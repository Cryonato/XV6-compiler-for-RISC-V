
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000c117          	auipc	sp,0xc
    80000004:	89013103          	ld	sp,-1904(sp) # 8000b890 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000050:	0000c717          	auipc	a4,0xc
    80000054:	8b070713          	addi	a4,a4,-1872 # 8000b900 <timer_scratch>
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
    80000066:	7ae78793          	addi	a5,a5,1966 # 80006810 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff59a5f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r"(x));
    800000a8:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mepc, %0" : : "r"(x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	ef878793          	addi	a5,a5,-264 # 80000fa4 <main>
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
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	baa080e7          	jalr	-1110(ra) # 80002cd4 <either_copyin>
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
    8000018c:	00014517          	auipc	a0,0x14
    80000190:	8b450513          	addi	a0,a0,-1868 # 80013a40 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	b76080e7          	jalr	-1162(ra) # 80000d0a <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019c:	00014497          	auipc	s1,0x14
    800001a0:	8a448493          	addi	s1,s1,-1884 # 80013a40 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a4:	00014917          	auipc	s2,0x14
    800001a8:	93490913          	addi	s2,s2,-1740 # 80013ad8 <cons+0x98>
    while (n > 0)
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
        while (cons.r == cons.w)
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
            if (killed(myproc()))
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	f18080e7          	jalr	-232(ra) # 800020d4 <myproc>
    800001c4:	00003097          	auipc	ra,0x3
    800001c8:	95a080e7          	jalr	-1702(ra) # 80002b1e <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
            sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	6a4080e7          	jalr	1700(ra) # 80002876 <sleep>
        while (cons.r == cons.w)
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00014717          	auipc	a4,0x14
    800001ec:	85870713          	addi	a4,a4,-1960 # 80013a40 <cons>
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
    8000021a:	00003097          	auipc	ra,0x3
    8000021e:	a64080e7          	jalr	-1436(ra) # 80002c7e <either_copyout>
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
    80000236:	00014517          	auipc	a0,0x14
    8000023a:	80a50513          	addi	a0,a0,-2038 # 80013a40 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	b80080e7          	jalr	-1152(ra) # 80000dbe <release>
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
    80000264:	00014717          	auipc	a4,0x14
    80000268:	86f72a23          	sw	a5,-1932(a4) # 80013ad8 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
    release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	7c650513          	addi	a0,a0,1990 # 80013a40 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	b3c080e7          	jalr	-1220(ra) # 80000dbe <release>
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
    800002e6:	75e50513          	addi	a0,a0,1886 # 80013a40 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	a20080e7          	jalr	-1504(ra) # 80000d0a <acquire>

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
    80000308:	00003097          	auipc	ra,0x3
    8000030c:	a22080e7          	jalr	-1502(ra) # 80002d2a <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	73050513          	addi	a0,a0,1840 # 80013a40 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	aa6080e7          	jalr	-1370(ra) # 80000dbe <release>
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
    80000336:	70e70713          	addi	a4,a4,1806 # 80013a40 <cons>
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
    80000360:	6e478793          	addi	a5,a5,1764 # 80013a40 <cons>
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
    8000038e:	74e7a783          	lw	a5,1870(a5) # 80013ad8 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
        while (cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	6a070713          	addi	a4,a4,1696 # 80013a40 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	69048493          	addi	s1,s1,1680 # 80013a40 <cons>
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
    800003fa:	64a70713          	addi	a4,a4,1610 # 80013a40 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
            cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	6cf72a23          	sw	a5,1748(a4) # 80013ae0 <cons+0xa0>
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
    80000436:	60e78793          	addi	a5,a5,1550 # 80013a40 <cons>
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
    8000045a:	68c7a323          	sw	a2,1670(a5) # 80013adc <cons+0x9c>
                wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	67a50513          	addi	a0,a0,1658 # 80013ad8 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	474080e7          	jalr	1140(ra) # 800028da <wakeup>
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
    80000484:	5c050513          	addi	a0,a0,1472 # 80013a40 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	7f2080e7          	jalr	2034(ra) # 80000c7a <initlock>

    uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	366080e7          	jalr	870(ra) # 800007f6 <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000498:	000a3797          	auipc	a5,0xa3
    8000049c:	77078793          	addi	a5,a5,1904 # 800a3c08 <devsw>
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
    800004da:	54260613          	addi	a2,a2,1346 # 80008a18 <digits>
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
    80000582:	5807a123          	sw	zero,1410(a5) # 80013b00 <pr+0x18>
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
    800005b6:	2ef72f23          	sw	a5,766(a4) # 8000b8b0 <panicked>
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
    800005e0:	524d2d03          	lw	s10,1316(s10) # 80013b00 <pr+0x18>
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
    8000061e:	3fea8a93          	addi	s5,s5,1022 # 80008a18 <digits>
        switch (c)
    80000622:	07300c13          	li	s8,115
    80000626:	06400d93          	li	s11,100
    8000062a:	a0b1                	j	80000676 <printf+0xba>
        acquire(&pr.lock);
    8000062c:	00013517          	auipc	a0,0x13
    80000630:	4bc50513          	addi	a0,a0,1212 # 80013ae8 <pr>
    80000634:	00000097          	auipc	ra,0x0
    80000638:	6d6080e7          	jalr	1750(ra) # 80000d0a <acquire>
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
    800007b6:	33650513          	addi	a0,a0,822 # 80013ae8 <pr>
    800007ba:	00000097          	auipc	ra,0x0
    800007be:	604080e7          	jalr	1540(ra) # 80000dbe <release>
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
    800007d2:	31a48493          	addi	s1,s1,794 # 80013ae8 <pr>
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	86a58593          	addi	a1,a1,-1942 # 80008040 <__func__.1+0x38>
    800007de:	8526                	mv	a0,s1
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	49a080e7          	jalr	1178(ra) # 80000c7a <initlock>
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
    8000083e:	2ce50513          	addi	a0,a0,718 # 80013b08 <uart_tx_lock>
    80000842:	00000097          	auipc	ra,0x0
    80000846:	438080e7          	jalr	1080(ra) # 80000c7a <initlock>
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
    80000862:	460080e7          	jalr	1120(ra) # 80000cbe <push_off>

  if(panicked){
    80000866:	0000b797          	auipc	a5,0xb
    8000086a:	04a7a783          	lw	a5,74(a5) # 8000b8b0 <panicked>
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
    80000890:	4d2080e7          	jalr	1234(ra) # 80000d5e <pop_off>
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
    800008a4:	0187b783          	ld	a5,24(a5) # 8000b8b8 <uart_tx_r>
    800008a8:	0000b717          	auipc	a4,0xb
    800008ac:	01873703          	ld	a4,24(a4) # 8000b8c0 <uart_tx_w>
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
    800008d2:	23aa8a93          	addi	s5,s5,570 # 80013b08 <uart_tx_lock>
    uart_tx_r += 1;
    800008d6:	0000b497          	auipc	s1,0xb
    800008da:	fe248493          	addi	s1,s1,-30 # 8000b8b8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008de:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e2:	0000b997          	auipc	s3,0xb
    800008e6:	fde98993          	addi	s3,s3,-34 # 8000b8c0 <uart_tx_w>
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
    80000908:	fd6080e7          	jalr	-42(ra) # 800028da <wakeup>
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
    80000946:	1c650513          	addi	a0,a0,454 # 80013b08 <uart_tx_lock>
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	3c0080e7          	jalr	960(ra) # 80000d0a <acquire>
  if(panicked){
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	f5e7a783          	lw	a5,-162(a5) # 8000b8b0 <panicked>
    8000095a:	e7c9                	bnez	a5,800009e4 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000095c:	0000b717          	auipc	a4,0xb
    80000960:	f6473703          	ld	a4,-156(a4) # 8000b8c0 <uart_tx_w>
    80000964:	0000b797          	auipc	a5,0xb
    80000968:	f547b783          	ld	a5,-172(a5) # 8000b8b8 <uart_tx_r>
    8000096c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000970:	00013997          	auipc	s3,0x13
    80000974:	19898993          	addi	s3,s3,408 # 80013b08 <uart_tx_lock>
    80000978:	0000b497          	auipc	s1,0xb
    8000097c:	f4048493          	addi	s1,s1,-192 # 8000b8b8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000980:	0000b917          	auipc	s2,0xb
    80000984:	f4090913          	addi	s2,s2,-192 # 8000b8c0 <uart_tx_w>
    80000988:	00e79f63          	bne	a5,a4,800009a6 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000098c:	85ce                	mv	a1,s3
    8000098e:	8526                	mv	a0,s1
    80000990:	00002097          	auipc	ra,0x2
    80000994:	ee6080e7          	jalr	-282(ra) # 80002876 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000998:	00093703          	ld	a4,0(s2)
    8000099c:	609c                	ld	a5,0(s1)
    8000099e:	02078793          	addi	a5,a5,32
    800009a2:	fee785e3          	beq	a5,a4,8000098c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a6:	00013497          	auipc	s1,0x13
    800009aa:	16248493          	addi	s1,s1,354 # 80013b08 <uart_tx_lock>
    800009ae:	01f77793          	andi	a5,a4,31
    800009b2:	97a6                	add	a5,a5,s1
    800009b4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009b8:	0705                	addi	a4,a4,1
    800009ba:	0000b797          	auipc	a5,0xb
    800009be:	f0e7b323          	sd	a4,-250(a5) # 8000b8c0 <uart_tx_w>
  uartstart();
    800009c2:	00000097          	auipc	ra,0x0
    800009c6:	ede080e7          	jalr	-290(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    800009ca:	8526                	mv	a0,s1
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	3f2080e7          	jalr	1010(ra) # 80000dbe <release>
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
    80000a32:	0da48493          	addi	s1,s1,218 # 80013b08 <uart_tx_lock>
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	2d2080e7          	jalr	722(ra) # 80000d0a <acquire>
  uartstart();
    80000a40:	00000097          	auipc	ra,0x0
    80000a44:	e60080e7          	jalr	-416(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    80000a48:	8526                	mv	a0,s1
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	374080e7          	jalr	884(ra) # 80000dbe <release>
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
    80000a6e:	e667b783          	ld	a5,-410(a5) # 8000b8d0 <MAX_PAGES>
    80000a72:	c799                	beqz	a5,80000a80 <kfree+0x24>
        assert(FREE_PAGES < MAX_PAGES);
    80000a74:	0000b717          	auipc	a4,0xb
    80000a78:	e5473703          	ld	a4,-428(a4) # 8000b8c8 <FREE_PAGES>
    80000a7c:	06f77663          	bgeu	a4,a5,80000ae8 <kfree+0x8c>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a80:	03449793          	slli	a5,s1,0x34
    80000a84:	efc1                	bnez	a5,80000b1c <kfree+0xc0>
    80000a86:	000a4797          	auipc	a5,0xa4
    80000a8a:	31a78793          	addi	a5,a5,794 # 800a4da0 <end>
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
    80000aa4:	366080e7          	jalr	870(ra) # 80000e06 <memset>

    r = (struct run *)pa;

    acquire(&kmem.lock);
    80000aa8:	00013917          	auipc	s2,0x13
    80000aac:	09890913          	addi	s2,s2,152 # 80013b40 <kmem>
    80000ab0:	854a                	mv	a0,s2
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	258080e7          	jalr	600(ra) # 80000d0a <acquire>
    r->next = kmem.freelist;
    80000aba:	01893783          	ld	a5,24(s2)
    80000abe:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000ac0:	00993c23          	sd	s1,24(s2)
    FREE_PAGES++;
    80000ac4:	0000b717          	auipc	a4,0xb
    80000ac8:	e0470713          	addi	a4,a4,-508 # 8000b8c8 <FREE_PAGES>
    80000acc:	631c                	ld	a5,0(a4)
    80000ace:	0785                	addi	a5,a5,1
    80000ad0:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000ad2:	854a                	mv	a0,s2
    80000ad4:	00000097          	auipc	ra,0x0
    80000ad8:	2ea080e7          	jalr	746(ra) # 80000dbe <release>
}
    80000adc:	60e2                	ld	ra,24(sp)
    80000ade:	6442                	ld	s0,16(sp)
    80000ae0:	64a2                	ld	s1,8(sp)
    80000ae2:	6902                	ld	s2,0(sp)
    80000ae4:	6105                	addi	sp,sp,32
    80000ae6:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000ae8:	03800693          	li	a3,56
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
    80000b8c:	fb850513          	addi	a0,a0,-72 # 80013b40 <kmem>
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	0ea080e7          	jalr	234(ra) # 80000c7a <initlock>
    freerange(end, (void *)PHYSTOP);
    80000b98:	45c5                	li	a1,17
    80000b9a:	05ee                	slli	a1,a1,0x1b
    80000b9c:	000a4517          	auipc	a0,0xa4
    80000ba0:	20450513          	addi	a0,a0,516 # 800a4da0 <end>
    80000ba4:	00000097          	auipc	ra,0x0
    80000ba8:	f88080e7          	jalr	-120(ra) # 80000b2c <freerange>
    MAX_PAGES = FREE_PAGES;
    80000bac:	0000b797          	auipc	a5,0xb
    80000bb0:	d1c7b783          	ld	a5,-740(a5) # 8000b8c8 <FREE_PAGES>
    80000bb4:	0000b717          	auipc	a4,0xb
    80000bb8:	d0f73e23          	sd	a5,-740(a4) # 8000b8d0 <MAX_PAGES>
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
    80000bd2:	cfa7b783          	ld	a5,-774(a5) # 8000b8c8 <FREE_PAGES>
    80000bd6:	cfb9                	beqz	a5,80000c34 <kalloc+0x70>
    struct run *r;

    acquire(&kmem.lock);
    80000bd8:	00013497          	auipc	s1,0x13
    80000bdc:	f6848493          	addi	s1,s1,-152 # 80013b40 <kmem>
    80000be0:	8526                	mv	a0,s1
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	128080e7          	jalr	296(ra) # 80000d0a <acquire>
    r = kmem.freelist;
    80000bea:	6c84                	ld	s1,24(s1)
    if (r)
    80000bec:	ccb5                	beqz	s1,80000c68 <kalloc+0xa4>
        kmem.freelist = r->next;
    80000bee:	609c                	ld	a5,0(s1)
    80000bf0:	00013517          	auipc	a0,0x13
    80000bf4:	f5050513          	addi	a0,a0,-176 # 80013b40 <kmem>
    80000bf8:	ed1c                	sd	a5,24(a0)
    release(&kmem.lock);
    80000bfa:	00000097          	auipc	ra,0x0
    80000bfe:	1c4080e7          	jalr	452(ra) # 80000dbe <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000c02:	6605                	lui	a2,0x1
    80000c04:	4595                	li	a1,5
    80000c06:	8526                	mv	a0,s1
    80000c08:	00000097          	auipc	ra,0x0
    80000c0c:	1fe080e7          	jalr	510(ra) # 80000e06 <memset>
    FREE_PAGES--;
    80000c10:	0000b717          	auipc	a4,0xb
    80000c14:	cb870713          	addi	a4,a4,-840 # 8000b8c8 <FREE_PAGES>
    80000c18:	631c                	ld	a5,0(a4)
    80000c1a:	17fd                	addi	a5,a5,-1
    80000c1c:	e31c                	sd	a5,0(a4)
    increment_ref_count((uint64) r);
    80000c1e:	8526                	mv	a0,s1
    80000c20:	00000097          	auipc	ra,0x0
    80000c24:	5dc080e7          	jalr	1500(ra) # 800011fc <increment_ref_count>
    return (void *)r;
}
    80000c28:	8526                	mv	a0,s1
    80000c2a:	60e2                	ld	ra,24(sp)
    80000c2c:	6442                	ld	s0,16(sp)
    80000c2e:	64a2                	ld	s1,8(sp)
    80000c30:	6105                	addi	sp,sp,32
    80000c32:	8082                	ret
    assert(FREE_PAGES > 0);
    80000c34:	05000693          	li	a3,80
    80000c38:	00007617          	auipc	a2,0x7
    80000c3c:	3c860613          	addi	a2,a2,968 # 80008000 <etext>
    80000c40:	00007597          	auipc	a1,0x7
    80000c44:	41058593          	addi	a1,a1,1040 # 80008050 <__func__.1+0x48>
    80000c48:	00007517          	auipc	a0,0x7
    80000c4c:	41850513          	addi	a0,a0,1048 # 80008060 <__func__.1+0x58>
    80000c50:	00000097          	auipc	ra,0x0
    80000c54:	96c080e7          	jalr	-1684(ra) # 800005bc <printf>
    80000c58:	00007517          	auipc	a0,0x7
    80000c5c:	41850513          	addi	a0,a0,1048 # 80008070 <__func__.1+0x68>
    80000c60:	00000097          	auipc	ra,0x0
    80000c64:	900080e7          	jalr	-1792(ra) # 80000560 <panic>
    release(&kmem.lock);
    80000c68:	00013517          	auipc	a0,0x13
    80000c6c:	ed850513          	addi	a0,a0,-296 # 80013b40 <kmem>
    80000c70:	00000097          	auipc	ra,0x0
    80000c74:	14e080e7          	jalr	334(ra) # 80000dbe <release>
    if (r)
    80000c78:	bf61                	j	80000c10 <kalloc+0x4c>

0000000080000c7a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c7a:	1141                	addi	sp,sp,-16
    80000c7c:	e422                	sd	s0,8(sp)
    80000c7e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c80:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c82:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c86:	00053823          	sd	zero,16(a0)
}
    80000c8a:	6422                	ld	s0,8(sp)
    80000c8c:	0141                	addi	sp,sp,16
    80000c8e:	8082                	ret

0000000080000c90 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c90:	411c                	lw	a5,0(a0)
    80000c92:	e399                	bnez	a5,80000c98 <holding+0x8>
    80000c94:	4501                	li	a0,0
  return r;
}
    80000c96:	8082                	ret
{
    80000c98:	1101                	addi	sp,sp,-32
    80000c9a:	ec06                	sd	ra,24(sp)
    80000c9c:	e822                	sd	s0,16(sp)
    80000c9e:	e426                	sd	s1,8(sp)
    80000ca0:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ca2:	6904                	ld	s1,16(a0)
    80000ca4:	00001097          	auipc	ra,0x1
    80000ca8:	414080e7          	jalr	1044(ra) # 800020b8 <mycpu>
    80000cac:	40a48533          	sub	a0,s1,a0
    80000cb0:	00153513          	seqz	a0,a0
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	addi	sp,sp,32
    80000cbc:	8082                	ret

0000000080000cbe <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000cbe:	1101                	addi	sp,sp,-32
    80000cc0:	ec06                	sd	ra,24(sp)
    80000cc2:	e822                	sd	s0,16(sp)
    80000cc4:	e426                	sd	s1,8(sp)
    80000cc6:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000cc8:	100024f3          	csrr	s1,sstatus
    80000ccc:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cd0:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000cd2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000cd6:	00001097          	auipc	ra,0x1
    80000cda:	3e2080e7          	jalr	994(ra) # 800020b8 <mycpu>
    80000cde:	5d3c                	lw	a5,120(a0)
    80000ce0:	cf89                	beqz	a5,80000cfa <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ce2:	00001097          	auipc	ra,0x1
    80000ce6:	3d6080e7          	jalr	982(ra) # 800020b8 <mycpu>
    80000cea:	5d3c                	lw	a5,120(a0)
    80000cec:	2785                	addiw	a5,a5,1
    80000cee:	dd3c                	sw	a5,120(a0)
}
    80000cf0:	60e2                	ld	ra,24(sp)
    80000cf2:	6442                	ld	s0,16(sp)
    80000cf4:	64a2                	ld	s1,8(sp)
    80000cf6:	6105                	addi	sp,sp,32
    80000cf8:	8082                	ret
    mycpu()->intena = old;
    80000cfa:	00001097          	auipc	ra,0x1
    80000cfe:	3be080e7          	jalr	958(ra) # 800020b8 <mycpu>
    return (x & SSTATUS_SIE) != 0;
    80000d02:	8085                	srli	s1,s1,0x1
    80000d04:	8885                	andi	s1,s1,1
    80000d06:	dd64                	sw	s1,124(a0)
    80000d08:	bfe9                	j	80000ce2 <push_off+0x24>

0000000080000d0a <acquire>:
{
    80000d0a:	1101                	addi	sp,sp,-32
    80000d0c:	ec06                	sd	ra,24(sp)
    80000d0e:	e822                	sd	s0,16(sp)
    80000d10:	e426                	sd	s1,8(sp)
    80000d12:	1000                	addi	s0,sp,32
    80000d14:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d16:	00000097          	auipc	ra,0x0
    80000d1a:	fa8080e7          	jalr	-88(ra) # 80000cbe <push_off>
  if(holding(lk))
    80000d1e:	8526                	mv	a0,s1
    80000d20:	00000097          	auipc	ra,0x0
    80000d24:	f70080e7          	jalr	-144(ra) # 80000c90 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d28:	4705                	li	a4,1
  if(holding(lk))
    80000d2a:	e115                	bnez	a0,80000d4e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d2c:	87ba                	mv	a5,a4
    80000d2e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d32:	2781                	sext.w	a5,a5
    80000d34:	ffe5                	bnez	a5,80000d2c <acquire+0x22>
  __sync_synchronize();
    80000d36:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000d3a:	00001097          	auipc	ra,0x1
    80000d3e:	37e080e7          	jalr	894(ra) # 800020b8 <mycpu>
    80000d42:	e888                	sd	a0,16(s1)
}
    80000d44:	60e2                	ld	ra,24(sp)
    80000d46:	6442                	ld	s0,16(sp)
    80000d48:	64a2                	ld	s1,8(sp)
    80000d4a:	6105                	addi	sp,sp,32
    80000d4c:	8082                	ret
    panic("acquire");
    80000d4e:	00007517          	auipc	a0,0x7
    80000d52:	34250513          	addi	a0,a0,834 # 80008090 <__func__.1+0x88>
    80000d56:	00000097          	auipc	ra,0x0
    80000d5a:	80a080e7          	jalr	-2038(ra) # 80000560 <panic>

0000000080000d5e <pop_off>:

void
pop_off(void)
{
    80000d5e:	1141                	addi	sp,sp,-16
    80000d60:	e406                	sd	ra,8(sp)
    80000d62:	e022                	sd	s0,0(sp)
    80000d64:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d66:	00001097          	auipc	ra,0x1
    80000d6a:	352080e7          	jalr	850(ra) # 800020b8 <mycpu>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000d6e:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80000d72:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d74:	e78d                	bnez	a5,80000d9e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d76:	5d3c                	lw	a5,120(a0)
    80000d78:	02f05b63          	blez	a5,80000dae <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d7c:	37fd                	addiw	a5,a5,-1
    80000d7e:	0007871b          	sext.w	a4,a5
    80000d82:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d84:	eb09                	bnez	a4,80000d96 <pop_off+0x38>
    80000d86:	5d7c                	lw	a5,124(a0)
    80000d88:	c799                	beqz	a5,80000d96 <pop_off+0x38>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000d8a:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d8e:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000d92:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret
    panic("pop_off - interruptible");
    80000d9e:	00007517          	auipc	a0,0x7
    80000da2:	2fa50513          	addi	a0,a0,762 # 80008098 <__func__.1+0x90>
    80000da6:	fffff097          	auipc	ra,0xfffff
    80000daa:	7ba080e7          	jalr	1978(ra) # 80000560 <panic>
    panic("pop_off");
    80000dae:	00007517          	auipc	a0,0x7
    80000db2:	30250513          	addi	a0,a0,770 # 800080b0 <__func__.1+0xa8>
    80000db6:	fffff097          	auipc	ra,0xfffff
    80000dba:	7aa080e7          	jalr	1962(ra) # 80000560 <panic>

0000000080000dbe <release>:
{
    80000dbe:	1101                	addi	sp,sp,-32
    80000dc0:	ec06                	sd	ra,24(sp)
    80000dc2:	e822                	sd	s0,16(sp)
    80000dc4:	e426                	sd	s1,8(sp)
    80000dc6:	1000                	addi	s0,sp,32
    80000dc8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000dca:	00000097          	auipc	ra,0x0
    80000dce:	ec6080e7          	jalr	-314(ra) # 80000c90 <holding>
    80000dd2:	c115                	beqz	a0,80000df6 <release+0x38>
  lk->cpu = 0;
    80000dd4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000dd8:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000ddc:	0310000f          	fence	rw,w
    80000de0:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000de4:	00000097          	auipc	ra,0x0
    80000de8:	f7a080e7          	jalr	-134(ra) # 80000d5e <pop_off>
}
    80000dec:	60e2                	ld	ra,24(sp)
    80000dee:	6442                	ld	s0,16(sp)
    80000df0:	64a2                	ld	s1,8(sp)
    80000df2:	6105                	addi	sp,sp,32
    80000df4:	8082                	ret
    panic("release");
    80000df6:	00007517          	auipc	a0,0x7
    80000dfa:	2c250513          	addi	a0,a0,706 # 800080b8 <__func__.1+0xb0>
    80000dfe:	fffff097          	auipc	ra,0xfffff
    80000e02:	762080e7          	jalr	1890(ra) # 80000560 <panic>

0000000080000e06 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e0c:	ca19                	beqz	a2,80000e22 <memset+0x1c>
    80000e0e:	87aa                	mv	a5,a0
    80000e10:	1602                	slli	a2,a2,0x20
    80000e12:	9201                	srli	a2,a2,0x20
    80000e14:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e18:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e1c:	0785                	addi	a5,a5,1
    80000e1e:	fee79de3          	bne	a5,a4,80000e18 <memset+0x12>
  }
  return dst;
}
    80000e22:	6422                	ld	s0,8(sp)
    80000e24:	0141                	addi	sp,sp,16
    80000e26:	8082                	ret

0000000080000e28 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e28:	1141                	addi	sp,sp,-16
    80000e2a:	e422                	sd	s0,8(sp)
    80000e2c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e2e:	ca05                	beqz	a2,80000e5e <memcmp+0x36>
    80000e30:	fff6069b          	addiw	a3,a2,-1
    80000e34:	1682                	slli	a3,a3,0x20
    80000e36:	9281                	srli	a3,a3,0x20
    80000e38:	0685                	addi	a3,a3,1
    80000e3a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e3c:	00054783          	lbu	a5,0(a0)
    80000e40:	0005c703          	lbu	a4,0(a1)
    80000e44:	00e79863          	bne	a5,a4,80000e54 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e48:	0505                	addi	a0,a0,1
    80000e4a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e4c:	fed518e3          	bne	a0,a3,80000e3c <memcmp+0x14>
  }

  return 0;
    80000e50:	4501                	li	a0,0
    80000e52:	a019                	j	80000e58 <memcmp+0x30>
      return *s1 - *s2;
    80000e54:	40e7853b          	subw	a0,a5,a4
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  return 0;
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <memcmp+0x30>

0000000080000e62 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e422                	sd	s0,8(sp)
    80000e66:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000e68:	c205                	beqz	a2,80000e88 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e6a:	02a5e263          	bltu	a1,a0,80000e8e <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e6e:	1602                	slli	a2,a2,0x20
    80000e70:	9201                	srli	a2,a2,0x20
    80000e72:	00c587b3          	add	a5,a1,a2
{
    80000e76:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e78:	0585                	addi	a1,a1,1
    80000e7a:	0705                	addi	a4,a4,1
    80000e7c:	fff5c683          	lbu	a3,-1(a1)
    80000e80:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e84:	feb79ae3          	bne	a5,a1,80000e78 <memmove+0x16>

  return dst;
}
    80000e88:	6422                	ld	s0,8(sp)
    80000e8a:	0141                	addi	sp,sp,16
    80000e8c:	8082                	ret
  if(s < d && s + n > d){
    80000e8e:	02061693          	slli	a3,a2,0x20
    80000e92:	9281                	srli	a3,a3,0x20
    80000e94:	00d58733          	add	a4,a1,a3
    80000e98:	fce57be3          	bgeu	a0,a4,80000e6e <memmove+0xc>
    d += n;
    80000e9c:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e9e:	fff6079b          	addiw	a5,a2,-1
    80000ea2:	1782                	slli	a5,a5,0x20
    80000ea4:	9381                	srli	a5,a5,0x20
    80000ea6:	fff7c793          	not	a5,a5
    80000eaa:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000eac:	177d                	addi	a4,a4,-1
    80000eae:	16fd                	addi	a3,a3,-1
    80000eb0:	00074603          	lbu	a2,0(a4)
    80000eb4:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000eb8:	fef71ae3          	bne	a4,a5,80000eac <memmove+0x4a>
    80000ebc:	b7f1                	j	80000e88 <memmove+0x26>

0000000080000ebe <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000ebe:	1141                	addi	sp,sp,-16
    80000ec0:	e406                	sd	ra,8(sp)
    80000ec2:	e022                	sd	s0,0(sp)
    80000ec4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000ec6:	00000097          	auipc	ra,0x0
    80000eca:	f9c080e7          	jalr	-100(ra) # 80000e62 <memmove>
}
    80000ece:	60a2                	ld	ra,8(sp)
    80000ed0:	6402                	ld	s0,0(sp)
    80000ed2:	0141                	addi	sp,sp,16
    80000ed4:	8082                	ret

0000000080000ed6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000ed6:	1141                	addi	sp,sp,-16
    80000ed8:	e422                	sd	s0,8(sp)
    80000eda:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000edc:	ce11                	beqz	a2,80000ef8 <strncmp+0x22>
    80000ede:	00054783          	lbu	a5,0(a0)
    80000ee2:	cf89                	beqz	a5,80000efc <strncmp+0x26>
    80000ee4:	0005c703          	lbu	a4,0(a1)
    80000ee8:	00f71a63          	bne	a4,a5,80000efc <strncmp+0x26>
    n--, p++, q++;
    80000eec:	367d                	addiw	a2,a2,-1
    80000eee:	0505                	addi	a0,a0,1
    80000ef0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ef2:	f675                	bnez	a2,80000ede <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ef4:	4501                	li	a0,0
    80000ef6:	a801                	j	80000f06 <strncmp+0x30>
    80000ef8:	4501                	li	a0,0
    80000efa:	a031                	j	80000f06 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000efc:	00054503          	lbu	a0,0(a0)
    80000f00:	0005c783          	lbu	a5,0(a1)
    80000f04:	9d1d                	subw	a0,a0,a5
}
    80000f06:	6422                	ld	s0,8(sp)
    80000f08:	0141                	addi	sp,sp,16
    80000f0a:	8082                	ret

0000000080000f0c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f0c:	1141                	addi	sp,sp,-16
    80000f0e:	e422                	sd	s0,8(sp)
    80000f10:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f12:	87aa                	mv	a5,a0
    80000f14:	86b2                	mv	a3,a2
    80000f16:	367d                	addiw	a2,a2,-1
    80000f18:	02d05563          	blez	a3,80000f42 <strncpy+0x36>
    80000f1c:	0785                	addi	a5,a5,1
    80000f1e:	0005c703          	lbu	a4,0(a1)
    80000f22:	fee78fa3          	sb	a4,-1(a5)
    80000f26:	0585                	addi	a1,a1,1
    80000f28:	f775                	bnez	a4,80000f14 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f2a:	873e                	mv	a4,a5
    80000f2c:	9fb5                	addw	a5,a5,a3
    80000f2e:	37fd                	addiw	a5,a5,-1
    80000f30:	00c05963          	blez	a2,80000f42 <strncpy+0x36>
    *s++ = 0;
    80000f34:	0705                	addi	a4,a4,1
    80000f36:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000f3a:	40e786bb          	subw	a3,a5,a4
    80000f3e:	fed04be3          	bgtz	a3,80000f34 <strncpy+0x28>
  return os;
}
    80000f42:	6422                	ld	s0,8(sp)
    80000f44:	0141                	addi	sp,sp,16
    80000f46:	8082                	ret

0000000080000f48 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f48:	1141                	addi	sp,sp,-16
    80000f4a:	e422                	sd	s0,8(sp)
    80000f4c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f4e:	02c05363          	blez	a2,80000f74 <safestrcpy+0x2c>
    80000f52:	fff6069b          	addiw	a3,a2,-1
    80000f56:	1682                	slli	a3,a3,0x20
    80000f58:	9281                	srli	a3,a3,0x20
    80000f5a:	96ae                	add	a3,a3,a1
    80000f5c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f5e:	00d58963          	beq	a1,a3,80000f70 <safestrcpy+0x28>
    80000f62:	0585                	addi	a1,a1,1
    80000f64:	0785                	addi	a5,a5,1
    80000f66:	fff5c703          	lbu	a4,-1(a1)
    80000f6a:	fee78fa3          	sb	a4,-1(a5)
    80000f6e:	fb65                	bnez	a4,80000f5e <safestrcpy+0x16>
    ;
  *s = 0;
    80000f70:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f74:	6422                	ld	s0,8(sp)
    80000f76:	0141                	addi	sp,sp,16
    80000f78:	8082                	ret

0000000080000f7a <strlen>:

int
strlen(const char *s)
{
    80000f7a:	1141                	addi	sp,sp,-16
    80000f7c:	e422                	sd	s0,8(sp)
    80000f7e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f80:	00054783          	lbu	a5,0(a0)
    80000f84:	cf91                	beqz	a5,80000fa0 <strlen+0x26>
    80000f86:	0505                	addi	a0,a0,1
    80000f88:	87aa                	mv	a5,a0
    80000f8a:	86be                	mv	a3,a5
    80000f8c:	0785                	addi	a5,a5,1
    80000f8e:	fff7c703          	lbu	a4,-1(a5)
    80000f92:	ff65                	bnez	a4,80000f8a <strlen+0x10>
    80000f94:	40a6853b          	subw	a0,a3,a0
    80000f98:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000f9a:	6422                	ld	s0,8(sp)
    80000f9c:	0141                	addi	sp,sp,16
    80000f9e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000fa0:	4501                	li	a0,0
    80000fa2:	bfe5                	j	80000f9a <strlen+0x20>

0000000080000fa4 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000fa4:	1141                	addi	sp,sp,-16
    80000fa6:	e406                	sd	ra,8(sp)
    80000fa8:	e022                	sd	s0,0(sp)
    80000faa:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000fac:	00001097          	auipc	ra,0x1
    80000fb0:	0fc080e7          	jalr	252(ra) # 800020a8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000fb4:	0000b717          	auipc	a4,0xb
    80000fb8:	92470713          	addi	a4,a4,-1756 # 8000b8d8 <started>
  if(cpuid() == 0){
    80000fbc:	c139                	beqz	a0,80001002 <main+0x5e>
    while(started == 0)
    80000fbe:	431c                	lw	a5,0(a4)
    80000fc0:	2781                	sext.w	a5,a5
    80000fc2:	dff5                	beqz	a5,80000fbe <main+0x1a>
      ;
    __sync_synchronize();
    80000fc4:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000fc8:	00001097          	auipc	ra,0x1
    80000fcc:	0e0080e7          	jalr	224(ra) # 800020a8 <cpuid>
    80000fd0:	85aa                	mv	a1,a0
    80000fd2:	00007517          	auipc	a0,0x7
    80000fd6:	10650513          	addi	a0,a0,262 # 800080d8 <__func__.1+0xd0>
    80000fda:	fffff097          	auipc	ra,0xfffff
    80000fde:	5e2080e7          	jalr	1506(ra) # 800005bc <printf>
    kvminithart();    // turn on paging
    80000fe2:	00000097          	auipc	ra,0x0
    80000fe6:	0e0080e7          	jalr	224(ra) # 800010c2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fea:	00002097          	auipc	ra,0x2
    80000fee:	f64080e7          	jalr	-156(ra) # 80002f4e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ff2:	00006097          	auipc	ra,0x6
    80000ff6:	862080e7          	jalr	-1950(ra) # 80006854 <plicinithart>
  }

  scheduler();        
    80000ffa:	00001097          	auipc	ra,0x1
    80000ffe:	75a080e7          	jalr	1882(ra) # 80002754 <scheduler>
    consoleinit();
    80001002:	fffff097          	auipc	ra,0xfffff
    80001006:	46e080e7          	jalr	1134(ra) # 80000470 <consoleinit>
    printfinit();
    8000100a:	fffff097          	auipc	ra,0xfffff
    8000100e:	7ba080e7          	jalr	1978(ra) # 800007c4 <printfinit>
    printf("\n");
    80001012:	00007517          	auipc	a0,0x7
    80001016:	00e50513          	addi	a0,a0,14 # 80008020 <__func__.1+0x18>
    8000101a:	fffff097          	auipc	ra,0xfffff
    8000101e:	5a2080e7          	jalr	1442(ra) # 800005bc <printf>
    printf("xv6 kernel is booting\n");
    80001022:	00007517          	auipc	a0,0x7
    80001026:	09e50513          	addi	a0,a0,158 # 800080c0 <__func__.1+0xb8>
    8000102a:	fffff097          	auipc	ra,0xfffff
    8000102e:	592080e7          	jalr	1426(ra) # 800005bc <printf>
    printf("\n");
    80001032:	00007517          	auipc	a0,0x7
    80001036:	fee50513          	addi	a0,a0,-18 # 80008020 <__func__.1+0x18>
    8000103a:	fffff097          	auipc	ra,0xfffff
    8000103e:	582080e7          	jalr	1410(ra) # 800005bc <printf>
    init_refcount_table(); // Initialize reference counter table
    80001042:	00000097          	auipc	ra,0x0
    80001046:	190080e7          	jalr	400(ra) # 800011d2 <init_refcount_table>
    kinit();         // physical page allocator
    8000104a:	00000097          	auipc	ra,0x0
    8000104e:	b2e080e7          	jalr	-1234(ra) # 80000b78 <kinit>
    kvminit();       // create kernel page table
    80001052:	00000097          	auipc	ra,0x0
    80001056:	4a0080e7          	jalr	1184(ra) # 800014f2 <kvminit>
    kvminithart();   // turn on paging
    8000105a:	00000097          	auipc	ra,0x0
    8000105e:	068080e7          	jalr	104(ra) # 800010c2 <kvminithart>
    procinit();      // process table
    80001062:	00001097          	auipc	ra,0x1
    80001066:	e8a080e7          	jalr	-374(ra) # 80001eec <procinit>
    trapinit();      // trap vectors
    8000106a:	00002097          	auipc	ra,0x2
    8000106e:	ebc080e7          	jalr	-324(ra) # 80002f26 <trapinit>
    trapinithart();  // install kernel trap vector
    80001072:	00002097          	auipc	ra,0x2
    80001076:	edc080e7          	jalr	-292(ra) # 80002f4e <trapinithart>
    plicinit();      // set up interrupt controller
    8000107a:	00005097          	auipc	ra,0x5
    8000107e:	7c0080e7          	jalr	1984(ra) # 8000683a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001082:	00005097          	auipc	ra,0x5
    80001086:	7d2080e7          	jalr	2002(ra) # 80006854 <plicinithart>
    binit();         // buffer cache
    8000108a:	00003097          	auipc	ra,0x3
    8000108e:	896080e7          	jalr	-1898(ra) # 80003920 <binit>
    iinit();         // inode table
    80001092:	00003097          	auipc	ra,0x3
    80001096:	f4c080e7          	jalr	-180(ra) # 80003fde <iinit>
    fileinit();      // file table
    8000109a:	00004097          	auipc	ra,0x4
    8000109e:	efc080e7          	jalr	-260(ra) # 80004f96 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010a2:	00006097          	auipc	ra,0x6
    800010a6:	8ba080e7          	jalr	-1862(ra) # 8000695c <virtio_disk_init>
    userinit();      // first user process
    800010aa:	00001097          	auipc	ra,0x1
    800010ae:	2fc080e7          	jalr	764(ra) # 800023a6 <userinit>
    __sync_synchronize();
    800010b2:	0330000f          	fence	rw,rw
    started = 1;
    800010b6:	4785                	li	a5,1
    800010b8:	0000b717          	auipc	a4,0xb
    800010bc:	82f72023          	sw	a5,-2016(a4) # 8000b8d8 <started>
    800010c0:	bf2d                	j	80000ffa <main+0x56>

00000000800010c2 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800010c2:	1141                	addi	sp,sp,-16
    800010c4:	e422                	sd	s0,8(sp)
    800010c6:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
    // the zero, zero means flush all TLB entries.
    asm volatile("sfence.vma zero, zero");
    800010c8:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800010cc:	0000b797          	auipc	a5,0xb
    800010d0:	8147b783          	ld	a5,-2028(a5) # 8000b8e0 <kernel_pagetable>
    800010d4:	83b1                	srli	a5,a5,0xc
    800010d6:	577d                	li	a4,-1
    800010d8:	177e                	slli	a4,a4,0x3f
    800010da:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    800010dc:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma zero, zero");
    800010e0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800010e4:	6422                	ld	s0,8(sp)
    800010e6:	0141                	addi	sp,sp,16
    800010e8:	8082                	ret

00000000800010ea <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010ea:	7139                	addi	sp,sp,-64
    800010ec:	fc06                	sd	ra,56(sp)
    800010ee:	f822                	sd	s0,48(sp)
    800010f0:	f426                	sd	s1,40(sp)
    800010f2:	f04a                	sd	s2,32(sp)
    800010f4:	ec4e                	sd	s3,24(sp)
    800010f6:	e852                	sd	s4,16(sp)
    800010f8:	e456                	sd	s5,8(sp)
    800010fa:	e05a                	sd	s6,0(sp)
    800010fc:	0080                	addi	s0,sp,64
    800010fe:	84aa                	mv	s1,a0
    80001100:	89ae                	mv	s3,a1
    80001102:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001104:	57fd                	li	a5,-1
    80001106:	83e9                	srli	a5,a5,0x1a
    80001108:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000110a:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000110c:	04b7f263          	bgeu	a5,a1,80001150 <walk+0x66>
    panic("walk");
    80001110:	00007517          	auipc	a0,0x7
    80001114:	fe050513          	addi	a0,a0,-32 # 800080f0 <__func__.1+0xe8>
    80001118:	fffff097          	auipc	ra,0xfffff
    8000111c:	448080e7          	jalr	1096(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001120:	060a8663          	beqz	s5,8000118c <walk+0xa2>
    80001124:	00000097          	auipc	ra,0x0
    80001128:	aa0080e7          	jalr	-1376(ra) # 80000bc4 <kalloc>
    8000112c:	84aa                	mv	s1,a0
    8000112e:	c529                	beqz	a0,80001178 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001130:	6605                	lui	a2,0x1
    80001132:	4581                	li	a1,0
    80001134:	00000097          	auipc	ra,0x0
    80001138:	cd2080e7          	jalr	-814(ra) # 80000e06 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000113c:	00c4d793          	srli	a5,s1,0xc
    80001140:	07aa                	slli	a5,a5,0xa
    80001142:	0017e793          	ori	a5,a5,1
    80001146:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000114a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ff5a257>
    8000114c:	036a0063          	beq	s4,s6,8000116c <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001150:	0149d933          	srl	s2,s3,s4
    80001154:	1ff97913          	andi	s2,s2,511
    80001158:	090e                	slli	s2,s2,0x3
    8000115a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000115c:	00093483          	ld	s1,0(s2)
    80001160:	0014f793          	andi	a5,s1,1
    80001164:	dfd5                	beqz	a5,80001120 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001166:	80a9                	srli	s1,s1,0xa
    80001168:	04b2                	slli	s1,s1,0xc
    8000116a:	b7c5                	j	8000114a <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000116c:	00c9d513          	srli	a0,s3,0xc
    80001170:	1ff57513          	andi	a0,a0,511
    80001174:	050e                	slli	a0,a0,0x3
    80001176:	9526                	add	a0,a0,s1
}
    80001178:	70e2                	ld	ra,56(sp)
    8000117a:	7442                	ld	s0,48(sp)
    8000117c:	74a2                	ld	s1,40(sp)
    8000117e:	7902                	ld	s2,32(sp)
    80001180:	69e2                	ld	s3,24(sp)
    80001182:	6a42                	ld	s4,16(sp)
    80001184:	6aa2                	ld	s5,8(sp)
    80001186:	6b02                	ld	s6,0(sp)
    80001188:	6121                	addi	sp,sp,64
    8000118a:	8082                	ret
        return 0;
    8000118c:	4501                	li	a0,0
    8000118e:	b7ed                	j	80001178 <walk+0x8e>

0000000080001190 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001190:	57fd                	li	a5,-1
    80001192:	83e9                	srli	a5,a5,0x1a
    80001194:	00b7f463          	bgeu	a5,a1,8000119c <walkaddr+0xc>
    return 0;
    80001198:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000119a:	8082                	ret
{
    8000119c:	1141                	addi	sp,sp,-16
    8000119e:	e406                	sd	ra,8(sp)
    800011a0:	e022                	sd	s0,0(sp)
    800011a2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800011a4:	4601                	li	a2,0
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	f44080e7          	jalr	-188(ra) # 800010ea <walk>
  if(pte == 0)
    800011ae:	c105                	beqz	a0,800011ce <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800011b0:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011b2:	0117f693          	andi	a3,a5,17
    800011b6:	4745                	li	a4,17
    return 0;
    800011b8:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011ba:	00e68663          	beq	a3,a4,800011c6 <walkaddr+0x36>
}
    800011be:	60a2                	ld	ra,8(sp)
    800011c0:	6402                	ld	s0,0(sp)
    800011c2:	0141                	addi	sp,sp,16
    800011c4:	8082                	ret
  pa = PTE2PA(*pte);
    800011c6:	83a9                	srli	a5,a5,0xa
    800011c8:	00c79513          	slli	a0,a5,0xc
  return pa;
    800011cc:	bfcd                	j	800011be <walkaddr+0x2e>
    return 0;
    800011ce:	4501                	li	a0,0
    800011d0:	b7fd                	j	800011be <walkaddr+0x2e>

00000000800011d2 <init_refcount_table>:
    pa += PGSIZE;
  }
  return 0;
}

void init_refcount_table() {
    800011d2:	1141                	addi	sp,sp,-16
    800011d4:	e422                	sd	s0,8(sp)
    800011d6:	0800                	addi	s0,sp,16

  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    800011d8:	00013797          	auipc	a5,0x13
    800011dc:	9a078793          	addi	a5,a5,-1632 # 80013b78 <refcount_table>
    800011e0:	00093717          	auipc	a4,0x93
    800011e4:	99870713          	addi	a4,a4,-1640 # 80093b78 <refcount_table+0x80000>
    refcount_table.refcount_entry[i].pa = 0;
    800011e8:	0007b023          	sd	zero,0(a5)
    refcount_table.refcount_entry[i].ref_count = 0;
    800011ec:	0007a423          	sw	zero,8(a5)
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    800011f0:	07c1                	addi	a5,a5,16
    800011f2:	fee79be3          	bne	a5,a4,800011e8 <init_refcount_table+0x16>
  }
}
    800011f6:	6422                	ld	s0,8(sp)
    800011f8:	0141                	addi	sp,sp,16
    800011fa:	8082                	ret

00000000800011fc <increment_ref_count>:
void increment_ref_count(uint64 pa) {
  // Align the physical address to page boundary
  pa = PGROUNDDOWN(pa);

  // Special case: Allow MMIO regions
  if (pa == UART0 || pa == VIRTIO0 || (pa >= PLIC && pa < PLIC + 0x400000)) {
    800011fc:	77f9                	lui	a5,0xffffe
    800011fe:	8fe9                	and	a5,a5,a0
    80001200:	10000737          	lui	a4,0x10000
    80001204:	12e78863          	beq	a5,a4,80001334 <increment_ref_count+0x138>
void increment_ref_count(uint64 pa) {
    80001208:	1101                	addi	sp,sp,-32
    8000120a:	ec06                	sd	ra,24(sp)
    8000120c:	e822                	sd	s0,16(sp)
    8000120e:	e426                	sd	s1,8(sp)
    80001210:	1000                	addi	s0,sp,32
  pa = PGROUNDDOWN(pa);
    80001212:	77fd                	lui	a5,0xfffff
    80001214:	00f574b3          	and	s1,a0,a5
  if (pa == UART0 || pa == VIRTIO0 || (pa >= PLIC && pa < PLIC + 0x400000)) {
    80001218:	f40007b7          	lui	a5,0xf4000
    8000121c:	97a6                	add	a5,a5,s1
    8000121e:	00400737          	lui	a4,0x400
    80001222:	0ee7e263          	bltu	a5,a4,80001306 <increment_ref_count+0x10a>
    return;  // Allow mapping without reference counting
  }
  
  // Check if address is within valid physical memory range
  if ((pa < KERNBASE || pa >= PHYSTOP)) {
    80001226:	800007b7          	lui	a5,0x80000
    8000122a:	97a6                	add	a5,a5,s1
    8000122c:	08000737          	lui	a4,0x8000
    80001230:	08e7f563          	bgeu	a5,a4,800012ba <increment_ref_count+0xbe>
    printf("Error: PA %p outside valid range [%p, %p]\n", 
           pa, KERNBASE, PHYSTOP);
    panic("increment_ref_count: invalid physical address");
  }
  acquire(&refcount_lock);
    80001234:	00013517          	auipc	a0,0x13
    80001238:	92c50513          	addi	a0,a0,-1748 # 80013b60 <refcount_lock>
    8000123c:	00000097          	auipc	ra,0x0
    80001240:	ace080e7          	jalr	-1330(ra) # 80000d0a <acquire>
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    80001244:	00013717          	auipc	a4,0x13
    80001248:	93470713          	addi	a4,a4,-1740 # 80013b78 <refcount_table>
    8000124c:	4781                	li	a5,0
    8000124e:	6621                	lui	a2,0x8
    
    if (refcount_table.refcount_entry[i].pa == pa) {
    80001250:	6314                	ld	a3,0(a4)
    80001252:	08968963          	beq	a3,s1,800012e4 <increment_ref_count+0xe8>
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    80001256:	2785                	addiw	a5,a5,1 # ffffffff80000001 <end+0xfffffffefff5b261>
    80001258:	0741                	addi	a4,a4,16
    8000125a:	fec79be3          	bne	a5,a2,80001250 <increment_ref_count+0x54>
    8000125e:	00013717          	auipc	a4,0x13
    80001262:	92270713          	addi	a4,a4,-1758 # 80013b80 <refcount_table+0x8>
      release(&refcount_lock);
      return;
    }
  }
  // If the physical address is not found, add it to the table
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    80001266:	4781                	li	a5,0
    80001268:	6621                	lui	a2,0x8
    if (refcount_table.refcount_entry[i].ref_count == 0) {
    8000126a:	4314                	lw	a3,0(a4)
    8000126c:	c2d5                	beqz	a3,80001310 <increment_ref_count+0x114>
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    8000126e:	2785                	addiw	a5,a5,1
    80001270:	0741                	addi	a4,a4,16
    80001272:	fec79ce3          	bne	a5,a2,8000126a <increment_ref_count+0x6e>
      refcount_table.refcount_entry[i].ref_count = 1;
      release(&refcount_lock);
      return;
    }
  }
  release(&refcount_lock);
    80001276:	00013517          	auipc	a0,0x13
    8000127a:	8ea50513          	addi	a0,a0,-1814 # 80013b60 <refcount_lock>
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	b40080e7          	jalr	-1216(ra) # 80000dbe <release>

  // Table is full - print diagnostic information
  printf("refcount_table is full: %d entries\n", MAXPHYSICALFRAMES);
    80001286:	65a1                	lui	a1,0x8
    80001288:	00007517          	auipc	a0,0x7
    8000128c:	ed050513          	addi	a0,a0,-304 # 80008158 <__func__.1+0x150>
    80001290:	fffff097          	auipc	ra,0xfffff
    80001294:	32c080e7          	jalr	812(ra) # 800005bc <printf>
  printf("Failed to add PA: %p\n", pa);
    80001298:	85a6                	mv	a1,s1
    8000129a:	00007517          	auipc	a0,0x7
    8000129e:	ee650513          	addi	a0,a0,-282 # 80008180 <__func__.1+0x178>
    800012a2:	fffff097          	auipc	ra,0xfffff
    800012a6:	31a080e7          	jalr	794(ra) # 800005bc <printf>
  if (pa == UART0 || pa == VIRTIO0 || (pa >= PLIC && pa < PLIC + 0x400000)) {
    printf("Debug: This is MMIO region at %p\n", (uint)pa);
  }
  
  panic("increment_ref_count: no space in refcount_table");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	eee50513          	addi	a0,a0,-274 # 80008198 <__func__.1+0x190>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	2ae080e7          	jalr	686(ra) # 80000560 <panic>
    printf("Error: PA %p outside valid range [%p, %p]\n", 
    800012ba:	46c5                	li	a3,17
    800012bc:	06ee                	slli	a3,a3,0x1b
    800012be:	4605                	li	a2,1
    800012c0:	067e                	slli	a2,a2,0x1f
    800012c2:	85a6                	mv	a1,s1
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e3450513          	addi	a0,a0,-460 # 800080f8 <__func__.1+0xf0>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	2f0080e7          	jalr	752(ra) # 800005bc <printf>
    panic("increment_ref_count: invalid physical address");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e5450513          	addi	a0,a0,-428 # 80008128 <__func__.1+0x120>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	284080e7          	jalr	644(ra) # 80000560 <panic>
      refcount_table.refcount_entry[i].ref_count++;
    800012e4:	0792                	slli	a5,a5,0x4
    800012e6:	00013717          	auipc	a4,0x13
    800012ea:	89270713          	addi	a4,a4,-1902 # 80013b78 <refcount_table>
    800012ee:	97ba                	add	a5,a5,a4
    800012f0:	4798                	lw	a4,8(a5)
    800012f2:	2705                	addiw	a4,a4,1
    800012f4:	c798                	sw	a4,8(a5)
      release(&refcount_lock);
    800012f6:	00013517          	auipc	a0,0x13
    800012fa:	86a50513          	addi	a0,a0,-1942 # 80013b60 <refcount_lock>
    800012fe:	00000097          	auipc	ra,0x0
    80001302:	ac0080e7          	jalr	-1344(ra) # 80000dbe <release>
}
    80001306:	60e2                	ld	ra,24(sp)
    80001308:	6442                	ld	s0,16(sp)
    8000130a:	64a2                	ld	s1,8(sp)
    8000130c:	6105                	addi	sp,sp,32
    8000130e:	8082                	ret
      refcount_table.refcount_entry[i].pa = pa;
    80001310:	0792                	slli	a5,a5,0x4
    80001312:	00013717          	auipc	a4,0x13
    80001316:	86670713          	addi	a4,a4,-1946 # 80013b78 <refcount_table>
    8000131a:	97ba                	add	a5,a5,a4
    8000131c:	e384                	sd	s1,0(a5)
      refcount_table.refcount_entry[i].ref_count = 1;
    8000131e:	4705                	li	a4,1
    80001320:	c798                	sw	a4,8(a5)
      release(&refcount_lock);
    80001322:	00013517          	auipc	a0,0x13
    80001326:	83e50513          	addi	a0,a0,-1986 # 80013b60 <refcount_lock>
    8000132a:	00000097          	auipc	ra,0x0
    8000132e:	a94080e7          	jalr	-1388(ra) # 80000dbe <release>
      return;
    80001332:	bfd1                	j	80001306 <increment_ref_count+0x10a>
    80001334:	8082                	ret

0000000080001336 <mappages>:
{
    80001336:	715d                	addi	sp,sp,-80
    80001338:	e486                	sd	ra,72(sp)
    8000133a:	e0a2                	sd	s0,64(sp)
    8000133c:	fc26                	sd	s1,56(sp)
    8000133e:	f84a                	sd	s2,48(sp)
    80001340:	f44e                	sd	s3,40(sp)
    80001342:	f052                	sd	s4,32(sp)
    80001344:	ec56                	sd	s5,24(sp)
    80001346:	e85a                	sd	s6,16(sp)
    80001348:	e45e                	sd	s7,8(sp)
    8000134a:	e062                	sd	s8,0(sp)
    8000134c:	0880                	addi	s0,sp,80
  if(size == 0)
    8000134e:	ce31                	beqz	a2,800013aa <mappages+0x74>
    80001350:	8b2a                	mv	s6,a0
    80001352:	8bba                	mv	s7,a4
  a = PGROUNDDOWN(va);
    80001354:	777d                	lui	a4,0xfffff
    80001356:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000135a:	fff58a13          	addi	s4,a1,-1 # 7fff <_entry-0x7fff8001>
    8000135e:	9a32                	add	s4,s4,a2
    80001360:	00ea7a33          	and	s4,s4,a4
  a = PGROUNDDOWN(va);
    80001364:	89be                	mv	s3,a5
    80001366:	40f68ab3          	sub	s5,a3,a5
    a += PGSIZE;
    8000136a:	6c05                	lui	s8,0x1
    8000136c:	015984b3          	add	s1,s3,s5
    if((pte = walk(pagetable, a, 1)) == 0)
    80001370:	4605                	li	a2,1
    80001372:	85ce                	mv	a1,s3
    80001374:	855a                	mv	a0,s6
    80001376:	00000097          	auipc	ra,0x0
    8000137a:	d74080e7          	jalr	-652(ra) # 800010ea <walk>
    8000137e:	892a                	mv	s2,a0
    80001380:	c529                	beqz	a0,800013ca <mappages+0x94>
    if(*pte & PTE_V)
    80001382:	611c                	ld	a5,0(a0)
    80001384:	8b85                	andi	a5,a5,1
    80001386:	eb95                	bnez	a5,800013ba <mappages+0x84>
    increment_ref_count(pa);
    80001388:	8526                	mv	a0,s1
    8000138a:	00000097          	auipc	ra,0x0
    8000138e:	e72080e7          	jalr	-398(ra) # 800011fc <increment_ref_count>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001392:	80b1                	srli	s1,s1,0xc
    80001394:	04aa                	slli	s1,s1,0xa
    80001396:	0174e4b3          	or	s1,s1,s7
    8000139a:	0014e493          	ori	s1,s1,1
    8000139e:	00993023          	sd	s1,0(s2)
    if(a == last)
    800013a2:	05498163          	beq	s3,s4,800013e4 <mappages+0xae>
    a += PGSIZE;
    800013a6:	99e2                	add	s3,s3,s8
    if((pte = walk(pagetable, a, 1)) == 0)
    800013a8:	b7d1                	j	8000136c <mappages+0x36>
    panic("mappages: size");
    800013aa:	00007517          	auipc	a0,0x7
    800013ae:	e1e50513          	addi	a0,a0,-482 # 800081c8 <__func__.1+0x1c0>
    800013b2:	fffff097          	auipc	ra,0xfffff
    800013b6:	1ae080e7          	jalr	430(ra) # 80000560 <panic>
      panic("mappages: remap");
    800013ba:	00007517          	auipc	a0,0x7
    800013be:	e1e50513          	addi	a0,a0,-482 # 800081d8 <__func__.1+0x1d0>
    800013c2:	fffff097          	auipc	ra,0xfffff
    800013c6:	19e080e7          	jalr	414(ra) # 80000560 <panic>
      return -1;
    800013ca:	557d                	li	a0,-1
}
    800013cc:	60a6                	ld	ra,72(sp)
    800013ce:	6406                	ld	s0,64(sp)
    800013d0:	74e2                	ld	s1,56(sp)
    800013d2:	7942                	ld	s2,48(sp)
    800013d4:	79a2                	ld	s3,40(sp)
    800013d6:	7a02                	ld	s4,32(sp)
    800013d8:	6ae2                	ld	s5,24(sp)
    800013da:	6b42                	ld	s6,16(sp)
    800013dc:	6ba2                	ld	s7,8(sp)
    800013de:	6c02                	ld	s8,0(sp)
    800013e0:	6161                	addi	sp,sp,80
    800013e2:	8082                	ret
  return 0;
    800013e4:	4501                	li	a0,0
    800013e6:	b7dd                	j	800013cc <mappages+0x96>

00000000800013e8 <kvmmap>:
{
    800013e8:	1141                	addi	sp,sp,-16
    800013ea:	e406                	sd	ra,8(sp)
    800013ec:	e022                	sd	s0,0(sp)
    800013ee:	0800                	addi	s0,sp,16
    800013f0:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800013f2:	86b2                	mv	a3,a2
    800013f4:	863e                	mv	a2,a5
    800013f6:	00000097          	auipc	ra,0x0
    800013fa:	f40080e7          	jalr	-192(ra) # 80001336 <mappages>
    800013fe:	e509                	bnez	a0,80001408 <kvmmap+0x20>
}
    80001400:	60a2                	ld	ra,8(sp)
    80001402:	6402                	ld	s0,0(sp)
    80001404:	0141                	addi	sp,sp,16
    80001406:	8082                	ret
    panic("kvmmap");
    80001408:	00007517          	auipc	a0,0x7
    8000140c:	de050513          	addi	a0,a0,-544 # 800081e8 <__func__.1+0x1e0>
    80001410:	fffff097          	auipc	ra,0xfffff
    80001414:	150080e7          	jalr	336(ra) # 80000560 <panic>

0000000080001418 <kvmmake>:
{
    80001418:	1101                	addi	sp,sp,-32
    8000141a:	ec06                	sd	ra,24(sp)
    8000141c:	e822                	sd	s0,16(sp)
    8000141e:	e426                	sd	s1,8(sp)
    80001420:	e04a                	sd	s2,0(sp)
    80001422:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001424:	fffff097          	auipc	ra,0xfffff
    80001428:	7a0080e7          	jalr	1952(ra) # 80000bc4 <kalloc>
    8000142c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000142e:	6605                	lui	a2,0x1
    80001430:	4581                	li	a1,0
    80001432:	00000097          	auipc	ra,0x0
    80001436:	9d4080e7          	jalr	-1580(ra) # 80000e06 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000143a:	4719                	li	a4,6
    8000143c:	6685                	lui	a3,0x1
    8000143e:	10000637          	lui	a2,0x10000
    80001442:	100005b7          	lui	a1,0x10000
    80001446:	8526                	mv	a0,s1
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	fa0080e7          	jalr	-96(ra) # 800013e8 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001450:	4719                	li	a4,6
    80001452:	6685                	lui	a3,0x1
    80001454:	10001637          	lui	a2,0x10001
    80001458:	100015b7          	lui	a1,0x10001
    8000145c:	8526                	mv	a0,s1
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	f8a080e7          	jalr	-118(ra) # 800013e8 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 400000, PTE_R | PTE_W);
    80001466:	4719                	li	a4,6
    80001468:	000626b7          	lui	a3,0x62
    8000146c:	a8068693          	addi	a3,a3,-1408 # 61a80 <_entry-0x7ff9e580>
    80001470:	0c000637          	lui	a2,0xc000
    80001474:	0c0005b7          	lui	a1,0xc000
    80001478:	8526                	mv	a0,s1
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f6e080e7          	jalr	-146(ra) # 800013e8 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001482:	00007917          	auipc	s2,0x7
    80001486:	b7e90913          	addi	s2,s2,-1154 # 80008000 <etext>
    8000148a:	4729                	li	a4,10
    8000148c:	80007697          	auipc	a3,0x80007
    80001490:	b7468693          	addi	a3,a3,-1164 # 8000 <_entry-0x7fff8000>
    80001494:	4605                	li	a2,1
    80001496:	067e                	slli	a2,a2,0x1f
    80001498:	85b2                	mv	a1,a2
    8000149a:	8526                	mv	a0,s1
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f4c080e7          	jalr	-180(ra) # 800013e8 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800014a4:	46c5                	li	a3,17
    800014a6:	06ee                	slli	a3,a3,0x1b
    800014a8:	4719                	li	a4,6
    800014aa:	412686b3          	sub	a3,a3,s2
    800014ae:	864a                	mv	a2,s2
    800014b0:	85ca                	mv	a1,s2
    800014b2:	8526                	mv	a0,s1
    800014b4:	00000097          	auipc	ra,0x0
    800014b8:	f34080e7          	jalr	-204(ra) # 800013e8 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800014bc:	4729                	li	a4,10
    800014be:	6685                	lui	a3,0x1
    800014c0:	00006617          	auipc	a2,0x6
    800014c4:	b4060613          	addi	a2,a2,-1216 # 80007000 <_trampoline>
    800014c8:	040005b7          	lui	a1,0x4000
    800014cc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800014ce:	05b2                	slli	a1,a1,0xc
    800014d0:	8526                	mv	a0,s1
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	f16080e7          	jalr	-234(ra) # 800013e8 <kvmmap>
  proc_mapstacks(kpgtbl);
    800014da:	8526                	mv	a0,s1
    800014dc:	00001097          	auipc	ra,0x1
    800014e0:	96c080e7          	jalr	-1684(ra) # 80001e48 <proc_mapstacks>
}
    800014e4:	8526                	mv	a0,s1
    800014e6:	60e2                	ld	ra,24(sp)
    800014e8:	6442                	ld	s0,16(sp)
    800014ea:	64a2                	ld	s1,8(sp)
    800014ec:	6902                	ld	s2,0(sp)
    800014ee:	6105                	addi	sp,sp,32
    800014f0:	8082                	ret

00000000800014f2 <kvminit>:
{
    800014f2:	1141                	addi	sp,sp,-16
    800014f4:	e406                	sd	ra,8(sp)
    800014f6:	e022                	sd	s0,0(sp)
    800014f8:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800014fa:	00000097          	auipc	ra,0x0
    800014fe:	f1e080e7          	jalr	-226(ra) # 80001418 <kvmmake>
    80001502:	0000a797          	auipc	a5,0xa
    80001506:	3ca7bf23          	sd	a0,990(a5) # 8000b8e0 <kernel_pagetable>
}
    8000150a:	60a2                	ld	ra,8(sp)
    8000150c:	6402                	ld	s0,0(sp)
    8000150e:	0141                	addi	sp,sp,16
    80001510:	8082                	ret

0000000080001512 <decrement_ref_count>:

// Decrement the reference count for a physical address and deallocate if it hits zero
void decrement_ref_count(uint64 pa) {
    80001512:	1101                	addi	sp,sp,-32
    80001514:	ec06                	sd	ra,24(sp)
    80001516:	e822                	sd	s0,16(sp)
    80001518:	e426                	sd	s1,8(sp)
    8000151a:	e04a                	sd	s2,0(sp)
    8000151c:	1000                	addi	s0,sp,32
  pa = PGROUNDDOWN(pa);
    8000151e:	77fd                	lui	a5,0xfffff
    80001520:	00f57933          	and	s2,a0,a5

  acquire(&refcount_lock);
    80001524:	00012517          	auipc	a0,0x12
    80001528:	63c50513          	addi	a0,a0,1596 # 80013b60 <refcount_lock>
    8000152c:	fffff097          	auipc	ra,0xfffff
    80001530:	7de080e7          	jalr	2014(ra) # 80000d0a <acquire>
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    80001534:	00012797          	auipc	a5,0x12
    80001538:	64478793          	addi	a5,a5,1604 # 80013b78 <refcount_table>
    8000153c:	4481                	li	s1,0
    8000153e:	66a1                	lui	a3,0x8
    if (refcount_table.refcount_entry[i].pa == pa) {
    80001540:	6398                	ld	a4,0(a5)
    80001542:	03270663          	beq	a4,s2,8000156e <decrement_ref_count+0x5c>
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    80001546:	2485                	addiw	s1,s1,1
    80001548:	07c1                	addi	a5,a5,16
    8000154a:	fed49be3          	bne	s1,a3,80001540 <decrement_ref_count+0x2e>
      }
      release(&refcount_lock);
      return;
    }
  }
  release(&refcount_lock);
    8000154e:	00012517          	auipc	a0,0x12
    80001552:	61250513          	addi	a0,a0,1554 # 80013b60 <refcount_lock>
    80001556:	00000097          	auipc	ra,0x0
    8000155a:	868080e7          	jalr	-1944(ra) # 80000dbe <release>

  panic("decrement_ref_count: physical address not found");
    8000155e:	00007517          	auipc	a0,0x7
    80001562:	c9250513          	addi	a0,a0,-878 # 800081f0 <__func__.1+0x1e8>
    80001566:	fffff097          	auipc	ra,0xfffff
    8000156a:	ffa080e7          	jalr	-6(ra) # 80000560 <panic>
      refcount_table.refcount_entry[i].ref_count--;
    8000156e:	00449713          	slli	a4,s1,0x4
    80001572:	00012797          	auipc	a5,0x12
    80001576:	60678793          	addi	a5,a5,1542 # 80013b78 <refcount_table>
    8000157a:	97ba                	add	a5,a5,a4
    8000157c:	4798                	lw	a4,8(a5)
    8000157e:	377d                	addiw	a4,a4,-1 # ffffffffffffefff <end+0xffffffff7ff5a25f>
    80001580:	0007069b          	sext.w	a3,a4
    80001584:	c798                	sw	a4,8(a5)
      if (refcount_table.refcount_entry[i].ref_count == 0) {
    80001586:	ce99                	beqz	a3,800015a4 <decrement_ref_count+0x92>
      release(&refcount_lock);
    80001588:	00012517          	auipc	a0,0x12
    8000158c:	5d850513          	addi	a0,a0,1496 # 80013b60 <refcount_lock>
    80001590:	00000097          	auipc	ra,0x0
    80001594:	82e080e7          	jalr	-2002(ra) # 80000dbe <release>
}
    80001598:	60e2                	ld	ra,24(sp)
    8000159a:	6442                	ld	s0,16(sp)
    8000159c:	64a2                	ld	s1,8(sp)
    8000159e:	6902                	ld	s2,0(sp)
    800015a0:	6105                	addi	sp,sp,32
    800015a2:	8082                	ret
        kfree((void*)pa);  // Deallocate the physical address
    800015a4:	854a                	mv	a0,s2
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	4b6080e7          	jalr	1206(ra) # 80000a5c <kfree>
        refcount_table.refcount_entry[i].pa = 0;
    800015ae:	0492                	slli	s1,s1,0x4
    800015b0:	00012797          	auipc	a5,0x12
    800015b4:	5c878793          	addi	a5,a5,1480 # 80013b78 <refcount_table>
    800015b8:	97a6                	add	a5,a5,s1
    800015ba:	0007b023          	sd	zero,0(a5)
    800015be:	b7e9                	j	80001588 <decrement_ref_count+0x76>

00000000800015c0 <uvmfind>:

uint64
uvmfind(pagetable_t pagetable, uint64 pa)
{
    800015c0:	7139                	addi	sp,sp,-64
    800015c2:	fc06                	sd	ra,56(sp)
    800015c4:	f822                	sd	s0,48(sp)
    800015c6:	f426                	sd	s1,40(sp)
    800015c8:	f04a                	sd	s2,32(sp)
    800015ca:	ec4e                	sd	s3,24(sp)
    800015cc:	e852                	sd	s4,16(sp)
    800015ce:	e456                	sd	s5,8(sp)
    800015d0:	0080                	addi	s0,sp,64
    800015d2:	892a                	mv	s2,a0
    800015d4:	8aae                	mv	s5,a1
  pte_t *pte;
  uint64 va;

  // Iterate over the entire virtual address space.
  // MAXVA is assumed to be the maximum valid virtual address.
  for(va = 0; va < MAXVA; va += PGSIZE){
    800015d6:	4481                	li	s1,0
    800015d8:	6a05                	lui	s4,0x1
    800015da:	4985                	li	s3,1
    800015dc:	199a                	slli	s3,s3,0x26
    800015de:	a021                	j	800015e6 <uvmfind+0x26>
    800015e0:	94d2                	add	s1,s1,s4
    800015e2:	03348c63          	beq	s1,s3,8000161a <uvmfind+0x5a>
    pte = walk(pagetable, va, 0);
    800015e6:	4601                	li	a2,0
    800015e8:	85a6                	mv	a1,s1
    800015ea:	854a                	mv	a0,s2
    800015ec:	00000097          	auipc	ra,0x0
    800015f0:	afe080e7          	jalr	-1282(ra) # 800010ea <walk>
    if(pte == 0)
    800015f4:	d575                	beqz	a0,800015e0 <uvmfind+0x20>
      continue;             // No page table entry for this va.
    if((*pte & PTE_V) == 0)
    800015f6:	611c                	ld	a5,0(a0)
    800015f8:	0017f713          	andi	a4,a5,1
    800015fc:	d375                	beqz	a4,800015e0 <uvmfind+0x20>
      continue;             // Entry is not valid.
    if(PTE2PA(*pte) == pa)
    800015fe:	83a9                	srli	a5,a5,0xa
    80001600:	07b2                	slli	a5,a5,0xc
    80001602:	fd579fe3          	bne	a5,s5,800015e0 <uvmfind+0x20>
      return va;            // Found the mapping; return the virtual address.
  }
  return 0;                 // No mapping found.
}
    80001606:	8526                	mv	a0,s1
    80001608:	70e2                	ld	ra,56(sp)
    8000160a:	7442                	ld	s0,48(sp)
    8000160c:	74a2                	ld	s1,40(sp)
    8000160e:	7902                	ld	s2,32(sp)
    80001610:	69e2                	ld	s3,24(sp)
    80001612:	6a42                	ld	s4,16(sp)
    80001614:	6aa2                	ld	s5,8(sp)
    80001616:	6121                	addi	sp,sp,64
    80001618:	8082                	ret
  return 0;                 // No mapping found.
    8000161a:	4481                	li	s1,0
    8000161c:	b7ed                	j	80001606 <uvmfind+0x46>

000000008000161e <find_ref_count>:

int
find_ref_count(uint64 pa){
  pa = PGROUNDDOWN(pa);
    8000161e:	77fd                	lui	a5,0xfffff
    80001620:	8d7d                	and	a0,a0,a5

  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    80001622:	00012717          	auipc	a4,0x12
    80001626:	55670713          	addi	a4,a4,1366 # 80013b78 <refcount_table>
    8000162a:	4781                	li	a5,0
    8000162c:	6621                	lui	a2,0x8
    if (refcount_table.refcount_entry[i].pa == pa) {
    8000162e:	6314                	ld	a3,0(a4)
    80001630:	02a68263          	beq	a3,a0,80001654 <find_ref_count+0x36>
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    80001634:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ff5a261>
    80001636:	0741                	addi	a4,a4,16
    80001638:	fec79be3          	bne	a5,a2,8000162e <find_ref_count+0x10>
find_ref_count(uint64 pa){
    8000163c:	1141                	addi	sp,sp,-16
    8000163e:	e406                	sd	ra,8(sp)
    80001640:	e022                	sd	s0,0(sp)
    80001642:	0800                	addi	s0,sp,16
      return refcount_table.refcount_entry[i].ref_count;
    }
      
  }
  panic("cow_fault: physical page not found in refcount table");
    80001644:	00007517          	auipc	a0,0x7
    80001648:	bdc50513          	addi	a0,a0,-1060 # 80008220 <__func__.1+0x218>
    8000164c:	fffff097          	auipc	ra,0xfffff
    80001650:	f14080e7          	jalr	-236(ra) # 80000560 <panic>
      return refcount_table.refcount_entry[i].ref_count;
    80001654:	0792                	slli	a5,a5,0x4
    80001656:	00012717          	auipc	a4,0x12
    8000165a:	52270713          	addi	a4,a4,1314 # 80013b78 <refcount_table>
    8000165e:	97ba                	add	a5,a5,a4
    80001660:	4788                	lw	a0,8(a5)
}
    80001662:	8082                	ret

0000000080001664 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages)
{
    80001664:	7139                	addi	sp,sp,-64
    80001666:	fc06                	sd	ra,56(sp)
    80001668:	f822                	sd	s0,48(sp)
    8000166a:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000166c:	03459793          	slli	a5,a1,0x34
    80001670:	e7b5                	bnez	a5,800016dc <uvmunmap+0x78>
    80001672:	f04a                	sd	s2,32(sp)
    80001674:	ec4e                	sd	s3,24(sp)
    80001676:	e852                	sd	s4,16(sp)
    80001678:	e456                	sd	s5,8(sp)
    8000167a:	e05a                	sd	s6,0(sp)
    8000167c:	8a2a                	mv	s4,a0
    8000167e:	892e                	mv	s2,a1
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001680:	00c61993          	slli	s3,a2,0xc
    80001684:	99ae                	add	s3,s3,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001686:	4b05                	li	s6,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001688:	6a85                	lui	s5,0x1
    8000168a:	0535f063          	bgeu	a1,s3,800016ca <uvmunmap+0x66>
    8000168e:	f426                	sd	s1,40(sp)
    if((pte = walk(pagetable, a, 0)) == 0)
    80001690:	4601                	li	a2,0
    80001692:	85ca                	mv	a1,s2
    80001694:	8552                	mv	a0,s4
    80001696:	00000097          	auipc	ra,0x0
    8000169a:	a54080e7          	jalr	-1452(ra) # 800010ea <walk>
    8000169e:	84aa                	mv	s1,a0
    800016a0:	cd21                	beqz	a0,800016f8 <uvmunmap+0x94>
    if((*pte & PTE_V) == 0)
    800016a2:	6108                	ld	a0,0(a0)
    800016a4:	00157793          	andi	a5,a0,1
    800016a8:	c3a5                	beqz	a5,80001708 <uvmunmap+0xa4>
    if(PTE_FLAGS(*pte) == PTE_V)
    800016aa:	3ff57793          	andi	a5,a0,1023
    800016ae:	07678563          	beq	a5,s6,80001718 <uvmunmap+0xb4>
      panic("uvmunmap: not a leaf");
    uint64 pa = PTE2PA(*pte);
    800016b2:	8129                	srli	a0,a0,0xa

    decrement_ref_count(pa);
    800016b4:	0532                	slli	a0,a0,0xc
    800016b6:	00000097          	auipc	ra,0x0
    800016ba:	e5c080e7          	jalr	-420(ra) # 80001512 <decrement_ref_count>
    *pte = 0;
    800016be:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800016c2:	9956                	add	s2,s2,s5
    800016c4:	fd3966e3          	bltu	s2,s3,80001690 <uvmunmap+0x2c>
    800016c8:	74a2                	ld	s1,40(sp)
    800016ca:	7902                	ld	s2,32(sp)
    800016cc:	69e2                	ld	s3,24(sp)
    800016ce:	6a42                	ld	s4,16(sp)
    800016d0:	6aa2                	ld	s5,8(sp)
    800016d2:	6b02                	ld	s6,0(sp)
  }
}
    800016d4:	70e2                	ld	ra,56(sp)
    800016d6:	7442                	ld	s0,48(sp)
    800016d8:	6121                	addi	sp,sp,64
    800016da:	8082                	ret
    800016dc:	f426                	sd	s1,40(sp)
    800016de:	f04a                	sd	s2,32(sp)
    800016e0:	ec4e                	sd	s3,24(sp)
    800016e2:	e852                	sd	s4,16(sp)
    800016e4:	e456                	sd	s5,8(sp)
    800016e6:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800016e8:	00007517          	auipc	a0,0x7
    800016ec:	b7050513          	addi	a0,a0,-1168 # 80008258 <__func__.1+0x250>
    800016f0:	fffff097          	auipc	ra,0xfffff
    800016f4:	e70080e7          	jalr	-400(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    800016f8:	00007517          	auipc	a0,0x7
    800016fc:	b7850513          	addi	a0,a0,-1160 # 80008270 <__func__.1+0x268>
    80001700:	fffff097          	auipc	ra,0xfffff
    80001704:	e60080e7          	jalr	-416(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    80001708:	00007517          	auipc	a0,0x7
    8000170c:	b7850513          	addi	a0,a0,-1160 # 80008280 <__func__.1+0x278>
    80001710:	fffff097          	auipc	ra,0xfffff
    80001714:	e50080e7          	jalr	-432(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    80001718:	00007517          	auipc	a0,0x7
    8000171c:	b8050513          	addi	a0,a0,-1152 # 80008298 <__func__.1+0x290>
    80001720:	fffff097          	auipc	ra,0xfffff
    80001724:	e40080e7          	jalr	-448(ra) # 80000560 <panic>

0000000080001728 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001728:	1101                	addi	sp,sp,-32
    8000172a:	ec06                	sd	ra,24(sp)
    8000172c:	e822                	sd	s0,16(sp)
    8000172e:	e426                	sd	s1,8(sp)
    80001730:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	492080e7          	jalr	1170(ra) # 80000bc4 <kalloc>
    8000173a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000173c:	c519                	beqz	a0,8000174a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000173e:	6605                	lui	a2,0x1
    80001740:	4581                	li	a1,0
    80001742:	fffff097          	auipc	ra,0xfffff
    80001746:	6c4080e7          	jalr	1732(ra) # 80000e06 <memset>
  return pagetable;
}
    8000174a:	8526                	mv	a0,s1
    8000174c:	60e2                	ld	ra,24(sp)
    8000174e:	6442                	ld	s0,16(sp)
    80001750:	64a2                	ld	s1,8(sp)
    80001752:	6105                	addi	sp,sp,32
    80001754:	8082                	ret

0000000080001756 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001756:	7179                	addi	sp,sp,-48
    80001758:	f406                	sd	ra,40(sp)
    8000175a:	f022                	sd	s0,32(sp)
    8000175c:	ec26                	sd	s1,24(sp)
    8000175e:	e84a                	sd	s2,16(sp)
    80001760:	e44e                	sd	s3,8(sp)
    80001762:	e052                	sd	s4,0(sp)
    80001764:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001766:	6785                	lui	a5,0x1
    80001768:	04f67863          	bgeu	a2,a5,800017b8 <uvmfirst+0x62>
    8000176c:	8a2a                	mv	s4,a0
    8000176e:	89ae                	mv	s3,a1
    80001770:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001772:	fffff097          	auipc	ra,0xfffff
    80001776:	452080e7          	jalr	1106(ra) # 80000bc4 <kalloc>
    8000177a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000177c:	6605                	lui	a2,0x1
    8000177e:	4581                	li	a1,0
    80001780:	fffff097          	auipc	ra,0xfffff
    80001784:	686080e7          	jalr	1670(ra) # 80000e06 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001788:	4779                	li	a4,30
    8000178a:	86ca                	mv	a3,s2
    8000178c:	6605                	lui	a2,0x1
    8000178e:	4581                	li	a1,0
    80001790:	8552                	mv	a0,s4
    80001792:	00000097          	auipc	ra,0x0
    80001796:	ba4080e7          	jalr	-1116(ra) # 80001336 <mappages>
  memmove(mem, src, sz);
    8000179a:	8626                	mv	a2,s1
    8000179c:	85ce                	mv	a1,s3
    8000179e:	854a                	mv	a0,s2
    800017a0:	fffff097          	auipc	ra,0xfffff
    800017a4:	6c2080e7          	jalr	1730(ra) # 80000e62 <memmove>
}
    800017a8:	70a2                	ld	ra,40(sp)
    800017aa:	7402                	ld	s0,32(sp)
    800017ac:	64e2                	ld	s1,24(sp)
    800017ae:	6942                	ld	s2,16(sp)
    800017b0:	69a2                	ld	s3,8(sp)
    800017b2:	6a02                	ld	s4,0(sp)
    800017b4:	6145                	addi	sp,sp,48
    800017b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800017b8:	00007517          	auipc	a0,0x7
    800017bc:	af850513          	addi	a0,a0,-1288 # 800082b0 <__func__.1+0x2a8>
    800017c0:	fffff097          	auipc	ra,0xfffff
    800017c4:	da0080e7          	jalr	-608(ra) # 80000560 <panic>

00000000800017c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800017c8:	1101                	addi	sp,sp,-32
    800017ca:	ec06                	sd	ra,24(sp)
    800017cc:	e822                	sd	s0,16(sp)
    800017ce:	e426                	sd	s1,8(sp)
    800017d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800017d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800017d4:	00b67d63          	bgeu	a2,a1,800017ee <uvmdealloc+0x26>
    800017d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800017da:	6785                	lui	a5,0x1
    800017dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800017de:	00f60733          	add	a4,a2,a5
    800017e2:	76fd                	lui	a3,0xfffff
    800017e4:	8f75                	and	a4,a4,a3
    800017e6:	97ae                	add	a5,a5,a1
    800017e8:	8ff5                	and	a5,a5,a3
    800017ea:	00f76863          	bltu	a4,a5,800017fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages);
  }

  return newsz;
}
    800017ee:	8526                	mv	a0,s1
    800017f0:	60e2                	ld	ra,24(sp)
    800017f2:	6442                	ld	s0,16(sp)
    800017f4:	64a2                	ld	s1,8(sp)
    800017f6:	6105                	addi	sp,sp,32
    800017f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800017fa:	8f99                	sub	a5,a5,a4
    800017fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages);
    800017fe:	0007861b          	sext.w	a2,a5
    80001802:	85ba                	mv	a1,a4
    80001804:	00000097          	auipc	ra,0x0
    80001808:	e60080e7          	jalr	-416(ra) # 80001664 <uvmunmap>
    8000180c:	b7cd                	j	800017ee <uvmdealloc+0x26>

000000008000180e <uvmalloc>:
  if(newsz < oldsz)
    8000180e:	0ab66b63          	bltu	a2,a1,800018c4 <uvmalloc+0xb6>
{
    80001812:	7139                	addi	sp,sp,-64
    80001814:	fc06                	sd	ra,56(sp)
    80001816:	f822                	sd	s0,48(sp)
    80001818:	ec4e                	sd	s3,24(sp)
    8000181a:	e852                	sd	s4,16(sp)
    8000181c:	e456                	sd	s5,8(sp)
    8000181e:	0080                	addi	s0,sp,64
    80001820:	8aaa                	mv	s5,a0
    80001822:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001824:	6785                	lui	a5,0x1
    80001826:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001828:	95be                	add	a1,a1,a5
    8000182a:	77fd                	lui	a5,0xfffff
    8000182c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001830:	08c9fc63          	bgeu	s3,a2,800018c8 <uvmalloc+0xba>
    80001834:	f426                	sd	s1,40(sp)
    80001836:	f04a                	sd	s2,32(sp)
    80001838:	e05a                	sd	s6,0(sp)
    8000183a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000183c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001840:	fffff097          	auipc	ra,0xfffff
    80001844:	384080e7          	jalr	900(ra) # 80000bc4 <kalloc>
    80001848:	84aa                	mv	s1,a0
    if(mem == 0){
    8000184a:	c915                	beqz	a0,8000187e <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    8000184c:	6605                	lui	a2,0x1
    8000184e:	4581                	li	a1,0
    80001850:	fffff097          	auipc	ra,0xfffff
    80001854:	5b6080e7          	jalr	1462(ra) # 80000e06 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001858:	875a                	mv	a4,s6
    8000185a:	86a6                	mv	a3,s1
    8000185c:	6605                	lui	a2,0x1
    8000185e:	85ca                	mv	a1,s2
    80001860:	8556                	mv	a0,s5
    80001862:	00000097          	auipc	ra,0x0
    80001866:	ad4080e7          	jalr	-1324(ra) # 80001336 <mappages>
    8000186a:	ed05                	bnez	a0,800018a2 <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000186c:	6785                	lui	a5,0x1
    8000186e:	993e                	add	s2,s2,a5
    80001870:	fd4968e3          	bltu	s2,s4,80001840 <uvmalloc+0x32>
  return newsz;
    80001874:	8552                	mv	a0,s4
    80001876:	74a2                	ld	s1,40(sp)
    80001878:	7902                	ld	s2,32(sp)
    8000187a:	6b02                	ld	s6,0(sp)
    8000187c:	a821                	j	80001894 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    8000187e:	864e                	mv	a2,s3
    80001880:	85ca                	mv	a1,s2
    80001882:	8556                	mv	a0,s5
    80001884:	00000097          	auipc	ra,0x0
    80001888:	f44080e7          	jalr	-188(ra) # 800017c8 <uvmdealloc>
      return 0;
    8000188c:	4501                	li	a0,0
    8000188e:	74a2                	ld	s1,40(sp)
    80001890:	7902                	ld	s2,32(sp)
    80001892:	6b02                	ld	s6,0(sp)
}
    80001894:	70e2                	ld	ra,56(sp)
    80001896:	7442                	ld	s0,48(sp)
    80001898:	69e2                	ld	s3,24(sp)
    8000189a:	6a42                	ld	s4,16(sp)
    8000189c:	6aa2                	ld	s5,8(sp)
    8000189e:	6121                	addi	sp,sp,64
    800018a0:	8082                	ret
      kfree(mem);
    800018a2:	8526                	mv	a0,s1
    800018a4:	fffff097          	auipc	ra,0xfffff
    800018a8:	1b8080e7          	jalr	440(ra) # 80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800018ac:	864e                	mv	a2,s3
    800018ae:	85ca                	mv	a1,s2
    800018b0:	8556                	mv	a0,s5
    800018b2:	00000097          	auipc	ra,0x0
    800018b6:	f16080e7          	jalr	-234(ra) # 800017c8 <uvmdealloc>
      return 0;
    800018ba:	4501                	li	a0,0
    800018bc:	74a2                	ld	s1,40(sp)
    800018be:	7902                	ld	s2,32(sp)
    800018c0:	6b02                	ld	s6,0(sp)
    800018c2:	bfc9                	j	80001894 <uvmalloc+0x86>
    return oldsz;
    800018c4:	852e                	mv	a0,a1
}
    800018c6:	8082                	ret
  return newsz;
    800018c8:	8532                	mv	a0,a2
    800018ca:	b7e9                	j	80001894 <uvmalloc+0x86>

00000000800018cc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800018cc:	7179                	addi	sp,sp,-48
    800018ce:	f406                	sd	ra,40(sp)
    800018d0:	f022                	sd	s0,32(sp)
    800018d2:	ec26                	sd	s1,24(sp)
    800018d4:	e84a                	sd	s2,16(sp)
    800018d6:	e44e                	sd	s3,8(sp)
    800018d8:	e052                	sd	s4,0(sp)
    800018da:	1800                	addi	s0,sp,48
    800018dc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800018de:	84aa                	mv	s1,a0
    800018e0:	6905                	lui	s2,0x1
    800018e2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800018e4:	4985                	li	s3,1
    800018e6:	a829                	j	80001900 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800018e8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800018ea:	00c79513          	slli	a0,a5,0xc
    800018ee:	00000097          	auipc	ra,0x0
    800018f2:	fde080e7          	jalr	-34(ra) # 800018cc <freewalk>
      pagetable[i] = 0;
    800018f6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800018fa:	04a1                	addi	s1,s1,8
    800018fc:	03248163          	beq	s1,s2,8000191e <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001900:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001902:	00f7f713          	andi	a4,a5,15
    80001906:	ff3701e3          	beq	a4,s3,800018e8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000190a:	8b85                	andi	a5,a5,1
    8000190c:	d7fd                	beqz	a5,800018fa <freewalk+0x2e>
      panic("freewalk: leaf");
    8000190e:	00007517          	auipc	a0,0x7
    80001912:	9c250513          	addi	a0,a0,-1598 # 800082d0 <__func__.1+0x2c8>
    80001916:	fffff097          	auipc	ra,0xfffff
    8000191a:	c4a080e7          	jalr	-950(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    8000191e:	8552                	mv	a0,s4
    80001920:	fffff097          	auipc	ra,0xfffff
    80001924:	13c080e7          	jalr	316(ra) # 80000a5c <kfree>
}
    80001928:	70a2                	ld	ra,40(sp)
    8000192a:	7402                	ld	s0,32(sp)
    8000192c:	64e2                	ld	s1,24(sp)
    8000192e:	6942                	ld	s2,16(sp)
    80001930:	69a2                	ld	s3,8(sp)
    80001932:	6a02                	ld	s4,0(sp)
    80001934:	6145                	addi	sp,sp,48
    80001936:	8082                	ret

0000000080001938 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001938:	1101                	addi	sp,sp,-32
    8000193a:	ec06                	sd	ra,24(sp)
    8000193c:	e822                	sd	s0,16(sp)
    8000193e:	e426                	sd	s1,8(sp)
    80001940:	1000                	addi	s0,sp,32
    80001942:	84aa                	mv	s1,a0
  if(sz > 0)
    80001944:	e999                	bnez	a1,8000195a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE);
  freewalk(pagetable);
    80001946:	8526                	mv	a0,s1
    80001948:	00000097          	auipc	ra,0x0
    8000194c:	f84080e7          	jalr	-124(ra) # 800018cc <freewalk>
}
    80001950:	60e2                	ld	ra,24(sp)
    80001952:	6442                	ld	s0,16(sp)
    80001954:	64a2                	ld	s1,8(sp)
    80001956:	6105                	addi	sp,sp,32
    80001958:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE);
    8000195a:	6785                	lui	a5,0x1
    8000195c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000195e:	95be                	add	a1,a1,a5
    80001960:	00c5d613          	srli	a2,a1,0xc
    80001964:	4581                	li	a1,0
    80001966:	00000097          	auipc	ra,0x0
    8000196a:	cfe080e7          	jalr	-770(ra) # 80001664 <uvmunmap>
    8000196e:	bfe1                	j	80001946 <uvmfree+0xe>

0000000080001970 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001970:	c671                	beqz	a2,80001a3c <uvmcopy+0xcc>
{
    80001972:	715d                	addi	sp,sp,-80
    80001974:	e486                	sd	ra,72(sp)
    80001976:	e0a2                	sd	s0,64(sp)
    80001978:	fc26                	sd	s1,56(sp)
    8000197a:	f84a                	sd	s2,48(sp)
    8000197c:	f44e                	sd	s3,40(sp)
    8000197e:	f052                	sd	s4,32(sp)
    80001980:	ec56                	sd	s5,24(sp)
    80001982:	e85a                	sd	s6,16(sp)
    80001984:	e45e                	sd	s7,8(sp)
    80001986:	0880                	addi	s0,sp,80
    80001988:	8b2a                	mv	s6,a0
    8000198a:	8aae                	mv	s5,a1
    8000198c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000198e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001990:	4601                	li	a2,0
    80001992:	85ce                	mv	a1,s3
    80001994:	855a                	mv	a0,s6
    80001996:	fffff097          	auipc	ra,0xfffff
    8000199a:	754080e7          	jalr	1876(ra) # 800010ea <walk>
    8000199e:	c531                	beqz	a0,800019ea <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800019a0:	6118                	ld	a4,0(a0)
    800019a2:	00177793          	andi	a5,a4,1
    800019a6:	cbb1                	beqz	a5,800019fa <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800019a8:	00a75593          	srli	a1,a4,0xa
    800019ac:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800019b0:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800019b4:	fffff097          	auipc	ra,0xfffff
    800019b8:	210080e7          	jalr	528(ra) # 80000bc4 <kalloc>
    800019bc:	892a                	mv	s2,a0
    800019be:	c939                	beqz	a0,80001a14 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800019c0:	6605                	lui	a2,0x1
    800019c2:	85de                	mv	a1,s7
    800019c4:	fffff097          	auipc	ra,0xfffff
    800019c8:	49e080e7          	jalr	1182(ra) # 80000e62 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800019cc:	8726                	mv	a4,s1
    800019ce:	86ca                	mv	a3,s2
    800019d0:	6605                	lui	a2,0x1
    800019d2:	85ce                	mv	a1,s3
    800019d4:	8556                	mv	a0,s5
    800019d6:	00000097          	auipc	ra,0x0
    800019da:	960080e7          	jalr	-1696(ra) # 80001336 <mappages>
    800019de:	e515                	bnez	a0,80001a0a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800019e0:	6785                	lui	a5,0x1
    800019e2:	99be                	add	s3,s3,a5
    800019e4:	fb49e6e3          	bltu	s3,s4,80001990 <uvmcopy+0x20>
    800019e8:	a83d                	j	80001a26 <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    800019ea:	00007517          	auipc	a0,0x7
    800019ee:	8f650513          	addi	a0,a0,-1802 # 800082e0 <__func__.1+0x2d8>
    800019f2:	fffff097          	auipc	ra,0xfffff
    800019f6:	b6e080e7          	jalr	-1170(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    800019fa:	00007517          	auipc	a0,0x7
    800019fe:	90650513          	addi	a0,a0,-1786 # 80008300 <__func__.1+0x2f8>
    80001a02:	fffff097          	auipc	ra,0xfffff
    80001a06:	b5e080e7          	jalr	-1186(ra) # 80000560 <panic>
      kfree(mem);
    80001a0a:	854a                	mv	a0,s2
    80001a0c:	fffff097          	auipc	ra,0xfffff
    80001a10:	050080e7          	jalr	80(ra) # 80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE);
    80001a14:	00c9d613          	srli	a2,s3,0xc
    80001a18:	4581                	li	a1,0
    80001a1a:	8556                	mv	a0,s5
    80001a1c:	00000097          	auipc	ra,0x0
    80001a20:	c48080e7          	jalr	-952(ra) # 80001664 <uvmunmap>
  return -1;
    80001a24:	557d                	li	a0,-1
}
    80001a26:	60a6                	ld	ra,72(sp)
    80001a28:	6406                	ld	s0,64(sp)
    80001a2a:	74e2                	ld	s1,56(sp)
    80001a2c:	7942                	ld	s2,48(sp)
    80001a2e:	79a2                	ld	s3,40(sp)
    80001a30:	7a02                	ld	s4,32(sp)
    80001a32:	6ae2                	ld	s5,24(sp)
    80001a34:	6b42                	ld	s6,16(sp)
    80001a36:	6ba2                	ld	s7,8(sp)
    80001a38:	6161                	addi	sp,sp,80
    80001a3a:	8082                	ret
  return 0;
    80001a3c:	4501                	li	a0,0
}
    80001a3e:	8082                	ret

0000000080001a40 <uvmremap>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001a40:	ca55                	beqz	a2,80001af4 <uvmremap+0xb4>
{
    80001a42:	7179                	addi	sp,sp,-48
    80001a44:	f406                	sd	ra,40(sp)
    80001a46:	f022                	sd	s0,32(sp)
    80001a48:	ec26                	sd	s1,24(sp)
    80001a4a:	e84a                	sd	s2,16(sp)
    80001a4c:	e44e                	sd	s3,8(sp)
    80001a4e:	e052                	sd	s4,0(sp)
    80001a50:	1800                	addi	s0,sp,48
    80001a52:	89aa                	mv	s3,a0
    80001a54:	8a2e                	mv	s4,a1
    80001a56:	8932                	mv	s2,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001a58:	4481                	li	s1,0
    80001a5a:	a091                	j	80001a9e <uvmremap+0x5e>
    if((pte = walk(parent, i, 0)) == 0)
      panic("uvmremap: pte should exist");
    80001a5c:	00007517          	auipc	a0,0x7
    80001a60:	8c450513          	addi	a0,a0,-1852 # 80008320 <__func__.1+0x318>
    80001a64:	fffff097          	auipc	ra,0xfffff
    80001a68:	afc080e7          	jalr	-1284(ra) # 80000560 <panic>
    if((*pte & PTE_V) == 0)
      panic("uvmremap: page not present");
    80001a6c:	00007517          	auipc	a0,0x7
    80001a70:	8d450513          	addi	a0,a0,-1836 # 80008340 <__func__.1+0x338>
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	aec080e7          	jalr	-1300(ra) # 80000560 <panic>
    if (flags & PTE_W) {
      flags = flags | PTE_COW; // Use a reserved bit for COW entries
      *pte = *pte  | PTE_COW;
    }
    flags = flags & ~PTE_W;
    *pte = *pte & ~PTE_W;        // Updates the parents page table entry
    80001a7c:	611c                	ld	a5,0(a0)
    80001a7e:	9bed                	andi	a5,a5,-5
    80001a80:	e11c                	sd	a5,0(a0)
    // Mappinig new page table netry to child
    if(mappages(child, i, PGSIZE, pa, flags) != 0){
    80001a82:	3fb77713          	andi	a4,a4,1019
    80001a86:	6605                	lui	a2,0x1
    80001a88:	85a6                	mv	a1,s1
    80001a8a:	8552                	mv	a0,s4
    80001a8c:	00000097          	auipc	ra,0x0
    80001a90:	8aa080e7          	jalr	-1878(ra) # 80001336 <mappages>
    80001a94:	ed1d                	bnez	a0,80001ad2 <uvmremap+0x92>
  for(i = 0; i < sz; i += PGSIZE){
    80001a96:	6785                	lui	a5,0x1
    80001a98:	94be                	add	s1,s1,a5
    80001a9a:	0524f463          	bgeu	s1,s2,80001ae2 <uvmremap+0xa2>
    if((pte = walk(parent, i, 0)) == 0)
    80001a9e:	4601                	li	a2,0
    80001aa0:	85a6                	mv	a1,s1
    80001aa2:	854e                	mv	a0,s3
    80001aa4:	fffff097          	auipc	ra,0xfffff
    80001aa8:	646080e7          	jalr	1606(ra) # 800010ea <walk>
    80001aac:	d945                	beqz	a0,80001a5c <uvmremap+0x1c>
    if((*pte & PTE_V) == 0)
    80001aae:	611c                	ld	a5,0(a0)
    80001ab0:	0017f713          	andi	a4,a5,1
    80001ab4:	df45                	beqz	a4,80001a6c <uvmremap+0x2c>
    pa = PTE2PA(*pte);
    80001ab6:	00a7d693          	srli	a3,a5,0xa
    80001aba:	06b2                	slli	a3,a3,0xc
    flags = PTE_FLAGS(*pte);
    80001abc:	3ff7f713          	andi	a4,a5,1023
    if (flags & PTE_W) {
    80001ac0:	0047f613          	andi	a2,a5,4
    80001ac4:	de45                	beqz	a2,80001a7c <uvmremap+0x3c>
      flags = flags | PTE_COW; // Use a reserved bit for COW entries
    80001ac6:	20076713          	ori	a4,a4,512
      *pte = *pte  | PTE_COW;
    80001aca:	2007e793          	ori	a5,a5,512
    80001ace:	e11c                	sd	a5,0(a0)
    80001ad0:	b775                	j	80001a7c <uvmremap+0x3c>
      panic("uvmremap: couldnt map pte to child");
    80001ad2:	00007517          	auipc	a0,0x7
    80001ad6:	88e50513          	addi	a0,a0,-1906 # 80008360 <__func__.1+0x358>
    80001ada:	fffff097          	auipc	ra,0xfffff
    80001ade:	a86080e7          	jalr	-1402(ra) # 80000560 <panic>
    }
  }
  return 0;
}
    80001ae2:	4501                	li	a0,0
    80001ae4:	70a2                	ld	ra,40(sp)
    80001ae6:	7402                	ld	s0,32(sp)
    80001ae8:	64e2                	ld	s1,24(sp)
    80001aea:	6942                	ld	s2,16(sp)
    80001aec:	69a2                	ld	s3,8(sp)
    80001aee:	6a02                	ld	s4,0(sp)
    80001af0:	6145                	addi	sp,sp,48
    80001af2:	8082                	ret
    80001af4:	4501                	li	a0,0
    80001af6:	8082                	ret

0000000080001af8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001af8:	1141                	addi	sp,sp,-16
    80001afa:	e406                	sd	ra,8(sp)
    80001afc:	e022                	sd	s0,0(sp)
    80001afe:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001b00:	4601                	li	a2,0
    80001b02:	fffff097          	auipc	ra,0xfffff
    80001b06:	5e8080e7          	jalr	1512(ra) # 800010ea <walk>
  if(pte == 0)
    80001b0a:	c901                	beqz	a0,80001b1a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001b0c:	611c                	ld	a5,0(a0)
    80001b0e:	9bbd                	andi	a5,a5,-17
    80001b10:	e11c                	sd	a5,0(a0)
}
    80001b12:	60a2                	ld	ra,8(sp)
    80001b14:	6402                	ld	s0,0(sp)
    80001b16:	0141                	addi	sp,sp,16
    80001b18:	8082                	ret
    panic("uvmclear");
    80001b1a:	00007517          	auipc	a0,0x7
    80001b1e:	86e50513          	addi	a0,a0,-1938 # 80008388 <__func__.1+0x380>
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	a3e080e7          	jalr	-1474(ra) # 80000560 <panic>

0000000080001b2a <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001b2a:	cee9                	beqz	a3,80001c04 <copyout+0xda>
{
    80001b2c:	711d                	addi	sp,sp,-96
    80001b2e:	ec86                	sd	ra,88(sp)
    80001b30:	e8a2                	sd	s0,80(sp)
    80001b32:	e4a6                	sd	s1,72(sp)
    80001b34:	e0ca                	sd	s2,64(sp)
    80001b36:	fc4e                	sd	s3,56(sp)
    80001b38:	f852                	sd	s4,48(sp)
    80001b3a:	f456                	sd	s5,40(sp)
    80001b3c:	f05a                	sd	s6,32(sp)
    80001b3e:	ec5e                	sd	s7,24(sp)
    80001b40:	e862                	sd	s8,16(sp)
    80001b42:	e466                	sd	s9,8(sp)
    80001b44:	e06a                	sd	s10,0(sp)
    80001b46:	1080                	addi	s0,sp,96
    80001b48:	8baa                	mv	s7,a0
    80001b4a:	84ae                	mv	s1,a1
    80001b4c:	8b32                	mv	s6,a2
    80001b4e:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80001b50:	7c7d                	lui	s8,0xfffff
    // Get the PTE to check for COW
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    80001b52:	4cc5                	li	s9,17
    80001b54:	a82d                	j	80001b8e <copyout+0x64>
      increment_ref_count((uint64)mem);
      decrement_ref_count(pa);
    }

    pa0 = PTE2PA(*pte);
    n = PGSIZE - (dstva - va0);
    80001b56:	409a0933          	sub	s2,s4,s1
    80001b5a:	6785                	lui	a5,0x1
    80001b5c:	993e                	add	s2,s2,a5
    if(n > len) n = len;
    80001b5e:	012af363          	bgeu	s5,s2,80001b64 <copyout+0x3a>
    80001b62:	8956                	mv	s2,s5
    pa0 = PTE2PA(*pte);
    80001b64:	0009b783          	ld	a5,0(s3) # 1000 <_entry-0x7ffff000>
    80001b68:	83a9                	srli	a5,a5,0xa
    80001b6a:	07b2                	slli	a5,a5,0xc
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001b6c:	41448533          	sub	a0,s1,s4
    80001b70:	0009061b          	sext.w	a2,s2
    80001b74:	85da                	mv	a1,s6
    80001b76:	953e                	add	a0,a0,a5
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	2ea080e7          	jalr	746(ra) # 80000e62 <memmove>

    len -= n;
    80001b80:	412a8ab3          	sub	s5,s5,s2
    src += n;
    80001b84:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    80001b86:	6485                	lui	s1,0x1
    80001b88:	94d2                	add	s1,s1,s4
  while(len > 0){
    80001b8a:	060a8b63          	beqz	s5,80001c00 <copyout+0xd6>
    va0 = PGROUNDDOWN(dstva);
    80001b8e:	0184fa33          	and	s4,s1,s8
    pte = walk(pagetable, va0, 0);
    80001b92:	4601                	li	a2,0
    80001b94:	85d2                	mv	a1,s4
    80001b96:	855e                	mv	a0,s7
    80001b98:	fffff097          	auipc	ra,0xfffff
    80001b9c:	552080e7          	jalr	1362(ra) # 800010ea <walk>
    80001ba0:	89aa                	mv	s3,a0
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    80001ba2:	c13d                	beqz	a0,80001c08 <copyout+0xde>
    80001ba4:	6108                	ld	a0,0(a0)
    80001ba6:	01157793          	andi	a5,a0,17
    80001baa:	07979e63          	bne	a5,s9,80001c26 <copyout+0xfc>
    if(*pte & PTE_COW) {
    80001bae:	20057793          	andi	a5,a0,512
    80001bb2:	d3d5                	beqz	a5,80001b56 <copyout+0x2c>
      uint64 pa = PTE2PA(*pte);
    80001bb4:	8129                	srli	a0,a0,0xa
    80001bb6:	00c51913          	slli	s2,a0,0xc
      char *mem = kalloc();
    80001bba:	fffff097          	auipc	ra,0xfffff
    80001bbe:	00a080e7          	jalr	10(ra) # 80000bc4 <kalloc>
    80001bc2:	8d2a                	mv	s10,a0
      if(mem == 0)
    80001bc4:	c13d                	beqz	a0,80001c2a <copyout+0x100>
      memmove(mem, (char*)pa, PGSIZE);
    80001bc6:	6605                	lui	a2,0x1
    80001bc8:	85ca                	mv	a1,s2
    80001bca:	fffff097          	auipc	ra,0xfffff
    80001bce:	298080e7          	jalr	664(ra) # 80000e62 <memmove>
      uint flags = (PTE_FLAGS(*pte) & ~PTE_COW) | PTE_W;
    80001bd2:	0009b783          	ld	a5,0(s3)
    80001bd6:	1fb7f793          	andi	a5,a5,507
      *pte = PA2PTE(mem) | flags;
    80001bda:	0047e793          	ori	a5,a5,4
    80001bde:	00cd5713          	srli	a4,s10,0xc
    80001be2:	072a                	slli	a4,a4,0xa
    80001be4:	8fd9                	or	a5,a5,a4
      *pte = *pte & ~PTE_COW;
    80001be6:	00f9b023          	sd	a5,0(s3)
      increment_ref_count((uint64)mem);
    80001bea:	856a                	mv	a0,s10
    80001bec:	fffff097          	auipc	ra,0xfffff
    80001bf0:	610080e7          	jalr	1552(ra) # 800011fc <increment_ref_count>
      decrement_ref_count(pa);
    80001bf4:	854a                	mv	a0,s2
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	91c080e7          	jalr	-1764(ra) # 80001512 <decrement_ref_count>
    80001bfe:	bfa1                	j	80001b56 <copyout+0x2c>
  }
  return 0;
    80001c00:	4501                	li	a0,0
    80001c02:	a021                	j	80001c0a <copyout+0xe0>
    80001c04:	4501                	li	a0,0
}
    80001c06:	8082                	ret
      return -1;
    80001c08:	557d                	li	a0,-1
}
    80001c0a:	60e6                	ld	ra,88(sp)
    80001c0c:	6446                	ld	s0,80(sp)
    80001c0e:	64a6                	ld	s1,72(sp)
    80001c10:	6906                	ld	s2,64(sp)
    80001c12:	79e2                	ld	s3,56(sp)
    80001c14:	7a42                	ld	s4,48(sp)
    80001c16:	7aa2                	ld	s5,40(sp)
    80001c18:	7b02                	ld	s6,32(sp)
    80001c1a:	6be2                	ld	s7,24(sp)
    80001c1c:	6c42                	ld	s8,16(sp)
    80001c1e:	6ca2                	ld	s9,8(sp)
    80001c20:	6d02                	ld	s10,0(sp)
    80001c22:	6125                	addi	sp,sp,96
    80001c24:	8082                	ret
      return -1;
    80001c26:	557d                	li	a0,-1
    80001c28:	b7cd                	j	80001c0a <copyout+0xe0>
        return -1;
    80001c2a:	557d                	li	a0,-1
    80001c2c:	bff9                	j	80001c0a <copyout+0xe0>

0000000080001c2e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001c2e:	caa5                	beqz	a3,80001c9e <copyin+0x70>
{
    80001c30:	715d                	addi	sp,sp,-80
    80001c32:	e486                	sd	ra,72(sp)
    80001c34:	e0a2                	sd	s0,64(sp)
    80001c36:	fc26                	sd	s1,56(sp)
    80001c38:	f84a                	sd	s2,48(sp)
    80001c3a:	f44e                	sd	s3,40(sp)
    80001c3c:	f052                	sd	s4,32(sp)
    80001c3e:	ec56                	sd	s5,24(sp)
    80001c40:	e85a                	sd	s6,16(sp)
    80001c42:	e45e                	sd	s7,8(sp)
    80001c44:	e062                	sd	s8,0(sp)
    80001c46:	0880                	addi	s0,sp,80
    80001c48:	8b2a                	mv	s6,a0
    80001c4a:	8a2e                	mv	s4,a1
    80001c4c:	8c32                	mv	s8,a2
    80001c4e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001c50:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001c52:	6a85                	lui	s5,0x1
    80001c54:	a01d                	j	80001c7a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001c56:	018505b3          	add	a1,a0,s8
    80001c5a:	0004861b          	sext.w	a2,s1
    80001c5e:	412585b3          	sub	a1,a1,s2
    80001c62:	8552                	mv	a0,s4
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	1fe080e7          	jalr	510(ra) # 80000e62 <memmove>

    len -= n;
    80001c6c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001c70:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001c72:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001c76:	02098263          	beqz	s3,80001c9a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001c7a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001c7e:	85ca                	mv	a1,s2
    80001c80:	855a                	mv	a0,s6
    80001c82:	fffff097          	auipc	ra,0xfffff
    80001c86:	50e080e7          	jalr	1294(ra) # 80001190 <walkaddr>
    if(pa0 == 0)
    80001c8a:	cd01                	beqz	a0,80001ca2 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001c8c:	418904b3          	sub	s1,s2,s8
    80001c90:	94d6                	add	s1,s1,s5
    if(n > len)
    80001c92:	fc99f2e3          	bgeu	s3,s1,80001c56 <copyin+0x28>
    80001c96:	84ce                	mv	s1,s3
    80001c98:	bf7d                	j	80001c56 <copyin+0x28>
  }
  return 0;
    80001c9a:	4501                	li	a0,0
    80001c9c:	a021                	j	80001ca4 <copyin+0x76>
    80001c9e:	4501                	li	a0,0
}
    80001ca0:	8082                	ret
      return -1;
    80001ca2:	557d                	li	a0,-1
}
    80001ca4:	60a6                	ld	ra,72(sp)
    80001ca6:	6406                	ld	s0,64(sp)
    80001ca8:	74e2                	ld	s1,56(sp)
    80001caa:	7942                	ld	s2,48(sp)
    80001cac:	79a2                	ld	s3,40(sp)
    80001cae:	7a02                	ld	s4,32(sp)
    80001cb0:	6ae2                	ld	s5,24(sp)
    80001cb2:	6b42                	ld	s6,16(sp)
    80001cb4:	6ba2                	ld	s7,8(sp)
    80001cb6:	6c02                	ld	s8,0(sp)
    80001cb8:	6161                	addi	sp,sp,80
    80001cba:	8082                	ret

0000000080001cbc <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001cbc:	cacd                	beqz	a3,80001d6e <copyinstr+0xb2>
{
    80001cbe:	715d                	addi	sp,sp,-80
    80001cc0:	e486                	sd	ra,72(sp)
    80001cc2:	e0a2                	sd	s0,64(sp)
    80001cc4:	fc26                	sd	s1,56(sp)
    80001cc6:	f84a                	sd	s2,48(sp)
    80001cc8:	f44e                	sd	s3,40(sp)
    80001cca:	f052                	sd	s4,32(sp)
    80001ccc:	ec56                	sd	s5,24(sp)
    80001cce:	e85a                	sd	s6,16(sp)
    80001cd0:	e45e                	sd	s7,8(sp)
    80001cd2:	0880                	addi	s0,sp,80
    80001cd4:	8a2a                	mv	s4,a0
    80001cd6:	8b2e                	mv	s6,a1
    80001cd8:	8bb2                	mv	s7,a2
    80001cda:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80001cdc:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001cde:	6985                	lui	s3,0x1
    80001ce0:	a825                	j	80001d18 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001ce2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001ce6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001ce8:	37fd                	addiw	a5,a5,-1
    80001cea:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001cee:	60a6                	ld	ra,72(sp)
    80001cf0:	6406                	ld	s0,64(sp)
    80001cf2:	74e2                	ld	s1,56(sp)
    80001cf4:	7942                	ld	s2,48(sp)
    80001cf6:	79a2                	ld	s3,40(sp)
    80001cf8:	7a02                	ld	s4,32(sp)
    80001cfa:	6ae2                	ld	s5,24(sp)
    80001cfc:	6b42                	ld	s6,16(sp)
    80001cfe:	6ba2                	ld	s7,8(sp)
    80001d00:	6161                	addi	sp,sp,80
    80001d02:	8082                	ret
    80001d04:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001d08:	9742                	add	a4,a4,a6
      --max;
    80001d0a:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001d0e:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001d12:	04e58663          	beq	a1,a4,80001d5e <copyinstr+0xa2>
{
    80001d16:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001d18:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001d1c:	85a6                	mv	a1,s1
    80001d1e:	8552                	mv	a0,s4
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	470080e7          	jalr	1136(ra) # 80001190 <walkaddr>
    if(pa0 == 0)
    80001d28:	cd0d                	beqz	a0,80001d62 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80001d2a:	417486b3          	sub	a3,s1,s7
    80001d2e:	96ce                	add	a3,a3,s3
    if(n > max)
    80001d30:	00d97363          	bgeu	s2,a3,80001d36 <copyinstr+0x7a>
    80001d34:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001d36:	955e                	add	a0,a0,s7
    80001d38:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001d3a:	c695                	beqz	a3,80001d66 <copyinstr+0xaa>
    80001d3c:	87da                	mv	a5,s6
    80001d3e:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001d40:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001d44:	96da                	add	a3,a3,s6
    80001d46:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001d48:	00f60733          	add	a4,a2,a5
    80001d4c:	00074703          	lbu	a4,0(a4)
    80001d50:	db49                	beqz	a4,80001ce2 <copyinstr+0x26>
        *dst = *p;
    80001d52:	00e78023          	sb	a4,0(a5)
      dst++;
    80001d56:	0785                	addi	a5,a5,1
    while(n > 0){
    80001d58:	fed797e3          	bne	a5,a3,80001d46 <copyinstr+0x8a>
    80001d5c:	b765                	j	80001d04 <copyinstr+0x48>
    80001d5e:	4781                	li	a5,0
    80001d60:	b761                	j	80001ce8 <copyinstr+0x2c>
      return -1;
    80001d62:	557d                	li	a0,-1
    80001d64:	b769                	j	80001cee <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001d66:	6b85                	lui	s7,0x1
    80001d68:	9ba6                	add	s7,s7,s1
    80001d6a:	87da                	mv	a5,s6
    80001d6c:	b76d                	j	80001d16 <copyinstr+0x5a>
  int got_null = 0;
    80001d6e:	4781                	li	a5,0
  if(got_null){
    80001d70:	37fd                	addiw	a5,a5,-1
    80001d72:	0007851b          	sext.w	a0,a5
}
    80001d76:	8082                	ret

0000000080001d78 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001d78:	715d                	addi	sp,sp,-80
    80001d7a:	e486                	sd	ra,72(sp)
    80001d7c:	e0a2                	sd	s0,64(sp)
    80001d7e:	fc26                	sd	s1,56(sp)
    80001d80:	f84a                	sd	s2,48(sp)
    80001d82:	f44e                	sd	s3,40(sp)
    80001d84:	f052                	sd	s4,32(sp)
    80001d86:	ec56                	sd	s5,24(sp)
    80001d88:	e85a                	sd	s6,16(sp)
    80001d8a:	e45e                	sd	s7,8(sp)
    80001d8c:	e062                	sd	s8,0(sp)
    80001d8e:	0880                	addi	s0,sp,80
    asm volatile("mv %0, tp" : "=r"(x));
    80001d90:	8792                	mv	a5,tp
    int id = r_tp();
    80001d92:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001d94:	00092a97          	auipc	s5,0x92
    80001d98:	dfca8a93          	addi	s5,s5,-516 # 80093b90 <cpus>
    80001d9c:	00779713          	slli	a4,a5,0x7
    80001da0:	00ea86b3          	add	a3,s5,a4
    80001da4:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ff5a260>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001da8:	0721                	addi	a4,a4,8
    80001daa:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001dac:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001dae:	0000ac17          	auipc	s8,0xa
    80001db2:	a6ac0c13          	addi	s8,s8,-1430 # 8000b818 <sched_pointer>
    80001db6:	00000b97          	auipc	s7,0x0
    80001dba:	fc2b8b93          	addi	s7,s7,-62 # 80001d78 <rr_scheduler>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80001dbe:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dc2:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80001dc6:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001dca:	00092497          	auipc	s1,0x92
    80001dce:	1f648493          	addi	s1,s1,502 # 80093fc0 <proc>
            if (p->state == RUNNABLE)
    80001dd2:	498d                	li	s3,3
                p->state = RUNNING;
    80001dd4:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001dd6:	00098a17          	auipc	s4,0x98
    80001dda:	beaa0a13          	addi	s4,s4,-1046 # 800999c0 <tickslock>
    80001dde:	a81d                	j	80001e14 <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001de0:	8526                	mv	a0,s1
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	fdc080e7          	jalr	-36(ra) # 80000dbe <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001dea:	60a6                	ld	ra,72(sp)
    80001dec:	6406                	ld	s0,64(sp)
    80001dee:	74e2                	ld	s1,56(sp)
    80001df0:	7942                	ld	s2,48(sp)
    80001df2:	79a2                	ld	s3,40(sp)
    80001df4:	7a02                	ld	s4,32(sp)
    80001df6:	6ae2                	ld	s5,24(sp)
    80001df8:	6b42                	ld	s6,16(sp)
    80001dfa:	6ba2                	ld	s7,8(sp)
    80001dfc:	6c02                	ld	s8,0(sp)
    80001dfe:	6161                	addi	sp,sp,80
    80001e00:	8082                	ret
            release(&p->lock);
    80001e02:	8526                	mv	a0,s1
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	fba080e7          	jalr	-70(ra) # 80000dbe <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001e0c:	16848493          	addi	s1,s1,360
    80001e10:	fb4487e3          	beq	s1,s4,80001dbe <rr_scheduler+0x46>
            acquire(&p->lock);
    80001e14:	8526                	mv	a0,s1
    80001e16:	fffff097          	auipc	ra,0xfffff
    80001e1a:	ef4080e7          	jalr	-268(ra) # 80000d0a <acquire>
            if (p->state == RUNNABLE)
    80001e1e:	4c9c                	lw	a5,24(s1)
    80001e20:	ff3791e3          	bne	a5,s3,80001e02 <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001e24:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001e28:	00993023          	sd	s1,0(s2)
                swtch(&c->context, &p->context);
    80001e2c:	06048593          	addi	a1,s1,96
    80001e30:	8556                	mv	a0,s5
    80001e32:	00001097          	auipc	ra,0x1
    80001e36:	08a080e7          	jalr	138(ra) # 80002ebc <swtch>
                if (sched_pointer != &rr_scheduler)
    80001e3a:	000c3783          	ld	a5,0(s8)
    80001e3e:	fb7791e3          	bne	a5,s7,80001de0 <rr_scheduler+0x68>
                c->proc = 0;
    80001e42:	00093023          	sd	zero,0(s2)
    80001e46:	bf75                	j	80001e02 <rr_scheduler+0x8a>

0000000080001e48 <proc_mapstacks>:
{
    80001e48:	7139                	addi	sp,sp,-64
    80001e4a:	fc06                	sd	ra,56(sp)
    80001e4c:	f822                	sd	s0,48(sp)
    80001e4e:	f426                	sd	s1,40(sp)
    80001e50:	f04a                	sd	s2,32(sp)
    80001e52:	ec4e                	sd	s3,24(sp)
    80001e54:	e852                	sd	s4,16(sp)
    80001e56:	e456                	sd	s5,8(sp)
    80001e58:	e05a                	sd	s6,0(sp)
    80001e5a:	0080                	addi	s0,sp,64
    80001e5c:	8a2a                	mv	s4,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001e5e:	00092497          	auipc	s1,0x92
    80001e62:	16248493          	addi	s1,s1,354 # 80093fc0 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001e66:	8b26                	mv	s6,s1
    80001e68:	04fa5937          	lui	s2,0x4fa5
    80001e6c:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001e70:	0932                	slli	s2,s2,0xc
    80001e72:	fa590913          	addi	s2,s2,-91
    80001e76:	0932                	slli	s2,s2,0xc
    80001e78:	fa590913          	addi	s2,s2,-91
    80001e7c:	0932                	slli	s2,s2,0xc
    80001e7e:	fa590913          	addi	s2,s2,-91
    80001e82:	040009b7          	lui	s3,0x4000
    80001e86:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001e88:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001e8a:	00098a97          	auipc	s5,0x98
    80001e8e:	b36a8a93          	addi	s5,s5,-1226 # 800999c0 <tickslock>
        char *pa = kalloc();
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	d32080e7          	jalr	-718(ra) # 80000bc4 <kalloc>
    80001e9a:	862a                	mv	a2,a0
        if (pa == 0)
    80001e9c:	c121                	beqz	a0,80001edc <proc_mapstacks+0x94>
        uint64 va = KSTACK((int)(p - proc));
    80001e9e:	416485b3          	sub	a1,s1,s6
    80001ea2:	858d                	srai	a1,a1,0x3
    80001ea4:	032585b3          	mul	a1,a1,s2
    80001ea8:	2585                	addiw	a1,a1,1
    80001eaa:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001eae:	4719                	li	a4,6
    80001eb0:	6685                	lui	a3,0x1
    80001eb2:	40b985b3          	sub	a1,s3,a1
    80001eb6:	8552                	mv	a0,s4
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	530080e7          	jalr	1328(ra) # 800013e8 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001ec0:	16848493          	addi	s1,s1,360
    80001ec4:	fd5497e3          	bne	s1,s5,80001e92 <proc_mapstacks+0x4a>
}
    80001ec8:	70e2                	ld	ra,56(sp)
    80001eca:	7442                	ld	s0,48(sp)
    80001ecc:	74a2                	ld	s1,40(sp)
    80001ece:	7902                	ld	s2,32(sp)
    80001ed0:	69e2                	ld	s3,24(sp)
    80001ed2:	6a42                	ld	s4,16(sp)
    80001ed4:	6aa2                	ld	s5,8(sp)
    80001ed6:	6b02                	ld	s6,0(sp)
    80001ed8:	6121                	addi	sp,sp,64
    80001eda:	8082                	ret
            panic("kalloc");
    80001edc:	00006517          	auipc	a0,0x6
    80001ee0:	4bc50513          	addi	a0,a0,1212 # 80008398 <__func__.1+0x390>
    80001ee4:	ffffe097          	auipc	ra,0xffffe
    80001ee8:	67c080e7          	jalr	1660(ra) # 80000560 <panic>

0000000080001eec <procinit>:
{
    80001eec:	7139                	addi	sp,sp,-64
    80001eee:	fc06                	sd	ra,56(sp)
    80001ef0:	f822                	sd	s0,48(sp)
    80001ef2:	f426                	sd	s1,40(sp)
    80001ef4:	f04a                	sd	s2,32(sp)
    80001ef6:	ec4e                	sd	s3,24(sp)
    80001ef8:	e852                	sd	s4,16(sp)
    80001efa:	e456                	sd	s5,8(sp)
    80001efc:	e05a                	sd	s6,0(sp)
    80001efe:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001f00:	00006597          	auipc	a1,0x6
    80001f04:	4a058593          	addi	a1,a1,1184 # 800083a0 <__func__.1+0x398>
    80001f08:	00092517          	auipc	a0,0x92
    80001f0c:	08850513          	addi	a0,a0,136 # 80093f90 <pid_lock>
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	d6a080e7          	jalr	-662(ra) # 80000c7a <initlock>
    initlock(&wait_lock, "wait_lock");
    80001f18:	00006597          	auipc	a1,0x6
    80001f1c:	49058593          	addi	a1,a1,1168 # 800083a8 <__func__.1+0x3a0>
    80001f20:	00092517          	auipc	a0,0x92
    80001f24:	08850513          	addi	a0,a0,136 # 80093fa8 <wait_lock>
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	d52080e7          	jalr	-686(ra) # 80000c7a <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f30:	00092497          	auipc	s1,0x92
    80001f34:	09048493          	addi	s1,s1,144 # 80093fc0 <proc>
        initlock(&p->lock, "proc");
    80001f38:	00006b17          	auipc	s6,0x6
    80001f3c:	480b0b13          	addi	s6,s6,1152 # 800083b8 <__func__.1+0x3b0>
        p->kstack = KSTACK((int)(p - proc));
    80001f40:	8aa6                	mv	s5,s1
    80001f42:	04fa5937          	lui	s2,0x4fa5
    80001f46:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001f4a:	0932                	slli	s2,s2,0xc
    80001f4c:	fa590913          	addi	s2,s2,-91
    80001f50:	0932                	slli	s2,s2,0xc
    80001f52:	fa590913          	addi	s2,s2,-91
    80001f56:	0932                	slli	s2,s2,0xc
    80001f58:	fa590913          	addi	s2,s2,-91
    80001f5c:	040009b7          	lui	s3,0x4000
    80001f60:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001f62:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001f64:	00098a17          	auipc	s4,0x98
    80001f68:	a5ca0a13          	addi	s4,s4,-1444 # 800999c0 <tickslock>
        initlock(&p->lock, "proc");
    80001f6c:	85da                	mv	a1,s6
    80001f6e:	8526                	mv	a0,s1
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	d0a080e7          	jalr	-758(ra) # 80000c7a <initlock>
        p->state = UNUSED;
    80001f78:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001f7c:	415487b3          	sub	a5,s1,s5
    80001f80:	878d                	srai	a5,a5,0x3
    80001f82:	032787b3          	mul	a5,a5,s2
    80001f86:	2785                	addiw	a5,a5,1
    80001f88:	00d7979b          	slliw	a5,a5,0xd
    80001f8c:	40f987b3          	sub	a5,s3,a5
    80001f90:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001f92:	16848493          	addi	s1,s1,360
    80001f96:	fd449be3          	bne	s1,s4,80001f6c <procinit+0x80>
}
    80001f9a:	70e2                	ld	ra,56(sp)
    80001f9c:	7442                	ld	s0,48(sp)
    80001f9e:	74a2                	ld	s1,40(sp)
    80001fa0:	7902                	ld	s2,32(sp)
    80001fa2:	69e2                	ld	s3,24(sp)
    80001fa4:	6a42                	ld	s4,16(sp)
    80001fa6:	6aa2                	ld	s5,8(sp)
    80001fa8:	6b02                	ld	s6,0(sp)
    80001faa:	6121                	addi	sp,sp,64
    80001fac:	8082                	ret

0000000080001fae <copy_array>:
{
    80001fae:	1141                	addi	sp,sp,-16
    80001fb0:	e422                	sd	s0,8(sp)
    80001fb2:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001fb4:	00c05c63          	blez	a2,80001fcc <copy_array+0x1e>
    80001fb8:	87aa                	mv	a5,a0
    80001fba:	9532                	add	a0,a0,a2
        dst[i] = src[i];
    80001fbc:	0007c703          	lbu	a4,0(a5)
    80001fc0:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001fc4:	0785                	addi	a5,a5,1
    80001fc6:	0585                	addi	a1,a1,1
    80001fc8:	fea79ae3          	bne	a5,a0,80001fbc <copy_array+0xe>
}
    80001fcc:	6422                	ld	s0,8(sp)
    80001fce:	0141                	addi	sp,sp,16
    80001fd0:	8082                	ret

0000000080001fd2 <va2pa>:
uint64 va2pa(uint64 va, uint64 pid){
    80001fd2:	7139                	addi	sp,sp,-64
    80001fd4:	fc06                	sd	ra,56(sp)
    80001fd6:	f822                	sd	s0,48(sp)
    80001fd8:	f426                	sd	s1,40(sp)
    80001fda:	f04a                	sd	s2,32(sp)
    80001fdc:	ec4e                	sd	s3,24(sp)
    80001fde:	e852                	sd	s4,16(sp)
    80001fe0:	e456                	sd	s5,8(sp)
    80001fe2:	0080                	addi	s0,sp,64
    80001fe4:	8aaa                	mv	s5,a0
    80001fe6:	892e                	mv	s2,a1
    uint64 pa = 0;
    80001fe8:	4a01                	li	s4,0
    for (p = proc; p < &proc[NPROC]; p++){
    80001fea:	00092497          	auipc	s1,0x92
    80001fee:	fd648493          	addi	s1,s1,-42 # 80093fc0 <proc>
    80001ff2:	00098997          	auipc	s3,0x98
    80001ff6:	9ce98993          	addi	s3,s3,-1586 # 800999c0 <tickslock>
    80001ffa:	a811                	j	8000200e <va2pa+0x3c>
        release(&p->lock);
    80001ffc:	8526                	mv	a0,s1
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	dc0080e7          	jalr	-576(ra) # 80000dbe <release>
    for (p = proc; p < &proc[NPROC]; p++){
    80002006:	16848493          	addi	s1,s1,360
    8000200a:	03348263          	beq	s1,s3,8000202e <va2pa+0x5c>
        acquire(&p->lock);
    8000200e:	8526                	mv	a0,s1
    80002010:	fffff097          	auipc	ra,0xfffff
    80002014:	cfa080e7          	jalr	-774(ra) # 80000d0a <acquire>
        if (pid == (uint64) p->pid){
    80002018:	589c                	lw	a5,48(s1)
    8000201a:	ff2791e3          	bne	a5,s2,80001ffc <va2pa+0x2a>
            pa = walkaddr(pt, va);     
    8000201e:	85d6                	mv	a1,s5
    80002020:	68a8                	ld	a0,80(s1)
    80002022:	fffff097          	auipc	ra,0xfffff
    80002026:	16e080e7          	jalr	366(ra) # 80001190 <walkaddr>
    8000202a:	8a2a                	mv	s4,a0
    8000202c:	bfc1                	j	80001ffc <va2pa+0x2a>
}
    8000202e:	8552                	mv	a0,s4
    80002030:	70e2                	ld	ra,56(sp)
    80002032:	7442                	ld	s0,48(sp)
    80002034:	74a2                	ld	s1,40(sp)
    80002036:	7902                	ld	s2,32(sp)
    80002038:	69e2                	ld	s3,24(sp)
    8000203a:	6a42                	ld	s4,16(sp)
    8000203c:	6aa2                	ld	s5,8(sp)
    8000203e:	6121                	addi	sp,sp,64
    80002040:	8082                	ret

0000000080002042 <free_pte>:
void free_pte(pte_t *pte){
    80002042:	7179                	addi	sp,sp,-48
    80002044:	f406                	sd	ra,40(sp)
    80002046:	f022                	sd	s0,32(sp)
    80002048:	ec26                	sd	s1,24(sp)
    8000204a:	e84a                	sd	s2,16(sp)
    8000204c:	e44e                	sd	s3,8(sp)
    8000204e:	e052                	sd	s4,0(sp)
    80002050:	1800                	addi	s0,sp,48
    uint64 pa = PTE2PA(*pte);
    80002052:	00053983          	ld	s3,0(a0)
    80002056:	00a9d993          	srli	s3,s3,0xa
    8000205a:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++){
    8000205c:	00092497          	auipc	s1,0x92
    80002060:	f6448493          	addi	s1,s1,-156 # 80093fc0 <proc>
    80002064:	00098a17          	auipc	s4,0x98
    80002068:	95ca0a13          	addi	s4,s4,-1700 # 800999c0 <tickslock>
    8000206c:	a029                	j	80002076 <free_pte+0x34>
    8000206e:	16848493          	addi	s1,s1,360
    80002072:	03448363          	beq	s1,s4,80002098 <free_pte+0x56>
        pagetable_t pt = p->pagetable;
    80002076:	0504b903          	ld	s2,80(s1)
        uint64 va = uvmfind(pt, pa);
    8000207a:	85ce                	mv	a1,s3
    8000207c:	854a                	mv	a0,s2
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	542080e7          	jalr	1346(ra) # 800015c0 <uvmfind>
        if (va != 0){
    80002086:	d565                	beqz	a0,8000206e <free_pte+0x2c>
            uvmunmap(pt, va, 1);
    80002088:	4605                	li	a2,1
    8000208a:	85aa                	mv	a1,a0
    8000208c:	854a                	mv	a0,s2
    8000208e:	fffff097          	auipc	ra,0xfffff
    80002092:	5d6080e7          	jalr	1494(ra) # 80001664 <uvmunmap>
    80002096:	bfe1                	j	8000206e <free_pte+0x2c>
}
    80002098:	70a2                	ld	ra,40(sp)
    8000209a:	7402                	ld	s0,32(sp)
    8000209c:	64e2                	ld	s1,24(sp)
    8000209e:	6942                	ld	s2,16(sp)
    800020a0:	69a2                	ld	s3,8(sp)
    800020a2:	6a02                	ld	s4,0(sp)
    800020a4:	6145                	addi	sp,sp,48
    800020a6:	8082                	ret

00000000800020a8 <cpuid>:
{
    800020a8:	1141                	addi	sp,sp,-16
    800020aa:	e422                	sd	s0,8(sp)
    800020ac:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    800020ae:	8512                	mv	a0,tp
}
    800020b0:	2501                	sext.w	a0,a0
    800020b2:	6422                	ld	s0,8(sp)
    800020b4:	0141                	addi	sp,sp,16
    800020b6:	8082                	ret

00000000800020b8 <mycpu>:
{
    800020b8:	1141                	addi	sp,sp,-16
    800020ba:	e422                	sd	s0,8(sp)
    800020bc:	0800                	addi	s0,sp,16
    800020be:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    800020c0:	2781                	sext.w	a5,a5
    800020c2:	079e                	slli	a5,a5,0x7
}
    800020c4:	00092517          	auipc	a0,0x92
    800020c8:	acc50513          	addi	a0,a0,-1332 # 80093b90 <cpus>
    800020cc:	953e                	add	a0,a0,a5
    800020ce:	6422                	ld	s0,8(sp)
    800020d0:	0141                	addi	sp,sp,16
    800020d2:	8082                	ret

00000000800020d4 <myproc>:
{
    800020d4:	1101                	addi	sp,sp,-32
    800020d6:	ec06                	sd	ra,24(sp)
    800020d8:	e822                	sd	s0,16(sp)
    800020da:	e426                	sd	s1,8(sp)
    800020dc:	1000                	addi	s0,sp,32
    push_off();
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	be0080e7          	jalr	-1056(ra) # 80000cbe <push_off>
    800020e6:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    800020e8:	2781                	sext.w	a5,a5
    800020ea:	079e                	slli	a5,a5,0x7
    800020ec:	00092717          	auipc	a4,0x92
    800020f0:	aa470713          	addi	a4,a4,-1372 # 80093b90 <cpus>
    800020f4:	97ba                	add	a5,a5,a4
    800020f6:	6384                	ld	s1,0(a5)
    pop_off();
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	c66080e7          	jalr	-922(ra) # 80000d5e <pop_off>
}
    80002100:	8526                	mv	a0,s1
    80002102:	60e2                	ld	ra,24(sp)
    80002104:	6442                	ld	s0,16(sp)
    80002106:	64a2                	ld	s1,8(sp)
    80002108:	6105                	addi	sp,sp,32
    8000210a:	8082                	ret

000000008000210c <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    8000210c:	1141                	addi	sp,sp,-16
    8000210e:	e406                	sd	ra,8(sp)
    80002110:	e022                	sd	s0,0(sp)
    80002112:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80002114:	00000097          	auipc	ra,0x0
    80002118:	fc0080e7          	jalr	-64(ra) # 800020d4 <myproc>
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	ca2080e7          	jalr	-862(ra) # 80000dbe <release>

    if (first)
    80002124:	00009797          	auipc	a5,0x9
    80002128:	6ec7a783          	lw	a5,1772(a5) # 8000b810 <first.1>
    8000212c:	eb89                	bnez	a5,8000213e <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    8000212e:	00001097          	auipc	ra,0x1
    80002132:	f5a080e7          	jalr	-166(ra) # 80003088 <usertrapret>
}
    80002136:	60a2                	ld	ra,8(sp)
    80002138:	6402                	ld	s0,0(sp)
    8000213a:	0141                	addi	sp,sp,16
    8000213c:	8082                	ret
        first = 0;
    8000213e:	00009797          	auipc	a5,0x9
    80002142:	6c07a923          	sw	zero,1746(a5) # 8000b810 <first.1>
        fsinit(ROOTDEV);
    80002146:	4505                	li	a0,1
    80002148:	00002097          	auipc	ra,0x2
    8000214c:	e16080e7          	jalr	-490(ra) # 80003f5e <fsinit>
    80002150:	bff9                	j	8000212e <forkret+0x22>

0000000080002152 <allocpid>:
{
    80002152:	1101                	addi	sp,sp,-32
    80002154:	ec06                	sd	ra,24(sp)
    80002156:	e822                	sd	s0,16(sp)
    80002158:	e426                	sd	s1,8(sp)
    8000215a:	e04a                	sd	s2,0(sp)
    8000215c:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    8000215e:	00092917          	auipc	s2,0x92
    80002162:	e3290913          	addi	s2,s2,-462 # 80093f90 <pid_lock>
    80002166:	854a                	mv	a0,s2
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	ba2080e7          	jalr	-1118(ra) # 80000d0a <acquire>
    pid = nextpid;
    80002170:	00009797          	auipc	a5,0x9
    80002174:	6b078793          	addi	a5,a5,1712 # 8000b820 <nextpid>
    80002178:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    8000217a:	0014871b          	addiw	a4,s1,1
    8000217e:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80002180:	854a                	mv	a0,s2
    80002182:	fffff097          	auipc	ra,0xfffff
    80002186:	c3c080e7          	jalr	-964(ra) # 80000dbe <release>
}
    8000218a:	8526                	mv	a0,s1
    8000218c:	60e2                	ld	ra,24(sp)
    8000218e:	6442                	ld	s0,16(sp)
    80002190:	64a2                	ld	s1,8(sp)
    80002192:	6902                	ld	s2,0(sp)
    80002194:	6105                	addi	sp,sp,32
    80002196:	8082                	ret

0000000080002198 <proc_pagetable>:
{
    80002198:	1101                	addi	sp,sp,-32
    8000219a:	ec06                	sd	ra,24(sp)
    8000219c:	e822                	sd	s0,16(sp)
    8000219e:	e426                	sd	s1,8(sp)
    800021a0:	e04a                	sd	s2,0(sp)
    800021a2:	1000                	addi	s0,sp,32
    800021a4:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	582080e7          	jalr	1410(ra) # 80001728 <uvmcreate>
    800021ae:	84aa                	mv	s1,a0
    if (pagetable == 0)
    800021b0:	c121                	beqz	a0,800021f0 <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    800021b2:	4729                	li	a4,10
    800021b4:	00005697          	auipc	a3,0x5
    800021b8:	e4c68693          	addi	a3,a3,-436 # 80007000 <_trampoline>
    800021bc:	6605                	lui	a2,0x1
    800021be:	040005b7          	lui	a1,0x4000
    800021c2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800021c4:	05b2                	slli	a1,a1,0xc
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	170080e7          	jalr	368(ra) # 80001336 <mappages>
    800021ce:	02054863          	bltz	a0,800021fe <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    800021d2:	4719                	li	a4,6
    800021d4:	05893683          	ld	a3,88(s2)
    800021d8:	6605                	lui	a2,0x1
    800021da:	020005b7          	lui	a1,0x2000
    800021de:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800021e0:	05b6                	slli	a1,a1,0xd
    800021e2:	8526                	mv	a0,s1
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	152080e7          	jalr	338(ra) # 80001336 <mappages>
    800021ec:	02054163          	bltz	a0,8000220e <proc_pagetable+0x76>
}
    800021f0:	8526                	mv	a0,s1
    800021f2:	60e2                	ld	ra,24(sp)
    800021f4:	6442                	ld	s0,16(sp)
    800021f6:	64a2                	ld	s1,8(sp)
    800021f8:	6902                	ld	s2,0(sp)
    800021fa:	6105                	addi	sp,sp,32
    800021fc:	8082                	ret
        uvmfree(pagetable, 0);
    800021fe:	4581                	li	a1,0
    80002200:	8526                	mv	a0,s1
    80002202:	fffff097          	auipc	ra,0xfffff
    80002206:	736080e7          	jalr	1846(ra) # 80001938 <uvmfree>
        return 0;
    8000220a:	4481                	li	s1,0
    8000220c:	b7d5                	j	800021f0 <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1);
    8000220e:	4605                	li	a2,1
    80002210:	040005b7          	lui	a1,0x4000
    80002214:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002216:	05b2                	slli	a1,a1,0xc
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	44a080e7          	jalr	1098(ra) # 80001664 <uvmunmap>
        uvmfree(pagetable, 0);
    80002222:	4581                	li	a1,0
    80002224:	8526                	mv	a0,s1
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	712080e7          	jalr	1810(ra) # 80001938 <uvmfree>
        return 0;
    8000222e:	4481                	li	s1,0
    80002230:	b7c1                	j	800021f0 <proc_pagetable+0x58>

0000000080002232 <proc_freepagetable>:
{
    80002232:	1101                	addi	sp,sp,-32
    80002234:	ec06                	sd	ra,24(sp)
    80002236:	e822                	sd	s0,16(sp)
    80002238:	e426                	sd	s1,8(sp)
    8000223a:	e04a                	sd	s2,0(sp)
    8000223c:	1000                	addi	s0,sp,32
    8000223e:	84aa                	mv	s1,a0
    80002240:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1);
    80002242:	4605                	li	a2,1
    80002244:	040005b7          	lui	a1,0x4000
    80002248:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000224a:	05b2                	slli	a1,a1,0xc
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	418080e7          	jalr	1048(ra) # 80001664 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1);
    80002254:	4605                	li	a2,1
    80002256:	020005b7          	lui	a1,0x2000
    8000225a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    8000225c:	05b6                	slli	a1,a1,0xd
    8000225e:	8526                	mv	a0,s1
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	404080e7          	jalr	1028(ra) # 80001664 <uvmunmap>
    uvmfree(pagetable, sz);
    80002268:	85ca                	mv	a1,s2
    8000226a:	8526                	mv	a0,s1
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	6cc080e7          	jalr	1740(ra) # 80001938 <uvmfree>
}
    80002274:	60e2                	ld	ra,24(sp)
    80002276:	6442                	ld	s0,16(sp)
    80002278:	64a2                	ld	s1,8(sp)
    8000227a:	6902                	ld	s2,0(sp)
    8000227c:	6105                	addi	sp,sp,32
    8000227e:	8082                	ret

0000000080002280 <freeproc>:
{
    80002280:	1101                	addi	sp,sp,-32
    80002282:	ec06                	sd	ra,24(sp)
    80002284:	e822                	sd	s0,16(sp)
    80002286:	e426                	sd	s1,8(sp)
    80002288:	1000                	addi	s0,sp,32
    8000228a:	84aa                	mv	s1,a0
    if (p->trapframe)
    8000228c:	6d28                	ld	a0,88(a0)
    8000228e:	c509                	beqz	a0,80002298 <freeproc+0x18>
        kfree((void *)p->trapframe);
    80002290:	ffffe097          	auipc	ra,0xffffe
    80002294:	7cc080e7          	jalr	1996(ra) # 80000a5c <kfree>
    p->trapframe = 0;
    80002298:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    8000229c:	68a8                	ld	a0,80(s1)
    8000229e:	c511                	beqz	a0,800022aa <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    800022a0:	64ac                	ld	a1,72(s1)
    800022a2:	00000097          	auipc	ra,0x0
    800022a6:	f90080e7          	jalr	-112(ra) # 80002232 <proc_freepagetable>
    p->pagetable = 0;
    800022aa:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    800022ae:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    800022b2:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    800022b6:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    800022ba:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    800022be:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    800022c2:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    800022c6:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    800022ca:	0004ac23          	sw	zero,24(s1)
}
    800022ce:	60e2                	ld	ra,24(sp)
    800022d0:	6442                	ld	s0,16(sp)
    800022d2:	64a2                	ld	s1,8(sp)
    800022d4:	6105                	addi	sp,sp,32
    800022d6:	8082                	ret

00000000800022d8 <allocproc>:
{
    800022d8:	1101                	addi	sp,sp,-32
    800022da:	ec06                	sd	ra,24(sp)
    800022dc:	e822                	sd	s0,16(sp)
    800022de:	e426                	sd	s1,8(sp)
    800022e0:	e04a                	sd	s2,0(sp)
    800022e2:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    800022e4:	00092497          	auipc	s1,0x92
    800022e8:	cdc48493          	addi	s1,s1,-804 # 80093fc0 <proc>
    800022ec:	00097917          	auipc	s2,0x97
    800022f0:	6d490913          	addi	s2,s2,1748 # 800999c0 <tickslock>
        acquire(&p->lock);
    800022f4:	8526                	mv	a0,s1
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	a14080e7          	jalr	-1516(ra) # 80000d0a <acquire>
        if (p->state == UNUSED)
    800022fe:	4c9c                	lw	a5,24(s1)
    80002300:	cf81                	beqz	a5,80002318 <allocproc+0x40>
            release(&p->lock);
    80002302:	8526                	mv	a0,s1
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	aba080e7          	jalr	-1350(ra) # 80000dbe <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000230c:	16848493          	addi	s1,s1,360
    80002310:	ff2492e3          	bne	s1,s2,800022f4 <allocproc+0x1c>
    return 0;
    80002314:	4481                	li	s1,0
    80002316:	a889                	j	80002368 <allocproc+0x90>
    p->pid = allocpid();
    80002318:	00000097          	auipc	ra,0x0
    8000231c:	e3a080e7          	jalr	-454(ra) # 80002152 <allocpid>
    80002320:	d888                	sw	a0,48(s1)
    p->state = USED;
    80002322:	4785                	li	a5,1
    80002324:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	89e080e7          	jalr	-1890(ra) # 80000bc4 <kalloc>
    8000232e:	892a                	mv	s2,a0
    80002330:	eca8                	sd	a0,88(s1)
    80002332:	c131                	beqz	a0,80002376 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80002334:	8526                	mv	a0,s1
    80002336:	00000097          	auipc	ra,0x0
    8000233a:	e62080e7          	jalr	-414(ra) # 80002198 <proc_pagetable>
    8000233e:	892a                	mv	s2,a0
    80002340:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80002342:	c531                	beqz	a0,8000238e <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80002344:	07000613          	li	a2,112
    80002348:	4581                	li	a1,0
    8000234a:	06048513          	addi	a0,s1,96
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	ab8080e7          	jalr	-1352(ra) # 80000e06 <memset>
    p->context.ra = (uint64)forkret;
    80002356:	00000797          	auipc	a5,0x0
    8000235a:	db678793          	addi	a5,a5,-586 # 8000210c <forkret>
    8000235e:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80002360:	60bc                	ld	a5,64(s1)
    80002362:	6705                	lui	a4,0x1
    80002364:	97ba                	add	a5,a5,a4
    80002366:	f4bc                	sd	a5,104(s1)
}
    80002368:	8526                	mv	a0,s1
    8000236a:	60e2                	ld	ra,24(sp)
    8000236c:	6442                	ld	s0,16(sp)
    8000236e:	64a2                	ld	s1,8(sp)
    80002370:	6902                	ld	s2,0(sp)
    80002372:	6105                	addi	sp,sp,32
    80002374:	8082                	ret
        freeproc(p);
    80002376:	8526                	mv	a0,s1
    80002378:	00000097          	auipc	ra,0x0
    8000237c:	f08080e7          	jalr	-248(ra) # 80002280 <freeproc>
        release(&p->lock);
    80002380:	8526                	mv	a0,s1
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	a3c080e7          	jalr	-1476(ra) # 80000dbe <release>
        return 0;
    8000238a:	84ca                	mv	s1,s2
    8000238c:	bff1                	j	80002368 <allocproc+0x90>
        freeproc(p);
    8000238e:	8526                	mv	a0,s1
    80002390:	00000097          	auipc	ra,0x0
    80002394:	ef0080e7          	jalr	-272(ra) # 80002280 <freeproc>
        release(&p->lock);
    80002398:	8526                	mv	a0,s1
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	a24080e7          	jalr	-1500(ra) # 80000dbe <release>
        return 0;
    800023a2:	84ca                	mv	s1,s2
    800023a4:	b7d1                	j	80002368 <allocproc+0x90>

00000000800023a6 <userinit>:
{
    800023a6:	1101                	addi	sp,sp,-32
    800023a8:	ec06                	sd	ra,24(sp)
    800023aa:	e822                	sd	s0,16(sp)
    800023ac:	e426                	sd	s1,8(sp)
    800023ae:	1000                	addi	s0,sp,32
    p = allocproc();
    800023b0:	00000097          	auipc	ra,0x0
    800023b4:	f28080e7          	jalr	-216(ra) # 800022d8 <allocproc>
    800023b8:	84aa                	mv	s1,a0
    initproc = p;
    800023ba:	00009797          	auipc	a5,0x9
    800023be:	52a7b723          	sd	a0,1326(a5) # 8000b8e8 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800023c2:	03400613          	li	a2,52
    800023c6:	00009597          	auipc	a1,0x9
    800023ca:	46a58593          	addi	a1,a1,1130 # 8000b830 <initcode>
    800023ce:	6928                	ld	a0,80(a0)
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	386080e7          	jalr	902(ra) # 80001756 <uvmfirst>
    p->sz = PGSIZE;
    800023d8:	6785                	lui	a5,0x1
    800023da:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    800023dc:	6cb8                	ld	a4,88(s1)
    800023de:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    800023e2:	6cb8                	ld	a4,88(s1)
    800023e4:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    800023e6:	4641                	li	a2,16
    800023e8:	00006597          	auipc	a1,0x6
    800023ec:	fd858593          	addi	a1,a1,-40 # 800083c0 <__func__.1+0x3b8>
    800023f0:	15848513          	addi	a0,s1,344
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	b54080e7          	jalr	-1196(ra) # 80000f48 <safestrcpy>
    p->cwd = namei("/");
    800023fc:	00006517          	auipc	a0,0x6
    80002400:	fd450513          	addi	a0,a0,-44 # 800083d0 <__func__.1+0x3c8>
    80002404:	00002097          	auipc	ra,0x2
    80002408:	5ac080e7          	jalr	1452(ra) # 800049b0 <namei>
    8000240c:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80002410:	478d                	li	a5,3
    80002412:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80002414:	8526                	mv	a0,s1
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	9a8080e7          	jalr	-1624(ra) # 80000dbe <release>
}
    8000241e:	60e2                	ld	ra,24(sp)
    80002420:	6442                	ld	s0,16(sp)
    80002422:	64a2                	ld	s1,8(sp)
    80002424:	6105                	addi	sp,sp,32
    80002426:	8082                	ret

0000000080002428 <growproc>:
{
    80002428:	1101                	addi	sp,sp,-32
    8000242a:	ec06                	sd	ra,24(sp)
    8000242c:	e822                	sd	s0,16(sp)
    8000242e:	e426                	sd	s1,8(sp)
    80002430:	e04a                	sd	s2,0(sp)
    80002432:	1000                	addi	s0,sp,32
    80002434:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80002436:	00000097          	auipc	ra,0x0
    8000243a:	c9e080e7          	jalr	-866(ra) # 800020d4 <myproc>
    8000243e:	84aa                	mv	s1,a0
    sz = p->sz;
    80002440:	652c                	ld	a1,72(a0)
    if (n > 0)
    80002442:	01204c63          	bgtz	s2,8000245a <growproc+0x32>
    else if (n < 0)
    80002446:	02094663          	bltz	s2,80002472 <growproc+0x4a>
    p->sz = sz;
    8000244a:	e4ac                	sd	a1,72(s1)
    return 0;
    8000244c:	4501                	li	a0,0
}
    8000244e:	60e2                	ld	ra,24(sp)
    80002450:	6442                	ld	s0,16(sp)
    80002452:	64a2                	ld	s1,8(sp)
    80002454:	6902                	ld	s2,0(sp)
    80002456:	6105                	addi	sp,sp,32
    80002458:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    8000245a:	4691                	li	a3,4
    8000245c:	00b90633          	add	a2,s2,a1
    80002460:	6928                	ld	a0,80(a0)
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	3ac080e7          	jalr	940(ra) # 8000180e <uvmalloc>
    8000246a:	85aa                	mv	a1,a0
    8000246c:	fd79                	bnez	a0,8000244a <growproc+0x22>
            return -1;
    8000246e:	557d                	li	a0,-1
    80002470:	bff9                	j	8000244e <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002472:	00b90633          	add	a2,s2,a1
    80002476:	6928                	ld	a0,80(a0)
    80002478:	fffff097          	auipc	ra,0xfffff
    8000247c:	350080e7          	jalr	848(ra) # 800017c8 <uvmdealloc>
    80002480:	85aa                	mv	a1,a0
    80002482:	b7e1                	j	8000244a <growproc+0x22>

0000000080002484 <ps>:
{
    80002484:	715d                	addi	sp,sp,-80
    80002486:	e486                	sd	ra,72(sp)
    80002488:	e0a2                	sd	s0,64(sp)
    8000248a:	fc26                	sd	s1,56(sp)
    8000248c:	f84a                	sd	s2,48(sp)
    8000248e:	f44e                	sd	s3,40(sp)
    80002490:	f052                	sd	s4,32(sp)
    80002492:	ec56                	sd	s5,24(sp)
    80002494:	e85a                	sd	s6,16(sp)
    80002496:	e45e                	sd	s7,8(sp)
    80002498:	e062                	sd	s8,0(sp)
    8000249a:	0880                	addi	s0,sp,80
    8000249c:	84aa                	mv	s1,a0
    8000249e:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    800024a0:	00000097          	auipc	ra,0x0
    800024a4:	c34080e7          	jalr	-972(ra) # 800020d4 <myproc>
        return result;
    800024a8:	4901                	li	s2,0
    if (count == 0)
    800024aa:	0c0b8663          	beqz	s7,80002576 <ps+0xf2>
    void *result = (void *)myproc()->sz;
    800024ae:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    800024b2:	003b951b          	slliw	a0,s7,0x3
    800024b6:	0175053b          	addw	a0,a0,s7
    800024ba:	0025151b          	slliw	a0,a0,0x2
    800024be:	2501                	sext.w	a0,a0
    800024c0:	00000097          	auipc	ra,0x0
    800024c4:	f68080e7          	jalr	-152(ra) # 80002428 <growproc>
    800024c8:	12054f63          	bltz	a0,80002606 <ps+0x182>
    struct user_proc loc_result[count];
    800024cc:	003b9a13          	slli	s4,s7,0x3
    800024d0:	9a5e                	add	s4,s4,s7
    800024d2:	0a0a                	slli	s4,s4,0x2
    800024d4:	00fa0793          	addi	a5,s4,15
    800024d8:	8391                	srli	a5,a5,0x4
    800024da:	0792                	slli	a5,a5,0x4
    800024dc:	40f10133          	sub	sp,sp,a5
    800024e0:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    800024e2:	16800793          	li	a5,360
    800024e6:	02f484b3          	mul	s1,s1,a5
    800024ea:	00092797          	auipc	a5,0x92
    800024ee:	ad678793          	addi	a5,a5,-1322 # 80093fc0 <proc>
    800024f2:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    800024f4:	00097797          	auipc	a5,0x97
    800024f8:	4cc78793          	addi	a5,a5,1228 # 800999c0 <tickslock>
        return result;
    800024fc:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    800024fe:	06f4fc63          	bgeu	s1,a5,80002576 <ps+0xf2>
    acquire(&wait_lock);
    80002502:	00092517          	auipc	a0,0x92
    80002506:	aa650513          	addi	a0,a0,-1370 # 80093fa8 <wait_lock>
    8000250a:	fffff097          	auipc	ra,0xfffff
    8000250e:	800080e7          	jalr	-2048(ra) # 80000d0a <acquire>
        if (localCount == count)
    80002512:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    80002516:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80002518:	00097c17          	auipc	s8,0x97
    8000251c:	4a8c0c13          	addi	s8,s8,1192 # 800999c0 <tickslock>
    80002520:	a851                	j	800025b4 <ps+0x130>
            loc_result[localCount].state = UNUSED;
    80002522:	00399793          	slli	a5,s3,0x3
    80002526:	97ce                	add	a5,a5,s3
    80002528:	078a                	slli	a5,a5,0x2
    8000252a:	97d6                	add	a5,a5,s5
    8000252c:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80002530:	8526                	mv	a0,s1
    80002532:	fffff097          	auipc	ra,0xfffff
    80002536:	88c080e7          	jalr	-1908(ra) # 80000dbe <release>
    release(&wait_lock);
    8000253a:	00092517          	auipc	a0,0x92
    8000253e:	a6e50513          	addi	a0,a0,-1426 # 80093fa8 <wait_lock>
    80002542:	fffff097          	auipc	ra,0xfffff
    80002546:	87c080e7          	jalr	-1924(ra) # 80000dbe <release>
    if (localCount < count)
    8000254a:	0179f963          	bgeu	s3,s7,8000255c <ps+0xd8>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    8000254e:	00399793          	slli	a5,s3,0x3
    80002552:	97ce                	add	a5,a5,s3
    80002554:	078a                	slli	a5,a5,0x2
    80002556:	97d6                	add	a5,a5,s5
    80002558:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    8000255c:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    8000255e:	00000097          	auipc	ra,0x0
    80002562:	b76080e7          	jalr	-1162(ra) # 800020d4 <myproc>
    80002566:	86d2                	mv	a3,s4
    80002568:	8656                	mv	a2,s5
    8000256a:	85da                	mv	a1,s6
    8000256c:	6928                	ld	a0,80(a0)
    8000256e:	fffff097          	auipc	ra,0xfffff
    80002572:	5bc080e7          	jalr	1468(ra) # 80001b2a <copyout>
}
    80002576:	854a                	mv	a0,s2
    80002578:	fb040113          	addi	sp,s0,-80
    8000257c:	60a6                	ld	ra,72(sp)
    8000257e:	6406                	ld	s0,64(sp)
    80002580:	74e2                	ld	s1,56(sp)
    80002582:	7942                	ld	s2,48(sp)
    80002584:	79a2                	ld	s3,40(sp)
    80002586:	7a02                	ld	s4,32(sp)
    80002588:	6ae2                	ld	s5,24(sp)
    8000258a:	6b42                	ld	s6,16(sp)
    8000258c:	6ba2                	ld	s7,8(sp)
    8000258e:	6c02                	ld	s8,0(sp)
    80002590:	6161                	addi	sp,sp,80
    80002592:	8082                	ret
        release(&p->lock);
    80002594:	8526                	mv	a0,s1
    80002596:	fffff097          	auipc	ra,0xfffff
    8000259a:	828080e7          	jalr	-2008(ra) # 80000dbe <release>
        localCount++;
    8000259e:	2985                	addiw	s3,s3,1
    800025a0:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    800025a4:	16848493          	addi	s1,s1,360
    800025a8:	f984f9e3          	bgeu	s1,s8,8000253a <ps+0xb6>
        if (localCount == count)
    800025ac:	02490913          	addi	s2,s2,36
    800025b0:	053b8d63          	beq	s7,s3,8000260a <ps+0x186>
        acquire(&p->lock);
    800025b4:	8526                	mv	a0,s1
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	754080e7          	jalr	1876(ra) # 80000d0a <acquire>
        if (p->state == UNUSED)
    800025be:	4c9c                	lw	a5,24(s1)
    800025c0:	d3ad                	beqz	a5,80002522 <ps+0x9e>
        loc_result[localCount].state = p->state;
    800025c2:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    800025c6:	549c                	lw	a5,40(s1)
    800025c8:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    800025cc:	54dc                	lw	a5,44(s1)
    800025ce:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    800025d2:	589c                	lw	a5,48(s1)
    800025d4:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    800025d8:	4641                	li	a2,16
    800025da:	85ca                	mv	a1,s2
    800025dc:	15848513          	addi	a0,s1,344
    800025e0:	00000097          	auipc	ra,0x0
    800025e4:	9ce080e7          	jalr	-1586(ra) # 80001fae <copy_array>
        if (p->parent != 0) // init
    800025e8:	7c88                	ld	a0,56(s1)
    800025ea:	d54d                	beqz	a0,80002594 <ps+0x110>
            acquire(&p->parent->lock);
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	71e080e7          	jalr	1822(ra) # 80000d0a <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    800025f4:	7c88                	ld	a0,56(s1)
    800025f6:	591c                	lw	a5,48(a0)
    800025f8:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    800025fc:	ffffe097          	auipc	ra,0xffffe
    80002600:	7c2080e7          	jalr	1986(ra) # 80000dbe <release>
    80002604:	bf41                	j	80002594 <ps+0x110>
        return result;
    80002606:	4901                	li	s2,0
    80002608:	b7bd                	j	80002576 <ps+0xf2>
    release(&wait_lock);
    8000260a:	00092517          	auipc	a0,0x92
    8000260e:	99e50513          	addi	a0,a0,-1634 # 80093fa8 <wait_lock>
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	7ac080e7          	jalr	1964(ra) # 80000dbe <release>
    if (localCount < count)
    8000261a:	b789                	j	8000255c <ps+0xd8>

000000008000261c <fork>:
{
    8000261c:	7139                	addi	sp,sp,-64
    8000261e:	fc06                	sd	ra,56(sp)
    80002620:	f822                	sd	s0,48(sp)
    80002622:	f04a                	sd	s2,32(sp)
    80002624:	e456                	sd	s5,8(sp)
    80002626:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    80002628:	00000097          	auipc	ra,0x0
    8000262c:	aac080e7          	jalr	-1364(ra) # 800020d4 <myproc>
    80002630:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    80002632:	00000097          	auipc	ra,0x0
    80002636:	ca6080e7          	jalr	-858(ra) # 800022d8 <allocproc>
    8000263a:	10050b63          	beqz	a0,80002750 <fork+0x134>
    8000263e:	e852                	sd	s4,16(sp)
    80002640:	8a2a                	mv	s4,a0
    if (uvmremap(p->pagetable, np->pagetable, p->sz) < 0)
    80002642:	048ab603          	ld	a2,72(s5)
    80002646:	692c                	ld	a1,80(a0)
    80002648:	050ab503          	ld	a0,80(s5)
    8000264c:	fffff097          	auipc	ra,0xfffff
    80002650:	3f4080e7          	jalr	1012(ra) # 80001a40 <uvmremap>
    80002654:	04054a63          	bltz	a0,800026a8 <fork+0x8c>
    80002658:	f426                	sd	s1,40(sp)
    8000265a:	ec4e                	sd	s3,24(sp)
    np->sz = p->sz;
    8000265c:	048ab783          	ld	a5,72(s5)
    80002660:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    80002664:	058ab683          	ld	a3,88(s5)
    80002668:	87b6                	mv	a5,a3
    8000266a:	058a3703          	ld	a4,88(s4)
    8000266e:	12068693          	addi	a3,a3,288
    80002672:	0007b803          	ld	a6,0(a5)
    80002676:	6788                	ld	a0,8(a5)
    80002678:	6b8c                	ld	a1,16(a5)
    8000267a:	6f90                	ld	a2,24(a5)
    8000267c:	01073023          	sd	a6,0(a4)
    80002680:	e708                	sd	a0,8(a4)
    80002682:	eb0c                	sd	a1,16(a4)
    80002684:	ef10                	sd	a2,24(a4)
    80002686:	02078793          	addi	a5,a5,32
    8000268a:	02070713          	addi	a4,a4,32
    8000268e:	fed792e3          	bne	a5,a3,80002672 <fork+0x56>
    np->trapframe->a0 = 0;
    80002692:	058a3783          	ld	a5,88(s4)
    80002696:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    8000269a:	0d0a8493          	addi	s1,s5,208
    8000269e:	0d0a0913          	addi	s2,s4,208
    800026a2:	150a8993          	addi	s3,s5,336
    800026a6:	a829                	j	800026c0 <fork+0xa4>
        release(&np->lock);
    800026a8:	8552                	mv	a0,s4
    800026aa:	ffffe097          	auipc	ra,0xffffe
    800026ae:	714080e7          	jalr	1812(ra) # 80000dbe <release>
        return -1;
    800026b2:	597d                	li	s2,-1
    800026b4:	6a42                	ld	s4,16(sp)
    800026b6:	a071                	j	80002742 <fork+0x126>
    for (i = 0; i < NOFILE; i++)
    800026b8:	04a1                	addi	s1,s1,8
    800026ba:	0921                	addi	s2,s2,8
    800026bc:	01348b63          	beq	s1,s3,800026d2 <fork+0xb6>
        if (p->ofile[i])
    800026c0:	6088                	ld	a0,0(s1)
    800026c2:	d97d                	beqz	a0,800026b8 <fork+0x9c>
            np->ofile[i] = filedup(p->ofile[i]);
    800026c4:	00003097          	auipc	ra,0x3
    800026c8:	964080e7          	jalr	-1692(ra) # 80005028 <filedup>
    800026cc:	00a93023          	sd	a0,0(s2)
    800026d0:	b7e5                	j	800026b8 <fork+0x9c>
    np->cwd = idup(p->cwd);
    800026d2:	150ab503          	ld	a0,336(s5)
    800026d6:	00002097          	auipc	ra,0x2
    800026da:	ace080e7          	jalr	-1330(ra) # 800041a4 <idup>
    800026de:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    800026e2:	4641                	li	a2,16
    800026e4:	158a8593          	addi	a1,s5,344
    800026e8:	158a0513          	addi	a0,s4,344
    800026ec:	fffff097          	auipc	ra,0xfffff
    800026f0:	85c080e7          	jalr	-1956(ra) # 80000f48 <safestrcpy>
    pid = np->pid;
    800026f4:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    800026f8:	8552                	mv	a0,s4
    800026fa:	ffffe097          	auipc	ra,0xffffe
    800026fe:	6c4080e7          	jalr	1732(ra) # 80000dbe <release>
    acquire(&wait_lock);
    80002702:	00092497          	auipc	s1,0x92
    80002706:	8a648493          	addi	s1,s1,-1882 # 80093fa8 <wait_lock>
    8000270a:	8526                	mv	a0,s1
    8000270c:	ffffe097          	auipc	ra,0xffffe
    80002710:	5fe080e7          	jalr	1534(ra) # 80000d0a <acquire>
    np->parent = p;
    80002714:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    80002718:	8526                	mv	a0,s1
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	6a4080e7          	jalr	1700(ra) # 80000dbe <release>
    acquire(&np->lock);
    80002722:	8552                	mv	a0,s4
    80002724:	ffffe097          	auipc	ra,0xffffe
    80002728:	5e6080e7          	jalr	1510(ra) # 80000d0a <acquire>
    np->state = RUNNABLE;
    8000272c:	478d                	li	a5,3
    8000272e:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002732:	8552                	mv	a0,s4
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	68a080e7          	jalr	1674(ra) # 80000dbe <release>
    return pid;
    8000273c:	74a2                	ld	s1,40(sp)
    8000273e:	69e2                	ld	s3,24(sp)
    80002740:	6a42                	ld	s4,16(sp)
}
    80002742:	854a                	mv	a0,s2
    80002744:	70e2                	ld	ra,56(sp)
    80002746:	7442                	ld	s0,48(sp)
    80002748:	7902                	ld	s2,32(sp)
    8000274a:	6aa2                	ld	s5,8(sp)
    8000274c:	6121                	addi	sp,sp,64
    8000274e:	8082                	ret
        return -1;
    80002750:	597d                	li	s2,-1
    80002752:	bfc5                	j	80002742 <fork+0x126>

0000000080002754 <scheduler>:
{
    80002754:	1101                	addi	sp,sp,-32
    80002756:	ec06                	sd	ra,24(sp)
    80002758:	e822                	sd	s0,16(sp)
    8000275a:	e426                	sd	s1,8(sp)
    8000275c:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    8000275e:	00009497          	auipc	s1,0x9
    80002762:	0ba48493          	addi	s1,s1,186 # 8000b818 <sched_pointer>
    80002766:	609c                	ld	a5,0(s1)
    80002768:	9782                	jalr	a5
    while (1)
    8000276a:	bff5                	j	80002766 <scheduler+0x12>

000000008000276c <sched>:
{
    8000276c:	7179                	addi	sp,sp,-48
    8000276e:	f406                	sd	ra,40(sp)
    80002770:	f022                	sd	s0,32(sp)
    80002772:	ec26                	sd	s1,24(sp)
    80002774:	e84a                	sd	s2,16(sp)
    80002776:	e44e                	sd	s3,8(sp)
    80002778:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    8000277a:	00000097          	auipc	ra,0x0
    8000277e:	95a080e7          	jalr	-1702(ra) # 800020d4 <myproc>
    80002782:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    80002784:	ffffe097          	auipc	ra,0xffffe
    80002788:	50c080e7          	jalr	1292(ra) # 80000c90 <holding>
    8000278c:	c53d                	beqz	a0,800027fa <sched+0x8e>
    8000278e:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    80002790:	2781                	sext.w	a5,a5
    80002792:	079e                	slli	a5,a5,0x7
    80002794:	00091717          	auipc	a4,0x91
    80002798:	3fc70713          	addi	a4,a4,1020 # 80093b90 <cpus>
    8000279c:	97ba                	add	a5,a5,a4
    8000279e:	5fb8                	lw	a4,120(a5)
    800027a0:	4785                	li	a5,1
    800027a2:	06f71463          	bne	a4,a5,8000280a <sched+0x9e>
    if (p->state == RUNNING)
    800027a6:	4c98                	lw	a4,24(s1)
    800027a8:	4791                	li	a5,4
    800027aa:	06f70863          	beq	a4,a5,8000281a <sched+0xae>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    800027ae:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    800027b2:	8b89                	andi	a5,a5,2
    if (intr_get())
    800027b4:	ebbd                	bnez	a5,8000282a <sched+0xbe>
    asm volatile("mv %0, tp" : "=r"(x));
    800027b6:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    800027b8:	00091917          	auipc	s2,0x91
    800027bc:	3d890913          	addi	s2,s2,984 # 80093b90 <cpus>
    800027c0:	2781                	sext.w	a5,a5
    800027c2:	079e                	slli	a5,a5,0x7
    800027c4:	97ca                	add	a5,a5,s2
    800027c6:	07c7a983          	lw	s3,124(a5)
    800027ca:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    800027cc:	2581                	sext.w	a1,a1
    800027ce:	059e                	slli	a1,a1,0x7
    800027d0:	05a1                	addi	a1,a1,8
    800027d2:	95ca                	add	a1,a1,s2
    800027d4:	06048513          	addi	a0,s1,96
    800027d8:	00000097          	auipc	ra,0x0
    800027dc:	6e4080e7          	jalr	1764(ra) # 80002ebc <swtch>
    800027e0:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    800027e2:	2781                	sext.w	a5,a5
    800027e4:	079e                	slli	a5,a5,0x7
    800027e6:	993e                	add	s2,s2,a5
    800027e8:	07392e23          	sw	s3,124(s2)
}
    800027ec:	70a2                	ld	ra,40(sp)
    800027ee:	7402                	ld	s0,32(sp)
    800027f0:	64e2                	ld	s1,24(sp)
    800027f2:	6942                	ld	s2,16(sp)
    800027f4:	69a2                	ld	s3,8(sp)
    800027f6:	6145                	addi	sp,sp,48
    800027f8:	8082                	ret
        panic("sched p->lock");
    800027fa:	00006517          	auipc	a0,0x6
    800027fe:	bde50513          	addi	a0,a0,-1058 # 800083d8 <__func__.1+0x3d0>
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	d5e080e7          	jalr	-674(ra) # 80000560 <panic>
        panic("sched locks");
    8000280a:	00006517          	auipc	a0,0x6
    8000280e:	bde50513          	addi	a0,a0,-1058 # 800083e8 <__func__.1+0x3e0>
    80002812:	ffffe097          	auipc	ra,0xffffe
    80002816:	d4e080e7          	jalr	-690(ra) # 80000560 <panic>
        panic("sched running");
    8000281a:	00006517          	auipc	a0,0x6
    8000281e:	bde50513          	addi	a0,a0,-1058 # 800083f8 <__func__.1+0x3f0>
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	d3e080e7          	jalr	-706(ra) # 80000560 <panic>
        panic("sched interruptible");
    8000282a:	00006517          	auipc	a0,0x6
    8000282e:	bde50513          	addi	a0,a0,-1058 # 80008408 <__func__.1+0x400>
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	d2e080e7          	jalr	-722(ra) # 80000560 <panic>

000000008000283a <yield>:
{
    8000283a:	1101                	addi	sp,sp,-32
    8000283c:	ec06                	sd	ra,24(sp)
    8000283e:	e822                	sd	s0,16(sp)
    80002840:	e426                	sd	s1,8(sp)
    80002842:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    80002844:	00000097          	auipc	ra,0x0
    80002848:	890080e7          	jalr	-1904(ra) # 800020d4 <myproc>
    8000284c:	84aa                	mv	s1,a0
    acquire(&p->lock);
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	4bc080e7          	jalr	1212(ra) # 80000d0a <acquire>
    p->state = RUNNABLE;
    80002856:	478d                	li	a5,3
    80002858:	cc9c                	sw	a5,24(s1)
    sched();
    8000285a:	00000097          	auipc	ra,0x0
    8000285e:	f12080e7          	jalr	-238(ra) # 8000276c <sched>
    release(&p->lock);
    80002862:	8526                	mv	a0,s1
    80002864:	ffffe097          	auipc	ra,0xffffe
    80002868:	55a080e7          	jalr	1370(ra) # 80000dbe <release>
}
    8000286c:	60e2                	ld	ra,24(sp)
    8000286e:	6442                	ld	s0,16(sp)
    80002870:	64a2                	ld	s1,8(sp)
    80002872:	6105                	addi	sp,sp,32
    80002874:	8082                	ret

0000000080002876 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002876:	7179                	addi	sp,sp,-48
    80002878:	f406                	sd	ra,40(sp)
    8000287a:	f022                	sd	s0,32(sp)
    8000287c:	ec26                	sd	s1,24(sp)
    8000287e:	e84a                	sd	s2,16(sp)
    80002880:	e44e                	sd	s3,8(sp)
    80002882:	1800                	addi	s0,sp,48
    80002884:	89aa                	mv	s3,a0
    80002886:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002888:	00000097          	auipc	ra,0x0
    8000288c:	84c080e7          	jalr	-1972(ra) # 800020d4 <myproc>
    80002890:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    80002892:	ffffe097          	auipc	ra,0xffffe
    80002896:	478080e7          	jalr	1144(ra) # 80000d0a <acquire>
    release(lk);
    8000289a:	854a                	mv	a0,s2
    8000289c:	ffffe097          	auipc	ra,0xffffe
    800028a0:	522080e7          	jalr	1314(ra) # 80000dbe <release>

    // Go to sleep.
    p->chan = chan;
    800028a4:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    800028a8:	4789                	li	a5,2
    800028aa:	cc9c                	sw	a5,24(s1)

    sched();
    800028ac:	00000097          	auipc	ra,0x0
    800028b0:	ec0080e7          	jalr	-320(ra) # 8000276c <sched>

    // Tidy up.
    p->chan = 0;
    800028b4:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    800028b8:	8526                	mv	a0,s1
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	504080e7          	jalr	1284(ra) # 80000dbe <release>
    acquire(lk);
    800028c2:	854a                	mv	a0,s2
    800028c4:	ffffe097          	auipc	ra,0xffffe
    800028c8:	446080e7          	jalr	1094(ra) # 80000d0a <acquire>
}
    800028cc:	70a2                	ld	ra,40(sp)
    800028ce:	7402                	ld	s0,32(sp)
    800028d0:	64e2                	ld	s1,24(sp)
    800028d2:	6942                	ld	s2,16(sp)
    800028d4:	69a2                	ld	s3,8(sp)
    800028d6:	6145                	addi	sp,sp,48
    800028d8:	8082                	ret

00000000800028da <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800028da:	7139                	addi	sp,sp,-64
    800028dc:	fc06                	sd	ra,56(sp)
    800028de:	f822                	sd	s0,48(sp)
    800028e0:	f426                	sd	s1,40(sp)
    800028e2:	f04a                	sd	s2,32(sp)
    800028e4:	ec4e                	sd	s3,24(sp)
    800028e6:	e852                	sd	s4,16(sp)
    800028e8:	e456                	sd	s5,8(sp)
    800028ea:	0080                	addi	s0,sp,64
    800028ec:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800028ee:	00091497          	auipc	s1,0x91
    800028f2:	6d248493          	addi	s1,s1,1746 # 80093fc0 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    800028f6:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    800028f8:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    800028fa:	00097917          	auipc	s2,0x97
    800028fe:	0c690913          	addi	s2,s2,198 # 800999c0 <tickslock>
    80002902:	a811                	j	80002916 <wakeup+0x3c>
            }
            release(&p->lock);
    80002904:	8526                	mv	a0,s1
    80002906:	ffffe097          	auipc	ra,0xffffe
    8000290a:	4b8080e7          	jalr	1208(ra) # 80000dbe <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000290e:	16848493          	addi	s1,s1,360
    80002912:	03248663          	beq	s1,s2,8000293e <wakeup+0x64>
        if (p != myproc())
    80002916:	fffff097          	auipc	ra,0xfffff
    8000291a:	7be080e7          	jalr	1982(ra) # 800020d4 <myproc>
    8000291e:	fea488e3          	beq	s1,a0,8000290e <wakeup+0x34>
            acquire(&p->lock);
    80002922:	8526                	mv	a0,s1
    80002924:	ffffe097          	auipc	ra,0xffffe
    80002928:	3e6080e7          	jalr	998(ra) # 80000d0a <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    8000292c:	4c9c                	lw	a5,24(s1)
    8000292e:	fd379be3          	bne	a5,s3,80002904 <wakeup+0x2a>
    80002932:	709c                	ld	a5,32(s1)
    80002934:	fd4798e3          	bne	a5,s4,80002904 <wakeup+0x2a>
                p->state = RUNNABLE;
    80002938:	0154ac23          	sw	s5,24(s1)
    8000293c:	b7e1                	j	80002904 <wakeup+0x2a>
        }
    }
}
    8000293e:	70e2                	ld	ra,56(sp)
    80002940:	7442                	ld	s0,48(sp)
    80002942:	74a2                	ld	s1,40(sp)
    80002944:	7902                	ld	s2,32(sp)
    80002946:	69e2                	ld	s3,24(sp)
    80002948:	6a42                	ld	s4,16(sp)
    8000294a:	6aa2                	ld	s5,8(sp)
    8000294c:	6121                	addi	sp,sp,64
    8000294e:	8082                	ret

0000000080002950 <reparent>:
{
    80002950:	7179                	addi	sp,sp,-48
    80002952:	f406                	sd	ra,40(sp)
    80002954:	f022                	sd	s0,32(sp)
    80002956:	ec26                	sd	s1,24(sp)
    80002958:	e84a                	sd	s2,16(sp)
    8000295a:	e44e                	sd	s3,8(sp)
    8000295c:	e052                	sd	s4,0(sp)
    8000295e:	1800                	addi	s0,sp,48
    80002960:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002962:	00091497          	auipc	s1,0x91
    80002966:	65e48493          	addi	s1,s1,1630 # 80093fc0 <proc>
            pp->parent = initproc;
    8000296a:	00009a17          	auipc	s4,0x9
    8000296e:	f7ea0a13          	addi	s4,s4,-130 # 8000b8e8 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002972:	00097997          	auipc	s3,0x97
    80002976:	04e98993          	addi	s3,s3,78 # 800999c0 <tickslock>
    8000297a:	a029                	j	80002984 <reparent+0x34>
    8000297c:	16848493          	addi	s1,s1,360
    80002980:	01348d63          	beq	s1,s3,8000299a <reparent+0x4a>
        if (pp->parent == p)
    80002984:	7c9c                	ld	a5,56(s1)
    80002986:	ff279be3          	bne	a5,s2,8000297c <reparent+0x2c>
            pp->parent = initproc;
    8000298a:	000a3503          	ld	a0,0(s4)
    8000298e:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    80002990:	00000097          	auipc	ra,0x0
    80002994:	f4a080e7          	jalr	-182(ra) # 800028da <wakeup>
    80002998:	b7d5                	j	8000297c <reparent+0x2c>
}
    8000299a:	70a2                	ld	ra,40(sp)
    8000299c:	7402                	ld	s0,32(sp)
    8000299e:	64e2                	ld	s1,24(sp)
    800029a0:	6942                	ld	s2,16(sp)
    800029a2:	69a2                	ld	s3,8(sp)
    800029a4:	6a02                	ld	s4,0(sp)
    800029a6:	6145                	addi	sp,sp,48
    800029a8:	8082                	ret

00000000800029aa <exit>:
{
    800029aa:	7179                	addi	sp,sp,-48
    800029ac:	f406                	sd	ra,40(sp)
    800029ae:	f022                	sd	s0,32(sp)
    800029b0:	ec26                	sd	s1,24(sp)
    800029b2:	e84a                	sd	s2,16(sp)
    800029b4:	e44e                	sd	s3,8(sp)
    800029b6:	e052                	sd	s4,0(sp)
    800029b8:	1800                	addi	s0,sp,48
    800029ba:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    800029bc:	fffff097          	auipc	ra,0xfffff
    800029c0:	718080e7          	jalr	1816(ra) # 800020d4 <myproc>
    800029c4:	89aa                	mv	s3,a0
    if (p == initproc)
    800029c6:	00009797          	auipc	a5,0x9
    800029ca:	f227b783          	ld	a5,-222(a5) # 8000b8e8 <initproc>
    800029ce:	0d050493          	addi	s1,a0,208
    800029d2:	15050913          	addi	s2,a0,336
    800029d6:	02a79363          	bne	a5,a0,800029fc <exit+0x52>
        panic("init exiting");
    800029da:	00006517          	auipc	a0,0x6
    800029de:	a4650513          	addi	a0,a0,-1466 # 80008420 <__func__.1+0x418>
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	b7e080e7          	jalr	-1154(ra) # 80000560 <panic>
            fileclose(f);
    800029ea:	00002097          	auipc	ra,0x2
    800029ee:	690080e7          	jalr	1680(ra) # 8000507a <fileclose>
            p->ofile[fd] = 0;
    800029f2:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    800029f6:	04a1                	addi	s1,s1,8
    800029f8:	01248563          	beq	s1,s2,80002a02 <exit+0x58>
        if (p->ofile[fd])
    800029fc:	6088                	ld	a0,0(s1)
    800029fe:	f575                	bnez	a0,800029ea <exit+0x40>
    80002a00:	bfdd                	j	800029f6 <exit+0x4c>
    begin_op();
    80002a02:	00002097          	auipc	ra,0x2
    80002a06:	1ae080e7          	jalr	430(ra) # 80004bb0 <begin_op>
    iput(p->cwd);
    80002a0a:	1509b503          	ld	a0,336(s3)
    80002a0e:	00002097          	auipc	ra,0x2
    80002a12:	992080e7          	jalr	-1646(ra) # 800043a0 <iput>
    end_op();
    80002a16:	00002097          	auipc	ra,0x2
    80002a1a:	214080e7          	jalr	532(ra) # 80004c2a <end_op>
    p->cwd = 0;
    80002a1e:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002a22:	00091497          	auipc	s1,0x91
    80002a26:	58648493          	addi	s1,s1,1414 # 80093fa8 <wait_lock>
    80002a2a:	8526                	mv	a0,s1
    80002a2c:	ffffe097          	auipc	ra,0xffffe
    80002a30:	2de080e7          	jalr	734(ra) # 80000d0a <acquire>
    reparent(p);
    80002a34:	854e                	mv	a0,s3
    80002a36:	00000097          	auipc	ra,0x0
    80002a3a:	f1a080e7          	jalr	-230(ra) # 80002950 <reparent>
    wakeup(p->parent);
    80002a3e:	0389b503          	ld	a0,56(s3)
    80002a42:	00000097          	auipc	ra,0x0
    80002a46:	e98080e7          	jalr	-360(ra) # 800028da <wakeup>
    acquire(&p->lock);
    80002a4a:	854e                	mv	a0,s3
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	2be080e7          	jalr	702(ra) # 80000d0a <acquire>
    p->xstate = status;
    80002a54:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    80002a58:	4795                	li	a5,5
    80002a5a:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002a5e:	8526                	mv	a0,s1
    80002a60:	ffffe097          	auipc	ra,0xffffe
    80002a64:	35e080e7          	jalr	862(ra) # 80000dbe <release>
    sched();
    80002a68:	00000097          	auipc	ra,0x0
    80002a6c:	d04080e7          	jalr	-764(ra) # 8000276c <sched>
    panic("zombie exit");
    80002a70:	00006517          	auipc	a0,0x6
    80002a74:	9c050513          	addi	a0,a0,-1600 # 80008430 <__func__.1+0x428>
    80002a78:	ffffe097          	auipc	ra,0xffffe
    80002a7c:	ae8080e7          	jalr	-1304(ra) # 80000560 <panic>

0000000080002a80 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002a80:	7179                	addi	sp,sp,-48
    80002a82:	f406                	sd	ra,40(sp)
    80002a84:	f022                	sd	s0,32(sp)
    80002a86:	ec26                	sd	s1,24(sp)
    80002a88:	e84a                	sd	s2,16(sp)
    80002a8a:	e44e                	sd	s3,8(sp)
    80002a8c:	1800                	addi	s0,sp,48
    80002a8e:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002a90:	00091497          	auipc	s1,0x91
    80002a94:	53048493          	addi	s1,s1,1328 # 80093fc0 <proc>
    80002a98:	00097997          	auipc	s3,0x97
    80002a9c:	f2898993          	addi	s3,s3,-216 # 800999c0 <tickslock>
    {
        acquire(&p->lock);
    80002aa0:	8526                	mv	a0,s1
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	268080e7          	jalr	616(ra) # 80000d0a <acquire>
        if (p->pid == pid)
    80002aaa:	589c                	lw	a5,48(s1)
    80002aac:	01278d63          	beq	a5,s2,80002ac6 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002ab0:	8526                	mv	a0,s1
    80002ab2:	ffffe097          	auipc	ra,0xffffe
    80002ab6:	30c080e7          	jalr	780(ra) # 80000dbe <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002aba:	16848493          	addi	s1,s1,360
    80002abe:	ff3491e3          	bne	s1,s3,80002aa0 <kill+0x20>
    }
    return -1;
    80002ac2:	557d                	li	a0,-1
    80002ac4:	a829                	j	80002ade <kill+0x5e>
            p->killed = 1;
    80002ac6:	4785                	li	a5,1
    80002ac8:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    80002aca:	4c98                	lw	a4,24(s1)
    80002acc:	4789                	li	a5,2
    80002ace:	00f70f63          	beq	a4,a5,80002aec <kill+0x6c>
            release(&p->lock);
    80002ad2:	8526                	mv	a0,s1
    80002ad4:	ffffe097          	auipc	ra,0xffffe
    80002ad8:	2ea080e7          	jalr	746(ra) # 80000dbe <release>
            return 0;
    80002adc:	4501                	li	a0,0
}
    80002ade:	70a2                	ld	ra,40(sp)
    80002ae0:	7402                	ld	s0,32(sp)
    80002ae2:	64e2                	ld	s1,24(sp)
    80002ae4:	6942                	ld	s2,16(sp)
    80002ae6:	69a2                	ld	s3,8(sp)
    80002ae8:	6145                	addi	sp,sp,48
    80002aea:	8082                	ret
                p->state = RUNNABLE;
    80002aec:	478d                	li	a5,3
    80002aee:	cc9c                	sw	a5,24(s1)
    80002af0:	b7cd                	j	80002ad2 <kill+0x52>

0000000080002af2 <setkilled>:

void setkilled(struct proc *p)
{
    80002af2:	1101                	addi	sp,sp,-32
    80002af4:	ec06                	sd	ra,24(sp)
    80002af6:	e822                	sd	s0,16(sp)
    80002af8:	e426                	sd	s1,8(sp)
    80002afa:	1000                	addi	s0,sp,32
    80002afc:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002afe:	ffffe097          	auipc	ra,0xffffe
    80002b02:	20c080e7          	jalr	524(ra) # 80000d0a <acquire>
    p->killed = 1;
    80002b06:	4785                	li	a5,1
    80002b08:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    80002b0a:	8526                	mv	a0,s1
    80002b0c:	ffffe097          	auipc	ra,0xffffe
    80002b10:	2b2080e7          	jalr	690(ra) # 80000dbe <release>
}
    80002b14:	60e2                	ld	ra,24(sp)
    80002b16:	6442                	ld	s0,16(sp)
    80002b18:	64a2                	ld	s1,8(sp)
    80002b1a:	6105                	addi	sp,sp,32
    80002b1c:	8082                	ret

0000000080002b1e <killed>:

int killed(struct proc *p)
{
    80002b1e:	1101                	addi	sp,sp,-32
    80002b20:	ec06                	sd	ra,24(sp)
    80002b22:	e822                	sd	s0,16(sp)
    80002b24:	e426                	sd	s1,8(sp)
    80002b26:	e04a                	sd	s2,0(sp)
    80002b28:	1000                	addi	s0,sp,32
    80002b2a:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    80002b2c:	ffffe097          	auipc	ra,0xffffe
    80002b30:	1de080e7          	jalr	478(ra) # 80000d0a <acquire>
    k = p->killed;
    80002b34:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    80002b38:	8526                	mv	a0,s1
    80002b3a:	ffffe097          	auipc	ra,0xffffe
    80002b3e:	284080e7          	jalr	644(ra) # 80000dbe <release>
    return k;
}
    80002b42:	854a                	mv	a0,s2
    80002b44:	60e2                	ld	ra,24(sp)
    80002b46:	6442                	ld	s0,16(sp)
    80002b48:	64a2                	ld	s1,8(sp)
    80002b4a:	6902                	ld	s2,0(sp)
    80002b4c:	6105                	addi	sp,sp,32
    80002b4e:	8082                	ret

0000000080002b50 <wait>:
{
    80002b50:	715d                	addi	sp,sp,-80
    80002b52:	e486                	sd	ra,72(sp)
    80002b54:	e0a2                	sd	s0,64(sp)
    80002b56:	fc26                	sd	s1,56(sp)
    80002b58:	f84a                	sd	s2,48(sp)
    80002b5a:	f44e                	sd	s3,40(sp)
    80002b5c:	f052                	sd	s4,32(sp)
    80002b5e:	ec56                	sd	s5,24(sp)
    80002b60:	e85a                	sd	s6,16(sp)
    80002b62:	e45e                	sd	s7,8(sp)
    80002b64:	e062                	sd	s8,0(sp)
    80002b66:	0880                	addi	s0,sp,80
    80002b68:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    80002b6a:	fffff097          	auipc	ra,0xfffff
    80002b6e:	56a080e7          	jalr	1386(ra) # 800020d4 <myproc>
    80002b72:	892a                	mv	s2,a0
    acquire(&wait_lock);
    80002b74:	00091517          	auipc	a0,0x91
    80002b78:	43450513          	addi	a0,a0,1076 # 80093fa8 <wait_lock>
    80002b7c:	ffffe097          	auipc	ra,0xffffe
    80002b80:	18e080e7          	jalr	398(ra) # 80000d0a <acquire>
        havekids = 0;
    80002b84:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    80002b86:	4a15                	li	s4,5
                havekids = 1;
    80002b88:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002b8a:	00097997          	auipc	s3,0x97
    80002b8e:	e3698993          	addi	s3,s3,-458 # 800999c0 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002b92:	00091c17          	auipc	s8,0x91
    80002b96:	416c0c13          	addi	s8,s8,1046 # 80093fa8 <wait_lock>
    80002b9a:	a0d1                	j	80002c5e <wait+0x10e>
                    pid = pp->pid;
    80002b9c:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002ba0:	000b0e63          	beqz	s6,80002bbc <wait+0x6c>
    80002ba4:	4691                	li	a3,4
    80002ba6:	02c48613          	addi	a2,s1,44
    80002baa:	85da                	mv	a1,s6
    80002bac:	05093503          	ld	a0,80(s2)
    80002bb0:	fffff097          	auipc	ra,0xfffff
    80002bb4:	f7a080e7          	jalr	-134(ra) # 80001b2a <copyout>
    80002bb8:	04054163          	bltz	a0,80002bfa <wait+0xaa>
                    freeproc(pp);
    80002bbc:	8526                	mv	a0,s1
    80002bbe:	fffff097          	auipc	ra,0xfffff
    80002bc2:	6c2080e7          	jalr	1730(ra) # 80002280 <freeproc>
                    release(&pp->lock);
    80002bc6:	8526                	mv	a0,s1
    80002bc8:	ffffe097          	auipc	ra,0xffffe
    80002bcc:	1f6080e7          	jalr	502(ra) # 80000dbe <release>
                    release(&wait_lock);
    80002bd0:	00091517          	auipc	a0,0x91
    80002bd4:	3d850513          	addi	a0,a0,984 # 80093fa8 <wait_lock>
    80002bd8:	ffffe097          	auipc	ra,0xffffe
    80002bdc:	1e6080e7          	jalr	486(ra) # 80000dbe <release>
}
    80002be0:	854e                	mv	a0,s3
    80002be2:	60a6                	ld	ra,72(sp)
    80002be4:	6406                	ld	s0,64(sp)
    80002be6:	74e2                	ld	s1,56(sp)
    80002be8:	7942                	ld	s2,48(sp)
    80002bea:	79a2                	ld	s3,40(sp)
    80002bec:	7a02                	ld	s4,32(sp)
    80002bee:	6ae2                	ld	s5,24(sp)
    80002bf0:	6b42                	ld	s6,16(sp)
    80002bf2:	6ba2                	ld	s7,8(sp)
    80002bf4:	6c02                	ld	s8,0(sp)
    80002bf6:	6161                	addi	sp,sp,80
    80002bf8:	8082                	ret
                        release(&pp->lock);
    80002bfa:	8526                	mv	a0,s1
    80002bfc:	ffffe097          	auipc	ra,0xffffe
    80002c00:	1c2080e7          	jalr	450(ra) # 80000dbe <release>
                        release(&wait_lock);
    80002c04:	00091517          	auipc	a0,0x91
    80002c08:	3a450513          	addi	a0,a0,932 # 80093fa8 <wait_lock>
    80002c0c:	ffffe097          	auipc	ra,0xffffe
    80002c10:	1b2080e7          	jalr	434(ra) # 80000dbe <release>
                        return -1;
    80002c14:	59fd                	li	s3,-1
    80002c16:	b7e9                	j	80002be0 <wait+0x90>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002c18:	16848493          	addi	s1,s1,360
    80002c1c:	03348463          	beq	s1,s3,80002c44 <wait+0xf4>
            if (pp->parent == p)
    80002c20:	7c9c                	ld	a5,56(s1)
    80002c22:	ff279be3          	bne	a5,s2,80002c18 <wait+0xc8>
                acquire(&pp->lock);
    80002c26:	8526                	mv	a0,s1
    80002c28:	ffffe097          	auipc	ra,0xffffe
    80002c2c:	0e2080e7          	jalr	226(ra) # 80000d0a <acquire>
                if (pp->state == ZOMBIE)
    80002c30:	4c9c                	lw	a5,24(s1)
    80002c32:	f74785e3          	beq	a5,s4,80002b9c <wait+0x4c>
                release(&pp->lock);
    80002c36:	8526                	mv	a0,s1
    80002c38:	ffffe097          	auipc	ra,0xffffe
    80002c3c:	186080e7          	jalr	390(ra) # 80000dbe <release>
                havekids = 1;
    80002c40:	8756                	mv	a4,s5
    80002c42:	bfd9                	j	80002c18 <wait+0xc8>
        if (!havekids || killed(p))
    80002c44:	c31d                	beqz	a4,80002c6a <wait+0x11a>
    80002c46:	854a                	mv	a0,s2
    80002c48:	00000097          	auipc	ra,0x0
    80002c4c:	ed6080e7          	jalr	-298(ra) # 80002b1e <killed>
    80002c50:	ed09                	bnez	a0,80002c6a <wait+0x11a>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002c52:	85e2                	mv	a1,s8
    80002c54:	854a                	mv	a0,s2
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	c20080e7          	jalr	-992(ra) # 80002876 <sleep>
        havekids = 0;
    80002c5e:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002c60:	00091497          	auipc	s1,0x91
    80002c64:	36048493          	addi	s1,s1,864 # 80093fc0 <proc>
    80002c68:	bf65                	j	80002c20 <wait+0xd0>
            release(&wait_lock);
    80002c6a:	00091517          	auipc	a0,0x91
    80002c6e:	33e50513          	addi	a0,a0,830 # 80093fa8 <wait_lock>
    80002c72:	ffffe097          	auipc	ra,0xffffe
    80002c76:	14c080e7          	jalr	332(ra) # 80000dbe <release>
            return -1;
    80002c7a:	59fd                	li	s3,-1
    80002c7c:	b795                	j	80002be0 <wait+0x90>

0000000080002c7e <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002c7e:	7179                	addi	sp,sp,-48
    80002c80:	f406                	sd	ra,40(sp)
    80002c82:	f022                	sd	s0,32(sp)
    80002c84:	ec26                	sd	s1,24(sp)
    80002c86:	e84a                	sd	s2,16(sp)
    80002c88:	e44e                	sd	s3,8(sp)
    80002c8a:	e052                	sd	s4,0(sp)
    80002c8c:	1800                	addi	s0,sp,48
    80002c8e:	84aa                	mv	s1,a0
    80002c90:	892e                	mv	s2,a1
    80002c92:	89b2                	mv	s3,a2
    80002c94:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002c96:	fffff097          	auipc	ra,0xfffff
    80002c9a:	43e080e7          	jalr	1086(ra) # 800020d4 <myproc>
    if (user_dst)
    80002c9e:	c08d                	beqz	s1,80002cc0 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002ca0:	86d2                	mv	a3,s4
    80002ca2:	864e                	mv	a2,s3
    80002ca4:	85ca                	mv	a1,s2
    80002ca6:	6928                	ld	a0,80(a0)
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	e82080e7          	jalr	-382(ra) # 80001b2a <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002cb0:	70a2                	ld	ra,40(sp)
    80002cb2:	7402                	ld	s0,32(sp)
    80002cb4:	64e2                	ld	s1,24(sp)
    80002cb6:	6942                	ld	s2,16(sp)
    80002cb8:	69a2                	ld	s3,8(sp)
    80002cba:	6a02                	ld	s4,0(sp)
    80002cbc:	6145                	addi	sp,sp,48
    80002cbe:	8082                	ret
        memmove((char *)dst, src, len);
    80002cc0:	000a061b          	sext.w	a2,s4
    80002cc4:	85ce                	mv	a1,s3
    80002cc6:	854a                	mv	a0,s2
    80002cc8:	ffffe097          	auipc	ra,0xffffe
    80002ccc:	19a080e7          	jalr	410(ra) # 80000e62 <memmove>
        return 0;
    80002cd0:	8526                	mv	a0,s1
    80002cd2:	bff9                	j	80002cb0 <either_copyout+0x32>

0000000080002cd4 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002cd4:	7179                	addi	sp,sp,-48
    80002cd6:	f406                	sd	ra,40(sp)
    80002cd8:	f022                	sd	s0,32(sp)
    80002cda:	ec26                	sd	s1,24(sp)
    80002cdc:	e84a                	sd	s2,16(sp)
    80002cde:	e44e                	sd	s3,8(sp)
    80002ce0:	e052                	sd	s4,0(sp)
    80002ce2:	1800                	addi	s0,sp,48
    80002ce4:	892a                	mv	s2,a0
    80002ce6:	84ae                	mv	s1,a1
    80002ce8:	89b2                	mv	s3,a2
    80002cea:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	3e8080e7          	jalr	1000(ra) # 800020d4 <myproc>
    if (user_src)
    80002cf4:	c08d                	beqz	s1,80002d16 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    80002cf6:	86d2                	mv	a3,s4
    80002cf8:	864e                	mv	a2,s3
    80002cfa:	85ca                	mv	a1,s2
    80002cfc:	6928                	ld	a0,80(a0)
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	f30080e7          	jalr	-208(ra) # 80001c2e <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    80002d06:	70a2                	ld	ra,40(sp)
    80002d08:	7402                	ld	s0,32(sp)
    80002d0a:	64e2                	ld	s1,24(sp)
    80002d0c:	6942                	ld	s2,16(sp)
    80002d0e:	69a2                	ld	s3,8(sp)
    80002d10:	6a02                	ld	s4,0(sp)
    80002d12:	6145                	addi	sp,sp,48
    80002d14:	8082                	ret
        memmove(dst, (char *)src, len);
    80002d16:	000a061b          	sext.w	a2,s4
    80002d1a:	85ce                	mv	a1,s3
    80002d1c:	854a                	mv	a0,s2
    80002d1e:	ffffe097          	auipc	ra,0xffffe
    80002d22:	144080e7          	jalr	324(ra) # 80000e62 <memmove>
        return 0;
    80002d26:	8526                	mv	a0,s1
    80002d28:	bff9                	j	80002d06 <either_copyin+0x32>

0000000080002d2a <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002d2a:	715d                	addi	sp,sp,-80
    80002d2c:	e486                	sd	ra,72(sp)
    80002d2e:	e0a2                	sd	s0,64(sp)
    80002d30:	fc26                	sd	s1,56(sp)
    80002d32:	f84a                	sd	s2,48(sp)
    80002d34:	f44e                	sd	s3,40(sp)
    80002d36:	f052                	sd	s4,32(sp)
    80002d38:	ec56                	sd	s5,24(sp)
    80002d3a:	e85a                	sd	s6,16(sp)
    80002d3c:	e45e                	sd	s7,8(sp)
    80002d3e:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002d40:	00005517          	auipc	a0,0x5
    80002d44:	2e050513          	addi	a0,a0,736 # 80008020 <__func__.1+0x18>
    80002d48:	ffffe097          	auipc	ra,0xffffe
    80002d4c:	874080e7          	jalr	-1932(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002d50:	00091497          	auipc	s1,0x91
    80002d54:	3c848493          	addi	s1,s1,968 # 80094118 <proc+0x158>
    80002d58:	00097917          	auipc	s2,0x97
    80002d5c:	dc090913          	addi	s2,s2,-576 # 80099b18 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002d60:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002d62:	00005997          	auipc	s3,0x5
    80002d66:	6de98993          	addi	s3,s3,1758 # 80008440 <__func__.1+0x438>
        printf("%d <%s %s", p->pid, state, p->name);
    80002d6a:	00005a97          	auipc	s5,0x5
    80002d6e:	6dea8a93          	addi	s5,s5,1758 # 80008448 <__func__.1+0x440>
        printf("\n");
    80002d72:	00005a17          	auipc	s4,0x5
    80002d76:	2aea0a13          	addi	s4,s4,686 # 80008020 <__func__.1+0x18>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002d7a:	00006b97          	auipc	s7,0x6
    80002d7e:	cb6b8b93          	addi	s7,s7,-842 # 80008a30 <states.0>
    80002d82:	a00d                	j	80002da4 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002d84:	ed86a583          	lw	a1,-296(a3)
    80002d88:	8556                	mv	a0,s5
    80002d8a:	ffffe097          	auipc	ra,0xffffe
    80002d8e:	832080e7          	jalr	-1998(ra) # 800005bc <printf>
        printf("\n");
    80002d92:	8552                	mv	a0,s4
    80002d94:	ffffe097          	auipc	ra,0xffffe
    80002d98:	828080e7          	jalr	-2008(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002d9c:	16848493          	addi	s1,s1,360
    80002da0:	03248263          	beq	s1,s2,80002dc4 <procdump+0x9a>
        if (p->state == UNUSED)
    80002da4:	86a6                	mv	a3,s1
    80002da6:	ec04a783          	lw	a5,-320(s1)
    80002daa:	dbed                	beqz	a5,80002d9c <procdump+0x72>
            state = "???";
    80002dac:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002dae:	fcfb6be3          	bltu	s6,a5,80002d84 <procdump+0x5a>
    80002db2:	02079713          	slli	a4,a5,0x20
    80002db6:	01d75793          	srli	a5,a4,0x1d
    80002dba:	97de                	add	a5,a5,s7
    80002dbc:	6390                	ld	a2,0(a5)
    80002dbe:	f279                	bnez	a2,80002d84 <procdump+0x5a>
            state = "???";
    80002dc0:	864e                	mv	a2,s3
    80002dc2:	b7c9                	j	80002d84 <procdump+0x5a>
    }
}
    80002dc4:	60a6                	ld	ra,72(sp)
    80002dc6:	6406                	ld	s0,64(sp)
    80002dc8:	74e2                	ld	s1,56(sp)
    80002dca:	7942                	ld	s2,48(sp)
    80002dcc:	79a2                	ld	s3,40(sp)
    80002dce:	7a02                	ld	s4,32(sp)
    80002dd0:	6ae2                	ld	s5,24(sp)
    80002dd2:	6b42                	ld	s6,16(sp)
    80002dd4:	6ba2                	ld	s7,8(sp)
    80002dd6:	6161                	addi	sp,sp,80
    80002dd8:	8082                	ret

0000000080002dda <schedls>:

void schedls()
{
    80002dda:	1141                	addi	sp,sp,-16
    80002ddc:	e406                	sd	ra,8(sp)
    80002dde:	e022                	sd	s0,0(sp)
    80002de0:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002de2:	00005517          	auipc	a0,0x5
    80002de6:	67650513          	addi	a0,a0,1654 # 80008458 <__func__.1+0x450>
    80002dea:	ffffd097          	auipc	ra,0xffffd
    80002dee:	7d2080e7          	jalr	2002(ra) # 800005bc <printf>
    printf("====================================\n");
    80002df2:	00005517          	auipc	a0,0x5
    80002df6:	68e50513          	addi	a0,a0,1678 # 80008480 <__func__.1+0x478>
    80002dfa:	ffffd097          	auipc	ra,0xffffd
    80002dfe:	7c2080e7          	jalr	1986(ra) # 800005bc <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002e02:	00009717          	auipc	a4,0x9
    80002e06:	a7673703          	ld	a4,-1418(a4) # 8000b878 <available_schedulers+0x10>
    80002e0a:	00009797          	auipc	a5,0x9
    80002e0e:	a0e7b783          	ld	a5,-1522(a5) # 8000b818 <sched_pointer>
    80002e12:	04f70663          	beq	a4,a5,80002e5e <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002e16:	00005517          	auipc	a0,0x5
    80002e1a:	69a50513          	addi	a0,a0,1690 # 800084b0 <__func__.1+0x4a8>
    80002e1e:	ffffd097          	auipc	ra,0xffffd
    80002e22:	79e080e7          	jalr	1950(ra) # 800005bc <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002e26:	00009617          	auipc	a2,0x9
    80002e2a:	a5a62603          	lw	a2,-1446(a2) # 8000b880 <available_schedulers+0x18>
    80002e2e:	00009597          	auipc	a1,0x9
    80002e32:	a3a58593          	addi	a1,a1,-1478 # 8000b868 <available_schedulers>
    80002e36:	00005517          	auipc	a0,0x5
    80002e3a:	68250513          	addi	a0,a0,1666 # 800084b8 <__func__.1+0x4b0>
    80002e3e:	ffffd097          	auipc	ra,0xffffd
    80002e42:	77e080e7          	jalr	1918(ra) # 800005bc <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002e46:	00005517          	auipc	a0,0x5
    80002e4a:	67a50513          	addi	a0,a0,1658 # 800084c0 <__func__.1+0x4b8>
    80002e4e:	ffffd097          	auipc	ra,0xffffd
    80002e52:	76e080e7          	jalr	1902(ra) # 800005bc <printf>
}
    80002e56:	60a2                	ld	ra,8(sp)
    80002e58:	6402                	ld	s0,0(sp)
    80002e5a:	0141                	addi	sp,sp,16
    80002e5c:	8082                	ret
            printf("[*]\t");
    80002e5e:	00005517          	auipc	a0,0x5
    80002e62:	64a50513          	addi	a0,a0,1610 # 800084a8 <__func__.1+0x4a0>
    80002e66:	ffffd097          	auipc	ra,0xffffd
    80002e6a:	756080e7          	jalr	1878(ra) # 800005bc <printf>
    80002e6e:	bf65                	j	80002e26 <schedls+0x4c>

0000000080002e70 <schedset>:

void schedset(int id)
{
    80002e70:	1141                	addi	sp,sp,-16
    80002e72:	e406                	sd	ra,8(sp)
    80002e74:	e022                	sd	s0,0(sp)
    80002e76:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002e78:	e90d                	bnez	a0,80002eaa <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002e7a:	00009797          	auipc	a5,0x9
    80002e7e:	9fe7b783          	ld	a5,-1538(a5) # 8000b878 <available_schedulers+0x10>
    80002e82:	00009717          	auipc	a4,0x9
    80002e86:	98f73b23          	sd	a5,-1642(a4) # 8000b818 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002e8a:	00009597          	auipc	a1,0x9
    80002e8e:	9de58593          	addi	a1,a1,-1570 # 8000b868 <available_schedulers>
    80002e92:	00005517          	auipc	a0,0x5
    80002e96:	66e50513          	addi	a0,a0,1646 # 80008500 <__func__.1+0x4f8>
    80002e9a:	ffffd097          	auipc	ra,0xffffd
    80002e9e:	722080e7          	jalr	1826(ra) # 800005bc <printf>
    80002ea2:	60a2                	ld	ra,8(sp)
    80002ea4:	6402                	ld	s0,0(sp)
    80002ea6:	0141                	addi	sp,sp,16
    80002ea8:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002eaa:	00005517          	auipc	a0,0x5
    80002eae:	62e50513          	addi	a0,a0,1582 # 800084d8 <__func__.1+0x4d0>
    80002eb2:	ffffd097          	auipc	ra,0xffffd
    80002eb6:	70a080e7          	jalr	1802(ra) # 800005bc <printf>
        return;
    80002eba:	b7e5                	j	80002ea2 <schedset+0x32>

0000000080002ebc <swtch>:
    80002ebc:	00153023          	sd	ra,0(a0)
    80002ec0:	00253423          	sd	sp,8(a0)
    80002ec4:	e900                	sd	s0,16(a0)
    80002ec6:	ed04                	sd	s1,24(a0)
    80002ec8:	03253023          	sd	s2,32(a0)
    80002ecc:	03353423          	sd	s3,40(a0)
    80002ed0:	03453823          	sd	s4,48(a0)
    80002ed4:	03553c23          	sd	s5,56(a0)
    80002ed8:	05653023          	sd	s6,64(a0)
    80002edc:	05753423          	sd	s7,72(a0)
    80002ee0:	05853823          	sd	s8,80(a0)
    80002ee4:	05953c23          	sd	s9,88(a0)
    80002ee8:	07a53023          	sd	s10,96(a0)
    80002eec:	07b53423          	sd	s11,104(a0)
    80002ef0:	0005b083          	ld	ra,0(a1)
    80002ef4:	0085b103          	ld	sp,8(a1)
    80002ef8:	6980                	ld	s0,16(a1)
    80002efa:	6d84                	ld	s1,24(a1)
    80002efc:	0205b903          	ld	s2,32(a1)
    80002f00:	0285b983          	ld	s3,40(a1)
    80002f04:	0305ba03          	ld	s4,48(a1)
    80002f08:	0385ba83          	ld	s5,56(a1)
    80002f0c:	0405bb03          	ld	s6,64(a1)
    80002f10:	0485bb83          	ld	s7,72(a1)
    80002f14:	0505bc03          	ld	s8,80(a1)
    80002f18:	0585bc83          	ld	s9,88(a1)
    80002f1c:	0605bd03          	ld	s10,96(a1)
    80002f20:	0685bd83          	ld	s11,104(a1)
    80002f24:	8082                	ret

0000000080002f26 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002f26:	1141                	addi	sp,sp,-16
    80002f28:	e406                	sd	ra,8(sp)
    80002f2a:	e022                	sd	s0,0(sp)
    80002f2c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002f2e:	00005597          	auipc	a1,0x5
    80002f32:	62a58593          	addi	a1,a1,1578 # 80008558 <__func__.1+0x550>
    80002f36:	00097517          	auipc	a0,0x97
    80002f3a:	a8a50513          	addi	a0,a0,-1398 # 800999c0 <tickslock>
    80002f3e:	ffffe097          	auipc	ra,0xffffe
    80002f42:	d3c080e7          	jalr	-708(ra) # 80000c7a <initlock>
}
    80002f46:	60a2                	ld	ra,8(sp)
    80002f48:	6402                	ld	s0,0(sp)
    80002f4a:	0141                	addi	sp,sp,16
    80002f4c:	8082                	ret

0000000080002f4e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002f4e:	1141                	addi	sp,sp,-16
    80002f50:	e422                	sd	s0,8(sp)
    80002f52:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002f54:	00004797          	auipc	a5,0x4
    80002f58:	82c78793          	addi	a5,a5,-2004 # 80006780 <kernelvec>
    80002f5c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002f60:	6422                	ld	s0,8(sp)
    80002f62:	0141                	addi	sp,sp,16
    80002f64:	8082                	ret

0000000080002f66 <cow_fault>:
}


int
cow_fault(struct proc *p, uint64 fault_addr)
{
    80002f66:	7139                	addi	sp,sp,-64
    80002f68:	fc06                	sd	ra,56(sp)
    80002f6a:	f822                	sd	s0,48(sp)
    80002f6c:	f04a                	sd	s2,32(sp)
    80002f6e:	e05a                	sd	s6,0(sp)
    80002f70:	0080                	addi	s0,sp,64
    80002f72:	8b2a                	mv	s6,a0
    80002f74:	892e                	mv	s2,a1
  printf("I exist!");
    80002f76:	00005517          	auipc	a0,0x5
    80002f7a:	5ea50513          	addi	a0,a0,1514 # 80008560 <__func__.1+0x558>
    80002f7e:	ffffd097          	auipc	ra,0xffffd
    80002f82:	63e080e7          	jalr	1598(ra) # 800005bc <printf>
  // Round fault address down to page boundary.
  uint64 va = PGROUNDDOWN(fault_addr);
    80002f86:	77fd                	lui	a5,0xfffff
    80002f88:	00f97933          	and	s2,s2,a5
  pte_t *pte = walk(p->pagetable, va, 0);
    80002f8c:	4601                	li	a2,0
    80002f8e:	85ca                	mv	a1,s2
    80002f90:	050b3503          	ld	a0,80(s6)
    80002f94:	ffffe097          	auipc	ra,0xffffe
    80002f98:	156080e7          	jalr	342(ra) # 800010ea <walk>
  if(pte == 0 || !(*pte & PTE_V))
    80002f9c:	c171                	beqz	a0,80003060 <cow_fault+0xfa>
    80002f9e:	f426                	sd	s1,40(sp)
    80002fa0:	e456                	sd	s5,8(sp)
    80002fa2:	8aaa                	mv	s5,a0
    80002fa4:	6104                	ld	s1,0(a0)
    80002fa6:	0014f793          	andi	a5,s1,1
    80002faa:	cfcd                	beqz	a5,80003064 <cow_fault+0xfe>
    return -1;  // no valid mapping

  // Only handle pages shared via vfork:
  // Our convention is that such pages have the custom COW marker PTE_U and are not writable.
  if(((*pte & ~PTE_COW) == 0) || (*pte & PTE_W))
    80002fac:	dff4f793          	andi	a5,s1,-513
    80002fb0:	cfd5                	beqz	a5,8000306c <cow_fault+0x106>
    80002fb2:	0044f793          	andi	a5,s1,4
    80002fb6:	efdd                	bnez	a5,80003074 <cow_fault+0x10e>
    80002fb8:	ec4e                	sd	s3,24(sp)
    80002fba:	e852                	sd	s4,16(sp)
    return -1;  // not a vfork-shared COW page

  uint64 old_pa = PTE2PA(*pte);
    80002fbc:	00a4da13          	srli	s4,s1,0xa
    80002fc0:	0a32                	slli	s4,s4,0xc
  uint flags = PTE_FLAGS(*pte);
    80002fc2:	0004899b          	sext.w	s3,s1

  // Look up the reference count for the physical page.
  int ref_count = find_ref_count(old_pa);
    80002fc6:	8552                	mv	a0,s4
    80002fc8:	ffffe097          	auipc	ra,0xffffe
    80002fcc:	656080e7          	jalr	1622(ra) # 8000161e <find_ref_count>


  if(ref_count > 1){
    80002fd0:	4785                	li	a5,1
    80002fd2:	02a7ca63          	blt	a5,a0,80003006 <cow_fault+0xa0>
      return -1;
    }
  } else {
    // Only one reference exists.
    // Simply update the mapping in place: clear the COW flag and add write permission.
    *pte = PA2PTE(old_pa) | ((flags | PTE_W) & ~PTE_COW);
    80002fd6:	1ff9f993          	andi	s3,s3,511
    80002fda:	0049e993          	ori	s3,s3,4
    80002fde:	77fd                	lui	a5,0xfffff
    80002fe0:	8389                	srli	a5,a5,0x2
    80002fe2:	8cfd                	and	s1,s1,a5
    80002fe4:	0099e9b3          	or	s3,s3,s1
    80002fe8:	013ab023          	sd	s3,0(s5)
    asm volatile("sfence.vma zero, zero");
    80002fec:	12000073          	sfence.vma
  }

  // Flush the TLB so that the new mapping takes effect.
  sfence_vma();
  return 0;
    80002ff0:	4501                	li	a0,0
    80002ff2:	74a2                	ld	s1,40(sp)
    80002ff4:	69e2                	ld	s3,24(sp)
    80002ff6:	6a42                	ld	s4,16(sp)
    80002ff8:	6aa2                	ld	s5,8(sp)
}
    80002ffa:	70e2                	ld	ra,56(sp)
    80002ffc:	7442                	ld	s0,48(sp)
    80002ffe:	7902                	ld	s2,32(sp)
    80003000:	6b02                	ld	s6,0(sp)
    80003002:	6121                	addi	sp,sp,64
    80003004:	8082                	ret
    char *new_page = kalloc();
    80003006:	ffffe097          	auipc	ra,0xffffe
    8000300a:	bbe080e7          	jalr	-1090(ra) # 80000bc4 <kalloc>
    8000300e:	84aa                	mv	s1,a0
    if(new_page == 0)
    80003010:	c535                	beqz	a0,8000307c <cow_fault+0x116>
    memmove(new_page, (char *)old_pa, PGSIZE);
    80003012:	6605                	lui	a2,0x1
    80003014:	85d2                	mv	a1,s4
    80003016:	ffffe097          	auipc	ra,0xffffe
    8000301a:	e4c080e7          	jalr	-436(ra) # 80000e62 <memmove>
    uvmunmap(p->pagetable, va, 1);
    8000301e:	4605                	li	a2,1
    80003020:	85ca                	mv	a1,s2
    80003022:	050b3503          	ld	a0,80(s6)
    80003026:	ffffe097          	auipc	ra,0xffffe
    8000302a:	63e080e7          	jalr	1598(ra) # 80001664 <uvmunmap>
    if(mappages(p->pagetable, va, PGSIZE, (uint64)new_page,
    8000302e:	2009f713          	andi	a4,s3,512
    80003032:	00476713          	ori	a4,a4,4
    80003036:	86a6                	mv	a3,s1
    80003038:	6605                	lui	a2,0x1
    8000303a:	85ca                	mv	a1,s2
    8000303c:	050b3503          	ld	a0,80(s6)
    80003040:	ffffe097          	auipc	ra,0xffffe
    80003044:	2f6080e7          	jalr	758(ra) # 80001336 <mappages>
    80003048:	d155                	beqz	a0,80002fec <cow_fault+0x86>
      kfree(new_page);
    8000304a:	8526                	mv	a0,s1
    8000304c:	ffffe097          	auipc	ra,0xffffe
    80003050:	a10080e7          	jalr	-1520(ra) # 80000a5c <kfree>
      return -1;
    80003054:	557d                	li	a0,-1
    80003056:	74a2                	ld	s1,40(sp)
    80003058:	69e2                	ld	s3,24(sp)
    8000305a:	6a42                	ld	s4,16(sp)
    8000305c:	6aa2                	ld	s5,8(sp)
    8000305e:	bf71                	j	80002ffa <cow_fault+0x94>
    return -1;  // no valid mapping
    80003060:	557d                	li	a0,-1
    80003062:	bf61                	j	80002ffa <cow_fault+0x94>
    80003064:	557d                	li	a0,-1
    80003066:	74a2                	ld	s1,40(sp)
    80003068:	6aa2                	ld	s5,8(sp)
    8000306a:	bf41                	j	80002ffa <cow_fault+0x94>
    return -1;  // not a vfork-shared COW page
    8000306c:	557d                	li	a0,-1
    8000306e:	74a2                	ld	s1,40(sp)
    80003070:	6aa2                	ld	s5,8(sp)
    80003072:	b761                	j	80002ffa <cow_fault+0x94>
    80003074:	557d                	li	a0,-1
    80003076:	74a2                	ld	s1,40(sp)
    80003078:	6aa2                	ld	s5,8(sp)
    8000307a:	b741                	j	80002ffa <cow_fault+0x94>
      return -1;
    8000307c:	557d                	li	a0,-1
    8000307e:	74a2                	ld	s1,40(sp)
    80003080:	69e2                	ld	s3,24(sp)
    80003082:	6a42                	ld	s4,16(sp)
    80003084:	6aa2                	ld	s5,8(sp)
    80003086:	bf95                	j	80002ffa <cow_fault+0x94>

0000000080003088 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80003088:	1141                	addi	sp,sp,-16
    8000308a:	e406                	sd	ra,8(sp)
    8000308c:	e022                	sd	s0,0(sp)
    8000308e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003090:	fffff097          	auipc	ra,0xfffff
    80003094:	044080e7          	jalr	68(ra) # 800020d4 <myproc>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003098:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000309c:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    8000309e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800030a2:	00004697          	auipc	a3,0x4
    800030a6:	f5e68693          	addi	a3,a3,-162 # 80007000 <_trampoline>
    800030aa:	00004717          	auipc	a4,0x4
    800030ae:	f5670713          	addi	a4,a4,-170 # 80007000 <_trampoline>
    800030b2:	8f15                	sub	a4,a4,a3
    800030b4:	040007b7          	lui	a5,0x4000
    800030b8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800030ba:	07b2                	slli	a5,a5,0xc
    800030bc:	973e                	add	a4,a4,a5
    asm volatile("csrw stvec, %0" : : "r"(x));
    800030be:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800030c2:	6d38                	ld	a4,88(a0)
    asm volatile("csrr %0, satp" : "=r"(x));
    800030c4:	18002673          	csrr	a2,satp
    800030c8:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800030ca:	6d30                	ld	a2,88(a0)
    800030cc:	6138                	ld	a4,64(a0)
    800030ce:	6585                	lui	a1,0x1
    800030d0:	972e                	add	a4,a4,a1
    800030d2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800030d4:	6d38                	ld	a4,88(a0)
    800030d6:	00000617          	auipc	a2,0x0
    800030da:	13860613          	addi	a2,a2,312 # 8000320e <usertrap>
    800030de:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800030e0:	6d38                	ld	a4,88(a0)
    asm volatile("mv %0, tp" : "=r"(x));
    800030e2:	8612                	mv	a2,tp
    800030e4:	f310                	sd	a2,32(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    800030e6:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800030ea:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800030ee:	02076713          	ori	a4,a4,32
    asm volatile("csrw sstatus, %0" : : "r"(x));
    800030f2:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800030f6:	6d38                	ld	a4,88(a0)
    asm volatile("csrw sepc, %0" : : "r"(x));
    800030f8:	6f18                	ld	a4,24(a4)
    800030fa:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800030fe:	6928                	ld	a0,80(a0)
    80003100:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80003102:	00004717          	auipc	a4,0x4
    80003106:	f9a70713          	addi	a4,a4,-102 # 8000709c <userret>
    8000310a:	8f15                	sub	a4,a4,a3
    8000310c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000310e:	577d                	li	a4,-1
    80003110:	177e                	slli	a4,a4,0x3f
    80003112:	8d59                	or	a0,a0,a4
    80003114:	9782                	jalr	a5
}
    80003116:	60a2                	ld	ra,8(sp)
    80003118:	6402                	ld	s0,0(sp)
    8000311a:	0141                	addi	sp,sp,16
    8000311c:	8082                	ret

000000008000311e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000311e:	1101                	addi	sp,sp,-32
    80003120:	ec06                	sd	ra,24(sp)
    80003122:	e822                	sd	s0,16(sp)
    80003124:	e426                	sd	s1,8(sp)
    80003126:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003128:	00097497          	auipc	s1,0x97
    8000312c:	89848493          	addi	s1,s1,-1896 # 800999c0 <tickslock>
    80003130:	8526                	mv	a0,s1
    80003132:	ffffe097          	auipc	ra,0xffffe
    80003136:	bd8080e7          	jalr	-1064(ra) # 80000d0a <acquire>
  ticks++;
    8000313a:	00008517          	auipc	a0,0x8
    8000313e:	7b650513          	addi	a0,a0,1974 # 8000b8f0 <ticks>
    80003142:	411c                	lw	a5,0(a0)
    80003144:	2785                	addiw	a5,a5,1
    80003146:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003148:	fffff097          	auipc	ra,0xfffff
    8000314c:	792080e7          	jalr	1938(ra) # 800028da <wakeup>
  release(&tickslock);
    80003150:	8526                	mv	a0,s1
    80003152:	ffffe097          	auipc	ra,0xffffe
    80003156:	c6c080e7          	jalr	-916(ra) # 80000dbe <release>
}
    8000315a:	60e2                	ld	ra,24(sp)
    8000315c:	6442                	ld	s0,16(sp)
    8000315e:	64a2                	ld	s1,8(sp)
    80003160:	6105                	addi	sp,sp,32
    80003162:	8082                	ret

0000000080003164 <devintr>:
    asm volatile("csrr %0, scause" : "=r"(x));
    80003164:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80003168:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    8000316a:	0a07d163          	bgez	a5,8000320c <devintr+0xa8>
{
    8000316e:	1101                	addi	sp,sp,-32
    80003170:	ec06                	sd	ra,24(sp)
    80003172:	e822                	sd	s0,16(sp)
    80003174:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80003176:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    8000317a:	46a5                	li	a3,9
    8000317c:	00d70c63          	beq	a4,a3,80003194 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80003180:	577d                	li	a4,-1
    80003182:	177e                	slli	a4,a4,0x3f
    80003184:	0705                	addi	a4,a4,1
    return 0;
    80003186:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80003188:	06e78163          	beq	a5,a4,800031ea <devintr+0x86>
  }
}
    8000318c:	60e2                	ld	ra,24(sp)
    8000318e:	6442                	ld	s0,16(sp)
    80003190:	6105                	addi	sp,sp,32
    80003192:	8082                	ret
    80003194:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80003196:	00003097          	auipc	ra,0x3
    8000319a:	6f6080e7          	jalr	1782(ra) # 8000688c <plic_claim>
    8000319e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800031a0:	47a9                	li	a5,10
    800031a2:	00f50963          	beq	a0,a5,800031b4 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    800031a6:	4785                	li	a5,1
    800031a8:	00f50b63          	beq	a0,a5,800031be <devintr+0x5a>
    return 1;
    800031ac:	4505                	li	a0,1
    } else if(irq){
    800031ae:	ec89                	bnez	s1,800031c8 <devintr+0x64>
    800031b0:	64a2                	ld	s1,8(sp)
    800031b2:	bfe9                	j	8000318c <devintr+0x28>
      uartintr();
    800031b4:	ffffe097          	auipc	ra,0xffffe
    800031b8:	858080e7          	jalr	-1960(ra) # 80000a0c <uartintr>
    if(irq)
    800031bc:	a839                	j	800031da <devintr+0x76>
      virtio_disk_intr();
    800031be:	00004097          	auipc	ra,0x4
    800031c2:	bf8080e7          	jalr	-1032(ra) # 80006db6 <virtio_disk_intr>
    if(irq)
    800031c6:	a811                	j	800031da <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    800031c8:	85a6                	mv	a1,s1
    800031ca:	00005517          	auipc	a0,0x5
    800031ce:	3a650513          	addi	a0,a0,934 # 80008570 <__func__.1+0x568>
    800031d2:	ffffd097          	auipc	ra,0xffffd
    800031d6:	3ea080e7          	jalr	1002(ra) # 800005bc <printf>
      plic_complete(irq);
    800031da:	8526                	mv	a0,s1
    800031dc:	00003097          	auipc	ra,0x3
    800031e0:	6d4080e7          	jalr	1748(ra) # 800068b0 <plic_complete>
    return 1;
    800031e4:	4505                	li	a0,1
    800031e6:	64a2                	ld	s1,8(sp)
    800031e8:	b755                	j	8000318c <devintr+0x28>
    if(cpuid() == 0){
    800031ea:	fffff097          	auipc	ra,0xfffff
    800031ee:	ebe080e7          	jalr	-322(ra) # 800020a8 <cpuid>
    800031f2:	c901                	beqz	a0,80003202 <devintr+0x9e>
    asm volatile("csrr %0, sip" : "=r"(x));
    800031f4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800031f8:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip, %0" : : "r"(x));
    800031fa:	14479073          	csrw	sip,a5
    return 2;
    800031fe:	4509                	li	a0,2
    80003200:	b771                	j	8000318c <devintr+0x28>
      clockintr();
    80003202:	00000097          	auipc	ra,0x0
    80003206:	f1c080e7          	jalr	-228(ra) # 8000311e <clockintr>
    8000320a:	b7ed                	j	800031f4 <devintr+0x90>
}
    8000320c:	8082                	ret

000000008000320e <usertrap>:
{
    8000320e:	1101                	addi	sp,sp,-32
    80003210:	ec06                	sd	ra,24(sp)
    80003212:	e822                	sd	s0,16(sp)
    80003214:	e426                	sd	s1,8(sp)
    80003216:	e04a                	sd	s2,0(sp)
    80003218:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    8000321a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000321e:	1007f793          	andi	a5,a5,256
    80003222:	e7b9                	bnez	a5,80003270 <usertrap+0x62>
    asm volatile("csrw stvec, %0" : : "r"(x));
    80003224:	00003797          	auipc	a5,0x3
    80003228:	55c78793          	addi	a5,a5,1372 # 80006780 <kernelvec>
    8000322c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003230:	fffff097          	auipc	ra,0xfffff
    80003234:	ea4080e7          	jalr	-348(ra) # 800020d4 <myproc>
    80003238:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000323a:	6d3c                	ld	a5,88(a0)
    asm volatile("csrr %0, sepc" : "=r"(x));
    8000323c:	14102773          	csrr	a4,sepc
    80003240:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0, scause" : "=r"(x));
    80003242:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003246:	47a1                	li	a5,8
    80003248:	02f70c63          	beq	a4,a5,80003280 <usertrap+0x72>
    8000324c:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15){
    80003250:	47bd                	li	a5,15
    80003252:	08f70063          	beq	a4,a5,800032d2 <usertrap+0xc4>
  } else if((which_dev = devintr()) != 0){
    80003256:	00000097          	auipc	ra,0x0
    8000325a:	f0e080e7          	jalr	-242(ra) # 80003164 <devintr>
    8000325e:	892a                	mv	s2,a0
    80003260:	c545                	beqz	a0,80003308 <usertrap+0xfa>
  if(killed(p))
    80003262:	8526                	mv	a0,s1
    80003264:	00000097          	auipc	ra,0x0
    80003268:	8ba080e7          	jalr	-1862(ra) # 80002b1e <killed>
    8000326c:	c16d                	beqz	a0,8000334e <usertrap+0x140>
    8000326e:	a8d9                	j	80003344 <usertrap+0x136>
    panic("usertrap: not from user mode");
    80003270:	00005517          	auipc	a0,0x5
    80003274:	32050513          	addi	a0,a0,800 # 80008590 <__func__.1+0x588>
    80003278:	ffffd097          	auipc	ra,0xffffd
    8000327c:	2e8080e7          	jalr	744(ra) # 80000560 <panic>
    if(killed(p))
    80003280:	00000097          	auipc	ra,0x0
    80003284:	89e080e7          	jalr	-1890(ra) # 80002b1e <killed>
    80003288:	ed1d                	bnez	a0,800032c6 <usertrap+0xb8>
    p->trapframe->epc += 4;
    8000328a:	6cb8                	ld	a4,88(s1)
    8000328c:	6f1c                	ld	a5,24(a4)
    8000328e:	0791                	addi	a5,a5,4
    80003290:	ef1c                	sd	a5,24(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003292:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003296:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    8000329a:	10079073          	csrw	sstatus,a5
    syscall();
    8000329e:	00000097          	auipc	ra,0x0
    800032a2:	30a080e7          	jalr	778(ra) # 800035a8 <syscall>
  if(killed(p))
    800032a6:	8526                	mv	a0,s1
    800032a8:	00000097          	auipc	ra,0x0
    800032ac:	876080e7          	jalr	-1930(ra) # 80002b1e <killed>
    800032b0:	e949                	bnez	a0,80003342 <usertrap+0x134>
  usertrapret();
    800032b2:	00000097          	auipc	ra,0x0
    800032b6:	dd6080e7          	jalr	-554(ra) # 80003088 <usertrapret>
}
    800032ba:	60e2                	ld	ra,24(sp)
    800032bc:	6442                	ld	s0,16(sp)
    800032be:	64a2                	ld	s1,8(sp)
    800032c0:	6902                	ld	s2,0(sp)
    800032c2:	6105                	addi	sp,sp,32
    800032c4:	8082                	ret
      exit(-1);
    800032c6:	557d                	li	a0,-1
    800032c8:	fffff097          	auipc	ra,0xfffff
    800032cc:	6e2080e7          	jalr	1762(ra) # 800029aa <exit>
    800032d0:	bf6d                	j	8000328a <usertrap+0x7c>
    asm volatile("csrr %0, stval" : "=r"(x));
    800032d2:	14302973          	csrr	s2,stval
    if(cow_fault(p, fault_addr) < 0){
    800032d6:	85ca                	mv	a1,s2
    800032d8:	00000097          	auipc	ra,0x0
    800032dc:	c8e080e7          	jalr	-882(ra) # 80002f66 <cow_fault>
    800032e0:	fc0553e3          	bgez	a0,800032a6 <usertrap+0x98>
      p->killed = 1;
    800032e4:	4785                	li	a5,1
    800032e6:	d49c                	sw	a5,40(s1)
      printf("cow_fault failed for pid %d at va %p\n", p->pid, fault_addr);
    800032e8:	864a                	mv	a2,s2
    800032ea:	588c                	lw	a1,48(s1)
    800032ec:	00005517          	auipc	a0,0x5
    800032f0:	2c450513          	addi	a0,a0,708 # 800085b0 <__func__.1+0x5a8>
    800032f4:	ffffd097          	auipc	ra,0xffffd
    800032f8:	2c8080e7          	jalr	712(ra) # 800005bc <printf>
      setkilled(p);
    800032fc:	8526                	mv	a0,s1
    800032fe:	fffff097          	auipc	ra,0xfffff
    80003302:	7f4080e7          	jalr	2036(ra) # 80002af2 <setkilled>
    80003306:	b745                	j	800032a6 <usertrap+0x98>
    asm volatile("csrr %0, scause" : "=r"(x));
    80003308:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000330c:	5890                	lw	a2,48(s1)
    8000330e:	00005517          	auipc	a0,0x5
    80003312:	2ca50513          	addi	a0,a0,714 # 800085d8 <__func__.1+0x5d0>
    80003316:	ffffd097          	auipc	ra,0xffffd
    8000331a:	2a6080e7          	jalr	678(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    8000331e:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80003322:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003326:	00005517          	auipc	a0,0x5
    8000332a:	2e250513          	addi	a0,a0,738 # 80008608 <__func__.1+0x600>
    8000332e:	ffffd097          	auipc	ra,0xffffd
    80003332:	28e080e7          	jalr	654(ra) # 800005bc <printf>
    setkilled(p);
    80003336:	8526                	mv	a0,s1
    80003338:	fffff097          	auipc	ra,0xfffff
    8000333c:	7ba080e7          	jalr	1978(ra) # 80002af2 <setkilled>
    80003340:	b79d                	j	800032a6 <usertrap+0x98>
  if(killed(p))
    80003342:	4901                	li	s2,0
    exit(-1);
    80003344:	557d                	li	a0,-1
    80003346:	fffff097          	auipc	ra,0xfffff
    8000334a:	664080e7          	jalr	1636(ra) # 800029aa <exit>
  if(which_dev == 2)
    8000334e:	4789                	li	a5,2
    80003350:	f6f911e3          	bne	s2,a5,800032b2 <usertrap+0xa4>
    yield();
    80003354:	fffff097          	auipc	ra,0xfffff
    80003358:	4e6080e7          	jalr	1254(ra) # 8000283a <yield>
    8000335c:	bf99                	j	800032b2 <usertrap+0xa4>

000000008000335e <kerneltrap>:
{
    8000335e:	7179                	addi	sp,sp,-48
    80003360:	f406                	sd	ra,40(sp)
    80003362:	f022                	sd	s0,32(sp)
    80003364:	ec26                	sd	s1,24(sp)
    80003366:	e84a                	sd	s2,16(sp)
    80003368:	e44e                	sd	s3,8(sp)
    8000336a:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sepc" : "=r"(x));
    8000336c:	14102973          	csrr	s2,sepc
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003370:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0, scause" : "=r"(x));
    80003374:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003378:	1004f793          	andi	a5,s1,256
    8000337c:	cb85                	beqz	a5,800033ac <kerneltrap+0x4e>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    8000337e:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80003382:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003384:	ef85                	bnez	a5,800033bc <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	dde080e7          	jalr	-546(ra) # 80003164 <devintr>
    8000338e:	cd1d                	beqz	a0,800033cc <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003390:	4789                	li	a5,2
    80003392:	06f50a63          	beq	a0,a5,80003406 <kerneltrap+0xa8>
    asm volatile("csrw sepc, %0" : : "r"(x));
    80003396:	14191073          	csrw	sepc,s2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    8000339a:	10049073          	csrw	sstatus,s1
}
    8000339e:	70a2                	ld	ra,40(sp)
    800033a0:	7402                	ld	s0,32(sp)
    800033a2:	64e2                	ld	s1,24(sp)
    800033a4:	6942                	ld	s2,16(sp)
    800033a6:	69a2                	ld	s3,8(sp)
    800033a8:	6145                	addi	sp,sp,48
    800033aa:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800033ac:	00005517          	auipc	a0,0x5
    800033b0:	27c50513          	addi	a0,a0,636 # 80008628 <__func__.1+0x620>
    800033b4:	ffffd097          	auipc	ra,0xffffd
    800033b8:	1ac080e7          	jalr	428(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    800033bc:	00005517          	auipc	a0,0x5
    800033c0:	29450513          	addi	a0,a0,660 # 80008650 <__func__.1+0x648>
    800033c4:	ffffd097          	auipc	ra,0xffffd
    800033c8:	19c080e7          	jalr	412(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    800033cc:	85ce                	mv	a1,s3
    800033ce:	00005517          	auipc	a0,0x5
    800033d2:	2a250513          	addi	a0,a0,674 # 80008670 <__func__.1+0x668>
    800033d6:	ffffd097          	auipc	ra,0xffffd
    800033da:	1e6080e7          	jalr	486(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    800033de:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    800033e2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800033e6:	00005517          	auipc	a0,0x5
    800033ea:	29a50513          	addi	a0,a0,666 # 80008680 <__func__.1+0x678>
    800033ee:	ffffd097          	auipc	ra,0xffffd
    800033f2:	1ce080e7          	jalr	462(ra) # 800005bc <printf>
    panic("kerneltrap");
    800033f6:	00005517          	auipc	a0,0x5
    800033fa:	2a250513          	addi	a0,a0,674 # 80008698 <__func__.1+0x690>
    800033fe:	ffffd097          	auipc	ra,0xffffd
    80003402:	162080e7          	jalr	354(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003406:	fffff097          	auipc	ra,0xfffff
    8000340a:	cce080e7          	jalr	-818(ra) # 800020d4 <myproc>
    8000340e:	d541                	beqz	a0,80003396 <kerneltrap+0x38>
    80003410:	fffff097          	auipc	ra,0xfffff
    80003414:	cc4080e7          	jalr	-828(ra) # 800020d4 <myproc>
    80003418:	4d18                	lw	a4,24(a0)
    8000341a:	4791                	li	a5,4
    8000341c:	f6f71de3          	bne	a4,a5,80003396 <kerneltrap+0x38>
    yield();
    80003420:	fffff097          	auipc	ra,0xfffff
    80003424:	41a080e7          	jalr	1050(ra) # 8000283a <yield>
    80003428:	b7bd                	j	80003396 <kerneltrap+0x38>

000000008000342a <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    8000342a:	1101                	addi	sp,sp,-32
    8000342c:	ec06                	sd	ra,24(sp)
    8000342e:	e822                	sd	s0,16(sp)
    80003430:	e426                	sd	s1,8(sp)
    80003432:	1000                	addi	s0,sp,32
    80003434:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80003436:	fffff097          	auipc	ra,0xfffff
    8000343a:	c9e080e7          	jalr	-866(ra) # 800020d4 <myproc>
    switch (n)
    8000343e:	4795                	li	a5,5
    80003440:	0497e163          	bltu	a5,s1,80003482 <argraw+0x58>
    80003444:	048a                	slli	s1,s1,0x2
    80003446:	00005717          	auipc	a4,0x5
    8000344a:	61a70713          	addi	a4,a4,1562 # 80008a60 <states.0+0x30>
    8000344e:	94ba                	add	s1,s1,a4
    80003450:	409c                	lw	a5,0(s1)
    80003452:	97ba                	add	a5,a5,a4
    80003454:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80003456:	6d3c                	ld	a5,88(a0)
    80003458:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    8000345a:	60e2                	ld	ra,24(sp)
    8000345c:	6442                	ld	s0,16(sp)
    8000345e:	64a2                	ld	s1,8(sp)
    80003460:	6105                	addi	sp,sp,32
    80003462:	8082                	ret
        return p->trapframe->a1;
    80003464:	6d3c                	ld	a5,88(a0)
    80003466:	7fa8                	ld	a0,120(a5)
    80003468:	bfcd                	j	8000345a <argraw+0x30>
        return p->trapframe->a2;
    8000346a:	6d3c                	ld	a5,88(a0)
    8000346c:	63c8                	ld	a0,128(a5)
    8000346e:	b7f5                	j	8000345a <argraw+0x30>
        return p->trapframe->a3;
    80003470:	6d3c                	ld	a5,88(a0)
    80003472:	67c8                	ld	a0,136(a5)
    80003474:	b7dd                	j	8000345a <argraw+0x30>
        return p->trapframe->a4;
    80003476:	6d3c                	ld	a5,88(a0)
    80003478:	6bc8                	ld	a0,144(a5)
    8000347a:	b7c5                	j	8000345a <argraw+0x30>
        return p->trapframe->a5;
    8000347c:	6d3c                	ld	a5,88(a0)
    8000347e:	6fc8                	ld	a0,152(a5)
    80003480:	bfe9                	j	8000345a <argraw+0x30>
    panic("argraw");
    80003482:	00005517          	auipc	a0,0x5
    80003486:	22650513          	addi	a0,a0,550 # 800086a8 <__func__.1+0x6a0>
    8000348a:	ffffd097          	auipc	ra,0xffffd
    8000348e:	0d6080e7          	jalr	214(ra) # 80000560 <panic>

0000000080003492 <fetchaddr>:
{
    80003492:	1101                	addi	sp,sp,-32
    80003494:	ec06                	sd	ra,24(sp)
    80003496:	e822                	sd	s0,16(sp)
    80003498:	e426                	sd	s1,8(sp)
    8000349a:	e04a                	sd	s2,0(sp)
    8000349c:	1000                	addi	s0,sp,32
    8000349e:	84aa                	mv	s1,a0
    800034a0:	892e                	mv	s2,a1
    struct proc *p = myproc();
    800034a2:	fffff097          	auipc	ra,0xfffff
    800034a6:	c32080e7          	jalr	-974(ra) # 800020d4 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800034aa:	653c                	ld	a5,72(a0)
    800034ac:	02f4f863          	bgeu	s1,a5,800034dc <fetchaddr+0x4a>
    800034b0:	00848713          	addi	a4,s1,8
    800034b4:	02e7e663          	bltu	a5,a4,800034e0 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800034b8:	46a1                	li	a3,8
    800034ba:	8626                	mv	a2,s1
    800034bc:	85ca                	mv	a1,s2
    800034be:	6928                	ld	a0,80(a0)
    800034c0:	ffffe097          	auipc	ra,0xffffe
    800034c4:	76e080e7          	jalr	1902(ra) # 80001c2e <copyin>
    800034c8:	00a03533          	snez	a0,a0
    800034cc:	40a00533          	neg	a0,a0
}
    800034d0:	60e2                	ld	ra,24(sp)
    800034d2:	6442                	ld	s0,16(sp)
    800034d4:	64a2                	ld	s1,8(sp)
    800034d6:	6902                	ld	s2,0(sp)
    800034d8:	6105                	addi	sp,sp,32
    800034da:	8082                	ret
        return -1;
    800034dc:	557d                	li	a0,-1
    800034de:	bfcd                	j	800034d0 <fetchaddr+0x3e>
    800034e0:	557d                	li	a0,-1
    800034e2:	b7fd                	j	800034d0 <fetchaddr+0x3e>

00000000800034e4 <fetchstr>:
{
    800034e4:	7179                	addi	sp,sp,-48
    800034e6:	f406                	sd	ra,40(sp)
    800034e8:	f022                	sd	s0,32(sp)
    800034ea:	ec26                	sd	s1,24(sp)
    800034ec:	e84a                	sd	s2,16(sp)
    800034ee:	e44e                	sd	s3,8(sp)
    800034f0:	1800                	addi	s0,sp,48
    800034f2:	892a                	mv	s2,a0
    800034f4:	84ae                	mv	s1,a1
    800034f6:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    800034f8:	fffff097          	auipc	ra,0xfffff
    800034fc:	bdc080e7          	jalr	-1060(ra) # 800020d4 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80003500:	86ce                	mv	a3,s3
    80003502:	864a                	mv	a2,s2
    80003504:	85a6                	mv	a1,s1
    80003506:	6928                	ld	a0,80(a0)
    80003508:	ffffe097          	auipc	ra,0xffffe
    8000350c:	7b4080e7          	jalr	1972(ra) # 80001cbc <copyinstr>
    80003510:	00054e63          	bltz	a0,8000352c <fetchstr+0x48>
    return strlen(buf);
    80003514:	8526                	mv	a0,s1
    80003516:	ffffe097          	auipc	ra,0xffffe
    8000351a:	a64080e7          	jalr	-1436(ra) # 80000f7a <strlen>
}
    8000351e:	70a2                	ld	ra,40(sp)
    80003520:	7402                	ld	s0,32(sp)
    80003522:	64e2                	ld	s1,24(sp)
    80003524:	6942                	ld	s2,16(sp)
    80003526:	69a2                	ld	s3,8(sp)
    80003528:	6145                	addi	sp,sp,48
    8000352a:	8082                	ret
        return -1;
    8000352c:	557d                	li	a0,-1
    8000352e:	bfc5                	j	8000351e <fetchstr+0x3a>

0000000080003530 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003530:	1101                	addi	sp,sp,-32
    80003532:	ec06                	sd	ra,24(sp)
    80003534:	e822                	sd	s0,16(sp)
    80003536:	e426                	sd	s1,8(sp)
    80003538:	1000                	addi	s0,sp,32
    8000353a:	84ae                	mv	s1,a1
    *ip = argraw(n);
    8000353c:	00000097          	auipc	ra,0x0
    80003540:	eee080e7          	jalr	-274(ra) # 8000342a <argraw>
    80003544:	c088                	sw	a0,0(s1)
}
    80003546:	60e2                	ld	ra,24(sp)
    80003548:	6442                	ld	s0,16(sp)
    8000354a:	64a2                	ld	s1,8(sp)
    8000354c:	6105                	addi	sp,sp,32
    8000354e:	8082                	ret

0000000080003550 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003550:	1101                	addi	sp,sp,-32
    80003552:	ec06                	sd	ra,24(sp)
    80003554:	e822                	sd	s0,16(sp)
    80003556:	e426                	sd	s1,8(sp)
    80003558:	1000                	addi	s0,sp,32
    8000355a:	84ae                	mv	s1,a1
    *ip = argraw(n);
    8000355c:	00000097          	auipc	ra,0x0
    80003560:	ece080e7          	jalr	-306(ra) # 8000342a <argraw>
    80003564:	e088                	sd	a0,0(s1)
}
    80003566:	60e2                	ld	ra,24(sp)
    80003568:	6442                	ld	s0,16(sp)
    8000356a:	64a2                	ld	s1,8(sp)
    8000356c:	6105                	addi	sp,sp,32
    8000356e:	8082                	ret

0000000080003570 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80003570:	7179                	addi	sp,sp,-48
    80003572:	f406                	sd	ra,40(sp)
    80003574:	f022                	sd	s0,32(sp)
    80003576:	ec26                	sd	s1,24(sp)
    80003578:	e84a                	sd	s2,16(sp)
    8000357a:	1800                	addi	s0,sp,48
    8000357c:	84ae                	mv	s1,a1
    8000357e:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80003580:	fd840593          	addi	a1,s0,-40
    80003584:	00000097          	auipc	ra,0x0
    80003588:	fcc080e7          	jalr	-52(ra) # 80003550 <argaddr>
    return fetchstr(addr, buf, max);
    8000358c:	864a                	mv	a2,s2
    8000358e:	85a6                	mv	a1,s1
    80003590:	fd843503          	ld	a0,-40(s0)
    80003594:	00000097          	auipc	ra,0x0
    80003598:	f50080e7          	jalr	-176(ra) # 800034e4 <fetchstr>
}
    8000359c:	70a2                	ld	ra,40(sp)
    8000359e:	7402                	ld	s0,32(sp)
    800035a0:	64e2                	ld	s1,24(sp)
    800035a2:	6942                	ld	s2,16(sp)
    800035a4:	6145                	addi	sp,sp,48
    800035a6:	8082                	ret

00000000800035a8 <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    800035a8:	1101                	addi	sp,sp,-32
    800035aa:	ec06                	sd	ra,24(sp)
    800035ac:	e822                	sd	s0,16(sp)
    800035ae:	e426                	sd	s1,8(sp)
    800035b0:	e04a                	sd	s2,0(sp)
    800035b2:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    800035b4:	fffff097          	auipc	ra,0xfffff
    800035b8:	b20080e7          	jalr	-1248(ra) # 800020d4 <myproc>
    800035bc:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    800035be:	05853903          	ld	s2,88(a0)
    800035c2:	0a893783          	ld	a5,168(s2)
    800035c6:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800035ca:	37fd                	addiw	a5,a5,-1
    800035cc:	4765                	li	a4,25
    800035ce:	00f76f63          	bltu	a4,a5,800035ec <syscall+0x44>
    800035d2:	00369713          	slli	a4,a3,0x3
    800035d6:	00005797          	auipc	a5,0x5
    800035da:	4a278793          	addi	a5,a5,1186 # 80008a78 <syscalls>
    800035de:	97ba                	add	a5,a5,a4
    800035e0:	639c                	ld	a5,0(a5)
    800035e2:	c789                	beqz	a5,800035ec <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    800035e4:	9782                	jalr	a5
    800035e6:	06a93823          	sd	a0,112(s2)
    800035ea:	a839                	j	80003608 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    800035ec:	15848613          	addi	a2,s1,344
    800035f0:	588c                	lw	a1,48(s1)
    800035f2:	00005517          	auipc	a0,0x5
    800035f6:	0be50513          	addi	a0,a0,190 # 800086b0 <__func__.1+0x6a8>
    800035fa:	ffffd097          	auipc	ra,0xffffd
    800035fe:	fc2080e7          	jalr	-62(ra) # 800005bc <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80003602:	6cbc                	ld	a5,88(s1)
    80003604:	577d                	li	a4,-1
    80003606:	fbb8                	sd	a4,112(a5)
    }
}
    80003608:	60e2                	ld	ra,24(sp)
    8000360a:	6442                	ld	s0,16(sp)
    8000360c:	64a2                	ld	s1,8(sp)
    8000360e:	6902                	ld	s2,0(sp)
    80003610:	6105                	addi	sp,sp,32
    80003612:	8082                	ret

0000000080003614 <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    80003614:	1101                	addi	sp,sp,-32
    80003616:	ec06                	sd	ra,24(sp)
    80003618:	e822                	sd	s0,16(sp)
    8000361a:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    8000361c:	fec40593          	addi	a1,s0,-20
    80003620:	4501                	li	a0,0
    80003622:	00000097          	auipc	ra,0x0
    80003626:	f0e080e7          	jalr	-242(ra) # 80003530 <argint>
    exit(n);
    8000362a:	fec42503          	lw	a0,-20(s0)
    8000362e:	fffff097          	auipc	ra,0xfffff
    80003632:	37c080e7          	jalr	892(ra) # 800029aa <exit>
    return 0; // not reached
}
    80003636:	4501                	li	a0,0
    80003638:	60e2                	ld	ra,24(sp)
    8000363a:	6442                	ld	s0,16(sp)
    8000363c:	6105                	addi	sp,sp,32
    8000363e:	8082                	ret

0000000080003640 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003640:	1141                	addi	sp,sp,-16
    80003642:	e406                	sd	ra,8(sp)
    80003644:	e022                	sd	s0,0(sp)
    80003646:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80003648:	fffff097          	auipc	ra,0xfffff
    8000364c:	a8c080e7          	jalr	-1396(ra) # 800020d4 <myproc>
}
    80003650:	5908                	lw	a0,48(a0)
    80003652:	60a2                	ld	ra,8(sp)
    80003654:	6402                	ld	s0,0(sp)
    80003656:	0141                	addi	sp,sp,16
    80003658:	8082                	ret

000000008000365a <sys_fork>:

uint64
sys_fork(void)
{
    8000365a:	1141                	addi	sp,sp,-16
    8000365c:	e406                	sd	ra,8(sp)
    8000365e:	e022                	sd	s0,0(sp)
    80003660:	0800                	addi	s0,sp,16
    return fork();
    80003662:	fffff097          	auipc	ra,0xfffff
    80003666:	fba080e7          	jalr	-70(ra) # 8000261c <fork>
}
    8000366a:	60a2                	ld	ra,8(sp)
    8000366c:	6402                	ld	s0,0(sp)
    8000366e:	0141                	addi	sp,sp,16
    80003670:	8082                	ret

0000000080003672 <sys_wait>:

uint64
sys_wait(void)
{
    80003672:	1101                	addi	sp,sp,-32
    80003674:	ec06                	sd	ra,24(sp)
    80003676:	e822                	sd	s0,16(sp)
    80003678:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    8000367a:	fe840593          	addi	a1,s0,-24
    8000367e:	4501                	li	a0,0
    80003680:	00000097          	auipc	ra,0x0
    80003684:	ed0080e7          	jalr	-304(ra) # 80003550 <argaddr>
    return wait(p);
    80003688:	fe843503          	ld	a0,-24(s0)
    8000368c:	fffff097          	auipc	ra,0xfffff
    80003690:	4c4080e7          	jalr	1220(ra) # 80002b50 <wait>
}
    80003694:	60e2                	ld	ra,24(sp)
    80003696:	6442                	ld	s0,16(sp)
    80003698:	6105                	addi	sp,sp,32
    8000369a:	8082                	ret

000000008000369c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000369c:	7179                	addi	sp,sp,-48
    8000369e:	f406                	sd	ra,40(sp)
    800036a0:	f022                	sd	s0,32(sp)
    800036a2:	ec26                	sd	s1,24(sp)
    800036a4:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    800036a6:	fdc40593          	addi	a1,s0,-36
    800036aa:	4501                	li	a0,0
    800036ac:	00000097          	auipc	ra,0x0
    800036b0:	e84080e7          	jalr	-380(ra) # 80003530 <argint>
    addr = myproc()->sz;
    800036b4:	fffff097          	auipc	ra,0xfffff
    800036b8:	a20080e7          	jalr	-1504(ra) # 800020d4 <myproc>
    800036bc:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    800036be:	fdc42503          	lw	a0,-36(s0)
    800036c2:	fffff097          	auipc	ra,0xfffff
    800036c6:	d66080e7          	jalr	-666(ra) # 80002428 <growproc>
    800036ca:	00054863          	bltz	a0,800036da <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    800036ce:	8526                	mv	a0,s1
    800036d0:	70a2                	ld	ra,40(sp)
    800036d2:	7402                	ld	s0,32(sp)
    800036d4:	64e2                	ld	s1,24(sp)
    800036d6:	6145                	addi	sp,sp,48
    800036d8:	8082                	ret
        return -1;
    800036da:	54fd                	li	s1,-1
    800036dc:	bfcd                	j	800036ce <sys_sbrk+0x32>

00000000800036de <sys_sleep>:

uint64
sys_sleep(void)
{
    800036de:	7139                	addi	sp,sp,-64
    800036e0:	fc06                	sd	ra,56(sp)
    800036e2:	f822                	sd	s0,48(sp)
    800036e4:	f04a                	sd	s2,32(sp)
    800036e6:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    800036e8:	fcc40593          	addi	a1,s0,-52
    800036ec:	4501                	li	a0,0
    800036ee:	00000097          	auipc	ra,0x0
    800036f2:	e42080e7          	jalr	-446(ra) # 80003530 <argint>
    acquire(&tickslock);
    800036f6:	00096517          	auipc	a0,0x96
    800036fa:	2ca50513          	addi	a0,a0,714 # 800999c0 <tickslock>
    800036fe:	ffffd097          	auipc	ra,0xffffd
    80003702:	60c080e7          	jalr	1548(ra) # 80000d0a <acquire>
    ticks0 = ticks;
    80003706:	00008917          	auipc	s2,0x8
    8000370a:	1ea92903          	lw	s2,490(s2) # 8000b8f0 <ticks>
    while (ticks - ticks0 < n)
    8000370e:	fcc42783          	lw	a5,-52(s0)
    80003712:	c3b9                	beqz	a5,80003758 <sys_sleep+0x7a>
    80003714:	f426                	sd	s1,40(sp)
    80003716:	ec4e                	sd	s3,24(sp)
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    80003718:	00096997          	auipc	s3,0x96
    8000371c:	2a898993          	addi	s3,s3,680 # 800999c0 <tickslock>
    80003720:	00008497          	auipc	s1,0x8
    80003724:	1d048493          	addi	s1,s1,464 # 8000b8f0 <ticks>
        if (killed(myproc()))
    80003728:	fffff097          	auipc	ra,0xfffff
    8000372c:	9ac080e7          	jalr	-1620(ra) # 800020d4 <myproc>
    80003730:	fffff097          	auipc	ra,0xfffff
    80003734:	3ee080e7          	jalr	1006(ra) # 80002b1e <killed>
    80003738:	ed15                	bnez	a0,80003774 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    8000373a:	85ce                	mv	a1,s3
    8000373c:	8526                	mv	a0,s1
    8000373e:	fffff097          	auipc	ra,0xfffff
    80003742:	138080e7          	jalr	312(ra) # 80002876 <sleep>
    while (ticks - ticks0 < n)
    80003746:	409c                	lw	a5,0(s1)
    80003748:	412787bb          	subw	a5,a5,s2
    8000374c:	fcc42703          	lw	a4,-52(s0)
    80003750:	fce7ece3          	bltu	a5,a4,80003728 <sys_sleep+0x4a>
    80003754:	74a2                	ld	s1,40(sp)
    80003756:	69e2                	ld	s3,24(sp)
    }
    release(&tickslock);
    80003758:	00096517          	auipc	a0,0x96
    8000375c:	26850513          	addi	a0,a0,616 # 800999c0 <tickslock>
    80003760:	ffffd097          	auipc	ra,0xffffd
    80003764:	65e080e7          	jalr	1630(ra) # 80000dbe <release>
    return 0;
    80003768:	4501                	li	a0,0
}
    8000376a:	70e2                	ld	ra,56(sp)
    8000376c:	7442                	ld	s0,48(sp)
    8000376e:	7902                	ld	s2,32(sp)
    80003770:	6121                	addi	sp,sp,64
    80003772:	8082                	ret
            release(&tickslock);
    80003774:	00096517          	auipc	a0,0x96
    80003778:	24c50513          	addi	a0,a0,588 # 800999c0 <tickslock>
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	642080e7          	jalr	1602(ra) # 80000dbe <release>
            return -1;
    80003784:	557d                	li	a0,-1
    80003786:	74a2                	ld	s1,40(sp)
    80003788:	69e2                	ld	s3,24(sp)
    8000378a:	b7c5                	j	8000376a <sys_sleep+0x8c>

000000008000378c <sys_kill>:

uint64
sys_kill(void)
{
    8000378c:	1101                	addi	sp,sp,-32
    8000378e:	ec06                	sd	ra,24(sp)
    80003790:	e822                	sd	s0,16(sp)
    80003792:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    80003794:	fec40593          	addi	a1,s0,-20
    80003798:	4501                	li	a0,0
    8000379a:	00000097          	auipc	ra,0x0
    8000379e:	d96080e7          	jalr	-618(ra) # 80003530 <argint>
    return kill(pid);
    800037a2:	fec42503          	lw	a0,-20(s0)
    800037a6:	fffff097          	auipc	ra,0xfffff
    800037aa:	2da080e7          	jalr	730(ra) # 80002a80 <kill>
}
    800037ae:	60e2                	ld	ra,24(sp)
    800037b0:	6442                	ld	s0,16(sp)
    800037b2:	6105                	addi	sp,sp,32
    800037b4:	8082                	ret

00000000800037b6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800037b6:	1101                	addi	sp,sp,-32
    800037b8:	ec06                	sd	ra,24(sp)
    800037ba:	e822                	sd	s0,16(sp)
    800037bc:	e426                	sd	s1,8(sp)
    800037be:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    800037c0:	00096517          	auipc	a0,0x96
    800037c4:	20050513          	addi	a0,a0,512 # 800999c0 <tickslock>
    800037c8:	ffffd097          	auipc	ra,0xffffd
    800037cc:	542080e7          	jalr	1346(ra) # 80000d0a <acquire>
    xticks = ticks;
    800037d0:	00008497          	auipc	s1,0x8
    800037d4:	1204a483          	lw	s1,288(s1) # 8000b8f0 <ticks>
    release(&tickslock);
    800037d8:	00096517          	auipc	a0,0x96
    800037dc:	1e850513          	addi	a0,a0,488 # 800999c0 <tickslock>
    800037e0:	ffffd097          	auipc	ra,0xffffd
    800037e4:	5de080e7          	jalr	1502(ra) # 80000dbe <release>
    return xticks;
}
    800037e8:	02049513          	slli	a0,s1,0x20
    800037ec:	9101                	srli	a0,a0,0x20
    800037ee:	60e2                	ld	ra,24(sp)
    800037f0:	6442                	ld	s0,16(sp)
    800037f2:	64a2                	ld	s1,8(sp)
    800037f4:	6105                	addi	sp,sp,32
    800037f6:	8082                	ret

00000000800037f8 <sys_ps>:

void *
sys_ps(void)
{
    800037f8:	1101                	addi	sp,sp,-32
    800037fa:	ec06                	sd	ra,24(sp)
    800037fc:	e822                	sd	s0,16(sp)
    800037fe:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    80003800:	fe042623          	sw	zero,-20(s0)
    80003804:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    80003808:	fec40593          	addi	a1,s0,-20
    8000380c:	4501                	li	a0,0
    8000380e:	00000097          	auipc	ra,0x0
    80003812:	d22080e7          	jalr	-734(ra) # 80003530 <argint>
    argint(1, &count);
    80003816:	fe840593          	addi	a1,s0,-24
    8000381a:	4505                	li	a0,1
    8000381c:	00000097          	auipc	ra,0x0
    80003820:	d14080e7          	jalr	-748(ra) # 80003530 <argint>
    return ps((uint8)start, (uint8)count);
    80003824:	fe844583          	lbu	a1,-24(s0)
    80003828:	fec44503          	lbu	a0,-20(s0)
    8000382c:	fffff097          	auipc	ra,0xfffff
    80003830:	c58080e7          	jalr	-936(ra) # 80002484 <ps>
}
    80003834:	60e2                	ld	ra,24(sp)
    80003836:	6442                	ld	s0,16(sp)
    80003838:	6105                	addi	sp,sp,32
    8000383a:	8082                	ret

000000008000383c <sys_schedls>:

uint64 sys_schedls(void)
{
    8000383c:	1141                	addi	sp,sp,-16
    8000383e:	e406                	sd	ra,8(sp)
    80003840:	e022                	sd	s0,0(sp)
    80003842:	0800                	addi	s0,sp,16
    schedls();
    80003844:	fffff097          	auipc	ra,0xfffff
    80003848:	596080e7          	jalr	1430(ra) # 80002dda <schedls>
    return 0;
}
    8000384c:	4501                	li	a0,0
    8000384e:	60a2                	ld	ra,8(sp)
    80003850:	6402                	ld	s0,0(sp)
    80003852:	0141                	addi	sp,sp,16
    80003854:	8082                	ret

0000000080003856 <sys_schedset>:

uint64 sys_schedset(void)
{
    80003856:	1101                	addi	sp,sp,-32
    80003858:	ec06                	sd	ra,24(sp)
    8000385a:	e822                	sd	s0,16(sp)
    8000385c:	1000                	addi	s0,sp,32
    int id = 0;
    8000385e:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    80003862:	fec40593          	addi	a1,s0,-20
    80003866:	4501                	li	a0,0
    80003868:	00000097          	auipc	ra,0x0
    8000386c:	cc8080e7          	jalr	-824(ra) # 80003530 <argint>
    schedset(id - 1);
    80003870:	fec42503          	lw	a0,-20(s0)
    80003874:	357d                	addiw	a0,a0,-1
    80003876:	fffff097          	auipc	ra,0xfffff
    8000387a:	5fa080e7          	jalr	1530(ra) # 80002e70 <schedset>
    return 0;
}
    8000387e:	4501                	li	a0,0
    80003880:	60e2                	ld	ra,24(sp)
    80003882:	6442                	ld	s0,16(sp)
    80003884:	6105                	addi	sp,sp,32
    80003886:	8082                	ret

0000000080003888 <sys_va2pa>:

uint64 sys_va2pa(void)
{
    80003888:	7179                	addi	sp,sp,-48
    8000388a:	f406                	sd	ra,40(sp)
    8000388c:	f022                	sd	s0,32(sp)
    8000388e:	1800                	addi	s0,sp,48
    struct proc* proc;
    uint64 va, pid = 0;
    80003890:	fc043823          	sd	zero,-48(s0)

    argaddr(0, &va);
    80003894:	fd840593          	addi	a1,s0,-40
    80003898:	4501                	li	a0,0
    8000389a:	00000097          	auipc	ra,0x0
    8000389e:	cb6080e7          	jalr	-842(ra) # 80003550 <argaddr>
    argaddr(1, &pid);
    800038a2:	fd040593          	addi	a1,s0,-48
    800038a6:	4505                	li	a0,1
    800038a8:	00000097          	auipc	ra,0x0
    800038ac:	ca8080e7          	jalr	-856(ra) # 80003550 <argaddr>

    if (pid == 0){
    800038b0:	fd043783          	ld	a5,-48(s0)
    800038b4:	cf89                	beqz	a5,800038ce <sys_va2pa+0x46>
        acquire(&proc->lock);
        pid = proc->pid;
        release(&proc->lock);
    }
    
    return va2pa(va, pid);
    800038b6:	fd043583          	ld	a1,-48(s0)
    800038ba:	fd843503          	ld	a0,-40(s0)
    800038be:	ffffe097          	auipc	ra,0xffffe
    800038c2:	714080e7          	jalr	1812(ra) # 80001fd2 <va2pa>
}
    800038c6:	70a2                	ld	ra,40(sp)
    800038c8:	7402                	ld	s0,32(sp)
    800038ca:	6145                	addi	sp,sp,48
    800038cc:	8082                	ret
    800038ce:	ec26                	sd	s1,24(sp)
        proc = myproc();
    800038d0:	fffff097          	auipc	ra,0xfffff
    800038d4:	804080e7          	jalr	-2044(ra) # 800020d4 <myproc>
    800038d8:	84aa                	mv	s1,a0
        acquire(&proc->lock);
    800038da:	ffffd097          	auipc	ra,0xffffd
    800038de:	430080e7          	jalr	1072(ra) # 80000d0a <acquire>
        pid = proc->pid;
    800038e2:	589c                	lw	a5,48(s1)
    800038e4:	fcf43823          	sd	a5,-48(s0)
        release(&proc->lock);
    800038e8:	8526                	mv	a0,s1
    800038ea:	ffffd097          	auipc	ra,0xffffd
    800038ee:	4d4080e7          	jalr	1236(ra) # 80000dbe <release>
    800038f2:	64e2                	ld	s1,24(sp)
    800038f4:	b7c9                	j	800038b6 <sys_va2pa+0x2e>

00000000800038f6 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    800038f6:	1141                	addi	sp,sp,-16
    800038f8:	e406                	sd	ra,8(sp)
    800038fa:	e022                	sd	s0,0(sp)
    800038fc:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    800038fe:	00008597          	auipc	a1,0x8
    80003902:	fca5b583          	ld	a1,-54(a1) # 8000b8c8 <FREE_PAGES>
    80003906:	00005517          	auipc	a0,0x5
    8000390a:	dca50513          	addi	a0,a0,-566 # 800086d0 <__func__.1+0x6c8>
    8000390e:	ffffd097          	auipc	ra,0xffffd
    80003912:	cae080e7          	jalr	-850(ra) # 800005bc <printf>
    return 0;
    80003916:	4501                	li	a0,0
    80003918:	60a2                	ld	ra,8(sp)
    8000391a:	6402                	ld	s0,0(sp)
    8000391c:	0141                	addi	sp,sp,16
    8000391e:	8082                	ret

0000000080003920 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003920:	7179                	addi	sp,sp,-48
    80003922:	f406                	sd	ra,40(sp)
    80003924:	f022                	sd	s0,32(sp)
    80003926:	ec26                	sd	s1,24(sp)
    80003928:	e84a                	sd	s2,16(sp)
    8000392a:	e44e                	sd	s3,8(sp)
    8000392c:	e052                	sd	s4,0(sp)
    8000392e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003930:	00005597          	auipc	a1,0x5
    80003934:	da858593          	addi	a1,a1,-600 # 800086d8 <__func__.1+0x6d0>
    80003938:	00096517          	auipc	a0,0x96
    8000393c:	0a050513          	addi	a0,a0,160 # 800999d8 <bcache>
    80003940:	ffffd097          	auipc	ra,0xffffd
    80003944:	33a080e7          	jalr	826(ra) # 80000c7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003948:	0009e797          	auipc	a5,0x9e
    8000394c:	09078793          	addi	a5,a5,144 # 800a19d8 <bcache+0x8000>
    80003950:	0009e717          	auipc	a4,0x9e
    80003954:	2f070713          	addi	a4,a4,752 # 800a1c40 <bcache+0x8268>
    80003958:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000395c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003960:	00096497          	auipc	s1,0x96
    80003964:	09048493          	addi	s1,s1,144 # 800999f0 <bcache+0x18>
    b->next = bcache.head.next;
    80003968:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000396a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000396c:	00005a17          	auipc	s4,0x5
    80003970:	d74a0a13          	addi	s4,s4,-652 # 800086e0 <__func__.1+0x6d8>
    b->next = bcache.head.next;
    80003974:	2b893783          	ld	a5,696(s2)
    80003978:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000397a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000397e:	85d2                	mv	a1,s4
    80003980:	01048513          	addi	a0,s1,16
    80003984:	00001097          	auipc	ra,0x1
    80003988:	4e8080e7          	jalr	1256(ra) # 80004e6c <initsleeplock>
    bcache.head.next->prev = b;
    8000398c:	2b893783          	ld	a5,696(s2)
    80003990:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003992:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003996:	45848493          	addi	s1,s1,1112
    8000399a:	fd349de3          	bne	s1,s3,80003974 <binit+0x54>
  }
}
    8000399e:	70a2                	ld	ra,40(sp)
    800039a0:	7402                	ld	s0,32(sp)
    800039a2:	64e2                	ld	s1,24(sp)
    800039a4:	6942                	ld	s2,16(sp)
    800039a6:	69a2                	ld	s3,8(sp)
    800039a8:	6a02                	ld	s4,0(sp)
    800039aa:	6145                	addi	sp,sp,48
    800039ac:	8082                	ret

00000000800039ae <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800039ae:	7179                	addi	sp,sp,-48
    800039b0:	f406                	sd	ra,40(sp)
    800039b2:	f022                	sd	s0,32(sp)
    800039b4:	ec26                	sd	s1,24(sp)
    800039b6:	e84a                	sd	s2,16(sp)
    800039b8:	e44e                	sd	s3,8(sp)
    800039ba:	1800                	addi	s0,sp,48
    800039bc:	892a                	mv	s2,a0
    800039be:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800039c0:	00096517          	auipc	a0,0x96
    800039c4:	01850513          	addi	a0,a0,24 # 800999d8 <bcache>
    800039c8:	ffffd097          	auipc	ra,0xffffd
    800039cc:	342080e7          	jalr	834(ra) # 80000d0a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800039d0:	0009e497          	auipc	s1,0x9e
    800039d4:	2c04b483          	ld	s1,704(s1) # 800a1c90 <bcache+0x82b8>
    800039d8:	0009e797          	auipc	a5,0x9e
    800039dc:	26878793          	addi	a5,a5,616 # 800a1c40 <bcache+0x8268>
    800039e0:	02f48f63          	beq	s1,a5,80003a1e <bread+0x70>
    800039e4:	873e                	mv	a4,a5
    800039e6:	a021                	j	800039ee <bread+0x40>
    800039e8:	68a4                	ld	s1,80(s1)
    800039ea:	02e48a63          	beq	s1,a4,80003a1e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800039ee:	449c                	lw	a5,8(s1)
    800039f0:	ff279ce3          	bne	a5,s2,800039e8 <bread+0x3a>
    800039f4:	44dc                	lw	a5,12(s1)
    800039f6:	ff3799e3          	bne	a5,s3,800039e8 <bread+0x3a>
      b->refcnt++;
    800039fa:	40bc                	lw	a5,64(s1)
    800039fc:	2785                	addiw	a5,a5,1
    800039fe:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003a00:	00096517          	auipc	a0,0x96
    80003a04:	fd850513          	addi	a0,a0,-40 # 800999d8 <bcache>
    80003a08:	ffffd097          	auipc	ra,0xffffd
    80003a0c:	3b6080e7          	jalr	950(ra) # 80000dbe <release>
      acquiresleep(&b->lock);
    80003a10:	01048513          	addi	a0,s1,16
    80003a14:	00001097          	auipc	ra,0x1
    80003a18:	492080e7          	jalr	1170(ra) # 80004ea6 <acquiresleep>
      return b;
    80003a1c:	a8b9                	j	80003a7a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003a1e:	0009e497          	auipc	s1,0x9e
    80003a22:	26a4b483          	ld	s1,618(s1) # 800a1c88 <bcache+0x82b0>
    80003a26:	0009e797          	auipc	a5,0x9e
    80003a2a:	21a78793          	addi	a5,a5,538 # 800a1c40 <bcache+0x8268>
    80003a2e:	00f48863          	beq	s1,a5,80003a3e <bread+0x90>
    80003a32:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003a34:	40bc                	lw	a5,64(s1)
    80003a36:	cf81                	beqz	a5,80003a4e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003a38:	64a4                	ld	s1,72(s1)
    80003a3a:	fee49de3          	bne	s1,a4,80003a34 <bread+0x86>
  panic("bget: no buffers");
    80003a3e:	00005517          	auipc	a0,0x5
    80003a42:	caa50513          	addi	a0,a0,-854 # 800086e8 <__func__.1+0x6e0>
    80003a46:	ffffd097          	auipc	ra,0xffffd
    80003a4a:	b1a080e7          	jalr	-1254(ra) # 80000560 <panic>
      b->dev = dev;
    80003a4e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003a52:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003a56:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003a5a:	4785                	li	a5,1
    80003a5c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003a5e:	00096517          	auipc	a0,0x96
    80003a62:	f7a50513          	addi	a0,a0,-134 # 800999d8 <bcache>
    80003a66:	ffffd097          	auipc	ra,0xffffd
    80003a6a:	358080e7          	jalr	856(ra) # 80000dbe <release>
      acquiresleep(&b->lock);
    80003a6e:	01048513          	addi	a0,s1,16
    80003a72:	00001097          	auipc	ra,0x1
    80003a76:	434080e7          	jalr	1076(ra) # 80004ea6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003a7a:	409c                	lw	a5,0(s1)
    80003a7c:	cb89                	beqz	a5,80003a8e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003a7e:	8526                	mv	a0,s1
    80003a80:	70a2                	ld	ra,40(sp)
    80003a82:	7402                	ld	s0,32(sp)
    80003a84:	64e2                	ld	s1,24(sp)
    80003a86:	6942                	ld	s2,16(sp)
    80003a88:	69a2                	ld	s3,8(sp)
    80003a8a:	6145                	addi	sp,sp,48
    80003a8c:	8082                	ret
    virtio_disk_rw(b, 0);
    80003a8e:	4581                	li	a1,0
    80003a90:	8526                	mv	a0,s1
    80003a92:	00003097          	auipc	ra,0x3
    80003a96:	0f6080e7          	jalr	246(ra) # 80006b88 <virtio_disk_rw>
    b->valid = 1;
    80003a9a:	4785                	li	a5,1
    80003a9c:	c09c                	sw	a5,0(s1)
  return b;
    80003a9e:	b7c5                	j	80003a7e <bread+0xd0>

0000000080003aa0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003aa0:	1101                	addi	sp,sp,-32
    80003aa2:	ec06                	sd	ra,24(sp)
    80003aa4:	e822                	sd	s0,16(sp)
    80003aa6:	e426                	sd	s1,8(sp)
    80003aa8:	1000                	addi	s0,sp,32
    80003aaa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003aac:	0541                	addi	a0,a0,16
    80003aae:	00001097          	auipc	ra,0x1
    80003ab2:	492080e7          	jalr	1170(ra) # 80004f40 <holdingsleep>
    80003ab6:	cd01                	beqz	a0,80003ace <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003ab8:	4585                	li	a1,1
    80003aba:	8526                	mv	a0,s1
    80003abc:	00003097          	auipc	ra,0x3
    80003ac0:	0cc080e7          	jalr	204(ra) # 80006b88 <virtio_disk_rw>
}
    80003ac4:	60e2                	ld	ra,24(sp)
    80003ac6:	6442                	ld	s0,16(sp)
    80003ac8:	64a2                	ld	s1,8(sp)
    80003aca:	6105                	addi	sp,sp,32
    80003acc:	8082                	ret
    panic("bwrite");
    80003ace:	00005517          	auipc	a0,0x5
    80003ad2:	c3250513          	addi	a0,a0,-974 # 80008700 <__func__.1+0x6f8>
    80003ad6:	ffffd097          	auipc	ra,0xffffd
    80003ada:	a8a080e7          	jalr	-1398(ra) # 80000560 <panic>

0000000080003ade <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003ade:	1101                	addi	sp,sp,-32
    80003ae0:	ec06                	sd	ra,24(sp)
    80003ae2:	e822                	sd	s0,16(sp)
    80003ae4:	e426                	sd	s1,8(sp)
    80003ae6:	e04a                	sd	s2,0(sp)
    80003ae8:	1000                	addi	s0,sp,32
    80003aea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003aec:	01050913          	addi	s2,a0,16
    80003af0:	854a                	mv	a0,s2
    80003af2:	00001097          	auipc	ra,0x1
    80003af6:	44e080e7          	jalr	1102(ra) # 80004f40 <holdingsleep>
    80003afa:	c925                	beqz	a0,80003b6a <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003afc:	854a                	mv	a0,s2
    80003afe:	00001097          	auipc	ra,0x1
    80003b02:	3fe080e7          	jalr	1022(ra) # 80004efc <releasesleep>

  acquire(&bcache.lock);
    80003b06:	00096517          	auipc	a0,0x96
    80003b0a:	ed250513          	addi	a0,a0,-302 # 800999d8 <bcache>
    80003b0e:	ffffd097          	auipc	ra,0xffffd
    80003b12:	1fc080e7          	jalr	508(ra) # 80000d0a <acquire>
  b->refcnt--;
    80003b16:	40bc                	lw	a5,64(s1)
    80003b18:	37fd                	addiw	a5,a5,-1
    80003b1a:	0007871b          	sext.w	a4,a5
    80003b1e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003b20:	e71d                	bnez	a4,80003b4e <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003b22:	68b8                	ld	a4,80(s1)
    80003b24:	64bc                	ld	a5,72(s1)
    80003b26:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003b28:	68b8                	ld	a4,80(s1)
    80003b2a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003b2c:	0009e797          	auipc	a5,0x9e
    80003b30:	eac78793          	addi	a5,a5,-340 # 800a19d8 <bcache+0x8000>
    80003b34:	2b87b703          	ld	a4,696(a5)
    80003b38:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003b3a:	0009e717          	auipc	a4,0x9e
    80003b3e:	10670713          	addi	a4,a4,262 # 800a1c40 <bcache+0x8268>
    80003b42:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003b44:	2b87b703          	ld	a4,696(a5)
    80003b48:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003b4a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003b4e:	00096517          	auipc	a0,0x96
    80003b52:	e8a50513          	addi	a0,a0,-374 # 800999d8 <bcache>
    80003b56:	ffffd097          	auipc	ra,0xffffd
    80003b5a:	268080e7          	jalr	616(ra) # 80000dbe <release>
}
    80003b5e:	60e2                	ld	ra,24(sp)
    80003b60:	6442                	ld	s0,16(sp)
    80003b62:	64a2                	ld	s1,8(sp)
    80003b64:	6902                	ld	s2,0(sp)
    80003b66:	6105                	addi	sp,sp,32
    80003b68:	8082                	ret
    panic("brelse");
    80003b6a:	00005517          	auipc	a0,0x5
    80003b6e:	b9e50513          	addi	a0,a0,-1122 # 80008708 <__func__.1+0x700>
    80003b72:	ffffd097          	auipc	ra,0xffffd
    80003b76:	9ee080e7          	jalr	-1554(ra) # 80000560 <panic>

0000000080003b7a <bpin>:

void
bpin(struct buf *b) {
    80003b7a:	1101                	addi	sp,sp,-32
    80003b7c:	ec06                	sd	ra,24(sp)
    80003b7e:	e822                	sd	s0,16(sp)
    80003b80:	e426                	sd	s1,8(sp)
    80003b82:	1000                	addi	s0,sp,32
    80003b84:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003b86:	00096517          	auipc	a0,0x96
    80003b8a:	e5250513          	addi	a0,a0,-430 # 800999d8 <bcache>
    80003b8e:	ffffd097          	auipc	ra,0xffffd
    80003b92:	17c080e7          	jalr	380(ra) # 80000d0a <acquire>
  b->refcnt++;
    80003b96:	40bc                	lw	a5,64(s1)
    80003b98:	2785                	addiw	a5,a5,1
    80003b9a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003b9c:	00096517          	auipc	a0,0x96
    80003ba0:	e3c50513          	addi	a0,a0,-452 # 800999d8 <bcache>
    80003ba4:	ffffd097          	auipc	ra,0xffffd
    80003ba8:	21a080e7          	jalr	538(ra) # 80000dbe <release>
}
    80003bac:	60e2                	ld	ra,24(sp)
    80003bae:	6442                	ld	s0,16(sp)
    80003bb0:	64a2                	ld	s1,8(sp)
    80003bb2:	6105                	addi	sp,sp,32
    80003bb4:	8082                	ret

0000000080003bb6 <bunpin>:

void
bunpin(struct buf *b) {
    80003bb6:	1101                	addi	sp,sp,-32
    80003bb8:	ec06                	sd	ra,24(sp)
    80003bba:	e822                	sd	s0,16(sp)
    80003bbc:	e426                	sd	s1,8(sp)
    80003bbe:	1000                	addi	s0,sp,32
    80003bc0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003bc2:	00096517          	auipc	a0,0x96
    80003bc6:	e1650513          	addi	a0,a0,-490 # 800999d8 <bcache>
    80003bca:	ffffd097          	auipc	ra,0xffffd
    80003bce:	140080e7          	jalr	320(ra) # 80000d0a <acquire>
  b->refcnt--;
    80003bd2:	40bc                	lw	a5,64(s1)
    80003bd4:	37fd                	addiw	a5,a5,-1
    80003bd6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003bd8:	00096517          	auipc	a0,0x96
    80003bdc:	e0050513          	addi	a0,a0,-512 # 800999d8 <bcache>
    80003be0:	ffffd097          	auipc	ra,0xffffd
    80003be4:	1de080e7          	jalr	478(ra) # 80000dbe <release>
}
    80003be8:	60e2                	ld	ra,24(sp)
    80003bea:	6442                	ld	s0,16(sp)
    80003bec:	64a2                	ld	s1,8(sp)
    80003bee:	6105                	addi	sp,sp,32
    80003bf0:	8082                	ret

0000000080003bf2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003bf2:	1101                	addi	sp,sp,-32
    80003bf4:	ec06                	sd	ra,24(sp)
    80003bf6:	e822                	sd	s0,16(sp)
    80003bf8:	e426                	sd	s1,8(sp)
    80003bfa:	e04a                	sd	s2,0(sp)
    80003bfc:	1000                	addi	s0,sp,32
    80003bfe:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003c00:	00d5d59b          	srliw	a1,a1,0xd
    80003c04:	0009e797          	auipc	a5,0x9e
    80003c08:	4b07a783          	lw	a5,1200(a5) # 800a20b4 <sb+0x1c>
    80003c0c:	9dbd                	addw	a1,a1,a5
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	da0080e7          	jalr	-608(ra) # 800039ae <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003c16:	0074f713          	andi	a4,s1,7
    80003c1a:	4785                	li	a5,1
    80003c1c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003c20:	14ce                	slli	s1,s1,0x33
    80003c22:	90d9                	srli	s1,s1,0x36
    80003c24:	00950733          	add	a4,a0,s1
    80003c28:	05874703          	lbu	a4,88(a4)
    80003c2c:	00e7f6b3          	and	a3,a5,a4
    80003c30:	c69d                	beqz	a3,80003c5e <bfree+0x6c>
    80003c32:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003c34:	94aa                	add	s1,s1,a0
    80003c36:	fff7c793          	not	a5,a5
    80003c3a:	8f7d                	and	a4,a4,a5
    80003c3c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003c40:	00001097          	auipc	ra,0x1
    80003c44:	148080e7          	jalr	328(ra) # 80004d88 <log_write>
  brelse(bp);
    80003c48:	854a                	mv	a0,s2
    80003c4a:	00000097          	auipc	ra,0x0
    80003c4e:	e94080e7          	jalr	-364(ra) # 80003ade <brelse>
}
    80003c52:	60e2                	ld	ra,24(sp)
    80003c54:	6442                	ld	s0,16(sp)
    80003c56:	64a2                	ld	s1,8(sp)
    80003c58:	6902                	ld	s2,0(sp)
    80003c5a:	6105                	addi	sp,sp,32
    80003c5c:	8082                	ret
    panic("freeing free block");
    80003c5e:	00005517          	auipc	a0,0x5
    80003c62:	ab250513          	addi	a0,a0,-1358 # 80008710 <__func__.1+0x708>
    80003c66:	ffffd097          	auipc	ra,0xffffd
    80003c6a:	8fa080e7          	jalr	-1798(ra) # 80000560 <panic>

0000000080003c6e <balloc>:
{
    80003c6e:	711d                	addi	sp,sp,-96
    80003c70:	ec86                	sd	ra,88(sp)
    80003c72:	e8a2                	sd	s0,80(sp)
    80003c74:	e4a6                	sd	s1,72(sp)
    80003c76:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003c78:	0009e797          	auipc	a5,0x9e
    80003c7c:	4247a783          	lw	a5,1060(a5) # 800a209c <sb+0x4>
    80003c80:	10078f63          	beqz	a5,80003d9e <balloc+0x130>
    80003c84:	e0ca                	sd	s2,64(sp)
    80003c86:	fc4e                	sd	s3,56(sp)
    80003c88:	f852                	sd	s4,48(sp)
    80003c8a:	f456                	sd	s5,40(sp)
    80003c8c:	f05a                	sd	s6,32(sp)
    80003c8e:	ec5e                	sd	s7,24(sp)
    80003c90:	e862                	sd	s8,16(sp)
    80003c92:	e466                	sd	s9,8(sp)
    80003c94:	8baa                	mv	s7,a0
    80003c96:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003c98:	0009eb17          	auipc	s6,0x9e
    80003c9c:	400b0b13          	addi	s6,s6,1024 # 800a2098 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ca0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003ca2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ca4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003ca6:	6c89                	lui	s9,0x2
    80003ca8:	a061                	j	80003d30 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003caa:	97ca                	add	a5,a5,s2
    80003cac:	8e55                	or	a2,a2,a3
    80003cae:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003cb2:	854a                	mv	a0,s2
    80003cb4:	00001097          	auipc	ra,0x1
    80003cb8:	0d4080e7          	jalr	212(ra) # 80004d88 <log_write>
        brelse(bp);
    80003cbc:	854a                	mv	a0,s2
    80003cbe:	00000097          	auipc	ra,0x0
    80003cc2:	e20080e7          	jalr	-480(ra) # 80003ade <brelse>
  bp = bread(dev, bno);
    80003cc6:	85a6                	mv	a1,s1
    80003cc8:	855e                	mv	a0,s7
    80003cca:	00000097          	auipc	ra,0x0
    80003cce:	ce4080e7          	jalr	-796(ra) # 800039ae <bread>
    80003cd2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003cd4:	40000613          	li	a2,1024
    80003cd8:	4581                	li	a1,0
    80003cda:	05850513          	addi	a0,a0,88
    80003cde:	ffffd097          	auipc	ra,0xffffd
    80003ce2:	128080e7          	jalr	296(ra) # 80000e06 <memset>
  log_write(bp);
    80003ce6:	854a                	mv	a0,s2
    80003ce8:	00001097          	auipc	ra,0x1
    80003cec:	0a0080e7          	jalr	160(ra) # 80004d88 <log_write>
  brelse(bp);
    80003cf0:	854a                	mv	a0,s2
    80003cf2:	00000097          	auipc	ra,0x0
    80003cf6:	dec080e7          	jalr	-532(ra) # 80003ade <brelse>
}
    80003cfa:	6906                	ld	s2,64(sp)
    80003cfc:	79e2                	ld	s3,56(sp)
    80003cfe:	7a42                	ld	s4,48(sp)
    80003d00:	7aa2                	ld	s5,40(sp)
    80003d02:	7b02                	ld	s6,32(sp)
    80003d04:	6be2                	ld	s7,24(sp)
    80003d06:	6c42                	ld	s8,16(sp)
    80003d08:	6ca2                	ld	s9,8(sp)
}
    80003d0a:	8526                	mv	a0,s1
    80003d0c:	60e6                	ld	ra,88(sp)
    80003d0e:	6446                	ld	s0,80(sp)
    80003d10:	64a6                	ld	s1,72(sp)
    80003d12:	6125                	addi	sp,sp,96
    80003d14:	8082                	ret
    brelse(bp);
    80003d16:	854a                	mv	a0,s2
    80003d18:	00000097          	auipc	ra,0x0
    80003d1c:	dc6080e7          	jalr	-570(ra) # 80003ade <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003d20:	015c87bb          	addw	a5,s9,s5
    80003d24:	00078a9b          	sext.w	s5,a5
    80003d28:	004b2703          	lw	a4,4(s6)
    80003d2c:	06eaf163          	bgeu	s5,a4,80003d8e <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003d30:	41fad79b          	sraiw	a5,s5,0x1f
    80003d34:	0137d79b          	srliw	a5,a5,0x13
    80003d38:	015787bb          	addw	a5,a5,s5
    80003d3c:	40d7d79b          	sraiw	a5,a5,0xd
    80003d40:	01cb2583          	lw	a1,28(s6)
    80003d44:	9dbd                	addw	a1,a1,a5
    80003d46:	855e                	mv	a0,s7
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	c66080e7          	jalr	-922(ra) # 800039ae <bread>
    80003d50:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003d52:	004b2503          	lw	a0,4(s6)
    80003d56:	000a849b          	sext.w	s1,s5
    80003d5a:	8762                	mv	a4,s8
    80003d5c:	faa4fde3          	bgeu	s1,a0,80003d16 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003d60:	00777693          	andi	a3,a4,7
    80003d64:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003d68:	41f7579b          	sraiw	a5,a4,0x1f
    80003d6c:	01d7d79b          	srliw	a5,a5,0x1d
    80003d70:	9fb9                	addw	a5,a5,a4
    80003d72:	4037d79b          	sraiw	a5,a5,0x3
    80003d76:	00f90633          	add	a2,s2,a5
    80003d7a:	05864603          	lbu	a2,88(a2)
    80003d7e:	00c6f5b3          	and	a1,a3,a2
    80003d82:	d585                	beqz	a1,80003caa <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003d84:	2705                	addiw	a4,a4,1
    80003d86:	2485                	addiw	s1,s1,1
    80003d88:	fd471ae3          	bne	a4,s4,80003d5c <balloc+0xee>
    80003d8c:	b769                	j	80003d16 <balloc+0xa8>
    80003d8e:	6906                	ld	s2,64(sp)
    80003d90:	79e2                	ld	s3,56(sp)
    80003d92:	7a42                	ld	s4,48(sp)
    80003d94:	7aa2                	ld	s5,40(sp)
    80003d96:	7b02                	ld	s6,32(sp)
    80003d98:	6be2                	ld	s7,24(sp)
    80003d9a:	6c42                	ld	s8,16(sp)
    80003d9c:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003d9e:	00005517          	auipc	a0,0x5
    80003da2:	98a50513          	addi	a0,a0,-1654 # 80008728 <__func__.1+0x720>
    80003da6:	ffffd097          	auipc	ra,0xffffd
    80003daa:	816080e7          	jalr	-2026(ra) # 800005bc <printf>
  return 0;
    80003dae:	4481                	li	s1,0
    80003db0:	bfa9                	j	80003d0a <balloc+0x9c>

0000000080003db2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003db2:	7179                	addi	sp,sp,-48
    80003db4:	f406                	sd	ra,40(sp)
    80003db6:	f022                	sd	s0,32(sp)
    80003db8:	ec26                	sd	s1,24(sp)
    80003dba:	e84a                	sd	s2,16(sp)
    80003dbc:	e44e                	sd	s3,8(sp)
    80003dbe:	1800                	addi	s0,sp,48
    80003dc0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003dc2:	47ad                	li	a5,11
    80003dc4:	02b7e863          	bltu	a5,a1,80003df4 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003dc8:	02059793          	slli	a5,a1,0x20
    80003dcc:	01e7d593          	srli	a1,a5,0x1e
    80003dd0:	00b504b3          	add	s1,a0,a1
    80003dd4:	0504a903          	lw	s2,80(s1)
    80003dd8:	08091263          	bnez	s2,80003e5c <bmap+0xaa>
      addr = balloc(ip->dev);
    80003ddc:	4108                	lw	a0,0(a0)
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	e90080e7          	jalr	-368(ra) # 80003c6e <balloc>
    80003de6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003dea:	06090963          	beqz	s2,80003e5c <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003dee:	0524a823          	sw	s2,80(s1)
    80003df2:	a0ad                	j	80003e5c <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003df4:	ff45849b          	addiw	s1,a1,-12
    80003df8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003dfc:	0ff00793          	li	a5,255
    80003e00:	08e7e863          	bltu	a5,a4,80003e90 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003e04:	08052903          	lw	s2,128(a0)
    80003e08:	00091f63          	bnez	s2,80003e26 <bmap+0x74>
      addr = balloc(ip->dev);
    80003e0c:	4108                	lw	a0,0(a0)
    80003e0e:	00000097          	auipc	ra,0x0
    80003e12:	e60080e7          	jalr	-416(ra) # 80003c6e <balloc>
    80003e16:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003e1a:	04090163          	beqz	s2,80003e5c <bmap+0xaa>
    80003e1e:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003e20:	0929a023          	sw	s2,128(s3)
    80003e24:	a011                	j	80003e28 <bmap+0x76>
    80003e26:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003e28:	85ca                	mv	a1,s2
    80003e2a:	0009a503          	lw	a0,0(s3)
    80003e2e:	00000097          	auipc	ra,0x0
    80003e32:	b80080e7          	jalr	-1152(ra) # 800039ae <bread>
    80003e36:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003e38:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003e3c:	02049713          	slli	a4,s1,0x20
    80003e40:	01e75593          	srli	a1,a4,0x1e
    80003e44:	00b784b3          	add	s1,a5,a1
    80003e48:	0004a903          	lw	s2,0(s1)
    80003e4c:	02090063          	beqz	s2,80003e6c <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003e50:	8552                	mv	a0,s4
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	c8c080e7          	jalr	-884(ra) # 80003ade <brelse>
    return addr;
    80003e5a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003e5c:	854a                	mv	a0,s2
    80003e5e:	70a2                	ld	ra,40(sp)
    80003e60:	7402                	ld	s0,32(sp)
    80003e62:	64e2                	ld	s1,24(sp)
    80003e64:	6942                	ld	s2,16(sp)
    80003e66:	69a2                	ld	s3,8(sp)
    80003e68:	6145                	addi	sp,sp,48
    80003e6a:	8082                	ret
      addr = balloc(ip->dev);
    80003e6c:	0009a503          	lw	a0,0(s3)
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	dfe080e7          	jalr	-514(ra) # 80003c6e <balloc>
    80003e78:	0005091b          	sext.w	s2,a0
      if(addr){
    80003e7c:	fc090ae3          	beqz	s2,80003e50 <bmap+0x9e>
        a[bn] = addr;
    80003e80:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003e84:	8552                	mv	a0,s4
    80003e86:	00001097          	auipc	ra,0x1
    80003e8a:	f02080e7          	jalr	-254(ra) # 80004d88 <log_write>
    80003e8e:	b7c9                	j	80003e50 <bmap+0x9e>
    80003e90:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003e92:	00005517          	auipc	a0,0x5
    80003e96:	8ae50513          	addi	a0,a0,-1874 # 80008740 <__func__.1+0x738>
    80003e9a:	ffffc097          	auipc	ra,0xffffc
    80003e9e:	6c6080e7          	jalr	1734(ra) # 80000560 <panic>

0000000080003ea2 <iget>:
{
    80003ea2:	7179                	addi	sp,sp,-48
    80003ea4:	f406                	sd	ra,40(sp)
    80003ea6:	f022                	sd	s0,32(sp)
    80003ea8:	ec26                	sd	s1,24(sp)
    80003eaa:	e84a                	sd	s2,16(sp)
    80003eac:	e44e                	sd	s3,8(sp)
    80003eae:	e052                	sd	s4,0(sp)
    80003eb0:	1800                	addi	s0,sp,48
    80003eb2:	89aa                	mv	s3,a0
    80003eb4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003eb6:	0009e517          	auipc	a0,0x9e
    80003eba:	20250513          	addi	a0,a0,514 # 800a20b8 <itable>
    80003ebe:	ffffd097          	auipc	ra,0xffffd
    80003ec2:	e4c080e7          	jalr	-436(ra) # 80000d0a <acquire>
  empty = 0;
    80003ec6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ec8:	0009e497          	auipc	s1,0x9e
    80003ecc:	20848493          	addi	s1,s1,520 # 800a20d0 <itable+0x18>
    80003ed0:	000a0697          	auipc	a3,0xa0
    80003ed4:	c9068693          	addi	a3,a3,-880 # 800a3b60 <log>
    80003ed8:	a039                	j	80003ee6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003eda:	02090b63          	beqz	s2,80003f10 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ede:	08848493          	addi	s1,s1,136
    80003ee2:	02d48a63          	beq	s1,a3,80003f16 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003ee6:	449c                	lw	a5,8(s1)
    80003ee8:	fef059e3          	blez	a5,80003eda <iget+0x38>
    80003eec:	4098                	lw	a4,0(s1)
    80003eee:	ff3716e3          	bne	a4,s3,80003eda <iget+0x38>
    80003ef2:	40d8                	lw	a4,4(s1)
    80003ef4:	ff4713e3          	bne	a4,s4,80003eda <iget+0x38>
      ip->ref++;
    80003ef8:	2785                	addiw	a5,a5,1
    80003efa:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003efc:	0009e517          	auipc	a0,0x9e
    80003f00:	1bc50513          	addi	a0,a0,444 # 800a20b8 <itable>
    80003f04:	ffffd097          	auipc	ra,0xffffd
    80003f08:	eba080e7          	jalr	-326(ra) # 80000dbe <release>
      return ip;
    80003f0c:	8926                	mv	s2,s1
    80003f0e:	a03d                	j	80003f3c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003f10:	f7f9                	bnez	a5,80003ede <iget+0x3c>
      empty = ip;
    80003f12:	8926                	mv	s2,s1
    80003f14:	b7e9                	j	80003ede <iget+0x3c>
  if(empty == 0)
    80003f16:	02090c63          	beqz	s2,80003f4e <iget+0xac>
  ip->dev = dev;
    80003f1a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003f1e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003f22:	4785                	li	a5,1
    80003f24:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003f28:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003f2c:	0009e517          	auipc	a0,0x9e
    80003f30:	18c50513          	addi	a0,a0,396 # 800a20b8 <itable>
    80003f34:	ffffd097          	auipc	ra,0xffffd
    80003f38:	e8a080e7          	jalr	-374(ra) # 80000dbe <release>
}
    80003f3c:	854a                	mv	a0,s2
    80003f3e:	70a2                	ld	ra,40(sp)
    80003f40:	7402                	ld	s0,32(sp)
    80003f42:	64e2                	ld	s1,24(sp)
    80003f44:	6942                	ld	s2,16(sp)
    80003f46:	69a2                	ld	s3,8(sp)
    80003f48:	6a02                	ld	s4,0(sp)
    80003f4a:	6145                	addi	sp,sp,48
    80003f4c:	8082                	ret
    panic("iget: no inodes");
    80003f4e:	00005517          	auipc	a0,0x5
    80003f52:	80a50513          	addi	a0,a0,-2038 # 80008758 <__func__.1+0x750>
    80003f56:	ffffc097          	auipc	ra,0xffffc
    80003f5a:	60a080e7          	jalr	1546(ra) # 80000560 <panic>

0000000080003f5e <fsinit>:
fsinit(int dev) {
    80003f5e:	7179                	addi	sp,sp,-48
    80003f60:	f406                	sd	ra,40(sp)
    80003f62:	f022                	sd	s0,32(sp)
    80003f64:	ec26                	sd	s1,24(sp)
    80003f66:	e84a                	sd	s2,16(sp)
    80003f68:	e44e                	sd	s3,8(sp)
    80003f6a:	1800                	addi	s0,sp,48
    80003f6c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003f6e:	4585                	li	a1,1
    80003f70:	00000097          	auipc	ra,0x0
    80003f74:	a3e080e7          	jalr	-1474(ra) # 800039ae <bread>
    80003f78:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003f7a:	0009e997          	auipc	s3,0x9e
    80003f7e:	11e98993          	addi	s3,s3,286 # 800a2098 <sb>
    80003f82:	02000613          	li	a2,32
    80003f86:	05850593          	addi	a1,a0,88
    80003f8a:	854e                	mv	a0,s3
    80003f8c:	ffffd097          	auipc	ra,0xffffd
    80003f90:	ed6080e7          	jalr	-298(ra) # 80000e62 <memmove>
  brelse(bp);
    80003f94:	8526                	mv	a0,s1
    80003f96:	00000097          	auipc	ra,0x0
    80003f9a:	b48080e7          	jalr	-1208(ra) # 80003ade <brelse>
  if(sb.magic != FSMAGIC)
    80003f9e:	0009a703          	lw	a4,0(s3)
    80003fa2:	102037b7          	lui	a5,0x10203
    80003fa6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003faa:	02f71263          	bne	a4,a5,80003fce <fsinit+0x70>
  initlog(dev, &sb);
    80003fae:	0009e597          	auipc	a1,0x9e
    80003fb2:	0ea58593          	addi	a1,a1,234 # 800a2098 <sb>
    80003fb6:	854a                	mv	a0,s2
    80003fb8:	00001097          	auipc	ra,0x1
    80003fbc:	b60080e7          	jalr	-1184(ra) # 80004b18 <initlog>
}
    80003fc0:	70a2                	ld	ra,40(sp)
    80003fc2:	7402                	ld	s0,32(sp)
    80003fc4:	64e2                	ld	s1,24(sp)
    80003fc6:	6942                	ld	s2,16(sp)
    80003fc8:	69a2                	ld	s3,8(sp)
    80003fca:	6145                	addi	sp,sp,48
    80003fcc:	8082                	ret
    panic("invalid file system");
    80003fce:	00004517          	auipc	a0,0x4
    80003fd2:	79a50513          	addi	a0,a0,1946 # 80008768 <__func__.1+0x760>
    80003fd6:	ffffc097          	auipc	ra,0xffffc
    80003fda:	58a080e7          	jalr	1418(ra) # 80000560 <panic>

0000000080003fde <iinit>:
{
    80003fde:	7179                	addi	sp,sp,-48
    80003fe0:	f406                	sd	ra,40(sp)
    80003fe2:	f022                	sd	s0,32(sp)
    80003fe4:	ec26                	sd	s1,24(sp)
    80003fe6:	e84a                	sd	s2,16(sp)
    80003fe8:	e44e                	sd	s3,8(sp)
    80003fea:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003fec:	00004597          	auipc	a1,0x4
    80003ff0:	79458593          	addi	a1,a1,1940 # 80008780 <__func__.1+0x778>
    80003ff4:	0009e517          	auipc	a0,0x9e
    80003ff8:	0c450513          	addi	a0,a0,196 # 800a20b8 <itable>
    80003ffc:	ffffd097          	auipc	ra,0xffffd
    80004000:	c7e080e7          	jalr	-898(ra) # 80000c7a <initlock>
  for(i = 0; i < NINODE; i++) {
    80004004:	0009e497          	auipc	s1,0x9e
    80004008:	0dc48493          	addi	s1,s1,220 # 800a20e0 <itable+0x28>
    8000400c:	000a0997          	auipc	s3,0xa0
    80004010:	b6498993          	addi	s3,s3,-1180 # 800a3b70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004014:	00004917          	auipc	s2,0x4
    80004018:	77490913          	addi	s2,s2,1908 # 80008788 <__func__.1+0x780>
    8000401c:	85ca                	mv	a1,s2
    8000401e:	8526                	mv	a0,s1
    80004020:	00001097          	auipc	ra,0x1
    80004024:	e4c080e7          	jalr	-436(ra) # 80004e6c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004028:	08848493          	addi	s1,s1,136
    8000402c:	ff3498e3          	bne	s1,s3,8000401c <iinit+0x3e>
}
    80004030:	70a2                	ld	ra,40(sp)
    80004032:	7402                	ld	s0,32(sp)
    80004034:	64e2                	ld	s1,24(sp)
    80004036:	6942                	ld	s2,16(sp)
    80004038:	69a2                	ld	s3,8(sp)
    8000403a:	6145                	addi	sp,sp,48
    8000403c:	8082                	ret

000000008000403e <ialloc>:
{
    8000403e:	7139                	addi	sp,sp,-64
    80004040:	fc06                	sd	ra,56(sp)
    80004042:	f822                	sd	s0,48(sp)
    80004044:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80004046:	0009e717          	auipc	a4,0x9e
    8000404a:	05e72703          	lw	a4,94(a4) # 800a20a4 <sb+0xc>
    8000404e:	4785                	li	a5,1
    80004050:	06e7f463          	bgeu	a5,a4,800040b8 <ialloc+0x7a>
    80004054:	f426                	sd	s1,40(sp)
    80004056:	f04a                	sd	s2,32(sp)
    80004058:	ec4e                	sd	s3,24(sp)
    8000405a:	e852                	sd	s4,16(sp)
    8000405c:	e456                	sd	s5,8(sp)
    8000405e:	e05a                	sd	s6,0(sp)
    80004060:	8aaa                	mv	s5,a0
    80004062:	8b2e                	mv	s6,a1
    80004064:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004066:	0009ea17          	auipc	s4,0x9e
    8000406a:	032a0a13          	addi	s4,s4,50 # 800a2098 <sb>
    8000406e:	00495593          	srli	a1,s2,0x4
    80004072:	018a2783          	lw	a5,24(s4)
    80004076:	9dbd                	addw	a1,a1,a5
    80004078:	8556                	mv	a0,s5
    8000407a:	00000097          	auipc	ra,0x0
    8000407e:	934080e7          	jalr	-1740(ra) # 800039ae <bread>
    80004082:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80004084:	05850993          	addi	s3,a0,88
    80004088:	00f97793          	andi	a5,s2,15
    8000408c:	079a                	slli	a5,a5,0x6
    8000408e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004090:	00099783          	lh	a5,0(s3)
    80004094:	cf9d                	beqz	a5,800040d2 <ialloc+0x94>
    brelse(bp);
    80004096:	00000097          	auipc	ra,0x0
    8000409a:	a48080e7          	jalr	-1464(ra) # 80003ade <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000409e:	0905                	addi	s2,s2,1
    800040a0:	00ca2703          	lw	a4,12(s4)
    800040a4:	0009079b          	sext.w	a5,s2
    800040a8:	fce7e3e3          	bltu	a5,a4,8000406e <ialloc+0x30>
    800040ac:	74a2                	ld	s1,40(sp)
    800040ae:	7902                	ld	s2,32(sp)
    800040b0:	69e2                	ld	s3,24(sp)
    800040b2:	6a42                	ld	s4,16(sp)
    800040b4:	6aa2                	ld	s5,8(sp)
    800040b6:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800040b8:	00004517          	auipc	a0,0x4
    800040bc:	6d850513          	addi	a0,a0,1752 # 80008790 <__func__.1+0x788>
    800040c0:	ffffc097          	auipc	ra,0xffffc
    800040c4:	4fc080e7          	jalr	1276(ra) # 800005bc <printf>
  return 0;
    800040c8:	4501                	li	a0,0
}
    800040ca:	70e2                	ld	ra,56(sp)
    800040cc:	7442                	ld	s0,48(sp)
    800040ce:	6121                	addi	sp,sp,64
    800040d0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800040d2:	04000613          	li	a2,64
    800040d6:	4581                	li	a1,0
    800040d8:	854e                	mv	a0,s3
    800040da:	ffffd097          	auipc	ra,0xffffd
    800040de:	d2c080e7          	jalr	-724(ra) # 80000e06 <memset>
      dip->type = type;
    800040e2:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800040e6:	8526                	mv	a0,s1
    800040e8:	00001097          	auipc	ra,0x1
    800040ec:	ca0080e7          	jalr	-864(ra) # 80004d88 <log_write>
      brelse(bp);
    800040f0:	8526                	mv	a0,s1
    800040f2:	00000097          	auipc	ra,0x0
    800040f6:	9ec080e7          	jalr	-1556(ra) # 80003ade <brelse>
      return iget(dev, inum);
    800040fa:	0009059b          	sext.w	a1,s2
    800040fe:	8556                	mv	a0,s5
    80004100:	00000097          	auipc	ra,0x0
    80004104:	da2080e7          	jalr	-606(ra) # 80003ea2 <iget>
    80004108:	74a2                	ld	s1,40(sp)
    8000410a:	7902                	ld	s2,32(sp)
    8000410c:	69e2                	ld	s3,24(sp)
    8000410e:	6a42                	ld	s4,16(sp)
    80004110:	6aa2                	ld	s5,8(sp)
    80004112:	6b02                	ld	s6,0(sp)
    80004114:	bf5d                	j	800040ca <ialloc+0x8c>

0000000080004116 <iupdate>:
{
    80004116:	1101                	addi	sp,sp,-32
    80004118:	ec06                	sd	ra,24(sp)
    8000411a:	e822                	sd	s0,16(sp)
    8000411c:	e426                	sd	s1,8(sp)
    8000411e:	e04a                	sd	s2,0(sp)
    80004120:	1000                	addi	s0,sp,32
    80004122:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004124:	415c                	lw	a5,4(a0)
    80004126:	0047d79b          	srliw	a5,a5,0x4
    8000412a:	0009e597          	auipc	a1,0x9e
    8000412e:	f865a583          	lw	a1,-122(a1) # 800a20b0 <sb+0x18>
    80004132:	9dbd                	addw	a1,a1,a5
    80004134:	4108                	lw	a0,0(a0)
    80004136:	00000097          	auipc	ra,0x0
    8000413a:	878080e7          	jalr	-1928(ra) # 800039ae <bread>
    8000413e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004140:	05850793          	addi	a5,a0,88
    80004144:	40d8                	lw	a4,4(s1)
    80004146:	8b3d                	andi	a4,a4,15
    80004148:	071a                	slli	a4,a4,0x6
    8000414a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000414c:	04449703          	lh	a4,68(s1)
    80004150:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80004154:	04649703          	lh	a4,70(s1)
    80004158:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000415c:	04849703          	lh	a4,72(s1)
    80004160:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80004164:	04a49703          	lh	a4,74(s1)
    80004168:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000416c:	44f8                	lw	a4,76(s1)
    8000416e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004170:	03400613          	li	a2,52
    80004174:	05048593          	addi	a1,s1,80
    80004178:	00c78513          	addi	a0,a5,12
    8000417c:	ffffd097          	auipc	ra,0xffffd
    80004180:	ce6080e7          	jalr	-794(ra) # 80000e62 <memmove>
  log_write(bp);
    80004184:	854a                	mv	a0,s2
    80004186:	00001097          	auipc	ra,0x1
    8000418a:	c02080e7          	jalr	-1022(ra) # 80004d88 <log_write>
  brelse(bp);
    8000418e:	854a                	mv	a0,s2
    80004190:	00000097          	auipc	ra,0x0
    80004194:	94e080e7          	jalr	-1714(ra) # 80003ade <brelse>
}
    80004198:	60e2                	ld	ra,24(sp)
    8000419a:	6442                	ld	s0,16(sp)
    8000419c:	64a2                	ld	s1,8(sp)
    8000419e:	6902                	ld	s2,0(sp)
    800041a0:	6105                	addi	sp,sp,32
    800041a2:	8082                	ret

00000000800041a4 <idup>:
{
    800041a4:	1101                	addi	sp,sp,-32
    800041a6:	ec06                	sd	ra,24(sp)
    800041a8:	e822                	sd	s0,16(sp)
    800041aa:	e426                	sd	s1,8(sp)
    800041ac:	1000                	addi	s0,sp,32
    800041ae:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800041b0:	0009e517          	auipc	a0,0x9e
    800041b4:	f0850513          	addi	a0,a0,-248 # 800a20b8 <itable>
    800041b8:	ffffd097          	auipc	ra,0xffffd
    800041bc:	b52080e7          	jalr	-1198(ra) # 80000d0a <acquire>
  ip->ref++;
    800041c0:	449c                	lw	a5,8(s1)
    800041c2:	2785                	addiw	a5,a5,1
    800041c4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800041c6:	0009e517          	auipc	a0,0x9e
    800041ca:	ef250513          	addi	a0,a0,-270 # 800a20b8 <itable>
    800041ce:	ffffd097          	auipc	ra,0xffffd
    800041d2:	bf0080e7          	jalr	-1040(ra) # 80000dbe <release>
}
    800041d6:	8526                	mv	a0,s1
    800041d8:	60e2                	ld	ra,24(sp)
    800041da:	6442                	ld	s0,16(sp)
    800041dc:	64a2                	ld	s1,8(sp)
    800041de:	6105                	addi	sp,sp,32
    800041e0:	8082                	ret

00000000800041e2 <ilock>:
{
    800041e2:	1101                	addi	sp,sp,-32
    800041e4:	ec06                	sd	ra,24(sp)
    800041e6:	e822                	sd	s0,16(sp)
    800041e8:	e426                	sd	s1,8(sp)
    800041ea:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800041ec:	c10d                	beqz	a0,8000420e <ilock+0x2c>
    800041ee:	84aa                	mv	s1,a0
    800041f0:	451c                	lw	a5,8(a0)
    800041f2:	00f05e63          	blez	a5,8000420e <ilock+0x2c>
  acquiresleep(&ip->lock);
    800041f6:	0541                	addi	a0,a0,16
    800041f8:	00001097          	auipc	ra,0x1
    800041fc:	cae080e7          	jalr	-850(ra) # 80004ea6 <acquiresleep>
  if(ip->valid == 0){
    80004200:	40bc                	lw	a5,64(s1)
    80004202:	cf99                	beqz	a5,80004220 <ilock+0x3e>
}
    80004204:	60e2                	ld	ra,24(sp)
    80004206:	6442                	ld	s0,16(sp)
    80004208:	64a2                	ld	s1,8(sp)
    8000420a:	6105                	addi	sp,sp,32
    8000420c:	8082                	ret
    8000420e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80004210:	00004517          	auipc	a0,0x4
    80004214:	59850513          	addi	a0,a0,1432 # 800087a8 <__func__.1+0x7a0>
    80004218:	ffffc097          	auipc	ra,0xffffc
    8000421c:	348080e7          	jalr	840(ra) # 80000560 <panic>
    80004220:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004222:	40dc                	lw	a5,4(s1)
    80004224:	0047d79b          	srliw	a5,a5,0x4
    80004228:	0009e597          	auipc	a1,0x9e
    8000422c:	e885a583          	lw	a1,-376(a1) # 800a20b0 <sb+0x18>
    80004230:	9dbd                	addw	a1,a1,a5
    80004232:	4088                	lw	a0,0(s1)
    80004234:	fffff097          	auipc	ra,0xfffff
    80004238:	77a080e7          	jalr	1914(ra) # 800039ae <bread>
    8000423c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000423e:	05850593          	addi	a1,a0,88
    80004242:	40dc                	lw	a5,4(s1)
    80004244:	8bbd                	andi	a5,a5,15
    80004246:	079a                	slli	a5,a5,0x6
    80004248:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000424a:	00059783          	lh	a5,0(a1)
    8000424e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004252:	00259783          	lh	a5,2(a1)
    80004256:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000425a:	00459783          	lh	a5,4(a1)
    8000425e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004262:	00659783          	lh	a5,6(a1)
    80004266:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000426a:	459c                	lw	a5,8(a1)
    8000426c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000426e:	03400613          	li	a2,52
    80004272:	05b1                	addi	a1,a1,12
    80004274:	05048513          	addi	a0,s1,80
    80004278:	ffffd097          	auipc	ra,0xffffd
    8000427c:	bea080e7          	jalr	-1046(ra) # 80000e62 <memmove>
    brelse(bp);
    80004280:	854a                	mv	a0,s2
    80004282:	00000097          	auipc	ra,0x0
    80004286:	85c080e7          	jalr	-1956(ra) # 80003ade <brelse>
    ip->valid = 1;
    8000428a:	4785                	li	a5,1
    8000428c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000428e:	04449783          	lh	a5,68(s1)
    80004292:	c399                	beqz	a5,80004298 <ilock+0xb6>
    80004294:	6902                	ld	s2,0(sp)
    80004296:	b7bd                	j	80004204 <ilock+0x22>
      panic("ilock: no type");
    80004298:	00004517          	auipc	a0,0x4
    8000429c:	51850513          	addi	a0,a0,1304 # 800087b0 <__func__.1+0x7a8>
    800042a0:	ffffc097          	auipc	ra,0xffffc
    800042a4:	2c0080e7          	jalr	704(ra) # 80000560 <panic>

00000000800042a8 <iunlock>:
{
    800042a8:	1101                	addi	sp,sp,-32
    800042aa:	ec06                	sd	ra,24(sp)
    800042ac:	e822                	sd	s0,16(sp)
    800042ae:	e426                	sd	s1,8(sp)
    800042b0:	e04a                	sd	s2,0(sp)
    800042b2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800042b4:	c905                	beqz	a0,800042e4 <iunlock+0x3c>
    800042b6:	84aa                	mv	s1,a0
    800042b8:	01050913          	addi	s2,a0,16
    800042bc:	854a                	mv	a0,s2
    800042be:	00001097          	auipc	ra,0x1
    800042c2:	c82080e7          	jalr	-894(ra) # 80004f40 <holdingsleep>
    800042c6:	cd19                	beqz	a0,800042e4 <iunlock+0x3c>
    800042c8:	449c                	lw	a5,8(s1)
    800042ca:	00f05d63          	blez	a5,800042e4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800042ce:	854a                	mv	a0,s2
    800042d0:	00001097          	auipc	ra,0x1
    800042d4:	c2c080e7          	jalr	-980(ra) # 80004efc <releasesleep>
}
    800042d8:	60e2                	ld	ra,24(sp)
    800042da:	6442                	ld	s0,16(sp)
    800042dc:	64a2                	ld	s1,8(sp)
    800042de:	6902                	ld	s2,0(sp)
    800042e0:	6105                	addi	sp,sp,32
    800042e2:	8082                	ret
    panic("iunlock");
    800042e4:	00004517          	auipc	a0,0x4
    800042e8:	4dc50513          	addi	a0,a0,1244 # 800087c0 <__func__.1+0x7b8>
    800042ec:	ffffc097          	auipc	ra,0xffffc
    800042f0:	274080e7          	jalr	628(ra) # 80000560 <panic>

00000000800042f4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800042f4:	7179                	addi	sp,sp,-48
    800042f6:	f406                	sd	ra,40(sp)
    800042f8:	f022                	sd	s0,32(sp)
    800042fa:	ec26                	sd	s1,24(sp)
    800042fc:	e84a                	sd	s2,16(sp)
    800042fe:	e44e                	sd	s3,8(sp)
    80004300:	1800                	addi	s0,sp,48
    80004302:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004304:	05050493          	addi	s1,a0,80
    80004308:	08050913          	addi	s2,a0,128
    8000430c:	a021                	j	80004314 <itrunc+0x20>
    8000430e:	0491                	addi	s1,s1,4
    80004310:	01248d63          	beq	s1,s2,8000432a <itrunc+0x36>
    if(ip->addrs[i]){
    80004314:	408c                	lw	a1,0(s1)
    80004316:	dde5                	beqz	a1,8000430e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80004318:	0009a503          	lw	a0,0(s3)
    8000431c:	00000097          	auipc	ra,0x0
    80004320:	8d6080e7          	jalr	-1834(ra) # 80003bf2 <bfree>
      ip->addrs[i] = 0;
    80004324:	0004a023          	sw	zero,0(s1)
    80004328:	b7dd                	j	8000430e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000432a:	0809a583          	lw	a1,128(s3)
    8000432e:	ed99                	bnez	a1,8000434c <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004330:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004334:	854e                	mv	a0,s3
    80004336:	00000097          	auipc	ra,0x0
    8000433a:	de0080e7          	jalr	-544(ra) # 80004116 <iupdate>
}
    8000433e:	70a2                	ld	ra,40(sp)
    80004340:	7402                	ld	s0,32(sp)
    80004342:	64e2                	ld	s1,24(sp)
    80004344:	6942                	ld	s2,16(sp)
    80004346:	69a2                	ld	s3,8(sp)
    80004348:	6145                	addi	sp,sp,48
    8000434a:	8082                	ret
    8000434c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000434e:	0009a503          	lw	a0,0(s3)
    80004352:	fffff097          	auipc	ra,0xfffff
    80004356:	65c080e7          	jalr	1628(ra) # 800039ae <bread>
    8000435a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000435c:	05850493          	addi	s1,a0,88
    80004360:	45850913          	addi	s2,a0,1112
    80004364:	a021                	j	8000436c <itrunc+0x78>
    80004366:	0491                	addi	s1,s1,4
    80004368:	01248b63          	beq	s1,s2,8000437e <itrunc+0x8a>
      if(a[j])
    8000436c:	408c                	lw	a1,0(s1)
    8000436e:	dde5                	beqz	a1,80004366 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80004370:	0009a503          	lw	a0,0(s3)
    80004374:	00000097          	auipc	ra,0x0
    80004378:	87e080e7          	jalr	-1922(ra) # 80003bf2 <bfree>
    8000437c:	b7ed                	j	80004366 <itrunc+0x72>
    brelse(bp);
    8000437e:	8552                	mv	a0,s4
    80004380:	fffff097          	auipc	ra,0xfffff
    80004384:	75e080e7          	jalr	1886(ra) # 80003ade <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004388:	0809a583          	lw	a1,128(s3)
    8000438c:	0009a503          	lw	a0,0(s3)
    80004390:	00000097          	auipc	ra,0x0
    80004394:	862080e7          	jalr	-1950(ra) # 80003bf2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004398:	0809a023          	sw	zero,128(s3)
    8000439c:	6a02                	ld	s4,0(sp)
    8000439e:	bf49                	j	80004330 <itrunc+0x3c>

00000000800043a0 <iput>:
{
    800043a0:	1101                	addi	sp,sp,-32
    800043a2:	ec06                	sd	ra,24(sp)
    800043a4:	e822                	sd	s0,16(sp)
    800043a6:	e426                	sd	s1,8(sp)
    800043a8:	1000                	addi	s0,sp,32
    800043aa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800043ac:	0009e517          	auipc	a0,0x9e
    800043b0:	d0c50513          	addi	a0,a0,-756 # 800a20b8 <itable>
    800043b4:	ffffd097          	auipc	ra,0xffffd
    800043b8:	956080e7          	jalr	-1706(ra) # 80000d0a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800043bc:	4498                	lw	a4,8(s1)
    800043be:	4785                	li	a5,1
    800043c0:	02f70263          	beq	a4,a5,800043e4 <iput+0x44>
  ip->ref--;
    800043c4:	449c                	lw	a5,8(s1)
    800043c6:	37fd                	addiw	a5,a5,-1
    800043c8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800043ca:	0009e517          	auipc	a0,0x9e
    800043ce:	cee50513          	addi	a0,a0,-786 # 800a20b8 <itable>
    800043d2:	ffffd097          	auipc	ra,0xffffd
    800043d6:	9ec080e7          	jalr	-1556(ra) # 80000dbe <release>
}
    800043da:	60e2                	ld	ra,24(sp)
    800043dc:	6442                	ld	s0,16(sp)
    800043de:	64a2                	ld	s1,8(sp)
    800043e0:	6105                	addi	sp,sp,32
    800043e2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800043e4:	40bc                	lw	a5,64(s1)
    800043e6:	dff9                	beqz	a5,800043c4 <iput+0x24>
    800043e8:	04a49783          	lh	a5,74(s1)
    800043ec:	ffe1                	bnez	a5,800043c4 <iput+0x24>
    800043ee:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800043f0:	01048913          	addi	s2,s1,16
    800043f4:	854a                	mv	a0,s2
    800043f6:	00001097          	auipc	ra,0x1
    800043fa:	ab0080e7          	jalr	-1360(ra) # 80004ea6 <acquiresleep>
    release(&itable.lock);
    800043fe:	0009e517          	auipc	a0,0x9e
    80004402:	cba50513          	addi	a0,a0,-838 # 800a20b8 <itable>
    80004406:	ffffd097          	auipc	ra,0xffffd
    8000440a:	9b8080e7          	jalr	-1608(ra) # 80000dbe <release>
    itrunc(ip);
    8000440e:	8526                	mv	a0,s1
    80004410:	00000097          	auipc	ra,0x0
    80004414:	ee4080e7          	jalr	-284(ra) # 800042f4 <itrunc>
    ip->type = 0;
    80004418:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000441c:	8526                	mv	a0,s1
    8000441e:	00000097          	auipc	ra,0x0
    80004422:	cf8080e7          	jalr	-776(ra) # 80004116 <iupdate>
    ip->valid = 0;
    80004426:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000442a:	854a                	mv	a0,s2
    8000442c:	00001097          	auipc	ra,0x1
    80004430:	ad0080e7          	jalr	-1328(ra) # 80004efc <releasesleep>
    acquire(&itable.lock);
    80004434:	0009e517          	auipc	a0,0x9e
    80004438:	c8450513          	addi	a0,a0,-892 # 800a20b8 <itable>
    8000443c:	ffffd097          	auipc	ra,0xffffd
    80004440:	8ce080e7          	jalr	-1842(ra) # 80000d0a <acquire>
    80004444:	6902                	ld	s2,0(sp)
    80004446:	bfbd                	j	800043c4 <iput+0x24>

0000000080004448 <iunlockput>:
{
    80004448:	1101                	addi	sp,sp,-32
    8000444a:	ec06                	sd	ra,24(sp)
    8000444c:	e822                	sd	s0,16(sp)
    8000444e:	e426                	sd	s1,8(sp)
    80004450:	1000                	addi	s0,sp,32
    80004452:	84aa                	mv	s1,a0
  iunlock(ip);
    80004454:	00000097          	auipc	ra,0x0
    80004458:	e54080e7          	jalr	-428(ra) # 800042a8 <iunlock>
  iput(ip);
    8000445c:	8526                	mv	a0,s1
    8000445e:	00000097          	auipc	ra,0x0
    80004462:	f42080e7          	jalr	-190(ra) # 800043a0 <iput>
}
    80004466:	60e2                	ld	ra,24(sp)
    80004468:	6442                	ld	s0,16(sp)
    8000446a:	64a2                	ld	s1,8(sp)
    8000446c:	6105                	addi	sp,sp,32
    8000446e:	8082                	ret

0000000080004470 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004470:	1141                	addi	sp,sp,-16
    80004472:	e422                	sd	s0,8(sp)
    80004474:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004476:	411c                	lw	a5,0(a0)
    80004478:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000447a:	415c                	lw	a5,4(a0)
    8000447c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000447e:	04451783          	lh	a5,68(a0)
    80004482:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004486:	04a51783          	lh	a5,74(a0)
    8000448a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000448e:	04c56783          	lwu	a5,76(a0)
    80004492:	e99c                	sd	a5,16(a1)
}
    80004494:	6422                	ld	s0,8(sp)
    80004496:	0141                	addi	sp,sp,16
    80004498:	8082                	ret

000000008000449a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000449a:	457c                	lw	a5,76(a0)
    8000449c:	10d7e563          	bltu	a5,a3,800045a6 <readi+0x10c>
{
    800044a0:	7159                	addi	sp,sp,-112
    800044a2:	f486                	sd	ra,104(sp)
    800044a4:	f0a2                	sd	s0,96(sp)
    800044a6:	eca6                	sd	s1,88(sp)
    800044a8:	e0d2                	sd	s4,64(sp)
    800044aa:	fc56                	sd	s5,56(sp)
    800044ac:	f85a                	sd	s6,48(sp)
    800044ae:	f45e                	sd	s7,40(sp)
    800044b0:	1880                	addi	s0,sp,112
    800044b2:	8b2a                	mv	s6,a0
    800044b4:	8bae                	mv	s7,a1
    800044b6:	8a32                	mv	s4,a2
    800044b8:	84b6                	mv	s1,a3
    800044ba:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800044bc:	9f35                	addw	a4,a4,a3
    return 0;
    800044be:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800044c0:	0cd76a63          	bltu	a4,a3,80004594 <readi+0xfa>
    800044c4:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800044c6:	00e7f463          	bgeu	a5,a4,800044ce <readi+0x34>
    n = ip->size - off;
    800044ca:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800044ce:	0a0a8963          	beqz	s5,80004580 <readi+0xe6>
    800044d2:	e8ca                	sd	s2,80(sp)
    800044d4:	f062                	sd	s8,32(sp)
    800044d6:	ec66                	sd	s9,24(sp)
    800044d8:	e86a                	sd	s10,16(sp)
    800044da:	e46e                	sd	s11,8(sp)
    800044dc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800044de:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800044e2:	5c7d                	li	s8,-1
    800044e4:	a82d                	j	8000451e <readi+0x84>
    800044e6:	020d1d93          	slli	s11,s10,0x20
    800044ea:	020ddd93          	srli	s11,s11,0x20
    800044ee:	05890613          	addi	a2,s2,88
    800044f2:	86ee                	mv	a3,s11
    800044f4:	963a                	add	a2,a2,a4
    800044f6:	85d2                	mv	a1,s4
    800044f8:	855e                	mv	a0,s7
    800044fa:	ffffe097          	auipc	ra,0xffffe
    800044fe:	784080e7          	jalr	1924(ra) # 80002c7e <either_copyout>
    80004502:	05850d63          	beq	a0,s8,8000455c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004506:	854a                	mv	a0,s2
    80004508:	fffff097          	auipc	ra,0xfffff
    8000450c:	5d6080e7          	jalr	1494(ra) # 80003ade <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004510:	013d09bb          	addw	s3,s10,s3
    80004514:	009d04bb          	addw	s1,s10,s1
    80004518:	9a6e                	add	s4,s4,s11
    8000451a:	0559fd63          	bgeu	s3,s5,80004574 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    8000451e:	00a4d59b          	srliw	a1,s1,0xa
    80004522:	855a                	mv	a0,s6
    80004524:	00000097          	auipc	ra,0x0
    80004528:	88e080e7          	jalr	-1906(ra) # 80003db2 <bmap>
    8000452c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004530:	c9b1                	beqz	a1,80004584 <readi+0xea>
    bp = bread(ip->dev, addr);
    80004532:	000b2503          	lw	a0,0(s6)
    80004536:	fffff097          	auipc	ra,0xfffff
    8000453a:	478080e7          	jalr	1144(ra) # 800039ae <bread>
    8000453e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004540:	3ff4f713          	andi	a4,s1,1023
    80004544:	40ec87bb          	subw	a5,s9,a4
    80004548:	413a86bb          	subw	a3,s5,s3
    8000454c:	8d3e                	mv	s10,a5
    8000454e:	2781                	sext.w	a5,a5
    80004550:	0006861b          	sext.w	a2,a3
    80004554:	f8f679e3          	bgeu	a2,a5,800044e6 <readi+0x4c>
    80004558:	8d36                	mv	s10,a3
    8000455a:	b771                	j	800044e6 <readi+0x4c>
      brelse(bp);
    8000455c:	854a                	mv	a0,s2
    8000455e:	fffff097          	auipc	ra,0xfffff
    80004562:	580080e7          	jalr	1408(ra) # 80003ade <brelse>
      tot = -1;
    80004566:	59fd                	li	s3,-1
      break;
    80004568:	6946                	ld	s2,80(sp)
    8000456a:	7c02                	ld	s8,32(sp)
    8000456c:	6ce2                	ld	s9,24(sp)
    8000456e:	6d42                	ld	s10,16(sp)
    80004570:	6da2                	ld	s11,8(sp)
    80004572:	a831                	j	8000458e <readi+0xf4>
    80004574:	6946                	ld	s2,80(sp)
    80004576:	7c02                	ld	s8,32(sp)
    80004578:	6ce2                	ld	s9,24(sp)
    8000457a:	6d42                	ld	s10,16(sp)
    8000457c:	6da2                	ld	s11,8(sp)
    8000457e:	a801                	j	8000458e <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004580:	89d6                	mv	s3,s5
    80004582:	a031                	j	8000458e <readi+0xf4>
    80004584:	6946                	ld	s2,80(sp)
    80004586:	7c02                	ld	s8,32(sp)
    80004588:	6ce2                	ld	s9,24(sp)
    8000458a:	6d42                	ld	s10,16(sp)
    8000458c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000458e:	0009851b          	sext.w	a0,s3
    80004592:	69a6                	ld	s3,72(sp)
}
    80004594:	70a6                	ld	ra,104(sp)
    80004596:	7406                	ld	s0,96(sp)
    80004598:	64e6                	ld	s1,88(sp)
    8000459a:	6a06                	ld	s4,64(sp)
    8000459c:	7ae2                	ld	s5,56(sp)
    8000459e:	7b42                	ld	s6,48(sp)
    800045a0:	7ba2                	ld	s7,40(sp)
    800045a2:	6165                	addi	sp,sp,112
    800045a4:	8082                	ret
    return 0;
    800045a6:	4501                	li	a0,0
}
    800045a8:	8082                	ret

00000000800045aa <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800045aa:	457c                	lw	a5,76(a0)
    800045ac:	10d7ee63          	bltu	a5,a3,800046c8 <writei+0x11e>
{
    800045b0:	7159                	addi	sp,sp,-112
    800045b2:	f486                	sd	ra,104(sp)
    800045b4:	f0a2                	sd	s0,96(sp)
    800045b6:	e8ca                	sd	s2,80(sp)
    800045b8:	e0d2                	sd	s4,64(sp)
    800045ba:	fc56                	sd	s5,56(sp)
    800045bc:	f85a                	sd	s6,48(sp)
    800045be:	f45e                	sd	s7,40(sp)
    800045c0:	1880                	addi	s0,sp,112
    800045c2:	8aaa                	mv	s5,a0
    800045c4:	8bae                	mv	s7,a1
    800045c6:	8a32                	mv	s4,a2
    800045c8:	8936                	mv	s2,a3
    800045ca:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800045cc:	00e687bb          	addw	a5,a3,a4
    800045d0:	0ed7ee63          	bltu	a5,a3,800046cc <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800045d4:	00043737          	lui	a4,0x43
    800045d8:	0ef76c63          	bltu	a4,a5,800046d0 <writei+0x126>
    800045dc:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800045de:	0c0b0d63          	beqz	s6,800046b8 <writei+0x10e>
    800045e2:	eca6                	sd	s1,88(sp)
    800045e4:	f062                	sd	s8,32(sp)
    800045e6:	ec66                	sd	s9,24(sp)
    800045e8:	e86a                	sd	s10,16(sp)
    800045ea:	e46e                	sd	s11,8(sp)
    800045ec:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800045ee:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800045f2:	5c7d                	li	s8,-1
    800045f4:	a091                	j	80004638 <writei+0x8e>
    800045f6:	020d1d93          	slli	s11,s10,0x20
    800045fa:	020ddd93          	srli	s11,s11,0x20
    800045fe:	05848513          	addi	a0,s1,88
    80004602:	86ee                	mv	a3,s11
    80004604:	8652                	mv	a2,s4
    80004606:	85de                	mv	a1,s7
    80004608:	953a                	add	a0,a0,a4
    8000460a:	ffffe097          	auipc	ra,0xffffe
    8000460e:	6ca080e7          	jalr	1738(ra) # 80002cd4 <either_copyin>
    80004612:	07850263          	beq	a0,s8,80004676 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004616:	8526                	mv	a0,s1
    80004618:	00000097          	auipc	ra,0x0
    8000461c:	770080e7          	jalr	1904(ra) # 80004d88 <log_write>
    brelse(bp);
    80004620:	8526                	mv	a0,s1
    80004622:	fffff097          	auipc	ra,0xfffff
    80004626:	4bc080e7          	jalr	1212(ra) # 80003ade <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000462a:	013d09bb          	addw	s3,s10,s3
    8000462e:	012d093b          	addw	s2,s10,s2
    80004632:	9a6e                	add	s4,s4,s11
    80004634:	0569f663          	bgeu	s3,s6,80004680 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004638:	00a9559b          	srliw	a1,s2,0xa
    8000463c:	8556                	mv	a0,s5
    8000463e:	fffff097          	auipc	ra,0xfffff
    80004642:	774080e7          	jalr	1908(ra) # 80003db2 <bmap>
    80004646:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000464a:	c99d                	beqz	a1,80004680 <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000464c:	000aa503          	lw	a0,0(s5)
    80004650:	fffff097          	auipc	ra,0xfffff
    80004654:	35e080e7          	jalr	862(ra) # 800039ae <bread>
    80004658:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000465a:	3ff97713          	andi	a4,s2,1023
    8000465e:	40ec87bb          	subw	a5,s9,a4
    80004662:	413b06bb          	subw	a3,s6,s3
    80004666:	8d3e                	mv	s10,a5
    80004668:	2781                	sext.w	a5,a5
    8000466a:	0006861b          	sext.w	a2,a3
    8000466e:	f8f674e3          	bgeu	a2,a5,800045f6 <writei+0x4c>
    80004672:	8d36                	mv	s10,a3
    80004674:	b749                	j	800045f6 <writei+0x4c>
      brelse(bp);
    80004676:	8526                	mv	a0,s1
    80004678:	fffff097          	auipc	ra,0xfffff
    8000467c:	466080e7          	jalr	1126(ra) # 80003ade <brelse>
  }

  if(off > ip->size)
    80004680:	04caa783          	lw	a5,76(s5)
    80004684:	0327fc63          	bgeu	a5,s2,800046bc <writei+0x112>
    ip->size = off;
    80004688:	052aa623          	sw	s2,76(s5)
    8000468c:	64e6                	ld	s1,88(sp)
    8000468e:	7c02                	ld	s8,32(sp)
    80004690:	6ce2                	ld	s9,24(sp)
    80004692:	6d42                	ld	s10,16(sp)
    80004694:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004696:	8556                	mv	a0,s5
    80004698:	00000097          	auipc	ra,0x0
    8000469c:	a7e080e7          	jalr	-1410(ra) # 80004116 <iupdate>

  return tot;
    800046a0:	0009851b          	sext.w	a0,s3
    800046a4:	69a6                	ld	s3,72(sp)
}
    800046a6:	70a6                	ld	ra,104(sp)
    800046a8:	7406                	ld	s0,96(sp)
    800046aa:	6946                	ld	s2,80(sp)
    800046ac:	6a06                	ld	s4,64(sp)
    800046ae:	7ae2                	ld	s5,56(sp)
    800046b0:	7b42                	ld	s6,48(sp)
    800046b2:	7ba2                	ld	s7,40(sp)
    800046b4:	6165                	addi	sp,sp,112
    800046b6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800046b8:	89da                	mv	s3,s6
    800046ba:	bff1                	j	80004696 <writei+0xec>
    800046bc:	64e6                	ld	s1,88(sp)
    800046be:	7c02                	ld	s8,32(sp)
    800046c0:	6ce2                	ld	s9,24(sp)
    800046c2:	6d42                	ld	s10,16(sp)
    800046c4:	6da2                	ld	s11,8(sp)
    800046c6:	bfc1                	j	80004696 <writei+0xec>
    return -1;
    800046c8:	557d                	li	a0,-1
}
    800046ca:	8082                	ret
    return -1;
    800046cc:	557d                	li	a0,-1
    800046ce:	bfe1                	j	800046a6 <writei+0xfc>
    return -1;
    800046d0:	557d                	li	a0,-1
    800046d2:	bfd1                	j	800046a6 <writei+0xfc>

00000000800046d4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800046d4:	1141                	addi	sp,sp,-16
    800046d6:	e406                	sd	ra,8(sp)
    800046d8:	e022                	sd	s0,0(sp)
    800046da:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800046dc:	4639                	li	a2,14
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	7f8080e7          	jalr	2040(ra) # 80000ed6 <strncmp>
}
    800046e6:	60a2                	ld	ra,8(sp)
    800046e8:	6402                	ld	s0,0(sp)
    800046ea:	0141                	addi	sp,sp,16
    800046ec:	8082                	ret

00000000800046ee <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800046ee:	7139                	addi	sp,sp,-64
    800046f0:	fc06                	sd	ra,56(sp)
    800046f2:	f822                	sd	s0,48(sp)
    800046f4:	f426                	sd	s1,40(sp)
    800046f6:	f04a                	sd	s2,32(sp)
    800046f8:	ec4e                	sd	s3,24(sp)
    800046fa:	e852                	sd	s4,16(sp)
    800046fc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800046fe:	04451703          	lh	a4,68(a0)
    80004702:	4785                	li	a5,1
    80004704:	00f71a63          	bne	a4,a5,80004718 <dirlookup+0x2a>
    80004708:	892a                	mv	s2,a0
    8000470a:	89ae                	mv	s3,a1
    8000470c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000470e:	457c                	lw	a5,76(a0)
    80004710:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004712:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004714:	e79d                	bnez	a5,80004742 <dirlookup+0x54>
    80004716:	a8a5                	j	8000478e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004718:	00004517          	auipc	a0,0x4
    8000471c:	0b050513          	addi	a0,a0,176 # 800087c8 <__func__.1+0x7c0>
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	e40080e7          	jalr	-448(ra) # 80000560 <panic>
      panic("dirlookup read");
    80004728:	00004517          	auipc	a0,0x4
    8000472c:	0b850513          	addi	a0,a0,184 # 800087e0 <__func__.1+0x7d8>
    80004730:	ffffc097          	auipc	ra,0xffffc
    80004734:	e30080e7          	jalr	-464(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004738:	24c1                	addiw	s1,s1,16
    8000473a:	04c92783          	lw	a5,76(s2)
    8000473e:	04f4f763          	bgeu	s1,a5,8000478c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004742:	4741                	li	a4,16
    80004744:	86a6                	mv	a3,s1
    80004746:	fc040613          	addi	a2,s0,-64
    8000474a:	4581                	li	a1,0
    8000474c:	854a                	mv	a0,s2
    8000474e:	00000097          	auipc	ra,0x0
    80004752:	d4c080e7          	jalr	-692(ra) # 8000449a <readi>
    80004756:	47c1                	li	a5,16
    80004758:	fcf518e3          	bne	a0,a5,80004728 <dirlookup+0x3a>
    if(de.inum == 0)
    8000475c:	fc045783          	lhu	a5,-64(s0)
    80004760:	dfe1                	beqz	a5,80004738 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004762:	fc240593          	addi	a1,s0,-62
    80004766:	854e                	mv	a0,s3
    80004768:	00000097          	auipc	ra,0x0
    8000476c:	f6c080e7          	jalr	-148(ra) # 800046d4 <namecmp>
    80004770:	f561                	bnez	a0,80004738 <dirlookup+0x4a>
      if(poff)
    80004772:	000a0463          	beqz	s4,8000477a <dirlookup+0x8c>
        *poff = off;
    80004776:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000477a:	fc045583          	lhu	a1,-64(s0)
    8000477e:	00092503          	lw	a0,0(s2)
    80004782:	fffff097          	auipc	ra,0xfffff
    80004786:	720080e7          	jalr	1824(ra) # 80003ea2 <iget>
    8000478a:	a011                	j	8000478e <dirlookup+0xa0>
  return 0;
    8000478c:	4501                	li	a0,0
}
    8000478e:	70e2                	ld	ra,56(sp)
    80004790:	7442                	ld	s0,48(sp)
    80004792:	74a2                	ld	s1,40(sp)
    80004794:	7902                	ld	s2,32(sp)
    80004796:	69e2                	ld	s3,24(sp)
    80004798:	6a42                	ld	s4,16(sp)
    8000479a:	6121                	addi	sp,sp,64
    8000479c:	8082                	ret

000000008000479e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000479e:	711d                	addi	sp,sp,-96
    800047a0:	ec86                	sd	ra,88(sp)
    800047a2:	e8a2                	sd	s0,80(sp)
    800047a4:	e4a6                	sd	s1,72(sp)
    800047a6:	e0ca                	sd	s2,64(sp)
    800047a8:	fc4e                	sd	s3,56(sp)
    800047aa:	f852                	sd	s4,48(sp)
    800047ac:	f456                	sd	s5,40(sp)
    800047ae:	f05a                	sd	s6,32(sp)
    800047b0:	ec5e                	sd	s7,24(sp)
    800047b2:	e862                	sd	s8,16(sp)
    800047b4:	e466                	sd	s9,8(sp)
    800047b6:	1080                	addi	s0,sp,96
    800047b8:	84aa                	mv	s1,a0
    800047ba:	8b2e                	mv	s6,a1
    800047bc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800047be:	00054703          	lbu	a4,0(a0)
    800047c2:	02f00793          	li	a5,47
    800047c6:	02f70263          	beq	a4,a5,800047ea <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800047ca:	ffffe097          	auipc	ra,0xffffe
    800047ce:	90a080e7          	jalr	-1782(ra) # 800020d4 <myproc>
    800047d2:	15053503          	ld	a0,336(a0)
    800047d6:	00000097          	auipc	ra,0x0
    800047da:	9ce080e7          	jalr	-1586(ra) # 800041a4 <idup>
    800047de:	8a2a                	mv	s4,a0
  while(*path == '/')
    800047e0:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800047e4:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800047e6:	4b85                	li	s7,1
    800047e8:	a875                	j	800048a4 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    800047ea:	4585                	li	a1,1
    800047ec:	4505                	li	a0,1
    800047ee:	fffff097          	auipc	ra,0xfffff
    800047f2:	6b4080e7          	jalr	1716(ra) # 80003ea2 <iget>
    800047f6:	8a2a                	mv	s4,a0
    800047f8:	b7e5                	j	800047e0 <namex+0x42>
      iunlockput(ip);
    800047fa:	8552                	mv	a0,s4
    800047fc:	00000097          	auipc	ra,0x0
    80004800:	c4c080e7          	jalr	-948(ra) # 80004448 <iunlockput>
      return 0;
    80004804:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004806:	8552                	mv	a0,s4
    80004808:	60e6                	ld	ra,88(sp)
    8000480a:	6446                	ld	s0,80(sp)
    8000480c:	64a6                	ld	s1,72(sp)
    8000480e:	6906                	ld	s2,64(sp)
    80004810:	79e2                	ld	s3,56(sp)
    80004812:	7a42                	ld	s4,48(sp)
    80004814:	7aa2                	ld	s5,40(sp)
    80004816:	7b02                	ld	s6,32(sp)
    80004818:	6be2                	ld	s7,24(sp)
    8000481a:	6c42                	ld	s8,16(sp)
    8000481c:	6ca2                	ld	s9,8(sp)
    8000481e:	6125                	addi	sp,sp,96
    80004820:	8082                	ret
      iunlock(ip);
    80004822:	8552                	mv	a0,s4
    80004824:	00000097          	auipc	ra,0x0
    80004828:	a84080e7          	jalr	-1404(ra) # 800042a8 <iunlock>
      return ip;
    8000482c:	bfe9                	j	80004806 <namex+0x68>
      iunlockput(ip);
    8000482e:	8552                	mv	a0,s4
    80004830:	00000097          	auipc	ra,0x0
    80004834:	c18080e7          	jalr	-1000(ra) # 80004448 <iunlockput>
      return 0;
    80004838:	8a4e                	mv	s4,s3
    8000483a:	b7f1                	j	80004806 <namex+0x68>
  len = path - s;
    8000483c:	40998633          	sub	a2,s3,s1
    80004840:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004844:	099c5863          	bge	s8,s9,800048d4 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80004848:	4639                	li	a2,14
    8000484a:	85a6                	mv	a1,s1
    8000484c:	8556                	mv	a0,s5
    8000484e:	ffffc097          	auipc	ra,0xffffc
    80004852:	614080e7          	jalr	1556(ra) # 80000e62 <memmove>
    80004856:	84ce                	mv	s1,s3
  while(*path == '/')
    80004858:	0004c783          	lbu	a5,0(s1)
    8000485c:	01279763          	bne	a5,s2,8000486a <namex+0xcc>
    path++;
    80004860:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004862:	0004c783          	lbu	a5,0(s1)
    80004866:	ff278de3          	beq	a5,s2,80004860 <namex+0xc2>
    ilock(ip);
    8000486a:	8552                	mv	a0,s4
    8000486c:	00000097          	auipc	ra,0x0
    80004870:	976080e7          	jalr	-1674(ra) # 800041e2 <ilock>
    if(ip->type != T_DIR){
    80004874:	044a1783          	lh	a5,68(s4)
    80004878:	f97791e3          	bne	a5,s7,800047fa <namex+0x5c>
    if(nameiparent && *path == '\0'){
    8000487c:	000b0563          	beqz	s6,80004886 <namex+0xe8>
    80004880:	0004c783          	lbu	a5,0(s1)
    80004884:	dfd9                	beqz	a5,80004822 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004886:	4601                	li	a2,0
    80004888:	85d6                	mv	a1,s5
    8000488a:	8552                	mv	a0,s4
    8000488c:	00000097          	auipc	ra,0x0
    80004890:	e62080e7          	jalr	-414(ra) # 800046ee <dirlookup>
    80004894:	89aa                	mv	s3,a0
    80004896:	dd41                	beqz	a0,8000482e <namex+0x90>
    iunlockput(ip);
    80004898:	8552                	mv	a0,s4
    8000489a:	00000097          	auipc	ra,0x0
    8000489e:	bae080e7          	jalr	-1106(ra) # 80004448 <iunlockput>
    ip = next;
    800048a2:	8a4e                	mv	s4,s3
  while(*path == '/')
    800048a4:	0004c783          	lbu	a5,0(s1)
    800048a8:	01279763          	bne	a5,s2,800048b6 <namex+0x118>
    path++;
    800048ac:	0485                	addi	s1,s1,1
  while(*path == '/')
    800048ae:	0004c783          	lbu	a5,0(s1)
    800048b2:	ff278de3          	beq	a5,s2,800048ac <namex+0x10e>
  if(*path == 0)
    800048b6:	cb9d                	beqz	a5,800048ec <namex+0x14e>
  while(*path != '/' && *path != 0)
    800048b8:	0004c783          	lbu	a5,0(s1)
    800048bc:	89a6                	mv	s3,s1
  len = path - s;
    800048be:	4c81                	li	s9,0
    800048c0:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800048c2:	01278963          	beq	a5,s2,800048d4 <namex+0x136>
    800048c6:	dbbd                	beqz	a5,8000483c <namex+0x9e>
    path++;
    800048c8:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800048ca:	0009c783          	lbu	a5,0(s3)
    800048ce:	ff279ce3          	bne	a5,s2,800048c6 <namex+0x128>
    800048d2:	b7ad                	j	8000483c <namex+0x9e>
    memmove(name, s, len);
    800048d4:	2601                	sext.w	a2,a2
    800048d6:	85a6                	mv	a1,s1
    800048d8:	8556                	mv	a0,s5
    800048da:	ffffc097          	auipc	ra,0xffffc
    800048de:	588080e7          	jalr	1416(ra) # 80000e62 <memmove>
    name[len] = 0;
    800048e2:	9cd6                	add	s9,s9,s5
    800048e4:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800048e8:	84ce                	mv	s1,s3
    800048ea:	b7bd                	j	80004858 <namex+0xba>
  if(nameiparent){
    800048ec:	f00b0de3          	beqz	s6,80004806 <namex+0x68>
    iput(ip);
    800048f0:	8552                	mv	a0,s4
    800048f2:	00000097          	auipc	ra,0x0
    800048f6:	aae080e7          	jalr	-1362(ra) # 800043a0 <iput>
    return 0;
    800048fa:	4a01                	li	s4,0
    800048fc:	b729                	j	80004806 <namex+0x68>

00000000800048fe <dirlink>:
{
    800048fe:	7139                	addi	sp,sp,-64
    80004900:	fc06                	sd	ra,56(sp)
    80004902:	f822                	sd	s0,48(sp)
    80004904:	f04a                	sd	s2,32(sp)
    80004906:	ec4e                	sd	s3,24(sp)
    80004908:	e852                	sd	s4,16(sp)
    8000490a:	0080                	addi	s0,sp,64
    8000490c:	892a                	mv	s2,a0
    8000490e:	8a2e                	mv	s4,a1
    80004910:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004912:	4601                	li	a2,0
    80004914:	00000097          	auipc	ra,0x0
    80004918:	dda080e7          	jalr	-550(ra) # 800046ee <dirlookup>
    8000491c:	ed25                	bnez	a0,80004994 <dirlink+0x96>
    8000491e:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004920:	04c92483          	lw	s1,76(s2)
    80004924:	c49d                	beqz	s1,80004952 <dirlink+0x54>
    80004926:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004928:	4741                	li	a4,16
    8000492a:	86a6                	mv	a3,s1
    8000492c:	fc040613          	addi	a2,s0,-64
    80004930:	4581                	li	a1,0
    80004932:	854a                	mv	a0,s2
    80004934:	00000097          	auipc	ra,0x0
    80004938:	b66080e7          	jalr	-1178(ra) # 8000449a <readi>
    8000493c:	47c1                	li	a5,16
    8000493e:	06f51163          	bne	a0,a5,800049a0 <dirlink+0xa2>
    if(de.inum == 0)
    80004942:	fc045783          	lhu	a5,-64(s0)
    80004946:	c791                	beqz	a5,80004952 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004948:	24c1                	addiw	s1,s1,16
    8000494a:	04c92783          	lw	a5,76(s2)
    8000494e:	fcf4ede3          	bltu	s1,a5,80004928 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004952:	4639                	li	a2,14
    80004954:	85d2                	mv	a1,s4
    80004956:	fc240513          	addi	a0,s0,-62
    8000495a:	ffffc097          	auipc	ra,0xffffc
    8000495e:	5b2080e7          	jalr	1458(ra) # 80000f0c <strncpy>
  de.inum = inum;
    80004962:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004966:	4741                	li	a4,16
    80004968:	86a6                	mv	a3,s1
    8000496a:	fc040613          	addi	a2,s0,-64
    8000496e:	4581                	li	a1,0
    80004970:	854a                	mv	a0,s2
    80004972:	00000097          	auipc	ra,0x0
    80004976:	c38080e7          	jalr	-968(ra) # 800045aa <writei>
    8000497a:	1541                	addi	a0,a0,-16
    8000497c:	00a03533          	snez	a0,a0
    80004980:	40a00533          	neg	a0,a0
    80004984:	74a2                	ld	s1,40(sp)
}
    80004986:	70e2                	ld	ra,56(sp)
    80004988:	7442                	ld	s0,48(sp)
    8000498a:	7902                	ld	s2,32(sp)
    8000498c:	69e2                	ld	s3,24(sp)
    8000498e:	6a42                	ld	s4,16(sp)
    80004990:	6121                	addi	sp,sp,64
    80004992:	8082                	ret
    iput(ip);
    80004994:	00000097          	auipc	ra,0x0
    80004998:	a0c080e7          	jalr	-1524(ra) # 800043a0 <iput>
    return -1;
    8000499c:	557d                	li	a0,-1
    8000499e:	b7e5                	j	80004986 <dirlink+0x88>
      panic("dirlink read");
    800049a0:	00004517          	auipc	a0,0x4
    800049a4:	e5050513          	addi	a0,a0,-432 # 800087f0 <__func__.1+0x7e8>
    800049a8:	ffffc097          	auipc	ra,0xffffc
    800049ac:	bb8080e7          	jalr	-1096(ra) # 80000560 <panic>

00000000800049b0 <namei>:

struct inode*
namei(char *path)
{
    800049b0:	1101                	addi	sp,sp,-32
    800049b2:	ec06                	sd	ra,24(sp)
    800049b4:	e822                	sd	s0,16(sp)
    800049b6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800049b8:	fe040613          	addi	a2,s0,-32
    800049bc:	4581                	li	a1,0
    800049be:	00000097          	auipc	ra,0x0
    800049c2:	de0080e7          	jalr	-544(ra) # 8000479e <namex>
}
    800049c6:	60e2                	ld	ra,24(sp)
    800049c8:	6442                	ld	s0,16(sp)
    800049ca:	6105                	addi	sp,sp,32
    800049cc:	8082                	ret

00000000800049ce <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800049ce:	1141                	addi	sp,sp,-16
    800049d0:	e406                	sd	ra,8(sp)
    800049d2:	e022                	sd	s0,0(sp)
    800049d4:	0800                	addi	s0,sp,16
    800049d6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800049d8:	4585                	li	a1,1
    800049da:	00000097          	auipc	ra,0x0
    800049de:	dc4080e7          	jalr	-572(ra) # 8000479e <namex>
}
    800049e2:	60a2                	ld	ra,8(sp)
    800049e4:	6402                	ld	s0,0(sp)
    800049e6:	0141                	addi	sp,sp,16
    800049e8:	8082                	ret

00000000800049ea <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800049ea:	1101                	addi	sp,sp,-32
    800049ec:	ec06                	sd	ra,24(sp)
    800049ee:	e822                	sd	s0,16(sp)
    800049f0:	e426                	sd	s1,8(sp)
    800049f2:	e04a                	sd	s2,0(sp)
    800049f4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800049f6:	0009f917          	auipc	s2,0x9f
    800049fa:	16a90913          	addi	s2,s2,362 # 800a3b60 <log>
    800049fe:	01892583          	lw	a1,24(s2)
    80004a02:	02892503          	lw	a0,40(s2)
    80004a06:	fffff097          	auipc	ra,0xfffff
    80004a0a:	fa8080e7          	jalr	-88(ra) # 800039ae <bread>
    80004a0e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004a10:	02c92603          	lw	a2,44(s2)
    80004a14:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004a16:	00c05f63          	blez	a2,80004a34 <write_head+0x4a>
    80004a1a:	0009f717          	auipc	a4,0x9f
    80004a1e:	17670713          	addi	a4,a4,374 # 800a3b90 <log+0x30>
    80004a22:	87aa                	mv	a5,a0
    80004a24:	060a                	slli	a2,a2,0x2
    80004a26:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004a28:	4314                	lw	a3,0(a4)
    80004a2a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004a2c:	0711                	addi	a4,a4,4
    80004a2e:	0791                	addi	a5,a5,4
    80004a30:	fec79ce3          	bne	a5,a2,80004a28 <write_head+0x3e>
  }
  bwrite(buf);
    80004a34:	8526                	mv	a0,s1
    80004a36:	fffff097          	auipc	ra,0xfffff
    80004a3a:	06a080e7          	jalr	106(ra) # 80003aa0 <bwrite>
  brelse(buf);
    80004a3e:	8526                	mv	a0,s1
    80004a40:	fffff097          	auipc	ra,0xfffff
    80004a44:	09e080e7          	jalr	158(ra) # 80003ade <brelse>
}
    80004a48:	60e2                	ld	ra,24(sp)
    80004a4a:	6442                	ld	s0,16(sp)
    80004a4c:	64a2                	ld	s1,8(sp)
    80004a4e:	6902                	ld	s2,0(sp)
    80004a50:	6105                	addi	sp,sp,32
    80004a52:	8082                	ret

0000000080004a54 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a54:	0009f797          	auipc	a5,0x9f
    80004a58:	1387a783          	lw	a5,312(a5) # 800a3b8c <log+0x2c>
    80004a5c:	0af05d63          	blez	a5,80004b16 <install_trans+0xc2>
{
    80004a60:	7139                	addi	sp,sp,-64
    80004a62:	fc06                	sd	ra,56(sp)
    80004a64:	f822                	sd	s0,48(sp)
    80004a66:	f426                	sd	s1,40(sp)
    80004a68:	f04a                	sd	s2,32(sp)
    80004a6a:	ec4e                	sd	s3,24(sp)
    80004a6c:	e852                	sd	s4,16(sp)
    80004a6e:	e456                	sd	s5,8(sp)
    80004a70:	e05a                	sd	s6,0(sp)
    80004a72:	0080                	addi	s0,sp,64
    80004a74:	8b2a                	mv	s6,a0
    80004a76:	0009fa97          	auipc	s5,0x9f
    80004a7a:	11aa8a93          	addi	s5,s5,282 # 800a3b90 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a7e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004a80:	0009f997          	auipc	s3,0x9f
    80004a84:	0e098993          	addi	s3,s3,224 # 800a3b60 <log>
    80004a88:	a00d                	j	80004aaa <install_trans+0x56>
    brelse(lbuf);
    80004a8a:	854a                	mv	a0,s2
    80004a8c:	fffff097          	auipc	ra,0xfffff
    80004a90:	052080e7          	jalr	82(ra) # 80003ade <brelse>
    brelse(dbuf);
    80004a94:	8526                	mv	a0,s1
    80004a96:	fffff097          	auipc	ra,0xfffff
    80004a9a:	048080e7          	jalr	72(ra) # 80003ade <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a9e:	2a05                	addiw	s4,s4,1
    80004aa0:	0a91                	addi	s5,s5,4
    80004aa2:	02c9a783          	lw	a5,44(s3)
    80004aa6:	04fa5e63          	bge	s4,a5,80004b02 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004aaa:	0189a583          	lw	a1,24(s3)
    80004aae:	014585bb          	addw	a1,a1,s4
    80004ab2:	2585                	addiw	a1,a1,1
    80004ab4:	0289a503          	lw	a0,40(s3)
    80004ab8:	fffff097          	auipc	ra,0xfffff
    80004abc:	ef6080e7          	jalr	-266(ra) # 800039ae <bread>
    80004ac0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004ac2:	000aa583          	lw	a1,0(s5)
    80004ac6:	0289a503          	lw	a0,40(s3)
    80004aca:	fffff097          	auipc	ra,0xfffff
    80004ace:	ee4080e7          	jalr	-284(ra) # 800039ae <bread>
    80004ad2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004ad4:	40000613          	li	a2,1024
    80004ad8:	05890593          	addi	a1,s2,88
    80004adc:	05850513          	addi	a0,a0,88
    80004ae0:	ffffc097          	auipc	ra,0xffffc
    80004ae4:	382080e7          	jalr	898(ra) # 80000e62 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004ae8:	8526                	mv	a0,s1
    80004aea:	fffff097          	auipc	ra,0xfffff
    80004aee:	fb6080e7          	jalr	-74(ra) # 80003aa0 <bwrite>
    if(recovering == 0)
    80004af2:	f80b1ce3          	bnez	s6,80004a8a <install_trans+0x36>
      bunpin(dbuf);
    80004af6:	8526                	mv	a0,s1
    80004af8:	fffff097          	auipc	ra,0xfffff
    80004afc:	0be080e7          	jalr	190(ra) # 80003bb6 <bunpin>
    80004b00:	b769                	j	80004a8a <install_trans+0x36>
}
    80004b02:	70e2                	ld	ra,56(sp)
    80004b04:	7442                	ld	s0,48(sp)
    80004b06:	74a2                	ld	s1,40(sp)
    80004b08:	7902                	ld	s2,32(sp)
    80004b0a:	69e2                	ld	s3,24(sp)
    80004b0c:	6a42                	ld	s4,16(sp)
    80004b0e:	6aa2                	ld	s5,8(sp)
    80004b10:	6b02                	ld	s6,0(sp)
    80004b12:	6121                	addi	sp,sp,64
    80004b14:	8082                	ret
    80004b16:	8082                	ret

0000000080004b18 <initlog>:
{
    80004b18:	7179                	addi	sp,sp,-48
    80004b1a:	f406                	sd	ra,40(sp)
    80004b1c:	f022                	sd	s0,32(sp)
    80004b1e:	ec26                	sd	s1,24(sp)
    80004b20:	e84a                	sd	s2,16(sp)
    80004b22:	e44e                	sd	s3,8(sp)
    80004b24:	1800                	addi	s0,sp,48
    80004b26:	892a                	mv	s2,a0
    80004b28:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004b2a:	0009f497          	auipc	s1,0x9f
    80004b2e:	03648493          	addi	s1,s1,54 # 800a3b60 <log>
    80004b32:	00004597          	auipc	a1,0x4
    80004b36:	cce58593          	addi	a1,a1,-818 # 80008800 <__func__.1+0x7f8>
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	ffffc097          	auipc	ra,0xffffc
    80004b40:	13e080e7          	jalr	318(ra) # 80000c7a <initlock>
  log.start = sb->logstart;
    80004b44:	0149a583          	lw	a1,20(s3)
    80004b48:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004b4a:	0109a783          	lw	a5,16(s3)
    80004b4e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004b50:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004b54:	854a                	mv	a0,s2
    80004b56:	fffff097          	auipc	ra,0xfffff
    80004b5a:	e58080e7          	jalr	-424(ra) # 800039ae <bread>
  log.lh.n = lh->n;
    80004b5e:	4d30                	lw	a2,88(a0)
    80004b60:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004b62:	00c05f63          	blez	a2,80004b80 <initlog+0x68>
    80004b66:	87aa                	mv	a5,a0
    80004b68:	0009f717          	auipc	a4,0x9f
    80004b6c:	02870713          	addi	a4,a4,40 # 800a3b90 <log+0x30>
    80004b70:	060a                	slli	a2,a2,0x2
    80004b72:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004b74:	4ff4                	lw	a3,92(a5)
    80004b76:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004b78:	0791                	addi	a5,a5,4
    80004b7a:	0711                	addi	a4,a4,4
    80004b7c:	fec79ce3          	bne	a5,a2,80004b74 <initlog+0x5c>
  brelse(buf);
    80004b80:	fffff097          	auipc	ra,0xfffff
    80004b84:	f5e080e7          	jalr	-162(ra) # 80003ade <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004b88:	4505                	li	a0,1
    80004b8a:	00000097          	auipc	ra,0x0
    80004b8e:	eca080e7          	jalr	-310(ra) # 80004a54 <install_trans>
  log.lh.n = 0;
    80004b92:	0009f797          	auipc	a5,0x9f
    80004b96:	fe07ad23          	sw	zero,-6(a5) # 800a3b8c <log+0x2c>
  write_head(); // clear the log
    80004b9a:	00000097          	auipc	ra,0x0
    80004b9e:	e50080e7          	jalr	-432(ra) # 800049ea <write_head>
}
    80004ba2:	70a2                	ld	ra,40(sp)
    80004ba4:	7402                	ld	s0,32(sp)
    80004ba6:	64e2                	ld	s1,24(sp)
    80004ba8:	6942                	ld	s2,16(sp)
    80004baa:	69a2                	ld	s3,8(sp)
    80004bac:	6145                	addi	sp,sp,48
    80004bae:	8082                	ret

0000000080004bb0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004bb0:	1101                	addi	sp,sp,-32
    80004bb2:	ec06                	sd	ra,24(sp)
    80004bb4:	e822                	sd	s0,16(sp)
    80004bb6:	e426                	sd	s1,8(sp)
    80004bb8:	e04a                	sd	s2,0(sp)
    80004bba:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004bbc:	0009f517          	auipc	a0,0x9f
    80004bc0:	fa450513          	addi	a0,a0,-92 # 800a3b60 <log>
    80004bc4:	ffffc097          	auipc	ra,0xffffc
    80004bc8:	146080e7          	jalr	326(ra) # 80000d0a <acquire>
  while(1){
    if(log.committing){
    80004bcc:	0009f497          	auipc	s1,0x9f
    80004bd0:	f9448493          	addi	s1,s1,-108 # 800a3b60 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004bd4:	4979                	li	s2,30
    80004bd6:	a039                	j	80004be4 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004bd8:	85a6                	mv	a1,s1
    80004bda:	8526                	mv	a0,s1
    80004bdc:	ffffe097          	auipc	ra,0xffffe
    80004be0:	c9a080e7          	jalr	-870(ra) # 80002876 <sleep>
    if(log.committing){
    80004be4:	50dc                	lw	a5,36(s1)
    80004be6:	fbed                	bnez	a5,80004bd8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004be8:	5098                	lw	a4,32(s1)
    80004bea:	2705                	addiw	a4,a4,1
    80004bec:	0027179b          	slliw	a5,a4,0x2
    80004bf0:	9fb9                	addw	a5,a5,a4
    80004bf2:	0017979b          	slliw	a5,a5,0x1
    80004bf6:	54d4                	lw	a3,44(s1)
    80004bf8:	9fb5                	addw	a5,a5,a3
    80004bfa:	00f95963          	bge	s2,a5,80004c0c <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004bfe:	85a6                	mv	a1,s1
    80004c00:	8526                	mv	a0,s1
    80004c02:	ffffe097          	auipc	ra,0xffffe
    80004c06:	c74080e7          	jalr	-908(ra) # 80002876 <sleep>
    80004c0a:	bfe9                	j	80004be4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004c0c:	0009f517          	auipc	a0,0x9f
    80004c10:	f5450513          	addi	a0,a0,-172 # 800a3b60 <log>
    80004c14:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004c16:	ffffc097          	auipc	ra,0xffffc
    80004c1a:	1a8080e7          	jalr	424(ra) # 80000dbe <release>
      break;
    }
  }
}
    80004c1e:	60e2                	ld	ra,24(sp)
    80004c20:	6442                	ld	s0,16(sp)
    80004c22:	64a2                	ld	s1,8(sp)
    80004c24:	6902                	ld	s2,0(sp)
    80004c26:	6105                	addi	sp,sp,32
    80004c28:	8082                	ret

0000000080004c2a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004c2a:	7139                	addi	sp,sp,-64
    80004c2c:	fc06                	sd	ra,56(sp)
    80004c2e:	f822                	sd	s0,48(sp)
    80004c30:	f426                	sd	s1,40(sp)
    80004c32:	f04a                	sd	s2,32(sp)
    80004c34:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004c36:	0009f497          	auipc	s1,0x9f
    80004c3a:	f2a48493          	addi	s1,s1,-214 # 800a3b60 <log>
    80004c3e:	8526                	mv	a0,s1
    80004c40:	ffffc097          	auipc	ra,0xffffc
    80004c44:	0ca080e7          	jalr	202(ra) # 80000d0a <acquire>
  log.outstanding -= 1;
    80004c48:	509c                	lw	a5,32(s1)
    80004c4a:	37fd                	addiw	a5,a5,-1
    80004c4c:	0007891b          	sext.w	s2,a5
    80004c50:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004c52:	50dc                	lw	a5,36(s1)
    80004c54:	e7b9                	bnez	a5,80004ca2 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    80004c56:	06091163          	bnez	s2,80004cb8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004c5a:	0009f497          	auipc	s1,0x9f
    80004c5e:	f0648493          	addi	s1,s1,-250 # 800a3b60 <log>
    80004c62:	4785                	li	a5,1
    80004c64:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004c66:	8526                	mv	a0,s1
    80004c68:	ffffc097          	auipc	ra,0xffffc
    80004c6c:	156080e7          	jalr	342(ra) # 80000dbe <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004c70:	54dc                	lw	a5,44(s1)
    80004c72:	06f04763          	bgtz	a5,80004ce0 <end_op+0xb6>
    acquire(&log.lock);
    80004c76:	0009f497          	auipc	s1,0x9f
    80004c7a:	eea48493          	addi	s1,s1,-278 # 800a3b60 <log>
    80004c7e:	8526                	mv	a0,s1
    80004c80:	ffffc097          	auipc	ra,0xffffc
    80004c84:	08a080e7          	jalr	138(ra) # 80000d0a <acquire>
    log.committing = 0;
    80004c88:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004c8c:	8526                	mv	a0,s1
    80004c8e:	ffffe097          	auipc	ra,0xffffe
    80004c92:	c4c080e7          	jalr	-948(ra) # 800028da <wakeup>
    release(&log.lock);
    80004c96:	8526                	mv	a0,s1
    80004c98:	ffffc097          	auipc	ra,0xffffc
    80004c9c:	126080e7          	jalr	294(ra) # 80000dbe <release>
}
    80004ca0:	a815                	j	80004cd4 <end_op+0xaa>
    80004ca2:	ec4e                	sd	s3,24(sp)
    80004ca4:	e852                	sd	s4,16(sp)
    80004ca6:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004ca8:	00004517          	auipc	a0,0x4
    80004cac:	b6050513          	addi	a0,a0,-1184 # 80008808 <__func__.1+0x800>
    80004cb0:	ffffc097          	auipc	ra,0xffffc
    80004cb4:	8b0080e7          	jalr	-1872(ra) # 80000560 <panic>
    wakeup(&log);
    80004cb8:	0009f497          	auipc	s1,0x9f
    80004cbc:	ea848493          	addi	s1,s1,-344 # 800a3b60 <log>
    80004cc0:	8526                	mv	a0,s1
    80004cc2:	ffffe097          	auipc	ra,0xffffe
    80004cc6:	c18080e7          	jalr	-1000(ra) # 800028da <wakeup>
  release(&log.lock);
    80004cca:	8526                	mv	a0,s1
    80004ccc:	ffffc097          	auipc	ra,0xffffc
    80004cd0:	0f2080e7          	jalr	242(ra) # 80000dbe <release>
}
    80004cd4:	70e2                	ld	ra,56(sp)
    80004cd6:	7442                	ld	s0,48(sp)
    80004cd8:	74a2                	ld	s1,40(sp)
    80004cda:	7902                	ld	s2,32(sp)
    80004cdc:	6121                	addi	sp,sp,64
    80004cde:	8082                	ret
    80004ce0:	ec4e                	sd	s3,24(sp)
    80004ce2:	e852                	sd	s4,16(sp)
    80004ce4:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ce6:	0009fa97          	auipc	s5,0x9f
    80004cea:	eaaa8a93          	addi	s5,s5,-342 # 800a3b90 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004cee:	0009fa17          	auipc	s4,0x9f
    80004cf2:	e72a0a13          	addi	s4,s4,-398 # 800a3b60 <log>
    80004cf6:	018a2583          	lw	a1,24(s4)
    80004cfa:	012585bb          	addw	a1,a1,s2
    80004cfe:	2585                	addiw	a1,a1,1
    80004d00:	028a2503          	lw	a0,40(s4)
    80004d04:	fffff097          	auipc	ra,0xfffff
    80004d08:	caa080e7          	jalr	-854(ra) # 800039ae <bread>
    80004d0c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004d0e:	000aa583          	lw	a1,0(s5)
    80004d12:	028a2503          	lw	a0,40(s4)
    80004d16:	fffff097          	auipc	ra,0xfffff
    80004d1a:	c98080e7          	jalr	-872(ra) # 800039ae <bread>
    80004d1e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004d20:	40000613          	li	a2,1024
    80004d24:	05850593          	addi	a1,a0,88
    80004d28:	05848513          	addi	a0,s1,88
    80004d2c:	ffffc097          	auipc	ra,0xffffc
    80004d30:	136080e7          	jalr	310(ra) # 80000e62 <memmove>
    bwrite(to);  // write the log
    80004d34:	8526                	mv	a0,s1
    80004d36:	fffff097          	auipc	ra,0xfffff
    80004d3a:	d6a080e7          	jalr	-662(ra) # 80003aa0 <bwrite>
    brelse(from);
    80004d3e:	854e                	mv	a0,s3
    80004d40:	fffff097          	auipc	ra,0xfffff
    80004d44:	d9e080e7          	jalr	-610(ra) # 80003ade <brelse>
    brelse(to);
    80004d48:	8526                	mv	a0,s1
    80004d4a:	fffff097          	auipc	ra,0xfffff
    80004d4e:	d94080e7          	jalr	-620(ra) # 80003ade <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004d52:	2905                	addiw	s2,s2,1
    80004d54:	0a91                	addi	s5,s5,4
    80004d56:	02ca2783          	lw	a5,44(s4)
    80004d5a:	f8f94ee3          	blt	s2,a5,80004cf6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004d5e:	00000097          	auipc	ra,0x0
    80004d62:	c8c080e7          	jalr	-884(ra) # 800049ea <write_head>
    install_trans(0); // Now install writes to home locations
    80004d66:	4501                	li	a0,0
    80004d68:	00000097          	auipc	ra,0x0
    80004d6c:	cec080e7          	jalr	-788(ra) # 80004a54 <install_trans>
    log.lh.n = 0;
    80004d70:	0009f797          	auipc	a5,0x9f
    80004d74:	e007ae23          	sw	zero,-484(a5) # 800a3b8c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004d78:	00000097          	auipc	ra,0x0
    80004d7c:	c72080e7          	jalr	-910(ra) # 800049ea <write_head>
    80004d80:	69e2                	ld	s3,24(sp)
    80004d82:	6a42                	ld	s4,16(sp)
    80004d84:	6aa2                	ld	s5,8(sp)
    80004d86:	bdc5                	j	80004c76 <end_op+0x4c>

0000000080004d88 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004d88:	1101                	addi	sp,sp,-32
    80004d8a:	ec06                	sd	ra,24(sp)
    80004d8c:	e822                	sd	s0,16(sp)
    80004d8e:	e426                	sd	s1,8(sp)
    80004d90:	e04a                	sd	s2,0(sp)
    80004d92:	1000                	addi	s0,sp,32
    80004d94:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004d96:	0009f917          	auipc	s2,0x9f
    80004d9a:	dca90913          	addi	s2,s2,-566 # 800a3b60 <log>
    80004d9e:	854a                	mv	a0,s2
    80004da0:	ffffc097          	auipc	ra,0xffffc
    80004da4:	f6a080e7          	jalr	-150(ra) # 80000d0a <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004da8:	02c92603          	lw	a2,44(s2)
    80004dac:	47f5                	li	a5,29
    80004dae:	06c7c563          	blt	a5,a2,80004e18 <log_write+0x90>
    80004db2:	0009f797          	auipc	a5,0x9f
    80004db6:	dca7a783          	lw	a5,-566(a5) # 800a3b7c <log+0x1c>
    80004dba:	37fd                	addiw	a5,a5,-1
    80004dbc:	04f65e63          	bge	a2,a5,80004e18 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004dc0:	0009f797          	auipc	a5,0x9f
    80004dc4:	dc07a783          	lw	a5,-576(a5) # 800a3b80 <log+0x20>
    80004dc8:	06f05063          	blez	a5,80004e28 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004dcc:	4781                	li	a5,0
    80004dce:	06c05563          	blez	a2,80004e38 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004dd2:	44cc                	lw	a1,12(s1)
    80004dd4:	0009f717          	auipc	a4,0x9f
    80004dd8:	dbc70713          	addi	a4,a4,-580 # 800a3b90 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004ddc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004dde:	4314                	lw	a3,0(a4)
    80004de0:	04b68c63          	beq	a3,a1,80004e38 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004de4:	2785                	addiw	a5,a5,1
    80004de6:	0711                	addi	a4,a4,4
    80004de8:	fef61be3          	bne	a2,a5,80004dde <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004dec:	0621                	addi	a2,a2,8
    80004dee:	060a                	slli	a2,a2,0x2
    80004df0:	0009f797          	auipc	a5,0x9f
    80004df4:	d7078793          	addi	a5,a5,-656 # 800a3b60 <log>
    80004df8:	97b2                	add	a5,a5,a2
    80004dfa:	44d8                	lw	a4,12(s1)
    80004dfc:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004dfe:	8526                	mv	a0,s1
    80004e00:	fffff097          	auipc	ra,0xfffff
    80004e04:	d7a080e7          	jalr	-646(ra) # 80003b7a <bpin>
    log.lh.n++;
    80004e08:	0009f717          	auipc	a4,0x9f
    80004e0c:	d5870713          	addi	a4,a4,-680 # 800a3b60 <log>
    80004e10:	575c                	lw	a5,44(a4)
    80004e12:	2785                	addiw	a5,a5,1
    80004e14:	d75c                	sw	a5,44(a4)
    80004e16:	a82d                	j	80004e50 <log_write+0xc8>
    panic("too big a transaction");
    80004e18:	00004517          	auipc	a0,0x4
    80004e1c:	a0050513          	addi	a0,a0,-1536 # 80008818 <__func__.1+0x810>
    80004e20:	ffffb097          	auipc	ra,0xffffb
    80004e24:	740080e7          	jalr	1856(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004e28:	00004517          	auipc	a0,0x4
    80004e2c:	a0850513          	addi	a0,a0,-1528 # 80008830 <__func__.1+0x828>
    80004e30:	ffffb097          	auipc	ra,0xffffb
    80004e34:	730080e7          	jalr	1840(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004e38:	00878693          	addi	a3,a5,8
    80004e3c:	068a                	slli	a3,a3,0x2
    80004e3e:	0009f717          	auipc	a4,0x9f
    80004e42:	d2270713          	addi	a4,a4,-734 # 800a3b60 <log>
    80004e46:	9736                	add	a4,a4,a3
    80004e48:	44d4                	lw	a3,12(s1)
    80004e4a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004e4c:	faf609e3          	beq	a2,a5,80004dfe <log_write+0x76>
  }
  release(&log.lock);
    80004e50:	0009f517          	auipc	a0,0x9f
    80004e54:	d1050513          	addi	a0,a0,-752 # 800a3b60 <log>
    80004e58:	ffffc097          	auipc	ra,0xffffc
    80004e5c:	f66080e7          	jalr	-154(ra) # 80000dbe <release>
}
    80004e60:	60e2                	ld	ra,24(sp)
    80004e62:	6442                	ld	s0,16(sp)
    80004e64:	64a2                	ld	s1,8(sp)
    80004e66:	6902                	ld	s2,0(sp)
    80004e68:	6105                	addi	sp,sp,32
    80004e6a:	8082                	ret

0000000080004e6c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004e6c:	1101                	addi	sp,sp,-32
    80004e6e:	ec06                	sd	ra,24(sp)
    80004e70:	e822                	sd	s0,16(sp)
    80004e72:	e426                	sd	s1,8(sp)
    80004e74:	e04a                	sd	s2,0(sp)
    80004e76:	1000                	addi	s0,sp,32
    80004e78:	84aa                	mv	s1,a0
    80004e7a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004e7c:	00004597          	auipc	a1,0x4
    80004e80:	9d458593          	addi	a1,a1,-1580 # 80008850 <__func__.1+0x848>
    80004e84:	0521                	addi	a0,a0,8
    80004e86:	ffffc097          	auipc	ra,0xffffc
    80004e8a:	df4080e7          	jalr	-524(ra) # 80000c7a <initlock>
  lk->name = name;
    80004e8e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004e92:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004e96:	0204a423          	sw	zero,40(s1)
}
    80004e9a:	60e2                	ld	ra,24(sp)
    80004e9c:	6442                	ld	s0,16(sp)
    80004e9e:	64a2                	ld	s1,8(sp)
    80004ea0:	6902                	ld	s2,0(sp)
    80004ea2:	6105                	addi	sp,sp,32
    80004ea4:	8082                	ret

0000000080004ea6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004ea6:	1101                	addi	sp,sp,-32
    80004ea8:	ec06                	sd	ra,24(sp)
    80004eaa:	e822                	sd	s0,16(sp)
    80004eac:	e426                	sd	s1,8(sp)
    80004eae:	e04a                	sd	s2,0(sp)
    80004eb0:	1000                	addi	s0,sp,32
    80004eb2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004eb4:	00850913          	addi	s2,a0,8
    80004eb8:	854a                	mv	a0,s2
    80004eba:	ffffc097          	auipc	ra,0xffffc
    80004ebe:	e50080e7          	jalr	-432(ra) # 80000d0a <acquire>
  while (lk->locked) {
    80004ec2:	409c                	lw	a5,0(s1)
    80004ec4:	cb89                	beqz	a5,80004ed6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004ec6:	85ca                	mv	a1,s2
    80004ec8:	8526                	mv	a0,s1
    80004eca:	ffffe097          	auipc	ra,0xffffe
    80004ece:	9ac080e7          	jalr	-1620(ra) # 80002876 <sleep>
  while (lk->locked) {
    80004ed2:	409c                	lw	a5,0(s1)
    80004ed4:	fbed                	bnez	a5,80004ec6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004ed6:	4785                	li	a5,1
    80004ed8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004eda:	ffffd097          	auipc	ra,0xffffd
    80004ede:	1fa080e7          	jalr	506(ra) # 800020d4 <myproc>
    80004ee2:	591c                	lw	a5,48(a0)
    80004ee4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004ee6:	854a                	mv	a0,s2
    80004ee8:	ffffc097          	auipc	ra,0xffffc
    80004eec:	ed6080e7          	jalr	-298(ra) # 80000dbe <release>
}
    80004ef0:	60e2                	ld	ra,24(sp)
    80004ef2:	6442                	ld	s0,16(sp)
    80004ef4:	64a2                	ld	s1,8(sp)
    80004ef6:	6902                	ld	s2,0(sp)
    80004ef8:	6105                	addi	sp,sp,32
    80004efa:	8082                	ret

0000000080004efc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004efc:	1101                	addi	sp,sp,-32
    80004efe:	ec06                	sd	ra,24(sp)
    80004f00:	e822                	sd	s0,16(sp)
    80004f02:	e426                	sd	s1,8(sp)
    80004f04:	e04a                	sd	s2,0(sp)
    80004f06:	1000                	addi	s0,sp,32
    80004f08:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004f0a:	00850913          	addi	s2,a0,8
    80004f0e:	854a                	mv	a0,s2
    80004f10:	ffffc097          	auipc	ra,0xffffc
    80004f14:	dfa080e7          	jalr	-518(ra) # 80000d0a <acquire>
  lk->locked = 0;
    80004f18:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004f1c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004f20:	8526                	mv	a0,s1
    80004f22:	ffffe097          	auipc	ra,0xffffe
    80004f26:	9b8080e7          	jalr	-1608(ra) # 800028da <wakeup>
  release(&lk->lk);
    80004f2a:	854a                	mv	a0,s2
    80004f2c:	ffffc097          	auipc	ra,0xffffc
    80004f30:	e92080e7          	jalr	-366(ra) # 80000dbe <release>
}
    80004f34:	60e2                	ld	ra,24(sp)
    80004f36:	6442                	ld	s0,16(sp)
    80004f38:	64a2                	ld	s1,8(sp)
    80004f3a:	6902                	ld	s2,0(sp)
    80004f3c:	6105                	addi	sp,sp,32
    80004f3e:	8082                	ret

0000000080004f40 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004f40:	7179                	addi	sp,sp,-48
    80004f42:	f406                	sd	ra,40(sp)
    80004f44:	f022                	sd	s0,32(sp)
    80004f46:	ec26                	sd	s1,24(sp)
    80004f48:	e84a                	sd	s2,16(sp)
    80004f4a:	1800                	addi	s0,sp,48
    80004f4c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004f4e:	00850913          	addi	s2,a0,8
    80004f52:	854a                	mv	a0,s2
    80004f54:	ffffc097          	auipc	ra,0xffffc
    80004f58:	db6080e7          	jalr	-586(ra) # 80000d0a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004f5c:	409c                	lw	a5,0(s1)
    80004f5e:	ef91                	bnez	a5,80004f7a <holdingsleep+0x3a>
    80004f60:	4481                	li	s1,0
  release(&lk->lk);
    80004f62:	854a                	mv	a0,s2
    80004f64:	ffffc097          	auipc	ra,0xffffc
    80004f68:	e5a080e7          	jalr	-422(ra) # 80000dbe <release>
  return r;
}
    80004f6c:	8526                	mv	a0,s1
    80004f6e:	70a2                	ld	ra,40(sp)
    80004f70:	7402                	ld	s0,32(sp)
    80004f72:	64e2                	ld	s1,24(sp)
    80004f74:	6942                	ld	s2,16(sp)
    80004f76:	6145                	addi	sp,sp,48
    80004f78:	8082                	ret
    80004f7a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004f7c:	0284a983          	lw	s3,40(s1)
    80004f80:	ffffd097          	auipc	ra,0xffffd
    80004f84:	154080e7          	jalr	340(ra) # 800020d4 <myproc>
    80004f88:	5904                	lw	s1,48(a0)
    80004f8a:	413484b3          	sub	s1,s1,s3
    80004f8e:	0014b493          	seqz	s1,s1
    80004f92:	69a2                	ld	s3,8(sp)
    80004f94:	b7f9                	j	80004f62 <holdingsleep+0x22>

0000000080004f96 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004f96:	1141                	addi	sp,sp,-16
    80004f98:	e406                	sd	ra,8(sp)
    80004f9a:	e022                	sd	s0,0(sp)
    80004f9c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004f9e:	00004597          	auipc	a1,0x4
    80004fa2:	8c258593          	addi	a1,a1,-1854 # 80008860 <__func__.1+0x858>
    80004fa6:	0009f517          	auipc	a0,0x9f
    80004faa:	d0250513          	addi	a0,a0,-766 # 800a3ca8 <ftable>
    80004fae:	ffffc097          	auipc	ra,0xffffc
    80004fb2:	ccc080e7          	jalr	-820(ra) # 80000c7a <initlock>
}
    80004fb6:	60a2                	ld	ra,8(sp)
    80004fb8:	6402                	ld	s0,0(sp)
    80004fba:	0141                	addi	sp,sp,16
    80004fbc:	8082                	ret

0000000080004fbe <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004fbe:	1101                	addi	sp,sp,-32
    80004fc0:	ec06                	sd	ra,24(sp)
    80004fc2:	e822                	sd	s0,16(sp)
    80004fc4:	e426                	sd	s1,8(sp)
    80004fc6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004fc8:	0009f517          	auipc	a0,0x9f
    80004fcc:	ce050513          	addi	a0,a0,-800 # 800a3ca8 <ftable>
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	d3a080e7          	jalr	-710(ra) # 80000d0a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004fd8:	0009f497          	auipc	s1,0x9f
    80004fdc:	ce848493          	addi	s1,s1,-792 # 800a3cc0 <ftable+0x18>
    80004fe0:	000a0717          	auipc	a4,0xa0
    80004fe4:	c8070713          	addi	a4,a4,-896 # 800a4c60 <disk>
    if(f->ref == 0){
    80004fe8:	40dc                	lw	a5,4(s1)
    80004fea:	cf99                	beqz	a5,80005008 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004fec:	02848493          	addi	s1,s1,40
    80004ff0:	fee49ce3          	bne	s1,a4,80004fe8 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004ff4:	0009f517          	auipc	a0,0x9f
    80004ff8:	cb450513          	addi	a0,a0,-844 # 800a3ca8 <ftable>
    80004ffc:	ffffc097          	auipc	ra,0xffffc
    80005000:	dc2080e7          	jalr	-574(ra) # 80000dbe <release>
  return 0;
    80005004:	4481                	li	s1,0
    80005006:	a819                	j	8000501c <filealloc+0x5e>
      f->ref = 1;
    80005008:	4785                	li	a5,1
    8000500a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000500c:	0009f517          	auipc	a0,0x9f
    80005010:	c9c50513          	addi	a0,a0,-868 # 800a3ca8 <ftable>
    80005014:	ffffc097          	auipc	ra,0xffffc
    80005018:	daa080e7          	jalr	-598(ra) # 80000dbe <release>
}
    8000501c:	8526                	mv	a0,s1
    8000501e:	60e2                	ld	ra,24(sp)
    80005020:	6442                	ld	s0,16(sp)
    80005022:	64a2                	ld	s1,8(sp)
    80005024:	6105                	addi	sp,sp,32
    80005026:	8082                	ret

0000000080005028 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005028:	1101                	addi	sp,sp,-32
    8000502a:	ec06                	sd	ra,24(sp)
    8000502c:	e822                	sd	s0,16(sp)
    8000502e:	e426                	sd	s1,8(sp)
    80005030:	1000                	addi	s0,sp,32
    80005032:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005034:	0009f517          	auipc	a0,0x9f
    80005038:	c7450513          	addi	a0,a0,-908 # 800a3ca8 <ftable>
    8000503c:	ffffc097          	auipc	ra,0xffffc
    80005040:	cce080e7          	jalr	-818(ra) # 80000d0a <acquire>
  if(f->ref < 1)
    80005044:	40dc                	lw	a5,4(s1)
    80005046:	02f05263          	blez	a5,8000506a <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000504a:	2785                	addiw	a5,a5,1
    8000504c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000504e:	0009f517          	auipc	a0,0x9f
    80005052:	c5a50513          	addi	a0,a0,-934 # 800a3ca8 <ftable>
    80005056:	ffffc097          	auipc	ra,0xffffc
    8000505a:	d68080e7          	jalr	-664(ra) # 80000dbe <release>
  return f;
}
    8000505e:	8526                	mv	a0,s1
    80005060:	60e2                	ld	ra,24(sp)
    80005062:	6442                	ld	s0,16(sp)
    80005064:	64a2                	ld	s1,8(sp)
    80005066:	6105                	addi	sp,sp,32
    80005068:	8082                	ret
    panic("filedup");
    8000506a:	00003517          	auipc	a0,0x3
    8000506e:	7fe50513          	addi	a0,a0,2046 # 80008868 <__func__.1+0x860>
    80005072:	ffffb097          	auipc	ra,0xffffb
    80005076:	4ee080e7          	jalr	1262(ra) # 80000560 <panic>

000000008000507a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000507a:	7139                	addi	sp,sp,-64
    8000507c:	fc06                	sd	ra,56(sp)
    8000507e:	f822                	sd	s0,48(sp)
    80005080:	f426                	sd	s1,40(sp)
    80005082:	0080                	addi	s0,sp,64
    80005084:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005086:	0009f517          	auipc	a0,0x9f
    8000508a:	c2250513          	addi	a0,a0,-990 # 800a3ca8 <ftable>
    8000508e:	ffffc097          	auipc	ra,0xffffc
    80005092:	c7c080e7          	jalr	-900(ra) # 80000d0a <acquire>
  if(f->ref < 1)
    80005096:	40dc                	lw	a5,4(s1)
    80005098:	04f05c63          	blez	a5,800050f0 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    8000509c:	37fd                	addiw	a5,a5,-1
    8000509e:	0007871b          	sext.w	a4,a5
    800050a2:	c0dc                	sw	a5,4(s1)
    800050a4:	06e04263          	bgtz	a4,80005108 <fileclose+0x8e>
    800050a8:	f04a                	sd	s2,32(sp)
    800050aa:	ec4e                	sd	s3,24(sp)
    800050ac:	e852                	sd	s4,16(sp)
    800050ae:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800050b0:	0004a903          	lw	s2,0(s1)
    800050b4:	0094ca83          	lbu	s5,9(s1)
    800050b8:	0104ba03          	ld	s4,16(s1)
    800050bc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800050c0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800050c4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800050c8:	0009f517          	auipc	a0,0x9f
    800050cc:	be050513          	addi	a0,a0,-1056 # 800a3ca8 <ftable>
    800050d0:	ffffc097          	auipc	ra,0xffffc
    800050d4:	cee080e7          	jalr	-786(ra) # 80000dbe <release>

  if(ff.type == FD_PIPE){
    800050d8:	4785                	li	a5,1
    800050da:	04f90463          	beq	s2,a5,80005122 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800050de:	3979                	addiw	s2,s2,-2
    800050e0:	4785                	li	a5,1
    800050e2:	0527fb63          	bgeu	a5,s2,80005138 <fileclose+0xbe>
    800050e6:	7902                	ld	s2,32(sp)
    800050e8:	69e2                	ld	s3,24(sp)
    800050ea:	6a42                	ld	s4,16(sp)
    800050ec:	6aa2                	ld	s5,8(sp)
    800050ee:	a02d                	j	80005118 <fileclose+0x9e>
    800050f0:	f04a                	sd	s2,32(sp)
    800050f2:	ec4e                	sd	s3,24(sp)
    800050f4:	e852                	sd	s4,16(sp)
    800050f6:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800050f8:	00003517          	auipc	a0,0x3
    800050fc:	77850513          	addi	a0,a0,1912 # 80008870 <__func__.1+0x868>
    80005100:	ffffb097          	auipc	ra,0xffffb
    80005104:	460080e7          	jalr	1120(ra) # 80000560 <panic>
    release(&ftable.lock);
    80005108:	0009f517          	auipc	a0,0x9f
    8000510c:	ba050513          	addi	a0,a0,-1120 # 800a3ca8 <ftable>
    80005110:	ffffc097          	auipc	ra,0xffffc
    80005114:	cae080e7          	jalr	-850(ra) # 80000dbe <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80005118:	70e2                	ld	ra,56(sp)
    8000511a:	7442                	ld	s0,48(sp)
    8000511c:	74a2                	ld	s1,40(sp)
    8000511e:	6121                	addi	sp,sp,64
    80005120:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005122:	85d6                	mv	a1,s5
    80005124:	8552                	mv	a0,s4
    80005126:	00000097          	auipc	ra,0x0
    8000512a:	3a2080e7          	jalr	930(ra) # 800054c8 <pipeclose>
    8000512e:	7902                	ld	s2,32(sp)
    80005130:	69e2                	ld	s3,24(sp)
    80005132:	6a42                	ld	s4,16(sp)
    80005134:	6aa2                	ld	s5,8(sp)
    80005136:	b7cd                	j	80005118 <fileclose+0x9e>
    begin_op();
    80005138:	00000097          	auipc	ra,0x0
    8000513c:	a78080e7          	jalr	-1416(ra) # 80004bb0 <begin_op>
    iput(ff.ip);
    80005140:	854e                	mv	a0,s3
    80005142:	fffff097          	auipc	ra,0xfffff
    80005146:	25e080e7          	jalr	606(ra) # 800043a0 <iput>
    end_op();
    8000514a:	00000097          	auipc	ra,0x0
    8000514e:	ae0080e7          	jalr	-1312(ra) # 80004c2a <end_op>
    80005152:	7902                	ld	s2,32(sp)
    80005154:	69e2                	ld	s3,24(sp)
    80005156:	6a42                	ld	s4,16(sp)
    80005158:	6aa2                	ld	s5,8(sp)
    8000515a:	bf7d                	j	80005118 <fileclose+0x9e>

000000008000515c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000515c:	715d                	addi	sp,sp,-80
    8000515e:	e486                	sd	ra,72(sp)
    80005160:	e0a2                	sd	s0,64(sp)
    80005162:	fc26                	sd	s1,56(sp)
    80005164:	f44e                	sd	s3,40(sp)
    80005166:	0880                	addi	s0,sp,80
    80005168:	84aa                	mv	s1,a0
    8000516a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000516c:	ffffd097          	auipc	ra,0xffffd
    80005170:	f68080e7          	jalr	-152(ra) # 800020d4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005174:	409c                	lw	a5,0(s1)
    80005176:	37f9                	addiw	a5,a5,-2
    80005178:	4705                	li	a4,1
    8000517a:	04f76863          	bltu	a4,a5,800051ca <filestat+0x6e>
    8000517e:	f84a                	sd	s2,48(sp)
    80005180:	892a                	mv	s2,a0
    ilock(f->ip);
    80005182:	6c88                	ld	a0,24(s1)
    80005184:	fffff097          	auipc	ra,0xfffff
    80005188:	05e080e7          	jalr	94(ra) # 800041e2 <ilock>
    stati(f->ip, &st);
    8000518c:	fb840593          	addi	a1,s0,-72
    80005190:	6c88                	ld	a0,24(s1)
    80005192:	fffff097          	auipc	ra,0xfffff
    80005196:	2de080e7          	jalr	734(ra) # 80004470 <stati>
    iunlock(f->ip);
    8000519a:	6c88                	ld	a0,24(s1)
    8000519c:	fffff097          	auipc	ra,0xfffff
    800051a0:	10c080e7          	jalr	268(ra) # 800042a8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800051a4:	46e1                	li	a3,24
    800051a6:	fb840613          	addi	a2,s0,-72
    800051aa:	85ce                	mv	a1,s3
    800051ac:	05093503          	ld	a0,80(s2)
    800051b0:	ffffd097          	auipc	ra,0xffffd
    800051b4:	97a080e7          	jalr	-1670(ra) # 80001b2a <copyout>
    800051b8:	41f5551b          	sraiw	a0,a0,0x1f
    800051bc:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800051be:	60a6                	ld	ra,72(sp)
    800051c0:	6406                	ld	s0,64(sp)
    800051c2:	74e2                	ld	s1,56(sp)
    800051c4:	79a2                	ld	s3,40(sp)
    800051c6:	6161                	addi	sp,sp,80
    800051c8:	8082                	ret
  return -1;
    800051ca:	557d                	li	a0,-1
    800051cc:	bfcd                	j	800051be <filestat+0x62>

00000000800051ce <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800051ce:	7179                	addi	sp,sp,-48
    800051d0:	f406                	sd	ra,40(sp)
    800051d2:	f022                	sd	s0,32(sp)
    800051d4:	e84a                	sd	s2,16(sp)
    800051d6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800051d8:	00854783          	lbu	a5,8(a0)
    800051dc:	cbc5                	beqz	a5,8000528c <fileread+0xbe>
    800051de:	ec26                	sd	s1,24(sp)
    800051e0:	e44e                	sd	s3,8(sp)
    800051e2:	84aa                	mv	s1,a0
    800051e4:	89ae                	mv	s3,a1
    800051e6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800051e8:	411c                	lw	a5,0(a0)
    800051ea:	4705                	li	a4,1
    800051ec:	04e78963          	beq	a5,a4,8000523e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800051f0:	470d                	li	a4,3
    800051f2:	04e78f63          	beq	a5,a4,80005250 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800051f6:	4709                	li	a4,2
    800051f8:	08e79263          	bne	a5,a4,8000527c <fileread+0xae>
    ilock(f->ip);
    800051fc:	6d08                	ld	a0,24(a0)
    800051fe:	fffff097          	auipc	ra,0xfffff
    80005202:	fe4080e7          	jalr	-28(ra) # 800041e2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005206:	874a                	mv	a4,s2
    80005208:	5094                	lw	a3,32(s1)
    8000520a:	864e                	mv	a2,s3
    8000520c:	4585                	li	a1,1
    8000520e:	6c88                	ld	a0,24(s1)
    80005210:	fffff097          	auipc	ra,0xfffff
    80005214:	28a080e7          	jalr	650(ra) # 8000449a <readi>
    80005218:	892a                	mv	s2,a0
    8000521a:	00a05563          	blez	a0,80005224 <fileread+0x56>
      f->off += r;
    8000521e:	509c                	lw	a5,32(s1)
    80005220:	9fa9                	addw	a5,a5,a0
    80005222:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005224:	6c88                	ld	a0,24(s1)
    80005226:	fffff097          	auipc	ra,0xfffff
    8000522a:	082080e7          	jalr	130(ra) # 800042a8 <iunlock>
    8000522e:	64e2                	ld	s1,24(sp)
    80005230:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80005232:	854a                	mv	a0,s2
    80005234:	70a2                	ld	ra,40(sp)
    80005236:	7402                	ld	s0,32(sp)
    80005238:	6942                	ld	s2,16(sp)
    8000523a:	6145                	addi	sp,sp,48
    8000523c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000523e:	6908                	ld	a0,16(a0)
    80005240:	00000097          	auipc	ra,0x0
    80005244:	400080e7          	jalr	1024(ra) # 80005640 <piperead>
    80005248:	892a                	mv	s2,a0
    8000524a:	64e2                	ld	s1,24(sp)
    8000524c:	69a2                	ld	s3,8(sp)
    8000524e:	b7d5                	j	80005232 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005250:	02451783          	lh	a5,36(a0)
    80005254:	03079693          	slli	a3,a5,0x30
    80005258:	92c1                	srli	a3,a3,0x30
    8000525a:	4725                	li	a4,9
    8000525c:	02d76a63          	bltu	a4,a3,80005290 <fileread+0xc2>
    80005260:	0792                	slli	a5,a5,0x4
    80005262:	0009f717          	auipc	a4,0x9f
    80005266:	9a670713          	addi	a4,a4,-1626 # 800a3c08 <devsw>
    8000526a:	97ba                	add	a5,a5,a4
    8000526c:	639c                	ld	a5,0(a5)
    8000526e:	c78d                	beqz	a5,80005298 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80005270:	4505                	li	a0,1
    80005272:	9782                	jalr	a5
    80005274:	892a                	mv	s2,a0
    80005276:	64e2                	ld	s1,24(sp)
    80005278:	69a2                	ld	s3,8(sp)
    8000527a:	bf65                	j	80005232 <fileread+0x64>
    panic("fileread");
    8000527c:	00003517          	auipc	a0,0x3
    80005280:	60450513          	addi	a0,a0,1540 # 80008880 <__func__.1+0x878>
    80005284:	ffffb097          	auipc	ra,0xffffb
    80005288:	2dc080e7          	jalr	732(ra) # 80000560 <panic>
    return -1;
    8000528c:	597d                	li	s2,-1
    8000528e:	b755                	j	80005232 <fileread+0x64>
      return -1;
    80005290:	597d                	li	s2,-1
    80005292:	64e2                	ld	s1,24(sp)
    80005294:	69a2                	ld	s3,8(sp)
    80005296:	bf71                	j	80005232 <fileread+0x64>
    80005298:	597d                	li	s2,-1
    8000529a:	64e2                	ld	s1,24(sp)
    8000529c:	69a2                	ld	s3,8(sp)
    8000529e:	bf51                	j	80005232 <fileread+0x64>

00000000800052a0 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800052a0:	00954783          	lbu	a5,9(a0)
    800052a4:	12078963          	beqz	a5,800053d6 <filewrite+0x136>
{
    800052a8:	715d                	addi	sp,sp,-80
    800052aa:	e486                	sd	ra,72(sp)
    800052ac:	e0a2                	sd	s0,64(sp)
    800052ae:	f84a                	sd	s2,48(sp)
    800052b0:	f052                	sd	s4,32(sp)
    800052b2:	e85a                	sd	s6,16(sp)
    800052b4:	0880                	addi	s0,sp,80
    800052b6:	892a                	mv	s2,a0
    800052b8:	8b2e                	mv	s6,a1
    800052ba:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800052bc:	411c                	lw	a5,0(a0)
    800052be:	4705                	li	a4,1
    800052c0:	02e78763          	beq	a5,a4,800052ee <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800052c4:	470d                	li	a4,3
    800052c6:	02e78a63          	beq	a5,a4,800052fa <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800052ca:	4709                	li	a4,2
    800052cc:	0ee79863          	bne	a5,a4,800053bc <filewrite+0x11c>
    800052d0:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800052d2:	0cc05463          	blez	a2,8000539a <filewrite+0xfa>
    800052d6:	fc26                	sd	s1,56(sp)
    800052d8:	ec56                	sd	s5,24(sp)
    800052da:	e45e                	sd	s7,8(sp)
    800052dc:	e062                	sd	s8,0(sp)
    int i = 0;
    800052de:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800052e0:	6b85                	lui	s7,0x1
    800052e2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800052e6:	6c05                	lui	s8,0x1
    800052e8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800052ec:	a851                	j	80005380 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800052ee:	6908                	ld	a0,16(a0)
    800052f0:	00000097          	auipc	ra,0x0
    800052f4:	248080e7          	jalr	584(ra) # 80005538 <pipewrite>
    800052f8:	a85d                	j	800053ae <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800052fa:	02451783          	lh	a5,36(a0)
    800052fe:	03079693          	slli	a3,a5,0x30
    80005302:	92c1                	srli	a3,a3,0x30
    80005304:	4725                	li	a4,9
    80005306:	0cd76a63          	bltu	a4,a3,800053da <filewrite+0x13a>
    8000530a:	0792                	slli	a5,a5,0x4
    8000530c:	0009f717          	auipc	a4,0x9f
    80005310:	8fc70713          	addi	a4,a4,-1796 # 800a3c08 <devsw>
    80005314:	97ba                	add	a5,a5,a4
    80005316:	679c                	ld	a5,8(a5)
    80005318:	c3f9                	beqz	a5,800053de <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    8000531a:	4505                	li	a0,1
    8000531c:	9782                	jalr	a5
    8000531e:	a841                	j	800053ae <filewrite+0x10e>
      if(n1 > max)
    80005320:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80005324:	00000097          	auipc	ra,0x0
    80005328:	88c080e7          	jalr	-1908(ra) # 80004bb0 <begin_op>
      ilock(f->ip);
    8000532c:	01893503          	ld	a0,24(s2)
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	eb2080e7          	jalr	-334(ra) # 800041e2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005338:	8756                	mv	a4,s5
    8000533a:	02092683          	lw	a3,32(s2)
    8000533e:	01698633          	add	a2,s3,s6
    80005342:	4585                	li	a1,1
    80005344:	01893503          	ld	a0,24(s2)
    80005348:	fffff097          	auipc	ra,0xfffff
    8000534c:	262080e7          	jalr	610(ra) # 800045aa <writei>
    80005350:	84aa                	mv	s1,a0
    80005352:	00a05763          	blez	a0,80005360 <filewrite+0xc0>
        f->off += r;
    80005356:	02092783          	lw	a5,32(s2)
    8000535a:	9fa9                	addw	a5,a5,a0
    8000535c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005360:	01893503          	ld	a0,24(s2)
    80005364:	fffff097          	auipc	ra,0xfffff
    80005368:	f44080e7          	jalr	-188(ra) # 800042a8 <iunlock>
      end_op();
    8000536c:	00000097          	auipc	ra,0x0
    80005370:	8be080e7          	jalr	-1858(ra) # 80004c2a <end_op>

      if(r != n1){
    80005374:	029a9563          	bne	s5,s1,8000539e <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80005378:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000537c:	0149da63          	bge	s3,s4,80005390 <filewrite+0xf0>
      int n1 = n - i;
    80005380:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80005384:	0004879b          	sext.w	a5,s1
    80005388:	f8fbdce3          	bge	s7,a5,80005320 <filewrite+0x80>
    8000538c:	84e2                	mv	s1,s8
    8000538e:	bf49                	j	80005320 <filewrite+0x80>
    80005390:	74e2                	ld	s1,56(sp)
    80005392:	6ae2                	ld	s5,24(sp)
    80005394:	6ba2                	ld	s7,8(sp)
    80005396:	6c02                	ld	s8,0(sp)
    80005398:	a039                	j	800053a6 <filewrite+0x106>
    int i = 0;
    8000539a:	4981                	li	s3,0
    8000539c:	a029                	j	800053a6 <filewrite+0x106>
    8000539e:	74e2                	ld	s1,56(sp)
    800053a0:	6ae2                	ld	s5,24(sp)
    800053a2:	6ba2                	ld	s7,8(sp)
    800053a4:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800053a6:	033a1e63          	bne	s4,s3,800053e2 <filewrite+0x142>
    800053aa:	8552                	mv	a0,s4
    800053ac:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800053ae:	60a6                	ld	ra,72(sp)
    800053b0:	6406                	ld	s0,64(sp)
    800053b2:	7942                	ld	s2,48(sp)
    800053b4:	7a02                	ld	s4,32(sp)
    800053b6:	6b42                	ld	s6,16(sp)
    800053b8:	6161                	addi	sp,sp,80
    800053ba:	8082                	ret
    800053bc:	fc26                	sd	s1,56(sp)
    800053be:	f44e                	sd	s3,40(sp)
    800053c0:	ec56                	sd	s5,24(sp)
    800053c2:	e45e                	sd	s7,8(sp)
    800053c4:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800053c6:	00003517          	auipc	a0,0x3
    800053ca:	4ca50513          	addi	a0,a0,1226 # 80008890 <__func__.1+0x888>
    800053ce:	ffffb097          	auipc	ra,0xffffb
    800053d2:	192080e7          	jalr	402(ra) # 80000560 <panic>
    return -1;
    800053d6:	557d                	li	a0,-1
}
    800053d8:	8082                	ret
      return -1;
    800053da:	557d                	li	a0,-1
    800053dc:	bfc9                	j	800053ae <filewrite+0x10e>
    800053de:	557d                	li	a0,-1
    800053e0:	b7f9                	j	800053ae <filewrite+0x10e>
    ret = (i == n ? n : -1);
    800053e2:	557d                	li	a0,-1
    800053e4:	79a2                	ld	s3,40(sp)
    800053e6:	b7e1                	j	800053ae <filewrite+0x10e>

00000000800053e8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800053e8:	7179                	addi	sp,sp,-48
    800053ea:	f406                	sd	ra,40(sp)
    800053ec:	f022                	sd	s0,32(sp)
    800053ee:	ec26                	sd	s1,24(sp)
    800053f0:	e052                	sd	s4,0(sp)
    800053f2:	1800                	addi	s0,sp,48
    800053f4:	84aa                	mv	s1,a0
    800053f6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800053f8:	0005b023          	sd	zero,0(a1)
    800053fc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005400:	00000097          	auipc	ra,0x0
    80005404:	bbe080e7          	jalr	-1090(ra) # 80004fbe <filealloc>
    80005408:	e088                	sd	a0,0(s1)
    8000540a:	cd49                	beqz	a0,800054a4 <pipealloc+0xbc>
    8000540c:	00000097          	auipc	ra,0x0
    80005410:	bb2080e7          	jalr	-1102(ra) # 80004fbe <filealloc>
    80005414:	00aa3023          	sd	a0,0(s4)
    80005418:	c141                	beqz	a0,80005498 <pipealloc+0xb0>
    8000541a:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000541c:	ffffb097          	auipc	ra,0xffffb
    80005420:	7a8080e7          	jalr	1960(ra) # 80000bc4 <kalloc>
    80005424:	892a                	mv	s2,a0
    80005426:	c13d                	beqz	a0,8000548c <pipealloc+0xa4>
    80005428:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000542a:	4985                	li	s3,1
    8000542c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005430:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005434:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005438:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000543c:	00003597          	auipc	a1,0x3
    80005440:	46458593          	addi	a1,a1,1124 # 800088a0 <__func__.1+0x898>
    80005444:	ffffc097          	auipc	ra,0xffffc
    80005448:	836080e7          	jalr	-1994(ra) # 80000c7a <initlock>
  (*f0)->type = FD_PIPE;
    8000544c:	609c                	ld	a5,0(s1)
    8000544e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005452:	609c                	ld	a5,0(s1)
    80005454:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005458:	609c                	ld	a5,0(s1)
    8000545a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000545e:	609c                	ld	a5,0(s1)
    80005460:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005464:	000a3783          	ld	a5,0(s4)
    80005468:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000546c:	000a3783          	ld	a5,0(s4)
    80005470:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005474:	000a3783          	ld	a5,0(s4)
    80005478:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000547c:	000a3783          	ld	a5,0(s4)
    80005480:	0127b823          	sd	s2,16(a5)
  return 0;
    80005484:	4501                	li	a0,0
    80005486:	6942                	ld	s2,16(sp)
    80005488:	69a2                	ld	s3,8(sp)
    8000548a:	a03d                	j	800054b8 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000548c:	6088                	ld	a0,0(s1)
    8000548e:	c119                	beqz	a0,80005494 <pipealloc+0xac>
    80005490:	6942                	ld	s2,16(sp)
    80005492:	a029                	j	8000549c <pipealloc+0xb4>
    80005494:	6942                	ld	s2,16(sp)
    80005496:	a039                	j	800054a4 <pipealloc+0xbc>
    80005498:	6088                	ld	a0,0(s1)
    8000549a:	c50d                	beqz	a0,800054c4 <pipealloc+0xdc>
    fileclose(*f0);
    8000549c:	00000097          	auipc	ra,0x0
    800054a0:	bde080e7          	jalr	-1058(ra) # 8000507a <fileclose>
  if(*f1)
    800054a4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800054a8:	557d                	li	a0,-1
  if(*f1)
    800054aa:	c799                	beqz	a5,800054b8 <pipealloc+0xd0>
    fileclose(*f1);
    800054ac:	853e                	mv	a0,a5
    800054ae:	00000097          	auipc	ra,0x0
    800054b2:	bcc080e7          	jalr	-1076(ra) # 8000507a <fileclose>
  return -1;
    800054b6:	557d                	li	a0,-1
}
    800054b8:	70a2                	ld	ra,40(sp)
    800054ba:	7402                	ld	s0,32(sp)
    800054bc:	64e2                	ld	s1,24(sp)
    800054be:	6a02                	ld	s4,0(sp)
    800054c0:	6145                	addi	sp,sp,48
    800054c2:	8082                	ret
  return -1;
    800054c4:	557d                	li	a0,-1
    800054c6:	bfcd                	j	800054b8 <pipealloc+0xd0>

00000000800054c8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800054c8:	1101                	addi	sp,sp,-32
    800054ca:	ec06                	sd	ra,24(sp)
    800054cc:	e822                	sd	s0,16(sp)
    800054ce:	e426                	sd	s1,8(sp)
    800054d0:	e04a                	sd	s2,0(sp)
    800054d2:	1000                	addi	s0,sp,32
    800054d4:	84aa                	mv	s1,a0
    800054d6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800054d8:	ffffc097          	auipc	ra,0xffffc
    800054dc:	832080e7          	jalr	-1998(ra) # 80000d0a <acquire>
  if(writable){
    800054e0:	02090d63          	beqz	s2,8000551a <pipeclose+0x52>
    pi->writeopen = 0;
    800054e4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800054e8:	21848513          	addi	a0,s1,536
    800054ec:	ffffd097          	auipc	ra,0xffffd
    800054f0:	3ee080e7          	jalr	1006(ra) # 800028da <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800054f4:	2204b783          	ld	a5,544(s1)
    800054f8:	eb95                	bnez	a5,8000552c <pipeclose+0x64>
    release(&pi->lock);
    800054fa:	8526                	mv	a0,s1
    800054fc:	ffffc097          	auipc	ra,0xffffc
    80005500:	8c2080e7          	jalr	-1854(ra) # 80000dbe <release>
    kfree((char*)pi);
    80005504:	8526                	mv	a0,s1
    80005506:	ffffb097          	auipc	ra,0xffffb
    8000550a:	556080e7          	jalr	1366(ra) # 80000a5c <kfree>
  } else
    release(&pi->lock);
}
    8000550e:	60e2                	ld	ra,24(sp)
    80005510:	6442                	ld	s0,16(sp)
    80005512:	64a2                	ld	s1,8(sp)
    80005514:	6902                	ld	s2,0(sp)
    80005516:	6105                	addi	sp,sp,32
    80005518:	8082                	ret
    pi->readopen = 0;
    8000551a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000551e:	21c48513          	addi	a0,s1,540
    80005522:	ffffd097          	auipc	ra,0xffffd
    80005526:	3b8080e7          	jalr	952(ra) # 800028da <wakeup>
    8000552a:	b7e9                	j	800054f4 <pipeclose+0x2c>
    release(&pi->lock);
    8000552c:	8526                	mv	a0,s1
    8000552e:	ffffc097          	auipc	ra,0xffffc
    80005532:	890080e7          	jalr	-1904(ra) # 80000dbe <release>
}
    80005536:	bfe1                	j	8000550e <pipeclose+0x46>

0000000080005538 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005538:	711d                	addi	sp,sp,-96
    8000553a:	ec86                	sd	ra,88(sp)
    8000553c:	e8a2                	sd	s0,80(sp)
    8000553e:	e4a6                	sd	s1,72(sp)
    80005540:	e0ca                	sd	s2,64(sp)
    80005542:	fc4e                	sd	s3,56(sp)
    80005544:	f852                	sd	s4,48(sp)
    80005546:	f456                	sd	s5,40(sp)
    80005548:	1080                	addi	s0,sp,96
    8000554a:	84aa                	mv	s1,a0
    8000554c:	8aae                	mv	s5,a1
    8000554e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005550:	ffffd097          	auipc	ra,0xffffd
    80005554:	b84080e7          	jalr	-1148(ra) # 800020d4 <myproc>
    80005558:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000555a:	8526                	mv	a0,s1
    8000555c:	ffffb097          	auipc	ra,0xffffb
    80005560:	7ae080e7          	jalr	1966(ra) # 80000d0a <acquire>
  while(i < n){
    80005564:	0d405863          	blez	s4,80005634 <pipewrite+0xfc>
    80005568:	f05a                	sd	s6,32(sp)
    8000556a:	ec5e                	sd	s7,24(sp)
    8000556c:	e862                	sd	s8,16(sp)
  int i = 0;
    8000556e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005570:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005572:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005576:	21c48b93          	addi	s7,s1,540
    8000557a:	a089                	j	800055bc <pipewrite+0x84>
      release(&pi->lock);
    8000557c:	8526                	mv	a0,s1
    8000557e:	ffffc097          	auipc	ra,0xffffc
    80005582:	840080e7          	jalr	-1984(ra) # 80000dbe <release>
      return -1;
    80005586:	597d                	li	s2,-1
    80005588:	7b02                	ld	s6,32(sp)
    8000558a:	6be2                	ld	s7,24(sp)
    8000558c:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000558e:	854a                	mv	a0,s2
    80005590:	60e6                	ld	ra,88(sp)
    80005592:	6446                	ld	s0,80(sp)
    80005594:	64a6                	ld	s1,72(sp)
    80005596:	6906                	ld	s2,64(sp)
    80005598:	79e2                	ld	s3,56(sp)
    8000559a:	7a42                	ld	s4,48(sp)
    8000559c:	7aa2                	ld	s5,40(sp)
    8000559e:	6125                	addi	sp,sp,96
    800055a0:	8082                	ret
      wakeup(&pi->nread);
    800055a2:	8562                	mv	a0,s8
    800055a4:	ffffd097          	auipc	ra,0xffffd
    800055a8:	336080e7          	jalr	822(ra) # 800028da <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800055ac:	85a6                	mv	a1,s1
    800055ae:	855e                	mv	a0,s7
    800055b0:	ffffd097          	auipc	ra,0xffffd
    800055b4:	2c6080e7          	jalr	710(ra) # 80002876 <sleep>
  while(i < n){
    800055b8:	05495f63          	bge	s2,s4,80005616 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    800055bc:	2204a783          	lw	a5,544(s1)
    800055c0:	dfd5                	beqz	a5,8000557c <pipewrite+0x44>
    800055c2:	854e                	mv	a0,s3
    800055c4:	ffffd097          	auipc	ra,0xffffd
    800055c8:	55a080e7          	jalr	1370(ra) # 80002b1e <killed>
    800055cc:	f945                	bnez	a0,8000557c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800055ce:	2184a783          	lw	a5,536(s1)
    800055d2:	21c4a703          	lw	a4,540(s1)
    800055d6:	2007879b          	addiw	a5,a5,512
    800055da:	fcf704e3          	beq	a4,a5,800055a2 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800055de:	4685                	li	a3,1
    800055e0:	01590633          	add	a2,s2,s5
    800055e4:	faf40593          	addi	a1,s0,-81
    800055e8:	0509b503          	ld	a0,80(s3)
    800055ec:	ffffc097          	auipc	ra,0xffffc
    800055f0:	642080e7          	jalr	1602(ra) # 80001c2e <copyin>
    800055f4:	05650263          	beq	a0,s6,80005638 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800055f8:	21c4a783          	lw	a5,540(s1)
    800055fc:	0017871b          	addiw	a4,a5,1
    80005600:	20e4ae23          	sw	a4,540(s1)
    80005604:	1ff7f793          	andi	a5,a5,511
    80005608:	97a6                	add	a5,a5,s1
    8000560a:	faf44703          	lbu	a4,-81(s0)
    8000560e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005612:	2905                	addiw	s2,s2,1
    80005614:	b755                	j	800055b8 <pipewrite+0x80>
    80005616:	7b02                	ld	s6,32(sp)
    80005618:	6be2                	ld	s7,24(sp)
    8000561a:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000561c:	21848513          	addi	a0,s1,536
    80005620:	ffffd097          	auipc	ra,0xffffd
    80005624:	2ba080e7          	jalr	698(ra) # 800028da <wakeup>
  release(&pi->lock);
    80005628:	8526                	mv	a0,s1
    8000562a:	ffffb097          	auipc	ra,0xffffb
    8000562e:	794080e7          	jalr	1940(ra) # 80000dbe <release>
  return i;
    80005632:	bfb1                	j	8000558e <pipewrite+0x56>
  int i = 0;
    80005634:	4901                	li	s2,0
    80005636:	b7dd                	j	8000561c <pipewrite+0xe4>
    80005638:	7b02                	ld	s6,32(sp)
    8000563a:	6be2                	ld	s7,24(sp)
    8000563c:	6c42                	ld	s8,16(sp)
    8000563e:	bff9                	j	8000561c <pipewrite+0xe4>

0000000080005640 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005640:	715d                	addi	sp,sp,-80
    80005642:	e486                	sd	ra,72(sp)
    80005644:	e0a2                	sd	s0,64(sp)
    80005646:	fc26                	sd	s1,56(sp)
    80005648:	f84a                	sd	s2,48(sp)
    8000564a:	f44e                	sd	s3,40(sp)
    8000564c:	f052                	sd	s4,32(sp)
    8000564e:	ec56                	sd	s5,24(sp)
    80005650:	0880                	addi	s0,sp,80
    80005652:	84aa                	mv	s1,a0
    80005654:	892e                	mv	s2,a1
    80005656:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005658:	ffffd097          	auipc	ra,0xffffd
    8000565c:	a7c080e7          	jalr	-1412(ra) # 800020d4 <myproc>
    80005660:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005662:	8526                	mv	a0,s1
    80005664:	ffffb097          	auipc	ra,0xffffb
    80005668:	6a6080e7          	jalr	1702(ra) # 80000d0a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000566c:	2184a703          	lw	a4,536(s1)
    80005670:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005674:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005678:	02f71963          	bne	a4,a5,800056aa <piperead+0x6a>
    8000567c:	2244a783          	lw	a5,548(s1)
    80005680:	cf95                	beqz	a5,800056bc <piperead+0x7c>
    if(killed(pr)){
    80005682:	8552                	mv	a0,s4
    80005684:	ffffd097          	auipc	ra,0xffffd
    80005688:	49a080e7          	jalr	1178(ra) # 80002b1e <killed>
    8000568c:	e10d                	bnez	a0,800056ae <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000568e:	85a6                	mv	a1,s1
    80005690:	854e                	mv	a0,s3
    80005692:	ffffd097          	auipc	ra,0xffffd
    80005696:	1e4080e7          	jalr	484(ra) # 80002876 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000569a:	2184a703          	lw	a4,536(s1)
    8000569e:	21c4a783          	lw	a5,540(s1)
    800056a2:	fcf70de3          	beq	a4,a5,8000567c <piperead+0x3c>
    800056a6:	e85a                	sd	s6,16(sp)
    800056a8:	a819                	j	800056be <piperead+0x7e>
    800056aa:	e85a                	sd	s6,16(sp)
    800056ac:	a809                	j	800056be <piperead+0x7e>
      release(&pi->lock);
    800056ae:	8526                	mv	a0,s1
    800056b0:	ffffb097          	auipc	ra,0xffffb
    800056b4:	70e080e7          	jalr	1806(ra) # 80000dbe <release>
      return -1;
    800056b8:	59fd                	li	s3,-1
    800056ba:	a0a5                	j	80005722 <piperead+0xe2>
    800056bc:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800056be:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800056c0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800056c2:	05505463          	blez	s5,8000570a <piperead+0xca>
    if(pi->nread == pi->nwrite)
    800056c6:	2184a783          	lw	a5,536(s1)
    800056ca:	21c4a703          	lw	a4,540(s1)
    800056ce:	02f70e63          	beq	a4,a5,8000570a <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800056d2:	0017871b          	addiw	a4,a5,1
    800056d6:	20e4ac23          	sw	a4,536(s1)
    800056da:	1ff7f793          	andi	a5,a5,511
    800056de:	97a6                	add	a5,a5,s1
    800056e0:	0187c783          	lbu	a5,24(a5)
    800056e4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800056e8:	4685                	li	a3,1
    800056ea:	fbf40613          	addi	a2,s0,-65
    800056ee:	85ca                	mv	a1,s2
    800056f0:	050a3503          	ld	a0,80(s4)
    800056f4:	ffffc097          	auipc	ra,0xffffc
    800056f8:	436080e7          	jalr	1078(ra) # 80001b2a <copyout>
    800056fc:	01650763          	beq	a0,s6,8000570a <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005700:	2985                	addiw	s3,s3,1
    80005702:	0905                	addi	s2,s2,1
    80005704:	fd3a91e3          	bne	s5,s3,800056c6 <piperead+0x86>
    80005708:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000570a:	21c48513          	addi	a0,s1,540
    8000570e:	ffffd097          	auipc	ra,0xffffd
    80005712:	1cc080e7          	jalr	460(ra) # 800028da <wakeup>
  release(&pi->lock);
    80005716:	8526                	mv	a0,s1
    80005718:	ffffb097          	auipc	ra,0xffffb
    8000571c:	6a6080e7          	jalr	1702(ra) # 80000dbe <release>
    80005720:	6b42                	ld	s6,16(sp)
  return i;
}
    80005722:	854e                	mv	a0,s3
    80005724:	60a6                	ld	ra,72(sp)
    80005726:	6406                	ld	s0,64(sp)
    80005728:	74e2                	ld	s1,56(sp)
    8000572a:	7942                	ld	s2,48(sp)
    8000572c:	79a2                	ld	s3,40(sp)
    8000572e:	7a02                	ld	s4,32(sp)
    80005730:	6ae2                	ld	s5,24(sp)
    80005732:	6161                	addi	sp,sp,80
    80005734:	8082                	ret

0000000080005736 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);


int flags2perm(int flags)
{
    80005736:	1141                	addi	sp,sp,-16
    80005738:	e422                	sd	s0,8(sp)
    8000573a:	0800                	addi	s0,sp,16
    8000573c:	87aa                	mv	a5,a0
    int perm = PTE_R;
    if(flags & 0x1)
    8000573e:	00157713          	andi	a4,a0,1
      perm |= PTE_X;
    80005742:	4529                	li	a0,10
    if(flags & 0x1)
    80005744:	e311                	bnez	a4,80005748 <flags2perm+0x12>
    int perm = PTE_R;
    80005746:	4509                	li	a0,2
    if(flags & 0x2)
    80005748:	8b89                	andi	a5,a5,2
    8000574a:	c399                	beqz	a5,80005750 <flags2perm+0x1a>
      perm |= PTE_W;
    8000574c:	00456513          	ori	a0,a0,4
    return perm;
}
    80005750:	6422                	ld	s0,8(sp)
    80005752:	0141                	addi	sp,sp,16
    80005754:	8082                	ret

0000000080005756 <exec>:

int
exec(char *path, char **argv)
{
    80005756:	df010113          	addi	sp,sp,-528
    8000575a:	20113423          	sd	ra,520(sp)
    8000575e:	20813023          	sd	s0,512(sp)
    80005762:	ffa6                	sd	s1,504(sp)
    80005764:	fbca                	sd	s2,496(sp)
    80005766:	0c00                	addi	s0,sp,528
    80005768:	892a                	mv	s2,a0
    8000576a:	dea43c23          	sd	a0,-520(s0)
    8000576e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005772:	ffffd097          	auipc	ra,0xffffd
    80005776:	962080e7          	jalr	-1694(ra) # 800020d4 <myproc>
    8000577a:	84aa                	mv	s1,a0

  begin_op();
    8000577c:	fffff097          	auipc	ra,0xfffff
    80005780:	434080e7          	jalr	1076(ra) # 80004bb0 <begin_op>

  if((ip = namei(path)) == 0){
    80005784:	854a                	mv	a0,s2
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	22a080e7          	jalr	554(ra) # 800049b0 <namei>
    8000578e:	c135                	beqz	a0,800057f2 <exec+0x9c>
    80005790:	f3d2                	sd	s4,480(sp)
    80005792:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005794:	fffff097          	auipc	ra,0xfffff
    80005798:	a4e080e7          	jalr	-1458(ra) # 800041e2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000579c:	04000713          	li	a4,64
    800057a0:	4681                	li	a3,0
    800057a2:	e5040613          	addi	a2,s0,-432
    800057a6:	4581                	li	a1,0
    800057a8:	8552                	mv	a0,s4
    800057aa:	fffff097          	auipc	ra,0xfffff
    800057ae:	cf0080e7          	jalr	-784(ra) # 8000449a <readi>
    800057b2:	04000793          	li	a5,64
    800057b6:	00f51a63          	bne	a0,a5,800057ca <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800057ba:	e5042703          	lw	a4,-432(s0)
    800057be:	464c47b7          	lui	a5,0x464c4
    800057c2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800057c6:	02f70c63          	beq	a4,a5,800057fe <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800057ca:	8552                	mv	a0,s4
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	c7c080e7          	jalr	-900(ra) # 80004448 <iunlockput>
    end_op();
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	456080e7          	jalr	1110(ra) # 80004c2a <end_op>
  }
  return -1;
    800057dc:	557d                	li	a0,-1
    800057de:	7a1e                	ld	s4,480(sp)
}
    800057e0:	20813083          	ld	ra,520(sp)
    800057e4:	20013403          	ld	s0,512(sp)
    800057e8:	74fe                	ld	s1,504(sp)
    800057ea:	795e                	ld	s2,496(sp)
    800057ec:	21010113          	addi	sp,sp,528
    800057f0:	8082                	ret
    end_op();
    800057f2:	fffff097          	auipc	ra,0xfffff
    800057f6:	438080e7          	jalr	1080(ra) # 80004c2a <end_op>
    return -1;
    800057fa:	557d                	li	a0,-1
    800057fc:	b7d5                	j	800057e0 <exec+0x8a>
    800057fe:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005800:	8526                	mv	a0,s1
    80005802:	ffffd097          	auipc	ra,0xffffd
    80005806:	996080e7          	jalr	-1642(ra) # 80002198 <proc_pagetable>
    8000580a:	8b2a                	mv	s6,a0
    8000580c:	30050f63          	beqz	a0,80005b2a <exec+0x3d4>
    80005810:	f7ce                	sd	s3,488(sp)
    80005812:	efd6                	sd	s5,472(sp)
    80005814:	e7de                	sd	s7,456(sp)
    80005816:	e3e2                	sd	s8,448(sp)
    80005818:	ff66                	sd	s9,440(sp)
    8000581a:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000581c:	e7042d03          	lw	s10,-400(s0)
    80005820:	e8845783          	lhu	a5,-376(s0)
    80005824:	14078d63          	beqz	a5,8000597e <exec+0x228>
    80005828:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000582a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000582c:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    8000582e:	6c85                	lui	s9,0x1
    80005830:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005834:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005838:	6a85                	lui	s5,0x1
    8000583a:	a0b5                	j	800058a6 <exec+0x150>
      panic("loadseg: address should exist");
    8000583c:	00003517          	auipc	a0,0x3
    80005840:	06c50513          	addi	a0,a0,108 # 800088a8 <__func__.1+0x8a0>
    80005844:	ffffb097          	auipc	ra,0xffffb
    80005848:	d1c080e7          	jalr	-740(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    8000584c:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000584e:	8726                	mv	a4,s1
    80005850:	012c06bb          	addw	a3,s8,s2
    80005854:	4581                	li	a1,0
    80005856:	8552                	mv	a0,s4
    80005858:	fffff097          	auipc	ra,0xfffff
    8000585c:	c42080e7          	jalr	-958(ra) # 8000449a <readi>
    80005860:	2501                	sext.w	a0,a0
    80005862:	28a49863          	bne	s1,a0,80005af2 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    80005866:	012a893b          	addw	s2,s5,s2
    8000586a:	03397563          	bgeu	s2,s3,80005894 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    8000586e:	02091593          	slli	a1,s2,0x20
    80005872:	9181                	srli	a1,a1,0x20
    80005874:	95de                	add	a1,a1,s7
    80005876:	855a                	mv	a0,s6
    80005878:	ffffc097          	auipc	ra,0xffffc
    8000587c:	918080e7          	jalr	-1768(ra) # 80001190 <walkaddr>
    80005880:	862a                	mv	a2,a0
    if(pa == 0)
    80005882:	dd4d                	beqz	a0,8000583c <exec+0xe6>
    if(sz - i < PGSIZE)
    80005884:	412984bb          	subw	s1,s3,s2
    80005888:	0004879b          	sext.w	a5,s1
    8000588c:	fcfcf0e3          	bgeu	s9,a5,8000584c <exec+0xf6>
    80005890:	84d6                	mv	s1,s5
    80005892:	bf6d                	j	8000584c <exec+0xf6>
    sz = sz1;
    80005894:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005898:	2d85                	addiw	s11,s11,1
    8000589a:	038d0d1b          	addiw	s10,s10,56
    8000589e:	e8845783          	lhu	a5,-376(s0)
    800058a2:	08fdd663          	bge	s11,a5,8000592e <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800058a6:	2d01                	sext.w	s10,s10
    800058a8:	03800713          	li	a4,56
    800058ac:	86ea                	mv	a3,s10
    800058ae:	e1840613          	addi	a2,s0,-488
    800058b2:	4581                	li	a1,0
    800058b4:	8552                	mv	a0,s4
    800058b6:	fffff097          	auipc	ra,0xfffff
    800058ba:	be4080e7          	jalr	-1052(ra) # 8000449a <readi>
    800058be:	03800793          	li	a5,56
    800058c2:	20f51063          	bne	a0,a5,80005ac2 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    800058c6:	e1842783          	lw	a5,-488(s0)
    800058ca:	4705                	li	a4,1
    800058cc:	fce796e3          	bne	a5,a4,80005898 <exec+0x142>
    if(ph.memsz < ph.filesz)
    800058d0:	e4043483          	ld	s1,-448(s0)
    800058d4:	e3843783          	ld	a5,-456(s0)
    800058d8:	1ef4e963          	bltu	s1,a5,80005aca <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800058dc:	e2843783          	ld	a5,-472(s0)
    800058e0:	94be                	add	s1,s1,a5
    800058e2:	1ef4e863          	bltu	s1,a5,80005ad2 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    800058e6:	df043703          	ld	a4,-528(s0)
    800058ea:	8ff9                	and	a5,a5,a4
    800058ec:	1e079763          	bnez	a5,80005ada <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800058f0:	e1c42503          	lw	a0,-484(s0)
    800058f4:	00000097          	auipc	ra,0x0
    800058f8:	e42080e7          	jalr	-446(ra) # 80005736 <flags2perm>
    800058fc:	86aa                	mv	a3,a0
    800058fe:	8626                	mv	a2,s1
    80005900:	85ca                	mv	a1,s2
    80005902:	855a                	mv	a0,s6
    80005904:	ffffc097          	auipc	ra,0xffffc
    80005908:	f0a080e7          	jalr	-246(ra) # 8000180e <uvmalloc>
    8000590c:	e0a43423          	sd	a0,-504(s0)
    80005910:	1c050963          	beqz	a0,80005ae2 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005914:	e2843b83          	ld	s7,-472(s0)
    80005918:	e2042c03          	lw	s8,-480(s0)
    8000591c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005920:	00098463          	beqz	s3,80005928 <exec+0x1d2>
    80005924:	4901                	li	s2,0
    80005926:	b7a1                	j	8000586e <exec+0x118>
    sz = sz1;
    80005928:	e0843903          	ld	s2,-504(s0)
    8000592c:	b7b5                	j	80005898 <exec+0x142>
    8000592e:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80005930:	8552                	mv	a0,s4
    80005932:	fffff097          	auipc	ra,0xfffff
    80005936:	b16080e7          	jalr	-1258(ra) # 80004448 <iunlockput>
  end_op();
    8000593a:	fffff097          	auipc	ra,0xfffff
    8000593e:	2f0080e7          	jalr	752(ra) # 80004c2a <end_op>
  p = myproc();
    80005942:	ffffc097          	auipc	ra,0xffffc
    80005946:	792080e7          	jalr	1938(ra) # 800020d4 <myproc>
    8000594a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000594c:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005950:	6985                	lui	s3,0x1
    80005952:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005954:	99ca                	add	s3,s3,s2
    80005956:	77fd                	lui	a5,0xfffff
    80005958:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_R | PTE_W)) == 0)
    8000595c:	4699                	li	a3,6
    8000595e:	6609                	lui	a2,0x2
    80005960:	964e                	add	a2,a2,s3
    80005962:	85ce                	mv	a1,s3
    80005964:	855a                	mv	a0,s6
    80005966:	ffffc097          	auipc	ra,0xffffc
    8000596a:	ea8080e7          	jalr	-344(ra) # 8000180e <uvmalloc>
    8000596e:	892a                	mv	s2,a0
    80005970:	e0a43423          	sd	a0,-504(s0)
    80005974:	e519                	bnez	a0,80005982 <exec+0x22c>
  if(pagetable)
    80005976:	e1343423          	sd	s3,-504(s0)
    8000597a:	4a01                	li	s4,0
    8000597c:	aaa5                	j	80005af4 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000597e:	4901                	li	s2,0
    80005980:	bf45                	j	80005930 <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005982:	75f9                	lui	a1,0xffffe
    80005984:	95aa                	add	a1,a1,a0
    80005986:	855a                	mv	a0,s6
    80005988:	ffffc097          	auipc	ra,0xffffc
    8000598c:	170080e7          	jalr	368(ra) # 80001af8 <uvmclear>
  stackbase = sp - PGSIZE;
    80005990:	7bfd                	lui	s7,0xfffff
    80005992:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005994:	e0043783          	ld	a5,-512(s0)
    80005998:	6388                	ld	a0,0(a5)
    8000599a:	c52d                	beqz	a0,80005a04 <exec+0x2ae>
    8000599c:	e9040993          	addi	s3,s0,-368
    800059a0:	f9040c13          	addi	s8,s0,-112
    800059a4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800059a6:	ffffb097          	auipc	ra,0xffffb
    800059aa:	5d4080e7          	jalr	1492(ra) # 80000f7a <strlen>
    800059ae:	0015079b          	addiw	a5,a0,1
    800059b2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800059b6:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800059ba:	13796863          	bltu	s2,s7,80005aea <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800059be:	e0043d03          	ld	s10,-512(s0)
    800059c2:	000d3a03          	ld	s4,0(s10)
    800059c6:	8552                	mv	a0,s4
    800059c8:	ffffb097          	auipc	ra,0xffffb
    800059cc:	5b2080e7          	jalr	1458(ra) # 80000f7a <strlen>
    800059d0:	0015069b          	addiw	a3,a0,1
    800059d4:	8652                	mv	a2,s4
    800059d6:	85ca                	mv	a1,s2
    800059d8:	855a                	mv	a0,s6
    800059da:	ffffc097          	auipc	ra,0xffffc
    800059de:	150080e7          	jalr	336(ra) # 80001b2a <copyout>
    800059e2:	10054663          	bltz	a0,80005aee <exec+0x398>
    ustack[argc] = sp;
    800059e6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800059ea:	0485                	addi	s1,s1,1
    800059ec:	008d0793          	addi	a5,s10,8
    800059f0:	e0f43023          	sd	a5,-512(s0)
    800059f4:	008d3503          	ld	a0,8(s10)
    800059f8:	c909                	beqz	a0,80005a0a <exec+0x2b4>
    if(argc >= MAXARG)
    800059fa:	09a1                	addi	s3,s3,8
    800059fc:	fb8995e3          	bne	s3,s8,800059a6 <exec+0x250>
  ip = 0;
    80005a00:	4a01                	li	s4,0
    80005a02:	a8cd                	j	80005af4 <exec+0x39e>
  sp = sz;
    80005a04:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005a08:	4481                	li	s1,0
  ustack[argc] = 0;
    80005a0a:	00349793          	slli	a5,s1,0x3
    80005a0e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ff5a1f0>
    80005a12:	97a2                	add	a5,a5,s0
    80005a14:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005a18:	00148693          	addi	a3,s1,1
    80005a1c:	068e                	slli	a3,a3,0x3
    80005a1e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005a22:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005a26:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005a2a:	f57966e3          	bltu	s2,s7,80005976 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005a2e:	e9040613          	addi	a2,s0,-368
    80005a32:	85ca                	mv	a1,s2
    80005a34:	855a                	mv	a0,s6
    80005a36:	ffffc097          	auipc	ra,0xffffc
    80005a3a:	0f4080e7          	jalr	244(ra) # 80001b2a <copyout>
    80005a3e:	0e054863          	bltz	a0,80005b2e <exec+0x3d8>
  p->trapframe->a1 = sp;
    80005a42:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005a46:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005a4a:	df843783          	ld	a5,-520(s0)
    80005a4e:	0007c703          	lbu	a4,0(a5)
    80005a52:	cf11                	beqz	a4,80005a6e <exec+0x318>
    80005a54:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005a56:	02f00693          	li	a3,47
    80005a5a:	a039                	j	80005a68 <exec+0x312>
      last = s+1;
    80005a5c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005a60:	0785                	addi	a5,a5,1
    80005a62:	fff7c703          	lbu	a4,-1(a5)
    80005a66:	c701                	beqz	a4,80005a6e <exec+0x318>
    if(*s == '/')
    80005a68:	fed71ce3          	bne	a4,a3,80005a60 <exec+0x30a>
    80005a6c:	bfc5                	j	80005a5c <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    80005a6e:	4641                	li	a2,16
    80005a70:	df843583          	ld	a1,-520(s0)
    80005a74:	158a8513          	addi	a0,s5,344
    80005a78:	ffffb097          	auipc	ra,0xffffb
    80005a7c:	4d0080e7          	jalr	1232(ra) # 80000f48 <safestrcpy>
  oldpagetable = p->pagetable;
    80005a80:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005a84:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005a88:	e0843783          	ld	a5,-504(s0)
    80005a8c:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005a90:	058ab783          	ld	a5,88(s5)
    80005a94:	e6843703          	ld	a4,-408(s0)
    80005a98:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005a9a:	058ab783          	ld	a5,88(s5)
    80005a9e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005aa2:	85e6                	mv	a1,s9
    80005aa4:	ffffc097          	auipc	ra,0xffffc
    80005aa8:	78e080e7          	jalr	1934(ra) # 80002232 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005aac:	0004851b          	sext.w	a0,s1
    80005ab0:	79be                	ld	s3,488(sp)
    80005ab2:	7a1e                	ld	s4,480(sp)
    80005ab4:	6afe                	ld	s5,472(sp)
    80005ab6:	6b5e                	ld	s6,464(sp)
    80005ab8:	6bbe                	ld	s7,456(sp)
    80005aba:	6c1e                	ld	s8,448(sp)
    80005abc:	7cfa                	ld	s9,440(sp)
    80005abe:	7d5a                	ld	s10,432(sp)
    80005ac0:	b305                	j	800057e0 <exec+0x8a>
    80005ac2:	e1243423          	sd	s2,-504(s0)
    80005ac6:	7dba                	ld	s11,424(sp)
    80005ac8:	a035                	j	80005af4 <exec+0x39e>
    80005aca:	e1243423          	sd	s2,-504(s0)
    80005ace:	7dba                	ld	s11,424(sp)
    80005ad0:	a015                	j	80005af4 <exec+0x39e>
    80005ad2:	e1243423          	sd	s2,-504(s0)
    80005ad6:	7dba                	ld	s11,424(sp)
    80005ad8:	a831                	j	80005af4 <exec+0x39e>
    80005ada:	e1243423          	sd	s2,-504(s0)
    80005ade:	7dba                	ld	s11,424(sp)
    80005ae0:	a811                	j	80005af4 <exec+0x39e>
    80005ae2:	e1243423          	sd	s2,-504(s0)
    80005ae6:	7dba                	ld	s11,424(sp)
    80005ae8:	a031                	j	80005af4 <exec+0x39e>
  ip = 0;
    80005aea:	4a01                	li	s4,0
    80005aec:	a021                	j	80005af4 <exec+0x39e>
    80005aee:	4a01                	li	s4,0
  if(pagetable)
    80005af0:	a011                	j	80005af4 <exec+0x39e>
    80005af2:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005af4:	e0843583          	ld	a1,-504(s0)
    80005af8:	855a                	mv	a0,s6
    80005afa:	ffffc097          	auipc	ra,0xffffc
    80005afe:	738080e7          	jalr	1848(ra) # 80002232 <proc_freepagetable>
  return -1;
    80005b02:	557d                	li	a0,-1
  if(ip){
    80005b04:	000a1b63          	bnez	s4,80005b1a <exec+0x3c4>
    80005b08:	79be                	ld	s3,488(sp)
    80005b0a:	7a1e                	ld	s4,480(sp)
    80005b0c:	6afe                	ld	s5,472(sp)
    80005b0e:	6b5e                	ld	s6,464(sp)
    80005b10:	6bbe                	ld	s7,456(sp)
    80005b12:	6c1e                	ld	s8,448(sp)
    80005b14:	7cfa                	ld	s9,440(sp)
    80005b16:	7d5a                	ld	s10,432(sp)
    80005b18:	b1e1                	j	800057e0 <exec+0x8a>
    80005b1a:	79be                	ld	s3,488(sp)
    80005b1c:	6afe                	ld	s5,472(sp)
    80005b1e:	6b5e                	ld	s6,464(sp)
    80005b20:	6bbe                	ld	s7,456(sp)
    80005b22:	6c1e                	ld	s8,448(sp)
    80005b24:	7cfa                	ld	s9,440(sp)
    80005b26:	7d5a                	ld	s10,432(sp)
    80005b28:	b14d                	j	800057ca <exec+0x74>
    80005b2a:	6b5e                	ld	s6,464(sp)
    80005b2c:	b979                	j	800057ca <exec+0x74>
  sz = sz1;
    80005b2e:	e0843983          	ld	s3,-504(s0)
    80005b32:	b591                	j	80005976 <exec+0x220>

0000000080005b34 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005b34:	7179                	addi	sp,sp,-48
    80005b36:	f406                	sd	ra,40(sp)
    80005b38:	f022                	sd	s0,32(sp)
    80005b3a:	ec26                	sd	s1,24(sp)
    80005b3c:	e84a                	sd	s2,16(sp)
    80005b3e:	1800                	addi	s0,sp,48
    80005b40:	892e                	mv	s2,a1
    80005b42:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005b44:	fdc40593          	addi	a1,s0,-36
    80005b48:	ffffe097          	auipc	ra,0xffffe
    80005b4c:	9e8080e7          	jalr	-1560(ra) # 80003530 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005b50:	fdc42703          	lw	a4,-36(s0)
    80005b54:	47bd                	li	a5,15
    80005b56:	02e7eb63          	bltu	a5,a4,80005b8c <argfd+0x58>
    80005b5a:	ffffc097          	auipc	ra,0xffffc
    80005b5e:	57a080e7          	jalr	1402(ra) # 800020d4 <myproc>
    80005b62:	fdc42703          	lw	a4,-36(s0)
    80005b66:	01a70793          	addi	a5,a4,26
    80005b6a:	078e                	slli	a5,a5,0x3
    80005b6c:	953e                	add	a0,a0,a5
    80005b6e:	611c                	ld	a5,0(a0)
    80005b70:	c385                	beqz	a5,80005b90 <argfd+0x5c>
    return -1;
  if(pfd)
    80005b72:	00090463          	beqz	s2,80005b7a <argfd+0x46>
    *pfd = fd;
    80005b76:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005b7a:	4501                	li	a0,0
  if(pf)
    80005b7c:	c091                	beqz	s1,80005b80 <argfd+0x4c>
    *pf = f;
    80005b7e:	e09c                	sd	a5,0(s1)
}
    80005b80:	70a2                	ld	ra,40(sp)
    80005b82:	7402                	ld	s0,32(sp)
    80005b84:	64e2                	ld	s1,24(sp)
    80005b86:	6942                	ld	s2,16(sp)
    80005b88:	6145                	addi	sp,sp,48
    80005b8a:	8082                	ret
    return -1;
    80005b8c:	557d                	li	a0,-1
    80005b8e:	bfcd                	j	80005b80 <argfd+0x4c>
    80005b90:	557d                	li	a0,-1
    80005b92:	b7fd                	j	80005b80 <argfd+0x4c>

0000000080005b94 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005b94:	1101                	addi	sp,sp,-32
    80005b96:	ec06                	sd	ra,24(sp)
    80005b98:	e822                	sd	s0,16(sp)
    80005b9a:	e426                	sd	s1,8(sp)
    80005b9c:	1000                	addi	s0,sp,32
    80005b9e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005ba0:	ffffc097          	auipc	ra,0xffffc
    80005ba4:	534080e7          	jalr	1332(ra) # 800020d4 <myproc>
    80005ba8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005baa:	0d050793          	addi	a5,a0,208
    80005bae:	4501                	li	a0,0
    80005bb0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005bb2:	6398                	ld	a4,0(a5)
    80005bb4:	cb19                	beqz	a4,80005bca <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005bb6:	2505                	addiw	a0,a0,1
    80005bb8:	07a1                	addi	a5,a5,8
    80005bba:	fed51ce3          	bne	a0,a3,80005bb2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005bbe:	557d                	li	a0,-1
}
    80005bc0:	60e2                	ld	ra,24(sp)
    80005bc2:	6442                	ld	s0,16(sp)
    80005bc4:	64a2                	ld	s1,8(sp)
    80005bc6:	6105                	addi	sp,sp,32
    80005bc8:	8082                	ret
      p->ofile[fd] = f;
    80005bca:	01a50793          	addi	a5,a0,26
    80005bce:	078e                	slli	a5,a5,0x3
    80005bd0:	963e                	add	a2,a2,a5
    80005bd2:	e204                	sd	s1,0(a2)
      return fd;
    80005bd4:	b7f5                	j	80005bc0 <fdalloc+0x2c>

0000000080005bd6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005bd6:	715d                	addi	sp,sp,-80
    80005bd8:	e486                	sd	ra,72(sp)
    80005bda:	e0a2                	sd	s0,64(sp)
    80005bdc:	fc26                	sd	s1,56(sp)
    80005bde:	f84a                	sd	s2,48(sp)
    80005be0:	f44e                	sd	s3,40(sp)
    80005be2:	ec56                	sd	s5,24(sp)
    80005be4:	e85a                	sd	s6,16(sp)
    80005be6:	0880                	addi	s0,sp,80
    80005be8:	8b2e                	mv	s6,a1
    80005bea:	89b2                	mv	s3,a2
    80005bec:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005bee:	fb040593          	addi	a1,s0,-80
    80005bf2:	fffff097          	auipc	ra,0xfffff
    80005bf6:	ddc080e7          	jalr	-548(ra) # 800049ce <nameiparent>
    80005bfa:	84aa                	mv	s1,a0
    80005bfc:	14050e63          	beqz	a0,80005d58 <create+0x182>
    return 0;

  ilock(dp);
    80005c00:	ffffe097          	auipc	ra,0xffffe
    80005c04:	5e2080e7          	jalr	1506(ra) # 800041e2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005c08:	4601                	li	a2,0
    80005c0a:	fb040593          	addi	a1,s0,-80
    80005c0e:	8526                	mv	a0,s1
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	ade080e7          	jalr	-1314(ra) # 800046ee <dirlookup>
    80005c18:	8aaa                	mv	s5,a0
    80005c1a:	c539                	beqz	a0,80005c68 <create+0x92>
    iunlockput(dp);
    80005c1c:	8526                	mv	a0,s1
    80005c1e:	fffff097          	auipc	ra,0xfffff
    80005c22:	82a080e7          	jalr	-2006(ra) # 80004448 <iunlockput>
    ilock(ip);
    80005c26:	8556                	mv	a0,s5
    80005c28:	ffffe097          	auipc	ra,0xffffe
    80005c2c:	5ba080e7          	jalr	1466(ra) # 800041e2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005c30:	4789                	li	a5,2
    80005c32:	02fb1463          	bne	s6,a5,80005c5a <create+0x84>
    80005c36:	044ad783          	lhu	a5,68(s5)
    80005c3a:	37f9                	addiw	a5,a5,-2
    80005c3c:	17c2                	slli	a5,a5,0x30
    80005c3e:	93c1                	srli	a5,a5,0x30
    80005c40:	4705                	li	a4,1
    80005c42:	00f76c63          	bltu	a4,a5,80005c5a <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005c46:	8556                	mv	a0,s5
    80005c48:	60a6                	ld	ra,72(sp)
    80005c4a:	6406                	ld	s0,64(sp)
    80005c4c:	74e2                	ld	s1,56(sp)
    80005c4e:	7942                	ld	s2,48(sp)
    80005c50:	79a2                	ld	s3,40(sp)
    80005c52:	6ae2                	ld	s5,24(sp)
    80005c54:	6b42                	ld	s6,16(sp)
    80005c56:	6161                	addi	sp,sp,80
    80005c58:	8082                	ret
    iunlockput(ip);
    80005c5a:	8556                	mv	a0,s5
    80005c5c:	ffffe097          	auipc	ra,0xffffe
    80005c60:	7ec080e7          	jalr	2028(ra) # 80004448 <iunlockput>
    return 0;
    80005c64:	4a81                	li	s5,0
    80005c66:	b7c5                	j	80005c46 <create+0x70>
    80005c68:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005c6a:	85da                	mv	a1,s6
    80005c6c:	4088                	lw	a0,0(s1)
    80005c6e:	ffffe097          	auipc	ra,0xffffe
    80005c72:	3d0080e7          	jalr	976(ra) # 8000403e <ialloc>
    80005c76:	8a2a                	mv	s4,a0
    80005c78:	c531                	beqz	a0,80005cc4 <create+0xee>
  ilock(ip);
    80005c7a:	ffffe097          	auipc	ra,0xffffe
    80005c7e:	568080e7          	jalr	1384(ra) # 800041e2 <ilock>
  ip->major = major;
    80005c82:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005c86:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005c8a:	4905                	li	s2,1
    80005c8c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005c90:	8552                	mv	a0,s4
    80005c92:	ffffe097          	auipc	ra,0xffffe
    80005c96:	484080e7          	jalr	1156(ra) # 80004116 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005c9a:	032b0d63          	beq	s6,s2,80005cd4 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005c9e:	004a2603          	lw	a2,4(s4)
    80005ca2:	fb040593          	addi	a1,s0,-80
    80005ca6:	8526                	mv	a0,s1
    80005ca8:	fffff097          	auipc	ra,0xfffff
    80005cac:	c56080e7          	jalr	-938(ra) # 800048fe <dirlink>
    80005cb0:	08054163          	bltz	a0,80005d32 <create+0x15c>
  iunlockput(dp);
    80005cb4:	8526                	mv	a0,s1
    80005cb6:	ffffe097          	auipc	ra,0xffffe
    80005cba:	792080e7          	jalr	1938(ra) # 80004448 <iunlockput>
  return ip;
    80005cbe:	8ad2                	mv	s5,s4
    80005cc0:	7a02                	ld	s4,32(sp)
    80005cc2:	b751                	j	80005c46 <create+0x70>
    iunlockput(dp);
    80005cc4:	8526                	mv	a0,s1
    80005cc6:	ffffe097          	auipc	ra,0xffffe
    80005cca:	782080e7          	jalr	1922(ra) # 80004448 <iunlockput>
    return 0;
    80005cce:	8ad2                	mv	s5,s4
    80005cd0:	7a02                	ld	s4,32(sp)
    80005cd2:	bf95                	j	80005c46 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005cd4:	004a2603          	lw	a2,4(s4)
    80005cd8:	00003597          	auipc	a1,0x3
    80005cdc:	bf058593          	addi	a1,a1,-1040 # 800088c8 <__func__.1+0x8c0>
    80005ce0:	8552                	mv	a0,s4
    80005ce2:	fffff097          	auipc	ra,0xfffff
    80005ce6:	c1c080e7          	jalr	-996(ra) # 800048fe <dirlink>
    80005cea:	04054463          	bltz	a0,80005d32 <create+0x15c>
    80005cee:	40d0                	lw	a2,4(s1)
    80005cf0:	00003597          	auipc	a1,0x3
    80005cf4:	be058593          	addi	a1,a1,-1056 # 800088d0 <__func__.1+0x8c8>
    80005cf8:	8552                	mv	a0,s4
    80005cfa:	fffff097          	auipc	ra,0xfffff
    80005cfe:	c04080e7          	jalr	-1020(ra) # 800048fe <dirlink>
    80005d02:	02054863          	bltz	a0,80005d32 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005d06:	004a2603          	lw	a2,4(s4)
    80005d0a:	fb040593          	addi	a1,s0,-80
    80005d0e:	8526                	mv	a0,s1
    80005d10:	fffff097          	auipc	ra,0xfffff
    80005d14:	bee080e7          	jalr	-1042(ra) # 800048fe <dirlink>
    80005d18:	00054d63          	bltz	a0,80005d32 <create+0x15c>
    dp->nlink++;  // for ".."
    80005d1c:	04a4d783          	lhu	a5,74(s1)
    80005d20:	2785                	addiw	a5,a5,1
    80005d22:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005d26:	8526                	mv	a0,s1
    80005d28:	ffffe097          	auipc	ra,0xffffe
    80005d2c:	3ee080e7          	jalr	1006(ra) # 80004116 <iupdate>
    80005d30:	b751                	j	80005cb4 <create+0xde>
  ip->nlink = 0;
    80005d32:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005d36:	8552                	mv	a0,s4
    80005d38:	ffffe097          	auipc	ra,0xffffe
    80005d3c:	3de080e7          	jalr	990(ra) # 80004116 <iupdate>
  iunlockput(ip);
    80005d40:	8552                	mv	a0,s4
    80005d42:	ffffe097          	auipc	ra,0xffffe
    80005d46:	706080e7          	jalr	1798(ra) # 80004448 <iunlockput>
  iunlockput(dp);
    80005d4a:	8526                	mv	a0,s1
    80005d4c:	ffffe097          	auipc	ra,0xffffe
    80005d50:	6fc080e7          	jalr	1788(ra) # 80004448 <iunlockput>
  return 0;
    80005d54:	7a02                	ld	s4,32(sp)
    80005d56:	bdc5                	j	80005c46 <create+0x70>
    return 0;
    80005d58:	8aaa                	mv	s5,a0
    80005d5a:	b5f5                	j	80005c46 <create+0x70>

0000000080005d5c <sys_dup>:
{
    80005d5c:	7179                	addi	sp,sp,-48
    80005d5e:	f406                	sd	ra,40(sp)
    80005d60:	f022                	sd	s0,32(sp)
    80005d62:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005d64:	fd840613          	addi	a2,s0,-40
    80005d68:	4581                	li	a1,0
    80005d6a:	4501                	li	a0,0
    80005d6c:	00000097          	auipc	ra,0x0
    80005d70:	dc8080e7          	jalr	-568(ra) # 80005b34 <argfd>
    return -1;
    80005d74:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005d76:	02054763          	bltz	a0,80005da4 <sys_dup+0x48>
    80005d7a:	ec26                	sd	s1,24(sp)
    80005d7c:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005d7e:	fd843903          	ld	s2,-40(s0)
    80005d82:	854a                	mv	a0,s2
    80005d84:	00000097          	auipc	ra,0x0
    80005d88:	e10080e7          	jalr	-496(ra) # 80005b94 <fdalloc>
    80005d8c:	84aa                	mv	s1,a0
    return -1;
    80005d8e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005d90:	00054f63          	bltz	a0,80005dae <sys_dup+0x52>
  filedup(f);
    80005d94:	854a                	mv	a0,s2
    80005d96:	fffff097          	auipc	ra,0xfffff
    80005d9a:	292080e7          	jalr	658(ra) # 80005028 <filedup>
  return fd;
    80005d9e:	87a6                	mv	a5,s1
    80005da0:	64e2                	ld	s1,24(sp)
    80005da2:	6942                	ld	s2,16(sp)
}
    80005da4:	853e                	mv	a0,a5
    80005da6:	70a2                	ld	ra,40(sp)
    80005da8:	7402                	ld	s0,32(sp)
    80005daa:	6145                	addi	sp,sp,48
    80005dac:	8082                	ret
    80005dae:	64e2                	ld	s1,24(sp)
    80005db0:	6942                	ld	s2,16(sp)
    80005db2:	bfcd                	j	80005da4 <sys_dup+0x48>

0000000080005db4 <sys_read>:
{
    80005db4:	7179                	addi	sp,sp,-48
    80005db6:	f406                	sd	ra,40(sp)
    80005db8:	f022                	sd	s0,32(sp)
    80005dba:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005dbc:	fd840593          	addi	a1,s0,-40
    80005dc0:	4505                	li	a0,1
    80005dc2:	ffffd097          	auipc	ra,0xffffd
    80005dc6:	78e080e7          	jalr	1934(ra) # 80003550 <argaddr>
  argint(2, &n);
    80005dca:	fe440593          	addi	a1,s0,-28
    80005dce:	4509                	li	a0,2
    80005dd0:	ffffd097          	auipc	ra,0xffffd
    80005dd4:	760080e7          	jalr	1888(ra) # 80003530 <argint>
  if(argfd(0, 0, &f) < 0)
    80005dd8:	fe840613          	addi	a2,s0,-24
    80005ddc:	4581                	li	a1,0
    80005dde:	4501                	li	a0,0
    80005de0:	00000097          	auipc	ra,0x0
    80005de4:	d54080e7          	jalr	-684(ra) # 80005b34 <argfd>
    80005de8:	87aa                	mv	a5,a0
    return -1;
    80005dea:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005dec:	0007cc63          	bltz	a5,80005e04 <sys_read+0x50>
  return fileread(f, p, n);
    80005df0:	fe442603          	lw	a2,-28(s0)
    80005df4:	fd843583          	ld	a1,-40(s0)
    80005df8:	fe843503          	ld	a0,-24(s0)
    80005dfc:	fffff097          	auipc	ra,0xfffff
    80005e00:	3d2080e7          	jalr	978(ra) # 800051ce <fileread>
}
    80005e04:	70a2                	ld	ra,40(sp)
    80005e06:	7402                	ld	s0,32(sp)
    80005e08:	6145                	addi	sp,sp,48
    80005e0a:	8082                	ret

0000000080005e0c <sys_write>:
{
    80005e0c:	7179                	addi	sp,sp,-48
    80005e0e:	f406                	sd	ra,40(sp)
    80005e10:	f022                	sd	s0,32(sp)
    80005e12:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005e14:	fd840593          	addi	a1,s0,-40
    80005e18:	4505                	li	a0,1
    80005e1a:	ffffd097          	auipc	ra,0xffffd
    80005e1e:	736080e7          	jalr	1846(ra) # 80003550 <argaddr>
  argint(2, &n);
    80005e22:	fe440593          	addi	a1,s0,-28
    80005e26:	4509                	li	a0,2
    80005e28:	ffffd097          	auipc	ra,0xffffd
    80005e2c:	708080e7          	jalr	1800(ra) # 80003530 <argint>
  if(argfd(0, 0, &f) < 0)
    80005e30:	fe840613          	addi	a2,s0,-24
    80005e34:	4581                	li	a1,0
    80005e36:	4501                	li	a0,0
    80005e38:	00000097          	auipc	ra,0x0
    80005e3c:	cfc080e7          	jalr	-772(ra) # 80005b34 <argfd>
    80005e40:	87aa                	mv	a5,a0
    return -1;
    80005e42:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005e44:	0007cc63          	bltz	a5,80005e5c <sys_write+0x50>
  return filewrite(f, p, n);
    80005e48:	fe442603          	lw	a2,-28(s0)
    80005e4c:	fd843583          	ld	a1,-40(s0)
    80005e50:	fe843503          	ld	a0,-24(s0)
    80005e54:	fffff097          	auipc	ra,0xfffff
    80005e58:	44c080e7          	jalr	1100(ra) # 800052a0 <filewrite>
}
    80005e5c:	70a2                	ld	ra,40(sp)
    80005e5e:	7402                	ld	s0,32(sp)
    80005e60:	6145                	addi	sp,sp,48
    80005e62:	8082                	ret

0000000080005e64 <sys_close>:
{
    80005e64:	1101                	addi	sp,sp,-32
    80005e66:	ec06                	sd	ra,24(sp)
    80005e68:	e822                	sd	s0,16(sp)
    80005e6a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005e6c:	fe040613          	addi	a2,s0,-32
    80005e70:	fec40593          	addi	a1,s0,-20
    80005e74:	4501                	li	a0,0
    80005e76:	00000097          	auipc	ra,0x0
    80005e7a:	cbe080e7          	jalr	-834(ra) # 80005b34 <argfd>
    return -1;
    80005e7e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005e80:	02054463          	bltz	a0,80005ea8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005e84:	ffffc097          	auipc	ra,0xffffc
    80005e88:	250080e7          	jalr	592(ra) # 800020d4 <myproc>
    80005e8c:	fec42783          	lw	a5,-20(s0)
    80005e90:	07e9                	addi	a5,a5,26
    80005e92:	078e                	slli	a5,a5,0x3
    80005e94:	953e                	add	a0,a0,a5
    80005e96:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005e9a:	fe043503          	ld	a0,-32(s0)
    80005e9e:	fffff097          	auipc	ra,0xfffff
    80005ea2:	1dc080e7          	jalr	476(ra) # 8000507a <fileclose>
  return 0;
    80005ea6:	4781                	li	a5,0
}
    80005ea8:	853e                	mv	a0,a5
    80005eaa:	60e2                	ld	ra,24(sp)
    80005eac:	6442                	ld	s0,16(sp)
    80005eae:	6105                	addi	sp,sp,32
    80005eb0:	8082                	ret

0000000080005eb2 <sys_fstat>:
{
    80005eb2:	1101                	addi	sp,sp,-32
    80005eb4:	ec06                	sd	ra,24(sp)
    80005eb6:	e822                	sd	s0,16(sp)
    80005eb8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005eba:	fe040593          	addi	a1,s0,-32
    80005ebe:	4505                	li	a0,1
    80005ec0:	ffffd097          	auipc	ra,0xffffd
    80005ec4:	690080e7          	jalr	1680(ra) # 80003550 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005ec8:	fe840613          	addi	a2,s0,-24
    80005ecc:	4581                	li	a1,0
    80005ece:	4501                	li	a0,0
    80005ed0:	00000097          	auipc	ra,0x0
    80005ed4:	c64080e7          	jalr	-924(ra) # 80005b34 <argfd>
    80005ed8:	87aa                	mv	a5,a0
    return -1;
    80005eda:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005edc:	0007ca63          	bltz	a5,80005ef0 <sys_fstat+0x3e>
  return filestat(f, st);
    80005ee0:	fe043583          	ld	a1,-32(s0)
    80005ee4:	fe843503          	ld	a0,-24(s0)
    80005ee8:	fffff097          	auipc	ra,0xfffff
    80005eec:	274080e7          	jalr	628(ra) # 8000515c <filestat>
}
    80005ef0:	60e2                	ld	ra,24(sp)
    80005ef2:	6442                	ld	s0,16(sp)
    80005ef4:	6105                	addi	sp,sp,32
    80005ef6:	8082                	ret

0000000080005ef8 <sys_link>:
{
    80005ef8:	7169                	addi	sp,sp,-304
    80005efa:	f606                	sd	ra,296(sp)
    80005efc:	f222                	sd	s0,288(sp)
    80005efe:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f00:	08000613          	li	a2,128
    80005f04:	ed040593          	addi	a1,s0,-304
    80005f08:	4501                	li	a0,0
    80005f0a:	ffffd097          	auipc	ra,0xffffd
    80005f0e:	666080e7          	jalr	1638(ra) # 80003570 <argstr>
    return -1;
    80005f12:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f14:	12054663          	bltz	a0,80006040 <sys_link+0x148>
    80005f18:	08000613          	li	a2,128
    80005f1c:	f5040593          	addi	a1,s0,-176
    80005f20:	4505                	li	a0,1
    80005f22:	ffffd097          	auipc	ra,0xffffd
    80005f26:	64e080e7          	jalr	1614(ra) # 80003570 <argstr>
    return -1;
    80005f2a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f2c:	10054a63          	bltz	a0,80006040 <sys_link+0x148>
    80005f30:	ee26                	sd	s1,280(sp)
  begin_op();
    80005f32:	fffff097          	auipc	ra,0xfffff
    80005f36:	c7e080e7          	jalr	-898(ra) # 80004bb0 <begin_op>
  if((ip = namei(old)) == 0){
    80005f3a:	ed040513          	addi	a0,s0,-304
    80005f3e:	fffff097          	auipc	ra,0xfffff
    80005f42:	a72080e7          	jalr	-1422(ra) # 800049b0 <namei>
    80005f46:	84aa                	mv	s1,a0
    80005f48:	c949                	beqz	a0,80005fda <sys_link+0xe2>
  ilock(ip);
    80005f4a:	ffffe097          	auipc	ra,0xffffe
    80005f4e:	298080e7          	jalr	664(ra) # 800041e2 <ilock>
  if(ip->type == T_DIR){
    80005f52:	04449703          	lh	a4,68(s1)
    80005f56:	4785                	li	a5,1
    80005f58:	08f70863          	beq	a4,a5,80005fe8 <sys_link+0xf0>
    80005f5c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005f5e:	04a4d783          	lhu	a5,74(s1)
    80005f62:	2785                	addiw	a5,a5,1
    80005f64:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005f68:	8526                	mv	a0,s1
    80005f6a:	ffffe097          	auipc	ra,0xffffe
    80005f6e:	1ac080e7          	jalr	428(ra) # 80004116 <iupdate>
  iunlock(ip);
    80005f72:	8526                	mv	a0,s1
    80005f74:	ffffe097          	auipc	ra,0xffffe
    80005f78:	334080e7          	jalr	820(ra) # 800042a8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005f7c:	fd040593          	addi	a1,s0,-48
    80005f80:	f5040513          	addi	a0,s0,-176
    80005f84:	fffff097          	auipc	ra,0xfffff
    80005f88:	a4a080e7          	jalr	-1462(ra) # 800049ce <nameiparent>
    80005f8c:	892a                	mv	s2,a0
    80005f8e:	cd35                	beqz	a0,8000600a <sys_link+0x112>
  ilock(dp);
    80005f90:	ffffe097          	auipc	ra,0xffffe
    80005f94:	252080e7          	jalr	594(ra) # 800041e2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005f98:	00092703          	lw	a4,0(s2)
    80005f9c:	409c                	lw	a5,0(s1)
    80005f9e:	06f71163          	bne	a4,a5,80006000 <sys_link+0x108>
    80005fa2:	40d0                	lw	a2,4(s1)
    80005fa4:	fd040593          	addi	a1,s0,-48
    80005fa8:	854a                	mv	a0,s2
    80005faa:	fffff097          	auipc	ra,0xfffff
    80005fae:	954080e7          	jalr	-1708(ra) # 800048fe <dirlink>
    80005fb2:	04054763          	bltz	a0,80006000 <sys_link+0x108>
  iunlockput(dp);
    80005fb6:	854a                	mv	a0,s2
    80005fb8:	ffffe097          	auipc	ra,0xffffe
    80005fbc:	490080e7          	jalr	1168(ra) # 80004448 <iunlockput>
  iput(ip);
    80005fc0:	8526                	mv	a0,s1
    80005fc2:	ffffe097          	auipc	ra,0xffffe
    80005fc6:	3de080e7          	jalr	990(ra) # 800043a0 <iput>
  end_op();
    80005fca:	fffff097          	auipc	ra,0xfffff
    80005fce:	c60080e7          	jalr	-928(ra) # 80004c2a <end_op>
  return 0;
    80005fd2:	4781                	li	a5,0
    80005fd4:	64f2                	ld	s1,280(sp)
    80005fd6:	6952                	ld	s2,272(sp)
    80005fd8:	a0a5                	j	80006040 <sys_link+0x148>
    end_op();
    80005fda:	fffff097          	auipc	ra,0xfffff
    80005fde:	c50080e7          	jalr	-944(ra) # 80004c2a <end_op>
    return -1;
    80005fe2:	57fd                	li	a5,-1
    80005fe4:	64f2                	ld	s1,280(sp)
    80005fe6:	a8a9                	j	80006040 <sys_link+0x148>
    iunlockput(ip);
    80005fe8:	8526                	mv	a0,s1
    80005fea:	ffffe097          	auipc	ra,0xffffe
    80005fee:	45e080e7          	jalr	1118(ra) # 80004448 <iunlockput>
    end_op();
    80005ff2:	fffff097          	auipc	ra,0xfffff
    80005ff6:	c38080e7          	jalr	-968(ra) # 80004c2a <end_op>
    return -1;
    80005ffa:	57fd                	li	a5,-1
    80005ffc:	64f2                	ld	s1,280(sp)
    80005ffe:	a089                	j	80006040 <sys_link+0x148>
    iunlockput(dp);
    80006000:	854a                	mv	a0,s2
    80006002:	ffffe097          	auipc	ra,0xffffe
    80006006:	446080e7          	jalr	1094(ra) # 80004448 <iunlockput>
  ilock(ip);
    8000600a:	8526                	mv	a0,s1
    8000600c:	ffffe097          	auipc	ra,0xffffe
    80006010:	1d6080e7          	jalr	470(ra) # 800041e2 <ilock>
  ip->nlink--;
    80006014:	04a4d783          	lhu	a5,74(s1)
    80006018:	37fd                	addiw	a5,a5,-1
    8000601a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000601e:	8526                	mv	a0,s1
    80006020:	ffffe097          	auipc	ra,0xffffe
    80006024:	0f6080e7          	jalr	246(ra) # 80004116 <iupdate>
  iunlockput(ip);
    80006028:	8526                	mv	a0,s1
    8000602a:	ffffe097          	auipc	ra,0xffffe
    8000602e:	41e080e7          	jalr	1054(ra) # 80004448 <iunlockput>
  end_op();
    80006032:	fffff097          	auipc	ra,0xfffff
    80006036:	bf8080e7          	jalr	-1032(ra) # 80004c2a <end_op>
  return -1;
    8000603a:	57fd                	li	a5,-1
    8000603c:	64f2                	ld	s1,280(sp)
    8000603e:	6952                	ld	s2,272(sp)
}
    80006040:	853e                	mv	a0,a5
    80006042:	70b2                	ld	ra,296(sp)
    80006044:	7412                	ld	s0,288(sp)
    80006046:	6155                	addi	sp,sp,304
    80006048:	8082                	ret

000000008000604a <sys_unlink>:
{
    8000604a:	7151                	addi	sp,sp,-240
    8000604c:	f586                	sd	ra,232(sp)
    8000604e:	f1a2                	sd	s0,224(sp)
    80006050:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80006052:	08000613          	li	a2,128
    80006056:	f3040593          	addi	a1,s0,-208
    8000605a:	4501                	li	a0,0
    8000605c:	ffffd097          	auipc	ra,0xffffd
    80006060:	514080e7          	jalr	1300(ra) # 80003570 <argstr>
    80006064:	1a054a63          	bltz	a0,80006218 <sys_unlink+0x1ce>
    80006068:	eda6                	sd	s1,216(sp)
  begin_op();
    8000606a:	fffff097          	auipc	ra,0xfffff
    8000606e:	b46080e7          	jalr	-1210(ra) # 80004bb0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006072:	fb040593          	addi	a1,s0,-80
    80006076:	f3040513          	addi	a0,s0,-208
    8000607a:	fffff097          	auipc	ra,0xfffff
    8000607e:	954080e7          	jalr	-1708(ra) # 800049ce <nameiparent>
    80006082:	84aa                	mv	s1,a0
    80006084:	cd71                	beqz	a0,80006160 <sys_unlink+0x116>
  ilock(dp);
    80006086:	ffffe097          	auipc	ra,0xffffe
    8000608a:	15c080e7          	jalr	348(ra) # 800041e2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000608e:	00003597          	auipc	a1,0x3
    80006092:	83a58593          	addi	a1,a1,-1990 # 800088c8 <__func__.1+0x8c0>
    80006096:	fb040513          	addi	a0,s0,-80
    8000609a:	ffffe097          	auipc	ra,0xffffe
    8000609e:	63a080e7          	jalr	1594(ra) # 800046d4 <namecmp>
    800060a2:	14050c63          	beqz	a0,800061fa <sys_unlink+0x1b0>
    800060a6:	00003597          	auipc	a1,0x3
    800060aa:	82a58593          	addi	a1,a1,-2006 # 800088d0 <__func__.1+0x8c8>
    800060ae:	fb040513          	addi	a0,s0,-80
    800060b2:	ffffe097          	auipc	ra,0xffffe
    800060b6:	622080e7          	jalr	1570(ra) # 800046d4 <namecmp>
    800060ba:	14050063          	beqz	a0,800061fa <sys_unlink+0x1b0>
    800060be:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800060c0:	f2c40613          	addi	a2,s0,-212
    800060c4:	fb040593          	addi	a1,s0,-80
    800060c8:	8526                	mv	a0,s1
    800060ca:	ffffe097          	auipc	ra,0xffffe
    800060ce:	624080e7          	jalr	1572(ra) # 800046ee <dirlookup>
    800060d2:	892a                	mv	s2,a0
    800060d4:	12050263          	beqz	a0,800061f8 <sys_unlink+0x1ae>
  ilock(ip);
    800060d8:	ffffe097          	auipc	ra,0xffffe
    800060dc:	10a080e7          	jalr	266(ra) # 800041e2 <ilock>
  if(ip->nlink < 1)
    800060e0:	04a91783          	lh	a5,74(s2)
    800060e4:	08f05563          	blez	a5,8000616e <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800060e8:	04491703          	lh	a4,68(s2)
    800060ec:	4785                	li	a5,1
    800060ee:	08f70963          	beq	a4,a5,80006180 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    800060f2:	4641                	li	a2,16
    800060f4:	4581                	li	a1,0
    800060f6:	fc040513          	addi	a0,s0,-64
    800060fa:	ffffb097          	auipc	ra,0xffffb
    800060fe:	d0c080e7          	jalr	-756(ra) # 80000e06 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006102:	4741                	li	a4,16
    80006104:	f2c42683          	lw	a3,-212(s0)
    80006108:	fc040613          	addi	a2,s0,-64
    8000610c:	4581                	li	a1,0
    8000610e:	8526                	mv	a0,s1
    80006110:	ffffe097          	auipc	ra,0xffffe
    80006114:	49a080e7          	jalr	1178(ra) # 800045aa <writei>
    80006118:	47c1                	li	a5,16
    8000611a:	0af51b63          	bne	a0,a5,800061d0 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    8000611e:	04491703          	lh	a4,68(s2)
    80006122:	4785                	li	a5,1
    80006124:	0af70f63          	beq	a4,a5,800061e2 <sys_unlink+0x198>
  iunlockput(dp);
    80006128:	8526                	mv	a0,s1
    8000612a:	ffffe097          	auipc	ra,0xffffe
    8000612e:	31e080e7          	jalr	798(ra) # 80004448 <iunlockput>
  ip->nlink--;
    80006132:	04a95783          	lhu	a5,74(s2)
    80006136:	37fd                	addiw	a5,a5,-1
    80006138:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000613c:	854a                	mv	a0,s2
    8000613e:	ffffe097          	auipc	ra,0xffffe
    80006142:	fd8080e7          	jalr	-40(ra) # 80004116 <iupdate>
  iunlockput(ip);
    80006146:	854a                	mv	a0,s2
    80006148:	ffffe097          	auipc	ra,0xffffe
    8000614c:	300080e7          	jalr	768(ra) # 80004448 <iunlockput>
  end_op();
    80006150:	fffff097          	auipc	ra,0xfffff
    80006154:	ada080e7          	jalr	-1318(ra) # 80004c2a <end_op>
  return 0;
    80006158:	4501                	li	a0,0
    8000615a:	64ee                	ld	s1,216(sp)
    8000615c:	694e                	ld	s2,208(sp)
    8000615e:	a84d                	j	80006210 <sys_unlink+0x1c6>
    end_op();
    80006160:	fffff097          	auipc	ra,0xfffff
    80006164:	aca080e7          	jalr	-1334(ra) # 80004c2a <end_op>
    return -1;
    80006168:	557d                	li	a0,-1
    8000616a:	64ee                	ld	s1,216(sp)
    8000616c:	a055                	j	80006210 <sys_unlink+0x1c6>
    8000616e:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80006170:	00002517          	auipc	a0,0x2
    80006174:	76850513          	addi	a0,a0,1896 # 800088d8 <__func__.1+0x8d0>
    80006178:	ffffa097          	auipc	ra,0xffffa
    8000617c:	3e8080e7          	jalr	1000(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006180:	04c92703          	lw	a4,76(s2)
    80006184:	02000793          	li	a5,32
    80006188:	f6e7f5e3          	bgeu	a5,a4,800060f2 <sys_unlink+0xa8>
    8000618c:	e5ce                	sd	s3,200(sp)
    8000618e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006192:	4741                	li	a4,16
    80006194:	86ce                	mv	a3,s3
    80006196:	f1840613          	addi	a2,s0,-232
    8000619a:	4581                	li	a1,0
    8000619c:	854a                	mv	a0,s2
    8000619e:	ffffe097          	auipc	ra,0xffffe
    800061a2:	2fc080e7          	jalr	764(ra) # 8000449a <readi>
    800061a6:	47c1                	li	a5,16
    800061a8:	00f51c63          	bne	a0,a5,800061c0 <sys_unlink+0x176>
    if(de.inum != 0)
    800061ac:	f1845783          	lhu	a5,-232(s0)
    800061b0:	e7b5                	bnez	a5,8000621c <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800061b2:	29c1                	addiw	s3,s3,16
    800061b4:	04c92783          	lw	a5,76(s2)
    800061b8:	fcf9ede3          	bltu	s3,a5,80006192 <sys_unlink+0x148>
    800061bc:	69ae                	ld	s3,200(sp)
    800061be:	bf15                	j	800060f2 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    800061c0:	00002517          	auipc	a0,0x2
    800061c4:	73050513          	addi	a0,a0,1840 # 800088f0 <__func__.1+0x8e8>
    800061c8:	ffffa097          	auipc	ra,0xffffa
    800061cc:	398080e7          	jalr	920(ra) # 80000560 <panic>
    800061d0:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800061d2:	00002517          	auipc	a0,0x2
    800061d6:	73650513          	addi	a0,a0,1846 # 80008908 <__func__.1+0x900>
    800061da:	ffffa097          	auipc	ra,0xffffa
    800061de:	386080e7          	jalr	902(ra) # 80000560 <panic>
    dp->nlink--;
    800061e2:	04a4d783          	lhu	a5,74(s1)
    800061e6:	37fd                	addiw	a5,a5,-1
    800061e8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800061ec:	8526                	mv	a0,s1
    800061ee:	ffffe097          	auipc	ra,0xffffe
    800061f2:	f28080e7          	jalr	-216(ra) # 80004116 <iupdate>
    800061f6:	bf0d                	j	80006128 <sys_unlink+0xde>
    800061f8:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800061fa:	8526                	mv	a0,s1
    800061fc:	ffffe097          	auipc	ra,0xffffe
    80006200:	24c080e7          	jalr	588(ra) # 80004448 <iunlockput>
  end_op();
    80006204:	fffff097          	auipc	ra,0xfffff
    80006208:	a26080e7          	jalr	-1498(ra) # 80004c2a <end_op>
  return -1;
    8000620c:	557d                	li	a0,-1
    8000620e:	64ee                	ld	s1,216(sp)
}
    80006210:	70ae                	ld	ra,232(sp)
    80006212:	740e                	ld	s0,224(sp)
    80006214:	616d                	addi	sp,sp,240
    80006216:	8082                	ret
    return -1;
    80006218:	557d                	li	a0,-1
    8000621a:	bfdd                	j	80006210 <sys_unlink+0x1c6>
    iunlockput(ip);
    8000621c:	854a                	mv	a0,s2
    8000621e:	ffffe097          	auipc	ra,0xffffe
    80006222:	22a080e7          	jalr	554(ra) # 80004448 <iunlockput>
    goto bad;
    80006226:	694e                	ld	s2,208(sp)
    80006228:	69ae                	ld	s3,200(sp)
    8000622a:	bfc1                	j	800061fa <sys_unlink+0x1b0>

000000008000622c <sys_open>:

uint64
sys_open(void)
{
    8000622c:	7131                	addi	sp,sp,-192
    8000622e:	fd06                	sd	ra,184(sp)
    80006230:	f922                	sd	s0,176(sp)
    80006232:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80006234:	f4c40593          	addi	a1,s0,-180
    80006238:	4505                	li	a0,1
    8000623a:	ffffd097          	auipc	ra,0xffffd
    8000623e:	2f6080e7          	jalr	758(ra) # 80003530 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006242:	08000613          	li	a2,128
    80006246:	f5040593          	addi	a1,s0,-176
    8000624a:	4501                	li	a0,0
    8000624c:	ffffd097          	auipc	ra,0xffffd
    80006250:	324080e7          	jalr	804(ra) # 80003570 <argstr>
    80006254:	87aa                	mv	a5,a0
    return -1;
    80006256:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006258:	0a07ce63          	bltz	a5,80006314 <sys_open+0xe8>
    8000625c:	f526                	sd	s1,168(sp)

  begin_op();
    8000625e:	fffff097          	auipc	ra,0xfffff
    80006262:	952080e7          	jalr	-1710(ra) # 80004bb0 <begin_op>

  if(omode & O_CREATE){
    80006266:	f4c42783          	lw	a5,-180(s0)
    8000626a:	2007f793          	andi	a5,a5,512
    8000626e:	cfd5                	beqz	a5,8000632a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006270:	4681                	li	a3,0
    80006272:	4601                	li	a2,0
    80006274:	4589                	li	a1,2
    80006276:	f5040513          	addi	a0,s0,-176
    8000627a:	00000097          	auipc	ra,0x0
    8000627e:	95c080e7          	jalr	-1700(ra) # 80005bd6 <create>
    80006282:	84aa                	mv	s1,a0
    if(ip == 0){
    80006284:	cd41                	beqz	a0,8000631c <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006286:	04449703          	lh	a4,68(s1)
    8000628a:	478d                	li	a5,3
    8000628c:	00f71763          	bne	a4,a5,8000629a <sys_open+0x6e>
    80006290:	0464d703          	lhu	a4,70(s1)
    80006294:	47a5                	li	a5,9
    80006296:	0ee7e163          	bltu	a5,a4,80006378 <sys_open+0x14c>
    8000629a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000629c:	fffff097          	auipc	ra,0xfffff
    800062a0:	d22080e7          	jalr	-734(ra) # 80004fbe <filealloc>
    800062a4:	892a                	mv	s2,a0
    800062a6:	c97d                	beqz	a0,8000639c <sys_open+0x170>
    800062a8:	ed4e                	sd	s3,152(sp)
    800062aa:	00000097          	auipc	ra,0x0
    800062ae:	8ea080e7          	jalr	-1814(ra) # 80005b94 <fdalloc>
    800062b2:	89aa                	mv	s3,a0
    800062b4:	0c054e63          	bltz	a0,80006390 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800062b8:	04449703          	lh	a4,68(s1)
    800062bc:	478d                	li	a5,3
    800062be:	0ef70c63          	beq	a4,a5,800063b6 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800062c2:	4789                	li	a5,2
    800062c4:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800062c8:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800062cc:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800062d0:	f4c42783          	lw	a5,-180(s0)
    800062d4:	0017c713          	xori	a4,a5,1
    800062d8:	8b05                	andi	a4,a4,1
    800062da:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800062de:	0037f713          	andi	a4,a5,3
    800062e2:	00e03733          	snez	a4,a4
    800062e6:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800062ea:	4007f793          	andi	a5,a5,1024
    800062ee:	c791                	beqz	a5,800062fa <sys_open+0xce>
    800062f0:	04449703          	lh	a4,68(s1)
    800062f4:	4789                	li	a5,2
    800062f6:	0cf70763          	beq	a4,a5,800063c4 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    800062fa:	8526                	mv	a0,s1
    800062fc:	ffffe097          	auipc	ra,0xffffe
    80006300:	fac080e7          	jalr	-84(ra) # 800042a8 <iunlock>
  end_op();
    80006304:	fffff097          	auipc	ra,0xfffff
    80006308:	926080e7          	jalr	-1754(ra) # 80004c2a <end_op>

  return fd;
    8000630c:	854e                	mv	a0,s3
    8000630e:	74aa                	ld	s1,168(sp)
    80006310:	790a                	ld	s2,160(sp)
    80006312:	69ea                	ld	s3,152(sp)
}
    80006314:	70ea                	ld	ra,184(sp)
    80006316:	744a                	ld	s0,176(sp)
    80006318:	6129                	addi	sp,sp,192
    8000631a:	8082                	ret
      end_op();
    8000631c:	fffff097          	auipc	ra,0xfffff
    80006320:	90e080e7          	jalr	-1778(ra) # 80004c2a <end_op>
      return -1;
    80006324:	557d                	li	a0,-1
    80006326:	74aa                	ld	s1,168(sp)
    80006328:	b7f5                	j	80006314 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    8000632a:	f5040513          	addi	a0,s0,-176
    8000632e:	ffffe097          	auipc	ra,0xffffe
    80006332:	682080e7          	jalr	1666(ra) # 800049b0 <namei>
    80006336:	84aa                	mv	s1,a0
    80006338:	c90d                	beqz	a0,8000636a <sys_open+0x13e>
    ilock(ip);
    8000633a:	ffffe097          	auipc	ra,0xffffe
    8000633e:	ea8080e7          	jalr	-344(ra) # 800041e2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006342:	04449703          	lh	a4,68(s1)
    80006346:	4785                	li	a5,1
    80006348:	f2f71fe3          	bne	a4,a5,80006286 <sys_open+0x5a>
    8000634c:	f4c42783          	lw	a5,-180(s0)
    80006350:	d7a9                	beqz	a5,8000629a <sys_open+0x6e>
      iunlockput(ip);
    80006352:	8526                	mv	a0,s1
    80006354:	ffffe097          	auipc	ra,0xffffe
    80006358:	0f4080e7          	jalr	244(ra) # 80004448 <iunlockput>
      end_op();
    8000635c:	fffff097          	auipc	ra,0xfffff
    80006360:	8ce080e7          	jalr	-1842(ra) # 80004c2a <end_op>
      return -1;
    80006364:	557d                	li	a0,-1
    80006366:	74aa                	ld	s1,168(sp)
    80006368:	b775                	j	80006314 <sys_open+0xe8>
      end_op();
    8000636a:	fffff097          	auipc	ra,0xfffff
    8000636e:	8c0080e7          	jalr	-1856(ra) # 80004c2a <end_op>
      return -1;
    80006372:	557d                	li	a0,-1
    80006374:	74aa                	ld	s1,168(sp)
    80006376:	bf79                	j	80006314 <sys_open+0xe8>
    iunlockput(ip);
    80006378:	8526                	mv	a0,s1
    8000637a:	ffffe097          	auipc	ra,0xffffe
    8000637e:	0ce080e7          	jalr	206(ra) # 80004448 <iunlockput>
    end_op();
    80006382:	fffff097          	auipc	ra,0xfffff
    80006386:	8a8080e7          	jalr	-1880(ra) # 80004c2a <end_op>
    return -1;
    8000638a:	557d                	li	a0,-1
    8000638c:	74aa                	ld	s1,168(sp)
    8000638e:	b759                	j	80006314 <sys_open+0xe8>
      fileclose(f);
    80006390:	854a                	mv	a0,s2
    80006392:	fffff097          	auipc	ra,0xfffff
    80006396:	ce8080e7          	jalr	-792(ra) # 8000507a <fileclose>
    8000639a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000639c:	8526                	mv	a0,s1
    8000639e:	ffffe097          	auipc	ra,0xffffe
    800063a2:	0aa080e7          	jalr	170(ra) # 80004448 <iunlockput>
    end_op();
    800063a6:	fffff097          	auipc	ra,0xfffff
    800063aa:	884080e7          	jalr	-1916(ra) # 80004c2a <end_op>
    return -1;
    800063ae:	557d                	li	a0,-1
    800063b0:	74aa                	ld	s1,168(sp)
    800063b2:	790a                	ld	s2,160(sp)
    800063b4:	b785                	j	80006314 <sys_open+0xe8>
    f->type = FD_DEVICE;
    800063b6:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800063ba:	04649783          	lh	a5,70(s1)
    800063be:	02f91223          	sh	a5,36(s2)
    800063c2:	b729                	j	800062cc <sys_open+0xa0>
    itrunc(ip);
    800063c4:	8526                	mv	a0,s1
    800063c6:	ffffe097          	auipc	ra,0xffffe
    800063ca:	f2e080e7          	jalr	-210(ra) # 800042f4 <itrunc>
    800063ce:	b735                	j	800062fa <sys_open+0xce>

00000000800063d0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800063d0:	7175                	addi	sp,sp,-144
    800063d2:	e506                	sd	ra,136(sp)
    800063d4:	e122                	sd	s0,128(sp)
    800063d6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800063d8:	ffffe097          	auipc	ra,0xffffe
    800063dc:	7d8080e7          	jalr	2008(ra) # 80004bb0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800063e0:	08000613          	li	a2,128
    800063e4:	f7040593          	addi	a1,s0,-144
    800063e8:	4501                	li	a0,0
    800063ea:	ffffd097          	auipc	ra,0xffffd
    800063ee:	186080e7          	jalr	390(ra) # 80003570 <argstr>
    800063f2:	02054963          	bltz	a0,80006424 <sys_mkdir+0x54>
    800063f6:	4681                	li	a3,0
    800063f8:	4601                	li	a2,0
    800063fa:	4585                	li	a1,1
    800063fc:	f7040513          	addi	a0,s0,-144
    80006400:	fffff097          	auipc	ra,0xfffff
    80006404:	7d6080e7          	jalr	2006(ra) # 80005bd6 <create>
    80006408:	cd11                	beqz	a0,80006424 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000640a:	ffffe097          	auipc	ra,0xffffe
    8000640e:	03e080e7          	jalr	62(ra) # 80004448 <iunlockput>
  end_op();
    80006412:	fffff097          	auipc	ra,0xfffff
    80006416:	818080e7          	jalr	-2024(ra) # 80004c2a <end_op>
  return 0;
    8000641a:	4501                	li	a0,0
}
    8000641c:	60aa                	ld	ra,136(sp)
    8000641e:	640a                	ld	s0,128(sp)
    80006420:	6149                	addi	sp,sp,144
    80006422:	8082                	ret
    end_op();
    80006424:	fffff097          	auipc	ra,0xfffff
    80006428:	806080e7          	jalr	-2042(ra) # 80004c2a <end_op>
    return -1;
    8000642c:	557d                	li	a0,-1
    8000642e:	b7fd                	j	8000641c <sys_mkdir+0x4c>

0000000080006430 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006430:	7135                	addi	sp,sp,-160
    80006432:	ed06                	sd	ra,152(sp)
    80006434:	e922                	sd	s0,144(sp)
    80006436:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006438:	ffffe097          	auipc	ra,0xffffe
    8000643c:	778080e7          	jalr	1912(ra) # 80004bb0 <begin_op>
  argint(1, &major);
    80006440:	f6c40593          	addi	a1,s0,-148
    80006444:	4505                	li	a0,1
    80006446:	ffffd097          	auipc	ra,0xffffd
    8000644a:	0ea080e7          	jalr	234(ra) # 80003530 <argint>
  argint(2, &minor);
    8000644e:	f6840593          	addi	a1,s0,-152
    80006452:	4509                	li	a0,2
    80006454:	ffffd097          	auipc	ra,0xffffd
    80006458:	0dc080e7          	jalr	220(ra) # 80003530 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000645c:	08000613          	li	a2,128
    80006460:	f7040593          	addi	a1,s0,-144
    80006464:	4501                	li	a0,0
    80006466:	ffffd097          	auipc	ra,0xffffd
    8000646a:	10a080e7          	jalr	266(ra) # 80003570 <argstr>
    8000646e:	02054b63          	bltz	a0,800064a4 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006472:	f6841683          	lh	a3,-152(s0)
    80006476:	f6c41603          	lh	a2,-148(s0)
    8000647a:	458d                	li	a1,3
    8000647c:	f7040513          	addi	a0,s0,-144
    80006480:	fffff097          	auipc	ra,0xfffff
    80006484:	756080e7          	jalr	1878(ra) # 80005bd6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006488:	cd11                	beqz	a0,800064a4 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000648a:	ffffe097          	auipc	ra,0xffffe
    8000648e:	fbe080e7          	jalr	-66(ra) # 80004448 <iunlockput>
  end_op();
    80006492:	ffffe097          	auipc	ra,0xffffe
    80006496:	798080e7          	jalr	1944(ra) # 80004c2a <end_op>
  return 0;
    8000649a:	4501                	li	a0,0
}
    8000649c:	60ea                	ld	ra,152(sp)
    8000649e:	644a                	ld	s0,144(sp)
    800064a0:	610d                	addi	sp,sp,160
    800064a2:	8082                	ret
    end_op();
    800064a4:	ffffe097          	auipc	ra,0xffffe
    800064a8:	786080e7          	jalr	1926(ra) # 80004c2a <end_op>
    return -1;
    800064ac:	557d                	li	a0,-1
    800064ae:	b7fd                	j	8000649c <sys_mknod+0x6c>

00000000800064b0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800064b0:	7135                	addi	sp,sp,-160
    800064b2:	ed06                	sd	ra,152(sp)
    800064b4:	e922                	sd	s0,144(sp)
    800064b6:	e14a                	sd	s2,128(sp)
    800064b8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800064ba:	ffffc097          	auipc	ra,0xffffc
    800064be:	c1a080e7          	jalr	-998(ra) # 800020d4 <myproc>
    800064c2:	892a                	mv	s2,a0
  
  begin_op();
    800064c4:	ffffe097          	auipc	ra,0xffffe
    800064c8:	6ec080e7          	jalr	1772(ra) # 80004bb0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800064cc:	08000613          	li	a2,128
    800064d0:	f6040593          	addi	a1,s0,-160
    800064d4:	4501                	li	a0,0
    800064d6:	ffffd097          	auipc	ra,0xffffd
    800064da:	09a080e7          	jalr	154(ra) # 80003570 <argstr>
    800064de:	04054d63          	bltz	a0,80006538 <sys_chdir+0x88>
    800064e2:	e526                	sd	s1,136(sp)
    800064e4:	f6040513          	addi	a0,s0,-160
    800064e8:	ffffe097          	auipc	ra,0xffffe
    800064ec:	4c8080e7          	jalr	1224(ra) # 800049b0 <namei>
    800064f0:	84aa                	mv	s1,a0
    800064f2:	c131                	beqz	a0,80006536 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800064f4:	ffffe097          	auipc	ra,0xffffe
    800064f8:	cee080e7          	jalr	-786(ra) # 800041e2 <ilock>
  if(ip->type != T_DIR){
    800064fc:	04449703          	lh	a4,68(s1)
    80006500:	4785                	li	a5,1
    80006502:	04f71163          	bne	a4,a5,80006544 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006506:	8526                	mv	a0,s1
    80006508:	ffffe097          	auipc	ra,0xffffe
    8000650c:	da0080e7          	jalr	-608(ra) # 800042a8 <iunlock>
  iput(p->cwd);
    80006510:	15093503          	ld	a0,336(s2)
    80006514:	ffffe097          	auipc	ra,0xffffe
    80006518:	e8c080e7          	jalr	-372(ra) # 800043a0 <iput>
  end_op();
    8000651c:	ffffe097          	auipc	ra,0xffffe
    80006520:	70e080e7          	jalr	1806(ra) # 80004c2a <end_op>
  p->cwd = ip;
    80006524:	14993823          	sd	s1,336(s2)
  return 0;
    80006528:	4501                	li	a0,0
    8000652a:	64aa                	ld	s1,136(sp)
}
    8000652c:	60ea                	ld	ra,152(sp)
    8000652e:	644a                	ld	s0,144(sp)
    80006530:	690a                	ld	s2,128(sp)
    80006532:	610d                	addi	sp,sp,160
    80006534:	8082                	ret
    80006536:	64aa                	ld	s1,136(sp)
    end_op();
    80006538:	ffffe097          	auipc	ra,0xffffe
    8000653c:	6f2080e7          	jalr	1778(ra) # 80004c2a <end_op>
    return -1;
    80006540:	557d                	li	a0,-1
    80006542:	b7ed                	j	8000652c <sys_chdir+0x7c>
    iunlockput(ip);
    80006544:	8526                	mv	a0,s1
    80006546:	ffffe097          	auipc	ra,0xffffe
    8000654a:	f02080e7          	jalr	-254(ra) # 80004448 <iunlockput>
    end_op();
    8000654e:	ffffe097          	auipc	ra,0xffffe
    80006552:	6dc080e7          	jalr	1756(ra) # 80004c2a <end_op>
    return -1;
    80006556:	557d                	li	a0,-1
    80006558:	64aa                	ld	s1,136(sp)
    8000655a:	bfc9                	j	8000652c <sys_chdir+0x7c>

000000008000655c <sys_exec>:

uint64
sys_exec(void)
{
    8000655c:	7121                	addi	sp,sp,-448
    8000655e:	ff06                	sd	ra,440(sp)
    80006560:	fb22                	sd	s0,432(sp)
    80006562:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006564:	e4840593          	addi	a1,s0,-440
    80006568:	4505                	li	a0,1
    8000656a:	ffffd097          	auipc	ra,0xffffd
    8000656e:	fe6080e7          	jalr	-26(ra) # 80003550 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006572:	08000613          	li	a2,128
    80006576:	f5040593          	addi	a1,s0,-176
    8000657a:	4501                	li	a0,0
    8000657c:	ffffd097          	auipc	ra,0xffffd
    80006580:	ff4080e7          	jalr	-12(ra) # 80003570 <argstr>
    80006584:	87aa                	mv	a5,a0
    return -1;
    80006586:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006588:	0e07c263          	bltz	a5,8000666c <sys_exec+0x110>
    8000658c:	f726                	sd	s1,424(sp)
    8000658e:	f34a                	sd	s2,416(sp)
    80006590:	ef4e                	sd	s3,408(sp)
    80006592:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80006594:	10000613          	li	a2,256
    80006598:	4581                	li	a1,0
    8000659a:	e5040513          	addi	a0,s0,-432
    8000659e:	ffffb097          	auipc	ra,0xffffb
    800065a2:	868080e7          	jalr	-1944(ra) # 80000e06 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800065a6:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800065aa:	89a6                	mv	s3,s1
    800065ac:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800065ae:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800065b2:	00391513          	slli	a0,s2,0x3
    800065b6:	e4040593          	addi	a1,s0,-448
    800065ba:	e4843783          	ld	a5,-440(s0)
    800065be:	953e                	add	a0,a0,a5
    800065c0:	ffffd097          	auipc	ra,0xffffd
    800065c4:	ed2080e7          	jalr	-302(ra) # 80003492 <fetchaddr>
    800065c8:	02054a63          	bltz	a0,800065fc <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    800065cc:	e4043783          	ld	a5,-448(s0)
    800065d0:	c7b9                	beqz	a5,8000661e <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800065d2:	ffffa097          	auipc	ra,0xffffa
    800065d6:	5f2080e7          	jalr	1522(ra) # 80000bc4 <kalloc>
    800065da:	85aa                	mv	a1,a0
    800065dc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800065e0:	cd11                	beqz	a0,800065fc <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800065e2:	6605                	lui	a2,0x1
    800065e4:	e4043503          	ld	a0,-448(s0)
    800065e8:	ffffd097          	auipc	ra,0xffffd
    800065ec:	efc080e7          	jalr	-260(ra) # 800034e4 <fetchstr>
    800065f0:	00054663          	bltz	a0,800065fc <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    800065f4:	0905                	addi	s2,s2,1
    800065f6:	09a1                	addi	s3,s3,8
    800065f8:	fb491de3          	bne	s2,s4,800065b2 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800065fc:	f5040913          	addi	s2,s0,-176
    80006600:	6088                	ld	a0,0(s1)
    80006602:	c125                	beqz	a0,80006662 <sys_exec+0x106>
    kfree(argv[i]);
    80006604:	ffffa097          	auipc	ra,0xffffa
    80006608:	458080e7          	jalr	1112(ra) # 80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000660c:	04a1                	addi	s1,s1,8
    8000660e:	ff2499e3          	bne	s1,s2,80006600 <sys_exec+0xa4>
  return -1;
    80006612:	557d                	li	a0,-1
    80006614:	74ba                	ld	s1,424(sp)
    80006616:	791a                	ld	s2,416(sp)
    80006618:	69fa                	ld	s3,408(sp)
    8000661a:	6a5a                	ld	s4,400(sp)
    8000661c:	a881                	j	8000666c <sys_exec+0x110>
      argv[i] = 0;
    8000661e:	0009079b          	sext.w	a5,s2
    80006622:	078e                	slli	a5,a5,0x3
    80006624:	fd078793          	addi	a5,a5,-48
    80006628:	97a2                	add	a5,a5,s0
    8000662a:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    8000662e:	e5040593          	addi	a1,s0,-432
    80006632:	f5040513          	addi	a0,s0,-176
    80006636:	fffff097          	auipc	ra,0xfffff
    8000663a:	120080e7          	jalr	288(ra) # 80005756 <exec>
    8000663e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006640:	f5040993          	addi	s3,s0,-176
    80006644:	6088                	ld	a0,0(s1)
    80006646:	c901                	beqz	a0,80006656 <sys_exec+0xfa>
    kfree(argv[i]);
    80006648:	ffffa097          	auipc	ra,0xffffa
    8000664c:	414080e7          	jalr	1044(ra) # 80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006650:	04a1                	addi	s1,s1,8
    80006652:	ff3499e3          	bne	s1,s3,80006644 <sys_exec+0xe8>
  return ret;
    80006656:	854a                	mv	a0,s2
    80006658:	74ba                	ld	s1,424(sp)
    8000665a:	791a                	ld	s2,416(sp)
    8000665c:	69fa                	ld	s3,408(sp)
    8000665e:	6a5a                	ld	s4,400(sp)
    80006660:	a031                	j	8000666c <sys_exec+0x110>
  return -1;
    80006662:	557d                	li	a0,-1
    80006664:	74ba                	ld	s1,424(sp)
    80006666:	791a                	ld	s2,416(sp)
    80006668:	69fa                	ld	s3,408(sp)
    8000666a:	6a5a                	ld	s4,400(sp)
}
    8000666c:	70fa                	ld	ra,440(sp)
    8000666e:	745a                	ld	s0,432(sp)
    80006670:	6139                	addi	sp,sp,448
    80006672:	8082                	ret

0000000080006674 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006674:	7139                	addi	sp,sp,-64
    80006676:	fc06                	sd	ra,56(sp)
    80006678:	f822                	sd	s0,48(sp)
    8000667a:	f426                	sd	s1,40(sp)
    8000667c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000667e:	ffffc097          	auipc	ra,0xffffc
    80006682:	a56080e7          	jalr	-1450(ra) # 800020d4 <myproc>
    80006686:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006688:	fd840593          	addi	a1,s0,-40
    8000668c:	4501                	li	a0,0
    8000668e:	ffffd097          	auipc	ra,0xffffd
    80006692:	ec2080e7          	jalr	-318(ra) # 80003550 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006696:	fc840593          	addi	a1,s0,-56
    8000669a:	fd040513          	addi	a0,s0,-48
    8000669e:	fffff097          	auipc	ra,0xfffff
    800066a2:	d4a080e7          	jalr	-694(ra) # 800053e8 <pipealloc>
    return -1;
    800066a6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800066a8:	0c054463          	bltz	a0,80006770 <sys_pipe+0xfc>
  fd0 = -1;
    800066ac:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800066b0:	fd043503          	ld	a0,-48(s0)
    800066b4:	fffff097          	auipc	ra,0xfffff
    800066b8:	4e0080e7          	jalr	1248(ra) # 80005b94 <fdalloc>
    800066bc:	fca42223          	sw	a0,-60(s0)
    800066c0:	08054b63          	bltz	a0,80006756 <sys_pipe+0xe2>
    800066c4:	fc843503          	ld	a0,-56(s0)
    800066c8:	fffff097          	auipc	ra,0xfffff
    800066cc:	4cc080e7          	jalr	1228(ra) # 80005b94 <fdalloc>
    800066d0:	fca42023          	sw	a0,-64(s0)
    800066d4:	06054863          	bltz	a0,80006744 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800066d8:	4691                	li	a3,4
    800066da:	fc440613          	addi	a2,s0,-60
    800066de:	fd843583          	ld	a1,-40(s0)
    800066e2:	68a8                	ld	a0,80(s1)
    800066e4:	ffffb097          	auipc	ra,0xffffb
    800066e8:	446080e7          	jalr	1094(ra) # 80001b2a <copyout>
    800066ec:	02054063          	bltz	a0,8000670c <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800066f0:	4691                	li	a3,4
    800066f2:	fc040613          	addi	a2,s0,-64
    800066f6:	fd843583          	ld	a1,-40(s0)
    800066fa:	0591                	addi	a1,a1,4
    800066fc:	68a8                	ld	a0,80(s1)
    800066fe:	ffffb097          	auipc	ra,0xffffb
    80006702:	42c080e7          	jalr	1068(ra) # 80001b2a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006706:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006708:	06055463          	bgez	a0,80006770 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000670c:	fc442783          	lw	a5,-60(s0)
    80006710:	07e9                	addi	a5,a5,26
    80006712:	078e                	slli	a5,a5,0x3
    80006714:	97a6                	add	a5,a5,s1
    80006716:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000671a:	fc042783          	lw	a5,-64(s0)
    8000671e:	07e9                	addi	a5,a5,26
    80006720:	078e                	slli	a5,a5,0x3
    80006722:	94be                	add	s1,s1,a5
    80006724:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006728:	fd043503          	ld	a0,-48(s0)
    8000672c:	fffff097          	auipc	ra,0xfffff
    80006730:	94e080e7          	jalr	-1714(ra) # 8000507a <fileclose>
    fileclose(wf);
    80006734:	fc843503          	ld	a0,-56(s0)
    80006738:	fffff097          	auipc	ra,0xfffff
    8000673c:	942080e7          	jalr	-1726(ra) # 8000507a <fileclose>
    return -1;
    80006740:	57fd                	li	a5,-1
    80006742:	a03d                	j	80006770 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006744:	fc442783          	lw	a5,-60(s0)
    80006748:	0007c763          	bltz	a5,80006756 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000674c:	07e9                	addi	a5,a5,26
    8000674e:	078e                	slli	a5,a5,0x3
    80006750:	97a6                	add	a5,a5,s1
    80006752:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006756:	fd043503          	ld	a0,-48(s0)
    8000675a:	fffff097          	auipc	ra,0xfffff
    8000675e:	920080e7          	jalr	-1760(ra) # 8000507a <fileclose>
    fileclose(wf);
    80006762:	fc843503          	ld	a0,-56(s0)
    80006766:	fffff097          	auipc	ra,0xfffff
    8000676a:	914080e7          	jalr	-1772(ra) # 8000507a <fileclose>
    return -1;
    8000676e:	57fd                	li	a5,-1
}
    80006770:	853e                	mv	a0,a5
    80006772:	70e2                	ld	ra,56(sp)
    80006774:	7442                	ld	s0,48(sp)
    80006776:	74a2                	ld	s1,40(sp)
    80006778:	6121                	addi	sp,sp,64
    8000677a:	8082                	ret
    8000677c:	0000                	unimp
	...

0000000080006780 <kernelvec>:
    80006780:	7111                	addi	sp,sp,-256
    80006782:	e006                	sd	ra,0(sp)
    80006784:	e40a                	sd	sp,8(sp)
    80006786:	e80e                	sd	gp,16(sp)
    80006788:	ec12                	sd	tp,24(sp)
    8000678a:	f016                	sd	t0,32(sp)
    8000678c:	f41a                	sd	t1,40(sp)
    8000678e:	f81e                	sd	t2,48(sp)
    80006790:	fc22                	sd	s0,56(sp)
    80006792:	e0a6                	sd	s1,64(sp)
    80006794:	e4aa                	sd	a0,72(sp)
    80006796:	e8ae                	sd	a1,80(sp)
    80006798:	ecb2                	sd	a2,88(sp)
    8000679a:	f0b6                	sd	a3,96(sp)
    8000679c:	f4ba                	sd	a4,104(sp)
    8000679e:	f8be                	sd	a5,112(sp)
    800067a0:	fcc2                	sd	a6,120(sp)
    800067a2:	e146                	sd	a7,128(sp)
    800067a4:	e54a                	sd	s2,136(sp)
    800067a6:	e94e                	sd	s3,144(sp)
    800067a8:	ed52                	sd	s4,152(sp)
    800067aa:	f156                	sd	s5,160(sp)
    800067ac:	f55a                	sd	s6,168(sp)
    800067ae:	f95e                	sd	s7,176(sp)
    800067b0:	fd62                	sd	s8,184(sp)
    800067b2:	e1e6                	sd	s9,192(sp)
    800067b4:	e5ea                	sd	s10,200(sp)
    800067b6:	e9ee                	sd	s11,208(sp)
    800067b8:	edf2                	sd	t3,216(sp)
    800067ba:	f1f6                	sd	t4,224(sp)
    800067bc:	f5fa                	sd	t5,232(sp)
    800067be:	f9fe                	sd	t6,240(sp)
    800067c0:	b9ffc0ef          	jal	8000335e <kerneltrap>
    800067c4:	6082                	ld	ra,0(sp)
    800067c6:	6122                	ld	sp,8(sp)
    800067c8:	61c2                	ld	gp,16(sp)
    800067ca:	7282                	ld	t0,32(sp)
    800067cc:	7322                	ld	t1,40(sp)
    800067ce:	73c2                	ld	t2,48(sp)
    800067d0:	7462                	ld	s0,56(sp)
    800067d2:	6486                	ld	s1,64(sp)
    800067d4:	6526                	ld	a0,72(sp)
    800067d6:	65c6                	ld	a1,80(sp)
    800067d8:	6666                	ld	a2,88(sp)
    800067da:	7686                	ld	a3,96(sp)
    800067dc:	7726                	ld	a4,104(sp)
    800067de:	77c6                	ld	a5,112(sp)
    800067e0:	7866                	ld	a6,120(sp)
    800067e2:	688a                	ld	a7,128(sp)
    800067e4:	692a                	ld	s2,136(sp)
    800067e6:	69ca                	ld	s3,144(sp)
    800067e8:	6a6a                	ld	s4,152(sp)
    800067ea:	7a8a                	ld	s5,160(sp)
    800067ec:	7b2a                	ld	s6,168(sp)
    800067ee:	7bca                	ld	s7,176(sp)
    800067f0:	7c6a                	ld	s8,184(sp)
    800067f2:	6c8e                	ld	s9,192(sp)
    800067f4:	6d2e                	ld	s10,200(sp)
    800067f6:	6dce                	ld	s11,208(sp)
    800067f8:	6e6e                	ld	t3,216(sp)
    800067fa:	7e8e                	ld	t4,224(sp)
    800067fc:	7f2e                	ld	t5,232(sp)
    800067fe:	7fce                	ld	t6,240(sp)
    80006800:	6111                	addi	sp,sp,256
    80006802:	10200073          	sret
    80006806:	00000013          	nop
    8000680a:	00000013          	nop
    8000680e:	0001                	nop

0000000080006810 <timervec>:
    80006810:	34051573          	csrrw	a0,mscratch,a0
    80006814:	e10c                	sd	a1,0(a0)
    80006816:	e510                	sd	a2,8(a0)
    80006818:	e914                	sd	a3,16(a0)
    8000681a:	6d0c                	ld	a1,24(a0)
    8000681c:	7110                	ld	a2,32(a0)
    8000681e:	6194                	ld	a3,0(a1)
    80006820:	96b2                	add	a3,a3,a2
    80006822:	e194                	sd	a3,0(a1)
    80006824:	4589                	li	a1,2
    80006826:	14459073          	csrw	sip,a1
    8000682a:	6914                	ld	a3,16(a0)
    8000682c:	6510                	ld	a2,8(a0)
    8000682e:	610c                	ld	a1,0(a0)
    80006830:	34051573          	csrrw	a0,mscratch,a0
    80006834:	30200073          	mret
	...

000000008000683a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000683a:	1141                	addi	sp,sp,-16
    8000683c:	e422                	sd	s0,8(sp)
    8000683e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006840:	0c0007b7          	lui	a5,0xc000
    80006844:	4705                	li	a4,1
    80006846:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006848:	0c0007b7          	lui	a5,0xc000
    8000684c:	c3d8                	sw	a4,4(a5)
}
    8000684e:	6422                	ld	s0,8(sp)
    80006850:	0141                	addi	sp,sp,16
    80006852:	8082                	ret

0000000080006854 <plicinithart>:

void
plicinithart(void)
{
    80006854:	1141                	addi	sp,sp,-16
    80006856:	e406                	sd	ra,8(sp)
    80006858:	e022                	sd	s0,0(sp)
    8000685a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000685c:	ffffc097          	auipc	ra,0xffffc
    80006860:	84c080e7          	jalr	-1972(ra) # 800020a8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006864:	0085171b          	slliw	a4,a0,0x8
    80006868:	0c0027b7          	lui	a5,0xc002
    8000686c:	97ba                	add	a5,a5,a4
    8000686e:	40200713          	li	a4,1026
    80006872:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006876:	00d5151b          	slliw	a0,a0,0xd
    8000687a:	0c2017b7          	lui	a5,0xc201
    8000687e:	97aa                	add	a5,a5,a0
    80006880:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006884:	60a2                	ld	ra,8(sp)
    80006886:	6402                	ld	s0,0(sp)
    80006888:	0141                	addi	sp,sp,16
    8000688a:	8082                	ret

000000008000688c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000688c:	1141                	addi	sp,sp,-16
    8000688e:	e406                	sd	ra,8(sp)
    80006890:	e022                	sd	s0,0(sp)
    80006892:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006894:	ffffc097          	auipc	ra,0xffffc
    80006898:	814080e7          	jalr	-2028(ra) # 800020a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000689c:	00d5151b          	slliw	a0,a0,0xd
    800068a0:	0c2017b7          	lui	a5,0xc201
    800068a4:	97aa                	add	a5,a5,a0
  return irq;
}
    800068a6:	43c8                	lw	a0,4(a5)
    800068a8:	60a2                	ld	ra,8(sp)
    800068aa:	6402                	ld	s0,0(sp)
    800068ac:	0141                	addi	sp,sp,16
    800068ae:	8082                	ret

00000000800068b0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800068b0:	1101                	addi	sp,sp,-32
    800068b2:	ec06                	sd	ra,24(sp)
    800068b4:	e822                	sd	s0,16(sp)
    800068b6:	e426                	sd	s1,8(sp)
    800068b8:	1000                	addi	s0,sp,32
    800068ba:	84aa                	mv	s1,a0
  int hart = cpuid();
    800068bc:	ffffb097          	auipc	ra,0xffffb
    800068c0:	7ec080e7          	jalr	2028(ra) # 800020a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800068c4:	00d5151b          	slliw	a0,a0,0xd
    800068c8:	0c2017b7          	lui	a5,0xc201
    800068cc:	97aa                	add	a5,a5,a0
    800068ce:	c3c4                	sw	s1,4(a5)
}
    800068d0:	60e2                	ld	ra,24(sp)
    800068d2:	6442                	ld	s0,16(sp)
    800068d4:	64a2                	ld	s1,8(sp)
    800068d6:	6105                	addi	sp,sp,32
    800068d8:	8082                	ret

00000000800068da <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800068da:	1141                	addi	sp,sp,-16
    800068dc:	e406                	sd	ra,8(sp)
    800068de:	e022                	sd	s0,0(sp)
    800068e0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800068e2:	479d                	li	a5,7
    800068e4:	04a7cc63          	blt	a5,a0,8000693c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800068e8:	0009e797          	auipc	a5,0x9e
    800068ec:	37878793          	addi	a5,a5,888 # 800a4c60 <disk>
    800068f0:	97aa                	add	a5,a5,a0
    800068f2:	0187c783          	lbu	a5,24(a5)
    800068f6:	ebb9                	bnez	a5,8000694c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800068f8:	00451693          	slli	a3,a0,0x4
    800068fc:	0009e797          	auipc	a5,0x9e
    80006900:	36478793          	addi	a5,a5,868 # 800a4c60 <disk>
    80006904:	6398                	ld	a4,0(a5)
    80006906:	9736                	add	a4,a4,a3
    80006908:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000690c:	6398                	ld	a4,0(a5)
    8000690e:	9736                	add	a4,a4,a3
    80006910:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006914:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006918:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000691c:	97aa                	add	a5,a5,a0
    8000691e:	4705                	li	a4,1
    80006920:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006924:	0009e517          	auipc	a0,0x9e
    80006928:	35450513          	addi	a0,a0,852 # 800a4c78 <disk+0x18>
    8000692c:	ffffc097          	auipc	ra,0xffffc
    80006930:	fae080e7          	jalr	-82(ra) # 800028da <wakeup>
}
    80006934:	60a2                	ld	ra,8(sp)
    80006936:	6402                	ld	s0,0(sp)
    80006938:	0141                	addi	sp,sp,16
    8000693a:	8082                	ret
    panic("free_desc 1");
    8000693c:	00002517          	auipc	a0,0x2
    80006940:	fdc50513          	addi	a0,a0,-36 # 80008918 <__func__.1+0x910>
    80006944:	ffffa097          	auipc	ra,0xffffa
    80006948:	c1c080e7          	jalr	-996(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000694c:	00002517          	auipc	a0,0x2
    80006950:	fdc50513          	addi	a0,a0,-36 # 80008928 <__func__.1+0x920>
    80006954:	ffffa097          	auipc	ra,0xffffa
    80006958:	c0c080e7          	jalr	-1012(ra) # 80000560 <panic>

000000008000695c <virtio_disk_init>:
{
    8000695c:	1101                	addi	sp,sp,-32
    8000695e:	ec06                	sd	ra,24(sp)
    80006960:	e822                	sd	s0,16(sp)
    80006962:	e426                	sd	s1,8(sp)
    80006964:	e04a                	sd	s2,0(sp)
    80006966:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006968:	00002597          	auipc	a1,0x2
    8000696c:	fd058593          	addi	a1,a1,-48 # 80008938 <__func__.1+0x930>
    80006970:	0009e517          	auipc	a0,0x9e
    80006974:	41850513          	addi	a0,a0,1048 # 800a4d88 <disk+0x128>
    80006978:	ffffa097          	auipc	ra,0xffffa
    8000697c:	302080e7          	jalr	770(ra) # 80000c7a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006980:	100017b7          	lui	a5,0x10001
    80006984:	4398                	lw	a4,0(a5)
    80006986:	2701                	sext.w	a4,a4
    80006988:	747277b7          	lui	a5,0x74727
    8000698c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006990:	18f71c63          	bne	a4,a5,80006b28 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006994:	100017b7          	lui	a5,0x10001
    80006998:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    8000699a:	439c                	lw	a5,0(a5)
    8000699c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000699e:	4709                	li	a4,2
    800069a0:	18e79463          	bne	a5,a4,80006b28 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800069a4:	100017b7          	lui	a5,0x10001
    800069a8:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800069aa:	439c                	lw	a5,0(a5)
    800069ac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800069ae:	16e79d63          	bne	a5,a4,80006b28 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800069b2:	100017b7          	lui	a5,0x10001
    800069b6:	47d8                	lw	a4,12(a5)
    800069b8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800069ba:	554d47b7          	lui	a5,0x554d4
    800069be:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800069c2:	16f71363          	bne	a4,a5,80006b28 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    800069c6:	100017b7          	lui	a5,0x10001
    800069ca:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800069ce:	4705                	li	a4,1
    800069d0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800069d2:	470d                	li	a4,3
    800069d4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800069d6:	10001737          	lui	a4,0x10001
    800069da:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800069dc:	c7ffe737          	lui	a4,0xc7ffe
    800069e0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47f599bf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800069e4:	8ef9                	and	a3,a3,a4
    800069e6:	10001737          	lui	a4,0x10001
    800069ea:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800069ec:	472d                	li	a4,11
    800069ee:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800069f0:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800069f4:	439c                	lw	a5,0(a5)
    800069f6:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800069fa:	8ba1                	andi	a5,a5,8
    800069fc:	12078e63          	beqz	a5,80006b38 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006a00:	100017b7          	lui	a5,0x10001
    80006a04:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006a08:	100017b7          	lui	a5,0x10001
    80006a0c:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006a10:	439c                	lw	a5,0(a5)
    80006a12:	2781                	sext.w	a5,a5
    80006a14:	12079a63          	bnez	a5,80006b48 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006a18:	100017b7          	lui	a5,0x10001
    80006a1c:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006a20:	439c                	lw	a5,0(a5)
    80006a22:	2781                	sext.w	a5,a5
  if(max == 0)
    80006a24:	12078a63          	beqz	a5,80006b58 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006a28:	471d                	li	a4,7
    80006a2a:	12f77f63          	bgeu	a4,a5,80006b68 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    80006a2e:	ffffa097          	auipc	ra,0xffffa
    80006a32:	196080e7          	jalr	406(ra) # 80000bc4 <kalloc>
    80006a36:	0009e497          	auipc	s1,0x9e
    80006a3a:	22a48493          	addi	s1,s1,554 # 800a4c60 <disk>
    80006a3e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006a40:	ffffa097          	auipc	ra,0xffffa
    80006a44:	184080e7          	jalr	388(ra) # 80000bc4 <kalloc>
    80006a48:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80006a4a:	ffffa097          	auipc	ra,0xffffa
    80006a4e:	17a080e7          	jalr	378(ra) # 80000bc4 <kalloc>
    80006a52:	87aa                	mv	a5,a0
    80006a54:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006a56:	6088                	ld	a0,0(s1)
    80006a58:	12050063          	beqz	a0,80006b78 <virtio_disk_init+0x21c>
    80006a5c:	0009e717          	auipc	a4,0x9e
    80006a60:	20c73703          	ld	a4,524(a4) # 800a4c68 <disk+0x8>
    80006a64:	10070a63          	beqz	a4,80006b78 <virtio_disk_init+0x21c>
    80006a68:	10078863          	beqz	a5,80006b78 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    80006a6c:	6605                	lui	a2,0x1
    80006a6e:	4581                	li	a1,0
    80006a70:	ffffa097          	auipc	ra,0xffffa
    80006a74:	396080e7          	jalr	918(ra) # 80000e06 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006a78:	0009e497          	auipc	s1,0x9e
    80006a7c:	1e848493          	addi	s1,s1,488 # 800a4c60 <disk>
    80006a80:	6605                	lui	a2,0x1
    80006a82:	4581                	li	a1,0
    80006a84:	6488                	ld	a0,8(s1)
    80006a86:	ffffa097          	auipc	ra,0xffffa
    80006a8a:	380080e7          	jalr	896(ra) # 80000e06 <memset>
  memset(disk.used, 0, PGSIZE);
    80006a8e:	6605                	lui	a2,0x1
    80006a90:	4581                	li	a1,0
    80006a92:	6888                	ld	a0,16(s1)
    80006a94:	ffffa097          	auipc	ra,0xffffa
    80006a98:	372080e7          	jalr	882(ra) # 80000e06 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006a9c:	100017b7          	lui	a5,0x10001
    80006aa0:	4721                	li	a4,8
    80006aa2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006aa4:	4098                	lw	a4,0(s1)
    80006aa6:	100017b7          	lui	a5,0x10001
    80006aaa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006aae:	40d8                	lw	a4,4(s1)
    80006ab0:	100017b7          	lui	a5,0x10001
    80006ab4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006ab8:	649c                	ld	a5,8(s1)
    80006aba:	0007869b          	sext.w	a3,a5
    80006abe:	10001737          	lui	a4,0x10001
    80006ac2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006ac6:	9781                	srai	a5,a5,0x20
    80006ac8:	10001737          	lui	a4,0x10001
    80006acc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006ad0:	689c                	ld	a5,16(s1)
    80006ad2:	0007869b          	sext.w	a3,a5
    80006ad6:	10001737          	lui	a4,0x10001
    80006ada:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006ade:	9781                	srai	a5,a5,0x20
    80006ae0:	10001737          	lui	a4,0x10001
    80006ae4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006ae8:	10001737          	lui	a4,0x10001
    80006aec:	4785                	li	a5,1
    80006aee:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006af0:	00f48c23          	sb	a5,24(s1)
    80006af4:	00f48ca3          	sb	a5,25(s1)
    80006af8:	00f48d23          	sb	a5,26(s1)
    80006afc:	00f48da3          	sb	a5,27(s1)
    80006b00:	00f48e23          	sb	a5,28(s1)
    80006b04:	00f48ea3          	sb	a5,29(s1)
    80006b08:	00f48f23          	sb	a5,30(s1)
    80006b0c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006b10:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006b14:	100017b7          	lui	a5,0x10001
    80006b18:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80006b1c:	60e2                	ld	ra,24(sp)
    80006b1e:	6442                	ld	s0,16(sp)
    80006b20:	64a2                	ld	s1,8(sp)
    80006b22:	6902                	ld	s2,0(sp)
    80006b24:	6105                	addi	sp,sp,32
    80006b26:	8082                	ret
    panic("could not find virtio disk");
    80006b28:	00002517          	auipc	a0,0x2
    80006b2c:	e2050513          	addi	a0,a0,-480 # 80008948 <__func__.1+0x940>
    80006b30:	ffffa097          	auipc	ra,0xffffa
    80006b34:	a30080e7          	jalr	-1488(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006b38:	00002517          	auipc	a0,0x2
    80006b3c:	e3050513          	addi	a0,a0,-464 # 80008968 <__func__.1+0x960>
    80006b40:	ffffa097          	auipc	ra,0xffffa
    80006b44:	a20080e7          	jalr	-1504(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006b48:	00002517          	auipc	a0,0x2
    80006b4c:	e4050513          	addi	a0,a0,-448 # 80008988 <__func__.1+0x980>
    80006b50:	ffffa097          	auipc	ra,0xffffa
    80006b54:	a10080e7          	jalr	-1520(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006b58:	00002517          	auipc	a0,0x2
    80006b5c:	e5050513          	addi	a0,a0,-432 # 800089a8 <__func__.1+0x9a0>
    80006b60:	ffffa097          	auipc	ra,0xffffa
    80006b64:	a00080e7          	jalr	-1536(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006b68:	00002517          	auipc	a0,0x2
    80006b6c:	e6050513          	addi	a0,a0,-416 # 800089c8 <__func__.1+0x9c0>
    80006b70:	ffffa097          	auipc	ra,0xffffa
    80006b74:	9f0080e7          	jalr	-1552(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006b78:	00002517          	auipc	a0,0x2
    80006b7c:	e7050513          	addi	a0,a0,-400 # 800089e8 <__func__.1+0x9e0>
    80006b80:	ffffa097          	auipc	ra,0xffffa
    80006b84:	9e0080e7          	jalr	-1568(ra) # 80000560 <panic>

0000000080006b88 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006b88:	7159                	addi	sp,sp,-112
    80006b8a:	f486                	sd	ra,104(sp)
    80006b8c:	f0a2                	sd	s0,96(sp)
    80006b8e:	eca6                	sd	s1,88(sp)
    80006b90:	e8ca                	sd	s2,80(sp)
    80006b92:	e4ce                	sd	s3,72(sp)
    80006b94:	e0d2                	sd	s4,64(sp)
    80006b96:	fc56                	sd	s5,56(sp)
    80006b98:	f85a                	sd	s6,48(sp)
    80006b9a:	f45e                	sd	s7,40(sp)
    80006b9c:	f062                	sd	s8,32(sp)
    80006b9e:	ec66                	sd	s9,24(sp)
    80006ba0:	1880                	addi	s0,sp,112
    80006ba2:	8a2a                	mv	s4,a0
    80006ba4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006ba6:	00c52c83          	lw	s9,12(a0)
    80006baa:	001c9c9b          	slliw	s9,s9,0x1
    80006bae:	1c82                	slli	s9,s9,0x20
    80006bb0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006bb4:	0009e517          	auipc	a0,0x9e
    80006bb8:	1d450513          	addi	a0,a0,468 # 800a4d88 <disk+0x128>
    80006bbc:	ffffa097          	auipc	ra,0xffffa
    80006bc0:	14e080e7          	jalr	334(ra) # 80000d0a <acquire>
  for(int i = 0; i < 3; i++){
    80006bc4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006bc6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006bc8:	0009eb17          	auipc	s6,0x9e
    80006bcc:	098b0b13          	addi	s6,s6,152 # 800a4c60 <disk>
  for(int i = 0; i < 3; i++){
    80006bd0:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006bd2:	0009ec17          	auipc	s8,0x9e
    80006bd6:	1b6c0c13          	addi	s8,s8,438 # 800a4d88 <disk+0x128>
    80006bda:	a0ad                	j	80006c44 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80006bdc:	00fb0733          	add	a4,s6,a5
    80006be0:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006be4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006be6:	0207c563          	bltz	a5,80006c10 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006bea:	2905                	addiw	s2,s2,1
    80006bec:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006bee:	05590f63          	beq	s2,s5,80006c4c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006bf2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006bf4:	0009e717          	auipc	a4,0x9e
    80006bf8:	06c70713          	addi	a4,a4,108 # 800a4c60 <disk>
    80006bfc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006bfe:	01874683          	lbu	a3,24(a4)
    80006c02:	fee9                	bnez	a3,80006bdc <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006c04:	2785                	addiw	a5,a5,1
    80006c06:	0705                	addi	a4,a4,1
    80006c08:	fe979be3          	bne	a5,s1,80006bfe <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006c0c:	57fd                	li	a5,-1
    80006c0e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006c10:	03205163          	blez	s2,80006c32 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006c14:	f9042503          	lw	a0,-112(s0)
    80006c18:	00000097          	auipc	ra,0x0
    80006c1c:	cc2080e7          	jalr	-830(ra) # 800068da <free_desc>
      for(int j = 0; j < i; j++)
    80006c20:	4785                	li	a5,1
    80006c22:	0127d863          	bge	a5,s2,80006c32 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006c26:	f9442503          	lw	a0,-108(s0)
    80006c2a:	00000097          	auipc	ra,0x0
    80006c2e:	cb0080e7          	jalr	-848(ra) # 800068da <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006c32:	85e2                	mv	a1,s8
    80006c34:	0009e517          	auipc	a0,0x9e
    80006c38:	04450513          	addi	a0,a0,68 # 800a4c78 <disk+0x18>
    80006c3c:	ffffc097          	auipc	ra,0xffffc
    80006c40:	c3a080e7          	jalr	-966(ra) # 80002876 <sleep>
  for(int i = 0; i < 3; i++){
    80006c44:	f9040613          	addi	a2,s0,-112
    80006c48:	894e                	mv	s2,s3
    80006c4a:	b765                	j	80006bf2 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006c4c:	f9042503          	lw	a0,-112(s0)
    80006c50:	00451693          	slli	a3,a0,0x4

  if(write)
    80006c54:	0009e797          	auipc	a5,0x9e
    80006c58:	00c78793          	addi	a5,a5,12 # 800a4c60 <disk>
    80006c5c:	00a50713          	addi	a4,a0,10
    80006c60:	0712                	slli	a4,a4,0x4
    80006c62:	973e                	add	a4,a4,a5
    80006c64:	01703633          	snez	a2,s7
    80006c68:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006c6a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006c6e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006c72:	6398                	ld	a4,0(a5)
    80006c74:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006c76:	0a868613          	addi	a2,a3,168
    80006c7a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006c7c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006c7e:	6390                	ld	a2,0(a5)
    80006c80:	00d605b3          	add	a1,a2,a3
    80006c84:	4741                	li	a4,16
    80006c86:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006c88:	4805                	li	a6,1
    80006c8a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006c8e:	f9442703          	lw	a4,-108(s0)
    80006c92:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006c96:	0712                	slli	a4,a4,0x4
    80006c98:	963a                	add	a2,a2,a4
    80006c9a:	058a0593          	addi	a1,s4,88
    80006c9e:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006ca0:	0007b883          	ld	a7,0(a5)
    80006ca4:	9746                	add	a4,a4,a7
    80006ca6:	40000613          	li	a2,1024
    80006caa:	c710                	sw	a2,8(a4)
  if(write)
    80006cac:	001bb613          	seqz	a2,s7
    80006cb0:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006cb4:	00166613          	ori	a2,a2,1
    80006cb8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006cbc:	f9842583          	lw	a1,-104(s0)
    80006cc0:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006cc4:	00250613          	addi	a2,a0,2
    80006cc8:	0612                	slli	a2,a2,0x4
    80006cca:	963e                	add	a2,a2,a5
    80006ccc:	577d                	li	a4,-1
    80006cce:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006cd2:	0592                	slli	a1,a1,0x4
    80006cd4:	98ae                	add	a7,a7,a1
    80006cd6:	03068713          	addi	a4,a3,48
    80006cda:	973e                	add	a4,a4,a5
    80006cdc:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006ce0:	6398                	ld	a4,0(a5)
    80006ce2:	972e                	add	a4,a4,a1
    80006ce4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006ce8:	4689                	li	a3,2
    80006cea:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006cee:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006cf2:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006cf6:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006cfa:	6794                	ld	a3,8(a5)
    80006cfc:	0026d703          	lhu	a4,2(a3)
    80006d00:	8b1d                	andi	a4,a4,7
    80006d02:	0706                	slli	a4,a4,0x1
    80006d04:	96ba                	add	a3,a3,a4
    80006d06:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006d0a:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006d0e:	6798                	ld	a4,8(a5)
    80006d10:	00275783          	lhu	a5,2(a4)
    80006d14:	2785                	addiw	a5,a5,1
    80006d16:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006d1a:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006d1e:	100017b7          	lui	a5,0x10001
    80006d22:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006d26:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006d2a:	0009e917          	auipc	s2,0x9e
    80006d2e:	05e90913          	addi	s2,s2,94 # 800a4d88 <disk+0x128>
  while(b->disk == 1) {
    80006d32:	4485                	li	s1,1
    80006d34:	01079c63          	bne	a5,a6,80006d4c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006d38:	85ca                	mv	a1,s2
    80006d3a:	8552                	mv	a0,s4
    80006d3c:	ffffc097          	auipc	ra,0xffffc
    80006d40:	b3a080e7          	jalr	-1222(ra) # 80002876 <sleep>
  while(b->disk == 1) {
    80006d44:	004a2783          	lw	a5,4(s4)
    80006d48:	fe9788e3          	beq	a5,s1,80006d38 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006d4c:	f9042903          	lw	s2,-112(s0)
    80006d50:	00290713          	addi	a4,s2,2
    80006d54:	0712                	slli	a4,a4,0x4
    80006d56:	0009e797          	auipc	a5,0x9e
    80006d5a:	f0a78793          	addi	a5,a5,-246 # 800a4c60 <disk>
    80006d5e:	97ba                	add	a5,a5,a4
    80006d60:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006d64:	0009e997          	auipc	s3,0x9e
    80006d68:	efc98993          	addi	s3,s3,-260 # 800a4c60 <disk>
    80006d6c:	00491713          	slli	a4,s2,0x4
    80006d70:	0009b783          	ld	a5,0(s3)
    80006d74:	97ba                	add	a5,a5,a4
    80006d76:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006d7a:	854a                	mv	a0,s2
    80006d7c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006d80:	00000097          	auipc	ra,0x0
    80006d84:	b5a080e7          	jalr	-1190(ra) # 800068da <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006d88:	8885                	andi	s1,s1,1
    80006d8a:	f0ed                	bnez	s1,80006d6c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006d8c:	0009e517          	auipc	a0,0x9e
    80006d90:	ffc50513          	addi	a0,a0,-4 # 800a4d88 <disk+0x128>
    80006d94:	ffffa097          	auipc	ra,0xffffa
    80006d98:	02a080e7          	jalr	42(ra) # 80000dbe <release>
}
    80006d9c:	70a6                	ld	ra,104(sp)
    80006d9e:	7406                	ld	s0,96(sp)
    80006da0:	64e6                	ld	s1,88(sp)
    80006da2:	6946                	ld	s2,80(sp)
    80006da4:	69a6                	ld	s3,72(sp)
    80006da6:	6a06                	ld	s4,64(sp)
    80006da8:	7ae2                	ld	s5,56(sp)
    80006daa:	7b42                	ld	s6,48(sp)
    80006dac:	7ba2                	ld	s7,40(sp)
    80006dae:	7c02                	ld	s8,32(sp)
    80006db0:	6ce2                	ld	s9,24(sp)
    80006db2:	6165                	addi	sp,sp,112
    80006db4:	8082                	ret

0000000080006db6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006db6:	1101                	addi	sp,sp,-32
    80006db8:	ec06                	sd	ra,24(sp)
    80006dba:	e822                	sd	s0,16(sp)
    80006dbc:	e426                	sd	s1,8(sp)
    80006dbe:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006dc0:	0009e497          	auipc	s1,0x9e
    80006dc4:	ea048493          	addi	s1,s1,-352 # 800a4c60 <disk>
    80006dc8:	0009e517          	auipc	a0,0x9e
    80006dcc:	fc050513          	addi	a0,a0,-64 # 800a4d88 <disk+0x128>
    80006dd0:	ffffa097          	auipc	ra,0xffffa
    80006dd4:	f3a080e7          	jalr	-198(ra) # 80000d0a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006dd8:	100017b7          	lui	a5,0x10001
    80006ddc:	53b8                	lw	a4,96(a5)
    80006dde:	8b0d                	andi	a4,a4,3
    80006de0:	100017b7          	lui	a5,0x10001
    80006de4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006de6:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006dea:	689c                	ld	a5,16(s1)
    80006dec:	0204d703          	lhu	a4,32(s1)
    80006df0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006df4:	04f70863          	beq	a4,a5,80006e44 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006df8:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006dfc:	6898                	ld	a4,16(s1)
    80006dfe:	0204d783          	lhu	a5,32(s1)
    80006e02:	8b9d                	andi	a5,a5,7
    80006e04:	078e                	slli	a5,a5,0x3
    80006e06:	97ba                	add	a5,a5,a4
    80006e08:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006e0a:	00278713          	addi	a4,a5,2
    80006e0e:	0712                	slli	a4,a4,0x4
    80006e10:	9726                	add	a4,a4,s1
    80006e12:	01074703          	lbu	a4,16(a4)
    80006e16:	e721                	bnez	a4,80006e5e <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006e18:	0789                	addi	a5,a5,2
    80006e1a:	0792                	slli	a5,a5,0x4
    80006e1c:	97a6                	add	a5,a5,s1
    80006e1e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006e20:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006e24:	ffffc097          	auipc	ra,0xffffc
    80006e28:	ab6080e7          	jalr	-1354(ra) # 800028da <wakeup>

    disk.used_idx += 1;
    80006e2c:	0204d783          	lhu	a5,32(s1)
    80006e30:	2785                	addiw	a5,a5,1
    80006e32:	17c2                	slli	a5,a5,0x30
    80006e34:	93c1                	srli	a5,a5,0x30
    80006e36:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006e3a:	6898                	ld	a4,16(s1)
    80006e3c:	00275703          	lhu	a4,2(a4)
    80006e40:	faf71ce3          	bne	a4,a5,80006df8 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006e44:	0009e517          	auipc	a0,0x9e
    80006e48:	f4450513          	addi	a0,a0,-188 # 800a4d88 <disk+0x128>
    80006e4c:	ffffa097          	auipc	ra,0xffffa
    80006e50:	f72080e7          	jalr	-142(ra) # 80000dbe <release>
}
    80006e54:	60e2                	ld	ra,24(sp)
    80006e56:	6442                	ld	s0,16(sp)
    80006e58:	64a2                	ld	s1,8(sp)
    80006e5a:	6105                	addi	sp,sp,32
    80006e5c:	8082                	ret
      panic("virtio_disk_intr status");
    80006e5e:	00002517          	auipc	a0,0x2
    80006e62:	ba250513          	addi	a0,a0,-1118 # 80008a00 <__func__.1+0x9f8>
    80006e66:	ffff9097          	auipc	ra,0xffff9
    80006e6a:	6fa080e7          	jalr	1786(ra) # 80000560 <panic>
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
