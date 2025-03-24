
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	7b013103          	ld	sp,1968(sp) # 8000b7b0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	7d070713          	addi	a4,a4,2000 # 8000b820 <timer_scratch>
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
    80000066:	60e78793          	addi	a5,a5,1550 # 80006670 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff59b6f>
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
    8000012e:	a96080e7          	jalr	-1386(ra) # 80002bc0 <either_copyin>
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
    80000190:	7d450513          	addi	a0,a0,2004 # 80013960 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	b76080e7          	jalr	-1162(ra) # 80000d0a <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	7c448493          	addi	s1,s1,1988 # 80013960 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a4:	00014917          	auipc	s2,0x14
    800001a8:	85490913          	addi	s2,s2,-1964 # 800139f8 <cons+0x98>
    while (n > 0)
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
        while (cons.r == cons.w)
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
            if (killed(myproc()))
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	e04080e7          	jalr	-508(ra) # 80001fc0 <myproc>
    800001c4:	00003097          	auipc	ra,0x3
    800001c8:	846080e7          	jalr	-1978(ra) # 80002a0a <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
            sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	590080e7          	jalr	1424(ra) # 80002762 <sleep>
        while (cons.r == cons.w)
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	77870713          	addi	a4,a4,1912 # 80013960 <cons>
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
    8000021e:	950080e7          	jalr	-1712(ra) # 80002b6a <either_copyout>
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
    8000023a:	72a50513          	addi	a0,a0,1834 # 80013960 <cons>
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
    80000264:	00013717          	auipc	a4,0x13
    80000268:	78f72a23          	sw	a5,1940(a4) # 800139f8 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
    release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	6e650513          	addi	a0,a0,1766 # 80013960 <cons>
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
    800002e6:	67e50513          	addi	a0,a0,1662 # 80013960 <cons>
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
    8000030c:	90e080e7          	jalr	-1778(ra) # 80002c16 <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	65050513          	addi	a0,a0,1616 # 80013960 <cons>
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
    80000336:	62e70713          	addi	a4,a4,1582 # 80013960 <cons>
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
    80000360:	60478793          	addi	a5,a5,1540 # 80013960 <cons>
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
    8000038e:	66e7a783          	lw	a5,1646(a5) # 800139f8 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
        while (cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	5c070713          	addi	a4,a4,1472 # 80013960 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	5b048493          	addi	s1,s1,1456 # 80013960 <cons>
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
    800003fa:	56a70713          	addi	a4,a4,1386 # 80013960 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
            cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	5ef72a23          	sw	a5,1524(a4) # 80013a00 <cons+0xa0>
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
    80000436:	52e78793          	addi	a5,a5,1326 # 80013960 <cons>
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
    8000045a:	5ac7a323          	sw	a2,1446(a5) # 800139fc <cons+0x9c>
                wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	59a50513          	addi	a0,a0,1434 # 800139f8 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	360080e7          	jalr	864(ra) # 800027c6 <wakeup>
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
    80000484:	4e050513          	addi	a0,a0,1248 # 80013960 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	7f2080e7          	jalr	2034(ra) # 80000c7a <initlock>

    uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	366080e7          	jalr	870(ra) # 800007f6 <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000498:	000a3797          	auipc	a5,0xa3
    8000049c:	66078793          	addi	a5,a5,1632 # 800a3af8 <devsw>
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
    800004da:	51260613          	addi	a2,a2,1298 # 800089e8 <digits>
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
    80000582:	4a07a123          	sw	zero,1186(a5) # 80013a20 <pr+0x18>
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
    800005b6:	20f72f23          	sw	a5,542(a4) # 8000b7d0 <panicked>
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
    800005e0:	444d2d03          	lw	s10,1092(s10) # 80013a20 <pr+0x18>
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
    8000061e:	3cea8a93          	addi	s5,s5,974 # 800089e8 <digits>
        switch (c)
    80000622:	07300c13          	li	s8,115
    80000626:	06400d93          	li	s11,100
    8000062a:	a0b1                	j	80000676 <printf+0xba>
        acquire(&pr.lock);
    8000062c:	00013517          	auipc	a0,0x13
    80000630:	3dc50513          	addi	a0,a0,988 # 80013a08 <pr>
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
    800007b6:	25650513          	addi	a0,a0,598 # 80013a08 <pr>
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
    800007d2:	23a48493          	addi	s1,s1,570 # 80013a08 <pr>
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
    8000083e:	1ee50513          	addi	a0,a0,494 # 80013a28 <uart_tx_lock>
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
    8000086a:	f6a7a783          	lw	a5,-150(a5) # 8000b7d0 <panicked>
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
    800008a4:	f387b783          	ld	a5,-200(a5) # 8000b7d8 <uart_tx_r>
    800008a8:	0000b717          	auipc	a4,0xb
    800008ac:	f3873703          	ld	a4,-200(a4) # 8000b7e0 <uart_tx_w>
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
    800008d2:	15aa8a93          	addi	s5,s5,346 # 80013a28 <uart_tx_lock>
    uart_tx_r += 1;
    800008d6:	0000b497          	auipc	s1,0xb
    800008da:	f0248493          	addi	s1,s1,-254 # 8000b7d8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008de:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e2:	0000b997          	auipc	s3,0xb
    800008e6:	efe98993          	addi	s3,s3,-258 # 8000b7e0 <uart_tx_w>
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
    80000908:	ec2080e7          	jalr	-318(ra) # 800027c6 <wakeup>
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
    80000946:	0e650513          	addi	a0,a0,230 # 80013a28 <uart_tx_lock>
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	3c0080e7          	jalr	960(ra) # 80000d0a <acquire>
  if(panicked){
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	e7e7a783          	lw	a5,-386(a5) # 8000b7d0 <panicked>
    8000095a:	e7c9                	bnez	a5,800009e4 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000095c:	0000b717          	auipc	a4,0xb
    80000960:	e8473703          	ld	a4,-380(a4) # 8000b7e0 <uart_tx_w>
    80000964:	0000b797          	auipc	a5,0xb
    80000968:	e747b783          	ld	a5,-396(a5) # 8000b7d8 <uart_tx_r>
    8000096c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000970:	00013997          	auipc	s3,0x13
    80000974:	0b898993          	addi	s3,s3,184 # 80013a28 <uart_tx_lock>
    80000978:	0000b497          	auipc	s1,0xb
    8000097c:	e6048493          	addi	s1,s1,-416 # 8000b7d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000980:	0000b917          	auipc	s2,0xb
    80000984:	e6090913          	addi	s2,s2,-416 # 8000b7e0 <uart_tx_w>
    80000988:	00e79f63          	bne	a5,a4,800009a6 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000098c:	85ce                	mv	a1,s3
    8000098e:	8526                	mv	a0,s1
    80000990:	00002097          	auipc	ra,0x2
    80000994:	dd2080e7          	jalr	-558(ra) # 80002762 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000998:	00093703          	ld	a4,0(s2)
    8000099c:	609c                	ld	a5,0(s1)
    8000099e:	02078793          	addi	a5,a5,32
    800009a2:	fee785e3          	beq	a5,a4,8000098c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a6:	00013497          	auipc	s1,0x13
    800009aa:	08248493          	addi	s1,s1,130 # 80013a28 <uart_tx_lock>
    800009ae:	01f77793          	andi	a5,a4,31
    800009b2:	97a6                	add	a5,a5,s1
    800009b4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009b8:	0705                	addi	a4,a4,1
    800009ba:	0000b797          	auipc	a5,0xb
    800009be:	e2e7b323          	sd	a4,-474(a5) # 8000b7e0 <uart_tx_w>
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
    80000a32:	ffa48493          	addi	s1,s1,-6 # 80013a28 <uart_tx_lock>
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
    80000a6e:	d867b783          	ld	a5,-634(a5) # 8000b7f0 <MAX_PAGES>
    80000a72:	c799                	beqz	a5,80000a80 <kfree+0x24>
        assert(FREE_PAGES < MAX_PAGES);
    80000a74:	0000b717          	auipc	a4,0xb
    80000a78:	d7473703          	ld	a4,-652(a4) # 8000b7e8 <FREE_PAGES>
    80000a7c:	06f77663          	bgeu	a4,a5,80000ae8 <kfree+0x8c>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a80:	03449793          	slli	a5,s1,0x34
    80000a84:	efc1                	bnez	a5,80000b1c <kfree+0xc0>
    80000a86:	000a4797          	auipc	a5,0xa4
    80000a8a:	20a78793          	addi	a5,a5,522 # 800a4c90 <end>
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
    80000aac:	fb890913          	addi	s2,s2,-72 # 80013a60 <kmem>
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
    80000ac8:	d2470713          	addi	a4,a4,-732 # 8000b7e8 <FREE_PAGES>
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
    80000b8c:	ed850513          	addi	a0,a0,-296 # 80013a60 <kmem>
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	0ea080e7          	jalr	234(ra) # 80000c7a <initlock>
    freerange(end, (void *)PHYSTOP);
    80000b98:	45c5                	li	a1,17
    80000b9a:	05ee                	slli	a1,a1,0x1b
    80000b9c:	000a4517          	auipc	a0,0xa4
    80000ba0:	0f450513          	addi	a0,a0,244 # 800a4c90 <end>
    80000ba4:	00000097          	auipc	ra,0x0
    80000ba8:	f88080e7          	jalr	-120(ra) # 80000b2c <freerange>
    MAX_PAGES = FREE_PAGES;
    80000bac:	0000b797          	auipc	a5,0xb
    80000bb0:	c3c7b783          	ld	a5,-964(a5) # 8000b7e8 <FREE_PAGES>
    80000bb4:	0000b717          	auipc	a4,0xb
    80000bb8:	c2f73e23          	sd	a5,-964(a4) # 8000b7f0 <MAX_PAGES>
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
    80000bd2:	c1a7b783          	ld	a5,-998(a5) # 8000b7e8 <FREE_PAGES>
    80000bd6:	cfb9                	beqz	a5,80000c34 <kalloc+0x70>
    struct run *r;

    acquire(&kmem.lock);
    80000bd8:	00013497          	auipc	s1,0x13
    80000bdc:	e8848493          	addi	s1,s1,-376 # 80013a60 <kmem>
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
    80000bf4:	e7050513          	addi	a0,a0,-400 # 80013a60 <kmem>
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
    80000c14:	bd870713          	addi	a4,a4,-1064 # 8000b7e8 <FREE_PAGES>
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
    80000c6c:	df850513          	addi	a0,a0,-520 # 80013a60 <kmem>
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
    80000ca8:	300080e7          	jalr	768(ra) # 80001fa4 <mycpu>
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
    80000cda:	2ce080e7          	jalr	718(ra) # 80001fa4 <mycpu>
    80000cde:	5d3c                	lw	a5,120(a0)
    80000ce0:	cf89                	beqz	a5,80000cfa <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ce2:	00001097          	auipc	ra,0x1
    80000ce6:	2c2080e7          	jalr	706(ra) # 80001fa4 <mycpu>
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
    80000cfe:	2aa080e7          	jalr	682(ra) # 80001fa4 <mycpu>
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
    80000d3e:	26a080e7          	jalr	618(ra) # 80001fa4 <mycpu>
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
    80000d6a:	23e080e7          	jalr	574(ra) # 80001fa4 <mycpu>
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
    80000fb0:	fe8080e7          	jalr	-24(ra) # 80001f94 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000fb4:	0000b717          	auipc	a4,0xb
    80000fb8:	84470713          	addi	a4,a4,-1980 # 8000b7f8 <started>
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
    80000fcc:	fcc080e7          	jalr	-52(ra) # 80001f94 <cpuid>
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
    80000fee:	e50080e7          	jalr	-432(ra) # 80002e3a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ff2:	00005097          	auipc	ra,0x5
    80000ff6:	6c2080e7          	jalr	1730(ra) # 800066b4 <plicinithart>
  }

  scheduler();        
    80000ffa:	00001097          	auipc	ra,0x1
    80000ffe:	646080e7          	jalr	1606(ra) # 80002640 <scheduler>
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
    init_phys_addr_refcount_table(); // Initialize reference counter table
    80001042:	00000097          	auipc	ra,0x0
    80001046:	190080e7          	jalr	400(ra) # 800011d2 <init_phys_addr_refcount_table>
    kinit();         // physical page allocator
    8000104a:	00000097          	auipc	ra,0x0
    8000104e:	b2e080e7          	jalr	-1234(ra) # 80000b78 <kinit>
    kvminit();       // create kernel page table
    80001052:	00000097          	auipc	ra,0x0
    80001056:	460080e7          	jalr	1120(ra) # 800014b2 <kvminit>
    kvminithart();   // turn on paging
    8000105a:	00000097          	auipc	ra,0x0
    8000105e:	068080e7          	jalr	104(ra) # 800010c2 <kvminithart>
    procinit();      // process table
    80001062:	00001097          	auipc	ra,0x1
    80001066:	d76080e7          	jalr	-650(ra) # 80001dd8 <procinit>
    trapinit();      // trap vectors
    8000106a:	00002097          	auipc	ra,0x2
    8000106e:	da8080e7          	jalr	-600(ra) # 80002e12 <trapinit>
    trapinithart();  // install kernel trap vector
    80001072:	00002097          	auipc	ra,0x2
    80001076:	dc8080e7          	jalr	-568(ra) # 80002e3a <trapinithart>
    plicinit();      // set up interrupt controller
    8000107a:	00005097          	auipc	ra,0x5
    8000107e:	620080e7          	jalr	1568(ra) # 8000669a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001082:	00005097          	auipc	ra,0x5
    80001086:	632080e7          	jalr	1586(ra) # 800066b4 <plicinithart>
    binit();         // buffer cache
    8000108a:	00002097          	auipc	ra,0x2
    8000108e:	620080e7          	jalr	1568(ra) # 800036aa <binit>
    iinit();         // inode table
    80001092:	00003097          	auipc	ra,0x3
    80001096:	cd6080e7          	jalr	-810(ra) # 80003d68 <iinit>
    fileinit();      // file table
    8000109a:	00004097          	auipc	ra,0x4
    8000109e:	c86080e7          	jalr	-890(ra) # 80004d20 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010a2:	00005097          	auipc	ra,0x5
    800010a6:	71a080e7          	jalr	1818(ra) # 800067bc <virtio_disk_init>
    userinit();      // first user process
    800010aa:	00001097          	auipc	ra,0x1
    800010ae:	1e8080e7          	jalr	488(ra) # 80002292 <userinit>
    __sync_synchronize();
    800010b2:	0330000f          	fence	rw,rw
    started = 1;
    800010b6:	4785                	li	a5,1
    800010b8:	0000a717          	auipc	a4,0xa
    800010bc:	74f72023          	sw	a5,1856(a4) # 8000b7f8 <started>
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
    800010cc:	0000a797          	auipc	a5,0xa
    800010d0:	7347b783          	ld	a5,1844(a5) # 8000b800 <kernel_pagetable>
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
    8000114a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ff5a367>
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

00000000800011d2 <init_phys_addr_refcount_table>:
    pa += PGSIZE;
  }
  return 0;
}

void init_phys_addr_refcount_table() {
    800011d2:	1141                	addi	sp,sp,-16
    800011d4:	e422                	sd	s0,8(sp)
    800011d6:	0800                	addi	s0,sp,16
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    800011d8:	00013797          	auipc	a5,0x13
    800011dc:	8a878793          	addi	a5,a5,-1880 # 80013a80 <phys_addr_refcount_table>
    800011e0:	00093717          	auipc	a4,0x93
    800011e4:	8a070713          	addi	a4,a4,-1888 # 80093a80 <cpus>
    phys_addr_refcount_table[i].pa = 0;
    800011e8:	0007b023          	sd	zero,0(a5)
    phys_addr_refcount_table[i].ref_count = 0;
    800011ec:	0007a423          	sw	zero,8(a5)
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    800011f0:	07c1                	addi	a5,a5,16
    800011f2:	fee79be3          	bne	a5,a4,800011e8 <init_phys_addr_refcount_table+0x16>
  }
}
    800011f6:	6422                	ld	s0,8(sp)
    800011f8:	0141                	addi	sp,sp,16
    800011fa:	8082                	ret

00000000800011fc <increment_ref_count>:
  pa = PGROUNDDOWN(pa);

  int mmio = 0;
\
  // Special case: Allow MMIO regions
  if (pa == UART0 || pa == VIRTIO0 || (pa >= PLIC && pa < PLIC + 0x400000)) {
    800011fc:	77f9                	lui	a5,0xffffe
    800011fe:	8fe9                	and	a5,a5,a0
    80001200:	10000737          	lui	a4,0x10000
    80001204:	0ee78863          	beq	a5,a4,800012f4 <increment_ref_count+0xf8>
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
    80001222:	0ae7ea63          	bltu	a5,a4,800012d6 <increment_ref_count+0xda>
    return;  // Allow mapping without reference counting
  }
  
  // Check if address is within valid physical memory range
  if ((pa < KERNBASE || pa >= PHYSTOP) &&  !mmio) {
    80001226:	800006b7          	lui	a3,0x80000
    8000122a:	96a6                	add	a3,a3,s1
    8000122c:	080005b7          	lui	a1,0x8000
    80001230:	00013717          	auipc	a4,0x13
    80001234:	85070713          	addi	a4,a4,-1968 # 80013a80 <phys_addr_refcount_table>
    printf("Error: PA %p outside valid range [%p, %p]\n", 
           pa, KERNBASE, PHYSTOP);
    panic("increment_ref_count: invalid physical address");
  }

  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    80001238:	4781                	li	a5,0
    8000123a:	6621                	lui	a2,0x8
  if ((pa < KERNBASE || pa >= PHYSTOP) &&  !mmio) {
    8000123c:	04b6ff63          	bgeu	a3,a1,8000129a <increment_ref_count+0x9e>
    if (phys_addr_refcount_table[i].pa == pa) {
    80001240:	6314                	ld	a3,0(a4)
    80001242:	08968163          	beq	a3,s1,800012c4 <increment_ref_count+0xc8>
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    80001246:	2785                	addiw	a5,a5,1 # fffffffff4000001 <end+0xffffffff73f5b371>
    80001248:	0741                	addi	a4,a4,16
    8000124a:	fec79be3          	bne	a5,a2,80001240 <increment_ref_count+0x44>
    8000124e:	00013717          	auipc	a4,0x13
    80001252:	83a70713          	addi	a4,a4,-1990 # 80013a88 <phys_addr_refcount_table+0x8>
      phys_addr_refcount_table[i].ref_count++;
      return;
    }
  }
  // If the physical address is not found, add it to the table
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    80001256:	4781                	li	a5,0
    80001258:	6621                	lui	a2,0x8
    if (phys_addr_refcount_table[i].ref_count == 0) {
    8000125a:	4314                	lw	a3,0(a4)
    8000125c:	c2d1                	beqz	a3,800012e0 <increment_ref_count+0xe4>
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    8000125e:	2785                	addiw	a5,a5,1
    80001260:	0741                	addi	a4,a4,16
    80001262:	fec79ce3          	bne	a5,a2,8000125a <increment_ref_count+0x5e>
      return;
    }
  }

  // Table is full - print diagnostic information
  printf("phys_addr_refcount_table is full: %d entries\n", MAXPHYSICALFRAMES);
    80001266:	65a1                	lui	a1,0x8
    80001268:	00007517          	auipc	a0,0x7
    8000126c:	ef050513          	addi	a0,a0,-272 # 80008158 <__func__.1+0x150>
    80001270:	fffff097          	auipc	ra,0xfffff
    80001274:	34c080e7          	jalr	844(ra) # 800005bc <printf>
  printf("Failed to add PA: %p\n", pa);
    80001278:	85a6                	mv	a1,s1
    8000127a:	00007517          	auipc	a0,0x7
    8000127e:	f0e50513          	addi	a0,a0,-242 # 80008188 <__func__.1+0x180>
    80001282:	fffff097          	auipc	ra,0xfffff
    80001286:	33a080e7          	jalr	826(ra) # 800005bc <printf>
  if (pa == UART0 || pa == VIRTIO0 || (pa >= PLIC && pa < PLIC + 0x400000)) {
    printf("Debug: This is MMIO region at %p\n", (uint)pa);
  }
  
  panic("increment_ref_count: no space in phys_addr_refcount_table");
    8000128a:	00007517          	auipc	a0,0x7
    8000128e:	f1650513          	addi	a0,a0,-234 # 800081a0 <__func__.1+0x198>
    80001292:	fffff097          	auipc	ra,0xfffff
    80001296:	2ce080e7          	jalr	718(ra) # 80000560 <panic>
    printf("Error: PA %p outside valid range [%p, %p]\n", 
    8000129a:	46c5                	li	a3,17
    8000129c:	06ee                	slli	a3,a3,0x1b
    8000129e:	4605                	li	a2,1
    800012a0:	067e                	slli	a2,a2,0x1f
    800012a2:	85a6                	mv	a1,s1
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5450513          	addi	a0,a0,-428 # 800080f8 <__func__.1+0xf0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	310080e7          	jalr	784(ra) # 800005bc <printf>
    panic("increment_ref_count: invalid physical address");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e7450513          	addi	a0,a0,-396 # 80008128 <__func__.1+0x120>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	2a4080e7          	jalr	676(ra) # 80000560 <panic>
      phys_addr_refcount_table[i].ref_count++;
    800012c4:	0792                	slli	a5,a5,0x4
    800012c6:	00012717          	auipc	a4,0x12
    800012ca:	7ba70713          	addi	a4,a4,1978 # 80013a80 <phys_addr_refcount_table>
    800012ce:	97ba                	add	a5,a5,a4
    800012d0:	4798                	lw	a4,8(a5)
    800012d2:	2705                	addiw	a4,a4,1
    800012d4:	c798                	sw	a4,8(a5)
}
    800012d6:	60e2                	ld	ra,24(sp)
    800012d8:	6442                	ld	s0,16(sp)
    800012da:	64a2                	ld	s1,8(sp)
    800012dc:	6105                	addi	sp,sp,32
    800012de:	8082                	ret
      phys_addr_refcount_table[i].pa = pa;
    800012e0:	0792                	slli	a5,a5,0x4
    800012e2:	00012717          	auipc	a4,0x12
    800012e6:	79e70713          	addi	a4,a4,1950 # 80013a80 <phys_addr_refcount_table>
    800012ea:	97ba                	add	a5,a5,a4
    800012ec:	e384                	sd	s1,0(a5)
      phys_addr_refcount_table[i].ref_count = 1;
    800012ee:	4705                	li	a4,1
    800012f0:	c798                	sw	a4,8(a5)
      return;
    800012f2:	b7d5                	j	800012d6 <increment_ref_count+0xda>
    800012f4:	8082                	ret

00000000800012f6 <mappages>:
{
    800012f6:	715d                	addi	sp,sp,-80
    800012f8:	e486                	sd	ra,72(sp)
    800012fa:	e0a2                	sd	s0,64(sp)
    800012fc:	fc26                	sd	s1,56(sp)
    800012fe:	f84a                	sd	s2,48(sp)
    80001300:	f44e                	sd	s3,40(sp)
    80001302:	f052                	sd	s4,32(sp)
    80001304:	ec56                	sd	s5,24(sp)
    80001306:	e85a                	sd	s6,16(sp)
    80001308:	e45e                	sd	s7,8(sp)
    8000130a:	e062                	sd	s8,0(sp)
    8000130c:	0880                	addi	s0,sp,80
  if(size == 0)
    8000130e:	ce31                	beqz	a2,8000136a <mappages+0x74>
    80001310:	8b2a                	mv	s6,a0
    80001312:	8bba                	mv	s7,a4
  a = PGROUNDDOWN(va);
    80001314:	777d                	lui	a4,0xfffff
    80001316:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000131a:	fff58a13          	addi	s4,a1,-1 # 7fff <_entry-0x7fff8001>
    8000131e:	9a32                	add	s4,s4,a2
    80001320:	00ea7a33          	and	s4,s4,a4
  a = PGROUNDDOWN(va);
    80001324:	89be                	mv	s3,a5
    80001326:	40f68ab3          	sub	s5,a3,a5
    a += PGSIZE;
    8000132a:	6c05                	lui	s8,0x1
    8000132c:	015984b3          	add	s1,s3,s5
    if((pte = walk(pagetable, a, 1)) == 0)
    80001330:	4605                	li	a2,1
    80001332:	85ce                	mv	a1,s3
    80001334:	855a                	mv	a0,s6
    80001336:	00000097          	auipc	ra,0x0
    8000133a:	db4080e7          	jalr	-588(ra) # 800010ea <walk>
    8000133e:	892a                	mv	s2,a0
    80001340:	c529                	beqz	a0,8000138a <mappages+0x94>
    if(*pte & PTE_V)
    80001342:	611c                	ld	a5,0(a0)
    80001344:	8b85                	andi	a5,a5,1
    80001346:	eb95                	bnez	a5,8000137a <mappages+0x84>
    increment_ref_count(pa);
    80001348:	8526                	mv	a0,s1
    8000134a:	00000097          	auipc	ra,0x0
    8000134e:	eb2080e7          	jalr	-334(ra) # 800011fc <increment_ref_count>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001352:	80b1                	srli	s1,s1,0xc
    80001354:	04aa                	slli	s1,s1,0xa
    80001356:	0174e4b3          	or	s1,s1,s7
    8000135a:	0014e493          	ori	s1,s1,1
    8000135e:	00993023          	sd	s1,0(s2)
    if(a == last)
    80001362:	05498163          	beq	s3,s4,800013a4 <mappages+0xae>
    a += PGSIZE;
    80001366:	99e2                	add	s3,s3,s8
    if((pte = walk(pagetable, a, 1)) == 0)
    80001368:	b7d1                	j	8000132c <mappages+0x36>
    panic("mappages: size");
    8000136a:	00007517          	auipc	a0,0x7
    8000136e:	e7650513          	addi	a0,a0,-394 # 800081e0 <__func__.1+0x1d8>
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	1ee080e7          	jalr	494(ra) # 80000560 <panic>
      panic("mappages: remap");
    8000137a:	00007517          	auipc	a0,0x7
    8000137e:	e7650513          	addi	a0,a0,-394 # 800081f0 <__func__.1+0x1e8>
    80001382:	fffff097          	auipc	ra,0xfffff
    80001386:	1de080e7          	jalr	478(ra) # 80000560 <panic>
      return -1;
    8000138a:	557d                	li	a0,-1
}
    8000138c:	60a6                	ld	ra,72(sp)
    8000138e:	6406                	ld	s0,64(sp)
    80001390:	74e2                	ld	s1,56(sp)
    80001392:	7942                	ld	s2,48(sp)
    80001394:	79a2                	ld	s3,40(sp)
    80001396:	7a02                	ld	s4,32(sp)
    80001398:	6ae2                	ld	s5,24(sp)
    8000139a:	6b42                	ld	s6,16(sp)
    8000139c:	6ba2                	ld	s7,8(sp)
    8000139e:	6c02                	ld	s8,0(sp)
    800013a0:	6161                	addi	sp,sp,80
    800013a2:	8082                	ret
  return 0;
    800013a4:	4501                	li	a0,0
    800013a6:	b7dd                	j	8000138c <mappages+0x96>

00000000800013a8 <kvmmap>:
{
    800013a8:	1141                	addi	sp,sp,-16
    800013aa:	e406                	sd	ra,8(sp)
    800013ac:	e022                	sd	s0,0(sp)
    800013ae:	0800                	addi	s0,sp,16
    800013b0:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800013b2:	86b2                	mv	a3,a2
    800013b4:	863e                	mv	a2,a5
    800013b6:	00000097          	auipc	ra,0x0
    800013ba:	f40080e7          	jalr	-192(ra) # 800012f6 <mappages>
    800013be:	e509                	bnez	a0,800013c8 <kvmmap+0x20>
}
    800013c0:	60a2                	ld	ra,8(sp)
    800013c2:	6402                	ld	s0,0(sp)
    800013c4:	0141                	addi	sp,sp,16
    800013c6:	8082                	ret
    panic("kvmmap");
    800013c8:	00007517          	auipc	a0,0x7
    800013cc:	e3850513          	addi	a0,a0,-456 # 80008200 <__func__.1+0x1f8>
    800013d0:	fffff097          	auipc	ra,0xfffff
    800013d4:	190080e7          	jalr	400(ra) # 80000560 <panic>

00000000800013d8 <kvmmake>:
{
    800013d8:	1101                	addi	sp,sp,-32
    800013da:	ec06                	sd	ra,24(sp)
    800013dc:	e822                	sd	s0,16(sp)
    800013de:	e426                	sd	s1,8(sp)
    800013e0:	e04a                	sd	s2,0(sp)
    800013e2:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800013e4:	fffff097          	auipc	ra,0xfffff
    800013e8:	7e0080e7          	jalr	2016(ra) # 80000bc4 <kalloc>
    800013ec:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800013ee:	6605                	lui	a2,0x1
    800013f0:	4581                	li	a1,0
    800013f2:	00000097          	auipc	ra,0x0
    800013f6:	a14080e7          	jalr	-1516(ra) # 80000e06 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013fa:	4719                	li	a4,6
    800013fc:	6685                	lui	a3,0x1
    800013fe:	10000637          	lui	a2,0x10000
    80001402:	100005b7          	lui	a1,0x10000
    80001406:	8526                	mv	a0,s1
    80001408:	00000097          	auipc	ra,0x0
    8000140c:	fa0080e7          	jalr	-96(ra) # 800013a8 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001410:	4719                	li	a4,6
    80001412:	6685                	lui	a3,0x1
    80001414:	10001637          	lui	a2,0x10001
    80001418:	100015b7          	lui	a1,0x10001
    8000141c:	8526                	mv	a0,s1
    8000141e:	00000097          	auipc	ra,0x0
    80001422:	f8a080e7          	jalr	-118(ra) # 800013a8 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 400000, PTE_R | PTE_W);
    80001426:	4719                	li	a4,6
    80001428:	000626b7          	lui	a3,0x62
    8000142c:	a8068693          	addi	a3,a3,-1408 # 61a80 <_entry-0x7ff9e580>
    80001430:	0c000637          	lui	a2,0xc000
    80001434:	0c0005b7          	lui	a1,0xc000
    80001438:	8526                	mv	a0,s1
    8000143a:	00000097          	auipc	ra,0x0
    8000143e:	f6e080e7          	jalr	-146(ra) # 800013a8 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001442:	00007917          	auipc	s2,0x7
    80001446:	bbe90913          	addi	s2,s2,-1090 # 80008000 <etext>
    8000144a:	4729                	li	a4,10
    8000144c:	80007697          	auipc	a3,0x80007
    80001450:	bb468693          	addi	a3,a3,-1100 # 8000 <_entry-0x7fff8000>
    80001454:	4605                	li	a2,1
    80001456:	067e                	slli	a2,a2,0x1f
    80001458:	85b2                	mv	a1,a2
    8000145a:	8526                	mv	a0,s1
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	f4c080e7          	jalr	-180(ra) # 800013a8 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001464:	46c5                	li	a3,17
    80001466:	06ee                	slli	a3,a3,0x1b
    80001468:	4719                	li	a4,6
    8000146a:	412686b3          	sub	a3,a3,s2
    8000146e:	864a                	mv	a2,s2
    80001470:	85ca                	mv	a1,s2
    80001472:	8526                	mv	a0,s1
    80001474:	00000097          	auipc	ra,0x0
    80001478:	f34080e7          	jalr	-204(ra) # 800013a8 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000147c:	4729                	li	a4,10
    8000147e:	6685                	lui	a3,0x1
    80001480:	00006617          	auipc	a2,0x6
    80001484:	b8060613          	addi	a2,a2,-1152 # 80007000 <_trampoline>
    80001488:	040005b7          	lui	a1,0x4000
    8000148c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000148e:	05b2                	slli	a1,a1,0xc
    80001490:	8526                	mv	a0,s1
    80001492:	00000097          	auipc	ra,0x0
    80001496:	f16080e7          	jalr	-234(ra) # 800013a8 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000149a:	8526                	mv	a0,s1
    8000149c:	00001097          	auipc	ra,0x1
    800014a0:	898080e7          	jalr	-1896(ra) # 80001d34 <proc_mapstacks>
}
    800014a4:	8526                	mv	a0,s1
    800014a6:	60e2                	ld	ra,24(sp)
    800014a8:	6442                	ld	s0,16(sp)
    800014aa:	64a2                	ld	s1,8(sp)
    800014ac:	6902                	ld	s2,0(sp)
    800014ae:	6105                	addi	sp,sp,32
    800014b0:	8082                	ret

00000000800014b2 <kvminit>:
{
    800014b2:	1141                	addi	sp,sp,-16
    800014b4:	e406                	sd	ra,8(sp)
    800014b6:	e022                	sd	s0,0(sp)
    800014b8:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800014ba:	00000097          	auipc	ra,0x0
    800014be:	f1e080e7          	jalr	-226(ra) # 800013d8 <kvmmake>
    800014c2:	0000a797          	auipc	a5,0xa
    800014c6:	32a7bf23          	sd	a0,830(a5) # 8000b800 <kernel_pagetable>
}
    800014ca:	60a2                	ld	ra,8(sp)
    800014cc:	6402                	ld	s0,0(sp)
    800014ce:	0141                	addi	sp,sp,16
    800014d0:	8082                	ret

00000000800014d2 <decrement_ref_count>:

// Decrement the reference count for a physical address and deallocate if it hits zero
void decrement_ref_count(uint64 pa) {
    800014d2:	1101                	addi	sp,sp,-32
    800014d4:	ec06                	sd	ra,24(sp)
    800014d6:	e822                	sd	s0,16(sp)
    800014d8:	e426                	sd	s1,8(sp)
    800014da:	1000                	addi	s0,sp,32
  pa = PGROUNDDOWN(pa);
    800014dc:	77fd                	lui	a5,0xfffff
    800014de:	8d7d                	and	a0,a0,a5

  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    800014e0:	00012797          	auipc	a5,0x12
    800014e4:	5a078793          	addi	a5,a5,1440 # 80013a80 <phys_addr_refcount_table>
    800014e8:	4481                	li	s1,0
    800014ea:	66a1                	lui	a3,0x8
    if (phys_addr_refcount_table[i].pa == pa) {
    800014ec:	6398                	ld	a4,0(a5)
    800014ee:	00a70e63          	beq	a4,a0,8000150a <decrement_ref_count+0x38>
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    800014f2:	2485                	addiw	s1,s1,1
    800014f4:	07c1                	addi	a5,a5,16
    800014f6:	fed49be3          	bne	s1,a3,800014ec <decrement_ref_count+0x1a>
        phys_addr_refcount_table[i].pa = 0;
      }
      return;
    }
  }
  panic("decrement_ref_count: physical address not found");
    800014fa:	00007517          	auipc	a0,0x7
    800014fe:	d0e50513          	addi	a0,a0,-754 # 80008208 <__func__.1+0x200>
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	05e080e7          	jalr	94(ra) # 80000560 <panic>
      phys_addr_refcount_table[i].ref_count--;
    8000150a:	00449713          	slli	a4,s1,0x4
    8000150e:	00012797          	auipc	a5,0x12
    80001512:	57278793          	addi	a5,a5,1394 # 80013a80 <phys_addr_refcount_table>
    80001516:	97ba                	add	a5,a5,a4
    80001518:	4798                	lw	a4,8(a5)
    8000151a:	377d                	addiw	a4,a4,-1 # ffffffffffffefff <end+0xffffffff7ff5a36f>
    8000151c:	0007069b          	sext.w	a3,a4
    80001520:	c798                	sw	a4,8(a5)
      if (phys_addr_refcount_table[i].ref_count == 0) {
    80001522:	c691                	beqz	a3,8000152e <decrement_ref_count+0x5c>
}
    80001524:	60e2                	ld	ra,24(sp)
    80001526:	6442                	ld	s0,16(sp)
    80001528:	64a2                	ld	s1,8(sp)
    8000152a:	6105                	addi	sp,sp,32
    8000152c:	8082                	ret
        kfree((void*)pa);  // Deallocate the physical address
    8000152e:	fffff097          	auipc	ra,0xfffff
    80001532:	52e080e7          	jalr	1326(ra) # 80000a5c <kfree>
        phys_addr_refcount_table[i].pa = 0;
    80001536:	0492                	slli	s1,s1,0x4
    80001538:	00012797          	auipc	a5,0x12
    8000153c:	54878793          	addi	a5,a5,1352 # 80013a80 <phys_addr_refcount_table>
    80001540:	97a6                	add	a5,a5,s1
    80001542:	0007b023          	sd	zero,0(a5)
      return;
    80001546:	bff9                	j	80001524 <decrement_ref_count+0x52>

0000000080001548 <uvmfind>:

uint64
uvmfind(pagetable_t pagetable, uint64 pa)
{
    80001548:	7139                	addi	sp,sp,-64
    8000154a:	fc06                	sd	ra,56(sp)
    8000154c:	f822                	sd	s0,48(sp)
    8000154e:	f426                	sd	s1,40(sp)
    80001550:	f04a                	sd	s2,32(sp)
    80001552:	ec4e                	sd	s3,24(sp)
    80001554:	e852                	sd	s4,16(sp)
    80001556:	e456                	sd	s5,8(sp)
    80001558:	0080                	addi	s0,sp,64
    8000155a:	892a                	mv	s2,a0
    8000155c:	8aae                	mv	s5,a1
  pte_t *pte;
  uint64 va;

  // Iterate over the entire virtual address space.
  // MAXVA is assumed to be the maximum valid virtual address.
  for(va = 0; va < MAXVA; va += PGSIZE){
    8000155e:	4481                	li	s1,0
    80001560:	6a05                	lui	s4,0x1
    80001562:	4985                	li	s3,1
    80001564:	199a                	slli	s3,s3,0x26
    80001566:	a021                	j	8000156e <uvmfind+0x26>
    80001568:	94d2                	add	s1,s1,s4
    8000156a:	03348c63          	beq	s1,s3,800015a2 <uvmfind+0x5a>
    pte = walk(pagetable, va, 0);
    8000156e:	4601                	li	a2,0
    80001570:	85a6                	mv	a1,s1
    80001572:	854a                	mv	a0,s2
    80001574:	00000097          	auipc	ra,0x0
    80001578:	b76080e7          	jalr	-1162(ra) # 800010ea <walk>
    if(pte == 0)
    8000157c:	d575                	beqz	a0,80001568 <uvmfind+0x20>
      continue;             // No page table entry for this va.
    if((*pte & PTE_V) == 0)
    8000157e:	611c                	ld	a5,0(a0)
    80001580:	0017f713          	andi	a4,a5,1
    80001584:	d375                	beqz	a4,80001568 <uvmfind+0x20>
      continue;             // Entry is not valid.
    if(PTE2PA(*pte) == pa)
    80001586:	83a9                	srli	a5,a5,0xa
    80001588:	07b2                	slli	a5,a5,0xc
    8000158a:	fd579fe3          	bne	a5,s5,80001568 <uvmfind+0x20>
      return va;            // Found the mapping; return the virtual address.
  }
  return 0;                 // No mapping found.
}
    8000158e:	8526                	mv	a0,s1
    80001590:	70e2                	ld	ra,56(sp)
    80001592:	7442                	ld	s0,48(sp)
    80001594:	74a2                	ld	s1,40(sp)
    80001596:	7902                	ld	s2,32(sp)
    80001598:	69e2                	ld	s3,24(sp)
    8000159a:	6a42                	ld	s4,16(sp)
    8000159c:	6aa2                	ld	s5,8(sp)
    8000159e:	6121                	addi	sp,sp,64
    800015a0:	8082                	ret
  return 0;                 // No mapping found.
    800015a2:	4481                	li	s1,0
    800015a4:	b7ed                	j	8000158e <uvmfind+0x46>

00000000800015a6 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages)
{
    800015a6:	7139                	addi	sp,sp,-64
    800015a8:	fc06                	sd	ra,56(sp)
    800015aa:	f822                	sd	s0,48(sp)
    800015ac:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800015ae:	03459793          	slli	a5,a1,0x34
    800015b2:	e7b5                	bnez	a5,8000161e <uvmunmap+0x78>
    800015b4:	f04a                	sd	s2,32(sp)
    800015b6:	ec4e                	sd	s3,24(sp)
    800015b8:	e852                	sd	s4,16(sp)
    800015ba:	e456                	sd	s5,8(sp)
    800015bc:	e05a                	sd	s6,0(sp)
    800015be:	8a2a                	mv	s4,a0
    800015c0:	892e                	mv	s2,a1
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800015c2:	00c61993          	slli	s3,a2,0xc
    800015c6:	99ae                	add	s3,s3,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800015c8:	4b05                	li	s6,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800015ca:	6a85                	lui	s5,0x1
    800015cc:	0535f063          	bgeu	a1,s3,8000160c <uvmunmap+0x66>
    800015d0:	f426                	sd	s1,40(sp)
    if((pte = walk(pagetable, a, 0)) == 0)
    800015d2:	4601                	li	a2,0
    800015d4:	85ca                	mv	a1,s2
    800015d6:	8552                	mv	a0,s4
    800015d8:	00000097          	auipc	ra,0x0
    800015dc:	b12080e7          	jalr	-1262(ra) # 800010ea <walk>
    800015e0:	84aa                	mv	s1,a0
    800015e2:	cd21                	beqz	a0,8000163a <uvmunmap+0x94>
    if((*pte & PTE_V) == 0)
    800015e4:	6108                	ld	a0,0(a0)
    800015e6:	00157793          	andi	a5,a0,1
    800015ea:	c3a5                	beqz	a5,8000164a <uvmunmap+0xa4>
    if(PTE_FLAGS(*pte) == PTE_V)
    800015ec:	3ff57793          	andi	a5,a0,1023
    800015f0:	07678563          	beq	a5,s6,8000165a <uvmunmap+0xb4>
      panic("uvmunmap: not a leaf");
    uint64 pa = PTE2PA(*pte);
    800015f4:	8129                	srli	a0,a0,0xa

    decrement_ref_count(pa);
    800015f6:	0532                	slli	a0,a0,0xc
    800015f8:	00000097          	auipc	ra,0x0
    800015fc:	eda080e7          	jalr	-294(ra) # 800014d2 <decrement_ref_count>
    *pte = 0;
    80001600:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001604:	9956                	add	s2,s2,s5
    80001606:	fd3966e3          	bltu	s2,s3,800015d2 <uvmunmap+0x2c>
    8000160a:	74a2                	ld	s1,40(sp)
    8000160c:	7902                	ld	s2,32(sp)
    8000160e:	69e2                	ld	s3,24(sp)
    80001610:	6a42                	ld	s4,16(sp)
    80001612:	6aa2                	ld	s5,8(sp)
    80001614:	6b02                	ld	s6,0(sp)
  }
}
    80001616:	70e2                	ld	ra,56(sp)
    80001618:	7442                	ld	s0,48(sp)
    8000161a:	6121                	addi	sp,sp,64
    8000161c:	8082                	ret
    8000161e:	f426                	sd	s1,40(sp)
    80001620:	f04a                	sd	s2,32(sp)
    80001622:	ec4e                	sd	s3,24(sp)
    80001624:	e852                	sd	s4,16(sp)
    80001626:	e456                	sd	s5,8(sp)
    80001628:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000162a:	00007517          	auipc	a0,0x7
    8000162e:	c0e50513          	addi	a0,a0,-1010 # 80008238 <__func__.1+0x230>
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	f2e080e7          	jalr	-210(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    8000163a:	00007517          	auipc	a0,0x7
    8000163e:	c1650513          	addi	a0,a0,-1002 # 80008250 <__func__.1+0x248>
    80001642:	fffff097          	auipc	ra,0xfffff
    80001646:	f1e080e7          	jalr	-226(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    8000164a:	00007517          	auipc	a0,0x7
    8000164e:	c1650513          	addi	a0,a0,-1002 # 80008260 <__func__.1+0x258>
    80001652:	fffff097          	auipc	ra,0xfffff
    80001656:	f0e080e7          	jalr	-242(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    8000165a:	00007517          	auipc	a0,0x7
    8000165e:	c1e50513          	addi	a0,a0,-994 # 80008278 <__func__.1+0x270>
    80001662:	fffff097          	auipc	ra,0xfffff
    80001666:	efe080e7          	jalr	-258(ra) # 80000560 <panic>

000000008000166a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000166a:	1101                	addi	sp,sp,-32
    8000166c:	ec06                	sd	ra,24(sp)
    8000166e:	e822                	sd	s0,16(sp)
    80001670:	e426                	sd	s1,8(sp)
    80001672:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001674:	fffff097          	auipc	ra,0xfffff
    80001678:	550080e7          	jalr	1360(ra) # 80000bc4 <kalloc>
    8000167c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000167e:	c519                	beqz	a0,8000168c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001680:	6605                	lui	a2,0x1
    80001682:	4581                	li	a1,0
    80001684:	fffff097          	auipc	ra,0xfffff
    80001688:	782080e7          	jalr	1922(ra) # 80000e06 <memset>
  return pagetable;
}
    8000168c:	8526                	mv	a0,s1
    8000168e:	60e2                	ld	ra,24(sp)
    80001690:	6442                	ld	s0,16(sp)
    80001692:	64a2                	ld	s1,8(sp)
    80001694:	6105                	addi	sp,sp,32
    80001696:	8082                	ret

0000000080001698 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001698:	7179                	addi	sp,sp,-48
    8000169a:	f406                	sd	ra,40(sp)
    8000169c:	f022                	sd	s0,32(sp)
    8000169e:	ec26                	sd	s1,24(sp)
    800016a0:	e84a                	sd	s2,16(sp)
    800016a2:	e44e                	sd	s3,8(sp)
    800016a4:	e052                	sd	s4,0(sp)
    800016a6:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800016a8:	6785                	lui	a5,0x1
    800016aa:	04f67863          	bgeu	a2,a5,800016fa <uvmfirst+0x62>
    800016ae:	8a2a                	mv	s4,a0
    800016b0:	89ae                	mv	s3,a1
    800016b2:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800016b4:	fffff097          	auipc	ra,0xfffff
    800016b8:	510080e7          	jalr	1296(ra) # 80000bc4 <kalloc>
    800016bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800016be:	6605                	lui	a2,0x1
    800016c0:	4581                	li	a1,0
    800016c2:	fffff097          	auipc	ra,0xfffff
    800016c6:	744080e7          	jalr	1860(ra) # 80000e06 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800016ca:	4779                	li	a4,30
    800016cc:	86ca                	mv	a3,s2
    800016ce:	6605                	lui	a2,0x1
    800016d0:	4581                	li	a1,0
    800016d2:	8552                	mv	a0,s4
    800016d4:	00000097          	auipc	ra,0x0
    800016d8:	c22080e7          	jalr	-990(ra) # 800012f6 <mappages>
  memmove(mem, src, sz);
    800016dc:	8626                	mv	a2,s1
    800016de:	85ce                	mv	a1,s3
    800016e0:	854a                	mv	a0,s2
    800016e2:	fffff097          	auipc	ra,0xfffff
    800016e6:	780080e7          	jalr	1920(ra) # 80000e62 <memmove>
}
    800016ea:	70a2                	ld	ra,40(sp)
    800016ec:	7402                	ld	s0,32(sp)
    800016ee:	64e2                	ld	s1,24(sp)
    800016f0:	6942                	ld	s2,16(sp)
    800016f2:	69a2                	ld	s3,8(sp)
    800016f4:	6a02                	ld	s4,0(sp)
    800016f6:	6145                	addi	sp,sp,48
    800016f8:	8082                	ret
    panic("uvmfirst: more than a page");
    800016fa:	00007517          	auipc	a0,0x7
    800016fe:	b9650513          	addi	a0,a0,-1130 # 80008290 <__func__.1+0x288>
    80001702:	fffff097          	auipc	ra,0xfffff
    80001706:	e5e080e7          	jalr	-418(ra) # 80000560 <panic>

000000008000170a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000170a:	1101                	addi	sp,sp,-32
    8000170c:	ec06                	sd	ra,24(sp)
    8000170e:	e822                	sd	s0,16(sp)
    80001710:	e426                	sd	s1,8(sp)
    80001712:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001714:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001716:	00b67d63          	bgeu	a2,a1,80001730 <uvmdealloc+0x26>
    8000171a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000171c:	6785                	lui	a5,0x1
    8000171e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001720:	00f60733          	add	a4,a2,a5
    80001724:	76fd                	lui	a3,0xfffff
    80001726:	8f75                	and	a4,a4,a3
    80001728:	97ae                	add	a5,a5,a1
    8000172a:	8ff5                	and	a5,a5,a3
    8000172c:	00f76863          	bltu	a4,a5,8000173c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages);
  }

  return newsz;
}
    80001730:	8526                	mv	a0,s1
    80001732:	60e2                	ld	ra,24(sp)
    80001734:	6442                	ld	s0,16(sp)
    80001736:	64a2                	ld	s1,8(sp)
    80001738:	6105                	addi	sp,sp,32
    8000173a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000173c:	8f99                	sub	a5,a5,a4
    8000173e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages);
    80001740:	0007861b          	sext.w	a2,a5
    80001744:	85ba                	mv	a1,a4
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	e60080e7          	jalr	-416(ra) # 800015a6 <uvmunmap>
    8000174e:	b7cd                	j	80001730 <uvmdealloc+0x26>

0000000080001750 <uvmalloc>:
  if(newsz < oldsz)
    80001750:	0ab66b63          	bltu	a2,a1,80001806 <uvmalloc+0xb6>
{
    80001754:	7139                	addi	sp,sp,-64
    80001756:	fc06                	sd	ra,56(sp)
    80001758:	f822                	sd	s0,48(sp)
    8000175a:	ec4e                	sd	s3,24(sp)
    8000175c:	e852                	sd	s4,16(sp)
    8000175e:	e456                	sd	s5,8(sp)
    80001760:	0080                	addi	s0,sp,64
    80001762:	8aaa                	mv	s5,a0
    80001764:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001766:	6785                	lui	a5,0x1
    80001768:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000176a:	95be                	add	a1,a1,a5
    8000176c:	77fd                	lui	a5,0xfffff
    8000176e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001772:	08c9fc63          	bgeu	s3,a2,8000180a <uvmalloc+0xba>
    80001776:	f426                	sd	s1,40(sp)
    80001778:	f04a                	sd	s2,32(sp)
    8000177a:	e05a                	sd	s6,0(sp)
    8000177c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000177e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001782:	fffff097          	auipc	ra,0xfffff
    80001786:	442080e7          	jalr	1090(ra) # 80000bc4 <kalloc>
    8000178a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000178c:	c915                	beqz	a0,800017c0 <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    8000178e:	6605                	lui	a2,0x1
    80001790:	4581                	li	a1,0
    80001792:	fffff097          	auipc	ra,0xfffff
    80001796:	674080e7          	jalr	1652(ra) # 80000e06 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000179a:	875a                	mv	a4,s6
    8000179c:	86a6                	mv	a3,s1
    8000179e:	6605                	lui	a2,0x1
    800017a0:	85ca                	mv	a1,s2
    800017a2:	8556                	mv	a0,s5
    800017a4:	00000097          	auipc	ra,0x0
    800017a8:	b52080e7          	jalr	-1198(ra) # 800012f6 <mappages>
    800017ac:	ed05                	bnez	a0,800017e4 <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800017ae:	6785                	lui	a5,0x1
    800017b0:	993e                	add	s2,s2,a5
    800017b2:	fd4968e3          	bltu	s2,s4,80001782 <uvmalloc+0x32>
  return newsz;
    800017b6:	8552                	mv	a0,s4
    800017b8:	74a2                	ld	s1,40(sp)
    800017ba:	7902                	ld	s2,32(sp)
    800017bc:	6b02                	ld	s6,0(sp)
    800017be:	a821                	j	800017d6 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800017c0:	864e                	mv	a2,s3
    800017c2:	85ca                	mv	a1,s2
    800017c4:	8556                	mv	a0,s5
    800017c6:	00000097          	auipc	ra,0x0
    800017ca:	f44080e7          	jalr	-188(ra) # 8000170a <uvmdealloc>
      return 0;
    800017ce:	4501                	li	a0,0
    800017d0:	74a2                	ld	s1,40(sp)
    800017d2:	7902                	ld	s2,32(sp)
    800017d4:	6b02                	ld	s6,0(sp)
}
    800017d6:	70e2                	ld	ra,56(sp)
    800017d8:	7442                	ld	s0,48(sp)
    800017da:	69e2                	ld	s3,24(sp)
    800017dc:	6a42                	ld	s4,16(sp)
    800017de:	6aa2                	ld	s5,8(sp)
    800017e0:	6121                	addi	sp,sp,64
    800017e2:	8082                	ret
      kfree(mem);
    800017e4:	8526                	mv	a0,s1
    800017e6:	fffff097          	auipc	ra,0xfffff
    800017ea:	276080e7          	jalr	630(ra) # 80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800017ee:	864e                	mv	a2,s3
    800017f0:	85ca                	mv	a1,s2
    800017f2:	8556                	mv	a0,s5
    800017f4:	00000097          	auipc	ra,0x0
    800017f8:	f16080e7          	jalr	-234(ra) # 8000170a <uvmdealloc>
      return 0;
    800017fc:	4501                	li	a0,0
    800017fe:	74a2                	ld	s1,40(sp)
    80001800:	7902                	ld	s2,32(sp)
    80001802:	6b02                	ld	s6,0(sp)
    80001804:	bfc9                	j	800017d6 <uvmalloc+0x86>
    return oldsz;
    80001806:	852e                	mv	a0,a1
}
    80001808:	8082                	ret
  return newsz;
    8000180a:	8532                	mv	a0,a2
    8000180c:	b7e9                	j	800017d6 <uvmalloc+0x86>

000000008000180e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000180e:	7179                	addi	sp,sp,-48
    80001810:	f406                	sd	ra,40(sp)
    80001812:	f022                	sd	s0,32(sp)
    80001814:	ec26                	sd	s1,24(sp)
    80001816:	e84a                	sd	s2,16(sp)
    80001818:	e44e                	sd	s3,8(sp)
    8000181a:	e052                	sd	s4,0(sp)
    8000181c:	1800                	addi	s0,sp,48
    8000181e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001820:	84aa                	mv	s1,a0
    80001822:	6905                	lui	s2,0x1
    80001824:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001826:	4985                	li	s3,1
    80001828:	a829                	j	80001842 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000182a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000182c:	00c79513          	slli	a0,a5,0xc
    80001830:	00000097          	auipc	ra,0x0
    80001834:	fde080e7          	jalr	-34(ra) # 8000180e <freewalk>
      pagetable[i] = 0;
    80001838:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000183c:	04a1                	addi	s1,s1,8
    8000183e:	03248163          	beq	s1,s2,80001860 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001842:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001844:	00f7f713          	andi	a4,a5,15
    80001848:	ff3701e3          	beq	a4,s3,8000182a <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000184c:	8b85                	andi	a5,a5,1
    8000184e:	d7fd                	beqz	a5,8000183c <freewalk+0x2e>
      panic("freewalk: leaf");
    80001850:	00007517          	auipc	a0,0x7
    80001854:	a6050513          	addi	a0,a0,-1440 # 800082b0 <__func__.1+0x2a8>
    80001858:	fffff097          	auipc	ra,0xfffff
    8000185c:	d08080e7          	jalr	-760(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    80001860:	8552                	mv	a0,s4
    80001862:	fffff097          	auipc	ra,0xfffff
    80001866:	1fa080e7          	jalr	506(ra) # 80000a5c <kfree>
}
    8000186a:	70a2                	ld	ra,40(sp)
    8000186c:	7402                	ld	s0,32(sp)
    8000186e:	64e2                	ld	s1,24(sp)
    80001870:	6942                	ld	s2,16(sp)
    80001872:	69a2                	ld	s3,8(sp)
    80001874:	6a02                	ld	s4,0(sp)
    80001876:	6145                	addi	sp,sp,48
    80001878:	8082                	ret

000000008000187a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000187a:	1101                	addi	sp,sp,-32
    8000187c:	ec06                	sd	ra,24(sp)
    8000187e:	e822                	sd	s0,16(sp)
    80001880:	e426                	sd	s1,8(sp)
    80001882:	1000                	addi	s0,sp,32
    80001884:	84aa                	mv	s1,a0
  if(sz > 0)
    80001886:	e999                	bnez	a1,8000189c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE);
  freewalk(pagetable);
    80001888:	8526                	mv	a0,s1
    8000188a:	00000097          	auipc	ra,0x0
    8000188e:	f84080e7          	jalr	-124(ra) # 8000180e <freewalk>
}
    80001892:	60e2                	ld	ra,24(sp)
    80001894:	6442                	ld	s0,16(sp)
    80001896:	64a2                	ld	s1,8(sp)
    80001898:	6105                	addi	sp,sp,32
    8000189a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE);
    8000189c:	6785                	lui	a5,0x1
    8000189e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800018a0:	95be                	add	a1,a1,a5
    800018a2:	00c5d613          	srli	a2,a1,0xc
    800018a6:	4581                	li	a1,0
    800018a8:	00000097          	auipc	ra,0x0
    800018ac:	cfe080e7          	jalr	-770(ra) # 800015a6 <uvmunmap>
    800018b0:	bfe1                	j	80001888 <uvmfree+0xe>

00000000800018b2 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800018b2:	c671                	beqz	a2,8000197e <uvmcopy+0xcc>
{
    800018b4:	715d                	addi	sp,sp,-80
    800018b6:	e486                	sd	ra,72(sp)
    800018b8:	e0a2                	sd	s0,64(sp)
    800018ba:	fc26                	sd	s1,56(sp)
    800018bc:	f84a                	sd	s2,48(sp)
    800018be:	f44e                	sd	s3,40(sp)
    800018c0:	f052                	sd	s4,32(sp)
    800018c2:	ec56                	sd	s5,24(sp)
    800018c4:	e85a                	sd	s6,16(sp)
    800018c6:	e45e                	sd	s7,8(sp)
    800018c8:	0880                	addi	s0,sp,80
    800018ca:	8b2a                	mv	s6,a0
    800018cc:	8aae                	mv	s5,a1
    800018ce:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800018d0:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800018d2:	4601                	li	a2,0
    800018d4:	85ce                	mv	a1,s3
    800018d6:	855a                	mv	a0,s6
    800018d8:	00000097          	auipc	ra,0x0
    800018dc:	812080e7          	jalr	-2030(ra) # 800010ea <walk>
    800018e0:	c531                	beqz	a0,8000192c <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800018e2:	6118                	ld	a4,0(a0)
    800018e4:	00177793          	andi	a5,a4,1
    800018e8:	cbb1                	beqz	a5,8000193c <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800018ea:	00a75593          	srli	a1,a4,0xa
    800018ee:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800018f2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800018f6:	fffff097          	auipc	ra,0xfffff
    800018fa:	2ce080e7          	jalr	718(ra) # 80000bc4 <kalloc>
    800018fe:	892a                	mv	s2,a0
    80001900:	c939                	beqz	a0,80001956 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001902:	6605                	lui	a2,0x1
    80001904:	85de                	mv	a1,s7
    80001906:	fffff097          	auipc	ra,0xfffff
    8000190a:	55c080e7          	jalr	1372(ra) # 80000e62 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000190e:	8726                	mv	a4,s1
    80001910:	86ca                	mv	a3,s2
    80001912:	6605                	lui	a2,0x1
    80001914:	85ce                	mv	a1,s3
    80001916:	8556                	mv	a0,s5
    80001918:	00000097          	auipc	ra,0x0
    8000191c:	9de080e7          	jalr	-1570(ra) # 800012f6 <mappages>
    80001920:	e515                	bnez	a0,8000194c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001922:	6785                	lui	a5,0x1
    80001924:	99be                	add	s3,s3,a5
    80001926:	fb49e6e3          	bltu	s3,s4,800018d2 <uvmcopy+0x20>
    8000192a:	a83d                	j	80001968 <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    8000192c:	00007517          	auipc	a0,0x7
    80001930:	99450513          	addi	a0,a0,-1644 # 800082c0 <__func__.1+0x2b8>
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	c2c080e7          	jalr	-980(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    8000193c:	00007517          	auipc	a0,0x7
    80001940:	9a450513          	addi	a0,a0,-1628 # 800082e0 <__func__.1+0x2d8>
    80001944:	fffff097          	auipc	ra,0xfffff
    80001948:	c1c080e7          	jalr	-996(ra) # 80000560 <panic>
      kfree(mem);
    8000194c:	854a                	mv	a0,s2
    8000194e:	fffff097          	auipc	ra,0xfffff
    80001952:	10e080e7          	jalr	270(ra) # 80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE);
    80001956:	00c9d613          	srli	a2,s3,0xc
    8000195a:	4581                	li	a1,0
    8000195c:	8556                	mv	a0,s5
    8000195e:	00000097          	auipc	ra,0x0
    80001962:	c48080e7          	jalr	-952(ra) # 800015a6 <uvmunmap>
  return -1;
    80001966:	557d                	li	a0,-1
}
    80001968:	60a6                	ld	ra,72(sp)
    8000196a:	6406                	ld	s0,64(sp)
    8000196c:	74e2                	ld	s1,56(sp)
    8000196e:	7942                	ld	s2,48(sp)
    80001970:	79a2                	ld	s3,40(sp)
    80001972:	7a02                	ld	s4,32(sp)
    80001974:	6ae2                	ld	s5,24(sp)
    80001976:	6b42                	ld	s6,16(sp)
    80001978:	6ba2                	ld	s7,8(sp)
    8000197a:	6161                	addi	sp,sp,80
    8000197c:	8082                	ret
  return 0;
    8000197e:	4501                	li	a0,0
}
    80001980:	8082                	ret

0000000080001982 <uvmremap>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001982:	ca79                	beqz	a2,80001a58 <uvmremap+0xd6>
{
    80001984:	7139                	addi	sp,sp,-64
    80001986:	fc06                	sd	ra,56(sp)
    80001988:	f822                	sd	s0,48(sp)
    8000198a:	f426                	sd	s1,40(sp)
    8000198c:	f04a                	sd	s2,32(sp)
    8000198e:	ec4e                	sd	s3,24(sp)
    80001990:	e852                	sd	s4,16(sp)
    80001992:	e456                	sd	s5,8(sp)
    80001994:	e05a                	sd	s6,0(sp)
    80001996:	0080                	addi	s0,sp,64
    80001998:	8a2a                	mv	s4,a0
    8000199a:	8b2e                	mv	s6,a1
    8000199c:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000199e:	4481                	li	s1,0
    if((pte = walk(parent, i, 0)) == 0)
    800019a0:	4601                	li	a2,0
    800019a2:	85a6                	mv	a1,s1
    800019a4:	8552                	mv	a0,s4
    800019a6:	fffff097          	auipc	ra,0xfffff
    800019aa:	744080e7          	jalr	1860(ra) # 800010ea <walk>
    800019ae:	c52d                	beqz	a0,80001a18 <uvmremap+0x96>
      panic("uvmremap: pte should exist");
    if((*pte & PTE_V) == 0)
    800019b0:	00053903          	ld	s2,0(a0)
    800019b4:	00197793          	andi	a5,s2,1
    800019b8:	cba5                	beqz	a5,80001a28 <uvmremap+0xa6>
      panic("uvmremap: page not present");
    pa = PTE2PA(*pte);
    800019ba:	00a95993          	srli	s3,s2,0xa
    800019be:	09b2                	slli	s3,s3,0xc
    flags = PTE_FLAGS(*pte) & ~PTE_W;

    // Remove previous mapping
    uvmunmap(parent, i, 1);
    800019c0:	4605                	li	a2,1
    800019c2:	85a6                	mv	a1,s1
    800019c4:	8552                	mv	a0,s4
    800019c6:	00000097          	auipc	ra,0x0
    800019ca:	be0080e7          	jalr	-1056(ra) # 800015a6 <uvmunmap>
    // Remove write permission from parent pagetable
    if(mappages(parent, i, PGSIZE, pa, flags) != 0){
    800019ce:	3fb97913          	andi	s2,s2,1019
    800019d2:	874a                	mv	a4,s2
    800019d4:	86ce                	mv	a3,s3
    800019d6:	6605                	lui	a2,0x1
    800019d8:	85a6                	mv	a1,s1
    800019da:	8552                	mv	a0,s4
    800019dc:	00000097          	auipc	ra,0x0
    800019e0:	91a080e7          	jalr	-1766(ra) # 800012f6 <mappages>
    800019e4:	e931                	bnez	a0,80001a38 <uvmremap+0xb6>
      panic("uvmremap: couldnt remap pte for parent");
    }

    // Mappinig new page table netry to child
    if(mappages(child, i, PGSIZE, pa, flags) != 0){
    800019e6:	874a                	mv	a4,s2
    800019e8:	86ce                	mv	a3,s3
    800019ea:	6605                	lui	a2,0x1
    800019ec:	85a6                	mv	a1,s1
    800019ee:	855a                	mv	a0,s6
    800019f0:	00000097          	auipc	ra,0x0
    800019f4:	906080e7          	jalr	-1786(ra) # 800012f6 <mappages>
    800019f8:	e921                	bnez	a0,80001a48 <uvmremap+0xc6>
  for(i = 0; i < sz; i += PGSIZE){
    800019fa:	6785                	lui	a5,0x1
    800019fc:	94be                	add	s1,s1,a5
    800019fe:	fb54e1e3          	bltu	s1,s5,800019a0 <uvmremap+0x1e>
      panic("uvmremap: couldnt map pte to child");
    }
  }
  return 0;

}
    80001a02:	4501                	li	a0,0
    80001a04:	70e2                	ld	ra,56(sp)
    80001a06:	7442                	ld	s0,48(sp)
    80001a08:	74a2                	ld	s1,40(sp)
    80001a0a:	7902                	ld	s2,32(sp)
    80001a0c:	69e2                	ld	s3,24(sp)
    80001a0e:	6a42                	ld	s4,16(sp)
    80001a10:	6aa2                	ld	s5,8(sp)
    80001a12:	6b02                	ld	s6,0(sp)
    80001a14:	6121                	addi	sp,sp,64
    80001a16:	8082                	ret
      panic("uvmremap: pte should exist");
    80001a18:	00007517          	auipc	a0,0x7
    80001a1c:	8e850513          	addi	a0,a0,-1816 # 80008300 <__func__.1+0x2f8>
    80001a20:	fffff097          	auipc	ra,0xfffff
    80001a24:	b40080e7          	jalr	-1216(ra) # 80000560 <panic>
      panic("uvmremap: page not present");
    80001a28:	00007517          	auipc	a0,0x7
    80001a2c:	8f850513          	addi	a0,a0,-1800 # 80008320 <__func__.1+0x318>
    80001a30:	fffff097          	auipc	ra,0xfffff
    80001a34:	b30080e7          	jalr	-1232(ra) # 80000560 <panic>
      panic("uvmremap: couldnt remap pte for parent");
    80001a38:	00007517          	auipc	a0,0x7
    80001a3c:	90850513          	addi	a0,a0,-1784 # 80008340 <__func__.1+0x338>
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	b20080e7          	jalr	-1248(ra) # 80000560 <panic>
      panic("uvmremap: couldnt map pte to child");
    80001a48:	00007517          	auipc	a0,0x7
    80001a4c:	92050513          	addi	a0,a0,-1760 # 80008368 <__func__.1+0x360>
    80001a50:	fffff097          	auipc	ra,0xfffff
    80001a54:	b10080e7          	jalr	-1264(ra) # 80000560 <panic>
}
    80001a58:	4501                	li	a0,0
    80001a5a:	8082                	ret

0000000080001a5c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001a5c:	1141                	addi	sp,sp,-16
    80001a5e:	e406                	sd	ra,8(sp)
    80001a60:	e022                	sd	s0,0(sp)
    80001a62:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001a64:	4601                	li	a2,0
    80001a66:	fffff097          	auipc	ra,0xfffff
    80001a6a:	684080e7          	jalr	1668(ra) # 800010ea <walk>
  if(pte == 0)
    80001a6e:	c901                	beqz	a0,80001a7e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001a70:	611c                	ld	a5,0(a0)
    80001a72:	9bbd                	andi	a5,a5,-17
    80001a74:	e11c                	sd	a5,0(a0)
}
    80001a76:	60a2                	ld	ra,8(sp)
    80001a78:	6402                	ld	s0,0(sp)
    80001a7a:	0141                	addi	sp,sp,16
    80001a7c:	8082                	ret
    panic("uvmclear");
    80001a7e:	00007517          	auipc	a0,0x7
    80001a82:	91250513          	addi	a0,a0,-1774 # 80008390 <__func__.1+0x388>
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	ada080e7          	jalr	-1318(ra) # 80000560 <panic>

0000000080001a8e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001a8e:	c6bd                	beqz	a3,80001afc <copyout+0x6e>
{
    80001a90:	715d                	addi	sp,sp,-80
    80001a92:	e486                	sd	ra,72(sp)
    80001a94:	e0a2                	sd	s0,64(sp)
    80001a96:	fc26                	sd	s1,56(sp)
    80001a98:	f84a                	sd	s2,48(sp)
    80001a9a:	f44e                	sd	s3,40(sp)
    80001a9c:	f052                	sd	s4,32(sp)
    80001a9e:	ec56                	sd	s5,24(sp)
    80001aa0:	e85a                	sd	s6,16(sp)
    80001aa2:	e45e                	sd	s7,8(sp)
    80001aa4:	e062                	sd	s8,0(sp)
    80001aa6:	0880                	addi	s0,sp,80
    80001aa8:	8b2a                	mv	s6,a0
    80001aaa:	8c2e                	mv	s8,a1
    80001aac:	8a32                	mv	s4,a2
    80001aae:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001ab0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001ab2:	6a85                	lui	s5,0x1
    80001ab4:	a015                	j	80001ad8 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001ab6:	9562                	add	a0,a0,s8
    80001ab8:	0004861b          	sext.w	a2,s1
    80001abc:	85d2                	mv	a1,s4
    80001abe:	41250533          	sub	a0,a0,s2
    80001ac2:	fffff097          	auipc	ra,0xfffff
    80001ac6:	3a0080e7          	jalr	928(ra) # 80000e62 <memmove>

    len -= n;
    80001aca:	409989b3          	sub	s3,s3,s1
    src += n;
    80001ace:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001ad0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001ad4:	02098263          	beqz	s3,80001af8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001ad8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001adc:	85ca                	mv	a1,s2
    80001ade:	855a                	mv	a0,s6
    80001ae0:	fffff097          	auipc	ra,0xfffff
    80001ae4:	6b0080e7          	jalr	1712(ra) # 80001190 <walkaddr>
    if(pa0 == 0)
    80001ae8:	cd01                	beqz	a0,80001b00 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001aea:	418904b3          	sub	s1,s2,s8
    80001aee:	94d6                	add	s1,s1,s5
    if(n > len)
    80001af0:	fc99f3e3          	bgeu	s3,s1,80001ab6 <copyout+0x28>
    80001af4:	84ce                	mv	s1,s3
    80001af6:	b7c1                	j	80001ab6 <copyout+0x28>
  }
  return 0;
    80001af8:	4501                	li	a0,0
    80001afa:	a021                	j	80001b02 <copyout+0x74>
    80001afc:	4501                	li	a0,0
}
    80001afe:	8082                	ret
      return -1;
    80001b00:	557d                	li	a0,-1
}
    80001b02:	60a6                	ld	ra,72(sp)
    80001b04:	6406                	ld	s0,64(sp)
    80001b06:	74e2                	ld	s1,56(sp)
    80001b08:	7942                	ld	s2,48(sp)
    80001b0a:	79a2                	ld	s3,40(sp)
    80001b0c:	7a02                	ld	s4,32(sp)
    80001b0e:	6ae2                	ld	s5,24(sp)
    80001b10:	6b42                	ld	s6,16(sp)
    80001b12:	6ba2                	ld	s7,8(sp)
    80001b14:	6c02                	ld	s8,0(sp)
    80001b16:	6161                	addi	sp,sp,80
    80001b18:	8082                	ret

0000000080001b1a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001b1a:	caa5                	beqz	a3,80001b8a <copyin+0x70>
{
    80001b1c:	715d                	addi	sp,sp,-80
    80001b1e:	e486                	sd	ra,72(sp)
    80001b20:	e0a2                	sd	s0,64(sp)
    80001b22:	fc26                	sd	s1,56(sp)
    80001b24:	f84a                	sd	s2,48(sp)
    80001b26:	f44e                	sd	s3,40(sp)
    80001b28:	f052                	sd	s4,32(sp)
    80001b2a:	ec56                	sd	s5,24(sp)
    80001b2c:	e85a                	sd	s6,16(sp)
    80001b2e:	e45e                	sd	s7,8(sp)
    80001b30:	e062                	sd	s8,0(sp)
    80001b32:	0880                	addi	s0,sp,80
    80001b34:	8b2a                	mv	s6,a0
    80001b36:	8a2e                	mv	s4,a1
    80001b38:	8c32                	mv	s8,a2
    80001b3a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001b3c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001b3e:	6a85                	lui	s5,0x1
    80001b40:	a01d                	j	80001b66 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001b42:	018505b3          	add	a1,a0,s8
    80001b46:	0004861b          	sext.w	a2,s1
    80001b4a:	412585b3          	sub	a1,a1,s2
    80001b4e:	8552                	mv	a0,s4
    80001b50:	fffff097          	auipc	ra,0xfffff
    80001b54:	312080e7          	jalr	786(ra) # 80000e62 <memmove>

    len -= n;
    80001b58:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001b5c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001b5e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001b62:	02098263          	beqz	s3,80001b86 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001b66:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001b6a:	85ca                	mv	a1,s2
    80001b6c:	855a                	mv	a0,s6
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	622080e7          	jalr	1570(ra) # 80001190 <walkaddr>
    if(pa0 == 0)
    80001b76:	cd01                	beqz	a0,80001b8e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001b78:	418904b3          	sub	s1,s2,s8
    80001b7c:	94d6                	add	s1,s1,s5
    if(n > len)
    80001b7e:	fc99f2e3          	bgeu	s3,s1,80001b42 <copyin+0x28>
    80001b82:	84ce                	mv	s1,s3
    80001b84:	bf7d                	j	80001b42 <copyin+0x28>
  }
  return 0;
    80001b86:	4501                	li	a0,0
    80001b88:	a021                	j	80001b90 <copyin+0x76>
    80001b8a:	4501                	li	a0,0
}
    80001b8c:	8082                	ret
      return -1;
    80001b8e:	557d                	li	a0,-1
}
    80001b90:	60a6                	ld	ra,72(sp)
    80001b92:	6406                	ld	s0,64(sp)
    80001b94:	74e2                	ld	s1,56(sp)
    80001b96:	7942                	ld	s2,48(sp)
    80001b98:	79a2                	ld	s3,40(sp)
    80001b9a:	7a02                	ld	s4,32(sp)
    80001b9c:	6ae2                	ld	s5,24(sp)
    80001b9e:	6b42                	ld	s6,16(sp)
    80001ba0:	6ba2                	ld	s7,8(sp)
    80001ba2:	6c02                	ld	s8,0(sp)
    80001ba4:	6161                	addi	sp,sp,80
    80001ba6:	8082                	ret

0000000080001ba8 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001ba8:	cacd                	beqz	a3,80001c5a <copyinstr+0xb2>
{
    80001baa:	715d                	addi	sp,sp,-80
    80001bac:	e486                	sd	ra,72(sp)
    80001bae:	e0a2                	sd	s0,64(sp)
    80001bb0:	fc26                	sd	s1,56(sp)
    80001bb2:	f84a                	sd	s2,48(sp)
    80001bb4:	f44e                	sd	s3,40(sp)
    80001bb6:	f052                	sd	s4,32(sp)
    80001bb8:	ec56                	sd	s5,24(sp)
    80001bba:	e85a                	sd	s6,16(sp)
    80001bbc:	e45e                	sd	s7,8(sp)
    80001bbe:	0880                	addi	s0,sp,80
    80001bc0:	8a2a                	mv	s4,a0
    80001bc2:	8b2e                	mv	s6,a1
    80001bc4:	8bb2                	mv	s7,a2
    80001bc6:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80001bc8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001bca:	6985                	lui	s3,0x1
    80001bcc:	a825                	j	80001c04 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001bce:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001bd2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001bd4:	37fd                	addiw	a5,a5,-1
    80001bd6:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001bda:	60a6                	ld	ra,72(sp)
    80001bdc:	6406                	ld	s0,64(sp)
    80001bde:	74e2                	ld	s1,56(sp)
    80001be0:	7942                	ld	s2,48(sp)
    80001be2:	79a2                	ld	s3,40(sp)
    80001be4:	7a02                	ld	s4,32(sp)
    80001be6:	6ae2                	ld	s5,24(sp)
    80001be8:	6b42                	ld	s6,16(sp)
    80001bea:	6ba2                	ld	s7,8(sp)
    80001bec:	6161                	addi	sp,sp,80
    80001bee:	8082                	ret
    80001bf0:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001bf4:	9742                	add	a4,a4,a6
      --max;
    80001bf6:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001bfa:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001bfe:	04e58663          	beq	a1,a4,80001c4a <copyinstr+0xa2>
{
    80001c02:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001c04:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001c08:	85a6                	mv	a1,s1
    80001c0a:	8552                	mv	a0,s4
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	584080e7          	jalr	1412(ra) # 80001190 <walkaddr>
    if(pa0 == 0)
    80001c14:	cd0d                	beqz	a0,80001c4e <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80001c16:	417486b3          	sub	a3,s1,s7
    80001c1a:	96ce                	add	a3,a3,s3
    if(n > max)
    80001c1c:	00d97363          	bgeu	s2,a3,80001c22 <copyinstr+0x7a>
    80001c20:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001c22:	955e                	add	a0,a0,s7
    80001c24:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001c26:	c695                	beqz	a3,80001c52 <copyinstr+0xaa>
    80001c28:	87da                	mv	a5,s6
    80001c2a:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001c2c:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001c30:	96da                	add	a3,a3,s6
    80001c32:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001c34:	00f60733          	add	a4,a2,a5
    80001c38:	00074703          	lbu	a4,0(a4)
    80001c3c:	db49                	beqz	a4,80001bce <copyinstr+0x26>
        *dst = *p;
    80001c3e:	00e78023          	sb	a4,0(a5)
      dst++;
    80001c42:	0785                	addi	a5,a5,1
    while(n > 0){
    80001c44:	fed797e3          	bne	a5,a3,80001c32 <copyinstr+0x8a>
    80001c48:	b765                	j	80001bf0 <copyinstr+0x48>
    80001c4a:	4781                	li	a5,0
    80001c4c:	b761                	j	80001bd4 <copyinstr+0x2c>
      return -1;
    80001c4e:	557d                	li	a0,-1
    80001c50:	b769                	j	80001bda <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001c52:	6b85                	lui	s7,0x1
    80001c54:	9ba6                	add	s7,s7,s1
    80001c56:	87da                	mv	a5,s6
    80001c58:	b76d                	j	80001c02 <copyinstr+0x5a>
  int got_null = 0;
    80001c5a:	4781                	li	a5,0
  if(got_null){
    80001c5c:	37fd                	addiw	a5,a5,-1
    80001c5e:	0007851b          	sext.w	a0,a5
}
    80001c62:	8082                	ret

0000000080001c64 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001c64:	715d                	addi	sp,sp,-80
    80001c66:	e486                	sd	ra,72(sp)
    80001c68:	e0a2                	sd	s0,64(sp)
    80001c6a:	fc26                	sd	s1,56(sp)
    80001c6c:	f84a                	sd	s2,48(sp)
    80001c6e:	f44e                	sd	s3,40(sp)
    80001c70:	f052                	sd	s4,32(sp)
    80001c72:	ec56                	sd	s5,24(sp)
    80001c74:	e85a                	sd	s6,16(sp)
    80001c76:	e45e                	sd	s7,8(sp)
    80001c78:	e062                	sd	s8,0(sp)
    80001c7a:	0880                	addi	s0,sp,80
    asm volatile("mv %0, tp" : "=r"(x));
    80001c7c:	8792                	mv	a5,tp
    int id = r_tp();
    80001c7e:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001c80:	00092a97          	auipc	s5,0x92
    80001c84:	e00a8a93          	addi	s5,s5,-512 # 80093a80 <cpus>
    80001c88:	00779713          	slli	a4,a5,0x7
    80001c8c:	00ea86b3          	add	a3,s5,a4
    80001c90:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ff5a370>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001c94:	0721                	addi	a4,a4,8
    80001c96:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001c98:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001c9a:	0000ac17          	auipc	s8,0xa
    80001c9e:	a9ec0c13          	addi	s8,s8,-1378 # 8000b738 <sched_pointer>
    80001ca2:	00000b97          	auipc	s7,0x0
    80001ca6:	fc2b8b93          	addi	s7,s7,-62 # 80001c64 <rr_scheduler>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80001caa:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001cae:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80001cb2:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001cb6:	00092497          	auipc	s1,0x92
    80001cba:	1fa48493          	addi	s1,s1,506 # 80093eb0 <proc>
            if (p->state == RUNNABLE)
    80001cbe:	498d                	li	s3,3
                p->state = RUNNING;
    80001cc0:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001cc2:	00098a17          	auipc	s4,0x98
    80001cc6:	beea0a13          	addi	s4,s4,-1042 # 800998b0 <tickslock>
    80001cca:	a81d                	j	80001d00 <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001ccc:	8526                	mv	a0,s1
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	0f0080e7          	jalr	240(ra) # 80000dbe <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001cd6:	60a6                	ld	ra,72(sp)
    80001cd8:	6406                	ld	s0,64(sp)
    80001cda:	74e2                	ld	s1,56(sp)
    80001cdc:	7942                	ld	s2,48(sp)
    80001cde:	79a2                	ld	s3,40(sp)
    80001ce0:	7a02                	ld	s4,32(sp)
    80001ce2:	6ae2                	ld	s5,24(sp)
    80001ce4:	6b42                	ld	s6,16(sp)
    80001ce6:	6ba2                	ld	s7,8(sp)
    80001ce8:	6c02                	ld	s8,0(sp)
    80001cea:	6161                	addi	sp,sp,80
    80001cec:	8082                	ret
            release(&p->lock);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	0ce080e7          	jalr	206(ra) # 80000dbe <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001cf8:	16848493          	addi	s1,s1,360
    80001cfc:	fb4487e3          	beq	s1,s4,80001caa <rr_scheduler+0x46>
            acquire(&p->lock);
    80001d00:	8526                	mv	a0,s1
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	008080e7          	jalr	8(ra) # 80000d0a <acquire>
            if (p->state == RUNNABLE)
    80001d0a:	4c9c                	lw	a5,24(s1)
    80001d0c:	ff3791e3          	bne	a5,s3,80001cee <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001d10:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001d14:	00993023          	sd	s1,0(s2)
                swtch(&c->context, &p->context);
    80001d18:	06048593          	addi	a1,s1,96
    80001d1c:	8556                	mv	a0,s5
    80001d1e:	00001097          	auipc	ra,0x1
    80001d22:	08a080e7          	jalr	138(ra) # 80002da8 <swtch>
                if (sched_pointer != &rr_scheduler)
    80001d26:	000c3783          	ld	a5,0(s8)
    80001d2a:	fb7791e3          	bne	a5,s7,80001ccc <rr_scheduler+0x68>
                c->proc = 0;
    80001d2e:	00093023          	sd	zero,0(s2)
    80001d32:	bf75                	j	80001cee <rr_scheduler+0x8a>

0000000080001d34 <proc_mapstacks>:
{
    80001d34:	7139                	addi	sp,sp,-64
    80001d36:	fc06                	sd	ra,56(sp)
    80001d38:	f822                	sd	s0,48(sp)
    80001d3a:	f426                	sd	s1,40(sp)
    80001d3c:	f04a                	sd	s2,32(sp)
    80001d3e:	ec4e                	sd	s3,24(sp)
    80001d40:	e852                	sd	s4,16(sp)
    80001d42:	e456                	sd	s5,8(sp)
    80001d44:	e05a                	sd	s6,0(sp)
    80001d46:	0080                	addi	s0,sp,64
    80001d48:	8a2a                	mv	s4,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001d4a:	00092497          	auipc	s1,0x92
    80001d4e:	16648493          	addi	s1,s1,358 # 80093eb0 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001d52:	8b26                	mv	s6,s1
    80001d54:	04fa5937          	lui	s2,0x4fa5
    80001d58:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001d5c:	0932                	slli	s2,s2,0xc
    80001d5e:	fa590913          	addi	s2,s2,-91
    80001d62:	0932                	slli	s2,s2,0xc
    80001d64:	fa590913          	addi	s2,s2,-91
    80001d68:	0932                	slli	s2,s2,0xc
    80001d6a:	fa590913          	addi	s2,s2,-91
    80001d6e:	040009b7          	lui	s3,0x4000
    80001d72:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001d74:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001d76:	00098a97          	auipc	s5,0x98
    80001d7a:	b3aa8a93          	addi	s5,s5,-1222 # 800998b0 <tickslock>
        char *pa = kalloc();
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	e46080e7          	jalr	-442(ra) # 80000bc4 <kalloc>
    80001d86:	862a                	mv	a2,a0
        if (pa == 0)
    80001d88:	c121                	beqz	a0,80001dc8 <proc_mapstacks+0x94>
        uint64 va = KSTACK((int)(p - proc));
    80001d8a:	416485b3          	sub	a1,s1,s6
    80001d8e:	858d                	srai	a1,a1,0x3
    80001d90:	032585b3          	mul	a1,a1,s2
    80001d94:	2585                	addiw	a1,a1,1
    80001d96:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001d9a:	4719                	li	a4,6
    80001d9c:	6685                	lui	a3,0x1
    80001d9e:	40b985b3          	sub	a1,s3,a1
    80001da2:	8552                	mv	a0,s4
    80001da4:	fffff097          	auipc	ra,0xfffff
    80001da8:	604080e7          	jalr	1540(ra) # 800013a8 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001dac:	16848493          	addi	s1,s1,360
    80001db0:	fd5497e3          	bne	s1,s5,80001d7e <proc_mapstacks+0x4a>
}
    80001db4:	70e2                	ld	ra,56(sp)
    80001db6:	7442                	ld	s0,48(sp)
    80001db8:	74a2                	ld	s1,40(sp)
    80001dba:	7902                	ld	s2,32(sp)
    80001dbc:	69e2                	ld	s3,24(sp)
    80001dbe:	6a42                	ld	s4,16(sp)
    80001dc0:	6aa2                	ld	s5,8(sp)
    80001dc2:	6b02                	ld	s6,0(sp)
    80001dc4:	6121                	addi	sp,sp,64
    80001dc6:	8082                	ret
            panic("kalloc");
    80001dc8:	00006517          	auipc	a0,0x6
    80001dcc:	5d850513          	addi	a0,a0,1496 # 800083a0 <__func__.1+0x398>
    80001dd0:	ffffe097          	auipc	ra,0xffffe
    80001dd4:	790080e7          	jalr	1936(ra) # 80000560 <panic>

0000000080001dd8 <procinit>:
{
    80001dd8:	7139                	addi	sp,sp,-64
    80001dda:	fc06                	sd	ra,56(sp)
    80001ddc:	f822                	sd	s0,48(sp)
    80001dde:	f426                	sd	s1,40(sp)
    80001de0:	f04a                	sd	s2,32(sp)
    80001de2:	ec4e                	sd	s3,24(sp)
    80001de4:	e852                	sd	s4,16(sp)
    80001de6:	e456                	sd	s5,8(sp)
    80001de8:	e05a                	sd	s6,0(sp)
    80001dea:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001dec:	00006597          	auipc	a1,0x6
    80001df0:	5bc58593          	addi	a1,a1,1468 # 800083a8 <__func__.1+0x3a0>
    80001df4:	00092517          	auipc	a0,0x92
    80001df8:	08c50513          	addi	a0,a0,140 # 80093e80 <pid_lock>
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	e7e080e7          	jalr	-386(ra) # 80000c7a <initlock>
    initlock(&wait_lock, "wait_lock");
    80001e04:	00006597          	auipc	a1,0x6
    80001e08:	5ac58593          	addi	a1,a1,1452 # 800083b0 <__func__.1+0x3a8>
    80001e0c:	00092517          	auipc	a0,0x92
    80001e10:	08c50513          	addi	a0,a0,140 # 80093e98 <wait_lock>
    80001e14:	fffff097          	auipc	ra,0xfffff
    80001e18:	e66080e7          	jalr	-410(ra) # 80000c7a <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001e1c:	00092497          	auipc	s1,0x92
    80001e20:	09448493          	addi	s1,s1,148 # 80093eb0 <proc>
        initlock(&p->lock, "proc");
    80001e24:	00006b17          	auipc	s6,0x6
    80001e28:	59cb0b13          	addi	s6,s6,1436 # 800083c0 <__func__.1+0x3b8>
        p->kstack = KSTACK((int)(p - proc));
    80001e2c:	8aa6                	mv	s5,s1
    80001e2e:	04fa5937          	lui	s2,0x4fa5
    80001e32:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001e36:	0932                	slli	s2,s2,0xc
    80001e38:	fa590913          	addi	s2,s2,-91
    80001e3c:	0932                	slli	s2,s2,0xc
    80001e3e:	fa590913          	addi	s2,s2,-91
    80001e42:	0932                	slli	s2,s2,0xc
    80001e44:	fa590913          	addi	s2,s2,-91
    80001e48:	040009b7          	lui	s3,0x4000
    80001e4c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001e4e:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001e50:	00098a17          	auipc	s4,0x98
    80001e54:	a60a0a13          	addi	s4,s4,-1440 # 800998b0 <tickslock>
        initlock(&p->lock, "proc");
    80001e58:	85da                	mv	a1,s6
    80001e5a:	8526                	mv	a0,s1
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	e1e080e7          	jalr	-482(ra) # 80000c7a <initlock>
        p->state = UNUSED;
    80001e64:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001e68:	415487b3          	sub	a5,s1,s5
    80001e6c:	878d                	srai	a5,a5,0x3
    80001e6e:	032787b3          	mul	a5,a5,s2
    80001e72:	2785                	addiw	a5,a5,1
    80001e74:	00d7979b          	slliw	a5,a5,0xd
    80001e78:	40f987b3          	sub	a5,s3,a5
    80001e7c:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001e7e:	16848493          	addi	s1,s1,360
    80001e82:	fd449be3          	bne	s1,s4,80001e58 <procinit+0x80>
}
    80001e86:	70e2                	ld	ra,56(sp)
    80001e88:	7442                	ld	s0,48(sp)
    80001e8a:	74a2                	ld	s1,40(sp)
    80001e8c:	7902                	ld	s2,32(sp)
    80001e8e:	69e2                	ld	s3,24(sp)
    80001e90:	6a42                	ld	s4,16(sp)
    80001e92:	6aa2                	ld	s5,8(sp)
    80001e94:	6b02                	ld	s6,0(sp)
    80001e96:	6121                	addi	sp,sp,64
    80001e98:	8082                	ret

0000000080001e9a <copy_array>:
{
    80001e9a:	1141                	addi	sp,sp,-16
    80001e9c:	e422                	sd	s0,8(sp)
    80001e9e:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001ea0:	00c05c63          	blez	a2,80001eb8 <copy_array+0x1e>
    80001ea4:	87aa                	mv	a5,a0
    80001ea6:	9532                	add	a0,a0,a2
        dst[i] = src[i];
    80001ea8:	0007c703          	lbu	a4,0(a5)
    80001eac:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001eb0:	0785                	addi	a5,a5,1
    80001eb2:	0585                	addi	a1,a1,1
    80001eb4:	fea79ae3          	bne	a5,a0,80001ea8 <copy_array+0xe>
}
    80001eb8:	6422                	ld	s0,8(sp)
    80001eba:	0141                	addi	sp,sp,16
    80001ebc:	8082                	ret

0000000080001ebe <va2pa>:
uint64 va2pa(uint64 va, uint64 pid){
    80001ebe:	7139                	addi	sp,sp,-64
    80001ec0:	fc06                	sd	ra,56(sp)
    80001ec2:	f822                	sd	s0,48(sp)
    80001ec4:	f426                	sd	s1,40(sp)
    80001ec6:	f04a                	sd	s2,32(sp)
    80001ec8:	ec4e                	sd	s3,24(sp)
    80001eca:	e852                	sd	s4,16(sp)
    80001ecc:	e456                	sd	s5,8(sp)
    80001ece:	0080                	addi	s0,sp,64
    80001ed0:	8aaa                	mv	s5,a0
    80001ed2:	892e                	mv	s2,a1
    uint64 pa = 0;
    80001ed4:	4a01                	li	s4,0
    for (p = proc; p < &proc[NPROC]; p++){
    80001ed6:	00092497          	auipc	s1,0x92
    80001eda:	fda48493          	addi	s1,s1,-38 # 80093eb0 <proc>
    80001ede:	00098997          	auipc	s3,0x98
    80001ee2:	9d298993          	addi	s3,s3,-1582 # 800998b0 <tickslock>
    80001ee6:	a811                	j	80001efa <va2pa+0x3c>
        release(&p->lock);
    80001ee8:	8526                	mv	a0,s1
    80001eea:	fffff097          	auipc	ra,0xfffff
    80001eee:	ed4080e7          	jalr	-300(ra) # 80000dbe <release>
    for (p = proc; p < &proc[NPROC]; p++){
    80001ef2:	16848493          	addi	s1,s1,360
    80001ef6:	03348263          	beq	s1,s3,80001f1a <va2pa+0x5c>
        acquire(&p->lock);
    80001efa:	8526                	mv	a0,s1
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	e0e080e7          	jalr	-498(ra) # 80000d0a <acquire>
        if (pid == (uint64) p->pid){
    80001f04:	589c                	lw	a5,48(s1)
    80001f06:	ff2791e3          	bne	a5,s2,80001ee8 <va2pa+0x2a>
            pa = walkaddr(pt, va);     
    80001f0a:	85d6                	mv	a1,s5
    80001f0c:	68a8                	ld	a0,80(s1)
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	282080e7          	jalr	642(ra) # 80001190 <walkaddr>
    80001f16:	8a2a                	mv	s4,a0
    80001f18:	bfc1                	j	80001ee8 <va2pa+0x2a>
}
    80001f1a:	8552                	mv	a0,s4
    80001f1c:	70e2                	ld	ra,56(sp)
    80001f1e:	7442                	ld	s0,48(sp)
    80001f20:	74a2                	ld	s1,40(sp)
    80001f22:	7902                	ld	s2,32(sp)
    80001f24:	69e2                	ld	s3,24(sp)
    80001f26:	6a42                	ld	s4,16(sp)
    80001f28:	6aa2                	ld	s5,8(sp)
    80001f2a:	6121                	addi	sp,sp,64
    80001f2c:	8082                	ret

0000000080001f2e <free_pte>:
void free_pte(pte_t *pte){
    80001f2e:	7179                	addi	sp,sp,-48
    80001f30:	f406                	sd	ra,40(sp)
    80001f32:	f022                	sd	s0,32(sp)
    80001f34:	ec26                	sd	s1,24(sp)
    80001f36:	e84a                	sd	s2,16(sp)
    80001f38:	e44e                	sd	s3,8(sp)
    80001f3a:	e052                	sd	s4,0(sp)
    80001f3c:	1800                	addi	s0,sp,48
    uint64 pa = PTE2PA(*pte);
    80001f3e:	00053983          	ld	s3,0(a0)
    80001f42:	00a9d993          	srli	s3,s3,0xa
    80001f46:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++){
    80001f48:	00092497          	auipc	s1,0x92
    80001f4c:	f6848493          	addi	s1,s1,-152 # 80093eb0 <proc>
    80001f50:	00098a17          	auipc	s4,0x98
    80001f54:	960a0a13          	addi	s4,s4,-1696 # 800998b0 <tickslock>
    80001f58:	a029                	j	80001f62 <free_pte+0x34>
    80001f5a:	16848493          	addi	s1,s1,360
    80001f5e:	03448363          	beq	s1,s4,80001f84 <free_pte+0x56>
        pagetable_t pt = p->pagetable;
    80001f62:	0504b903          	ld	s2,80(s1)
        uint64 va = uvmfind(pt, pa);
    80001f66:	85ce                	mv	a1,s3
    80001f68:	854a                	mv	a0,s2
    80001f6a:	fffff097          	auipc	ra,0xfffff
    80001f6e:	5de080e7          	jalr	1502(ra) # 80001548 <uvmfind>
        if (va != 0){
    80001f72:	d565                	beqz	a0,80001f5a <free_pte+0x2c>
            uvmunmap(pt, va, 1);
    80001f74:	4605                	li	a2,1
    80001f76:	85aa                	mv	a1,a0
    80001f78:	854a                	mv	a0,s2
    80001f7a:	fffff097          	auipc	ra,0xfffff
    80001f7e:	62c080e7          	jalr	1580(ra) # 800015a6 <uvmunmap>
    80001f82:	bfe1                	j	80001f5a <free_pte+0x2c>
}
    80001f84:	70a2                	ld	ra,40(sp)
    80001f86:	7402                	ld	s0,32(sp)
    80001f88:	64e2                	ld	s1,24(sp)
    80001f8a:	6942                	ld	s2,16(sp)
    80001f8c:	69a2                	ld	s3,8(sp)
    80001f8e:	6a02                	ld	s4,0(sp)
    80001f90:	6145                	addi	sp,sp,48
    80001f92:	8082                	ret

0000000080001f94 <cpuid>:
{
    80001f94:	1141                	addi	sp,sp,-16
    80001f96:	e422                	sd	s0,8(sp)
    80001f98:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    80001f9a:	8512                	mv	a0,tp
}
    80001f9c:	2501                	sext.w	a0,a0
    80001f9e:	6422                	ld	s0,8(sp)
    80001fa0:	0141                	addi	sp,sp,16
    80001fa2:	8082                	ret

0000000080001fa4 <mycpu>:
{
    80001fa4:	1141                	addi	sp,sp,-16
    80001fa6:	e422                	sd	s0,8(sp)
    80001fa8:	0800                	addi	s0,sp,16
    80001faa:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001fac:	2781                	sext.w	a5,a5
    80001fae:	079e                	slli	a5,a5,0x7
}
    80001fb0:	00092517          	auipc	a0,0x92
    80001fb4:	ad050513          	addi	a0,a0,-1328 # 80093a80 <cpus>
    80001fb8:	953e                	add	a0,a0,a5
    80001fba:	6422                	ld	s0,8(sp)
    80001fbc:	0141                	addi	sp,sp,16
    80001fbe:	8082                	ret

0000000080001fc0 <myproc>:
{
    80001fc0:	1101                	addi	sp,sp,-32
    80001fc2:	ec06                	sd	ra,24(sp)
    80001fc4:	e822                	sd	s0,16(sp)
    80001fc6:	e426                	sd	s1,8(sp)
    80001fc8:	1000                	addi	s0,sp,32
    push_off();
    80001fca:	fffff097          	auipc	ra,0xfffff
    80001fce:	cf4080e7          	jalr	-780(ra) # 80000cbe <push_off>
    80001fd2:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001fd4:	2781                	sext.w	a5,a5
    80001fd6:	079e                	slli	a5,a5,0x7
    80001fd8:	00092717          	auipc	a4,0x92
    80001fdc:	aa870713          	addi	a4,a4,-1368 # 80093a80 <cpus>
    80001fe0:	97ba                	add	a5,a5,a4
    80001fe2:	6384                	ld	s1,0(a5)
    pop_off();
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	d7a080e7          	jalr	-646(ra) # 80000d5e <pop_off>
}
    80001fec:	8526                	mv	a0,s1
    80001fee:	60e2                	ld	ra,24(sp)
    80001ff0:	6442                	ld	s0,16(sp)
    80001ff2:	64a2                	ld	s1,8(sp)
    80001ff4:	6105                	addi	sp,sp,32
    80001ff6:	8082                	ret

0000000080001ff8 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001ff8:	1141                	addi	sp,sp,-16
    80001ffa:	e406                	sd	ra,8(sp)
    80001ffc:	e022                	sd	s0,0(sp)
    80001ffe:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80002000:	00000097          	auipc	ra,0x0
    80002004:	fc0080e7          	jalr	-64(ra) # 80001fc0 <myproc>
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	db6080e7          	jalr	-586(ra) # 80000dbe <release>

    if (first)
    80002010:	00009797          	auipc	a5,0x9
    80002014:	7207a783          	lw	a5,1824(a5) # 8000b730 <first.1>
    80002018:	eb89                	bnez	a5,8000202a <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    8000201a:	00001097          	auipc	ra,0x1
    8000201e:	e38080e7          	jalr	-456(ra) # 80002e52 <usertrapret>
}
    80002022:	60a2                	ld	ra,8(sp)
    80002024:	6402                	ld	s0,0(sp)
    80002026:	0141                	addi	sp,sp,16
    80002028:	8082                	ret
        first = 0;
    8000202a:	00009797          	auipc	a5,0x9
    8000202e:	7007a323          	sw	zero,1798(a5) # 8000b730 <first.1>
        fsinit(ROOTDEV);
    80002032:	4505                	li	a0,1
    80002034:	00002097          	auipc	ra,0x2
    80002038:	cb4080e7          	jalr	-844(ra) # 80003ce8 <fsinit>
    8000203c:	bff9                	j	8000201a <forkret+0x22>

000000008000203e <allocpid>:
{
    8000203e:	1101                	addi	sp,sp,-32
    80002040:	ec06                	sd	ra,24(sp)
    80002042:	e822                	sd	s0,16(sp)
    80002044:	e426                	sd	s1,8(sp)
    80002046:	e04a                	sd	s2,0(sp)
    80002048:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    8000204a:	00092917          	auipc	s2,0x92
    8000204e:	e3690913          	addi	s2,s2,-458 # 80093e80 <pid_lock>
    80002052:	854a                	mv	a0,s2
    80002054:	fffff097          	auipc	ra,0xfffff
    80002058:	cb6080e7          	jalr	-842(ra) # 80000d0a <acquire>
    pid = nextpid;
    8000205c:	00009797          	auipc	a5,0x9
    80002060:	6e478793          	addi	a5,a5,1764 # 8000b740 <nextpid>
    80002064:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80002066:	0014871b          	addiw	a4,s1,1
    8000206a:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    8000206c:	854a                	mv	a0,s2
    8000206e:	fffff097          	auipc	ra,0xfffff
    80002072:	d50080e7          	jalr	-688(ra) # 80000dbe <release>
}
    80002076:	8526                	mv	a0,s1
    80002078:	60e2                	ld	ra,24(sp)
    8000207a:	6442                	ld	s0,16(sp)
    8000207c:	64a2                	ld	s1,8(sp)
    8000207e:	6902                	ld	s2,0(sp)
    80002080:	6105                	addi	sp,sp,32
    80002082:	8082                	ret

0000000080002084 <proc_pagetable>:
{
    80002084:	1101                	addi	sp,sp,-32
    80002086:	ec06                	sd	ra,24(sp)
    80002088:	e822                	sd	s0,16(sp)
    8000208a:	e426                	sd	s1,8(sp)
    8000208c:	e04a                	sd	s2,0(sp)
    8000208e:	1000                	addi	s0,sp,32
    80002090:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80002092:	fffff097          	auipc	ra,0xfffff
    80002096:	5d8080e7          	jalr	1496(ra) # 8000166a <uvmcreate>
    8000209a:	84aa                	mv	s1,a0
    if (pagetable == 0)
    8000209c:	c121                	beqz	a0,800020dc <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000209e:	4729                	li	a4,10
    800020a0:	00005697          	auipc	a3,0x5
    800020a4:	f6068693          	addi	a3,a3,-160 # 80007000 <_trampoline>
    800020a8:	6605                	lui	a2,0x1
    800020aa:	040005b7          	lui	a1,0x4000
    800020ae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800020b0:	05b2                	slli	a1,a1,0xc
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	244080e7          	jalr	580(ra) # 800012f6 <mappages>
    800020ba:	02054863          	bltz	a0,800020ea <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    800020be:	4719                	li	a4,6
    800020c0:	05893683          	ld	a3,88(s2)
    800020c4:	6605                	lui	a2,0x1
    800020c6:	020005b7          	lui	a1,0x2000
    800020ca:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800020cc:	05b6                	slli	a1,a1,0xd
    800020ce:	8526                	mv	a0,s1
    800020d0:	fffff097          	auipc	ra,0xfffff
    800020d4:	226080e7          	jalr	550(ra) # 800012f6 <mappages>
    800020d8:	02054163          	bltz	a0,800020fa <proc_pagetable+0x76>
}
    800020dc:	8526                	mv	a0,s1
    800020de:	60e2                	ld	ra,24(sp)
    800020e0:	6442                	ld	s0,16(sp)
    800020e2:	64a2                	ld	s1,8(sp)
    800020e4:	6902                	ld	s2,0(sp)
    800020e6:	6105                	addi	sp,sp,32
    800020e8:	8082                	ret
        uvmfree(pagetable, 0);
    800020ea:	4581                	li	a1,0
    800020ec:	8526                	mv	a0,s1
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	78c080e7          	jalr	1932(ra) # 8000187a <uvmfree>
        return 0;
    800020f6:	4481                	li	s1,0
    800020f8:	b7d5                	j	800020dc <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1);
    800020fa:	4605                	li	a2,1
    800020fc:	040005b7          	lui	a1,0x4000
    80002100:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002102:	05b2                	slli	a1,a1,0xc
    80002104:	8526                	mv	a0,s1
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	4a0080e7          	jalr	1184(ra) # 800015a6 <uvmunmap>
        uvmfree(pagetable, 0);
    8000210e:	4581                	li	a1,0
    80002110:	8526                	mv	a0,s1
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	768080e7          	jalr	1896(ra) # 8000187a <uvmfree>
        return 0;
    8000211a:	4481                	li	s1,0
    8000211c:	b7c1                	j	800020dc <proc_pagetable+0x58>

000000008000211e <proc_freepagetable>:
{
    8000211e:	1101                	addi	sp,sp,-32
    80002120:	ec06                	sd	ra,24(sp)
    80002122:	e822                	sd	s0,16(sp)
    80002124:	e426                	sd	s1,8(sp)
    80002126:	e04a                	sd	s2,0(sp)
    80002128:	1000                	addi	s0,sp,32
    8000212a:	84aa                	mv	s1,a0
    8000212c:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1);
    8000212e:	4605                	li	a2,1
    80002130:	040005b7          	lui	a1,0x4000
    80002134:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002136:	05b2                	slli	a1,a1,0xc
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	46e080e7          	jalr	1134(ra) # 800015a6 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1);
    80002140:	4605                	li	a2,1
    80002142:	020005b7          	lui	a1,0x2000
    80002146:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80002148:	05b6                	slli	a1,a1,0xd
    8000214a:	8526                	mv	a0,s1
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	45a080e7          	jalr	1114(ra) # 800015a6 <uvmunmap>
    uvmfree(pagetable, sz);
    80002154:	85ca                	mv	a1,s2
    80002156:	8526                	mv	a0,s1
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	722080e7          	jalr	1826(ra) # 8000187a <uvmfree>
}
    80002160:	60e2                	ld	ra,24(sp)
    80002162:	6442                	ld	s0,16(sp)
    80002164:	64a2                	ld	s1,8(sp)
    80002166:	6902                	ld	s2,0(sp)
    80002168:	6105                	addi	sp,sp,32
    8000216a:	8082                	ret

000000008000216c <freeproc>:
{
    8000216c:	1101                	addi	sp,sp,-32
    8000216e:	ec06                	sd	ra,24(sp)
    80002170:	e822                	sd	s0,16(sp)
    80002172:	e426                	sd	s1,8(sp)
    80002174:	1000                	addi	s0,sp,32
    80002176:	84aa                	mv	s1,a0
    if (p->trapframe)
    80002178:	6d28                	ld	a0,88(a0)
    8000217a:	c509                	beqz	a0,80002184 <freeproc+0x18>
        kfree((void *)p->trapframe);
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	8e0080e7          	jalr	-1824(ra) # 80000a5c <kfree>
    p->trapframe = 0;
    80002184:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80002188:	68a8                	ld	a0,80(s1)
    8000218a:	c511                	beqz	a0,80002196 <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    8000218c:	64ac                	ld	a1,72(s1)
    8000218e:	00000097          	auipc	ra,0x0
    80002192:	f90080e7          	jalr	-112(ra) # 8000211e <proc_freepagetable>
    p->pagetable = 0;
    80002196:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    8000219a:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    8000219e:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    800021a2:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    800021a6:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    800021aa:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    800021ae:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    800021b2:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    800021b6:	0004ac23          	sw	zero,24(s1)
}
    800021ba:	60e2                	ld	ra,24(sp)
    800021bc:	6442                	ld	s0,16(sp)
    800021be:	64a2                	ld	s1,8(sp)
    800021c0:	6105                	addi	sp,sp,32
    800021c2:	8082                	ret

00000000800021c4 <allocproc>:
{
    800021c4:	1101                	addi	sp,sp,-32
    800021c6:	ec06                	sd	ra,24(sp)
    800021c8:	e822                	sd	s0,16(sp)
    800021ca:	e426                	sd	s1,8(sp)
    800021cc:	e04a                	sd	s2,0(sp)
    800021ce:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    800021d0:	00092497          	auipc	s1,0x92
    800021d4:	ce048493          	addi	s1,s1,-800 # 80093eb0 <proc>
    800021d8:	00097917          	auipc	s2,0x97
    800021dc:	6d890913          	addi	s2,s2,1752 # 800998b0 <tickslock>
        acquire(&p->lock);
    800021e0:	8526                	mv	a0,s1
    800021e2:	fffff097          	auipc	ra,0xfffff
    800021e6:	b28080e7          	jalr	-1240(ra) # 80000d0a <acquire>
        if (p->state == UNUSED)
    800021ea:	4c9c                	lw	a5,24(s1)
    800021ec:	cf81                	beqz	a5,80002204 <allocproc+0x40>
            release(&p->lock);
    800021ee:	8526                	mv	a0,s1
    800021f0:	fffff097          	auipc	ra,0xfffff
    800021f4:	bce080e7          	jalr	-1074(ra) # 80000dbe <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800021f8:	16848493          	addi	s1,s1,360
    800021fc:	ff2492e3          	bne	s1,s2,800021e0 <allocproc+0x1c>
    return 0;
    80002200:	4481                	li	s1,0
    80002202:	a889                	j	80002254 <allocproc+0x90>
    p->pid = allocpid();
    80002204:	00000097          	auipc	ra,0x0
    80002208:	e3a080e7          	jalr	-454(ra) # 8000203e <allocpid>
    8000220c:	d888                	sw	a0,48(s1)
    p->state = USED;
    8000220e:	4785                	li	a5,1
    80002210:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	9b2080e7          	jalr	-1614(ra) # 80000bc4 <kalloc>
    8000221a:	892a                	mv	s2,a0
    8000221c:	eca8                	sd	a0,88(s1)
    8000221e:	c131                	beqz	a0,80002262 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80002220:	8526                	mv	a0,s1
    80002222:	00000097          	auipc	ra,0x0
    80002226:	e62080e7          	jalr	-414(ra) # 80002084 <proc_pagetable>
    8000222a:	892a                	mv	s2,a0
    8000222c:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    8000222e:	c531                	beqz	a0,8000227a <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80002230:	07000613          	li	a2,112
    80002234:	4581                	li	a1,0
    80002236:	06048513          	addi	a0,s1,96
    8000223a:	fffff097          	auipc	ra,0xfffff
    8000223e:	bcc080e7          	jalr	-1076(ra) # 80000e06 <memset>
    p->context.ra = (uint64)forkret;
    80002242:	00000797          	auipc	a5,0x0
    80002246:	db678793          	addi	a5,a5,-586 # 80001ff8 <forkret>
    8000224a:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    8000224c:	60bc                	ld	a5,64(s1)
    8000224e:	6705                	lui	a4,0x1
    80002250:	97ba                	add	a5,a5,a4
    80002252:	f4bc                	sd	a5,104(s1)
}
    80002254:	8526                	mv	a0,s1
    80002256:	60e2                	ld	ra,24(sp)
    80002258:	6442                	ld	s0,16(sp)
    8000225a:	64a2                	ld	s1,8(sp)
    8000225c:	6902                	ld	s2,0(sp)
    8000225e:	6105                	addi	sp,sp,32
    80002260:	8082                	ret
        freeproc(p);
    80002262:	8526                	mv	a0,s1
    80002264:	00000097          	auipc	ra,0x0
    80002268:	f08080e7          	jalr	-248(ra) # 8000216c <freeproc>
        release(&p->lock);
    8000226c:	8526                	mv	a0,s1
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	b50080e7          	jalr	-1200(ra) # 80000dbe <release>
        return 0;
    80002276:	84ca                	mv	s1,s2
    80002278:	bff1                	j	80002254 <allocproc+0x90>
        freeproc(p);
    8000227a:	8526                	mv	a0,s1
    8000227c:	00000097          	auipc	ra,0x0
    80002280:	ef0080e7          	jalr	-272(ra) # 8000216c <freeproc>
        release(&p->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	b38080e7          	jalr	-1224(ra) # 80000dbe <release>
        return 0;
    8000228e:	84ca                	mv	s1,s2
    80002290:	b7d1                	j	80002254 <allocproc+0x90>

0000000080002292 <userinit>:
{
    80002292:	1101                	addi	sp,sp,-32
    80002294:	ec06                	sd	ra,24(sp)
    80002296:	e822                	sd	s0,16(sp)
    80002298:	e426                	sd	s1,8(sp)
    8000229a:	1000                	addi	s0,sp,32
    p = allocproc();
    8000229c:	00000097          	auipc	ra,0x0
    800022a0:	f28080e7          	jalr	-216(ra) # 800021c4 <allocproc>
    800022a4:	84aa                	mv	s1,a0
    initproc = p;
    800022a6:	00009797          	auipc	a5,0x9
    800022aa:	56a7b123          	sd	a0,1378(a5) # 8000b808 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800022ae:	03400613          	li	a2,52
    800022b2:	00009597          	auipc	a1,0x9
    800022b6:	49e58593          	addi	a1,a1,1182 # 8000b750 <initcode>
    800022ba:	6928                	ld	a0,80(a0)
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	3dc080e7          	jalr	988(ra) # 80001698 <uvmfirst>
    p->sz = PGSIZE;
    800022c4:	6785                	lui	a5,0x1
    800022c6:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    800022c8:	6cb8                	ld	a4,88(s1)
    800022ca:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    800022ce:	6cb8                	ld	a4,88(s1)
    800022d0:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    800022d2:	4641                	li	a2,16
    800022d4:	00006597          	auipc	a1,0x6
    800022d8:	0f458593          	addi	a1,a1,244 # 800083c8 <__func__.1+0x3c0>
    800022dc:	15848513          	addi	a0,s1,344
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	c68080e7          	jalr	-920(ra) # 80000f48 <safestrcpy>
    p->cwd = namei("/");
    800022e8:	00006517          	auipc	a0,0x6
    800022ec:	0f050513          	addi	a0,a0,240 # 800083d8 <__func__.1+0x3d0>
    800022f0:	00002097          	auipc	ra,0x2
    800022f4:	44a080e7          	jalr	1098(ra) # 8000473a <namei>
    800022f8:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    800022fc:	478d                	li	a5,3
    800022fe:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80002300:	8526                	mv	a0,s1
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	abc080e7          	jalr	-1348(ra) # 80000dbe <release>
}
    8000230a:	60e2                	ld	ra,24(sp)
    8000230c:	6442                	ld	s0,16(sp)
    8000230e:	64a2                	ld	s1,8(sp)
    80002310:	6105                	addi	sp,sp,32
    80002312:	8082                	ret

0000000080002314 <growproc>:
{
    80002314:	1101                	addi	sp,sp,-32
    80002316:	ec06                	sd	ra,24(sp)
    80002318:	e822                	sd	s0,16(sp)
    8000231a:	e426                	sd	s1,8(sp)
    8000231c:	e04a                	sd	s2,0(sp)
    8000231e:	1000                	addi	s0,sp,32
    80002320:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80002322:	00000097          	auipc	ra,0x0
    80002326:	c9e080e7          	jalr	-866(ra) # 80001fc0 <myproc>
    8000232a:	84aa                	mv	s1,a0
    sz = p->sz;
    8000232c:	652c                	ld	a1,72(a0)
    if (n > 0)
    8000232e:	01204c63          	bgtz	s2,80002346 <growproc+0x32>
    else if (n < 0)
    80002332:	02094663          	bltz	s2,8000235e <growproc+0x4a>
    p->sz = sz;
    80002336:	e4ac                	sd	a1,72(s1)
    return 0;
    80002338:	4501                	li	a0,0
}
    8000233a:	60e2                	ld	ra,24(sp)
    8000233c:	6442                	ld	s0,16(sp)
    8000233e:	64a2                	ld	s1,8(sp)
    80002340:	6902                	ld	s2,0(sp)
    80002342:	6105                	addi	sp,sp,32
    80002344:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80002346:	4691                	li	a3,4
    80002348:	00b90633          	add	a2,s2,a1
    8000234c:	6928                	ld	a0,80(a0)
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	402080e7          	jalr	1026(ra) # 80001750 <uvmalloc>
    80002356:	85aa                	mv	a1,a0
    80002358:	fd79                	bnez	a0,80002336 <growproc+0x22>
            return -1;
    8000235a:	557d                	li	a0,-1
    8000235c:	bff9                	j	8000233a <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000235e:	00b90633          	add	a2,s2,a1
    80002362:	6928                	ld	a0,80(a0)
    80002364:	fffff097          	auipc	ra,0xfffff
    80002368:	3a6080e7          	jalr	934(ra) # 8000170a <uvmdealloc>
    8000236c:	85aa                	mv	a1,a0
    8000236e:	b7e1                	j	80002336 <growproc+0x22>

0000000080002370 <ps>:
{
    80002370:	715d                	addi	sp,sp,-80
    80002372:	e486                	sd	ra,72(sp)
    80002374:	e0a2                	sd	s0,64(sp)
    80002376:	fc26                	sd	s1,56(sp)
    80002378:	f84a                	sd	s2,48(sp)
    8000237a:	f44e                	sd	s3,40(sp)
    8000237c:	f052                	sd	s4,32(sp)
    8000237e:	ec56                	sd	s5,24(sp)
    80002380:	e85a                	sd	s6,16(sp)
    80002382:	e45e                	sd	s7,8(sp)
    80002384:	e062                	sd	s8,0(sp)
    80002386:	0880                	addi	s0,sp,80
    80002388:	84aa                	mv	s1,a0
    8000238a:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    8000238c:	00000097          	auipc	ra,0x0
    80002390:	c34080e7          	jalr	-972(ra) # 80001fc0 <myproc>
        return result;
    80002394:	4901                	li	s2,0
    if (count == 0)
    80002396:	0c0b8663          	beqz	s7,80002462 <ps+0xf2>
    void *result = (void *)myproc()->sz;
    8000239a:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    8000239e:	003b951b          	slliw	a0,s7,0x3
    800023a2:	0175053b          	addw	a0,a0,s7
    800023a6:	0025151b          	slliw	a0,a0,0x2
    800023aa:	2501                	sext.w	a0,a0
    800023ac:	00000097          	auipc	ra,0x0
    800023b0:	f68080e7          	jalr	-152(ra) # 80002314 <growproc>
    800023b4:	12054f63          	bltz	a0,800024f2 <ps+0x182>
    struct user_proc loc_result[count];
    800023b8:	003b9a13          	slli	s4,s7,0x3
    800023bc:	9a5e                	add	s4,s4,s7
    800023be:	0a0a                	slli	s4,s4,0x2
    800023c0:	00fa0793          	addi	a5,s4,15
    800023c4:	8391                	srli	a5,a5,0x4
    800023c6:	0792                	slli	a5,a5,0x4
    800023c8:	40f10133          	sub	sp,sp,a5
    800023cc:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    800023ce:	16800793          	li	a5,360
    800023d2:	02f484b3          	mul	s1,s1,a5
    800023d6:	00092797          	auipc	a5,0x92
    800023da:	ada78793          	addi	a5,a5,-1318 # 80093eb0 <proc>
    800023de:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    800023e0:	00097797          	auipc	a5,0x97
    800023e4:	4d078793          	addi	a5,a5,1232 # 800998b0 <tickslock>
        return result;
    800023e8:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    800023ea:	06f4fc63          	bgeu	s1,a5,80002462 <ps+0xf2>
    acquire(&wait_lock);
    800023ee:	00092517          	auipc	a0,0x92
    800023f2:	aaa50513          	addi	a0,a0,-1366 # 80093e98 <wait_lock>
    800023f6:	fffff097          	auipc	ra,0xfffff
    800023fa:	914080e7          	jalr	-1772(ra) # 80000d0a <acquire>
        if (localCount == count)
    800023fe:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    80002402:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80002404:	00097c17          	auipc	s8,0x97
    80002408:	4acc0c13          	addi	s8,s8,1196 # 800998b0 <tickslock>
    8000240c:	a851                	j	800024a0 <ps+0x130>
            loc_result[localCount].state = UNUSED;
    8000240e:	00399793          	slli	a5,s3,0x3
    80002412:	97ce                	add	a5,a5,s3
    80002414:	078a                	slli	a5,a5,0x2
    80002416:	97d6                	add	a5,a5,s5
    80002418:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    8000241c:	8526                	mv	a0,s1
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	9a0080e7          	jalr	-1632(ra) # 80000dbe <release>
    release(&wait_lock);
    80002426:	00092517          	auipc	a0,0x92
    8000242a:	a7250513          	addi	a0,a0,-1422 # 80093e98 <wait_lock>
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	990080e7          	jalr	-1648(ra) # 80000dbe <release>
    if (localCount < count)
    80002436:	0179f963          	bgeu	s3,s7,80002448 <ps+0xd8>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    8000243a:	00399793          	slli	a5,s3,0x3
    8000243e:	97ce                	add	a5,a5,s3
    80002440:	078a                	slli	a5,a5,0x2
    80002442:	97d6                	add	a5,a5,s5
    80002444:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    80002448:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    8000244a:	00000097          	auipc	ra,0x0
    8000244e:	b76080e7          	jalr	-1162(ra) # 80001fc0 <myproc>
    80002452:	86d2                	mv	a3,s4
    80002454:	8656                	mv	a2,s5
    80002456:	85da                	mv	a1,s6
    80002458:	6928                	ld	a0,80(a0)
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	634080e7          	jalr	1588(ra) # 80001a8e <copyout>
}
    80002462:	854a                	mv	a0,s2
    80002464:	fb040113          	addi	sp,s0,-80
    80002468:	60a6                	ld	ra,72(sp)
    8000246a:	6406                	ld	s0,64(sp)
    8000246c:	74e2                	ld	s1,56(sp)
    8000246e:	7942                	ld	s2,48(sp)
    80002470:	79a2                	ld	s3,40(sp)
    80002472:	7a02                	ld	s4,32(sp)
    80002474:	6ae2                	ld	s5,24(sp)
    80002476:	6b42                	ld	s6,16(sp)
    80002478:	6ba2                	ld	s7,8(sp)
    8000247a:	6c02                	ld	s8,0(sp)
    8000247c:	6161                	addi	sp,sp,80
    8000247e:	8082                	ret
        release(&p->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	fffff097          	auipc	ra,0xfffff
    80002486:	93c080e7          	jalr	-1732(ra) # 80000dbe <release>
        localCount++;
    8000248a:	2985                	addiw	s3,s3,1
    8000248c:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    80002490:	16848493          	addi	s1,s1,360
    80002494:	f984f9e3          	bgeu	s1,s8,80002426 <ps+0xb6>
        if (localCount == count)
    80002498:	02490913          	addi	s2,s2,36
    8000249c:	053b8d63          	beq	s7,s3,800024f6 <ps+0x186>
        acquire(&p->lock);
    800024a0:	8526                	mv	a0,s1
    800024a2:	fffff097          	auipc	ra,0xfffff
    800024a6:	868080e7          	jalr	-1944(ra) # 80000d0a <acquire>
        if (p->state == UNUSED)
    800024aa:	4c9c                	lw	a5,24(s1)
    800024ac:	d3ad                	beqz	a5,8000240e <ps+0x9e>
        loc_result[localCount].state = p->state;
    800024ae:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    800024b2:	549c                	lw	a5,40(s1)
    800024b4:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    800024b8:	54dc                	lw	a5,44(s1)
    800024ba:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    800024be:	589c                	lw	a5,48(s1)
    800024c0:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    800024c4:	4641                	li	a2,16
    800024c6:	85ca                	mv	a1,s2
    800024c8:	15848513          	addi	a0,s1,344
    800024cc:	00000097          	auipc	ra,0x0
    800024d0:	9ce080e7          	jalr	-1586(ra) # 80001e9a <copy_array>
        if (p->parent != 0) // init
    800024d4:	7c88                	ld	a0,56(s1)
    800024d6:	d54d                	beqz	a0,80002480 <ps+0x110>
            acquire(&p->parent->lock);
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	832080e7          	jalr	-1998(ra) # 80000d0a <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    800024e0:	7c88                	ld	a0,56(s1)
    800024e2:	591c                	lw	a5,48(a0)
    800024e4:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    800024e8:	fffff097          	auipc	ra,0xfffff
    800024ec:	8d6080e7          	jalr	-1834(ra) # 80000dbe <release>
    800024f0:	bf41                	j	80002480 <ps+0x110>
        return result;
    800024f2:	4901                	li	s2,0
    800024f4:	b7bd                	j	80002462 <ps+0xf2>
    release(&wait_lock);
    800024f6:	00092517          	auipc	a0,0x92
    800024fa:	9a250513          	addi	a0,a0,-1630 # 80093e98 <wait_lock>
    800024fe:	fffff097          	auipc	ra,0xfffff
    80002502:	8c0080e7          	jalr	-1856(ra) # 80000dbe <release>
    if (localCount < count)
    80002506:	b789                	j	80002448 <ps+0xd8>

0000000080002508 <fork>:
{
    80002508:	7139                	addi	sp,sp,-64
    8000250a:	fc06                	sd	ra,56(sp)
    8000250c:	f822                	sd	s0,48(sp)
    8000250e:	f04a                	sd	s2,32(sp)
    80002510:	e456                	sd	s5,8(sp)
    80002512:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    80002514:	00000097          	auipc	ra,0x0
    80002518:	aac080e7          	jalr	-1364(ra) # 80001fc0 <myproc>
    8000251c:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    8000251e:	00000097          	auipc	ra,0x0
    80002522:	ca6080e7          	jalr	-858(ra) # 800021c4 <allocproc>
    80002526:	10050b63          	beqz	a0,8000263c <fork+0x134>
    8000252a:	e852                	sd	s4,16(sp)
    8000252c:	8a2a                	mv	s4,a0
    if (uvmremap(p->pagetable, np->pagetable, p->sz) < 0)
    8000252e:	048ab603          	ld	a2,72(s5)
    80002532:	692c                	ld	a1,80(a0)
    80002534:	050ab503          	ld	a0,80(s5)
    80002538:	fffff097          	auipc	ra,0xfffff
    8000253c:	44a080e7          	jalr	1098(ra) # 80001982 <uvmremap>
    80002540:	04054a63          	bltz	a0,80002594 <fork+0x8c>
    80002544:	f426                	sd	s1,40(sp)
    80002546:	ec4e                	sd	s3,24(sp)
    np->sz = p->sz;
    80002548:	048ab783          	ld	a5,72(s5)
    8000254c:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    80002550:	058ab683          	ld	a3,88(s5)
    80002554:	87b6                	mv	a5,a3
    80002556:	058a3703          	ld	a4,88(s4)
    8000255a:	12068693          	addi	a3,a3,288
    8000255e:	0007b803          	ld	a6,0(a5)
    80002562:	6788                	ld	a0,8(a5)
    80002564:	6b8c                	ld	a1,16(a5)
    80002566:	6f90                	ld	a2,24(a5)
    80002568:	01073023          	sd	a6,0(a4)
    8000256c:	e708                	sd	a0,8(a4)
    8000256e:	eb0c                	sd	a1,16(a4)
    80002570:	ef10                	sd	a2,24(a4)
    80002572:	02078793          	addi	a5,a5,32
    80002576:	02070713          	addi	a4,a4,32
    8000257a:	fed792e3          	bne	a5,a3,8000255e <fork+0x56>
    np->trapframe->a0 = 0;
    8000257e:	058a3783          	ld	a5,88(s4)
    80002582:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    80002586:	0d0a8493          	addi	s1,s5,208
    8000258a:	0d0a0913          	addi	s2,s4,208
    8000258e:	150a8993          	addi	s3,s5,336
    80002592:	a829                	j	800025ac <fork+0xa4>
        release(&np->lock);
    80002594:	8552                	mv	a0,s4
    80002596:	fffff097          	auipc	ra,0xfffff
    8000259a:	828080e7          	jalr	-2008(ra) # 80000dbe <release>
        return -1;
    8000259e:	597d                	li	s2,-1
    800025a0:	6a42                	ld	s4,16(sp)
    800025a2:	a071                	j	8000262e <fork+0x126>
    for (i = 0; i < NOFILE; i++)
    800025a4:	04a1                	addi	s1,s1,8
    800025a6:	0921                	addi	s2,s2,8
    800025a8:	01348b63          	beq	s1,s3,800025be <fork+0xb6>
        if (p->ofile[i])
    800025ac:	6088                	ld	a0,0(s1)
    800025ae:	d97d                	beqz	a0,800025a4 <fork+0x9c>
            np->ofile[i] = filedup(p->ofile[i]);
    800025b0:	00003097          	auipc	ra,0x3
    800025b4:	802080e7          	jalr	-2046(ra) # 80004db2 <filedup>
    800025b8:	00a93023          	sd	a0,0(s2)
    800025bc:	b7e5                	j	800025a4 <fork+0x9c>
    np->cwd = idup(p->cwd);
    800025be:	150ab503          	ld	a0,336(s5)
    800025c2:	00002097          	auipc	ra,0x2
    800025c6:	96c080e7          	jalr	-1684(ra) # 80003f2e <idup>
    800025ca:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    800025ce:	4641                	li	a2,16
    800025d0:	158a8593          	addi	a1,s5,344
    800025d4:	158a0513          	addi	a0,s4,344
    800025d8:	fffff097          	auipc	ra,0xfffff
    800025dc:	970080e7          	jalr	-1680(ra) # 80000f48 <safestrcpy>
    pid = np->pid;
    800025e0:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    800025e4:	8552                	mv	a0,s4
    800025e6:	ffffe097          	auipc	ra,0xffffe
    800025ea:	7d8080e7          	jalr	2008(ra) # 80000dbe <release>
    acquire(&wait_lock);
    800025ee:	00092497          	auipc	s1,0x92
    800025f2:	8aa48493          	addi	s1,s1,-1878 # 80093e98 <wait_lock>
    800025f6:	8526                	mv	a0,s1
    800025f8:	ffffe097          	auipc	ra,0xffffe
    800025fc:	712080e7          	jalr	1810(ra) # 80000d0a <acquire>
    np->parent = p;
    80002600:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    80002604:	8526                	mv	a0,s1
    80002606:	ffffe097          	auipc	ra,0xffffe
    8000260a:	7b8080e7          	jalr	1976(ra) # 80000dbe <release>
    acquire(&np->lock);
    8000260e:	8552                	mv	a0,s4
    80002610:	ffffe097          	auipc	ra,0xffffe
    80002614:	6fa080e7          	jalr	1786(ra) # 80000d0a <acquire>
    np->state = RUNNABLE;
    80002618:	478d                	li	a5,3
    8000261a:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    8000261e:	8552                	mv	a0,s4
    80002620:	ffffe097          	auipc	ra,0xffffe
    80002624:	79e080e7          	jalr	1950(ra) # 80000dbe <release>
    return pid;
    80002628:	74a2                	ld	s1,40(sp)
    8000262a:	69e2                	ld	s3,24(sp)
    8000262c:	6a42                	ld	s4,16(sp)
}
    8000262e:	854a                	mv	a0,s2
    80002630:	70e2                	ld	ra,56(sp)
    80002632:	7442                	ld	s0,48(sp)
    80002634:	7902                	ld	s2,32(sp)
    80002636:	6aa2                	ld	s5,8(sp)
    80002638:	6121                	addi	sp,sp,64
    8000263a:	8082                	ret
        return -1;
    8000263c:	597d                	li	s2,-1
    8000263e:	bfc5                	j	8000262e <fork+0x126>

0000000080002640 <scheduler>:
{
    80002640:	1101                	addi	sp,sp,-32
    80002642:	ec06                	sd	ra,24(sp)
    80002644:	e822                	sd	s0,16(sp)
    80002646:	e426                	sd	s1,8(sp)
    80002648:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    8000264a:	00009497          	auipc	s1,0x9
    8000264e:	0ee48493          	addi	s1,s1,238 # 8000b738 <sched_pointer>
    80002652:	609c                	ld	a5,0(s1)
    80002654:	9782                	jalr	a5
    while (1)
    80002656:	bff5                	j	80002652 <scheduler+0x12>

0000000080002658 <sched>:
{
    80002658:	7179                	addi	sp,sp,-48
    8000265a:	f406                	sd	ra,40(sp)
    8000265c:	f022                	sd	s0,32(sp)
    8000265e:	ec26                	sd	s1,24(sp)
    80002660:	e84a                	sd	s2,16(sp)
    80002662:	e44e                	sd	s3,8(sp)
    80002664:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    80002666:	00000097          	auipc	ra,0x0
    8000266a:	95a080e7          	jalr	-1702(ra) # 80001fc0 <myproc>
    8000266e:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    80002670:	ffffe097          	auipc	ra,0xffffe
    80002674:	620080e7          	jalr	1568(ra) # 80000c90 <holding>
    80002678:	c53d                	beqz	a0,800026e6 <sched+0x8e>
    8000267a:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    8000267c:	2781                	sext.w	a5,a5
    8000267e:	079e                	slli	a5,a5,0x7
    80002680:	00091717          	auipc	a4,0x91
    80002684:	40070713          	addi	a4,a4,1024 # 80093a80 <cpus>
    80002688:	97ba                	add	a5,a5,a4
    8000268a:	5fb8                	lw	a4,120(a5)
    8000268c:	4785                	li	a5,1
    8000268e:	06f71463          	bne	a4,a5,800026f6 <sched+0x9e>
    if (p->state == RUNNING)
    80002692:	4c98                	lw	a4,24(s1)
    80002694:	4791                	li	a5,4
    80002696:	06f70863          	beq	a4,a5,80002706 <sched+0xae>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    8000269a:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    8000269e:	8b89                	andi	a5,a5,2
    if (intr_get())
    800026a0:	ebbd                	bnez	a5,80002716 <sched+0xbe>
    asm volatile("mv %0, tp" : "=r"(x));
    800026a2:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    800026a4:	00091917          	auipc	s2,0x91
    800026a8:	3dc90913          	addi	s2,s2,988 # 80093a80 <cpus>
    800026ac:	2781                	sext.w	a5,a5
    800026ae:	079e                	slli	a5,a5,0x7
    800026b0:	97ca                	add	a5,a5,s2
    800026b2:	07c7a983          	lw	s3,124(a5)
    800026b6:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    800026b8:	2581                	sext.w	a1,a1
    800026ba:	059e                	slli	a1,a1,0x7
    800026bc:	05a1                	addi	a1,a1,8
    800026be:	95ca                	add	a1,a1,s2
    800026c0:	06048513          	addi	a0,s1,96
    800026c4:	00000097          	auipc	ra,0x0
    800026c8:	6e4080e7          	jalr	1764(ra) # 80002da8 <swtch>
    800026cc:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    800026ce:	2781                	sext.w	a5,a5
    800026d0:	079e                	slli	a5,a5,0x7
    800026d2:	993e                	add	s2,s2,a5
    800026d4:	07392e23          	sw	s3,124(s2)
}
    800026d8:	70a2                	ld	ra,40(sp)
    800026da:	7402                	ld	s0,32(sp)
    800026dc:	64e2                	ld	s1,24(sp)
    800026de:	6942                	ld	s2,16(sp)
    800026e0:	69a2                	ld	s3,8(sp)
    800026e2:	6145                	addi	sp,sp,48
    800026e4:	8082                	ret
        panic("sched p->lock");
    800026e6:	00006517          	auipc	a0,0x6
    800026ea:	cfa50513          	addi	a0,a0,-774 # 800083e0 <__func__.1+0x3d8>
    800026ee:	ffffe097          	auipc	ra,0xffffe
    800026f2:	e72080e7          	jalr	-398(ra) # 80000560 <panic>
        panic("sched locks");
    800026f6:	00006517          	auipc	a0,0x6
    800026fa:	cfa50513          	addi	a0,a0,-774 # 800083f0 <__func__.1+0x3e8>
    800026fe:	ffffe097          	auipc	ra,0xffffe
    80002702:	e62080e7          	jalr	-414(ra) # 80000560 <panic>
        panic("sched running");
    80002706:	00006517          	auipc	a0,0x6
    8000270a:	cfa50513          	addi	a0,a0,-774 # 80008400 <__func__.1+0x3f8>
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	e52080e7          	jalr	-430(ra) # 80000560 <panic>
        panic("sched interruptible");
    80002716:	00006517          	auipc	a0,0x6
    8000271a:	cfa50513          	addi	a0,a0,-774 # 80008410 <__func__.1+0x408>
    8000271e:	ffffe097          	auipc	ra,0xffffe
    80002722:	e42080e7          	jalr	-446(ra) # 80000560 <panic>

0000000080002726 <yield>:
{
    80002726:	1101                	addi	sp,sp,-32
    80002728:	ec06                	sd	ra,24(sp)
    8000272a:	e822                	sd	s0,16(sp)
    8000272c:	e426                	sd	s1,8(sp)
    8000272e:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    80002730:	00000097          	auipc	ra,0x0
    80002734:	890080e7          	jalr	-1904(ra) # 80001fc0 <myproc>
    80002738:	84aa                	mv	s1,a0
    acquire(&p->lock);
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	5d0080e7          	jalr	1488(ra) # 80000d0a <acquire>
    p->state = RUNNABLE;
    80002742:	478d                	li	a5,3
    80002744:	cc9c                	sw	a5,24(s1)
    sched();
    80002746:	00000097          	auipc	ra,0x0
    8000274a:	f12080e7          	jalr	-238(ra) # 80002658 <sched>
    release(&p->lock);
    8000274e:	8526                	mv	a0,s1
    80002750:	ffffe097          	auipc	ra,0xffffe
    80002754:	66e080e7          	jalr	1646(ra) # 80000dbe <release>
}
    80002758:	60e2                	ld	ra,24(sp)
    8000275a:	6442                	ld	s0,16(sp)
    8000275c:	64a2                	ld	s1,8(sp)
    8000275e:	6105                	addi	sp,sp,32
    80002760:	8082                	ret

0000000080002762 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002762:	7179                	addi	sp,sp,-48
    80002764:	f406                	sd	ra,40(sp)
    80002766:	f022                	sd	s0,32(sp)
    80002768:	ec26                	sd	s1,24(sp)
    8000276a:	e84a                	sd	s2,16(sp)
    8000276c:	e44e                	sd	s3,8(sp)
    8000276e:	1800                	addi	s0,sp,48
    80002770:	89aa                	mv	s3,a0
    80002772:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002774:	00000097          	auipc	ra,0x0
    80002778:	84c080e7          	jalr	-1972(ra) # 80001fc0 <myproc>
    8000277c:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    8000277e:	ffffe097          	auipc	ra,0xffffe
    80002782:	58c080e7          	jalr	1420(ra) # 80000d0a <acquire>
    release(lk);
    80002786:	854a                	mv	a0,s2
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	636080e7          	jalr	1590(ra) # 80000dbe <release>

    // Go to sleep.
    p->chan = chan;
    80002790:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    80002794:	4789                	li	a5,2
    80002796:	cc9c                	sw	a5,24(s1)

    sched();
    80002798:	00000097          	auipc	ra,0x0
    8000279c:	ec0080e7          	jalr	-320(ra) # 80002658 <sched>

    // Tidy up.
    p->chan = 0;
    800027a0:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    800027a4:	8526                	mv	a0,s1
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	618080e7          	jalr	1560(ra) # 80000dbe <release>
    acquire(lk);
    800027ae:	854a                	mv	a0,s2
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	55a080e7          	jalr	1370(ra) # 80000d0a <acquire>
}
    800027b8:	70a2                	ld	ra,40(sp)
    800027ba:	7402                	ld	s0,32(sp)
    800027bc:	64e2                	ld	s1,24(sp)
    800027be:	6942                	ld	s2,16(sp)
    800027c0:	69a2                	ld	s3,8(sp)
    800027c2:	6145                	addi	sp,sp,48
    800027c4:	8082                	ret

00000000800027c6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800027c6:	7139                	addi	sp,sp,-64
    800027c8:	fc06                	sd	ra,56(sp)
    800027ca:	f822                	sd	s0,48(sp)
    800027cc:	f426                	sd	s1,40(sp)
    800027ce:	f04a                	sd	s2,32(sp)
    800027d0:	ec4e                	sd	s3,24(sp)
    800027d2:	e852                	sd	s4,16(sp)
    800027d4:	e456                	sd	s5,8(sp)
    800027d6:	0080                	addi	s0,sp,64
    800027d8:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800027da:	00091497          	auipc	s1,0x91
    800027de:	6d648493          	addi	s1,s1,1750 # 80093eb0 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    800027e2:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    800027e4:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    800027e6:	00097917          	auipc	s2,0x97
    800027ea:	0ca90913          	addi	s2,s2,202 # 800998b0 <tickslock>
    800027ee:	a811                	j	80002802 <wakeup+0x3c>
            }
            release(&p->lock);
    800027f0:	8526                	mv	a0,s1
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	5cc080e7          	jalr	1484(ra) # 80000dbe <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800027fa:	16848493          	addi	s1,s1,360
    800027fe:	03248663          	beq	s1,s2,8000282a <wakeup+0x64>
        if (p != myproc())
    80002802:	fffff097          	auipc	ra,0xfffff
    80002806:	7be080e7          	jalr	1982(ra) # 80001fc0 <myproc>
    8000280a:	fea488e3          	beq	s1,a0,800027fa <wakeup+0x34>
            acquire(&p->lock);
    8000280e:	8526                	mv	a0,s1
    80002810:	ffffe097          	auipc	ra,0xffffe
    80002814:	4fa080e7          	jalr	1274(ra) # 80000d0a <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    80002818:	4c9c                	lw	a5,24(s1)
    8000281a:	fd379be3          	bne	a5,s3,800027f0 <wakeup+0x2a>
    8000281e:	709c                	ld	a5,32(s1)
    80002820:	fd4798e3          	bne	a5,s4,800027f0 <wakeup+0x2a>
                p->state = RUNNABLE;
    80002824:	0154ac23          	sw	s5,24(s1)
    80002828:	b7e1                	j	800027f0 <wakeup+0x2a>
        }
    }
}
    8000282a:	70e2                	ld	ra,56(sp)
    8000282c:	7442                	ld	s0,48(sp)
    8000282e:	74a2                	ld	s1,40(sp)
    80002830:	7902                	ld	s2,32(sp)
    80002832:	69e2                	ld	s3,24(sp)
    80002834:	6a42                	ld	s4,16(sp)
    80002836:	6aa2                	ld	s5,8(sp)
    80002838:	6121                	addi	sp,sp,64
    8000283a:	8082                	ret

000000008000283c <reparent>:
{
    8000283c:	7179                	addi	sp,sp,-48
    8000283e:	f406                	sd	ra,40(sp)
    80002840:	f022                	sd	s0,32(sp)
    80002842:	ec26                	sd	s1,24(sp)
    80002844:	e84a                	sd	s2,16(sp)
    80002846:	e44e                	sd	s3,8(sp)
    80002848:	e052                	sd	s4,0(sp)
    8000284a:	1800                	addi	s0,sp,48
    8000284c:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000284e:	00091497          	auipc	s1,0x91
    80002852:	66248493          	addi	s1,s1,1634 # 80093eb0 <proc>
            pp->parent = initproc;
    80002856:	00009a17          	auipc	s4,0x9
    8000285a:	fb2a0a13          	addi	s4,s4,-78 # 8000b808 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000285e:	00097997          	auipc	s3,0x97
    80002862:	05298993          	addi	s3,s3,82 # 800998b0 <tickslock>
    80002866:	a029                	j	80002870 <reparent+0x34>
    80002868:	16848493          	addi	s1,s1,360
    8000286c:	01348d63          	beq	s1,s3,80002886 <reparent+0x4a>
        if (pp->parent == p)
    80002870:	7c9c                	ld	a5,56(s1)
    80002872:	ff279be3          	bne	a5,s2,80002868 <reparent+0x2c>
            pp->parent = initproc;
    80002876:	000a3503          	ld	a0,0(s4)
    8000287a:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	f4a080e7          	jalr	-182(ra) # 800027c6 <wakeup>
    80002884:	b7d5                	j	80002868 <reparent+0x2c>
}
    80002886:	70a2                	ld	ra,40(sp)
    80002888:	7402                	ld	s0,32(sp)
    8000288a:	64e2                	ld	s1,24(sp)
    8000288c:	6942                	ld	s2,16(sp)
    8000288e:	69a2                	ld	s3,8(sp)
    80002890:	6a02                	ld	s4,0(sp)
    80002892:	6145                	addi	sp,sp,48
    80002894:	8082                	ret

0000000080002896 <exit>:
{
    80002896:	7179                	addi	sp,sp,-48
    80002898:	f406                	sd	ra,40(sp)
    8000289a:	f022                	sd	s0,32(sp)
    8000289c:	ec26                	sd	s1,24(sp)
    8000289e:	e84a                	sd	s2,16(sp)
    800028a0:	e44e                	sd	s3,8(sp)
    800028a2:	e052                	sd	s4,0(sp)
    800028a4:	1800                	addi	s0,sp,48
    800028a6:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    800028a8:	fffff097          	auipc	ra,0xfffff
    800028ac:	718080e7          	jalr	1816(ra) # 80001fc0 <myproc>
    800028b0:	89aa                	mv	s3,a0
    if (p == initproc)
    800028b2:	00009797          	auipc	a5,0x9
    800028b6:	f567b783          	ld	a5,-170(a5) # 8000b808 <initproc>
    800028ba:	0d050493          	addi	s1,a0,208
    800028be:	15050913          	addi	s2,a0,336
    800028c2:	02a79363          	bne	a5,a0,800028e8 <exit+0x52>
        panic("init exiting");
    800028c6:	00006517          	auipc	a0,0x6
    800028ca:	b6250513          	addi	a0,a0,-1182 # 80008428 <__func__.1+0x420>
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	c92080e7          	jalr	-878(ra) # 80000560 <panic>
            fileclose(f);
    800028d6:	00002097          	auipc	ra,0x2
    800028da:	52e080e7          	jalr	1326(ra) # 80004e04 <fileclose>
            p->ofile[fd] = 0;
    800028de:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    800028e2:	04a1                	addi	s1,s1,8
    800028e4:	01248563          	beq	s1,s2,800028ee <exit+0x58>
        if (p->ofile[fd])
    800028e8:	6088                	ld	a0,0(s1)
    800028ea:	f575                	bnez	a0,800028d6 <exit+0x40>
    800028ec:	bfdd                	j	800028e2 <exit+0x4c>
    begin_op();
    800028ee:	00002097          	auipc	ra,0x2
    800028f2:	04c080e7          	jalr	76(ra) # 8000493a <begin_op>
    iput(p->cwd);
    800028f6:	1509b503          	ld	a0,336(s3)
    800028fa:	00002097          	auipc	ra,0x2
    800028fe:	830080e7          	jalr	-2000(ra) # 8000412a <iput>
    end_op();
    80002902:	00002097          	auipc	ra,0x2
    80002906:	0b2080e7          	jalr	178(ra) # 800049b4 <end_op>
    p->cwd = 0;
    8000290a:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    8000290e:	00091497          	auipc	s1,0x91
    80002912:	58a48493          	addi	s1,s1,1418 # 80093e98 <wait_lock>
    80002916:	8526                	mv	a0,s1
    80002918:	ffffe097          	auipc	ra,0xffffe
    8000291c:	3f2080e7          	jalr	1010(ra) # 80000d0a <acquire>
    reparent(p);
    80002920:	854e                	mv	a0,s3
    80002922:	00000097          	auipc	ra,0x0
    80002926:	f1a080e7          	jalr	-230(ra) # 8000283c <reparent>
    wakeup(p->parent);
    8000292a:	0389b503          	ld	a0,56(s3)
    8000292e:	00000097          	auipc	ra,0x0
    80002932:	e98080e7          	jalr	-360(ra) # 800027c6 <wakeup>
    acquire(&p->lock);
    80002936:	854e                	mv	a0,s3
    80002938:	ffffe097          	auipc	ra,0xffffe
    8000293c:	3d2080e7          	jalr	978(ra) # 80000d0a <acquire>
    p->xstate = status;
    80002940:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    80002944:	4795                	li	a5,5
    80002946:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    8000294a:	8526                	mv	a0,s1
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	472080e7          	jalr	1138(ra) # 80000dbe <release>
    sched();
    80002954:	00000097          	auipc	ra,0x0
    80002958:	d04080e7          	jalr	-764(ra) # 80002658 <sched>
    panic("zombie exit");
    8000295c:	00006517          	auipc	a0,0x6
    80002960:	adc50513          	addi	a0,a0,-1316 # 80008438 <__func__.1+0x430>
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	bfc080e7          	jalr	-1028(ra) # 80000560 <panic>

000000008000296c <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000296c:	7179                	addi	sp,sp,-48
    8000296e:	f406                	sd	ra,40(sp)
    80002970:	f022                	sd	s0,32(sp)
    80002972:	ec26                	sd	s1,24(sp)
    80002974:	e84a                	sd	s2,16(sp)
    80002976:	e44e                	sd	s3,8(sp)
    80002978:	1800                	addi	s0,sp,48
    8000297a:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    8000297c:	00091497          	auipc	s1,0x91
    80002980:	53448493          	addi	s1,s1,1332 # 80093eb0 <proc>
    80002984:	00097997          	auipc	s3,0x97
    80002988:	f2c98993          	addi	s3,s3,-212 # 800998b0 <tickslock>
    {
        acquire(&p->lock);
    8000298c:	8526                	mv	a0,s1
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	37c080e7          	jalr	892(ra) # 80000d0a <acquire>
        if (p->pid == pid)
    80002996:	589c                	lw	a5,48(s1)
    80002998:	01278d63          	beq	a5,s2,800029b2 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    8000299c:	8526                	mv	a0,s1
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	420080e7          	jalr	1056(ra) # 80000dbe <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800029a6:	16848493          	addi	s1,s1,360
    800029aa:	ff3491e3          	bne	s1,s3,8000298c <kill+0x20>
    }
    return -1;
    800029ae:	557d                	li	a0,-1
    800029b0:	a829                	j	800029ca <kill+0x5e>
            p->killed = 1;
    800029b2:	4785                	li	a5,1
    800029b4:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    800029b6:	4c98                	lw	a4,24(s1)
    800029b8:	4789                	li	a5,2
    800029ba:	00f70f63          	beq	a4,a5,800029d8 <kill+0x6c>
            release(&p->lock);
    800029be:	8526                	mv	a0,s1
    800029c0:	ffffe097          	auipc	ra,0xffffe
    800029c4:	3fe080e7          	jalr	1022(ra) # 80000dbe <release>
            return 0;
    800029c8:	4501                	li	a0,0
}
    800029ca:	70a2                	ld	ra,40(sp)
    800029cc:	7402                	ld	s0,32(sp)
    800029ce:	64e2                	ld	s1,24(sp)
    800029d0:	6942                	ld	s2,16(sp)
    800029d2:	69a2                	ld	s3,8(sp)
    800029d4:	6145                	addi	sp,sp,48
    800029d6:	8082                	ret
                p->state = RUNNABLE;
    800029d8:	478d                	li	a5,3
    800029da:	cc9c                	sw	a5,24(s1)
    800029dc:	b7cd                	j	800029be <kill+0x52>

00000000800029de <setkilled>:

void setkilled(struct proc *p)
{
    800029de:	1101                	addi	sp,sp,-32
    800029e0:	ec06                	sd	ra,24(sp)
    800029e2:	e822                	sd	s0,16(sp)
    800029e4:	e426                	sd	s1,8(sp)
    800029e6:	1000                	addi	s0,sp,32
    800029e8:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800029ea:	ffffe097          	auipc	ra,0xffffe
    800029ee:	320080e7          	jalr	800(ra) # 80000d0a <acquire>
    p->killed = 1;
    800029f2:	4785                	li	a5,1
    800029f4:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    800029f6:	8526                	mv	a0,s1
    800029f8:	ffffe097          	auipc	ra,0xffffe
    800029fc:	3c6080e7          	jalr	966(ra) # 80000dbe <release>
}
    80002a00:	60e2                	ld	ra,24(sp)
    80002a02:	6442                	ld	s0,16(sp)
    80002a04:	64a2                	ld	s1,8(sp)
    80002a06:	6105                	addi	sp,sp,32
    80002a08:	8082                	ret

0000000080002a0a <killed>:

int killed(struct proc *p)
{
    80002a0a:	1101                	addi	sp,sp,-32
    80002a0c:	ec06                	sd	ra,24(sp)
    80002a0e:	e822                	sd	s0,16(sp)
    80002a10:	e426                	sd	s1,8(sp)
    80002a12:	e04a                	sd	s2,0(sp)
    80002a14:	1000                	addi	s0,sp,32
    80002a16:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	2f2080e7          	jalr	754(ra) # 80000d0a <acquire>
    k = p->killed;
    80002a20:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    80002a24:	8526                	mv	a0,s1
    80002a26:	ffffe097          	auipc	ra,0xffffe
    80002a2a:	398080e7          	jalr	920(ra) # 80000dbe <release>
    return k;
}
    80002a2e:	854a                	mv	a0,s2
    80002a30:	60e2                	ld	ra,24(sp)
    80002a32:	6442                	ld	s0,16(sp)
    80002a34:	64a2                	ld	s1,8(sp)
    80002a36:	6902                	ld	s2,0(sp)
    80002a38:	6105                	addi	sp,sp,32
    80002a3a:	8082                	ret

0000000080002a3c <wait>:
{
    80002a3c:	715d                	addi	sp,sp,-80
    80002a3e:	e486                	sd	ra,72(sp)
    80002a40:	e0a2                	sd	s0,64(sp)
    80002a42:	fc26                	sd	s1,56(sp)
    80002a44:	f84a                	sd	s2,48(sp)
    80002a46:	f44e                	sd	s3,40(sp)
    80002a48:	f052                	sd	s4,32(sp)
    80002a4a:	ec56                	sd	s5,24(sp)
    80002a4c:	e85a                	sd	s6,16(sp)
    80002a4e:	e45e                	sd	s7,8(sp)
    80002a50:	e062                	sd	s8,0(sp)
    80002a52:	0880                	addi	s0,sp,80
    80002a54:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    80002a56:	fffff097          	auipc	ra,0xfffff
    80002a5a:	56a080e7          	jalr	1386(ra) # 80001fc0 <myproc>
    80002a5e:	892a                	mv	s2,a0
    acquire(&wait_lock);
    80002a60:	00091517          	auipc	a0,0x91
    80002a64:	43850513          	addi	a0,a0,1080 # 80093e98 <wait_lock>
    80002a68:	ffffe097          	auipc	ra,0xffffe
    80002a6c:	2a2080e7          	jalr	674(ra) # 80000d0a <acquire>
        havekids = 0;
    80002a70:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    80002a72:	4a15                	li	s4,5
                havekids = 1;
    80002a74:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a76:	00097997          	auipc	s3,0x97
    80002a7a:	e3a98993          	addi	s3,s3,-454 # 800998b0 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002a7e:	00091c17          	auipc	s8,0x91
    80002a82:	41ac0c13          	addi	s8,s8,1050 # 80093e98 <wait_lock>
    80002a86:	a0d1                	j	80002b4a <wait+0x10e>
                    pid = pp->pid;
    80002a88:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002a8c:	000b0e63          	beqz	s6,80002aa8 <wait+0x6c>
    80002a90:	4691                	li	a3,4
    80002a92:	02c48613          	addi	a2,s1,44
    80002a96:	85da                	mv	a1,s6
    80002a98:	05093503          	ld	a0,80(s2)
    80002a9c:	fffff097          	auipc	ra,0xfffff
    80002aa0:	ff2080e7          	jalr	-14(ra) # 80001a8e <copyout>
    80002aa4:	04054163          	bltz	a0,80002ae6 <wait+0xaa>
                    freeproc(pp);
    80002aa8:	8526                	mv	a0,s1
    80002aaa:	fffff097          	auipc	ra,0xfffff
    80002aae:	6c2080e7          	jalr	1730(ra) # 8000216c <freeproc>
                    release(&pp->lock);
    80002ab2:	8526                	mv	a0,s1
    80002ab4:	ffffe097          	auipc	ra,0xffffe
    80002ab8:	30a080e7          	jalr	778(ra) # 80000dbe <release>
                    release(&wait_lock);
    80002abc:	00091517          	auipc	a0,0x91
    80002ac0:	3dc50513          	addi	a0,a0,988 # 80093e98 <wait_lock>
    80002ac4:	ffffe097          	auipc	ra,0xffffe
    80002ac8:	2fa080e7          	jalr	762(ra) # 80000dbe <release>
}
    80002acc:	854e                	mv	a0,s3
    80002ace:	60a6                	ld	ra,72(sp)
    80002ad0:	6406                	ld	s0,64(sp)
    80002ad2:	74e2                	ld	s1,56(sp)
    80002ad4:	7942                	ld	s2,48(sp)
    80002ad6:	79a2                	ld	s3,40(sp)
    80002ad8:	7a02                	ld	s4,32(sp)
    80002ada:	6ae2                	ld	s5,24(sp)
    80002adc:	6b42                	ld	s6,16(sp)
    80002ade:	6ba2                	ld	s7,8(sp)
    80002ae0:	6c02                	ld	s8,0(sp)
    80002ae2:	6161                	addi	sp,sp,80
    80002ae4:	8082                	ret
                        release(&pp->lock);
    80002ae6:	8526                	mv	a0,s1
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	2d6080e7          	jalr	726(ra) # 80000dbe <release>
                        release(&wait_lock);
    80002af0:	00091517          	auipc	a0,0x91
    80002af4:	3a850513          	addi	a0,a0,936 # 80093e98 <wait_lock>
    80002af8:	ffffe097          	auipc	ra,0xffffe
    80002afc:	2c6080e7          	jalr	710(ra) # 80000dbe <release>
                        return -1;
    80002b00:	59fd                	li	s3,-1
    80002b02:	b7e9                	j	80002acc <wait+0x90>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002b04:	16848493          	addi	s1,s1,360
    80002b08:	03348463          	beq	s1,s3,80002b30 <wait+0xf4>
            if (pp->parent == p)
    80002b0c:	7c9c                	ld	a5,56(s1)
    80002b0e:	ff279be3          	bne	a5,s2,80002b04 <wait+0xc8>
                acquire(&pp->lock);
    80002b12:	8526                	mv	a0,s1
    80002b14:	ffffe097          	auipc	ra,0xffffe
    80002b18:	1f6080e7          	jalr	502(ra) # 80000d0a <acquire>
                if (pp->state == ZOMBIE)
    80002b1c:	4c9c                	lw	a5,24(s1)
    80002b1e:	f74785e3          	beq	a5,s4,80002a88 <wait+0x4c>
                release(&pp->lock);
    80002b22:	8526                	mv	a0,s1
    80002b24:	ffffe097          	auipc	ra,0xffffe
    80002b28:	29a080e7          	jalr	666(ra) # 80000dbe <release>
                havekids = 1;
    80002b2c:	8756                	mv	a4,s5
    80002b2e:	bfd9                	j	80002b04 <wait+0xc8>
        if (!havekids || killed(p))
    80002b30:	c31d                	beqz	a4,80002b56 <wait+0x11a>
    80002b32:	854a                	mv	a0,s2
    80002b34:	00000097          	auipc	ra,0x0
    80002b38:	ed6080e7          	jalr	-298(ra) # 80002a0a <killed>
    80002b3c:	ed09                	bnez	a0,80002b56 <wait+0x11a>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002b3e:	85e2                	mv	a1,s8
    80002b40:	854a                	mv	a0,s2
    80002b42:	00000097          	auipc	ra,0x0
    80002b46:	c20080e7          	jalr	-992(ra) # 80002762 <sleep>
        havekids = 0;
    80002b4a:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002b4c:	00091497          	auipc	s1,0x91
    80002b50:	36448493          	addi	s1,s1,868 # 80093eb0 <proc>
    80002b54:	bf65                	j	80002b0c <wait+0xd0>
            release(&wait_lock);
    80002b56:	00091517          	auipc	a0,0x91
    80002b5a:	34250513          	addi	a0,a0,834 # 80093e98 <wait_lock>
    80002b5e:	ffffe097          	auipc	ra,0xffffe
    80002b62:	260080e7          	jalr	608(ra) # 80000dbe <release>
            return -1;
    80002b66:	59fd                	li	s3,-1
    80002b68:	b795                	j	80002acc <wait+0x90>

0000000080002b6a <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002b6a:	7179                	addi	sp,sp,-48
    80002b6c:	f406                	sd	ra,40(sp)
    80002b6e:	f022                	sd	s0,32(sp)
    80002b70:	ec26                	sd	s1,24(sp)
    80002b72:	e84a                	sd	s2,16(sp)
    80002b74:	e44e                	sd	s3,8(sp)
    80002b76:	e052                	sd	s4,0(sp)
    80002b78:	1800                	addi	s0,sp,48
    80002b7a:	84aa                	mv	s1,a0
    80002b7c:	892e                	mv	s2,a1
    80002b7e:	89b2                	mv	s3,a2
    80002b80:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002b82:	fffff097          	auipc	ra,0xfffff
    80002b86:	43e080e7          	jalr	1086(ra) # 80001fc0 <myproc>
    if (user_dst)
    80002b8a:	c08d                	beqz	s1,80002bac <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002b8c:	86d2                	mv	a3,s4
    80002b8e:	864e                	mv	a2,s3
    80002b90:	85ca                	mv	a1,s2
    80002b92:	6928                	ld	a0,80(a0)
    80002b94:	fffff097          	auipc	ra,0xfffff
    80002b98:	efa080e7          	jalr	-262(ra) # 80001a8e <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002b9c:	70a2                	ld	ra,40(sp)
    80002b9e:	7402                	ld	s0,32(sp)
    80002ba0:	64e2                	ld	s1,24(sp)
    80002ba2:	6942                	ld	s2,16(sp)
    80002ba4:	69a2                	ld	s3,8(sp)
    80002ba6:	6a02                	ld	s4,0(sp)
    80002ba8:	6145                	addi	sp,sp,48
    80002baa:	8082                	ret
        memmove((char *)dst, src, len);
    80002bac:	000a061b          	sext.w	a2,s4
    80002bb0:	85ce                	mv	a1,s3
    80002bb2:	854a                	mv	a0,s2
    80002bb4:	ffffe097          	auipc	ra,0xffffe
    80002bb8:	2ae080e7          	jalr	686(ra) # 80000e62 <memmove>
        return 0;
    80002bbc:	8526                	mv	a0,s1
    80002bbe:	bff9                	j	80002b9c <either_copyout+0x32>

0000000080002bc0 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002bc0:	7179                	addi	sp,sp,-48
    80002bc2:	f406                	sd	ra,40(sp)
    80002bc4:	f022                	sd	s0,32(sp)
    80002bc6:	ec26                	sd	s1,24(sp)
    80002bc8:	e84a                	sd	s2,16(sp)
    80002bca:	e44e                	sd	s3,8(sp)
    80002bcc:	e052                	sd	s4,0(sp)
    80002bce:	1800                	addi	s0,sp,48
    80002bd0:	892a                	mv	s2,a0
    80002bd2:	84ae                	mv	s1,a1
    80002bd4:	89b2                	mv	s3,a2
    80002bd6:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002bd8:	fffff097          	auipc	ra,0xfffff
    80002bdc:	3e8080e7          	jalr	1000(ra) # 80001fc0 <myproc>
    if (user_src)
    80002be0:	c08d                	beqz	s1,80002c02 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    80002be2:	86d2                	mv	a3,s4
    80002be4:	864e                	mv	a2,s3
    80002be6:	85ca                	mv	a1,s2
    80002be8:	6928                	ld	a0,80(a0)
    80002bea:	fffff097          	auipc	ra,0xfffff
    80002bee:	f30080e7          	jalr	-208(ra) # 80001b1a <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    80002bf2:	70a2                	ld	ra,40(sp)
    80002bf4:	7402                	ld	s0,32(sp)
    80002bf6:	64e2                	ld	s1,24(sp)
    80002bf8:	6942                	ld	s2,16(sp)
    80002bfa:	69a2                	ld	s3,8(sp)
    80002bfc:	6a02                	ld	s4,0(sp)
    80002bfe:	6145                	addi	sp,sp,48
    80002c00:	8082                	ret
        memmove(dst, (char *)src, len);
    80002c02:	000a061b          	sext.w	a2,s4
    80002c06:	85ce                	mv	a1,s3
    80002c08:	854a                	mv	a0,s2
    80002c0a:	ffffe097          	auipc	ra,0xffffe
    80002c0e:	258080e7          	jalr	600(ra) # 80000e62 <memmove>
        return 0;
    80002c12:	8526                	mv	a0,s1
    80002c14:	bff9                	j	80002bf2 <either_copyin+0x32>

0000000080002c16 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002c16:	715d                	addi	sp,sp,-80
    80002c18:	e486                	sd	ra,72(sp)
    80002c1a:	e0a2                	sd	s0,64(sp)
    80002c1c:	fc26                	sd	s1,56(sp)
    80002c1e:	f84a                	sd	s2,48(sp)
    80002c20:	f44e                	sd	s3,40(sp)
    80002c22:	f052                	sd	s4,32(sp)
    80002c24:	ec56                	sd	s5,24(sp)
    80002c26:	e85a                	sd	s6,16(sp)
    80002c28:	e45e                	sd	s7,8(sp)
    80002c2a:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002c2c:	00005517          	auipc	a0,0x5
    80002c30:	3f450513          	addi	a0,a0,1012 # 80008020 <__func__.1+0x18>
    80002c34:	ffffe097          	auipc	ra,0xffffe
    80002c38:	988080e7          	jalr	-1656(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002c3c:	00091497          	auipc	s1,0x91
    80002c40:	3cc48493          	addi	s1,s1,972 # 80094008 <proc+0x158>
    80002c44:	00097917          	auipc	s2,0x97
    80002c48:	dc490913          	addi	s2,s2,-572 # 80099a08 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c4c:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002c4e:	00005997          	auipc	s3,0x5
    80002c52:	7fa98993          	addi	s3,s3,2042 # 80008448 <__func__.1+0x440>
        printf("%d <%s %s", p->pid, state, p->name);
    80002c56:	00005a97          	auipc	s5,0x5
    80002c5a:	7faa8a93          	addi	s5,s5,2042 # 80008450 <__func__.1+0x448>
        printf("\n");
    80002c5e:	00005a17          	auipc	s4,0x5
    80002c62:	3c2a0a13          	addi	s4,s4,962 # 80008020 <__func__.1+0x18>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c66:	00006b97          	auipc	s7,0x6
    80002c6a:	d9ab8b93          	addi	s7,s7,-614 # 80008a00 <states.0>
    80002c6e:	a00d                	j	80002c90 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002c70:	ed86a583          	lw	a1,-296(a3)
    80002c74:	8556                	mv	a0,s5
    80002c76:	ffffe097          	auipc	ra,0xffffe
    80002c7a:	946080e7          	jalr	-1722(ra) # 800005bc <printf>
        printf("\n");
    80002c7e:	8552                	mv	a0,s4
    80002c80:	ffffe097          	auipc	ra,0xffffe
    80002c84:	93c080e7          	jalr	-1732(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002c88:	16848493          	addi	s1,s1,360
    80002c8c:	03248263          	beq	s1,s2,80002cb0 <procdump+0x9a>
        if (p->state == UNUSED)
    80002c90:	86a6                	mv	a3,s1
    80002c92:	ec04a783          	lw	a5,-320(s1)
    80002c96:	dbed                	beqz	a5,80002c88 <procdump+0x72>
            state = "???";
    80002c98:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c9a:	fcfb6be3          	bltu	s6,a5,80002c70 <procdump+0x5a>
    80002c9e:	02079713          	slli	a4,a5,0x20
    80002ca2:	01d75793          	srli	a5,a4,0x1d
    80002ca6:	97de                	add	a5,a5,s7
    80002ca8:	6390                	ld	a2,0(a5)
    80002caa:	f279                	bnez	a2,80002c70 <procdump+0x5a>
            state = "???";
    80002cac:	864e                	mv	a2,s3
    80002cae:	b7c9                	j	80002c70 <procdump+0x5a>
    }
}
    80002cb0:	60a6                	ld	ra,72(sp)
    80002cb2:	6406                	ld	s0,64(sp)
    80002cb4:	74e2                	ld	s1,56(sp)
    80002cb6:	7942                	ld	s2,48(sp)
    80002cb8:	79a2                	ld	s3,40(sp)
    80002cba:	7a02                	ld	s4,32(sp)
    80002cbc:	6ae2                	ld	s5,24(sp)
    80002cbe:	6b42                	ld	s6,16(sp)
    80002cc0:	6ba2                	ld	s7,8(sp)
    80002cc2:	6161                	addi	sp,sp,80
    80002cc4:	8082                	ret

0000000080002cc6 <schedls>:

void schedls()
{
    80002cc6:	1141                	addi	sp,sp,-16
    80002cc8:	e406                	sd	ra,8(sp)
    80002cca:	e022                	sd	s0,0(sp)
    80002ccc:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002cce:	00005517          	auipc	a0,0x5
    80002cd2:	79250513          	addi	a0,a0,1938 # 80008460 <__func__.1+0x458>
    80002cd6:	ffffe097          	auipc	ra,0xffffe
    80002cda:	8e6080e7          	jalr	-1818(ra) # 800005bc <printf>
    printf("====================================\n");
    80002cde:	00005517          	auipc	a0,0x5
    80002ce2:	7aa50513          	addi	a0,a0,1962 # 80008488 <__func__.1+0x480>
    80002ce6:	ffffe097          	auipc	ra,0xffffe
    80002cea:	8d6080e7          	jalr	-1834(ra) # 800005bc <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002cee:	00009717          	auipc	a4,0x9
    80002cf2:	aaa73703          	ld	a4,-1366(a4) # 8000b798 <available_schedulers+0x10>
    80002cf6:	00009797          	auipc	a5,0x9
    80002cfa:	a427b783          	ld	a5,-1470(a5) # 8000b738 <sched_pointer>
    80002cfe:	04f70663          	beq	a4,a5,80002d4a <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002d02:	00005517          	auipc	a0,0x5
    80002d06:	7b650513          	addi	a0,a0,1974 # 800084b8 <__func__.1+0x4b0>
    80002d0a:	ffffe097          	auipc	ra,0xffffe
    80002d0e:	8b2080e7          	jalr	-1870(ra) # 800005bc <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002d12:	00009617          	auipc	a2,0x9
    80002d16:	a8e62603          	lw	a2,-1394(a2) # 8000b7a0 <available_schedulers+0x18>
    80002d1a:	00009597          	auipc	a1,0x9
    80002d1e:	a6e58593          	addi	a1,a1,-1426 # 8000b788 <available_schedulers>
    80002d22:	00005517          	auipc	a0,0x5
    80002d26:	79e50513          	addi	a0,a0,1950 # 800084c0 <__func__.1+0x4b8>
    80002d2a:	ffffe097          	auipc	ra,0xffffe
    80002d2e:	892080e7          	jalr	-1902(ra) # 800005bc <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002d32:	00005517          	auipc	a0,0x5
    80002d36:	79650513          	addi	a0,a0,1942 # 800084c8 <__func__.1+0x4c0>
    80002d3a:	ffffe097          	auipc	ra,0xffffe
    80002d3e:	882080e7          	jalr	-1918(ra) # 800005bc <printf>
}
    80002d42:	60a2                	ld	ra,8(sp)
    80002d44:	6402                	ld	s0,0(sp)
    80002d46:	0141                	addi	sp,sp,16
    80002d48:	8082                	ret
            printf("[*]\t");
    80002d4a:	00005517          	auipc	a0,0x5
    80002d4e:	76650513          	addi	a0,a0,1894 # 800084b0 <__func__.1+0x4a8>
    80002d52:	ffffe097          	auipc	ra,0xffffe
    80002d56:	86a080e7          	jalr	-1942(ra) # 800005bc <printf>
    80002d5a:	bf65                	j	80002d12 <schedls+0x4c>

0000000080002d5c <schedset>:

void schedset(int id)
{
    80002d5c:	1141                	addi	sp,sp,-16
    80002d5e:	e406                	sd	ra,8(sp)
    80002d60:	e022                	sd	s0,0(sp)
    80002d62:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002d64:	e90d                	bnez	a0,80002d96 <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002d66:	00009797          	auipc	a5,0x9
    80002d6a:	a327b783          	ld	a5,-1486(a5) # 8000b798 <available_schedulers+0x10>
    80002d6e:	00009717          	auipc	a4,0x9
    80002d72:	9cf73523          	sd	a5,-1590(a4) # 8000b738 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002d76:	00009597          	auipc	a1,0x9
    80002d7a:	a1258593          	addi	a1,a1,-1518 # 8000b788 <available_schedulers>
    80002d7e:	00005517          	auipc	a0,0x5
    80002d82:	78a50513          	addi	a0,a0,1930 # 80008508 <__func__.1+0x500>
    80002d86:	ffffe097          	auipc	ra,0xffffe
    80002d8a:	836080e7          	jalr	-1994(ra) # 800005bc <printf>
    80002d8e:	60a2                	ld	ra,8(sp)
    80002d90:	6402                	ld	s0,0(sp)
    80002d92:	0141                	addi	sp,sp,16
    80002d94:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002d96:	00005517          	auipc	a0,0x5
    80002d9a:	74a50513          	addi	a0,a0,1866 # 800084e0 <__func__.1+0x4d8>
    80002d9e:	ffffe097          	auipc	ra,0xffffe
    80002da2:	81e080e7          	jalr	-2018(ra) # 800005bc <printf>
        return;
    80002da6:	b7e5                	j	80002d8e <schedset+0x32>

0000000080002da8 <swtch>:
    80002da8:	00153023          	sd	ra,0(a0)
    80002dac:	00253423          	sd	sp,8(a0)
    80002db0:	e900                	sd	s0,16(a0)
    80002db2:	ed04                	sd	s1,24(a0)
    80002db4:	03253023          	sd	s2,32(a0)
    80002db8:	03353423          	sd	s3,40(a0)
    80002dbc:	03453823          	sd	s4,48(a0)
    80002dc0:	03553c23          	sd	s5,56(a0)
    80002dc4:	05653023          	sd	s6,64(a0)
    80002dc8:	05753423          	sd	s7,72(a0)
    80002dcc:	05853823          	sd	s8,80(a0)
    80002dd0:	05953c23          	sd	s9,88(a0)
    80002dd4:	07a53023          	sd	s10,96(a0)
    80002dd8:	07b53423          	sd	s11,104(a0)
    80002ddc:	0005b083          	ld	ra,0(a1)
    80002de0:	0085b103          	ld	sp,8(a1)
    80002de4:	6980                	ld	s0,16(a1)
    80002de6:	6d84                	ld	s1,24(a1)
    80002de8:	0205b903          	ld	s2,32(a1)
    80002dec:	0285b983          	ld	s3,40(a1)
    80002df0:	0305ba03          	ld	s4,48(a1)
    80002df4:	0385ba83          	ld	s5,56(a1)
    80002df8:	0405bb03          	ld	s6,64(a1)
    80002dfc:	0485bb83          	ld	s7,72(a1)
    80002e00:	0505bc03          	ld	s8,80(a1)
    80002e04:	0585bc83          	ld	s9,88(a1)
    80002e08:	0605bd03          	ld	s10,96(a1)
    80002e0c:	0685bd83          	ld	s11,104(a1)
    80002e10:	8082                	ret

0000000080002e12 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002e12:	1141                	addi	sp,sp,-16
    80002e14:	e406                	sd	ra,8(sp)
    80002e16:	e022                	sd	s0,0(sp)
    80002e18:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002e1a:	00005597          	auipc	a1,0x5
    80002e1e:	74658593          	addi	a1,a1,1862 # 80008560 <__func__.1+0x558>
    80002e22:	00097517          	auipc	a0,0x97
    80002e26:	a8e50513          	addi	a0,a0,-1394 # 800998b0 <tickslock>
    80002e2a:	ffffe097          	auipc	ra,0xffffe
    80002e2e:	e50080e7          	jalr	-432(ra) # 80000c7a <initlock>
}
    80002e32:	60a2                	ld	ra,8(sp)
    80002e34:	6402                	ld	s0,0(sp)
    80002e36:	0141                	addi	sp,sp,16
    80002e38:	8082                	ret

0000000080002e3a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002e3a:	1141                	addi	sp,sp,-16
    80002e3c:	e422                	sd	s0,8(sp)
    80002e3e:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002e40:	00003797          	auipc	a5,0x3
    80002e44:	7a078793          	addi	a5,a5,1952 # 800065e0 <kernelvec>
    80002e48:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002e4c:	6422                	ld	s0,8(sp)
    80002e4e:	0141                	addi	sp,sp,16
    80002e50:	8082                	ret

0000000080002e52 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002e52:	1141                	addi	sp,sp,-16
    80002e54:	e406                	sd	ra,8(sp)
    80002e56:	e022                	sd	s0,0(sp)
    80002e58:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002e5a:	fffff097          	auipc	ra,0xfffff
    80002e5e:	166080e7          	jalr	358(ra) # 80001fc0 <myproc>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002e62:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002e66:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002e68:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002e6c:	00004697          	auipc	a3,0x4
    80002e70:	19468693          	addi	a3,a3,404 # 80007000 <_trampoline>
    80002e74:	00004717          	auipc	a4,0x4
    80002e78:	18c70713          	addi	a4,a4,396 # 80007000 <_trampoline>
    80002e7c:	8f15                	sub	a4,a4,a3
    80002e7e:	040007b7          	lui	a5,0x4000
    80002e82:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002e84:	07b2                	slli	a5,a5,0xc
    80002e86:	973e                	add	a4,a4,a5
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002e88:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002e8c:	6d38                	ld	a4,88(a0)
    asm volatile("csrr %0, satp" : "=r"(x));
    80002e8e:	18002673          	csrr	a2,satp
    80002e92:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002e94:	6d30                	ld	a2,88(a0)
    80002e96:	6138                	ld	a4,64(a0)
    80002e98:	6585                	lui	a1,0x1
    80002e9a:	972e                	add	a4,a4,a1
    80002e9c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002e9e:	6d38                	ld	a4,88(a0)
    80002ea0:	00000617          	auipc	a2,0x0
    80002ea4:	13860613          	addi	a2,a2,312 # 80002fd8 <usertrap>
    80002ea8:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002eaa:	6d38                	ld	a4,88(a0)
    asm volatile("mv %0, tp" : "=r"(x));
    80002eac:	8612                	mv	a2,tp
    80002eae:	f310                	sd	a2,32(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002eb0:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002eb4:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002eb8:	02076713          	ori	a4,a4,32
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002ebc:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002ec0:	6d38                	ld	a4,88(a0)
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002ec2:	6f18                	ld	a4,24(a4)
    80002ec4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ec8:	6928                	ld	a0,80(a0)
    80002eca:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002ecc:	00004717          	auipc	a4,0x4
    80002ed0:	1d070713          	addi	a4,a4,464 # 8000709c <userret>
    80002ed4:	8f15                	sub	a4,a4,a3
    80002ed6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002ed8:	577d                	li	a4,-1
    80002eda:	177e                	slli	a4,a4,0x3f
    80002edc:	8d59                	or	a0,a0,a4
    80002ede:	9782                	jalr	a5
}
    80002ee0:	60a2                	ld	ra,8(sp)
    80002ee2:	6402                	ld	s0,0(sp)
    80002ee4:	0141                	addi	sp,sp,16
    80002ee6:	8082                	ret

0000000080002ee8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002ee8:	1101                	addi	sp,sp,-32
    80002eea:	ec06                	sd	ra,24(sp)
    80002eec:	e822                	sd	s0,16(sp)
    80002eee:	e426                	sd	s1,8(sp)
    80002ef0:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ef2:	00097497          	auipc	s1,0x97
    80002ef6:	9be48493          	addi	s1,s1,-1602 # 800998b0 <tickslock>
    80002efa:	8526                	mv	a0,s1
    80002efc:	ffffe097          	auipc	ra,0xffffe
    80002f00:	e0e080e7          	jalr	-498(ra) # 80000d0a <acquire>
  ticks++;
    80002f04:	00009517          	auipc	a0,0x9
    80002f08:	90c50513          	addi	a0,a0,-1780 # 8000b810 <ticks>
    80002f0c:	411c                	lw	a5,0(a0)
    80002f0e:	2785                	addiw	a5,a5,1
    80002f10:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002f12:	00000097          	auipc	ra,0x0
    80002f16:	8b4080e7          	jalr	-1868(ra) # 800027c6 <wakeup>
  release(&tickslock);
    80002f1a:	8526                	mv	a0,s1
    80002f1c:	ffffe097          	auipc	ra,0xffffe
    80002f20:	ea2080e7          	jalr	-350(ra) # 80000dbe <release>
}
    80002f24:	60e2                	ld	ra,24(sp)
    80002f26:	6442                	ld	s0,16(sp)
    80002f28:	64a2                	ld	s1,8(sp)
    80002f2a:	6105                	addi	sp,sp,32
    80002f2c:	8082                	ret

0000000080002f2e <devintr>:
    asm volatile("csrr %0, scause" : "=r"(x));
    80002f2e:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002f32:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002f34:	0a07d163          	bgez	a5,80002fd6 <devintr+0xa8>
{
    80002f38:	1101                	addi	sp,sp,-32
    80002f3a:	ec06                	sd	ra,24(sp)
    80002f3c:	e822                	sd	s0,16(sp)
    80002f3e:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002f40:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002f44:	46a5                	li	a3,9
    80002f46:	00d70c63          	beq	a4,a3,80002f5e <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002f4a:	577d                	li	a4,-1
    80002f4c:	177e                	slli	a4,a4,0x3f
    80002f4e:	0705                	addi	a4,a4,1
    return 0;
    80002f50:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002f52:	06e78163          	beq	a5,a4,80002fb4 <devintr+0x86>
  }
}
    80002f56:	60e2                	ld	ra,24(sp)
    80002f58:	6442                	ld	s0,16(sp)
    80002f5a:	6105                	addi	sp,sp,32
    80002f5c:	8082                	ret
    80002f5e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002f60:	00003097          	auipc	ra,0x3
    80002f64:	78c080e7          	jalr	1932(ra) # 800066ec <plic_claim>
    80002f68:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002f6a:	47a9                	li	a5,10
    80002f6c:	00f50963          	beq	a0,a5,80002f7e <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002f70:	4785                	li	a5,1
    80002f72:	00f50b63          	beq	a0,a5,80002f88 <devintr+0x5a>
    return 1;
    80002f76:	4505                	li	a0,1
    } else if(irq){
    80002f78:	ec89                	bnez	s1,80002f92 <devintr+0x64>
    80002f7a:	64a2                	ld	s1,8(sp)
    80002f7c:	bfe9                	j	80002f56 <devintr+0x28>
      uartintr();
    80002f7e:	ffffe097          	auipc	ra,0xffffe
    80002f82:	a8e080e7          	jalr	-1394(ra) # 80000a0c <uartintr>
    if(irq)
    80002f86:	a839                	j	80002fa4 <devintr+0x76>
      virtio_disk_intr();
    80002f88:	00004097          	auipc	ra,0x4
    80002f8c:	c8e080e7          	jalr	-882(ra) # 80006c16 <virtio_disk_intr>
    if(irq)
    80002f90:	a811                	j	80002fa4 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002f92:	85a6                	mv	a1,s1
    80002f94:	00005517          	auipc	a0,0x5
    80002f98:	5d450513          	addi	a0,a0,1492 # 80008568 <__func__.1+0x560>
    80002f9c:	ffffd097          	auipc	ra,0xffffd
    80002fa0:	620080e7          	jalr	1568(ra) # 800005bc <printf>
      plic_complete(irq);
    80002fa4:	8526                	mv	a0,s1
    80002fa6:	00003097          	auipc	ra,0x3
    80002faa:	76a080e7          	jalr	1898(ra) # 80006710 <plic_complete>
    return 1;
    80002fae:	4505                	li	a0,1
    80002fb0:	64a2                	ld	s1,8(sp)
    80002fb2:	b755                	j	80002f56 <devintr+0x28>
    if(cpuid() == 0){
    80002fb4:	fffff097          	auipc	ra,0xfffff
    80002fb8:	fe0080e7          	jalr	-32(ra) # 80001f94 <cpuid>
    80002fbc:	c901                	beqz	a0,80002fcc <devintr+0x9e>
    asm volatile("csrr %0, sip" : "=r"(x));
    80002fbe:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002fc2:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip, %0" : : "r"(x));
    80002fc4:	14479073          	csrw	sip,a5
    return 2;
    80002fc8:	4509                	li	a0,2
    80002fca:	b771                	j	80002f56 <devintr+0x28>
      clockintr();
    80002fcc:	00000097          	auipc	ra,0x0
    80002fd0:	f1c080e7          	jalr	-228(ra) # 80002ee8 <clockintr>
    80002fd4:	b7ed                	j	80002fbe <devintr+0x90>
}
    80002fd6:	8082                	ret

0000000080002fd8 <usertrap>:
{
    80002fd8:	1101                	addi	sp,sp,-32
    80002fda:	ec06                	sd	ra,24(sp)
    80002fdc:	e822                	sd	s0,16(sp)
    80002fde:	e426                	sd	s1,8(sp)
    80002fe0:	e04a                	sd	s2,0(sp)
    80002fe2:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002fe4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002fe8:	1007f793          	andi	a5,a5,256
    80002fec:	e3b1                	bnez	a5,80003030 <usertrap+0x58>
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002fee:	00003797          	auipc	a5,0x3
    80002ff2:	5f278793          	addi	a5,a5,1522 # 800065e0 <kernelvec>
    80002ff6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ffa:	fffff097          	auipc	ra,0xfffff
    80002ffe:	fc6080e7          	jalr	-58(ra) # 80001fc0 <myproc>
    80003002:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003004:	6d3c                	ld	a5,88(a0)
    asm volatile("csrr %0, sepc" : "=r"(x));
    80003006:	14102773          	csrr	a4,sepc
    8000300a:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0, scause" : "=r"(x));
    8000300c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003010:	47a1                	li	a5,8
    80003012:	02f70763          	beq	a4,a5,80003040 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80003016:	00000097          	auipc	ra,0x0
    8000301a:	f18080e7          	jalr	-232(ra) # 80002f2e <devintr>
    8000301e:	892a                	mv	s2,a0
    80003020:	c151                	beqz	a0,800030a4 <usertrap+0xcc>
  if(killed(p))
    80003022:	8526                	mv	a0,s1
    80003024:	00000097          	auipc	ra,0x0
    80003028:	9e6080e7          	jalr	-1562(ra) # 80002a0a <killed>
    8000302c:	c929                	beqz	a0,8000307e <usertrap+0xa6>
    8000302e:	a099                	j	80003074 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80003030:	00005517          	auipc	a0,0x5
    80003034:	55850513          	addi	a0,a0,1368 # 80008588 <__func__.1+0x580>
    80003038:	ffffd097          	auipc	ra,0xffffd
    8000303c:	528080e7          	jalr	1320(ra) # 80000560 <panic>
    if(killed(p))
    80003040:	00000097          	auipc	ra,0x0
    80003044:	9ca080e7          	jalr	-1590(ra) # 80002a0a <killed>
    80003048:	e921                	bnez	a0,80003098 <usertrap+0xc0>
    p->trapframe->epc += 4;
    8000304a:	6cb8                	ld	a4,88(s1)
    8000304c:	6f1c                	ld	a5,24(a4)
    8000304e:	0791                	addi	a5,a5,4
    80003050:	ef1c                	sd	a5,24(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003052:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003056:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    8000305a:	10079073          	csrw	sstatus,a5
    syscall();
    8000305e:	00000097          	auipc	ra,0x0
    80003062:	2d4080e7          	jalr	724(ra) # 80003332 <syscall>
  if(killed(p))
    80003066:	8526                	mv	a0,s1
    80003068:	00000097          	auipc	ra,0x0
    8000306c:	9a2080e7          	jalr	-1630(ra) # 80002a0a <killed>
    80003070:	c911                	beqz	a0,80003084 <usertrap+0xac>
    80003072:	4901                	li	s2,0
    exit(-1);
    80003074:	557d                	li	a0,-1
    80003076:	00000097          	auipc	ra,0x0
    8000307a:	820080e7          	jalr	-2016(ra) # 80002896 <exit>
  if(which_dev == 2)
    8000307e:	4789                	li	a5,2
    80003080:	04f90f63          	beq	s2,a5,800030de <usertrap+0x106>
  usertrapret();
    80003084:	00000097          	auipc	ra,0x0
    80003088:	dce080e7          	jalr	-562(ra) # 80002e52 <usertrapret>
}
    8000308c:	60e2                	ld	ra,24(sp)
    8000308e:	6442                	ld	s0,16(sp)
    80003090:	64a2                	ld	s1,8(sp)
    80003092:	6902                	ld	s2,0(sp)
    80003094:	6105                	addi	sp,sp,32
    80003096:	8082                	ret
      exit(-1);
    80003098:	557d                	li	a0,-1
    8000309a:	fffff097          	auipc	ra,0xfffff
    8000309e:	7fc080e7          	jalr	2044(ra) # 80002896 <exit>
    800030a2:	b765                	j	8000304a <usertrap+0x72>
    asm volatile("csrr %0, scause" : "=r"(x));
    800030a4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800030a8:	5890                	lw	a2,48(s1)
    800030aa:	00005517          	auipc	a0,0x5
    800030ae:	4fe50513          	addi	a0,a0,1278 # 800085a8 <__func__.1+0x5a0>
    800030b2:	ffffd097          	auipc	ra,0xffffd
    800030b6:	50a080e7          	jalr	1290(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    800030ba:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    800030be:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030c2:	00005517          	auipc	a0,0x5
    800030c6:	51650513          	addi	a0,a0,1302 # 800085d8 <__func__.1+0x5d0>
    800030ca:	ffffd097          	auipc	ra,0xffffd
    800030ce:	4f2080e7          	jalr	1266(ra) # 800005bc <printf>
    setkilled(p);
    800030d2:	8526                	mv	a0,s1
    800030d4:	00000097          	auipc	ra,0x0
    800030d8:	90a080e7          	jalr	-1782(ra) # 800029de <setkilled>
    800030dc:	b769                	j	80003066 <usertrap+0x8e>
    yield();
    800030de:	fffff097          	auipc	ra,0xfffff
    800030e2:	648080e7          	jalr	1608(ra) # 80002726 <yield>
    800030e6:	bf79                	j	80003084 <usertrap+0xac>

00000000800030e8 <kerneltrap>:
{
    800030e8:	7179                	addi	sp,sp,-48
    800030ea:	f406                	sd	ra,40(sp)
    800030ec:	f022                	sd	s0,32(sp)
    800030ee:	ec26                	sd	s1,24(sp)
    800030f0:	e84a                	sd	s2,16(sp)
    800030f2:	e44e                	sd	s3,8(sp)
    800030f4:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sepc" : "=r"(x));
    800030f6:	14102973          	csrr	s2,sepc
    asm volatile("csrr %0, sstatus" : "=r"(x));
    800030fa:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0, scause" : "=r"(x));
    800030fe:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003102:	1004f793          	andi	a5,s1,256
    80003106:	cb85                	beqz	a5,80003136 <kerneltrap+0x4e>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003108:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    8000310c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000310e:	ef85                	bnez	a5,80003146 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003110:	00000097          	auipc	ra,0x0
    80003114:	e1e080e7          	jalr	-482(ra) # 80002f2e <devintr>
    80003118:	cd1d                	beqz	a0,80003156 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000311a:	4789                	li	a5,2
    8000311c:	06f50a63          	beq	a0,a5,80003190 <kerneltrap+0xa8>
    asm volatile("csrw sepc, %0" : : "r"(x));
    80003120:	14191073          	csrw	sepc,s2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80003124:	10049073          	csrw	sstatus,s1
}
    80003128:	70a2                	ld	ra,40(sp)
    8000312a:	7402                	ld	s0,32(sp)
    8000312c:	64e2                	ld	s1,24(sp)
    8000312e:	6942                	ld	s2,16(sp)
    80003130:	69a2                	ld	s3,8(sp)
    80003132:	6145                	addi	sp,sp,48
    80003134:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003136:	00005517          	auipc	a0,0x5
    8000313a:	4c250513          	addi	a0,a0,1218 # 800085f8 <__func__.1+0x5f0>
    8000313e:	ffffd097          	auipc	ra,0xffffd
    80003142:	422080e7          	jalr	1058(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80003146:	00005517          	auipc	a0,0x5
    8000314a:	4da50513          	addi	a0,a0,1242 # 80008620 <__func__.1+0x618>
    8000314e:	ffffd097          	auipc	ra,0xffffd
    80003152:	412080e7          	jalr	1042(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80003156:	85ce                	mv	a1,s3
    80003158:	00005517          	auipc	a0,0x5
    8000315c:	4e850513          	addi	a0,a0,1256 # 80008640 <__func__.1+0x638>
    80003160:	ffffd097          	auipc	ra,0xffffd
    80003164:	45c080e7          	jalr	1116(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80003168:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    8000316c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003170:	00005517          	auipc	a0,0x5
    80003174:	4e050513          	addi	a0,a0,1248 # 80008650 <__func__.1+0x648>
    80003178:	ffffd097          	auipc	ra,0xffffd
    8000317c:	444080e7          	jalr	1092(ra) # 800005bc <printf>
    panic("kerneltrap");
    80003180:	00005517          	auipc	a0,0x5
    80003184:	4e850513          	addi	a0,a0,1256 # 80008668 <__func__.1+0x660>
    80003188:	ffffd097          	auipc	ra,0xffffd
    8000318c:	3d8080e7          	jalr	984(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003190:	fffff097          	auipc	ra,0xfffff
    80003194:	e30080e7          	jalr	-464(ra) # 80001fc0 <myproc>
    80003198:	d541                	beqz	a0,80003120 <kerneltrap+0x38>
    8000319a:	fffff097          	auipc	ra,0xfffff
    8000319e:	e26080e7          	jalr	-474(ra) # 80001fc0 <myproc>
    800031a2:	4d18                	lw	a4,24(a0)
    800031a4:	4791                	li	a5,4
    800031a6:	f6f71de3          	bne	a4,a5,80003120 <kerneltrap+0x38>
    yield();
    800031aa:	fffff097          	auipc	ra,0xfffff
    800031ae:	57c080e7          	jalr	1404(ra) # 80002726 <yield>
    800031b2:	b7bd                	j	80003120 <kerneltrap+0x38>

00000000800031b4 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    800031b4:	1101                	addi	sp,sp,-32
    800031b6:	ec06                	sd	ra,24(sp)
    800031b8:	e822                	sd	s0,16(sp)
    800031ba:	e426                	sd	s1,8(sp)
    800031bc:	1000                	addi	s0,sp,32
    800031be:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    800031c0:	fffff097          	auipc	ra,0xfffff
    800031c4:	e00080e7          	jalr	-512(ra) # 80001fc0 <myproc>
    switch (n)
    800031c8:	4795                	li	a5,5
    800031ca:	0497e163          	bltu	a5,s1,8000320c <argraw+0x58>
    800031ce:	048a                	slli	s1,s1,0x2
    800031d0:	00006717          	auipc	a4,0x6
    800031d4:	86070713          	addi	a4,a4,-1952 # 80008a30 <states.0+0x30>
    800031d8:	94ba                	add	s1,s1,a4
    800031da:	409c                	lw	a5,0(s1)
    800031dc:	97ba                	add	a5,a5,a4
    800031de:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    800031e0:	6d3c                	ld	a5,88(a0)
    800031e2:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    800031e4:	60e2                	ld	ra,24(sp)
    800031e6:	6442                	ld	s0,16(sp)
    800031e8:	64a2                	ld	s1,8(sp)
    800031ea:	6105                	addi	sp,sp,32
    800031ec:	8082                	ret
        return p->trapframe->a1;
    800031ee:	6d3c                	ld	a5,88(a0)
    800031f0:	7fa8                	ld	a0,120(a5)
    800031f2:	bfcd                	j	800031e4 <argraw+0x30>
        return p->trapframe->a2;
    800031f4:	6d3c                	ld	a5,88(a0)
    800031f6:	63c8                	ld	a0,128(a5)
    800031f8:	b7f5                	j	800031e4 <argraw+0x30>
        return p->trapframe->a3;
    800031fa:	6d3c                	ld	a5,88(a0)
    800031fc:	67c8                	ld	a0,136(a5)
    800031fe:	b7dd                	j	800031e4 <argraw+0x30>
        return p->trapframe->a4;
    80003200:	6d3c                	ld	a5,88(a0)
    80003202:	6bc8                	ld	a0,144(a5)
    80003204:	b7c5                	j	800031e4 <argraw+0x30>
        return p->trapframe->a5;
    80003206:	6d3c                	ld	a5,88(a0)
    80003208:	6fc8                	ld	a0,152(a5)
    8000320a:	bfe9                	j	800031e4 <argraw+0x30>
    panic("argraw");
    8000320c:	00005517          	auipc	a0,0x5
    80003210:	46c50513          	addi	a0,a0,1132 # 80008678 <__func__.1+0x670>
    80003214:	ffffd097          	auipc	ra,0xffffd
    80003218:	34c080e7          	jalr	844(ra) # 80000560 <panic>

000000008000321c <fetchaddr>:
{
    8000321c:	1101                	addi	sp,sp,-32
    8000321e:	ec06                	sd	ra,24(sp)
    80003220:	e822                	sd	s0,16(sp)
    80003222:	e426                	sd	s1,8(sp)
    80003224:	e04a                	sd	s2,0(sp)
    80003226:	1000                	addi	s0,sp,32
    80003228:	84aa                	mv	s1,a0
    8000322a:	892e                	mv	s2,a1
    struct proc *p = myproc();
    8000322c:	fffff097          	auipc	ra,0xfffff
    80003230:	d94080e7          	jalr	-620(ra) # 80001fc0 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003234:	653c                	ld	a5,72(a0)
    80003236:	02f4f863          	bgeu	s1,a5,80003266 <fetchaddr+0x4a>
    8000323a:	00848713          	addi	a4,s1,8
    8000323e:	02e7e663          	bltu	a5,a4,8000326a <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003242:	46a1                	li	a3,8
    80003244:	8626                	mv	a2,s1
    80003246:	85ca                	mv	a1,s2
    80003248:	6928                	ld	a0,80(a0)
    8000324a:	fffff097          	auipc	ra,0xfffff
    8000324e:	8d0080e7          	jalr	-1840(ra) # 80001b1a <copyin>
    80003252:	00a03533          	snez	a0,a0
    80003256:	40a00533          	neg	a0,a0
}
    8000325a:	60e2                	ld	ra,24(sp)
    8000325c:	6442                	ld	s0,16(sp)
    8000325e:	64a2                	ld	s1,8(sp)
    80003260:	6902                	ld	s2,0(sp)
    80003262:	6105                	addi	sp,sp,32
    80003264:	8082                	ret
        return -1;
    80003266:	557d                	li	a0,-1
    80003268:	bfcd                	j	8000325a <fetchaddr+0x3e>
    8000326a:	557d                	li	a0,-1
    8000326c:	b7fd                	j	8000325a <fetchaddr+0x3e>

000000008000326e <fetchstr>:
{
    8000326e:	7179                	addi	sp,sp,-48
    80003270:	f406                	sd	ra,40(sp)
    80003272:	f022                	sd	s0,32(sp)
    80003274:	ec26                	sd	s1,24(sp)
    80003276:	e84a                	sd	s2,16(sp)
    80003278:	e44e                	sd	s3,8(sp)
    8000327a:	1800                	addi	s0,sp,48
    8000327c:	892a                	mv	s2,a0
    8000327e:	84ae                	mv	s1,a1
    80003280:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80003282:	fffff097          	auipc	ra,0xfffff
    80003286:	d3e080e7          	jalr	-706(ra) # 80001fc0 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    8000328a:	86ce                	mv	a3,s3
    8000328c:	864a                	mv	a2,s2
    8000328e:	85a6                	mv	a1,s1
    80003290:	6928                	ld	a0,80(a0)
    80003292:	fffff097          	auipc	ra,0xfffff
    80003296:	916080e7          	jalr	-1770(ra) # 80001ba8 <copyinstr>
    8000329a:	00054e63          	bltz	a0,800032b6 <fetchstr+0x48>
    return strlen(buf);
    8000329e:	8526                	mv	a0,s1
    800032a0:	ffffe097          	auipc	ra,0xffffe
    800032a4:	cda080e7          	jalr	-806(ra) # 80000f7a <strlen>
}
    800032a8:	70a2                	ld	ra,40(sp)
    800032aa:	7402                	ld	s0,32(sp)
    800032ac:	64e2                	ld	s1,24(sp)
    800032ae:	6942                	ld	s2,16(sp)
    800032b0:	69a2                	ld	s3,8(sp)
    800032b2:	6145                	addi	sp,sp,48
    800032b4:	8082                	ret
        return -1;
    800032b6:	557d                	li	a0,-1
    800032b8:	bfc5                	j	800032a8 <fetchstr+0x3a>

00000000800032ba <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	e426                	sd	s1,8(sp)
    800032c2:	1000                	addi	s0,sp,32
    800032c4:	84ae                	mv	s1,a1
    *ip = argraw(n);
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	eee080e7          	jalr	-274(ra) # 800031b4 <argraw>
    800032ce:	c088                	sw	a0,0(s1)
}
    800032d0:	60e2                	ld	ra,24(sp)
    800032d2:	6442                	ld	s0,16(sp)
    800032d4:	64a2                	ld	s1,8(sp)
    800032d6:	6105                	addi	sp,sp,32
    800032d8:	8082                	ret

00000000800032da <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    800032da:	1101                	addi	sp,sp,-32
    800032dc:	ec06                	sd	ra,24(sp)
    800032de:	e822                	sd	s0,16(sp)
    800032e0:	e426                	sd	s1,8(sp)
    800032e2:	1000                	addi	s0,sp,32
    800032e4:	84ae                	mv	s1,a1
    *ip = argraw(n);
    800032e6:	00000097          	auipc	ra,0x0
    800032ea:	ece080e7          	jalr	-306(ra) # 800031b4 <argraw>
    800032ee:	e088                	sd	a0,0(s1)
}
    800032f0:	60e2                	ld	ra,24(sp)
    800032f2:	6442                	ld	s0,16(sp)
    800032f4:	64a2                	ld	s1,8(sp)
    800032f6:	6105                	addi	sp,sp,32
    800032f8:	8082                	ret

00000000800032fa <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    800032fa:	7179                	addi	sp,sp,-48
    800032fc:	f406                	sd	ra,40(sp)
    800032fe:	f022                	sd	s0,32(sp)
    80003300:	ec26                	sd	s1,24(sp)
    80003302:	e84a                	sd	s2,16(sp)
    80003304:	1800                	addi	s0,sp,48
    80003306:	84ae                	mv	s1,a1
    80003308:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    8000330a:	fd840593          	addi	a1,s0,-40
    8000330e:	00000097          	auipc	ra,0x0
    80003312:	fcc080e7          	jalr	-52(ra) # 800032da <argaddr>
    return fetchstr(addr, buf, max);
    80003316:	864a                	mv	a2,s2
    80003318:	85a6                	mv	a1,s1
    8000331a:	fd843503          	ld	a0,-40(s0)
    8000331e:	00000097          	auipc	ra,0x0
    80003322:	f50080e7          	jalr	-176(ra) # 8000326e <fetchstr>
}
    80003326:	70a2                	ld	ra,40(sp)
    80003328:	7402                	ld	s0,32(sp)
    8000332a:	64e2                	ld	s1,24(sp)
    8000332c:	6942                	ld	s2,16(sp)
    8000332e:	6145                	addi	sp,sp,48
    80003330:	8082                	ret

0000000080003332 <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    80003332:	1101                	addi	sp,sp,-32
    80003334:	ec06                	sd	ra,24(sp)
    80003336:	e822                	sd	s0,16(sp)
    80003338:	e426                	sd	s1,8(sp)
    8000333a:	e04a                	sd	s2,0(sp)
    8000333c:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    8000333e:	fffff097          	auipc	ra,0xfffff
    80003342:	c82080e7          	jalr	-894(ra) # 80001fc0 <myproc>
    80003346:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80003348:	05853903          	ld	s2,88(a0)
    8000334c:	0a893783          	ld	a5,168(s2)
    80003350:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80003354:	37fd                	addiw	a5,a5,-1
    80003356:	4765                	li	a4,25
    80003358:	00f76f63          	bltu	a4,a5,80003376 <syscall+0x44>
    8000335c:	00369713          	slli	a4,a3,0x3
    80003360:	00005797          	auipc	a5,0x5
    80003364:	6e878793          	addi	a5,a5,1768 # 80008a48 <syscalls>
    80003368:	97ba                	add	a5,a5,a4
    8000336a:	639c                	ld	a5,0(a5)
    8000336c:	c789                	beqz	a5,80003376 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    8000336e:	9782                	jalr	a5
    80003370:	06a93823          	sd	a0,112(s2)
    80003374:	a839                	j	80003392 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    80003376:	15848613          	addi	a2,s1,344
    8000337a:	588c                	lw	a1,48(s1)
    8000337c:	00005517          	auipc	a0,0x5
    80003380:	30450513          	addi	a0,a0,772 # 80008680 <__func__.1+0x678>
    80003384:	ffffd097          	auipc	ra,0xffffd
    80003388:	238080e7          	jalr	568(ra) # 800005bc <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    8000338c:	6cbc                	ld	a5,88(s1)
    8000338e:	577d                	li	a4,-1
    80003390:	fbb8                	sd	a4,112(a5)
    }
}
    80003392:	60e2                	ld	ra,24(sp)
    80003394:	6442                	ld	s0,16(sp)
    80003396:	64a2                	ld	s1,8(sp)
    80003398:	6902                	ld	s2,0(sp)
    8000339a:	6105                	addi	sp,sp,32
    8000339c:	8082                	ret

000000008000339e <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    8000339e:	1101                	addi	sp,sp,-32
    800033a0:	ec06                	sd	ra,24(sp)
    800033a2:	e822                	sd	s0,16(sp)
    800033a4:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    800033a6:	fec40593          	addi	a1,s0,-20
    800033aa:	4501                	li	a0,0
    800033ac:	00000097          	auipc	ra,0x0
    800033b0:	f0e080e7          	jalr	-242(ra) # 800032ba <argint>
    exit(n);
    800033b4:	fec42503          	lw	a0,-20(s0)
    800033b8:	fffff097          	auipc	ra,0xfffff
    800033bc:	4de080e7          	jalr	1246(ra) # 80002896 <exit>
    return 0; // not reached
}
    800033c0:	4501                	li	a0,0
    800033c2:	60e2                	ld	ra,24(sp)
    800033c4:	6442                	ld	s0,16(sp)
    800033c6:	6105                	addi	sp,sp,32
    800033c8:	8082                	ret

00000000800033ca <sys_getpid>:

uint64
sys_getpid(void)
{
    800033ca:	1141                	addi	sp,sp,-16
    800033cc:	e406                	sd	ra,8(sp)
    800033ce:	e022                	sd	s0,0(sp)
    800033d0:	0800                	addi	s0,sp,16
    return myproc()->pid;
    800033d2:	fffff097          	auipc	ra,0xfffff
    800033d6:	bee080e7          	jalr	-1042(ra) # 80001fc0 <myproc>
}
    800033da:	5908                	lw	a0,48(a0)
    800033dc:	60a2                	ld	ra,8(sp)
    800033de:	6402                	ld	s0,0(sp)
    800033e0:	0141                	addi	sp,sp,16
    800033e2:	8082                	ret

00000000800033e4 <sys_fork>:

uint64
sys_fork(void)
{
    800033e4:	1141                	addi	sp,sp,-16
    800033e6:	e406                	sd	ra,8(sp)
    800033e8:	e022                	sd	s0,0(sp)
    800033ea:	0800                	addi	s0,sp,16
    return fork();
    800033ec:	fffff097          	auipc	ra,0xfffff
    800033f0:	11c080e7          	jalr	284(ra) # 80002508 <fork>
}
    800033f4:	60a2                	ld	ra,8(sp)
    800033f6:	6402                	ld	s0,0(sp)
    800033f8:	0141                	addi	sp,sp,16
    800033fa:	8082                	ret

00000000800033fc <sys_wait>:

uint64
sys_wait(void)
{
    800033fc:	1101                	addi	sp,sp,-32
    800033fe:	ec06                	sd	ra,24(sp)
    80003400:	e822                	sd	s0,16(sp)
    80003402:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003404:	fe840593          	addi	a1,s0,-24
    80003408:	4501                	li	a0,0
    8000340a:	00000097          	auipc	ra,0x0
    8000340e:	ed0080e7          	jalr	-304(ra) # 800032da <argaddr>
    return wait(p);
    80003412:	fe843503          	ld	a0,-24(s0)
    80003416:	fffff097          	auipc	ra,0xfffff
    8000341a:	626080e7          	jalr	1574(ra) # 80002a3c <wait>
}
    8000341e:	60e2                	ld	ra,24(sp)
    80003420:	6442                	ld	s0,16(sp)
    80003422:	6105                	addi	sp,sp,32
    80003424:	8082                	ret

0000000080003426 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003426:	7179                	addi	sp,sp,-48
    80003428:	f406                	sd	ra,40(sp)
    8000342a:	f022                	sd	s0,32(sp)
    8000342c:	ec26                	sd	s1,24(sp)
    8000342e:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    80003430:	fdc40593          	addi	a1,s0,-36
    80003434:	4501                	li	a0,0
    80003436:	00000097          	auipc	ra,0x0
    8000343a:	e84080e7          	jalr	-380(ra) # 800032ba <argint>
    addr = myproc()->sz;
    8000343e:	fffff097          	auipc	ra,0xfffff
    80003442:	b82080e7          	jalr	-1150(ra) # 80001fc0 <myproc>
    80003446:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    80003448:	fdc42503          	lw	a0,-36(s0)
    8000344c:	fffff097          	auipc	ra,0xfffff
    80003450:	ec8080e7          	jalr	-312(ra) # 80002314 <growproc>
    80003454:	00054863          	bltz	a0,80003464 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    80003458:	8526                	mv	a0,s1
    8000345a:	70a2                	ld	ra,40(sp)
    8000345c:	7402                	ld	s0,32(sp)
    8000345e:	64e2                	ld	s1,24(sp)
    80003460:	6145                	addi	sp,sp,48
    80003462:	8082                	ret
        return -1;
    80003464:	54fd                	li	s1,-1
    80003466:	bfcd                	j	80003458 <sys_sbrk+0x32>

0000000080003468 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003468:	7139                	addi	sp,sp,-64
    8000346a:	fc06                	sd	ra,56(sp)
    8000346c:	f822                	sd	s0,48(sp)
    8000346e:	f04a                	sd	s2,32(sp)
    80003470:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    80003472:	fcc40593          	addi	a1,s0,-52
    80003476:	4501                	li	a0,0
    80003478:	00000097          	auipc	ra,0x0
    8000347c:	e42080e7          	jalr	-446(ra) # 800032ba <argint>
    acquire(&tickslock);
    80003480:	00096517          	auipc	a0,0x96
    80003484:	43050513          	addi	a0,a0,1072 # 800998b0 <tickslock>
    80003488:	ffffe097          	auipc	ra,0xffffe
    8000348c:	882080e7          	jalr	-1918(ra) # 80000d0a <acquire>
    ticks0 = ticks;
    80003490:	00008917          	auipc	s2,0x8
    80003494:	38092903          	lw	s2,896(s2) # 8000b810 <ticks>
    while (ticks - ticks0 < n)
    80003498:	fcc42783          	lw	a5,-52(s0)
    8000349c:	c3b9                	beqz	a5,800034e2 <sys_sleep+0x7a>
    8000349e:	f426                	sd	s1,40(sp)
    800034a0:	ec4e                	sd	s3,24(sp)
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    800034a2:	00096997          	auipc	s3,0x96
    800034a6:	40e98993          	addi	s3,s3,1038 # 800998b0 <tickslock>
    800034aa:	00008497          	auipc	s1,0x8
    800034ae:	36648493          	addi	s1,s1,870 # 8000b810 <ticks>
        if (killed(myproc()))
    800034b2:	fffff097          	auipc	ra,0xfffff
    800034b6:	b0e080e7          	jalr	-1266(ra) # 80001fc0 <myproc>
    800034ba:	fffff097          	auipc	ra,0xfffff
    800034be:	550080e7          	jalr	1360(ra) # 80002a0a <killed>
    800034c2:	ed15                	bnez	a0,800034fe <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    800034c4:	85ce                	mv	a1,s3
    800034c6:	8526                	mv	a0,s1
    800034c8:	fffff097          	auipc	ra,0xfffff
    800034cc:	29a080e7          	jalr	666(ra) # 80002762 <sleep>
    while (ticks - ticks0 < n)
    800034d0:	409c                	lw	a5,0(s1)
    800034d2:	412787bb          	subw	a5,a5,s2
    800034d6:	fcc42703          	lw	a4,-52(s0)
    800034da:	fce7ece3          	bltu	a5,a4,800034b2 <sys_sleep+0x4a>
    800034de:	74a2                	ld	s1,40(sp)
    800034e0:	69e2                	ld	s3,24(sp)
    }
    release(&tickslock);
    800034e2:	00096517          	auipc	a0,0x96
    800034e6:	3ce50513          	addi	a0,a0,974 # 800998b0 <tickslock>
    800034ea:	ffffe097          	auipc	ra,0xffffe
    800034ee:	8d4080e7          	jalr	-1836(ra) # 80000dbe <release>
    return 0;
    800034f2:	4501                	li	a0,0
}
    800034f4:	70e2                	ld	ra,56(sp)
    800034f6:	7442                	ld	s0,48(sp)
    800034f8:	7902                	ld	s2,32(sp)
    800034fa:	6121                	addi	sp,sp,64
    800034fc:	8082                	ret
            release(&tickslock);
    800034fe:	00096517          	auipc	a0,0x96
    80003502:	3b250513          	addi	a0,a0,946 # 800998b0 <tickslock>
    80003506:	ffffe097          	auipc	ra,0xffffe
    8000350a:	8b8080e7          	jalr	-1864(ra) # 80000dbe <release>
            return -1;
    8000350e:	557d                	li	a0,-1
    80003510:	74a2                	ld	s1,40(sp)
    80003512:	69e2                	ld	s3,24(sp)
    80003514:	b7c5                	j	800034f4 <sys_sleep+0x8c>

0000000080003516 <sys_kill>:

uint64
sys_kill(void)
{
    80003516:	1101                	addi	sp,sp,-32
    80003518:	ec06                	sd	ra,24(sp)
    8000351a:	e822                	sd	s0,16(sp)
    8000351c:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    8000351e:	fec40593          	addi	a1,s0,-20
    80003522:	4501                	li	a0,0
    80003524:	00000097          	auipc	ra,0x0
    80003528:	d96080e7          	jalr	-618(ra) # 800032ba <argint>
    return kill(pid);
    8000352c:	fec42503          	lw	a0,-20(s0)
    80003530:	fffff097          	auipc	ra,0xfffff
    80003534:	43c080e7          	jalr	1084(ra) # 8000296c <kill>
}
    80003538:	60e2                	ld	ra,24(sp)
    8000353a:	6442                	ld	s0,16(sp)
    8000353c:	6105                	addi	sp,sp,32
    8000353e:	8082                	ret

0000000080003540 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003540:	1101                	addi	sp,sp,-32
    80003542:	ec06                	sd	ra,24(sp)
    80003544:	e822                	sd	s0,16(sp)
    80003546:	e426                	sd	s1,8(sp)
    80003548:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    8000354a:	00096517          	auipc	a0,0x96
    8000354e:	36650513          	addi	a0,a0,870 # 800998b0 <tickslock>
    80003552:	ffffd097          	auipc	ra,0xffffd
    80003556:	7b8080e7          	jalr	1976(ra) # 80000d0a <acquire>
    xticks = ticks;
    8000355a:	00008497          	auipc	s1,0x8
    8000355e:	2b64a483          	lw	s1,694(s1) # 8000b810 <ticks>
    release(&tickslock);
    80003562:	00096517          	auipc	a0,0x96
    80003566:	34e50513          	addi	a0,a0,846 # 800998b0 <tickslock>
    8000356a:	ffffe097          	auipc	ra,0xffffe
    8000356e:	854080e7          	jalr	-1964(ra) # 80000dbe <release>
    return xticks;
}
    80003572:	02049513          	slli	a0,s1,0x20
    80003576:	9101                	srli	a0,a0,0x20
    80003578:	60e2                	ld	ra,24(sp)
    8000357a:	6442                	ld	s0,16(sp)
    8000357c:	64a2                	ld	s1,8(sp)
    8000357e:	6105                	addi	sp,sp,32
    80003580:	8082                	ret

0000000080003582 <sys_ps>:

void *
sys_ps(void)
{
    80003582:	1101                	addi	sp,sp,-32
    80003584:	ec06                	sd	ra,24(sp)
    80003586:	e822                	sd	s0,16(sp)
    80003588:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    8000358a:	fe042623          	sw	zero,-20(s0)
    8000358e:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    80003592:	fec40593          	addi	a1,s0,-20
    80003596:	4501                	li	a0,0
    80003598:	00000097          	auipc	ra,0x0
    8000359c:	d22080e7          	jalr	-734(ra) # 800032ba <argint>
    argint(1, &count);
    800035a0:	fe840593          	addi	a1,s0,-24
    800035a4:	4505                	li	a0,1
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	d14080e7          	jalr	-748(ra) # 800032ba <argint>
    return ps((uint8)start, (uint8)count);
    800035ae:	fe844583          	lbu	a1,-24(s0)
    800035b2:	fec44503          	lbu	a0,-20(s0)
    800035b6:	fffff097          	auipc	ra,0xfffff
    800035ba:	dba080e7          	jalr	-582(ra) # 80002370 <ps>
}
    800035be:	60e2                	ld	ra,24(sp)
    800035c0:	6442                	ld	s0,16(sp)
    800035c2:	6105                	addi	sp,sp,32
    800035c4:	8082                	ret

00000000800035c6 <sys_schedls>:

uint64 sys_schedls(void)
{
    800035c6:	1141                	addi	sp,sp,-16
    800035c8:	e406                	sd	ra,8(sp)
    800035ca:	e022                	sd	s0,0(sp)
    800035cc:	0800                	addi	s0,sp,16
    schedls();
    800035ce:	fffff097          	auipc	ra,0xfffff
    800035d2:	6f8080e7          	jalr	1784(ra) # 80002cc6 <schedls>
    return 0;
}
    800035d6:	4501                	li	a0,0
    800035d8:	60a2                	ld	ra,8(sp)
    800035da:	6402                	ld	s0,0(sp)
    800035dc:	0141                	addi	sp,sp,16
    800035de:	8082                	ret

00000000800035e0 <sys_schedset>:

uint64 sys_schedset(void)
{
    800035e0:	1101                	addi	sp,sp,-32
    800035e2:	ec06                	sd	ra,24(sp)
    800035e4:	e822                	sd	s0,16(sp)
    800035e6:	1000                	addi	s0,sp,32
    int id = 0;
    800035e8:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    800035ec:	fec40593          	addi	a1,s0,-20
    800035f0:	4501                	li	a0,0
    800035f2:	00000097          	auipc	ra,0x0
    800035f6:	cc8080e7          	jalr	-824(ra) # 800032ba <argint>
    schedset(id - 1);
    800035fa:	fec42503          	lw	a0,-20(s0)
    800035fe:	357d                	addiw	a0,a0,-1
    80003600:	fffff097          	auipc	ra,0xfffff
    80003604:	75c080e7          	jalr	1884(ra) # 80002d5c <schedset>
    return 0;
}
    80003608:	4501                	li	a0,0
    8000360a:	60e2                	ld	ra,24(sp)
    8000360c:	6442                	ld	s0,16(sp)
    8000360e:	6105                	addi	sp,sp,32
    80003610:	8082                	ret

0000000080003612 <sys_va2pa>:

uint64 sys_va2pa(void)
{
    80003612:	7179                	addi	sp,sp,-48
    80003614:	f406                	sd	ra,40(sp)
    80003616:	f022                	sd	s0,32(sp)
    80003618:	1800                	addi	s0,sp,48
    struct proc* proc;
    uint64 va, pid = 0;
    8000361a:	fc043823          	sd	zero,-48(s0)

    argaddr(0, &va);
    8000361e:	fd840593          	addi	a1,s0,-40
    80003622:	4501                	li	a0,0
    80003624:	00000097          	auipc	ra,0x0
    80003628:	cb6080e7          	jalr	-842(ra) # 800032da <argaddr>
    argaddr(1, &pid);
    8000362c:	fd040593          	addi	a1,s0,-48
    80003630:	4505                	li	a0,1
    80003632:	00000097          	auipc	ra,0x0
    80003636:	ca8080e7          	jalr	-856(ra) # 800032da <argaddr>

    if (pid == 0){
    8000363a:	fd043783          	ld	a5,-48(s0)
    8000363e:	cf89                	beqz	a5,80003658 <sys_va2pa+0x46>
        acquire(&proc->lock);
        pid = proc->pid;
        release(&proc->lock);
    }
    
    return va2pa(va, pid);
    80003640:	fd043583          	ld	a1,-48(s0)
    80003644:	fd843503          	ld	a0,-40(s0)
    80003648:	fffff097          	auipc	ra,0xfffff
    8000364c:	876080e7          	jalr	-1930(ra) # 80001ebe <va2pa>
}
    80003650:	70a2                	ld	ra,40(sp)
    80003652:	7402                	ld	s0,32(sp)
    80003654:	6145                	addi	sp,sp,48
    80003656:	8082                	ret
    80003658:	ec26                	sd	s1,24(sp)
        proc = myproc();
    8000365a:	fffff097          	auipc	ra,0xfffff
    8000365e:	966080e7          	jalr	-1690(ra) # 80001fc0 <myproc>
    80003662:	84aa                	mv	s1,a0
        acquire(&proc->lock);
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	6a6080e7          	jalr	1702(ra) # 80000d0a <acquire>
        pid = proc->pid;
    8000366c:	589c                	lw	a5,48(s1)
    8000366e:	fcf43823          	sd	a5,-48(s0)
        release(&proc->lock);
    80003672:	8526                	mv	a0,s1
    80003674:	ffffd097          	auipc	ra,0xffffd
    80003678:	74a080e7          	jalr	1866(ra) # 80000dbe <release>
    8000367c:	64e2                	ld	s1,24(sp)
    8000367e:	b7c9                	j	80003640 <sys_va2pa+0x2e>

0000000080003680 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    80003680:	1141                	addi	sp,sp,-16
    80003682:	e406                	sd	ra,8(sp)
    80003684:	e022                	sd	s0,0(sp)
    80003686:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    80003688:	00008597          	auipc	a1,0x8
    8000368c:	1605b583          	ld	a1,352(a1) # 8000b7e8 <FREE_PAGES>
    80003690:	00005517          	auipc	a0,0x5
    80003694:	01050513          	addi	a0,a0,16 # 800086a0 <__func__.1+0x698>
    80003698:	ffffd097          	auipc	ra,0xffffd
    8000369c:	f24080e7          	jalr	-220(ra) # 800005bc <printf>
    return 0;
    800036a0:	4501                	li	a0,0
    800036a2:	60a2                	ld	ra,8(sp)
    800036a4:	6402                	ld	s0,0(sp)
    800036a6:	0141                	addi	sp,sp,16
    800036a8:	8082                	ret

00000000800036aa <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800036aa:	7179                	addi	sp,sp,-48
    800036ac:	f406                	sd	ra,40(sp)
    800036ae:	f022                	sd	s0,32(sp)
    800036b0:	ec26                	sd	s1,24(sp)
    800036b2:	e84a                	sd	s2,16(sp)
    800036b4:	e44e                	sd	s3,8(sp)
    800036b6:	e052                	sd	s4,0(sp)
    800036b8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800036ba:	00005597          	auipc	a1,0x5
    800036be:	fee58593          	addi	a1,a1,-18 # 800086a8 <__func__.1+0x6a0>
    800036c2:	00096517          	auipc	a0,0x96
    800036c6:	20650513          	addi	a0,a0,518 # 800998c8 <bcache>
    800036ca:	ffffd097          	auipc	ra,0xffffd
    800036ce:	5b0080e7          	jalr	1456(ra) # 80000c7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800036d2:	0009e797          	auipc	a5,0x9e
    800036d6:	1f678793          	addi	a5,a5,502 # 800a18c8 <bcache+0x8000>
    800036da:	0009e717          	auipc	a4,0x9e
    800036de:	45670713          	addi	a4,a4,1110 # 800a1b30 <bcache+0x8268>
    800036e2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800036e6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036ea:	00096497          	auipc	s1,0x96
    800036ee:	1f648493          	addi	s1,s1,502 # 800998e0 <bcache+0x18>
    b->next = bcache.head.next;
    800036f2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800036f4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800036f6:	00005a17          	auipc	s4,0x5
    800036fa:	fbaa0a13          	addi	s4,s4,-70 # 800086b0 <__func__.1+0x6a8>
    b->next = bcache.head.next;
    800036fe:	2b893783          	ld	a5,696(s2)
    80003702:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003704:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003708:	85d2                	mv	a1,s4
    8000370a:	01048513          	addi	a0,s1,16
    8000370e:	00001097          	auipc	ra,0x1
    80003712:	4e8080e7          	jalr	1256(ra) # 80004bf6 <initsleeplock>
    bcache.head.next->prev = b;
    80003716:	2b893783          	ld	a5,696(s2)
    8000371a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000371c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003720:	45848493          	addi	s1,s1,1112
    80003724:	fd349de3          	bne	s1,s3,800036fe <binit+0x54>
  }
}
    80003728:	70a2                	ld	ra,40(sp)
    8000372a:	7402                	ld	s0,32(sp)
    8000372c:	64e2                	ld	s1,24(sp)
    8000372e:	6942                	ld	s2,16(sp)
    80003730:	69a2                	ld	s3,8(sp)
    80003732:	6a02                	ld	s4,0(sp)
    80003734:	6145                	addi	sp,sp,48
    80003736:	8082                	ret

0000000080003738 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003738:	7179                	addi	sp,sp,-48
    8000373a:	f406                	sd	ra,40(sp)
    8000373c:	f022                	sd	s0,32(sp)
    8000373e:	ec26                	sd	s1,24(sp)
    80003740:	e84a                	sd	s2,16(sp)
    80003742:	e44e                	sd	s3,8(sp)
    80003744:	1800                	addi	s0,sp,48
    80003746:	892a                	mv	s2,a0
    80003748:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000374a:	00096517          	auipc	a0,0x96
    8000374e:	17e50513          	addi	a0,a0,382 # 800998c8 <bcache>
    80003752:	ffffd097          	auipc	ra,0xffffd
    80003756:	5b8080e7          	jalr	1464(ra) # 80000d0a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000375a:	0009e497          	auipc	s1,0x9e
    8000375e:	4264b483          	ld	s1,1062(s1) # 800a1b80 <bcache+0x82b8>
    80003762:	0009e797          	auipc	a5,0x9e
    80003766:	3ce78793          	addi	a5,a5,974 # 800a1b30 <bcache+0x8268>
    8000376a:	02f48f63          	beq	s1,a5,800037a8 <bread+0x70>
    8000376e:	873e                	mv	a4,a5
    80003770:	a021                	j	80003778 <bread+0x40>
    80003772:	68a4                	ld	s1,80(s1)
    80003774:	02e48a63          	beq	s1,a4,800037a8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003778:	449c                	lw	a5,8(s1)
    8000377a:	ff279ce3          	bne	a5,s2,80003772 <bread+0x3a>
    8000377e:	44dc                	lw	a5,12(s1)
    80003780:	ff3799e3          	bne	a5,s3,80003772 <bread+0x3a>
      b->refcnt++;
    80003784:	40bc                	lw	a5,64(s1)
    80003786:	2785                	addiw	a5,a5,1
    80003788:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000378a:	00096517          	auipc	a0,0x96
    8000378e:	13e50513          	addi	a0,a0,318 # 800998c8 <bcache>
    80003792:	ffffd097          	auipc	ra,0xffffd
    80003796:	62c080e7          	jalr	1580(ra) # 80000dbe <release>
      acquiresleep(&b->lock);
    8000379a:	01048513          	addi	a0,s1,16
    8000379e:	00001097          	auipc	ra,0x1
    800037a2:	492080e7          	jalr	1170(ra) # 80004c30 <acquiresleep>
      return b;
    800037a6:	a8b9                	j	80003804 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037a8:	0009e497          	auipc	s1,0x9e
    800037ac:	3d04b483          	ld	s1,976(s1) # 800a1b78 <bcache+0x82b0>
    800037b0:	0009e797          	auipc	a5,0x9e
    800037b4:	38078793          	addi	a5,a5,896 # 800a1b30 <bcache+0x8268>
    800037b8:	00f48863          	beq	s1,a5,800037c8 <bread+0x90>
    800037bc:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800037be:	40bc                	lw	a5,64(s1)
    800037c0:	cf81                	beqz	a5,800037d8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037c2:	64a4                	ld	s1,72(s1)
    800037c4:	fee49de3          	bne	s1,a4,800037be <bread+0x86>
  panic("bget: no buffers");
    800037c8:	00005517          	auipc	a0,0x5
    800037cc:	ef050513          	addi	a0,a0,-272 # 800086b8 <__func__.1+0x6b0>
    800037d0:	ffffd097          	auipc	ra,0xffffd
    800037d4:	d90080e7          	jalr	-624(ra) # 80000560 <panic>
      b->dev = dev;
    800037d8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800037dc:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800037e0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800037e4:	4785                	li	a5,1
    800037e6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800037e8:	00096517          	auipc	a0,0x96
    800037ec:	0e050513          	addi	a0,a0,224 # 800998c8 <bcache>
    800037f0:	ffffd097          	auipc	ra,0xffffd
    800037f4:	5ce080e7          	jalr	1486(ra) # 80000dbe <release>
      acquiresleep(&b->lock);
    800037f8:	01048513          	addi	a0,s1,16
    800037fc:	00001097          	auipc	ra,0x1
    80003800:	434080e7          	jalr	1076(ra) # 80004c30 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003804:	409c                	lw	a5,0(s1)
    80003806:	cb89                	beqz	a5,80003818 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003808:	8526                	mv	a0,s1
    8000380a:	70a2                	ld	ra,40(sp)
    8000380c:	7402                	ld	s0,32(sp)
    8000380e:	64e2                	ld	s1,24(sp)
    80003810:	6942                	ld	s2,16(sp)
    80003812:	69a2                	ld	s3,8(sp)
    80003814:	6145                	addi	sp,sp,48
    80003816:	8082                	ret
    virtio_disk_rw(b, 0);
    80003818:	4581                	li	a1,0
    8000381a:	8526                	mv	a0,s1
    8000381c:	00003097          	auipc	ra,0x3
    80003820:	1cc080e7          	jalr	460(ra) # 800069e8 <virtio_disk_rw>
    b->valid = 1;
    80003824:	4785                	li	a5,1
    80003826:	c09c                	sw	a5,0(s1)
  return b;
    80003828:	b7c5                	j	80003808 <bread+0xd0>

000000008000382a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000382a:	1101                	addi	sp,sp,-32
    8000382c:	ec06                	sd	ra,24(sp)
    8000382e:	e822                	sd	s0,16(sp)
    80003830:	e426                	sd	s1,8(sp)
    80003832:	1000                	addi	s0,sp,32
    80003834:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003836:	0541                	addi	a0,a0,16
    80003838:	00001097          	auipc	ra,0x1
    8000383c:	492080e7          	jalr	1170(ra) # 80004cca <holdingsleep>
    80003840:	cd01                	beqz	a0,80003858 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003842:	4585                	li	a1,1
    80003844:	8526                	mv	a0,s1
    80003846:	00003097          	auipc	ra,0x3
    8000384a:	1a2080e7          	jalr	418(ra) # 800069e8 <virtio_disk_rw>
}
    8000384e:	60e2                	ld	ra,24(sp)
    80003850:	6442                	ld	s0,16(sp)
    80003852:	64a2                	ld	s1,8(sp)
    80003854:	6105                	addi	sp,sp,32
    80003856:	8082                	ret
    panic("bwrite");
    80003858:	00005517          	auipc	a0,0x5
    8000385c:	e7850513          	addi	a0,a0,-392 # 800086d0 <__func__.1+0x6c8>
    80003860:	ffffd097          	auipc	ra,0xffffd
    80003864:	d00080e7          	jalr	-768(ra) # 80000560 <panic>

0000000080003868 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003868:	1101                	addi	sp,sp,-32
    8000386a:	ec06                	sd	ra,24(sp)
    8000386c:	e822                	sd	s0,16(sp)
    8000386e:	e426                	sd	s1,8(sp)
    80003870:	e04a                	sd	s2,0(sp)
    80003872:	1000                	addi	s0,sp,32
    80003874:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003876:	01050913          	addi	s2,a0,16
    8000387a:	854a                	mv	a0,s2
    8000387c:	00001097          	auipc	ra,0x1
    80003880:	44e080e7          	jalr	1102(ra) # 80004cca <holdingsleep>
    80003884:	c925                	beqz	a0,800038f4 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003886:	854a                	mv	a0,s2
    80003888:	00001097          	auipc	ra,0x1
    8000388c:	3fe080e7          	jalr	1022(ra) # 80004c86 <releasesleep>

  acquire(&bcache.lock);
    80003890:	00096517          	auipc	a0,0x96
    80003894:	03850513          	addi	a0,a0,56 # 800998c8 <bcache>
    80003898:	ffffd097          	auipc	ra,0xffffd
    8000389c:	472080e7          	jalr	1138(ra) # 80000d0a <acquire>
  b->refcnt--;
    800038a0:	40bc                	lw	a5,64(s1)
    800038a2:	37fd                	addiw	a5,a5,-1
    800038a4:	0007871b          	sext.w	a4,a5
    800038a8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800038aa:	e71d                	bnez	a4,800038d8 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800038ac:	68b8                	ld	a4,80(s1)
    800038ae:	64bc                	ld	a5,72(s1)
    800038b0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800038b2:	68b8                	ld	a4,80(s1)
    800038b4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800038b6:	0009e797          	auipc	a5,0x9e
    800038ba:	01278793          	addi	a5,a5,18 # 800a18c8 <bcache+0x8000>
    800038be:	2b87b703          	ld	a4,696(a5)
    800038c2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800038c4:	0009e717          	auipc	a4,0x9e
    800038c8:	26c70713          	addi	a4,a4,620 # 800a1b30 <bcache+0x8268>
    800038cc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800038ce:	2b87b703          	ld	a4,696(a5)
    800038d2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800038d4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800038d8:	00096517          	auipc	a0,0x96
    800038dc:	ff050513          	addi	a0,a0,-16 # 800998c8 <bcache>
    800038e0:	ffffd097          	auipc	ra,0xffffd
    800038e4:	4de080e7          	jalr	1246(ra) # 80000dbe <release>
}
    800038e8:	60e2                	ld	ra,24(sp)
    800038ea:	6442                	ld	s0,16(sp)
    800038ec:	64a2                	ld	s1,8(sp)
    800038ee:	6902                	ld	s2,0(sp)
    800038f0:	6105                	addi	sp,sp,32
    800038f2:	8082                	ret
    panic("brelse");
    800038f4:	00005517          	auipc	a0,0x5
    800038f8:	de450513          	addi	a0,a0,-540 # 800086d8 <__func__.1+0x6d0>
    800038fc:	ffffd097          	auipc	ra,0xffffd
    80003900:	c64080e7          	jalr	-924(ra) # 80000560 <panic>

0000000080003904 <bpin>:

void
bpin(struct buf *b) {
    80003904:	1101                	addi	sp,sp,-32
    80003906:	ec06                	sd	ra,24(sp)
    80003908:	e822                	sd	s0,16(sp)
    8000390a:	e426                	sd	s1,8(sp)
    8000390c:	1000                	addi	s0,sp,32
    8000390e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003910:	00096517          	auipc	a0,0x96
    80003914:	fb850513          	addi	a0,a0,-72 # 800998c8 <bcache>
    80003918:	ffffd097          	auipc	ra,0xffffd
    8000391c:	3f2080e7          	jalr	1010(ra) # 80000d0a <acquire>
  b->refcnt++;
    80003920:	40bc                	lw	a5,64(s1)
    80003922:	2785                	addiw	a5,a5,1
    80003924:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003926:	00096517          	auipc	a0,0x96
    8000392a:	fa250513          	addi	a0,a0,-94 # 800998c8 <bcache>
    8000392e:	ffffd097          	auipc	ra,0xffffd
    80003932:	490080e7          	jalr	1168(ra) # 80000dbe <release>
}
    80003936:	60e2                	ld	ra,24(sp)
    80003938:	6442                	ld	s0,16(sp)
    8000393a:	64a2                	ld	s1,8(sp)
    8000393c:	6105                	addi	sp,sp,32
    8000393e:	8082                	ret

0000000080003940 <bunpin>:

void
bunpin(struct buf *b) {
    80003940:	1101                	addi	sp,sp,-32
    80003942:	ec06                	sd	ra,24(sp)
    80003944:	e822                	sd	s0,16(sp)
    80003946:	e426                	sd	s1,8(sp)
    80003948:	1000                	addi	s0,sp,32
    8000394a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000394c:	00096517          	auipc	a0,0x96
    80003950:	f7c50513          	addi	a0,a0,-132 # 800998c8 <bcache>
    80003954:	ffffd097          	auipc	ra,0xffffd
    80003958:	3b6080e7          	jalr	950(ra) # 80000d0a <acquire>
  b->refcnt--;
    8000395c:	40bc                	lw	a5,64(s1)
    8000395e:	37fd                	addiw	a5,a5,-1
    80003960:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003962:	00096517          	auipc	a0,0x96
    80003966:	f6650513          	addi	a0,a0,-154 # 800998c8 <bcache>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	454080e7          	jalr	1108(ra) # 80000dbe <release>
}
    80003972:	60e2                	ld	ra,24(sp)
    80003974:	6442                	ld	s0,16(sp)
    80003976:	64a2                	ld	s1,8(sp)
    80003978:	6105                	addi	sp,sp,32
    8000397a:	8082                	ret

000000008000397c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000397c:	1101                	addi	sp,sp,-32
    8000397e:	ec06                	sd	ra,24(sp)
    80003980:	e822                	sd	s0,16(sp)
    80003982:	e426                	sd	s1,8(sp)
    80003984:	e04a                	sd	s2,0(sp)
    80003986:	1000                	addi	s0,sp,32
    80003988:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000398a:	00d5d59b          	srliw	a1,a1,0xd
    8000398e:	0009e797          	auipc	a5,0x9e
    80003992:	6167a783          	lw	a5,1558(a5) # 800a1fa4 <sb+0x1c>
    80003996:	9dbd                	addw	a1,a1,a5
    80003998:	00000097          	auipc	ra,0x0
    8000399c:	da0080e7          	jalr	-608(ra) # 80003738 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800039a0:	0074f713          	andi	a4,s1,7
    800039a4:	4785                	li	a5,1
    800039a6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800039aa:	14ce                	slli	s1,s1,0x33
    800039ac:	90d9                	srli	s1,s1,0x36
    800039ae:	00950733          	add	a4,a0,s1
    800039b2:	05874703          	lbu	a4,88(a4)
    800039b6:	00e7f6b3          	and	a3,a5,a4
    800039ba:	c69d                	beqz	a3,800039e8 <bfree+0x6c>
    800039bc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800039be:	94aa                	add	s1,s1,a0
    800039c0:	fff7c793          	not	a5,a5
    800039c4:	8f7d                	and	a4,a4,a5
    800039c6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800039ca:	00001097          	auipc	ra,0x1
    800039ce:	148080e7          	jalr	328(ra) # 80004b12 <log_write>
  brelse(bp);
    800039d2:	854a                	mv	a0,s2
    800039d4:	00000097          	auipc	ra,0x0
    800039d8:	e94080e7          	jalr	-364(ra) # 80003868 <brelse>
}
    800039dc:	60e2                	ld	ra,24(sp)
    800039de:	6442                	ld	s0,16(sp)
    800039e0:	64a2                	ld	s1,8(sp)
    800039e2:	6902                	ld	s2,0(sp)
    800039e4:	6105                	addi	sp,sp,32
    800039e6:	8082                	ret
    panic("freeing free block");
    800039e8:	00005517          	auipc	a0,0x5
    800039ec:	cf850513          	addi	a0,a0,-776 # 800086e0 <__func__.1+0x6d8>
    800039f0:	ffffd097          	auipc	ra,0xffffd
    800039f4:	b70080e7          	jalr	-1168(ra) # 80000560 <panic>

00000000800039f8 <balloc>:
{
    800039f8:	711d                	addi	sp,sp,-96
    800039fa:	ec86                	sd	ra,88(sp)
    800039fc:	e8a2                	sd	s0,80(sp)
    800039fe:	e4a6                	sd	s1,72(sp)
    80003a00:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a02:	0009e797          	auipc	a5,0x9e
    80003a06:	58a7a783          	lw	a5,1418(a5) # 800a1f8c <sb+0x4>
    80003a0a:	10078f63          	beqz	a5,80003b28 <balloc+0x130>
    80003a0e:	e0ca                	sd	s2,64(sp)
    80003a10:	fc4e                	sd	s3,56(sp)
    80003a12:	f852                	sd	s4,48(sp)
    80003a14:	f456                	sd	s5,40(sp)
    80003a16:	f05a                	sd	s6,32(sp)
    80003a18:	ec5e                	sd	s7,24(sp)
    80003a1a:	e862                	sd	s8,16(sp)
    80003a1c:	e466                	sd	s9,8(sp)
    80003a1e:	8baa                	mv	s7,a0
    80003a20:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a22:	0009eb17          	auipc	s6,0x9e
    80003a26:	566b0b13          	addi	s6,s6,1382 # 800a1f88 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a2a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003a2c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a2e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003a30:	6c89                	lui	s9,0x2
    80003a32:	a061                	j	80003aba <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a34:	97ca                	add	a5,a5,s2
    80003a36:	8e55                	or	a2,a2,a3
    80003a38:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003a3c:	854a                	mv	a0,s2
    80003a3e:	00001097          	auipc	ra,0x1
    80003a42:	0d4080e7          	jalr	212(ra) # 80004b12 <log_write>
        brelse(bp);
    80003a46:	854a                	mv	a0,s2
    80003a48:	00000097          	auipc	ra,0x0
    80003a4c:	e20080e7          	jalr	-480(ra) # 80003868 <brelse>
  bp = bread(dev, bno);
    80003a50:	85a6                	mv	a1,s1
    80003a52:	855e                	mv	a0,s7
    80003a54:	00000097          	auipc	ra,0x0
    80003a58:	ce4080e7          	jalr	-796(ra) # 80003738 <bread>
    80003a5c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003a5e:	40000613          	li	a2,1024
    80003a62:	4581                	li	a1,0
    80003a64:	05850513          	addi	a0,a0,88
    80003a68:	ffffd097          	auipc	ra,0xffffd
    80003a6c:	39e080e7          	jalr	926(ra) # 80000e06 <memset>
  log_write(bp);
    80003a70:	854a                	mv	a0,s2
    80003a72:	00001097          	auipc	ra,0x1
    80003a76:	0a0080e7          	jalr	160(ra) # 80004b12 <log_write>
  brelse(bp);
    80003a7a:	854a                	mv	a0,s2
    80003a7c:	00000097          	auipc	ra,0x0
    80003a80:	dec080e7          	jalr	-532(ra) # 80003868 <brelse>
}
    80003a84:	6906                	ld	s2,64(sp)
    80003a86:	79e2                	ld	s3,56(sp)
    80003a88:	7a42                	ld	s4,48(sp)
    80003a8a:	7aa2                	ld	s5,40(sp)
    80003a8c:	7b02                	ld	s6,32(sp)
    80003a8e:	6be2                	ld	s7,24(sp)
    80003a90:	6c42                	ld	s8,16(sp)
    80003a92:	6ca2                	ld	s9,8(sp)
}
    80003a94:	8526                	mv	a0,s1
    80003a96:	60e6                	ld	ra,88(sp)
    80003a98:	6446                	ld	s0,80(sp)
    80003a9a:	64a6                	ld	s1,72(sp)
    80003a9c:	6125                	addi	sp,sp,96
    80003a9e:	8082                	ret
    brelse(bp);
    80003aa0:	854a                	mv	a0,s2
    80003aa2:	00000097          	auipc	ra,0x0
    80003aa6:	dc6080e7          	jalr	-570(ra) # 80003868 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003aaa:	015c87bb          	addw	a5,s9,s5
    80003aae:	00078a9b          	sext.w	s5,a5
    80003ab2:	004b2703          	lw	a4,4(s6)
    80003ab6:	06eaf163          	bgeu	s5,a4,80003b18 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003aba:	41fad79b          	sraiw	a5,s5,0x1f
    80003abe:	0137d79b          	srliw	a5,a5,0x13
    80003ac2:	015787bb          	addw	a5,a5,s5
    80003ac6:	40d7d79b          	sraiw	a5,a5,0xd
    80003aca:	01cb2583          	lw	a1,28(s6)
    80003ace:	9dbd                	addw	a1,a1,a5
    80003ad0:	855e                	mv	a0,s7
    80003ad2:	00000097          	auipc	ra,0x0
    80003ad6:	c66080e7          	jalr	-922(ra) # 80003738 <bread>
    80003ada:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003adc:	004b2503          	lw	a0,4(s6)
    80003ae0:	000a849b          	sext.w	s1,s5
    80003ae4:	8762                	mv	a4,s8
    80003ae6:	faa4fde3          	bgeu	s1,a0,80003aa0 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003aea:	00777693          	andi	a3,a4,7
    80003aee:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003af2:	41f7579b          	sraiw	a5,a4,0x1f
    80003af6:	01d7d79b          	srliw	a5,a5,0x1d
    80003afa:	9fb9                	addw	a5,a5,a4
    80003afc:	4037d79b          	sraiw	a5,a5,0x3
    80003b00:	00f90633          	add	a2,s2,a5
    80003b04:	05864603          	lbu	a2,88(a2)
    80003b08:	00c6f5b3          	and	a1,a3,a2
    80003b0c:	d585                	beqz	a1,80003a34 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b0e:	2705                	addiw	a4,a4,1
    80003b10:	2485                	addiw	s1,s1,1
    80003b12:	fd471ae3          	bne	a4,s4,80003ae6 <balloc+0xee>
    80003b16:	b769                	j	80003aa0 <balloc+0xa8>
    80003b18:	6906                	ld	s2,64(sp)
    80003b1a:	79e2                	ld	s3,56(sp)
    80003b1c:	7a42                	ld	s4,48(sp)
    80003b1e:	7aa2                	ld	s5,40(sp)
    80003b20:	7b02                	ld	s6,32(sp)
    80003b22:	6be2                	ld	s7,24(sp)
    80003b24:	6c42                	ld	s8,16(sp)
    80003b26:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003b28:	00005517          	auipc	a0,0x5
    80003b2c:	bd050513          	addi	a0,a0,-1072 # 800086f8 <__func__.1+0x6f0>
    80003b30:	ffffd097          	auipc	ra,0xffffd
    80003b34:	a8c080e7          	jalr	-1396(ra) # 800005bc <printf>
  return 0;
    80003b38:	4481                	li	s1,0
    80003b3a:	bfa9                	j	80003a94 <balloc+0x9c>

0000000080003b3c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b3c:	7179                	addi	sp,sp,-48
    80003b3e:	f406                	sd	ra,40(sp)
    80003b40:	f022                	sd	s0,32(sp)
    80003b42:	ec26                	sd	s1,24(sp)
    80003b44:	e84a                	sd	s2,16(sp)
    80003b46:	e44e                	sd	s3,8(sp)
    80003b48:	1800                	addi	s0,sp,48
    80003b4a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b4c:	47ad                	li	a5,11
    80003b4e:	02b7e863          	bltu	a5,a1,80003b7e <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003b52:	02059793          	slli	a5,a1,0x20
    80003b56:	01e7d593          	srli	a1,a5,0x1e
    80003b5a:	00b504b3          	add	s1,a0,a1
    80003b5e:	0504a903          	lw	s2,80(s1)
    80003b62:	08091263          	bnez	s2,80003be6 <bmap+0xaa>
      addr = balloc(ip->dev);
    80003b66:	4108                	lw	a0,0(a0)
    80003b68:	00000097          	auipc	ra,0x0
    80003b6c:	e90080e7          	jalr	-368(ra) # 800039f8 <balloc>
    80003b70:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b74:	06090963          	beqz	s2,80003be6 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003b78:	0524a823          	sw	s2,80(s1)
    80003b7c:	a0ad                	j	80003be6 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003b7e:	ff45849b          	addiw	s1,a1,-12
    80003b82:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003b86:	0ff00793          	li	a5,255
    80003b8a:	08e7e863          	bltu	a5,a4,80003c1a <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003b8e:	08052903          	lw	s2,128(a0)
    80003b92:	00091f63          	bnez	s2,80003bb0 <bmap+0x74>
      addr = balloc(ip->dev);
    80003b96:	4108                	lw	a0,0(a0)
    80003b98:	00000097          	auipc	ra,0x0
    80003b9c:	e60080e7          	jalr	-416(ra) # 800039f8 <balloc>
    80003ba0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ba4:	04090163          	beqz	s2,80003be6 <bmap+0xaa>
    80003ba8:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003baa:	0929a023          	sw	s2,128(s3)
    80003bae:	a011                	j	80003bb2 <bmap+0x76>
    80003bb0:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003bb2:	85ca                	mv	a1,s2
    80003bb4:	0009a503          	lw	a0,0(s3)
    80003bb8:	00000097          	auipc	ra,0x0
    80003bbc:	b80080e7          	jalr	-1152(ra) # 80003738 <bread>
    80003bc0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003bc2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003bc6:	02049713          	slli	a4,s1,0x20
    80003bca:	01e75593          	srli	a1,a4,0x1e
    80003bce:	00b784b3          	add	s1,a5,a1
    80003bd2:	0004a903          	lw	s2,0(s1)
    80003bd6:	02090063          	beqz	s2,80003bf6 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003bda:	8552                	mv	a0,s4
    80003bdc:	00000097          	auipc	ra,0x0
    80003be0:	c8c080e7          	jalr	-884(ra) # 80003868 <brelse>
    return addr;
    80003be4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003be6:	854a                	mv	a0,s2
    80003be8:	70a2                	ld	ra,40(sp)
    80003bea:	7402                	ld	s0,32(sp)
    80003bec:	64e2                	ld	s1,24(sp)
    80003bee:	6942                	ld	s2,16(sp)
    80003bf0:	69a2                	ld	s3,8(sp)
    80003bf2:	6145                	addi	sp,sp,48
    80003bf4:	8082                	ret
      addr = balloc(ip->dev);
    80003bf6:	0009a503          	lw	a0,0(s3)
    80003bfa:	00000097          	auipc	ra,0x0
    80003bfe:	dfe080e7          	jalr	-514(ra) # 800039f8 <balloc>
    80003c02:	0005091b          	sext.w	s2,a0
      if(addr){
    80003c06:	fc090ae3          	beqz	s2,80003bda <bmap+0x9e>
        a[bn] = addr;
    80003c0a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003c0e:	8552                	mv	a0,s4
    80003c10:	00001097          	auipc	ra,0x1
    80003c14:	f02080e7          	jalr	-254(ra) # 80004b12 <log_write>
    80003c18:	b7c9                	j	80003bda <bmap+0x9e>
    80003c1a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003c1c:	00005517          	auipc	a0,0x5
    80003c20:	af450513          	addi	a0,a0,-1292 # 80008710 <__func__.1+0x708>
    80003c24:	ffffd097          	auipc	ra,0xffffd
    80003c28:	93c080e7          	jalr	-1732(ra) # 80000560 <panic>

0000000080003c2c <iget>:
{
    80003c2c:	7179                	addi	sp,sp,-48
    80003c2e:	f406                	sd	ra,40(sp)
    80003c30:	f022                	sd	s0,32(sp)
    80003c32:	ec26                	sd	s1,24(sp)
    80003c34:	e84a                	sd	s2,16(sp)
    80003c36:	e44e                	sd	s3,8(sp)
    80003c38:	e052                	sd	s4,0(sp)
    80003c3a:	1800                	addi	s0,sp,48
    80003c3c:	89aa                	mv	s3,a0
    80003c3e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c40:	0009e517          	auipc	a0,0x9e
    80003c44:	36850513          	addi	a0,a0,872 # 800a1fa8 <itable>
    80003c48:	ffffd097          	auipc	ra,0xffffd
    80003c4c:	0c2080e7          	jalr	194(ra) # 80000d0a <acquire>
  empty = 0;
    80003c50:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c52:	0009e497          	auipc	s1,0x9e
    80003c56:	36e48493          	addi	s1,s1,878 # 800a1fc0 <itable+0x18>
    80003c5a:	000a0697          	auipc	a3,0xa0
    80003c5e:	df668693          	addi	a3,a3,-522 # 800a3a50 <log>
    80003c62:	a039                	j	80003c70 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c64:	02090b63          	beqz	s2,80003c9a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c68:	08848493          	addi	s1,s1,136
    80003c6c:	02d48a63          	beq	s1,a3,80003ca0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c70:	449c                	lw	a5,8(s1)
    80003c72:	fef059e3          	blez	a5,80003c64 <iget+0x38>
    80003c76:	4098                	lw	a4,0(s1)
    80003c78:	ff3716e3          	bne	a4,s3,80003c64 <iget+0x38>
    80003c7c:	40d8                	lw	a4,4(s1)
    80003c7e:	ff4713e3          	bne	a4,s4,80003c64 <iget+0x38>
      ip->ref++;
    80003c82:	2785                	addiw	a5,a5,1
    80003c84:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003c86:	0009e517          	auipc	a0,0x9e
    80003c8a:	32250513          	addi	a0,a0,802 # 800a1fa8 <itable>
    80003c8e:	ffffd097          	auipc	ra,0xffffd
    80003c92:	130080e7          	jalr	304(ra) # 80000dbe <release>
      return ip;
    80003c96:	8926                	mv	s2,s1
    80003c98:	a03d                	j	80003cc6 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c9a:	f7f9                	bnez	a5,80003c68 <iget+0x3c>
      empty = ip;
    80003c9c:	8926                	mv	s2,s1
    80003c9e:	b7e9                	j	80003c68 <iget+0x3c>
  if(empty == 0)
    80003ca0:	02090c63          	beqz	s2,80003cd8 <iget+0xac>
  ip->dev = dev;
    80003ca4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003ca8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003cac:	4785                	li	a5,1
    80003cae:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003cb2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003cb6:	0009e517          	auipc	a0,0x9e
    80003cba:	2f250513          	addi	a0,a0,754 # 800a1fa8 <itable>
    80003cbe:	ffffd097          	auipc	ra,0xffffd
    80003cc2:	100080e7          	jalr	256(ra) # 80000dbe <release>
}
    80003cc6:	854a                	mv	a0,s2
    80003cc8:	70a2                	ld	ra,40(sp)
    80003cca:	7402                	ld	s0,32(sp)
    80003ccc:	64e2                	ld	s1,24(sp)
    80003cce:	6942                	ld	s2,16(sp)
    80003cd0:	69a2                	ld	s3,8(sp)
    80003cd2:	6a02                	ld	s4,0(sp)
    80003cd4:	6145                	addi	sp,sp,48
    80003cd6:	8082                	ret
    panic("iget: no inodes");
    80003cd8:	00005517          	auipc	a0,0x5
    80003cdc:	a5050513          	addi	a0,a0,-1456 # 80008728 <__func__.1+0x720>
    80003ce0:	ffffd097          	auipc	ra,0xffffd
    80003ce4:	880080e7          	jalr	-1920(ra) # 80000560 <panic>

0000000080003ce8 <fsinit>:
fsinit(int dev) {
    80003ce8:	7179                	addi	sp,sp,-48
    80003cea:	f406                	sd	ra,40(sp)
    80003cec:	f022                	sd	s0,32(sp)
    80003cee:	ec26                	sd	s1,24(sp)
    80003cf0:	e84a                	sd	s2,16(sp)
    80003cf2:	e44e                	sd	s3,8(sp)
    80003cf4:	1800                	addi	s0,sp,48
    80003cf6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003cf8:	4585                	li	a1,1
    80003cfa:	00000097          	auipc	ra,0x0
    80003cfe:	a3e080e7          	jalr	-1474(ra) # 80003738 <bread>
    80003d02:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003d04:	0009e997          	auipc	s3,0x9e
    80003d08:	28498993          	addi	s3,s3,644 # 800a1f88 <sb>
    80003d0c:	02000613          	li	a2,32
    80003d10:	05850593          	addi	a1,a0,88
    80003d14:	854e                	mv	a0,s3
    80003d16:	ffffd097          	auipc	ra,0xffffd
    80003d1a:	14c080e7          	jalr	332(ra) # 80000e62 <memmove>
  brelse(bp);
    80003d1e:	8526                	mv	a0,s1
    80003d20:	00000097          	auipc	ra,0x0
    80003d24:	b48080e7          	jalr	-1208(ra) # 80003868 <brelse>
  if(sb.magic != FSMAGIC)
    80003d28:	0009a703          	lw	a4,0(s3)
    80003d2c:	102037b7          	lui	a5,0x10203
    80003d30:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d34:	02f71263          	bne	a4,a5,80003d58 <fsinit+0x70>
  initlog(dev, &sb);
    80003d38:	0009e597          	auipc	a1,0x9e
    80003d3c:	25058593          	addi	a1,a1,592 # 800a1f88 <sb>
    80003d40:	854a                	mv	a0,s2
    80003d42:	00001097          	auipc	ra,0x1
    80003d46:	b60080e7          	jalr	-1184(ra) # 800048a2 <initlog>
}
    80003d4a:	70a2                	ld	ra,40(sp)
    80003d4c:	7402                	ld	s0,32(sp)
    80003d4e:	64e2                	ld	s1,24(sp)
    80003d50:	6942                	ld	s2,16(sp)
    80003d52:	69a2                	ld	s3,8(sp)
    80003d54:	6145                	addi	sp,sp,48
    80003d56:	8082                	ret
    panic("invalid file system");
    80003d58:	00005517          	auipc	a0,0x5
    80003d5c:	9e050513          	addi	a0,a0,-1568 # 80008738 <__func__.1+0x730>
    80003d60:	ffffd097          	auipc	ra,0xffffd
    80003d64:	800080e7          	jalr	-2048(ra) # 80000560 <panic>

0000000080003d68 <iinit>:
{
    80003d68:	7179                	addi	sp,sp,-48
    80003d6a:	f406                	sd	ra,40(sp)
    80003d6c:	f022                	sd	s0,32(sp)
    80003d6e:	ec26                	sd	s1,24(sp)
    80003d70:	e84a                	sd	s2,16(sp)
    80003d72:	e44e                	sd	s3,8(sp)
    80003d74:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003d76:	00005597          	auipc	a1,0x5
    80003d7a:	9da58593          	addi	a1,a1,-1574 # 80008750 <__func__.1+0x748>
    80003d7e:	0009e517          	auipc	a0,0x9e
    80003d82:	22a50513          	addi	a0,a0,554 # 800a1fa8 <itable>
    80003d86:	ffffd097          	auipc	ra,0xffffd
    80003d8a:	ef4080e7          	jalr	-268(ra) # 80000c7a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003d8e:	0009e497          	auipc	s1,0x9e
    80003d92:	24248493          	addi	s1,s1,578 # 800a1fd0 <itable+0x28>
    80003d96:	000a0997          	auipc	s3,0xa0
    80003d9a:	cca98993          	addi	s3,s3,-822 # 800a3a60 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d9e:	00005917          	auipc	s2,0x5
    80003da2:	9ba90913          	addi	s2,s2,-1606 # 80008758 <__func__.1+0x750>
    80003da6:	85ca                	mv	a1,s2
    80003da8:	8526                	mv	a0,s1
    80003daa:	00001097          	auipc	ra,0x1
    80003dae:	e4c080e7          	jalr	-436(ra) # 80004bf6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003db2:	08848493          	addi	s1,s1,136
    80003db6:	ff3498e3          	bne	s1,s3,80003da6 <iinit+0x3e>
}
    80003dba:	70a2                	ld	ra,40(sp)
    80003dbc:	7402                	ld	s0,32(sp)
    80003dbe:	64e2                	ld	s1,24(sp)
    80003dc0:	6942                	ld	s2,16(sp)
    80003dc2:	69a2                	ld	s3,8(sp)
    80003dc4:	6145                	addi	sp,sp,48
    80003dc6:	8082                	ret

0000000080003dc8 <ialloc>:
{
    80003dc8:	7139                	addi	sp,sp,-64
    80003dca:	fc06                	sd	ra,56(sp)
    80003dcc:	f822                	sd	s0,48(sp)
    80003dce:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003dd0:	0009e717          	auipc	a4,0x9e
    80003dd4:	1c472703          	lw	a4,452(a4) # 800a1f94 <sb+0xc>
    80003dd8:	4785                	li	a5,1
    80003dda:	06e7f463          	bgeu	a5,a4,80003e42 <ialloc+0x7a>
    80003dde:	f426                	sd	s1,40(sp)
    80003de0:	f04a                	sd	s2,32(sp)
    80003de2:	ec4e                	sd	s3,24(sp)
    80003de4:	e852                	sd	s4,16(sp)
    80003de6:	e456                	sd	s5,8(sp)
    80003de8:	e05a                	sd	s6,0(sp)
    80003dea:	8aaa                	mv	s5,a0
    80003dec:	8b2e                	mv	s6,a1
    80003dee:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003df0:	0009ea17          	auipc	s4,0x9e
    80003df4:	198a0a13          	addi	s4,s4,408 # 800a1f88 <sb>
    80003df8:	00495593          	srli	a1,s2,0x4
    80003dfc:	018a2783          	lw	a5,24(s4)
    80003e00:	9dbd                	addw	a1,a1,a5
    80003e02:	8556                	mv	a0,s5
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	934080e7          	jalr	-1740(ra) # 80003738 <bread>
    80003e0c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003e0e:	05850993          	addi	s3,a0,88
    80003e12:	00f97793          	andi	a5,s2,15
    80003e16:	079a                	slli	a5,a5,0x6
    80003e18:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003e1a:	00099783          	lh	a5,0(s3)
    80003e1e:	cf9d                	beqz	a5,80003e5c <ialloc+0x94>
    brelse(bp);
    80003e20:	00000097          	auipc	ra,0x0
    80003e24:	a48080e7          	jalr	-1464(ra) # 80003868 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e28:	0905                	addi	s2,s2,1
    80003e2a:	00ca2703          	lw	a4,12(s4)
    80003e2e:	0009079b          	sext.w	a5,s2
    80003e32:	fce7e3e3          	bltu	a5,a4,80003df8 <ialloc+0x30>
    80003e36:	74a2                	ld	s1,40(sp)
    80003e38:	7902                	ld	s2,32(sp)
    80003e3a:	69e2                	ld	s3,24(sp)
    80003e3c:	6a42                	ld	s4,16(sp)
    80003e3e:	6aa2                	ld	s5,8(sp)
    80003e40:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003e42:	00005517          	auipc	a0,0x5
    80003e46:	91e50513          	addi	a0,a0,-1762 # 80008760 <__func__.1+0x758>
    80003e4a:	ffffc097          	auipc	ra,0xffffc
    80003e4e:	772080e7          	jalr	1906(ra) # 800005bc <printf>
  return 0;
    80003e52:	4501                	li	a0,0
}
    80003e54:	70e2                	ld	ra,56(sp)
    80003e56:	7442                	ld	s0,48(sp)
    80003e58:	6121                	addi	sp,sp,64
    80003e5a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e5c:	04000613          	li	a2,64
    80003e60:	4581                	li	a1,0
    80003e62:	854e                	mv	a0,s3
    80003e64:	ffffd097          	auipc	ra,0xffffd
    80003e68:	fa2080e7          	jalr	-94(ra) # 80000e06 <memset>
      dip->type = type;
    80003e6c:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003e70:	8526                	mv	a0,s1
    80003e72:	00001097          	auipc	ra,0x1
    80003e76:	ca0080e7          	jalr	-864(ra) # 80004b12 <log_write>
      brelse(bp);
    80003e7a:	8526                	mv	a0,s1
    80003e7c:	00000097          	auipc	ra,0x0
    80003e80:	9ec080e7          	jalr	-1556(ra) # 80003868 <brelse>
      return iget(dev, inum);
    80003e84:	0009059b          	sext.w	a1,s2
    80003e88:	8556                	mv	a0,s5
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	da2080e7          	jalr	-606(ra) # 80003c2c <iget>
    80003e92:	74a2                	ld	s1,40(sp)
    80003e94:	7902                	ld	s2,32(sp)
    80003e96:	69e2                	ld	s3,24(sp)
    80003e98:	6a42                	ld	s4,16(sp)
    80003e9a:	6aa2                	ld	s5,8(sp)
    80003e9c:	6b02                	ld	s6,0(sp)
    80003e9e:	bf5d                	j	80003e54 <ialloc+0x8c>

0000000080003ea0 <iupdate>:
{
    80003ea0:	1101                	addi	sp,sp,-32
    80003ea2:	ec06                	sd	ra,24(sp)
    80003ea4:	e822                	sd	s0,16(sp)
    80003ea6:	e426                	sd	s1,8(sp)
    80003ea8:	e04a                	sd	s2,0(sp)
    80003eaa:	1000                	addi	s0,sp,32
    80003eac:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003eae:	415c                	lw	a5,4(a0)
    80003eb0:	0047d79b          	srliw	a5,a5,0x4
    80003eb4:	0009e597          	auipc	a1,0x9e
    80003eb8:	0ec5a583          	lw	a1,236(a1) # 800a1fa0 <sb+0x18>
    80003ebc:	9dbd                	addw	a1,a1,a5
    80003ebe:	4108                	lw	a0,0(a0)
    80003ec0:	00000097          	auipc	ra,0x0
    80003ec4:	878080e7          	jalr	-1928(ra) # 80003738 <bread>
    80003ec8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003eca:	05850793          	addi	a5,a0,88
    80003ece:	40d8                	lw	a4,4(s1)
    80003ed0:	8b3d                	andi	a4,a4,15
    80003ed2:	071a                	slli	a4,a4,0x6
    80003ed4:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003ed6:	04449703          	lh	a4,68(s1)
    80003eda:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003ede:	04649703          	lh	a4,70(s1)
    80003ee2:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003ee6:	04849703          	lh	a4,72(s1)
    80003eea:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003eee:	04a49703          	lh	a4,74(s1)
    80003ef2:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003ef6:	44f8                	lw	a4,76(s1)
    80003ef8:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003efa:	03400613          	li	a2,52
    80003efe:	05048593          	addi	a1,s1,80
    80003f02:	00c78513          	addi	a0,a5,12
    80003f06:	ffffd097          	auipc	ra,0xffffd
    80003f0a:	f5c080e7          	jalr	-164(ra) # 80000e62 <memmove>
  log_write(bp);
    80003f0e:	854a                	mv	a0,s2
    80003f10:	00001097          	auipc	ra,0x1
    80003f14:	c02080e7          	jalr	-1022(ra) # 80004b12 <log_write>
  brelse(bp);
    80003f18:	854a                	mv	a0,s2
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	94e080e7          	jalr	-1714(ra) # 80003868 <brelse>
}
    80003f22:	60e2                	ld	ra,24(sp)
    80003f24:	6442                	ld	s0,16(sp)
    80003f26:	64a2                	ld	s1,8(sp)
    80003f28:	6902                	ld	s2,0(sp)
    80003f2a:	6105                	addi	sp,sp,32
    80003f2c:	8082                	ret

0000000080003f2e <idup>:
{
    80003f2e:	1101                	addi	sp,sp,-32
    80003f30:	ec06                	sd	ra,24(sp)
    80003f32:	e822                	sd	s0,16(sp)
    80003f34:	e426                	sd	s1,8(sp)
    80003f36:	1000                	addi	s0,sp,32
    80003f38:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f3a:	0009e517          	auipc	a0,0x9e
    80003f3e:	06e50513          	addi	a0,a0,110 # 800a1fa8 <itable>
    80003f42:	ffffd097          	auipc	ra,0xffffd
    80003f46:	dc8080e7          	jalr	-568(ra) # 80000d0a <acquire>
  ip->ref++;
    80003f4a:	449c                	lw	a5,8(s1)
    80003f4c:	2785                	addiw	a5,a5,1
    80003f4e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f50:	0009e517          	auipc	a0,0x9e
    80003f54:	05850513          	addi	a0,a0,88 # 800a1fa8 <itable>
    80003f58:	ffffd097          	auipc	ra,0xffffd
    80003f5c:	e66080e7          	jalr	-410(ra) # 80000dbe <release>
}
    80003f60:	8526                	mv	a0,s1
    80003f62:	60e2                	ld	ra,24(sp)
    80003f64:	6442                	ld	s0,16(sp)
    80003f66:	64a2                	ld	s1,8(sp)
    80003f68:	6105                	addi	sp,sp,32
    80003f6a:	8082                	ret

0000000080003f6c <ilock>:
{
    80003f6c:	1101                	addi	sp,sp,-32
    80003f6e:	ec06                	sd	ra,24(sp)
    80003f70:	e822                	sd	s0,16(sp)
    80003f72:	e426                	sd	s1,8(sp)
    80003f74:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003f76:	c10d                	beqz	a0,80003f98 <ilock+0x2c>
    80003f78:	84aa                	mv	s1,a0
    80003f7a:	451c                	lw	a5,8(a0)
    80003f7c:	00f05e63          	blez	a5,80003f98 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003f80:	0541                	addi	a0,a0,16
    80003f82:	00001097          	auipc	ra,0x1
    80003f86:	cae080e7          	jalr	-850(ra) # 80004c30 <acquiresleep>
  if(ip->valid == 0){
    80003f8a:	40bc                	lw	a5,64(s1)
    80003f8c:	cf99                	beqz	a5,80003faa <ilock+0x3e>
}
    80003f8e:	60e2                	ld	ra,24(sp)
    80003f90:	6442                	ld	s0,16(sp)
    80003f92:	64a2                	ld	s1,8(sp)
    80003f94:	6105                	addi	sp,sp,32
    80003f96:	8082                	ret
    80003f98:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003f9a:	00004517          	auipc	a0,0x4
    80003f9e:	7de50513          	addi	a0,a0,2014 # 80008778 <__func__.1+0x770>
    80003fa2:	ffffc097          	auipc	ra,0xffffc
    80003fa6:	5be080e7          	jalr	1470(ra) # 80000560 <panic>
    80003faa:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003fac:	40dc                	lw	a5,4(s1)
    80003fae:	0047d79b          	srliw	a5,a5,0x4
    80003fb2:	0009e597          	auipc	a1,0x9e
    80003fb6:	fee5a583          	lw	a1,-18(a1) # 800a1fa0 <sb+0x18>
    80003fba:	9dbd                	addw	a1,a1,a5
    80003fbc:	4088                	lw	a0,0(s1)
    80003fbe:	fffff097          	auipc	ra,0xfffff
    80003fc2:	77a080e7          	jalr	1914(ra) # 80003738 <bread>
    80003fc6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003fc8:	05850593          	addi	a1,a0,88
    80003fcc:	40dc                	lw	a5,4(s1)
    80003fce:	8bbd                	andi	a5,a5,15
    80003fd0:	079a                	slli	a5,a5,0x6
    80003fd2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003fd4:	00059783          	lh	a5,0(a1)
    80003fd8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003fdc:	00259783          	lh	a5,2(a1)
    80003fe0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003fe4:	00459783          	lh	a5,4(a1)
    80003fe8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003fec:	00659783          	lh	a5,6(a1)
    80003ff0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003ff4:	459c                	lw	a5,8(a1)
    80003ff6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ff8:	03400613          	li	a2,52
    80003ffc:	05b1                	addi	a1,a1,12
    80003ffe:	05048513          	addi	a0,s1,80
    80004002:	ffffd097          	auipc	ra,0xffffd
    80004006:	e60080e7          	jalr	-416(ra) # 80000e62 <memmove>
    brelse(bp);
    8000400a:	854a                	mv	a0,s2
    8000400c:	00000097          	auipc	ra,0x0
    80004010:	85c080e7          	jalr	-1956(ra) # 80003868 <brelse>
    ip->valid = 1;
    80004014:	4785                	li	a5,1
    80004016:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004018:	04449783          	lh	a5,68(s1)
    8000401c:	c399                	beqz	a5,80004022 <ilock+0xb6>
    8000401e:	6902                	ld	s2,0(sp)
    80004020:	b7bd                	j	80003f8e <ilock+0x22>
      panic("ilock: no type");
    80004022:	00004517          	auipc	a0,0x4
    80004026:	75e50513          	addi	a0,a0,1886 # 80008780 <__func__.1+0x778>
    8000402a:	ffffc097          	auipc	ra,0xffffc
    8000402e:	536080e7          	jalr	1334(ra) # 80000560 <panic>

0000000080004032 <iunlock>:
{
    80004032:	1101                	addi	sp,sp,-32
    80004034:	ec06                	sd	ra,24(sp)
    80004036:	e822                	sd	s0,16(sp)
    80004038:	e426                	sd	s1,8(sp)
    8000403a:	e04a                	sd	s2,0(sp)
    8000403c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000403e:	c905                	beqz	a0,8000406e <iunlock+0x3c>
    80004040:	84aa                	mv	s1,a0
    80004042:	01050913          	addi	s2,a0,16
    80004046:	854a                	mv	a0,s2
    80004048:	00001097          	auipc	ra,0x1
    8000404c:	c82080e7          	jalr	-894(ra) # 80004cca <holdingsleep>
    80004050:	cd19                	beqz	a0,8000406e <iunlock+0x3c>
    80004052:	449c                	lw	a5,8(s1)
    80004054:	00f05d63          	blez	a5,8000406e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004058:	854a                	mv	a0,s2
    8000405a:	00001097          	auipc	ra,0x1
    8000405e:	c2c080e7          	jalr	-980(ra) # 80004c86 <releasesleep>
}
    80004062:	60e2                	ld	ra,24(sp)
    80004064:	6442                	ld	s0,16(sp)
    80004066:	64a2                	ld	s1,8(sp)
    80004068:	6902                	ld	s2,0(sp)
    8000406a:	6105                	addi	sp,sp,32
    8000406c:	8082                	ret
    panic("iunlock");
    8000406e:	00004517          	auipc	a0,0x4
    80004072:	72250513          	addi	a0,a0,1826 # 80008790 <__func__.1+0x788>
    80004076:	ffffc097          	auipc	ra,0xffffc
    8000407a:	4ea080e7          	jalr	1258(ra) # 80000560 <panic>

000000008000407e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000407e:	7179                	addi	sp,sp,-48
    80004080:	f406                	sd	ra,40(sp)
    80004082:	f022                	sd	s0,32(sp)
    80004084:	ec26                	sd	s1,24(sp)
    80004086:	e84a                	sd	s2,16(sp)
    80004088:	e44e                	sd	s3,8(sp)
    8000408a:	1800                	addi	s0,sp,48
    8000408c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000408e:	05050493          	addi	s1,a0,80
    80004092:	08050913          	addi	s2,a0,128
    80004096:	a021                	j	8000409e <itrunc+0x20>
    80004098:	0491                	addi	s1,s1,4
    8000409a:	01248d63          	beq	s1,s2,800040b4 <itrunc+0x36>
    if(ip->addrs[i]){
    8000409e:	408c                	lw	a1,0(s1)
    800040a0:	dde5                	beqz	a1,80004098 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800040a2:	0009a503          	lw	a0,0(s3)
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	8d6080e7          	jalr	-1834(ra) # 8000397c <bfree>
      ip->addrs[i] = 0;
    800040ae:	0004a023          	sw	zero,0(s1)
    800040b2:	b7dd                	j	80004098 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800040b4:	0809a583          	lw	a1,128(s3)
    800040b8:	ed99                	bnez	a1,800040d6 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800040ba:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800040be:	854e                	mv	a0,s3
    800040c0:	00000097          	auipc	ra,0x0
    800040c4:	de0080e7          	jalr	-544(ra) # 80003ea0 <iupdate>
}
    800040c8:	70a2                	ld	ra,40(sp)
    800040ca:	7402                	ld	s0,32(sp)
    800040cc:	64e2                	ld	s1,24(sp)
    800040ce:	6942                	ld	s2,16(sp)
    800040d0:	69a2                	ld	s3,8(sp)
    800040d2:	6145                	addi	sp,sp,48
    800040d4:	8082                	ret
    800040d6:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800040d8:	0009a503          	lw	a0,0(s3)
    800040dc:	fffff097          	auipc	ra,0xfffff
    800040e0:	65c080e7          	jalr	1628(ra) # 80003738 <bread>
    800040e4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800040e6:	05850493          	addi	s1,a0,88
    800040ea:	45850913          	addi	s2,a0,1112
    800040ee:	a021                	j	800040f6 <itrunc+0x78>
    800040f0:	0491                	addi	s1,s1,4
    800040f2:	01248b63          	beq	s1,s2,80004108 <itrunc+0x8a>
      if(a[j])
    800040f6:	408c                	lw	a1,0(s1)
    800040f8:	dde5                	beqz	a1,800040f0 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    800040fa:	0009a503          	lw	a0,0(s3)
    800040fe:	00000097          	auipc	ra,0x0
    80004102:	87e080e7          	jalr	-1922(ra) # 8000397c <bfree>
    80004106:	b7ed                	j	800040f0 <itrunc+0x72>
    brelse(bp);
    80004108:	8552                	mv	a0,s4
    8000410a:	fffff097          	auipc	ra,0xfffff
    8000410e:	75e080e7          	jalr	1886(ra) # 80003868 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004112:	0809a583          	lw	a1,128(s3)
    80004116:	0009a503          	lw	a0,0(s3)
    8000411a:	00000097          	auipc	ra,0x0
    8000411e:	862080e7          	jalr	-1950(ra) # 8000397c <bfree>
    ip->addrs[NDIRECT] = 0;
    80004122:	0809a023          	sw	zero,128(s3)
    80004126:	6a02                	ld	s4,0(sp)
    80004128:	bf49                	j	800040ba <itrunc+0x3c>

000000008000412a <iput>:
{
    8000412a:	1101                	addi	sp,sp,-32
    8000412c:	ec06                	sd	ra,24(sp)
    8000412e:	e822                	sd	s0,16(sp)
    80004130:	e426                	sd	s1,8(sp)
    80004132:	1000                	addi	s0,sp,32
    80004134:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004136:	0009e517          	auipc	a0,0x9e
    8000413a:	e7250513          	addi	a0,a0,-398 # 800a1fa8 <itable>
    8000413e:	ffffd097          	auipc	ra,0xffffd
    80004142:	bcc080e7          	jalr	-1076(ra) # 80000d0a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004146:	4498                	lw	a4,8(s1)
    80004148:	4785                	li	a5,1
    8000414a:	02f70263          	beq	a4,a5,8000416e <iput+0x44>
  ip->ref--;
    8000414e:	449c                	lw	a5,8(s1)
    80004150:	37fd                	addiw	a5,a5,-1
    80004152:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004154:	0009e517          	auipc	a0,0x9e
    80004158:	e5450513          	addi	a0,a0,-428 # 800a1fa8 <itable>
    8000415c:	ffffd097          	auipc	ra,0xffffd
    80004160:	c62080e7          	jalr	-926(ra) # 80000dbe <release>
}
    80004164:	60e2                	ld	ra,24(sp)
    80004166:	6442                	ld	s0,16(sp)
    80004168:	64a2                	ld	s1,8(sp)
    8000416a:	6105                	addi	sp,sp,32
    8000416c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000416e:	40bc                	lw	a5,64(s1)
    80004170:	dff9                	beqz	a5,8000414e <iput+0x24>
    80004172:	04a49783          	lh	a5,74(s1)
    80004176:	ffe1                	bnez	a5,8000414e <iput+0x24>
    80004178:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000417a:	01048913          	addi	s2,s1,16
    8000417e:	854a                	mv	a0,s2
    80004180:	00001097          	auipc	ra,0x1
    80004184:	ab0080e7          	jalr	-1360(ra) # 80004c30 <acquiresleep>
    release(&itable.lock);
    80004188:	0009e517          	auipc	a0,0x9e
    8000418c:	e2050513          	addi	a0,a0,-480 # 800a1fa8 <itable>
    80004190:	ffffd097          	auipc	ra,0xffffd
    80004194:	c2e080e7          	jalr	-978(ra) # 80000dbe <release>
    itrunc(ip);
    80004198:	8526                	mv	a0,s1
    8000419a:	00000097          	auipc	ra,0x0
    8000419e:	ee4080e7          	jalr	-284(ra) # 8000407e <itrunc>
    ip->type = 0;
    800041a2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800041a6:	8526                	mv	a0,s1
    800041a8:	00000097          	auipc	ra,0x0
    800041ac:	cf8080e7          	jalr	-776(ra) # 80003ea0 <iupdate>
    ip->valid = 0;
    800041b0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800041b4:	854a                	mv	a0,s2
    800041b6:	00001097          	auipc	ra,0x1
    800041ba:	ad0080e7          	jalr	-1328(ra) # 80004c86 <releasesleep>
    acquire(&itable.lock);
    800041be:	0009e517          	auipc	a0,0x9e
    800041c2:	dea50513          	addi	a0,a0,-534 # 800a1fa8 <itable>
    800041c6:	ffffd097          	auipc	ra,0xffffd
    800041ca:	b44080e7          	jalr	-1212(ra) # 80000d0a <acquire>
    800041ce:	6902                	ld	s2,0(sp)
    800041d0:	bfbd                	j	8000414e <iput+0x24>

00000000800041d2 <iunlockput>:
{
    800041d2:	1101                	addi	sp,sp,-32
    800041d4:	ec06                	sd	ra,24(sp)
    800041d6:	e822                	sd	s0,16(sp)
    800041d8:	e426                	sd	s1,8(sp)
    800041da:	1000                	addi	s0,sp,32
    800041dc:	84aa                	mv	s1,a0
  iunlock(ip);
    800041de:	00000097          	auipc	ra,0x0
    800041e2:	e54080e7          	jalr	-428(ra) # 80004032 <iunlock>
  iput(ip);
    800041e6:	8526                	mv	a0,s1
    800041e8:	00000097          	auipc	ra,0x0
    800041ec:	f42080e7          	jalr	-190(ra) # 8000412a <iput>
}
    800041f0:	60e2                	ld	ra,24(sp)
    800041f2:	6442                	ld	s0,16(sp)
    800041f4:	64a2                	ld	s1,8(sp)
    800041f6:	6105                	addi	sp,sp,32
    800041f8:	8082                	ret

00000000800041fa <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800041fa:	1141                	addi	sp,sp,-16
    800041fc:	e422                	sd	s0,8(sp)
    800041fe:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004200:	411c                	lw	a5,0(a0)
    80004202:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004204:	415c                	lw	a5,4(a0)
    80004206:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004208:	04451783          	lh	a5,68(a0)
    8000420c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004210:	04a51783          	lh	a5,74(a0)
    80004214:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004218:	04c56783          	lwu	a5,76(a0)
    8000421c:	e99c                	sd	a5,16(a1)
}
    8000421e:	6422                	ld	s0,8(sp)
    80004220:	0141                	addi	sp,sp,16
    80004222:	8082                	ret

0000000080004224 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004224:	457c                	lw	a5,76(a0)
    80004226:	10d7e563          	bltu	a5,a3,80004330 <readi+0x10c>
{
    8000422a:	7159                	addi	sp,sp,-112
    8000422c:	f486                	sd	ra,104(sp)
    8000422e:	f0a2                	sd	s0,96(sp)
    80004230:	eca6                	sd	s1,88(sp)
    80004232:	e0d2                	sd	s4,64(sp)
    80004234:	fc56                	sd	s5,56(sp)
    80004236:	f85a                	sd	s6,48(sp)
    80004238:	f45e                	sd	s7,40(sp)
    8000423a:	1880                	addi	s0,sp,112
    8000423c:	8b2a                	mv	s6,a0
    8000423e:	8bae                	mv	s7,a1
    80004240:	8a32                	mv	s4,a2
    80004242:	84b6                	mv	s1,a3
    80004244:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004246:	9f35                	addw	a4,a4,a3
    return 0;
    80004248:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000424a:	0cd76a63          	bltu	a4,a3,8000431e <readi+0xfa>
    8000424e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80004250:	00e7f463          	bgeu	a5,a4,80004258 <readi+0x34>
    n = ip->size - off;
    80004254:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004258:	0a0a8963          	beqz	s5,8000430a <readi+0xe6>
    8000425c:	e8ca                	sd	s2,80(sp)
    8000425e:	f062                	sd	s8,32(sp)
    80004260:	ec66                	sd	s9,24(sp)
    80004262:	e86a                	sd	s10,16(sp)
    80004264:	e46e                	sd	s11,8(sp)
    80004266:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004268:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000426c:	5c7d                	li	s8,-1
    8000426e:	a82d                	j	800042a8 <readi+0x84>
    80004270:	020d1d93          	slli	s11,s10,0x20
    80004274:	020ddd93          	srli	s11,s11,0x20
    80004278:	05890613          	addi	a2,s2,88
    8000427c:	86ee                	mv	a3,s11
    8000427e:	963a                	add	a2,a2,a4
    80004280:	85d2                	mv	a1,s4
    80004282:	855e                	mv	a0,s7
    80004284:	fffff097          	auipc	ra,0xfffff
    80004288:	8e6080e7          	jalr	-1818(ra) # 80002b6a <either_copyout>
    8000428c:	05850d63          	beq	a0,s8,800042e6 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004290:	854a                	mv	a0,s2
    80004292:	fffff097          	auipc	ra,0xfffff
    80004296:	5d6080e7          	jalr	1494(ra) # 80003868 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000429a:	013d09bb          	addw	s3,s10,s3
    8000429e:	009d04bb          	addw	s1,s10,s1
    800042a2:	9a6e                	add	s4,s4,s11
    800042a4:	0559fd63          	bgeu	s3,s5,800042fe <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    800042a8:	00a4d59b          	srliw	a1,s1,0xa
    800042ac:	855a                	mv	a0,s6
    800042ae:	00000097          	auipc	ra,0x0
    800042b2:	88e080e7          	jalr	-1906(ra) # 80003b3c <bmap>
    800042b6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042ba:	c9b1                	beqz	a1,8000430e <readi+0xea>
    bp = bread(ip->dev, addr);
    800042bc:	000b2503          	lw	a0,0(s6)
    800042c0:	fffff097          	auipc	ra,0xfffff
    800042c4:	478080e7          	jalr	1144(ra) # 80003738 <bread>
    800042c8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042ca:	3ff4f713          	andi	a4,s1,1023
    800042ce:	40ec87bb          	subw	a5,s9,a4
    800042d2:	413a86bb          	subw	a3,s5,s3
    800042d6:	8d3e                	mv	s10,a5
    800042d8:	2781                	sext.w	a5,a5
    800042da:	0006861b          	sext.w	a2,a3
    800042de:	f8f679e3          	bgeu	a2,a5,80004270 <readi+0x4c>
    800042e2:	8d36                	mv	s10,a3
    800042e4:	b771                	j	80004270 <readi+0x4c>
      brelse(bp);
    800042e6:	854a                	mv	a0,s2
    800042e8:	fffff097          	auipc	ra,0xfffff
    800042ec:	580080e7          	jalr	1408(ra) # 80003868 <brelse>
      tot = -1;
    800042f0:	59fd                	li	s3,-1
      break;
    800042f2:	6946                	ld	s2,80(sp)
    800042f4:	7c02                	ld	s8,32(sp)
    800042f6:	6ce2                	ld	s9,24(sp)
    800042f8:	6d42                	ld	s10,16(sp)
    800042fa:	6da2                	ld	s11,8(sp)
    800042fc:	a831                	j	80004318 <readi+0xf4>
    800042fe:	6946                	ld	s2,80(sp)
    80004300:	7c02                	ld	s8,32(sp)
    80004302:	6ce2                	ld	s9,24(sp)
    80004304:	6d42                	ld	s10,16(sp)
    80004306:	6da2                	ld	s11,8(sp)
    80004308:	a801                	j	80004318 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000430a:	89d6                	mv	s3,s5
    8000430c:	a031                	j	80004318 <readi+0xf4>
    8000430e:	6946                	ld	s2,80(sp)
    80004310:	7c02                	ld	s8,32(sp)
    80004312:	6ce2                	ld	s9,24(sp)
    80004314:	6d42                	ld	s10,16(sp)
    80004316:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80004318:	0009851b          	sext.w	a0,s3
    8000431c:	69a6                	ld	s3,72(sp)
}
    8000431e:	70a6                	ld	ra,104(sp)
    80004320:	7406                	ld	s0,96(sp)
    80004322:	64e6                	ld	s1,88(sp)
    80004324:	6a06                	ld	s4,64(sp)
    80004326:	7ae2                	ld	s5,56(sp)
    80004328:	7b42                	ld	s6,48(sp)
    8000432a:	7ba2                	ld	s7,40(sp)
    8000432c:	6165                	addi	sp,sp,112
    8000432e:	8082                	ret
    return 0;
    80004330:	4501                	li	a0,0
}
    80004332:	8082                	ret

0000000080004334 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004334:	457c                	lw	a5,76(a0)
    80004336:	10d7ee63          	bltu	a5,a3,80004452 <writei+0x11e>
{
    8000433a:	7159                	addi	sp,sp,-112
    8000433c:	f486                	sd	ra,104(sp)
    8000433e:	f0a2                	sd	s0,96(sp)
    80004340:	e8ca                	sd	s2,80(sp)
    80004342:	e0d2                	sd	s4,64(sp)
    80004344:	fc56                	sd	s5,56(sp)
    80004346:	f85a                	sd	s6,48(sp)
    80004348:	f45e                	sd	s7,40(sp)
    8000434a:	1880                	addi	s0,sp,112
    8000434c:	8aaa                	mv	s5,a0
    8000434e:	8bae                	mv	s7,a1
    80004350:	8a32                	mv	s4,a2
    80004352:	8936                	mv	s2,a3
    80004354:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004356:	00e687bb          	addw	a5,a3,a4
    8000435a:	0ed7ee63          	bltu	a5,a3,80004456 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000435e:	00043737          	lui	a4,0x43
    80004362:	0ef76c63          	bltu	a4,a5,8000445a <writei+0x126>
    80004366:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004368:	0c0b0d63          	beqz	s6,80004442 <writei+0x10e>
    8000436c:	eca6                	sd	s1,88(sp)
    8000436e:	f062                	sd	s8,32(sp)
    80004370:	ec66                	sd	s9,24(sp)
    80004372:	e86a                	sd	s10,16(sp)
    80004374:	e46e                	sd	s11,8(sp)
    80004376:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004378:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000437c:	5c7d                	li	s8,-1
    8000437e:	a091                	j	800043c2 <writei+0x8e>
    80004380:	020d1d93          	slli	s11,s10,0x20
    80004384:	020ddd93          	srli	s11,s11,0x20
    80004388:	05848513          	addi	a0,s1,88
    8000438c:	86ee                	mv	a3,s11
    8000438e:	8652                	mv	a2,s4
    80004390:	85de                	mv	a1,s7
    80004392:	953a                	add	a0,a0,a4
    80004394:	fffff097          	auipc	ra,0xfffff
    80004398:	82c080e7          	jalr	-2004(ra) # 80002bc0 <either_copyin>
    8000439c:	07850263          	beq	a0,s8,80004400 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800043a0:	8526                	mv	a0,s1
    800043a2:	00000097          	auipc	ra,0x0
    800043a6:	770080e7          	jalr	1904(ra) # 80004b12 <log_write>
    brelse(bp);
    800043aa:	8526                	mv	a0,s1
    800043ac:	fffff097          	auipc	ra,0xfffff
    800043b0:	4bc080e7          	jalr	1212(ra) # 80003868 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043b4:	013d09bb          	addw	s3,s10,s3
    800043b8:	012d093b          	addw	s2,s10,s2
    800043bc:	9a6e                	add	s4,s4,s11
    800043be:	0569f663          	bgeu	s3,s6,8000440a <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800043c2:	00a9559b          	srliw	a1,s2,0xa
    800043c6:	8556                	mv	a0,s5
    800043c8:	fffff097          	auipc	ra,0xfffff
    800043cc:	774080e7          	jalr	1908(ra) # 80003b3c <bmap>
    800043d0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800043d4:	c99d                	beqz	a1,8000440a <writei+0xd6>
    bp = bread(ip->dev, addr);
    800043d6:	000aa503          	lw	a0,0(s5)
    800043da:	fffff097          	auipc	ra,0xfffff
    800043de:	35e080e7          	jalr	862(ra) # 80003738 <bread>
    800043e2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043e4:	3ff97713          	andi	a4,s2,1023
    800043e8:	40ec87bb          	subw	a5,s9,a4
    800043ec:	413b06bb          	subw	a3,s6,s3
    800043f0:	8d3e                	mv	s10,a5
    800043f2:	2781                	sext.w	a5,a5
    800043f4:	0006861b          	sext.w	a2,a3
    800043f8:	f8f674e3          	bgeu	a2,a5,80004380 <writei+0x4c>
    800043fc:	8d36                	mv	s10,a3
    800043fe:	b749                	j	80004380 <writei+0x4c>
      brelse(bp);
    80004400:	8526                	mv	a0,s1
    80004402:	fffff097          	auipc	ra,0xfffff
    80004406:	466080e7          	jalr	1126(ra) # 80003868 <brelse>
  }

  if(off > ip->size)
    8000440a:	04caa783          	lw	a5,76(s5)
    8000440e:	0327fc63          	bgeu	a5,s2,80004446 <writei+0x112>
    ip->size = off;
    80004412:	052aa623          	sw	s2,76(s5)
    80004416:	64e6                	ld	s1,88(sp)
    80004418:	7c02                	ld	s8,32(sp)
    8000441a:	6ce2                	ld	s9,24(sp)
    8000441c:	6d42                	ld	s10,16(sp)
    8000441e:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004420:	8556                	mv	a0,s5
    80004422:	00000097          	auipc	ra,0x0
    80004426:	a7e080e7          	jalr	-1410(ra) # 80003ea0 <iupdate>

  return tot;
    8000442a:	0009851b          	sext.w	a0,s3
    8000442e:	69a6                	ld	s3,72(sp)
}
    80004430:	70a6                	ld	ra,104(sp)
    80004432:	7406                	ld	s0,96(sp)
    80004434:	6946                	ld	s2,80(sp)
    80004436:	6a06                	ld	s4,64(sp)
    80004438:	7ae2                	ld	s5,56(sp)
    8000443a:	7b42                	ld	s6,48(sp)
    8000443c:	7ba2                	ld	s7,40(sp)
    8000443e:	6165                	addi	sp,sp,112
    80004440:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004442:	89da                	mv	s3,s6
    80004444:	bff1                	j	80004420 <writei+0xec>
    80004446:	64e6                	ld	s1,88(sp)
    80004448:	7c02                	ld	s8,32(sp)
    8000444a:	6ce2                	ld	s9,24(sp)
    8000444c:	6d42                	ld	s10,16(sp)
    8000444e:	6da2                	ld	s11,8(sp)
    80004450:	bfc1                	j	80004420 <writei+0xec>
    return -1;
    80004452:	557d                	li	a0,-1
}
    80004454:	8082                	ret
    return -1;
    80004456:	557d                	li	a0,-1
    80004458:	bfe1                	j	80004430 <writei+0xfc>
    return -1;
    8000445a:	557d                	li	a0,-1
    8000445c:	bfd1                	j	80004430 <writei+0xfc>

000000008000445e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000445e:	1141                	addi	sp,sp,-16
    80004460:	e406                	sd	ra,8(sp)
    80004462:	e022                	sd	s0,0(sp)
    80004464:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004466:	4639                	li	a2,14
    80004468:	ffffd097          	auipc	ra,0xffffd
    8000446c:	a6e080e7          	jalr	-1426(ra) # 80000ed6 <strncmp>
}
    80004470:	60a2                	ld	ra,8(sp)
    80004472:	6402                	ld	s0,0(sp)
    80004474:	0141                	addi	sp,sp,16
    80004476:	8082                	ret

0000000080004478 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004478:	7139                	addi	sp,sp,-64
    8000447a:	fc06                	sd	ra,56(sp)
    8000447c:	f822                	sd	s0,48(sp)
    8000447e:	f426                	sd	s1,40(sp)
    80004480:	f04a                	sd	s2,32(sp)
    80004482:	ec4e                	sd	s3,24(sp)
    80004484:	e852                	sd	s4,16(sp)
    80004486:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004488:	04451703          	lh	a4,68(a0)
    8000448c:	4785                	li	a5,1
    8000448e:	00f71a63          	bne	a4,a5,800044a2 <dirlookup+0x2a>
    80004492:	892a                	mv	s2,a0
    80004494:	89ae                	mv	s3,a1
    80004496:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004498:	457c                	lw	a5,76(a0)
    8000449a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000449c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000449e:	e79d                	bnez	a5,800044cc <dirlookup+0x54>
    800044a0:	a8a5                	j	80004518 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800044a2:	00004517          	auipc	a0,0x4
    800044a6:	2f650513          	addi	a0,a0,758 # 80008798 <__func__.1+0x790>
    800044aa:	ffffc097          	auipc	ra,0xffffc
    800044ae:	0b6080e7          	jalr	182(ra) # 80000560 <panic>
      panic("dirlookup read");
    800044b2:	00004517          	auipc	a0,0x4
    800044b6:	2fe50513          	addi	a0,a0,766 # 800087b0 <__func__.1+0x7a8>
    800044ba:	ffffc097          	auipc	ra,0xffffc
    800044be:	0a6080e7          	jalr	166(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044c2:	24c1                	addiw	s1,s1,16
    800044c4:	04c92783          	lw	a5,76(s2)
    800044c8:	04f4f763          	bgeu	s1,a5,80004516 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044cc:	4741                	li	a4,16
    800044ce:	86a6                	mv	a3,s1
    800044d0:	fc040613          	addi	a2,s0,-64
    800044d4:	4581                	li	a1,0
    800044d6:	854a                	mv	a0,s2
    800044d8:	00000097          	auipc	ra,0x0
    800044dc:	d4c080e7          	jalr	-692(ra) # 80004224 <readi>
    800044e0:	47c1                	li	a5,16
    800044e2:	fcf518e3          	bne	a0,a5,800044b2 <dirlookup+0x3a>
    if(de.inum == 0)
    800044e6:	fc045783          	lhu	a5,-64(s0)
    800044ea:	dfe1                	beqz	a5,800044c2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800044ec:	fc240593          	addi	a1,s0,-62
    800044f0:	854e                	mv	a0,s3
    800044f2:	00000097          	auipc	ra,0x0
    800044f6:	f6c080e7          	jalr	-148(ra) # 8000445e <namecmp>
    800044fa:	f561                	bnez	a0,800044c2 <dirlookup+0x4a>
      if(poff)
    800044fc:	000a0463          	beqz	s4,80004504 <dirlookup+0x8c>
        *poff = off;
    80004500:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004504:	fc045583          	lhu	a1,-64(s0)
    80004508:	00092503          	lw	a0,0(s2)
    8000450c:	fffff097          	auipc	ra,0xfffff
    80004510:	720080e7          	jalr	1824(ra) # 80003c2c <iget>
    80004514:	a011                	j	80004518 <dirlookup+0xa0>
  return 0;
    80004516:	4501                	li	a0,0
}
    80004518:	70e2                	ld	ra,56(sp)
    8000451a:	7442                	ld	s0,48(sp)
    8000451c:	74a2                	ld	s1,40(sp)
    8000451e:	7902                	ld	s2,32(sp)
    80004520:	69e2                	ld	s3,24(sp)
    80004522:	6a42                	ld	s4,16(sp)
    80004524:	6121                	addi	sp,sp,64
    80004526:	8082                	ret

0000000080004528 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004528:	711d                	addi	sp,sp,-96
    8000452a:	ec86                	sd	ra,88(sp)
    8000452c:	e8a2                	sd	s0,80(sp)
    8000452e:	e4a6                	sd	s1,72(sp)
    80004530:	e0ca                	sd	s2,64(sp)
    80004532:	fc4e                	sd	s3,56(sp)
    80004534:	f852                	sd	s4,48(sp)
    80004536:	f456                	sd	s5,40(sp)
    80004538:	f05a                	sd	s6,32(sp)
    8000453a:	ec5e                	sd	s7,24(sp)
    8000453c:	e862                	sd	s8,16(sp)
    8000453e:	e466                	sd	s9,8(sp)
    80004540:	1080                	addi	s0,sp,96
    80004542:	84aa                	mv	s1,a0
    80004544:	8b2e                	mv	s6,a1
    80004546:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004548:	00054703          	lbu	a4,0(a0)
    8000454c:	02f00793          	li	a5,47
    80004550:	02f70263          	beq	a4,a5,80004574 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004554:	ffffe097          	auipc	ra,0xffffe
    80004558:	a6c080e7          	jalr	-1428(ra) # 80001fc0 <myproc>
    8000455c:	15053503          	ld	a0,336(a0)
    80004560:	00000097          	auipc	ra,0x0
    80004564:	9ce080e7          	jalr	-1586(ra) # 80003f2e <idup>
    80004568:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000456a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000456e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004570:	4b85                	li	s7,1
    80004572:	a875                	j	8000462e <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80004574:	4585                	li	a1,1
    80004576:	4505                	li	a0,1
    80004578:	fffff097          	auipc	ra,0xfffff
    8000457c:	6b4080e7          	jalr	1716(ra) # 80003c2c <iget>
    80004580:	8a2a                	mv	s4,a0
    80004582:	b7e5                	j	8000456a <namex+0x42>
      iunlockput(ip);
    80004584:	8552                	mv	a0,s4
    80004586:	00000097          	auipc	ra,0x0
    8000458a:	c4c080e7          	jalr	-948(ra) # 800041d2 <iunlockput>
      return 0;
    8000458e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004590:	8552                	mv	a0,s4
    80004592:	60e6                	ld	ra,88(sp)
    80004594:	6446                	ld	s0,80(sp)
    80004596:	64a6                	ld	s1,72(sp)
    80004598:	6906                	ld	s2,64(sp)
    8000459a:	79e2                	ld	s3,56(sp)
    8000459c:	7a42                	ld	s4,48(sp)
    8000459e:	7aa2                	ld	s5,40(sp)
    800045a0:	7b02                	ld	s6,32(sp)
    800045a2:	6be2                	ld	s7,24(sp)
    800045a4:	6c42                	ld	s8,16(sp)
    800045a6:	6ca2                	ld	s9,8(sp)
    800045a8:	6125                	addi	sp,sp,96
    800045aa:	8082                	ret
      iunlock(ip);
    800045ac:	8552                	mv	a0,s4
    800045ae:	00000097          	auipc	ra,0x0
    800045b2:	a84080e7          	jalr	-1404(ra) # 80004032 <iunlock>
      return ip;
    800045b6:	bfe9                	j	80004590 <namex+0x68>
      iunlockput(ip);
    800045b8:	8552                	mv	a0,s4
    800045ba:	00000097          	auipc	ra,0x0
    800045be:	c18080e7          	jalr	-1000(ra) # 800041d2 <iunlockput>
      return 0;
    800045c2:	8a4e                	mv	s4,s3
    800045c4:	b7f1                	j	80004590 <namex+0x68>
  len = path - s;
    800045c6:	40998633          	sub	a2,s3,s1
    800045ca:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800045ce:	099c5863          	bge	s8,s9,8000465e <namex+0x136>
    memmove(name, s, DIRSIZ);
    800045d2:	4639                	li	a2,14
    800045d4:	85a6                	mv	a1,s1
    800045d6:	8556                	mv	a0,s5
    800045d8:	ffffd097          	auipc	ra,0xffffd
    800045dc:	88a080e7          	jalr	-1910(ra) # 80000e62 <memmove>
    800045e0:	84ce                	mv	s1,s3
  while(*path == '/')
    800045e2:	0004c783          	lbu	a5,0(s1)
    800045e6:	01279763          	bne	a5,s2,800045f4 <namex+0xcc>
    path++;
    800045ea:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045ec:	0004c783          	lbu	a5,0(s1)
    800045f0:	ff278de3          	beq	a5,s2,800045ea <namex+0xc2>
    ilock(ip);
    800045f4:	8552                	mv	a0,s4
    800045f6:	00000097          	auipc	ra,0x0
    800045fa:	976080e7          	jalr	-1674(ra) # 80003f6c <ilock>
    if(ip->type != T_DIR){
    800045fe:	044a1783          	lh	a5,68(s4)
    80004602:	f97791e3          	bne	a5,s7,80004584 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004606:	000b0563          	beqz	s6,80004610 <namex+0xe8>
    8000460a:	0004c783          	lbu	a5,0(s1)
    8000460e:	dfd9                	beqz	a5,800045ac <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004610:	4601                	li	a2,0
    80004612:	85d6                	mv	a1,s5
    80004614:	8552                	mv	a0,s4
    80004616:	00000097          	auipc	ra,0x0
    8000461a:	e62080e7          	jalr	-414(ra) # 80004478 <dirlookup>
    8000461e:	89aa                	mv	s3,a0
    80004620:	dd41                	beqz	a0,800045b8 <namex+0x90>
    iunlockput(ip);
    80004622:	8552                	mv	a0,s4
    80004624:	00000097          	auipc	ra,0x0
    80004628:	bae080e7          	jalr	-1106(ra) # 800041d2 <iunlockput>
    ip = next;
    8000462c:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000462e:	0004c783          	lbu	a5,0(s1)
    80004632:	01279763          	bne	a5,s2,80004640 <namex+0x118>
    path++;
    80004636:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004638:	0004c783          	lbu	a5,0(s1)
    8000463c:	ff278de3          	beq	a5,s2,80004636 <namex+0x10e>
  if(*path == 0)
    80004640:	cb9d                	beqz	a5,80004676 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004642:	0004c783          	lbu	a5,0(s1)
    80004646:	89a6                	mv	s3,s1
  len = path - s;
    80004648:	4c81                	li	s9,0
    8000464a:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000464c:	01278963          	beq	a5,s2,8000465e <namex+0x136>
    80004650:	dbbd                	beqz	a5,800045c6 <namex+0x9e>
    path++;
    80004652:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004654:	0009c783          	lbu	a5,0(s3)
    80004658:	ff279ce3          	bne	a5,s2,80004650 <namex+0x128>
    8000465c:	b7ad                	j	800045c6 <namex+0x9e>
    memmove(name, s, len);
    8000465e:	2601                	sext.w	a2,a2
    80004660:	85a6                	mv	a1,s1
    80004662:	8556                	mv	a0,s5
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	7fe080e7          	jalr	2046(ra) # 80000e62 <memmove>
    name[len] = 0;
    8000466c:	9cd6                	add	s9,s9,s5
    8000466e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004672:	84ce                	mv	s1,s3
    80004674:	b7bd                	j	800045e2 <namex+0xba>
  if(nameiparent){
    80004676:	f00b0de3          	beqz	s6,80004590 <namex+0x68>
    iput(ip);
    8000467a:	8552                	mv	a0,s4
    8000467c:	00000097          	auipc	ra,0x0
    80004680:	aae080e7          	jalr	-1362(ra) # 8000412a <iput>
    return 0;
    80004684:	4a01                	li	s4,0
    80004686:	b729                	j	80004590 <namex+0x68>

0000000080004688 <dirlink>:
{
    80004688:	7139                	addi	sp,sp,-64
    8000468a:	fc06                	sd	ra,56(sp)
    8000468c:	f822                	sd	s0,48(sp)
    8000468e:	f04a                	sd	s2,32(sp)
    80004690:	ec4e                	sd	s3,24(sp)
    80004692:	e852                	sd	s4,16(sp)
    80004694:	0080                	addi	s0,sp,64
    80004696:	892a                	mv	s2,a0
    80004698:	8a2e                	mv	s4,a1
    8000469a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000469c:	4601                	li	a2,0
    8000469e:	00000097          	auipc	ra,0x0
    800046a2:	dda080e7          	jalr	-550(ra) # 80004478 <dirlookup>
    800046a6:	ed25                	bnez	a0,8000471e <dirlink+0x96>
    800046a8:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046aa:	04c92483          	lw	s1,76(s2)
    800046ae:	c49d                	beqz	s1,800046dc <dirlink+0x54>
    800046b0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046b2:	4741                	li	a4,16
    800046b4:	86a6                	mv	a3,s1
    800046b6:	fc040613          	addi	a2,s0,-64
    800046ba:	4581                	li	a1,0
    800046bc:	854a                	mv	a0,s2
    800046be:	00000097          	auipc	ra,0x0
    800046c2:	b66080e7          	jalr	-1178(ra) # 80004224 <readi>
    800046c6:	47c1                	li	a5,16
    800046c8:	06f51163          	bne	a0,a5,8000472a <dirlink+0xa2>
    if(de.inum == 0)
    800046cc:	fc045783          	lhu	a5,-64(s0)
    800046d0:	c791                	beqz	a5,800046dc <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046d2:	24c1                	addiw	s1,s1,16
    800046d4:	04c92783          	lw	a5,76(s2)
    800046d8:	fcf4ede3          	bltu	s1,a5,800046b2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800046dc:	4639                	li	a2,14
    800046de:	85d2                	mv	a1,s4
    800046e0:	fc240513          	addi	a0,s0,-62
    800046e4:	ffffd097          	auipc	ra,0xffffd
    800046e8:	828080e7          	jalr	-2008(ra) # 80000f0c <strncpy>
  de.inum = inum;
    800046ec:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046f0:	4741                	li	a4,16
    800046f2:	86a6                	mv	a3,s1
    800046f4:	fc040613          	addi	a2,s0,-64
    800046f8:	4581                	li	a1,0
    800046fa:	854a                	mv	a0,s2
    800046fc:	00000097          	auipc	ra,0x0
    80004700:	c38080e7          	jalr	-968(ra) # 80004334 <writei>
    80004704:	1541                	addi	a0,a0,-16
    80004706:	00a03533          	snez	a0,a0
    8000470a:	40a00533          	neg	a0,a0
    8000470e:	74a2                	ld	s1,40(sp)
}
    80004710:	70e2                	ld	ra,56(sp)
    80004712:	7442                	ld	s0,48(sp)
    80004714:	7902                	ld	s2,32(sp)
    80004716:	69e2                	ld	s3,24(sp)
    80004718:	6a42                	ld	s4,16(sp)
    8000471a:	6121                	addi	sp,sp,64
    8000471c:	8082                	ret
    iput(ip);
    8000471e:	00000097          	auipc	ra,0x0
    80004722:	a0c080e7          	jalr	-1524(ra) # 8000412a <iput>
    return -1;
    80004726:	557d                	li	a0,-1
    80004728:	b7e5                	j	80004710 <dirlink+0x88>
      panic("dirlink read");
    8000472a:	00004517          	auipc	a0,0x4
    8000472e:	09650513          	addi	a0,a0,150 # 800087c0 <__func__.1+0x7b8>
    80004732:	ffffc097          	auipc	ra,0xffffc
    80004736:	e2e080e7          	jalr	-466(ra) # 80000560 <panic>

000000008000473a <namei>:

struct inode*
namei(char *path)
{
    8000473a:	1101                	addi	sp,sp,-32
    8000473c:	ec06                	sd	ra,24(sp)
    8000473e:	e822                	sd	s0,16(sp)
    80004740:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004742:	fe040613          	addi	a2,s0,-32
    80004746:	4581                	li	a1,0
    80004748:	00000097          	auipc	ra,0x0
    8000474c:	de0080e7          	jalr	-544(ra) # 80004528 <namex>
}
    80004750:	60e2                	ld	ra,24(sp)
    80004752:	6442                	ld	s0,16(sp)
    80004754:	6105                	addi	sp,sp,32
    80004756:	8082                	ret

0000000080004758 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004758:	1141                	addi	sp,sp,-16
    8000475a:	e406                	sd	ra,8(sp)
    8000475c:	e022                	sd	s0,0(sp)
    8000475e:	0800                	addi	s0,sp,16
    80004760:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004762:	4585                	li	a1,1
    80004764:	00000097          	auipc	ra,0x0
    80004768:	dc4080e7          	jalr	-572(ra) # 80004528 <namex>
}
    8000476c:	60a2                	ld	ra,8(sp)
    8000476e:	6402                	ld	s0,0(sp)
    80004770:	0141                	addi	sp,sp,16
    80004772:	8082                	ret

0000000080004774 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004774:	1101                	addi	sp,sp,-32
    80004776:	ec06                	sd	ra,24(sp)
    80004778:	e822                	sd	s0,16(sp)
    8000477a:	e426                	sd	s1,8(sp)
    8000477c:	e04a                	sd	s2,0(sp)
    8000477e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004780:	0009f917          	auipc	s2,0x9f
    80004784:	2d090913          	addi	s2,s2,720 # 800a3a50 <log>
    80004788:	01892583          	lw	a1,24(s2)
    8000478c:	02892503          	lw	a0,40(s2)
    80004790:	fffff097          	auipc	ra,0xfffff
    80004794:	fa8080e7          	jalr	-88(ra) # 80003738 <bread>
    80004798:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000479a:	02c92603          	lw	a2,44(s2)
    8000479e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800047a0:	00c05f63          	blez	a2,800047be <write_head+0x4a>
    800047a4:	0009f717          	auipc	a4,0x9f
    800047a8:	2dc70713          	addi	a4,a4,732 # 800a3a80 <log+0x30>
    800047ac:	87aa                	mv	a5,a0
    800047ae:	060a                	slli	a2,a2,0x2
    800047b0:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800047b2:	4314                	lw	a3,0(a4)
    800047b4:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800047b6:	0711                	addi	a4,a4,4
    800047b8:	0791                	addi	a5,a5,4
    800047ba:	fec79ce3          	bne	a5,a2,800047b2 <write_head+0x3e>
  }
  bwrite(buf);
    800047be:	8526                	mv	a0,s1
    800047c0:	fffff097          	auipc	ra,0xfffff
    800047c4:	06a080e7          	jalr	106(ra) # 8000382a <bwrite>
  brelse(buf);
    800047c8:	8526                	mv	a0,s1
    800047ca:	fffff097          	auipc	ra,0xfffff
    800047ce:	09e080e7          	jalr	158(ra) # 80003868 <brelse>
}
    800047d2:	60e2                	ld	ra,24(sp)
    800047d4:	6442                	ld	s0,16(sp)
    800047d6:	64a2                	ld	s1,8(sp)
    800047d8:	6902                	ld	s2,0(sp)
    800047da:	6105                	addi	sp,sp,32
    800047dc:	8082                	ret

00000000800047de <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800047de:	0009f797          	auipc	a5,0x9f
    800047e2:	29e7a783          	lw	a5,670(a5) # 800a3a7c <log+0x2c>
    800047e6:	0af05d63          	blez	a5,800048a0 <install_trans+0xc2>
{
    800047ea:	7139                	addi	sp,sp,-64
    800047ec:	fc06                	sd	ra,56(sp)
    800047ee:	f822                	sd	s0,48(sp)
    800047f0:	f426                	sd	s1,40(sp)
    800047f2:	f04a                	sd	s2,32(sp)
    800047f4:	ec4e                	sd	s3,24(sp)
    800047f6:	e852                	sd	s4,16(sp)
    800047f8:	e456                	sd	s5,8(sp)
    800047fa:	e05a                	sd	s6,0(sp)
    800047fc:	0080                	addi	s0,sp,64
    800047fe:	8b2a                	mv	s6,a0
    80004800:	0009fa97          	auipc	s5,0x9f
    80004804:	280a8a93          	addi	s5,s5,640 # 800a3a80 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004808:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000480a:	0009f997          	auipc	s3,0x9f
    8000480e:	24698993          	addi	s3,s3,582 # 800a3a50 <log>
    80004812:	a00d                	j	80004834 <install_trans+0x56>
    brelse(lbuf);
    80004814:	854a                	mv	a0,s2
    80004816:	fffff097          	auipc	ra,0xfffff
    8000481a:	052080e7          	jalr	82(ra) # 80003868 <brelse>
    brelse(dbuf);
    8000481e:	8526                	mv	a0,s1
    80004820:	fffff097          	auipc	ra,0xfffff
    80004824:	048080e7          	jalr	72(ra) # 80003868 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004828:	2a05                	addiw	s4,s4,1
    8000482a:	0a91                	addi	s5,s5,4
    8000482c:	02c9a783          	lw	a5,44(s3)
    80004830:	04fa5e63          	bge	s4,a5,8000488c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004834:	0189a583          	lw	a1,24(s3)
    80004838:	014585bb          	addw	a1,a1,s4
    8000483c:	2585                	addiw	a1,a1,1
    8000483e:	0289a503          	lw	a0,40(s3)
    80004842:	fffff097          	auipc	ra,0xfffff
    80004846:	ef6080e7          	jalr	-266(ra) # 80003738 <bread>
    8000484a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000484c:	000aa583          	lw	a1,0(s5)
    80004850:	0289a503          	lw	a0,40(s3)
    80004854:	fffff097          	auipc	ra,0xfffff
    80004858:	ee4080e7          	jalr	-284(ra) # 80003738 <bread>
    8000485c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000485e:	40000613          	li	a2,1024
    80004862:	05890593          	addi	a1,s2,88
    80004866:	05850513          	addi	a0,a0,88
    8000486a:	ffffc097          	auipc	ra,0xffffc
    8000486e:	5f8080e7          	jalr	1528(ra) # 80000e62 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004872:	8526                	mv	a0,s1
    80004874:	fffff097          	auipc	ra,0xfffff
    80004878:	fb6080e7          	jalr	-74(ra) # 8000382a <bwrite>
    if(recovering == 0)
    8000487c:	f80b1ce3          	bnez	s6,80004814 <install_trans+0x36>
      bunpin(dbuf);
    80004880:	8526                	mv	a0,s1
    80004882:	fffff097          	auipc	ra,0xfffff
    80004886:	0be080e7          	jalr	190(ra) # 80003940 <bunpin>
    8000488a:	b769                	j	80004814 <install_trans+0x36>
}
    8000488c:	70e2                	ld	ra,56(sp)
    8000488e:	7442                	ld	s0,48(sp)
    80004890:	74a2                	ld	s1,40(sp)
    80004892:	7902                	ld	s2,32(sp)
    80004894:	69e2                	ld	s3,24(sp)
    80004896:	6a42                	ld	s4,16(sp)
    80004898:	6aa2                	ld	s5,8(sp)
    8000489a:	6b02                	ld	s6,0(sp)
    8000489c:	6121                	addi	sp,sp,64
    8000489e:	8082                	ret
    800048a0:	8082                	ret

00000000800048a2 <initlog>:
{
    800048a2:	7179                	addi	sp,sp,-48
    800048a4:	f406                	sd	ra,40(sp)
    800048a6:	f022                	sd	s0,32(sp)
    800048a8:	ec26                	sd	s1,24(sp)
    800048aa:	e84a                	sd	s2,16(sp)
    800048ac:	e44e                	sd	s3,8(sp)
    800048ae:	1800                	addi	s0,sp,48
    800048b0:	892a                	mv	s2,a0
    800048b2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800048b4:	0009f497          	auipc	s1,0x9f
    800048b8:	19c48493          	addi	s1,s1,412 # 800a3a50 <log>
    800048bc:	00004597          	auipc	a1,0x4
    800048c0:	f1458593          	addi	a1,a1,-236 # 800087d0 <__func__.1+0x7c8>
    800048c4:	8526                	mv	a0,s1
    800048c6:	ffffc097          	auipc	ra,0xffffc
    800048ca:	3b4080e7          	jalr	948(ra) # 80000c7a <initlock>
  log.start = sb->logstart;
    800048ce:	0149a583          	lw	a1,20(s3)
    800048d2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800048d4:	0109a783          	lw	a5,16(s3)
    800048d8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800048da:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800048de:	854a                	mv	a0,s2
    800048e0:	fffff097          	auipc	ra,0xfffff
    800048e4:	e58080e7          	jalr	-424(ra) # 80003738 <bread>
  log.lh.n = lh->n;
    800048e8:	4d30                	lw	a2,88(a0)
    800048ea:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800048ec:	00c05f63          	blez	a2,8000490a <initlog+0x68>
    800048f0:	87aa                	mv	a5,a0
    800048f2:	0009f717          	auipc	a4,0x9f
    800048f6:	18e70713          	addi	a4,a4,398 # 800a3a80 <log+0x30>
    800048fa:	060a                	slli	a2,a2,0x2
    800048fc:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800048fe:	4ff4                	lw	a3,92(a5)
    80004900:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004902:	0791                	addi	a5,a5,4
    80004904:	0711                	addi	a4,a4,4
    80004906:	fec79ce3          	bne	a5,a2,800048fe <initlog+0x5c>
  brelse(buf);
    8000490a:	fffff097          	auipc	ra,0xfffff
    8000490e:	f5e080e7          	jalr	-162(ra) # 80003868 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004912:	4505                	li	a0,1
    80004914:	00000097          	auipc	ra,0x0
    80004918:	eca080e7          	jalr	-310(ra) # 800047de <install_trans>
  log.lh.n = 0;
    8000491c:	0009f797          	auipc	a5,0x9f
    80004920:	1607a023          	sw	zero,352(a5) # 800a3a7c <log+0x2c>
  write_head(); // clear the log
    80004924:	00000097          	auipc	ra,0x0
    80004928:	e50080e7          	jalr	-432(ra) # 80004774 <write_head>
}
    8000492c:	70a2                	ld	ra,40(sp)
    8000492e:	7402                	ld	s0,32(sp)
    80004930:	64e2                	ld	s1,24(sp)
    80004932:	6942                	ld	s2,16(sp)
    80004934:	69a2                	ld	s3,8(sp)
    80004936:	6145                	addi	sp,sp,48
    80004938:	8082                	ret

000000008000493a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000493a:	1101                	addi	sp,sp,-32
    8000493c:	ec06                	sd	ra,24(sp)
    8000493e:	e822                	sd	s0,16(sp)
    80004940:	e426                	sd	s1,8(sp)
    80004942:	e04a                	sd	s2,0(sp)
    80004944:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004946:	0009f517          	auipc	a0,0x9f
    8000494a:	10a50513          	addi	a0,a0,266 # 800a3a50 <log>
    8000494e:	ffffc097          	auipc	ra,0xffffc
    80004952:	3bc080e7          	jalr	956(ra) # 80000d0a <acquire>
  while(1){
    if(log.committing){
    80004956:	0009f497          	auipc	s1,0x9f
    8000495a:	0fa48493          	addi	s1,s1,250 # 800a3a50 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000495e:	4979                	li	s2,30
    80004960:	a039                	j	8000496e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004962:	85a6                	mv	a1,s1
    80004964:	8526                	mv	a0,s1
    80004966:	ffffe097          	auipc	ra,0xffffe
    8000496a:	dfc080e7          	jalr	-516(ra) # 80002762 <sleep>
    if(log.committing){
    8000496e:	50dc                	lw	a5,36(s1)
    80004970:	fbed                	bnez	a5,80004962 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004972:	5098                	lw	a4,32(s1)
    80004974:	2705                	addiw	a4,a4,1
    80004976:	0027179b          	slliw	a5,a4,0x2
    8000497a:	9fb9                	addw	a5,a5,a4
    8000497c:	0017979b          	slliw	a5,a5,0x1
    80004980:	54d4                	lw	a3,44(s1)
    80004982:	9fb5                	addw	a5,a5,a3
    80004984:	00f95963          	bge	s2,a5,80004996 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004988:	85a6                	mv	a1,s1
    8000498a:	8526                	mv	a0,s1
    8000498c:	ffffe097          	auipc	ra,0xffffe
    80004990:	dd6080e7          	jalr	-554(ra) # 80002762 <sleep>
    80004994:	bfe9                	j	8000496e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004996:	0009f517          	auipc	a0,0x9f
    8000499a:	0ba50513          	addi	a0,a0,186 # 800a3a50 <log>
    8000499e:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800049a0:	ffffc097          	auipc	ra,0xffffc
    800049a4:	41e080e7          	jalr	1054(ra) # 80000dbe <release>
      break;
    }
  }
}
    800049a8:	60e2                	ld	ra,24(sp)
    800049aa:	6442                	ld	s0,16(sp)
    800049ac:	64a2                	ld	s1,8(sp)
    800049ae:	6902                	ld	s2,0(sp)
    800049b0:	6105                	addi	sp,sp,32
    800049b2:	8082                	ret

00000000800049b4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800049b4:	7139                	addi	sp,sp,-64
    800049b6:	fc06                	sd	ra,56(sp)
    800049b8:	f822                	sd	s0,48(sp)
    800049ba:	f426                	sd	s1,40(sp)
    800049bc:	f04a                	sd	s2,32(sp)
    800049be:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800049c0:	0009f497          	auipc	s1,0x9f
    800049c4:	09048493          	addi	s1,s1,144 # 800a3a50 <log>
    800049c8:	8526                	mv	a0,s1
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	340080e7          	jalr	832(ra) # 80000d0a <acquire>
  log.outstanding -= 1;
    800049d2:	509c                	lw	a5,32(s1)
    800049d4:	37fd                	addiw	a5,a5,-1
    800049d6:	0007891b          	sext.w	s2,a5
    800049da:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800049dc:	50dc                	lw	a5,36(s1)
    800049de:	e7b9                	bnez	a5,80004a2c <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    800049e0:	06091163          	bnez	s2,80004a42 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800049e4:	0009f497          	auipc	s1,0x9f
    800049e8:	06c48493          	addi	s1,s1,108 # 800a3a50 <log>
    800049ec:	4785                	li	a5,1
    800049ee:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800049f0:	8526                	mv	a0,s1
    800049f2:	ffffc097          	auipc	ra,0xffffc
    800049f6:	3cc080e7          	jalr	972(ra) # 80000dbe <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800049fa:	54dc                	lw	a5,44(s1)
    800049fc:	06f04763          	bgtz	a5,80004a6a <end_op+0xb6>
    acquire(&log.lock);
    80004a00:	0009f497          	auipc	s1,0x9f
    80004a04:	05048493          	addi	s1,s1,80 # 800a3a50 <log>
    80004a08:	8526                	mv	a0,s1
    80004a0a:	ffffc097          	auipc	ra,0xffffc
    80004a0e:	300080e7          	jalr	768(ra) # 80000d0a <acquire>
    log.committing = 0;
    80004a12:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004a16:	8526                	mv	a0,s1
    80004a18:	ffffe097          	auipc	ra,0xffffe
    80004a1c:	dae080e7          	jalr	-594(ra) # 800027c6 <wakeup>
    release(&log.lock);
    80004a20:	8526                	mv	a0,s1
    80004a22:	ffffc097          	auipc	ra,0xffffc
    80004a26:	39c080e7          	jalr	924(ra) # 80000dbe <release>
}
    80004a2a:	a815                	j	80004a5e <end_op+0xaa>
    80004a2c:	ec4e                	sd	s3,24(sp)
    80004a2e:	e852                	sd	s4,16(sp)
    80004a30:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004a32:	00004517          	auipc	a0,0x4
    80004a36:	da650513          	addi	a0,a0,-602 # 800087d8 <__func__.1+0x7d0>
    80004a3a:	ffffc097          	auipc	ra,0xffffc
    80004a3e:	b26080e7          	jalr	-1242(ra) # 80000560 <panic>
    wakeup(&log);
    80004a42:	0009f497          	auipc	s1,0x9f
    80004a46:	00e48493          	addi	s1,s1,14 # 800a3a50 <log>
    80004a4a:	8526                	mv	a0,s1
    80004a4c:	ffffe097          	auipc	ra,0xffffe
    80004a50:	d7a080e7          	jalr	-646(ra) # 800027c6 <wakeup>
  release(&log.lock);
    80004a54:	8526                	mv	a0,s1
    80004a56:	ffffc097          	auipc	ra,0xffffc
    80004a5a:	368080e7          	jalr	872(ra) # 80000dbe <release>
}
    80004a5e:	70e2                	ld	ra,56(sp)
    80004a60:	7442                	ld	s0,48(sp)
    80004a62:	74a2                	ld	s1,40(sp)
    80004a64:	7902                	ld	s2,32(sp)
    80004a66:	6121                	addi	sp,sp,64
    80004a68:	8082                	ret
    80004a6a:	ec4e                	sd	s3,24(sp)
    80004a6c:	e852                	sd	s4,16(sp)
    80004a6e:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a70:	0009fa97          	auipc	s5,0x9f
    80004a74:	010a8a93          	addi	s5,s5,16 # 800a3a80 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004a78:	0009fa17          	auipc	s4,0x9f
    80004a7c:	fd8a0a13          	addi	s4,s4,-40 # 800a3a50 <log>
    80004a80:	018a2583          	lw	a1,24(s4)
    80004a84:	012585bb          	addw	a1,a1,s2
    80004a88:	2585                	addiw	a1,a1,1
    80004a8a:	028a2503          	lw	a0,40(s4)
    80004a8e:	fffff097          	auipc	ra,0xfffff
    80004a92:	caa080e7          	jalr	-854(ra) # 80003738 <bread>
    80004a96:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004a98:	000aa583          	lw	a1,0(s5)
    80004a9c:	028a2503          	lw	a0,40(s4)
    80004aa0:	fffff097          	auipc	ra,0xfffff
    80004aa4:	c98080e7          	jalr	-872(ra) # 80003738 <bread>
    80004aa8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004aaa:	40000613          	li	a2,1024
    80004aae:	05850593          	addi	a1,a0,88
    80004ab2:	05848513          	addi	a0,s1,88
    80004ab6:	ffffc097          	auipc	ra,0xffffc
    80004aba:	3ac080e7          	jalr	940(ra) # 80000e62 <memmove>
    bwrite(to);  // write the log
    80004abe:	8526                	mv	a0,s1
    80004ac0:	fffff097          	auipc	ra,0xfffff
    80004ac4:	d6a080e7          	jalr	-662(ra) # 8000382a <bwrite>
    brelse(from);
    80004ac8:	854e                	mv	a0,s3
    80004aca:	fffff097          	auipc	ra,0xfffff
    80004ace:	d9e080e7          	jalr	-610(ra) # 80003868 <brelse>
    brelse(to);
    80004ad2:	8526                	mv	a0,s1
    80004ad4:	fffff097          	auipc	ra,0xfffff
    80004ad8:	d94080e7          	jalr	-620(ra) # 80003868 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004adc:	2905                	addiw	s2,s2,1
    80004ade:	0a91                	addi	s5,s5,4
    80004ae0:	02ca2783          	lw	a5,44(s4)
    80004ae4:	f8f94ee3          	blt	s2,a5,80004a80 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004ae8:	00000097          	auipc	ra,0x0
    80004aec:	c8c080e7          	jalr	-884(ra) # 80004774 <write_head>
    install_trans(0); // Now install writes to home locations
    80004af0:	4501                	li	a0,0
    80004af2:	00000097          	auipc	ra,0x0
    80004af6:	cec080e7          	jalr	-788(ra) # 800047de <install_trans>
    log.lh.n = 0;
    80004afa:	0009f797          	auipc	a5,0x9f
    80004afe:	f807a123          	sw	zero,-126(a5) # 800a3a7c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004b02:	00000097          	auipc	ra,0x0
    80004b06:	c72080e7          	jalr	-910(ra) # 80004774 <write_head>
    80004b0a:	69e2                	ld	s3,24(sp)
    80004b0c:	6a42                	ld	s4,16(sp)
    80004b0e:	6aa2                	ld	s5,8(sp)
    80004b10:	bdc5                	j	80004a00 <end_op+0x4c>

0000000080004b12 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004b12:	1101                	addi	sp,sp,-32
    80004b14:	ec06                	sd	ra,24(sp)
    80004b16:	e822                	sd	s0,16(sp)
    80004b18:	e426                	sd	s1,8(sp)
    80004b1a:	e04a                	sd	s2,0(sp)
    80004b1c:	1000                	addi	s0,sp,32
    80004b1e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004b20:	0009f917          	auipc	s2,0x9f
    80004b24:	f3090913          	addi	s2,s2,-208 # 800a3a50 <log>
    80004b28:	854a                	mv	a0,s2
    80004b2a:	ffffc097          	auipc	ra,0xffffc
    80004b2e:	1e0080e7          	jalr	480(ra) # 80000d0a <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004b32:	02c92603          	lw	a2,44(s2)
    80004b36:	47f5                	li	a5,29
    80004b38:	06c7c563          	blt	a5,a2,80004ba2 <log_write+0x90>
    80004b3c:	0009f797          	auipc	a5,0x9f
    80004b40:	f307a783          	lw	a5,-208(a5) # 800a3a6c <log+0x1c>
    80004b44:	37fd                	addiw	a5,a5,-1
    80004b46:	04f65e63          	bge	a2,a5,80004ba2 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004b4a:	0009f797          	auipc	a5,0x9f
    80004b4e:	f267a783          	lw	a5,-218(a5) # 800a3a70 <log+0x20>
    80004b52:	06f05063          	blez	a5,80004bb2 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004b56:	4781                	li	a5,0
    80004b58:	06c05563          	blez	a2,80004bc2 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b5c:	44cc                	lw	a1,12(s1)
    80004b5e:	0009f717          	auipc	a4,0x9f
    80004b62:	f2270713          	addi	a4,a4,-222 # 800a3a80 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004b66:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b68:	4314                	lw	a3,0(a4)
    80004b6a:	04b68c63          	beq	a3,a1,80004bc2 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004b6e:	2785                	addiw	a5,a5,1
    80004b70:	0711                	addi	a4,a4,4
    80004b72:	fef61be3          	bne	a2,a5,80004b68 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004b76:	0621                	addi	a2,a2,8
    80004b78:	060a                	slli	a2,a2,0x2
    80004b7a:	0009f797          	auipc	a5,0x9f
    80004b7e:	ed678793          	addi	a5,a5,-298 # 800a3a50 <log>
    80004b82:	97b2                	add	a5,a5,a2
    80004b84:	44d8                	lw	a4,12(s1)
    80004b86:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004b88:	8526                	mv	a0,s1
    80004b8a:	fffff097          	auipc	ra,0xfffff
    80004b8e:	d7a080e7          	jalr	-646(ra) # 80003904 <bpin>
    log.lh.n++;
    80004b92:	0009f717          	auipc	a4,0x9f
    80004b96:	ebe70713          	addi	a4,a4,-322 # 800a3a50 <log>
    80004b9a:	575c                	lw	a5,44(a4)
    80004b9c:	2785                	addiw	a5,a5,1
    80004b9e:	d75c                	sw	a5,44(a4)
    80004ba0:	a82d                	j	80004bda <log_write+0xc8>
    panic("too big a transaction");
    80004ba2:	00004517          	auipc	a0,0x4
    80004ba6:	c4650513          	addi	a0,a0,-954 # 800087e8 <__func__.1+0x7e0>
    80004baa:	ffffc097          	auipc	ra,0xffffc
    80004bae:	9b6080e7          	jalr	-1610(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004bb2:	00004517          	auipc	a0,0x4
    80004bb6:	c4e50513          	addi	a0,a0,-946 # 80008800 <__func__.1+0x7f8>
    80004bba:	ffffc097          	auipc	ra,0xffffc
    80004bbe:	9a6080e7          	jalr	-1626(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004bc2:	00878693          	addi	a3,a5,8
    80004bc6:	068a                	slli	a3,a3,0x2
    80004bc8:	0009f717          	auipc	a4,0x9f
    80004bcc:	e8870713          	addi	a4,a4,-376 # 800a3a50 <log>
    80004bd0:	9736                	add	a4,a4,a3
    80004bd2:	44d4                	lw	a3,12(s1)
    80004bd4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004bd6:	faf609e3          	beq	a2,a5,80004b88 <log_write+0x76>
  }
  release(&log.lock);
    80004bda:	0009f517          	auipc	a0,0x9f
    80004bde:	e7650513          	addi	a0,a0,-394 # 800a3a50 <log>
    80004be2:	ffffc097          	auipc	ra,0xffffc
    80004be6:	1dc080e7          	jalr	476(ra) # 80000dbe <release>
}
    80004bea:	60e2                	ld	ra,24(sp)
    80004bec:	6442                	ld	s0,16(sp)
    80004bee:	64a2                	ld	s1,8(sp)
    80004bf0:	6902                	ld	s2,0(sp)
    80004bf2:	6105                	addi	sp,sp,32
    80004bf4:	8082                	ret

0000000080004bf6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004bf6:	1101                	addi	sp,sp,-32
    80004bf8:	ec06                	sd	ra,24(sp)
    80004bfa:	e822                	sd	s0,16(sp)
    80004bfc:	e426                	sd	s1,8(sp)
    80004bfe:	e04a                	sd	s2,0(sp)
    80004c00:	1000                	addi	s0,sp,32
    80004c02:	84aa                	mv	s1,a0
    80004c04:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004c06:	00004597          	auipc	a1,0x4
    80004c0a:	c1a58593          	addi	a1,a1,-998 # 80008820 <__func__.1+0x818>
    80004c0e:	0521                	addi	a0,a0,8
    80004c10:	ffffc097          	auipc	ra,0xffffc
    80004c14:	06a080e7          	jalr	106(ra) # 80000c7a <initlock>
  lk->name = name;
    80004c18:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004c1c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c20:	0204a423          	sw	zero,40(s1)
}
    80004c24:	60e2                	ld	ra,24(sp)
    80004c26:	6442                	ld	s0,16(sp)
    80004c28:	64a2                	ld	s1,8(sp)
    80004c2a:	6902                	ld	s2,0(sp)
    80004c2c:	6105                	addi	sp,sp,32
    80004c2e:	8082                	ret

0000000080004c30 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c30:	1101                	addi	sp,sp,-32
    80004c32:	ec06                	sd	ra,24(sp)
    80004c34:	e822                	sd	s0,16(sp)
    80004c36:	e426                	sd	s1,8(sp)
    80004c38:	e04a                	sd	s2,0(sp)
    80004c3a:	1000                	addi	s0,sp,32
    80004c3c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c3e:	00850913          	addi	s2,a0,8
    80004c42:	854a                	mv	a0,s2
    80004c44:	ffffc097          	auipc	ra,0xffffc
    80004c48:	0c6080e7          	jalr	198(ra) # 80000d0a <acquire>
  while (lk->locked) {
    80004c4c:	409c                	lw	a5,0(s1)
    80004c4e:	cb89                	beqz	a5,80004c60 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004c50:	85ca                	mv	a1,s2
    80004c52:	8526                	mv	a0,s1
    80004c54:	ffffe097          	auipc	ra,0xffffe
    80004c58:	b0e080e7          	jalr	-1266(ra) # 80002762 <sleep>
  while (lk->locked) {
    80004c5c:	409c                	lw	a5,0(s1)
    80004c5e:	fbed                	bnez	a5,80004c50 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004c60:	4785                	li	a5,1
    80004c62:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c64:	ffffd097          	auipc	ra,0xffffd
    80004c68:	35c080e7          	jalr	860(ra) # 80001fc0 <myproc>
    80004c6c:	591c                	lw	a5,48(a0)
    80004c6e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004c70:	854a                	mv	a0,s2
    80004c72:	ffffc097          	auipc	ra,0xffffc
    80004c76:	14c080e7          	jalr	332(ra) # 80000dbe <release>
}
    80004c7a:	60e2                	ld	ra,24(sp)
    80004c7c:	6442                	ld	s0,16(sp)
    80004c7e:	64a2                	ld	s1,8(sp)
    80004c80:	6902                	ld	s2,0(sp)
    80004c82:	6105                	addi	sp,sp,32
    80004c84:	8082                	ret

0000000080004c86 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004c86:	1101                	addi	sp,sp,-32
    80004c88:	ec06                	sd	ra,24(sp)
    80004c8a:	e822                	sd	s0,16(sp)
    80004c8c:	e426                	sd	s1,8(sp)
    80004c8e:	e04a                	sd	s2,0(sp)
    80004c90:	1000                	addi	s0,sp,32
    80004c92:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c94:	00850913          	addi	s2,a0,8
    80004c98:	854a                	mv	a0,s2
    80004c9a:	ffffc097          	auipc	ra,0xffffc
    80004c9e:	070080e7          	jalr	112(ra) # 80000d0a <acquire>
  lk->locked = 0;
    80004ca2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ca6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004caa:	8526                	mv	a0,s1
    80004cac:	ffffe097          	auipc	ra,0xffffe
    80004cb0:	b1a080e7          	jalr	-1254(ra) # 800027c6 <wakeup>
  release(&lk->lk);
    80004cb4:	854a                	mv	a0,s2
    80004cb6:	ffffc097          	auipc	ra,0xffffc
    80004cba:	108080e7          	jalr	264(ra) # 80000dbe <release>
}
    80004cbe:	60e2                	ld	ra,24(sp)
    80004cc0:	6442                	ld	s0,16(sp)
    80004cc2:	64a2                	ld	s1,8(sp)
    80004cc4:	6902                	ld	s2,0(sp)
    80004cc6:	6105                	addi	sp,sp,32
    80004cc8:	8082                	ret

0000000080004cca <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004cca:	7179                	addi	sp,sp,-48
    80004ccc:	f406                	sd	ra,40(sp)
    80004cce:	f022                	sd	s0,32(sp)
    80004cd0:	ec26                	sd	s1,24(sp)
    80004cd2:	e84a                	sd	s2,16(sp)
    80004cd4:	1800                	addi	s0,sp,48
    80004cd6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004cd8:	00850913          	addi	s2,a0,8
    80004cdc:	854a                	mv	a0,s2
    80004cde:	ffffc097          	auipc	ra,0xffffc
    80004ce2:	02c080e7          	jalr	44(ra) # 80000d0a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ce6:	409c                	lw	a5,0(s1)
    80004ce8:	ef91                	bnez	a5,80004d04 <holdingsleep+0x3a>
    80004cea:	4481                	li	s1,0
  release(&lk->lk);
    80004cec:	854a                	mv	a0,s2
    80004cee:	ffffc097          	auipc	ra,0xffffc
    80004cf2:	0d0080e7          	jalr	208(ra) # 80000dbe <release>
  return r;
}
    80004cf6:	8526                	mv	a0,s1
    80004cf8:	70a2                	ld	ra,40(sp)
    80004cfa:	7402                	ld	s0,32(sp)
    80004cfc:	64e2                	ld	s1,24(sp)
    80004cfe:	6942                	ld	s2,16(sp)
    80004d00:	6145                	addi	sp,sp,48
    80004d02:	8082                	ret
    80004d04:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d06:	0284a983          	lw	s3,40(s1)
    80004d0a:	ffffd097          	auipc	ra,0xffffd
    80004d0e:	2b6080e7          	jalr	694(ra) # 80001fc0 <myproc>
    80004d12:	5904                	lw	s1,48(a0)
    80004d14:	413484b3          	sub	s1,s1,s3
    80004d18:	0014b493          	seqz	s1,s1
    80004d1c:	69a2                	ld	s3,8(sp)
    80004d1e:	b7f9                	j	80004cec <holdingsleep+0x22>

0000000080004d20 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004d20:	1141                	addi	sp,sp,-16
    80004d22:	e406                	sd	ra,8(sp)
    80004d24:	e022                	sd	s0,0(sp)
    80004d26:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004d28:	00004597          	auipc	a1,0x4
    80004d2c:	b0858593          	addi	a1,a1,-1272 # 80008830 <__func__.1+0x828>
    80004d30:	0009f517          	auipc	a0,0x9f
    80004d34:	e6850513          	addi	a0,a0,-408 # 800a3b98 <ftable>
    80004d38:	ffffc097          	auipc	ra,0xffffc
    80004d3c:	f42080e7          	jalr	-190(ra) # 80000c7a <initlock>
}
    80004d40:	60a2                	ld	ra,8(sp)
    80004d42:	6402                	ld	s0,0(sp)
    80004d44:	0141                	addi	sp,sp,16
    80004d46:	8082                	ret

0000000080004d48 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004d48:	1101                	addi	sp,sp,-32
    80004d4a:	ec06                	sd	ra,24(sp)
    80004d4c:	e822                	sd	s0,16(sp)
    80004d4e:	e426                	sd	s1,8(sp)
    80004d50:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004d52:	0009f517          	auipc	a0,0x9f
    80004d56:	e4650513          	addi	a0,a0,-442 # 800a3b98 <ftable>
    80004d5a:	ffffc097          	auipc	ra,0xffffc
    80004d5e:	fb0080e7          	jalr	-80(ra) # 80000d0a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d62:	0009f497          	auipc	s1,0x9f
    80004d66:	e4e48493          	addi	s1,s1,-434 # 800a3bb0 <ftable+0x18>
    80004d6a:	000a0717          	auipc	a4,0xa0
    80004d6e:	de670713          	addi	a4,a4,-538 # 800a4b50 <disk>
    if(f->ref == 0){
    80004d72:	40dc                	lw	a5,4(s1)
    80004d74:	cf99                	beqz	a5,80004d92 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d76:	02848493          	addi	s1,s1,40
    80004d7a:	fee49ce3          	bne	s1,a4,80004d72 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004d7e:	0009f517          	auipc	a0,0x9f
    80004d82:	e1a50513          	addi	a0,a0,-486 # 800a3b98 <ftable>
    80004d86:	ffffc097          	auipc	ra,0xffffc
    80004d8a:	038080e7          	jalr	56(ra) # 80000dbe <release>
  return 0;
    80004d8e:	4481                	li	s1,0
    80004d90:	a819                	j	80004da6 <filealloc+0x5e>
      f->ref = 1;
    80004d92:	4785                	li	a5,1
    80004d94:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004d96:	0009f517          	auipc	a0,0x9f
    80004d9a:	e0250513          	addi	a0,a0,-510 # 800a3b98 <ftable>
    80004d9e:	ffffc097          	auipc	ra,0xffffc
    80004da2:	020080e7          	jalr	32(ra) # 80000dbe <release>
}
    80004da6:	8526                	mv	a0,s1
    80004da8:	60e2                	ld	ra,24(sp)
    80004daa:	6442                	ld	s0,16(sp)
    80004dac:	64a2                	ld	s1,8(sp)
    80004dae:	6105                	addi	sp,sp,32
    80004db0:	8082                	ret

0000000080004db2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004db2:	1101                	addi	sp,sp,-32
    80004db4:	ec06                	sd	ra,24(sp)
    80004db6:	e822                	sd	s0,16(sp)
    80004db8:	e426                	sd	s1,8(sp)
    80004dba:	1000                	addi	s0,sp,32
    80004dbc:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004dbe:	0009f517          	auipc	a0,0x9f
    80004dc2:	dda50513          	addi	a0,a0,-550 # 800a3b98 <ftable>
    80004dc6:	ffffc097          	auipc	ra,0xffffc
    80004dca:	f44080e7          	jalr	-188(ra) # 80000d0a <acquire>
  if(f->ref < 1)
    80004dce:	40dc                	lw	a5,4(s1)
    80004dd0:	02f05263          	blez	a5,80004df4 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004dd4:	2785                	addiw	a5,a5,1
    80004dd6:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004dd8:	0009f517          	auipc	a0,0x9f
    80004ddc:	dc050513          	addi	a0,a0,-576 # 800a3b98 <ftable>
    80004de0:	ffffc097          	auipc	ra,0xffffc
    80004de4:	fde080e7          	jalr	-34(ra) # 80000dbe <release>
  return f;
}
    80004de8:	8526                	mv	a0,s1
    80004dea:	60e2                	ld	ra,24(sp)
    80004dec:	6442                	ld	s0,16(sp)
    80004dee:	64a2                	ld	s1,8(sp)
    80004df0:	6105                	addi	sp,sp,32
    80004df2:	8082                	ret
    panic("filedup");
    80004df4:	00004517          	auipc	a0,0x4
    80004df8:	a4450513          	addi	a0,a0,-1468 # 80008838 <__func__.1+0x830>
    80004dfc:	ffffb097          	auipc	ra,0xffffb
    80004e00:	764080e7          	jalr	1892(ra) # 80000560 <panic>

0000000080004e04 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004e04:	7139                	addi	sp,sp,-64
    80004e06:	fc06                	sd	ra,56(sp)
    80004e08:	f822                	sd	s0,48(sp)
    80004e0a:	f426                	sd	s1,40(sp)
    80004e0c:	0080                	addi	s0,sp,64
    80004e0e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004e10:	0009f517          	auipc	a0,0x9f
    80004e14:	d8850513          	addi	a0,a0,-632 # 800a3b98 <ftable>
    80004e18:	ffffc097          	auipc	ra,0xffffc
    80004e1c:	ef2080e7          	jalr	-270(ra) # 80000d0a <acquire>
  if(f->ref < 1)
    80004e20:	40dc                	lw	a5,4(s1)
    80004e22:	04f05c63          	blez	a5,80004e7a <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004e26:	37fd                	addiw	a5,a5,-1
    80004e28:	0007871b          	sext.w	a4,a5
    80004e2c:	c0dc                	sw	a5,4(s1)
    80004e2e:	06e04263          	bgtz	a4,80004e92 <fileclose+0x8e>
    80004e32:	f04a                	sd	s2,32(sp)
    80004e34:	ec4e                	sd	s3,24(sp)
    80004e36:	e852                	sd	s4,16(sp)
    80004e38:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004e3a:	0004a903          	lw	s2,0(s1)
    80004e3e:	0094ca83          	lbu	s5,9(s1)
    80004e42:	0104ba03          	ld	s4,16(s1)
    80004e46:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004e4a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004e4e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004e52:	0009f517          	auipc	a0,0x9f
    80004e56:	d4650513          	addi	a0,a0,-698 # 800a3b98 <ftable>
    80004e5a:	ffffc097          	auipc	ra,0xffffc
    80004e5e:	f64080e7          	jalr	-156(ra) # 80000dbe <release>

  if(ff.type == FD_PIPE){
    80004e62:	4785                	li	a5,1
    80004e64:	04f90463          	beq	s2,a5,80004eac <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004e68:	3979                	addiw	s2,s2,-2
    80004e6a:	4785                	li	a5,1
    80004e6c:	0527fb63          	bgeu	a5,s2,80004ec2 <fileclose+0xbe>
    80004e70:	7902                	ld	s2,32(sp)
    80004e72:	69e2                	ld	s3,24(sp)
    80004e74:	6a42                	ld	s4,16(sp)
    80004e76:	6aa2                	ld	s5,8(sp)
    80004e78:	a02d                	j	80004ea2 <fileclose+0x9e>
    80004e7a:	f04a                	sd	s2,32(sp)
    80004e7c:	ec4e                	sd	s3,24(sp)
    80004e7e:	e852                	sd	s4,16(sp)
    80004e80:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004e82:	00004517          	auipc	a0,0x4
    80004e86:	9be50513          	addi	a0,a0,-1602 # 80008840 <__func__.1+0x838>
    80004e8a:	ffffb097          	auipc	ra,0xffffb
    80004e8e:	6d6080e7          	jalr	1750(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004e92:	0009f517          	auipc	a0,0x9f
    80004e96:	d0650513          	addi	a0,a0,-762 # 800a3b98 <ftable>
    80004e9a:	ffffc097          	auipc	ra,0xffffc
    80004e9e:	f24080e7          	jalr	-220(ra) # 80000dbe <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004ea2:	70e2                	ld	ra,56(sp)
    80004ea4:	7442                	ld	s0,48(sp)
    80004ea6:	74a2                	ld	s1,40(sp)
    80004ea8:	6121                	addi	sp,sp,64
    80004eaa:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004eac:	85d6                	mv	a1,s5
    80004eae:	8552                	mv	a0,s4
    80004eb0:	00000097          	auipc	ra,0x0
    80004eb4:	3a2080e7          	jalr	930(ra) # 80005252 <pipeclose>
    80004eb8:	7902                	ld	s2,32(sp)
    80004eba:	69e2                	ld	s3,24(sp)
    80004ebc:	6a42                	ld	s4,16(sp)
    80004ebe:	6aa2                	ld	s5,8(sp)
    80004ec0:	b7cd                	j	80004ea2 <fileclose+0x9e>
    begin_op();
    80004ec2:	00000097          	auipc	ra,0x0
    80004ec6:	a78080e7          	jalr	-1416(ra) # 8000493a <begin_op>
    iput(ff.ip);
    80004eca:	854e                	mv	a0,s3
    80004ecc:	fffff097          	auipc	ra,0xfffff
    80004ed0:	25e080e7          	jalr	606(ra) # 8000412a <iput>
    end_op();
    80004ed4:	00000097          	auipc	ra,0x0
    80004ed8:	ae0080e7          	jalr	-1312(ra) # 800049b4 <end_op>
    80004edc:	7902                	ld	s2,32(sp)
    80004ede:	69e2                	ld	s3,24(sp)
    80004ee0:	6a42                	ld	s4,16(sp)
    80004ee2:	6aa2                	ld	s5,8(sp)
    80004ee4:	bf7d                	j	80004ea2 <fileclose+0x9e>

0000000080004ee6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ee6:	715d                	addi	sp,sp,-80
    80004ee8:	e486                	sd	ra,72(sp)
    80004eea:	e0a2                	sd	s0,64(sp)
    80004eec:	fc26                	sd	s1,56(sp)
    80004eee:	f44e                	sd	s3,40(sp)
    80004ef0:	0880                	addi	s0,sp,80
    80004ef2:	84aa                	mv	s1,a0
    80004ef4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ef6:	ffffd097          	auipc	ra,0xffffd
    80004efa:	0ca080e7          	jalr	202(ra) # 80001fc0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004efe:	409c                	lw	a5,0(s1)
    80004f00:	37f9                	addiw	a5,a5,-2
    80004f02:	4705                	li	a4,1
    80004f04:	04f76863          	bltu	a4,a5,80004f54 <filestat+0x6e>
    80004f08:	f84a                	sd	s2,48(sp)
    80004f0a:	892a                	mv	s2,a0
    ilock(f->ip);
    80004f0c:	6c88                	ld	a0,24(s1)
    80004f0e:	fffff097          	auipc	ra,0xfffff
    80004f12:	05e080e7          	jalr	94(ra) # 80003f6c <ilock>
    stati(f->ip, &st);
    80004f16:	fb840593          	addi	a1,s0,-72
    80004f1a:	6c88                	ld	a0,24(s1)
    80004f1c:	fffff097          	auipc	ra,0xfffff
    80004f20:	2de080e7          	jalr	734(ra) # 800041fa <stati>
    iunlock(f->ip);
    80004f24:	6c88                	ld	a0,24(s1)
    80004f26:	fffff097          	auipc	ra,0xfffff
    80004f2a:	10c080e7          	jalr	268(ra) # 80004032 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004f2e:	46e1                	li	a3,24
    80004f30:	fb840613          	addi	a2,s0,-72
    80004f34:	85ce                	mv	a1,s3
    80004f36:	05093503          	ld	a0,80(s2)
    80004f3a:	ffffd097          	auipc	ra,0xffffd
    80004f3e:	b54080e7          	jalr	-1196(ra) # 80001a8e <copyout>
    80004f42:	41f5551b          	sraiw	a0,a0,0x1f
    80004f46:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004f48:	60a6                	ld	ra,72(sp)
    80004f4a:	6406                	ld	s0,64(sp)
    80004f4c:	74e2                	ld	s1,56(sp)
    80004f4e:	79a2                	ld	s3,40(sp)
    80004f50:	6161                	addi	sp,sp,80
    80004f52:	8082                	ret
  return -1;
    80004f54:	557d                	li	a0,-1
    80004f56:	bfcd                	j	80004f48 <filestat+0x62>

0000000080004f58 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004f58:	7179                	addi	sp,sp,-48
    80004f5a:	f406                	sd	ra,40(sp)
    80004f5c:	f022                	sd	s0,32(sp)
    80004f5e:	e84a                	sd	s2,16(sp)
    80004f60:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004f62:	00854783          	lbu	a5,8(a0)
    80004f66:	cbc5                	beqz	a5,80005016 <fileread+0xbe>
    80004f68:	ec26                	sd	s1,24(sp)
    80004f6a:	e44e                	sd	s3,8(sp)
    80004f6c:	84aa                	mv	s1,a0
    80004f6e:	89ae                	mv	s3,a1
    80004f70:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f72:	411c                	lw	a5,0(a0)
    80004f74:	4705                	li	a4,1
    80004f76:	04e78963          	beq	a5,a4,80004fc8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f7a:	470d                	li	a4,3
    80004f7c:	04e78f63          	beq	a5,a4,80004fda <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f80:	4709                	li	a4,2
    80004f82:	08e79263          	bne	a5,a4,80005006 <fileread+0xae>
    ilock(f->ip);
    80004f86:	6d08                	ld	a0,24(a0)
    80004f88:	fffff097          	auipc	ra,0xfffff
    80004f8c:	fe4080e7          	jalr	-28(ra) # 80003f6c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004f90:	874a                	mv	a4,s2
    80004f92:	5094                	lw	a3,32(s1)
    80004f94:	864e                	mv	a2,s3
    80004f96:	4585                	li	a1,1
    80004f98:	6c88                	ld	a0,24(s1)
    80004f9a:	fffff097          	auipc	ra,0xfffff
    80004f9e:	28a080e7          	jalr	650(ra) # 80004224 <readi>
    80004fa2:	892a                	mv	s2,a0
    80004fa4:	00a05563          	blez	a0,80004fae <fileread+0x56>
      f->off += r;
    80004fa8:	509c                	lw	a5,32(s1)
    80004faa:	9fa9                	addw	a5,a5,a0
    80004fac:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004fae:	6c88                	ld	a0,24(s1)
    80004fb0:	fffff097          	auipc	ra,0xfffff
    80004fb4:	082080e7          	jalr	130(ra) # 80004032 <iunlock>
    80004fb8:	64e2                	ld	s1,24(sp)
    80004fba:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004fbc:	854a                	mv	a0,s2
    80004fbe:	70a2                	ld	ra,40(sp)
    80004fc0:	7402                	ld	s0,32(sp)
    80004fc2:	6942                	ld	s2,16(sp)
    80004fc4:	6145                	addi	sp,sp,48
    80004fc6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004fc8:	6908                	ld	a0,16(a0)
    80004fca:	00000097          	auipc	ra,0x0
    80004fce:	400080e7          	jalr	1024(ra) # 800053ca <piperead>
    80004fd2:	892a                	mv	s2,a0
    80004fd4:	64e2                	ld	s1,24(sp)
    80004fd6:	69a2                	ld	s3,8(sp)
    80004fd8:	b7d5                	j	80004fbc <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004fda:	02451783          	lh	a5,36(a0)
    80004fde:	03079693          	slli	a3,a5,0x30
    80004fe2:	92c1                	srli	a3,a3,0x30
    80004fe4:	4725                	li	a4,9
    80004fe6:	02d76a63          	bltu	a4,a3,8000501a <fileread+0xc2>
    80004fea:	0792                	slli	a5,a5,0x4
    80004fec:	0009f717          	auipc	a4,0x9f
    80004ff0:	b0c70713          	addi	a4,a4,-1268 # 800a3af8 <devsw>
    80004ff4:	97ba                	add	a5,a5,a4
    80004ff6:	639c                	ld	a5,0(a5)
    80004ff8:	c78d                	beqz	a5,80005022 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004ffa:	4505                	li	a0,1
    80004ffc:	9782                	jalr	a5
    80004ffe:	892a                	mv	s2,a0
    80005000:	64e2                	ld	s1,24(sp)
    80005002:	69a2                	ld	s3,8(sp)
    80005004:	bf65                	j	80004fbc <fileread+0x64>
    panic("fileread");
    80005006:	00004517          	auipc	a0,0x4
    8000500a:	84a50513          	addi	a0,a0,-1974 # 80008850 <__func__.1+0x848>
    8000500e:	ffffb097          	auipc	ra,0xffffb
    80005012:	552080e7          	jalr	1362(ra) # 80000560 <panic>
    return -1;
    80005016:	597d                	li	s2,-1
    80005018:	b755                	j	80004fbc <fileread+0x64>
      return -1;
    8000501a:	597d                	li	s2,-1
    8000501c:	64e2                	ld	s1,24(sp)
    8000501e:	69a2                	ld	s3,8(sp)
    80005020:	bf71                	j	80004fbc <fileread+0x64>
    80005022:	597d                	li	s2,-1
    80005024:	64e2                	ld	s1,24(sp)
    80005026:	69a2                	ld	s3,8(sp)
    80005028:	bf51                	j	80004fbc <fileread+0x64>

000000008000502a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000502a:	00954783          	lbu	a5,9(a0)
    8000502e:	12078963          	beqz	a5,80005160 <filewrite+0x136>
{
    80005032:	715d                	addi	sp,sp,-80
    80005034:	e486                	sd	ra,72(sp)
    80005036:	e0a2                	sd	s0,64(sp)
    80005038:	f84a                	sd	s2,48(sp)
    8000503a:	f052                	sd	s4,32(sp)
    8000503c:	e85a                	sd	s6,16(sp)
    8000503e:	0880                	addi	s0,sp,80
    80005040:	892a                	mv	s2,a0
    80005042:	8b2e                	mv	s6,a1
    80005044:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005046:	411c                	lw	a5,0(a0)
    80005048:	4705                	li	a4,1
    8000504a:	02e78763          	beq	a5,a4,80005078 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000504e:	470d                	li	a4,3
    80005050:	02e78a63          	beq	a5,a4,80005084 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005054:	4709                	li	a4,2
    80005056:	0ee79863          	bne	a5,a4,80005146 <filewrite+0x11c>
    8000505a:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000505c:	0cc05463          	blez	a2,80005124 <filewrite+0xfa>
    80005060:	fc26                	sd	s1,56(sp)
    80005062:	ec56                	sd	s5,24(sp)
    80005064:	e45e                	sd	s7,8(sp)
    80005066:	e062                	sd	s8,0(sp)
    int i = 0;
    80005068:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000506a:	6b85                	lui	s7,0x1
    8000506c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005070:	6c05                	lui	s8,0x1
    80005072:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80005076:	a851                	j	8000510a <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80005078:	6908                	ld	a0,16(a0)
    8000507a:	00000097          	auipc	ra,0x0
    8000507e:	248080e7          	jalr	584(ra) # 800052c2 <pipewrite>
    80005082:	a85d                	j	80005138 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005084:	02451783          	lh	a5,36(a0)
    80005088:	03079693          	slli	a3,a5,0x30
    8000508c:	92c1                	srli	a3,a3,0x30
    8000508e:	4725                	li	a4,9
    80005090:	0cd76a63          	bltu	a4,a3,80005164 <filewrite+0x13a>
    80005094:	0792                	slli	a5,a5,0x4
    80005096:	0009f717          	auipc	a4,0x9f
    8000509a:	a6270713          	addi	a4,a4,-1438 # 800a3af8 <devsw>
    8000509e:	97ba                	add	a5,a5,a4
    800050a0:	679c                	ld	a5,8(a5)
    800050a2:	c3f9                	beqz	a5,80005168 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    800050a4:	4505                	li	a0,1
    800050a6:	9782                	jalr	a5
    800050a8:	a841                	j	80005138 <filewrite+0x10e>
      if(n1 > max)
    800050aa:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800050ae:	00000097          	auipc	ra,0x0
    800050b2:	88c080e7          	jalr	-1908(ra) # 8000493a <begin_op>
      ilock(f->ip);
    800050b6:	01893503          	ld	a0,24(s2)
    800050ba:	fffff097          	auipc	ra,0xfffff
    800050be:	eb2080e7          	jalr	-334(ra) # 80003f6c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800050c2:	8756                	mv	a4,s5
    800050c4:	02092683          	lw	a3,32(s2)
    800050c8:	01698633          	add	a2,s3,s6
    800050cc:	4585                	li	a1,1
    800050ce:	01893503          	ld	a0,24(s2)
    800050d2:	fffff097          	auipc	ra,0xfffff
    800050d6:	262080e7          	jalr	610(ra) # 80004334 <writei>
    800050da:	84aa                	mv	s1,a0
    800050dc:	00a05763          	blez	a0,800050ea <filewrite+0xc0>
        f->off += r;
    800050e0:	02092783          	lw	a5,32(s2)
    800050e4:	9fa9                	addw	a5,a5,a0
    800050e6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800050ea:	01893503          	ld	a0,24(s2)
    800050ee:	fffff097          	auipc	ra,0xfffff
    800050f2:	f44080e7          	jalr	-188(ra) # 80004032 <iunlock>
      end_op();
    800050f6:	00000097          	auipc	ra,0x0
    800050fa:	8be080e7          	jalr	-1858(ra) # 800049b4 <end_op>

      if(r != n1){
    800050fe:	029a9563          	bne	s5,s1,80005128 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80005102:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005106:	0149da63          	bge	s3,s4,8000511a <filewrite+0xf0>
      int n1 = n - i;
    8000510a:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000510e:	0004879b          	sext.w	a5,s1
    80005112:	f8fbdce3          	bge	s7,a5,800050aa <filewrite+0x80>
    80005116:	84e2                	mv	s1,s8
    80005118:	bf49                	j	800050aa <filewrite+0x80>
    8000511a:	74e2                	ld	s1,56(sp)
    8000511c:	6ae2                	ld	s5,24(sp)
    8000511e:	6ba2                	ld	s7,8(sp)
    80005120:	6c02                	ld	s8,0(sp)
    80005122:	a039                	j	80005130 <filewrite+0x106>
    int i = 0;
    80005124:	4981                	li	s3,0
    80005126:	a029                	j	80005130 <filewrite+0x106>
    80005128:	74e2                	ld	s1,56(sp)
    8000512a:	6ae2                	ld	s5,24(sp)
    8000512c:	6ba2                	ld	s7,8(sp)
    8000512e:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80005130:	033a1e63          	bne	s4,s3,8000516c <filewrite+0x142>
    80005134:	8552                	mv	a0,s4
    80005136:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005138:	60a6                	ld	ra,72(sp)
    8000513a:	6406                	ld	s0,64(sp)
    8000513c:	7942                	ld	s2,48(sp)
    8000513e:	7a02                	ld	s4,32(sp)
    80005140:	6b42                	ld	s6,16(sp)
    80005142:	6161                	addi	sp,sp,80
    80005144:	8082                	ret
    80005146:	fc26                	sd	s1,56(sp)
    80005148:	f44e                	sd	s3,40(sp)
    8000514a:	ec56                	sd	s5,24(sp)
    8000514c:	e45e                	sd	s7,8(sp)
    8000514e:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80005150:	00003517          	auipc	a0,0x3
    80005154:	71050513          	addi	a0,a0,1808 # 80008860 <__func__.1+0x858>
    80005158:	ffffb097          	auipc	ra,0xffffb
    8000515c:	408080e7          	jalr	1032(ra) # 80000560 <panic>
    return -1;
    80005160:	557d                	li	a0,-1
}
    80005162:	8082                	ret
      return -1;
    80005164:	557d                	li	a0,-1
    80005166:	bfc9                	j	80005138 <filewrite+0x10e>
    80005168:	557d                	li	a0,-1
    8000516a:	b7f9                	j	80005138 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    8000516c:	557d                	li	a0,-1
    8000516e:	79a2                	ld	s3,40(sp)
    80005170:	b7e1                	j	80005138 <filewrite+0x10e>

0000000080005172 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005172:	7179                	addi	sp,sp,-48
    80005174:	f406                	sd	ra,40(sp)
    80005176:	f022                	sd	s0,32(sp)
    80005178:	ec26                	sd	s1,24(sp)
    8000517a:	e052                	sd	s4,0(sp)
    8000517c:	1800                	addi	s0,sp,48
    8000517e:	84aa                	mv	s1,a0
    80005180:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005182:	0005b023          	sd	zero,0(a1)
    80005186:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000518a:	00000097          	auipc	ra,0x0
    8000518e:	bbe080e7          	jalr	-1090(ra) # 80004d48 <filealloc>
    80005192:	e088                	sd	a0,0(s1)
    80005194:	cd49                	beqz	a0,8000522e <pipealloc+0xbc>
    80005196:	00000097          	auipc	ra,0x0
    8000519a:	bb2080e7          	jalr	-1102(ra) # 80004d48 <filealloc>
    8000519e:	00aa3023          	sd	a0,0(s4)
    800051a2:	c141                	beqz	a0,80005222 <pipealloc+0xb0>
    800051a4:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800051a6:	ffffc097          	auipc	ra,0xffffc
    800051aa:	a1e080e7          	jalr	-1506(ra) # 80000bc4 <kalloc>
    800051ae:	892a                	mv	s2,a0
    800051b0:	c13d                	beqz	a0,80005216 <pipealloc+0xa4>
    800051b2:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800051b4:	4985                	li	s3,1
    800051b6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800051ba:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800051be:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800051c2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800051c6:	00003597          	auipc	a1,0x3
    800051ca:	6aa58593          	addi	a1,a1,1706 # 80008870 <__func__.1+0x868>
    800051ce:	ffffc097          	auipc	ra,0xffffc
    800051d2:	aac080e7          	jalr	-1364(ra) # 80000c7a <initlock>
  (*f0)->type = FD_PIPE;
    800051d6:	609c                	ld	a5,0(s1)
    800051d8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800051dc:	609c                	ld	a5,0(s1)
    800051de:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800051e2:	609c                	ld	a5,0(s1)
    800051e4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800051e8:	609c                	ld	a5,0(s1)
    800051ea:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800051ee:	000a3783          	ld	a5,0(s4)
    800051f2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800051f6:	000a3783          	ld	a5,0(s4)
    800051fa:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800051fe:	000a3783          	ld	a5,0(s4)
    80005202:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005206:	000a3783          	ld	a5,0(s4)
    8000520a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000520e:	4501                	li	a0,0
    80005210:	6942                	ld	s2,16(sp)
    80005212:	69a2                	ld	s3,8(sp)
    80005214:	a03d                	j	80005242 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005216:	6088                	ld	a0,0(s1)
    80005218:	c119                	beqz	a0,8000521e <pipealloc+0xac>
    8000521a:	6942                	ld	s2,16(sp)
    8000521c:	a029                	j	80005226 <pipealloc+0xb4>
    8000521e:	6942                	ld	s2,16(sp)
    80005220:	a039                	j	8000522e <pipealloc+0xbc>
    80005222:	6088                	ld	a0,0(s1)
    80005224:	c50d                	beqz	a0,8000524e <pipealloc+0xdc>
    fileclose(*f0);
    80005226:	00000097          	auipc	ra,0x0
    8000522a:	bde080e7          	jalr	-1058(ra) # 80004e04 <fileclose>
  if(*f1)
    8000522e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005232:	557d                	li	a0,-1
  if(*f1)
    80005234:	c799                	beqz	a5,80005242 <pipealloc+0xd0>
    fileclose(*f1);
    80005236:	853e                	mv	a0,a5
    80005238:	00000097          	auipc	ra,0x0
    8000523c:	bcc080e7          	jalr	-1076(ra) # 80004e04 <fileclose>
  return -1;
    80005240:	557d                	li	a0,-1
}
    80005242:	70a2                	ld	ra,40(sp)
    80005244:	7402                	ld	s0,32(sp)
    80005246:	64e2                	ld	s1,24(sp)
    80005248:	6a02                	ld	s4,0(sp)
    8000524a:	6145                	addi	sp,sp,48
    8000524c:	8082                	ret
  return -1;
    8000524e:	557d                	li	a0,-1
    80005250:	bfcd                	j	80005242 <pipealloc+0xd0>

0000000080005252 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005252:	1101                	addi	sp,sp,-32
    80005254:	ec06                	sd	ra,24(sp)
    80005256:	e822                	sd	s0,16(sp)
    80005258:	e426                	sd	s1,8(sp)
    8000525a:	e04a                	sd	s2,0(sp)
    8000525c:	1000                	addi	s0,sp,32
    8000525e:	84aa                	mv	s1,a0
    80005260:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005262:	ffffc097          	auipc	ra,0xffffc
    80005266:	aa8080e7          	jalr	-1368(ra) # 80000d0a <acquire>
  if(writable){
    8000526a:	02090d63          	beqz	s2,800052a4 <pipeclose+0x52>
    pi->writeopen = 0;
    8000526e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005272:	21848513          	addi	a0,s1,536
    80005276:	ffffd097          	auipc	ra,0xffffd
    8000527a:	550080e7          	jalr	1360(ra) # 800027c6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000527e:	2204b783          	ld	a5,544(s1)
    80005282:	eb95                	bnez	a5,800052b6 <pipeclose+0x64>
    release(&pi->lock);
    80005284:	8526                	mv	a0,s1
    80005286:	ffffc097          	auipc	ra,0xffffc
    8000528a:	b38080e7          	jalr	-1224(ra) # 80000dbe <release>
    kfree((char*)pi);
    8000528e:	8526                	mv	a0,s1
    80005290:	ffffb097          	auipc	ra,0xffffb
    80005294:	7cc080e7          	jalr	1996(ra) # 80000a5c <kfree>
  } else
    release(&pi->lock);
}
    80005298:	60e2                	ld	ra,24(sp)
    8000529a:	6442                	ld	s0,16(sp)
    8000529c:	64a2                	ld	s1,8(sp)
    8000529e:	6902                	ld	s2,0(sp)
    800052a0:	6105                	addi	sp,sp,32
    800052a2:	8082                	ret
    pi->readopen = 0;
    800052a4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800052a8:	21c48513          	addi	a0,s1,540
    800052ac:	ffffd097          	auipc	ra,0xffffd
    800052b0:	51a080e7          	jalr	1306(ra) # 800027c6 <wakeup>
    800052b4:	b7e9                	j	8000527e <pipeclose+0x2c>
    release(&pi->lock);
    800052b6:	8526                	mv	a0,s1
    800052b8:	ffffc097          	auipc	ra,0xffffc
    800052bc:	b06080e7          	jalr	-1274(ra) # 80000dbe <release>
}
    800052c0:	bfe1                	j	80005298 <pipeclose+0x46>

00000000800052c2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800052c2:	711d                	addi	sp,sp,-96
    800052c4:	ec86                	sd	ra,88(sp)
    800052c6:	e8a2                	sd	s0,80(sp)
    800052c8:	e4a6                	sd	s1,72(sp)
    800052ca:	e0ca                	sd	s2,64(sp)
    800052cc:	fc4e                	sd	s3,56(sp)
    800052ce:	f852                	sd	s4,48(sp)
    800052d0:	f456                	sd	s5,40(sp)
    800052d2:	1080                	addi	s0,sp,96
    800052d4:	84aa                	mv	s1,a0
    800052d6:	8aae                	mv	s5,a1
    800052d8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800052da:	ffffd097          	auipc	ra,0xffffd
    800052de:	ce6080e7          	jalr	-794(ra) # 80001fc0 <myproc>
    800052e2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800052e4:	8526                	mv	a0,s1
    800052e6:	ffffc097          	auipc	ra,0xffffc
    800052ea:	a24080e7          	jalr	-1500(ra) # 80000d0a <acquire>
  while(i < n){
    800052ee:	0d405863          	blez	s4,800053be <pipewrite+0xfc>
    800052f2:	f05a                	sd	s6,32(sp)
    800052f4:	ec5e                	sd	s7,24(sp)
    800052f6:	e862                	sd	s8,16(sp)
  int i = 0;
    800052f8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052fa:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800052fc:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005300:	21c48b93          	addi	s7,s1,540
    80005304:	a089                	j	80005346 <pipewrite+0x84>
      release(&pi->lock);
    80005306:	8526                	mv	a0,s1
    80005308:	ffffc097          	auipc	ra,0xffffc
    8000530c:	ab6080e7          	jalr	-1354(ra) # 80000dbe <release>
      return -1;
    80005310:	597d                	li	s2,-1
    80005312:	7b02                	ld	s6,32(sp)
    80005314:	6be2                	ld	s7,24(sp)
    80005316:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005318:	854a                	mv	a0,s2
    8000531a:	60e6                	ld	ra,88(sp)
    8000531c:	6446                	ld	s0,80(sp)
    8000531e:	64a6                	ld	s1,72(sp)
    80005320:	6906                	ld	s2,64(sp)
    80005322:	79e2                	ld	s3,56(sp)
    80005324:	7a42                	ld	s4,48(sp)
    80005326:	7aa2                	ld	s5,40(sp)
    80005328:	6125                	addi	sp,sp,96
    8000532a:	8082                	ret
      wakeup(&pi->nread);
    8000532c:	8562                	mv	a0,s8
    8000532e:	ffffd097          	auipc	ra,0xffffd
    80005332:	498080e7          	jalr	1176(ra) # 800027c6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005336:	85a6                	mv	a1,s1
    80005338:	855e                	mv	a0,s7
    8000533a:	ffffd097          	auipc	ra,0xffffd
    8000533e:	428080e7          	jalr	1064(ra) # 80002762 <sleep>
  while(i < n){
    80005342:	05495f63          	bge	s2,s4,800053a0 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80005346:	2204a783          	lw	a5,544(s1)
    8000534a:	dfd5                	beqz	a5,80005306 <pipewrite+0x44>
    8000534c:	854e                	mv	a0,s3
    8000534e:	ffffd097          	auipc	ra,0xffffd
    80005352:	6bc080e7          	jalr	1724(ra) # 80002a0a <killed>
    80005356:	f945                	bnez	a0,80005306 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005358:	2184a783          	lw	a5,536(s1)
    8000535c:	21c4a703          	lw	a4,540(s1)
    80005360:	2007879b          	addiw	a5,a5,512
    80005364:	fcf704e3          	beq	a4,a5,8000532c <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005368:	4685                	li	a3,1
    8000536a:	01590633          	add	a2,s2,s5
    8000536e:	faf40593          	addi	a1,s0,-81
    80005372:	0509b503          	ld	a0,80(s3)
    80005376:	ffffc097          	auipc	ra,0xffffc
    8000537a:	7a4080e7          	jalr	1956(ra) # 80001b1a <copyin>
    8000537e:	05650263          	beq	a0,s6,800053c2 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005382:	21c4a783          	lw	a5,540(s1)
    80005386:	0017871b          	addiw	a4,a5,1
    8000538a:	20e4ae23          	sw	a4,540(s1)
    8000538e:	1ff7f793          	andi	a5,a5,511
    80005392:	97a6                	add	a5,a5,s1
    80005394:	faf44703          	lbu	a4,-81(s0)
    80005398:	00e78c23          	sb	a4,24(a5)
      i++;
    8000539c:	2905                	addiw	s2,s2,1
    8000539e:	b755                	j	80005342 <pipewrite+0x80>
    800053a0:	7b02                	ld	s6,32(sp)
    800053a2:	6be2                	ld	s7,24(sp)
    800053a4:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800053a6:	21848513          	addi	a0,s1,536
    800053aa:	ffffd097          	auipc	ra,0xffffd
    800053ae:	41c080e7          	jalr	1052(ra) # 800027c6 <wakeup>
  release(&pi->lock);
    800053b2:	8526                	mv	a0,s1
    800053b4:	ffffc097          	auipc	ra,0xffffc
    800053b8:	a0a080e7          	jalr	-1526(ra) # 80000dbe <release>
  return i;
    800053bc:	bfb1                	j	80005318 <pipewrite+0x56>
  int i = 0;
    800053be:	4901                	li	s2,0
    800053c0:	b7dd                	j	800053a6 <pipewrite+0xe4>
    800053c2:	7b02                	ld	s6,32(sp)
    800053c4:	6be2                	ld	s7,24(sp)
    800053c6:	6c42                	ld	s8,16(sp)
    800053c8:	bff9                	j	800053a6 <pipewrite+0xe4>

00000000800053ca <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800053ca:	715d                	addi	sp,sp,-80
    800053cc:	e486                	sd	ra,72(sp)
    800053ce:	e0a2                	sd	s0,64(sp)
    800053d0:	fc26                	sd	s1,56(sp)
    800053d2:	f84a                	sd	s2,48(sp)
    800053d4:	f44e                	sd	s3,40(sp)
    800053d6:	f052                	sd	s4,32(sp)
    800053d8:	ec56                	sd	s5,24(sp)
    800053da:	0880                	addi	s0,sp,80
    800053dc:	84aa                	mv	s1,a0
    800053de:	892e                	mv	s2,a1
    800053e0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800053e2:	ffffd097          	auipc	ra,0xffffd
    800053e6:	bde080e7          	jalr	-1058(ra) # 80001fc0 <myproc>
    800053ea:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800053ec:	8526                	mv	a0,s1
    800053ee:	ffffc097          	auipc	ra,0xffffc
    800053f2:	91c080e7          	jalr	-1764(ra) # 80000d0a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053f6:	2184a703          	lw	a4,536(s1)
    800053fa:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800053fe:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005402:	02f71963          	bne	a4,a5,80005434 <piperead+0x6a>
    80005406:	2244a783          	lw	a5,548(s1)
    8000540a:	cf95                	beqz	a5,80005446 <piperead+0x7c>
    if(killed(pr)){
    8000540c:	8552                	mv	a0,s4
    8000540e:	ffffd097          	auipc	ra,0xffffd
    80005412:	5fc080e7          	jalr	1532(ra) # 80002a0a <killed>
    80005416:	e10d                	bnez	a0,80005438 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005418:	85a6                	mv	a1,s1
    8000541a:	854e                	mv	a0,s3
    8000541c:	ffffd097          	auipc	ra,0xffffd
    80005420:	346080e7          	jalr	838(ra) # 80002762 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005424:	2184a703          	lw	a4,536(s1)
    80005428:	21c4a783          	lw	a5,540(s1)
    8000542c:	fcf70de3          	beq	a4,a5,80005406 <piperead+0x3c>
    80005430:	e85a                	sd	s6,16(sp)
    80005432:	a819                	j	80005448 <piperead+0x7e>
    80005434:	e85a                	sd	s6,16(sp)
    80005436:	a809                	j	80005448 <piperead+0x7e>
      release(&pi->lock);
    80005438:	8526                	mv	a0,s1
    8000543a:	ffffc097          	auipc	ra,0xffffc
    8000543e:	984080e7          	jalr	-1660(ra) # 80000dbe <release>
      return -1;
    80005442:	59fd                	li	s3,-1
    80005444:	a0a5                	j	800054ac <piperead+0xe2>
    80005446:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005448:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000544a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000544c:	05505463          	blez	s5,80005494 <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80005450:	2184a783          	lw	a5,536(s1)
    80005454:	21c4a703          	lw	a4,540(s1)
    80005458:	02f70e63          	beq	a4,a5,80005494 <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000545c:	0017871b          	addiw	a4,a5,1
    80005460:	20e4ac23          	sw	a4,536(s1)
    80005464:	1ff7f793          	andi	a5,a5,511
    80005468:	97a6                	add	a5,a5,s1
    8000546a:	0187c783          	lbu	a5,24(a5)
    8000546e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005472:	4685                	li	a3,1
    80005474:	fbf40613          	addi	a2,s0,-65
    80005478:	85ca                	mv	a1,s2
    8000547a:	050a3503          	ld	a0,80(s4)
    8000547e:	ffffc097          	auipc	ra,0xffffc
    80005482:	610080e7          	jalr	1552(ra) # 80001a8e <copyout>
    80005486:	01650763          	beq	a0,s6,80005494 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000548a:	2985                	addiw	s3,s3,1
    8000548c:	0905                	addi	s2,s2,1
    8000548e:	fd3a91e3          	bne	s5,s3,80005450 <piperead+0x86>
    80005492:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005494:	21c48513          	addi	a0,s1,540
    80005498:	ffffd097          	auipc	ra,0xffffd
    8000549c:	32e080e7          	jalr	814(ra) # 800027c6 <wakeup>
  release(&pi->lock);
    800054a0:	8526                	mv	a0,s1
    800054a2:	ffffc097          	auipc	ra,0xffffc
    800054a6:	91c080e7          	jalr	-1764(ra) # 80000dbe <release>
    800054aa:	6b42                	ld	s6,16(sp)
  return i;
}
    800054ac:	854e                	mv	a0,s3
    800054ae:	60a6                	ld	ra,72(sp)
    800054b0:	6406                	ld	s0,64(sp)
    800054b2:	74e2                	ld	s1,56(sp)
    800054b4:	7942                	ld	s2,48(sp)
    800054b6:	79a2                	ld	s3,40(sp)
    800054b8:	7a02                	ld	s4,32(sp)
    800054ba:	6ae2                	ld	s5,24(sp)
    800054bc:	6161                	addi	sp,sp,80
    800054be:	8082                	ret

00000000800054c0 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);
static int add_pagetable_modifications(pagetable_t oldpagetable, pagetable_t newpagetable, uint64 oldsz, uint64 sz);


int flags2perm(int flags)
{
    800054c0:	1141                	addi	sp,sp,-16
    800054c2:	e422                	sd	s0,8(sp)
    800054c4:	0800                	addi	s0,sp,16
    800054c6:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800054c8:	8905                	andi	a0,a0,1
    800054ca:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800054cc:	8b89                	andi	a5,a5,2
    800054ce:	c399                	beqz	a5,800054d4 <flags2perm+0x14>
      perm |= PTE_W;
    800054d0:	00456513          	ori	a0,a0,4
    return perm;
}
    800054d4:	6422                	ld	s0,8(sp)
    800054d6:	0141                	addi	sp,sp,16
    800054d8:	8082                	ret

00000000800054da <exec>:

int
exec(char *path, char **argv)
{
    800054da:	df010113          	addi	sp,sp,-528
    800054de:	20113423          	sd	ra,520(sp)
    800054e2:	20813023          	sd	s0,512(sp)
    800054e6:	ffa6                	sd	s1,504(sp)
    800054e8:	fbca                	sd	s2,496(sp)
    800054ea:	0c00                	addi	s0,sp,528
    800054ec:	892a                	mv	s2,a0
    800054ee:	dea43c23          	sd	a0,-520(s0)
    800054f2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800054f6:	ffffd097          	auipc	ra,0xffffd
    800054fa:	aca080e7          	jalr	-1334(ra) # 80001fc0 <myproc>
    800054fe:	84aa                	mv	s1,a0

  begin_op();
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	43a080e7          	jalr	1082(ra) # 8000493a <begin_op>

  if((ip = namei(path)) == 0){
    80005508:	854a                	mv	a0,s2
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	230080e7          	jalr	560(ra) # 8000473a <namei>
    80005512:	c135                	beqz	a0,80005576 <exec+0x9c>
    80005514:	f3d2                	sd	s4,480(sp)
    80005516:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005518:	fffff097          	auipc	ra,0xfffff
    8000551c:	a54080e7          	jalr	-1452(ra) # 80003f6c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005520:	04000713          	li	a4,64
    80005524:	4681                	li	a3,0
    80005526:	e5040613          	addi	a2,s0,-432
    8000552a:	4581                	li	a1,0
    8000552c:	8552                	mv	a0,s4
    8000552e:	fffff097          	auipc	ra,0xfffff
    80005532:	cf6080e7          	jalr	-778(ra) # 80004224 <readi>
    80005536:	04000793          	li	a5,64
    8000553a:	00f51a63          	bne	a0,a5,8000554e <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000553e:	e5042703          	lw	a4,-432(s0)
    80005542:	464c47b7          	lui	a5,0x464c4
    80005546:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000554a:	02f70c63          	beq	a4,a5,80005582 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000554e:	8552                	mv	a0,s4
    80005550:	fffff097          	auipc	ra,0xfffff
    80005554:	c82080e7          	jalr	-894(ra) # 800041d2 <iunlockput>
    end_op();
    80005558:	fffff097          	auipc	ra,0xfffff
    8000555c:	45c080e7          	jalr	1116(ra) # 800049b4 <end_op>
  }
  return -1;
    80005560:	557d                	li	a0,-1
    80005562:	7a1e                	ld	s4,480(sp)
}
    80005564:	20813083          	ld	ra,520(sp)
    80005568:	20013403          	ld	s0,512(sp)
    8000556c:	74fe                	ld	s1,504(sp)
    8000556e:	795e                	ld	s2,496(sp)
    80005570:	21010113          	addi	sp,sp,528
    80005574:	8082                	ret
    end_op();
    80005576:	fffff097          	auipc	ra,0xfffff
    8000557a:	43e080e7          	jalr	1086(ra) # 800049b4 <end_op>
    return -1;
    8000557e:	557d                	li	a0,-1
    80005580:	b7d5                	j	80005564 <exec+0x8a>
    80005582:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005584:	8526                	mv	a0,s1
    80005586:	ffffd097          	auipc	ra,0xffffd
    8000558a:	afe080e7          	jalr	-1282(ra) # 80002084 <proc_pagetable>
    8000558e:	8b2a                	mv	s6,a0
    80005590:	3e050863          	beqz	a0,80005980 <exec+0x4a6>
    80005594:	f7ce                	sd	s3,488(sp)
    80005596:	efd6                	sd	s5,472(sp)
    80005598:	e7de                	sd	s7,456(sp)
    8000559a:	e3e2                	sd	s8,448(sp)
    8000559c:	ff66                	sd	s9,440(sp)
    8000559e:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055a0:	e7042d03          	lw	s10,-400(s0)
    800055a4:	e8845783          	lhu	a5,-376(s0)
    800055a8:	14078d63          	beqz	a5,80005702 <exec+0x228>
    800055ac:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800055ae:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055b0:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800055b2:	6c85                	lui	s9,0x1
    800055b4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800055b8:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800055bc:	6a85                	lui	s5,0x1
    800055be:	a0b5                	j	8000562a <exec+0x150>
      panic("loadseg: address should exist");
    800055c0:	00003517          	auipc	a0,0x3
    800055c4:	2b850513          	addi	a0,a0,696 # 80008878 <__func__.1+0x870>
    800055c8:	ffffb097          	auipc	ra,0xffffb
    800055cc:	f98080e7          	jalr	-104(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    800055d0:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800055d2:	8726                	mv	a4,s1
    800055d4:	012c06bb          	addw	a3,s8,s2
    800055d8:	4581                	li	a1,0
    800055da:	8552                	mv	a0,s4
    800055dc:	fffff097          	auipc	ra,0xfffff
    800055e0:	c48080e7          	jalr	-952(ra) # 80004224 <readi>
    800055e4:	2501                	sext.w	a0,a0
    800055e6:	36a49163          	bne	s1,a0,80005948 <exec+0x46e>
  for(i = 0; i < sz; i += PGSIZE){
    800055ea:	012a893b          	addw	s2,s5,s2
    800055ee:	03397563          	bgeu	s2,s3,80005618 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    800055f2:	02091593          	slli	a1,s2,0x20
    800055f6:	9181                	srli	a1,a1,0x20
    800055f8:	95de                	add	a1,a1,s7
    800055fa:	855a                	mv	a0,s6
    800055fc:	ffffc097          	auipc	ra,0xffffc
    80005600:	b94080e7          	jalr	-1132(ra) # 80001190 <walkaddr>
    80005604:	862a                	mv	a2,a0
    if(pa == 0)
    80005606:	dd4d                	beqz	a0,800055c0 <exec+0xe6>
    if(sz - i < PGSIZE)
    80005608:	412984bb          	subw	s1,s3,s2
    8000560c:	0004879b          	sext.w	a5,s1
    80005610:	fcfcf0e3          	bgeu	s9,a5,800055d0 <exec+0xf6>
    80005614:	84d6                	mv	s1,s5
    80005616:	bf6d                	j	800055d0 <exec+0xf6>
    sz = sz1;
    80005618:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000561c:	2d85                	addiw	s11,s11,1
    8000561e:	038d0d1b          	addiw	s10,s10,56
    80005622:	e8845783          	lhu	a5,-376(s0)
    80005626:	08fdd663          	bge	s11,a5,800056b2 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000562a:	2d01                	sext.w	s10,s10
    8000562c:	03800713          	li	a4,56
    80005630:	86ea                	mv	a3,s10
    80005632:	e1840613          	addi	a2,s0,-488
    80005636:	4581                	li	a1,0
    80005638:	8552                	mv	a0,s4
    8000563a:	fffff097          	auipc	ra,0xfffff
    8000563e:	bea080e7          	jalr	-1046(ra) # 80004224 <readi>
    80005642:	03800793          	li	a5,56
    80005646:	2cf51963          	bne	a0,a5,80005918 <exec+0x43e>
    if(ph.type != ELF_PROG_LOAD)
    8000564a:	e1842783          	lw	a5,-488(s0)
    8000564e:	4705                	li	a4,1
    80005650:	fce796e3          	bne	a5,a4,8000561c <exec+0x142>
    if(ph.memsz < ph.filesz)
    80005654:	e4043483          	ld	s1,-448(s0)
    80005658:	e3843783          	ld	a5,-456(s0)
    8000565c:	2cf4e263          	bltu	s1,a5,80005920 <exec+0x446>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005660:	e2843783          	ld	a5,-472(s0)
    80005664:	94be                	add	s1,s1,a5
    80005666:	2cf4e163          	bltu	s1,a5,80005928 <exec+0x44e>
    if(ph.vaddr % PGSIZE != 0)
    8000566a:	df043703          	ld	a4,-528(s0)
    8000566e:	8ff9                	and	a5,a5,a4
    80005670:	2c079063          	bnez	a5,80005930 <exec+0x456>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005674:	e1c42503          	lw	a0,-484(s0)
    80005678:	00000097          	auipc	ra,0x0
    8000567c:	e48080e7          	jalr	-440(ra) # 800054c0 <flags2perm>
    80005680:	86aa                	mv	a3,a0
    80005682:	8626                	mv	a2,s1
    80005684:	85ca                	mv	a1,s2
    80005686:	855a                	mv	a0,s6
    80005688:	ffffc097          	auipc	ra,0xffffc
    8000568c:	0c8080e7          	jalr	200(ra) # 80001750 <uvmalloc>
    80005690:	e0a43423          	sd	a0,-504(s0)
    80005694:	2a050263          	beqz	a0,80005938 <exec+0x45e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005698:	e2843b83          	ld	s7,-472(s0)
    8000569c:	e2042c03          	lw	s8,-480(s0)
    800056a0:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800056a4:	00098463          	beqz	s3,800056ac <exec+0x1d2>
    800056a8:	4901                	li	s2,0
    800056aa:	b7a1                	j	800055f2 <exec+0x118>
    sz = sz1;
    800056ac:	e0843903          	ld	s2,-504(s0)
    800056b0:	b7b5                	j	8000561c <exec+0x142>
    800056b2:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800056b4:	8552                	mv	a0,s4
    800056b6:	fffff097          	auipc	ra,0xfffff
    800056ba:	b1c080e7          	jalr	-1252(ra) # 800041d2 <iunlockput>
  end_op();
    800056be:	fffff097          	auipc	ra,0xfffff
    800056c2:	2f6080e7          	jalr	758(ra) # 800049b4 <end_op>
  p = myproc();
    800056c6:	ffffd097          	auipc	ra,0xffffd
    800056ca:	8fa080e7          	jalr	-1798(ra) # 80001fc0 <myproc>
    800056ce:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800056d0:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800056d4:	6985                	lui	s3,0x1
    800056d6:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800056d8:	99ca                	add	s3,s3,s2
    800056da:	77fd                	lui	a5,0xfffff
    800056dc:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800056e0:	4691                	li	a3,4
    800056e2:	6609                	lui	a2,0x2
    800056e4:	964e                	add	a2,a2,s3
    800056e6:	85ce                	mv	a1,s3
    800056e8:	855a                	mv	a0,s6
    800056ea:	ffffc097          	auipc	ra,0xffffc
    800056ee:	066080e7          	jalr	102(ra) # 80001750 <uvmalloc>
    800056f2:	892a                	mv	s2,a0
    800056f4:	e0a43423          	sd	a0,-504(s0)
    800056f8:	e519                	bnez	a0,80005706 <exec+0x22c>
  if(pagetable)
    800056fa:	e1343423          	sd	s3,-504(s0)
    800056fe:	4a01                	li	s4,0
    80005700:	a4a9                	j	8000594a <exec+0x470>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005702:	4901                	li	s2,0
    80005704:	bf45                	j	800056b4 <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005706:	75f9                	lui	a1,0xffffe
    80005708:	95aa                	add	a1,a1,a0
    8000570a:	855a                	mv	a0,s6
    8000570c:	ffffc097          	auipc	ra,0xffffc
    80005710:	350080e7          	jalr	848(ra) # 80001a5c <uvmclear>
  stackbase = sp - PGSIZE;
    80005714:	7bfd                	lui	s7,0xfffff
    80005716:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005718:	e0043783          	ld	a5,-512(s0)
    8000571c:	6388                	ld	a0,0(a5)
    8000571e:	c52d                	beqz	a0,80005788 <exec+0x2ae>
    80005720:	e9040993          	addi	s3,s0,-368
    80005724:	f9040c13          	addi	s8,s0,-112
    80005728:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000572a:	ffffc097          	auipc	ra,0xffffc
    8000572e:	850080e7          	jalr	-1968(ra) # 80000f7a <strlen>
    80005732:	0015079b          	addiw	a5,a0,1
    80005736:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000573a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000573e:	21796163          	bltu	s2,s7,80005940 <exec+0x466>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005742:	e0043d03          	ld	s10,-512(s0)
    80005746:	000d3a03          	ld	s4,0(s10)
    8000574a:	8552                	mv	a0,s4
    8000574c:	ffffc097          	auipc	ra,0xffffc
    80005750:	82e080e7          	jalr	-2002(ra) # 80000f7a <strlen>
    80005754:	0015069b          	addiw	a3,a0,1
    80005758:	8652                	mv	a2,s4
    8000575a:	85ca                	mv	a1,s2
    8000575c:	855a                	mv	a0,s6
    8000575e:	ffffc097          	auipc	ra,0xffffc
    80005762:	330080e7          	jalr	816(ra) # 80001a8e <copyout>
    80005766:	1c054f63          	bltz	a0,80005944 <exec+0x46a>
    ustack[argc] = sp;
    8000576a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000576e:	0485                	addi	s1,s1,1
    80005770:	008d0793          	addi	a5,s10,8
    80005774:	e0f43023          	sd	a5,-512(s0)
    80005778:	008d3503          	ld	a0,8(s10)
    8000577c:	c909                	beqz	a0,8000578e <exec+0x2b4>
    if(argc >= MAXARG)
    8000577e:	09a1                	addi	s3,s3,8
    80005780:	fb8995e3          	bne	s3,s8,8000572a <exec+0x250>
  ip = 0;
    80005784:	4a01                	li	s4,0
    80005786:	a2d1                	j	8000594a <exec+0x470>
  sp = sz;
    80005788:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000578c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000578e:	00349793          	slli	a5,s1,0x3
    80005792:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ff5a300>
    80005796:	97a2                	add	a5,a5,s0
    80005798:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000579c:	00148693          	addi	a3,s1,1
    800057a0:	068e                	slli	a3,a3,0x3
    800057a2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800057a6:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800057aa:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800057ae:	f57966e3          	bltu	s2,s7,800056fa <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800057b2:	e9040613          	addi	a2,s0,-368
    800057b6:	85ca                	mv	a1,s2
    800057b8:	855a                	mv	a0,s6
    800057ba:	ffffc097          	auipc	ra,0xffffc
    800057be:	2d4080e7          	jalr	724(ra) # 80001a8e <copyout>
    800057c2:	1c054163          	bltz	a0,80005984 <exec+0x4aa>
  p->trapframe->a1 = sp;
    800057c6:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800057ca:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800057ce:	df843783          	ld	a5,-520(s0)
    800057d2:	0007c703          	lbu	a4,0(a5)
    800057d6:	cf11                	beqz	a4,800057f2 <exec+0x318>
    800057d8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800057da:	02f00693          	li	a3,47
    800057de:	a039                	j	800057ec <exec+0x312>
      last = s+1;
    800057e0:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800057e4:	0785                	addi	a5,a5,1
    800057e6:	fff7c703          	lbu	a4,-1(a5)
    800057ea:	c701                	beqz	a4,800057f2 <exec+0x318>
    if(*s == '/')
    800057ec:	fed71ce3          	bne	a4,a3,800057e4 <exec+0x30a>
    800057f0:	bfc5                	j	800057e0 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    800057f2:	4641                	li	a2,16
    800057f4:	df843583          	ld	a1,-520(s0)
    800057f8:	158a8513          	addi	a0,s5,344
    800057fc:	ffffb097          	auipc	ra,0xffffb
    80005800:	74c080e7          	jalr	1868(ra) # 80000f48 <safestrcpy>
  oldpagetable = p->pagetable;
    80005804:	050abd03          	ld	s10,80(s5)
}

static int
add_pagetable_modifications(pagetable_t oldpagetable, pagetable_t pagetable, uint64 oldsz, uint64 newsz){

  for (uint64 va = 0; va < oldsz && va < newsz; va += PGSIZE) {
    80005808:	0c0c8863          	beqz	s9,800058d8 <exec+0x3fe>
    8000580c:	4981                	li	s3,0
    8000580e:	a809                	j	80005820 <exec+0x346>
    80005810:	6785                	lui	a5,0x1
    80005812:	99be                	add	s3,s3,a5
    80005814:	0d99f263          	bgeu	s3,s9,800058d8 <exec+0x3fe>
    80005818:	e0843783          	ld	a5,-504(s0)
    8000581c:	0af9fe63          	bgeu	s3,a5,800058d8 <exec+0x3fe>
    // Get the corresponding page table entries.
    pte_t *oldpte = walk(oldpagetable, va, 0);
    80005820:	4601                	li	a2,0
    80005822:	85ce                	mv	a1,s3
    80005824:	856a                	mv	a0,s10
    80005826:	ffffc097          	auipc	ra,0xffffc
    8000582a:	8c4080e7          	jalr	-1852(ra) # 800010ea <walk>
    8000582e:	8a2a                	mv	s4,a0
    pte_t *newpte = walk(pagetable, va, 0);
    80005830:	4601                	li	a2,0
    80005832:	85ce                	mv	a1,s3
    80005834:	855a                	mv	a0,s6
    80005836:	ffffc097          	auipc	ra,0xffffc
    8000583a:	8b4080e7          	jalr	-1868(ra) # 800010ea <walk>
    8000583e:	8baa                	mv	s7,a0
    char* mem;
    // If either entry doesn't exist or is not valid, skip this address.
    if(oldpte == 0 || newpte == 0 || !(*oldpte & PTE_V) || !(*newpte & PTE_V))
    80005840:	fc0a08e3          	beqz	s4,80005810 <exec+0x336>
    80005844:	d571                	beqz	a0,80005810 <exec+0x336>
    80005846:	000a3703          	ld	a4,0(s4)
    8000584a:	00177793          	andi	a5,a4,1
    8000584e:	d3e9                	beqz	a5,80005810 <exec+0x336>
    80005850:	611c                	ld	a5,0(a0)
    80005852:	0017f693          	andi	a3,a5,1
    80005856:	decd                	beqz	a3,80005810 <exec+0x336>
      continue;

    // Get physical addresses from the entries.
    uint64 old_pa = PTE2PA(*oldpte);
    80005858:	8329                	srli	a4,a4,0xa
    8000585a:	00c71c13          	slli	s8,a4,0xc
    uint64 new_pa = PTE2PA(*newpte);
    8000585e:	83a9                	srli	a5,a5,0xa
    
    // Compare the contents of the two pages.
    if(memcmp((void *)old_pa, (void *)new_pa, PGSIZE) == 0) {
    80005860:	6605                	lui	a2,0x1
    80005862:	00c79593          	slli	a1,a5,0xc
    80005866:	8562                	mv	a0,s8
    80005868:	ffffb097          	auipc	ra,0xffffb
    8000586c:	5c0080e7          	jalr	1472(ra) # 80000e28 <memcmp>
    80005870:	f145                	bnez	a0,80005810 <exec+0x336>
      // Remapping old page table entry
      free_pte(newpte);
    80005872:	855e                	mv	a0,s7
    80005874:	ffffc097          	auipc	ra,0xffffc
    80005878:	6ba080e7          	jalr	1722(ra) # 80001f2e <free_pte>

      if ((newpte = kalloc()) == 0){
    8000587c:	ffffb097          	auipc	ra,0xffffb
    80005880:	348080e7          	jalr	840(ra) # 80000bc4 <kalloc>
    80005884:	10050363          	beqz	a0,8000598a <exec+0x4b0>
        return -1;
      }
      memmove(newpte, oldpte, PGSIZE);
    80005888:	6605                	lui	a2,0x1
    8000588a:	85d2                	mv	a1,s4
    8000588c:	ffffb097          	auipc	ra,0xffffb
    80005890:	5d6080e7          	jalr	1494(ra) # 80000e62 <memmove>
      uint64 flags = PTE_FLAGS(*oldpte);
    80005894:	000a3b83          	ld	s7,0(s4)
    80005898:	3ffbfb93          	andi	s7,s7,1023
      if((mem = kalloc()) == 0){
    8000589c:	ffffb097          	auipc	ra,0xffffb
    800058a0:	328080e7          	jalr	808(ra) # 80000bc4 <kalloc>
    800058a4:	8a2a                	mv	s4,a0
    800058a6:	c175                	beqz	a0,8000598a <exec+0x4b0>
        return -1;
      }
      memmove(mem, (char*)old_pa, PGSIZE);
    800058a8:	6605                	lui	a2,0x1
    800058aa:	85e2                	mv	a1,s8
    800058ac:	ffffb097          	auipc	ra,0xffffb
    800058b0:	5b6080e7          	jalr	1462(ra) # 80000e62 <memmove>
      if(mappages(pagetable, va, PGSIZE, (uint64)mem, flags) != 0){
    800058b4:	875e                	mv	a4,s7
    800058b6:	86d2                	mv	a3,s4
    800058b8:	6605                	lui	a2,0x1
    800058ba:	85ce                	mv	a1,s3
    800058bc:	855a                	mv	a0,s6
    800058be:	ffffc097          	auipc	ra,0xffffc
    800058c2:	a38080e7          	jalr	-1480(ra) # 800012f6 <mappages>
    800058c6:	d529                	beqz	a0,80005810 <exec+0x336>
        kfree(mem);
    800058c8:	8552                	mv	a0,s4
    800058ca:	ffffb097          	auipc	ra,0xffffb
    800058ce:	192080e7          	jalr	402(ra) # 80000a5c <kfree>
  sz = sz1;
    800058d2:	e0843983          	ld	s3,-504(s0)
    800058d6:	b515                	j	800056fa <exec+0x220>
  p->pagetable = pagetable;
    800058d8:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800058dc:	e0843783          	ld	a5,-504(s0)
    800058e0:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800058e4:	058ab783          	ld	a5,88(s5)
    800058e8:	e6843703          	ld	a4,-408(s0)
    800058ec:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800058ee:	058ab783          	ld	a5,88(s5)
    800058f2:	0327b823          	sd	s2,48(a5) # 1030 <_entry-0x7fffefd0>
  proc_freepagetable(oldpagetable, oldsz);
    800058f6:	85e6                	mv	a1,s9
    800058f8:	856a                	mv	a0,s10
    800058fa:	ffffd097          	auipc	ra,0xffffd
    800058fe:	824080e7          	jalr	-2012(ra) # 8000211e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005902:	0004851b          	sext.w	a0,s1
    80005906:	79be                	ld	s3,488(sp)
    80005908:	7a1e                	ld	s4,480(sp)
    8000590a:	6afe                	ld	s5,472(sp)
    8000590c:	6b5e                	ld	s6,464(sp)
    8000590e:	6bbe                	ld	s7,456(sp)
    80005910:	6c1e                	ld	s8,448(sp)
    80005912:	7cfa                	ld	s9,440(sp)
    80005914:	7d5a                	ld	s10,432(sp)
    80005916:	b1b9                	j	80005564 <exec+0x8a>
    80005918:	e1243423          	sd	s2,-504(s0)
    8000591c:	7dba                	ld	s11,424(sp)
    8000591e:	a035                	j	8000594a <exec+0x470>
    80005920:	e1243423          	sd	s2,-504(s0)
    80005924:	7dba                	ld	s11,424(sp)
    80005926:	a015                	j	8000594a <exec+0x470>
    80005928:	e1243423          	sd	s2,-504(s0)
    8000592c:	7dba                	ld	s11,424(sp)
    8000592e:	a831                	j	8000594a <exec+0x470>
    80005930:	e1243423          	sd	s2,-504(s0)
    80005934:	7dba                	ld	s11,424(sp)
    80005936:	a811                	j	8000594a <exec+0x470>
    80005938:	e1243423          	sd	s2,-504(s0)
    8000593c:	7dba                	ld	s11,424(sp)
    8000593e:	a031                	j	8000594a <exec+0x470>
  ip = 0;
    80005940:	4a01                	li	s4,0
    80005942:	a021                	j	8000594a <exec+0x470>
    80005944:	4a01                	li	s4,0
  if(pagetable)
    80005946:	a011                	j	8000594a <exec+0x470>
    80005948:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    8000594a:	e0843583          	ld	a1,-504(s0)
    8000594e:	855a                	mv	a0,s6
    80005950:	ffffc097          	auipc	ra,0xffffc
    80005954:	7ce080e7          	jalr	1998(ra) # 8000211e <proc_freepagetable>
  return -1;
    80005958:	557d                	li	a0,-1
  if(ip){
    8000595a:	000a1b63          	bnez	s4,80005970 <exec+0x496>
    8000595e:	79be                	ld	s3,488(sp)
    80005960:	7a1e                	ld	s4,480(sp)
    80005962:	6afe                	ld	s5,472(sp)
    80005964:	6b5e                	ld	s6,464(sp)
    80005966:	6bbe                	ld	s7,456(sp)
    80005968:	6c1e                	ld	s8,448(sp)
    8000596a:	7cfa                	ld	s9,440(sp)
    8000596c:	7d5a                	ld	s10,432(sp)
    8000596e:	bedd                	j	80005564 <exec+0x8a>
    80005970:	79be                	ld	s3,488(sp)
    80005972:	6afe                	ld	s5,472(sp)
    80005974:	6b5e                	ld	s6,464(sp)
    80005976:	6bbe                	ld	s7,456(sp)
    80005978:	6c1e                	ld	s8,448(sp)
    8000597a:	7cfa                	ld	s9,440(sp)
    8000597c:	7d5a                	ld	s10,432(sp)
    8000597e:	bec1                	j	8000554e <exec+0x74>
    80005980:	6b5e                	ld	s6,464(sp)
    80005982:	b6f1                	j	8000554e <exec+0x74>
  sz = sz1;
    80005984:	e0843983          	ld	s3,-504(s0)
    80005988:	bb8d                	j	800056fa <exec+0x220>
    8000598a:	e0843983          	ld	s3,-504(s0)
    8000598e:	b3b5                	j	800056fa <exec+0x220>

0000000080005990 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005990:	7179                	addi	sp,sp,-48
    80005992:	f406                	sd	ra,40(sp)
    80005994:	f022                	sd	s0,32(sp)
    80005996:	ec26                	sd	s1,24(sp)
    80005998:	e84a                	sd	s2,16(sp)
    8000599a:	1800                	addi	s0,sp,48
    8000599c:	892e                	mv	s2,a1
    8000599e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800059a0:	fdc40593          	addi	a1,s0,-36
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	916080e7          	jalr	-1770(ra) # 800032ba <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800059ac:	fdc42703          	lw	a4,-36(s0)
    800059b0:	47bd                	li	a5,15
    800059b2:	02e7eb63          	bltu	a5,a4,800059e8 <argfd+0x58>
    800059b6:	ffffc097          	auipc	ra,0xffffc
    800059ba:	60a080e7          	jalr	1546(ra) # 80001fc0 <myproc>
    800059be:	fdc42703          	lw	a4,-36(s0)
    800059c2:	01a70793          	addi	a5,a4,26
    800059c6:	078e                	slli	a5,a5,0x3
    800059c8:	953e                	add	a0,a0,a5
    800059ca:	611c                	ld	a5,0(a0)
    800059cc:	c385                	beqz	a5,800059ec <argfd+0x5c>
    return -1;
  if(pfd)
    800059ce:	00090463          	beqz	s2,800059d6 <argfd+0x46>
    *pfd = fd;
    800059d2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800059d6:	4501                	li	a0,0
  if(pf)
    800059d8:	c091                	beqz	s1,800059dc <argfd+0x4c>
    *pf = f;
    800059da:	e09c                	sd	a5,0(s1)
}
    800059dc:	70a2                	ld	ra,40(sp)
    800059de:	7402                	ld	s0,32(sp)
    800059e0:	64e2                	ld	s1,24(sp)
    800059e2:	6942                	ld	s2,16(sp)
    800059e4:	6145                	addi	sp,sp,48
    800059e6:	8082                	ret
    return -1;
    800059e8:	557d                	li	a0,-1
    800059ea:	bfcd                	j	800059dc <argfd+0x4c>
    800059ec:	557d                	li	a0,-1
    800059ee:	b7fd                	j	800059dc <argfd+0x4c>

00000000800059f0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800059f0:	1101                	addi	sp,sp,-32
    800059f2:	ec06                	sd	ra,24(sp)
    800059f4:	e822                	sd	s0,16(sp)
    800059f6:	e426                	sd	s1,8(sp)
    800059f8:	1000                	addi	s0,sp,32
    800059fa:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800059fc:	ffffc097          	auipc	ra,0xffffc
    80005a00:	5c4080e7          	jalr	1476(ra) # 80001fc0 <myproc>
    80005a04:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005a06:	0d050793          	addi	a5,a0,208
    80005a0a:	4501                	li	a0,0
    80005a0c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005a0e:	6398                	ld	a4,0(a5)
    80005a10:	cb19                	beqz	a4,80005a26 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005a12:	2505                	addiw	a0,a0,1
    80005a14:	07a1                	addi	a5,a5,8
    80005a16:	fed51ce3          	bne	a0,a3,80005a0e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005a1a:	557d                	li	a0,-1
}
    80005a1c:	60e2                	ld	ra,24(sp)
    80005a1e:	6442                	ld	s0,16(sp)
    80005a20:	64a2                	ld	s1,8(sp)
    80005a22:	6105                	addi	sp,sp,32
    80005a24:	8082                	ret
      p->ofile[fd] = f;
    80005a26:	01a50793          	addi	a5,a0,26
    80005a2a:	078e                	slli	a5,a5,0x3
    80005a2c:	963e                	add	a2,a2,a5
    80005a2e:	e204                	sd	s1,0(a2)
      return fd;
    80005a30:	b7f5                	j	80005a1c <fdalloc+0x2c>

0000000080005a32 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005a32:	715d                	addi	sp,sp,-80
    80005a34:	e486                	sd	ra,72(sp)
    80005a36:	e0a2                	sd	s0,64(sp)
    80005a38:	fc26                	sd	s1,56(sp)
    80005a3a:	f84a                	sd	s2,48(sp)
    80005a3c:	f44e                	sd	s3,40(sp)
    80005a3e:	ec56                	sd	s5,24(sp)
    80005a40:	e85a                	sd	s6,16(sp)
    80005a42:	0880                	addi	s0,sp,80
    80005a44:	8b2e                	mv	s6,a1
    80005a46:	89b2                	mv	s3,a2
    80005a48:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005a4a:	fb040593          	addi	a1,s0,-80
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	d0a080e7          	jalr	-758(ra) # 80004758 <nameiparent>
    80005a56:	84aa                	mv	s1,a0
    80005a58:	14050e63          	beqz	a0,80005bb4 <create+0x182>
    return 0;

  ilock(dp);
    80005a5c:	ffffe097          	auipc	ra,0xffffe
    80005a60:	510080e7          	jalr	1296(ra) # 80003f6c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005a64:	4601                	li	a2,0
    80005a66:	fb040593          	addi	a1,s0,-80
    80005a6a:	8526                	mv	a0,s1
    80005a6c:	fffff097          	auipc	ra,0xfffff
    80005a70:	a0c080e7          	jalr	-1524(ra) # 80004478 <dirlookup>
    80005a74:	8aaa                	mv	s5,a0
    80005a76:	c539                	beqz	a0,80005ac4 <create+0x92>
    iunlockput(dp);
    80005a78:	8526                	mv	a0,s1
    80005a7a:	ffffe097          	auipc	ra,0xffffe
    80005a7e:	758080e7          	jalr	1880(ra) # 800041d2 <iunlockput>
    ilock(ip);
    80005a82:	8556                	mv	a0,s5
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	4e8080e7          	jalr	1256(ra) # 80003f6c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005a8c:	4789                	li	a5,2
    80005a8e:	02fb1463          	bne	s6,a5,80005ab6 <create+0x84>
    80005a92:	044ad783          	lhu	a5,68(s5)
    80005a96:	37f9                	addiw	a5,a5,-2
    80005a98:	17c2                	slli	a5,a5,0x30
    80005a9a:	93c1                	srli	a5,a5,0x30
    80005a9c:	4705                	li	a4,1
    80005a9e:	00f76c63          	bltu	a4,a5,80005ab6 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005aa2:	8556                	mv	a0,s5
    80005aa4:	60a6                	ld	ra,72(sp)
    80005aa6:	6406                	ld	s0,64(sp)
    80005aa8:	74e2                	ld	s1,56(sp)
    80005aaa:	7942                	ld	s2,48(sp)
    80005aac:	79a2                	ld	s3,40(sp)
    80005aae:	6ae2                	ld	s5,24(sp)
    80005ab0:	6b42                	ld	s6,16(sp)
    80005ab2:	6161                	addi	sp,sp,80
    80005ab4:	8082                	ret
    iunlockput(ip);
    80005ab6:	8556                	mv	a0,s5
    80005ab8:	ffffe097          	auipc	ra,0xffffe
    80005abc:	71a080e7          	jalr	1818(ra) # 800041d2 <iunlockput>
    return 0;
    80005ac0:	4a81                	li	s5,0
    80005ac2:	b7c5                	j	80005aa2 <create+0x70>
    80005ac4:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005ac6:	85da                	mv	a1,s6
    80005ac8:	4088                	lw	a0,0(s1)
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	2fe080e7          	jalr	766(ra) # 80003dc8 <ialloc>
    80005ad2:	8a2a                	mv	s4,a0
    80005ad4:	c531                	beqz	a0,80005b20 <create+0xee>
  ilock(ip);
    80005ad6:	ffffe097          	auipc	ra,0xffffe
    80005ada:	496080e7          	jalr	1174(ra) # 80003f6c <ilock>
  ip->major = major;
    80005ade:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005ae2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005ae6:	4905                	li	s2,1
    80005ae8:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005aec:	8552                	mv	a0,s4
    80005aee:	ffffe097          	auipc	ra,0xffffe
    80005af2:	3b2080e7          	jalr	946(ra) # 80003ea0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005af6:	032b0d63          	beq	s6,s2,80005b30 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005afa:	004a2603          	lw	a2,4(s4)
    80005afe:	fb040593          	addi	a1,s0,-80
    80005b02:	8526                	mv	a0,s1
    80005b04:	fffff097          	auipc	ra,0xfffff
    80005b08:	b84080e7          	jalr	-1148(ra) # 80004688 <dirlink>
    80005b0c:	08054163          	bltz	a0,80005b8e <create+0x15c>
  iunlockput(dp);
    80005b10:	8526                	mv	a0,s1
    80005b12:	ffffe097          	auipc	ra,0xffffe
    80005b16:	6c0080e7          	jalr	1728(ra) # 800041d2 <iunlockput>
  return ip;
    80005b1a:	8ad2                	mv	s5,s4
    80005b1c:	7a02                	ld	s4,32(sp)
    80005b1e:	b751                	j	80005aa2 <create+0x70>
    iunlockput(dp);
    80005b20:	8526                	mv	a0,s1
    80005b22:	ffffe097          	auipc	ra,0xffffe
    80005b26:	6b0080e7          	jalr	1712(ra) # 800041d2 <iunlockput>
    return 0;
    80005b2a:	8ad2                	mv	s5,s4
    80005b2c:	7a02                	ld	s4,32(sp)
    80005b2e:	bf95                	j	80005aa2 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005b30:	004a2603          	lw	a2,4(s4)
    80005b34:	00003597          	auipc	a1,0x3
    80005b38:	d6458593          	addi	a1,a1,-668 # 80008898 <__func__.1+0x890>
    80005b3c:	8552                	mv	a0,s4
    80005b3e:	fffff097          	auipc	ra,0xfffff
    80005b42:	b4a080e7          	jalr	-1206(ra) # 80004688 <dirlink>
    80005b46:	04054463          	bltz	a0,80005b8e <create+0x15c>
    80005b4a:	40d0                	lw	a2,4(s1)
    80005b4c:	00003597          	auipc	a1,0x3
    80005b50:	d5458593          	addi	a1,a1,-684 # 800088a0 <__func__.1+0x898>
    80005b54:	8552                	mv	a0,s4
    80005b56:	fffff097          	auipc	ra,0xfffff
    80005b5a:	b32080e7          	jalr	-1230(ra) # 80004688 <dirlink>
    80005b5e:	02054863          	bltz	a0,80005b8e <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005b62:	004a2603          	lw	a2,4(s4)
    80005b66:	fb040593          	addi	a1,s0,-80
    80005b6a:	8526                	mv	a0,s1
    80005b6c:	fffff097          	auipc	ra,0xfffff
    80005b70:	b1c080e7          	jalr	-1252(ra) # 80004688 <dirlink>
    80005b74:	00054d63          	bltz	a0,80005b8e <create+0x15c>
    dp->nlink++;  // for ".."
    80005b78:	04a4d783          	lhu	a5,74(s1)
    80005b7c:	2785                	addiw	a5,a5,1
    80005b7e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b82:	8526                	mv	a0,s1
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	31c080e7          	jalr	796(ra) # 80003ea0 <iupdate>
    80005b8c:	b751                	j	80005b10 <create+0xde>
  ip->nlink = 0;
    80005b8e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005b92:	8552                	mv	a0,s4
    80005b94:	ffffe097          	auipc	ra,0xffffe
    80005b98:	30c080e7          	jalr	780(ra) # 80003ea0 <iupdate>
  iunlockput(ip);
    80005b9c:	8552                	mv	a0,s4
    80005b9e:	ffffe097          	auipc	ra,0xffffe
    80005ba2:	634080e7          	jalr	1588(ra) # 800041d2 <iunlockput>
  iunlockput(dp);
    80005ba6:	8526                	mv	a0,s1
    80005ba8:	ffffe097          	auipc	ra,0xffffe
    80005bac:	62a080e7          	jalr	1578(ra) # 800041d2 <iunlockput>
  return 0;
    80005bb0:	7a02                	ld	s4,32(sp)
    80005bb2:	bdc5                	j	80005aa2 <create+0x70>
    return 0;
    80005bb4:	8aaa                	mv	s5,a0
    80005bb6:	b5f5                	j	80005aa2 <create+0x70>

0000000080005bb8 <sys_dup>:
{
    80005bb8:	7179                	addi	sp,sp,-48
    80005bba:	f406                	sd	ra,40(sp)
    80005bbc:	f022                	sd	s0,32(sp)
    80005bbe:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005bc0:	fd840613          	addi	a2,s0,-40
    80005bc4:	4581                	li	a1,0
    80005bc6:	4501                	li	a0,0
    80005bc8:	00000097          	auipc	ra,0x0
    80005bcc:	dc8080e7          	jalr	-568(ra) # 80005990 <argfd>
    return -1;
    80005bd0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005bd2:	02054763          	bltz	a0,80005c00 <sys_dup+0x48>
    80005bd6:	ec26                	sd	s1,24(sp)
    80005bd8:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005bda:	fd843903          	ld	s2,-40(s0)
    80005bde:	854a                	mv	a0,s2
    80005be0:	00000097          	auipc	ra,0x0
    80005be4:	e10080e7          	jalr	-496(ra) # 800059f0 <fdalloc>
    80005be8:	84aa                	mv	s1,a0
    return -1;
    80005bea:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005bec:	00054f63          	bltz	a0,80005c0a <sys_dup+0x52>
  filedup(f);
    80005bf0:	854a                	mv	a0,s2
    80005bf2:	fffff097          	auipc	ra,0xfffff
    80005bf6:	1c0080e7          	jalr	448(ra) # 80004db2 <filedup>
  return fd;
    80005bfa:	87a6                	mv	a5,s1
    80005bfc:	64e2                	ld	s1,24(sp)
    80005bfe:	6942                	ld	s2,16(sp)
}
    80005c00:	853e                	mv	a0,a5
    80005c02:	70a2                	ld	ra,40(sp)
    80005c04:	7402                	ld	s0,32(sp)
    80005c06:	6145                	addi	sp,sp,48
    80005c08:	8082                	ret
    80005c0a:	64e2                	ld	s1,24(sp)
    80005c0c:	6942                	ld	s2,16(sp)
    80005c0e:	bfcd                	j	80005c00 <sys_dup+0x48>

0000000080005c10 <sys_read>:
{
    80005c10:	7179                	addi	sp,sp,-48
    80005c12:	f406                	sd	ra,40(sp)
    80005c14:	f022                	sd	s0,32(sp)
    80005c16:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005c18:	fd840593          	addi	a1,s0,-40
    80005c1c:	4505                	li	a0,1
    80005c1e:	ffffd097          	auipc	ra,0xffffd
    80005c22:	6bc080e7          	jalr	1724(ra) # 800032da <argaddr>
  argint(2, &n);
    80005c26:	fe440593          	addi	a1,s0,-28
    80005c2a:	4509                	li	a0,2
    80005c2c:	ffffd097          	auipc	ra,0xffffd
    80005c30:	68e080e7          	jalr	1678(ra) # 800032ba <argint>
  if(argfd(0, 0, &f) < 0)
    80005c34:	fe840613          	addi	a2,s0,-24
    80005c38:	4581                	li	a1,0
    80005c3a:	4501                	li	a0,0
    80005c3c:	00000097          	auipc	ra,0x0
    80005c40:	d54080e7          	jalr	-684(ra) # 80005990 <argfd>
    80005c44:	87aa                	mv	a5,a0
    return -1;
    80005c46:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c48:	0007cc63          	bltz	a5,80005c60 <sys_read+0x50>
  return fileread(f, p, n);
    80005c4c:	fe442603          	lw	a2,-28(s0)
    80005c50:	fd843583          	ld	a1,-40(s0)
    80005c54:	fe843503          	ld	a0,-24(s0)
    80005c58:	fffff097          	auipc	ra,0xfffff
    80005c5c:	300080e7          	jalr	768(ra) # 80004f58 <fileread>
}
    80005c60:	70a2                	ld	ra,40(sp)
    80005c62:	7402                	ld	s0,32(sp)
    80005c64:	6145                	addi	sp,sp,48
    80005c66:	8082                	ret

0000000080005c68 <sys_write>:
{
    80005c68:	7179                	addi	sp,sp,-48
    80005c6a:	f406                	sd	ra,40(sp)
    80005c6c:	f022                	sd	s0,32(sp)
    80005c6e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005c70:	fd840593          	addi	a1,s0,-40
    80005c74:	4505                	li	a0,1
    80005c76:	ffffd097          	auipc	ra,0xffffd
    80005c7a:	664080e7          	jalr	1636(ra) # 800032da <argaddr>
  argint(2, &n);
    80005c7e:	fe440593          	addi	a1,s0,-28
    80005c82:	4509                	li	a0,2
    80005c84:	ffffd097          	auipc	ra,0xffffd
    80005c88:	636080e7          	jalr	1590(ra) # 800032ba <argint>
  if(argfd(0, 0, &f) < 0)
    80005c8c:	fe840613          	addi	a2,s0,-24
    80005c90:	4581                	li	a1,0
    80005c92:	4501                	li	a0,0
    80005c94:	00000097          	auipc	ra,0x0
    80005c98:	cfc080e7          	jalr	-772(ra) # 80005990 <argfd>
    80005c9c:	87aa                	mv	a5,a0
    return -1;
    80005c9e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005ca0:	0007cc63          	bltz	a5,80005cb8 <sys_write+0x50>
  return filewrite(f, p, n);
    80005ca4:	fe442603          	lw	a2,-28(s0)
    80005ca8:	fd843583          	ld	a1,-40(s0)
    80005cac:	fe843503          	ld	a0,-24(s0)
    80005cb0:	fffff097          	auipc	ra,0xfffff
    80005cb4:	37a080e7          	jalr	890(ra) # 8000502a <filewrite>
}
    80005cb8:	70a2                	ld	ra,40(sp)
    80005cba:	7402                	ld	s0,32(sp)
    80005cbc:	6145                	addi	sp,sp,48
    80005cbe:	8082                	ret

0000000080005cc0 <sys_close>:
{
    80005cc0:	1101                	addi	sp,sp,-32
    80005cc2:	ec06                	sd	ra,24(sp)
    80005cc4:	e822                	sd	s0,16(sp)
    80005cc6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005cc8:	fe040613          	addi	a2,s0,-32
    80005ccc:	fec40593          	addi	a1,s0,-20
    80005cd0:	4501                	li	a0,0
    80005cd2:	00000097          	auipc	ra,0x0
    80005cd6:	cbe080e7          	jalr	-834(ra) # 80005990 <argfd>
    return -1;
    80005cda:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005cdc:	02054463          	bltz	a0,80005d04 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005ce0:	ffffc097          	auipc	ra,0xffffc
    80005ce4:	2e0080e7          	jalr	736(ra) # 80001fc0 <myproc>
    80005ce8:	fec42783          	lw	a5,-20(s0)
    80005cec:	07e9                	addi	a5,a5,26
    80005cee:	078e                	slli	a5,a5,0x3
    80005cf0:	953e                	add	a0,a0,a5
    80005cf2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005cf6:	fe043503          	ld	a0,-32(s0)
    80005cfa:	fffff097          	auipc	ra,0xfffff
    80005cfe:	10a080e7          	jalr	266(ra) # 80004e04 <fileclose>
  return 0;
    80005d02:	4781                	li	a5,0
}
    80005d04:	853e                	mv	a0,a5
    80005d06:	60e2                	ld	ra,24(sp)
    80005d08:	6442                	ld	s0,16(sp)
    80005d0a:	6105                	addi	sp,sp,32
    80005d0c:	8082                	ret

0000000080005d0e <sys_fstat>:
{
    80005d0e:	1101                	addi	sp,sp,-32
    80005d10:	ec06                	sd	ra,24(sp)
    80005d12:	e822                	sd	s0,16(sp)
    80005d14:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005d16:	fe040593          	addi	a1,s0,-32
    80005d1a:	4505                	li	a0,1
    80005d1c:	ffffd097          	auipc	ra,0xffffd
    80005d20:	5be080e7          	jalr	1470(ra) # 800032da <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005d24:	fe840613          	addi	a2,s0,-24
    80005d28:	4581                	li	a1,0
    80005d2a:	4501                	li	a0,0
    80005d2c:	00000097          	auipc	ra,0x0
    80005d30:	c64080e7          	jalr	-924(ra) # 80005990 <argfd>
    80005d34:	87aa                	mv	a5,a0
    return -1;
    80005d36:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d38:	0007ca63          	bltz	a5,80005d4c <sys_fstat+0x3e>
  return filestat(f, st);
    80005d3c:	fe043583          	ld	a1,-32(s0)
    80005d40:	fe843503          	ld	a0,-24(s0)
    80005d44:	fffff097          	auipc	ra,0xfffff
    80005d48:	1a2080e7          	jalr	418(ra) # 80004ee6 <filestat>
}
    80005d4c:	60e2                	ld	ra,24(sp)
    80005d4e:	6442                	ld	s0,16(sp)
    80005d50:	6105                	addi	sp,sp,32
    80005d52:	8082                	ret

0000000080005d54 <sys_link>:
{
    80005d54:	7169                	addi	sp,sp,-304
    80005d56:	f606                	sd	ra,296(sp)
    80005d58:	f222                	sd	s0,288(sp)
    80005d5a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d5c:	08000613          	li	a2,128
    80005d60:	ed040593          	addi	a1,s0,-304
    80005d64:	4501                	li	a0,0
    80005d66:	ffffd097          	auipc	ra,0xffffd
    80005d6a:	594080e7          	jalr	1428(ra) # 800032fa <argstr>
    return -1;
    80005d6e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d70:	12054663          	bltz	a0,80005e9c <sys_link+0x148>
    80005d74:	08000613          	li	a2,128
    80005d78:	f5040593          	addi	a1,s0,-176
    80005d7c:	4505                	li	a0,1
    80005d7e:	ffffd097          	auipc	ra,0xffffd
    80005d82:	57c080e7          	jalr	1404(ra) # 800032fa <argstr>
    return -1;
    80005d86:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d88:	10054a63          	bltz	a0,80005e9c <sys_link+0x148>
    80005d8c:	ee26                	sd	s1,280(sp)
  begin_op();
    80005d8e:	fffff097          	auipc	ra,0xfffff
    80005d92:	bac080e7          	jalr	-1108(ra) # 8000493a <begin_op>
  if((ip = namei(old)) == 0){
    80005d96:	ed040513          	addi	a0,s0,-304
    80005d9a:	fffff097          	auipc	ra,0xfffff
    80005d9e:	9a0080e7          	jalr	-1632(ra) # 8000473a <namei>
    80005da2:	84aa                	mv	s1,a0
    80005da4:	c949                	beqz	a0,80005e36 <sys_link+0xe2>
  ilock(ip);
    80005da6:	ffffe097          	auipc	ra,0xffffe
    80005daa:	1c6080e7          	jalr	454(ra) # 80003f6c <ilock>
  if(ip->type == T_DIR){
    80005dae:	04449703          	lh	a4,68(s1)
    80005db2:	4785                	li	a5,1
    80005db4:	08f70863          	beq	a4,a5,80005e44 <sys_link+0xf0>
    80005db8:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005dba:	04a4d783          	lhu	a5,74(s1)
    80005dbe:	2785                	addiw	a5,a5,1
    80005dc0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005dc4:	8526                	mv	a0,s1
    80005dc6:	ffffe097          	auipc	ra,0xffffe
    80005dca:	0da080e7          	jalr	218(ra) # 80003ea0 <iupdate>
  iunlock(ip);
    80005dce:	8526                	mv	a0,s1
    80005dd0:	ffffe097          	auipc	ra,0xffffe
    80005dd4:	262080e7          	jalr	610(ra) # 80004032 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005dd8:	fd040593          	addi	a1,s0,-48
    80005ddc:	f5040513          	addi	a0,s0,-176
    80005de0:	fffff097          	auipc	ra,0xfffff
    80005de4:	978080e7          	jalr	-1672(ra) # 80004758 <nameiparent>
    80005de8:	892a                	mv	s2,a0
    80005dea:	cd35                	beqz	a0,80005e66 <sys_link+0x112>
  ilock(dp);
    80005dec:	ffffe097          	auipc	ra,0xffffe
    80005df0:	180080e7          	jalr	384(ra) # 80003f6c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005df4:	00092703          	lw	a4,0(s2)
    80005df8:	409c                	lw	a5,0(s1)
    80005dfa:	06f71163          	bne	a4,a5,80005e5c <sys_link+0x108>
    80005dfe:	40d0                	lw	a2,4(s1)
    80005e00:	fd040593          	addi	a1,s0,-48
    80005e04:	854a                	mv	a0,s2
    80005e06:	fffff097          	auipc	ra,0xfffff
    80005e0a:	882080e7          	jalr	-1918(ra) # 80004688 <dirlink>
    80005e0e:	04054763          	bltz	a0,80005e5c <sys_link+0x108>
  iunlockput(dp);
    80005e12:	854a                	mv	a0,s2
    80005e14:	ffffe097          	auipc	ra,0xffffe
    80005e18:	3be080e7          	jalr	958(ra) # 800041d2 <iunlockput>
  iput(ip);
    80005e1c:	8526                	mv	a0,s1
    80005e1e:	ffffe097          	auipc	ra,0xffffe
    80005e22:	30c080e7          	jalr	780(ra) # 8000412a <iput>
  end_op();
    80005e26:	fffff097          	auipc	ra,0xfffff
    80005e2a:	b8e080e7          	jalr	-1138(ra) # 800049b4 <end_op>
  return 0;
    80005e2e:	4781                	li	a5,0
    80005e30:	64f2                	ld	s1,280(sp)
    80005e32:	6952                	ld	s2,272(sp)
    80005e34:	a0a5                	j	80005e9c <sys_link+0x148>
    end_op();
    80005e36:	fffff097          	auipc	ra,0xfffff
    80005e3a:	b7e080e7          	jalr	-1154(ra) # 800049b4 <end_op>
    return -1;
    80005e3e:	57fd                	li	a5,-1
    80005e40:	64f2                	ld	s1,280(sp)
    80005e42:	a8a9                	j	80005e9c <sys_link+0x148>
    iunlockput(ip);
    80005e44:	8526                	mv	a0,s1
    80005e46:	ffffe097          	auipc	ra,0xffffe
    80005e4a:	38c080e7          	jalr	908(ra) # 800041d2 <iunlockput>
    end_op();
    80005e4e:	fffff097          	auipc	ra,0xfffff
    80005e52:	b66080e7          	jalr	-1178(ra) # 800049b4 <end_op>
    return -1;
    80005e56:	57fd                	li	a5,-1
    80005e58:	64f2                	ld	s1,280(sp)
    80005e5a:	a089                	j	80005e9c <sys_link+0x148>
    iunlockput(dp);
    80005e5c:	854a                	mv	a0,s2
    80005e5e:	ffffe097          	auipc	ra,0xffffe
    80005e62:	374080e7          	jalr	884(ra) # 800041d2 <iunlockput>
  ilock(ip);
    80005e66:	8526                	mv	a0,s1
    80005e68:	ffffe097          	auipc	ra,0xffffe
    80005e6c:	104080e7          	jalr	260(ra) # 80003f6c <ilock>
  ip->nlink--;
    80005e70:	04a4d783          	lhu	a5,74(s1)
    80005e74:	37fd                	addiw	a5,a5,-1
    80005e76:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005e7a:	8526                	mv	a0,s1
    80005e7c:	ffffe097          	auipc	ra,0xffffe
    80005e80:	024080e7          	jalr	36(ra) # 80003ea0 <iupdate>
  iunlockput(ip);
    80005e84:	8526                	mv	a0,s1
    80005e86:	ffffe097          	auipc	ra,0xffffe
    80005e8a:	34c080e7          	jalr	844(ra) # 800041d2 <iunlockput>
  end_op();
    80005e8e:	fffff097          	auipc	ra,0xfffff
    80005e92:	b26080e7          	jalr	-1242(ra) # 800049b4 <end_op>
  return -1;
    80005e96:	57fd                	li	a5,-1
    80005e98:	64f2                	ld	s1,280(sp)
    80005e9a:	6952                	ld	s2,272(sp)
}
    80005e9c:	853e                	mv	a0,a5
    80005e9e:	70b2                	ld	ra,296(sp)
    80005ea0:	7412                	ld	s0,288(sp)
    80005ea2:	6155                	addi	sp,sp,304
    80005ea4:	8082                	ret

0000000080005ea6 <sys_unlink>:
{
    80005ea6:	7151                	addi	sp,sp,-240
    80005ea8:	f586                	sd	ra,232(sp)
    80005eaa:	f1a2                	sd	s0,224(sp)
    80005eac:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005eae:	08000613          	li	a2,128
    80005eb2:	f3040593          	addi	a1,s0,-208
    80005eb6:	4501                	li	a0,0
    80005eb8:	ffffd097          	auipc	ra,0xffffd
    80005ebc:	442080e7          	jalr	1090(ra) # 800032fa <argstr>
    80005ec0:	1a054a63          	bltz	a0,80006074 <sys_unlink+0x1ce>
    80005ec4:	eda6                	sd	s1,216(sp)
  begin_op();
    80005ec6:	fffff097          	auipc	ra,0xfffff
    80005eca:	a74080e7          	jalr	-1420(ra) # 8000493a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005ece:	fb040593          	addi	a1,s0,-80
    80005ed2:	f3040513          	addi	a0,s0,-208
    80005ed6:	fffff097          	auipc	ra,0xfffff
    80005eda:	882080e7          	jalr	-1918(ra) # 80004758 <nameiparent>
    80005ede:	84aa                	mv	s1,a0
    80005ee0:	cd71                	beqz	a0,80005fbc <sys_unlink+0x116>
  ilock(dp);
    80005ee2:	ffffe097          	auipc	ra,0xffffe
    80005ee6:	08a080e7          	jalr	138(ra) # 80003f6c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005eea:	00003597          	auipc	a1,0x3
    80005eee:	9ae58593          	addi	a1,a1,-1618 # 80008898 <__func__.1+0x890>
    80005ef2:	fb040513          	addi	a0,s0,-80
    80005ef6:	ffffe097          	auipc	ra,0xffffe
    80005efa:	568080e7          	jalr	1384(ra) # 8000445e <namecmp>
    80005efe:	14050c63          	beqz	a0,80006056 <sys_unlink+0x1b0>
    80005f02:	00003597          	auipc	a1,0x3
    80005f06:	99e58593          	addi	a1,a1,-1634 # 800088a0 <__func__.1+0x898>
    80005f0a:	fb040513          	addi	a0,s0,-80
    80005f0e:	ffffe097          	auipc	ra,0xffffe
    80005f12:	550080e7          	jalr	1360(ra) # 8000445e <namecmp>
    80005f16:	14050063          	beqz	a0,80006056 <sys_unlink+0x1b0>
    80005f1a:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005f1c:	f2c40613          	addi	a2,s0,-212
    80005f20:	fb040593          	addi	a1,s0,-80
    80005f24:	8526                	mv	a0,s1
    80005f26:	ffffe097          	auipc	ra,0xffffe
    80005f2a:	552080e7          	jalr	1362(ra) # 80004478 <dirlookup>
    80005f2e:	892a                	mv	s2,a0
    80005f30:	12050263          	beqz	a0,80006054 <sys_unlink+0x1ae>
  ilock(ip);
    80005f34:	ffffe097          	auipc	ra,0xffffe
    80005f38:	038080e7          	jalr	56(ra) # 80003f6c <ilock>
  if(ip->nlink < 1)
    80005f3c:	04a91783          	lh	a5,74(s2)
    80005f40:	08f05563          	blez	a5,80005fca <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005f44:	04491703          	lh	a4,68(s2)
    80005f48:	4785                	li	a5,1
    80005f4a:	08f70963          	beq	a4,a5,80005fdc <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005f4e:	4641                	li	a2,16
    80005f50:	4581                	li	a1,0
    80005f52:	fc040513          	addi	a0,s0,-64
    80005f56:	ffffb097          	auipc	ra,0xffffb
    80005f5a:	eb0080e7          	jalr	-336(ra) # 80000e06 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f5e:	4741                	li	a4,16
    80005f60:	f2c42683          	lw	a3,-212(s0)
    80005f64:	fc040613          	addi	a2,s0,-64
    80005f68:	4581                	li	a1,0
    80005f6a:	8526                	mv	a0,s1
    80005f6c:	ffffe097          	auipc	ra,0xffffe
    80005f70:	3c8080e7          	jalr	968(ra) # 80004334 <writei>
    80005f74:	47c1                	li	a5,16
    80005f76:	0af51b63          	bne	a0,a5,8000602c <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005f7a:	04491703          	lh	a4,68(s2)
    80005f7e:	4785                	li	a5,1
    80005f80:	0af70f63          	beq	a4,a5,8000603e <sys_unlink+0x198>
  iunlockput(dp);
    80005f84:	8526                	mv	a0,s1
    80005f86:	ffffe097          	auipc	ra,0xffffe
    80005f8a:	24c080e7          	jalr	588(ra) # 800041d2 <iunlockput>
  ip->nlink--;
    80005f8e:	04a95783          	lhu	a5,74(s2)
    80005f92:	37fd                	addiw	a5,a5,-1
    80005f94:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005f98:	854a                	mv	a0,s2
    80005f9a:	ffffe097          	auipc	ra,0xffffe
    80005f9e:	f06080e7          	jalr	-250(ra) # 80003ea0 <iupdate>
  iunlockput(ip);
    80005fa2:	854a                	mv	a0,s2
    80005fa4:	ffffe097          	auipc	ra,0xffffe
    80005fa8:	22e080e7          	jalr	558(ra) # 800041d2 <iunlockput>
  end_op();
    80005fac:	fffff097          	auipc	ra,0xfffff
    80005fb0:	a08080e7          	jalr	-1528(ra) # 800049b4 <end_op>
  return 0;
    80005fb4:	4501                	li	a0,0
    80005fb6:	64ee                	ld	s1,216(sp)
    80005fb8:	694e                	ld	s2,208(sp)
    80005fba:	a84d                	j	8000606c <sys_unlink+0x1c6>
    end_op();
    80005fbc:	fffff097          	auipc	ra,0xfffff
    80005fc0:	9f8080e7          	jalr	-1544(ra) # 800049b4 <end_op>
    return -1;
    80005fc4:	557d                	li	a0,-1
    80005fc6:	64ee                	ld	s1,216(sp)
    80005fc8:	a055                	j	8000606c <sys_unlink+0x1c6>
    80005fca:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005fcc:	00003517          	auipc	a0,0x3
    80005fd0:	8dc50513          	addi	a0,a0,-1828 # 800088a8 <__func__.1+0x8a0>
    80005fd4:	ffffa097          	auipc	ra,0xffffa
    80005fd8:	58c080e7          	jalr	1420(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005fdc:	04c92703          	lw	a4,76(s2)
    80005fe0:	02000793          	li	a5,32
    80005fe4:	f6e7f5e3          	bgeu	a5,a4,80005f4e <sys_unlink+0xa8>
    80005fe8:	e5ce                	sd	s3,200(sp)
    80005fea:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005fee:	4741                	li	a4,16
    80005ff0:	86ce                	mv	a3,s3
    80005ff2:	f1840613          	addi	a2,s0,-232
    80005ff6:	4581                	li	a1,0
    80005ff8:	854a                	mv	a0,s2
    80005ffa:	ffffe097          	auipc	ra,0xffffe
    80005ffe:	22a080e7          	jalr	554(ra) # 80004224 <readi>
    80006002:	47c1                	li	a5,16
    80006004:	00f51c63          	bne	a0,a5,8000601c <sys_unlink+0x176>
    if(de.inum != 0)
    80006008:	f1845783          	lhu	a5,-232(s0)
    8000600c:	e7b5                	bnez	a5,80006078 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000600e:	29c1                	addiw	s3,s3,16
    80006010:	04c92783          	lw	a5,76(s2)
    80006014:	fcf9ede3          	bltu	s3,a5,80005fee <sys_unlink+0x148>
    80006018:	69ae                	ld	s3,200(sp)
    8000601a:	bf15                	j	80005f4e <sys_unlink+0xa8>
      panic("isdirempty: readi");
    8000601c:	00003517          	auipc	a0,0x3
    80006020:	8a450513          	addi	a0,a0,-1884 # 800088c0 <__func__.1+0x8b8>
    80006024:	ffffa097          	auipc	ra,0xffffa
    80006028:	53c080e7          	jalr	1340(ra) # 80000560 <panic>
    8000602c:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000602e:	00003517          	auipc	a0,0x3
    80006032:	8aa50513          	addi	a0,a0,-1878 # 800088d8 <__func__.1+0x8d0>
    80006036:	ffffa097          	auipc	ra,0xffffa
    8000603a:	52a080e7          	jalr	1322(ra) # 80000560 <panic>
    dp->nlink--;
    8000603e:	04a4d783          	lhu	a5,74(s1)
    80006042:	37fd                	addiw	a5,a5,-1
    80006044:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006048:	8526                	mv	a0,s1
    8000604a:	ffffe097          	auipc	ra,0xffffe
    8000604e:	e56080e7          	jalr	-426(ra) # 80003ea0 <iupdate>
    80006052:	bf0d                	j	80005f84 <sys_unlink+0xde>
    80006054:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80006056:	8526                	mv	a0,s1
    80006058:	ffffe097          	auipc	ra,0xffffe
    8000605c:	17a080e7          	jalr	378(ra) # 800041d2 <iunlockput>
  end_op();
    80006060:	fffff097          	auipc	ra,0xfffff
    80006064:	954080e7          	jalr	-1708(ra) # 800049b4 <end_op>
  return -1;
    80006068:	557d                	li	a0,-1
    8000606a:	64ee                	ld	s1,216(sp)
}
    8000606c:	70ae                	ld	ra,232(sp)
    8000606e:	740e                	ld	s0,224(sp)
    80006070:	616d                	addi	sp,sp,240
    80006072:	8082                	ret
    return -1;
    80006074:	557d                	li	a0,-1
    80006076:	bfdd                	j	8000606c <sys_unlink+0x1c6>
    iunlockput(ip);
    80006078:	854a                	mv	a0,s2
    8000607a:	ffffe097          	auipc	ra,0xffffe
    8000607e:	158080e7          	jalr	344(ra) # 800041d2 <iunlockput>
    goto bad;
    80006082:	694e                	ld	s2,208(sp)
    80006084:	69ae                	ld	s3,200(sp)
    80006086:	bfc1                	j	80006056 <sys_unlink+0x1b0>

0000000080006088 <sys_open>:

uint64
sys_open(void)
{
    80006088:	7131                	addi	sp,sp,-192
    8000608a:	fd06                	sd	ra,184(sp)
    8000608c:	f922                	sd	s0,176(sp)
    8000608e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80006090:	f4c40593          	addi	a1,s0,-180
    80006094:	4505                	li	a0,1
    80006096:	ffffd097          	auipc	ra,0xffffd
    8000609a:	224080e7          	jalr	548(ra) # 800032ba <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000609e:	08000613          	li	a2,128
    800060a2:	f5040593          	addi	a1,s0,-176
    800060a6:	4501                	li	a0,0
    800060a8:	ffffd097          	auipc	ra,0xffffd
    800060ac:	252080e7          	jalr	594(ra) # 800032fa <argstr>
    800060b0:	87aa                	mv	a5,a0
    return -1;
    800060b2:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800060b4:	0a07ce63          	bltz	a5,80006170 <sys_open+0xe8>
    800060b8:	f526                	sd	s1,168(sp)

  begin_op();
    800060ba:	fffff097          	auipc	ra,0xfffff
    800060be:	880080e7          	jalr	-1920(ra) # 8000493a <begin_op>

  if(omode & O_CREATE){
    800060c2:	f4c42783          	lw	a5,-180(s0)
    800060c6:	2007f793          	andi	a5,a5,512
    800060ca:	cfd5                	beqz	a5,80006186 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800060cc:	4681                	li	a3,0
    800060ce:	4601                	li	a2,0
    800060d0:	4589                	li	a1,2
    800060d2:	f5040513          	addi	a0,s0,-176
    800060d6:	00000097          	auipc	ra,0x0
    800060da:	95c080e7          	jalr	-1700(ra) # 80005a32 <create>
    800060de:	84aa                	mv	s1,a0
    if(ip == 0){
    800060e0:	cd41                	beqz	a0,80006178 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800060e2:	04449703          	lh	a4,68(s1)
    800060e6:	478d                	li	a5,3
    800060e8:	00f71763          	bne	a4,a5,800060f6 <sys_open+0x6e>
    800060ec:	0464d703          	lhu	a4,70(s1)
    800060f0:	47a5                	li	a5,9
    800060f2:	0ee7e163          	bltu	a5,a4,800061d4 <sys_open+0x14c>
    800060f6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800060f8:	fffff097          	auipc	ra,0xfffff
    800060fc:	c50080e7          	jalr	-944(ra) # 80004d48 <filealloc>
    80006100:	892a                	mv	s2,a0
    80006102:	c97d                	beqz	a0,800061f8 <sys_open+0x170>
    80006104:	ed4e                	sd	s3,152(sp)
    80006106:	00000097          	auipc	ra,0x0
    8000610a:	8ea080e7          	jalr	-1814(ra) # 800059f0 <fdalloc>
    8000610e:	89aa                	mv	s3,a0
    80006110:	0c054e63          	bltz	a0,800061ec <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006114:	04449703          	lh	a4,68(s1)
    80006118:	478d                	li	a5,3
    8000611a:	0ef70c63          	beq	a4,a5,80006212 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000611e:	4789                	li	a5,2
    80006120:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80006124:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80006128:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000612c:	f4c42783          	lw	a5,-180(s0)
    80006130:	0017c713          	xori	a4,a5,1
    80006134:	8b05                	andi	a4,a4,1
    80006136:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000613a:	0037f713          	andi	a4,a5,3
    8000613e:	00e03733          	snez	a4,a4
    80006142:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006146:	4007f793          	andi	a5,a5,1024
    8000614a:	c791                	beqz	a5,80006156 <sys_open+0xce>
    8000614c:	04449703          	lh	a4,68(s1)
    80006150:	4789                	li	a5,2
    80006152:	0cf70763          	beq	a4,a5,80006220 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80006156:	8526                	mv	a0,s1
    80006158:	ffffe097          	auipc	ra,0xffffe
    8000615c:	eda080e7          	jalr	-294(ra) # 80004032 <iunlock>
  end_op();
    80006160:	fffff097          	auipc	ra,0xfffff
    80006164:	854080e7          	jalr	-1964(ra) # 800049b4 <end_op>

  return fd;
    80006168:	854e                	mv	a0,s3
    8000616a:	74aa                	ld	s1,168(sp)
    8000616c:	790a                	ld	s2,160(sp)
    8000616e:	69ea                	ld	s3,152(sp)
}
    80006170:	70ea                	ld	ra,184(sp)
    80006172:	744a                	ld	s0,176(sp)
    80006174:	6129                	addi	sp,sp,192
    80006176:	8082                	ret
      end_op();
    80006178:	fffff097          	auipc	ra,0xfffff
    8000617c:	83c080e7          	jalr	-1988(ra) # 800049b4 <end_op>
      return -1;
    80006180:	557d                	li	a0,-1
    80006182:	74aa                	ld	s1,168(sp)
    80006184:	b7f5                	j	80006170 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80006186:	f5040513          	addi	a0,s0,-176
    8000618a:	ffffe097          	auipc	ra,0xffffe
    8000618e:	5b0080e7          	jalr	1456(ra) # 8000473a <namei>
    80006192:	84aa                	mv	s1,a0
    80006194:	c90d                	beqz	a0,800061c6 <sys_open+0x13e>
    ilock(ip);
    80006196:	ffffe097          	auipc	ra,0xffffe
    8000619a:	dd6080e7          	jalr	-554(ra) # 80003f6c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000619e:	04449703          	lh	a4,68(s1)
    800061a2:	4785                	li	a5,1
    800061a4:	f2f71fe3          	bne	a4,a5,800060e2 <sys_open+0x5a>
    800061a8:	f4c42783          	lw	a5,-180(s0)
    800061ac:	d7a9                	beqz	a5,800060f6 <sys_open+0x6e>
      iunlockput(ip);
    800061ae:	8526                	mv	a0,s1
    800061b0:	ffffe097          	auipc	ra,0xffffe
    800061b4:	022080e7          	jalr	34(ra) # 800041d2 <iunlockput>
      end_op();
    800061b8:	ffffe097          	auipc	ra,0xffffe
    800061bc:	7fc080e7          	jalr	2044(ra) # 800049b4 <end_op>
      return -1;
    800061c0:	557d                	li	a0,-1
    800061c2:	74aa                	ld	s1,168(sp)
    800061c4:	b775                	j	80006170 <sys_open+0xe8>
      end_op();
    800061c6:	ffffe097          	auipc	ra,0xffffe
    800061ca:	7ee080e7          	jalr	2030(ra) # 800049b4 <end_op>
      return -1;
    800061ce:	557d                	li	a0,-1
    800061d0:	74aa                	ld	s1,168(sp)
    800061d2:	bf79                	j	80006170 <sys_open+0xe8>
    iunlockput(ip);
    800061d4:	8526                	mv	a0,s1
    800061d6:	ffffe097          	auipc	ra,0xffffe
    800061da:	ffc080e7          	jalr	-4(ra) # 800041d2 <iunlockput>
    end_op();
    800061de:	ffffe097          	auipc	ra,0xffffe
    800061e2:	7d6080e7          	jalr	2006(ra) # 800049b4 <end_op>
    return -1;
    800061e6:	557d                	li	a0,-1
    800061e8:	74aa                	ld	s1,168(sp)
    800061ea:	b759                	j	80006170 <sys_open+0xe8>
      fileclose(f);
    800061ec:	854a                	mv	a0,s2
    800061ee:	fffff097          	auipc	ra,0xfffff
    800061f2:	c16080e7          	jalr	-1002(ra) # 80004e04 <fileclose>
    800061f6:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800061f8:	8526                	mv	a0,s1
    800061fa:	ffffe097          	auipc	ra,0xffffe
    800061fe:	fd8080e7          	jalr	-40(ra) # 800041d2 <iunlockput>
    end_op();
    80006202:	ffffe097          	auipc	ra,0xffffe
    80006206:	7b2080e7          	jalr	1970(ra) # 800049b4 <end_op>
    return -1;
    8000620a:	557d                	li	a0,-1
    8000620c:	74aa                	ld	s1,168(sp)
    8000620e:	790a                	ld	s2,160(sp)
    80006210:	b785                	j	80006170 <sys_open+0xe8>
    f->type = FD_DEVICE;
    80006212:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80006216:	04649783          	lh	a5,70(s1)
    8000621a:	02f91223          	sh	a5,36(s2)
    8000621e:	b729                	j	80006128 <sys_open+0xa0>
    itrunc(ip);
    80006220:	8526                	mv	a0,s1
    80006222:	ffffe097          	auipc	ra,0xffffe
    80006226:	e5c080e7          	jalr	-420(ra) # 8000407e <itrunc>
    8000622a:	b735                	j	80006156 <sys_open+0xce>

000000008000622c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000622c:	7175                	addi	sp,sp,-144
    8000622e:	e506                	sd	ra,136(sp)
    80006230:	e122                	sd	s0,128(sp)
    80006232:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006234:	ffffe097          	auipc	ra,0xffffe
    80006238:	706080e7          	jalr	1798(ra) # 8000493a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000623c:	08000613          	li	a2,128
    80006240:	f7040593          	addi	a1,s0,-144
    80006244:	4501                	li	a0,0
    80006246:	ffffd097          	auipc	ra,0xffffd
    8000624a:	0b4080e7          	jalr	180(ra) # 800032fa <argstr>
    8000624e:	02054963          	bltz	a0,80006280 <sys_mkdir+0x54>
    80006252:	4681                	li	a3,0
    80006254:	4601                	li	a2,0
    80006256:	4585                	li	a1,1
    80006258:	f7040513          	addi	a0,s0,-144
    8000625c:	fffff097          	auipc	ra,0xfffff
    80006260:	7d6080e7          	jalr	2006(ra) # 80005a32 <create>
    80006264:	cd11                	beqz	a0,80006280 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006266:	ffffe097          	auipc	ra,0xffffe
    8000626a:	f6c080e7          	jalr	-148(ra) # 800041d2 <iunlockput>
  end_op();
    8000626e:	ffffe097          	auipc	ra,0xffffe
    80006272:	746080e7          	jalr	1862(ra) # 800049b4 <end_op>
  return 0;
    80006276:	4501                	li	a0,0
}
    80006278:	60aa                	ld	ra,136(sp)
    8000627a:	640a                	ld	s0,128(sp)
    8000627c:	6149                	addi	sp,sp,144
    8000627e:	8082                	ret
    end_op();
    80006280:	ffffe097          	auipc	ra,0xffffe
    80006284:	734080e7          	jalr	1844(ra) # 800049b4 <end_op>
    return -1;
    80006288:	557d                	li	a0,-1
    8000628a:	b7fd                	j	80006278 <sys_mkdir+0x4c>

000000008000628c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000628c:	7135                	addi	sp,sp,-160
    8000628e:	ed06                	sd	ra,152(sp)
    80006290:	e922                	sd	s0,144(sp)
    80006292:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006294:	ffffe097          	auipc	ra,0xffffe
    80006298:	6a6080e7          	jalr	1702(ra) # 8000493a <begin_op>
  argint(1, &major);
    8000629c:	f6c40593          	addi	a1,s0,-148
    800062a0:	4505                	li	a0,1
    800062a2:	ffffd097          	auipc	ra,0xffffd
    800062a6:	018080e7          	jalr	24(ra) # 800032ba <argint>
  argint(2, &minor);
    800062aa:	f6840593          	addi	a1,s0,-152
    800062ae:	4509                	li	a0,2
    800062b0:	ffffd097          	auipc	ra,0xffffd
    800062b4:	00a080e7          	jalr	10(ra) # 800032ba <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800062b8:	08000613          	li	a2,128
    800062bc:	f7040593          	addi	a1,s0,-144
    800062c0:	4501                	li	a0,0
    800062c2:	ffffd097          	auipc	ra,0xffffd
    800062c6:	038080e7          	jalr	56(ra) # 800032fa <argstr>
    800062ca:	02054b63          	bltz	a0,80006300 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800062ce:	f6841683          	lh	a3,-152(s0)
    800062d2:	f6c41603          	lh	a2,-148(s0)
    800062d6:	458d                	li	a1,3
    800062d8:	f7040513          	addi	a0,s0,-144
    800062dc:	fffff097          	auipc	ra,0xfffff
    800062e0:	756080e7          	jalr	1878(ra) # 80005a32 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800062e4:	cd11                	beqz	a0,80006300 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800062e6:	ffffe097          	auipc	ra,0xffffe
    800062ea:	eec080e7          	jalr	-276(ra) # 800041d2 <iunlockput>
  end_op();
    800062ee:	ffffe097          	auipc	ra,0xffffe
    800062f2:	6c6080e7          	jalr	1734(ra) # 800049b4 <end_op>
  return 0;
    800062f6:	4501                	li	a0,0
}
    800062f8:	60ea                	ld	ra,152(sp)
    800062fa:	644a                	ld	s0,144(sp)
    800062fc:	610d                	addi	sp,sp,160
    800062fe:	8082                	ret
    end_op();
    80006300:	ffffe097          	auipc	ra,0xffffe
    80006304:	6b4080e7          	jalr	1716(ra) # 800049b4 <end_op>
    return -1;
    80006308:	557d                	li	a0,-1
    8000630a:	b7fd                	j	800062f8 <sys_mknod+0x6c>

000000008000630c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000630c:	7135                	addi	sp,sp,-160
    8000630e:	ed06                	sd	ra,152(sp)
    80006310:	e922                	sd	s0,144(sp)
    80006312:	e14a                	sd	s2,128(sp)
    80006314:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006316:	ffffc097          	auipc	ra,0xffffc
    8000631a:	caa080e7          	jalr	-854(ra) # 80001fc0 <myproc>
    8000631e:	892a                	mv	s2,a0
  
  begin_op();
    80006320:	ffffe097          	auipc	ra,0xffffe
    80006324:	61a080e7          	jalr	1562(ra) # 8000493a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006328:	08000613          	li	a2,128
    8000632c:	f6040593          	addi	a1,s0,-160
    80006330:	4501                	li	a0,0
    80006332:	ffffd097          	auipc	ra,0xffffd
    80006336:	fc8080e7          	jalr	-56(ra) # 800032fa <argstr>
    8000633a:	04054d63          	bltz	a0,80006394 <sys_chdir+0x88>
    8000633e:	e526                	sd	s1,136(sp)
    80006340:	f6040513          	addi	a0,s0,-160
    80006344:	ffffe097          	auipc	ra,0xffffe
    80006348:	3f6080e7          	jalr	1014(ra) # 8000473a <namei>
    8000634c:	84aa                	mv	s1,a0
    8000634e:	c131                	beqz	a0,80006392 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006350:	ffffe097          	auipc	ra,0xffffe
    80006354:	c1c080e7          	jalr	-996(ra) # 80003f6c <ilock>
  if(ip->type != T_DIR){
    80006358:	04449703          	lh	a4,68(s1)
    8000635c:	4785                	li	a5,1
    8000635e:	04f71163          	bne	a4,a5,800063a0 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006362:	8526                	mv	a0,s1
    80006364:	ffffe097          	auipc	ra,0xffffe
    80006368:	cce080e7          	jalr	-818(ra) # 80004032 <iunlock>
  iput(p->cwd);
    8000636c:	15093503          	ld	a0,336(s2)
    80006370:	ffffe097          	auipc	ra,0xffffe
    80006374:	dba080e7          	jalr	-582(ra) # 8000412a <iput>
  end_op();
    80006378:	ffffe097          	auipc	ra,0xffffe
    8000637c:	63c080e7          	jalr	1596(ra) # 800049b4 <end_op>
  p->cwd = ip;
    80006380:	14993823          	sd	s1,336(s2)
  return 0;
    80006384:	4501                	li	a0,0
    80006386:	64aa                	ld	s1,136(sp)
}
    80006388:	60ea                	ld	ra,152(sp)
    8000638a:	644a                	ld	s0,144(sp)
    8000638c:	690a                	ld	s2,128(sp)
    8000638e:	610d                	addi	sp,sp,160
    80006390:	8082                	ret
    80006392:	64aa                	ld	s1,136(sp)
    end_op();
    80006394:	ffffe097          	auipc	ra,0xffffe
    80006398:	620080e7          	jalr	1568(ra) # 800049b4 <end_op>
    return -1;
    8000639c:	557d                	li	a0,-1
    8000639e:	b7ed                	j	80006388 <sys_chdir+0x7c>
    iunlockput(ip);
    800063a0:	8526                	mv	a0,s1
    800063a2:	ffffe097          	auipc	ra,0xffffe
    800063a6:	e30080e7          	jalr	-464(ra) # 800041d2 <iunlockput>
    end_op();
    800063aa:	ffffe097          	auipc	ra,0xffffe
    800063ae:	60a080e7          	jalr	1546(ra) # 800049b4 <end_op>
    return -1;
    800063b2:	557d                	li	a0,-1
    800063b4:	64aa                	ld	s1,136(sp)
    800063b6:	bfc9                	j	80006388 <sys_chdir+0x7c>

00000000800063b8 <sys_exec>:

uint64
sys_exec(void)
{
    800063b8:	7121                	addi	sp,sp,-448
    800063ba:	ff06                	sd	ra,440(sp)
    800063bc:	fb22                	sd	s0,432(sp)
    800063be:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800063c0:	e4840593          	addi	a1,s0,-440
    800063c4:	4505                	li	a0,1
    800063c6:	ffffd097          	auipc	ra,0xffffd
    800063ca:	f14080e7          	jalr	-236(ra) # 800032da <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800063ce:	08000613          	li	a2,128
    800063d2:	f5040593          	addi	a1,s0,-176
    800063d6:	4501                	li	a0,0
    800063d8:	ffffd097          	auipc	ra,0xffffd
    800063dc:	f22080e7          	jalr	-222(ra) # 800032fa <argstr>
    800063e0:	87aa                	mv	a5,a0
    return -1;
    800063e2:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800063e4:	0e07c263          	bltz	a5,800064c8 <sys_exec+0x110>
    800063e8:	f726                	sd	s1,424(sp)
    800063ea:	f34a                	sd	s2,416(sp)
    800063ec:	ef4e                	sd	s3,408(sp)
    800063ee:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800063f0:	10000613          	li	a2,256
    800063f4:	4581                	li	a1,0
    800063f6:	e5040513          	addi	a0,s0,-432
    800063fa:	ffffb097          	auipc	ra,0xffffb
    800063fe:	a0c080e7          	jalr	-1524(ra) # 80000e06 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006402:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80006406:	89a6                	mv	s3,s1
    80006408:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000640a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000640e:	00391513          	slli	a0,s2,0x3
    80006412:	e4040593          	addi	a1,s0,-448
    80006416:	e4843783          	ld	a5,-440(s0)
    8000641a:	953e                	add	a0,a0,a5
    8000641c:	ffffd097          	auipc	ra,0xffffd
    80006420:	e00080e7          	jalr	-512(ra) # 8000321c <fetchaddr>
    80006424:	02054a63          	bltz	a0,80006458 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80006428:	e4043783          	ld	a5,-448(s0)
    8000642c:	c7b9                	beqz	a5,8000647a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000642e:	ffffa097          	auipc	ra,0xffffa
    80006432:	796080e7          	jalr	1942(ra) # 80000bc4 <kalloc>
    80006436:	85aa                	mv	a1,a0
    80006438:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000643c:	cd11                	beqz	a0,80006458 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000643e:	6605                	lui	a2,0x1
    80006440:	e4043503          	ld	a0,-448(s0)
    80006444:	ffffd097          	auipc	ra,0xffffd
    80006448:	e2a080e7          	jalr	-470(ra) # 8000326e <fetchstr>
    8000644c:	00054663          	bltz	a0,80006458 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80006450:	0905                	addi	s2,s2,1
    80006452:	09a1                	addi	s3,s3,8
    80006454:	fb491de3          	bne	s2,s4,8000640e <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006458:	f5040913          	addi	s2,s0,-176
    8000645c:	6088                	ld	a0,0(s1)
    8000645e:	c125                	beqz	a0,800064be <sys_exec+0x106>
    kfree(argv[i]);
    80006460:	ffffa097          	auipc	ra,0xffffa
    80006464:	5fc080e7          	jalr	1532(ra) # 80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006468:	04a1                	addi	s1,s1,8
    8000646a:	ff2499e3          	bne	s1,s2,8000645c <sys_exec+0xa4>
  return -1;
    8000646e:	557d                	li	a0,-1
    80006470:	74ba                	ld	s1,424(sp)
    80006472:	791a                	ld	s2,416(sp)
    80006474:	69fa                	ld	s3,408(sp)
    80006476:	6a5a                	ld	s4,400(sp)
    80006478:	a881                	j	800064c8 <sys_exec+0x110>
      argv[i] = 0;
    8000647a:	0009079b          	sext.w	a5,s2
    8000647e:	078e                	slli	a5,a5,0x3
    80006480:	fd078793          	addi	a5,a5,-48
    80006484:	97a2                	add	a5,a5,s0
    80006486:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    8000648a:	e5040593          	addi	a1,s0,-432
    8000648e:	f5040513          	addi	a0,s0,-176
    80006492:	fffff097          	auipc	ra,0xfffff
    80006496:	048080e7          	jalr	72(ra) # 800054da <exec>
    8000649a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000649c:	f5040993          	addi	s3,s0,-176
    800064a0:	6088                	ld	a0,0(s1)
    800064a2:	c901                	beqz	a0,800064b2 <sys_exec+0xfa>
    kfree(argv[i]);
    800064a4:	ffffa097          	auipc	ra,0xffffa
    800064a8:	5b8080e7          	jalr	1464(ra) # 80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800064ac:	04a1                	addi	s1,s1,8
    800064ae:	ff3499e3          	bne	s1,s3,800064a0 <sys_exec+0xe8>
  return ret;
    800064b2:	854a                	mv	a0,s2
    800064b4:	74ba                	ld	s1,424(sp)
    800064b6:	791a                	ld	s2,416(sp)
    800064b8:	69fa                	ld	s3,408(sp)
    800064ba:	6a5a                	ld	s4,400(sp)
    800064bc:	a031                	j	800064c8 <sys_exec+0x110>
  return -1;
    800064be:	557d                	li	a0,-1
    800064c0:	74ba                	ld	s1,424(sp)
    800064c2:	791a                	ld	s2,416(sp)
    800064c4:	69fa                	ld	s3,408(sp)
    800064c6:	6a5a                	ld	s4,400(sp)
}
    800064c8:	70fa                	ld	ra,440(sp)
    800064ca:	745a                	ld	s0,432(sp)
    800064cc:	6139                	addi	sp,sp,448
    800064ce:	8082                	ret

00000000800064d0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800064d0:	7139                	addi	sp,sp,-64
    800064d2:	fc06                	sd	ra,56(sp)
    800064d4:	f822                	sd	s0,48(sp)
    800064d6:	f426                	sd	s1,40(sp)
    800064d8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800064da:	ffffc097          	auipc	ra,0xffffc
    800064de:	ae6080e7          	jalr	-1306(ra) # 80001fc0 <myproc>
    800064e2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800064e4:	fd840593          	addi	a1,s0,-40
    800064e8:	4501                	li	a0,0
    800064ea:	ffffd097          	auipc	ra,0xffffd
    800064ee:	df0080e7          	jalr	-528(ra) # 800032da <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800064f2:	fc840593          	addi	a1,s0,-56
    800064f6:	fd040513          	addi	a0,s0,-48
    800064fa:	fffff097          	auipc	ra,0xfffff
    800064fe:	c78080e7          	jalr	-904(ra) # 80005172 <pipealloc>
    return -1;
    80006502:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006504:	0c054463          	bltz	a0,800065cc <sys_pipe+0xfc>
  fd0 = -1;
    80006508:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000650c:	fd043503          	ld	a0,-48(s0)
    80006510:	fffff097          	auipc	ra,0xfffff
    80006514:	4e0080e7          	jalr	1248(ra) # 800059f0 <fdalloc>
    80006518:	fca42223          	sw	a0,-60(s0)
    8000651c:	08054b63          	bltz	a0,800065b2 <sys_pipe+0xe2>
    80006520:	fc843503          	ld	a0,-56(s0)
    80006524:	fffff097          	auipc	ra,0xfffff
    80006528:	4cc080e7          	jalr	1228(ra) # 800059f0 <fdalloc>
    8000652c:	fca42023          	sw	a0,-64(s0)
    80006530:	06054863          	bltz	a0,800065a0 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006534:	4691                	li	a3,4
    80006536:	fc440613          	addi	a2,s0,-60
    8000653a:	fd843583          	ld	a1,-40(s0)
    8000653e:	68a8                	ld	a0,80(s1)
    80006540:	ffffb097          	auipc	ra,0xffffb
    80006544:	54e080e7          	jalr	1358(ra) # 80001a8e <copyout>
    80006548:	02054063          	bltz	a0,80006568 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000654c:	4691                	li	a3,4
    8000654e:	fc040613          	addi	a2,s0,-64
    80006552:	fd843583          	ld	a1,-40(s0)
    80006556:	0591                	addi	a1,a1,4
    80006558:	68a8                	ld	a0,80(s1)
    8000655a:	ffffb097          	auipc	ra,0xffffb
    8000655e:	534080e7          	jalr	1332(ra) # 80001a8e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006562:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006564:	06055463          	bgez	a0,800065cc <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006568:	fc442783          	lw	a5,-60(s0)
    8000656c:	07e9                	addi	a5,a5,26
    8000656e:	078e                	slli	a5,a5,0x3
    80006570:	97a6                	add	a5,a5,s1
    80006572:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006576:	fc042783          	lw	a5,-64(s0)
    8000657a:	07e9                	addi	a5,a5,26
    8000657c:	078e                	slli	a5,a5,0x3
    8000657e:	94be                	add	s1,s1,a5
    80006580:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006584:	fd043503          	ld	a0,-48(s0)
    80006588:	fffff097          	auipc	ra,0xfffff
    8000658c:	87c080e7          	jalr	-1924(ra) # 80004e04 <fileclose>
    fileclose(wf);
    80006590:	fc843503          	ld	a0,-56(s0)
    80006594:	fffff097          	auipc	ra,0xfffff
    80006598:	870080e7          	jalr	-1936(ra) # 80004e04 <fileclose>
    return -1;
    8000659c:	57fd                	li	a5,-1
    8000659e:	a03d                	j	800065cc <sys_pipe+0xfc>
    if(fd0 >= 0)
    800065a0:	fc442783          	lw	a5,-60(s0)
    800065a4:	0007c763          	bltz	a5,800065b2 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800065a8:	07e9                	addi	a5,a5,26
    800065aa:	078e                	slli	a5,a5,0x3
    800065ac:	97a6                	add	a5,a5,s1
    800065ae:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800065b2:	fd043503          	ld	a0,-48(s0)
    800065b6:	fffff097          	auipc	ra,0xfffff
    800065ba:	84e080e7          	jalr	-1970(ra) # 80004e04 <fileclose>
    fileclose(wf);
    800065be:	fc843503          	ld	a0,-56(s0)
    800065c2:	fffff097          	auipc	ra,0xfffff
    800065c6:	842080e7          	jalr	-1982(ra) # 80004e04 <fileclose>
    return -1;
    800065ca:	57fd                	li	a5,-1
}
    800065cc:	853e                	mv	a0,a5
    800065ce:	70e2                	ld	ra,56(sp)
    800065d0:	7442                	ld	s0,48(sp)
    800065d2:	74a2                	ld	s1,40(sp)
    800065d4:	6121                	addi	sp,sp,64
    800065d6:	8082                	ret
	...

00000000800065e0 <kernelvec>:
    800065e0:	7111                	addi	sp,sp,-256
    800065e2:	e006                	sd	ra,0(sp)
    800065e4:	e40a                	sd	sp,8(sp)
    800065e6:	e80e                	sd	gp,16(sp)
    800065e8:	ec12                	sd	tp,24(sp)
    800065ea:	f016                	sd	t0,32(sp)
    800065ec:	f41a                	sd	t1,40(sp)
    800065ee:	f81e                	sd	t2,48(sp)
    800065f0:	fc22                	sd	s0,56(sp)
    800065f2:	e0a6                	sd	s1,64(sp)
    800065f4:	e4aa                	sd	a0,72(sp)
    800065f6:	e8ae                	sd	a1,80(sp)
    800065f8:	ecb2                	sd	a2,88(sp)
    800065fa:	f0b6                	sd	a3,96(sp)
    800065fc:	f4ba                	sd	a4,104(sp)
    800065fe:	f8be                	sd	a5,112(sp)
    80006600:	fcc2                	sd	a6,120(sp)
    80006602:	e146                	sd	a7,128(sp)
    80006604:	e54a                	sd	s2,136(sp)
    80006606:	e94e                	sd	s3,144(sp)
    80006608:	ed52                	sd	s4,152(sp)
    8000660a:	f156                	sd	s5,160(sp)
    8000660c:	f55a                	sd	s6,168(sp)
    8000660e:	f95e                	sd	s7,176(sp)
    80006610:	fd62                	sd	s8,184(sp)
    80006612:	e1e6                	sd	s9,192(sp)
    80006614:	e5ea                	sd	s10,200(sp)
    80006616:	e9ee                	sd	s11,208(sp)
    80006618:	edf2                	sd	t3,216(sp)
    8000661a:	f1f6                	sd	t4,224(sp)
    8000661c:	f5fa                	sd	t5,232(sp)
    8000661e:	f9fe                	sd	t6,240(sp)
    80006620:	ac9fc0ef          	jal	800030e8 <kerneltrap>
    80006624:	6082                	ld	ra,0(sp)
    80006626:	6122                	ld	sp,8(sp)
    80006628:	61c2                	ld	gp,16(sp)
    8000662a:	7282                	ld	t0,32(sp)
    8000662c:	7322                	ld	t1,40(sp)
    8000662e:	73c2                	ld	t2,48(sp)
    80006630:	7462                	ld	s0,56(sp)
    80006632:	6486                	ld	s1,64(sp)
    80006634:	6526                	ld	a0,72(sp)
    80006636:	65c6                	ld	a1,80(sp)
    80006638:	6666                	ld	a2,88(sp)
    8000663a:	7686                	ld	a3,96(sp)
    8000663c:	7726                	ld	a4,104(sp)
    8000663e:	77c6                	ld	a5,112(sp)
    80006640:	7866                	ld	a6,120(sp)
    80006642:	688a                	ld	a7,128(sp)
    80006644:	692a                	ld	s2,136(sp)
    80006646:	69ca                	ld	s3,144(sp)
    80006648:	6a6a                	ld	s4,152(sp)
    8000664a:	7a8a                	ld	s5,160(sp)
    8000664c:	7b2a                	ld	s6,168(sp)
    8000664e:	7bca                	ld	s7,176(sp)
    80006650:	7c6a                	ld	s8,184(sp)
    80006652:	6c8e                	ld	s9,192(sp)
    80006654:	6d2e                	ld	s10,200(sp)
    80006656:	6dce                	ld	s11,208(sp)
    80006658:	6e6e                	ld	t3,216(sp)
    8000665a:	7e8e                	ld	t4,224(sp)
    8000665c:	7f2e                	ld	t5,232(sp)
    8000665e:	7fce                	ld	t6,240(sp)
    80006660:	6111                	addi	sp,sp,256
    80006662:	10200073          	sret
    80006666:	00000013          	nop
    8000666a:	00000013          	nop
    8000666e:	0001                	nop

0000000080006670 <timervec>:
    80006670:	34051573          	csrrw	a0,mscratch,a0
    80006674:	e10c                	sd	a1,0(a0)
    80006676:	e510                	sd	a2,8(a0)
    80006678:	e914                	sd	a3,16(a0)
    8000667a:	6d0c                	ld	a1,24(a0)
    8000667c:	7110                	ld	a2,32(a0)
    8000667e:	6194                	ld	a3,0(a1)
    80006680:	96b2                	add	a3,a3,a2
    80006682:	e194                	sd	a3,0(a1)
    80006684:	4589                	li	a1,2
    80006686:	14459073          	csrw	sip,a1
    8000668a:	6914                	ld	a3,16(a0)
    8000668c:	6510                	ld	a2,8(a0)
    8000668e:	610c                	ld	a1,0(a0)
    80006690:	34051573          	csrrw	a0,mscratch,a0
    80006694:	30200073          	mret
	...

000000008000669a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000669a:	1141                	addi	sp,sp,-16
    8000669c:	e422                	sd	s0,8(sp)
    8000669e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800066a0:	0c0007b7          	lui	a5,0xc000
    800066a4:	4705                	li	a4,1
    800066a6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800066a8:	0c0007b7          	lui	a5,0xc000
    800066ac:	c3d8                	sw	a4,4(a5)
}
    800066ae:	6422                	ld	s0,8(sp)
    800066b0:	0141                	addi	sp,sp,16
    800066b2:	8082                	ret

00000000800066b4 <plicinithart>:

void
plicinithart(void)
{
    800066b4:	1141                	addi	sp,sp,-16
    800066b6:	e406                	sd	ra,8(sp)
    800066b8:	e022                	sd	s0,0(sp)
    800066ba:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800066bc:	ffffc097          	auipc	ra,0xffffc
    800066c0:	8d8080e7          	jalr	-1832(ra) # 80001f94 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800066c4:	0085171b          	slliw	a4,a0,0x8
    800066c8:	0c0027b7          	lui	a5,0xc002
    800066cc:	97ba                	add	a5,a5,a4
    800066ce:	40200713          	li	a4,1026
    800066d2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800066d6:	00d5151b          	slliw	a0,a0,0xd
    800066da:	0c2017b7          	lui	a5,0xc201
    800066de:	97aa                	add	a5,a5,a0
    800066e0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800066e4:	60a2                	ld	ra,8(sp)
    800066e6:	6402                	ld	s0,0(sp)
    800066e8:	0141                	addi	sp,sp,16
    800066ea:	8082                	ret

00000000800066ec <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800066ec:	1141                	addi	sp,sp,-16
    800066ee:	e406                	sd	ra,8(sp)
    800066f0:	e022                	sd	s0,0(sp)
    800066f2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800066f4:	ffffc097          	auipc	ra,0xffffc
    800066f8:	8a0080e7          	jalr	-1888(ra) # 80001f94 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800066fc:	00d5151b          	slliw	a0,a0,0xd
    80006700:	0c2017b7          	lui	a5,0xc201
    80006704:	97aa                	add	a5,a5,a0
  return irq;
}
    80006706:	43c8                	lw	a0,4(a5)
    80006708:	60a2                	ld	ra,8(sp)
    8000670a:	6402                	ld	s0,0(sp)
    8000670c:	0141                	addi	sp,sp,16
    8000670e:	8082                	ret

0000000080006710 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006710:	1101                	addi	sp,sp,-32
    80006712:	ec06                	sd	ra,24(sp)
    80006714:	e822                	sd	s0,16(sp)
    80006716:	e426                	sd	s1,8(sp)
    80006718:	1000                	addi	s0,sp,32
    8000671a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000671c:	ffffc097          	auipc	ra,0xffffc
    80006720:	878080e7          	jalr	-1928(ra) # 80001f94 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006724:	00d5151b          	slliw	a0,a0,0xd
    80006728:	0c2017b7          	lui	a5,0xc201
    8000672c:	97aa                	add	a5,a5,a0
    8000672e:	c3c4                	sw	s1,4(a5)
}
    80006730:	60e2                	ld	ra,24(sp)
    80006732:	6442                	ld	s0,16(sp)
    80006734:	64a2                	ld	s1,8(sp)
    80006736:	6105                	addi	sp,sp,32
    80006738:	8082                	ret

000000008000673a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000673a:	1141                	addi	sp,sp,-16
    8000673c:	e406                	sd	ra,8(sp)
    8000673e:	e022                	sd	s0,0(sp)
    80006740:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006742:	479d                	li	a5,7
    80006744:	04a7cc63          	blt	a5,a0,8000679c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006748:	0009e797          	auipc	a5,0x9e
    8000674c:	40878793          	addi	a5,a5,1032 # 800a4b50 <disk>
    80006750:	97aa                	add	a5,a5,a0
    80006752:	0187c783          	lbu	a5,24(a5)
    80006756:	ebb9                	bnez	a5,800067ac <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006758:	00451693          	slli	a3,a0,0x4
    8000675c:	0009e797          	auipc	a5,0x9e
    80006760:	3f478793          	addi	a5,a5,1012 # 800a4b50 <disk>
    80006764:	6398                	ld	a4,0(a5)
    80006766:	9736                	add	a4,a4,a3
    80006768:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000676c:	6398                	ld	a4,0(a5)
    8000676e:	9736                	add	a4,a4,a3
    80006770:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006774:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006778:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000677c:	97aa                	add	a5,a5,a0
    8000677e:	4705                	li	a4,1
    80006780:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006784:	0009e517          	auipc	a0,0x9e
    80006788:	3e450513          	addi	a0,a0,996 # 800a4b68 <disk+0x18>
    8000678c:	ffffc097          	auipc	ra,0xffffc
    80006790:	03a080e7          	jalr	58(ra) # 800027c6 <wakeup>
}
    80006794:	60a2                	ld	ra,8(sp)
    80006796:	6402                	ld	s0,0(sp)
    80006798:	0141                	addi	sp,sp,16
    8000679a:	8082                	ret
    panic("free_desc 1");
    8000679c:	00002517          	auipc	a0,0x2
    800067a0:	14c50513          	addi	a0,a0,332 # 800088e8 <__func__.1+0x8e0>
    800067a4:	ffffa097          	auipc	ra,0xffffa
    800067a8:	dbc080e7          	jalr	-580(ra) # 80000560 <panic>
    panic("free_desc 2");
    800067ac:	00002517          	auipc	a0,0x2
    800067b0:	14c50513          	addi	a0,a0,332 # 800088f8 <__func__.1+0x8f0>
    800067b4:	ffffa097          	auipc	ra,0xffffa
    800067b8:	dac080e7          	jalr	-596(ra) # 80000560 <panic>

00000000800067bc <virtio_disk_init>:
{
    800067bc:	1101                	addi	sp,sp,-32
    800067be:	ec06                	sd	ra,24(sp)
    800067c0:	e822                	sd	s0,16(sp)
    800067c2:	e426                	sd	s1,8(sp)
    800067c4:	e04a                	sd	s2,0(sp)
    800067c6:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800067c8:	00002597          	auipc	a1,0x2
    800067cc:	14058593          	addi	a1,a1,320 # 80008908 <__func__.1+0x900>
    800067d0:	0009e517          	auipc	a0,0x9e
    800067d4:	4a850513          	addi	a0,a0,1192 # 800a4c78 <disk+0x128>
    800067d8:	ffffa097          	auipc	ra,0xffffa
    800067dc:	4a2080e7          	jalr	1186(ra) # 80000c7a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800067e0:	100017b7          	lui	a5,0x10001
    800067e4:	4398                	lw	a4,0(a5)
    800067e6:	2701                	sext.w	a4,a4
    800067e8:	747277b7          	lui	a5,0x74727
    800067ec:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800067f0:	18f71c63          	bne	a4,a5,80006988 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800067f4:	100017b7          	lui	a5,0x10001
    800067f8:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800067fa:	439c                	lw	a5,0(a5)
    800067fc:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800067fe:	4709                	li	a4,2
    80006800:	18e79463          	bne	a5,a4,80006988 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006804:	100017b7          	lui	a5,0x10001
    80006808:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    8000680a:	439c                	lw	a5,0(a5)
    8000680c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000680e:	16e79d63          	bne	a5,a4,80006988 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006812:	100017b7          	lui	a5,0x10001
    80006816:	47d8                	lw	a4,12(a5)
    80006818:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000681a:	554d47b7          	lui	a5,0x554d4
    8000681e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006822:	16f71363          	bne	a4,a5,80006988 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006826:	100017b7          	lui	a5,0x10001
    8000682a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000682e:	4705                	li	a4,1
    80006830:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006832:	470d                	li	a4,3
    80006834:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006836:	10001737          	lui	a4,0x10001
    8000683a:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000683c:	c7ffe737          	lui	a4,0xc7ffe
    80006840:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47f59acf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006844:	8ef9                	and	a3,a3,a4
    80006846:	10001737          	lui	a4,0x10001
    8000684a:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000684c:	472d                	li	a4,11
    8000684e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006850:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006854:	439c                	lw	a5,0(a5)
    80006856:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000685a:	8ba1                	andi	a5,a5,8
    8000685c:	12078e63          	beqz	a5,80006998 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006860:	100017b7          	lui	a5,0x10001
    80006864:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006868:	100017b7          	lui	a5,0x10001
    8000686c:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006870:	439c                	lw	a5,0(a5)
    80006872:	2781                	sext.w	a5,a5
    80006874:	12079a63          	bnez	a5,800069a8 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006878:	100017b7          	lui	a5,0x10001
    8000687c:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006880:	439c                	lw	a5,0(a5)
    80006882:	2781                	sext.w	a5,a5
  if(max == 0)
    80006884:	12078a63          	beqz	a5,800069b8 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006888:	471d                	li	a4,7
    8000688a:	12f77f63          	bgeu	a4,a5,800069c8 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000688e:	ffffa097          	auipc	ra,0xffffa
    80006892:	336080e7          	jalr	822(ra) # 80000bc4 <kalloc>
    80006896:	0009e497          	auipc	s1,0x9e
    8000689a:	2ba48493          	addi	s1,s1,698 # 800a4b50 <disk>
    8000689e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800068a0:	ffffa097          	auipc	ra,0xffffa
    800068a4:	324080e7          	jalr	804(ra) # 80000bc4 <kalloc>
    800068a8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800068aa:	ffffa097          	auipc	ra,0xffffa
    800068ae:	31a080e7          	jalr	794(ra) # 80000bc4 <kalloc>
    800068b2:	87aa                	mv	a5,a0
    800068b4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800068b6:	6088                	ld	a0,0(s1)
    800068b8:	12050063          	beqz	a0,800069d8 <virtio_disk_init+0x21c>
    800068bc:	0009e717          	auipc	a4,0x9e
    800068c0:	29c73703          	ld	a4,668(a4) # 800a4b58 <disk+0x8>
    800068c4:	10070a63          	beqz	a4,800069d8 <virtio_disk_init+0x21c>
    800068c8:	10078863          	beqz	a5,800069d8 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    800068cc:	6605                	lui	a2,0x1
    800068ce:	4581                	li	a1,0
    800068d0:	ffffa097          	auipc	ra,0xffffa
    800068d4:	536080e7          	jalr	1334(ra) # 80000e06 <memset>
  memset(disk.avail, 0, PGSIZE);
    800068d8:	0009e497          	auipc	s1,0x9e
    800068dc:	27848493          	addi	s1,s1,632 # 800a4b50 <disk>
    800068e0:	6605                	lui	a2,0x1
    800068e2:	4581                	li	a1,0
    800068e4:	6488                	ld	a0,8(s1)
    800068e6:	ffffa097          	auipc	ra,0xffffa
    800068ea:	520080e7          	jalr	1312(ra) # 80000e06 <memset>
  memset(disk.used, 0, PGSIZE);
    800068ee:	6605                	lui	a2,0x1
    800068f0:	4581                	li	a1,0
    800068f2:	6888                	ld	a0,16(s1)
    800068f4:	ffffa097          	auipc	ra,0xffffa
    800068f8:	512080e7          	jalr	1298(ra) # 80000e06 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800068fc:	100017b7          	lui	a5,0x10001
    80006900:	4721                	li	a4,8
    80006902:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006904:	4098                	lw	a4,0(s1)
    80006906:	100017b7          	lui	a5,0x10001
    8000690a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000690e:	40d8                	lw	a4,4(s1)
    80006910:	100017b7          	lui	a5,0x10001
    80006914:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006918:	649c                	ld	a5,8(s1)
    8000691a:	0007869b          	sext.w	a3,a5
    8000691e:	10001737          	lui	a4,0x10001
    80006922:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006926:	9781                	srai	a5,a5,0x20
    80006928:	10001737          	lui	a4,0x10001
    8000692c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006930:	689c                	ld	a5,16(s1)
    80006932:	0007869b          	sext.w	a3,a5
    80006936:	10001737          	lui	a4,0x10001
    8000693a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000693e:	9781                	srai	a5,a5,0x20
    80006940:	10001737          	lui	a4,0x10001
    80006944:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006948:	10001737          	lui	a4,0x10001
    8000694c:	4785                	li	a5,1
    8000694e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006950:	00f48c23          	sb	a5,24(s1)
    80006954:	00f48ca3          	sb	a5,25(s1)
    80006958:	00f48d23          	sb	a5,26(s1)
    8000695c:	00f48da3          	sb	a5,27(s1)
    80006960:	00f48e23          	sb	a5,28(s1)
    80006964:	00f48ea3          	sb	a5,29(s1)
    80006968:	00f48f23          	sb	a5,30(s1)
    8000696c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006970:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006974:	100017b7          	lui	a5,0x10001
    80006978:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000697c:	60e2                	ld	ra,24(sp)
    8000697e:	6442                	ld	s0,16(sp)
    80006980:	64a2                	ld	s1,8(sp)
    80006982:	6902                	ld	s2,0(sp)
    80006984:	6105                	addi	sp,sp,32
    80006986:	8082                	ret
    panic("could not find virtio disk");
    80006988:	00002517          	auipc	a0,0x2
    8000698c:	f9050513          	addi	a0,a0,-112 # 80008918 <__func__.1+0x910>
    80006990:	ffffa097          	auipc	ra,0xffffa
    80006994:	bd0080e7          	jalr	-1072(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006998:	00002517          	auipc	a0,0x2
    8000699c:	fa050513          	addi	a0,a0,-96 # 80008938 <__func__.1+0x930>
    800069a0:	ffffa097          	auipc	ra,0xffffa
    800069a4:	bc0080e7          	jalr	-1088(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    800069a8:	00002517          	auipc	a0,0x2
    800069ac:	fb050513          	addi	a0,a0,-80 # 80008958 <__func__.1+0x950>
    800069b0:	ffffa097          	auipc	ra,0xffffa
    800069b4:	bb0080e7          	jalr	-1104(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    800069b8:	00002517          	auipc	a0,0x2
    800069bc:	fc050513          	addi	a0,a0,-64 # 80008978 <__func__.1+0x970>
    800069c0:	ffffa097          	auipc	ra,0xffffa
    800069c4:	ba0080e7          	jalr	-1120(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    800069c8:	00002517          	auipc	a0,0x2
    800069cc:	fd050513          	addi	a0,a0,-48 # 80008998 <__func__.1+0x990>
    800069d0:	ffffa097          	auipc	ra,0xffffa
    800069d4:	b90080e7          	jalr	-1136(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    800069d8:	00002517          	auipc	a0,0x2
    800069dc:	fe050513          	addi	a0,a0,-32 # 800089b8 <__func__.1+0x9b0>
    800069e0:	ffffa097          	auipc	ra,0xffffa
    800069e4:	b80080e7          	jalr	-1152(ra) # 80000560 <panic>

00000000800069e8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800069e8:	7159                	addi	sp,sp,-112
    800069ea:	f486                	sd	ra,104(sp)
    800069ec:	f0a2                	sd	s0,96(sp)
    800069ee:	eca6                	sd	s1,88(sp)
    800069f0:	e8ca                	sd	s2,80(sp)
    800069f2:	e4ce                	sd	s3,72(sp)
    800069f4:	e0d2                	sd	s4,64(sp)
    800069f6:	fc56                	sd	s5,56(sp)
    800069f8:	f85a                	sd	s6,48(sp)
    800069fa:	f45e                	sd	s7,40(sp)
    800069fc:	f062                	sd	s8,32(sp)
    800069fe:	ec66                	sd	s9,24(sp)
    80006a00:	1880                	addi	s0,sp,112
    80006a02:	8a2a                	mv	s4,a0
    80006a04:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006a06:	00c52c83          	lw	s9,12(a0)
    80006a0a:	001c9c9b          	slliw	s9,s9,0x1
    80006a0e:	1c82                	slli	s9,s9,0x20
    80006a10:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006a14:	0009e517          	auipc	a0,0x9e
    80006a18:	26450513          	addi	a0,a0,612 # 800a4c78 <disk+0x128>
    80006a1c:	ffffa097          	auipc	ra,0xffffa
    80006a20:	2ee080e7          	jalr	750(ra) # 80000d0a <acquire>
  for(int i = 0; i < 3; i++){
    80006a24:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006a26:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006a28:	0009eb17          	auipc	s6,0x9e
    80006a2c:	128b0b13          	addi	s6,s6,296 # 800a4b50 <disk>
  for(int i = 0; i < 3; i++){
    80006a30:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006a32:	0009ec17          	auipc	s8,0x9e
    80006a36:	246c0c13          	addi	s8,s8,582 # 800a4c78 <disk+0x128>
    80006a3a:	a0ad                	j	80006aa4 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80006a3c:	00fb0733          	add	a4,s6,a5
    80006a40:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006a44:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006a46:	0207c563          	bltz	a5,80006a70 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006a4a:	2905                	addiw	s2,s2,1
    80006a4c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006a4e:	05590f63          	beq	s2,s5,80006aac <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006a52:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006a54:	0009e717          	auipc	a4,0x9e
    80006a58:	0fc70713          	addi	a4,a4,252 # 800a4b50 <disk>
    80006a5c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006a5e:	01874683          	lbu	a3,24(a4)
    80006a62:	fee9                	bnez	a3,80006a3c <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006a64:	2785                	addiw	a5,a5,1
    80006a66:	0705                	addi	a4,a4,1
    80006a68:	fe979be3          	bne	a5,s1,80006a5e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006a6c:	57fd                	li	a5,-1
    80006a6e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006a70:	03205163          	blez	s2,80006a92 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006a74:	f9042503          	lw	a0,-112(s0)
    80006a78:	00000097          	auipc	ra,0x0
    80006a7c:	cc2080e7          	jalr	-830(ra) # 8000673a <free_desc>
      for(int j = 0; j < i; j++)
    80006a80:	4785                	li	a5,1
    80006a82:	0127d863          	bge	a5,s2,80006a92 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006a86:	f9442503          	lw	a0,-108(s0)
    80006a8a:	00000097          	auipc	ra,0x0
    80006a8e:	cb0080e7          	jalr	-848(ra) # 8000673a <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006a92:	85e2                	mv	a1,s8
    80006a94:	0009e517          	auipc	a0,0x9e
    80006a98:	0d450513          	addi	a0,a0,212 # 800a4b68 <disk+0x18>
    80006a9c:	ffffc097          	auipc	ra,0xffffc
    80006aa0:	cc6080e7          	jalr	-826(ra) # 80002762 <sleep>
  for(int i = 0; i < 3; i++){
    80006aa4:	f9040613          	addi	a2,s0,-112
    80006aa8:	894e                	mv	s2,s3
    80006aaa:	b765                	j	80006a52 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006aac:	f9042503          	lw	a0,-112(s0)
    80006ab0:	00451693          	slli	a3,a0,0x4

  if(write)
    80006ab4:	0009e797          	auipc	a5,0x9e
    80006ab8:	09c78793          	addi	a5,a5,156 # 800a4b50 <disk>
    80006abc:	00a50713          	addi	a4,a0,10
    80006ac0:	0712                	slli	a4,a4,0x4
    80006ac2:	973e                	add	a4,a4,a5
    80006ac4:	01703633          	snez	a2,s7
    80006ac8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006aca:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006ace:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006ad2:	6398                	ld	a4,0(a5)
    80006ad4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006ad6:	0a868613          	addi	a2,a3,168
    80006ada:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006adc:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006ade:	6390                	ld	a2,0(a5)
    80006ae0:	00d605b3          	add	a1,a2,a3
    80006ae4:	4741                	li	a4,16
    80006ae6:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006ae8:	4805                	li	a6,1
    80006aea:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006aee:	f9442703          	lw	a4,-108(s0)
    80006af2:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006af6:	0712                	slli	a4,a4,0x4
    80006af8:	963a                	add	a2,a2,a4
    80006afa:	058a0593          	addi	a1,s4,88
    80006afe:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006b00:	0007b883          	ld	a7,0(a5)
    80006b04:	9746                	add	a4,a4,a7
    80006b06:	40000613          	li	a2,1024
    80006b0a:	c710                	sw	a2,8(a4)
  if(write)
    80006b0c:	001bb613          	seqz	a2,s7
    80006b10:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006b14:	00166613          	ori	a2,a2,1
    80006b18:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006b1c:	f9842583          	lw	a1,-104(s0)
    80006b20:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006b24:	00250613          	addi	a2,a0,2
    80006b28:	0612                	slli	a2,a2,0x4
    80006b2a:	963e                	add	a2,a2,a5
    80006b2c:	577d                	li	a4,-1
    80006b2e:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006b32:	0592                	slli	a1,a1,0x4
    80006b34:	98ae                	add	a7,a7,a1
    80006b36:	03068713          	addi	a4,a3,48
    80006b3a:	973e                	add	a4,a4,a5
    80006b3c:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006b40:	6398                	ld	a4,0(a5)
    80006b42:	972e                	add	a4,a4,a1
    80006b44:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006b48:	4689                	li	a3,2
    80006b4a:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006b4e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006b52:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006b56:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006b5a:	6794                	ld	a3,8(a5)
    80006b5c:	0026d703          	lhu	a4,2(a3)
    80006b60:	8b1d                	andi	a4,a4,7
    80006b62:	0706                	slli	a4,a4,0x1
    80006b64:	96ba                	add	a3,a3,a4
    80006b66:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006b6a:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006b6e:	6798                	ld	a4,8(a5)
    80006b70:	00275783          	lhu	a5,2(a4)
    80006b74:	2785                	addiw	a5,a5,1
    80006b76:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006b7a:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006b7e:	100017b7          	lui	a5,0x10001
    80006b82:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006b86:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006b8a:	0009e917          	auipc	s2,0x9e
    80006b8e:	0ee90913          	addi	s2,s2,238 # 800a4c78 <disk+0x128>
  while(b->disk == 1) {
    80006b92:	4485                	li	s1,1
    80006b94:	01079c63          	bne	a5,a6,80006bac <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006b98:	85ca                	mv	a1,s2
    80006b9a:	8552                	mv	a0,s4
    80006b9c:	ffffc097          	auipc	ra,0xffffc
    80006ba0:	bc6080e7          	jalr	-1082(ra) # 80002762 <sleep>
  while(b->disk == 1) {
    80006ba4:	004a2783          	lw	a5,4(s4)
    80006ba8:	fe9788e3          	beq	a5,s1,80006b98 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006bac:	f9042903          	lw	s2,-112(s0)
    80006bb0:	00290713          	addi	a4,s2,2
    80006bb4:	0712                	slli	a4,a4,0x4
    80006bb6:	0009e797          	auipc	a5,0x9e
    80006bba:	f9a78793          	addi	a5,a5,-102 # 800a4b50 <disk>
    80006bbe:	97ba                	add	a5,a5,a4
    80006bc0:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006bc4:	0009e997          	auipc	s3,0x9e
    80006bc8:	f8c98993          	addi	s3,s3,-116 # 800a4b50 <disk>
    80006bcc:	00491713          	slli	a4,s2,0x4
    80006bd0:	0009b783          	ld	a5,0(s3)
    80006bd4:	97ba                	add	a5,a5,a4
    80006bd6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006bda:	854a                	mv	a0,s2
    80006bdc:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006be0:	00000097          	auipc	ra,0x0
    80006be4:	b5a080e7          	jalr	-1190(ra) # 8000673a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006be8:	8885                	andi	s1,s1,1
    80006bea:	f0ed                	bnez	s1,80006bcc <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006bec:	0009e517          	auipc	a0,0x9e
    80006bf0:	08c50513          	addi	a0,a0,140 # 800a4c78 <disk+0x128>
    80006bf4:	ffffa097          	auipc	ra,0xffffa
    80006bf8:	1ca080e7          	jalr	458(ra) # 80000dbe <release>
}
    80006bfc:	70a6                	ld	ra,104(sp)
    80006bfe:	7406                	ld	s0,96(sp)
    80006c00:	64e6                	ld	s1,88(sp)
    80006c02:	6946                	ld	s2,80(sp)
    80006c04:	69a6                	ld	s3,72(sp)
    80006c06:	6a06                	ld	s4,64(sp)
    80006c08:	7ae2                	ld	s5,56(sp)
    80006c0a:	7b42                	ld	s6,48(sp)
    80006c0c:	7ba2                	ld	s7,40(sp)
    80006c0e:	7c02                	ld	s8,32(sp)
    80006c10:	6ce2                	ld	s9,24(sp)
    80006c12:	6165                	addi	sp,sp,112
    80006c14:	8082                	ret

0000000080006c16 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006c16:	1101                	addi	sp,sp,-32
    80006c18:	ec06                	sd	ra,24(sp)
    80006c1a:	e822                	sd	s0,16(sp)
    80006c1c:	e426                	sd	s1,8(sp)
    80006c1e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006c20:	0009e497          	auipc	s1,0x9e
    80006c24:	f3048493          	addi	s1,s1,-208 # 800a4b50 <disk>
    80006c28:	0009e517          	auipc	a0,0x9e
    80006c2c:	05050513          	addi	a0,a0,80 # 800a4c78 <disk+0x128>
    80006c30:	ffffa097          	auipc	ra,0xffffa
    80006c34:	0da080e7          	jalr	218(ra) # 80000d0a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006c38:	100017b7          	lui	a5,0x10001
    80006c3c:	53b8                	lw	a4,96(a5)
    80006c3e:	8b0d                	andi	a4,a4,3
    80006c40:	100017b7          	lui	a5,0x10001
    80006c44:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006c46:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006c4a:	689c                	ld	a5,16(s1)
    80006c4c:	0204d703          	lhu	a4,32(s1)
    80006c50:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006c54:	04f70863          	beq	a4,a5,80006ca4 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006c58:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006c5c:	6898                	ld	a4,16(s1)
    80006c5e:	0204d783          	lhu	a5,32(s1)
    80006c62:	8b9d                	andi	a5,a5,7
    80006c64:	078e                	slli	a5,a5,0x3
    80006c66:	97ba                	add	a5,a5,a4
    80006c68:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006c6a:	00278713          	addi	a4,a5,2
    80006c6e:	0712                	slli	a4,a4,0x4
    80006c70:	9726                	add	a4,a4,s1
    80006c72:	01074703          	lbu	a4,16(a4)
    80006c76:	e721                	bnez	a4,80006cbe <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006c78:	0789                	addi	a5,a5,2
    80006c7a:	0792                	slli	a5,a5,0x4
    80006c7c:	97a6                	add	a5,a5,s1
    80006c7e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006c80:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006c84:	ffffc097          	auipc	ra,0xffffc
    80006c88:	b42080e7          	jalr	-1214(ra) # 800027c6 <wakeup>

    disk.used_idx += 1;
    80006c8c:	0204d783          	lhu	a5,32(s1)
    80006c90:	2785                	addiw	a5,a5,1
    80006c92:	17c2                	slli	a5,a5,0x30
    80006c94:	93c1                	srli	a5,a5,0x30
    80006c96:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006c9a:	6898                	ld	a4,16(s1)
    80006c9c:	00275703          	lhu	a4,2(a4)
    80006ca0:	faf71ce3          	bne	a4,a5,80006c58 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006ca4:	0009e517          	auipc	a0,0x9e
    80006ca8:	fd450513          	addi	a0,a0,-44 # 800a4c78 <disk+0x128>
    80006cac:	ffffa097          	auipc	ra,0xffffa
    80006cb0:	112080e7          	jalr	274(ra) # 80000dbe <release>
}
    80006cb4:	60e2                	ld	ra,24(sp)
    80006cb6:	6442                	ld	s0,16(sp)
    80006cb8:	64a2                	ld	s1,8(sp)
    80006cba:	6105                	addi	sp,sp,32
    80006cbc:	8082                	ret
      panic("virtio_disk_intr status");
    80006cbe:	00002517          	auipc	a0,0x2
    80006cc2:	d1250513          	addi	a0,a0,-750 # 800089d0 <__func__.1+0x9c8>
    80006cc6:	ffffa097          	auipc	ra,0xffffa
    80006cca:	89a080e7          	jalr	-1894(ra) # 80000560 <panic>
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
