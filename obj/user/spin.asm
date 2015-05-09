
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 00 16 80 00 	movl   $0x801600,(%esp)
  80004e:	e8 80 01 00 00       	call   8001d3 <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 e3 0f 00 00       	call   80103b <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 78 16 80 00 	movl   $0x801678,(%esp)
  800065:	e8 69 01 00 00       	call   8001d3 <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 28 16 80 00 	movl   $0x801628,(%esp)
  800073:	e8 5b 01 00 00       	call   8001d3 <cprintf>
	sys_yield();
  800078:	e8 3f 0c 00 00       	call   800cbc <sys_yield>
	sys_yield();
  80007d:	e8 3a 0c 00 00       	call   800cbc <sys_yield>
	sys_yield();
  800082:	e8 35 0c 00 00       	call   800cbc <sys_yield>
	sys_yield();
  800087:	e8 30 0c 00 00       	call   800cbc <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 27 0c 00 00       	call   800cbc <sys_yield>
	sys_yield();
  800095:	e8 22 0c 00 00       	call   800cbc <sys_yield>
	sys_yield();
  80009a:	e8 1d 0c 00 00       	call   800cbc <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 17 0c 00 00       	call   800cbc <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 50 16 80 00 	movl   $0x801650,(%esp)
  8000ac:	e8 22 01 00 00       	call   8001d3 <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 76 0b 00 00       	call   800c2f <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    
	...

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
  8000c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000c9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000d2:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000d9:	00 00 00 
	envid_t envid = sys_getenvid();
  8000dc:	e8 ab 0b 00 00       	call   800c8c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  8000e1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ee:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f3:	85 f6                	test   %esi,%esi
  8000f5:	7e 07                	jle    8000fe <libmain+0x3e>
		binaryname = argv[0];
  8000f7:	8b 03                	mov    (%ebx),%eax
  8000f9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800102:	89 34 24             	mov    %esi,(%esp)
  800105:	e8 36 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80010a:	e8 0d 00 00 00       	call   80011c <exit>
}
  80010f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800112:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800115:	89 ec                	mov    %ebp,%esp
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    
  800119:	00 00                	add    %al,(%eax)
	...

0080011c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800122:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800129:	e8 01 0b 00 00       	call   800c2f <sys_env_destroy>
}
  80012e:	c9                   	leave  
  80012f:	c3                   	ret    

00800130 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	53                   	push   %ebx
  800134:	83 ec 14             	sub    $0x14,%esp
  800137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013a:	8b 03                	mov    (%ebx),%eax
  80013c:	8b 55 08             	mov    0x8(%ebp),%edx
  80013f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800143:	83 c0 01             	add    $0x1,%eax
  800146:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800148:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014d:	75 19                	jne    800168 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80014f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800156:	00 
  800157:	8d 43 08             	lea    0x8(%ebx),%eax
  80015a:	89 04 24             	mov    %eax,(%esp)
  80015d:	e8 6e 0a 00 00       	call   800bd0 <sys_cputs>
		b->idx = 0;
  800162:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800168:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80016c:	83 c4 14             	add    $0x14,%esp
  80016f:	5b                   	pop    %ebx
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80017b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800182:	00 00 00 
	b.cnt = 0;
  800185:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a7:	c7 04 24 30 01 80 00 	movl   $0x800130,(%esp)
  8001ae:	e8 d1 01 00 00       	call   800384 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c3:	89 04 24             	mov    %eax,(%esp)
  8001c6:	e8 05 0a 00 00       	call   800bd0 <sys_cputs>

	return b.cnt;
}
  8001cb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e3:	89 04 24             	mov    %eax,(%esp)
  8001e6:	e8 87 ff ff ff       	call   800172 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001eb:	c9                   	leave  
  8001ec:	c3                   	ret    
  8001ed:	00 00                	add    %al,(%eax)
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 3c             	sub    $0x3c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d7                	mov    %edx,%edi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80020d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800210:	b8 00 00 00 00       	mov    $0x0,%eax
  800215:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800218:	72 11                	jb     80022b <printnum+0x3b>
  80021a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800220:	76 09                	jbe    80022b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800222:	83 eb 01             	sub    $0x1,%ebx
  800225:	85 db                	test   %ebx,%ebx
  800227:	7f 51                	jg     80027a <printnum+0x8a>
  800229:	eb 5e                	jmp    800289 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800236:	8b 45 10             	mov    0x10(%ebp),%eax
  800239:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800241:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800245:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024c:	00 
  80024d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025a:	e8 f1 10 00 00       	call   801350 <__udivdi3>
  80025f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800263:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026e:	89 fa                	mov    %edi,%edx
  800270:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800273:	e8 78 ff ff ff       	call   8001f0 <printnum>
  800278:	eb 0f                	jmp    800289 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027e:	89 34 24             	mov    %esi,(%esp)
  800281:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800284:	83 eb 01             	sub    $0x1,%ebx
  800287:	75 f1                	jne    80027a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800289:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80028d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800291:	8b 45 10             	mov    0x10(%ebp),%eax
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029f:	00 
  8002a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ad:	e8 ce 11 00 00       	call   801480 <__umoddi3>
  8002b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b6:	0f be 80 a0 16 80 00 	movsbl 0x8016a0(%eax),%eax
  8002bd:	89 04 24             	mov    %eax,(%esp)
  8002c0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002c3:	83 c4 3c             	add    $0x3c,%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ce:	83 fa 01             	cmp    $0x1,%edx
  8002d1:	7e 0e                	jle    8002e1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	8b 52 04             	mov    0x4(%edx),%edx
  8002df:	eb 22                	jmp    800303 <getuint+0x38>
	else if (lflag)
  8002e1:	85 d2                	test   %edx,%edx
  8002e3:	74 10                	je     8002f5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f3:	eb 0e                	jmp    800303 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 02                	mov    (%edx),%eax
  8002fe:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800308:	83 fa 01             	cmp    $0x1,%edx
  80030b:	7e 0e                	jle    80031b <getint+0x16>
		return va_arg(*ap, long long);
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800312:	89 08                	mov    %ecx,(%eax)
  800314:	8b 02                	mov    (%edx),%eax
  800316:	8b 52 04             	mov    0x4(%edx),%edx
  800319:	eb 22                	jmp    80033d <getint+0x38>
	else if (lflag)
  80031b:	85 d2                	test   %edx,%edx
  80031d:	74 10                	je     80032f <getint+0x2a>
		return va_arg(*ap, long);
  80031f:	8b 10                	mov    (%eax),%edx
  800321:	8d 4a 04             	lea    0x4(%edx),%ecx
  800324:	89 08                	mov    %ecx,(%eax)
  800326:	8b 02                	mov    (%edx),%eax
  800328:	89 c2                	mov    %eax,%edx
  80032a:	c1 fa 1f             	sar    $0x1f,%edx
  80032d:	eb 0e                	jmp    80033d <getint+0x38>
	else
		return va_arg(*ap, int);
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	8d 4a 04             	lea    0x4(%edx),%ecx
  800334:	89 08                	mov    %ecx,(%eax)
  800336:	8b 02                	mov    (%edx),%eax
  800338:	89 c2                	mov    %eax,%edx
  80033a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800345:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	3b 50 04             	cmp    0x4(%eax),%edx
  80034e:	73 0a                	jae    80035a <sprintputch+0x1b>
		*b->buf++ = ch;
  800350:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800353:	88 0a                	mov    %cl,(%edx)
  800355:	83 c2 01             	add    $0x1,%edx
  800358:	89 10                	mov    %edx,(%eax)
}
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    

0080035c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800362:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800365:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800369:	8b 45 10             	mov    0x10(%ebp),%eax
  80036c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800370:	8b 45 0c             	mov    0xc(%ebp),%eax
  800373:	89 44 24 04          	mov    %eax,0x4(%esp)
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	89 04 24             	mov    %eax,(%esp)
  80037d:	e8 02 00 00 00       	call   800384 <vprintfmt>
	va_end(ap);
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
  80038a:	83 ec 4c             	sub    $0x4c,%esp
  80038d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800390:	8b 75 10             	mov    0x10(%ebp),%esi
  800393:	eb 12                	jmp    8003a7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800395:	85 c0                	test   %eax,%eax
  800397:	0f 84 77 03 00 00    	je     800714 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  80039d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003a1:	89 04 24             	mov    %eax,(%esp)
  8003a4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a7:	0f b6 06             	movzbl (%esi),%eax
  8003aa:	83 c6 01             	add    $0x1,%esi
  8003ad:	83 f8 25             	cmp    $0x25,%eax
  8003b0:	75 e3                	jne    800395 <vprintfmt+0x11>
  8003b2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003c2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ce:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003d1:	eb 2b                	jmp    8003fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003da:	eb 22                	jmp    8003fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003df:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003e3:	eb 19                	jmp    8003fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003ef:	eb 0d                	jmp    8003fe <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	0f b6 06             	movzbl (%esi),%eax
  800401:	0f b6 d0             	movzbl %al,%edx
  800404:	8d 7e 01             	lea    0x1(%esi),%edi
  800407:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80040a:	83 e8 23             	sub    $0x23,%eax
  80040d:	3c 55                	cmp    $0x55,%al
  80040f:	0f 87 d9 02 00 00    	ja     8006ee <vprintfmt+0x36a>
  800415:	0f b6 c0             	movzbl %al,%eax
  800418:	ff 24 85 60 17 80 00 	jmp    *0x801760(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80041f:	83 ea 30             	sub    $0x30,%edx
  800422:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800425:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800429:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80042f:	83 fa 09             	cmp    $0x9,%edx
  800432:	77 4a                	ja     80047e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800437:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80043a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80043d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800441:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800444:	8d 50 d0             	lea    -0x30(%eax),%edx
  800447:	83 fa 09             	cmp    $0x9,%edx
  80044a:	76 eb                	jbe    800437 <vprintfmt+0xb3>
  80044c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80044f:	eb 2d                	jmp    80047e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800462:	eb 1a                	jmp    80047e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800467:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046b:	79 91                	jns    8003fe <vprintfmt+0x7a>
  80046d:	e9 73 ff ff ff       	jmp    8003e5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800475:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80047c:	eb 80                	jmp    8003fe <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80047e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800482:	0f 89 76 ff ff ff    	jns    8003fe <vprintfmt+0x7a>
  800488:	e9 64 ff ff ff       	jmp    8003f1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800493:	e9 66 ff ff ff       	jmp    8003fe <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8d 50 04             	lea    0x4(%eax),%edx
  80049e:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a5:	8b 00                	mov    (%eax),%eax
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b0:	e9 f2 fe ff ff       	jmp    8003a7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 50 04             	lea    0x4(%eax),%edx
  8004bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	89 c2                	mov    %eax,%edx
  8004c2:	c1 fa 1f             	sar    $0x1f,%edx
  8004c5:	31 d0                	xor    %edx,%eax
  8004c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c9:	83 f8 08             	cmp    $0x8,%eax
  8004cc:	7f 0b                	jg     8004d9 <vprintfmt+0x155>
  8004ce:	8b 14 85 c0 18 80 00 	mov    0x8018c0(,%eax,4),%edx
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	75 23                	jne    8004fc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004dd:	c7 44 24 08 b8 16 80 	movl   $0x8016b8,0x8(%esp)
  8004e4:	00 
  8004e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004ec:	89 3c 24             	mov    %edi,(%esp)
  8004ef:	e8 68 fe ff ff       	call   80035c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f7:	e9 ab fe ff ff       	jmp    8003a7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800500:	c7 44 24 08 c1 16 80 	movl   $0x8016c1,0x8(%esp)
  800507:	00 
  800508:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80050f:	89 3c 24             	mov    %edi,(%esp)
  800512:	e8 45 fe ff ff       	call   80035c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051a:	e9 88 fe ff ff       	jmp    8003a7 <vprintfmt+0x23>
  80051f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800522:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800525:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800533:	85 f6                	test   %esi,%esi
  800535:	ba b1 16 80 00       	mov    $0x8016b1,%edx
  80053a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80053d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800541:	7e 06                	jle    800549 <vprintfmt+0x1c5>
  800543:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800547:	75 10                	jne    800559 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800549:	0f be 06             	movsbl (%esi),%eax
  80054c:	83 c6 01             	add    $0x1,%esi
  80054f:	85 c0                	test   %eax,%eax
  800551:	0f 85 86 00 00 00    	jne    8005dd <vprintfmt+0x259>
  800557:	eb 76                	jmp    8005cf <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800559:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055d:	89 34 24             	mov    %esi,(%esp)
  800560:	e8 56 02 00 00       	call   8007bb <strnlen>
  800565:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800568:	29 c2                	sub    %eax,%edx
  80056a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80056d:	85 d2                	test   %edx,%edx
  80056f:	7e d8                	jle    800549 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800571:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800575:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800578:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80057b:	89 d6                	mov    %edx,%esi
  80057d:	89 c7                	mov    %eax,%edi
  80057f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800583:	89 3c 24             	mov    %edi,(%esp)
  800586:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800589:	83 ee 01             	sub    $0x1,%esi
  80058c:	75 f1                	jne    80057f <vprintfmt+0x1fb>
  80058e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800591:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800594:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800597:	eb b0                	jmp    800549 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800599:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059d:	74 18                	je     8005b7 <vprintfmt+0x233>
  80059f:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a2:	83 fa 5e             	cmp    $0x5e,%edx
  8005a5:	76 10                	jbe    8005b7 <vprintfmt+0x233>
					putch('?', putdat);
  8005a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ab:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b2:	ff 55 08             	call   *0x8(%ebp)
  8005b5:	eb 0a                	jmp    8005c1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  8005b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005c5:	0f be 06             	movsbl (%esi),%eax
  8005c8:	83 c6 01             	add    $0x1,%esi
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	75 0e                	jne    8005dd <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d6:	7f 11                	jg     8005e9 <vprintfmt+0x265>
  8005d8:	e9 ca fd ff ff       	jmp    8003a7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005dd:	85 ff                	test   %edi,%edi
  8005df:	90                   	nop
  8005e0:	78 b7                	js     800599 <vprintfmt+0x215>
  8005e2:	83 ef 01             	sub    $0x1,%edi
  8005e5:	79 b2                	jns    800599 <vprintfmt+0x215>
  8005e7:	eb e6                	jmp    8005cf <vprintfmt+0x24b>
  8005e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005ec:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005fa:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fc:	83 ee 01             	sub    $0x1,%esi
  8005ff:	75 ee                	jne    8005ef <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800604:	e9 9e fd ff ff       	jmp    8003a7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800609:	89 ca                	mov    %ecx,%edx
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 f2 fc ff ff       	call   800305 <getint>
  800613:	89 c6                	mov    %eax,%esi
  800615:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800617:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061c:	85 d2                	test   %edx,%edx
  80061e:	0f 89 8c 00 00 00    	jns    8006b0 <vprintfmt+0x32c>
				putch('-', putdat);
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800632:	f7 de                	neg    %esi
  800634:	83 d7 00             	adc    $0x0,%edi
  800637:	f7 df                	neg    %edi
			}
			base = 10;
  800639:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063e:	eb 70                	jmp    8006b0 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800640:	89 ca                	mov    %ecx,%edx
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 81 fc ff ff       	call   8002cb <getuint>
  80064a:	89 c6                	mov    %eax,%esi
  80064c:	89 d7                	mov    %edx,%edi
			base = 10;
  80064e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800653:	eb 5b                	jmp    8006b0 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  800655:	89 ca                	mov    %ecx,%edx
  800657:	8d 45 14             	lea    0x14(%ebp),%eax
  80065a:	e8 a6 fc ff ff       	call   800305 <getint>
  80065f:	89 c6                	mov    %eax,%esi
  800661:	89 d7                	mov    %edx,%edi
			base = 8;
  800663:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800668:	eb 46                	jmp    8006b0 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80066a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800675:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068f:	8b 30                	mov    (%eax),%esi
  800691:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800696:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80069b:	eb 13                	jmp    8006b0 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069d:	89 ca                	mov    %ecx,%edx
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a2:	e8 24 fc ff ff       	call   8002cb <getuint>
  8006a7:	89 c6                	mov    %eax,%esi
  8006a9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006ab:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006b4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c3:	89 34 24             	mov    %esi,(%esp)
  8006c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ca:	89 da                	mov    %ebx,%edx
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	e8 1c fb ff ff       	call   8001f0 <printnum>
			break;
  8006d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d7:	e9 cb fc ff ff       	jmp    8003a7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e0:	89 14 24             	mov    %edx,(%esp)
  8006e3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e9:	e9 b9 fc ff ff       	jmp    8003a7 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800700:	0f 84 a1 fc ff ff    	je     8003a7 <vprintfmt+0x23>
  800706:	83 ee 01             	sub    $0x1,%esi
  800709:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80070d:	75 f7                	jne    800706 <vprintfmt+0x382>
  80070f:	e9 93 fc ff ff       	jmp    8003a7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800714:	83 c4 4c             	add    $0x4c,%esp
  800717:	5b                   	pop    %ebx
  800718:	5e                   	pop    %esi
  800719:	5f                   	pop    %edi
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	83 ec 28             	sub    $0x28,%esp
  800722:	8b 45 08             	mov    0x8(%ebp),%eax
  800725:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800728:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800732:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800739:	85 c0                	test   %eax,%eax
  80073b:	74 30                	je     80076d <vsnprintf+0x51>
  80073d:	85 d2                	test   %edx,%edx
  80073f:	7e 2c                	jle    80076d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800748:	8b 45 10             	mov    0x10(%ebp),%eax
  80074b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800752:	89 44 24 04          	mov    %eax,0x4(%esp)
  800756:	c7 04 24 3f 03 80 00 	movl   $0x80033f,(%esp)
  80075d:	e8 22 fc ff ff       	call   800384 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800762:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800765:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800768:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076b:	eb 05                	jmp    800772 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800781:	8b 45 10             	mov    0x10(%ebp),%eax
  800784:	89 44 24 08          	mov    %eax,0x8(%esp)
  800788:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	89 04 24             	mov    %eax,(%esp)
  800795:	e8 82 ff ff ff       	call   80071c <vsnprintf>
	va_end(ap);

	return rc;
}
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    
  80079c:	00 00                	add    %al,(%eax)
	...

008007a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ae:	74 09                	je     8007b9 <strlen+0x19>
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b7:	75 f7                	jne    8007b0 <strlen+0x10>
		n++;
	return n;
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ca:	85 c9                	test   %ecx,%ecx
  8007cc:	74 1a                	je     8007e8 <strnlen+0x2d>
  8007ce:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007d1:	74 15                	je     8007e8 <strnlen+0x2d>
  8007d3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007d8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	39 ca                	cmp    %ecx,%edx
  8007dc:	74 0a                	je     8007e8 <strnlen+0x2d>
  8007de:	83 c2 01             	add    $0x1,%edx
  8007e1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007e6:	75 f0                	jne    8007d8 <strnlen+0x1d>
		n++;
	return n;
}
  8007e8:	5b                   	pop    %ebx
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007fe:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	84 c9                	test   %cl,%cl
  800806:	75 f2                	jne    8007fa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800808:	5b                   	pop    %ebx
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800815:	89 1c 24             	mov    %ebx,(%esp)
  800818:	e8 83 ff ff ff       	call   8007a0 <strlen>
	strcpy(dst + len, src);
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800820:	89 54 24 04          	mov    %edx,0x4(%esp)
  800824:	01 d8                	add    %ebx,%eax
  800826:	89 04 24             	mov    %eax,(%esp)
  800829:	e8 bd ff ff ff       	call   8007eb <strcpy>
	return dst;
}
  80082e:	89 d8                	mov    %ebx,%eax
  800830:	83 c4 08             	add    $0x8,%esp
  800833:	5b                   	pop    %ebx
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	56                   	push   %esi
  80083a:	53                   	push   %ebx
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800844:	85 f6                	test   %esi,%esi
  800846:	74 18                	je     800860 <strncpy+0x2a>
  800848:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80084d:	0f b6 1a             	movzbl (%edx),%ebx
  800850:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800853:	80 3a 01             	cmpb   $0x1,(%edx)
  800856:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	83 c1 01             	add    $0x1,%ecx
  80085c:	39 f1                	cmp    %esi,%ecx
  80085e:	75 ed                	jne    80084d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	57                   	push   %edi
  800868:	56                   	push   %esi
  800869:	53                   	push   %ebx
  80086a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800870:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800873:	89 f8                	mov    %edi,%eax
  800875:	85 f6                	test   %esi,%esi
  800877:	74 2b                	je     8008a4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800879:	83 fe 01             	cmp    $0x1,%esi
  80087c:	74 23                	je     8008a1 <strlcpy+0x3d>
  80087e:	0f b6 0b             	movzbl (%ebx),%ecx
  800881:	84 c9                	test   %cl,%cl
  800883:	74 1c                	je     8008a1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800885:	83 ee 02             	sub    $0x2,%esi
  800888:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088d:	88 08                	mov    %cl,(%eax)
  80088f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800892:	39 f2                	cmp    %esi,%edx
  800894:	74 0b                	je     8008a1 <strlcpy+0x3d>
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80089d:	84 c9                	test   %cl,%cl
  80089f:	75 ec                	jne    80088d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  8008a1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a4:	29 f8                	sub    %edi,%eax
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b4:	0f b6 01             	movzbl (%ecx),%eax
  8008b7:	84 c0                	test   %al,%al
  8008b9:	74 16                	je     8008d1 <strcmp+0x26>
  8008bb:	3a 02                	cmp    (%edx),%al
  8008bd:	75 12                	jne    8008d1 <strcmp+0x26>
		p++, q++;
  8008bf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8008c6:	84 c0                	test   %al,%al
  8008c8:	74 07                	je     8008d1 <strcmp+0x26>
  8008ca:	83 c1 01             	add    $0x1,%ecx
  8008cd:	3a 02                	cmp    (%edx),%al
  8008cf:	74 ee                	je     8008bf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d1:	0f b6 c0             	movzbl %al,%eax
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	29 d0                	sub    %edx,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ed:	85 d2                	test   %edx,%edx
  8008ef:	74 28                	je     800919 <strncmp+0x3e>
  8008f1:	0f b6 01             	movzbl (%ecx),%eax
  8008f4:	84 c0                	test   %al,%al
  8008f6:	74 24                	je     80091c <strncmp+0x41>
  8008f8:	3a 03                	cmp    (%ebx),%al
  8008fa:	75 20                	jne    80091c <strncmp+0x41>
  8008fc:	83 ea 01             	sub    $0x1,%edx
  8008ff:	74 13                	je     800914 <strncmp+0x39>
		n--, p++, q++;
  800901:	83 c1 01             	add    $0x1,%ecx
  800904:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800907:	0f b6 01             	movzbl (%ecx),%eax
  80090a:	84 c0                	test   %al,%al
  80090c:	74 0e                	je     80091c <strncmp+0x41>
  80090e:	3a 03                	cmp    (%ebx),%al
  800910:	74 ea                	je     8008fc <strncmp+0x21>
  800912:	eb 08                	jmp    80091c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800919:	5b                   	pop    %ebx
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80091c:	0f b6 01             	movzbl (%ecx),%eax
  80091f:	0f b6 13             	movzbl (%ebx),%edx
  800922:	29 d0                	sub    %edx,%eax
  800924:	eb f3                	jmp    800919 <strncmp+0x3e>

00800926 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800930:	0f b6 10             	movzbl (%eax),%edx
  800933:	84 d2                	test   %dl,%dl
  800935:	74 1c                	je     800953 <strchr+0x2d>
		if (*s == c)
  800937:	38 ca                	cmp    %cl,%dl
  800939:	75 09                	jne    800944 <strchr+0x1e>
  80093b:	eb 1b                	jmp    800958 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80093d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800940:	38 ca                	cmp    %cl,%dl
  800942:	74 14                	je     800958 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800944:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800948:	84 d2                	test   %dl,%dl
  80094a:	75 f1                	jne    80093d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
  800951:	eb 05                	jmp    800958 <strchr+0x32>
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800964:	0f b6 10             	movzbl (%eax),%edx
  800967:	84 d2                	test   %dl,%dl
  800969:	74 14                	je     80097f <strfind+0x25>
		if (*s == c)
  80096b:	38 ca                	cmp    %cl,%dl
  80096d:	75 06                	jne    800975 <strfind+0x1b>
  80096f:	eb 0e                	jmp    80097f <strfind+0x25>
  800971:	38 ca                	cmp    %cl,%dl
  800973:	74 0a                	je     80097f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	0f b6 10             	movzbl (%eax),%edx
  80097b:	84 d2                	test   %dl,%dl
  80097d:	75 f2                	jne    800971 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 0c             	sub    $0xc,%esp
  800987:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80098a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80098d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800990:	8b 7d 08             	mov    0x8(%ebp),%edi
  800993:	8b 45 0c             	mov    0xc(%ebp),%eax
  800996:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800999:	85 c9                	test   %ecx,%ecx
  80099b:	74 30                	je     8009cd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a3:	75 25                	jne    8009ca <memset+0x49>
  8009a5:	f6 c1 03             	test   $0x3,%cl
  8009a8:	75 20                	jne    8009ca <memset+0x49>
		c &= 0xFF;
  8009aa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ad:	89 d3                	mov    %edx,%ebx
  8009af:	c1 e3 08             	shl    $0x8,%ebx
  8009b2:	89 d6                	mov    %edx,%esi
  8009b4:	c1 e6 18             	shl    $0x18,%esi
  8009b7:	89 d0                	mov    %edx,%eax
  8009b9:	c1 e0 10             	shl    $0x10,%eax
  8009bc:	09 f0                	or     %esi,%eax
  8009be:	09 d0                	or     %edx,%eax
  8009c0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c5:	fc                   	cld    
  8009c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c8:	eb 03                	jmp    8009cd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ca:	fc                   	cld    
  8009cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cd:	89 f8                	mov    %edi,%eax
  8009cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009d8:	89 ec                	mov    %ebp,%esp
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 08             	sub    $0x8,%esp
  8009e2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009e5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f1:	39 c6                	cmp    %eax,%esi
  8009f3:	73 36                	jae    800a2b <memmove+0x4f>
  8009f5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f8:	39 d0                	cmp    %edx,%eax
  8009fa:	73 2f                	jae    800a2b <memmove+0x4f>
		s += n;
		d += n;
  8009fc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ff:	f6 c2 03             	test   $0x3,%dl
  800a02:	75 1b                	jne    800a1f <memmove+0x43>
  800a04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0a:	75 13                	jne    800a1f <memmove+0x43>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 0e                	jne    800a1f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a11:	83 ef 04             	sub    $0x4,%edi
  800a14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a1a:	fd                   	std    
  800a1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1d:	eb 09                	jmp    800a28 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1f:	83 ef 01             	sub    $0x1,%edi
  800a22:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a25:	fd                   	std    
  800a26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a28:	fc                   	cld    
  800a29:	eb 20                	jmp    800a4b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a31:	75 13                	jne    800a46 <memmove+0x6a>
  800a33:	a8 03                	test   $0x3,%al
  800a35:	75 0f                	jne    800a46 <memmove+0x6a>
  800a37:	f6 c1 03             	test   $0x3,%cl
  800a3a:	75 0a                	jne    800a46 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a3f:	89 c7                	mov    %eax,%edi
  800a41:	fc                   	cld    
  800a42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a44:	eb 05                	jmp    800a4b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a46:	89 c7                	mov    %eax,%edi
  800a48:	fc                   	cld    
  800a49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a4e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a51:	89 ec                	mov    %ebp,%esp
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	89 04 24             	mov    %eax,(%esp)
  800a6f:	e8 68 ff ff ff       	call   8009dc <memmove>
}
  800a74:	c9                   	leave  
  800a75:	c3                   	ret    

00800a76 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
  800a7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a82:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a85:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8a:	85 ff                	test   %edi,%edi
  800a8c:	74 37                	je     800ac5 <memcmp+0x4f>
		if (*s1 != *s2)
  800a8e:	0f b6 03             	movzbl (%ebx),%eax
  800a91:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a94:	83 ef 01             	sub    $0x1,%edi
  800a97:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a9c:	38 c8                	cmp    %cl,%al
  800a9e:	74 1c                	je     800abc <memcmp+0x46>
  800aa0:	eb 10                	jmp    800ab2 <memcmp+0x3c>
  800aa2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800aa7:	83 c2 01             	add    $0x1,%edx
  800aaa:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800aae:	38 c8                	cmp    %cl,%al
  800ab0:	74 0a                	je     800abc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800ab2:	0f b6 c0             	movzbl %al,%eax
  800ab5:	0f b6 c9             	movzbl %cl,%ecx
  800ab8:	29 c8                	sub    %ecx,%eax
  800aba:	eb 09                	jmp    800ac5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abc:	39 fa                	cmp    %edi,%edx
  800abe:	75 e2                	jne    800aa2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad0:	89 c2                	mov    %eax,%edx
  800ad2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad5:	39 d0                	cmp    %edx,%eax
  800ad7:	73 19                	jae    800af2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800add:	38 08                	cmp    %cl,(%eax)
  800adf:	75 06                	jne    800ae7 <memfind+0x1d>
  800ae1:	eb 0f                	jmp    800af2 <memfind+0x28>
  800ae3:	38 08                	cmp    %cl,(%eax)
  800ae5:	74 0b                	je     800af2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae7:	83 c0 01             	add    $0x1,%eax
  800aea:	39 d0                	cmp    %edx,%eax
  800aec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800af0:	75 f1                	jne    800ae3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
  800afa:	8b 55 08             	mov    0x8(%ebp),%edx
  800afd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b00:	0f b6 02             	movzbl (%edx),%eax
  800b03:	3c 20                	cmp    $0x20,%al
  800b05:	74 04                	je     800b0b <strtol+0x17>
  800b07:	3c 09                	cmp    $0x9,%al
  800b09:	75 0e                	jne    800b19 <strtol+0x25>
		s++;
  800b0b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	0f b6 02             	movzbl (%edx),%eax
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f6                	je     800b0b <strtol+0x17>
  800b15:	3c 09                	cmp    $0x9,%al
  800b17:	74 f2                	je     800b0b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b19:	3c 2b                	cmp    $0x2b,%al
  800b1b:	75 0a                	jne    800b27 <strtol+0x33>
		s++;
  800b1d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
  800b25:	eb 10                	jmp    800b37 <strtol+0x43>
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b2c:	3c 2d                	cmp    $0x2d,%al
  800b2e:	75 07                	jne    800b37 <strtol+0x43>
		s++, neg = 1;
  800b30:	83 c2 01             	add    $0x1,%edx
  800b33:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b37:	85 db                	test   %ebx,%ebx
  800b39:	0f 94 c0             	sete   %al
  800b3c:	74 05                	je     800b43 <strtol+0x4f>
  800b3e:	83 fb 10             	cmp    $0x10,%ebx
  800b41:	75 15                	jne    800b58 <strtol+0x64>
  800b43:	80 3a 30             	cmpb   $0x30,(%edx)
  800b46:	75 10                	jne    800b58 <strtol+0x64>
  800b48:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b4c:	75 0a                	jne    800b58 <strtol+0x64>
		s += 2, base = 16;
  800b4e:	83 c2 02             	add    $0x2,%edx
  800b51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b56:	eb 13                	jmp    800b6b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b58:	84 c0                	test   %al,%al
  800b5a:	74 0f                	je     800b6b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b61:	80 3a 30             	cmpb   $0x30,(%edx)
  800b64:	75 05                	jne    800b6b <strtol+0x77>
		s++, base = 8;
  800b66:	83 c2 01             	add    $0x1,%edx
  800b69:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b72:	0f b6 0a             	movzbl (%edx),%ecx
  800b75:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b78:	80 fb 09             	cmp    $0x9,%bl
  800b7b:	77 08                	ja     800b85 <strtol+0x91>
			dig = *s - '0';
  800b7d:	0f be c9             	movsbl %cl,%ecx
  800b80:	83 e9 30             	sub    $0x30,%ecx
  800b83:	eb 1e                	jmp    800ba3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b85:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b88:	80 fb 19             	cmp    $0x19,%bl
  800b8b:	77 08                	ja     800b95 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b8d:	0f be c9             	movsbl %cl,%ecx
  800b90:	83 e9 57             	sub    $0x57,%ecx
  800b93:	eb 0e                	jmp    800ba3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b95:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b98:	80 fb 19             	cmp    $0x19,%bl
  800b9b:	77 14                	ja     800bb1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b9d:	0f be c9             	movsbl %cl,%ecx
  800ba0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ba3:	39 f1                	cmp    %esi,%ecx
  800ba5:	7d 0e                	jge    800bb5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ba7:	83 c2 01             	add    $0x1,%edx
  800baa:	0f af c6             	imul   %esi,%eax
  800bad:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800baf:	eb c1                	jmp    800b72 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bb1:	89 c1                	mov    %eax,%ecx
  800bb3:	eb 02                	jmp    800bb7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbb:	74 05                	je     800bc2 <strtol+0xce>
		*endptr = (char *) s;
  800bbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bc2:	89 ca                	mov    %ecx,%edx
  800bc4:	f7 da                	neg    %edx
  800bc6:	85 ff                	test   %edi,%edi
  800bc8:	0f 45 c2             	cmovne %edx,%eax
}
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bd9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bdc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bea:	89 c3                	mov    %eax,%ebx
  800bec:	89 c7                	mov    %eax,%edi
  800bee:	89 c6                	mov    %eax,%esi
  800bf0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bf5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bf8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bfb:	89 ec                	mov    %ebp,%esp
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_cgetc>:

int
sys_cgetc(void)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c13:	b8 01 00 00 00       	mov    $0x1,%eax
  800c18:	89 d1                	mov    %edx,%ecx
  800c1a:	89 d3                	mov    %edx,%ebx
  800c1c:	89 d7                	mov    %edx,%edi
  800c1e:	89 d6                	mov    %edx,%esi
  800c20:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c2b:	89 ec                	mov    %ebp,%esp
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	83 ec 38             	sub    $0x38,%esp
  800c35:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c38:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c3b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c43:	b8 03 00 00 00       	mov    $0x3,%eax
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	89 cb                	mov    %ecx,%ebx
  800c4d:	89 cf                	mov    %ecx,%edi
  800c4f:	89 ce                	mov    %ecx,%esi
  800c51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 28                	jle    800c7f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c62:	00 
  800c63:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800c6a:	00 
  800c6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c72:	00 
  800c73:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800c7a:	e8 e5 05 00 00       	call   801264 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c88:	89 ec                	mov    %ebp,%esp
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c95:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c98:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ca5:	89 d1                	mov    %edx,%ecx
  800ca7:	89 d3                	mov    %edx,%ebx
  800ca9:	89 d7                	mov    %edx,%edi
  800cab:	89 d6                	mov    %edx,%esi
  800cad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800caf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb8:	89 ec                	mov    %ebp,%esp
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_yield>:

void
sys_yield(void)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	89 d3                	mov    %edx,%ebx
  800cd9:	89 d7                	mov    %edx,%edi
  800cdb:	89 d6                	mov    %edx,%esi
  800cdd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cdf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce8:	89 ec                	mov    %ebp,%esp
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 38             	sub    $0x38,%esp
  800cf2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	be 00 00 00 00       	mov    $0x0,%esi
  800d00:	b8 04 00 00 00       	mov    $0x4,%eax
  800d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	89 f7                	mov    %esi,%edi
  800d10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d12:	85 c0                	test   %eax,%eax
  800d14:	7e 28                	jle    800d3e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d21:	00 
  800d22:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800d29:	00 
  800d2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d31:	00 
  800d32:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800d39:	e8 26 05 00 00       	call   801264 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d3e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d41:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d44:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d47:	89 ec                	mov    %ebp,%esp
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	83 ec 38             	sub    $0x38,%esp
  800d51:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d54:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d57:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d5f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d70:	85 c0                	test   %eax,%eax
  800d72:	7e 28                	jle    800d9c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d78:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d7f:	00 
  800d80:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800d87:	00 
  800d88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8f:	00 
  800d90:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800d97:	e8 c8 04 00 00       	call   801264 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d9c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d9f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da5:	89 ec                	mov    %ebp,%esp
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	83 ec 38             	sub    $0x38,%esp
  800daf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbd:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc8:	89 df                	mov    %ebx,%edi
  800dca:	89 de                	mov    %ebx,%esi
  800dcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	7e 28                	jle    800dfa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ddd:	00 
  800dde:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800de5:	00 
  800de6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ded:	00 
  800dee:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800df5:	e8 6a 04 00 00       	call   801264 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dfa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dfd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e00:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e03:	89 ec                	mov    %ebp,%esp
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	83 ec 38             	sub    $0x38,%esp
  800e0d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e10:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e13:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	89 df                	mov    %ebx,%edi
  800e28:	89 de                	mov    %ebx,%esi
  800e2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7e 28                	jle    800e58 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e34:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e3b:	00 
  800e3c:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800e43:	00 
  800e44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4b:	00 
  800e4c:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800e53:	e8 0c 04 00 00       	call   801264 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e58:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e5b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e61:	89 ec                	mov    %ebp,%esp
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	83 ec 38             	sub    $0x38,%esp
  800e6b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e6e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e71:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e79:	b8 09 00 00 00       	mov    $0x9,%eax
  800e7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e81:	8b 55 08             	mov    0x8(%ebp),%edx
  800e84:	89 df                	mov    %ebx,%edi
  800e86:	89 de                	mov    %ebx,%esi
  800e88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	7e 28                	jle    800eb6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e92:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e99:	00 
  800e9a:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800ea1:	00 
  800ea2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea9:	00 
  800eaa:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800eb1:	e8 ae 03 00 00       	call   801264 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ebc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ebf:	89 ec                	mov    %ebp,%esp
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ecc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ecf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed2:	be 00 00 00 00       	mov    $0x0,%esi
  800ed7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800edc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800edf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef3:	89 ec                	mov    %ebp,%esp
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800f06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f10:	8b 55 08             	mov    0x8(%ebp),%edx
  800f13:	89 cb                	mov    %ecx,%ebx
  800f15:	89 cf                	mov    %ecx,%edi
  800f17:	89 ce                	mov    %ecx,%esi
  800f19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	7e 28                	jle    800f47 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f23:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f2a:	00 
  800f2b:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800f32:	00 
  800f33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3a:	00 
  800f3b:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800f42:	e8 1d 03 00 00       	call   801264 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f47:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f4a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f4d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f50:	89 ec                	mov    %ebp,%esp
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    

00800f54 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	53                   	push   %ebx
  800f58:	83 ec 24             	sub    $0x24,%esp
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f5e:	8b 18                	mov    (%eax),%ebx
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

		/// check if access is write and to a copy-on-write page.
    pte_t pte = uvpt[PGNUM(addr)];
  800f60:	89 da                	mov    %ebx,%edx
  800f62:	c1 ea 0c             	shr    $0xc,%edx
  800f65:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800f6c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f70:	74 05                	je     800f77 <pgfault+0x23>
  800f72:	f6 c6 08             	test   $0x8,%dh
  800f75:	75 1c                	jne    800f93 <pgfault+0x3f>
        panic("pgfault: fault access not to a write or a copy-on-write page");
  800f77:	c7 44 24 08 10 19 80 	movl   $0x801910,0x8(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800f86:	00 
  800f87:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  800f8e:	e8 d1 02 00 00       	call   801264 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
    if (sys_page_alloc(0, PFTEMP, PTE_W | PTE_U | PTE_P)) {
  800f93:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f9a:	00 
  800f9b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fa2:	00 
  800fa3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800faa:	e8 3d fd ff ff       	call   800cec <sys_page_alloc>
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	74 1c                	je     800fcf <pgfault+0x7b>
        panic("pgfault: no phys mem");
  800fb3:	c7 44 24 08 7b 19 80 	movl   $0x80197b,0x8(%esp)
  800fba:	00 
  800fbb:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800fc2:	00 
  800fc3:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  800fca:	e8 95 02 00 00       	call   801264 <_panic>
    }

    // copy data to the new page from the source page.
    void *fltpg_addr = (void *)ROUNDDOWN(addr, PGSIZE);
  800fcf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, fltpg_addr, PGSIZE);
  800fd5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fdc:	00 
  800fdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fe1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fe8:	e8 ef f9 ff ff       	call   8009dc <memmove>

    // change mapping for the faulting page.
    if (sys_page_map(0, PFTEMP, 0, fltpg_addr, PTE_W|PTE_U|PTE_P)) {
  800fed:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ff4:	00 
  800ff5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ff9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801000:	00 
  801001:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801008:	00 
  801009:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801010:	e8 36 fd ff ff       	call   800d4b <sys_page_map>
  801015:	85 c0                	test   %eax,%eax
  801017:	74 1c                	je     801035 <pgfault+0xe1>
        panic("pgfault: map error");
  801019:	c7 44 24 08 90 19 80 	movl   $0x801990,0x8(%esp)
  801020:	00 
  801021:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801028:	00 
  801029:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  801030:	e8 2f 02 00 00       	call   801264 <_panic>
    }
	// panic("pgfault not implemented");
}
  801035:	83 c4 24             	add    $0x24,%esp
  801038:	5b                   	pop    %ebx
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	57                   	push   %edi
  80103f:	56                   	push   %esi
  801040:	53                   	push   %ebx
  801041:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	// Step 1: install user mode pgfault handler.
    set_pgfault_handler(pgfault);
  801044:	c7 04 24 54 0f 80 00 	movl   $0x800f54,(%esp)
  80104b:	e8 6c 02 00 00       	call   8012bc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801050:	ba 07 00 00 00       	mov    $0x7,%edx
  801055:	89 d0                	mov    %edx,%eax
  801057:	cd 30                	int    $0x30
  801059:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80105c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // Step 2: create child environment.
    envid_t envid = sys_exofork();
    if (envid < 0) {
  80105f:	85 c0                	test   %eax,%eax
  801061:	79 1c                	jns    80107f <fork+0x44>
        panic("fork: cannot create child env");
  801063:	c7 44 24 08 a3 19 80 	movl   $0x8019a3,0x8(%esp)
  80106a:	00 
  80106b:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801072:	00 
  801073:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  80107a:	e8 e5 01 00 00       	call   801264 <_panic>
    }
    else if (envid == 0) {
  80107f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801086:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80108a:	75 1c                	jne    8010a8 <fork+0x6d>
        // child environment.
        thisenv = &envs[ENVX(sys_getenvid())];
  80108c:	e8 fb fb ff ff       	call   800c8c <sys_getenvid>
  801091:	25 ff 03 00 00       	and    $0x3ff,%eax
  801096:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801099:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109e:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  8010a3:	e9 8d 01 00 00       	jmp    801235 <fork+0x1fa>

    // Step 3: duplicate pages.
    int ipd;
    for (ipd = 0; ipd < PDX(UTOP); ipd++) {
        // No page table yet.
        if (!(uvpd[ipd] & PTE_P))
  8010a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010ab:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  8010b2:	a8 01                	test   $0x1,%al
  8010b4:	0f 84 c5 00 00 00    	je     80117f <fork+0x144>
            continue;

        int ipt;
        for (ipt = 0; ipt < NPTENTRIES; ipt++) {
            unsigned pn = (ipd << 10) | ipt;
  8010ba:	89 d7                	mov    %edx,%edi
  8010bc:	c1 e7 0a             	shl    $0xa,%edi
  8010bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c4:	89 de                	mov    %ebx,%esi
  8010c6:	09 fe                	or     %edi,%esi
            if (pn != PGNUM(UXSTACKTOP - PGSIZE)) {
  8010c8:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8010ce:	0f 84 9c 00 00 00    	je     801170 <fork+0x135>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	pte_t pte = uvpt[pn];
  8010d4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
    void *va = (void *)(pn << PGSHIFT);

    // If the page is writable or copy-on-write,
    // the mapping must be copy-on-write ,
    // otherwise the new environment could change this page.
    if ((pte & PTE_W) || (pte & PTE_COW)) {
  8010db:	a9 02 08 00 00       	test   $0x802,%eax
  8010e0:	0f 84 8a 00 00 00    	je     801170 <fork+0x135>
{
	int r;

	// LAB 4: Your code here.
	pte_t pte = uvpt[pn];
    void *va = (void *)(pn << PGSHIFT);
  8010e6:	c1 e6 0c             	shl    $0xc,%esi

    // If the page is writable or copy-on-write,
    // the mapping must be copy-on-write ,
    // otherwise the new environment could change this page.
    if ((pte & PTE_W) || (pte & PTE_COW)) {
        if (sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) {
  8010e9:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010f0:	00 
  8010f1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801100:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801107:	e8 3f fc ff ff       	call   800d4b <sys_page_map>
  80110c:	85 c0                	test   %eax,%eax
  80110e:	74 1c                	je     80112c <fork+0xf1>
            panic("duppage: map cow error");
  801110:	c7 44 24 08 c1 19 80 	movl   $0x8019c1,0x8(%esp)
  801117:	00 
  801118:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  801127:	e8 38 01 00 00       	call   801264 <_panic>
        }

        // Change permission of the page in this environment to copy-on-write.
        // Otherwise the new environment would see the change in this environment.
        if (sys_page_map(0, va, 0, va, PTE_COW|PTE_U| PTE_P)) {
  80112c:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801133:	00 
  801134:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801138:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80113f:	00 
  801140:	89 74 24 04          	mov    %esi,0x4(%esp)
  801144:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80114b:	e8 fb fb ff ff       	call   800d4b <sys_page_map>
  801150:	85 c0                	test   %eax,%eax
  801152:	74 1c                	je     801170 <fork+0x135>
            panic("duppage: change perm error");
  801154:	c7 44 24 08 d8 19 80 	movl   $0x8019d8,0x8(%esp)
  80115b:	00 
  80115c:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801163:	00 
  801164:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  80116b:	e8 f4 00 00 00       	call   801264 <_panic>
        // No page table yet.
        if (!(uvpd[ipd] & PTE_P))
            continue;

        int ipt;
        for (ipt = 0; ipt < NPTENTRIES; ipt++) {
  801170:	83 c3 01             	add    $0x1,%ebx
  801173:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801179:	0f 85 45 ff ff ff    	jne    8010c4 <fork+0x89>
        return 0;
    }

    // Step 3: duplicate pages.
    int ipd;
    for (ipd = 0; ipd < PDX(UTOP); ipd++) {
  80117f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  801183:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
  80118a:	0f 85 18 ff ff ff    	jne    8010a8 <fork+0x6d>
            }
        }
    }

    // allocate a new page for child to hold the exception stack.
    if (sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) {
  801190:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801197:	00 
  801198:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80119f:	ee 
  8011a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011a3:	89 04 24             	mov    %eax,(%esp)
  8011a6:	e8 41 fb ff ff       	call   800cec <sys_page_alloc>
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	74 1c                	je     8011cb <fork+0x190>
        panic("fork: no phys mem for xstk");
  8011af:	c7 44 24 08 f3 19 80 	movl   $0x8019f3,0x8(%esp)
  8011b6:	00 
  8011b7:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8011be:	00 
  8011bf:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  8011c6:	e8 99 00 00 00       	call   801264 <_panic>
    }

    // Step 4: set user page fault entry for child.
    if (sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) {
  8011cb:	a1 04 20 80 00       	mov    0x802004,%eax
  8011d0:	8b 40 64             	mov    0x64(%eax),%eax
  8011d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011da:	89 04 24             	mov    %eax,(%esp)
  8011dd:	e8 83 fc ff ff       	call   800e65 <sys_env_set_pgfault_upcall>
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	74 1c                	je     801202 <fork+0x1c7>
        panic("fork: cannot set pgfault upcall");
  8011e6:	c7 44 24 08 50 19 80 	movl   $0x801950,0x8(%esp)
  8011ed:	00 
  8011ee:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8011f5:	00 
  8011f6:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  8011fd:	e8 62 00 00 00       	call   801264 <_panic>
    }

    // Step 5: set child status to ENV_RUNNABLE.
    if (sys_env_set_status(envid, ENV_RUNNABLE)) {
  801202:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801209:	00 
  80120a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80120d:	89 04 24             	mov    %eax,(%esp)
  801210:	e8 f2 fb ff ff       	call   800e07 <sys_env_set_status>
  801215:	85 c0                	test   %eax,%eax
  801217:	74 1c                	je     801235 <fork+0x1fa>
        panic("fork: cannot set env status");
  801219:	c7 44 24 08 0e 1a 80 	movl   $0x801a0e,0x8(%esp)
  801220:	00 
  801221:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801228:	00 
  801229:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  801230:	e8 2f 00 00 00       	call   801264 <_panic>
    }

    return envid;

}
  801235:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801238:	83 c4 3c             	add    $0x3c,%esp
  80123b:	5b                   	pop    %ebx
  80123c:	5e                   	pop    %esi
  80123d:	5f                   	pop    %edi
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <sfork>:

// Challenge!
int
sfork(void)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801246:	c7 44 24 08 2a 1a 80 	movl   $0x801a2a,0x8(%esp)
  80124d:	00 
  80124e:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  801255:	00 
  801256:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  80125d:	e8 02 00 00 00       	call   801264 <_panic>
	...

00801264 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
  801269:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80126c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80126f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801275:	e8 12 fa ff ff       	call   800c8c <sys_getenvid>
  80127a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801281:	8b 55 08             	mov    0x8(%ebp),%edx
  801284:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801288:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80128c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801290:	c7 04 24 40 1a 80 00 	movl   $0x801a40,(%esp)
  801297:	e8 37 ef ff ff       	call   8001d3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80129c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012a3:	89 04 24             	mov    %eax,(%esp)
  8012a6:	e8 c7 ee ff ff       	call   800172 <vcprintf>
	cprintf("\n");
  8012ab:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  8012b2:	e8 1c ef ff ff       	call   8001d3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012b7:	cc                   	int3   
  8012b8:	eb fd                	jmp    8012b7 <_panic+0x53>
	...

008012bc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012c2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8012c9:	75 50                	jne    80131b <set_pgfault_handler+0x5f>
		// First time through!
		// LAB 4: Your code here.
		int error = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P);
  8012cb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012d2:	00 
  8012d3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012da:	ee 
  8012db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e2:	e8 05 fa ff ff       	call   800cec <sys_page_alloc>
        if (error) {
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	74 1c                	je     801307 <set_pgfault_handler+0x4b>
            panic("No physical memory available!");
  8012eb:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  8012f2:	00 
  8012f3:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8012fa:	00 
  8012fb:	c7 04 24 82 1a 80 00 	movl   $0x801a82,(%esp)
  801302:	e8 5d ff ff ff       	call   801264 <_panic>
        }

		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801307:	c7 44 24 04 28 13 80 	movl   $0x801328,0x4(%esp)
  80130e:	00 
  80130f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801316:	e8 4a fb ff ff       	call   800e65 <sys_env_set_pgfault_upcall>
		
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80131b:	8b 45 08             	mov    0x8(%ebp),%eax
  80131e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801323:	c9                   	leave  
  801324:	c3                   	ret    
  801325:	00 00                	add    %al,(%eax)
	...

00801328 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801328:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801329:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80132e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801330:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	

	movl %esp, %eax 		// temporarily save exception stack esp
  801333:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 	// return addr (eip) -> ebx 
  801335:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 	// now trap-time stack
  801339:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 				// push eip onto trap-time stack 
  80133d:	53                   	push   %ebx
	movl %esp, 48(%eax) 	// Updating the trap-time stack esp, since a new val has been pushed
  80133e:	89 60 30             	mov    %esp,0x30(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	movl %eax, %esp 	/* now exception stack */
  801341:	89 c4                	mov    %eax,%esp
	addl $4, %esp 		/* skip utf_fault_va */
  801343:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 		/* skip utf_err */
  801346:	83 c4 04             	add    $0x4,%esp
	popal 				/* restore from utf_regs  */
  801349:	61                   	popa   
	addl $4, %esp 		/* skip utf_eip (already on trap-time stack) */
  80134a:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	popfl /* restore from utf_eflags */
  80134d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp /* restore from utf_esp - top of stack (bottom-most val) will be the eip to go to */
  80134e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	
	ret
  80134f:	c3                   	ret    

00801350 <__udivdi3>:
  801350:	83 ec 1c             	sub    $0x1c,%esp
  801353:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801357:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80135b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80135f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801363:	89 74 24 10          	mov    %esi,0x10(%esp)
  801367:	8b 74 24 24          	mov    0x24(%esp),%esi
  80136b:	85 ff                	test   %edi,%edi
  80136d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801371:	89 44 24 08          	mov    %eax,0x8(%esp)
  801375:	89 cd                	mov    %ecx,%ebp
  801377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137b:	75 33                	jne    8013b0 <__udivdi3+0x60>
  80137d:	39 f1                	cmp    %esi,%ecx
  80137f:	77 57                	ja     8013d8 <__udivdi3+0x88>
  801381:	85 c9                	test   %ecx,%ecx
  801383:	75 0b                	jne    801390 <__udivdi3+0x40>
  801385:	b8 01 00 00 00       	mov    $0x1,%eax
  80138a:	31 d2                	xor    %edx,%edx
  80138c:	f7 f1                	div    %ecx
  80138e:	89 c1                	mov    %eax,%ecx
  801390:	89 f0                	mov    %esi,%eax
  801392:	31 d2                	xor    %edx,%edx
  801394:	f7 f1                	div    %ecx
  801396:	89 c6                	mov    %eax,%esi
  801398:	8b 44 24 04          	mov    0x4(%esp),%eax
  80139c:	f7 f1                	div    %ecx
  80139e:	89 f2                	mov    %esi,%edx
  8013a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013ac:	83 c4 1c             	add    $0x1c,%esp
  8013af:	c3                   	ret    
  8013b0:	31 d2                	xor    %edx,%edx
  8013b2:	31 c0                	xor    %eax,%eax
  8013b4:	39 f7                	cmp    %esi,%edi
  8013b6:	77 e8                	ja     8013a0 <__udivdi3+0x50>
  8013b8:	0f bd cf             	bsr    %edi,%ecx
  8013bb:	83 f1 1f             	xor    $0x1f,%ecx
  8013be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013c2:	75 2c                	jne    8013f0 <__udivdi3+0xa0>
  8013c4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8013c8:	76 04                	jbe    8013ce <__udivdi3+0x7e>
  8013ca:	39 f7                	cmp    %esi,%edi
  8013cc:	73 d2                	jae    8013a0 <__udivdi3+0x50>
  8013ce:	31 d2                	xor    %edx,%edx
  8013d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8013d5:	eb c9                	jmp    8013a0 <__udivdi3+0x50>
  8013d7:	90                   	nop
  8013d8:	89 f2                	mov    %esi,%edx
  8013da:	f7 f1                	div    %ecx
  8013dc:	31 d2                	xor    %edx,%edx
  8013de:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013e2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013e6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013ea:	83 c4 1c             	add    $0x1c,%esp
  8013ed:	c3                   	ret    
  8013ee:	66 90                	xchg   %ax,%ax
  8013f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013f5:	b8 20 00 00 00       	mov    $0x20,%eax
  8013fa:	89 ea                	mov    %ebp,%edx
  8013fc:	2b 44 24 04          	sub    0x4(%esp),%eax
  801400:	d3 e7                	shl    %cl,%edi
  801402:	89 c1                	mov    %eax,%ecx
  801404:	d3 ea                	shr    %cl,%edx
  801406:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80140b:	09 fa                	or     %edi,%edx
  80140d:	89 f7                	mov    %esi,%edi
  80140f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801413:	89 f2                	mov    %esi,%edx
  801415:	8b 74 24 08          	mov    0x8(%esp),%esi
  801419:	d3 e5                	shl    %cl,%ebp
  80141b:	89 c1                	mov    %eax,%ecx
  80141d:	d3 ef                	shr    %cl,%edi
  80141f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801424:	d3 e2                	shl    %cl,%edx
  801426:	89 c1                	mov    %eax,%ecx
  801428:	d3 ee                	shr    %cl,%esi
  80142a:	09 d6                	or     %edx,%esi
  80142c:	89 fa                	mov    %edi,%edx
  80142e:	89 f0                	mov    %esi,%eax
  801430:	f7 74 24 0c          	divl   0xc(%esp)
  801434:	89 d7                	mov    %edx,%edi
  801436:	89 c6                	mov    %eax,%esi
  801438:	f7 e5                	mul    %ebp
  80143a:	39 d7                	cmp    %edx,%edi
  80143c:	72 22                	jb     801460 <__udivdi3+0x110>
  80143e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801442:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801447:	d3 e5                	shl    %cl,%ebp
  801449:	39 c5                	cmp    %eax,%ebp
  80144b:	73 04                	jae    801451 <__udivdi3+0x101>
  80144d:	39 d7                	cmp    %edx,%edi
  80144f:	74 0f                	je     801460 <__udivdi3+0x110>
  801451:	89 f0                	mov    %esi,%eax
  801453:	31 d2                	xor    %edx,%edx
  801455:	e9 46 ff ff ff       	jmp    8013a0 <__udivdi3+0x50>
  80145a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801460:	8d 46 ff             	lea    -0x1(%esi),%eax
  801463:	31 d2                	xor    %edx,%edx
  801465:	8b 74 24 10          	mov    0x10(%esp),%esi
  801469:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80146d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801471:	83 c4 1c             	add    $0x1c,%esp
  801474:	c3                   	ret    
	...

00801480 <__umoddi3>:
  801480:	83 ec 1c             	sub    $0x1c,%esp
  801483:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801487:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80148b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80148f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801493:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801497:	8b 74 24 24          	mov    0x24(%esp),%esi
  80149b:	85 ed                	test   %ebp,%ebp
  80149d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8014a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a5:	89 cf                	mov    %ecx,%edi
  8014a7:	89 04 24             	mov    %eax,(%esp)
  8014aa:	89 f2                	mov    %esi,%edx
  8014ac:	75 1a                	jne    8014c8 <__umoddi3+0x48>
  8014ae:	39 f1                	cmp    %esi,%ecx
  8014b0:	76 4e                	jbe    801500 <__umoddi3+0x80>
  8014b2:	f7 f1                	div    %ecx
  8014b4:	89 d0                	mov    %edx,%eax
  8014b6:	31 d2                	xor    %edx,%edx
  8014b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8014bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8014c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8014c4:	83 c4 1c             	add    $0x1c,%esp
  8014c7:	c3                   	ret    
  8014c8:	39 f5                	cmp    %esi,%ebp
  8014ca:	77 54                	ja     801520 <__umoddi3+0xa0>
  8014cc:	0f bd c5             	bsr    %ebp,%eax
  8014cf:	83 f0 1f             	xor    $0x1f,%eax
  8014d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d6:	75 60                	jne    801538 <__umoddi3+0xb8>
  8014d8:	3b 0c 24             	cmp    (%esp),%ecx
  8014db:	0f 87 07 01 00 00    	ja     8015e8 <__umoddi3+0x168>
  8014e1:	89 f2                	mov    %esi,%edx
  8014e3:	8b 34 24             	mov    (%esp),%esi
  8014e6:	29 ce                	sub    %ecx,%esi
  8014e8:	19 ea                	sbb    %ebp,%edx
  8014ea:	89 34 24             	mov    %esi,(%esp)
  8014ed:	8b 04 24             	mov    (%esp),%eax
  8014f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8014f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8014f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8014fc:	83 c4 1c             	add    $0x1c,%esp
  8014ff:	c3                   	ret    
  801500:	85 c9                	test   %ecx,%ecx
  801502:	75 0b                	jne    80150f <__umoddi3+0x8f>
  801504:	b8 01 00 00 00       	mov    $0x1,%eax
  801509:	31 d2                	xor    %edx,%edx
  80150b:	f7 f1                	div    %ecx
  80150d:	89 c1                	mov    %eax,%ecx
  80150f:	89 f0                	mov    %esi,%eax
  801511:	31 d2                	xor    %edx,%edx
  801513:	f7 f1                	div    %ecx
  801515:	8b 04 24             	mov    (%esp),%eax
  801518:	f7 f1                	div    %ecx
  80151a:	eb 98                	jmp    8014b4 <__umoddi3+0x34>
  80151c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801520:	89 f2                	mov    %esi,%edx
  801522:	8b 74 24 10          	mov    0x10(%esp),%esi
  801526:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80152a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80152e:	83 c4 1c             	add    $0x1c,%esp
  801531:	c3                   	ret    
  801532:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801538:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80153d:	89 e8                	mov    %ebp,%eax
  80153f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801544:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801548:	89 fa                	mov    %edi,%edx
  80154a:	d3 e0                	shl    %cl,%eax
  80154c:	89 e9                	mov    %ebp,%ecx
  80154e:	d3 ea                	shr    %cl,%edx
  801550:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801555:	09 c2                	or     %eax,%edx
  801557:	8b 44 24 08          	mov    0x8(%esp),%eax
  80155b:	89 14 24             	mov    %edx,(%esp)
  80155e:	89 f2                	mov    %esi,%edx
  801560:	d3 e7                	shl    %cl,%edi
  801562:	89 e9                	mov    %ebp,%ecx
  801564:	d3 ea                	shr    %cl,%edx
  801566:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80156b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80156f:	d3 e6                	shl    %cl,%esi
  801571:	89 e9                	mov    %ebp,%ecx
  801573:	d3 e8                	shr    %cl,%eax
  801575:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80157a:	09 f0                	or     %esi,%eax
  80157c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801580:	f7 34 24             	divl   (%esp)
  801583:	d3 e6                	shl    %cl,%esi
  801585:	89 74 24 08          	mov    %esi,0x8(%esp)
  801589:	89 d6                	mov    %edx,%esi
  80158b:	f7 e7                	mul    %edi
  80158d:	39 d6                	cmp    %edx,%esi
  80158f:	89 c1                	mov    %eax,%ecx
  801591:	89 d7                	mov    %edx,%edi
  801593:	72 3f                	jb     8015d4 <__umoddi3+0x154>
  801595:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801599:	72 35                	jb     8015d0 <__umoddi3+0x150>
  80159b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80159f:	29 c8                	sub    %ecx,%eax
  8015a1:	19 fe                	sbb    %edi,%esi
  8015a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015a8:	89 f2                	mov    %esi,%edx
  8015aa:	d3 e8                	shr    %cl,%eax
  8015ac:	89 e9                	mov    %ebp,%ecx
  8015ae:	d3 e2                	shl    %cl,%edx
  8015b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015b5:	09 d0                	or     %edx,%eax
  8015b7:	89 f2                	mov    %esi,%edx
  8015b9:	d3 ea                	shr    %cl,%edx
  8015bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8015bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8015c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8015c7:	83 c4 1c             	add    $0x1c,%esp
  8015ca:	c3                   	ret    
  8015cb:	90                   	nop
  8015cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015d0:	39 d6                	cmp    %edx,%esi
  8015d2:	75 c7                	jne    80159b <__umoddi3+0x11b>
  8015d4:	89 d7                	mov    %edx,%edi
  8015d6:	89 c1                	mov    %eax,%ecx
  8015d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8015dc:	1b 3c 24             	sbb    (%esp),%edi
  8015df:	eb ba                	jmp    80159b <__umoddi3+0x11b>
  8015e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015e8:	39 f5                	cmp    %esi,%ebp
  8015ea:	0f 82 f1 fe ff ff    	jb     8014e1 <__umoddi3+0x61>
  8015f0:	e9 f8 fe ff ff       	jmp    8014ed <__umoddi3+0x6d>
