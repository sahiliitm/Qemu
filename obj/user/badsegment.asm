
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800049:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800052:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800059:	00 00 00 
	envid_t envid = sys_getenvid();
  80005c:	e8 0b 01 00 00       	call   80016c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  800061:	25 ff 03 00 00       	and    $0x3ff,%eax
  800066:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 f6                	test   %esi,%esi
  800075:	7e 07                	jle    80007e <libmain+0x3e>
		binaryname = argv[0];
  800077:	8b 03                	mov    (%ebx),%eax
  800079:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800082:	89 34 24             	mov    %esi,(%esp)
  800085:	e8 aa ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008a:	e8 0d 00 00 00       	call   80009c <exit>
}
  80008f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800092:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800095:	89 ec                	mov    %ebp,%esp
  800097:	5d                   	pop    %ebp
  800098:	c3                   	ret    
  800099:	00 00                	add    %al,(%eax)
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a9:	e8 61 00 00 00       	call   80010f <sys_env_destroy>
}
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000b9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000bc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	89 c3                	mov    %eax,%ebx
  8000cc:	89 c7                	mov    %eax,%edi
  8000ce:	89 c6                	mov    %eax,%esi
  8000d0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000db:	89 ec                	mov    %ebp,%esp
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_cgetc>:

int
sys_cgetc(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 0c             	sub    $0xc,%esp
  8000e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f8:	89 d1                	mov    %edx,%ecx
  8000fa:	89 d3                	mov    %edx,%ebx
  8000fc:	89 d7                	mov    %edx,%edi
  8000fe:	89 d6                	mov    %edx,%esi
  800100:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800102:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800105:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800108:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	83 ec 38             	sub    $0x38,%esp
  800115:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800118:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80011b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800123:	b8 03 00 00 00       	mov    $0x3,%eax
  800128:	8b 55 08             	mov    0x8(%ebp),%edx
  80012b:	89 cb                	mov    %ecx,%ebx
  80012d:	89 cf                	mov    %ecx,%edi
  80012f:	89 ce                	mov    %ecx,%esi
  800131:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800133:	85 c0                	test   %eax,%eax
  800135:	7e 28                	jle    80015f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800137:	89 44 24 10          	mov    %eax,0x10(%esp)
  80013b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800142:	00 
  800143:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  80014a:	00 
  80014b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800152:	00 
  800153:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  80015a:	e8 d5 02 00 00       	call   800434 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800162:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800165:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800168:	89 ec                	mov    %ebp,%esp
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 0c             	sub    $0xc,%esp
  800172:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800175:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800178:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017b:	ba 00 00 00 00       	mov    $0x0,%edx
  800180:	b8 02 00 00 00       	mov    $0x2,%eax
  800185:	89 d1                	mov    %edx,%ecx
  800187:	89 d3                	mov    %edx,%ebx
  800189:	89 d7                	mov    %edx,%edi
  80018b:	89 d6                	mov    %edx,%esi
  80018d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800192:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800195:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800198:	89 ec                	mov    %ebp,%esp
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    

0080019c <sys_yield>:

void
sys_yield(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001a5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001a8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001b5:	89 d1                	mov    %edx,%ecx
  8001b7:	89 d3                	mov    %edx,%ebx
  8001b9:	89 d7                	mov    %edx,%edi
  8001bb:	89 d6                	mov    %edx,%esi
  8001bd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001bf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001c2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c8:	89 ec                	mov    %ebp,%esp
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 38             	sub    $0x38,%esp
  8001d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	be 00 00 00 00       	mov    $0x0,%esi
  8001e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	89 f7                	mov    %esi,%edi
  8001f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7e 28                	jle    80021e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800201:	00 
  800202:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  800209:	00 
  80020a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800211:	00 
  800212:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  800219:	e8 16 02 00 00       	call   800434 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80021e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800221:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800224:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800227:	89 ec                	mov    %ebp,%esp
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 38             	sub    $0x38,%esp
  800231:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800234:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800237:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	b8 05 00 00 00       	mov    $0x5,%eax
  80023f:	8b 75 18             	mov    0x18(%ebp),%esi
  800242:	8b 7d 14             	mov    0x14(%ebp),%edi
  800245:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024b:	8b 55 08             	mov    0x8(%ebp),%edx
  80024e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 28                	jle    80027c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	89 44 24 10          	mov    %eax,0x10(%esp)
  800258:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80025f:	00 
  800260:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  800267:	00 
  800268:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026f:	00 
  800270:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  800277:	e8 b8 01 00 00       	call   800434 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80027c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80027f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800282:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800285:	89 ec                	mov    %ebp,%esp
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 38             	sub    $0x38,%esp
  80028f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800292:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800295:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 06 00 00 00       	mov    $0x6,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	89 de                	mov    %ebx,%esi
  8002ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	7e 28                	jle    8002da <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002bd:	00 
  8002be:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  8002c5:	00 
  8002c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002cd:	00 
  8002ce:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  8002d5:	e8 5a 01 00 00       	call   800434 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002e3:	89 ec                	mov    %ebp,%esp
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	83 ec 38             	sub    $0x38,%esp
  8002ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fb:	b8 08 00 00 00       	mov    $0x8,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	89 df                	mov    %ebx,%edi
  800308:	89 de                	mov    %ebx,%esi
  80030a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80030c:	85 c0                	test   %eax,%eax
  80030e:	7e 28                	jle    800338 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800310:	89 44 24 10          	mov    %eax,0x10(%esp)
  800314:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80031b:	00 
  80031c:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  800323:	00 
  800324:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032b:	00 
  80032c:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  800333:	e8 fc 00 00 00       	call   800434 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800338:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80033b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80033e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800341:	89 ec                	mov    %ebp,%esp
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 38             	sub    $0x38,%esp
  80034b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80034e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800351:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800354:	bb 00 00 00 00       	mov    $0x0,%ebx
  800359:	b8 09 00 00 00       	mov    $0x9,%eax
  80035e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800361:	8b 55 08             	mov    0x8(%ebp),%edx
  800364:	89 df                	mov    %ebx,%edi
  800366:	89 de                	mov    %ebx,%esi
  800368:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80036a:	85 c0                	test   %eax,%eax
  80036c:	7e 28                	jle    800396 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800372:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800379:	00 
  80037a:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  800381:	00 
  800382:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800389:	00 
  80038a:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  800391:	e8 9e 00 00 00       	call   800434 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800396:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800399:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80039c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80039f:	89 ec                	mov    %ebp,%esp
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	83 ec 0c             	sub    $0xc,%esp
  8003a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003af:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b2:	be 00 00 00 00       	mov    $0x0,%esi
  8003b7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003d3:	89 ec                	mov    %ebp,%esp
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	83 ec 38             	sub    $0x38,%esp
  8003dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003eb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f3:	89 cb                	mov    %ecx,%ebx
  8003f5:	89 cf                	mov    %ecx,%edi
  8003f7:	89 ce                	mov    %ecx,%esi
  8003f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003fb:	85 c0                	test   %eax,%eax
  8003fd:	7e 28                	jle    800427 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800403:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80040a:	00 
  80040b:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  800412:	00 
  800413:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80041a:	00 
  80041b:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  800422:	e8 0d 00 00 00       	call   800434 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800427:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80042a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80042d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800430:	89 ec                	mov    %ebp,%esp
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	56                   	push   %esi
  800438:	53                   	push   %ebx
  800439:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80043c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80043f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800445:	e8 22 fd ff ff       	call   80016c <sys_getenvid>
  80044a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800451:	8b 55 08             	mov    0x8(%ebp),%edx
  800454:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800458:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80045c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800460:	c7 04 24 18 12 80 00 	movl   $0x801218,(%esp)
  800467:	e8 c3 00 00 00       	call   80052f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80046c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800470:	8b 45 10             	mov    0x10(%ebp),%eax
  800473:	89 04 24             	mov    %eax,(%esp)
  800476:	e8 53 00 00 00       	call   8004ce <vcprintf>
	cprintf("\n");
  80047b:	c7 04 24 3c 12 80 00 	movl   $0x80123c,(%esp)
  800482:	e8 a8 00 00 00       	call   80052f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800487:	cc                   	int3   
  800488:	eb fd                	jmp    800487 <_panic+0x53>
	...

0080048c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	53                   	push   %ebx
  800490:	83 ec 14             	sub    $0x14,%esp
  800493:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800496:	8b 03                	mov    (%ebx),%eax
  800498:	8b 55 08             	mov    0x8(%ebp),%edx
  80049b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80049f:	83 c0 01             	add    $0x1,%eax
  8004a2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004a9:	75 19                	jne    8004c4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004ab:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004b2:	00 
  8004b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8004b6:	89 04 24             	mov    %eax,(%esp)
  8004b9:	e8 f2 fb ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  8004be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004c8:	83 c4 14             	add    $0x14,%esp
  8004cb:	5b                   	pop    %ebx
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    

008004ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004de:	00 00 00 
	b.cnt = 0;
  8004e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004e8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800503:	c7 04 24 8c 04 80 00 	movl   $0x80048c,(%esp)
  80050a:	e8 d5 01 00 00       	call   8006e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80050f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800515:	89 44 24 04          	mov    %eax,0x4(%esp)
  800519:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	e8 89 fb ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  800527:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80052d:	c9                   	leave  
  80052e:	c3                   	ret    

0080052f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800535:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800538:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053c:	8b 45 08             	mov    0x8(%ebp),%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	e8 87 ff ff ff       	call   8004ce <vcprintf>
	va_end(ap);

	return cnt;
}
  800547:	c9                   	leave  
  800548:	c3                   	ret    
  800549:	00 00                	add    %al,(%eax)
  80054b:	00 00                	add    %al,(%eax)
  80054d:	00 00                	add    %al,(%eax)
	...

00800550 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	57                   	push   %edi
  800554:	56                   	push   %esi
  800555:	53                   	push   %ebx
  800556:	83 ec 3c             	sub    $0x3c,%esp
  800559:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055c:	89 d7                	mov    %edx,%edi
  80055e:	8b 45 08             	mov    0x8(%ebp),%eax
  800561:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800564:	8b 45 0c             	mov    0xc(%ebp),%eax
  800567:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80056d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800570:	b8 00 00 00 00       	mov    $0x0,%eax
  800575:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800578:	72 11                	jb     80058b <printnum+0x3b>
  80057a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80057d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800580:	76 09                	jbe    80058b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800582:	83 eb 01             	sub    $0x1,%ebx
  800585:	85 db                	test   %ebx,%ebx
  800587:	7f 51                	jg     8005da <printnum+0x8a>
  800589:	eb 5e                	jmp    8005e9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80058b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80058f:	83 eb 01             	sub    $0x1,%ebx
  800592:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800596:	8b 45 10             	mov    0x10(%ebp),%eax
  800599:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005a1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ac:	00 
  8005ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ba:	e8 71 09 00 00       	call   800f30 <__udivdi3>
  8005bf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005c3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005c7:	89 04 24             	mov    %eax,(%esp)
  8005ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ce:	89 fa                	mov    %edi,%edx
  8005d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d3:	e8 78 ff ff ff       	call   800550 <printnum>
  8005d8:	eb 0f                	jmp    8005e9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005de:	89 34 24             	mov    %esi,(%esp)
  8005e1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005e4:	83 eb 01             	sub    $0x1,%ebx
  8005e7:	75 f1                	jne    8005da <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ed:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ff:	00 
  800600:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060d:	e8 4e 0a 00 00       	call   801060 <__umoddi3>
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	0f be 80 3e 12 80 00 	movsbl 0x80123e(%eax),%eax
  80061d:	89 04 24             	mov    %eax,(%esp)
  800620:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800623:	83 c4 3c             	add    $0x3c,%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5f                   	pop    %edi
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80062e:	83 fa 01             	cmp    $0x1,%edx
  800631:	7e 0e                	jle    800641 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800633:	8b 10                	mov    (%eax),%edx
  800635:	8d 4a 08             	lea    0x8(%edx),%ecx
  800638:	89 08                	mov    %ecx,(%eax)
  80063a:	8b 02                	mov    (%edx),%eax
  80063c:	8b 52 04             	mov    0x4(%edx),%edx
  80063f:	eb 22                	jmp    800663 <getuint+0x38>
	else if (lflag)
  800641:	85 d2                	test   %edx,%edx
  800643:	74 10                	je     800655 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800645:	8b 10                	mov    (%eax),%edx
  800647:	8d 4a 04             	lea    0x4(%edx),%ecx
  80064a:	89 08                	mov    %ecx,(%eax)
  80064c:	8b 02                	mov    (%edx),%eax
  80064e:	ba 00 00 00 00       	mov    $0x0,%edx
  800653:	eb 0e                	jmp    800663 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800655:	8b 10                	mov    (%eax),%edx
  800657:	8d 4a 04             	lea    0x4(%edx),%ecx
  80065a:	89 08                	mov    %ecx,(%eax)
  80065c:	8b 02                	mov    (%edx),%eax
  80065e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800663:	5d                   	pop    %ebp
  800664:	c3                   	ret    

00800665 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800668:	83 fa 01             	cmp    $0x1,%edx
  80066b:	7e 0e                	jle    80067b <getint+0x16>
		return va_arg(*ap, long long);
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800672:	89 08                	mov    %ecx,(%eax)
  800674:	8b 02                	mov    (%edx),%eax
  800676:	8b 52 04             	mov    0x4(%edx),%edx
  800679:	eb 22                	jmp    80069d <getint+0x38>
	else if (lflag)
  80067b:	85 d2                	test   %edx,%edx
  80067d:	74 10                	je     80068f <getint+0x2a>
		return va_arg(*ap, long);
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	8d 4a 04             	lea    0x4(%edx),%ecx
  800684:	89 08                	mov    %ecx,(%eax)
  800686:	8b 02                	mov    (%edx),%eax
  800688:	89 c2                	mov    %eax,%edx
  80068a:	c1 fa 1f             	sar    $0x1f,%edx
  80068d:	eb 0e                	jmp    80069d <getint+0x38>
	else
		return va_arg(*ap, int);
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	8d 4a 04             	lea    0x4(%edx),%ecx
  800694:	89 08                	mov    %ecx,(%eax)
  800696:	8b 02                	mov    (%edx),%eax
  800698:	89 c2                	mov    %eax,%edx
  80069a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80069d:	5d                   	pop    %ebp
  80069e:	c3                   	ret    

0080069f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006a9:	8b 10                	mov    (%eax),%edx
  8006ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8006ae:	73 0a                	jae    8006ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8006b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b3:	88 0a                	mov    %cl,(%edx)
  8006b5:	83 c2 01             	add    $0x1,%edx
  8006b8:	89 10                	mov    %edx,(%eax)
}
  8006ba:	5d                   	pop    %ebp
  8006bb:	c3                   	ret    

008006bc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	e8 02 00 00 00       	call   8006e4 <vprintfmt>
	va_end(ap);
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	57                   	push   %edi
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
  8006ea:	83 ec 4c             	sub    $0x4c,%esp
  8006ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f0:	8b 75 10             	mov    0x10(%ebp),%esi
  8006f3:	eb 12                	jmp    800707 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	0f 84 77 03 00 00    	je     800a74 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  8006fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800701:	89 04 24             	mov    %eax,(%esp)
  800704:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800707:	0f b6 06             	movzbl (%esi),%eax
  80070a:	83 c6 01             	add    $0x1,%esi
  80070d:	83 f8 25             	cmp    $0x25,%eax
  800710:	75 e3                	jne    8006f5 <vprintfmt+0x11>
  800712:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800716:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80071d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800722:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800729:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800731:	eb 2b                	jmp    80075e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800733:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800736:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80073a:	eb 22                	jmp    80075e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80073f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800743:	eb 19                	jmp    80075e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800748:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80074f:	eb 0d                	jmp    80075e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800751:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800754:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800757:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075e:	0f b6 06             	movzbl (%esi),%eax
  800761:	0f b6 d0             	movzbl %al,%edx
  800764:	8d 7e 01             	lea    0x1(%esi),%edi
  800767:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80076a:	83 e8 23             	sub    $0x23,%eax
  80076d:	3c 55                	cmp    $0x55,%al
  80076f:	0f 87 d9 02 00 00    	ja     800a4e <vprintfmt+0x36a>
  800775:	0f b6 c0             	movzbl %al,%eax
  800778:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80077f:	83 ea 30             	sub    $0x30,%edx
  800782:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800785:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800789:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80078f:	83 fa 09             	cmp    $0x9,%edx
  800792:	77 4a                	ja     8007de <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800794:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800797:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80079a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80079d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8007a1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007a4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007a7:	83 fa 09             	cmp    $0x9,%edx
  8007aa:	76 eb                	jbe    800797 <vprintfmt+0xb3>
  8007ac:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007af:	eb 2d                	jmp    8007de <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8d 50 04             	lea    0x4(%eax),%edx
  8007b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ba:	8b 00                	mov    (%eax),%eax
  8007bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007c2:	eb 1a                	jmp    8007de <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007cb:	79 91                	jns    80075e <vprintfmt+0x7a>
  8007cd:	e9 73 ff ff ff       	jmp    800745 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007d5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007dc:	eb 80                	jmp    80075e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8007de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007e2:	0f 89 76 ff ff ff    	jns    80075e <vprintfmt+0x7a>
  8007e8:	e9 64 ff ff ff       	jmp    800751 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ed:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f3:	e9 66 ff ff ff       	jmp    80075e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8d 50 04             	lea    0x4(%eax),%edx
  8007fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800801:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800805:	8b 00                	mov    (%eax),%eax
  800807:	89 04 24             	mov    %eax,(%esp)
  80080a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800810:	e9 f2 fe ff ff       	jmp    800707 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8d 50 04             	lea    0x4(%eax),%edx
  80081b:	89 55 14             	mov    %edx,0x14(%ebp)
  80081e:	8b 00                	mov    (%eax),%eax
  800820:	89 c2                	mov    %eax,%edx
  800822:	c1 fa 1f             	sar    $0x1f,%edx
  800825:	31 d0                	xor    %edx,%eax
  800827:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800829:	83 f8 08             	cmp    $0x8,%eax
  80082c:	7f 0b                	jg     800839 <vprintfmt+0x155>
  80082e:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800835:	85 d2                	test   %edx,%edx
  800837:	75 23                	jne    80085c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800839:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083d:	c7 44 24 08 56 12 80 	movl   $0x801256,0x8(%esp)
  800844:	00 
  800845:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800849:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084c:	89 3c 24             	mov    %edi,(%esp)
  80084f:	e8 68 fe ff ff       	call   8006bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800854:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800857:	e9 ab fe ff ff       	jmp    800707 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80085c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800860:	c7 44 24 08 5f 12 80 	movl   $0x80125f,0x8(%esp)
  800867:	00 
  800868:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086f:	89 3c 24             	mov    %edi,(%esp)
  800872:	e8 45 fe ff ff       	call   8006bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800877:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80087a:	e9 88 fe ff ff       	jmp    800707 <vprintfmt+0x23>
  80087f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800882:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800885:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800888:	8b 45 14             	mov    0x14(%ebp),%eax
  80088b:	8d 50 04             	lea    0x4(%eax),%edx
  80088e:	89 55 14             	mov    %edx,0x14(%ebp)
  800891:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800893:	85 f6                	test   %esi,%esi
  800895:	ba 4f 12 80 00       	mov    $0x80124f,%edx
  80089a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80089d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008a1:	7e 06                	jle    8008a9 <vprintfmt+0x1c5>
  8008a3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8008a7:	75 10                	jne    8008b9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008a9:	0f be 06             	movsbl (%esi),%eax
  8008ac:	83 c6 01             	add    $0x1,%esi
  8008af:	85 c0                	test   %eax,%eax
  8008b1:	0f 85 86 00 00 00    	jne    80093d <vprintfmt+0x259>
  8008b7:	eb 76                	jmp    80092f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008bd:	89 34 24             	mov    %esi,(%esp)
  8008c0:	e8 56 02 00 00       	call   800b1b <strnlen>
  8008c5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008c8:	29 c2                	sub    %eax,%edx
  8008ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008cd:	85 d2                	test   %edx,%edx
  8008cf:	7e d8                	jle    8008a9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  8008d1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8008d5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8008d8:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8008db:	89 d6                	mov    %edx,%esi
  8008dd:	89 c7                	mov    %eax,%edi
  8008df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e3:	89 3c 24             	mov    %edi,(%esp)
  8008e6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008e9:	83 ee 01             	sub    $0x1,%esi
  8008ec:	75 f1                	jne    8008df <vprintfmt+0x1fb>
  8008ee:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8008f1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8008f4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008f7:	eb b0                	jmp    8008a9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008f9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008fd:	74 18                	je     800917 <vprintfmt+0x233>
  8008ff:	8d 50 e0             	lea    -0x20(%eax),%edx
  800902:	83 fa 5e             	cmp    $0x5e,%edx
  800905:	76 10                	jbe    800917 <vprintfmt+0x233>
					putch('?', putdat);
  800907:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80090b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800912:	ff 55 08             	call   *0x8(%ebp)
  800915:	eb 0a                	jmp    800921 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800917:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091b:	89 04 24             	mov    %eax,(%esp)
  80091e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800921:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800925:	0f be 06             	movsbl (%esi),%eax
  800928:	83 c6 01             	add    $0x1,%esi
  80092b:	85 c0                	test   %eax,%eax
  80092d:	75 0e                	jne    80093d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800932:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800936:	7f 11                	jg     800949 <vprintfmt+0x265>
  800938:	e9 ca fd ff ff       	jmp    800707 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80093d:	85 ff                	test   %edi,%edi
  80093f:	90                   	nop
  800940:	78 b7                	js     8008f9 <vprintfmt+0x215>
  800942:	83 ef 01             	sub    $0x1,%edi
  800945:	79 b2                	jns    8008f9 <vprintfmt+0x215>
  800947:	eb e6                	jmp    80092f <vprintfmt+0x24b>
  800949:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80094c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80094f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800953:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80095a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 ee 01             	sub    $0x1,%esi
  80095f:	75 ee                	jne    80094f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800961:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800964:	e9 9e fd ff ff       	jmp    800707 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800969:	89 ca                	mov    %ecx,%edx
  80096b:	8d 45 14             	lea    0x14(%ebp),%eax
  80096e:	e8 f2 fc ff ff       	call   800665 <getint>
  800973:	89 c6                	mov    %eax,%esi
  800975:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800977:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80097c:	85 d2                	test   %edx,%edx
  80097e:	0f 89 8c 00 00 00    	jns    800a10 <vprintfmt+0x32c>
				putch('-', putdat);
  800984:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800988:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80098f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800992:	f7 de                	neg    %esi
  800994:	83 d7 00             	adc    $0x0,%edi
  800997:	f7 df                	neg    %edi
			}
			base = 10;
  800999:	b8 0a 00 00 00       	mov    $0xa,%eax
  80099e:	eb 70                	jmp    800a10 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009a0:	89 ca                	mov    %ecx,%edx
  8009a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a5:	e8 81 fc ff ff       	call   80062b <getuint>
  8009aa:	89 c6                	mov    %eax,%esi
  8009ac:	89 d7                	mov    %edx,%edi
			base = 10;
  8009ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009b3:	eb 5b                	jmp    800a10 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  8009b5:	89 ca                	mov    %ecx,%edx
  8009b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ba:	e8 a6 fc ff ff       	call   800665 <getint>
  8009bf:	89 c6                	mov    %eax,%esi
  8009c1:	89 d7                	mov    %edx,%edi
			base = 8;
  8009c3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8009c8:	eb 46                	jmp    800a10 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009d5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009dc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e9:	8d 50 04             	lea    0x4(%eax),%edx
  8009ec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009ef:	8b 30                	mov    (%eax),%esi
  8009f1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009f6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009fb:	eb 13                	jmp    800a10 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009fd:	89 ca                	mov    %ecx,%edx
  8009ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800a02:	e8 24 fc ff ff       	call   80062b <getuint>
  800a07:	89 c6                	mov    %eax,%esi
  800a09:	89 d7                	mov    %edx,%edi
			base = 16;
  800a0b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a10:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a14:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a1b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a23:	89 34 24             	mov    %esi,(%esp)
  800a26:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a2a:	89 da                	mov    %ebx,%edx
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	e8 1c fb ff ff       	call   800550 <printnum>
			break;
  800a34:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a37:	e9 cb fc ff ff       	jmp    800707 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a40:	89 14 24             	mov    %edx,(%esp)
  800a43:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a46:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a49:	e9 b9 fc ff ff       	jmp    800707 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a52:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a59:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a5c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a60:	0f 84 a1 fc ff ff    	je     800707 <vprintfmt+0x23>
  800a66:	83 ee 01             	sub    $0x1,%esi
  800a69:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a6d:	75 f7                	jne    800a66 <vprintfmt+0x382>
  800a6f:	e9 93 fc ff ff       	jmp    800707 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a74:	83 c4 4c             	add    $0x4c,%esp
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	83 ec 28             	sub    $0x28,%esp
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
  800a85:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a88:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a8b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a8f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	74 30                	je     800acd <vsnprintf+0x51>
  800a9d:	85 d2                	test   %edx,%edx
  800a9f:	7e 2c                	jle    800acd <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800aa1:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa8:	8b 45 10             	mov    0x10(%ebp),%eax
  800aab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aaf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab6:	c7 04 24 9f 06 80 00 	movl   $0x80069f,(%esp)
  800abd:	e8 22 fc ff ff       	call   8006e4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ac2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ac5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800acb:	eb 05                	jmp    800ad2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800acd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ad2:	c9                   	leave  
  800ad3:	c3                   	ret    

00800ad4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ada:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800add:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	89 04 24             	mov    %eax,(%esp)
  800af5:	e8 82 ff ff ff       	call   800a7c <vsnprintf>
	va_end(ap);

	return rc;
}
  800afa:	c9                   	leave  
  800afb:	c3                   	ret    
  800afc:	00 00                	add    %al,(%eax)
	...

00800b00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b0e:	74 09                	je     800b19 <strlen+0x19>
		n++;
  800b10:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b13:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b17:	75 f7                	jne    800b10 <strlen+0x10>
		n++;
	return n;
}
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	53                   	push   %ebx
  800b1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2a:	85 c9                	test   %ecx,%ecx
  800b2c:	74 1a                	je     800b48 <strnlen+0x2d>
  800b2e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b31:	74 15                	je     800b48 <strnlen+0x2d>
  800b33:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800b38:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b3a:	39 ca                	cmp    %ecx,%edx
  800b3c:	74 0a                	je     800b48 <strnlen+0x2d>
  800b3e:	83 c2 01             	add    $0x1,%edx
  800b41:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800b46:	75 f0                	jne    800b38 <strnlen+0x1d>
		n++;
	return n;
}
  800b48:	5b                   	pop    %ebx
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	53                   	push   %ebx
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b5e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b61:	83 c2 01             	add    $0x1,%edx
  800b64:	84 c9                	test   %cl,%cl
  800b66:	75 f2                	jne    800b5a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b68:	5b                   	pop    %ebx
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 08             	sub    $0x8,%esp
  800b72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b75:	89 1c 24             	mov    %ebx,(%esp)
  800b78:	e8 83 ff ff ff       	call   800b00 <strlen>
	strcpy(dst + len, src);
  800b7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b80:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b84:	01 d8                	add    %ebx,%eax
  800b86:	89 04 24             	mov    %eax,(%esp)
  800b89:	e8 bd ff ff ff       	call   800b4b <strcpy>
	return dst;
}
  800b8e:	89 d8                	mov    %ebx,%eax
  800b90:	83 c4 08             	add    $0x8,%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba4:	85 f6                	test   %esi,%esi
  800ba6:	74 18                	je     800bc0 <strncpy+0x2a>
  800ba8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bad:	0f b6 1a             	movzbl (%edx),%ebx
  800bb0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bb3:	80 3a 01             	cmpb   $0x1,(%edx)
  800bb6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb9:	83 c1 01             	add    $0x1,%ecx
  800bbc:	39 f1                	cmp    %esi,%ecx
  800bbe:	75 ed                	jne    800bad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bd0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bd3:	89 f8                	mov    %edi,%eax
  800bd5:	85 f6                	test   %esi,%esi
  800bd7:	74 2b                	je     800c04 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800bd9:	83 fe 01             	cmp    $0x1,%esi
  800bdc:	74 23                	je     800c01 <strlcpy+0x3d>
  800bde:	0f b6 0b             	movzbl (%ebx),%ecx
  800be1:	84 c9                	test   %cl,%cl
  800be3:	74 1c                	je     800c01 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800be5:	83 ee 02             	sub    $0x2,%esi
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bed:	88 08                	mov    %cl,(%eax)
  800bef:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bf2:	39 f2                	cmp    %esi,%edx
  800bf4:	74 0b                	je     800c01 <strlcpy+0x3d>
  800bf6:	83 c2 01             	add    $0x1,%edx
  800bf9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bfd:	84 c9                	test   %cl,%cl
  800bff:	75 ec                	jne    800bed <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800c01:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c04:	29 f8                	sub    %edi,%eax
}
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c11:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c14:	0f b6 01             	movzbl (%ecx),%eax
  800c17:	84 c0                	test   %al,%al
  800c19:	74 16                	je     800c31 <strcmp+0x26>
  800c1b:	3a 02                	cmp    (%edx),%al
  800c1d:	75 12                	jne    800c31 <strcmp+0x26>
		p++, q++;
  800c1f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c22:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800c26:	84 c0                	test   %al,%al
  800c28:	74 07                	je     800c31 <strcmp+0x26>
  800c2a:	83 c1 01             	add    $0x1,%ecx
  800c2d:	3a 02                	cmp    (%edx),%al
  800c2f:	74 ee                	je     800c1f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c31:	0f b6 c0             	movzbl %al,%eax
  800c34:	0f b6 12             	movzbl (%edx),%edx
  800c37:	29 d0                	sub    %edx,%eax
}
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	53                   	push   %ebx
  800c3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c45:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c48:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c4d:	85 d2                	test   %edx,%edx
  800c4f:	74 28                	je     800c79 <strncmp+0x3e>
  800c51:	0f b6 01             	movzbl (%ecx),%eax
  800c54:	84 c0                	test   %al,%al
  800c56:	74 24                	je     800c7c <strncmp+0x41>
  800c58:	3a 03                	cmp    (%ebx),%al
  800c5a:	75 20                	jne    800c7c <strncmp+0x41>
  800c5c:	83 ea 01             	sub    $0x1,%edx
  800c5f:	74 13                	je     800c74 <strncmp+0x39>
		n--, p++, q++;
  800c61:	83 c1 01             	add    $0x1,%ecx
  800c64:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c67:	0f b6 01             	movzbl (%ecx),%eax
  800c6a:	84 c0                	test   %al,%al
  800c6c:	74 0e                	je     800c7c <strncmp+0x41>
  800c6e:	3a 03                	cmp    (%ebx),%al
  800c70:	74 ea                	je     800c5c <strncmp+0x21>
  800c72:	eb 08                	jmp    800c7c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c74:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c7c:	0f b6 01             	movzbl (%ecx),%eax
  800c7f:	0f b6 13             	movzbl (%ebx),%edx
  800c82:	29 d0                	sub    %edx,%eax
  800c84:	eb f3                	jmp    800c79 <strncmp+0x3e>

00800c86 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c90:	0f b6 10             	movzbl (%eax),%edx
  800c93:	84 d2                	test   %dl,%dl
  800c95:	74 1c                	je     800cb3 <strchr+0x2d>
		if (*s == c)
  800c97:	38 ca                	cmp    %cl,%dl
  800c99:	75 09                	jne    800ca4 <strchr+0x1e>
  800c9b:	eb 1b                	jmp    800cb8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c9d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800ca0:	38 ca                	cmp    %cl,%dl
  800ca2:	74 14                	je     800cb8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ca4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800ca8:	84 d2                	test   %dl,%dl
  800caa:	75 f1                	jne    800c9d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800cac:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb1:	eb 05                	jmp    800cb8 <strchr+0x32>
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc4:	0f b6 10             	movzbl (%eax),%edx
  800cc7:	84 d2                	test   %dl,%dl
  800cc9:	74 14                	je     800cdf <strfind+0x25>
		if (*s == c)
  800ccb:	38 ca                	cmp    %cl,%dl
  800ccd:	75 06                	jne    800cd5 <strfind+0x1b>
  800ccf:	eb 0e                	jmp    800cdf <strfind+0x25>
  800cd1:	38 ca                	cmp    %cl,%dl
  800cd3:	74 0a                	je     800cdf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cd5:	83 c0 01             	add    $0x1,%eax
  800cd8:	0f b6 10             	movzbl (%eax),%edx
  800cdb:	84 d2                	test   %dl,%dl
  800cdd:	75 f2                	jne    800cd1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ced:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cf0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cf9:	85 c9                	test   %ecx,%ecx
  800cfb:	74 30                	je     800d2d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cfd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d03:	75 25                	jne    800d2a <memset+0x49>
  800d05:	f6 c1 03             	test   $0x3,%cl
  800d08:	75 20                	jne    800d2a <memset+0x49>
		c &= 0xFF;
  800d0a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d0d:	89 d3                	mov    %edx,%ebx
  800d0f:	c1 e3 08             	shl    $0x8,%ebx
  800d12:	89 d6                	mov    %edx,%esi
  800d14:	c1 e6 18             	shl    $0x18,%esi
  800d17:	89 d0                	mov    %edx,%eax
  800d19:	c1 e0 10             	shl    $0x10,%eax
  800d1c:	09 f0                	or     %esi,%eax
  800d1e:	09 d0                	or     %edx,%eax
  800d20:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d22:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d25:	fc                   	cld    
  800d26:	f3 ab                	rep stos %eax,%es:(%edi)
  800d28:	eb 03                	jmp    800d2d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d2a:	fc                   	cld    
  800d2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d2d:	89 f8                	mov    %edi,%eax
  800d2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d38:	89 ec                	mov    %ebp,%esp
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 08             	sub    $0x8,%esp
  800d42:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d45:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d51:	39 c6                	cmp    %eax,%esi
  800d53:	73 36                	jae    800d8b <memmove+0x4f>
  800d55:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d58:	39 d0                	cmp    %edx,%eax
  800d5a:	73 2f                	jae    800d8b <memmove+0x4f>
		s += n;
		d += n;
  800d5c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d5f:	f6 c2 03             	test   $0x3,%dl
  800d62:	75 1b                	jne    800d7f <memmove+0x43>
  800d64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d6a:	75 13                	jne    800d7f <memmove+0x43>
  800d6c:	f6 c1 03             	test   $0x3,%cl
  800d6f:	75 0e                	jne    800d7f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d71:	83 ef 04             	sub    $0x4,%edi
  800d74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d77:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d7a:	fd                   	std    
  800d7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d7d:	eb 09                	jmp    800d88 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d7f:	83 ef 01             	sub    $0x1,%edi
  800d82:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d85:	fd                   	std    
  800d86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d88:	fc                   	cld    
  800d89:	eb 20                	jmp    800dab <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d8b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d91:	75 13                	jne    800da6 <memmove+0x6a>
  800d93:	a8 03                	test   $0x3,%al
  800d95:	75 0f                	jne    800da6 <memmove+0x6a>
  800d97:	f6 c1 03             	test   $0x3,%cl
  800d9a:	75 0a                	jne    800da6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d9c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d9f:	89 c7                	mov    %eax,%edi
  800da1:	fc                   	cld    
  800da2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800da4:	eb 05                	jmp    800dab <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800da6:	89 c7                	mov    %eax,%edi
  800da8:	fc                   	cld    
  800da9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db1:	89 ec                	mov    %ebp,%esp
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dbb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	89 04 24             	mov    %eax,(%esp)
  800dcf:	e8 68 ff ff ff       	call   800d3c <memmove>
}
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    

00800dd6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
  800ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ddf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800de5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dea:	85 ff                	test   %edi,%edi
  800dec:	74 37                	je     800e25 <memcmp+0x4f>
		if (*s1 != *s2)
  800dee:	0f b6 03             	movzbl (%ebx),%eax
  800df1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800df4:	83 ef 01             	sub    $0x1,%edi
  800df7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800dfc:	38 c8                	cmp    %cl,%al
  800dfe:	74 1c                	je     800e1c <memcmp+0x46>
  800e00:	eb 10                	jmp    800e12 <memcmp+0x3c>
  800e02:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e07:	83 c2 01             	add    $0x1,%edx
  800e0a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e0e:	38 c8                	cmp    %cl,%al
  800e10:	74 0a                	je     800e1c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800e12:	0f b6 c0             	movzbl %al,%eax
  800e15:	0f b6 c9             	movzbl %cl,%ecx
  800e18:	29 c8                	sub    %ecx,%eax
  800e1a:	eb 09                	jmp    800e25 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e1c:	39 fa                	cmp    %edi,%edx
  800e1e:	75 e2                	jne    800e02 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e30:	89 c2                	mov    %eax,%edx
  800e32:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e35:	39 d0                	cmp    %edx,%eax
  800e37:	73 19                	jae    800e52 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e39:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e3d:	38 08                	cmp    %cl,(%eax)
  800e3f:	75 06                	jne    800e47 <memfind+0x1d>
  800e41:	eb 0f                	jmp    800e52 <memfind+0x28>
  800e43:	38 08                	cmp    %cl,(%eax)
  800e45:	74 0b                	je     800e52 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e47:	83 c0 01             	add    $0x1,%eax
  800e4a:	39 d0                	cmp    %edx,%eax
  800e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e50:	75 f1                	jne    800e43 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e60:	0f b6 02             	movzbl (%edx),%eax
  800e63:	3c 20                	cmp    $0x20,%al
  800e65:	74 04                	je     800e6b <strtol+0x17>
  800e67:	3c 09                	cmp    $0x9,%al
  800e69:	75 0e                	jne    800e79 <strtol+0x25>
		s++;
  800e6b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e6e:	0f b6 02             	movzbl (%edx),%eax
  800e71:	3c 20                	cmp    $0x20,%al
  800e73:	74 f6                	je     800e6b <strtol+0x17>
  800e75:	3c 09                	cmp    $0x9,%al
  800e77:	74 f2                	je     800e6b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e79:	3c 2b                	cmp    $0x2b,%al
  800e7b:	75 0a                	jne    800e87 <strtol+0x33>
		s++;
  800e7d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e80:	bf 00 00 00 00       	mov    $0x0,%edi
  800e85:	eb 10                	jmp    800e97 <strtol+0x43>
  800e87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e8c:	3c 2d                	cmp    $0x2d,%al
  800e8e:	75 07                	jne    800e97 <strtol+0x43>
		s++, neg = 1;
  800e90:	83 c2 01             	add    $0x1,%edx
  800e93:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e97:	85 db                	test   %ebx,%ebx
  800e99:	0f 94 c0             	sete   %al
  800e9c:	74 05                	je     800ea3 <strtol+0x4f>
  800e9e:	83 fb 10             	cmp    $0x10,%ebx
  800ea1:	75 15                	jne    800eb8 <strtol+0x64>
  800ea3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ea6:	75 10                	jne    800eb8 <strtol+0x64>
  800ea8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800eac:	75 0a                	jne    800eb8 <strtol+0x64>
		s += 2, base = 16;
  800eae:	83 c2 02             	add    $0x2,%edx
  800eb1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800eb6:	eb 13                	jmp    800ecb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800eb8:	84 c0                	test   %al,%al
  800eba:	74 0f                	je     800ecb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ebc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ec1:	80 3a 30             	cmpb   $0x30,(%edx)
  800ec4:	75 05                	jne    800ecb <strtol+0x77>
		s++, base = 8;
  800ec6:	83 c2 01             	add    $0x1,%edx
  800ec9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ecb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ed2:	0f b6 0a             	movzbl (%edx),%ecx
  800ed5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ed8:	80 fb 09             	cmp    $0x9,%bl
  800edb:	77 08                	ja     800ee5 <strtol+0x91>
			dig = *s - '0';
  800edd:	0f be c9             	movsbl %cl,%ecx
  800ee0:	83 e9 30             	sub    $0x30,%ecx
  800ee3:	eb 1e                	jmp    800f03 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800ee5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ee8:	80 fb 19             	cmp    $0x19,%bl
  800eeb:	77 08                	ja     800ef5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800eed:	0f be c9             	movsbl %cl,%ecx
  800ef0:	83 e9 57             	sub    $0x57,%ecx
  800ef3:	eb 0e                	jmp    800f03 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800ef5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ef8:	80 fb 19             	cmp    $0x19,%bl
  800efb:	77 14                	ja     800f11 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800efd:	0f be c9             	movsbl %cl,%ecx
  800f00:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f03:	39 f1                	cmp    %esi,%ecx
  800f05:	7d 0e                	jge    800f15 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800f07:	83 c2 01             	add    $0x1,%edx
  800f0a:	0f af c6             	imul   %esi,%eax
  800f0d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f0f:	eb c1                	jmp    800ed2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f11:	89 c1                	mov    %eax,%ecx
  800f13:	eb 02                	jmp    800f17 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f15:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f1b:	74 05                	je     800f22 <strtol+0xce>
		*endptr = (char *) s;
  800f1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f20:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f22:	89 ca                	mov    %ecx,%edx
  800f24:	f7 da                	neg    %edx
  800f26:	85 ff                	test   %edi,%edi
  800f28:	0f 45 c2             	cmovne %edx,%eax
}
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <__udivdi3>:
  800f30:	83 ec 1c             	sub    $0x1c,%esp
  800f33:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f37:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f3b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f3f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f43:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f47:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f4b:	85 ff                	test   %edi,%edi
  800f4d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f55:	89 cd                	mov    %ecx,%ebp
  800f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5b:	75 33                	jne    800f90 <__udivdi3+0x60>
  800f5d:	39 f1                	cmp    %esi,%ecx
  800f5f:	77 57                	ja     800fb8 <__udivdi3+0x88>
  800f61:	85 c9                	test   %ecx,%ecx
  800f63:	75 0b                	jne    800f70 <__udivdi3+0x40>
  800f65:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6a:	31 d2                	xor    %edx,%edx
  800f6c:	f7 f1                	div    %ecx
  800f6e:	89 c1                	mov    %eax,%ecx
  800f70:	89 f0                	mov    %esi,%eax
  800f72:	31 d2                	xor    %edx,%edx
  800f74:	f7 f1                	div    %ecx
  800f76:	89 c6                	mov    %eax,%esi
  800f78:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f7c:	f7 f1                	div    %ecx
  800f7e:	89 f2                	mov    %esi,%edx
  800f80:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f84:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f88:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f8c:	83 c4 1c             	add    $0x1c,%esp
  800f8f:	c3                   	ret    
  800f90:	31 d2                	xor    %edx,%edx
  800f92:	31 c0                	xor    %eax,%eax
  800f94:	39 f7                	cmp    %esi,%edi
  800f96:	77 e8                	ja     800f80 <__udivdi3+0x50>
  800f98:	0f bd cf             	bsr    %edi,%ecx
  800f9b:	83 f1 1f             	xor    $0x1f,%ecx
  800f9e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fa2:	75 2c                	jne    800fd0 <__udivdi3+0xa0>
  800fa4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fa8:	76 04                	jbe    800fae <__udivdi3+0x7e>
  800faa:	39 f7                	cmp    %esi,%edi
  800fac:	73 d2                	jae    800f80 <__udivdi3+0x50>
  800fae:	31 d2                	xor    %edx,%edx
  800fb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb5:	eb c9                	jmp    800f80 <__udivdi3+0x50>
  800fb7:	90                   	nop
  800fb8:	89 f2                	mov    %esi,%edx
  800fba:	f7 f1                	div    %ecx
  800fbc:	31 d2                	xor    %edx,%edx
  800fbe:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fc2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fc6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fca:	83 c4 1c             	add    $0x1c,%esp
  800fcd:	c3                   	ret    
  800fce:	66 90                	xchg   %ax,%ax
  800fd0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fd5:	b8 20 00 00 00       	mov    $0x20,%eax
  800fda:	89 ea                	mov    %ebp,%edx
  800fdc:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fe0:	d3 e7                	shl    %cl,%edi
  800fe2:	89 c1                	mov    %eax,%ecx
  800fe4:	d3 ea                	shr    %cl,%edx
  800fe6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800feb:	09 fa                	or     %edi,%edx
  800fed:	89 f7                	mov    %esi,%edi
  800fef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ff9:	d3 e5                	shl    %cl,%ebp
  800ffb:	89 c1                	mov    %eax,%ecx
  800ffd:	d3 ef                	shr    %cl,%edi
  800fff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801004:	d3 e2                	shl    %cl,%edx
  801006:	89 c1                	mov    %eax,%ecx
  801008:	d3 ee                	shr    %cl,%esi
  80100a:	09 d6                	or     %edx,%esi
  80100c:	89 fa                	mov    %edi,%edx
  80100e:	89 f0                	mov    %esi,%eax
  801010:	f7 74 24 0c          	divl   0xc(%esp)
  801014:	89 d7                	mov    %edx,%edi
  801016:	89 c6                	mov    %eax,%esi
  801018:	f7 e5                	mul    %ebp
  80101a:	39 d7                	cmp    %edx,%edi
  80101c:	72 22                	jb     801040 <__udivdi3+0x110>
  80101e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801022:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801027:	d3 e5                	shl    %cl,%ebp
  801029:	39 c5                	cmp    %eax,%ebp
  80102b:	73 04                	jae    801031 <__udivdi3+0x101>
  80102d:	39 d7                	cmp    %edx,%edi
  80102f:	74 0f                	je     801040 <__udivdi3+0x110>
  801031:	89 f0                	mov    %esi,%eax
  801033:	31 d2                	xor    %edx,%edx
  801035:	e9 46 ff ff ff       	jmp    800f80 <__udivdi3+0x50>
  80103a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801040:	8d 46 ff             	lea    -0x1(%esi),%eax
  801043:	31 d2                	xor    %edx,%edx
  801045:	8b 74 24 10          	mov    0x10(%esp),%esi
  801049:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80104d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801051:	83 c4 1c             	add    $0x1c,%esp
  801054:	c3                   	ret    
	...

00801060 <__umoddi3>:
  801060:	83 ec 1c             	sub    $0x1c,%esp
  801063:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801067:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80106b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80106f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801073:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801077:	8b 74 24 24          	mov    0x24(%esp),%esi
  80107b:	85 ed                	test   %ebp,%ebp
  80107d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801081:	89 44 24 08          	mov    %eax,0x8(%esp)
  801085:	89 cf                	mov    %ecx,%edi
  801087:	89 04 24             	mov    %eax,(%esp)
  80108a:	89 f2                	mov    %esi,%edx
  80108c:	75 1a                	jne    8010a8 <__umoddi3+0x48>
  80108e:	39 f1                	cmp    %esi,%ecx
  801090:	76 4e                	jbe    8010e0 <__umoddi3+0x80>
  801092:	f7 f1                	div    %ecx
  801094:	89 d0                	mov    %edx,%eax
  801096:	31 d2                	xor    %edx,%edx
  801098:	8b 74 24 10          	mov    0x10(%esp),%esi
  80109c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010a0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010a4:	83 c4 1c             	add    $0x1c,%esp
  8010a7:	c3                   	ret    
  8010a8:	39 f5                	cmp    %esi,%ebp
  8010aa:	77 54                	ja     801100 <__umoddi3+0xa0>
  8010ac:	0f bd c5             	bsr    %ebp,%eax
  8010af:	83 f0 1f             	xor    $0x1f,%eax
  8010b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b6:	75 60                	jne    801118 <__umoddi3+0xb8>
  8010b8:	3b 0c 24             	cmp    (%esp),%ecx
  8010bb:	0f 87 07 01 00 00    	ja     8011c8 <__umoddi3+0x168>
  8010c1:	89 f2                	mov    %esi,%edx
  8010c3:	8b 34 24             	mov    (%esp),%esi
  8010c6:	29 ce                	sub    %ecx,%esi
  8010c8:	19 ea                	sbb    %ebp,%edx
  8010ca:	89 34 24             	mov    %esi,(%esp)
  8010cd:	8b 04 24             	mov    (%esp),%eax
  8010d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010dc:	83 c4 1c             	add    $0x1c,%esp
  8010df:	c3                   	ret    
  8010e0:	85 c9                	test   %ecx,%ecx
  8010e2:	75 0b                	jne    8010ef <__umoddi3+0x8f>
  8010e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e9:	31 d2                	xor    %edx,%edx
  8010eb:	f7 f1                	div    %ecx
  8010ed:	89 c1                	mov    %eax,%ecx
  8010ef:	89 f0                	mov    %esi,%eax
  8010f1:	31 d2                	xor    %edx,%edx
  8010f3:	f7 f1                	div    %ecx
  8010f5:	8b 04 24             	mov    (%esp),%eax
  8010f8:	f7 f1                	div    %ecx
  8010fa:	eb 98                	jmp    801094 <__umoddi3+0x34>
  8010fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801100:	89 f2                	mov    %esi,%edx
  801102:	8b 74 24 10          	mov    0x10(%esp),%esi
  801106:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80110a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80110e:	83 c4 1c             	add    $0x1c,%esp
  801111:	c3                   	ret    
  801112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801118:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80111d:	89 e8                	mov    %ebp,%eax
  80111f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801124:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801128:	89 fa                	mov    %edi,%edx
  80112a:	d3 e0                	shl    %cl,%eax
  80112c:	89 e9                	mov    %ebp,%ecx
  80112e:	d3 ea                	shr    %cl,%edx
  801130:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801135:	09 c2                	or     %eax,%edx
  801137:	8b 44 24 08          	mov    0x8(%esp),%eax
  80113b:	89 14 24             	mov    %edx,(%esp)
  80113e:	89 f2                	mov    %esi,%edx
  801140:	d3 e7                	shl    %cl,%edi
  801142:	89 e9                	mov    %ebp,%ecx
  801144:	d3 ea                	shr    %cl,%edx
  801146:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80114b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80114f:	d3 e6                	shl    %cl,%esi
  801151:	89 e9                	mov    %ebp,%ecx
  801153:	d3 e8                	shr    %cl,%eax
  801155:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115a:	09 f0                	or     %esi,%eax
  80115c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801160:	f7 34 24             	divl   (%esp)
  801163:	d3 e6                	shl    %cl,%esi
  801165:	89 74 24 08          	mov    %esi,0x8(%esp)
  801169:	89 d6                	mov    %edx,%esi
  80116b:	f7 e7                	mul    %edi
  80116d:	39 d6                	cmp    %edx,%esi
  80116f:	89 c1                	mov    %eax,%ecx
  801171:	89 d7                	mov    %edx,%edi
  801173:	72 3f                	jb     8011b4 <__umoddi3+0x154>
  801175:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801179:	72 35                	jb     8011b0 <__umoddi3+0x150>
  80117b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80117f:	29 c8                	sub    %ecx,%eax
  801181:	19 fe                	sbb    %edi,%esi
  801183:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801188:	89 f2                	mov    %esi,%edx
  80118a:	d3 e8                	shr    %cl,%eax
  80118c:	89 e9                	mov    %ebp,%ecx
  80118e:	d3 e2                	shl    %cl,%edx
  801190:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801195:	09 d0                	or     %edx,%eax
  801197:	89 f2                	mov    %esi,%edx
  801199:	d3 ea                	shr    %cl,%edx
  80119b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80119f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011a3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011a7:	83 c4 1c             	add    $0x1c,%esp
  8011aa:	c3                   	ret    
  8011ab:	90                   	nop
  8011ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	39 d6                	cmp    %edx,%esi
  8011b2:	75 c7                	jne    80117b <__umoddi3+0x11b>
  8011b4:	89 d7                	mov    %edx,%edi
  8011b6:	89 c1                	mov    %eax,%ecx
  8011b8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011bc:	1b 3c 24             	sbb    (%esp),%edi
  8011bf:	eb ba                	jmp    80117b <__umoddi3+0x11b>
  8011c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	39 f5                	cmp    %esi,%ebp
  8011ca:	0f 82 f1 fe ff ff    	jb     8010c1 <__umoddi3+0x61>
  8011d0:	e9 f8 fe ff ff       	jmp    8010cd <__umoddi3+0x6d>
