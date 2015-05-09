
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800049:	8b 50 04             	mov    0x4(%eax),%edx
  80004c:	83 e2 07             	and    $0x7,%edx
  80004f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800053:	8b 00                	mov    (%eax),%eax
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 e0 12 80 00 	movl   $0x8012e0,(%esp)
  800060:	e8 42 01 00 00       	call   8001a7 <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 02 0c 00 00       	call   800c6c <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 9d 0b 00 00       	call   800c0f <sys_env_destroy>
}
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <umain>:

void
umain(int argc, char **argv)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007a:	c7 04 24 40 00 80 00 	movl   $0x800040,(%esp)
  800081:	e8 ae 0e 00 00       	call   800f34 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800086:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80008d:	00 00 00 
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000a6:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000ad:	00 00 00 
	envid_t envid = sys_getenvid();
  8000b0:	e8 b7 0b 00 00       	call   800c6c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  8000b5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c2:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c7:	85 f6                	test   %esi,%esi
  8000c9:	7e 07                	jle    8000d2 <libmain+0x3e>
		binaryname = argv[0];
  8000cb:	8b 03                	mov    (%ebx),%eax
  8000cd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d6:	89 34 24             	mov    %esi,(%esp)
  8000d9:	e8 96 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000de:	e8 0d 00 00 00       	call   8000f0 <exit>
}
  8000e3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000e9:	89 ec                	mov    %ebp,%esp
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    
  8000ed:	00 00                	add    %al,(%eax)
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 0d 0b 00 00       	call   800c0f <sys_env_destroy>
}
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 14             	sub    $0x14,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 03                	mov    (%ebx),%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800117:	83 c0 01             	add    $0x1,%eax
  80011a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800121:	75 19                	jne    80013c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800123:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80012a:	00 
  80012b:	8d 43 08             	lea    0x8(%ebx),%eax
  80012e:	89 04 24             	mov    %eax,(%esp)
  800131:	e8 7a 0a 00 00       	call   800bb0 <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80013c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800140:	83 c4 14             	add    $0x14,%esp
  800143:	5b                   	pop    %ebx
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800156:	00 00 00 
	b.cnt = 0;
  800159:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800160:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800163:	8b 45 0c             	mov    0xc(%ebp),%eax
  800166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800171:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	c7 04 24 04 01 80 00 	movl   $0x800104,(%esp)
  800182:	e8 dd 01 00 00       	call   800364 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800187:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800197:	89 04 24             	mov    %eax,(%esp)
  80019a:	e8 11 0a 00 00       	call   800bb0 <sys_cputs>

	return b.cnt;
}
  80019f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 87 ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    
	...

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 3c             	sub    $0x3c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d7                	mov    %edx,%edi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ed:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001f5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001f8:	72 11                	jb     80020b <printnum+0x3b>
  8001fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800200:	76 09                	jbe    80020b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800202:	83 eb 01             	sub    $0x1,%ebx
  800205:	85 db                	test   %ebx,%ebx
  800207:	7f 51                	jg     80025a <printnum+0x8a>
  800209:	eb 5e                	jmp    800269 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80020f:	83 eb 01             	sub    $0x1,%ebx
  800212:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800216:	8b 45 10             	mov    0x10(%ebp),%eax
  800219:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800221:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800225:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022c:	00 
  80022d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	e8 e1 0d 00 00       	call   801020 <__udivdi3>
  80023f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800243:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80024e:	89 fa                	mov    %edi,%edx
  800250:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800253:	e8 78 ff ff ff       	call   8001d0 <printnum>
  800258:	eb 0f                	jmp    800269 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80025a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025e:	89 34 24             	mov    %esi,(%esp)
  800261:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800264:	83 eb 01             	sub    $0x1,%ebx
  800267:	75 f1                	jne    80025a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800269:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800271:	8b 45 10             	mov    0x10(%ebp),%eax
  800274:	89 44 24 08          	mov    %eax,0x8(%esp)
  800278:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027f:	00 
  800280:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800289:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028d:	e8 be 0e 00 00       	call   801150 <__umoddi3>
  800292:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800296:	0f be 80 06 13 80 00 	movsbl 0x801306(%eax),%eax
  80029d:	89 04 24             	mov    %eax,(%esp)
  8002a0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002a3:	83 c4 3c             	add    $0x3c,%esp
  8002a6:	5b                   	pop    %ebx
  8002a7:	5e                   	pop    %esi
  8002a8:	5f                   	pop    %edi
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ae:	83 fa 01             	cmp    $0x1,%edx
  8002b1:	7e 0e                	jle    8002c1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b8:	89 08                	mov    %ecx,(%eax)
  8002ba:	8b 02                	mov    (%edx),%eax
  8002bc:	8b 52 04             	mov    0x4(%edx),%edx
  8002bf:	eb 22                	jmp    8002e3 <getuint+0x38>
	else if (lflag)
  8002c1:	85 d2                	test   %edx,%edx
  8002c3:	74 10                	je     8002d5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ca:	89 08                	mov    %ecx,(%eax)
  8002cc:	8b 02                	mov    (%edx),%eax
  8002ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d3:	eb 0e                	jmp    8002e3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d5:	8b 10                	mov    (%eax),%edx
  8002d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 02                	mov    (%edx),%eax
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e8:	83 fa 01             	cmp    $0x1,%edx
  8002eb:	7e 0e                	jle    8002fb <getint+0x16>
		return va_arg(*ap, long long);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	8b 52 04             	mov    0x4(%edx),%edx
  8002f9:	eb 22                	jmp    80031d <getint+0x38>
	else if (lflag)
  8002fb:	85 d2                	test   %edx,%edx
  8002fd:	74 10                	je     80030f <getint+0x2a>
		return va_arg(*ap, long);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 04             	lea    0x4(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	89 c2                	mov    %eax,%edx
  80030a:	c1 fa 1f             	sar    $0x1f,%edx
  80030d:	eb 0e                	jmp    80031d <getint+0x38>
	else
		return va_arg(*ap, int);
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	8d 4a 04             	lea    0x4(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 02                	mov    (%edx),%eax
  800318:	89 c2                	mov    %eax,%edx
  80031a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800325:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	3b 50 04             	cmp    0x4(%eax),%edx
  80032e:	73 0a                	jae    80033a <sprintputch+0x1b>
		*b->buf++ = ch;
  800330:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800333:	88 0a                	mov    %cl,(%edx)
  800335:	83 c2 01             	add    $0x1,%edx
  800338:	89 10                	mov    %edx,(%eax)
}
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800342:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800345:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800349:	8b 45 10             	mov    0x10(%ebp),%eax
  80034c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800350:	8b 45 0c             	mov    0xc(%ebp),%eax
  800353:	89 44 24 04          	mov    %eax,0x4(%esp)
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	89 04 24             	mov    %eax,(%esp)
  80035d:	e8 02 00 00 00       	call   800364 <vprintfmt>
	va_end(ap);
}
  800362:	c9                   	leave  
  800363:	c3                   	ret    

00800364 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	57                   	push   %edi
  800368:	56                   	push   %esi
  800369:	53                   	push   %ebx
  80036a:	83 ec 4c             	sub    $0x4c,%esp
  80036d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800370:	8b 75 10             	mov    0x10(%ebp),%esi
  800373:	eb 12                	jmp    800387 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800375:	85 c0                	test   %eax,%eax
  800377:	0f 84 77 03 00 00    	je     8006f4 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  80037d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800381:	89 04 24             	mov    %eax,(%esp)
  800384:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800387:	0f b6 06             	movzbl (%esi),%eax
  80038a:	83 c6 01             	add    $0x1,%esi
  80038d:	83 f8 25             	cmp    $0x25,%eax
  800390:	75 e3                	jne    800375 <vprintfmt+0x11>
  800392:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800396:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80039d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003a2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003b1:	eb 2b                	jmp    8003de <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003ba:	eb 22                	jmp    8003de <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bf:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003c3:	eb 19                	jmp    8003de <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003cf:	eb 0d                	jmp    8003de <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	0f b6 06             	movzbl (%esi),%eax
  8003e1:	0f b6 d0             	movzbl %al,%edx
  8003e4:	8d 7e 01             	lea    0x1(%esi),%edi
  8003e7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003ea:	83 e8 23             	sub    $0x23,%eax
  8003ed:	3c 55                	cmp    $0x55,%al
  8003ef:	0f 87 d9 02 00 00    	ja     8006ce <vprintfmt+0x36a>
  8003f5:	0f b6 c0             	movzbl %al,%eax
  8003f8:	ff 24 85 c0 13 80 00 	jmp    *0x8013c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ff:	83 ea 30             	sub    $0x30,%edx
  800402:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800405:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800409:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80040f:	83 fa 09             	cmp    $0x9,%edx
  800412:	77 4a                	ja     80045e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800417:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80041a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80041d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800421:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800424:	8d 50 d0             	lea    -0x30(%eax),%edx
  800427:	83 fa 09             	cmp    $0x9,%edx
  80042a:	76 eb                	jbe    800417 <vprintfmt+0xb3>
  80042c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80042f:	eb 2d                	jmp    80045e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 50 04             	lea    0x4(%eax),%edx
  800437:	89 55 14             	mov    %edx,0x14(%ebp)
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800442:	eb 1a                	jmp    80045e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800447:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044b:	79 91                	jns    8003de <vprintfmt+0x7a>
  80044d:	e9 73 ff ff ff       	jmp    8003c5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800455:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80045c:	eb 80                	jmp    8003de <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80045e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800462:	0f 89 76 ff ff ff    	jns    8003de <vprintfmt+0x7a>
  800468:	e9 64 ff ff ff       	jmp    8003d1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800473:	e9 66 ff ff ff       	jmp    8003de <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800485:	8b 00                	mov    (%eax),%eax
  800487:	89 04 24             	mov    %eax,(%esp)
  80048a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800490:	e9 f2 fe ff ff       	jmp    800387 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 50 04             	lea    0x4(%eax),%edx
  80049b:	89 55 14             	mov    %edx,0x14(%ebp)
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	89 c2                	mov    %eax,%edx
  8004a2:	c1 fa 1f             	sar    $0x1f,%edx
  8004a5:	31 d0                	xor    %edx,%eax
  8004a7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a9:	83 f8 08             	cmp    $0x8,%eax
  8004ac:	7f 0b                	jg     8004b9 <vprintfmt+0x155>
  8004ae:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  8004b5:	85 d2                	test   %edx,%edx
  8004b7:	75 23                	jne    8004dc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004bd:	c7 44 24 08 1e 13 80 	movl   $0x80131e,0x8(%esp)
  8004c4:	00 
  8004c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004cc:	89 3c 24             	mov    %edi,(%esp)
  8004cf:	e8 68 fe ff ff       	call   80033c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d7:	e9 ab fe ff ff       	jmp    800387 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e0:	c7 44 24 08 27 13 80 	movl   $0x801327,0x8(%esp)
  8004e7:	00 
  8004e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004ef:	89 3c 24             	mov    %edi,(%esp)
  8004f2:	e8 45 fe ff ff       	call   80033c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004fa:	e9 88 fe ff ff       	jmp    800387 <vprintfmt+0x23>
  8004ff:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800502:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800505:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 04             	lea    0x4(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800513:	85 f6                	test   %esi,%esi
  800515:	ba 17 13 80 00       	mov    $0x801317,%edx
  80051a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80051d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800521:	7e 06                	jle    800529 <vprintfmt+0x1c5>
  800523:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800527:	75 10                	jne    800539 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800529:	0f be 06             	movsbl (%esi),%eax
  80052c:	83 c6 01             	add    $0x1,%esi
  80052f:	85 c0                	test   %eax,%eax
  800531:	0f 85 86 00 00 00    	jne    8005bd <vprintfmt+0x259>
  800537:	eb 76                	jmp    8005af <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800539:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053d:	89 34 24             	mov    %esi,(%esp)
  800540:	e8 56 02 00 00       	call   80079b <strnlen>
  800545:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800548:	29 c2                	sub    %eax,%edx
  80054a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80054d:	85 d2                	test   %edx,%edx
  80054f:	7e d8                	jle    800529 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800551:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800555:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800558:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80055b:	89 d6                	mov    %edx,%esi
  80055d:	89 c7                	mov    %eax,%edi
  80055f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800563:	89 3c 24             	mov    %edi,(%esp)
  800566:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800569:	83 ee 01             	sub    $0x1,%esi
  80056c:	75 f1                	jne    80055f <vprintfmt+0x1fb>
  80056e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800571:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800574:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800577:	eb b0                	jmp    800529 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800579:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057d:	74 18                	je     800597 <vprintfmt+0x233>
  80057f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800582:	83 fa 5e             	cmp    $0x5e,%edx
  800585:	76 10                	jbe    800597 <vprintfmt+0x233>
					putch('?', putdat);
  800587:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800592:	ff 55 08             	call   *0x8(%ebp)
  800595:	eb 0a                	jmp    8005a1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800597:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059b:	89 04 24             	mov    %eax,(%esp)
  80059e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005a5:	0f be 06             	movsbl (%esi),%eax
  8005a8:	83 c6 01             	add    $0x1,%esi
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	75 0e                	jne    8005bd <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b6:	7f 11                	jg     8005c9 <vprintfmt+0x265>
  8005b8:	e9 ca fd ff ff       	jmp    800387 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bd:	85 ff                	test   %edi,%edi
  8005bf:	90                   	nop
  8005c0:	78 b7                	js     800579 <vprintfmt+0x215>
  8005c2:	83 ef 01             	sub    $0x1,%edi
  8005c5:	79 b2                	jns    800579 <vprintfmt+0x215>
  8005c7:	eb e6                	jmp    8005af <vprintfmt+0x24b>
  8005c9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005cc:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005da:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005dc:	83 ee 01             	sub    $0x1,%esi
  8005df:	75 ee                	jne    8005cf <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e4:	e9 9e fd ff ff       	jmp    800387 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e9:	89 ca                	mov    %ecx,%edx
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 f2 fc ff ff       	call   8002e5 <getint>
  8005f3:	89 c6                	mov    %eax,%esi
  8005f5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	0f 89 8c 00 00 00    	jns    800690 <vprintfmt+0x32c>
				putch('-', putdat);
  800604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800608:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800612:	f7 de                	neg    %esi
  800614:	83 d7 00             	adc    $0x0,%edi
  800617:	f7 df                	neg    %edi
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	eb 70                	jmp    800690 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800620:	89 ca                	mov    %ecx,%edx
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 81 fc ff ff       	call   8002ab <getuint>
  80062a:	89 c6                	mov    %eax,%esi
  80062c:	89 d7                	mov    %edx,%edi
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800633:	eb 5b                	jmp    800690 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  800635:	89 ca                	mov    %ecx,%edx
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 a6 fc ff ff       	call   8002e5 <getint>
  80063f:	89 c6                	mov    %eax,%esi
  800641:	89 d7                	mov    %edx,%edi
			base = 8;
  800643:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800648:	eb 46                	jmp    800690 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80064a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800655:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066f:	8b 30                	mov    (%eax),%esi
  800671:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800676:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067b:	eb 13                	jmp    800690 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067d:	89 ca                	mov    %ecx,%edx
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 24 fc ff ff       	call   8002ab <getuint>
  800687:	89 c6                	mov    %eax,%esi
  800689:	89 d7                	mov    %edx,%edi
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800690:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800694:	89 54 24 10          	mov    %edx,0x10(%esp)
  800698:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80069b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a3:	89 34 24             	mov    %esi,(%esp)
  8006a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006aa:	89 da                	mov    %ebx,%edx
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	e8 1c fb ff ff       	call   8001d0 <printnum>
			break;
  8006b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b7:	e9 cb fc ff ff       	jmp    800387 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	89 14 24             	mov    %edx,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c9:	e9 b9 fc ff ff       	jmp    800387 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e0:	0f 84 a1 fc ff ff    	je     800387 <vprintfmt+0x23>
  8006e6:	83 ee 01             	sub    $0x1,%esi
  8006e9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ed:	75 f7                	jne    8006e6 <vprintfmt+0x382>
  8006ef:	e9 93 fc ff ff       	jmp    800387 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006f4:	83 c4 4c             	add    $0x4c,%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	83 ec 28             	sub    $0x28,%esp
  800702:	8b 45 08             	mov    0x8(%ebp),%eax
  800705:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800708:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800712:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800719:	85 c0                	test   %eax,%eax
  80071b:	74 30                	je     80074d <vsnprintf+0x51>
  80071d:	85 d2                	test   %edx,%edx
  80071f:	7e 2c                	jle    80074d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800728:	8b 45 10             	mov    0x10(%ebp),%eax
  80072b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800732:	89 44 24 04          	mov    %eax,0x4(%esp)
  800736:	c7 04 24 1f 03 80 00 	movl   $0x80031f,(%esp)
  80073d:	e8 22 fc ff ff       	call   800364 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800742:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800745:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800748:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074b:	eb 05                	jmp    800752 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800761:	8b 45 10             	mov    0x10(%ebp),%eax
  800764:	89 44 24 08          	mov    %eax,0x8(%esp)
  800768:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	89 04 24             	mov    %eax,(%esp)
  800775:	e8 82 ff ff ff       	call   8006fc <vsnprintf>
	va_end(ap);

	return rc;
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    
  80077c:	00 00                	add    %al,(%eax)
	...

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	80 3a 00             	cmpb   $0x0,(%edx)
  80078e:	74 09                	je     800799 <strlen+0x19>
		n++;
  800790:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800793:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800797:	75 f7                	jne    800790 <strlen+0x10>
		n++;
	return n;
}
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007aa:	85 c9                	test   %ecx,%ecx
  8007ac:	74 1a                	je     8007c8 <strnlen+0x2d>
  8007ae:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007b1:	74 15                	je     8007c8 <strnlen+0x2d>
  8007b3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007b8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ba:	39 ca                	cmp    %ecx,%edx
  8007bc:	74 0a                	je     8007c8 <strnlen+0x2d>
  8007be:	83 c2 01             	add    $0x1,%edx
  8007c1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007c6:	75 f0                	jne    8007b8 <strnlen+0x1d>
		n++;
	return n;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007da:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007de:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007e1:	83 c2 01             	add    $0x1,%edx
  8007e4:	84 c9                	test   %cl,%cl
  8007e6:	75 f2                	jne    8007da <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e8:	5b                   	pop    %ebx
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	83 ec 08             	sub    $0x8,%esp
  8007f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f5:	89 1c 24             	mov    %ebx,(%esp)
  8007f8:	e8 83 ff ff ff       	call   800780 <strlen>
	strcpy(dst + len, src);
  8007fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800800:	89 54 24 04          	mov    %edx,0x4(%esp)
  800804:	01 d8                	add    %ebx,%eax
  800806:	89 04 24             	mov    %eax,(%esp)
  800809:	e8 bd ff ff ff       	call   8007cb <strcpy>
	return dst;
}
  80080e:	89 d8                	mov    %ebx,%eax
  800810:	83 c4 08             	add    $0x8,%esp
  800813:	5b                   	pop    %ebx
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800821:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800824:	85 f6                	test   %esi,%esi
  800826:	74 18                	je     800840 <strncpy+0x2a>
  800828:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80082d:	0f b6 1a             	movzbl (%edx),%ebx
  800830:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800833:	80 3a 01             	cmpb   $0x1,(%edx)
  800836:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	39 f1                	cmp    %esi,%ecx
  80083e:	75 ed                	jne    80082d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	57                   	push   %edi
  800848:	56                   	push   %esi
  800849:	53                   	push   %ebx
  80084a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800850:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800853:	89 f8                	mov    %edi,%eax
  800855:	85 f6                	test   %esi,%esi
  800857:	74 2b                	je     800884 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800859:	83 fe 01             	cmp    $0x1,%esi
  80085c:	74 23                	je     800881 <strlcpy+0x3d>
  80085e:	0f b6 0b             	movzbl (%ebx),%ecx
  800861:	84 c9                	test   %cl,%cl
  800863:	74 1c                	je     800881 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800865:	83 ee 02             	sub    $0x2,%esi
  800868:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086d:	88 08                	mov    %cl,(%eax)
  80086f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800872:	39 f2                	cmp    %esi,%edx
  800874:	74 0b                	je     800881 <strlcpy+0x3d>
  800876:	83 c2 01             	add    $0x1,%edx
  800879:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80087d:	84 c9                	test   %cl,%cl
  80087f:	75 ec                	jne    80086d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800881:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800884:	29 f8                	sub    %edi,%eax
}
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5f                   	pop    %edi
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800894:	0f b6 01             	movzbl (%ecx),%eax
  800897:	84 c0                	test   %al,%al
  800899:	74 16                	je     8008b1 <strcmp+0x26>
  80089b:	3a 02                	cmp    (%edx),%al
  80089d:	75 12                	jne    8008b1 <strcmp+0x26>
		p++, q++;
  80089f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8008a6:	84 c0                	test   %al,%al
  8008a8:	74 07                	je     8008b1 <strcmp+0x26>
  8008aa:	83 c1 01             	add    $0x1,%ecx
  8008ad:	3a 02                	cmp    (%edx),%al
  8008af:	74 ee                	je     80089f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b1:	0f b6 c0             	movzbl %al,%eax
  8008b4:	0f b6 12             	movzbl (%edx),%edx
  8008b7:	29 d0                	sub    %edx,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008c5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cd:	85 d2                	test   %edx,%edx
  8008cf:	74 28                	je     8008f9 <strncmp+0x3e>
  8008d1:	0f b6 01             	movzbl (%ecx),%eax
  8008d4:	84 c0                	test   %al,%al
  8008d6:	74 24                	je     8008fc <strncmp+0x41>
  8008d8:	3a 03                	cmp    (%ebx),%al
  8008da:	75 20                	jne    8008fc <strncmp+0x41>
  8008dc:	83 ea 01             	sub    $0x1,%edx
  8008df:	74 13                	je     8008f4 <strncmp+0x39>
		n--, p++, q++;
  8008e1:	83 c1 01             	add    $0x1,%ecx
  8008e4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e7:	0f b6 01             	movzbl (%ecx),%eax
  8008ea:	84 c0                	test   %al,%al
  8008ec:	74 0e                	je     8008fc <strncmp+0x41>
  8008ee:	3a 03                	cmp    (%ebx),%al
  8008f0:	74 ea                	je     8008dc <strncmp+0x21>
  8008f2:	eb 08                	jmp    8008fc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f9:	5b                   	pop    %ebx
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fc:	0f b6 01             	movzbl (%ecx),%eax
  8008ff:	0f b6 13             	movzbl (%ebx),%edx
  800902:	29 d0                	sub    %edx,%eax
  800904:	eb f3                	jmp    8008f9 <strncmp+0x3e>

00800906 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800910:	0f b6 10             	movzbl (%eax),%edx
  800913:	84 d2                	test   %dl,%dl
  800915:	74 1c                	je     800933 <strchr+0x2d>
		if (*s == c)
  800917:	38 ca                	cmp    %cl,%dl
  800919:	75 09                	jne    800924 <strchr+0x1e>
  80091b:	eb 1b                	jmp    800938 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800920:	38 ca                	cmp    %cl,%dl
  800922:	74 14                	je     800938 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800924:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800928:	84 d2                	test   %dl,%dl
  80092a:	75 f1                	jne    80091d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
  800931:	eb 05                	jmp    800938 <strchr+0x32>
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	0f b6 10             	movzbl (%eax),%edx
  800947:	84 d2                	test   %dl,%dl
  800949:	74 14                	je     80095f <strfind+0x25>
		if (*s == c)
  80094b:	38 ca                	cmp    %cl,%dl
  80094d:	75 06                	jne    800955 <strfind+0x1b>
  80094f:	eb 0e                	jmp    80095f <strfind+0x25>
  800951:	38 ca                	cmp    %cl,%dl
  800953:	74 0a                	je     80095f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	0f b6 10             	movzbl (%eax),%edx
  80095b:	84 d2                	test   %dl,%dl
  80095d:	75 f2                	jne    800951 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 0c             	sub    $0xc,%esp
  800967:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80096a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80096d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800970:	8b 7d 08             	mov    0x8(%ebp),%edi
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
  800976:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800979:	85 c9                	test   %ecx,%ecx
  80097b:	74 30                	je     8009ad <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800983:	75 25                	jne    8009aa <memset+0x49>
  800985:	f6 c1 03             	test   $0x3,%cl
  800988:	75 20                	jne    8009aa <memset+0x49>
		c &= 0xFF;
  80098a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80098d:	89 d3                	mov    %edx,%ebx
  80098f:	c1 e3 08             	shl    $0x8,%ebx
  800992:	89 d6                	mov    %edx,%esi
  800994:	c1 e6 18             	shl    $0x18,%esi
  800997:	89 d0                	mov    %edx,%eax
  800999:	c1 e0 10             	shl    $0x10,%eax
  80099c:	09 f0                	or     %esi,%eax
  80099e:	09 d0                	or     %edx,%eax
  8009a0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009a2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009a5:	fc                   	cld    
  8009a6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a8:	eb 03                	jmp    8009ad <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009aa:	fc                   	cld    
  8009ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009b8:	89 ec                	mov    %ebp,%esp
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 08             	sub    $0x8,%esp
  8009c2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009c5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d1:	39 c6                	cmp    %eax,%esi
  8009d3:	73 36                	jae    800a0b <memmove+0x4f>
  8009d5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d8:	39 d0                	cmp    %edx,%eax
  8009da:	73 2f                	jae    800a0b <memmove+0x4f>
		s += n;
		d += n;
  8009dc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009df:	f6 c2 03             	test   $0x3,%dl
  8009e2:	75 1b                	jne    8009ff <memmove+0x43>
  8009e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ea:	75 13                	jne    8009ff <memmove+0x43>
  8009ec:	f6 c1 03             	test   $0x3,%cl
  8009ef:	75 0e                	jne    8009ff <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f1:	83 ef 04             	sub    $0x4,%edi
  8009f4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009fa:	fd                   	std    
  8009fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fd:	eb 09                	jmp    800a08 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ff:	83 ef 01             	sub    $0x1,%edi
  800a02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a05:	fd                   	std    
  800a06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a08:	fc                   	cld    
  800a09:	eb 20                	jmp    800a2b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a11:	75 13                	jne    800a26 <memmove+0x6a>
  800a13:	a8 03                	test   $0x3,%al
  800a15:	75 0f                	jne    800a26 <memmove+0x6a>
  800a17:	f6 c1 03             	test   $0x3,%cl
  800a1a:	75 0a                	jne    800a26 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a1c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a1f:	89 c7                	mov    %eax,%edi
  800a21:	fc                   	cld    
  800a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a24:	eb 05                	jmp    800a2b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a26:	89 c7                	mov    %eax,%edi
  800a28:	fc                   	cld    
  800a29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a31:	89 ec                	mov    %ebp,%esp
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	89 04 24             	mov    %eax,(%esp)
  800a4f:	e8 68 ff ff ff       	call   8009bc <memmove>
}
  800a54:	c9                   	leave  
  800a55:	c3                   	ret    

00800a56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a62:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6a:	85 ff                	test   %edi,%edi
  800a6c:	74 37                	je     800aa5 <memcmp+0x4f>
		if (*s1 != *s2)
  800a6e:	0f b6 03             	movzbl (%ebx),%eax
  800a71:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a74:	83 ef 01             	sub    $0x1,%edi
  800a77:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a7c:	38 c8                	cmp    %cl,%al
  800a7e:	74 1c                	je     800a9c <memcmp+0x46>
  800a80:	eb 10                	jmp    800a92 <memcmp+0x3c>
  800a82:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a87:	83 c2 01             	add    $0x1,%edx
  800a8a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a8e:	38 c8                	cmp    %cl,%al
  800a90:	74 0a                	je     800a9c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800a92:	0f b6 c0             	movzbl %al,%eax
  800a95:	0f b6 c9             	movzbl %cl,%ecx
  800a98:	29 c8                	sub    %ecx,%eax
  800a9a:	eb 09                	jmp    800aa5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9c:	39 fa                	cmp    %edi,%edx
  800a9e:	75 e2                	jne    800a82 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ab0:	89 c2                	mov    %eax,%edx
  800ab2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab5:	39 d0                	cmp    %edx,%eax
  800ab7:	73 19                	jae    800ad2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800abd:	38 08                	cmp    %cl,(%eax)
  800abf:	75 06                	jne    800ac7 <memfind+0x1d>
  800ac1:	eb 0f                	jmp    800ad2 <memfind+0x28>
  800ac3:	38 08                	cmp    %cl,(%eax)
  800ac5:	74 0b                	je     800ad2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	39 d0                	cmp    %edx,%eax
  800acc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ad0:	75 f1                	jne    800ac3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae0:	0f b6 02             	movzbl (%edx),%eax
  800ae3:	3c 20                	cmp    $0x20,%al
  800ae5:	74 04                	je     800aeb <strtol+0x17>
  800ae7:	3c 09                	cmp    $0x9,%al
  800ae9:	75 0e                	jne    800af9 <strtol+0x25>
		s++;
  800aeb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aee:	0f b6 02             	movzbl (%edx),%eax
  800af1:	3c 20                	cmp    $0x20,%al
  800af3:	74 f6                	je     800aeb <strtol+0x17>
  800af5:	3c 09                	cmp    $0x9,%al
  800af7:	74 f2                	je     800aeb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af9:	3c 2b                	cmp    $0x2b,%al
  800afb:	75 0a                	jne    800b07 <strtol+0x33>
		s++;
  800afd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b00:	bf 00 00 00 00       	mov    $0x0,%edi
  800b05:	eb 10                	jmp    800b17 <strtol+0x43>
  800b07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0c:	3c 2d                	cmp    $0x2d,%al
  800b0e:	75 07                	jne    800b17 <strtol+0x43>
		s++, neg = 1;
  800b10:	83 c2 01             	add    $0x1,%edx
  800b13:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b17:	85 db                	test   %ebx,%ebx
  800b19:	0f 94 c0             	sete   %al
  800b1c:	74 05                	je     800b23 <strtol+0x4f>
  800b1e:	83 fb 10             	cmp    $0x10,%ebx
  800b21:	75 15                	jne    800b38 <strtol+0x64>
  800b23:	80 3a 30             	cmpb   $0x30,(%edx)
  800b26:	75 10                	jne    800b38 <strtol+0x64>
  800b28:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b2c:	75 0a                	jne    800b38 <strtol+0x64>
		s += 2, base = 16;
  800b2e:	83 c2 02             	add    $0x2,%edx
  800b31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b36:	eb 13                	jmp    800b4b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b38:	84 c0                	test   %al,%al
  800b3a:	74 0f                	je     800b4b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b41:	80 3a 30             	cmpb   $0x30,(%edx)
  800b44:	75 05                	jne    800b4b <strtol+0x77>
		s++, base = 8;
  800b46:	83 c2 01             	add    $0x1,%edx
  800b49:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b52:	0f b6 0a             	movzbl (%edx),%ecx
  800b55:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b58:	80 fb 09             	cmp    $0x9,%bl
  800b5b:	77 08                	ja     800b65 <strtol+0x91>
			dig = *s - '0';
  800b5d:	0f be c9             	movsbl %cl,%ecx
  800b60:	83 e9 30             	sub    $0x30,%ecx
  800b63:	eb 1e                	jmp    800b83 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b65:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b68:	80 fb 19             	cmp    $0x19,%bl
  800b6b:	77 08                	ja     800b75 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b6d:	0f be c9             	movsbl %cl,%ecx
  800b70:	83 e9 57             	sub    $0x57,%ecx
  800b73:	eb 0e                	jmp    800b83 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b75:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b78:	80 fb 19             	cmp    $0x19,%bl
  800b7b:	77 14                	ja     800b91 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b7d:	0f be c9             	movsbl %cl,%ecx
  800b80:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b83:	39 f1                	cmp    %esi,%ecx
  800b85:	7d 0e                	jge    800b95 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b87:	83 c2 01             	add    $0x1,%edx
  800b8a:	0f af c6             	imul   %esi,%eax
  800b8d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b8f:	eb c1                	jmp    800b52 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b91:	89 c1                	mov    %eax,%ecx
  800b93:	eb 02                	jmp    800b97 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b95:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9b:	74 05                	je     800ba2 <strtol+0xce>
		*endptr = (char *) s;
  800b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba2:	89 ca                	mov    %ecx,%edx
  800ba4:	f7 da                	neg    %edx
  800ba6:	85 ff                	test   %edi,%edi
  800ba8:	0f 45 c2             	cmovne %edx,%eax
}
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bb9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bbc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bca:	89 c3                	mov    %eax,%ebx
  800bcc:	89 c7                	mov    %eax,%edi
  800bce:	89 c6                	mov    %eax,%esi
  800bd0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bdb:	89 ec                	mov    %ebp,%esp
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800be8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800beb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf8:	89 d1                	mov    %edx,%ecx
  800bfa:	89 d3                	mov    %edx,%ebx
  800bfc:	89 d7                	mov    %edx,%edi
  800bfe:	89 d6                	mov    %edx,%esi
  800c00:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c0b:	89 ec                	mov    %ebp,%esp
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	83 ec 38             	sub    $0x38,%esp
  800c15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c23:	b8 03 00 00 00       	mov    $0x3,%eax
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	89 cb                	mov    %ecx,%ebx
  800c2d:	89 cf                	mov    %ecx,%edi
  800c2f:	89 ce                	mov    %ecx,%esi
  800c31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 28                	jle    800c5f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c42:	00 
  800c43:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800c4a:	00 
  800c4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c52:	00 
  800c53:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800c5a:	e8 69 03 00 00       	call   800fc8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c68:	89 ec                	mov    %ebp,%esp
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 0c             	sub    $0xc,%esp
  800c72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	b8 02 00 00 00       	mov    $0x2,%eax
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	89 d3                	mov    %edx,%ebx
  800c89:	89 d7                	mov    %edx,%edi
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c98:	89 ec                	mov    %ebp,%esp
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_yield>:

void
sys_yield(void)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ca5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ca8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	89 d3                	mov    %edx,%ebx
  800cb9:	89 d7                	mov    %edx,%edi
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc8:	89 ec                	mov    %ebp,%esp
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 38             	sub    $0x38,%esp
  800cd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	be 00 00 00 00       	mov    $0x0,%esi
  800ce0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ce5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	89 f7                	mov    %esi,%edi
  800cf0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	7e 28                	jle    800d1e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d01:	00 
  800d02:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800d09:	00 
  800d0a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d11:	00 
  800d12:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800d19:	e8 aa 02 00 00       	call   800fc8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d1e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d21:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d24:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d27:	89 ec                	mov    %ebp,%esp
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 38             	sub    $0x38,%esp
  800d31:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d37:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d3f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7e 28                	jle    800d7c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d58:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d5f:	00 
  800d60:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800d67:	00 
  800d68:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6f:	00 
  800d70:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800d77:	e8 4c 02 00 00       	call   800fc8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d7c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d7f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d82:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d85:	89 ec                	mov    %ebp,%esp
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	83 ec 38             	sub    $0x38,%esp
  800d8f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d92:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d95:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	89 df                	mov    %ebx,%edi
  800daa:	89 de                	mov    %ebx,%esi
  800dac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dae:	85 c0                	test   %eax,%eax
  800db0:	7e 28                	jle    800dda <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dbd:	00 
  800dbe:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800dc5:	00 
  800dc6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcd:	00 
  800dce:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800dd5:	e8 ee 01 00 00       	call   800fc8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dda:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ddd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de3:	89 ec                	mov    %ebp,%esp
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	83 ec 38             	sub    $0x38,%esp
  800ded:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfb:	b8 08 00 00 00       	mov    $0x8,%eax
  800e00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	89 df                	mov    %ebx,%edi
  800e08:	89 de                	mov    %ebx,%esi
  800e0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7e 28                	jle    800e38 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e14:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e1b:	00 
  800e1c:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800e23:	00 
  800e24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2b:	00 
  800e2c:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800e33:	e8 90 01 00 00       	call   800fc8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e38:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e3b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e41:	89 ec                	mov    %ebp,%esp
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	83 ec 38             	sub    $0x38,%esp
  800e4b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e4e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e51:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e59:	b8 09 00 00 00       	mov    $0x9,%eax
  800e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	89 df                	mov    %ebx,%edi
  800e66:	89 de                	mov    %ebx,%esi
  800e68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	7e 28                	jle    800e96 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e72:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e79:	00 
  800e7a:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800e81:	00 
  800e82:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e89:	00 
  800e8a:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800e91:	e8 32 01 00 00       	call   800fc8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e96:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e99:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e9c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e9f:	89 ec                	mov    %ebp,%esp
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	83 ec 0c             	sub    $0xc,%esp
  800ea9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eaf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	be 00 00 00 00       	mov    $0x0,%esi
  800eb7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ebc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ebf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ecd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed3:	89 ec                	mov    %ebp,%esp
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	83 ec 38             	sub    $0x38,%esp
  800edd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eeb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ef0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef3:	89 cb                	mov    %ecx,%ebx
  800ef5:	89 cf                	mov    %ecx,%edi
  800ef7:	89 ce                	mov    %ecx,%esi
  800ef9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800efb:	85 c0                	test   %eax,%eax
  800efd:	7e 28                	jle    800f27 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f03:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f0a:	00 
  800f0b:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800f12:	00 
  800f13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1a:	00 
  800f1b:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800f22:	e8 a1 00 00 00       	call   800fc8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f27:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f2d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f30:	89 ec                	mov    %ebp,%esp
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f3a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f41:	75 50                	jne    800f93 <set_pgfault_handler+0x5f>
		// First time through!
		// LAB 4: Your code here.
		int error = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P);
  800f43:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f52:	ee 
  800f53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5a:	e8 6d fd ff ff       	call   800ccc <sys_page_alloc>
        if (error) {
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	74 1c                	je     800f7f <set_pgfault_handler+0x4b>
            panic("No physical memory available!");
  800f63:	c7 44 24 08 6f 15 80 	movl   $0x80156f,0x8(%esp)
  800f6a:	00 
  800f6b:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f72:	00 
  800f73:	c7 04 24 8d 15 80 00 	movl   $0x80158d,(%esp)
  800f7a:	e8 49 00 00 00       	call   800fc8 <_panic>
        }

		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800f7f:	c7 44 24 04 a0 0f 80 	movl   $0x800fa0,0x4(%esp)
  800f86:	00 
  800f87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f8e:	e8 b2 fe ff ff       	call   800e45 <sys_env_set_pgfault_upcall>
		
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
  800f96:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    
  800f9d:	00 00                	add    %al,(%eax)
	...

00800fa0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800fa0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800fa1:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800fa6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800fa8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	

	movl %esp, %eax 		// temporarily save exception stack esp
  800fab:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 	// return addr (eip) -> ebx 
  800fad:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 	// now trap-time stack
  800fb1:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 				// push eip onto trap-time stack 
  800fb5:	53                   	push   %ebx
	movl %esp, 48(%eax) 	// Updating the trap-time stack esp, since a new val has been pushed
  800fb6:	89 60 30             	mov    %esp,0x30(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	movl %eax, %esp 	/* now exception stack */
  800fb9:	89 c4                	mov    %eax,%esp
	addl $4, %esp 		/* skip utf_fault_va */
  800fbb:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 		/* skip utf_err */
  800fbe:	83 c4 04             	add    $0x4,%esp
	popal 				/* restore from utf_regs  */
  800fc1:	61                   	popa   
	addl $4, %esp 		/* skip utf_eip (already on trap-time stack) */
  800fc2:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	popfl /* restore from utf_eflags */
  800fc5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp /* restore from utf_esp - top of stack (bottom-most val) will be the eip to go to */
  800fc6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	
	ret
  800fc7:	c3                   	ret    

00800fc8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	56                   	push   %esi
  800fcc:	53                   	push   %ebx
  800fcd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800fd0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fd3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800fd9:	e8 8e fc ff ff       	call   800c6c <sys_getenvid>
  800fde:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe1:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fe5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ff0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff4:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  800ffb:	e8 a7 f1 ff ff       	call   8001a7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801000:	89 74 24 04          	mov    %esi,0x4(%esp)
  801004:	8b 45 10             	mov    0x10(%ebp),%eax
  801007:	89 04 24             	mov    %eax,(%esp)
  80100a:	e8 37 f1 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  80100f:	c7 04 24 fa 12 80 00 	movl   $0x8012fa,(%esp)
  801016:	e8 8c f1 ff ff       	call   8001a7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80101b:	cc                   	int3   
  80101c:	eb fd                	jmp    80101b <_panic+0x53>
	...

00801020 <__udivdi3>:
  801020:	83 ec 1c             	sub    $0x1c,%esp
  801023:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801027:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80102b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80102f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801033:	89 74 24 10          	mov    %esi,0x10(%esp)
  801037:	8b 74 24 24          	mov    0x24(%esp),%esi
  80103b:	85 ff                	test   %edi,%edi
  80103d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801041:	89 44 24 08          	mov    %eax,0x8(%esp)
  801045:	89 cd                	mov    %ecx,%ebp
  801047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104b:	75 33                	jne    801080 <__udivdi3+0x60>
  80104d:	39 f1                	cmp    %esi,%ecx
  80104f:	77 57                	ja     8010a8 <__udivdi3+0x88>
  801051:	85 c9                	test   %ecx,%ecx
  801053:	75 0b                	jne    801060 <__udivdi3+0x40>
  801055:	b8 01 00 00 00       	mov    $0x1,%eax
  80105a:	31 d2                	xor    %edx,%edx
  80105c:	f7 f1                	div    %ecx
  80105e:	89 c1                	mov    %eax,%ecx
  801060:	89 f0                	mov    %esi,%eax
  801062:	31 d2                	xor    %edx,%edx
  801064:	f7 f1                	div    %ecx
  801066:	89 c6                	mov    %eax,%esi
  801068:	8b 44 24 04          	mov    0x4(%esp),%eax
  80106c:	f7 f1                	div    %ecx
  80106e:	89 f2                	mov    %esi,%edx
  801070:	8b 74 24 10          	mov    0x10(%esp),%esi
  801074:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801078:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80107c:	83 c4 1c             	add    $0x1c,%esp
  80107f:	c3                   	ret    
  801080:	31 d2                	xor    %edx,%edx
  801082:	31 c0                	xor    %eax,%eax
  801084:	39 f7                	cmp    %esi,%edi
  801086:	77 e8                	ja     801070 <__udivdi3+0x50>
  801088:	0f bd cf             	bsr    %edi,%ecx
  80108b:	83 f1 1f             	xor    $0x1f,%ecx
  80108e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801092:	75 2c                	jne    8010c0 <__udivdi3+0xa0>
  801094:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801098:	76 04                	jbe    80109e <__udivdi3+0x7e>
  80109a:	39 f7                	cmp    %esi,%edi
  80109c:	73 d2                	jae    801070 <__udivdi3+0x50>
  80109e:	31 d2                	xor    %edx,%edx
  8010a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a5:	eb c9                	jmp    801070 <__udivdi3+0x50>
  8010a7:	90                   	nop
  8010a8:	89 f2                	mov    %esi,%edx
  8010aa:	f7 f1                	div    %ecx
  8010ac:	31 d2                	xor    %edx,%edx
  8010ae:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010b2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010b6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ba:	83 c4 1c             	add    $0x1c,%esp
  8010bd:	c3                   	ret    
  8010be:	66 90                	xchg   %ax,%ax
  8010c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010c5:	b8 20 00 00 00       	mov    $0x20,%eax
  8010ca:	89 ea                	mov    %ebp,%edx
  8010cc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010d0:	d3 e7                	shl    %cl,%edi
  8010d2:	89 c1                	mov    %eax,%ecx
  8010d4:	d3 ea                	shr    %cl,%edx
  8010d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010db:	09 fa                	or     %edi,%edx
  8010dd:	89 f7                	mov    %esi,%edi
  8010df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e3:	89 f2                	mov    %esi,%edx
  8010e5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010e9:	d3 e5                	shl    %cl,%ebp
  8010eb:	89 c1                	mov    %eax,%ecx
  8010ed:	d3 ef                	shr    %cl,%edi
  8010ef:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010f4:	d3 e2                	shl    %cl,%edx
  8010f6:	89 c1                	mov    %eax,%ecx
  8010f8:	d3 ee                	shr    %cl,%esi
  8010fa:	09 d6                	or     %edx,%esi
  8010fc:	89 fa                	mov    %edi,%edx
  8010fe:	89 f0                	mov    %esi,%eax
  801100:	f7 74 24 0c          	divl   0xc(%esp)
  801104:	89 d7                	mov    %edx,%edi
  801106:	89 c6                	mov    %eax,%esi
  801108:	f7 e5                	mul    %ebp
  80110a:	39 d7                	cmp    %edx,%edi
  80110c:	72 22                	jb     801130 <__udivdi3+0x110>
  80110e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801112:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801117:	d3 e5                	shl    %cl,%ebp
  801119:	39 c5                	cmp    %eax,%ebp
  80111b:	73 04                	jae    801121 <__udivdi3+0x101>
  80111d:	39 d7                	cmp    %edx,%edi
  80111f:	74 0f                	je     801130 <__udivdi3+0x110>
  801121:	89 f0                	mov    %esi,%eax
  801123:	31 d2                	xor    %edx,%edx
  801125:	e9 46 ff ff ff       	jmp    801070 <__udivdi3+0x50>
  80112a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801130:	8d 46 ff             	lea    -0x1(%esi),%eax
  801133:	31 d2                	xor    %edx,%edx
  801135:	8b 74 24 10          	mov    0x10(%esp),%esi
  801139:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80113d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801141:	83 c4 1c             	add    $0x1c,%esp
  801144:	c3                   	ret    
	...

00801150 <__umoddi3>:
  801150:	83 ec 1c             	sub    $0x1c,%esp
  801153:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801157:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80115b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80115f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801163:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801167:	8b 74 24 24          	mov    0x24(%esp),%esi
  80116b:	85 ed                	test   %ebp,%ebp
  80116d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801171:	89 44 24 08          	mov    %eax,0x8(%esp)
  801175:	89 cf                	mov    %ecx,%edi
  801177:	89 04 24             	mov    %eax,(%esp)
  80117a:	89 f2                	mov    %esi,%edx
  80117c:	75 1a                	jne    801198 <__umoddi3+0x48>
  80117e:	39 f1                	cmp    %esi,%ecx
  801180:	76 4e                	jbe    8011d0 <__umoddi3+0x80>
  801182:	f7 f1                	div    %ecx
  801184:	89 d0                	mov    %edx,%eax
  801186:	31 d2                	xor    %edx,%edx
  801188:	8b 74 24 10          	mov    0x10(%esp),%esi
  80118c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801190:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801194:	83 c4 1c             	add    $0x1c,%esp
  801197:	c3                   	ret    
  801198:	39 f5                	cmp    %esi,%ebp
  80119a:	77 54                	ja     8011f0 <__umoddi3+0xa0>
  80119c:	0f bd c5             	bsr    %ebp,%eax
  80119f:	83 f0 1f             	xor    $0x1f,%eax
  8011a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a6:	75 60                	jne    801208 <__umoddi3+0xb8>
  8011a8:	3b 0c 24             	cmp    (%esp),%ecx
  8011ab:	0f 87 07 01 00 00    	ja     8012b8 <__umoddi3+0x168>
  8011b1:	89 f2                	mov    %esi,%edx
  8011b3:	8b 34 24             	mov    (%esp),%esi
  8011b6:	29 ce                	sub    %ecx,%esi
  8011b8:	19 ea                	sbb    %ebp,%edx
  8011ba:	89 34 24             	mov    %esi,(%esp)
  8011bd:	8b 04 24             	mov    (%esp),%eax
  8011c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011cc:	83 c4 1c             	add    $0x1c,%esp
  8011cf:	c3                   	ret    
  8011d0:	85 c9                	test   %ecx,%ecx
  8011d2:	75 0b                	jne    8011df <__umoddi3+0x8f>
  8011d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d9:	31 d2                	xor    %edx,%edx
  8011db:	f7 f1                	div    %ecx
  8011dd:	89 c1                	mov    %eax,%ecx
  8011df:	89 f0                	mov    %esi,%eax
  8011e1:	31 d2                	xor    %edx,%edx
  8011e3:	f7 f1                	div    %ecx
  8011e5:	8b 04 24             	mov    (%esp),%eax
  8011e8:	f7 f1                	div    %ecx
  8011ea:	eb 98                	jmp    801184 <__umoddi3+0x34>
  8011ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	89 f2                	mov    %esi,%edx
  8011f2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011f6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011fa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011fe:	83 c4 1c             	add    $0x1c,%esp
  801201:	c3                   	ret    
  801202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801208:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80120d:	89 e8                	mov    %ebp,%eax
  80120f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801214:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801218:	89 fa                	mov    %edi,%edx
  80121a:	d3 e0                	shl    %cl,%eax
  80121c:	89 e9                	mov    %ebp,%ecx
  80121e:	d3 ea                	shr    %cl,%edx
  801220:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801225:	09 c2                	or     %eax,%edx
  801227:	8b 44 24 08          	mov    0x8(%esp),%eax
  80122b:	89 14 24             	mov    %edx,(%esp)
  80122e:	89 f2                	mov    %esi,%edx
  801230:	d3 e7                	shl    %cl,%edi
  801232:	89 e9                	mov    %ebp,%ecx
  801234:	d3 ea                	shr    %cl,%edx
  801236:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80123b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80123f:	d3 e6                	shl    %cl,%esi
  801241:	89 e9                	mov    %ebp,%ecx
  801243:	d3 e8                	shr    %cl,%eax
  801245:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80124a:	09 f0                	or     %esi,%eax
  80124c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801250:	f7 34 24             	divl   (%esp)
  801253:	d3 e6                	shl    %cl,%esi
  801255:	89 74 24 08          	mov    %esi,0x8(%esp)
  801259:	89 d6                	mov    %edx,%esi
  80125b:	f7 e7                	mul    %edi
  80125d:	39 d6                	cmp    %edx,%esi
  80125f:	89 c1                	mov    %eax,%ecx
  801261:	89 d7                	mov    %edx,%edi
  801263:	72 3f                	jb     8012a4 <__umoddi3+0x154>
  801265:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801269:	72 35                	jb     8012a0 <__umoddi3+0x150>
  80126b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80126f:	29 c8                	sub    %ecx,%eax
  801271:	19 fe                	sbb    %edi,%esi
  801273:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801278:	89 f2                	mov    %esi,%edx
  80127a:	d3 e8                	shr    %cl,%eax
  80127c:	89 e9                	mov    %ebp,%ecx
  80127e:	d3 e2                	shl    %cl,%edx
  801280:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801285:	09 d0                	or     %edx,%eax
  801287:	89 f2                	mov    %esi,%edx
  801289:	d3 ea                	shr    %cl,%edx
  80128b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80128f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801293:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801297:	83 c4 1c             	add    $0x1c,%esp
  80129a:	c3                   	ret    
  80129b:	90                   	nop
  80129c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a0:	39 d6                	cmp    %edx,%esi
  8012a2:	75 c7                	jne    80126b <__umoddi3+0x11b>
  8012a4:	89 d7                	mov    %edx,%edi
  8012a6:	89 c1                	mov    %eax,%ecx
  8012a8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012ac:	1b 3c 24             	sbb    (%esp),%edi
  8012af:	eb ba                	jmp    80126b <__umoddi3+0x11b>
  8012b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	39 f5                	cmp    %esi,%ebp
  8012ba:	0f 82 f1 fe ff ff    	jb     8011b1 <__umoddi3+0x61>
  8012c0:	e9 f8 fe ff ff       	jmp    8011bd <__umoddi3+0x6d>
