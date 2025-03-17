
user/_cowtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <testcase5>:

int global_array[16777216] = {0};
int global_var = 0;

void testcase5()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
    int pid[3];

    printf("\n----- Test case 5 -----\n");
   c:	00001517          	auipc	a0,0x1
  10:	e4450513          	addi	a0,a0,-444 # e50 <malloc+0x102>
  14:	00001097          	auipc	ra,0x1
  18:	c82080e7          	jalr	-894(ra) # c96 <printf>
    printf("[prnt] v1 --> ");
  1c:	00001517          	auipc	a0,0x1
  20:	e5450513          	addi	a0,a0,-428 # e70 <malloc+0x122>
  24:	00001097          	auipc	ra,0x1
  28:	c72080e7          	jalr	-910(ra) # c96 <printf>
    print_free_frame_cnt();
  2c:	00001097          	auipc	ra,0x1
  30:	99a080e7          	jalr	-1638(ra) # 9c6 <pfreepages>

    for (int i = 0; i < 3; ++i)
  34:	fd040493          	addi	s1,s0,-48
  38:	fdc40913          	addi	s2,s0,-36
    {
        if ((pid[i] = fork()) == 0)
  3c:	00001097          	auipc	ra,0x1
  40:	8c2080e7          	jalr	-1854(ra) # 8fe <fork>
  44:	c088                	sw	a0,0(s1)
  46:	c531                	beqz	a0,92 <testcase5+0x92>
            // PARENT
            break;
        }
    }

    sleep(100);
  48:	06400513          	li	a0,100
  4c:	00001097          	auipc	ra,0x1
  50:	94a080e7          	jalr	-1718(ra) # 996 <sleep>
  54:	448d                	li	s1,3

    for (int i = 0; i < 3; ++i)
    {
        int _pid = wait(0);
  56:	4501                	li	a0,0
  58:	00001097          	auipc	ra,0x1
  5c:	8b6080e7          	jalr	-1866(ra) # 90e <wait>
        for (int j = 0; j < 3; ++j)
        {
            if (pid[j] == _pid)
  60:	fd042783          	lw	a5,-48(s0)
  64:	02a78b63          	beq	a5,a0,9a <testcase5+0x9a>
  68:	fd442783          	lw	a5,-44(s0)
  6c:	02a78763          	beq	a5,a0,9a <testcase5+0x9a>
  70:	fd842783          	lw	a5,-40(s0)
  74:	02a78363          	beq	a5,a0,9a <testcase5+0x9a>
            {
                break;
            }
            if (j == 2)
            {
                printf("wait() error!");
  78:	00001517          	auipc	a0,0x1
  7c:	e0850513          	addi	a0,a0,-504 # e80 <malloc+0x132>
  80:	00001097          	auipc	ra,0x1
  84:	c16080e7          	jalr	-1002(ra) # c96 <printf>
                exit(1);
  88:	4505                	li	a0,1
  8a:	00001097          	auipc	ra,0x1
  8e:	87c080e7          	jalr	-1924(ra) # 906 <exit>
    for (int i = 0; i < 3; ++i)
  92:	0491                	addi	s1,s1,4
  94:	fb2494e3          	bne	s1,s2,3c <testcase5+0x3c>
  98:	bf45                	j	48 <testcase5+0x48>
    for (int i = 0; i < 3; ++i)
  9a:	34fd                	addiw	s1,s1,-1
  9c:	fccd                	bnez	s1,56 <testcase5+0x56>
            }
        }
    }

    printf("[prnt] v7 --> ");
  9e:	00001517          	auipc	a0,0x1
  a2:	df250513          	addi	a0,a0,-526 # e90 <malloc+0x142>
  a6:	00001097          	auipc	ra,0x1
  aa:	bf0080e7          	jalr	-1040(ra) # c96 <printf>
    print_free_frame_cnt();
  ae:	00001097          	auipc	ra,0x1
  b2:	918080e7          	jalr	-1768(ra) # 9c6 <pfreepages>
}
  b6:	70a2                	ld	ra,40(sp)
  b8:	7402                	ld	s0,32(sp)
  ba:	64e2                	ld	s1,24(sp)
  bc:	6942                	ld	s2,16(sp)
  be:	6145                	addi	sp,sp,48
  c0:	8082                	ret

00000000000000c2 <testcase4>:

void testcase4()
{
  c2:	1101                	addi	sp,sp,-32
  c4:	ec06                	sd	ra,24(sp)
  c6:	e822                	sd	s0,16(sp)
  c8:	e426                	sd	s1,8(sp)
  ca:	e04a                	sd	s2,0(sp)
  cc:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 4 -----\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	dd250513          	addi	a0,a0,-558 # ea0 <malloc+0x152>
  d6:	00001097          	auipc	ra,0x1
  da:	bc0080e7          	jalr	-1088(ra) # c96 <printf>
    printf("[prnt] v1 --> ");
  de:	00001517          	auipc	a0,0x1
  e2:	d9250513          	addi	a0,a0,-622 # e70 <malloc+0x122>
  e6:	00001097          	auipc	ra,0x1
  ea:	bb0080e7          	jalr	-1104(ra) # c96 <printf>
    print_free_frame_cnt();
  ee:	00001097          	auipc	ra,0x1
  f2:	8d8080e7          	jalr	-1832(ra) # 9c6 <pfreepages>

    if ((pid = fork()) == 0)
  f6:	00001097          	auipc	ra,0x1
  fa:	808080e7          	jalr	-2040(ra) # 8fe <fork>
  fe:	c561                	beqz	a0,1c6 <testcase4+0x104>
 100:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 102:	00001517          	auipc	a0,0x1
 106:	ece50513          	addi	a0,a0,-306 # fd0 <malloc+0x282>
 10a:	00001097          	auipc	ra,0x1
 10e:	b8c080e7          	jalr	-1140(ra) # c96 <printf>
        print_free_frame_cnt();
 112:	00001097          	auipc	ra,0x1
 116:	8b4080e7          	jalr	-1868(ra) # 9c6 <pfreepages>

        global_array[0] = 111;
 11a:	00002917          	auipc	s2,0x2
 11e:	3d690913          	addi	s2,s2,982 # 24f0 <global_array>
 122:	06f00793          	li	a5,111
 126:	00f92023          	sw	a5,0(s2)
        printf("[prnt] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 12a:	06f00593          	li	a1,111
 12e:	00001517          	auipc	a0,0x1
 132:	eb250513          	addi	a0,a0,-334 # fe0 <malloc+0x292>
 136:	00001097          	auipc	ra,0x1
 13a:	b60080e7          	jalr	-1184(ra) # c96 <printf>

        printf("[prnt] v3 --> ");
 13e:	00001517          	auipc	a0,0x1
 142:	eea50513          	addi	a0,a0,-278 # 1028 <malloc+0x2da>
 146:	00001097          	auipc	ra,0x1
 14a:	b50080e7          	jalr	-1200(ra) # c96 <printf>
        print_free_frame_cnt();
 14e:	00001097          	auipc	ra,0x1
 152:	878080e7          	jalr	-1928(ra) # 9c6 <pfreepages>
        printf("[prnt] pa3 --> 0x%x\n", va2pa((uint64)&global_array[0], getpid()));
 156:	00001097          	auipc	ra,0x1
 15a:	830080e7          	jalr	-2000(ra) # 986 <getpid>
 15e:	85aa                	mv	a1,a0
 160:	854a                	mv	a0,s2
 162:	00001097          	auipc	ra,0x1
 166:	85c080e7          	jalr	-1956(ra) # 9be <va2pa>
 16a:	85aa                	mv	a1,a0
 16c:	00001517          	auipc	a0,0x1
 170:	ecc50513          	addi	a0,a0,-308 # 1038 <malloc+0x2ea>
 174:	00001097          	auipc	ra,0x1
 178:	b22080e7          	jalr	-1246(ra) # c96 <printf>
    }

    if (wait(0) != pid)
 17c:	4501                	li	a0,0
 17e:	00000097          	auipc	ra,0x0
 182:	790080e7          	jalr	1936(ra) # 90e <wait>
 186:	12951f63          	bne	a0,s1,2c4 <testcase4+0x202>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] global_array[0] --> %d\n", global_array[0]);
 18a:	00002597          	auipc	a1,0x2
 18e:	3665a583          	lw	a1,870(a1) # 24f0 <global_array>
 192:	00001517          	auipc	a0,0x1
 196:	ebe50513          	addi	a0,a0,-322 # 1050 <malloc+0x302>
 19a:	00001097          	auipc	ra,0x1
 19e:	afc080e7          	jalr	-1284(ra) # c96 <printf>

    printf("[prnt] v7 --> ");
 1a2:	00001517          	auipc	a0,0x1
 1a6:	cee50513          	addi	a0,a0,-786 # e90 <malloc+0x142>
 1aa:	00001097          	auipc	ra,0x1
 1ae:	aec080e7          	jalr	-1300(ra) # c96 <printf>
    print_free_frame_cnt();
 1b2:	00001097          	auipc	ra,0x1
 1b6:	814080e7          	jalr	-2028(ra) # 9c6 <pfreepages>
}
 1ba:	60e2                	ld	ra,24(sp)
 1bc:	6442                	ld	s0,16(sp)
 1be:	64a2                	ld	s1,8(sp)
 1c0:	6902                	ld	s2,0(sp)
 1c2:	6105                	addi	sp,sp,32
 1c4:	8082                	ret
        sleep(50);
 1c6:	03200513          	li	a0,50
 1ca:	00000097          	auipc	ra,0x0
 1ce:	7cc080e7          	jalr	1996(ra) # 996 <sleep>
        printf("[chld] pa1 --> 0x%x\n", va2pa((uint64)&global_array[0], getpid()));
 1d2:	00002497          	auipc	s1,0x2
 1d6:	31e48493          	addi	s1,s1,798 # 24f0 <global_array>
 1da:	00000097          	auipc	ra,0x0
 1de:	7ac080e7          	jalr	1964(ra) # 986 <getpid>
 1e2:	85aa                	mv	a1,a0
 1e4:	8526                	mv	a0,s1
 1e6:	00000097          	auipc	ra,0x0
 1ea:	7d8080e7          	jalr	2008(ra) # 9be <va2pa>
 1ee:	85aa                	mv	a1,a0
 1f0:	00001517          	auipc	a0,0x1
 1f4:	cd050513          	addi	a0,a0,-816 # ec0 <malloc+0x172>
 1f8:	00001097          	auipc	ra,0x1
 1fc:	a9e080e7          	jalr	-1378(ra) # c96 <printf>
        printf("[chld] v4 --> ");
 200:	00001517          	auipc	a0,0x1
 204:	cd850513          	addi	a0,a0,-808 # ed8 <malloc+0x18a>
 208:	00001097          	auipc	ra,0x1
 20c:	a8e080e7          	jalr	-1394(ra) # c96 <printf>
        print_free_frame_cnt();
 210:	00000097          	auipc	ra,0x0
 214:	7b6080e7          	jalr	1974(ra) # 9c6 <pfreepages>
        global_array[0] = 222;
 218:	0de00793          	li	a5,222
 21c:	c09c                	sw	a5,0(s1)
        printf("[chld] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 21e:	0de00593          	li	a1,222
 222:	00001517          	auipc	a0,0x1
 226:	cc650513          	addi	a0,a0,-826 # ee8 <malloc+0x19a>
 22a:	00001097          	auipc	ra,0x1
 22e:	a6c080e7          	jalr	-1428(ra) # c96 <printf>
        printf("[chld] pa2 --> 0x%x\n", va2pa((uint64)&global_array[0], getpid()));
 232:	00000097          	auipc	ra,0x0
 236:	754080e7          	jalr	1876(ra) # 986 <getpid>
 23a:	85aa                	mv	a1,a0
 23c:	8526                	mv	a0,s1
 23e:	00000097          	auipc	ra,0x0
 242:	780080e7          	jalr	1920(ra) # 9be <va2pa>
 246:	85aa                	mv	a1,a0
 248:	00001517          	auipc	a0,0x1
 24c:	ce850513          	addi	a0,a0,-792 # f30 <malloc+0x1e2>
 250:	00001097          	auipc	ra,0x1
 254:	a46080e7          	jalr	-1466(ra) # c96 <printf>
        printf("[chld] v5 --> ");
 258:	00001517          	auipc	a0,0x1
 25c:	cf050513          	addi	a0,a0,-784 # f48 <malloc+0x1fa>
 260:	00001097          	auipc	ra,0x1
 264:	a36080e7          	jalr	-1482(ra) # c96 <printf>
        print_free_frame_cnt();
 268:	00000097          	auipc	ra,0x0
 26c:	75e080e7          	jalr	1886(ra) # 9c6 <pfreepages>
        global_array[2047] = 333;
 270:	14d00793          	li	a5,333
 274:	00004717          	auipc	a4,0x4
 278:	26f72c23          	sw	a5,632(a4) # 44ec <global_array+0x1ffc>
        printf("[chld] modified two elements in the 2nd page, global_array[2047]=%d\n", global_array[2047]);
 27c:	14d00593          	li	a1,333
 280:	00001517          	auipc	a0,0x1
 284:	cd850513          	addi	a0,a0,-808 # f58 <malloc+0x20a>
 288:	00001097          	auipc	ra,0x1
 28c:	a0e080e7          	jalr	-1522(ra) # c96 <printf>
        printf("[chld] v6 --> ");
 290:	00001517          	auipc	a0,0x1
 294:	d1050513          	addi	a0,a0,-752 # fa0 <malloc+0x252>
 298:	00001097          	auipc	ra,0x1
 29c:	9fe080e7          	jalr	-1538(ra) # c96 <printf>
        print_free_frame_cnt();
 2a0:	00000097          	auipc	ra,0x0
 2a4:	726080e7          	jalr	1830(ra) # 9c6 <pfreepages>
        printf("[chld] global_array[0] --> %d\n", global_array[0]);
 2a8:	408c                	lw	a1,0(s1)
 2aa:	00001517          	auipc	a0,0x1
 2ae:	d0650513          	addi	a0,a0,-762 # fb0 <malloc+0x262>
 2b2:	00001097          	auipc	ra,0x1
 2b6:	9e4080e7          	jalr	-1564(ra) # c96 <printf>
        exit(0);
 2ba:	4501                	li	a0,0
 2bc:	00000097          	auipc	ra,0x0
 2c0:	64a080e7          	jalr	1610(ra) # 906 <exit>
        printf("wait() error!");
 2c4:	00001517          	auipc	a0,0x1
 2c8:	bbc50513          	addi	a0,a0,-1092 # e80 <malloc+0x132>
 2cc:	00001097          	auipc	ra,0x1
 2d0:	9ca080e7          	jalr	-1590(ra) # c96 <printf>
        exit(1);
 2d4:	4505                	li	a0,1
 2d6:	00000097          	auipc	ra,0x0
 2da:	630080e7          	jalr	1584(ra) # 906 <exit>

00000000000002de <testcase3>:

void testcase3()
{
 2de:	1101                	addi	sp,sp,-32
 2e0:	ec06                	sd	ra,24(sp)
 2e2:	e822                	sd	s0,16(sp)
 2e4:	e426                	sd	s1,8(sp)
 2e6:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 3 -----\n");
 2e8:	00001517          	auipc	a0,0x1
 2ec:	d8850513          	addi	a0,a0,-632 # 1070 <malloc+0x322>
 2f0:	00001097          	auipc	ra,0x1
 2f4:	9a6080e7          	jalr	-1626(ra) # c96 <printf>
    printf("[prnt] v1 --> ");
 2f8:	00001517          	auipc	a0,0x1
 2fc:	b7850513          	addi	a0,a0,-1160 # e70 <malloc+0x122>
 300:	00001097          	auipc	ra,0x1
 304:	996080e7          	jalr	-1642(ra) # c96 <printf>
    print_free_frame_cnt();
 308:	00000097          	auipc	ra,0x0
 30c:	6be080e7          	jalr	1726(ra) # 9c6 <pfreepages>

    if ((pid = fork()) == 0)
 310:	00000097          	auipc	ra,0x0
 314:	5ee080e7          	jalr	1518(ra) # 8fe <fork>
 318:	cd35                	beqz	a0,394 <testcase3+0xb6>
 31a:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 31c:	00001517          	auipc	a0,0x1
 320:	cb450513          	addi	a0,a0,-844 # fd0 <malloc+0x282>
 324:	00001097          	auipc	ra,0x1
 328:	972080e7          	jalr	-1678(ra) # c96 <printf>
        print_free_frame_cnt();
 32c:	00000097          	auipc	ra,0x0
 330:	69a080e7          	jalr	1690(ra) # 9c6 <pfreepages>

        printf("[prnt] read global_var, global_var=%d\n", global_var);
 334:	00002597          	auipc	a1,0x2
 338:	1ac5a583          	lw	a1,428(a1) # 24e0 <global_var>
 33c:	00001517          	auipc	a0,0x1
 340:	d8450513          	addi	a0,a0,-636 # 10c0 <malloc+0x372>
 344:	00001097          	auipc	ra,0x1
 348:	952080e7          	jalr	-1710(ra) # c96 <printf>

        printf("[prnt] v3 --> ");
 34c:	00001517          	auipc	a0,0x1
 350:	cdc50513          	addi	a0,a0,-804 # 1028 <malloc+0x2da>
 354:	00001097          	auipc	ra,0x1
 358:	942080e7          	jalr	-1726(ra) # c96 <printf>
        print_free_frame_cnt();
 35c:	00000097          	auipc	ra,0x0
 360:	66a080e7          	jalr	1642(ra) # 9c6 <pfreepages>
    }

    if (wait(0) != pid)
 364:	4501                	li	a0,0
 366:	00000097          	auipc	ra,0x0
 36a:	5a8080e7          	jalr	1448(ra) # 90e <wait>
 36e:	08951663          	bne	a0,s1,3fa <testcase3+0x11c>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v6 --> ");
 372:	00001517          	auipc	a0,0x1
 376:	d7650513          	addi	a0,a0,-650 # 10e8 <malloc+0x39a>
 37a:	00001097          	auipc	ra,0x1
 37e:	91c080e7          	jalr	-1764(ra) # c96 <printf>
    print_free_frame_cnt();
 382:	00000097          	auipc	ra,0x0
 386:	644080e7          	jalr	1604(ra) # 9c6 <pfreepages>
}
 38a:	60e2                	ld	ra,24(sp)
 38c:	6442                	ld	s0,16(sp)
 38e:	64a2                	ld	s1,8(sp)
 390:	6105                	addi	sp,sp,32
 392:	8082                	ret
        sleep(50);
 394:	03200513          	li	a0,50
 398:	00000097          	auipc	ra,0x0
 39c:	5fe080e7          	jalr	1534(ra) # 996 <sleep>
        printf("[chld] v4 --> ");
 3a0:	00001517          	auipc	a0,0x1
 3a4:	b3850513          	addi	a0,a0,-1224 # ed8 <malloc+0x18a>
 3a8:	00001097          	auipc	ra,0x1
 3ac:	8ee080e7          	jalr	-1810(ra) # c96 <printf>
        print_free_frame_cnt();
 3b0:	00000097          	auipc	ra,0x0
 3b4:	616080e7          	jalr	1558(ra) # 9c6 <pfreepages>
        global_var = 100;
 3b8:	06400793          	li	a5,100
 3bc:	00002717          	auipc	a4,0x2
 3c0:	12f72223          	sw	a5,292(a4) # 24e0 <global_var>
        printf("[chld] modified global_var, global_var=%d\n", global_var);
 3c4:	06400593          	li	a1,100
 3c8:	00001517          	auipc	a0,0x1
 3cc:	cc850513          	addi	a0,a0,-824 # 1090 <malloc+0x342>
 3d0:	00001097          	auipc	ra,0x1
 3d4:	8c6080e7          	jalr	-1850(ra) # c96 <printf>
        printf("[chld] v5 --> ");
 3d8:	00001517          	auipc	a0,0x1
 3dc:	b7050513          	addi	a0,a0,-1168 # f48 <malloc+0x1fa>
 3e0:	00001097          	auipc	ra,0x1
 3e4:	8b6080e7          	jalr	-1866(ra) # c96 <printf>
        print_free_frame_cnt();
 3e8:	00000097          	auipc	ra,0x0
 3ec:	5de080e7          	jalr	1502(ra) # 9c6 <pfreepages>
        exit(0);
 3f0:	4501                	li	a0,0
 3f2:	00000097          	auipc	ra,0x0
 3f6:	514080e7          	jalr	1300(ra) # 906 <exit>
        printf("wait() error!");
 3fa:	00001517          	auipc	a0,0x1
 3fe:	a8650513          	addi	a0,a0,-1402 # e80 <malloc+0x132>
 402:	00001097          	auipc	ra,0x1
 406:	894080e7          	jalr	-1900(ra) # c96 <printf>
        exit(1);
 40a:	4505                	li	a0,1
 40c:	00000097          	auipc	ra,0x0
 410:	4fa080e7          	jalr	1274(ra) # 906 <exit>

0000000000000414 <testcase2>:

void testcase2()
{
 414:	1101                	addi	sp,sp,-32
 416:	ec06                	sd	ra,24(sp)
 418:	e822                	sd	s0,16(sp)
 41a:	e426                	sd	s1,8(sp)
 41c:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 2 -----\n");
 41e:	00001517          	auipc	a0,0x1
 422:	cda50513          	addi	a0,a0,-806 # 10f8 <malloc+0x3aa>
 426:	00001097          	auipc	ra,0x1
 42a:	870080e7          	jalr	-1936(ra) # c96 <printf>
    printf("[prnt] v1 --> ");
 42e:	00001517          	auipc	a0,0x1
 432:	a4250513          	addi	a0,a0,-1470 # e70 <malloc+0x122>
 436:	00001097          	auipc	ra,0x1
 43a:	860080e7          	jalr	-1952(ra) # c96 <printf>
    print_free_frame_cnt();
 43e:	00000097          	auipc	ra,0x0
 442:	588080e7          	jalr	1416(ra) # 9c6 <pfreepages>

    if ((pid = fork()) == 0)
 446:	00000097          	auipc	ra,0x0
 44a:	4b8080e7          	jalr	1208(ra) # 8fe <fork>
 44e:	c531                	beqz	a0,49a <testcase2+0x86>
 450:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 452:	00001517          	auipc	a0,0x1
 456:	b7e50513          	addi	a0,a0,-1154 # fd0 <malloc+0x282>
 45a:	00001097          	auipc	ra,0x1
 45e:	83c080e7          	jalr	-1988(ra) # c96 <printf>
        print_free_frame_cnt();
 462:	00000097          	auipc	ra,0x0
 466:	564080e7          	jalr	1380(ra) # 9c6 <pfreepages>
    }

    if (wait(0) != pid)
 46a:	4501                	li	a0,0
 46c:	00000097          	auipc	ra,0x0
 470:	4a2080e7          	jalr	1186(ra) # 90e <wait>
 474:	08951263          	bne	a0,s1,4f8 <testcase2+0xe4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v5 --> ");
 478:	00001517          	auipc	a0,0x1
 47c:	cd850513          	addi	a0,a0,-808 # 1150 <malloc+0x402>
 480:	00001097          	auipc	ra,0x1
 484:	816080e7          	jalr	-2026(ra) # c96 <printf>
    print_free_frame_cnt();
 488:	00000097          	auipc	ra,0x0
 48c:	53e080e7          	jalr	1342(ra) # 9c6 <pfreepages>
}
 490:	60e2                	ld	ra,24(sp)
 492:	6442                	ld	s0,16(sp)
 494:	64a2                	ld	s1,8(sp)
 496:	6105                	addi	sp,sp,32
 498:	8082                	ret
        sleep(50);
 49a:	03200513          	li	a0,50
 49e:	00000097          	auipc	ra,0x0
 4a2:	4f8080e7          	jalr	1272(ra) # 996 <sleep>
        printf("[chld] v3 --> ");
 4a6:	00001517          	auipc	a0,0x1
 4aa:	c7250513          	addi	a0,a0,-910 # 1118 <malloc+0x3ca>
 4ae:	00000097          	auipc	ra,0x0
 4b2:	7e8080e7          	jalr	2024(ra) # c96 <printf>
        print_free_frame_cnt();
 4b6:	00000097          	auipc	ra,0x0
 4ba:	510080e7          	jalr	1296(ra) # 9c6 <pfreepages>
        printf("[chld] read global_var, global_var=%d\n", global_var);
 4be:	00002597          	auipc	a1,0x2
 4c2:	0225a583          	lw	a1,34(a1) # 24e0 <global_var>
 4c6:	00001517          	auipc	a0,0x1
 4ca:	c6250513          	addi	a0,a0,-926 # 1128 <malloc+0x3da>
 4ce:	00000097          	auipc	ra,0x0
 4d2:	7c8080e7          	jalr	1992(ra) # c96 <printf>
        printf("[chld] v4 --> ");
 4d6:	00001517          	auipc	a0,0x1
 4da:	a0250513          	addi	a0,a0,-1534 # ed8 <malloc+0x18a>
 4de:	00000097          	auipc	ra,0x0
 4e2:	7b8080e7          	jalr	1976(ra) # c96 <printf>
        print_free_frame_cnt();
 4e6:	00000097          	auipc	ra,0x0
 4ea:	4e0080e7          	jalr	1248(ra) # 9c6 <pfreepages>
        exit(0);
 4ee:	4501                	li	a0,0
 4f0:	00000097          	auipc	ra,0x0
 4f4:	416080e7          	jalr	1046(ra) # 906 <exit>
        printf("wait() error!");
 4f8:	00001517          	auipc	a0,0x1
 4fc:	98850513          	addi	a0,a0,-1656 # e80 <malloc+0x132>
 500:	00000097          	auipc	ra,0x0
 504:	796080e7          	jalr	1942(ra) # c96 <printf>
        exit(1);
 508:	4505                	li	a0,1
 50a:	00000097          	auipc	ra,0x0
 50e:	3fc080e7          	jalr	1020(ra) # 906 <exit>

0000000000000512 <testcase1>:

void testcase1()
{
 512:	1101                	addi	sp,sp,-32
 514:	ec06                	sd	ra,24(sp)
 516:	e822                	sd	s0,16(sp)
 518:	e426                	sd	s1,8(sp)
 51a:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 1 -----\n");
 51c:	00001517          	auipc	a0,0x1
 520:	c4450513          	addi	a0,a0,-956 # 1160 <malloc+0x412>
 524:	00000097          	auipc	ra,0x0
 528:	772080e7          	jalr	1906(ra) # c96 <printf>
    printf("[prnt] v1 --> ");
 52c:	00001517          	auipc	a0,0x1
 530:	94450513          	addi	a0,a0,-1724 # e70 <malloc+0x122>
 534:	00000097          	auipc	ra,0x0
 538:	762080e7          	jalr	1890(ra) # c96 <printf>
    print_free_frame_cnt();
 53c:	00000097          	auipc	ra,0x0
 540:	48a080e7          	jalr	1162(ra) # 9c6 <pfreepages>

    if ((pid = fork()) == 0)
 544:	00000097          	auipc	ra,0x0
 548:	3ba080e7          	jalr	954(ra) # 8fe <fork>
 54c:	c531                	beqz	a0,598 <testcase1+0x86>
 54e:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v3 --> ");
 550:	00001517          	auipc	a0,0x1
 554:	ad850513          	addi	a0,a0,-1320 # 1028 <malloc+0x2da>
 558:	00000097          	auipc	ra,0x0
 55c:	73e080e7          	jalr	1854(ra) # c96 <printf>
        print_free_frame_cnt();
 560:	00000097          	auipc	ra,0x0
 564:	466080e7          	jalr	1126(ra) # 9c6 <pfreepages>
    }

    if (wait(0) != pid)
 568:	4501                	li	a0,0
 56a:	00000097          	auipc	ra,0x0
 56e:	3a4080e7          	jalr	932(ra) # 90e <wait>
 572:	04951a63          	bne	a0,s1,5c6 <testcase1+0xb4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v4 --> ");
 576:	00001517          	auipc	a0,0x1
 57a:	c1a50513          	addi	a0,a0,-998 # 1190 <malloc+0x442>
 57e:	00000097          	auipc	ra,0x0
 582:	718080e7          	jalr	1816(ra) # c96 <printf>
    print_free_frame_cnt();
 586:	00000097          	auipc	ra,0x0
 58a:	440080e7          	jalr	1088(ra) # 9c6 <pfreepages>
}
 58e:	60e2                	ld	ra,24(sp)
 590:	6442                	ld	s0,16(sp)
 592:	64a2                	ld	s1,8(sp)
 594:	6105                	addi	sp,sp,32
 596:	8082                	ret
        sleep(50);
 598:	03200513          	li	a0,50
 59c:	00000097          	auipc	ra,0x0
 5a0:	3fa080e7          	jalr	1018(ra) # 996 <sleep>
        printf("[chld] v2 --> ");
 5a4:	00001517          	auipc	a0,0x1
 5a8:	bdc50513          	addi	a0,a0,-1060 # 1180 <malloc+0x432>
 5ac:	00000097          	auipc	ra,0x0
 5b0:	6ea080e7          	jalr	1770(ra) # c96 <printf>
        print_free_frame_cnt();
 5b4:	00000097          	auipc	ra,0x0
 5b8:	412080e7          	jalr	1042(ra) # 9c6 <pfreepages>
        exit(0);
 5bc:	4501                	li	a0,0
 5be:	00000097          	auipc	ra,0x0
 5c2:	348080e7          	jalr	840(ra) # 906 <exit>
        printf("wait() error!");
 5c6:	00001517          	auipc	a0,0x1
 5ca:	8ba50513          	addi	a0,a0,-1862 # e80 <malloc+0x132>
 5ce:	00000097          	auipc	ra,0x0
 5d2:	6c8080e7          	jalr	1736(ra) # c96 <printf>
        exit(1);
 5d6:	4505                	li	a0,1
 5d8:	00000097          	auipc	ra,0x0
 5dc:	32e080e7          	jalr	814(ra) # 906 <exit>

00000000000005e0 <main>:

int main(int argc, char *argv[])
{
 5e0:	1101                	addi	sp,sp,-32
 5e2:	ec06                	sd	ra,24(sp)
 5e4:	e822                	sd	s0,16(sp)
 5e6:	e426                	sd	s1,8(sp)
 5e8:	1000                	addi	s0,sp,32
    if (argc < 2)
 5ea:	4785                	li	a5,1
 5ec:	02a7d963          	bge	a5,a0,61e <main+0x3e>
 5f0:	84ae                	mv	s1,a1
    {
        printf("Usage: cowtest test_id\n");
        exit(-1);
    }
    switch (atoi(argv[1]))
 5f2:	6588                	ld	a0,8(a1)
 5f4:	00000097          	auipc	ra,0x0
 5f8:	218080e7          	jalr	536(ra) # 80c <atoi>
 5fc:	478d                	li	a5,3
 5fe:	06f50063          	beq	a0,a5,65e <main+0x7e>
 602:	02a7cb63          	blt	a5,a0,638 <main+0x58>
 606:	4785                	li	a5,1
 608:	04f50163          	beq	a0,a5,64a <main+0x6a>
 60c:	4789                	li	a5,2
 60e:	04f51e63          	bne	a0,a5,66a <main+0x8a>
    case 1:
        testcase1();
        break;

    case 2:
        testcase2();
 612:	00000097          	auipc	ra,0x0
 616:	e02080e7          	jalr	-510(ra) # 414 <testcase2>

    default:
        printf("Error: No test with index %s\n", argv[1]);
        return 1;
    }
    return 0;
 61a:	4501                	li	a0,0
        break;
 61c:	a825                	j	654 <main+0x74>
        printf("Usage: cowtest test_id\n");
 61e:	00001517          	auipc	a0,0x1
 622:	b8250513          	addi	a0,a0,-1150 # 11a0 <malloc+0x452>
 626:	00000097          	auipc	ra,0x0
 62a:	670080e7          	jalr	1648(ra) # c96 <printf>
        exit(-1);
 62e:	557d                	li	a0,-1
 630:	00000097          	auipc	ra,0x0
 634:	2d6080e7          	jalr	726(ra) # 906 <exit>
    switch (atoi(argv[1]))
 638:	4791                	li	a5,4
 63a:	02f51863          	bne	a0,a5,66a <main+0x8a>
        testcase4();
 63e:	00000097          	auipc	ra,0x0
 642:	a84080e7          	jalr	-1404(ra) # c2 <testcase4>
    return 0;
 646:	4501                	li	a0,0
        break;
 648:	a031                	j	654 <main+0x74>
        testcase1();
 64a:	00000097          	auipc	ra,0x0
 64e:	ec8080e7          	jalr	-312(ra) # 512 <testcase1>
    return 0;
 652:	4501                	li	a0,0
 654:	60e2                	ld	ra,24(sp)
 656:	6442                	ld	s0,16(sp)
 658:	64a2                	ld	s1,8(sp)
 65a:	6105                	addi	sp,sp,32
 65c:	8082                	ret
        testcase3();
 65e:	00000097          	auipc	ra,0x0
 662:	c80080e7          	jalr	-896(ra) # 2de <testcase3>
    return 0;
 666:	4501                	li	a0,0
        break;
 668:	b7f5                	j	654 <main+0x74>
        printf("Error: No test with index %s\n", argv[1]);
 66a:	648c                	ld	a1,8(s1)
 66c:	00001517          	auipc	a0,0x1
 670:	b4c50513          	addi	a0,a0,-1204 # 11b8 <malloc+0x46a>
 674:	00000097          	auipc	ra,0x0
 678:	622080e7          	jalr	1570(ra) # c96 <printf>
        return 1;
 67c:	4505                	li	a0,1
 67e:	bfd9                	j	654 <main+0x74>

0000000000000680 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 680:	1141                	addi	sp,sp,-16
 682:	e406                	sd	ra,8(sp)
 684:	e022                	sd	s0,0(sp)
 686:	0800                	addi	s0,sp,16
  extern int main();
  main();
 688:	00000097          	auipc	ra,0x0
 68c:	f58080e7          	jalr	-168(ra) # 5e0 <main>
  exit(0);
 690:	4501                	li	a0,0
 692:	00000097          	auipc	ra,0x0
 696:	274080e7          	jalr	628(ra) # 906 <exit>

000000000000069a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 69a:	1141                	addi	sp,sp,-16
 69c:	e422                	sd	s0,8(sp)
 69e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 6a0:	87aa                	mv	a5,a0
 6a2:	0585                	addi	a1,a1,1
 6a4:	0785                	addi	a5,a5,1
 6a6:	fff5c703          	lbu	a4,-1(a1)
 6aa:	fee78fa3          	sb	a4,-1(a5)
 6ae:	fb75                	bnez	a4,6a2 <strcpy+0x8>
    ;
  return os;
}
 6b0:	6422                	ld	s0,8(sp)
 6b2:	0141                	addi	sp,sp,16
 6b4:	8082                	ret

00000000000006b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 6b6:	1141                	addi	sp,sp,-16
 6b8:	e422                	sd	s0,8(sp)
 6ba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 6bc:	00054783          	lbu	a5,0(a0)
 6c0:	cb91                	beqz	a5,6d4 <strcmp+0x1e>
 6c2:	0005c703          	lbu	a4,0(a1)
 6c6:	00f71763          	bne	a4,a5,6d4 <strcmp+0x1e>
    p++, q++;
 6ca:	0505                	addi	a0,a0,1
 6cc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 6ce:	00054783          	lbu	a5,0(a0)
 6d2:	fbe5                	bnez	a5,6c2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 6d4:	0005c503          	lbu	a0,0(a1)
}
 6d8:	40a7853b          	subw	a0,a5,a0
 6dc:	6422                	ld	s0,8(sp)
 6de:	0141                	addi	sp,sp,16
 6e0:	8082                	ret

00000000000006e2 <strlen>:

uint
strlen(const char *s)
{
 6e2:	1141                	addi	sp,sp,-16
 6e4:	e422                	sd	s0,8(sp)
 6e6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 6e8:	00054783          	lbu	a5,0(a0)
 6ec:	cf91                	beqz	a5,708 <strlen+0x26>
 6ee:	0505                	addi	a0,a0,1
 6f0:	87aa                	mv	a5,a0
 6f2:	86be                	mv	a3,a5
 6f4:	0785                	addi	a5,a5,1
 6f6:	fff7c703          	lbu	a4,-1(a5)
 6fa:	ff65                	bnez	a4,6f2 <strlen+0x10>
 6fc:	40a6853b          	subw	a0,a3,a0
 700:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 702:	6422                	ld	s0,8(sp)
 704:	0141                	addi	sp,sp,16
 706:	8082                	ret
  for(n = 0; s[n]; n++)
 708:	4501                	li	a0,0
 70a:	bfe5                	j	702 <strlen+0x20>

000000000000070c <memset>:

void*
memset(void *dst, int c, uint n)
{
 70c:	1141                	addi	sp,sp,-16
 70e:	e422                	sd	s0,8(sp)
 710:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 712:	ca19                	beqz	a2,728 <memset+0x1c>
 714:	87aa                	mv	a5,a0
 716:	1602                	slli	a2,a2,0x20
 718:	9201                	srli	a2,a2,0x20
 71a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 71e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 722:	0785                	addi	a5,a5,1
 724:	fee79de3          	bne	a5,a4,71e <memset+0x12>
  }
  return dst;
}
 728:	6422                	ld	s0,8(sp)
 72a:	0141                	addi	sp,sp,16
 72c:	8082                	ret

000000000000072e <strchr>:

char*
strchr(const char *s, char c)
{
 72e:	1141                	addi	sp,sp,-16
 730:	e422                	sd	s0,8(sp)
 732:	0800                	addi	s0,sp,16
  for(; *s; s++)
 734:	00054783          	lbu	a5,0(a0)
 738:	cb99                	beqz	a5,74e <strchr+0x20>
    if(*s == c)
 73a:	00f58763          	beq	a1,a5,748 <strchr+0x1a>
  for(; *s; s++)
 73e:	0505                	addi	a0,a0,1
 740:	00054783          	lbu	a5,0(a0)
 744:	fbfd                	bnez	a5,73a <strchr+0xc>
      return (char*)s;
  return 0;
 746:	4501                	li	a0,0
}
 748:	6422                	ld	s0,8(sp)
 74a:	0141                	addi	sp,sp,16
 74c:	8082                	ret
  return 0;
 74e:	4501                	li	a0,0
 750:	bfe5                	j	748 <strchr+0x1a>

0000000000000752 <gets>:

char*
gets(char *buf, int max)
{
 752:	711d                	addi	sp,sp,-96
 754:	ec86                	sd	ra,88(sp)
 756:	e8a2                	sd	s0,80(sp)
 758:	e4a6                	sd	s1,72(sp)
 75a:	e0ca                	sd	s2,64(sp)
 75c:	fc4e                	sd	s3,56(sp)
 75e:	f852                	sd	s4,48(sp)
 760:	f456                	sd	s5,40(sp)
 762:	f05a                	sd	s6,32(sp)
 764:	ec5e                	sd	s7,24(sp)
 766:	1080                	addi	s0,sp,96
 768:	8baa                	mv	s7,a0
 76a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 76c:	892a                	mv	s2,a0
 76e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 770:	4aa9                	li	s5,10
 772:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 774:	89a6                	mv	s3,s1
 776:	2485                	addiw	s1,s1,1
 778:	0344d863          	bge	s1,s4,7a8 <gets+0x56>
    cc = read(0, &c, 1);
 77c:	4605                	li	a2,1
 77e:	faf40593          	addi	a1,s0,-81
 782:	4501                	li	a0,0
 784:	00000097          	auipc	ra,0x0
 788:	19a080e7          	jalr	410(ra) # 91e <read>
    if(cc < 1)
 78c:	00a05e63          	blez	a0,7a8 <gets+0x56>
    buf[i++] = c;
 790:	faf44783          	lbu	a5,-81(s0)
 794:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 798:	01578763          	beq	a5,s5,7a6 <gets+0x54>
 79c:	0905                	addi	s2,s2,1
 79e:	fd679be3          	bne	a5,s6,774 <gets+0x22>
    buf[i++] = c;
 7a2:	89a6                	mv	s3,s1
 7a4:	a011                	j	7a8 <gets+0x56>
 7a6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 7a8:	99de                	add	s3,s3,s7
 7aa:	00098023          	sb	zero,0(s3)
  return buf;
}
 7ae:	855e                	mv	a0,s7
 7b0:	60e6                	ld	ra,88(sp)
 7b2:	6446                	ld	s0,80(sp)
 7b4:	64a6                	ld	s1,72(sp)
 7b6:	6906                	ld	s2,64(sp)
 7b8:	79e2                	ld	s3,56(sp)
 7ba:	7a42                	ld	s4,48(sp)
 7bc:	7aa2                	ld	s5,40(sp)
 7be:	7b02                	ld	s6,32(sp)
 7c0:	6be2                	ld	s7,24(sp)
 7c2:	6125                	addi	sp,sp,96
 7c4:	8082                	ret

00000000000007c6 <stat>:

int
stat(const char *n, struct stat *st)
{
 7c6:	1101                	addi	sp,sp,-32
 7c8:	ec06                	sd	ra,24(sp)
 7ca:	e822                	sd	s0,16(sp)
 7cc:	e04a                	sd	s2,0(sp)
 7ce:	1000                	addi	s0,sp,32
 7d0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7d2:	4581                	li	a1,0
 7d4:	00000097          	auipc	ra,0x0
 7d8:	172080e7          	jalr	370(ra) # 946 <open>
  if(fd < 0)
 7dc:	02054663          	bltz	a0,808 <stat+0x42>
 7e0:	e426                	sd	s1,8(sp)
 7e2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 7e4:	85ca                	mv	a1,s2
 7e6:	00000097          	auipc	ra,0x0
 7ea:	178080e7          	jalr	376(ra) # 95e <fstat>
 7ee:	892a                	mv	s2,a0
  close(fd);
 7f0:	8526                	mv	a0,s1
 7f2:	00000097          	auipc	ra,0x0
 7f6:	13c080e7          	jalr	316(ra) # 92e <close>
  return r;
 7fa:	64a2                	ld	s1,8(sp)
}
 7fc:	854a                	mv	a0,s2
 7fe:	60e2                	ld	ra,24(sp)
 800:	6442                	ld	s0,16(sp)
 802:	6902                	ld	s2,0(sp)
 804:	6105                	addi	sp,sp,32
 806:	8082                	ret
    return -1;
 808:	597d                	li	s2,-1
 80a:	bfcd                	j	7fc <stat+0x36>

000000000000080c <atoi>:

int
atoi(const char *s)
{
 80c:	1141                	addi	sp,sp,-16
 80e:	e422                	sd	s0,8(sp)
 810:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 812:	00054683          	lbu	a3,0(a0)
 816:	fd06879b          	addiw	a5,a3,-48
 81a:	0ff7f793          	zext.b	a5,a5
 81e:	4625                	li	a2,9
 820:	02f66863          	bltu	a2,a5,850 <atoi+0x44>
 824:	872a                	mv	a4,a0
  n = 0;
 826:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 828:	0705                	addi	a4,a4,1
 82a:	0025179b          	slliw	a5,a0,0x2
 82e:	9fa9                	addw	a5,a5,a0
 830:	0017979b          	slliw	a5,a5,0x1
 834:	9fb5                	addw	a5,a5,a3
 836:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 83a:	00074683          	lbu	a3,0(a4)
 83e:	fd06879b          	addiw	a5,a3,-48
 842:	0ff7f793          	zext.b	a5,a5
 846:	fef671e3          	bgeu	a2,a5,828 <atoi+0x1c>
  return n;
}
 84a:	6422                	ld	s0,8(sp)
 84c:	0141                	addi	sp,sp,16
 84e:	8082                	ret
  n = 0;
 850:	4501                	li	a0,0
 852:	bfe5                	j	84a <atoi+0x3e>

0000000000000854 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 854:	1141                	addi	sp,sp,-16
 856:	e422                	sd	s0,8(sp)
 858:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 85a:	02b57463          	bgeu	a0,a1,882 <memmove+0x2e>
    while(n-- > 0)
 85e:	00c05f63          	blez	a2,87c <memmove+0x28>
 862:	1602                	slli	a2,a2,0x20
 864:	9201                	srli	a2,a2,0x20
 866:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 86a:	872a                	mv	a4,a0
      *dst++ = *src++;
 86c:	0585                	addi	a1,a1,1
 86e:	0705                	addi	a4,a4,1
 870:	fff5c683          	lbu	a3,-1(a1)
 874:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 878:	fef71ae3          	bne	a4,a5,86c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 87c:	6422                	ld	s0,8(sp)
 87e:	0141                	addi	sp,sp,16
 880:	8082                	ret
    dst += n;
 882:	00c50733          	add	a4,a0,a2
    src += n;
 886:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 888:	fec05ae3          	blez	a2,87c <memmove+0x28>
 88c:	fff6079b          	addiw	a5,a2,-1
 890:	1782                	slli	a5,a5,0x20
 892:	9381                	srli	a5,a5,0x20
 894:	fff7c793          	not	a5,a5
 898:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 89a:	15fd                	addi	a1,a1,-1
 89c:	177d                	addi	a4,a4,-1
 89e:	0005c683          	lbu	a3,0(a1)
 8a2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 8a6:	fee79ae3          	bne	a5,a4,89a <memmove+0x46>
 8aa:	bfc9                	j	87c <memmove+0x28>

00000000000008ac <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 8ac:	1141                	addi	sp,sp,-16
 8ae:	e422                	sd	s0,8(sp)
 8b0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 8b2:	ca05                	beqz	a2,8e2 <memcmp+0x36>
 8b4:	fff6069b          	addiw	a3,a2,-1
 8b8:	1682                	slli	a3,a3,0x20
 8ba:	9281                	srli	a3,a3,0x20
 8bc:	0685                	addi	a3,a3,1
 8be:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 8c0:	00054783          	lbu	a5,0(a0)
 8c4:	0005c703          	lbu	a4,0(a1)
 8c8:	00e79863          	bne	a5,a4,8d8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 8cc:	0505                	addi	a0,a0,1
    p2++;
 8ce:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 8d0:	fed518e3          	bne	a0,a3,8c0 <memcmp+0x14>
  }
  return 0;
 8d4:	4501                	li	a0,0
 8d6:	a019                	j	8dc <memcmp+0x30>
      return *p1 - *p2;
 8d8:	40e7853b          	subw	a0,a5,a4
}
 8dc:	6422                	ld	s0,8(sp)
 8de:	0141                	addi	sp,sp,16
 8e0:	8082                	ret
  return 0;
 8e2:	4501                	li	a0,0
 8e4:	bfe5                	j	8dc <memcmp+0x30>

00000000000008e6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 8e6:	1141                	addi	sp,sp,-16
 8e8:	e406                	sd	ra,8(sp)
 8ea:	e022                	sd	s0,0(sp)
 8ec:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 8ee:	00000097          	auipc	ra,0x0
 8f2:	f66080e7          	jalr	-154(ra) # 854 <memmove>
}
 8f6:	60a2                	ld	ra,8(sp)
 8f8:	6402                	ld	s0,0(sp)
 8fa:	0141                	addi	sp,sp,16
 8fc:	8082                	ret

00000000000008fe <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 8fe:	4885                	li	a7,1
 ecall
 900:	00000073          	ecall
 ret
 904:	8082                	ret

0000000000000906 <exit>:
.global exit
exit:
 li a7, SYS_exit
 906:	4889                	li	a7,2
 ecall
 908:	00000073          	ecall
 ret
 90c:	8082                	ret

000000000000090e <wait>:
.global wait
wait:
 li a7, SYS_wait
 90e:	488d                	li	a7,3
 ecall
 910:	00000073          	ecall
 ret
 914:	8082                	ret

0000000000000916 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 916:	4891                	li	a7,4
 ecall
 918:	00000073          	ecall
 ret
 91c:	8082                	ret

000000000000091e <read>:
.global read
read:
 li a7, SYS_read
 91e:	4895                	li	a7,5
 ecall
 920:	00000073          	ecall
 ret
 924:	8082                	ret

0000000000000926 <write>:
.global write
write:
 li a7, SYS_write
 926:	48c1                	li	a7,16
 ecall
 928:	00000073          	ecall
 ret
 92c:	8082                	ret

000000000000092e <close>:
.global close
close:
 li a7, SYS_close
 92e:	48d5                	li	a7,21
 ecall
 930:	00000073          	ecall
 ret
 934:	8082                	ret

0000000000000936 <kill>:
.global kill
kill:
 li a7, SYS_kill
 936:	4899                	li	a7,6
 ecall
 938:	00000073          	ecall
 ret
 93c:	8082                	ret

000000000000093e <exec>:
.global exec
exec:
 li a7, SYS_exec
 93e:	489d                	li	a7,7
 ecall
 940:	00000073          	ecall
 ret
 944:	8082                	ret

0000000000000946 <open>:
.global open
open:
 li a7, SYS_open
 946:	48bd                	li	a7,15
 ecall
 948:	00000073          	ecall
 ret
 94c:	8082                	ret

000000000000094e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 94e:	48c5                	li	a7,17
 ecall
 950:	00000073          	ecall
 ret
 954:	8082                	ret

0000000000000956 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 956:	48c9                	li	a7,18
 ecall
 958:	00000073          	ecall
 ret
 95c:	8082                	ret

000000000000095e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 95e:	48a1                	li	a7,8
 ecall
 960:	00000073          	ecall
 ret
 964:	8082                	ret

0000000000000966 <link>:
.global link
link:
 li a7, SYS_link
 966:	48cd                	li	a7,19
 ecall
 968:	00000073          	ecall
 ret
 96c:	8082                	ret

000000000000096e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 96e:	48d1                	li	a7,20
 ecall
 970:	00000073          	ecall
 ret
 974:	8082                	ret

0000000000000976 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 976:	48a5                	li	a7,9
 ecall
 978:	00000073          	ecall
 ret
 97c:	8082                	ret

000000000000097e <dup>:
.global dup
dup:
 li a7, SYS_dup
 97e:	48a9                	li	a7,10
 ecall
 980:	00000073          	ecall
 ret
 984:	8082                	ret

0000000000000986 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 986:	48ad                	li	a7,11
 ecall
 988:	00000073          	ecall
 ret
 98c:	8082                	ret

000000000000098e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 98e:	48b1                	li	a7,12
 ecall
 990:	00000073          	ecall
 ret
 994:	8082                	ret

0000000000000996 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 996:	48b5                	li	a7,13
 ecall
 998:	00000073          	ecall
 ret
 99c:	8082                	ret

000000000000099e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 99e:	48b9                	li	a7,14
 ecall
 9a0:	00000073          	ecall
 ret
 9a4:	8082                	ret

00000000000009a6 <ps>:
.global ps
ps:
 li a7, SYS_ps
 9a6:	48d9                	li	a7,22
 ecall
 9a8:	00000073          	ecall
 ret
 9ac:	8082                	ret

00000000000009ae <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 9ae:	48dd                	li	a7,23
 ecall
 9b0:	00000073          	ecall
 ret
 9b4:	8082                	ret

00000000000009b6 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 9b6:	48e1                	li	a7,24
 ecall
 9b8:	00000073          	ecall
 ret
 9bc:	8082                	ret

00000000000009be <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 9be:	48e9                	li	a7,26
 ecall
 9c0:	00000073          	ecall
 ret
 9c4:	8082                	ret

00000000000009c6 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 9c6:	48e5                	li	a7,25
 ecall
 9c8:	00000073          	ecall
 ret
 9cc:	8082                	ret

00000000000009ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9ce:	1101                	addi	sp,sp,-32
 9d0:	ec06                	sd	ra,24(sp)
 9d2:	e822                	sd	s0,16(sp)
 9d4:	1000                	addi	s0,sp,32
 9d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9da:	4605                	li	a2,1
 9dc:	fef40593          	addi	a1,s0,-17
 9e0:	00000097          	auipc	ra,0x0
 9e4:	f46080e7          	jalr	-186(ra) # 926 <write>
}
 9e8:	60e2                	ld	ra,24(sp)
 9ea:	6442                	ld	s0,16(sp)
 9ec:	6105                	addi	sp,sp,32
 9ee:	8082                	ret

00000000000009f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9f0:	7139                	addi	sp,sp,-64
 9f2:	fc06                	sd	ra,56(sp)
 9f4:	f822                	sd	s0,48(sp)
 9f6:	f426                	sd	s1,40(sp)
 9f8:	0080                	addi	s0,sp,64
 9fa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 9fc:	c299                	beqz	a3,a02 <printint+0x12>
 9fe:	0805cb63          	bltz	a1,a94 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 a02:	2581                	sext.w	a1,a1
  neg = 0;
 a04:	4881                	li	a7,0
 a06:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 a0a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 a0c:	2601                	sext.w	a2,a2
 a0e:	00001517          	auipc	a0,0x1
 a12:	82a50513          	addi	a0,a0,-2006 # 1238 <digits>
 a16:	883a                	mv	a6,a4
 a18:	2705                	addiw	a4,a4,1
 a1a:	02c5f7bb          	remuw	a5,a1,a2
 a1e:	1782                	slli	a5,a5,0x20
 a20:	9381                	srli	a5,a5,0x20
 a22:	97aa                	add	a5,a5,a0
 a24:	0007c783          	lbu	a5,0(a5)
 a28:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a2c:	0005879b          	sext.w	a5,a1
 a30:	02c5d5bb          	divuw	a1,a1,a2
 a34:	0685                	addi	a3,a3,1
 a36:	fec7f0e3          	bgeu	a5,a2,a16 <printint+0x26>
  if(neg)
 a3a:	00088c63          	beqz	a7,a52 <printint+0x62>
    buf[i++] = '-';
 a3e:	fd070793          	addi	a5,a4,-48
 a42:	00878733          	add	a4,a5,s0
 a46:	02d00793          	li	a5,45
 a4a:	fef70823          	sb	a5,-16(a4)
 a4e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a52:	02e05c63          	blez	a4,a8a <printint+0x9a>
 a56:	f04a                	sd	s2,32(sp)
 a58:	ec4e                	sd	s3,24(sp)
 a5a:	fc040793          	addi	a5,s0,-64
 a5e:	00e78933          	add	s2,a5,a4
 a62:	fff78993          	addi	s3,a5,-1
 a66:	99ba                	add	s3,s3,a4
 a68:	377d                	addiw	a4,a4,-1
 a6a:	1702                	slli	a4,a4,0x20
 a6c:	9301                	srli	a4,a4,0x20
 a6e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a72:	fff94583          	lbu	a1,-1(s2)
 a76:	8526                	mv	a0,s1
 a78:	00000097          	auipc	ra,0x0
 a7c:	f56080e7          	jalr	-170(ra) # 9ce <putc>
  while(--i >= 0)
 a80:	197d                	addi	s2,s2,-1
 a82:	ff3918e3          	bne	s2,s3,a72 <printint+0x82>
 a86:	7902                	ld	s2,32(sp)
 a88:	69e2                	ld	s3,24(sp)
}
 a8a:	70e2                	ld	ra,56(sp)
 a8c:	7442                	ld	s0,48(sp)
 a8e:	74a2                	ld	s1,40(sp)
 a90:	6121                	addi	sp,sp,64
 a92:	8082                	ret
    x = -xx;
 a94:	40b005bb          	negw	a1,a1
    neg = 1;
 a98:	4885                	li	a7,1
    x = -xx;
 a9a:	b7b5                	j	a06 <printint+0x16>

0000000000000a9c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 a9c:	715d                	addi	sp,sp,-80
 a9e:	e486                	sd	ra,72(sp)
 aa0:	e0a2                	sd	s0,64(sp)
 aa2:	f84a                	sd	s2,48(sp)
 aa4:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 aa6:	0005c903          	lbu	s2,0(a1)
 aaa:	1a090a63          	beqz	s2,c5e <vprintf+0x1c2>
 aae:	fc26                	sd	s1,56(sp)
 ab0:	f44e                	sd	s3,40(sp)
 ab2:	f052                	sd	s4,32(sp)
 ab4:	ec56                	sd	s5,24(sp)
 ab6:	e85a                	sd	s6,16(sp)
 ab8:	e45e                	sd	s7,8(sp)
 aba:	8aaa                	mv	s5,a0
 abc:	8bb2                	mv	s7,a2
 abe:	00158493          	addi	s1,a1,1
  state = 0;
 ac2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 ac4:	02500a13          	li	s4,37
 ac8:	4b55                	li	s6,21
 aca:	a839                	j	ae8 <vprintf+0x4c>
        putc(fd, c);
 acc:	85ca                	mv	a1,s2
 ace:	8556                	mv	a0,s5
 ad0:	00000097          	auipc	ra,0x0
 ad4:	efe080e7          	jalr	-258(ra) # 9ce <putc>
 ad8:	a019                	j	ade <vprintf+0x42>
    } else if(state == '%'){
 ada:	01498d63          	beq	s3,s4,af4 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 ade:	0485                	addi	s1,s1,1
 ae0:	fff4c903          	lbu	s2,-1(s1)
 ae4:	16090763          	beqz	s2,c52 <vprintf+0x1b6>
    if(state == 0){
 ae8:	fe0999e3          	bnez	s3,ada <vprintf+0x3e>
      if(c == '%'){
 aec:	ff4910e3          	bne	s2,s4,acc <vprintf+0x30>
        state = '%';
 af0:	89d2                	mv	s3,s4
 af2:	b7f5                	j	ade <vprintf+0x42>
      if(c == 'd'){
 af4:	13490463          	beq	s2,s4,c1c <vprintf+0x180>
 af8:	f9d9079b          	addiw	a5,s2,-99
 afc:	0ff7f793          	zext.b	a5,a5
 b00:	12fb6763          	bltu	s6,a5,c2e <vprintf+0x192>
 b04:	f9d9079b          	addiw	a5,s2,-99
 b08:	0ff7f713          	zext.b	a4,a5
 b0c:	12eb6163          	bltu	s6,a4,c2e <vprintf+0x192>
 b10:	00271793          	slli	a5,a4,0x2
 b14:	00000717          	auipc	a4,0x0
 b18:	6cc70713          	addi	a4,a4,1740 # 11e0 <malloc+0x492>
 b1c:	97ba                	add	a5,a5,a4
 b1e:	439c                	lw	a5,0(a5)
 b20:	97ba                	add	a5,a5,a4
 b22:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 b24:	008b8913          	addi	s2,s7,8
 b28:	4685                	li	a3,1
 b2a:	4629                	li	a2,10
 b2c:	000ba583          	lw	a1,0(s7)
 b30:	8556                	mv	a0,s5
 b32:	00000097          	auipc	ra,0x0
 b36:	ebe080e7          	jalr	-322(ra) # 9f0 <printint>
 b3a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 b3c:	4981                	li	s3,0
 b3e:	b745                	j	ade <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b40:	008b8913          	addi	s2,s7,8
 b44:	4681                	li	a3,0
 b46:	4629                	li	a2,10
 b48:	000ba583          	lw	a1,0(s7)
 b4c:	8556                	mv	a0,s5
 b4e:	00000097          	auipc	ra,0x0
 b52:	ea2080e7          	jalr	-350(ra) # 9f0 <printint>
 b56:	8bca                	mv	s7,s2
      state = 0;
 b58:	4981                	li	s3,0
 b5a:	b751                	j	ade <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 b5c:	008b8913          	addi	s2,s7,8
 b60:	4681                	li	a3,0
 b62:	4641                	li	a2,16
 b64:	000ba583          	lw	a1,0(s7)
 b68:	8556                	mv	a0,s5
 b6a:	00000097          	auipc	ra,0x0
 b6e:	e86080e7          	jalr	-378(ra) # 9f0 <printint>
 b72:	8bca                	mv	s7,s2
      state = 0;
 b74:	4981                	li	s3,0
 b76:	b7a5                	j	ade <vprintf+0x42>
 b78:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 b7a:	008b8c13          	addi	s8,s7,8
 b7e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 b82:	03000593          	li	a1,48
 b86:	8556                	mv	a0,s5
 b88:	00000097          	auipc	ra,0x0
 b8c:	e46080e7          	jalr	-442(ra) # 9ce <putc>
  putc(fd, 'x');
 b90:	07800593          	li	a1,120
 b94:	8556                	mv	a0,s5
 b96:	00000097          	auipc	ra,0x0
 b9a:	e38080e7          	jalr	-456(ra) # 9ce <putc>
 b9e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ba0:	00000b97          	auipc	s7,0x0
 ba4:	698b8b93          	addi	s7,s7,1688 # 1238 <digits>
 ba8:	03c9d793          	srli	a5,s3,0x3c
 bac:	97de                	add	a5,a5,s7
 bae:	0007c583          	lbu	a1,0(a5)
 bb2:	8556                	mv	a0,s5
 bb4:	00000097          	auipc	ra,0x0
 bb8:	e1a080e7          	jalr	-486(ra) # 9ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 bbc:	0992                	slli	s3,s3,0x4
 bbe:	397d                	addiw	s2,s2,-1
 bc0:	fe0914e3          	bnez	s2,ba8 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 bc4:	8be2                	mv	s7,s8
      state = 0;
 bc6:	4981                	li	s3,0
 bc8:	6c02                	ld	s8,0(sp)
 bca:	bf11                	j	ade <vprintf+0x42>
        s = va_arg(ap, char*);
 bcc:	008b8993          	addi	s3,s7,8
 bd0:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 bd4:	02090163          	beqz	s2,bf6 <vprintf+0x15a>
        while(*s != 0){
 bd8:	00094583          	lbu	a1,0(s2)
 bdc:	c9a5                	beqz	a1,c4c <vprintf+0x1b0>
          putc(fd, *s);
 bde:	8556                	mv	a0,s5
 be0:	00000097          	auipc	ra,0x0
 be4:	dee080e7          	jalr	-530(ra) # 9ce <putc>
          s++;
 be8:	0905                	addi	s2,s2,1
        while(*s != 0){
 bea:	00094583          	lbu	a1,0(s2)
 bee:	f9e5                	bnez	a1,bde <vprintf+0x142>
        s = va_arg(ap, char*);
 bf0:	8bce                	mv	s7,s3
      state = 0;
 bf2:	4981                	li	s3,0
 bf4:	b5ed                	j	ade <vprintf+0x42>
          s = "(null)";
 bf6:	00000917          	auipc	s2,0x0
 bfa:	5e290913          	addi	s2,s2,1506 # 11d8 <malloc+0x48a>
        while(*s != 0){
 bfe:	02800593          	li	a1,40
 c02:	bff1                	j	bde <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 c04:	008b8913          	addi	s2,s7,8
 c08:	000bc583          	lbu	a1,0(s7)
 c0c:	8556                	mv	a0,s5
 c0e:	00000097          	auipc	ra,0x0
 c12:	dc0080e7          	jalr	-576(ra) # 9ce <putc>
 c16:	8bca                	mv	s7,s2
      state = 0;
 c18:	4981                	li	s3,0
 c1a:	b5d1                	j	ade <vprintf+0x42>
        putc(fd, c);
 c1c:	02500593          	li	a1,37
 c20:	8556                	mv	a0,s5
 c22:	00000097          	auipc	ra,0x0
 c26:	dac080e7          	jalr	-596(ra) # 9ce <putc>
      state = 0;
 c2a:	4981                	li	s3,0
 c2c:	bd4d                	j	ade <vprintf+0x42>
        putc(fd, '%');
 c2e:	02500593          	li	a1,37
 c32:	8556                	mv	a0,s5
 c34:	00000097          	auipc	ra,0x0
 c38:	d9a080e7          	jalr	-614(ra) # 9ce <putc>
        putc(fd, c);
 c3c:	85ca                	mv	a1,s2
 c3e:	8556                	mv	a0,s5
 c40:	00000097          	auipc	ra,0x0
 c44:	d8e080e7          	jalr	-626(ra) # 9ce <putc>
      state = 0;
 c48:	4981                	li	s3,0
 c4a:	bd51                	j	ade <vprintf+0x42>
        s = va_arg(ap, char*);
 c4c:	8bce                	mv	s7,s3
      state = 0;
 c4e:	4981                	li	s3,0
 c50:	b579                	j	ade <vprintf+0x42>
 c52:	74e2                	ld	s1,56(sp)
 c54:	79a2                	ld	s3,40(sp)
 c56:	7a02                	ld	s4,32(sp)
 c58:	6ae2                	ld	s5,24(sp)
 c5a:	6b42                	ld	s6,16(sp)
 c5c:	6ba2                	ld	s7,8(sp)
    }
  }
}
 c5e:	60a6                	ld	ra,72(sp)
 c60:	6406                	ld	s0,64(sp)
 c62:	7942                	ld	s2,48(sp)
 c64:	6161                	addi	sp,sp,80
 c66:	8082                	ret

0000000000000c68 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c68:	715d                	addi	sp,sp,-80
 c6a:	ec06                	sd	ra,24(sp)
 c6c:	e822                	sd	s0,16(sp)
 c6e:	1000                	addi	s0,sp,32
 c70:	e010                	sd	a2,0(s0)
 c72:	e414                	sd	a3,8(s0)
 c74:	e818                	sd	a4,16(s0)
 c76:	ec1c                	sd	a5,24(s0)
 c78:	03043023          	sd	a6,32(s0)
 c7c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c80:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c84:	8622                	mv	a2,s0
 c86:	00000097          	auipc	ra,0x0
 c8a:	e16080e7          	jalr	-490(ra) # a9c <vprintf>
}
 c8e:	60e2                	ld	ra,24(sp)
 c90:	6442                	ld	s0,16(sp)
 c92:	6161                	addi	sp,sp,80
 c94:	8082                	ret

0000000000000c96 <printf>:

void
printf(const char *fmt, ...)
{
 c96:	711d                	addi	sp,sp,-96
 c98:	ec06                	sd	ra,24(sp)
 c9a:	e822                	sd	s0,16(sp)
 c9c:	1000                	addi	s0,sp,32
 c9e:	e40c                	sd	a1,8(s0)
 ca0:	e810                	sd	a2,16(s0)
 ca2:	ec14                	sd	a3,24(s0)
 ca4:	f018                	sd	a4,32(s0)
 ca6:	f41c                	sd	a5,40(s0)
 ca8:	03043823          	sd	a6,48(s0)
 cac:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 cb0:	00840613          	addi	a2,s0,8
 cb4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 cb8:	85aa                	mv	a1,a0
 cba:	4505                	li	a0,1
 cbc:	00000097          	auipc	ra,0x0
 cc0:	de0080e7          	jalr	-544(ra) # a9c <vprintf>
}
 cc4:	60e2                	ld	ra,24(sp)
 cc6:	6442                	ld	s0,16(sp)
 cc8:	6125                	addi	sp,sp,96
 cca:	8082                	ret

0000000000000ccc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ccc:	1141                	addi	sp,sp,-16
 cce:	e422                	sd	s0,8(sp)
 cd0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 cd2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cd6:	00002797          	auipc	a5,0x2
 cda:	8127b783          	ld	a5,-2030(a5) # 24e8 <freep>
 cde:	a02d                	j	d08 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 ce0:	4618                	lw	a4,8(a2)
 ce2:	9f2d                	addw	a4,a4,a1
 ce4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ce8:	6398                	ld	a4,0(a5)
 cea:	6310                	ld	a2,0(a4)
 cec:	a83d                	j	d2a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 cee:	ff852703          	lw	a4,-8(a0)
 cf2:	9f31                	addw	a4,a4,a2
 cf4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 cf6:	ff053683          	ld	a3,-16(a0)
 cfa:	a091                	j	d3e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cfc:	6398                	ld	a4,0(a5)
 cfe:	00e7e463          	bltu	a5,a4,d06 <free+0x3a>
 d02:	00e6ea63          	bltu	a3,a4,d16 <free+0x4a>
{
 d06:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d08:	fed7fae3          	bgeu	a5,a3,cfc <free+0x30>
 d0c:	6398                	ld	a4,0(a5)
 d0e:	00e6e463          	bltu	a3,a4,d16 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d12:	fee7eae3          	bltu	a5,a4,d06 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 d16:	ff852583          	lw	a1,-8(a0)
 d1a:	6390                	ld	a2,0(a5)
 d1c:	02059813          	slli	a6,a1,0x20
 d20:	01c85713          	srli	a4,a6,0x1c
 d24:	9736                	add	a4,a4,a3
 d26:	fae60de3          	beq	a2,a4,ce0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 d2a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d2e:	4790                	lw	a2,8(a5)
 d30:	02061593          	slli	a1,a2,0x20
 d34:	01c5d713          	srli	a4,a1,0x1c
 d38:	973e                	add	a4,a4,a5
 d3a:	fae68ae3          	beq	a3,a4,cee <free+0x22>
    p->s.ptr = bp->s.ptr;
 d3e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 d40:	00001717          	auipc	a4,0x1
 d44:	7af73423          	sd	a5,1960(a4) # 24e8 <freep>
}
 d48:	6422                	ld	s0,8(sp)
 d4a:	0141                	addi	sp,sp,16
 d4c:	8082                	ret

0000000000000d4e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d4e:	7139                	addi	sp,sp,-64
 d50:	fc06                	sd	ra,56(sp)
 d52:	f822                	sd	s0,48(sp)
 d54:	f426                	sd	s1,40(sp)
 d56:	ec4e                	sd	s3,24(sp)
 d58:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d5a:	02051493          	slli	s1,a0,0x20
 d5e:	9081                	srli	s1,s1,0x20
 d60:	04bd                	addi	s1,s1,15
 d62:	8091                	srli	s1,s1,0x4
 d64:	0014899b          	addiw	s3,s1,1
 d68:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d6a:	00001517          	auipc	a0,0x1
 d6e:	77e53503          	ld	a0,1918(a0) # 24e8 <freep>
 d72:	c915                	beqz	a0,da6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d74:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d76:	4798                	lw	a4,8(a5)
 d78:	08977e63          	bgeu	a4,s1,e14 <malloc+0xc6>
 d7c:	f04a                	sd	s2,32(sp)
 d7e:	e852                	sd	s4,16(sp)
 d80:	e456                	sd	s5,8(sp)
 d82:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 d84:	8a4e                	mv	s4,s3
 d86:	0009871b          	sext.w	a4,s3
 d8a:	6685                	lui	a3,0x1
 d8c:	00d77363          	bgeu	a4,a3,d92 <malloc+0x44>
 d90:	6a05                	lui	s4,0x1
 d92:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 d96:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 d9a:	00001917          	auipc	s2,0x1
 d9e:	74e90913          	addi	s2,s2,1870 # 24e8 <freep>
  if(p == (char*)-1)
 da2:	5afd                	li	s5,-1
 da4:	a091                	j	de8 <malloc+0x9a>
 da6:	f04a                	sd	s2,32(sp)
 da8:	e852                	sd	s4,16(sp)
 daa:	e456                	sd	s5,8(sp)
 dac:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 dae:	04001797          	auipc	a5,0x4001
 db2:	74278793          	addi	a5,a5,1858 # 40024f0 <base>
 db6:	00001717          	auipc	a4,0x1
 dba:	72f73923          	sd	a5,1842(a4) # 24e8 <freep>
 dbe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 dc0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 dc4:	b7c1                	j	d84 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 dc6:	6398                	ld	a4,0(a5)
 dc8:	e118                	sd	a4,0(a0)
 dca:	a08d                	j	e2c <malloc+0xde>
  hp->s.size = nu;
 dcc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 dd0:	0541                	addi	a0,a0,16
 dd2:	00000097          	auipc	ra,0x0
 dd6:	efa080e7          	jalr	-262(ra) # ccc <free>
  return freep;
 dda:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 dde:	c13d                	beqz	a0,e44 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 de0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 de2:	4798                	lw	a4,8(a5)
 de4:	02977463          	bgeu	a4,s1,e0c <malloc+0xbe>
    if(p == freep)
 de8:	00093703          	ld	a4,0(s2)
 dec:	853e                	mv	a0,a5
 dee:	fef719e3          	bne	a4,a5,de0 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 df2:	8552                	mv	a0,s4
 df4:	00000097          	auipc	ra,0x0
 df8:	b9a080e7          	jalr	-1126(ra) # 98e <sbrk>
  if(p == (char*)-1)
 dfc:	fd5518e3          	bne	a0,s5,dcc <malloc+0x7e>
        return 0;
 e00:	4501                	li	a0,0
 e02:	7902                	ld	s2,32(sp)
 e04:	6a42                	ld	s4,16(sp)
 e06:	6aa2                	ld	s5,8(sp)
 e08:	6b02                	ld	s6,0(sp)
 e0a:	a03d                	j	e38 <malloc+0xea>
 e0c:	7902                	ld	s2,32(sp)
 e0e:	6a42                	ld	s4,16(sp)
 e10:	6aa2                	ld	s5,8(sp)
 e12:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 e14:	fae489e3          	beq	s1,a4,dc6 <malloc+0x78>
        p->s.size -= nunits;
 e18:	4137073b          	subw	a4,a4,s3
 e1c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 e1e:	02071693          	slli	a3,a4,0x20
 e22:	01c6d713          	srli	a4,a3,0x1c
 e26:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 e28:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 e2c:	00001717          	auipc	a4,0x1
 e30:	6aa73e23          	sd	a0,1724(a4) # 24e8 <freep>
      return (void*)(p + 1);
 e34:	01078513          	addi	a0,a5,16
  }
}
 e38:	70e2                	ld	ra,56(sp)
 e3a:	7442                	ld	s0,48(sp)
 e3c:	74a2                	ld	s1,40(sp)
 e3e:	69e2                	ld	s3,24(sp)
 e40:	6121                	addi	sp,sp,64
 e42:	8082                	ret
 e44:	7902                	ld	s2,32(sp)
 e46:	6a42                	ld	s4,16(sp)
 e48:	6aa2                	ld	s5,8(sp)
 e4a:	6b02                	ld	s6,0(sp)
 e4c:	b7f5                	j	e38 <malloc+0xea>
