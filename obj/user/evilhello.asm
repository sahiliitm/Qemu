
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 72 00 00 00       	call   8000c0 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800062:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800069:	00 00 00 
	envid_t envid = sys_getenvid();
  80006c:	e8 0b 01 00 00       	call   80017c <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  800071:	25 ff 03 00 00       	and    $0x3ff,%eax
  800076:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 f6                	test   %esi,%esi
  800085:	7e 07                	jle    80008e <libmain+0x3e>
		binaryname = argv[0];
  800087:	8b 03                	mov    (%ebx),%eax
  800089:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800092:	89 34 24             	mov    %esi,(%esp)
  800095:	e8 9a ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009a:	e8 0d 00 00 00       	call   8000ac <exit>
}
  80009f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a5:	89 ec                	mov    %ebp,%esp
  8000a7:	5d                   	pop    %ebp
  8000a8:	c3                   	ret    
  8000a9:	00 00                	add    %al,(%eax)
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 61 00 00 00       	call   80011f <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000da:	89 c3                	mov    %eax,%ebx
  8000dc:	89 c7                	mov    %eax,%edi
  8000de:	89 c6                	mov    %eax,%esi
  8000e0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000e5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800103:	b8 01 00 00 00       	mov    $0x1,%eax
  800108:	89 d1                	mov    %edx,%ecx
  80010a:	89 d3                	mov    %edx,%ebx
  80010c:	89 d7                	mov    %edx,%edi
  80010e:	89 d6                	mov    %edx,%esi
  800110:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800112:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800115:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800118:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80011b:	89 ec                	mov    %ebp,%esp
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	83 ec 38             	sub    $0x38,%esp
  800125:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800128:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80012b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800133:	b8 03 00 00 00       	mov    $0x3,%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	89 cb                	mov    %ecx,%ebx
  80013d:	89 cf                	mov    %ecx,%edi
  80013f:	89 ce                	mov    %ecx,%esi
  800141:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800143:	85 c0                	test   %eax,%eax
  800145:	7e 28                	jle    80016f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800147:	89 44 24 10          	mov    %eax,0x10(%esp)
  80014b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800152:	00 
  800153:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  80016a:	e8 d5 02 00 00       	call   800444 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80016f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800172:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800175:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800178:	89 ec                	mov    %ebp,%esp
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800185:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800188:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018b:	ba 00 00 00 00       	mov    $0x0,%edx
  800190:	b8 02 00 00 00       	mov    $0x2,%eax
  800195:	89 d1                	mov    %edx,%ecx
  800197:	89 d3                	mov    %edx,%ebx
  800199:	89 d7                	mov    %edx,%edi
  80019b:	89 d6                	mov    %edx,%esi
  80019d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80019f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001a2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a8:	89 ec                	mov    %ebp,%esp
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    

008001ac <sys_yield>:

void
sys_yield(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001c5:	89 d1                	mov    %edx,%ecx
  8001c7:	89 d3                	mov    %edx,%ebx
  8001c9:	89 d7                	mov    %edx,%edi
  8001cb:	89 d6                	mov    %edx,%esi
  8001cd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d8:	89 ec                	mov    %ebp,%esp
  8001da:	5d                   	pop    %ebp
  8001db:	c3                   	ret    

008001dc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 38             	sub    $0x38,%esp
  8001e2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001e5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001e8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001eb:	be 00 00 00 00       	mov    $0x0,%esi
  8001f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	89 f7                	mov    %esi,%edi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 28                	jle    80022e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800211:	00 
  800212:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  800219:	00 
  80021a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800221:	00 
  800222:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  800229:	e8 16 02 00 00       	call   800444 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80022e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800231:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800234:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800237:	89 ec                	mov    %ebp,%esp
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 38             	sub    $0x38,%esp
  800241:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800244:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800247:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024a:	b8 05 00 00 00       	mov    $0x5,%eax
  80024f:	8b 75 18             	mov    0x18(%ebp),%esi
  800252:	8b 7d 14             	mov    0x14(%ebp),%edi
  800255:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800258:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025b:	8b 55 08             	mov    0x8(%ebp),%edx
  80025e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800260:	85 c0                	test   %eax,%eax
  800262:	7e 28                	jle    80028c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800264:	89 44 24 10          	mov    %eax,0x10(%esp)
  800268:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80026f:	00 
  800270:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  800277:	00 
  800278:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027f:	00 
  800280:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  800287:	e8 b8 01 00 00       	call   800444 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80028c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80028f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800292:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800295:	89 ec                	mov    %ebp,%esp
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 38             	sub    $0x38,%esp
  80029f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002a2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002a5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	89 df                	mov    %ebx,%edi
  8002ba:	89 de                	mov    %ebx,%esi
  8002bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	7e 28                	jle    8002ea <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002dd:	00 
  8002de:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  8002e5:	e8 5a 01 00 00       	call   800444 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002ed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002f0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002f3:	89 ec                	mov    %ebp,%esp
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	83 ec 38             	sub    $0x38,%esp
  8002fd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800300:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800303:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800306:	bb 00 00 00 00       	mov    $0x0,%ebx
  80030b:	b8 08 00 00 00       	mov    $0x8,%eax
  800310:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	89 df                	mov    %ebx,%edi
  800318:	89 de                	mov    %ebx,%esi
  80031a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80031c:	85 c0                	test   %eax,%eax
  80031e:	7e 28                	jle    800348 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800320:	89 44 24 10          	mov    %eax,0x10(%esp)
  800324:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80032b:	00 
  80032c:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  800333:	00 
  800334:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033b:	00 
  80033c:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  800343:	e8 fc 00 00 00       	call   800444 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800348:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80034b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80034e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800351:	89 ec                	mov    %ebp,%esp
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	83 ec 38             	sub    $0x38,%esp
  80035b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80035e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800361:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800364:	bb 00 00 00 00       	mov    $0x0,%ebx
  800369:	b8 09 00 00 00       	mov    $0x9,%eax
  80036e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800371:	8b 55 08             	mov    0x8(%ebp),%edx
  800374:	89 df                	mov    %ebx,%edi
  800376:	89 de                	mov    %ebx,%esi
  800378:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80037a:	85 c0                	test   %eax,%eax
  80037c:	7e 28                	jle    8003a6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80037e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800382:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800389:	00 
  80038a:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  800391:	00 
  800392:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800399:	00 
  80039a:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  8003a1:	e8 9e 00 00 00       	call   800444 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003af:	89 ec                	mov    %ebp,%esp
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	83 ec 0c             	sub    $0xc,%esp
  8003b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c2:	be 00 00 00 00       	mov    $0x0,%esi
  8003c7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003e3:	89 ec                	mov    %ebp,%esp
  8003e5:	5d                   	pop    %ebp
  8003e6:	c3                   	ret    

008003e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	83 ec 38             	sub    $0x38,%esp
  8003ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800400:	8b 55 08             	mov    0x8(%ebp),%edx
  800403:	89 cb                	mov    %ecx,%ebx
  800405:	89 cf                	mov    %ecx,%edi
  800407:	89 ce                	mov    %ecx,%esi
  800409:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80040b:	85 c0                	test   %eax,%eax
  80040d:	7e 28                	jle    800437 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80040f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800413:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80041a:	00 
  80041b:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  800422:	00 
  800423:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80042a:	00 
  80042b:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  800432:	e8 0d 00 00 00       	call   800444 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800437:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80043a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80043d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800440:	89 ec                	mov    %ebp,%esp
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    

00800444 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	56                   	push   %esi
  800448:	53                   	push   %ebx
  800449:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80044c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80044f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800455:	e8 22 fd ff ff       	call   80017c <sys_getenvid>
  80045a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800461:	8b 55 08             	mov    0x8(%ebp),%edx
  800464:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800468:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80046c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800470:	c7 04 24 38 12 80 00 	movl   $0x801238,(%esp)
  800477:	e8 c3 00 00 00       	call   80053f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80047c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800480:	8b 45 10             	mov    0x10(%ebp),%eax
  800483:	89 04 24             	mov    %eax,(%esp)
  800486:	e8 53 00 00 00       	call   8004de <vcprintf>
	cprintf("\n");
  80048b:	c7 04 24 5c 12 80 00 	movl   $0x80125c,(%esp)
  800492:	e8 a8 00 00 00       	call   80053f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800497:	cc                   	int3   
  800498:	eb fd                	jmp    800497 <_panic+0x53>
	...

0080049c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	53                   	push   %ebx
  8004a0:	83 ec 14             	sub    $0x14,%esp
  8004a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004a6:	8b 03                	mov    (%ebx),%eax
  8004a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ab:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004af:	83 c0 01             	add    $0x1,%eax
  8004b2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004b4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b9:	75 19                	jne    8004d4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004bb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004c2:	00 
  8004c3:	8d 43 08             	lea    0x8(%ebx),%eax
  8004c6:	89 04 24             	mov    %eax,(%esp)
  8004c9:	e8 f2 fb ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  8004ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004d4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004d8:	83 c4 14             	add    $0x14,%esp
  8004db:	5b                   	pop    %ebx
  8004dc:	5d                   	pop    %ebp
  8004dd:	c3                   	ret    

008004de <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004ee:	00 00 00 
	b.cnt = 0;
  8004f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800502:	8b 45 08             	mov    0x8(%ebp),%eax
  800505:	89 44 24 08          	mov    %eax,0x8(%esp)
  800509:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80050f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800513:	c7 04 24 9c 04 80 00 	movl   $0x80049c,(%esp)
  80051a:	e8 d5 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80051f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800525:	89 44 24 04          	mov    %eax,0x4(%esp)
  800529:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	e8 89 fb ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800537:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800545:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054c:	8b 45 08             	mov    0x8(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	e8 87 ff ff ff       	call   8004de <vcprintf>
	va_end(ap);

	return cnt;
}
  800557:	c9                   	leave  
  800558:	c3                   	ret    
  800559:	00 00                	add    %al,(%eax)
  80055b:	00 00                	add    %al,(%eax)
  80055d:	00 00                	add    %al,(%eax)
	...

00800560 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	57                   	push   %edi
  800564:	56                   	push   %esi
  800565:	53                   	push   %ebx
  800566:	83 ec 3c             	sub    $0x3c,%esp
  800569:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056c:	89 d7                	mov    %edx,%edi
  80056e:	8b 45 08             	mov    0x8(%ebp),%eax
  800571:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800574:	8b 45 0c             	mov    0xc(%ebp),%eax
  800577:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80057d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800588:	72 11                	jb     80059b <printnum+0x3b>
  80058a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80058d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800590:	76 09                	jbe    80059b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800592:	83 eb 01             	sub    $0x1,%ebx
  800595:	85 db                	test   %ebx,%ebx
  800597:	7f 51                	jg     8005ea <printnum+0x8a>
  800599:	eb 5e                	jmp    8005f9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80059b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80059f:	83 eb 01             	sub    $0x1,%ebx
  8005a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8005a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ad:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005b1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005bc:	00 
  8005bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ca:	e8 71 09 00 00       	call   800f40 <__udivdi3>
  8005cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005d7:	89 04 24             	mov    %eax,(%esp)
  8005da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005de:	89 fa                	mov    %edi,%edx
  8005e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e3:	e8 78 ff ff ff       	call   800560 <printnum>
  8005e8:	eb 0f                	jmp    8005f9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ee:	89 34 24             	mov    %esi,(%esp)
  8005f1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005f4:	83 eb 01             	sub    $0x1,%ebx
  8005f7:	75 f1                	jne    8005ea <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800601:	8b 45 10             	mov    0x10(%ebp),%eax
  800604:	89 44 24 08          	mov    %eax,0x8(%esp)
  800608:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80060f:	00 
  800610:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800613:	89 04 24             	mov    %eax,(%esp)
  800616:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800619:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061d:	e8 4e 0a 00 00       	call   801070 <__umoddi3>
  800622:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800626:	0f be 80 5e 12 80 00 	movsbl 0x80125e(%eax),%eax
  80062d:	89 04 24             	mov    %eax,(%esp)
  800630:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800633:	83 c4 3c             	add    $0x3c,%esp
  800636:	5b                   	pop    %ebx
  800637:	5e                   	pop    %esi
  800638:	5f                   	pop    %edi
  800639:	5d                   	pop    %ebp
  80063a:	c3                   	ret    

0080063b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80063e:	83 fa 01             	cmp    $0x1,%edx
  800641:	7e 0e                	jle    800651 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800643:	8b 10                	mov    (%eax),%edx
  800645:	8d 4a 08             	lea    0x8(%edx),%ecx
  800648:	89 08                	mov    %ecx,(%eax)
  80064a:	8b 02                	mov    (%edx),%eax
  80064c:	8b 52 04             	mov    0x4(%edx),%edx
  80064f:	eb 22                	jmp    800673 <getuint+0x38>
	else if (lflag)
  800651:	85 d2                	test   %edx,%edx
  800653:	74 10                	je     800665 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800655:	8b 10                	mov    (%eax),%edx
  800657:	8d 4a 04             	lea    0x4(%edx),%ecx
  80065a:	89 08                	mov    %ecx,(%eax)
  80065c:	8b 02                	mov    (%edx),%eax
  80065e:	ba 00 00 00 00       	mov    $0x0,%edx
  800663:	eb 0e                	jmp    800673 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800665:	8b 10                	mov    (%eax),%edx
  800667:	8d 4a 04             	lea    0x4(%edx),%ecx
  80066a:	89 08                	mov    %ecx,(%eax)
  80066c:	8b 02                	mov    (%edx),%eax
  80066e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800673:	5d                   	pop    %ebp
  800674:	c3                   	ret    

00800675 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800678:	83 fa 01             	cmp    $0x1,%edx
  80067b:	7e 0e                	jle    80068b <getint+0x16>
		return va_arg(*ap, long long);
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800682:	89 08                	mov    %ecx,(%eax)
  800684:	8b 02                	mov    (%edx),%eax
  800686:	8b 52 04             	mov    0x4(%edx),%edx
  800689:	eb 22                	jmp    8006ad <getint+0x38>
	else if (lflag)
  80068b:	85 d2                	test   %edx,%edx
  80068d:	74 10                	je     80069f <getint+0x2a>
		return va_arg(*ap, long);
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	8d 4a 04             	lea    0x4(%edx),%ecx
  800694:	89 08                	mov    %ecx,(%eax)
  800696:	8b 02                	mov    (%edx),%eax
  800698:	89 c2                	mov    %eax,%edx
  80069a:	c1 fa 1f             	sar    $0x1f,%edx
  80069d:	eb 0e                	jmp    8006ad <getint+0x38>
	else
		return va_arg(*ap, int);
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a4:	89 08                	mov    %ecx,(%eax)
  8006a6:	8b 02                	mov    (%edx),%eax
  8006a8:	89 c2                	mov    %eax,%edx
  8006aa:	c1 fa 1f             	sar    $0x1f,%edx
}
  8006ad:	5d                   	pop    %ebp
  8006ae:	c3                   	ret    

008006af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006b9:	8b 10                	mov    (%eax),%edx
  8006bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8006be:	73 0a                	jae    8006ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8006c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c3:	88 0a                	mov    %cl,(%edx)
  8006c5:	83 c2 01             	add    $0x1,%edx
  8006c8:	89 10                	mov    %edx,(%eax)
}
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	e8 02 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 4c             	sub    $0x4c,%esp
  8006fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800700:	8b 75 10             	mov    0x10(%ebp),%esi
  800703:	eb 12                	jmp    800717 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800705:	85 c0                	test   %eax,%eax
  800707:	0f 84 77 03 00 00    	je     800a84 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  80070d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800711:	89 04 24             	mov    %eax,(%esp)
  800714:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800717:	0f b6 06             	movzbl (%esi),%eax
  80071a:	83 c6 01             	add    $0x1,%esi
  80071d:	83 f8 25             	cmp    $0x25,%eax
  800720:	75 e3                	jne    800705 <vprintfmt+0x11>
  800722:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800726:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80072d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800732:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800741:	eb 2b                	jmp    80076e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800746:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80074a:	eb 22                	jmp    80076e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80074f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800753:	eb 19                	jmp    80076e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800755:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800758:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80075f:	eb 0d                	jmp    80076e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800761:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800764:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800767:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076e:	0f b6 06             	movzbl (%esi),%eax
  800771:	0f b6 d0             	movzbl %al,%edx
  800774:	8d 7e 01             	lea    0x1(%esi),%edi
  800777:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80077a:	83 e8 23             	sub    $0x23,%eax
  80077d:	3c 55                	cmp    $0x55,%al
  80077f:	0f 87 d9 02 00 00    	ja     800a5e <vprintfmt+0x36a>
  800785:	0f b6 c0             	movzbl %al,%eax
  800788:	ff 24 85 20 13 80 00 	jmp    *0x801320(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80078f:	83 ea 30             	sub    $0x30,%edx
  800792:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800795:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800799:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80079f:	83 fa 09             	cmp    $0x9,%edx
  8007a2:	77 4a                	ja     8007ee <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007a7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8007aa:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8007ad:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8007b1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007b4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007b7:	83 fa 09             	cmp    $0x9,%edx
  8007ba:	76 eb                	jbe    8007a7 <vprintfmt+0xb3>
  8007bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007bf:	eb 2d                	jmp    8007ee <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8d 50 04             	lea    0x4(%eax),%edx
  8007c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ca:	8b 00                	mov    (%eax),%eax
  8007cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007d2:	eb 1a                	jmp    8007ee <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007db:	79 91                	jns    80076e <vprintfmt+0x7a>
  8007dd:	e9 73 ff ff ff       	jmp    800755 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007e5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007ec:	eb 80                	jmp    80076e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8007ee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007f2:	0f 89 76 ff ff ff    	jns    80076e <vprintfmt+0x7a>
  8007f8:	e9 64 ff ff ff       	jmp    800761 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007fd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800800:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800803:	e9 66 ff ff ff       	jmp    80076e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8d 50 04             	lea    0x4(%eax),%edx
  80080e:	89 55 14             	mov    %edx,0x14(%ebp)
  800811:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800815:	8b 00                	mov    (%eax),%eax
  800817:	89 04 24             	mov    %eax,(%esp)
  80081a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800820:	e9 f2 fe ff ff       	jmp    800717 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8d 50 04             	lea    0x4(%eax),%edx
  80082b:	89 55 14             	mov    %edx,0x14(%ebp)
  80082e:	8b 00                	mov    (%eax),%eax
  800830:	89 c2                	mov    %eax,%edx
  800832:	c1 fa 1f             	sar    $0x1f,%edx
  800835:	31 d0                	xor    %edx,%eax
  800837:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800839:	83 f8 08             	cmp    $0x8,%eax
  80083c:	7f 0b                	jg     800849 <vprintfmt+0x155>
  80083e:	8b 14 85 80 14 80 00 	mov    0x801480(,%eax,4),%edx
  800845:	85 d2                	test   %edx,%edx
  800847:	75 23                	jne    80086c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800849:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084d:	c7 44 24 08 76 12 80 	movl   $0x801276,0x8(%esp)
  800854:	00 
  800855:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800859:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085c:	89 3c 24             	mov    %edi,(%esp)
  80085f:	e8 68 fe ff ff       	call   8006cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800864:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800867:	e9 ab fe ff ff       	jmp    800717 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80086c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800870:	c7 44 24 08 7f 12 80 	movl   $0x80127f,0x8(%esp)
  800877:	00 
  800878:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087f:	89 3c 24             	mov    %edi,(%esp)
  800882:	e8 45 fe ff ff       	call   8006cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800887:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80088a:	e9 88 fe ff ff       	jmp    800717 <vprintfmt+0x23>
  80088f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800892:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800895:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 04             	lea    0x4(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8008a3:	85 f6                	test   %esi,%esi
  8008a5:	ba 6f 12 80 00       	mov    $0x80126f,%edx
  8008aa:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8008ad:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008b1:	7e 06                	jle    8008b9 <vprintfmt+0x1c5>
  8008b3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8008b7:	75 10                	jne    8008c9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008b9:	0f be 06             	movsbl (%esi),%eax
  8008bc:	83 c6 01             	add    $0x1,%esi
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	0f 85 86 00 00 00    	jne    80094d <vprintfmt+0x259>
  8008c7:	eb 76                	jmp    80093f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008cd:	89 34 24             	mov    %esi,(%esp)
  8008d0:	e8 56 02 00 00       	call   800b2b <strnlen>
  8008d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008d8:	29 c2                	sub    %eax,%edx
  8008da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008dd:	85 d2                	test   %edx,%edx
  8008df:	7e d8                	jle    8008b9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  8008e1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8008e5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8008e8:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8008eb:	89 d6                	mov    %edx,%esi
  8008ed:	89 c7                	mov    %eax,%edi
  8008ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f3:	89 3c 24             	mov    %edi,(%esp)
  8008f6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f9:	83 ee 01             	sub    $0x1,%esi
  8008fc:	75 f1                	jne    8008ef <vprintfmt+0x1fb>
  8008fe:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800901:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800904:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800907:	eb b0                	jmp    8008b9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800909:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80090d:	74 18                	je     800927 <vprintfmt+0x233>
  80090f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800912:	83 fa 5e             	cmp    $0x5e,%edx
  800915:	76 10                	jbe    800927 <vprintfmt+0x233>
					putch('?', putdat);
  800917:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800922:	ff 55 08             	call   *0x8(%ebp)
  800925:	eb 0a                	jmp    800931 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800927:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092b:	89 04 24             	mov    %eax,(%esp)
  80092e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800931:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800935:	0f be 06             	movsbl (%esi),%eax
  800938:	83 c6 01             	add    $0x1,%esi
  80093b:	85 c0                	test   %eax,%eax
  80093d:	75 0e                	jne    80094d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800942:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800946:	7f 11                	jg     800959 <vprintfmt+0x265>
  800948:	e9 ca fd ff ff       	jmp    800717 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80094d:	85 ff                	test   %edi,%edi
  80094f:	90                   	nop
  800950:	78 b7                	js     800909 <vprintfmt+0x215>
  800952:	83 ef 01             	sub    $0x1,%edi
  800955:	79 b2                	jns    800909 <vprintfmt+0x215>
  800957:	eb e6                	jmp    80093f <vprintfmt+0x24b>
  800959:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80095c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80095f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800963:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80096a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80096c:	83 ee 01             	sub    $0x1,%esi
  80096f:	75 ee                	jne    80095f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800971:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800974:	e9 9e fd ff ff       	jmp    800717 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800979:	89 ca                	mov    %ecx,%edx
  80097b:	8d 45 14             	lea    0x14(%ebp),%eax
  80097e:	e8 f2 fc ff ff       	call   800675 <getint>
  800983:	89 c6                	mov    %eax,%esi
  800985:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800987:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80098c:	85 d2                	test   %edx,%edx
  80098e:	0f 89 8c 00 00 00    	jns    800a20 <vprintfmt+0x32c>
				putch('-', putdat);
  800994:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800998:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80099f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009a2:	f7 de                	neg    %esi
  8009a4:	83 d7 00             	adc    $0x0,%edi
  8009a7:	f7 df                	neg    %edi
			}
			base = 10;
  8009a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009ae:	eb 70                	jmp    800a20 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009b0:	89 ca                	mov    %ecx,%edx
  8009b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b5:	e8 81 fc ff ff       	call   80063b <getuint>
  8009ba:	89 c6                	mov    %eax,%esi
  8009bc:	89 d7                	mov    %edx,%edi
			base = 10;
  8009be:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009c3:	eb 5b                	jmp    800a20 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  8009c5:	89 ca                	mov    %ecx,%edx
  8009c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ca:	e8 a6 fc ff ff       	call   800675 <getint>
  8009cf:	89 c6                	mov    %eax,%esi
  8009d1:	89 d7                	mov    %edx,%edi
			base = 8;
  8009d3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8009d8:	eb 46                	jmp    800a20 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009de:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009e5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ec:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009f3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f9:	8d 50 04             	lea    0x4(%eax),%edx
  8009fc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009ff:	8b 30                	mov    (%eax),%esi
  800a01:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a06:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a0b:	eb 13                	jmp    800a20 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a0d:	89 ca                	mov    %ecx,%edx
  800a0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a12:	e8 24 fc ff ff       	call   80063b <getuint>
  800a17:	89 c6                	mov    %eax,%esi
  800a19:	89 d7                	mov    %edx,%edi
			base = 16;
  800a1b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a20:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a24:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a28:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a33:	89 34 24             	mov    %esi,(%esp)
  800a36:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a3a:	89 da                	mov    %ebx,%edx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	e8 1c fb ff ff       	call   800560 <printnum>
			break;
  800a44:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a47:	e9 cb fc ff ff       	jmp    800717 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a50:	89 14 24             	mov    %edx,(%esp)
  800a53:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a56:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a59:	e9 b9 fc ff ff       	jmp    800717 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a62:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a69:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a6c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a70:	0f 84 a1 fc ff ff    	je     800717 <vprintfmt+0x23>
  800a76:	83 ee 01             	sub    $0x1,%esi
  800a79:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a7d:	75 f7                	jne    800a76 <vprintfmt+0x382>
  800a7f:	e9 93 fc ff ff       	jmp    800717 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a84:	83 c4 4c             	add    $0x4c,%esp
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	83 ec 28             	sub    $0x28,%esp
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a98:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a9b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a9f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800aa2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	74 30                	je     800add <vsnprintf+0x51>
  800aad:	85 d2                	test   %edx,%edx
  800aaf:	7e 2c                	jle    800add <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ab1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ab8:	8b 45 10             	mov    0x10(%ebp),%eax
  800abb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac6:	c7 04 24 af 06 80 00 	movl   $0x8006af,(%esp)
  800acd:	e8 22 fc ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adb:	eb 05                	jmp    800ae2 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800add:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ae2:	c9                   	leave  
  800ae3:	c3                   	ret    

00800ae4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af1:	8b 45 10             	mov    0x10(%ebp),%eax
  800af4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	89 04 24             	mov    %eax,(%esp)
  800b05:	e8 82 ff ff ff       	call   800a8c <vsnprintf>
	va_end(ap);

	return rc;
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    
  800b0c:	00 00                	add    %al,(%eax)
	...

00800b10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b1e:	74 09                	je     800b29 <strlen+0x19>
		n++;
  800b20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b27:	75 f7                	jne    800b20 <strlen+0x10>
		n++;
	return n;
}
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	53                   	push   %ebx
  800b2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3a:	85 c9                	test   %ecx,%ecx
  800b3c:	74 1a                	je     800b58 <strnlen+0x2d>
  800b3e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b41:	74 15                	je     800b58 <strnlen+0x2d>
  800b43:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800b48:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b4a:	39 ca                	cmp    %ecx,%edx
  800b4c:	74 0a                	je     800b58 <strnlen+0x2d>
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800b56:	75 f0                	jne    800b48 <strnlen+0x1d>
		n++;
	return n;
}
  800b58:	5b                   	pop    %ebx
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	53                   	push   %ebx
  800b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b6e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b71:	83 c2 01             	add    $0x1,%edx
  800b74:	84 c9                	test   %cl,%cl
  800b76:	75 f2                	jne    800b6a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b78:	5b                   	pop    %ebx
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 08             	sub    $0x8,%esp
  800b82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b85:	89 1c 24             	mov    %ebx,(%esp)
  800b88:	e8 83 ff ff ff       	call   800b10 <strlen>
	strcpy(dst + len, src);
  800b8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b90:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b94:	01 d8                	add    %ebx,%eax
  800b96:	89 04 24             	mov    %eax,(%esp)
  800b99:	e8 bd ff ff ff       	call   800b5b <strcpy>
	return dst;
}
  800b9e:	89 d8                	mov    %ebx,%eax
  800ba0:	83 c4 08             	add    $0x8,%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	8b 45 08             	mov    0x8(%ebp),%eax
  800bae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb4:	85 f6                	test   %esi,%esi
  800bb6:	74 18                	je     800bd0 <strncpy+0x2a>
  800bb8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bbd:	0f b6 1a             	movzbl (%edx),%ebx
  800bc0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bc3:	80 3a 01             	cmpb   $0x1,(%edx)
  800bc6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bc9:	83 c1 01             	add    $0x1,%ecx
  800bcc:	39 f1                	cmp    %esi,%ecx
  800bce:	75 ed                	jne    800bbd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bdd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800be3:	89 f8                	mov    %edi,%eax
  800be5:	85 f6                	test   %esi,%esi
  800be7:	74 2b                	je     800c14 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800be9:	83 fe 01             	cmp    $0x1,%esi
  800bec:	74 23                	je     800c11 <strlcpy+0x3d>
  800bee:	0f b6 0b             	movzbl (%ebx),%ecx
  800bf1:	84 c9                	test   %cl,%cl
  800bf3:	74 1c                	je     800c11 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800bf5:	83 ee 02             	sub    $0x2,%esi
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bfd:	88 08                	mov    %cl,(%eax)
  800bff:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c02:	39 f2                	cmp    %esi,%edx
  800c04:	74 0b                	je     800c11 <strlcpy+0x3d>
  800c06:	83 c2 01             	add    $0x1,%edx
  800c09:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c0d:	84 c9                	test   %cl,%cl
  800c0f:	75 ec                	jne    800bfd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800c11:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c14:	29 f8                	sub    %edi,%eax
}
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c21:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c24:	0f b6 01             	movzbl (%ecx),%eax
  800c27:	84 c0                	test   %al,%al
  800c29:	74 16                	je     800c41 <strcmp+0x26>
  800c2b:	3a 02                	cmp    (%edx),%al
  800c2d:	75 12                	jne    800c41 <strcmp+0x26>
		p++, q++;
  800c2f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c32:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800c36:	84 c0                	test   %al,%al
  800c38:	74 07                	je     800c41 <strcmp+0x26>
  800c3a:	83 c1 01             	add    $0x1,%ecx
  800c3d:	3a 02                	cmp    (%edx),%al
  800c3f:	74 ee                	je     800c2f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c41:	0f b6 c0             	movzbl %al,%eax
  800c44:	0f b6 12             	movzbl (%edx),%edx
  800c47:	29 d0                	sub    %edx,%eax
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	53                   	push   %ebx
  800c4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c55:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c58:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c5d:	85 d2                	test   %edx,%edx
  800c5f:	74 28                	je     800c89 <strncmp+0x3e>
  800c61:	0f b6 01             	movzbl (%ecx),%eax
  800c64:	84 c0                	test   %al,%al
  800c66:	74 24                	je     800c8c <strncmp+0x41>
  800c68:	3a 03                	cmp    (%ebx),%al
  800c6a:	75 20                	jne    800c8c <strncmp+0x41>
  800c6c:	83 ea 01             	sub    $0x1,%edx
  800c6f:	74 13                	je     800c84 <strncmp+0x39>
		n--, p++, q++;
  800c71:	83 c1 01             	add    $0x1,%ecx
  800c74:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c77:	0f b6 01             	movzbl (%ecx),%eax
  800c7a:	84 c0                	test   %al,%al
  800c7c:	74 0e                	je     800c8c <strncmp+0x41>
  800c7e:	3a 03                	cmp    (%ebx),%al
  800c80:	74 ea                	je     800c6c <strncmp+0x21>
  800c82:	eb 08                	jmp    800c8c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c84:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c89:	5b                   	pop    %ebx
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c8c:	0f b6 01             	movzbl (%ecx),%eax
  800c8f:	0f b6 13             	movzbl (%ebx),%edx
  800c92:	29 d0                	sub    %edx,%eax
  800c94:	eb f3                	jmp    800c89 <strncmp+0x3e>

00800c96 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ca0:	0f b6 10             	movzbl (%eax),%edx
  800ca3:	84 d2                	test   %dl,%dl
  800ca5:	74 1c                	je     800cc3 <strchr+0x2d>
		if (*s == c)
  800ca7:	38 ca                	cmp    %cl,%dl
  800ca9:	75 09                	jne    800cb4 <strchr+0x1e>
  800cab:	eb 1b                	jmp    800cc8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cad:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800cb0:	38 ca                	cmp    %cl,%dl
  800cb2:	74 14                	je     800cc8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cb4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800cb8:	84 d2                	test   %dl,%dl
  800cba:	75 f1                	jne    800cad <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc1:	eb 05                	jmp    800cc8 <strchr+0x32>
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd4:	0f b6 10             	movzbl (%eax),%edx
  800cd7:	84 d2                	test   %dl,%dl
  800cd9:	74 14                	je     800cef <strfind+0x25>
		if (*s == c)
  800cdb:	38 ca                	cmp    %cl,%dl
  800cdd:	75 06                	jne    800ce5 <strfind+0x1b>
  800cdf:	eb 0e                	jmp    800cef <strfind+0x25>
  800ce1:	38 ca                	cmp    %cl,%dl
  800ce3:	74 0a                	je     800cef <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ce5:	83 c0 01             	add    $0x1,%eax
  800ce8:	0f b6 10             	movzbl (%eax),%edx
  800ceb:	84 d2                	test   %dl,%dl
  800ced:	75 f2                	jne    800ce1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cfa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cfd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d00:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d09:	85 c9                	test   %ecx,%ecx
  800d0b:	74 30                	je     800d3d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d13:	75 25                	jne    800d3a <memset+0x49>
  800d15:	f6 c1 03             	test   $0x3,%cl
  800d18:	75 20                	jne    800d3a <memset+0x49>
		c &= 0xFF;
  800d1a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d1d:	89 d3                	mov    %edx,%ebx
  800d1f:	c1 e3 08             	shl    $0x8,%ebx
  800d22:	89 d6                	mov    %edx,%esi
  800d24:	c1 e6 18             	shl    $0x18,%esi
  800d27:	89 d0                	mov    %edx,%eax
  800d29:	c1 e0 10             	shl    $0x10,%eax
  800d2c:	09 f0                	or     %esi,%eax
  800d2e:	09 d0                	or     %edx,%eax
  800d30:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d32:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d35:	fc                   	cld    
  800d36:	f3 ab                	rep stos %eax,%es:(%edi)
  800d38:	eb 03                	jmp    800d3d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d3a:	fc                   	cld    
  800d3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d3d:	89 f8                	mov    %edi,%eax
  800d3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d48:	89 ec                	mov    %ebp,%esp
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 08             	sub    $0x8,%esp
  800d52:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d55:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d61:	39 c6                	cmp    %eax,%esi
  800d63:	73 36                	jae    800d9b <memmove+0x4f>
  800d65:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d68:	39 d0                	cmp    %edx,%eax
  800d6a:	73 2f                	jae    800d9b <memmove+0x4f>
		s += n;
		d += n;
  800d6c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d6f:	f6 c2 03             	test   $0x3,%dl
  800d72:	75 1b                	jne    800d8f <memmove+0x43>
  800d74:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d7a:	75 13                	jne    800d8f <memmove+0x43>
  800d7c:	f6 c1 03             	test   $0x3,%cl
  800d7f:	75 0e                	jne    800d8f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d81:	83 ef 04             	sub    $0x4,%edi
  800d84:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d87:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d8a:	fd                   	std    
  800d8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d8d:	eb 09                	jmp    800d98 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d8f:	83 ef 01             	sub    $0x1,%edi
  800d92:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d95:	fd                   	std    
  800d96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d98:	fc                   	cld    
  800d99:	eb 20                	jmp    800dbb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d9b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800da1:	75 13                	jne    800db6 <memmove+0x6a>
  800da3:	a8 03                	test   $0x3,%al
  800da5:	75 0f                	jne    800db6 <memmove+0x6a>
  800da7:	f6 c1 03             	test   $0x3,%cl
  800daa:	75 0a                	jne    800db6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800dac:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800daf:	89 c7                	mov    %eax,%edi
  800db1:	fc                   	cld    
  800db2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800db4:	eb 05                	jmp    800dbb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800db6:	89 c7                	mov    %eax,%edi
  800db8:	fc                   	cld    
  800db9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dbb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dbe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc1:	89 ec                	mov    %ebp,%esp
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dcb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dce:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	89 04 24             	mov    %eax,(%esp)
  800ddf:	e8 68 ff ff ff       	call   800d4c <memmove>
}
  800de4:	c9                   	leave  
  800de5:	c3                   	ret    

00800de6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
  800dec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800def:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800df5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dfa:	85 ff                	test   %edi,%edi
  800dfc:	74 37                	je     800e35 <memcmp+0x4f>
		if (*s1 != *s2)
  800dfe:	0f b6 03             	movzbl (%ebx),%eax
  800e01:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e04:	83 ef 01             	sub    $0x1,%edi
  800e07:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e0c:	38 c8                	cmp    %cl,%al
  800e0e:	74 1c                	je     800e2c <memcmp+0x46>
  800e10:	eb 10                	jmp    800e22 <memcmp+0x3c>
  800e12:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e17:	83 c2 01             	add    $0x1,%edx
  800e1a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e1e:	38 c8                	cmp    %cl,%al
  800e20:	74 0a                	je     800e2c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800e22:	0f b6 c0             	movzbl %al,%eax
  800e25:	0f b6 c9             	movzbl %cl,%ecx
  800e28:	29 c8                	sub    %ecx,%eax
  800e2a:	eb 09                	jmp    800e35 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e2c:	39 fa                	cmp    %edi,%edx
  800e2e:	75 e2                	jne    800e12 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e40:	89 c2                	mov    %eax,%edx
  800e42:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e45:	39 d0                	cmp    %edx,%eax
  800e47:	73 19                	jae    800e62 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e49:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e4d:	38 08                	cmp    %cl,(%eax)
  800e4f:	75 06                	jne    800e57 <memfind+0x1d>
  800e51:	eb 0f                	jmp    800e62 <memfind+0x28>
  800e53:	38 08                	cmp    %cl,(%eax)
  800e55:	74 0b                	je     800e62 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e57:	83 c0 01             	add    $0x1,%eax
  800e5a:	39 d0                	cmp    %edx,%eax
  800e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e60:	75 f1                	jne    800e53 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	53                   	push   %ebx
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e70:	0f b6 02             	movzbl (%edx),%eax
  800e73:	3c 20                	cmp    $0x20,%al
  800e75:	74 04                	je     800e7b <strtol+0x17>
  800e77:	3c 09                	cmp    $0x9,%al
  800e79:	75 0e                	jne    800e89 <strtol+0x25>
		s++;
  800e7b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e7e:	0f b6 02             	movzbl (%edx),%eax
  800e81:	3c 20                	cmp    $0x20,%al
  800e83:	74 f6                	je     800e7b <strtol+0x17>
  800e85:	3c 09                	cmp    $0x9,%al
  800e87:	74 f2                	je     800e7b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e89:	3c 2b                	cmp    $0x2b,%al
  800e8b:	75 0a                	jne    800e97 <strtol+0x33>
		s++;
  800e8d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e90:	bf 00 00 00 00       	mov    $0x0,%edi
  800e95:	eb 10                	jmp    800ea7 <strtol+0x43>
  800e97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e9c:	3c 2d                	cmp    $0x2d,%al
  800e9e:	75 07                	jne    800ea7 <strtol+0x43>
		s++, neg = 1;
  800ea0:	83 c2 01             	add    $0x1,%edx
  800ea3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ea7:	85 db                	test   %ebx,%ebx
  800ea9:	0f 94 c0             	sete   %al
  800eac:	74 05                	je     800eb3 <strtol+0x4f>
  800eae:	83 fb 10             	cmp    $0x10,%ebx
  800eb1:	75 15                	jne    800ec8 <strtol+0x64>
  800eb3:	80 3a 30             	cmpb   $0x30,(%edx)
  800eb6:	75 10                	jne    800ec8 <strtol+0x64>
  800eb8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ebc:	75 0a                	jne    800ec8 <strtol+0x64>
		s += 2, base = 16;
  800ebe:	83 c2 02             	add    $0x2,%edx
  800ec1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ec6:	eb 13                	jmp    800edb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ec8:	84 c0                	test   %al,%al
  800eca:	74 0f                	je     800edb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ecc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ed1:	80 3a 30             	cmpb   $0x30,(%edx)
  800ed4:	75 05                	jne    800edb <strtol+0x77>
		s++, base = 8;
  800ed6:	83 c2 01             	add    $0x1,%edx
  800ed9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800edb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ee2:	0f b6 0a             	movzbl (%edx),%ecx
  800ee5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ee8:	80 fb 09             	cmp    $0x9,%bl
  800eeb:	77 08                	ja     800ef5 <strtol+0x91>
			dig = *s - '0';
  800eed:	0f be c9             	movsbl %cl,%ecx
  800ef0:	83 e9 30             	sub    $0x30,%ecx
  800ef3:	eb 1e                	jmp    800f13 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800ef5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ef8:	80 fb 19             	cmp    $0x19,%bl
  800efb:	77 08                	ja     800f05 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800efd:	0f be c9             	movsbl %cl,%ecx
  800f00:	83 e9 57             	sub    $0x57,%ecx
  800f03:	eb 0e                	jmp    800f13 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800f05:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f08:	80 fb 19             	cmp    $0x19,%bl
  800f0b:	77 14                	ja     800f21 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f0d:	0f be c9             	movsbl %cl,%ecx
  800f10:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f13:	39 f1                	cmp    %esi,%ecx
  800f15:	7d 0e                	jge    800f25 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800f17:	83 c2 01             	add    $0x1,%edx
  800f1a:	0f af c6             	imul   %esi,%eax
  800f1d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f1f:	eb c1                	jmp    800ee2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f21:	89 c1                	mov    %eax,%ecx
  800f23:	eb 02                	jmp    800f27 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f25:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f27:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f2b:	74 05                	je     800f32 <strtol+0xce>
		*endptr = (char *) s;
  800f2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f30:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f32:	89 ca                	mov    %ecx,%edx
  800f34:	f7 da                	neg    %edx
  800f36:	85 ff                	test   %edi,%edi
  800f38:	0f 45 c2             	cmovne %edx,%eax
}
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <__udivdi3>:
  800f40:	83 ec 1c             	sub    $0x1c,%esp
  800f43:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f47:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f4b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f4f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f53:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f57:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f5b:	85 ff                	test   %edi,%edi
  800f5d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f61:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f65:	89 cd                	mov    %ecx,%ebp
  800f67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6b:	75 33                	jne    800fa0 <__udivdi3+0x60>
  800f6d:	39 f1                	cmp    %esi,%ecx
  800f6f:	77 57                	ja     800fc8 <__udivdi3+0x88>
  800f71:	85 c9                	test   %ecx,%ecx
  800f73:	75 0b                	jne    800f80 <__udivdi3+0x40>
  800f75:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7a:	31 d2                	xor    %edx,%edx
  800f7c:	f7 f1                	div    %ecx
  800f7e:	89 c1                	mov    %eax,%ecx
  800f80:	89 f0                	mov    %esi,%eax
  800f82:	31 d2                	xor    %edx,%edx
  800f84:	f7 f1                	div    %ecx
  800f86:	89 c6                	mov    %eax,%esi
  800f88:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f8c:	f7 f1                	div    %ecx
  800f8e:	89 f2                	mov    %esi,%edx
  800f90:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f94:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f98:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f9c:	83 c4 1c             	add    $0x1c,%esp
  800f9f:	c3                   	ret    
  800fa0:	31 d2                	xor    %edx,%edx
  800fa2:	31 c0                	xor    %eax,%eax
  800fa4:	39 f7                	cmp    %esi,%edi
  800fa6:	77 e8                	ja     800f90 <__udivdi3+0x50>
  800fa8:	0f bd cf             	bsr    %edi,%ecx
  800fab:	83 f1 1f             	xor    $0x1f,%ecx
  800fae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fb2:	75 2c                	jne    800fe0 <__udivdi3+0xa0>
  800fb4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fb8:	76 04                	jbe    800fbe <__udivdi3+0x7e>
  800fba:	39 f7                	cmp    %esi,%edi
  800fbc:	73 d2                	jae    800f90 <__udivdi3+0x50>
  800fbe:	31 d2                	xor    %edx,%edx
  800fc0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc5:	eb c9                	jmp    800f90 <__udivdi3+0x50>
  800fc7:	90                   	nop
  800fc8:	89 f2                	mov    %esi,%edx
  800fca:	f7 f1                	div    %ecx
  800fcc:	31 d2                	xor    %edx,%edx
  800fce:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fd2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fd6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fda:	83 c4 1c             	add    $0x1c,%esp
  800fdd:	c3                   	ret    
  800fde:	66 90                	xchg   %ax,%ax
  800fe0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fe5:	b8 20 00 00 00       	mov    $0x20,%eax
  800fea:	89 ea                	mov    %ebp,%edx
  800fec:	2b 44 24 04          	sub    0x4(%esp),%eax
  800ff0:	d3 e7                	shl    %cl,%edi
  800ff2:	89 c1                	mov    %eax,%ecx
  800ff4:	d3 ea                	shr    %cl,%edx
  800ff6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffb:	09 fa                	or     %edi,%edx
  800ffd:	89 f7                	mov    %esi,%edi
  800fff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801003:	89 f2                	mov    %esi,%edx
  801005:	8b 74 24 08          	mov    0x8(%esp),%esi
  801009:	d3 e5                	shl    %cl,%ebp
  80100b:	89 c1                	mov    %eax,%ecx
  80100d:	d3 ef                	shr    %cl,%edi
  80100f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801014:	d3 e2                	shl    %cl,%edx
  801016:	89 c1                	mov    %eax,%ecx
  801018:	d3 ee                	shr    %cl,%esi
  80101a:	09 d6                	or     %edx,%esi
  80101c:	89 fa                	mov    %edi,%edx
  80101e:	89 f0                	mov    %esi,%eax
  801020:	f7 74 24 0c          	divl   0xc(%esp)
  801024:	89 d7                	mov    %edx,%edi
  801026:	89 c6                	mov    %eax,%esi
  801028:	f7 e5                	mul    %ebp
  80102a:	39 d7                	cmp    %edx,%edi
  80102c:	72 22                	jb     801050 <__udivdi3+0x110>
  80102e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801032:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801037:	d3 e5                	shl    %cl,%ebp
  801039:	39 c5                	cmp    %eax,%ebp
  80103b:	73 04                	jae    801041 <__udivdi3+0x101>
  80103d:	39 d7                	cmp    %edx,%edi
  80103f:	74 0f                	je     801050 <__udivdi3+0x110>
  801041:	89 f0                	mov    %esi,%eax
  801043:	31 d2                	xor    %edx,%edx
  801045:	e9 46 ff ff ff       	jmp    800f90 <__udivdi3+0x50>
  80104a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801050:	8d 46 ff             	lea    -0x1(%esi),%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	8b 74 24 10          	mov    0x10(%esp),%esi
  801059:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80105d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801061:	83 c4 1c             	add    $0x1c,%esp
  801064:	c3                   	ret    
	...

00801070 <__umoddi3>:
  801070:	83 ec 1c             	sub    $0x1c,%esp
  801073:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801077:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80107b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80107f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801083:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801087:	8b 74 24 24          	mov    0x24(%esp),%esi
  80108b:	85 ed                	test   %ebp,%ebp
  80108d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801091:	89 44 24 08          	mov    %eax,0x8(%esp)
  801095:	89 cf                	mov    %ecx,%edi
  801097:	89 04 24             	mov    %eax,(%esp)
  80109a:	89 f2                	mov    %esi,%edx
  80109c:	75 1a                	jne    8010b8 <__umoddi3+0x48>
  80109e:	39 f1                	cmp    %esi,%ecx
  8010a0:	76 4e                	jbe    8010f0 <__umoddi3+0x80>
  8010a2:	f7 f1                	div    %ecx
  8010a4:	89 d0                	mov    %edx,%eax
  8010a6:	31 d2                	xor    %edx,%edx
  8010a8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010ac:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010b0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010b4:	83 c4 1c             	add    $0x1c,%esp
  8010b7:	c3                   	ret    
  8010b8:	39 f5                	cmp    %esi,%ebp
  8010ba:	77 54                	ja     801110 <__umoddi3+0xa0>
  8010bc:	0f bd c5             	bsr    %ebp,%eax
  8010bf:	83 f0 1f             	xor    $0x1f,%eax
  8010c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c6:	75 60                	jne    801128 <__umoddi3+0xb8>
  8010c8:	3b 0c 24             	cmp    (%esp),%ecx
  8010cb:	0f 87 07 01 00 00    	ja     8011d8 <__umoddi3+0x168>
  8010d1:	89 f2                	mov    %esi,%edx
  8010d3:	8b 34 24             	mov    (%esp),%esi
  8010d6:	29 ce                	sub    %ecx,%esi
  8010d8:	19 ea                	sbb    %ebp,%edx
  8010da:	89 34 24             	mov    %esi,(%esp)
  8010dd:	8b 04 24             	mov    (%esp),%eax
  8010e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ec:	83 c4 1c             	add    $0x1c,%esp
  8010ef:	c3                   	ret    
  8010f0:	85 c9                	test   %ecx,%ecx
  8010f2:	75 0b                	jne    8010ff <__umoddi3+0x8f>
  8010f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f9:	31 d2                	xor    %edx,%edx
  8010fb:	f7 f1                	div    %ecx
  8010fd:	89 c1                	mov    %eax,%ecx
  8010ff:	89 f0                	mov    %esi,%eax
  801101:	31 d2                	xor    %edx,%edx
  801103:	f7 f1                	div    %ecx
  801105:	8b 04 24             	mov    (%esp),%eax
  801108:	f7 f1                	div    %ecx
  80110a:	eb 98                	jmp    8010a4 <__umoddi3+0x34>
  80110c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801110:	89 f2                	mov    %esi,%edx
  801112:	8b 74 24 10          	mov    0x10(%esp),%esi
  801116:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80111a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80111e:	83 c4 1c             	add    $0x1c,%esp
  801121:	c3                   	ret    
  801122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801128:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80112d:	89 e8                	mov    %ebp,%eax
  80112f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801134:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801138:	89 fa                	mov    %edi,%edx
  80113a:	d3 e0                	shl    %cl,%eax
  80113c:	89 e9                	mov    %ebp,%ecx
  80113e:	d3 ea                	shr    %cl,%edx
  801140:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801145:	09 c2                	or     %eax,%edx
  801147:	8b 44 24 08          	mov    0x8(%esp),%eax
  80114b:	89 14 24             	mov    %edx,(%esp)
  80114e:	89 f2                	mov    %esi,%edx
  801150:	d3 e7                	shl    %cl,%edi
  801152:	89 e9                	mov    %ebp,%ecx
  801154:	d3 ea                	shr    %cl,%edx
  801156:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80115f:	d3 e6                	shl    %cl,%esi
  801161:	89 e9                	mov    %ebp,%ecx
  801163:	d3 e8                	shr    %cl,%eax
  801165:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80116a:	09 f0                	or     %esi,%eax
  80116c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801170:	f7 34 24             	divl   (%esp)
  801173:	d3 e6                	shl    %cl,%esi
  801175:	89 74 24 08          	mov    %esi,0x8(%esp)
  801179:	89 d6                	mov    %edx,%esi
  80117b:	f7 e7                	mul    %edi
  80117d:	39 d6                	cmp    %edx,%esi
  80117f:	89 c1                	mov    %eax,%ecx
  801181:	89 d7                	mov    %edx,%edi
  801183:	72 3f                	jb     8011c4 <__umoddi3+0x154>
  801185:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801189:	72 35                	jb     8011c0 <__umoddi3+0x150>
  80118b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80118f:	29 c8                	sub    %ecx,%eax
  801191:	19 fe                	sbb    %edi,%esi
  801193:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801198:	89 f2                	mov    %esi,%edx
  80119a:	d3 e8                	shr    %cl,%eax
  80119c:	89 e9                	mov    %ebp,%ecx
  80119e:	d3 e2                	shl    %cl,%edx
  8011a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011a5:	09 d0                	or     %edx,%eax
  8011a7:	89 f2                	mov    %esi,%edx
  8011a9:	d3 ea                	shr    %cl,%edx
  8011ab:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011af:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011b3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011b7:	83 c4 1c             	add    $0x1c,%esp
  8011ba:	c3                   	ret    
  8011bb:	90                   	nop
  8011bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c0:	39 d6                	cmp    %edx,%esi
  8011c2:	75 c7                	jne    80118b <__umoddi3+0x11b>
  8011c4:	89 d7                	mov    %edx,%edi
  8011c6:	89 c1                	mov    %eax,%ecx
  8011c8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011cc:	1b 3c 24             	sbb    (%esp),%edi
  8011cf:	eb ba                	jmp    80118b <__umoddi3+0x11b>
  8011d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011d8:	39 f5                	cmp    %esi,%ebp
  8011da:	0f 82 f1 fe ff ff    	jb     8010d1 <__umoddi3+0x61>
  8011e0:	e9 f8 fe ff ff       	jmp    8010dd <__umoddi3+0x6d>
