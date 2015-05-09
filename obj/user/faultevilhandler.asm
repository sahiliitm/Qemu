
obj/user/faultevilhandler:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 ae 01 00 00       	call   800204 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800056:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005d:	f0 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 13 03 00 00       	call   80037d <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80008a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800091:	00 00 00 
	envid_t envid = sys_getenvid();
  800094:	e8 0b 01 00 00       	call   8001a4 <sys_getenvid>
	thisenv = &(envs[ENVX(envid)]);
  800099:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a6:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ab:	85 f6                	test   %esi,%esi
  8000ad:	7e 07                	jle    8000b6 <libmain+0x3e>
		binaryname = argv[0];
  8000af:	8b 03                	mov    (%ebx),%eax
  8000b1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ba:	89 34 24             	mov    %esi,(%esp)
  8000bd:	e8 72 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000c2:	e8 0d 00 00 00       	call   8000d4 <exit>
}
  8000c7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000ca:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000cd:	89 ec                	mov    %ebp,%esp
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    
  8000d1:	00 00                	add    %al,(%eax)
	...

008000d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e1:	e8 61 00 00 00       	call   800147 <sys_env_destroy>
}
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800102:	89 c3                	mov    %eax,%ebx
  800104:	89 c7                	mov    %eax,%edi
  800106:	89 c6                	mov    %eax,%esi
  800108:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80010a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80010d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800110:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800113:	89 ec                	mov    %ebp,%esp
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_cgetc>:

int
sys_cgetc(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	83 ec 0c             	sub    $0xc,%esp
  80011d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800120:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800123:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 01 00 00 00       	mov    $0x1,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80013a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80013d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800140:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 38             	sub    $0x38,%esp
  80014d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800150:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800153:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800156:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015b:	b8 03 00 00 00       	mov    $0x3,%eax
  800160:	8b 55 08             	mov    0x8(%ebp),%edx
  800163:	89 cb                	mov    %ecx,%ebx
  800165:	89 cf                	mov    %ecx,%edi
  800167:	89 ce                	mov    %ecx,%esi
  800169:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016b:	85 c0                	test   %eax,%eax
  80016d:	7e 28                	jle    800197 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80016f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800173:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80017a:	00 
  80017b:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800182:	00 
  800183:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80018a:	00 
  80018b:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  800192:	e8 d5 02 00 00       	call   80046c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800197:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80019a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80019d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a0:	89 ec                	mov    %ebp,%esp
  8001a2:	5d                   	pop    %ebp
  8001a3:	c3                   	ret    

008001a4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001ad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001b0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b8:	b8 02 00 00 00       	mov    $0x2,%eax
  8001bd:	89 d1                	mov    %edx,%ecx
  8001bf:	89 d3                	mov    %edx,%ebx
  8001c1:	89 d7                	mov    %edx,%edi
  8001c3:	89 d6                	mov    %edx,%esi
  8001c5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001c7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d0:	89 ec                	mov    %ebp,%esp
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    

008001d4 <sys_yield>:

void
sys_yield(void)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001dd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001e0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8001e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001ed:	89 d1                	mov    %edx,%ecx
  8001ef:	89 d3                	mov    %edx,%ebx
  8001f1:	89 d7                	mov    %edx,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001f7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001fa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001fd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800200:	89 ec                	mov    %ebp,%esp
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 38             	sub    $0x38,%esp
  80020a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80020d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800210:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800213:	be 00 00 00 00       	mov    $0x0,%esi
  800218:	b8 04 00 00 00       	mov    $0x4,%eax
  80021d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800223:	8b 55 08             	mov    0x8(%ebp),%edx
  800226:	89 f7                	mov    %esi,%edi
  800228:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80022a:	85 c0                	test   %eax,%eax
  80022c:	7e 28                	jle    800256 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800232:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800239:	00 
  80023a:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800241:	00 
  800242:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800249:	00 
  80024a:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  800251:	e8 16 02 00 00       	call   80046c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800256:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800259:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80025c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80025f:	89 ec                	mov    %ebp,%esp
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 38             	sub    $0x38,%esp
  800269:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80026c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80026f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800272:	b8 05 00 00 00       	mov    $0x5,%eax
  800277:	8b 75 18             	mov    0x18(%ebp),%esi
  80027a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80027d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800283:	8b 55 08             	mov    0x8(%ebp),%edx
  800286:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800288:	85 c0                	test   %eax,%eax
  80028a:	7e 28                	jle    8002b4 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800290:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800297:	00 
  800298:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  80029f:	00 
  8002a0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a7:	00 
  8002a8:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  8002af:	e8 b8 01 00 00       	call   80046c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002b4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002b7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002ba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002bd:	89 ec                	mov    %ebp,%esp
  8002bf:	5d                   	pop    %ebp
  8002c0:	c3                   	ret    

008002c1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	83 ec 38             	sub    $0x38,%esp
  8002c7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002ca:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002cd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d5:	b8 06 00 00 00       	mov    $0x6,%eax
  8002da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e0:	89 df                	mov    %ebx,%edi
  8002e2:	89 de                	mov    %ebx,%esi
  8002e4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e6:	85 c0                	test   %eax,%eax
  8002e8:	7e 28                	jle    800312 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ee:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002f5:	00 
  8002f6:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  8002fd:	00 
  8002fe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800305:	00 
  800306:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  80030d:	e8 5a 01 00 00       	call   80046c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800312:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800315:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800318:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80031b:	89 ec                	mov    %ebp,%esp
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	83 ec 38             	sub    $0x38,%esp
  800325:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800328:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80032b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800333:	b8 08 00 00 00       	mov    $0x8,%eax
  800338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033b:	8b 55 08             	mov    0x8(%ebp),%edx
  80033e:	89 df                	mov    %ebx,%edi
  800340:	89 de                	mov    %ebx,%esi
  800342:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800344:	85 c0                	test   %eax,%eax
  800346:	7e 28                	jle    800370 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800348:	89 44 24 10          	mov    %eax,0x10(%esp)
  80034c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800353:	00 
  800354:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  80035b:	00 
  80035c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800363:	00 
  800364:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  80036b:	e8 fc 00 00 00       	call   80046c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800370:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800373:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800376:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800379:	89 ec                	mov    %ebp,%esp
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	83 ec 38             	sub    $0x38,%esp
  800383:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800386:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800389:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800391:	b8 09 00 00 00       	mov    $0x9,%eax
  800396:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800399:	8b 55 08             	mov    0x8(%ebp),%edx
  80039c:	89 df                	mov    %ebx,%edi
  80039e:	89 de                	mov    %ebx,%esi
  8003a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003a2:	85 c0                	test   %eax,%eax
  8003a4:	7e 28                	jle    8003ce <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003aa:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003b1:	00 
  8003b2:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  8003b9:	00 
  8003ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c1:	00 
  8003c2:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  8003c9:	e8 9e 00 00 00       	call   80046c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003d1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003d4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003d7:	89 ec                	mov    %ebp,%esp
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	83 ec 0c             	sub    $0xc,%esp
  8003e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ea:	be 00 00 00 00       	mov    $0x0,%esi
  8003ef:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003f4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800400:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800402:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800405:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800408:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80040b:	89 ec                	mov    %ebp,%esp
  80040d:	5d                   	pop    %ebp
  80040e:	c3                   	ret    

0080040f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	83 ec 38             	sub    $0x38,%esp
  800415:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800418:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80041b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80041e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800423:	b8 0c 00 00 00       	mov    $0xc,%eax
  800428:	8b 55 08             	mov    0x8(%ebp),%edx
  80042b:	89 cb                	mov    %ecx,%ebx
  80042d:	89 cf                	mov    %ecx,%edi
  80042f:	89 ce                	mov    %ecx,%esi
  800431:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800433:	85 c0                	test   %eax,%eax
  800435:	7e 28                	jle    80045f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800437:	89 44 24 10          	mov    %eax,0x10(%esp)
  80043b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800442:	00 
  800443:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  80044a:	00 
  80044b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800452:	00 
  800453:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  80045a:	e8 0d 00 00 00       	call   80046c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80045f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800462:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800465:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800468:	89 ec                	mov    %ebp,%esp
  80046a:	5d                   	pop    %ebp
  80046b:	c3                   	ret    

0080046c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	56                   	push   %esi
  800470:	53                   	push   %ebx
  800471:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800474:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800477:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80047d:	e8 22 fd ff ff       	call   8001a4 <sys_getenvid>
  800482:	8b 55 0c             	mov    0xc(%ebp),%edx
  800485:	89 54 24 10          	mov    %edx,0x10(%esp)
  800489:	8b 55 08             	mov    0x8(%ebp),%edx
  80048c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800490:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800494:	89 44 24 04          	mov    %eax,0x4(%esp)
  800498:	c7 04 24 58 12 80 00 	movl   $0x801258,(%esp)
  80049f:	e8 c3 00 00 00       	call   800567 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ab:	89 04 24             	mov    %eax,(%esp)
  8004ae:	e8 53 00 00 00       	call   800506 <vcprintf>
	cprintf("\n");
  8004b3:	c7 04 24 7c 12 80 00 	movl   $0x80127c,(%esp)
  8004ba:	e8 a8 00 00 00       	call   800567 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004bf:	cc                   	int3   
  8004c0:	eb fd                	jmp    8004bf <_panic+0x53>
	...

008004c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	53                   	push   %ebx
  8004c8:	83 ec 14             	sub    $0x14,%esp
  8004cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ce:	8b 03                	mov    (%ebx),%eax
  8004d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004d7:	83 c0 01             	add    $0x1,%eax
  8004da:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004e1:	75 19                	jne    8004fc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004e3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004ea:	00 
  8004eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8004ee:	89 04 24             	mov    %eax,(%esp)
  8004f1:	e8 f2 fb ff ff       	call   8000e8 <sys_cputs>
		b->idx = 0;
  8004f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800500:	83 c4 14             	add    $0x14,%esp
  800503:	5b                   	pop    %ebx
  800504:	5d                   	pop    %ebp
  800505:	c3                   	ret    

00800506 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80050f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800516:	00 00 00 
	b.cnt = 0;
  800519:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800520:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800523:	8b 45 0c             	mov    0xc(%ebp),%eax
  800526:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052a:	8b 45 08             	mov    0x8(%ebp),%eax
  80052d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800531:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800537:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053b:	c7 04 24 c4 04 80 00 	movl   $0x8004c4,(%esp)
  800542:	e8 dd 01 00 00       	call   800724 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800547:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80054d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800551:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800557:	89 04 24             	mov    %eax,(%esp)
  80055a:	e8 89 fb ff ff       	call   8000e8 <sys_cputs>

	return b.cnt;
}
  80055f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800565:	c9                   	leave  
  800566:	c3                   	ret    

00800567 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800567:	55                   	push   %ebp
  800568:	89 e5                	mov    %esp,%ebp
  80056a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80056d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800570:	89 44 24 04          	mov    %eax,0x4(%esp)
  800574:	8b 45 08             	mov    0x8(%ebp),%eax
  800577:	89 04 24             	mov    %eax,(%esp)
  80057a:	e8 87 ff ff ff       	call   800506 <vcprintf>
	va_end(ap);

	return cnt;
}
  80057f:	c9                   	leave  
  800580:	c3                   	ret    
	...

00800590 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	57                   	push   %edi
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	83 ec 3c             	sub    $0x3c,%esp
  800599:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80059c:	89 d7                	mov    %edx,%edi
  80059e:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005b8:	72 11                	jb     8005cb <printnum+0x3b>
  8005ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005bd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005c0:	76 09                	jbe    8005cb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005c2:	83 eb 01             	sub    $0x1,%ebx
  8005c5:	85 db                	test   %ebx,%ebx
  8005c7:	7f 51                	jg     80061a <printnum+0x8a>
  8005c9:	eb 5e                	jmp    800629 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005cb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005cf:	83 eb 01             	sub    $0x1,%ebx
  8005d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8005d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005dd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005e1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ec:	00 
  8005ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005f0:	89 04 24             	mov    %eax,(%esp)
  8005f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fa:	e8 71 09 00 00       	call   800f70 <__udivdi3>
  8005ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800603:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800607:	89 04 24             	mov    %eax,(%esp)
  80060a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80060e:	89 fa                	mov    %edi,%edx
  800610:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800613:	e8 78 ff ff ff       	call   800590 <printnum>
  800618:	eb 0f                	jmp    800629 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80061a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061e:	89 34 24             	mov    %esi,(%esp)
  800621:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800624:	83 eb 01             	sub    $0x1,%ebx
  800627:	75 f1                	jne    80061a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800629:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800631:	8b 45 10             	mov    0x10(%ebp),%eax
  800634:	89 44 24 08          	mov    %eax,0x8(%esp)
  800638:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80063f:	00 
  800640:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800649:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064d:	e8 4e 0a 00 00       	call   8010a0 <__umoddi3>
  800652:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800656:	0f be 80 7e 12 80 00 	movsbl 0x80127e(%eax),%eax
  80065d:	89 04 24             	mov    %eax,(%esp)
  800660:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800663:	83 c4 3c             	add    $0x3c,%esp
  800666:	5b                   	pop    %ebx
  800667:	5e                   	pop    %esi
  800668:	5f                   	pop    %edi
  800669:	5d                   	pop    %ebp
  80066a:	c3                   	ret    

0080066b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80066b:	55                   	push   %ebp
  80066c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80066e:	83 fa 01             	cmp    $0x1,%edx
  800671:	7e 0e                	jle    800681 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800673:	8b 10                	mov    (%eax),%edx
  800675:	8d 4a 08             	lea    0x8(%edx),%ecx
  800678:	89 08                	mov    %ecx,(%eax)
  80067a:	8b 02                	mov    (%edx),%eax
  80067c:	8b 52 04             	mov    0x4(%edx),%edx
  80067f:	eb 22                	jmp    8006a3 <getuint+0x38>
	else if (lflag)
  800681:	85 d2                	test   %edx,%edx
  800683:	74 10                	je     800695 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800685:	8b 10                	mov    (%eax),%edx
  800687:	8d 4a 04             	lea    0x4(%edx),%ecx
  80068a:	89 08                	mov    %ecx,(%eax)
  80068c:	8b 02                	mov    (%edx),%eax
  80068e:	ba 00 00 00 00       	mov    $0x0,%edx
  800693:	eb 0e                	jmp    8006a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800695:	8b 10                	mov    (%eax),%edx
  800697:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069a:	89 08                	mov    %ecx,(%eax)
  80069c:	8b 02                	mov    (%edx),%eax
  80069e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a3:	5d                   	pop    %ebp
  8006a4:	c3                   	ret    

008006a5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006a8:	83 fa 01             	cmp    $0x1,%edx
  8006ab:	7e 0e                	jle    8006bb <getint+0x16>
		return va_arg(*ap, long long);
  8006ad:	8b 10                	mov    (%eax),%edx
  8006af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006b2:	89 08                	mov    %ecx,(%eax)
  8006b4:	8b 02                	mov    (%edx),%eax
  8006b6:	8b 52 04             	mov    0x4(%edx),%edx
  8006b9:	eb 22                	jmp    8006dd <getint+0x38>
	else if (lflag)
  8006bb:	85 d2                	test   %edx,%edx
  8006bd:	74 10                	je     8006cf <getint+0x2a>
		return va_arg(*ap, long);
  8006bf:	8b 10                	mov    (%eax),%edx
  8006c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006c4:	89 08                	mov    %ecx,(%eax)
  8006c6:	8b 02                	mov    (%edx),%eax
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	c1 fa 1f             	sar    $0x1f,%edx
  8006cd:	eb 0e                	jmp    8006dd <getint+0x38>
	else
		return va_arg(*ap, int);
  8006cf:	8b 10                	mov    (%eax),%edx
  8006d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006d4:	89 08                	mov    %ecx,(%eax)
  8006d6:	8b 02                	mov    (%edx),%eax
  8006d8:	89 c2                	mov    %eax,%edx
  8006da:	c1 fa 1f             	sar    $0x1f,%edx
}
  8006dd:	5d                   	pop    %ebp
  8006de:	c3                   	ret    

008006df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006e9:	8b 10                	mov    (%eax),%edx
  8006eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8006ee:	73 0a                	jae    8006fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8006f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f3:	88 0a                	mov    %cl,(%edx)
  8006f5:	83 c2 01             	add    $0x1,%edx
  8006f8:	89 10                	mov    %edx,(%eax)
}
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800702:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800705:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800709:	8b 45 10             	mov    0x10(%ebp),%eax
  80070c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800710:	8b 45 0c             	mov    0xc(%ebp),%eax
  800713:	89 44 24 04          	mov    %eax,0x4(%esp)
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	89 04 24             	mov    %eax,(%esp)
  80071d:	e8 02 00 00 00       	call   800724 <vprintfmt>
	va_end(ap);
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	57                   	push   %edi
  800728:	56                   	push   %esi
  800729:	53                   	push   %ebx
  80072a:	83 ec 4c             	sub    $0x4c,%esp
  80072d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800730:	8b 75 10             	mov    0x10(%ebp),%esi
  800733:	eb 12                	jmp    800747 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800735:	85 c0                	test   %eax,%eax
  800737:	0f 84 77 03 00 00    	je     800ab4 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
  80073d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800741:	89 04 24             	mov    %eax,(%esp)
  800744:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800747:	0f b6 06             	movzbl (%esi),%eax
  80074a:	83 c6 01             	add    $0x1,%esi
  80074d:	83 f8 25             	cmp    $0x25,%eax
  800750:	75 e3                	jne    800735 <vprintfmt+0x11>
  800752:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800756:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80075d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800762:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800769:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800771:	eb 2b                	jmp    80079e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800773:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800776:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80077a:	eb 22                	jmp    80079e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80077f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800783:	eb 19                	jmp    80079e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800785:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800788:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80078f:	eb 0d                	jmp    80079e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800791:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800794:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800797:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	0f b6 06             	movzbl (%esi),%eax
  8007a1:	0f b6 d0             	movzbl %al,%edx
  8007a4:	8d 7e 01             	lea    0x1(%esi),%edi
  8007a7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8007aa:	83 e8 23             	sub    $0x23,%eax
  8007ad:	3c 55                	cmp    $0x55,%al
  8007af:	0f 87 d9 02 00 00    	ja     800a8e <vprintfmt+0x36a>
  8007b5:	0f b6 c0             	movzbl %al,%eax
  8007b8:	ff 24 85 40 13 80 00 	jmp    *0x801340(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007bf:	83 ea 30             	sub    $0x30,%edx
  8007c2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8007c5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8007c9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8007cf:	83 fa 09             	cmp    $0x9,%edx
  8007d2:	77 4a                	ja     80081e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007d7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8007da:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8007dd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8007e1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007e4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007e7:	83 fa 09             	cmp    $0x9,%edx
  8007ea:	76 eb                	jbe    8007d7 <vprintfmt+0xb3>
  8007ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007ef:	eb 2d                	jmp    80081e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8d 50 04             	lea    0x4(%eax),%edx
  8007f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fa:	8b 00                	mov    (%eax),%eax
  8007fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800802:	eb 1a                	jmp    80081e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800804:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800807:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80080b:	79 91                	jns    80079e <vprintfmt+0x7a>
  80080d:	e9 73 ff ff ff       	jmp    800785 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800812:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800815:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80081c:	eb 80                	jmp    80079e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80081e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800822:	0f 89 76 ff ff ff    	jns    80079e <vprintfmt+0x7a>
  800828:	e9 64 ff ff ff       	jmp    800791 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80082d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800830:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800833:	e9 66 ff ff ff       	jmp    80079e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8d 50 04             	lea    0x4(%eax),%edx
  80083e:	89 55 14             	mov    %edx,0x14(%ebp)
  800841:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800845:	8b 00                	mov    (%eax),%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800850:	e9 f2 fe ff ff       	jmp    800747 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800855:	8b 45 14             	mov    0x14(%ebp),%eax
  800858:	8d 50 04             	lea    0x4(%eax),%edx
  80085b:	89 55 14             	mov    %edx,0x14(%ebp)
  80085e:	8b 00                	mov    (%eax),%eax
  800860:	89 c2                	mov    %eax,%edx
  800862:	c1 fa 1f             	sar    $0x1f,%edx
  800865:	31 d0                	xor    %edx,%eax
  800867:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800869:	83 f8 08             	cmp    $0x8,%eax
  80086c:	7f 0b                	jg     800879 <vprintfmt+0x155>
  80086e:	8b 14 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%edx
  800875:	85 d2                	test   %edx,%edx
  800877:	75 23                	jne    80089c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800879:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087d:	c7 44 24 08 96 12 80 	movl   $0x801296,0x8(%esp)
  800884:	00 
  800885:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800889:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088c:	89 3c 24             	mov    %edi,(%esp)
  80088f:	e8 68 fe ff ff       	call   8006fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800894:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800897:	e9 ab fe ff ff       	jmp    800747 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80089c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008a0:	c7 44 24 08 9f 12 80 	movl   $0x80129f,0x8(%esp)
  8008a7:	00 
  8008a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008af:	89 3c 24             	mov    %edi,(%esp)
  8008b2:	e8 45 fe ff ff       	call   8006fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008ba:	e9 88 fe ff ff       	jmp    800747 <vprintfmt+0x23>
  8008bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8008d3:	85 f6                	test   %esi,%esi
  8008d5:	ba 8f 12 80 00       	mov    $0x80128f,%edx
  8008da:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8008dd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008e1:	7e 06                	jle    8008e9 <vprintfmt+0x1c5>
  8008e3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8008e7:	75 10                	jne    8008f9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008e9:	0f be 06             	movsbl (%esi),%eax
  8008ec:	83 c6 01             	add    $0x1,%esi
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	0f 85 86 00 00 00    	jne    80097d <vprintfmt+0x259>
  8008f7:	eb 76                	jmp    80096f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008fd:	89 34 24             	mov    %esi,(%esp)
  800900:	e8 56 02 00 00       	call   800b5b <strnlen>
  800905:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800908:	29 c2                	sub    %eax,%edx
  80090a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80090d:	85 d2                	test   %edx,%edx
  80090f:	7e d8                	jle    8008e9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800911:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800915:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800918:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80091b:	89 d6                	mov    %edx,%esi
  80091d:	89 c7                	mov    %eax,%edi
  80091f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800923:	89 3c 24             	mov    %edi,(%esp)
  800926:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800929:	83 ee 01             	sub    $0x1,%esi
  80092c:	75 f1                	jne    80091f <vprintfmt+0x1fb>
  80092e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800931:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800934:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800937:	eb b0                	jmp    8008e9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800939:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80093d:	74 18                	je     800957 <vprintfmt+0x233>
  80093f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800942:	83 fa 5e             	cmp    $0x5e,%edx
  800945:	76 10                	jbe    800957 <vprintfmt+0x233>
					putch('?', putdat);
  800947:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800952:	ff 55 08             	call   *0x8(%ebp)
  800955:	eb 0a                	jmp    800961 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800957:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095b:	89 04 24             	mov    %eax,(%esp)
  80095e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800961:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800965:	0f be 06             	movsbl (%esi),%eax
  800968:	83 c6 01             	add    $0x1,%esi
  80096b:	85 c0                	test   %eax,%eax
  80096d:	75 0e                	jne    80097d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800972:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800976:	7f 11                	jg     800989 <vprintfmt+0x265>
  800978:	e9 ca fd ff ff       	jmp    800747 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80097d:	85 ff                	test   %edi,%edi
  80097f:	90                   	nop
  800980:	78 b7                	js     800939 <vprintfmt+0x215>
  800982:	83 ef 01             	sub    $0x1,%edi
  800985:	79 b2                	jns    800939 <vprintfmt+0x215>
  800987:	eb e6                	jmp    80096f <vprintfmt+0x24b>
  800989:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80098c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80098f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800993:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80099a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80099c:	83 ee 01             	sub    $0x1,%esi
  80099f:	75 ee                	jne    80098f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009a4:	e9 9e fd ff ff       	jmp    800747 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a9:	89 ca                	mov    %ecx,%edx
  8009ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ae:	e8 f2 fc ff ff       	call   8006a5 <getint>
  8009b3:	89 c6                	mov    %eax,%esi
  8009b5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009bc:	85 d2                	test   %edx,%edx
  8009be:	0f 89 8c 00 00 00    	jns    800a50 <vprintfmt+0x32c>
				putch('-', putdat);
  8009c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009d2:	f7 de                	neg    %esi
  8009d4:	83 d7 00             	adc    $0x0,%edi
  8009d7:	f7 df                	neg    %edi
			}
			base = 10;
  8009d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009de:	eb 70                	jmp    800a50 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009e0:	89 ca                	mov    %ecx,%edx
  8009e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e5:	e8 81 fc ff ff       	call   80066b <getuint>
  8009ea:	89 c6                	mov    %eax,%esi
  8009ec:	89 d7                	mov    %edx,%edi
			base = 10;
  8009ee:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009f3:	eb 5b                	jmp    800a50 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
  8009f5:	89 ca                	mov    %ecx,%edx
  8009f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fa:	e8 a6 fc ff ff       	call   8006a5 <getint>
  8009ff:	89 c6                	mov    %eax,%esi
  800a01:	89 d7                	mov    %edx,%edi
			base = 8;
  800a03:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800a08:	eb 46                	jmp    800a50 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a15:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a23:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a26:	8b 45 14             	mov    0x14(%ebp),%eax
  800a29:	8d 50 04             	lea    0x4(%eax),%edx
  800a2c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2f:	8b 30                	mov    (%eax),%esi
  800a31:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a36:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a3b:	eb 13                	jmp    800a50 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3d:	89 ca                	mov    %ecx,%edx
  800a3f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a42:	e8 24 fc ff ff       	call   80066b <getuint>
  800a47:	89 c6                	mov    %eax,%esi
  800a49:	89 d7                	mov    %edx,%edi
			base = 16;
  800a4b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a50:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a54:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a58:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a63:	89 34 24             	mov    %esi,(%esp)
  800a66:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a6a:	89 da                	mov    %ebx,%edx
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	e8 1c fb ff ff       	call   800590 <printnum>
			break;
  800a74:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a77:	e9 cb fc ff ff       	jmp    800747 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a7c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a80:	89 14 24             	mov    %edx,(%esp)
  800a83:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a86:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a89:	e9 b9 fc ff ff       	jmp    800747 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a8e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a92:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a99:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a9c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800aa0:	0f 84 a1 fc ff ff    	je     800747 <vprintfmt+0x23>
  800aa6:	83 ee 01             	sub    $0x1,%esi
  800aa9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800aad:	75 f7                	jne    800aa6 <vprintfmt+0x382>
  800aaf:	e9 93 fc ff ff       	jmp    800747 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800ab4:	83 c4 4c             	add    $0x4c,%esp
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	83 ec 28             	sub    $0x28,%esp
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ac8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800acb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800acf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ad2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	74 30                	je     800b0d <vsnprintf+0x51>
  800add:	85 d2                	test   %edx,%edx
  800adf:	7e 2c                	jle    800b0d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae8:	8b 45 10             	mov    0x10(%ebp),%eax
  800aeb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af6:	c7 04 24 df 06 80 00 	movl   $0x8006df,(%esp)
  800afd:	e8 22 fc ff ff       	call   800724 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b02:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b05:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b0b:	eb 05                	jmp    800b12 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b12:	c9                   	leave  
  800b13:	c3                   	ret    

00800b14 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b1a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b21:	8b 45 10             	mov    0x10(%ebp),%eax
  800b24:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	89 04 24             	mov    %eax,(%esp)
  800b35:	e8 82 ff ff ff       	call   800abc <vsnprintf>
	va_end(ap);

	return rc;
}
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    
  800b3c:	00 00                	add    %al,(%eax)
	...

00800b40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b4e:	74 09                	je     800b59 <strlen+0x19>
		n++;
  800b50:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b53:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b57:	75 f7                	jne    800b50 <strlen+0x10>
		n++;
	return n;
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	53                   	push   %ebx
  800b5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6a:	85 c9                	test   %ecx,%ecx
  800b6c:	74 1a                	je     800b88 <strnlen+0x2d>
  800b6e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b71:	74 15                	je     800b88 <strnlen+0x2d>
  800b73:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800b78:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b7a:	39 ca                	cmp    %ecx,%edx
  800b7c:	74 0a                	je     800b88 <strnlen+0x2d>
  800b7e:	83 c2 01             	add    $0x1,%edx
  800b81:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800b86:	75 f0                	jne    800b78 <strnlen+0x1d>
		n++;
	return n;
}
  800b88:	5b                   	pop    %ebx
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	53                   	push   %ebx
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b9e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ba1:	83 c2 01             	add    $0x1,%edx
  800ba4:	84 c9                	test   %cl,%cl
  800ba6:	75 f2                	jne    800b9a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	53                   	push   %ebx
  800baf:	83 ec 08             	sub    $0x8,%esp
  800bb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bb5:	89 1c 24             	mov    %ebx,(%esp)
  800bb8:	e8 83 ff ff ff       	call   800b40 <strlen>
	strcpy(dst + len, src);
  800bbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc4:	01 d8                	add    %ebx,%eax
  800bc6:	89 04 24             	mov    %eax,(%esp)
  800bc9:	e8 bd ff ff ff       	call   800b8b <strcpy>
	return dst;
}
  800bce:	89 d8                	mov    %ebx,%eax
  800bd0:	83 c4 08             	add    $0x8,%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bde:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be4:	85 f6                	test   %esi,%esi
  800be6:	74 18                	je     800c00 <strncpy+0x2a>
  800be8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bed:	0f b6 1a             	movzbl (%edx),%ebx
  800bf0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bf3:	80 3a 01             	cmpb   $0x1,(%edx)
  800bf6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf9:	83 c1 01             	add    $0x1,%ecx
  800bfc:	39 f1                	cmp    %esi,%ecx
  800bfe:	75 ed                	jne    800bed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c10:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c13:	89 f8                	mov    %edi,%eax
  800c15:	85 f6                	test   %esi,%esi
  800c17:	74 2b                	je     800c44 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800c19:	83 fe 01             	cmp    $0x1,%esi
  800c1c:	74 23                	je     800c41 <strlcpy+0x3d>
  800c1e:	0f b6 0b             	movzbl (%ebx),%ecx
  800c21:	84 c9                	test   %cl,%cl
  800c23:	74 1c                	je     800c41 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c25:	83 ee 02             	sub    $0x2,%esi
  800c28:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c2d:	88 08                	mov    %cl,(%eax)
  800c2f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c32:	39 f2                	cmp    %esi,%edx
  800c34:	74 0b                	je     800c41 <strlcpy+0x3d>
  800c36:	83 c2 01             	add    $0x1,%edx
  800c39:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c3d:	84 c9                	test   %cl,%cl
  800c3f:	75 ec                	jne    800c2d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800c41:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c44:	29 f8                	sub    %edi,%eax
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c51:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c54:	0f b6 01             	movzbl (%ecx),%eax
  800c57:	84 c0                	test   %al,%al
  800c59:	74 16                	je     800c71 <strcmp+0x26>
  800c5b:	3a 02                	cmp    (%edx),%al
  800c5d:	75 12                	jne    800c71 <strcmp+0x26>
		p++, q++;
  800c5f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c62:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800c66:	84 c0                	test   %al,%al
  800c68:	74 07                	je     800c71 <strcmp+0x26>
  800c6a:	83 c1 01             	add    $0x1,%ecx
  800c6d:	3a 02                	cmp    (%edx),%al
  800c6f:	74 ee                	je     800c5f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c71:	0f b6 c0             	movzbl %al,%eax
  800c74:	0f b6 12             	movzbl (%edx),%edx
  800c77:	29 d0                	sub    %edx,%eax
}
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	53                   	push   %ebx
  800c7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c85:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c88:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c8d:	85 d2                	test   %edx,%edx
  800c8f:	74 28                	je     800cb9 <strncmp+0x3e>
  800c91:	0f b6 01             	movzbl (%ecx),%eax
  800c94:	84 c0                	test   %al,%al
  800c96:	74 24                	je     800cbc <strncmp+0x41>
  800c98:	3a 03                	cmp    (%ebx),%al
  800c9a:	75 20                	jne    800cbc <strncmp+0x41>
  800c9c:	83 ea 01             	sub    $0x1,%edx
  800c9f:	74 13                	je     800cb4 <strncmp+0x39>
		n--, p++, q++;
  800ca1:	83 c1 01             	add    $0x1,%ecx
  800ca4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ca7:	0f b6 01             	movzbl (%ecx),%eax
  800caa:	84 c0                	test   %al,%al
  800cac:	74 0e                	je     800cbc <strncmp+0x41>
  800cae:	3a 03                	cmp    (%ebx),%al
  800cb0:	74 ea                	je     800c9c <strncmp+0x21>
  800cb2:	eb 08                	jmp    800cbc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cb9:	5b                   	pop    %ebx
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cbc:	0f b6 01             	movzbl (%ecx),%eax
  800cbf:	0f b6 13             	movzbl (%ebx),%edx
  800cc2:	29 d0                	sub    %edx,%eax
  800cc4:	eb f3                	jmp    800cb9 <strncmp+0x3e>

00800cc6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd0:	0f b6 10             	movzbl (%eax),%edx
  800cd3:	84 d2                	test   %dl,%dl
  800cd5:	74 1c                	je     800cf3 <strchr+0x2d>
		if (*s == c)
  800cd7:	38 ca                	cmp    %cl,%dl
  800cd9:	75 09                	jne    800ce4 <strchr+0x1e>
  800cdb:	eb 1b                	jmp    800cf8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cdd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800ce0:	38 ca                	cmp    %cl,%dl
  800ce2:	74 14                	je     800cf8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ce4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800ce8:	84 d2                	test   %dl,%dl
  800cea:	75 f1                	jne    800cdd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf1:	eb 05                	jmp    800cf8 <strchr+0x32>
  800cf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d04:	0f b6 10             	movzbl (%eax),%edx
  800d07:	84 d2                	test   %dl,%dl
  800d09:	74 14                	je     800d1f <strfind+0x25>
		if (*s == c)
  800d0b:	38 ca                	cmp    %cl,%dl
  800d0d:	75 06                	jne    800d15 <strfind+0x1b>
  800d0f:	eb 0e                	jmp    800d1f <strfind+0x25>
  800d11:	38 ca                	cmp    %cl,%dl
  800d13:	74 0a                	je     800d1f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d15:	83 c0 01             	add    $0x1,%eax
  800d18:	0f b6 10             	movzbl (%eax),%edx
  800d1b:	84 d2                	test   %dl,%dl
  800d1d:	75 f2                	jne    800d11 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d2a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d2d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d30:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d39:	85 c9                	test   %ecx,%ecx
  800d3b:	74 30                	je     800d6d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d43:	75 25                	jne    800d6a <memset+0x49>
  800d45:	f6 c1 03             	test   $0x3,%cl
  800d48:	75 20                	jne    800d6a <memset+0x49>
		c &= 0xFF;
  800d4a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d4d:	89 d3                	mov    %edx,%ebx
  800d4f:	c1 e3 08             	shl    $0x8,%ebx
  800d52:	89 d6                	mov    %edx,%esi
  800d54:	c1 e6 18             	shl    $0x18,%esi
  800d57:	89 d0                	mov    %edx,%eax
  800d59:	c1 e0 10             	shl    $0x10,%eax
  800d5c:	09 f0                	or     %esi,%eax
  800d5e:	09 d0                	or     %edx,%eax
  800d60:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d62:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d65:	fc                   	cld    
  800d66:	f3 ab                	rep stos %eax,%es:(%edi)
  800d68:	eb 03                	jmp    800d6d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d6a:	fc                   	cld    
  800d6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d6d:	89 f8                	mov    %edi,%eax
  800d6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d78:	89 ec                	mov    %ebp,%esp
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 08             	sub    $0x8,%esp
  800d82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d85:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d91:	39 c6                	cmp    %eax,%esi
  800d93:	73 36                	jae    800dcb <memmove+0x4f>
  800d95:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d98:	39 d0                	cmp    %edx,%eax
  800d9a:	73 2f                	jae    800dcb <memmove+0x4f>
		s += n;
		d += n;
  800d9c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d9f:	f6 c2 03             	test   $0x3,%dl
  800da2:	75 1b                	jne    800dbf <memmove+0x43>
  800da4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800daa:	75 13                	jne    800dbf <memmove+0x43>
  800dac:	f6 c1 03             	test   $0x3,%cl
  800daf:	75 0e                	jne    800dbf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800db1:	83 ef 04             	sub    $0x4,%edi
  800db4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800db7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800dba:	fd                   	std    
  800dbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dbd:	eb 09                	jmp    800dc8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800dbf:	83 ef 01             	sub    $0x1,%edi
  800dc2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dc5:	fd                   	std    
  800dc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dc8:	fc                   	cld    
  800dc9:	eb 20                	jmp    800deb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dcb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dd1:	75 13                	jne    800de6 <memmove+0x6a>
  800dd3:	a8 03                	test   $0x3,%al
  800dd5:	75 0f                	jne    800de6 <memmove+0x6a>
  800dd7:	f6 c1 03             	test   $0x3,%cl
  800dda:	75 0a                	jne    800de6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ddc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ddf:	89 c7                	mov    %eax,%edi
  800de1:	fc                   	cld    
  800de2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800de4:	eb 05                	jmp    800deb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800de6:	89 c7                	mov    %eax,%edi
  800de8:	fc                   	cld    
  800de9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800deb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df1:	89 ec                	mov    %ebp,%esp
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dfb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dfe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e09:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0c:	89 04 24             	mov    %eax,(%esp)
  800e0f:	e8 68 ff ff ff       	call   800d7c <memmove>
}
  800e14:	c9                   	leave  
  800e15:	c3                   	ret    

00800e16 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e22:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e25:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e2a:	85 ff                	test   %edi,%edi
  800e2c:	74 37                	je     800e65 <memcmp+0x4f>
		if (*s1 != *s2)
  800e2e:	0f b6 03             	movzbl (%ebx),%eax
  800e31:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e34:	83 ef 01             	sub    $0x1,%edi
  800e37:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e3c:	38 c8                	cmp    %cl,%al
  800e3e:	74 1c                	je     800e5c <memcmp+0x46>
  800e40:	eb 10                	jmp    800e52 <memcmp+0x3c>
  800e42:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e47:	83 c2 01             	add    $0x1,%edx
  800e4a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e4e:	38 c8                	cmp    %cl,%al
  800e50:	74 0a                	je     800e5c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800e52:	0f b6 c0             	movzbl %al,%eax
  800e55:	0f b6 c9             	movzbl %cl,%ecx
  800e58:	29 c8                	sub    %ecx,%eax
  800e5a:	eb 09                	jmp    800e65 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e5c:	39 fa                	cmp    %edi,%edx
  800e5e:	75 e2                	jne    800e42 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e70:	89 c2                	mov    %eax,%edx
  800e72:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e75:	39 d0                	cmp    %edx,%eax
  800e77:	73 19                	jae    800e92 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e79:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e7d:	38 08                	cmp    %cl,(%eax)
  800e7f:	75 06                	jne    800e87 <memfind+0x1d>
  800e81:	eb 0f                	jmp    800e92 <memfind+0x28>
  800e83:	38 08                	cmp    %cl,(%eax)
  800e85:	74 0b                	je     800e92 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e87:	83 c0 01             	add    $0x1,%eax
  800e8a:	39 d0                	cmp    %edx,%eax
  800e8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e90:	75 f1                	jne    800e83 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
  800e9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ea0:	0f b6 02             	movzbl (%edx),%eax
  800ea3:	3c 20                	cmp    $0x20,%al
  800ea5:	74 04                	je     800eab <strtol+0x17>
  800ea7:	3c 09                	cmp    $0x9,%al
  800ea9:	75 0e                	jne    800eb9 <strtol+0x25>
		s++;
  800eab:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eae:	0f b6 02             	movzbl (%edx),%eax
  800eb1:	3c 20                	cmp    $0x20,%al
  800eb3:	74 f6                	je     800eab <strtol+0x17>
  800eb5:	3c 09                	cmp    $0x9,%al
  800eb7:	74 f2                	je     800eab <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eb9:	3c 2b                	cmp    $0x2b,%al
  800ebb:	75 0a                	jne    800ec7 <strtol+0x33>
		s++;
  800ebd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ec0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ec5:	eb 10                	jmp    800ed7 <strtol+0x43>
  800ec7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ecc:	3c 2d                	cmp    $0x2d,%al
  800ece:	75 07                	jne    800ed7 <strtol+0x43>
		s++, neg = 1;
  800ed0:	83 c2 01             	add    $0x1,%edx
  800ed3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ed7:	85 db                	test   %ebx,%ebx
  800ed9:	0f 94 c0             	sete   %al
  800edc:	74 05                	je     800ee3 <strtol+0x4f>
  800ede:	83 fb 10             	cmp    $0x10,%ebx
  800ee1:	75 15                	jne    800ef8 <strtol+0x64>
  800ee3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ee6:	75 10                	jne    800ef8 <strtol+0x64>
  800ee8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800eec:	75 0a                	jne    800ef8 <strtol+0x64>
		s += 2, base = 16;
  800eee:	83 c2 02             	add    $0x2,%edx
  800ef1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ef6:	eb 13                	jmp    800f0b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ef8:	84 c0                	test   %al,%al
  800efa:	74 0f                	je     800f0b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800efc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f01:	80 3a 30             	cmpb   $0x30,(%edx)
  800f04:	75 05                	jne    800f0b <strtol+0x77>
		s++, base = 8;
  800f06:	83 c2 01             	add    $0x1,%edx
  800f09:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800f0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f10:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f12:	0f b6 0a             	movzbl (%edx),%ecx
  800f15:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f18:	80 fb 09             	cmp    $0x9,%bl
  800f1b:	77 08                	ja     800f25 <strtol+0x91>
			dig = *s - '0';
  800f1d:	0f be c9             	movsbl %cl,%ecx
  800f20:	83 e9 30             	sub    $0x30,%ecx
  800f23:	eb 1e                	jmp    800f43 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800f25:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f28:	80 fb 19             	cmp    $0x19,%bl
  800f2b:	77 08                	ja     800f35 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800f2d:	0f be c9             	movsbl %cl,%ecx
  800f30:	83 e9 57             	sub    $0x57,%ecx
  800f33:	eb 0e                	jmp    800f43 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800f35:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f38:	80 fb 19             	cmp    $0x19,%bl
  800f3b:	77 14                	ja     800f51 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f3d:	0f be c9             	movsbl %cl,%ecx
  800f40:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f43:	39 f1                	cmp    %esi,%ecx
  800f45:	7d 0e                	jge    800f55 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800f47:	83 c2 01             	add    $0x1,%edx
  800f4a:	0f af c6             	imul   %esi,%eax
  800f4d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f4f:	eb c1                	jmp    800f12 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f51:	89 c1                	mov    %eax,%ecx
  800f53:	eb 02                	jmp    800f57 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f55:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f5b:	74 05                	je     800f62 <strtol+0xce>
		*endptr = (char *) s;
  800f5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f60:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f62:	89 ca                	mov    %ecx,%edx
  800f64:	f7 da                	neg    %edx
  800f66:	85 ff                	test   %edi,%edi
  800f68:	0f 45 c2             	cmovne %edx,%eax
}
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <__udivdi3>:
  800f70:	83 ec 1c             	sub    $0x1c,%esp
  800f73:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f77:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f7b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f7f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f83:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f87:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f8b:	85 ff                	test   %edi,%edi
  800f8d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f95:	89 cd                	mov    %ecx,%ebp
  800f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9b:	75 33                	jne    800fd0 <__udivdi3+0x60>
  800f9d:	39 f1                	cmp    %esi,%ecx
  800f9f:	77 57                	ja     800ff8 <__udivdi3+0x88>
  800fa1:	85 c9                	test   %ecx,%ecx
  800fa3:	75 0b                	jne    800fb0 <__udivdi3+0x40>
  800fa5:	b8 01 00 00 00       	mov    $0x1,%eax
  800faa:	31 d2                	xor    %edx,%edx
  800fac:	f7 f1                	div    %ecx
  800fae:	89 c1                	mov    %eax,%ecx
  800fb0:	89 f0                	mov    %esi,%eax
  800fb2:	31 d2                	xor    %edx,%edx
  800fb4:	f7 f1                	div    %ecx
  800fb6:	89 c6                	mov    %eax,%esi
  800fb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fbc:	f7 f1                	div    %ecx
  800fbe:	89 f2                	mov    %esi,%edx
  800fc0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fc4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fc8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fcc:	83 c4 1c             	add    $0x1c,%esp
  800fcf:	c3                   	ret    
  800fd0:	31 d2                	xor    %edx,%edx
  800fd2:	31 c0                	xor    %eax,%eax
  800fd4:	39 f7                	cmp    %esi,%edi
  800fd6:	77 e8                	ja     800fc0 <__udivdi3+0x50>
  800fd8:	0f bd cf             	bsr    %edi,%ecx
  800fdb:	83 f1 1f             	xor    $0x1f,%ecx
  800fde:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fe2:	75 2c                	jne    801010 <__udivdi3+0xa0>
  800fe4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fe8:	76 04                	jbe    800fee <__udivdi3+0x7e>
  800fea:	39 f7                	cmp    %esi,%edi
  800fec:	73 d2                	jae    800fc0 <__udivdi3+0x50>
  800fee:	31 d2                	xor    %edx,%edx
  800ff0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff5:	eb c9                	jmp    800fc0 <__udivdi3+0x50>
  800ff7:	90                   	nop
  800ff8:	89 f2                	mov    %esi,%edx
  800ffa:	f7 f1                	div    %ecx
  800ffc:	31 d2                	xor    %edx,%edx
  800ffe:	8b 74 24 10          	mov    0x10(%esp),%esi
  801002:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801006:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80100a:	83 c4 1c             	add    $0x1c,%esp
  80100d:	c3                   	ret    
  80100e:	66 90                	xchg   %ax,%ax
  801010:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801015:	b8 20 00 00 00       	mov    $0x20,%eax
  80101a:	89 ea                	mov    %ebp,%edx
  80101c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801020:	d3 e7                	shl    %cl,%edi
  801022:	89 c1                	mov    %eax,%ecx
  801024:	d3 ea                	shr    %cl,%edx
  801026:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80102b:	09 fa                	or     %edi,%edx
  80102d:	89 f7                	mov    %esi,%edi
  80102f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801033:	89 f2                	mov    %esi,%edx
  801035:	8b 74 24 08          	mov    0x8(%esp),%esi
  801039:	d3 e5                	shl    %cl,%ebp
  80103b:	89 c1                	mov    %eax,%ecx
  80103d:	d3 ef                	shr    %cl,%edi
  80103f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801044:	d3 e2                	shl    %cl,%edx
  801046:	89 c1                	mov    %eax,%ecx
  801048:	d3 ee                	shr    %cl,%esi
  80104a:	09 d6                	or     %edx,%esi
  80104c:	89 fa                	mov    %edi,%edx
  80104e:	89 f0                	mov    %esi,%eax
  801050:	f7 74 24 0c          	divl   0xc(%esp)
  801054:	89 d7                	mov    %edx,%edi
  801056:	89 c6                	mov    %eax,%esi
  801058:	f7 e5                	mul    %ebp
  80105a:	39 d7                	cmp    %edx,%edi
  80105c:	72 22                	jb     801080 <__udivdi3+0x110>
  80105e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801062:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801067:	d3 e5                	shl    %cl,%ebp
  801069:	39 c5                	cmp    %eax,%ebp
  80106b:	73 04                	jae    801071 <__udivdi3+0x101>
  80106d:	39 d7                	cmp    %edx,%edi
  80106f:	74 0f                	je     801080 <__udivdi3+0x110>
  801071:	89 f0                	mov    %esi,%eax
  801073:	31 d2                	xor    %edx,%edx
  801075:	e9 46 ff ff ff       	jmp    800fc0 <__udivdi3+0x50>
  80107a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801080:	8d 46 ff             	lea    -0x1(%esi),%eax
  801083:	31 d2                	xor    %edx,%edx
  801085:	8b 74 24 10          	mov    0x10(%esp),%esi
  801089:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80108d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801091:	83 c4 1c             	add    $0x1c,%esp
  801094:	c3                   	ret    
	...

008010a0 <__umoddi3>:
  8010a0:	83 ec 1c             	sub    $0x1c,%esp
  8010a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8010ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010bb:	85 ed                	test   %ebp,%ebp
  8010bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c5:	89 cf                	mov    %ecx,%edi
  8010c7:	89 04 24             	mov    %eax,(%esp)
  8010ca:	89 f2                	mov    %esi,%edx
  8010cc:	75 1a                	jne    8010e8 <__umoddi3+0x48>
  8010ce:	39 f1                	cmp    %esi,%ecx
  8010d0:	76 4e                	jbe    801120 <__umoddi3+0x80>
  8010d2:	f7 f1                	div    %ecx
  8010d4:	89 d0                	mov    %edx,%eax
  8010d6:	31 d2                	xor    %edx,%edx
  8010d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010e4:	83 c4 1c             	add    $0x1c,%esp
  8010e7:	c3                   	ret    
  8010e8:	39 f5                	cmp    %esi,%ebp
  8010ea:	77 54                	ja     801140 <__umoddi3+0xa0>
  8010ec:	0f bd c5             	bsr    %ebp,%eax
  8010ef:	83 f0 1f             	xor    $0x1f,%eax
  8010f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f6:	75 60                	jne    801158 <__umoddi3+0xb8>
  8010f8:	3b 0c 24             	cmp    (%esp),%ecx
  8010fb:	0f 87 07 01 00 00    	ja     801208 <__umoddi3+0x168>
  801101:	89 f2                	mov    %esi,%edx
  801103:	8b 34 24             	mov    (%esp),%esi
  801106:	29 ce                	sub    %ecx,%esi
  801108:	19 ea                	sbb    %ebp,%edx
  80110a:	89 34 24             	mov    %esi,(%esp)
  80110d:	8b 04 24             	mov    (%esp),%eax
  801110:	8b 74 24 10          	mov    0x10(%esp),%esi
  801114:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801118:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80111c:	83 c4 1c             	add    $0x1c,%esp
  80111f:	c3                   	ret    
  801120:	85 c9                	test   %ecx,%ecx
  801122:	75 0b                	jne    80112f <__umoddi3+0x8f>
  801124:	b8 01 00 00 00       	mov    $0x1,%eax
  801129:	31 d2                	xor    %edx,%edx
  80112b:	f7 f1                	div    %ecx
  80112d:	89 c1                	mov    %eax,%ecx
  80112f:	89 f0                	mov    %esi,%eax
  801131:	31 d2                	xor    %edx,%edx
  801133:	f7 f1                	div    %ecx
  801135:	8b 04 24             	mov    (%esp),%eax
  801138:	f7 f1                	div    %ecx
  80113a:	eb 98                	jmp    8010d4 <__umoddi3+0x34>
  80113c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801140:	89 f2                	mov    %esi,%edx
  801142:	8b 74 24 10          	mov    0x10(%esp),%esi
  801146:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80114a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80114e:	83 c4 1c             	add    $0x1c,%esp
  801151:	c3                   	ret    
  801152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801158:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115d:	89 e8                	mov    %ebp,%eax
  80115f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801164:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801168:	89 fa                	mov    %edi,%edx
  80116a:	d3 e0                	shl    %cl,%eax
  80116c:	89 e9                	mov    %ebp,%ecx
  80116e:	d3 ea                	shr    %cl,%edx
  801170:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801175:	09 c2                	or     %eax,%edx
  801177:	8b 44 24 08          	mov    0x8(%esp),%eax
  80117b:	89 14 24             	mov    %edx,(%esp)
  80117e:	89 f2                	mov    %esi,%edx
  801180:	d3 e7                	shl    %cl,%edi
  801182:	89 e9                	mov    %ebp,%ecx
  801184:	d3 ea                	shr    %cl,%edx
  801186:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80118b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80118f:	d3 e6                	shl    %cl,%esi
  801191:	89 e9                	mov    %ebp,%ecx
  801193:	d3 e8                	shr    %cl,%eax
  801195:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80119a:	09 f0                	or     %esi,%eax
  80119c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011a0:	f7 34 24             	divl   (%esp)
  8011a3:	d3 e6                	shl    %cl,%esi
  8011a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011a9:	89 d6                	mov    %edx,%esi
  8011ab:	f7 e7                	mul    %edi
  8011ad:	39 d6                	cmp    %edx,%esi
  8011af:	89 c1                	mov    %eax,%ecx
  8011b1:	89 d7                	mov    %edx,%edi
  8011b3:	72 3f                	jb     8011f4 <__umoddi3+0x154>
  8011b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8011b9:	72 35                	jb     8011f0 <__umoddi3+0x150>
  8011bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011bf:	29 c8                	sub    %ecx,%eax
  8011c1:	19 fe                	sbb    %edi,%esi
  8011c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011c8:	89 f2                	mov    %esi,%edx
  8011ca:	d3 e8                	shr    %cl,%eax
  8011cc:	89 e9                	mov    %ebp,%ecx
  8011ce:	d3 e2                	shl    %cl,%edx
  8011d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011d5:	09 d0                	or     %edx,%eax
  8011d7:	89 f2                	mov    %esi,%edx
  8011d9:	d3 ea                	shr    %cl,%edx
  8011db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011e7:	83 c4 1c             	add    $0x1c,%esp
  8011ea:	c3                   	ret    
  8011eb:	90                   	nop
  8011ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	39 d6                	cmp    %edx,%esi
  8011f2:	75 c7                	jne    8011bb <__umoddi3+0x11b>
  8011f4:	89 d7                	mov    %edx,%edi
  8011f6:	89 c1                	mov    %eax,%ecx
  8011f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011fc:	1b 3c 24             	sbb    (%esp),%edi
  8011ff:	eb ba                	jmp    8011bb <__umoddi3+0x11b>
  801201:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801208:	39 f5                	cmp    %esi,%ebp
  80120a:	0f 82 f1 fe ff ff    	jb     801101 <__umoddi3+0x61>
  801210:	e9 f8 fe ff ff       	jmp    80110d <__umoddi3+0x6d>
