
user/_ps:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
    uint16 proc_idx = 0;
   e:	4901                	li	s2,0

        for (int i = 0; i < 2; i++)
        {
            if (procs[i].state == UNUSED)
                exit(0);
            printf("%s (%d): %d\n", procs[i].name, procs[i].pid, procs[i].state);
  10:	00001997          	auipc	s3,0x1
  14:	85098993          	addi	s3,s3,-1968 # 860 <malloc+0x112>
  18:	a815                	j	4c <main+0x4c>
            printf("SYSCALL FAILED");
  1a:	00001517          	auipc	a0,0x1
  1e:	83650513          	addi	a0,a0,-1994 # 850 <malloc+0x102>
  22:	00000097          	auipc	ra,0x0
  26:	674080e7          	jalr	1652(ra) # 696 <printf>
            exit(-1);
  2a:	557d                	li	a0,-1
  2c:	00000097          	auipc	ra,0x0
  30:	2da080e7          	jalr	730(ra) # 306 <exit>
            printf("%s (%d): %d\n", procs[i].name, procs[i].pid, procs[i].state);
  34:	5890                	lw	a2,48(s1)
  36:	03848593          	addi	a1,s1,56
  3a:	854e                	mv	a0,s3
  3c:	00000097          	auipc	ra,0x0
  40:	65a080e7          	jalr	1626(ra) # 696 <printf>
        }
        proc_idx += 2;
  44:	2909                	addiw	s2,s2,2
  46:	1942                	slli	s2,s2,0x30
  48:	03095913          	srli	s2,s2,0x30
        struct user_proc *procs = ps(proc_idx, 2);
  4c:	4589                	li	a1,2
  4e:	0ff97513          	zext.b	a0,s2
  52:	00000097          	auipc	ra,0x0
  56:	354080e7          	jalr	852(ra) # 3a6 <ps>
  5a:	84aa                	mv	s1,a0
        if (procs == 0)
  5c:	dd5d                	beqz	a0,1a <main+0x1a>
            if (procs[i].state == UNUSED)
  5e:	4114                	lw	a3,0(a0)
  60:	ca99                	beqz	a3,76 <main+0x76>
            printf("%s (%d): %d\n", procs[i].name, procs[i].pid, procs[i].state);
  62:	4550                	lw	a2,12(a0)
  64:	01450593          	addi	a1,a0,20
  68:	854e                	mv	a0,s3
  6a:	00000097          	auipc	ra,0x0
  6e:	62c080e7          	jalr	1580(ra) # 696 <printf>
            if (procs[i].state == UNUSED)
  72:	50d4                	lw	a3,36(s1)
  74:	f2e1                	bnez	a3,34 <main+0x34>
                exit(0);
  76:	4501                	li	a0,0
  78:	00000097          	auipc	ra,0x0
  7c:	28e080e7          	jalr	654(ra) # 306 <exit>

0000000000000080 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  80:	1141                	addi	sp,sp,-16
  82:	e406                	sd	ra,8(sp)
  84:	e022                	sd	s0,0(sp)
  86:	0800                	addi	s0,sp,16
  extern int main();
  main();
  88:	00000097          	auipc	ra,0x0
  8c:	f78080e7          	jalr	-136(ra) # 0 <main>
  exit(0);
  90:	4501                	li	a0,0
  92:	00000097          	auipc	ra,0x0
  96:	274080e7          	jalr	628(ra) # 306 <exit>

000000000000009a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  9a:	1141                	addi	sp,sp,-16
  9c:	e422                	sd	s0,8(sp)
  9e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a0:	87aa                	mv	a5,a0
  a2:	0585                	addi	a1,a1,1
  a4:	0785                	addi	a5,a5,1
  a6:	fff5c703          	lbu	a4,-1(a1)
  aa:	fee78fa3          	sb	a4,-1(a5)
  ae:	fb75                	bnez	a4,a2 <strcpy+0x8>
    ;
  return os;
}
  b0:	6422                	ld	s0,8(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret

00000000000000b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	cb91                	beqz	a5,d4 <strcmp+0x1e>
  c2:	0005c703          	lbu	a4,0(a1)
  c6:	00f71763          	bne	a4,a5,d4 <strcmp+0x1e>
    p++, q++;
  ca:	0505                	addi	a0,a0,1
  cc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	fbe5                	bnez	a5,c2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  d4:	0005c503          	lbu	a0,0(a1)
}
  d8:	40a7853b          	subw	a0,a5,a0
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret

00000000000000e2 <strlen>:

uint
strlen(const char *s)
{
  e2:	1141                	addi	sp,sp,-16
  e4:	e422                	sd	s0,8(sp)
  e6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	cf91                	beqz	a5,108 <strlen+0x26>
  ee:	0505                	addi	a0,a0,1
  f0:	87aa                	mv	a5,a0
  f2:	86be                	mv	a3,a5
  f4:	0785                	addi	a5,a5,1
  f6:	fff7c703          	lbu	a4,-1(a5)
  fa:	ff65                	bnez	a4,f2 <strlen+0x10>
  fc:	40a6853b          	subw	a0,a3,a0
 100:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret
  for(n = 0; s[n]; n++)
 108:	4501                	li	a0,0
 10a:	bfe5                	j	102 <strlen+0x20>

000000000000010c <memset>:

void*
memset(void *dst, int c, uint n)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e422                	sd	s0,8(sp)
 110:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 112:	ca19                	beqz	a2,128 <memset+0x1c>
 114:	87aa                	mv	a5,a0
 116:	1602                	slli	a2,a2,0x20
 118:	9201                	srli	a2,a2,0x20
 11a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 11e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 122:	0785                	addi	a5,a5,1
 124:	fee79de3          	bne	a5,a4,11e <memset+0x12>
  }
  return dst;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret

000000000000012e <strchr>:

char*
strchr(const char *s, char c)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  for(; *s; s++)
 134:	00054783          	lbu	a5,0(a0)
 138:	cb99                	beqz	a5,14e <strchr+0x20>
    if(*s == c)
 13a:	00f58763          	beq	a1,a5,148 <strchr+0x1a>
  for(; *s; s++)
 13e:	0505                	addi	a0,a0,1
 140:	00054783          	lbu	a5,0(a0)
 144:	fbfd                	bnez	a5,13a <strchr+0xc>
      return (char*)s;
  return 0;
 146:	4501                	li	a0,0
}
 148:	6422                	ld	s0,8(sp)
 14a:	0141                	addi	sp,sp,16
 14c:	8082                	ret
  return 0;
 14e:	4501                	li	a0,0
 150:	bfe5                	j	148 <strchr+0x1a>

0000000000000152 <gets>:

char*
gets(char *buf, int max)
{
 152:	711d                	addi	sp,sp,-96
 154:	ec86                	sd	ra,88(sp)
 156:	e8a2                	sd	s0,80(sp)
 158:	e4a6                	sd	s1,72(sp)
 15a:	e0ca                	sd	s2,64(sp)
 15c:	fc4e                	sd	s3,56(sp)
 15e:	f852                	sd	s4,48(sp)
 160:	f456                	sd	s5,40(sp)
 162:	f05a                	sd	s6,32(sp)
 164:	ec5e                	sd	s7,24(sp)
 166:	1080                	addi	s0,sp,96
 168:	8baa                	mv	s7,a0
 16a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16c:	892a                	mv	s2,a0
 16e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 170:	4aa9                	li	s5,10
 172:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 174:	89a6                	mv	s3,s1
 176:	2485                	addiw	s1,s1,1
 178:	0344d863          	bge	s1,s4,1a8 <gets+0x56>
    cc = read(0, &c, 1);
 17c:	4605                	li	a2,1
 17e:	faf40593          	addi	a1,s0,-81
 182:	4501                	li	a0,0
 184:	00000097          	auipc	ra,0x0
 188:	19a080e7          	jalr	410(ra) # 31e <read>
    if(cc < 1)
 18c:	00a05e63          	blez	a0,1a8 <gets+0x56>
    buf[i++] = c;
 190:	faf44783          	lbu	a5,-81(s0)
 194:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 198:	01578763          	beq	a5,s5,1a6 <gets+0x54>
 19c:	0905                	addi	s2,s2,1
 19e:	fd679be3          	bne	a5,s6,174 <gets+0x22>
    buf[i++] = c;
 1a2:	89a6                	mv	s3,s1
 1a4:	a011                	j	1a8 <gets+0x56>
 1a6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1a8:	99de                	add	s3,s3,s7
 1aa:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ae:	855e                	mv	a0,s7
 1b0:	60e6                	ld	ra,88(sp)
 1b2:	6446                	ld	s0,80(sp)
 1b4:	64a6                	ld	s1,72(sp)
 1b6:	6906                	ld	s2,64(sp)
 1b8:	79e2                	ld	s3,56(sp)
 1ba:	7a42                	ld	s4,48(sp)
 1bc:	7aa2                	ld	s5,40(sp)
 1be:	7b02                	ld	s6,32(sp)
 1c0:	6be2                	ld	s7,24(sp)
 1c2:	6125                	addi	sp,sp,96
 1c4:	8082                	ret

00000000000001c6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c6:	1101                	addi	sp,sp,-32
 1c8:	ec06                	sd	ra,24(sp)
 1ca:	e822                	sd	s0,16(sp)
 1cc:	e04a                	sd	s2,0(sp)
 1ce:	1000                	addi	s0,sp,32
 1d0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d2:	4581                	li	a1,0
 1d4:	00000097          	auipc	ra,0x0
 1d8:	172080e7          	jalr	370(ra) # 346 <open>
  if(fd < 0)
 1dc:	02054663          	bltz	a0,208 <stat+0x42>
 1e0:	e426                	sd	s1,8(sp)
 1e2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1e4:	85ca                	mv	a1,s2
 1e6:	00000097          	auipc	ra,0x0
 1ea:	178080e7          	jalr	376(ra) # 35e <fstat>
 1ee:	892a                	mv	s2,a0
  close(fd);
 1f0:	8526                	mv	a0,s1
 1f2:	00000097          	auipc	ra,0x0
 1f6:	13c080e7          	jalr	316(ra) # 32e <close>
  return r;
 1fa:	64a2                	ld	s1,8(sp)
}
 1fc:	854a                	mv	a0,s2
 1fe:	60e2                	ld	ra,24(sp)
 200:	6442                	ld	s0,16(sp)
 202:	6902                	ld	s2,0(sp)
 204:	6105                	addi	sp,sp,32
 206:	8082                	ret
    return -1;
 208:	597d                	li	s2,-1
 20a:	bfcd                	j	1fc <stat+0x36>

000000000000020c <atoi>:

int
atoi(const char *s)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e422                	sd	s0,8(sp)
 210:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 212:	00054683          	lbu	a3,0(a0)
 216:	fd06879b          	addiw	a5,a3,-48
 21a:	0ff7f793          	zext.b	a5,a5
 21e:	4625                	li	a2,9
 220:	02f66863          	bltu	a2,a5,250 <atoi+0x44>
 224:	872a                	mv	a4,a0
  n = 0;
 226:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 228:	0705                	addi	a4,a4,1
 22a:	0025179b          	slliw	a5,a0,0x2
 22e:	9fa9                	addw	a5,a5,a0
 230:	0017979b          	slliw	a5,a5,0x1
 234:	9fb5                	addw	a5,a5,a3
 236:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 23a:	00074683          	lbu	a3,0(a4)
 23e:	fd06879b          	addiw	a5,a3,-48
 242:	0ff7f793          	zext.b	a5,a5
 246:	fef671e3          	bgeu	a2,a5,228 <atoi+0x1c>
  return n;
}
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
  n = 0;
 250:	4501                	li	a0,0
 252:	bfe5                	j	24a <atoi+0x3e>

0000000000000254 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 254:	1141                	addi	sp,sp,-16
 256:	e422                	sd	s0,8(sp)
 258:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 25a:	02b57463          	bgeu	a0,a1,282 <memmove+0x2e>
    while(n-- > 0)
 25e:	00c05f63          	blez	a2,27c <memmove+0x28>
 262:	1602                	slli	a2,a2,0x20
 264:	9201                	srli	a2,a2,0x20
 266:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 26a:	872a                	mv	a4,a0
      *dst++ = *src++;
 26c:	0585                	addi	a1,a1,1
 26e:	0705                	addi	a4,a4,1
 270:	fff5c683          	lbu	a3,-1(a1)
 274:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 278:	fef71ae3          	bne	a4,a5,26c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 27c:	6422                	ld	s0,8(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret
    dst += n;
 282:	00c50733          	add	a4,a0,a2
    src += n;
 286:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 288:	fec05ae3          	blez	a2,27c <memmove+0x28>
 28c:	fff6079b          	addiw	a5,a2,-1
 290:	1782                	slli	a5,a5,0x20
 292:	9381                	srli	a5,a5,0x20
 294:	fff7c793          	not	a5,a5
 298:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 29a:	15fd                	addi	a1,a1,-1
 29c:	177d                	addi	a4,a4,-1
 29e:	0005c683          	lbu	a3,0(a1)
 2a2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2a6:	fee79ae3          	bne	a5,a4,29a <memmove+0x46>
 2aa:	bfc9                	j	27c <memmove+0x28>

00000000000002ac <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e422                	sd	s0,8(sp)
 2b0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2b2:	ca05                	beqz	a2,2e2 <memcmp+0x36>
 2b4:	fff6069b          	addiw	a3,a2,-1
 2b8:	1682                	slli	a3,a3,0x20
 2ba:	9281                	srli	a3,a3,0x20
 2bc:	0685                	addi	a3,a3,1
 2be:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2c0:	00054783          	lbu	a5,0(a0)
 2c4:	0005c703          	lbu	a4,0(a1)
 2c8:	00e79863          	bne	a5,a4,2d8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2cc:	0505                	addi	a0,a0,1
    p2++;
 2ce:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2d0:	fed518e3          	bne	a0,a3,2c0 <memcmp+0x14>
  }
  return 0;
 2d4:	4501                	li	a0,0
 2d6:	a019                	j	2dc <memcmp+0x30>
      return *p1 - *p2;
 2d8:	40e7853b          	subw	a0,a5,a4
}
 2dc:	6422                	ld	s0,8(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret
  return 0;
 2e2:	4501                	li	a0,0
 2e4:	bfe5                	j	2dc <memcmp+0x30>

00000000000002e6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e406                	sd	ra,8(sp)
 2ea:	e022                	sd	s0,0(sp)
 2ec:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ee:	00000097          	auipc	ra,0x0
 2f2:	f66080e7          	jalr	-154(ra) # 254 <memmove>
}
 2f6:	60a2                	ld	ra,8(sp)
 2f8:	6402                	ld	s0,0(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret

00000000000002fe <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2fe:	4885                	li	a7,1
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <exit>:
.global exit
exit:
 li a7, SYS_exit
 306:	4889                	li	a7,2
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <wait>:
.global wait
wait:
 li a7, SYS_wait
 30e:	488d                	li	a7,3
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 316:	4891                	li	a7,4
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <read>:
.global read
read:
 li a7, SYS_read
 31e:	4895                	li	a7,5
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <write>:
.global write
write:
 li a7, SYS_write
 326:	48c1                	li	a7,16
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <close>:
.global close
close:
 li a7, SYS_close
 32e:	48d5                	li	a7,21
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <kill>:
.global kill
kill:
 li a7, SYS_kill
 336:	4899                	li	a7,6
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <exec>:
.global exec
exec:
 li a7, SYS_exec
 33e:	489d                	li	a7,7
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <open>:
.global open
open:
 li a7, SYS_open
 346:	48bd                	li	a7,15
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 34e:	48c5                	li	a7,17
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 356:	48c9                	li	a7,18
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 35e:	48a1                	li	a7,8
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <link>:
.global link
link:
 li a7, SYS_link
 366:	48cd                	li	a7,19
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 36e:	48d1                	li	a7,20
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 376:	48a5                	li	a7,9
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <dup>:
.global dup
dup:
 li a7, SYS_dup
 37e:	48a9                	li	a7,10
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 386:	48ad                	li	a7,11
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 38e:	48b1                	li	a7,12
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 396:	48b5                	li	a7,13
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 39e:	48b9                	li	a7,14
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <ps>:
.global ps
ps:
 li a7, SYS_ps
 3a6:	48d9                	li	a7,22
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 3ae:	48dd                	li	a7,23
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 3b6:	48e1                	li	a7,24
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 3be:	48e9                	li	a7,26
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 3c6:	48e5                	li	a7,25
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ce:	1101                	addi	sp,sp,-32
 3d0:	ec06                	sd	ra,24(sp)
 3d2:	e822                	sd	s0,16(sp)
 3d4:	1000                	addi	s0,sp,32
 3d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3da:	4605                	li	a2,1
 3dc:	fef40593          	addi	a1,s0,-17
 3e0:	00000097          	auipc	ra,0x0
 3e4:	f46080e7          	jalr	-186(ra) # 326 <write>
}
 3e8:	60e2                	ld	ra,24(sp)
 3ea:	6442                	ld	s0,16(sp)
 3ec:	6105                	addi	sp,sp,32
 3ee:	8082                	ret

00000000000003f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f0:	7139                	addi	sp,sp,-64
 3f2:	fc06                	sd	ra,56(sp)
 3f4:	f822                	sd	s0,48(sp)
 3f6:	f426                	sd	s1,40(sp)
 3f8:	0080                	addi	s0,sp,64
 3fa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3fc:	c299                	beqz	a3,402 <printint+0x12>
 3fe:	0805cb63          	bltz	a1,494 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 402:	2581                	sext.w	a1,a1
  neg = 0;
 404:	4881                	li	a7,0
 406:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 40a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 40c:	2601                	sext.w	a2,a2
 40e:	00000517          	auipc	a0,0x0
 412:	4c250513          	addi	a0,a0,1218 # 8d0 <digits>
 416:	883a                	mv	a6,a4
 418:	2705                	addiw	a4,a4,1
 41a:	02c5f7bb          	remuw	a5,a1,a2
 41e:	1782                	slli	a5,a5,0x20
 420:	9381                	srli	a5,a5,0x20
 422:	97aa                	add	a5,a5,a0
 424:	0007c783          	lbu	a5,0(a5)
 428:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 42c:	0005879b          	sext.w	a5,a1
 430:	02c5d5bb          	divuw	a1,a1,a2
 434:	0685                	addi	a3,a3,1
 436:	fec7f0e3          	bgeu	a5,a2,416 <printint+0x26>
  if(neg)
 43a:	00088c63          	beqz	a7,452 <printint+0x62>
    buf[i++] = '-';
 43e:	fd070793          	addi	a5,a4,-48
 442:	00878733          	add	a4,a5,s0
 446:	02d00793          	li	a5,45
 44a:	fef70823          	sb	a5,-16(a4)
 44e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 452:	02e05c63          	blez	a4,48a <printint+0x9a>
 456:	f04a                	sd	s2,32(sp)
 458:	ec4e                	sd	s3,24(sp)
 45a:	fc040793          	addi	a5,s0,-64
 45e:	00e78933          	add	s2,a5,a4
 462:	fff78993          	addi	s3,a5,-1
 466:	99ba                	add	s3,s3,a4
 468:	377d                	addiw	a4,a4,-1
 46a:	1702                	slli	a4,a4,0x20
 46c:	9301                	srli	a4,a4,0x20
 46e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 472:	fff94583          	lbu	a1,-1(s2)
 476:	8526                	mv	a0,s1
 478:	00000097          	auipc	ra,0x0
 47c:	f56080e7          	jalr	-170(ra) # 3ce <putc>
  while(--i >= 0)
 480:	197d                	addi	s2,s2,-1
 482:	ff3918e3          	bne	s2,s3,472 <printint+0x82>
 486:	7902                	ld	s2,32(sp)
 488:	69e2                	ld	s3,24(sp)
}
 48a:	70e2                	ld	ra,56(sp)
 48c:	7442                	ld	s0,48(sp)
 48e:	74a2                	ld	s1,40(sp)
 490:	6121                	addi	sp,sp,64
 492:	8082                	ret
    x = -xx;
 494:	40b005bb          	negw	a1,a1
    neg = 1;
 498:	4885                	li	a7,1
    x = -xx;
 49a:	b7b5                	j	406 <printint+0x16>

000000000000049c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 49c:	715d                	addi	sp,sp,-80
 49e:	e486                	sd	ra,72(sp)
 4a0:	e0a2                	sd	s0,64(sp)
 4a2:	f84a                	sd	s2,48(sp)
 4a4:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a6:	0005c903          	lbu	s2,0(a1)
 4aa:	1a090a63          	beqz	s2,65e <vprintf+0x1c2>
 4ae:	fc26                	sd	s1,56(sp)
 4b0:	f44e                	sd	s3,40(sp)
 4b2:	f052                	sd	s4,32(sp)
 4b4:	ec56                	sd	s5,24(sp)
 4b6:	e85a                	sd	s6,16(sp)
 4b8:	e45e                	sd	s7,8(sp)
 4ba:	8aaa                	mv	s5,a0
 4bc:	8bb2                	mv	s7,a2
 4be:	00158493          	addi	s1,a1,1
  state = 0;
 4c2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4c4:	02500a13          	li	s4,37
 4c8:	4b55                	li	s6,21
 4ca:	a839                	j	4e8 <vprintf+0x4c>
        putc(fd, c);
 4cc:	85ca                	mv	a1,s2
 4ce:	8556                	mv	a0,s5
 4d0:	00000097          	auipc	ra,0x0
 4d4:	efe080e7          	jalr	-258(ra) # 3ce <putc>
 4d8:	a019                	j	4de <vprintf+0x42>
    } else if(state == '%'){
 4da:	01498d63          	beq	s3,s4,4f4 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4de:	0485                	addi	s1,s1,1
 4e0:	fff4c903          	lbu	s2,-1(s1)
 4e4:	16090763          	beqz	s2,652 <vprintf+0x1b6>
    if(state == 0){
 4e8:	fe0999e3          	bnez	s3,4da <vprintf+0x3e>
      if(c == '%'){
 4ec:	ff4910e3          	bne	s2,s4,4cc <vprintf+0x30>
        state = '%';
 4f0:	89d2                	mv	s3,s4
 4f2:	b7f5                	j	4de <vprintf+0x42>
      if(c == 'd'){
 4f4:	13490463          	beq	s2,s4,61c <vprintf+0x180>
 4f8:	f9d9079b          	addiw	a5,s2,-99
 4fc:	0ff7f793          	zext.b	a5,a5
 500:	12fb6763          	bltu	s6,a5,62e <vprintf+0x192>
 504:	f9d9079b          	addiw	a5,s2,-99
 508:	0ff7f713          	zext.b	a4,a5
 50c:	12eb6163          	bltu	s6,a4,62e <vprintf+0x192>
 510:	00271793          	slli	a5,a4,0x2
 514:	00000717          	auipc	a4,0x0
 518:	36470713          	addi	a4,a4,868 # 878 <malloc+0x12a>
 51c:	97ba                	add	a5,a5,a4
 51e:	439c                	lw	a5,0(a5)
 520:	97ba                	add	a5,a5,a4
 522:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 524:	008b8913          	addi	s2,s7,8
 528:	4685                	li	a3,1
 52a:	4629                	li	a2,10
 52c:	000ba583          	lw	a1,0(s7)
 530:	8556                	mv	a0,s5
 532:	00000097          	auipc	ra,0x0
 536:	ebe080e7          	jalr	-322(ra) # 3f0 <printint>
 53a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 53c:	4981                	li	s3,0
 53e:	b745                	j	4de <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 540:	008b8913          	addi	s2,s7,8
 544:	4681                	li	a3,0
 546:	4629                	li	a2,10
 548:	000ba583          	lw	a1,0(s7)
 54c:	8556                	mv	a0,s5
 54e:	00000097          	auipc	ra,0x0
 552:	ea2080e7          	jalr	-350(ra) # 3f0 <printint>
 556:	8bca                	mv	s7,s2
      state = 0;
 558:	4981                	li	s3,0
 55a:	b751                	j	4de <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 55c:	008b8913          	addi	s2,s7,8
 560:	4681                	li	a3,0
 562:	4641                	li	a2,16
 564:	000ba583          	lw	a1,0(s7)
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	e86080e7          	jalr	-378(ra) # 3f0 <printint>
 572:	8bca                	mv	s7,s2
      state = 0;
 574:	4981                	li	s3,0
 576:	b7a5                	j	4de <vprintf+0x42>
 578:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 57a:	008b8c13          	addi	s8,s7,8
 57e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 582:	03000593          	li	a1,48
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	e46080e7          	jalr	-442(ra) # 3ce <putc>
  putc(fd, 'x');
 590:	07800593          	li	a1,120
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	e38080e7          	jalr	-456(ra) # 3ce <putc>
 59e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a0:	00000b97          	auipc	s7,0x0
 5a4:	330b8b93          	addi	s7,s7,816 # 8d0 <digits>
 5a8:	03c9d793          	srli	a5,s3,0x3c
 5ac:	97de                	add	a5,a5,s7
 5ae:	0007c583          	lbu	a1,0(a5)
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	e1a080e7          	jalr	-486(ra) # 3ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5bc:	0992                	slli	s3,s3,0x4
 5be:	397d                	addiw	s2,s2,-1
 5c0:	fe0914e3          	bnez	s2,5a8 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5c4:	8be2                	mv	s7,s8
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	6c02                	ld	s8,0(sp)
 5ca:	bf11                	j	4de <vprintf+0x42>
        s = va_arg(ap, char*);
 5cc:	008b8993          	addi	s3,s7,8
 5d0:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5d4:	02090163          	beqz	s2,5f6 <vprintf+0x15a>
        while(*s != 0){
 5d8:	00094583          	lbu	a1,0(s2)
 5dc:	c9a5                	beqz	a1,64c <vprintf+0x1b0>
          putc(fd, *s);
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	dee080e7          	jalr	-530(ra) # 3ce <putc>
          s++;
 5e8:	0905                	addi	s2,s2,1
        while(*s != 0){
 5ea:	00094583          	lbu	a1,0(s2)
 5ee:	f9e5                	bnez	a1,5de <vprintf+0x142>
        s = va_arg(ap, char*);
 5f0:	8bce                	mv	s7,s3
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b5ed                	j	4de <vprintf+0x42>
          s = "(null)";
 5f6:	00000917          	auipc	s2,0x0
 5fa:	27a90913          	addi	s2,s2,634 # 870 <malloc+0x122>
        while(*s != 0){
 5fe:	02800593          	li	a1,40
 602:	bff1                	j	5de <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 604:	008b8913          	addi	s2,s7,8
 608:	000bc583          	lbu	a1,0(s7)
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	dc0080e7          	jalr	-576(ra) # 3ce <putc>
 616:	8bca                	mv	s7,s2
      state = 0;
 618:	4981                	li	s3,0
 61a:	b5d1                	j	4de <vprintf+0x42>
        putc(fd, c);
 61c:	02500593          	li	a1,37
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	dac080e7          	jalr	-596(ra) # 3ce <putc>
      state = 0;
 62a:	4981                	li	s3,0
 62c:	bd4d                	j	4de <vprintf+0x42>
        putc(fd, '%');
 62e:	02500593          	li	a1,37
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	d9a080e7          	jalr	-614(ra) # 3ce <putc>
        putc(fd, c);
 63c:	85ca                	mv	a1,s2
 63e:	8556                	mv	a0,s5
 640:	00000097          	auipc	ra,0x0
 644:	d8e080e7          	jalr	-626(ra) # 3ce <putc>
      state = 0;
 648:	4981                	li	s3,0
 64a:	bd51                	j	4de <vprintf+0x42>
        s = va_arg(ap, char*);
 64c:	8bce                	mv	s7,s3
      state = 0;
 64e:	4981                	li	s3,0
 650:	b579                	j	4de <vprintf+0x42>
 652:	74e2                	ld	s1,56(sp)
 654:	79a2                	ld	s3,40(sp)
 656:	7a02                	ld	s4,32(sp)
 658:	6ae2                	ld	s5,24(sp)
 65a:	6b42                	ld	s6,16(sp)
 65c:	6ba2                	ld	s7,8(sp)
    }
  }
}
 65e:	60a6                	ld	ra,72(sp)
 660:	6406                	ld	s0,64(sp)
 662:	7942                	ld	s2,48(sp)
 664:	6161                	addi	sp,sp,80
 666:	8082                	ret

0000000000000668 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 668:	715d                	addi	sp,sp,-80
 66a:	ec06                	sd	ra,24(sp)
 66c:	e822                	sd	s0,16(sp)
 66e:	1000                	addi	s0,sp,32
 670:	e010                	sd	a2,0(s0)
 672:	e414                	sd	a3,8(s0)
 674:	e818                	sd	a4,16(s0)
 676:	ec1c                	sd	a5,24(s0)
 678:	03043023          	sd	a6,32(s0)
 67c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 680:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 684:	8622                	mv	a2,s0
 686:	00000097          	auipc	ra,0x0
 68a:	e16080e7          	jalr	-490(ra) # 49c <vprintf>
}
 68e:	60e2                	ld	ra,24(sp)
 690:	6442                	ld	s0,16(sp)
 692:	6161                	addi	sp,sp,80
 694:	8082                	ret

0000000000000696 <printf>:

void
printf(const char *fmt, ...)
{
 696:	711d                	addi	sp,sp,-96
 698:	ec06                	sd	ra,24(sp)
 69a:	e822                	sd	s0,16(sp)
 69c:	1000                	addi	s0,sp,32
 69e:	e40c                	sd	a1,8(s0)
 6a0:	e810                	sd	a2,16(s0)
 6a2:	ec14                	sd	a3,24(s0)
 6a4:	f018                	sd	a4,32(s0)
 6a6:	f41c                	sd	a5,40(s0)
 6a8:	03043823          	sd	a6,48(s0)
 6ac:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6b0:	00840613          	addi	a2,s0,8
 6b4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6b8:	85aa                	mv	a1,a0
 6ba:	4505                	li	a0,1
 6bc:	00000097          	auipc	ra,0x0
 6c0:	de0080e7          	jalr	-544(ra) # 49c <vprintf>
}
 6c4:	60e2                	ld	ra,24(sp)
 6c6:	6442                	ld	s0,16(sp)
 6c8:	6125                	addi	sp,sp,96
 6ca:	8082                	ret

00000000000006cc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6cc:	1141                	addi	sp,sp,-16
 6ce:	e422                	sd	s0,8(sp)
 6d0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6d2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d6:	00001797          	auipc	a5,0x1
 6da:	d0a7b783          	ld	a5,-758(a5) # 13e0 <freep>
 6de:	a02d                	j	708 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6e0:	4618                	lw	a4,8(a2)
 6e2:	9f2d                	addw	a4,a4,a1
 6e4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6e8:	6398                	ld	a4,0(a5)
 6ea:	6310                	ld	a2,0(a4)
 6ec:	a83d                	j	72a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6ee:	ff852703          	lw	a4,-8(a0)
 6f2:	9f31                	addw	a4,a4,a2
 6f4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6f6:	ff053683          	ld	a3,-16(a0)
 6fa:	a091                	j	73e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6fc:	6398                	ld	a4,0(a5)
 6fe:	00e7e463          	bltu	a5,a4,706 <free+0x3a>
 702:	00e6ea63          	bltu	a3,a4,716 <free+0x4a>
{
 706:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 708:	fed7fae3          	bgeu	a5,a3,6fc <free+0x30>
 70c:	6398                	ld	a4,0(a5)
 70e:	00e6e463          	bltu	a3,a4,716 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 712:	fee7eae3          	bltu	a5,a4,706 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 716:	ff852583          	lw	a1,-8(a0)
 71a:	6390                	ld	a2,0(a5)
 71c:	02059813          	slli	a6,a1,0x20
 720:	01c85713          	srli	a4,a6,0x1c
 724:	9736                	add	a4,a4,a3
 726:	fae60de3          	beq	a2,a4,6e0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 72a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 72e:	4790                	lw	a2,8(a5)
 730:	02061593          	slli	a1,a2,0x20
 734:	01c5d713          	srli	a4,a1,0x1c
 738:	973e                	add	a4,a4,a5
 73a:	fae68ae3          	beq	a3,a4,6ee <free+0x22>
    p->s.ptr = bp->s.ptr;
 73e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 740:	00001717          	auipc	a4,0x1
 744:	caf73023          	sd	a5,-864(a4) # 13e0 <freep>
}
 748:	6422                	ld	s0,8(sp)
 74a:	0141                	addi	sp,sp,16
 74c:	8082                	ret

000000000000074e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 74e:	7139                	addi	sp,sp,-64
 750:	fc06                	sd	ra,56(sp)
 752:	f822                	sd	s0,48(sp)
 754:	f426                	sd	s1,40(sp)
 756:	ec4e                	sd	s3,24(sp)
 758:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 75a:	02051493          	slli	s1,a0,0x20
 75e:	9081                	srli	s1,s1,0x20
 760:	04bd                	addi	s1,s1,15
 762:	8091                	srli	s1,s1,0x4
 764:	0014899b          	addiw	s3,s1,1
 768:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 76a:	00001517          	auipc	a0,0x1
 76e:	c7653503          	ld	a0,-906(a0) # 13e0 <freep>
 772:	c915                	beqz	a0,7a6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 774:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 776:	4798                	lw	a4,8(a5)
 778:	08977e63          	bgeu	a4,s1,814 <malloc+0xc6>
 77c:	f04a                	sd	s2,32(sp)
 77e:	e852                	sd	s4,16(sp)
 780:	e456                	sd	s5,8(sp)
 782:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 784:	8a4e                	mv	s4,s3
 786:	0009871b          	sext.w	a4,s3
 78a:	6685                	lui	a3,0x1
 78c:	00d77363          	bgeu	a4,a3,792 <malloc+0x44>
 790:	6a05                	lui	s4,0x1
 792:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 796:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 79a:	00001917          	auipc	s2,0x1
 79e:	c4690913          	addi	s2,s2,-954 # 13e0 <freep>
  if(p == (char*)-1)
 7a2:	5afd                	li	s5,-1
 7a4:	a091                	j	7e8 <malloc+0x9a>
 7a6:	f04a                	sd	s2,32(sp)
 7a8:	e852                	sd	s4,16(sp)
 7aa:	e456                	sd	s5,8(sp)
 7ac:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7ae:	00001797          	auipc	a5,0x1
 7b2:	c4278793          	addi	a5,a5,-958 # 13f0 <base>
 7b6:	00001717          	auipc	a4,0x1
 7ba:	c2f73523          	sd	a5,-982(a4) # 13e0 <freep>
 7be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7c4:	b7c1                	j	784 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7c6:	6398                	ld	a4,0(a5)
 7c8:	e118                	sd	a4,0(a0)
 7ca:	a08d                	j	82c <malloc+0xde>
  hp->s.size = nu;
 7cc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7d0:	0541                	addi	a0,a0,16
 7d2:	00000097          	auipc	ra,0x0
 7d6:	efa080e7          	jalr	-262(ra) # 6cc <free>
  return freep;
 7da:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7de:	c13d                	beqz	a0,844 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e2:	4798                	lw	a4,8(a5)
 7e4:	02977463          	bgeu	a4,s1,80c <malloc+0xbe>
    if(p == freep)
 7e8:	00093703          	ld	a4,0(s2)
 7ec:	853e                	mv	a0,a5
 7ee:	fef719e3          	bne	a4,a5,7e0 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7f2:	8552                	mv	a0,s4
 7f4:	00000097          	auipc	ra,0x0
 7f8:	b9a080e7          	jalr	-1126(ra) # 38e <sbrk>
  if(p == (char*)-1)
 7fc:	fd5518e3          	bne	a0,s5,7cc <malloc+0x7e>
        return 0;
 800:	4501                	li	a0,0
 802:	7902                	ld	s2,32(sp)
 804:	6a42                	ld	s4,16(sp)
 806:	6aa2                	ld	s5,8(sp)
 808:	6b02                	ld	s6,0(sp)
 80a:	a03d                	j	838 <malloc+0xea>
 80c:	7902                	ld	s2,32(sp)
 80e:	6a42                	ld	s4,16(sp)
 810:	6aa2                	ld	s5,8(sp)
 812:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 814:	fae489e3          	beq	s1,a4,7c6 <malloc+0x78>
        p->s.size -= nunits;
 818:	4137073b          	subw	a4,a4,s3
 81c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 81e:	02071693          	slli	a3,a4,0x20
 822:	01c6d713          	srli	a4,a3,0x1c
 826:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 828:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 82c:	00001717          	auipc	a4,0x1
 830:	baa73a23          	sd	a0,-1100(a4) # 13e0 <freep>
      return (void*)(p + 1);
 834:	01078513          	addi	a0,a5,16
  }
}
 838:	70e2                	ld	ra,56(sp)
 83a:	7442                	ld	s0,48(sp)
 83c:	74a2                	ld	s1,40(sp)
 83e:	69e2                	ld	s3,24(sp)
 840:	6121                	addi	sp,sp,64
 842:	8082                	ret
 844:	7902                	ld	s2,32(sp)
 846:	6a42                	ld	s4,16(sp)
 848:	6aa2                	ld	s5,8(sp)
 84a:	6b02                	ld	s6,0(sp)
 84c:	b7f5                	j	838 <malloc+0xea>
