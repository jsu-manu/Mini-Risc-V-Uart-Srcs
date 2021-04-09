
memtest.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	00012117          	auipc	sp,0x12
   4:	04010113          	addi	sp,sp,64 # 12040 <_sp0>
   8:	00022517          	auipc	a0,0x22
   c:	03c50513          	addi	a0,a0,60 # 22044 <_rp0>
  10:	2f5000ef          	jal	ra,b04 <set_CRAS_base_addr>
  14:	00000097          	auipc	ra,0x0
  18:	00c08093          	addi	ra,ra,12 # 20 <_endloop>
  1c:	008000ef          	jal	ra,24 <main>

00000020 <_endloop>:
  20:	0000006f          	j	20 <_endloop>

00000024 <main>:
  24:	fe010113          	addi	sp,sp,-32
  28:	00112e23          	sw	ra,28(sp)
  2c:	00812c23          	sw	s0,24(sp)
  30:	02010413          	addi	s0,sp,32
  34:	030000ef          	jal	ra,64 <uart_init>
  38:	000027b7          	lui	a5,0x2
  3c:	00078793          	mv	a5,a5
  40:	fef42623          	sw	a5,-20(s0)
  44:	fec42503          	lw	a0,-20(s0)
  48:	1e4000ef          	jal	ra,22c <uart_print>
  4c:	00000793          	li	a5,0
  50:	00078513          	mv	a0,a5
  54:	01c12083          	lw	ra,28(sp)
  58:	01812403          	lw	s0,24(sp)
  5c:	02010113          	addi	sp,sp,32
  60:	00008067          	ret

00000064 <uart_init>:
  64:	fe010113          	addi	sp,sp,-32
  68:	00812e23          	sw	s0,28(sp)
  6c:	02010413          	addi	s0,sp,32
  70:	aaaaa7b7          	lui	a5,0xaaaaa
  74:	40078793          	addi	a5,a5,1024 # aaaaa400 <_rp0+0xaaa883bc>
  78:	fef42623          	sw	a5,-20(s0)
  7c:	fec42783          	lw	a5,-20(s0)
  80:	00378793          	addi	a5,a5,3
  84:	f8300713          	li	a4,-125
  88:	00e78023          	sb	a4,0(a5)
  8c:	03600793          	li	a5,54
  90:	fef405a3          	sb	a5,-21(s0)
  94:	fec42783          	lw	a5,-20(s0)
  98:	feb44703          	lbu	a4,-21(s0)
  9c:	00e78023          	sb	a4,0(a5)
  a0:	fec42783          	lw	a5,-20(s0)
  a4:	00178793          	addi	a5,a5,1
  a8:	00078023          	sb	zero,0(a5)
  ac:	fec42783          	lw	a5,-20(s0)
  b0:	00378793          	addi	a5,a5,3
  b4:	00300713          	li	a4,3
  b8:	00e78023          	sb	a4,0(a5)
  bc:	fec42783          	lw	a5,-20(s0)
  c0:	00278793          	addi	a5,a5,2
  c4:	00100713          	li	a4,1
  c8:	00e78023          	sb	a4,0(a5)
  cc:	fec42783          	lw	a5,-20(s0)
  d0:	00178793          	addi	a5,a5,1
  d4:	00100713          	li	a4,1
  d8:	00e78023          	sb	a4,0(a5)
  dc:	00100793          	li	a5,1
  e0:	00078513          	mv	a0,a5
  e4:	01c12403          	lw	s0,28(sp)
  e8:	02010113          	addi	sp,sp,32
  ec:	00008067          	ret

000000f0 <uart_put>:
  f0:	fd010113          	addi	sp,sp,-48
  f4:	02812623          	sw	s0,44(sp)
  f8:	03010413          	addi	s0,sp,48
  fc:	00050793          	mv	a5,a0
 100:	fcf40fa3          	sb	a5,-33(s0)
 104:	aaaaa7b7          	lui	a5,0xaaaaa
 108:	40078793          	addi	a5,a5,1024 # aaaaa400 <_rp0+0xaaa883bc>
 10c:	fef42623          	sw	a5,-20(s0)
 110:	fec42783          	lw	a5,-20(s0)
 114:	fdf44703          	lbu	a4,-33(s0)
 118:	00e78023          	sb	a4,0(a5)
 11c:	00000013          	nop
 120:	02c12403          	lw	s0,44(sp)
 124:	03010113          	addi	sp,sp,48
 128:	00008067          	ret

0000012c <uart_put_blocking>:
 12c:	fd010113          	addi	sp,sp,-48
 130:	02112623          	sw	ra,44(sp)
 134:	02812423          	sw	s0,40(sp)
 138:	03010413          	addi	s0,sp,48
 13c:	00050793          	mv	a5,a0
 140:	fcf40fa3          	sb	a5,-33(s0)
 144:	06c000ef          	jal	ra,1b0 <uart_poll>
 148:	00050793          	mv	a5,a0
 14c:	0607f793          	andi	a5,a5,96
 150:	fef407a3          	sb	a5,-17(s0)
 154:	fef44783          	lbu	a5,-17(s0)
 158:	fe0786e3          	beqz	a5,144 <uart_put_blocking+0x18>
 15c:	fdf44783          	lbu	a5,-33(s0)
 160:	00078513          	mv	a0,a5
 164:	f8dff0ef          	jal	ra,f0 <uart_put>
 168:	00000013          	nop
 16c:	02c12083          	lw	ra,44(sp)
 170:	02812403          	lw	s0,40(sp)
 174:	03010113          	addi	sp,sp,48
 178:	00008067          	ret

0000017c <uart_get>:
 17c:	fe010113          	addi	sp,sp,-32
 180:	00812e23          	sw	s0,28(sp)
 184:	02010413          	addi	s0,sp,32
 188:	aaaaa7b7          	lui	a5,0xaaaaa
 18c:	40078793          	addi	a5,a5,1024 # aaaaa400 <_rp0+0xaaa883bc>
 190:	fef42623          	sw	a5,-20(s0)
 194:	fec42783          	lw	a5,-20(s0)
 198:	0007c783          	lbu	a5,0(a5)
 19c:	0ff7f793          	andi	a5,a5,255
 1a0:	00078513          	mv	a0,a5
 1a4:	01c12403          	lw	s0,28(sp)
 1a8:	02010113          	addi	sp,sp,32
 1ac:	00008067          	ret

000001b0 <uart_poll>:
 1b0:	fe010113          	addi	sp,sp,-32
 1b4:	00812e23          	sw	s0,28(sp)
 1b8:	02010413          	addi	s0,sp,32
 1bc:	aaaaa7b7          	lui	a5,0xaaaaa
 1c0:	40078793          	addi	a5,a5,1024 # aaaaa400 <_rp0+0xaaa883bc>
 1c4:	fef42623          	sw	a5,-20(s0)
 1c8:	fec42783          	lw	a5,-20(s0)
 1cc:	00578793          	addi	a5,a5,5
 1d0:	0007c783          	lbu	a5,0(a5)
 1d4:	0ff7f793          	andi	a5,a5,255
 1d8:	00078513          	mv	a0,a5
 1dc:	01c12403          	lw	s0,28(sp)
 1e0:	02010113          	addi	sp,sp,32
 1e4:	00008067          	ret

000001e8 <uart_read_blocking>:
 1e8:	fe010113          	addi	sp,sp,-32
 1ec:	00112e23          	sw	ra,28(sp)
 1f0:	00812c23          	sw	s0,24(sp)
 1f4:	02010413          	addi	s0,sp,32
 1f8:	fb9ff0ef          	jal	ra,1b0 <uart_poll>
 1fc:	00050793          	mv	a5,a0
 200:	0017f793          	andi	a5,a5,1
 204:	fef407a3          	sb	a5,-17(s0)
 208:	fef44783          	lbu	a5,-17(s0)
 20c:	fe0786e3          	beqz	a5,1f8 <uart_read_blocking+0x10>
 210:	f6dff0ef          	jal	ra,17c <uart_get>
 214:	00050793          	mv	a5,a0
 218:	00078513          	mv	a0,a5
 21c:	01c12083          	lw	ra,28(sp)
 220:	01812403          	lw	s0,24(sp)
 224:	02010113          	addi	sp,sp,32
 228:	00008067          	ret

0000022c <uart_print>:
 22c:	fd010113          	addi	sp,sp,-48
 230:	02112623          	sw	ra,44(sp)
 234:	02812423          	sw	s0,40(sp)
 238:	03010413          	addi	s0,sp,48
 23c:	fca42e23          	sw	a0,-36(s0)
 240:	fdc42783          	lw	a5,-36(s0)
 244:	fef42423          	sw	a5,-24(s0)
 248:	fe042623          	sw	zero,-20(s0)
 24c:	04c0006f          	j	298 <uart_print+0x6c>
 250:	fec42783          	lw	a5,-20(s0)
 254:	02079063          	bnez	a5,274 <uart_print+0x48>
 258:	fec42783          	lw	a5,-20(s0)
 25c:	fe842703          	lw	a4,-24(s0)
 260:	00f707b3          	add	a5,a4,a5
 264:	0007c783          	lbu	a5,0(a5)
 268:	00078513          	mv	a0,a5
 26c:	ec1ff0ef          	jal	ra,12c <uart_put_blocking>
 270:	01c0006f          	j	28c <uart_print+0x60>
 274:	fec42783          	lw	a5,-20(s0)
 278:	fe842703          	lw	a4,-24(s0)
 27c:	00f707b3          	add	a5,a4,a5
 280:	0007c783          	lbu	a5,0(a5)
 284:	00078513          	mv	a0,a5
 288:	e69ff0ef          	jal	ra,f0 <uart_put>
 28c:	fec42783          	lw	a5,-20(s0)
 290:	00178793          	addi	a5,a5,1
 294:	fef42623          	sw	a5,-20(s0)
 298:	fec42783          	lw	a5,-20(s0)
 29c:	fe842703          	lw	a4,-24(s0)
 2a0:	00f707b3          	add	a5,a4,a5
 2a4:	0007c783          	lbu	a5,0(a5)
 2a8:	fa0794e3          	bnez	a5,250 <uart_print+0x24>
 2ac:	00000013          	nop
 2b0:	02c12083          	lw	ra,44(sp)
 2b4:	02812403          	lw	s0,40(sp)
 2b8:	03010113          	addi	sp,sp,48
 2bc:	00008067          	ret

000002c0 <readline>:
 2c0:	fd010113          	addi	sp,sp,-48
 2c4:	02112623          	sw	ra,44(sp)
 2c8:	02812423          	sw	s0,40(sp)
 2cc:	03010413          	addi	s0,sp,48
 2d0:	fca42e23          	sw	a0,-36(s0)
 2d4:	fcb42c23          	sw	a1,-40(s0)
 2d8:	fe042623          	sw	zero,-20(s0)
 2dc:	0900006f          	j	36c <readline+0xac>
 2e0:	f09ff0ef          	jal	ra,1e8 <uart_read_blocking>
 2e4:	00050793          	mv	a5,a0
 2e8:	fef403a3          	sb	a5,-25(s0)
 2ec:	fe744703          	lbu	a4,-25(s0)
 2f0:	00d00793          	li	a5,13
 2f4:	04f71663          	bne	a4,a5,340 <readline+0x80>
 2f8:	fec42783          	lw	a5,-20(s0)
 2fc:	fef42423          	sw	a5,-24(s0)
 300:	0200006f          	j	320 <readline+0x60>
 304:	fe842783          	lw	a5,-24(s0)
 308:	fdc42703          	lw	a4,-36(s0)
 30c:	00f707b3          	add	a5,a4,a5
 310:	00078023          	sb	zero,0(a5)
 314:	fe842783          	lw	a5,-24(s0)
 318:	00178793          	addi	a5,a5,1
 31c:	fef42423          	sw	a5,-24(s0)
 320:	fe842703          	lw	a4,-24(s0)
 324:	fd842783          	lw	a5,-40(s0)
 328:	fcf74ee3          	blt	a4,a5,304 <readline+0x44>
 32c:	00d00513          	li	a0,13
 330:	dc1ff0ef          	jal	ra,f0 <uart_put>
 334:	00a00513          	li	a0,10
 338:	db9ff0ef          	jal	ra,f0 <uart_put>
 33c:	03c0006f          	j	378 <readline+0xb8>
 340:	fe744783          	lbu	a5,-25(s0)
 344:	00078513          	mv	a0,a5
 348:	da9ff0ef          	jal	ra,f0 <uart_put>
 34c:	fec42783          	lw	a5,-20(s0)
 350:	fdc42703          	lw	a4,-36(s0)
 354:	00f707b3          	add	a5,a4,a5
 358:	fe744703          	lbu	a4,-25(s0)
 35c:	00e78023          	sb	a4,0(a5)
 360:	fec42783          	lw	a5,-20(s0)
 364:	00178793          	addi	a5,a5,1
 368:	fef42623          	sw	a5,-20(s0)
 36c:	fec42703          	lw	a4,-20(s0)
 370:	fd842783          	lw	a5,-40(s0)
 374:	f6f746e3          	blt	a4,a5,2e0 <readline+0x20>
 378:	02c12083          	lw	ra,44(sp)
 37c:	02812403          	lw	s0,40(sp)
 380:	03010113          	addi	sp,sp,48
 384:	00008067          	ret

00000388 <strlen>:
 388:	fd010113          	addi	sp,sp,-48
 38c:	02812623          	sw	s0,44(sp)
 390:	03010413          	addi	s0,sp,48
 394:	fca42e23          	sw	a0,-36(s0)
 398:	fdc42783          	lw	a5,-36(s0)
 39c:	fef42423          	sw	a5,-24(s0)
 3a0:	fe042623          	sw	zero,-20(s0)
 3a4:	0100006f          	j	3b4 <strlen+0x2c>
 3a8:	fec42783          	lw	a5,-20(s0)
 3ac:	00178793          	addi	a5,a5,1
 3b0:	fef42623          	sw	a5,-20(s0)
 3b4:	fec42783          	lw	a5,-20(s0)
 3b8:	fe842703          	lw	a4,-24(s0)
 3bc:	00f707b3          	add	a5,a4,a5
 3c0:	0007c783          	lbu	a5,0(a5)
 3c4:	fe0792e3          	bnez	a5,3a8 <strlen+0x20>
 3c8:	fec42783          	lw	a5,-20(s0)
 3cc:	00078513          	mv	a0,a5
 3d0:	02c12403          	lw	s0,44(sp)
 3d4:	03010113          	addi	sp,sp,48
 3d8:	00008067          	ret

000003dc <atoi>:
 3dc:	fc010113          	addi	sp,sp,-64
 3e0:	02112e23          	sw	ra,60(sp)
 3e4:	02812c23          	sw	s0,56(sp)
 3e8:	04010413          	addi	s0,sp,64
 3ec:	fca42623          	sw	a0,-52(s0)
 3f0:	fcc42503          	lw	a0,-52(s0)
 3f4:	f95ff0ef          	jal	ra,388 <strlen>
 3f8:	fea42223          	sw	a0,-28(s0)
 3fc:	fe042423          	sw	zero,-24(s0)
 400:	00100793          	li	a5,1
 404:	fef42023          	sw	a5,-32(s0)
 408:	0840006f          	j	48c <atoi+0xb0>
 40c:	fec42783          	lw	a5,-20(s0)
 410:	fcc42703          	lw	a4,-52(s0)
 414:	00f707b3          	add	a5,a4,a5
 418:	0007c783          	lbu	a5,0(a5)
 41c:	fd078793          	addi	a5,a5,-48
 420:	fcf42e23          	sw	a5,-36(s0)
 424:	fdc42703          	lw	a4,-36(s0)
 428:	ffd00793          	li	a5,-3
 42c:	00f71863          	bne	a4,a5,43c <atoi+0x60>
 430:	fe842783          	lw	a5,-24(s0)
 434:	40f007b3          	neg	a5,a5
 438:	0600006f          	j	498 <atoi+0xbc>
 43c:	fdc42783          	lw	a5,-36(s0)
 440:	0207cc63          	bltz	a5,478 <atoi+0x9c>
 444:	fdc42703          	lw	a4,-36(s0)
 448:	00900793          	li	a5,9
 44c:	02e7c663          	blt	a5,a4,478 <atoi+0x9c>
 450:	fdc42783          	lw	a5,-36(s0)
 454:	fe042703          	lw	a4,-32(s0)
 458:	00070593          	mv	a1,a4
 45c:	00078513          	mv	a0,a5
 460:	1e0000ef          	jal	ra,640 <multiply>
 464:	00050713          	mv	a4,a0
 468:	fe842783          	lw	a5,-24(s0)
 46c:	00e787b3          	add	a5,a5,a4
 470:	fef42423          	sw	a5,-24(s0)
 474:	00c0006f          	j	480 <atoi+0xa4>
 478:	fff00793          	li	a5,-1
 47c:	01c0006f          	j	498 <atoi+0xbc>
 480:	fec42783          	lw	a5,-20(s0)
 484:	fff78793          	addi	a5,a5,-1
 488:	fef42623          	sw	a5,-20(s0)
 48c:	fec42783          	lw	a5,-20(s0)
 490:	f607dee3          	bgez	a5,40c <atoi+0x30>
 494:	fe842783          	lw	a5,-24(s0)
 498:	00078513          	mv	a0,a5
 49c:	03c12083          	lw	ra,60(sp)
 4a0:	03812403          	lw	s0,56(sp)
 4a4:	04010113          	addi	sp,sp,64
 4a8:	00008067          	ret

000004ac <itoa>:
 4ac:	fd010113          	addi	sp,sp,-48
 4b0:	02112623          	sw	ra,44(sp)
 4b4:	02812423          	sw	s0,40(sp)
 4b8:	03010413          	addi	s0,sp,48
 4bc:	fca42e23          	sw	a0,-36(s0)
 4c0:	fcb42c23          	sw	a1,-40(s0)
 4c4:	fe042223          	sw	zero,-28(s0)
 4c8:	fdc42783          	lw	a5,-36(s0)
 4cc:	0207d863          	bgez	a5,4fc <itoa+0x50>
 4d0:	fe442783          	lw	a5,-28(s0)
 4d4:	fd842703          	lw	a4,-40(s0)
 4d8:	00f707b3          	add	a5,a4,a5
 4dc:	02d00713          	li	a4,45
 4e0:	00e78023          	sb	a4,0(a5)
 4e4:	fdc42783          	lw	a5,-36(s0)
 4e8:	40f007b3          	neg	a5,a5
 4ec:	fcf42e23          	sw	a5,-36(s0)
 4f0:	fe442783          	lw	a5,-28(s0)
 4f4:	00178793          	addi	a5,a5,1
 4f8:	fef42223          	sw	a5,-28(s0)
 4fc:	fdc42703          	lw	a4,-36(s0)
 500:	00900793          	li	a5,9
 504:	02e7c463          	blt	a5,a4,52c <itoa+0x80>
 508:	fdc42783          	lw	a5,-36(s0)
 50c:	0ff7f713          	andi	a4,a5,255
 510:	fe442783          	lw	a5,-28(s0)
 514:	fd842683          	lw	a3,-40(s0)
 518:	00f687b3          	add	a5,a3,a5
 51c:	03070713          	addi	a4,a4,48
 520:	0ff77713          	andi	a4,a4,255
 524:	00e78023          	sb	a4,0(a5)
 528:	0d40006f          	j	5fc <itoa+0x150>
 52c:	00100793          	li	a5,1
 530:	fef42623          	sw	a5,-20(s0)
 534:	0180006f          	j	54c <itoa+0xa0>
 538:	fec42783          	lw	a5,-20(s0)
 53c:	00a00593          	li	a1,10
 540:	00078513          	mv	a0,a5
 544:	0fc000ef          	jal	ra,640 <multiply>
 548:	fea42623          	sw	a0,-20(s0)
 54c:	fec42583          	lw	a1,-20(s0)
 550:	fdc42503          	lw	a0,-36(s0)
 554:	158000ef          	jal	ra,6ac <divide>
 558:	00050793          	mv	a5,a0
 55c:	fcf04ee3          	bgtz	a5,538 <itoa+0x8c>
 560:	00a00593          	li	a1,10
 564:	fec42503          	lw	a0,-20(s0)
 568:	144000ef          	jal	ra,6ac <divide>
 56c:	fea42423          	sw	a0,-24(s0)
 570:	fec42583          	lw	a1,-20(s0)
 574:	fdc42503          	lw	a0,-36(s0)
 578:	268000ef          	jal	ra,7e0 <modulo>
 57c:	00050793          	mv	a5,a0
 580:	fe842583          	lw	a1,-24(s0)
 584:	00078513          	mv	a0,a5
 588:	124000ef          	jal	ra,6ac <divide>
 58c:	fea42023          	sw	a0,-32(s0)
 590:	fe042783          	lw	a5,-32(s0)
 594:	0ff7f713          	andi	a4,a5,255
 598:	fe442783          	lw	a5,-28(s0)
 59c:	fd842683          	lw	a3,-40(s0)
 5a0:	00f687b3          	add	a5,a3,a5
 5a4:	03070713          	addi	a4,a4,48
 5a8:	0ff77713          	andi	a4,a4,255
 5ac:	00e78023          	sb	a4,0(a5)
 5b0:	fe442783          	lw	a5,-28(s0)
 5b4:	00178793          	addi	a5,a5,1
 5b8:	fef42223          	sw	a5,-28(s0)
 5bc:	fe842703          	lw	a4,-24(s0)
 5c0:	00100793          	li	a5,1
 5c4:	02f70a63          	beq	a4,a5,5f8 <itoa+0x14c>
 5c8:	fe442703          	lw	a4,-28(s0)
 5cc:	00c00793          	li	a5,12
 5d0:	02f70463          	beq	a4,a5,5f8 <itoa+0x14c>
 5d4:	00a00593          	li	a1,10
 5d8:	fe842503          	lw	a0,-24(s0)
 5dc:	0d0000ef          	jal	ra,6ac <divide>
 5e0:	fea42423          	sw	a0,-24(s0)
 5e4:	00a00593          	li	a1,10
 5e8:	fec42503          	lw	a0,-20(s0)
 5ec:	0c0000ef          	jal	ra,6ac <divide>
 5f0:	fea42623          	sw	a0,-20(s0)
 5f4:	f7dff06f          	j	570 <itoa+0xc4>
 5f8:	00000013          	nop
 5fc:	02c12083          	lw	ra,44(sp)
 600:	02812403          	lw	s0,40(sp)
 604:	03010113          	addi	sp,sp,48
 608:	00008067          	ret

0000060c <abs>:
 60c:	fe010113          	addi	sp,sp,-32
 610:	00812e23          	sw	s0,28(sp)
 614:	02010413          	addi	s0,sp,32
 618:	fea42623          	sw	a0,-20(s0)
 61c:	fec42783          	lw	a5,-20(s0)
 620:	41f7d713          	srai	a4,a5,0x1f
 624:	fec42783          	lw	a5,-20(s0)
 628:	00f747b3          	xor	a5,a4,a5
 62c:	40e787b3          	sub	a5,a5,a4
 630:	00078513          	mv	a0,a5
 634:	01c12403          	lw	s0,28(sp)
 638:	02010113          	addi	sp,sp,32
 63c:	00008067          	ret

00000640 <multiply>:
 640:	fd010113          	addi	sp,sp,-48
 644:	02812623          	sw	s0,44(sp)
 648:	03010413          	addi	s0,sp,48
 64c:	fca42e23          	sw	a0,-36(s0)
 650:	fcb42c23          	sw	a1,-40(s0)
 654:	fe042623          	sw	zero,-20(s0)
 658:	0380006f          	j	690 <multiply+0x50>
 65c:	fdc42783          	lw	a5,-36(s0)
 660:	0017f793          	andi	a5,a5,1
 664:	00078a63          	beqz	a5,678 <multiply+0x38>
 668:	fec42703          	lw	a4,-20(s0)
 66c:	fd842783          	lw	a5,-40(s0)
 670:	00f707b3          	add	a5,a4,a5
 674:	fef42623          	sw	a5,-20(s0)
 678:	fdc42783          	lw	a5,-36(s0)
 67c:	0017d793          	srli	a5,a5,0x1
 680:	fcf42e23          	sw	a5,-36(s0)
 684:	fd842783          	lw	a5,-40(s0)
 688:	00179793          	slli	a5,a5,0x1
 68c:	fcf42c23          	sw	a5,-40(s0)
 690:	fdc42783          	lw	a5,-36(s0)
 694:	fc0794e3          	bnez	a5,65c <multiply+0x1c>
 698:	fec42783          	lw	a5,-20(s0)
 69c:	00078513          	mv	a0,a5
 6a0:	02c12403          	lw	s0,44(sp)
 6a4:	03010113          	addi	sp,sp,48
 6a8:	00008067          	ret

000006ac <divide>:
 6ac:	fd010113          	addi	sp,sp,-48
 6b0:	02112623          	sw	ra,44(sp)
 6b4:	02812423          	sw	s0,40(sp)
 6b8:	03010413          	addi	s0,sp,48
 6bc:	fca42e23          	sw	a0,-36(s0)
 6c0:	fcb42c23          	sw	a1,-40(s0)
 6c4:	fd842783          	lw	a5,-40(s0)
 6c8:	00079663          	bnez	a5,6d4 <divide+0x28>
 6cc:	00000793          	li	a5,0
 6d0:	0fc0006f          	j	7cc <divide+0x120>
 6d4:	00100793          	li	a5,1
 6d8:	fef42623          	sw	a5,-20(s0)
 6dc:	fdc42783          	lw	a5,-36(s0)
 6e0:	fd842703          	lw	a4,-40(s0)
 6e4:	00070593          	mv	a1,a4
 6e8:	00078513          	mv	a0,a5
 6ec:	f55ff0ef          	jal	ra,640 <multiply>
 6f0:	00050793          	mv	a5,a0
 6f4:	0007d663          	bgez	a5,700 <divide+0x54>
 6f8:	fff00793          	li	a5,-1
 6fc:	fef42623          	sw	a5,-20(s0)
 700:	fdc42783          	lw	a5,-36(s0)
 704:	41f7d793          	srai	a5,a5,0x1f
 708:	fdc42703          	lw	a4,-36(s0)
 70c:	00f74733          	xor	a4,a4,a5
 710:	40f707b3          	sub	a5,a4,a5
 714:	fcf42e23          	sw	a5,-36(s0)
 718:	fd842783          	lw	a5,-40(s0)
 71c:	41f7d793          	srai	a5,a5,0x1f
 720:	fd842703          	lw	a4,-40(s0)
 724:	00f74733          	xor	a4,a4,a5
 728:	40f707b3          	sub	a5,a4,a5
 72c:	fcf42c23          	sw	a5,-40(s0)
 730:	00100793          	li	a5,1
 734:	fef42423          	sw	a5,-24(s0)
 738:	fe042223          	sw	zero,-28(s0)
 73c:	01c0006f          	j	758 <divide+0xac>
 740:	fd842783          	lw	a5,-40(s0)
 744:	00179793          	slli	a5,a5,0x1
 748:	fcf42c23          	sw	a5,-40(s0)
 74c:	fe842783          	lw	a5,-24(s0)
 750:	00179793          	slli	a5,a5,0x1
 754:	fef42423          	sw	a5,-24(s0)
 758:	fd842703          	lw	a4,-40(s0)
 75c:	fdc42783          	lw	a5,-36(s0)
 760:	fee7d0e3          	ble	a4,a5,740 <divide+0x94>
 764:	0480006f          	j	7ac <divide+0x100>
 768:	fd842783          	lw	a5,-40(s0)
 76c:	4017d793          	srai	a5,a5,0x1
 770:	fcf42c23          	sw	a5,-40(s0)
 774:	fe842783          	lw	a5,-24(s0)
 778:	0017d793          	srli	a5,a5,0x1
 77c:	fef42423          	sw	a5,-24(s0)
 780:	fdc42703          	lw	a4,-36(s0)
 784:	fd842783          	lw	a5,-40(s0)
 788:	02f74263          	blt	a4,a5,7ac <divide+0x100>
 78c:	fdc42703          	lw	a4,-36(s0)
 790:	fd842783          	lw	a5,-40(s0)
 794:	40f707b3          	sub	a5,a4,a5
 798:	fcf42e23          	sw	a5,-36(s0)
 79c:	fe442703          	lw	a4,-28(s0)
 7a0:	fe842783          	lw	a5,-24(s0)
 7a4:	00f767b3          	or	a5,a4,a5
 7a8:	fef42223          	sw	a5,-28(s0)
 7ac:	fe842703          	lw	a4,-24(s0)
 7b0:	00100793          	li	a5,1
 7b4:	fae7eae3          	bltu	a5,a4,768 <divide+0xbc>
 7b8:	fec42783          	lw	a5,-20(s0)
 7bc:	fe442583          	lw	a1,-28(s0)
 7c0:	00078513          	mv	a0,a5
 7c4:	e7dff0ef          	jal	ra,640 <multiply>
 7c8:	00050793          	mv	a5,a0
 7cc:	00078513          	mv	a0,a5
 7d0:	02c12083          	lw	ra,44(sp)
 7d4:	02812403          	lw	s0,40(sp)
 7d8:	03010113          	addi	sp,sp,48
 7dc:	00008067          	ret

000007e0 <modulo>:
 7e0:	fd010113          	addi	sp,sp,-48
 7e4:	02112623          	sw	ra,44(sp)
 7e8:	02812423          	sw	s0,40(sp)
 7ec:	03010413          	addi	s0,sp,48
 7f0:	fca42e23          	sw	a0,-36(s0)
 7f4:	fcb42c23          	sw	a1,-40(s0)
 7f8:	fd842783          	lw	a5,-40(s0)
 7fc:	00079663          	bnez	a5,808 <modulo+0x28>
 800:	00000793          	li	a5,0
 804:	0d80006f          	j	8dc <modulo+0xfc>
 808:	00100793          	li	a5,1
 80c:	fef42623          	sw	a5,-20(s0)
 810:	fdc42783          	lw	a5,-36(s0)
 814:	0007d663          	bgez	a5,820 <modulo+0x40>
 818:	fff00793          	li	a5,-1
 81c:	fef42623          	sw	a5,-20(s0)
 820:	fdc42783          	lw	a5,-36(s0)
 824:	41f7d793          	srai	a5,a5,0x1f
 828:	fdc42703          	lw	a4,-36(s0)
 82c:	00f74733          	xor	a4,a4,a5
 830:	40f707b3          	sub	a5,a4,a5
 834:	fcf42e23          	sw	a5,-36(s0)
 838:	fd842783          	lw	a5,-40(s0)
 83c:	41f7d793          	srai	a5,a5,0x1f
 840:	fd842703          	lw	a4,-40(s0)
 844:	00f74733          	xor	a4,a4,a5
 848:	40f707b3          	sub	a5,a4,a5
 84c:	fcf42c23          	sw	a5,-40(s0)
 850:	00100793          	li	a5,1
 854:	fef42423          	sw	a5,-24(s0)
 858:	01c0006f          	j	874 <modulo+0x94>
 85c:	fd842783          	lw	a5,-40(s0)
 860:	00179793          	slli	a5,a5,0x1
 864:	fcf42c23          	sw	a5,-40(s0)
 868:	fe842783          	lw	a5,-24(s0)
 86c:	00179793          	slli	a5,a5,0x1
 870:	fef42423          	sw	a5,-24(s0)
 874:	fd842703          	lw	a4,-40(s0)
 878:	fdc42783          	lw	a5,-36(s0)
 87c:	fee7d0e3          	ble	a4,a5,85c <modulo+0x7c>
 880:	0380006f          	j	8b8 <modulo+0xd8>
 884:	fd842783          	lw	a5,-40(s0)
 888:	4017d793          	srai	a5,a5,0x1
 88c:	fcf42c23          	sw	a5,-40(s0)
 890:	fe842783          	lw	a5,-24(s0)
 894:	0017d793          	srli	a5,a5,0x1
 898:	fef42423          	sw	a5,-24(s0)
 89c:	fdc42703          	lw	a4,-36(s0)
 8a0:	fd842783          	lw	a5,-40(s0)
 8a4:	00f74a63          	blt	a4,a5,8b8 <modulo+0xd8>
 8a8:	fdc42703          	lw	a4,-36(s0)
 8ac:	fd842783          	lw	a5,-40(s0)
 8b0:	40f707b3          	sub	a5,a4,a5
 8b4:	fcf42e23          	sw	a5,-36(s0)
 8b8:	fe842703          	lw	a4,-24(s0)
 8bc:	00100793          	li	a5,1
 8c0:	fce7e2e3          	bltu	a5,a4,884 <modulo+0xa4>
 8c4:	fec42783          	lw	a5,-20(s0)
 8c8:	fdc42703          	lw	a4,-36(s0)
 8cc:	00070593          	mv	a1,a4
 8d0:	00078513          	mv	a0,a5
 8d4:	d6dff0ef          	jal	ra,640 <multiply>
 8d8:	00050793          	mv	a5,a0
 8dc:	00078513          	mv	a0,a5
 8e0:	02c12083          	lw	ra,44(sp)
 8e4:	02812403          	lw	s0,40(sp)
 8e8:	03010113          	addi	sp,sp,48
 8ec:	00008067          	ret

000008f0 <count_digits>:
 8f0:	fd010113          	addi	sp,sp,-48
 8f4:	02112623          	sw	ra,44(sp)
 8f8:	02812423          	sw	s0,40(sp)
 8fc:	03010413          	addi	s0,sp,48
 900:	fca42e23          	sw	a0,-36(s0)
 904:	fe042623          	sw	zero,-20(s0)
 908:	0200006f          	j	928 <count_digits+0x38>
 90c:	00a00593          	li	a1,10
 910:	fdc42503          	lw	a0,-36(s0)
 914:	d99ff0ef          	jal	ra,6ac <divide>
 918:	fca42e23          	sw	a0,-36(s0)
 91c:	fec42783          	lw	a5,-20(s0)
 920:	00178793          	addi	a5,a5,1
 924:	fef42623          	sw	a5,-20(s0)
 928:	fdc42783          	lw	a5,-36(s0)
 92c:	fe0790e3          	bnez	a5,90c <count_digits+0x1c>
 930:	fec42783          	lw	a5,-20(s0)
 934:	00078513          	mv	a0,a5
 938:	02c12083          	lw	ra,44(sp)
 93c:	02812403          	lw	s0,40(sp)
 940:	03010113          	addi	sp,sp,48
 944:	00008067          	ret

00000948 <__mulsi3>:
 948:	fd010113          	addi	sp,sp,-48
 94c:	02812623          	sw	s0,44(sp)
 950:	03010413          	addi	s0,sp,48
 954:	fca42e23          	sw	a0,-36(s0)
 958:	fcb42c23          	sw	a1,-40(s0)
 95c:	fe042623          	sw	zero,-20(s0)
 960:	fd842783          	lw	a5,-40(s0)
 964:	0007de63          	bgez	a5,980 <__mulsi3+0x38>
 968:	fdc42783          	lw	a5,-36(s0)
 96c:	40f007b3          	neg	a5,a5
 970:	fcf42e23          	sw	a5,-36(s0)
 974:	fd842783          	lw	a5,-40(s0)
 978:	40f007b3          	neg	a5,a5
 97c:	fcf42c23          	sw	a5,-40(s0)
 980:	fe042423          	sw	zero,-24(s0)
 984:	0200006f          	j	9a4 <__mulsi3+0x5c>
 988:	fec42703          	lw	a4,-20(s0)
 98c:	fdc42783          	lw	a5,-36(s0)
 990:	00f707b3          	add	a5,a4,a5
 994:	fef42623          	sw	a5,-20(s0)
 998:	fe842783          	lw	a5,-24(s0)
 99c:	00178793          	addi	a5,a5,1
 9a0:	fef42423          	sw	a5,-24(s0)
 9a4:	fe842703          	lw	a4,-24(s0)
 9a8:	fd842783          	lw	a5,-40(s0)
 9ac:	fcf74ee3          	blt	a4,a5,988 <__mulsi3+0x40>
 9b0:	fec42783          	lw	a5,-20(s0)
 9b4:	00078513          	mv	a0,a5
 9b8:	02c12403          	lw	s0,44(sp)
 9bc:	03010113          	addi	sp,sp,48
 9c0:	00008067          	ret

000009c4 <__divsi3>:
 9c4:	fd010113          	addi	sp,sp,-48
 9c8:	02812623          	sw	s0,44(sp)
 9cc:	03010413          	addi	s0,sp,48
 9d0:	fca42e23          	sw	a0,-36(s0)
 9d4:	fcb42c23          	sw	a1,-40(s0)
 9d8:	fe042623          	sw	zero,-20(s0)
 9dc:	fdc42703          	lw	a4,-36(s0)
 9e0:	fd842783          	lw	a5,-40(s0)
 9e4:	00f75663          	ble	a5,a4,9f0 <__divsi3+0x2c>
 9e8:	fec42783          	lw	a5,-20(s0)
 9ec:	0240006f          	j	a10 <__divsi3+0x4c>
 9f0:	fdc42703          	lw	a4,-36(s0)
 9f4:	fd842783          	lw	a5,-40(s0)
 9f8:	40f707b3          	sub	a5,a4,a5
 9fc:	fcf42e23          	sw	a5,-36(s0)
 a00:	fec42783          	lw	a5,-20(s0)
 a04:	00178793          	addi	a5,a5,1
 a08:	fef42623          	sw	a5,-20(s0)
 a0c:	fd1ff06f          	j	9dc <__divsi3+0x18>
 a10:	00078513          	mv	a0,a5
 a14:	02c12403          	lw	s0,44(sp)
 a18:	03010113          	addi	sp,sp,48
 a1c:	00008067          	ret

00000a20 <__udivsi3>:
 a20:	fd010113          	addi	sp,sp,-48
 a24:	02812623          	sw	s0,44(sp)
 a28:	03010413          	addi	s0,sp,48
 a2c:	fca42e23          	sw	a0,-36(s0)
 a30:	fcb42c23          	sw	a1,-40(s0)
 a34:	fe042623          	sw	zero,-20(s0)
 a38:	fdc42703          	lw	a4,-36(s0)
 a3c:	fd842783          	lw	a5,-40(s0)
 a40:	00f75663          	ble	a5,a4,a4c <__udivsi3+0x2c>
 a44:	fec42783          	lw	a5,-20(s0)
 a48:	0240006f          	j	a6c <__udivsi3+0x4c>
 a4c:	fdc42703          	lw	a4,-36(s0)
 a50:	fd842783          	lw	a5,-40(s0)
 a54:	40f707b3          	sub	a5,a4,a5
 a58:	fcf42e23          	sw	a5,-36(s0)
 a5c:	fec42783          	lw	a5,-20(s0)
 a60:	00178793          	addi	a5,a5,1
 a64:	fef42623          	sw	a5,-20(s0)
 a68:	fd1ff06f          	j	a38 <__udivsi3+0x18>
 a6c:	00078513          	mv	a0,a5
 a70:	02c12403          	lw	s0,44(sp)
 a74:	03010113          	addi	sp,sp,48
 a78:	00008067          	ret

00000a7c <__modsi3>:
 a7c:	fe010113          	addi	sp,sp,-32
 a80:	00812e23          	sw	s0,28(sp)
 a84:	02010413          	addi	s0,sp,32
 a88:	fea42623          	sw	a0,-20(s0)
 a8c:	feb42423          	sw	a1,-24(s0)
 a90:	fe842703          	lw	a4,-24(s0)
 a94:	fec42783          	lw	a5,-20(s0)
 a98:	00e7d663          	ble	a4,a5,aa4 <__modsi3+0x28>
 a9c:	fec42783          	lw	a5,-20(s0)
 aa0:	0180006f          	j	ab8 <__modsi3+0x3c>
 aa4:	fec42703          	lw	a4,-20(s0)
 aa8:	fe842783          	lw	a5,-24(s0)
 aac:	40f707b3          	sub	a5,a4,a5
 ab0:	fef42623          	sw	a5,-20(s0)
 ab4:	fddff06f          	j	a90 <__modsi3+0x14>
 ab8:	00078513          	mv	a0,a5
 abc:	01c12403          	lw	s0,28(sp)
 ac0:	02010113          	addi	sp,sp,32
 ac4:	00008067          	ret

00000ac8 <set_CRAS>:
 ac8:	fd010113          	addi	sp,sp,-48
 acc:	02812623          	sw	s0,44(sp)
 ad0:	03010413          	addi	s0,sp,48
 ad4:	00050793          	mv	a5,a0
 ad8:	fcf40fa3          	sb	a5,-33(s0)
 adc:	aaaaa7b7          	lui	a5,0xaaaaa
 ae0:	60078793          	addi	a5,a5,1536 # aaaaa600 <_rp0+0xaaa885bc>
 ae4:	fef42623          	sw	a5,-20(s0)
 ae8:	fec42783          	lw	a5,-20(s0)
 aec:	fdf44703          	lbu	a4,-33(s0)
 af0:	00e78023          	sb	a4,0(a5)
 af4:	00000013          	nop
 af8:	02c12403          	lw	s0,44(sp)
 afc:	03010113          	addi	sp,sp,48
 b00:	00008067          	ret

00000b04 <set_CRAS_base_addr>:
 b04:	fd010113          	addi	sp,sp,-48
 b08:	02812623          	sw	s0,44(sp)
 b0c:	03010413          	addi	s0,sp,48
 b10:	fca42e23          	sw	a0,-36(s0)
 b14:	aaaaa7b7          	lui	a5,0xaaaaa
 b18:	60478793          	addi	a5,a5,1540 # aaaaa604 <_rp0+0xaaa885c0>
 b1c:	fef42623          	sw	a5,-20(s0)
 b20:	fec42783          	lw	a5,-20(s0)
 b24:	fdc42703          	lw	a4,-36(s0)
 b28:	00e7a023          	sw	a4,0(a5)
 b2c:	00000013          	nop
 b30:	02c12403          	lw	s0,44(sp)
 b34:	03010113          	addi	sp,sp,48
 b38:	00008067          	ret

00000b3c <set_key_word>:
 b3c:	fd010113          	addi	sp,sp,-48
 b40:	02812623          	sw	s0,44(sp)
 b44:	03010413          	addi	s0,sp,48
 b48:	fca42e23          	sw	a0,-36(s0)
 b4c:	aaaaa7b7          	lui	a5,0xaaaaa
 b50:	61078793          	addi	a5,a5,1552 # aaaaa610 <_rp0+0xaaa885cc>
 b54:	fef42623          	sw	a5,-20(s0)
 b58:	fdc42783          	lw	a5,-36(s0)
 b5c:	0007a703          	lw	a4,0(a5)
 b60:	fec42783          	lw	a5,-20(s0)
 b64:	00e7a023          	sw	a4,0(a5)
 b68:	fec42783          	lw	a5,-20(s0)
 b6c:	00478793          	addi	a5,a5,4
 b70:	fdc42703          	lw	a4,-36(s0)
 b74:	00472703          	lw	a4,4(a4)
 b78:	00e7a023          	sw	a4,0(a5)
 b7c:	fec42783          	lw	a5,-20(s0)
 b80:	00878793          	addi	a5,a5,8
 b84:	fdc42703          	lw	a4,-36(s0)
 b88:	00872703          	lw	a4,8(a4)
 b8c:	00e7a023          	sw	a4,0(a5)
 b90:	fec42783          	lw	a5,-20(s0)
 b94:	00c78793          	addi	a5,a5,12
 b98:	fdc42703          	lw	a4,-36(s0)
 b9c:	00c72703          	lw	a4,12(a4)
 ba0:	00e7a023          	sw	a4,0(a5)
 ba4:	00000013          	nop
 ba8:	02c12403          	lw	s0,44(sp)
 bac:	03010113          	addi	sp,sp,48
 bb0:	00008067          	ret
