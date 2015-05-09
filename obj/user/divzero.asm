
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 c2                	mov    %eax,%edx
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 20 12 80 00 	movl   $0x801220,(%esp)
  800060:	e8 16 01 00 00       	call   80017b <cprintf>
}
  800065:	c9                   	leave  
  800066:	c3                   	ret    
	...

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
  80006e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800071:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800074:	8b 75 08             	mov    0x8(%ebp),%esi
  800077:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80007a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800081:	00 00 00 
	envid_t envid = sys_getenvid();
  800084:	e8 b3 0b 00 00       	call   800c3c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  800089:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800091:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800096:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009b:	85 f6                	test   %esi,%esi
  80009d:	7e 07                	jle    8000a6 <libmain+0x3e>
		binaryname = argv[0];
  80009f:	8b 03                	mov    (%ebx),%eax
  8000a1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000aa:	89 34 24             	mov    %esi,(%esp)
  8000ad:	e8 82 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0d 00 00 00       	call   8000c4 <exit>
}
  8000b7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000ba:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000bd:	89 ec                	mov    %ebp,%esp
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d1:	e8 09 0b 00 00       	call   800bdf <sys_env_destroy>
}
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 14             	sub    $0x14,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000eb:	83 c0 01             	add    $0x1,%eax
  8000ee:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	75 19                	jne    800110 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000f7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000fe:	00 
  8000ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800102:	89 04 24             	mov    %eax,(%esp)
  800105:	e8 76 0a 00 00       	call   800b80 <sys_cputs>
		b->idx = 0;
  80010a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800110:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800114:	83 c4 14             	add    $0x14,%esp
  800117:	5b                   	pop    %ebx
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    

0080011a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800123:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012a:	00 00 00 
	b.cnt = 0;
  80012d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800134:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800137:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013e:	8b 45 08             	mov    0x8(%ebp),%eax
  800141:	89 44 24 08          	mov    %eax,0x8(%esp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	c7 04 24 d8 00 80 00 	movl   $0x8000d8,(%esp)
  800156:	e8 d9 01 00 00       	call   800334 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800161:	89 44 24 04          	mov    %eax,0x4(%esp)
  800165:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016b:	89 04 24             	mov    %eax,(%esp)
  80016e:	e8 0d 0a 00 00       	call   800b80 <sys_cputs>

	return b.cnt;
}
  800173:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800181:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	8b 45 08             	mov    0x8(%ebp),%eax
  80018b:	89 04 24             	mov    %eax,(%esp)
  80018e:	e8 87 ff ff ff       	call   80011a <vcprintf>
	va_end(ap);

	return cnt;
}
  800193:	c9                   	leave  
  800194:	c3                   	ret    
	...

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 3c             	sub    $0x3c,%esp
  8001a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ac:	89 d7                	mov    %edx,%edi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001c5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001c8:	72 11                	jb     8001db <printnum+0x3b>
  8001ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d0:	76 09                	jbe    8001db <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d2:	83 eb 01             	sub    $0x1,%ebx
  8001d5:	85 db                	test   %ebx,%ebx
  8001d7:	7f 51                	jg     80022a <printnum+0x8a>
  8001d9:	eb 5e                	jmp    800239 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001db:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001df:	83 eb 01             	sub    $0x1,%ebx
  8001e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ed:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001f1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fc:	00 
  8001fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800200:	89 04 24             	mov    %eax,(%esp)
  800203:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800206:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020a:	e8 51 0d 00 00       	call   800f60 <__udivdi3>
  80020f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800213:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800217:	89 04 24             	mov    %eax,(%esp)
  80021a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80021e:	89 fa                	mov    %edi,%edx
  800220:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800223:	e8 78 ff ff ff       	call   8001a0 <printnum>
  800228:	eb 0f                	jmp    800239 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022e:	89 34 24             	mov    %esi,(%esp)
  800231:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	75 f1                	jne    80022a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800239:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800241:	8b 45 10             	mov    0x10(%ebp),%eax
  800244:	89 44 24 08          	mov    %eax,0x8(%esp)
  800248:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024f:	00 
  800250:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800253:	89 04 24             	mov    %eax,(%esp)
  800256:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	e8 2e 0e 00 00       	call   801090 <__umoddi3>
  800262:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800266:	0f be 80 38 12 80 00 	movsbl 0x801238(%eax),%eax
  80026d:	89 04 24             	mov    %eax,(%esp)
  800270:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800273:	83 c4 3c             	add    $0x3c,%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027e:	83 fa 01             	cmp    $0x1,%edx
  800281:	7e 0e                	jle    800291 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800283:	8b 10                	mov    (%eax),%edx
  800285:	8d 4a 08             	lea    0x8(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 02                	mov    (%edx),%eax
  80028c:	8b 52 04             	mov    0x4(%edx),%edx
  80028f:	eb 22                	jmp    8002b3 <getuint+0x38>
	else if (lflag)
  800291:	85 d2                	test   %edx,%edx
  800293:	74 10                	je     8002a5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a3:	eb 0e                	jmp    8002b3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a5:	8b 10                	mov    (%eax),%edx
  8002a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002aa:	89 08                	mov    %ecx,(%eax)
  8002ac:	8b 02                	mov    (%edx),%eax
  8002ae:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b8:	83 fa 01             	cmp    $0x1,%edx
  8002bb:	7e 0e                	jle    8002cb <getint+0x16>
		return va_arg(*ap, long long);
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 02                	mov    (%edx),%eax
  8002c6:	8b 52 04             	mov    0x4(%edx),%edx
  8002c9:	eb 22                	jmp    8002ed <getint+0x38>
	else if (lflag)
  8002cb:	85 d2                	test   %edx,%edx
  8002cd:	74 10                	je     8002df <getint+0x2a>
		return va_arg(*ap, long);
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d4:	89 08                	mov    %ecx,(%eax)
  8002d6:	8b 02                	mov    (%edx),%eax
  8002d8:	89 c2                	mov    %eax,%edx
  8002da:	c1 fa 1f             	sar    $0x1f,%edx
  8002dd:	eb 0e                	jmp    8002ed <getint+0x38>
	else
		return va_arg(*ap, int);
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e4:	89 08                	mov    %ecx,(%eax)
  8002e6:	8b 02                	mov    (%edx),%eax
  8002e8:	89 c2                	mov    %eax,%edx
  8002ea:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fe:	73 0a                	jae    80030a <sprintputch+0x1b>
		*b->buf++ = ch;
  800300:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800303:	88 0a                	mov    %cl,(%edx)
  800305:	83 c2 01             	add    $0x1,%edx
  800308:	89 10                	mov    %edx,(%eax)
}
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800312:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800315:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800319:	8b 45 10             	mov    0x10(%ebp),%eax
  80031c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
  800323:	89 44 24 04          	mov    %eax,0x4(%esp)
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	89 04 24             	mov    %eax,(%esp)
  80032d:	e8 02 00 00 00       	call   800334 <vprintfmt>
	va_end(ap);
}
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
  80033a:	83 ec 4c             	sub    $0x4c,%esp
  80033d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800340:	8b 75 10             	mov    0x10(%ebp),%esi
  800343:	eb 12                	jmp    800357 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800345:	85 c0                	test   %eax,%eax
  800347:	0f 84 77 03 00 00    	je     8006c4 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  80034d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800351:	89 04 24             	mov    %eax,(%esp)
  800354:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800357:	0f b6 06             	movzbl (%esi),%eax
  80035a:	83 c6 01             	add    $0x1,%esi
  80035d:	83 f8 25             	cmp    $0x25,%eax
  800360:	75 e3                	jne    800345 <vprintfmt+0x11>
  800362:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800366:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80036d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800372:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800381:	eb 2b                	jmp    8003ae <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800386:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80038a:	eb 22                	jmp    8003ae <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800393:	eb 19                	jmp    8003ae <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800398:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80039f:	eb 0d                	jmp    8003ae <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	0f b6 06             	movzbl (%esi),%eax
  8003b1:	0f b6 d0             	movzbl %al,%edx
  8003b4:	8d 7e 01             	lea    0x1(%esi),%edi
  8003b7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003ba:	83 e8 23             	sub    $0x23,%eax
  8003bd:	3c 55                	cmp    $0x55,%al
  8003bf:	0f 87 d9 02 00 00    	ja     80069e <vprintfmt+0x36a>
  8003c5:	0f b6 c0             	movzbl %al,%eax
  8003c8:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cf:	83 ea 30             	sub    $0x30,%edx
  8003d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003d5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003d9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003df:	83 fa 09             	cmp    $0x9,%edx
  8003e2:	77 4a                	ja     80042e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003ea:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003ed:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003f1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003f4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003f7:	83 fa 09             	cmp    $0x9,%edx
  8003fa:	76 eb                	jbe    8003e7 <vprintfmt+0xb3>
  8003fc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003ff:	eb 2d                	jmp    80042e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 50 04             	lea    0x4(%eax),%edx
  800407:	89 55 14             	mov    %edx,0x14(%ebp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800412:	eb 1a                	jmp    80042e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800417:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80041b:	79 91                	jns    8003ae <vprintfmt+0x7a>
  80041d:	e9 73 ff ff ff       	jmp    800395 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800425:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80042c:	eb 80                	jmp    8003ae <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80042e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800432:	0f 89 76 ff ff ff    	jns    8003ae <vprintfmt+0x7a>
  800438:	e9 64 ff ff ff       	jmp    8003a1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800443:	e9 66 ff ff ff       	jmp    8003ae <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 50 04             	lea    0x4(%eax),%edx
  80044e:	89 55 14             	mov    %edx,0x14(%ebp)
  800451:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800455:	8b 00                	mov    (%eax),%eax
  800457:	89 04 24             	mov    %eax,(%esp)
  80045a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800460:	e9 f2 fe ff ff       	jmp    800357 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800465:	8b 45 14             	mov    0x14(%ebp),%eax
  800468:	8d 50 04             	lea    0x4(%eax),%edx
  80046b:	89 55 14             	mov    %edx,0x14(%ebp)
  80046e:	8b 00                	mov    (%eax),%eax
  800470:	89 c2                	mov    %eax,%edx
  800472:	c1 fa 1f             	sar    $0x1f,%edx
  800475:	31 d0                	xor    %edx,%eax
  800477:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800479:	83 f8 08             	cmp    $0x8,%eax
  80047c:	7f 0b                	jg     800489 <vprintfmt+0x155>
  80047e:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800485:	85 d2                	test   %edx,%edx
  800487:	75 23                	jne    8004ac <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800489:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048d:	c7 44 24 08 50 12 80 	movl   $0x801250,0x8(%esp)
  800494:	00 
  800495:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800499:	8b 7d 08             	mov    0x8(%ebp),%edi
  80049c:	89 3c 24             	mov    %edi,(%esp)
  80049f:	e8 68 fe ff ff       	call   80030c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a7:	e9 ab fe ff ff       	jmp    800357 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b0:	c7 44 24 08 59 12 80 	movl   $0x801259,0x8(%esp)
  8004b7:	00 
  8004b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004bf:	89 3c 24             	mov    %edi,(%esp)
  8004c2:	e8 45 fe ff ff       	call   80030c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ca:	e9 88 fe ff ff       	jmp    800357 <vprintfmt+0x23>
  8004cf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 50 04             	lea    0x4(%eax),%edx
  8004de:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004e3:	85 f6                	test   %esi,%esi
  8004e5:	ba 49 12 80 00       	mov    $0x801249,%edx
  8004ea:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004ed:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f1:	7e 06                	jle    8004f9 <vprintfmt+0x1c5>
  8004f3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f7:	75 10                	jne    800509 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f9:	0f be 06             	movsbl (%esi),%eax
  8004fc:	83 c6 01             	add    $0x1,%esi
  8004ff:	85 c0                	test   %eax,%eax
  800501:	0f 85 86 00 00 00    	jne    80058d <vprintfmt+0x259>
  800507:	eb 76                	jmp    80057f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800509:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050d:	89 34 24             	mov    %esi,(%esp)
  800510:	e8 56 02 00 00       	call   80076b <strnlen>
  800515:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800518:	29 c2                	sub    %eax,%edx
  80051a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80051d:	85 d2                	test   %edx,%edx
  80051f:	7e d8                	jle    8004f9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800521:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800525:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800528:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80052b:	89 d6                	mov    %edx,%esi
  80052d:	89 c7                	mov    %eax,%edi
  80052f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800533:	89 3c 24             	mov    %edi,(%esp)
  800536:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800539:	83 ee 01             	sub    $0x1,%esi
  80053c:	75 f1                	jne    80052f <vprintfmt+0x1fb>
  80053e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800541:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800544:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800547:	eb b0                	jmp    8004f9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800549:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054d:	74 18                	je     800567 <vprintfmt+0x233>
  80054f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800552:	83 fa 5e             	cmp    $0x5e,%edx
  800555:	76 10                	jbe    800567 <vprintfmt+0x233>
					putch('?', putdat);
  800557:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800562:	ff 55 08             	call   *0x8(%ebp)
  800565:	eb 0a                	jmp    800571 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800567:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056b:	89 04 24             	mov    %eax,(%esp)
  80056e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800571:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800575:	0f be 06             	movsbl (%esi),%eax
  800578:	83 c6 01             	add    $0x1,%esi
  80057b:	85 c0                	test   %eax,%eax
  80057d:	75 0e                	jne    80058d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800582:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800586:	7f 11                	jg     800599 <vprintfmt+0x265>
  800588:	e9 ca fd ff ff       	jmp    800357 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058d:	85 ff                	test   %edi,%edi
  80058f:	90                   	nop
  800590:	78 b7                	js     800549 <vprintfmt+0x215>
  800592:	83 ef 01             	sub    $0x1,%edi
  800595:	79 b2                	jns    800549 <vprintfmt+0x215>
  800597:	eb e6                	jmp    80057f <vprintfmt+0x24b>
  800599:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80059c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005aa:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ac:	83 ee 01             	sub    $0x1,%esi
  8005af:	75 ee                	jne    80059f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b4:	e9 9e fd ff ff       	jmp    800357 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b9:	89 ca                	mov    %ecx,%edx
  8005bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005be:	e8 f2 fc ff ff       	call   8002b5 <getint>
  8005c3:	89 c6                	mov    %eax,%esi
  8005c5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005cc:	85 d2                	test   %edx,%edx
  8005ce:	0f 89 8c 00 00 00    	jns    800660 <vprintfmt+0x32c>
				putch('-', putdat);
  8005d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e2:	f7 de                	neg    %esi
  8005e4:	83 d7 00             	adc    $0x0,%edi
  8005e7:	f7 df                	neg    %edi
			}
			base = 10;
  8005e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ee:	eb 70                	jmp    800660 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f0:	89 ca                	mov    %ecx,%edx
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f5:	e8 81 fc ff ff       	call   80027b <getuint>
  8005fa:	89 c6                	mov    %eax,%esi
  8005fc:	89 d7                	mov    %edx,%edi
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800603:	eb 5b                	jmp    800660 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  800605:	89 ca                	mov    %ecx,%edx
  800607:	8d 45 14             	lea    0x14(%ebp),%eax
  80060a:	e8 a6 fc ff ff       	call   8002b5 <getint>
  80060f:	89 c6                	mov    %eax,%esi
  800611:	89 d7                	mov    %edx,%edi
			base = 8;
  800613:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800618:	eb 46                	jmp    800660 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80061a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800625:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800633:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 50 04             	lea    0x4(%eax),%edx
  80063c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063f:	8b 30                	mov    (%eax),%esi
  800641:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800646:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064b:	eb 13                	jmp    800660 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064d:	89 ca                	mov    %ecx,%edx
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 24 fc ff ff       	call   80027b <getuint>
  800657:	89 c6                	mov    %eax,%esi
  800659:	89 d7                	mov    %edx,%edi
			base = 16;
  80065b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800660:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800664:	89 54 24 10          	mov    %edx,0x10(%esp)
  800668:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80066f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800673:	89 34 24             	mov    %esi,(%esp)
  800676:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067a:	89 da                	mov    %ebx,%edx
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	e8 1c fb ff ff       	call   8001a0 <printnum>
			break;
  800684:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800687:	e9 cb fc ff ff       	jmp    800357 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	89 14 24             	mov    %edx,(%esp)
  800693:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800699:	e9 b9 fc ff ff       	jmp    800357 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006a9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ac:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006b0:	0f 84 a1 fc ff ff    	je     800357 <vprintfmt+0x23>
  8006b6:	83 ee 01             	sub    $0x1,%esi
  8006b9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006bd:	75 f7                	jne    8006b6 <vprintfmt+0x382>
  8006bf:	e9 93 fc ff ff       	jmp    800357 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006c4:	83 c4 4c             	add    $0x4c,%esp
  8006c7:	5b                   	pop    %ebx
  8006c8:	5e                   	pop    %esi
  8006c9:	5f                   	pop    %edi
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	83 ec 28             	sub    $0x28,%esp
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006db:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006df:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 30                	je     80071d <vsnprintf+0x51>
  8006ed:	85 d2                	test   %edx,%edx
  8006ef:	7e 2c                	jle    80071d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800702:	89 44 24 04          	mov    %eax,0x4(%esp)
  800706:	c7 04 24 ef 02 80 00 	movl   $0x8002ef,(%esp)
  80070d:	e8 22 fc ff ff       	call   800334 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800712:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800715:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800718:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071b:	eb 05                	jmp    800722 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800731:	8b 45 10             	mov    0x10(%ebp),%eax
  800734:	89 44 24 08          	mov    %eax,0x8(%esp)
  800738:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073f:	8b 45 08             	mov    0x8(%ebp),%eax
  800742:	89 04 24             	mov    %eax,(%esp)
  800745:	e8 82 ff ff ff       	call   8006cc <vsnprintf>
	va_end(ap);

	return rc;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    
  80074c:	00 00                	add    %al,(%eax)
	...

00800750 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	80 3a 00             	cmpb   $0x0,(%edx)
  80075e:	74 09                	je     800769 <strlen+0x19>
		n++;
  800760:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800767:	75 f7                	jne    800760 <strlen+0x10>
		n++;
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800772:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	85 c9                	test   %ecx,%ecx
  80077c:	74 1a                	je     800798 <strnlen+0x2d>
  80077e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800781:	74 15                	je     800798 <strnlen+0x2d>
  800783:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800788:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078a:	39 ca                	cmp    %ecx,%edx
  80078c:	74 0a                	je     800798 <strnlen+0x2d>
  80078e:	83 c2 01             	add    $0x1,%edx
  800791:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800796:	75 f0                	jne    800788 <strnlen+0x1d>
		n++;
	return n;
}
  800798:	5b                   	pop    %ebx
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007aa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007ae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007b1:	83 c2 01             	add    $0x1,%edx
  8007b4:	84 c9                	test   %cl,%cl
  8007b6:	75 f2                	jne    8007aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007b8:	5b                   	pop    %ebx
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c5:	89 1c 24             	mov    %ebx,(%esp)
  8007c8:	e8 83 ff ff ff       	call   800750 <strlen>
	strcpy(dst + len, src);
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d4:	01 d8                	add    %ebx,%eax
  8007d6:	89 04 24             	mov    %eax,(%esp)
  8007d9:	e8 bd ff ff ff       	call   80079b <strcpy>
	return dst;
}
  8007de:	89 d8                	mov    %ebx,%eax
  8007e0:	83 c4 08             	add    $0x8,%esp
  8007e3:	5b                   	pop    %ebx
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f4:	85 f6                	test   %esi,%esi
  8007f6:	74 18                	je     800810 <strncpy+0x2a>
  8007f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007fd:	0f b6 1a             	movzbl (%edx),%ebx
  800800:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800803:	80 3a 01             	cmpb   $0x1,(%edx)
  800806:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800809:	83 c1 01             	add    $0x1,%ecx
  80080c:	39 f1                	cmp    %esi,%ecx
  80080e:	75 ed                	jne    8007fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800810:	5b                   	pop    %ebx
  800811:	5e                   	pop    %esi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	57                   	push   %edi
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800820:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800823:	89 f8                	mov    %edi,%eax
  800825:	85 f6                	test   %esi,%esi
  800827:	74 2b                	je     800854 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800829:	83 fe 01             	cmp    $0x1,%esi
  80082c:	74 23                	je     800851 <strlcpy+0x3d>
  80082e:	0f b6 0b             	movzbl (%ebx),%ecx
  800831:	84 c9                	test   %cl,%cl
  800833:	74 1c                	je     800851 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800835:	83 ee 02             	sub    $0x2,%esi
  800838:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083d:	88 08                	mov    %cl,(%eax)
  80083f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800842:	39 f2                	cmp    %esi,%edx
  800844:	74 0b                	je     800851 <strlcpy+0x3d>
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80084d:	84 c9                	test   %cl,%cl
  80084f:	75 ec                	jne    80083d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800851:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800854:	29 f8                	sub    %edi,%eax
}
  800856:	5b                   	pop    %ebx
  800857:	5e                   	pop    %esi
  800858:	5f                   	pop    %edi
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800864:	0f b6 01             	movzbl (%ecx),%eax
  800867:	84 c0                	test   %al,%al
  800869:	74 16                	je     800881 <strcmp+0x26>
  80086b:	3a 02                	cmp    (%edx),%al
  80086d:	75 12                	jne    800881 <strcmp+0x26>
		p++, q++;
  80086f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800872:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800876:	84 c0                	test   %al,%al
  800878:	74 07                	je     800881 <strcmp+0x26>
  80087a:	83 c1 01             	add    $0x1,%ecx
  80087d:	3a 02                	cmp    (%edx),%al
  80087f:	74 ee                	je     80086f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800881:	0f b6 c0             	movzbl %al,%eax
  800884:	0f b6 12             	movzbl (%edx),%edx
  800887:	29 d0                	sub    %edx,%eax
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800892:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800895:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089d:	85 d2                	test   %edx,%edx
  80089f:	74 28                	je     8008c9 <strncmp+0x3e>
  8008a1:	0f b6 01             	movzbl (%ecx),%eax
  8008a4:	84 c0                	test   %al,%al
  8008a6:	74 24                	je     8008cc <strncmp+0x41>
  8008a8:	3a 03                	cmp    (%ebx),%al
  8008aa:	75 20                	jne    8008cc <strncmp+0x41>
  8008ac:	83 ea 01             	sub    $0x1,%edx
  8008af:	74 13                	je     8008c4 <strncmp+0x39>
		n--, p++, q++;
  8008b1:	83 c1 01             	add    $0x1,%ecx
  8008b4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b7:	0f b6 01             	movzbl (%ecx),%eax
  8008ba:	84 c0                	test   %al,%al
  8008bc:	74 0e                	je     8008cc <strncmp+0x41>
  8008be:	3a 03                	cmp    (%ebx),%al
  8008c0:	74 ea                	je     8008ac <strncmp+0x21>
  8008c2:	eb 08                	jmp    8008cc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c9:	5b                   	pop    %ebx
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cc:	0f b6 01             	movzbl (%ecx),%eax
  8008cf:	0f b6 13             	movzbl (%ebx),%edx
  8008d2:	29 d0                	sub    %edx,%eax
  8008d4:	eb f3                	jmp    8008c9 <strncmp+0x3e>

008008d6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e0:	0f b6 10             	movzbl (%eax),%edx
  8008e3:	84 d2                	test   %dl,%dl
  8008e5:	74 1c                	je     800903 <strchr+0x2d>
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	75 09                	jne    8008f4 <strchr+0x1e>
  8008eb:	eb 1b                	jmp    800908 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ed:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 14                	je     800908 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	75 f1                	jne    8008ed <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800901:	eb 05                	jmp    800908 <strchr+0x32>
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800914:	0f b6 10             	movzbl (%eax),%edx
  800917:	84 d2                	test   %dl,%dl
  800919:	74 14                	je     80092f <strfind+0x25>
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	75 06                	jne    800925 <strfind+0x1b>
  80091f:	eb 0e                	jmp    80092f <strfind+0x25>
  800921:	38 ca                	cmp    %cl,%dl
  800923:	74 0a                	je     80092f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800925:	83 c0 01             	add    $0x1,%eax
  800928:	0f b6 10             	movzbl (%eax),%edx
  80092b:	84 d2                	test   %dl,%dl
  80092d:	75 f2                	jne    800921 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	83 ec 0c             	sub    $0xc,%esp
  800937:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80093a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80093d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800940:	8b 7d 08             	mov    0x8(%ebp),%edi
  800943:	8b 45 0c             	mov    0xc(%ebp),%eax
  800946:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800949:	85 c9                	test   %ecx,%ecx
  80094b:	74 30                	je     80097d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800953:	75 25                	jne    80097a <memset+0x49>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 20                	jne    80097a <memset+0x49>
		c &= 0xFF;
  80095a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095d:	89 d3                	mov    %edx,%ebx
  80095f:	c1 e3 08             	shl    $0x8,%ebx
  800962:	89 d6                	mov    %edx,%esi
  800964:	c1 e6 18             	shl    $0x18,%esi
  800967:	89 d0                	mov    %edx,%eax
  800969:	c1 e0 10             	shl    $0x10,%eax
  80096c:	09 f0                	or     %esi,%eax
  80096e:	09 d0                	or     %edx,%eax
  800970:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800972:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800975:	fc                   	cld    
  800976:	f3 ab                	rep stos %eax,%es:(%edi)
  800978:	eb 03                	jmp    80097d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800982:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800985:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800988:	89 ec                	mov    %ebp,%esp
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	83 ec 08             	sub    $0x8,%esp
  800992:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800995:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a1:	39 c6                	cmp    %eax,%esi
  8009a3:	73 36                	jae    8009db <memmove+0x4f>
  8009a5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a8:	39 d0                	cmp    %edx,%eax
  8009aa:	73 2f                	jae    8009db <memmove+0x4f>
		s += n;
		d += n;
  8009ac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009af:	f6 c2 03             	test   $0x3,%dl
  8009b2:	75 1b                	jne    8009cf <memmove+0x43>
  8009b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ba:	75 13                	jne    8009cf <memmove+0x43>
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 0e                	jne    8009cf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c1:	83 ef 04             	sub    $0x4,%edi
  8009c4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ca:	fd                   	std    
  8009cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cd:	eb 09                	jmp    8009d8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cf:	83 ef 01             	sub    $0x1,%edi
  8009d2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d5:	fd                   	std    
  8009d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d8:	fc                   	cld    
  8009d9:	eb 20                	jmp    8009fb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009db:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e1:	75 13                	jne    8009f6 <memmove+0x6a>
  8009e3:	a8 03                	test   $0x3,%al
  8009e5:	75 0f                	jne    8009f6 <memmove+0x6a>
  8009e7:	f6 c1 03             	test   $0x3,%cl
  8009ea:	75 0a                	jne    8009f6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ec:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ef:	89 c7                	mov    %eax,%edi
  8009f1:	fc                   	cld    
  8009f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f4:	eb 05                	jmp    8009fb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f6:	89 c7                	mov    %eax,%edi
  8009f8:	fc                   	cld    
  8009f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a01:	89 ec                	mov    %ebp,%esp
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	89 04 24             	mov    %eax,(%esp)
  800a1f:	e8 68 ff ff ff       	call   80098c <memmove>
}
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a32:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3a:	85 ff                	test   %edi,%edi
  800a3c:	74 37                	je     800a75 <memcmp+0x4f>
		if (*s1 != *s2)
  800a3e:	0f b6 03             	movzbl (%ebx),%eax
  800a41:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a44:	83 ef 01             	sub    $0x1,%edi
  800a47:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a4c:	38 c8                	cmp    %cl,%al
  800a4e:	74 1c                	je     800a6c <memcmp+0x46>
  800a50:	eb 10                	jmp    800a62 <memcmp+0x3c>
  800a52:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a57:	83 c2 01             	add    $0x1,%edx
  800a5a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a5e:	38 c8                	cmp    %cl,%al
  800a60:	74 0a                	je     800a6c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800a62:	0f b6 c0             	movzbl %al,%eax
  800a65:	0f b6 c9             	movzbl %cl,%ecx
  800a68:	29 c8                	sub    %ecx,%eax
  800a6a:	eb 09                	jmp    800a75 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6c:	39 fa                	cmp    %edi,%edx
  800a6e:	75 e2                	jne    800a52 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a80:	89 c2                	mov    %eax,%edx
  800a82:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a85:	39 d0                	cmp    %edx,%eax
  800a87:	73 19                	jae    800aa2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a8d:	38 08                	cmp    %cl,(%eax)
  800a8f:	75 06                	jne    800a97 <memfind+0x1d>
  800a91:	eb 0f                	jmp    800aa2 <memfind+0x28>
  800a93:	38 08                	cmp    %cl,(%eax)
  800a95:	74 0b                	je     800aa2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a97:	83 c0 01             	add    $0x1,%eax
  800a9a:	39 d0                	cmp    %edx,%eax
  800a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800aa0:	75 f1                	jne    800a93 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
  800aaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800aad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab0:	0f b6 02             	movzbl (%edx),%eax
  800ab3:	3c 20                	cmp    $0x20,%al
  800ab5:	74 04                	je     800abb <strtol+0x17>
  800ab7:	3c 09                	cmp    $0x9,%al
  800ab9:	75 0e                	jne    800ac9 <strtol+0x25>
		s++;
  800abb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abe:	0f b6 02             	movzbl (%edx),%eax
  800ac1:	3c 20                	cmp    $0x20,%al
  800ac3:	74 f6                	je     800abb <strtol+0x17>
  800ac5:	3c 09                	cmp    $0x9,%al
  800ac7:	74 f2                	je     800abb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac9:	3c 2b                	cmp    $0x2b,%al
  800acb:	75 0a                	jne    800ad7 <strtol+0x33>
		s++;
  800acd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad5:	eb 10                	jmp    800ae7 <strtol+0x43>
  800ad7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800adc:	3c 2d                	cmp    $0x2d,%al
  800ade:	75 07                	jne    800ae7 <strtol+0x43>
		s++, neg = 1;
  800ae0:	83 c2 01             	add    $0x1,%edx
  800ae3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae7:	85 db                	test   %ebx,%ebx
  800ae9:	0f 94 c0             	sete   %al
  800aec:	74 05                	je     800af3 <strtol+0x4f>
  800aee:	83 fb 10             	cmp    $0x10,%ebx
  800af1:	75 15                	jne    800b08 <strtol+0x64>
  800af3:	80 3a 30             	cmpb   $0x30,(%edx)
  800af6:	75 10                	jne    800b08 <strtol+0x64>
  800af8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800afc:	75 0a                	jne    800b08 <strtol+0x64>
		s += 2, base = 16;
  800afe:	83 c2 02             	add    $0x2,%edx
  800b01:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b06:	eb 13                	jmp    800b1b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b08:	84 c0                	test   %al,%al
  800b0a:	74 0f                	je     800b1b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b11:	80 3a 30             	cmpb   $0x30,(%edx)
  800b14:	75 05                	jne    800b1b <strtol+0x77>
		s++, base = 8;
  800b16:	83 c2 01             	add    $0x1,%edx
  800b19:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b20:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b22:	0f b6 0a             	movzbl (%edx),%ecx
  800b25:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b28:	80 fb 09             	cmp    $0x9,%bl
  800b2b:	77 08                	ja     800b35 <strtol+0x91>
			dig = *s - '0';
  800b2d:	0f be c9             	movsbl %cl,%ecx
  800b30:	83 e9 30             	sub    $0x30,%ecx
  800b33:	eb 1e                	jmp    800b53 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b35:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b38:	80 fb 19             	cmp    $0x19,%bl
  800b3b:	77 08                	ja     800b45 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b3d:	0f be c9             	movsbl %cl,%ecx
  800b40:	83 e9 57             	sub    $0x57,%ecx
  800b43:	eb 0e                	jmp    800b53 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b45:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b48:	80 fb 19             	cmp    $0x19,%bl
  800b4b:	77 14                	ja     800b61 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b4d:	0f be c9             	movsbl %cl,%ecx
  800b50:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b53:	39 f1                	cmp    %esi,%ecx
  800b55:	7d 0e                	jge    800b65 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b57:	83 c2 01             	add    $0x1,%edx
  800b5a:	0f af c6             	imul   %esi,%eax
  800b5d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b5f:	eb c1                	jmp    800b22 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b61:	89 c1                	mov    %eax,%ecx
  800b63:	eb 02                	jmp    800b67 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b65:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6b:	74 05                	je     800b72 <strtol+0xce>
		*endptr = (char *) s;
  800b6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b70:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b72:	89 ca                	mov    %ecx,%edx
  800b74:	f7 da                	neg    %edx
  800b76:	85 ff                	test   %edi,%edi
  800b78:	0f 45 c2             	cmovne %edx,%eax
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	89 c3                	mov    %eax,%ebx
  800b9c:	89 c7                	mov    %eax,%edi
  800b9e:	89 c6                	mov    %eax,%esi
  800ba0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ba5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ba8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bab:	89 ec                	mov    %ebp,%esp
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_cgetc>:

int
sys_cgetc(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bb8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bbb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc8:	89 d1                	mov    %edx,%ecx
  800bca:	89 d3                	mov    %edx,%ebx
  800bcc:	89 d7                	mov    %edx,%edi
  800bce:	89 d6                	mov    %edx,%esi
  800bd0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bdb:	89 ec                	mov    %ebp,%esp
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	83 ec 38             	sub    $0x38,%esp
  800be5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800be8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800beb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 cb                	mov    %ecx,%ebx
  800bfd:	89 cf                	mov    %ecx,%edi
  800bff:	89 ce                	mov    %ecx,%esi
  800c01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 28                	jle    800c2f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c12:	00 
  800c13:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800c1a:	00 
  800c1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c22:	00 
  800c23:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800c2a:	e8 d5 02 00 00       	call   800f04 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c38:	89 ec                	mov    %ebp,%esp
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 02 00 00 00       	mov    $0x2,%eax
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	89 d3                	mov    %edx,%ebx
  800c59:	89 d7                	mov    %edx,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c68:	89 ec                	mov    %ebp,%esp
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_yield>:

void
sys_yield(void)
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
  800c80:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	89 d3                	mov    %edx,%ebx
  800c89:	89 d7                	mov    %edx,%edi
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c98:	89 ec                	mov    %ebp,%esp
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 38             	sub    $0x38,%esp
  800ca2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ca5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ca8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	be 00 00 00 00       	mov    $0x0,%esi
  800cb0:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	89 f7                	mov    %esi,%edi
  800cc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 28                	jle    800cee <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cca:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cd1:	00 
  800cd2:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800cd9:	00 
  800cda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce1:	00 
  800ce2:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800ce9:	e8 16 02 00 00       	call   800f04 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cf7:	89 ec                	mov    %ebp,%esp
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 38             	sub    $0x38,%esp
  800d01:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d07:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 28                	jle    800d4c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d28:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d2f:	00 
  800d30:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800d37:	00 
  800d38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3f:	00 
  800d40:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800d47:	e8 b8 01 00 00       	call   800f04 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d4c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d4f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d52:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d55:	89 ec                	mov    %ebp,%esp
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	83 ec 38             	sub    $0x38,%esp
  800d5f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d62:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d65:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	89 df                	mov    %ebx,%edi
  800d7a:	89 de                	mov    %ebx,%esi
  800d7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 28                	jle    800daa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d86:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d8d:	00 
  800d8e:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800d95:	00 
  800d96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9d:	00 
  800d9e:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800da5:	e8 5a 01 00 00       	call   800f04 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800daa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db3:	89 ec                	mov    %ebp,%esp
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 38             	sub    $0x38,%esp
  800dbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	89 df                	mov    %ebx,%edi
  800dd8:	89 de                	mov    %ebx,%esi
  800dda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	7e 28                	jle    800e08 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800deb:	00 
  800dec:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800df3:	00 
  800df4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfb:	00 
  800dfc:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800e03:	e8 fc 00 00 00       	call   800f04 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e08:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e0b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e0e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e11:	89 ec                	mov    %ebp,%esp
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	83 ec 38             	sub    $0x38,%esp
  800e1b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e1e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e21:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e29:	b8 09 00 00 00       	mov    $0x9,%eax
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e31:	8b 55 08             	mov    0x8(%ebp),%edx
  800e34:	89 df                	mov    %ebx,%edi
  800e36:	89 de                	mov    %ebx,%esi
  800e38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	7e 28                	jle    800e66 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e42:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e49:	00 
  800e4a:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800e51:	00 
  800e52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e59:	00 
  800e5a:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800e61:	e8 9e 00 00 00       	call   800f04 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e66:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e69:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e6c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e6f:	89 ec                	mov    %ebp,%esp
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	83 ec 0c             	sub    $0xc,%esp
  800e79:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e7c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e7f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e82:	be 00 00 00 00       	mov    $0x0,%esi
  800e87:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e95:	8b 55 08             	mov    0x8(%ebp),%edx
  800e98:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e9a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e9d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea3:	89 ec                	mov    %ebp,%esp
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	83 ec 38             	sub    $0x38,%esp
  800ead:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec3:	89 cb                	mov    %ecx,%ebx
  800ec5:	89 cf                	mov    %ecx,%edi
  800ec7:	89 ce                	mov    %ecx,%esi
  800ec9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	7e 28                	jle    800ef7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800eda:	00 
  800edb:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eea:	00 
  800eeb:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800ef2:	e8 0d 00 00 00       	call   800f04 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800efa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800efd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f00:	89 ec                	mov    %ebp,%esp
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f0c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f0f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f15:	e8 22 fd ff ff       	call   800c3c <sys_getenvid>
  800f1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f1d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f21:	8b 55 08             	mov    0x8(%ebp),%edx
  800f24:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f28:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f30:	c7 04 24 b0 14 80 00 	movl   $0x8014b0,(%esp)
  800f37:	e8 3f f2 ff ff       	call   80017b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f3c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f40:	8b 45 10             	mov    0x10(%ebp),%eax
  800f43:	89 04 24             	mov    %eax,(%esp)
  800f46:	e8 cf f1 ff ff       	call   80011a <vcprintf>
	cprintf("\n");
  800f4b:	c7 04 24 2c 12 80 00 	movl   $0x80122c,(%esp)
  800f52:	e8 24 f2 ff ff       	call   80017b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f57:	cc                   	int3   
  800f58:	eb fd                	jmp    800f57 <_panic+0x53>
  800f5a:	00 00                	add    %al,(%eax)
  800f5c:	00 00                	add    %al,(%eax)
	...

00800f60 <__udivdi3>:
  800f60:	83 ec 1c             	sub    $0x1c,%esp
  800f63:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f67:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f6b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f6f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f73:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f77:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f7b:	85 ff                	test   %edi,%edi
  800f7d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f85:	89 cd                	mov    %ecx,%ebp
  800f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8b:	75 33                	jne    800fc0 <__udivdi3+0x60>
  800f8d:	39 f1                	cmp    %esi,%ecx
  800f8f:	77 57                	ja     800fe8 <__udivdi3+0x88>
  800f91:	85 c9                	test   %ecx,%ecx
  800f93:	75 0b                	jne    800fa0 <__udivdi3+0x40>
  800f95:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9a:	31 d2                	xor    %edx,%edx
  800f9c:	f7 f1                	div    %ecx
  800f9e:	89 c1                	mov    %eax,%ecx
  800fa0:	89 f0                	mov    %esi,%eax
  800fa2:	31 d2                	xor    %edx,%edx
  800fa4:	f7 f1                	div    %ecx
  800fa6:	89 c6                	mov    %eax,%esi
  800fa8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fac:	f7 f1                	div    %ecx
  800fae:	89 f2                	mov    %esi,%edx
  800fb0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fb4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fb8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fbc:	83 c4 1c             	add    $0x1c,%esp
  800fbf:	c3                   	ret    
  800fc0:	31 d2                	xor    %edx,%edx
  800fc2:	31 c0                	xor    %eax,%eax
  800fc4:	39 f7                	cmp    %esi,%edi
  800fc6:	77 e8                	ja     800fb0 <__udivdi3+0x50>
  800fc8:	0f bd cf             	bsr    %edi,%ecx
  800fcb:	83 f1 1f             	xor    $0x1f,%ecx
  800fce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fd2:	75 2c                	jne    801000 <__udivdi3+0xa0>
  800fd4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fd8:	76 04                	jbe    800fde <__udivdi3+0x7e>
  800fda:	39 f7                	cmp    %esi,%edi
  800fdc:	73 d2                	jae    800fb0 <__udivdi3+0x50>
  800fde:	31 d2                	xor    %edx,%edx
  800fe0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe5:	eb c9                	jmp    800fb0 <__udivdi3+0x50>
  800fe7:	90                   	nop
  800fe8:	89 f2                	mov    %esi,%edx
  800fea:	f7 f1                	div    %ecx
  800fec:	31 d2                	xor    %edx,%edx
  800fee:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ff2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ff6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ffa:	83 c4 1c             	add    $0x1c,%esp
  800ffd:	c3                   	ret    
  800ffe:	66 90                	xchg   %ax,%ax
  801000:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801005:	b8 20 00 00 00       	mov    $0x20,%eax
  80100a:	89 ea                	mov    %ebp,%edx
  80100c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801010:	d3 e7                	shl    %cl,%edi
  801012:	89 c1                	mov    %eax,%ecx
  801014:	d3 ea                	shr    %cl,%edx
  801016:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80101b:	09 fa                	or     %edi,%edx
  80101d:	89 f7                	mov    %esi,%edi
  80101f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801023:	89 f2                	mov    %esi,%edx
  801025:	8b 74 24 08          	mov    0x8(%esp),%esi
  801029:	d3 e5                	shl    %cl,%ebp
  80102b:	89 c1                	mov    %eax,%ecx
  80102d:	d3 ef                	shr    %cl,%edi
  80102f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801034:	d3 e2                	shl    %cl,%edx
  801036:	89 c1                	mov    %eax,%ecx
  801038:	d3 ee                	shr    %cl,%esi
  80103a:	09 d6                	or     %edx,%esi
  80103c:	89 fa                	mov    %edi,%edx
  80103e:	89 f0                	mov    %esi,%eax
  801040:	f7 74 24 0c          	divl   0xc(%esp)
  801044:	89 d7                	mov    %edx,%edi
  801046:	89 c6                	mov    %eax,%esi
  801048:	f7 e5                	mul    %ebp
  80104a:	39 d7                	cmp    %edx,%edi
  80104c:	72 22                	jb     801070 <__udivdi3+0x110>
  80104e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801052:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801057:	d3 e5                	shl    %cl,%ebp
  801059:	39 c5                	cmp    %eax,%ebp
  80105b:	73 04                	jae    801061 <__udivdi3+0x101>
  80105d:	39 d7                	cmp    %edx,%edi
  80105f:	74 0f                	je     801070 <__udivdi3+0x110>
  801061:	89 f0                	mov    %esi,%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	e9 46 ff ff ff       	jmp    800fb0 <__udivdi3+0x50>
  80106a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801070:	8d 46 ff             	lea    -0x1(%esi),%eax
  801073:	31 d2                	xor    %edx,%edx
  801075:	8b 74 24 10          	mov    0x10(%esp),%esi
  801079:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80107d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801081:	83 c4 1c             	add    $0x1c,%esp
  801084:	c3                   	ret    
	...

00801090 <__umoddi3>:
  801090:	83 ec 1c             	sub    $0x1c,%esp
  801093:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801097:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80109b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80109f:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010a3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010ab:	85 ed                	test   %ebp,%ebp
  8010ad:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b5:	89 cf                	mov    %ecx,%edi
  8010b7:	89 04 24             	mov    %eax,(%esp)
  8010ba:	89 f2                	mov    %esi,%edx
  8010bc:	75 1a                	jne    8010d8 <__umoddi3+0x48>
  8010be:	39 f1                	cmp    %esi,%ecx
  8010c0:	76 4e                	jbe    801110 <__umoddi3+0x80>
  8010c2:	f7 f1                	div    %ecx
  8010c4:	89 d0                	mov    %edx,%eax
  8010c6:	31 d2                	xor    %edx,%edx
  8010c8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010cc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010d4:	83 c4 1c             	add    $0x1c,%esp
  8010d7:	c3                   	ret    
  8010d8:	39 f5                	cmp    %esi,%ebp
  8010da:	77 54                	ja     801130 <__umoddi3+0xa0>
  8010dc:	0f bd c5             	bsr    %ebp,%eax
  8010df:	83 f0 1f             	xor    $0x1f,%eax
  8010e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e6:	75 60                	jne    801148 <__umoddi3+0xb8>
  8010e8:	3b 0c 24             	cmp    (%esp),%ecx
  8010eb:	0f 87 07 01 00 00    	ja     8011f8 <__umoddi3+0x168>
  8010f1:	89 f2                	mov    %esi,%edx
  8010f3:	8b 34 24             	mov    (%esp),%esi
  8010f6:	29 ce                	sub    %ecx,%esi
  8010f8:	19 ea                	sbb    %ebp,%edx
  8010fa:	89 34 24             	mov    %esi,(%esp)
  8010fd:	8b 04 24             	mov    (%esp),%eax
  801100:	8b 74 24 10          	mov    0x10(%esp),%esi
  801104:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801108:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80110c:	83 c4 1c             	add    $0x1c,%esp
  80110f:	c3                   	ret    
  801110:	85 c9                	test   %ecx,%ecx
  801112:	75 0b                	jne    80111f <__umoddi3+0x8f>
  801114:	b8 01 00 00 00       	mov    $0x1,%eax
  801119:	31 d2                	xor    %edx,%edx
  80111b:	f7 f1                	div    %ecx
  80111d:	89 c1                	mov    %eax,%ecx
  80111f:	89 f0                	mov    %esi,%eax
  801121:	31 d2                	xor    %edx,%edx
  801123:	f7 f1                	div    %ecx
  801125:	8b 04 24             	mov    (%esp),%eax
  801128:	f7 f1                	div    %ecx
  80112a:	eb 98                	jmp    8010c4 <__umoddi3+0x34>
  80112c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801130:	89 f2                	mov    %esi,%edx
  801132:	8b 74 24 10          	mov    0x10(%esp),%esi
  801136:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80113a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80113e:	83 c4 1c             	add    $0x1c,%esp
  801141:	c3                   	ret    
  801142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801148:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80114d:	89 e8                	mov    %ebp,%eax
  80114f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801154:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801158:	89 fa                	mov    %edi,%edx
  80115a:	d3 e0                	shl    %cl,%eax
  80115c:	89 e9                	mov    %ebp,%ecx
  80115e:	d3 ea                	shr    %cl,%edx
  801160:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801165:	09 c2                	or     %eax,%edx
  801167:	8b 44 24 08          	mov    0x8(%esp),%eax
  80116b:	89 14 24             	mov    %edx,(%esp)
  80116e:	89 f2                	mov    %esi,%edx
  801170:	d3 e7                	shl    %cl,%edi
  801172:	89 e9                	mov    %ebp,%ecx
  801174:	d3 ea                	shr    %cl,%edx
  801176:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80117b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80117f:	d3 e6                	shl    %cl,%esi
  801181:	89 e9                	mov    %ebp,%ecx
  801183:	d3 e8                	shr    %cl,%eax
  801185:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80118a:	09 f0                	or     %esi,%eax
  80118c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801190:	f7 34 24             	divl   (%esp)
  801193:	d3 e6                	shl    %cl,%esi
  801195:	89 74 24 08          	mov    %esi,0x8(%esp)
  801199:	89 d6                	mov    %edx,%esi
  80119b:	f7 e7                	mul    %edi
  80119d:	39 d6                	cmp    %edx,%esi
  80119f:	89 c1                	mov    %eax,%ecx
  8011a1:	89 d7                	mov    %edx,%edi
  8011a3:	72 3f                	jb     8011e4 <__umoddi3+0x154>
  8011a5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8011a9:	72 35                	jb     8011e0 <__umoddi3+0x150>
  8011ab:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011af:	29 c8                	sub    %ecx,%eax
  8011b1:	19 fe                	sbb    %edi,%esi
  8011b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011b8:	89 f2                	mov    %esi,%edx
  8011ba:	d3 e8                	shr    %cl,%eax
  8011bc:	89 e9                	mov    %ebp,%ecx
  8011be:	d3 e2                	shl    %cl,%edx
  8011c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011c5:	09 d0                	or     %edx,%eax
  8011c7:	89 f2                	mov    %esi,%edx
  8011c9:	d3 ea                	shr    %cl,%edx
  8011cb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011cf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011d3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011d7:	83 c4 1c             	add    $0x1c,%esp
  8011da:	c3                   	ret    
  8011db:	90                   	nop
  8011dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	39 d6                	cmp    %edx,%esi
  8011e2:	75 c7                	jne    8011ab <__umoddi3+0x11b>
  8011e4:	89 d7                	mov    %edx,%edi
  8011e6:	89 c1                	mov    %eax,%ecx
  8011e8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011ec:	1b 3c 24             	sbb    (%esp),%edi
  8011ef:	eb ba                	jmp    8011ab <__umoddi3+0x11b>
  8011f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011f8:	39 f5                	cmp    %esi,%ebp
  8011fa:	0f 82 f1 fe ff ff    	jb     8010f1 <__umoddi3+0x61>
  801200:	e9 f8 fe ff ff       	jmp    8010fd <__umoddi3+0x6d>
