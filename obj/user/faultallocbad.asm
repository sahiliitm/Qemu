
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 20 13 80 00 	movl   $0x801320,(%esp)
  80004b:	e8 ff 01 00 00       	call   80024f <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 fd 0c 00 00       	call   800d6c <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 40 13 80 	movl   $0x801340,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 2a 13 80 00 	movl   $0x80132a,(%esp)
  800092:	e8 bd 00 00 00       	call   800154 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 6c 13 80 	movl   $0x80136c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 41 07 00 00       	call   8007f4 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 09 0f 00 00       	call   800fd4 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 71 0b 00 00       	call   800c50 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000f6:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000fd:	00 00 00 
	envid_t envid = sys_getenvid();
  800100:	e8 07 0c 00 00       	call   800d0c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  800105:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800112:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800117:	85 f6                	test   %esi,%esi
  800119:	7e 07                	jle    800122 <libmain+0x3e>
		binaryname = argv[0];
  80011b:	8b 03                	mov    (%ebx),%eax
  80011d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800122:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800126:	89 34 24             	mov    %esi,(%esp)
  800129:	e8 8b ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  80012e:	e8 0d 00 00 00       	call   800140 <exit>
}
  800133:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800136:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800139:	89 ec                	mov    %ebp,%esp
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    
  80013d:	00 00                	add    %al,(%eax)
	...

00800140 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014d:	e8 5d 0b 00 00       	call   800caf <sys_env_destroy>
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
  800159:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800165:	e8 a2 0b 00 00       	call   800d0c <sys_getenvid>
  80016a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800178:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 98 13 80 00 	movl   $0x801398,(%esp)
  800187:	e8 c3 00 00 00       	call   80024f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800190:	8b 45 10             	mov    0x10(%ebp),%eax
  800193:	89 04 24             	mov    %eax,(%esp)
  800196:	e8 53 00 00 00       	call   8001ee <vcprintf>
	cprintf("\n");
  80019b:	c7 04 24 28 13 80 00 	movl   $0x801328,(%esp)
  8001a2:	e8 a8 00 00 00       	call   80024f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a7:	cc                   	int3   
  8001a8:	eb fd                	jmp    8001a7 <_panic+0x53>
	...

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 14             	sub    $0x14,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	83 c0 01             	add    $0x1,%eax
  8001c2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c9:	75 19                	jne    8001e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d2:	00 
  8001d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d6:	89 04 24             	mov    %eax,(%esp)
  8001d9:	e8 72 0a 00 00       	call   800c50 <sys_cputs>
		b->idx = 0;
  8001de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e8:	83 c4 14             	add    $0x14,%esp
  8001eb:	5b                   	pop    %ebx
  8001ec:	5d                   	pop    %ebp
  8001ed:	c3                   	ret    

008001ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fe:	00 00 00 
	b.cnt = 0;
  800201:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800208:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	89 44 24 08          	mov    %eax,0x8(%esp)
  800219:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	c7 04 24 ac 01 80 00 	movl   $0x8001ac,(%esp)
  80022a:	e8 d5 01 00 00       	call   800404 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800235:	89 44 24 04          	mov    %eax,0x4(%esp)
  800239:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	e8 09 0a 00 00       	call   800c50 <sys_cputs>

	return b.cnt;
}
  800247:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800255:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 87 ff ff ff       	call   8001ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800267:	c9                   	leave  
  800268:	c3                   	ret    
  800269:	00 00                	add    %al,(%eax)
  80026b:	00 00                	add    %al,(%eax)
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800290:	b8 00 00 00 00       	mov    $0x0,%eax
  800295:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800298:	72 11                	jb     8002ab <printnum+0x3b>
  80029a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029d:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a0:	76 09                	jbe    8002ab <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a2:	83 eb 01             	sub    $0x1,%ebx
  8002a5:	85 db                	test   %ebx,%ebx
  8002a7:	7f 51                	jg     8002fa <printnum+0x8a>
  8002a9:	eb 5e                	jmp    800309 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ab:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002af:	83 eb 01             	sub    $0x1,%ebx
  8002b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cc:	00 
  8002cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002da:	e8 91 0d 00 00       	call   801070 <__udivdi3>
  8002df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ee:	89 fa                	mov    %edi,%edx
  8002f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f3:	e8 78 ff ff ff       	call   800270 <printnum>
  8002f8:	eb 0f                	jmp    800309 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fe:	89 34 24             	mov    %esi,(%esp)
  800301:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800304:	83 eb 01             	sub    $0x1,%ebx
  800307:	75 f1                	jne    8002fa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800309:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800311:	8b 45 10             	mov    0x10(%ebp),%eax
  800314:	89 44 24 08          	mov    %eax,0x8(%esp)
  800318:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031f:	00 
  800320:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	e8 6e 0e 00 00       	call   8011a0 <__umoddi3>
  800332:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800336:	0f be 80 bc 13 80 00 	movsbl 0x8013bc(%eax),%eax
  80033d:	89 04 24             	mov    %eax,(%esp)
  800340:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800343:	83 c4 3c             	add    $0x3c,%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034e:	83 fa 01             	cmp    $0x1,%edx
  800351:	7e 0e                	jle    800361 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800353:	8b 10                	mov    (%eax),%edx
  800355:	8d 4a 08             	lea    0x8(%edx),%ecx
  800358:	89 08                	mov    %ecx,(%eax)
  80035a:	8b 02                	mov    (%edx),%eax
  80035c:	8b 52 04             	mov    0x4(%edx),%edx
  80035f:	eb 22                	jmp    800383 <getuint+0x38>
	else if (lflag)
  800361:	85 d2                	test   %edx,%edx
  800363:	74 10                	je     800375 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800365:	8b 10                	mov    (%eax),%edx
  800367:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036a:	89 08                	mov    %ecx,(%eax)
  80036c:	8b 02                	mov    (%edx),%eax
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	eb 0e                	jmp    800383 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800375:	8b 10                	mov    (%eax),%edx
  800377:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037a:	89 08                	mov    %ecx,(%eax)
  80037c:	8b 02                	mov    (%edx),%eax
  80037e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800388:	83 fa 01             	cmp    $0x1,%edx
  80038b:	7e 0e                	jle    80039b <getint+0x16>
		return va_arg(*ap, long long);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	8b 52 04             	mov    0x4(%edx),%edx
  800399:	eb 22                	jmp    8003bd <getint+0x38>
	else if (lflag)
  80039b:	85 d2                	test   %edx,%edx
  80039d:	74 10                	je     8003af <getint+0x2a>
		return va_arg(*ap, long);
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a4:	89 08                	mov    %ecx,(%eax)
  8003a6:	8b 02                	mov    (%edx),%eax
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 fa 1f             	sar    $0x1f,%edx
  8003ad:	eb 0e                	jmp    8003bd <getint+0x38>
	else
		return va_arg(*ap, int);
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b4:	89 08                	mov    %ecx,(%eax)
  8003b6:	8b 02                	mov    (%edx),%eax
  8003b8:	89 c2                	mov    %eax,%edx
  8003ba:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ce:	73 0a                	jae    8003da <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d3:	88 0a                	mov    %cl,(%edx)
  8003d5:	83 c2 01             	add    $0x1,%edx
  8003d8:	89 10                	mov    %edx,(%eax)
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	89 04 24             	mov    %eax,(%esp)
  8003fd:	e8 02 00 00 00       	call   800404 <vprintfmt>
	va_end(ap);
}
  800402:	c9                   	leave  
  800403:	c3                   	ret    

00800404 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	83 ec 4c             	sub    $0x4c,%esp
  80040d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800410:	8b 75 10             	mov    0x10(%ebp),%esi
  800413:	eb 12                	jmp    800427 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800415:	85 c0                	test   %eax,%eax
  800417:	0f 84 77 03 00 00    	je     800794 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  80041d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800421:	89 04 24             	mov    %eax,(%esp)
  800424:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800427:	0f b6 06             	movzbl (%esi),%eax
  80042a:	83 c6 01             	add    $0x1,%esi
  80042d:	83 f8 25             	cmp    $0x25,%eax
  800430:	75 e3                	jne    800415 <vprintfmt+0x11>
  800432:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800436:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80043d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800442:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800449:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800451:	eb 2b                	jmp    80047e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800456:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80045a:	eb 22                	jmp    80047e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80045f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800463:	eb 19                	jmp    80047e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800468:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80046f:	eb 0d                	jmp    80047e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800471:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800474:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800477:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	0f b6 06             	movzbl (%esi),%eax
  800481:	0f b6 d0             	movzbl %al,%edx
  800484:	8d 7e 01             	lea    0x1(%esi),%edi
  800487:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80048a:	83 e8 23             	sub    $0x23,%eax
  80048d:	3c 55                	cmp    $0x55,%al
  80048f:	0f 87 d9 02 00 00    	ja     80076e <vprintfmt+0x36a>
  800495:	0f b6 c0             	movzbl %al,%eax
  800498:	ff 24 85 80 14 80 00 	jmp    *0x801480(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049f:	83 ea 30             	sub    $0x30,%edx
  8004a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004a5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004a9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004af:	83 fa 09             	cmp    $0x9,%edx
  8004b2:	77 4a                	ja     8004fe <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004ba:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004bd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004c1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004c7:	83 fa 09             	cmp    $0x9,%edx
  8004ca:	76 eb                	jbe    8004b7 <vprintfmt+0xb3>
  8004cc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004cf:	eb 2d                	jmp    8004fe <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8d 50 04             	lea    0x4(%eax),%edx
  8004d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e2:	eb 1a                	jmp    8004fe <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004eb:	79 91                	jns    80047e <vprintfmt+0x7a>
  8004ed:	e9 73 ff ff ff       	jmp    800465 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004fc:	eb 80                	jmp    80047e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800502:	0f 89 76 ff ff ff    	jns    80047e <vprintfmt+0x7a>
  800508:	e9 64 ff ff ff       	jmp    800471 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800513:	e9 66 ff ff ff       	jmp    80047e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 50 04             	lea    0x4(%eax),%edx
  80051e:	89 55 14             	mov    %edx,0x14(%ebp)
  800521:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800525:	8b 00                	mov    (%eax),%eax
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800530:	e9 f2 fe ff ff       	jmp    800427 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 c2                	mov    %eax,%edx
  800542:	c1 fa 1f             	sar    $0x1f,%edx
  800545:	31 d0                	xor    %edx,%eax
  800547:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800549:	83 f8 08             	cmp    $0x8,%eax
  80054c:	7f 0b                	jg     800559 <vprintfmt+0x155>
  80054e:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	75 23                	jne    80057c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800559:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055d:	c7 44 24 08 d4 13 80 	movl   $0x8013d4,0x8(%esp)
  800564:	00 
  800565:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800569:	8b 7d 08             	mov    0x8(%ebp),%edi
  80056c:	89 3c 24             	mov    %edi,(%esp)
  80056f:	e8 68 fe ff ff       	call   8003dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800577:	e9 ab fe ff ff       	jmp    800427 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80057c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800580:	c7 44 24 08 dd 13 80 	movl   $0x8013dd,0x8(%esp)
  800587:	00 
  800588:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058f:	89 3c 24             	mov    %edi,(%esp)
  800592:	e8 45 fe ff ff       	call   8003dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80059a:	e9 88 fe ff ff       	jmp    800427 <vprintfmt+0x23>
  80059f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005b3:	85 f6                	test   %esi,%esi
  8005b5:	ba cd 13 80 00       	mov    $0x8013cd,%edx
  8005ba:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005bd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005c1:	7e 06                	jle    8005c9 <vprintfmt+0x1c5>
  8005c3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005c7:	75 10                	jne    8005d9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c9:	0f be 06             	movsbl (%esi),%eax
  8005cc:	83 c6 01             	add    $0x1,%esi
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	0f 85 86 00 00 00    	jne    80065d <vprintfmt+0x259>
  8005d7:	eb 76                	jmp    80064f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005dd:	89 34 24             	mov    %esi,(%esp)
  8005e0:	e8 56 02 00 00       	call   80083b <strnlen>
  8005e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005e8:	29 c2                	sub    %eax,%edx
  8005ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	7e d8                	jle    8005c9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  8005f1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005f5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005f8:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8005fb:	89 d6                	mov    %edx,%esi
  8005fd:	89 c7                	mov    %eax,%edi
  8005ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800603:	89 3c 24             	mov    %edi,(%esp)
  800606:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	83 ee 01             	sub    $0x1,%esi
  80060c:	75 f1                	jne    8005ff <vprintfmt+0x1fb>
  80060e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800611:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800614:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800617:	eb b0                	jmp    8005c9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800619:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061d:	74 18                	je     800637 <vprintfmt+0x233>
  80061f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800622:	83 fa 5e             	cmp    $0x5e,%edx
  800625:	76 10                	jbe    800637 <vprintfmt+0x233>
					putch('?', putdat);
  800627:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800632:	ff 55 08             	call   *0x8(%ebp)
  800635:	eb 0a                	jmp    800641 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800637:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800641:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800645:	0f be 06             	movsbl (%esi),%eax
  800648:	83 c6 01             	add    $0x1,%esi
  80064b:	85 c0                	test   %eax,%eax
  80064d:	75 0e                	jne    80065d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800652:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800656:	7f 11                	jg     800669 <vprintfmt+0x265>
  800658:	e9 ca fd ff ff       	jmp    800427 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065d:	85 ff                	test   %edi,%edi
  80065f:	90                   	nop
  800660:	78 b7                	js     800619 <vprintfmt+0x215>
  800662:	83 ef 01             	sub    $0x1,%edi
  800665:	79 b2                	jns    800619 <vprintfmt+0x215>
  800667:	eb e6                	jmp    80064f <vprintfmt+0x24b>
  800669:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80066c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80066f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800673:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80067a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067c:	83 ee 01             	sub    $0x1,%esi
  80067f:	75 ee                	jne    80066f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800681:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800684:	e9 9e fd ff ff       	jmp    800427 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800689:	89 ca                	mov    %ecx,%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 f2 fc ff ff       	call   800385 <getint>
  800693:	89 c6                	mov    %eax,%esi
  800695:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800697:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069c:	85 d2                	test   %edx,%edx
  80069e:	0f 89 8c 00 00 00    	jns    800730 <vprintfmt+0x32c>
				putch('-', putdat);
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b2:	f7 de                	neg    %esi
  8006b4:	83 d7 00             	adc    $0x0,%edi
  8006b7:	f7 df                	neg    %edi
			}
			base = 10;
  8006b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006be:	eb 70                	jmp    800730 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c0:	89 ca                	mov    %ecx,%edx
  8006c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c5:	e8 81 fc ff ff       	call   80034b <getuint>
  8006ca:	89 c6                	mov    %eax,%esi
  8006cc:	89 d7                	mov    %edx,%edi
			base = 10;
  8006ce:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006d3:	eb 5b                	jmp    800730 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  8006d5:	89 ca                	mov    %ecx,%edx
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006da:	e8 a6 fc ff ff       	call   800385 <getint>
  8006df:	89 c6                	mov    %eax,%esi
  8006e1:	89 d7                	mov    %edx,%edi
			base = 8;
  8006e3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006e8:	eb 46                	jmp    800730 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ee:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006f5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800703:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80070f:	8b 30                	mov    (%eax),%esi
  800711:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800716:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80071b:	eb 13                	jmp    800730 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80071d:	89 ca                	mov    %ecx,%edx
  80071f:	8d 45 14             	lea    0x14(%ebp),%eax
  800722:	e8 24 fc ff ff       	call   80034b <getuint>
  800727:	89 c6                	mov    %eax,%esi
  800729:	89 d7                	mov    %edx,%edi
			base = 16;
  80072b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800730:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800734:	89 54 24 10          	mov    %edx,0x10(%esp)
  800738:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80073b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80073f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800743:	89 34 24             	mov    %esi,(%esp)
  800746:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074a:	89 da                	mov    %ebx,%edx
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	e8 1c fb ff ff       	call   800270 <printnum>
			break;
  800754:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800757:	e9 cb fc ff ff       	jmp    800427 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80075c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800760:	89 14 24             	mov    %edx,(%esp)
  800763:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800766:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800769:	e9 b9 fc ff ff       	jmp    800427 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80076e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800772:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800779:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800780:	0f 84 a1 fc ff ff    	je     800427 <vprintfmt+0x23>
  800786:	83 ee 01             	sub    $0x1,%esi
  800789:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80078d:	75 f7                	jne    800786 <vprintfmt+0x382>
  80078f:	e9 93 fc ff ff       	jmp    800427 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800794:	83 c4 4c             	add    $0x4c,%esp
  800797:	5b                   	pop    %ebx
  800798:	5e                   	pop    %esi
  800799:	5f                   	pop    %edi
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	83 ec 28             	sub    $0x28,%esp
  8007a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ab:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007af:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	74 30                	je     8007ed <vsnprintf+0x51>
  8007bd:	85 d2                	test   %edx,%edx
  8007bf:	7e 2c                	jle    8007ed <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d6:	c7 04 24 bf 03 80 00 	movl   $0x8003bf,(%esp)
  8007dd:	e8 22 fc ff ff       	call   800404 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007eb:	eb 05                	jmp    8007f2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f2:	c9                   	leave  
  8007f3:	c3                   	ret    

008007f4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800801:	8b 45 10             	mov    0x10(%ebp),%eax
  800804:	89 44 24 08          	mov    %eax,0x8(%esp)
  800808:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	89 04 24             	mov    %eax,(%esp)
  800815:	e8 82 ff ff ff       	call   80079c <vsnprintf>
	va_end(ap);

	return rc;
}
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    
  80081c:	00 00                	add    %al,(%eax)
	...

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	80 3a 00             	cmpb   $0x0,(%edx)
  80082e:	74 09                	je     800839 <strlen+0x19>
		n++;
  800830:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800833:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800837:	75 f7                	jne    800830 <strlen+0x10>
		n++;
	return n;
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
  80084a:	85 c9                	test   %ecx,%ecx
  80084c:	74 1a                	je     800868 <strnlen+0x2d>
  80084e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800851:	74 15                	je     800868 <strnlen+0x2d>
  800853:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800858:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085a:	39 ca                	cmp    %ecx,%edx
  80085c:	74 0a                	je     800868 <strnlen+0x2d>
  80085e:	83 c2 01             	add    $0x1,%edx
  800861:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800866:	75 f0                	jne    800858 <strnlen+0x1d>
		n++;
	return n;
}
  800868:	5b                   	pop    %ebx
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800875:	ba 00 00 00 00       	mov    $0x0,%edx
  80087a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80087e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800881:	83 c2 01             	add    $0x1,%edx
  800884:	84 c9                	test   %cl,%cl
  800886:	75 f2                	jne    80087a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800888:	5b                   	pop    %ebx
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800895:	89 1c 24             	mov    %ebx,(%esp)
  800898:	e8 83 ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a4:	01 d8                	add    %ebx,%eax
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	e8 bd ff ff ff       	call   80086b <strcpy>
	return dst;
}
  8008ae:	89 d8                	mov    %ebx,%eax
  8008b0:	83 c4 08             	add    $0x8,%esp
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	56                   	push   %esi
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c4:	85 f6                	test   %esi,%esi
  8008c6:	74 18                	je     8008e0 <strncpy+0x2a>
  8008c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008cd:	0f b6 1a             	movzbl (%edx),%ebx
  8008d0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008d6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d9:	83 c1 01             	add    $0x1,%ecx
  8008dc:	39 f1                	cmp    %esi,%ecx
  8008de:	75 ed                	jne    8008cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	57                   	push   %edi
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008f0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f3:	89 f8                	mov    %edi,%eax
  8008f5:	85 f6                	test   %esi,%esi
  8008f7:	74 2b                	je     800924 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8008f9:	83 fe 01             	cmp    $0x1,%esi
  8008fc:	74 23                	je     800921 <strlcpy+0x3d>
  8008fe:	0f b6 0b             	movzbl (%ebx),%ecx
  800901:	84 c9                	test   %cl,%cl
  800903:	74 1c                	je     800921 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800905:	83 ee 02             	sub    $0x2,%esi
  800908:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80090d:	88 08                	mov    %cl,(%eax)
  80090f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800912:	39 f2                	cmp    %esi,%edx
  800914:	74 0b                	je     800921 <strlcpy+0x3d>
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80091d:	84 c9                	test   %cl,%cl
  80091f:	75 ec                	jne    80090d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800921:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800924:	29 f8                	sub    %edi,%eax
}
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5f                   	pop    %edi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800934:	0f b6 01             	movzbl (%ecx),%eax
  800937:	84 c0                	test   %al,%al
  800939:	74 16                	je     800951 <strcmp+0x26>
  80093b:	3a 02                	cmp    (%edx),%al
  80093d:	75 12                	jne    800951 <strcmp+0x26>
		p++, q++;
  80093f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800942:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800946:	84 c0                	test   %al,%al
  800948:	74 07                	je     800951 <strcmp+0x26>
  80094a:	83 c1 01             	add    $0x1,%ecx
  80094d:	3a 02                	cmp    (%edx),%al
  80094f:	74 ee                	je     80093f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800951:	0f b6 c0             	movzbl %al,%eax
  800954:	0f b6 12             	movzbl (%edx),%edx
  800957:	29 d0                	sub    %edx,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800962:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800965:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800968:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80096d:	85 d2                	test   %edx,%edx
  80096f:	74 28                	je     800999 <strncmp+0x3e>
  800971:	0f b6 01             	movzbl (%ecx),%eax
  800974:	84 c0                	test   %al,%al
  800976:	74 24                	je     80099c <strncmp+0x41>
  800978:	3a 03                	cmp    (%ebx),%al
  80097a:	75 20                	jne    80099c <strncmp+0x41>
  80097c:	83 ea 01             	sub    $0x1,%edx
  80097f:	74 13                	je     800994 <strncmp+0x39>
		n--, p++, q++;
  800981:	83 c1 01             	add    $0x1,%ecx
  800984:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800987:	0f b6 01             	movzbl (%ecx),%eax
  80098a:	84 c0                	test   %al,%al
  80098c:	74 0e                	je     80099c <strncmp+0x41>
  80098e:	3a 03                	cmp    (%ebx),%al
  800990:	74 ea                	je     80097c <strncmp+0x21>
  800992:	eb 08                	jmp    80099c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80099c:	0f b6 01             	movzbl (%ecx),%eax
  80099f:	0f b6 13             	movzbl (%ebx),%edx
  8009a2:	29 d0                	sub    %edx,%eax
  8009a4:	eb f3                	jmp    800999 <strncmp+0x3e>

008009a6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b0:	0f b6 10             	movzbl (%eax),%edx
  8009b3:	84 d2                	test   %dl,%dl
  8009b5:	74 1c                	je     8009d3 <strchr+0x2d>
		if (*s == c)
  8009b7:	38 ca                	cmp    %cl,%dl
  8009b9:	75 09                	jne    8009c4 <strchr+0x1e>
  8009bb:	eb 1b                	jmp    8009d8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009bd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8009c0:	38 ca                	cmp    %cl,%dl
  8009c2:	74 14                	je     8009d8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8009c8:	84 d2                	test   %dl,%dl
  8009ca:	75 f1                	jne    8009bd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d1:	eb 05                	jmp    8009d8 <strchr+0x32>
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e4:	0f b6 10             	movzbl (%eax),%edx
  8009e7:	84 d2                	test   %dl,%dl
  8009e9:	74 14                	je     8009ff <strfind+0x25>
		if (*s == c)
  8009eb:	38 ca                	cmp    %cl,%dl
  8009ed:	75 06                	jne    8009f5 <strfind+0x1b>
  8009ef:	eb 0e                	jmp    8009ff <strfind+0x25>
  8009f1:	38 ca                	cmp    %cl,%dl
  8009f3:	74 0a                	je     8009ff <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	0f b6 10             	movzbl (%eax),%edx
  8009fb:	84 d2                	test   %dl,%dl
  8009fd:	75 f2                	jne    8009f1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	83 ec 0c             	sub    $0xc,%esp
  800a07:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a0a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a0d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a10:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a19:	85 c9                	test   %ecx,%ecx
  800a1b:	74 30                	je     800a4d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a23:	75 25                	jne    800a4a <memset+0x49>
  800a25:	f6 c1 03             	test   $0x3,%cl
  800a28:	75 20                	jne    800a4a <memset+0x49>
		c &= 0xFF;
  800a2a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a2d:	89 d3                	mov    %edx,%ebx
  800a2f:	c1 e3 08             	shl    $0x8,%ebx
  800a32:	89 d6                	mov    %edx,%esi
  800a34:	c1 e6 18             	shl    $0x18,%esi
  800a37:	89 d0                	mov    %edx,%eax
  800a39:	c1 e0 10             	shl    $0x10,%eax
  800a3c:	09 f0                	or     %esi,%eax
  800a3e:	09 d0                	or     %edx,%eax
  800a40:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a42:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a45:	fc                   	cld    
  800a46:	f3 ab                	rep stos %eax,%es:(%edi)
  800a48:	eb 03                	jmp    800a4d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a4a:	fc                   	cld    
  800a4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4d:	89 f8                	mov    %edi,%eax
  800a4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a58:	89 ec                	mov    %ebp,%esp
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	83 ec 08             	sub    $0x8,%esp
  800a62:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a65:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a71:	39 c6                	cmp    %eax,%esi
  800a73:	73 36                	jae    800aab <memmove+0x4f>
  800a75:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a78:	39 d0                	cmp    %edx,%eax
  800a7a:	73 2f                	jae    800aab <memmove+0x4f>
		s += n;
		d += n;
  800a7c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7f:	f6 c2 03             	test   $0x3,%dl
  800a82:	75 1b                	jne    800a9f <memmove+0x43>
  800a84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8a:	75 13                	jne    800a9f <memmove+0x43>
  800a8c:	f6 c1 03             	test   $0x3,%cl
  800a8f:	75 0e                	jne    800a9f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a91:	83 ef 04             	sub    $0x4,%edi
  800a94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a97:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a9a:	fd                   	std    
  800a9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9d:	eb 09                	jmp    800aa8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9f:	83 ef 01             	sub    $0x1,%edi
  800aa2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aa5:	fd                   	std    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa8:	fc                   	cld    
  800aa9:	eb 20                	jmp    800acb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aab:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab1:	75 13                	jne    800ac6 <memmove+0x6a>
  800ab3:	a8 03                	test   $0x3,%al
  800ab5:	75 0f                	jne    800ac6 <memmove+0x6a>
  800ab7:	f6 c1 03             	test   $0x3,%cl
  800aba:	75 0a                	jne    800ac6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800abc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800abf:	89 c7                	mov    %eax,%edi
  800ac1:	fc                   	cld    
  800ac2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac4:	eb 05                	jmp    800acb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac6:	89 c7                	mov    %eax,%edi
  800ac8:	fc                   	cld    
  800ac9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800acb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ace:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ad1:	89 ec                	mov    %ebp,%esp
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800adb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ade:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	89 04 24             	mov    %eax,(%esp)
  800aef:	e8 68 ff ff ff       	call   800a5c <memmove>
}
  800af4:	c9                   	leave  
  800af5:	c3                   	ret    

00800af6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0a:	85 ff                	test   %edi,%edi
  800b0c:	74 37                	je     800b45 <memcmp+0x4f>
		if (*s1 != *s2)
  800b0e:	0f b6 03             	movzbl (%ebx),%eax
  800b11:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b14:	83 ef 01             	sub    $0x1,%edi
  800b17:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b1c:	38 c8                	cmp    %cl,%al
  800b1e:	74 1c                	je     800b3c <memcmp+0x46>
  800b20:	eb 10                	jmp    800b32 <memcmp+0x3c>
  800b22:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b27:	83 c2 01             	add    $0x1,%edx
  800b2a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b2e:	38 c8                	cmp    %cl,%al
  800b30:	74 0a                	je     800b3c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800b32:	0f b6 c0             	movzbl %al,%eax
  800b35:	0f b6 c9             	movzbl %cl,%ecx
  800b38:	29 c8                	sub    %ecx,%eax
  800b3a:	eb 09                	jmp    800b45 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3c:	39 fa                	cmp    %edi,%edx
  800b3e:	75 e2                	jne    800b22 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b50:	89 c2                	mov    %eax,%edx
  800b52:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b55:	39 d0                	cmp    %edx,%eax
  800b57:	73 19                	jae    800b72 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b59:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b5d:	38 08                	cmp    %cl,(%eax)
  800b5f:	75 06                	jne    800b67 <memfind+0x1d>
  800b61:	eb 0f                	jmp    800b72 <memfind+0x28>
  800b63:	38 08                	cmp    %cl,(%eax)
  800b65:	74 0b                	je     800b72 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b67:	83 c0 01             	add    $0x1,%eax
  800b6a:	39 d0                	cmp    %edx,%eax
  800b6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b70:	75 f1                	jne    800b63 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b80:	0f b6 02             	movzbl (%edx),%eax
  800b83:	3c 20                	cmp    $0x20,%al
  800b85:	74 04                	je     800b8b <strtol+0x17>
  800b87:	3c 09                	cmp    $0x9,%al
  800b89:	75 0e                	jne    800b99 <strtol+0x25>
		s++;
  800b8b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8e:	0f b6 02             	movzbl (%edx),%eax
  800b91:	3c 20                	cmp    $0x20,%al
  800b93:	74 f6                	je     800b8b <strtol+0x17>
  800b95:	3c 09                	cmp    $0x9,%al
  800b97:	74 f2                	je     800b8b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b99:	3c 2b                	cmp    $0x2b,%al
  800b9b:	75 0a                	jne    800ba7 <strtol+0x33>
		s++;
  800b9d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba5:	eb 10                	jmp    800bb7 <strtol+0x43>
  800ba7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bac:	3c 2d                	cmp    $0x2d,%al
  800bae:	75 07                	jne    800bb7 <strtol+0x43>
		s++, neg = 1;
  800bb0:	83 c2 01             	add    $0x1,%edx
  800bb3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb7:	85 db                	test   %ebx,%ebx
  800bb9:	0f 94 c0             	sete   %al
  800bbc:	74 05                	je     800bc3 <strtol+0x4f>
  800bbe:	83 fb 10             	cmp    $0x10,%ebx
  800bc1:	75 15                	jne    800bd8 <strtol+0x64>
  800bc3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bc6:	75 10                	jne    800bd8 <strtol+0x64>
  800bc8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bcc:	75 0a                	jne    800bd8 <strtol+0x64>
		s += 2, base = 16;
  800bce:	83 c2 02             	add    $0x2,%edx
  800bd1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd6:	eb 13                	jmp    800beb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800bd8:	84 c0                	test   %al,%al
  800bda:	74 0f                	je     800beb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bdc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be1:	80 3a 30             	cmpb   $0x30,(%edx)
  800be4:	75 05                	jne    800beb <strtol+0x77>
		s++, base = 8;
  800be6:	83 c2 01             	add    $0x1,%edx
  800be9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800beb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf2:	0f b6 0a             	movzbl (%edx),%ecx
  800bf5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bf8:	80 fb 09             	cmp    $0x9,%bl
  800bfb:	77 08                	ja     800c05 <strtol+0x91>
			dig = *s - '0';
  800bfd:	0f be c9             	movsbl %cl,%ecx
  800c00:	83 e9 30             	sub    $0x30,%ecx
  800c03:	eb 1e                	jmp    800c23 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c05:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c08:	80 fb 19             	cmp    $0x19,%bl
  800c0b:	77 08                	ja     800c15 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c0d:	0f be c9             	movsbl %cl,%ecx
  800c10:	83 e9 57             	sub    $0x57,%ecx
  800c13:	eb 0e                	jmp    800c23 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c15:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c18:	80 fb 19             	cmp    $0x19,%bl
  800c1b:	77 14                	ja     800c31 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c1d:	0f be c9             	movsbl %cl,%ecx
  800c20:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c23:	39 f1                	cmp    %esi,%ecx
  800c25:	7d 0e                	jge    800c35 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c27:	83 c2 01             	add    $0x1,%edx
  800c2a:	0f af c6             	imul   %esi,%eax
  800c2d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c2f:	eb c1                	jmp    800bf2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c31:	89 c1                	mov    %eax,%ecx
  800c33:	eb 02                	jmp    800c37 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c35:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3b:	74 05                	je     800c42 <strtol+0xce>
		*endptr = (char *) s;
  800c3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c40:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c42:	89 ca                	mov    %ecx,%edx
  800c44:	f7 da                	neg    %edx
  800c46:	85 ff                	test   %edi,%edi
  800c48:	0f 45 c2             	cmovne %edx,%eax
}
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	89 c3                	mov    %eax,%ebx
  800c6c:	89 c7                	mov    %eax,%edi
  800c6e:	89 c6                	mov    %eax,%esi
  800c70:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c72:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c75:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c78:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c7b:	89 ec                	mov    %ebp,%esp
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c88:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c8b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c93:	b8 01 00 00 00       	mov    $0x1,%eax
  800c98:	89 d1                	mov    %edx,%ecx
  800c9a:	89 d3                	mov    %edx,%ebx
  800c9c:	89 d7                	mov    %edx,%edi
  800c9e:	89 d6                	mov    %edx,%esi
  800ca0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ca5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ca8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cab:	89 ec                	mov    %ebp,%esp
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	83 ec 38             	sub    $0x38,%esp
  800cb5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cb8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cbb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	89 cb                	mov    %ecx,%ebx
  800ccd:	89 cf                	mov    %ecx,%edi
  800ccf:	89 ce                	mov    %ecx,%esi
  800cd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 28                	jle    800cff <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800cea:	00 
  800ceb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf2:	00 
  800cf3:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800cfa:	e8 55 f4 ff ff       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d08:	89 ec                	mov    %ebp,%esp
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d18:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d20:	b8 02 00 00 00       	mov    $0x2,%eax
  800d25:	89 d1                	mov    %edx,%ecx
  800d27:	89 d3                	mov    %edx,%ebx
  800d29:	89 d7                	mov    %edx,%edi
  800d2b:	89 d6                	mov    %edx,%esi
  800d2d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d38:	89 ec                	mov    %ebp,%esp
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_yield>:

void
sys_yield(void)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d50:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d55:	89 d1                	mov    %edx,%ecx
  800d57:	89 d3                	mov    %edx,%ebx
  800d59:	89 d7                	mov    %edx,%edi
  800d5b:	89 d6                	mov    %edx,%esi
  800d5d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d68:	89 ec                	mov    %ebp,%esp
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 38             	sub    $0x38,%esp
  800d72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	be 00 00 00 00       	mov    $0x0,%esi
  800d80:	b8 04 00 00 00       	mov    $0x4,%eax
  800d85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8e:	89 f7                	mov    %esi,%edi
  800d90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7e 28                	jle    800dbe <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800da1:	00 
  800da2:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800da9:	00 
  800daa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db1:	00 
  800db2:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800db9:	e8 96 f3 ff ff       	call   800154 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dbe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc7:	89 ec                	mov    %ebp,%esp
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	83 ec 38             	sub    $0x38,%esp
  800dd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	b8 05 00 00 00       	mov    $0x5,%eax
  800ddf:	8b 75 18             	mov    0x18(%ebp),%esi
  800de2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df0:	85 c0                	test   %eax,%eax
  800df2:	7e 28                	jle    800e1c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dff:	00 
  800e00:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800e07:	00 
  800e08:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0f:	00 
  800e10:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800e17:	e8 38 f3 ff ff       	call   800154 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e1c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e1f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e22:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e25:	89 ec                	mov    %ebp,%esp
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 38             	sub    $0x38,%esp
  800e2f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e32:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e35:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	89 df                	mov    %ebx,%edi
  800e4a:	89 de                	mov    %ebx,%esi
  800e4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	7e 28                	jle    800e7a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e52:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e56:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e5d:	00 
  800e5e:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800e65:	00 
  800e66:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6d:	00 
  800e6e:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800e75:	e8 da f2 ff ff       	call   800154 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e7a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e83:	89 ec                	mov    %ebp,%esp
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	83 ec 38             	sub    $0x38,%esp
  800e8d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e90:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e93:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea6:	89 df                	mov    %ebx,%edi
  800ea8:	89 de                	mov    %ebx,%esi
  800eaa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eac:	85 c0                	test   %eax,%eax
  800eae:	7e 28                	jle    800ed8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ebb:	00 
  800ebc:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800ec3:	00 
  800ec4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecb:	00 
  800ecc:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800ed3:	e8 7c f2 ff ff       	call   800154 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ed8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800edb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ede:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee1:	89 ec                	mov    %ebp,%esp
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 38             	sub    $0x38,%esp
  800eeb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef9:	b8 09 00 00 00       	mov    $0x9,%eax
  800efe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	89 df                	mov    %ebx,%edi
  800f06:	89 de                	mov    %ebx,%esi
  800f08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	7e 28                	jle    800f36 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f12:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f19:	00 
  800f1a:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800f21:	00 
  800f22:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f29:	00 
  800f2a:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800f31:	e8 1e f2 ff ff       	call   800154 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f36:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f39:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f3c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f3f:	89 ec                	mov    %ebp,%esp
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	83 ec 0c             	sub    $0xc,%esp
  800f49:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f4c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f4f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f52:	be 00 00 00 00       	mov    $0x0,%esi
  800f57:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f5c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
  800f68:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f6a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f73:	89 ec                	mov    %ebp,%esp
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 38             	sub    $0x38,%esp
  800f7d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f80:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f83:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f90:	8b 55 08             	mov    0x8(%ebp),%edx
  800f93:	89 cb                	mov    %ecx,%ebx
  800f95:	89 cf                	mov    %ecx,%edi
  800f97:	89 ce                	mov    %ecx,%esi
  800f99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	7e 28                	jle    800fc7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800faa:	00 
  800fab:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800fb2:	00 
  800fb3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fba:	00 
  800fbb:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800fc2:	e8 8d f1 ff ff       	call   800154 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fc7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fcd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd0:	89 ec                	mov    %ebp,%esp
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fda:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800fe1:	75 50                	jne    801033 <set_pgfault_handler+0x5f>
		// First time through!
		// LAB 4: Your code here.
		int error = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P);
  800fe3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fea:	00 
  800feb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800ff2:	ee 
  800ff3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ffa:	e8 6d fd ff ff       	call   800d6c <sys_page_alloc>
        if (error) {
  800fff:	85 c0                	test   %eax,%eax
  801001:	74 1c                	je     80101f <set_pgfault_handler+0x4b>
            panic("No physical memory available!");
  801003:	c7 44 24 08 2f 16 80 	movl   $0x80162f,0x8(%esp)
  80100a:	00 
  80100b:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801012:	00 
  801013:	c7 04 24 4d 16 80 00 	movl   $0x80164d,(%esp)
  80101a:	e8 35 f1 ff ff       	call   800154 <_panic>
        }

		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80101f:	c7 44 24 04 40 10 80 	movl   $0x801040,0x4(%esp)
  801026:	00 
  801027:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80102e:	e8 b2 fe ff ff       	call   800ee5 <sys_env_set_pgfault_upcall>
		
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80103b:	c9                   	leave  
  80103c:	c3                   	ret    
  80103d:	00 00                	add    %al,(%eax)
	...

00801040 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801040:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801041:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801046:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801048:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	

	movl %esp, %eax 		// temporarily save exception stack esp
  80104b:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 	// return addr (eip) -> ebx 
  80104d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 	// now trap-time stack
  801051:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 				// push eip onto trap-time stack 
  801055:	53                   	push   %ebx
	movl %esp, 48(%eax) 	// Updating the trap-time stack esp, since a new val has been pushed
  801056:	89 60 30             	mov    %esp,0x30(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	movl %eax, %esp 	/* now exception stack */
  801059:	89 c4                	mov    %eax,%esp
	addl $4, %esp 		/* skip utf_fault_va */
  80105b:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 		/* skip utf_err */
  80105e:	83 c4 04             	add    $0x4,%esp
	popal 				/* restore from utf_regs  */
  801061:	61                   	popa   
	addl $4, %esp 		/* skip utf_eip (already on trap-time stack) */
  801062:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	popfl /* restore from utf_eflags */
  801065:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp /* restore from utf_esp - top of stack (bottom-most val) will be the eip to go to */
  801066:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	
	ret
  801067:	c3                   	ret    
	...

00801070 <__udivdi3>:
  801070:	83 ec 1c             	sub    $0x1c,%esp
  801073:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801077:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80107b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80107f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801083:	89 74 24 10          	mov    %esi,0x10(%esp)
  801087:	8b 74 24 24          	mov    0x24(%esp),%esi
  80108b:	85 ff                	test   %edi,%edi
  80108d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801091:	89 44 24 08          	mov    %eax,0x8(%esp)
  801095:	89 cd                	mov    %ecx,%ebp
  801097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109b:	75 33                	jne    8010d0 <__udivdi3+0x60>
  80109d:	39 f1                	cmp    %esi,%ecx
  80109f:	77 57                	ja     8010f8 <__udivdi3+0x88>
  8010a1:	85 c9                	test   %ecx,%ecx
  8010a3:	75 0b                	jne    8010b0 <__udivdi3+0x40>
  8010a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010aa:	31 d2                	xor    %edx,%edx
  8010ac:	f7 f1                	div    %ecx
  8010ae:	89 c1                	mov    %eax,%ecx
  8010b0:	89 f0                	mov    %esi,%eax
  8010b2:	31 d2                	xor    %edx,%edx
  8010b4:	f7 f1                	div    %ecx
  8010b6:	89 c6                	mov    %eax,%esi
  8010b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010bc:	f7 f1                	div    %ecx
  8010be:	89 f2                	mov    %esi,%edx
  8010c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010cc:	83 c4 1c             	add    $0x1c,%esp
  8010cf:	c3                   	ret    
  8010d0:	31 d2                	xor    %edx,%edx
  8010d2:	31 c0                	xor    %eax,%eax
  8010d4:	39 f7                	cmp    %esi,%edi
  8010d6:	77 e8                	ja     8010c0 <__udivdi3+0x50>
  8010d8:	0f bd cf             	bsr    %edi,%ecx
  8010db:	83 f1 1f             	xor    $0x1f,%ecx
  8010de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010e2:	75 2c                	jne    801110 <__udivdi3+0xa0>
  8010e4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010e8:	76 04                	jbe    8010ee <__udivdi3+0x7e>
  8010ea:	39 f7                	cmp    %esi,%edi
  8010ec:	73 d2                	jae    8010c0 <__udivdi3+0x50>
  8010ee:	31 d2                	xor    %edx,%edx
  8010f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f5:	eb c9                	jmp    8010c0 <__udivdi3+0x50>
  8010f7:	90                   	nop
  8010f8:	89 f2                	mov    %esi,%edx
  8010fa:	f7 f1                	div    %ecx
  8010fc:	31 d2                	xor    %edx,%edx
  8010fe:	8b 74 24 10          	mov    0x10(%esp),%esi
  801102:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801106:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80110a:	83 c4 1c             	add    $0x1c,%esp
  80110d:	c3                   	ret    
  80110e:	66 90                	xchg   %ax,%ax
  801110:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801115:	b8 20 00 00 00       	mov    $0x20,%eax
  80111a:	89 ea                	mov    %ebp,%edx
  80111c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801120:	d3 e7                	shl    %cl,%edi
  801122:	89 c1                	mov    %eax,%ecx
  801124:	d3 ea                	shr    %cl,%edx
  801126:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80112b:	09 fa                	or     %edi,%edx
  80112d:	89 f7                	mov    %esi,%edi
  80112f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801133:	89 f2                	mov    %esi,%edx
  801135:	8b 74 24 08          	mov    0x8(%esp),%esi
  801139:	d3 e5                	shl    %cl,%ebp
  80113b:	89 c1                	mov    %eax,%ecx
  80113d:	d3 ef                	shr    %cl,%edi
  80113f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801144:	d3 e2                	shl    %cl,%edx
  801146:	89 c1                	mov    %eax,%ecx
  801148:	d3 ee                	shr    %cl,%esi
  80114a:	09 d6                	or     %edx,%esi
  80114c:	89 fa                	mov    %edi,%edx
  80114e:	89 f0                	mov    %esi,%eax
  801150:	f7 74 24 0c          	divl   0xc(%esp)
  801154:	89 d7                	mov    %edx,%edi
  801156:	89 c6                	mov    %eax,%esi
  801158:	f7 e5                	mul    %ebp
  80115a:	39 d7                	cmp    %edx,%edi
  80115c:	72 22                	jb     801180 <__udivdi3+0x110>
  80115e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801162:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801167:	d3 e5                	shl    %cl,%ebp
  801169:	39 c5                	cmp    %eax,%ebp
  80116b:	73 04                	jae    801171 <__udivdi3+0x101>
  80116d:	39 d7                	cmp    %edx,%edi
  80116f:	74 0f                	je     801180 <__udivdi3+0x110>
  801171:	89 f0                	mov    %esi,%eax
  801173:	31 d2                	xor    %edx,%edx
  801175:	e9 46 ff ff ff       	jmp    8010c0 <__udivdi3+0x50>
  80117a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801180:	8d 46 ff             	lea    -0x1(%esi),%eax
  801183:	31 d2                	xor    %edx,%edx
  801185:	8b 74 24 10          	mov    0x10(%esp),%esi
  801189:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80118d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801191:	83 c4 1c             	add    $0x1c,%esp
  801194:	c3                   	ret    
	...

008011a0 <__umoddi3>:
  8011a0:	83 ec 1c             	sub    $0x1c,%esp
  8011a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011bb:	85 ed                	test   %ebp,%ebp
  8011bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c5:	89 cf                	mov    %ecx,%edi
  8011c7:	89 04 24             	mov    %eax,(%esp)
  8011ca:	89 f2                	mov    %esi,%edx
  8011cc:	75 1a                	jne    8011e8 <__umoddi3+0x48>
  8011ce:	39 f1                	cmp    %esi,%ecx
  8011d0:	76 4e                	jbe    801220 <__umoddi3+0x80>
  8011d2:	f7 f1                	div    %ecx
  8011d4:	89 d0                	mov    %edx,%eax
  8011d6:	31 d2                	xor    %edx,%edx
  8011d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011e4:	83 c4 1c             	add    $0x1c,%esp
  8011e7:	c3                   	ret    
  8011e8:	39 f5                	cmp    %esi,%ebp
  8011ea:	77 54                	ja     801240 <__umoddi3+0xa0>
  8011ec:	0f bd c5             	bsr    %ebp,%eax
  8011ef:	83 f0 1f             	xor    $0x1f,%eax
  8011f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f6:	75 60                	jne    801258 <__umoddi3+0xb8>
  8011f8:	3b 0c 24             	cmp    (%esp),%ecx
  8011fb:	0f 87 07 01 00 00    	ja     801308 <__umoddi3+0x168>
  801201:	89 f2                	mov    %esi,%edx
  801203:	8b 34 24             	mov    (%esp),%esi
  801206:	29 ce                	sub    %ecx,%esi
  801208:	19 ea                	sbb    %ebp,%edx
  80120a:	89 34 24             	mov    %esi,(%esp)
  80120d:	8b 04 24             	mov    (%esp),%eax
  801210:	8b 74 24 10          	mov    0x10(%esp),%esi
  801214:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801218:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80121c:	83 c4 1c             	add    $0x1c,%esp
  80121f:	c3                   	ret    
  801220:	85 c9                	test   %ecx,%ecx
  801222:	75 0b                	jne    80122f <__umoddi3+0x8f>
  801224:	b8 01 00 00 00       	mov    $0x1,%eax
  801229:	31 d2                	xor    %edx,%edx
  80122b:	f7 f1                	div    %ecx
  80122d:	89 c1                	mov    %eax,%ecx
  80122f:	89 f0                	mov    %esi,%eax
  801231:	31 d2                	xor    %edx,%edx
  801233:	f7 f1                	div    %ecx
  801235:	8b 04 24             	mov    (%esp),%eax
  801238:	f7 f1                	div    %ecx
  80123a:	eb 98                	jmp    8011d4 <__umoddi3+0x34>
  80123c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801240:	89 f2                	mov    %esi,%edx
  801242:	8b 74 24 10          	mov    0x10(%esp),%esi
  801246:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80124a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80124e:	83 c4 1c             	add    $0x1c,%esp
  801251:	c3                   	ret    
  801252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801258:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80125d:	89 e8                	mov    %ebp,%eax
  80125f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801264:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801268:	89 fa                	mov    %edi,%edx
  80126a:	d3 e0                	shl    %cl,%eax
  80126c:	89 e9                	mov    %ebp,%ecx
  80126e:	d3 ea                	shr    %cl,%edx
  801270:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801275:	09 c2                	or     %eax,%edx
  801277:	8b 44 24 08          	mov    0x8(%esp),%eax
  80127b:	89 14 24             	mov    %edx,(%esp)
  80127e:	89 f2                	mov    %esi,%edx
  801280:	d3 e7                	shl    %cl,%edi
  801282:	89 e9                	mov    %ebp,%ecx
  801284:	d3 ea                	shr    %cl,%edx
  801286:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80128b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80128f:	d3 e6                	shl    %cl,%esi
  801291:	89 e9                	mov    %ebp,%ecx
  801293:	d3 e8                	shr    %cl,%eax
  801295:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80129a:	09 f0                	or     %esi,%eax
  80129c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012a0:	f7 34 24             	divl   (%esp)
  8012a3:	d3 e6                	shl    %cl,%esi
  8012a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012a9:	89 d6                	mov    %edx,%esi
  8012ab:	f7 e7                	mul    %edi
  8012ad:	39 d6                	cmp    %edx,%esi
  8012af:	89 c1                	mov    %eax,%ecx
  8012b1:	89 d7                	mov    %edx,%edi
  8012b3:	72 3f                	jb     8012f4 <__umoddi3+0x154>
  8012b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012b9:	72 35                	jb     8012f0 <__umoddi3+0x150>
  8012bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012bf:	29 c8                	sub    %ecx,%eax
  8012c1:	19 fe                	sbb    %edi,%esi
  8012c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012c8:	89 f2                	mov    %esi,%edx
  8012ca:	d3 e8                	shr    %cl,%eax
  8012cc:	89 e9                	mov    %ebp,%ecx
  8012ce:	d3 e2                	shl    %cl,%edx
  8012d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012d5:	09 d0                	or     %edx,%eax
  8012d7:	89 f2                	mov    %esi,%edx
  8012d9:	d3 ea                	shr    %cl,%edx
  8012db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012e7:	83 c4 1c             	add    $0x1c,%esp
  8012ea:	c3                   	ret    
  8012eb:	90                   	nop
  8012ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	39 d6                	cmp    %edx,%esi
  8012f2:	75 c7                	jne    8012bb <__umoddi3+0x11b>
  8012f4:	89 d7                	mov    %edx,%edi
  8012f6:	89 c1                	mov    %eax,%ecx
  8012f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012fc:	1b 3c 24             	sbb    (%esp),%edi
  8012ff:	eb ba                	jmp    8012bb <__umoddi3+0x11b>
  801301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801308:	39 f5                	cmp    %esi,%ebp
  80130a:	0f 82 f1 fe ff ff    	jb     801201 <__umoddi3+0x61>
  801310:	e9 f8 fe ff ff       	jmp    80120d <__umoddi3+0x6d>
