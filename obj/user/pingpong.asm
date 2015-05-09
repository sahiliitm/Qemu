
obj/user/pingpong:     file format elf32-i386


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

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 39 10 00 00       	call   80107b <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 7c 0c 00 00       	call   800ccc <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  80005f:	e8 a7 01 00 00       	call   80020b <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 85 12 00 00       	call   80130c <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 02 12 00 00       	call   8012a4 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 20 0c 00 00       	call   800ccc <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 76 17 80 00 	movl   $0x801776,(%esp)
  8000bf:	e8 47 01 00 00       	call   80020b <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 21 12 00 00       	call   80130c <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}

}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

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
  800114:	e8 b3 0b 00 00       	call   800ccc <sys_getenvid>
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
  80013d:	e8 f2 fe ff ff       	call   800034 <umain>

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
  800161:	e8 09 0b 00 00       	call   800c6f <sys_env_destroy>
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 14             	sub    $0x14,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 03                	mov    (%ebx),%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017b:	83 c0 01             	add    $0x1,%eax
  80017e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800180:	3d ff 00 00 00       	cmp    $0xff,%eax
  800185:	75 19                	jne    8001a0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800187:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80018e:	00 
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	89 04 24             	mov    %eax,(%esp)
  800195:	e8 76 0a 00 00       	call   800c10 <sys_cputs>
		b->idx = 0;
  80019a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001a0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a4:	83 c4 14             	add    $0x14,%esp
  8001a7:	5b                   	pop    %ebx
  8001a8:	5d                   	pop    %ebp
  8001a9:	c3                   	ret    

008001aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ba:	00 00 00 
	b.cnt = 0;
  8001bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001df:	c7 04 24 68 01 80 00 	movl   $0x800168,(%esp)
  8001e6:	e8 d9 01 00 00       	call   8003c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001eb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	e8 0d 0a 00 00       	call   800c10 <sys_cputs>

	return b.cnt;
}
  800203:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800211:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	8b 45 08             	mov    0x8(%ebp),%eax
  80021b:	89 04 24             	mov    %eax,(%esp)
  80021e:	e8 87 ff ff ff       	call   8001aa <vcprintf>
	va_end(ap);

	return cnt;
}
  800223:	c9                   	leave  
  800224:	c3                   	ret    
	...

00800230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 3c             	sub    $0x3c,%esp
  800239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80023c:	89 d7                	mov    %edx,%edi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800244:	8b 45 0c             	mov    0xc(%ebp),%eax
  800247:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80024d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800250:	b8 00 00 00 00       	mov    $0x0,%eax
  800255:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800258:	72 11                	jb     80026b <printnum+0x3b>
  80025a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80025d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800260:	76 09                	jbe    80026b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800262:	83 eb 01             	sub    $0x1,%ebx
  800265:	85 db                	test   %ebx,%ebx
  800267:	7f 51                	jg     8002ba <printnum+0x8a>
  800269:	eb 5e                	jmp    8002c9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80026f:	83 eb 01             	sub    $0x1,%ebx
  800272:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800276:	8b 45 10             	mov    0x10(%ebp),%eax
  800279:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800281:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800285:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028c:	00 
  80028d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800290:	89 04 24             	mov    %eax,(%esp)
  800293:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029a:	e8 11 12 00 00       	call   8014b0 <__udivdi3>
  80029f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002a3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ae:	89 fa                	mov    %edi,%edx
  8002b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002b3:	e8 78 ff ff ff       	call   800230 <printnum>
  8002b8:	eb 0f                	jmp    8002c9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002be:	89 34 24             	mov    %esi,(%esp)
  8002c1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c4:	83 eb 01             	sub    $0x1,%ebx
  8002c7:	75 f1                	jne    8002ba <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002df:	00 
  8002e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ed:	e8 ee 12 00 00       	call   8015e0 <__umoddi3>
  8002f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f6:	0f be 80 93 17 80 00 	movsbl 0x801793(%eax),%eax
  8002fd:	89 04 24             	mov    %eax,(%esp)
  800300:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800303:	83 c4 3c             	add    $0x3c,%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5f                   	pop    %edi
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030e:	83 fa 01             	cmp    $0x1,%edx
  800311:	7e 0e                	jle    800321 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 08             	lea    0x8(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	8b 52 04             	mov    0x4(%edx),%edx
  80031f:	eb 22                	jmp    800343 <getuint+0x38>
	else if (lflag)
  800321:	85 d2                	test   %edx,%edx
  800323:	74 10                	je     800335 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800325:	8b 10                	mov    (%eax),%edx
  800327:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032a:	89 08                	mov    %ecx,(%eax)
  80032c:	8b 02                	mov    (%edx),%eax
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
  800333:	eb 0e                	jmp    800343 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800335:	8b 10                	mov    (%eax),%edx
  800337:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033a:	89 08                	mov    %ecx,(%eax)
  80033c:	8b 02                	mov    (%edx),%eax
  80033e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800348:	83 fa 01             	cmp    $0x1,%edx
  80034b:	7e 0e                	jle    80035b <getint+0x16>
		return va_arg(*ap, long long);
  80034d:	8b 10                	mov    (%eax),%edx
  80034f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800352:	89 08                	mov    %ecx,(%eax)
  800354:	8b 02                	mov    (%edx),%eax
  800356:	8b 52 04             	mov    0x4(%edx),%edx
  800359:	eb 22                	jmp    80037d <getint+0x38>
	else if (lflag)
  80035b:	85 d2                	test   %edx,%edx
  80035d:	74 10                	je     80036f <getint+0x2a>
		return va_arg(*ap, long);
  80035f:	8b 10                	mov    (%eax),%edx
  800361:	8d 4a 04             	lea    0x4(%edx),%ecx
  800364:	89 08                	mov    %ecx,(%eax)
  800366:	8b 02                	mov    (%edx),%eax
  800368:	89 c2                	mov    %eax,%edx
  80036a:	c1 fa 1f             	sar    $0x1f,%edx
  80036d:	eb 0e                	jmp    80037d <getint+0x38>
	else
		return va_arg(*ap, int);
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	8d 4a 04             	lea    0x4(%edx),%ecx
  800374:	89 08                	mov    %ecx,(%eax)
  800376:	8b 02                	mov    (%edx),%eax
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800385:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	3b 50 04             	cmp    0x4(%eax),%edx
  80038e:	73 0a                	jae    80039a <sprintputch+0x1b>
		*b->buf++ = ch;
  800390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800393:	88 0a                	mov    %cl,(%edx)
  800395:	83 c2 01             	add    $0x1,%edx
  800398:	89 10                	mov    %edx,(%eax)
}
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ba:	89 04 24             	mov    %eax,(%esp)
  8003bd:	e8 02 00 00 00       	call   8003c4 <vprintfmt>
	va_end(ap);
}
  8003c2:	c9                   	leave  
  8003c3:	c3                   	ret    

008003c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	57                   	push   %edi
  8003c8:	56                   	push   %esi
  8003c9:	53                   	push   %ebx
  8003ca:	83 ec 4c             	sub    $0x4c,%esp
  8003cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d0:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d3:	eb 12                	jmp    8003e7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d5:	85 c0                	test   %eax,%eax
  8003d7:	0f 84 77 03 00 00    	je     800754 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  8003dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e1:	89 04 24             	mov    %eax,(%esp)
  8003e4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e7:	0f b6 06             	movzbl (%esi),%eax
  8003ea:	83 c6 01             	add    $0x1,%esi
  8003ed:	83 f8 25             	cmp    $0x25,%eax
  8003f0:	75 e3                	jne    8003d5 <vprintfmt+0x11>
  8003f2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800402:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800411:	eb 2b                	jmp    80043e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800416:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80041a:	eb 22                	jmp    80043e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800423:	eb 19                	jmp    80043e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800428:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042f:	eb 0d                	jmp    80043e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800431:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800434:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800437:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	0f b6 06             	movzbl (%esi),%eax
  800441:	0f b6 d0             	movzbl %al,%edx
  800444:	8d 7e 01             	lea    0x1(%esi),%edi
  800447:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80044a:	83 e8 23             	sub    $0x23,%eax
  80044d:	3c 55                	cmp    $0x55,%al
  80044f:	0f 87 d9 02 00 00    	ja     80072e <vprintfmt+0x36a>
  800455:	0f b6 c0             	movzbl %al,%eax
  800458:	ff 24 85 60 18 80 00 	jmp    *0x801860(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045f:	83 ea 30             	sub    $0x30,%edx
  800462:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800465:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800469:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80046f:	83 fa 09             	cmp    $0x9,%edx
  800472:	77 4a                	ja     8004be <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800477:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80047a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80047d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800481:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800484:	8d 50 d0             	lea    -0x30(%eax),%edx
  800487:	83 fa 09             	cmp    $0x9,%edx
  80048a:	76 eb                	jbe    800477 <vprintfmt+0xb3>
  80048c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80048f:	eb 2d                	jmp    8004be <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 50 04             	lea    0x4(%eax),%edx
  800497:	89 55 14             	mov    %edx,0x14(%ebp)
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a2:	eb 1a                	jmp    8004be <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ab:	79 91                	jns    80043e <vprintfmt+0x7a>
  8004ad:	e9 73 ff ff ff       	jmp    800425 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004bc:	eb 80                	jmp    80043e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c2:	0f 89 76 ff ff ff    	jns    80043e <vprintfmt+0x7a>
  8004c8:	e9 64 ff ff ff       	jmp    800431 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004cd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004d3:	e9 66 ff ff ff       	jmp    80043e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 50 04             	lea    0x4(%eax),%edx
  8004de:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e5:	8b 00                	mov    (%eax),%eax
  8004e7:	89 04 24             	mov    %eax,(%esp)
  8004ea:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004f0:	e9 f2 fe ff ff       	jmp    8003e7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f8:	8d 50 04             	lea    0x4(%eax),%edx
  8004fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fe:	8b 00                	mov    (%eax),%eax
  800500:	89 c2                	mov    %eax,%edx
  800502:	c1 fa 1f             	sar    $0x1f,%edx
  800505:	31 d0                	xor    %edx,%eax
  800507:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800509:	83 f8 08             	cmp    $0x8,%eax
  80050c:	7f 0b                	jg     800519 <vprintfmt+0x155>
  80050e:	8b 14 85 c0 19 80 00 	mov    0x8019c0(,%eax,4),%edx
  800515:	85 d2                	test   %edx,%edx
  800517:	75 23                	jne    80053c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800519:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051d:	c7 44 24 08 ab 17 80 	movl   $0x8017ab,0x8(%esp)
  800524:	00 
  800525:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800529:	8b 7d 08             	mov    0x8(%ebp),%edi
  80052c:	89 3c 24             	mov    %edi,(%esp)
  80052f:	e8 68 fe ff ff       	call   80039c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800534:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800537:	e9 ab fe ff ff       	jmp    8003e7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80053c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800540:	c7 44 24 08 b4 17 80 	movl   $0x8017b4,0x8(%esp)
  800547:	00 
  800548:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80054f:	89 3c 24             	mov    %edi,(%esp)
  800552:	e8 45 fe ff ff       	call   80039c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80055a:	e9 88 fe ff ff       	jmp    8003e7 <vprintfmt+0x23>
  80055f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800562:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800565:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800573:	85 f6                	test   %esi,%esi
  800575:	ba a4 17 80 00       	mov    $0x8017a4,%edx
  80057a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80057d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800581:	7e 06                	jle    800589 <vprintfmt+0x1c5>
  800583:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800587:	75 10                	jne    800599 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800589:	0f be 06             	movsbl (%esi),%eax
  80058c:	83 c6 01             	add    $0x1,%esi
  80058f:	85 c0                	test   %eax,%eax
  800591:	0f 85 86 00 00 00    	jne    80061d <vprintfmt+0x259>
  800597:	eb 76                	jmp    80060f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800599:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80059d:	89 34 24             	mov    %esi,(%esp)
  8005a0:	e8 56 02 00 00       	call   8007fb <strnlen>
  8005a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005a8:	29 c2                	sub    %eax,%edx
  8005aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ad:	85 d2                	test   %edx,%edx
  8005af:	7e d8                	jle    800589 <vprintfmt+0x1c5>
					putch(padc, putdat);
  8005b1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005b5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005b8:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8005bb:	89 d6                	mov    %edx,%esi
  8005bd:	89 c7                	mov    %eax,%edi
  8005bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c3:	89 3c 24             	mov    %edi,(%esp)
  8005c6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c9:	83 ee 01             	sub    $0x1,%esi
  8005cc:	75 f1                	jne    8005bf <vprintfmt+0x1fb>
  8005ce:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8005d1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005d4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005d7:	eb b0                	jmp    800589 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005dd:	74 18                	je     8005f7 <vprintfmt+0x233>
  8005df:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005e2:	83 fa 5e             	cmp    $0x5e,%edx
  8005e5:	76 10                	jbe    8005f7 <vprintfmt+0x233>
					putch('?', putdat);
  8005e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005eb:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f2:	ff 55 08             	call   *0x8(%ebp)
  8005f5:	eb 0a                	jmp    800601 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  8005f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fb:	89 04 24             	mov    %eax,(%esp)
  8005fe:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800601:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800605:	0f be 06             	movsbl (%esi),%eax
  800608:	83 c6 01             	add    $0x1,%esi
  80060b:	85 c0                	test   %eax,%eax
  80060d:	75 0e                	jne    80061d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800612:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800616:	7f 11                	jg     800629 <vprintfmt+0x265>
  800618:	e9 ca fd ff ff       	jmp    8003e7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061d:	85 ff                	test   %edi,%edi
  80061f:	90                   	nop
  800620:	78 b7                	js     8005d9 <vprintfmt+0x215>
  800622:	83 ef 01             	sub    $0x1,%edi
  800625:	79 b2                	jns    8005d9 <vprintfmt+0x215>
  800627:	eb e6                	jmp    80060f <vprintfmt+0x24b>
  800629:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80062c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80062f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800633:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80063a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063c:	83 ee 01             	sub    $0x1,%esi
  80063f:	75 ee                	jne    80062f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800644:	e9 9e fd ff ff       	jmp    8003e7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800649:	89 ca                	mov    %ecx,%edx
  80064b:	8d 45 14             	lea    0x14(%ebp),%eax
  80064e:	e8 f2 fc ff ff       	call   800345 <getint>
  800653:	89 c6                	mov    %eax,%esi
  800655:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800657:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80065c:	85 d2                	test   %edx,%edx
  80065e:	0f 89 8c 00 00 00    	jns    8006f0 <vprintfmt+0x32c>
				putch('-', putdat);
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800672:	f7 de                	neg    %esi
  800674:	83 d7 00             	adc    $0x0,%edi
  800677:	f7 df                	neg    %edi
			}
			base = 10;
  800679:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067e:	eb 70                	jmp    8006f0 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800680:	89 ca                	mov    %ecx,%edx
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 81 fc ff ff       	call   80030b <getuint>
  80068a:	89 c6                	mov    %eax,%esi
  80068c:	89 d7                	mov    %edx,%edi
			base = 10;
  80068e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800693:	eb 5b                	jmp    8006f0 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  800695:	89 ca                	mov    %ecx,%edx
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	e8 a6 fc ff ff       	call   800345 <getint>
  80069f:	89 c6                	mov    %eax,%esi
  8006a1:	89 d7                	mov    %edx,%edi
			base = 8;
  8006a3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006a8:	eb 46                	jmp    8006f0 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cf:	8b 30                	mov    (%eax),%esi
  8006d1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006db:	eb 13                	jmp    8006f0 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006dd:	89 ca                	mov    %ecx,%edx
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e2:	e8 24 fc ff ff       	call   80030b <getuint>
  8006e7:	89 c6                	mov    %eax,%esi
  8006e9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800703:	89 34 24             	mov    %esi,(%esp)
  800706:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070a:	89 da                	mov    %ebx,%edx
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	e8 1c fb ff ff       	call   800230 <printnum>
			break;
  800714:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800717:	e9 cb fc ff ff       	jmp    8003e7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	89 14 24             	mov    %edx,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 b9 fc ff ff       	jmp    8003e7 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800739:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800740:	0f 84 a1 fc ff ff    	je     8003e7 <vprintfmt+0x23>
  800746:	83 ee 01             	sub    $0x1,%esi
  800749:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80074d:	75 f7                	jne    800746 <vprintfmt+0x382>
  80074f:	e9 93 fc ff ff       	jmp    8003e7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800754:	83 c4 4c             	add    $0x4c,%esp
  800757:	5b                   	pop    %ebx
  800758:	5e                   	pop    %esi
  800759:	5f                   	pop    %edi
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	83 ec 28             	sub    $0x28,%esp
  800762:	8b 45 08             	mov    0x8(%ebp),%eax
  800765:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800768:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800772:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800779:	85 c0                	test   %eax,%eax
  80077b:	74 30                	je     8007ad <vsnprintf+0x51>
  80077d:	85 d2                	test   %edx,%edx
  80077f:	7e 2c                	jle    8007ad <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800788:	8b 45 10             	mov    0x10(%ebp),%eax
  80078b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800792:	89 44 24 04          	mov    %eax,0x4(%esp)
  800796:	c7 04 24 7f 03 80 00 	movl   $0x80037f,(%esp)
  80079d:	e8 22 fc ff ff       	call   8003c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ab:	eb 05                	jmp    8007b2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	89 04 24             	mov    %eax,(%esp)
  8007d5:	e8 82 ff ff ff       	call   80075c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    
  8007dc:	00 00                	add    %al,(%eax)
	...

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ee:	74 09                	je     8007f9 <strlen+0x19>
		n++;
  8007f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f7:	75 f7                	jne    8007f0 <strlen+0x10>
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
  80080a:	85 c9                	test   %ecx,%ecx
  80080c:	74 1a                	je     800828 <strnlen+0x2d>
  80080e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800811:	74 15                	je     800828 <strnlen+0x2d>
  800813:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800818:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081a:	39 ca                	cmp    %ecx,%edx
  80081c:	74 0a                	je     800828 <strnlen+0x2d>
  80081e:	83 c2 01             	add    $0x1,%edx
  800821:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800826:	75 f0                	jne    800818 <strnlen+0x1d>
		n++;
	return n;
}
  800828:	5b                   	pop    %ebx
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800835:	ba 00 00 00 00       	mov    $0x0,%edx
  80083a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80083e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800841:	83 c2 01             	add    $0x1,%edx
  800844:	84 c9                	test   %cl,%cl
  800846:	75 f2                	jne    80083a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800848:	5b                   	pop    %ebx
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800855:	89 1c 24             	mov    %ebx,(%esp)
  800858:	e8 83 ff ff ff       	call   8007e0 <strlen>
	strcpy(dst + len, src);
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800860:	89 54 24 04          	mov    %edx,0x4(%esp)
  800864:	01 d8                	add    %ebx,%eax
  800866:	89 04 24             	mov    %eax,(%esp)
  800869:	e8 bd ff ff ff       	call   80082b <strcpy>
	return dst;
}
  80086e:	89 d8                	mov    %ebx,%eax
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	5b                   	pop    %ebx
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800884:	85 f6                	test   %esi,%esi
  800886:	74 18                	je     8008a0 <strncpy+0x2a>
  800888:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80088d:	0f b6 1a             	movzbl (%edx),%ebx
  800890:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800893:	80 3a 01             	cmpb   $0x1,(%edx)
  800896:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800899:	83 c1 01             	add    $0x1,%ecx
  80089c:	39 f1                	cmp    %esi,%ecx
  80089e:	75 ed                	jne    80088d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	57                   	push   %edi
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b3:	89 f8                	mov    %edi,%eax
  8008b5:	85 f6                	test   %esi,%esi
  8008b7:	74 2b                	je     8008e4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8008b9:	83 fe 01             	cmp    $0x1,%esi
  8008bc:	74 23                	je     8008e1 <strlcpy+0x3d>
  8008be:	0f b6 0b             	movzbl (%ebx),%ecx
  8008c1:	84 c9                	test   %cl,%cl
  8008c3:	74 1c                	je     8008e1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008c5:	83 ee 02             	sub    $0x2,%esi
  8008c8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cd:	88 08                	mov    %cl,(%eax)
  8008cf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d2:	39 f2                	cmp    %esi,%edx
  8008d4:	74 0b                	je     8008e1 <strlcpy+0x3d>
  8008d6:	83 c2 01             	add    $0x1,%edx
  8008d9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008dd:	84 c9                	test   %cl,%cl
  8008df:	75 ec                	jne    8008cd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  8008e1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e4:	29 f8                	sub    %edi,%eax
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5f                   	pop    %edi
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f4:	0f b6 01             	movzbl (%ecx),%eax
  8008f7:	84 c0                	test   %al,%al
  8008f9:	74 16                	je     800911 <strcmp+0x26>
  8008fb:	3a 02                	cmp    (%edx),%al
  8008fd:	75 12                	jne    800911 <strcmp+0x26>
		p++, q++;
  8008ff:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800902:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800906:	84 c0                	test   %al,%al
  800908:	74 07                	je     800911 <strcmp+0x26>
  80090a:	83 c1 01             	add    $0x1,%ecx
  80090d:	3a 02                	cmp    (%edx),%al
  80090f:	74 ee                	je     8008ff <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800911:	0f b6 c0             	movzbl %al,%eax
  800914:	0f b6 12             	movzbl (%edx),%edx
  800917:	29 d0                	sub    %edx,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800925:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80092d:	85 d2                	test   %edx,%edx
  80092f:	74 28                	je     800959 <strncmp+0x3e>
  800931:	0f b6 01             	movzbl (%ecx),%eax
  800934:	84 c0                	test   %al,%al
  800936:	74 24                	je     80095c <strncmp+0x41>
  800938:	3a 03                	cmp    (%ebx),%al
  80093a:	75 20                	jne    80095c <strncmp+0x41>
  80093c:	83 ea 01             	sub    $0x1,%edx
  80093f:	74 13                	je     800954 <strncmp+0x39>
		n--, p++, q++;
  800941:	83 c1 01             	add    $0x1,%ecx
  800944:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800947:	0f b6 01             	movzbl (%ecx),%eax
  80094a:	84 c0                	test   %al,%al
  80094c:	74 0e                	je     80095c <strncmp+0x41>
  80094e:	3a 03                	cmp    (%ebx),%al
  800950:	74 ea                	je     80093c <strncmp+0x21>
  800952:	eb 08                	jmp    80095c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800959:	5b                   	pop    %ebx
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095c:	0f b6 01             	movzbl (%ecx),%eax
  80095f:	0f b6 13             	movzbl (%ebx),%edx
  800962:	29 d0                	sub    %edx,%eax
  800964:	eb f3                	jmp    800959 <strncmp+0x3e>

00800966 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800970:	0f b6 10             	movzbl (%eax),%edx
  800973:	84 d2                	test   %dl,%dl
  800975:	74 1c                	je     800993 <strchr+0x2d>
		if (*s == c)
  800977:	38 ca                	cmp    %cl,%dl
  800979:	75 09                	jne    800984 <strchr+0x1e>
  80097b:	eb 1b                	jmp    800998 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800980:	38 ca                	cmp    %cl,%dl
  800982:	74 14                	je     800998 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800984:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800988:	84 d2                	test   %dl,%dl
  80098a:	75 f1                	jne    80097d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
  800991:	eb 05                	jmp    800998 <strchr+0x32>
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a4:	0f b6 10             	movzbl (%eax),%edx
  8009a7:	84 d2                	test   %dl,%dl
  8009a9:	74 14                	je     8009bf <strfind+0x25>
		if (*s == c)
  8009ab:	38 ca                	cmp    %cl,%dl
  8009ad:	75 06                	jne    8009b5 <strfind+0x1b>
  8009af:	eb 0e                	jmp    8009bf <strfind+0x25>
  8009b1:	38 ca                	cmp    %cl,%dl
  8009b3:	74 0a                	je     8009bf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	0f b6 10             	movzbl (%eax),%edx
  8009bb:	84 d2                	test   %dl,%dl
  8009bd:	75 f2                	jne    8009b1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	83 ec 0c             	sub    $0xc,%esp
  8009c7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009ca:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009cd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d9:	85 c9                	test   %ecx,%ecx
  8009db:	74 30                	je     800a0d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e3:	75 25                	jne    800a0a <memset+0x49>
  8009e5:	f6 c1 03             	test   $0x3,%cl
  8009e8:	75 20                	jne    800a0a <memset+0x49>
		c &= 0xFF;
  8009ea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ed:	89 d3                	mov    %edx,%ebx
  8009ef:	c1 e3 08             	shl    $0x8,%ebx
  8009f2:	89 d6                	mov    %edx,%esi
  8009f4:	c1 e6 18             	shl    $0x18,%esi
  8009f7:	89 d0                	mov    %edx,%eax
  8009f9:	c1 e0 10             	shl    $0x10,%eax
  8009fc:	09 f0                	or     %esi,%eax
  8009fe:	09 d0                	or     %edx,%eax
  800a00:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a02:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a05:	fc                   	cld    
  800a06:	f3 ab                	rep stos %eax,%es:(%edi)
  800a08:	eb 03                	jmp    800a0d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0a:	fc                   	cld    
  800a0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0d:	89 f8                	mov    %edi,%eax
  800a0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a18:	89 ec                	mov    %ebp,%esp
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	83 ec 08             	sub    $0x8,%esp
  800a22:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a25:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a31:	39 c6                	cmp    %eax,%esi
  800a33:	73 36                	jae    800a6b <memmove+0x4f>
  800a35:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a38:	39 d0                	cmp    %edx,%eax
  800a3a:	73 2f                	jae    800a6b <memmove+0x4f>
		s += n;
		d += n;
  800a3c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3f:	f6 c2 03             	test   $0x3,%dl
  800a42:	75 1b                	jne    800a5f <memmove+0x43>
  800a44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4a:	75 13                	jne    800a5f <memmove+0x43>
  800a4c:	f6 c1 03             	test   $0x3,%cl
  800a4f:	75 0e                	jne    800a5f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a51:	83 ef 04             	sub    $0x4,%edi
  800a54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a57:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a5a:	fd                   	std    
  800a5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5d:	eb 09                	jmp    800a68 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a5f:	83 ef 01             	sub    $0x1,%edi
  800a62:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a65:	fd                   	std    
  800a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a68:	fc                   	cld    
  800a69:	eb 20                	jmp    800a8b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a71:	75 13                	jne    800a86 <memmove+0x6a>
  800a73:	a8 03                	test   $0x3,%al
  800a75:	75 0f                	jne    800a86 <memmove+0x6a>
  800a77:	f6 c1 03             	test   $0x3,%cl
  800a7a:	75 0a                	jne    800a86 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a7c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a7f:	89 c7                	mov    %eax,%edi
  800a81:	fc                   	cld    
  800a82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a84:	eb 05                	jmp    800a8b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a86:	89 c7                	mov    %eax,%edi
  800a88:	fc                   	cld    
  800a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a8e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a91:	89 ec                	mov    %ebp,%esp
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a9b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	89 04 24             	mov    %eax,(%esp)
  800aaf:	e8 68 ff ff ff       	call   800a1c <memmove>
}
  800ab4:	c9                   	leave  
  800ab5:	c3                   	ret    

00800ab6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800abf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aca:	85 ff                	test   %edi,%edi
  800acc:	74 37                	je     800b05 <memcmp+0x4f>
		if (*s1 != *s2)
  800ace:	0f b6 03             	movzbl (%ebx),%eax
  800ad1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad4:	83 ef 01             	sub    $0x1,%edi
  800ad7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800adc:	38 c8                	cmp    %cl,%al
  800ade:	74 1c                	je     800afc <memcmp+0x46>
  800ae0:	eb 10                	jmp    800af2 <memcmp+0x3c>
  800ae2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ae7:	83 c2 01             	add    $0x1,%edx
  800aea:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800aee:	38 c8                	cmp    %cl,%al
  800af0:	74 0a                	je     800afc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800af2:	0f b6 c0             	movzbl %al,%eax
  800af5:	0f b6 c9             	movzbl %cl,%ecx
  800af8:	29 c8                	sub    %ecx,%eax
  800afa:	eb 09                	jmp    800b05 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afc:	39 fa                	cmp    %edi,%edx
  800afe:	75 e2                	jne    800ae2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b10:	89 c2                	mov    %eax,%edx
  800b12:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b15:	39 d0                	cmp    %edx,%eax
  800b17:	73 19                	jae    800b32 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b19:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b1d:	38 08                	cmp    %cl,(%eax)
  800b1f:	75 06                	jne    800b27 <memfind+0x1d>
  800b21:	eb 0f                	jmp    800b32 <memfind+0x28>
  800b23:	38 08                	cmp    %cl,(%eax)
  800b25:	74 0b                	je     800b32 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b27:	83 c0 01             	add    $0x1,%eax
  800b2a:	39 d0                	cmp    %edx,%eax
  800b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b30:	75 f1                	jne    800b23 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b40:	0f b6 02             	movzbl (%edx),%eax
  800b43:	3c 20                	cmp    $0x20,%al
  800b45:	74 04                	je     800b4b <strtol+0x17>
  800b47:	3c 09                	cmp    $0x9,%al
  800b49:	75 0e                	jne    800b59 <strtol+0x25>
		s++;
  800b4b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4e:	0f b6 02             	movzbl (%edx),%eax
  800b51:	3c 20                	cmp    $0x20,%al
  800b53:	74 f6                	je     800b4b <strtol+0x17>
  800b55:	3c 09                	cmp    $0x9,%al
  800b57:	74 f2                	je     800b4b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b59:	3c 2b                	cmp    $0x2b,%al
  800b5b:	75 0a                	jne    800b67 <strtol+0x33>
		s++;
  800b5d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b60:	bf 00 00 00 00       	mov    $0x0,%edi
  800b65:	eb 10                	jmp    800b77 <strtol+0x43>
  800b67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b6c:	3c 2d                	cmp    $0x2d,%al
  800b6e:	75 07                	jne    800b77 <strtol+0x43>
		s++, neg = 1;
  800b70:	83 c2 01             	add    $0x1,%edx
  800b73:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b77:	85 db                	test   %ebx,%ebx
  800b79:	0f 94 c0             	sete   %al
  800b7c:	74 05                	je     800b83 <strtol+0x4f>
  800b7e:	83 fb 10             	cmp    $0x10,%ebx
  800b81:	75 15                	jne    800b98 <strtol+0x64>
  800b83:	80 3a 30             	cmpb   $0x30,(%edx)
  800b86:	75 10                	jne    800b98 <strtol+0x64>
  800b88:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b8c:	75 0a                	jne    800b98 <strtol+0x64>
		s += 2, base = 16;
  800b8e:	83 c2 02             	add    $0x2,%edx
  800b91:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b96:	eb 13                	jmp    800bab <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b98:	84 c0                	test   %al,%al
  800b9a:	74 0f                	je     800bab <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b9c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba1:	80 3a 30             	cmpb   $0x30,(%edx)
  800ba4:	75 05                	jne    800bab <strtol+0x77>
		s++, base = 8;
  800ba6:	83 c2 01             	add    $0x1,%edx
  800ba9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb2:	0f b6 0a             	movzbl (%edx),%ecx
  800bb5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bb8:	80 fb 09             	cmp    $0x9,%bl
  800bbb:	77 08                	ja     800bc5 <strtol+0x91>
			dig = *s - '0';
  800bbd:	0f be c9             	movsbl %cl,%ecx
  800bc0:	83 e9 30             	sub    $0x30,%ecx
  800bc3:	eb 1e                	jmp    800be3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800bc5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bc8:	80 fb 19             	cmp    $0x19,%bl
  800bcb:	77 08                	ja     800bd5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800bcd:	0f be c9             	movsbl %cl,%ecx
  800bd0:	83 e9 57             	sub    $0x57,%ecx
  800bd3:	eb 0e                	jmp    800be3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800bd5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bd8:	80 fb 19             	cmp    $0x19,%bl
  800bdb:	77 14                	ja     800bf1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bdd:	0f be c9             	movsbl %cl,%ecx
  800be0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800be3:	39 f1                	cmp    %esi,%ecx
  800be5:	7d 0e                	jge    800bf5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800be7:	83 c2 01             	add    $0x1,%edx
  800bea:	0f af c6             	imul   %esi,%eax
  800bed:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bef:	eb c1                	jmp    800bb2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bf1:	89 c1                	mov    %eax,%ecx
  800bf3:	eb 02                	jmp    800bf7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bf5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bfb:	74 05                	je     800c02 <strtol+0xce>
		*endptr = (char *) s;
  800bfd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c00:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c02:	89 ca                	mov    %ecx,%edx
  800c04:	f7 da                	neg    %edx
  800c06:	85 ff                	test   %edi,%edi
  800c08:	0f 45 c2             	cmovne %edx,%eax
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c19:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c27:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2a:	89 c3                	mov    %eax,%ebx
  800c2c:	89 c7                	mov    %eax,%edi
  800c2e:	89 c6                	mov    %eax,%esi
  800c30:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c32:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c35:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c3b:	89 ec                	mov    %ebp,%esp
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c53:	b8 01 00 00 00       	mov    $0x1,%eax
  800c58:	89 d1                	mov    %edx,%ecx
  800c5a:	89 d3                	mov    %edx,%ebx
  800c5c:	89 d7                	mov    %edx,%edi
  800c5e:	89 d6                	mov    %edx,%esi
  800c60:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c62:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c65:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c68:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c6b:	89 ec                	mov    %ebp,%esp
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	83 ec 38             	sub    $0x38,%esp
  800c75:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c78:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c7b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c83:	b8 03 00 00 00       	mov    $0x3,%eax
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	89 cb                	mov    %ecx,%ebx
  800c8d:	89 cf                	mov    %ecx,%edi
  800c8f:	89 ce                	mov    %ecx,%esi
  800c91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 28                	jle    800cbf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ca2:	00 
  800ca3:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800caa:	00 
  800cab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb2:	00 
  800cb3:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800cba:	e8 fd 06 00 00       	call   8013bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc8:	89 ec                	mov    %ebp,%esp
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800ce0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	89 d3                	mov    %edx,%ebx
  800ce9:	89 d7                	mov    %edx,%edi
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cf8:	89 ec                	mov    %ebp,%esp
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_yield>:

void
sys_yield(void)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d08:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d28:	89 ec                	mov    %ebp,%esp
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 38             	sub    $0x38,%esp
  800d32:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d35:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d38:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	be 00 00 00 00       	mov    $0x0,%esi
  800d40:	b8 04 00 00 00       	mov    $0x4,%eax
  800d45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	89 f7                	mov    %esi,%edi
  800d50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7e 28                	jle    800d7e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d61:	00 
  800d62:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800d69:	00 
  800d6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d71:	00 
  800d72:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800d79:	e8 3e 06 00 00       	call   8013bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d7e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d81:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d84:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d87:	89 ec                	mov    %ebp,%esp
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 38             	sub    $0x38,%esp
  800d91:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d94:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d97:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9f:	8b 75 18             	mov    0x18(%ebp),%esi
  800da2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db0:	85 c0                	test   %eax,%eax
  800db2:	7e 28                	jle    800ddc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dbf:	00 
  800dc0:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800dc7:	00 
  800dc8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcf:	00 
  800dd0:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800dd7:	e8 e0 05 00 00       	call   8013bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ddc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ddf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de5:	89 ec                	mov    %ebp,%esp
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	83 ec 38             	sub    $0x38,%esp
  800def:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfd:	b8 06 00 00 00       	mov    $0x6,%eax
  800e02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
  800e08:	89 df                	mov    %ebx,%edi
  800e0a:	89 de                	mov    %ebx,%esi
  800e0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	7e 28                	jle    800e3a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e16:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e1d:	00 
  800e1e:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800e25:	00 
  800e26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2d:	00 
  800e2e:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800e35:	e8 82 05 00 00       	call   8013bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e3a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e3d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e40:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e43:	89 ec                	mov    %ebp,%esp
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	83 ec 38             	sub    $0x38,%esp
  800e4d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e50:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e53:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	89 df                	mov    %ebx,%edi
  800e68:	89 de                	mov    %ebx,%esi
  800e6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	7e 28                	jle    800e98 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e74:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e7b:	00 
  800e7c:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800e83:	00 
  800e84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8b:	00 
  800e8c:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800e93:	e8 24 05 00 00       	call   8013bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e98:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e9b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e9e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea1:	89 ec                	mov    %ebp,%esp
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 38             	sub    $0x38,%esp
  800eab:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eae:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb9:	b8 09 00 00 00       	mov    $0x9,%eax
  800ebe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec4:	89 df                	mov    %ebx,%edi
  800ec6:	89 de                	mov    %ebx,%esi
  800ec8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	7e 28                	jle    800ef6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ece:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ed9:	00 
  800eda:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee9:	00 
  800eea:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800ef1:	e8 c6 04 00 00       	call   8013bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800efc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eff:	89 ec                	mov    %ebp,%esp
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	83 ec 0c             	sub    $0xc,%esp
  800f09:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f0c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f0f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f12:	be 00 00 00 00       	mov    $0x0,%esi
  800f17:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f2a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f30:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f33:	89 ec                	mov    %ebp,%esp
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 38             	sub    $0x38,%esp
  800f3d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f40:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f43:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f50:	8b 55 08             	mov    0x8(%ebp),%edx
  800f53:	89 cb                	mov    %ecx,%ebx
  800f55:	89 cf                	mov    %ecx,%edi
  800f57:	89 ce                	mov    %ecx,%esi
  800f59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	7e 28                	jle    800f87 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f63:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f6a:	00 
  800f6b:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800f72:	00 
  800f73:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7a:	00 
  800f7b:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800f82:	e8 35 04 00 00       	call   8013bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f87:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f8d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f90:	89 ec                	mov    %ebp,%esp
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    

00800f94 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	53                   	push   %ebx
  800f98:	83 ec 24             	sub    $0x24,%esp
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f9e:	8b 18                	mov    (%eax),%ebx
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

		/// check if access is write and to a copy-on-write page.
    pte_t pte = uvpt[PGNUM(addr)];
  800fa0:	89 da                	mov    %ebx,%edx
  800fa2:	c1 ea 0c             	shr    $0xc,%edx
  800fa5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800fac:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fb0:	74 05                	je     800fb7 <pgfault+0x23>
  800fb2:	f6 c6 08             	test   $0x8,%dh
  800fb5:	75 1c                	jne    800fd3 <pgfault+0x3f>
        panic("pgfault: fault access not to a write or a copy-on-write page");
  800fb7:	c7 44 24 08 10 1a 80 	movl   $0x801a10,0x8(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800fc6:	00 
  800fc7:	c7 04 24 70 1a 80 00 	movl   $0x801a70,(%esp)
  800fce:	e8 e9 03 00 00       	call   8013bc <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
    if (sys_page_alloc(0, PFTEMP, PTE_W | PTE_U | PTE_P)) {
  800fd3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fda:	00 
  800fdb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe2:	00 
  800fe3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fea:	e8 3d fd ff ff       	call   800d2c <sys_page_alloc>
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	74 1c                	je     80100f <pgfault+0x7b>
        panic("pgfault: no phys mem");
  800ff3:	c7 44 24 08 7b 1a 80 	movl   $0x801a7b,0x8(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801002:	00 
  801003:	c7 04 24 70 1a 80 00 	movl   $0x801a70,(%esp)
  80100a:	e8 ad 03 00 00       	call   8013bc <_panic>
    }

    // copy data to the new page from the source page.
    void *fltpg_addr = (void *)ROUNDDOWN(addr, PGSIZE);
  80100f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, fltpg_addr, PGSIZE);
  801015:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80101c:	00 
  80101d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801021:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801028:	e8 ef f9 ff ff       	call   800a1c <memmove>

    // change mapping for the faulting page.
    if (sys_page_map(0, PFTEMP, 0, fltpg_addr, PTE_W|PTE_U|PTE_P)) {
  80102d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801034:	00 
  801035:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801039:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801040:	00 
  801041:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801048:	00 
  801049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801050:	e8 36 fd ff ff       	call   800d8b <sys_page_map>
  801055:	85 c0                	test   %eax,%eax
  801057:	74 1c                	je     801075 <pgfault+0xe1>
        panic("pgfault: map error");
  801059:	c7 44 24 08 90 1a 80 	movl   $0x801a90,0x8(%esp)
  801060:	00 
  801061:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801068:	00 
  801069:	c7 04 24 70 1a 80 00 	movl   $0x801a70,(%esp)
  801070:	e8 47 03 00 00       	call   8013bc <_panic>
    }
	// panic("pgfault not implemented");
}
  801075:	83 c4 24             	add    $0x24,%esp
  801078:	5b                   	pop    %ebx
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	// Step 1: install user mode pgfault handler.
    set_pgfault_handler(pgfault);
  801084:	c7 04 24 94 0f 80 00 	movl   $0x800f94,(%esp)
  80108b:	e8 84 03 00 00       	call   801414 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801090:	ba 07 00 00 00       	mov    $0x7,%edx
  801095:	89 d0                	mov    %edx,%eax
  801097:	cd 30                	int    $0x30
  801099:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80109c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // Step 2: create child environment.
    envid_t envid = sys_exofork();
    if (envid < 0) {
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	79 1c                	jns    8010bf <fork+0x44>
        panic("fork: cannot create child env");
  8010a3:	c7 44 24 08 a3 1a 80 	movl   $0x801aa3,0x8(%esp)
  8010aa:	00 
  8010ab:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  8010b2:	00 
  8010b3:	c7 04 24 70 1a 80 00 	movl   $0x801a70,(%esp)
  8010ba:	e8 fd 02 00 00       	call   8013bc <_panic>
    }
    else if (envid == 0) {
  8010bf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8010c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010ca:	75 1c                	jne    8010e8 <fork+0x6d>
        // child environment.
        thisenv = &envs[ENVX(sys_getenvid())];
  8010cc:	e8 fb fb ff ff       	call   800ccc <sys_getenvid>
  8010d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010de:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  8010e3:	e9 8d 01 00 00       	jmp    801275 <fork+0x1fa>

    // Step 3: duplicate pages.
    int ipd;
    for (ipd = 0; ipd < PDX(UTOP); ipd++) {
        // No page table yet.
        if (!(uvpd[ipd] & PTE_P))
  8010e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010eb:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  8010f2:	a8 01                	test   $0x1,%al
  8010f4:	0f 84 c5 00 00 00    	je     8011bf <fork+0x144>
            continue;

        int ipt;
        for (ipt = 0; ipt < NPTENTRIES; ipt++) {
            unsigned pn = (ipd << 10) | ipt;
  8010fa:	89 d7                	mov    %edx,%edi
  8010fc:	c1 e7 0a             	shl    $0xa,%edi
  8010ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801104:	89 de                	mov    %ebx,%esi
  801106:	09 fe                	or     %edi,%esi
            if (pn != PGNUM(UXSTACKTOP - PGSIZE)) {
  801108:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  80110e:	0f 84 9c 00 00 00    	je     8011b0 <fork+0x135>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	pte_t pte = uvpt[pn];
  801114:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
    void *va = (void *)(pn << PGSHIFT);

    // If the page is writable or copy-on-write,
    // the mapping must be copy-on-write ,
    // otherwise the new environment could change this page.
    if ((pte & PTE_W) || (pte & PTE_COW)) {
  80111b:	a9 02 08 00 00       	test   $0x802,%eax
  801120:	0f 84 8a 00 00 00    	je     8011b0 <fork+0x135>
{
	int r;

	// LAB 4: Your code here.
	pte_t pte = uvpt[pn];
    void *va = (void *)(pn << PGSHIFT);
  801126:	c1 e6 0c             	shl    $0xc,%esi

    // If the page is writable or copy-on-write,
    // the mapping must be copy-on-write ,
    // otherwise the new environment could change this page.
    if ((pte & PTE_W) || (pte & PTE_COW)) {
        if (sys_page_map(0, va, envid, va, PTE_COW|PTE_U|PTE_P)) {
  801129:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801130:	00 
  801131:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801135:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801138:	89 44 24 08          	mov    %eax,0x8(%esp)
  80113c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801147:	e8 3f fc ff ff       	call   800d8b <sys_page_map>
  80114c:	85 c0                	test   %eax,%eax
  80114e:	74 1c                	je     80116c <fork+0xf1>
            panic("duppage: map cow error");
  801150:	c7 44 24 08 c1 1a 80 	movl   $0x801ac1,0x8(%esp)
  801157:	00 
  801158:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80115f:	00 
  801160:	c7 04 24 70 1a 80 00 	movl   $0x801a70,(%esp)
  801167:	e8 50 02 00 00       	call   8013bc <_panic>
        }

        // Change permission of the page in this environment to copy-on-write.
        // Otherwise the new environment would see the change in this environment.
        if (sys_page_map(0, va, 0, va, PTE_COW|PTE_U| PTE_P)) {
  80116c:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801173:	00 
  801174:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801178:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80117f:	00 
  801180:	89 74 24 04          	mov    %esi,0x4(%esp)
  801184:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80118b:	e8 fb fb ff ff       	call   800d8b <sys_page_map>
  801190:	85 c0                	test   %eax,%eax
  801192:	74 1c                	je     8011b0 <fork+0x135>
            panic("duppage: change perm error");
  801194:	c7 44 24 08 d8 1a 80 	movl   $0x801ad8,0x8(%esp)
  80119b:	00 
  80119c:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8011a3:	00 
  8011a4:	c7 04 24 70 1a 80 00 	movl   $0x801a70,(%esp)
  8011ab:	e8 0c 02 00 00       	call   8013bc <_panic>
        // No page table yet.
        if (!(uvpd[ipd] & PTE_P))
            continue;

        int ipt;
        for (ipt = 0; ipt < NPTENTRIES; ipt++) {
  8011b0:	83 c3 01             	add    $0x1,%ebx
  8011b3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8011b9:	0f 85 45 ff ff ff    	jne    801104 <fork+0x89>
        return 0;
    }

    // Step 3: duplicate pages.
    int ipd;
    for (ipd = 0; ipd < PDX(UTOP); ipd++) {
  8011bf:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  8011c3:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
  8011ca:	0f 85 18 ff ff ff    	jne    8010e8 <fork+0x6d>
            }
        }
    }

    // allocate a new page for child to hold the exception stack.
    if (sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) {
  8011d0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011d7:	00 
  8011d8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011df:	ee 
  8011e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011e3:	89 04 24             	mov    %eax,(%esp)
  8011e6:	e8 41 fb ff ff       	call   800d2c <sys_page_alloc>
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	74 1c                	je     80120b <fork+0x190>
        panic("fork: no phys mem for xstk");
  8011ef:	c7 44 24 08 f3 1a 80 	movl   $0x801af3,0x8(%esp)
  8011f6:	00 
  8011f7:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8011fe:	00 
  8011ff:	c7 04 24 70 1a 80 00 	movl   $0x801a70,(%esp)
  801206:	e8 b1 01 00 00       	call   8013bc <_panic>
    }

    // Step 4: set user page fault entry for child.
    if (sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) {
  80120b:	a1 04 20 80 00       	mov    0x802004,%eax
  801210:	8b 40 64             	mov    0x64(%eax),%eax
  801213:	89 44 24 04          	mov    %eax,0x4(%esp)
  801217:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80121a:	89 04 24             	mov    %eax,(%esp)
  80121d:	e8 83 fc ff ff       	call   800ea5 <sys_env_set_pgfault_upcall>
  801222:	85 c0                	test   %eax,%eax
  801224:	74 1c                	je     801242 <fork+0x1c7>
        panic("fork: cannot set pgfault upcall");
  801226:	c7 44 24 08 50 1a 80 	movl   $0x801a50,0x8(%esp)
  80122d:	00 
  80122e:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  801235:	00 
  801236:	c7 04 24 70 1a 80 00 	movl   $0x801a70,(%esp)
  80123d:	e8 7a 01 00 00       	call   8013bc <_panic>
    }

    // Step 5: set child status to ENV_RUNNABLE.
    if (sys_env_set_status(envid, ENV_RUNNABLE)) {
  801242:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801249:	00 
  80124a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80124d:	89 04 24             	mov    %eax,(%esp)
  801250:	e8 f2 fb ff ff       	call   800e47 <sys_env_set_status>
  801255:	85 c0                	test   %eax,%eax
  801257:	74 1c                	je     801275 <fork+0x1fa>
        panic("fork: cannot set env status");
  801259:	c7 44 24 08 0e 1b 80 	movl   $0x801b0e,0x8(%esp)
  801260:	00 
  801261:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801268:	00 
  801269:	c7 04 24 70 1a 80 00 	movl   $0x801a70,(%esp)
  801270:	e8 47 01 00 00       	call   8013bc <_panic>
    }

    return envid;

}
  801275:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801278:	83 c4 3c             	add    $0x3c,%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <sfork>:

// Challenge!
int
sfork(void)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801286:	c7 44 24 08 2a 1b 80 	movl   $0x801b2a,0x8(%esp)
  80128d:	00 
  80128e:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  801295:	00 
  801296:	c7 04 24 70 1a 80 00 	movl   $0x801a70,(%esp)
  80129d:	e8 1a 01 00 00       	call   8013bc <_panic>
	...

008012a4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	56                   	push   %esi
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 10             	sub    $0x10,%esp
  8012ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
    
    if (!pg)
  8012b5:	85 c0                	test   %eax,%eax
        pg = (void *)UTOP;
  8012b7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8012bc:	0f 44 c2             	cmove  %edx,%eax

    int result;
    if ((result = sys_ipc_recv(pg))) {
  8012bf:	89 04 24             	mov    %eax,(%esp)
  8012c2:	e8 70 fc ff ff       	call   800f37 <sys_ipc_recv>
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	74 16                	je     8012e1 <ipc_recv+0x3d>
        if (from_env_store)
  8012cb:	85 db                	test   %ebx,%ebx
  8012cd:	74 06                	je     8012d5 <ipc_recv+0x31>
            *from_env_store = 0;
  8012cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        if (perm_store)
  8012d5:	85 f6                	test   %esi,%esi
  8012d7:	74 2c                	je     801305 <ipc_recv+0x61>
            *perm_store = 0;
  8012d9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8012df:	eb 24                	jmp    801305 <ipc_recv+0x61>
            
        return result;
    }

    if (from_env_store)
  8012e1:	85 db                	test   %ebx,%ebx
  8012e3:	74 0a                	je     8012ef <ipc_recv+0x4b>
        *from_env_store = thisenv->env_ipc_from;
  8012e5:	a1 04 20 80 00       	mov    0x802004,%eax
  8012ea:	8b 40 74             	mov    0x74(%eax),%eax
  8012ed:	89 03                	mov    %eax,(%ebx)

    if (perm_store)
  8012ef:	85 f6                	test   %esi,%esi
  8012f1:	74 0a                	je     8012fd <ipc_recv+0x59>
        *perm_store = thisenv->env_ipc_perm;
  8012f3:	a1 04 20 80 00       	mov    0x802004,%eax
  8012f8:	8b 40 78             	mov    0x78(%eax),%eax
  8012fb:	89 06                	mov    %eax,(%esi)

	return thisenv->env_ipc_value;
  8012fd:	a1 04 20 80 00       	mov    0x802004,%eax
  801302:	8b 40 70             	mov    0x70(%eax),%eax
}
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	5b                   	pop    %ebx
  801309:	5e                   	pop    %esi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	57                   	push   %edi
  801310:	56                   	push   %esi
  801311:	53                   	push   %ebx
  801312:	83 ec 1c             	sub    $0x1c,%esp
  801315:	8b 75 08             	mov    0x8(%ebp),%esi
  801318:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80131b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

    if (!pg)
  80131e:	85 db                	test   %ebx,%ebx
        pg = (void *)UTOP;
  801320:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801325:	0f 44 d8             	cmove  %eax,%ebx
  801328:	eb 05                	jmp    80132f <ipc_send+0x23>

    int result;
    while (-E_IPC_NOT_RECV == (result = sys_ipc_try_send(to_env, val, pg, perm)))
        sys_yield();
  80132a:	e8 cd f9 ff ff       	call   800cfc <sys_yield>

    if (!pg)
        pg = (void *)UTOP;

    int result;
    while (-E_IPC_NOT_RECV == (result = sys_ipc_try_send(to_env, val, pg, perm)))
  80132f:	8b 45 14             	mov    0x14(%ebp),%eax
  801332:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801336:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80133a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80133e:	89 34 24             	mov    %esi,(%esp)
  801341:	e8 bd fb ff ff       	call   800f03 <sys_ipc_try_send>
  801346:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801349:	74 df                	je     80132a <ipc_send+0x1e>
        sys_yield();

    if (result)
  80134b:	85 c0                	test   %eax,%eax
  80134d:	74 1c                	je     80136b <ipc_send+0x5f>
        panic("ipc_send: error");
  80134f:	c7 44 24 08 40 1b 80 	movl   $0x801b40,0x8(%esp)
  801356:	00 
  801357:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80135e:	00 
  80135f:	c7 04 24 50 1b 80 00 	movl   $0x801b50,(%esp)
  801366:	e8 51 00 00 00       	call   8013bc <_panic>
}
  80136b:	83 c4 1c             	add    $0x1c,%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801379:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80137e:	39 c8                	cmp    %ecx,%eax
  801380:	74 17                	je     801399 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801382:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801387:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80138a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801390:	8b 52 50             	mov    0x50(%edx),%edx
  801393:	39 ca                	cmp    %ecx,%edx
  801395:	75 14                	jne    8013ab <ipc_find_env+0x38>
  801397:	eb 05                	jmp    80139e <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801399:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80139e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013a1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013a6:	8b 40 40             	mov    0x40(%eax),%eax
  8013a9:	eb 0e                	jmp    8013b9 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013ab:	83 c0 01             	add    $0x1,%eax
  8013ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013b3:	75 d2                	jne    801387 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013b5:	66 b8 00 00          	mov    $0x0,%ax
}
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    
	...

008013bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8013c4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013c7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8013cd:	e8 fa f8 ff ff       	call   800ccc <sys_getenvid>
  8013d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e8:	c7 04 24 5c 1b 80 00 	movl   $0x801b5c,(%esp)
  8013ef:	e8 17 ee ff ff       	call   80020b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8013fb:	89 04 24             	mov    %eax,(%esp)
  8013fe:	e8 a7 ed ff ff       	call   8001aa <vcprintf>
	cprintf("\n");
  801403:	c7 04 24 87 17 80 00 	movl   $0x801787,(%esp)
  80140a:	e8 fc ed ff ff       	call   80020b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80140f:	cc                   	int3   
  801410:	eb fd                	jmp    80140f <_panic+0x53>
	...

00801414 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80141a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801421:	75 50                	jne    801473 <set_pgfault_handler+0x5f>
		// First time through!
		// LAB 4: Your code here.
		int error = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P);
  801423:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80142a:	00 
  80142b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801432:	ee 
  801433:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80143a:	e8 ed f8 ff ff       	call   800d2c <sys_page_alloc>
        if (error) {
  80143f:	85 c0                	test   %eax,%eax
  801441:	74 1c                	je     80145f <set_pgfault_handler+0x4b>
            panic("No physical memory available!");
  801443:	c7 44 24 08 80 1b 80 	movl   $0x801b80,0x8(%esp)
  80144a:	00 
  80144b:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801452:	00 
  801453:	c7 04 24 9e 1b 80 00 	movl   $0x801b9e,(%esp)
  80145a:	e8 5d ff ff ff       	call   8013bc <_panic>
        }

		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80145f:	c7 44 24 04 80 14 80 	movl   $0x801480,0x4(%esp)
  801466:	00 
  801467:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80146e:	e8 32 fa ff ff       	call   800ea5 <sys_env_set_pgfault_upcall>
		
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801473:	8b 45 08             	mov    0x8(%ebp),%eax
  801476:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    
  80147d:	00 00                	add    %al,(%eax)
	...

00801480 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801480:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801481:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801486:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801488:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	

	movl %esp, %eax 		// temporarily save exception stack esp
  80148b:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 	// return addr (eip) -> ebx 
  80148d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 	// now trap-time stack
  801491:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 				// push eip onto trap-time stack 
  801495:	53                   	push   %ebx
	movl %esp, 48(%eax) 	// Updating the trap-time stack esp, since a new val has been pushed
  801496:	89 60 30             	mov    %esp,0x30(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	movl %eax, %esp 	/* now exception stack */
  801499:	89 c4                	mov    %eax,%esp
	addl $4, %esp 		/* skip utf_fault_va */
  80149b:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 		/* skip utf_err */
  80149e:	83 c4 04             	add    $0x4,%esp
	popal 				/* restore from utf_regs  */
  8014a1:	61                   	popa   
	addl $4, %esp 		/* skip utf_eip (already on trap-time stack) */
  8014a2:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	popfl /* restore from utf_eflags */
  8014a5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp /* restore from utf_esp - top of stack (bottom-most val) will be the eip to go to */
  8014a6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	
	ret
  8014a7:	c3                   	ret    
	...

008014b0 <__udivdi3>:
  8014b0:	83 ec 1c             	sub    $0x1c,%esp
  8014b3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8014b7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8014bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8014bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8014c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8014c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8014cb:	85 ff                	test   %edi,%edi
  8014cd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8014d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014d5:	89 cd                	mov    %ecx,%ebp
  8014d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014db:	75 33                	jne    801510 <__udivdi3+0x60>
  8014dd:	39 f1                	cmp    %esi,%ecx
  8014df:	77 57                	ja     801538 <__udivdi3+0x88>
  8014e1:	85 c9                	test   %ecx,%ecx
  8014e3:	75 0b                	jne    8014f0 <__udivdi3+0x40>
  8014e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ea:	31 d2                	xor    %edx,%edx
  8014ec:	f7 f1                	div    %ecx
  8014ee:	89 c1                	mov    %eax,%ecx
  8014f0:	89 f0                	mov    %esi,%eax
  8014f2:	31 d2                	xor    %edx,%edx
  8014f4:	f7 f1                	div    %ecx
  8014f6:	89 c6                	mov    %eax,%esi
  8014f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014fc:	f7 f1                	div    %ecx
  8014fe:	89 f2                	mov    %esi,%edx
  801500:	8b 74 24 10          	mov    0x10(%esp),%esi
  801504:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801508:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80150c:	83 c4 1c             	add    $0x1c,%esp
  80150f:	c3                   	ret    
  801510:	31 d2                	xor    %edx,%edx
  801512:	31 c0                	xor    %eax,%eax
  801514:	39 f7                	cmp    %esi,%edi
  801516:	77 e8                	ja     801500 <__udivdi3+0x50>
  801518:	0f bd cf             	bsr    %edi,%ecx
  80151b:	83 f1 1f             	xor    $0x1f,%ecx
  80151e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801522:	75 2c                	jne    801550 <__udivdi3+0xa0>
  801524:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801528:	76 04                	jbe    80152e <__udivdi3+0x7e>
  80152a:	39 f7                	cmp    %esi,%edi
  80152c:	73 d2                	jae    801500 <__udivdi3+0x50>
  80152e:	31 d2                	xor    %edx,%edx
  801530:	b8 01 00 00 00       	mov    $0x1,%eax
  801535:	eb c9                	jmp    801500 <__udivdi3+0x50>
  801537:	90                   	nop
  801538:	89 f2                	mov    %esi,%edx
  80153a:	f7 f1                	div    %ecx
  80153c:	31 d2                	xor    %edx,%edx
  80153e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801542:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801546:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80154a:	83 c4 1c             	add    $0x1c,%esp
  80154d:	c3                   	ret    
  80154e:	66 90                	xchg   %ax,%ax
  801550:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801555:	b8 20 00 00 00       	mov    $0x20,%eax
  80155a:	89 ea                	mov    %ebp,%edx
  80155c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801560:	d3 e7                	shl    %cl,%edi
  801562:	89 c1                	mov    %eax,%ecx
  801564:	d3 ea                	shr    %cl,%edx
  801566:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80156b:	09 fa                	or     %edi,%edx
  80156d:	89 f7                	mov    %esi,%edi
  80156f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801573:	89 f2                	mov    %esi,%edx
  801575:	8b 74 24 08          	mov    0x8(%esp),%esi
  801579:	d3 e5                	shl    %cl,%ebp
  80157b:	89 c1                	mov    %eax,%ecx
  80157d:	d3 ef                	shr    %cl,%edi
  80157f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801584:	d3 e2                	shl    %cl,%edx
  801586:	89 c1                	mov    %eax,%ecx
  801588:	d3 ee                	shr    %cl,%esi
  80158a:	09 d6                	or     %edx,%esi
  80158c:	89 fa                	mov    %edi,%edx
  80158e:	89 f0                	mov    %esi,%eax
  801590:	f7 74 24 0c          	divl   0xc(%esp)
  801594:	89 d7                	mov    %edx,%edi
  801596:	89 c6                	mov    %eax,%esi
  801598:	f7 e5                	mul    %ebp
  80159a:	39 d7                	cmp    %edx,%edi
  80159c:	72 22                	jb     8015c0 <__udivdi3+0x110>
  80159e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8015a2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015a7:	d3 e5                	shl    %cl,%ebp
  8015a9:	39 c5                	cmp    %eax,%ebp
  8015ab:	73 04                	jae    8015b1 <__udivdi3+0x101>
  8015ad:	39 d7                	cmp    %edx,%edi
  8015af:	74 0f                	je     8015c0 <__udivdi3+0x110>
  8015b1:	89 f0                	mov    %esi,%eax
  8015b3:	31 d2                	xor    %edx,%edx
  8015b5:	e9 46 ff ff ff       	jmp    801500 <__udivdi3+0x50>
  8015ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8015c0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015c3:	31 d2                	xor    %edx,%edx
  8015c5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8015c9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8015cd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8015d1:	83 c4 1c             	add    $0x1c,%esp
  8015d4:	c3                   	ret    
	...

008015e0 <__umoddi3>:
  8015e0:	83 ec 1c             	sub    $0x1c,%esp
  8015e3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8015e7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8015eb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8015ef:	89 74 24 10          	mov    %esi,0x10(%esp)
  8015f3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8015f7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8015fb:	85 ed                	test   %ebp,%ebp
  8015fd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801601:	89 44 24 08          	mov    %eax,0x8(%esp)
  801605:	89 cf                	mov    %ecx,%edi
  801607:	89 04 24             	mov    %eax,(%esp)
  80160a:	89 f2                	mov    %esi,%edx
  80160c:	75 1a                	jne    801628 <__umoddi3+0x48>
  80160e:	39 f1                	cmp    %esi,%ecx
  801610:	76 4e                	jbe    801660 <__umoddi3+0x80>
  801612:	f7 f1                	div    %ecx
  801614:	89 d0                	mov    %edx,%eax
  801616:	31 d2                	xor    %edx,%edx
  801618:	8b 74 24 10          	mov    0x10(%esp),%esi
  80161c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801620:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801624:	83 c4 1c             	add    $0x1c,%esp
  801627:	c3                   	ret    
  801628:	39 f5                	cmp    %esi,%ebp
  80162a:	77 54                	ja     801680 <__umoddi3+0xa0>
  80162c:	0f bd c5             	bsr    %ebp,%eax
  80162f:	83 f0 1f             	xor    $0x1f,%eax
  801632:	89 44 24 04          	mov    %eax,0x4(%esp)
  801636:	75 60                	jne    801698 <__umoddi3+0xb8>
  801638:	3b 0c 24             	cmp    (%esp),%ecx
  80163b:	0f 87 07 01 00 00    	ja     801748 <__umoddi3+0x168>
  801641:	89 f2                	mov    %esi,%edx
  801643:	8b 34 24             	mov    (%esp),%esi
  801646:	29 ce                	sub    %ecx,%esi
  801648:	19 ea                	sbb    %ebp,%edx
  80164a:	89 34 24             	mov    %esi,(%esp)
  80164d:	8b 04 24             	mov    (%esp),%eax
  801650:	8b 74 24 10          	mov    0x10(%esp),%esi
  801654:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801658:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80165c:	83 c4 1c             	add    $0x1c,%esp
  80165f:	c3                   	ret    
  801660:	85 c9                	test   %ecx,%ecx
  801662:	75 0b                	jne    80166f <__umoddi3+0x8f>
  801664:	b8 01 00 00 00       	mov    $0x1,%eax
  801669:	31 d2                	xor    %edx,%edx
  80166b:	f7 f1                	div    %ecx
  80166d:	89 c1                	mov    %eax,%ecx
  80166f:	89 f0                	mov    %esi,%eax
  801671:	31 d2                	xor    %edx,%edx
  801673:	f7 f1                	div    %ecx
  801675:	8b 04 24             	mov    (%esp),%eax
  801678:	f7 f1                	div    %ecx
  80167a:	eb 98                	jmp    801614 <__umoddi3+0x34>
  80167c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801680:	89 f2                	mov    %esi,%edx
  801682:	8b 74 24 10          	mov    0x10(%esp),%esi
  801686:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80168a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80168e:	83 c4 1c             	add    $0x1c,%esp
  801691:	c3                   	ret    
  801692:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801698:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80169d:	89 e8                	mov    %ebp,%eax
  80169f:	bd 20 00 00 00       	mov    $0x20,%ebp
  8016a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8016a8:	89 fa                	mov    %edi,%edx
  8016aa:	d3 e0                	shl    %cl,%eax
  8016ac:	89 e9                	mov    %ebp,%ecx
  8016ae:	d3 ea                	shr    %cl,%edx
  8016b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8016b5:	09 c2                	or     %eax,%edx
  8016b7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8016bb:	89 14 24             	mov    %edx,(%esp)
  8016be:	89 f2                	mov    %esi,%edx
  8016c0:	d3 e7                	shl    %cl,%edi
  8016c2:	89 e9                	mov    %ebp,%ecx
  8016c4:	d3 ea                	shr    %cl,%edx
  8016c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8016cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016cf:	d3 e6                	shl    %cl,%esi
  8016d1:	89 e9                	mov    %ebp,%ecx
  8016d3:	d3 e8                	shr    %cl,%eax
  8016d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8016da:	09 f0                	or     %esi,%eax
  8016dc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8016e0:	f7 34 24             	divl   (%esp)
  8016e3:	d3 e6                	shl    %cl,%esi
  8016e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8016e9:	89 d6                	mov    %edx,%esi
  8016eb:	f7 e7                	mul    %edi
  8016ed:	39 d6                	cmp    %edx,%esi
  8016ef:	89 c1                	mov    %eax,%ecx
  8016f1:	89 d7                	mov    %edx,%edi
  8016f3:	72 3f                	jb     801734 <__umoddi3+0x154>
  8016f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8016f9:	72 35                	jb     801730 <__umoddi3+0x150>
  8016fb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8016ff:	29 c8                	sub    %ecx,%eax
  801701:	19 fe                	sbb    %edi,%esi
  801703:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801708:	89 f2                	mov    %esi,%edx
  80170a:	d3 e8                	shr    %cl,%eax
  80170c:	89 e9                	mov    %ebp,%ecx
  80170e:	d3 e2                	shl    %cl,%edx
  801710:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801715:	09 d0                	or     %edx,%eax
  801717:	89 f2                	mov    %esi,%edx
  801719:	d3 ea                	shr    %cl,%edx
  80171b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80171f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801723:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801727:	83 c4 1c             	add    $0x1c,%esp
  80172a:	c3                   	ret    
  80172b:	90                   	nop
  80172c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801730:	39 d6                	cmp    %edx,%esi
  801732:	75 c7                	jne    8016fb <__umoddi3+0x11b>
  801734:	89 d7                	mov    %edx,%edi
  801736:	89 c1                	mov    %eax,%ecx
  801738:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80173c:	1b 3c 24             	sbb    (%esp),%edi
  80173f:	eb ba                	jmp    8016fb <__umoddi3+0x11b>
  801741:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801748:	39 f5                	cmp    %esi,%ebp
  80174a:	0f 82 f1 fe ff ff    	jb     801641 <__umoddi3+0x61>
  801750:	e9 f8 fe ff ff       	jmp    80164d <__umoddi3+0x6d>
