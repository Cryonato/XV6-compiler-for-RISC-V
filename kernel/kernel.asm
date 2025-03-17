
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	4c013103          	ld	sp,1216(sp) # 8000b4c0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r"(x));
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	1761                	addi	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	0000b717          	auipc	a4,0xb
    80000054:	4e070713          	addi	a4,a4,1248 # 8000b530 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void
w_mscratch(uint64 x)
{
    asm volatile("csrw mscratch, %0" : : "r"(x));
    8000005e:	34071073          	csrw	mscratch,a4
    asm volatile("csrw mtvec, %0" : : "r"(x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	1fe78793          	addi	a5,a5,510 # 80006260 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
    asm volatile("csrr %0, mstatus" : "=r"(x));
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
    asm volatile("csrw mstatus, %0" : : "r"(x));
    80000076:	30079073          	csrw	mstatus,a5
    asm volatile("csrr %0, mie" : "=r"(x));
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
    asm volatile("csrw mie, %0" : : "r"(x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
    asm volatile("csrr %0, mstatus" : "=r"(x));
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd9e5f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r"(x));
    800000a8:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mepc, %0" : : "r"(x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	eee78793          	addi	a5,a5,-274 # 80000f9a <main>
    800000b4:	34179073          	csrw	mepc,a5
    asm volatile("csrw satp, %0" : : "r"(x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
    asm volatile("csrw medeleg, %0" : : "r"(x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
    asm volatile("csrw mideleg, %0" : : "r"(x));
    800000c6:	30379073          	csrw	mideleg,a5
    asm volatile("csrr %0, sie" : "=r"(x));
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
    asm volatile("csrw sie, %0" : : "r"(x));
    800000d2:	10479073          	csrw	sie,a5
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
    asm volatile("csrr %0, mhartid" : "=r"(x));
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
    asm volatile("mv tp, %0" : : "r"(x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	addi	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    {
        char c;
        if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	75c080e7          	jalr	1884(ra) # 80002886 <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7f6080e7          	jalr	2038(ra) # 80000930 <uartputc>
    for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
    }

    return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	addi	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
    uint target;
    int c;
    char cbuf;

    target = n;
    80000188:	00060b1b          	sext.w	s6,a2
    acquire(&cons.lock);
    8000018c:	00013517          	auipc	a0,0x13
    80000190:	4e450513          	addi	a0,a0,1252 # 80013670 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	b6c080e7          	jalr	-1172(ra) # 80000d00 <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	4d448493          	addi	s1,s1,1236 # 80013670 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a4:	00013917          	auipc	s2,0x13
    800001a8:	56490913          	addi	s2,s2,1380 # 80013708 <cons+0x98>
    while (n > 0)
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
        while (cons.r == cons.w)
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
            if (killed(myproc()))
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	aba080e7          	jalr	-1350(ra) # 80001c76 <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	50c080e7          	jalr	1292(ra) # 800026d0 <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
            sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	256080e7          	jalr	598(ra) # 80002428 <sleep>
        while (cons.r == cons.w)
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	48870713          	addi	a4,a4,1160 # 80013670 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

        if (c == C('D'))
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
            }
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	616080e7          	jalr	1558(ra) # 80002830 <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
            break;

        dst++;
    80000228:	0a05                	addi	s4,s4,1
        --n;
    8000022a:	39fd                	addiw	s3,s3,-1

        if (c == '\n')
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
                release(&cons.lock);
    80000236:	00013517          	auipc	a0,0x13
    8000023a:	43a50513          	addi	a0,a0,1082 # 80013670 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	b76080e7          	jalr	-1162(ra) # 80000db4 <release>
                return -1;
    80000246:	557d                	li	a0,-1
        }
    }
    release(&cons.lock);

    return target - n;
}
    80000248:	60e6                	ld	ra,88(sp)
    8000024a:	6446                	ld	s0,80(sp)
    8000024c:	64a6                	ld	s1,72(sp)
    8000024e:	6906                	ld	s2,64(sp)
    80000250:	79e2                	ld	s3,56(sp)
    80000252:	7a42                	ld	s4,48(sp)
    80000254:	7aa2                	ld	s5,40(sp)
    80000256:	7b02                	ld	s6,32(sp)
    80000258:	6125                	addi	sp,sp,96
    8000025a:	8082                	ret
            if (n < target)
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
                cons.r--;
    80000264:	00013717          	auipc	a4,0x13
    80000268:	4af72223          	sw	a5,1188(a4) # 80013708 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
    release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	3f650513          	addi	a0,a0,1014 # 80013670 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	b32080e7          	jalr	-1230(ra) # 80000db4 <release>
    return target - n;
    8000028a:	413b053b          	subw	a0,s6,s3
    8000028e:	bf6d                	j	80000248 <consoleread+0xda>
    80000290:	6be2                	ld	s7,24(sp)
    80000292:	b7e5                	j	8000027a <consoleread+0x10c>

0000000080000294 <consputc>:
{
    80000294:	1141                	addi	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	addi	s0,sp,16
    if (c == BACKSPACE)
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
        uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	5ae080e7          	jalr	1454(ra) # 80000852 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	addi	sp,sp,16
    800002b2:	8082                	ret
        uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	59c080e7          	jalr	1436(ra) # 80000852 <uartputc_sync>
        uartputc_sync(' ');
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	590080e7          	jalr	1424(ra) # 80000852 <uartputc_sync>
        uartputc_sync('\b');
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	586080e7          	jalr	1414(ra) # 80000852 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002d6:	1101                	addi	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	addi	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002e2:	00013517          	auipc	a0,0x13
    800002e6:	38e50513          	addi	a0,a0,910 # 80013670 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	a16080e7          	jalr	-1514(ra) # 80000d00 <acquire>

    switch (c)
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
    {
    case C('P'): // Print process list.
        procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	5d4080e7          	jalr	1492(ra) # 800028dc <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	36050513          	addi	a0,a0,864 # 80013670 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	a9c080e7          	jalr	-1380(ra) # 80000db4 <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	addi	sp,sp,32
    80000328:	8082                	ret
    switch (c)
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000332:	00013717          	auipc	a4,0x13
    80000336:	33e70713          	addi	a4,a4,830 # 80013670 <cons>
    8000033a:	0a072783          	lw	a5,160(a4)
    8000033e:	09872703          	lw	a4,152(a4)
    80000342:	9f99                	subw	a5,a5,a4
    80000344:	07f00713          	li	a4,127
    80000348:	fcf764e3          	bltu	a4,a5,80000310 <consoleintr+0x3a>
            c = (c == '\r') ? '\n' : c;
    8000034c:	47b5                	li	a5,13
    8000034e:	0cf48d63          	beq	s1,a5,80000428 <consoleintr+0x152>
            consputc(c);
    80000352:	8526                	mv	a0,s1
    80000354:	00000097          	auipc	ra,0x0
    80000358:	f40080e7          	jalr	-192(ra) # 80000294 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035c:	00013797          	auipc	a5,0x13
    80000360:	31478793          	addi	a5,a5,788 # 80013670 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addiw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	andi	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00013797          	auipc	a5,0x13
    8000038e:	37e7a783          	lw	a5,894(a5) # 80013708 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
        while (cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	2d070713          	addi	a4,a4,720 # 80013670 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	2c048493          	addi	s1,s1,704 # 80013670 <cons>
        while (cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003be:	37fd                	addiw	a5,a5,-1
    800003c0:	07f7f713          	andi	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
            cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
        while (cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
        if (cons.e != cons.w)
    800003f6:	00013717          	auipc	a4,0x13
    800003fa:	27a70713          	addi	a4,a4,634 # 80013670 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
            cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	30f72223          	sw	a5,772(a4) # 80013710 <cons+0xa0>
            consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
            consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00013797          	auipc	a5,0x13
    80000436:	23e78793          	addi	a5,a5,574 # 80013670 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addiw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	andi	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000456:	00013797          	auipc	a5,0x13
    8000045a:	2ac7ab23          	sw	a2,694(a5) # 8001370c <cons+0x9c>
                wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	2aa50513          	addi	a0,a0,682 # 80013708 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	026080e7          	jalr	38(ra) # 8000248c <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void consoleinit(void)
{
    80000470:	1141                	addi	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	addi	s0,sp,16
    initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b9858593          	addi	a1,a1,-1128 # 80008010 <__func__.1+0x8>
    80000480:	00013517          	auipc	a0,0x13
    80000484:	1f050513          	addi	a0,a0,496 # 80013670 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	7e8080e7          	jalr	2024(ra) # 80000c70 <initlock>

    uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	366080e7          	jalr	870(ra) # 800007f6 <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000498:	00023797          	auipc	a5,0x23
    8000049c:	37078793          	addi	a5,a5,880 # 80023808 <devsw>
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	cce70713          	addi	a4,a4,-818 # 8000016e <consoleread>
    800004a8:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    800004aa:	00000717          	auipc	a4,0x0
    800004ae:	c5670713          	addi	a4,a4,-938 # 80000100 <consolewrite>
    800004b2:	ef98                	sd	a4,24(a5)
}
    800004b4:	60a2                	ld	ra,8(sp)
    800004b6:	6402                	ld	s0,0(sp)
    800004b8:	0141                	addi	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004bc:	7179                	addi	sp,sp,-48
    800004be:	f406                	sd	ra,40(sp)
    800004c0:	f022                	sd	s0,32(sp)
    800004c2:	1800                	addi	s0,sp,48
    char buf[16];
    int i;
    uint x;

    if (sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0xe>
    800004c6:	08054963          	bltz	a0,80000558 <printint+0x9c>
        x = -xx;
    else
        x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	addi	a3,s0,-48

    i = 0;
    800004d2:	4701                	li	a4,0
    do
    {
        buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	36a60613          	addi	a2,a2,874 # 80008840 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addiw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	slli	a5,a5,0x20
    800004e8:	9381                	srli	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	addi	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

    if (sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
        buf[i++] = '-';
    80000506:	fe070793          	addi	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addiw	a4,a6,2

    while (--i >= 0)
    8000051a:	02e05b63          	blez	a4,80000550 <printint+0x94>
    8000051e:	ec26                	sd	s1,24(sp)
    80000520:	e84a                	sd	s2,16(sp)
    80000522:	fd040793          	addi	a5,s0,-48
    80000526:	00e784b3          	add	s1,a5,a4
    8000052a:	fff78913          	addi	s2,a5,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	377d                	addiw	a4,a4,-1
    80000532:	1702                	slli	a4,a4,0x20
    80000534:	9301                	srli	a4,a4,0x20
    80000536:	40e90933          	sub	s2,s2,a4
        consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d56080e7          	jalr	-682(ra) # 80000294 <consputc>
    while (--i >= 0)
    80000546:	14fd                	addi	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x7e>
    8000054c:	64e2                	ld	s1,24(sp)
    8000054e:	6942                	ld	s2,16(sp)
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	6145                	addi	sp,sp,48
    80000556:	8082                	ret
        x = -xx;
    80000558:	40a0053b          	negw	a0,a0
    if (sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
        x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    if (locking)
        release(&pr.lock);
}

void panic(char *s, ...)
{
    80000560:	711d                	addi	sp,sp,-96
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	addi	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
    8000056c:	e40c                	sd	a1,8(s0)
    8000056e:	e810                	sd	a2,16(s0)
    80000570:	ec14                	sd	a3,24(s0)
    80000572:	f018                	sd	a4,32(s0)
    80000574:	f41c                	sd	a5,40(s0)
    80000576:	03043823          	sd	a6,48(s0)
    8000057a:	03143c23          	sd	a7,56(s0)
    pr.locking = 0;
    8000057e:	00013797          	auipc	a5,0x13
    80000582:	1a07a923          	sw	zero,434(a5) # 80013730 <pr+0x18>
    printf("panic: ");
    80000586:	00008517          	auipc	a0,0x8
    8000058a:	a9250513          	addi	a0,a0,-1390 # 80008018 <__func__.1+0x10>
    8000058e:	00000097          	auipc	ra,0x0
    80000592:	02e080e7          	jalr	46(ra) # 800005bc <printf>
    printf(s);
    80000596:	8526                	mv	a0,s1
    80000598:	00000097          	auipc	ra,0x0
    8000059c:	024080e7          	jalr	36(ra) # 800005bc <printf>
    printf("\n");
    800005a0:	00008517          	auipc	a0,0x8
    800005a4:	a8050513          	addi	a0,a0,-1408 # 80008020 <__func__.1+0x18>
    800005a8:	00000097          	auipc	ra,0x0
    800005ac:	014080e7          	jalr	20(ra) # 800005bc <printf>
    panicked = 1; // freeze uart output from other CPUs
    800005b0:	4785                	li	a5,1
    800005b2:	0000b717          	auipc	a4,0xb
    800005b6:	f2f72723          	sw	a5,-210(a4) # 8000b4e0 <panicked>
    for (;;)
    800005ba:	a001                	j	800005ba <panic+0x5a>

00000000800005bc <printf>:
{
    800005bc:	7131                	addi	sp,sp,-192
    800005be:	fc86                	sd	ra,120(sp)
    800005c0:	f8a2                	sd	s0,112(sp)
    800005c2:	e8d2                	sd	s4,80(sp)
    800005c4:	f06a                	sd	s10,32(sp)
    800005c6:	0100                	addi	s0,sp,128
    800005c8:	8a2a                	mv	s4,a0
    800005ca:	e40c                	sd	a1,8(s0)
    800005cc:	e810                	sd	a2,16(s0)
    800005ce:	ec14                	sd	a3,24(s0)
    800005d0:	f018                	sd	a4,32(s0)
    800005d2:	f41c                	sd	a5,40(s0)
    800005d4:	03043823          	sd	a6,48(s0)
    800005d8:	03143c23          	sd	a7,56(s0)
    locking = pr.locking;
    800005dc:	00013d17          	auipc	s10,0x13
    800005e0:	154d2d03          	lw	s10,340(s10) # 80013730 <pr+0x18>
    if (locking)
    800005e4:	040d1463          	bnez	s10,8000062c <printf+0x70>
    if (fmt == 0)
    800005e8:	040a0b63          	beqz	s4,8000063e <printf+0x82>
    va_start(ap, fmt);
    800005ec:	00840793          	addi	a5,s0,8
    800005f0:	f8f43423          	sd	a5,-120(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005f4:	000a4503          	lbu	a0,0(s4)
    800005f8:	18050b63          	beqz	a0,8000078e <printf+0x1d2>
    800005fc:	f4a6                	sd	s1,104(sp)
    800005fe:	f0ca                	sd	s2,96(sp)
    80000600:	ecce                	sd	s3,88(sp)
    80000602:	e4d6                	sd	s5,72(sp)
    80000604:	e0da                	sd	s6,64(sp)
    80000606:	fc5e                	sd	s7,56(sp)
    80000608:	f862                	sd	s8,48(sp)
    8000060a:	f466                	sd	s9,40(sp)
    8000060c:	ec6e                	sd	s11,24(sp)
    8000060e:	4981                	li	s3,0
        if (c != '%')
    80000610:	02500b13          	li	s6,37
        switch (c)
    80000614:	07000b93          	li	s7,112
    consputc('x');
    80000618:	4cc1                	li	s9,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000061a:	00008a97          	auipc	s5,0x8
    8000061e:	226a8a93          	addi	s5,s5,550 # 80008840 <digits>
        switch (c)
    80000622:	07300c13          	li	s8,115
    80000626:	06400d93          	li	s11,100
    8000062a:	a0b1                	j	80000676 <printf+0xba>
        acquire(&pr.lock);
    8000062c:	00013517          	auipc	a0,0x13
    80000630:	0ec50513          	addi	a0,a0,236 # 80013718 <pr>
    80000634:	00000097          	auipc	ra,0x0
    80000638:	6cc080e7          	jalr	1740(ra) # 80000d00 <acquire>
    8000063c:	b775                	j	800005e8 <printf+0x2c>
    8000063e:	f4a6                	sd	s1,104(sp)
    80000640:	f0ca                	sd	s2,96(sp)
    80000642:	ecce                	sd	s3,88(sp)
    80000644:	e4d6                	sd	s5,72(sp)
    80000646:	e0da                	sd	s6,64(sp)
    80000648:	fc5e                	sd	s7,56(sp)
    8000064a:	f862                	sd	s8,48(sp)
    8000064c:	f466                	sd	s9,40(sp)
    8000064e:	ec6e                	sd	s11,24(sp)
        panic("null fmt");
    80000650:	00008517          	auipc	a0,0x8
    80000654:	9e050513          	addi	a0,a0,-1568 # 80008030 <__func__.1+0x28>
    80000658:	00000097          	auipc	ra,0x0
    8000065c:	f08080e7          	jalr	-248(ra) # 80000560 <panic>
            consputc(c);
    80000660:	00000097          	auipc	ra,0x0
    80000664:	c34080e7          	jalr	-972(ra) # 80000294 <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000668:	2985                	addiw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c503          	lbu	a0,0(a5)
    80000672:	10050563          	beqz	a0,8000077c <printf+0x1c0>
        if (c != '%')
    80000676:	ff6515e3          	bne	a0,s6,80000660 <printf+0xa4>
        c = fmt[++i] & 0xff;
    8000067a:	2985                	addiw	s3,s3,1
    8000067c:	013a07b3          	add	a5,s4,s3
    80000680:	0007c783          	lbu	a5,0(a5)
    80000684:	0007849b          	sext.w	s1,a5
        if (c == 0)
    80000688:	10078b63          	beqz	a5,8000079e <printf+0x1e2>
        switch (c)
    8000068c:	05778a63          	beq	a5,s7,800006e0 <printf+0x124>
    80000690:	02fbf663          	bgeu	s7,a5,800006bc <printf+0x100>
    80000694:	09878863          	beq	a5,s8,80000724 <printf+0x168>
    80000698:	07800713          	li	a4,120
    8000069c:	0ce79563          	bne	a5,a4,80000766 <printf+0x1aa>
            printint(va_arg(ap, int), 16, 1);
    800006a0:	f8843783          	ld	a5,-120(s0)
    800006a4:	00878713          	addi	a4,a5,8
    800006a8:	f8e43423          	sd	a4,-120(s0)
    800006ac:	4605                	li	a2,1
    800006ae:	85e6                	mv	a1,s9
    800006b0:	4388                	lw	a0,0(a5)
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	e0a080e7          	jalr	-502(ra) # 800004bc <printint>
            break;
    800006ba:	b77d                	j	80000668 <printf+0xac>
        switch (c)
    800006bc:	09678f63          	beq	a5,s6,8000075a <printf+0x19e>
    800006c0:	0bb79363          	bne	a5,s11,80000766 <printf+0x1aa>
            printint(va_arg(ap, int), 10, 1);
    800006c4:	f8843783          	ld	a5,-120(s0)
    800006c8:	00878713          	addi	a4,a5,8
    800006cc:	f8e43423          	sd	a4,-120(s0)
    800006d0:	4605                	li	a2,1
    800006d2:	45a9                	li	a1,10
    800006d4:	4388                	lw	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	de6080e7          	jalr	-538(ra) # 800004bc <printint>
            break;
    800006de:	b769                	j	80000668 <printf+0xac>
            printptr(va_arg(ap, uint64));
    800006e0:	f8843783          	ld	a5,-120(s0)
    800006e4:	00878713          	addi	a4,a5,8
    800006e8:	f8e43423          	sd	a4,-120(s0)
    800006ec:	0007b903          	ld	s2,0(a5)
    consputc('0');
    800006f0:	03000513          	li	a0,48
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	ba0080e7          	jalr	-1120(ra) # 80000294 <consputc>
    consputc('x');
    800006fc:	07800513          	li	a0,120
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b94080e7          	jalr	-1132(ra) # 80000294 <consputc>
    80000708:	84e6                	mv	s1,s9
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000070a:	03c95793          	srli	a5,s2,0x3c
    8000070e:	97d6                	add	a5,a5,s5
    80000710:	0007c503          	lbu	a0,0(a5)
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b80080e7          	jalr	-1152(ra) # 80000294 <consputc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000071c:	0912                	slli	s2,s2,0x4
    8000071e:	34fd                	addiw	s1,s1,-1
    80000720:	f4ed                	bnez	s1,8000070a <printf+0x14e>
    80000722:	b799                	j	80000668 <printf+0xac>
            if ((s = va_arg(ap, char *)) == 0)
    80000724:	f8843783          	ld	a5,-120(s0)
    80000728:	00878713          	addi	a4,a5,8
    8000072c:	f8e43423          	sd	a4,-120(s0)
    80000730:	6384                	ld	s1,0(a5)
    80000732:	cc89                	beqz	s1,8000074c <printf+0x190>
            for (; *s; s++)
    80000734:	0004c503          	lbu	a0,0(s1)
    80000738:	d905                	beqz	a0,80000668 <printf+0xac>
                consputc(*s);
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b5a080e7          	jalr	-1190(ra) # 80000294 <consputc>
            for (; *s; s++)
    80000742:	0485                	addi	s1,s1,1
    80000744:	0004c503          	lbu	a0,0(s1)
    80000748:	f96d                	bnez	a0,8000073a <printf+0x17e>
    8000074a:	bf39                	j	80000668 <printf+0xac>
                s = "(null)";
    8000074c:	00008497          	auipc	s1,0x8
    80000750:	8dc48493          	addi	s1,s1,-1828 # 80008028 <__func__.1+0x20>
            for (; *s; s++)
    80000754:	02800513          	li	a0,40
    80000758:	b7cd                	j	8000073a <printf+0x17e>
            consputc('%');
    8000075a:	855a                	mv	a0,s6
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	b38080e7          	jalr	-1224(ra) # 80000294 <consputc>
            break;
    80000764:	b711                	j	80000668 <printf+0xac>
            consputc('%');
    80000766:	855a                	mv	a0,s6
    80000768:	00000097          	auipc	ra,0x0
    8000076c:	b2c080e7          	jalr	-1236(ra) # 80000294 <consputc>
            consputc(c);
    80000770:	8526                	mv	a0,s1
    80000772:	00000097          	auipc	ra,0x0
    80000776:	b22080e7          	jalr	-1246(ra) # 80000294 <consputc>
            break;
    8000077a:	b5fd                	j	80000668 <printf+0xac>
    8000077c:	74a6                	ld	s1,104(sp)
    8000077e:	7906                	ld	s2,96(sp)
    80000780:	69e6                	ld	s3,88(sp)
    80000782:	6aa6                	ld	s5,72(sp)
    80000784:	6b06                	ld	s6,64(sp)
    80000786:	7be2                	ld	s7,56(sp)
    80000788:	7c42                	ld	s8,48(sp)
    8000078a:	7ca2                	ld	s9,40(sp)
    8000078c:	6de2                	ld	s11,24(sp)
    if (locking)
    8000078e:	020d1263          	bnez	s10,800007b2 <printf+0x1f6>
}
    80000792:	70e6                	ld	ra,120(sp)
    80000794:	7446                	ld	s0,112(sp)
    80000796:	6a46                	ld	s4,80(sp)
    80000798:	7d02                	ld	s10,32(sp)
    8000079a:	6129                	addi	sp,sp,192
    8000079c:	8082                	ret
    8000079e:	74a6                	ld	s1,104(sp)
    800007a0:	7906                	ld	s2,96(sp)
    800007a2:	69e6                	ld	s3,88(sp)
    800007a4:	6aa6                	ld	s5,72(sp)
    800007a6:	6b06                	ld	s6,64(sp)
    800007a8:	7be2                	ld	s7,56(sp)
    800007aa:	7c42                	ld	s8,48(sp)
    800007ac:	7ca2                	ld	s9,40(sp)
    800007ae:	6de2                	ld	s11,24(sp)
    800007b0:	bff9                	j	8000078e <printf+0x1d2>
        release(&pr.lock);
    800007b2:	00013517          	auipc	a0,0x13
    800007b6:	f6650513          	addi	a0,a0,-154 # 80013718 <pr>
    800007ba:	00000097          	auipc	ra,0x0
    800007be:	5fa080e7          	jalr	1530(ra) # 80000db4 <release>
}
    800007c2:	bfc1                	j	80000792 <printf+0x1d6>

00000000800007c4 <printfinit>:
        ;
}

void printfinit(void)
{
    800007c4:	1101                	addi	sp,sp,-32
    800007c6:	ec06                	sd	ra,24(sp)
    800007c8:	e822                	sd	s0,16(sp)
    800007ca:	e426                	sd	s1,8(sp)
    800007cc:	1000                	addi	s0,sp,32
    initlock(&pr.lock, "pr");
    800007ce:	00013497          	auipc	s1,0x13
    800007d2:	f4a48493          	addi	s1,s1,-182 # 80013718 <pr>
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	86a58593          	addi	a1,a1,-1942 # 80008040 <__func__.1+0x38>
    800007de:	8526                	mv	a0,s1
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	490080e7          	jalr	1168(ra) # 80000c70 <initlock>
    pr.locking = 1;
    800007e8:	4785                	li	a5,1
    800007ea:	cc9c                	sw	a5,24(s1)
}
    800007ec:	60e2                	ld	ra,24(sp)
    800007ee:	6442                	ld	s0,16(sp)
    800007f0:	64a2                	ld	s1,8(sp)
    800007f2:	6105                	addi	sp,sp,32
    800007f4:	8082                	ret

00000000800007f6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007f6:	1141                	addi	sp,sp,-16
    800007f8:	e406                	sd	ra,8(sp)
    800007fa:	e022                	sd	s0,0(sp)
    800007fc:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007fe:	100007b7          	lui	a5,0x10000
    80000802:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000806:	10000737          	lui	a4,0x10000
    8000080a:	f8000693          	li	a3,-128
    8000080e:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000812:	468d                	li	a3,3
    80000814:	10000637          	lui	a2,0x10000
    80000818:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000081c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000820:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000824:	10000737          	lui	a4,0x10000
    80000828:	461d                	li	a2,7
    8000082a:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000082e:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000832:	00008597          	auipc	a1,0x8
    80000836:	81658593          	addi	a1,a1,-2026 # 80008048 <__func__.1+0x40>
    8000083a:	00013517          	auipc	a0,0x13
    8000083e:	efe50513          	addi	a0,a0,-258 # 80013738 <uart_tx_lock>
    80000842:	00000097          	auipc	ra,0x0
    80000846:	42e080e7          	jalr	1070(ra) # 80000c70 <initlock>
}
    8000084a:	60a2                	ld	ra,8(sp)
    8000084c:	6402                	ld	s0,0(sp)
    8000084e:	0141                	addi	sp,sp,16
    80000850:	8082                	ret

0000000080000852 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000852:	1101                	addi	sp,sp,-32
    80000854:	ec06                	sd	ra,24(sp)
    80000856:	e822                	sd	s0,16(sp)
    80000858:	e426                	sd	s1,8(sp)
    8000085a:	1000                	addi	s0,sp,32
    8000085c:	84aa                	mv	s1,a0
  push_off();
    8000085e:	00000097          	auipc	ra,0x0
    80000862:	456080e7          	jalr	1110(ra) # 80000cb4 <push_off>

  if(panicked){
    80000866:	0000b797          	auipc	a5,0xb
    8000086a:	c7a7a783          	lw	a5,-902(a5) # 8000b4e0 <panicked>
    8000086e:	eb85                	bnez	a5,8000089e <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000870:	10000737          	lui	a4,0x10000
    80000874:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000876:	00074783          	lbu	a5,0(a4)
    8000087a:	0207f793          	andi	a5,a5,32
    8000087e:	dfe5                	beqz	a5,80000876 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000880:	0ff4f513          	zext.b	a0,s1
    80000884:	100007b7          	lui	a5,0x10000
    80000888:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088c:	00000097          	auipc	ra,0x0
    80000890:	4c8080e7          	jalr	1224(ra) # 80000d54 <pop_off>
}
    80000894:	60e2                	ld	ra,24(sp)
    80000896:	6442                	ld	s0,16(sp)
    80000898:	64a2                	ld	s1,8(sp)
    8000089a:	6105                	addi	sp,sp,32
    8000089c:	8082                	ret
    for(;;)
    8000089e:	a001                	j	8000089e <uartputc_sync+0x4c>

00000000800008a0 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008a0:	0000b797          	auipc	a5,0xb
    800008a4:	c487b783          	ld	a5,-952(a5) # 8000b4e8 <uart_tx_r>
    800008a8:	0000b717          	auipc	a4,0xb
    800008ac:	c4873703          	ld	a4,-952(a4) # 8000b4f0 <uart_tx_w>
    800008b0:	06f70f63          	beq	a4,a5,8000092e <uartstart+0x8e>
{
    800008b4:	7139                	addi	sp,sp,-64
    800008b6:	fc06                	sd	ra,56(sp)
    800008b8:	f822                	sd	s0,48(sp)
    800008ba:	f426                	sd	s1,40(sp)
    800008bc:	f04a                	sd	s2,32(sp)
    800008be:	ec4e                	sd	s3,24(sp)
    800008c0:	e852                	sd	s4,16(sp)
    800008c2:	e456                	sd	s5,8(sp)
    800008c4:	e05a                	sd	s6,0(sp)
    800008c6:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c8:	10000937          	lui	s2,0x10000
    800008cc:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ce:	00013a97          	auipc	s5,0x13
    800008d2:	e6aa8a93          	addi	s5,s5,-406 # 80013738 <uart_tx_lock>
    uart_tx_r += 1;
    800008d6:	0000b497          	auipc	s1,0xb
    800008da:	c1248493          	addi	s1,s1,-1006 # 8000b4e8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008de:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e2:	0000b997          	auipc	s3,0xb
    800008e6:	c0e98993          	addi	s3,s3,-1010 # 8000b4f0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ea:	00094703          	lbu	a4,0(s2)
    800008ee:	02077713          	andi	a4,a4,32
    800008f2:	c705                	beqz	a4,8000091a <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008f4:	01f7f713          	andi	a4,a5,31
    800008f8:	9756                	add	a4,a4,s5
    800008fa:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008fe:	0785                	addi	a5,a5,1
    80000900:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    80000902:	8526                	mv	a0,s1
    80000904:	00002097          	auipc	ra,0x2
    80000908:	b88080e7          	jalr	-1144(ra) # 8000248c <wakeup>
    WriteReg(THR, c);
    8000090c:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000910:	609c                	ld	a5,0(s1)
    80000912:	0009b703          	ld	a4,0(s3)
    80000916:	fcf71ae3          	bne	a4,a5,800008ea <uartstart+0x4a>
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
    8000092e:	8082                	ret

0000000080000930 <uartputc>:
{
    80000930:	7179                	addi	sp,sp,-48
    80000932:	f406                	sd	ra,40(sp)
    80000934:	f022                	sd	s0,32(sp)
    80000936:	ec26                	sd	s1,24(sp)
    80000938:	e84a                	sd	s2,16(sp)
    8000093a:	e44e                	sd	s3,8(sp)
    8000093c:	e052                	sd	s4,0(sp)
    8000093e:	1800                	addi	s0,sp,48
    80000940:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000942:	00013517          	auipc	a0,0x13
    80000946:	df650513          	addi	a0,a0,-522 # 80013738 <uart_tx_lock>
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	3b6080e7          	jalr	950(ra) # 80000d00 <acquire>
  if(panicked){
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	b8e7a783          	lw	a5,-1138(a5) # 8000b4e0 <panicked>
    8000095a:	e7c9                	bnez	a5,800009e4 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000095c:	0000b717          	auipc	a4,0xb
    80000960:	b9473703          	ld	a4,-1132(a4) # 8000b4f0 <uart_tx_w>
    80000964:	0000b797          	auipc	a5,0xb
    80000968:	b847b783          	ld	a5,-1148(a5) # 8000b4e8 <uart_tx_r>
    8000096c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000970:	00013997          	auipc	s3,0x13
    80000974:	dc898993          	addi	s3,s3,-568 # 80013738 <uart_tx_lock>
    80000978:	0000b497          	auipc	s1,0xb
    8000097c:	b7048493          	addi	s1,s1,-1168 # 8000b4e8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000980:	0000b917          	auipc	s2,0xb
    80000984:	b7090913          	addi	s2,s2,-1168 # 8000b4f0 <uart_tx_w>
    80000988:	00e79f63          	bne	a5,a4,800009a6 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000098c:	85ce                	mv	a1,s3
    8000098e:	8526                	mv	a0,s1
    80000990:	00002097          	auipc	ra,0x2
    80000994:	a98080e7          	jalr	-1384(ra) # 80002428 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000998:	00093703          	ld	a4,0(s2)
    8000099c:	609c                	ld	a5,0(s1)
    8000099e:	02078793          	addi	a5,a5,32
    800009a2:	fee785e3          	beq	a5,a4,8000098c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a6:	00013497          	auipc	s1,0x13
    800009aa:	d9248493          	addi	s1,s1,-622 # 80013738 <uart_tx_lock>
    800009ae:	01f77793          	andi	a5,a4,31
    800009b2:	97a6                	add	a5,a5,s1
    800009b4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009b8:	0705                	addi	a4,a4,1
    800009ba:	0000b797          	auipc	a5,0xb
    800009be:	b2e7bb23          	sd	a4,-1226(a5) # 8000b4f0 <uart_tx_w>
  uartstart();
    800009c2:	00000097          	auipc	ra,0x0
    800009c6:	ede080e7          	jalr	-290(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    800009ca:	8526                	mv	a0,s1
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	3e8080e7          	jalr	1000(ra) # 80000db4 <release>
}
    800009d4:	70a2                	ld	ra,40(sp)
    800009d6:	7402                	ld	s0,32(sp)
    800009d8:	64e2                	ld	s1,24(sp)
    800009da:	6942                	ld	s2,16(sp)
    800009dc:	69a2                	ld	s3,8(sp)
    800009de:	6a02                	ld	s4,0(sp)
    800009e0:	6145                	addi	sp,sp,48
    800009e2:	8082                	ret
    for(;;)
    800009e4:	a001                	j	800009e4 <uartputc+0xb4>

00000000800009e6 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e6:	1141                	addi	sp,sp,-16
    800009e8:	e422                	sd	s0,8(sp)
    800009ea:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009f2:	0007c783          	lbu	a5,0(a5)
    800009f6:	8b85                	andi	a5,a5,1
    800009f8:	cb81                	beqz	a5,80000a08 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009fa:	100007b7          	lui	a5,0x10000
    800009fe:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a02:	6422                	ld	s0,8(sp)
    80000a04:	0141                	addi	sp,sp,16
    80000a06:	8082                	ret
    return -1;
    80000a08:	557d                	li	a0,-1
    80000a0a:	bfe5                	j	80000a02 <uartgetc+0x1c>

0000000080000a0c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a0c:	1101                	addi	sp,sp,-32
    80000a0e:	ec06                	sd	ra,24(sp)
    80000a10:	e822                	sd	s0,16(sp)
    80000a12:	e426                	sd	s1,8(sp)
    80000a14:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a16:	54fd                	li	s1,-1
    80000a18:	a029                	j	80000a22 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a1a:	00000097          	auipc	ra,0x0
    80000a1e:	8bc080e7          	jalr	-1860(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	fc4080e7          	jalr	-60(ra) # 800009e6 <uartgetc>
    if(c == -1)
    80000a2a:	fe9518e3          	bne	a0,s1,80000a1a <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a2e:	00013497          	auipc	s1,0x13
    80000a32:	d0a48493          	addi	s1,s1,-758 # 80013738 <uart_tx_lock>
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	2c8080e7          	jalr	712(ra) # 80000d00 <acquire>
  uartstart();
    80000a40:	00000097          	auipc	ra,0x0
    80000a44:	e60080e7          	jalr	-416(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    80000a48:	8526                	mv	a0,s1
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	36a080e7          	jalr	874(ra) # 80000db4 <release>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
    80000a68:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000a6a:	0000b797          	auipc	a5,0xb
    80000a6e:	a967b783          	ld	a5,-1386(a5) # 8000b500 <MAX_PAGES>
    80000a72:	c799                	beqz	a5,80000a80 <kfree+0x24>
        assert(FREE_PAGES < MAX_PAGES);
    80000a74:	0000b717          	auipc	a4,0xb
    80000a78:	a8473703          	ld	a4,-1404(a4) # 8000b4f8 <FREE_PAGES>
    80000a7c:	06f77663          	bgeu	a4,a5,80000ae8 <kfree+0x8c>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a80:	03449793          	slli	a5,s1,0x34
    80000a84:	efc1                	bnez	a5,80000b1c <kfree+0xc0>
    80000a86:	00024797          	auipc	a5,0x24
    80000a8a:	f1a78793          	addi	a5,a5,-230 # 800249a0 <end>
    80000a8e:	08f4e763          	bltu	s1,a5,80000b1c <kfree+0xc0>
    80000a92:	47c5                	li	a5,17
    80000a94:	07ee                	slli	a5,a5,0x1b
    80000a96:	08f4f363          	bgeu	s1,a5,80000b1c <kfree+0xc0>
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);
    80000a9a:	6605                	lui	a2,0x1
    80000a9c:	4585                	li	a1,1
    80000a9e:	8526                	mv	a0,s1
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	35c080e7          	jalr	860(ra) # 80000dfc <memset>

    r = (struct run *)pa;

    acquire(&kmem.lock);
    80000aa8:	00013917          	auipc	s2,0x13
    80000aac:	cc890913          	addi	s2,s2,-824 # 80013770 <kmem>
    80000ab0:	854a                	mv	a0,s2
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	24e080e7          	jalr	590(ra) # 80000d00 <acquire>
    r->next = kmem.freelist;
    80000aba:	01893783          	ld	a5,24(s2)
    80000abe:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000ac0:	00993c23          	sd	s1,24(s2)
    FREE_PAGES++;
    80000ac4:	0000b717          	auipc	a4,0xb
    80000ac8:	a3470713          	addi	a4,a4,-1484 # 8000b4f8 <FREE_PAGES>
    80000acc:	631c                	ld	a5,0(a4)
    80000ace:	0785                	addi	a5,a5,1
    80000ad0:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000ad2:	854a                	mv	a0,s2
    80000ad4:	00000097          	auipc	ra,0x0
    80000ad8:	2e0080e7          	jalr	736(ra) # 80000db4 <release>
}
    80000adc:	60e2                	ld	ra,24(sp)
    80000ade:	6442                	ld	s0,16(sp)
    80000ae0:	64a2                	ld	s1,8(sp)
    80000ae2:	6902                	ld	s2,0(sp)
    80000ae4:	6105                	addi	sp,sp,32
    80000ae6:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000ae8:	03700693          	li	a3,55
    80000aec:	00007617          	auipc	a2,0x7
    80000af0:	51c60613          	addi	a2,a2,1308 # 80008008 <__func__.1>
    80000af4:	00007597          	auipc	a1,0x7
    80000af8:	55c58593          	addi	a1,a1,1372 # 80008050 <__func__.1+0x48>
    80000afc:	00007517          	auipc	a0,0x7
    80000b00:	56450513          	addi	a0,a0,1380 # 80008060 <__func__.1+0x58>
    80000b04:	00000097          	auipc	ra,0x0
    80000b08:	ab8080e7          	jalr	-1352(ra) # 800005bc <printf>
    80000b0c:	00007517          	auipc	a0,0x7
    80000b10:	56450513          	addi	a0,a0,1380 # 80008070 <__func__.1+0x68>
    80000b14:	00000097          	auipc	ra,0x0
    80000b18:	a4c080e7          	jalr	-1460(ra) # 80000560 <panic>
        panic("kfree");
    80000b1c:	00007517          	auipc	a0,0x7
    80000b20:	56450513          	addi	a0,a0,1380 # 80008080 <__func__.1+0x78>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	a3c080e7          	jalr	-1476(ra) # 80000560 <panic>

0000000080000b2c <freerange>:
{
    80000b2c:	7179                	addi	sp,sp,-48
    80000b2e:	f406                	sd	ra,40(sp)
    80000b30:	f022                	sd	s0,32(sp)
    80000b32:	ec26                	sd	s1,24(sp)
    80000b34:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000b36:	6785                	lui	a5,0x1
    80000b38:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b3c:	00e504b3          	add	s1,a0,a4
    80000b40:	777d                	lui	a4,0xfffff
    80000b42:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b44:	94be                	add	s1,s1,a5
    80000b46:	0295e463          	bltu	a1,s1,80000b6e <freerange+0x42>
    80000b4a:	e84a                	sd	s2,16(sp)
    80000b4c:	e44e                	sd	s3,8(sp)
    80000b4e:	e052                	sd	s4,0(sp)
    80000b50:	892e                	mv	s2,a1
        kfree(p);
    80000b52:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b54:	6985                	lui	s3,0x1
        kfree(p);
    80000b56:	01448533          	add	a0,s1,s4
    80000b5a:	00000097          	auipc	ra,0x0
    80000b5e:	f02080e7          	jalr	-254(ra) # 80000a5c <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b62:	94ce                	add	s1,s1,s3
    80000b64:	fe9979e3          	bgeu	s2,s1,80000b56 <freerange+0x2a>
    80000b68:	6942                	ld	s2,16(sp)
    80000b6a:	69a2                	ld	s3,8(sp)
    80000b6c:	6a02                	ld	s4,0(sp)
}
    80000b6e:	70a2                	ld	ra,40(sp)
    80000b70:	7402                	ld	s0,32(sp)
    80000b72:	64e2                	ld	s1,24(sp)
    80000b74:	6145                	addi	sp,sp,48
    80000b76:	8082                	ret

0000000080000b78 <kinit>:
{
    80000b78:	1141                	addi	sp,sp,-16
    80000b7a:	e406                	sd	ra,8(sp)
    80000b7c:	e022                	sd	s0,0(sp)
    80000b7e:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000b80:	00007597          	auipc	a1,0x7
    80000b84:	50858593          	addi	a1,a1,1288 # 80008088 <__func__.1+0x80>
    80000b88:	00013517          	auipc	a0,0x13
    80000b8c:	be850513          	addi	a0,a0,-1048 # 80013770 <kmem>
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	0e0080e7          	jalr	224(ra) # 80000c70 <initlock>
    freerange(end, (void *)PHYSTOP);
    80000b98:	45c5                	li	a1,17
    80000b9a:	05ee                	slli	a1,a1,0x1b
    80000b9c:	00024517          	auipc	a0,0x24
    80000ba0:	e0450513          	addi	a0,a0,-508 # 800249a0 <end>
    80000ba4:	00000097          	auipc	ra,0x0
    80000ba8:	f88080e7          	jalr	-120(ra) # 80000b2c <freerange>
    MAX_PAGES = FREE_PAGES;
    80000bac:	0000b797          	auipc	a5,0xb
    80000bb0:	94c7b783          	ld	a5,-1716(a5) # 8000b4f8 <FREE_PAGES>
    80000bb4:	0000b717          	auipc	a4,0xb
    80000bb8:	94f73623          	sd	a5,-1716(a4) # 8000b500 <MAX_PAGES>
}
    80000bbc:	60a2                	ld	ra,8(sp)
    80000bbe:	6402                	ld	s0,0(sp)
    80000bc0:	0141                	addi	sp,sp,16
    80000bc2:	8082                	ret

0000000080000bc4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000bc4:	1101                	addi	sp,sp,-32
    80000bc6:	ec06                	sd	ra,24(sp)
    80000bc8:	e822                	sd	s0,16(sp)
    80000bca:	e426                	sd	s1,8(sp)
    80000bcc:	1000                	addi	s0,sp,32
    assert(FREE_PAGES > 0);
    80000bce:	0000b797          	auipc	a5,0xb
    80000bd2:	92a7b783          	ld	a5,-1750(a5) # 8000b4f8 <FREE_PAGES>
    80000bd6:	cbb1                	beqz	a5,80000c2a <kalloc+0x66>
    struct run *r;

    acquire(&kmem.lock);
    80000bd8:	00013497          	auipc	s1,0x13
    80000bdc:	b9848493          	addi	s1,s1,-1128 # 80013770 <kmem>
    80000be0:	8526                	mv	a0,s1
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	11e080e7          	jalr	286(ra) # 80000d00 <acquire>
    r = kmem.freelist;
    80000bea:	6c84                	ld	s1,24(s1)
    if (r)
    80000bec:	c8ad                	beqz	s1,80000c5e <kalloc+0x9a>
        kmem.freelist = r->next;
    80000bee:	609c                	ld	a5,0(s1)
    80000bf0:	00013517          	auipc	a0,0x13
    80000bf4:	b8050513          	addi	a0,a0,-1152 # 80013770 <kmem>
    80000bf8:	ed1c                	sd	a5,24(a0)
    release(&kmem.lock);
    80000bfa:	00000097          	auipc	ra,0x0
    80000bfe:	1ba080e7          	jalr	442(ra) # 80000db4 <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000c02:	6605                	lui	a2,0x1
    80000c04:	4595                	li	a1,5
    80000c06:	8526                	mv	a0,s1
    80000c08:	00000097          	auipc	ra,0x0
    80000c0c:	1f4080e7          	jalr	500(ra) # 80000dfc <memset>
    FREE_PAGES--;
    80000c10:	0000b717          	auipc	a4,0xb
    80000c14:	8e870713          	addi	a4,a4,-1816 # 8000b4f8 <FREE_PAGES>
    80000c18:	631c                	ld	a5,0(a4)
    80000c1a:	17fd                	addi	a5,a5,-1
    80000c1c:	e31c                	sd	a5,0(a4)
    return (void *)r;
}
    80000c1e:	8526                	mv	a0,s1
    80000c20:	60e2                	ld	ra,24(sp)
    80000c22:	6442                	ld	s0,16(sp)
    80000c24:	64a2                	ld	s1,8(sp)
    80000c26:	6105                	addi	sp,sp,32
    80000c28:	8082                	ret
    assert(FREE_PAGES > 0);
    80000c2a:	04f00693          	li	a3,79
    80000c2e:	00007617          	auipc	a2,0x7
    80000c32:	3d260613          	addi	a2,a2,978 # 80008000 <etext>
    80000c36:	00007597          	auipc	a1,0x7
    80000c3a:	41a58593          	addi	a1,a1,1050 # 80008050 <__func__.1+0x48>
    80000c3e:	00007517          	auipc	a0,0x7
    80000c42:	42250513          	addi	a0,a0,1058 # 80008060 <__func__.1+0x58>
    80000c46:	00000097          	auipc	ra,0x0
    80000c4a:	976080e7          	jalr	-1674(ra) # 800005bc <printf>
    80000c4e:	00007517          	auipc	a0,0x7
    80000c52:	42250513          	addi	a0,a0,1058 # 80008070 <__func__.1+0x68>
    80000c56:	00000097          	auipc	ra,0x0
    80000c5a:	90a080e7          	jalr	-1782(ra) # 80000560 <panic>
    release(&kmem.lock);
    80000c5e:	00013517          	auipc	a0,0x13
    80000c62:	b1250513          	addi	a0,a0,-1262 # 80013770 <kmem>
    80000c66:	00000097          	auipc	ra,0x0
    80000c6a:	14e080e7          	jalr	334(ra) # 80000db4 <release>
    if (r)
    80000c6e:	b74d                	j	80000c10 <kalloc+0x4c>

0000000080000c70 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c70:	1141                	addi	sp,sp,-16
    80000c72:	e422                	sd	s0,8(sp)
    80000c74:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c76:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c78:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c7c:	00053823          	sd	zero,16(a0)
}
    80000c80:	6422                	ld	s0,8(sp)
    80000c82:	0141                	addi	sp,sp,16
    80000c84:	8082                	ret

0000000080000c86 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c86:	411c                	lw	a5,0(a0)
    80000c88:	e399                	bnez	a5,80000c8e <holding+0x8>
    80000c8a:	4501                	li	a0,0
  return r;
}
    80000c8c:	8082                	ret
{
    80000c8e:	1101                	addi	sp,sp,-32
    80000c90:	ec06                	sd	ra,24(sp)
    80000c92:	e822                	sd	s0,16(sp)
    80000c94:	e426                	sd	s1,8(sp)
    80000c96:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c98:	6904                	ld	s1,16(a0)
    80000c9a:	00001097          	auipc	ra,0x1
    80000c9e:	fc0080e7          	jalr	-64(ra) # 80001c5a <mycpu>
    80000ca2:	40a48533          	sub	a0,s1,a0
    80000ca6:	00153513          	seqz	a0,a0
}
    80000caa:	60e2                	ld	ra,24(sp)
    80000cac:	6442                	ld	s0,16(sp)
    80000cae:	64a2                	ld	s1,8(sp)
    80000cb0:	6105                	addi	sp,sp,32
    80000cb2:	8082                	ret

0000000080000cb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000cb4:	1101                	addi	sp,sp,-32
    80000cb6:	ec06                	sd	ra,24(sp)
    80000cb8:	e822                	sd	s0,16(sp)
    80000cba:	e426                	sd	s1,8(sp)
    80000cbc:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000cbe:	100024f3          	csrr	s1,sstatus
    80000cc2:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cc6:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000cc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ccc:	00001097          	auipc	ra,0x1
    80000cd0:	f8e080e7          	jalr	-114(ra) # 80001c5a <mycpu>
    80000cd4:	5d3c                	lw	a5,120(a0)
    80000cd6:	cf89                	beqz	a5,80000cf0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000cd8:	00001097          	auipc	ra,0x1
    80000cdc:	f82080e7          	jalr	-126(ra) # 80001c5a <mycpu>
    80000ce0:	5d3c                	lw	a5,120(a0)
    80000ce2:	2785                	addiw	a5,a5,1
    80000ce4:	dd3c                	sw	a5,120(a0)
}
    80000ce6:	60e2                	ld	ra,24(sp)
    80000ce8:	6442                	ld	s0,16(sp)
    80000cea:	64a2                	ld	s1,8(sp)
    80000cec:	6105                	addi	sp,sp,32
    80000cee:	8082                	ret
    mycpu()->intena = old;
    80000cf0:	00001097          	auipc	ra,0x1
    80000cf4:	f6a080e7          	jalr	-150(ra) # 80001c5a <mycpu>
    return (x & SSTATUS_SIE) != 0;
    80000cf8:	8085                	srli	s1,s1,0x1
    80000cfa:	8885                	andi	s1,s1,1
    80000cfc:	dd64                	sw	s1,124(a0)
    80000cfe:	bfe9                	j	80000cd8 <push_off+0x24>

0000000080000d00 <acquire>:
{
    80000d00:	1101                	addi	sp,sp,-32
    80000d02:	ec06                	sd	ra,24(sp)
    80000d04:	e822                	sd	s0,16(sp)
    80000d06:	e426                	sd	s1,8(sp)
    80000d08:	1000                	addi	s0,sp,32
    80000d0a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d0c:	00000097          	auipc	ra,0x0
    80000d10:	fa8080e7          	jalr	-88(ra) # 80000cb4 <push_off>
  if(holding(lk))
    80000d14:	8526                	mv	a0,s1
    80000d16:	00000097          	auipc	ra,0x0
    80000d1a:	f70080e7          	jalr	-144(ra) # 80000c86 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d1e:	4705                	li	a4,1
  if(holding(lk))
    80000d20:	e115                	bnez	a0,80000d44 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d22:	87ba                	mv	a5,a4
    80000d24:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d28:	2781                	sext.w	a5,a5
    80000d2a:	ffe5                	bnez	a5,80000d22 <acquire+0x22>
  __sync_synchronize();
    80000d2c:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000d30:	00001097          	auipc	ra,0x1
    80000d34:	f2a080e7          	jalr	-214(ra) # 80001c5a <mycpu>
    80000d38:	e888                	sd	a0,16(s1)
}
    80000d3a:	60e2                	ld	ra,24(sp)
    80000d3c:	6442                	ld	s0,16(sp)
    80000d3e:	64a2                	ld	s1,8(sp)
    80000d40:	6105                	addi	sp,sp,32
    80000d42:	8082                	ret
    panic("acquire");
    80000d44:	00007517          	auipc	a0,0x7
    80000d48:	34c50513          	addi	a0,a0,844 # 80008090 <__func__.1+0x88>
    80000d4c:	00000097          	auipc	ra,0x0
    80000d50:	814080e7          	jalr	-2028(ra) # 80000560 <panic>

0000000080000d54 <pop_off>:

void
pop_off(void)
{
    80000d54:	1141                	addi	sp,sp,-16
    80000d56:	e406                	sd	ra,8(sp)
    80000d58:	e022                	sd	s0,0(sp)
    80000d5a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d5c:	00001097          	auipc	ra,0x1
    80000d60:	efe080e7          	jalr	-258(ra) # 80001c5a <mycpu>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000d64:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80000d68:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d6a:	e78d                	bnez	a5,80000d94 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d6c:	5d3c                	lw	a5,120(a0)
    80000d6e:	02f05b63          	blez	a5,80000da4 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d72:	37fd                	addiw	a5,a5,-1
    80000d74:	0007871b          	sext.w	a4,a5
    80000d78:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d7a:	eb09                	bnez	a4,80000d8c <pop_off+0x38>
    80000d7c:	5d7c                	lw	a5,124(a0)
    80000d7e:	c799                	beqz	a5,80000d8c <pop_off+0x38>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000d80:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d84:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000d88:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret
    panic("pop_off - interruptible");
    80000d94:	00007517          	auipc	a0,0x7
    80000d98:	30450513          	addi	a0,a0,772 # 80008098 <__func__.1+0x90>
    80000d9c:	fffff097          	auipc	ra,0xfffff
    80000da0:	7c4080e7          	jalr	1988(ra) # 80000560 <panic>
    panic("pop_off");
    80000da4:	00007517          	auipc	a0,0x7
    80000da8:	30c50513          	addi	a0,a0,780 # 800080b0 <__func__.1+0xa8>
    80000dac:	fffff097          	auipc	ra,0xfffff
    80000db0:	7b4080e7          	jalr	1972(ra) # 80000560 <panic>

0000000080000db4 <release>:
{
    80000db4:	1101                	addi	sp,sp,-32
    80000db6:	ec06                	sd	ra,24(sp)
    80000db8:	e822                	sd	s0,16(sp)
    80000dba:	e426                	sd	s1,8(sp)
    80000dbc:	1000                	addi	s0,sp,32
    80000dbe:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000dc0:	00000097          	auipc	ra,0x0
    80000dc4:	ec6080e7          	jalr	-314(ra) # 80000c86 <holding>
    80000dc8:	c115                	beqz	a0,80000dec <release+0x38>
  lk->cpu = 0;
    80000dca:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000dce:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000dd2:	0310000f          	fence	rw,w
    80000dd6:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000dda:	00000097          	auipc	ra,0x0
    80000dde:	f7a080e7          	jalr	-134(ra) # 80000d54 <pop_off>
}
    80000de2:	60e2                	ld	ra,24(sp)
    80000de4:	6442                	ld	s0,16(sp)
    80000de6:	64a2                	ld	s1,8(sp)
    80000de8:	6105                	addi	sp,sp,32
    80000dea:	8082                	ret
    panic("release");
    80000dec:	00007517          	auipc	a0,0x7
    80000df0:	2cc50513          	addi	a0,a0,716 # 800080b8 <__func__.1+0xb0>
    80000df4:	fffff097          	auipc	ra,0xfffff
    80000df8:	76c080e7          	jalr	1900(ra) # 80000560 <panic>

0000000080000dfc <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000dfc:	1141                	addi	sp,sp,-16
    80000dfe:	e422                	sd	s0,8(sp)
    80000e00:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e02:	ca19                	beqz	a2,80000e18 <memset+0x1c>
    80000e04:	87aa                	mv	a5,a0
    80000e06:	1602                	slli	a2,a2,0x20
    80000e08:	9201                	srli	a2,a2,0x20
    80000e0a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e0e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e12:	0785                	addi	a5,a5,1
    80000e14:	fee79de3          	bne	a5,a4,80000e0e <memset+0x12>
  }
  return dst;
}
    80000e18:	6422                	ld	s0,8(sp)
    80000e1a:	0141                	addi	sp,sp,16
    80000e1c:	8082                	ret

0000000080000e1e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e1e:	1141                	addi	sp,sp,-16
    80000e20:	e422                	sd	s0,8(sp)
    80000e22:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e24:	ca05                	beqz	a2,80000e54 <memcmp+0x36>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	0685                	addi	a3,a3,1
    80000e30:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e32:	00054783          	lbu	a5,0(a0)
    80000e36:	0005c703          	lbu	a4,0(a1)
    80000e3a:	00e79863          	bne	a5,a4,80000e4a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e3e:	0505                	addi	a0,a0,1
    80000e40:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e42:	fed518e3          	bne	a0,a3,80000e32 <memcmp+0x14>
  }

  return 0;
    80000e46:	4501                	li	a0,0
    80000e48:	a019                	j	80000e4e <memcmp+0x30>
      return *s1 - *s2;
    80000e4a:	40e7853b          	subw	a0,a5,a4
}
    80000e4e:	6422                	ld	s0,8(sp)
    80000e50:	0141                	addi	sp,sp,16
    80000e52:	8082                	ret
  return 0;
    80000e54:	4501                	li	a0,0
    80000e56:	bfe5                	j	80000e4e <memcmp+0x30>

0000000080000e58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e58:	1141                	addi	sp,sp,-16
    80000e5a:	e422                	sd	s0,8(sp)
    80000e5c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000e5e:	c205                	beqz	a2,80000e7e <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e60:	02a5e263          	bltu	a1,a0,80000e84 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e64:	1602                	slli	a2,a2,0x20
    80000e66:	9201                	srli	a2,a2,0x20
    80000e68:	00c587b3          	add	a5,a1,a2
{
    80000e6c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e6e:	0585                	addi	a1,a1,1
    80000e70:	0705                	addi	a4,a4,1
    80000e72:	fff5c683          	lbu	a3,-1(a1)
    80000e76:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e7a:	feb79ae3          	bne	a5,a1,80000e6e <memmove+0x16>

  return dst;
}
    80000e7e:	6422                	ld	s0,8(sp)
    80000e80:	0141                	addi	sp,sp,16
    80000e82:	8082                	ret
  if(s < d && s + n > d){
    80000e84:	02061693          	slli	a3,a2,0x20
    80000e88:	9281                	srli	a3,a3,0x20
    80000e8a:	00d58733          	add	a4,a1,a3
    80000e8e:	fce57be3          	bgeu	a0,a4,80000e64 <memmove+0xc>
    d += n;
    80000e92:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e94:	fff6079b          	addiw	a5,a2,-1
    80000e98:	1782                	slli	a5,a5,0x20
    80000e9a:	9381                	srli	a5,a5,0x20
    80000e9c:	fff7c793          	not	a5,a5
    80000ea0:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000ea2:	177d                	addi	a4,a4,-1
    80000ea4:	16fd                	addi	a3,a3,-1
    80000ea6:	00074603          	lbu	a2,0(a4)
    80000eaa:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000eae:	fef71ae3          	bne	a4,a5,80000ea2 <memmove+0x4a>
    80000eb2:	b7f1                	j	80000e7e <memmove+0x26>

0000000080000eb4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000eb4:	1141                	addi	sp,sp,-16
    80000eb6:	e406                	sd	ra,8(sp)
    80000eb8:	e022                	sd	s0,0(sp)
    80000eba:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000ebc:	00000097          	auipc	ra,0x0
    80000ec0:	f9c080e7          	jalr	-100(ra) # 80000e58 <memmove>
}
    80000ec4:	60a2                	ld	ra,8(sp)
    80000ec6:	6402                	ld	s0,0(sp)
    80000ec8:	0141                	addi	sp,sp,16
    80000eca:	8082                	ret

0000000080000ecc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000ecc:	1141                	addi	sp,sp,-16
    80000ece:	e422                	sd	s0,8(sp)
    80000ed0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ed2:	ce11                	beqz	a2,80000eee <strncmp+0x22>
    80000ed4:	00054783          	lbu	a5,0(a0)
    80000ed8:	cf89                	beqz	a5,80000ef2 <strncmp+0x26>
    80000eda:	0005c703          	lbu	a4,0(a1)
    80000ede:	00f71a63          	bne	a4,a5,80000ef2 <strncmp+0x26>
    n--, p++, q++;
    80000ee2:	367d                	addiw	a2,a2,-1
    80000ee4:	0505                	addi	a0,a0,1
    80000ee6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ee8:	f675                	bnez	a2,80000ed4 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000eea:	4501                	li	a0,0
    80000eec:	a801                	j	80000efc <strncmp+0x30>
    80000eee:	4501                	li	a0,0
    80000ef0:	a031                	j	80000efc <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000ef2:	00054503          	lbu	a0,0(a0)
    80000ef6:	0005c783          	lbu	a5,0(a1)
    80000efa:	9d1d                	subw	a0,a0,a5
}
    80000efc:	6422                	ld	s0,8(sp)
    80000efe:	0141                	addi	sp,sp,16
    80000f00:	8082                	ret

0000000080000f02 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f02:	1141                	addi	sp,sp,-16
    80000f04:	e422                	sd	s0,8(sp)
    80000f06:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f08:	87aa                	mv	a5,a0
    80000f0a:	86b2                	mv	a3,a2
    80000f0c:	367d                	addiw	a2,a2,-1
    80000f0e:	02d05563          	blez	a3,80000f38 <strncpy+0x36>
    80000f12:	0785                	addi	a5,a5,1
    80000f14:	0005c703          	lbu	a4,0(a1)
    80000f18:	fee78fa3          	sb	a4,-1(a5)
    80000f1c:	0585                	addi	a1,a1,1
    80000f1e:	f775                	bnez	a4,80000f0a <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f20:	873e                	mv	a4,a5
    80000f22:	9fb5                	addw	a5,a5,a3
    80000f24:	37fd                	addiw	a5,a5,-1
    80000f26:	00c05963          	blez	a2,80000f38 <strncpy+0x36>
    *s++ = 0;
    80000f2a:	0705                	addi	a4,a4,1
    80000f2c:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000f30:	40e786bb          	subw	a3,a5,a4
    80000f34:	fed04be3          	bgtz	a3,80000f2a <strncpy+0x28>
  return os;
}
    80000f38:	6422                	ld	s0,8(sp)
    80000f3a:	0141                	addi	sp,sp,16
    80000f3c:	8082                	ret

0000000080000f3e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f3e:	1141                	addi	sp,sp,-16
    80000f40:	e422                	sd	s0,8(sp)
    80000f42:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f44:	02c05363          	blez	a2,80000f6a <safestrcpy+0x2c>
    80000f48:	fff6069b          	addiw	a3,a2,-1
    80000f4c:	1682                	slli	a3,a3,0x20
    80000f4e:	9281                	srli	a3,a3,0x20
    80000f50:	96ae                	add	a3,a3,a1
    80000f52:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f54:	00d58963          	beq	a1,a3,80000f66 <safestrcpy+0x28>
    80000f58:	0585                	addi	a1,a1,1
    80000f5a:	0785                	addi	a5,a5,1
    80000f5c:	fff5c703          	lbu	a4,-1(a1)
    80000f60:	fee78fa3          	sb	a4,-1(a5)
    80000f64:	fb65                	bnez	a4,80000f54 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f66:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f6a:	6422                	ld	s0,8(sp)
    80000f6c:	0141                	addi	sp,sp,16
    80000f6e:	8082                	ret

0000000080000f70 <strlen>:

int
strlen(const char *s)
{
    80000f70:	1141                	addi	sp,sp,-16
    80000f72:	e422                	sd	s0,8(sp)
    80000f74:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f76:	00054783          	lbu	a5,0(a0)
    80000f7a:	cf91                	beqz	a5,80000f96 <strlen+0x26>
    80000f7c:	0505                	addi	a0,a0,1
    80000f7e:	87aa                	mv	a5,a0
    80000f80:	86be                	mv	a3,a5
    80000f82:	0785                	addi	a5,a5,1
    80000f84:	fff7c703          	lbu	a4,-1(a5)
    80000f88:	ff65                	bnez	a4,80000f80 <strlen+0x10>
    80000f8a:	40a6853b          	subw	a0,a3,a0
    80000f8e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000f90:	6422                	ld	s0,8(sp)
    80000f92:	0141                	addi	sp,sp,16
    80000f94:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f96:	4501                	li	a0,0
    80000f98:	bfe5                	j	80000f90 <strlen+0x20>

0000000080000f9a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f9a:	1141                	addi	sp,sp,-16
    80000f9c:	e406                	sd	ra,8(sp)
    80000f9e:	e022                	sd	s0,0(sp)
    80000fa0:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000fa2:	00001097          	auipc	ra,0x1
    80000fa6:	ca8080e7          	jalr	-856(ra) # 80001c4a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000faa:	0000a717          	auipc	a4,0xa
    80000fae:	55e70713          	addi	a4,a4,1374 # 8000b508 <started>
  if(cpuid() == 0){
    80000fb2:	c139                	beqz	a0,80000ff8 <main+0x5e>
    while(started == 0)
    80000fb4:	431c                	lw	a5,0(a4)
    80000fb6:	2781                	sext.w	a5,a5
    80000fb8:	dff5                	beqz	a5,80000fb4 <main+0x1a>
      ;
    __sync_synchronize();
    80000fba:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000fbe:	00001097          	auipc	ra,0x1
    80000fc2:	c8c080e7          	jalr	-884(ra) # 80001c4a <cpuid>
    80000fc6:	85aa                	mv	a1,a0
    80000fc8:	00007517          	auipc	a0,0x7
    80000fcc:	11050513          	addi	a0,a0,272 # 800080d8 <__func__.1+0xd0>
    80000fd0:	fffff097          	auipc	ra,0xfffff
    80000fd4:	5ec080e7          	jalr	1516(ra) # 800005bc <printf>
    kvminithart();    // turn on paging
    80000fd8:	00000097          	auipc	ra,0x0
    80000fdc:	0d8080e7          	jalr	216(ra) # 800010b0 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fe0:	00002097          	auipc	ra,0x2
    80000fe4:	b20080e7          	jalr	-1248(ra) # 80002b00 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000fe8:	00005097          	auipc	ra,0x5
    80000fec:	2bc080e7          	jalr	700(ra) # 800062a4 <plicinithart>
  }

  scheduler();        
    80000ff0:	00001097          	auipc	ra,0x1
    80000ff4:	316080e7          	jalr	790(ra) # 80002306 <scheduler>
    consoleinit();
    80000ff8:	fffff097          	auipc	ra,0xfffff
    80000ffc:	478080e7          	jalr	1144(ra) # 80000470 <consoleinit>
    printfinit();
    80001000:	fffff097          	auipc	ra,0xfffff
    80001004:	7c4080e7          	jalr	1988(ra) # 800007c4 <printfinit>
    printf("\n");
    80001008:	00007517          	auipc	a0,0x7
    8000100c:	01850513          	addi	a0,a0,24 # 80008020 <__func__.1+0x18>
    80001010:	fffff097          	auipc	ra,0xfffff
    80001014:	5ac080e7          	jalr	1452(ra) # 800005bc <printf>
    printf("xv6 kernel is booting\n");
    80001018:	00007517          	auipc	a0,0x7
    8000101c:	0a850513          	addi	a0,a0,168 # 800080c0 <__func__.1+0xb8>
    80001020:	fffff097          	auipc	ra,0xfffff
    80001024:	59c080e7          	jalr	1436(ra) # 800005bc <printf>
    printf("\n");
    80001028:	00007517          	auipc	a0,0x7
    8000102c:	ff850513          	addi	a0,a0,-8 # 80008020 <__func__.1+0x18>
    80001030:	fffff097          	auipc	ra,0xfffff
    80001034:	58c080e7          	jalr	1420(ra) # 800005bc <printf>
    kinit();         // physical page allocator
    80001038:	00000097          	auipc	ra,0x0
    8000103c:	b40080e7          	jalr	-1216(ra) # 80000b78 <kinit>
    kvminit();       // create kernel page table
    80001040:	00000097          	auipc	ra,0x0
    80001044:	326080e7          	jalr	806(ra) # 80001366 <kvminit>
    kvminithart();   // turn on paging
    80001048:	00000097          	auipc	ra,0x0
    8000104c:	068080e7          	jalr	104(ra) # 800010b0 <kvminithart>
    procinit();      // process table
    80001050:	00001097          	auipc	ra,0x1
    80001054:	aa4080e7          	jalr	-1372(ra) # 80001af4 <procinit>
    trapinit();      // trap vectors
    80001058:	00002097          	auipc	ra,0x2
    8000105c:	a80080e7          	jalr	-1408(ra) # 80002ad8 <trapinit>
    trapinithart();  // install kernel trap vector
    80001060:	00002097          	auipc	ra,0x2
    80001064:	aa0080e7          	jalr	-1376(ra) # 80002b00 <trapinithart>
    plicinit();      // set up interrupt controller
    80001068:	00005097          	auipc	ra,0x5
    8000106c:	222080e7          	jalr	546(ra) # 8000628a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001070:	00005097          	auipc	ra,0x5
    80001074:	234080e7          	jalr	564(ra) # 800062a4 <plicinithart>
    binit();         // buffer cache
    80001078:	00002097          	auipc	ra,0x2
    8000107c:	2f8080e7          	jalr	760(ra) # 80003370 <binit>
    iinit();         // inode table
    80001080:	00003097          	auipc	ra,0x3
    80001084:	9ae080e7          	jalr	-1618(ra) # 80003a2e <iinit>
    fileinit();      // file table
    80001088:	00004097          	auipc	ra,0x4
    8000108c:	95e080e7          	jalr	-1698(ra) # 800049e6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001090:	00005097          	auipc	ra,0x5
    80001094:	31c080e7          	jalr	796(ra) # 800063ac <virtio_disk_init>
    userinit();      // first user process
    80001098:	00001097          	auipc	ra,0x1
    8000109c:	eb6080e7          	jalr	-330(ra) # 80001f4e <userinit>
    __sync_synchronize();
    800010a0:	0330000f          	fence	rw,rw
    started = 1;
    800010a4:	4785                	li	a5,1
    800010a6:	0000a717          	auipc	a4,0xa
    800010aa:	46f72123          	sw	a5,1122(a4) # 8000b508 <started>
    800010ae:	b789                	j	80000ff0 <main+0x56>

00000000800010b0 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800010b0:	1141                	addi	sp,sp,-16
    800010b2:	e422                	sd	s0,8(sp)
    800010b4:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
    // the zero, zero means flush all TLB entries.
    asm volatile("sfence.vma zero, zero");
    800010b6:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800010ba:	0000a797          	auipc	a5,0xa
    800010be:	4567b783          	ld	a5,1110(a5) # 8000b510 <kernel_pagetable>
    800010c2:	83b1                	srli	a5,a5,0xc
    800010c4:	577d                	li	a4,-1
    800010c6:	177e                	slli	a4,a4,0x3f
    800010c8:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    800010ca:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma zero, zero");
    800010ce:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800010d2:	6422                	ld	s0,8(sp)
    800010d4:	0141                	addi	sp,sp,16
    800010d6:	8082                	ret

00000000800010d8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010d8:	7139                	addi	sp,sp,-64
    800010da:	fc06                	sd	ra,56(sp)
    800010dc:	f822                	sd	s0,48(sp)
    800010de:	f426                	sd	s1,40(sp)
    800010e0:	f04a                	sd	s2,32(sp)
    800010e2:	ec4e                	sd	s3,24(sp)
    800010e4:	e852                	sd	s4,16(sp)
    800010e6:	e456                	sd	s5,8(sp)
    800010e8:	e05a                	sd	s6,0(sp)
    800010ea:	0080                	addi	s0,sp,64
    800010ec:	84aa                	mv	s1,a0
    800010ee:	89ae                	mv	s3,a1
    800010f0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800010f2:	57fd                	li	a5,-1
    800010f4:	83e9                	srli	a5,a5,0x1a
    800010f6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800010f8:	4b31                	li	s6,12
  if(va >= MAXVA)
    800010fa:	04b7f263          	bgeu	a5,a1,8000113e <walk+0x66>
    panic("walk");
    800010fe:	00007517          	auipc	a0,0x7
    80001102:	ff250513          	addi	a0,a0,-14 # 800080f0 <__func__.1+0xe8>
    80001106:	fffff097          	auipc	ra,0xfffff
    8000110a:	45a080e7          	jalr	1114(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000110e:	060a8663          	beqz	s5,8000117a <walk+0xa2>
    80001112:	00000097          	auipc	ra,0x0
    80001116:	ab2080e7          	jalr	-1358(ra) # 80000bc4 <kalloc>
    8000111a:	84aa                	mv	s1,a0
    8000111c:	c529                	beqz	a0,80001166 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000111e:	6605                	lui	a2,0x1
    80001120:	4581                	li	a1,0
    80001122:	00000097          	auipc	ra,0x0
    80001126:	cda080e7          	jalr	-806(ra) # 80000dfc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000112a:	00c4d793          	srli	a5,s1,0xc
    8000112e:	07aa                	slli	a5,a5,0xa
    80001130:	0017e793          	ori	a5,a5,1
    80001134:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001138:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffda657>
    8000113a:	036a0063          	beq	s4,s6,8000115a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000113e:	0149d933          	srl	s2,s3,s4
    80001142:	1ff97913          	andi	s2,s2,511
    80001146:	090e                	slli	s2,s2,0x3
    80001148:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000114a:	00093483          	ld	s1,0(s2)
    8000114e:	0014f793          	andi	a5,s1,1
    80001152:	dfd5                	beqz	a5,8000110e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001154:	80a9                	srli	s1,s1,0xa
    80001156:	04b2                	slli	s1,s1,0xc
    80001158:	b7c5                	j	80001138 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000115a:	00c9d513          	srli	a0,s3,0xc
    8000115e:	1ff57513          	andi	a0,a0,511
    80001162:	050e                	slli	a0,a0,0x3
    80001164:	9526                	add	a0,a0,s1
}
    80001166:	70e2                	ld	ra,56(sp)
    80001168:	7442                	ld	s0,48(sp)
    8000116a:	74a2                	ld	s1,40(sp)
    8000116c:	7902                	ld	s2,32(sp)
    8000116e:	69e2                	ld	s3,24(sp)
    80001170:	6a42                	ld	s4,16(sp)
    80001172:	6aa2                	ld	s5,8(sp)
    80001174:	6b02                	ld	s6,0(sp)
    80001176:	6121                	addi	sp,sp,64
    80001178:	8082                	ret
        return 0;
    8000117a:	4501                	li	a0,0
    8000117c:	b7ed                	j	80001166 <walk+0x8e>

000000008000117e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000117e:	57fd                	li	a5,-1
    80001180:	83e9                	srli	a5,a5,0x1a
    80001182:	00b7f463          	bgeu	a5,a1,8000118a <walkaddr+0xc>
    return 0;
    80001186:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001188:	8082                	ret
{
    8000118a:	1141                	addi	sp,sp,-16
    8000118c:	e406                	sd	ra,8(sp)
    8000118e:	e022                	sd	s0,0(sp)
    80001190:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001192:	4601                	li	a2,0
    80001194:	00000097          	auipc	ra,0x0
    80001198:	f44080e7          	jalr	-188(ra) # 800010d8 <walk>
  if(pte == 0)
    8000119c:	c105                	beqz	a0,800011bc <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000119e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011a0:	0117f693          	andi	a3,a5,17
    800011a4:	4745                	li	a4,17
    return 0;
    800011a6:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011a8:	00e68663          	beq	a3,a4,800011b4 <walkaddr+0x36>
}
    800011ac:	60a2                	ld	ra,8(sp)
    800011ae:	6402                	ld	s0,0(sp)
    800011b0:	0141                	addi	sp,sp,16
    800011b2:	8082                	ret
  pa = PTE2PA(*pte);
    800011b4:	83a9                	srli	a5,a5,0xa
    800011b6:	00c79513          	slli	a0,a5,0xc
  return pa;
    800011ba:	bfcd                	j	800011ac <walkaddr+0x2e>
    return 0;
    800011bc:	4501                	li	a0,0
    800011be:	b7fd                	j	800011ac <walkaddr+0x2e>

00000000800011c0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011c0:	715d                	addi	sp,sp,-80
    800011c2:	e486                	sd	ra,72(sp)
    800011c4:	e0a2                	sd	s0,64(sp)
    800011c6:	fc26                	sd	s1,56(sp)
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800011d6:	c639                	beqz	a2,80001224 <mappages+0x64>
    800011d8:	8aaa                	mv	s5,a0
    800011da:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800011dc:	777d                	lui	a4,0xfffff
    800011de:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011e2:	fff58993          	addi	s3,a1,-1
    800011e6:	99b2                	add	s3,s3,a2
    800011e8:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011ec:	893e                	mv	s2,a5
    800011ee:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011f2:	6b85                	lui	s7,0x1
    800011f4:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800011f8:	4605                	li	a2,1
    800011fa:	85ca                	mv	a1,s2
    800011fc:	8556                	mv	a0,s5
    800011fe:	00000097          	auipc	ra,0x0
    80001202:	eda080e7          	jalr	-294(ra) # 800010d8 <walk>
    80001206:	cd1d                	beqz	a0,80001244 <mappages+0x84>
    if(*pte & PTE_V)
    80001208:	611c                	ld	a5,0(a0)
    8000120a:	8b85                	andi	a5,a5,1
    8000120c:	e785                	bnez	a5,80001234 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000120e:	80b1                	srli	s1,s1,0xc
    80001210:	04aa                	slli	s1,s1,0xa
    80001212:	0164e4b3          	or	s1,s1,s6
    80001216:	0014e493          	ori	s1,s1,1
    8000121a:	e104                	sd	s1,0(a0)
    if(a == last)
    8000121c:	05390063          	beq	s2,s3,8000125c <mappages+0x9c>
    a += PGSIZE;
    80001220:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001222:	bfc9                	j	800011f4 <mappages+0x34>
    panic("mappages: size");
    80001224:	00007517          	auipc	a0,0x7
    80001228:	ed450513          	addi	a0,a0,-300 # 800080f8 <__func__.1+0xf0>
    8000122c:	fffff097          	auipc	ra,0xfffff
    80001230:	334080e7          	jalr	820(ra) # 80000560 <panic>
      panic("mappages: remap");
    80001234:	00007517          	auipc	a0,0x7
    80001238:	ed450513          	addi	a0,a0,-300 # 80008108 <__func__.1+0x100>
    8000123c:	fffff097          	auipc	ra,0xfffff
    80001240:	324080e7          	jalr	804(ra) # 80000560 <panic>
      return -1;
    80001244:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001246:	60a6                	ld	ra,72(sp)
    80001248:	6406                	ld	s0,64(sp)
    8000124a:	74e2                	ld	s1,56(sp)
    8000124c:	7942                	ld	s2,48(sp)
    8000124e:	79a2                	ld	s3,40(sp)
    80001250:	7a02                	ld	s4,32(sp)
    80001252:	6ae2                	ld	s5,24(sp)
    80001254:	6b42                	ld	s6,16(sp)
    80001256:	6ba2                	ld	s7,8(sp)
    80001258:	6161                	addi	sp,sp,80
    8000125a:	8082                	ret
  return 0;
    8000125c:	4501                	li	a0,0
    8000125e:	b7e5                	j	80001246 <mappages+0x86>

0000000080001260 <kvmmap>:
{
    80001260:	1141                	addi	sp,sp,-16
    80001262:	e406                	sd	ra,8(sp)
    80001264:	e022                	sd	s0,0(sp)
    80001266:	0800                	addi	s0,sp,16
    80001268:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000126a:	86b2                	mv	a3,a2
    8000126c:	863e                	mv	a2,a5
    8000126e:	00000097          	auipc	ra,0x0
    80001272:	f52080e7          	jalr	-174(ra) # 800011c0 <mappages>
    80001276:	e509                	bnez	a0,80001280 <kvmmap+0x20>
}
    80001278:	60a2                	ld	ra,8(sp)
    8000127a:	6402                	ld	s0,0(sp)
    8000127c:	0141                	addi	sp,sp,16
    8000127e:	8082                	ret
    panic("kvmmap");
    80001280:	00007517          	auipc	a0,0x7
    80001284:	e9850513          	addi	a0,a0,-360 # 80008118 <__func__.1+0x110>
    80001288:	fffff097          	auipc	ra,0xfffff
    8000128c:	2d8080e7          	jalr	728(ra) # 80000560 <panic>

0000000080001290 <kvmmake>:
{
    80001290:	1101                	addi	sp,sp,-32
    80001292:	ec06                	sd	ra,24(sp)
    80001294:	e822                	sd	s0,16(sp)
    80001296:	e426                	sd	s1,8(sp)
    80001298:	e04a                	sd	s2,0(sp)
    8000129a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	928080e7          	jalr	-1752(ra) # 80000bc4 <kalloc>
    800012a4:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012a6:	6605                	lui	a2,0x1
    800012a8:	4581                	li	a1,0
    800012aa:	00000097          	auipc	ra,0x0
    800012ae:	b52080e7          	jalr	-1198(ra) # 80000dfc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012b2:	4719                	li	a4,6
    800012b4:	6685                	lui	a3,0x1
    800012b6:	10000637          	lui	a2,0x10000
    800012ba:	100005b7          	lui	a1,0x10000
    800012be:	8526                	mv	a0,s1
    800012c0:	00000097          	auipc	ra,0x0
    800012c4:	fa0080e7          	jalr	-96(ra) # 80001260 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012c8:	4719                	li	a4,6
    800012ca:	6685                	lui	a3,0x1
    800012cc:	10001637          	lui	a2,0x10001
    800012d0:	100015b7          	lui	a1,0x10001
    800012d4:	8526                	mv	a0,s1
    800012d6:	00000097          	auipc	ra,0x0
    800012da:	f8a080e7          	jalr	-118(ra) # 80001260 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012de:	4719                	li	a4,6
    800012e0:	004006b7          	lui	a3,0x400
    800012e4:	0c000637          	lui	a2,0xc000
    800012e8:	0c0005b7          	lui	a1,0xc000
    800012ec:	8526                	mv	a0,s1
    800012ee:	00000097          	auipc	ra,0x0
    800012f2:	f72080e7          	jalr	-142(ra) # 80001260 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012f6:	00007917          	auipc	s2,0x7
    800012fa:	d0a90913          	addi	s2,s2,-758 # 80008000 <etext>
    800012fe:	4729                	li	a4,10
    80001300:	80007697          	auipc	a3,0x80007
    80001304:	d0068693          	addi	a3,a3,-768 # 8000 <_entry-0x7fff8000>
    80001308:	4605                	li	a2,1
    8000130a:	067e                	slli	a2,a2,0x1f
    8000130c:	85b2                	mv	a1,a2
    8000130e:	8526                	mv	a0,s1
    80001310:	00000097          	auipc	ra,0x0
    80001314:	f50080e7          	jalr	-176(ra) # 80001260 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001318:	46c5                	li	a3,17
    8000131a:	06ee                	slli	a3,a3,0x1b
    8000131c:	4719                	li	a4,6
    8000131e:	412686b3          	sub	a3,a3,s2
    80001322:	864a                	mv	a2,s2
    80001324:	85ca                	mv	a1,s2
    80001326:	8526                	mv	a0,s1
    80001328:	00000097          	auipc	ra,0x0
    8000132c:	f38080e7          	jalr	-200(ra) # 80001260 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001330:	4729                	li	a4,10
    80001332:	6685                	lui	a3,0x1
    80001334:	00006617          	auipc	a2,0x6
    80001338:	ccc60613          	addi	a2,a2,-820 # 80007000 <_trampoline>
    8000133c:	040005b7          	lui	a1,0x4000
    80001340:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001342:	05b2                	slli	a1,a1,0xc
    80001344:	8526                	mv	a0,s1
    80001346:	00000097          	auipc	ra,0x0
    8000134a:	f1a080e7          	jalr	-230(ra) # 80001260 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000134e:	8526                	mv	a0,s1
    80001350:	00000097          	auipc	ra,0x0
    80001354:	700080e7          	jalr	1792(ra) # 80001a50 <proc_mapstacks>
}
    80001358:	8526                	mv	a0,s1
    8000135a:	60e2                	ld	ra,24(sp)
    8000135c:	6442                	ld	s0,16(sp)
    8000135e:	64a2                	ld	s1,8(sp)
    80001360:	6902                	ld	s2,0(sp)
    80001362:	6105                	addi	sp,sp,32
    80001364:	8082                	ret

0000000080001366 <kvminit>:
{
    80001366:	1141                	addi	sp,sp,-16
    80001368:	e406                	sd	ra,8(sp)
    8000136a:	e022                	sd	s0,0(sp)
    8000136c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000136e:	00000097          	auipc	ra,0x0
    80001372:	f22080e7          	jalr	-222(ra) # 80001290 <kvmmake>
    80001376:	0000a797          	auipc	a5,0xa
    8000137a:	18a7bd23          	sd	a0,410(a5) # 8000b510 <kernel_pagetable>
}
    8000137e:	60a2                	ld	ra,8(sp)
    80001380:	6402                	ld	s0,0(sp)
    80001382:	0141                	addi	sp,sp,16
    80001384:	8082                	ret

0000000080001386 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001386:	715d                	addi	sp,sp,-80
    80001388:	e486                	sd	ra,72(sp)
    8000138a:	e0a2                	sd	s0,64(sp)
    8000138c:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000138e:	03459793          	slli	a5,a1,0x34
    80001392:	e39d                	bnez	a5,800013b8 <uvmunmap+0x32>
    80001394:	f84a                	sd	s2,48(sp)
    80001396:	f44e                	sd	s3,40(sp)
    80001398:	f052                	sd	s4,32(sp)
    8000139a:	ec56                	sd	s5,24(sp)
    8000139c:	e85a                	sd	s6,16(sp)
    8000139e:	e45e                	sd	s7,8(sp)
    800013a0:	8a2a                	mv	s4,a0
    800013a2:	892e                	mv	s2,a1
    800013a4:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013a6:	0632                	slli	a2,a2,0xc
    800013a8:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800013ac:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013ae:	6b05                	lui	s6,0x1
    800013b0:	0935fb63          	bgeu	a1,s3,80001446 <uvmunmap+0xc0>
    800013b4:	fc26                	sd	s1,56(sp)
    800013b6:	a8a9                	j	80001410 <uvmunmap+0x8a>
    800013b8:	fc26                	sd	s1,56(sp)
    800013ba:	f84a                	sd	s2,48(sp)
    800013bc:	f44e                	sd	s3,40(sp)
    800013be:	f052                	sd	s4,32(sp)
    800013c0:	ec56                	sd	s5,24(sp)
    800013c2:	e85a                	sd	s6,16(sp)
    800013c4:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800013c6:	00007517          	auipc	a0,0x7
    800013ca:	d5a50513          	addi	a0,a0,-678 # 80008120 <__func__.1+0x118>
    800013ce:	fffff097          	auipc	ra,0xfffff
    800013d2:	192080e7          	jalr	402(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    800013d6:	00007517          	auipc	a0,0x7
    800013da:	d6250513          	addi	a0,a0,-670 # 80008138 <__func__.1+0x130>
    800013de:	fffff097          	auipc	ra,0xfffff
    800013e2:	182080e7          	jalr	386(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    800013e6:	00007517          	auipc	a0,0x7
    800013ea:	d6250513          	addi	a0,a0,-670 # 80008148 <__func__.1+0x140>
    800013ee:	fffff097          	auipc	ra,0xfffff
    800013f2:	172080e7          	jalr	370(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    800013f6:	00007517          	auipc	a0,0x7
    800013fa:	d6a50513          	addi	a0,a0,-662 # 80008160 <__func__.1+0x158>
    800013fe:	fffff097          	auipc	ra,0xfffff
    80001402:	162080e7          	jalr	354(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001406:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000140a:	995a                	add	s2,s2,s6
    8000140c:	03397c63          	bgeu	s2,s3,80001444 <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001410:	4601                	li	a2,0
    80001412:	85ca                	mv	a1,s2
    80001414:	8552                	mv	a0,s4
    80001416:	00000097          	auipc	ra,0x0
    8000141a:	cc2080e7          	jalr	-830(ra) # 800010d8 <walk>
    8000141e:	84aa                	mv	s1,a0
    80001420:	d95d                	beqz	a0,800013d6 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001422:	6108                	ld	a0,0(a0)
    80001424:	00157793          	andi	a5,a0,1
    80001428:	dfdd                	beqz	a5,800013e6 <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000142a:	3ff57793          	andi	a5,a0,1023
    8000142e:	fd7784e3          	beq	a5,s7,800013f6 <uvmunmap+0x70>
    if(do_free){
    80001432:	fc0a8ae3          	beqz	s5,80001406 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    80001436:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001438:	0532                	slli	a0,a0,0xc
    8000143a:	fffff097          	auipc	ra,0xfffff
    8000143e:	622080e7          	jalr	1570(ra) # 80000a5c <kfree>
    80001442:	b7d1                	j	80001406 <uvmunmap+0x80>
    80001444:	74e2                	ld	s1,56(sp)
    80001446:	7942                	ld	s2,48(sp)
    80001448:	79a2                	ld	s3,40(sp)
    8000144a:	7a02                	ld	s4,32(sp)
    8000144c:	6ae2                	ld	s5,24(sp)
    8000144e:	6b42                	ld	s6,16(sp)
    80001450:	6ba2                	ld	s7,8(sp)
  }
}
    80001452:	60a6                	ld	ra,72(sp)
    80001454:	6406                	ld	s0,64(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret

000000008000145a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000145a:	1101                	addi	sp,sp,-32
    8000145c:	ec06                	sd	ra,24(sp)
    8000145e:	e822                	sd	s0,16(sp)
    80001460:	e426                	sd	s1,8(sp)
    80001462:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001464:	fffff097          	auipc	ra,0xfffff
    80001468:	760080e7          	jalr	1888(ra) # 80000bc4 <kalloc>
    8000146c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000146e:	c519                	beqz	a0,8000147c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001470:	6605                	lui	a2,0x1
    80001472:	4581                	li	a1,0
    80001474:	00000097          	auipc	ra,0x0
    80001478:	988080e7          	jalr	-1656(ra) # 80000dfc <memset>
  return pagetable;
}
    8000147c:	8526                	mv	a0,s1
    8000147e:	60e2                	ld	ra,24(sp)
    80001480:	6442                	ld	s0,16(sp)
    80001482:	64a2                	ld	s1,8(sp)
    80001484:	6105                	addi	sp,sp,32
    80001486:	8082                	ret

0000000080001488 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001488:	7179                	addi	sp,sp,-48
    8000148a:	f406                	sd	ra,40(sp)
    8000148c:	f022                	sd	s0,32(sp)
    8000148e:	ec26                	sd	s1,24(sp)
    80001490:	e84a                	sd	s2,16(sp)
    80001492:	e44e                	sd	s3,8(sp)
    80001494:	e052                	sd	s4,0(sp)
    80001496:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001498:	6785                	lui	a5,0x1
    8000149a:	04f67863          	bgeu	a2,a5,800014ea <uvmfirst+0x62>
    8000149e:	8a2a                	mv	s4,a0
    800014a0:	89ae                	mv	s3,a1
    800014a2:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800014a4:	fffff097          	auipc	ra,0xfffff
    800014a8:	720080e7          	jalr	1824(ra) # 80000bc4 <kalloc>
    800014ac:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014ae:	6605                	lui	a2,0x1
    800014b0:	4581                	li	a1,0
    800014b2:	00000097          	auipc	ra,0x0
    800014b6:	94a080e7          	jalr	-1718(ra) # 80000dfc <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014ba:	4779                	li	a4,30
    800014bc:	86ca                	mv	a3,s2
    800014be:	6605                	lui	a2,0x1
    800014c0:	4581                	li	a1,0
    800014c2:	8552                	mv	a0,s4
    800014c4:	00000097          	auipc	ra,0x0
    800014c8:	cfc080e7          	jalr	-772(ra) # 800011c0 <mappages>
  memmove(mem, src, sz);
    800014cc:	8626                	mv	a2,s1
    800014ce:	85ce                	mv	a1,s3
    800014d0:	854a                	mv	a0,s2
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	986080e7          	jalr	-1658(ra) # 80000e58 <memmove>
}
    800014da:	70a2                	ld	ra,40(sp)
    800014dc:	7402                	ld	s0,32(sp)
    800014de:	64e2                	ld	s1,24(sp)
    800014e0:	6942                	ld	s2,16(sp)
    800014e2:	69a2                	ld	s3,8(sp)
    800014e4:	6a02                	ld	s4,0(sp)
    800014e6:	6145                	addi	sp,sp,48
    800014e8:	8082                	ret
    panic("uvmfirst: more than a page");
    800014ea:	00007517          	auipc	a0,0x7
    800014ee:	c8e50513          	addi	a0,a0,-882 # 80008178 <__func__.1+0x170>
    800014f2:	fffff097          	auipc	ra,0xfffff
    800014f6:	06e080e7          	jalr	110(ra) # 80000560 <panic>

00000000800014fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800014fa:	1101                	addi	sp,sp,-32
    800014fc:	ec06                	sd	ra,24(sp)
    800014fe:	e822                	sd	s0,16(sp)
    80001500:	e426                	sd	s1,8(sp)
    80001502:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001504:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001506:	00b67d63          	bgeu	a2,a1,80001520 <uvmdealloc+0x26>
    8000150a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000150c:	6785                	lui	a5,0x1
    8000150e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001510:	00f60733          	add	a4,a2,a5
    80001514:	76fd                	lui	a3,0xfffff
    80001516:	8f75                	and	a4,a4,a3
    80001518:	97ae                	add	a5,a5,a1
    8000151a:	8ff5                	and	a5,a5,a3
    8000151c:	00f76863          	bltu	a4,a5,8000152c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001520:	8526                	mv	a0,s1
    80001522:	60e2                	ld	ra,24(sp)
    80001524:	6442                	ld	s0,16(sp)
    80001526:	64a2                	ld	s1,8(sp)
    80001528:	6105                	addi	sp,sp,32
    8000152a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000152c:	8f99                	sub	a5,a5,a4
    8000152e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001530:	4685                	li	a3,1
    80001532:	0007861b          	sext.w	a2,a5
    80001536:	85ba                	mv	a1,a4
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	e4e080e7          	jalr	-434(ra) # 80001386 <uvmunmap>
    80001540:	b7c5                	j	80001520 <uvmdealloc+0x26>

0000000080001542 <uvmalloc>:
  if(newsz < oldsz)
    80001542:	0ab66b63          	bltu	a2,a1,800015f8 <uvmalloc+0xb6>
{
    80001546:	7139                	addi	sp,sp,-64
    80001548:	fc06                	sd	ra,56(sp)
    8000154a:	f822                	sd	s0,48(sp)
    8000154c:	ec4e                	sd	s3,24(sp)
    8000154e:	e852                	sd	s4,16(sp)
    80001550:	e456                	sd	s5,8(sp)
    80001552:	0080                	addi	s0,sp,64
    80001554:	8aaa                	mv	s5,a0
    80001556:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001558:	6785                	lui	a5,0x1
    8000155a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000155c:	95be                	add	a1,a1,a5
    8000155e:	77fd                	lui	a5,0xfffff
    80001560:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001564:	08c9fc63          	bgeu	s3,a2,800015fc <uvmalloc+0xba>
    80001568:	f426                	sd	s1,40(sp)
    8000156a:	f04a                	sd	s2,32(sp)
    8000156c:	e05a                	sd	s6,0(sp)
    8000156e:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001570:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001574:	fffff097          	auipc	ra,0xfffff
    80001578:	650080e7          	jalr	1616(ra) # 80000bc4 <kalloc>
    8000157c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000157e:	c915                	beqz	a0,800015b2 <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    80001580:	6605                	lui	a2,0x1
    80001582:	4581                	li	a1,0
    80001584:	00000097          	auipc	ra,0x0
    80001588:	878080e7          	jalr	-1928(ra) # 80000dfc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000158c:	875a                	mv	a4,s6
    8000158e:	86a6                	mv	a3,s1
    80001590:	6605                	lui	a2,0x1
    80001592:	85ca                	mv	a1,s2
    80001594:	8556                	mv	a0,s5
    80001596:	00000097          	auipc	ra,0x0
    8000159a:	c2a080e7          	jalr	-982(ra) # 800011c0 <mappages>
    8000159e:	ed05                	bnez	a0,800015d6 <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015a0:	6785                	lui	a5,0x1
    800015a2:	993e                	add	s2,s2,a5
    800015a4:	fd4968e3          	bltu	s2,s4,80001574 <uvmalloc+0x32>
  return newsz;
    800015a8:	8552                	mv	a0,s4
    800015aa:	74a2                	ld	s1,40(sp)
    800015ac:	7902                	ld	s2,32(sp)
    800015ae:	6b02                	ld	s6,0(sp)
    800015b0:	a821                	j	800015c8 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800015b2:	864e                	mv	a2,s3
    800015b4:	85ca                	mv	a1,s2
    800015b6:	8556                	mv	a0,s5
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	f42080e7          	jalr	-190(ra) # 800014fa <uvmdealloc>
      return 0;
    800015c0:	4501                	li	a0,0
    800015c2:	74a2                	ld	s1,40(sp)
    800015c4:	7902                	ld	s2,32(sp)
    800015c6:	6b02                	ld	s6,0(sp)
}
    800015c8:	70e2                	ld	ra,56(sp)
    800015ca:	7442                	ld	s0,48(sp)
    800015cc:	69e2                	ld	s3,24(sp)
    800015ce:	6a42                	ld	s4,16(sp)
    800015d0:	6aa2                	ld	s5,8(sp)
    800015d2:	6121                	addi	sp,sp,64
    800015d4:	8082                	ret
      kfree(mem);
    800015d6:	8526                	mv	a0,s1
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	484080e7          	jalr	1156(ra) # 80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015e0:	864e                	mv	a2,s3
    800015e2:	85ca                	mv	a1,s2
    800015e4:	8556                	mv	a0,s5
    800015e6:	00000097          	auipc	ra,0x0
    800015ea:	f14080e7          	jalr	-236(ra) # 800014fa <uvmdealloc>
      return 0;
    800015ee:	4501                	li	a0,0
    800015f0:	74a2                	ld	s1,40(sp)
    800015f2:	7902                	ld	s2,32(sp)
    800015f4:	6b02                	ld	s6,0(sp)
    800015f6:	bfc9                	j	800015c8 <uvmalloc+0x86>
    return oldsz;
    800015f8:	852e                	mv	a0,a1
}
    800015fa:	8082                	ret
  return newsz;
    800015fc:	8532                	mv	a0,a2
    800015fe:	b7e9                	j	800015c8 <uvmalloc+0x86>

0000000080001600 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001600:	7179                	addi	sp,sp,-48
    80001602:	f406                	sd	ra,40(sp)
    80001604:	f022                	sd	s0,32(sp)
    80001606:	ec26                	sd	s1,24(sp)
    80001608:	e84a                	sd	s2,16(sp)
    8000160a:	e44e                	sd	s3,8(sp)
    8000160c:	e052                	sd	s4,0(sp)
    8000160e:	1800                	addi	s0,sp,48
    80001610:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001612:	84aa                	mv	s1,a0
    80001614:	6905                	lui	s2,0x1
    80001616:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001618:	4985                	li	s3,1
    8000161a:	a829                	j	80001634 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000161c:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000161e:	00c79513          	slli	a0,a5,0xc
    80001622:	00000097          	auipc	ra,0x0
    80001626:	fde080e7          	jalr	-34(ra) # 80001600 <freewalk>
      pagetable[i] = 0;
    8000162a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000162e:	04a1                	addi	s1,s1,8
    80001630:	03248163          	beq	s1,s2,80001652 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001634:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001636:	00f7f713          	andi	a4,a5,15
    8000163a:	ff3701e3          	beq	a4,s3,8000161c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000163e:	8b85                	andi	a5,a5,1
    80001640:	d7fd                	beqz	a5,8000162e <freewalk+0x2e>
      panic("freewalk: leaf");
    80001642:	00007517          	auipc	a0,0x7
    80001646:	b5650513          	addi	a0,a0,-1194 # 80008198 <__func__.1+0x190>
    8000164a:	fffff097          	auipc	ra,0xfffff
    8000164e:	f16080e7          	jalr	-234(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    80001652:	8552                	mv	a0,s4
    80001654:	fffff097          	auipc	ra,0xfffff
    80001658:	408080e7          	jalr	1032(ra) # 80000a5c <kfree>
}
    8000165c:	70a2                	ld	ra,40(sp)
    8000165e:	7402                	ld	s0,32(sp)
    80001660:	64e2                	ld	s1,24(sp)
    80001662:	6942                	ld	s2,16(sp)
    80001664:	69a2                	ld	s3,8(sp)
    80001666:	6a02                	ld	s4,0(sp)
    80001668:	6145                	addi	sp,sp,48
    8000166a:	8082                	ret

000000008000166c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000166c:	1101                	addi	sp,sp,-32
    8000166e:	ec06                	sd	ra,24(sp)
    80001670:	e822                	sd	s0,16(sp)
    80001672:	e426                	sd	s1,8(sp)
    80001674:	1000                	addi	s0,sp,32
    80001676:	84aa                	mv	s1,a0
  if(sz > 0)
    80001678:	e999                	bnez	a1,8000168e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000167a:	8526                	mv	a0,s1
    8000167c:	00000097          	auipc	ra,0x0
    80001680:	f84080e7          	jalr	-124(ra) # 80001600 <freewalk>
}
    80001684:	60e2                	ld	ra,24(sp)
    80001686:	6442                	ld	s0,16(sp)
    80001688:	64a2                	ld	s1,8(sp)
    8000168a:	6105                	addi	sp,sp,32
    8000168c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000168e:	6785                	lui	a5,0x1
    80001690:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001692:	95be                	add	a1,a1,a5
    80001694:	4685                	li	a3,1
    80001696:	00c5d613          	srli	a2,a1,0xc
    8000169a:	4581                	li	a1,0
    8000169c:	00000097          	auipc	ra,0x0
    800016a0:	cea080e7          	jalr	-790(ra) # 80001386 <uvmunmap>
    800016a4:	bfd9                	j	8000167a <uvmfree+0xe>

00000000800016a6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016a6:	c679                	beqz	a2,80001774 <uvmcopy+0xce>
{
    800016a8:	715d                	addi	sp,sp,-80
    800016aa:	e486                	sd	ra,72(sp)
    800016ac:	e0a2                	sd	s0,64(sp)
    800016ae:	fc26                	sd	s1,56(sp)
    800016b0:	f84a                	sd	s2,48(sp)
    800016b2:	f44e                	sd	s3,40(sp)
    800016b4:	f052                	sd	s4,32(sp)
    800016b6:	ec56                	sd	s5,24(sp)
    800016b8:	e85a                	sd	s6,16(sp)
    800016ba:	e45e                	sd	s7,8(sp)
    800016bc:	0880                	addi	s0,sp,80
    800016be:	8b2a                	mv	s6,a0
    800016c0:	8aae                	mv	s5,a1
    800016c2:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016c4:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800016c6:	4601                	li	a2,0
    800016c8:	85ce                	mv	a1,s3
    800016ca:	855a                	mv	a0,s6
    800016cc:	00000097          	auipc	ra,0x0
    800016d0:	a0c080e7          	jalr	-1524(ra) # 800010d8 <walk>
    800016d4:	c531                	beqz	a0,80001720 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016d6:	6118                	ld	a4,0(a0)
    800016d8:	00177793          	andi	a5,a4,1
    800016dc:	cbb1                	beqz	a5,80001730 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016de:	00a75593          	srli	a1,a4,0xa
    800016e2:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016e6:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800016ea:	fffff097          	auipc	ra,0xfffff
    800016ee:	4da080e7          	jalr	1242(ra) # 80000bc4 <kalloc>
    800016f2:	892a                	mv	s2,a0
    800016f4:	c939                	beqz	a0,8000174a <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016f6:	6605                	lui	a2,0x1
    800016f8:	85de                	mv	a1,s7
    800016fa:	fffff097          	auipc	ra,0xfffff
    800016fe:	75e080e7          	jalr	1886(ra) # 80000e58 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001702:	8726                	mv	a4,s1
    80001704:	86ca                	mv	a3,s2
    80001706:	6605                	lui	a2,0x1
    80001708:	85ce                	mv	a1,s3
    8000170a:	8556                	mv	a0,s5
    8000170c:	00000097          	auipc	ra,0x0
    80001710:	ab4080e7          	jalr	-1356(ra) # 800011c0 <mappages>
    80001714:	e515                	bnez	a0,80001740 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001716:	6785                	lui	a5,0x1
    80001718:	99be                	add	s3,s3,a5
    8000171a:	fb49e6e3          	bltu	s3,s4,800016c6 <uvmcopy+0x20>
    8000171e:	a081                	j	8000175e <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001720:	00007517          	auipc	a0,0x7
    80001724:	a8850513          	addi	a0,a0,-1400 # 800081a8 <__func__.1+0x1a0>
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	e38080e7          	jalr	-456(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001730:	00007517          	auipc	a0,0x7
    80001734:	a9850513          	addi	a0,a0,-1384 # 800081c8 <__func__.1+0x1c0>
    80001738:	fffff097          	auipc	ra,0xfffff
    8000173c:	e28080e7          	jalr	-472(ra) # 80000560 <panic>
      kfree(mem);
    80001740:	854a                	mv	a0,s2
    80001742:	fffff097          	auipc	ra,0xfffff
    80001746:	31a080e7          	jalr	794(ra) # 80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000174a:	4685                	li	a3,1
    8000174c:	00c9d613          	srli	a2,s3,0xc
    80001750:	4581                	li	a1,0
    80001752:	8556                	mv	a0,s5
    80001754:	00000097          	auipc	ra,0x0
    80001758:	c32080e7          	jalr	-974(ra) # 80001386 <uvmunmap>
  return -1;
    8000175c:	557d                	li	a0,-1
}
    8000175e:	60a6                	ld	ra,72(sp)
    80001760:	6406                	ld	s0,64(sp)
    80001762:	74e2                	ld	s1,56(sp)
    80001764:	7942                	ld	s2,48(sp)
    80001766:	79a2                	ld	s3,40(sp)
    80001768:	7a02                	ld	s4,32(sp)
    8000176a:	6ae2                	ld	s5,24(sp)
    8000176c:	6b42                	ld	s6,16(sp)
    8000176e:	6ba2                	ld	s7,8(sp)
    80001770:	6161                	addi	sp,sp,80
    80001772:	8082                	ret
  return 0;
    80001774:	4501                	li	a0,0
}
    80001776:	8082                	ret

0000000080001778 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001778:	1141                	addi	sp,sp,-16
    8000177a:	e406                	sd	ra,8(sp)
    8000177c:	e022                	sd	s0,0(sp)
    8000177e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001780:	4601                	li	a2,0
    80001782:	00000097          	auipc	ra,0x0
    80001786:	956080e7          	jalr	-1706(ra) # 800010d8 <walk>
  if(pte == 0)
    8000178a:	c901                	beqz	a0,8000179a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000178c:	611c                	ld	a5,0(a0)
    8000178e:	9bbd                	andi	a5,a5,-17
    80001790:	e11c                	sd	a5,0(a0)
}
    80001792:	60a2                	ld	ra,8(sp)
    80001794:	6402                	ld	s0,0(sp)
    80001796:	0141                	addi	sp,sp,16
    80001798:	8082                	ret
    panic("uvmclear");
    8000179a:	00007517          	auipc	a0,0x7
    8000179e:	a4e50513          	addi	a0,a0,-1458 # 800081e8 <__func__.1+0x1e0>
    800017a2:	fffff097          	auipc	ra,0xfffff
    800017a6:	dbe080e7          	jalr	-578(ra) # 80000560 <panic>

00000000800017aa <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017aa:	c6bd                	beqz	a3,80001818 <copyout+0x6e>
{
    800017ac:	715d                	addi	sp,sp,-80
    800017ae:	e486                	sd	ra,72(sp)
    800017b0:	e0a2                	sd	s0,64(sp)
    800017b2:	fc26                	sd	s1,56(sp)
    800017b4:	f84a                	sd	s2,48(sp)
    800017b6:	f44e                	sd	s3,40(sp)
    800017b8:	f052                	sd	s4,32(sp)
    800017ba:	ec56                	sd	s5,24(sp)
    800017bc:	e85a                	sd	s6,16(sp)
    800017be:	e45e                	sd	s7,8(sp)
    800017c0:	e062                	sd	s8,0(sp)
    800017c2:	0880                	addi	s0,sp,80
    800017c4:	8b2a                	mv	s6,a0
    800017c6:	8c2e                	mv	s8,a1
    800017c8:	8a32                	mv	s4,a2
    800017ca:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800017cc:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800017ce:	6a85                	lui	s5,0x1
    800017d0:	a015                	j	800017f4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017d2:	9562                	add	a0,a0,s8
    800017d4:	0004861b          	sext.w	a2,s1
    800017d8:	85d2                	mv	a1,s4
    800017da:	41250533          	sub	a0,a0,s2
    800017de:	fffff097          	auipc	ra,0xfffff
    800017e2:	67a080e7          	jalr	1658(ra) # 80000e58 <memmove>

    len -= n;
    800017e6:	409989b3          	sub	s3,s3,s1
    src += n;
    800017ea:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800017ec:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017f0:	02098263          	beqz	s3,80001814 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800017f4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017f8:	85ca                	mv	a1,s2
    800017fa:	855a                	mv	a0,s6
    800017fc:	00000097          	auipc	ra,0x0
    80001800:	982080e7          	jalr	-1662(ra) # 8000117e <walkaddr>
    if(pa0 == 0)
    80001804:	cd01                	beqz	a0,8000181c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001806:	418904b3          	sub	s1,s2,s8
    8000180a:	94d6                	add	s1,s1,s5
    if(n > len)
    8000180c:	fc99f3e3          	bgeu	s3,s1,800017d2 <copyout+0x28>
    80001810:	84ce                	mv	s1,s3
    80001812:	b7c1                	j	800017d2 <copyout+0x28>
  }
  return 0;
    80001814:	4501                	li	a0,0
    80001816:	a021                	j	8000181e <copyout+0x74>
    80001818:	4501                	li	a0,0
}
    8000181a:	8082                	ret
      return -1;
    8000181c:	557d                	li	a0,-1
}
    8000181e:	60a6                	ld	ra,72(sp)
    80001820:	6406                	ld	s0,64(sp)
    80001822:	74e2                	ld	s1,56(sp)
    80001824:	7942                	ld	s2,48(sp)
    80001826:	79a2                	ld	s3,40(sp)
    80001828:	7a02                	ld	s4,32(sp)
    8000182a:	6ae2                	ld	s5,24(sp)
    8000182c:	6b42                	ld	s6,16(sp)
    8000182e:	6ba2                	ld	s7,8(sp)
    80001830:	6c02                	ld	s8,0(sp)
    80001832:	6161                	addi	sp,sp,80
    80001834:	8082                	ret

0000000080001836 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001836:	caa5                	beqz	a3,800018a6 <copyin+0x70>
{
    80001838:	715d                	addi	sp,sp,-80
    8000183a:	e486                	sd	ra,72(sp)
    8000183c:	e0a2                	sd	s0,64(sp)
    8000183e:	fc26                	sd	s1,56(sp)
    80001840:	f84a                	sd	s2,48(sp)
    80001842:	f44e                	sd	s3,40(sp)
    80001844:	f052                	sd	s4,32(sp)
    80001846:	ec56                	sd	s5,24(sp)
    80001848:	e85a                	sd	s6,16(sp)
    8000184a:	e45e                	sd	s7,8(sp)
    8000184c:	e062                	sd	s8,0(sp)
    8000184e:	0880                	addi	s0,sp,80
    80001850:	8b2a                	mv	s6,a0
    80001852:	8a2e                	mv	s4,a1
    80001854:	8c32                	mv	s8,a2
    80001856:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001858:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000185a:	6a85                	lui	s5,0x1
    8000185c:	a01d                	j	80001882 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000185e:	018505b3          	add	a1,a0,s8
    80001862:	0004861b          	sext.w	a2,s1
    80001866:	412585b3          	sub	a1,a1,s2
    8000186a:	8552                	mv	a0,s4
    8000186c:	fffff097          	auipc	ra,0xfffff
    80001870:	5ec080e7          	jalr	1516(ra) # 80000e58 <memmove>

    len -= n;
    80001874:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001878:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000187a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000187e:	02098263          	beqz	s3,800018a2 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001882:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001886:	85ca                	mv	a1,s2
    80001888:	855a                	mv	a0,s6
    8000188a:	00000097          	auipc	ra,0x0
    8000188e:	8f4080e7          	jalr	-1804(ra) # 8000117e <walkaddr>
    if(pa0 == 0)
    80001892:	cd01                	beqz	a0,800018aa <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001894:	418904b3          	sub	s1,s2,s8
    80001898:	94d6                	add	s1,s1,s5
    if(n > len)
    8000189a:	fc99f2e3          	bgeu	s3,s1,8000185e <copyin+0x28>
    8000189e:	84ce                	mv	s1,s3
    800018a0:	bf7d                	j	8000185e <copyin+0x28>
  }
  return 0;
    800018a2:	4501                	li	a0,0
    800018a4:	a021                	j	800018ac <copyin+0x76>
    800018a6:	4501                	li	a0,0
}
    800018a8:	8082                	ret
      return -1;
    800018aa:	557d                	li	a0,-1
}
    800018ac:	60a6                	ld	ra,72(sp)
    800018ae:	6406                	ld	s0,64(sp)
    800018b0:	74e2                	ld	s1,56(sp)
    800018b2:	7942                	ld	s2,48(sp)
    800018b4:	79a2                	ld	s3,40(sp)
    800018b6:	7a02                	ld	s4,32(sp)
    800018b8:	6ae2                	ld	s5,24(sp)
    800018ba:	6b42                	ld	s6,16(sp)
    800018bc:	6ba2                	ld	s7,8(sp)
    800018be:	6c02                	ld	s8,0(sp)
    800018c0:	6161                	addi	sp,sp,80
    800018c2:	8082                	ret

00000000800018c4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800018c4:	cacd                	beqz	a3,80001976 <copyinstr+0xb2>
{
    800018c6:	715d                	addi	sp,sp,-80
    800018c8:	e486                	sd	ra,72(sp)
    800018ca:	e0a2                	sd	s0,64(sp)
    800018cc:	fc26                	sd	s1,56(sp)
    800018ce:	f84a                	sd	s2,48(sp)
    800018d0:	f44e                	sd	s3,40(sp)
    800018d2:	f052                	sd	s4,32(sp)
    800018d4:	ec56                	sd	s5,24(sp)
    800018d6:	e85a                	sd	s6,16(sp)
    800018d8:	e45e                	sd	s7,8(sp)
    800018da:	0880                	addi	s0,sp,80
    800018dc:	8a2a                	mv	s4,a0
    800018de:	8b2e                	mv	s6,a1
    800018e0:	8bb2                	mv	s7,a2
    800018e2:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800018e4:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018e6:	6985                	lui	s3,0x1
    800018e8:	a825                	j	80001920 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800018ea:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800018ee:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800018f0:	37fd                	addiw	a5,a5,-1
    800018f2:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800018f6:	60a6                	ld	ra,72(sp)
    800018f8:	6406                	ld	s0,64(sp)
    800018fa:	74e2                	ld	s1,56(sp)
    800018fc:	7942                	ld	s2,48(sp)
    800018fe:	79a2                	ld	s3,40(sp)
    80001900:	7a02                	ld	s4,32(sp)
    80001902:	6ae2                	ld	s5,24(sp)
    80001904:	6b42                	ld	s6,16(sp)
    80001906:	6ba2                	ld	s7,8(sp)
    80001908:	6161                	addi	sp,sp,80
    8000190a:	8082                	ret
    8000190c:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001910:	9742                	add	a4,a4,a6
      --max;
    80001912:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001916:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    8000191a:	04e58663          	beq	a1,a4,80001966 <copyinstr+0xa2>
{
    8000191e:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001920:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001924:	85a6                	mv	a1,s1
    80001926:	8552                	mv	a0,s4
    80001928:	00000097          	auipc	ra,0x0
    8000192c:	856080e7          	jalr	-1962(ra) # 8000117e <walkaddr>
    if(pa0 == 0)
    80001930:	cd0d                	beqz	a0,8000196a <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80001932:	417486b3          	sub	a3,s1,s7
    80001936:	96ce                	add	a3,a3,s3
    if(n > max)
    80001938:	00d97363          	bgeu	s2,a3,8000193e <copyinstr+0x7a>
    8000193c:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    8000193e:	955e                	add	a0,a0,s7
    80001940:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001942:	c695                	beqz	a3,8000196e <copyinstr+0xaa>
    80001944:	87da                	mv	a5,s6
    80001946:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001948:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000194c:	96da                	add	a3,a3,s6
    8000194e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001950:	00f60733          	add	a4,a2,a5
    80001954:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffda660>
    80001958:	db49                	beqz	a4,800018ea <copyinstr+0x26>
        *dst = *p;
    8000195a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000195e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001960:	fed797e3          	bne	a5,a3,8000194e <copyinstr+0x8a>
    80001964:	b765                	j	8000190c <copyinstr+0x48>
    80001966:	4781                	li	a5,0
    80001968:	b761                	j	800018f0 <copyinstr+0x2c>
      return -1;
    8000196a:	557d                	li	a0,-1
    8000196c:	b769                	j	800018f6 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000196e:	6b85                	lui	s7,0x1
    80001970:	9ba6                	add	s7,s7,s1
    80001972:	87da                	mv	a5,s6
    80001974:	b76d                	j	8000191e <copyinstr+0x5a>
  int got_null = 0;
    80001976:	4781                	li	a5,0
  if(got_null){
    80001978:	37fd                	addiw	a5,a5,-1
    8000197a:	0007851b          	sext.w	a0,a5
}
    8000197e:	8082                	ret

0000000080001980 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001980:	715d                	addi	sp,sp,-80
    80001982:	e486                	sd	ra,72(sp)
    80001984:	e0a2                	sd	s0,64(sp)
    80001986:	fc26                	sd	s1,56(sp)
    80001988:	f84a                	sd	s2,48(sp)
    8000198a:	f44e                	sd	s3,40(sp)
    8000198c:	f052                	sd	s4,32(sp)
    8000198e:	ec56                	sd	s5,24(sp)
    80001990:	e85a                	sd	s6,16(sp)
    80001992:	e45e                	sd	s7,8(sp)
    80001994:	e062                	sd	s8,0(sp)
    80001996:	0880                	addi	s0,sp,80
    asm volatile("mv %0, tp" : "=r"(x));
    80001998:	8792                	mv	a5,tp
    int id = r_tp();
    8000199a:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    8000199c:	00012a97          	auipc	s5,0x12
    800019a0:	df4a8a93          	addi	s5,s5,-524 # 80013790 <cpus>
    800019a4:	00779713          	slli	a4,a5,0x7
    800019a8:	00ea86b3          	add	a3,s5,a4
    800019ac:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffda660>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    800019b0:	0721                	addi	a4,a4,8
    800019b2:	9aba                	add	s5,s5,a4
                c->proc = p;
    800019b4:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    800019b6:	0000ac17          	auipc	s8,0xa
    800019ba:	a92c0c13          	addi	s8,s8,-1390 # 8000b448 <sched_pointer>
    800019be:	00000b97          	auipc	s7,0x0
    800019c2:	fc2b8b93          	addi	s7,s7,-62 # 80001980 <rr_scheduler>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    800019c6:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    800019ca:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    800019ce:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    800019d2:	00012497          	auipc	s1,0x12
    800019d6:	1ee48493          	addi	s1,s1,494 # 80013bc0 <proc>
            if (p->state == RUNNABLE)
    800019da:	498d                	li	s3,3
                p->state = RUNNING;
    800019dc:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    800019de:	00018a17          	auipc	s4,0x18
    800019e2:	be2a0a13          	addi	s4,s4,-1054 # 800195c0 <tickslock>
    800019e6:	a81d                	j	80001a1c <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    800019e8:	8526                	mv	a0,s1
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	3ca080e7          	jalr	970(ra) # 80000db4 <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    800019f2:	60a6                	ld	ra,72(sp)
    800019f4:	6406                	ld	s0,64(sp)
    800019f6:	74e2                	ld	s1,56(sp)
    800019f8:	7942                	ld	s2,48(sp)
    800019fa:	79a2                	ld	s3,40(sp)
    800019fc:	7a02                	ld	s4,32(sp)
    800019fe:	6ae2                	ld	s5,24(sp)
    80001a00:	6b42                	ld	s6,16(sp)
    80001a02:	6ba2                	ld	s7,8(sp)
    80001a04:	6c02                	ld	s8,0(sp)
    80001a06:	6161                	addi	sp,sp,80
    80001a08:	8082                	ret
            release(&p->lock);
    80001a0a:	8526                	mv	a0,s1
    80001a0c:	fffff097          	auipc	ra,0xfffff
    80001a10:	3a8080e7          	jalr	936(ra) # 80000db4 <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001a14:	16848493          	addi	s1,s1,360
    80001a18:	fb4487e3          	beq	s1,s4,800019c6 <rr_scheduler+0x46>
            acquire(&p->lock);
    80001a1c:	8526                	mv	a0,s1
    80001a1e:	fffff097          	auipc	ra,0xfffff
    80001a22:	2e2080e7          	jalr	738(ra) # 80000d00 <acquire>
            if (p->state == RUNNABLE)
    80001a26:	4c9c                	lw	a5,24(s1)
    80001a28:	ff3791e3          	bne	a5,s3,80001a0a <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001a2c:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001a30:	00993023          	sd	s1,0(s2)
                swtch(&c->context, &p->context);
    80001a34:	06048593          	addi	a1,s1,96
    80001a38:	8556                	mv	a0,s5
    80001a3a:	00001097          	auipc	ra,0x1
    80001a3e:	034080e7          	jalr	52(ra) # 80002a6e <swtch>
                if (sched_pointer != &rr_scheduler)
    80001a42:	000c3783          	ld	a5,0(s8)
    80001a46:	fb7791e3          	bne	a5,s7,800019e8 <rr_scheduler+0x68>
                c->proc = 0;
    80001a4a:	00093023          	sd	zero,0(s2)
    80001a4e:	bf75                	j	80001a0a <rr_scheduler+0x8a>

0000000080001a50 <proc_mapstacks>:
{
    80001a50:	7139                	addi	sp,sp,-64
    80001a52:	fc06                	sd	ra,56(sp)
    80001a54:	f822                	sd	s0,48(sp)
    80001a56:	f426                	sd	s1,40(sp)
    80001a58:	f04a                	sd	s2,32(sp)
    80001a5a:	ec4e                	sd	s3,24(sp)
    80001a5c:	e852                	sd	s4,16(sp)
    80001a5e:	e456                	sd	s5,8(sp)
    80001a60:	e05a                	sd	s6,0(sp)
    80001a62:	0080                	addi	s0,sp,64
    80001a64:	8a2a                	mv	s4,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001a66:	00012497          	auipc	s1,0x12
    80001a6a:	15a48493          	addi	s1,s1,346 # 80013bc0 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001a6e:	8b26                	mv	s6,s1
    80001a70:	04fa5937          	lui	s2,0x4fa5
    80001a74:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001a78:	0932                	slli	s2,s2,0xc
    80001a7a:	fa590913          	addi	s2,s2,-91
    80001a7e:	0932                	slli	s2,s2,0xc
    80001a80:	fa590913          	addi	s2,s2,-91
    80001a84:	0932                	slli	s2,s2,0xc
    80001a86:	fa590913          	addi	s2,s2,-91
    80001a8a:	040009b7          	lui	s3,0x4000
    80001a8e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a90:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001a92:	00018a97          	auipc	s5,0x18
    80001a96:	b2ea8a93          	addi	s5,s5,-1234 # 800195c0 <tickslock>
        char *pa = kalloc();
    80001a9a:	fffff097          	auipc	ra,0xfffff
    80001a9e:	12a080e7          	jalr	298(ra) # 80000bc4 <kalloc>
    80001aa2:	862a                	mv	a2,a0
        if (pa == 0)
    80001aa4:	c121                	beqz	a0,80001ae4 <proc_mapstacks+0x94>
        uint64 va = KSTACK((int)(p - proc));
    80001aa6:	416485b3          	sub	a1,s1,s6
    80001aaa:	858d                	srai	a1,a1,0x3
    80001aac:	032585b3          	mul	a1,a1,s2
    80001ab0:	2585                	addiw	a1,a1,1
    80001ab2:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001ab6:	4719                	li	a4,6
    80001ab8:	6685                	lui	a3,0x1
    80001aba:	40b985b3          	sub	a1,s3,a1
    80001abe:	8552                	mv	a0,s4
    80001ac0:	fffff097          	auipc	ra,0xfffff
    80001ac4:	7a0080e7          	jalr	1952(ra) # 80001260 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001ac8:	16848493          	addi	s1,s1,360
    80001acc:	fd5497e3          	bne	s1,s5,80001a9a <proc_mapstacks+0x4a>
}
    80001ad0:	70e2                	ld	ra,56(sp)
    80001ad2:	7442                	ld	s0,48(sp)
    80001ad4:	74a2                	ld	s1,40(sp)
    80001ad6:	7902                	ld	s2,32(sp)
    80001ad8:	69e2                	ld	s3,24(sp)
    80001ada:	6a42                	ld	s4,16(sp)
    80001adc:	6aa2                	ld	s5,8(sp)
    80001ade:	6b02                	ld	s6,0(sp)
    80001ae0:	6121                	addi	sp,sp,64
    80001ae2:	8082                	ret
            panic("kalloc");
    80001ae4:	00006517          	auipc	a0,0x6
    80001ae8:	71450513          	addi	a0,a0,1812 # 800081f8 <__func__.1+0x1f0>
    80001aec:	fffff097          	auipc	ra,0xfffff
    80001af0:	a74080e7          	jalr	-1420(ra) # 80000560 <panic>

0000000080001af4 <procinit>:
{
    80001af4:	7139                	addi	sp,sp,-64
    80001af6:	fc06                	sd	ra,56(sp)
    80001af8:	f822                	sd	s0,48(sp)
    80001afa:	f426                	sd	s1,40(sp)
    80001afc:	f04a                	sd	s2,32(sp)
    80001afe:	ec4e                	sd	s3,24(sp)
    80001b00:	e852                	sd	s4,16(sp)
    80001b02:	e456                	sd	s5,8(sp)
    80001b04:	e05a                	sd	s6,0(sp)
    80001b06:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001b08:	00006597          	auipc	a1,0x6
    80001b0c:	6f858593          	addi	a1,a1,1784 # 80008200 <__func__.1+0x1f8>
    80001b10:	00012517          	auipc	a0,0x12
    80001b14:	08050513          	addi	a0,a0,128 # 80013b90 <pid_lock>
    80001b18:	fffff097          	auipc	ra,0xfffff
    80001b1c:	158080e7          	jalr	344(ra) # 80000c70 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001b20:	00006597          	auipc	a1,0x6
    80001b24:	6e858593          	addi	a1,a1,1768 # 80008208 <__func__.1+0x200>
    80001b28:	00012517          	auipc	a0,0x12
    80001b2c:	08050513          	addi	a0,a0,128 # 80013ba8 <wait_lock>
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	140080e7          	jalr	320(ra) # 80000c70 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b38:	00012497          	auipc	s1,0x12
    80001b3c:	08848493          	addi	s1,s1,136 # 80013bc0 <proc>
        initlock(&p->lock, "proc");
    80001b40:	00006b17          	auipc	s6,0x6
    80001b44:	6d8b0b13          	addi	s6,s6,1752 # 80008218 <__func__.1+0x210>
        p->kstack = KSTACK((int)(p - proc));
    80001b48:	8aa6                	mv	s5,s1
    80001b4a:	04fa5937          	lui	s2,0x4fa5
    80001b4e:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001b52:	0932                	slli	s2,s2,0xc
    80001b54:	fa590913          	addi	s2,s2,-91
    80001b58:	0932                	slli	s2,s2,0xc
    80001b5a:	fa590913          	addi	s2,s2,-91
    80001b5e:	0932                	slli	s2,s2,0xc
    80001b60:	fa590913          	addi	s2,s2,-91
    80001b64:	040009b7          	lui	s3,0x4000
    80001b68:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001b6a:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001b6c:	00018a17          	auipc	s4,0x18
    80001b70:	a54a0a13          	addi	s4,s4,-1452 # 800195c0 <tickslock>
        initlock(&p->lock, "proc");
    80001b74:	85da                	mv	a1,s6
    80001b76:	8526                	mv	a0,s1
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	0f8080e7          	jalr	248(ra) # 80000c70 <initlock>
        p->state = UNUSED;
    80001b80:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001b84:	415487b3          	sub	a5,s1,s5
    80001b88:	878d                	srai	a5,a5,0x3
    80001b8a:	032787b3          	mul	a5,a5,s2
    80001b8e:	2785                	addiw	a5,a5,1
    80001b90:	00d7979b          	slliw	a5,a5,0xd
    80001b94:	40f987b3          	sub	a5,s3,a5
    80001b98:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001b9a:	16848493          	addi	s1,s1,360
    80001b9e:	fd449be3          	bne	s1,s4,80001b74 <procinit+0x80>
}
    80001ba2:	70e2                	ld	ra,56(sp)
    80001ba4:	7442                	ld	s0,48(sp)
    80001ba6:	74a2                	ld	s1,40(sp)
    80001ba8:	7902                	ld	s2,32(sp)
    80001baa:	69e2                	ld	s3,24(sp)
    80001bac:	6a42                	ld	s4,16(sp)
    80001bae:	6aa2                	ld	s5,8(sp)
    80001bb0:	6b02                	ld	s6,0(sp)
    80001bb2:	6121                	addi	sp,sp,64
    80001bb4:	8082                	ret

0000000080001bb6 <copy_array>:
{
    80001bb6:	1141                	addi	sp,sp,-16
    80001bb8:	e422                	sd	s0,8(sp)
    80001bba:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001bbc:	00c05c63          	blez	a2,80001bd4 <copy_array+0x1e>
    80001bc0:	87aa                	mv	a5,a0
    80001bc2:	9532                	add	a0,a0,a2
        dst[i] = src[i];
    80001bc4:	0007c703          	lbu	a4,0(a5)
    80001bc8:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001bcc:	0785                	addi	a5,a5,1
    80001bce:	0585                	addi	a1,a1,1
    80001bd0:	fea79ae3          	bne	a5,a0,80001bc4 <copy_array+0xe>
}
    80001bd4:	6422                	ld	s0,8(sp)
    80001bd6:	0141                	addi	sp,sp,16
    80001bd8:	8082                	ret

0000000080001bda <va2pa>:
uint64 va2pa(uint64 va, uint64 pid){
    80001bda:	7139                	addi	sp,sp,-64
    80001bdc:	fc06                	sd	ra,56(sp)
    80001bde:	f822                	sd	s0,48(sp)
    80001be0:	f426                	sd	s1,40(sp)
    80001be2:	f04a                	sd	s2,32(sp)
    80001be4:	ec4e                	sd	s3,24(sp)
    80001be6:	e852                	sd	s4,16(sp)
    80001be8:	e456                	sd	s5,8(sp)
    80001bea:	0080                	addi	s0,sp,64
    80001bec:	8aaa                	mv	s5,a0
    80001bee:	892e                	mv	s2,a1
    uint64 pa = 0;
    80001bf0:	4a01                	li	s4,0
    for (p = proc; p < &proc[NPROC]; p++){
    80001bf2:	00012497          	auipc	s1,0x12
    80001bf6:	fce48493          	addi	s1,s1,-50 # 80013bc0 <proc>
    80001bfa:	00018997          	auipc	s3,0x18
    80001bfe:	9c698993          	addi	s3,s3,-1594 # 800195c0 <tickslock>
    80001c02:	a811                	j	80001c16 <va2pa+0x3c>
        release(&p->lock);
    80001c04:	8526                	mv	a0,s1
    80001c06:	fffff097          	auipc	ra,0xfffff
    80001c0a:	1ae080e7          	jalr	430(ra) # 80000db4 <release>
    for (p = proc; p < &proc[NPROC]; p++){
    80001c0e:	16848493          	addi	s1,s1,360
    80001c12:	03348263          	beq	s1,s3,80001c36 <va2pa+0x5c>
        acquire(&p->lock);
    80001c16:	8526                	mv	a0,s1
    80001c18:	fffff097          	auipc	ra,0xfffff
    80001c1c:	0e8080e7          	jalr	232(ra) # 80000d00 <acquire>
        if (pid == (uint64) p->pid){
    80001c20:	589c                	lw	a5,48(s1)
    80001c22:	ff2791e3          	bne	a5,s2,80001c04 <va2pa+0x2a>
            pa = walkaddr(pt, va);     
    80001c26:	85d6                	mv	a1,s5
    80001c28:	68a8                	ld	a0,80(s1)
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	554080e7          	jalr	1364(ra) # 8000117e <walkaddr>
    80001c32:	8a2a                	mv	s4,a0
    80001c34:	bfc1                	j	80001c04 <va2pa+0x2a>
}
    80001c36:	8552                	mv	a0,s4
    80001c38:	70e2                	ld	ra,56(sp)
    80001c3a:	7442                	ld	s0,48(sp)
    80001c3c:	74a2                	ld	s1,40(sp)
    80001c3e:	7902                	ld	s2,32(sp)
    80001c40:	69e2                	ld	s3,24(sp)
    80001c42:	6a42                	ld	s4,16(sp)
    80001c44:	6aa2                	ld	s5,8(sp)
    80001c46:	6121                	addi	sp,sp,64
    80001c48:	8082                	ret

0000000080001c4a <cpuid>:
{
    80001c4a:	1141                	addi	sp,sp,-16
    80001c4c:	e422                	sd	s0,8(sp)
    80001c4e:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    80001c50:	8512                	mv	a0,tp
}
    80001c52:	2501                	sext.w	a0,a0
    80001c54:	6422                	ld	s0,8(sp)
    80001c56:	0141                	addi	sp,sp,16
    80001c58:	8082                	ret

0000000080001c5a <mycpu>:
{
    80001c5a:	1141                	addi	sp,sp,-16
    80001c5c:	e422                	sd	s0,8(sp)
    80001c5e:	0800                	addi	s0,sp,16
    80001c60:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001c62:	2781                	sext.w	a5,a5
    80001c64:	079e                	slli	a5,a5,0x7
}
    80001c66:	00012517          	auipc	a0,0x12
    80001c6a:	b2a50513          	addi	a0,a0,-1238 # 80013790 <cpus>
    80001c6e:	953e                	add	a0,a0,a5
    80001c70:	6422                	ld	s0,8(sp)
    80001c72:	0141                	addi	sp,sp,16
    80001c74:	8082                	ret

0000000080001c76 <myproc>:
{
    80001c76:	1101                	addi	sp,sp,-32
    80001c78:	ec06                	sd	ra,24(sp)
    80001c7a:	e822                	sd	s0,16(sp)
    80001c7c:	e426                	sd	s1,8(sp)
    80001c7e:	1000                	addi	s0,sp,32
    push_off();
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	034080e7          	jalr	52(ra) # 80000cb4 <push_off>
    80001c88:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001c8a:	2781                	sext.w	a5,a5
    80001c8c:	079e                	slli	a5,a5,0x7
    80001c8e:	00012717          	auipc	a4,0x12
    80001c92:	b0270713          	addi	a4,a4,-1278 # 80013790 <cpus>
    80001c96:	97ba                	add	a5,a5,a4
    80001c98:	6384                	ld	s1,0(a5)
    pop_off();
    80001c9a:	fffff097          	auipc	ra,0xfffff
    80001c9e:	0ba080e7          	jalr	186(ra) # 80000d54 <pop_off>
}
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	60e2                	ld	ra,24(sp)
    80001ca6:	6442                	ld	s0,16(sp)
    80001ca8:	64a2                	ld	s1,8(sp)
    80001caa:	6105                	addi	sp,sp,32
    80001cac:	8082                	ret

0000000080001cae <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001cae:	1141                	addi	sp,sp,-16
    80001cb0:	e406                	sd	ra,8(sp)
    80001cb2:	e022                	sd	s0,0(sp)
    80001cb4:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001cb6:	00000097          	auipc	ra,0x0
    80001cba:	fc0080e7          	jalr	-64(ra) # 80001c76 <myproc>
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	0f6080e7          	jalr	246(ra) # 80000db4 <release>

    if (first)
    80001cc6:	00009797          	auipc	a5,0x9
    80001cca:	77a7a783          	lw	a5,1914(a5) # 8000b440 <first.1>
    80001cce:	eb89                	bnez	a5,80001ce0 <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001cd0:	00001097          	auipc	ra,0x1
    80001cd4:	e48080e7          	jalr	-440(ra) # 80002b18 <usertrapret>
}
    80001cd8:	60a2                	ld	ra,8(sp)
    80001cda:	6402                	ld	s0,0(sp)
    80001cdc:	0141                	addi	sp,sp,16
    80001cde:	8082                	ret
        first = 0;
    80001ce0:	00009797          	auipc	a5,0x9
    80001ce4:	7607a023          	sw	zero,1888(a5) # 8000b440 <first.1>
        fsinit(ROOTDEV);
    80001ce8:	4505                	li	a0,1
    80001cea:	00002097          	auipc	ra,0x2
    80001cee:	cc4080e7          	jalr	-828(ra) # 800039ae <fsinit>
    80001cf2:	bff9                	j	80001cd0 <forkret+0x22>

0000000080001cf4 <allocpid>:
{
    80001cf4:	1101                	addi	sp,sp,-32
    80001cf6:	ec06                	sd	ra,24(sp)
    80001cf8:	e822                	sd	s0,16(sp)
    80001cfa:	e426                	sd	s1,8(sp)
    80001cfc:	e04a                	sd	s2,0(sp)
    80001cfe:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001d00:	00012917          	auipc	s2,0x12
    80001d04:	e9090913          	addi	s2,s2,-368 # 80013b90 <pid_lock>
    80001d08:	854a                	mv	a0,s2
    80001d0a:	fffff097          	auipc	ra,0xfffff
    80001d0e:	ff6080e7          	jalr	-10(ra) # 80000d00 <acquire>
    pid = nextpid;
    80001d12:	00009797          	auipc	a5,0x9
    80001d16:	73e78793          	addi	a5,a5,1854 # 8000b450 <nextpid>
    80001d1a:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001d1c:	0014871b          	addiw	a4,s1,1
    80001d20:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001d22:	854a                	mv	a0,s2
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	090080e7          	jalr	144(ra) # 80000db4 <release>
}
    80001d2c:	8526                	mv	a0,s1
    80001d2e:	60e2                	ld	ra,24(sp)
    80001d30:	6442                	ld	s0,16(sp)
    80001d32:	64a2                	ld	s1,8(sp)
    80001d34:	6902                	ld	s2,0(sp)
    80001d36:	6105                	addi	sp,sp,32
    80001d38:	8082                	ret

0000000080001d3a <proc_pagetable>:
{
    80001d3a:	1101                	addi	sp,sp,-32
    80001d3c:	ec06                	sd	ra,24(sp)
    80001d3e:	e822                	sd	s0,16(sp)
    80001d40:	e426                	sd	s1,8(sp)
    80001d42:	e04a                	sd	s2,0(sp)
    80001d44:	1000                	addi	s0,sp,32
    80001d46:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	712080e7          	jalr	1810(ra) # 8000145a <uvmcreate>
    80001d50:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001d52:	c121                	beqz	a0,80001d92 <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d54:	4729                	li	a4,10
    80001d56:	00005697          	auipc	a3,0x5
    80001d5a:	2aa68693          	addi	a3,a3,682 # 80007000 <_trampoline>
    80001d5e:	6605                	lui	a2,0x1
    80001d60:	040005b7          	lui	a1,0x4000
    80001d64:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d66:	05b2                	slli	a1,a1,0xc
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	458080e7          	jalr	1112(ra) # 800011c0 <mappages>
    80001d70:	02054863          	bltz	a0,80001da0 <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d74:	4719                	li	a4,6
    80001d76:	05893683          	ld	a3,88(s2)
    80001d7a:	6605                	lui	a2,0x1
    80001d7c:	020005b7          	lui	a1,0x2000
    80001d80:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d82:	05b6                	slli	a1,a1,0xd
    80001d84:	8526                	mv	a0,s1
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	43a080e7          	jalr	1082(ra) # 800011c0 <mappages>
    80001d8e:	02054163          	bltz	a0,80001db0 <proc_pagetable+0x76>
}
    80001d92:	8526                	mv	a0,s1
    80001d94:	60e2                	ld	ra,24(sp)
    80001d96:	6442                	ld	s0,16(sp)
    80001d98:	64a2                	ld	s1,8(sp)
    80001d9a:	6902                	ld	s2,0(sp)
    80001d9c:	6105                	addi	sp,sp,32
    80001d9e:	8082                	ret
        uvmfree(pagetable, 0);
    80001da0:	4581                	li	a1,0
    80001da2:	8526                	mv	a0,s1
    80001da4:	00000097          	auipc	ra,0x0
    80001da8:	8c8080e7          	jalr	-1848(ra) # 8000166c <uvmfree>
        return 0;
    80001dac:	4481                	li	s1,0
    80001dae:	b7d5                	j	80001d92 <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001db0:	4681                	li	a3,0
    80001db2:	4605                	li	a2,1
    80001db4:	040005b7          	lui	a1,0x4000
    80001db8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dba:	05b2                	slli	a1,a1,0xc
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	fffff097          	auipc	ra,0xfffff
    80001dc2:	5c8080e7          	jalr	1480(ra) # 80001386 <uvmunmap>
        uvmfree(pagetable, 0);
    80001dc6:	4581                	li	a1,0
    80001dc8:	8526                	mv	a0,s1
    80001dca:	00000097          	auipc	ra,0x0
    80001dce:	8a2080e7          	jalr	-1886(ra) # 8000166c <uvmfree>
        return 0;
    80001dd2:	4481                	li	s1,0
    80001dd4:	bf7d                	j	80001d92 <proc_pagetable+0x58>

0000000080001dd6 <proc_freepagetable>:
{
    80001dd6:	1101                	addi	sp,sp,-32
    80001dd8:	ec06                	sd	ra,24(sp)
    80001dda:	e822                	sd	s0,16(sp)
    80001ddc:	e426                	sd	s1,8(sp)
    80001dde:	e04a                	sd	s2,0(sp)
    80001de0:	1000                	addi	s0,sp,32
    80001de2:	84aa                	mv	s1,a0
    80001de4:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001de6:	4681                	li	a3,0
    80001de8:	4605                	li	a2,1
    80001dea:	040005b7          	lui	a1,0x4000
    80001dee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001df0:	05b2                	slli	a1,a1,0xc
    80001df2:	fffff097          	auipc	ra,0xfffff
    80001df6:	594080e7          	jalr	1428(ra) # 80001386 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001dfa:	4681                	li	a3,0
    80001dfc:	4605                	li	a2,1
    80001dfe:	020005b7          	lui	a1,0x2000
    80001e02:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e04:	05b6                	slli	a1,a1,0xd
    80001e06:	8526                	mv	a0,s1
    80001e08:	fffff097          	auipc	ra,0xfffff
    80001e0c:	57e080e7          	jalr	1406(ra) # 80001386 <uvmunmap>
    uvmfree(pagetable, sz);
    80001e10:	85ca                	mv	a1,s2
    80001e12:	8526                	mv	a0,s1
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	858080e7          	jalr	-1960(ra) # 8000166c <uvmfree>
}
    80001e1c:	60e2                	ld	ra,24(sp)
    80001e1e:	6442                	ld	s0,16(sp)
    80001e20:	64a2                	ld	s1,8(sp)
    80001e22:	6902                	ld	s2,0(sp)
    80001e24:	6105                	addi	sp,sp,32
    80001e26:	8082                	ret

0000000080001e28 <freeproc>:
{
    80001e28:	1101                	addi	sp,sp,-32
    80001e2a:	ec06                	sd	ra,24(sp)
    80001e2c:	e822                	sd	s0,16(sp)
    80001e2e:	e426                	sd	s1,8(sp)
    80001e30:	1000                	addi	s0,sp,32
    80001e32:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001e34:	6d28                	ld	a0,88(a0)
    80001e36:	c509                	beqz	a0,80001e40 <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	c24080e7          	jalr	-988(ra) # 80000a5c <kfree>
    p->trapframe = 0;
    80001e40:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001e44:	68a8                	ld	a0,80(s1)
    80001e46:	c511                	beqz	a0,80001e52 <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001e48:	64ac                	ld	a1,72(s1)
    80001e4a:	00000097          	auipc	ra,0x0
    80001e4e:	f8c080e7          	jalr	-116(ra) # 80001dd6 <proc_freepagetable>
    p->pagetable = 0;
    80001e52:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001e56:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001e5a:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001e5e:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001e62:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001e66:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001e6a:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001e6e:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001e72:	0004ac23          	sw	zero,24(s1)
}
    80001e76:	60e2                	ld	ra,24(sp)
    80001e78:	6442                	ld	s0,16(sp)
    80001e7a:	64a2                	ld	s1,8(sp)
    80001e7c:	6105                	addi	sp,sp,32
    80001e7e:	8082                	ret

0000000080001e80 <allocproc>:
{
    80001e80:	1101                	addi	sp,sp,-32
    80001e82:	ec06                	sd	ra,24(sp)
    80001e84:	e822                	sd	s0,16(sp)
    80001e86:	e426                	sd	s1,8(sp)
    80001e88:	e04a                	sd	s2,0(sp)
    80001e8a:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001e8c:	00012497          	auipc	s1,0x12
    80001e90:	d3448493          	addi	s1,s1,-716 # 80013bc0 <proc>
    80001e94:	00017917          	auipc	s2,0x17
    80001e98:	72c90913          	addi	s2,s2,1836 # 800195c0 <tickslock>
        acquire(&p->lock);
    80001e9c:	8526                	mv	a0,s1
    80001e9e:	fffff097          	auipc	ra,0xfffff
    80001ea2:	e62080e7          	jalr	-414(ra) # 80000d00 <acquire>
        if (p->state == UNUSED)
    80001ea6:	4c9c                	lw	a5,24(s1)
    80001ea8:	cf81                	beqz	a5,80001ec0 <allocproc+0x40>
            release(&p->lock);
    80001eaa:	8526                	mv	a0,s1
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	f08080e7          	jalr	-248(ra) # 80000db4 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001eb4:	16848493          	addi	s1,s1,360
    80001eb8:	ff2492e3          	bne	s1,s2,80001e9c <allocproc+0x1c>
    return 0;
    80001ebc:	4481                	li	s1,0
    80001ebe:	a889                	j	80001f10 <allocproc+0x90>
    p->pid = allocpid();
    80001ec0:	00000097          	auipc	ra,0x0
    80001ec4:	e34080e7          	jalr	-460(ra) # 80001cf4 <allocpid>
    80001ec8:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001eca:	4785                	li	a5,1
    80001ecc:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001ece:	fffff097          	auipc	ra,0xfffff
    80001ed2:	cf6080e7          	jalr	-778(ra) # 80000bc4 <kalloc>
    80001ed6:	892a                	mv	s2,a0
    80001ed8:	eca8                	sd	a0,88(s1)
    80001eda:	c131                	beqz	a0,80001f1e <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001edc:	8526                	mv	a0,s1
    80001ede:	00000097          	auipc	ra,0x0
    80001ee2:	e5c080e7          	jalr	-420(ra) # 80001d3a <proc_pagetable>
    80001ee6:	892a                	mv	s2,a0
    80001ee8:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001eea:	c531                	beqz	a0,80001f36 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001eec:	07000613          	li	a2,112
    80001ef0:	4581                	li	a1,0
    80001ef2:	06048513          	addi	a0,s1,96
    80001ef6:	fffff097          	auipc	ra,0xfffff
    80001efa:	f06080e7          	jalr	-250(ra) # 80000dfc <memset>
    p->context.ra = (uint64)forkret;
    80001efe:	00000797          	auipc	a5,0x0
    80001f02:	db078793          	addi	a5,a5,-592 # 80001cae <forkret>
    80001f06:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001f08:	60bc                	ld	a5,64(s1)
    80001f0a:	6705                	lui	a4,0x1
    80001f0c:	97ba                	add	a5,a5,a4
    80001f0e:	f4bc                	sd	a5,104(s1)
}
    80001f10:	8526                	mv	a0,s1
    80001f12:	60e2                	ld	ra,24(sp)
    80001f14:	6442                	ld	s0,16(sp)
    80001f16:	64a2                	ld	s1,8(sp)
    80001f18:	6902                	ld	s2,0(sp)
    80001f1a:	6105                	addi	sp,sp,32
    80001f1c:	8082                	ret
        freeproc(p);
    80001f1e:	8526                	mv	a0,s1
    80001f20:	00000097          	auipc	ra,0x0
    80001f24:	f08080e7          	jalr	-248(ra) # 80001e28 <freeproc>
        release(&p->lock);
    80001f28:	8526                	mv	a0,s1
    80001f2a:	fffff097          	auipc	ra,0xfffff
    80001f2e:	e8a080e7          	jalr	-374(ra) # 80000db4 <release>
        return 0;
    80001f32:	84ca                	mv	s1,s2
    80001f34:	bff1                	j	80001f10 <allocproc+0x90>
        freeproc(p);
    80001f36:	8526                	mv	a0,s1
    80001f38:	00000097          	auipc	ra,0x0
    80001f3c:	ef0080e7          	jalr	-272(ra) # 80001e28 <freeproc>
        release(&p->lock);
    80001f40:	8526                	mv	a0,s1
    80001f42:	fffff097          	auipc	ra,0xfffff
    80001f46:	e72080e7          	jalr	-398(ra) # 80000db4 <release>
        return 0;
    80001f4a:	84ca                	mv	s1,s2
    80001f4c:	b7d1                	j	80001f10 <allocproc+0x90>

0000000080001f4e <userinit>:
{
    80001f4e:	1101                	addi	sp,sp,-32
    80001f50:	ec06                	sd	ra,24(sp)
    80001f52:	e822                	sd	s0,16(sp)
    80001f54:	e426                	sd	s1,8(sp)
    80001f56:	1000                	addi	s0,sp,32
    p = allocproc();
    80001f58:	00000097          	auipc	ra,0x0
    80001f5c:	f28080e7          	jalr	-216(ra) # 80001e80 <allocproc>
    80001f60:	84aa                	mv	s1,a0
    initproc = p;
    80001f62:	00009797          	auipc	a5,0x9
    80001f66:	5aa7bb23          	sd	a0,1462(a5) # 8000b518 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f6a:	03400613          	li	a2,52
    80001f6e:	00009597          	auipc	a1,0x9
    80001f72:	4f258593          	addi	a1,a1,1266 # 8000b460 <initcode>
    80001f76:	6928                	ld	a0,80(a0)
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	510080e7          	jalr	1296(ra) # 80001488 <uvmfirst>
    p->sz = PGSIZE;
    80001f80:	6785                	lui	a5,0x1
    80001f82:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80001f84:	6cb8                	ld	a4,88(s1)
    80001f86:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001f8a:	6cb8                	ld	a4,88(s1)
    80001f8c:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f8e:	4641                	li	a2,16
    80001f90:	00006597          	auipc	a1,0x6
    80001f94:	29058593          	addi	a1,a1,656 # 80008220 <__func__.1+0x218>
    80001f98:	15848513          	addi	a0,s1,344
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	fa2080e7          	jalr	-94(ra) # 80000f3e <safestrcpy>
    p->cwd = namei("/");
    80001fa4:	00006517          	auipc	a0,0x6
    80001fa8:	28c50513          	addi	a0,a0,652 # 80008230 <__func__.1+0x228>
    80001fac:	00002097          	auipc	ra,0x2
    80001fb0:	454080e7          	jalr	1108(ra) # 80004400 <namei>
    80001fb4:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80001fb8:	478d                	li	a5,3
    80001fba:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001fbc:	8526                	mv	a0,s1
    80001fbe:	fffff097          	auipc	ra,0xfffff
    80001fc2:	df6080e7          	jalr	-522(ra) # 80000db4 <release>
}
    80001fc6:	60e2                	ld	ra,24(sp)
    80001fc8:	6442                	ld	s0,16(sp)
    80001fca:	64a2                	ld	s1,8(sp)
    80001fcc:	6105                	addi	sp,sp,32
    80001fce:	8082                	ret

0000000080001fd0 <growproc>:
{
    80001fd0:	1101                	addi	sp,sp,-32
    80001fd2:	ec06                	sd	ra,24(sp)
    80001fd4:	e822                	sd	s0,16(sp)
    80001fd6:	e426                	sd	s1,8(sp)
    80001fd8:	e04a                	sd	s2,0(sp)
    80001fda:	1000                	addi	s0,sp,32
    80001fdc:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80001fde:	00000097          	auipc	ra,0x0
    80001fe2:	c98080e7          	jalr	-872(ra) # 80001c76 <myproc>
    80001fe6:	84aa                	mv	s1,a0
    sz = p->sz;
    80001fe8:	652c                	ld	a1,72(a0)
    if (n > 0)
    80001fea:	01204c63          	bgtz	s2,80002002 <growproc+0x32>
    else if (n < 0)
    80001fee:	02094663          	bltz	s2,8000201a <growproc+0x4a>
    p->sz = sz;
    80001ff2:	e4ac                	sd	a1,72(s1)
    return 0;
    80001ff4:	4501                	li	a0,0
}
    80001ff6:	60e2                	ld	ra,24(sp)
    80001ff8:	6442                	ld	s0,16(sp)
    80001ffa:	64a2                	ld	s1,8(sp)
    80001ffc:	6902                	ld	s2,0(sp)
    80001ffe:	6105                	addi	sp,sp,32
    80002000:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80002002:	4691                	li	a3,4
    80002004:	00b90633          	add	a2,s2,a1
    80002008:	6928                	ld	a0,80(a0)
    8000200a:	fffff097          	auipc	ra,0xfffff
    8000200e:	538080e7          	jalr	1336(ra) # 80001542 <uvmalloc>
    80002012:	85aa                	mv	a1,a0
    80002014:	fd79                	bnez	a0,80001ff2 <growproc+0x22>
            return -1;
    80002016:	557d                	li	a0,-1
    80002018:	bff9                	j	80001ff6 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000201a:	00b90633          	add	a2,s2,a1
    8000201e:	6928                	ld	a0,80(a0)
    80002020:	fffff097          	auipc	ra,0xfffff
    80002024:	4da080e7          	jalr	1242(ra) # 800014fa <uvmdealloc>
    80002028:	85aa                	mv	a1,a0
    8000202a:	b7e1                	j	80001ff2 <growproc+0x22>

000000008000202c <ps>:
{
    8000202c:	715d                	addi	sp,sp,-80
    8000202e:	e486                	sd	ra,72(sp)
    80002030:	e0a2                	sd	s0,64(sp)
    80002032:	fc26                	sd	s1,56(sp)
    80002034:	f84a                	sd	s2,48(sp)
    80002036:	f44e                	sd	s3,40(sp)
    80002038:	f052                	sd	s4,32(sp)
    8000203a:	ec56                	sd	s5,24(sp)
    8000203c:	e85a                	sd	s6,16(sp)
    8000203e:	e45e                	sd	s7,8(sp)
    80002040:	e062                	sd	s8,0(sp)
    80002042:	0880                	addi	s0,sp,80
    80002044:	84aa                	mv	s1,a0
    80002046:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    80002048:	00000097          	auipc	ra,0x0
    8000204c:	c2e080e7          	jalr	-978(ra) # 80001c76 <myproc>
        return result;
    80002050:	4901                	li	s2,0
    if (count == 0)
    80002052:	0c0b8663          	beqz	s7,8000211e <ps+0xf2>
    void *result = (void *)myproc()->sz;
    80002056:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    8000205a:	003b951b          	slliw	a0,s7,0x3
    8000205e:	0175053b          	addw	a0,a0,s7
    80002062:	0025151b          	slliw	a0,a0,0x2
    80002066:	2501                	sext.w	a0,a0
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	f68080e7          	jalr	-152(ra) # 80001fd0 <growproc>
    80002070:	12054f63          	bltz	a0,800021ae <ps+0x182>
    struct user_proc loc_result[count];
    80002074:	003b9a13          	slli	s4,s7,0x3
    80002078:	9a5e                	add	s4,s4,s7
    8000207a:	0a0a                	slli	s4,s4,0x2
    8000207c:	00fa0793          	addi	a5,s4,15
    80002080:	8391                	srli	a5,a5,0x4
    80002082:	0792                	slli	a5,a5,0x4
    80002084:	40f10133          	sub	sp,sp,a5
    80002088:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    8000208a:	16800793          	li	a5,360
    8000208e:	02f484b3          	mul	s1,s1,a5
    80002092:	00012797          	auipc	a5,0x12
    80002096:	b2e78793          	addi	a5,a5,-1234 # 80013bc0 <proc>
    8000209a:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    8000209c:	00017797          	auipc	a5,0x17
    800020a0:	52478793          	addi	a5,a5,1316 # 800195c0 <tickslock>
        return result;
    800020a4:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    800020a6:	06f4fc63          	bgeu	s1,a5,8000211e <ps+0xf2>
    acquire(&wait_lock);
    800020aa:	00012517          	auipc	a0,0x12
    800020ae:	afe50513          	addi	a0,a0,-1282 # 80013ba8 <wait_lock>
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	c4e080e7          	jalr	-946(ra) # 80000d00 <acquire>
        if (localCount == count)
    800020ba:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    800020be:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    800020c0:	00017c17          	auipc	s8,0x17
    800020c4:	500c0c13          	addi	s8,s8,1280 # 800195c0 <tickslock>
    800020c8:	a851                	j	8000215c <ps+0x130>
            loc_result[localCount].state = UNUSED;
    800020ca:	00399793          	slli	a5,s3,0x3
    800020ce:	97ce                	add	a5,a5,s3
    800020d0:	078a                	slli	a5,a5,0x2
    800020d2:	97d6                	add	a5,a5,s5
    800020d4:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    800020d8:	8526                	mv	a0,s1
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	cda080e7          	jalr	-806(ra) # 80000db4 <release>
    release(&wait_lock);
    800020e2:	00012517          	auipc	a0,0x12
    800020e6:	ac650513          	addi	a0,a0,-1338 # 80013ba8 <wait_lock>
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	cca080e7          	jalr	-822(ra) # 80000db4 <release>
    if (localCount < count)
    800020f2:	0179f963          	bgeu	s3,s7,80002104 <ps+0xd8>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    800020f6:	00399793          	slli	a5,s3,0x3
    800020fa:	97ce                	add	a5,a5,s3
    800020fc:	078a                	slli	a5,a5,0x2
    800020fe:	97d6                	add	a5,a5,s5
    80002100:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    80002104:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    80002106:	00000097          	auipc	ra,0x0
    8000210a:	b70080e7          	jalr	-1168(ra) # 80001c76 <myproc>
    8000210e:	86d2                	mv	a3,s4
    80002110:	8656                	mv	a2,s5
    80002112:	85da                	mv	a1,s6
    80002114:	6928                	ld	a0,80(a0)
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	694080e7          	jalr	1684(ra) # 800017aa <copyout>
}
    8000211e:	854a                	mv	a0,s2
    80002120:	fb040113          	addi	sp,s0,-80
    80002124:	60a6                	ld	ra,72(sp)
    80002126:	6406                	ld	s0,64(sp)
    80002128:	74e2                	ld	s1,56(sp)
    8000212a:	7942                	ld	s2,48(sp)
    8000212c:	79a2                	ld	s3,40(sp)
    8000212e:	7a02                	ld	s4,32(sp)
    80002130:	6ae2                	ld	s5,24(sp)
    80002132:	6b42                	ld	s6,16(sp)
    80002134:	6ba2                	ld	s7,8(sp)
    80002136:	6c02                	ld	s8,0(sp)
    80002138:	6161                	addi	sp,sp,80
    8000213a:	8082                	ret
        release(&p->lock);
    8000213c:	8526                	mv	a0,s1
    8000213e:	fffff097          	auipc	ra,0xfffff
    80002142:	c76080e7          	jalr	-906(ra) # 80000db4 <release>
        localCount++;
    80002146:	2985                	addiw	s3,s3,1
    80002148:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    8000214c:	16848493          	addi	s1,s1,360
    80002150:	f984f9e3          	bgeu	s1,s8,800020e2 <ps+0xb6>
        if (localCount == count)
    80002154:	02490913          	addi	s2,s2,36
    80002158:	053b8d63          	beq	s7,s3,800021b2 <ps+0x186>
        acquire(&p->lock);
    8000215c:	8526                	mv	a0,s1
    8000215e:	fffff097          	auipc	ra,0xfffff
    80002162:	ba2080e7          	jalr	-1118(ra) # 80000d00 <acquire>
        if (p->state == UNUSED)
    80002166:	4c9c                	lw	a5,24(s1)
    80002168:	d3ad                	beqz	a5,800020ca <ps+0x9e>
        loc_result[localCount].state = p->state;
    8000216a:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    8000216e:	549c                	lw	a5,40(s1)
    80002170:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    80002174:	54dc                	lw	a5,44(s1)
    80002176:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    8000217a:	589c                	lw	a5,48(s1)
    8000217c:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    80002180:	4641                	li	a2,16
    80002182:	85ca                	mv	a1,s2
    80002184:	15848513          	addi	a0,s1,344
    80002188:	00000097          	auipc	ra,0x0
    8000218c:	a2e080e7          	jalr	-1490(ra) # 80001bb6 <copy_array>
        if (p->parent != 0) // init
    80002190:	7c88                	ld	a0,56(s1)
    80002192:	d54d                	beqz	a0,8000213c <ps+0x110>
            acquire(&p->parent->lock);
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	b6c080e7          	jalr	-1172(ra) # 80000d00 <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    8000219c:	7c88                	ld	a0,56(s1)
    8000219e:	591c                	lw	a5,48(a0)
    800021a0:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	c10080e7          	jalr	-1008(ra) # 80000db4 <release>
    800021ac:	bf41                	j	8000213c <ps+0x110>
        return result;
    800021ae:	4901                	li	s2,0
    800021b0:	b7bd                	j	8000211e <ps+0xf2>
    release(&wait_lock);
    800021b2:	00012517          	auipc	a0,0x12
    800021b6:	9f650513          	addi	a0,a0,-1546 # 80013ba8 <wait_lock>
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	bfa080e7          	jalr	-1030(ra) # 80000db4 <release>
    if (localCount < count)
    800021c2:	b789                	j	80002104 <ps+0xd8>

00000000800021c4 <fork>:
{
    800021c4:	7139                	addi	sp,sp,-64
    800021c6:	fc06                	sd	ra,56(sp)
    800021c8:	f822                	sd	s0,48(sp)
    800021ca:	f04a                	sd	s2,32(sp)
    800021cc:	e456                	sd	s5,8(sp)
    800021ce:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    800021d0:	00000097          	auipc	ra,0x0
    800021d4:	aa6080e7          	jalr	-1370(ra) # 80001c76 <myproc>
    800021d8:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    800021da:	00000097          	auipc	ra,0x0
    800021de:	ca6080e7          	jalr	-858(ra) # 80001e80 <allocproc>
    800021e2:	12050063          	beqz	a0,80002302 <fork+0x13e>
    800021e6:	e852                	sd	s4,16(sp)
    800021e8:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    800021ea:	048ab603          	ld	a2,72(s5)
    800021ee:	692c                	ld	a1,80(a0)
    800021f0:	050ab503          	ld	a0,80(s5)
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	4b2080e7          	jalr	1202(ra) # 800016a6 <uvmcopy>
    800021fc:	04054a63          	bltz	a0,80002250 <fork+0x8c>
    80002200:	f426                	sd	s1,40(sp)
    80002202:	ec4e                	sd	s3,24(sp)
    np->sz = p->sz;
    80002204:	048ab783          	ld	a5,72(s5)
    80002208:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    8000220c:	058ab683          	ld	a3,88(s5)
    80002210:	87b6                	mv	a5,a3
    80002212:	058a3703          	ld	a4,88(s4)
    80002216:	12068693          	addi	a3,a3,288
    8000221a:	0007b803          	ld	a6,0(a5)
    8000221e:	6788                	ld	a0,8(a5)
    80002220:	6b8c                	ld	a1,16(a5)
    80002222:	6f90                	ld	a2,24(a5)
    80002224:	01073023          	sd	a6,0(a4)
    80002228:	e708                	sd	a0,8(a4)
    8000222a:	eb0c                	sd	a1,16(a4)
    8000222c:	ef10                	sd	a2,24(a4)
    8000222e:	02078793          	addi	a5,a5,32
    80002232:	02070713          	addi	a4,a4,32
    80002236:	fed792e3          	bne	a5,a3,8000221a <fork+0x56>
    np->trapframe->a0 = 0;
    8000223a:	058a3783          	ld	a5,88(s4)
    8000223e:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    80002242:	0d0a8493          	addi	s1,s5,208
    80002246:	0d0a0913          	addi	s2,s4,208
    8000224a:	150a8993          	addi	s3,s5,336
    8000224e:	a015                	j	80002272 <fork+0xae>
        freeproc(np);
    80002250:	8552                	mv	a0,s4
    80002252:	00000097          	auipc	ra,0x0
    80002256:	bd6080e7          	jalr	-1066(ra) # 80001e28 <freeproc>
        release(&np->lock);
    8000225a:	8552                	mv	a0,s4
    8000225c:	fffff097          	auipc	ra,0xfffff
    80002260:	b58080e7          	jalr	-1192(ra) # 80000db4 <release>
        return -1;
    80002264:	597d                	li	s2,-1
    80002266:	6a42                	ld	s4,16(sp)
    80002268:	a071                	j	800022f4 <fork+0x130>
    for (i = 0; i < NOFILE; i++)
    8000226a:	04a1                	addi	s1,s1,8
    8000226c:	0921                	addi	s2,s2,8
    8000226e:	01348b63          	beq	s1,s3,80002284 <fork+0xc0>
        if (p->ofile[i])
    80002272:	6088                	ld	a0,0(s1)
    80002274:	d97d                	beqz	a0,8000226a <fork+0xa6>
            np->ofile[i] = filedup(p->ofile[i]);
    80002276:	00003097          	auipc	ra,0x3
    8000227a:	802080e7          	jalr	-2046(ra) # 80004a78 <filedup>
    8000227e:	00a93023          	sd	a0,0(s2)
    80002282:	b7e5                	j	8000226a <fork+0xa6>
    np->cwd = idup(p->cwd);
    80002284:	150ab503          	ld	a0,336(s5)
    80002288:	00002097          	auipc	ra,0x2
    8000228c:	96c080e7          	jalr	-1684(ra) # 80003bf4 <idup>
    80002290:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    80002294:	4641                	li	a2,16
    80002296:	158a8593          	addi	a1,s5,344
    8000229a:	158a0513          	addi	a0,s4,344
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	ca0080e7          	jalr	-864(ra) # 80000f3e <safestrcpy>
    pid = np->pid;
    800022a6:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    800022aa:	8552                	mv	a0,s4
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	b08080e7          	jalr	-1272(ra) # 80000db4 <release>
    acquire(&wait_lock);
    800022b4:	00012497          	auipc	s1,0x12
    800022b8:	8f448493          	addi	s1,s1,-1804 # 80013ba8 <wait_lock>
    800022bc:	8526                	mv	a0,s1
    800022be:	fffff097          	auipc	ra,0xfffff
    800022c2:	a42080e7          	jalr	-1470(ra) # 80000d00 <acquire>
    np->parent = p;
    800022c6:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	ae8080e7          	jalr	-1304(ra) # 80000db4 <release>
    acquire(&np->lock);
    800022d4:	8552                	mv	a0,s4
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	a2a080e7          	jalr	-1494(ra) # 80000d00 <acquire>
    np->state = RUNNABLE;
    800022de:	478d                	li	a5,3
    800022e0:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    800022e4:	8552                	mv	a0,s4
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	ace080e7          	jalr	-1330(ra) # 80000db4 <release>
    return pid;
    800022ee:	74a2                	ld	s1,40(sp)
    800022f0:	69e2                	ld	s3,24(sp)
    800022f2:	6a42                	ld	s4,16(sp)
}
    800022f4:	854a                	mv	a0,s2
    800022f6:	70e2                	ld	ra,56(sp)
    800022f8:	7442                	ld	s0,48(sp)
    800022fa:	7902                	ld	s2,32(sp)
    800022fc:	6aa2                	ld	s5,8(sp)
    800022fe:	6121                	addi	sp,sp,64
    80002300:	8082                	ret
        return -1;
    80002302:	597d                	li	s2,-1
    80002304:	bfc5                	j	800022f4 <fork+0x130>

0000000080002306 <scheduler>:
{
    80002306:	1101                	addi	sp,sp,-32
    80002308:	ec06                	sd	ra,24(sp)
    8000230a:	e822                	sd	s0,16(sp)
    8000230c:	e426                	sd	s1,8(sp)
    8000230e:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    80002310:	00009497          	auipc	s1,0x9
    80002314:	13848493          	addi	s1,s1,312 # 8000b448 <sched_pointer>
    80002318:	609c                	ld	a5,0(s1)
    8000231a:	9782                	jalr	a5
    while (1)
    8000231c:	bff5                	j	80002318 <scheduler+0x12>

000000008000231e <sched>:
{
    8000231e:	7179                	addi	sp,sp,-48
    80002320:	f406                	sd	ra,40(sp)
    80002322:	f022                	sd	s0,32(sp)
    80002324:	ec26                	sd	s1,24(sp)
    80002326:	e84a                	sd	s2,16(sp)
    80002328:	e44e                	sd	s3,8(sp)
    8000232a:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    8000232c:	00000097          	auipc	ra,0x0
    80002330:	94a080e7          	jalr	-1718(ra) # 80001c76 <myproc>
    80002334:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	950080e7          	jalr	-1712(ra) # 80000c86 <holding>
    8000233e:	c53d                	beqz	a0,800023ac <sched+0x8e>
    80002340:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    80002342:	2781                	sext.w	a5,a5
    80002344:	079e                	slli	a5,a5,0x7
    80002346:	00011717          	auipc	a4,0x11
    8000234a:	44a70713          	addi	a4,a4,1098 # 80013790 <cpus>
    8000234e:	97ba                	add	a5,a5,a4
    80002350:	5fb8                	lw	a4,120(a5)
    80002352:	4785                	li	a5,1
    80002354:	06f71463          	bne	a4,a5,800023bc <sched+0x9e>
    if (p->state == RUNNING)
    80002358:	4c98                	lw	a4,24(s1)
    8000235a:	4791                	li	a5,4
    8000235c:	06f70863          	beq	a4,a5,800023cc <sched+0xae>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002360:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80002364:	8b89                	andi	a5,a5,2
    if (intr_get())
    80002366:	ebbd                	bnez	a5,800023dc <sched+0xbe>
    asm volatile("mv %0, tp" : "=r"(x));
    80002368:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    8000236a:	00011917          	auipc	s2,0x11
    8000236e:	42690913          	addi	s2,s2,1062 # 80013790 <cpus>
    80002372:	2781                	sext.w	a5,a5
    80002374:	079e                	slli	a5,a5,0x7
    80002376:	97ca                	add	a5,a5,s2
    80002378:	07c7a983          	lw	s3,124(a5)
    8000237c:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    8000237e:	2581                	sext.w	a1,a1
    80002380:	059e                	slli	a1,a1,0x7
    80002382:	05a1                	addi	a1,a1,8
    80002384:	95ca                	add	a1,a1,s2
    80002386:	06048513          	addi	a0,s1,96
    8000238a:	00000097          	auipc	ra,0x0
    8000238e:	6e4080e7          	jalr	1764(ra) # 80002a6e <swtch>
    80002392:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    80002394:	2781                	sext.w	a5,a5
    80002396:	079e                	slli	a5,a5,0x7
    80002398:	993e                	add	s2,s2,a5
    8000239a:	07392e23          	sw	s3,124(s2)
}
    8000239e:	70a2                	ld	ra,40(sp)
    800023a0:	7402                	ld	s0,32(sp)
    800023a2:	64e2                	ld	s1,24(sp)
    800023a4:	6942                	ld	s2,16(sp)
    800023a6:	69a2                	ld	s3,8(sp)
    800023a8:	6145                	addi	sp,sp,48
    800023aa:	8082                	ret
        panic("sched p->lock");
    800023ac:	00006517          	auipc	a0,0x6
    800023b0:	e8c50513          	addi	a0,a0,-372 # 80008238 <__func__.1+0x230>
    800023b4:	ffffe097          	auipc	ra,0xffffe
    800023b8:	1ac080e7          	jalr	428(ra) # 80000560 <panic>
        panic("sched locks");
    800023bc:	00006517          	auipc	a0,0x6
    800023c0:	e8c50513          	addi	a0,a0,-372 # 80008248 <__func__.1+0x240>
    800023c4:	ffffe097          	auipc	ra,0xffffe
    800023c8:	19c080e7          	jalr	412(ra) # 80000560 <panic>
        panic("sched running");
    800023cc:	00006517          	auipc	a0,0x6
    800023d0:	e8c50513          	addi	a0,a0,-372 # 80008258 <__func__.1+0x250>
    800023d4:	ffffe097          	auipc	ra,0xffffe
    800023d8:	18c080e7          	jalr	396(ra) # 80000560 <panic>
        panic("sched interruptible");
    800023dc:	00006517          	auipc	a0,0x6
    800023e0:	e8c50513          	addi	a0,a0,-372 # 80008268 <__func__.1+0x260>
    800023e4:	ffffe097          	auipc	ra,0xffffe
    800023e8:	17c080e7          	jalr	380(ra) # 80000560 <panic>

00000000800023ec <yield>:
{
    800023ec:	1101                	addi	sp,sp,-32
    800023ee:	ec06                	sd	ra,24(sp)
    800023f0:	e822                	sd	s0,16(sp)
    800023f2:	e426                	sd	s1,8(sp)
    800023f4:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    800023f6:	00000097          	auipc	ra,0x0
    800023fa:	880080e7          	jalr	-1920(ra) # 80001c76 <myproc>
    800023fe:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	900080e7          	jalr	-1792(ra) # 80000d00 <acquire>
    p->state = RUNNABLE;
    80002408:	478d                	li	a5,3
    8000240a:	cc9c                	sw	a5,24(s1)
    sched();
    8000240c:	00000097          	auipc	ra,0x0
    80002410:	f12080e7          	jalr	-238(ra) # 8000231e <sched>
    release(&p->lock);
    80002414:	8526                	mv	a0,s1
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	99e080e7          	jalr	-1634(ra) # 80000db4 <release>
}
    8000241e:	60e2                	ld	ra,24(sp)
    80002420:	6442                	ld	s0,16(sp)
    80002422:	64a2                	ld	s1,8(sp)
    80002424:	6105                	addi	sp,sp,32
    80002426:	8082                	ret

0000000080002428 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002428:	7179                	addi	sp,sp,-48
    8000242a:	f406                	sd	ra,40(sp)
    8000242c:	f022                	sd	s0,32(sp)
    8000242e:	ec26                	sd	s1,24(sp)
    80002430:	e84a                	sd	s2,16(sp)
    80002432:	e44e                	sd	s3,8(sp)
    80002434:	1800                	addi	s0,sp,48
    80002436:	89aa                	mv	s3,a0
    80002438:	892e                	mv	s2,a1
    struct proc *p = myproc();
    8000243a:	00000097          	auipc	ra,0x0
    8000243e:	83c080e7          	jalr	-1988(ra) # 80001c76 <myproc>
    80002442:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    80002444:	fffff097          	auipc	ra,0xfffff
    80002448:	8bc080e7          	jalr	-1860(ra) # 80000d00 <acquire>
    release(lk);
    8000244c:	854a                	mv	a0,s2
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	966080e7          	jalr	-1690(ra) # 80000db4 <release>

    // Go to sleep.
    p->chan = chan;
    80002456:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    8000245a:	4789                	li	a5,2
    8000245c:	cc9c                	sw	a5,24(s1)

    sched();
    8000245e:	00000097          	auipc	ra,0x0
    80002462:	ec0080e7          	jalr	-320(ra) # 8000231e <sched>

    // Tidy up.
    p->chan = 0;
    80002466:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    8000246a:	8526                	mv	a0,s1
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	948080e7          	jalr	-1720(ra) # 80000db4 <release>
    acquire(lk);
    80002474:	854a                	mv	a0,s2
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	88a080e7          	jalr	-1910(ra) # 80000d00 <acquire>
}
    8000247e:	70a2                	ld	ra,40(sp)
    80002480:	7402                	ld	s0,32(sp)
    80002482:	64e2                	ld	s1,24(sp)
    80002484:	6942                	ld	s2,16(sp)
    80002486:	69a2                	ld	s3,8(sp)
    80002488:	6145                	addi	sp,sp,48
    8000248a:	8082                	ret

000000008000248c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000248c:	7139                	addi	sp,sp,-64
    8000248e:	fc06                	sd	ra,56(sp)
    80002490:	f822                	sd	s0,48(sp)
    80002492:	f426                	sd	s1,40(sp)
    80002494:	f04a                	sd	s2,32(sp)
    80002496:	ec4e                	sd	s3,24(sp)
    80002498:	e852                	sd	s4,16(sp)
    8000249a:	e456                	sd	s5,8(sp)
    8000249c:	0080                	addi	s0,sp,64
    8000249e:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800024a0:	00011497          	auipc	s1,0x11
    800024a4:	72048493          	addi	s1,s1,1824 # 80013bc0 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    800024a8:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    800024aa:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    800024ac:	00017917          	auipc	s2,0x17
    800024b0:	11490913          	addi	s2,s2,276 # 800195c0 <tickslock>
    800024b4:	a811                	j	800024c8 <wakeup+0x3c>
            }
            release(&p->lock);
    800024b6:	8526                	mv	a0,s1
    800024b8:	fffff097          	auipc	ra,0xfffff
    800024bc:	8fc080e7          	jalr	-1796(ra) # 80000db4 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800024c0:	16848493          	addi	s1,s1,360
    800024c4:	03248663          	beq	s1,s2,800024f0 <wakeup+0x64>
        if (p != myproc())
    800024c8:	fffff097          	auipc	ra,0xfffff
    800024cc:	7ae080e7          	jalr	1966(ra) # 80001c76 <myproc>
    800024d0:	fea488e3          	beq	s1,a0,800024c0 <wakeup+0x34>
            acquire(&p->lock);
    800024d4:	8526                	mv	a0,s1
    800024d6:	fffff097          	auipc	ra,0xfffff
    800024da:	82a080e7          	jalr	-2006(ra) # 80000d00 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    800024de:	4c9c                	lw	a5,24(s1)
    800024e0:	fd379be3          	bne	a5,s3,800024b6 <wakeup+0x2a>
    800024e4:	709c                	ld	a5,32(s1)
    800024e6:	fd4798e3          	bne	a5,s4,800024b6 <wakeup+0x2a>
                p->state = RUNNABLE;
    800024ea:	0154ac23          	sw	s5,24(s1)
    800024ee:	b7e1                	j	800024b6 <wakeup+0x2a>
        }
    }
}
    800024f0:	70e2                	ld	ra,56(sp)
    800024f2:	7442                	ld	s0,48(sp)
    800024f4:	74a2                	ld	s1,40(sp)
    800024f6:	7902                	ld	s2,32(sp)
    800024f8:	69e2                	ld	s3,24(sp)
    800024fa:	6a42                	ld	s4,16(sp)
    800024fc:	6aa2                	ld	s5,8(sp)
    800024fe:	6121                	addi	sp,sp,64
    80002500:	8082                	ret

0000000080002502 <reparent>:
{
    80002502:	7179                	addi	sp,sp,-48
    80002504:	f406                	sd	ra,40(sp)
    80002506:	f022                	sd	s0,32(sp)
    80002508:	ec26                	sd	s1,24(sp)
    8000250a:	e84a                	sd	s2,16(sp)
    8000250c:	e44e                	sd	s3,8(sp)
    8000250e:	e052                	sd	s4,0(sp)
    80002510:	1800                	addi	s0,sp,48
    80002512:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002514:	00011497          	auipc	s1,0x11
    80002518:	6ac48493          	addi	s1,s1,1708 # 80013bc0 <proc>
            pp->parent = initproc;
    8000251c:	00009a17          	auipc	s4,0x9
    80002520:	ffca0a13          	addi	s4,s4,-4 # 8000b518 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002524:	00017997          	auipc	s3,0x17
    80002528:	09c98993          	addi	s3,s3,156 # 800195c0 <tickslock>
    8000252c:	a029                	j	80002536 <reparent+0x34>
    8000252e:	16848493          	addi	s1,s1,360
    80002532:	01348d63          	beq	s1,s3,8000254c <reparent+0x4a>
        if (pp->parent == p)
    80002536:	7c9c                	ld	a5,56(s1)
    80002538:	ff279be3          	bne	a5,s2,8000252e <reparent+0x2c>
            pp->parent = initproc;
    8000253c:	000a3503          	ld	a0,0(s4)
    80002540:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    80002542:	00000097          	auipc	ra,0x0
    80002546:	f4a080e7          	jalr	-182(ra) # 8000248c <wakeup>
    8000254a:	b7d5                	j	8000252e <reparent+0x2c>
}
    8000254c:	70a2                	ld	ra,40(sp)
    8000254e:	7402                	ld	s0,32(sp)
    80002550:	64e2                	ld	s1,24(sp)
    80002552:	6942                	ld	s2,16(sp)
    80002554:	69a2                	ld	s3,8(sp)
    80002556:	6a02                	ld	s4,0(sp)
    80002558:	6145                	addi	sp,sp,48
    8000255a:	8082                	ret

000000008000255c <exit>:
{
    8000255c:	7179                	addi	sp,sp,-48
    8000255e:	f406                	sd	ra,40(sp)
    80002560:	f022                	sd	s0,32(sp)
    80002562:	ec26                	sd	s1,24(sp)
    80002564:	e84a                	sd	s2,16(sp)
    80002566:	e44e                	sd	s3,8(sp)
    80002568:	e052                	sd	s4,0(sp)
    8000256a:	1800                	addi	s0,sp,48
    8000256c:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    8000256e:	fffff097          	auipc	ra,0xfffff
    80002572:	708080e7          	jalr	1800(ra) # 80001c76 <myproc>
    80002576:	89aa                	mv	s3,a0
    if (p == initproc)
    80002578:	00009797          	auipc	a5,0x9
    8000257c:	fa07b783          	ld	a5,-96(a5) # 8000b518 <initproc>
    80002580:	0d050493          	addi	s1,a0,208
    80002584:	15050913          	addi	s2,a0,336
    80002588:	02a79363          	bne	a5,a0,800025ae <exit+0x52>
        panic("init exiting");
    8000258c:	00006517          	auipc	a0,0x6
    80002590:	cf450513          	addi	a0,a0,-780 # 80008280 <__func__.1+0x278>
    80002594:	ffffe097          	auipc	ra,0xffffe
    80002598:	fcc080e7          	jalr	-52(ra) # 80000560 <panic>
            fileclose(f);
    8000259c:	00002097          	auipc	ra,0x2
    800025a0:	52e080e7          	jalr	1326(ra) # 80004aca <fileclose>
            p->ofile[fd] = 0;
    800025a4:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    800025a8:	04a1                	addi	s1,s1,8
    800025aa:	01248563          	beq	s1,s2,800025b4 <exit+0x58>
        if (p->ofile[fd])
    800025ae:	6088                	ld	a0,0(s1)
    800025b0:	f575                	bnez	a0,8000259c <exit+0x40>
    800025b2:	bfdd                	j	800025a8 <exit+0x4c>
    begin_op();
    800025b4:	00002097          	auipc	ra,0x2
    800025b8:	04c080e7          	jalr	76(ra) # 80004600 <begin_op>
    iput(p->cwd);
    800025bc:	1509b503          	ld	a0,336(s3)
    800025c0:	00002097          	auipc	ra,0x2
    800025c4:	830080e7          	jalr	-2000(ra) # 80003df0 <iput>
    end_op();
    800025c8:	00002097          	auipc	ra,0x2
    800025cc:	0b2080e7          	jalr	178(ra) # 8000467a <end_op>
    p->cwd = 0;
    800025d0:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    800025d4:	00011497          	auipc	s1,0x11
    800025d8:	5d448493          	addi	s1,s1,1492 # 80013ba8 <wait_lock>
    800025dc:	8526                	mv	a0,s1
    800025de:	ffffe097          	auipc	ra,0xffffe
    800025e2:	722080e7          	jalr	1826(ra) # 80000d00 <acquire>
    reparent(p);
    800025e6:	854e                	mv	a0,s3
    800025e8:	00000097          	auipc	ra,0x0
    800025ec:	f1a080e7          	jalr	-230(ra) # 80002502 <reparent>
    wakeup(p->parent);
    800025f0:	0389b503          	ld	a0,56(s3)
    800025f4:	00000097          	auipc	ra,0x0
    800025f8:	e98080e7          	jalr	-360(ra) # 8000248c <wakeup>
    acquire(&p->lock);
    800025fc:	854e                	mv	a0,s3
    800025fe:	ffffe097          	auipc	ra,0xffffe
    80002602:	702080e7          	jalr	1794(ra) # 80000d00 <acquire>
    p->xstate = status;
    80002606:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    8000260a:	4795                	li	a5,5
    8000260c:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002610:	8526                	mv	a0,s1
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	7a2080e7          	jalr	1954(ra) # 80000db4 <release>
    sched();
    8000261a:	00000097          	auipc	ra,0x0
    8000261e:	d04080e7          	jalr	-764(ra) # 8000231e <sched>
    panic("zombie exit");
    80002622:	00006517          	auipc	a0,0x6
    80002626:	c6e50513          	addi	a0,a0,-914 # 80008290 <__func__.1+0x288>
    8000262a:	ffffe097          	auipc	ra,0xffffe
    8000262e:	f36080e7          	jalr	-202(ra) # 80000560 <panic>

0000000080002632 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002632:	7179                	addi	sp,sp,-48
    80002634:	f406                	sd	ra,40(sp)
    80002636:	f022                	sd	s0,32(sp)
    80002638:	ec26                	sd	s1,24(sp)
    8000263a:	e84a                	sd	s2,16(sp)
    8000263c:	e44e                	sd	s3,8(sp)
    8000263e:	1800                	addi	s0,sp,48
    80002640:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002642:	00011497          	auipc	s1,0x11
    80002646:	57e48493          	addi	s1,s1,1406 # 80013bc0 <proc>
    8000264a:	00017997          	auipc	s3,0x17
    8000264e:	f7698993          	addi	s3,s3,-138 # 800195c0 <tickslock>
    {
        acquire(&p->lock);
    80002652:	8526                	mv	a0,s1
    80002654:	ffffe097          	auipc	ra,0xffffe
    80002658:	6ac080e7          	jalr	1708(ra) # 80000d00 <acquire>
        if (p->pid == pid)
    8000265c:	589c                	lw	a5,48(s1)
    8000265e:	01278d63          	beq	a5,s2,80002678 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002662:	8526                	mv	a0,s1
    80002664:	ffffe097          	auipc	ra,0xffffe
    80002668:	750080e7          	jalr	1872(ra) # 80000db4 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000266c:	16848493          	addi	s1,s1,360
    80002670:	ff3491e3          	bne	s1,s3,80002652 <kill+0x20>
    }
    return -1;
    80002674:	557d                	li	a0,-1
    80002676:	a829                	j	80002690 <kill+0x5e>
            p->killed = 1;
    80002678:	4785                	li	a5,1
    8000267a:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    8000267c:	4c98                	lw	a4,24(s1)
    8000267e:	4789                	li	a5,2
    80002680:	00f70f63          	beq	a4,a5,8000269e <kill+0x6c>
            release(&p->lock);
    80002684:	8526                	mv	a0,s1
    80002686:	ffffe097          	auipc	ra,0xffffe
    8000268a:	72e080e7          	jalr	1838(ra) # 80000db4 <release>
            return 0;
    8000268e:	4501                	li	a0,0
}
    80002690:	70a2                	ld	ra,40(sp)
    80002692:	7402                	ld	s0,32(sp)
    80002694:	64e2                	ld	s1,24(sp)
    80002696:	6942                	ld	s2,16(sp)
    80002698:	69a2                	ld	s3,8(sp)
    8000269a:	6145                	addi	sp,sp,48
    8000269c:	8082                	ret
                p->state = RUNNABLE;
    8000269e:	478d                	li	a5,3
    800026a0:	cc9c                	sw	a5,24(s1)
    800026a2:	b7cd                	j	80002684 <kill+0x52>

00000000800026a4 <setkilled>:

void setkilled(struct proc *p)
{
    800026a4:	1101                	addi	sp,sp,-32
    800026a6:	ec06                	sd	ra,24(sp)
    800026a8:	e822                	sd	s0,16(sp)
    800026aa:	e426                	sd	s1,8(sp)
    800026ac:	1000                	addi	s0,sp,32
    800026ae:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	650080e7          	jalr	1616(ra) # 80000d00 <acquire>
    p->killed = 1;
    800026b8:	4785                	li	a5,1
    800026ba:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    800026bc:	8526                	mv	a0,s1
    800026be:	ffffe097          	auipc	ra,0xffffe
    800026c2:	6f6080e7          	jalr	1782(ra) # 80000db4 <release>
}
    800026c6:	60e2                	ld	ra,24(sp)
    800026c8:	6442                	ld	s0,16(sp)
    800026ca:	64a2                	ld	s1,8(sp)
    800026cc:	6105                	addi	sp,sp,32
    800026ce:	8082                	ret

00000000800026d0 <killed>:

int killed(struct proc *p)
{
    800026d0:	1101                	addi	sp,sp,-32
    800026d2:	ec06                	sd	ra,24(sp)
    800026d4:	e822                	sd	s0,16(sp)
    800026d6:	e426                	sd	s1,8(sp)
    800026d8:	e04a                	sd	s2,0(sp)
    800026da:	1000                	addi	s0,sp,32
    800026dc:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    800026de:	ffffe097          	auipc	ra,0xffffe
    800026e2:	622080e7          	jalr	1570(ra) # 80000d00 <acquire>
    k = p->killed;
    800026e6:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    800026ea:	8526                	mv	a0,s1
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	6c8080e7          	jalr	1736(ra) # 80000db4 <release>
    return k;
}
    800026f4:	854a                	mv	a0,s2
    800026f6:	60e2                	ld	ra,24(sp)
    800026f8:	6442                	ld	s0,16(sp)
    800026fa:	64a2                	ld	s1,8(sp)
    800026fc:	6902                	ld	s2,0(sp)
    800026fe:	6105                	addi	sp,sp,32
    80002700:	8082                	ret

0000000080002702 <wait>:
{
    80002702:	715d                	addi	sp,sp,-80
    80002704:	e486                	sd	ra,72(sp)
    80002706:	e0a2                	sd	s0,64(sp)
    80002708:	fc26                	sd	s1,56(sp)
    8000270a:	f84a                	sd	s2,48(sp)
    8000270c:	f44e                	sd	s3,40(sp)
    8000270e:	f052                	sd	s4,32(sp)
    80002710:	ec56                	sd	s5,24(sp)
    80002712:	e85a                	sd	s6,16(sp)
    80002714:	e45e                	sd	s7,8(sp)
    80002716:	e062                	sd	s8,0(sp)
    80002718:	0880                	addi	s0,sp,80
    8000271a:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    8000271c:	fffff097          	auipc	ra,0xfffff
    80002720:	55a080e7          	jalr	1370(ra) # 80001c76 <myproc>
    80002724:	892a                	mv	s2,a0
    acquire(&wait_lock);
    80002726:	00011517          	auipc	a0,0x11
    8000272a:	48250513          	addi	a0,a0,1154 # 80013ba8 <wait_lock>
    8000272e:	ffffe097          	auipc	ra,0xffffe
    80002732:	5d2080e7          	jalr	1490(ra) # 80000d00 <acquire>
        havekids = 0;
    80002736:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    80002738:	4a15                	li	s4,5
                havekids = 1;
    8000273a:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    8000273c:	00017997          	auipc	s3,0x17
    80002740:	e8498993          	addi	s3,s3,-380 # 800195c0 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002744:	00011c17          	auipc	s8,0x11
    80002748:	464c0c13          	addi	s8,s8,1124 # 80013ba8 <wait_lock>
    8000274c:	a0d1                	j	80002810 <wait+0x10e>
                    pid = pp->pid;
    8000274e:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002752:	000b0e63          	beqz	s6,8000276e <wait+0x6c>
    80002756:	4691                	li	a3,4
    80002758:	02c48613          	addi	a2,s1,44
    8000275c:	85da                	mv	a1,s6
    8000275e:	05093503          	ld	a0,80(s2)
    80002762:	fffff097          	auipc	ra,0xfffff
    80002766:	048080e7          	jalr	72(ra) # 800017aa <copyout>
    8000276a:	04054163          	bltz	a0,800027ac <wait+0xaa>
                    freeproc(pp);
    8000276e:	8526                	mv	a0,s1
    80002770:	fffff097          	auipc	ra,0xfffff
    80002774:	6b8080e7          	jalr	1720(ra) # 80001e28 <freeproc>
                    release(&pp->lock);
    80002778:	8526                	mv	a0,s1
    8000277a:	ffffe097          	auipc	ra,0xffffe
    8000277e:	63a080e7          	jalr	1594(ra) # 80000db4 <release>
                    release(&wait_lock);
    80002782:	00011517          	auipc	a0,0x11
    80002786:	42650513          	addi	a0,a0,1062 # 80013ba8 <wait_lock>
    8000278a:	ffffe097          	auipc	ra,0xffffe
    8000278e:	62a080e7          	jalr	1578(ra) # 80000db4 <release>
}
    80002792:	854e                	mv	a0,s3
    80002794:	60a6                	ld	ra,72(sp)
    80002796:	6406                	ld	s0,64(sp)
    80002798:	74e2                	ld	s1,56(sp)
    8000279a:	7942                	ld	s2,48(sp)
    8000279c:	79a2                	ld	s3,40(sp)
    8000279e:	7a02                	ld	s4,32(sp)
    800027a0:	6ae2                	ld	s5,24(sp)
    800027a2:	6b42                	ld	s6,16(sp)
    800027a4:	6ba2                	ld	s7,8(sp)
    800027a6:	6c02                	ld	s8,0(sp)
    800027a8:	6161                	addi	sp,sp,80
    800027aa:	8082                	ret
                        release(&pp->lock);
    800027ac:	8526                	mv	a0,s1
    800027ae:	ffffe097          	auipc	ra,0xffffe
    800027b2:	606080e7          	jalr	1542(ra) # 80000db4 <release>
                        release(&wait_lock);
    800027b6:	00011517          	auipc	a0,0x11
    800027ba:	3f250513          	addi	a0,a0,1010 # 80013ba8 <wait_lock>
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	5f6080e7          	jalr	1526(ra) # 80000db4 <release>
                        return -1;
    800027c6:	59fd                	li	s3,-1
    800027c8:	b7e9                	j	80002792 <wait+0x90>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800027ca:	16848493          	addi	s1,s1,360
    800027ce:	03348463          	beq	s1,s3,800027f6 <wait+0xf4>
            if (pp->parent == p)
    800027d2:	7c9c                	ld	a5,56(s1)
    800027d4:	ff279be3          	bne	a5,s2,800027ca <wait+0xc8>
                acquire(&pp->lock);
    800027d8:	8526                	mv	a0,s1
    800027da:	ffffe097          	auipc	ra,0xffffe
    800027de:	526080e7          	jalr	1318(ra) # 80000d00 <acquire>
                if (pp->state == ZOMBIE)
    800027e2:	4c9c                	lw	a5,24(s1)
    800027e4:	f74785e3          	beq	a5,s4,8000274e <wait+0x4c>
                release(&pp->lock);
    800027e8:	8526                	mv	a0,s1
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	5ca080e7          	jalr	1482(ra) # 80000db4 <release>
                havekids = 1;
    800027f2:	8756                	mv	a4,s5
    800027f4:	bfd9                	j	800027ca <wait+0xc8>
        if (!havekids || killed(p))
    800027f6:	c31d                	beqz	a4,8000281c <wait+0x11a>
    800027f8:	854a                	mv	a0,s2
    800027fa:	00000097          	auipc	ra,0x0
    800027fe:	ed6080e7          	jalr	-298(ra) # 800026d0 <killed>
    80002802:	ed09                	bnez	a0,8000281c <wait+0x11a>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002804:	85e2                	mv	a1,s8
    80002806:	854a                	mv	a0,s2
    80002808:	00000097          	auipc	ra,0x0
    8000280c:	c20080e7          	jalr	-992(ra) # 80002428 <sleep>
        havekids = 0;
    80002810:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002812:	00011497          	auipc	s1,0x11
    80002816:	3ae48493          	addi	s1,s1,942 # 80013bc0 <proc>
    8000281a:	bf65                	j	800027d2 <wait+0xd0>
            release(&wait_lock);
    8000281c:	00011517          	auipc	a0,0x11
    80002820:	38c50513          	addi	a0,a0,908 # 80013ba8 <wait_lock>
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	590080e7          	jalr	1424(ra) # 80000db4 <release>
            return -1;
    8000282c:	59fd                	li	s3,-1
    8000282e:	b795                	j	80002792 <wait+0x90>

0000000080002830 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002830:	7179                	addi	sp,sp,-48
    80002832:	f406                	sd	ra,40(sp)
    80002834:	f022                	sd	s0,32(sp)
    80002836:	ec26                	sd	s1,24(sp)
    80002838:	e84a                	sd	s2,16(sp)
    8000283a:	e44e                	sd	s3,8(sp)
    8000283c:	e052                	sd	s4,0(sp)
    8000283e:	1800                	addi	s0,sp,48
    80002840:	84aa                	mv	s1,a0
    80002842:	892e                	mv	s2,a1
    80002844:	89b2                	mv	s3,a2
    80002846:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002848:	fffff097          	auipc	ra,0xfffff
    8000284c:	42e080e7          	jalr	1070(ra) # 80001c76 <myproc>
    if (user_dst)
    80002850:	c08d                	beqz	s1,80002872 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002852:	86d2                	mv	a3,s4
    80002854:	864e                	mv	a2,s3
    80002856:	85ca                	mv	a1,s2
    80002858:	6928                	ld	a0,80(a0)
    8000285a:	fffff097          	auipc	ra,0xfffff
    8000285e:	f50080e7          	jalr	-176(ra) # 800017aa <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002862:	70a2                	ld	ra,40(sp)
    80002864:	7402                	ld	s0,32(sp)
    80002866:	64e2                	ld	s1,24(sp)
    80002868:	6942                	ld	s2,16(sp)
    8000286a:	69a2                	ld	s3,8(sp)
    8000286c:	6a02                	ld	s4,0(sp)
    8000286e:	6145                	addi	sp,sp,48
    80002870:	8082                	ret
        memmove((char *)dst, src, len);
    80002872:	000a061b          	sext.w	a2,s4
    80002876:	85ce                	mv	a1,s3
    80002878:	854a                	mv	a0,s2
    8000287a:	ffffe097          	auipc	ra,0xffffe
    8000287e:	5de080e7          	jalr	1502(ra) # 80000e58 <memmove>
        return 0;
    80002882:	8526                	mv	a0,s1
    80002884:	bff9                	j	80002862 <either_copyout+0x32>

0000000080002886 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002886:	7179                	addi	sp,sp,-48
    80002888:	f406                	sd	ra,40(sp)
    8000288a:	f022                	sd	s0,32(sp)
    8000288c:	ec26                	sd	s1,24(sp)
    8000288e:	e84a                	sd	s2,16(sp)
    80002890:	e44e                	sd	s3,8(sp)
    80002892:	e052                	sd	s4,0(sp)
    80002894:	1800                	addi	s0,sp,48
    80002896:	892a                	mv	s2,a0
    80002898:	84ae                	mv	s1,a1
    8000289a:	89b2                	mv	s3,a2
    8000289c:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    8000289e:	fffff097          	auipc	ra,0xfffff
    800028a2:	3d8080e7          	jalr	984(ra) # 80001c76 <myproc>
    if (user_src)
    800028a6:	c08d                	beqz	s1,800028c8 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    800028a8:	86d2                	mv	a3,s4
    800028aa:	864e                	mv	a2,s3
    800028ac:	85ca                	mv	a1,s2
    800028ae:	6928                	ld	a0,80(a0)
    800028b0:	fffff097          	auipc	ra,0xfffff
    800028b4:	f86080e7          	jalr	-122(ra) # 80001836 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    800028b8:	70a2                	ld	ra,40(sp)
    800028ba:	7402                	ld	s0,32(sp)
    800028bc:	64e2                	ld	s1,24(sp)
    800028be:	6942                	ld	s2,16(sp)
    800028c0:	69a2                	ld	s3,8(sp)
    800028c2:	6a02                	ld	s4,0(sp)
    800028c4:	6145                	addi	sp,sp,48
    800028c6:	8082                	ret
        memmove(dst, (char *)src, len);
    800028c8:	000a061b          	sext.w	a2,s4
    800028cc:	85ce                	mv	a1,s3
    800028ce:	854a                	mv	a0,s2
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	588080e7          	jalr	1416(ra) # 80000e58 <memmove>
        return 0;
    800028d8:	8526                	mv	a0,s1
    800028da:	bff9                	j	800028b8 <either_copyin+0x32>

00000000800028dc <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800028dc:	715d                	addi	sp,sp,-80
    800028de:	e486                	sd	ra,72(sp)
    800028e0:	e0a2                	sd	s0,64(sp)
    800028e2:	fc26                	sd	s1,56(sp)
    800028e4:	f84a                	sd	s2,48(sp)
    800028e6:	f44e                	sd	s3,40(sp)
    800028e8:	f052                	sd	s4,32(sp)
    800028ea:	ec56                	sd	s5,24(sp)
    800028ec:	e85a                	sd	s6,16(sp)
    800028ee:	e45e                	sd	s7,8(sp)
    800028f0:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    800028f2:	00005517          	auipc	a0,0x5
    800028f6:	72e50513          	addi	a0,a0,1838 # 80008020 <__func__.1+0x18>
    800028fa:	ffffe097          	auipc	ra,0xffffe
    800028fe:	cc2080e7          	jalr	-830(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002902:	00011497          	auipc	s1,0x11
    80002906:	41648493          	addi	s1,s1,1046 # 80013d18 <proc+0x158>
    8000290a:	00017917          	auipc	s2,0x17
    8000290e:	e0e90913          	addi	s2,s2,-498 # 80019718 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002912:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002914:	00006997          	auipc	s3,0x6
    80002918:	98c98993          	addi	s3,s3,-1652 # 800082a0 <__func__.1+0x298>
        printf("%d <%s %s", p->pid, state, p->name);
    8000291c:	00006a97          	auipc	s5,0x6
    80002920:	98ca8a93          	addi	s5,s5,-1652 # 800082a8 <__func__.1+0x2a0>
        printf("\n");
    80002924:	00005a17          	auipc	s4,0x5
    80002928:	6fca0a13          	addi	s4,s4,1788 # 80008020 <__func__.1+0x18>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000292c:	00006b97          	auipc	s7,0x6
    80002930:	f2cb8b93          	addi	s7,s7,-212 # 80008858 <states.0>
    80002934:	a00d                	j	80002956 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002936:	ed86a583          	lw	a1,-296(a3)
    8000293a:	8556                	mv	a0,s5
    8000293c:	ffffe097          	auipc	ra,0xffffe
    80002940:	c80080e7          	jalr	-896(ra) # 800005bc <printf>
        printf("\n");
    80002944:	8552                	mv	a0,s4
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	c76080e7          	jalr	-906(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    8000294e:	16848493          	addi	s1,s1,360
    80002952:	03248263          	beq	s1,s2,80002976 <procdump+0x9a>
        if (p->state == UNUSED)
    80002956:	86a6                	mv	a3,s1
    80002958:	ec04a783          	lw	a5,-320(s1)
    8000295c:	dbed                	beqz	a5,8000294e <procdump+0x72>
            state = "???";
    8000295e:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002960:	fcfb6be3          	bltu	s6,a5,80002936 <procdump+0x5a>
    80002964:	02079713          	slli	a4,a5,0x20
    80002968:	01d75793          	srli	a5,a4,0x1d
    8000296c:	97de                	add	a5,a5,s7
    8000296e:	6390                	ld	a2,0(a5)
    80002970:	f279                	bnez	a2,80002936 <procdump+0x5a>
            state = "???";
    80002972:	864e                	mv	a2,s3
    80002974:	b7c9                	j	80002936 <procdump+0x5a>
    }
}
    80002976:	60a6                	ld	ra,72(sp)
    80002978:	6406                	ld	s0,64(sp)
    8000297a:	74e2                	ld	s1,56(sp)
    8000297c:	7942                	ld	s2,48(sp)
    8000297e:	79a2                	ld	s3,40(sp)
    80002980:	7a02                	ld	s4,32(sp)
    80002982:	6ae2                	ld	s5,24(sp)
    80002984:	6b42                	ld	s6,16(sp)
    80002986:	6ba2                	ld	s7,8(sp)
    80002988:	6161                	addi	sp,sp,80
    8000298a:	8082                	ret

000000008000298c <schedls>:

void schedls()
{
    8000298c:	1141                	addi	sp,sp,-16
    8000298e:	e406                	sd	ra,8(sp)
    80002990:	e022                	sd	s0,0(sp)
    80002992:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002994:	00006517          	auipc	a0,0x6
    80002998:	92450513          	addi	a0,a0,-1756 # 800082b8 <__func__.1+0x2b0>
    8000299c:	ffffe097          	auipc	ra,0xffffe
    800029a0:	c20080e7          	jalr	-992(ra) # 800005bc <printf>
    printf("====================================\n");
    800029a4:	00006517          	auipc	a0,0x6
    800029a8:	93c50513          	addi	a0,a0,-1732 # 800082e0 <__func__.1+0x2d8>
    800029ac:	ffffe097          	auipc	ra,0xffffe
    800029b0:	c10080e7          	jalr	-1008(ra) # 800005bc <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    800029b4:	00009717          	auipc	a4,0x9
    800029b8:	af473703          	ld	a4,-1292(a4) # 8000b4a8 <available_schedulers+0x10>
    800029bc:	00009797          	auipc	a5,0x9
    800029c0:	a8c7b783          	ld	a5,-1396(a5) # 8000b448 <sched_pointer>
    800029c4:	04f70663          	beq	a4,a5,80002a10 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    800029c8:	00006517          	auipc	a0,0x6
    800029cc:	94850513          	addi	a0,a0,-1720 # 80008310 <__func__.1+0x308>
    800029d0:	ffffe097          	auipc	ra,0xffffe
    800029d4:	bec080e7          	jalr	-1044(ra) # 800005bc <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    800029d8:	00009617          	auipc	a2,0x9
    800029dc:	ad862603          	lw	a2,-1320(a2) # 8000b4b0 <available_schedulers+0x18>
    800029e0:	00009597          	auipc	a1,0x9
    800029e4:	ab858593          	addi	a1,a1,-1352 # 8000b498 <available_schedulers>
    800029e8:	00006517          	auipc	a0,0x6
    800029ec:	93050513          	addi	a0,a0,-1744 # 80008318 <__func__.1+0x310>
    800029f0:	ffffe097          	auipc	ra,0xffffe
    800029f4:	bcc080e7          	jalr	-1076(ra) # 800005bc <printf>
    }
    printf("\n*: current scheduler\n\n");
    800029f8:	00006517          	auipc	a0,0x6
    800029fc:	92850513          	addi	a0,a0,-1752 # 80008320 <__func__.1+0x318>
    80002a00:	ffffe097          	auipc	ra,0xffffe
    80002a04:	bbc080e7          	jalr	-1092(ra) # 800005bc <printf>
}
    80002a08:	60a2                	ld	ra,8(sp)
    80002a0a:	6402                	ld	s0,0(sp)
    80002a0c:	0141                	addi	sp,sp,16
    80002a0e:	8082                	ret
            printf("[*]\t");
    80002a10:	00006517          	auipc	a0,0x6
    80002a14:	8f850513          	addi	a0,a0,-1800 # 80008308 <__func__.1+0x300>
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	ba4080e7          	jalr	-1116(ra) # 800005bc <printf>
    80002a20:	bf65                	j	800029d8 <schedls+0x4c>

0000000080002a22 <schedset>:

void schedset(int id)
{
    80002a22:	1141                	addi	sp,sp,-16
    80002a24:	e406                	sd	ra,8(sp)
    80002a26:	e022                	sd	s0,0(sp)
    80002a28:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002a2a:	e90d                	bnez	a0,80002a5c <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002a2c:	00009797          	auipc	a5,0x9
    80002a30:	a7c7b783          	ld	a5,-1412(a5) # 8000b4a8 <available_schedulers+0x10>
    80002a34:	00009717          	auipc	a4,0x9
    80002a38:	a0f73a23          	sd	a5,-1516(a4) # 8000b448 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002a3c:	00009597          	auipc	a1,0x9
    80002a40:	a5c58593          	addi	a1,a1,-1444 # 8000b498 <available_schedulers>
    80002a44:	00006517          	auipc	a0,0x6
    80002a48:	91c50513          	addi	a0,a0,-1764 # 80008360 <__func__.1+0x358>
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	b70080e7          	jalr	-1168(ra) # 800005bc <printf>
    80002a54:	60a2                	ld	ra,8(sp)
    80002a56:	6402                	ld	s0,0(sp)
    80002a58:	0141                	addi	sp,sp,16
    80002a5a:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002a5c:	00006517          	auipc	a0,0x6
    80002a60:	8dc50513          	addi	a0,a0,-1828 # 80008338 <__func__.1+0x330>
    80002a64:	ffffe097          	auipc	ra,0xffffe
    80002a68:	b58080e7          	jalr	-1192(ra) # 800005bc <printf>
        return;
    80002a6c:	b7e5                	j	80002a54 <schedset+0x32>

0000000080002a6e <swtch>:
    80002a6e:	00153023          	sd	ra,0(a0)
    80002a72:	00253423          	sd	sp,8(a0)
    80002a76:	e900                	sd	s0,16(a0)
    80002a78:	ed04                	sd	s1,24(a0)
    80002a7a:	03253023          	sd	s2,32(a0)
    80002a7e:	03353423          	sd	s3,40(a0)
    80002a82:	03453823          	sd	s4,48(a0)
    80002a86:	03553c23          	sd	s5,56(a0)
    80002a8a:	05653023          	sd	s6,64(a0)
    80002a8e:	05753423          	sd	s7,72(a0)
    80002a92:	05853823          	sd	s8,80(a0)
    80002a96:	05953c23          	sd	s9,88(a0)
    80002a9a:	07a53023          	sd	s10,96(a0)
    80002a9e:	07b53423          	sd	s11,104(a0)
    80002aa2:	0005b083          	ld	ra,0(a1)
    80002aa6:	0085b103          	ld	sp,8(a1)
    80002aaa:	6980                	ld	s0,16(a1)
    80002aac:	6d84                	ld	s1,24(a1)
    80002aae:	0205b903          	ld	s2,32(a1)
    80002ab2:	0285b983          	ld	s3,40(a1)
    80002ab6:	0305ba03          	ld	s4,48(a1)
    80002aba:	0385ba83          	ld	s5,56(a1)
    80002abe:	0405bb03          	ld	s6,64(a1)
    80002ac2:	0485bb83          	ld	s7,72(a1)
    80002ac6:	0505bc03          	ld	s8,80(a1)
    80002aca:	0585bc83          	ld	s9,88(a1)
    80002ace:	0605bd03          	ld	s10,96(a1)
    80002ad2:	0685bd83          	ld	s11,104(a1)
    80002ad6:	8082                	ret

0000000080002ad8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002ad8:	1141                	addi	sp,sp,-16
    80002ada:	e406                	sd	ra,8(sp)
    80002adc:	e022                	sd	s0,0(sp)
    80002ade:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ae0:	00006597          	auipc	a1,0x6
    80002ae4:	8d858593          	addi	a1,a1,-1832 # 800083b8 <__func__.1+0x3b0>
    80002ae8:	00017517          	auipc	a0,0x17
    80002aec:	ad850513          	addi	a0,a0,-1320 # 800195c0 <tickslock>
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	180080e7          	jalr	384(ra) # 80000c70 <initlock>
}
    80002af8:	60a2                	ld	ra,8(sp)
    80002afa:	6402                	ld	s0,0(sp)
    80002afc:	0141                	addi	sp,sp,16
    80002afe:	8082                	ret

0000000080002b00 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b00:	1141                	addi	sp,sp,-16
    80002b02:	e422                	sd	s0,8(sp)
    80002b04:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002b06:	00003797          	auipc	a5,0x3
    80002b0a:	6ca78793          	addi	a5,a5,1738 # 800061d0 <kernelvec>
    80002b0e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b12:	6422                	ld	s0,8(sp)
    80002b14:	0141                	addi	sp,sp,16
    80002b16:	8082                	ret

0000000080002b18 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b18:	1141                	addi	sp,sp,-16
    80002b1a:	e406                	sd	ra,8(sp)
    80002b1c:	e022                	sd	s0,0(sp)
    80002b1e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b20:	fffff097          	auipc	ra,0xfffff
    80002b24:	156080e7          	jalr	342(ra) # 80001c76 <myproc>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002b28:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b2c:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002b2e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b32:	00004697          	auipc	a3,0x4
    80002b36:	4ce68693          	addi	a3,a3,1230 # 80007000 <_trampoline>
    80002b3a:	00004717          	auipc	a4,0x4
    80002b3e:	4c670713          	addi	a4,a4,1222 # 80007000 <_trampoline>
    80002b42:	8f15                	sub	a4,a4,a3
    80002b44:	040007b7          	lui	a5,0x4000
    80002b48:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002b4a:	07b2                	slli	a5,a5,0xc
    80002b4c:	973e                	add	a4,a4,a5
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002b4e:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b52:	6d38                	ld	a4,88(a0)
    asm volatile("csrr %0, satp" : "=r"(x));
    80002b54:	18002673          	csrr	a2,satp
    80002b58:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b5a:	6d30                	ld	a2,88(a0)
    80002b5c:	6138                	ld	a4,64(a0)
    80002b5e:	6585                	lui	a1,0x1
    80002b60:	972e                	add	a4,a4,a1
    80002b62:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b64:	6d38                	ld	a4,88(a0)
    80002b66:	00000617          	auipc	a2,0x0
    80002b6a:	13860613          	addi	a2,a2,312 # 80002c9e <usertrap>
    80002b6e:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b70:	6d38                	ld	a4,88(a0)
    asm volatile("mv %0, tp" : "=r"(x));
    80002b72:	8612                	mv	a2,tp
    80002b74:	f310                	sd	a2,32(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002b76:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b7a:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b7e:	02076713          	ori	a4,a4,32
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002b82:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b86:	6d38                	ld	a4,88(a0)
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002b88:	6f18                	ld	a4,24(a4)
    80002b8a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b8e:	6928                	ld	a0,80(a0)
    80002b90:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b92:	00004717          	auipc	a4,0x4
    80002b96:	50a70713          	addi	a4,a4,1290 # 8000709c <userret>
    80002b9a:	8f15                	sub	a4,a4,a3
    80002b9c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002b9e:	577d                	li	a4,-1
    80002ba0:	177e                	slli	a4,a4,0x3f
    80002ba2:	8d59                	or	a0,a0,a4
    80002ba4:	9782                	jalr	a5
}
    80002ba6:	60a2                	ld	ra,8(sp)
    80002ba8:	6402                	ld	s0,0(sp)
    80002baa:	0141                	addi	sp,sp,16
    80002bac:	8082                	ret

0000000080002bae <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002bae:	1101                	addi	sp,sp,-32
    80002bb0:	ec06                	sd	ra,24(sp)
    80002bb2:	e822                	sd	s0,16(sp)
    80002bb4:	e426                	sd	s1,8(sp)
    80002bb6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002bb8:	00017497          	auipc	s1,0x17
    80002bbc:	a0848493          	addi	s1,s1,-1528 # 800195c0 <tickslock>
    80002bc0:	8526                	mv	a0,s1
    80002bc2:	ffffe097          	auipc	ra,0xffffe
    80002bc6:	13e080e7          	jalr	318(ra) # 80000d00 <acquire>
  ticks++;
    80002bca:	00009517          	auipc	a0,0x9
    80002bce:	95650513          	addi	a0,a0,-1706 # 8000b520 <ticks>
    80002bd2:	411c                	lw	a5,0(a0)
    80002bd4:	2785                	addiw	a5,a5,1
    80002bd6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002bd8:	00000097          	auipc	ra,0x0
    80002bdc:	8b4080e7          	jalr	-1868(ra) # 8000248c <wakeup>
  release(&tickslock);
    80002be0:	8526                	mv	a0,s1
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	1d2080e7          	jalr	466(ra) # 80000db4 <release>
}
    80002bea:	60e2                	ld	ra,24(sp)
    80002bec:	6442                	ld	s0,16(sp)
    80002bee:	64a2                	ld	s1,8(sp)
    80002bf0:	6105                	addi	sp,sp,32
    80002bf2:	8082                	ret

0000000080002bf4 <devintr>:
    asm volatile("csrr %0, scause" : "=r"(x));
    80002bf4:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002bf8:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002bfa:	0a07d163          	bgez	a5,80002c9c <devintr+0xa8>
{
    80002bfe:	1101                	addi	sp,sp,-32
    80002c00:	ec06                	sd	ra,24(sp)
    80002c02:	e822                	sd	s0,16(sp)
    80002c04:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002c06:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002c0a:	46a5                	li	a3,9
    80002c0c:	00d70c63          	beq	a4,a3,80002c24 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002c10:	577d                	li	a4,-1
    80002c12:	177e                	slli	a4,a4,0x3f
    80002c14:	0705                	addi	a4,a4,1
    return 0;
    80002c16:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c18:	06e78163          	beq	a5,a4,80002c7a <devintr+0x86>
  }
}
    80002c1c:	60e2                	ld	ra,24(sp)
    80002c1e:	6442                	ld	s0,16(sp)
    80002c20:	6105                	addi	sp,sp,32
    80002c22:	8082                	ret
    80002c24:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002c26:	00003097          	auipc	ra,0x3
    80002c2a:	6b6080e7          	jalr	1718(ra) # 800062dc <plic_claim>
    80002c2e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c30:	47a9                	li	a5,10
    80002c32:	00f50963          	beq	a0,a5,80002c44 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002c36:	4785                	li	a5,1
    80002c38:	00f50b63          	beq	a0,a5,80002c4e <devintr+0x5a>
    return 1;
    80002c3c:	4505                	li	a0,1
    } else if(irq){
    80002c3e:	ec89                	bnez	s1,80002c58 <devintr+0x64>
    80002c40:	64a2                	ld	s1,8(sp)
    80002c42:	bfe9                	j	80002c1c <devintr+0x28>
      uartintr();
    80002c44:	ffffe097          	auipc	ra,0xffffe
    80002c48:	dc8080e7          	jalr	-568(ra) # 80000a0c <uartintr>
    if(irq)
    80002c4c:	a839                	j	80002c6a <devintr+0x76>
      virtio_disk_intr();
    80002c4e:	00004097          	auipc	ra,0x4
    80002c52:	bb8080e7          	jalr	-1096(ra) # 80006806 <virtio_disk_intr>
    if(irq)
    80002c56:	a811                	j	80002c6a <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c58:	85a6                	mv	a1,s1
    80002c5a:	00005517          	auipc	a0,0x5
    80002c5e:	76650513          	addi	a0,a0,1894 # 800083c0 <__func__.1+0x3b8>
    80002c62:	ffffe097          	auipc	ra,0xffffe
    80002c66:	95a080e7          	jalr	-1702(ra) # 800005bc <printf>
      plic_complete(irq);
    80002c6a:	8526                	mv	a0,s1
    80002c6c:	00003097          	auipc	ra,0x3
    80002c70:	694080e7          	jalr	1684(ra) # 80006300 <plic_complete>
    return 1;
    80002c74:	4505                	li	a0,1
    80002c76:	64a2                	ld	s1,8(sp)
    80002c78:	b755                	j	80002c1c <devintr+0x28>
    if(cpuid() == 0){
    80002c7a:	fffff097          	auipc	ra,0xfffff
    80002c7e:	fd0080e7          	jalr	-48(ra) # 80001c4a <cpuid>
    80002c82:	c901                	beqz	a0,80002c92 <devintr+0x9e>
    asm volatile("csrr %0, sip" : "=r"(x));
    80002c84:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c88:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip, %0" : : "r"(x));
    80002c8a:	14479073          	csrw	sip,a5
    return 2;
    80002c8e:	4509                	li	a0,2
    80002c90:	b771                	j	80002c1c <devintr+0x28>
      clockintr();
    80002c92:	00000097          	auipc	ra,0x0
    80002c96:	f1c080e7          	jalr	-228(ra) # 80002bae <clockintr>
    80002c9a:	b7ed                	j	80002c84 <devintr+0x90>
}
    80002c9c:	8082                	ret

0000000080002c9e <usertrap>:
{
    80002c9e:	1101                	addi	sp,sp,-32
    80002ca0:	ec06                	sd	ra,24(sp)
    80002ca2:	e822                	sd	s0,16(sp)
    80002ca4:	e426                	sd	s1,8(sp)
    80002ca6:	e04a                	sd	s2,0(sp)
    80002ca8:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002caa:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002cae:	1007f793          	andi	a5,a5,256
    80002cb2:	e3b1                	bnez	a5,80002cf6 <usertrap+0x58>
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002cb4:	00003797          	auipc	a5,0x3
    80002cb8:	51c78793          	addi	a5,a5,1308 # 800061d0 <kernelvec>
    80002cbc:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002cc0:	fffff097          	auipc	ra,0xfffff
    80002cc4:	fb6080e7          	jalr	-74(ra) # 80001c76 <myproc>
    80002cc8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002cca:	6d3c                	ld	a5,88(a0)
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002ccc:	14102773          	csrr	a4,sepc
    80002cd0:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0, scause" : "=r"(x));
    80002cd2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cd6:	47a1                	li	a5,8
    80002cd8:	02f70763          	beq	a4,a5,80002d06 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002cdc:	00000097          	auipc	ra,0x0
    80002ce0:	f18080e7          	jalr	-232(ra) # 80002bf4 <devintr>
    80002ce4:	892a                	mv	s2,a0
    80002ce6:	c151                	beqz	a0,80002d6a <usertrap+0xcc>
  if(killed(p))
    80002ce8:	8526                	mv	a0,s1
    80002cea:	00000097          	auipc	ra,0x0
    80002cee:	9e6080e7          	jalr	-1562(ra) # 800026d0 <killed>
    80002cf2:	c929                	beqz	a0,80002d44 <usertrap+0xa6>
    80002cf4:	a099                	j	80002d3a <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002cf6:	00005517          	auipc	a0,0x5
    80002cfa:	6ea50513          	addi	a0,a0,1770 # 800083e0 <__func__.1+0x3d8>
    80002cfe:	ffffe097          	auipc	ra,0xffffe
    80002d02:	862080e7          	jalr	-1950(ra) # 80000560 <panic>
    if(killed(p))
    80002d06:	00000097          	auipc	ra,0x0
    80002d0a:	9ca080e7          	jalr	-1590(ra) # 800026d0 <killed>
    80002d0e:	e921                	bnez	a0,80002d5e <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002d10:	6cb8                	ld	a4,88(s1)
    80002d12:	6f1c                	ld	a5,24(a4)
    80002d14:	0791                	addi	a5,a5,4
    80002d16:	ef1c                	sd	a5,24(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002d18:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d1c:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002d20:	10079073          	csrw	sstatus,a5
    syscall();
    80002d24:	00000097          	auipc	ra,0x0
    80002d28:	2d4080e7          	jalr	724(ra) # 80002ff8 <syscall>
  if(killed(p))
    80002d2c:	8526                	mv	a0,s1
    80002d2e:	00000097          	auipc	ra,0x0
    80002d32:	9a2080e7          	jalr	-1630(ra) # 800026d0 <killed>
    80002d36:	c911                	beqz	a0,80002d4a <usertrap+0xac>
    80002d38:	4901                	li	s2,0
    exit(-1);
    80002d3a:	557d                	li	a0,-1
    80002d3c:	00000097          	auipc	ra,0x0
    80002d40:	820080e7          	jalr	-2016(ra) # 8000255c <exit>
  if(which_dev == 2)
    80002d44:	4789                	li	a5,2
    80002d46:	04f90f63          	beq	s2,a5,80002da4 <usertrap+0x106>
  usertrapret();
    80002d4a:	00000097          	auipc	ra,0x0
    80002d4e:	dce080e7          	jalr	-562(ra) # 80002b18 <usertrapret>
}
    80002d52:	60e2                	ld	ra,24(sp)
    80002d54:	6442                	ld	s0,16(sp)
    80002d56:	64a2                	ld	s1,8(sp)
    80002d58:	6902                	ld	s2,0(sp)
    80002d5a:	6105                	addi	sp,sp,32
    80002d5c:	8082                	ret
      exit(-1);
    80002d5e:	557d                	li	a0,-1
    80002d60:	fffff097          	auipc	ra,0xfffff
    80002d64:	7fc080e7          	jalr	2044(ra) # 8000255c <exit>
    80002d68:	b765                	j	80002d10 <usertrap+0x72>
    asm volatile("csrr %0, scause" : "=r"(x));
    80002d6a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d6e:	5890                	lw	a2,48(s1)
    80002d70:	00005517          	auipc	a0,0x5
    80002d74:	69050513          	addi	a0,a0,1680 # 80008400 <__func__.1+0x3f8>
    80002d78:	ffffe097          	auipc	ra,0xffffe
    80002d7c:	844080e7          	jalr	-1980(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002d80:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80002d84:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d88:	00005517          	auipc	a0,0x5
    80002d8c:	6a850513          	addi	a0,a0,1704 # 80008430 <__func__.1+0x428>
    80002d90:	ffffe097          	auipc	ra,0xffffe
    80002d94:	82c080e7          	jalr	-2004(ra) # 800005bc <printf>
    setkilled(p);
    80002d98:	8526                	mv	a0,s1
    80002d9a:	00000097          	auipc	ra,0x0
    80002d9e:	90a080e7          	jalr	-1782(ra) # 800026a4 <setkilled>
    80002da2:	b769                	j	80002d2c <usertrap+0x8e>
    yield();
    80002da4:	fffff097          	auipc	ra,0xfffff
    80002da8:	648080e7          	jalr	1608(ra) # 800023ec <yield>
    80002dac:	bf79                	j	80002d4a <usertrap+0xac>

0000000080002dae <kerneltrap>:
{
    80002dae:	7179                	addi	sp,sp,-48
    80002db0:	f406                	sd	ra,40(sp)
    80002db2:	f022                	sd	s0,32(sp)
    80002db4:	ec26                	sd	s1,24(sp)
    80002db6:	e84a                	sd	s2,16(sp)
    80002db8:	e44e                	sd	s3,8(sp)
    80002dba:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002dbc:	14102973          	csrr	s2,sepc
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002dc0:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0, scause" : "=r"(x));
    80002dc4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002dc8:	1004f793          	andi	a5,s1,256
    80002dcc:	cb85                	beqz	a5,80002dfc <kerneltrap+0x4e>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002dce:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80002dd2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002dd4:	ef85                	bnez	a5,80002e0c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002dd6:	00000097          	auipc	ra,0x0
    80002dda:	e1e080e7          	jalr	-482(ra) # 80002bf4 <devintr>
    80002dde:	cd1d                	beqz	a0,80002e1c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002de0:	4789                	li	a5,2
    80002de2:	06f50a63          	beq	a0,a5,80002e56 <kerneltrap+0xa8>
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002de6:	14191073          	csrw	sepc,s2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002dea:	10049073          	csrw	sstatus,s1
}
    80002dee:	70a2                	ld	ra,40(sp)
    80002df0:	7402                	ld	s0,32(sp)
    80002df2:	64e2                	ld	s1,24(sp)
    80002df4:	6942                	ld	s2,16(sp)
    80002df6:	69a2                	ld	s3,8(sp)
    80002df8:	6145                	addi	sp,sp,48
    80002dfa:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002dfc:	00005517          	auipc	a0,0x5
    80002e00:	65450513          	addi	a0,a0,1620 # 80008450 <__func__.1+0x448>
    80002e04:	ffffd097          	auipc	ra,0xffffd
    80002e08:	75c080e7          	jalr	1884(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002e0c:	00005517          	auipc	a0,0x5
    80002e10:	66c50513          	addi	a0,a0,1644 # 80008478 <__func__.1+0x470>
    80002e14:	ffffd097          	auipc	ra,0xffffd
    80002e18:	74c080e7          	jalr	1868(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002e1c:	85ce                	mv	a1,s3
    80002e1e:	00005517          	auipc	a0,0x5
    80002e22:	67a50513          	addi	a0,a0,1658 # 80008498 <__func__.1+0x490>
    80002e26:	ffffd097          	auipc	ra,0xffffd
    80002e2a:	796080e7          	jalr	1942(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002e2e:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80002e32:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e36:	00005517          	auipc	a0,0x5
    80002e3a:	67250513          	addi	a0,a0,1650 # 800084a8 <__func__.1+0x4a0>
    80002e3e:	ffffd097          	auipc	ra,0xffffd
    80002e42:	77e080e7          	jalr	1918(ra) # 800005bc <printf>
    panic("kerneltrap");
    80002e46:	00005517          	auipc	a0,0x5
    80002e4a:	67a50513          	addi	a0,a0,1658 # 800084c0 <__func__.1+0x4b8>
    80002e4e:	ffffd097          	auipc	ra,0xffffd
    80002e52:	712080e7          	jalr	1810(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e56:	fffff097          	auipc	ra,0xfffff
    80002e5a:	e20080e7          	jalr	-480(ra) # 80001c76 <myproc>
    80002e5e:	d541                	beqz	a0,80002de6 <kerneltrap+0x38>
    80002e60:	fffff097          	auipc	ra,0xfffff
    80002e64:	e16080e7          	jalr	-490(ra) # 80001c76 <myproc>
    80002e68:	4d18                	lw	a4,24(a0)
    80002e6a:	4791                	li	a5,4
    80002e6c:	f6f71de3          	bne	a4,a5,80002de6 <kerneltrap+0x38>
    yield();
    80002e70:	fffff097          	auipc	ra,0xfffff
    80002e74:	57c080e7          	jalr	1404(ra) # 800023ec <yield>
    80002e78:	b7bd                	j	80002de6 <kerneltrap+0x38>

0000000080002e7a <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e7a:	1101                	addi	sp,sp,-32
    80002e7c:	ec06                	sd	ra,24(sp)
    80002e7e:	e822                	sd	s0,16(sp)
    80002e80:	e426                	sd	s1,8(sp)
    80002e82:	1000                	addi	s0,sp,32
    80002e84:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80002e86:	fffff097          	auipc	ra,0xfffff
    80002e8a:	df0080e7          	jalr	-528(ra) # 80001c76 <myproc>
    switch (n)
    80002e8e:	4795                	li	a5,5
    80002e90:	0497e163          	bltu	a5,s1,80002ed2 <argraw+0x58>
    80002e94:	048a                	slli	s1,s1,0x2
    80002e96:	00006717          	auipc	a4,0x6
    80002e9a:	9f270713          	addi	a4,a4,-1550 # 80008888 <states.0+0x30>
    80002e9e:	94ba                	add	s1,s1,a4
    80002ea0:	409c                	lw	a5,0(s1)
    80002ea2:	97ba                	add	a5,a5,a4
    80002ea4:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80002ea6:	6d3c                	ld	a5,88(a0)
    80002ea8:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002eaa:	60e2                	ld	ra,24(sp)
    80002eac:	6442                	ld	s0,16(sp)
    80002eae:	64a2                	ld	s1,8(sp)
    80002eb0:	6105                	addi	sp,sp,32
    80002eb2:	8082                	ret
        return p->trapframe->a1;
    80002eb4:	6d3c                	ld	a5,88(a0)
    80002eb6:	7fa8                	ld	a0,120(a5)
    80002eb8:	bfcd                	j	80002eaa <argraw+0x30>
        return p->trapframe->a2;
    80002eba:	6d3c                	ld	a5,88(a0)
    80002ebc:	63c8                	ld	a0,128(a5)
    80002ebe:	b7f5                	j	80002eaa <argraw+0x30>
        return p->trapframe->a3;
    80002ec0:	6d3c                	ld	a5,88(a0)
    80002ec2:	67c8                	ld	a0,136(a5)
    80002ec4:	b7dd                	j	80002eaa <argraw+0x30>
        return p->trapframe->a4;
    80002ec6:	6d3c                	ld	a5,88(a0)
    80002ec8:	6bc8                	ld	a0,144(a5)
    80002eca:	b7c5                	j	80002eaa <argraw+0x30>
        return p->trapframe->a5;
    80002ecc:	6d3c                	ld	a5,88(a0)
    80002ece:	6fc8                	ld	a0,152(a5)
    80002ed0:	bfe9                	j	80002eaa <argraw+0x30>
    panic("argraw");
    80002ed2:	00005517          	auipc	a0,0x5
    80002ed6:	5fe50513          	addi	a0,a0,1534 # 800084d0 <__func__.1+0x4c8>
    80002eda:	ffffd097          	auipc	ra,0xffffd
    80002ede:	686080e7          	jalr	1670(ra) # 80000560 <panic>

0000000080002ee2 <fetchaddr>:
{
    80002ee2:	1101                	addi	sp,sp,-32
    80002ee4:	ec06                	sd	ra,24(sp)
    80002ee6:	e822                	sd	s0,16(sp)
    80002ee8:	e426                	sd	s1,8(sp)
    80002eea:	e04a                	sd	s2,0(sp)
    80002eec:	1000                	addi	s0,sp,32
    80002eee:	84aa                	mv	s1,a0
    80002ef0:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002ef2:	fffff097          	auipc	ra,0xfffff
    80002ef6:	d84080e7          	jalr	-636(ra) # 80001c76 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002efa:	653c                	ld	a5,72(a0)
    80002efc:	02f4f863          	bgeu	s1,a5,80002f2c <fetchaddr+0x4a>
    80002f00:	00848713          	addi	a4,s1,8
    80002f04:	02e7e663          	bltu	a5,a4,80002f30 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f08:	46a1                	li	a3,8
    80002f0a:	8626                	mv	a2,s1
    80002f0c:	85ca                	mv	a1,s2
    80002f0e:	6928                	ld	a0,80(a0)
    80002f10:	fffff097          	auipc	ra,0xfffff
    80002f14:	926080e7          	jalr	-1754(ra) # 80001836 <copyin>
    80002f18:	00a03533          	snez	a0,a0
    80002f1c:	40a00533          	neg	a0,a0
}
    80002f20:	60e2                	ld	ra,24(sp)
    80002f22:	6442                	ld	s0,16(sp)
    80002f24:	64a2                	ld	s1,8(sp)
    80002f26:	6902                	ld	s2,0(sp)
    80002f28:	6105                	addi	sp,sp,32
    80002f2a:	8082                	ret
        return -1;
    80002f2c:	557d                	li	a0,-1
    80002f2e:	bfcd                	j	80002f20 <fetchaddr+0x3e>
    80002f30:	557d                	li	a0,-1
    80002f32:	b7fd                	j	80002f20 <fetchaddr+0x3e>

0000000080002f34 <fetchstr>:
{
    80002f34:	7179                	addi	sp,sp,-48
    80002f36:	f406                	sd	ra,40(sp)
    80002f38:	f022                	sd	s0,32(sp)
    80002f3a:	ec26                	sd	s1,24(sp)
    80002f3c:	e84a                	sd	s2,16(sp)
    80002f3e:	e44e                	sd	s3,8(sp)
    80002f40:	1800                	addi	s0,sp,48
    80002f42:	892a                	mv	s2,a0
    80002f44:	84ae                	mv	s1,a1
    80002f46:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80002f48:	fffff097          	auipc	ra,0xfffff
    80002f4c:	d2e080e7          	jalr	-722(ra) # 80001c76 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002f50:	86ce                	mv	a3,s3
    80002f52:	864a                	mv	a2,s2
    80002f54:	85a6                	mv	a1,s1
    80002f56:	6928                	ld	a0,80(a0)
    80002f58:	fffff097          	auipc	ra,0xfffff
    80002f5c:	96c080e7          	jalr	-1684(ra) # 800018c4 <copyinstr>
    80002f60:	00054e63          	bltz	a0,80002f7c <fetchstr+0x48>
    return strlen(buf);
    80002f64:	8526                	mv	a0,s1
    80002f66:	ffffe097          	auipc	ra,0xffffe
    80002f6a:	00a080e7          	jalr	10(ra) # 80000f70 <strlen>
}
    80002f6e:	70a2                	ld	ra,40(sp)
    80002f70:	7402                	ld	s0,32(sp)
    80002f72:	64e2                	ld	s1,24(sp)
    80002f74:	6942                	ld	s2,16(sp)
    80002f76:	69a2                	ld	s3,8(sp)
    80002f78:	6145                	addi	sp,sp,48
    80002f7a:	8082                	ret
        return -1;
    80002f7c:	557d                	li	a0,-1
    80002f7e:	bfc5                	j	80002f6e <fetchstr+0x3a>

0000000080002f80 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002f80:	1101                	addi	sp,sp,-32
    80002f82:	ec06                	sd	ra,24(sp)
    80002f84:	e822                	sd	s0,16(sp)
    80002f86:	e426                	sd	s1,8(sp)
    80002f88:	1000                	addi	s0,sp,32
    80002f8a:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002f8c:	00000097          	auipc	ra,0x0
    80002f90:	eee080e7          	jalr	-274(ra) # 80002e7a <argraw>
    80002f94:	c088                	sw	a0,0(s1)
}
    80002f96:	60e2                	ld	ra,24(sp)
    80002f98:	6442                	ld	s0,16(sp)
    80002f9a:	64a2                	ld	s1,8(sp)
    80002f9c:	6105                	addi	sp,sp,32
    80002f9e:	8082                	ret

0000000080002fa0 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002fa0:	1101                	addi	sp,sp,-32
    80002fa2:	ec06                	sd	ra,24(sp)
    80002fa4:	e822                	sd	s0,16(sp)
    80002fa6:	e426                	sd	s1,8(sp)
    80002fa8:	1000                	addi	s0,sp,32
    80002faa:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002fac:	00000097          	auipc	ra,0x0
    80002fb0:	ece080e7          	jalr	-306(ra) # 80002e7a <argraw>
    80002fb4:	e088                	sd	a0,0(s1)
}
    80002fb6:	60e2                	ld	ra,24(sp)
    80002fb8:	6442                	ld	s0,16(sp)
    80002fba:	64a2                	ld	s1,8(sp)
    80002fbc:	6105                	addi	sp,sp,32
    80002fbe:	8082                	ret

0000000080002fc0 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002fc0:	7179                	addi	sp,sp,-48
    80002fc2:	f406                	sd	ra,40(sp)
    80002fc4:	f022                	sd	s0,32(sp)
    80002fc6:	ec26                	sd	s1,24(sp)
    80002fc8:	e84a                	sd	s2,16(sp)
    80002fca:	1800                	addi	s0,sp,48
    80002fcc:	84ae                	mv	s1,a1
    80002fce:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80002fd0:	fd840593          	addi	a1,s0,-40
    80002fd4:	00000097          	auipc	ra,0x0
    80002fd8:	fcc080e7          	jalr	-52(ra) # 80002fa0 <argaddr>
    return fetchstr(addr, buf, max);
    80002fdc:	864a                	mv	a2,s2
    80002fde:	85a6                	mv	a1,s1
    80002fe0:	fd843503          	ld	a0,-40(s0)
    80002fe4:	00000097          	auipc	ra,0x0
    80002fe8:	f50080e7          	jalr	-176(ra) # 80002f34 <fetchstr>
}
    80002fec:	70a2                	ld	ra,40(sp)
    80002fee:	7402                	ld	s0,32(sp)
    80002ff0:	64e2                	ld	s1,24(sp)
    80002ff2:	6942                	ld	s2,16(sp)
    80002ff4:	6145                	addi	sp,sp,48
    80002ff6:	8082                	ret

0000000080002ff8 <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    80002ff8:	1101                	addi	sp,sp,-32
    80002ffa:	ec06                	sd	ra,24(sp)
    80002ffc:	e822                	sd	s0,16(sp)
    80002ffe:	e426                	sd	s1,8(sp)
    80003000:	e04a                	sd	s2,0(sp)
    80003002:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    80003004:	fffff097          	auipc	ra,0xfffff
    80003008:	c72080e7          	jalr	-910(ra) # 80001c76 <myproc>
    8000300c:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    8000300e:	05853903          	ld	s2,88(a0)
    80003012:	0a893783          	ld	a5,168(s2)
    80003016:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    8000301a:	37fd                	addiw	a5,a5,-1
    8000301c:	4765                	li	a4,25
    8000301e:	00f76f63          	bltu	a4,a5,8000303c <syscall+0x44>
    80003022:	00369713          	slli	a4,a3,0x3
    80003026:	00006797          	auipc	a5,0x6
    8000302a:	87a78793          	addi	a5,a5,-1926 # 800088a0 <syscalls>
    8000302e:	97ba                	add	a5,a5,a4
    80003030:	639c                	ld	a5,0(a5)
    80003032:	c789                	beqz	a5,8000303c <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80003034:	9782                	jalr	a5
    80003036:	06a93823          	sd	a0,112(s2)
    8000303a:	a839                	j	80003058 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    8000303c:	15848613          	addi	a2,s1,344
    80003040:	588c                	lw	a1,48(s1)
    80003042:	00005517          	auipc	a0,0x5
    80003046:	49650513          	addi	a0,a0,1174 # 800084d8 <__func__.1+0x4d0>
    8000304a:	ffffd097          	auipc	ra,0xffffd
    8000304e:	572080e7          	jalr	1394(ra) # 800005bc <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80003052:	6cbc                	ld	a5,88(s1)
    80003054:	577d                	li	a4,-1
    80003056:	fbb8                	sd	a4,112(a5)
    }
}
    80003058:	60e2                	ld	ra,24(sp)
    8000305a:	6442                	ld	s0,16(sp)
    8000305c:	64a2                	ld	s1,8(sp)
    8000305e:	6902                	ld	s2,0(sp)
    80003060:	6105                	addi	sp,sp,32
    80003062:	8082                	ret

0000000080003064 <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    80003064:	1101                	addi	sp,sp,-32
    80003066:	ec06                	sd	ra,24(sp)
    80003068:	e822                	sd	s0,16(sp)
    8000306a:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    8000306c:	fec40593          	addi	a1,s0,-20
    80003070:	4501                	li	a0,0
    80003072:	00000097          	auipc	ra,0x0
    80003076:	f0e080e7          	jalr	-242(ra) # 80002f80 <argint>
    exit(n);
    8000307a:	fec42503          	lw	a0,-20(s0)
    8000307e:	fffff097          	auipc	ra,0xfffff
    80003082:	4de080e7          	jalr	1246(ra) # 8000255c <exit>
    return 0; // not reached
}
    80003086:	4501                	li	a0,0
    80003088:	60e2                	ld	ra,24(sp)
    8000308a:	6442                	ld	s0,16(sp)
    8000308c:	6105                	addi	sp,sp,32
    8000308e:	8082                	ret

0000000080003090 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003090:	1141                	addi	sp,sp,-16
    80003092:	e406                	sd	ra,8(sp)
    80003094:	e022                	sd	s0,0(sp)
    80003096:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80003098:	fffff097          	auipc	ra,0xfffff
    8000309c:	bde080e7          	jalr	-1058(ra) # 80001c76 <myproc>
}
    800030a0:	5908                	lw	a0,48(a0)
    800030a2:	60a2                	ld	ra,8(sp)
    800030a4:	6402                	ld	s0,0(sp)
    800030a6:	0141                	addi	sp,sp,16
    800030a8:	8082                	ret

00000000800030aa <sys_fork>:

uint64
sys_fork(void)
{
    800030aa:	1141                	addi	sp,sp,-16
    800030ac:	e406                	sd	ra,8(sp)
    800030ae:	e022                	sd	s0,0(sp)
    800030b0:	0800                	addi	s0,sp,16
    return fork();
    800030b2:	fffff097          	auipc	ra,0xfffff
    800030b6:	112080e7          	jalr	274(ra) # 800021c4 <fork>
}
    800030ba:	60a2                	ld	ra,8(sp)
    800030bc:	6402                	ld	s0,0(sp)
    800030be:	0141                	addi	sp,sp,16
    800030c0:	8082                	ret

00000000800030c2 <sys_wait>:

uint64
sys_wait(void)
{
    800030c2:	1101                	addi	sp,sp,-32
    800030c4:	ec06                	sd	ra,24(sp)
    800030c6:	e822                	sd	s0,16(sp)
    800030c8:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    800030ca:	fe840593          	addi	a1,s0,-24
    800030ce:	4501                	li	a0,0
    800030d0:	00000097          	auipc	ra,0x0
    800030d4:	ed0080e7          	jalr	-304(ra) # 80002fa0 <argaddr>
    return wait(p);
    800030d8:	fe843503          	ld	a0,-24(s0)
    800030dc:	fffff097          	auipc	ra,0xfffff
    800030e0:	626080e7          	jalr	1574(ra) # 80002702 <wait>
}
    800030e4:	60e2                	ld	ra,24(sp)
    800030e6:	6442                	ld	s0,16(sp)
    800030e8:	6105                	addi	sp,sp,32
    800030ea:	8082                	ret

00000000800030ec <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800030ec:	7179                	addi	sp,sp,-48
    800030ee:	f406                	sd	ra,40(sp)
    800030f0:	f022                	sd	s0,32(sp)
    800030f2:	ec26                	sd	s1,24(sp)
    800030f4:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    800030f6:	fdc40593          	addi	a1,s0,-36
    800030fa:	4501                	li	a0,0
    800030fc:	00000097          	auipc	ra,0x0
    80003100:	e84080e7          	jalr	-380(ra) # 80002f80 <argint>
    addr = myproc()->sz;
    80003104:	fffff097          	auipc	ra,0xfffff
    80003108:	b72080e7          	jalr	-1166(ra) # 80001c76 <myproc>
    8000310c:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    8000310e:	fdc42503          	lw	a0,-36(s0)
    80003112:	fffff097          	auipc	ra,0xfffff
    80003116:	ebe080e7          	jalr	-322(ra) # 80001fd0 <growproc>
    8000311a:	00054863          	bltz	a0,8000312a <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    8000311e:	8526                	mv	a0,s1
    80003120:	70a2                	ld	ra,40(sp)
    80003122:	7402                	ld	s0,32(sp)
    80003124:	64e2                	ld	s1,24(sp)
    80003126:	6145                	addi	sp,sp,48
    80003128:	8082                	ret
        return -1;
    8000312a:	54fd                	li	s1,-1
    8000312c:	bfcd                	j	8000311e <sys_sbrk+0x32>

000000008000312e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000312e:	7139                	addi	sp,sp,-64
    80003130:	fc06                	sd	ra,56(sp)
    80003132:	f822                	sd	s0,48(sp)
    80003134:	f04a                	sd	s2,32(sp)
    80003136:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    80003138:	fcc40593          	addi	a1,s0,-52
    8000313c:	4501                	li	a0,0
    8000313e:	00000097          	auipc	ra,0x0
    80003142:	e42080e7          	jalr	-446(ra) # 80002f80 <argint>
    acquire(&tickslock);
    80003146:	00016517          	auipc	a0,0x16
    8000314a:	47a50513          	addi	a0,a0,1146 # 800195c0 <tickslock>
    8000314e:	ffffe097          	auipc	ra,0xffffe
    80003152:	bb2080e7          	jalr	-1102(ra) # 80000d00 <acquire>
    ticks0 = ticks;
    80003156:	00008917          	auipc	s2,0x8
    8000315a:	3ca92903          	lw	s2,970(s2) # 8000b520 <ticks>
    while (ticks - ticks0 < n)
    8000315e:	fcc42783          	lw	a5,-52(s0)
    80003162:	c3b9                	beqz	a5,800031a8 <sys_sleep+0x7a>
    80003164:	f426                	sd	s1,40(sp)
    80003166:	ec4e                	sd	s3,24(sp)
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    80003168:	00016997          	auipc	s3,0x16
    8000316c:	45898993          	addi	s3,s3,1112 # 800195c0 <tickslock>
    80003170:	00008497          	auipc	s1,0x8
    80003174:	3b048493          	addi	s1,s1,944 # 8000b520 <ticks>
        if (killed(myproc()))
    80003178:	fffff097          	auipc	ra,0xfffff
    8000317c:	afe080e7          	jalr	-1282(ra) # 80001c76 <myproc>
    80003180:	fffff097          	auipc	ra,0xfffff
    80003184:	550080e7          	jalr	1360(ra) # 800026d0 <killed>
    80003188:	ed15                	bnez	a0,800031c4 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    8000318a:	85ce                	mv	a1,s3
    8000318c:	8526                	mv	a0,s1
    8000318e:	fffff097          	auipc	ra,0xfffff
    80003192:	29a080e7          	jalr	666(ra) # 80002428 <sleep>
    while (ticks - ticks0 < n)
    80003196:	409c                	lw	a5,0(s1)
    80003198:	412787bb          	subw	a5,a5,s2
    8000319c:	fcc42703          	lw	a4,-52(s0)
    800031a0:	fce7ece3          	bltu	a5,a4,80003178 <sys_sleep+0x4a>
    800031a4:	74a2                	ld	s1,40(sp)
    800031a6:	69e2                	ld	s3,24(sp)
    }
    release(&tickslock);
    800031a8:	00016517          	auipc	a0,0x16
    800031ac:	41850513          	addi	a0,a0,1048 # 800195c0 <tickslock>
    800031b0:	ffffe097          	auipc	ra,0xffffe
    800031b4:	c04080e7          	jalr	-1020(ra) # 80000db4 <release>
    return 0;
    800031b8:	4501                	li	a0,0
}
    800031ba:	70e2                	ld	ra,56(sp)
    800031bc:	7442                	ld	s0,48(sp)
    800031be:	7902                	ld	s2,32(sp)
    800031c0:	6121                	addi	sp,sp,64
    800031c2:	8082                	ret
            release(&tickslock);
    800031c4:	00016517          	auipc	a0,0x16
    800031c8:	3fc50513          	addi	a0,a0,1020 # 800195c0 <tickslock>
    800031cc:	ffffe097          	auipc	ra,0xffffe
    800031d0:	be8080e7          	jalr	-1048(ra) # 80000db4 <release>
            return -1;
    800031d4:	557d                	li	a0,-1
    800031d6:	74a2                	ld	s1,40(sp)
    800031d8:	69e2                	ld	s3,24(sp)
    800031da:	b7c5                	j	800031ba <sys_sleep+0x8c>

00000000800031dc <sys_kill>:

uint64
sys_kill(void)
{
    800031dc:	1101                	addi	sp,sp,-32
    800031de:	ec06                	sd	ra,24(sp)
    800031e0:	e822                	sd	s0,16(sp)
    800031e2:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    800031e4:	fec40593          	addi	a1,s0,-20
    800031e8:	4501                	li	a0,0
    800031ea:	00000097          	auipc	ra,0x0
    800031ee:	d96080e7          	jalr	-618(ra) # 80002f80 <argint>
    return kill(pid);
    800031f2:	fec42503          	lw	a0,-20(s0)
    800031f6:	fffff097          	auipc	ra,0xfffff
    800031fa:	43c080e7          	jalr	1084(ra) # 80002632 <kill>
}
    800031fe:	60e2                	ld	ra,24(sp)
    80003200:	6442                	ld	s0,16(sp)
    80003202:	6105                	addi	sp,sp,32
    80003204:	8082                	ret

0000000080003206 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003206:	1101                	addi	sp,sp,-32
    80003208:	ec06                	sd	ra,24(sp)
    8000320a:	e822                	sd	s0,16(sp)
    8000320c:	e426                	sd	s1,8(sp)
    8000320e:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80003210:	00016517          	auipc	a0,0x16
    80003214:	3b050513          	addi	a0,a0,944 # 800195c0 <tickslock>
    80003218:	ffffe097          	auipc	ra,0xffffe
    8000321c:	ae8080e7          	jalr	-1304(ra) # 80000d00 <acquire>
    xticks = ticks;
    80003220:	00008497          	auipc	s1,0x8
    80003224:	3004a483          	lw	s1,768(s1) # 8000b520 <ticks>
    release(&tickslock);
    80003228:	00016517          	auipc	a0,0x16
    8000322c:	39850513          	addi	a0,a0,920 # 800195c0 <tickslock>
    80003230:	ffffe097          	auipc	ra,0xffffe
    80003234:	b84080e7          	jalr	-1148(ra) # 80000db4 <release>
    return xticks;
}
    80003238:	02049513          	slli	a0,s1,0x20
    8000323c:	9101                	srli	a0,a0,0x20
    8000323e:	60e2                	ld	ra,24(sp)
    80003240:	6442                	ld	s0,16(sp)
    80003242:	64a2                	ld	s1,8(sp)
    80003244:	6105                	addi	sp,sp,32
    80003246:	8082                	ret

0000000080003248 <sys_ps>:

void *
sys_ps(void)
{
    80003248:	1101                	addi	sp,sp,-32
    8000324a:	ec06                	sd	ra,24(sp)
    8000324c:	e822                	sd	s0,16(sp)
    8000324e:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    80003250:	fe042623          	sw	zero,-20(s0)
    80003254:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    80003258:	fec40593          	addi	a1,s0,-20
    8000325c:	4501                	li	a0,0
    8000325e:	00000097          	auipc	ra,0x0
    80003262:	d22080e7          	jalr	-734(ra) # 80002f80 <argint>
    argint(1, &count);
    80003266:	fe840593          	addi	a1,s0,-24
    8000326a:	4505                	li	a0,1
    8000326c:	00000097          	auipc	ra,0x0
    80003270:	d14080e7          	jalr	-748(ra) # 80002f80 <argint>
    return ps((uint8)start, (uint8)count);
    80003274:	fe844583          	lbu	a1,-24(s0)
    80003278:	fec44503          	lbu	a0,-20(s0)
    8000327c:	fffff097          	auipc	ra,0xfffff
    80003280:	db0080e7          	jalr	-592(ra) # 8000202c <ps>
}
    80003284:	60e2                	ld	ra,24(sp)
    80003286:	6442                	ld	s0,16(sp)
    80003288:	6105                	addi	sp,sp,32
    8000328a:	8082                	ret

000000008000328c <sys_schedls>:

uint64 sys_schedls(void)
{
    8000328c:	1141                	addi	sp,sp,-16
    8000328e:	e406                	sd	ra,8(sp)
    80003290:	e022                	sd	s0,0(sp)
    80003292:	0800                	addi	s0,sp,16
    schedls();
    80003294:	fffff097          	auipc	ra,0xfffff
    80003298:	6f8080e7          	jalr	1784(ra) # 8000298c <schedls>
    return 0;
}
    8000329c:	4501                	li	a0,0
    8000329e:	60a2                	ld	ra,8(sp)
    800032a0:	6402                	ld	s0,0(sp)
    800032a2:	0141                	addi	sp,sp,16
    800032a4:	8082                	ret

00000000800032a6 <sys_schedset>:

uint64 sys_schedset(void)
{
    800032a6:	1101                	addi	sp,sp,-32
    800032a8:	ec06                	sd	ra,24(sp)
    800032aa:	e822                	sd	s0,16(sp)
    800032ac:	1000                	addi	s0,sp,32
    int id = 0;
    800032ae:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    800032b2:	fec40593          	addi	a1,s0,-20
    800032b6:	4501                	li	a0,0
    800032b8:	00000097          	auipc	ra,0x0
    800032bc:	cc8080e7          	jalr	-824(ra) # 80002f80 <argint>
    schedset(id - 1);
    800032c0:	fec42503          	lw	a0,-20(s0)
    800032c4:	357d                	addiw	a0,a0,-1
    800032c6:	fffff097          	auipc	ra,0xfffff
    800032ca:	75c080e7          	jalr	1884(ra) # 80002a22 <schedset>
    return 0;
}
    800032ce:	4501                	li	a0,0
    800032d0:	60e2                	ld	ra,24(sp)
    800032d2:	6442                	ld	s0,16(sp)
    800032d4:	6105                	addi	sp,sp,32
    800032d6:	8082                	ret

00000000800032d8 <sys_va2pa>:

uint64 sys_va2pa(void)
{
    800032d8:	7179                	addi	sp,sp,-48
    800032da:	f406                	sd	ra,40(sp)
    800032dc:	f022                	sd	s0,32(sp)
    800032de:	1800                	addi	s0,sp,48
    struct proc* proc;
    uint64 va, pid = 0;
    800032e0:	fc043823          	sd	zero,-48(s0)

    argaddr(0, &va);
    800032e4:	fd840593          	addi	a1,s0,-40
    800032e8:	4501                	li	a0,0
    800032ea:	00000097          	auipc	ra,0x0
    800032ee:	cb6080e7          	jalr	-842(ra) # 80002fa0 <argaddr>
    argaddr(1, &pid);
    800032f2:	fd040593          	addi	a1,s0,-48
    800032f6:	4505                	li	a0,1
    800032f8:	00000097          	auipc	ra,0x0
    800032fc:	ca8080e7          	jalr	-856(ra) # 80002fa0 <argaddr>

    if (pid == 0){
    80003300:	fd043783          	ld	a5,-48(s0)
    80003304:	cf89                	beqz	a5,8000331e <sys_va2pa+0x46>
        acquire(&proc->lock);
        pid = proc->pid;
        release(&proc->lock);
    }
    
    return va2pa(va, pid);
    80003306:	fd043583          	ld	a1,-48(s0)
    8000330a:	fd843503          	ld	a0,-40(s0)
    8000330e:	fffff097          	auipc	ra,0xfffff
    80003312:	8cc080e7          	jalr	-1844(ra) # 80001bda <va2pa>
}
    80003316:	70a2                	ld	ra,40(sp)
    80003318:	7402                	ld	s0,32(sp)
    8000331a:	6145                	addi	sp,sp,48
    8000331c:	8082                	ret
    8000331e:	ec26                	sd	s1,24(sp)
        proc = myproc();
    80003320:	fffff097          	auipc	ra,0xfffff
    80003324:	956080e7          	jalr	-1706(ra) # 80001c76 <myproc>
    80003328:	84aa                	mv	s1,a0
        acquire(&proc->lock);
    8000332a:	ffffe097          	auipc	ra,0xffffe
    8000332e:	9d6080e7          	jalr	-1578(ra) # 80000d00 <acquire>
        pid = proc->pid;
    80003332:	589c                	lw	a5,48(s1)
    80003334:	fcf43823          	sd	a5,-48(s0)
        release(&proc->lock);
    80003338:	8526                	mv	a0,s1
    8000333a:	ffffe097          	auipc	ra,0xffffe
    8000333e:	a7a080e7          	jalr	-1414(ra) # 80000db4 <release>
    80003342:	64e2                	ld	s1,24(sp)
    80003344:	b7c9                	j	80003306 <sys_va2pa+0x2e>

0000000080003346 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    80003346:	1141                	addi	sp,sp,-16
    80003348:	e406                	sd	ra,8(sp)
    8000334a:	e022                	sd	s0,0(sp)
    8000334c:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    8000334e:	00008597          	auipc	a1,0x8
    80003352:	1aa5b583          	ld	a1,426(a1) # 8000b4f8 <FREE_PAGES>
    80003356:	00005517          	auipc	a0,0x5
    8000335a:	1a250513          	addi	a0,a0,418 # 800084f8 <__func__.1+0x4f0>
    8000335e:	ffffd097          	auipc	ra,0xffffd
    80003362:	25e080e7          	jalr	606(ra) # 800005bc <printf>
    return 0;
    80003366:	4501                	li	a0,0
    80003368:	60a2                	ld	ra,8(sp)
    8000336a:	6402                	ld	s0,0(sp)
    8000336c:	0141                	addi	sp,sp,16
    8000336e:	8082                	ret

0000000080003370 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003370:	7179                	addi	sp,sp,-48
    80003372:	f406                	sd	ra,40(sp)
    80003374:	f022                	sd	s0,32(sp)
    80003376:	ec26                	sd	s1,24(sp)
    80003378:	e84a                	sd	s2,16(sp)
    8000337a:	e44e                	sd	s3,8(sp)
    8000337c:	e052                	sd	s4,0(sp)
    8000337e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003380:	00005597          	auipc	a1,0x5
    80003384:	18058593          	addi	a1,a1,384 # 80008500 <__func__.1+0x4f8>
    80003388:	00016517          	auipc	a0,0x16
    8000338c:	25050513          	addi	a0,a0,592 # 800195d8 <bcache>
    80003390:	ffffe097          	auipc	ra,0xffffe
    80003394:	8e0080e7          	jalr	-1824(ra) # 80000c70 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003398:	0001e797          	auipc	a5,0x1e
    8000339c:	24078793          	addi	a5,a5,576 # 800215d8 <bcache+0x8000>
    800033a0:	0001e717          	auipc	a4,0x1e
    800033a4:	4a070713          	addi	a4,a4,1184 # 80021840 <bcache+0x8268>
    800033a8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800033ac:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033b0:	00016497          	auipc	s1,0x16
    800033b4:	24048493          	addi	s1,s1,576 # 800195f0 <bcache+0x18>
    b->next = bcache.head.next;
    800033b8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800033ba:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800033bc:	00005a17          	auipc	s4,0x5
    800033c0:	14ca0a13          	addi	s4,s4,332 # 80008508 <__func__.1+0x500>
    b->next = bcache.head.next;
    800033c4:	2b893783          	ld	a5,696(s2)
    800033c8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033ca:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033ce:	85d2                	mv	a1,s4
    800033d0:	01048513          	addi	a0,s1,16
    800033d4:	00001097          	auipc	ra,0x1
    800033d8:	4e8080e7          	jalr	1256(ra) # 800048bc <initsleeplock>
    bcache.head.next->prev = b;
    800033dc:	2b893783          	ld	a5,696(s2)
    800033e0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800033e2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033e6:	45848493          	addi	s1,s1,1112
    800033ea:	fd349de3          	bne	s1,s3,800033c4 <binit+0x54>
  }
}
    800033ee:	70a2                	ld	ra,40(sp)
    800033f0:	7402                	ld	s0,32(sp)
    800033f2:	64e2                	ld	s1,24(sp)
    800033f4:	6942                	ld	s2,16(sp)
    800033f6:	69a2                	ld	s3,8(sp)
    800033f8:	6a02                	ld	s4,0(sp)
    800033fa:	6145                	addi	sp,sp,48
    800033fc:	8082                	ret

00000000800033fe <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033fe:	7179                	addi	sp,sp,-48
    80003400:	f406                	sd	ra,40(sp)
    80003402:	f022                	sd	s0,32(sp)
    80003404:	ec26                	sd	s1,24(sp)
    80003406:	e84a                	sd	s2,16(sp)
    80003408:	e44e                	sd	s3,8(sp)
    8000340a:	1800                	addi	s0,sp,48
    8000340c:	892a                	mv	s2,a0
    8000340e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003410:	00016517          	auipc	a0,0x16
    80003414:	1c850513          	addi	a0,a0,456 # 800195d8 <bcache>
    80003418:	ffffe097          	auipc	ra,0xffffe
    8000341c:	8e8080e7          	jalr	-1816(ra) # 80000d00 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003420:	0001e497          	auipc	s1,0x1e
    80003424:	4704b483          	ld	s1,1136(s1) # 80021890 <bcache+0x82b8>
    80003428:	0001e797          	auipc	a5,0x1e
    8000342c:	41878793          	addi	a5,a5,1048 # 80021840 <bcache+0x8268>
    80003430:	02f48f63          	beq	s1,a5,8000346e <bread+0x70>
    80003434:	873e                	mv	a4,a5
    80003436:	a021                	j	8000343e <bread+0x40>
    80003438:	68a4                	ld	s1,80(s1)
    8000343a:	02e48a63          	beq	s1,a4,8000346e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000343e:	449c                	lw	a5,8(s1)
    80003440:	ff279ce3          	bne	a5,s2,80003438 <bread+0x3a>
    80003444:	44dc                	lw	a5,12(s1)
    80003446:	ff3799e3          	bne	a5,s3,80003438 <bread+0x3a>
      b->refcnt++;
    8000344a:	40bc                	lw	a5,64(s1)
    8000344c:	2785                	addiw	a5,a5,1
    8000344e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003450:	00016517          	auipc	a0,0x16
    80003454:	18850513          	addi	a0,a0,392 # 800195d8 <bcache>
    80003458:	ffffe097          	auipc	ra,0xffffe
    8000345c:	95c080e7          	jalr	-1700(ra) # 80000db4 <release>
      acquiresleep(&b->lock);
    80003460:	01048513          	addi	a0,s1,16
    80003464:	00001097          	auipc	ra,0x1
    80003468:	492080e7          	jalr	1170(ra) # 800048f6 <acquiresleep>
      return b;
    8000346c:	a8b9                	j	800034ca <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000346e:	0001e497          	auipc	s1,0x1e
    80003472:	41a4b483          	ld	s1,1050(s1) # 80021888 <bcache+0x82b0>
    80003476:	0001e797          	auipc	a5,0x1e
    8000347a:	3ca78793          	addi	a5,a5,970 # 80021840 <bcache+0x8268>
    8000347e:	00f48863          	beq	s1,a5,8000348e <bread+0x90>
    80003482:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003484:	40bc                	lw	a5,64(s1)
    80003486:	cf81                	beqz	a5,8000349e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003488:	64a4                	ld	s1,72(s1)
    8000348a:	fee49de3          	bne	s1,a4,80003484 <bread+0x86>
  panic("bget: no buffers");
    8000348e:	00005517          	auipc	a0,0x5
    80003492:	08250513          	addi	a0,a0,130 # 80008510 <__func__.1+0x508>
    80003496:	ffffd097          	auipc	ra,0xffffd
    8000349a:	0ca080e7          	jalr	202(ra) # 80000560 <panic>
      b->dev = dev;
    8000349e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800034a2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800034a6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800034aa:	4785                	li	a5,1
    800034ac:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034ae:	00016517          	auipc	a0,0x16
    800034b2:	12a50513          	addi	a0,a0,298 # 800195d8 <bcache>
    800034b6:	ffffe097          	auipc	ra,0xffffe
    800034ba:	8fe080e7          	jalr	-1794(ra) # 80000db4 <release>
      acquiresleep(&b->lock);
    800034be:	01048513          	addi	a0,s1,16
    800034c2:	00001097          	auipc	ra,0x1
    800034c6:	434080e7          	jalr	1076(ra) # 800048f6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034ca:	409c                	lw	a5,0(s1)
    800034cc:	cb89                	beqz	a5,800034de <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034ce:	8526                	mv	a0,s1
    800034d0:	70a2                	ld	ra,40(sp)
    800034d2:	7402                	ld	s0,32(sp)
    800034d4:	64e2                	ld	s1,24(sp)
    800034d6:	6942                	ld	s2,16(sp)
    800034d8:	69a2                	ld	s3,8(sp)
    800034da:	6145                	addi	sp,sp,48
    800034dc:	8082                	ret
    virtio_disk_rw(b, 0);
    800034de:	4581                	li	a1,0
    800034e0:	8526                	mv	a0,s1
    800034e2:	00003097          	auipc	ra,0x3
    800034e6:	0f6080e7          	jalr	246(ra) # 800065d8 <virtio_disk_rw>
    b->valid = 1;
    800034ea:	4785                	li	a5,1
    800034ec:	c09c                	sw	a5,0(s1)
  return b;
    800034ee:	b7c5                	j	800034ce <bread+0xd0>

00000000800034f0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034f0:	1101                	addi	sp,sp,-32
    800034f2:	ec06                	sd	ra,24(sp)
    800034f4:	e822                	sd	s0,16(sp)
    800034f6:	e426                	sd	s1,8(sp)
    800034f8:	1000                	addi	s0,sp,32
    800034fa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034fc:	0541                	addi	a0,a0,16
    800034fe:	00001097          	auipc	ra,0x1
    80003502:	492080e7          	jalr	1170(ra) # 80004990 <holdingsleep>
    80003506:	cd01                	beqz	a0,8000351e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003508:	4585                	li	a1,1
    8000350a:	8526                	mv	a0,s1
    8000350c:	00003097          	auipc	ra,0x3
    80003510:	0cc080e7          	jalr	204(ra) # 800065d8 <virtio_disk_rw>
}
    80003514:	60e2                	ld	ra,24(sp)
    80003516:	6442                	ld	s0,16(sp)
    80003518:	64a2                	ld	s1,8(sp)
    8000351a:	6105                	addi	sp,sp,32
    8000351c:	8082                	ret
    panic("bwrite");
    8000351e:	00005517          	auipc	a0,0x5
    80003522:	00a50513          	addi	a0,a0,10 # 80008528 <__func__.1+0x520>
    80003526:	ffffd097          	auipc	ra,0xffffd
    8000352a:	03a080e7          	jalr	58(ra) # 80000560 <panic>

000000008000352e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000352e:	1101                	addi	sp,sp,-32
    80003530:	ec06                	sd	ra,24(sp)
    80003532:	e822                	sd	s0,16(sp)
    80003534:	e426                	sd	s1,8(sp)
    80003536:	e04a                	sd	s2,0(sp)
    80003538:	1000                	addi	s0,sp,32
    8000353a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000353c:	01050913          	addi	s2,a0,16
    80003540:	854a                	mv	a0,s2
    80003542:	00001097          	auipc	ra,0x1
    80003546:	44e080e7          	jalr	1102(ra) # 80004990 <holdingsleep>
    8000354a:	c925                	beqz	a0,800035ba <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    8000354c:	854a                	mv	a0,s2
    8000354e:	00001097          	auipc	ra,0x1
    80003552:	3fe080e7          	jalr	1022(ra) # 8000494c <releasesleep>

  acquire(&bcache.lock);
    80003556:	00016517          	auipc	a0,0x16
    8000355a:	08250513          	addi	a0,a0,130 # 800195d8 <bcache>
    8000355e:	ffffd097          	auipc	ra,0xffffd
    80003562:	7a2080e7          	jalr	1954(ra) # 80000d00 <acquire>
  b->refcnt--;
    80003566:	40bc                	lw	a5,64(s1)
    80003568:	37fd                	addiw	a5,a5,-1
    8000356a:	0007871b          	sext.w	a4,a5
    8000356e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003570:	e71d                	bnez	a4,8000359e <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003572:	68b8                	ld	a4,80(s1)
    80003574:	64bc                	ld	a5,72(s1)
    80003576:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003578:	68b8                	ld	a4,80(s1)
    8000357a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000357c:	0001e797          	auipc	a5,0x1e
    80003580:	05c78793          	addi	a5,a5,92 # 800215d8 <bcache+0x8000>
    80003584:	2b87b703          	ld	a4,696(a5)
    80003588:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000358a:	0001e717          	auipc	a4,0x1e
    8000358e:	2b670713          	addi	a4,a4,694 # 80021840 <bcache+0x8268>
    80003592:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003594:	2b87b703          	ld	a4,696(a5)
    80003598:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000359a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000359e:	00016517          	auipc	a0,0x16
    800035a2:	03a50513          	addi	a0,a0,58 # 800195d8 <bcache>
    800035a6:	ffffe097          	auipc	ra,0xffffe
    800035aa:	80e080e7          	jalr	-2034(ra) # 80000db4 <release>
}
    800035ae:	60e2                	ld	ra,24(sp)
    800035b0:	6442                	ld	s0,16(sp)
    800035b2:	64a2                	ld	s1,8(sp)
    800035b4:	6902                	ld	s2,0(sp)
    800035b6:	6105                	addi	sp,sp,32
    800035b8:	8082                	ret
    panic("brelse");
    800035ba:	00005517          	auipc	a0,0x5
    800035be:	f7650513          	addi	a0,a0,-138 # 80008530 <__func__.1+0x528>
    800035c2:	ffffd097          	auipc	ra,0xffffd
    800035c6:	f9e080e7          	jalr	-98(ra) # 80000560 <panic>

00000000800035ca <bpin>:

void
bpin(struct buf *b) {
    800035ca:	1101                	addi	sp,sp,-32
    800035cc:	ec06                	sd	ra,24(sp)
    800035ce:	e822                	sd	s0,16(sp)
    800035d0:	e426                	sd	s1,8(sp)
    800035d2:	1000                	addi	s0,sp,32
    800035d4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035d6:	00016517          	auipc	a0,0x16
    800035da:	00250513          	addi	a0,a0,2 # 800195d8 <bcache>
    800035de:	ffffd097          	auipc	ra,0xffffd
    800035e2:	722080e7          	jalr	1826(ra) # 80000d00 <acquire>
  b->refcnt++;
    800035e6:	40bc                	lw	a5,64(s1)
    800035e8:	2785                	addiw	a5,a5,1
    800035ea:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035ec:	00016517          	auipc	a0,0x16
    800035f0:	fec50513          	addi	a0,a0,-20 # 800195d8 <bcache>
    800035f4:	ffffd097          	auipc	ra,0xffffd
    800035f8:	7c0080e7          	jalr	1984(ra) # 80000db4 <release>
}
    800035fc:	60e2                	ld	ra,24(sp)
    800035fe:	6442                	ld	s0,16(sp)
    80003600:	64a2                	ld	s1,8(sp)
    80003602:	6105                	addi	sp,sp,32
    80003604:	8082                	ret

0000000080003606 <bunpin>:

void
bunpin(struct buf *b) {
    80003606:	1101                	addi	sp,sp,-32
    80003608:	ec06                	sd	ra,24(sp)
    8000360a:	e822                	sd	s0,16(sp)
    8000360c:	e426                	sd	s1,8(sp)
    8000360e:	1000                	addi	s0,sp,32
    80003610:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003612:	00016517          	auipc	a0,0x16
    80003616:	fc650513          	addi	a0,a0,-58 # 800195d8 <bcache>
    8000361a:	ffffd097          	auipc	ra,0xffffd
    8000361e:	6e6080e7          	jalr	1766(ra) # 80000d00 <acquire>
  b->refcnt--;
    80003622:	40bc                	lw	a5,64(s1)
    80003624:	37fd                	addiw	a5,a5,-1
    80003626:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003628:	00016517          	auipc	a0,0x16
    8000362c:	fb050513          	addi	a0,a0,-80 # 800195d8 <bcache>
    80003630:	ffffd097          	auipc	ra,0xffffd
    80003634:	784080e7          	jalr	1924(ra) # 80000db4 <release>
}
    80003638:	60e2                	ld	ra,24(sp)
    8000363a:	6442                	ld	s0,16(sp)
    8000363c:	64a2                	ld	s1,8(sp)
    8000363e:	6105                	addi	sp,sp,32
    80003640:	8082                	ret

0000000080003642 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003642:	1101                	addi	sp,sp,-32
    80003644:	ec06                	sd	ra,24(sp)
    80003646:	e822                	sd	s0,16(sp)
    80003648:	e426                	sd	s1,8(sp)
    8000364a:	e04a                	sd	s2,0(sp)
    8000364c:	1000                	addi	s0,sp,32
    8000364e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003650:	00d5d59b          	srliw	a1,a1,0xd
    80003654:	0001e797          	auipc	a5,0x1e
    80003658:	6607a783          	lw	a5,1632(a5) # 80021cb4 <sb+0x1c>
    8000365c:	9dbd                	addw	a1,a1,a5
    8000365e:	00000097          	auipc	ra,0x0
    80003662:	da0080e7          	jalr	-608(ra) # 800033fe <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003666:	0074f713          	andi	a4,s1,7
    8000366a:	4785                	li	a5,1
    8000366c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003670:	14ce                	slli	s1,s1,0x33
    80003672:	90d9                	srli	s1,s1,0x36
    80003674:	00950733          	add	a4,a0,s1
    80003678:	05874703          	lbu	a4,88(a4)
    8000367c:	00e7f6b3          	and	a3,a5,a4
    80003680:	c69d                	beqz	a3,800036ae <bfree+0x6c>
    80003682:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003684:	94aa                	add	s1,s1,a0
    80003686:	fff7c793          	not	a5,a5
    8000368a:	8f7d                	and	a4,a4,a5
    8000368c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003690:	00001097          	auipc	ra,0x1
    80003694:	148080e7          	jalr	328(ra) # 800047d8 <log_write>
  brelse(bp);
    80003698:	854a                	mv	a0,s2
    8000369a:	00000097          	auipc	ra,0x0
    8000369e:	e94080e7          	jalr	-364(ra) # 8000352e <brelse>
}
    800036a2:	60e2                	ld	ra,24(sp)
    800036a4:	6442                	ld	s0,16(sp)
    800036a6:	64a2                	ld	s1,8(sp)
    800036a8:	6902                	ld	s2,0(sp)
    800036aa:	6105                	addi	sp,sp,32
    800036ac:	8082                	ret
    panic("freeing free block");
    800036ae:	00005517          	auipc	a0,0x5
    800036b2:	e8a50513          	addi	a0,a0,-374 # 80008538 <__func__.1+0x530>
    800036b6:	ffffd097          	auipc	ra,0xffffd
    800036ba:	eaa080e7          	jalr	-342(ra) # 80000560 <panic>

00000000800036be <balloc>:
{
    800036be:	711d                	addi	sp,sp,-96
    800036c0:	ec86                	sd	ra,88(sp)
    800036c2:	e8a2                	sd	s0,80(sp)
    800036c4:	e4a6                	sd	s1,72(sp)
    800036c6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036c8:	0001e797          	auipc	a5,0x1e
    800036cc:	5d47a783          	lw	a5,1492(a5) # 80021c9c <sb+0x4>
    800036d0:	10078f63          	beqz	a5,800037ee <balloc+0x130>
    800036d4:	e0ca                	sd	s2,64(sp)
    800036d6:	fc4e                	sd	s3,56(sp)
    800036d8:	f852                	sd	s4,48(sp)
    800036da:	f456                	sd	s5,40(sp)
    800036dc:	f05a                	sd	s6,32(sp)
    800036de:	ec5e                	sd	s7,24(sp)
    800036e0:	e862                	sd	s8,16(sp)
    800036e2:	e466                	sd	s9,8(sp)
    800036e4:	8baa                	mv	s7,a0
    800036e6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036e8:	0001eb17          	auipc	s6,0x1e
    800036ec:	5b0b0b13          	addi	s6,s6,1456 # 80021c98 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036f0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036f2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036f4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036f6:	6c89                	lui	s9,0x2
    800036f8:	a061                	j	80003780 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036fa:	97ca                	add	a5,a5,s2
    800036fc:	8e55                	or	a2,a2,a3
    800036fe:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003702:	854a                	mv	a0,s2
    80003704:	00001097          	auipc	ra,0x1
    80003708:	0d4080e7          	jalr	212(ra) # 800047d8 <log_write>
        brelse(bp);
    8000370c:	854a                	mv	a0,s2
    8000370e:	00000097          	auipc	ra,0x0
    80003712:	e20080e7          	jalr	-480(ra) # 8000352e <brelse>
  bp = bread(dev, bno);
    80003716:	85a6                	mv	a1,s1
    80003718:	855e                	mv	a0,s7
    8000371a:	00000097          	auipc	ra,0x0
    8000371e:	ce4080e7          	jalr	-796(ra) # 800033fe <bread>
    80003722:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003724:	40000613          	li	a2,1024
    80003728:	4581                	li	a1,0
    8000372a:	05850513          	addi	a0,a0,88
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	6ce080e7          	jalr	1742(ra) # 80000dfc <memset>
  log_write(bp);
    80003736:	854a                	mv	a0,s2
    80003738:	00001097          	auipc	ra,0x1
    8000373c:	0a0080e7          	jalr	160(ra) # 800047d8 <log_write>
  brelse(bp);
    80003740:	854a                	mv	a0,s2
    80003742:	00000097          	auipc	ra,0x0
    80003746:	dec080e7          	jalr	-532(ra) # 8000352e <brelse>
}
    8000374a:	6906                	ld	s2,64(sp)
    8000374c:	79e2                	ld	s3,56(sp)
    8000374e:	7a42                	ld	s4,48(sp)
    80003750:	7aa2                	ld	s5,40(sp)
    80003752:	7b02                	ld	s6,32(sp)
    80003754:	6be2                	ld	s7,24(sp)
    80003756:	6c42                	ld	s8,16(sp)
    80003758:	6ca2                	ld	s9,8(sp)
}
    8000375a:	8526                	mv	a0,s1
    8000375c:	60e6                	ld	ra,88(sp)
    8000375e:	6446                	ld	s0,80(sp)
    80003760:	64a6                	ld	s1,72(sp)
    80003762:	6125                	addi	sp,sp,96
    80003764:	8082                	ret
    brelse(bp);
    80003766:	854a                	mv	a0,s2
    80003768:	00000097          	auipc	ra,0x0
    8000376c:	dc6080e7          	jalr	-570(ra) # 8000352e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003770:	015c87bb          	addw	a5,s9,s5
    80003774:	00078a9b          	sext.w	s5,a5
    80003778:	004b2703          	lw	a4,4(s6)
    8000377c:	06eaf163          	bgeu	s5,a4,800037de <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003780:	41fad79b          	sraiw	a5,s5,0x1f
    80003784:	0137d79b          	srliw	a5,a5,0x13
    80003788:	015787bb          	addw	a5,a5,s5
    8000378c:	40d7d79b          	sraiw	a5,a5,0xd
    80003790:	01cb2583          	lw	a1,28(s6)
    80003794:	9dbd                	addw	a1,a1,a5
    80003796:	855e                	mv	a0,s7
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	c66080e7          	jalr	-922(ra) # 800033fe <bread>
    800037a0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037a2:	004b2503          	lw	a0,4(s6)
    800037a6:	000a849b          	sext.w	s1,s5
    800037aa:	8762                	mv	a4,s8
    800037ac:	faa4fde3          	bgeu	s1,a0,80003766 <balloc+0xa8>
      m = 1 << (bi % 8);
    800037b0:	00777693          	andi	a3,a4,7
    800037b4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037b8:	41f7579b          	sraiw	a5,a4,0x1f
    800037bc:	01d7d79b          	srliw	a5,a5,0x1d
    800037c0:	9fb9                	addw	a5,a5,a4
    800037c2:	4037d79b          	sraiw	a5,a5,0x3
    800037c6:	00f90633          	add	a2,s2,a5
    800037ca:	05864603          	lbu	a2,88(a2)
    800037ce:	00c6f5b3          	and	a1,a3,a2
    800037d2:	d585                	beqz	a1,800036fa <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037d4:	2705                	addiw	a4,a4,1
    800037d6:	2485                	addiw	s1,s1,1
    800037d8:	fd471ae3          	bne	a4,s4,800037ac <balloc+0xee>
    800037dc:	b769                	j	80003766 <balloc+0xa8>
    800037de:	6906                	ld	s2,64(sp)
    800037e0:	79e2                	ld	s3,56(sp)
    800037e2:	7a42                	ld	s4,48(sp)
    800037e4:	7aa2                	ld	s5,40(sp)
    800037e6:	7b02                	ld	s6,32(sp)
    800037e8:	6be2                	ld	s7,24(sp)
    800037ea:	6c42                	ld	s8,16(sp)
    800037ec:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800037ee:	00005517          	auipc	a0,0x5
    800037f2:	d6250513          	addi	a0,a0,-670 # 80008550 <__func__.1+0x548>
    800037f6:	ffffd097          	auipc	ra,0xffffd
    800037fa:	dc6080e7          	jalr	-570(ra) # 800005bc <printf>
  return 0;
    800037fe:	4481                	li	s1,0
    80003800:	bfa9                	j	8000375a <balloc+0x9c>

0000000080003802 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003802:	7179                	addi	sp,sp,-48
    80003804:	f406                	sd	ra,40(sp)
    80003806:	f022                	sd	s0,32(sp)
    80003808:	ec26                	sd	s1,24(sp)
    8000380a:	e84a                	sd	s2,16(sp)
    8000380c:	e44e                	sd	s3,8(sp)
    8000380e:	1800                	addi	s0,sp,48
    80003810:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003812:	47ad                	li	a5,11
    80003814:	02b7e863          	bltu	a5,a1,80003844 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003818:	02059793          	slli	a5,a1,0x20
    8000381c:	01e7d593          	srli	a1,a5,0x1e
    80003820:	00b504b3          	add	s1,a0,a1
    80003824:	0504a903          	lw	s2,80(s1)
    80003828:	08091263          	bnez	s2,800038ac <bmap+0xaa>
      addr = balloc(ip->dev);
    8000382c:	4108                	lw	a0,0(a0)
    8000382e:	00000097          	auipc	ra,0x0
    80003832:	e90080e7          	jalr	-368(ra) # 800036be <balloc>
    80003836:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000383a:	06090963          	beqz	s2,800038ac <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    8000383e:	0524a823          	sw	s2,80(s1)
    80003842:	a0ad                	j	800038ac <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003844:	ff45849b          	addiw	s1,a1,-12
    80003848:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000384c:	0ff00793          	li	a5,255
    80003850:	08e7e863          	bltu	a5,a4,800038e0 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003854:	08052903          	lw	s2,128(a0)
    80003858:	00091f63          	bnez	s2,80003876 <bmap+0x74>
      addr = balloc(ip->dev);
    8000385c:	4108                	lw	a0,0(a0)
    8000385e:	00000097          	auipc	ra,0x0
    80003862:	e60080e7          	jalr	-416(ra) # 800036be <balloc>
    80003866:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000386a:	04090163          	beqz	s2,800038ac <bmap+0xaa>
    8000386e:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003870:	0929a023          	sw	s2,128(s3)
    80003874:	a011                	j	80003878 <bmap+0x76>
    80003876:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003878:	85ca                	mv	a1,s2
    8000387a:	0009a503          	lw	a0,0(s3)
    8000387e:	00000097          	auipc	ra,0x0
    80003882:	b80080e7          	jalr	-1152(ra) # 800033fe <bread>
    80003886:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003888:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000388c:	02049713          	slli	a4,s1,0x20
    80003890:	01e75593          	srli	a1,a4,0x1e
    80003894:	00b784b3          	add	s1,a5,a1
    80003898:	0004a903          	lw	s2,0(s1)
    8000389c:	02090063          	beqz	s2,800038bc <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800038a0:	8552                	mv	a0,s4
    800038a2:	00000097          	auipc	ra,0x0
    800038a6:	c8c080e7          	jalr	-884(ra) # 8000352e <brelse>
    return addr;
    800038aa:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800038ac:	854a                	mv	a0,s2
    800038ae:	70a2                	ld	ra,40(sp)
    800038b0:	7402                	ld	s0,32(sp)
    800038b2:	64e2                	ld	s1,24(sp)
    800038b4:	6942                	ld	s2,16(sp)
    800038b6:	69a2                	ld	s3,8(sp)
    800038b8:	6145                	addi	sp,sp,48
    800038ba:	8082                	ret
      addr = balloc(ip->dev);
    800038bc:	0009a503          	lw	a0,0(s3)
    800038c0:	00000097          	auipc	ra,0x0
    800038c4:	dfe080e7          	jalr	-514(ra) # 800036be <balloc>
    800038c8:	0005091b          	sext.w	s2,a0
      if(addr){
    800038cc:	fc090ae3          	beqz	s2,800038a0 <bmap+0x9e>
        a[bn] = addr;
    800038d0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800038d4:	8552                	mv	a0,s4
    800038d6:	00001097          	auipc	ra,0x1
    800038da:	f02080e7          	jalr	-254(ra) # 800047d8 <log_write>
    800038de:	b7c9                	j	800038a0 <bmap+0x9e>
    800038e0:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800038e2:	00005517          	auipc	a0,0x5
    800038e6:	c8650513          	addi	a0,a0,-890 # 80008568 <__func__.1+0x560>
    800038ea:	ffffd097          	auipc	ra,0xffffd
    800038ee:	c76080e7          	jalr	-906(ra) # 80000560 <panic>

00000000800038f2 <iget>:
{
    800038f2:	7179                	addi	sp,sp,-48
    800038f4:	f406                	sd	ra,40(sp)
    800038f6:	f022                	sd	s0,32(sp)
    800038f8:	ec26                	sd	s1,24(sp)
    800038fa:	e84a                	sd	s2,16(sp)
    800038fc:	e44e                	sd	s3,8(sp)
    800038fe:	e052                	sd	s4,0(sp)
    80003900:	1800                	addi	s0,sp,48
    80003902:	89aa                	mv	s3,a0
    80003904:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003906:	0001e517          	auipc	a0,0x1e
    8000390a:	3b250513          	addi	a0,a0,946 # 80021cb8 <itable>
    8000390e:	ffffd097          	auipc	ra,0xffffd
    80003912:	3f2080e7          	jalr	1010(ra) # 80000d00 <acquire>
  empty = 0;
    80003916:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003918:	0001e497          	auipc	s1,0x1e
    8000391c:	3b848493          	addi	s1,s1,952 # 80021cd0 <itable+0x18>
    80003920:	00020697          	auipc	a3,0x20
    80003924:	e4068693          	addi	a3,a3,-448 # 80023760 <log>
    80003928:	a039                	j	80003936 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000392a:	02090b63          	beqz	s2,80003960 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000392e:	08848493          	addi	s1,s1,136
    80003932:	02d48a63          	beq	s1,a3,80003966 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003936:	449c                	lw	a5,8(s1)
    80003938:	fef059e3          	blez	a5,8000392a <iget+0x38>
    8000393c:	4098                	lw	a4,0(s1)
    8000393e:	ff3716e3          	bne	a4,s3,8000392a <iget+0x38>
    80003942:	40d8                	lw	a4,4(s1)
    80003944:	ff4713e3          	bne	a4,s4,8000392a <iget+0x38>
      ip->ref++;
    80003948:	2785                	addiw	a5,a5,1
    8000394a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000394c:	0001e517          	auipc	a0,0x1e
    80003950:	36c50513          	addi	a0,a0,876 # 80021cb8 <itable>
    80003954:	ffffd097          	auipc	ra,0xffffd
    80003958:	460080e7          	jalr	1120(ra) # 80000db4 <release>
      return ip;
    8000395c:	8926                	mv	s2,s1
    8000395e:	a03d                	j	8000398c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003960:	f7f9                	bnez	a5,8000392e <iget+0x3c>
      empty = ip;
    80003962:	8926                	mv	s2,s1
    80003964:	b7e9                	j	8000392e <iget+0x3c>
  if(empty == 0)
    80003966:	02090c63          	beqz	s2,8000399e <iget+0xac>
  ip->dev = dev;
    8000396a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000396e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003972:	4785                	li	a5,1
    80003974:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003978:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000397c:	0001e517          	auipc	a0,0x1e
    80003980:	33c50513          	addi	a0,a0,828 # 80021cb8 <itable>
    80003984:	ffffd097          	auipc	ra,0xffffd
    80003988:	430080e7          	jalr	1072(ra) # 80000db4 <release>
}
    8000398c:	854a                	mv	a0,s2
    8000398e:	70a2                	ld	ra,40(sp)
    80003990:	7402                	ld	s0,32(sp)
    80003992:	64e2                	ld	s1,24(sp)
    80003994:	6942                	ld	s2,16(sp)
    80003996:	69a2                	ld	s3,8(sp)
    80003998:	6a02                	ld	s4,0(sp)
    8000399a:	6145                	addi	sp,sp,48
    8000399c:	8082                	ret
    panic("iget: no inodes");
    8000399e:	00005517          	auipc	a0,0x5
    800039a2:	be250513          	addi	a0,a0,-1054 # 80008580 <__func__.1+0x578>
    800039a6:	ffffd097          	auipc	ra,0xffffd
    800039aa:	bba080e7          	jalr	-1094(ra) # 80000560 <panic>

00000000800039ae <fsinit>:
fsinit(int dev) {
    800039ae:	7179                	addi	sp,sp,-48
    800039b0:	f406                	sd	ra,40(sp)
    800039b2:	f022                	sd	s0,32(sp)
    800039b4:	ec26                	sd	s1,24(sp)
    800039b6:	e84a                	sd	s2,16(sp)
    800039b8:	e44e                	sd	s3,8(sp)
    800039ba:	1800                	addi	s0,sp,48
    800039bc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800039be:	4585                	li	a1,1
    800039c0:	00000097          	auipc	ra,0x0
    800039c4:	a3e080e7          	jalr	-1474(ra) # 800033fe <bread>
    800039c8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039ca:	0001e997          	auipc	s3,0x1e
    800039ce:	2ce98993          	addi	s3,s3,718 # 80021c98 <sb>
    800039d2:	02000613          	li	a2,32
    800039d6:	05850593          	addi	a1,a0,88
    800039da:	854e                	mv	a0,s3
    800039dc:	ffffd097          	auipc	ra,0xffffd
    800039e0:	47c080e7          	jalr	1148(ra) # 80000e58 <memmove>
  brelse(bp);
    800039e4:	8526                	mv	a0,s1
    800039e6:	00000097          	auipc	ra,0x0
    800039ea:	b48080e7          	jalr	-1208(ra) # 8000352e <brelse>
  if(sb.magic != FSMAGIC)
    800039ee:	0009a703          	lw	a4,0(s3)
    800039f2:	102037b7          	lui	a5,0x10203
    800039f6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039fa:	02f71263          	bne	a4,a5,80003a1e <fsinit+0x70>
  initlog(dev, &sb);
    800039fe:	0001e597          	auipc	a1,0x1e
    80003a02:	29a58593          	addi	a1,a1,666 # 80021c98 <sb>
    80003a06:	854a                	mv	a0,s2
    80003a08:	00001097          	auipc	ra,0x1
    80003a0c:	b60080e7          	jalr	-1184(ra) # 80004568 <initlog>
}
    80003a10:	70a2                	ld	ra,40(sp)
    80003a12:	7402                	ld	s0,32(sp)
    80003a14:	64e2                	ld	s1,24(sp)
    80003a16:	6942                	ld	s2,16(sp)
    80003a18:	69a2                	ld	s3,8(sp)
    80003a1a:	6145                	addi	sp,sp,48
    80003a1c:	8082                	ret
    panic("invalid file system");
    80003a1e:	00005517          	auipc	a0,0x5
    80003a22:	b7250513          	addi	a0,a0,-1166 # 80008590 <__func__.1+0x588>
    80003a26:	ffffd097          	auipc	ra,0xffffd
    80003a2a:	b3a080e7          	jalr	-1222(ra) # 80000560 <panic>

0000000080003a2e <iinit>:
{
    80003a2e:	7179                	addi	sp,sp,-48
    80003a30:	f406                	sd	ra,40(sp)
    80003a32:	f022                	sd	s0,32(sp)
    80003a34:	ec26                	sd	s1,24(sp)
    80003a36:	e84a                	sd	s2,16(sp)
    80003a38:	e44e                	sd	s3,8(sp)
    80003a3a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a3c:	00005597          	auipc	a1,0x5
    80003a40:	b6c58593          	addi	a1,a1,-1172 # 800085a8 <__func__.1+0x5a0>
    80003a44:	0001e517          	auipc	a0,0x1e
    80003a48:	27450513          	addi	a0,a0,628 # 80021cb8 <itable>
    80003a4c:	ffffd097          	auipc	ra,0xffffd
    80003a50:	224080e7          	jalr	548(ra) # 80000c70 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a54:	0001e497          	auipc	s1,0x1e
    80003a58:	28c48493          	addi	s1,s1,652 # 80021ce0 <itable+0x28>
    80003a5c:	00020997          	auipc	s3,0x20
    80003a60:	d1498993          	addi	s3,s3,-748 # 80023770 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a64:	00005917          	auipc	s2,0x5
    80003a68:	b4c90913          	addi	s2,s2,-1204 # 800085b0 <__func__.1+0x5a8>
    80003a6c:	85ca                	mv	a1,s2
    80003a6e:	8526                	mv	a0,s1
    80003a70:	00001097          	auipc	ra,0x1
    80003a74:	e4c080e7          	jalr	-436(ra) # 800048bc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a78:	08848493          	addi	s1,s1,136
    80003a7c:	ff3498e3          	bne	s1,s3,80003a6c <iinit+0x3e>
}
    80003a80:	70a2                	ld	ra,40(sp)
    80003a82:	7402                	ld	s0,32(sp)
    80003a84:	64e2                	ld	s1,24(sp)
    80003a86:	6942                	ld	s2,16(sp)
    80003a88:	69a2                	ld	s3,8(sp)
    80003a8a:	6145                	addi	sp,sp,48
    80003a8c:	8082                	ret

0000000080003a8e <ialloc>:
{
    80003a8e:	7139                	addi	sp,sp,-64
    80003a90:	fc06                	sd	ra,56(sp)
    80003a92:	f822                	sd	s0,48(sp)
    80003a94:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a96:	0001e717          	auipc	a4,0x1e
    80003a9a:	20e72703          	lw	a4,526(a4) # 80021ca4 <sb+0xc>
    80003a9e:	4785                	li	a5,1
    80003aa0:	06e7f463          	bgeu	a5,a4,80003b08 <ialloc+0x7a>
    80003aa4:	f426                	sd	s1,40(sp)
    80003aa6:	f04a                	sd	s2,32(sp)
    80003aa8:	ec4e                	sd	s3,24(sp)
    80003aaa:	e852                	sd	s4,16(sp)
    80003aac:	e456                	sd	s5,8(sp)
    80003aae:	e05a                	sd	s6,0(sp)
    80003ab0:	8aaa                	mv	s5,a0
    80003ab2:	8b2e                	mv	s6,a1
    80003ab4:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003ab6:	0001ea17          	auipc	s4,0x1e
    80003aba:	1e2a0a13          	addi	s4,s4,482 # 80021c98 <sb>
    80003abe:	00495593          	srli	a1,s2,0x4
    80003ac2:	018a2783          	lw	a5,24(s4)
    80003ac6:	9dbd                	addw	a1,a1,a5
    80003ac8:	8556                	mv	a0,s5
    80003aca:	00000097          	auipc	ra,0x0
    80003ace:	934080e7          	jalr	-1740(ra) # 800033fe <bread>
    80003ad2:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ad4:	05850993          	addi	s3,a0,88
    80003ad8:	00f97793          	andi	a5,s2,15
    80003adc:	079a                	slli	a5,a5,0x6
    80003ade:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003ae0:	00099783          	lh	a5,0(s3)
    80003ae4:	cf9d                	beqz	a5,80003b22 <ialloc+0x94>
    brelse(bp);
    80003ae6:	00000097          	auipc	ra,0x0
    80003aea:	a48080e7          	jalr	-1464(ra) # 8000352e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003aee:	0905                	addi	s2,s2,1
    80003af0:	00ca2703          	lw	a4,12(s4)
    80003af4:	0009079b          	sext.w	a5,s2
    80003af8:	fce7e3e3          	bltu	a5,a4,80003abe <ialloc+0x30>
    80003afc:	74a2                	ld	s1,40(sp)
    80003afe:	7902                	ld	s2,32(sp)
    80003b00:	69e2                	ld	s3,24(sp)
    80003b02:	6a42                	ld	s4,16(sp)
    80003b04:	6aa2                	ld	s5,8(sp)
    80003b06:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003b08:	00005517          	auipc	a0,0x5
    80003b0c:	ab050513          	addi	a0,a0,-1360 # 800085b8 <__func__.1+0x5b0>
    80003b10:	ffffd097          	auipc	ra,0xffffd
    80003b14:	aac080e7          	jalr	-1364(ra) # 800005bc <printf>
  return 0;
    80003b18:	4501                	li	a0,0
}
    80003b1a:	70e2                	ld	ra,56(sp)
    80003b1c:	7442                	ld	s0,48(sp)
    80003b1e:	6121                	addi	sp,sp,64
    80003b20:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b22:	04000613          	li	a2,64
    80003b26:	4581                	li	a1,0
    80003b28:	854e                	mv	a0,s3
    80003b2a:	ffffd097          	auipc	ra,0xffffd
    80003b2e:	2d2080e7          	jalr	722(ra) # 80000dfc <memset>
      dip->type = type;
    80003b32:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b36:	8526                	mv	a0,s1
    80003b38:	00001097          	auipc	ra,0x1
    80003b3c:	ca0080e7          	jalr	-864(ra) # 800047d8 <log_write>
      brelse(bp);
    80003b40:	8526                	mv	a0,s1
    80003b42:	00000097          	auipc	ra,0x0
    80003b46:	9ec080e7          	jalr	-1556(ra) # 8000352e <brelse>
      return iget(dev, inum);
    80003b4a:	0009059b          	sext.w	a1,s2
    80003b4e:	8556                	mv	a0,s5
    80003b50:	00000097          	auipc	ra,0x0
    80003b54:	da2080e7          	jalr	-606(ra) # 800038f2 <iget>
    80003b58:	74a2                	ld	s1,40(sp)
    80003b5a:	7902                	ld	s2,32(sp)
    80003b5c:	69e2                	ld	s3,24(sp)
    80003b5e:	6a42                	ld	s4,16(sp)
    80003b60:	6aa2                	ld	s5,8(sp)
    80003b62:	6b02                	ld	s6,0(sp)
    80003b64:	bf5d                	j	80003b1a <ialloc+0x8c>

0000000080003b66 <iupdate>:
{
    80003b66:	1101                	addi	sp,sp,-32
    80003b68:	ec06                	sd	ra,24(sp)
    80003b6a:	e822                	sd	s0,16(sp)
    80003b6c:	e426                	sd	s1,8(sp)
    80003b6e:	e04a                	sd	s2,0(sp)
    80003b70:	1000                	addi	s0,sp,32
    80003b72:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b74:	415c                	lw	a5,4(a0)
    80003b76:	0047d79b          	srliw	a5,a5,0x4
    80003b7a:	0001e597          	auipc	a1,0x1e
    80003b7e:	1365a583          	lw	a1,310(a1) # 80021cb0 <sb+0x18>
    80003b82:	9dbd                	addw	a1,a1,a5
    80003b84:	4108                	lw	a0,0(a0)
    80003b86:	00000097          	auipc	ra,0x0
    80003b8a:	878080e7          	jalr	-1928(ra) # 800033fe <bread>
    80003b8e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b90:	05850793          	addi	a5,a0,88
    80003b94:	40d8                	lw	a4,4(s1)
    80003b96:	8b3d                	andi	a4,a4,15
    80003b98:	071a                	slli	a4,a4,0x6
    80003b9a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003b9c:	04449703          	lh	a4,68(s1)
    80003ba0:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003ba4:	04649703          	lh	a4,70(s1)
    80003ba8:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003bac:	04849703          	lh	a4,72(s1)
    80003bb0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003bb4:	04a49703          	lh	a4,74(s1)
    80003bb8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003bbc:	44f8                	lw	a4,76(s1)
    80003bbe:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003bc0:	03400613          	li	a2,52
    80003bc4:	05048593          	addi	a1,s1,80
    80003bc8:	00c78513          	addi	a0,a5,12
    80003bcc:	ffffd097          	auipc	ra,0xffffd
    80003bd0:	28c080e7          	jalr	652(ra) # 80000e58 <memmove>
  log_write(bp);
    80003bd4:	854a                	mv	a0,s2
    80003bd6:	00001097          	auipc	ra,0x1
    80003bda:	c02080e7          	jalr	-1022(ra) # 800047d8 <log_write>
  brelse(bp);
    80003bde:	854a                	mv	a0,s2
    80003be0:	00000097          	auipc	ra,0x0
    80003be4:	94e080e7          	jalr	-1714(ra) # 8000352e <brelse>
}
    80003be8:	60e2                	ld	ra,24(sp)
    80003bea:	6442                	ld	s0,16(sp)
    80003bec:	64a2                	ld	s1,8(sp)
    80003bee:	6902                	ld	s2,0(sp)
    80003bf0:	6105                	addi	sp,sp,32
    80003bf2:	8082                	ret

0000000080003bf4 <idup>:
{
    80003bf4:	1101                	addi	sp,sp,-32
    80003bf6:	ec06                	sd	ra,24(sp)
    80003bf8:	e822                	sd	s0,16(sp)
    80003bfa:	e426                	sd	s1,8(sp)
    80003bfc:	1000                	addi	s0,sp,32
    80003bfe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c00:	0001e517          	auipc	a0,0x1e
    80003c04:	0b850513          	addi	a0,a0,184 # 80021cb8 <itable>
    80003c08:	ffffd097          	auipc	ra,0xffffd
    80003c0c:	0f8080e7          	jalr	248(ra) # 80000d00 <acquire>
  ip->ref++;
    80003c10:	449c                	lw	a5,8(s1)
    80003c12:	2785                	addiw	a5,a5,1
    80003c14:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c16:	0001e517          	auipc	a0,0x1e
    80003c1a:	0a250513          	addi	a0,a0,162 # 80021cb8 <itable>
    80003c1e:	ffffd097          	auipc	ra,0xffffd
    80003c22:	196080e7          	jalr	406(ra) # 80000db4 <release>
}
    80003c26:	8526                	mv	a0,s1
    80003c28:	60e2                	ld	ra,24(sp)
    80003c2a:	6442                	ld	s0,16(sp)
    80003c2c:	64a2                	ld	s1,8(sp)
    80003c2e:	6105                	addi	sp,sp,32
    80003c30:	8082                	ret

0000000080003c32 <ilock>:
{
    80003c32:	1101                	addi	sp,sp,-32
    80003c34:	ec06                	sd	ra,24(sp)
    80003c36:	e822                	sd	s0,16(sp)
    80003c38:	e426                	sd	s1,8(sp)
    80003c3a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c3c:	c10d                	beqz	a0,80003c5e <ilock+0x2c>
    80003c3e:	84aa                	mv	s1,a0
    80003c40:	451c                	lw	a5,8(a0)
    80003c42:	00f05e63          	blez	a5,80003c5e <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003c46:	0541                	addi	a0,a0,16
    80003c48:	00001097          	auipc	ra,0x1
    80003c4c:	cae080e7          	jalr	-850(ra) # 800048f6 <acquiresleep>
  if(ip->valid == 0){
    80003c50:	40bc                	lw	a5,64(s1)
    80003c52:	cf99                	beqz	a5,80003c70 <ilock+0x3e>
}
    80003c54:	60e2                	ld	ra,24(sp)
    80003c56:	6442                	ld	s0,16(sp)
    80003c58:	64a2                	ld	s1,8(sp)
    80003c5a:	6105                	addi	sp,sp,32
    80003c5c:	8082                	ret
    80003c5e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003c60:	00005517          	auipc	a0,0x5
    80003c64:	97050513          	addi	a0,a0,-1680 # 800085d0 <__func__.1+0x5c8>
    80003c68:	ffffd097          	auipc	ra,0xffffd
    80003c6c:	8f8080e7          	jalr	-1800(ra) # 80000560 <panic>
    80003c70:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c72:	40dc                	lw	a5,4(s1)
    80003c74:	0047d79b          	srliw	a5,a5,0x4
    80003c78:	0001e597          	auipc	a1,0x1e
    80003c7c:	0385a583          	lw	a1,56(a1) # 80021cb0 <sb+0x18>
    80003c80:	9dbd                	addw	a1,a1,a5
    80003c82:	4088                	lw	a0,0(s1)
    80003c84:	fffff097          	auipc	ra,0xfffff
    80003c88:	77a080e7          	jalr	1914(ra) # 800033fe <bread>
    80003c8c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c8e:	05850593          	addi	a1,a0,88
    80003c92:	40dc                	lw	a5,4(s1)
    80003c94:	8bbd                	andi	a5,a5,15
    80003c96:	079a                	slli	a5,a5,0x6
    80003c98:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c9a:	00059783          	lh	a5,0(a1)
    80003c9e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003ca2:	00259783          	lh	a5,2(a1)
    80003ca6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003caa:	00459783          	lh	a5,4(a1)
    80003cae:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003cb2:	00659783          	lh	a5,6(a1)
    80003cb6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003cba:	459c                	lw	a5,8(a1)
    80003cbc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003cbe:	03400613          	li	a2,52
    80003cc2:	05b1                	addi	a1,a1,12
    80003cc4:	05048513          	addi	a0,s1,80
    80003cc8:	ffffd097          	auipc	ra,0xffffd
    80003ccc:	190080e7          	jalr	400(ra) # 80000e58 <memmove>
    brelse(bp);
    80003cd0:	854a                	mv	a0,s2
    80003cd2:	00000097          	auipc	ra,0x0
    80003cd6:	85c080e7          	jalr	-1956(ra) # 8000352e <brelse>
    ip->valid = 1;
    80003cda:	4785                	li	a5,1
    80003cdc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003cde:	04449783          	lh	a5,68(s1)
    80003ce2:	c399                	beqz	a5,80003ce8 <ilock+0xb6>
    80003ce4:	6902                	ld	s2,0(sp)
    80003ce6:	b7bd                	j	80003c54 <ilock+0x22>
      panic("ilock: no type");
    80003ce8:	00005517          	auipc	a0,0x5
    80003cec:	8f050513          	addi	a0,a0,-1808 # 800085d8 <__func__.1+0x5d0>
    80003cf0:	ffffd097          	auipc	ra,0xffffd
    80003cf4:	870080e7          	jalr	-1936(ra) # 80000560 <panic>

0000000080003cf8 <iunlock>:
{
    80003cf8:	1101                	addi	sp,sp,-32
    80003cfa:	ec06                	sd	ra,24(sp)
    80003cfc:	e822                	sd	s0,16(sp)
    80003cfe:	e426                	sd	s1,8(sp)
    80003d00:	e04a                	sd	s2,0(sp)
    80003d02:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d04:	c905                	beqz	a0,80003d34 <iunlock+0x3c>
    80003d06:	84aa                	mv	s1,a0
    80003d08:	01050913          	addi	s2,a0,16
    80003d0c:	854a                	mv	a0,s2
    80003d0e:	00001097          	auipc	ra,0x1
    80003d12:	c82080e7          	jalr	-894(ra) # 80004990 <holdingsleep>
    80003d16:	cd19                	beqz	a0,80003d34 <iunlock+0x3c>
    80003d18:	449c                	lw	a5,8(s1)
    80003d1a:	00f05d63          	blez	a5,80003d34 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d1e:	854a                	mv	a0,s2
    80003d20:	00001097          	auipc	ra,0x1
    80003d24:	c2c080e7          	jalr	-980(ra) # 8000494c <releasesleep>
}
    80003d28:	60e2                	ld	ra,24(sp)
    80003d2a:	6442                	ld	s0,16(sp)
    80003d2c:	64a2                	ld	s1,8(sp)
    80003d2e:	6902                	ld	s2,0(sp)
    80003d30:	6105                	addi	sp,sp,32
    80003d32:	8082                	ret
    panic("iunlock");
    80003d34:	00005517          	auipc	a0,0x5
    80003d38:	8b450513          	addi	a0,a0,-1868 # 800085e8 <__func__.1+0x5e0>
    80003d3c:	ffffd097          	auipc	ra,0xffffd
    80003d40:	824080e7          	jalr	-2012(ra) # 80000560 <panic>

0000000080003d44 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d44:	7179                	addi	sp,sp,-48
    80003d46:	f406                	sd	ra,40(sp)
    80003d48:	f022                	sd	s0,32(sp)
    80003d4a:	ec26                	sd	s1,24(sp)
    80003d4c:	e84a                	sd	s2,16(sp)
    80003d4e:	e44e                	sd	s3,8(sp)
    80003d50:	1800                	addi	s0,sp,48
    80003d52:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d54:	05050493          	addi	s1,a0,80
    80003d58:	08050913          	addi	s2,a0,128
    80003d5c:	a021                	j	80003d64 <itrunc+0x20>
    80003d5e:	0491                	addi	s1,s1,4
    80003d60:	01248d63          	beq	s1,s2,80003d7a <itrunc+0x36>
    if(ip->addrs[i]){
    80003d64:	408c                	lw	a1,0(s1)
    80003d66:	dde5                	beqz	a1,80003d5e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003d68:	0009a503          	lw	a0,0(s3)
    80003d6c:	00000097          	auipc	ra,0x0
    80003d70:	8d6080e7          	jalr	-1834(ra) # 80003642 <bfree>
      ip->addrs[i] = 0;
    80003d74:	0004a023          	sw	zero,0(s1)
    80003d78:	b7dd                	j	80003d5e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d7a:	0809a583          	lw	a1,128(s3)
    80003d7e:	ed99                	bnez	a1,80003d9c <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d80:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d84:	854e                	mv	a0,s3
    80003d86:	00000097          	auipc	ra,0x0
    80003d8a:	de0080e7          	jalr	-544(ra) # 80003b66 <iupdate>
}
    80003d8e:	70a2                	ld	ra,40(sp)
    80003d90:	7402                	ld	s0,32(sp)
    80003d92:	64e2                	ld	s1,24(sp)
    80003d94:	6942                	ld	s2,16(sp)
    80003d96:	69a2                	ld	s3,8(sp)
    80003d98:	6145                	addi	sp,sp,48
    80003d9a:	8082                	ret
    80003d9c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d9e:	0009a503          	lw	a0,0(s3)
    80003da2:	fffff097          	auipc	ra,0xfffff
    80003da6:	65c080e7          	jalr	1628(ra) # 800033fe <bread>
    80003daa:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003dac:	05850493          	addi	s1,a0,88
    80003db0:	45850913          	addi	s2,a0,1112
    80003db4:	a021                	j	80003dbc <itrunc+0x78>
    80003db6:	0491                	addi	s1,s1,4
    80003db8:	01248b63          	beq	s1,s2,80003dce <itrunc+0x8a>
      if(a[j])
    80003dbc:	408c                	lw	a1,0(s1)
    80003dbe:	dde5                	beqz	a1,80003db6 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003dc0:	0009a503          	lw	a0,0(s3)
    80003dc4:	00000097          	auipc	ra,0x0
    80003dc8:	87e080e7          	jalr	-1922(ra) # 80003642 <bfree>
    80003dcc:	b7ed                	j	80003db6 <itrunc+0x72>
    brelse(bp);
    80003dce:	8552                	mv	a0,s4
    80003dd0:	fffff097          	auipc	ra,0xfffff
    80003dd4:	75e080e7          	jalr	1886(ra) # 8000352e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003dd8:	0809a583          	lw	a1,128(s3)
    80003ddc:	0009a503          	lw	a0,0(s3)
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	862080e7          	jalr	-1950(ra) # 80003642 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003de8:	0809a023          	sw	zero,128(s3)
    80003dec:	6a02                	ld	s4,0(sp)
    80003dee:	bf49                	j	80003d80 <itrunc+0x3c>

0000000080003df0 <iput>:
{
    80003df0:	1101                	addi	sp,sp,-32
    80003df2:	ec06                	sd	ra,24(sp)
    80003df4:	e822                	sd	s0,16(sp)
    80003df6:	e426                	sd	s1,8(sp)
    80003df8:	1000                	addi	s0,sp,32
    80003dfa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003dfc:	0001e517          	auipc	a0,0x1e
    80003e00:	ebc50513          	addi	a0,a0,-324 # 80021cb8 <itable>
    80003e04:	ffffd097          	auipc	ra,0xffffd
    80003e08:	efc080e7          	jalr	-260(ra) # 80000d00 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e0c:	4498                	lw	a4,8(s1)
    80003e0e:	4785                	li	a5,1
    80003e10:	02f70263          	beq	a4,a5,80003e34 <iput+0x44>
  ip->ref--;
    80003e14:	449c                	lw	a5,8(s1)
    80003e16:	37fd                	addiw	a5,a5,-1
    80003e18:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e1a:	0001e517          	auipc	a0,0x1e
    80003e1e:	e9e50513          	addi	a0,a0,-354 # 80021cb8 <itable>
    80003e22:	ffffd097          	auipc	ra,0xffffd
    80003e26:	f92080e7          	jalr	-110(ra) # 80000db4 <release>
}
    80003e2a:	60e2                	ld	ra,24(sp)
    80003e2c:	6442                	ld	s0,16(sp)
    80003e2e:	64a2                	ld	s1,8(sp)
    80003e30:	6105                	addi	sp,sp,32
    80003e32:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e34:	40bc                	lw	a5,64(s1)
    80003e36:	dff9                	beqz	a5,80003e14 <iput+0x24>
    80003e38:	04a49783          	lh	a5,74(s1)
    80003e3c:	ffe1                	bnez	a5,80003e14 <iput+0x24>
    80003e3e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003e40:	01048913          	addi	s2,s1,16
    80003e44:	854a                	mv	a0,s2
    80003e46:	00001097          	auipc	ra,0x1
    80003e4a:	ab0080e7          	jalr	-1360(ra) # 800048f6 <acquiresleep>
    release(&itable.lock);
    80003e4e:	0001e517          	auipc	a0,0x1e
    80003e52:	e6a50513          	addi	a0,a0,-406 # 80021cb8 <itable>
    80003e56:	ffffd097          	auipc	ra,0xffffd
    80003e5a:	f5e080e7          	jalr	-162(ra) # 80000db4 <release>
    itrunc(ip);
    80003e5e:	8526                	mv	a0,s1
    80003e60:	00000097          	auipc	ra,0x0
    80003e64:	ee4080e7          	jalr	-284(ra) # 80003d44 <itrunc>
    ip->type = 0;
    80003e68:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e6c:	8526                	mv	a0,s1
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	cf8080e7          	jalr	-776(ra) # 80003b66 <iupdate>
    ip->valid = 0;
    80003e76:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e7a:	854a                	mv	a0,s2
    80003e7c:	00001097          	auipc	ra,0x1
    80003e80:	ad0080e7          	jalr	-1328(ra) # 8000494c <releasesleep>
    acquire(&itable.lock);
    80003e84:	0001e517          	auipc	a0,0x1e
    80003e88:	e3450513          	addi	a0,a0,-460 # 80021cb8 <itable>
    80003e8c:	ffffd097          	auipc	ra,0xffffd
    80003e90:	e74080e7          	jalr	-396(ra) # 80000d00 <acquire>
    80003e94:	6902                	ld	s2,0(sp)
    80003e96:	bfbd                	j	80003e14 <iput+0x24>

0000000080003e98 <iunlockput>:
{
    80003e98:	1101                	addi	sp,sp,-32
    80003e9a:	ec06                	sd	ra,24(sp)
    80003e9c:	e822                	sd	s0,16(sp)
    80003e9e:	e426                	sd	s1,8(sp)
    80003ea0:	1000                	addi	s0,sp,32
    80003ea2:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ea4:	00000097          	auipc	ra,0x0
    80003ea8:	e54080e7          	jalr	-428(ra) # 80003cf8 <iunlock>
  iput(ip);
    80003eac:	8526                	mv	a0,s1
    80003eae:	00000097          	auipc	ra,0x0
    80003eb2:	f42080e7          	jalr	-190(ra) # 80003df0 <iput>
}
    80003eb6:	60e2                	ld	ra,24(sp)
    80003eb8:	6442                	ld	s0,16(sp)
    80003eba:	64a2                	ld	s1,8(sp)
    80003ebc:	6105                	addi	sp,sp,32
    80003ebe:	8082                	ret

0000000080003ec0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ec0:	1141                	addi	sp,sp,-16
    80003ec2:	e422                	sd	s0,8(sp)
    80003ec4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ec6:	411c                	lw	a5,0(a0)
    80003ec8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003eca:	415c                	lw	a5,4(a0)
    80003ecc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ece:	04451783          	lh	a5,68(a0)
    80003ed2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ed6:	04a51783          	lh	a5,74(a0)
    80003eda:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ede:	04c56783          	lwu	a5,76(a0)
    80003ee2:	e99c                	sd	a5,16(a1)
}
    80003ee4:	6422                	ld	s0,8(sp)
    80003ee6:	0141                	addi	sp,sp,16
    80003ee8:	8082                	ret

0000000080003eea <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003eea:	457c                	lw	a5,76(a0)
    80003eec:	10d7e563          	bltu	a5,a3,80003ff6 <readi+0x10c>
{
    80003ef0:	7159                	addi	sp,sp,-112
    80003ef2:	f486                	sd	ra,104(sp)
    80003ef4:	f0a2                	sd	s0,96(sp)
    80003ef6:	eca6                	sd	s1,88(sp)
    80003ef8:	e0d2                	sd	s4,64(sp)
    80003efa:	fc56                	sd	s5,56(sp)
    80003efc:	f85a                	sd	s6,48(sp)
    80003efe:	f45e                	sd	s7,40(sp)
    80003f00:	1880                	addi	s0,sp,112
    80003f02:	8b2a                	mv	s6,a0
    80003f04:	8bae                	mv	s7,a1
    80003f06:	8a32                	mv	s4,a2
    80003f08:	84b6                	mv	s1,a3
    80003f0a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003f0c:	9f35                	addw	a4,a4,a3
    return 0;
    80003f0e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f10:	0cd76a63          	bltu	a4,a3,80003fe4 <readi+0xfa>
    80003f14:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003f16:	00e7f463          	bgeu	a5,a4,80003f1e <readi+0x34>
    n = ip->size - off;
    80003f1a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f1e:	0a0a8963          	beqz	s5,80003fd0 <readi+0xe6>
    80003f22:	e8ca                	sd	s2,80(sp)
    80003f24:	f062                	sd	s8,32(sp)
    80003f26:	ec66                	sd	s9,24(sp)
    80003f28:	e86a                	sd	s10,16(sp)
    80003f2a:	e46e                	sd	s11,8(sp)
    80003f2c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f2e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f32:	5c7d                	li	s8,-1
    80003f34:	a82d                	j	80003f6e <readi+0x84>
    80003f36:	020d1d93          	slli	s11,s10,0x20
    80003f3a:	020ddd93          	srli	s11,s11,0x20
    80003f3e:	05890613          	addi	a2,s2,88
    80003f42:	86ee                	mv	a3,s11
    80003f44:	963a                	add	a2,a2,a4
    80003f46:	85d2                	mv	a1,s4
    80003f48:	855e                	mv	a0,s7
    80003f4a:	fffff097          	auipc	ra,0xfffff
    80003f4e:	8e6080e7          	jalr	-1818(ra) # 80002830 <either_copyout>
    80003f52:	05850d63          	beq	a0,s8,80003fac <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f56:	854a                	mv	a0,s2
    80003f58:	fffff097          	auipc	ra,0xfffff
    80003f5c:	5d6080e7          	jalr	1494(ra) # 8000352e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f60:	013d09bb          	addw	s3,s10,s3
    80003f64:	009d04bb          	addw	s1,s10,s1
    80003f68:	9a6e                	add	s4,s4,s11
    80003f6a:	0559fd63          	bgeu	s3,s5,80003fc4 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003f6e:	00a4d59b          	srliw	a1,s1,0xa
    80003f72:	855a                	mv	a0,s6
    80003f74:	00000097          	auipc	ra,0x0
    80003f78:	88e080e7          	jalr	-1906(ra) # 80003802 <bmap>
    80003f7c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f80:	c9b1                	beqz	a1,80003fd4 <readi+0xea>
    bp = bread(ip->dev, addr);
    80003f82:	000b2503          	lw	a0,0(s6)
    80003f86:	fffff097          	auipc	ra,0xfffff
    80003f8a:	478080e7          	jalr	1144(ra) # 800033fe <bread>
    80003f8e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f90:	3ff4f713          	andi	a4,s1,1023
    80003f94:	40ec87bb          	subw	a5,s9,a4
    80003f98:	413a86bb          	subw	a3,s5,s3
    80003f9c:	8d3e                	mv	s10,a5
    80003f9e:	2781                	sext.w	a5,a5
    80003fa0:	0006861b          	sext.w	a2,a3
    80003fa4:	f8f679e3          	bgeu	a2,a5,80003f36 <readi+0x4c>
    80003fa8:	8d36                	mv	s10,a3
    80003faa:	b771                	j	80003f36 <readi+0x4c>
      brelse(bp);
    80003fac:	854a                	mv	a0,s2
    80003fae:	fffff097          	auipc	ra,0xfffff
    80003fb2:	580080e7          	jalr	1408(ra) # 8000352e <brelse>
      tot = -1;
    80003fb6:	59fd                	li	s3,-1
      break;
    80003fb8:	6946                	ld	s2,80(sp)
    80003fba:	7c02                	ld	s8,32(sp)
    80003fbc:	6ce2                	ld	s9,24(sp)
    80003fbe:	6d42                	ld	s10,16(sp)
    80003fc0:	6da2                	ld	s11,8(sp)
    80003fc2:	a831                	j	80003fde <readi+0xf4>
    80003fc4:	6946                	ld	s2,80(sp)
    80003fc6:	7c02                	ld	s8,32(sp)
    80003fc8:	6ce2                	ld	s9,24(sp)
    80003fca:	6d42                	ld	s10,16(sp)
    80003fcc:	6da2                	ld	s11,8(sp)
    80003fce:	a801                	j	80003fde <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fd0:	89d6                	mv	s3,s5
    80003fd2:	a031                	j	80003fde <readi+0xf4>
    80003fd4:	6946                	ld	s2,80(sp)
    80003fd6:	7c02                	ld	s8,32(sp)
    80003fd8:	6ce2                	ld	s9,24(sp)
    80003fda:	6d42                	ld	s10,16(sp)
    80003fdc:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003fde:	0009851b          	sext.w	a0,s3
    80003fe2:	69a6                	ld	s3,72(sp)
}
    80003fe4:	70a6                	ld	ra,104(sp)
    80003fe6:	7406                	ld	s0,96(sp)
    80003fe8:	64e6                	ld	s1,88(sp)
    80003fea:	6a06                	ld	s4,64(sp)
    80003fec:	7ae2                	ld	s5,56(sp)
    80003fee:	7b42                	ld	s6,48(sp)
    80003ff0:	7ba2                	ld	s7,40(sp)
    80003ff2:	6165                	addi	sp,sp,112
    80003ff4:	8082                	ret
    return 0;
    80003ff6:	4501                	li	a0,0
}
    80003ff8:	8082                	ret

0000000080003ffa <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ffa:	457c                	lw	a5,76(a0)
    80003ffc:	10d7ee63          	bltu	a5,a3,80004118 <writei+0x11e>
{
    80004000:	7159                	addi	sp,sp,-112
    80004002:	f486                	sd	ra,104(sp)
    80004004:	f0a2                	sd	s0,96(sp)
    80004006:	e8ca                	sd	s2,80(sp)
    80004008:	e0d2                	sd	s4,64(sp)
    8000400a:	fc56                	sd	s5,56(sp)
    8000400c:	f85a                	sd	s6,48(sp)
    8000400e:	f45e                	sd	s7,40(sp)
    80004010:	1880                	addi	s0,sp,112
    80004012:	8aaa                	mv	s5,a0
    80004014:	8bae                	mv	s7,a1
    80004016:	8a32                	mv	s4,a2
    80004018:	8936                	mv	s2,a3
    8000401a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000401c:	00e687bb          	addw	a5,a3,a4
    80004020:	0ed7ee63          	bltu	a5,a3,8000411c <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004024:	00043737          	lui	a4,0x43
    80004028:	0ef76c63          	bltu	a4,a5,80004120 <writei+0x126>
    8000402c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000402e:	0c0b0d63          	beqz	s6,80004108 <writei+0x10e>
    80004032:	eca6                	sd	s1,88(sp)
    80004034:	f062                	sd	s8,32(sp)
    80004036:	ec66                	sd	s9,24(sp)
    80004038:	e86a                	sd	s10,16(sp)
    8000403a:	e46e                	sd	s11,8(sp)
    8000403c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000403e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004042:	5c7d                	li	s8,-1
    80004044:	a091                	j	80004088 <writei+0x8e>
    80004046:	020d1d93          	slli	s11,s10,0x20
    8000404a:	020ddd93          	srli	s11,s11,0x20
    8000404e:	05848513          	addi	a0,s1,88
    80004052:	86ee                	mv	a3,s11
    80004054:	8652                	mv	a2,s4
    80004056:	85de                	mv	a1,s7
    80004058:	953a                	add	a0,a0,a4
    8000405a:	fffff097          	auipc	ra,0xfffff
    8000405e:	82c080e7          	jalr	-2004(ra) # 80002886 <either_copyin>
    80004062:	07850263          	beq	a0,s8,800040c6 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004066:	8526                	mv	a0,s1
    80004068:	00000097          	auipc	ra,0x0
    8000406c:	770080e7          	jalr	1904(ra) # 800047d8 <log_write>
    brelse(bp);
    80004070:	8526                	mv	a0,s1
    80004072:	fffff097          	auipc	ra,0xfffff
    80004076:	4bc080e7          	jalr	1212(ra) # 8000352e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000407a:	013d09bb          	addw	s3,s10,s3
    8000407e:	012d093b          	addw	s2,s10,s2
    80004082:	9a6e                	add	s4,s4,s11
    80004084:	0569f663          	bgeu	s3,s6,800040d0 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004088:	00a9559b          	srliw	a1,s2,0xa
    8000408c:	8556                	mv	a0,s5
    8000408e:	fffff097          	auipc	ra,0xfffff
    80004092:	774080e7          	jalr	1908(ra) # 80003802 <bmap>
    80004096:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000409a:	c99d                	beqz	a1,800040d0 <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000409c:	000aa503          	lw	a0,0(s5)
    800040a0:	fffff097          	auipc	ra,0xfffff
    800040a4:	35e080e7          	jalr	862(ra) # 800033fe <bread>
    800040a8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040aa:	3ff97713          	andi	a4,s2,1023
    800040ae:	40ec87bb          	subw	a5,s9,a4
    800040b2:	413b06bb          	subw	a3,s6,s3
    800040b6:	8d3e                	mv	s10,a5
    800040b8:	2781                	sext.w	a5,a5
    800040ba:	0006861b          	sext.w	a2,a3
    800040be:	f8f674e3          	bgeu	a2,a5,80004046 <writei+0x4c>
    800040c2:	8d36                	mv	s10,a3
    800040c4:	b749                	j	80004046 <writei+0x4c>
      brelse(bp);
    800040c6:	8526                	mv	a0,s1
    800040c8:	fffff097          	auipc	ra,0xfffff
    800040cc:	466080e7          	jalr	1126(ra) # 8000352e <brelse>
  }

  if(off > ip->size)
    800040d0:	04caa783          	lw	a5,76(s5)
    800040d4:	0327fc63          	bgeu	a5,s2,8000410c <writei+0x112>
    ip->size = off;
    800040d8:	052aa623          	sw	s2,76(s5)
    800040dc:	64e6                	ld	s1,88(sp)
    800040de:	7c02                	ld	s8,32(sp)
    800040e0:	6ce2                	ld	s9,24(sp)
    800040e2:	6d42                	ld	s10,16(sp)
    800040e4:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800040e6:	8556                	mv	a0,s5
    800040e8:	00000097          	auipc	ra,0x0
    800040ec:	a7e080e7          	jalr	-1410(ra) # 80003b66 <iupdate>

  return tot;
    800040f0:	0009851b          	sext.w	a0,s3
    800040f4:	69a6                	ld	s3,72(sp)
}
    800040f6:	70a6                	ld	ra,104(sp)
    800040f8:	7406                	ld	s0,96(sp)
    800040fa:	6946                	ld	s2,80(sp)
    800040fc:	6a06                	ld	s4,64(sp)
    800040fe:	7ae2                	ld	s5,56(sp)
    80004100:	7b42                	ld	s6,48(sp)
    80004102:	7ba2                	ld	s7,40(sp)
    80004104:	6165                	addi	sp,sp,112
    80004106:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004108:	89da                	mv	s3,s6
    8000410a:	bff1                	j	800040e6 <writei+0xec>
    8000410c:	64e6                	ld	s1,88(sp)
    8000410e:	7c02                	ld	s8,32(sp)
    80004110:	6ce2                	ld	s9,24(sp)
    80004112:	6d42                	ld	s10,16(sp)
    80004114:	6da2                	ld	s11,8(sp)
    80004116:	bfc1                	j	800040e6 <writei+0xec>
    return -1;
    80004118:	557d                	li	a0,-1
}
    8000411a:	8082                	ret
    return -1;
    8000411c:	557d                	li	a0,-1
    8000411e:	bfe1                	j	800040f6 <writei+0xfc>
    return -1;
    80004120:	557d                	li	a0,-1
    80004122:	bfd1                	j	800040f6 <writei+0xfc>

0000000080004124 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004124:	1141                	addi	sp,sp,-16
    80004126:	e406                	sd	ra,8(sp)
    80004128:	e022                	sd	s0,0(sp)
    8000412a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000412c:	4639                	li	a2,14
    8000412e:	ffffd097          	auipc	ra,0xffffd
    80004132:	d9e080e7          	jalr	-610(ra) # 80000ecc <strncmp>
}
    80004136:	60a2                	ld	ra,8(sp)
    80004138:	6402                	ld	s0,0(sp)
    8000413a:	0141                	addi	sp,sp,16
    8000413c:	8082                	ret

000000008000413e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000413e:	7139                	addi	sp,sp,-64
    80004140:	fc06                	sd	ra,56(sp)
    80004142:	f822                	sd	s0,48(sp)
    80004144:	f426                	sd	s1,40(sp)
    80004146:	f04a                	sd	s2,32(sp)
    80004148:	ec4e                	sd	s3,24(sp)
    8000414a:	e852                	sd	s4,16(sp)
    8000414c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000414e:	04451703          	lh	a4,68(a0)
    80004152:	4785                	li	a5,1
    80004154:	00f71a63          	bne	a4,a5,80004168 <dirlookup+0x2a>
    80004158:	892a                	mv	s2,a0
    8000415a:	89ae                	mv	s3,a1
    8000415c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000415e:	457c                	lw	a5,76(a0)
    80004160:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004162:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004164:	e79d                	bnez	a5,80004192 <dirlookup+0x54>
    80004166:	a8a5                	j	800041de <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004168:	00004517          	auipc	a0,0x4
    8000416c:	48850513          	addi	a0,a0,1160 # 800085f0 <__func__.1+0x5e8>
    80004170:	ffffc097          	auipc	ra,0xffffc
    80004174:	3f0080e7          	jalr	1008(ra) # 80000560 <panic>
      panic("dirlookup read");
    80004178:	00004517          	auipc	a0,0x4
    8000417c:	49050513          	addi	a0,a0,1168 # 80008608 <__func__.1+0x600>
    80004180:	ffffc097          	auipc	ra,0xffffc
    80004184:	3e0080e7          	jalr	992(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004188:	24c1                	addiw	s1,s1,16
    8000418a:	04c92783          	lw	a5,76(s2)
    8000418e:	04f4f763          	bgeu	s1,a5,800041dc <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004192:	4741                	li	a4,16
    80004194:	86a6                	mv	a3,s1
    80004196:	fc040613          	addi	a2,s0,-64
    8000419a:	4581                	li	a1,0
    8000419c:	854a                	mv	a0,s2
    8000419e:	00000097          	auipc	ra,0x0
    800041a2:	d4c080e7          	jalr	-692(ra) # 80003eea <readi>
    800041a6:	47c1                	li	a5,16
    800041a8:	fcf518e3          	bne	a0,a5,80004178 <dirlookup+0x3a>
    if(de.inum == 0)
    800041ac:	fc045783          	lhu	a5,-64(s0)
    800041b0:	dfe1                	beqz	a5,80004188 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800041b2:	fc240593          	addi	a1,s0,-62
    800041b6:	854e                	mv	a0,s3
    800041b8:	00000097          	auipc	ra,0x0
    800041bc:	f6c080e7          	jalr	-148(ra) # 80004124 <namecmp>
    800041c0:	f561                	bnez	a0,80004188 <dirlookup+0x4a>
      if(poff)
    800041c2:	000a0463          	beqz	s4,800041ca <dirlookup+0x8c>
        *poff = off;
    800041c6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800041ca:	fc045583          	lhu	a1,-64(s0)
    800041ce:	00092503          	lw	a0,0(s2)
    800041d2:	fffff097          	auipc	ra,0xfffff
    800041d6:	720080e7          	jalr	1824(ra) # 800038f2 <iget>
    800041da:	a011                	j	800041de <dirlookup+0xa0>
  return 0;
    800041dc:	4501                	li	a0,0
}
    800041de:	70e2                	ld	ra,56(sp)
    800041e0:	7442                	ld	s0,48(sp)
    800041e2:	74a2                	ld	s1,40(sp)
    800041e4:	7902                	ld	s2,32(sp)
    800041e6:	69e2                	ld	s3,24(sp)
    800041e8:	6a42                	ld	s4,16(sp)
    800041ea:	6121                	addi	sp,sp,64
    800041ec:	8082                	ret

00000000800041ee <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800041ee:	711d                	addi	sp,sp,-96
    800041f0:	ec86                	sd	ra,88(sp)
    800041f2:	e8a2                	sd	s0,80(sp)
    800041f4:	e4a6                	sd	s1,72(sp)
    800041f6:	e0ca                	sd	s2,64(sp)
    800041f8:	fc4e                	sd	s3,56(sp)
    800041fa:	f852                	sd	s4,48(sp)
    800041fc:	f456                	sd	s5,40(sp)
    800041fe:	f05a                	sd	s6,32(sp)
    80004200:	ec5e                	sd	s7,24(sp)
    80004202:	e862                	sd	s8,16(sp)
    80004204:	e466                	sd	s9,8(sp)
    80004206:	1080                	addi	s0,sp,96
    80004208:	84aa                	mv	s1,a0
    8000420a:	8b2e                	mv	s6,a1
    8000420c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000420e:	00054703          	lbu	a4,0(a0)
    80004212:	02f00793          	li	a5,47
    80004216:	02f70263          	beq	a4,a5,8000423a <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000421a:	ffffe097          	auipc	ra,0xffffe
    8000421e:	a5c080e7          	jalr	-1444(ra) # 80001c76 <myproc>
    80004222:	15053503          	ld	a0,336(a0)
    80004226:	00000097          	auipc	ra,0x0
    8000422a:	9ce080e7          	jalr	-1586(ra) # 80003bf4 <idup>
    8000422e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004230:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004234:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004236:	4b85                	li	s7,1
    80004238:	a875                	j	800042f4 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    8000423a:	4585                	li	a1,1
    8000423c:	4505                	li	a0,1
    8000423e:	fffff097          	auipc	ra,0xfffff
    80004242:	6b4080e7          	jalr	1716(ra) # 800038f2 <iget>
    80004246:	8a2a                	mv	s4,a0
    80004248:	b7e5                	j	80004230 <namex+0x42>
      iunlockput(ip);
    8000424a:	8552                	mv	a0,s4
    8000424c:	00000097          	auipc	ra,0x0
    80004250:	c4c080e7          	jalr	-948(ra) # 80003e98 <iunlockput>
      return 0;
    80004254:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004256:	8552                	mv	a0,s4
    80004258:	60e6                	ld	ra,88(sp)
    8000425a:	6446                	ld	s0,80(sp)
    8000425c:	64a6                	ld	s1,72(sp)
    8000425e:	6906                	ld	s2,64(sp)
    80004260:	79e2                	ld	s3,56(sp)
    80004262:	7a42                	ld	s4,48(sp)
    80004264:	7aa2                	ld	s5,40(sp)
    80004266:	7b02                	ld	s6,32(sp)
    80004268:	6be2                	ld	s7,24(sp)
    8000426a:	6c42                	ld	s8,16(sp)
    8000426c:	6ca2                	ld	s9,8(sp)
    8000426e:	6125                	addi	sp,sp,96
    80004270:	8082                	ret
      iunlock(ip);
    80004272:	8552                	mv	a0,s4
    80004274:	00000097          	auipc	ra,0x0
    80004278:	a84080e7          	jalr	-1404(ra) # 80003cf8 <iunlock>
      return ip;
    8000427c:	bfe9                	j	80004256 <namex+0x68>
      iunlockput(ip);
    8000427e:	8552                	mv	a0,s4
    80004280:	00000097          	auipc	ra,0x0
    80004284:	c18080e7          	jalr	-1000(ra) # 80003e98 <iunlockput>
      return 0;
    80004288:	8a4e                	mv	s4,s3
    8000428a:	b7f1                	j	80004256 <namex+0x68>
  len = path - s;
    8000428c:	40998633          	sub	a2,s3,s1
    80004290:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004294:	099c5863          	bge	s8,s9,80004324 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80004298:	4639                	li	a2,14
    8000429a:	85a6                	mv	a1,s1
    8000429c:	8556                	mv	a0,s5
    8000429e:	ffffd097          	auipc	ra,0xffffd
    800042a2:	bba080e7          	jalr	-1094(ra) # 80000e58 <memmove>
    800042a6:	84ce                	mv	s1,s3
  while(*path == '/')
    800042a8:	0004c783          	lbu	a5,0(s1)
    800042ac:	01279763          	bne	a5,s2,800042ba <namex+0xcc>
    path++;
    800042b0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042b2:	0004c783          	lbu	a5,0(s1)
    800042b6:	ff278de3          	beq	a5,s2,800042b0 <namex+0xc2>
    ilock(ip);
    800042ba:	8552                	mv	a0,s4
    800042bc:	00000097          	auipc	ra,0x0
    800042c0:	976080e7          	jalr	-1674(ra) # 80003c32 <ilock>
    if(ip->type != T_DIR){
    800042c4:	044a1783          	lh	a5,68(s4)
    800042c8:	f97791e3          	bne	a5,s7,8000424a <namex+0x5c>
    if(nameiparent && *path == '\0'){
    800042cc:	000b0563          	beqz	s6,800042d6 <namex+0xe8>
    800042d0:	0004c783          	lbu	a5,0(s1)
    800042d4:	dfd9                	beqz	a5,80004272 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    800042d6:	4601                	li	a2,0
    800042d8:	85d6                	mv	a1,s5
    800042da:	8552                	mv	a0,s4
    800042dc:	00000097          	auipc	ra,0x0
    800042e0:	e62080e7          	jalr	-414(ra) # 8000413e <dirlookup>
    800042e4:	89aa                	mv	s3,a0
    800042e6:	dd41                	beqz	a0,8000427e <namex+0x90>
    iunlockput(ip);
    800042e8:	8552                	mv	a0,s4
    800042ea:	00000097          	auipc	ra,0x0
    800042ee:	bae080e7          	jalr	-1106(ra) # 80003e98 <iunlockput>
    ip = next;
    800042f2:	8a4e                	mv	s4,s3
  while(*path == '/')
    800042f4:	0004c783          	lbu	a5,0(s1)
    800042f8:	01279763          	bne	a5,s2,80004306 <namex+0x118>
    path++;
    800042fc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042fe:	0004c783          	lbu	a5,0(s1)
    80004302:	ff278de3          	beq	a5,s2,800042fc <namex+0x10e>
  if(*path == 0)
    80004306:	cb9d                	beqz	a5,8000433c <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004308:	0004c783          	lbu	a5,0(s1)
    8000430c:	89a6                	mv	s3,s1
  len = path - s;
    8000430e:	4c81                	li	s9,0
    80004310:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004312:	01278963          	beq	a5,s2,80004324 <namex+0x136>
    80004316:	dbbd                	beqz	a5,8000428c <namex+0x9e>
    path++;
    80004318:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000431a:	0009c783          	lbu	a5,0(s3)
    8000431e:	ff279ce3          	bne	a5,s2,80004316 <namex+0x128>
    80004322:	b7ad                	j	8000428c <namex+0x9e>
    memmove(name, s, len);
    80004324:	2601                	sext.w	a2,a2
    80004326:	85a6                	mv	a1,s1
    80004328:	8556                	mv	a0,s5
    8000432a:	ffffd097          	auipc	ra,0xffffd
    8000432e:	b2e080e7          	jalr	-1234(ra) # 80000e58 <memmove>
    name[len] = 0;
    80004332:	9cd6                	add	s9,s9,s5
    80004334:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004338:	84ce                	mv	s1,s3
    8000433a:	b7bd                	j	800042a8 <namex+0xba>
  if(nameiparent){
    8000433c:	f00b0de3          	beqz	s6,80004256 <namex+0x68>
    iput(ip);
    80004340:	8552                	mv	a0,s4
    80004342:	00000097          	auipc	ra,0x0
    80004346:	aae080e7          	jalr	-1362(ra) # 80003df0 <iput>
    return 0;
    8000434a:	4a01                	li	s4,0
    8000434c:	b729                	j	80004256 <namex+0x68>

000000008000434e <dirlink>:
{
    8000434e:	7139                	addi	sp,sp,-64
    80004350:	fc06                	sd	ra,56(sp)
    80004352:	f822                	sd	s0,48(sp)
    80004354:	f04a                	sd	s2,32(sp)
    80004356:	ec4e                	sd	s3,24(sp)
    80004358:	e852                	sd	s4,16(sp)
    8000435a:	0080                	addi	s0,sp,64
    8000435c:	892a                	mv	s2,a0
    8000435e:	8a2e                	mv	s4,a1
    80004360:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004362:	4601                	li	a2,0
    80004364:	00000097          	auipc	ra,0x0
    80004368:	dda080e7          	jalr	-550(ra) # 8000413e <dirlookup>
    8000436c:	ed25                	bnez	a0,800043e4 <dirlink+0x96>
    8000436e:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004370:	04c92483          	lw	s1,76(s2)
    80004374:	c49d                	beqz	s1,800043a2 <dirlink+0x54>
    80004376:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004378:	4741                	li	a4,16
    8000437a:	86a6                	mv	a3,s1
    8000437c:	fc040613          	addi	a2,s0,-64
    80004380:	4581                	li	a1,0
    80004382:	854a                	mv	a0,s2
    80004384:	00000097          	auipc	ra,0x0
    80004388:	b66080e7          	jalr	-1178(ra) # 80003eea <readi>
    8000438c:	47c1                	li	a5,16
    8000438e:	06f51163          	bne	a0,a5,800043f0 <dirlink+0xa2>
    if(de.inum == 0)
    80004392:	fc045783          	lhu	a5,-64(s0)
    80004396:	c791                	beqz	a5,800043a2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004398:	24c1                	addiw	s1,s1,16
    8000439a:	04c92783          	lw	a5,76(s2)
    8000439e:	fcf4ede3          	bltu	s1,a5,80004378 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800043a2:	4639                	li	a2,14
    800043a4:	85d2                	mv	a1,s4
    800043a6:	fc240513          	addi	a0,s0,-62
    800043aa:	ffffd097          	auipc	ra,0xffffd
    800043ae:	b58080e7          	jalr	-1192(ra) # 80000f02 <strncpy>
  de.inum = inum;
    800043b2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043b6:	4741                	li	a4,16
    800043b8:	86a6                	mv	a3,s1
    800043ba:	fc040613          	addi	a2,s0,-64
    800043be:	4581                	li	a1,0
    800043c0:	854a                	mv	a0,s2
    800043c2:	00000097          	auipc	ra,0x0
    800043c6:	c38080e7          	jalr	-968(ra) # 80003ffa <writei>
    800043ca:	1541                	addi	a0,a0,-16
    800043cc:	00a03533          	snez	a0,a0
    800043d0:	40a00533          	neg	a0,a0
    800043d4:	74a2                	ld	s1,40(sp)
}
    800043d6:	70e2                	ld	ra,56(sp)
    800043d8:	7442                	ld	s0,48(sp)
    800043da:	7902                	ld	s2,32(sp)
    800043dc:	69e2                	ld	s3,24(sp)
    800043de:	6a42                	ld	s4,16(sp)
    800043e0:	6121                	addi	sp,sp,64
    800043e2:	8082                	ret
    iput(ip);
    800043e4:	00000097          	auipc	ra,0x0
    800043e8:	a0c080e7          	jalr	-1524(ra) # 80003df0 <iput>
    return -1;
    800043ec:	557d                	li	a0,-1
    800043ee:	b7e5                	j	800043d6 <dirlink+0x88>
      panic("dirlink read");
    800043f0:	00004517          	auipc	a0,0x4
    800043f4:	22850513          	addi	a0,a0,552 # 80008618 <__func__.1+0x610>
    800043f8:	ffffc097          	auipc	ra,0xffffc
    800043fc:	168080e7          	jalr	360(ra) # 80000560 <panic>

0000000080004400 <namei>:

struct inode*
namei(char *path)
{
    80004400:	1101                	addi	sp,sp,-32
    80004402:	ec06                	sd	ra,24(sp)
    80004404:	e822                	sd	s0,16(sp)
    80004406:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004408:	fe040613          	addi	a2,s0,-32
    8000440c:	4581                	li	a1,0
    8000440e:	00000097          	auipc	ra,0x0
    80004412:	de0080e7          	jalr	-544(ra) # 800041ee <namex>
}
    80004416:	60e2                	ld	ra,24(sp)
    80004418:	6442                	ld	s0,16(sp)
    8000441a:	6105                	addi	sp,sp,32
    8000441c:	8082                	ret

000000008000441e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000441e:	1141                	addi	sp,sp,-16
    80004420:	e406                	sd	ra,8(sp)
    80004422:	e022                	sd	s0,0(sp)
    80004424:	0800                	addi	s0,sp,16
    80004426:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004428:	4585                	li	a1,1
    8000442a:	00000097          	auipc	ra,0x0
    8000442e:	dc4080e7          	jalr	-572(ra) # 800041ee <namex>
}
    80004432:	60a2                	ld	ra,8(sp)
    80004434:	6402                	ld	s0,0(sp)
    80004436:	0141                	addi	sp,sp,16
    80004438:	8082                	ret

000000008000443a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000443a:	1101                	addi	sp,sp,-32
    8000443c:	ec06                	sd	ra,24(sp)
    8000443e:	e822                	sd	s0,16(sp)
    80004440:	e426                	sd	s1,8(sp)
    80004442:	e04a                	sd	s2,0(sp)
    80004444:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004446:	0001f917          	auipc	s2,0x1f
    8000444a:	31a90913          	addi	s2,s2,794 # 80023760 <log>
    8000444e:	01892583          	lw	a1,24(s2)
    80004452:	02892503          	lw	a0,40(s2)
    80004456:	fffff097          	auipc	ra,0xfffff
    8000445a:	fa8080e7          	jalr	-88(ra) # 800033fe <bread>
    8000445e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004460:	02c92603          	lw	a2,44(s2)
    80004464:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004466:	00c05f63          	blez	a2,80004484 <write_head+0x4a>
    8000446a:	0001f717          	auipc	a4,0x1f
    8000446e:	32670713          	addi	a4,a4,806 # 80023790 <log+0x30>
    80004472:	87aa                	mv	a5,a0
    80004474:	060a                	slli	a2,a2,0x2
    80004476:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004478:	4314                	lw	a3,0(a4)
    8000447a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000447c:	0711                	addi	a4,a4,4
    8000447e:	0791                	addi	a5,a5,4
    80004480:	fec79ce3          	bne	a5,a2,80004478 <write_head+0x3e>
  }
  bwrite(buf);
    80004484:	8526                	mv	a0,s1
    80004486:	fffff097          	auipc	ra,0xfffff
    8000448a:	06a080e7          	jalr	106(ra) # 800034f0 <bwrite>
  brelse(buf);
    8000448e:	8526                	mv	a0,s1
    80004490:	fffff097          	auipc	ra,0xfffff
    80004494:	09e080e7          	jalr	158(ra) # 8000352e <brelse>
}
    80004498:	60e2                	ld	ra,24(sp)
    8000449a:	6442                	ld	s0,16(sp)
    8000449c:	64a2                	ld	s1,8(sp)
    8000449e:	6902                	ld	s2,0(sp)
    800044a0:	6105                	addi	sp,sp,32
    800044a2:	8082                	ret

00000000800044a4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800044a4:	0001f797          	auipc	a5,0x1f
    800044a8:	2e87a783          	lw	a5,744(a5) # 8002378c <log+0x2c>
    800044ac:	0af05d63          	blez	a5,80004566 <install_trans+0xc2>
{
    800044b0:	7139                	addi	sp,sp,-64
    800044b2:	fc06                	sd	ra,56(sp)
    800044b4:	f822                	sd	s0,48(sp)
    800044b6:	f426                	sd	s1,40(sp)
    800044b8:	f04a                	sd	s2,32(sp)
    800044ba:	ec4e                	sd	s3,24(sp)
    800044bc:	e852                	sd	s4,16(sp)
    800044be:	e456                	sd	s5,8(sp)
    800044c0:	e05a                	sd	s6,0(sp)
    800044c2:	0080                	addi	s0,sp,64
    800044c4:	8b2a                	mv	s6,a0
    800044c6:	0001fa97          	auipc	s5,0x1f
    800044ca:	2caa8a93          	addi	s5,s5,714 # 80023790 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ce:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044d0:	0001f997          	auipc	s3,0x1f
    800044d4:	29098993          	addi	s3,s3,656 # 80023760 <log>
    800044d8:	a00d                	j	800044fa <install_trans+0x56>
    brelse(lbuf);
    800044da:	854a                	mv	a0,s2
    800044dc:	fffff097          	auipc	ra,0xfffff
    800044e0:	052080e7          	jalr	82(ra) # 8000352e <brelse>
    brelse(dbuf);
    800044e4:	8526                	mv	a0,s1
    800044e6:	fffff097          	auipc	ra,0xfffff
    800044ea:	048080e7          	jalr	72(ra) # 8000352e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ee:	2a05                	addiw	s4,s4,1
    800044f0:	0a91                	addi	s5,s5,4
    800044f2:	02c9a783          	lw	a5,44(s3)
    800044f6:	04fa5e63          	bge	s4,a5,80004552 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044fa:	0189a583          	lw	a1,24(s3)
    800044fe:	014585bb          	addw	a1,a1,s4
    80004502:	2585                	addiw	a1,a1,1
    80004504:	0289a503          	lw	a0,40(s3)
    80004508:	fffff097          	auipc	ra,0xfffff
    8000450c:	ef6080e7          	jalr	-266(ra) # 800033fe <bread>
    80004510:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004512:	000aa583          	lw	a1,0(s5)
    80004516:	0289a503          	lw	a0,40(s3)
    8000451a:	fffff097          	auipc	ra,0xfffff
    8000451e:	ee4080e7          	jalr	-284(ra) # 800033fe <bread>
    80004522:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004524:	40000613          	li	a2,1024
    80004528:	05890593          	addi	a1,s2,88
    8000452c:	05850513          	addi	a0,a0,88
    80004530:	ffffd097          	auipc	ra,0xffffd
    80004534:	928080e7          	jalr	-1752(ra) # 80000e58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004538:	8526                	mv	a0,s1
    8000453a:	fffff097          	auipc	ra,0xfffff
    8000453e:	fb6080e7          	jalr	-74(ra) # 800034f0 <bwrite>
    if(recovering == 0)
    80004542:	f80b1ce3          	bnez	s6,800044da <install_trans+0x36>
      bunpin(dbuf);
    80004546:	8526                	mv	a0,s1
    80004548:	fffff097          	auipc	ra,0xfffff
    8000454c:	0be080e7          	jalr	190(ra) # 80003606 <bunpin>
    80004550:	b769                	j	800044da <install_trans+0x36>
}
    80004552:	70e2                	ld	ra,56(sp)
    80004554:	7442                	ld	s0,48(sp)
    80004556:	74a2                	ld	s1,40(sp)
    80004558:	7902                	ld	s2,32(sp)
    8000455a:	69e2                	ld	s3,24(sp)
    8000455c:	6a42                	ld	s4,16(sp)
    8000455e:	6aa2                	ld	s5,8(sp)
    80004560:	6b02                	ld	s6,0(sp)
    80004562:	6121                	addi	sp,sp,64
    80004564:	8082                	ret
    80004566:	8082                	ret

0000000080004568 <initlog>:
{
    80004568:	7179                	addi	sp,sp,-48
    8000456a:	f406                	sd	ra,40(sp)
    8000456c:	f022                	sd	s0,32(sp)
    8000456e:	ec26                	sd	s1,24(sp)
    80004570:	e84a                	sd	s2,16(sp)
    80004572:	e44e                	sd	s3,8(sp)
    80004574:	1800                	addi	s0,sp,48
    80004576:	892a                	mv	s2,a0
    80004578:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000457a:	0001f497          	auipc	s1,0x1f
    8000457e:	1e648493          	addi	s1,s1,486 # 80023760 <log>
    80004582:	00004597          	auipc	a1,0x4
    80004586:	0a658593          	addi	a1,a1,166 # 80008628 <__func__.1+0x620>
    8000458a:	8526                	mv	a0,s1
    8000458c:	ffffc097          	auipc	ra,0xffffc
    80004590:	6e4080e7          	jalr	1764(ra) # 80000c70 <initlock>
  log.start = sb->logstart;
    80004594:	0149a583          	lw	a1,20(s3)
    80004598:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000459a:	0109a783          	lw	a5,16(s3)
    8000459e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800045a0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800045a4:	854a                	mv	a0,s2
    800045a6:	fffff097          	auipc	ra,0xfffff
    800045aa:	e58080e7          	jalr	-424(ra) # 800033fe <bread>
  log.lh.n = lh->n;
    800045ae:	4d30                	lw	a2,88(a0)
    800045b0:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045b2:	00c05f63          	blez	a2,800045d0 <initlog+0x68>
    800045b6:	87aa                	mv	a5,a0
    800045b8:	0001f717          	auipc	a4,0x1f
    800045bc:	1d870713          	addi	a4,a4,472 # 80023790 <log+0x30>
    800045c0:	060a                	slli	a2,a2,0x2
    800045c2:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800045c4:	4ff4                	lw	a3,92(a5)
    800045c6:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045c8:	0791                	addi	a5,a5,4
    800045ca:	0711                	addi	a4,a4,4
    800045cc:	fec79ce3          	bne	a5,a2,800045c4 <initlog+0x5c>
  brelse(buf);
    800045d0:	fffff097          	auipc	ra,0xfffff
    800045d4:	f5e080e7          	jalr	-162(ra) # 8000352e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045d8:	4505                	li	a0,1
    800045da:	00000097          	auipc	ra,0x0
    800045de:	eca080e7          	jalr	-310(ra) # 800044a4 <install_trans>
  log.lh.n = 0;
    800045e2:	0001f797          	auipc	a5,0x1f
    800045e6:	1a07a523          	sw	zero,426(a5) # 8002378c <log+0x2c>
  write_head(); // clear the log
    800045ea:	00000097          	auipc	ra,0x0
    800045ee:	e50080e7          	jalr	-432(ra) # 8000443a <write_head>
}
    800045f2:	70a2                	ld	ra,40(sp)
    800045f4:	7402                	ld	s0,32(sp)
    800045f6:	64e2                	ld	s1,24(sp)
    800045f8:	6942                	ld	s2,16(sp)
    800045fa:	69a2                	ld	s3,8(sp)
    800045fc:	6145                	addi	sp,sp,48
    800045fe:	8082                	ret

0000000080004600 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004600:	1101                	addi	sp,sp,-32
    80004602:	ec06                	sd	ra,24(sp)
    80004604:	e822                	sd	s0,16(sp)
    80004606:	e426                	sd	s1,8(sp)
    80004608:	e04a                	sd	s2,0(sp)
    8000460a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000460c:	0001f517          	auipc	a0,0x1f
    80004610:	15450513          	addi	a0,a0,340 # 80023760 <log>
    80004614:	ffffc097          	auipc	ra,0xffffc
    80004618:	6ec080e7          	jalr	1772(ra) # 80000d00 <acquire>
  while(1){
    if(log.committing){
    8000461c:	0001f497          	auipc	s1,0x1f
    80004620:	14448493          	addi	s1,s1,324 # 80023760 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004624:	4979                	li	s2,30
    80004626:	a039                	j	80004634 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004628:	85a6                	mv	a1,s1
    8000462a:	8526                	mv	a0,s1
    8000462c:	ffffe097          	auipc	ra,0xffffe
    80004630:	dfc080e7          	jalr	-516(ra) # 80002428 <sleep>
    if(log.committing){
    80004634:	50dc                	lw	a5,36(s1)
    80004636:	fbed                	bnez	a5,80004628 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004638:	5098                	lw	a4,32(s1)
    8000463a:	2705                	addiw	a4,a4,1
    8000463c:	0027179b          	slliw	a5,a4,0x2
    80004640:	9fb9                	addw	a5,a5,a4
    80004642:	0017979b          	slliw	a5,a5,0x1
    80004646:	54d4                	lw	a3,44(s1)
    80004648:	9fb5                	addw	a5,a5,a3
    8000464a:	00f95963          	bge	s2,a5,8000465c <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000464e:	85a6                	mv	a1,s1
    80004650:	8526                	mv	a0,s1
    80004652:	ffffe097          	auipc	ra,0xffffe
    80004656:	dd6080e7          	jalr	-554(ra) # 80002428 <sleep>
    8000465a:	bfe9                	j	80004634 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000465c:	0001f517          	auipc	a0,0x1f
    80004660:	10450513          	addi	a0,a0,260 # 80023760 <log>
    80004664:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004666:	ffffc097          	auipc	ra,0xffffc
    8000466a:	74e080e7          	jalr	1870(ra) # 80000db4 <release>
      break;
    }
  }
}
    8000466e:	60e2                	ld	ra,24(sp)
    80004670:	6442                	ld	s0,16(sp)
    80004672:	64a2                	ld	s1,8(sp)
    80004674:	6902                	ld	s2,0(sp)
    80004676:	6105                	addi	sp,sp,32
    80004678:	8082                	ret

000000008000467a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000467a:	7139                	addi	sp,sp,-64
    8000467c:	fc06                	sd	ra,56(sp)
    8000467e:	f822                	sd	s0,48(sp)
    80004680:	f426                	sd	s1,40(sp)
    80004682:	f04a                	sd	s2,32(sp)
    80004684:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004686:	0001f497          	auipc	s1,0x1f
    8000468a:	0da48493          	addi	s1,s1,218 # 80023760 <log>
    8000468e:	8526                	mv	a0,s1
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	670080e7          	jalr	1648(ra) # 80000d00 <acquire>
  log.outstanding -= 1;
    80004698:	509c                	lw	a5,32(s1)
    8000469a:	37fd                	addiw	a5,a5,-1
    8000469c:	0007891b          	sext.w	s2,a5
    800046a0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800046a2:	50dc                	lw	a5,36(s1)
    800046a4:	e7b9                	bnez	a5,800046f2 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    800046a6:	06091163          	bnez	s2,80004708 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800046aa:	0001f497          	auipc	s1,0x1f
    800046ae:	0b648493          	addi	s1,s1,182 # 80023760 <log>
    800046b2:	4785                	li	a5,1
    800046b4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800046b6:	8526                	mv	a0,s1
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	6fc080e7          	jalr	1788(ra) # 80000db4 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800046c0:	54dc                	lw	a5,44(s1)
    800046c2:	06f04763          	bgtz	a5,80004730 <end_op+0xb6>
    acquire(&log.lock);
    800046c6:	0001f497          	auipc	s1,0x1f
    800046ca:	09a48493          	addi	s1,s1,154 # 80023760 <log>
    800046ce:	8526                	mv	a0,s1
    800046d0:	ffffc097          	auipc	ra,0xffffc
    800046d4:	630080e7          	jalr	1584(ra) # 80000d00 <acquire>
    log.committing = 0;
    800046d8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800046dc:	8526                	mv	a0,s1
    800046de:	ffffe097          	auipc	ra,0xffffe
    800046e2:	dae080e7          	jalr	-594(ra) # 8000248c <wakeup>
    release(&log.lock);
    800046e6:	8526                	mv	a0,s1
    800046e8:	ffffc097          	auipc	ra,0xffffc
    800046ec:	6cc080e7          	jalr	1740(ra) # 80000db4 <release>
}
    800046f0:	a815                	j	80004724 <end_op+0xaa>
    800046f2:	ec4e                	sd	s3,24(sp)
    800046f4:	e852                	sd	s4,16(sp)
    800046f6:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800046f8:	00004517          	auipc	a0,0x4
    800046fc:	f3850513          	addi	a0,a0,-200 # 80008630 <__func__.1+0x628>
    80004700:	ffffc097          	auipc	ra,0xffffc
    80004704:	e60080e7          	jalr	-416(ra) # 80000560 <panic>
    wakeup(&log);
    80004708:	0001f497          	auipc	s1,0x1f
    8000470c:	05848493          	addi	s1,s1,88 # 80023760 <log>
    80004710:	8526                	mv	a0,s1
    80004712:	ffffe097          	auipc	ra,0xffffe
    80004716:	d7a080e7          	jalr	-646(ra) # 8000248c <wakeup>
  release(&log.lock);
    8000471a:	8526                	mv	a0,s1
    8000471c:	ffffc097          	auipc	ra,0xffffc
    80004720:	698080e7          	jalr	1688(ra) # 80000db4 <release>
}
    80004724:	70e2                	ld	ra,56(sp)
    80004726:	7442                	ld	s0,48(sp)
    80004728:	74a2                	ld	s1,40(sp)
    8000472a:	7902                	ld	s2,32(sp)
    8000472c:	6121                	addi	sp,sp,64
    8000472e:	8082                	ret
    80004730:	ec4e                	sd	s3,24(sp)
    80004732:	e852                	sd	s4,16(sp)
    80004734:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004736:	0001fa97          	auipc	s5,0x1f
    8000473a:	05aa8a93          	addi	s5,s5,90 # 80023790 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000473e:	0001fa17          	auipc	s4,0x1f
    80004742:	022a0a13          	addi	s4,s4,34 # 80023760 <log>
    80004746:	018a2583          	lw	a1,24(s4)
    8000474a:	012585bb          	addw	a1,a1,s2
    8000474e:	2585                	addiw	a1,a1,1
    80004750:	028a2503          	lw	a0,40(s4)
    80004754:	fffff097          	auipc	ra,0xfffff
    80004758:	caa080e7          	jalr	-854(ra) # 800033fe <bread>
    8000475c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000475e:	000aa583          	lw	a1,0(s5)
    80004762:	028a2503          	lw	a0,40(s4)
    80004766:	fffff097          	auipc	ra,0xfffff
    8000476a:	c98080e7          	jalr	-872(ra) # 800033fe <bread>
    8000476e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004770:	40000613          	li	a2,1024
    80004774:	05850593          	addi	a1,a0,88
    80004778:	05848513          	addi	a0,s1,88
    8000477c:	ffffc097          	auipc	ra,0xffffc
    80004780:	6dc080e7          	jalr	1756(ra) # 80000e58 <memmove>
    bwrite(to);  // write the log
    80004784:	8526                	mv	a0,s1
    80004786:	fffff097          	auipc	ra,0xfffff
    8000478a:	d6a080e7          	jalr	-662(ra) # 800034f0 <bwrite>
    brelse(from);
    8000478e:	854e                	mv	a0,s3
    80004790:	fffff097          	auipc	ra,0xfffff
    80004794:	d9e080e7          	jalr	-610(ra) # 8000352e <brelse>
    brelse(to);
    80004798:	8526                	mv	a0,s1
    8000479a:	fffff097          	auipc	ra,0xfffff
    8000479e:	d94080e7          	jalr	-620(ra) # 8000352e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047a2:	2905                	addiw	s2,s2,1
    800047a4:	0a91                	addi	s5,s5,4
    800047a6:	02ca2783          	lw	a5,44(s4)
    800047aa:	f8f94ee3          	blt	s2,a5,80004746 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	c8c080e7          	jalr	-884(ra) # 8000443a <write_head>
    install_trans(0); // Now install writes to home locations
    800047b6:	4501                	li	a0,0
    800047b8:	00000097          	auipc	ra,0x0
    800047bc:	cec080e7          	jalr	-788(ra) # 800044a4 <install_trans>
    log.lh.n = 0;
    800047c0:	0001f797          	auipc	a5,0x1f
    800047c4:	fc07a623          	sw	zero,-52(a5) # 8002378c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800047c8:	00000097          	auipc	ra,0x0
    800047cc:	c72080e7          	jalr	-910(ra) # 8000443a <write_head>
    800047d0:	69e2                	ld	s3,24(sp)
    800047d2:	6a42                	ld	s4,16(sp)
    800047d4:	6aa2                	ld	s5,8(sp)
    800047d6:	bdc5                	j	800046c6 <end_op+0x4c>

00000000800047d8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800047d8:	1101                	addi	sp,sp,-32
    800047da:	ec06                	sd	ra,24(sp)
    800047dc:	e822                	sd	s0,16(sp)
    800047de:	e426                	sd	s1,8(sp)
    800047e0:	e04a                	sd	s2,0(sp)
    800047e2:	1000                	addi	s0,sp,32
    800047e4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800047e6:	0001f917          	auipc	s2,0x1f
    800047ea:	f7a90913          	addi	s2,s2,-134 # 80023760 <log>
    800047ee:	854a                	mv	a0,s2
    800047f0:	ffffc097          	auipc	ra,0xffffc
    800047f4:	510080e7          	jalr	1296(ra) # 80000d00 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047f8:	02c92603          	lw	a2,44(s2)
    800047fc:	47f5                	li	a5,29
    800047fe:	06c7c563          	blt	a5,a2,80004868 <log_write+0x90>
    80004802:	0001f797          	auipc	a5,0x1f
    80004806:	f7a7a783          	lw	a5,-134(a5) # 8002377c <log+0x1c>
    8000480a:	37fd                	addiw	a5,a5,-1
    8000480c:	04f65e63          	bge	a2,a5,80004868 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004810:	0001f797          	auipc	a5,0x1f
    80004814:	f707a783          	lw	a5,-144(a5) # 80023780 <log+0x20>
    80004818:	06f05063          	blez	a5,80004878 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000481c:	4781                	li	a5,0
    8000481e:	06c05563          	blez	a2,80004888 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004822:	44cc                	lw	a1,12(s1)
    80004824:	0001f717          	auipc	a4,0x1f
    80004828:	f6c70713          	addi	a4,a4,-148 # 80023790 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000482c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000482e:	4314                	lw	a3,0(a4)
    80004830:	04b68c63          	beq	a3,a1,80004888 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004834:	2785                	addiw	a5,a5,1
    80004836:	0711                	addi	a4,a4,4
    80004838:	fef61be3          	bne	a2,a5,8000482e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000483c:	0621                	addi	a2,a2,8
    8000483e:	060a                	slli	a2,a2,0x2
    80004840:	0001f797          	auipc	a5,0x1f
    80004844:	f2078793          	addi	a5,a5,-224 # 80023760 <log>
    80004848:	97b2                	add	a5,a5,a2
    8000484a:	44d8                	lw	a4,12(s1)
    8000484c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000484e:	8526                	mv	a0,s1
    80004850:	fffff097          	auipc	ra,0xfffff
    80004854:	d7a080e7          	jalr	-646(ra) # 800035ca <bpin>
    log.lh.n++;
    80004858:	0001f717          	auipc	a4,0x1f
    8000485c:	f0870713          	addi	a4,a4,-248 # 80023760 <log>
    80004860:	575c                	lw	a5,44(a4)
    80004862:	2785                	addiw	a5,a5,1
    80004864:	d75c                	sw	a5,44(a4)
    80004866:	a82d                	j	800048a0 <log_write+0xc8>
    panic("too big a transaction");
    80004868:	00004517          	auipc	a0,0x4
    8000486c:	dd850513          	addi	a0,a0,-552 # 80008640 <__func__.1+0x638>
    80004870:	ffffc097          	auipc	ra,0xffffc
    80004874:	cf0080e7          	jalr	-784(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004878:	00004517          	auipc	a0,0x4
    8000487c:	de050513          	addi	a0,a0,-544 # 80008658 <__func__.1+0x650>
    80004880:	ffffc097          	auipc	ra,0xffffc
    80004884:	ce0080e7          	jalr	-800(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004888:	00878693          	addi	a3,a5,8
    8000488c:	068a                	slli	a3,a3,0x2
    8000488e:	0001f717          	auipc	a4,0x1f
    80004892:	ed270713          	addi	a4,a4,-302 # 80023760 <log>
    80004896:	9736                	add	a4,a4,a3
    80004898:	44d4                	lw	a3,12(s1)
    8000489a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000489c:	faf609e3          	beq	a2,a5,8000484e <log_write+0x76>
  }
  release(&log.lock);
    800048a0:	0001f517          	auipc	a0,0x1f
    800048a4:	ec050513          	addi	a0,a0,-320 # 80023760 <log>
    800048a8:	ffffc097          	auipc	ra,0xffffc
    800048ac:	50c080e7          	jalr	1292(ra) # 80000db4 <release>
}
    800048b0:	60e2                	ld	ra,24(sp)
    800048b2:	6442                	ld	s0,16(sp)
    800048b4:	64a2                	ld	s1,8(sp)
    800048b6:	6902                	ld	s2,0(sp)
    800048b8:	6105                	addi	sp,sp,32
    800048ba:	8082                	ret

00000000800048bc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800048bc:	1101                	addi	sp,sp,-32
    800048be:	ec06                	sd	ra,24(sp)
    800048c0:	e822                	sd	s0,16(sp)
    800048c2:	e426                	sd	s1,8(sp)
    800048c4:	e04a                	sd	s2,0(sp)
    800048c6:	1000                	addi	s0,sp,32
    800048c8:	84aa                	mv	s1,a0
    800048ca:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048cc:	00004597          	auipc	a1,0x4
    800048d0:	dac58593          	addi	a1,a1,-596 # 80008678 <__func__.1+0x670>
    800048d4:	0521                	addi	a0,a0,8
    800048d6:	ffffc097          	auipc	ra,0xffffc
    800048da:	39a080e7          	jalr	922(ra) # 80000c70 <initlock>
  lk->name = name;
    800048de:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800048e2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048e6:	0204a423          	sw	zero,40(s1)
}
    800048ea:	60e2                	ld	ra,24(sp)
    800048ec:	6442                	ld	s0,16(sp)
    800048ee:	64a2                	ld	s1,8(sp)
    800048f0:	6902                	ld	s2,0(sp)
    800048f2:	6105                	addi	sp,sp,32
    800048f4:	8082                	ret

00000000800048f6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048f6:	1101                	addi	sp,sp,-32
    800048f8:	ec06                	sd	ra,24(sp)
    800048fa:	e822                	sd	s0,16(sp)
    800048fc:	e426                	sd	s1,8(sp)
    800048fe:	e04a                	sd	s2,0(sp)
    80004900:	1000                	addi	s0,sp,32
    80004902:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004904:	00850913          	addi	s2,a0,8
    80004908:	854a                	mv	a0,s2
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	3f6080e7          	jalr	1014(ra) # 80000d00 <acquire>
  while (lk->locked) {
    80004912:	409c                	lw	a5,0(s1)
    80004914:	cb89                	beqz	a5,80004926 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004916:	85ca                	mv	a1,s2
    80004918:	8526                	mv	a0,s1
    8000491a:	ffffe097          	auipc	ra,0xffffe
    8000491e:	b0e080e7          	jalr	-1266(ra) # 80002428 <sleep>
  while (lk->locked) {
    80004922:	409c                	lw	a5,0(s1)
    80004924:	fbed                	bnez	a5,80004916 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004926:	4785                	li	a5,1
    80004928:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000492a:	ffffd097          	auipc	ra,0xffffd
    8000492e:	34c080e7          	jalr	844(ra) # 80001c76 <myproc>
    80004932:	591c                	lw	a5,48(a0)
    80004934:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004936:	854a                	mv	a0,s2
    80004938:	ffffc097          	auipc	ra,0xffffc
    8000493c:	47c080e7          	jalr	1148(ra) # 80000db4 <release>
}
    80004940:	60e2                	ld	ra,24(sp)
    80004942:	6442                	ld	s0,16(sp)
    80004944:	64a2                	ld	s1,8(sp)
    80004946:	6902                	ld	s2,0(sp)
    80004948:	6105                	addi	sp,sp,32
    8000494a:	8082                	ret

000000008000494c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000494c:	1101                	addi	sp,sp,-32
    8000494e:	ec06                	sd	ra,24(sp)
    80004950:	e822                	sd	s0,16(sp)
    80004952:	e426                	sd	s1,8(sp)
    80004954:	e04a                	sd	s2,0(sp)
    80004956:	1000                	addi	s0,sp,32
    80004958:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000495a:	00850913          	addi	s2,a0,8
    8000495e:	854a                	mv	a0,s2
    80004960:	ffffc097          	auipc	ra,0xffffc
    80004964:	3a0080e7          	jalr	928(ra) # 80000d00 <acquire>
  lk->locked = 0;
    80004968:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000496c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004970:	8526                	mv	a0,s1
    80004972:	ffffe097          	auipc	ra,0xffffe
    80004976:	b1a080e7          	jalr	-1254(ra) # 8000248c <wakeup>
  release(&lk->lk);
    8000497a:	854a                	mv	a0,s2
    8000497c:	ffffc097          	auipc	ra,0xffffc
    80004980:	438080e7          	jalr	1080(ra) # 80000db4 <release>
}
    80004984:	60e2                	ld	ra,24(sp)
    80004986:	6442                	ld	s0,16(sp)
    80004988:	64a2                	ld	s1,8(sp)
    8000498a:	6902                	ld	s2,0(sp)
    8000498c:	6105                	addi	sp,sp,32
    8000498e:	8082                	ret

0000000080004990 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004990:	7179                	addi	sp,sp,-48
    80004992:	f406                	sd	ra,40(sp)
    80004994:	f022                	sd	s0,32(sp)
    80004996:	ec26                	sd	s1,24(sp)
    80004998:	e84a                	sd	s2,16(sp)
    8000499a:	1800                	addi	s0,sp,48
    8000499c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000499e:	00850913          	addi	s2,a0,8
    800049a2:	854a                	mv	a0,s2
    800049a4:	ffffc097          	auipc	ra,0xffffc
    800049a8:	35c080e7          	jalr	860(ra) # 80000d00 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049ac:	409c                	lw	a5,0(s1)
    800049ae:	ef91                	bnez	a5,800049ca <holdingsleep+0x3a>
    800049b0:	4481                	li	s1,0
  release(&lk->lk);
    800049b2:	854a                	mv	a0,s2
    800049b4:	ffffc097          	auipc	ra,0xffffc
    800049b8:	400080e7          	jalr	1024(ra) # 80000db4 <release>
  return r;
}
    800049bc:	8526                	mv	a0,s1
    800049be:	70a2                	ld	ra,40(sp)
    800049c0:	7402                	ld	s0,32(sp)
    800049c2:	64e2                	ld	s1,24(sp)
    800049c4:	6942                	ld	s2,16(sp)
    800049c6:	6145                	addi	sp,sp,48
    800049c8:	8082                	ret
    800049ca:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800049cc:	0284a983          	lw	s3,40(s1)
    800049d0:	ffffd097          	auipc	ra,0xffffd
    800049d4:	2a6080e7          	jalr	678(ra) # 80001c76 <myproc>
    800049d8:	5904                	lw	s1,48(a0)
    800049da:	413484b3          	sub	s1,s1,s3
    800049de:	0014b493          	seqz	s1,s1
    800049e2:	69a2                	ld	s3,8(sp)
    800049e4:	b7f9                	j	800049b2 <holdingsleep+0x22>

00000000800049e6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800049e6:	1141                	addi	sp,sp,-16
    800049e8:	e406                	sd	ra,8(sp)
    800049ea:	e022                	sd	s0,0(sp)
    800049ec:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049ee:	00004597          	auipc	a1,0x4
    800049f2:	c9a58593          	addi	a1,a1,-870 # 80008688 <__func__.1+0x680>
    800049f6:	0001f517          	auipc	a0,0x1f
    800049fa:	eb250513          	addi	a0,a0,-334 # 800238a8 <ftable>
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	272080e7          	jalr	626(ra) # 80000c70 <initlock>
}
    80004a06:	60a2                	ld	ra,8(sp)
    80004a08:	6402                	ld	s0,0(sp)
    80004a0a:	0141                	addi	sp,sp,16
    80004a0c:	8082                	ret

0000000080004a0e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a0e:	1101                	addi	sp,sp,-32
    80004a10:	ec06                	sd	ra,24(sp)
    80004a12:	e822                	sd	s0,16(sp)
    80004a14:	e426                	sd	s1,8(sp)
    80004a16:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a18:	0001f517          	auipc	a0,0x1f
    80004a1c:	e9050513          	addi	a0,a0,-368 # 800238a8 <ftable>
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	2e0080e7          	jalr	736(ra) # 80000d00 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a28:	0001f497          	auipc	s1,0x1f
    80004a2c:	e9848493          	addi	s1,s1,-360 # 800238c0 <ftable+0x18>
    80004a30:	00020717          	auipc	a4,0x20
    80004a34:	e3070713          	addi	a4,a4,-464 # 80024860 <disk>
    if(f->ref == 0){
    80004a38:	40dc                	lw	a5,4(s1)
    80004a3a:	cf99                	beqz	a5,80004a58 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a3c:	02848493          	addi	s1,s1,40
    80004a40:	fee49ce3          	bne	s1,a4,80004a38 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a44:	0001f517          	auipc	a0,0x1f
    80004a48:	e6450513          	addi	a0,a0,-412 # 800238a8 <ftable>
    80004a4c:	ffffc097          	auipc	ra,0xffffc
    80004a50:	368080e7          	jalr	872(ra) # 80000db4 <release>
  return 0;
    80004a54:	4481                	li	s1,0
    80004a56:	a819                	j	80004a6c <filealloc+0x5e>
      f->ref = 1;
    80004a58:	4785                	li	a5,1
    80004a5a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a5c:	0001f517          	auipc	a0,0x1f
    80004a60:	e4c50513          	addi	a0,a0,-436 # 800238a8 <ftable>
    80004a64:	ffffc097          	auipc	ra,0xffffc
    80004a68:	350080e7          	jalr	848(ra) # 80000db4 <release>
}
    80004a6c:	8526                	mv	a0,s1
    80004a6e:	60e2                	ld	ra,24(sp)
    80004a70:	6442                	ld	s0,16(sp)
    80004a72:	64a2                	ld	s1,8(sp)
    80004a74:	6105                	addi	sp,sp,32
    80004a76:	8082                	ret

0000000080004a78 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a78:	1101                	addi	sp,sp,-32
    80004a7a:	ec06                	sd	ra,24(sp)
    80004a7c:	e822                	sd	s0,16(sp)
    80004a7e:	e426                	sd	s1,8(sp)
    80004a80:	1000                	addi	s0,sp,32
    80004a82:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a84:	0001f517          	auipc	a0,0x1f
    80004a88:	e2450513          	addi	a0,a0,-476 # 800238a8 <ftable>
    80004a8c:	ffffc097          	auipc	ra,0xffffc
    80004a90:	274080e7          	jalr	628(ra) # 80000d00 <acquire>
  if(f->ref < 1)
    80004a94:	40dc                	lw	a5,4(s1)
    80004a96:	02f05263          	blez	a5,80004aba <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a9a:	2785                	addiw	a5,a5,1
    80004a9c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a9e:	0001f517          	auipc	a0,0x1f
    80004aa2:	e0a50513          	addi	a0,a0,-502 # 800238a8 <ftable>
    80004aa6:	ffffc097          	auipc	ra,0xffffc
    80004aaa:	30e080e7          	jalr	782(ra) # 80000db4 <release>
  return f;
}
    80004aae:	8526                	mv	a0,s1
    80004ab0:	60e2                	ld	ra,24(sp)
    80004ab2:	6442                	ld	s0,16(sp)
    80004ab4:	64a2                	ld	s1,8(sp)
    80004ab6:	6105                	addi	sp,sp,32
    80004ab8:	8082                	ret
    panic("filedup");
    80004aba:	00004517          	auipc	a0,0x4
    80004abe:	bd650513          	addi	a0,a0,-1066 # 80008690 <__func__.1+0x688>
    80004ac2:	ffffc097          	auipc	ra,0xffffc
    80004ac6:	a9e080e7          	jalr	-1378(ra) # 80000560 <panic>

0000000080004aca <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004aca:	7139                	addi	sp,sp,-64
    80004acc:	fc06                	sd	ra,56(sp)
    80004ace:	f822                	sd	s0,48(sp)
    80004ad0:	f426                	sd	s1,40(sp)
    80004ad2:	0080                	addi	s0,sp,64
    80004ad4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ad6:	0001f517          	auipc	a0,0x1f
    80004ada:	dd250513          	addi	a0,a0,-558 # 800238a8 <ftable>
    80004ade:	ffffc097          	auipc	ra,0xffffc
    80004ae2:	222080e7          	jalr	546(ra) # 80000d00 <acquire>
  if(f->ref < 1)
    80004ae6:	40dc                	lw	a5,4(s1)
    80004ae8:	04f05c63          	blez	a5,80004b40 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004aec:	37fd                	addiw	a5,a5,-1
    80004aee:	0007871b          	sext.w	a4,a5
    80004af2:	c0dc                	sw	a5,4(s1)
    80004af4:	06e04263          	bgtz	a4,80004b58 <fileclose+0x8e>
    80004af8:	f04a                	sd	s2,32(sp)
    80004afa:	ec4e                	sd	s3,24(sp)
    80004afc:	e852                	sd	s4,16(sp)
    80004afe:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b00:	0004a903          	lw	s2,0(s1)
    80004b04:	0094ca83          	lbu	s5,9(s1)
    80004b08:	0104ba03          	ld	s4,16(s1)
    80004b0c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b10:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b14:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b18:	0001f517          	auipc	a0,0x1f
    80004b1c:	d9050513          	addi	a0,a0,-624 # 800238a8 <ftable>
    80004b20:	ffffc097          	auipc	ra,0xffffc
    80004b24:	294080e7          	jalr	660(ra) # 80000db4 <release>

  if(ff.type == FD_PIPE){
    80004b28:	4785                	li	a5,1
    80004b2a:	04f90463          	beq	s2,a5,80004b72 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b2e:	3979                	addiw	s2,s2,-2
    80004b30:	4785                	li	a5,1
    80004b32:	0527fb63          	bgeu	a5,s2,80004b88 <fileclose+0xbe>
    80004b36:	7902                	ld	s2,32(sp)
    80004b38:	69e2                	ld	s3,24(sp)
    80004b3a:	6a42                	ld	s4,16(sp)
    80004b3c:	6aa2                	ld	s5,8(sp)
    80004b3e:	a02d                	j	80004b68 <fileclose+0x9e>
    80004b40:	f04a                	sd	s2,32(sp)
    80004b42:	ec4e                	sd	s3,24(sp)
    80004b44:	e852                	sd	s4,16(sp)
    80004b46:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004b48:	00004517          	auipc	a0,0x4
    80004b4c:	b5050513          	addi	a0,a0,-1200 # 80008698 <__func__.1+0x690>
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	a10080e7          	jalr	-1520(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004b58:	0001f517          	auipc	a0,0x1f
    80004b5c:	d5050513          	addi	a0,a0,-688 # 800238a8 <ftable>
    80004b60:	ffffc097          	auipc	ra,0xffffc
    80004b64:	254080e7          	jalr	596(ra) # 80000db4 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004b68:	70e2                	ld	ra,56(sp)
    80004b6a:	7442                	ld	s0,48(sp)
    80004b6c:	74a2                	ld	s1,40(sp)
    80004b6e:	6121                	addi	sp,sp,64
    80004b70:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b72:	85d6                	mv	a1,s5
    80004b74:	8552                	mv	a0,s4
    80004b76:	00000097          	auipc	ra,0x0
    80004b7a:	3a2080e7          	jalr	930(ra) # 80004f18 <pipeclose>
    80004b7e:	7902                	ld	s2,32(sp)
    80004b80:	69e2                	ld	s3,24(sp)
    80004b82:	6a42                	ld	s4,16(sp)
    80004b84:	6aa2                	ld	s5,8(sp)
    80004b86:	b7cd                	j	80004b68 <fileclose+0x9e>
    begin_op();
    80004b88:	00000097          	auipc	ra,0x0
    80004b8c:	a78080e7          	jalr	-1416(ra) # 80004600 <begin_op>
    iput(ff.ip);
    80004b90:	854e                	mv	a0,s3
    80004b92:	fffff097          	auipc	ra,0xfffff
    80004b96:	25e080e7          	jalr	606(ra) # 80003df0 <iput>
    end_op();
    80004b9a:	00000097          	auipc	ra,0x0
    80004b9e:	ae0080e7          	jalr	-1312(ra) # 8000467a <end_op>
    80004ba2:	7902                	ld	s2,32(sp)
    80004ba4:	69e2                	ld	s3,24(sp)
    80004ba6:	6a42                	ld	s4,16(sp)
    80004ba8:	6aa2                	ld	s5,8(sp)
    80004baa:	bf7d                	j	80004b68 <fileclose+0x9e>

0000000080004bac <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004bac:	715d                	addi	sp,sp,-80
    80004bae:	e486                	sd	ra,72(sp)
    80004bb0:	e0a2                	sd	s0,64(sp)
    80004bb2:	fc26                	sd	s1,56(sp)
    80004bb4:	f44e                	sd	s3,40(sp)
    80004bb6:	0880                	addi	s0,sp,80
    80004bb8:	84aa                	mv	s1,a0
    80004bba:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004bbc:	ffffd097          	auipc	ra,0xffffd
    80004bc0:	0ba080e7          	jalr	186(ra) # 80001c76 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004bc4:	409c                	lw	a5,0(s1)
    80004bc6:	37f9                	addiw	a5,a5,-2
    80004bc8:	4705                	li	a4,1
    80004bca:	04f76863          	bltu	a4,a5,80004c1a <filestat+0x6e>
    80004bce:	f84a                	sd	s2,48(sp)
    80004bd0:	892a                	mv	s2,a0
    ilock(f->ip);
    80004bd2:	6c88                	ld	a0,24(s1)
    80004bd4:	fffff097          	auipc	ra,0xfffff
    80004bd8:	05e080e7          	jalr	94(ra) # 80003c32 <ilock>
    stati(f->ip, &st);
    80004bdc:	fb840593          	addi	a1,s0,-72
    80004be0:	6c88                	ld	a0,24(s1)
    80004be2:	fffff097          	auipc	ra,0xfffff
    80004be6:	2de080e7          	jalr	734(ra) # 80003ec0 <stati>
    iunlock(f->ip);
    80004bea:	6c88                	ld	a0,24(s1)
    80004bec:	fffff097          	auipc	ra,0xfffff
    80004bf0:	10c080e7          	jalr	268(ra) # 80003cf8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004bf4:	46e1                	li	a3,24
    80004bf6:	fb840613          	addi	a2,s0,-72
    80004bfa:	85ce                	mv	a1,s3
    80004bfc:	05093503          	ld	a0,80(s2)
    80004c00:	ffffd097          	auipc	ra,0xffffd
    80004c04:	baa080e7          	jalr	-1110(ra) # 800017aa <copyout>
    80004c08:	41f5551b          	sraiw	a0,a0,0x1f
    80004c0c:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004c0e:	60a6                	ld	ra,72(sp)
    80004c10:	6406                	ld	s0,64(sp)
    80004c12:	74e2                	ld	s1,56(sp)
    80004c14:	79a2                	ld	s3,40(sp)
    80004c16:	6161                	addi	sp,sp,80
    80004c18:	8082                	ret
  return -1;
    80004c1a:	557d                	li	a0,-1
    80004c1c:	bfcd                	j	80004c0e <filestat+0x62>

0000000080004c1e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c1e:	7179                	addi	sp,sp,-48
    80004c20:	f406                	sd	ra,40(sp)
    80004c22:	f022                	sd	s0,32(sp)
    80004c24:	e84a                	sd	s2,16(sp)
    80004c26:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c28:	00854783          	lbu	a5,8(a0)
    80004c2c:	cbc5                	beqz	a5,80004cdc <fileread+0xbe>
    80004c2e:	ec26                	sd	s1,24(sp)
    80004c30:	e44e                	sd	s3,8(sp)
    80004c32:	84aa                	mv	s1,a0
    80004c34:	89ae                	mv	s3,a1
    80004c36:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c38:	411c                	lw	a5,0(a0)
    80004c3a:	4705                	li	a4,1
    80004c3c:	04e78963          	beq	a5,a4,80004c8e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c40:	470d                	li	a4,3
    80004c42:	04e78f63          	beq	a5,a4,80004ca0 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c46:	4709                	li	a4,2
    80004c48:	08e79263          	bne	a5,a4,80004ccc <fileread+0xae>
    ilock(f->ip);
    80004c4c:	6d08                	ld	a0,24(a0)
    80004c4e:	fffff097          	auipc	ra,0xfffff
    80004c52:	fe4080e7          	jalr	-28(ra) # 80003c32 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c56:	874a                	mv	a4,s2
    80004c58:	5094                	lw	a3,32(s1)
    80004c5a:	864e                	mv	a2,s3
    80004c5c:	4585                	li	a1,1
    80004c5e:	6c88                	ld	a0,24(s1)
    80004c60:	fffff097          	auipc	ra,0xfffff
    80004c64:	28a080e7          	jalr	650(ra) # 80003eea <readi>
    80004c68:	892a                	mv	s2,a0
    80004c6a:	00a05563          	blez	a0,80004c74 <fileread+0x56>
      f->off += r;
    80004c6e:	509c                	lw	a5,32(s1)
    80004c70:	9fa9                	addw	a5,a5,a0
    80004c72:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c74:	6c88                	ld	a0,24(s1)
    80004c76:	fffff097          	auipc	ra,0xfffff
    80004c7a:	082080e7          	jalr	130(ra) # 80003cf8 <iunlock>
    80004c7e:	64e2                	ld	s1,24(sp)
    80004c80:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004c82:	854a                	mv	a0,s2
    80004c84:	70a2                	ld	ra,40(sp)
    80004c86:	7402                	ld	s0,32(sp)
    80004c88:	6942                	ld	s2,16(sp)
    80004c8a:	6145                	addi	sp,sp,48
    80004c8c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c8e:	6908                	ld	a0,16(a0)
    80004c90:	00000097          	auipc	ra,0x0
    80004c94:	400080e7          	jalr	1024(ra) # 80005090 <piperead>
    80004c98:	892a                	mv	s2,a0
    80004c9a:	64e2                	ld	s1,24(sp)
    80004c9c:	69a2                	ld	s3,8(sp)
    80004c9e:	b7d5                	j	80004c82 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004ca0:	02451783          	lh	a5,36(a0)
    80004ca4:	03079693          	slli	a3,a5,0x30
    80004ca8:	92c1                	srli	a3,a3,0x30
    80004caa:	4725                	li	a4,9
    80004cac:	02d76a63          	bltu	a4,a3,80004ce0 <fileread+0xc2>
    80004cb0:	0792                	slli	a5,a5,0x4
    80004cb2:	0001f717          	auipc	a4,0x1f
    80004cb6:	b5670713          	addi	a4,a4,-1194 # 80023808 <devsw>
    80004cba:	97ba                	add	a5,a5,a4
    80004cbc:	639c                	ld	a5,0(a5)
    80004cbe:	c78d                	beqz	a5,80004ce8 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004cc0:	4505                	li	a0,1
    80004cc2:	9782                	jalr	a5
    80004cc4:	892a                	mv	s2,a0
    80004cc6:	64e2                	ld	s1,24(sp)
    80004cc8:	69a2                	ld	s3,8(sp)
    80004cca:	bf65                	j	80004c82 <fileread+0x64>
    panic("fileread");
    80004ccc:	00004517          	auipc	a0,0x4
    80004cd0:	9dc50513          	addi	a0,a0,-1572 # 800086a8 <__func__.1+0x6a0>
    80004cd4:	ffffc097          	auipc	ra,0xffffc
    80004cd8:	88c080e7          	jalr	-1908(ra) # 80000560 <panic>
    return -1;
    80004cdc:	597d                	li	s2,-1
    80004cde:	b755                	j	80004c82 <fileread+0x64>
      return -1;
    80004ce0:	597d                	li	s2,-1
    80004ce2:	64e2                	ld	s1,24(sp)
    80004ce4:	69a2                	ld	s3,8(sp)
    80004ce6:	bf71                	j	80004c82 <fileread+0x64>
    80004ce8:	597d                	li	s2,-1
    80004cea:	64e2                	ld	s1,24(sp)
    80004cec:	69a2                	ld	s3,8(sp)
    80004cee:	bf51                	j	80004c82 <fileread+0x64>

0000000080004cf0 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004cf0:	00954783          	lbu	a5,9(a0)
    80004cf4:	12078963          	beqz	a5,80004e26 <filewrite+0x136>
{
    80004cf8:	715d                	addi	sp,sp,-80
    80004cfa:	e486                	sd	ra,72(sp)
    80004cfc:	e0a2                	sd	s0,64(sp)
    80004cfe:	f84a                	sd	s2,48(sp)
    80004d00:	f052                	sd	s4,32(sp)
    80004d02:	e85a                	sd	s6,16(sp)
    80004d04:	0880                	addi	s0,sp,80
    80004d06:	892a                	mv	s2,a0
    80004d08:	8b2e                	mv	s6,a1
    80004d0a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d0c:	411c                	lw	a5,0(a0)
    80004d0e:	4705                	li	a4,1
    80004d10:	02e78763          	beq	a5,a4,80004d3e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d14:	470d                	li	a4,3
    80004d16:	02e78a63          	beq	a5,a4,80004d4a <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d1a:	4709                	li	a4,2
    80004d1c:	0ee79863          	bne	a5,a4,80004e0c <filewrite+0x11c>
    80004d20:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d22:	0cc05463          	blez	a2,80004dea <filewrite+0xfa>
    80004d26:	fc26                	sd	s1,56(sp)
    80004d28:	ec56                	sd	s5,24(sp)
    80004d2a:	e45e                	sd	s7,8(sp)
    80004d2c:	e062                	sd	s8,0(sp)
    int i = 0;
    80004d2e:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004d30:	6b85                	lui	s7,0x1
    80004d32:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004d36:	6c05                	lui	s8,0x1
    80004d38:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004d3c:	a851                	j	80004dd0 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004d3e:	6908                	ld	a0,16(a0)
    80004d40:	00000097          	auipc	ra,0x0
    80004d44:	248080e7          	jalr	584(ra) # 80004f88 <pipewrite>
    80004d48:	a85d                	j	80004dfe <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d4a:	02451783          	lh	a5,36(a0)
    80004d4e:	03079693          	slli	a3,a5,0x30
    80004d52:	92c1                	srli	a3,a3,0x30
    80004d54:	4725                	li	a4,9
    80004d56:	0cd76a63          	bltu	a4,a3,80004e2a <filewrite+0x13a>
    80004d5a:	0792                	slli	a5,a5,0x4
    80004d5c:	0001f717          	auipc	a4,0x1f
    80004d60:	aac70713          	addi	a4,a4,-1364 # 80023808 <devsw>
    80004d64:	97ba                	add	a5,a5,a4
    80004d66:	679c                	ld	a5,8(a5)
    80004d68:	c3f9                	beqz	a5,80004e2e <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004d6a:	4505                	li	a0,1
    80004d6c:	9782                	jalr	a5
    80004d6e:	a841                	j	80004dfe <filewrite+0x10e>
      if(n1 > max)
    80004d70:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004d74:	00000097          	auipc	ra,0x0
    80004d78:	88c080e7          	jalr	-1908(ra) # 80004600 <begin_op>
      ilock(f->ip);
    80004d7c:	01893503          	ld	a0,24(s2)
    80004d80:	fffff097          	auipc	ra,0xfffff
    80004d84:	eb2080e7          	jalr	-334(ra) # 80003c32 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d88:	8756                	mv	a4,s5
    80004d8a:	02092683          	lw	a3,32(s2)
    80004d8e:	01698633          	add	a2,s3,s6
    80004d92:	4585                	li	a1,1
    80004d94:	01893503          	ld	a0,24(s2)
    80004d98:	fffff097          	auipc	ra,0xfffff
    80004d9c:	262080e7          	jalr	610(ra) # 80003ffa <writei>
    80004da0:	84aa                	mv	s1,a0
    80004da2:	00a05763          	blez	a0,80004db0 <filewrite+0xc0>
        f->off += r;
    80004da6:	02092783          	lw	a5,32(s2)
    80004daa:	9fa9                	addw	a5,a5,a0
    80004dac:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004db0:	01893503          	ld	a0,24(s2)
    80004db4:	fffff097          	auipc	ra,0xfffff
    80004db8:	f44080e7          	jalr	-188(ra) # 80003cf8 <iunlock>
      end_op();
    80004dbc:	00000097          	auipc	ra,0x0
    80004dc0:	8be080e7          	jalr	-1858(ra) # 8000467a <end_op>

      if(r != n1){
    80004dc4:	029a9563          	bne	s5,s1,80004dee <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004dc8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004dcc:	0149da63          	bge	s3,s4,80004de0 <filewrite+0xf0>
      int n1 = n - i;
    80004dd0:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004dd4:	0004879b          	sext.w	a5,s1
    80004dd8:	f8fbdce3          	bge	s7,a5,80004d70 <filewrite+0x80>
    80004ddc:	84e2                	mv	s1,s8
    80004dde:	bf49                	j	80004d70 <filewrite+0x80>
    80004de0:	74e2                	ld	s1,56(sp)
    80004de2:	6ae2                	ld	s5,24(sp)
    80004de4:	6ba2                	ld	s7,8(sp)
    80004de6:	6c02                	ld	s8,0(sp)
    80004de8:	a039                	j	80004df6 <filewrite+0x106>
    int i = 0;
    80004dea:	4981                	li	s3,0
    80004dec:	a029                	j	80004df6 <filewrite+0x106>
    80004dee:	74e2                	ld	s1,56(sp)
    80004df0:	6ae2                	ld	s5,24(sp)
    80004df2:	6ba2                	ld	s7,8(sp)
    80004df4:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004df6:	033a1e63          	bne	s4,s3,80004e32 <filewrite+0x142>
    80004dfa:	8552                	mv	a0,s4
    80004dfc:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004dfe:	60a6                	ld	ra,72(sp)
    80004e00:	6406                	ld	s0,64(sp)
    80004e02:	7942                	ld	s2,48(sp)
    80004e04:	7a02                	ld	s4,32(sp)
    80004e06:	6b42                	ld	s6,16(sp)
    80004e08:	6161                	addi	sp,sp,80
    80004e0a:	8082                	ret
    80004e0c:	fc26                	sd	s1,56(sp)
    80004e0e:	f44e                	sd	s3,40(sp)
    80004e10:	ec56                	sd	s5,24(sp)
    80004e12:	e45e                	sd	s7,8(sp)
    80004e14:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004e16:	00004517          	auipc	a0,0x4
    80004e1a:	8a250513          	addi	a0,a0,-1886 # 800086b8 <__func__.1+0x6b0>
    80004e1e:	ffffb097          	auipc	ra,0xffffb
    80004e22:	742080e7          	jalr	1858(ra) # 80000560 <panic>
    return -1;
    80004e26:	557d                	li	a0,-1
}
    80004e28:	8082                	ret
      return -1;
    80004e2a:	557d                	li	a0,-1
    80004e2c:	bfc9                	j	80004dfe <filewrite+0x10e>
    80004e2e:	557d                	li	a0,-1
    80004e30:	b7f9                	j	80004dfe <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004e32:	557d                	li	a0,-1
    80004e34:	79a2                	ld	s3,40(sp)
    80004e36:	b7e1                	j	80004dfe <filewrite+0x10e>

0000000080004e38 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e38:	7179                	addi	sp,sp,-48
    80004e3a:	f406                	sd	ra,40(sp)
    80004e3c:	f022                	sd	s0,32(sp)
    80004e3e:	ec26                	sd	s1,24(sp)
    80004e40:	e052                	sd	s4,0(sp)
    80004e42:	1800                	addi	s0,sp,48
    80004e44:	84aa                	mv	s1,a0
    80004e46:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e48:	0005b023          	sd	zero,0(a1)
    80004e4c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e50:	00000097          	auipc	ra,0x0
    80004e54:	bbe080e7          	jalr	-1090(ra) # 80004a0e <filealloc>
    80004e58:	e088                	sd	a0,0(s1)
    80004e5a:	cd49                	beqz	a0,80004ef4 <pipealloc+0xbc>
    80004e5c:	00000097          	auipc	ra,0x0
    80004e60:	bb2080e7          	jalr	-1102(ra) # 80004a0e <filealloc>
    80004e64:	00aa3023          	sd	a0,0(s4)
    80004e68:	c141                	beqz	a0,80004ee8 <pipealloc+0xb0>
    80004e6a:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e6c:	ffffc097          	auipc	ra,0xffffc
    80004e70:	d58080e7          	jalr	-680(ra) # 80000bc4 <kalloc>
    80004e74:	892a                	mv	s2,a0
    80004e76:	c13d                	beqz	a0,80004edc <pipealloc+0xa4>
    80004e78:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004e7a:	4985                	li	s3,1
    80004e7c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e80:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e84:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e88:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e8c:	00004597          	auipc	a1,0x4
    80004e90:	83c58593          	addi	a1,a1,-1988 # 800086c8 <__func__.1+0x6c0>
    80004e94:	ffffc097          	auipc	ra,0xffffc
    80004e98:	ddc080e7          	jalr	-548(ra) # 80000c70 <initlock>
  (*f0)->type = FD_PIPE;
    80004e9c:	609c                	ld	a5,0(s1)
    80004e9e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ea2:	609c                	ld	a5,0(s1)
    80004ea4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ea8:	609c                	ld	a5,0(s1)
    80004eaa:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004eae:	609c                	ld	a5,0(s1)
    80004eb0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004eb4:	000a3783          	ld	a5,0(s4)
    80004eb8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ebc:	000a3783          	ld	a5,0(s4)
    80004ec0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ec4:	000a3783          	ld	a5,0(s4)
    80004ec8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ecc:	000a3783          	ld	a5,0(s4)
    80004ed0:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ed4:	4501                	li	a0,0
    80004ed6:	6942                	ld	s2,16(sp)
    80004ed8:	69a2                	ld	s3,8(sp)
    80004eda:	a03d                	j	80004f08 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004edc:	6088                	ld	a0,0(s1)
    80004ede:	c119                	beqz	a0,80004ee4 <pipealloc+0xac>
    80004ee0:	6942                	ld	s2,16(sp)
    80004ee2:	a029                	j	80004eec <pipealloc+0xb4>
    80004ee4:	6942                	ld	s2,16(sp)
    80004ee6:	a039                	j	80004ef4 <pipealloc+0xbc>
    80004ee8:	6088                	ld	a0,0(s1)
    80004eea:	c50d                	beqz	a0,80004f14 <pipealloc+0xdc>
    fileclose(*f0);
    80004eec:	00000097          	auipc	ra,0x0
    80004ef0:	bde080e7          	jalr	-1058(ra) # 80004aca <fileclose>
  if(*f1)
    80004ef4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ef8:	557d                	li	a0,-1
  if(*f1)
    80004efa:	c799                	beqz	a5,80004f08 <pipealloc+0xd0>
    fileclose(*f1);
    80004efc:	853e                	mv	a0,a5
    80004efe:	00000097          	auipc	ra,0x0
    80004f02:	bcc080e7          	jalr	-1076(ra) # 80004aca <fileclose>
  return -1;
    80004f06:	557d                	li	a0,-1
}
    80004f08:	70a2                	ld	ra,40(sp)
    80004f0a:	7402                	ld	s0,32(sp)
    80004f0c:	64e2                	ld	s1,24(sp)
    80004f0e:	6a02                	ld	s4,0(sp)
    80004f10:	6145                	addi	sp,sp,48
    80004f12:	8082                	ret
  return -1;
    80004f14:	557d                	li	a0,-1
    80004f16:	bfcd                	j	80004f08 <pipealloc+0xd0>

0000000080004f18 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f18:	1101                	addi	sp,sp,-32
    80004f1a:	ec06                	sd	ra,24(sp)
    80004f1c:	e822                	sd	s0,16(sp)
    80004f1e:	e426                	sd	s1,8(sp)
    80004f20:	e04a                	sd	s2,0(sp)
    80004f22:	1000                	addi	s0,sp,32
    80004f24:	84aa                	mv	s1,a0
    80004f26:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f28:	ffffc097          	auipc	ra,0xffffc
    80004f2c:	dd8080e7          	jalr	-552(ra) # 80000d00 <acquire>
  if(writable){
    80004f30:	02090d63          	beqz	s2,80004f6a <pipeclose+0x52>
    pi->writeopen = 0;
    80004f34:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f38:	21848513          	addi	a0,s1,536
    80004f3c:	ffffd097          	auipc	ra,0xffffd
    80004f40:	550080e7          	jalr	1360(ra) # 8000248c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f44:	2204b783          	ld	a5,544(s1)
    80004f48:	eb95                	bnez	a5,80004f7c <pipeclose+0x64>
    release(&pi->lock);
    80004f4a:	8526                	mv	a0,s1
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	e68080e7          	jalr	-408(ra) # 80000db4 <release>
    kfree((char*)pi);
    80004f54:	8526                	mv	a0,s1
    80004f56:	ffffc097          	auipc	ra,0xffffc
    80004f5a:	b06080e7          	jalr	-1274(ra) # 80000a5c <kfree>
  } else
    release(&pi->lock);
}
    80004f5e:	60e2                	ld	ra,24(sp)
    80004f60:	6442                	ld	s0,16(sp)
    80004f62:	64a2                	ld	s1,8(sp)
    80004f64:	6902                	ld	s2,0(sp)
    80004f66:	6105                	addi	sp,sp,32
    80004f68:	8082                	ret
    pi->readopen = 0;
    80004f6a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f6e:	21c48513          	addi	a0,s1,540
    80004f72:	ffffd097          	auipc	ra,0xffffd
    80004f76:	51a080e7          	jalr	1306(ra) # 8000248c <wakeup>
    80004f7a:	b7e9                	j	80004f44 <pipeclose+0x2c>
    release(&pi->lock);
    80004f7c:	8526                	mv	a0,s1
    80004f7e:	ffffc097          	auipc	ra,0xffffc
    80004f82:	e36080e7          	jalr	-458(ra) # 80000db4 <release>
}
    80004f86:	bfe1                	j	80004f5e <pipeclose+0x46>

0000000080004f88 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f88:	711d                	addi	sp,sp,-96
    80004f8a:	ec86                	sd	ra,88(sp)
    80004f8c:	e8a2                	sd	s0,80(sp)
    80004f8e:	e4a6                	sd	s1,72(sp)
    80004f90:	e0ca                	sd	s2,64(sp)
    80004f92:	fc4e                	sd	s3,56(sp)
    80004f94:	f852                	sd	s4,48(sp)
    80004f96:	f456                	sd	s5,40(sp)
    80004f98:	1080                	addi	s0,sp,96
    80004f9a:	84aa                	mv	s1,a0
    80004f9c:	8aae                	mv	s5,a1
    80004f9e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004fa0:	ffffd097          	auipc	ra,0xffffd
    80004fa4:	cd6080e7          	jalr	-810(ra) # 80001c76 <myproc>
    80004fa8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004faa:	8526                	mv	a0,s1
    80004fac:	ffffc097          	auipc	ra,0xffffc
    80004fb0:	d54080e7          	jalr	-684(ra) # 80000d00 <acquire>
  while(i < n){
    80004fb4:	0d405863          	blez	s4,80005084 <pipewrite+0xfc>
    80004fb8:	f05a                	sd	s6,32(sp)
    80004fba:	ec5e                	sd	s7,24(sp)
    80004fbc:	e862                	sd	s8,16(sp)
  int i = 0;
    80004fbe:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fc0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004fc2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004fc6:	21c48b93          	addi	s7,s1,540
    80004fca:	a089                	j	8000500c <pipewrite+0x84>
      release(&pi->lock);
    80004fcc:	8526                	mv	a0,s1
    80004fce:	ffffc097          	auipc	ra,0xffffc
    80004fd2:	de6080e7          	jalr	-538(ra) # 80000db4 <release>
      return -1;
    80004fd6:	597d                	li	s2,-1
    80004fd8:	7b02                	ld	s6,32(sp)
    80004fda:	6be2                	ld	s7,24(sp)
    80004fdc:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004fde:	854a                	mv	a0,s2
    80004fe0:	60e6                	ld	ra,88(sp)
    80004fe2:	6446                	ld	s0,80(sp)
    80004fe4:	64a6                	ld	s1,72(sp)
    80004fe6:	6906                	ld	s2,64(sp)
    80004fe8:	79e2                	ld	s3,56(sp)
    80004fea:	7a42                	ld	s4,48(sp)
    80004fec:	7aa2                	ld	s5,40(sp)
    80004fee:	6125                	addi	sp,sp,96
    80004ff0:	8082                	ret
      wakeup(&pi->nread);
    80004ff2:	8562                	mv	a0,s8
    80004ff4:	ffffd097          	auipc	ra,0xffffd
    80004ff8:	498080e7          	jalr	1176(ra) # 8000248c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ffc:	85a6                	mv	a1,s1
    80004ffe:	855e                	mv	a0,s7
    80005000:	ffffd097          	auipc	ra,0xffffd
    80005004:	428080e7          	jalr	1064(ra) # 80002428 <sleep>
  while(i < n){
    80005008:	05495f63          	bge	s2,s4,80005066 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    8000500c:	2204a783          	lw	a5,544(s1)
    80005010:	dfd5                	beqz	a5,80004fcc <pipewrite+0x44>
    80005012:	854e                	mv	a0,s3
    80005014:	ffffd097          	auipc	ra,0xffffd
    80005018:	6bc080e7          	jalr	1724(ra) # 800026d0 <killed>
    8000501c:	f945                	bnez	a0,80004fcc <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000501e:	2184a783          	lw	a5,536(s1)
    80005022:	21c4a703          	lw	a4,540(s1)
    80005026:	2007879b          	addiw	a5,a5,512
    8000502a:	fcf704e3          	beq	a4,a5,80004ff2 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000502e:	4685                	li	a3,1
    80005030:	01590633          	add	a2,s2,s5
    80005034:	faf40593          	addi	a1,s0,-81
    80005038:	0509b503          	ld	a0,80(s3)
    8000503c:	ffffc097          	auipc	ra,0xffffc
    80005040:	7fa080e7          	jalr	2042(ra) # 80001836 <copyin>
    80005044:	05650263          	beq	a0,s6,80005088 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005048:	21c4a783          	lw	a5,540(s1)
    8000504c:	0017871b          	addiw	a4,a5,1
    80005050:	20e4ae23          	sw	a4,540(s1)
    80005054:	1ff7f793          	andi	a5,a5,511
    80005058:	97a6                	add	a5,a5,s1
    8000505a:	faf44703          	lbu	a4,-81(s0)
    8000505e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005062:	2905                	addiw	s2,s2,1
    80005064:	b755                	j	80005008 <pipewrite+0x80>
    80005066:	7b02                	ld	s6,32(sp)
    80005068:	6be2                	ld	s7,24(sp)
    8000506a:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000506c:	21848513          	addi	a0,s1,536
    80005070:	ffffd097          	auipc	ra,0xffffd
    80005074:	41c080e7          	jalr	1052(ra) # 8000248c <wakeup>
  release(&pi->lock);
    80005078:	8526                	mv	a0,s1
    8000507a:	ffffc097          	auipc	ra,0xffffc
    8000507e:	d3a080e7          	jalr	-710(ra) # 80000db4 <release>
  return i;
    80005082:	bfb1                	j	80004fde <pipewrite+0x56>
  int i = 0;
    80005084:	4901                	li	s2,0
    80005086:	b7dd                	j	8000506c <pipewrite+0xe4>
    80005088:	7b02                	ld	s6,32(sp)
    8000508a:	6be2                	ld	s7,24(sp)
    8000508c:	6c42                	ld	s8,16(sp)
    8000508e:	bff9                	j	8000506c <pipewrite+0xe4>

0000000080005090 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005090:	715d                	addi	sp,sp,-80
    80005092:	e486                	sd	ra,72(sp)
    80005094:	e0a2                	sd	s0,64(sp)
    80005096:	fc26                	sd	s1,56(sp)
    80005098:	f84a                	sd	s2,48(sp)
    8000509a:	f44e                	sd	s3,40(sp)
    8000509c:	f052                	sd	s4,32(sp)
    8000509e:	ec56                	sd	s5,24(sp)
    800050a0:	0880                	addi	s0,sp,80
    800050a2:	84aa                	mv	s1,a0
    800050a4:	892e                	mv	s2,a1
    800050a6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800050a8:	ffffd097          	auipc	ra,0xffffd
    800050ac:	bce080e7          	jalr	-1074(ra) # 80001c76 <myproc>
    800050b0:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800050b2:	8526                	mv	a0,s1
    800050b4:	ffffc097          	auipc	ra,0xffffc
    800050b8:	c4c080e7          	jalr	-948(ra) # 80000d00 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050bc:	2184a703          	lw	a4,536(s1)
    800050c0:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050c4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050c8:	02f71963          	bne	a4,a5,800050fa <piperead+0x6a>
    800050cc:	2244a783          	lw	a5,548(s1)
    800050d0:	cf95                	beqz	a5,8000510c <piperead+0x7c>
    if(killed(pr)){
    800050d2:	8552                	mv	a0,s4
    800050d4:	ffffd097          	auipc	ra,0xffffd
    800050d8:	5fc080e7          	jalr	1532(ra) # 800026d0 <killed>
    800050dc:	e10d                	bnez	a0,800050fe <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050de:	85a6                	mv	a1,s1
    800050e0:	854e                	mv	a0,s3
    800050e2:	ffffd097          	auipc	ra,0xffffd
    800050e6:	346080e7          	jalr	838(ra) # 80002428 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050ea:	2184a703          	lw	a4,536(s1)
    800050ee:	21c4a783          	lw	a5,540(s1)
    800050f2:	fcf70de3          	beq	a4,a5,800050cc <piperead+0x3c>
    800050f6:	e85a                	sd	s6,16(sp)
    800050f8:	a819                	j	8000510e <piperead+0x7e>
    800050fa:	e85a                	sd	s6,16(sp)
    800050fc:	a809                	j	8000510e <piperead+0x7e>
      release(&pi->lock);
    800050fe:	8526                	mv	a0,s1
    80005100:	ffffc097          	auipc	ra,0xffffc
    80005104:	cb4080e7          	jalr	-844(ra) # 80000db4 <release>
      return -1;
    80005108:	59fd                	li	s3,-1
    8000510a:	a0a5                	j	80005172 <piperead+0xe2>
    8000510c:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000510e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005110:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005112:	05505463          	blez	s5,8000515a <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80005116:	2184a783          	lw	a5,536(s1)
    8000511a:	21c4a703          	lw	a4,540(s1)
    8000511e:	02f70e63          	beq	a4,a5,8000515a <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005122:	0017871b          	addiw	a4,a5,1
    80005126:	20e4ac23          	sw	a4,536(s1)
    8000512a:	1ff7f793          	andi	a5,a5,511
    8000512e:	97a6                	add	a5,a5,s1
    80005130:	0187c783          	lbu	a5,24(a5)
    80005134:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005138:	4685                	li	a3,1
    8000513a:	fbf40613          	addi	a2,s0,-65
    8000513e:	85ca                	mv	a1,s2
    80005140:	050a3503          	ld	a0,80(s4)
    80005144:	ffffc097          	auipc	ra,0xffffc
    80005148:	666080e7          	jalr	1638(ra) # 800017aa <copyout>
    8000514c:	01650763          	beq	a0,s6,8000515a <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005150:	2985                	addiw	s3,s3,1
    80005152:	0905                	addi	s2,s2,1
    80005154:	fd3a91e3          	bne	s5,s3,80005116 <piperead+0x86>
    80005158:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000515a:	21c48513          	addi	a0,s1,540
    8000515e:	ffffd097          	auipc	ra,0xffffd
    80005162:	32e080e7          	jalr	814(ra) # 8000248c <wakeup>
  release(&pi->lock);
    80005166:	8526                	mv	a0,s1
    80005168:	ffffc097          	auipc	ra,0xffffc
    8000516c:	c4c080e7          	jalr	-948(ra) # 80000db4 <release>
    80005170:	6b42                	ld	s6,16(sp)
  return i;
}
    80005172:	854e                	mv	a0,s3
    80005174:	60a6                	ld	ra,72(sp)
    80005176:	6406                	ld	s0,64(sp)
    80005178:	74e2                	ld	s1,56(sp)
    8000517a:	7942                	ld	s2,48(sp)
    8000517c:	79a2                	ld	s3,40(sp)
    8000517e:	7a02                	ld	s4,32(sp)
    80005180:	6ae2                	ld	s5,24(sp)
    80005182:	6161                	addi	sp,sp,80
    80005184:	8082                	ret

0000000080005186 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005186:	1141                	addi	sp,sp,-16
    80005188:	e422                	sd	s0,8(sp)
    8000518a:	0800                	addi	s0,sp,16
    8000518c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000518e:	8905                	andi	a0,a0,1
    80005190:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005192:	8b89                	andi	a5,a5,2
    80005194:	c399                	beqz	a5,8000519a <flags2perm+0x14>
      perm |= PTE_W;
    80005196:	00456513          	ori	a0,a0,4
    return perm;
}
    8000519a:	6422                	ld	s0,8(sp)
    8000519c:	0141                	addi	sp,sp,16
    8000519e:	8082                	ret

00000000800051a0 <exec>:

int
exec(char *path, char **argv)
{
    800051a0:	df010113          	addi	sp,sp,-528
    800051a4:	20113423          	sd	ra,520(sp)
    800051a8:	20813023          	sd	s0,512(sp)
    800051ac:	ffa6                	sd	s1,504(sp)
    800051ae:	fbca                	sd	s2,496(sp)
    800051b0:	0c00                	addi	s0,sp,528
    800051b2:	892a                	mv	s2,a0
    800051b4:	dea43c23          	sd	a0,-520(s0)
    800051b8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800051bc:	ffffd097          	auipc	ra,0xffffd
    800051c0:	aba080e7          	jalr	-1350(ra) # 80001c76 <myproc>
    800051c4:	84aa                	mv	s1,a0

  begin_op();
    800051c6:	fffff097          	auipc	ra,0xfffff
    800051ca:	43a080e7          	jalr	1082(ra) # 80004600 <begin_op>

  if((ip = namei(path)) == 0){
    800051ce:	854a                	mv	a0,s2
    800051d0:	fffff097          	auipc	ra,0xfffff
    800051d4:	230080e7          	jalr	560(ra) # 80004400 <namei>
    800051d8:	c135                	beqz	a0,8000523c <exec+0x9c>
    800051da:	f3d2                	sd	s4,480(sp)
    800051dc:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	a54080e7          	jalr	-1452(ra) # 80003c32 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800051e6:	04000713          	li	a4,64
    800051ea:	4681                	li	a3,0
    800051ec:	e5040613          	addi	a2,s0,-432
    800051f0:	4581                	li	a1,0
    800051f2:	8552                	mv	a0,s4
    800051f4:	fffff097          	auipc	ra,0xfffff
    800051f8:	cf6080e7          	jalr	-778(ra) # 80003eea <readi>
    800051fc:	04000793          	li	a5,64
    80005200:	00f51a63          	bne	a0,a5,80005214 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005204:	e5042703          	lw	a4,-432(s0)
    80005208:	464c47b7          	lui	a5,0x464c4
    8000520c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005210:	02f70c63          	beq	a4,a5,80005248 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005214:	8552                	mv	a0,s4
    80005216:	fffff097          	auipc	ra,0xfffff
    8000521a:	c82080e7          	jalr	-894(ra) # 80003e98 <iunlockput>
    end_op();
    8000521e:	fffff097          	auipc	ra,0xfffff
    80005222:	45c080e7          	jalr	1116(ra) # 8000467a <end_op>
  }
  return -1;
    80005226:	557d                	li	a0,-1
    80005228:	7a1e                	ld	s4,480(sp)
}
    8000522a:	20813083          	ld	ra,520(sp)
    8000522e:	20013403          	ld	s0,512(sp)
    80005232:	74fe                	ld	s1,504(sp)
    80005234:	795e                	ld	s2,496(sp)
    80005236:	21010113          	addi	sp,sp,528
    8000523a:	8082                	ret
    end_op();
    8000523c:	fffff097          	auipc	ra,0xfffff
    80005240:	43e080e7          	jalr	1086(ra) # 8000467a <end_op>
    return -1;
    80005244:	557d                	li	a0,-1
    80005246:	b7d5                	j	8000522a <exec+0x8a>
    80005248:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000524a:	8526                	mv	a0,s1
    8000524c:	ffffd097          	auipc	ra,0xffffd
    80005250:	aee080e7          	jalr	-1298(ra) # 80001d3a <proc_pagetable>
    80005254:	8b2a                	mv	s6,a0
    80005256:	30050f63          	beqz	a0,80005574 <exec+0x3d4>
    8000525a:	f7ce                	sd	s3,488(sp)
    8000525c:	efd6                	sd	s5,472(sp)
    8000525e:	e7de                	sd	s7,456(sp)
    80005260:	e3e2                	sd	s8,448(sp)
    80005262:	ff66                	sd	s9,440(sp)
    80005264:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005266:	e7042d03          	lw	s10,-400(s0)
    8000526a:	e8845783          	lhu	a5,-376(s0)
    8000526e:	14078d63          	beqz	a5,800053c8 <exec+0x228>
    80005272:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005274:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005276:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005278:	6c85                	lui	s9,0x1
    8000527a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000527e:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005282:	6a85                	lui	s5,0x1
    80005284:	a0b5                	j	800052f0 <exec+0x150>
      panic("loadseg: address should exist");
    80005286:	00003517          	auipc	a0,0x3
    8000528a:	44a50513          	addi	a0,a0,1098 # 800086d0 <__func__.1+0x6c8>
    8000528e:	ffffb097          	auipc	ra,0xffffb
    80005292:	2d2080e7          	jalr	722(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80005296:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005298:	8726                	mv	a4,s1
    8000529a:	012c06bb          	addw	a3,s8,s2
    8000529e:	4581                	li	a1,0
    800052a0:	8552                	mv	a0,s4
    800052a2:	fffff097          	auipc	ra,0xfffff
    800052a6:	c48080e7          	jalr	-952(ra) # 80003eea <readi>
    800052aa:	2501                	sext.w	a0,a0
    800052ac:	28a49863          	bne	s1,a0,8000553c <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    800052b0:	012a893b          	addw	s2,s5,s2
    800052b4:	03397563          	bgeu	s2,s3,800052de <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    800052b8:	02091593          	slli	a1,s2,0x20
    800052bc:	9181                	srli	a1,a1,0x20
    800052be:	95de                	add	a1,a1,s7
    800052c0:	855a                	mv	a0,s6
    800052c2:	ffffc097          	auipc	ra,0xffffc
    800052c6:	ebc080e7          	jalr	-324(ra) # 8000117e <walkaddr>
    800052ca:	862a                	mv	a2,a0
    if(pa == 0)
    800052cc:	dd4d                	beqz	a0,80005286 <exec+0xe6>
    if(sz - i < PGSIZE)
    800052ce:	412984bb          	subw	s1,s3,s2
    800052d2:	0004879b          	sext.w	a5,s1
    800052d6:	fcfcf0e3          	bgeu	s9,a5,80005296 <exec+0xf6>
    800052da:	84d6                	mv	s1,s5
    800052dc:	bf6d                	j	80005296 <exec+0xf6>
    sz = sz1;
    800052de:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052e2:	2d85                	addiw	s11,s11,1
    800052e4:	038d0d1b          	addiw	s10,s10,56
    800052e8:	e8845783          	lhu	a5,-376(s0)
    800052ec:	08fdd663          	bge	s11,a5,80005378 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052f0:	2d01                	sext.w	s10,s10
    800052f2:	03800713          	li	a4,56
    800052f6:	86ea                	mv	a3,s10
    800052f8:	e1840613          	addi	a2,s0,-488
    800052fc:	4581                	li	a1,0
    800052fe:	8552                	mv	a0,s4
    80005300:	fffff097          	auipc	ra,0xfffff
    80005304:	bea080e7          	jalr	-1046(ra) # 80003eea <readi>
    80005308:	03800793          	li	a5,56
    8000530c:	20f51063          	bne	a0,a5,8000550c <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    80005310:	e1842783          	lw	a5,-488(s0)
    80005314:	4705                	li	a4,1
    80005316:	fce796e3          	bne	a5,a4,800052e2 <exec+0x142>
    if(ph.memsz < ph.filesz)
    8000531a:	e4043483          	ld	s1,-448(s0)
    8000531e:	e3843783          	ld	a5,-456(s0)
    80005322:	1ef4e963          	bltu	s1,a5,80005514 <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005326:	e2843783          	ld	a5,-472(s0)
    8000532a:	94be                	add	s1,s1,a5
    8000532c:	1ef4e863          	bltu	s1,a5,8000551c <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    80005330:	df043703          	ld	a4,-528(s0)
    80005334:	8ff9                	and	a5,a5,a4
    80005336:	1e079763          	bnez	a5,80005524 <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000533a:	e1c42503          	lw	a0,-484(s0)
    8000533e:	00000097          	auipc	ra,0x0
    80005342:	e48080e7          	jalr	-440(ra) # 80005186 <flags2perm>
    80005346:	86aa                	mv	a3,a0
    80005348:	8626                	mv	a2,s1
    8000534a:	85ca                	mv	a1,s2
    8000534c:	855a                	mv	a0,s6
    8000534e:	ffffc097          	auipc	ra,0xffffc
    80005352:	1f4080e7          	jalr	500(ra) # 80001542 <uvmalloc>
    80005356:	e0a43423          	sd	a0,-504(s0)
    8000535a:	1c050963          	beqz	a0,8000552c <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000535e:	e2843b83          	ld	s7,-472(s0)
    80005362:	e2042c03          	lw	s8,-480(s0)
    80005366:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000536a:	00098463          	beqz	s3,80005372 <exec+0x1d2>
    8000536e:	4901                	li	s2,0
    80005370:	b7a1                	j	800052b8 <exec+0x118>
    sz = sz1;
    80005372:	e0843903          	ld	s2,-504(s0)
    80005376:	b7b5                	j	800052e2 <exec+0x142>
    80005378:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000537a:	8552                	mv	a0,s4
    8000537c:	fffff097          	auipc	ra,0xfffff
    80005380:	b1c080e7          	jalr	-1252(ra) # 80003e98 <iunlockput>
  end_op();
    80005384:	fffff097          	auipc	ra,0xfffff
    80005388:	2f6080e7          	jalr	758(ra) # 8000467a <end_op>
  p = myproc();
    8000538c:	ffffd097          	auipc	ra,0xffffd
    80005390:	8ea080e7          	jalr	-1814(ra) # 80001c76 <myproc>
    80005394:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005396:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000539a:	6985                	lui	s3,0x1
    8000539c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000539e:	99ca                	add	s3,s3,s2
    800053a0:	77fd                	lui	a5,0xfffff
    800053a2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800053a6:	4691                	li	a3,4
    800053a8:	6609                	lui	a2,0x2
    800053aa:	964e                	add	a2,a2,s3
    800053ac:	85ce                	mv	a1,s3
    800053ae:	855a                	mv	a0,s6
    800053b0:	ffffc097          	auipc	ra,0xffffc
    800053b4:	192080e7          	jalr	402(ra) # 80001542 <uvmalloc>
    800053b8:	892a                	mv	s2,a0
    800053ba:	e0a43423          	sd	a0,-504(s0)
    800053be:	e519                	bnez	a0,800053cc <exec+0x22c>
  if(pagetable)
    800053c0:	e1343423          	sd	s3,-504(s0)
    800053c4:	4a01                	li	s4,0
    800053c6:	aaa5                	j	8000553e <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800053c8:	4901                	li	s2,0
    800053ca:	bf45                	j	8000537a <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    800053cc:	75f9                	lui	a1,0xffffe
    800053ce:	95aa                	add	a1,a1,a0
    800053d0:	855a                	mv	a0,s6
    800053d2:	ffffc097          	auipc	ra,0xffffc
    800053d6:	3a6080e7          	jalr	934(ra) # 80001778 <uvmclear>
  stackbase = sp - PGSIZE;
    800053da:	7bfd                	lui	s7,0xfffff
    800053dc:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800053de:	e0043783          	ld	a5,-512(s0)
    800053e2:	6388                	ld	a0,0(a5)
    800053e4:	c52d                	beqz	a0,8000544e <exec+0x2ae>
    800053e6:	e9040993          	addi	s3,s0,-368
    800053ea:	f9040c13          	addi	s8,s0,-112
    800053ee:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800053f0:	ffffc097          	auipc	ra,0xffffc
    800053f4:	b80080e7          	jalr	-1152(ra) # 80000f70 <strlen>
    800053f8:	0015079b          	addiw	a5,a0,1
    800053fc:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005400:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005404:	13796863          	bltu	s2,s7,80005534 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005408:	e0043d03          	ld	s10,-512(s0)
    8000540c:	000d3a03          	ld	s4,0(s10)
    80005410:	8552                	mv	a0,s4
    80005412:	ffffc097          	auipc	ra,0xffffc
    80005416:	b5e080e7          	jalr	-1186(ra) # 80000f70 <strlen>
    8000541a:	0015069b          	addiw	a3,a0,1
    8000541e:	8652                	mv	a2,s4
    80005420:	85ca                	mv	a1,s2
    80005422:	855a                	mv	a0,s6
    80005424:	ffffc097          	auipc	ra,0xffffc
    80005428:	386080e7          	jalr	902(ra) # 800017aa <copyout>
    8000542c:	10054663          	bltz	a0,80005538 <exec+0x398>
    ustack[argc] = sp;
    80005430:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005434:	0485                	addi	s1,s1,1
    80005436:	008d0793          	addi	a5,s10,8
    8000543a:	e0f43023          	sd	a5,-512(s0)
    8000543e:	008d3503          	ld	a0,8(s10)
    80005442:	c909                	beqz	a0,80005454 <exec+0x2b4>
    if(argc >= MAXARG)
    80005444:	09a1                	addi	s3,s3,8
    80005446:	fb8995e3          	bne	s3,s8,800053f0 <exec+0x250>
  ip = 0;
    8000544a:	4a01                	li	s4,0
    8000544c:	a8cd                	j	8000553e <exec+0x39e>
  sp = sz;
    8000544e:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005452:	4481                	li	s1,0
  ustack[argc] = 0;
    80005454:	00349793          	slli	a5,s1,0x3
    80005458:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffda5f0>
    8000545c:	97a2                	add	a5,a5,s0
    8000545e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005462:	00148693          	addi	a3,s1,1
    80005466:	068e                	slli	a3,a3,0x3
    80005468:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000546c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005470:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005474:	f57966e3          	bltu	s2,s7,800053c0 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005478:	e9040613          	addi	a2,s0,-368
    8000547c:	85ca                	mv	a1,s2
    8000547e:	855a                	mv	a0,s6
    80005480:	ffffc097          	auipc	ra,0xffffc
    80005484:	32a080e7          	jalr	810(ra) # 800017aa <copyout>
    80005488:	0e054863          	bltz	a0,80005578 <exec+0x3d8>
  p->trapframe->a1 = sp;
    8000548c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005490:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005494:	df843783          	ld	a5,-520(s0)
    80005498:	0007c703          	lbu	a4,0(a5)
    8000549c:	cf11                	beqz	a4,800054b8 <exec+0x318>
    8000549e:	0785                	addi	a5,a5,1
    if(*s == '/')
    800054a0:	02f00693          	li	a3,47
    800054a4:	a039                	j	800054b2 <exec+0x312>
      last = s+1;
    800054a6:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800054aa:	0785                	addi	a5,a5,1
    800054ac:	fff7c703          	lbu	a4,-1(a5)
    800054b0:	c701                	beqz	a4,800054b8 <exec+0x318>
    if(*s == '/')
    800054b2:	fed71ce3          	bne	a4,a3,800054aa <exec+0x30a>
    800054b6:	bfc5                	j	800054a6 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    800054b8:	4641                	li	a2,16
    800054ba:	df843583          	ld	a1,-520(s0)
    800054be:	158a8513          	addi	a0,s5,344
    800054c2:	ffffc097          	auipc	ra,0xffffc
    800054c6:	a7c080e7          	jalr	-1412(ra) # 80000f3e <safestrcpy>
  oldpagetable = p->pagetable;
    800054ca:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800054ce:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800054d2:	e0843783          	ld	a5,-504(s0)
    800054d6:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800054da:	058ab783          	ld	a5,88(s5)
    800054de:	e6843703          	ld	a4,-408(s0)
    800054e2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800054e4:	058ab783          	ld	a5,88(s5)
    800054e8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800054ec:	85e6                	mv	a1,s9
    800054ee:	ffffd097          	auipc	ra,0xffffd
    800054f2:	8e8080e7          	jalr	-1816(ra) # 80001dd6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054f6:	0004851b          	sext.w	a0,s1
    800054fa:	79be                	ld	s3,488(sp)
    800054fc:	7a1e                	ld	s4,480(sp)
    800054fe:	6afe                	ld	s5,472(sp)
    80005500:	6b5e                	ld	s6,464(sp)
    80005502:	6bbe                	ld	s7,456(sp)
    80005504:	6c1e                	ld	s8,448(sp)
    80005506:	7cfa                	ld	s9,440(sp)
    80005508:	7d5a                	ld	s10,432(sp)
    8000550a:	b305                	j	8000522a <exec+0x8a>
    8000550c:	e1243423          	sd	s2,-504(s0)
    80005510:	7dba                	ld	s11,424(sp)
    80005512:	a035                	j	8000553e <exec+0x39e>
    80005514:	e1243423          	sd	s2,-504(s0)
    80005518:	7dba                	ld	s11,424(sp)
    8000551a:	a015                	j	8000553e <exec+0x39e>
    8000551c:	e1243423          	sd	s2,-504(s0)
    80005520:	7dba                	ld	s11,424(sp)
    80005522:	a831                	j	8000553e <exec+0x39e>
    80005524:	e1243423          	sd	s2,-504(s0)
    80005528:	7dba                	ld	s11,424(sp)
    8000552a:	a811                	j	8000553e <exec+0x39e>
    8000552c:	e1243423          	sd	s2,-504(s0)
    80005530:	7dba                	ld	s11,424(sp)
    80005532:	a031                	j	8000553e <exec+0x39e>
  ip = 0;
    80005534:	4a01                	li	s4,0
    80005536:	a021                	j	8000553e <exec+0x39e>
    80005538:	4a01                	li	s4,0
  if(pagetable)
    8000553a:	a011                	j	8000553e <exec+0x39e>
    8000553c:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    8000553e:	e0843583          	ld	a1,-504(s0)
    80005542:	855a                	mv	a0,s6
    80005544:	ffffd097          	auipc	ra,0xffffd
    80005548:	892080e7          	jalr	-1902(ra) # 80001dd6 <proc_freepagetable>
  return -1;
    8000554c:	557d                	li	a0,-1
  if(ip){
    8000554e:	000a1b63          	bnez	s4,80005564 <exec+0x3c4>
    80005552:	79be                	ld	s3,488(sp)
    80005554:	7a1e                	ld	s4,480(sp)
    80005556:	6afe                	ld	s5,472(sp)
    80005558:	6b5e                	ld	s6,464(sp)
    8000555a:	6bbe                	ld	s7,456(sp)
    8000555c:	6c1e                	ld	s8,448(sp)
    8000555e:	7cfa                	ld	s9,440(sp)
    80005560:	7d5a                	ld	s10,432(sp)
    80005562:	b1e1                	j	8000522a <exec+0x8a>
    80005564:	79be                	ld	s3,488(sp)
    80005566:	6afe                	ld	s5,472(sp)
    80005568:	6b5e                	ld	s6,464(sp)
    8000556a:	6bbe                	ld	s7,456(sp)
    8000556c:	6c1e                	ld	s8,448(sp)
    8000556e:	7cfa                	ld	s9,440(sp)
    80005570:	7d5a                	ld	s10,432(sp)
    80005572:	b14d                	j	80005214 <exec+0x74>
    80005574:	6b5e                	ld	s6,464(sp)
    80005576:	b979                	j	80005214 <exec+0x74>
  sz = sz1;
    80005578:	e0843983          	ld	s3,-504(s0)
    8000557c:	b591                	j	800053c0 <exec+0x220>

000000008000557e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000557e:	7179                	addi	sp,sp,-48
    80005580:	f406                	sd	ra,40(sp)
    80005582:	f022                	sd	s0,32(sp)
    80005584:	ec26                	sd	s1,24(sp)
    80005586:	e84a                	sd	s2,16(sp)
    80005588:	1800                	addi	s0,sp,48
    8000558a:	892e                	mv	s2,a1
    8000558c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000558e:	fdc40593          	addi	a1,s0,-36
    80005592:	ffffe097          	auipc	ra,0xffffe
    80005596:	9ee080e7          	jalr	-1554(ra) # 80002f80 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000559a:	fdc42703          	lw	a4,-36(s0)
    8000559e:	47bd                	li	a5,15
    800055a0:	02e7eb63          	bltu	a5,a4,800055d6 <argfd+0x58>
    800055a4:	ffffc097          	auipc	ra,0xffffc
    800055a8:	6d2080e7          	jalr	1746(ra) # 80001c76 <myproc>
    800055ac:	fdc42703          	lw	a4,-36(s0)
    800055b0:	01a70793          	addi	a5,a4,26
    800055b4:	078e                	slli	a5,a5,0x3
    800055b6:	953e                	add	a0,a0,a5
    800055b8:	611c                	ld	a5,0(a0)
    800055ba:	c385                	beqz	a5,800055da <argfd+0x5c>
    return -1;
  if(pfd)
    800055bc:	00090463          	beqz	s2,800055c4 <argfd+0x46>
    *pfd = fd;
    800055c0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800055c4:	4501                	li	a0,0
  if(pf)
    800055c6:	c091                	beqz	s1,800055ca <argfd+0x4c>
    *pf = f;
    800055c8:	e09c                	sd	a5,0(s1)
}
    800055ca:	70a2                	ld	ra,40(sp)
    800055cc:	7402                	ld	s0,32(sp)
    800055ce:	64e2                	ld	s1,24(sp)
    800055d0:	6942                	ld	s2,16(sp)
    800055d2:	6145                	addi	sp,sp,48
    800055d4:	8082                	ret
    return -1;
    800055d6:	557d                	li	a0,-1
    800055d8:	bfcd                	j	800055ca <argfd+0x4c>
    800055da:	557d                	li	a0,-1
    800055dc:	b7fd                	j	800055ca <argfd+0x4c>

00000000800055de <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800055de:	1101                	addi	sp,sp,-32
    800055e0:	ec06                	sd	ra,24(sp)
    800055e2:	e822                	sd	s0,16(sp)
    800055e4:	e426                	sd	s1,8(sp)
    800055e6:	1000                	addi	s0,sp,32
    800055e8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800055ea:	ffffc097          	auipc	ra,0xffffc
    800055ee:	68c080e7          	jalr	1676(ra) # 80001c76 <myproc>
    800055f2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800055f4:	0d050793          	addi	a5,a0,208
    800055f8:	4501                	li	a0,0
    800055fa:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800055fc:	6398                	ld	a4,0(a5)
    800055fe:	cb19                	beqz	a4,80005614 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005600:	2505                	addiw	a0,a0,1
    80005602:	07a1                	addi	a5,a5,8
    80005604:	fed51ce3          	bne	a0,a3,800055fc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005608:	557d                	li	a0,-1
}
    8000560a:	60e2                	ld	ra,24(sp)
    8000560c:	6442                	ld	s0,16(sp)
    8000560e:	64a2                	ld	s1,8(sp)
    80005610:	6105                	addi	sp,sp,32
    80005612:	8082                	ret
      p->ofile[fd] = f;
    80005614:	01a50793          	addi	a5,a0,26
    80005618:	078e                	slli	a5,a5,0x3
    8000561a:	963e                	add	a2,a2,a5
    8000561c:	e204                	sd	s1,0(a2)
      return fd;
    8000561e:	b7f5                	j	8000560a <fdalloc+0x2c>

0000000080005620 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005620:	715d                	addi	sp,sp,-80
    80005622:	e486                	sd	ra,72(sp)
    80005624:	e0a2                	sd	s0,64(sp)
    80005626:	fc26                	sd	s1,56(sp)
    80005628:	f84a                	sd	s2,48(sp)
    8000562a:	f44e                	sd	s3,40(sp)
    8000562c:	ec56                	sd	s5,24(sp)
    8000562e:	e85a                	sd	s6,16(sp)
    80005630:	0880                	addi	s0,sp,80
    80005632:	8b2e                	mv	s6,a1
    80005634:	89b2                	mv	s3,a2
    80005636:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005638:	fb040593          	addi	a1,s0,-80
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	de2080e7          	jalr	-542(ra) # 8000441e <nameiparent>
    80005644:	84aa                	mv	s1,a0
    80005646:	14050e63          	beqz	a0,800057a2 <create+0x182>
    return 0;

  ilock(dp);
    8000564a:	ffffe097          	auipc	ra,0xffffe
    8000564e:	5e8080e7          	jalr	1512(ra) # 80003c32 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005652:	4601                	li	a2,0
    80005654:	fb040593          	addi	a1,s0,-80
    80005658:	8526                	mv	a0,s1
    8000565a:	fffff097          	auipc	ra,0xfffff
    8000565e:	ae4080e7          	jalr	-1308(ra) # 8000413e <dirlookup>
    80005662:	8aaa                	mv	s5,a0
    80005664:	c539                	beqz	a0,800056b2 <create+0x92>
    iunlockput(dp);
    80005666:	8526                	mv	a0,s1
    80005668:	fffff097          	auipc	ra,0xfffff
    8000566c:	830080e7          	jalr	-2000(ra) # 80003e98 <iunlockput>
    ilock(ip);
    80005670:	8556                	mv	a0,s5
    80005672:	ffffe097          	auipc	ra,0xffffe
    80005676:	5c0080e7          	jalr	1472(ra) # 80003c32 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000567a:	4789                	li	a5,2
    8000567c:	02fb1463          	bne	s6,a5,800056a4 <create+0x84>
    80005680:	044ad783          	lhu	a5,68(s5)
    80005684:	37f9                	addiw	a5,a5,-2
    80005686:	17c2                	slli	a5,a5,0x30
    80005688:	93c1                	srli	a5,a5,0x30
    8000568a:	4705                	li	a4,1
    8000568c:	00f76c63          	bltu	a4,a5,800056a4 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005690:	8556                	mv	a0,s5
    80005692:	60a6                	ld	ra,72(sp)
    80005694:	6406                	ld	s0,64(sp)
    80005696:	74e2                	ld	s1,56(sp)
    80005698:	7942                	ld	s2,48(sp)
    8000569a:	79a2                	ld	s3,40(sp)
    8000569c:	6ae2                	ld	s5,24(sp)
    8000569e:	6b42                	ld	s6,16(sp)
    800056a0:	6161                	addi	sp,sp,80
    800056a2:	8082                	ret
    iunlockput(ip);
    800056a4:	8556                	mv	a0,s5
    800056a6:	ffffe097          	auipc	ra,0xffffe
    800056aa:	7f2080e7          	jalr	2034(ra) # 80003e98 <iunlockput>
    return 0;
    800056ae:	4a81                	li	s5,0
    800056b0:	b7c5                	j	80005690 <create+0x70>
    800056b2:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800056b4:	85da                	mv	a1,s6
    800056b6:	4088                	lw	a0,0(s1)
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	3d6080e7          	jalr	982(ra) # 80003a8e <ialloc>
    800056c0:	8a2a                	mv	s4,a0
    800056c2:	c531                	beqz	a0,8000570e <create+0xee>
  ilock(ip);
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	56e080e7          	jalr	1390(ra) # 80003c32 <ilock>
  ip->major = major;
    800056cc:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800056d0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800056d4:	4905                	li	s2,1
    800056d6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800056da:	8552                	mv	a0,s4
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	48a080e7          	jalr	1162(ra) # 80003b66 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800056e4:	032b0d63          	beq	s6,s2,8000571e <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800056e8:	004a2603          	lw	a2,4(s4)
    800056ec:	fb040593          	addi	a1,s0,-80
    800056f0:	8526                	mv	a0,s1
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	c5c080e7          	jalr	-932(ra) # 8000434e <dirlink>
    800056fa:	08054163          	bltz	a0,8000577c <create+0x15c>
  iunlockput(dp);
    800056fe:	8526                	mv	a0,s1
    80005700:	ffffe097          	auipc	ra,0xffffe
    80005704:	798080e7          	jalr	1944(ra) # 80003e98 <iunlockput>
  return ip;
    80005708:	8ad2                	mv	s5,s4
    8000570a:	7a02                	ld	s4,32(sp)
    8000570c:	b751                	j	80005690 <create+0x70>
    iunlockput(dp);
    8000570e:	8526                	mv	a0,s1
    80005710:	ffffe097          	auipc	ra,0xffffe
    80005714:	788080e7          	jalr	1928(ra) # 80003e98 <iunlockput>
    return 0;
    80005718:	8ad2                	mv	s5,s4
    8000571a:	7a02                	ld	s4,32(sp)
    8000571c:	bf95                	j	80005690 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000571e:	004a2603          	lw	a2,4(s4)
    80005722:	00003597          	auipc	a1,0x3
    80005726:	fce58593          	addi	a1,a1,-50 # 800086f0 <__func__.1+0x6e8>
    8000572a:	8552                	mv	a0,s4
    8000572c:	fffff097          	auipc	ra,0xfffff
    80005730:	c22080e7          	jalr	-990(ra) # 8000434e <dirlink>
    80005734:	04054463          	bltz	a0,8000577c <create+0x15c>
    80005738:	40d0                	lw	a2,4(s1)
    8000573a:	00003597          	auipc	a1,0x3
    8000573e:	fbe58593          	addi	a1,a1,-66 # 800086f8 <__func__.1+0x6f0>
    80005742:	8552                	mv	a0,s4
    80005744:	fffff097          	auipc	ra,0xfffff
    80005748:	c0a080e7          	jalr	-1014(ra) # 8000434e <dirlink>
    8000574c:	02054863          	bltz	a0,8000577c <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005750:	004a2603          	lw	a2,4(s4)
    80005754:	fb040593          	addi	a1,s0,-80
    80005758:	8526                	mv	a0,s1
    8000575a:	fffff097          	auipc	ra,0xfffff
    8000575e:	bf4080e7          	jalr	-1036(ra) # 8000434e <dirlink>
    80005762:	00054d63          	bltz	a0,8000577c <create+0x15c>
    dp->nlink++;  // for ".."
    80005766:	04a4d783          	lhu	a5,74(s1)
    8000576a:	2785                	addiw	a5,a5,1
    8000576c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005770:	8526                	mv	a0,s1
    80005772:	ffffe097          	auipc	ra,0xffffe
    80005776:	3f4080e7          	jalr	1012(ra) # 80003b66 <iupdate>
    8000577a:	b751                	j	800056fe <create+0xde>
  ip->nlink = 0;
    8000577c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005780:	8552                	mv	a0,s4
    80005782:	ffffe097          	auipc	ra,0xffffe
    80005786:	3e4080e7          	jalr	996(ra) # 80003b66 <iupdate>
  iunlockput(ip);
    8000578a:	8552                	mv	a0,s4
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	70c080e7          	jalr	1804(ra) # 80003e98 <iunlockput>
  iunlockput(dp);
    80005794:	8526                	mv	a0,s1
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	702080e7          	jalr	1794(ra) # 80003e98 <iunlockput>
  return 0;
    8000579e:	7a02                	ld	s4,32(sp)
    800057a0:	bdc5                	j	80005690 <create+0x70>
    return 0;
    800057a2:	8aaa                	mv	s5,a0
    800057a4:	b5f5                	j	80005690 <create+0x70>

00000000800057a6 <sys_dup>:
{
    800057a6:	7179                	addi	sp,sp,-48
    800057a8:	f406                	sd	ra,40(sp)
    800057aa:	f022                	sd	s0,32(sp)
    800057ac:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057ae:	fd840613          	addi	a2,s0,-40
    800057b2:	4581                	li	a1,0
    800057b4:	4501                	li	a0,0
    800057b6:	00000097          	auipc	ra,0x0
    800057ba:	dc8080e7          	jalr	-568(ra) # 8000557e <argfd>
    return -1;
    800057be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057c0:	02054763          	bltz	a0,800057ee <sys_dup+0x48>
    800057c4:	ec26                	sd	s1,24(sp)
    800057c6:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800057c8:	fd843903          	ld	s2,-40(s0)
    800057cc:	854a                	mv	a0,s2
    800057ce:	00000097          	auipc	ra,0x0
    800057d2:	e10080e7          	jalr	-496(ra) # 800055de <fdalloc>
    800057d6:	84aa                	mv	s1,a0
    return -1;
    800057d8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057da:	00054f63          	bltz	a0,800057f8 <sys_dup+0x52>
  filedup(f);
    800057de:	854a                	mv	a0,s2
    800057e0:	fffff097          	auipc	ra,0xfffff
    800057e4:	298080e7          	jalr	664(ra) # 80004a78 <filedup>
  return fd;
    800057e8:	87a6                	mv	a5,s1
    800057ea:	64e2                	ld	s1,24(sp)
    800057ec:	6942                	ld	s2,16(sp)
}
    800057ee:	853e                	mv	a0,a5
    800057f0:	70a2                	ld	ra,40(sp)
    800057f2:	7402                	ld	s0,32(sp)
    800057f4:	6145                	addi	sp,sp,48
    800057f6:	8082                	ret
    800057f8:	64e2                	ld	s1,24(sp)
    800057fa:	6942                	ld	s2,16(sp)
    800057fc:	bfcd                	j	800057ee <sys_dup+0x48>

00000000800057fe <sys_read>:
{
    800057fe:	7179                	addi	sp,sp,-48
    80005800:	f406                	sd	ra,40(sp)
    80005802:	f022                	sd	s0,32(sp)
    80005804:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005806:	fd840593          	addi	a1,s0,-40
    8000580a:	4505                	li	a0,1
    8000580c:	ffffd097          	auipc	ra,0xffffd
    80005810:	794080e7          	jalr	1940(ra) # 80002fa0 <argaddr>
  argint(2, &n);
    80005814:	fe440593          	addi	a1,s0,-28
    80005818:	4509                	li	a0,2
    8000581a:	ffffd097          	auipc	ra,0xffffd
    8000581e:	766080e7          	jalr	1894(ra) # 80002f80 <argint>
  if(argfd(0, 0, &f) < 0)
    80005822:	fe840613          	addi	a2,s0,-24
    80005826:	4581                	li	a1,0
    80005828:	4501                	li	a0,0
    8000582a:	00000097          	auipc	ra,0x0
    8000582e:	d54080e7          	jalr	-684(ra) # 8000557e <argfd>
    80005832:	87aa                	mv	a5,a0
    return -1;
    80005834:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005836:	0007cc63          	bltz	a5,8000584e <sys_read+0x50>
  return fileread(f, p, n);
    8000583a:	fe442603          	lw	a2,-28(s0)
    8000583e:	fd843583          	ld	a1,-40(s0)
    80005842:	fe843503          	ld	a0,-24(s0)
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	3d8080e7          	jalr	984(ra) # 80004c1e <fileread>
}
    8000584e:	70a2                	ld	ra,40(sp)
    80005850:	7402                	ld	s0,32(sp)
    80005852:	6145                	addi	sp,sp,48
    80005854:	8082                	ret

0000000080005856 <sys_write>:
{
    80005856:	7179                	addi	sp,sp,-48
    80005858:	f406                	sd	ra,40(sp)
    8000585a:	f022                	sd	s0,32(sp)
    8000585c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000585e:	fd840593          	addi	a1,s0,-40
    80005862:	4505                	li	a0,1
    80005864:	ffffd097          	auipc	ra,0xffffd
    80005868:	73c080e7          	jalr	1852(ra) # 80002fa0 <argaddr>
  argint(2, &n);
    8000586c:	fe440593          	addi	a1,s0,-28
    80005870:	4509                	li	a0,2
    80005872:	ffffd097          	auipc	ra,0xffffd
    80005876:	70e080e7          	jalr	1806(ra) # 80002f80 <argint>
  if(argfd(0, 0, &f) < 0)
    8000587a:	fe840613          	addi	a2,s0,-24
    8000587e:	4581                	li	a1,0
    80005880:	4501                	li	a0,0
    80005882:	00000097          	auipc	ra,0x0
    80005886:	cfc080e7          	jalr	-772(ra) # 8000557e <argfd>
    8000588a:	87aa                	mv	a5,a0
    return -1;
    8000588c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000588e:	0007cc63          	bltz	a5,800058a6 <sys_write+0x50>
  return filewrite(f, p, n);
    80005892:	fe442603          	lw	a2,-28(s0)
    80005896:	fd843583          	ld	a1,-40(s0)
    8000589a:	fe843503          	ld	a0,-24(s0)
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	452080e7          	jalr	1106(ra) # 80004cf0 <filewrite>
}
    800058a6:	70a2                	ld	ra,40(sp)
    800058a8:	7402                	ld	s0,32(sp)
    800058aa:	6145                	addi	sp,sp,48
    800058ac:	8082                	ret

00000000800058ae <sys_close>:
{
    800058ae:	1101                	addi	sp,sp,-32
    800058b0:	ec06                	sd	ra,24(sp)
    800058b2:	e822                	sd	s0,16(sp)
    800058b4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800058b6:	fe040613          	addi	a2,s0,-32
    800058ba:	fec40593          	addi	a1,s0,-20
    800058be:	4501                	li	a0,0
    800058c0:	00000097          	auipc	ra,0x0
    800058c4:	cbe080e7          	jalr	-834(ra) # 8000557e <argfd>
    return -1;
    800058c8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058ca:	02054463          	bltz	a0,800058f2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800058ce:	ffffc097          	auipc	ra,0xffffc
    800058d2:	3a8080e7          	jalr	936(ra) # 80001c76 <myproc>
    800058d6:	fec42783          	lw	a5,-20(s0)
    800058da:	07e9                	addi	a5,a5,26
    800058dc:	078e                	slli	a5,a5,0x3
    800058de:	953e                	add	a0,a0,a5
    800058e0:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800058e4:	fe043503          	ld	a0,-32(s0)
    800058e8:	fffff097          	auipc	ra,0xfffff
    800058ec:	1e2080e7          	jalr	482(ra) # 80004aca <fileclose>
  return 0;
    800058f0:	4781                	li	a5,0
}
    800058f2:	853e                	mv	a0,a5
    800058f4:	60e2                	ld	ra,24(sp)
    800058f6:	6442                	ld	s0,16(sp)
    800058f8:	6105                	addi	sp,sp,32
    800058fa:	8082                	ret

00000000800058fc <sys_fstat>:
{
    800058fc:	1101                	addi	sp,sp,-32
    800058fe:	ec06                	sd	ra,24(sp)
    80005900:	e822                	sd	s0,16(sp)
    80005902:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005904:	fe040593          	addi	a1,s0,-32
    80005908:	4505                	li	a0,1
    8000590a:	ffffd097          	auipc	ra,0xffffd
    8000590e:	696080e7          	jalr	1686(ra) # 80002fa0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005912:	fe840613          	addi	a2,s0,-24
    80005916:	4581                	li	a1,0
    80005918:	4501                	li	a0,0
    8000591a:	00000097          	auipc	ra,0x0
    8000591e:	c64080e7          	jalr	-924(ra) # 8000557e <argfd>
    80005922:	87aa                	mv	a5,a0
    return -1;
    80005924:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005926:	0007ca63          	bltz	a5,8000593a <sys_fstat+0x3e>
  return filestat(f, st);
    8000592a:	fe043583          	ld	a1,-32(s0)
    8000592e:	fe843503          	ld	a0,-24(s0)
    80005932:	fffff097          	auipc	ra,0xfffff
    80005936:	27a080e7          	jalr	634(ra) # 80004bac <filestat>
}
    8000593a:	60e2                	ld	ra,24(sp)
    8000593c:	6442                	ld	s0,16(sp)
    8000593e:	6105                	addi	sp,sp,32
    80005940:	8082                	ret

0000000080005942 <sys_link>:
{
    80005942:	7169                	addi	sp,sp,-304
    80005944:	f606                	sd	ra,296(sp)
    80005946:	f222                	sd	s0,288(sp)
    80005948:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000594a:	08000613          	li	a2,128
    8000594e:	ed040593          	addi	a1,s0,-304
    80005952:	4501                	li	a0,0
    80005954:	ffffd097          	auipc	ra,0xffffd
    80005958:	66c080e7          	jalr	1644(ra) # 80002fc0 <argstr>
    return -1;
    8000595c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000595e:	12054663          	bltz	a0,80005a8a <sys_link+0x148>
    80005962:	08000613          	li	a2,128
    80005966:	f5040593          	addi	a1,s0,-176
    8000596a:	4505                	li	a0,1
    8000596c:	ffffd097          	auipc	ra,0xffffd
    80005970:	654080e7          	jalr	1620(ra) # 80002fc0 <argstr>
    return -1;
    80005974:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005976:	10054a63          	bltz	a0,80005a8a <sys_link+0x148>
    8000597a:	ee26                	sd	s1,280(sp)
  begin_op();
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	c84080e7          	jalr	-892(ra) # 80004600 <begin_op>
  if((ip = namei(old)) == 0){
    80005984:	ed040513          	addi	a0,s0,-304
    80005988:	fffff097          	auipc	ra,0xfffff
    8000598c:	a78080e7          	jalr	-1416(ra) # 80004400 <namei>
    80005990:	84aa                	mv	s1,a0
    80005992:	c949                	beqz	a0,80005a24 <sys_link+0xe2>
  ilock(ip);
    80005994:	ffffe097          	auipc	ra,0xffffe
    80005998:	29e080e7          	jalr	670(ra) # 80003c32 <ilock>
  if(ip->type == T_DIR){
    8000599c:	04449703          	lh	a4,68(s1)
    800059a0:	4785                	li	a5,1
    800059a2:	08f70863          	beq	a4,a5,80005a32 <sys_link+0xf0>
    800059a6:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800059a8:	04a4d783          	lhu	a5,74(s1)
    800059ac:	2785                	addiw	a5,a5,1
    800059ae:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059b2:	8526                	mv	a0,s1
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	1b2080e7          	jalr	434(ra) # 80003b66 <iupdate>
  iunlock(ip);
    800059bc:	8526                	mv	a0,s1
    800059be:	ffffe097          	auipc	ra,0xffffe
    800059c2:	33a080e7          	jalr	826(ra) # 80003cf8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800059c6:	fd040593          	addi	a1,s0,-48
    800059ca:	f5040513          	addi	a0,s0,-176
    800059ce:	fffff097          	auipc	ra,0xfffff
    800059d2:	a50080e7          	jalr	-1456(ra) # 8000441e <nameiparent>
    800059d6:	892a                	mv	s2,a0
    800059d8:	cd35                	beqz	a0,80005a54 <sys_link+0x112>
  ilock(dp);
    800059da:	ffffe097          	auipc	ra,0xffffe
    800059de:	258080e7          	jalr	600(ra) # 80003c32 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800059e2:	00092703          	lw	a4,0(s2)
    800059e6:	409c                	lw	a5,0(s1)
    800059e8:	06f71163          	bne	a4,a5,80005a4a <sys_link+0x108>
    800059ec:	40d0                	lw	a2,4(s1)
    800059ee:	fd040593          	addi	a1,s0,-48
    800059f2:	854a                	mv	a0,s2
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	95a080e7          	jalr	-1702(ra) # 8000434e <dirlink>
    800059fc:	04054763          	bltz	a0,80005a4a <sys_link+0x108>
  iunlockput(dp);
    80005a00:	854a                	mv	a0,s2
    80005a02:	ffffe097          	auipc	ra,0xffffe
    80005a06:	496080e7          	jalr	1174(ra) # 80003e98 <iunlockput>
  iput(ip);
    80005a0a:	8526                	mv	a0,s1
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	3e4080e7          	jalr	996(ra) # 80003df0 <iput>
  end_op();
    80005a14:	fffff097          	auipc	ra,0xfffff
    80005a18:	c66080e7          	jalr	-922(ra) # 8000467a <end_op>
  return 0;
    80005a1c:	4781                	li	a5,0
    80005a1e:	64f2                	ld	s1,280(sp)
    80005a20:	6952                	ld	s2,272(sp)
    80005a22:	a0a5                	j	80005a8a <sys_link+0x148>
    end_op();
    80005a24:	fffff097          	auipc	ra,0xfffff
    80005a28:	c56080e7          	jalr	-938(ra) # 8000467a <end_op>
    return -1;
    80005a2c:	57fd                	li	a5,-1
    80005a2e:	64f2                	ld	s1,280(sp)
    80005a30:	a8a9                	j	80005a8a <sys_link+0x148>
    iunlockput(ip);
    80005a32:	8526                	mv	a0,s1
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	464080e7          	jalr	1124(ra) # 80003e98 <iunlockput>
    end_op();
    80005a3c:	fffff097          	auipc	ra,0xfffff
    80005a40:	c3e080e7          	jalr	-962(ra) # 8000467a <end_op>
    return -1;
    80005a44:	57fd                	li	a5,-1
    80005a46:	64f2                	ld	s1,280(sp)
    80005a48:	a089                	j	80005a8a <sys_link+0x148>
    iunlockput(dp);
    80005a4a:	854a                	mv	a0,s2
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	44c080e7          	jalr	1100(ra) # 80003e98 <iunlockput>
  ilock(ip);
    80005a54:	8526                	mv	a0,s1
    80005a56:	ffffe097          	auipc	ra,0xffffe
    80005a5a:	1dc080e7          	jalr	476(ra) # 80003c32 <ilock>
  ip->nlink--;
    80005a5e:	04a4d783          	lhu	a5,74(s1)
    80005a62:	37fd                	addiw	a5,a5,-1
    80005a64:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a68:	8526                	mv	a0,s1
    80005a6a:	ffffe097          	auipc	ra,0xffffe
    80005a6e:	0fc080e7          	jalr	252(ra) # 80003b66 <iupdate>
  iunlockput(ip);
    80005a72:	8526                	mv	a0,s1
    80005a74:	ffffe097          	auipc	ra,0xffffe
    80005a78:	424080e7          	jalr	1060(ra) # 80003e98 <iunlockput>
  end_op();
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	bfe080e7          	jalr	-1026(ra) # 8000467a <end_op>
  return -1;
    80005a84:	57fd                	li	a5,-1
    80005a86:	64f2                	ld	s1,280(sp)
    80005a88:	6952                	ld	s2,272(sp)
}
    80005a8a:	853e                	mv	a0,a5
    80005a8c:	70b2                	ld	ra,296(sp)
    80005a8e:	7412                	ld	s0,288(sp)
    80005a90:	6155                	addi	sp,sp,304
    80005a92:	8082                	ret

0000000080005a94 <sys_unlink>:
{
    80005a94:	7151                	addi	sp,sp,-240
    80005a96:	f586                	sd	ra,232(sp)
    80005a98:	f1a2                	sd	s0,224(sp)
    80005a9a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a9c:	08000613          	li	a2,128
    80005aa0:	f3040593          	addi	a1,s0,-208
    80005aa4:	4501                	li	a0,0
    80005aa6:	ffffd097          	auipc	ra,0xffffd
    80005aaa:	51a080e7          	jalr	1306(ra) # 80002fc0 <argstr>
    80005aae:	1a054a63          	bltz	a0,80005c62 <sys_unlink+0x1ce>
    80005ab2:	eda6                	sd	s1,216(sp)
  begin_op();
    80005ab4:	fffff097          	auipc	ra,0xfffff
    80005ab8:	b4c080e7          	jalr	-1204(ra) # 80004600 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005abc:	fb040593          	addi	a1,s0,-80
    80005ac0:	f3040513          	addi	a0,s0,-208
    80005ac4:	fffff097          	auipc	ra,0xfffff
    80005ac8:	95a080e7          	jalr	-1702(ra) # 8000441e <nameiparent>
    80005acc:	84aa                	mv	s1,a0
    80005ace:	cd71                	beqz	a0,80005baa <sys_unlink+0x116>
  ilock(dp);
    80005ad0:	ffffe097          	auipc	ra,0xffffe
    80005ad4:	162080e7          	jalr	354(ra) # 80003c32 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005ad8:	00003597          	auipc	a1,0x3
    80005adc:	c1858593          	addi	a1,a1,-1000 # 800086f0 <__func__.1+0x6e8>
    80005ae0:	fb040513          	addi	a0,s0,-80
    80005ae4:	ffffe097          	auipc	ra,0xffffe
    80005ae8:	640080e7          	jalr	1600(ra) # 80004124 <namecmp>
    80005aec:	14050c63          	beqz	a0,80005c44 <sys_unlink+0x1b0>
    80005af0:	00003597          	auipc	a1,0x3
    80005af4:	c0858593          	addi	a1,a1,-1016 # 800086f8 <__func__.1+0x6f0>
    80005af8:	fb040513          	addi	a0,s0,-80
    80005afc:	ffffe097          	auipc	ra,0xffffe
    80005b00:	628080e7          	jalr	1576(ra) # 80004124 <namecmp>
    80005b04:	14050063          	beqz	a0,80005c44 <sys_unlink+0x1b0>
    80005b08:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b0a:	f2c40613          	addi	a2,s0,-212
    80005b0e:	fb040593          	addi	a1,s0,-80
    80005b12:	8526                	mv	a0,s1
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	62a080e7          	jalr	1578(ra) # 8000413e <dirlookup>
    80005b1c:	892a                	mv	s2,a0
    80005b1e:	12050263          	beqz	a0,80005c42 <sys_unlink+0x1ae>
  ilock(ip);
    80005b22:	ffffe097          	auipc	ra,0xffffe
    80005b26:	110080e7          	jalr	272(ra) # 80003c32 <ilock>
  if(ip->nlink < 1)
    80005b2a:	04a91783          	lh	a5,74(s2)
    80005b2e:	08f05563          	blez	a5,80005bb8 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b32:	04491703          	lh	a4,68(s2)
    80005b36:	4785                	li	a5,1
    80005b38:	08f70963          	beq	a4,a5,80005bca <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005b3c:	4641                	li	a2,16
    80005b3e:	4581                	li	a1,0
    80005b40:	fc040513          	addi	a0,s0,-64
    80005b44:	ffffb097          	auipc	ra,0xffffb
    80005b48:	2b8080e7          	jalr	696(ra) # 80000dfc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b4c:	4741                	li	a4,16
    80005b4e:	f2c42683          	lw	a3,-212(s0)
    80005b52:	fc040613          	addi	a2,s0,-64
    80005b56:	4581                	li	a1,0
    80005b58:	8526                	mv	a0,s1
    80005b5a:	ffffe097          	auipc	ra,0xffffe
    80005b5e:	4a0080e7          	jalr	1184(ra) # 80003ffa <writei>
    80005b62:	47c1                	li	a5,16
    80005b64:	0af51b63          	bne	a0,a5,80005c1a <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005b68:	04491703          	lh	a4,68(s2)
    80005b6c:	4785                	li	a5,1
    80005b6e:	0af70f63          	beq	a4,a5,80005c2c <sys_unlink+0x198>
  iunlockput(dp);
    80005b72:	8526                	mv	a0,s1
    80005b74:	ffffe097          	auipc	ra,0xffffe
    80005b78:	324080e7          	jalr	804(ra) # 80003e98 <iunlockput>
  ip->nlink--;
    80005b7c:	04a95783          	lhu	a5,74(s2)
    80005b80:	37fd                	addiw	a5,a5,-1
    80005b82:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b86:	854a                	mv	a0,s2
    80005b88:	ffffe097          	auipc	ra,0xffffe
    80005b8c:	fde080e7          	jalr	-34(ra) # 80003b66 <iupdate>
  iunlockput(ip);
    80005b90:	854a                	mv	a0,s2
    80005b92:	ffffe097          	auipc	ra,0xffffe
    80005b96:	306080e7          	jalr	774(ra) # 80003e98 <iunlockput>
  end_op();
    80005b9a:	fffff097          	auipc	ra,0xfffff
    80005b9e:	ae0080e7          	jalr	-1312(ra) # 8000467a <end_op>
  return 0;
    80005ba2:	4501                	li	a0,0
    80005ba4:	64ee                	ld	s1,216(sp)
    80005ba6:	694e                	ld	s2,208(sp)
    80005ba8:	a84d                	j	80005c5a <sys_unlink+0x1c6>
    end_op();
    80005baa:	fffff097          	auipc	ra,0xfffff
    80005bae:	ad0080e7          	jalr	-1328(ra) # 8000467a <end_op>
    return -1;
    80005bb2:	557d                	li	a0,-1
    80005bb4:	64ee                	ld	s1,216(sp)
    80005bb6:	a055                	j	80005c5a <sys_unlink+0x1c6>
    80005bb8:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005bba:	00003517          	auipc	a0,0x3
    80005bbe:	b4650513          	addi	a0,a0,-1210 # 80008700 <__func__.1+0x6f8>
    80005bc2:	ffffb097          	auipc	ra,0xffffb
    80005bc6:	99e080e7          	jalr	-1634(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bca:	04c92703          	lw	a4,76(s2)
    80005bce:	02000793          	li	a5,32
    80005bd2:	f6e7f5e3          	bgeu	a5,a4,80005b3c <sys_unlink+0xa8>
    80005bd6:	e5ce                	sd	s3,200(sp)
    80005bd8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bdc:	4741                	li	a4,16
    80005bde:	86ce                	mv	a3,s3
    80005be0:	f1840613          	addi	a2,s0,-232
    80005be4:	4581                	li	a1,0
    80005be6:	854a                	mv	a0,s2
    80005be8:	ffffe097          	auipc	ra,0xffffe
    80005bec:	302080e7          	jalr	770(ra) # 80003eea <readi>
    80005bf0:	47c1                	li	a5,16
    80005bf2:	00f51c63          	bne	a0,a5,80005c0a <sys_unlink+0x176>
    if(de.inum != 0)
    80005bf6:	f1845783          	lhu	a5,-232(s0)
    80005bfa:	e7b5                	bnez	a5,80005c66 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bfc:	29c1                	addiw	s3,s3,16
    80005bfe:	04c92783          	lw	a5,76(s2)
    80005c02:	fcf9ede3          	bltu	s3,a5,80005bdc <sys_unlink+0x148>
    80005c06:	69ae                	ld	s3,200(sp)
    80005c08:	bf15                	j	80005b3c <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80005c0a:	00003517          	auipc	a0,0x3
    80005c0e:	b0e50513          	addi	a0,a0,-1266 # 80008718 <__func__.1+0x710>
    80005c12:	ffffb097          	auipc	ra,0xffffb
    80005c16:	94e080e7          	jalr	-1714(ra) # 80000560 <panic>
    80005c1a:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005c1c:	00003517          	auipc	a0,0x3
    80005c20:	b1450513          	addi	a0,a0,-1260 # 80008730 <__func__.1+0x728>
    80005c24:	ffffb097          	auipc	ra,0xffffb
    80005c28:	93c080e7          	jalr	-1732(ra) # 80000560 <panic>
    dp->nlink--;
    80005c2c:	04a4d783          	lhu	a5,74(s1)
    80005c30:	37fd                	addiw	a5,a5,-1
    80005c32:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c36:	8526                	mv	a0,s1
    80005c38:	ffffe097          	auipc	ra,0xffffe
    80005c3c:	f2e080e7          	jalr	-210(ra) # 80003b66 <iupdate>
    80005c40:	bf0d                	j	80005b72 <sys_unlink+0xde>
    80005c42:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	252080e7          	jalr	594(ra) # 80003e98 <iunlockput>
  end_op();
    80005c4e:	fffff097          	auipc	ra,0xfffff
    80005c52:	a2c080e7          	jalr	-1492(ra) # 8000467a <end_op>
  return -1;
    80005c56:	557d                	li	a0,-1
    80005c58:	64ee                	ld	s1,216(sp)
}
    80005c5a:	70ae                	ld	ra,232(sp)
    80005c5c:	740e                	ld	s0,224(sp)
    80005c5e:	616d                	addi	sp,sp,240
    80005c60:	8082                	ret
    return -1;
    80005c62:	557d                	li	a0,-1
    80005c64:	bfdd                	j	80005c5a <sys_unlink+0x1c6>
    iunlockput(ip);
    80005c66:	854a                	mv	a0,s2
    80005c68:	ffffe097          	auipc	ra,0xffffe
    80005c6c:	230080e7          	jalr	560(ra) # 80003e98 <iunlockput>
    goto bad;
    80005c70:	694e                	ld	s2,208(sp)
    80005c72:	69ae                	ld	s3,200(sp)
    80005c74:	bfc1                	j	80005c44 <sys_unlink+0x1b0>

0000000080005c76 <sys_open>:

uint64
sys_open(void)
{
    80005c76:	7131                	addi	sp,sp,-192
    80005c78:	fd06                	sd	ra,184(sp)
    80005c7a:	f922                	sd	s0,176(sp)
    80005c7c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005c7e:	f4c40593          	addi	a1,s0,-180
    80005c82:	4505                	li	a0,1
    80005c84:	ffffd097          	auipc	ra,0xffffd
    80005c88:	2fc080e7          	jalr	764(ra) # 80002f80 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c8c:	08000613          	li	a2,128
    80005c90:	f5040593          	addi	a1,s0,-176
    80005c94:	4501                	li	a0,0
    80005c96:	ffffd097          	auipc	ra,0xffffd
    80005c9a:	32a080e7          	jalr	810(ra) # 80002fc0 <argstr>
    80005c9e:	87aa                	mv	a5,a0
    return -1;
    80005ca0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ca2:	0a07ce63          	bltz	a5,80005d5e <sys_open+0xe8>
    80005ca6:	f526                	sd	s1,168(sp)

  begin_op();
    80005ca8:	fffff097          	auipc	ra,0xfffff
    80005cac:	958080e7          	jalr	-1704(ra) # 80004600 <begin_op>

  if(omode & O_CREATE){
    80005cb0:	f4c42783          	lw	a5,-180(s0)
    80005cb4:	2007f793          	andi	a5,a5,512
    80005cb8:	cfd5                	beqz	a5,80005d74 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005cba:	4681                	li	a3,0
    80005cbc:	4601                	li	a2,0
    80005cbe:	4589                	li	a1,2
    80005cc0:	f5040513          	addi	a0,s0,-176
    80005cc4:	00000097          	auipc	ra,0x0
    80005cc8:	95c080e7          	jalr	-1700(ra) # 80005620 <create>
    80005ccc:	84aa                	mv	s1,a0
    if(ip == 0){
    80005cce:	cd41                	beqz	a0,80005d66 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005cd0:	04449703          	lh	a4,68(s1)
    80005cd4:	478d                	li	a5,3
    80005cd6:	00f71763          	bne	a4,a5,80005ce4 <sys_open+0x6e>
    80005cda:	0464d703          	lhu	a4,70(s1)
    80005cde:	47a5                	li	a5,9
    80005ce0:	0ee7e163          	bltu	a5,a4,80005dc2 <sys_open+0x14c>
    80005ce4:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ce6:	fffff097          	auipc	ra,0xfffff
    80005cea:	d28080e7          	jalr	-728(ra) # 80004a0e <filealloc>
    80005cee:	892a                	mv	s2,a0
    80005cf0:	c97d                	beqz	a0,80005de6 <sys_open+0x170>
    80005cf2:	ed4e                	sd	s3,152(sp)
    80005cf4:	00000097          	auipc	ra,0x0
    80005cf8:	8ea080e7          	jalr	-1814(ra) # 800055de <fdalloc>
    80005cfc:	89aa                	mv	s3,a0
    80005cfe:	0c054e63          	bltz	a0,80005dda <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d02:	04449703          	lh	a4,68(s1)
    80005d06:	478d                	li	a5,3
    80005d08:	0ef70c63          	beq	a4,a5,80005e00 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d0c:	4789                	li	a5,2
    80005d0e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005d12:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005d16:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005d1a:	f4c42783          	lw	a5,-180(s0)
    80005d1e:	0017c713          	xori	a4,a5,1
    80005d22:	8b05                	andi	a4,a4,1
    80005d24:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d28:	0037f713          	andi	a4,a5,3
    80005d2c:	00e03733          	snez	a4,a4
    80005d30:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d34:	4007f793          	andi	a5,a5,1024
    80005d38:	c791                	beqz	a5,80005d44 <sys_open+0xce>
    80005d3a:	04449703          	lh	a4,68(s1)
    80005d3e:	4789                	li	a5,2
    80005d40:	0cf70763          	beq	a4,a5,80005e0e <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005d44:	8526                	mv	a0,s1
    80005d46:	ffffe097          	auipc	ra,0xffffe
    80005d4a:	fb2080e7          	jalr	-78(ra) # 80003cf8 <iunlock>
  end_op();
    80005d4e:	fffff097          	auipc	ra,0xfffff
    80005d52:	92c080e7          	jalr	-1748(ra) # 8000467a <end_op>

  return fd;
    80005d56:	854e                	mv	a0,s3
    80005d58:	74aa                	ld	s1,168(sp)
    80005d5a:	790a                	ld	s2,160(sp)
    80005d5c:	69ea                	ld	s3,152(sp)
}
    80005d5e:	70ea                	ld	ra,184(sp)
    80005d60:	744a                	ld	s0,176(sp)
    80005d62:	6129                	addi	sp,sp,192
    80005d64:	8082                	ret
      end_op();
    80005d66:	fffff097          	auipc	ra,0xfffff
    80005d6a:	914080e7          	jalr	-1772(ra) # 8000467a <end_op>
      return -1;
    80005d6e:	557d                	li	a0,-1
    80005d70:	74aa                	ld	s1,168(sp)
    80005d72:	b7f5                	j	80005d5e <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005d74:	f5040513          	addi	a0,s0,-176
    80005d78:	ffffe097          	auipc	ra,0xffffe
    80005d7c:	688080e7          	jalr	1672(ra) # 80004400 <namei>
    80005d80:	84aa                	mv	s1,a0
    80005d82:	c90d                	beqz	a0,80005db4 <sys_open+0x13e>
    ilock(ip);
    80005d84:	ffffe097          	auipc	ra,0xffffe
    80005d88:	eae080e7          	jalr	-338(ra) # 80003c32 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d8c:	04449703          	lh	a4,68(s1)
    80005d90:	4785                	li	a5,1
    80005d92:	f2f71fe3          	bne	a4,a5,80005cd0 <sys_open+0x5a>
    80005d96:	f4c42783          	lw	a5,-180(s0)
    80005d9a:	d7a9                	beqz	a5,80005ce4 <sys_open+0x6e>
      iunlockput(ip);
    80005d9c:	8526                	mv	a0,s1
    80005d9e:	ffffe097          	auipc	ra,0xffffe
    80005da2:	0fa080e7          	jalr	250(ra) # 80003e98 <iunlockput>
      end_op();
    80005da6:	fffff097          	auipc	ra,0xfffff
    80005daa:	8d4080e7          	jalr	-1836(ra) # 8000467a <end_op>
      return -1;
    80005dae:	557d                	li	a0,-1
    80005db0:	74aa                	ld	s1,168(sp)
    80005db2:	b775                	j	80005d5e <sys_open+0xe8>
      end_op();
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	8c6080e7          	jalr	-1850(ra) # 8000467a <end_op>
      return -1;
    80005dbc:	557d                	li	a0,-1
    80005dbe:	74aa                	ld	s1,168(sp)
    80005dc0:	bf79                	j	80005d5e <sys_open+0xe8>
    iunlockput(ip);
    80005dc2:	8526                	mv	a0,s1
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	0d4080e7          	jalr	212(ra) # 80003e98 <iunlockput>
    end_op();
    80005dcc:	fffff097          	auipc	ra,0xfffff
    80005dd0:	8ae080e7          	jalr	-1874(ra) # 8000467a <end_op>
    return -1;
    80005dd4:	557d                	li	a0,-1
    80005dd6:	74aa                	ld	s1,168(sp)
    80005dd8:	b759                	j	80005d5e <sys_open+0xe8>
      fileclose(f);
    80005dda:	854a                	mv	a0,s2
    80005ddc:	fffff097          	auipc	ra,0xfffff
    80005de0:	cee080e7          	jalr	-786(ra) # 80004aca <fileclose>
    80005de4:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005de6:	8526                	mv	a0,s1
    80005de8:	ffffe097          	auipc	ra,0xffffe
    80005dec:	0b0080e7          	jalr	176(ra) # 80003e98 <iunlockput>
    end_op();
    80005df0:	fffff097          	auipc	ra,0xfffff
    80005df4:	88a080e7          	jalr	-1910(ra) # 8000467a <end_op>
    return -1;
    80005df8:	557d                	li	a0,-1
    80005dfa:	74aa                	ld	s1,168(sp)
    80005dfc:	790a                	ld	s2,160(sp)
    80005dfe:	b785                	j	80005d5e <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005e00:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005e04:	04649783          	lh	a5,70(s1)
    80005e08:	02f91223          	sh	a5,36(s2)
    80005e0c:	b729                	j	80005d16 <sys_open+0xa0>
    itrunc(ip);
    80005e0e:	8526                	mv	a0,s1
    80005e10:	ffffe097          	auipc	ra,0xffffe
    80005e14:	f34080e7          	jalr	-204(ra) # 80003d44 <itrunc>
    80005e18:	b735                	j	80005d44 <sys_open+0xce>

0000000080005e1a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e1a:	7175                	addi	sp,sp,-144
    80005e1c:	e506                	sd	ra,136(sp)
    80005e1e:	e122                	sd	s0,128(sp)
    80005e20:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e22:	ffffe097          	auipc	ra,0xffffe
    80005e26:	7de080e7          	jalr	2014(ra) # 80004600 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e2a:	08000613          	li	a2,128
    80005e2e:	f7040593          	addi	a1,s0,-144
    80005e32:	4501                	li	a0,0
    80005e34:	ffffd097          	auipc	ra,0xffffd
    80005e38:	18c080e7          	jalr	396(ra) # 80002fc0 <argstr>
    80005e3c:	02054963          	bltz	a0,80005e6e <sys_mkdir+0x54>
    80005e40:	4681                	li	a3,0
    80005e42:	4601                	li	a2,0
    80005e44:	4585                	li	a1,1
    80005e46:	f7040513          	addi	a0,s0,-144
    80005e4a:	fffff097          	auipc	ra,0xfffff
    80005e4e:	7d6080e7          	jalr	2006(ra) # 80005620 <create>
    80005e52:	cd11                	beqz	a0,80005e6e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e54:	ffffe097          	auipc	ra,0xffffe
    80005e58:	044080e7          	jalr	68(ra) # 80003e98 <iunlockput>
  end_op();
    80005e5c:	fffff097          	auipc	ra,0xfffff
    80005e60:	81e080e7          	jalr	-2018(ra) # 8000467a <end_op>
  return 0;
    80005e64:	4501                	li	a0,0
}
    80005e66:	60aa                	ld	ra,136(sp)
    80005e68:	640a                	ld	s0,128(sp)
    80005e6a:	6149                	addi	sp,sp,144
    80005e6c:	8082                	ret
    end_op();
    80005e6e:	fffff097          	auipc	ra,0xfffff
    80005e72:	80c080e7          	jalr	-2036(ra) # 8000467a <end_op>
    return -1;
    80005e76:	557d                	li	a0,-1
    80005e78:	b7fd                	j	80005e66 <sys_mkdir+0x4c>

0000000080005e7a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e7a:	7135                	addi	sp,sp,-160
    80005e7c:	ed06                	sd	ra,152(sp)
    80005e7e:	e922                	sd	s0,144(sp)
    80005e80:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e82:	ffffe097          	auipc	ra,0xffffe
    80005e86:	77e080e7          	jalr	1918(ra) # 80004600 <begin_op>
  argint(1, &major);
    80005e8a:	f6c40593          	addi	a1,s0,-148
    80005e8e:	4505                	li	a0,1
    80005e90:	ffffd097          	auipc	ra,0xffffd
    80005e94:	0f0080e7          	jalr	240(ra) # 80002f80 <argint>
  argint(2, &minor);
    80005e98:	f6840593          	addi	a1,s0,-152
    80005e9c:	4509                	li	a0,2
    80005e9e:	ffffd097          	auipc	ra,0xffffd
    80005ea2:	0e2080e7          	jalr	226(ra) # 80002f80 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ea6:	08000613          	li	a2,128
    80005eaa:	f7040593          	addi	a1,s0,-144
    80005eae:	4501                	li	a0,0
    80005eb0:	ffffd097          	auipc	ra,0xffffd
    80005eb4:	110080e7          	jalr	272(ra) # 80002fc0 <argstr>
    80005eb8:	02054b63          	bltz	a0,80005eee <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ebc:	f6841683          	lh	a3,-152(s0)
    80005ec0:	f6c41603          	lh	a2,-148(s0)
    80005ec4:	458d                	li	a1,3
    80005ec6:	f7040513          	addi	a0,s0,-144
    80005eca:	fffff097          	auipc	ra,0xfffff
    80005ece:	756080e7          	jalr	1878(ra) # 80005620 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ed2:	cd11                	beqz	a0,80005eee <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ed4:	ffffe097          	auipc	ra,0xffffe
    80005ed8:	fc4080e7          	jalr	-60(ra) # 80003e98 <iunlockput>
  end_op();
    80005edc:	ffffe097          	auipc	ra,0xffffe
    80005ee0:	79e080e7          	jalr	1950(ra) # 8000467a <end_op>
  return 0;
    80005ee4:	4501                	li	a0,0
}
    80005ee6:	60ea                	ld	ra,152(sp)
    80005ee8:	644a                	ld	s0,144(sp)
    80005eea:	610d                	addi	sp,sp,160
    80005eec:	8082                	ret
    end_op();
    80005eee:	ffffe097          	auipc	ra,0xffffe
    80005ef2:	78c080e7          	jalr	1932(ra) # 8000467a <end_op>
    return -1;
    80005ef6:	557d                	li	a0,-1
    80005ef8:	b7fd                	j	80005ee6 <sys_mknod+0x6c>

0000000080005efa <sys_chdir>:

uint64
sys_chdir(void)
{
    80005efa:	7135                	addi	sp,sp,-160
    80005efc:	ed06                	sd	ra,152(sp)
    80005efe:	e922                	sd	s0,144(sp)
    80005f00:	e14a                	sd	s2,128(sp)
    80005f02:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f04:	ffffc097          	auipc	ra,0xffffc
    80005f08:	d72080e7          	jalr	-654(ra) # 80001c76 <myproc>
    80005f0c:	892a                	mv	s2,a0
  
  begin_op();
    80005f0e:	ffffe097          	auipc	ra,0xffffe
    80005f12:	6f2080e7          	jalr	1778(ra) # 80004600 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f16:	08000613          	li	a2,128
    80005f1a:	f6040593          	addi	a1,s0,-160
    80005f1e:	4501                	li	a0,0
    80005f20:	ffffd097          	auipc	ra,0xffffd
    80005f24:	0a0080e7          	jalr	160(ra) # 80002fc0 <argstr>
    80005f28:	04054d63          	bltz	a0,80005f82 <sys_chdir+0x88>
    80005f2c:	e526                	sd	s1,136(sp)
    80005f2e:	f6040513          	addi	a0,s0,-160
    80005f32:	ffffe097          	auipc	ra,0xffffe
    80005f36:	4ce080e7          	jalr	1230(ra) # 80004400 <namei>
    80005f3a:	84aa                	mv	s1,a0
    80005f3c:	c131                	beqz	a0,80005f80 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f3e:	ffffe097          	auipc	ra,0xffffe
    80005f42:	cf4080e7          	jalr	-780(ra) # 80003c32 <ilock>
  if(ip->type != T_DIR){
    80005f46:	04449703          	lh	a4,68(s1)
    80005f4a:	4785                	li	a5,1
    80005f4c:	04f71163          	bne	a4,a5,80005f8e <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f50:	8526                	mv	a0,s1
    80005f52:	ffffe097          	auipc	ra,0xffffe
    80005f56:	da6080e7          	jalr	-602(ra) # 80003cf8 <iunlock>
  iput(p->cwd);
    80005f5a:	15093503          	ld	a0,336(s2)
    80005f5e:	ffffe097          	auipc	ra,0xffffe
    80005f62:	e92080e7          	jalr	-366(ra) # 80003df0 <iput>
  end_op();
    80005f66:	ffffe097          	auipc	ra,0xffffe
    80005f6a:	714080e7          	jalr	1812(ra) # 8000467a <end_op>
  p->cwd = ip;
    80005f6e:	14993823          	sd	s1,336(s2)
  return 0;
    80005f72:	4501                	li	a0,0
    80005f74:	64aa                	ld	s1,136(sp)
}
    80005f76:	60ea                	ld	ra,152(sp)
    80005f78:	644a                	ld	s0,144(sp)
    80005f7a:	690a                	ld	s2,128(sp)
    80005f7c:	610d                	addi	sp,sp,160
    80005f7e:	8082                	ret
    80005f80:	64aa                	ld	s1,136(sp)
    end_op();
    80005f82:	ffffe097          	auipc	ra,0xffffe
    80005f86:	6f8080e7          	jalr	1784(ra) # 8000467a <end_op>
    return -1;
    80005f8a:	557d                	li	a0,-1
    80005f8c:	b7ed                	j	80005f76 <sys_chdir+0x7c>
    iunlockput(ip);
    80005f8e:	8526                	mv	a0,s1
    80005f90:	ffffe097          	auipc	ra,0xffffe
    80005f94:	f08080e7          	jalr	-248(ra) # 80003e98 <iunlockput>
    end_op();
    80005f98:	ffffe097          	auipc	ra,0xffffe
    80005f9c:	6e2080e7          	jalr	1762(ra) # 8000467a <end_op>
    return -1;
    80005fa0:	557d                	li	a0,-1
    80005fa2:	64aa                	ld	s1,136(sp)
    80005fa4:	bfc9                	j	80005f76 <sys_chdir+0x7c>

0000000080005fa6 <sys_exec>:

uint64
sys_exec(void)
{
    80005fa6:	7121                	addi	sp,sp,-448
    80005fa8:	ff06                	sd	ra,440(sp)
    80005faa:	fb22                	sd	s0,432(sp)
    80005fac:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005fae:	e4840593          	addi	a1,s0,-440
    80005fb2:	4505                	li	a0,1
    80005fb4:	ffffd097          	auipc	ra,0xffffd
    80005fb8:	fec080e7          	jalr	-20(ra) # 80002fa0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005fbc:	08000613          	li	a2,128
    80005fc0:	f5040593          	addi	a1,s0,-176
    80005fc4:	4501                	li	a0,0
    80005fc6:	ffffd097          	auipc	ra,0xffffd
    80005fca:	ffa080e7          	jalr	-6(ra) # 80002fc0 <argstr>
    80005fce:	87aa                	mv	a5,a0
    return -1;
    80005fd0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005fd2:	0e07c263          	bltz	a5,800060b6 <sys_exec+0x110>
    80005fd6:	f726                	sd	s1,424(sp)
    80005fd8:	f34a                	sd	s2,416(sp)
    80005fda:	ef4e                	sd	s3,408(sp)
    80005fdc:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005fde:	10000613          	li	a2,256
    80005fe2:	4581                	li	a1,0
    80005fe4:	e5040513          	addi	a0,s0,-432
    80005fe8:	ffffb097          	auipc	ra,0xffffb
    80005fec:	e14080e7          	jalr	-492(ra) # 80000dfc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ff0:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005ff4:	89a6                	mv	s3,s1
    80005ff6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ff8:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ffc:	00391513          	slli	a0,s2,0x3
    80006000:	e4040593          	addi	a1,s0,-448
    80006004:	e4843783          	ld	a5,-440(s0)
    80006008:	953e                	add	a0,a0,a5
    8000600a:	ffffd097          	auipc	ra,0xffffd
    8000600e:	ed8080e7          	jalr	-296(ra) # 80002ee2 <fetchaddr>
    80006012:	02054a63          	bltz	a0,80006046 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80006016:	e4043783          	ld	a5,-448(s0)
    8000601a:	c7b9                	beqz	a5,80006068 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000601c:	ffffb097          	auipc	ra,0xffffb
    80006020:	ba8080e7          	jalr	-1112(ra) # 80000bc4 <kalloc>
    80006024:	85aa                	mv	a1,a0
    80006026:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000602a:	cd11                	beqz	a0,80006046 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000602c:	6605                	lui	a2,0x1
    8000602e:	e4043503          	ld	a0,-448(s0)
    80006032:	ffffd097          	auipc	ra,0xffffd
    80006036:	f02080e7          	jalr	-254(ra) # 80002f34 <fetchstr>
    8000603a:	00054663          	bltz	a0,80006046 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    8000603e:	0905                	addi	s2,s2,1
    80006040:	09a1                	addi	s3,s3,8
    80006042:	fb491de3          	bne	s2,s4,80005ffc <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006046:	f5040913          	addi	s2,s0,-176
    8000604a:	6088                	ld	a0,0(s1)
    8000604c:	c125                	beqz	a0,800060ac <sys_exec+0x106>
    kfree(argv[i]);
    8000604e:	ffffb097          	auipc	ra,0xffffb
    80006052:	a0e080e7          	jalr	-1522(ra) # 80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006056:	04a1                	addi	s1,s1,8
    80006058:	ff2499e3          	bne	s1,s2,8000604a <sys_exec+0xa4>
  return -1;
    8000605c:	557d                	li	a0,-1
    8000605e:	74ba                	ld	s1,424(sp)
    80006060:	791a                	ld	s2,416(sp)
    80006062:	69fa                	ld	s3,408(sp)
    80006064:	6a5a                	ld	s4,400(sp)
    80006066:	a881                	j	800060b6 <sys_exec+0x110>
      argv[i] = 0;
    80006068:	0009079b          	sext.w	a5,s2
    8000606c:	078e                	slli	a5,a5,0x3
    8000606e:	fd078793          	addi	a5,a5,-48
    80006072:	97a2                	add	a5,a5,s0
    80006074:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80006078:	e5040593          	addi	a1,s0,-432
    8000607c:	f5040513          	addi	a0,s0,-176
    80006080:	fffff097          	auipc	ra,0xfffff
    80006084:	120080e7          	jalr	288(ra) # 800051a0 <exec>
    80006088:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000608a:	f5040993          	addi	s3,s0,-176
    8000608e:	6088                	ld	a0,0(s1)
    80006090:	c901                	beqz	a0,800060a0 <sys_exec+0xfa>
    kfree(argv[i]);
    80006092:	ffffb097          	auipc	ra,0xffffb
    80006096:	9ca080e7          	jalr	-1590(ra) # 80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000609a:	04a1                	addi	s1,s1,8
    8000609c:	ff3499e3          	bne	s1,s3,8000608e <sys_exec+0xe8>
  return ret;
    800060a0:	854a                	mv	a0,s2
    800060a2:	74ba                	ld	s1,424(sp)
    800060a4:	791a                	ld	s2,416(sp)
    800060a6:	69fa                	ld	s3,408(sp)
    800060a8:	6a5a                	ld	s4,400(sp)
    800060aa:	a031                	j	800060b6 <sys_exec+0x110>
  return -1;
    800060ac:	557d                	li	a0,-1
    800060ae:	74ba                	ld	s1,424(sp)
    800060b0:	791a                	ld	s2,416(sp)
    800060b2:	69fa                	ld	s3,408(sp)
    800060b4:	6a5a                	ld	s4,400(sp)
}
    800060b6:	70fa                	ld	ra,440(sp)
    800060b8:	745a                	ld	s0,432(sp)
    800060ba:	6139                	addi	sp,sp,448
    800060bc:	8082                	ret

00000000800060be <sys_pipe>:

uint64
sys_pipe(void)
{
    800060be:	7139                	addi	sp,sp,-64
    800060c0:	fc06                	sd	ra,56(sp)
    800060c2:	f822                	sd	s0,48(sp)
    800060c4:	f426                	sd	s1,40(sp)
    800060c6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800060c8:	ffffc097          	auipc	ra,0xffffc
    800060cc:	bae080e7          	jalr	-1106(ra) # 80001c76 <myproc>
    800060d0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800060d2:	fd840593          	addi	a1,s0,-40
    800060d6:	4501                	li	a0,0
    800060d8:	ffffd097          	auipc	ra,0xffffd
    800060dc:	ec8080e7          	jalr	-312(ra) # 80002fa0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800060e0:	fc840593          	addi	a1,s0,-56
    800060e4:	fd040513          	addi	a0,s0,-48
    800060e8:	fffff097          	auipc	ra,0xfffff
    800060ec:	d50080e7          	jalr	-688(ra) # 80004e38 <pipealloc>
    return -1;
    800060f0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800060f2:	0c054463          	bltz	a0,800061ba <sys_pipe+0xfc>
  fd0 = -1;
    800060f6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800060fa:	fd043503          	ld	a0,-48(s0)
    800060fe:	fffff097          	auipc	ra,0xfffff
    80006102:	4e0080e7          	jalr	1248(ra) # 800055de <fdalloc>
    80006106:	fca42223          	sw	a0,-60(s0)
    8000610a:	08054b63          	bltz	a0,800061a0 <sys_pipe+0xe2>
    8000610e:	fc843503          	ld	a0,-56(s0)
    80006112:	fffff097          	auipc	ra,0xfffff
    80006116:	4cc080e7          	jalr	1228(ra) # 800055de <fdalloc>
    8000611a:	fca42023          	sw	a0,-64(s0)
    8000611e:	06054863          	bltz	a0,8000618e <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006122:	4691                	li	a3,4
    80006124:	fc440613          	addi	a2,s0,-60
    80006128:	fd843583          	ld	a1,-40(s0)
    8000612c:	68a8                	ld	a0,80(s1)
    8000612e:	ffffb097          	auipc	ra,0xffffb
    80006132:	67c080e7          	jalr	1660(ra) # 800017aa <copyout>
    80006136:	02054063          	bltz	a0,80006156 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000613a:	4691                	li	a3,4
    8000613c:	fc040613          	addi	a2,s0,-64
    80006140:	fd843583          	ld	a1,-40(s0)
    80006144:	0591                	addi	a1,a1,4
    80006146:	68a8                	ld	a0,80(s1)
    80006148:	ffffb097          	auipc	ra,0xffffb
    8000614c:	662080e7          	jalr	1634(ra) # 800017aa <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006150:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006152:	06055463          	bgez	a0,800061ba <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006156:	fc442783          	lw	a5,-60(s0)
    8000615a:	07e9                	addi	a5,a5,26
    8000615c:	078e                	slli	a5,a5,0x3
    8000615e:	97a6                	add	a5,a5,s1
    80006160:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006164:	fc042783          	lw	a5,-64(s0)
    80006168:	07e9                	addi	a5,a5,26
    8000616a:	078e                	slli	a5,a5,0x3
    8000616c:	94be                	add	s1,s1,a5
    8000616e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006172:	fd043503          	ld	a0,-48(s0)
    80006176:	fffff097          	auipc	ra,0xfffff
    8000617a:	954080e7          	jalr	-1708(ra) # 80004aca <fileclose>
    fileclose(wf);
    8000617e:	fc843503          	ld	a0,-56(s0)
    80006182:	fffff097          	auipc	ra,0xfffff
    80006186:	948080e7          	jalr	-1720(ra) # 80004aca <fileclose>
    return -1;
    8000618a:	57fd                	li	a5,-1
    8000618c:	a03d                	j	800061ba <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000618e:	fc442783          	lw	a5,-60(s0)
    80006192:	0007c763          	bltz	a5,800061a0 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006196:	07e9                	addi	a5,a5,26
    80006198:	078e                	slli	a5,a5,0x3
    8000619a:	97a6                	add	a5,a5,s1
    8000619c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800061a0:	fd043503          	ld	a0,-48(s0)
    800061a4:	fffff097          	auipc	ra,0xfffff
    800061a8:	926080e7          	jalr	-1754(ra) # 80004aca <fileclose>
    fileclose(wf);
    800061ac:	fc843503          	ld	a0,-56(s0)
    800061b0:	fffff097          	auipc	ra,0xfffff
    800061b4:	91a080e7          	jalr	-1766(ra) # 80004aca <fileclose>
    return -1;
    800061b8:	57fd                	li	a5,-1
}
    800061ba:	853e                	mv	a0,a5
    800061bc:	70e2                	ld	ra,56(sp)
    800061be:	7442                	ld	s0,48(sp)
    800061c0:	74a2                	ld	s1,40(sp)
    800061c2:	6121                	addi	sp,sp,64
    800061c4:	8082                	ret
	...

00000000800061d0 <kernelvec>:
    800061d0:	7111                	addi	sp,sp,-256
    800061d2:	e006                	sd	ra,0(sp)
    800061d4:	e40a                	sd	sp,8(sp)
    800061d6:	e80e                	sd	gp,16(sp)
    800061d8:	ec12                	sd	tp,24(sp)
    800061da:	f016                	sd	t0,32(sp)
    800061dc:	f41a                	sd	t1,40(sp)
    800061de:	f81e                	sd	t2,48(sp)
    800061e0:	fc22                	sd	s0,56(sp)
    800061e2:	e0a6                	sd	s1,64(sp)
    800061e4:	e4aa                	sd	a0,72(sp)
    800061e6:	e8ae                	sd	a1,80(sp)
    800061e8:	ecb2                	sd	a2,88(sp)
    800061ea:	f0b6                	sd	a3,96(sp)
    800061ec:	f4ba                	sd	a4,104(sp)
    800061ee:	f8be                	sd	a5,112(sp)
    800061f0:	fcc2                	sd	a6,120(sp)
    800061f2:	e146                	sd	a7,128(sp)
    800061f4:	e54a                	sd	s2,136(sp)
    800061f6:	e94e                	sd	s3,144(sp)
    800061f8:	ed52                	sd	s4,152(sp)
    800061fa:	f156                	sd	s5,160(sp)
    800061fc:	f55a                	sd	s6,168(sp)
    800061fe:	f95e                	sd	s7,176(sp)
    80006200:	fd62                	sd	s8,184(sp)
    80006202:	e1e6                	sd	s9,192(sp)
    80006204:	e5ea                	sd	s10,200(sp)
    80006206:	e9ee                	sd	s11,208(sp)
    80006208:	edf2                	sd	t3,216(sp)
    8000620a:	f1f6                	sd	t4,224(sp)
    8000620c:	f5fa                	sd	t5,232(sp)
    8000620e:	f9fe                	sd	t6,240(sp)
    80006210:	b9ffc0ef          	jal	80002dae <kerneltrap>
    80006214:	6082                	ld	ra,0(sp)
    80006216:	6122                	ld	sp,8(sp)
    80006218:	61c2                	ld	gp,16(sp)
    8000621a:	7282                	ld	t0,32(sp)
    8000621c:	7322                	ld	t1,40(sp)
    8000621e:	73c2                	ld	t2,48(sp)
    80006220:	7462                	ld	s0,56(sp)
    80006222:	6486                	ld	s1,64(sp)
    80006224:	6526                	ld	a0,72(sp)
    80006226:	65c6                	ld	a1,80(sp)
    80006228:	6666                	ld	a2,88(sp)
    8000622a:	7686                	ld	a3,96(sp)
    8000622c:	7726                	ld	a4,104(sp)
    8000622e:	77c6                	ld	a5,112(sp)
    80006230:	7866                	ld	a6,120(sp)
    80006232:	688a                	ld	a7,128(sp)
    80006234:	692a                	ld	s2,136(sp)
    80006236:	69ca                	ld	s3,144(sp)
    80006238:	6a6a                	ld	s4,152(sp)
    8000623a:	7a8a                	ld	s5,160(sp)
    8000623c:	7b2a                	ld	s6,168(sp)
    8000623e:	7bca                	ld	s7,176(sp)
    80006240:	7c6a                	ld	s8,184(sp)
    80006242:	6c8e                	ld	s9,192(sp)
    80006244:	6d2e                	ld	s10,200(sp)
    80006246:	6dce                	ld	s11,208(sp)
    80006248:	6e6e                	ld	t3,216(sp)
    8000624a:	7e8e                	ld	t4,224(sp)
    8000624c:	7f2e                	ld	t5,232(sp)
    8000624e:	7fce                	ld	t6,240(sp)
    80006250:	6111                	addi	sp,sp,256
    80006252:	10200073          	sret
    80006256:	00000013          	nop
    8000625a:	00000013          	nop
    8000625e:	0001                	nop

0000000080006260 <timervec>:
    80006260:	34051573          	csrrw	a0,mscratch,a0
    80006264:	e10c                	sd	a1,0(a0)
    80006266:	e510                	sd	a2,8(a0)
    80006268:	e914                	sd	a3,16(a0)
    8000626a:	6d0c                	ld	a1,24(a0)
    8000626c:	7110                	ld	a2,32(a0)
    8000626e:	6194                	ld	a3,0(a1)
    80006270:	96b2                	add	a3,a3,a2
    80006272:	e194                	sd	a3,0(a1)
    80006274:	4589                	li	a1,2
    80006276:	14459073          	csrw	sip,a1
    8000627a:	6914                	ld	a3,16(a0)
    8000627c:	6510                	ld	a2,8(a0)
    8000627e:	610c                	ld	a1,0(a0)
    80006280:	34051573          	csrrw	a0,mscratch,a0
    80006284:	30200073          	mret
	...

000000008000628a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000628a:	1141                	addi	sp,sp,-16
    8000628c:	e422                	sd	s0,8(sp)
    8000628e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006290:	0c0007b7          	lui	a5,0xc000
    80006294:	4705                	li	a4,1
    80006296:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006298:	0c0007b7          	lui	a5,0xc000
    8000629c:	c3d8                	sw	a4,4(a5)
}
    8000629e:	6422                	ld	s0,8(sp)
    800062a0:	0141                	addi	sp,sp,16
    800062a2:	8082                	ret

00000000800062a4 <plicinithart>:

void
plicinithart(void)
{
    800062a4:	1141                	addi	sp,sp,-16
    800062a6:	e406                	sd	ra,8(sp)
    800062a8:	e022                	sd	s0,0(sp)
    800062aa:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062ac:	ffffc097          	auipc	ra,0xffffc
    800062b0:	99e080e7          	jalr	-1634(ra) # 80001c4a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800062b4:	0085171b          	slliw	a4,a0,0x8
    800062b8:	0c0027b7          	lui	a5,0xc002
    800062bc:	97ba                	add	a5,a5,a4
    800062be:	40200713          	li	a4,1026
    800062c2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800062c6:	00d5151b          	slliw	a0,a0,0xd
    800062ca:	0c2017b7          	lui	a5,0xc201
    800062ce:	97aa                	add	a5,a5,a0
    800062d0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800062d4:	60a2                	ld	ra,8(sp)
    800062d6:	6402                	ld	s0,0(sp)
    800062d8:	0141                	addi	sp,sp,16
    800062da:	8082                	ret

00000000800062dc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800062dc:	1141                	addi	sp,sp,-16
    800062de:	e406                	sd	ra,8(sp)
    800062e0:	e022                	sd	s0,0(sp)
    800062e2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062e4:	ffffc097          	auipc	ra,0xffffc
    800062e8:	966080e7          	jalr	-1690(ra) # 80001c4a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800062ec:	00d5151b          	slliw	a0,a0,0xd
    800062f0:	0c2017b7          	lui	a5,0xc201
    800062f4:	97aa                	add	a5,a5,a0
  return irq;
}
    800062f6:	43c8                	lw	a0,4(a5)
    800062f8:	60a2                	ld	ra,8(sp)
    800062fa:	6402                	ld	s0,0(sp)
    800062fc:	0141                	addi	sp,sp,16
    800062fe:	8082                	ret

0000000080006300 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006300:	1101                	addi	sp,sp,-32
    80006302:	ec06                	sd	ra,24(sp)
    80006304:	e822                	sd	s0,16(sp)
    80006306:	e426                	sd	s1,8(sp)
    80006308:	1000                	addi	s0,sp,32
    8000630a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000630c:	ffffc097          	auipc	ra,0xffffc
    80006310:	93e080e7          	jalr	-1730(ra) # 80001c4a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006314:	00d5151b          	slliw	a0,a0,0xd
    80006318:	0c2017b7          	lui	a5,0xc201
    8000631c:	97aa                	add	a5,a5,a0
    8000631e:	c3c4                	sw	s1,4(a5)
}
    80006320:	60e2                	ld	ra,24(sp)
    80006322:	6442                	ld	s0,16(sp)
    80006324:	64a2                	ld	s1,8(sp)
    80006326:	6105                	addi	sp,sp,32
    80006328:	8082                	ret

000000008000632a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000632a:	1141                	addi	sp,sp,-16
    8000632c:	e406                	sd	ra,8(sp)
    8000632e:	e022                	sd	s0,0(sp)
    80006330:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006332:	479d                	li	a5,7
    80006334:	04a7cc63          	blt	a5,a0,8000638c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006338:	0001e797          	auipc	a5,0x1e
    8000633c:	52878793          	addi	a5,a5,1320 # 80024860 <disk>
    80006340:	97aa                	add	a5,a5,a0
    80006342:	0187c783          	lbu	a5,24(a5)
    80006346:	ebb9                	bnez	a5,8000639c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006348:	00451693          	slli	a3,a0,0x4
    8000634c:	0001e797          	auipc	a5,0x1e
    80006350:	51478793          	addi	a5,a5,1300 # 80024860 <disk>
    80006354:	6398                	ld	a4,0(a5)
    80006356:	9736                	add	a4,a4,a3
    80006358:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000635c:	6398                	ld	a4,0(a5)
    8000635e:	9736                	add	a4,a4,a3
    80006360:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006364:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006368:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000636c:	97aa                	add	a5,a5,a0
    8000636e:	4705                	li	a4,1
    80006370:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006374:	0001e517          	auipc	a0,0x1e
    80006378:	50450513          	addi	a0,a0,1284 # 80024878 <disk+0x18>
    8000637c:	ffffc097          	auipc	ra,0xffffc
    80006380:	110080e7          	jalr	272(ra) # 8000248c <wakeup>
}
    80006384:	60a2                	ld	ra,8(sp)
    80006386:	6402                	ld	s0,0(sp)
    80006388:	0141                	addi	sp,sp,16
    8000638a:	8082                	ret
    panic("free_desc 1");
    8000638c:	00002517          	auipc	a0,0x2
    80006390:	3b450513          	addi	a0,a0,948 # 80008740 <__func__.1+0x738>
    80006394:	ffffa097          	auipc	ra,0xffffa
    80006398:	1cc080e7          	jalr	460(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000639c:	00002517          	auipc	a0,0x2
    800063a0:	3b450513          	addi	a0,a0,948 # 80008750 <__func__.1+0x748>
    800063a4:	ffffa097          	auipc	ra,0xffffa
    800063a8:	1bc080e7          	jalr	444(ra) # 80000560 <panic>

00000000800063ac <virtio_disk_init>:
{
    800063ac:	1101                	addi	sp,sp,-32
    800063ae:	ec06                	sd	ra,24(sp)
    800063b0:	e822                	sd	s0,16(sp)
    800063b2:	e426                	sd	s1,8(sp)
    800063b4:	e04a                	sd	s2,0(sp)
    800063b6:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800063b8:	00002597          	auipc	a1,0x2
    800063bc:	3a858593          	addi	a1,a1,936 # 80008760 <__func__.1+0x758>
    800063c0:	0001e517          	auipc	a0,0x1e
    800063c4:	5c850513          	addi	a0,a0,1480 # 80024988 <disk+0x128>
    800063c8:	ffffb097          	auipc	ra,0xffffb
    800063cc:	8a8080e7          	jalr	-1880(ra) # 80000c70 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063d0:	100017b7          	lui	a5,0x10001
    800063d4:	4398                	lw	a4,0(a5)
    800063d6:	2701                	sext.w	a4,a4
    800063d8:	747277b7          	lui	a5,0x74727
    800063dc:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800063e0:	18f71c63          	bne	a4,a5,80006578 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063e4:	100017b7          	lui	a5,0x10001
    800063e8:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800063ea:	439c                	lw	a5,0(a5)
    800063ec:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063ee:	4709                	li	a4,2
    800063f0:	18e79463          	bne	a5,a4,80006578 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063f4:	100017b7          	lui	a5,0x10001
    800063f8:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800063fa:	439c                	lw	a5,0(a5)
    800063fc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063fe:	16e79d63          	bne	a5,a4,80006578 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006402:	100017b7          	lui	a5,0x10001
    80006406:	47d8                	lw	a4,12(a5)
    80006408:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000640a:	554d47b7          	lui	a5,0x554d4
    8000640e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006412:	16f71363          	bne	a4,a5,80006578 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006416:	100017b7          	lui	a5,0x10001
    8000641a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000641e:	4705                	li	a4,1
    80006420:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006422:	470d                	li	a4,3
    80006424:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006426:	10001737          	lui	a4,0x10001
    8000642a:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000642c:	c7ffe737          	lui	a4,0xc7ffe
    80006430:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd9dbf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006434:	8ef9                	and	a3,a3,a4
    80006436:	10001737          	lui	a4,0x10001
    8000643a:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000643c:	472d                	li	a4,11
    8000643e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006440:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006444:	439c                	lw	a5,0(a5)
    80006446:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000644a:	8ba1                	andi	a5,a5,8
    8000644c:	12078e63          	beqz	a5,80006588 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006450:	100017b7          	lui	a5,0x10001
    80006454:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006458:	100017b7          	lui	a5,0x10001
    8000645c:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006460:	439c                	lw	a5,0(a5)
    80006462:	2781                	sext.w	a5,a5
    80006464:	12079a63          	bnez	a5,80006598 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006468:	100017b7          	lui	a5,0x10001
    8000646c:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006470:	439c                	lw	a5,0(a5)
    80006472:	2781                	sext.w	a5,a5
  if(max == 0)
    80006474:	12078a63          	beqz	a5,800065a8 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006478:	471d                	li	a4,7
    8000647a:	12f77f63          	bgeu	a4,a5,800065b8 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000647e:	ffffa097          	auipc	ra,0xffffa
    80006482:	746080e7          	jalr	1862(ra) # 80000bc4 <kalloc>
    80006486:	0001e497          	auipc	s1,0x1e
    8000648a:	3da48493          	addi	s1,s1,986 # 80024860 <disk>
    8000648e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006490:	ffffa097          	auipc	ra,0xffffa
    80006494:	734080e7          	jalr	1844(ra) # 80000bc4 <kalloc>
    80006498:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000649a:	ffffa097          	auipc	ra,0xffffa
    8000649e:	72a080e7          	jalr	1834(ra) # 80000bc4 <kalloc>
    800064a2:	87aa                	mv	a5,a0
    800064a4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800064a6:	6088                	ld	a0,0(s1)
    800064a8:	12050063          	beqz	a0,800065c8 <virtio_disk_init+0x21c>
    800064ac:	0001e717          	auipc	a4,0x1e
    800064b0:	3bc73703          	ld	a4,956(a4) # 80024868 <disk+0x8>
    800064b4:	10070a63          	beqz	a4,800065c8 <virtio_disk_init+0x21c>
    800064b8:	10078863          	beqz	a5,800065c8 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    800064bc:	6605                	lui	a2,0x1
    800064be:	4581                	li	a1,0
    800064c0:	ffffb097          	auipc	ra,0xffffb
    800064c4:	93c080e7          	jalr	-1732(ra) # 80000dfc <memset>
  memset(disk.avail, 0, PGSIZE);
    800064c8:	0001e497          	auipc	s1,0x1e
    800064cc:	39848493          	addi	s1,s1,920 # 80024860 <disk>
    800064d0:	6605                	lui	a2,0x1
    800064d2:	4581                	li	a1,0
    800064d4:	6488                	ld	a0,8(s1)
    800064d6:	ffffb097          	auipc	ra,0xffffb
    800064da:	926080e7          	jalr	-1754(ra) # 80000dfc <memset>
  memset(disk.used, 0, PGSIZE);
    800064de:	6605                	lui	a2,0x1
    800064e0:	4581                	li	a1,0
    800064e2:	6888                	ld	a0,16(s1)
    800064e4:	ffffb097          	auipc	ra,0xffffb
    800064e8:	918080e7          	jalr	-1768(ra) # 80000dfc <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800064ec:	100017b7          	lui	a5,0x10001
    800064f0:	4721                	li	a4,8
    800064f2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800064f4:	4098                	lw	a4,0(s1)
    800064f6:	100017b7          	lui	a5,0x10001
    800064fa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800064fe:	40d8                	lw	a4,4(s1)
    80006500:	100017b7          	lui	a5,0x10001
    80006504:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006508:	649c                	ld	a5,8(s1)
    8000650a:	0007869b          	sext.w	a3,a5
    8000650e:	10001737          	lui	a4,0x10001
    80006512:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006516:	9781                	srai	a5,a5,0x20
    80006518:	10001737          	lui	a4,0x10001
    8000651c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006520:	689c                	ld	a5,16(s1)
    80006522:	0007869b          	sext.w	a3,a5
    80006526:	10001737          	lui	a4,0x10001
    8000652a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000652e:	9781                	srai	a5,a5,0x20
    80006530:	10001737          	lui	a4,0x10001
    80006534:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006538:	10001737          	lui	a4,0x10001
    8000653c:	4785                	li	a5,1
    8000653e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006540:	00f48c23          	sb	a5,24(s1)
    80006544:	00f48ca3          	sb	a5,25(s1)
    80006548:	00f48d23          	sb	a5,26(s1)
    8000654c:	00f48da3          	sb	a5,27(s1)
    80006550:	00f48e23          	sb	a5,28(s1)
    80006554:	00f48ea3          	sb	a5,29(s1)
    80006558:	00f48f23          	sb	a5,30(s1)
    8000655c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006560:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006564:	100017b7          	lui	a5,0x10001
    80006568:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000656c:	60e2                	ld	ra,24(sp)
    8000656e:	6442                	ld	s0,16(sp)
    80006570:	64a2                	ld	s1,8(sp)
    80006572:	6902                	ld	s2,0(sp)
    80006574:	6105                	addi	sp,sp,32
    80006576:	8082                	ret
    panic("could not find virtio disk");
    80006578:	00002517          	auipc	a0,0x2
    8000657c:	1f850513          	addi	a0,a0,504 # 80008770 <__func__.1+0x768>
    80006580:	ffffa097          	auipc	ra,0xffffa
    80006584:	fe0080e7          	jalr	-32(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006588:	00002517          	auipc	a0,0x2
    8000658c:	20850513          	addi	a0,a0,520 # 80008790 <__func__.1+0x788>
    80006590:	ffffa097          	auipc	ra,0xffffa
    80006594:	fd0080e7          	jalr	-48(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006598:	00002517          	auipc	a0,0x2
    8000659c:	21850513          	addi	a0,a0,536 # 800087b0 <__func__.1+0x7a8>
    800065a0:	ffffa097          	auipc	ra,0xffffa
    800065a4:	fc0080e7          	jalr	-64(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    800065a8:	00002517          	auipc	a0,0x2
    800065ac:	22850513          	addi	a0,a0,552 # 800087d0 <__func__.1+0x7c8>
    800065b0:	ffffa097          	auipc	ra,0xffffa
    800065b4:	fb0080e7          	jalr	-80(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    800065b8:	00002517          	auipc	a0,0x2
    800065bc:	23850513          	addi	a0,a0,568 # 800087f0 <__func__.1+0x7e8>
    800065c0:	ffffa097          	auipc	ra,0xffffa
    800065c4:	fa0080e7          	jalr	-96(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    800065c8:	00002517          	auipc	a0,0x2
    800065cc:	24850513          	addi	a0,a0,584 # 80008810 <__func__.1+0x808>
    800065d0:	ffffa097          	auipc	ra,0xffffa
    800065d4:	f90080e7          	jalr	-112(ra) # 80000560 <panic>

00000000800065d8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800065d8:	7159                	addi	sp,sp,-112
    800065da:	f486                	sd	ra,104(sp)
    800065dc:	f0a2                	sd	s0,96(sp)
    800065de:	eca6                	sd	s1,88(sp)
    800065e0:	e8ca                	sd	s2,80(sp)
    800065e2:	e4ce                	sd	s3,72(sp)
    800065e4:	e0d2                	sd	s4,64(sp)
    800065e6:	fc56                	sd	s5,56(sp)
    800065e8:	f85a                	sd	s6,48(sp)
    800065ea:	f45e                	sd	s7,40(sp)
    800065ec:	f062                	sd	s8,32(sp)
    800065ee:	ec66                	sd	s9,24(sp)
    800065f0:	1880                	addi	s0,sp,112
    800065f2:	8a2a                	mv	s4,a0
    800065f4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800065f6:	00c52c83          	lw	s9,12(a0)
    800065fa:	001c9c9b          	slliw	s9,s9,0x1
    800065fe:	1c82                	slli	s9,s9,0x20
    80006600:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006604:	0001e517          	auipc	a0,0x1e
    80006608:	38450513          	addi	a0,a0,900 # 80024988 <disk+0x128>
    8000660c:	ffffa097          	auipc	ra,0xffffa
    80006610:	6f4080e7          	jalr	1780(ra) # 80000d00 <acquire>
  for(int i = 0; i < 3; i++){
    80006614:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006616:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006618:	0001eb17          	auipc	s6,0x1e
    8000661c:	248b0b13          	addi	s6,s6,584 # 80024860 <disk>
  for(int i = 0; i < 3; i++){
    80006620:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006622:	0001ec17          	auipc	s8,0x1e
    80006626:	366c0c13          	addi	s8,s8,870 # 80024988 <disk+0x128>
    8000662a:	a0ad                	j	80006694 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    8000662c:	00fb0733          	add	a4,s6,a5
    80006630:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006634:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006636:	0207c563          	bltz	a5,80006660 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000663a:	2905                	addiw	s2,s2,1
    8000663c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000663e:	05590f63          	beq	s2,s5,8000669c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006642:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006644:	0001e717          	auipc	a4,0x1e
    80006648:	21c70713          	addi	a4,a4,540 # 80024860 <disk>
    8000664c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000664e:	01874683          	lbu	a3,24(a4)
    80006652:	fee9                	bnez	a3,8000662c <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006654:	2785                	addiw	a5,a5,1
    80006656:	0705                	addi	a4,a4,1
    80006658:	fe979be3          	bne	a5,s1,8000664e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000665c:	57fd                	li	a5,-1
    8000665e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006660:	03205163          	blez	s2,80006682 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006664:	f9042503          	lw	a0,-112(s0)
    80006668:	00000097          	auipc	ra,0x0
    8000666c:	cc2080e7          	jalr	-830(ra) # 8000632a <free_desc>
      for(int j = 0; j < i; j++)
    80006670:	4785                	li	a5,1
    80006672:	0127d863          	bge	a5,s2,80006682 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006676:	f9442503          	lw	a0,-108(s0)
    8000667a:	00000097          	auipc	ra,0x0
    8000667e:	cb0080e7          	jalr	-848(ra) # 8000632a <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006682:	85e2                	mv	a1,s8
    80006684:	0001e517          	auipc	a0,0x1e
    80006688:	1f450513          	addi	a0,a0,500 # 80024878 <disk+0x18>
    8000668c:	ffffc097          	auipc	ra,0xffffc
    80006690:	d9c080e7          	jalr	-612(ra) # 80002428 <sleep>
  for(int i = 0; i < 3; i++){
    80006694:	f9040613          	addi	a2,s0,-112
    80006698:	894e                	mv	s2,s3
    8000669a:	b765                	j	80006642 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000669c:	f9042503          	lw	a0,-112(s0)
    800066a0:	00451693          	slli	a3,a0,0x4

  if(write)
    800066a4:	0001e797          	auipc	a5,0x1e
    800066a8:	1bc78793          	addi	a5,a5,444 # 80024860 <disk>
    800066ac:	00a50713          	addi	a4,a0,10
    800066b0:	0712                	slli	a4,a4,0x4
    800066b2:	973e                	add	a4,a4,a5
    800066b4:	01703633          	snez	a2,s7
    800066b8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800066ba:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800066be:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800066c2:	6398                	ld	a4,0(a5)
    800066c4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066c6:	0a868613          	addi	a2,a3,168
    800066ca:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066cc:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800066ce:	6390                	ld	a2,0(a5)
    800066d0:	00d605b3          	add	a1,a2,a3
    800066d4:	4741                	li	a4,16
    800066d6:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800066d8:	4805                	li	a6,1
    800066da:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800066de:	f9442703          	lw	a4,-108(s0)
    800066e2:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800066e6:	0712                	slli	a4,a4,0x4
    800066e8:	963a                	add	a2,a2,a4
    800066ea:	058a0593          	addi	a1,s4,88
    800066ee:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800066f0:	0007b883          	ld	a7,0(a5)
    800066f4:	9746                	add	a4,a4,a7
    800066f6:	40000613          	li	a2,1024
    800066fa:	c710                	sw	a2,8(a4)
  if(write)
    800066fc:	001bb613          	seqz	a2,s7
    80006700:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006704:	00166613          	ori	a2,a2,1
    80006708:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000670c:	f9842583          	lw	a1,-104(s0)
    80006710:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006714:	00250613          	addi	a2,a0,2
    80006718:	0612                	slli	a2,a2,0x4
    8000671a:	963e                	add	a2,a2,a5
    8000671c:	577d                	li	a4,-1
    8000671e:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006722:	0592                	slli	a1,a1,0x4
    80006724:	98ae                	add	a7,a7,a1
    80006726:	03068713          	addi	a4,a3,48
    8000672a:	973e                	add	a4,a4,a5
    8000672c:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006730:	6398                	ld	a4,0(a5)
    80006732:	972e                	add	a4,a4,a1
    80006734:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006738:	4689                	li	a3,2
    8000673a:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    8000673e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006742:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006746:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000674a:	6794                	ld	a3,8(a5)
    8000674c:	0026d703          	lhu	a4,2(a3)
    80006750:	8b1d                	andi	a4,a4,7
    80006752:	0706                	slli	a4,a4,0x1
    80006754:	96ba                	add	a3,a3,a4
    80006756:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000675a:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000675e:	6798                	ld	a4,8(a5)
    80006760:	00275783          	lhu	a5,2(a4)
    80006764:	2785                	addiw	a5,a5,1
    80006766:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000676a:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000676e:	100017b7          	lui	a5,0x10001
    80006772:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006776:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000677a:	0001e917          	auipc	s2,0x1e
    8000677e:	20e90913          	addi	s2,s2,526 # 80024988 <disk+0x128>
  while(b->disk == 1) {
    80006782:	4485                	li	s1,1
    80006784:	01079c63          	bne	a5,a6,8000679c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006788:	85ca                	mv	a1,s2
    8000678a:	8552                	mv	a0,s4
    8000678c:	ffffc097          	auipc	ra,0xffffc
    80006790:	c9c080e7          	jalr	-868(ra) # 80002428 <sleep>
  while(b->disk == 1) {
    80006794:	004a2783          	lw	a5,4(s4)
    80006798:	fe9788e3          	beq	a5,s1,80006788 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000679c:	f9042903          	lw	s2,-112(s0)
    800067a0:	00290713          	addi	a4,s2,2
    800067a4:	0712                	slli	a4,a4,0x4
    800067a6:	0001e797          	auipc	a5,0x1e
    800067aa:	0ba78793          	addi	a5,a5,186 # 80024860 <disk>
    800067ae:	97ba                	add	a5,a5,a4
    800067b0:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800067b4:	0001e997          	auipc	s3,0x1e
    800067b8:	0ac98993          	addi	s3,s3,172 # 80024860 <disk>
    800067bc:	00491713          	slli	a4,s2,0x4
    800067c0:	0009b783          	ld	a5,0(s3)
    800067c4:	97ba                	add	a5,a5,a4
    800067c6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800067ca:	854a                	mv	a0,s2
    800067cc:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800067d0:	00000097          	auipc	ra,0x0
    800067d4:	b5a080e7          	jalr	-1190(ra) # 8000632a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800067d8:	8885                	andi	s1,s1,1
    800067da:	f0ed                	bnez	s1,800067bc <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800067dc:	0001e517          	auipc	a0,0x1e
    800067e0:	1ac50513          	addi	a0,a0,428 # 80024988 <disk+0x128>
    800067e4:	ffffa097          	auipc	ra,0xffffa
    800067e8:	5d0080e7          	jalr	1488(ra) # 80000db4 <release>
}
    800067ec:	70a6                	ld	ra,104(sp)
    800067ee:	7406                	ld	s0,96(sp)
    800067f0:	64e6                	ld	s1,88(sp)
    800067f2:	6946                	ld	s2,80(sp)
    800067f4:	69a6                	ld	s3,72(sp)
    800067f6:	6a06                	ld	s4,64(sp)
    800067f8:	7ae2                	ld	s5,56(sp)
    800067fa:	7b42                	ld	s6,48(sp)
    800067fc:	7ba2                	ld	s7,40(sp)
    800067fe:	7c02                	ld	s8,32(sp)
    80006800:	6ce2                	ld	s9,24(sp)
    80006802:	6165                	addi	sp,sp,112
    80006804:	8082                	ret

0000000080006806 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006806:	1101                	addi	sp,sp,-32
    80006808:	ec06                	sd	ra,24(sp)
    8000680a:	e822                	sd	s0,16(sp)
    8000680c:	e426                	sd	s1,8(sp)
    8000680e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006810:	0001e497          	auipc	s1,0x1e
    80006814:	05048493          	addi	s1,s1,80 # 80024860 <disk>
    80006818:	0001e517          	auipc	a0,0x1e
    8000681c:	17050513          	addi	a0,a0,368 # 80024988 <disk+0x128>
    80006820:	ffffa097          	auipc	ra,0xffffa
    80006824:	4e0080e7          	jalr	1248(ra) # 80000d00 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006828:	100017b7          	lui	a5,0x10001
    8000682c:	53b8                	lw	a4,96(a5)
    8000682e:	8b0d                	andi	a4,a4,3
    80006830:	100017b7          	lui	a5,0x10001
    80006834:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006836:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000683a:	689c                	ld	a5,16(s1)
    8000683c:	0204d703          	lhu	a4,32(s1)
    80006840:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006844:	04f70863          	beq	a4,a5,80006894 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006848:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000684c:	6898                	ld	a4,16(s1)
    8000684e:	0204d783          	lhu	a5,32(s1)
    80006852:	8b9d                	andi	a5,a5,7
    80006854:	078e                	slli	a5,a5,0x3
    80006856:	97ba                	add	a5,a5,a4
    80006858:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000685a:	00278713          	addi	a4,a5,2
    8000685e:	0712                	slli	a4,a4,0x4
    80006860:	9726                	add	a4,a4,s1
    80006862:	01074703          	lbu	a4,16(a4)
    80006866:	e721                	bnez	a4,800068ae <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006868:	0789                	addi	a5,a5,2
    8000686a:	0792                	slli	a5,a5,0x4
    8000686c:	97a6                	add	a5,a5,s1
    8000686e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006870:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006874:	ffffc097          	auipc	ra,0xffffc
    80006878:	c18080e7          	jalr	-1000(ra) # 8000248c <wakeup>

    disk.used_idx += 1;
    8000687c:	0204d783          	lhu	a5,32(s1)
    80006880:	2785                	addiw	a5,a5,1
    80006882:	17c2                	slli	a5,a5,0x30
    80006884:	93c1                	srli	a5,a5,0x30
    80006886:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000688a:	6898                	ld	a4,16(s1)
    8000688c:	00275703          	lhu	a4,2(a4)
    80006890:	faf71ce3          	bne	a4,a5,80006848 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006894:	0001e517          	auipc	a0,0x1e
    80006898:	0f450513          	addi	a0,a0,244 # 80024988 <disk+0x128>
    8000689c:	ffffa097          	auipc	ra,0xffffa
    800068a0:	518080e7          	jalr	1304(ra) # 80000db4 <release>
}
    800068a4:	60e2                	ld	ra,24(sp)
    800068a6:	6442                	ld	s0,16(sp)
    800068a8:	64a2                	ld	s1,8(sp)
    800068aa:	6105                	addi	sp,sp,32
    800068ac:	8082                	ret
      panic("virtio_disk_intr status");
    800068ae:	00002517          	auipc	a0,0x2
    800068b2:	f7a50513          	addi	a0,a0,-134 # 80008828 <__func__.1+0x820>
    800068b6:	ffffa097          	auipc	ra,0xffffa
    800068ba:	caa080e7          	jalr	-854(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
