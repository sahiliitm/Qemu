
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 1f 01 00 00       	call   800150 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 fc 12 00 00       	call   801354 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 c0 17 80 00 	movl   $0x8017c0,(%esp)
  800071:	e8 45 02 00 00       	call   8002bb <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 b0 10 00 00       	call   80112b <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 cc 17 80 	movl   $0x8017cc,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 d5 17 80 00 	movl   $0x8017d5,(%esp)
  80009c:	e8 1f 01 00 00       	call   8001c0 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 94 12 00 00       	call   801354 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 d3 12 00 00       	call   8013bc <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 33 10 00 00       	call   80112b <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 cc 17 80 	movl   $0x8017cc,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 d5 17 80 00 	movl   $0x8017d5,(%esp)
  800119:	e8 a2 00 00 00       	call   8001c0 <_panic>
	if (id == 0)
  80011e:	bb 02 00 00 00       	mov    $0x2,%ebx
  800123:	85 c0                	test   %eax,%eax
  800125:	75 05                	jne    80012c <umain+0x41>
		primeproc();
  800127:	e8 08 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 74 12 00 00       	call   8013bc <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	83 c3 01             	add    $0x1,%ebx
  80014b:	eb df                	jmp    80012c <umain+0x41>
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
  800156:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800159:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80015c:	8b 75 08             	mov    0x8(%ebp),%esi
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800162:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800169:	00 00 00 
	envid_t envid = sys_getenvid();
  80016c:	e8 0b 0c 00 00       	call   800d7c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  800171:	25 ff 03 00 00       	and    $0x3ff,%eax
  800176:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800179:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80017e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800183:	85 f6                	test   %esi,%esi
  800185:	7e 07                	jle    80018e <libmain+0x3e>
		binaryname = argv[0];
  800187:	8b 03                	mov    (%ebx),%eax
  800189:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80018e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800192:	89 34 24             	mov    %esi,(%esp)
  800195:	e8 51 ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  80019a:	e8 0d 00 00 00       	call   8001ac <exit>
}
  80019f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001a2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001a5:	89 ec                	mov    %ebp,%esp
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    
  8001a9:	00 00                	add    %al,(%eax)
	...

008001ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b9:	e8 61 0b 00 00       	call   800d1f <sys_env_destroy>
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001cb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001d1:	e8 a6 0b 00 00       	call   800d7c <sys_getenvid>
  8001d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ec:	c7 04 24 f0 17 80 00 	movl   $0x8017f0,(%esp)
  8001f3:	e8 c3 00 00 00       	call   8002bb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	e8 53 00 00 00       	call   80025a <vcprintf>
	cprintf("\n");
  800207:	c7 04 24 13 18 80 00 	movl   $0x801813,(%esp)
  80020e:	e8 a8 00 00 00       	call   8002bb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800213:	cc                   	int3   
  800214:	eb fd                	jmp    800213 <_panic+0x53>
	...

00800218 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	53                   	push   %ebx
  80021c:	83 ec 14             	sub    $0x14,%esp
  80021f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800222:	8b 03                	mov    (%ebx),%eax
  800224:	8b 55 08             	mov    0x8(%ebp),%edx
  800227:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80022b:	83 c0 01             	add    $0x1,%eax
  80022e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800230:	3d ff 00 00 00       	cmp    $0xff,%eax
  800235:	75 19                	jne    800250 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800237:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80023e:	00 
  80023f:	8d 43 08             	lea    0x8(%ebx),%eax
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	e8 76 0a 00 00       	call   800cc0 <sys_cputs>
		b->idx = 0;
  80024a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800250:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800254:	83 c4 14             	add    $0x14,%esp
  800257:	5b                   	pop    %ebx
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    

0080025a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800263:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80026a:	00 00 00 
	b.cnt = 0;
  80026d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800274:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800277:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 44 24 08          	mov    %eax,0x8(%esp)
  800285:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028f:	c7 04 24 18 02 80 00 	movl   $0x800218,(%esp)
  800296:	e8 d9 01 00 00       	call   800474 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80029b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ab:	89 04 24             	mov    %eax,(%esp)
  8002ae:	e8 0d 0a 00 00       	call   800cc0 <sys_cputs>

	return b.cnt;
}
  8002b3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    

008002bb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	e8 87 ff ff ff       	call   80025a <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    
	...

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 3c             	sub    $0x3c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d7                	mov    %edx,%edi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800300:	b8 00 00 00 00       	mov    $0x0,%eax
  800305:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800308:	72 11                	jb     80031b <printnum+0x3b>
  80030a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800310:	76 09                	jbe    80031b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800312:	83 eb 01             	sub    $0x1,%ebx
  800315:	85 db                	test   %ebx,%ebx
  800317:	7f 51                	jg     80036a <printnum+0x8a>
  800319:	eb 5e                	jmp    800379 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80031b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80031f:	83 eb 01             	sub    $0x1,%ebx
  800322:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800326:	8b 45 10             	mov    0x10(%ebp),%eax
  800329:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800331:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800335:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033c:	00 
  80033d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034a:	e8 b1 11 00 00       	call   801500 <__udivdi3>
  80034f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800353:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800357:	89 04 24             	mov    %eax,(%esp)
  80035a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80035e:	89 fa                	mov    %edi,%edx
  800360:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800363:	e8 78 ff ff ff       	call   8002e0 <printnum>
  800368:	eb 0f                	jmp    800379 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036e:	89 34 24             	mov    %esi,(%esp)
  800371:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800374:	83 eb 01             	sub    $0x1,%ebx
  800377:	75 f1                	jne    80036a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800379:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80037d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800381:	8b 45 10             	mov    0x10(%ebp),%eax
  800384:	89 44 24 08          	mov    %eax,0x8(%esp)
  800388:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038f:	00 
  800390:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	e8 8e 12 00 00       	call   801630 <__umoddi3>
  8003a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a6:	0f be 80 15 18 80 00 	movsbl 0x801815(%eax),%eax
  8003ad:	89 04 24             	mov    %eax,(%esp)
  8003b0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003b3:	83 c4 3c             	add    $0x3c,%esp
  8003b6:	5b                   	pop    %ebx
  8003b7:	5e                   	pop    %esi
  8003b8:	5f                   	pop    %edi
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003be:	83 fa 01             	cmp    $0x1,%edx
  8003c1:	7e 0e                	jle    8003d1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003c3:	8b 10                	mov    (%eax),%edx
  8003c5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c8:	89 08                	mov    %ecx,(%eax)
  8003ca:	8b 02                	mov    (%edx),%eax
  8003cc:	8b 52 04             	mov    0x4(%edx),%edx
  8003cf:	eb 22                	jmp    8003f3 <getuint+0x38>
	else if (lflag)
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	74 10                	je     8003e5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d5:	8b 10                	mov    (%eax),%edx
  8003d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003da:	89 08                	mov    %ecx,(%eax)
  8003dc:	8b 02                	mov    (%edx),%eax
  8003de:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e3:	eb 0e                	jmp    8003f3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e5:	8b 10                	mov    (%eax),%edx
  8003e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ea:	89 08                	mov    %ecx,(%eax)
  8003ec:	8b 02                	mov    (%edx),%eax
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f8:	83 fa 01             	cmp    $0x1,%edx
  8003fb:	7e 0e                	jle    80040b <getint+0x16>
		return va_arg(*ap, long long);
  8003fd:	8b 10                	mov    (%eax),%edx
  8003ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 02                	mov    (%edx),%eax
  800406:	8b 52 04             	mov    0x4(%edx),%edx
  800409:	eb 22                	jmp    80042d <getint+0x38>
	else if (lflag)
  80040b:	85 d2                	test   %edx,%edx
  80040d:	74 10                	je     80041f <getint+0x2a>
		return va_arg(*ap, long);
  80040f:	8b 10                	mov    (%eax),%edx
  800411:	8d 4a 04             	lea    0x4(%edx),%ecx
  800414:	89 08                	mov    %ecx,(%eax)
  800416:	8b 02                	mov    (%edx),%eax
  800418:	89 c2                	mov    %eax,%edx
  80041a:	c1 fa 1f             	sar    $0x1f,%edx
  80041d:	eb 0e                	jmp    80042d <getint+0x38>
	else
		return va_arg(*ap, int);
  80041f:	8b 10                	mov    (%eax),%edx
  800421:	8d 4a 04             	lea    0x4(%edx),%ecx
  800424:	89 08                	mov    %ecx,(%eax)
  800426:	8b 02                	mov    (%edx),%eax
  800428:	89 c2                	mov    %eax,%edx
  80042a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800435:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800439:	8b 10                	mov    (%eax),%edx
  80043b:	3b 50 04             	cmp    0x4(%eax),%edx
  80043e:	73 0a                	jae    80044a <sprintputch+0x1b>
		*b->buf++ = ch;
  800440:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800443:	88 0a                	mov    %cl,(%edx)
  800445:	83 c2 01             	add    $0x1,%edx
  800448:	89 10                	mov    %edx,(%eax)
}
  80044a:	5d                   	pop    %ebp
  80044b:	c3                   	ret    

0080044c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800452:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800455:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800459:	8b 45 10             	mov    0x10(%ebp),%eax
  80045c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	89 44 24 04          	mov    %eax,0x4(%esp)
  800467:	8b 45 08             	mov    0x8(%ebp),%eax
  80046a:	89 04 24             	mov    %eax,(%esp)
  80046d:	e8 02 00 00 00       	call   800474 <vprintfmt>
	va_end(ap);
}
  800472:	c9                   	leave  
  800473:	c3                   	ret    

00800474 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800474:	55                   	push   %ebp
  800475:	89 e5                	mov    %esp,%ebp
  800477:	57                   	push   %edi
  800478:	56                   	push   %esi
  800479:	53                   	push   %ebx
  80047a:	83 ec 4c             	sub    $0x4c,%esp
  80047d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800480:	8b 75 10             	mov    0x10(%ebp),%esi
  800483:	eb 12                	jmp    800497 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800485:	85 c0                	test   %eax,%eax
  800487:	0f 84 77 03 00 00    	je     800804 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  80048d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800491:	89 04 24             	mov    %eax,(%esp)
  800494:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800497:	0f b6 06             	movzbl (%esi),%eax
  80049a:	83 c6 01             	add    $0x1,%esi
  80049d:	83 f8 25             	cmp    $0x25,%eax
  8004a0:	75 e3                	jne    800485 <vprintfmt+0x11>
  8004a2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004ad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004b2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004be:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c1:	eb 2b                	jmp    8004ee <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004ca:	eb 22                	jmp    8004ee <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004cf:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004d3:	eb 19                	jmp    8004ee <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004df:	eb 0d                	jmp    8004ee <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	0f b6 06             	movzbl (%esi),%eax
  8004f1:	0f b6 d0             	movzbl %al,%edx
  8004f4:	8d 7e 01             	lea    0x1(%esi),%edi
  8004f7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004fa:	83 e8 23             	sub    $0x23,%eax
  8004fd:	3c 55                	cmp    $0x55,%al
  8004ff:	0f 87 d9 02 00 00    	ja     8007de <vprintfmt+0x36a>
  800505:	0f b6 c0             	movzbl %al,%eax
  800508:	ff 24 85 e0 18 80 00 	jmp    *0x8018e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80050f:	83 ea 30             	sub    $0x30,%edx
  800512:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800515:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800519:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80051f:	83 fa 09             	cmp    $0x9,%edx
  800522:	77 4a                	ja     80056e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800527:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80052a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80052d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800531:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800534:	8d 50 d0             	lea    -0x30(%eax),%edx
  800537:	83 fa 09             	cmp    $0x9,%edx
  80053a:	76 eb                	jbe    800527 <vprintfmt+0xb3>
  80053c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80053f:	eb 2d                	jmp    80056e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 50 04             	lea    0x4(%eax),%edx
  800547:	89 55 14             	mov    %edx,0x14(%ebp)
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800552:	eb 1a                	jmp    80056e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800554:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800557:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055b:	79 91                	jns    8004ee <vprintfmt+0x7a>
  80055d:	e9 73 ff ff ff       	jmp    8004d5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800565:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80056c:	eb 80                	jmp    8004ee <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80056e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800572:	0f 89 76 ff ff ff    	jns    8004ee <vprintfmt+0x7a>
  800578:	e9 64 ff ff ff       	jmp    8004e1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80057d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800580:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800583:	e9 66 ff ff ff       	jmp    8004ee <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 04             	lea    0x4(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800595:	8b 00                	mov    (%eax),%eax
  800597:	89 04 24             	mov    %eax,(%esp)
  80059a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005a0:	e9 f2 fe ff ff       	jmp    800497 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 04             	lea    0x4(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 c2                	mov    %eax,%edx
  8005b2:	c1 fa 1f             	sar    $0x1f,%edx
  8005b5:	31 d0                	xor    %edx,%eax
  8005b7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b9:	83 f8 08             	cmp    $0x8,%eax
  8005bc:	7f 0b                	jg     8005c9 <vprintfmt+0x155>
  8005be:	8b 14 85 40 1a 80 00 	mov    0x801a40(,%eax,4),%edx
  8005c5:	85 d2                	test   %edx,%edx
  8005c7:	75 23                	jne    8005ec <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8005c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cd:	c7 44 24 08 2d 18 80 	movl   $0x80182d,0x8(%esp)
  8005d4:	00 
  8005d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005dc:	89 3c 24             	mov    %edi,(%esp)
  8005df:	e8 68 fe ff ff       	call   80044c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005e7:	e9 ab fe ff ff       	jmp    800497 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005f0:	c7 44 24 08 36 18 80 	movl   $0x801836,0x8(%esp)
  8005f7:	00 
  8005f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ff:	89 3c 24             	mov    %edi,(%esp)
  800602:	e8 45 fe ff ff       	call   80044c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800607:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060a:	e9 88 fe ff ff       	jmp    800497 <vprintfmt+0x23>
  80060f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800612:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800615:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800623:	85 f6                	test   %esi,%esi
  800625:	ba 26 18 80 00       	mov    $0x801826,%edx
  80062a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80062d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800631:	7e 06                	jle    800639 <vprintfmt+0x1c5>
  800633:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800637:	75 10                	jne    800649 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800639:	0f be 06             	movsbl (%esi),%eax
  80063c:	83 c6 01             	add    $0x1,%esi
  80063f:	85 c0                	test   %eax,%eax
  800641:	0f 85 86 00 00 00    	jne    8006cd <vprintfmt+0x259>
  800647:	eb 76                	jmp    8006bf <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800649:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064d:	89 34 24             	mov    %esi,(%esp)
  800650:	e8 56 02 00 00       	call   8008ab <strnlen>
  800655:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800658:	29 c2                	sub    %eax,%edx
  80065a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80065d:	85 d2                	test   %edx,%edx
  80065f:	7e d8                	jle    800639 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800661:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800665:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800668:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80066b:	89 d6                	mov    %edx,%esi
  80066d:	89 c7                	mov    %eax,%edi
  80066f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800673:	89 3c 24             	mov    %edi,(%esp)
  800676:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800679:	83 ee 01             	sub    $0x1,%esi
  80067c:	75 f1                	jne    80066f <vprintfmt+0x1fb>
  80067e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800681:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800684:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800687:	eb b0                	jmp    800639 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800689:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068d:	74 18                	je     8006a7 <vprintfmt+0x233>
  80068f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800692:	83 fa 5e             	cmp    $0x5e,%edx
  800695:	76 10                	jbe    8006a7 <vprintfmt+0x233>
					putch('?', putdat);
  800697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006a2:	ff 55 08             	call   *0x8(%ebp)
  8006a5:	eb 0a                	jmp    8006b1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  8006a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006b5:	0f be 06             	movsbl (%esi),%eax
  8006b8:	83 c6 01             	add    $0x1,%esi
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	75 0e                	jne    8006cd <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006c6:	7f 11                	jg     8006d9 <vprintfmt+0x265>
  8006c8:	e9 ca fd ff ff       	jmp    800497 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006cd:	85 ff                	test   %edi,%edi
  8006cf:	90                   	nop
  8006d0:	78 b7                	js     800689 <vprintfmt+0x215>
  8006d2:	83 ef 01             	sub    $0x1,%edi
  8006d5:	79 b2                	jns    800689 <vprintfmt+0x215>
  8006d7:	eb e6                	jmp    8006bf <vprintfmt+0x24b>
  8006d9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006dc:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ea:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ec:	83 ee 01             	sub    $0x1,%esi
  8006ef:	75 ee                	jne    8006df <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f4:	e9 9e fd ff ff       	jmp    800497 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f9:	89 ca                	mov    %ecx,%edx
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	e8 f2 fc ff ff       	call   8003f5 <getint>
  800703:	89 c6                	mov    %eax,%esi
  800705:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800707:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80070c:	85 d2                	test   %edx,%edx
  80070e:	0f 89 8c 00 00 00    	jns    8007a0 <vprintfmt+0x32c>
				putch('-', putdat);
  800714:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800718:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800722:	f7 de                	neg    %esi
  800724:	83 d7 00             	adc    $0x0,%edi
  800727:	f7 df                	neg    %edi
			}
			base = 10;
  800729:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072e:	eb 70                	jmp    8007a0 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800730:	89 ca                	mov    %ecx,%edx
  800732:	8d 45 14             	lea    0x14(%ebp),%eax
  800735:	e8 81 fc ff ff       	call   8003bb <getuint>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	89 d7                	mov    %edx,%edi
			base = 10;
  80073e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800743:	eb 5b                	jmp    8007a0 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  800745:	89 ca                	mov    %ecx,%edx
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 a6 fc ff ff       	call   8003f5 <getint>
  80074f:	89 c6                	mov    %eax,%esi
  800751:	89 d7                	mov    %edx,%edi
			base = 8;
  800753:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800758:	eb 46                	jmp    8007a0 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80075a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800765:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800768:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800773:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800776:	8b 45 14             	mov    0x14(%ebp),%eax
  800779:	8d 50 04             	lea    0x4(%eax),%edx
  80077c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077f:	8b 30                	mov    (%eax),%esi
  800781:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800786:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80078b:	eb 13                	jmp    8007a0 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078d:	89 ca                	mov    %ecx,%edx
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 24 fc ff ff       	call   8003bb <getuint>
  800797:	89 c6                	mov    %eax,%esi
  800799:	89 d7                	mov    %edx,%edi
			base = 16;
  80079b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007a4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b3:	89 34 24             	mov    %esi,(%esp)
  8007b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ba:	89 da                	mov    %ebx,%edx
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	e8 1c fb ff ff       	call   8002e0 <printnum>
			break;
  8007c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007c7:	e9 cb fc ff ff       	jmp    800497 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d0:	89 14 24             	mov    %edx,(%esp)
  8007d3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d9:	e9 b9 fc ff ff       	jmp    800497 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ec:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007f0:	0f 84 a1 fc ff ff    	je     800497 <vprintfmt+0x23>
  8007f6:	83 ee 01             	sub    $0x1,%esi
  8007f9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007fd:	75 f7                	jne    8007f6 <vprintfmt+0x382>
  8007ff:	e9 93 fc ff ff       	jmp    800497 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800804:	83 c4 4c             	add    $0x4c,%esp
  800807:	5b                   	pop    %ebx
  800808:	5e                   	pop    %esi
  800809:	5f                   	pop    %edi
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	83 ec 28             	sub    $0x28,%esp
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800818:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800822:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800829:	85 c0                	test   %eax,%eax
  80082b:	74 30                	je     80085d <vsnprintf+0x51>
  80082d:	85 d2                	test   %edx,%edx
  80082f:	7e 2c                	jle    80085d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800838:	8b 45 10             	mov    0x10(%ebp),%eax
  80083b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800842:	89 44 24 04          	mov    %eax,0x4(%esp)
  800846:	c7 04 24 2f 04 80 00 	movl   $0x80042f,(%esp)
  80084d:	e8 22 fc ff ff       	call   800474 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800852:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800855:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800858:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085b:	eb 05                	jmp    800862 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800862:	c9                   	leave  
  800863:	c3                   	ret    

00800864 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80086a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800871:	8b 45 10             	mov    0x10(%ebp),%eax
  800874:	89 44 24 08          	mov    %eax,0x8(%esp)
  800878:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	e8 82 ff ff ff       	call   80080c <vsnprintf>
	va_end(ap);

	return rc;
}
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    
  80088c:	00 00                	add    %al,(%eax)
	...

00800890 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	80 3a 00             	cmpb   $0x0,(%edx)
  80089e:	74 09                	je     8008a9 <strlen+0x19>
		n++;
  8008a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a7:	75 f7                	jne    8008a0 <strlen+0x10>
		n++;
	return n;
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ba:	85 c9                	test   %ecx,%ecx
  8008bc:	74 1a                	je     8008d8 <strnlen+0x2d>
  8008be:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008c1:	74 15                	je     8008d8 <strnlen+0x2d>
  8008c3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008c8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ca:	39 ca                	cmp    %ecx,%edx
  8008cc:	74 0a                	je     8008d8 <strnlen+0x2d>
  8008ce:	83 c2 01             	add    $0x1,%edx
  8008d1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008d6:	75 f0                	jne    8008c8 <strnlen+0x1d>
		n++;
	return n;
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ea:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ee:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008f1:	83 c2 01             	add    $0x1,%edx
  8008f4:	84 c9                	test   %cl,%cl
  8008f6:	75 f2                	jne    8008ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800905:	89 1c 24             	mov    %ebx,(%esp)
  800908:	e8 83 ff ff ff       	call   800890 <strlen>
	strcpy(dst + len, src);
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 54 24 04          	mov    %edx,0x4(%esp)
  800914:	01 d8                	add    %ebx,%eax
  800916:	89 04 24             	mov    %eax,(%esp)
  800919:	e8 bd ff ff ff       	call   8008db <strcpy>
	return dst;
}
  80091e:	89 d8                	mov    %ebx,%eax
  800920:	83 c4 08             	add    $0x8,%esp
  800923:	5b                   	pop    %ebx
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800934:	85 f6                	test   %esi,%esi
  800936:	74 18                	je     800950 <strncpy+0x2a>
  800938:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80093d:	0f b6 1a             	movzbl (%edx),%ebx
  800940:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800943:	80 3a 01             	cmpb   $0x1,(%edx)
  800946:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	39 f1                	cmp    %esi,%ecx
  80094e:	75 ed                	jne    80093d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	57                   	push   %edi
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800960:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800963:	89 f8                	mov    %edi,%eax
  800965:	85 f6                	test   %esi,%esi
  800967:	74 2b                	je     800994 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800969:	83 fe 01             	cmp    $0x1,%esi
  80096c:	74 23                	je     800991 <strlcpy+0x3d>
  80096e:	0f b6 0b             	movzbl (%ebx),%ecx
  800971:	84 c9                	test   %cl,%cl
  800973:	74 1c                	je     800991 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800975:	83 ee 02             	sub    $0x2,%esi
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097d:	88 08                	mov    %cl,(%eax)
  80097f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800982:	39 f2                	cmp    %esi,%edx
  800984:	74 0b                	je     800991 <strlcpy+0x3d>
  800986:	83 c2 01             	add    $0x1,%edx
  800989:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80098d:	84 c9                	test   %cl,%cl
  80098f:	75 ec                	jne    80097d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800991:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800994:	29 f8                	sub    %edi,%eax
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5f                   	pop    %edi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a4:	0f b6 01             	movzbl (%ecx),%eax
  8009a7:	84 c0                	test   %al,%al
  8009a9:	74 16                	je     8009c1 <strcmp+0x26>
  8009ab:	3a 02                	cmp    (%edx),%al
  8009ad:	75 12                	jne    8009c1 <strcmp+0x26>
		p++, q++;
  8009af:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8009b6:	84 c0                	test   %al,%al
  8009b8:	74 07                	je     8009c1 <strcmp+0x26>
  8009ba:	83 c1 01             	add    $0x1,%ecx
  8009bd:	3a 02                	cmp    (%edx),%al
  8009bf:	74 ee                	je     8009af <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c1:	0f b6 c0             	movzbl %al,%eax
  8009c4:	0f b6 12             	movzbl (%edx),%edx
  8009c7:	29 d0                	sub    %edx,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009d5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009d8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009dd:	85 d2                	test   %edx,%edx
  8009df:	74 28                	je     800a09 <strncmp+0x3e>
  8009e1:	0f b6 01             	movzbl (%ecx),%eax
  8009e4:	84 c0                	test   %al,%al
  8009e6:	74 24                	je     800a0c <strncmp+0x41>
  8009e8:	3a 03                	cmp    (%ebx),%al
  8009ea:	75 20                	jne    800a0c <strncmp+0x41>
  8009ec:	83 ea 01             	sub    $0x1,%edx
  8009ef:	74 13                	je     800a04 <strncmp+0x39>
		n--, p++, q++;
  8009f1:	83 c1 01             	add    $0x1,%ecx
  8009f4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009f7:	0f b6 01             	movzbl (%ecx),%eax
  8009fa:	84 c0                	test   %al,%al
  8009fc:	74 0e                	je     800a0c <strncmp+0x41>
  8009fe:	3a 03                	cmp    (%ebx),%al
  800a00:	74 ea                	je     8009ec <strncmp+0x21>
  800a02:	eb 08                	jmp    800a0c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a09:	5b                   	pop    %ebx
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0c:	0f b6 01             	movzbl (%ecx),%eax
  800a0f:	0f b6 13             	movzbl (%ebx),%edx
  800a12:	29 d0                	sub    %edx,%eax
  800a14:	eb f3                	jmp    800a09 <strncmp+0x3e>

00800a16 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a20:	0f b6 10             	movzbl (%eax),%edx
  800a23:	84 d2                	test   %dl,%dl
  800a25:	74 1c                	je     800a43 <strchr+0x2d>
		if (*s == c)
  800a27:	38 ca                	cmp    %cl,%dl
  800a29:	75 09                	jne    800a34 <strchr+0x1e>
  800a2b:	eb 1b                	jmp    800a48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a2d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800a30:	38 ca                	cmp    %cl,%dl
  800a32:	74 14                	je     800a48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a34:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	75 f1                	jne    800a2d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	eb 05                	jmp    800a48 <strchr+0x32>
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a54:	0f b6 10             	movzbl (%eax),%edx
  800a57:	84 d2                	test   %dl,%dl
  800a59:	74 14                	je     800a6f <strfind+0x25>
		if (*s == c)
  800a5b:	38 ca                	cmp    %cl,%dl
  800a5d:	75 06                	jne    800a65 <strfind+0x1b>
  800a5f:	eb 0e                	jmp    800a6f <strfind+0x25>
  800a61:	38 ca                	cmp    %cl,%dl
  800a63:	74 0a                	je     800a6f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a65:	83 c0 01             	add    $0x1,%eax
  800a68:	0f b6 10             	movzbl (%eax),%edx
  800a6b:	84 d2                	test   %dl,%dl
  800a6d:	75 f2                	jne    800a61 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	83 ec 0c             	sub    $0xc,%esp
  800a77:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a7a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a7d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a89:	85 c9                	test   %ecx,%ecx
  800a8b:	74 30                	je     800abd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a93:	75 25                	jne    800aba <memset+0x49>
  800a95:	f6 c1 03             	test   $0x3,%cl
  800a98:	75 20                	jne    800aba <memset+0x49>
		c &= 0xFF;
  800a9a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9d:	89 d3                	mov    %edx,%ebx
  800a9f:	c1 e3 08             	shl    $0x8,%ebx
  800aa2:	89 d6                	mov    %edx,%esi
  800aa4:	c1 e6 18             	shl    $0x18,%esi
  800aa7:	89 d0                	mov    %edx,%eax
  800aa9:	c1 e0 10             	shl    $0x10,%eax
  800aac:	09 f0                	or     %esi,%eax
  800aae:	09 d0                	or     %edx,%eax
  800ab0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ab2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ab5:	fc                   	cld    
  800ab6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab8:	eb 03                	jmp    800abd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aba:	fc                   	cld    
  800abb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800abd:	89 f8                	mov    %edi,%eax
  800abf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ac2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ac5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ac8:	89 ec                	mov    %ebp,%esp
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	83 ec 08             	sub    $0x8,%esp
  800ad2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ad5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae1:	39 c6                	cmp    %eax,%esi
  800ae3:	73 36                	jae    800b1b <memmove+0x4f>
  800ae5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae8:	39 d0                	cmp    %edx,%eax
  800aea:	73 2f                	jae    800b1b <memmove+0x4f>
		s += n;
		d += n;
  800aec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aef:	f6 c2 03             	test   $0x3,%dl
  800af2:	75 1b                	jne    800b0f <memmove+0x43>
  800af4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afa:	75 13                	jne    800b0f <memmove+0x43>
  800afc:	f6 c1 03             	test   $0x3,%cl
  800aff:	75 0e                	jne    800b0f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b01:	83 ef 04             	sub    $0x4,%edi
  800b04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b0a:	fd                   	std    
  800b0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0d:	eb 09                	jmp    800b18 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b0f:	83 ef 01             	sub    $0x1,%edi
  800b12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b15:	fd                   	std    
  800b16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b18:	fc                   	cld    
  800b19:	eb 20                	jmp    800b3b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b21:	75 13                	jne    800b36 <memmove+0x6a>
  800b23:	a8 03                	test   $0x3,%al
  800b25:	75 0f                	jne    800b36 <memmove+0x6a>
  800b27:	f6 c1 03             	test   $0x3,%cl
  800b2a:	75 0a                	jne    800b36 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b2c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b2f:	89 c7                	mov    %eax,%edi
  800b31:	fc                   	cld    
  800b32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b34:	eb 05                	jmp    800b3b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b36:	89 c7                	mov    %eax,%edi
  800b38:	fc                   	cld    
  800b39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b41:	89 ec                	mov    %ebp,%esp
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	89 04 24             	mov    %eax,(%esp)
  800b5f:	e8 68 ff ff ff       	call   800acc <memmove>
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b72:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7a:	85 ff                	test   %edi,%edi
  800b7c:	74 37                	je     800bb5 <memcmp+0x4f>
		if (*s1 != *s2)
  800b7e:	0f b6 03             	movzbl (%ebx),%eax
  800b81:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b84:	83 ef 01             	sub    $0x1,%edi
  800b87:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b8c:	38 c8                	cmp    %cl,%al
  800b8e:	74 1c                	je     800bac <memcmp+0x46>
  800b90:	eb 10                	jmp    800ba2 <memcmp+0x3c>
  800b92:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b97:	83 c2 01             	add    $0x1,%edx
  800b9a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b9e:	38 c8                	cmp    %cl,%al
  800ba0:	74 0a                	je     800bac <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800ba2:	0f b6 c0             	movzbl %al,%eax
  800ba5:	0f b6 c9             	movzbl %cl,%ecx
  800ba8:	29 c8                	sub    %ecx,%eax
  800baa:	eb 09                	jmp    800bb5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bac:	39 fa                	cmp    %edi,%edx
  800bae:	75 e2                	jne    800b92 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bc0:	89 c2                	mov    %eax,%edx
  800bc2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc5:	39 d0                	cmp    %edx,%eax
  800bc7:	73 19                	jae    800be2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bcd:	38 08                	cmp    %cl,(%eax)
  800bcf:	75 06                	jne    800bd7 <memfind+0x1d>
  800bd1:	eb 0f                	jmp    800be2 <memfind+0x28>
  800bd3:	38 08                	cmp    %cl,(%eax)
  800bd5:	74 0b                	je     800be2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd7:	83 c0 01             	add    $0x1,%eax
  800bda:	39 d0                	cmp    %edx,%eax
  800bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800be0:	75 f1                	jne    800bd3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf0:	0f b6 02             	movzbl (%edx),%eax
  800bf3:	3c 20                	cmp    $0x20,%al
  800bf5:	74 04                	je     800bfb <strtol+0x17>
  800bf7:	3c 09                	cmp    $0x9,%al
  800bf9:	75 0e                	jne    800c09 <strtol+0x25>
		s++;
  800bfb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfe:	0f b6 02             	movzbl (%edx),%eax
  800c01:	3c 20                	cmp    $0x20,%al
  800c03:	74 f6                	je     800bfb <strtol+0x17>
  800c05:	3c 09                	cmp    $0x9,%al
  800c07:	74 f2                	je     800bfb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c09:	3c 2b                	cmp    $0x2b,%al
  800c0b:	75 0a                	jne    800c17 <strtol+0x33>
		s++;
  800c0d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c10:	bf 00 00 00 00       	mov    $0x0,%edi
  800c15:	eb 10                	jmp    800c27 <strtol+0x43>
  800c17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c1c:	3c 2d                	cmp    $0x2d,%al
  800c1e:	75 07                	jne    800c27 <strtol+0x43>
		s++, neg = 1;
  800c20:	83 c2 01             	add    $0x1,%edx
  800c23:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c27:	85 db                	test   %ebx,%ebx
  800c29:	0f 94 c0             	sete   %al
  800c2c:	74 05                	je     800c33 <strtol+0x4f>
  800c2e:	83 fb 10             	cmp    $0x10,%ebx
  800c31:	75 15                	jne    800c48 <strtol+0x64>
  800c33:	80 3a 30             	cmpb   $0x30,(%edx)
  800c36:	75 10                	jne    800c48 <strtol+0x64>
  800c38:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c3c:	75 0a                	jne    800c48 <strtol+0x64>
		s += 2, base = 16;
  800c3e:	83 c2 02             	add    $0x2,%edx
  800c41:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c46:	eb 13                	jmp    800c5b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c48:	84 c0                	test   %al,%al
  800c4a:	74 0f                	je     800c5b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c51:	80 3a 30             	cmpb   $0x30,(%edx)
  800c54:	75 05                	jne    800c5b <strtol+0x77>
		s++, base = 8;
  800c56:	83 c2 01             	add    $0x1,%edx
  800c59:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c60:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c62:	0f b6 0a             	movzbl (%edx),%ecx
  800c65:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c68:	80 fb 09             	cmp    $0x9,%bl
  800c6b:	77 08                	ja     800c75 <strtol+0x91>
			dig = *s - '0';
  800c6d:	0f be c9             	movsbl %cl,%ecx
  800c70:	83 e9 30             	sub    $0x30,%ecx
  800c73:	eb 1e                	jmp    800c93 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c75:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c78:	80 fb 19             	cmp    $0x19,%bl
  800c7b:	77 08                	ja     800c85 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c7d:	0f be c9             	movsbl %cl,%ecx
  800c80:	83 e9 57             	sub    $0x57,%ecx
  800c83:	eb 0e                	jmp    800c93 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c85:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c88:	80 fb 19             	cmp    $0x19,%bl
  800c8b:	77 14                	ja     800ca1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c8d:	0f be c9             	movsbl %cl,%ecx
  800c90:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c93:	39 f1                	cmp    %esi,%ecx
  800c95:	7d 0e                	jge    800ca5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c97:	83 c2 01             	add    $0x1,%edx
  800c9a:	0f af c6             	imul   %esi,%eax
  800c9d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c9f:	eb c1                	jmp    800c62 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ca1:	89 c1                	mov    %eax,%ecx
  800ca3:	eb 02                	jmp    800ca7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ca5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ca7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cab:	74 05                	je     800cb2 <strtol+0xce>
		*endptr = (char *) s;
  800cad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cb0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cb2:	89 ca                	mov    %ecx,%edx
  800cb4:	f7 da                	neg    %edx
  800cb6:	85 ff                	test   %edi,%edi
  800cb8:	0f 45 c2             	cmovne %edx,%eax
}
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ccc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 c3                	mov    %eax,%ebx
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	89 c6                	mov    %eax,%esi
  800ce0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ceb:	89 ec                	mov    %ebp,%esp
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_cgetc>:

int
sys_cgetc(void)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800d03:	b8 01 00 00 00       	mov    $0x1,%eax
  800d08:	89 d1                	mov    %edx,%ecx
  800d0a:	89 d3                	mov    %edx,%ebx
  800d0c:	89 d7                	mov    %edx,%edi
  800d0e:	89 d6                	mov    %edx,%esi
  800d10:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d1b:	89 ec                	mov    %ebp,%esp
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	83 ec 38             	sub    $0x38,%esp
  800d25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d33:	b8 03 00 00 00       	mov    $0x3,%eax
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	89 cb                	mov    %ecx,%ebx
  800d3d:	89 cf                	mov    %ecx,%edi
  800d3f:	89 ce                	mov    %ecx,%esi
  800d41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 28                	jle    800d6f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d52:	00 
  800d53:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800d5a:	00 
  800d5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d62:	00 
  800d63:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800d6a:	e8 51 f4 ff ff       	call   8001c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d78:	89 ec                	mov    %ebp,%esp
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800d90:	b8 02 00 00 00       	mov    $0x2,%eax
  800d95:	89 d1                	mov    %edx,%ecx
  800d97:	89 d3                	mov    %edx,%ebx
  800d99:	89 d7                	mov    %edx,%edi
  800d9b:	89 d6                	mov    %edx,%esi
  800d9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da8:	89 ec                	mov    %ebp,%esp
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_yield>:

void
sys_yield(void)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc5:	89 d1                	mov    %edx,%ecx
  800dc7:	89 d3                	mov    %edx,%ebx
  800dc9:	89 d7                	mov    %edx,%edi
  800dcb:	89 d6                	mov    %edx,%esi
  800dcd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd8:	89 ec                	mov    %ebp,%esp
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 38             	sub    $0x38,%esp
  800de2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	be 00 00 00 00       	mov    $0x0,%esi
  800df0:	b8 04 00 00 00       	mov    $0x4,%eax
  800df5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	89 f7                	mov    %esi,%edi
  800e00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e02:	85 c0                	test   %eax,%eax
  800e04:	7e 28                	jle    800e2e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e11:	00 
  800e12:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800e19:	00 
  800e1a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e21:	00 
  800e22:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800e29:	e8 92 f3 ff ff       	call   8001c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e2e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e31:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e34:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e37:	89 ec                	mov    %ebp,%esp
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	83 ec 38             	sub    $0x38,%esp
  800e41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e47:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	7e 28                	jle    800e8c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e6f:	00 
  800e70:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800e77:	00 
  800e78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7f:	00 
  800e80:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800e87:	e8 34 f3 ff ff       	call   8001c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e8c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e8f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e92:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e95:	89 ec                	mov    %ebp,%esp
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 38             	sub    $0x38,%esp
  800e9f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ead:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb8:	89 df                	mov    %ebx,%edi
  800eba:	89 de                	mov    %ebx,%esi
  800ebc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	7e 28                	jle    800eea <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ecd:	00 
  800ece:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800ed5:	00 
  800ed6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edd:	00 
  800ede:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800ee5:	e8 d6 f2 ff ff       	call   8001c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef3:	89 ec                	mov    %ebp,%esp
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 38             	sub    $0x38,%esp
  800efd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f00:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f03:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
  800f16:	89 df                	mov    %ebx,%edi
  800f18:	89 de                	mov    %ebx,%esi
  800f1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	7e 28                	jle    800f48 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f24:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800f33:	00 
  800f34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3b:	00 
  800f3c:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800f43:	e8 78 f2 ff ff       	call   8001c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f48:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f4b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f4e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f51:	89 ec                	mov    %ebp,%esp
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	83 ec 38             	sub    $0x38,%esp
  800f5b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f5e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f61:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f69:	b8 09 00 00 00       	mov    $0x9,%eax
  800f6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f71:	8b 55 08             	mov    0x8(%ebp),%edx
  800f74:	89 df                	mov    %ebx,%edi
  800f76:	89 de                	mov    %ebx,%esi
  800f78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	7e 28                	jle    800fa6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f82:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f89:	00 
  800f8a:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800f91:	00 
  800f92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f99:	00 
  800f9a:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800fa1:	e8 1a f2 ff ff       	call   8001c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fa6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fa9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800faf:	89 ec                	mov    %ebp,%esp
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 0c             	sub    $0xc,%esp
  800fb9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fbc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fbf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc2:	be 00 00 00 00       	mov    $0x0,%esi
  800fc7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fcc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fda:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fdd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fe0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe3:	89 ec                	mov    %ebp,%esp
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 38             	sub    $0x38,%esp
  800fed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ff0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ff3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffb:	b8 0c 00 00 00       	mov    $0xc,%eax
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	89 cb                	mov    %ecx,%ebx
  801005:	89 cf                	mov    %ecx,%edi
  801007:	89 ce                	mov    %ecx,%esi
  801009:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80100b:	85 c0                	test   %eax,%eax
  80100d:	7e 28                	jle    801037 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801013:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80101a:	00 
  80101b:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  801022:	00 
  801023:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80102a:	00 
  80102b:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  801032:	e8 89 f1 ff ff       	call   8001c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801037:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80103a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80103d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801040:	89 ec                	mov    %ebp,%esp
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	53                   	push   %ebx
  801048:	83 ec 24             	sub    $0x24,%esp
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80104e:	8b 18                	mov    (%eax),%ebx
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

		/// check if access is write and to a copy-on-write page.
    pte_t pte = uvpt[PGNUM(addr)];
  801050:	89 da                	mov    %ebx,%edx
  801052:	c1 ea 0c             	shr    $0xc,%edx
  801055:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  80105c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801060:	74 05                	je     801067 <pgfault+0x23>
  801062:	f6 c6 08             	test   $0x8,%dh
  801065:	75 1c                	jne    801083 <pgfault+0x3f>
        panic("pgfault: fault access not to a write or a copy-on-write page");
  801067:	c7 44 24 08 90 1a 80 	movl   $0x801a90,0x8(%esp)
  80106e:	00 
  80106f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801076:	00 
  801077:	c7 04 24 f0 1a 80 00 	movl   $0x801af0,(%esp)
  80107e:	e8 3d f1 ff ff       	call   8001c0 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
    if (sys_page_alloc(0, PFTEMP, PTE_W | PTE_U | PTE_P)) {
  801083:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80108a:	00 
  80108b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801092:	00 
  801093:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80109a:	e8 3d fd ff ff       	call   800ddc <sys_page_alloc>
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	74 1c                	je     8010bf <pgfault+0x7b>
        panic("pgfault: no phys mem");
  8010a3:	c7 44 24 08 fb 1a 80 	movl   $0x801afb,0x8(%esp)
  8010aa:	00 
  8010ab:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8010b2:	00 
  8010b3:	c7 04 24 f0 1a 80 00 	movl   $0x801af0,(%esp)
  8010ba:	e8 01 f1 ff ff       	call   8001c0 <_panic>
    }

    // copy data to the new page from the source page.
    void *fltpg_addr = (void *)ROUNDDOWN(addr, PGSIZE);
  8010bf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, fltpg_addr, PGSIZE);
  8010c5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010cc:	00 
  8010cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010d1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010d8:	e8 ef f9 ff ff       	call   800acc <memmove>

    // change mapping for the faulting page.
    if (sys_page_map(0, PFTEMP, 0, fltpg_addr, PTE_W|PTE_U|PTE_P)) {
  8010dd:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010e4:	00 
  8010e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010f8:	00 
  8010f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801100:	e8 36 fd ff ff       	call   800e3b <sys_page_map>
  801105:	85 c0                	test   %eax,%eax
  801107:	74 1c                	je     801125 <pgfault+0xe1>
        panic("pgfault: map error");
  801109:	c7 44 24 08 10 1b 80 	movl   $0x801b10,0x8(%esp)
  801110:	00 
  801111:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801118:	00 
  801119:	c7 04 24 f0 1a 80 00 	movl   $0x801af0,(%esp)
  801120:	e8 9b f0 ff ff       	call   8001c0 <_panic>
    }
	// panic("pgfault not implemented");
}
  801125:	83 c4 24             	add    $0x24,%esp
  801128:	5b                   	pop    %ebx
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	57                   	push   %edi
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
  801131:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	// Step 1: install user mode pgfault handler.
    set_pgfault_handler(pgfault);
  801134:	c7 04 24 44 10 80 00 	movl   $0x801044,(%esp)
  80113b:	e8 2c 03 00 00       	call   80146c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801140:	ba 07 00 00 00       	mov    $0x7,%edx
  801145:	89 d0                	mov    %edx,%eax
  801147:	cd 30                	int    $0x30
  801149:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80114c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // Step 2: create child environment.
    envid_t envid = sys_exofork();
    if (envid < 0) {
  80114f:	85 c0                	test   %eax,%eax
  801151:	79 1c                	jns    80116f <fork+0x44>
        panic("fork: cannot create child env");
  801153:	c7 44 24 08 23 1b 80 	movl   $0x801b23,0x8(%esp)
  80115a:	00 
  80115b:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801162:	00 
  801163:	c7 04 24 f0 1a 80 00 	movl   $0x801af0,(%esp)
  80116a:	e8 51 f0 ff ff       	call   8001c0 <_panic>
    }
    else if (envid == 0) {
  80116f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801176:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80117a:	75 1c                	jne    801198 <fork+0x6d>
        // child environment.
        thisenv = &envs[ENVX(sys_getenvid())];
  80117c:	e8 fb fb ff ff       	call   800d7c <sys_getenvid>
  801181:	25 ff 03 00 00       	and    $0x3ff,%eax
  801186:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801189:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80118e:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  801193:	e9 8d 01 00 00       	jmp    801325 <fork+0x1fa>

    // Step 3: duplicate pages.
    int ipd;
    for (ipd = 0; ipd < PDX(UTOP); ipd++) {
        // No page table yet.
        if (!(uvpd[ipd] & PTE_P))
  801198:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80119b:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  8011a2:	a8 01                	test   $0x1,%al
  8011a4:	0f 84 c5 00 00 00    	je     80126f <fork+0x144>
            continue;

        int ipt;
        for (ipt = 0; ipt < NPTENTRIES; ipt++) {
            unsigned pn = (ipd << 10) | ipt;
  8011aa:	89 d7                	mov    %edx,%edi
  8011ac:	c1 e7 0a             	shl    $0xa,%edi
  8011af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b4:	89 de                	mov    %ebx,%esi
  8011b6:	09 fe                	or     %edi,%esi
            if (pn != PGNUM(UXSTACKTOP - PGSIZE)) {
  8011b8:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8011be:	0f 84 9c 00 00 00    	je     801260 <fork+0x135>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	pte_t pte = uvpt[pn];
  8011c4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
    void *va = (void *)(pn << PGSHIFT);

    // If the page is writable or copy-on-write,
    // the mapping must be copy-on-write ,
    // otherwise the new environment could change this page.
    if ((pte & PTE_W) || (pte & PTE_COW)) {
  8011cb:	a9 02 08 00 00       	test   $0x802,%eax
  8011d0:	0f 84 8a 00 00 00    	je     801260 <fork+0x135>
{
	int r;

	// LAB 4: Your code here.
	pte_t pte = uvpt[pn];
    void *va = (void *)(pn << PGSHIFT);
  8011d6:	c1 e6 0c             	shl    $0xc,%esi

    // If the page is writable or copy-on-write,
    // the mapping must be copy-on-write ,
    // otherwise the new environment could change this page.
    if ((pte & PTE_W) || (pte & PTE_COW)) {
        if (sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) {
  8011d9:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011e0:	00 
  8011e1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f7:	e8 3f fc ff ff       	call   800e3b <sys_page_map>
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	74 1c                	je     80121c <fork+0xf1>
            panic("duppage: map cow error");
  801200:	c7 44 24 08 41 1b 80 	movl   $0x801b41,0x8(%esp)
  801207:	00 
  801208:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80120f:	00 
  801210:	c7 04 24 f0 1a 80 00 	movl   $0x801af0,(%esp)
  801217:	e8 a4 ef ff ff       	call   8001c0 <_panic>
        }

        // Change permission of the page in this environment to copy-on-write.
        // Otherwise the new environment would see the change in this environment.
        if (sys_page_map(0, va, 0, va, PTE_COW|PTE_U| PTE_P)) {
  80121c:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801223:	00 
  801224:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801228:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80122f:	00 
  801230:	89 74 24 04          	mov    %esi,0x4(%esp)
  801234:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123b:	e8 fb fb ff ff       	call   800e3b <sys_page_map>
  801240:	85 c0                	test   %eax,%eax
  801242:	74 1c                	je     801260 <fork+0x135>
            panic("duppage: change perm error");
  801244:	c7 44 24 08 58 1b 80 	movl   $0x801b58,0x8(%esp)
  80124b:	00 
  80124c:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801253:	00 
  801254:	c7 04 24 f0 1a 80 00 	movl   $0x801af0,(%esp)
  80125b:	e8 60 ef ff ff       	call   8001c0 <_panic>
        // No page table yet.
        if (!(uvpd[ipd] & PTE_P))
            continue;

        int ipt;
        for (ipt = 0; ipt < NPTENTRIES; ipt++) {
  801260:	83 c3 01             	add    $0x1,%ebx
  801263:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801269:	0f 85 45 ff ff ff    	jne    8011b4 <fork+0x89>
        return 0;
    }

    // Step 3: duplicate pages.
    int ipd;
    for (ipd = 0; ipd < PDX(UTOP); ipd++) {
  80126f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  801273:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
  80127a:	0f 85 18 ff ff ff    	jne    801198 <fork+0x6d>
            }
        }
    }

    // allocate a new page for child to hold the exception stack.
    if (sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) {
  801280:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801287:	00 
  801288:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80128f:	ee 
  801290:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801293:	89 04 24             	mov    %eax,(%esp)
  801296:	e8 41 fb ff ff       	call   800ddc <sys_page_alloc>
  80129b:	85 c0                	test   %eax,%eax
  80129d:	74 1c                	je     8012bb <fork+0x190>
        panic("fork: no phys mem for xstk");
  80129f:	c7 44 24 08 73 1b 80 	movl   $0x801b73,0x8(%esp)
  8012a6:	00 
  8012a7:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8012ae:	00 
  8012af:	c7 04 24 f0 1a 80 00 	movl   $0x801af0,(%esp)
  8012b6:	e8 05 ef ff ff       	call   8001c0 <_panic>
    }

    // Step 4: set user page fault entry for child.
    if (sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) {
  8012bb:	a1 04 20 80 00       	mov    0x802004,%eax
  8012c0:	8b 40 64             	mov    0x64(%eax),%eax
  8012c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012ca:	89 04 24             	mov    %eax,(%esp)
  8012cd:	e8 83 fc ff ff       	call   800f55 <sys_env_set_pgfault_upcall>
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	74 1c                	je     8012f2 <fork+0x1c7>
        panic("fork: cannot set pgfault upcall");
  8012d6:	c7 44 24 08 d0 1a 80 	movl   $0x801ad0,0x8(%esp)
  8012dd:	00 
  8012de:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8012e5:	00 
  8012e6:	c7 04 24 f0 1a 80 00 	movl   $0x801af0,(%esp)
  8012ed:	e8 ce ee ff ff       	call   8001c0 <_panic>
    }

    // Step 5: set child status to ENV_RUNNABLE.
    if (sys_env_set_status(envid, ENV_RUNNABLE)) {
  8012f2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012f9:	00 
  8012fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012fd:	89 04 24             	mov    %eax,(%esp)
  801300:	e8 f2 fb ff ff       	call   800ef7 <sys_env_set_status>
  801305:	85 c0                	test   %eax,%eax
  801307:	74 1c                	je     801325 <fork+0x1fa>
        panic("fork: cannot set env status");
  801309:	c7 44 24 08 8e 1b 80 	movl   $0x801b8e,0x8(%esp)
  801310:	00 
  801311:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801318:	00 
  801319:	c7 04 24 f0 1a 80 00 	movl   $0x801af0,(%esp)
  801320:	e8 9b ee ff ff       	call   8001c0 <_panic>
    }

    return envid;

}
  801325:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801328:	83 c4 3c             	add    $0x3c,%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5f                   	pop    %edi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <sfork>:

// Challenge!
int
sfork(void)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801336:	c7 44 24 08 aa 1b 80 	movl   $0x801baa,0x8(%esp)
  80133d:	00 
  80133e:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  801345:	00 
  801346:	c7 04 24 f0 1a 80 00 	movl   $0x801af0,(%esp)
  80134d:	e8 6e ee ff ff       	call   8001c0 <_panic>
	...

00801354 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	56                   	push   %esi
  801358:	53                   	push   %ebx
  801359:	83 ec 10             	sub    $0x10,%esp
  80135c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80135f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801362:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
    
    if (!pg)
  801365:	85 c0                	test   %eax,%eax
        pg = (void *)UTOP;
  801367:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80136c:	0f 44 c2             	cmove  %edx,%eax

    int result;
    if ((result = sys_ipc_recv(pg))) {
  80136f:	89 04 24             	mov    %eax,(%esp)
  801372:	e8 70 fc ff ff       	call   800fe7 <sys_ipc_recv>
  801377:	85 c0                	test   %eax,%eax
  801379:	74 16                	je     801391 <ipc_recv+0x3d>
        if (from_env_store)
  80137b:	85 db                	test   %ebx,%ebx
  80137d:	74 06                	je     801385 <ipc_recv+0x31>
            *from_env_store = 0;
  80137f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        if (perm_store)
  801385:	85 f6                	test   %esi,%esi
  801387:	74 2c                	je     8013b5 <ipc_recv+0x61>
            *perm_store = 0;
  801389:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80138f:	eb 24                	jmp    8013b5 <ipc_recv+0x61>
            
        return result;
    }

    if (from_env_store)
  801391:	85 db                	test   %ebx,%ebx
  801393:	74 0a                	je     80139f <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  801395:	a1 04 20 80 00       	mov    0x802004,%eax
  80139a:	8b 40 74             	mov    0x74(%eax),%eax
  80139d:	89 03                	mov    %eax,(%ebx)

    if (perm_store)
  80139f:	85 f6                	test   %esi,%esi
  8013a1:	74 0a                	je     8013ad <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  8013a3:	a1 04 20 80 00       	mov    0x802004,%eax
  8013a8:	8b 40 78             	mov    0x78(%eax),%eax
  8013ab:	89 06                	mov    %eax,(%esi)

	return thisenv->env_ipc_value;
  8013ad:	a1 04 20 80 00       	mov    0x802004,%eax
  8013b2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	57                   	push   %edi
  8013c0:	56                   	push   %esi
  8013c1:	53                   	push   %ebx
  8013c2:	83 ec 1c             	sub    $0x1c,%esp
  8013c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8013c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

    if (!pg)
  8013ce:	85 db                	test   %ebx,%ebx
        pg = (void *)UTOP;
  8013d0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013d5:	0f 44 d8             	cmove  %eax,%ebx
  8013d8:	eb 05                	jmp    8013df <ipc_send+0x23>

    int result;
    while (-E_IPC_NOT_RECV == (result = sys_ipc_try_send(to_env, val, pg, perm)))
        sys_yield();
  8013da:	e8 cd f9 ff ff       	call   800dac <sys_yield>

    if (!pg)
        pg = (void *)UTOP;

    int result;
    while (-E_IPC_NOT_RECV == (result = sys_ipc_try_send(to_env, val, pg, perm)))
  8013df:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013ee:	89 34 24             	mov    %esi,(%esp)
  8013f1:	e8 bd fb ff ff       	call   800fb3 <sys_ipc_try_send>
  8013f6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013f9:	74 df                	je     8013da <ipc_send+0x1e>
        sys_yield();

    if (result)
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	74 1c                	je     80141b <ipc_send+0x5f>
        panic("ipc_send: error");
  8013ff:	c7 44 24 08 c0 1b 80 	movl   $0x801bc0,0x8(%esp)
  801406:	00 
  801407:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80140e:	00 
  80140f:	c7 04 24 d0 1b 80 00 	movl   $0x801bd0,(%esp)
  801416:	e8 a5 ed ff ff       	call   8001c0 <_panic>
}
  80141b:	83 c4 1c             	add    $0x1c,%esp
  80141e:	5b                   	pop    %ebx
  80141f:	5e                   	pop    %esi
  801420:	5f                   	pop    %edi
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    

00801423 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801429:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80142e:	39 c8                	cmp    %ecx,%eax
  801430:	74 17                	je     801449 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801432:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801437:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80143a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801440:	8b 52 50             	mov    0x50(%edx),%edx
  801443:	39 ca                	cmp    %ecx,%edx
  801445:	75 14                	jne    80145b <ipc_find_env+0x38>
  801447:	eb 05                	jmp    80144e <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801449:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80144e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801451:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801456:	8b 40 40             	mov    0x40(%eax),%eax
  801459:	eb 0e                	jmp    801469 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80145b:	83 c0 01             	add    $0x1,%eax
  80145e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801463:	75 d2                	jne    801437 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801465:	66 b8 00 00          	mov    $0x0,%ax
}
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    
	...

0080146c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801472:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801479:	75 50                	jne    8014cb <set_pgfault_handler+0x5f>
		// First time through!
		// LAB 4: Your code here.
		int error = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P);
  80147b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801482:	00 
  801483:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80148a:	ee 
  80148b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801492:	e8 45 f9 ff ff       	call   800ddc <sys_page_alloc>
        if (error) {
  801497:	85 c0                	test   %eax,%eax
  801499:	74 1c                	je     8014b7 <set_pgfault_handler+0x4b>
            panic("No physical memory available!");
  80149b:	c7 44 24 08 da 1b 80 	movl   $0x801bda,0x8(%esp)
  8014a2:	00 
  8014a3:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8014aa:	00 
  8014ab:	c7 04 24 f8 1b 80 00 	movl   $0x801bf8,(%esp)
  8014b2:	e8 09 ed ff ff       	call   8001c0 <_panic>
        }

		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8014b7:	c7 44 24 04 d8 14 80 	movl   $0x8014d8,0x4(%esp)
  8014be:	00 
  8014bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c6:	e8 8a fa ff ff       	call   800f55 <sys_env_set_pgfault_upcall>
		
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ce:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8014d3:	c9                   	leave  
  8014d4:	c3                   	ret    
  8014d5:	00 00                	add    %al,(%eax)
	...

008014d8 <_pgfault_upcall>:
  8014d8:	54                   	push   %esp
  8014d9:	a1 08 20 80 00       	mov    0x802008,%eax
  8014de:	ff d0                	call   *%eax
  8014e0:	83 c4 04             	add    $0x4,%esp
  8014e3:	89 e0                	mov    %esp,%eax
  8014e5:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  8014e9:	8b 64 24 30          	mov    0x30(%esp),%esp
  8014ed:	53                   	push   %ebx
  8014ee:	89 60 30             	mov    %esp,0x30(%eax)
  8014f1:	89 c4                	mov    %eax,%esp
  8014f3:	83 c4 04             	add    $0x4,%esp
  8014f6:	83 c4 04             	add    $0x4,%esp
  8014f9:	61                   	popa   
  8014fa:	83 c4 04             	add    $0x4,%esp
  8014fd:	9d                   	popf   
  8014fe:	5c                   	pop    %esp
  8014ff:	c3                   	ret    

00801500 <__udivdi3>:
  801500:	83 ec 1c             	sub    $0x1c,%esp
  801503:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801507:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80150b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80150f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801513:	89 74 24 10          	mov    %esi,0x10(%esp)
  801517:	8b 74 24 24          	mov    0x24(%esp),%esi
  80151b:	85 ff                	test   %edi,%edi
  80151d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801521:	89 44 24 08          	mov    %eax,0x8(%esp)
  801525:	89 cd                	mov    %ecx,%ebp
  801527:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152b:	75 33                	jne    801560 <__udivdi3+0x60>
  80152d:	39 f1                	cmp    %esi,%ecx
  80152f:	77 57                	ja     801588 <__udivdi3+0x88>
  801531:	85 c9                	test   %ecx,%ecx
  801533:	75 0b                	jne    801540 <__udivdi3+0x40>
  801535:	b8 01 00 00 00       	mov    $0x1,%eax
  80153a:	31 d2                	xor    %edx,%edx
  80153c:	f7 f1                	div    %ecx
  80153e:	89 c1                	mov    %eax,%ecx
  801540:	89 f0                	mov    %esi,%eax
  801542:	31 d2                	xor    %edx,%edx
  801544:	f7 f1                	div    %ecx
  801546:	89 c6                	mov    %eax,%esi
  801548:	8b 44 24 04          	mov    0x4(%esp),%eax
  80154c:	f7 f1                	div    %ecx
  80154e:	89 f2                	mov    %esi,%edx
  801550:	8b 74 24 10          	mov    0x10(%esp),%esi
  801554:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801558:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80155c:	83 c4 1c             	add    $0x1c,%esp
  80155f:	c3                   	ret    
  801560:	31 d2                	xor    %edx,%edx
  801562:	31 c0                	xor    %eax,%eax
  801564:	39 f7                	cmp    %esi,%edi
  801566:	77 e8                	ja     801550 <__udivdi3+0x50>
  801568:	0f bd cf             	bsr    %edi,%ecx
  80156b:	83 f1 1f             	xor    $0x1f,%ecx
  80156e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801572:	75 2c                	jne    8015a0 <__udivdi3+0xa0>
  801574:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801578:	76 04                	jbe    80157e <__udivdi3+0x7e>
  80157a:	39 f7                	cmp    %esi,%edi
  80157c:	73 d2                	jae    801550 <__udivdi3+0x50>
  80157e:	31 d2                	xor    %edx,%edx
  801580:	b8 01 00 00 00       	mov    $0x1,%eax
  801585:	eb c9                	jmp    801550 <__udivdi3+0x50>
  801587:	90                   	nop
  801588:	89 f2                	mov    %esi,%edx
  80158a:	f7 f1                	div    %ecx
  80158c:	31 d2                	xor    %edx,%edx
  80158e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801592:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801596:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80159a:	83 c4 1c             	add    $0x1c,%esp
  80159d:	c3                   	ret    
  80159e:	66 90                	xchg   %ax,%ax
  8015a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015a5:	b8 20 00 00 00       	mov    $0x20,%eax
  8015aa:	89 ea                	mov    %ebp,%edx
  8015ac:	2b 44 24 04          	sub    0x4(%esp),%eax
  8015b0:	d3 e7                	shl    %cl,%edi
  8015b2:	89 c1                	mov    %eax,%ecx
  8015b4:	d3 ea                	shr    %cl,%edx
  8015b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015bb:	09 fa                	or     %edi,%edx
  8015bd:	89 f7                	mov    %esi,%edi
  8015bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015c3:	89 f2                	mov    %esi,%edx
  8015c5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8015c9:	d3 e5                	shl    %cl,%ebp
  8015cb:	89 c1                	mov    %eax,%ecx
  8015cd:	d3 ef                	shr    %cl,%edi
  8015cf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015d4:	d3 e2                	shl    %cl,%edx
  8015d6:	89 c1                	mov    %eax,%ecx
  8015d8:	d3 ee                	shr    %cl,%esi
  8015da:	09 d6                	or     %edx,%esi
  8015dc:	89 fa                	mov    %edi,%edx
  8015de:	89 f0                	mov    %esi,%eax
  8015e0:	f7 74 24 0c          	divl   0xc(%esp)
  8015e4:	89 d7                	mov    %edx,%edi
  8015e6:	89 c6                	mov    %eax,%esi
  8015e8:	f7 e5                	mul    %ebp
  8015ea:	39 d7                	cmp    %edx,%edi
  8015ec:	72 22                	jb     801610 <__udivdi3+0x110>
  8015ee:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8015f2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015f7:	d3 e5                	shl    %cl,%ebp
  8015f9:	39 c5                	cmp    %eax,%ebp
  8015fb:	73 04                	jae    801601 <__udivdi3+0x101>
  8015fd:	39 d7                	cmp    %edx,%edi
  8015ff:	74 0f                	je     801610 <__udivdi3+0x110>
  801601:	89 f0                	mov    %esi,%eax
  801603:	31 d2                	xor    %edx,%edx
  801605:	e9 46 ff ff ff       	jmp    801550 <__udivdi3+0x50>
  80160a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801610:	8d 46 ff             	lea    -0x1(%esi),%eax
  801613:	31 d2                	xor    %edx,%edx
  801615:	8b 74 24 10          	mov    0x10(%esp),%esi
  801619:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80161d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801621:	83 c4 1c             	add    $0x1c,%esp
  801624:	c3                   	ret    
	...

00801630 <__umoddi3>:
  801630:	83 ec 1c             	sub    $0x1c,%esp
  801633:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801637:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80163b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80163f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801643:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801647:	8b 74 24 24          	mov    0x24(%esp),%esi
  80164b:	85 ed                	test   %ebp,%ebp
  80164d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801651:	89 44 24 08          	mov    %eax,0x8(%esp)
  801655:	89 cf                	mov    %ecx,%edi
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	89 f2                	mov    %esi,%edx
  80165c:	75 1a                	jne    801678 <__umoddi3+0x48>
  80165e:	39 f1                	cmp    %esi,%ecx
  801660:	76 4e                	jbe    8016b0 <__umoddi3+0x80>
  801662:	f7 f1                	div    %ecx
  801664:	89 d0                	mov    %edx,%eax
  801666:	31 d2                	xor    %edx,%edx
  801668:	8b 74 24 10          	mov    0x10(%esp),%esi
  80166c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801670:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801674:	83 c4 1c             	add    $0x1c,%esp
  801677:	c3                   	ret    
  801678:	39 f5                	cmp    %esi,%ebp
  80167a:	77 54                	ja     8016d0 <__umoddi3+0xa0>
  80167c:	0f bd c5             	bsr    %ebp,%eax
  80167f:	83 f0 1f             	xor    $0x1f,%eax
  801682:	89 44 24 04          	mov    %eax,0x4(%esp)
  801686:	75 60                	jne    8016e8 <__umoddi3+0xb8>
  801688:	3b 0c 24             	cmp    (%esp),%ecx
  80168b:	0f 87 07 01 00 00    	ja     801798 <__umoddi3+0x168>
  801691:	89 f2                	mov    %esi,%edx
  801693:	8b 34 24             	mov    (%esp),%esi
  801696:	29 ce                	sub    %ecx,%esi
  801698:	19 ea                	sbb    %ebp,%edx
  80169a:	89 34 24             	mov    %esi,(%esp)
  80169d:	8b 04 24             	mov    (%esp),%eax
  8016a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016ac:	83 c4 1c             	add    $0x1c,%esp
  8016af:	c3                   	ret    
  8016b0:	85 c9                	test   %ecx,%ecx
  8016b2:	75 0b                	jne    8016bf <__umoddi3+0x8f>
  8016b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016b9:	31 d2                	xor    %edx,%edx
  8016bb:	f7 f1                	div    %ecx
  8016bd:	89 c1                	mov    %eax,%ecx
  8016bf:	89 f0                	mov    %esi,%eax
  8016c1:	31 d2                	xor    %edx,%edx
  8016c3:	f7 f1                	div    %ecx
  8016c5:	8b 04 24             	mov    (%esp),%eax
  8016c8:	f7 f1                	div    %ecx
  8016ca:	eb 98                	jmp    801664 <__umoddi3+0x34>
  8016cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016d0:	89 f2                	mov    %esi,%edx
  8016d2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016d6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016da:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016de:	83 c4 1c             	add    $0x1c,%esp
  8016e1:	c3                   	ret    
  8016e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8016e8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8016ed:	89 e8                	mov    %ebp,%eax
  8016ef:	bd 20 00 00 00       	mov    $0x20,%ebp
  8016f4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8016f8:	89 fa                	mov    %edi,%edx
  8016fa:	d3 e0                	shl    %cl,%eax
  8016fc:	89 e9                	mov    %ebp,%ecx
  8016fe:	d3 ea                	shr    %cl,%edx
  801700:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801705:	09 c2                	or     %eax,%edx
  801707:	8b 44 24 08          	mov    0x8(%esp),%eax
  80170b:	89 14 24             	mov    %edx,(%esp)
  80170e:	89 f2                	mov    %esi,%edx
  801710:	d3 e7                	shl    %cl,%edi
  801712:	89 e9                	mov    %ebp,%ecx
  801714:	d3 ea                	shr    %cl,%edx
  801716:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80171b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80171f:	d3 e6                	shl    %cl,%esi
  801721:	89 e9                	mov    %ebp,%ecx
  801723:	d3 e8                	shr    %cl,%eax
  801725:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80172a:	09 f0                	or     %esi,%eax
  80172c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801730:	f7 34 24             	divl   (%esp)
  801733:	d3 e6                	shl    %cl,%esi
  801735:	89 74 24 08          	mov    %esi,0x8(%esp)
  801739:	89 d6                	mov    %edx,%esi
  80173b:	f7 e7                	mul    %edi
  80173d:	39 d6                	cmp    %edx,%esi
  80173f:	89 c1                	mov    %eax,%ecx
  801741:	89 d7                	mov    %edx,%edi
  801743:	72 3f                	jb     801784 <__umoddi3+0x154>
  801745:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801749:	72 35                	jb     801780 <__umoddi3+0x150>
  80174b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80174f:	29 c8                	sub    %ecx,%eax
  801751:	19 fe                	sbb    %edi,%esi
  801753:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801758:	89 f2                	mov    %esi,%edx
  80175a:	d3 e8                	shr    %cl,%eax
  80175c:	89 e9                	mov    %ebp,%ecx
  80175e:	d3 e2                	shl    %cl,%edx
  801760:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801765:	09 d0                	or     %edx,%eax
  801767:	89 f2                	mov    %esi,%edx
  801769:	d3 ea                	shr    %cl,%edx
  80176b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80176f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801773:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801777:	83 c4 1c             	add    $0x1c,%esp
  80177a:	c3                   	ret    
  80177b:	90                   	nop
  80177c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801780:	39 d6                	cmp    %edx,%esi
  801782:	75 c7                	jne    80174b <__umoddi3+0x11b>
  801784:	89 d7                	mov    %edx,%edi
  801786:	89 c1                	mov    %eax,%ecx
  801788:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80178c:	1b 3c 24             	sbb    (%esp),%edi
  80178f:	eb ba                	jmp    80174b <__umoddi3+0x11b>
  801791:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801798:	39 f5                	cmp    %esi,%ebp
  80179a:	0f 82 f1 fe ff ff    	jb     801691 <__umoddi3+0x61>
  8017a0:	e9 f8 fe ff ff       	jmp    80169d <__umoddi3+0x6d>
