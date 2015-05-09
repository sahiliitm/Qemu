
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 1f 02 00 00       	call   800250 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 86 0e 00 00       	call   800edc <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 00 14 80 	movl   $0x801400,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 13 14 80 00 	movl   $0x801413,(%esp)
  800075:	e8 46 02 00 00       	call   8002c0 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 9d 0e 00 00       	call   800f3b <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 23 14 80 	movl   $0x801423,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 13 14 80 00 	movl   $0x801413,(%esp)
  8000bd:	e8 fe 01 00 00       	call   8002c0 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 f2 0a 00 00       	call   800bcc <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 ab 0e 00 00       	call   800f99 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 13 14 80 00 	movl   $0x801413,(%esp)
  80010d:	e8 ae 01 00 00       	call   8002c0 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	79 20                	jns    800152 <dumbfork+0x39>
		panic("sys_exofork: %e", envid);
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	c7 44 24 08 47 14 80 	movl   $0x801447,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 13 14 80 00 	movl   $0x801413,(%esp)
  80014d:	e8 6e 01 00 00       	call   8002c0 <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 19                	jne    80016f <dumbfork+0x56>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 21 0d 00 00       	call   800e7c <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80016d:	eb 7e                	jmp    8001ed <dumbfork+0xd4>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80016f:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800176:	b8 08 20 80 00       	mov    $0x802008,%eax
  80017b:	3d 00 00 80 00       	cmp    $0x800000,%eax
  800180:	76 23                	jbe    8001a5 <dumbfork+0x8c>
  800182:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  800187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018b:	89 1c 24             	mov    %ebx,(%esp)
  80018e:	e8 a1 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800193:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800196:	05 00 10 00 00       	add    $0x1000,%eax
  80019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80019e:	3d 08 20 80 00       	cmp    $0x802008,%eax
  8001a3:	72 e2                	jb     800187 <dumbfork+0x6e>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	89 34 24             	mov    %esi,(%esp)
  8001b4:	e8 7b fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001c0:	00 
  8001c1:	89 34 24             	mov    %esi,(%esp)
  8001c4:	e8 2e 0e 00 00       	call   800ff7 <sys_env_set_status>
  8001c9:	85 c0                	test   %eax,%eax
  8001cb:	79 20                	jns    8001ed <dumbfork+0xd4>
		panic("sys_env_set_status: %e", r);
  8001cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d1:	c7 44 24 08 57 14 80 	movl   $0x801457,0x8(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001e0:	00 
  8001e1:	c7 04 24 13 14 80 00 	movl   $0x801413,(%esp)
  8001e8:	e8 d3 00 00 00       	call   8002c0 <_panic>

	return envid;
}
  8001ed:	89 f0                	mov    %esi,%eax
  8001ef:	83 c4 20             	add    $0x20,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	57                   	push   %edi
  8001fa:	56                   	push   %esi
  8001fb:	53                   	push   %ebx
  8001fc:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001ff:	e8 15 ff ff ff       	call   800119 <dumbfork>
  800204:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800206:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80020b:	bf 75 14 80 00       	mov    $0x801475,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800210:	eb 26                	jmp    800238 <umain+0x42>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800212:	85 db                	test   %ebx,%ebx
  800214:	b8 6e 14 80 00       	mov    $0x80146e,%eax
  800219:	0f 44 c7             	cmove  %edi,%eax
  80021c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800220:	89 74 24 04          	mov    %esi,0x4(%esp)
  800224:	c7 04 24 7b 14 80 00 	movl   $0x80147b,(%esp)
  80022b:	e8 8b 01 00 00       	call   8003bb <cprintf>
		sys_yield();
  800230:	e8 77 0c 00 00       	call   800eac <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800235:	83 c6 01             	add    $0x1,%esi
  800238:	83 fb 01             	cmp    $0x1,%ebx
  80023b:	19 c0                	sbb    %eax,%eax
  80023d:	83 e0 0a             	and    $0xa,%eax
  800240:	83 c0 0a             	add    $0xa,%eax
  800243:	39 c6                	cmp    %eax,%esi
  800245:	7c cb                	jl     800212 <umain+0x1c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800247:	83 c4 1c             	add    $0x1c,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    
	...

00800250 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 18             	sub    $0x18,%esp
  800256:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800259:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80025c:	8b 75 08             	mov    0x8(%ebp),%esi
  80025f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800262:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800269:	00 00 00 
	envid_t envid = sys_getenvid();
  80026c:	e8 0b 0c 00 00       	call   800e7c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  800271:	25 ff 03 00 00       	and    $0x3ff,%eax
  800276:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800279:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80027e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800283:	85 f6                	test   %esi,%esi
  800285:	7e 07                	jle    80028e <libmain+0x3e>
		binaryname = argv[0];
  800287:	8b 03                	mov    (%ebx),%eax
  800289:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80028e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800292:	89 34 24             	mov    %esi,(%esp)
  800295:	e8 5c ff ff ff       	call   8001f6 <umain>

	// exit gracefully
	exit();
  80029a:	e8 0d 00 00 00       	call   8002ac <exit>
}
  80029f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002a2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8002a5:	89 ec                	mov    %ebp,%esp
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    
  8002a9:	00 00                	add    %al,(%eax)
	...

008002ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b9:	e8 61 0b 00 00       	call   800e1f <sys_env_destroy>
}
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	56                   	push   %esi
  8002c4:	53                   	push   %ebx
  8002c5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002cb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002d1:	e8 a6 0b 00 00       	call   800e7c <sys_getenvid>
  8002d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ec:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  8002f3:	e8 c3 00 00 00       	call   8003bb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	e8 53 00 00 00       	call   80035a <vcprintf>
	cprintf("\n");
  800307:	c7 04 24 8b 14 80 00 	movl   $0x80148b,(%esp)
  80030e:	e8 a8 00 00 00       	call   8003bb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800313:	cc                   	int3   
  800314:	eb fd                	jmp    800313 <_panic+0x53>
	...

00800318 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	53                   	push   %ebx
  80031c:	83 ec 14             	sub    $0x14,%esp
  80031f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800322:	8b 03                	mov    (%ebx),%eax
  800324:	8b 55 08             	mov    0x8(%ebp),%edx
  800327:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80032b:	83 c0 01             	add    $0x1,%eax
  80032e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800330:	3d ff 00 00 00       	cmp    $0xff,%eax
  800335:	75 19                	jne    800350 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800337:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80033e:	00 
  80033f:	8d 43 08             	lea    0x8(%ebx),%eax
  800342:	89 04 24             	mov    %eax,(%esp)
  800345:	e8 76 0a 00 00       	call   800dc0 <sys_cputs>
		b->idx = 0;
  80034a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800350:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800354:	83 c4 14             	add    $0x14,%esp
  800357:	5b                   	pop    %ebx
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    

0080035a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800363:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80036a:	00 00 00 
	b.cnt = 0;
  80036d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800374:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800377:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80037e:	8b 45 08             	mov    0x8(%ebp),%eax
  800381:	89 44 24 08          	mov    %eax,0x8(%esp)
  800385:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80038b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038f:	c7 04 24 18 03 80 00 	movl   $0x800318,(%esp)
  800396:	e8 d9 01 00 00       	call   800574 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80039b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ab:	89 04 24             	mov    %eax,(%esp)
  8003ae:	e8 0d 0a 00 00       	call   800dc0 <sys_cputs>

	return b.cnt;
}
  8003b3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    

008003bb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	e8 87 ff ff ff       	call   80035a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d3:	c9                   	leave  
  8003d4:	c3                   	ret    
	...

008003e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 3c             	sub    $0x3c,%esp
  8003e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ec:	89 d7                	mov    %edx,%edi
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800400:	b8 00 00 00 00       	mov    $0x0,%eax
  800405:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800408:	72 11                	jb     80041b <printnum+0x3b>
  80040a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80040d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800410:	76 09                	jbe    80041b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800412:	83 eb 01             	sub    $0x1,%ebx
  800415:	85 db                	test   %ebx,%ebx
  800417:	7f 51                	jg     80046a <printnum+0x8a>
  800419:	eb 5e                	jmp    800479 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80041f:	83 eb 01             	sub    $0x1,%ebx
  800422:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800426:	8b 45 10             	mov    0x10(%ebp),%eax
  800429:	89 44 24 08          	mov    %eax,0x8(%esp)
  80042d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800431:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800435:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80043c:	00 
  80043d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800446:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044a:	e8 01 0d 00 00       	call   801150 <__udivdi3>
  80044f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800453:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800457:	89 04 24             	mov    %eax,(%esp)
  80045a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80045e:	89 fa                	mov    %edi,%edx
  800460:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800463:	e8 78 ff ff ff       	call   8003e0 <printnum>
  800468:	eb 0f                	jmp    800479 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046e:	89 34 24             	mov    %esi,(%esp)
  800471:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800474:	83 eb 01             	sub    $0x1,%ebx
  800477:	75 f1                	jne    80046a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800479:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80047d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800481:	8b 45 10             	mov    0x10(%ebp),%eax
  800484:	89 44 24 08          	mov    %eax,0x8(%esp)
  800488:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80048f:	00 
  800490:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	e8 de 0d 00 00       	call   801280 <__umoddi3>
  8004a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a6:	0f be 80 bc 14 80 00 	movsbl 0x8014bc(%eax),%eax
  8004ad:	89 04 24             	mov    %eax,(%esp)
  8004b0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004b3:	83 c4 3c             	add    $0x3c,%esp
  8004b6:	5b                   	pop    %ebx
  8004b7:	5e                   	pop    %esi
  8004b8:	5f                   	pop    %edi
  8004b9:	5d                   	pop    %ebp
  8004ba:	c3                   	ret    

008004bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004bb:	55                   	push   %ebp
  8004bc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004be:	83 fa 01             	cmp    $0x1,%edx
  8004c1:	7e 0e                	jle    8004d1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c8:	89 08                	mov    %ecx,(%eax)
  8004ca:	8b 02                	mov    (%edx),%eax
  8004cc:	8b 52 04             	mov    0x4(%edx),%edx
  8004cf:	eb 22                	jmp    8004f3 <getuint+0x38>
	else if (lflag)
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	74 10                	je     8004e5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d5:	8b 10                	mov    (%eax),%edx
  8004d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004da:	89 08                	mov    %ecx,(%eax)
  8004dc:	8b 02                	mov    (%edx),%eax
  8004de:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e3:	eb 0e                	jmp    8004f3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ea:	89 08                	mov    %ecx,(%eax)
  8004ec:	8b 02                	mov    (%edx),%eax
  8004ee:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f3:	5d                   	pop    %ebp
  8004f4:	c3                   	ret    

008004f5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004f5:	55                   	push   %ebp
  8004f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004f8:	83 fa 01             	cmp    $0x1,%edx
  8004fb:	7e 0e                	jle    80050b <getint+0x16>
		return va_arg(*ap, long long);
  8004fd:	8b 10                	mov    (%eax),%edx
  8004ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  800502:	89 08                	mov    %ecx,(%eax)
  800504:	8b 02                	mov    (%edx),%eax
  800506:	8b 52 04             	mov    0x4(%edx),%edx
  800509:	eb 22                	jmp    80052d <getint+0x38>
	else if (lflag)
  80050b:	85 d2                	test   %edx,%edx
  80050d:	74 10                	je     80051f <getint+0x2a>
		return va_arg(*ap, long);
  80050f:	8b 10                	mov    (%eax),%edx
  800511:	8d 4a 04             	lea    0x4(%edx),%ecx
  800514:	89 08                	mov    %ecx,(%eax)
  800516:	8b 02                	mov    (%edx),%eax
  800518:	89 c2                	mov    %eax,%edx
  80051a:	c1 fa 1f             	sar    $0x1f,%edx
  80051d:	eb 0e                	jmp    80052d <getint+0x38>
	else
		return va_arg(*ap, int);
  80051f:	8b 10                	mov    (%eax),%edx
  800521:	8d 4a 04             	lea    0x4(%edx),%ecx
  800524:	89 08                	mov    %ecx,(%eax)
  800526:	8b 02                	mov    (%edx),%eax
  800528:	89 c2                	mov    %eax,%edx
  80052a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80052d:	5d                   	pop    %ebp
  80052e:	c3                   	ret    

0080052f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800535:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800539:	8b 10                	mov    (%eax),%edx
  80053b:	3b 50 04             	cmp    0x4(%eax),%edx
  80053e:	73 0a                	jae    80054a <sprintputch+0x1b>
		*b->buf++ = ch;
  800540:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800543:	88 0a                	mov    %cl,(%edx)
  800545:	83 c2 01             	add    $0x1,%edx
  800548:	89 10                	mov    %edx,(%eax)
}
  80054a:	5d                   	pop    %ebp
  80054b:	c3                   	ret    

0080054c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800552:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800555:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800559:	8b 45 10             	mov    0x10(%ebp),%eax
  80055c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800560:	8b 45 0c             	mov    0xc(%ebp),%eax
  800563:	89 44 24 04          	mov    %eax,0x4(%esp)
  800567:	8b 45 08             	mov    0x8(%ebp),%eax
  80056a:	89 04 24             	mov    %eax,(%esp)
  80056d:	e8 02 00 00 00       	call   800574 <vprintfmt>
	va_end(ap);
}
  800572:	c9                   	leave  
  800573:	c3                   	ret    

00800574 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	57                   	push   %edi
  800578:	56                   	push   %esi
  800579:	53                   	push   %ebx
  80057a:	83 ec 4c             	sub    $0x4c,%esp
  80057d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800580:	8b 75 10             	mov    0x10(%ebp),%esi
  800583:	eb 12                	jmp    800597 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800585:	85 c0                	test   %eax,%eax
  800587:	0f 84 77 03 00 00    	je     800904 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  80058d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800591:	89 04 24             	mov    %eax,(%esp)
  800594:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800597:	0f b6 06             	movzbl (%esi),%eax
  80059a:	83 c6 01             	add    $0x1,%esi
  80059d:	83 f8 25             	cmp    $0x25,%eax
  8005a0:	75 e3                	jne    800585 <vprintfmt+0x11>
  8005a2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005ad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005b2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005be:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005c1:	eb 2b                	jmp    8005ee <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005c6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005ca:	eb 22                	jmp    8005ee <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005cf:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005d3:	eb 19                	jmp    8005ee <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005df:	eb 0d                	jmp    8005ee <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005e7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	0f b6 06             	movzbl (%esi),%eax
  8005f1:	0f b6 d0             	movzbl %al,%edx
  8005f4:	8d 7e 01             	lea    0x1(%esi),%edi
  8005f7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005fa:	83 e8 23             	sub    $0x23,%eax
  8005fd:	3c 55                	cmp    $0x55,%al
  8005ff:	0f 87 d9 02 00 00    	ja     8008de <vprintfmt+0x36a>
  800605:	0f b6 c0             	movzbl %al,%eax
  800608:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80060f:	83 ea 30             	sub    $0x30,%edx
  800612:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800615:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800619:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80061f:	83 fa 09             	cmp    $0x9,%edx
  800622:	77 4a                	ja     80066e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800627:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80062a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80062d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800631:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800634:	8d 50 d0             	lea    -0x30(%eax),%edx
  800637:	83 fa 09             	cmp    $0x9,%edx
  80063a:	76 eb                	jbe    800627 <vprintfmt+0xb3>
  80063c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80063f:	eb 2d                	jmp    80066e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 50 04             	lea    0x4(%eax),%edx
  800647:	89 55 14             	mov    %edx,0x14(%ebp)
  80064a:	8b 00                	mov    (%eax),%eax
  80064c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800652:	eb 1a                	jmp    80066e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800654:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800657:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80065b:	79 91                	jns    8005ee <vprintfmt+0x7a>
  80065d:	e9 73 ff ff ff       	jmp    8005d5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800665:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80066c:	eb 80                	jmp    8005ee <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80066e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800672:	0f 89 76 ff ff ff    	jns    8005ee <vprintfmt+0x7a>
  800678:	e9 64 ff ff ff       	jmp    8005e1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80067d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800680:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800683:	e9 66 ff ff ff       	jmp    8005ee <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 04             	lea    0x4(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)
  800691:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	89 04 24             	mov    %eax,(%esp)
  80069a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006a0:	e9 f2 fe ff ff       	jmp    800597 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 50 04             	lea    0x4(%eax),%edx
  8006ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ae:	8b 00                	mov    (%eax),%eax
  8006b0:	89 c2                	mov    %eax,%edx
  8006b2:	c1 fa 1f             	sar    $0x1f,%edx
  8006b5:	31 d0                	xor    %edx,%eax
  8006b7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006b9:	83 f8 08             	cmp    $0x8,%eax
  8006bc:	7f 0b                	jg     8006c9 <vprintfmt+0x155>
  8006be:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  8006c5:	85 d2                	test   %edx,%edx
  8006c7:	75 23                	jne    8006ec <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8006c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006cd:	c7 44 24 08 d4 14 80 	movl   $0x8014d4,0x8(%esp)
  8006d4:	00 
  8006d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006dc:	89 3c 24             	mov    %edi,(%esp)
  8006df:	e8 68 fe ff ff       	call   80054c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006e7:	e9 ab fe ff ff       	jmp    800597 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f0:	c7 44 24 08 dd 14 80 	movl   $0x8014dd,0x8(%esp)
  8006f7:	00 
  8006f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ff:	89 3c 24             	mov    %edi,(%esp)
  800702:	e8 45 fe ff ff       	call   80054c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800707:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80070a:	e9 88 fe ff ff       	jmp    800597 <vprintfmt+0x23>
  80070f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800712:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800715:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)
  800721:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800723:	85 f6                	test   %esi,%esi
  800725:	ba cd 14 80 00       	mov    $0x8014cd,%edx
  80072a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80072d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800731:	7e 06                	jle    800739 <vprintfmt+0x1c5>
  800733:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800737:	75 10                	jne    800749 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800739:	0f be 06             	movsbl (%esi),%eax
  80073c:	83 c6 01             	add    $0x1,%esi
  80073f:	85 c0                	test   %eax,%eax
  800741:	0f 85 86 00 00 00    	jne    8007cd <vprintfmt+0x259>
  800747:	eb 76                	jmp    8007bf <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800749:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074d:	89 34 24             	mov    %esi,(%esp)
  800750:	e8 56 02 00 00       	call   8009ab <strnlen>
  800755:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800758:	29 c2                	sub    %eax,%edx
  80075a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80075d:	85 d2                	test   %edx,%edx
  80075f:	7e d8                	jle    800739 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800761:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800765:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800768:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80076b:	89 d6                	mov    %edx,%esi
  80076d:	89 c7                	mov    %eax,%edi
  80076f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800773:	89 3c 24             	mov    %edi,(%esp)
  800776:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800779:	83 ee 01             	sub    $0x1,%esi
  80077c:	75 f1                	jne    80076f <vprintfmt+0x1fb>
  80077e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800781:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800784:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800787:	eb b0                	jmp    800739 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800789:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80078d:	74 18                	je     8007a7 <vprintfmt+0x233>
  80078f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800792:	83 fa 5e             	cmp    $0x5e,%edx
  800795:	76 10                	jbe    8007a7 <vprintfmt+0x233>
					putch('?', putdat);
  800797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007a2:	ff 55 08             	call   *0x8(%ebp)
  8007a5:	eb 0a                	jmp    8007b1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  8007a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ab:	89 04 24             	mov    %eax,(%esp)
  8007ae:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8007b5:	0f be 06             	movsbl (%esi),%eax
  8007b8:	83 c6 01             	add    $0x1,%esi
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	75 0e                	jne    8007cd <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c6:	7f 11                	jg     8007d9 <vprintfmt+0x265>
  8007c8:	e9 ca fd ff ff       	jmp    800597 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007cd:	85 ff                	test   %edi,%edi
  8007cf:	90                   	nop
  8007d0:	78 b7                	js     800789 <vprintfmt+0x215>
  8007d2:	83 ef 01             	sub    $0x1,%edi
  8007d5:	79 b2                	jns    800789 <vprintfmt+0x215>
  8007d7:	eb e6                	jmp    8007bf <vprintfmt+0x24b>
  8007d9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007dc:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007ea:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007ec:	83 ee 01             	sub    $0x1,%esi
  8007ef:	75 ee                	jne    8007df <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007f4:	e9 9e fd ff ff       	jmp    800597 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f9:	89 ca                	mov    %ecx,%edx
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fe:	e8 f2 fc ff ff       	call   8004f5 <getint>
  800803:	89 c6                	mov    %eax,%esi
  800805:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800807:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80080c:	85 d2                	test   %edx,%edx
  80080e:	0f 89 8c 00 00 00    	jns    8008a0 <vprintfmt+0x32c>
				putch('-', putdat);
  800814:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800818:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80081f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800822:	f7 de                	neg    %esi
  800824:	83 d7 00             	adc    $0x0,%edi
  800827:	f7 df                	neg    %edi
			}
			base = 10;
  800829:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082e:	eb 70                	jmp    8008a0 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800830:	89 ca                	mov    %ecx,%edx
  800832:	8d 45 14             	lea    0x14(%ebp),%eax
  800835:	e8 81 fc ff ff       	call   8004bb <getuint>
  80083a:	89 c6                	mov    %eax,%esi
  80083c:	89 d7                	mov    %edx,%edi
			base = 10;
  80083e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800843:	eb 5b                	jmp    8008a0 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  800845:	89 ca                	mov    %ecx,%edx
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
  80084a:	e8 a6 fc ff ff       	call   8004f5 <getint>
  80084f:	89 c6                	mov    %eax,%esi
  800851:	89 d7                	mov    %edx,%edi
			base = 8;
  800853:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800858:	eb 46                	jmp    8008a0 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80085a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800865:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800868:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800873:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8d 50 04             	lea    0x4(%eax),%edx
  80087c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80087f:	8b 30                	mov    (%eax),%esi
  800881:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800886:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80088b:	eb 13                	jmp    8008a0 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80088d:	89 ca                	mov    %ecx,%edx
  80088f:	8d 45 14             	lea    0x14(%ebp),%eax
  800892:	e8 24 fc ff ff       	call   8004bb <getuint>
  800897:	89 c6                	mov    %eax,%esi
  800899:	89 d7                	mov    %edx,%edi
			base = 16;
  80089b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008a4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b3:	89 34 24             	mov    %esi,(%esp)
  8008b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ba:	89 da                	mov    %ebx,%edx
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	e8 1c fb ff ff       	call   8003e0 <printnum>
			break;
  8008c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008c7:	e9 cb fc ff ff       	jmp    800597 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d0:	89 14 24             	mov    %edx,(%esp)
  8008d3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d9:	e9 b9 fc ff ff       	jmp    800597 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008e9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ec:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008f0:	0f 84 a1 fc ff ff    	je     800597 <vprintfmt+0x23>
  8008f6:	83 ee 01             	sub    $0x1,%esi
  8008f9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008fd:	75 f7                	jne    8008f6 <vprintfmt+0x382>
  8008ff:	e9 93 fc ff ff       	jmp    800597 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800904:	83 c4 4c             	add    $0x4c,%esp
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	83 ec 28             	sub    $0x28,%esp
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800918:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800922:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800929:	85 c0                	test   %eax,%eax
  80092b:	74 30                	je     80095d <vsnprintf+0x51>
  80092d:	85 d2                	test   %edx,%edx
  80092f:	7e 2c                	jle    80095d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800931:	8b 45 14             	mov    0x14(%ebp),%eax
  800934:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800938:	8b 45 10             	mov    0x10(%ebp),%eax
  80093b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800942:	89 44 24 04          	mov    %eax,0x4(%esp)
  800946:	c7 04 24 2f 05 80 00 	movl   $0x80052f,(%esp)
  80094d:	e8 22 fc ff ff       	call   800574 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800952:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800955:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095b:	eb 05                	jmp    800962 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80095d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800971:	8b 45 10             	mov    0x10(%ebp),%eax
  800974:	89 44 24 08          	mov    %eax,0x8(%esp)
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	89 04 24             	mov    %eax,(%esp)
  800985:	e8 82 ff ff ff       	call   80090c <vsnprintf>
	va_end(ap);

	return rc;
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    
  80098c:	00 00                	add    %al,(%eax)
	...

00800990 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
  80099b:	80 3a 00             	cmpb   $0x0,(%edx)
  80099e:	74 09                	je     8009a9 <strlen+0x19>
		n++;
  8009a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a7:	75 f7                	jne    8009a0 <strlen+0x10>
		n++;
	return n;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ba:	85 c9                	test   %ecx,%ecx
  8009bc:	74 1a                	je     8009d8 <strnlen+0x2d>
  8009be:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009c1:	74 15                	je     8009d8 <strnlen+0x2d>
  8009c3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009c8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ca:	39 ca                	cmp    %ecx,%edx
  8009cc:	74 0a                	je     8009d8 <strnlen+0x2d>
  8009ce:	83 c2 01             	add    $0x1,%edx
  8009d1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009d6:	75 f0                	jne    8009c8 <strnlen+0x1d>
		n++;
	return n;
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ee:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009f1:	83 c2 01             	add    $0x1,%edx
  8009f4:	84 c9                	test   %cl,%cl
  8009f6:	75 f2                	jne    8009ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	83 ec 08             	sub    $0x8,%esp
  800a02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a05:	89 1c 24             	mov    %ebx,(%esp)
  800a08:	e8 83 ff ff ff       	call   800990 <strlen>
	strcpy(dst + len, src);
  800a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a10:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a14:	01 d8                	add    %ebx,%eax
  800a16:	89 04 24             	mov    %eax,(%esp)
  800a19:	e8 bd ff ff ff       	call   8009db <strcpy>
	return dst;
}
  800a1e:	89 d8                	mov    %ebx,%eax
  800a20:	83 c4 08             	add    $0x8,%esp
  800a23:	5b                   	pop    %ebx
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a31:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a34:	85 f6                	test   %esi,%esi
  800a36:	74 18                	je     800a50 <strncpy+0x2a>
  800a38:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a3d:	0f b6 1a             	movzbl (%edx),%ebx
  800a40:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a43:	80 3a 01             	cmpb   $0x1,(%edx)
  800a46:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	39 f1                	cmp    %esi,%ecx
  800a4e:	75 ed                	jne    800a3d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a60:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a63:	89 f8                	mov    %edi,%eax
  800a65:	85 f6                	test   %esi,%esi
  800a67:	74 2b                	je     800a94 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a69:	83 fe 01             	cmp    $0x1,%esi
  800a6c:	74 23                	je     800a91 <strlcpy+0x3d>
  800a6e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a71:	84 c9                	test   %cl,%cl
  800a73:	74 1c                	je     800a91 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a75:	83 ee 02             	sub    $0x2,%esi
  800a78:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a7d:	88 08                	mov    %cl,(%eax)
  800a7f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a82:	39 f2                	cmp    %esi,%edx
  800a84:	74 0b                	je     800a91 <strlcpy+0x3d>
  800a86:	83 c2 01             	add    $0x1,%edx
  800a89:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a8d:	84 c9                	test   %cl,%cl
  800a8f:	75 ec                	jne    800a7d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a91:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a94:	29 f8                	sub    %edi,%eax
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa4:	0f b6 01             	movzbl (%ecx),%eax
  800aa7:	84 c0                	test   %al,%al
  800aa9:	74 16                	je     800ac1 <strcmp+0x26>
  800aab:	3a 02                	cmp    (%edx),%al
  800aad:	75 12                	jne    800ac1 <strcmp+0x26>
		p++, q++;
  800aaf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ab2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ab6:	84 c0                	test   %al,%al
  800ab8:	74 07                	je     800ac1 <strcmp+0x26>
  800aba:	83 c1 01             	add    $0x1,%ecx
  800abd:	3a 02                	cmp    (%edx),%al
  800abf:	74 ee                	je     800aaf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac1:	0f b6 c0             	movzbl %al,%eax
  800ac4:	0f b6 12             	movzbl (%edx),%edx
  800ac7:	29 d0                	sub    %edx,%eax
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800add:	85 d2                	test   %edx,%edx
  800adf:	74 28                	je     800b09 <strncmp+0x3e>
  800ae1:	0f b6 01             	movzbl (%ecx),%eax
  800ae4:	84 c0                	test   %al,%al
  800ae6:	74 24                	je     800b0c <strncmp+0x41>
  800ae8:	3a 03                	cmp    (%ebx),%al
  800aea:	75 20                	jne    800b0c <strncmp+0x41>
  800aec:	83 ea 01             	sub    $0x1,%edx
  800aef:	74 13                	je     800b04 <strncmp+0x39>
		n--, p++, q++;
  800af1:	83 c1 01             	add    $0x1,%ecx
  800af4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af7:	0f b6 01             	movzbl (%ecx),%eax
  800afa:	84 c0                	test   %al,%al
  800afc:	74 0e                	je     800b0c <strncmp+0x41>
  800afe:	3a 03                	cmp    (%ebx),%al
  800b00:	74 ea                	je     800aec <strncmp+0x21>
  800b02:	eb 08                	jmp    800b0c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0c:	0f b6 01             	movzbl (%ecx),%eax
  800b0f:	0f b6 13             	movzbl (%ebx),%edx
  800b12:	29 d0                	sub    %edx,%eax
  800b14:	eb f3                	jmp    800b09 <strncmp+0x3e>

00800b16 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b20:	0f b6 10             	movzbl (%eax),%edx
  800b23:	84 d2                	test   %dl,%dl
  800b25:	74 1c                	je     800b43 <strchr+0x2d>
		if (*s == c)
  800b27:	38 ca                	cmp    %cl,%dl
  800b29:	75 09                	jne    800b34 <strchr+0x1e>
  800b2b:	eb 1b                	jmp    800b48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b2d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b30:	38 ca                	cmp    %cl,%dl
  800b32:	74 14                	je     800b48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b34:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b38:	84 d2                	test   %dl,%dl
  800b3a:	75 f1                	jne    800b2d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b41:	eb 05                	jmp    800b48 <strchr+0x32>
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b54:	0f b6 10             	movzbl (%eax),%edx
  800b57:	84 d2                	test   %dl,%dl
  800b59:	74 14                	je     800b6f <strfind+0x25>
		if (*s == c)
  800b5b:	38 ca                	cmp    %cl,%dl
  800b5d:	75 06                	jne    800b65 <strfind+0x1b>
  800b5f:	eb 0e                	jmp    800b6f <strfind+0x25>
  800b61:	38 ca                	cmp    %cl,%dl
  800b63:	74 0a                	je     800b6f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b65:	83 c0 01             	add    $0x1,%eax
  800b68:	0f b6 10             	movzbl (%eax),%edx
  800b6b:	84 d2                	test   %dl,%dl
  800b6d:	75 f2                	jne    800b61 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	83 ec 0c             	sub    $0xc,%esp
  800b77:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b7a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b7d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b89:	85 c9                	test   %ecx,%ecx
  800b8b:	74 30                	je     800bbd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b93:	75 25                	jne    800bba <memset+0x49>
  800b95:	f6 c1 03             	test   $0x3,%cl
  800b98:	75 20                	jne    800bba <memset+0x49>
		c &= 0xFF;
  800b9a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b9d:	89 d3                	mov    %edx,%ebx
  800b9f:	c1 e3 08             	shl    $0x8,%ebx
  800ba2:	89 d6                	mov    %edx,%esi
  800ba4:	c1 e6 18             	shl    $0x18,%esi
  800ba7:	89 d0                	mov    %edx,%eax
  800ba9:	c1 e0 10             	shl    $0x10,%eax
  800bac:	09 f0                	or     %esi,%eax
  800bae:	09 d0                	or     %edx,%eax
  800bb0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bb2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bb5:	fc                   	cld    
  800bb6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb8:	eb 03                	jmp    800bbd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bba:	fc                   	cld    
  800bbb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bbd:	89 f8                	mov    %edi,%eax
  800bbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bc8:	89 ec                	mov    %ebp,%esp
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	83 ec 08             	sub    $0x8,%esp
  800bd2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bd5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800be1:	39 c6                	cmp    %eax,%esi
  800be3:	73 36                	jae    800c1b <memmove+0x4f>
  800be5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be8:	39 d0                	cmp    %edx,%eax
  800bea:	73 2f                	jae    800c1b <memmove+0x4f>
		s += n;
		d += n;
  800bec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bef:	f6 c2 03             	test   $0x3,%dl
  800bf2:	75 1b                	jne    800c0f <memmove+0x43>
  800bf4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bfa:	75 13                	jne    800c0f <memmove+0x43>
  800bfc:	f6 c1 03             	test   $0x3,%cl
  800bff:	75 0e                	jne    800c0f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c01:	83 ef 04             	sub    $0x4,%edi
  800c04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c0a:	fd                   	std    
  800c0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0d:	eb 09                	jmp    800c18 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c0f:	83 ef 01             	sub    $0x1,%edi
  800c12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c15:	fd                   	std    
  800c16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c18:	fc                   	cld    
  800c19:	eb 20                	jmp    800c3b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c21:	75 13                	jne    800c36 <memmove+0x6a>
  800c23:	a8 03                	test   $0x3,%al
  800c25:	75 0f                	jne    800c36 <memmove+0x6a>
  800c27:	f6 c1 03             	test   $0x3,%cl
  800c2a:	75 0a                	jne    800c36 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c2c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c2f:	89 c7                	mov    %eax,%edi
  800c31:	fc                   	cld    
  800c32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c34:	eb 05                	jmp    800c3b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c36:	89 c7                	mov    %eax,%edi
  800c38:	fc                   	cld    
  800c39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c3b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c41:	89 ec                	mov    %ebp,%esp
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	89 04 24             	mov    %eax,(%esp)
  800c5f:	e8 68 ff ff ff       	call   800bcc <memmove>
}
  800c64:	c9                   	leave  
  800c65:	c3                   	ret    

00800c66 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c72:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c75:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7a:	85 ff                	test   %edi,%edi
  800c7c:	74 37                	je     800cb5 <memcmp+0x4f>
		if (*s1 != *s2)
  800c7e:	0f b6 03             	movzbl (%ebx),%eax
  800c81:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c84:	83 ef 01             	sub    $0x1,%edi
  800c87:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c8c:	38 c8                	cmp    %cl,%al
  800c8e:	74 1c                	je     800cac <memcmp+0x46>
  800c90:	eb 10                	jmp    800ca2 <memcmp+0x3c>
  800c92:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c97:	83 c2 01             	add    $0x1,%edx
  800c9a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c9e:	38 c8                	cmp    %cl,%al
  800ca0:	74 0a                	je     800cac <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800ca2:	0f b6 c0             	movzbl %al,%eax
  800ca5:	0f b6 c9             	movzbl %cl,%ecx
  800ca8:	29 c8                	sub    %ecx,%eax
  800caa:	eb 09                	jmp    800cb5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cac:	39 fa                	cmp    %edi,%edx
  800cae:	75 e2                	jne    800c92 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cc0:	89 c2                	mov    %eax,%edx
  800cc2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cc5:	39 d0                	cmp    %edx,%eax
  800cc7:	73 19                	jae    800ce2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cc9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ccd:	38 08                	cmp    %cl,(%eax)
  800ccf:	75 06                	jne    800cd7 <memfind+0x1d>
  800cd1:	eb 0f                	jmp    800ce2 <memfind+0x28>
  800cd3:	38 08                	cmp    %cl,(%eax)
  800cd5:	74 0b                	je     800ce2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd7:	83 c0 01             	add    $0x1,%eax
  800cda:	39 d0                	cmp    %edx,%eax
  800cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	75 f1                	jne    800cd3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf0:	0f b6 02             	movzbl (%edx),%eax
  800cf3:	3c 20                	cmp    $0x20,%al
  800cf5:	74 04                	je     800cfb <strtol+0x17>
  800cf7:	3c 09                	cmp    $0x9,%al
  800cf9:	75 0e                	jne    800d09 <strtol+0x25>
		s++;
  800cfb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfe:	0f b6 02             	movzbl (%edx),%eax
  800d01:	3c 20                	cmp    $0x20,%al
  800d03:	74 f6                	je     800cfb <strtol+0x17>
  800d05:	3c 09                	cmp    $0x9,%al
  800d07:	74 f2                	je     800cfb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d09:	3c 2b                	cmp    $0x2b,%al
  800d0b:	75 0a                	jne    800d17 <strtol+0x33>
		s++;
  800d0d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d10:	bf 00 00 00 00       	mov    $0x0,%edi
  800d15:	eb 10                	jmp    800d27 <strtol+0x43>
  800d17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d1c:	3c 2d                	cmp    $0x2d,%al
  800d1e:	75 07                	jne    800d27 <strtol+0x43>
		s++, neg = 1;
  800d20:	83 c2 01             	add    $0x1,%edx
  800d23:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d27:	85 db                	test   %ebx,%ebx
  800d29:	0f 94 c0             	sete   %al
  800d2c:	74 05                	je     800d33 <strtol+0x4f>
  800d2e:	83 fb 10             	cmp    $0x10,%ebx
  800d31:	75 15                	jne    800d48 <strtol+0x64>
  800d33:	80 3a 30             	cmpb   $0x30,(%edx)
  800d36:	75 10                	jne    800d48 <strtol+0x64>
  800d38:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d3c:	75 0a                	jne    800d48 <strtol+0x64>
		s += 2, base = 16;
  800d3e:	83 c2 02             	add    $0x2,%edx
  800d41:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d46:	eb 13                	jmp    800d5b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d48:	84 c0                	test   %al,%al
  800d4a:	74 0f                	je     800d5b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d51:	80 3a 30             	cmpb   $0x30,(%edx)
  800d54:	75 05                	jne    800d5b <strtol+0x77>
		s++, base = 8;
  800d56:	83 c2 01             	add    $0x1,%edx
  800d59:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d60:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d62:	0f b6 0a             	movzbl (%edx),%ecx
  800d65:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d68:	80 fb 09             	cmp    $0x9,%bl
  800d6b:	77 08                	ja     800d75 <strtol+0x91>
			dig = *s - '0';
  800d6d:	0f be c9             	movsbl %cl,%ecx
  800d70:	83 e9 30             	sub    $0x30,%ecx
  800d73:	eb 1e                	jmp    800d93 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d75:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d78:	80 fb 19             	cmp    $0x19,%bl
  800d7b:	77 08                	ja     800d85 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d7d:	0f be c9             	movsbl %cl,%ecx
  800d80:	83 e9 57             	sub    $0x57,%ecx
  800d83:	eb 0e                	jmp    800d93 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d85:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d88:	80 fb 19             	cmp    $0x19,%bl
  800d8b:	77 14                	ja     800da1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d8d:	0f be c9             	movsbl %cl,%ecx
  800d90:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d93:	39 f1                	cmp    %esi,%ecx
  800d95:	7d 0e                	jge    800da5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d97:	83 c2 01             	add    $0x1,%edx
  800d9a:	0f af c6             	imul   %esi,%eax
  800d9d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d9f:	eb c1                	jmp    800d62 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800da1:	89 c1                	mov    %eax,%ecx
  800da3:	eb 02                	jmp    800da7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800da5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800da7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dab:	74 05                	je     800db2 <strtol+0xce>
		*endptr = (char *) s;
  800dad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800db0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800db2:	89 ca                	mov    %ecx,%edx
  800db4:	f7 da                	neg    %edx
  800db6:	85 ff                	test   %edi,%edi
  800db8:	0f 45 c2             	cmovne %edx,%eax
}
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dcc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 c7                	mov    %eax,%edi
  800dde:	89 c6                	mov    %eax,%esi
  800de0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800de2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800deb:	89 ec                	mov    %ebp,%esp
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_cgetc>:

int
sys_cgetc(void)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800e03:	b8 01 00 00 00       	mov    $0x1,%eax
  800e08:	89 d1                	mov    %edx,%ecx
  800e0a:	89 d3                	mov    %edx,%ebx
  800e0c:	89 d7                	mov    %edx,%edi
  800e0e:	89 d6                	mov    %edx,%esi
  800e10:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1b:	89 ec                	mov    %ebp,%esp
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 38             	sub    $0x38,%esp
  800e25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e33:	b8 03 00 00 00       	mov    $0x3,%eax
  800e38:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3b:	89 cb                	mov    %ecx,%ebx
  800e3d:	89 cf                	mov    %ecx,%edi
  800e3f:	89 ce                	mov    %ecx,%esi
  800e41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	7e 28                	jle    800e6f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e52:	00 
  800e53:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800e5a:	00 
  800e5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e62:	00 
  800e63:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800e6a:	e8 51 f4 ff ff       	call   8002c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 0c             	sub    $0xc,%esp
  800e82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e88:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e90:	b8 02 00 00 00       	mov    $0x2,%eax
  800e95:	89 d1                	mov    %edx,%ecx
  800e97:	89 d3                	mov    %edx,%ebx
  800e99:	89 d7                	mov    %edx,%edi
  800e9b:	89 d6                	mov    %edx,%esi
  800e9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea8:	89 ec                	mov    %ebp,%esp
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_yield>:

void
sys_yield(void)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 0c             	sub    $0xc,%esp
  800eb2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ec5:	89 d1                	mov    %edx,%ecx
  800ec7:	89 d3                	mov    %edx,%ebx
  800ec9:	89 d7                	mov    %edx,%edi
  800ecb:	89 d6                	mov    %edx,%esi
  800ecd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ecf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed8:	89 ec                	mov    %ebp,%esp
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 38             	sub    $0x38,%esp
  800ee2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eeb:	be 00 00 00 00       	mov    $0x0,%esi
  800ef0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	89 f7                	mov    %esi,%edi
  800f00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f02:	85 c0                	test   %eax,%eax
  800f04:	7e 28                	jle    800f2e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f11:	00 
  800f12:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800f19:	00 
  800f1a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f21:	00 
  800f22:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800f29:	e8 92 f3 ff ff       	call   8002c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f2e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f31:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f34:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f37:	89 ec                	mov    %ebp,%esp
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 38             	sub    $0x38,%esp
  800f41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f47:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f60:	85 c0                	test   %eax,%eax
  800f62:	7e 28                	jle    800f8c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f6f:	00 
  800f70:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7f:	00 
  800f80:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800f87:	e8 34 f3 ff ff       	call   8002c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f8c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f92:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f95:	89 ec                	mov    %ebp,%esp
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 38             	sub    $0x38,%esp
  800f9f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fad:	b8 06 00 00 00       	mov    $0x6,%eax
  800fb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	89 df                	mov    %ebx,%edi
  800fba:	89 de                	mov    %ebx,%esi
  800fbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	7e 28                	jle    800fea <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fcd:	00 
  800fce:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800fd5:	00 
  800fd6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fdd:	00 
  800fde:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800fe5:	e8 d6 f2 ff ff       	call   8002c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff3:	89 ec                	mov    %ebp,%esp
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 38             	sub    $0x38,%esp
  800ffd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801000:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801003:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801006:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100b:	b8 08 00 00 00       	mov    $0x8,%eax
  801010:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801013:	8b 55 08             	mov    0x8(%ebp),%edx
  801016:	89 df                	mov    %ebx,%edi
  801018:	89 de                	mov    %ebx,%esi
  80101a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80101c:	85 c0                	test   %eax,%eax
  80101e:	7e 28                	jle    801048 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801020:	89 44 24 10          	mov    %eax,0x10(%esp)
  801024:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80102b:	00 
  80102c:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  801033:	00 
  801034:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  801043:	e8 78 f2 ff ff       	call   8002c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801048:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80104e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801051:	89 ec                	mov    %ebp,%esp
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	83 ec 38             	sub    $0x38,%esp
  80105b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80105e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801061:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801064:	bb 00 00 00 00       	mov    $0x0,%ebx
  801069:	b8 09 00 00 00       	mov    $0x9,%eax
  80106e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801071:	8b 55 08             	mov    0x8(%ebp),%edx
  801074:	89 df                	mov    %ebx,%edi
  801076:	89 de                	mov    %ebx,%esi
  801078:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107a:	85 c0                	test   %eax,%eax
  80107c:	7e 28                	jle    8010a6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801082:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801089:	00 
  80108a:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  801091:	00 
  801092:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801099:	00 
  80109a:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  8010a1:	e8 1a f2 ff ff       	call   8002c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010af:	89 ec                	mov    %ebp,%esp
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 0c             	sub    $0xc,%esp
  8010b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c2:	be 00 00 00 00       	mov    $0x0,%esi
  8010c7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e3:	89 ec                	mov    %ebp,%esp
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	83 ec 38             	sub    $0x38,%esp
  8010ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  801100:	8b 55 08             	mov    0x8(%ebp),%edx
  801103:	89 cb                	mov    %ecx,%ebx
  801105:	89 cf                	mov    %ecx,%edi
  801107:	89 ce                	mov    %ecx,%esi
  801109:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80110b:	85 c0                	test   %eax,%eax
  80110d:	7e 28                	jle    801137 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801113:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80111a:	00 
  80111b:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  801122:	00 
  801123:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80112a:	00 
  80112b:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  801132:	e8 89 f1 ff ff       	call   8002c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801137:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80113a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80113d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801140:	89 ec                	mov    %ebp,%esp
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    
	...

00801150 <__udivdi3>:
  801150:	83 ec 1c             	sub    $0x1c,%esp
  801153:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801157:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80115b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80115f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801163:	89 74 24 10          	mov    %esi,0x10(%esp)
  801167:	8b 74 24 24          	mov    0x24(%esp),%esi
  80116b:	85 ff                	test   %edi,%edi
  80116d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801171:	89 44 24 08          	mov    %eax,0x8(%esp)
  801175:	89 cd                	mov    %ecx,%ebp
  801177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117b:	75 33                	jne    8011b0 <__udivdi3+0x60>
  80117d:	39 f1                	cmp    %esi,%ecx
  80117f:	77 57                	ja     8011d8 <__udivdi3+0x88>
  801181:	85 c9                	test   %ecx,%ecx
  801183:	75 0b                	jne    801190 <__udivdi3+0x40>
  801185:	b8 01 00 00 00       	mov    $0x1,%eax
  80118a:	31 d2                	xor    %edx,%edx
  80118c:	f7 f1                	div    %ecx
  80118e:	89 c1                	mov    %eax,%ecx
  801190:	89 f0                	mov    %esi,%eax
  801192:	31 d2                	xor    %edx,%edx
  801194:	f7 f1                	div    %ecx
  801196:	89 c6                	mov    %eax,%esi
  801198:	8b 44 24 04          	mov    0x4(%esp),%eax
  80119c:	f7 f1                	div    %ecx
  80119e:	89 f2                	mov    %esi,%edx
  8011a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011ac:	83 c4 1c             	add    $0x1c,%esp
  8011af:	c3                   	ret    
  8011b0:	31 d2                	xor    %edx,%edx
  8011b2:	31 c0                	xor    %eax,%eax
  8011b4:	39 f7                	cmp    %esi,%edi
  8011b6:	77 e8                	ja     8011a0 <__udivdi3+0x50>
  8011b8:	0f bd cf             	bsr    %edi,%ecx
  8011bb:	83 f1 1f             	xor    $0x1f,%ecx
  8011be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011c2:	75 2c                	jne    8011f0 <__udivdi3+0xa0>
  8011c4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8011c8:	76 04                	jbe    8011ce <__udivdi3+0x7e>
  8011ca:	39 f7                	cmp    %esi,%edi
  8011cc:	73 d2                	jae    8011a0 <__udivdi3+0x50>
  8011ce:	31 d2                	xor    %edx,%edx
  8011d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d5:	eb c9                	jmp    8011a0 <__udivdi3+0x50>
  8011d7:	90                   	nop
  8011d8:	89 f2                	mov    %esi,%edx
  8011da:	f7 f1                	div    %ecx
  8011dc:	31 d2                	xor    %edx,%edx
  8011de:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011e2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011ea:	83 c4 1c             	add    $0x1c,%esp
  8011ed:	c3                   	ret    
  8011ee:	66 90                	xchg   %ax,%ax
  8011f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011f5:	b8 20 00 00 00       	mov    $0x20,%eax
  8011fa:	89 ea                	mov    %ebp,%edx
  8011fc:	2b 44 24 04          	sub    0x4(%esp),%eax
  801200:	d3 e7                	shl    %cl,%edi
  801202:	89 c1                	mov    %eax,%ecx
  801204:	d3 ea                	shr    %cl,%edx
  801206:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80120b:	09 fa                	or     %edi,%edx
  80120d:	89 f7                	mov    %esi,%edi
  80120f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801213:	89 f2                	mov    %esi,%edx
  801215:	8b 74 24 08          	mov    0x8(%esp),%esi
  801219:	d3 e5                	shl    %cl,%ebp
  80121b:	89 c1                	mov    %eax,%ecx
  80121d:	d3 ef                	shr    %cl,%edi
  80121f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801224:	d3 e2                	shl    %cl,%edx
  801226:	89 c1                	mov    %eax,%ecx
  801228:	d3 ee                	shr    %cl,%esi
  80122a:	09 d6                	or     %edx,%esi
  80122c:	89 fa                	mov    %edi,%edx
  80122e:	89 f0                	mov    %esi,%eax
  801230:	f7 74 24 0c          	divl   0xc(%esp)
  801234:	89 d7                	mov    %edx,%edi
  801236:	89 c6                	mov    %eax,%esi
  801238:	f7 e5                	mul    %ebp
  80123a:	39 d7                	cmp    %edx,%edi
  80123c:	72 22                	jb     801260 <__udivdi3+0x110>
  80123e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801242:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801247:	d3 e5                	shl    %cl,%ebp
  801249:	39 c5                	cmp    %eax,%ebp
  80124b:	73 04                	jae    801251 <__udivdi3+0x101>
  80124d:	39 d7                	cmp    %edx,%edi
  80124f:	74 0f                	je     801260 <__udivdi3+0x110>
  801251:	89 f0                	mov    %esi,%eax
  801253:	31 d2                	xor    %edx,%edx
  801255:	e9 46 ff ff ff       	jmp    8011a0 <__udivdi3+0x50>
  80125a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801260:	8d 46 ff             	lea    -0x1(%esi),%eax
  801263:	31 d2                	xor    %edx,%edx
  801265:	8b 74 24 10          	mov    0x10(%esp),%esi
  801269:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80126d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801271:	83 c4 1c             	add    $0x1c,%esp
  801274:	c3                   	ret    
	...

00801280 <__umoddi3>:
  801280:	83 ec 1c             	sub    $0x1c,%esp
  801283:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801287:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80128b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80128f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801293:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801297:	8b 74 24 24          	mov    0x24(%esp),%esi
  80129b:	85 ed                	test   %ebp,%ebp
  80129d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8012a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a5:	89 cf                	mov    %ecx,%edi
  8012a7:	89 04 24             	mov    %eax,(%esp)
  8012aa:	89 f2                	mov    %esi,%edx
  8012ac:	75 1a                	jne    8012c8 <__umoddi3+0x48>
  8012ae:	39 f1                	cmp    %esi,%ecx
  8012b0:	76 4e                	jbe    801300 <__umoddi3+0x80>
  8012b2:	f7 f1                	div    %ecx
  8012b4:	89 d0                	mov    %edx,%eax
  8012b6:	31 d2                	xor    %edx,%edx
  8012b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012c4:	83 c4 1c             	add    $0x1c,%esp
  8012c7:	c3                   	ret    
  8012c8:	39 f5                	cmp    %esi,%ebp
  8012ca:	77 54                	ja     801320 <__umoddi3+0xa0>
  8012cc:	0f bd c5             	bsr    %ebp,%eax
  8012cf:	83 f0 1f             	xor    $0x1f,%eax
  8012d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d6:	75 60                	jne    801338 <__umoddi3+0xb8>
  8012d8:	3b 0c 24             	cmp    (%esp),%ecx
  8012db:	0f 87 07 01 00 00    	ja     8013e8 <__umoddi3+0x168>
  8012e1:	89 f2                	mov    %esi,%edx
  8012e3:	8b 34 24             	mov    (%esp),%esi
  8012e6:	29 ce                	sub    %ecx,%esi
  8012e8:	19 ea                	sbb    %ebp,%edx
  8012ea:	89 34 24             	mov    %esi,(%esp)
  8012ed:	8b 04 24             	mov    (%esp),%eax
  8012f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012fc:	83 c4 1c             	add    $0x1c,%esp
  8012ff:	c3                   	ret    
  801300:	85 c9                	test   %ecx,%ecx
  801302:	75 0b                	jne    80130f <__umoddi3+0x8f>
  801304:	b8 01 00 00 00       	mov    $0x1,%eax
  801309:	31 d2                	xor    %edx,%edx
  80130b:	f7 f1                	div    %ecx
  80130d:	89 c1                	mov    %eax,%ecx
  80130f:	89 f0                	mov    %esi,%eax
  801311:	31 d2                	xor    %edx,%edx
  801313:	f7 f1                	div    %ecx
  801315:	8b 04 24             	mov    (%esp),%eax
  801318:	f7 f1                	div    %ecx
  80131a:	eb 98                	jmp    8012b4 <__umoddi3+0x34>
  80131c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801320:	89 f2                	mov    %esi,%edx
  801322:	8b 74 24 10          	mov    0x10(%esp),%esi
  801326:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80132a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80132e:	83 c4 1c             	add    $0x1c,%esp
  801331:	c3                   	ret    
  801332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801338:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80133d:	89 e8                	mov    %ebp,%eax
  80133f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801344:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801348:	89 fa                	mov    %edi,%edx
  80134a:	d3 e0                	shl    %cl,%eax
  80134c:	89 e9                	mov    %ebp,%ecx
  80134e:	d3 ea                	shr    %cl,%edx
  801350:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801355:	09 c2                	or     %eax,%edx
  801357:	8b 44 24 08          	mov    0x8(%esp),%eax
  80135b:	89 14 24             	mov    %edx,(%esp)
  80135e:	89 f2                	mov    %esi,%edx
  801360:	d3 e7                	shl    %cl,%edi
  801362:	89 e9                	mov    %ebp,%ecx
  801364:	d3 ea                	shr    %cl,%edx
  801366:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80136b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80136f:	d3 e6                	shl    %cl,%esi
  801371:	89 e9                	mov    %ebp,%ecx
  801373:	d3 e8                	shr    %cl,%eax
  801375:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80137a:	09 f0                	or     %esi,%eax
  80137c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801380:	f7 34 24             	divl   (%esp)
  801383:	d3 e6                	shl    %cl,%esi
  801385:	89 74 24 08          	mov    %esi,0x8(%esp)
  801389:	89 d6                	mov    %edx,%esi
  80138b:	f7 e7                	mul    %edi
  80138d:	39 d6                	cmp    %edx,%esi
  80138f:	89 c1                	mov    %eax,%ecx
  801391:	89 d7                	mov    %edx,%edi
  801393:	72 3f                	jb     8013d4 <__umoddi3+0x154>
  801395:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801399:	72 35                	jb     8013d0 <__umoddi3+0x150>
  80139b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80139f:	29 c8                	sub    %ecx,%eax
  8013a1:	19 fe                	sbb    %edi,%esi
  8013a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013a8:	89 f2                	mov    %esi,%edx
  8013aa:	d3 e8                	shr    %cl,%eax
  8013ac:	89 e9                	mov    %ebp,%ecx
  8013ae:	d3 e2                	shl    %cl,%edx
  8013b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013b5:	09 d0                	or     %edx,%eax
  8013b7:	89 f2                	mov    %esi,%edx
  8013b9:	d3 ea                	shr    %cl,%edx
  8013bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013c7:	83 c4 1c             	add    $0x1c,%esp
  8013ca:	c3                   	ret    
  8013cb:	90                   	nop
  8013cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	39 d6                	cmp    %edx,%esi
  8013d2:	75 c7                	jne    80139b <__umoddi3+0x11b>
  8013d4:	89 d7                	mov    %edx,%edi
  8013d6:	89 c1                	mov    %eax,%ecx
  8013d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8013dc:	1b 3c 24             	sbb    (%esp),%edi
  8013df:	eb ba                	jmp    80139b <__umoddi3+0x11b>
  8013e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	39 f5                	cmp    %esi,%ebp
  8013ea:	0f 82 f1 fe ff ff    	jb     8012e1 <__umoddi3+0x61>
  8013f0:	e9 f8 fe ff ff       	jmp    8012ed <__umoddi3+0x6d>
