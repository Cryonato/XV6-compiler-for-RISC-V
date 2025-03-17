
user/_schedset:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    if (argc != 2)
   8:	4789                	li	a5,2
   a:	00f50f63          	beq	a0,a5,28 <main+0x28>
    {
        printf("Usage: schedset [SCHED ID]\n");
   e:	00001517          	auipc	a0,0x1
  12:	81250513          	addi	a0,a0,-2030 # 820 <malloc+0x10e>
  16:	00000097          	auipc	ra,0x0
  1a:	644080e7          	jalr	1604(ra) # 65a <printf>
        exit(1);
  1e:	4505                	li	a0,1
  20:	00000097          	auipc	ra,0x0
  24:	2aa080e7          	jalr	682(ra) # 2ca <exit>
    }
    int schedid = (*argv[1]) - '0';
  28:	659c                	ld	a5,8(a1)
  2a:	0007c503          	lbu	a0,0(a5)
    schedset(schedid);
  2e:	fd05051b          	addiw	a0,a0,-48
  32:	00000097          	auipc	ra,0x0
  36:	348080e7          	jalr	840(ra) # 37a <schedset>
    exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	28e080e7          	jalr	654(ra) # 2ca <exit>

0000000000000044 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  44:	1141                	addi	sp,sp,-16
  46:	e406                	sd	ra,8(sp)
  48:	e022                	sd	s0,0(sp)
  4a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  4c:	00000097          	auipc	ra,0x0
  50:	fb4080e7          	jalr	-76(ra) # 0 <main>
  exit(0);
  54:	4501                	li	a0,0
  56:	00000097          	auipc	ra,0x0
  5a:	274080e7          	jalr	628(ra) # 2ca <exit>

000000000000005e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  5e:	1141                	addi	sp,sp,-16
  60:	e422                	sd	s0,8(sp)
  62:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  64:	87aa                	mv	a5,a0
  66:	0585                	addi	a1,a1,1
  68:	0785                	addi	a5,a5,1
  6a:	fff5c703          	lbu	a4,-1(a1)
  6e:	fee78fa3          	sb	a4,-1(a5)
  72:	fb75                	bnez	a4,66 <strcpy+0x8>
    ;
  return os;
}
  74:	6422                	ld	s0,8(sp)
  76:	0141                	addi	sp,sp,16
  78:	8082                	ret

000000000000007a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  80:	00054783          	lbu	a5,0(a0)
  84:	cb91                	beqz	a5,98 <strcmp+0x1e>
  86:	0005c703          	lbu	a4,0(a1)
  8a:	00f71763          	bne	a4,a5,98 <strcmp+0x1e>
    p++, q++;
  8e:	0505                	addi	a0,a0,1
  90:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  92:	00054783          	lbu	a5,0(a0)
  96:	fbe5                	bnez	a5,86 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  98:	0005c503          	lbu	a0,0(a1)
}
  9c:	40a7853b          	subw	a0,a5,a0
  a0:	6422                	ld	s0,8(sp)
  a2:	0141                	addi	sp,sp,16
  a4:	8082                	ret

00000000000000a6 <strlen>:

uint
strlen(const char *s)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e422                	sd	s0,8(sp)
  aa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ac:	00054783          	lbu	a5,0(a0)
  b0:	cf91                	beqz	a5,cc <strlen+0x26>
  b2:	0505                	addi	a0,a0,1
  b4:	87aa                	mv	a5,a0
  b6:	86be                	mv	a3,a5
  b8:	0785                	addi	a5,a5,1
  ba:	fff7c703          	lbu	a4,-1(a5)
  be:	ff65                	bnez	a4,b6 <strlen+0x10>
  c0:	40a6853b          	subw	a0,a3,a0
  c4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret
  for(n = 0; s[n]; n++)
  cc:	4501                	li	a0,0
  ce:	bfe5                	j	c6 <strlen+0x20>

00000000000000d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d6:	ca19                	beqz	a2,ec <memset+0x1c>
  d8:	87aa                	mv	a5,a0
  da:	1602                	slli	a2,a2,0x20
  dc:	9201                	srli	a2,a2,0x20
  de:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e6:	0785                	addi	a5,a5,1
  e8:	fee79de3          	bne	a5,a4,e2 <memset+0x12>
  }
  return dst;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <strchr>:

char*
strchr(const char *s, char c)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e422                	sd	s0,8(sp)
  f6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cb99                	beqz	a5,112 <strchr+0x20>
    if(*s == c)
  fe:	00f58763          	beq	a1,a5,10c <strchr+0x1a>
  for(; *s; s++)
 102:	0505                	addi	a0,a0,1
 104:	00054783          	lbu	a5,0(a0)
 108:	fbfd                	bnez	a5,fe <strchr+0xc>
      return (char*)s;
  return 0;
 10a:	4501                	li	a0,0
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret
  return 0;
 112:	4501                	li	a0,0
 114:	bfe5                	j	10c <strchr+0x1a>

0000000000000116 <gets>:

char*
gets(char *buf, int max)
{
 116:	711d                	addi	sp,sp,-96
 118:	ec86                	sd	ra,88(sp)
 11a:	e8a2                	sd	s0,80(sp)
 11c:	e4a6                	sd	s1,72(sp)
 11e:	e0ca                	sd	s2,64(sp)
 120:	fc4e                	sd	s3,56(sp)
 122:	f852                	sd	s4,48(sp)
 124:	f456                	sd	s5,40(sp)
 126:	f05a                	sd	s6,32(sp)
 128:	ec5e                	sd	s7,24(sp)
 12a:	1080                	addi	s0,sp,96
 12c:	8baa                	mv	s7,a0
 12e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 130:	892a                	mv	s2,a0
 132:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 134:	4aa9                	li	s5,10
 136:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 138:	89a6                	mv	s3,s1
 13a:	2485                	addiw	s1,s1,1
 13c:	0344d863          	bge	s1,s4,16c <gets+0x56>
    cc = read(0, &c, 1);
 140:	4605                	li	a2,1
 142:	faf40593          	addi	a1,s0,-81
 146:	4501                	li	a0,0
 148:	00000097          	auipc	ra,0x0
 14c:	19a080e7          	jalr	410(ra) # 2e2 <read>
    if(cc < 1)
 150:	00a05e63          	blez	a0,16c <gets+0x56>
    buf[i++] = c;
 154:	faf44783          	lbu	a5,-81(s0)
 158:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15c:	01578763          	beq	a5,s5,16a <gets+0x54>
 160:	0905                	addi	s2,s2,1
 162:	fd679be3          	bne	a5,s6,138 <gets+0x22>
    buf[i++] = c;
 166:	89a6                	mv	s3,s1
 168:	a011                	j	16c <gets+0x56>
 16a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 16c:	99de                	add	s3,s3,s7
 16e:	00098023          	sb	zero,0(s3)
  return buf;
}
 172:	855e                	mv	a0,s7
 174:	60e6                	ld	ra,88(sp)
 176:	6446                	ld	s0,80(sp)
 178:	64a6                	ld	s1,72(sp)
 17a:	6906                	ld	s2,64(sp)
 17c:	79e2                	ld	s3,56(sp)
 17e:	7a42                	ld	s4,48(sp)
 180:	7aa2                	ld	s5,40(sp)
 182:	7b02                	ld	s6,32(sp)
 184:	6be2                	ld	s7,24(sp)
 186:	6125                	addi	sp,sp,96
 188:	8082                	ret

000000000000018a <stat>:

int
stat(const char *n, struct stat *st)
{
 18a:	1101                	addi	sp,sp,-32
 18c:	ec06                	sd	ra,24(sp)
 18e:	e822                	sd	s0,16(sp)
 190:	e04a                	sd	s2,0(sp)
 192:	1000                	addi	s0,sp,32
 194:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 196:	4581                	li	a1,0
 198:	00000097          	auipc	ra,0x0
 19c:	172080e7          	jalr	370(ra) # 30a <open>
  if(fd < 0)
 1a0:	02054663          	bltz	a0,1cc <stat+0x42>
 1a4:	e426                	sd	s1,8(sp)
 1a6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a8:	85ca                	mv	a1,s2
 1aa:	00000097          	auipc	ra,0x0
 1ae:	178080e7          	jalr	376(ra) # 322 <fstat>
 1b2:	892a                	mv	s2,a0
  close(fd);
 1b4:	8526                	mv	a0,s1
 1b6:	00000097          	auipc	ra,0x0
 1ba:	13c080e7          	jalr	316(ra) # 2f2 <close>
  return r;
 1be:	64a2                	ld	s1,8(sp)
}
 1c0:	854a                	mv	a0,s2
 1c2:	60e2                	ld	ra,24(sp)
 1c4:	6442                	ld	s0,16(sp)
 1c6:	6902                	ld	s2,0(sp)
 1c8:	6105                	addi	sp,sp,32
 1ca:	8082                	ret
    return -1;
 1cc:	597d                	li	s2,-1
 1ce:	bfcd                	j	1c0 <stat+0x36>

00000000000001d0 <atoi>:

int
atoi(const char *s)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e422                	sd	s0,8(sp)
 1d4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d6:	00054683          	lbu	a3,0(a0)
 1da:	fd06879b          	addiw	a5,a3,-48
 1de:	0ff7f793          	zext.b	a5,a5
 1e2:	4625                	li	a2,9
 1e4:	02f66863          	bltu	a2,a5,214 <atoi+0x44>
 1e8:	872a                	mv	a4,a0
  n = 0;
 1ea:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1ec:	0705                	addi	a4,a4,1
 1ee:	0025179b          	slliw	a5,a0,0x2
 1f2:	9fa9                	addw	a5,a5,a0
 1f4:	0017979b          	slliw	a5,a5,0x1
 1f8:	9fb5                	addw	a5,a5,a3
 1fa:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1fe:	00074683          	lbu	a3,0(a4)
 202:	fd06879b          	addiw	a5,a3,-48
 206:	0ff7f793          	zext.b	a5,a5
 20a:	fef671e3          	bgeu	a2,a5,1ec <atoi+0x1c>
  return n;
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	addi	sp,sp,16
 212:	8082                	ret
  n = 0;
 214:	4501                	li	a0,0
 216:	bfe5                	j	20e <atoi+0x3e>

0000000000000218 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e422                	sd	s0,8(sp)
 21c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 21e:	02b57463          	bgeu	a0,a1,246 <memmove+0x2e>
    while(n-- > 0)
 222:	00c05f63          	blez	a2,240 <memmove+0x28>
 226:	1602                	slli	a2,a2,0x20
 228:	9201                	srli	a2,a2,0x20
 22a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 22e:	872a                	mv	a4,a0
      *dst++ = *src++;
 230:	0585                	addi	a1,a1,1
 232:	0705                	addi	a4,a4,1
 234:	fff5c683          	lbu	a3,-1(a1)
 238:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 23c:	fef71ae3          	bne	a4,a5,230 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 240:	6422                	ld	s0,8(sp)
 242:	0141                	addi	sp,sp,16
 244:	8082                	ret
    dst += n;
 246:	00c50733          	add	a4,a0,a2
    src += n;
 24a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 24c:	fec05ae3          	blez	a2,240 <memmove+0x28>
 250:	fff6079b          	addiw	a5,a2,-1
 254:	1782                	slli	a5,a5,0x20
 256:	9381                	srli	a5,a5,0x20
 258:	fff7c793          	not	a5,a5
 25c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 25e:	15fd                	addi	a1,a1,-1
 260:	177d                	addi	a4,a4,-1
 262:	0005c683          	lbu	a3,0(a1)
 266:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 26a:	fee79ae3          	bne	a5,a4,25e <memmove+0x46>
 26e:	bfc9                	j	240 <memmove+0x28>

0000000000000270 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 270:	1141                	addi	sp,sp,-16
 272:	e422                	sd	s0,8(sp)
 274:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 276:	ca05                	beqz	a2,2a6 <memcmp+0x36>
 278:	fff6069b          	addiw	a3,a2,-1
 27c:	1682                	slli	a3,a3,0x20
 27e:	9281                	srli	a3,a3,0x20
 280:	0685                	addi	a3,a3,1
 282:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 284:	00054783          	lbu	a5,0(a0)
 288:	0005c703          	lbu	a4,0(a1)
 28c:	00e79863          	bne	a5,a4,29c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 290:	0505                	addi	a0,a0,1
    p2++;
 292:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 294:	fed518e3          	bne	a0,a3,284 <memcmp+0x14>
  }
  return 0;
 298:	4501                	li	a0,0
 29a:	a019                	j	2a0 <memcmp+0x30>
      return *p1 - *p2;
 29c:	40e7853b          	subw	a0,a5,a4
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret
  return 0;
 2a6:	4501                	li	a0,0
 2a8:	bfe5                	j	2a0 <memcmp+0x30>

00000000000002aa <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e406                	sd	ra,8(sp)
 2ae:	e022                	sd	s0,0(sp)
 2b0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2b2:	00000097          	auipc	ra,0x0
 2b6:	f66080e7          	jalr	-154(ra) # 218 <memmove>
}
 2ba:	60a2                	ld	ra,8(sp)
 2bc:	6402                	ld	s0,0(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret

00000000000002c2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2c2:	4885                	li	a7,1
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ca:	4889                	li	a7,2
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2d2:	488d                	li	a7,3
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2da:	4891                	li	a7,4
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <read>:
.global read
read:
 li a7, SYS_read
 2e2:	4895                	li	a7,5
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <write>:
.global write
write:
 li a7, SYS_write
 2ea:	48c1                	li	a7,16
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <close>:
.global close
close:
 li a7, SYS_close
 2f2:	48d5                	li	a7,21
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <kill>:
.global kill
kill:
 li a7, SYS_kill
 2fa:	4899                	li	a7,6
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <exec>:
.global exec
exec:
 li a7, SYS_exec
 302:	489d                	li	a7,7
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <open>:
.global open
open:
 li a7, SYS_open
 30a:	48bd                	li	a7,15
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 312:	48c5                	li	a7,17
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 31a:	48c9                	li	a7,18
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 322:	48a1                	li	a7,8
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <link>:
.global link
link:
 li a7, SYS_link
 32a:	48cd                	li	a7,19
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 332:	48d1                	li	a7,20
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 33a:	48a5                	li	a7,9
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <dup>:
.global dup
dup:
 li a7, SYS_dup
 342:	48a9                	li	a7,10
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 34a:	48ad                	li	a7,11
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 352:	48b1                	li	a7,12
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 35a:	48b5                	li	a7,13
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 362:	48b9                	li	a7,14
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <ps>:
.global ps
ps:
 li a7, SYS_ps
 36a:	48d9                	li	a7,22
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 372:	48dd                	li	a7,23
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 37a:	48e1                	li	a7,24
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 382:	48e9                	li	a7,26
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 38a:	48e5                	li	a7,25
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 392:	1101                	addi	sp,sp,-32
 394:	ec06                	sd	ra,24(sp)
 396:	e822                	sd	s0,16(sp)
 398:	1000                	addi	s0,sp,32
 39a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 39e:	4605                	li	a2,1
 3a0:	fef40593          	addi	a1,s0,-17
 3a4:	00000097          	auipc	ra,0x0
 3a8:	f46080e7          	jalr	-186(ra) # 2ea <write>
}
 3ac:	60e2                	ld	ra,24(sp)
 3ae:	6442                	ld	s0,16(sp)
 3b0:	6105                	addi	sp,sp,32
 3b2:	8082                	ret

00000000000003b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b4:	7139                	addi	sp,sp,-64
 3b6:	fc06                	sd	ra,56(sp)
 3b8:	f822                	sd	s0,48(sp)
 3ba:	f426                	sd	s1,40(sp)
 3bc:	0080                	addi	s0,sp,64
 3be:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3c0:	c299                	beqz	a3,3c6 <printint+0x12>
 3c2:	0805cb63          	bltz	a1,458 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3c6:	2581                	sext.w	a1,a1
  neg = 0;
 3c8:	4881                	li	a7,0
 3ca:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3ce:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3d0:	2601                	sext.w	a2,a2
 3d2:	00000517          	auipc	a0,0x0
 3d6:	4ce50513          	addi	a0,a0,1230 # 8a0 <digits>
 3da:	883a                	mv	a6,a4
 3dc:	2705                	addiw	a4,a4,1
 3de:	02c5f7bb          	remuw	a5,a1,a2
 3e2:	1782                	slli	a5,a5,0x20
 3e4:	9381                	srli	a5,a5,0x20
 3e6:	97aa                	add	a5,a5,a0
 3e8:	0007c783          	lbu	a5,0(a5)
 3ec:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3f0:	0005879b          	sext.w	a5,a1
 3f4:	02c5d5bb          	divuw	a1,a1,a2
 3f8:	0685                	addi	a3,a3,1
 3fa:	fec7f0e3          	bgeu	a5,a2,3da <printint+0x26>
  if(neg)
 3fe:	00088c63          	beqz	a7,416 <printint+0x62>
    buf[i++] = '-';
 402:	fd070793          	addi	a5,a4,-48
 406:	00878733          	add	a4,a5,s0
 40a:	02d00793          	li	a5,45
 40e:	fef70823          	sb	a5,-16(a4)
 412:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 416:	02e05c63          	blez	a4,44e <printint+0x9a>
 41a:	f04a                	sd	s2,32(sp)
 41c:	ec4e                	sd	s3,24(sp)
 41e:	fc040793          	addi	a5,s0,-64
 422:	00e78933          	add	s2,a5,a4
 426:	fff78993          	addi	s3,a5,-1
 42a:	99ba                	add	s3,s3,a4
 42c:	377d                	addiw	a4,a4,-1
 42e:	1702                	slli	a4,a4,0x20
 430:	9301                	srli	a4,a4,0x20
 432:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 436:	fff94583          	lbu	a1,-1(s2)
 43a:	8526                	mv	a0,s1
 43c:	00000097          	auipc	ra,0x0
 440:	f56080e7          	jalr	-170(ra) # 392 <putc>
  while(--i >= 0)
 444:	197d                	addi	s2,s2,-1
 446:	ff3918e3          	bne	s2,s3,436 <printint+0x82>
 44a:	7902                	ld	s2,32(sp)
 44c:	69e2                	ld	s3,24(sp)
}
 44e:	70e2                	ld	ra,56(sp)
 450:	7442                	ld	s0,48(sp)
 452:	74a2                	ld	s1,40(sp)
 454:	6121                	addi	sp,sp,64
 456:	8082                	ret
    x = -xx;
 458:	40b005bb          	negw	a1,a1
    neg = 1;
 45c:	4885                	li	a7,1
    x = -xx;
 45e:	b7b5                	j	3ca <printint+0x16>

0000000000000460 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 460:	715d                	addi	sp,sp,-80
 462:	e486                	sd	ra,72(sp)
 464:	e0a2                	sd	s0,64(sp)
 466:	f84a                	sd	s2,48(sp)
 468:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 46a:	0005c903          	lbu	s2,0(a1)
 46e:	1a090a63          	beqz	s2,622 <vprintf+0x1c2>
 472:	fc26                	sd	s1,56(sp)
 474:	f44e                	sd	s3,40(sp)
 476:	f052                	sd	s4,32(sp)
 478:	ec56                	sd	s5,24(sp)
 47a:	e85a                	sd	s6,16(sp)
 47c:	e45e                	sd	s7,8(sp)
 47e:	8aaa                	mv	s5,a0
 480:	8bb2                	mv	s7,a2
 482:	00158493          	addi	s1,a1,1
  state = 0;
 486:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 488:	02500a13          	li	s4,37
 48c:	4b55                	li	s6,21
 48e:	a839                	j	4ac <vprintf+0x4c>
        putc(fd, c);
 490:	85ca                	mv	a1,s2
 492:	8556                	mv	a0,s5
 494:	00000097          	auipc	ra,0x0
 498:	efe080e7          	jalr	-258(ra) # 392 <putc>
 49c:	a019                	j	4a2 <vprintf+0x42>
    } else if(state == '%'){
 49e:	01498d63          	beq	s3,s4,4b8 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4a2:	0485                	addi	s1,s1,1
 4a4:	fff4c903          	lbu	s2,-1(s1)
 4a8:	16090763          	beqz	s2,616 <vprintf+0x1b6>
    if(state == 0){
 4ac:	fe0999e3          	bnez	s3,49e <vprintf+0x3e>
      if(c == '%'){
 4b0:	ff4910e3          	bne	s2,s4,490 <vprintf+0x30>
        state = '%';
 4b4:	89d2                	mv	s3,s4
 4b6:	b7f5                	j	4a2 <vprintf+0x42>
      if(c == 'd'){
 4b8:	13490463          	beq	s2,s4,5e0 <vprintf+0x180>
 4bc:	f9d9079b          	addiw	a5,s2,-99
 4c0:	0ff7f793          	zext.b	a5,a5
 4c4:	12fb6763          	bltu	s6,a5,5f2 <vprintf+0x192>
 4c8:	f9d9079b          	addiw	a5,s2,-99
 4cc:	0ff7f713          	zext.b	a4,a5
 4d0:	12eb6163          	bltu	s6,a4,5f2 <vprintf+0x192>
 4d4:	00271793          	slli	a5,a4,0x2
 4d8:	00000717          	auipc	a4,0x0
 4dc:	37070713          	addi	a4,a4,880 # 848 <malloc+0x136>
 4e0:	97ba                	add	a5,a5,a4
 4e2:	439c                	lw	a5,0(a5)
 4e4:	97ba                	add	a5,a5,a4
 4e6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4e8:	008b8913          	addi	s2,s7,8
 4ec:	4685                	li	a3,1
 4ee:	4629                	li	a2,10
 4f0:	000ba583          	lw	a1,0(s7)
 4f4:	8556                	mv	a0,s5
 4f6:	00000097          	auipc	ra,0x0
 4fa:	ebe080e7          	jalr	-322(ra) # 3b4 <printint>
 4fe:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 500:	4981                	li	s3,0
 502:	b745                	j	4a2 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 504:	008b8913          	addi	s2,s7,8
 508:	4681                	li	a3,0
 50a:	4629                	li	a2,10
 50c:	000ba583          	lw	a1,0(s7)
 510:	8556                	mv	a0,s5
 512:	00000097          	auipc	ra,0x0
 516:	ea2080e7          	jalr	-350(ra) # 3b4 <printint>
 51a:	8bca                	mv	s7,s2
      state = 0;
 51c:	4981                	li	s3,0
 51e:	b751                	j	4a2 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 520:	008b8913          	addi	s2,s7,8
 524:	4681                	li	a3,0
 526:	4641                	li	a2,16
 528:	000ba583          	lw	a1,0(s7)
 52c:	8556                	mv	a0,s5
 52e:	00000097          	auipc	ra,0x0
 532:	e86080e7          	jalr	-378(ra) # 3b4 <printint>
 536:	8bca                	mv	s7,s2
      state = 0;
 538:	4981                	li	s3,0
 53a:	b7a5                	j	4a2 <vprintf+0x42>
 53c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 53e:	008b8c13          	addi	s8,s7,8
 542:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 546:	03000593          	li	a1,48
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e46080e7          	jalr	-442(ra) # 392 <putc>
  putc(fd, 'x');
 554:	07800593          	li	a1,120
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	e38080e7          	jalr	-456(ra) # 392 <putc>
 562:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 564:	00000b97          	auipc	s7,0x0
 568:	33cb8b93          	addi	s7,s7,828 # 8a0 <digits>
 56c:	03c9d793          	srli	a5,s3,0x3c
 570:	97de                	add	a5,a5,s7
 572:	0007c583          	lbu	a1,0(a5)
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e1a080e7          	jalr	-486(ra) # 392 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 580:	0992                	slli	s3,s3,0x4
 582:	397d                	addiw	s2,s2,-1
 584:	fe0914e3          	bnez	s2,56c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 588:	8be2                	mv	s7,s8
      state = 0;
 58a:	4981                	li	s3,0
 58c:	6c02                	ld	s8,0(sp)
 58e:	bf11                	j	4a2 <vprintf+0x42>
        s = va_arg(ap, char*);
 590:	008b8993          	addi	s3,s7,8
 594:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 598:	02090163          	beqz	s2,5ba <vprintf+0x15a>
        while(*s != 0){
 59c:	00094583          	lbu	a1,0(s2)
 5a0:	c9a5                	beqz	a1,610 <vprintf+0x1b0>
          putc(fd, *s);
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	dee080e7          	jalr	-530(ra) # 392 <putc>
          s++;
 5ac:	0905                	addi	s2,s2,1
        while(*s != 0){
 5ae:	00094583          	lbu	a1,0(s2)
 5b2:	f9e5                	bnez	a1,5a2 <vprintf+0x142>
        s = va_arg(ap, char*);
 5b4:	8bce                	mv	s7,s3
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b5ed                	j	4a2 <vprintf+0x42>
          s = "(null)";
 5ba:	00000917          	auipc	s2,0x0
 5be:	28690913          	addi	s2,s2,646 # 840 <malloc+0x12e>
        while(*s != 0){
 5c2:	02800593          	li	a1,40
 5c6:	bff1                	j	5a2 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 5c8:	008b8913          	addi	s2,s7,8
 5cc:	000bc583          	lbu	a1,0(s7)
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	dc0080e7          	jalr	-576(ra) # 392 <putc>
 5da:	8bca                	mv	s7,s2
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	b5d1                	j	4a2 <vprintf+0x42>
        putc(fd, c);
 5e0:	02500593          	li	a1,37
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	dac080e7          	jalr	-596(ra) # 392 <putc>
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bd4d                	j	4a2 <vprintf+0x42>
        putc(fd, '%');
 5f2:	02500593          	li	a1,37
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	d9a080e7          	jalr	-614(ra) # 392 <putc>
        putc(fd, c);
 600:	85ca                	mv	a1,s2
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	d8e080e7          	jalr	-626(ra) # 392 <putc>
      state = 0;
 60c:	4981                	li	s3,0
 60e:	bd51                	j	4a2 <vprintf+0x42>
        s = va_arg(ap, char*);
 610:	8bce                	mv	s7,s3
      state = 0;
 612:	4981                	li	s3,0
 614:	b579                	j	4a2 <vprintf+0x42>
 616:	74e2                	ld	s1,56(sp)
 618:	79a2                	ld	s3,40(sp)
 61a:	7a02                	ld	s4,32(sp)
 61c:	6ae2                	ld	s5,24(sp)
 61e:	6b42                	ld	s6,16(sp)
 620:	6ba2                	ld	s7,8(sp)
    }
  }
}
 622:	60a6                	ld	ra,72(sp)
 624:	6406                	ld	s0,64(sp)
 626:	7942                	ld	s2,48(sp)
 628:	6161                	addi	sp,sp,80
 62a:	8082                	ret

000000000000062c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 62c:	715d                	addi	sp,sp,-80
 62e:	ec06                	sd	ra,24(sp)
 630:	e822                	sd	s0,16(sp)
 632:	1000                	addi	s0,sp,32
 634:	e010                	sd	a2,0(s0)
 636:	e414                	sd	a3,8(s0)
 638:	e818                	sd	a4,16(s0)
 63a:	ec1c                	sd	a5,24(s0)
 63c:	03043023          	sd	a6,32(s0)
 640:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 644:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 648:	8622                	mv	a2,s0
 64a:	00000097          	auipc	ra,0x0
 64e:	e16080e7          	jalr	-490(ra) # 460 <vprintf>
}
 652:	60e2                	ld	ra,24(sp)
 654:	6442                	ld	s0,16(sp)
 656:	6161                	addi	sp,sp,80
 658:	8082                	ret

000000000000065a <printf>:

void
printf(const char *fmt, ...)
{
 65a:	711d                	addi	sp,sp,-96
 65c:	ec06                	sd	ra,24(sp)
 65e:	e822                	sd	s0,16(sp)
 660:	1000                	addi	s0,sp,32
 662:	e40c                	sd	a1,8(s0)
 664:	e810                	sd	a2,16(s0)
 666:	ec14                	sd	a3,24(s0)
 668:	f018                	sd	a4,32(s0)
 66a:	f41c                	sd	a5,40(s0)
 66c:	03043823          	sd	a6,48(s0)
 670:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 674:	00840613          	addi	a2,s0,8
 678:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 67c:	85aa                	mv	a1,a0
 67e:	4505                	li	a0,1
 680:	00000097          	auipc	ra,0x0
 684:	de0080e7          	jalr	-544(ra) # 460 <vprintf>
}
 688:	60e2                	ld	ra,24(sp)
 68a:	6442                	ld	s0,16(sp)
 68c:	6125                	addi	sp,sp,96
 68e:	8082                	ret

0000000000000690 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 690:	1141                	addi	sp,sp,-16
 692:	e422                	sd	s0,8(sp)
 694:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 696:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69a:	00001797          	auipc	a5,0x1
 69e:	d467b783          	ld	a5,-698(a5) # 13e0 <freep>
 6a2:	a02d                	j	6cc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6a4:	4618                	lw	a4,8(a2)
 6a6:	9f2d                	addw	a4,a4,a1
 6a8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ac:	6398                	ld	a4,0(a5)
 6ae:	6310                	ld	a2,0(a4)
 6b0:	a83d                	j	6ee <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6b2:	ff852703          	lw	a4,-8(a0)
 6b6:	9f31                	addw	a4,a4,a2
 6b8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6ba:	ff053683          	ld	a3,-16(a0)
 6be:	a091                	j	702 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c0:	6398                	ld	a4,0(a5)
 6c2:	00e7e463          	bltu	a5,a4,6ca <free+0x3a>
 6c6:	00e6ea63          	bltu	a3,a4,6da <free+0x4a>
{
 6ca:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6cc:	fed7fae3          	bgeu	a5,a3,6c0 <free+0x30>
 6d0:	6398                	ld	a4,0(a5)
 6d2:	00e6e463          	bltu	a3,a4,6da <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d6:	fee7eae3          	bltu	a5,a4,6ca <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6da:	ff852583          	lw	a1,-8(a0)
 6de:	6390                	ld	a2,0(a5)
 6e0:	02059813          	slli	a6,a1,0x20
 6e4:	01c85713          	srli	a4,a6,0x1c
 6e8:	9736                	add	a4,a4,a3
 6ea:	fae60de3          	beq	a2,a4,6a4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6ee:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6f2:	4790                	lw	a2,8(a5)
 6f4:	02061593          	slli	a1,a2,0x20
 6f8:	01c5d713          	srli	a4,a1,0x1c
 6fc:	973e                	add	a4,a4,a5
 6fe:	fae68ae3          	beq	a3,a4,6b2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 702:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 704:	00001717          	auipc	a4,0x1
 708:	ccf73e23          	sd	a5,-804(a4) # 13e0 <freep>
}
 70c:	6422                	ld	s0,8(sp)
 70e:	0141                	addi	sp,sp,16
 710:	8082                	ret

0000000000000712 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 712:	7139                	addi	sp,sp,-64
 714:	fc06                	sd	ra,56(sp)
 716:	f822                	sd	s0,48(sp)
 718:	f426                	sd	s1,40(sp)
 71a:	ec4e                	sd	s3,24(sp)
 71c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 71e:	02051493          	slli	s1,a0,0x20
 722:	9081                	srli	s1,s1,0x20
 724:	04bd                	addi	s1,s1,15
 726:	8091                	srli	s1,s1,0x4
 728:	0014899b          	addiw	s3,s1,1
 72c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 72e:	00001517          	auipc	a0,0x1
 732:	cb253503          	ld	a0,-846(a0) # 13e0 <freep>
 736:	c915                	beqz	a0,76a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 738:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 73a:	4798                	lw	a4,8(a5)
 73c:	08977e63          	bgeu	a4,s1,7d8 <malloc+0xc6>
 740:	f04a                	sd	s2,32(sp)
 742:	e852                	sd	s4,16(sp)
 744:	e456                	sd	s5,8(sp)
 746:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 748:	8a4e                	mv	s4,s3
 74a:	0009871b          	sext.w	a4,s3
 74e:	6685                	lui	a3,0x1
 750:	00d77363          	bgeu	a4,a3,756 <malloc+0x44>
 754:	6a05                	lui	s4,0x1
 756:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 75a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 75e:	00001917          	auipc	s2,0x1
 762:	c8290913          	addi	s2,s2,-894 # 13e0 <freep>
  if(p == (char*)-1)
 766:	5afd                	li	s5,-1
 768:	a091                	j	7ac <malloc+0x9a>
 76a:	f04a                	sd	s2,32(sp)
 76c:	e852                	sd	s4,16(sp)
 76e:	e456                	sd	s5,8(sp)
 770:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 772:	00001797          	auipc	a5,0x1
 776:	c7e78793          	addi	a5,a5,-898 # 13f0 <base>
 77a:	00001717          	auipc	a4,0x1
 77e:	c6f73323          	sd	a5,-922(a4) # 13e0 <freep>
 782:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 784:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 788:	b7c1                	j	748 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 78a:	6398                	ld	a4,0(a5)
 78c:	e118                	sd	a4,0(a0)
 78e:	a08d                	j	7f0 <malloc+0xde>
  hp->s.size = nu;
 790:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 794:	0541                	addi	a0,a0,16
 796:	00000097          	auipc	ra,0x0
 79a:	efa080e7          	jalr	-262(ra) # 690 <free>
  return freep;
 79e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7a2:	c13d                	beqz	a0,808 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a6:	4798                	lw	a4,8(a5)
 7a8:	02977463          	bgeu	a4,s1,7d0 <malloc+0xbe>
    if(p == freep)
 7ac:	00093703          	ld	a4,0(s2)
 7b0:	853e                	mv	a0,a5
 7b2:	fef719e3          	bne	a4,a5,7a4 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7b6:	8552                	mv	a0,s4
 7b8:	00000097          	auipc	ra,0x0
 7bc:	b9a080e7          	jalr	-1126(ra) # 352 <sbrk>
  if(p == (char*)-1)
 7c0:	fd5518e3          	bne	a0,s5,790 <malloc+0x7e>
        return 0;
 7c4:	4501                	li	a0,0
 7c6:	7902                	ld	s2,32(sp)
 7c8:	6a42                	ld	s4,16(sp)
 7ca:	6aa2                	ld	s5,8(sp)
 7cc:	6b02                	ld	s6,0(sp)
 7ce:	a03d                	j	7fc <malloc+0xea>
 7d0:	7902                	ld	s2,32(sp)
 7d2:	6a42                	ld	s4,16(sp)
 7d4:	6aa2                	ld	s5,8(sp)
 7d6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7d8:	fae489e3          	beq	s1,a4,78a <malloc+0x78>
        p->s.size -= nunits;
 7dc:	4137073b          	subw	a4,a4,s3
 7e0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7e2:	02071693          	slli	a3,a4,0x20
 7e6:	01c6d713          	srli	a4,a3,0x1c
 7ea:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7ec:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7f0:	00001717          	auipc	a4,0x1
 7f4:	bea73823          	sd	a0,-1040(a4) # 13e0 <freep>
      return (void*)(p + 1);
 7f8:	01078513          	addi	a0,a5,16
  }
}
 7fc:	70e2                	ld	ra,56(sp)
 7fe:	7442                	ld	s0,48(sp)
 800:	74a2                	ld	s1,40(sp)
 802:	69e2                	ld	s3,24(sp)
 804:	6121                	addi	sp,sp,64
 806:	8082                	ret
 808:	7902                	ld	s2,32(sp)
 80a:	6a42                	ld	s4,16(sp)
 80c:	6aa2                	ld	s5,8(sp)
 80e:	6b02                	ld	s6,0(sp)
 810:	b7f5                	j	7fc <malloc+0xea>
