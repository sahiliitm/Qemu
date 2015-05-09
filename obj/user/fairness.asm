
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 5b 0c 00 00       	call   800c9c <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 fa 0e 00 00       	call   800f64 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 a0 13 80 00 	movl   $0x8013a0,(%esp)
  80007c:	e8 56 01 00 00       	call   8001d7 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 b1 13 80 00 	movl   $0x8013b1,(%esp)
  800097:	e8 3b 01 00 00       	call   8001d7 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 0b 0f 00 00       	call   800fcc <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
	...

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
  8000ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000d6:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000dd:	00 00 00 
	envid_t envid = sys_getenvid();
  8000e0:	e8 b7 0b 00 00       	call   800c9c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  8000e5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ea:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f2:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f7:	85 f6                	test   %esi,%esi
  8000f9:	7e 07                	jle    800102 <libmain+0x3e>
		binaryname = argv[0];
  8000fb:	8b 03                	mov    (%ebx),%eax
  8000fd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800102:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800106:	89 34 24             	mov    %esi,(%esp)
  800109:	e8 26 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80010e:	e8 0d 00 00 00       	call   800120 <exit>
}
  800113:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800116:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800119:	89 ec                	mov    %ebp,%esp
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    
  80011d:	00 00                	add    %al,(%eax)
	...

00800120 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800126:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012d:	e8 0d 0b 00 00       	call   800c3f <sys_env_destroy>
}
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	53                   	push   %ebx
  800138:	83 ec 14             	sub    $0x14,%esp
  80013b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013e:	8b 03                	mov    (%ebx),%eax
  800140:	8b 55 08             	mov    0x8(%ebp),%edx
  800143:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800147:	83 c0 01             	add    $0x1,%eax
  80014a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800151:	75 19                	jne    80016c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800153:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80015a:	00 
  80015b:	8d 43 08             	lea    0x8(%ebx),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 7a 0a 00 00       	call   800be0 <sys_cputs>
		b->idx = 0;
  800166:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80016c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800170:	83 c4 14             	add    $0x14,%esp
  800173:	5b                   	pop    %ebx
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80017f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800186:	00 00 00 
	b.cnt = 0;
  800189:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800190:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800193:	8b 45 0c             	mov    0xc(%ebp),%eax
  800196:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ab:	c7 04 24 34 01 80 00 	movl   $0x800134,(%esp)
  8001b2:	e8 dd 01 00 00       	call   800394 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 11 0a 00 00       	call   800be0 <sys_cputs>

	return b.cnt;
}
  8001cf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001dd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e7:	89 04 24             	mov    %eax,(%esp)
  8001ea:	e8 87 ff ff ff       	call   800176 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    
	...

00800200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 3c             	sub    $0x3c,%esp
  800209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80020c:	89 d7                	mov    %edx,%edi
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
  800217:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80021a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80021d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800220:	b8 00 00 00 00       	mov    $0x0,%eax
  800225:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800228:	72 11                	jb     80023b <printnum+0x3b>
  80022a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	76 09                	jbe    80023b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800232:	83 eb 01             	sub    $0x1,%ebx
  800235:	85 db                	test   %ebx,%ebx
  800237:	7f 51                	jg     80028a <printnum+0x8a>
  800239:	eb 5e                	jmp    800299 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80023f:	83 eb 01             	sub    $0x1,%ebx
  800242:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800246:	8b 45 10             	mov    0x10(%ebp),%eax
  800249:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800251:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800255:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025c:	00 
  80025d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800266:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026a:	e8 71 0e 00 00       	call   8010e0 <__udivdi3>
  80026f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800273:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800277:	89 04 24             	mov    %eax,(%esp)
  80027a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80027e:	89 fa                	mov    %edi,%edx
  800280:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800283:	e8 78 ff ff ff       	call   800200 <printnum>
  800288:	eb 0f                	jmp    800299 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80028e:	89 34 24             	mov    %esi,(%esp)
  800291:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800294:	83 eb 01             	sub    $0x1,%ebx
  800297:	75 f1                	jne    80028a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800299:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002af:	00 
  8002b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b3:	89 04 24             	mov    %eax,(%esp)
  8002b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	e8 4e 0f 00 00       	call   801210 <__umoddi3>
  8002c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c6:	0f be 80 d2 13 80 00 	movsbl 0x8013d2(%eax),%eax
  8002cd:	89 04 24             	mov    %eax,(%esp)
  8002d0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002d3:	83 c4 3c             	add    $0x3c,%esp
  8002d6:	5b                   	pop    %ebx
  8002d7:	5e                   	pop    %esi
  8002d8:	5f                   	pop    %edi
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002de:	83 fa 01             	cmp    $0x1,%edx
  8002e1:	7e 0e                	jle    8002f1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e8:	89 08                	mov    %ecx,(%eax)
  8002ea:	8b 02                	mov    (%edx),%eax
  8002ec:	8b 52 04             	mov    0x4(%edx),%edx
  8002ef:	eb 22                	jmp    800313 <getuint+0x38>
	else if (lflag)
  8002f1:	85 d2                	test   %edx,%edx
  8002f3:	74 10                	je     800305 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 02                	mov    (%edx),%eax
  8002fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800303:	eb 0e                	jmp    800313 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800305:	8b 10                	mov    (%eax),%edx
  800307:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030a:	89 08                	mov    %ecx,(%eax)
  80030c:	8b 02                	mov    (%edx),%eax
  80030e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800318:	83 fa 01             	cmp    $0x1,%edx
  80031b:	7e 0e                	jle    80032b <getint+0x16>
		return va_arg(*ap, long long);
  80031d:	8b 10                	mov    (%eax),%edx
  80031f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 02                	mov    (%edx),%eax
  800326:	8b 52 04             	mov    0x4(%edx),%edx
  800329:	eb 22                	jmp    80034d <getint+0x38>
	else if (lflag)
  80032b:	85 d2                	test   %edx,%edx
  80032d:	74 10                	je     80033f <getint+0x2a>
		return va_arg(*ap, long);
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	8d 4a 04             	lea    0x4(%edx),%ecx
  800334:	89 08                	mov    %ecx,(%eax)
  800336:	8b 02                	mov    (%edx),%eax
  800338:	89 c2                	mov    %eax,%edx
  80033a:	c1 fa 1f             	sar    $0x1f,%edx
  80033d:	eb 0e                	jmp    80034d <getint+0x38>
	else
		return va_arg(*ap, int);
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	8d 4a 04             	lea    0x4(%edx),%ecx
  800344:	89 08                	mov    %ecx,(%eax)
  800346:	8b 02                	mov    (%edx),%eax
  800348:	89 c2                	mov    %eax,%edx
  80034a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800355:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 0a                	jae    80036a <sprintputch+0x1b>
		*b->buf++ = ch;
  800360:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800363:	88 0a                	mov    %cl,(%edx)
  800365:	83 c2 01             	add    $0x1,%edx
  800368:	89 10                	mov    %edx,(%eax)
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800372:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800375:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800379:	8b 45 10             	mov    0x10(%ebp),%eax
  80037c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800380:	8b 45 0c             	mov    0xc(%ebp),%eax
  800383:	89 44 24 04          	mov    %eax,0x4(%esp)
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	89 04 24             	mov    %eax,(%esp)
  80038d:	e8 02 00 00 00       	call   800394 <vprintfmt>
	va_end(ap);
}
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 4c             	sub    $0x4c,%esp
  80039d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a0:	8b 75 10             	mov    0x10(%ebp),%esi
  8003a3:	eb 12                	jmp    8003b7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a5:	85 c0                	test   %eax,%eax
  8003a7:	0f 84 77 03 00 00    	je     800724 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  8003ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b1:	89 04 24             	mov    %eax,(%esp)
  8003b4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b7:	0f b6 06             	movzbl (%esi),%eax
  8003ba:	83 c6 01             	add    $0x1,%esi
  8003bd:	83 f8 25             	cmp    $0x25,%eax
  8003c0:	75 e3                	jne    8003a5 <vprintfmt+0x11>
  8003c2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003c6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003cd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003d2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003e1:	eb 2b                	jmp    80040e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003ea:	eb 22                	jmp    80040e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ef:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003f3:	eb 19                	jmp    80040e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003f8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003ff:	eb 0d                	jmp    80040e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800401:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800404:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800407:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	0f b6 06             	movzbl (%esi),%eax
  800411:	0f b6 d0             	movzbl %al,%edx
  800414:	8d 7e 01             	lea    0x1(%esi),%edi
  800417:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80041a:	83 e8 23             	sub    $0x23,%eax
  80041d:	3c 55                	cmp    $0x55,%al
  80041f:	0f 87 d9 02 00 00    	ja     8006fe <vprintfmt+0x36a>
  800425:	0f b6 c0             	movzbl %al,%eax
  800428:	ff 24 85 a0 14 80 00 	jmp    *0x8014a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042f:	83 ea 30             	sub    $0x30,%edx
  800432:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800435:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800439:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80043f:	83 fa 09             	cmp    $0x9,%edx
  800442:	77 4a                	ja     80048e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800447:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80044a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80044d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800451:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800454:	8d 50 d0             	lea    -0x30(%eax),%edx
  800457:	83 fa 09             	cmp    $0x9,%edx
  80045a:	76 eb                	jbe    800447 <vprintfmt+0xb3>
  80045c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045f:	eb 2d                	jmp    80048e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	8b 00                	mov    (%eax),%eax
  80046c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800472:	eb 1a                	jmp    80048e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800477:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047b:	79 91                	jns    80040e <vprintfmt+0x7a>
  80047d:	e9 73 ff ff ff       	jmp    8003f5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800485:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80048c:	eb 80                	jmp    80040e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80048e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800492:	0f 89 76 ff ff ff    	jns    80040e <vprintfmt+0x7a>
  800498:	e9 64 ff ff ff       	jmp    800401 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a3:	e9 66 ff ff ff       	jmp    80040e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8d 50 04             	lea    0x4(%eax),%edx
  8004ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	89 04 24             	mov    %eax,(%esp)
  8004ba:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c0:	e9 f2 fe ff ff       	jmp    8003b7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	89 c2                	mov    %eax,%edx
  8004d2:	c1 fa 1f             	sar    $0x1f,%edx
  8004d5:	31 d0                	xor    %edx,%eax
  8004d7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d9:	83 f8 08             	cmp    $0x8,%eax
  8004dc:	7f 0b                	jg     8004e9 <vprintfmt+0x155>
  8004de:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  8004e5:	85 d2                	test   %edx,%edx
  8004e7:	75 23                	jne    80050c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ed:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  8004f4:	00 
  8004f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004fc:	89 3c 24             	mov    %edi,(%esp)
  8004ff:	e8 68 fe ff ff       	call   80036c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800507:	e9 ab fe ff ff       	jmp    8003b7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80050c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800510:	c7 44 24 08 f3 13 80 	movl   $0x8013f3,0x8(%esp)
  800517:	00 
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80051f:	89 3c 24             	mov    %edi,(%esp)
  800522:	e8 45 fe ff ff       	call   80036c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052a:	e9 88 fe ff ff       	jmp    8003b7 <vprintfmt+0x23>
  80052f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800532:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800535:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800543:	85 f6                	test   %esi,%esi
  800545:	ba e3 13 80 00       	mov    $0x8013e3,%edx
  80054a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80054d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800551:	7e 06                	jle    800559 <vprintfmt+0x1c5>
  800553:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800557:	75 10                	jne    800569 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800559:	0f be 06             	movsbl (%esi),%eax
  80055c:	83 c6 01             	add    $0x1,%esi
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 85 86 00 00 00    	jne    8005ed <vprintfmt+0x259>
  800567:	eb 76                	jmp    8005df <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800569:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056d:	89 34 24             	mov    %esi,(%esp)
  800570:	e8 56 02 00 00       	call   8007cb <strnlen>
  800575:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800578:	29 c2                	sub    %eax,%edx
  80057a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80057d:	85 d2                	test   %edx,%edx
  80057f:	7e d8                	jle    800559 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800581:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800585:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800588:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80058b:	89 d6                	mov    %edx,%esi
  80058d:	89 c7                	mov    %eax,%edi
  80058f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800593:	89 3c 24             	mov    %edi,(%esp)
  800596:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800599:	83 ee 01             	sub    $0x1,%esi
  80059c:	75 f1                	jne    80058f <vprintfmt+0x1fb>
  80059e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8005a1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005a4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005a7:	eb b0                	jmp    800559 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ad:	74 18                	je     8005c7 <vprintfmt+0x233>
  8005af:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b2:	83 fa 5e             	cmp    $0x5e,%edx
  8005b5:	76 10                	jbe    8005c7 <vprintfmt+0x233>
					putch('?', putdat);
  8005b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bb:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c2:	ff 55 08             	call   *0x8(%ebp)
  8005c5:	eb 0a                	jmp    8005d1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  8005c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cb:	89 04 24             	mov    %eax,(%esp)
  8005ce:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005d5:	0f be 06             	movsbl (%esi),%eax
  8005d8:	83 c6 01             	add    $0x1,%esi
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	75 0e                	jne    8005ed <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e6:	7f 11                	jg     8005f9 <vprintfmt+0x265>
  8005e8:	e9 ca fd ff ff       	jmp    8003b7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ed:	85 ff                	test   %edi,%edi
  8005ef:	90                   	nop
  8005f0:	78 b7                	js     8005a9 <vprintfmt+0x215>
  8005f2:	83 ef 01             	sub    $0x1,%edi
  8005f5:	79 b2                	jns    8005a9 <vprintfmt+0x215>
  8005f7:	eb e6                	jmp    8005df <vprintfmt+0x24b>
  8005f9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005fc:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800603:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80060a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060c:	83 ee 01             	sub    $0x1,%esi
  80060f:	75 ee                	jne    8005ff <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800611:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800614:	e9 9e fd ff ff       	jmp    8003b7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800619:	89 ca                	mov    %ecx,%edx
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 f2 fc ff ff       	call   800315 <getint>
  800623:	89 c6                	mov    %eax,%esi
  800625:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800627:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062c:	85 d2                	test   %edx,%edx
  80062e:	0f 89 8c 00 00 00    	jns    8006c0 <vprintfmt+0x32c>
				putch('-', putdat);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80063f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800642:	f7 de                	neg    %esi
  800644:	83 d7 00             	adc    $0x0,%edi
  800647:	f7 df                	neg    %edi
			}
			base = 10;
  800649:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064e:	eb 70                	jmp    8006c0 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800650:	89 ca                	mov    %ecx,%edx
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
  800655:	e8 81 fc ff ff       	call   8002db <getuint>
  80065a:	89 c6                	mov    %eax,%esi
  80065c:	89 d7                	mov    %edx,%edi
			base = 10;
  80065e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800663:	eb 5b                	jmp    8006c0 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  800665:	89 ca                	mov    %ecx,%edx
  800667:	8d 45 14             	lea    0x14(%ebp),%eax
  80066a:	e8 a6 fc ff ff       	call   800315 <getint>
  80066f:	89 c6                	mov    %eax,%esi
  800671:	89 d7                	mov    %edx,%edi
			base = 8;
  800673:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800678:	eb 46                	jmp    8006c0 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80067a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800685:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800688:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800693:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 50 04             	lea    0x4(%eax),%edx
  80069c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069f:	8b 30                	mov    (%eax),%esi
  8006a1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ab:	eb 13                	jmp    8006c0 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ad:	89 ca                	mov    %ecx,%edx
  8006af:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b2:	e8 24 fc ff ff       	call   8002db <getuint>
  8006b7:	89 c6                	mov    %eax,%esi
  8006b9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006bb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006c4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d3:	89 34 24             	mov    %esi,(%esp)
  8006d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006da:	89 da                	mov    %ebx,%edx
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	e8 1c fb ff ff       	call   800200 <printnum>
			break;
  8006e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e7:	e9 cb fc ff ff       	jmp    8003b7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f0:	89 14 24             	mov    %edx,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f9:	e9 b9 fc ff ff       	jmp    8003b7 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800702:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800709:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800710:	0f 84 a1 fc ff ff    	je     8003b7 <vprintfmt+0x23>
  800716:	83 ee 01             	sub    $0x1,%esi
  800719:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80071d:	75 f7                	jne    800716 <vprintfmt+0x382>
  80071f:	e9 93 fc ff ff       	jmp    8003b7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800724:	83 c4 4c             	add    $0x4c,%esp
  800727:	5b                   	pop    %ebx
  800728:	5e                   	pop    %esi
  800729:	5f                   	pop    %edi
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	83 ec 28             	sub    $0x28,%esp
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800738:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800742:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800749:	85 c0                	test   %eax,%eax
  80074b:	74 30                	je     80077d <vsnprintf+0x51>
  80074d:	85 d2                	test   %edx,%edx
  80074f:	7e 2c                	jle    80077d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800758:	8b 45 10             	mov    0x10(%ebp),%eax
  80075b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800762:	89 44 24 04          	mov    %eax,0x4(%esp)
  800766:	c7 04 24 4f 03 80 00 	movl   $0x80034f,(%esp)
  80076d:	e8 22 fc ff ff       	call   800394 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800772:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800775:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800778:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077b:	eb 05                	jmp    800782 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800791:	8b 45 10             	mov    0x10(%ebp),%eax
  800794:	89 44 24 08          	mov    %eax,0x8(%esp)
  800798:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	89 04 24             	mov    %eax,(%esp)
  8007a5:	e8 82 ff ff ff       	call   80072c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    
  8007ac:	00 00                	add    %al,(%eax)
	...

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007be:	74 09                	je     8007c9 <strlen+0x19>
		n++;
  8007c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c7:	75 f7                	jne    8007c0 <strlen+0x10>
		n++;
	return n;
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007da:	85 c9                	test   %ecx,%ecx
  8007dc:	74 1a                	je     8007f8 <strnlen+0x2d>
  8007de:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007e1:	74 15                	je     8007f8 <strnlen+0x2d>
  8007e3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007e8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ea:	39 ca                	cmp    %ecx,%edx
  8007ec:	74 0a                	je     8007f8 <strnlen+0x2d>
  8007ee:	83 c2 01             	add    $0x1,%edx
  8007f1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007f6:	75 f0                	jne    8007e8 <strnlen+0x1d>
		n++;
	return n;
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
  80080a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80080e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800811:	83 c2 01             	add    $0x1,%edx
  800814:	84 c9                	test   %cl,%cl
  800816:	75 f2                	jne    80080a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800825:	89 1c 24             	mov    %ebx,(%esp)
  800828:	e8 83 ff ff ff       	call   8007b0 <strlen>
	strcpy(dst + len, src);
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800830:	89 54 24 04          	mov    %edx,0x4(%esp)
  800834:	01 d8                	add    %ebx,%eax
  800836:	89 04 24             	mov    %eax,(%esp)
  800839:	e8 bd ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  80083e:	89 d8                	mov    %ebx,%eax
  800840:	83 c4 08             	add    $0x8,%esp
  800843:	5b                   	pop    %ebx
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	56                   	push   %esi
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800854:	85 f6                	test   %esi,%esi
  800856:	74 18                	je     800870 <strncpy+0x2a>
  800858:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80085d:	0f b6 1a             	movzbl (%edx),%ebx
  800860:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800863:	80 3a 01             	cmpb   $0x1,(%edx)
  800866:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800869:	83 c1 01             	add    $0x1,%ecx
  80086c:	39 f1                	cmp    %esi,%ecx
  80086e:	75 ed                	jne    80085d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	57                   	push   %edi
  800878:	56                   	push   %esi
  800879:	53                   	push   %ebx
  80087a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800880:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800883:	89 f8                	mov    %edi,%eax
  800885:	85 f6                	test   %esi,%esi
  800887:	74 2b                	je     8008b4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800889:	83 fe 01             	cmp    $0x1,%esi
  80088c:	74 23                	je     8008b1 <strlcpy+0x3d>
  80088e:	0f b6 0b             	movzbl (%ebx),%ecx
  800891:	84 c9                	test   %cl,%cl
  800893:	74 1c                	je     8008b1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800895:	83 ee 02             	sub    $0x2,%esi
  800898:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089d:	88 08                	mov    %cl,(%eax)
  80089f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a2:	39 f2                	cmp    %esi,%edx
  8008a4:	74 0b                	je     8008b1 <strlcpy+0x3d>
  8008a6:	83 c2 01             	add    $0x1,%edx
  8008a9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ad:	84 c9                	test   %cl,%cl
  8008af:	75 ec                	jne    80089d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  8008b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b4:	29 f8                	sub    %edi,%eax
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5f                   	pop    %edi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c4:	0f b6 01             	movzbl (%ecx),%eax
  8008c7:	84 c0                	test   %al,%al
  8008c9:	74 16                	je     8008e1 <strcmp+0x26>
  8008cb:	3a 02                	cmp    (%edx),%al
  8008cd:	75 12                	jne    8008e1 <strcmp+0x26>
		p++, q++;
  8008cf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8008d6:	84 c0                	test   %al,%al
  8008d8:	74 07                	je     8008e1 <strcmp+0x26>
  8008da:	83 c1 01             	add    $0x1,%ecx
  8008dd:	3a 02                	cmp    (%edx),%al
  8008df:	74 ee                	je     8008cf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e1:	0f b6 c0             	movzbl %al,%eax
  8008e4:	0f b6 12             	movzbl (%edx),%edx
  8008e7:	29 d0                	sub    %edx,%eax
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008f5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fd:	85 d2                	test   %edx,%edx
  8008ff:	74 28                	je     800929 <strncmp+0x3e>
  800901:	0f b6 01             	movzbl (%ecx),%eax
  800904:	84 c0                	test   %al,%al
  800906:	74 24                	je     80092c <strncmp+0x41>
  800908:	3a 03                	cmp    (%ebx),%al
  80090a:	75 20                	jne    80092c <strncmp+0x41>
  80090c:	83 ea 01             	sub    $0x1,%edx
  80090f:	74 13                	je     800924 <strncmp+0x39>
		n--, p++, q++;
  800911:	83 c1 01             	add    $0x1,%ecx
  800914:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800917:	0f b6 01             	movzbl (%ecx),%eax
  80091a:	84 c0                	test   %al,%al
  80091c:	74 0e                	je     80092c <strncmp+0x41>
  80091e:	3a 03                	cmp    (%ebx),%al
  800920:	74 ea                	je     80090c <strncmp+0x21>
  800922:	eb 08                	jmp    80092c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800929:	5b                   	pop    %ebx
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092c:	0f b6 01             	movzbl (%ecx),%eax
  80092f:	0f b6 13             	movzbl (%ebx),%edx
  800932:	29 d0                	sub    %edx,%eax
  800934:	eb f3                	jmp    800929 <strncmp+0x3e>

00800936 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800940:	0f b6 10             	movzbl (%eax),%edx
  800943:	84 d2                	test   %dl,%dl
  800945:	74 1c                	je     800963 <strchr+0x2d>
		if (*s == c)
  800947:	38 ca                	cmp    %cl,%dl
  800949:	75 09                	jne    800954 <strchr+0x1e>
  80094b:	eb 1b                	jmp    800968 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 14                	je     800968 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800954:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800958:	84 d2                	test   %dl,%dl
  80095a:	75 f1                	jne    80094d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
  800961:	eb 05                	jmp    800968 <strchr+0x32>
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800974:	0f b6 10             	movzbl (%eax),%edx
  800977:	84 d2                	test   %dl,%dl
  800979:	74 14                	je     80098f <strfind+0x25>
		if (*s == c)
  80097b:	38 ca                	cmp    %cl,%dl
  80097d:	75 06                	jne    800985 <strfind+0x1b>
  80097f:	eb 0e                	jmp    80098f <strfind+0x25>
  800981:	38 ca                	cmp    %cl,%dl
  800983:	74 0a                	je     80098f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800985:	83 c0 01             	add    $0x1,%eax
  800988:	0f b6 10             	movzbl (%eax),%edx
  80098b:	84 d2                	test   %dl,%dl
  80098d:	75 f2                	jne    800981 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	83 ec 0c             	sub    $0xc,%esp
  800997:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80099a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80099d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a9:	85 c9                	test   %ecx,%ecx
  8009ab:	74 30                	je     8009dd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b3:	75 25                	jne    8009da <memset+0x49>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 20                	jne    8009da <memset+0x49>
		c &= 0xFF;
  8009ba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bd:	89 d3                	mov    %edx,%ebx
  8009bf:	c1 e3 08             	shl    $0x8,%ebx
  8009c2:	89 d6                	mov    %edx,%esi
  8009c4:	c1 e6 18             	shl    $0x18,%esi
  8009c7:	89 d0                	mov    %edx,%eax
  8009c9:	c1 e0 10             	shl    $0x10,%eax
  8009cc:	09 f0                	or     %esi,%eax
  8009ce:	09 d0                	or     %edx,%eax
  8009d0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d5:	fc                   	cld    
  8009d6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d8:	eb 03                	jmp    8009dd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009da:	fc                   	cld    
  8009db:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009dd:	89 f8                	mov    %edi,%eax
  8009df:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009e2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009e8:	89 ec                	mov    %ebp,%esp
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 08             	sub    $0x8,%esp
  8009f2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009f5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a01:	39 c6                	cmp    %eax,%esi
  800a03:	73 36                	jae    800a3b <memmove+0x4f>
  800a05:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a08:	39 d0                	cmp    %edx,%eax
  800a0a:	73 2f                	jae    800a3b <memmove+0x4f>
		s += n;
		d += n;
  800a0c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	f6 c2 03             	test   $0x3,%dl
  800a12:	75 1b                	jne    800a2f <memmove+0x43>
  800a14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1a:	75 13                	jne    800a2f <memmove+0x43>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 0e                	jne    800a2f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a21:	83 ef 04             	sub    $0x4,%edi
  800a24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2a:	fd                   	std    
  800a2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2d:	eb 09                	jmp    800a38 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a2f:	83 ef 01             	sub    $0x1,%edi
  800a32:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a35:	fd                   	std    
  800a36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a38:	fc                   	cld    
  800a39:	eb 20                	jmp    800a5b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a41:	75 13                	jne    800a56 <memmove+0x6a>
  800a43:	a8 03                	test   $0x3,%al
  800a45:	75 0f                	jne    800a56 <memmove+0x6a>
  800a47:	f6 c1 03             	test   $0x3,%cl
  800a4a:	75 0a                	jne    800a56 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a4f:	89 c7                	mov    %eax,%edi
  800a51:	fc                   	cld    
  800a52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a54:	eb 05                	jmp    800a5b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a56:	89 c7                	mov    %eax,%edi
  800a58:	fc                   	cld    
  800a59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a61:	89 ec                	mov    %ebp,%esp
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	89 04 24             	mov    %eax,(%esp)
  800a7f:	e8 68 ff ff ff       	call   8009ec <memmove>
}
  800a84:	c9                   	leave  
  800a85:	c3                   	ret    

00800a86 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a92:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9a:	85 ff                	test   %edi,%edi
  800a9c:	74 37                	je     800ad5 <memcmp+0x4f>
		if (*s1 != *s2)
  800a9e:	0f b6 03             	movzbl (%ebx),%eax
  800aa1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa4:	83 ef 01             	sub    $0x1,%edi
  800aa7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800aac:	38 c8                	cmp    %cl,%al
  800aae:	74 1c                	je     800acc <memcmp+0x46>
  800ab0:	eb 10                	jmp    800ac2 <memcmp+0x3c>
  800ab2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ab7:	83 c2 01             	add    $0x1,%edx
  800aba:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800abe:	38 c8                	cmp    %cl,%al
  800ac0:	74 0a                	je     800acc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800ac2:	0f b6 c0             	movzbl %al,%eax
  800ac5:	0f b6 c9             	movzbl %cl,%ecx
  800ac8:	29 c8                	sub    %ecx,%eax
  800aca:	eb 09                	jmp    800ad5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acc:	39 fa                	cmp    %edi,%edx
  800ace:	75 e2                	jne    800ab2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae5:	39 d0                	cmp    %edx,%eax
  800ae7:	73 19                	jae    800b02 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800aed:	38 08                	cmp    %cl,(%eax)
  800aef:	75 06                	jne    800af7 <memfind+0x1d>
  800af1:	eb 0f                	jmp    800b02 <memfind+0x28>
  800af3:	38 08                	cmp    %cl,(%eax)
  800af5:	74 0b                	je     800b02 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af7:	83 c0 01             	add    $0x1,%eax
  800afa:	39 d0                	cmp    %edx,%eax
  800afc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b00:	75 f1                	jne    800af3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b10:	0f b6 02             	movzbl (%edx),%eax
  800b13:	3c 20                	cmp    $0x20,%al
  800b15:	74 04                	je     800b1b <strtol+0x17>
  800b17:	3c 09                	cmp    $0x9,%al
  800b19:	75 0e                	jne    800b29 <strtol+0x25>
		s++;
  800b1b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1e:	0f b6 02             	movzbl (%edx),%eax
  800b21:	3c 20                	cmp    $0x20,%al
  800b23:	74 f6                	je     800b1b <strtol+0x17>
  800b25:	3c 09                	cmp    $0x9,%al
  800b27:	74 f2                	je     800b1b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b29:	3c 2b                	cmp    $0x2b,%al
  800b2b:	75 0a                	jne    800b37 <strtol+0x33>
		s++;
  800b2d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b30:	bf 00 00 00 00       	mov    $0x0,%edi
  800b35:	eb 10                	jmp    800b47 <strtol+0x43>
  800b37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b3c:	3c 2d                	cmp    $0x2d,%al
  800b3e:	75 07                	jne    800b47 <strtol+0x43>
		s++, neg = 1;
  800b40:	83 c2 01             	add    $0x1,%edx
  800b43:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b47:	85 db                	test   %ebx,%ebx
  800b49:	0f 94 c0             	sete   %al
  800b4c:	74 05                	je     800b53 <strtol+0x4f>
  800b4e:	83 fb 10             	cmp    $0x10,%ebx
  800b51:	75 15                	jne    800b68 <strtol+0x64>
  800b53:	80 3a 30             	cmpb   $0x30,(%edx)
  800b56:	75 10                	jne    800b68 <strtol+0x64>
  800b58:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b5c:	75 0a                	jne    800b68 <strtol+0x64>
		s += 2, base = 16;
  800b5e:	83 c2 02             	add    $0x2,%edx
  800b61:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b66:	eb 13                	jmp    800b7b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b68:	84 c0                	test   %al,%al
  800b6a:	74 0f                	je     800b7b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b71:	80 3a 30             	cmpb   $0x30,(%edx)
  800b74:	75 05                	jne    800b7b <strtol+0x77>
		s++, base = 8;
  800b76:	83 c2 01             	add    $0x1,%edx
  800b79:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b80:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b82:	0f b6 0a             	movzbl (%edx),%ecx
  800b85:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b88:	80 fb 09             	cmp    $0x9,%bl
  800b8b:	77 08                	ja     800b95 <strtol+0x91>
			dig = *s - '0';
  800b8d:	0f be c9             	movsbl %cl,%ecx
  800b90:	83 e9 30             	sub    $0x30,%ecx
  800b93:	eb 1e                	jmp    800bb3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b95:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b98:	80 fb 19             	cmp    $0x19,%bl
  800b9b:	77 08                	ja     800ba5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b9d:	0f be c9             	movsbl %cl,%ecx
  800ba0:	83 e9 57             	sub    $0x57,%ecx
  800ba3:	eb 0e                	jmp    800bb3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800ba5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ba8:	80 fb 19             	cmp    $0x19,%bl
  800bab:	77 14                	ja     800bc1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bad:	0f be c9             	movsbl %cl,%ecx
  800bb0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bb3:	39 f1                	cmp    %esi,%ecx
  800bb5:	7d 0e                	jge    800bc5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bb7:	83 c2 01             	add    $0x1,%edx
  800bba:	0f af c6             	imul   %esi,%eax
  800bbd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bbf:	eb c1                	jmp    800b82 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bc1:	89 c1                	mov    %eax,%ecx
  800bc3:	eb 02                	jmp    800bc7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bc7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcb:	74 05                	je     800bd2 <strtol+0xce>
		*endptr = (char *) s;
  800bcd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bd0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bd2:	89 ca                	mov    %ecx,%edx
  800bd4:	f7 da                	neg    %edx
  800bd6:	85 ff                	test   %edi,%edi
  800bd8:	0f 45 c2             	cmovne %edx,%eax
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800be9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bec:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 c3                	mov    %eax,%ebx
  800bfc:	89 c7                	mov    %eax,%edi
  800bfe:	89 c6                	mov    %eax,%esi
  800c00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c0b:	89 ec                	mov    %ebp,%esp
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c23:	b8 01 00 00 00       	mov    $0x1,%eax
  800c28:	89 d1                	mov    %edx,%ecx
  800c2a:	89 d3                	mov    %edx,%ebx
  800c2c:	89 d7                	mov    %edx,%edi
  800c2e:	89 d6                	mov    %edx,%esi
  800c30:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c32:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c35:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c3b:	89 ec                	mov    %ebp,%esp
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	83 ec 38             	sub    $0x38,%esp
  800c45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c53:	b8 03 00 00 00       	mov    $0x3,%eax
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 cb                	mov    %ecx,%ebx
  800c5d:	89 cf                	mov    %ecx,%edi
  800c5f:	89 ce                	mov    %ecx,%esi
  800c61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 28                	jle    800c8f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c72:	00 
  800c73:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800c7a:	00 
  800c7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c82:	00 
  800c83:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800c8a:	e8 ed 03 00 00       	call   80107c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c98:	89 ec                	mov    %ebp,%esp
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800cb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	89 d3                	mov    %edx,%ebx
  800cb9:	89 d7                	mov    %edx,%edi
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc8:	89 ec                	mov    %ebp,%esp
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_yield>:

void
sys_yield(void)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	89 d3                	mov    %edx,%ebx
  800ce9:	89 d7                	mov    %edx,%edi
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cf8:	89 ec                	mov    %ebp,%esp
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 38             	sub    $0x38,%esp
  800d02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d08:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	be 00 00 00 00       	mov    $0x0,%esi
  800d10:	b8 04 00 00 00       	mov    $0x4,%eax
  800d15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	89 f7                	mov    %esi,%edi
  800d20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 28                	jle    800d4e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d31:	00 
  800d32:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800d39:	00 
  800d3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d41:	00 
  800d42:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800d49:	e8 2e 03 00 00       	call   80107c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d4e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d51:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d54:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d57:	89 ec                	mov    %ebp,%esp
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	83 ec 38             	sub    $0x38,%esp
  800d61:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d64:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d67:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d80:	85 c0                	test   %eax,%eax
  800d82:	7e 28                	jle    800dac <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d8f:	00 
  800d90:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800d97:	00 
  800d98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9f:	00 
  800da0:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800da7:	e8 d0 02 00 00       	call   80107c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dac:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800daf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db5:	89 ec                	mov    %ebp,%esp
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	83 ec 38             	sub    $0x38,%esp
  800dbf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	b8 06 00 00 00       	mov    $0x6,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 df                	mov    %ebx,%edi
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 28                	jle    800e0a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ded:	00 
  800dee:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800df5:	00 
  800df6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfd:	00 
  800dfe:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e05:	e8 72 02 00 00       	call   80107c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e0a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e0d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e13:	89 ec                	mov    %ebp,%esp
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	83 ec 38             	sub    $0x38,%esp
  800e1d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e20:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e23:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	89 df                	mov    %ebx,%edi
  800e38:	89 de                	mov    %ebx,%esi
  800e3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	7e 28                	jle    800e68 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e44:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e4b:	00 
  800e4c:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e53:	00 
  800e54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5b:	00 
  800e5c:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e63:	e8 14 02 00 00       	call   80107c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e68:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e6b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e6e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e71:	89 ec                	mov    %ebp,%esp
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	83 ec 38             	sub    $0x38,%esp
  800e7b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e7e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e81:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e89:	b8 09 00 00 00       	mov    $0x9,%eax
  800e8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e91:	8b 55 08             	mov    0x8(%ebp),%edx
  800e94:	89 df                	mov    %ebx,%edi
  800e96:	89 de                	mov    %ebx,%esi
  800e98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	7e 28                	jle    800ec6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ea9:	00 
  800eaa:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800eb1:	00 
  800eb2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb9:	00 
  800eba:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800ec1:	e8 b6 01 00 00       	call   80107c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ec6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ecc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ecf:	89 ec                	mov    %ebp,%esp
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	83 ec 0c             	sub    $0xc,%esp
  800ed9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800edc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800edf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee2:	be 00 00 00 00       	mov    $0x0,%esi
  800ee7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800efa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800efd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f00:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f03:	89 ec                	mov    %ebp,%esp
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 38             	sub    $0x38,%esp
  800f0d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f10:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f13:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f20:	8b 55 08             	mov    0x8(%ebp),%edx
  800f23:	89 cb                	mov    %ecx,%ebx
  800f25:	89 cf                	mov    %ecx,%edi
  800f27:	89 ce                	mov    %ecx,%esi
  800f29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	7e 28                	jle    800f57 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f33:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f3a:	00 
  800f3b:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800f42:	00 
  800f43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4a:	00 
  800f4b:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800f52:	e8 25 01 00 00       	call   80107c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f57:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f5a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f5d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f60:	89 ec                	mov    %ebp,%esp
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 10             	sub    $0x10,%esp
  800f6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f72:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
    
    if (!pg)
  800f75:	85 c0                	test   %eax,%eax
        pg = (void *)UTOP;
  800f77:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800f7c:	0f 44 c2             	cmove  %edx,%eax

    int result;
    if ((result = sys_ipc_recv(pg))) {
  800f7f:	89 04 24             	mov    %eax,(%esp)
  800f82:	e8 80 ff ff ff       	call   800f07 <sys_ipc_recv>
  800f87:	85 c0                	test   %eax,%eax
  800f89:	74 16                	je     800fa1 <ipc_recv+0x3d>
        if (from_env_store)
  800f8b:	85 db                	test   %ebx,%ebx
  800f8d:	74 06                	je     800f95 <ipc_recv+0x31>
            *from_env_store = 0;
  800f8f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        if (perm_store)
  800f95:	85 f6                	test   %esi,%esi
  800f97:	74 2c                	je     800fc5 <ipc_recv+0x61>
            *perm_store = 0;
  800f99:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800f9f:	eb 24                	jmp    800fc5 <ipc_recv+0x61>
            
        return result;
    }

    if (from_env_store)
  800fa1:	85 db                	test   %ebx,%ebx
  800fa3:	74 0a                	je     800faf <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  800fa5:	a1 04 20 80 00       	mov    0x802004,%eax
  800faa:	8b 40 74             	mov    0x74(%eax),%eax
  800fad:	89 03                	mov    %eax,(%ebx)

    if (perm_store)
  800faf:	85 f6                	test   %esi,%esi
  800fb1:	74 0a                	je     800fbd <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  800fb3:	a1 04 20 80 00       	mov    0x802004,%eax
  800fb8:	8b 40 78             	mov    0x78(%eax),%eax
  800fbb:	89 06                	mov    %eax,(%esi)

	return thisenv->env_ipc_value;
  800fbd:	a1 04 20 80 00       	mov    0x802004,%eax
  800fc2:	8b 40 70             	mov    0x70(%eax),%eax
}
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	57                   	push   %edi
  800fd0:	56                   	push   %esi
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 1c             	sub    $0x1c,%esp
  800fd5:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

    if (!pg)
  800fde:	85 db                	test   %ebx,%ebx
        pg = (void *)UTOP;
  800fe0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800fe5:	0f 44 d8             	cmove  %eax,%ebx
  800fe8:	eb 05                	jmp    800fef <ipc_send+0x23>

    int result;
    while (-E_IPC_NOT_RECV == (result = sys_ipc_try_send(to_env, val, pg, perm)))
        sys_yield();
  800fea:	e8 dd fc ff ff       	call   800ccc <sys_yield>

    if (!pg)
        pg = (void *)UTOP;

    int result;
    while (-E_IPC_NOT_RECV == (result = sys_ipc_try_send(to_env, val, pg, perm)))
  800fef:	8b 45 14             	mov    0x14(%ebp),%eax
  800ff2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ff6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ffa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ffe:	89 34 24             	mov    %esi,(%esp)
  801001:	e8 cd fe ff ff       	call   800ed3 <sys_ipc_try_send>
  801006:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801009:	74 df                	je     800fea <ipc_send+0x1e>
        sys_yield();

    if (result)
  80100b:	85 c0                	test   %eax,%eax
  80100d:	74 1c                	je     80102b <ipc_send+0x5f>
        panic("ipc_send: error");
  80100f:	c7 44 24 08 4f 16 80 	movl   $0x80164f,0x8(%esp)
  801016:	00 
  801017:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80101e:	00 
  80101f:	c7 04 24 5f 16 80 00 	movl   $0x80165f,(%esp)
  801026:	e8 51 00 00 00       	call   80107c <_panic>
}
  80102b:	83 c4 1c             	add    $0x1c,%esp
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801039:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80103e:	39 c8                	cmp    %ecx,%eax
  801040:	74 17                	je     801059 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801042:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801047:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80104a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801050:	8b 52 50             	mov    0x50(%edx),%edx
  801053:	39 ca                	cmp    %ecx,%edx
  801055:	75 14                	jne    80106b <ipc_find_env+0x38>
  801057:	eb 05                	jmp    80105e <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801059:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80105e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801061:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801066:	8b 40 40             	mov    0x40(%eax),%eax
  801069:	eb 0e                	jmp    801079 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80106b:	83 c0 01             	add    $0x1,%eax
  80106e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801073:	75 d2                	jne    801047 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801075:	66 b8 00 00          	mov    $0x0,%ax
}
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    
	...

0080107c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801084:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801087:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80108d:	e8 0a fc ff ff       	call   800c9c <sys_getenvid>
  801092:	8b 55 0c             	mov    0xc(%ebp),%edx
  801095:	89 54 24 10          	mov    %edx,0x10(%esp)
  801099:	8b 55 08             	mov    0x8(%ebp),%edx
  80109c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a8:	c7 04 24 6c 16 80 00 	movl   $0x80166c,(%esp)
  8010af:	e8 23 f1 ff ff       	call   8001d7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8010bb:	89 04 24             	mov    %eax,(%esp)
  8010be:	e8 b3 f0 ff ff       	call   800176 <vcprintf>
	cprintf("\n");
  8010c3:	c7 04 24 af 13 80 00 	movl   $0x8013af,(%esp)
  8010ca:	e8 08 f1 ff ff       	call   8001d7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010cf:	cc                   	int3   
  8010d0:	eb fd                	jmp    8010cf <_panic+0x53>
	...

008010e0 <__udivdi3>:
  8010e0:	83 ec 1c             	sub    $0x1c,%esp
  8010e3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010e7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8010eb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010ef:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010f3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010f7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010fb:	85 ff                	test   %edi,%edi
  8010fd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801101:	89 44 24 08          	mov    %eax,0x8(%esp)
  801105:	89 cd                	mov    %ecx,%ebp
  801107:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110b:	75 33                	jne    801140 <__udivdi3+0x60>
  80110d:	39 f1                	cmp    %esi,%ecx
  80110f:	77 57                	ja     801168 <__udivdi3+0x88>
  801111:	85 c9                	test   %ecx,%ecx
  801113:	75 0b                	jne    801120 <__udivdi3+0x40>
  801115:	b8 01 00 00 00       	mov    $0x1,%eax
  80111a:	31 d2                	xor    %edx,%edx
  80111c:	f7 f1                	div    %ecx
  80111e:	89 c1                	mov    %eax,%ecx
  801120:	89 f0                	mov    %esi,%eax
  801122:	31 d2                	xor    %edx,%edx
  801124:	f7 f1                	div    %ecx
  801126:	89 c6                	mov    %eax,%esi
  801128:	8b 44 24 04          	mov    0x4(%esp),%eax
  80112c:	f7 f1                	div    %ecx
  80112e:	89 f2                	mov    %esi,%edx
  801130:	8b 74 24 10          	mov    0x10(%esp),%esi
  801134:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801138:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80113c:	83 c4 1c             	add    $0x1c,%esp
  80113f:	c3                   	ret    
  801140:	31 d2                	xor    %edx,%edx
  801142:	31 c0                	xor    %eax,%eax
  801144:	39 f7                	cmp    %esi,%edi
  801146:	77 e8                	ja     801130 <__udivdi3+0x50>
  801148:	0f bd cf             	bsr    %edi,%ecx
  80114b:	83 f1 1f             	xor    $0x1f,%ecx
  80114e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801152:	75 2c                	jne    801180 <__udivdi3+0xa0>
  801154:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801158:	76 04                	jbe    80115e <__udivdi3+0x7e>
  80115a:	39 f7                	cmp    %esi,%edi
  80115c:	73 d2                	jae    801130 <__udivdi3+0x50>
  80115e:	31 d2                	xor    %edx,%edx
  801160:	b8 01 00 00 00       	mov    $0x1,%eax
  801165:	eb c9                	jmp    801130 <__udivdi3+0x50>
  801167:	90                   	nop
  801168:	89 f2                	mov    %esi,%edx
  80116a:	f7 f1                	div    %ecx
  80116c:	31 d2                	xor    %edx,%edx
  80116e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801172:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801176:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80117a:	83 c4 1c             	add    $0x1c,%esp
  80117d:	c3                   	ret    
  80117e:	66 90                	xchg   %ax,%ax
  801180:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801185:	b8 20 00 00 00       	mov    $0x20,%eax
  80118a:	89 ea                	mov    %ebp,%edx
  80118c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801190:	d3 e7                	shl    %cl,%edi
  801192:	89 c1                	mov    %eax,%ecx
  801194:	d3 ea                	shr    %cl,%edx
  801196:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80119b:	09 fa                	or     %edi,%edx
  80119d:	89 f7                	mov    %esi,%edi
  80119f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011a3:	89 f2                	mov    %esi,%edx
  8011a5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011a9:	d3 e5                	shl    %cl,%ebp
  8011ab:	89 c1                	mov    %eax,%ecx
  8011ad:	d3 ef                	shr    %cl,%edi
  8011af:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011b4:	d3 e2                	shl    %cl,%edx
  8011b6:	89 c1                	mov    %eax,%ecx
  8011b8:	d3 ee                	shr    %cl,%esi
  8011ba:	09 d6                	or     %edx,%esi
  8011bc:	89 fa                	mov    %edi,%edx
  8011be:	89 f0                	mov    %esi,%eax
  8011c0:	f7 74 24 0c          	divl   0xc(%esp)
  8011c4:	89 d7                	mov    %edx,%edi
  8011c6:	89 c6                	mov    %eax,%esi
  8011c8:	f7 e5                	mul    %ebp
  8011ca:	39 d7                	cmp    %edx,%edi
  8011cc:	72 22                	jb     8011f0 <__udivdi3+0x110>
  8011ce:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8011d2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011d7:	d3 e5                	shl    %cl,%ebp
  8011d9:	39 c5                	cmp    %eax,%ebp
  8011db:	73 04                	jae    8011e1 <__udivdi3+0x101>
  8011dd:	39 d7                	cmp    %edx,%edi
  8011df:	74 0f                	je     8011f0 <__udivdi3+0x110>
  8011e1:	89 f0                	mov    %esi,%eax
  8011e3:	31 d2                	xor    %edx,%edx
  8011e5:	e9 46 ff ff ff       	jmp    801130 <__udivdi3+0x50>
  8011ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011f0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8011f3:	31 d2                	xor    %edx,%edx
  8011f5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011f9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011fd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801201:	83 c4 1c             	add    $0x1c,%esp
  801204:	c3                   	ret    
	...

00801210 <__umoddi3>:
  801210:	83 ec 1c             	sub    $0x1c,%esp
  801213:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801217:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80121b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80121f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801223:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801227:	8b 74 24 24          	mov    0x24(%esp),%esi
  80122b:	85 ed                	test   %ebp,%ebp
  80122d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801231:	89 44 24 08          	mov    %eax,0x8(%esp)
  801235:	89 cf                	mov    %ecx,%edi
  801237:	89 04 24             	mov    %eax,(%esp)
  80123a:	89 f2                	mov    %esi,%edx
  80123c:	75 1a                	jne    801258 <__umoddi3+0x48>
  80123e:	39 f1                	cmp    %esi,%ecx
  801240:	76 4e                	jbe    801290 <__umoddi3+0x80>
  801242:	f7 f1                	div    %ecx
  801244:	89 d0                	mov    %edx,%eax
  801246:	31 d2                	xor    %edx,%edx
  801248:	8b 74 24 10          	mov    0x10(%esp),%esi
  80124c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801250:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801254:	83 c4 1c             	add    $0x1c,%esp
  801257:	c3                   	ret    
  801258:	39 f5                	cmp    %esi,%ebp
  80125a:	77 54                	ja     8012b0 <__umoddi3+0xa0>
  80125c:	0f bd c5             	bsr    %ebp,%eax
  80125f:	83 f0 1f             	xor    $0x1f,%eax
  801262:	89 44 24 04          	mov    %eax,0x4(%esp)
  801266:	75 60                	jne    8012c8 <__umoddi3+0xb8>
  801268:	3b 0c 24             	cmp    (%esp),%ecx
  80126b:	0f 87 07 01 00 00    	ja     801378 <__umoddi3+0x168>
  801271:	89 f2                	mov    %esi,%edx
  801273:	8b 34 24             	mov    (%esp),%esi
  801276:	29 ce                	sub    %ecx,%esi
  801278:	19 ea                	sbb    %ebp,%edx
  80127a:	89 34 24             	mov    %esi,(%esp)
  80127d:	8b 04 24             	mov    (%esp),%eax
  801280:	8b 74 24 10          	mov    0x10(%esp),%esi
  801284:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801288:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80128c:	83 c4 1c             	add    $0x1c,%esp
  80128f:	c3                   	ret    
  801290:	85 c9                	test   %ecx,%ecx
  801292:	75 0b                	jne    80129f <__umoddi3+0x8f>
  801294:	b8 01 00 00 00       	mov    $0x1,%eax
  801299:	31 d2                	xor    %edx,%edx
  80129b:	f7 f1                	div    %ecx
  80129d:	89 c1                	mov    %eax,%ecx
  80129f:	89 f0                	mov    %esi,%eax
  8012a1:	31 d2                	xor    %edx,%edx
  8012a3:	f7 f1                	div    %ecx
  8012a5:	8b 04 24             	mov    (%esp),%eax
  8012a8:	f7 f1                	div    %ecx
  8012aa:	eb 98                	jmp    801244 <__umoddi3+0x34>
  8012ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	89 f2                	mov    %esi,%edx
  8012b2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012b6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012ba:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012be:	83 c4 1c             	add    $0x1c,%esp
  8012c1:	c3                   	ret    
  8012c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012c8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012cd:	89 e8                	mov    %ebp,%eax
  8012cf:	bd 20 00 00 00       	mov    $0x20,%ebp
  8012d4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8012d8:	89 fa                	mov    %edi,%edx
  8012da:	d3 e0                	shl    %cl,%eax
  8012dc:	89 e9                	mov    %ebp,%ecx
  8012de:	d3 ea                	shr    %cl,%edx
  8012e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012e5:	09 c2                	or     %eax,%edx
  8012e7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012eb:	89 14 24             	mov    %edx,(%esp)
  8012ee:	89 f2                	mov    %esi,%edx
  8012f0:	d3 e7                	shl    %cl,%edi
  8012f2:	89 e9                	mov    %ebp,%ecx
  8012f4:	d3 ea                	shr    %cl,%edx
  8012f6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ff:	d3 e6                	shl    %cl,%esi
  801301:	89 e9                	mov    %ebp,%ecx
  801303:	d3 e8                	shr    %cl,%eax
  801305:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80130a:	09 f0                	or     %esi,%eax
  80130c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801310:	f7 34 24             	divl   (%esp)
  801313:	d3 e6                	shl    %cl,%esi
  801315:	89 74 24 08          	mov    %esi,0x8(%esp)
  801319:	89 d6                	mov    %edx,%esi
  80131b:	f7 e7                	mul    %edi
  80131d:	39 d6                	cmp    %edx,%esi
  80131f:	89 c1                	mov    %eax,%ecx
  801321:	89 d7                	mov    %edx,%edi
  801323:	72 3f                	jb     801364 <__umoddi3+0x154>
  801325:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801329:	72 35                	jb     801360 <__umoddi3+0x150>
  80132b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80132f:	29 c8                	sub    %ecx,%eax
  801331:	19 fe                	sbb    %edi,%esi
  801333:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801338:	89 f2                	mov    %esi,%edx
  80133a:	d3 e8                	shr    %cl,%eax
  80133c:	89 e9                	mov    %ebp,%ecx
  80133e:	d3 e2                	shl    %cl,%edx
  801340:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801345:	09 d0                	or     %edx,%eax
  801347:	89 f2                	mov    %esi,%edx
  801349:	d3 ea                	shr    %cl,%edx
  80134b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80134f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801353:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801357:	83 c4 1c             	add    $0x1c,%esp
  80135a:	c3                   	ret    
  80135b:	90                   	nop
  80135c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801360:	39 d6                	cmp    %edx,%esi
  801362:	75 c7                	jne    80132b <__umoddi3+0x11b>
  801364:	89 d7                	mov    %edx,%edi
  801366:	89 c1                	mov    %eax,%ecx
  801368:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80136c:	1b 3c 24             	sbb    (%esp),%edi
  80136f:	eb ba                	jmp    80132b <__umoddi3+0x11b>
  801371:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801378:	39 f5                	cmp    %esi,%ebp
  80137a:	0f 82 f1 fe ff ff    	jb     801271 <__umoddi3+0x61>
  801380:	e9 f8 fe ff ff       	jmp    80127d <__umoddi3+0x6d>
