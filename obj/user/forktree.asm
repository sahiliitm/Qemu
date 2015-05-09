
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 89 0c 00 00       	call   800ccc <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 40 16 80 00 	movl   $0x801640,(%esp)
  800052:	e8 b8 01 00 00       	call   80020f <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 38             	sub    $0x38,%esp
  800083:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800086:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800089:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80008c:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800090:	89 1c 24             	mov    %ebx,(%esp)
  800093:	e8 48 07 00 00       	call   8007e0 <strlen>
  800098:	83 f8 02             	cmp    $0x2,%eax
  80009b:	7f 41                	jg     8000de <forkchild+0x61>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000aa:	c7 44 24 08 51 16 80 	movl   $0x801651,0x8(%esp)
  8000b1:	00 
  8000b2:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b9:	00 
  8000ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000bd:	89 04 24             	mov    %eax,(%esp)
  8000c0:	e8 ef 06 00 00       	call   8007b4 <snprintf>
	if (fork() == 0) {
  8000c5:	e8 b1 0f 00 00       	call   80107b <fork>
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	75 10                	jne    8000de <forkchild+0x61>
		forktree(nxt);
  8000ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000d1:	89 04 24             	mov    %eax,(%esp)
  8000d4:	e8 5b ff ff ff       	call   800034 <forktree>
		exit();
  8000d9:	e8 7a 00 00 00       	call   800158 <exit>
	}
}
  8000de:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e1:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000e4:	89 ec                	mov    %ebp,%esp
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000ee:	c7 04 24 50 16 80 00 	movl   $0x801650,(%esp)
  8000f5:	e8 3a ff ff ff       	call   800034 <forktree>
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
  800102:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800105:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800108:	8b 75 08             	mov    0x8(%ebp),%esi
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80010e:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800115:	00 00 00 
	envid_t envid = sys_getenvid();
  800118:	e8 af 0b 00 00       	call   800ccc <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 f6                	test   %esi,%esi
  800131:	7e 07                	jle    80013a <libmain+0x3e>
		binaryname = argv[0];
  800133:	8b 03                	mov    (%ebx),%eax
  800135:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80013a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013e:	89 34 24             	mov    %esi,(%esp)
  800141:	e8 a2 ff ff ff       	call   8000e8 <umain>

	// exit gracefully
	exit();
  800146:	e8 0d 00 00 00       	call   800158 <exit>
}
  80014b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80014e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800151:	89 ec                	mov    %ebp,%esp
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    
  800155:	00 00                	add    %al,(%eax)
	...

00800158 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800165:	e8 05 0b 00 00       	call   800c6f <sys_env_destroy>
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	53                   	push   %ebx
  800170:	83 ec 14             	sub    $0x14,%esp
  800173:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800176:	8b 03                	mov    (%ebx),%eax
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017f:	83 c0 01             	add    $0x1,%eax
  800182:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800184:	3d ff 00 00 00       	cmp    $0xff,%eax
  800189:	75 19                	jne    8001a4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80018b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800192:	00 
  800193:	8d 43 08             	lea    0x8(%ebx),%eax
  800196:	89 04 24             	mov    %eax,(%esp)
  800199:	e8 72 0a 00 00       	call   800c10 <sys_cputs>
		b->idx = 0;
  80019e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001a4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a8:	83 c4 14             	add    $0x14,%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5d                   	pop    %ebp
  8001ad:	c3                   	ret    

008001ae <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
  8001b1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001be:	00 00 00 
	b.cnt = 0;
  8001c1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e3:	c7 04 24 6c 01 80 00 	movl   $0x80016c,(%esp)
  8001ea:	e8 d5 01 00 00       	call   8003c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ef:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	e8 09 0a 00 00       	call   800c10 <sys_cputs>

	return b.cnt;
}
  800207:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800215:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800218:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021c:	8b 45 08             	mov    0x8(%ebp),%eax
  80021f:	89 04 24             	mov    %eax,(%esp)
  800222:	e8 87 ff ff ff       	call   8001ae <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    
  800229:	00 00                	add    %al,(%eax)
  80022b:	00 00                	add    %al,(%eax)
  80022d:	00 00                	add    %al,(%eax)
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
  80029a:	e8 f1 10 00 00       	call   801390 <__udivdi3>
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
  8002ed:	e8 ce 11 00 00       	call   8014c0 <__umoddi3>
  8002f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f6:	0f be 80 60 16 80 00 	movsbl 0x801660(%eax),%eax
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
  800458:	ff 24 85 20 17 80 00 	jmp    *0x801720(,%eax,4)
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
  80050e:	8b 14 85 80 18 80 00 	mov    0x801880(,%eax,4),%edx
  800515:	85 d2                	test   %edx,%edx
  800517:	75 23                	jne    80053c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800519:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051d:	c7 44 24 08 78 16 80 	movl   $0x801678,0x8(%esp)
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
  800540:	c7 44 24 08 81 16 80 	movl   $0x801681,0x8(%esp)
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
  800575:	ba 71 16 80 00       	mov    $0x801671,%edx
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
  800ca3:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800caa:	00 
  800cab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb2:	00 
  800cb3:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800cba:	e8 e5 05 00 00       	call   8012a4 <_panic>

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
  800d62:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800d69:	00 
  800d6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d71:	00 
  800d72:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800d79:	e8 26 05 00 00       	call   8012a4 <_panic>

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
  800dc0:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800dc7:	00 
  800dc8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcf:	00 
  800dd0:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800dd7:	e8 c8 04 00 00       	call   8012a4 <_panic>

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
  800e1e:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800e25:	00 
  800e26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2d:	00 
  800e2e:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800e35:	e8 6a 04 00 00       	call   8012a4 <_panic>

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
  800e7c:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800e83:	00 
  800e84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8b:	00 
  800e8c:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800e93:	e8 0c 04 00 00       	call   8012a4 <_panic>

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
  800eda:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee9:	00 
  800eea:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800ef1:	e8 ae 03 00 00       	call   8012a4 <_panic>

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
  800f6b:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800f72:	00 
  800f73:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7a:	00 
  800f7b:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800f82:	e8 1d 03 00 00       	call   8012a4 <_panic>

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
  800fb7:	c7 44 24 08 d0 18 80 	movl   $0x8018d0,0x8(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800fc6:	00 
  800fc7:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  800fce:	e8 d1 02 00 00       	call   8012a4 <_panic>
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
  800ff3:	c7 44 24 08 3b 19 80 	movl   $0x80193b,0x8(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801002:	00 
  801003:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  80100a:	e8 95 02 00 00       	call   8012a4 <_panic>
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
  801059:	c7 44 24 08 50 19 80 	movl   $0x801950,0x8(%esp)
  801060:	00 
  801061:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801068:	00 
  801069:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  801070:	e8 2f 02 00 00       	call   8012a4 <_panic>
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
  80108b:	e8 6c 02 00 00       	call   8012fc <set_pgfault_handler>
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
  8010a3:	c7 44 24 08 63 19 80 	movl   $0x801963,0x8(%esp)
  8010aa:	00 
  8010ab:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  8010b2:	00 
  8010b3:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  8010ba:	e8 e5 01 00 00       	call   8012a4 <_panic>
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
  801150:	c7 44 24 08 81 19 80 	movl   $0x801981,0x8(%esp)
  801157:	00 
  801158:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80115f:	00 
  801160:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  801167:	e8 38 01 00 00       	call   8012a4 <_panic>
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
  801194:	c7 44 24 08 98 19 80 	movl   $0x801998,0x8(%esp)
  80119b:	00 
  80119c:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8011a3:	00 
  8011a4:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  8011ab:	e8 f4 00 00 00       	call   8012a4 <_panic>
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
  8011ef:	c7 44 24 08 b3 19 80 	movl   $0x8019b3,0x8(%esp)
  8011f6:	00 
  8011f7:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8011fe:	00 
  8011ff:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  801206:	e8 99 00 00 00       	call   8012a4 <_panic>
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
  801226:	c7 44 24 08 10 19 80 	movl   $0x801910,0x8(%esp)
  80122d:	00 
  80122e:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  801235:	00 
  801236:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  80123d:	e8 62 00 00 00       	call   8012a4 <_panic>
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
  801259:	c7 44 24 08 ce 19 80 	movl   $0x8019ce,0x8(%esp)
  801260:	00 
  801261:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801268:	00 
  801269:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  801270:	e8 2f 00 00 00       	call   8012a4 <_panic>
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
  801286:	c7 44 24 08 ea 19 80 	movl   $0x8019ea,0x8(%esp)
  80128d:	00 
  80128e:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  801295:	00 
  801296:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  80129d:	e8 02 00 00 00       	call   8012a4 <_panic>
	...

008012a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	56                   	push   %esi
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012ac:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012af:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8012b5:	e8 12 fa ff ff       	call   800ccc <sys_getenvid>
  8012ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d0:	c7 04 24 00 1a 80 00 	movl   $0x801a00,(%esp)
  8012d7:	e8 33 ef ff ff       	call   80020f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012e3:	89 04 24             	mov    %eax,(%esp)
  8012e6:	e8 c3 ee ff ff       	call   8001ae <vcprintf>
	cprintf("\n");
  8012eb:	c7 04 24 4f 16 80 00 	movl   $0x80164f,(%esp)
  8012f2:	e8 18 ef ff ff       	call   80020f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012f7:	cc                   	int3   
  8012f8:	eb fd                	jmp    8012f7 <_panic+0x53>
	...

008012fc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801302:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801309:	75 50                	jne    80135b <set_pgfault_handler+0x5f>
		// First time through!
		// LAB 4: Your code here.
		int error = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P);
  80130b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801312:	00 
  801313:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80131a:	ee 
  80131b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801322:	e8 05 fa ff ff       	call   800d2c <sys_page_alloc>
        if (error) {
  801327:	85 c0                	test   %eax,%eax
  801329:	74 1c                	je     801347 <set_pgfault_handler+0x4b>
            panic("No physical memory available!");
  80132b:	c7 44 24 08 24 1a 80 	movl   $0x801a24,0x8(%esp)
  801332:	00 
  801333:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80133a:	00 
  80133b:	c7 04 24 42 1a 80 00 	movl   $0x801a42,(%esp)
  801342:	e8 5d ff ff ff       	call   8012a4 <_panic>
        }

		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801347:	c7 44 24 04 68 13 80 	movl   $0x801368,0x4(%esp)
  80134e:	00 
  80134f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801356:	e8 4a fb ff ff       	call   800ea5 <sys_env_set_pgfault_upcall>
		
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80135b:	8b 45 08             	mov    0x8(%ebp),%eax
  80135e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801363:	c9                   	leave  
  801364:	c3                   	ret    
  801365:	00 00                	add    %al,(%eax)
	...

00801368 <_pgfault_upcall>:
  801368:	54                   	push   %esp
  801369:	a1 08 20 80 00       	mov    0x802008,%eax
  80136e:	ff d0                	call   *%eax
  801370:	83 c4 04             	add    $0x4,%esp
  801373:	89 e0                	mov    %esp,%eax
  801375:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  801379:	8b 64 24 30          	mov    0x30(%esp),%esp
  80137d:	53                   	push   %ebx
  80137e:	89 60 30             	mov    %esp,0x30(%eax)
  801381:	89 c4                	mov    %eax,%esp
  801383:	83 c4 04             	add    $0x4,%esp
  801386:	83 c4 04             	add    $0x4,%esp
  801389:	61                   	popa   
  80138a:	83 c4 04             	add    $0x4,%esp
  80138d:	9d                   	popf   
  80138e:	5c                   	pop    %esp
  80138f:	c3                   	ret    

00801390 <__udivdi3>:
  801390:	83 ec 1c             	sub    $0x1c,%esp
  801393:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801397:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80139b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80139f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8013a3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8013a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8013ab:	85 ff                	test   %edi,%edi
  8013ad:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8013b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b5:	89 cd                	mov    %ecx,%ebp
  8013b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bb:	75 33                	jne    8013f0 <__udivdi3+0x60>
  8013bd:	39 f1                	cmp    %esi,%ecx
  8013bf:	77 57                	ja     801418 <__udivdi3+0x88>
  8013c1:	85 c9                	test   %ecx,%ecx
  8013c3:	75 0b                	jne    8013d0 <__udivdi3+0x40>
  8013c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ca:	31 d2                	xor    %edx,%edx
  8013cc:	f7 f1                	div    %ecx
  8013ce:	89 c1                	mov    %eax,%ecx
  8013d0:	89 f0                	mov    %esi,%eax
  8013d2:	31 d2                	xor    %edx,%edx
  8013d4:	f7 f1                	div    %ecx
  8013d6:	89 c6                	mov    %eax,%esi
  8013d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013dc:	f7 f1                	div    %ecx
  8013de:	89 f2                	mov    %esi,%edx
  8013e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013ec:	83 c4 1c             	add    $0x1c,%esp
  8013ef:	c3                   	ret    
  8013f0:	31 d2                	xor    %edx,%edx
  8013f2:	31 c0                	xor    %eax,%eax
  8013f4:	39 f7                	cmp    %esi,%edi
  8013f6:	77 e8                	ja     8013e0 <__udivdi3+0x50>
  8013f8:	0f bd cf             	bsr    %edi,%ecx
  8013fb:	83 f1 1f             	xor    $0x1f,%ecx
  8013fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801402:	75 2c                	jne    801430 <__udivdi3+0xa0>
  801404:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801408:	76 04                	jbe    80140e <__udivdi3+0x7e>
  80140a:	39 f7                	cmp    %esi,%edi
  80140c:	73 d2                	jae    8013e0 <__udivdi3+0x50>
  80140e:	31 d2                	xor    %edx,%edx
  801410:	b8 01 00 00 00       	mov    $0x1,%eax
  801415:	eb c9                	jmp    8013e0 <__udivdi3+0x50>
  801417:	90                   	nop
  801418:	89 f2                	mov    %esi,%edx
  80141a:	f7 f1                	div    %ecx
  80141c:	31 d2                	xor    %edx,%edx
  80141e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801422:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801426:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80142a:	83 c4 1c             	add    $0x1c,%esp
  80142d:	c3                   	ret    
  80142e:	66 90                	xchg   %ax,%ax
  801430:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801435:	b8 20 00 00 00       	mov    $0x20,%eax
  80143a:	89 ea                	mov    %ebp,%edx
  80143c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801440:	d3 e7                	shl    %cl,%edi
  801442:	89 c1                	mov    %eax,%ecx
  801444:	d3 ea                	shr    %cl,%edx
  801446:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80144b:	09 fa                	or     %edi,%edx
  80144d:	89 f7                	mov    %esi,%edi
  80144f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801453:	89 f2                	mov    %esi,%edx
  801455:	8b 74 24 08          	mov    0x8(%esp),%esi
  801459:	d3 e5                	shl    %cl,%ebp
  80145b:	89 c1                	mov    %eax,%ecx
  80145d:	d3 ef                	shr    %cl,%edi
  80145f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801464:	d3 e2                	shl    %cl,%edx
  801466:	89 c1                	mov    %eax,%ecx
  801468:	d3 ee                	shr    %cl,%esi
  80146a:	09 d6                	or     %edx,%esi
  80146c:	89 fa                	mov    %edi,%edx
  80146e:	89 f0                	mov    %esi,%eax
  801470:	f7 74 24 0c          	divl   0xc(%esp)
  801474:	89 d7                	mov    %edx,%edi
  801476:	89 c6                	mov    %eax,%esi
  801478:	f7 e5                	mul    %ebp
  80147a:	39 d7                	cmp    %edx,%edi
  80147c:	72 22                	jb     8014a0 <__udivdi3+0x110>
  80147e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801482:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801487:	d3 e5                	shl    %cl,%ebp
  801489:	39 c5                	cmp    %eax,%ebp
  80148b:	73 04                	jae    801491 <__udivdi3+0x101>
  80148d:	39 d7                	cmp    %edx,%edi
  80148f:	74 0f                	je     8014a0 <__udivdi3+0x110>
  801491:	89 f0                	mov    %esi,%eax
  801493:	31 d2                	xor    %edx,%edx
  801495:	e9 46 ff ff ff       	jmp    8013e0 <__udivdi3+0x50>
  80149a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014a0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8014a3:	31 d2                	xor    %edx,%edx
  8014a5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8014a9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8014ad:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8014b1:	83 c4 1c             	add    $0x1c,%esp
  8014b4:	c3                   	ret    
	...

008014c0 <__umoddi3>:
  8014c0:	83 ec 1c             	sub    $0x1c,%esp
  8014c3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8014c7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8014cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8014cf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8014d3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8014d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8014db:	85 ed                	test   %ebp,%ebp
  8014dd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8014e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014e5:	89 cf                	mov    %ecx,%edi
  8014e7:	89 04 24             	mov    %eax,(%esp)
  8014ea:	89 f2                	mov    %esi,%edx
  8014ec:	75 1a                	jne    801508 <__umoddi3+0x48>
  8014ee:	39 f1                	cmp    %esi,%ecx
  8014f0:	76 4e                	jbe    801540 <__umoddi3+0x80>
  8014f2:	f7 f1                	div    %ecx
  8014f4:	89 d0                	mov    %edx,%eax
  8014f6:	31 d2                	xor    %edx,%edx
  8014f8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8014fc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801500:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801504:	83 c4 1c             	add    $0x1c,%esp
  801507:	c3                   	ret    
  801508:	39 f5                	cmp    %esi,%ebp
  80150a:	77 54                	ja     801560 <__umoddi3+0xa0>
  80150c:	0f bd c5             	bsr    %ebp,%eax
  80150f:	83 f0 1f             	xor    $0x1f,%eax
  801512:	89 44 24 04          	mov    %eax,0x4(%esp)
  801516:	75 60                	jne    801578 <__umoddi3+0xb8>
  801518:	3b 0c 24             	cmp    (%esp),%ecx
  80151b:	0f 87 07 01 00 00    	ja     801628 <__umoddi3+0x168>
  801521:	89 f2                	mov    %esi,%edx
  801523:	8b 34 24             	mov    (%esp),%esi
  801526:	29 ce                	sub    %ecx,%esi
  801528:	19 ea                	sbb    %ebp,%edx
  80152a:	89 34 24             	mov    %esi,(%esp)
  80152d:	8b 04 24             	mov    (%esp),%eax
  801530:	8b 74 24 10          	mov    0x10(%esp),%esi
  801534:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801538:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80153c:	83 c4 1c             	add    $0x1c,%esp
  80153f:	c3                   	ret    
  801540:	85 c9                	test   %ecx,%ecx
  801542:	75 0b                	jne    80154f <__umoddi3+0x8f>
  801544:	b8 01 00 00 00       	mov    $0x1,%eax
  801549:	31 d2                	xor    %edx,%edx
  80154b:	f7 f1                	div    %ecx
  80154d:	89 c1                	mov    %eax,%ecx
  80154f:	89 f0                	mov    %esi,%eax
  801551:	31 d2                	xor    %edx,%edx
  801553:	f7 f1                	div    %ecx
  801555:	8b 04 24             	mov    (%esp),%eax
  801558:	f7 f1                	div    %ecx
  80155a:	eb 98                	jmp    8014f4 <__umoddi3+0x34>
  80155c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801560:	89 f2                	mov    %esi,%edx
  801562:	8b 74 24 10          	mov    0x10(%esp),%esi
  801566:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80156a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80156e:	83 c4 1c             	add    $0x1c,%esp
  801571:	c3                   	ret    
  801572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801578:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80157d:	89 e8                	mov    %ebp,%eax
  80157f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801584:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801588:	89 fa                	mov    %edi,%edx
  80158a:	d3 e0                	shl    %cl,%eax
  80158c:	89 e9                	mov    %ebp,%ecx
  80158e:	d3 ea                	shr    %cl,%edx
  801590:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801595:	09 c2                	or     %eax,%edx
  801597:	8b 44 24 08          	mov    0x8(%esp),%eax
  80159b:	89 14 24             	mov    %edx,(%esp)
  80159e:	89 f2                	mov    %esi,%edx
  8015a0:	d3 e7                	shl    %cl,%edi
  8015a2:	89 e9                	mov    %ebp,%ecx
  8015a4:	d3 ea                	shr    %cl,%edx
  8015a6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015af:	d3 e6                	shl    %cl,%esi
  8015b1:	89 e9                	mov    %ebp,%ecx
  8015b3:	d3 e8                	shr    %cl,%eax
  8015b5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015ba:	09 f0                	or     %esi,%eax
  8015bc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8015c0:	f7 34 24             	divl   (%esp)
  8015c3:	d3 e6                	shl    %cl,%esi
  8015c5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015c9:	89 d6                	mov    %edx,%esi
  8015cb:	f7 e7                	mul    %edi
  8015cd:	39 d6                	cmp    %edx,%esi
  8015cf:	89 c1                	mov    %eax,%ecx
  8015d1:	89 d7                	mov    %edx,%edi
  8015d3:	72 3f                	jb     801614 <__umoddi3+0x154>
  8015d5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8015d9:	72 35                	jb     801610 <__umoddi3+0x150>
  8015db:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015df:	29 c8                	sub    %ecx,%eax
  8015e1:	19 fe                	sbb    %edi,%esi
  8015e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015e8:	89 f2                	mov    %esi,%edx
  8015ea:	d3 e8                	shr    %cl,%eax
  8015ec:	89 e9                	mov    %ebp,%ecx
  8015ee:	d3 e2                	shl    %cl,%edx
  8015f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015f5:	09 d0                	or     %edx,%eax
  8015f7:	89 f2                	mov    %esi,%edx
  8015f9:	d3 ea                	shr    %cl,%edx
  8015fb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8015ff:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801603:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801607:	83 c4 1c             	add    $0x1c,%esp
  80160a:	c3                   	ret    
  80160b:	90                   	nop
  80160c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801610:	39 d6                	cmp    %edx,%esi
  801612:	75 c7                	jne    8015db <__umoddi3+0x11b>
  801614:	89 d7                	mov    %edx,%edi
  801616:	89 c1                	mov    %eax,%ecx
  801618:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80161c:	1b 3c 24             	sbb    (%esp),%edi
  80161f:	eb ba                	jmp    8015db <__umoddi3+0x11b>
  801621:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801628:	39 f5                	cmp    %esi,%ebp
  80162a:	0f 82 f1 fe ff ff    	jb     801521 <__umoddi3+0x61>
  801630:	e9 f8 fe ff ff       	jmp    80152d <__umoddi3+0x6d>
