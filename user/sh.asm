
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
    }
    exit(0);
}

int getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
    write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	3ee58593          	addi	a1,a1,1006 # 1400 <malloc+0x10c>
      1a:	4509                	li	a0,2
      1c:	00001097          	auipc	ra,0x1
      20:	eb0080e7          	jalr	-336(ra) # ecc <write>
    memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	c88080e7          	jalr	-888(ra) # cb2 <memset>
    gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	cc2080e7          	jalr	-830(ra) # cf8 <gets>
    if (buf[0] == 0) // EOF
      3e:	0004c503          	lbu	a0,0(s1)
      42:	00153513          	seqz	a0,a0
        return -1;
    return 0;
}
      46:	40a00533          	neg	a0,a0
      4a:	60e2                	ld	ra,24(sp)
      4c:	6442                	ld	s0,16(sp)
      4e:	64a2                	ld	s1,8(sp)
      50:	6902                	ld	s2,0(sp)
      52:	6105                	addi	sp,sp,32
      54:	8082                	ret

0000000000000056 <panic>:
    }
    exit(0);
}

void panic(char *s)
{
      56:	1141                	addi	sp,sp,-16
      58:	e406                	sd	ra,8(sp)
      5a:	e022                	sd	s0,0(sp)
      5c:	0800                	addi	s0,sp,16
      5e:	862a                	mv	a2,a0
    fprintf(2, "%s\n", s);
      60:	00001597          	auipc	a1,0x1
      64:	3b058593          	addi	a1,a1,944 # 1410 <malloc+0x11c>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	1a4080e7          	jalr	420(ra) # 120e <fprintf>
    exit(1);
      72:	4505                	li	a0,1
      74:	00001097          	auipc	ra,0x1
      78:	e38080e7          	jalr	-456(ra) # eac <exit>

000000000000007c <fork1>:
}

int fork1(void)
{
      7c:	1141                	addi	sp,sp,-16
      7e:	e406                	sd	ra,8(sp)
      80:	e022                	sd	s0,0(sp)
      82:	0800                	addi	s0,sp,16
    int pid;

    pid = fork();
      84:	00001097          	auipc	ra,0x1
      88:	e20080e7          	jalr	-480(ra) # ea4 <fork>
    if (pid == -1)
      8c:	57fd                	li	a5,-1
      8e:	00f50663          	beq	a0,a5,9a <fork1+0x1e>
        panic("fork");
    return pid;
}
      92:	60a2                	ld	ra,8(sp)
      94:	6402                	ld	s0,0(sp)
      96:	0141                	addi	sp,sp,16
      98:	8082                	ret
        panic("fork");
      9a:	00001517          	auipc	a0,0x1
      9e:	37e50513          	addi	a0,a0,894 # 1418 <malloc+0x124>
      a2:	00000097          	auipc	ra,0x0
      a6:	fb4080e7          	jalr	-76(ra) # 56 <panic>

00000000000000aa <runcmd>:
{
      aa:	7179                	addi	sp,sp,-48
      ac:	f406                	sd	ra,40(sp)
      ae:	f022                	sd	s0,32(sp)
      b0:	1800                	addi	s0,sp,48
    if (cmd == 0)
      b2:	c115                	beqz	a0,d6 <runcmd+0x2c>
      b4:	ec26                	sd	s1,24(sp)
      b6:	84aa                	mv	s1,a0
    switch (cmd->type)
      b8:	4118                	lw	a4,0(a0)
      ba:	4795                	li	a5,5
      bc:	02e7e363          	bltu	a5,a4,e2 <runcmd+0x38>
      c0:	00056783          	lwu	a5,0(a0)
      c4:	078a                	slli	a5,a5,0x2
      c6:	00001717          	auipc	a4,0x1
      ca:	46a70713          	addi	a4,a4,1130 # 1530 <malloc+0x23c>
      ce:	97ba                	add	a5,a5,a4
      d0:	439c                	lw	a5,0(a5)
      d2:	97ba                	add	a5,a5,a4
      d4:	8782                	jr	a5
      d6:	ec26                	sd	s1,24(sp)
        exit(1);
      d8:	4505                	li	a0,1
      da:	00001097          	auipc	ra,0x1
      de:	dd2080e7          	jalr	-558(ra) # eac <exit>
        panic("runcmd");
      e2:	00001517          	auipc	a0,0x1
      e6:	33e50513          	addi	a0,a0,830 # 1420 <malloc+0x12c>
      ea:	00000097          	auipc	ra,0x0
      ee:	f6c080e7          	jalr	-148(ra) # 56 <panic>
        if (ecmd->argv[0] == 0)
      f2:	6508                	ld	a0,8(a0)
      f4:	c515                	beqz	a0,120 <runcmd+0x76>
        exec(ecmd->argv[0], ecmd->argv);
      f6:	00848593          	addi	a1,s1,8
      fa:	00001097          	auipc	ra,0x1
      fe:	dea080e7          	jalr	-534(ra) # ee4 <exec>
        fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     102:	6490                	ld	a2,8(s1)
     104:	00001597          	auipc	a1,0x1
     108:	32458593          	addi	a1,a1,804 # 1428 <malloc+0x134>
     10c:	4509                	li	a0,2
     10e:	00001097          	auipc	ra,0x1
     112:	100080e7          	jalr	256(ra) # 120e <fprintf>
    exit(0);
     116:	4501                	li	a0,0
     118:	00001097          	auipc	ra,0x1
     11c:	d94080e7          	jalr	-620(ra) # eac <exit>
            exit(1);
     120:	4505                	li	a0,1
     122:	00001097          	auipc	ra,0x1
     126:	d8a080e7          	jalr	-630(ra) # eac <exit>
        close(rcmd->fd);
     12a:	5148                	lw	a0,36(a0)
     12c:	00001097          	auipc	ra,0x1
     130:	da8080e7          	jalr	-600(ra) # ed4 <close>
        if (open(rcmd->file, rcmd->mode) < 0)
     134:	508c                	lw	a1,32(s1)
     136:	6888                	ld	a0,16(s1)
     138:	00001097          	auipc	ra,0x1
     13c:	db4080e7          	jalr	-588(ra) # eec <open>
     140:	00054763          	bltz	a0,14e <runcmd+0xa4>
        runcmd(rcmd->cmd);
     144:	6488                	ld	a0,8(s1)
     146:	00000097          	auipc	ra,0x0
     14a:	f64080e7          	jalr	-156(ra) # aa <runcmd>
            fprintf(2, "open %s failed\n", rcmd->file);
     14e:	6890                	ld	a2,16(s1)
     150:	00001597          	auipc	a1,0x1
     154:	2e858593          	addi	a1,a1,744 # 1438 <malloc+0x144>
     158:	4509                	li	a0,2
     15a:	00001097          	auipc	ra,0x1
     15e:	0b4080e7          	jalr	180(ra) # 120e <fprintf>
            exit(1);
     162:	4505                	li	a0,1
     164:	00001097          	auipc	ra,0x1
     168:	d48080e7          	jalr	-696(ra) # eac <exit>
        if (fork1() == 0)
     16c:	00000097          	auipc	ra,0x0
     170:	f10080e7          	jalr	-240(ra) # 7c <fork1>
     174:	e511                	bnez	a0,180 <runcmd+0xd6>
            runcmd(lcmd->left);
     176:	6488                	ld	a0,8(s1)
     178:	00000097          	auipc	ra,0x0
     17c:	f32080e7          	jalr	-206(ra) # aa <runcmd>
        wait(0);
     180:	4501                	li	a0,0
     182:	00001097          	auipc	ra,0x1
     186:	d32080e7          	jalr	-718(ra) # eb4 <wait>
        runcmd(lcmd->right);
     18a:	6888                	ld	a0,16(s1)
     18c:	00000097          	auipc	ra,0x0
     190:	f1e080e7          	jalr	-226(ra) # aa <runcmd>
        if (pipe(p) < 0)
     194:	fd840513          	addi	a0,s0,-40
     198:	00001097          	auipc	ra,0x1
     19c:	d24080e7          	jalr	-732(ra) # ebc <pipe>
     1a0:	04054363          	bltz	a0,1e6 <runcmd+0x13c>
        if (fork1() == 0)
     1a4:	00000097          	auipc	ra,0x0
     1a8:	ed8080e7          	jalr	-296(ra) # 7c <fork1>
     1ac:	e529                	bnez	a0,1f6 <runcmd+0x14c>
            close(1);
     1ae:	4505                	li	a0,1
     1b0:	00001097          	auipc	ra,0x1
     1b4:	d24080e7          	jalr	-732(ra) # ed4 <close>
            dup(p[1]);
     1b8:	fdc42503          	lw	a0,-36(s0)
     1bc:	00001097          	auipc	ra,0x1
     1c0:	d68080e7          	jalr	-664(ra) # f24 <dup>
            close(p[0]);
     1c4:	fd842503          	lw	a0,-40(s0)
     1c8:	00001097          	auipc	ra,0x1
     1cc:	d0c080e7          	jalr	-756(ra) # ed4 <close>
            close(p[1]);
     1d0:	fdc42503          	lw	a0,-36(s0)
     1d4:	00001097          	auipc	ra,0x1
     1d8:	d00080e7          	jalr	-768(ra) # ed4 <close>
            runcmd(pcmd->left);
     1dc:	6488                	ld	a0,8(s1)
     1de:	00000097          	auipc	ra,0x0
     1e2:	ecc080e7          	jalr	-308(ra) # aa <runcmd>
            panic("pipe");
     1e6:	00001517          	auipc	a0,0x1
     1ea:	26250513          	addi	a0,a0,610 # 1448 <malloc+0x154>
     1ee:	00000097          	auipc	ra,0x0
     1f2:	e68080e7          	jalr	-408(ra) # 56 <panic>
        if (fork1() == 0)
     1f6:	00000097          	auipc	ra,0x0
     1fa:	e86080e7          	jalr	-378(ra) # 7c <fork1>
     1fe:	ed05                	bnez	a0,236 <runcmd+0x18c>
            close(0);
     200:	00001097          	auipc	ra,0x1
     204:	cd4080e7          	jalr	-812(ra) # ed4 <close>
            dup(p[0]);
     208:	fd842503          	lw	a0,-40(s0)
     20c:	00001097          	auipc	ra,0x1
     210:	d18080e7          	jalr	-744(ra) # f24 <dup>
            close(p[0]);
     214:	fd842503          	lw	a0,-40(s0)
     218:	00001097          	auipc	ra,0x1
     21c:	cbc080e7          	jalr	-836(ra) # ed4 <close>
            close(p[1]);
     220:	fdc42503          	lw	a0,-36(s0)
     224:	00001097          	auipc	ra,0x1
     228:	cb0080e7          	jalr	-848(ra) # ed4 <close>
            runcmd(pcmd->right);
     22c:	6888                	ld	a0,16(s1)
     22e:	00000097          	auipc	ra,0x0
     232:	e7c080e7          	jalr	-388(ra) # aa <runcmd>
        close(p[0]);
     236:	fd842503          	lw	a0,-40(s0)
     23a:	00001097          	auipc	ra,0x1
     23e:	c9a080e7          	jalr	-870(ra) # ed4 <close>
        close(p[1]);
     242:	fdc42503          	lw	a0,-36(s0)
     246:	00001097          	auipc	ra,0x1
     24a:	c8e080e7          	jalr	-882(ra) # ed4 <close>
        wait(0);
     24e:	4501                	li	a0,0
     250:	00001097          	auipc	ra,0x1
     254:	c64080e7          	jalr	-924(ra) # eb4 <wait>
        wait(0);
     258:	4501                	li	a0,0
     25a:	00001097          	auipc	ra,0x1
     25e:	c5a080e7          	jalr	-934(ra) # eb4 <wait>
        break;
     262:	bd55                	j	116 <runcmd+0x6c>
        if (fork1() == 0)
     264:	00000097          	auipc	ra,0x0
     268:	e18080e7          	jalr	-488(ra) # 7c <fork1>
     26c:	ea0515e3          	bnez	a0,116 <runcmd+0x6c>
            runcmd(bcmd->cmd);
     270:	6488                	ld	a0,8(s1)
     272:	00000097          	auipc	ra,0x0
     276:	e38080e7          	jalr	-456(ra) # aa <runcmd>

000000000000027a <execcmd>:
// PAGEBREAK!
//  Constructors

struct cmd *
execcmd(void)
{
     27a:	1101                	addi	sp,sp,-32
     27c:	ec06                	sd	ra,24(sp)
     27e:	e822                	sd	s0,16(sp)
     280:	e426                	sd	s1,8(sp)
     282:	1000                	addi	s0,sp,32
    struct execcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     284:	0a800513          	li	a0,168
     288:	00001097          	auipc	ra,0x1
     28c:	06c080e7          	jalr	108(ra) # 12f4 <malloc>
     290:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     292:	0a800613          	li	a2,168
     296:	4581                	li	a1,0
     298:	00001097          	auipc	ra,0x1
     29c:	a1a080e7          	jalr	-1510(ra) # cb2 <memset>
    cmd->type = EXEC;
     2a0:	4785                	li	a5,1
     2a2:	c09c                	sw	a5,0(s1)
    return (struct cmd *)cmd;
}
     2a4:	8526                	mv	a0,s1
     2a6:	60e2                	ld	ra,24(sp)
     2a8:	6442                	ld	s0,16(sp)
     2aa:	64a2                	ld	s1,8(sp)
     2ac:	6105                	addi	sp,sp,32
     2ae:	8082                	ret

00000000000002b0 <redircmd>:

struct cmd *
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2b0:	7139                	addi	sp,sp,-64
     2b2:	fc06                	sd	ra,56(sp)
     2b4:	f822                	sd	s0,48(sp)
     2b6:	f426                	sd	s1,40(sp)
     2b8:	f04a                	sd	s2,32(sp)
     2ba:	ec4e                	sd	s3,24(sp)
     2bc:	e852                	sd	s4,16(sp)
     2be:	e456                	sd	s5,8(sp)
     2c0:	e05a                	sd	s6,0(sp)
     2c2:	0080                	addi	s0,sp,64
     2c4:	8b2a                	mv	s6,a0
     2c6:	8aae                	mv	s5,a1
     2c8:	8a32                	mv	s4,a2
     2ca:	89b6                	mv	s3,a3
     2cc:	893a                	mv	s2,a4
    struct redircmd *cmd;

    cmd = malloc(sizeof(*cmd));
     2ce:	02800513          	li	a0,40
     2d2:	00001097          	auipc	ra,0x1
     2d6:	022080e7          	jalr	34(ra) # 12f4 <malloc>
     2da:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     2dc:	02800613          	li	a2,40
     2e0:	4581                	li	a1,0
     2e2:	00001097          	auipc	ra,0x1
     2e6:	9d0080e7          	jalr	-1584(ra) # cb2 <memset>
    cmd->type = REDIR;
     2ea:	4789                	li	a5,2
     2ec:	c09c                	sw	a5,0(s1)
    cmd->cmd = subcmd;
     2ee:	0164b423          	sd	s6,8(s1)
    cmd->file = file;
     2f2:	0154b823          	sd	s5,16(s1)
    cmd->efile = efile;
     2f6:	0144bc23          	sd	s4,24(s1)
    cmd->mode = mode;
     2fa:	0334a023          	sw	s3,32(s1)
    cmd->fd = fd;
     2fe:	0324a223          	sw	s2,36(s1)
    return (struct cmd *)cmd;
}
     302:	8526                	mv	a0,s1
     304:	70e2                	ld	ra,56(sp)
     306:	7442                	ld	s0,48(sp)
     308:	74a2                	ld	s1,40(sp)
     30a:	7902                	ld	s2,32(sp)
     30c:	69e2                	ld	s3,24(sp)
     30e:	6a42                	ld	s4,16(sp)
     310:	6aa2                	ld	s5,8(sp)
     312:	6b02                	ld	s6,0(sp)
     314:	6121                	addi	sp,sp,64
     316:	8082                	ret

0000000000000318 <pipecmd>:

struct cmd *
pipecmd(struct cmd *left, struct cmd *right)
{
     318:	7179                	addi	sp,sp,-48
     31a:	f406                	sd	ra,40(sp)
     31c:	f022                	sd	s0,32(sp)
     31e:	ec26                	sd	s1,24(sp)
     320:	e84a                	sd	s2,16(sp)
     322:	e44e                	sd	s3,8(sp)
     324:	1800                	addi	s0,sp,48
     326:	89aa                	mv	s3,a0
     328:	892e                	mv	s2,a1
    struct pipecmd *cmd;

    cmd = malloc(sizeof(*cmd));
     32a:	4561                	li	a0,24
     32c:	00001097          	auipc	ra,0x1
     330:	fc8080e7          	jalr	-56(ra) # 12f4 <malloc>
     334:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     336:	4661                	li	a2,24
     338:	4581                	li	a1,0
     33a:	00001097          	auipc	ra,0x1
     33e:	978080e7          	jalr	-1672(ra) # cb2 <memset>
    cmd->type = PIPE;
     342:	478d                	li	a5,3
     344:	c09c                	sw	a5,0(s1)
    cmd->left = left;
     346:	0134b423          	sd	s3,8(s1)
    cmd->right = right;
     34a:	0124b823          	sd	s2,16(s1)
    return (struct cmd *)cmd;
}
     34e:	8526                	mv	a0,s1
     350:	70a2                	ld	ra,40(sp)
     352:	7402                	ld	s0,32(sp)
     354:	64e2                	ld	s1,24(sp)
     356:	6942                	ld	s2,16(sp)
     358:	69a2                	ld	s3,8(sp)
     35a:	6145                	addi	sp,sp,48
     35c:	8082                	ret

000000000000035e <listcmd>:

struct cmd *
listcmd(struct cmd *left, struct cmd *right)
{
     35e:	7179                	addi	sp,sp,-48
     360:	f406                	sd	ra,40(sp)
     362:	f022                	sd	s0,32(sp)
     364:	ec26                	sd	s1,24(sp)
     366:	e84a                	sd	s2,16(sp)
     368:	e44e                	sd	s3,8(sp)
     36a:	1800                	addi	s0,sp,48
     36c:	89aa                	mv	s3,a0
     36e:	892e                	mv	s2,a1
    struct listcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     370:	4561                	li	a0,24
     372:	00001097          	auipc	ra,0x1
     376:	f82080e7          	jalr	-126(ra) # 12f4 <malloc>
     37a:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     37c:	4661                	li	a2,24
     37e:	4581                	li	a1,0
     380:	00001097          	auipc	ra,0x1
     384:	932080e7          	jalr	-1742(ra) # cb2 <memset>
    cmd->type = LIST;
     388:	4791                	li	a5,4
     38a:	c09c                	sw	a5,0(s1)
    cmd->left = left;
     38c:	0134b423          	sd	s3,8(s1)
    cmd->right = right;
     390:	0124b823          	sd	s2,16(s1)
    return (struct cmd *)cmd;
}
     394:	8526                	mv	a0,s1
     396:	70a2                	ld	ra,40(sp)
     398:	7402                	ld	s0,32(sp)
     39a:	64e2                	ld	s1,24(sp)
     39c:	6942                	ld	s2,16(sp)
     39e:	69a2                	ld	s3,8(sp)
     3a0:	6145                	addi	sp,sp,48
     3a2:	8082                	ret

00000000000003a4 <backcmd>:

struct cmd *
backcmd(struct cmd *subcmd)
{
     3a4:	1101                	addi	sp,sp,-32
     3a6:	ec06                	sd	ra,24(sp)
     3a8:	e822                	sd	s0,16(sp)
     3aa:	e426                	sd	s1,8(sp)
     3ac:	e04a                	sd	s2,0(sp)
     3ae:	1000                	addi	s0,sp,32
     3b0:	892a                	mv	s2,a0
    struct backcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     3b2:	4541                	li	a0,16
     3b4:	00001097          	auipc	ra,0x1
     3b8:	f40080e7          	jalr	-192(ra) # 12f4 <malloc>
     3bc:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     3be:	4641                	li	a2,16
     3c0:	4581                	li	a1,0
     3c2:	00001097          	auipc	ra,0x1
     3c6:	8f0080e7          	jalr	-1808(ra) # cb2 <memset>
    cmd->type = BACK;
     3ca:	4795                	li	a5,5
     3cc:	c09c                	sw	a5,0(s1)
    cmd->cmd = subcmd;
     3ce:	0124b423          	sd	s2,8(s1)
    return (struct cmd *)cmd;
}
     3d2:	8526                	mv	a0,s1
     3d4:	60e2                	ld	ra,24(sp)
     3d6:	6442                	ld	s0,16(sp)
     3d8:	64a2                	ld	s1,8(sp)
     3da:	6902                	ld	s2,0(sp)
     3dc:	6105                	addi	sp,sp,32
     3de:	8082                	ret

00000000000003e0 <gettoken>:

char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int gettoken(char **ps, char *es, char **q, char **eq)
{
     3e0:	7139                	addi	sp,sp,-64
     3e2:	fc06                	sd	ra,56(sp)
     3e4:	f822                	sd	s0,48(sp)
     3e6:	f426                	sd	s1,40(sp)
     3e8:	f04a                	sd	s2,32(sp)
     3ea:	ec4e                	sd	s3,24(sp)
     3ec:	e852                	sd	s4,16(sp)
     3ee:	e456                	sd	s5,8(sp)
     3f0:	e05a                	sd	s6,0(sp)
     3f2:	0080                	addi	s0,sp,64
     3f4:	8a2a                	mv	s4,a0
     3f6:	892e                	mv	s2,a1
     3f8:	8ab2                	mv	s5,a2
     3fa:	8b36                	mv	s6,a3
    char *s;
    int ret;

    s = *ps;
     3fc:	6104                	ld	s1,0(a0)
    while (s < es && strchr(whitespace, *s))
     3fe:	00002997          	auipc	s3,0x2
     402:	40a98993          	addi	s3,s3,1034 # 2808 <whitespace>
     406:	00b4fe63          	bgeu	s1,a1,422 <gettoken+0x42>
     40a:	0004c583          	lbu	a1,0(s1)
     40e:	854e                	mv	a0,s3
     410:	00001097          	auipc	ra,0x1
     414:	8c4080e7          	jalr	-1852(ra) # cd4 <strchr>
     418:	c509                	beqz	a0,422 <gettoken+0x42>
        s++;
     41a:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     41c:	fe9917e3          	bne	s2,s1,40a <gettoken+0x2a>
     420:	84ca                	mv	s1,s2
    if (q)
     422:	000a8463          	beqz	s5,42a <gettoken+0x4a>
        *q = s;
     426:	009ab023          	sd	s1,0(s5)
    ret = *s;
     42a:	0004c783          	lbu	a5,0(s1)
     42e:	00078a9b          	sext.w	s5,a5
    switch (*s)
     432:	03c00713          	li	a4,60
     436:	06f76663          	bltu	a4,a5,4a2 <gettoken+0xc2>
     43a:	03a00713          	li	a4,58
     43e:	00f76e63          	bltu	a4,a5,45a <gettoken+0x7a>
     442:	cf89                	beqz	a5,45c <gettoken+0x7c>
     444:	02600713          	li	a4,38
     448:	00e78963          	beq	a5,a4,45a <gettoken+0x7a>
     44c:	fd87879b          	addiw	a5,a5,-40
     450:	0ff7f793          	zext.b	a5,a5
     454:	4705                	li	a4,1
     456:	06f76d63          	bltu	a4,a5,4d0 <gettoken+0xf0>
    case '(':
    case ')':
    case ';':
    case '&':
    case '<':
        s++;
     45a:	0485                	addi	s1,s1,1
        ret = 'a';
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
            s++;
        break;
    }
    if (eq)
     45c:	000b0463          	beqz	s6,464 <gettoken+0x84>
        *eq = s;
     460:	009b3023          	sd	s1,0(s6)

    while (s < es && strchr(whitespace, *s))
     464:	00002997          	auipc	s3,0x2
     468:	3a498993          	addi	s3,s3,932 # 2808 <whitespace>
     46c:	0124fe63          	bgeu	s1,s2,488 <gettoken+0xa8>
     470:	0004c583          	lbu	a1,0(s1)
     474:	854e                	mv	a0,s3
     476:	00001097          	auipc	ra,0x1
     47a:	85e080e7          	jalr	-1954(ra) # cd4 <strchr>
     47e:	c509                	beqz	a0,488 <gettoken+0xa8>
        s++;
     480:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     482:	fe9917e3          	bne	s2,s1,470 <gettoken+0x90>
     486:	84ca                	mv	s1,s2
    *ps = s;
     488:	009a3023          	sd	s1,0(s4)
    return ret;
}
     48c:	8556                	mv	a0,s5
     48e:	70e2                	ld	ra,56(sp)
     490:	7442                	ld	s0,48(sp)
     492:	74a2                	ld	s1,40(sp)
     494:	7902                	ld	s2,32(sp)
     496:	69e2                	ld	s3,24(sp)
     498:	6a42                	ld	s4,16(sp)
     49a:	6aa2                	ld	s5,8(sp)
     49c:	6b02                	ld	s6,0(sp)
     49e:	6121                	addi	sp,sp,64
     4a0:	8082                	ret
    switch (*s)
     4a2:	03e00713          	li	a4,62
     4a6:	02e79163          	bne	a5,a4,4c8 <gettoken+0xe8>
        s++;
     4aa:	00148693          	addi	a3,s1,1
        if (*s == '>')
     4ae:	0014c703          	lbu	a4,1(s1)
     4b2:	03e00793          	li	a5,62
            s++;
     4b6:	0489                	addi	s1,s1,2
            ret = '+';
     4b8:	02b00a93          	li	s5,43
        if (*s == '>')
     4bc:	faf700e3          	beq	a4,a5,45c <gettoken+0x7c>
        s++;
     4c0:	84b6                	mv	s1,a3
    ret = *s;
     4c2:	03e00a93          	li	s5,62
     4c6:	bf59                	j	45c <gettoken+0x7c>
    switch (*s)
     4c8:	07c00713          	li	a4,124
     4cc:	f8e787e3          	beq	a5,a4,45a <gettoken+0x7a>
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4d0:	00002997          	auipc	s3,0x2
     4d4:	33898993          	addi	s3,s3,824 # 2808 <whitespace>
     4d8:	00002a97          	auipc	s5,0x2
     4dc:	328a8a93          	addi	s5,s5,808 # 2800 <symbols>
     4e0:	0524f163          	bgeu	s1,s2,522 <gettoken+0x142>
     4e4:	0004c583          	lbu	a1,0(s1)
     4e8:	854e                	mv	a0,s3
     4ea:	00000097          	auipc	ra,0x0
     4ee:	7ea080e7          	jalr	2026(ra) # cd4 <strchr>
     4f2:	e50d                	bnez	a0,51c <gettoken+0x13c>
     4f4:	0004c583          	lbu	a1,0(s1)
     4f8:	8556                	mv	a0,s5
     4fa:	00000097          	auipc	ra,0x0
     4fe:	7da080e7          	jalr	2010(ra) # cd4 <strchr>
     502:	e911                	bnez	a0,516 <gettoken+0x136>
            s++;
     504:	0485                	addi	s1,s1,1
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     506:	fc991fe3          	bne	s2,s1,4e4 <gettoken+0x104>
    if (eq)
     50a:	84ca                	mv	s1,s2
        ret = 'a';
     50c:	06100a93          	li	s5,97
    if (eq)
     510:	f40b18e3          	bnez	s6,460 <gettoken+0x80>
     514:	bf95                	j	488 <gettoken+0xa8>
        ret = 'a';
     516:	06100a93          	li	s5,97
     51a:	b789                	j	45c <gettoken+0x7c>
     51c:	06100a93          	li	s5,97
     520:	bf35                	j	45c <gettoken+0x7c>
     522:	06100a93          	li	s5,97
    if (eq)
     526:	f20b1de3          	bnez	s6,460 <gettoken+0x80>
     52a:	bfb9                	j	488 <gettoken+0xa8>

000000000000052c <peek>:

int peek(char **ps, char *es, char *toks)
{
     52c:	7139                	addi	sp,sp,-64
     52e:	fc06                	sd	ra,56(sp)
     530:	f822                	sd	s0,48(sp)
     532:	f426                	sd	s1,40(sp)
     534:	f04a                	sd	s2,32(sp)
     536:	ec4e                	sd	s3,24(sp)
     538:	e852                	sd	s4,16(sp)
     53a:	e456                	sd	s5,8(sp)
     53c:	0080                	addi	s0,sp,64
     53e:	8a2a                	mv	s4,a0
     540:	892e                	mv	s2,a1
     542:	8ab2                	mv	s5,a2
    char *s;

    s = *ps;
     544:	6104                	ld	s1,0(a0)
    while (s < es && strchr(whitespace, *s))
     546:	00002997          	auipc	s3,0x2
     54a:	2c298993          	addi	s3,s3,706 # 2808 <whitespace>
     54e:	00b4fe63          	bgeu	s1,a1,56a <peek+0x3e>
     552:	0004c583          	lbu	a1,0(s1)
     556:	854e                	mv	a0,s3
     558:	00000097          	auipc	ra,0x0
     55c:	77c080e7          	jalr	1916(ra) # cd4 <strchr>
     560:	c509                	beqz	a0,56a <peek+0x3e>
        s++;
     562:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     564:	fe9917e3          	bne	s2,s1,552 <peek+0x26>
     568:	84ca                	mv	s1,s2
    *ps = s;
     56a:	009a3023          	sd	s1,0(s4)
    return *s && strchr(toks, *s);
     56e:	0004c583          	lbu	a1,0(s1)
     572:	4501                	li	a0,0
     574:	e991                	bnez	a1,588 <peek+0x5c>
}
     576:	70e2                	ld	ra,56(sp)
     578:	7442                	ld	s0,48(sp)
     57a:	74a2                	ld	s1,40(sp)
     57c:	7902                	ld	s2,32(sp)
     57e:	69e2                	ld	s3,24(sp)
     580:	6a42                	ld	s4,16(sp)
     582:	6aa2                	ld	s5,8(sp)
     584:	6121                	addi	sp,sp,64
     586:	8082                	ret
    return *s && strchr(toks, *s);
     588:	8556                	mv	a0,s5
     58a:	00000097          	auipc	ra,0x0
     58e:	74a080e7          	jalr	1866(ra) # cd4 <strchr>
     592:	00a03533          	snez	a0,a0
     596:	b7c5                	j	576 <peek+0x4a>

0000000000000598 <parseredirs>:
    return cmd;
}

struct cmd *
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     598:	711d                	addi	sp,sp,-96
     59a:	ec86                	sd	ra,88(sp)
     59c:	e8a2                	sd	s0,80(sp)
     59e:	e4a6                	sd	s1,72(sp)
     5a0:	e0ca                	sd	s2,64(sp)
     5a2:	fc4e                	sd	s3,56(sp)
     5a4:	f852                	sd	s4,48(sp)
     5a6:	f456                	sd	s5,40(sp)
     5a8:	f05a                	sd	s6,32(sp)
     5aa:	ec5e                	sd	s7,24(sp)
     5ac:	1080                	addi	s0,sp,96
     5ae:	8a2a                	mv	s4,a0
     5b0:	89ae                	mv	s3,a1
     5b2:	8932                	mv	s2,a2
    int tok;
    char *q, *eq;

    while (peek(ps, es, "<>"))
     5b4:	00001a97          	auipc	s5,0x1
     5b8:	ebca8a93          	addi	s5,s5,-324 # 1470 <malloc+0x17c>
    {
        tok = gettoken(ps, es, 0, 0);
        if (gettoken(ps, es, &q, &eq) != 'a')
     5bc:	06100b13          	li	s6,97
            panic("missing file for redirection");
        switch (tok)
     5c0:	03c00b93          	li	s7,60
    while (peek(ps, es, "<>"))
     5c4:	a02d                	j	5ee <parseredirs+0x56>
            panic("missing file for redirection");
     5c6:	00001517          	auipc	a0,0x1
     5ca:	e8a50513          	addi	a0,a0,-374 # 1450 <malloc+0x15c>
     5ce:	00000097          	auipc	ra,0x0
     5d2:	a88080e7          	jalr	-1400(ra) # 56 <panic>
        {
        case '<':
            cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5d6:	4701                	li	a4,0
     5d8:	4681                	li	a3,0
     5da:	fa043603          	ld	a2,-96(s0)
     5de:	fa843583          	ld	a1,-88(s0)
     5e2:	8552                	mv	a0,s4
     5e4:	00000097          	auipc	ra,0x0
     5e8:	ccc080e7          	jalr	-820(ra) # 2b0 <redircmd>
     5ec:	8a2a                	mv	s4,a0
    while (peek(ps, es, "<>"))
     5ee:	8656                	mv	a2,s5
     5f0:	85ca                	mv	a1,s2
     5f2:	854e                	mv	a0,s3
     5f4:	00000097          	auipc	ra,0x0
     5f8:	f38080e7          	jalr	-200(ra) # 52c <peek>
     5fc:	cd25                	beqz	a0,674 <parseredirs+0xdc>
        tok = gettoken(ps, es, 0, 0);
     5fe:	4681                	li	a3,0
     600:	4601                	li	a2,0
     602:	85ca                	mv	a1,s2
     604:	854e                	mv	a0,s3
     606:	00000097          	auipc	ra,0x0
     60a:	dda080e7          	jalr	-550(ra) # 3e0 <gettoken>
     60e:	84aa                	mv	s1,a0
        if (gettoken(ps, es, &q, &eq) != 'a')
     610:	fa040693          	addi	a3,s0,-96
     614:	fa840613          	addi	a2,s0,-88
     618:	85ca                	mv	a1,s2
     61a:	854e                	mv	a0,s3
     61c:	00000097          	auipc	ra,0x0
     620:	dc4080e7          	jalr	-572(ra) # 3e0 <gettoken>
     624:	fb6511e3          	bne	a0,s6,5c6 <parseredirs+0x2e>
        switch (tok)
     628:	fb7487e3          	beq	s1,s7,5d6 <parseredirs+0x3e>
     62c:	03e00793          	li	a5,62
     630:	02f48463          	beq	s1,a5,658 <parseredirs+0xc0>
     634:	02b00793          	li	a5,43
     638:	faf49be3          	bne	s1,a5,5ee <parseredirs+0x56>
            break;
        case '>':
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE | O_TRUNC, 1);
            break;
        case '+': // >>
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE, 1);
     63c:	4705                	li	a4,1
     63e:	20100693          	li	a3,513
     642:	fa043603          	ld	a2,-96(s0)
     646:	fa843583          	ld	a1,-88(s0)
     64a:	8552                	mv	a0,s4
     64c:	00000097          	auipc	ra,0x0
     650:	c64080e7          	jalr	-924(ra) # 2b0 <redircmd>
     654:	8a2a                	mv	s4,a0
            break;
     656:	bf61                	j	5ee <parseredirs+0x56>
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE | O_TRUNC, 1);
     658:	4705                	li	a4,1
     65a:	60100693          	li	a3,1537
     65e:	fa043603          	ld	a2,-96(s0)
     662:	fa843583          	ld	a1,-88(s0)
     666:	8552                	mv	a0,s4
     668:	00000097          	auipc	ra,0x0
     66c:	c48080e7          	jalr	-952(ra) # 2b0 <redircmd>
     670:	8a2a                	mv	s4,a0
            break;
     672:	bfb5                	j	5ee <parseredirs+0x56>
        }
    }
    return cmd;
}
     674:	8552                	mv	a0,s4
     676:	60e6                	ld	ra,88(sp)
     678:	6446                	ld	s0,80(sp)
     67a:	64a6                	ld	s1,72(sp)
     67c:	6906                	ld	s2,64(sp)
     67e:	79e2                	ld	s3,56(sp)
     680:	7a42                	ld	s4,48(sp)
     682:	7aa2                	ld	s5,40(sp)
     684:	7b02                	ld	s6,32(sp)
     686:	6be2                	ld	s7,24(sp)
     688:	6125                	addi	sp,sp,96
     68a:	8082                	ret

000000000000068c <parseexec>:
    return cmd;
}

struct cmd *
parseexec(char **ps, char *es)
{
     68c:	7159                	addi	sp,sp,-112
     68e:	f486                	sd	ra,104(sp)
     690:	f0a2                	sd	s0,96(sp)
     692:	eca6                	sd	s1,88(sp)
     694:	e0d2                	sd	s4,64(sp)
     696:	fc56                	sd	s5,56(sp)
     698:	1880                	addi	s0,sp,112
     69a:	8a2a                	mv	s4,a0
     69c:	8aae                	mv	s5,a1
    char *q, *eq;
    int tok, argc;
    struct execcmd *cmd;
    struct cmd *ret;

    if (peek(ps, es, "("))
     69e:	00001617          	auipc	a2,0x1
     6a2:	dda60613          	addi	a2,a2,-550 # 1478 <malloc+0x184>
     6a6:	00000097          	auipc	ra,0x0
     6aa:	e86080e7          	jalr	-378(ra) # 52c <peek>
     6ae:	ed15                	bnez	a0,6ea <parseexec+0x5e>
     6b0:	e8ca                	sd	s2,80(sp)
     6b2:	e4ce                	sd	s3,72(sp)
     6b4:	f85a                	sd	s6,48(sp)
     6b6:	f45e                	sd	s7,40(sp)
     6b8:	f062                	sd	s8,32(sp)
     6ba:	ec66                	sd	s9,24(sp)
     6bc:	89aa                	mv	s3,a0
        return parseblock(ps, es);

    ret = execcmd();
     6be:	00000097          	auipc	ra,0x0
     6c2:	bbc080e7          	jalr	-1092(ra) # 27a <execcmd>
     6c6:	8c2a                	mv	s8,a0
    cmd = (struct execcmd *)ret;

    argc = 0;
    ret = parseredirs(ret, ps, es);
     6c8:	8656                	mv	a2,s5
     6ca:	85d2                	mv	a1,s4
     6cc:	00000097          	auipc	ra,0x0
     6d0:	ecc080e7          	jalr	-308(ra) # 598 <parseredirs>
     6d4:	84aa                	mv	s1,a0
    while (!peek(ps, es, "|)&;"))
     6d6:	008c0913          	addi	s2,s8,8
     6da:	00001b17          	auipc	s6,0x1
     6de:	dbeb0b13          	addi	s6,s6,-578 # 1498 <malloc+0x1a4>
    {
        if ((tok = gettoken(ps, es, &q, &eq)) == 0)
            break;
        if (tok != 'a')
     6e2:	06100c93          	li	s9,97
            panic("syntax");
        cmd->argv[argc] = q;
        cmd->eargv[argc] = eq;
        argc++;
        if (argc >= MAXARGS)
     6e6:	4ba9                	li	s7,10
    while (!peek(ps, es, "|)&;"))
     6e8:	a081                	j	728 <parseexec+0x9c>
        return parseblock(ps, es);
     6ea:	85d6                	mv	a1,s5
     6ec:	8552                	mv	a0,s4
     6ee:	00000097          	auipc	ra,0x0
     6f2:	1bc080e7          	jalr	444(ra) # 8aa <parseblock>
     6f6:	84aa                	mv	s1,a0
        ret = parseredirs(ret, ps, es);
    }
    cmd->argv[argc] = 0;
    cmd->eargv[argc] = 0;
    return ret;
}
     6f8:	8526                	mv	a0,s1
     6fa:	70a6                	ld	ra,104(sp)
     6fc:	7406                	ld	s0,96(sp)
     6fe:	64e6                	ld	s1,88(sp)
     700:	6a06                	ld	s4,64(sp)
     702:	7ae2                	ld	s5,56(sp)
     704:	6165                	addi	sp,sp,112
     706:	8082                	ret
            panic("syntax");
     708:	00001517          	auipc	a0,0x1
     70c:	d7850513          	addi	a0,a0,-648 # 1480 <malloc+0x18c>
     710:	00000097          	auipc	ra,0x0
     714:	946080e7          	jalr	-1722(ra) # 56 <panic>
        ret = parseredirs(ret, ps, es);
     718:	8656                	mv	a2,s5
     71a:	85d2                	mv	a1,s4
     71c:	8526                	mv	a0,s1
     71e:	00000097          	auipc	ra,0x0
     722:	e7a080e7          	jalr	-390(ra) # 598 <parseredirs>
     726:	84aa                	mv	s1,a0
    while (!peek(ps, es, "|)&;"))
     728:	865a                	mv	a2,s6
     72a:	85d6                	mv	a1,s5
     72c:	8552                	mv	a0,s4
     72e:	00000097          	auipc	ra,0x0
     732:	dfe080e7          	jalr	-514(ra) # 52c <peek>
     736:	e131                	bnez	a0,77a <parseexec+0xee>
        if ((tok = gettoken(ps, es, &q, &eq)) == 0)
     738:	f9040693          	addi	a3,s0,-112
     73c:	f9840613          	addi	a2,s0,-104
     740:	85d6                	mv	a1,s5
     742:	8552                	mv	a0,s4
     744:	00000097          	auipc	ra,0x0
     748:	c9c080e7          	jalr	-868(ra) # 3e0 <gettoken>
     74c:	c51d                	beqz	a0,77a <parseexec+0xee>
        if (tok != 'a')
     74e:	fb951de3          	bne	a0,s9,708 <parseexec+0x7c>
        cmd->argv[argc] = q;
     752:	f9843783          	ld	a5,-104(s0)
     756:	00f93023          	sd	a5,0(s2)
        cmd->eargv[argc] = eq;
     75a:	f9043783          	ld	a5,-112(s0)
     75e:	04f93823          	sd	a5,80(s2)
        argc++;
     762:	2985                	addiw	s3,s3,1
        if (argc >= MAXARGS)
     764:	0921                	addi	s2,s2,8
     766:	fb7999e3          	bne	s3,s7,718 <parseexec+0x8c>
            panic("too many args");
     76a:	00001517          	auipc	a0,0x1
     76e:	d1e50513          	addi	a0,a0,-738 # 1488 <malloc+0x194>
     772:	00000097          	auipc	ra,0x0
     776:	8e4080e7          	jalr	-1820(ra) # 56 <panic>
    cmd->argv[argc] = 0;
     77a:	098e                	slli	s3,s3,0x3
     77c:	9c4e                	add	s8,s8,s3
     77e:	000c3423          	sd	zero,8(s8)
    cmd->eargv[argc] = 0;
     782:	040c3c23          	sd	zero,88(s8)
     786:	6946                	ld	s2,80(sp)
     788:	69a6                	ld	s3,72(sp)
     78a:	7b42                	ld	s6,48(sp)
     78c:	7ba2                	ld	s7,40(sp)
     78e:	7c02                	ld	s8,32(sp)
     790:	6ce2                	ld	s9,24(sp)
    return ret;
     792:	b79d                	j	6f8 <parseexec+0x6c>

0000000000000794 <parsepipe>:
{
     794:	7179                	addi	sp,sp,-48
     796:	f406                	sd	ra,40(sp)
     798:	f022                	sd	s0,32(sp)
     79a:	ec26                	sd	s1,24(sp)
     79c:	e84a                	sd	s2,16(sp)
     79e:	e44e                	sd	s3,8(sp)
     7a0:	1800                	addi	s0,sp,48
     7a2:	892a                	mv	s2,a0
     7a4:	89ae                	mv	s3,a1
    cmd = parseexec(ps, es);
     7a6:	00000097          	auipc	ra,0x0
     7aa:	ee6080e7          	jalr	-282(ra) # 68c <parseexec>
     7ae:	84aa                	mv	s1,a0
    if (peek(ps, es, "|"))
     7b0:	00001617          	auipc	a2,0x1
     7b4:	cf060613          	addi	a2,a2,-784 # 14a0 <malloc+0x1ac>
     7b8:	85ce                	mv	a1,s3
     7ba:	854a                	mv	a0,s2
     7bc:	00000097          	auipc	ra,0x0
     7c0:	d70080e7          	jalr	-656(ra) # 52c <peek>
     7c4:	e909                	bnez	a0,7d6 <parsepipe+0x42>
}
     7c6:	8526                	mv	a0,s1
     7c8:	70a2                	ld	ra,40(sp)
     7ca:	7402                	ld	s0,32(sp)
     7cc:	64e2                	ld	s1,24(sp)
     7ce:	6942                	ld	s2,16(sp)
     7d0:	69a2                	ld	s3,8(sp)
     7d2:	6145                	addi	sp,sp,48
     7d4:	8082                	ret
        gettoken(ps, es, 0, 0);
     7d6:	4681                	li	a3,0
     7d8:	4601                	li	a2,0
     7da:	85ce                	mv	a1,s3
     7dc:	854a                	mv	a0,s2
     7de:	00000097          	auipc	ra,0x0
     7e2:	c02080e7          	jalr	-1022(ra) # 3e0 <gettoken>
        cmd = pipecmd(cmd, parsepipe(ps, es));
     7e6:	85ce                	mv	a1,s3
     7e8:	854a                	mv	a0,s2
     7ea:	00000097          	auipc	ra,0x0
     7ee:	faa080e7          	jalr	-86(ra) # 794 <parsepipe>
     7f2:	85aa                	mv	a1,a0
     7f4:	8526                	mv	a0,s1
     7f6:	00000097          	auipc	ra,0x0
     7fa:	b22080e7          	jalr	-1246(ra) # 318 <pipecmd>
     7fe:	84aa                	mv	s1,a0
    return cmd;
     800:	b7d9                	j	7c6 <parsepipe+0x32>

0000000000000802 <parseline>:
{
     802:	7179                	addi	sp,sp,-48
     804:	f406                	sd	ra,40(sp)
     806:	f022                	sd	s0,32(sp)
     808:	ec26                	sd	s1,24(sp)
     80a:	e84a                	sd	s2,16(sp)
     80c:	e44e                	sd	s3,8(sp)
     80e:	e052                	sd	s4,0(sp)
     810:	1800                	addi	s0,sp,48
     812:	892a                	mv	s2,a0
     814:	89ae                	mv	s3,a1
    cmd = parsepipe(ps, es);
     816:	00000097          	auipc	ra,0x0
     81a:	f7e080e7          	jalr	-130(ra) # 794 <parsepipe>
     81e:	84aa                	mv	s1,a0
    while (peek(ps, es, "&"))
     820:	00001a17          	auipc	s4,0x1
     824:	c88a0a13          	addi	s4,s4,-888 # 14a8 <malloc+0x1b4>
     828:	a839                	j	846 <parseline+0x44>
        gettoken(ps, es, 0, 0);
     82a:	4681                	li	a3,0
     82c:	4601                	li	a2,0
     82e:	85ce                	mv	a1,s3
     830:	854a                	mv	a0,s2
     832:	00000097          	auipc	ra,0x0
     836:	bae080e7          	jalr	-1106(ra) # 3e0 <gettoken>
        cmd = backcmd(cmd);
     83a:	8526                	mv	a0,s1
     83c:	00000097          	auipc	ra,0x0
     840:	b68080e7          	jalr	-1176(ra) # 3a4 <backcmd>
     844:	84aa                	mv	s1,a0
    while (peek(ps, es, "&"))
     846:	8652                	mv	a2,s4
     848:	85ce                	mv	a1,s3
     84a:	854a                	mv	a0,s2
     84c:	00000097          	auipc	ra,0x0
     850:	ce0080e7          	jalr	-800(ra) # 52c <peek>
     854:	f979                	bnez	a0,82a <parseline+0x28>
    if (peek(ps, es, ";"))
     856:	00001617          	auipc	a2,0x1
     85a:	c5a60613          	addi	a2,a2,-934 # 14b0 <malloc+0x1bc>
     85e:	85ce                	mv	a1,s3
     860:	854a                	mv	a0,s2
     862:	00000097          	auipc	ra,0x0
     866:	cca080e7          	jalr	-822(ra) # 52c <peek>
     86a:	e911                	bnez	a0,87e <parseline+0x7c>
}
     86c:	8526                	mv	a0,s1
     86e:	70a2                	ld	ra,40(sp)
     870:	7402                	ld	s0,32(sp)
     872:	64e2                	ld	s1,24(sp)
     874:	6942                	ld	s2,16(sp)
     876:	69a2                	ld	s3,8(sp)
     878:	6a02                	ld	s4,0(sp)
     87a:	6145                	addi	sp,sp,48
     87c:	8082                	ret
        gettoken(ps, es, 0, 0);
     87e:	4681                	li	a3,0
     880:	4601                	li	a2,0
     882:	85ce                	mv	a1,s3
     884:	854a                	mv	a0,s2
     886:	00000097          	auipc	ra,0x0
     88a:	b5a080e7          	jalr	-1190(ra) # 3e0 <gettoken>
        cmd = listcmd(cmd, parseline(ps, es));
     88e:	85ce                	mv	a1,s3
     890:	854a                	mv	a0,s2
     892:	00000097          	auipc	ra,0x0
     896:	f70080e7          	jalr	-144(ra) # 802 <parseline>
     89a:	85aa                	mv	a1,a0
     89c:	8526                	mv	a0,s1
     89e:	00000097          	auipc	ra,0x0
     8a2:	ac0080e7          	jalr	-1344(ra) # 35e <listcmd>
     8a6:	84aa                	mv	s1,a0
    return cmd;
     8a8:	b7d1                	j	86c <parseline+0x6a>

00000000000008aa <parseblock>:
{
     8aa:	7179                	addi	sp,sp,-48
     8ac:	f406                	sd	ra,40(sp)
     8ae:	f022                	sd	s0,32(sp)
     8b0:	ec26                	sd	s1,24(sp)
     8b2:	e84a                	sd	s2,16(sp)
     8b4:	e44e                	sd	s3,8(sp)
     8b6:	1800                	addi	s0,sp,48
     8b8:	84aa                	mv	s1,a0
     8ba:	892e                	mv	s2,a1
    if (!peek(ps, es, "("))
     8bc:	00001617          	auipc	a2,0x1
     8c0:	bbc60613          	addi	a2,a2,-1092 # 1478 <malloc+0x184>
     8c4:	00000097          	auipc	ra,0x0
     8c8:	c68080e7          	jalr	-920(ra) # 52c <peek>
     8cc:	c12d                	beqz	a0,92e <parseblock+0x84>
    gettoken(ps, es, 0, 0);
     8ce:	4681                	li	a3,0
     8d0:	4601                	li	a2,0
     8d2:	85ca                	mv	a1,s2
     8d4:	8526                	mv	a0,s1
     8d6:	00000097          	auipc	ra,0x0
     8da:	b0a080e7          	jalr	-1270(ra) # 3e0 <gettoken>
    cmd = parseline(ps, es);
     8de:	85ca                	mv	a1,s2
     8e0:	8526                	mv	a0,s1
     8e2:	00000097          	auipc	ra,0x0
     8e6:	f20080e7          	jalr	-224(ra) # 802 <parseline>
     8ea:	89aa                	mv	s3,a0
    if (!peek(ps, es, ")"))
     8ec:	00001617          	auipc	a2,0x1
     8f0:	bdc60613          	addi	a2,a2,-1060 # 14c8 <malloc+0x1d4>
     8f4:	85ca                	mv	a1,s2
     8f6:	8526                	mv	a0,s1
     8f8:	00000097          	auipc	ra,0x0
     8fc:	c34080e7          	jalr	-972(ra) # 52c <peek>
     900:	cd1d                	beqz	a0,93e <parseblock+0x94>
    gettoken(ps, es, 0, 0);
     902:	4681                	li	a3,0
     904:	4601                	li	a2,0
     906:	85ca                	mv	a1,s2
     908:	8526                	mv	a0,s1
     90a:	00000097          	auipc	ra,0x0
     90e:	ad6080e7          	jalr	-1322(ra) # 3e0 <gettoken>
    cmd = parseredirs(cmd, ps, es);
     912:	864a                	mv	a2,s2
     914:	85a6                	mv	a1,s1
     916:	854e                	mv	a0,s3
     918:	00000097          	auipc	ra,0x0
     91c:	c80080e7          	jalr	-896(ra) # 598 <parseredirs>
}
     920:	70a2                	ld	ra,40(sp)
     922:	7402                	ld	s0,32(sp)
     924:	64e2                	ld	s1,24(sp)
     926:	6942                	ld	s2,16(sp)
     928:	69a2                	ld	s3,8(sp)
     92a:	6145                	addi	sp,sp,48
     92c:	8082                	ret
        panic("parseblock");
     92e:	00001517          	auipc	a0,0x1
     932:	b8a50513          	addi	a0,a0,-1142 # 14b8 <malloc+0x1c4>
     936:	fffff097          	auipc	ra,0xfffff
     93a:	720080e7          	jalr	1824(ra) # 56 <panic>
        panic("syntax - missing )");
     93e:	00001517          	auipc	a0,0x1
     942:	b9250513          	addi	a0,a0,-1134 # 14d0 <malloc+0x1dc>
     946:	fffff097          	auipc	ra,0xfffff
     94a:	710080e7          	jalr	1808(ra) # 56 <panic>

000000000000094e <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd *
nulterminate(struct cmd *cmd)
{
     94e:	1101                	addi	sp,sp,-32
     950:	ec06                	sd	ra,24(sp)
     952:	e822                	sd	s0,16(sp)
     954:	e426                	sd	s1,8(sp)
     956:	1000                	addi	s0,sp,32
     958:	84aa                	mv	s1,a0
    struct execcmd *ecmd;
    struct listcmd *lcmd;
    struct pipecmd *pcmd;
    struct redircmd *rcmd;

    if (cmd == 0)
     95a:	c521                	beqz	a0,9a2 <nulterminate+0x54>
        return 0;

    switch (cmd->type)
     95c:	4118                	lw	a4,0(a0)
     95e:	4795                	li	a5,5
     960:	04e7e163          	bltu	a5,a4,9a2 <nulterminate+0x54>
     964:	00056783          	lwu	a5,0(a0)
     968:	078a                	slli	a5,a5,0x2
     96a:	00001717          	auipc	a4,0x1
     96e:	bde70713          	addi	a4,a4,-1058 # 1548 <malloc+0x254>
     972:	97ba                	add	a5,a5,a4
     974:	439c                	lw	a5,0(a5)
     976:	97ba                	add	a5,a5,a4
     978:	8782                	jr	a5
    {
    case EXEC:
        ecmd = (struct execcmd *)cmd;
        for (i = 0; ecmd->argv[i]; i++)
     97a:	651c                	ld	a5,8(a0)
     97c:	c39d                	beqz	a5,9a2 <nulterminate+0x54>
     97e:	01050793          	addi	a5,a0,16
            *ecmd->eargv[i] = 0;
     982:	67b8                	ld	a4,72(a5)
     984:	00070023          	sb	zero,0(a4)
        for (i = 0; ecmd->argv[i]; i++)
     988:	07a1                	addi	a5,a5,8
     98a:	ff87b703          	ld	a4,-8(a5)
     98e:	fb75                	bnez	a4,982 <nulterminate+0x34>
     990:	a809                	j	9a2 <nulterminate+0x54>
        break;

    case REDIR:
        rcmd = (struct redircmd *)cmd;
        nulterminate(rcmd->cmd);
     992:	6508                	ld	a0,8(a0)
     994:	00000097          	auipc	ra,0x0
     998:	fba080e7          	jalr	-70(ra) # 94e <nulterminate>
        *rcmd->efile = 0;
     99c:	6c9c                	ld	a5,24(s1)
     99e:	00078023          	sb	zero,0(a5)
        bcmd = (struct backcmd *)cmd;
        nulterminate(bcmd->cmd);
        break;
    }
    return cmd;
}
     9a2:	8526                	mv	a0,s1
     9a4:	60e2                	ld	ra,24(sp)
     9a6:	6442                	ld	s0,16(sp)
     9a8:	64a2                	ld	s1,8(sp)
     9aa:	6105                	addi	sp,sp,32
     9ac:	8082                	ret
        nulterminate(pcmd->left);
     9ae:	6508                	ld	a0,8(a0)
     9b0:	00000097          	auipc	ra,0x0
     9b4:	f9e080e7          	jalr	-98(ra) # 94e <nulterminate>
        nulterminate(pcmd->right);
     9b8:	6888                	ld	a0,16(s1)
     9ba:	00000097          	auipc	ra,0x0
     9be:	f94080e7          	jalr	-108(ra) # 94e <nulterminate>
        break;
     9c2:	b7c5                	j	9a2 <nulterminate+0x54>
        nulterminate(lcmd->left);
     9c4:	6508                	ld	a0,8(a0)
     9c6:	00000097          	auipc	ra,0x0
     9ca:	f88080e7          	jalr	-120(ra) # 94e <nulterminate>
        nulterminate(lcmd->right);
     9ce:	6888                	ld	a0,16(s1)
     9d0:	00000097          	auipc	ra,0x0
     9d4:	f7e080e7          	jalr	-130(ra) # 94e <nulterminate>
        break;
     9d8:	b7e9                	j	9a2 <nulterminate+0x54>
        nulterminate(bcmd->cmd);
     9da:	6508                	ld	a0,8(a0)
     9dc:	00000097          	auipc	ra,0x0
     9e0:	f72080e7          	jalr	-142(ra) # 94e <nulterminate>
        break;
     9e4:	bf7d                	j	9a2 <nulterminate+0x54>

00000000000009e6 <parsecmd>:
{
     9e6:	7179                	addi	sp,sp,-48
     9e8:	f406                	sd	ra,40(sp)
     9ea:	f022                	sd	s0,32(sp)
     9ec:	ec26                	sd	s1,24(sp)
     9ee:	e84a                	sd	s2,16(sp)
     9f0:	1800                	addi	s0,sp,48
     9f2:	fca43c23          	sd	a0,-40(s0)
    es = s + strlen(s);
     9f6:	84aa                	mv	s1,a0
     9f8:	00000097          	auipc	ra,0x0
     9fc:	290080e7          	jalr	656(ra) # c88 <strlen>
     a00:	1502                	slli	a0,a0,0x20
     a02:	9101                	srli	a0,a0,0x20
     a04:	94aa                	add	s1,s1,a0
    cmd = parseline(&s, es);
     a06:	85a6                	mv	a1,s1
     a08:	fd840513          	addi	a0,s0,-40
     a0c:	00000097          	auipc	ra,0x0
     a10:	df6080e7          	jalr	-522(ra) # 802 <parseline>
     a14:	892a                	mv	s2,a0
    peek(&s, es, "");
     a16:	00001617          	auipc	a2,0x1
     a1a:	9f260613          	addi	a2,a2,-1550 # 1408 <malloc+0x114>
     a1e:	85a6                	mv	a1,s1
     a20:	fd840513          	addi	a0,s0,-40
     a24:	00000097          	auipc	ra,0x0
     a28:	b08080e7          	jalr	-1272(ra) # 52c <peek>
    if (s != es)
     a2c:	fd843603          	ld	a2,-40(s0)
     a30:	00961e63          	bne	a2,s1,a4c <parsecmd+0x66>
    nulterminate(cmd);
     a34:	854a                	mv	a0,s2
     a36:	00000097          	auipc	ra,0x0
     a3a:	f18080e7          	jalr	-232(ra) # 94e <nulterminate>
}
     a3e:	854a                	mv	a0,s2
     a40:	70a2                	ld	ra,40(sp)
     a42:	7402                	ld	s0,32(sp)
     a44:	64e2                	ld	s1,24(sp)
     a46:	6942                	ld	s2,16(sp)
     a48:	6145                	addi	sp,sp,48
     a4a:	8082                	ret
        fprintf(2, "leftovers: %s\n", s);
     a4c:	00001597          	auipc	a1,0x1
     a50:	a9c58593          	addi	a1,a1,-1380 # 14e8 <malloc+0x1f4>
     a54:	4509                	li	a0,2
     a56:	00000097          	auipc	ra,0x0
     a5a:	7b8080e7          	jalr	1976(ra) # 120e <fprintf>
        panic("syntax");
     a5e:	00001517          	auipc	a0,0x1
     a62:	a2250513          	addi	a0,a0,-1502 # 1480 <malloc+0x18c>
     a66:	fffff097          	auipc	ra,0xfffff
     a6a:	5f0080e7          	jalr	1520(ra) # 56 <panic>

0000000000000a6e <parse_buffer>:
{
     a6e:	1101                	addi	sp,sp,-32
     a70:	ec06                	sd	ra,24(sp)
     a72:	e822                	sd	s0,16(sp)
     a74:	e426                	sd	s1,8(sp)
     a76:	1000                	addi	s0,sp,32
     a78:	84aa                	mv	s1,a0
    if (buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' ')
     a7a:	00054783          	lbu	a5,0(a0)
     a7e:	06300713          	li	a4,99
     a82:	02e78b63          	beq	a5,a4,ab8 <parse_buffer+0x4a>
    if (buf[0] == 'e' &&
     a86:	06500713          	li	a4,101
     a8a:	00e79863          	bne	a5,a4,a9a <parse_buffer+0x2c>
     a8e:	00154703          	lbu	a4,1(a0)
     a92:	07800793          	li	a5,120
     a96:	06f70b63          	beq	a4,a5,b0c <parse_buffer+0x9e>
    if (fork1() == 0)
     a9a:	fffff097          	auipc	ra,0xfffff
     a9e:	5e2080e7          	jalr	1506(ra) # 7c <fork1>
     aa2:	c551                	beqz	a0,b2e <parse_buffer+0xc0>
    wait(0);
     aa4:	4501                	li	a0,0
     aa6:	00000097          	auipc	ra,0x0
     aaa:	40e080e7          	jalr	1038(ra) # eb4 <wait>
}
     aae:	60e2                	ld	ra,24(sp)
     ab0:	6442                	ld	s0,16(sp)
     ab2:	64a2                	ld	s1,8(sp)
     ab4:	6105                	addi	sp,sp,32
     ab6:	8082                	ret
    if (buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' ')
     ab8:	00154703          	lbu	a4,1(a0)
     abc:	06400793          	li	a5,100
     ac0:	fcf71de3          	bne	a4,a5,a9a <parse_buffer+0x2c>
     ac4:	00254703          	lbu	a4,2(a0)
     ac8:	02000793          	li	a5,32
     acc:	fcf717e3          	bne	a4,a5,a9a <parse_buffer+0x2c>
        buf[strlen(buf) - 1] = 0; // chop \n
     ad0:	00000097          	auipc	ra,0x0
     ad4:	1b8080e7          	jalr	440(ra) # c88 <strlen>
     ad8:	fff5079b          	addiw	a5,a0,-1
     adc:	1782                	slli	a5,a5,0x20
     ade:	9381                	srli	a5,a5,0x20
     ae0:	97a6                	add	a5,a5,s1
     ae2:	00078023          	sb	zero,0(a5)
        if (chdir(buf + 3) < 0)
     ae6:	048d                	addi	s1,s1,3
     ae8:	8526                	mv	a0,s1
     aea:	00000097          	auipc	ra,0x0
     aee:	432080e7          	jalr	1074(ra) # f1c <chdir>
     af2:	fa055ee3          	bgez	a0,aae <parse_buffer+0x40>
            fprintf(2, "cannot cd %s\n", buf + 3);
     af6:	8626                	mv	a2,s1
     af8:	00001597          	auipc	a1,0x1
     afc:	a0058593          	addi	a1,a1,-1536 # 14f8 <malloc+0x204>
     b00:	4509                	li	a0,2
     b02:	00000097          	auipc	ra,0x0
     b06:	70c080e7          	jalr	1804(ra) # 120e <fprintf>
     b0a:	b755                	j	aae <parse_buffer+0x40>
        buf[1] == 'x' &&
     b0c:	00254703          	lbu	a4,2(a0)
     b10:	06900793          	li	a5,105
     b14:	f8f713e3          	bne	a4,a5,a9a <parse_buffer+0x2c>
        buf[2] == 'i' &&
     b18:	00354703          	lbu	a4,3(a0)
     b1c:	07400793          	li	a5,116
     b20:	f6f71de3          	bne	a4,a5,a9a <parse_buffer+0x2c>
        exit(0);
     b24:	4501                	li	a0,0
     b26:	00000097          	auipc	ra,0x0
     b2a:	386080e7          	jalr	902(ra) # eac <exit>
        runcmd(parsecmd(buf));
     b2e:	8526                	mv	a0,s1
     b30:	00000097          	auipc	ra,0x0
     b34:	eb6080e7          	jalr	-330(ra) # 9e6 <parsecmd>
     b38:	fffff097          	auipc	ra,0xfffff
     b3c:	572080e7          	jalr	1394(ra) # aa <runcmd>

0000000000000b40 <main>:
{
     b40:	7179                	addi	sp,sp,-48
     b42:	f406                	sd	ra,40(sp)
     b44:	f022                	sd	s0,32(sp)
     b46:	ec26                	sd	s1,24(sp)
     b48:	e84a                	sd	s2,16(sp)
     b4a:	e44e                	sd	s3,8(sp)
     b4c:	1800                	addi	s0,sp,48
     b4e:	892a                	mv	s2,a0
     b50:	89ae                	mv	s3,a1
    while ((fd = open("console", O_RDWR)) >= 0)
     b52:	00001497          	auipc	s1,0x1
     b56:	9b648493          	addi	s1,s1,-1610 # 1508 <malloc+0x214>
     b5a:	4589                	li	a1,2
     b5c:	8526                	mv	a0,s1
     b5e:	00000097          	auipc	ra,0x0
     b62:	38e080e7          	jalr	910(ra) # eec <open>
     b66:	00054963          	bltz	a0,b78 <main+0x38>
        if (fd >= 3)
     b6a:	4789                	li	a5,2
     b6c:	fea7d7e3          	bge	a5,a0,b5a <main+0x1a>
            close(fd);
     b70:	00000097          	auipc	ra,0x0
     b74:	364080e7          	jalr	868(ra) # ed4 <close>
    if (argc == 2)
     b78:	4789                	li	a5,2
    while (getcmd(buf, sizeof(buf)) >= 0)
     b7a:	00002497          	auipc	s1,0x2
     b7e:	ca648493          	addi	s1,s1,-858 # 2820 <buf.0>
    if (argc == 2)
     b82:	08f91463          	bne	s2,a5,c0a <main+0xca>
        char *shell_script_file = argv[1];
     b86:	0089b483          	ld	s1,8(s3)
        int shfd = open(shell_script_file, O_RDWR);
     b8a:	4589                	li	a1,2
     b8c:	8526                	mv	a0,s1
     b8e:	00000097          	auipc	ra,0x0
     b92:	35e080e7          	jalr	862(ra) # eec <open>
     b96:	892a                	mv	s2,a0
        if (shfd < 0)
     b98:	04054663          	bltz	a0,be4 <main+0xa4>
        read(shfd, buf, sizeof(buf));
     b9c:	07800613          	li	a2,120
     ba0:	00002597          	auipc	a1,0x2
     ba4:	c8058593          	addi	a1,a1,-896 # 2820 <buf.0>
     ba8:	00000097          	auipc	ra,0x0
     bac:	31c080e7          	jalr	796(ra) # ec4 <read>
            parse_buffer(buf);
     bb0:	00002497          	auipc	s1,0x2
     bb4:	c7048493          	addi	s1,s1,-912 # 2820 <buf.0>
     bb8:	8526                	mv	a0,s1
     bba:	00000097          	auipc	ra,0x0
     bbe:	eb4080e7          	jalr	-332(ra) # a6e <parse_buffer>
        } while (read(shfd, buf, sizeof(buf)) == sizeof(buf));
     bc2:	07800613          	li	a2,120
     bc6:	85a6                	mv	a1,s1
     bc8:	854a                	mv	a0,s2
     bca:	00000097          	auipc	ra,0x0
     bce:	2fa080e7          	jalr	762(ra) # ec4 <read>
     bd2:	07800793          	li	a5,120
     bd6:	fef501e3          	beq	a0,a5,bb8 <main+0x78>
        exit(0);
     bda:	4501                	li	a0,0
     bdc:	00000097          	auipc	ra,0x0
     be0:	2d0080e7          	jalr	720(ra) # eac <exit>
            printf("Failed to open %s\n", shell_script_file);
     be4:	85a6                	mv	a1,s1
     be6:	00001517          	auipc	a0,0x1
     bea:	92a50513          	addi	a0,a0,-1750 # 1510 <malloc+0x21c>
     bee:	00000097          	auipc	ra,0x0
     bf2:	64e080e7          	jalr	1614(ra) # 123c <printf>
            exit(1);
     bf6:	4505                	li	a0,1
     bf8:	00000097          	auipc	ra,0x0
     bfc:	2b4080e7          	jalr	692(ra) # eac <exit>
        parse_buffer(buf);
     c00:	8526                	mv	a0,s1
     c02:	00000097          	auipc	ra,0x0
     c06:	e6c080e7          	jalr	-404(ra) # a6e <parse_buffer>
    while (getcmd(buf, sizeof(buf)) >= 0)
     c0a:	07800593          	li	a1,120
     c0e:	8526                	mv	a0,s1
     c10:	fffff097          	auipc	ra,0xfffff
     c14:	3f0080e7          	jalr	1008(ra) # 0 <getcmd>
     c18:	fe0554e3          	bgez	a0,c00 <main+0xc0>
    exit(0);
     c1c:	4501                	li	a0,0
     c1e:	00000097          	auipc	ra,0x0
     c22:	28e080e7          	jalr	654(ra) # eac <exit>

0000000000000c26 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     c26:	1141                	addi	sp,sp,-16
     c28:	e406                	sd	ra,8(sp)
     c2a:	e022                	sd	s0,0(sp)
     c2c:	0800                	addi	s0,sp,16
  extern int main();
  main();
     c2e:	00000097          	auipc	ra,0x0
     c32:	f12080e7          	jalr	-238(ra) # b40 <main>
  exit(0);
     c36:	4501                	li	a0,0
     c38:	00000097          	auipc	ra,0x0
     c3c:	274080e7          	jalr	628(ra) # eac <exit>

0000000000000c40 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     c40:	1141                	addi	sp,sp,-16
     c42:	e422                	sd	s0,8(sp)
     c44:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c46:	87aa                	mv	a5,a0
     c48:	0585                	addi	a1,a1,1
     c4a:	0785                	addi	a5,a5,1
     c4c:	fff5c703          	lbu	a4,-1(a1)
     c50:	fee78fa3          	sb	a4,-1(a5)
     c54:	fb75                	bnez	a4,c48 <strcpy+0x8>
    ;
  return os;
}
     c56:	6422                	ld	s0,8(sp)
     c58:	0141                	addi	sp,sp,16
     c5a:	8082                	ret

0000000000000c5c <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c5c:	1141                	addi	sp,sp,-16
     c5e:	e422                	sd	s0,8(sp)
     c60:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c62:	00054783          	lbu	a5,0(a0)
     c66:	cb91                	beqz	a5,c7a <strcmp+0x1e>
     c68:	0005c703          	lbu	a4,0(a1)
     c6c:	00f71763          	bne	a4,a5,c7a <strcmp+0x1e>
    p++, q++;
     c70:	0505                	addi	a0,a0,1
     c72:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c74:	00054783          	lbu	a5,0(a0)
     c78:	fbe5                	bnez	a5,c68 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c7a:	0005c503          	lbu	a0,0(a1)
}
     c7e:	40a7853b          	subw	a0,a5,a0
     c82:	6422                	ld	s0,8(sp)
     c84:	0141                	addi	sp,sp,16
     c86:	8082                	ret

0000000000000c88 <strlen>:

uint
strlen(const char *s)
{
     c88:	1141                	addi	sp,sp,-16
     c8a:	e422                	sd	s0,8(sp)
     c8c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c8e:	00054783          	lbu	a5,0(a0)
     c92:	cf91                	beqz	a5,cae <strlen+0x26>
     c94:	0505                	addi	a0,a0,1
     c96:	87aa                	mv	a5,a0
     c98:	86be                	mv	a3,a5
     c9a:	0785                	addi	a5,a5,1
     c9c:	fff7c703          	lbu	a4,-1(a5)
     ca0:	ff65                	bnez	a4,c98 <strlen+0x10>
     ca2:	40a6853b          	subw	a0,a3,a0
     ca6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     ca8:	6422                	ld	s0,8(sp)
     caa:	0141                	addi	sp,sp,16
     cac:	8082                	ret
  for(n = 0; s[n]; n++)
     cae:	4501                	li	a0,0
     cb0:	bfe5                	j	ca8 <strlen+0x20>

0000000000000cb2 <memset>:

void*
memset(void *dst, int c, uint n)
{
     cb2:	1141                	addi	sp,sp,-16
     cb4:	e422                	sd	s0,8(sp)
     cb6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     cb8:	ca19                	beqz	a2,cce <memset+0x1c>
     cba:	87aa                	mv	a5,a0
     cbc:	1602                	slli	a2,a2,0x20
     cbe:	9201                	srli	a2,a2,0x20
     cc0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     cc4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cc8:	0785                	addi	a5,a5,1
     cca:	fee79de3          	bne	a5,a4,cc4 <memset+0x12>
  }
  return dst;
}
     cce:	6422                	ld	s0,8(sp)
     cd0:	0141                	addi	sp,sp,16
     cd2:	8082                	ret

0000000000000cd4 <strchr>:

char*
strchr(const char *s, char c)
{
     cd4:	1141                	addi	sp,sp,-16
     cd6:	e422                	sd	s0,8(sp)
     cd8:	0800                	addi	s0,sp,16
  for(; *s; s++)
     cda:	00054783          	lbu	a5,0(a0)
     cde:	cb99                	beqz	a5,cf4 <strchr+0x20>
    if(*s == c)
     ce0:	00f58763          	beq	a1,a5,cee <strchr+0x1a>
  for(; *s; s++)
     ce4:	0505                	addi	a0,a0,1
     ce6:	00054783          	lbu	a5,0(a0)
     cea:	fbfd                	bnez	a5,ce0 <strchr+0xc>
      return (char*)s;
  return 0;
     cec:	4501                	li	a0,0
}
     cee:	6422                	ld	s0,8(sp)
     cf0:	0141                	addi	sp,sp,16
     cf2:	8082                	ret
  return 0;
     cf4:	4501                	li	a0,0
     cf6:	bfe5                	j	cee <strchr+0x1a>

0000000000000cf8 <gets>:

char*
gets(char *buf, int max)
{
     cf8:	711d                	addi	sp,sp,-96
     cfa:	ec86                	sd	ra,88(sp)
     cfc:	e8a2                	sd	s0,80(sp)
     cfe:	e4a6                	sd	s1,72(sp)
     d00:	e0ca                	sd	s2,64(sp)
     d02:	fc4e                	sd	s3,56(sp)
     d04:	f852                	sd	s4,48(sp)
     d06:	f456                	sd	s5,40(sp)
     d08:	f05a                	sd	s6,32(sp)
     d0a:	ec5e                	sd	s7,24(sp)
     d0c:	1080                	addi	s0,sp,96
     d0e:	8baa                	mv	s7,a0
     d10:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d12:	892a                	mv	s2,a0
     d14:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d16:	4aa9                	li	s5,10
     d18:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d1a:	89a6                	mv	s3,s1
     d1c:	2485                	addiw	s1,s1,1
     d1e:	0344d863          	bge	s1,s4,d4e <gets+0x56>
    cc = read(0, &c, 1);
     d22:	4605                	li	a2,1
     d24:	faf40593          	addi	a1,s0,-81
     d28:	4501                	li	a0,0
     d2a:	00000097          	auipc	ra,0x0
     d2e:	19a080e7          	jalr	410(ra) # ec4 <read>
    if(cc < 1)
     d32:	00a05e63          	blez	a0,d4e <gets+0x56>
    buf[i++] = c;
     d36:	faf44783          	lbu	a5,-81(s0)
     d3a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d3e:	01578763          	beq	a5,s5,d4c <gets+0x54>
     d42:	0905                	addi	s2,s2,1
     d44:	fd679be3          	bne	a5,s6,d1a <gets+0x22>
    buf[i++] = c;
     d48:	89a6                	mv	s3,s1
     d4a:	a011                	j	d4e <gets+0x56>
     d4c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d4e:	99de                	add	s3,s3,s7
     d50:	00098023          	sb	zero,0(s3)
  return buf;
}
     d54:	855e                	mv	a0,s7
     d56:	60e6                	ld	ra,88(sp)
     d58:	6446                	ld	s0,80(sp)
     d5a:	64a6                	ld	s1,72(sp)
     d5c:	6906                	ld	s2,64(sp)
     d5e:	79e2                	ld	s3,56(sp)
     d60:	7a42                	ld	s4,48(sp)
     d62:	7aa2                	ld	s5,40(sp)
     d64:	7b02                	ld	s6,32(sp)
     d66:	6be2                	ld	s7,24(sp)
     d68:	6125                	addi	sp,sp,96
     d6a:	8082                	ret

0000000000000d6c <stat>:

int
stat(const char *n, struct stat *st)
{
     d6c:	1101                	addi	sp,sp,-32
     d6e:	ec06                	sd	ra,24(sp)
     d70:	e822                	sd	s0,16(sp)
     d72:	e04a                	sd	s2,0(sp)
     d74:	1000                	addi	s0,sp,32
     d76:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d78:	4581                	li	a1,0
     d7a:	00000097          	auipc	ra,0x0
     d7e:	172080e7          	jalr	370(ra) # eec <open>
  if(fd < 0)
     d82:	02054663          	bltz	a0,dae <stat+0x42>
     d86:	e426                	sd	s1,8(sp)
     d88:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d8a:	85ca                	mv	a1,s2
     d8c:	00000097          	auipc	ra,0x0
     d90:	178080e7          	jalr	376(ra) # f04 <fstat>
     d94:	892a                	mv	s2,a0
  close(fd);
     d96:	8526                	mv	a0,s1
     d98:	00000097          	auipc	ra,0x0
     d9c:	13c080e7          	jalr	316(ra) # ed4 <close>
  return r;
     da0:	64a2                	ld	s1,8(sp)
}
     da2:	854a                	mv	a0,s2
     da4:	60e2                	ld	ra,24(sp)
     da6:	6442                	ld	s0,16(sp)
     da8:	6902                	ld	s2,0(sp)
     daa:	6105                	addi	sp,sp,32
     dac:	8082                	ret
    return -1;
     dae:	597d                	li	s2,-1
     db0:	bfcd                	j	da2 <stat+0x36>

0000000000000db2 <atoi>:

int
atoi(const char *s)
{
     db2:	1141                	addi	sp,sp,-16
     db4:	e422                	sd	s0,8(sp)
     db6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     db8:	00054683          	lbu	a3,0(a0)
     dbc:	fd06879b          	addiw	a5,a3,-48
     dc0:	0ff7f793          	zext.b	a5,a5
     dc4:	4625                	li	a2,9
     dc6:	02f66863          	bltu	a2,a5,df6 <atoi+0x44>
     dca:	872a                	mv	a4,a0
  n = 0;
     dcc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     dce:	0705                	addi	a4,a4,1
     dd0:	0025179b          	slliw	a5,a0,0x2
     dd4:	9fa9                	addw	a5,a5,a0
     dd6:	0017979b          	slliw	a5,a5,0x1
     dda:	9fb5                	addw	a5,a5,a3
     ddc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     de0:	00074683          	lbu	a3,0(a4)
     de4:	fd06879b          	addiw	a5,a3,-48
     de8:	0ff7f793          	zext.b	a5,a5
     dec:	fef671e3          	bgeu	a2,a5,dce <atoi+0x1c>
  return n;
}
     df0:	6422                	ld	s0,8(sp)
     df2:	0141                	addi	sp,sp,16
     df4:	8082                	ret
  n = 0;
     df6:	4501                	li	a0,0
     df8:	bfe5                	j	df0 <atoi+0x3e>

0000000000000dfa <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     dfa:	1141                	addi	sp,sp,-16
     dfc:	e422                	sd	s0,8(sp)
     dfe:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     e00:	02b57463          	bgeu	a0,a1,e28 <memmove+0x2e>
    while(n-- > 0)
     e04:	00c05f63          	blez	a2,e22 <memmove+0x28>
     e08:	1602                	slli	a2,a2,0x20
     e0a:	9201                	srli	a2,a2,0x20
     e0c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     e10:	872a                	mv	a4,a0
      *dst++ = *src++;
     e12:	0585                	addi	a1,a1,1
     e14:	0705                	addi	a4,a4,1
     e16:	fff5c683          	lbu	a3,-1(a1)
     e1a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e1e:	fef71ae3          	bne	a4,a5,e12 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e22:	6422                	ld	s0,8(sp)
     e24:	0141                	addi	sp,sp,16
     e26:	8082                	ret
    dst += n;
     e28:	00c50733          	add	a4,a0,a2
    src += n;
     e2c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e2e:	fec05ae3          	blez	a2,e22 <memmove+0x28>
     e32:	fff6079b          	addiw	a5,a2,-1
     e36:	1782                	slli	a5,a5,0x20
     e38:	9381                	srli	a5,a5,0x20
     e3a:	fff7c793          	not	a5,a5
     e3e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e40:	15fd                	addi	a1,a1,-1
     e42:	177d                	addi	a4,a4,-1
     e44:	0005c683          	lbu	a3,0(a1)
     e48:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e4c:	fee79ae3          	bne	a5,a4,e40 <memmove+0x46>
     e50:	bfc9                	j	e22 <memmove+0x28>

0000000000000e52 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e52:	1141                	addi	sp,sp,-16
     e54:	e422                	sd	s0,8(sp)
     e56:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e58:	ca05                	beqz	a2,e88 <memcmp+0x36>
     e5a:	fff6069b          	addiw	a3,a2,-1
     e5e:	1682                	slli	a3,a3,0x20
     e60:	9281                	srli	a3,a3,0x20
     e62:	0685                	addi	a3,a3,1
     e64:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e66:	00054783          	lbu	a5,0(a0)
     e6a:	0005c703          	lbu	a4,0(a1)
     e6e:	00e79863          	bne	a5,a4,e7e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e72:	0505                	addi	a0,a0,1
    p2++;
     e74:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e76:	fed518e3          	bne	a0,a3,e66 <memcmp+0x14>
  }
  return 0;
     e7a:	4501                	li	a0,0
     e7c:	a019                	j	e82 <memcmp+0x30>
      return *p1 - *p2;
     e7e:	40e7853b          	subw	a0,a5,a4
}
     e82:	6422                	ld	s0,8(sp)
     e84:	0141                	addi	sp,sp,16
     e86:	8082                	ret
  return 0;
     e88:	4501                	li	a0,0
     e8a:	bfe5                	j	e82 <memcmp+0x30>

0000000000000e8c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e8c:	1141                	addi	sp,sp,-16
     e8e:	e406                	sd	ra,8(sp)
     e90:	e022                	sd	s0,0(sp)
     e92:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e94:	00000097          	auipc	ra,0x0
     e98:	f66080e7          	jalr	-154(ra) # dfa <memmove>
}
     e9c:	60a2                	ld	ra,8(sp)
     e9e:	6402                	ld	s0,0(sp)
     ea0:	0141                	addi	sp,sp,16
     ea2:	8082                	ret

0000000000000ea4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ea4:	4885                	li	a7,1
 ecall
     ea6:	00000073          	ecall
 ret
     eaa:	8082                	ret

0000000000000eac <exit>:
.global exit
exit:
 li a7, SYS_exit
     eac:	4889                	li	a7,2
 ecall
     eae:	00000073          	ecall
 ret
     eb2:	8082                	ret

0000000000000eb4 <wait>:
.global wait
wait:
 li a7, SYS_wait
     eb4:	488d                	li	a7,3
 ecall
     eb6:	00000073          	ecall
 ret
     eba:	8082                	ret

0000000000000ebc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     ebc:	4891                	li	a7,4
 ecall
     ebe:	00000073          	ecall
 ret
     ec2:	8082                	ret

0000000000000ec4 <read>:
.global read
read:
 li a7, SYS_read
     ec4:	4895                	li	a7,5
 ecall
     ec6:	00000073          	ecall
 ret
     eca:	8082                	ret

0000000000000ecc <write>:
.global write
write:
 li a7, SYS_write
     ecc:	48c1                	li	a7,16
 ecall
     ece:	00000073          	ecall
 ret
     ed2:	8082                	ret

0000000000000ed4 <close>:
.global close
close:
 li a7, SYS_close
     ed4:	48d5                	li	a7,21
 ecall
     ed6:	00000073          	ecall
 ret
     eda:	8082                	ret

0000000000000edc <kill>:
.global kill
kill:
 li a7, SYS_kill
     edc:	4899                	li	a7,6
 ecall
     ede:	00000073          	ecall
 ret
     ee2:	8082                	ret

0000000000000ee4 <exec>:
.global exec
exec:
 li a7, SYS_exec
     ee4:	489d                	li	a7,7
 ecall
     ee6:	00000073          	ecall
 ret
     eea:	8082                	ret

0000000000000eec <open>:
.global open
open:
 li a7, SYS_open
     eec:	48bd                	li	a7,15
 ecall
     eee:	00000073          	ecall
 ret
     ef2:	8082                	ret

0000000000000ef4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     ef4:	48c5                	li	a7,17
 ecall
     ef6:	00000073          	ecall
 ret
     efa:	8082                	ret

0000000000000efc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     efc:	48c9                	li	a7,18
 ecall
     efe:	00000073          	ecall
 ret
     f02:	8082                	ret

0000000000000f04 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f04:	48a1                	li	a7,8
 ecall
     f06:	00000073          	ecall
 ret
     f0a:	8082                	ret

0000000000000f0c <link>:
.global link
link:
 li a7, SYS_link
     f0c:	48cd                	li	a7,19
 ecall
     f0e:	00000073          	ecall
 ret
     f12:	8082                	ret

0000000000000f14 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f14:	48d1                	li	a7,20
 ecall
     f16:	00000073          	ecall
 ret
     f1a:	8082                	ret

0000000000000f1c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f1c:	48a5                	li	a7,9
 ecall
     f1e:	00000073          	ecall
 ret
     f22:	8082                	ret

0000000000000f24 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f24:	48a9                	li	a7,10
 ecall
     f26:	00000073          	ecall
 ret
     f2a:	8082                	ret

0000000000000f2c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f2c:	48ad                	li	a7,11
 ecall
     f2e:	00000073          	ecall
 ret
     f32:	8082                	ret

0000000000000f34 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f34:	48b1                	li	a7,12
 ecall
     f36:	00000073          	ecall
 ret
     f3a:	8082                	ret

0000000000000f3c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f3c:	48b5                	li	a7,13
 ecall
     f3e:	00000073          	ecall
 ret
     f42:	8082                	ret

0000000000000f44 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f44:	48b9                	li	a7,14
 ecall
     f46:	00000073          	ecall
 ret
     f4a:	8082                	ret

0000000000000f4c <ps>:
.global ps
ps:
 li a7, SYS_ps
     f4c:	48d9                	li	a7,22
 ecall
     f4e:	00000073          	ecall
 ret
     f52:	8082                	ret

0000000000000f54 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
     f54:	48dd                	li	a7,23
 ecall
     f56:	00000073          	ecall
 ret
     f5a:	8082                	ret

0000000000000f5c <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
     f5c:	48e1                	li	a7,24
 ecall
     f5e:	00000073          	ecall
 ret
     f62:	8082                	ret

0000000000000f64 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
     f64:	48e9                	li	a7,26
 ecall
     f66:	00000073          	ecall
 ret
     f6a:	8082                	ret

0000000000000f6c <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
     f6c:	48e5                	li	a7,25
 ecall
     f6e:	00000073          	ecall
 ret
     f72:	8082                	ret

0000000000000f74 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f74:	1101                	addi	sp,sp,-32
     f76:	ec06                	sd	ra,24(sp)
     f78:	e822                	sd	s0,16(sp)
     f7a:	1000                	addi	s0,sp,32
     f7c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f80:	4605                	li	a2,1
     f82:	fef40593          	addi	a1,s0,-17
     f86:	00000097          	auipc	ra,0x0
     f8a:	f46080e7          	jalr	-186(ra) # ecc <write>
}
     f8e:	60e2                	ld	ra,24(sp)
     f90:	6442                	ld	s0,16(sp)
     f92:	6105                	addi	sp,sp,32
     f94:	8082                	ret

0000000000000f96 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f96:	7139                	addi	sp,sp,-64
     f98:	fc06                	sd	ra,56(sp)
     f9a:	f822                	sd	s0,48(sp)
     f9c:	f426                	sd	s1,40(sp)
     f9e:	0080                	addi	s0,sp,64
     fa0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     fa2:	c299                	beqz	a3,fa8 <printint+0x12>
     fa4:	0805cb63          	bltz	a1,103a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     fa8:	2581                	sext.w	a1,a1
  neg = 0;
     faa:	4881                	li	a7,0
     fac:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     fb0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     fb2:	2601                	sext.w	a2,a2
     fb4:	00000517          	auipc	a0,0x0
     fb8:	60450513          	addi	a0,a0,1540 # 15b8 <digits>
     fbc:	883a                	mv	a6,a4
     fbe:	2705                	addiw	a4,a4,1
     fc0:	02c5f7bb          	remuw	a5,a1,a2
     fc4:	1782                	slli	a5,a5,0x20
     fc6:	9381                	srli	a5,a5,0x20
     fc8:	97aa                	add	a5,a5,a0
     fca:	0007c783          	lbu	a5,0(a5)
     fce:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fd2:	0005879b          	sext.w	a5,a1
     fd6:	02c5d5bb          	divuw	a1,a1,a2
     fda:	0685                	addi	a3,a3,1
     fdc:	fec7f0e3          	bgeu	a5,a2,fbc <printint+0x26>
  if(neg)
     fe0:	00088c63          	beqz	a7,ff8 <printint+0x62>
    buf[i++] = '-';
     fe4:	fd070793          	addi	a5,a4,-48
     fe8:	00878733          	add	a4,a5,s0
     fec:	02d00793          	li	a5,45
     ff0:	fef70823          	sb	a5,-16(a4)
     ff4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     ff8:	02e05c63          	blez	a4,1030 <printint+0x9a>
     ffc:	f04a                	sd	s2,32(sp)
     ffe:	ec4e                	sd	s3,24(sp)
    1000:	fc040793          	addi	a5,s0,-64
    1004:	00e78933          	add	s2,a5,a4
    1008:	fff78993          	addi	s3,a5,-1
    100c:	99ba                	add	s3,s3,a4
    100e:	377d                	addiw	a4,a4,-1
    1010:	1702                	slli	a4,a4,0x20
    1012:	9301                	srli	a4,a4,0x20
    1014:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1018:	fff94583          	lbu	a1,-1(s2)
    101c:	8526                	mv	a0,s1
    101e:	00000097          	auipc	ra,0x0
    1022:	f56080e7          	jalr	-170(ra) # f74 <putc>
  while(--i >= 0)
    1026:	197d                	addi	s2,s2,-1
    1028:	ff3918e3          	bne	s2,s3,1018 <printint+0x82>
    102c:	7902                	ld	s2,32(sp)
    102e:	69e2                	ld	s3,24(sp)
}
    1030:	70e2                	ld	ra,56(sp)
    1032:	7442                	ld	s0,48(sp)
    1034:	74a2                	ld	s1,40(sp)
    1036:	6121                	addi	sp,sp,64
    1038:	8082                	ret
    x = -xx;
    103a:	40b005bb          	negw	a1,a1
    neg = 1;
    103e:	4885                	li	a7,1
    x = -xx;
    1040:	b7b5                	j	fac <printint+0x16>

0000000000001042 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1042:	715d                	addi	sp,sp,-80
    1044:	e486                	sd	ra,72(sp)
    1046:	e0a2                	sd	s0,64(sp)
    1048:	f84a                	sd	s2,48(sp)
    104a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    104c:	0005c903          	lbu	s2,0(a1)
    1050:	1a090a63          	beqz	s2,1204 <vprintf+0x1c2>
    1054:	fc26                	sd	s1,56(sp)
    1056:	f44e                	sd	s3,40(sp)
    1058:	f052                	sd	s4,32(sp)
    105a:	ec56                	sd	s5,24(sp)
    105c:	e85a                	sd	s6,16(sp)
    105e:	e45e                	sd	s7,8(sp)
    1060:	8aaa                	mv	s5,a0
    1062:	8bb2                	mv	s7,a2
    1064:	00158493          	addi	s1,a1,1
  state = 0;
    1068:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    106a:	02500a13          	li	s4,37
    106e:	4b55                	li	s6,21
    1070:	a839                	j	108e <vprintf+0x4c>
        putc(fd, c);
    1072:	85ca                	mv	a1,s2
    1074:	8556                	mv	a0,s5
    1076:	00000097          	auipc	ra,0x0
    107a:	efe080e7          	jalr	-258(ra) # f74 <putc>
    107e:	a019                	j	1084 <vprintf+0x42>
    } else if(state == '%'){
    1080:	01498d63          	beq	s3,s4,109a <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
    1084:	0485                	addi	s1,s1,1
    1086:	fff4c903          	lbu	s2,-1(s1)
    108a:	16090763          	beqz	s2,11f8 <vprintf+0x1b6>
    if(state == 0){
    108e:	fe0999e3          	bnez	s3,1080 <vprintf+0x3e>
      if(c == '%'){
    1092:	ff4910e3          	bne	s2,s4,1072 <vprintf+0x30>
        state = '%';
    1096:	89d2                	mv	s3,s4
    1098:	b7f5                	j	1084 <vprintf+0x42>
      if(c == 'd'){
    109a:	13490463          	beq	s2,s4,11c2 <vprintf+0x180>
    109e:	f9d9079b          	addiw	a5,s2,-99
    10a2:	0ff7f793          	zext.b	a5,a5
    10a6:	12fb6763          	bltu	s6,a5,11d4 <vprintf+0x192>
    10aa:	f9d9079b          	addiw	a5,s2,-99
    10ae:	0ff7f713          	zext.b	a4,a5
    10b2:	12eb6163          	bltu	s6,a4,11d4 <vprintf+0x192>
    10b6:	00271793          	slli	a5,a4,0x2
    10ba:	00000717          	auipc	a4,0x0
    10be:	4a670713          	addi	a4,a4,1190 # 1560 <malloc+0x26c>
    10c2:	97ba                	add	a5,a5,a4
    10c4:	439c                	lw	a5,0(a5)
    10c6:	97ba                	add	a5,a5,a4
    10c8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    10ca:	008b8913          	addi	s2,s7,8
    10ce:	4685                	li	a3,1
    10d0:	4629                	li	a2,10
    10d2:	000ba583          	lw	a1,0(s7)
    10d6:	8556                	mv	a0,s5
    10d8:	00000097          	auipc	ra,0x0
    10dc:	ebe080e7          	jalr	-322(ra) # f96 <printint>
    10e0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    10e2:	4981                	li	s3,0
    10e4:	b745                	j	1084 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10e6:	008b8913          	addi	s2,s7,8
    10ea:	4681                	li	a3,0
    10ec:	4629                	li	a2,10
    10ee:	000ba583          	lw	a1,0(s7)
    10f2:	8556                	mv	a0,s5
    10f4:	00000097          	auipc	ra,0x0
    10f8:	ea2080e7          	jalr	-350(ra) # f96 <printint>
    10fc:	8bca                	mv	s7,s2
      state = 0;
    10fe:	4981                	li	s3,0
    1100:	b751                	j	1084 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
    1102:	008b8913          	addi	s2,s7,8
    1106:	4681                	li	a3,0
    1108:	4641                	li	a2,16
    110a:	000ba583          	lw	a1,0(s7)
    110e:	8556                	mv	a0,s5
    1110:	00000097          	auipc	ra,0x0
    1114:	e86080e7          	jalr	-378(ra) # f96 <printint>
    1118:	8bca                	mv	s7,s2
      state = 0;
    111a:	4981                	li	s3,0
    111c:	b7a5                	j	1084 <vprintf+0x42>
    111e:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
    1120:	008b8c13          	addi	s8,s7,8
    1124:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    1128:	03000593          	li	a1,48
    112c:	8556                	mv	a0,s5
    112e:	00000097          	auipc	ra,0x0
    1132:	e46080e7          	jalr	-442(ra) # f74 <putc>
  putc(fd, 'x');
    1136:	07800593          	li	a1,120
    113a:	8556                	mv	a0,s5
    113c:	00000097          	auipc	ra,0x0
    1140:	e38080e7          	jalr	-456(ra) # f74 <putc>
    1144:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1146:	00000b97          	auipc	s7,0x0
    114a:	472b8b93          	addi	s7,s7,1138 # 15b8 <digits>
    114e:	03c9d793          	srli	a5,s3,0x3c
    1152:	97de                	add	a5,a5,s7
    1154:	0007c583          	lbu	a1,0(a5)
    1158:	8556                	mv	a0,s5
    115a:	00000097          	auipc	ra,0x0
    115e:	e1a080e7          	jalr	-486(ra) # f74 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1162:	0992                	slli	s3,s3,0x4
    1164:	397d                	addiw	s2,s2,-1
    1166:	fe0914e3          	bnez	s2,114e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    116a:	8be2                	mv	s7,s8
      state = 0;
    116c:	4981                	li	s3,0
    116e:	6c02                	ld	s8,0(sp)
    1170:	bf11                	j	1084 <vprintf+0x42>
        s = va_arg(ap, char*);
    1172:	008b8993          	addi	s3,s7,8
    1176:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    117a:	02090163          	beqz	s2,119c <vprintf+0x15a>
        while(*s != 0){
    117e:	00094583          	lbu	a1,0(s2)
    1182:	c9a5                	beqz	a1,11f2 <vprintf+0x1b0>
          putc(fd, *s);
    1184:	8556                	mv	a0,s5
    1186:	00000097          	auipc	ra,0x0
    118a:	dee080e7          	jalr	-530(ra) # f74 <putc>
          s++;
    118e:	0905                	addi	s2,s2,1
        while(*s != 0){
    1190:	00094583          	lbu	a1,0(s2)
    1194:	f9e5                	bnez	a1,1184 <vprintf+0x142>
        s = va_arg(ap, char*);
    1196:	8bce                	mv	s7,s3
      state = 0;
    1198:	4981                	li	s3,0
    119a:	b5ed                	j	1084 <vprintf+0x42>
          s = "(null)";
    119c:	00000917          	auipc	s2,0x0
    11a0:	38c90913          	addi	s2,s2,908 # 1528 <malloc+0x234>
        while(*s != 0){
    11a4:	02800593          	li	a1,40
    11a8:	bff1                	j	1184 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
    11aa:	008b8913          	addi	s2,s7,8
    11ae:	000bc583          	lbu	a1,0(s7)
    11b2:	8556                	mv	a0,s5
    11b4:	00000097          	auipc	ra,0x0
    11b8:	dc0080e7          	jalr	-576(ra) # f74 <putc>
    11bc:	8bca                	mv	s7,s2
      state = 0;
    11be:	4981                	li	s3,0
    11c0:	b5d1                	j	1084 <vprintf+0x42>
        putc(fd, c);
    11c2:	02500593          	li	a1,37
    11c6:	8556                	mv	a0,s5
    11c8:	00000097          	auipc	ra,0x0
    11cc:	dac080e7          	jalr	-596(ra) # f74 <putc>
      state = 0;
    11d0:	4981                	li	s3,0
    11d2:	bd4d                	j	1084 <vprintf+0x42>
        putc(fd, '%');
    11d4:	02500593          	li	a1,37
    11d8:	8556                	mv	a0,s5
    11da:	00000097          	auipc	ra,0x0
    11de:	d9a080e7          	jalr	-614(ra) # f74 <putc>
        putc(fd, c);
    11e2:	85ca                	mv	a1,s2
    11e4:	8556                	mv	a0,s5
    11e6:	00000097          	auipc	ra,0x0
    11ea:	d8e080e7          	jalr	-626(ra) # f74 <putc>
      state = 0;
    11ee:	4981                	li	s3,0
    11f0:	bd51                	j	1084 <vprintf+0x42>
        s = va_arg(ap, char*);
    11f2:	8bce                	mv	s7,s3
      state = 0;
    11f4:	4981                	li	s3,0
    11f6:	b579                	j	1084 <vprintf+0x42>
    11f8:	74e2                	ld	s1,56(sp)
    11fa:	79a2                	ld	s3,40(sp)
    11fc:	7a02                	ld	s4,32(sp)
    11fe:	6ae2                	ld	s5,24(sp)
    1200:	6b42                	ld	s6,16(sp)
    1202:	6ba2                	ld	s7,8(sp)
    }
  }
}
    1204:	60a6                	ld	ra,72(sp)
    1206:	6406                	ld	s0,64(sp)
    1208:	7942                	ld	s2,48(sp)
    120a:	6161                	addi	sp,sp,80
    120c:	8082                	ret

000000000000120e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    120e:	715d                	addi	sp,sp,-80
    1210:	ec06                	sd	ra,24(sp)
    1212:	e822                	sd	s0,16(sp)
    1214:	1000                	addi	s0,sp,32
    1216:	e010                	sd	a2,0(s0)
    1218:	e414                	sd	a3,8(s0)
    121a:	e818                	sd	a4,16(s0)
    121c:	ec1c                	sd	a5,24(s0)
    121e:	03043023          	sd	a6,32(s0)
    1222:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1226:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    122a:	8622                	mv	a2,s0
    122c:	00000097          	auipc	ra,0x0
    1230:	e16080e7          	jalr	-490(ra) # 1042 <vprintf>
}
    1234:	60e2                	ld	ra,24(sp)
    1236:	6442                	ld	s0,16(sp)
    1238:	6161                	addi	sp,sp,80
    123a:	8082                	ret

000000000000123c <printf>:

void
printf(const char *fmt, ...)
{
    123c:	711d                	addi	sp,sp,-96
    123e:	ec06                	sd	ra,24(sp)
    1240:	e822                	sd	s0,16(sp)
    1242:	1000                	addi	s0,sp,32
    1244:	e40c                	sd	a1,8(s0)
    1246:	e810                	sd	a2,16(s0)
    1248:	ec14                	sd	a3,24(s0)
    124a:	f018                	sd	a4,32(s0)
    124c:	f41c                	sd	a5,40(s0)
    124e:	03043823          	sd	a6,48(s0)
    1252:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1256:	00840613          	addi	a2,s0,8
    125a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    125e:	85aa                	mv	a1,a0
    1260:	4505                	li	a0,1
    1262:	00000097          	auipc	ra,0x0
    1266:	de0080e7          	jalr	-544(ra) # 1042 <vprintf>
}
    126a:	60e2                	ld	ra,24(sp)
    126c:	6442                	ld	s0,16(sp)
    126e:	6125                	addi	sp,sp,96
    1270:	8082                	ret

0000000000001272 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1272:	1141                	addi	sp,sp,-16
    1274:	e422                	sd	s0,8(sp)
    1276:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1278:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    127c:	00001797          	auipc	a5,0x1
    1280:	5947b783          	ld	a5,1428(a5) # 2810 <freep>
    1284:	a02d                	j	12ae <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1286:	4618                	lw	a4,8(a2)
    1288:	9f2d                	addw	a4,a4,a1
    128a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    128e:	6398                	ld	a4,0(a5)
    1290:	6310                	ld	a2,0(a4)
    1292:	a83d                	j	12d0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1294:	ff852703          	lw	a4,-8(a0)
    1298:	9f31                	addw	a4,a4,a2
    129a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    129c:	ff053683          	ld	a3,-16(a0)
    12a0:	a091                	j	12e4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12a2:	6398                	ld	a4,0(a5)
    12a4:	00e7e463          	bltu	a5,a4,12ac <free+0x3a>
    12a8:	00e6ea63          	bltu	a3,a4,12bc <free+0x4a>
{
    12ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12ae:	fed7fae3          	bgeu	a5,a3,12a2 <free+0x30>
    12b2:	6398                	ld	a4,0(a5)
    12b4:	00e6e463          	bltu	a3,a4,12bc <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12b8:	fee7eae3          	bltu	a5,a4,12ac <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    12bc:	ff852583          	lw	a1,-8(a0)
    12c0:	6390                	ld	a2,0(a5)
    12c2:	02059813          	slli	a6,a1,0x20
    12c6:	01c85713          	srli	a4,a6,0x1c
    12ca:	9736                	add	a4,a4,a3
    12cc:	fae60de3          	beq	a2,a4,1286 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    12d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12d4:	4790                	lw	a2,8(a5)
    12d6:	02061593          	slli	a1,a2,0x20
    12da:	01c5d713          	srli	a4,a1,0x1c
    12de:	973e                	add	a4,a4,a5
    12e0:	fae68ae3          	beq	a3,a4,1294 <free+0x22>
    p->s.ptr = bp->s.ptr;
    12e4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    12e6:	00001717          	auipc	a4,0x1
    12ea:	52f73523          	sd	a5,1322(a4) # 2810 <freep>
}
    12ee:	6422                	ld	s0,8(sp)
    12f0:	0141                	addi	sp,sp,16
    12f2:	8082                	ret

00000000000012f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12f4:	7139                	addi	sp,sp,-64
    12f6:	fc06                	sd	ra,56(sp)
    12f8:	f822                	sd	s0,48(sp)
    12fa:	f426                	sd	s1,40(sp)
    12fc:	ec4e                	sd	s3,24(sp)
    12fe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1300:	02051493          	slli	s1,a0,0x20
    1304:	9081                	srli	s1,s1,0x20
    1306:	04bd                	addi	s1,s1,15
    1308:	8091                	srli	s1,s1,0x4
    130a:	0014899b          	addiw	s3,s1,1
    130e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1310:	00001517          	auipc	a0,0x1
    1314:	50053503          	ld	a0,1280(a0) # 2810 <freep>
    1318:	c915                	beqz	a0,134c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    131a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    131c:	4798                	lw	a4,8(a5)
    131e:	08977e63          	bgeu	a4,s1,13ba <malloc+0xc6>
    1322:	f04a                	sd	s2,32(sp)
    1324:	e852                	sd	s4,16(sp)
    1326:	e456                	sd	s5,8(sp)
    1328:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    132a:	8a4e                	mv	s4,s3
    132c:	0009871b          	sext.w	a4,s3
    1330:	6685                	lui	a3,0x1
    1332:	00d77363          	bgeu	a4,a3,1338 <malloc+0x44>
    1336:	6a05                	lui	s4,0x1
    1338:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    133c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1340:	00001917          	auipc	s2,0x1
    1344:	4d090913          	addi	s2,s2,1232 # 2810 <freep>
  if(p == (char*)-1)
    1348:	5afd                	li	s5,-1
    134a:	a091                	j	138e <malloc+0x9a>
    134c:	f04a                	sd	s2,32(sp)
    134e:	e852                	sd	s4,16(sp)
    1350:	e456                	sd	s5,8(sp)
    1352:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    1354:	00001797          	auipc	a5,0x1
    1358:	54478793          	addi	a5,a5,1348 # 2898 <base>
    135c:	00001717          	auipc	a4,0x1
    1360:	4af73a23          	sd	a5,1204(a4) # 2810 <freep>
    1364:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1366:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    136a:	b7c1                	j	132a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    136c:	6398                	ld	a4,0(a5)
    136e:	e118                	sd	a4,0(a0)
    1370:	a08d                	j	13d2 <malloc+0xde>
  hp->s.size = nu;
    1372:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1376:	0541                	addi	a0,a0,16
    1378:	00000097          	auipc	ra,0x0
    137c:	efa080e7          	jalr	-262(ra) # 1272 <free>
  return freep;
    1380:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1384:	c13d                	beqz	a0,13ea <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1386:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1388:	4798                	lw	a4,8(a5)
    138a:	02977463          	bgeu	a4,s1,13b2 <malloc+0xbe>
    if(p == freep)
    138e:	00093703          	ld	a4,0(s2)
    1392:	853e                	mv	a0,a5
    1394:	fef719e3          	bne	a4,a5,1386 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
    1398:	8552                	mv	a0,s4
    139a:	00000097          	auipc	ra,0x0
    139e:	b9a080e7          	jalr	-1126(ra) # f34 <sbrk>
  if(p == (char*)-1)
    13a2:	fd5518e3          	bne	a0,s5,1372 <malloc+0x7e>
        return 0;
    13a6:	4501                	li	a0,0
    13a8:	7902                	ld	s2,32(sp)
    13aa:	6a42                	ld	s4,16(sp)
    13ac:	6aa2                	ld	s5,8(sp)
    13ae:	6b02                	ld	s6,0(sp)
    13b0:	a03d                	j	13de <malloc+0xea>
    13b2:	7902                	ld	s2,32(sp)
    13b4:	6a42                	ld	s4,16(sp)
    13b6:	6aa2                	ld	s5,8(sp)
    13b8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    13ba:	fae489e3          	beq	s1,a4,136c <malloc+0x78>
        p->s.size -= nunits;
    13be:	4137073b          	subw	a4,a4,s3
    13c2:	c798                	sw	a4,8(a5)
        p += p->s.size;
    13c4:	02071693          	slli	a3,a4,0x20
    13c8:	01c6d713          	srli	a4,a3,0x1c
    13cc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    13ce:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    13d2:	00001717          	auipc	a4,0x1
    13d6:	42a73f23          	sd	a0,1086(a4) # 2810 <freep>
      return (void*)(p + 1);
    13da:	01078513          	addi	a0,a5,16
  }
}
    13de:	70e2                	ld	ra,56(sp)
    13e0:	7442                	ld	s0,48(sp)
    13e2:	74a2                	ld	s1,40(sp)
    13e4:	69e2                	ld	s3,24(sp)
    13e6:	6121                	addi	sp,sp,64
    13e8:	8082                	ret
    13ea:	7902                	ld	s2,32(sp)
    13ec:	6a42                	ld	s4,16(sp)
    13ee:	6aa2                	ld	s5,8(sp)
    13f0:	6b02                	ld	s6,0(sp)
    13f2:	b7f5                	j	13de <malloc+0xea>
