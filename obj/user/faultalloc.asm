
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800044:	c7 04 24 40 13 80 00 	movl   $0x801340,(%esp)
  80004b:	e8 13 02 00 00       	call   800263 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 0d 0d 00 00       	call   800d7c <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 60 13 80 	movl   $0x801360,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 4a 13 80 00 	movl   $0x80134a,(%esp)
  800092:	e8 d1 00 00 00       	call   800168 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 8c 13 80 	movl   $0x80138c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 51 07 00 00       	call   800804 <snprintf>
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
  8000c6:	e8 19 0f 00 00       	call   800fe4 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 5c 13 80 00 	movl   $0x80135c,(%esp)
  8000da:	e8 84 01 00 00       	call   800263 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 5c 13 80 00 	movl   $0x80135c,(%esp)
  8000ee:	e8 70 01 00 00       	call   800263 <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80010a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800111:	00 00 00 
	envid_t envid = sys_getenvid();
  800114:	e8 03 0c 00 00       	call   800d1c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  800119:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800121:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800126:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012b:	85 f6                	test   %esi,%esi
  80012d:	7e 07                	jle    800136 <libmain+0x3e>
		binaryname = argv[0];
  80012f:	8b 03                	mov    (%ebx),%eax
  800131:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800136:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013a:	89 34 24             	mov    %esi,(%esp)
  80013d:	e8 77 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800142:	e8 0d 00 00 00       	call   800154 <exit>
}
  800147:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80014a:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80014d:	89 ec                	mov    %ebp,%esp
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    
  800151:	00 00                	add    %al,(%eax)
	...

00800154 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800161:	e8 59 0b 00 00       	call   800cbf <sys_env_destroy>
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800170:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800173:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800179:	e8 9e 0b 00 00       	call   800d1c <sys_getenvid>
  80017e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800181:	89 54 24 10          	mov    %edx,0x10(%esp)
  800185:	8b 55 08             	mov    0x8(%ebp),%edx
  800188:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80018c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	c7 04 24 b8 13 80 00 	movl   $0x8013b8,(%esp)
  80019b:	e8 c3 00 00 00       	call   800263 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 53 00 00 00       	call   800202 <vcprintf>
	cprintf("\n");
  8001af:	c7 04 24 5e 13 80 00 	movl   $0x80135e,(%esp)
  8001b6:	e8 a8 00 00 00       	call   800263 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bb:	cc                   	int3   
  8001bc:	eb fd                	jmp    8001bb <_panic+0x53>
	...

008001c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 14             	sub    $0x14,%esp
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ca:	8b 03                	mov    (%ebx),%eax
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d3:	83 c0 01             	add    $0x1,%eax
  8001d6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001dd:	75 19                	jne    8001f8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001df:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e6:	00 
  8001e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ea:	89 04 24             	mov    %eax,(%esp)
  8001ed:	e8 6e 0a 00 00       	call   800c60 <sys_cputs>
		b->idx = 0;
  8001f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    

00800202 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800212:	00 00 00 
	b.cnt = 0;
  800215:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800222:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800233:	89 44 24 04          	mov    %eax,0x4(%esp)
  800237:	c7 04 24 c0 01 80 00 	movl   $0x8001c0,(%esp)
  80023e:	e8 d1 01 00 00       	call   800414 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800243:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800253:	89 04 24             	mov    %eax,(%esp)
  800256:	e8 05 0a 00 00       	call   800c60 <sys_cputs>

	return b.cnt;
}
  80025b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800269:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800270:	8b 45 08             	mov    0x8(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	e8 87 ff ff ff       	call   800202 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    
  80027d:	00 00                	add    %al,(%eax)
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002a5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002a8:	72 11                	jb     8002bb <printnum+0x3b>
  8002aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ad:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b0:	76 09                	jbe    8002bb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f 51                	jg     80030a <printnum+0x8a>
  8002b9:	eb 5e                	jmp    800319 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002bf:	83 eb 01             	sub    $0x1,%ebx
  8002c2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002d1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002dc:	00 
  8002dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ea:	e8 91 0d 00 00       	call   801080 <__udivdi3>
  8002ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002f7:	89 04 24             	mov    %eax,(%esp)
  8002fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fe:	89 fa                	mov    %edi,%edx
  800300:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800303:	e8 78 ff ff ff       	call   800280 <printnum>
  800308:	eb 0f                	jmp    800319 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030e:	89 34 24             	mov    %esi,(%esp)
  800311:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800314:	83 eb 01             	sub    $0x1,%ebx
  800317:	75 f1                	jne    80030a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800319:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800321:	8b 45 10             	mov    0x10(%ebp),%eax
  800324:	89 44 24 08          	mov    %eax,0x8(%esp)
  800328:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032f:	00 
  800330:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800333:	89 04 24             	mov    %eax,(%esp)
  800336:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033d:	e8 6e 0e 00 00       	call   8011b0 <__umoddi3>
  800342:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800346:	0f be 80 dc 13 80 00 	movsbl 0x8013dc(%eax),%eax
  80034d:	89 04 24             	mov    %eax,(%esp)
  800350:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800353:	83 c4 3c             	add    $0x3c,%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80035e:	83 fa 01             	cmp    $0x1,%edx
  800361:	7e 0e                	jle    800371 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800363:	8b 10                	mov    (%eax),%edx
  800365:	8d 4a 08             	lea    0x8(%edx),%ecx
  800368:	89 08                	mov    %ecx,(%eax)
  80036a:	8b 02                	mov    (%edx),%eax
  80036c:	8b 52 04             	mov    0x4(%edx),%edx
  80036f:	eb 22                	jmp    800393 <getuint+0x38>
	else if (lflag)
  800371:	85 d2                	test   %edx,%edx
  800373:	74 10                	je     800385 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800375:	8b 10                	mov    (%eax),%edx
  800377:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037a:	89 08                	mov    %ecx,(%eax)
  80037c:	8b 02                	mov    (%edx),%eax
  80037e:	ba 00 00 00 00       	mov    $0x0,%edx
  800383:	eb 0e                	jmp    800393 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800385:	8b 10                	mov    (%eax),%edx
  800387:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038a:	89 08                	mov    %ecx,(%eax)
  80038c:	8b 02                	mov    (%edx),%eax
  80038e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800398:	83 fa 01             	cmp    $0x1,%edx
  80039b:	7e 0e                	jle    8003ab <getint+0x16>
		return va_arg(*ap, long long);
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 02                	mov    (%edx),%eax
  8003a6:	8b 52 04             	mov    0x4(%edx),%edx
  8003a9:	eb 22                	jmp    8003cd <getint+0x38>
	else if (lflag)
  8003ab:	85 d2                	test   %edx,%edx
  8003ad:	74 10                	je     8003bf <getint+0x2a>
		return va_arg(*ap, long);
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b4:	89 08                	mov    %ecx,(%eax)
  8003b6:	8b 02                	mov    (%edx),%eax
  8003b8:	89 c2                	mov    %eax,%edx
  8003ba:	c1 fa 1f             	sar    $0x1f,%edx
  8003bd:	eb 0e                	jmp    8003cd <getint+0x38>
	else
		return va_arg(*ap, int);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	3b 50 04             	cmp    0x4(%eax),%edx
  8003de:	73 0a                	jae    8003ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	88 0a                	mov    %cl,(%edx)
  8003e5:	83 c2 01             	add    $0x1,%edx
  8003e8:	89 10                	mov    %edx,(%eax)
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800400:	8b 45 0c             	mov    0xc(%ebp),%eax
  800403:	89 44 24 04          	mov    %eax,0x4(%esp)
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	89 04 24             	mov    %eax,(%esp)
  80040d:	e8 02 00 00 00       	call   800414 <vprintfmt>
	va_end(ap);
}
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	57                   	push   %edi
  800418:	56                   	push   %esi
  800419:	53                   	push   %ebx
  80041a:	83 ec 4c             	sub    $0x4c,%esp
  80041d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800420:	8b 75 10             	mov    0x10(%ebp),%esi
  800423:	eb 12                	jmp    800437 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800425:	85 c0                	test   %eax,%eax
  800427:	0f 84 77 03 00 00    	je     8007a4 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  80042d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800431:	89 04 24             	mov    %eax,(%esp)
  800434:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800437:	0f b6 06             	movzbl (%esi),%eax
  80043a:	83 c6 01             	add    $0x1,%esi
  80043d:	83 f8 25             	cmp    $0x25,%eax
  800440:	75 e3                	jne    800425 <vprintfmt+0x11>
  800442:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800446:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80044d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800452:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800459:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800461:	eb 2b                	jmp    80048e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800466:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80046a:	eb 22                	jmp    80048e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80046f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800473:	eb 19                	jmp    80048e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800478:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80047f:	eb 0d                	jmp    80048e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800481:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800487:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	0f b6 06             	movzbl (%esi),%eax
  800491:	0f b6 d0             	movzbl %al,%edx
  800494:	8d 7e 01             	lea    0x1(%esi),%edi
  800497:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80049a:	83 e8 23             	sub    $0x23,%eax
  80049d:	3c 55                	cmp    $0x55,%al
  80049f:	0f 87 d9 02 00 00    	ja     80077e <vprintfmt+0x36a>
  8004a5:	0f b6 c0             	movzbl %al,%eax
  8004a8:	ff 24 85 a0 14 80 00 	jmp    *0x8014a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004af:	83 ea 30             	sub    $0x30,%edx
  8004b2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004b5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004b9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004bf:	83 fa 09             	cmp    $0x9,%edx
  8004c2:	77 4a                	ja     80050e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004ca:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004cd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004d1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004d4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d7:	83 fa 09             	cmp    $0x9,%edx
  8004da:	76 eb                	jbe    8004c7 <vprintfmt+0xb3>
  8004dc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004df:	eb 2d                	jmp    80050e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 50 04             	lea    0x4(%eax),%edx
  8004e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f2:	eb 1a                	jmp    80050e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004fb:	79 91                	jns    80048e <vprintfmt+0x7a>
  8004fd:	e9 73 ff ff ff       	jmp    800475 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800505:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80050c:	eb 80                	jmp    80048e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80050e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800512:	0f 89 76 ff ff ff    	jns    80048e <vprintfmt+0x7a>
  800518:	e9 64 ff ff ff       	jmp    800481 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800520:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800523:	e9 66 ff ff ff       	jmp    80048e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800535:	8b 00                	mov    (%eax),%eax
  800537:	89 04 24             	mov    %eax,(%esp)
  80053a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800540:	e9 f2 fe ff ff       	jmp    800437 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 c2                	mov    %eax,%edx
  800552:	c1 fa 1f             	sar    $0x1f,%edx
  800555:	31 d0                	xor    %edx,%eax
  800557:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800559:	83 f8 08             	cmp    $0x8,%eax
  80055c:	7f 0b                	jg     800569 <vprintfmt+0x155>
  80055e:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800565:	85 d2                	test   %edx,%edx
  800567:	75 23                	jne    80058c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800569:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056d:	c7 44 24 08 f4 13 80 	movl   $0x8013f4,0x8(%esp)
  800574:	00 
  800575:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800579:	8b 7d 08             	mov    0x8(%ebp),%edi
  80057c:	89 3c 24             	mov    %edi,(%esp)
  80057f:	e8 68 fe ff ff       	call   8003ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800587:	e9 ab fe ff ff       	jmp    800437 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80058c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800590:	c7 44 24 08 fd 13 80 	movl   $0x8013fd,0x8(%esp)
  800597:	00 
  800598:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059f:	89 3c 24             	mov    %edi,(%esp)
  8005a2:	e8 45 fe ff ff       	call   8003ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005aa:	e9 88 fe ff ff       	jmp    800437 <vprintfmt+0x23>
  8005af:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005c3:	85 f6                	test   %esi,%esi
  8005c5:	ba ed 13 80 00       	mov    $0x8013ed,%edx
  8005ca:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005cd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d1:	7e 06                	jle    8005d9 <vprintfmt+0x1c5>
  8005d3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005d7:	75 10                	jne    8005e9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d9:	0f be 06             	movsbl (%esi),%eax
  8005dc:	83 c6 01             	add    $0x1,%esi
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	0f 85 86 00 00 00    	jne    80066d <vprintfmt+0x259>
  8005e7:	eb 76                	jmp    80065f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ed:	89 34 24             	mov    %esi,(%esp)
  8005f0:	e8 56 02 00 00       	call   80084b <strnlen>
  8005f5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005f8:	29 c2                	sub    %eax,%edx
  8005fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005fd:	85 d2                	test   %edx,%edx
  8005ff:	7e d8                	jle    8005d9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800601:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800605:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800608:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80060b:	89 d6                	mov    %edx,%esi
  80060d:	89 c7                	mov    %eax,%edi
  80060f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800613:	89 3c 24             	mov    %edi,(%esp)
  800616:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800619:	83 ee 01             	sub    $0x1,%esi
  80061c:	75 f1                	jne    80060f <vprintfmt+0x1fb>
  80061e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800621:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800624:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800627:	eb b0                	jmp    8005d9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800629:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062d:	74 18                	je     800647 <vprintfmt+0x233>
  80062f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800632:	83 fa 5e             	cmp    $0x5e,%edx
  800635:	76 10                	jbe    800647 <vprintfmt+0x233>
					putch('?', putdat);
  800637:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	eb 0a                	jmp    800651 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800647:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064b:	89 04 24             	mov    %eax,(%esp)
  80064e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800651:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800655:	0f be 06             	movsbl (%esi),%eax
  800658:	83 c6 01             	add    $0x1,%esi
  80065b:	85 c0                	test   %eax,%eax
  80065d:	75 0e                	jne    80066d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800662:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800666:	7f 11                	jg     800679 <vprintfmt+0x265>
  800668:	e9 ca fd ff ff       	jmp    800437 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066d:	85 ff                	test   %edi,%edi
  80066f:	90                   	nop
  800670:	78 b7                	js     800629 <vprintfmt+0x215>
  800672:	83 ef 01             	sub    $0x1,%edi
  800675:	79 b2                	jns    800629 <vprintfmt+0x215>
  800677:	eb e6                	jmp    80065f <vprintfmt+0x24b>
  800679:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80067c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800683:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80068a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068c:	83 ee 01             	sub    $0x1,%esi
  80068f:	75 ee                	jne    80067f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800694:	e9 9e fd ff ff       	jmp    800437 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800699:	89 ca                	mov    %ecx,%edx
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 f2 fc ff ff       	call   800395 <getint>
  8006a3:	89 c6                	mov    %eax,%esi
  8006a5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ac:	85 d2                	test   %edx,%edx
  8006ae:	0f 89 8c 00 00 00    	jns    800740 <vprintfmt+0x32c>
				putch('-', putdat);
  8006b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006bf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006c2:	f7 de                	neg    %esi
  8006c4:	83 d7 00             	adc    $0x0,%edi
  8006c7:	f7 df                	neg    %edi
			}
			base = 10;
  8006c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ce:	eb 70                	jmp    800740 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d0:	89 ca                	mov    %ecx,%edx
  8006d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d5:	e8 81 fc ff ff       	call   80035b <getuint>
  8006da:	89 c6                	mov    %eax,%esi
  8006dc:	89 d7                	mov    %edx,%edi
			base = 10;
  8006de:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006e3:	eb 5b                	jmp    800740 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  8006e5:	89 ca                	mov    %ecx,%edx
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ea:	e8 a6 fc ff ff       	call   800395 <getint>
  8006ef:	89 c6                	mov    %eax,%esi
  8006f1:	89 d7                	mov    %edx,%edi
			base = 8;
  8006f3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006f8:	eb 46                	jmp    800740 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fe:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800705:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800708:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 50 04             	lea    0x4(%eax),%edx
  80071c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071f:	8b 30                	mov    (%eax),%esi
  800721:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800726:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80072b:	eb 13                	jmp    800740 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072d:	89 ca                	mov    %ecx,%edx
  80072f:	8d 45 14             	lea    0x14(%ebp),%eax
  800732:	e8 24 fc ff ff       	call   80035b <getuint>
  800737:	89 c6                	mov    %eax,%esi
  800739:	89 d7                	mov    %edx,%edi
			base = 16;
  80073b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800740:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800744:	89 54 24 10          	mov    %edx,0x10(%esp)
  800748:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80074b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800753:	89 34 24             	mov    %esi,(%esp)
  800756:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075a:	89 da                	mov    %ebx,%edx
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	e8 1c fb ff ff       	call   800280 <printnum>
			break;
  800764:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800767:	e9 cb fc ff ff       	jmp    800437 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800770:	89 14 24             	mov    %edx,(%esp)
  800773:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800779:	e9 b9 fc ff ff       	jmp    800437 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800782:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800789:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80078c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800790:	0f 84 a1 fc ff ff    	je     800437 <vprintfmt+0x23>
  800796:	83 ee 01             	sub    $0x1,%esi
  800799:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80079d:	75 f7                	jne    800796 <vprintfmt+0x382>
  80079f:	e9 93 fc ff ff       	jmp    800437 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007a4:	83 c4 4c             	add    $0x4c,%esp
  8007a7:	5b                   	pop    %ebx
  8007a8:	5e                   	pop    %esi
  8007a9:	5f                   	pop    %edi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 28             	sub    $0x28,%esp
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007bf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	74 30                	je     8007fd <vsnprintf+0x51>
  8007cd:	85 d2                	test   %edx,%edx
  8007cf:	7e 2c                	jle    8007fd <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007df:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e6:	c7 04 24 cf 03 80 00 	movl   $0x8003cf,(%esp)
  8007ed:	e8 22 fc ff ff       	call   800414 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fb:	eb 05                	jmp    800802 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800802:	c9                   	leave  
  800803:	c3                   	ret    

00800804 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800811:	8b 45 10             	mov    0x10(%ebp),%eax
  800814:	89 44 24 08          	mov    %eax,0x8(%esp)
  800818:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	89 04 24             	mov    %eax,(%esp)
  800825:	e8 82 ff ff ff       	call   8007ac <vsnprintf>
	va_end(ap);

	return rc;
}
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    
  80082c:	00 00                	add    %al,(%eax)
	...

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	80 3a 00             	cmpb   $0x0,(%edx)
  80083e:	74 09                	je     800849 <strlen+0x19>
		n++;
  800840:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800847:	75 f7                	jne    800840 <strlen+0x10>
		n++;
	return n;
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
  80085a:	85 c9                	test   %ecx,%ecx
  80085c:	74 1a                	je     800878 <strnlen+0x2d>
  80085e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800861:	74 15                	je     800878 <strnlen+0x2d>
  800863:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800868:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086a:	39 ca                	cmp    %ecx,%edx
  80086c:	74 0a                	je     800878 <strnlen+0x2d>
  80086e:	83 c2 01             	add    $0x1,%edx
  800871:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800876:	75 f0                	jne    800868 <strnlen+0x1d>
		n++;
	return n;
}
  800878:	5b                   	pop    %ebx
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800885:	ba 00 00 00 00       	mov    $0x0,%edx
  80088a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80088e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800891:	83 c2 01             	add    $0x1,%edx
  800894:	84 c9                	test   %cl,%cl
  800896:	75 f2                	jne    80088a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a5:	89 1c 24             	mov    %ebx,(%esp)
  8008a8:	e8 83 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b4:	01 d8                	add    %ebx,%eax
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	e8 bd ff ff ff       	call   80087b <strcpy>
	return dst;
}
  8008be:	89 d8                	mov    %ebx,%eax
  8008c0:	83 c4 08             	add    $0x8,%esp
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d4:	85 f6                	test   %esi,%esi
  8008d6:	74 18                	je     8008f0 <strncpy+0x2a>
  8008d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008dd:	0f b6 1a             	movzbl (%edx),%ebx
  8008e0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008e6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e9:	83 c1 01             	add    $0x1,%ecx
  8008ec:	39 f1                	cmp    %esi,%ecx
  8008ee:	75 ed                	jne    8008dd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f0:	5b                   	pop    %ebx
  8008f1:	5e                   	pop    %esi
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	57                   	push   %edi
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800900:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800903:	89 f8                	mov    %edi,%eax
  800905:	85 f6                	test   %esi,%esi
  800907:	74 2b                	je     800934 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800909:	83 fe 01             	cmp    $0x1,%esi
  80090c:	74 23                	je     800931 <strlcpy+0x3d>
  80090e:	0f b6 0b             	movzbl (%ebx),%ecx
  800911:	84 c9                	test   %cl,%cl
  800913:	74 1c                	je     800931 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800915:	83 ee 02             	sub    $0x2,%esi
  800918:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091d:	88 08                	mov    %cl,(%eax)
  80091f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800922:	39 f2                	cmp    %esi,%edx
  800924:	74 0b                	je     800931 <strlcpy+0x3d>
  800926:	83 c2 01             	add    $0x1,%edx
  800929:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80092d:	84 c9                	test   %cl,%cl
  80092f:	75 ec                	jne    80091d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800931:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800934:	29 f8                	sub    %edi,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5f                   	pop    %edi
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800944:	0f b6 01             	movzbl (%ecx),%eax
  800947:	84 c0                	test   %al,%al
  800949:	74 16                	je     800961 <strcmp+0x26>
  80094b:	3a 02                	cmp    (%edx),%al
  80094d:	75 12                	jne    800961 <strcmp+0x26>
		p++, q++;
  80094f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800952:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800956:	84 c0                	test   %al,%al
  800958:	74 07                	je     800961 <strcmp+0x26>
  80095a:	83 c1 01             	add    $0x1,%ecx
  80095d:	3a 02                	cmp    (%edx),%al
  80095f:	74 ee                	je     80094f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800961:	0f b6 c0             	movzbl %al,%eax
  800964:	0f b6 12             	movzbl (%edx),%edx
  800967:	29 d0                	sub    %edx,%eax
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800972:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800975:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097d:	85 d2                	test   %edx,%edx
  80097f:	74 28                	je     8009a9 <strncmp+0x3e>
  800981:	0f b6 01             	movzbl (%ecx),%eax
  800984:	84 c0                	test   %al,%al
  800986:	74 24                	je     8009ac <strncmp+0x41>
  800988:	3a 03                	cmp    (%ebx),%al
  80098a:	75 20                	jne    8009ac <strncmp+0x41>
  80098c:	83 ea 01             	sub    $0x1,%edx
  80098f:	74 13                	je     8009a4 <strncmp+0x39>
		n--, p++, q++;
  800991:	83 c1 01             	add    $0x1,%ecx
  800994:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800997:	0f b6 01             	movzbl (%ecx),%eax
  80099a:	84 c0                	test   %al,%al
  80099c:	74 0e                	je     8009ac <strncmp+0x41>
  80099e:	3a 03                	cmp    (%ebx),%al
  8009a0:	74 ea                	je     80098c <strncmp+0x21>
  8009a2:	eb 08                	jmp    8009ac <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a9:	5b                   	pop    %ebx
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ac:	0f b6 01             	movzbl (%ecx),%eax
  8009af:	0f b6 13             	movzbl (%ebx),%edx
  8009b2:	29 d0                	sub    %edx,%eax
  8009b4:	eb f3                	jmp    8009a9 <strncmp+0x3e>

008009b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c0:	0f b6 10             	movzbl (%eax),%edx
  8009c3:	84 d2                	test   %dl,%dl
  8009c5:	74 1c                	je     8009e3 <strchr+0x2d>
		if (*s == c)
  8009c7:	38 ca                	cmp    %cl,%dl
  8009c9:	75 09                	jne    8009d4 <strchr+0x1e>
  8009cb:	eb 1b                	jmp    8009e8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009cd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8009d0:	38 ca                	cmp    %cl,%dl
  8009d2:	74 14                	je     8009e8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	75 f1                	jne    8009cd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e1:	eb 05                	jmp    8009e8 <strchr+0x32>
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f4:	0f b6 10             	movzbl (%eax),%edx
  8009f7:	84 d2                	test   %dl,%dl
  8009f9:	74 14                	je     800a0f <strfind+0x25>
		if (*s == c)
  8009fb:	38 ca                	cmp    %cl,%dl
  8009fd:	75 06                	jne    800a05 <strfind+0x1b>
  8009ff:	eb 0e                	jmp    800a0f <strfind+0x25>
  800a01:	38 ca                	cmp    %cl,%dl
  800a03:	74 0a                	je     800a0f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a05:	83 c0 01             	add    $0x1,%eax
  800a08:	0f b6 10             	movzbl (%eax),%edx
  800a0b:	84 d2                	test   %dl,%dl
  800a0d:	75 f2                	jne    800a01 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a1a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a1d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a29:	85 c9                	test   %ecx,%ecx
  800a2b:	74 30                	je     800a5d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a33:	75 25                	jne    800a5a <memset+0x49>
  800a35:	f6 c1 03             	test   $0x3,%cl
  800a38:	75 20                	jne    800a5a <memset+0x49>
		c &= 0xFF;
  800a3a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a3d:	89 d3                	mov    %edx,%ebx
  800a3f:	c1 e3 08             	shl    $0x8,%ebx
  800a42:	89 d6                	mov    %edx,%esi
  800a44:	c1 e6 18             	shl    $0x18,%esi
  800a47:	89 d0                	mov    %edx,%eax
  800a49:	c1 e0 10             	shl    $0x10,%eax
  800a4c:	09 f0                	or     %esi,%eax
  800a4e:	09 d0                	or     %edx,%eax
  800a50:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a52:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a55:	fc                   	cld    
  800a56:	f3 ab                	rep stos %eax,%es:(%edi)
  800a58:	eb 03                	jmp    800a5d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a5a:	fc                   	cld    
  800a5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a5d:	89 f8                	mov    %edi,%eax
  800a5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a68:	89 ec                	mov    %ebp,%esp
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 08             	sub    $0x8,%esp
  800a72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a75:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a81:	39 c6                	cmp    %eax,%esi
  800a83:	73 36                	jae    800abb <memmove+0x4f>
  800a85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a88:	39 d0                	cmp    %edx,%eax
  800a8a:	73 2f                	jae    800abb <memmove+0x4f>
		s += n;
		d += n;
  800a8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8f:	f6 c2 03             	test   $0x3,%dl
  800a92:	75 1b                	jne    800aaf <memmove+0x43>
  800a94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9a:	75 13                	jne    800aaf <memmove+0x43>
  800a9c:	f6 c1 03             	test   $0x3,%cl
  800a9f:	75 0e                	jne    800aaf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa1:	83 ef 04             	sub    $0x4,%edi
  800aa4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aaa:	fd                   	std    
  800aab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aad:	eb 09                	jmp    800ab8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aaf:	83 ef 01             	sub    $0x1,%edi
  800ab2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ab5:	fd                   	std    
  800ab6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab8:	fc                   	cld    
  800ab9:	eb 20                	jmp    800adb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ac1:	75 13                	jne    800ad6 <memmove+0x6a>
  800ac3:	a8 03                	test   $0x3,%al
  800ac5:	75 0f                	jne    800ad6 <memmove+0x6a>
  800ac7:	f6 c1 03             	test   $0x3,%cl
  800aca:	75 0a                	jne    800ad6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800acc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800acf:	89 c7                	mov    %eax,%edi
  800ad1:	fc                   	cld    
  800ad2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad4:	eb 05                	jmp    800adb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad6:	89 c7                	mov    %eax,%edi
  800ad8:	fc                   	cld    
  800ad9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800adb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ade:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ae1:	89 ec                	mov    %ebp,%esp
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aeb:	8b 45 10             	mov    0x10(%ebp),%eax
  800aee:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	89 04 24             	mov    %eax,(%esp)
  800aff:	e8 68 ff ff ff       	call   800a6c <memmove>
}
  800b04:	c9                   	leave  
  800b05:	c3                   	ret    

00800b06 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b12:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1a:	85 ff                	test   %edi,%edi
  800b1c:	74 37                	je     800b55 <memcmp+0x4f>
		if (*s1 != *s2)
  800b1e:	0f b6 03             	movzbl (%ebx),%eax
  800b21:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b24:	83 ef 01             	sub    $0x1,%edi
  800b27:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b2c:	38 c8                	cmp    %cl,%al
  800b2e:	74 1c                	je     800b4c <memcmp+0x46>
  800b30:	eb 10                	jmp    800b42 <memcmp+0x3c>
  800b32:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b37:	83 c2 01             	add    $0x1,%edx
  800b3a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b3e:	38 c8                	cmp    %cl,%al
  800b40:	74 0a                	je     800b4c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800b42:	0f b6 c0             	movzbl %al,%eax
  800b45:	0f b6 c9             	movzbl %cl,%ecx
  800b48:	29 c8                	sub    %ecx,%eax
  800b4a:	eb 09                	jmp    800b55 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4c:	39 fa                	cmp    %edi,%edx
  800b4e:	75 e2                	jne    800b32 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b60:	89 c2                	mov    %eax,%edx
  800b62:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b65:	39 d0                	cmp    %edx,%eax
  800b67:	73 19                	jae    800b82 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b69:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b6d:	38 08                	cmp    %cl,(%eax)
  800b6f:	75 06                	jne    800b77 <memfind+0x1d>
  800b71:	eb 0f                	jmp    800b82 <memfind+0x28>
  800b73:	38 08                	cmp    %cl,(%eax)
  800b75:	74 0b                	je     800b82 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b77:	83 c0 01             	add    $0x1,%eax
  800b7a:	39 d0                	cmp    %edx,%eax
  800b7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b80:	75 f1                	jne    800b73 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b90:	0f b6 02             	movzbl (%edx),%eax
  800b93:	3c 20                	cmp    $0x20,%al
  800b95:	74 04                	je     800b9b <strtol+0x17>
  800b97:	3c 09                	cmp    $0x9,%al
  800b99:	75 0e                	jne    800ba9 <strtol+0x25>
		s++;
  800b9b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9e:	0f b6 02             	movzbl (%edx),%eax
  800ba1:	3c 20                	cmp    $0x20,%al
  800ba3:	74 f6                	je     800b9b <strtol+0x17>
  800ba5:	3c 09                	cmp    $0x9,%al
  800ba7:	74 f2                	je     800b9b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba9:	3c 2b                	cmp    $0x2b,%al
  800bab:	75 0a                	jne    800bb7 <strtol+0x33>
		s++;
  800bad:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb5:	eb 10                	jmp    800bc7 <strtol+0x43>
  800bb7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bbc:	3c 2d                	cmp    $0x2d,%al
  800bbe:	75 07                	jne    800bc7 <strtol+0x43>
		s++, neg = 1;
  800bc0:	83 c2 01             	add    $0x1,%edx
  800bc3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc7:	85 db                	test   %ebx,%ebx
  800bc9:	0f 94 c0             	sete   %al
  800bcc:	74 05                	je     800bd3 <strtol+0x4f>
  800bce:	83 fb 10             	cmp    $0x10,%ebx
  800bd1:	75 15                	jne    800be8 <strtol+0x64>
  800bd3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bd6:	75 10                	jne    800be8 <strtol+0x64>
  800bd8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bdc:	75 0a                	jne    800be8 <strtol+0x64>
		s += 2, base = 16;
  800bde:	83 c2 02             	add    $0x2,%edx
  800be1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be6:	eb 13                	jmp    800bfb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800be8:	84 c0                	test   %al,%al
  800bea:	74 0f                	je     800bfb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bec:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf1:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf4:	75 05                	jne    800bfb <strtol+0x77>
		s++, base = 8;
  800bf6:	83 c2 01             	add    $0x1,%edx
  800bf9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800c00:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c02:	0f b6 0a             	movzbl (%edx),%ecx
  800c05:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c08:	80 fb 09             	cmp    $0x9,%bl
  800c0b:	77 08                	ja     800c15 <strtol+0x91>
			dig = *s - '0';
  800c0d:	0f be c9             	movsbl %cl,%ecx
  800c10:	83 e9 30             	sub    $0x30,%ecx
  800c13:	eb 1e                	jmp    800c33 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c15:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c18:	80 fb 19             	cmp    $0x19,%bl
  800c1b:	77 08                	ja     800c25 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c1d:	0f be c9             	movsbl %cl,%ecx
  800c20:	83 e9 57             	sub    $0x57,%ecx
  800c23:	eb 0e                	jmp    800c33 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c25:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c28:	80 fb 19             	cmp    $0x19,%bl
  800c2b:	77 14                	ja     800c41 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c2d:	0f be c9             	movsbl %cl,%ecx
  800c30:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c33:	39 f1                	cmp    %esi,%ecx
  800c35:	7d 0e                	jge    800c45 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c37:	83 c2 01             	add    $0x1,%edx
  800c3a:	0f af c6             	imul   %esi,%eax
  800c3d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c3f:	eb c1                	jmp    800c02 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c41:	89 c1                	mov    %eax,%ecx
  800c43:	eb 02                	jmp    800c47 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c45:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4b:	74 05                	je     800c52 <strtol+0xce>
		*endptr = (char *) s;
  800c4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c50:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c52:	89 ca                	mov    %ecx,%edx
  800c54:	f7 da                	neg    %edx
  800c56:	85 ff                	test   %edi,%edi
  800c58:	0f 45 c2             	cmovne %edx,%eax
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c69:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	89 c3                	mov    %eax,%ebx
  800c7c:	89 c7                	mov    %eax,%edi
  800c7e:	89 c6                	mov    %eax,%esi
  800c80:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c8b:	89 ec                	mov    %ebp,%esp
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca8:	89 d1                	mov    %edx,%ecx
  800caa:	89 d3                	mov    %edx,%ebx
  800cac:	89 d7                	mov    %edx,%edi
  800cae:	89 d6                	mov    %edx,%esi
  800cb0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cbb:	89 ec                	mov    %ebp,%esp
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 38             	sub    $0x38,%esp
  800cc5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ccb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 cb                	mov    %ecx,%ebx
  800cdd:	89 cf                	mov    %ecx,%edi
  800cdf:	89 ce                	mov    %ecx,%esi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 28                	jle    800d0f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ceb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800cfa:	00 
  800cfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d02:	00 
  800d03:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800d0a:	e8 59 f4 ff ff       	call   800168 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d18:	89 ec                	mov    %ebp,%esp
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 0c             	sub    $0xc,%esp
  800d22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d28:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d30:	b8 02 00 00 00       	mov    $0x2,%eax
  800d35:	89 d1                	mov    %edx,%ecx
  800d37:	89 d3                	mov    %edx,%ebx
  800d39:	89 d7                	mov    %edx,%edi
  800d3b:	89 d6                	mov    %edx,%esi
  800d3d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d48:	89 ec                	mov    %ebp,%esp
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_yield>:

void
sys_yield(void)
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
  800d60:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	89 d3                	mov    %edx,%ebx
  800d69:	89 d7                	mov    %edx,%edi
  800d6b:	89 d6                	mov    %edx,%esi
  800d6d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d78:	89 ec                	mov    %ebp,%esp
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 38             	sub    $0x38,%esp
  800d82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d88:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	be 00 00 00 00       	mov    $0x0,%esi
  800d90:	b8 04 00 00 00       	mov    $0x4,%eax
  800d95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	89 f7                	mov    %esi,%edi
  800da0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da2:	85 c0                	test   %eax,%eax
  800da4:	7e 28                	jle    800dce <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800daa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800db1:	00 
  800db2:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800db9:	00 
  800dba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc1:	00 
  800dc2:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800dc9:	e8 9a f3 ff ff       	call   800168 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd7:	89 ec                	mov    %ebp,%esp
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 38             	sub    $0x38,%esp
  800de1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	b8 05 00 00 00       	mov    $0x5,%eax
  800def:	8b 75 18             	mov    0x18(%ebp),%esi
  800df2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e00:	85 c0                	test   %eax,%eax
  800e02:	7e 28                	jle    800e2c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e04:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e08:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e0f:	00 
  800e10:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e17:	00 
  800e18:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1f:	00 
  800e20:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e27:	e8 3c f3 ff ff       	call   800168 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e2c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e2f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e32:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e35:	89 ec                	mov    %ebp,%esp
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	83 ec 38             	sub    $0x38,%esp
  800e3f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e42:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e45:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	89 df                	mov    %ebx,%edi
  800e5a:	89 de                	mov    %ebx,%esi
  800e5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	7e 28                	jle    800e8a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e62:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e66:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e6d:	00 
  800e6e:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e75:	00 
  800e76:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7d:	00 
  800e7e:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e85:	e8 de f2 ff ff       	call   800168 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e8a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e8d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e90:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e93:	89 ec                	mov    %ebp,%esp
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	83 ec 38             	sub    $0x38,%esp
  800e9d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eab:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb6:	89 df                	mov    %ebx,%edi
  800eb8:	89 de                	mov    %ebx,%esi
  800eba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	7e 28                	jle    800ee8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ecb:	00 
  800ecc:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800ed3:	00 
  800ed4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edb:	00 
  800edc:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800ee3:	e8 80 f2 ff ff       	call   800168 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ee8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eeb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef1:	89 ec                	mov    %ebp,%esp
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 38             	sub    $0x38,%esp
  800efb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800efe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f01:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f09:	b8 09 00 00 00       	mov    $0x9,%eax
  800f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 df                	mov    %ebx,%edi
  800f16:	89 de                	mov    %ebx,%esi
  800f18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	7e 28                	jle    800f46 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f22:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f29:	00 
  800f2a:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800f31:	00 
  800f32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f39:	00 
  800f3a:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800f41:	e8 22 f2 ff ff       	call   800168 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f46:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f49:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f4c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f4f:	89 ec                	mov    %ebp,%esp
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    

00800f53 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 0c             	sub    $0xc,%esp
  800f59:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f5f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f62:	be 00 00 00 00       	mov    $0x0,%esi
  800f67:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f6c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f75:	8b 55 08             	mov    0x8(%ebp),%edx
  800f78:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f7a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f83:	89 ec                	mov    %ebp,%esp
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 38             	sub    $0x38,%esp
  800f8d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f90:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f93:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa3:	89 cb                	mov    %ecx,%ebx
  800fa5:	89 cf                	mov    %ecx,%edi
  800fa7:	89 ce                	mov    %ecx,%esi
  800fa9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	7e 28                	jle    800fd7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fba:	00 
  800fbb:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fca:	00 
  800fcb:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800fd2:	e8 91 f1 ff ff       	call   800168 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fd7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fdd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe0:	89 ec                	mov    %ebp,%esp
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fea:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ff1:	75 50                	jne    801043 <set_pgfault_handler+0x5f>
		// First time through!
		// LAB 4: Your code here.
		int error = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P);
  800ff3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801002:	ee 
  801003:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100a:	e8 6d fd ff ff       	call   800d7c <sys_page_alloc>
        if (error) {
  80100f:	85 c0                	test   %eax,%eax
  801011:	74 1c                	je     80102f <set_pgfault_handler+0x4b>
            panic("No physical memory available!");
  801013:	c7 44 24 08 4f 16 80 	movl   $0x80164f,0x8(%esp)
  80101a:	00 
  80101b:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801022:	00 
  801023:	c7 04 24 6d 16 80 00 	movl   $0x80166d,(%esp)
  80102a:	e8 39 f1 ff ff       	call   800168 <_panic>
        }

		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80102f:	c7 44 24 04 50 10 80 	movl   $0x801050,0x4(%esp)
  801036:	00 
  801037:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103e:	e8 b2 fe ff ff       	call   800ef5 <sys_env_set_pgfault_upcall>
		
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    
  80104d:	00 00                	add    %al,(%eax)
	...

00801050 <_pgfault_upcall>:
  801050:	54                   	push   %esp
  801051:	a1 08 20 80 00       	mov    0x802008,%eax
  801056:	ff d0                	call   *%eax
  801058:	83 c4 04             	add    $0x4,%esp
  80105b:	89 e0                	mov    %esp,%eax
  80105d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  801061:	8b 64 24 30          	mov    0x30(%esp),%esp
  801065:	53                   	push   %ebx
  801066:	89 60 30             	mov    %esp,0x30(%eax)
  801069:	89 c4                	mov    %eax,%esp
  80106b:	83 c4 04             	add    $0x4,%esp
  80106e:	83 c4 04             	add    $0x4,%esp
  801071:	61                   	popa   
  801072:	83 c4 04             	add    $0x4,%esp
  801075:	9d                   	popf   
  801076:	5c                   	pop    %esp
  801077:	c3                   	ret    
	...

00801080 <__udivdi3>:
  801080:	83 ec 1c             	sub    $0x1c,%esp
  801083:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801087:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80108b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80108f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801093:	89 74 24 10          	mov    %esi,0x10(%esp)
  801097:	8b 74 24 24          	mov    0x24(%esp),%esi
  80109b:	85 ff                	test   %edi,%edi
  80109d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a5:	89 cd                	mov    %ecx,%ebp
  8010a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ab:	75 33                	jne    8010e0 <__udivdi3+0x60>
  8010ad:	39 f1                	cmp    %esi,%ecx
  8010af:	77 57                	ja     801108 <__udivdi3+0x88>
  8010b1:	85 c9                	test   %ecx,%ecx
  8010b3:	75 0b                	jne    8010c0 <__udivdi3+0x40>
  8010b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ba:	31 d2                	xor    %edx,%edx
  8010bc:	f7 f1                	div    %ecx
  8010be:	89 c1                	mov    %eax,%ecx
  8010c0:	89 f0                	mov    %esi,%eax
  8010c2:	31 d2                	xor    %edx,%edx
  8010c4:	f7 f1                	div    %ecx
  8010c6:	89 c6                	mov    %eax,%esi
  8010c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010cc:	f7 f1                	div    %ecx
  8010ce:	89 f2                	mov    %esi,%edx
  8010d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010dc:	83 c4 1c             	add    $0x1c,%esp
  8010df:	c3                   	ret    
  8010e0:	31 d2                	xor    %edx,%edx
  8010e2:	31 c0                	xor    %eax,%eax
  8010e4:	39 f7                	cmp    %esi,%edi
  8010e6:	77 e8                	ja     8010d0 <__udivdi3+0x50>
  8010e8:	0f bd cf             	bsr    %edi,%ecx
  8010eb:	83 f1 1f             	xor    $0x1f,%ecx
  8010ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010f2:	75 2c                	jne    801120 <__udivdi3+0xa0>
  8010f4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010f8:	76 04                	jbe    8010fe <__udivdi3+0x7e>
  8010fa:	39 f7                	cmp    %esi,%edi
  8010fc:	73 d2                	jae    8010d0 <__udivdi3+0x50>
  8010fe:	31 d2                	xor    %edx,%edx
  801100:	b8 01 00 00 00       	mov    $0x1,%eax
  801105:	eb c9                	jmp    8010d0 <__udivdi3+0x50>
  801107:	90                   	nop
  801108:	89 f2                	mov    %esi,%edx
  80110a:	f7 f1                	div    %ecx
  80110c:	31 d2                	xor    %edx,%edx
  80110e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801112:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801116:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80111a:	83 c4 1c             	add    $0x1c,%esp
  80111d:	c3                   	ret    
  80111e:	66 90                	xchg   %ax,%ax
  801120:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801125:	b8 20 00 00 00       	mov    $0x20,%eax
  80112a:	89 ea                	mov    %ebp,%edx
  80112c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801130:	d3 e7                	shl    %cl,%edi
  801132:	89 c1                	mov    %eax,%ecx
  801134:	d3 ea                	shr    %cl,%edx
  801136:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80113b:	09 fa                	or     %edi,%edx
  80113d:	89 f7                	mov    %esi,%edi
  80113f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801143:	89 f2                	mov    %esi,%edx
  801145:	8b 74 24 08          	mov    0x8(%esp),%esi
  801149:	d3 e5                	shl    %cl,%ebp
  80114b:	89 c1                	mov    %eax,%ecx
  80114d:	d3 ef                	shr    %cl,%edi
  80114f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801154:	d3 e2                	shl    %cl,%edx
  801156:	89 c1                	mov    %eax,%ecx
  801158:	d3 ee                	shr    %cl,%esi
  80115a:	09 d6                	or     %edx,%esi
  80115c:	89 fa                	mov    %edi,%edx
  80115e:	89 f0                	mov    %esi,%eax
  801160:	f7 74 24 0c          	divl   0xc(%esp)
  801164:	89 d7                	mov    %edx,%edi
  801166:	89 c6                	mov    %eax,%esi
  801168:	f7 e5                	mul    %ebp
  80116a:	39 d7                	cmp    %edx,%edi
  80116c:	72 22                	jb     801190 <__udivdi3+0x110>
  80116e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801172:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801177:	d3 e5                	shl    %cl,%ebp
  801179:	39 c5                	cmp    %eax,%ebp
  80117b:	73 04                	jae    801181 <__udivdi3+0x101>
  80117d:	39 d7                	cmp    %edx,%edi
  80117f:	74 0f                	je     801190 <__udivdi3+0x110>
  801181:	89 f0                	mov    %esi,%eax
  801183:	31 d2                	xor    %edx,%edx
  801185:	e9 46 ff ff ff       	jmp    8010d0 <__udivdi3+0x50>
  80118a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801190:	8d 46 ff             	lea    -0x1(%esi),%eax
  801193:	31 d2                	xor    %edx,%edx
  801195:	8b 74 24 10          	mov    0x10(%esp),%esi
  801199:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80119d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011a1:	83 c4 1c             	add    $0x1c,%esp
  8011a4:	c3                   	ret    
	...

008011b0 <__umoddi3>:
  8011b0:	83 ec 1c             	sub    $0x1c,%esp
  8011b3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011b7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011bf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011c3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011cb:	85 ed                	test   %ebp,%ebp
  8011cd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d5:	89 cf                	mov    %ecx,%edi
  8011d7:	89 04 24             	mov    %eax,(%esp)
  8011da:	89 f2                	mov    %esi,%edx
  8011dc:	75 1a                	jne    8011f8 <__umoddi3+0x48>
  8011de:	39 f1                	cmp    %esi,%ecx
  8011e0:	76 4e                	jbe    801230 <__umoddi3+0x80>
  8011e2:	f7 f1                	div    %ecx
  8011e4:	89 d0                	mov    %edx,%eax
  8011e6:	31 d2                	xor    %edx,%edx
  8011e8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011ec:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011f0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011f4:	83 c4 1c             	add    $0x1c,%esp
  8011f7:	c3                   	ret    
  8011f8:	39 f5                	cmp    %esi,%ebp
  8011fa:	77 54                	ja     801250 <__umoddi3+0xa0>
  8011fc:	0f bd c5             	bsr    %ebp,%eax
  8011ff:	83 f0 1f             	xor    $0x1f,%eax
  801202:	89 44 24 04          	mov    %eax,0x4(%esp)
  801206:	75 60                	jne    801268 <__umoddi3+0xb8>
  801208:	3b 0c 24             	cmp    (%esp),%ecx
  80120b:	0f 87 07 01 00 00    	ja     801318 <__umoddi3+0x168>
  801211:	89 f2                	mov    %esi,%edx
  801213:	8b 34 24             	mov    (%esp),%esi
  801216:	29 ce                	sub    %ecx,%esi
  801218:	19 ea                	sbb    %ebp,%edx
  80121a:	89 34 24             	mov    %esi,(%esp)
  80121d:	8b 04 24             	mov    (%esp),%eax
  801220:	8b 74 24 10          	mov    0x10(%esp),%esi
  801224:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801228:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80122c:	83 c4 1c             	add    $0x1c,%esp
  80122f:	c3                   	ret    
  801230:	85 c9                	test   %ecx,%ecx
  801232:	75 0b                	jne    80123f <__umoddi3+0x8f>
  801234:	b8 01 00 00 00       	mov    $0x1,%eax
  801239:	31 d2                	xor    %edx,%edx
  80123b:	f7 f1                	div    %ecx
  80123d:	89 c1                	mov    %eax,%ecx
  80123f:	89 f0                	mov    %esi,%eax
  801241:	31 d2                	xor    %edx,%edx
  801243:	f7 f1                	div    %ecx
  801245:	8b 04 24             	mov    (%esp),%eax
  801248:	f7 f1                	div    %ecx
  80124a:	eb 98                	jmp    8011e4 <__umoddi3+0x34>
  80124c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801250:	89 f2                	mov    %esi,%edx
  801252:	8b 74 24 10          	mov    0x10(%esp),%esi
  801256:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80125a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80125e:	83 c4 1c             	add    $0x1c,%esp
  801261:	c3                   	ret    
  801262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801268:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80126d:	89 e8                	mov    %ebp,%eax
  80126f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801274:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801278:	89 fa                	mov    %edi,%edx
  80127a:	d3 e0                	shl    %cl,%eax
  80127c:	89 e9                	mov    %ebp,%ecx
  80127e:	d3 ea                	shr    %cl,%edx
  801280:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801285:	09 c2                	or     %eax,%edx
  801287:	8b 44 24 08          	mov    0x8(%esp),%eax
  80128b:	89 14 24             	mov    %edx,(%esp)
  80128e:	89 f2                	mov    %esi,%edx
  801290:	d3 e7                	shl    %cl,%edi
  801292:	89 e9                	mov    %ebp,%ecx
  801294:	d3 ea                	shr    %cl,%edx
  801296:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80129b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80129f:	d3 e6                	shl    %cl,%esi
  8012a1:	89 e9                	mov    %ebp,%ecx
  8012a3:	d3 e8                	shr    %cl,%eax
  8012a5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012aa:	09 f0                	or     %esi,%eax
  8012ac:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012b0:	f7 34 24             	divl   (%esp)
  8012b3:	d3 e6                	shl    %cl,%esi
  8012b5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012b9:	89 d6                	mov    %edx,%esi
  8012bb:	f7 e7                	mul    %edi
  8012bd:	39 d6                	cmp    %edx,%esi
  8012bf:	89 c1                	mov    %eax,%ecx
  8012c1:	89 d7                	mov    %edx,%edi
  8012c3:	72 3f                	jb     801304 <__umoddi3+0x154>
  8012c5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012c9:	72 35                	jb     801300 <__umoddi3+0x150>
  8012cb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012cf:	29 c8                	sub    %ecx,%eax
  8012d1:	19 fe                	sbb    %edi,%esi
  8012d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012d8:	89 f2                	mov    %esi,%edx
  8012da:	d3 e8                	shr    %cl,%eax
  8012dc:	89 e9                	mov    %ebp,%ecx
  8012de:	d3 e2                	shl    %cl,%edx
  8012e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012e5:	09 d0                	or     %edx,%eax
  8012e7:	89 f2                	mov    %esi,%edx
  8012e9:	d3 ea                	shr    %cl,%edx
  8012eb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012ef:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012f3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012f7:	83 c4 1c             	add    $0x1c,%esp
  8012fa:	c3                   	ret    
  8012fb:	90                   	nop
  8012fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801300:	39 d6                	cmp    %edx,%esi
  801302:	75 c7                	jne    8012cb <__umoddi3+0x11b>
  801304:	89 d7                	mov    %edx,%edi
  801306:	89 c1                	mov    %eax,%ecx
  801308:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80130c:	1b 3c 24             	sbb    (%esp),%edi
  80130f:	eb ba                	jmp    8012cb <__umoddi3+0x11b>
  801311:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801318:	39 f5                	cmp    %esi,%ebp
  80131a:	0f 82 f1 fe ff ff    	jb     801211 <__umoddi3+0x61>
  801320:	e9 f8 fe ff ff       	jmp    80121d <__umoddi3+0x6d>
