
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 00 12 80 00 	movl   $0x801200,(%esp)
  80004a:	e8 18 01 00 00       	call   800167 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800066:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80006d:	00 00 00 
	envid_t envid = sys_getenvid();
  800070:	e8 b7 0b 00 00       	call   800c2c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 f6                	test   %esi,%esi
  800089:	7e 07                	jle    800092 <libmain+0x3e>
		binaryname = argv[0];
  80008b:	8b 03                	mov    (%ebx),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 96 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009e:	e8 0d 00 00 00       	call   8000b0 <exit>
}
  8000a3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a9:	89 ec                	mov    %ebp,%esp
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 0d 0b 00 00       	call   800bcf <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 14             	sub    $0x14,%esp
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ce:	8b 03                	mov    (%ebx),%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d7:	83 c0 01             	add    $0x1,%eax
  8000da:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e1:	75 19                	jne    8000fc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000e3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ea:	00 
  8000eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ee:	89 04 24             	mov    %eax,(%esp)
  8000f1:	e8 7a 0a 00 00       	call   800b70 <sys_cputs>
		b->idx = 0;
  8000f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800100:	83 c4 14             	add    $0x14,%esp
  800103:	5b                   	pop    %ebx
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800116:	00 00 00 
	b.cnt = 0;
  800119:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800120:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800123:	8b 45 0c             	mov    0xc(%ebp),%eax
  800126:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012a:	8b 45 08             	mov    0x8(%ebp),%eax
  80012d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800131:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800137:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013b:	c7 04 24 c4 00 80 00 	movl   $0x8000c4,(%esp)
  800142:	e8 dd 01 00 00       	call   800324 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800147:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800157:	89 04 24             	mov    %eax,(%esp)
  80015a:	e8 11 0a 00 00       	call   800b70 <sys_cputs>

	return b.cnt;
}
  80015f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	89 04 24             	mov    %eax,(%esp)
  80017a:	e8 87 ff ff ff       	call   800106 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b8:	72 11                	jb     8001cb <printnum+0x3b>
  8001ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c0:	76 09                	jbe    8001cb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c2:	83 eb 01             	sub    $0x1,%ebx
  8001c5:	85 db                	test   %ebx,%ebx
  8001c7:	7f 51                	jg     80021a <printnum+0x8a>
  8001c9:	eb 5e                	jmp    800229 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001cb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001cf:	83 eb 01             	sub    $0x1,%ebx
  8001d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001e1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ec:	00 
  8001ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fa:	e8 51 0d 00 00       	call   800f50 <__udivdi3>
  8001ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800203:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020e:	89 fa                	mov    %edi,%edx
  800210:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800213:	e8 78 ff ff ff       	call   800190 <printnum>
  800218:	eb 0f                	jmp    800229 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021e:	89 34 24             	mov    %esi,(%esp)
  800221:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800224:	83 eb 01             	sub    $0x1,%ebx
  800227:	75 f1                	jne    80021a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800229:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800231:	8b 45 10             	mov    0x10(%ebp),%eax
  800234:	89 44 24 08          	mov    %eax,0x8(%esp)
  800238:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023f:	00 
  800240:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024d:	e8 2e 0e 00 00       	call   801080 <__umoddi3>
  800252:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800256:	0f be 80 28 12 80 00 	movsbl 0x801228(%eax),%eax
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800263:	83 c4 3c             	add    $0x3c,%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026e:	83 fa 01             	cmp    $0x1,%edx
  800271:	7e 0e                	jle    800281 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 08             	lea    0x8(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	8b 52 04             	mov    0x4(%edx),%edx
  80027f:	eb 22                	jmp    8002a3 <getuint+0x38>
	else if (lflag)
  800281:	85 d2                	test   %edx,%edx
  800283:	74 10                	je     800295 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
  800293:	eb 0e                	jmp    8002a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a8:	83 fa 01             	cmp    $0x1,%edx
  8002ab:	7e 0e                	jle    8002bb <getint+0x16>
		return va_arg(*ap, long long);
  8002ad:	8b 10                	mov    (%eax),%edx
  8002af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b2:	89 08                	mov    %ecx,(%eax)
  8002b4:	8b 02                	mov    (%edx),%eax
  8002b6:	8b 52 04             	mov    0x4(%edx),%edx
  8002b9:	eb 22                	jmp    8002dd <getint+0x38>
	else if (lflag)
  8002bb:	85 d2                	test   %edx,%edx
  8002bd:	74 10                	je     8002cf <getint+0x2a>
		return va_arg(*ap, long);
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 02                	mov    (%edx),%eax
  8002c8:	89 c2                	mov    %eax,%edx
  8002ca:	c1 fa 1f             	sar    $0x1f,%edx
  8002cd:	eb 0e                	jmp    8002dd <getint+0x38>
	else
		return va_arg(*ap, int);
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d4:	89 08                	mov    %ecx,(%eax)
  8002d6:	8b 02                	mov    (%edx),%eax
  8002d8:	89 c2                	mov    %eax,%edx
  8002da:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ee:	73 0a                	jae    8002fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f3:	88 0a                	mov    %cl,(%edx)
  8002f5:	83 c2 01             	add    $0x1,%edx
  8002f8:	89 10                	mov    %edx,(%eax)
}
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800302:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800305:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800309:	8b 45 10             	mov    0x10(%ebp),%eax
  80030c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800310:	8b 45 0c             	mov    0xc(%ebp),%eax
  800313:	89 44 24 04          	mov    %eax,0x4(%esp)
  800317:	8b 45 08             	mov    0x8(%ebp),%eax
  80031a:	89 04 24             	mov    %eax,(%esp)
  80031d:	e8 02 00 00 00       	call   800324 <vprintfmt>
	va_end(ap);
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
  80032a:	83 ec 4c             	sub    $0x4c,%esp
  80032d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800330:	8b 75 10             	mov    0x10(%ebp),%esi
  800333:	eb 12                	jmp    800347 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800335:	85 c0                	test   %eax,%eax
  800337:	0f 84 77 03 00 00    	je     8006b4 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  80033d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800341:	89 04 24             	mov    %eax,(%esp)
  800344:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800347:	0f b6 06             	movzbl (%esi),%eax
  80034a:	83 c6 01             	add    $0x1,%esi
  80034d:	83 f8 25             	cmp    $0x25,%eax
  800350:	75 e3                	jne    800335 <vprintfmt+0x11>
  800352:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800356:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80035d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800362:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800369:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800371:	eb 2b                	jmp    80039e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800376:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80037a:	eb 22                	jmp    80039e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800383:	eb 19                	jmp    80039e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800388:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80038f:	eb 0d                	jmp    80039e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800391:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800394:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800397:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	0f b6 06             	movzbl (%esi),%eax
  8003a1:	0f b6 d0             	movzbl %al,%edx
  8003a4:	8d 7e 01             	lea    0x1(%esi),%edi
  8003a7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003aa:	83 e8 23             	sub    $0x23,%eax
  8003ad:	3c 55                	cmp    $0x55,%al
  8003af:	0f 87 d9 02 00 00    	ja     80068e <vprintfmt+0x36a>
  8003b5:	0f b6 c0             	movzbl %al,%eax
  8003b8:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bf:	83 ea 30             	sub    $0x30,%edx
  8003c2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003c5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003c9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003cf:	83 fa 09             	cmp    $0x9,%edx
  8003d2:	77 4a                	ja     80041e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003da:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003dd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003e1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003e4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003e7:	83 fa 09             	cmp    $0x9,%edx
  8003ea:	76 eb                	jbe    8003d7 <vprintfmt+0xb3>
  8003ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003ef:	eb 2d                	jmp    80041e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800402:	eb 1a                	jmp    80041e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800407:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040b:	79 91                	jns    80039e <vprintfmt+0x7a>
  80040d:	e9 73 ff ff ff       	jmp    800385 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800415:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80041c:	eb 80                	jmp    80039e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80041e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800422:	0f 89 76 ff ff ff    	jns    80039e <vprintfmt+0x7a>
  800428:	e9 64 ff ff ff       	jmp    800391 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800433:	e9 66 ff ff ff       	jmp    80039e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800445:	8b 00                	mov    (%eax),%eax
  800447:	89 04 24             	mov    %eax,(%esp)
  80044a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800450:	e9 f2 fe ff ff       	jmp    800347 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 50 04             	lea    0x4(%eax),%edx
  80045b:	89 55 14             	mov    %edx,0x14(%ebp)
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	89 c2                	mov    %eax,%edx
  800462:	c1 fa 1f             	sar    $0x1f,%edx
  800465:	31 d0                	xor    %edx,%eax
  800467:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800469:	83 f8 08             	cmp    $0x8,%eax
  80046c:	7f 0b                	jg     800479 <vprintfmt+0x155>
  80046e:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	75 23                	jne    80049c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800479:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047d:	c7 44 24 08 40 12 80 	movl   $0x801240,0x8(%esp)
  800484:	00 
  800485:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800489:	8b 7d 08             	mov    0x8(%ebp),%edi
  80048c:	89 3c 24             	mov    %edi,(%esp)
  80048f:	e8 68 fe ff ff       	call   8002fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800497:	e9 ab fe ff ff       	jmp    800347 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80049c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004a0:	c7 44 24 08 49 12 80 	movl   $0x801249,0x8(%esp)
  8004a7:	00 
  8004a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004af:	89 3c 24             	mov    %edi,(%esp)
  8004b2:	e8 45 fe ff ff       	call   8002fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ba:	e9 88 fe ff ff       	jmp    800347 <vprintfmt+0x23>
  8004bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004d3:	85 f6                	test   %esi,%esi
  8004d5:	ba 39 12 80 00       	mov    $0x801239,%edx
  8004da:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004dd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e1:	7e 06                	jle    8004e9 <vprintfmt+0x1c5>
  8004e3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004e7:	75 10                	jne    8004f9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e9:	0f be 06             	movsbl (%esi),%eax
  8004ec:	83 c6 01             	add    $0x1,%esi
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	0f 85 86 00 00 00    	jne    80057d <vprintfmt+0x259>
  8004f7:	eb 76                	jmp    80056f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fd:	89 34 24             	mov    %esi,(%esp)
  800500:	e8 56 02 00 00       	call   80075b <strnlen>
  800505:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800508:	29 c2                	sub    %eax,%edx
  80050a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80050d:	85 d2                	test   %edx,%edx
  80050f:	7e d8                	jle    8004e9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800511:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800515:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800518:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80051b:	89 d6                	mov    %edx,%esi
  80051d:	89 c7                	mov    %eax,%edi
  80051f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800523:	89 3c 24             	mov    %edi,(%esp)
  800526:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	83 ee 01             	sub    $0x1,%esi
  80052c:	75 f1                	jne    80051f <vprintfmt+0x1fb>
  80052e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800531:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800534:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800537:	eb b0                	jmp    8004e9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800539:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80053d:	74 18                	je     800557 <vprintfmt+0x233>
  80053f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800542:	83 fa 5e             	cmp    $0x5e,%edx
  800545:	76 10                	jbe    800557 <vprintfmt+0x233>
					putch('?', putdat);
  800547:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800552:	ff 55 08             	call   *0x8(%ebp)
  800555:	eb 0a                	jmp    800561 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800557:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800561:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800565:	0f be 06             	movsbl (%esi),%eax
  800568:	83 c6 01             	add    $0x1,%esi
  80056b:	85 c0                	test   %eax,%eax
  80056d:	75 0e                	jne    80057d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800572:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800576:	7f 11                	jg     800589 <vprintfmt+0x265>
  800578:	e9 ca fd ff ff       	jmp    800347 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	85 ff                	test   %edi,%edi
  80057f:	90                   	nop
  800580:	78 b7                	js     800539 <vprintfmt+0x215>
  800582:	83 ef 01             	sub    $0x1,%edi
  800585:	79 b2                	jns    800539 <vprintfmt+0x215>
  800587:	eb e6                	jmp    80056f <vprintfmt+0x24b>
  800589:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800593:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80059a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059c:	83 ee 01             	sub    $0x1,%esi
  80059f:	75 ee                	jne    80058f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a4:	e9 9e fd ff ff       	jmp    800347 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a9:	89 ca                	mov    %ecx,%edx
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 f2 fc ff ff       	call   8002a5 <getint>
  8005b3:	89 c6                	mov    %eax,%esi
  8005b5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005bc:	85 d2                	test   %edx,%edx
  8005be:	0f 89 8c 00 00 00    	jns    800650 <vprintfmt+0x32c>
				putch('-', putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005d2:	f7 de                	neg    %esi
  8005d4:	83 d7 00             	adc    $0x0,%edi
  8005d7:	f7 df                	neg    %edi
			}
			base = 10;
  8005d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005de:	eb 70                	jmp    800650 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e0:	89 ca                	mov    %ecx,%edx
  8005e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e5:	e8 81 fc ff ff       	call   80026b <getuint>
  8005ea:	89 c6                	mov    %eax,%esi
  8005ec:	89 d7                	mov    %edx,%edi
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005f3:	eb 5b                	jmp    800650 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  8005f5:	89 ca                	mov    %ecx,%edx
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 a6 fc ff ff       	call   8002a5 <getint>
  8005ff:	89 c6                	mov    %eax,%esi
  800601:	89 d7                	mov    %edx,%edi
			base = 8;
  800603:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800608:	eb 46                	jmp    800650 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80060a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800615:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800618:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800623:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062f:	8b 30                	mov    (%eax),%esi
  800631:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800636:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80063b:	eb 13                	jmp    800650 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80063d:	89 ca                	mov    %ecx,%edx
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 24 fc ff ff       	call   80026b <getuint>
  800647:	89 c6                	mov    %eax,%esi
  800649:	89 d7                	mov    %edx,%edi
			base = 16;
  80064b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800650:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800654:	89 54 24 10          	mov    %edx,0x10(%esp)
  800658:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800663:	89 34 24             	mov    %esi,(%esp)
  800666:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066a:	89 da                	mov    %ebx,%edx
  80066c:	8b 45 08             	mov    0x8(%ebp),%eax
  80066f:	e8 1c fb ff ff       	call   800190 <printnum>
			break;
  800674:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800677:	e9 cb fc ff ff       	jmp    800347 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800680:	89 14 24             	mov    %edx,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800689:	e9 b9 fc ff ff       	jmp    800347 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800692:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800699:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006a0:	0f 84 a1 fc ff ff    	je     800347 <vprintfmt+0x23>
  8006a6:	83 ee 01             	sub    $0x1,%esi
  8006a9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ad:	75 f7                	jne    8006a6 <vprintfmt+0x382>
  8006af:	e9 93 fc ff ff       	jmp    800347 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006b4:	83 c4 4c             	add    $0x4c,%esp
  8006b7:	5b                   	pop    %ebx
  8006b8:	5e                   	pop    %esi
  8006b9:	5f                   	pop    %edi
  8006ba:	5d                   	pop    %ebp
  8006bb:	c3                   	ret    

008006bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	83 ec 28             	sub    $0x28,%esp
  8006c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	74 30                	je     80070d <vsnprintf+0x51>
  8006dd:	85 d2                	test   %edx,%edx
  8006df:	7e 2c                	jle    80070d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8006eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f6:	c7 04 24 df 02 80 00 	movl   $0x8002df,(%esp)
  8006fd:	e8 22 fc ff ff       	call   800324 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800702:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800705:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070b:	eb 05                	jmp    800712 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800721:	8b 45 10             	mov    0x10(%ebp),%eax
  800724:	89 44 24 08          	mov    %eax,0x8(%esp)
  800728:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072f:	8b 45 08             	mov    0x8(%ebp),%eax
  800732:	89 04 24             	mov    %eax,(%esp)
  800735:	e8 82 ff ff ff       	call   8006bc <vsnprintf>
	va_end(ap);

	return rc;
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    
  80073c:	00 00                	add    %al,(%eax)
	...

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	80 3a 00             	cmpb   $0x0,(%edx)
  80074e:	74 09                	je     800759 <strlen+0x19>
		n++;
  800750:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800753:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800757:	75 f7                	jne    800750 <strlen+0x10>
		n++;
	return n;
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	b8 00 00 00 00       	mov    $0x0,%eax
  80076a:	85 c9                	test   %ecx,%ecx
  80076c:	74 1a                	je     800788 <strnlen+0x2d>
  80076e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800771:	74 15                	je     800788 <strnlen+0x2d>
  800773:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800778:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077a:	39 ca                	cmp    %ecx,%edx
  80077c:	74 0a                	je     800788 <strnlen+0x2d>
  80077e:	83 c2 01             	add    $0x1,%edx
  800781:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800786:	75 f0                	jne    800778 <strnlen+0x1d>
		n++;
	return n;
}
  800788:	5b                   	pop    %ebx
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	53                   	push   %ebx
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800795:	ba 00 00 00 00       	mov    $0x0,%edx
  80079a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80079e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007a1:	83 c2 01             	add    $0x1,%edx
  8007a4:	84 c9                	test   %cl,%cl
  8007a6:	75 f2                	jne    80079a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a8:	5b                   	pop    %ebx
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b5:	89 1c 24             	mov    %ebx,(%esp)
  8007b8:	e8 83 ff ff ff       	call   800740 <strlen>
	strcpy(dst + len, src);
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c4:	01 d8                	add    %ebx,%eax
  8007c6:	89 04 24             	mov    %eax,(%esp)
  8007c9:	e8 bd ff ff ff       	call   80078b <strcpy>
	return dst;
}
  8007ce:	89 d8                	mov    %ebx,%eax
  8007d0:	83 c4 08             	add    $0x8,%esp
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e4:	85 f6                	test   %esi,%esi
  8007e6:	74 18                	je     800800 <strncpy+0x2a>
  8007e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007ed:	0f b6 1a             	movzbl (%edx),%ebx
  8007f0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f3:	80 3a 01             	cmpb   $0x1,(%edx)
  8007f6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f9:	83 c1 01             	add    $0x1,%ecx
  8007fc:	39 f1                	cmp    %esi,%ecx
  8007fe:	75 ed                	jne    8007ed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800800:	5b                   	pop    %ebx
  800801:	5e                   	pop    %esi
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	57                   	push   %edi
  800808:	56                   	push   %esi
  800809:	53                   	push   %ebx
  80080a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800810:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800813:	89 f8                	mov    %edi,%eax
  800815:	85 f6                	test   %esi,%esi
  800817:	74 2b                	je     800844 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800819:	83 fe 01             	cmp    $0x1,%esi
  80081c:	74 23                	je     800841 <strlcpy+0x3d>
  80081e:	0f b6 0b             	movzbl (%ebx),%ecx
  800821:	84 c9                	test   %cl,%cl
  800823:	74 1c                	je     800841 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800825:	83 ee 02             	sub    $0x2,%esi
  800828:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082d:	88 08                	mov    %cl,(%eax)
  80082f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800832:	39 f2                	cmp    %esi,%edx
  800834:	74 0b                	je     800841 <strlcpy+0x3d>
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80083d:	84 c9                	test   %cl,%cl
  80083f:	75 ec                	jne    80082d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800841:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800844:	29 f8                	sub    %edi,%eax
}
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5f                   	pop    %edi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800851:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800854:	0f b6 01             	movzbl (%ecx),%eax
  800857:	84 c0                	test   %al,%al
  800859:	74 16                	je     800871 <strcmp+0x26>
  80085b:	3a 02                	cmp    (%edx),%al
  80085d:	75 12                	jne    800871 <strcmp+0x26>
		p++, q++;
  80085f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800862:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800866:	84 c0                	test   %al,%al
  800868:	74 07                	je     800871 <strcmp+0x26>
  80086a:	83 c1 01             	add    $0x1,%ecx
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	74 ee                	je     80085f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800885:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800888:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088d:	85 d2                	test   %edx,%edx
  80088f:	74 28                	je     8008b9 <strncmp+0x3e>
  800891:	0f b6 01             	movzbl (%ecx),%eax
  800894:	84 c0                	test   %al,%al
  800896:	74 24                	je     8008bc <strncmp+0x41>
  800898:	3a 03                	cmp    (%ebx),%al
  80089a:	75 20                	jne    8008bc <strncmp+0x41>
  80089c:	83 ea 01             	sub    $0x1,%edx
  80089f:	74 13                	je     8008b4 <strncmp+0x39>
		n--, p++, q++;
  8008a1:	83 c1 01             	add    $0x1,%ecx
  8008a4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a7:	0f b6 01             	movzbl (%ecx),%eax
  8008aa:	84 c0                	test   %al,%al
  8008ac:	74 0e                	je     8008bc <strncmp+0x41>
  8008ae:	3a 03                	cmp    (%ebx),%al
  8008b0:	74 ea                	je     80089c <strncmp+0x21>
  8008b2:	eb 08                	jmp    8008bc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bc:	0f b6 01             	movzbl (%ecx),%eax
  8008bf:	0f b6 13             	movzbl (%ebx),%edx
  8008c2:	29 d0                	sub    %edx,%eax
  8008c4:	eb f3                	jmp    8008b9 <strncmp+0x3e>

008008c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d0:	0f b6 10             	movzbl (%eax),%edx
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	74 1c                	je     8008f3 <strchr+0x2d>
		if (*s == c)
  8008d7:	38 ca                	cmp    %cl,%dl
  8008d9:	75 09                	jne    8008e4 <strchr+0x1e>
  8008db:	eb 1b                	jmp    8008f8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008dd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8008e0:	38 ca                	cmp    %cl,%dl
  8008e2:	74 14                	je     8008f8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	75 f1                	jne    8008dd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f1:	eb 05                	jmp    8008f8 <strchr+0x32>
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	0f b6 10             	movzbl (%eax),%edx
  800907:	84 d2                	test   %dl,%dl
  800909:	74 14                	je     80091f <strfind+0x25>
		if (*s == c)
  80090b:	38 ca                	cmp    %cl,%dl
  80090d:	75 06                	jne    800915 <strfind+0x1b>
  80090f:	eb 0e                	jmp    80091f <strfind+0x25>
  800911:	38 ca                	cmp    %cl,%dl
  800913:	74 0a                	je     80091f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	0f b6 10             	movzbl (%eax),%edx
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f2                	jne    800911 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	83 ec 0c             	sub    $0xc,%esp
  800927:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80092a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80092d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800930:	8b 7d 08             	mov    0x8(%ebp),%edi
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 30                	je     80096d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800943:	75 25                	jne    80096a <memset+0x49>
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 20                	jne    80096a <memset+0x49>
		c &= 0xFF;
  80094a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094d:	89 d3                	mov    %edx,%ebx
  80094f:	c1 e3 08             	shl    $0x8,%ebx
  800952:	89 d6                	mov    %edx,%esi
  800954:	c1 e6 18             	shl    $0x18,%esi
  800957:	89 d0                	mov    %edx,%eax
  800959:	c1 e0 10             	shl    $0x10,%eax
  80095c:	09 f0                	or     %esi,%eax
  80095e:	09 d0                	or     %edx,%eax
  800960:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800962:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800965:	fc                   	cld    
  800966:	f3 ab                	rep stos %eax,%es:(%edi)
  800968:	eb 03                	jmp    80096d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096a:	fc                   	cld    
  80096b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096d:	89 f8                	mov    %edi,%eax
  80096f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800972:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800975:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800978:	89 ec                	mov    %ebp,%esp
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 08             	sub    $0x8,%esp
  800982:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800985:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800991:	39 c6                	cmp    %eax,%esi
  800993:	73 36                	jae    8009cb <memmove+0x4f>
  800995:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800998:	39 d0                	cmp    %edx,%eax
  80099a:	73 2f                	jae    8009cb <memmove+0x4f>
		s += n;
		d += n;
  80099c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	f6 c2 03             	test   $0x3,%dl
  8009a2:	75 1b                	jne    8009bf <memmove+0x43>
  8009a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009aa:	75 13                	jne    8009bf <memmove+0x43>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 20                	jmp    8009eb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d1:	75 13                	jne    8009e6 <memmove+0x6a>
  8009d3:	a8 03                	test   $0x3,%al
  8009d5:	75 0f                	jne    8009e6 <memmove+0x6a>
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 0a                	jne    8009e6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009dc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009df:	89 c7                	mov    %eax,%edi
  8009e1:	fc                   	cld    
  8009e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e4:	eb 05                	jmp    8009eb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009eb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009f1:	89 ec                	mov    %ebp,%esp
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	89 04 24             	mov    %eax,(%esp)
  800a0f:	e8 68 ff ff ff       	call   80097c <memmove>
}
  800a14:	c9                   	leave  
  800a15:	c3                   	ret    

00800a16 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	57                   	push   %edi
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a22:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2a:	85 ff                	test   %edi,%edi
  800a2c:	74 37                	je     800a65 <memcmp+0x4f>
		if (*s1 != *s2)
  800a2e:	0f b6 03             	movzbl (%ebx),%eax
  800a31:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a34:	83 ef 01             	sub    $0x1,%edi
  800a37:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a3c:	38 c8                	cmp    %cl,%al
  800a3e:	74 1c                	je     800a5c <memcmp+0x46>
  800a40:	eb 10                	jmp    800a52 <memcmp+0x3c>
  800a42:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a47:	83 c2 01             	add    $0x1,%edx
  800a4a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a4e:	38 c8                	cmp    %cl,%al
  800a50:	74 0a                	je     800a5c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800a52:	0f b6 c0             	movzbl %al,%eax
  800a55:	0f b6 c9             	movzbl %cl,%ecx
  800a58:	29 c8                	sub    %ecx,%eax
  800a5a:	eb 09                	jmp    800a65 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5c:	39 fa                	cmp    %edi,%edx
  800a5e:	75 e2                	jne    800a42 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a70:	89 c2                	mov    %eax,%edx
  800a72:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a75:	39 d0                	cmp    %edx,%eax
  800a77:	73 19                	jae    800a92 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a79:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a7d:	38 08                	cmp    %cl,(%eax)
  800a7f:	75 06                	jne    800a87 <memfind+0x1d>
  800a81:	eb 0f                	jmp    800a92 <memfind+0x28>
  800a83:	38 08                	cmp    %cl,(%eax)
  800a85:	74 0b                	je     800a92 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a87:	83 c0 01             	add    $0x1,%eax
  800a8a:	39 d0                	cmp    %edx,%eax
  800a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a90:	75 f1                	jne    800a83 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
  800a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa0:	0f b6 02             	movzbl (%edx),%eax
  800aa3:	3c 20                	cmp    $0x20,%al
  800aa5:	74 04                	je     800aab <strtol+0x17>
  800aa7:	3c 09                	cmp    $0x9,%al
  800aa9:	75 0e                	jne    800ab9 <strtol+0x25>
		s++;
  800aab:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aae:	0f b6 02             	movzbl (%edx),%eax
  800ab1:	3c 20                	cmp    $0x20,%al
  800ab3:	74 f6                	je     800aab <strtol+0x17>
  800ab5:	3c 09                	cmp    $0x9,%al
  800ab7:	74 f2                	je     800aab <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab9:	3c 2b                	cmp    $0x2b,%al
  800abb:	75 0a                	jne    800ac7 <strtol+0x33>
		s++;
  800abd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac5:	eb 10                	jmp    800ad7 <strtol+0x43>
  800ac7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acc:	3c 2d                	cmp    $0x2d,%al
  800ace:	75 07                	jne    800ad7 <strtol+0x43>
		s++, neg = 1;
  800ad0:	83 c2 01             	add    $0x1,%edx
  800ad3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad7:	85 db                	test   %ebx,%ebx
  800ad9:	0f 94 c0             	sete   %al
  800adc:	74 05                	je     800ae3 <strtol+0x4f>
  800ade:	83 fb 10             	cmp    $0x10,%ebx
  800ae1:	75 15                	jne    800af8 <strtol+0x64>
  800ae3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae6:	75 10                	jne    800af8 <strtol+0x64>
  800ae8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aec:	75 0a                	jne    800af8 <strtol+0x64>
		s += 2, base = 16;
  800aee:	83 c2 02             	add    $0x2,%edx
  800af1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af6:	eb 13                	jmp    800b0b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800af8:	84 c0                	test   %al,%al
  800afa:	74 0f                	je     800b0b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b01:	80 3a 30             	cmpb   $0x30,(%edx)
  800b04:	75 05                	jne    800b0b <strtol+0x77>
		s++, base = 8;
  800b06:	83 c2 01             	add    $0x1,%edx
  800b09:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b12:	0f b6 0a             	movzbl (%edx),%ecx
  800b15:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b18:	80 fb 09             	cmp    $0x9,%bl
  800b1b:	77 08                	ja     800b25 <strtol+0x91>
			dig = *s - '0';
  800b1d:	0f be c9             	movsbl %cl,%ecx
  800b20:	83 e9 30             	sub    $0x30,%ecx
  800b23:	eb 1e                	jmp    800b43 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b25:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b28:	80 fb 19             	cmp    $0x19,%bl
  800b2b:	77 08                	ja     800b35 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b2d:	0f be c9             	movsbl %cl,%ecx
  800b30:	83 e9 57             	sub    $0x57,%ecx
  800b33:	eb 0e                	jmp    800b43 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b35:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b38:	80 fb 19             	cmp    $0x19,%bl
  800b3b:	77 14                	ja     800b51 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b3d:	0f be c9             	movsbl %cl,%ecx
  800b40:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b43:	39 f1                	cmp    %esi,%ecx
  800b45:	7d 0e                	jge    800b55 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b47:	83 c2 01             	add    $0x1,%edx
  800b4a:	0f af c6             	imul   %esi,%eax
  800b4d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b4f:	eb c1                	jmp    800b12 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b51:	89 c1                	mov    %eax,%ecx
  800b53:	eb 02                	jmp    800b57 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b55:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5b:	74 05                	je     800b62 <strtol+0xce>
		*endptr = (char *) s;
  800b5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b60:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b62:	89 ca                	mov    %ecx,%edx
  800b64:	f7 da                	neg    %edx
  800b66:	85 ff                	test   %edi,%edi
  800b68:	0f 45 c2             	cmovne %edx,%eax
}
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b79:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b7c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b87:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8a:	89 c3                	mov    %eax,%ebx
  800b8c:	89 c7                	mov    %eax,%edi
  800b8e:	89 c6                	mov    %eax,%esi
  800b90:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b9b:	89 ec                	mov    %ebp,%esp
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ba8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb8:	89 d1                	mov    %edx,%ecx
  800bba:	89 d3                	mov    %edx,%ebx
  800bbc:	89 d7                	mov    %edx,%edi
  800bbe:	89 d6                	mov    %edx,%esi
  800bc0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bc5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bc8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bcb:	89 ec                	mov    %ebp,%esp
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	83 ec 38             	sub    $0x38,%esp
  800bd5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bd8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bdb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be3:	b8 03 00 00 00       	mov    $0x3,%eax
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	89 cb                	mov    %ecx,%ebx
  800bed:	89 cf                	mov    %ecx,%edi
  800bef:	89 ce                	mov    %ecx,%esi
  800bf1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 28                	jle    800c1f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bfb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c02:	00 
  800c03:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c12:	00 
  800c13:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800c1a:	e8 d5 02 00 00       	call   800ef4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c28:	89 ec                	mov    %ebp,%esp
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 0c             	sub    $0xc,%esp
  800c32:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c35:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c38:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 02 00 00 00       	mov    $0x2,%eax
  800c45:	89 d1                	mov    %edx,%ecx
  800c47:	89 d3                	mov    %edx,%ebx
  800c49:	89 d7                	mov    %edx,%edi
  800c4b:	89 d6                	mov    %edx,%esi
  800c4d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c58:	89 ec                	mov    %ebp,%esp
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_yield>:

void
sys_yield(void)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c65:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c68:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c70:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c75:	89 d1                	mov    %edx,%ecx
  800c77:	89 d3                	mov    %edx,%ebx
  800c79:	89 d7                	mov    %edx,%edi
  800c7b:	89 d6                	mov    %edx,%esi
  800c7d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c88:	89 ec                	mov    %ebp,%esp
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 38             	sub    $0x38,%esp
  800c92:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c95:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c98:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9b:	be 00 00 00 00       	mov    $0x0,%esi
  800ca0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cab:	8b 55 08             	mov    0x8(%ebp),%edx
  800cae:	89 f7                	mov    %esi,%edi
  800cb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7e 28                	jle    800cde <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cba:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cc1:	00 
  800cc2:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800cc9:	00 
  800cca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd1:	00 
  800cd2:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800cd9:	e8 16 02 00 00       	call   800ef4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cde:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce7:	89 ec                	mov    %ebp,%esp
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 38             	sub    $0x38,%esp
  800cf1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800cff:	8b 75 18             	mov    0x18(%ebp),%esi
  800d02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d10:	85 c0                	test   %eax,%eax
  800d12:	7e 28                	jle    800d3c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d14:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d18:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d1f:	00 
  800d20:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800d27:	00 
  800d28:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2f:	00 
  800d30:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800d37:	e8 b8 01 00 00       	call   800ef4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d3c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d3f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d42:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d45:	89 ec                	mov    %ebp,%esp
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	83 ec 38             	sub    $0x38,%esp
  800d4f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d52:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d55:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	89 df                	mov    %ebx,%edi
  800d6a:	89 de                	mov    %ebx,%esi
  800d6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	7e 28                	jle    800d9a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d76:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d7d:	00 
  800d7e:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800d85:	00 
  800d86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8d:	00 
  800d8e:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800d95:	e8 5a 01 00 00       	call   800ef4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d9a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d9d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da3:	89 ec                	mov    %ebp,%esp
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	83 ec 38             	sub    $0x38,%esp
  800dad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 df                	mov    %ebx,%edi
  800dc8:	89 de                	mov    %ebx,%esi
  800dca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 28                	jle    800df8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800df3:	e8 fc 00 00 00       	call   800ef4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dfb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e01:	89 ec                	mov    %ebp,%esp
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 38             	sub    $0x38,%esp
  800e0b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e0e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e11:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e19:	b8 09 00 00 00       	mov    $0x9,%eax
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	89 df                	mov    %ebx,%edi
  800e26:	89 de                	mov    %ebx,%esi
  800e28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	7e 28                	jle    800e56 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e32:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e39:	00 
  800e3a:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800e41:	00 
  800e42:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e49:	00 
  800e4a:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800e51:	e8 9e 00 00 00       	call   800ef4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e56:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e59:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e5c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5f:	89 ec                	mov    %ebp,%esp
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	83 ec 0c             	sub    $0xc,%esp
  800e69:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e6c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e6f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e72:	be 00 00 00 00       	mov    $0x0,%esi
  800e77:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e7c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e8a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e8d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e90:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e93:	89 ec                	mov    %ebp,%esp
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800ea6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eab:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 cb                	mov    %ecx,%ebx
  800eb5:	89 cf                	mov    %ecx,%edi
  800eb7:	89 ce                	mov    %ecx,%esi
  800eb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	7e 28                	jle    800ee7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800eca:	00 
  800ecb:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800ed2:	00 
  800ed3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eda:	00 
  800edb:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800ee2:	e8 0d 00 00 00       	call   800ef4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eed:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef0:	89 ec                	mov    %ebp,%esp
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800efc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800eff:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f05:	e8 22 fd ff ff       	call   800c2c <sys_getenvid>
  800f0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f18:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f20:	c7 04 24 90 14 80 00 	movl   $0x801490,(%esp)
  800f27:	e8 3b f2 ff ff       	call   800167 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f2c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f30:	8b 45 10             	mov    0x10(%ebp),%eax
  800f33:	89 04 24             	mov    %eax,(%esp)
  800f36:	e8 cb f1 ff ff       	call   800106 <vcprintf>
	cprintf("\n");
  800f3b:	c7 04 24 1c 12 80 00 	movl   $0x80121c,(%esp)
  800f42:	e8 20 f2 ff ff       	call   800167 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f47:	cc                   	int3   
  800f48:	eb fd                	jmp    800f47 <_panic+0x53>
  800f4a:	00 00                	add    %al,(%eax)
  800f4c:	00 00                	add    %al,(%eax)
	...

00800f50 <__udivdi3>:
  800f50:	83 ec 1c             	sub    $0x1c,%esp
  800f53:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f57:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f5b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f5f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f63:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f67:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f6b:	85 ff                	test   %edi,%edi
  800f6d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f75:	89 cd                	mov    %ecx,%ebp
  800f77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7b:	75 33                	jne    800fb0 <__udivdi3+0x60>
  800f7d:	39 f1                	cmp    %esi,%ecx
  800f7f:	77 57                	ja     800fd8 <__udivdi3+0x88>
  800f81:	85 c9                	test   %ecx,%ecx
  800f83:	75 0b                	jne    800f90 <__udivdi3+0x40>
  800f85:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8a:	31 d2                	xor    %edx,%edx
  800f8c:	f7 f1                	div    %ecx
  800f8e:	89 c1                	mov    %eax,%ecx
  800f90:	89 f0                	mov    %esi,%eax
  800f92:	31 d2                	xor    %edx,%edx
  800f94:	f7 f1                	div    %ecx
  800f96:	89 c6                	mov    %eax,%esi
  800f98:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f9c:	f7 f1                	div    %ecx
  800f9e:	89 f2                	mov    %esi,%edx
  800fa0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fa4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fa8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fac:	83 c4 1c             	add    $0x1c,%esp
  800faf:	c3                   	ret    
  800fb0:	31 d2                	xor    %edx,%edx
  800fb2:	31 c0                	xor    %eax,%eax
  800fb4:	39 f7                	cmp    %esi,%edi
  800fb6:	77 e8                	ja     800fa0 <__udivdi3+0x50>
  800fb8:	0f bd cf             	bsr    %edi,%ecx
  800fbb:	83 f1 1f             	xor    $0x1f,%ecx
  800fbe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fc2:	75 2c                	jne    800ff0 <__udivdi3+0xa0>
  800fc4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fc8:	76 04                	jbe    800fce <__udivdi3+0x7e>
  800fca:	39 f7                	cmp    %esi,%edi
  800fcc:	73 d2                	jae    800fa0 <__udivdi3+0x50>
  800fce:	31 d2                	xor    %edx,%edx
  800fd0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd5:	eb c9                	jmp    800fa0 <__udivdi3+0x50>
  800fd7:	90                   	nop
  800fd8:	89 f2                	mov    %esi,%edx
  800fda:	f7 f1                	div    %ecx
  800fdc:	31 d2                	xor    %edx,%edx
  800fde:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fe2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fe6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fea:	83 c4 1c             	add    $0x1c,%esp
  800fed:	c3                   	ret    
  800fee:	66 90                	xchg   %ax,%ax
  800ff0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ff5:	b8 20 00 00 00       	mov    $0x20,%eax
  800ffa:	89 ea                	mov    %ebp,%edx
  800ffc:	2b 44 24 04          	sub    0x4(%esp),%eax
  801000:	d3 e7                	shl    %cl,%edi
  801002:	89 c1                	mov    %eax,%ecx
  801004:	d3 ea                	shr    %cl,%edx
  801006:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80100b:	09 fa                	or     %edi,%edx
  80100d:	89 f7                	mov    %esi,%edi
  80100f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801013:	89 f2                	mov    %esi,%edx
  801015:	8b 74 24 08          	mov    0x8(%esp),%esi
  801019:	d3 e5                	shl    %cl,%ebp
  80101b:	89 c1                	mov    %eax,%ecx
  80101d:	d3 ef                	shr    %cl,%edi
  80101f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801024:	d3 e2                	shl    %cl,%edx
  801026:	89 c1                	mov    %eax,%ecx
  801028:	d3 ee                	shr    %cl,%esi
  80102a:	09 d6                	or     %edx,%esi
  80102c:	89 fa                	mov    %edi,%edx
  80102e:	89 f0                	mov    %esi,%eax
  801030:	f7 74 24 0c          	divl   0xc(%esp)
  801034:	89 d7                	mov    %edx,%edi
  801036:	89 c6                	mov    %eax,%esi
  801038:	f7 e5                	mul    %ebp
  80103a:	39 d7                	cmp    %edx,%edi
  80103c:	72 22                	jb     801060 <__udivdi3+0x110>
  80103e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801042:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801047:	d3 e5                	shl    %cl,%ebp
  801049:	39 c5                	cmp    %eax,%ebp
  80104b:	73 04                	jae    801051 <__udivdi3+0x101>
  80104d:	39 d7                	cmp    %edx,%edi
  80104f:	74 0f                	je     801060 <__udivdi3+0x110>
  801051:	89 f0                	mov    %esi,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	e9 46 ff ff ff       	jmp    800fa0 <__udivdi3+0x50>
  80105a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801060:	8d 46 ff             	lea    -0x1(%esi),%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	8b 74 24 10          	mov    0x10(%esp),%esi
  801069:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80106d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801071:	83 c4 1c             	add    $0x1c,%esp
  801074:	c3                   	ret    
	...

00801080 <__umoddi3>:
  801080:	83 ec 1c             	sub    $0x1c,%esp
  801083:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801087:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80108b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80108f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801093:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801097:	8b 74 24 24          	mov    0x24(%esp),%esi
  80109b:	85 ed                	test   %ebp,%ebp
  80109d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a5:	89 cf                	mov    %ecx,%edi
  8010a7:	89 04 24             	mov    %eax,(%esp)
  8010aa:	89 f2                	mov    %esi,%edx
  8010ac:	75 1a                	jne    8010c8 <__umoddi3+0x48>
  8010ae:	39 f1                	cmp    %esi,%ecx
  8010b0:	76 4e                	jbe    801100 <__umoddi3+0x80>
  8010b2:	f7 f1                	div    %ecx
  8010b4:	89 d0                	mov    %edx,%eax
  8010b6:	31 d2                	xor    %edx,%edx
  8010b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010c4:	83 c4 1c             	add    $0x1c,%esp
  8010c7:	c3                   	ret    
  8010c8:	39 f5                	cmp    %esi,%ebp
  8010ca:	77 54                	ja     801120 <__umoddi3+0xa0>
  8010cc:	0f bd c5             	bsr    %ebp,%eax
  8010cf:	83 f0 1f             	xor    $0x1f,%eax
  8010d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d6:	75 60                	jne    801138 <__umoddi3+0xb8>
  8010d8:	3b 0c 24             	cmp    (%esp),%ecx
  8010db:	0f 87 07 01 00 00    	ja     8011e8 <__umoddi3+0x168>
  8010e1:	89 f2                	mov    %esi,%edx
  8010e3:	8b 34 24             	mov    (%esp),%esi
  8010e6:	29 ce                	sub    %ecx,%esi
  8010e8:	19 ea                	sbb    %ebp,%edx
  8010ea:	89 34 24             	mov    %esi,(%esp)
  8010ed:	8b 04 24             	mov    (%esp),%eax
  8010f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010fc:	83 c4 1c             	add    $0x1c,%esp
  8010ff:	c3                   	ret    
  801100:	85 c9                	test   %ecx,%ecx
  801102:	75 0b                	jne    80110f <__umoddi3+0x8f>
  801104:	b8 01 00 00 00       	mov    $0x1,%eax
  801109:	31 d2                	xor    %edx,%edx
  80110b:	f7 f1                	div    %ecx
  80110d:	89 c1                	mov    %eax,%ecx
  80110f:	89 f0                	mov    %esi,%eax
  801111:	31 d2                	xor    %edx,%edx
  801113:	f7 f1                	div    %ecx
  801115:	8b 04 24             	mov    (%esp),%eax
  801118:	f7 f1                	div    %ecx
  80111a:	eb 98                	jmp    8010b4 <__umoddi3+0x34>
  80111c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801120:	89 f2                	mov    %esi,%edx
  801122:	8b 74 24 10          	mov    0x10(%esp),%esi
  801126:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80112a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80112e:	83 c4 1c             	add    $0x1c,%esp
  801131:	c3                   	ret    
  801132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801138:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80113d:	89 e8                	mov    %ebp,%eax
  80113f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801144:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801148:	89 fa                	mov    %edi,%edx
  80114a:	d3 e0                	shl    %cl,%eax
  80114c:	89 e9                	mov    %ebp,%ecx
  80114e:	d3 ea                	shr    %cl,%edx
  801150:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801155:	09 c2                	or     %eax,%edx
  801157:	8b 44 24 08          	mov    0x8(%esp),%eax
  80115b:	89 14 24             	mov    %edx,(%esp)
  80115e:	89 f2                	mov    %esi,%edx
  801160:	d3 e7                	shl    %cl,%edi
  801162:	89 e9                	mov    %ebp,%ecx
  801164:	d3 ea                	shr    %cl,%edx
  801166:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80116b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80116f:	d3 e6                	shl    %cl,%esi
  801171:	89 e9                	mov    %ebp,%ecx
  801173:	d3 e8                	shr    %cl,%eax
  801175:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80117a:	09 f0                	or     %esi,%eax
  80117c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801180:	f7 34 24             	divl   (%esp)
  801183:	d3 e6                	shl    %cl,%esi
  801185:	89 74 24 08          	mov    %esi,0x8(%esp)
  801189:	89 d6                	mov    %edx,%esi
  80118b:	f7 e7                	mul    %edi
  80118d:	39 d6                	cmp    %edx,%esi
  80118f:	89 c1                	mov    %eax,%ecx
  801191:	89 d7                	mov    %edx,%edi
  801193:	72 3f                	jb     8011d4 <__umoddi3+0x154>
  801195:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801199:	72 35                	jb     8011d0 <__umoddi3+0x150>
  80119b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80119f:	29 c8                	sub    %ecx,%eax
  8011a1:	19 fe                	sbb    %edi,%esi
  8011a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011a8:	89 f2                	mov    %esi,%edx
  8011aa:	d3 e8                	shr    %cl,%eax
  8011ac:	89 e9                	mov    %ebp,%ecx
  8011ae:	d3 e2                	shl    %cl,%edx
  8011b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011b5:	09 d0                	or     %edx,%eax
  8011b7:	89 f2                	mov    %esi,%edx
  8011b9:	d3 ea                	shr    %cl,%edx
  8011bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c7:	83 c4 1c             	add    $0x1c,%esp
  8011ca:	c3                   	ret    
  8011cb:	90                   	nop
  8011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	39 d6                	cmp    %edx,%esi
  8011d2:	75 c7                	jne    80119b <__umoddi3+0x11b>
  8011d4:	89 d7                	mov    %edx,%edi
  8011d6:	89 c1                	mov    %eax,%ecx
  8011d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011dc:	1b 3c 24             	sbb    (%esp),%edi
  8011df:	eb ba                	jmp    80119b <__umoddi3+0x11b>
  8011e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	39 f5                	cmp    %esi,%ebp
  8011ea:	0f 82 f1 fe ff ff    	jb     8010e1 <__umoddi3+0x61>
  8011f0:	e9 f8 fe ff ff       	jmp    8010ed <__umoddi3+0x6d>
