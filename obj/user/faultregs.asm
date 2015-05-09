
obj/user/faultregs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 67 05 00 00       	call   800598 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c3                	mov    %eax,%ebx
  80003f:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 11 18 80 	movl   $0x801811,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 e0 17 80 00 	movl   $0x8017e0,(%esp)
  80005b:	e8 a3 06 00 00       	call   800703 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 f0 17 80 	movl   $0x8017f0,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  80007b:	e8 83 06 00 00       	call   800703 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  80008d:	e8 71 06 00 00       	call   800703 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  8000a0:	e8 5e 06 00 00       	call   800703 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 12 18 80 	movl   $0x801812,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  8000c7:	e8 37 06 00 00       	call   800703 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  8000db:	e8 23 06 00 00       	call   800703 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  8000e9:	e8 15 06 00 00       	call   800703 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 16 18 80 	movl   $0x801816,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  800110:	e8 ee 05 00 00       	call   800703 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  800124:	e8 da 05 00 00       	call   800703 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  800132:	e8 cc 05 00 00       	call   800703 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 1a 18 80 	movl   $0x80181a,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  800159:	e8 a5 05 00 00       	call   800703 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  80016d:	e8 91 05 00 00       	call   800703 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  80017b:	e8 83 05 00 00       	call   800703 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 1e 18 80 	movl   $0x80181e,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  8001a2:	e8 5c 05 00 00       	call   800703 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  8001b6:	e8 48 05 00 00       	call   800703 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  8001c4:	e8 3a 05 00 00       	call   800703 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 22 18 80 	movl   $0x801822,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  8001eb:	e8 13 05 00 00       	call   800703 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  8001ff:	e8 ff 04 00 00       	call   800703 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  80020d:	e8 f1 04 00 00       	call   800703 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 26 18 80 	movl   $0x801826,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  800234:	e8 ca 04 00 00       	call   800703 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  800248:	e8 b6 04 00 00       	call   800703 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  800256:	e8 a8 04 00 00       	call   800703 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 2a 18 80 	movl   $0x80182a,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  80027d:	e8 81 04 00 00       	call   800703 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  800291:	e8 6d 04 00 00       	call   800703 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  80029f:	e8 5f 04 00 00       	call   800703 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 2e 18 80 	movl   $0x80182e,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  8002c6:	e8 38 04 00 00       	call   800703 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  8002da:	e8 24 04 00 00       	call   800703 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  8002e8:	e8 16 04 00 00       	call   800703 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 35 18 80 	movl   $0x801835,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  80030f:	e8 ef 03 00 00       	call   800703 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  800323:	e8 db 03 00 00       	call   800703 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 39 18 80 00 	movl   $0x801839,(%esp)
  800336:	e8 c8 03 00 00       	call   800703 <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  800348:	e8 b6 03 00 00       	call   800703 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 39 18 80 00 	movl   $0x801839,(%esp)
  80035b:	e8 a3 03 00 00       	call   800703 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  800369:	e8 95 03 00 00       	call   800703 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 08 18 80 00 	movl   $0x801808,(%esp)
  800377:	e8 87 03 00 00       	call   800703 <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 28             	sub    $0x28,%esp
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800395:	74 27                	je     8003be <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800397:	8b 40 28             	mov    0x28(%eax),%eax
  80039a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a2:	c7 44 24 08 a0 18 80 	movl   $0x8018a0,0x8(%esp)
  8003a9:	00 
  8003aa:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b1:	00 
  8003b2:	c7 04 24 47 18 80 00 	movl   $0x801847,(%esp)
  8003b9:	e8 4a 02 00 00       	call   800608 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003be:	8b 50 08             	mov    0x8(%eax),%edx
  8003c1:	89 15 a0 20 80 00    	mov    %edx,0x8020a0
  8003c7:	8b 50 0c             	mov    0xc(%eax),%edx
  8003ca:	89 15 a4 20 80 00    	mov    %edx,0x8020a4
  8003d0:	8b 50 10             	mov    0x10(%eax),%edx
  8003d3:	89 15 a8 20 80 00    	mov    %edx,0x8020a8
  8003d9:	8b 50 14             	mov    0x14(%eax),%edx
  8003dc:	89 15 ac 20 80 00    	mov    %edx,0x8020ac
  8003e2:	8b 50 18             	mov    0x18(%eax),%edx
  8003e5:	89 15 b0 20 80 00    	mov    %edx,0x8020b0
  8003eb:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ee:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8003f4:	8b 50 20             	mov    0x20(%eax),%edx
  8003f7:	89 15 b8 20 80 00    	mov    %edx,0x8020b8
  8003fd:	8b 50 24             	mov    0x24(%eax),%edx
  800400:	89 15 bc 20 80 00    	mov    %edx,0x8020bc
	during.eip = utf->utf_eip;
  800406:	8b 50 28             	mov    0x28(%eax),%edx
  800409:	89 15 c0 20 80 00    	mov    %edx,0x8020c0
	during.eflags = utf->utf_eflags;
  80040f:	8b 50 2c             	mov    0x2c(%eax),%edx
  800412:	89 15 c4 20 80 00    	mov    %edx,0x8020c4
	during.esp = utf->utf_esp;
  800418:	8b 40 30             	mov    0x30(%eax),%eax
  80041b:	a3 c8 20 80 00       	mov    %eax,0x8020c8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800420:	c7 44 24 04 5f 18 80 	movl   $0x80185f,0x4(%esp)
  800427:	00 
  800428:	c7 04 24 6d 18 80 00 	movl   $0x80186d,(%esp)
  80042f:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  800434:	ba 58 18 80 00       	mov    $0x801858,%edx
  800439:	b8 20 20 80 00       	mov    $0x802020,%eax
  80043e:	e8 f1 fb ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800443:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80044a:	00 
  80044b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800452:	00 
  800453:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045a:	e8 bd 0d 00 00       	call   80121c <sys_page_alloc>
  80045f:	85 c0                	test   %eax,%eax
  800461:	79 20                	jns    800483 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	c7 44 24 08 74 18 80 	movl   $0x801874,0x8(%esp)
  80046e:	00 
  80046f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800476:	00 
  800477:	c7 04 24 47 18 80 00 	movl   $0x801847,(%esp)
  80047e:	e8 85 01 00 00       	call   800608 <_panic>
}
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <umain>:

void
umain(int argc, char **argv)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80048b:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800492:	e8 ed 0f 00 00       	call   801484 <set_pgfault_handler>

	__asm __volatile(
  800497:	50                   	push   %eax
  800498:	9c                   	pushf  
  800499:	58                   	pop    %eax
  80049a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049f:	50                   	push   %eax
  8004a0:	9d                   	popf   
  8004a1:	a3 44 20 80 00       	mov    %eax,0x802044
  8004a6:	8d 05 e1 04 80 00    	lea    0x8004e1,%eax
  8004ac:	a3 40 20 80 00       	mov    %eax,0x802040
  8004b1:	58                   	pop    %eax
  8004b2:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004b8:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004be:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004c4:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004ca:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004d0:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8004d6:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8004db:	89 25 48 20 80 00    	mov    %esp,0x802048
  8004e1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e8:	00 00 00 
  8004eb:	89 3d 60 20 80 00    	mov    %edi,0x802060
  8004f1:	89 35 64 20 80 00    	mov    %esi,0x802064
  8004f7:	89 2d 68 20 80 00    	mov    %ebp,0x802068
  8004fd:	89 1d 70 20 80 00    	mov    %ebx,0x802070
  800503:	89 15 74 20 80 00    	mov    %edx,0x802074
  800509:	89 0d 78 20 80 00    	mov    %ecx,0x802078
  80050f:	a3 7c 20 80 00       	mov    %eax,0x80207c
  800514:	89 25 88 20 80 00    	mov    %esp,0x802088
  80051a:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  800520:	8b 35 24 20 80 00    	mov    0x802024,%esi
  800526:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  80052c:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  800532:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800538:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  80053e:	a1 3c 20 80 00       	mov    0x80203c,%eax
  800543:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800549:	50                   	push   %eax
  80054a:	9c                   	pushf  
  80054b:	58                   	pop    %eax
  80054c:	a3 84 20 80 00       	mov    %eax,0x802084
  800551:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800552:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800559:	74 0c                	je     800567 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055b:	c7 04 24 d4 18 80 00 	movl   $0x8018d4,(%esp)
  800562:	e8 9c 01 00 00       	call   800703 <cprintf>
	after.eip = before.eip;
  800567:	a1 40 20 80 00       	mov    0x802040,%eax
  80056c:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	c7 44 24 04 87 18 80 	movl   $0x801887,0x4(%esp)
  800578:	00 
  800579:	c7 04 24 98 18 80 00 	movl   $0x801898,(%esp)
  800580:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800585:	ba 58 18 80 00       	mov    $0x801858,%edx
  80058a:	b8 20 20 80 00       	mov    $0x802020,%eax
  80058f:	e8 a0 fa ff ff       	call   800034 <check_regs>
}
  800594:	c9                   	leave  
  800595:	c3                   	ret    
	...

00800598 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	83 ec 18             	sub    $0x18,%esp
  80059e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005a1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8005aa:	c7 05 cc 20 80 00 00 	movl   $0x0,0x8020cc
  8005b1:	00 00 00 
	envid_t envid = sys_getenvid();
  8005b4:	e8 03 0c 00 00       	call   8011bc <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  8005b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005c6:	a3 cc 20 80 00       	mov    %eax,0x8020cc
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005cb:	85 f6                	test   %esi,%esi
  8005cd:	7e 07                	jle    8005d6 <libmain+0x3e>
		binaryname = argv[0];
  8005cf:	8b 03                	mov    (%ebx),%eax
  8005d1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005da:	89 34 24             	mov    %esi,(%esp)
  8005dd:	e8 a3 fe ff ff       	call   800485 <umain>

	// exit gracefully
	exit();
  8005e2:	e8 0d 00 00 00       	call   8005f4 <exit>
}
  8005e7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005ea:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005ed:	89 ec                	mov    %ebp,%esp
  8005ef:	5d                   	pop    %ebp
  8005f0:	c3                   	ret    
  8005f1:	00 00                	add    %al,(%eax)
	...

008005f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  8005f7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800601:	e8 59 0b 00 00       	call   80115f <sys_env_destroy>
}
  800606:	c9                   	leave  
  800607:	c3                   	ret    

00800608 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800608:	55                   	push   %ebp
  800609:	89 e5                	mov    %esp,%ebp
  80060b:	56                   	push   %esi
  80060c:	53                   	push   %ebx
  80060d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800610:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800613:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800619:	e8 9e 0b 00 00       	call   8011bc <sys_getenvid>
  80061e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800621:	89 54 24 10          	mov    %edx,0x10(%esp)
  800625:	8b 55 08             	mov    0x8(%ebp),%edx
  800628:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80062c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800630:	89 44 24 04          	mov    %eax,0x4(%esp)
  800634:	c7 04 24 00 19 80 00 	movl   $0x801900,(%esp)
  80063b:	e8 c3 00 00 00       	call   800703 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800640:	89 74 24 04          	mov    %esi,0x4(%esp)
  800644:	8b 45 10             	mov    0x10(%ebp),%eax
  800647:	89 04 24             	mov    %eax,(%esp)
  80064a:	e8 53 00 00 00       	call   8006a2 <vcprintf>
	cprintf("\n");
  80064f:	c7 04 24 10 18 80 00 	movl   $0x801810,(%esp)
  800656:	e8 a8 00 00 00       	call   800703 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80065b:	cc                   	int3   
  80065c:	eb fd                	jmp    80065b <_panic+0x53>
	...

00800660 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
  800663:	53                   	push   %ebx
  800664:	83 ec 14             	sub    $0x14,%esp
  800667:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80066a:	8b 03                	mov    (%ebx),%eax
  80066c:	8b 55 08             	mov    0x8(%ebp),%edx
  80066f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800673:	83 c0 01             	add    $0x1,%eax
  800676:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800678:	3d ff 00 00 00       	cmp    $0xff,%eax
  80067d:	75 19                	jne    800698 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80067f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800686:	00 
  800687:	8d 43 08             	lea    0x8(%ebx),%eax
  80068a:	89 04 24             	mov    %eax,(%esp)
  80068d:	e8 6e 0a 00 00       	call   801100 <sys_cputs>
		b->idx = 0;
  800692:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800698:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80069c:	83 c4 14             	add    $0x14,%esp
  80069f:	5b                   	pop    %ebx
  8006a0:	5d                   	pop    %ebp
  8006a1:	c3                   	ret    

008006a2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
  8006a5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8006ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006b2:	00 00 00 
	b.cnt = 0;
  8006b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006bc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d7:	c7 04 24 60 06 80 00 	movl   $0x800660,(%esp)
  8006de:	e8 d1 01 00 00       	call   8008b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006e3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006f3:	89 04 24             	mov    %eax,(%esp)
  8006f6:	e8 05 0a 00 00       	call   801100 <sys_cputs>

	return b.cnt;
}
  8006fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800709:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80070c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	89 04 24             	mov    %eax,(%esp)
  800716:	e8 87 ff ff ff       	call   8006a2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80071b:	c9                   	leave  
  80071c:	c3                   	ret    
  80071d:	00 00                	add    %al,(%eax)
	...

00800720 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	57                   	push   %edi
  800724:	56                   	push   %esi
  800725:	53                   	push   %ebx
  800726:	83 ec 3c             	sub    $0x3c,%esp
  800729:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072c:	89 d7                	mov    %edx,%edi
  80072e:	8b 45 08             	mov    0x8(%ebp),%eax
  800731:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800734:	8b 45 0c             	mov    0xc(%ebp),%eax
  800737:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80073a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80073d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800748:	72 11                	jb     80075b <printnum+0x3b>
  80074a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80074d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800750:	76 09                	jbe    80075b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800752:	83 eb 01             	sub    $0x1,%ebx
  800755:	85 db                	test   %ebx,%ebx
  800757:	7f 51                	jg     8007aa <printnum+0x8a>
  800759:	eb 5e                	jmp    8007b9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80075b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80075f:	83 eb 01             	sub    $0x1,%ebx
  800762:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800766:	8b 45 10             	mov    0x10(%ebp),%eax
  800769:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800771:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800775:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80077c:	00 
  80077d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800786:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078a:	e8 91 0d 00 00       	call   801520 <__udivdi3>
  80078f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800793:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800797:	89 04 24             	mov    %eax,(%esp)
  80079a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079e:	89 fa                	mov    %edi,%edx
  8007a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007a3:	e8 78 ff ff ff       	call   800720 <printnum>
  8007a8:	eb 0f                	jmp    8007b9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ae:	89 34 24             	mov    %esi,(%esp)
  8007b1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007b4:	83 eb 01             	sub    $0x1,%ebx
  8007b7:	75 f1                	jne    8007aa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007bd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007cf:	00 
  8007d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007d3:	89 04 24             	mov    %eax,(%esp)
  8007d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dd:	e8 6e 0e 00 00       	call   801650 <__umoddi3>
  8007e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e6:	0f be 80 24 19 80 00 	movsbl 0x801924(%eax),%eax
  8007ed:	89 04 24             	mov    %eax,(%esp)
  8007f0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007f3:	83 c4 3c             	add    $0x3c,%esp
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5f                   	pop    %edi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007fe:	83 fa 01             	cmp    $0x1,%edx
  800801:	7e 0e                	jle    800811 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800803:	8b 10                	mov    (%eax),%edx
  800805:	8d 4a 08             	lea    0x8(%edx),%ecx
  800808:	89 08                	mov    %ecx,(%eax)
  80080a:	8b 02                	mov    (%edx),%eax
  80080c:	8b 52 04             	mov    0x4(%edx),%edx
  80080f:	eb 22                	jmp    800833 <getuint+0x38>
	else if (lflag)
  800811:	85 d2                	test   %edx,%edx
  800813:	74 10                	je     800825 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800815:	8b 10                	mov    (%eax),%edx
  800817:	8d 4a 04             	lea    0x4(%edx),%ecx
  80081a:	89 08                	mov    %ecx,(%eax)
  80081c:	8b 02                	mov    (%edx),%eax
  80081e:	ba 00 00 00 00       	mov    $0x0,%edx
  800823:	eb 0e                	jmp    800833 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800825:	8b 10                	mov    (%eax),%edx
  800827:	8d 4a 04             	lea    0x4(%edx),%ecx
  80082a:	89 08                	mov    %ecx,(%eax)
  80082c:	8b 02                	mov    (%edx),%eax
  80082e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800838:	83 fa 01             	cmp    $0x1,%edx
  80083b:	7e 0e                	jle    80084b <getint+0x16>
		return va_arg(*ap, long long);
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800842:	89 08                	mov    %ecx,(%eax)
  800844:	8b 02                	mov    (%edx),%eax
  800846:	8b 52 04             	mov    0x4(%edx),%edx
  800849:	eb 22                	jmp    80086d <getint+0x38>
	else if (lflag)
  80084b:	85 d2                	test   %edx,%edx
  80084d:	74 10                	je     80085f <getint+0x2a>
		return va_arg(*ap, long);
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	8d 4a 04             	lea    0x4(%edx),%ecx
  800854:	89 08                	mov    %ecx,(%eax)
  800856:	8b 02                	mov    (%edx),%eax
  800858:	89 c2                	mov    %eax,%edx
  80085a:	c1 fa 1f             	sar    $0x1f,%edx
  80085d:	eb 0e                	jmp    80086d <getint+0x38>
	else
		return va_arg(*ap, int);
  80085f:	8b 10                	mov    (%eax),%edx
  800861:	8d 4a 04             	lea    0x4(%edx),%ecx
  800864:	89 08                	mov    %ecx,(%eax)
  800866:	8b 02                	mov    (%edx),%eax
  800868:	89 c2                	mov    %eax,%edx
  80086a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800875:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800879:	8b 10                	mov    (%eax),%edx
  80087b:	3b 50 04             	cmp    0x4(%eax),%edx
  80087e:	73 0a                	jae    80088a <sprintputch+0x1b>
		*b->buf++ = ch;
  800880:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800883:	88 0a                	mov    %cl,(%edx)
  800885:	83 c2 01             	add    $0x1,%edx
  800888:	89 10                	mov    %edx,(%eax)
}
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800892:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800895:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800899:	8b 45 10             	mov    0x10(%ebp),%eax
  80089c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	89 04 24             	mov    %eax,(%esp)
  8008ad:	e8 02 00 00 00       	call   8008b4 <vprintfmt>
	va_end(ap);
}
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    

008008b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	53                   	push   %ebx
  8008ba:	83 ec 4c             	sub    $0x4c,%esp
  8008bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008c0:	8b 75 10             	mov    0x10(%ebp),%esi
  8008c3:	eb 12                	jmp    8008d7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	0f 84 77 03 00 00    	je     800c44 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  8008cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d1:	89 04 24             	mov    %eax,(%esp)
  8008d4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008d7:	0f b6 06             	movzbl (%esi),%eax
  8008da:	83 c6 01             	add    $0x1,%esi
  8008dd:	83 f8 25             	cmp    $0x25,%eax
  8008e0:	75 e3                	jne    8008c5 <vprintfmt+0x11>
  8008e2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8008e6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8008ed:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8008f2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8008f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008fe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800901:	eb 2b                	jmp    80092e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800903:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800906:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80090a:	eb 22                	jmp    80092e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80090f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800913:	eb 19                	jmp    80092e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800915:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800918:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80091f:	eb 0d                	jmp    80092e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800921:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800924:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800927:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092e:	0f b6 06             	movzbl (%esi),%eax
  800931:	0f b6 d0             	movzbl %al,%edx
  800934:	8d 7e 01             	lea    0x1(%esi),%edi
  800937:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80093a:	83 e8 23             	sub    $0x23,%eax
  80093d:	3c 55                	cmp    $0x55,%al
  80093f:	0f 87 d9 02 00 00    	ja     800c1e <vprintfmt+0x36a>
  800945:	0f b6 c0             	movzbl %al,%eax
  800948:	ff 24 85 e0 19 80 00 	jmp    *0x8019e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80094f:	83 ea 30             	sub    $0x30,%edx
  800952:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800955:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800959:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80095f:	83 fa 09             	cmp    $0x9,%edx
  800962:	77 4a                	ja     8009ae <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800964:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800967:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80096a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80096d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800971:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800974:	8d 50 d0             	lea    -0x30(%eax),%edx
  800977:	83 fa 09             	cmp    $0x9,%edx
  80097a:	76 eb                	jbe    800967 <vprintfmt+0xb3>
  80097c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80097f:	eb 2d                	jmp    8009ae <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800981:	8b 45 14             	mov    0x14(%ebp),%eax
  800984:	8d 50 04             	lea    0x4(%eax),%edx
  800987:	89 55 14             	mov    %edx,0x14(%ebp)
  80098a:	8b 00                	mov    (%eax),%eax
  80098c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800992:	eb 1a                	jmp    8009ae <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800994:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800997:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80099b:	79 91                	jns    80092e <vprintfmt+0x7a>
  80099d:	e9 73 ff ff ff       	jmp    800915 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8009a5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8009ac:	eb 80                	jmp    80092e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8009ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009b2:	0f 89 76 ff ff ff    	jns    80092e <vprintfmt+0x7a>
  8009b8:	e9 64 ff ff ff       	jmp    800921 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009bd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009c3:	e9 66 ff ff ff       	jmp    80092e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009cb:	8d 50 04             	lea    0x4(%eax),%edx
  8009ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d5:	8b 00                	mov    (%eax),%eax
  8009d7:	89 04 24             	mov    %eax,(%esp)
  8009da:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009e0:	e9 f2 fe ff ff       	jmp    8008d7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e8:	8d 50 04             	lea    0x4(%eax),%edx
  8009eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ee:	8b 00                	mov    (%eax),%eax
  8009f0:	89 c2                	mov    %eax,%edx
  8009f2:	c1 fa 1f             	sar    $0x1f,%edx
  8009f5:	31 d0                	xor    %edx,%eax
  8009f7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009f9:	83 f8 08             	cmp    $0x8,%eax
  8009fc:	7f 0b                	jg     800a09 <vprintfmt+0x155>
  8009fe:	8b 14 85 40 1b 80 00 	mov    0x801b40(,%eax,4),%edx
  800a05:	85 d2                	test   %edx,%edx
  800a07:	75 23                	jne    800a2c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800a09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a0d:	c7 44 24 08 3c 19 80 	movl   $0x80193c,0x8(%esp)
  800a14:	00 
  800a15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1c:	89 3c 24             	mov    %edi,(%esp)
  800a1f:	e8 68 fe ff ff       	call   80088c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a24:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800a27:	e9 ab fe ff ff       	jmp    8008d7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800a2c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a30:	c7 44 24 08 45 19 80 	movl   $0x801945,0x8(%esp)
  800a37:	00 
  800a38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3f:	89 3c 24             	mov    %edi,(%esp)
  800a42:	e8 45 fe ff ff       	call   80088c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a47:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a4a:	e9 88 fe ff ff       	jmp    8008d7 <vprintfmt+0x23>
  800a4f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a55:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a58:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5b:	8d 50 04             	lea    0x4(%eax),%edx
  800a5e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a61:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800a63:	85 f6                	test   %esi,%esi
  800a65:	ba 35 19 80 00       	mov    $0x801935,%edx
  800a6a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800a6d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a71:	7e 06                	jle    800a79 <vprintfmt+0x1c5>
  800a73:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800a77:	75 10                	jne    800a89 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a79:	0f be 06             	movsbl (%esi),%eax
  800a7c:	83 c6 01             	add    $0x1,%esi
  800a7f:	85 c0                	test   %eax,%eax
  800a81:	0f 85 86 00 00 00    	jne    800b0d <vprintfmt+0x259>
  800a87:	eb 76                	jmp    800aff <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a89:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a8d:	89 34 24             	mov    %esi,(%esp)
  800a90:	e8 56 02 00 00       	call   800ceb <strnlen>
  800a95:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800a98:	29 c2                	sub    %eax,%edx
  800a9a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a9d:	85 d2                	test   %edx,%edx
  800a9f:	7e d8                	jle    800a79 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800aa1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800aa5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800aa8:	89 7d d0             	mov    %edi,-0x30(%ebp)
  800aab:	89 d6                	mov    %edx,%esi
  800aad:	89 c7                	mov    %eax,%edi
  800aaf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ab3:	89 3c 24             	mov    %edi,(%esp)
  800ab6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ab9:	83 ee 01             	sub    $0x1,%esi
  800abc:	75 f1                	jne    800aaf <vprintfmt+0x1fb>
  800abe:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800ac1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800ac4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800ac7:	eb b0                	jmp    800a79 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ac9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800acd:	74 18                	je     800ae7 <vprintfmt+0x233>
  800acf:	8d 50 e0             	lea    -0x20(%eax),%edx
  800ad2:	83 fa 5e             	cmp    $0x5e,%edx
  800ad5:	76 10                	jbe    800ae7 <vprintfmt+0x233>
					putch('?', putdat);
  800ad7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800adb:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ae2:	ff 55 08             	call   *0x8(%ebp)
  800ae5:	eb 0a                	jmp    800af1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800ae7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aeb:	89 04 24             	mov    %eax,(%esp)
  800aee:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800af1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800af5:	0f be 06             	movsbl (%esi),%eax
  800af8:	83 c6 01             	add    $0x1,%esi
  800afb:	85 c0                	test   %eax,%eax
  800afd:	75 0e                	jne    800b0d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b02:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b06:	7f 11                	jg     800b19 <vprintfmt+0x265>
  800b08:	e9 ca fd ff ff       	jmp    8008d7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b0d:	85 ff                	test   %edi,%edi
  800b0f:	90                   	nop
  800b10:	78 b7                	js     800ac9 <vprintfmt+0x215>
  800b12:	83 ef 01             	sub    $0x1,%edi
  800b15:	79 b2                	jns    800ac9 <vprintfmt+0x215>
  800b17:	eb e6                	jmp    800aff <vprintfmt+0x24b>
  800b19:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800b1c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b23:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b2a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b2c:	83 ee 01             	sub    $0x1,%esi
  800b2f:	75 ee                	jne    800b1f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b31:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b34:	e9 9e fd ff ff       	jmp    8008d7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b39:	89 ca                	mov    %ecx,%edx
  800b3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b3e:	e8 f2 fc ff ff       	call   800835 <getint>
  800b43:	89 c6                	mov    %eax,%esi
  800b45:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b47:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b4c:	85 d2                	test   %edx,%edx
  800b4e:	0f 89 8c 00 00 00    	jns    800be0 <vprintfmt+0x32c>
				putch('-', putdat);
  800b54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b58:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b5f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b62:	f7 de                	neg    %esi
  800b64:	83 d7 00             	adc    $0x0,%edi
  800b67:	f7 df                	neg    %edi
			}
			base = 10;
  800b69:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6e:	eb 70                	jmp    800be0 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b70:	89 ca                	mov    %ecx,%edx
  800b72:	8d 45 14             	lea    0x14(%ebp),%eax
  800b75:	e8 81 fc ff ff       	call   8007fb <getuint>
  800b7a:	89 c6                	mov    %eax,%esi
  800b7c:	89 d7                	mov    %edx,%edi
			base = 10;
  800b7e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b83:	eb 5b                	jmp    800be0 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  800b85:	89 ca                	mov    %ecx,%edx
  800b87:	8d 45 14             	lea    0x14(%ebp),%eax
  800b8a:	e8 a6 fc ff ff       	call   800835 <getint>
  800b8f:	89 c6                	mov    %eax,%esi
  800b91:	89 d7                	mov    %edx,%edi
			base = 8;
  800b93:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b98:	eb 46                	jmp    800be0 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b9e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ba5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800ba8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bac:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bb3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bb6:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb9:	8d 50 04             	lea    0x4(%eax),%edx
  800bbc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bbf:	8b 30                	mov    (%eax),%esi
  800bc1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bc6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bcb:	eb 13                	jmp    800be0 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bcd:	89 ca                	mov    %ecx,%edx
  800bcf:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd2:	e8 24 fc ff ff       	call   8007fb <getuint>
  800bd7:	89 c6                	mov    %eax,%esi
  800bd9:	89 d7                	mov    %edx,%edi
			base = 16;
  800bdb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800be0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800be4:	89 54 24 10          	mov    %edx,0x10(%esp)
  800be8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800beb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bef:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf3:	89 34 24             	mov    %esi,(%esp)
  800bf6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bfa:	89 da                	mov    %ebx,%edx
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bff:	e8 1c fb ff ff       	call   800720 <printnum>
			break;
  800c04:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c07:	e9 cb fc ff ff       	jmp    8008d7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c0c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c10:	89 14 24             	mov    %edx,(%esp)
  800c13:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c16:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c19:	e9 b9 fc ff ff       	jmp    8008d7 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c22:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c29:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c2c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c30:	0f 84 a1 fc ff ff    	je     8008d7 <vprintfmt+0x23>
  800c36:	83 ee 01             	sub    $0x1,%esi
  800c39:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c3d:	75 f7                	jne    800c36 <vprintfmt+0x382>
  800c3f:	e9 93 fc ff ff       	jmp    8008d7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800c44:	83 c4 4c             	add    $0x4c,%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 28             	sub    $0x28,%esp
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c58:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c5b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c5f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	74 30                	je     800c9d <vsnprintf+0x51>
  800c6d:	85 d2                	test   %edx,%edx
  800c6f:	7e 2c                	jle    800c9d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c71:	8b 45 14             	mov    0x14(%ebp),%eax
  800c74:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c86:	c7 04 24 6f 08 80 00 	movl   $0x80086f,(%esp)
  800c8d:	e8 22 fc ff ff       	call   8008b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c92:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c95:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9b:	eb 05                	jmp    800ca2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ca2:	c9                   	leave  
  800ca3:	c3                   	ret    

00800ca4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800caa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cb1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	89 04 24             	mov    %eax,(%esp)
  800cc5:	e8 82 ff ff ff       	call   800c4c <vsnprintf>
	va_end(ap);

	return rc;
}
  800cca:	c9                   	leave  
  800ccb:	c3                   	ret    
  800ccc:	00 00                	add    %al,(%eax)
	...

00800cd0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdb:	80 3a 00             	cmpb   $0x0,(%edx)
  800cde:	74 09                	je     800ce9 <strlen+0x19>
		n++;
  800ce0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ce3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ce7:	75 f7                	jne    800ce0 <strlen+0x10>
		n++;
	return n;
}
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	53                   	push   %ebx
  800cef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfa:	85 c9                	test   %ecx,%ecx
  800cfc:	74 1a                	je     800d18 <strnlen+0x2d>
  800cfe:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d01:	74 15                	je     800d18 <strnlen+0x2d>
  800d03:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d08:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d0a:	39 ca                	cmp    %ecx,%edx
  800d0c:	74 0a                	je     800d18 <strnlen+0x2d>
  800d0e:	83 c2 01             	add    $0x1,%edx
  800d11:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d16:	75 f0                	jne    800d08 <strnlen+0x1d>
		n++;
	return n;
}
  800d18:	5b                   	pop    %ebx
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	53                   	push   %ebx
  800d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d25:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d2e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d31:	83 c2 01             	add    $0x1,%edx
  800d34:	84 c9                	test   %cl,%cl
  800d36:	75 f2                	jne    800d2a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d38:	5b                   	pop    %ebx
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 08             	sub    $0x8,%esp
  800d42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d45:	89 1c 24             	mov    %ebx,(%esp)
  800d48:	e8 83 ff ff ff       	call   800cd0 <strlen>
	strcpy(dst + len, src);
  800d4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d50:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d54:	01 d8                	add    %ebx,%eax
  800d56:	89 04 24             	mov    %eax,(%esp)
  800d59:	e8 bd ff ff ff       	call   800d1b <strcpy>
	return dst;
}
  800d5e:	89 d8                	mov    %ebx,%eax
  800d60:	83 c4 08             	add    $0x8,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d71:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d74:	85 f6                	test   %esi,%esi
  800d76:	74 18                	je     800d90 <strncpy+0x2a>
  800d78:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d7d:	0f b6 1a             	movzbl (%edx),%ebx
  800d80:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d83:	80 3a 01             	cmpb   $0x1,(%edx)
  800d86:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d89:	83 c1 01             	add    $0x1,%ecx
  800d8c:	39 f1                	cmp    %esi,%ecx
  800d8e:	75 ed                	jne    800d7d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
  800d9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800da0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800da3:	89 f8                	mov    %edi,%eax
  800da5:	85 f6                	test   %esi,%esi
  800da7:	74 2b                	je     800dd4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800da9:	83 fe 01             	cmp    $0x1,%esi
  800dac:	74 23                	je     800dd1 <strlcpy+0x3d>
  800dae:	0f b6 0b             	movzbl (%ebx),%ecx
  800db1:	84 c9                	test   %cl,%cl
  800db3:	74 1c                	je     800dd1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800db5:	83 ee 02             	sub    $0x2,%esi
  800db8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800dbd:	88 08                	mov    %cl,(%eax)
  800dbf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dc2:	39 f2                	cmp    %esi,%edx
  800dc4:	74 0b                	je     800dd1 <strlcpy+0x3d>
  800dc6:	83 c2 01             	add    $0x1,%edx
  800dc9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800dcd:	84 c9                	test   %cl,%cl
  800dcf:	75 ec                	jne    800dbd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800dd1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dd4:	29 f8                	sub    %edi,%eax
}
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800de4:	0f b6 01             	movzbl (%ecx),%eax
  800de7:	84 c0                	test   %al,%al
  800de9:	74 16                	je     800e01 <strcmp+0x26>
  800deb:	3a 02                	cmp    (%edx),%al
  800ded:	75 12                	jne    800e01 <strcmp+0x26>
		p++, q++;
  800def:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800df2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800df6:	84 c0                	test   %al,%al
  800df8:	74 07                	je     800e01 <strcmp+0x26>
  800dfa:	83 c1 01             	add    $0x1,%ecx
  800dfd:	3a 02                	cmp    (%edx),%al
  800dff:	74 ee                	je     800def <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e01:	0f b6 c0             	movzbl %al,%eax
  800e04:	0f b6 12             	movzbl (%edx),%edx
  800e07:	29 d0                	sub    %edx,%eax
}
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	53                   	push   %ebx
  800e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e15:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e18:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e1d:	85 d2                	test   %edx,%edx
  800e1f:	74 28                	je     800e49 <strncmp+0x3e>
  800e21:	0f b6 01             	movzbl (%ecx),%eax
  800e24:	84 c0                	test   %al,%al
  800e26:	74 24                	je     800e4c <strncmp+0x41>
  800e28:	3a 03                	cmp    (%ebx),%al
  800e2a:	75 20                	jne    800e4c <strncmp+0x41>
  800e2c:	83 ea 01             	sub    $0x1,%edx
  800e2f:	74 13                	je     800e44 <strncmp+0x39>
		n--, p++, q++;
  800e31:	83 c1 01             	add    $0x1,%ecx
  800e34:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e37:	0f b6 01             	movzbl (%ecx),%eax
  800e3a:	84 c0                	test   %al,%al
  800e3c:	74 0e                	je     800e4c <strncmp+0x41>
  800e3e:	3a 03                	cmp    (%ebx),%al
  800e40:	74 ea                	je     800e2c <strncmp+0x21>
  800e42:	eb 08                	jmp    800e4c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e49:	5b                   	pop    %ebx
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e4c:	0f b6 01             	movzbl (%ecx),%eax
  800e4f:	0f b6 13             	movzbl (%ebx),%edx
  800e52:	29 d0                	sub    %edx,%eax
  800e54:	eb f3                	jmp    800e49 <strncmp+0x3e>

00800e56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e60:	0f b6 10             	movzbl (%eax),%edx
  800e63:	84 d2                	test   %dl,%dl
  800e65:	74 1c                	je     800e83 <strchr+0x2d>
		if (*s == c)
  800e67:	38 ca                	cmp    %cl,%dl
  800e69:	75 09                	jne    800e74 <strchr+0x1e>
  800e6b:	eb 1b                	jmp    800e88 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e6d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800e70:	38 ca                	cmp    %cl,%dl
  800e72:	74 14                	je     800e88 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e74:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800e78:	84 d2                	test   %dl,%dl
  800e7a:	75 f1                	jne    800e6d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800e7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e81:	eb 05                	jmp    800e88 <strchr+0x32>
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    

00800e8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e94:	0f b6 10             	movzbl (%eax),%edx
  800e97:	84 d2                	test   %dl,%dl
  800e99:	74 14                	je     800eaf <strfind+0x25>
		if (*s == c)
  800e9b:	38 ca                	cmp    %cl,%dl
  800e9d:	75 06                	jne    800ea5 <strfind+0x1b>
  800e9f:	eb 0e                	jmp    800eaf <strfind+0x25>
  800ea1:	38 ca                	cmp    %cl,%dl
  800ea3:	74 0a                	je     800eaf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ea5:	83 c0 01             	add    $0x1,%eax
  800ea8:	0f b6 10             	movzbl (%eax),%edx
  800eab:	84 d2                	test   %dl,%dl
  800ead:	75 f2                	jne    800ea1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	83 ec 0c             	sub    $0xc,%esp
  800eb7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ec0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ec9:	85 c9                	test   %ecx,%ecx
  800ecb:	74 30                	je     800efd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ecd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ed3:	75 25                	jne    800efa <memset+0x49>
  800ed5:	f6 c1 03             	test   $0x3,%cl
  800ed8:	75 20                	jne    800efa <memset+0x49>
		c &= 0xFF;
  800eda:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800edd:	89 d3                	mov    %edx,%ebx
  800edf:	c1 e3 08             	shl    $0x8,%ebx
  800ee2:	89 d6                	mov    %edx,%esi
  800ee4:	c1 e6 18             	shl    $0x18,%esi
  800ee7:	89 d0                	mov    %edx,%eax
  800ee9:	c1 e0 10             	shl    $0x10,%eax
  800eec:	09 f0                	or     %esi,%eax
  800eee:	09 d0                	or     %edx,%eax
  800ef0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ef2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ef5:	fc                   	cld    
  800ef6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ef8:	eb 03                	jmp    800efd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800efa:	fc                   	cld    
  800efb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800efd:	89 f8                	mov    %edi,%eax
  800eff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 08             	sub    $0x8,%esp
  800f12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f15:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f18:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f21:	39 c6                	cmp    %eax,%esi
  800f23:	73 36                	jae    800f5b <memmove+0x4f>
  800f25:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f28:	39 d0                	cmp    %edx,%eax
  800f2a:	73 2f                	jae    800f5b <memmove+0x4f>
		s += n;
		d += n;
  800f2c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f2f:	f6 c2 03             	test   $0x3,%dl
  800f32:	75 1b                	jne    800f4f <memmove+0x43>
  800f34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f3a:	75 13                	jne    800f4f <memmove+0x43>
  800f3c:	f6 c1 03             	test   $0x3,%cl
  800f3f:	75 0e                	jne    800f4f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f41:	83 ef 04             	sub    $0x4,%edi
  800f44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f4a:	fd                   	std    
  800f4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f4d:	eb 09                	jmp    800f58 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f4f:	83 ef 01             	sub    $0x1,%edi
  800f52:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f55:	fd                   	std    
  800f56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f58:	fc                   	cld    
  800f59:	eb 20                	jmp    800f7b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f61:	75 13                	jne    800f76 <memmove+0x6a>
  800f63:	a8 03                	test   $0x3,%al
  800f65:	75 0f                	jne    800f76 <memmove+0x6a>
  800f67:	f6 c1 03             	test   $0x3,%cl
  800f6a:	75 0a                	jne    800f76 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f6c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f6f:	89 c7                	mov    %eax,%edi
  800f71:	fc                   	cld    
  800f72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f74:	eb 05                	jmp    800f7b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f76:	89 c7                	mov    %eax,%edi
  800f78:	fc                   	cld    
  800f79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f7b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f81:	89 ec                	mov    %ebp,%esp
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    

00800f85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f99:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9c:	89 04 24             	mov    %eax,(%esp)
  800f9f:	e8 68 ff ff ff       	call   800f0c <memmove>
}
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    

00800fa6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800faf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fb2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fb5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fba:	85 ff                	test   %edi,%edi
  800fbc:	74 37                	je     800ff5 <memcmp+0x4f>
		if (*s1 != *s2)
  800fbe:	0f b6 03             	movzbl (%ebx),%eax
  800fc1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fc4:	83 ef 01             	sub    $0x1,%edi
  800fc7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800fcc:	38 c8                	cmp    %cl,%al
  800fce:	74 1c                	je     800fec <memcmp+0x46>
  800fd0:	eb 10                	jmp    800fe2 <memcmp+0x3c>
  800fd2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800fd7:	83 c2 01             	add    $0x1,%edx
  800fda:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800fde:	38 c8                	cmp    %cl,%al
  800fe0:	74 0a                	je     800fec <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800fe2:	0f b6 c0             	movzbl %al,%eax
  800fe5:	0f b6 c9             	movzbl %cl,%ecx
  800fe8:	29 c8                	sub    %ecx,%eax
  800fea:	eb 09                	jmp    800ff5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fec:	39 fa                	cmp    %edi,%edx
  800fee:	75 e2                	jne    800fd2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ff0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff5:	5b                   	pop    %ebx
  800ff6:	5e                   	pop    %esi
  800ff7:	5f                   	pop    %edi
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801000:	89 c2                	mov    %eax,%edx
  801002:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801005:	39 d0                	cmp    %edx,%eax
  801007:	73 19                	jae    801022 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  801009:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  80100d:	38 08                	cmp    %cl,(%eax)
  80100f:	75 06                	jne    801017 <memfind+0x1d>
  801011:	eb 0f                	jmp    801022 <memfind+0x28>
  801013:	38 08                	cmp    %cl,(%eax)
  801015:	74 0b                	je     801022 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801017:	83 c0 01             	add    $0x1,%eax
  80101a:	39 d0                	cmp    %edx,%eax
  80101c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801020:	75 f1                	jne    801013 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	57                   	push   %edi
  801028:	56                   	push   %esi
  801029:	53                   	push   %ebx
  80102a:	8b 55 08             	mov    0x8(%ebp),%edx
  80102d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801030:	0f b6 02             	movzbl (%edx),%eax
  801033:	3c 20                	cmp    $0x20,%al
  801035:	74 04                	je     80103b <strtol+0x17>
  801037:	3c 09                	cmp    $0x9,%al
  801039:	75 0e                	jne    801049 <strtol+0x25>
		s++;
  80103b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80103e:	0f b6 02             	movzbl (%edx),%eax
  801041:	3c 20                	cmp    $0x20,%al
  801043:	74 f6                	je     80103b <strtol+0x17>
  801045:	3c 09                	cmp    $0x9,%al
  801047:	74 f2                	je     80103b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801049:	3c 2b                	cmp    $0x2b,%al
  80104b:	75 0a                	jne    801057 <strtol+0x33>
		s++;
  80104d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801050:	bf 00 00 00 00       	mov    $0x0,%edi
  801055:	eb 10                	jmp    801067 <strtol+0x43>
  801057:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80105c:	3c 2d                	cmp    $0x2d,%al
  80105e:	75 07                	jne    801067 <strtol+0x43>
		s++, neg = 1;
  801060:	83 c2 01             	add    $0x1,%edx
  801063:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801067:	85 db                	test   %ebx,%ebx
  801069:	0f 94 c0             	sete   %al
  80106c:	74 05                	je     801073 <strtol+0x4f>
  80106e:	83 fb 10             	cmp    $0x10,%ebx
  801071:	75 15                	jne    801088 <strtol+0x64>
  801073:	80 3a 30             	cmpb   $0x30,(%edx)
  801076:	75 10                	jne    801088 <strtol+0x64>
  801078:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80107c:	75 0a                	jne    801088 <strtol+0x64>
		s += 2, base = 16;
  80107e:	83 c2 02             	add    $0x2,%edx
  801081:	bb 10 00 00 00       	mov    $0x10,%ebx
  801086:	eb 13                	jmp    80109b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801088:	84 c0                	test   %al,%al
  80108a:	74 0f                	je     80109b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80108c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801091:	80 3a 30             	cmpb   $0x30,(%edx)
  801094:	75 05                	jne    80109b <strtol+0x77>
		s++, base = 8;
  801096:	83 c2 01             	add    $0x1,%edx
  801099:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80109b:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010a2:	0f b6 0a             	movzbl (%edx),%ecx
  8010a5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8010a8:	80 fb 09             	cmp    $0x9,%bl
  8010ab:	77 08                	ja     8010b5 <strtol+0x91>
			dig = *s - '0';
  8010ad:	0f be c9             	movsbl %cl,%ecx
  8010b0:	83 e9 30             	sub    $0x30,%ecx
  8010b3:	eb 1e                	jmp    8010d3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  8010b5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8010b8:	80 fb 19             	cmp    $0x19,%bl
  8010bb:	77 08                	ja     8010c5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  8010bd:	0f be c9             	movsbl %cl,%ecx
  8010c0:	83 e9 57             	sub    $0x57,%ecx
  8010c3:	eb 0e                	jmp    8010d3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  8010c5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8010c8:	80 fb 19             	cmp    $0x19,%bl
  8010cb:	77 14                	ja     8010e1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8010cd:	0f be c9             	movsbl %cl,%ecx
  8010d0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8010d3:	39 f1                	cmp    %esi,%ecx
  8010d5:	7d 0e                	jge    8010e5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8010d7:	83 c2 01             	add    $0x1,%edx
  8010da:	0f af c6             	imul   %esi,%eax
  8010dd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8010df:	eb c1                	jmp    8010a2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8010e1:	89 c1                	mov    %eax,%ecx
  8010e3:	eb 02                	jmp    8010e7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8010e5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8010e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010eb:	74 05                	je     8010f2 <strtol+0xce>
		*endptr = (char *) s;
  8010ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010f0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8010f2:	89 ca                	mov    %ecx,%edx
  8010f4:	f7 da                	neg    %edx
  8010f6:	85 ff                	test   %edi,%edi
  8010f8:	0f 45 c2             	cmovne %edx,%eax
}
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801109:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80110c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110f:	b8 00 00 00 00       	mov    $0x0,%eax
  801114:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801117:	8b 55 08             	mov    0x8(%ebp),%edx
  80111a:	89 c3                	mov    %eax,%ebx
  80111c:	89 c7                	mov    %eax,%edi
  80111e:	89 c6                	mov    %eax,%esi
  801120:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801122:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801125:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801128:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80112b:	89 ec                	mov    %ebp,%esp
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <sys_cgetc>:

int
sys_cgetc(void)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	83 ec 0c             	sub    $0xc,%esp
  801135:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801138:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80113b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113e:	ba 00 00 00 00       	mov    $0x0,%edx
  801143:	b8 01 00 00 00       	mov    $0x1,%eax
  801148:	89 d1                	mov    %edx,%ecx
  80114a:	89 d3                	mov    %edx,%ebx
  80114c:	89 d7                	mov    %edx,%edi
  80114e:	89 d6                	mov    %edx,%esi
  801150:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801152:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801155:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801158:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80115b:	89 ec                	mov    %ebp,%esp
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	83 ec 38             	sub    $0x38,%esp
  801165:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801168:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80116b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801173:	b8 03 00 00 00       	mov    $0x3,%eax
  801178:	8b 55 08             	mov    0x8(%ebp),%edx
  80117b:	89 cb                	mov    %ecx,%ebx
  80117d:	89 cf                	mov    %ecx,%edi
  80117f:	89 ce                	mov    %ecx,%esi
  801181:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801183:	85 c0                	test   %eax,%eax
  801185:	7e 28                	jle    8011af <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801187:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801192:	00 
  801193:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  80119a:	00 
  80119b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011a2:	00 
  8011a3:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  8011aa:	e8 59 f4 ff ff       	call   800608 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011b8:	89 ec                	mov    %ebp,%esp
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    

008011bc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	83 ec 0c             	sub    $0xc,%esp
  8011c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8011d5:	89 d1                	mov    %edx,%ecx
  8011d7:	89 d3                	mov    %edx,%ebx
  8011d9:	89 d7                	mov    %edx,%edi
  8011db:	89 d6                	mov    %edx,%esi
  8011dd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011df:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011e2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e8:	89 ec                	mov    %ebp,%esp
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <sys_yield>:

void
sys_yield(void)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 0c             	sub    $0xc,%esp
  8011f2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011f5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011f8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801200:	b8 0a 00 00 00       	mov    $0xa,%eax
  801205:	89 d1                	mov    %edx,%ecx
  801207:	89 d3                	mov    %edx,%ebx
  801209:	89 d7                	mov    %edx,%edi
  80120b:	89 d6                	mov    %edx,%esi
  80120d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80120f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801212:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801215:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801218:	89 ec                	mov    %ebp,%esp
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	83 ec 38             	sub    $0x38,%esp
  801222:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801225:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801228:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122b:	be 00 00 00 00       	mov    $0x0,%esi
  801230:	b8 04 00 00 00       	mov    $0x4,%eax
  801235:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80123b:	8b 55 08             	mov    0x8(%ebp),%edx
  80123e:	89 f7                	mov    %esi,%edi
  801240:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801242:	85 c0                	test   %eax,%eax
  801244:	7e 28                	jle    80126e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801246:	89 44 24 10          	mov    %eax,0x10(%esp)
  80124a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801251:	00 
  801252:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  801259:	00 
  80125a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801261:	00 
  801262:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  801269:	e8 9a f3 ff ff       	call   800608 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80126e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801271:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801274:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801277:	89 ec                	mov    %ebp,%esp
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	83 ec 38             	sub    $0x38,%esp
  801281:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801284:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801287:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80128a:	b8 05 00 00 00       	mov    $0x5,%eax
  80128f:	8b 75 18             	mov    0x18(%ebp),%esi
  801292:	8b 7d 14             	mov    0x14(%ebp),%edi
  801295:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801298:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129b:	8b 55 08             	mov    0x8(%ebp),%edx
  80129e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	7e 28                	jle    8012cc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012af:	00 
  8012b0:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  8012b7:	00 
  8012b8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012bf:	00 
  8012c0:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  8012c7:	e8 3c f3 ff ff       	call   800608 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8012cc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012cf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012d2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012d5:	89 ec                	mov    %ebp,%esp
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    

008012d9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 38             	sub    $0x38,%esp
  8012df:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012e2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012e5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8012f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f8:	89 df                	mov    %ebx,%edi
  8012fa:	89 de                	mov    %ebx,%esi
  8012fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012fe:	85 c0                	test   %eax,%eax
  801300:	7e 28                	jle    80132a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801302:	89 44 24 10          	mov    %eax,0x10(%esp)
  801306:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80130d:	00 
  80130e:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  801315:	00 
  801316:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80131d:	00 
  80131e:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  801325:	e8 de f2 ff ff       	call   800608 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80132a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80132d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801330:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801333:	89 ec                	mov    %ebp,%esp
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	83 ec 38             	sub    $0x38,%esp
  80133d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801340:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801343:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801346:	bb 00 00 00 00       	mov    $0x0,%ebx
  80134b:	b8 08 00 00 00       	mov    $0x8,%eax
  801350:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801353:	8b 55 08             	mov    0x8(%ebp),%edx
  801356:	89 df                	mov    %ebx,%edi
  801358:	89 de                	mov    %ebx,%esi
  80135a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80135c:	85 c0                	test   %eax,%eax
  80135e:	7e 28                	jle    801388 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801360:	89 44 24 10          	mov    %eax,0x10(%esp)
  801364:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80136b:	00 
  80136c:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  801373:	00 
  801374:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80137b:	00 
  80137c:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  801383:	e8 80 f2 ff ff       	call   800608 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801388:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80138b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80138e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801391:	89 ec                	mov    %ebp,%esp
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	83 ec 38             	sub    $0x38,%esp
  80139b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80139e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a9:	b8 09 00 00 00       	mov    $0x9,%eax
  8013ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b4:	89 df                	mov    %ebx,%edi
  8013b6:	89 de                	mov    %ebx,%esi
  8013b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	7e 28                	jle    8013e6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013c2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013c9:	00 
  8013ca:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  8013d1:	00 
  8013d2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013d9:	00 
  8013da:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  8013e1:	e8 22 f2 ff ff       	call   800608 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8013e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013e9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013ef:	89 ec                	mov    %ebp,%esp
  8013f1:	5d                   	pop    %ebp
  8013f2:	c3                   	ret    

008013f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	83 ec 0c             	sub    $0xc,%esp
  8013f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801402:	be 00 00 00 00       	mov    $0x0,%esi
  801407:	b8 0b 00 00 00       	mov    $0xb,%eax
  80140c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80140f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801412:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801415:	8b 55 08             	mov    0x8(%ebp),%edx
  801418:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80141a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80141d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801420:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801423:	89 ec                	mov    %ebp,%esp
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 38             	sub    $0x38,%esp
  80142d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801430:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801433:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801436:	b9 00 00 00 00       	mov    $0x0,%ecx
  80143b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801440:	8b 55 08             	mov    0x8(%ebp),%edx
  801443:	89 cb                	mov    %ecx,%ebx
  801445:	89 cf                	mov    %ecx,%edi
  801447:	89 ce                	mov    %ecx,%esi
  801449:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80144b:	85 c0                	test   %eax,%eax
  80144d:	7e 28                	jle    801477 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80144f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801453:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80145a:	00 
  80145b:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  801462:	00 
  801463:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80146a:	00 
  80146b:	c7 04 24 81 1b 80 00 	movl   $0x801b81,(%esp)
  801472:	e8 91 f1 ff ff       	call   800608 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801477:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80147a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80147d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801480:	89 ec                	mov    %ebp,%esp
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80148a:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801491:	75 50                	jne    8014e3 <set_pgfault_handler+0x5f>
		// First time through!
		// LAB 4: Your code here.
		int error = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P);
  801493:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80149a:	00 
  80149b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014a2:	ee 
  8014a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014aa:	e8 6d fd ff ff       	call   80121c <sys_page_alloc>
        if (error) {
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	74 1c                	je     8014cf <set_pgfault_handler+0x4b>
            panic("No physical memory available!");
  8014b3:	c7 44 24 08 8f 1b 80 	movl   $0x801b8f,0x8(%esp)
  8014ba:	00 
  8014bb:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8014c2:	00 
  8014c3:	c7 04 24 ad 1b 80 00 	movl   $0x801bad,(%esp)
  8014ca:	e8 39 f1 ff ff       	call   800608 <_panic>
        }

		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8014cf:	c7 44 24 04 f0 14 80 	movl   $0x8014f0,0x4(%esp)
  8014d6:	00 
  8014d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014de:	e8 b2 fe ff ff       	call   801395 <sys_env_set_pgfault_upcall>
		
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    
  8014ed:	00 00                	add    %al,(%eax)
	...

008014f0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014f0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014f1:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  8014f6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014f8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	

	movl %esp, %eax 		// temporarily save exception stack esp
  8014fb:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 	// return addr (eip) -> ebx 
  8014fd:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 	// now trap-time stack
  801501:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 				// push eip onto trap-time stack 
  801505:	53                   	push   %ebx
	movl %esp, 48(%eax) 	// Updating the trap-time stack esp, since a new val has been pushed
  801506:	89 60 30             	mov    %esp,0x30(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	movl %eax, %esp 	/* now exception stack */
  801509:	89 c4                	mov    %eax,%esp
	addl $4, %esp 		/* skip utf_fault_va */
  80150b:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 		/* skip utf_err */
  80150e:	83 c4 04             	add    $0x4,%esp
	popal 				/* restore from utf_regs  */
  801511:	61                   	popa   
	addl $4, %esp 		/* skip utf_eip (already on trap-time stack) */
  801512:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	popfl /* restore from utf_eflags */
  801515:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp /* restore from utf_esp - top of stack (bottom-most val) will be the eip to go to */
  801516:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	
	ret
  801517:	c3                   	ret    
	...

00801520 <__udivdi3>:
  801520:	83 ec 1c             	sub    $0x1c,%esp
  801523:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801527:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80152b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80152f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801533:	89 74 24 10          	mov    %esi,0x10(%esp)
  801537:	8b 74 24 24          	mov    0x24(%esp),%esi
  80153b:	85 ff                	test   %edi,%edi
  80153d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801541:	89 44 24 08          	mov    %eax,0x8(%esp)
  801545:	89 cd                	mov    %ecx,%ebp
  801547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154b:	75 33                	jne    801580 <__udivdi3+0x60>
  80154d:	39 f1                	cmp    %esi,%ecx
  80154f:	77 57                	ja     8015a8 <__udivdi3+0x88>
  801551:	85 c9                	test   %ecx,%ecx
  801553:	75 0b                	jne    801560 <__udivdi3+0x40>
  801555:	b8 01 00 00 00       	mov    $0x1,%eax
  80155a:	31 d2                	xor    %edx,%edx
  80155c:	f7 f1                	div    %ecx
  80155e:	89 c1                	mov    %eax,%ecx
  801560:	89 f0                	mov    %esi,%eax
  801562:	31 d2                	xor    %edx,%edx
  801564:	f7 f1                	div    %ecx
  801566:	89 c6                	mov    %eax,%esi
  801568:	8b 44 24 04          	mov    0x4(%esp),%eax
  80156c:	f7 f1                	div    %ecx
  80156e:	89 f2                	mov    %esi,%edx
  801570:	8b 74 24 10          	mov    0x10(%esp),%esi
  801574:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801578:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80157c:	83 c4 1c             	add    $0x1c,%esp
  80157f:	c3                   	ret    
  801580:	31 d2                	xor    %edx,%edx
  801582:	31 c0                	xor    %eax,%eax
  801584:	39 f7                	cmp    %esi,%edi
  801586:	77 e8                	ja     801570 <__udivdi3+0x50>
  801588:	0f bd cf             	bsr    %edi,%ecx
  80158b:	83 f1 1f             	xor    $0x1f,%ecx
  80158e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801592:	75 2c                	jne    8015c0 <__udivdi3+0xa0>
  801594:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801598:	76 04                	jbe    80159e <__udivdi3+0x7e>
  80159a:	39 f7                	cmp    %esi,%edi
  80159c:	73 d2                	jae    801570 <__udivdi3+0x50>
  80159e:	31 d2                	xor    %edx,%edx
  8015a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a5:	eb c9                	jmp    801570 <__udivdi3+0x50>
  8015a7:	90                   	nop
  8015a8:	89 f2                	mov    %esi,%edx
  8015aa:	f7 f1                	div    %ecx
  8015ac:	31 d2                	xor    %edx,%edx
  8015ae:	8b 74 24 10          	mov    0x10(%esp),%esi
  8015b2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8015b6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8015ba:	83 c4 1c             	add    $0x1c,%esp
  8015bd:	c3                   	ret    
  8015be:	66 90                	xchg   %ax,%ax
  8015c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015c5:	b8 20 00 00 00       	mov    $0x20,%eax
  8015ca:	89 ea                	mov    %ebp,%edx
  8015cc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8015d0:	d3 e7                	shl    %cl,%edi
  8015d2:	89 c1                	mov    %eax,%ecx
  8015d4:	d3 ea                	shr    %cl,%edx
  8015d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015db:	09 fa                	or     %edi,%edx
  8015dd:	89 f7                	mov    %esi,%edi
  8015df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015e3:	89 f2                	mov    %esi,%edx
  8015e5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8015e9:	d3 e5                	shl    %cl,%ebp
  8015eb:	89 c1                	mov    %eax,%ecx
  8015ed:	d3 ef                	shr    %cl,%edi
  8015ef:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015f4:	d3 e2                	shl    %cl,%edx
  8015f6:	89 c1                	mov    %eax,%ecx
  8015f8:	d3 ee                	shr    %cl,%esi
  8015fa:	09 d6                	or     %edx,%esi
  8015fc:	89 fa                	mov    %edi,%edx
  8015fe:	89 f0                	mov    %esi,%eax
  801600:	f7 74 24 0c          	divl   0xc(%esp)
  801604:	89 d7                	mov    %edx,%edi
  801606:	89 c6                	mov    %eax,%esi
  801608:	f7 e5                	mul    %ebp
  80160a:	39 d7                	cmp    %edx,%edi
  80160c:	72 22                	jb     801630 <__udivdi3+0x110>
  80160e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801612:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801617:	d3 e5                	shl    %cl,%ebp
  801619:	39 c5                	cmp    %eax,%ebp
  80161b:	73 04                	jae    801621 <__udivdi3+0x101>
  80161d:	39 d7                	cmp    %edx,%edi
  80161f:	74 0f                	je     801630 <__udivdi3+0x110>
  801621:	89 f0                	mov    %esi,%eax
  801623:	31 d2                	xor    %edx,%edx
  801625:	e9 46 ff ff ff       	jmp    801570 <__udivdi3+0x50>
  80162a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801630:	8d 46 ff             	lea    -0x1(%esi),%eax
  801633:	31 d2                	xor    %edx,%edx
  801635:	8b 74 24 10          	mov    0x10(%esp),%esi
  801639:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80163d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801641:	83 c4 1c             	add    $0x1c,%esp
  801644:	c3                   	ret    
	...

00801650 <__umoddi3>:
  801650:	83 ec 1c             	sub    $0x1c,%esp
  801653:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801657:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80165b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80165f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801663:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801667:	8b 74 24 24          	mov    0x24(%esp),%esi
  80166b:	85 ed                	test   %ebp,%ebp
  80166d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801671:	89 44 24 08          	mov    %eax,0x8(%esp)
  801675:	89 cf                	mov    %ecx,%edi
  801677:	89 04 24             	mov    %eax,(%esp)
  80167a:	89 f2                	mov    %esi,%edx
  80167c:	75 1a                	jne    801698 <__umoddi3+0x48>
  80167e:	39 f1                	cmp    %esi,%ecx
  801680:	76 4e                	jbe    8016d0 <__umoddi3+0x80>
  801682:	f7 f1                	div    %ecx
  801684:	89 d0                	mov    %edx,%eax
  801686:	31 d2                	xor    %edx,%edx
  801688:	8b 74 24 10          	mov    0x10(%esp),%esi
  80168c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801690:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801694:	83 c4 1c             	add    $0x1c,%esp
  801697:	c3                   	ret    
  801698:	39 f5                	cmp    %esi,%ebp
  80169a:	77 54                	ja     8016f0 <__umoddi3+0xa0>
  80169c:	0f bd c5             	bsr    %ebp,%eax
  80169f:	83 f0 1f             	xor    $0x1f,%eax
  8016a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a6:	75 60                	jne    801708 <__umoddi3+0xb8>
  8016a8:	3b 0c 24             	cmp    (%esp),%ecx
  8016ab:	0f 87 07 01 00 00    	ja     8017b8 <__umoddi3+0x168>
  8016b1:	89 f2                	mov    %esi,%edx
  8016b3:	8b 34 24             	mov    (%esp),%esi
  8016b6:	29 ce                	sub    %ecx,%esi
  8016b8:	19 ea                	sbb    %ebp,%edx
  8016ba:	89 34 24             	mov    %esi,(%esp)
  8016bd:	8b 04 24             	mov    (%esp),%eax
  8016c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016cc:	83 c4 1c             	add    $0x1c,%esp
  8016cf:	c3                   	ret    
  8016d0:	85 c9                	test   %ecx,%ecx
  8016d2:	75 0b                	jne    8016df <__umoddi3+0x8f>
  8016d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d9:	31 d2                	xor    %edx,%edx
  8016db:	f7 f1                	div    %ecx
  8016dd:	89 c1                	mov    %eax,%ecx
  8016df:	89 f0                	mov    %esi,%eax
  8016e1:	31 d2                	xor    %edx,%edx
  8016e3:	f7 f1                	div    %ecx
  8016e5:	8b 04 24             	mov    (%esp),%eax
  8016e8:	f7 f1                	div    %ecx
  8016ea:	eb 98                	jmp    801684 <__umoddi3+0x34>
  8016ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016f0:	89 f2                	mov    %esi,%edx
  8016f2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016f6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016fa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016fe:	83 c4 1c             	add    $0x1c,%esp
  801701:	c3                   	ret    
  801702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801708:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80170d:	89 e8                	mov    %ebp,%eax
  80170f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801714:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801718:	89 fa                	mov    %edi,%edx
  80171a:	d3 e0                	shl    %cl,%eax
  80171c:	89 e9                	mov    %ebp,%ecx
  80171e:	d3 ea                	shr    %cl,%edx
  801720:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801725:	09 c2                	or     %eax,%edx
  801727:	8b 44 24 08          	mov    0x8(%esp),%eax
  80172b:	89 14 24             	mov    %edx,(%esp)
  80172e:	89 f2                	mov    %esi,%edx
  801730:	d3 e7                	shl    %cl,%edi
  801732:	89 e9                	mov    %ebp,%ecx
  801734:	d3 ea                	shr    %cl,%edx
  801736:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80173b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80173f:	d3 e6                	shl    %cl,%esi
  801741:	89 e9                	mov    %ebp,%ecx
  801743:	d3 e8                	shr    %cl,%eax
  801745:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80174a:	09 f0                	or     %esi,%eax
  80174c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801750:	f7 34 24             	divl   (%esp)
  801753:	d3 e6                	shl    %cl,%esi
  801755:	89 74 24 08          	mov    %esi,0x8(%esp)
  801759:	89 d6                	mov    %edx,%esi
  80175b:	f7 e7                	mul    %edi
  80175d:	39 d6                	cmp    %edx,%esi
  80175f:	89 c1                	mov    %eax,%ecx
  801761:	89 d7                	mov    %edx,%edi
  801763:	72 3f                	jb     8017a4 <__umoddi3+0x154>
  801765:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801769:	72 35                	jb     8017a0 <__umoddi3+0x150>
  80176b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80176f:	29 c8                	sub    %ecx,%eax
  801771:	19 fe                	sbb    %edi,%esi
  801773:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801778:	89 f2                	mov    %esi,%edx
  80177a:	d3 e8                	shr    %cl,%eax
  80177c:	89 e9                	mov    %ebp,%ecx
  80177e:	d3 e2                	shl    %cl,%edx
  801780:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801785:	09 d0                	or     %edx,%eax
  801787:	89 f2                	mov    %esi,%edx
  801789:	d3 ea                	shr    %cl,%edx
  80178b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80178f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801793:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801797:	83 c4 1c             	add    $0x1c,%esp
  80179a:	c3                   	ret    
  80179b:	90                   	nop
  80179c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017a0:	39 d6                	cmp    %edx,%esi
  8017a2:	75 c7                	jne    80176b <__umoddi3+0x11b>
  8017a4:	89 d7                	mov    %edx,%edi
  8017a6:	89 c1                	mov    %eax,%ecx
  8017a8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8017ac:	1b 3c 24             	sbb    (%esp),%edi
  8017af:	eb ba                	jmp    80176b <__umoddi3+0x11b>
  8017b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8017b8:	39 f5                	cmp    %esi,%ebp
  8017ba:	0f 82 f1 fe ff ff    	jb     8016b1 <__umoddi3+0x61>
  8017c0:	e9 f8 fe ff ff       	jmp    8016bd <__umoddi3+0x6d>
