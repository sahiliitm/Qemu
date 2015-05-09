
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 f7 00 00 00       	call   800128 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 ff 0c 00 00       	call   800d4c <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 a2 10 00 00       	call   8010fb <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 21                	jmp    800088 <umain+0x48>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 1c                	je     800088 <umain+0x48>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	6b c6 7c             	imul   $0x7c,%esi,%eax
  800075:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  80007a:	8b 40 50             	mov    0x50(%eax),%eax
  80007d:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800082:	85 c0                	test   %eax,%eax
  800084:	75 0f                	jne    800095 <umain+0x55>
  800086:	eb 24                	jmp    8000ac <umain+0x6c>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800088:	e8 ef 0c 00 00       	call   800d7c <sys_yield>
		return;
  80008d:	8d 76 00             	lea    0x0(%esi),%esi
  800090:	e9 8a 00 00 00       	jmp    80011f <umain+0xdf>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800095:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800098:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
		asm volatile("pause");
  80009e:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  8000a0:	8b 42 50             	mov    0x50(%edx),%eax
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	75 f7                	jne    80009e <umain+0x5e>
  8000a7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000ac:	e8 cb 0c 00 00       	call   800d7c <sys_yield>
  8000b1:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000b6:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000bc:	83 c2 01             	add    $0x1,%edx
  8000bf:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000c5:	83 e8 01             	sub    $0x1,%eax
  8000c8:	75 ec                	jne    8000b6 <umain+0x76>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000ca:	83 eb 01             	sub    $0x1,%ebx
  8000cd:	75 dd                	jne    8000ac <umain+0x6c>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000cf:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000d9:	74 25                	je     800100 <umain+0xc0>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000db:	a1 04 20 80 00       	mov    0x802004,%eax
  8000e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e4:	c7 44 24 08 80 16 80 	movl   $0x801680,0x8(%esp)
  8000eb:	00 
  8000ec:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f3:	00 
  8000f4:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  8000fb:	e8 98 00 00 00       	call   800198 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  800100:	a1 08 20 80 00       	mov    0x802008,%eax
  800105:	8b 50 5c             	mov    0x5c(%eax),%edx
  800108:	8b 40 48             	mov    0x48(%eax),%eax
  80010b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80010f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800113:	c7 04 24 bb 16 80 00 	movl   $0x8016bb,(%esp)
  80011a:	e8 74 01 00 00       	call   800293 <cprintf>

}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    
	...

00800128 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 18             	sub    $0x18,%esp
  80012e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800131:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800134:	8b 75 08             	mov    0x8(%ebp),%esi
  800137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80013a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800141:	00 00 00 
	envid_t envid = sys_getenvid();
  800144:	e8 03 0c 00 00       	call   800d4c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  800149:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800151:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800156:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015b:	85 f6                	test   %esi,%esi
  80015d:	7e 07                	jle    800166 <libmain+0x3e>
		binaryname = argv[0];
  80015f:	8b 03                	mov    (%ebx),%eax
  800161:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800166:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80016a:	89 34 24             	mov    %esi,(%esp)
  80016d:	e8 ce fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800172:	e8 0d 00 00 00       	call   800184 <exit>
}
  800177:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80017a:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80017d:	89 ec                	mov    %ebp,%esp
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    
  800181:	00 00                	add    %al,(%eax)
	...

00800184 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80018a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800191:	e8 59 0b 00 00       	call   800cef <sys_env_destroy>
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	56                   	push   %esi
  80019c:	53                   	push   %ebx
  80019d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001a9:	e8 9e 0b 00 00       	call   800d4c <sys_getenvid>
  8001ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c4:	c7 04 24 e4 16 80 00 	movl   $0x8016e4,(%esp)
  8001cb:	e8 c3 00 00 00       	call   800293 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d7:	89 04 24             	mov    %eax,(%esp)
  8001da:	e8 53 00 00 00       	call   800232 <vcprintf>
	cprintf("\n");
  8001df:	c7 04 24 d7 16 80 00 	movl   $0x8016d7,(%esp)
  8001e6:	e8 a8 00 00 00       	call   800293 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001eb:	cc                   	int3   
  8001ec:	eb fd                	jmp    8001eb <_panic+0x53>
	...

008001f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 14             	sub    $0x14,%esp
  8001f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fa:	8b 03                	mov    (%ebx),%eax
  8001fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800203:	83 c0 01             	add    $0x1,%eax
  800206:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800208:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020d:	75 19                	jne    800228 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80020f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800216:	00 
  800217:	8d 43 08             	lea    0x8(%ebx),%eax
  80021a:	89 04 24             	mov    %eax,(%esp)
  80021d:	e8 6e 0a 00 00       	call   800c90 <sys_cputs>
		b->idx = 0;
  800222:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800228:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022c:	83 c4 14             	add    $0x14,%esp
  80022f:	5b                   	pop    %ebx
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80023b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800242:	00 00 00 
	b.cnt = 0;
  800245:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800252:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800256:	8b 45 08             	mov    0x8(%ebp),%eax
  800259:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800263:	89 44 24 04          	mov    %eax,0x4(%esp)
  800267:	c7 04 24 f0 01 80 00 	movl   $0x8001f0,(%esp)
  80026e:	e8 d1 01 00 00       	call   800444 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800273:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 05 0a 00 00       	call   800c90 <sys_cputs>

	return b.cnt;
}
  80028b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800299:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	e8 87 ff ff ff       	call   800232 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    
  8002ad:	00 00                	add    %al,(%eax)
	...

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 3c             	sub    $0x3c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d7                	mov    %edx,%edi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002cd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002d8:	72 11                	jb     8002eb <printnum+0x3b>
  8002da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002dd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002e0:	76 09                	jbe    8002eb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e2:	83 eb 01             	sub    $0x1,%ebx
  8002e5:	85 db                	test   %ebx,%ebx
  8002e7:	7f 51                	jg     80033a <printnum+0x8a>
  8002e9:	eb 5e                	jmp    800349 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002eb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002ef:	83 eb 01             	sub    $0x1,%ebx
  8002f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800301:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800305:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030c:	00 
  80030d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031a:	e8 a1 10 00 00       	call   8013c0 <__udivdi3>
  80031f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800323:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032e:	89 fa                	mov    %edi,%edx
  800330:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800333:	e8 78 ff ff ff       	call   8002b0 <printnum>
  800338:	eb 0f                	jmp    800349 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80033a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033e:	89 34 24             	mov    %esi,(%esp)
  800341:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800344:	83 eb 01             	sub    $0x1,%ebx
  800347:	75 f1                	jne    80033a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800349:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800351:	8b 45 10             	mov    0x10(%ebp),%eax
  800354:	89 44 24 08          	mov    %eax,0x8(%esp)
  800358:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035f:	00 
  800360:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036d:	e8 7e 11 00 00       	call   8014f0 <__umoddi3>
  800372:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800376:	0f be 80 07 17 80 00 	movsbl 0x801707(%eax),%eax
  80037d:	89 04 24             	mov    %eax,(%esp)
  800380:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800383:	83 c4 3c             	add    $0x3c,%esp
  800386:	5b                   	pop    %ebx
  800387:	5e                   	pop    %esi
  800388:	5f                   	pop    %edi
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038e:	83 fa 01             	cmp    $0x1,%edx
  800391:	7e 0e                	jle    8003a1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800393:	8b 10                	mov    (%eax),%edx
  800395:	8d 4a 08             	lea    0x8(%edx),%ecx
  800398:	89 08                	mov    %ecx,(%eax)
  80039a:	8b 02                	mov    (%edx),%eax
  80039c:	8b 52 04             	mov    0x4(%edx),%edx
  80039f:	eb 22                	jmp    8003c3 <getuint+0x38>
	else if (lflag)
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	74 10                	je     8003b5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a5:	8b 10                	mov    (%eax),%edx
  8003a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003aa:	89 08                	mov    %ecx,(%eax)
  8003ac:	8b 02                	mov    (%edx),%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	eb 0e                	jmp    8003c3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b5:	8b 10                	mov    (%eax),%edx
  8003b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ba:	89 08                	mov    %ecx,(%eax)
  8003bc:	8b 02                	mov    (%edx),%eax
  8003be:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c8:	83 fa 01             	cmp    $0x1,%edx
  8003cb:	7e 0e                	jle    8003db <getint+0x16>
		return va_arg(*ap, long long);
  8003cd:	8b 10                	mov    (%eax),%edx
  8003cf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d2:	89 08                	mov    %ecx,(%eax)
  8003d4:	8b 02                	mov    (%edx),%eax
  8003d6:	8b 52 04             	mov    0x4(%edx),%edx
  8003d9:	eb 22                	jmp    8003fd <getint+0x38>
	else if (lflag)
  8003db:	85 d2                	test   %edx,%edx
  8003dd:	74 10                	je     8003ef <getint+0x2a>
		return va_arg(*ap, long);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	89 c2                	mov    %eax,%edx
  8003ea:	c1 fa 1f             	sar    $0x1f,%edx
  8003ed:	eb 0e                	jmp    8003fd <getint+0x38>
	else
		return va_arg(*ap, int);
  8003ef:	8b 10                	mov    (%eax),%edx
  8003f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f4:	89 08                	mov    %ecx,(%eax)
  8003f6:	8b 02                	mov    (%edx),%eax
  8003f8:	89 c2                	mov    %eax,%edx
  8003fa:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800405:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800409:	8b 10                	mov    (%eax),%edx
  80040b:	3b 50 04             	cmp    0x4(%eax),%edx
  80040e:	73 0a                	jae    80041a <sprintputch+0x1b>
		*b->buf++ = ch;
  800410:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800413:	88 0a                	mov    %cl,(%edx)
  800415:	83 c2 01             	add    $0x1,%edx
  800418:	89 10                	mov    %edx,(%eax)
}
  80041a:	5d                   	pop    %ebp
  80041b:	c3                   	ret    

0080041c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800422:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800425:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800429:	8b 45 10             	mov    0x10(%ebp),%eax
  80042c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800430:	8b 45 0c             	mov    0xc(%ebp),%eax
  800433:	89 44 24 04          	mov    %eax,0x4(%esp)
  800437:	8b 45 08             	mov    0x8(%ebp),%eax
  80043a:	89 04 24             	mov    %eax,(%esp)
  80043d:	e8 02 00 00 00       	call   800444 <vprintfmt>
	va_end(ap);
}
  800442:	c9                   	leave  
  800443:	c3                   	ret    

00800444 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	57                   	push   %edi
  800448:	56                   	push   %esi
  800449:	53                   	push   %ebx
  80044a:	83 ec 4c             	sub    $0x4c,%esp
  80044d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800450:	8b 75 10             	mov    0x10(%ebp),%esi
  800453:	eb 12                	jmp    800467 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800455:	85 c0                	test   %eax,%eax
  800457:	0f 84 77 03 00 00    	je     8007d4 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  80045d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800461:	89 04 24             	mov    %eax,(%esp)
  800464:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800467:	0f b6 06             	movzbl (%esi),%eax
  80046a:	83 c6 01             	add    $0x1,%esi
  80046d:	83 f8 25             	cmp    $0x25,%eax
  800470:	75 e3                	jne    800455 <vprintfmt+0x11>
  800472:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800476:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80047d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800482:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800489:	b9 00 00 00 00       	mov    $0x0,%ecx
  80048e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800491:	eb 2b                	jmp    8004be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800496:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80049a:	eb 22                	jmp    8004be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80049f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004a3:	eb 19                	jmp    8004be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004a8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004af:	eb 0d                	jmp    8004be <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	0f b6 06             	movzbl (%esi),%eax
  8004c1:	0f b6 d0             	movzbl %al,%edx
  8004c4:	8d 7e 01             	lea    0x1(%esi),%edi
  8004c7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004ca:	83 e8 23             	sub    $0x23,%eax
  8004cd:	3c 55                	cmp    $0x55,%al
  8004cf:	0f 87 d9 02 00 00    	ja     8007ae <vprintfmt+0x36a>
  8004d5:	0f b6 c0             	movzbl %al,%eax
  8004d8:	ff 24 85 c0 17 80 00 	jmp    *0x8017c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004df:	83 ea 30             	sub    $0x30,%edx
  8004e2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004e5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004e9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004ef:	83 fa 09             	cmp    $0x9,%edx
  8004f2:	77 4a                	ja     80053e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004fa:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004fd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800501:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800504:	8d 50 d0             	lea    -0x30(%eax),%edx
  800507:	83 fa 09             	cmp    $0x9,%edx
  80050a:	76 eb                	jbe    8004f7 <vprintfmt+0xb3>
  80050c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80050f:	eb 2d                	jmp    80053e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 04             	lea    0x4(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800522:	eb 1a                	jmp    80053e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800527:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052b:	79 91                	jns    8004be <vprintfmt+0x7a>
  80052d:	e9 73 ff ff ff       	jmp    8004a5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800535:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80053c:	eb 80                	jmp    8004be <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80053e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800542:	0f 89 76 ff ff ff    	jns    8004be <vprintfmt+0x7a>
  800548:	e9 64 ff ff ff       	jmp    8004b1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800553:	e9 66 ff ff ff       	jmp    8004be <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800565:	8b 00                	mov    (%eax),%eax
  800567:	89 04 24             	mov    %eax,(%esp)
  80056a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800570:	e9 f2 fe ff ff       	jmp    800467 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 50 04             	lea    0x4(%eax),%edx
  80057b:	89 55 14             	mov    %edx,0x14(%ebp)
  80057e:	8b 00                	mov    (%eax),%eax
  800580:	89 c2                	mov    %eax,%edx
  800582:	c1 fa 1f             	sar    $0x1f,%edx
  800585:	31 d0                	xor    %edx,%eax
  800587:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800589:	83 f8 08             	cmp    $0x8,%eax
  80058c:	7f 0b                	jg     800599 <vprintfmt+0x155>
  80058e:	8b 14 85 20 19 80 00 	mov    0x801920(,%eax,4),%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	75 23                	jne    8005bc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800599:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059d:	c7 44 24 08 1f 17 80 	movl   $0x80171f,0x8(%esp)
  8005a4:	00 
  8005a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ac:	89 3c 24             	mov    %edi,(%esp)
  8005af:	e8 68 fe ff ff       	call   80041c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005b7:	e9 ab fe ff ff       	jmp    800467 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c0:	c7 44 24 08 28 17 80 	movl   $0x801728,0x8(%esp)
  8005c7:	00 
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cf:	89 3c 24             	mov    %edi,(%esp)
  8005d2:	e8 45 fe ff ff       	call   80041c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005da:	e9 88 fe ff ff       	jmp    800467 <vprintfmt+0x23>
  8005df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005f3:	85 f6                	test   %esi,%esi
  8005f5:	ba 18 17 80 00       	mov    $0x801718,%edx
  8005fa:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005fd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800601:	7e 06                	jle    800609 <vprintfmt+0x1c5>
  800603:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800607:	75 10                	jne    800619 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800609:	0f be 06             	movsbl (%esi),%eax
  80060c:	83 c6 01             	add    $0x1,%esi
  80060f:	85 c0                	test   %eax,%eax
  800611:	0f 85 86 00 00 00    	jne    80069d <vprintfmt+0x259>
  800617:	eb 76                	jmp    80068f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061d:	89 34 24             	mov    %esi,(%esp)
  800620:	e8 56 02 00 00       	call   80087b <strnlen>
  800625:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800628:	29 c2                	sub    %eax,%edx
  80062a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80062d:	85 d2                	test   %edx,%edx
  80062f:	7e d8                	jle    800609 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800631:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800635:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800638:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80063b:	89 d6                	mov    %edx,%esi
  80063d:	89 c7                	mov    %eax,%edi
  80063f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800643:	89 3c 24             	mov    %edi,(%esp)
  800646:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800649:	83 ee 01             	sub    $0x1,%esi
  80064c:	75 f1                	jne    80063f <vprintfmt+0x1fb>
  80064e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800651:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800654:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800657:	eb b0                	jmp    800609 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800659:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80065d:	74 18                	je     800677 <vprintfmt+0x233>
  80065f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800662:	83 fa 5e             	cmp    $0x5e,%edx
  800665:	76 10                	jbe    800677 <vprintfmt+0x233>
					putch('?', putdat);
  800667:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800672:	ff 55 08             	call   *0x8(%ebp)
  800675:	eb 0a                	jmp    800681 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800677:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800681:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800685:	0f be 06             	movsbl (%esi),%eax
  800688:	83 c6 01             	add    $0x1,%esi
  80068b:	85 c0                	test   %eax,%eax
  80068d:	75 0e                	jne    80069d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800692:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800696:	7f 11                	jg     8006a9 <vprintfmt+0x265>
  800698:	e9 ca fd ff ff       	jmp    800467 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069d:	85 ff                	test   %edi,%edi
  80069f:	90                   	nop
  8006a0:	78 b7                	js     800659 <vprintfmt+0x215>
  8006a2:	83 ef 01             	sub    $0x1,%edi
  8006a5:	79 b2                	jns    800659 <vprintfmt+0x215>
  8006a7:	eb e6                	jmp    80068f <vprintfmt+0x24b>
  8006a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ba:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bc:	83 ee 01             	sub    $0x1,%esi
  8006bf:	75 ee                	jne    8006af <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006c4:	e9 9e fd ff ff       	jmp    800467 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c9:	89 ca                	mov    %ecx,%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 f2 fc ff ff       	call   8003c5 <getint>
  8006d3:	89 c6                	mov    %eax,%esi
  8006d5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	0f 89 8c 00 00 00    	jns    800770 <vprintfmt+0x32c>
				putch('-', putdat);
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ef:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f2:	f7 de                	neg    %esi
  8006f4:	83 d7 00             	adc    $0x0,%edi
  8006f7:	f7 df                	neg    %edi
			}
			base = 10;
  8006f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fe:	eb 70                	jmp    800770 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800700:	89 ca                	mov    %ecx,%edx
  800702:	8d 45 14             	lea    0x14(%ebp),%eax
  800705:	e8 81 fc ff ff       	call   80038b <getuint>
  80070a:	89 c6                	mov    %eax,%esi
  80070c:	89 d7                	mov    %edx,%edi
			base = 10;
  80070e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800713:	eb 5b                	jmp    800770 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  800715:	89 ca                	mov    %ecx,%edx
  800717:	8d 45 14             	lea    0x14(%ebp),%eax
  80071a:	e8 a6 fc ff ff       	call   8003c5 <getint>
  80071f:	89 c6                	mov    %eax,%esi
  800721:	89 d7                	mov    %edx,%edi
			base = 8;
  800723:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800728:	eb 46                	jmp    800770 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80072a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800735:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800738:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800743:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	8d 50 04             	lea    0x4(%eax),%edx
  80074c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80074f:	8b 30                	mov    (%eax),%esi
  800751:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800756:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80075b:	eb 13                	jmp    800770 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80075d:	89 ca                	mov    %ecx,%edx
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
  800762:	e8 24 fc ff ff       	call   80038b <getuint>
  800767:	89 c6                	mov    %eax,%esi
  800769:	89 d7                	mov    %edx,%edi
			base = 16;
  80076b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800770:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800774:	89 54 24 10          	mov    %edx,0x10(%esp)
  800778:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80077b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80077f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800783:	89 34 24             	mov    %esi,(%esp)
  800786:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078a:	89 da                	mov    %ebx,%edx
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	e8 1c fb ff ff       	call   8002b0 <printnum>
			break;
  800794:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800797:	e9 cb fc ff ff       	jmp    800467 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a0:	89 14 24             	mov    %edx,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007a9:	e9 b9 fc ff ff       	jmp    800467 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007bc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007c0:	0f 84 a1 fc ff ff    	je     800467 <vprintfmt+0x23>
  8007c6:	83 ee 01             	sub    $0x1,%esi
  8007c9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007cd:	75 f7                	jne    8007c6 <vprintfmt+0x382>
  8007cf:	e9 93 fc ff ff       	jmp    800467 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007d4:	83 c4 4c             	add    $0x4c,%esp
  8007d7:	5b                   	pop    %ebx
  8007d8:	5e                   	pop    %esi
  8007d9:	5f                   	pop    %edi
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	83 ec 28             	sub    $0x28,%esp
  8007e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007eb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	74 30                	je     80082d <vsnprintf+0x51>
  8007fd:	85 d2                	test   %edx,%edx
  8007ff:	7e 2c                	jle    80082d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800808:	8b 45 10             	mov    0x10(%ebp),%eax
  80080b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800812:	89 44 24 04          	mov    %eax,0x4(%esp)
  800816:	c7 04 24 ff 03 80 00 	movl   $0x8003ff,(%esp)
  80081d:	e8 22 fc ff ff       	call   800444 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800822:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800825:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800828:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082b:	eb 05                	jmp    800832 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80082d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800841:	8b 45 10             	mov    0x10(%ebp),%eax
  800844:	89 44 24 08          	mov    %eax,0x8(%esp)
  800848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	89 04 24             	mov    %eax,(%esp)
  800855:	e8 82 ff ff ff       	call   8007dc <vsnprintf>
	va_end(ap);

	return rc;
}
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    
  80085c:	00 00                	add    %al,(%eax)
	...

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	80 3a 00             	cmpb   $0x0,(%edx)
  80086e:	74 09                	je     800879 <strlen+0x19>
		n++;
  800870:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800873:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800877:	75 f7                	jne    800870 <strlen+0x10>
		n++;
	return n;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	74 1a                	je     8008a8 <strnlen+0x2d>
  80088e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800891:	74 15                	je     8008a8 <strnlen+0x2d>
  800893:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800898:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089a:	39 ca                	cmp    %ecx,%edx
  80089c:	74 0a                	je     8008a8 <strnlen+0x2d>
  80089e:	83 c2 01             	add    $0x1,%edx
  8008a1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008a6:	75 f0                	jne    800898 <strnlen+0x1d>
		n++;
	return n;
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ba:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008be:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008c1:	83 c2 01             	add    $0x1,%edx
  8008c4:	84 c9                	test   %cl,%cl
  8008c6:	75 f2                	jne    8008ba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d5:	89 1c 24             	mov    %ebx,(%esp)
  8008d8:	e8 83 ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e4:	01 d8                	add    %ebx,%eax
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	e8 bd ff ff ff       	call   8008ab <strcpy>
	return dst;
}
  8008ee:	89 d8                	mov    %ebx,%eax
  8008f0:	83 c4 08             	add    $0x8,%esp
  8008f3:	5b                   	pop    %ebx
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800904:	85 f6                	test   %esi,%esi
  800906:	74 18                	je     800920 <strncpy+0x2a>
  800908:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80090d:	0f b6 1a             	movzbl (%edx),%ebx
  800910:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800913:	80 3a 01             	cmpb   $0x1,(%edx)
  800916:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	39 f1                	cmp    %esi,%ecx
  80091e:	75 ed                	jne    80090d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	57                   	push   %edi
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800930:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800933:	89 f8                	mov    %edi,%eax
  800935:	85 f6                	test   %esi,%esi
  800937:	74 2b                	je     800964 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800939:	83 fe 01             	cmp    $0x1,%esi
  80093c:	74 23                	je     800961 <strlcpy+0x3d>
  80093e:	0f b6 0b             	movzbl (%ebx),%ecx
  800941:	84 c9                	test   %cl,%cl
  800943:	74 1c                	je     800961 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800945:	83 ee 02             	sub    $0x2,%esi
  800948:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094d:	88 08                	mov    %cl,(%eax)
  80094f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800952:	39 f2                	cmp    %esi,%edx
  800954:	74 0b                	je     800961 <strlcpy+0x3d>
  800956:	83 c2 01             	add    $0x1,%edx
  800959:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80095d:	84 c9                	test   %cl,%cl
  80095f:	75 ec                	jne    80094d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800961:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800964:	29 f8                	sub    %edi,%eax
}
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800971:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800974:	0f b6 01             	movzbl (%ecx),%eax
  800977:	84 c0                	test   %al,%al
  800979:	74 16                	je     800991 <strcmp+0x26>
  80097b:	3a 02                	cmp    (%edx),%al
  80097d:	75 12                	jne    800991 <strcmp+0x26>
		p++, q++;
  80097f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800982:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800986:	84 c0                	test   %al,%al
  800988:	74 07                	je     800991 <strcmp+0x26>
  80098a:	83 c1 01             	add    $0x1,%ecx
  80098d:	3a 02                	cmp    (%edx),%al
  80098f:	74 ee                	je     80097f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800991:	0f b6 c0             	movzbl %al,%eax
  800994:	0f b6 12             	movzbl (%edx),%edx
  800997:	29 d0                	sub    %edx,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009a5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ad:	85 d2                	test   %edx,%edx
  8009af:	74 28                	je     8009d9 <strncmp+0x3e>
  8009b1:	0f b6 01             	movzbl (%ecx),%eax
  8009b4:	84 c0                	test   %al,%al
  8009b6:	74 24                	je     8009dc <strncmp+0x41>
  8009b8:	3a 03                	cmp    (%ebx),%al
  8009ba:	75 20                	jne    8009dc <strncmp+0x41>
  8009bc:	83 ea 01             	sub    $0x1,%edx
  8009bf:	74 13                	je     8009d4 <strncmp+0x39>
		n--, p++, q++;
  8009c1:	83 c1 01             	add    $0x1,%ecx
  8009c4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c7:	0f b6 01             	movzbl (%ecx),%eax
  8009ca:	84 c0                	test   %al,%al
  8009cc:	74 0e                	je     8009dc <strncmp+0x41>
  8009ce:	3a 03                	cmp    (%ebx),%al
  8009d0:	74 ea                	je     8009bc <strncmp+0x21>
  8009d2:	eb 08                	jmp    8009dc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009dc:	0f b6 01             	movzbl (%ecx),%eax
  8009df:	0f b6 13             	movzbl (%ebx),%edx
  8009e2:	29 d0                	sub    %edx,%eax
  8009e4:	eb f3                	jmp    8009d9 <strncmp+0x3e>

008009e6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f0:	0f b6 10             	movzbl (%eax),%edx
  8009f3:	84 d2                	test   %dl,%dl
  8009f5:	74 1c                	je     800a13 <strchr+0x2d>
		if (*s == c)
  8009f7:	38 ca                	cmp    %cl,%dl
  8009f9:	75 09                	jne    800a04 <strchr+0x1e>
  8009fb:	eb 1b                	jmp    800a18 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009fd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800a00:	38 ca                	cmp    %cl,%dl
  800a02:	74 14                	je     800a18 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a04:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	75 f1                	jne    8009fd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a11:	eb 05                	jmp    800a18 <strchr+0x32>
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a24:	0f b6 10             	movzbl (%eax),%edx
  800a27:	84 d2                	test   %dl,%dl
  800a29:	74 14                	je     800a3f <strfind+0x25>
		if (*s == c)
  800a2b:	38 ca                	cmp    %cl,%dl
  800a2d:	75 06                	jne    800a35 <strfind+0x1b>
  800a2f:	eb 0e                	jmp    800a3f <strfind+0x25>
  800a31:	38 ca                	cmp    %cl,%dl
  800a33:	74 0a                	je     800a3f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	0f b6 10             	movzbl (%eax),%edx
  800a3b:	84 d2                	test   %dl,%dl
  800a3d:	75 f2                	jne    800a31 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	83 ec 0c             	sub    $0xc,%esp
  800a47:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a4a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a4d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a59:	85 c9                	test   %ecx,%ecx
  800a5b:	74 30                	je     800a8d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a5d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a63:	75 25                	jne    800a8a <memset+0x49>
  800a65:	f6 c1 03             	test   $0x3,%cl
  800a68:	75 20                	jne    800a8a <memset+0x49>
		c &= 0xFF;
  800a6a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6d:	89 d3                	mov    %edx,%ebx
  800a6f:	c1 e3 08             	shl    $0x8,%ebx
  800a72:	89 d6                	mov    %edx,%esi
  800a74:	c1 e6 18             	shl    $0x18,%esi
  800a77:	89 d0                	mov    %edx,%eax
  800a79:	c1 e0 10             	shl    $0x10,%eax
  800a7c:	09 f0                	or     %esi,%eax
  800a7e:	09 d0                	or     %edx,%eax
  800a80:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a82:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a85:	fc                   	cld    
  800a86:	f3 ab                	rep stos %eax,%es:(%edi)
  800a88:	eb 03                	jmp    800a8d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8a:	fc                   	cld    
  800a8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8d:	89 f8                	mov    %edi,%eax
  800a8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a98:	89 ec                	mov    %ebp,%esp
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	83 ec 08             	sub    $0x8,%esp
  800aa2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aa5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab1:	39 c6                	cmp    %eax,%esi
  800ab3:	73 36                	jae    800aeb <memmove+0x4f>
  800ab5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab8:	39 d0                	cmp    %edx,%eax
  800aba:	73 2f                	jae    800aeb <memmove+0x4f>
		s += n;
		d += n;
  800abc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abf:	f6 c2 03             	test   $0x3,%dl
  800ac2:	75 1b                	jne    800adf <memmove+0x43>
  800ac4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aca:	75 13                	jne    800adf <memmove+0x43>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 0e                	jne    800adf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad1:	83 ef 04             	sub    $0x4,%edi
  800ad4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ada:	fd                   	std    
  800adb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800add:	eb 09                	jmp    800ae8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800adf:	83 ef 01             	sub    $0x1,%edi
  800ae2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae5:	fd                   	std    
  800ae6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae8:	fc                   	cld    
  800ae9:	eb 20                	jmp    800b0b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aeb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af1:	75 13                	jne    800b06 <memmove+0x6a>
  800af3:	a8 03                	test   $0x3,%al
  800af5:	75 0f                	jne    800b06 <memmove+0x6a>
  800af7:	f6 c1 03             	test   $0x3,%cl
  800afa:	75 0a                	jne    800b06 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800afc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aff:	89 c7                	mov    %eax,%edi
  800b01:	fc                   	cld    
  800b02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b04:	eb 05                	jmp    800b0b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b06:	89 c7                	mov    %eax,%edi
  800b08:	fc                   	cld    
  800b09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b0e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b11:	89 ec                	mov    %ebp,%esp
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	89 04 24             	mov    %eax,(%esp)
  800b2f:	e8 68 ff ff ff       	call   800a9c <memmove>
}
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b42:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4a:	85 ff                	test   %edi,%edi
  800b4c:	74 37                	je     800b85 <memcmp+0x4f>
		if (*s1 != *s2)
  800b4e:	0f b6 03             	movzbl (%ebx),%eax
  800b51:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b54:	83 ef 01             	sub    $0x1,%edi
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b5c:	38 c8                	cmp    %cl,%al
  800b5e:	74 1c                	je     800b7c <memcmp+0x46>
  800b60:	eb 10                	jmp    800b72 <memcmp+0x3c>
  800b62:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b67:	83 c2 01             	add    $0x1,%edx
  800b6a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b6e:	38 c8                	cmp    %cl,%al
  800b70:	74 0a                	je     800b7c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800b72:	0f b6 c0             	movzbl %al,%eax
  800b75:	0f b6 c9             	movzbl %cl,%ecx
  800b78:	29 c8                	sub    %ecx,%eax
  800b7a:	eb 09                	jmp    800b85 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7c:	39 fa                	cmp    %edi,%edx
  800b7e:	75 e2                	jne    800b62 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b90:	89 c2                	mov    %eax,%edx
  800b92:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b95:	39 d0                	cmp    %edx,%eax
  800b97:	73 19                	jae    800bb2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b9d:	38 08                	cmp    %cl,(%eax)
  800b9f:	75 06                	jne    800ba7 <memfind+0x1d>
  800ba1:	eb 0f                	jmp    800bb2 <memfind+0x28>
  800ba3:	38 08                	cmp    %cl,(%eax)
  800ba5:	74 0b                	je     800bb2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba7:	83 c0 01             	add    $0x1,%eax
  800baa:	39 d0                	cmp    %edx,%eax
  800bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bb0:	75 f1                	jne    800ba3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc0:	0f b6 02             	movzbl (%edx),%eax
  800bc3:	3c 20                	cmp    $0x20,%al
  800bc5:	74 04                	je     800bcb <strtol+0x17>
  800bc7:	3c 09                	cmp    $0x9,%al
  800bc9:	75 0e                	jne    800bd9 <strtol+0x25>
		s++;
  800bcb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bce:	0f b6 02             	movzbl (%edx),%eax
  800bd1:	3c 20                	cmp    $0x20,%al
  800bd3:	74 f6                	je     800bcb <strtol+0x17>
  800bd5:	3c 09                	cmp    $0x9,%al
  800bd7:	74 f2                	je     800bcb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd9:	3c 2b                	cmp    $0x2b,%al
  800bdb:	75 0a                	jne    800be7 <strtol+0x33>
		s++;
  800bdd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be0:	bf 00 00 00 00       	mov    $0x0,%edi
  800be5:	eb 10                	jmp    800bf7 <strtol+0x43>
  800be7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bec:	3c 2d                	cmp    $0x2d,%al
  800bee:	75 07                	jne    800bf7 <strtol+0x43>
		s++, neg = 1;
  800bf0:	83 c2 01             	add    $0x1,%edx
  800bf3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf7:	85 db                	test   %ebx,%ebx
  800bf9:	0f 94 c0             	sete   %al
  800bfc:	74 05                	je     800c03 <strtol+0x4f>
  800bfe:	83 fb 10             	cmp    $0x10,%ebx
  800c01:	75 15                	jne    800c18 <strtol+0x64>
  800c03:	80 3a 30             	cmpb   $0x30,(%edx)
  800c06:	75 10                	jne    800c18 <strtol+0x64>
  800c08:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c0c:	75 0a                	jne    800c18 <strtol+0x64>
		s += 2, base = 16;
  800c0e:	83 c2 02             	add    $0x2,%edx
  800c11:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c16:	eb 13                	jmp    800c2b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c18:	84 c0                	test   %al,%al
  800c1a:	74 0f                	je     800c2b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c21:	80 3a 30             	cmpb   $0x30,(%edx)
  800c24:	75 05                	jne    800c2b <strtol+0x77>
		s++, base = 8;
  800c26:	83 c2 01             	add    $0x1,%edx
  800c29:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c30:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c32:	0f b6 0a             	movzbl (%edx),%ecx
  800c35:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c38:	80 fb 09             	cmp    $0x9,%bl
  800c3b:	77 08                	ja     800c45 <strtol+0x91>
			dig = *s - '0';
  800c3d:	0f be c9             	movsbl %cl,%ecx
  800c40:	83 e9 30             	sub    $0x30,%ecx
  800c43:	eb 1e                	jmp    800c63 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c45:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c48:	80 fb 19             	cmp    $0x19,%bl
  800c4b:	77 08                	ja     800c55 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c4d:	0f be c9             	movsbl %cl,%ecx
  800c50:	83 e9 57             	sub    $0x57,%ecx
  800c53:	eb 0e                	jmp    800c63 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c55:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c58:	80 fb 19             	cmp    $0x19,%bl
  800c5b:	77 14                	ja     800c71 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c5d:	0f be c9             	movsbl %cl,%ecx
  800c60:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c63:	39 f1                	cmp    %esi,%ecx
  800c65:	7d 0e                	jge    800c75 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c67:	83 c2 01             	add    $0x1,%edx
  800c6a:	0f af c6             	imul   %esi,%eax
  800c6d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c6f:	eb c1                	jmp    800c32 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c71:	89 c1                	mov    %eax,%ecx
  800c73:	eb 02                	jmp    800c77 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c75:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c7b:	74 05                	je     800c82 <strtol+0xce>
		*endptr = (char *) s;
  800c7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c80:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c82:	89 ca                	mov    %ecx,%edx
  800c84:	f7 da                	neg    %edx
  800c86:	85 ff                	test   %edi,%edi
  800c88:	0f 45 c2             	cmovne %edx,%eax
}
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c99:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	89 c3                	mov    %eax,%ebx
  800cac:	89 c7                	mov    %eax,%edi
  800cae:	89 c6                	mov    %eax,%esi
  800cb0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cb2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cbb:	89 ec                	mov    %ebp,%esp
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_cgetc>:

int
sys_cgetc(void)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ccb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd3:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd8:	89 d1                	mov    %edx,%ecx
  800cda:	89 d3                	mov    %edx,%ebx
  800cdc:	89 d7                	mov    %edx,%edi
  800cde:	89 d6                	mov    %edx,%esi
  800ce0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ce2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ceb:	89 ec                	mov    %ebp,%esp
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	83 ec 38             	sub    $0x38,%esp
  800cf5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d03:	b8 03 00 00 00       	mov    $0x3,%eax
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	89 cb                	mov    %ecx,%ebx
  800d0d:	89 cf                	mov    %ecx,%edi
  800d0f:	89 ce                	mov    %ecx,%esi
  800d11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 28                	jle    800d3f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d22:	00 
  800d23:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d32:	00 
  800d33:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800d3a:	e8 59 f4 ff ff       	call   800198 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d48:	89 ec                	mov    %ebp,%esp
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d58:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d60:	b8 02 00 00 00       	mov    $0x2,%eax
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	89 d3                	mov    %edx,%ebx
  800d69:	89 d7                	mov    %edx,%edi
  800d6b:	89 d6                	mov    %edx,%esi
  800d6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d78:	89 ec                	mov    %ebp,%esp
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_yield>:

void
sys_yield(void)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d88:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d90:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d95:	89 d1                	mov    %edx,%ecx
  800d97:	89 d3                	mov    %edx,%ebx
  800d99:	89 d7                	mov    %edx,%edi
  800d9b:	89 d6                	mov    %edx,%esi
  800d9d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da8:	89 ec                	mov    %ebp,%esp
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 38             	sub    $0x38,%esp
  800db2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	be 00 00 00 00       	mov    $0x0,%esi
  800dc0:	b8 04 00 00 00       	mov    $0x4,%eax
  800dc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	89 f7                	mov    %esi,%edi
  800dd0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	7e 28                	jle    800dfe <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dda:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800de1:	00 
  800de2:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800de9:	00 
  800dea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df1:	00 
  800df2:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800df9:	e8 9a f3 ff ff       	call   800198 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dfe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e01:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e04:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e07:	89 ec                	mov    %ebp,%esp
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	83 ec 38             	sub    $0x38,%esp
  800e11:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e17:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e30:	85 c0                	test   %eax,%eax
  800e32:	7e 28                	jle    800e5c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e38:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e3f:	00 
  800e40:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800e47:	00 
  800e48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4f:	00 
  800e50:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800e57:	e8 3c f3 ff ff       	call   800198 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e5c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e5f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e62:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e65:	89 ec                	mov    %ebp,%esp
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	83 ec 38             	sub    $0x38,%esp
  800e6f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e75:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	89 df                	mov    %ebx,%edi
  800e8a:	89 de                	mov    %ebx,%esi
  800e8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	7e 28                	jle    800eba <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e96:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e9d:	00 
  800e9e:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ead:	00 
  800eae:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800eb5:	e8 de f2 ff ff       	call   800198 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ebd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec3:	89 ec                	mov    %ebp,%esp
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 38             	sub    $0x38,%esp
  800ecd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 df                	mov    %ebx,%edi
  800ee8:	89 de                	mov    %ebx,%esi
  800eea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	7e 28                	jle    800f18 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800efb:	00 
  800efc:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800f03:	00 
  800f04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0b:	00 
  800f0c:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800f13:	e8 80 f2 ff ff       	call   800198 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f18:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f1b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f1e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f21:	89 ec                	mov    %ebp,%esp
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 38             	sub    $0x38,%esp
  800f2b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f2e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f31:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f39:	b8 09 00 00 00       	mov    $0x9,%eax
  800f3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f41:	8b 55 08             	mov    0x8(%ebp),%edx
  800f44:	89 df                	mov    %ebx,%edi
  800f46:	89 de                	mov    %ebx,%esi
  800f48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	7e 28                	jle    800f76 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f52:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f59:	00 
  800f5a:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800f61:	00 
  800f62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f69:	00 
  800f6a:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800f71:	e8 22 f2 ff ff       	call   800198 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f76:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f79:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7f:	89 ec                	mov    %ebp,%esp
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 0c             	sub    $0xc,%esp
  800f89:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f8f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f92:	be 00 00 00 00       	mov    $0x0,%esi
  800f97:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800faa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb3:	89 ec                	mov    %ebp,%esp
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 38             	sub    $0x38,%esp
  800fbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd3:	89 cb                	mov    %ecx,%ebx
  800fd5:	89 cf                	mov    %ecx,%edi
  800fd7:	89 ce                	mov    %ecx,%esi
  800fd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	7e 28                	jle    801007 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fea:	00 
  800feb:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800ff2:	00 
  800ff3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffa:	00 
  800ffb:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  801002:	e8 91 f1 ff ff       	call   800198 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801007:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80100a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80100d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801010:	89 ec                	mov    %ebp,%esp
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	53                   	push   %ebx
  801018:	83 ec 24             	sub    $0x24,%esp
  80101b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80101e:	8b 18                	mov    (%eax),%ebx
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

		/// check if access is write and to a copy-on-write page.
    pte_t pte = uvpt[PGNUM(addr)];
  801020:	89 da                	mov    %ebx,%edx
  801022:	c1 ea 0c             	shr    $0xc,%edx
  801025:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  80102c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801030:	74 05                	je     801037 <pgfault+0x23>
  801032:	f6 c6 08             	test   $0x8,%dh
  801035:	75 1c                	jne    801053 <pgfault+0x3f>
        panic("pgfault: fault access not to a write or a copy-on-write page");
  801037:	c7 44 24 08 70 19 80 	movl   $0x801970,0x8(%esp)
  80103e:	00 
  80103f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801046:	00 
  801047:	c7 04 24 d0 19 80 00 	movl   $0x8019d0,(%esp)
  80104e:	e8 45 f1 ff ff       	call   800198 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
    if (sys_page_alloc(0, PFTEMP, PTE_W | PTE_U | PTE_P)) {
  801053:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80105a:	00 
  80105b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801062:	00 
  801063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80106a:	e8 3d fd ff ff       	call   800dac <sys_page_alloc>
  80106f:	85 c0                	test   %eax,%eax
  801071:	74 1c                	je     80108f <pgfault+0x7b>
        panic("pgfault: no phys mem");
  801073:	c7 44 24 08 db 19 80 	movl   $0x8019db,0x8(%esp)
  80107a:	00 
  80107b:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801082:	00 
  801083:	c7 04 24 d0 19 80 00 	movl   $0x8019d0,(%esp)
  80108a:	e8 09 f1 ff ff       	call   800198 <_panic>
    }

    // copy data to the new page from the source page.
    void *fltpg_addr = (void *)ROUNDDOWN(addr, PGSIZE);
  80108f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, fltpg_addr, PGSIZE);
  801095:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80109c:	00 
  80109d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010a1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010a8:	e8 ef f9 ff ff       	call   800a9c <memmove>

    // change mapping for the faulting page.
    if (sys_page_map(0, PFTEMP, 0, fltpg_addr, PTE_W|PTE_U|PTE_P)) {
  8010ad:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010b4:	00 
  8010b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010c0:	00 
  8010c1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010c8:	00 
  8010c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d0:	e8 36 fd ff ff       	call   800e0b <sys_page_map>
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	74 1c                	je     8010f5 <pgfault+0xe1>
        panic("pgfault: map error");
  8010d9:	c7 44 24 08 f0 19 80 	movl   $0x8019f0,0x8(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  8010e8:	00 
  8010e9:	c7 04 24 d0 19 80 00 	movl   $0x8019d0,(%esp)
  8010f0:	e8 a3 f0 ff ff       	call   800198 <_panic>
    }
	// panic("pgfault not implemented");
}
  8010f5:	83 c4 24             	add    $0x24,%esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	// Step 1: install user mode pgfault handler.
    set_pgfault_handler(pgfault);
  801104:	c7 04 24 14 10 80 00 	movl   $0x801014,(%esp)
  80110b:	e8 14 02 00 00       	call   801324 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801110:	ba 07 00 00 00       	mov    $0x7,%edx
  801115:	89 d0                	mov    %edx,%eax
  801117:	cd 30                	int    $0x30
  801119:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80111c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // Step 2: create child environment.
    envid_t envid = sys_exofork();
    if (envid < 0) {
  80111f:	85 c0                	test   %eax,%eax
  801121:	79 1c                	jns    80113f <fork+0x44>
        panic("fork: cannot create child env");
  801123:	c7 44 24 08 03 1a 80 	movl   $0x801a03,0x8(%esp)
  80112a:	00 
  80112b:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801132:	00 
  801133:	c7 04 24 d0 19 80 00 	movl   $0x8019d0,(%esp)
  80113a:	e8 59 f0 ff ff       	call   800198 <_panic>
    }
    else if (envid == 0) {
  80113f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801146:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80114a:	75 1c                	jne    801168 <fork+0x6d>
        // child environment.
        thisenv = &envs[ENVX(sys_getenvid())];
  80114c:	e8 fb fb ff ff       	call   800d4c <sys_getenvid>
  801151:	25 ff 03 00 00       	and    $0x3ff,%eax
  801156:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801159:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80115e:	a3 08 20 80 00       	mov    %eax,0x802008
        return 0;
  801163:	e9 8d 01 00 00       	jmp    8012f5 <fork+0x1fa>

    // Step 3: duplicate pages.
    int ipd;
    for (ipd = 0; ipd < PDX(UTOP); ipd++) {
        // No page table yet.
        if (!(uvpd[ipd] & PTE_P))
  801168:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80116b:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  801172:	a8 01                	test   $0x1,%al
  801174:	0f 84 c5 00 00 00    	je     80123f <fork+0x144>
            continue;

        int ipt;
        for (ipt = 0; ipt < NPTENTRIES; ipt++) {
            unsigned pn = (ipd << 10) | ipt;
  80117a:	89 d7                	mov    %edx,%edi
  80117c:	c1 e7 0a             	shl    $0xa,%edi
  80117f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801184:	89 de                	mov    %ebx,%esi
  801186:	09 fe                	or     %edi,%esi
            if (pn != PGNUM(UXSTACKTOP - PGSIZE)) {
  801188:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  80118e:	0f 84 9c 00 00 00    	je     801230 <fork+0x135>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	pte_t pte = uvpt[pn];
  801194:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
    void *va = (void *)(pn << PGSHIFT);

    // If the page is writable or copy-on-write,
    // the mapping must be copy-on-write ,
    // otherwise the new environment could change this page.
    if ((pte & PTE_W) || (pte & PTE_COW)) {
  80119b:	a9 02 08 00 00       	test   $0x802,%eax
  8011a0:	0f 84 8a 00 00 00    	je     801230 <fork+0x135>
{
	int r;

	// LAB 4: Your code here.
	pte_t pte = uvpt[pn];
    void *va = (void *)(pn << PGSHIFT);
  8011a6:	c1 e6 0c             	shl    $0xc,%esi

    // If the page is writable or copy-on-write,
    // the mapping must be copy-on-write ,
    // otherwise the new environment could change this page.
    if ((pte & PTE_W) || (pte & PTE_COW)) {
        if (sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) {
  8011a9:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011b0:	00 
  8011b1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c7:	e8 3f fc ff ff       	call   800e0b <sys_page_map>
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	74 1c                	je     8011ec <fork+0xf1>
            panic("duppage: map cow error");
  8011d0:	c7 44 24 08 21 1a 80 	movl   $0x801a21,0x8(%esp)
  8011d7:	00 
  8011d8:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8011df:	00 
  8011e0:	c7 04 24 d0 19 80 00 	movl   $0x8019d0,(%esp)
  8011e7:	e8 ac ef ff ff       	call   800198 <_panic>
        }

        // Change permission of the page in this environment to copy-on-write.
        // Otherwise the new environment would see the change in this environment.
        if (sys_page_map(0, va, 0, va, PTE_COW|PTE_U| PTE_P)) {
  8011ec:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011f3:	00 
  8011f4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011ff:	00 
  801200:	89 74 24 04          	mov    %esi,0x4(%esp)
  801204:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80120b:	e8 fb fb ff ff       	call   800e0b <sys_page_map>
  801210:	85 c0                	test   %eax,%eax
  801212:	74 1c                	je     801230 <fork+0x135>
            panic("duppage: change perm error");
  801214:	c7 44 24 08 38 1a 80 	movl   $0x801a38,0x8(%esp)
  80121b:	00 
  80121c:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801223:	00 
  801224:	c7 04 24 d0 19 80 00 	movl   $0x8019d0,(%esp)
  80122b:	e8 68 ef ff ff       	call   800198 <_panic>
        // No page table yet.
        if (!(uvpd[ipd] & PTE_P))
            continue;

        int ipt;
        for (ipt = 0; ipt < NPTENTRIES; ipt++) {
  801230:	83 c3 01             	add    $0x1,%ebx
  801233:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801239:	0f 85 45 ff ff ff    	jne    801184 <fork+0x89>
        return 0;
    }

    // Step 3: duplicate pages.
    int ipd;
    for (ipd = 0; ipd < PDX(UTOP); ipd++) {
  80123f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  801243:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
  80124a:	0f 85 18 ff ff ff    	jne    801168 <fork+0x6d>
            }
        }
    }

    // allocate a new page for child to hold the exception stack.
    if (sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) {
  801250:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801257:	00 
  801258:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80125f:	ee 
  801260:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801263:	89 04 24             	mov    %eax,(%esp)
  801266:	e8 41 fb ff ff       	call   800dac <sys_page_alloc>
  80126b:	85 c0                	test   %eax,%eax
  80126d:	74 1c                	je     80128b <fork+0x190>
        panic("fork: no phys mem for xstk");
  80126f:	c7 44 24 08 53 1a 80 	movl   $0x801a53,0x8(%esp)
  801276:	00 
  801277:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  80127e:	00 
  80127f:	c7 04 24 d0 19 80 00 	movl   $0x8019d0,(%esp)
  801286:	e8 0d ef ff ff       	call   800198 <_panic>
    }

    // Step 4: set user page fault entry for child.
    if (sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) {
  80128b:	a1 08 20 80 00       	mov    0x802008,%eax
  801290:	8b 40 64             	mov    0x64(%eax),%eax
  801293:	89 44 24 04          	mov    %eax,0x4(%esp)
  801297:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80129a:	89 04 24             	mov    %eax,(%esp)
  80129d:	e8 83 fc ff ff       	call   800f25 <sys_env_set_pgfault_upcall>
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	74 1c                	je     8012c2 <fork+0x1c7>
        panic("fork: cannot set pgfault upcall");
  8012a6:	c7 44 24 08 b0 19 80 	movl   $0x8019b0,0x8(%esp)
  8012ad:	00 
  8012ae:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8012b5:	00 
  8012b6:	c7 04 24 d0 19 80 00 	movl   $0x8019d0,(%esp)
  8012bd:	e8 d6 ee ff ff       	call   800198 <_panic>
    }

    // Step 5: set child status to ENV_RUNNABLE.
    if (sys_env_set_status(envid, ENV_RUNNABLE)) {
  8012c2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012c9:	00 
  8012ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012cd:	89 04 24             	mov    %eax,(%esp)
  8012d0:	e8 f2 fb ff ff       	call   800ec7 <sys_env_set_status>
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	74 1c                	je     8012f5 <fork+0x1fa>
        panic("fork: cannot set env status");
  8012d9:	c7 44 24 08 6e 1a 80 	movl   $0x801a6e,0x8(%esp)
  8012e0:	00 
  8012e1:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  8012e8:	00 
  8012e9:	c7 04 24 d0 19 80 00 	movl   $0x8019d0,(%esp)
  8012f0:	e8 a3 ee ff ff       	call   800198 <_panic>
    }

    return envid;

}
  8012f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012f8:	83 c4 3c             	add    $0x3c,%esp
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5f                   	pop    %edi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <sfork>:

// Challenge!
int
sfork(void)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801306:	c7 44 24 08 8a 1a 80 	movl   $0x801a8a,0x8(%esp)
  80130d:	00 
  80130e:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  801315:	00 
  801316:	c7 04 24 d0 19 80 00 	movl   $0x8019d0,(%esp)
  80131d:	e8 76 ee ff ff       	call   800198 <_panic>
	...

00801324 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80132a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801331:	75 50                	jne    801383 <set_pgfault_handler+0x5f>
		// First time through!
		// LAB 4: Your code here.
		int error = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P);
  801333:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80133a:	00 
  80133b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801342:	ee 
  801343:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80134a:	e8 5d fa ff ff       	call   800dac <sys_page_alloc>
        if (error) {
  80134f:	85 c0                	test   %eax,%eax
  801351:	74 1c                	je     80136f <set_pgfault_handler+0x4b>
            panic("No physical memory available!");
  801353:	c7 44 24 08 a0 1a 80 	movl   $0x801aa0,0x8(%esp)
  80135a:	00 
  80135b:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801362:	00 
  801363:	c7 04 24 be 1a 80 00 	movl   $0x801abe,(%esp)
  80136a:	e8 29 ee ff ff       	call   800198 <_panic>
        }

		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80136f:	c7 44 24 04 90 13 80 	movl   $0x801390,0x4(%esp)
  801376:	00 
  801377:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80137e:	e8 a2 fb ff ff       	call   800f25 <sys_env_set_pgfault_upcall>
		
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801383:	8b 45 08             	mov    0x8(%ebp),%eax
  801386:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    
  80138d:	00 00                	add    %al,(%eax)
	...

00801390 <_pgfault_upcall>:
  801390:	54                   	push   %esp
  801391:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801396:	ff d0                	call   *%eax
  801398:	83 c4 04             	add    $0x4,%esp
  80139b:	89 e0                	mov    %esp,%eax
  80139d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  8013a1:	8b 64 24 30          	mov    0x30(%esp),%esp
  8013a5:	53                   	push   %ebx
  8013a6:	89 60 30             	mov    %esp,0x30(%eax)
  8013a9:	89 c4                	mov    %eax,%esp
  8013ab:	83 c4 04             	add    $0x4,%esp
  8013ae:	83 c4 04             	add    $0x4,%esp
  8013b1:	61                   	popa   
  8013b2:	83 c4 04             	add    $0x4,%esp
  8013b5:	9d                   	popf   
  8013b6:	5c                   	pop    %esp
  8013b7:	c3                   	ret    
	...

008013c0 <__udivdi3>:
  8013c0:	83 ec 1c             	sub    $0x1c,%esp
  8013c3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8013c7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8013cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8013cf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8013d3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8013d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8013db:	85 ff                	test   %edi,%edi
  8013dd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8013e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e5:	89 cd                	mov    %ecx,%ebp
  8013e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013eb:	75 33                	jne    801420 <__udivdi3+0x60>
  8013ed:	39 f1                	cmp    %esi,%ecx
  8013ef:	77 57                	ja     801448 <__udivdi3+0x88>
  8013f1:	85 c9                	test   %ecx,%ecx
  8013f3:	75 0b                	jne    801400 <__udivdi3+0x40>
  8013f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8013fa:	31 d2                	xor    %edx,%edx
  8013fc:	f7 f1                	div    %ecx
  8013fe:	89 c1                	mov    %eax,%ecx
  801400:	89 f0                	mov    %esi,%eax
  801402:	31 d2                	xor    %edx,%edx
  801404:	f7 f1                	div    %ecx
  801406:	89 c6                	mov    %eax,%esi
  801408:	8b 44 24 04          	mov    0x4(%esp),%eax
  80140c:	f7 f1                	div    %ecx
  80140e:	89 f2                	mov    %esi,%edx
  801410:	8b 74 24 10          	mov    0x10(%esp),%esi
  801414:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801418:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80141c:	83 c4 1c             	add    $0x1c,%esp
  80141f:	c3                   	ret    
  801420:	31 d2                	xor    %edx,%edx
  801422:	31 c0                	xor    %eax,%eax
  801424:	39 f7                	cmp    %esi,%edi
  801426:	77 e8                	ja     801410 <__udivdi3+0x50>
  801428:	0f bd cf             	bsr    %edi,%ecx
  80142b:	83 f1 1f             	xor    $0x1f,%ecx
  80142e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801432:	75 2c                	jne    801460 <__udivdi3+0xa0>
  801434:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801438:	76 04                	jbe    80143e <__udivdi3+0x7e>
  80143a:	39 f7                	cmp    %esi,%edi
  80143c:	73 d2                	jae    801410 <__udivdi3+0x50>
  80143e:	31 d2                	xor    %edx,%edx
  801440:	b8 01 00 00 00       	mov    $0x1,%eax
  801445:	eb c9                	jmp    801410 <__udivdi3+0x50>
  801447:	90                   	nop
  801448:	89 f2                	mov    %esi,%edx
  80144a:	f7 f1                	div    %ecx
  80144c:	31 d2                	xor    %edx,%edx
  80144e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801452:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801456:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80145a:	83 c4 1c             	add    $0x1c,%esp
  80145d:	c3                   	ret    
  80145e:	66 90                	xchg   %ax,%ax
  801460:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801465:	b8 20 00 00 00       	mov    $0x20,%eax
  80146a:	89 ea                	mov    %ebp,%edx
  80146c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801470:	d3 e7                	shl    %cl,%edi
  801472:	89 c1                	mov    %eax,%ecx
  801474:	d3 ea                	shr    %cl,%edx
  801476:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80147b:	09 fa                	or     %edi,%edx
  80147d:	89 f7                	mov    %esi,%edi
  80147f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801483:	89 f2                	mov    %esi,%edx
  801485:	8b 74 24 08          	mov    0x8(%esp),%esi
  801489:	d3 e5                	shl    %cl,%ebp
  80148b:	89 c1                	mov    %eax,%ecx
  80148d:	d3 ef                	shr    %cl,%edi
  80148f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801494:	d3 e2                	shl    %cl,%edx
  801496:	89 c1                	mov    %eax,%ecx
  801498:	d3 ee                	shr    %cl,%esi
  80149a:	09 d6                	or     %edx,%esi
  80149c:	89 fa                	mov    %edi,%edx
  80149e:	89 f0                	mov    %esi,%eax
  8014a0:	f7 74 24 0c          	divl   0xc(%esp)
  8014a4:	89 d7                	mov    %edx,%edi
  8014a6:	89 c6                	mov    %eax,%esi
  8014a8:	f7 e5                	mul    %ebp
  8014aa:	39 d7                	cmp    %edx,%edi
  8014ac:	72 22                	jb     8014d0 <__udivdi3+0x110>
  8014ae:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8014b2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014b7:	d3 e5                	shl    %cl,%ebp
  8014b9:	39 c5                	cmp    %eax,%ebp
  8014bb:	73 04                	jae    8014c1 <__udivdi3+0x101>
  8014bd:	39 d7                	cmp    %edx,%edi
  8014bf:	74 0f                	je     8014d0 <__udivdi3+0x110>
  8014c1:	89 f0                	mov    %esi,%eax
  8014c3:	31 d2                	xor    %edx,%edx
  8014c5:	e9 46 ff ff ff       	jmp    801410 <__udivdi3+0x50>
  8014ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014d0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8014d3:	31 d2                	xor    %edx,%edx
  8014d5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8014d9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8014dd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8014e1:	83 c4 1c             	add    $0x1c,%esp
  8014e4:	c3                   	ret    
	...

008014f0 <__umoddi3>:
  8014f0:	83 ec 1c             	sub    $0x1c,%esp
  8014f3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8014f7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8014fb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8014ff:	89 74 24 10          	mov    %esi,0x10(%esp)
  801503:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801507:	8b 74 24 24          	mov    0x24(%esp),%esi
  80150b:	85 ed                	test   %ebp,%ebp
  80150d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801511:	89 44 24 08          	mov    %eax,0x8(%esp)
  801515:	89 cf                	mov    %ecx,%edi
  801517:	89 04 24             	mov    %eax,(%esp)
  80151a:	89 f2                	mov    %esi,%edx
  80151c:	75 1a                	jne    801538 <__umoddi3+0x48>
  80151e:	39 f1                	cmp    %esi,%ecx
  801520:	76 4e                	jbe    801570 <__umoddi3+0x80>
  801522:	f7 f1                	div    %ecx
  801524:	89 d0                	mov    %edx,%eax
  801526:	31 d2                	xor    %edx,%edx
  801528:	8b 74 24 10          	mov    0x10(%esp),%esi
  80152c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801530:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801534:	83 c4 1c             	add    $0x1c,%esp
  801537:	c3                   	ret    
  801538:	39 f5                	cmp    %esi,%ebp
  80153a:	77 54                	ja     801590 <__umoddi3+0xa0>
  80153c:	0f bd c5             	bsr    %ebp,%eax
  80153f:	83 f0 1f             	xor    $0x1f,%eax
  801542:	89 44 24 04          	mov    %eax,0x4(%esp)
  801546:	75 60                	jne    8015a8 <__umoddi3+0xb8>
  801548:	3b 0c 24             	cmp    (%esp),%ecx
  80154b:	0f 87 07 01 00 00    	ja     801658 <__umoddi3+0x168>
  801551:	89 f2                	mov    %esi,%edx
  801553:	8b 34 24             	mov    (%esp),%esi
  801556:	29 ce                	sub    %ecx,%esi
  801558:	19 ea                	sbb    %ebp,%edx
  80155a:	89 34 24             	mov    %esi,(%esp)
  80155d:	8b 04 24             	mov    (%esp),%eax
  801560:	8b 74 24 10          	mov    0x10(%esp),%esi
  801564:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801568:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80156c:	83 c4 1c             	add    $0x1c,%esp
  80156f:	c3                   	ret    
  801570:	85 c9                	test   %ecx,%ecx
  801572:	75 0b                	jne    80157f <__umoddi3+0x8f>
  801574:	b8 01 00 00 00       	mov    $0x1,%eax
  801579:	31 d2                	xor    %edx,%edx
  80157b:	f7 f1                	div    %ecx
  80157d:	89 c1                	mov    %eax,%ecx
  80157f:	89 f0                	mov    %esi,%eax
  801581:	31 d2                	xor    %edx,%edx
  801583:	f7 f1                	div    %ecx
  801585:	8b 04 24             	mov    (%esp),%eax
  801588:	f7 f1                	div    %ecx
  80158a:	eb 98                	jmp    801524 <__umoddi3+0x34>
  80158c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801590:	89 f2                	mov    %esi,%edx
  801592:	8b 74 24 10          	mov    0x10(%esp),%esi
  801596:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80159a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80159e:	83 c4 1c             	add    $0x1c,%esp
  8015a1:	c3                   	ret    
  8015a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8015a8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015ad:	89 e8                	mov    %ebp,%eax
  8015af:	bd 20 00 00 00       	mov    $0x20,%ebp
  8015b4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8015b8:	89 fa                	mov    %edi,%edx
  8015ba:	d3 e0                	shl    %cl,%eax
  8015bc:	89 e9                	mov    %ebp,%ecx
  8015be:	d3 ea                	shr    %cl,%edx
  8015c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015c5:	09 c2                	or     %eax,%edx
  8015c7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015cb:	89 14 24             	mov    %edx,(%esp)
  8015ce:	89 f2                	mov    %esi,%edx
  8015d0:	d3 e7                	shl    %cl,%edi
  8015d2:	89 e9                	mov    %ebp,%ecx
  8015d4:	d3 ea                	shr    %cl,%edx
  8015d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015df:	d3 e6                	shl    %cl,%esi
  8015e1:	89 e9                	mov    %ebp,%ecx
  8015e3:	d3 e8                	shr    %cl,%eax
  8015e5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015ea:	09 f0                	or     %esi,%eax
  8015ec:	8b 74 24 08          	mov    0x8(%esp),%esi
  8015f0:	f7 34 24             	divl   (%esp)
  8015f3:	d3 e6                	shl    %cl,%esi
  8015f5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015f9:	89 d6                	mov    %edx,%esi
  8015fb:	f7 e7                	mul    %edi
  8015fd:	39 d6                	cmp    %edx,%esi
  8015ff:	89 c1                	mov    %eax,%ecx
  801601:	89 d7                	mov    %edx,%edi
  801603:	72 3f                	jb     801644 <__umoddi3+0x154>
  801605:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801609:	72 35                	jb     801640 <__umoddi3+0x150>
  80160b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80160f:	29 c8                	sub    %ecx,%eax
  801611:	19 fe                	sbb    %edi,%esi
  801613:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801618:	89 f2                	mov    %esi,%edx
  80161a:	d3 e8                	shr    %cl,%eax
  80161c:	89 e9                	mov    %ebp,%ecx
  80161e:	d3 e2                	shl    %cl,%edx
  801620:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801625:	09 d0                	or     %edx,%eax
  801627:	89 f2                	mov    %esi,%edx
  801629:	d3 ea                	shr    %cl,%edx
  80162b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80162f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801633:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801637:	83 c4 1c             	add    $0x1c,%esp
  80163a:	c3                   	ret    
  80163b:	90                   	nop
  80163c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801640:	39 d6                	cmp    %edx,%esi
  801642:	75 c7                	jne    80160b <__umoddi3+0x11b>
  801644:	89 d7                	mov    %edx,%edi
  801646:	89 c1                	mov    %eax,%ecx
  801648:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80164c:	1b 3c 24             	sbb    (%esp),%edi
  80164f:	eb ba                	jmp    80160b <__umoddi3+0x11b>
  801651:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801658:	39 f5                	cmp    %esi,%ebp
  80165a:	0f 82 f1 fe ff ff    	jb     801551 <__umoddi3+0x61>
  801660:	e9 f8 fe ff ff       	jmp    80155d <__umoddi3+0x6d>
