
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 be 22 f0    	mov    %esi,0xf022be80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 3c 65 00 00       	call   f01065a0 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 e0 6c 10 f0 	movl   $0xf0106ce0,(%esp)
f010007d:	e8 54 40 00 00       	call   f01040d6 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 15 40 00 00       	call   f01040a3 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 93 7e 10 f0 	movl   $0xf0107e93,(%esp)
f0100095:	e8 3c 40 00 00       	call   f01040d6 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 61 09 00 00       	call   f0100a07 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 4b 6d 10 f0 	movl   $0xf0106d4b,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 b9 64 00 00       	call   f01065a0 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 57 6d 10 f0 	movl   $0xf0106d57,(%esp)
f01000f2:	e8 df 3f 00 00       	call   f01040d6 <cprintf>

	lapic_init();
f01000f7:	e8 be 64 00 00       	call   f01065ba <lapic_init>
	env_init_percpu();
f01000fc:	e8 18 37 00 00       	call   f0103819 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 ea 3f 00 00       	call   f01040f0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 95 64 00 00       	call   f01065a0 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 a0 24 12 f0 	movl   $0xf01224a0,(%esp)
f0100124:	e8 27 67 00 00       	call   f0106850 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100129:	e8 4a 4a 00 00       	call   f0104b78 <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100135:	b8 08 d0 26 f0       	mov    $0xf026d008,%eax
f010013a:	2d 1c a4 22 f0       	sub    $0xf022a41c,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 1c a4 22 f0 	movl   $0xf022a41c,(%esp)
f0100152:	e8 ba 5d 00 00       	call   f0105f11 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 66 05 00 00       	call   f01006c2 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 6d 6d 10 f0 	movl   $0xf0106d6d,(%esp)
f010016b:	e8 66 3f 00 00       	call   f01040d6 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 77 14 00 00       	call   f01015ec <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 c9 36 00 00       	call   f0103843 <env_init>
	trap_init();
f010017a:	e8 0e 40 00 00       	call   f010418d <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	90                   	nop
f0100180:	e8 3c 61 00 00       	call   f01062c1 <mp_init>
	lapic_init();
f0100185:	e8 30 64 00 00       	call   f01065ba <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010018a:	e8 76 3e 00 00       	call   f0104005 <pic_init>
f010018f:	c7 04 24 a0 24 12 f0 	movl   $0xf01224a0,(%esp)
f0100196:	e8 b5 66 00 00       	call   f0106850 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010019b:	83 3d 88 be 22 f0 07 	cmpl   $0x7,0xf022be88
f01001a2:	77 24                	ja     f01001c8 <i386_init+0x9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001a4:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001ab:	00 
f01001ac:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f01001b3:	f0 
f01001b4:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01001bb:	00 
f01001bc:	c7 04 24 4b 6d 10 f0 	movl   $0xf0106d4b,(%esp)
f01001c3:	e8 78 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c8:	b8 da 61 10 f0       	mov    $0xf01061da,%eax
f01001cd:	2d 60 61 10 f0       	sub    $0xf0106160,%eax
f01001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d6:	c7 44 24 04 60 61 10 	movl   $0xf0106160,0x4(%esp)
f01001dd:	f0 
f01001de:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e5:	e8 82 5d 00 00       	call   f0105f6c <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001ea:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f01001f1:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01001f6:	3d 20 c0 22 f0       	cmp    $0xf022c020,%eax
f01001fb:	76 62                	jbe    f010025f <i386_init+0x131>
f01001fd:	bb 20 c0 22 f0       	mov    $0xf022c020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100202:	e8 99 63 00 00       	call   f01065a0 <cpunum>
f0100207:	6b c0 74             	imul   $0x74,%eax,%eax
f010020a:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010020f:	39 c3                	cmp    %eax,%ebx
f0100211:	74 39                	je     f010024c <i386_init+0x11e>

static void boot_aps(void);


void
i386_init(void)
f0100213:	89 d8                	mov    %ebx,%eax
f0100215:	2d 20 c0 22 f0       	sub    $0xf022c020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010021a:	c1 f8 02             	sar    $0x2,%eax
f010021d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100223:	c1 e0 0f             	shl    $0xf,%eax
f0100226:	8d 80 00 50 23 f0    	lea    -0xfdcb000(%eax),%eax
f010022c:	a3 84 be 22 f0       	mov    %eax,0xf022be84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100231:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100238:	00 
f0100239:	0f b6 03             	movzbl (%ebx),%eax
f010023c:	89 04 24             	mov    %eax,(%esp)
f010023f:	e8 c4 64 00 00       	call   f0106708 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100244:	8b 43 04             	mov    0x4(%ebx),%eax
f0100247:	83 f8 01             	cmp    $0x1,%eax
f010024a:	75 f8                	jne    f0100244 <i386_init+0x116>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010024c:	83 c3 74             	add    $0x74,%ebx
f010024f:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f0100256:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010025b:	39 c3                	cmp    %eax,%ebx
f010025d:	72 a3                	jb     f0100202 <i386_init+0xd4>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010025f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100266:	00 
f0100267:	c7 44 24 04 8b 9a 00 	movl   $0x9a8b,0x4(%esp)
f010026e:	00 
f010026f:	c7 04 24 91 09 22 f0 	movl   $0xf0220991,(%esp)
f0100276:	e8 e1 37 00 00       	call   f0103a5c <env_create>
	ENV_CREATE(user_yield,ENV_TYPE_USER);
	ENV_CREATE(user_yield,ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f010027b:	e8 f8 48 00 00       	call   f0104b78 <sched_yield>

f0100280 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100280:	55                   	push   %ebp
f0100281:	89 e5                	mov    %esp,%ebp
f0100283:	53                   	push   %ebx
f0100284:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100287:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010028a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010028d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100291:	8b 45 08             	mov    0x8(%ebp),%eax
f0100294:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100298:	c7 04 24 88 6d 10 f0 	movl   $0xf0106d88,(%esp)
f010029f:	e8 32 3e 00 00       	call   f01040d6 <cprintf>
	vcprintf(fmt, ap);
f01002a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002a8:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ab:	89 04 24             	mov    %eax,(%esp)
f01002ae:	e8 f0 3d 00 00       	call   f01040a3 <vcprintf>
	cprintf("\n");
f01002b3:	c7 04 24 93 7e 10 f0 	movl   $0xf0107e93,(%esp)
f01002ba:	e8 17 3e 00 00       	call   f01040d6 <cprintf>
	va_end(ap);
}
f01002bf:	83 c4 14             	add    $0x14,%esp
f01002c2:	5b                   	pop    %ebx
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    
	...

f01002d0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002d0:	55                   	push   %ebp
f01002d1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002d8:	ec                   	in     (%dx),%al
f01002d9:	ec                   	in     (%dx),%al
f01002da:	ec                   	in     (%dx),%al
f01002db:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002dc:	5d                   	pop    %ebp
f01002dd:	c3                   	ret    

f01002de <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002de:	55                   	push   %ebp
f01002df:	89 e5                	mov    %esp,%ebp
f01002e1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002e6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002e7:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002ec:	a8 01                	test   $0x1,%al
f01002ee:	74 06                	je     f01002f6 <serial_proc_data+0x18>
f01002f0:	b2 f8                	mov    $0xf8,%dl
f01002f2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002f3:	0f b6 c8             	movzbl %al,%ecx
}
f01002f6:	89 c8                	mov    %ecx,%eax
f01002f8:	5d                   	pop    %ebp
f01002f9:	c3                   	ret    

f01002fa <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002fa:	55                   	push   %ebp
f01002fb:	89 e5                	mov    %esp,%ebp
f01002fd:	53                   	push   %ebx
f01002fe:	83 ec 04             	sub    $0x4,%esp
f0100301:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100303:	eb 25                	jmp    f010032a <cons_intr+0x30>
		if (c == 0)
f0100305:	85 c0                	test   %eax,%eax
f0100307:	74 21                	je     f010032a <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f0100309:	8b 15 24 b2 22 f0    	mov    0xf022b224,%edx
f010030f:	88 82 20 b0 22 f0    	mov    %al,-0xfdd4fe0(%edx)
f0100315:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100318:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010031d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100322:	0f 44 c2             	cmove  %edx,%eax
f0100325:	a3 24 b2 22 f0       	mov    %eax,0xf022b224
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010032a:	ff d3                	call   *%ebx
f010032c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010032f:	75 d4                	jne    f0100305 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100331:	83 c4 04             	add    $0x4,%esp
f0100334:	5b                   	pop    %ebx
f0100335:	5d                   	pop    %ebp
f0100336:	c3                   	ret    

f0100337 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100337:	55                   	push   %ebp
f0100338:	89 e5                	mov    %esp,%ebp
f010033a:	57                   	push   %edi
f010033b:	56                   	push   %esi
f010033c:	53                   	push   %ebx
f010033d:	83 ec 2c             	sub    $0x2c,%esp
f0100340:	89 c7                	mov    %eax,%edi
f0100342:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100347:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100348:	a8 20                	test   $0x20,%al
f010034a:	75 1b                	jne    f0100367 <cons_putc+0x30>
f010034c:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100351:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100356:	e8 75 ff ff ff       	call   f01002d0 <delay>
f010035b:	89 f2                	mov    %esi,%edx
f010035d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010035e:	a8 20                	test   $0x20,%al
f0100360:	75 05                	jne    f0100367 <cons_putc+0x30>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100362:	83 eb 01             	sub    $0x1,%ebx
f0100365:	75 ef                	jne    f0100356 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100367:	89 fa                	mov    %edi,%edx
f0100369:	89 f8                	mov    %edi,%eax
f010036b:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100373:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100374:	b2 79                	mov    $0x79,%dl
f0100376:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100377:	84 c0                	test   %al,%al
f0100379:	78 1b                	js     f0100396 <cons_putc+0x5f>
f010037b:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100380:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100385:	e8 46 ff ff ff       	call   f01002d0 <delay>
f010038a:	89 f2                	mov    %esi,%edx
f010038c:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010038d:	84 c0                	test   %al,%al
f010038f:	78 05                	js     f0100396 <cons_putc+0x5f>
f0100391:	83 eb 01             	sub    $0x1,%ebx
f0100394:	75 ef                	jne    f0100385 <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100396:	ba 78 03 00 00       	mov    $0x378,%edx
f010039b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010039f:	ee                   	out    %al,(%dx)
f01003a0:	b2 7a                	mov    $0x7a,%dl
f01003a2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003a7:	ee                   	out    %al,(%dx)
f01003a8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ad:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF)){
f01003ae:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003b4:	75 45                	jne    f01003fb <cons_putc+0xc4>
		if(c % 4 == 0)
f01003b6:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01003bc:	75 08                	jne    f01003c6 <cons_putc+0x8f>
			c |= 0x0400;
f01003be:	81 cf 00 04 00 00    	or     $0x400,%edi
f01003c4:	eb 35                	jmp    f01003fb <cons_putc+0xc4>
		else if(c%4 == 1)
f01003c6:	89 fa                	mov    %edi,%edx
f01003c8:	c1 fa 1f             	sar    $0x1f,%edx
f01003cb:	c1 ea 1e             	shr    $0x1e,%edx
f01003ce:	8d 04 17             	lea    (%edi,%edx,1),%eax
f01003d1:	83 e0 03             	and    $0x3,%eax
f01003d4:	29 d0                	sub    %edx,%eax
f01003d6:	83 f8 01             	cmp    $0x1,%eax
f01003d9:	75 08                	jne    f01003e3 <cons_putc+0xac>
			c |= 0x0600;
f01003db:	81 cf 00 06 00 00    	or     $0x600,%edi
f01003e1:	eb 18                	jmp    f01003fb <cons_putc+0xc4>
		else if(c%4 == 2)
f01003e3:	83 f8 02             	cmp    $0x2,%eax
f01003e6:	75 08                	jne    f01003f0 <cons_putc+0xb9>
			c |= 0x0800;
f01003e8:	81 cf 00 08 00 00    	or     $0x800,%edi
f01003ee:	eb 0b                	jmp    f01003fb <cons_putc+0xc4>
		else if(c%4 == 3)
			c |= 0x0900;
f01003f0:	89 fa                	mov    %edi,%edx
f01003f2:	80 ce 09             	or     $0x9,%dh
f01003f5:	83 f8 03             	cmp    $0x3,%eax
f01003f8:	0f 44 fa             	cmove  %edx,%edi
	} 

	switch (c & 0xff) {
f01003fb:	89 f8                	mov    %edi,%eax
f01003fd:	25 ff 00 00 00       	and    $0xff,%eax
f0100402:	83 f8 09             	cmp    $0x9,%eax
f0100405:	74 77                	je     f010047e <cons_putc+0x147>
f0100407:	83 f8 09             	cmp    $0x9,%eax
f010040a:	7f 0b                	jg     f0100417 <cons_putc+0xe0>
f010040c:	83 f8 08             	cmp    $0x8,%eax
f010040f:	0f 85 9d 00 00 00    	jne    f01004b2 <cons_putc+0x17b>
f0100415:	eb 11                	jmp    f0100428 <cons_putc+0xf1>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	74 3c                	je     f0100458 <cons_putc+0x121>
f010041c:	83 f8 0d             	cmp    $0xd,%eax
f010041f:	90                   	nop
f0100420:	0f 85 8c 00 00 00    	jne    f01004b2 <cons_putc+0x17b>
f0100426:	eb 38                	jmp    f0100460 <cons_putc+0x129>
	case '\b':
		if (crt_pos > 0) {
f0100428:	0f b7 05 34 b2 22 f0 	movzwl 0xf022b234,%eax
f010042f:	66 85 c0             	test   %ax,%ax
f0100432:	0f 84 e4 00 00 00    	je     f010051c <cons_putc+0x1e5>
			crt_pos--;
f0100438:	83 e8 01             	sub    $0x1,%eax
f010043b:	66 a3 34 b2 22 f0    	mov    %ax,0xf022b234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100441:	0f b7 c0             	movzwl %ax,%eax
f0100444:	66 81 e7 00 ff       	and    $0xff00,%di
f0100449:	83 cf 20             	or     $0x20,%edi
f010044c:	8b 15 30 b2 22 f0    	mov    0xf022b230,%edx
f0100452:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100456:	eb 77                	jmp    f01004cf <cons_putc+0x198>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100458:	66 83 05 34 b2 22 f0 	addw   $0x50,0xf022b234
f010045f:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100460:	0f b7 05 34 b2 22 f0 	movzwl 0xf022b234,%eax
f0100467:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010046d:	c1 e8 16             	shr    $0x16,%eax
f0100470:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100473:	c1 e0 04             	shl    $0x4,%eax
f0100476:	66 a3 34 b2 22 f0    	mov    %ax,0xf022b234
f010047c:	eb 51                	jmp    f01004cf <cons_putc+0x198>
		break;
	case '\t':
		cons_putc(' ');
f010047e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100483:	e8 af fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100488:	b8 20 00 00 00       	mov    $0x20,%eax
f010048d:	e8 a5 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100492:	b8 20 00 00 00       	mov    $0x20,%eax
f0100497:	e8 9b fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f010049c:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a1:	e8 91 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f01004a6:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ab:	e8 87 fe ff ff       	call   f0100337 <cons_putc>
f01004b0:	eb 1d                	jmp    f01004cf <cons_putc+0x198>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004b2:	0f b7 05 34 b2 22 f0 	movzwl 0xf022b234,%eax
f01004b9:	0f b7 c8             	movzwl %ax,%ecx
f01004bc:	8b 15 30 b2 22 f0    	mov    0xf022b230,%edx
f01004c2:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01004c6:	83 c0 01             	add    $0x1,%eax
f01004c9:	66 a3 34 b2 22 f0    	mov    %ax,0xf022b234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01004cf:	66 81 3d 34 b2 22 f0 	cmpw   $0x7cf,0xf022b234
f01004d6:	cf 07 
f01004d8:	76 42                	jbe    f010051c <cons_putc+0x1e5>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004da:	a1 30 b2 22 f0       	mov    0xf022b230,%eax
f01004df:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004e6:	00 
f01004e7:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004ed:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004f1:	89 04 24             	mov    %eax,(%esp)
f01004f4:	e8 73 5a 00 00       	call   f0105f6c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004f9:	8b 15 30 b2 22 f0    	mov    0xf022b230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004ff:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100504:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010050a:	83 c0 01             	add    $0x1,%eax
f010050d:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100512:	75 f0                	jne    f0100504 <cons_putc+0x1cd>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100514:	66 83 2d 34 b2 22 f0 	subw   $0x50,0xf022b234
f010051b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010051c:	8b 0d 2c b2 22 f0    	mov    0xf022b22c,%ecx
f0100522:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100527:	89 ca                	mov    %ecx,%edx
f0100529:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010052a:	0f b7 35 34 b2 22 f0 	movzwl 0xf022b234,%esi
f0100531:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100534:	89 f0                	mov    %esi,%eax
f0100536:	66 c1 e8 08          	shr    $0x8,%ax
f010053a:	89 da                	mov    %ebx,%edx
f010053c:	ee                   	out    %al,(%dx)
f010053d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100542:	89 ca                	mov    %ecx,%edx
f0100544:	ee                   	out    %al,(%dx)
f0100545:	89 f0                	mov    %esi,%eax
f0100547:	89 da                	mov    %ebx,%edx
f0100549:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010054a:	83 c4 2c             	add    $0x2c,%esp
f010054d:	5b                   	pop    %ebx
f010054e:	5e                   	pop    %esi
f010054f:	5f                   	pop    %edi
f0100550:	5d                   	pop    %ebp
f0100551:	c3                   	ret    

f0100552 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100552:	55                   	push   %ebp
f0100553:	89 e5                	mov    %esp,%ebp
f0100555:	53                   	push   %ebx
f0100556:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100559:	ba 64 00 00 00       	mov    $0x64,%edx
f010055e:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010055f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100564:	a8 01                	test   $0x1,%al
f0100566:	0f 84 de 00 00 00    	je     f010064a <kbd_proc_data+0xf8>
f010056c:	b2 60                	mov    $0x60,%dl
f010056e:	ec                   	in     (%dx),%al
f010056f:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100571:	3c e0                	cmp    $0xe0,%al
f0100573:	75 11                	jne    f0100586 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f0100575:	83 0d 28 b2 22 f0 40 	orl    $0x40,0xf022b228
		return 0;
f010057c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100581:	e9 c4 00 00 00       	jmp    f010064a <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100586:	84 c0                	test   %al,%al
f0100588:	79 37                	jns    f01005c1 <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010058a:	8b 0d 28 b2 22 f0    	mov    0xf022b228,%ecx
f0100590:	89 cb                	mov    %ecx,%ebx
f0100592:	83 e3 40             	and    $0x40,%ebx
f0100595:	83 e0 7f             	and    $0x7f,%eax
f0100598:	85 db                	test   %ebx,%ebx
f010059a:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010059d:	0f b6 d2             	movzbl %dl,%edx
f01005a0:	0f b6 82 e0 6d 10 f0 	movzbl -0xfef9220(%edx),%eax
f01005a7:	83 c8 40             	or     $0x40,%eax
f01005aa:	0f b6 c0             	movzbl %al,%eax
f01005ad:	f7 d0                	not    %eax
f01005af:	21 c1                	and    %eax,%ecx
f01005b1:	89 0d 28 b2 22 f0    	mov    %ecx,0xf022b228
		return 0;
f01005b7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005bc:	e9 89 00 00 00       	jmp    f010064a <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01005c1:	8b 0d 28 b2 22 f0    	mov    0xf022b228,%ecx
f01005c7:	f6 c1 40             	test   $0x40,%cl
f01005ca:	74 0e                	je     f01005da <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01005cc:	89 c2                	mov    %eax,%edx
f01005ce:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01005d1:	83 e1 bf             	and    $0xffffffbf,%ecx
f01005d4:	89 0d 28 b2 22 f0    	mov    %ecx,0xf022b228
	}

	shift |= shiftcode[data];
f01005da:	0f b6 d2             	movzbl %dl,%edx
f01005dd:	0f b6 82 e0 6d 10 f0 	movzbl -0xfef9220(%edx),%eax
f01005e4:	0b 05 28 b2 22 f0    	or     0xf022b228,%eax
	shift ^= togglecode[data];
f01005ea:	0f b6 8a e0 6e 10 f0 	movzbl -0xfef9120(%edx),%ecx
f01005f1:	31 c8                	xor    %ecx,%eax
f01005f3:	a3 28 b2 22 f0       	mov    %eax,0xf022b228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005f8:	89 c1                	mov    %eax,%ecx
f01005fa:	83 e1 03             	and    $0x3,%ecx
f01005fd:	8b 0c 8d e0 6f 10 f0 	mov    -0xfef9020(,%ecx,4),%ecx
f0100604:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100608:	a8 08                	test   $0x8,%al
f010060a:	74 19                	je     f0100625 <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f010060c:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010060f:	83 fa 19             	cmp    $0x19,%edx
f0100612:	77 05                	ja     f0100619 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f0100614:	83 eb 20             	sub    $0x20,%ebx
f0100617:	eb 0c                	jmp    f0100625 <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f0100619:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f010061c:	8d 53 20             	lea    0x20(%ebx),%edx
f010061f:	83 f9 19             	cmp    $0x19,%ecx
f0100622:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100625:	f7 d0                	not    %eax
f0100627:	a8 06                	test   $0x6,%al
f0100629:	75 1f                	jne    f010064a <kbd_proc_data+0xf8>
f010062b:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100631:	75 17                	jne    f010064a <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f0100633:	c7 04 24 a2 6d 10 f0 	movl   $0xf0106da2,(%esp)
f010063a:	e8 97 3a 00 00       	call   f01040d6 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010063f:	ba 92 00 00 00       	mov    $0x92,%edx
f0100644:	b8 03 00 00 00       	mov    $0x3,%eax
f0100649:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010064a:	89 d8                	mov    %ebx,%eax
f010064c:	83 c4 14             	add    $0x14,%esp
f010064f:	5b                   	pop    %ebx
f0100650:	5d                   	pop    %ebp
f0100651:	c3                   	ret    

f0100652 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100652:	55                   	push   %ebp
f0100653:	89 e5                	mov    %esp,%ebp
f0100655:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100658:	80 3d 00 b0 22 f0 00 	cmpb   $0x0,0xf022b000
f010065f:	74 0a                	je     f010066b <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100661:	b8 de 02 10 f0       	mov    $0xf01002de,%eax
f0100666:	e8 8f fc ff ff       	call   f01002fa <cons_intr>
}
f010066b:	c9                   	leave  
f010066c:	c3                   	ret    

f010066d <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010066d:	55                   	push   %ebp
f010066e:	89 e5                	mov    %esp,%ebp
f0100670:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100673:	b8 52 05 10 f0       	mov    $0xf0100552,%eax
f0100678:	e8 7d fc ff ff       	call   f01002fa <cons_intr>
}
f010067d:	c9                   	leave  
f010067e:	c3                   	ret    

f010067f <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010067f:	55                   	push   %ebp
f0100680:	89 e5                	mov    %esp,%ebp
f0100682:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100685:	e8 c8 ff ff ff       	call   f0100652 <serial_intr>
	kbd_intr();
f010068a:	e8 de ff ff ff       	call   f010066d <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010068f:	8b 15 20 b2 22 f0    	mov    0xf022b220,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f0100695:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010069a:	3b 15 24 b2 22 f0    	cmp    0xf022b224,%edx
f01006a0:	74 1e                	je     f01006c0 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01006a2:	0f b6 82 20 b0 22 f0 	movzbl -0xfdd4fe0(%edx),%eax
f01006a9:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f01006ac:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006b7:	0f 44 d1             	cmove  %ecx,%edx
f01006ba:	89 15 20 b2 22 f0    	mov    %edx,0xf022b220
		return c;
	}
	return 0;
}
f01006c0:	c9                   	leave  
f01006c1:	c3                   	ret    

f01006c2 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006c2:	55                   	push   %ebp
f01006c3:	89 e5                	mov    %esp,%ebp
f01006c5:	57                   	push   %edi
f01006c6:	56                   	push   %esi
f01006c7:	53                   	push   %ebx
f01006c8:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006cb:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006d2:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006d9:	5a a5 
	if (*cp != 0xA55A) {
f01006db:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006e2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006e6:	74 11                	je     f01006f9 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006e8:	c7 05 2c b2 22 f0 b4 	movl   $0x3b4,0xf022b22c
f01006ef:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006f2:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006f7:	eb 16                	jmp    f010070f <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006f9:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100700:	c7 05 2c b2 22 f0 d4 	movl   $0x3d4,0xf022b22c
f0100707:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010070a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010070f:	8b 0d 2c b2 22 f0    	mov    0xf022b22c,%ecx
f0100715:	b8 0e 00 00 00       	mov    $0xe,%eax
f010071a:	89 ca                	mov    %ecx,%edx
f010071c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010071d:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100720:	89 da                	mov    %ebx,%edx
f0100722:	ec                   	in     (%dx),%al
f0100723:	0f b6 f8             	movzbl %al,%edi
f0100726:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100729:	b8 0f 00 00 00       	mov    $0xf,%eax
f010072e:	89 ca                	mov    %ecx,%edx
f0100730:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100731:	89 da                	mov    %ebx,%edx
f0100733:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100734:	89 35 30 b2 22 f0    	mov    %esi,0xf022b230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010073a:	0f b6 d8             	movzbl %al,%ebx
f010073d:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010073f:	66 89 3d 34 b2 22 f0 	mov    %di,0xf022b234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100746:	e8 22 ff ff ff       	call   f010066d <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f010074b:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0100752:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100757:	89 04 24             	mov    %eax,(%esp)
f010075a:	e8 35 38 00 00       	call   f0103f94 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010075f:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100764:	b8 00 00 00 00       	mov    $0x0,%eax
f0100769:	89 da                	mov    %ebx,%edx
f010076b:	ee                   	out    %al,(%dx)
f010076c:	b2 fb                	mov    $0xfb,%dl
f010076e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100773:	ee                   	out    %al,(%dx)
f0100774:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100779:	b8 0c 00 00 00       	mov    $0xc,%eax
f010077e:	89 ca                	mov    %ecx,%edx
f0100780:	ee                   	out    %al,(%dx)
f0100781:	b2 f9                	mov    $0xf9,%dl
f0100783:	b8 00 00 00 00       	mov    $0x0,%eax
f0100788:	ee                   	out    %al,(%dx)
f0100789:	b2 fb                	mov    $0xfb,%dl
f010078b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100790:	ee                   	out    %al,(%dx)
f0100791:	b2 fc                	mov    $0xfc,%dl
f0100793:	b8 00 00 00 00       	mov    $0x0,%eax
f0100798:	ee                   	out    %al,(%dx)
f0100799:	b2 f9                	mov    $0xf9,%dl
f010079b:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007a1:	b2 fd                	mov    $0xfd,%dl
f01007a3:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007a4:	3c ff                	cmp    $0xff,%al
f01007a6:	0f 95 c0             	setne  %al
f01007a9:	89 c6                	mov    %eax,%esi
f01007ab:	a2 00 b0 22 f0       	mov    %al,0xf022b000
f01007b0:	89 da                	mov    %ebx,%edx
f01007b2:	ec                   	in     (%dx),%al
f01007b3:	89 ca                	mov    %ecx,%edx
f01007b5:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007b6:	89 f0                	mov    %esi,%eax
f01007b8:	84 c0                	test   %al,%al
f01007ba:	75 0c                	jne    f01007c8 <cons_init+0x106>
		cprintf("Serial port does not exist!\n");
f01007bc:	c7 04 24 ae 6d 10 f0 	movl   $0xf0106dae,(%esp)
f01007c3:	e8 0e 39 00 00       	call   f01040d6 <cprintf>
}
f01007c8:	83 c4 1c             	add    $0x1c,%esp
f01007cb:	5b                   	pop    %ebx
f01007cc:	5e                   	pop    %esi
f01007cd:	5f                   	pop    %edi
f01007ce:	5d                   	pop    %ebp
f01007cf:	c3                   	ret    

f01007d0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01007d9:	e8 59 fb ff ff       	call   f0100337 <cons_putc>
}
f01007de:	c9                   	leave  
f01007df:	c3                   	ret    

f01007e0 <getchar>:

int
getchar(void)
{
f01007e0:	55                   	push   %ebp
f01007e1:	89 e5                	mov    %esp,%ebp
f01007e3:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007e6:	e8 94 fe ff ff       	call   f010067f <cons_getc>
f01007eb:	85 c0                	test   %eax,%eax
f01007ed:	74 f7                	je     f01007e6 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007ef:	c9                   	leave  
f01007f0:	c3                   	ret    

f01007f1 <iscons>:

int
iscons(int fdnum)
{
f01007f1:	55                   	push   %ebp
f01007f2:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007f4:	b8 01 00 00 00       	mov    $0x1,%eax
f01007f9:	5d                   	pop    %ebp
f01007fa:	c3                   	ret    
f01007fb:	00 00                	add    %al,(%eax)
f01007fd:	00 00                	add    %al,(%eax)
	...

f0100800 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100800:	55                   	push   %ebp
f0100801:	89 e5                	mov    %esp,%ebp
f0100803:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100806:	c7 04 24 f0 6f 10 f0 	movl   $0xf0106ff0,(%esp)
f010080d:	e8 c4 38 00 00       	call   f01040d6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100812:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100819:	00 
f010081a:	c7 04 24 a8 70 10 f0 	movl   $0xf01070a8,(%esp)
f0100821:	e8 b0 38 00 00       	call   f01040d6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100826:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010082d:	00 
f010082e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100835:	f0 
f0100836:	c7 04 24 d0 70 10 f0 	movl   $0xf01070d0,(%esp)
f010083d:	e8 94 38 00 00       	call   f01040d6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100842:	c7 44 24 08 d5 6c 10 	movl   $0x106cd5,0x8(%esp)
f0100849:	00 
f010084a:	c7 44 24 04 d5 6c 10 	movl   $0xf0106cd5,0x4(%esp)
f0100851:	f0 
f0100852:	c7 04 24 f4 70 10 f0 	movl   $0xf01070f4,(%esp)
f0100859:	e8 78 38 00 00       	call   f01040d6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010085e:	c7 44 24 08 1c a4 22 	movl   $0x22a41c,0x8(%esp)
f0100865:	00 
f0100866:	c7 44 24 04 1c a4 22 	movl   $0xf022a41c,0x4(%esp)
f010086d:	f0 
f010086e:	c7 04 24 18 71 10 f0 	movl   $0xf0107118,(%esp)
f0100875:	e8 5c 38 00 00       	call   f01040d6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087a:	c7 44 24 08 08 d0 26 	movl   $0x26d008,0x8(%esp)
f0100881:	00 
f0100882:	c7 44 24 04 08 d0 26 	movl   $0xf026d008,0x4(%esp)
f0100889:	f0 
f010088a:	c7 04 24 3c 71 10 f0 	movl   $0xf010713c,(%esp)
f0100891:	e8 40 38 00 00       	call   f01040d6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100896:	b8 07 d4 26 f0       	mov    $0xf026d407,%eax
f010089b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008a0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008a5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008ab:	85 c0                	test   %eax,%eax
f01008ad:	0f 48 c2             	cmovs  %edx,%eax
f01008b0:	c1 f8 0a             	sar    $0xa,%eax
f01008b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008b7:	c7 04 24 60 71 10 f0 	movl   $0xf0107160,(%esp)
f01008be:	e8 13 38 00 00       	call   f01040d6 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c8:	c9                   	leave  
f01008c9:	c3                   	ret    

f01008ca <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008ca:	55                   	push   %ebp
f01008cb:	89 e5                	mov    %esp,%ebp
f01008cd:	53                   	push   %ebx
f01008ce:	83 ec 14             	sub    $0x14,%esp
f01008d1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008d6:	8b 83 84 72 10 f0    	mov    -0xfef8d7c(%ebx),%eax
f01008dc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008e0:	8b 83 80 72 10 f0    	mov    -0xfef8d80(%ebx),%eax
f01008e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ea:	c7 04 24 09 70 10 f0 	movl   $0xf0107009,(%esp)
f01008f1:	e8 e0 37 00 00       	call   f01040d6 <cprintf>
f01008f6:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008f9:	83 fb 24             	cmp    $0x24,%ebx
f01008fc:	75 d8                	jne    f01008d6 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100903:	83 c4 14             	add    $0x14,%esp
f0100906:	5b                   	pop    %ebx
f0100907:	5d                   	pop    %ebp
f0100908:	c3                   	ret    

f0100909 <mon_backtrace>:
	unsigned int args[5];
}func_info;

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100909:	55                   	push   %ebp
f010090a:	89 e5                	mov    %esp,%ebp
f010090c:	57                   	push   %edi
f010090d:	56                   	push   %esi
f010090e:	53                   	push   %ebx
f010090f:	81 ec 7c 01 00 00    	sub    $0x17c,%esp
	
	func_info * func_ptr = 0;
	char format[150];
	char formatEIP[150];
	struct Eipdebuginfo info;
	strcpy(format,"ebp %08x eip %08x args %08x %08x %08x %08x %08x\n");
f0100915:	c7 44 24 04 8c 71 10 	movl   $0xf010718c,0x4(%esp)
f010091c:	f0 
f010091d:	8d 85 52 ff ff ff    	lea    -0xae(%ebp),%eax
f0100923:	89 04 24             	mov    %eax,(%esp)
f0100926:	e8 50 54 00 00       	call   f0105d7b <strcpy>
	strcpy(formatEIP, "\t%s:%d: %.*s+%d\n");
f010092b:	c7 44 24 04 12 70 10 	movl   $0xf0107012,0x4(%esp)
f0100932:	f0 
f0100933:	8d 85 bc fe ff ff    	lea    -0x144(%ebp),%eax
f0100939:	89 04 24             	mov    %eax,(%esp)
f010093c:	e8 3a 54 00 00       	call   f0105d7b <strcpy>
	cprintf("Stack backtrace:\n"); 
f0100941:	c7 04 24 23 70 10 f0 	movl   $0xf0107023,(%esp)
f0100948:	e8 89 37 00 00       	call   f01040d6 <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010094d:	89 e8                	mov    %ebp,%eax
	func_ptr = (func_info*)read_ebp();
f010094f:	89 c3                	mov    %eax,%ebx
	while(func_ptr != NULL){
f0100951:	85 c0                	test   %eax,%eax
f0100953:	0f 84 9e 00 00 00    	je     f01009f7 <mon_backtrace+0xee>
		
		cprintf(format,func_ptr,func_ptr->eip,func_ptr->args[0],func_ptr->args[1]
f0100959:	8d b5 52 ff ff ff    	lea    -0xae(%ebp),%esi
								 , func_ptr->args[2], func_ptr->args[3],func_ptr->args[4]);
		debuginfo_eip((uintptr_t)func_ptr->eip,&info);
f010095f:	8d bd a4 fe ff ff    	lea    -0x15c(%ebp),%edi
	strcpy(formatEIP, "\t%s:%d: %.*s+%d\n");
	cprintf("Stack backtrace:\n"); 
	func_ptr = (func_info*)read_ebp();
	while(func_ptr != NULL){
		
		cprintf(format,func_ptr,func_ptr->eip,func_ptr->args[0],func_ptr->args[1]
f0100965:	8b 43 18             	mov    0x18(%ebx),%eax
f0100968:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010096c:	8b 43 14             	mov    0x14(%ebx),%eax
f010096f:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100973:	8b 43 10             	mov    0x10(%ebx),%eax
f0100976:	89 44 24 14          	mov    %eax,0x14(%esp)
f010097a:	8b 43 0c             	mov    0xc(%ebx),%eax
f010097d:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100981:	8b 43 08             	mov    0x8(%ebx),%eax
f0100984:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100988:	8b 43 04             	mov    0x4(%ebx),%eax
f010098b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010098f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100993:	89 34 24             	mov    %esi,(%esp)
f0100996:	e8 3b 37 00 00       	call   f01040d6 <cprintf>
								 , func_ptr->args[2], func_ptr->args[3],func_ptr->args[4]);
		debuginfo_eip((uintptr_t)func_ptr->eip,&info);
f010099b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010099f:	8b 43 04             	mov    0x4(%ebx),%eax
f01009a2:	89 04 24             	mov    %eax,(%esp)
f01009a5:	e8 c0 49 00 00       	call   f010536a <debuginfo_eip>
		cprintf(formatEIP,
f01009aa:	8b 43 04             	mov    0x4(%ebx),%eax
f01009ad:	2b 85 b4 fe ff ff    	sub    -0x14c(%ebp),%eax
f01009b3:	89 44 24 14          	mov    %eax,0x14(%esp)
f01009b7:	8b 85 ac fe ff ff    	mov    -0x154(%ebp),%eax
f01009bd:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009c1:	8b 85 b0 fe ff ff    	mov    -0x150(%ebp),%eax
f01009c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009cb:	8b 85 a8 fe ff ff    	mov    -0x158(%ebp),%eax
f01009d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009d5:	8b 85 a4 fe ff ff    	mov    -0x15c(%ebp),%eax
f01009db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009df:	8d 85 bc fe ff ff    	lea    -0x144(%ebp),%eax
f01009e5:	89 04 24             	mov    %eax,(%esp)
f01009e8:	e8 e9 36 00 00       	call   f01040d6 <cprintf>
				info.eip_file,
				info.eip_line,
				info.eip_fn_namelen,
				(char*)info.eip_fn_name,(uintptr_t)func_ptr->eip - info.eip_fn_addr);
		func_ptr  = (func_info*) func_ptr->prevfunc_ebp;	
f01009ed:	8b 1b                	mov    (%ebx),%ebx
	struct Eipdebuginfo info;
	strcpy(format,"ebp %08x eip %08x args %08x %08x %08x %08x %08x\n");
	strcpy(formatEIP, "\t%s:%d: %.*s+%d\n");
	cprintf("Stack backtrace:\n"); 
	func_ptr = (func_info*)read_ebp();
	while(func_ptr != NULL){
f01009ef:	85 db                	test   %ebx,%ebx
f01009f1:	0f 85 6e ff ff ff    	jne    f0100965 <mon_backtrace+0x5c>
				(char*)info.eip_fn_name,(uintptr_t)func_ptr->eip - info.eip_fn_addr);
		func_ptr  = (func_info*) func_ptr->prevfunc_ebp;	
		
	}
	return 0;
}
f01009f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01009fc:	81 c4 7c 01 00 00    	add    $0x17c,%esp
f0100a02:	5b                   	pop    %ebx
f0100a03:	5e                   	pop    %esi
f0100a04:	5f                   	pop    %edi
f0100a05:	5d                   	pop    %ebp
f0100a06:	c3                   	ret    

f0100a07 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100a07:	55                   	push   %ebp
f0100a08:	89 e5                	mov    %esp,%ebp
f0100a0a:	57                   	push   %edi
f0100a0b:	56                   	push   %esi
f0100a0c:	53                   	push   %ebx
f0100a0d:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100a10:	c7 04 24 c0 71 10 f0 	movl   $0xf01071c0,(%esp)
f0100a17:	e8 ba 36 00 00       	call   f01040d6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a1c:	c7 04 24 e4 71 10 f0 	movl   $0xf01071e4,(%esp)
f0100a23:	e8 ae 36 00 00       	call   f01040d6 <cprintf>

	if (tf != NULL)
f0100a28:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100a2c:	74 0b                	je     f0100a39 <monitor+0x32>
		print_trapframe(tf);
f0100a2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a31:	89 04 24             	mov    %eax,(%esp)
f0100a34:	e8 9f 38 00 00       	call   f01042d8 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100a39:	c7 04 24 35 70 10 f0 	movl   $0xf0107035,(%esp)
f0100a40:	e8 1b 52 00 00       	call   f0105c60 <readline>
f0100a45:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a47:	85 c0                	test   %eax,%eax
f0100a49:	74 ee                	je     f0100a39 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100a4b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100a52:	be 00 00 00 00       	mov    $0x0,%esi
f0100a57:	eb 06                	jmp    f0100a5f <monitor+0x58>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a59:	c6 03 00             	movb   $0x0,(%ebx)
f0100a5c:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a5f:	0f b6 03             	movzbl (%ebx),%eax
f0100a62:	84 c0                	test   %al,%al
f0100a64:	74 6a                	je     f0100ad0 <monitor+0xc9>
f0100a66:	0f be c0             	movsbl %al,%eax
f0100a69:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a6d:	c7 04 24 39 70 10 f0 	movl   $0xf0107039,(%esp)
f0100a74:	e8 3d 54 00 00       	call   f0105eb6 <strchr>
f0100a79:	85 c0                	test   %eax,%eax
f0100a7b:	75 dc                	jne    f0100a59 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100a7d:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a80:	74 4e                	je     f0100ad0 <monitor+0xc9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a82:	83 fe 0f             	cmp    $0xf,%esi
f0100a85:	75 16                	jne    f0100a9d <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a87:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a8e:	00 
f0100a8f:	c7 04 24 3e 70 10 f0 	movl   $0xf010703e,(%esp)
f0100a96:	e8 3b 36 00 00       	call   f01040d6 <cprintf>
f0100a9b:	eb 9c                	jmp    f0100a39 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a9d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100aa1:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100aa4:	0f b6 03             	movzbl (%ebx),%eax
f0100aa7:	84 c0                	test   %al,%al
f0100aa9:	75 0c                	jne    f0100ab7 <monitor+0xb0>
f0100aab:	eb b2                	jmp    f0100a5f <monitor+0x58>
			buf++;
f0100aad:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ab0:	0f b6 03             	movzbl (%ebx),%eax
f0100ab3:	84 c0                	test   %al,%al
f0100ab5:	74 a8                	je     f0100a5f <monitor+0x58>
f0100ab7:	0f be c0             	movsbl %al,%eax
f0100aba:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100abe:	c7 04 24 39 70 10 f0 	movl   $0xf0107039,(%esp)
f0100ac5:	e8 ec 53 00 00       	call   f0105eb6 <strchr>
f0100aca:	85 c0                	test   %eax,%eax
f0100acc:	74 df                	je     f0100aad <monitor+0xa6>
f0100ace:	eb 8f                	jmp    f0100a5f <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f0100ad0:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ad7:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100ad8:	85 f6                	test   %esi,%esi
f0100ada:	0f 84 59 ff ff ff    	je     f0100a39 <monitor+0x32>
f0100ae0:	bb 80 72 10 f0       	mov    $0xf0107280,%ebx
f0100ae5:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100aea:	8b 03                	mov    (%ebx),%eax
f0100aec:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100af0:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100af3:	89 04 24             	mov    %eax,(%esp)
f0100af6:	e8 40 53 00 00       	call   f0105e3b <strcmp>
f0100afb:	85 c0                	test   %eax,%eax
f0100afd:	75 24                	jne    f0100b23 <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100aff:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100b02:	8b 55 08             	mov    0x8(%ebp),%edx
f0100b05:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100b09:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b0c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100b10:	89 34 24             	mov    %esi,(%esp)
f0100b13:	ff 14 85 88 72 10 f0 	call   *-0xfef8d78(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100b1a:	85 c0                	test   %eax,%eax
f0100b1c:	78 28                	js     f0100b46 <monitor+0x13f>
f0100b1e:	e9 16 ff ff ff       	jmp    f0100a39 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100b23:	83 c7 01             	add    $0x1,%edi
f0100b26:	83 c3 0c             	add    $0xc,%ebx
f0100b29:	83 ff 03             	cmp    $0x3,%edi
f0100b2c:	75 bc                	jne    f0100aea <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b2e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100b31:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b35:	c7 04 24 5b 70 10 f0 	movl   $0xf010705b,(%esp)
f0100b3c:	e8 95 35 00 00       	call   f01040d6 <cprintf>
f0100b41:	e9 f3 fe ff ff       	jmp    f0100a39 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100b46:	83 c4 5c             	add    $0x5c,%esp
f0100b49:	5b                   	pop    %ebx
f0100b4a:	5e                   	pop    %esi
f0100b4b:	5f                   	pop    %edi
f0100b4c:	5d                   	pop    %ebp
f0100b4d:	c3                   	ret    
	...

f0100b50 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b50:	55                   	push   %ebp
f0100b51:	89 e5                	mov    %esp,%ebp
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	///		The comments above are for the small if condition below :)
	if (!nextfree) {
f0100b53:	83 3d 3c b2 22 f0 00 	cmpl   $0x0,0xf022b23c
f0100b5a:	75 11                	jne    f0100b6d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b5c:	ba 07 e0 26 f0       	mov    $0xf026e007,%edx
f0100b61:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b67:	89 15 3c b2 22 f0    	mov    %edx,0xf022b23c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
		/// Increment nextfree by the memory (in terms of number of pages) being allocated here.
	if( n==0)
		return nextfree;
f0100b6d:	8b 15 3c b2 22 f0    	mov    0xf022b23c,%edx
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
		/// Increment nextfree by the memory (in terms of number of pages) being allocated here.
	if( n==0)
f0100b73:	85 c0                	test   %eax,%eax
f0100b75:	74 17                	je     f0100b8e <boot_alloc+0x3e>
		return nextfree;
	
	result = nextfree;
f0100b77:	8b 15 3c b2 22 f0    	mov    0xf022b23c,%edx

	nextfree += ROUNDUP(n,PGSIZE);
f0100b7d:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100b82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b87:	01 d0                	add    %edx,%eax
f0100b89:	a3 3c b2 22 f0       	mov    %eax,0xf022b23c

	
	return result;
}
f0100b8e:	89 d0                	mov    %edx,%eax
f0100b90:	5d                   	pop    %ebp
f0100b91:	c3                   	ret    

f0100b92 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b92:	55                   	push   %ebp
f0100b93:	89 e5                	mov    %esp,%ebp
f0100b95:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b98:	89 d1                	mov    %edx,%ecx
f0100b9a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b9d:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100ba0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100ba5:	f6 c1 01             	test   $0x1,%cl
f0100ba8:	74 57                	je     f0100c01 <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100baa:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bb0:	89 c8                	mov    %ecx,%eax
f0100bb2:	c1 e8 0c             	shr    $0xc,%eax
f0100bb5:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0100bbb:	72 20                	jb     f0100bdd <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bbd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100bc1:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0100bc8:	f0 
f0100bc9:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0100bd0:	00 
f0100bd1:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100bd8:	e8 63 f4 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100bdd:	c1 ea 0c             	shr    $0xc,%edx
f0100be0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100be6:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100bed:	89 c2                	mov    %eax,%edx
f0100bef:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100bf2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bf7:	85 d2                	test   %edx,%edx
f0100bf9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bfe:	0f 44 c2             	cmove  %edx,%eax
}
f0100c01:	c9                   	leave  
f0100c02:	c3                   	ret    

f0100c03 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100c03:	55                   	push   %ebp
f0100c04:	89 e5                	mov    %esp,%ebp
f0100c06:	83 ec 18             	sub    $0x18,%esp
f0100c09:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100c0c:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100c0f:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c11:	89 04 24             	mov    %eax,(%esp)
f0100c14:	e8 53 33 00 00       	call   f0103f6c <mc146818_read>
f0100c19:	89 c6                	mov    %eax,%esi
f0100c1b:	83 c3 01             	add    $0x1,%ebx
f0100c1e:	89 1c 24             	mov    %ebx,(%esp)
f0100c21:	e8 46 33 00 00       	call   f0103f6c <mc146818_read>
f0100c26:	c1 e0 08             	shl    $0x8,%eax
f0100c29:	09 f0                	or     %esi,%eax
}
f0100c2b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100c2e:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100c31:	89 ec                	mov    %ebp,%esp
f0100c33:	5d                   	pop    %ebp
f0100c34:	c3                   	ret    

f0100c35 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100c35:	55                   	push   %ebp
f0100c36:	89 e5                	mov    %esp,%ebp
f0100c38:	57                   	push   %edi
f0100c39:	56                   	push   %esi
f0100c3a:	53                   	push   %ebx
f0100c3b:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c3e:	3c 01                	cmp    $0x1,%al
f0100c40:	19 f6                	sbb    %esi,%esi
f0100c42:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100c48:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c4b:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f0100c51:	85 db                	test   %ebx,%ebx
f0100c53:	75 1c                	jne    f0100c71 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100c55:	c7 44 24 08 a4 72 10 	movl   $0xf01072a4,0x8(%esp)
f0100c5c:	f0 
f0100c5d:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f0100c64:	00 
f0100c65:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100c6c:	e8 cf f3 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100c71:	84 c0                	test   %al,%al
f0100c73:	74 50                	je     f0100cc5 <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c75:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100c78:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c7b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100c7e:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c81:	89 d8                	mov    %ebx,%eax
f0100c83:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100c89:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c8c:	c1 e8 16             	shr    $0x16,%eax
f0100c8f:	39 c6                	cmp    %eax,%esi
f0100c91:	0f 96 c0             	setbe  %al
f0100c94:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100c97:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100c9b:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100c9d:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca1:	8b 1b                	mov    (%ebx),%ebx
f0100ca3:	85 db                	test   %ebx,%ebx
f0100ca5:	75 da                	jne    f0100c81 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100ca7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100caa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100cb0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cb3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100cb6:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100cb8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100cbb:	89 1d 40 b2 22 f0    	mov    %ebx,0xf022b240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cc1:	85 db                	test   %ebx,%ebx
f0100cc3:	74 67                	je     f0100d2c <check_page_free_list+0xf7>
f0100cc5:	89 d8                	mov    %ebx,%eax
f0100cc7:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100ccd:	c1 f8 03             	sar    $0x3,%eax
f0100cd0:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100cd3:	89 c2                	mov    %eax,%edx
f0100cd5:	c1 ea 16             	shr    $0x16,%edx
f0100cd8:	39 d6                	cmp    %edx,%esi
f0100cda:	76 4a                	jbe    f0100d26 <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cdc:	89 c2                	mov    %eax,%edx
f0100cde:	c1 ea 0c             	shr    $0xc,%edx
f0100ce1:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100ce7:	72 20                	jb     f0100d09 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ce9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ced:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0100cf4:	f0 
f0100cf5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100cfc:	00 
f0100cfd:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f0100d04:	e8 37 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100d09:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100d10:	00 
f0100d11:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100d18:	00 
	return (void *)(pa + KERNBASE);
f0100d19:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d1e:	89 04 24             	mov    %eax,(%esp)
f0100d21:	e8 eb 51 00 00       	call   f0105f11 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d26:	8b 1b                	mov    (%ebx),%ebx
f0100d28:	85 db                	test   %ebx,%ebx
f0100d2a:	75 99                	jne    f0100cc5 <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100d2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d31:	e8 1a fe ff ff       	call   f0100b50 <boot_alloc>
f0100d36:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d39:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f0100d3f:	85 d2                	test   %edx,%edx
f0100d41:	0f 84 2f 02 00 00    	je     f0100f76 <check_page_free_list+0x341>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d47:	8b 1d 90 be 22 f0    	mov    0xf022be90,%ebx
f0100d4d:	39 da                	cmp    %ebx,%edx
f0100d4f:	72 51                	jb     f0100da2 <check_page_free_list+0x16d>
		assert(pp < pages + npages);
f0100d51:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0100d56:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100d59:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100d5c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d5f:	39 c2                	cmp    %eax,%edx
f0100d61:	73 68                	jae    f0100dcb <check_page_free_list+0x196>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d63:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0100d66:	89 d0                	mov    %edx,%eax
f0100d68:	29 d8                	sub    %ebx,%eax
f0100d6a:	a8 07                	test   $0x7,%al
f0100d6c:	0f 85 86 00 00 00    	jne    f0100df8 <check_page_free_list+0x1c3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d72:	c1 f8 03             	sar    $0x3,%eax
f0100d75:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d78:	85 c0                	test   %eax,%eax
f0100d7a:	0f 84 a6 00 00 00    	je     f0100e26 <check_page_free_list+0x1f1>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d80:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d85:	0f 84 c6 00 00 00    	je     f0100e51 <check_page_free_list+0x21c>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d8b:	be 00 00 00 00       	mov    $0x0,%esi
f0100d90:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d95:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0100d98:	e9 d8 00 00 00       	jmp    f0100e75 <check_page_free_list+0x240>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d9d:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100da0:	73 24                	jae    f0100dc6 <check_page_free_list+0x191>
f0100da2:	c7 44 24 0c b3 7b 10 	movl   $0xf0107bb3,0xc(%esp)
f0100da9:	f0 
f0100daa:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0100db1:	f0 
f0100db2:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f0100db9:	00 
f0100dba:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100dc1:	e8 7a f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100dc6:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100dc9:	72 24                	jb     f0100def <check_page_free_list+0x1ba>
f0100dcb:	c7 44 24 0c d4 7b 10 	movl   $0xf0107bd4,0xc(%esp)
f0100dd2:	f0 
f0100dd3:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0100dda:	f0 
f0100ddb:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0100de2:	00 
f0100de3:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100dea:	e8 51 f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100def:	89 d0                	mov    %edx,%eax
f0100df1:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100df4:	a8 07                	test   $0x7,%al
f0100df6:	74 24                	je     f0100e1c <check_page_free_list+0x1e7>
f0100df8:	c7 44 24 0c c8 72 10 	movl   $0xf01072c8,0xc(%esp)
f0100dff:	f0 
f0100e00:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0100e07:	f0 
f0100e08:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f0100e0f:	00 
f0100e10:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100e17:	e8 24 f2 ff ff       	call   f0100040 <_panic>
f0100e1c:	c1 f8 03             	sar    $0x3,%eax
f0100e1f:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100e22:	85 c0                	test   %eax,%eax
f0100e24:	75 24                	jne    f0100e4a <check_page_free_list+0x215>
f0100e26:	c7 44 24 0c e8 7b 10 	movl   $0xf0107be8,0xc(%esp)
f0100e2d:	f0 
f0100e2e:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0100e35:	f0 
f0100e36:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0100e3d:	00 
f0100e3e:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100e45:	e8 f6 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e4a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e4f:	75 24                	jne    f0100e75 <check_page_free_list+0x240>
f0100e51:	c7 44 24 0c f9 7b 10 	movl   $0xf0107bf9,0xc(%esp)
f0100e58:	f0 
f0100e59:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0100e60:	f0 
f0100e61:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0100e68:	00 
f0100e69:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100e70:	e8 cb f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e75:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e7a:	75 24                	jne    f0100ea0 <check_page_free_list+0x26b>
f0100e7c:	c7 44 24 0c fc 72 10 	movl   $0xf01072fc,0xc(%esp)
f0100e83:	f0 
f0100e84:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0100e8b:	f0 
f0100e8c:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f0100e93:	00 
f0100e94:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100e9b:	e8 a0 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ea0:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ea5:	75 24                	jne    f0100ecb <check_page_free_list+0x296>
f0100ea7:	c7 44 24 0c 12 7c 10 	movl   $0xf0107c12,0xc(%esp)
f0100eae:	f0 
f0100eaf:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0100eb6:	f0 
f0100eb7:	c7 44 24 04 ef 02 00 	movl   $0x2ef,0x4(%esp)
f0100ebe:	00 
f0100ebf:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100ec6:	e8 75 f1 ff ff       	call   f0100040 <_panic>
f0100ecb:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ecd:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ed2:	76 59                	jbe    f0100f2d <check_page_free_list+0x2f8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ed4:	89 c3                	mov    %eax,%ebx
f0100ed6:	c1 eb 0c             	shr    $0xc,%ebx
f0100ed9:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100edc:	77 20                	ja     f0100efe <check_page_free_list+0x2c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ede:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ee2:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0100ee9:	f0 
f0100eea:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ef1:	00 
f0100ef2:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f0100ef9:	e8 42 f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100efe:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0100f04:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100f07:	76 24                	jbe    f0100f2d <check_page_free_list+0x2f8>
f0100f09:	c7 44 24 0c 20 73 10 	movl   $0xf0107320,0xc(%esp)
f0100f10:	f0 
f0100f11:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0100f18:	f0 
f0100f19:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0100f20:	00 
f0100f21:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100f28:	e8 13 f1 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f2d:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100f32:	75 24                	jne    f0100f58 <check_page_free_list+0x323>
f0100f34:	c7 44 24 0c 2c 7c 10 	movl   $0xf0107c2c,0xc(%esp)
f0100f3b:	f0 
f0100f3c:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0100f43:	f0 
f0100f44:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f0100f4b:	00 
f0100f4c:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100f53:	e8 e8 f0 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100f58:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0100f5e:	77 05                	ja     f0100f65 <check_page_free_list+0x330>
			++nfree_basemem;
f0100f60:	83 c7 01             	add    $0x1,%edi
f0100f63:	eb 03                	jmp    f0100f68 <check_page_free_list+0x333>
		else
			++nfree_extmem;
f0100f65:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f68:	8b 12                	mov    (%edx),%edx
f0100f6a:	85 d2                	test   %edx,%edx
f0100f6c:	0f 85 2b fe ff ff    	jne    f0100d9d <check_page_free_list+0x168>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100f72:	85 ff                	test   %edi,%edi
f0100f74:	7f 24                	jg     f0100f9a <check_page_free_list+0x365>
f0100f76:	c7 44 24 0c 49 7c 10 	movl   $0xf0107c49,0xc(%esp)
f0100f7d:	f0 
f0100f7e:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0100f85:	f0 
f0100f86:	c7 44 24 04 fa 02 00 	movl   $0x2fa,0x4(%esp)
f0100f8d:	00 
f0100f8e:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100f95:	e8 a6 f0 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f9a:	85 f6                	test   %esi,%esi
f0100f9c:	7f 24                	jg     f0100fc2 <check_page_free_list+0x38d>
f0100f9e:	c7 44 24 0c 5b 7c 10 	movl   $0xf0107c5b,0xc(%esp)
f0100fa5:	f0 
f0100fa6:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0100fad:	f0 
f0100fae:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f0100fb5:	00 
f0100fb6:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100fbd:	e8 7e f0 ff ff       	call   f0100040 <_panic>
}
f0100fc2:	83 c4 4c             	add    $0x4c,%esp
f0100fc5:	5b                   	pop    %ebx
f0100fc6:	5e                   	pop    %esi
f0100fc7:	5f                   	pop    %edi
f0100fc8:	5d                   	pop    %ebp
f0100fc9:	c3                   	ret    

f0100fca <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100fca:	55                   	push   %ebp
f0100fcb:	89 e5                	mov    %esp,%ebp
f0100fcd:	56                   	push   %esi
f0100fce:	53                   	push   %ebx
f0100fcf:	83 ec 10             	sub    $0x10,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t nextPageBoot = PGNUM(PADDR(boot_alloc(0)));
f0100fd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fd7:	e8 74 fb ff ff       	call   f0100b50 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100fdc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fe1:	77 20                	ja     f0101003 <page_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fe3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fe7:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0100fee:	f0 
f0100fef:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
f0100ff6:	00 
f0100ff7:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0100ffe:	e8 3d f0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101003:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0101009:	c1 eb 0c             	shr    $0xc,%ebx
	size_t PagebeforeIO = PGNUM(IOPHYSMEM);
	for (i = 0; i < npages; i++) {
f010100c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101011:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0101018:	0f 84 91 00 00 00    	je     f01010af <page_init+0xe5>
f010101e:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
		
		if (i == PGNUM(MPENTRY_PADDR)){
f0101023:	83 fa 07             	cmp    $0x7,%edx
f0101026:	75 15                	jne    f010103d <page_init+0x73>
		
			pages[i].pp_ref = 1;
f0101028:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
f010102e:	66 c7 41 3c 01 00    	movw   $0x1,0x3c(%ecx)
			pages[i].pp_link = NULL;
f0101034:	c7 41 38 00 00 00 00 	movl   $0x0,0x38(%ecx)
f010103b:	eb 5e                	jmp    f010109b <page_init+0xd1>
		}
		else if(i == 0){
f010103d:	85 d2                	test   %edx,%edx
f010103f:	75 14                	jne    f0101055 <page_init+0x8b>

			pages[i].pp_ref = 1;
f0101041:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
f0101047:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
			pages[i].pp_link = NULL;
f010104d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0101053:	eb 46                	jmp    f010109b <page_init+0xd1>
		}
		else if( i < PagebeforeIO || i >= nextPageBoot){
f0101055:	81 fa 9f 00 00 00    	cmp    $0x9f,%edx
f010105b:	76 04                	jbe    f0101061 <page_init+0x97>
f010105d:	39 da                	cmp    %ebx,%edx
f010105f:	72 21                	jb     f0101082 <page_init+0xb8>
			pages[i].pp_ref = 0;
f0101061:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0101068:	89 ce                	mov    %ecx,%esi
f010106a:	03 35 90 be 22 f0    	add    0xf022be90,%esi
f0101070:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
			pages[i].pp_link = page_free_list;
f0101076:	89 06                	mov    %eax,(%esi)
			page_free_list = &pages[i];
f0101078:	89 c8                	mov    %ecx,%eax
f010107a:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0101080:	eb 19                	jmp    f010109b <page_init+0xd1>
		}
		else{
	      	pages[i].pp_ref = 1;
f0101082:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0101089:	03 0d 90 be 22 f0    	add    0xf022be90,%ecx
f010108f:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
	     	pages[i].pp_link = NULL;
f0101095:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t nextPageBoot = PGNUM(PADDR(boot_alloc(0)));
	size_t PagebeforeIO = PGNUM(IOPHYSMEM);
	for (i = 0; i < npages; i++) {
f010109b:	83 c2 01             	add    $0x1,%edx
f010109e:	39 15 88 be 22 f0    	cmp    %edx,0xf022be88
f01010a4:	0f 87 79 ff ff ff    	ja     f0101023 <page_init+0x59>
f01010aa:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
	    }
		
		
	}

	physaddr_t pa = page2pa(&pages[i]);
f01010af:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f01010b4:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010b7:	89 cb                	mov    %ecx,%ebx
f01010b9:	29 c3                	sub    %eax,%ebx
f01010bb:	89 d8                	mov    %ebx,%eax
f01010bd:	c1 f8 03             	sar    $0x3,%eax
f01010c0:	c1 e0 0c             	shl    $0xc,%eax
    
	if ((pa == 0 || pa == IOPHYSMEM) && (pages[i].pp_ref==0))
f01010c3:	85 c0                	test   %eax,%eax
f01010c5:	74 07                	je     f01010ce <page_init+0x104>
f01010c7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010cc:	75 17                	jne    f01010e5 <page_init+0x11b>
f01010ce:	66 83 79 04 00       	cmpw   $0x0,0x4(%ecx)
f01010d3:	75 10                	jne    f01010e5 <page_init+0x11b>
		cprintf("page error: i %d\n", i);	
f01010d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01010d9:	c7 04 24 6c 7c 10 f0 	movl   $0xf0107c6c,(%esp)
f01010e0:	e8 f1 2f 00 00       	call   f01040d6 <cprintf>

}
f01010e5:	83 c4 10             	add    $0x10,%esp
f01010e8:	5b                   	pop    %ebx
f01010e9:	5e                   	pop    %esi
f01010ea:	5d                   	pop    %ebp
f01010eb:	c3                   	ret    

f01010ec <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01010ec:	55                   	push   %ebp
f01010ed:	89 e5                	mov    %esp,%ebp
f01010ef:	53                   	push   %ebx
f01010f0:	83 ec 14             	sub    $0x14,%esp

	struct PageInfo * pp = NULL;
	if (!page_free_list)
f01010f3:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f01010f9:	85 db                	test   %ebx,%ebx
f01010fb:	74 65                	je     f0101162 <page_alloc+0x76>
	      return NULL;

	pp = page_free_list;

	page_free_list = page_free_list->pp_link;
f01010fd:	8b 03                	mov    (%ebx),%eax
f01010ff:	a3 40 b2 22 f0       	mov    %eax,0xf022b240

	if (alloc_flags & ALLOC_ZERO)
f0101104:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101108:	74 58                	je     f0101162 <page_alloc+0x76>
f010110a:	89 d8                	mov    %ebx,%eax
f010110c:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101112:	c1 f8 03             	sar    $0x3,%eax
f0101115:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101118:	89 c2                	mov    %eax,%edx
f010111a:	c1 ea 0c             	shr    $0xc,%edx
f010111d:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101123:	72 20                	jb     f0101145 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101125:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101129:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0101130:	f0 
f0101131:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101138:	00 
f0101139:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f0101140:	e8 fb ee ff ff       	call   f0100040 <_panic>
		memset(page2kva(pp), 0, PGSIZE);
f0101145:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010114c:	00 
f010114d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101154:	00 
	return (void *)(pa + KERNBASE);
f0101155:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010115a:	89 04 24             	mov    %eax,(%esp)
f010115d:	e8 af 4d 00 00       	call   f0105f11 <memset>
	return pp;
}
f0101162:	89 d8                	mov    %ebx,%eax
f0101164:	83 c4 14             	add    $0x14,%esp
f0101167:	5b                   	pop    %ebx
f0101168:	5d                   	pop    %ebp
f0101169:	c3                   	ret    

f010116a <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010116a:	55                   	push   %ebp
f010116b:	89 e5                	mov    %esp,%ebp
f010116d:	83 ec 18             	sub    $0x18,%esp
f0101170:	8b 45 08             	mov    0x8(%ebp),%eax
	assert(pp->pp_ref == 0);
f0101173:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101178:	74 24                	je     f010119e <page_free+0x34>
f010117a:	c7 44 24 0c 7e 7c 10 	movl   $0xf0107c7e,0xc(%esp)
f0101181:	f0 
f0101182:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101189:	f0 
f010118a:	c7 44 24 04 92 01 00 	movl   $0x192,0x4(%esp)
f0101191:	00 
f0101192:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101199:	e8 a2 ee ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010119e:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f01011a4:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01011a6:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
}
f01011ab:	c9                   	leave  
f01011ac:	c3                   	ret    

f01011ad <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01011ad:	55                   	push   %ebp
f01011ae:	89 e5                	mov    %esp,%ebp
f01011b0:	83 ec 18             	sub    $0x18,%esp
f01011b3:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01011b6:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f01011ba:	83 ea 01             	sub    $0x1,%edx
f01011bd:	66 89 50 04          	mov    %dx,0x4(%eax)
f01011c1:	66 85 d2             	test   %dx,%dx
f01011c4:	75 08                	jne    f01011ce <page_decref+0x21>
		page_free(pp);
f01011c6:	89 04 24             	mov    %eax,(%esp)
f01011c9:	e8 9c ff ff ff       	call   f010116a <page_free>
}
f01011ce:	c9                   	leave  
f01011cf:	c3                   	ret    

f01011d0 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01011d0:	55                   	push   %ebp
f01011d1:	89 e5                	mov    %esp,%ebp
f01011d3:	83 ec 28             	sub    $0x28,%esp
f01011d6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01011d9:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01011dc:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01011df:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pde_t * ptrpgadr  = pgdir + PDX(va);
f01011e2:	89 fe                	mov    %edi,%esi
f01011e4:	c1 ee 16             	shr    $0x16,%esi
f01011e7:	c1 e6 02             	shl    $0x2,%esi
f01011ea:	03 75 08             	add    0x8(%ebp),%esi
	if(*ptrpgadr & PTE_P ){
f01011ed:	8b 06                	mov    (%esi),%eax
f01011ef:	a8 01                	test   $0x1,%al
f01011f1:	74 47                	je     f010123a <pgdir_walk+0x6a>
	
		pte_t * ptadr = (pte_t*)KADDR(PTE_ADDR(*ptrpgadr));
f01011f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011f8:	89 c2                	mov    %eax,%edx
f01011fa:	c1 ea 0c             	shr    $0xc,%edx
f01011fd:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101203:	72 20                	jb     f0101225 <pgdir_walk+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101205:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101209:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0101210:	f0 
f0101211:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
f0101218:	00 
f0101219:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101220:	e8 1b ee ff ff       	call   f0100040 <_panic>
		return ptadr + PTX(va);  
f0101225:	c1 ef 0a             	shr    $0xa,%edi
f0101228:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f010122e:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
f0101235:	e9 31 01 00 00       	jmp    f010136b <pgdir_walk+0x19b>
	} 
	struct PageInfo * newpt = page_alloc(ALLOC_ZERO);
f010123a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101241:	e8 a6 fe ff ff       	call   f01010ec <page_alloc>
f0101246:	89 c3                	mov    %eax,%ebx

	if( create == 1&& newpt != NULL){
f0101248:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
f010124c:	0f 85 14 01 00 00    	jne    f0101366 <pgdir_walk+0x196>
f0101252:	85 c0                	test   %eax,%eax
f0101254:	0f 84 0c 01 00 00    	je     f0101366 <pgdir_walk+0x196>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010125a:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101260:	c1 f8 03             	sar    $0x3,%eax
f0101263:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101266:	89 c2                	mov    %eax,%edx
f0101268:	c1 ea 0c             	shr    $0xc,%edx
f010126b:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101271:	72 20                	jb     f0101293 <pgdir_walk+0xc3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101273:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101277:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f010127e:	f0 
f010127f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101286:	00 
f0101287:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f010128e:	e8 ad ed ff ff       	call   f0100040 <_panic>

		memset(page2kva(newpt),0,PGSIZE);
f0101293:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010129a:	00 
f010129b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012a2:	00 
	return (void *)(pa + KERNBASE);
f01012a3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012a8:	89 04 24             	mov    %eax,(%esp)
f01012ab:	e8 61 4c 00 00       	call   f0105f11 <memset>
		newpt->pp_ref = 1;
f01012b0:	66 c7 43 04 01 00    	movw   $0x1,0x4(%ebx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012b6:	2b 1d 90 be 22 f0    	sub    0xf022be90,%ebx
f01012bc:	c1 fb 03             	sar    $0x3,%ebx
f01012bf:	c1 e3 0c             	shl    $0xc,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012c2:	89 d8                	mov    %ebx,%eax
f01012c4:	c1 e8 0c             	shr    $0xc,%eax
f01012c7:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01012cd:	72 20                	jb     f01012ef <pgdir_walk+0x11f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012cf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01012d3:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f01012da:	f0 
f01012db:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01012e2:	00 
f01012e3:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f01012ea:	e8 51 ed ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01012ef:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01012f5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012fa:	77 20                	ja     f010131c <pgdir_walk+0x14c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101300:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0101307:	f0 
f0101308:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
f010130f:	00 
f0101310:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101317:	e8 24 ed ff ff       	call   f0100040 <_panic>
		*ptrpgadr = PADDR(page2kva(newpt)) | PTE_U | PTE_W | PTE_P;
f010131c:	83 cb 07             	or     $0x7,%ebx
f010131f:	89 1e                	mov    %ebx,(%esi)
		pte_t * ptadr = (pte_t *)KADDR(PTE_ADDR(*ptrpgadr));
f0101321:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101327:	89 d8                	mov    %ebx,%eax
f0101329:	c1 e8 0c             	shr    $0xc,%eax
f010132c:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0101332:	72 20                	jb     f0101354 <pgdir_walk+0x184>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101334:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101338:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f010133f:	f0 
f0101340:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
f0101347:	00 
f0101348:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f010134f:	e8 ec ec ff ff       	call   f0100040 <_panic>
		return ptadr + PTX(va);
f0101354:	c1 ef 0a             	shr    $0xa,%edi
f0101357:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f010135d:	8d 84 3b 00 00 00 f0 	lea    -0x10000000(%ebx,%edi,1),%eax
f0101364:	eb 05                	jmp    f010136b <pgdir_walk+0x19b>
	}
	return NULL;
f0101366:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010136b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010136e:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101371:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101374:	89 ec                	mov    %ebp,%esp
f0101376:	5d                   	pop    %ebp
f0101377:	c3                   	ret    

f0101378 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101378:	55                   	push   %ebp
f0101379:	89 e5                	mov    %esp,%ebp
f010137b:	57                   	push   %edi
f010137c:	56                   	push   %esi
f010137d:	53                   	push   %ebx
f010137e:	83 ec 2c             	sub    $0x2c,%esp
f0101381:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101384:	89 d7                	mov    %edx,%edi
f0101386:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	int pteindex;
	pte_t *pte;
	for(pteindex = 0; pteindex < size; pteindex += PGSIZE) {
f0101389:	85 c9                	test   %ecx,%ecx
f010138b:	74 3d                	je     f01013ca <boot_map_region+0x52>
f010138d:	bb 00 00 00 00       	mov    $0x0,%ebx
		
		pte = pgdir_walk(pgdir, (void*)va, 1);
		*pte = pa | perm | PTE_P;
f0101392:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101395:	83 c8 01             	or     $0x1,%eax
f0101398:	89 45 dc             	mov    %eax,-0x24(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f010139b:	8b 75 08             	mov    0x8(%ebp),%esi
f010139e:	01 de                	add    %ebx,%esi
	// Fill this function in
	int pteindex;
	pte_t *pte;
	for(pteindex = 0; pteindex < size; pteindex += PGSIZE) {
		
		pte = pgdir_walk(pgdir, (void*)va, 1);
f01013a0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01013a7:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01013a8:	8d 04 3b             	lea    (%ebx,%edi,1),%eax
	// Fill this function in
	int pteindex;
	pte_t *pte;
	for(pteindex = 0; pteindex < size; pteindex += PGSIZE) {
		
		pte = pgdir_walk(pgdir, (void*)va, 1);
f01013ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013af:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01013b2:	89 04 24             	mov    %eax,(%esp)
f01013b5:	e8 16 fe ff ff       	call   f01011d0 <pgdir_walk>
		*pte = pa | perm | PTE_P;
f01013ba:	0b 75 dc             	or     -0x24(%ebp),%esi
f01013bd:	89 30                	mov    %esi,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	int pteindex;
	pte_t *pte;
	for(pteindex = 0; pteindex < size; pteindex += PGSIZE) {
f01013bf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01013c5:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01013c8:	77 d1                	ja     f010139b <boot_map_region+0x23>
		pte = pgdir_walk(pgdir, (void*)va, 1);
		*pte = pa | perm | PTE_P;
		pa += PGSIZE;
		va += PGSIZE;
	}
}
f01013ca:	83 c4 2c             	add    $0x2c,%esp
f01013cd:	5b                   	pop    %ebx
f01013ce:	5e                   	pop    %esi
f01013cf:	5f                   	pop    %edi
f01013d0:	5d                   	pop    %ebp
f01013d1:	c3                   	ret    

f01013d2 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01013d2:	55                   	push   %ebp
f01013d3:	89 e5                	mov    %esp,%ebp
f01013d5:	53                   	push   %ebx
f01013d6:	83 ec 14             	sub    $0x14,%esp
f01013d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	pte_t * pte = pgdir_walk(pgdir,va,0);
f01013dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01013e3:	00 
f01013e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01013ee:	89 04 24             	mov    %eax,(%esp)
f01013f1:	e8 da fd ff ff       	call   f01011d0 <pgdir_walk>
	
	if(pte_store!=0){
f01013f6:	85 db                	test   %ebx,%ebx
f01013f8:	74 02                	je     f01013fc <page_lookup+0x2a>
		*pte_store = pte;
f01013fa:	89 03                	mov    %eax,(%ebx)
	}	
	if(pte !=NULL && (*pte & PTE_P)){
f01013fc:	85 c0                	test   %eax,%eax
f01013fe:	74 38                	je     f0101438 <page_lookup+0x66>
f0101400:	8b 00                	mov    (%eax),%eax
f0101402:	a8 01                	test   $0x1,%al
f0101404:	74 39                	je     f010143f <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101406:	c1 e8 0c             	shr    $0xc,%eax
f0101409:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f010140f:	72 1c                	jb     f010142d <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f0101411:	c7 44 24 08 68 73 10 	movl   $0xf0107368,0x8(%esp)
f0101418:	f0 
f0101419:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101420:	00 
f0101421:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f0101428:	e8 13 ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010142d:	c1 e0 03             	shl    $0x3,%eax
f0101430:	03 05 90 be 22 f0    	add    0xf022be90,%eax

		return pa2page(PTE_ADDR(*pte));
f0101436:	eb 0c                	jmp    f0101444 <page_lookup+0x72>
	}
	return NULL;
f0101438:	b8 00 00 00 00       	mov    $0x0,%eax
f010143d:	eb 05                	jmp    f0101444 <page_lookup+0x72>
f010143f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101444:	83 c4 14             	add    $0x14,%esp
f0101447:	5b                   	pop    %ebx
f0101448:	5d                   	pop    %ebp
f0101449:	c3                   	ret    

f010144a <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010144a:	55                   	push   %ebp
f010144b:	89 e5                	mov    %esp,%ebp
f010144d:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101450:	e8 4b 51 00 00       	call   f01065a0 <cpunum>
f0101455:	6b c0 74             	imul   $0x74,%eax,%eax
f0101458:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010145f:	74 16                	je     f0101477 <tlb_invalidate+0x2d>
f0101461:	e8 3a 51 00 00       	call   f01065a0 <cpunum>
f0101466:	6b c0 74             	imul   $0x74,%eax,%eax
f0101469:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010146f:	8b 55 08             	mov    0x8(%ebp),%edx
f0101472:	39 50 60             	cmp    %edx,0x60(%eax)
f0101475:	75 06                	jne    f010147d <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101477:	8b 45 0c             	mov    0xc(%ebp),%eax
f010147a:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010147d:	c9                   	leave  
f010147e:	c3                   	ret    

f010147f <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010147f:	55                   	push   %ebp
f0101480:	89 e5                	mov    %esp,%ebp
f0101482:	83 ec 28             	sub    $0x28,%esp
f0101485:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101488:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010148b:	8b 75 08             	mov    0x8(%ebp),%esi
f010148e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte;
	struct PageInfo* physpage = page_lookup(pgdir, va, &pte);
f0101491:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101494:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101498:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010149c:	89 34 24             	mov    %esi,(%esp)
f010149f:	e8 2e ff ff ff       	call   f01013d2 <page_lookup>
	if(physpage != NULL) {
f01014a4:	85 c0                	test   %eax,%eax
f01014a6:	74 1d                	je     f01014c5 <page_remove+0x46>
		page_decref(physpage);
f01014a8:	89 04 24             	mov    %eax,(%esp)
f01014ab:	e8 fd fc ff ff       	call   f01011ad <page_decref>
		*pte = 0;
f01014b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01014b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f01014b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01014bd:	89 34 24             	mov    %esi,(%esp)
f01014c0:	e8 85 ff ff ff       	call   f010144a <tlb_invalidate>
	}
}
f01014c5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01014c8:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01014cb:	89 ec                	mov    %ebp,%esp
f01014cd:	5d                   	pop    %ebp
f01014ce:	c3                   	ret    

f01014cf <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01014cf:	55                   	push   %ebp
f01014d0:	89 e5                	mov    %esp,%ebp
f01014d2:	83 ec 28             	sub    $0x28,%esp
f01014d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01014d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01014db:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01014de:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014e1:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t * pte = pgdir_walk(pgdir,va,1);
f01014e4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01014eb:	00 
f01014ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01014f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01014f3:	89 04 24             	mov    %eax,(%esp)
f01014f6:	e8 d5 fc ff ff       	call   f01011d0 <pgdir_walk>
f01014fb:	89 c3                	mov    %eax,%ebx
	if(pte == NULL){
f01014fd:	85 c0                	test   %eax,%eax
f01014ff:	74 66                	je     f0101567 <page_insert+0x98>

		return -E_NO_MEM;
	}
	if(*pte&PTE_P){
f0101501:	8b 00                	mov    (%eax),%eax
f0101503:	a8 01                	test   $0x1,%al
f0101505:	74 3c                	je     f0101543 <page_insert+0x74>
		if(PTE_ADDR(*pte) == page2pa(pp)) {
f0101507:	25 00 f0 ff ff       	and    $0xfffff000,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010150c:	89 f2                	mov    %esi,%edx
f010150e:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101514:	c1 fa 03             	sar    $0x3,%edx
f0101517:	c1 e2 0c             	shl    $0xc,%edx
f010151a:	39 d0                	cmp    %edx,%eax
f010151c:	75 16                	jne    f0101534 <page_insert+0x65>
			tlb_invalidate(pgdir, va);
f010151e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101522:	8b 45 08             	mov    0x8(%ebp),%eax
f0101525:	89 04 24             	mov    %eax,(%esp)
f0101528:	e8 1d ff ff ff       	call   f010144a <tlb_invalidate>
			pp -> pp_ref --;
f010152d:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f0101532:	eb 0f                	jmp    f0101543 <page_insert+0x74>
		}
		 else {
			page_remove(pgdir, va);
f0101534:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101538:	8b 45 08             	mov    0x8(%ebp),%eax
f010153b:	89 04 24             	mov    %eax,(%esp)
f010153e:	e8 3c ff ff ff       	call   f010147f <page_remove>
		}
	}
	*pte = page2pa(pp) | perm | PTE_P;
f0101543:	8b 45 14             	mov    0x14(%ebp),%eax
f0101546:	83 c8 01             	or     $0x1,%eax
f0101549:	89 f2                	mov    %esi,%edx
f010154b:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101551:	c1 fa 03             	sar    $0x3,%edx
f0101554:	c1 e2 0c             	shl    $0xc,%edx
f0101557:	09 d0                	or     %edx,%eax
f0101559:	89 03                	mov    %eax,(%ebx)
	pp -> pp_ref ++;
f010155b:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	return 0;
f0101560:	b8 00 00 00 00       	mov    $0x0,%eax
f0101565:	eb 05                	jmp    f010156c <page_insert+0x9d>
{
	// Fill this function in
	pte_t * pte = pgdir_walk(pgdir,va,1);
	if(pte == NULL){

		return -E_NO_MEM;
f0101567:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		}
	}
	*pte = page2pa(pp) | perm | PTE_P;
	pp -> pp_ref ++;
	return 0;
}
f010156c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010156f:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101572:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101575:	89 ec                	mov    %ebp,%esp
f0101577:	5d                   	pop    %ebp
f0101578:	c3                   	ret    

f0101579 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101579:	55                   	push   %ebp
f010157a:	89 e5                	mov    %esp,%ebp
f010157c:	53                   	push   %ebx
f010157d:	83 ec 14             	sub    $0x14,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
		/// Lab5:
	size = ROUNDUP(size,PGSIZE);
f0101580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101583:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0101589:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(base + size > MMIOLIM || base + size < base){
f010158f:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f0101595:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101598:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010159d:	77 04                	ja     f01015a3 <mmio_map_region+0x2a>
f010159f:	39 c2                	cmp    %eax,%edx
f01015a1:	76 1c                	jbe    f01015bf <mmio_map_region+0x46>
		panic("mmio_map_region : overflow during reservation.\n");
f01015a3:	c7 44 24 08 88 73 10 	movl   $0xf0107388,0x8(%esp)
f01015aa:	f0 
f01015ab:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
f01015b2:	00 
f01015b3:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01015ba:	e8 81 ea ff ff       	call   f0100040 <_panic>
	}
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f01015bf:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f01015c6:	00 
f01015c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01015ca:	89 04 24             	mov    %eax,(%esp)
f01015cd:	89 d9                	mov    %ebx,%ecx
f01015cf:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01015d4:	e8 9f fd ff ff       	call   f0101378 <boot_map_region>
	void * r = (void*)base;
f01015d9:	a1 00 23 12 f0       	mov    0xf0122300,%eax
	base += size;
f01015de:	01 c3                	add    %eax,%ebx
f01015e0:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300
	return r;
}
f01015e6:	83 c4 14             	add    $0x14,%esp
f01015e9:	5b                   	pop    %ebx
f01015ea:	5d                   	pop    %ebp
f01015eb:	c3                   	ret    

f01015ec <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01015ec:	55                   	push   %ebp
f01015ed:	89 e5                	mov    %esp,%ebp
f01015ef:	57                   	push   %edi
f01015f0:	56                   	push   %esi
f01015f1:	53                   	push   %ebx
f01015f2:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01015f5:	b8 15 00 00 00       	mov    $0x15,%eax
f01015fa:	e8 04 f6 ff ff       	call   f0100c03 <nvram_read>
f01015ff:	c1 e0 0a             	shl    $0xa,%eax
f0101602:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101608:	85 c0                	test   %eax,%eax
f010160a:	0f 48 c2             	cmovs  %edx,%eax
f010160d:	c1 f8 0c             	sar    $0xc,%eax
f0101610:	a3 38 b2 22 f0       	mov    %eax,0xf022b238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101615:	b8 17 00 00 00       	mov    $0x17,%eax
f010161a:	e8 e4 f5 ff ff       	call   f0100c03 <nvram_read>
f010161f:	c1 e0 0a             	shl    $0xa,%eax
f0101622:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101628:	85 c0                	test   %eax,%eax
f010162a:	0f 48 c2             	cmovs  %edx,%eax
f010162d:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101630:	85 c0                	test   %eax,%eax
f0101632:	74 0e                	je     f0101642 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101634:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010163a:	89 15 88 be 22 f0    	mov    %edx,0xf022be88
f0101640:	eb 0c                	jmp    f010164e <mem_init+0x62>
	else
		npages = npages_basemem;
f0101642:	8b 15 38 b2 22 f0    	mov    0xf022b238,%edx
f0101648:	89 15 88 be 22 f0    	mov    %edx,0xf022be88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010164e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101651:	c1 e8 0a             	shr    $0xa,%eax
f0101654:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101658:	a1 38 b2 22 f0       	mov    0xf022b238,%eax
f010165d:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101660:	c1 e8 0a             	shr    $0xa,%eax
f0101663:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101667:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f010166c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010166f:	c1 e8 0a             	shr    $0xa,%eax
f0101672:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101676:	c7 04 24 b8 73 10 f0 	movl   $0xf01073b8,(%esp)
f010167d:	e8 54 2a 00 00       	call   f01040d6 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101682:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101687:	e8 c4 f4 ff ff       	call   f0100b50 <boot_alloc>
f010168c:	a3 8c be 22 f0       	mov    %eax,0xf022be8c
	memset(kern_pgdir, 0, PGSIZE);
f0101691:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101698:	00 
f0101699:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01016a0:	00 
f01016a1:	89 04 24             	mov    %eax,(%esp)
f01016a4:	e8 68 48 00 00       	call   f0105f11 <memset>
	cprintf("kern_pgdir %x\n", (uint32_t)kern_pgdir);
f01016a9:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01016ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016b2:	c7 04 24 8e 7c 10 f0 	movl   $0xf0107c8e,(%esp)
f01016b9:	e8 18 2a 00 00       	call   f01040d6 <cprintf>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01016be:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01016c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01016c8:	77 20                	ja     f01016ea <mem_init+0xfe>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01016ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016ce:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f01016d5:	f0 
f01016d6:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01016dd:	00 
f01016de:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01016e5:	e8 56 e9 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01016ea:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01016f0:	83 ca 05             	or     $0x5,%edx
f01016f3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo)*npages );
f01016f9:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f01016fe:	c1 e0 03             	shl    $0x3,%eax
f0101701:	e8 4a f4 ff ff       	call   f0100b50 <boot_alloc>
f0101706:	a3 90 be 22 f0       	mov    %eax,0xf022be90
	cprintf("pages %x\n", (uint32_t)pages);
f010170b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010170f:	c7 04 24 9d 7c 10 f0 	movl   $0xf0107c9d,(%esp)
f0101716:	e8 bb 29 00 00       	call   f01040d6 <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env)* NENV);
f010171b:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101720:	e8 2b f4 ff ff       	call   f0100b50 <boot_alloc>
f0101725:	a3 48 b2 22 f0       	mov    %eax,0xf022b248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010172a:	e8 9b f8 ff ff       	call   f0100fca <page_init>

	check_page_free_list(1);
f010172f:	b8 01 00 00 00       	mov    $0x1,%eax
f0101734:	e8 fc f4 ff ff       	call   f0100c35 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101739:	83 3d 90 be 22 f0 00 	cmpl   $0x0,0xf022be90
f0101740:	75 1c                	jne    f010175e <mem_init+0x172>
		panic("'pages' is a null pointer!");
f0101742:	c7 44 24 08 a7 7c 10 	movl   $0xf0107ca7,0x8(%esp)
f0101749:	f0 
f010174a:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f0101751:	00 
f0101752:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101759:	e8 e2 e8 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010175e:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101763:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101768:	85 c0                	test   %eax,%eax
f010176a:	74 09                	je     f0101775 <mem_init+0x189>
		++nfree;
f010176c:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010176f:	8b 00                	mov    (%eax),%eax
f0101771:	85 c0                	test   %eax,%eax
f0101773:	75 f7                	jne    f010176c <mem_init+0x180>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101775:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010177c:	e8 6b f9 ff ff       	call   f01010ec <page_alloc>
f0101781:	89 c6                	mov    %eax,%esi
f0101783:	85 c0                	test   %eax,%eax
f0101785:	75 24                	jne    f01017ab <mem_init+0x1bf>
f0101787:	c7 44 24 0c c2 7c 10 	movl   $0xf0107cc2,0xc(%esp)
f010178e:	f0 
f010178f:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101796:	f0 
f0101797:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f010179e:	00 
f010179f:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01017a6:	e8 95 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017b2:	e8 35 f9 ff ff       	call   f01010ec <page_alloc>
f01017b7:	89 c7                	mov    %eax,%edi
f01017b9:	85 c0                	test   %eax,%eax
f01017bb:	75 24                	jne    f01017e1 <mem_init+0x1f5>
f01017bd:	c7 44 24 0c d8 7c 10 	movl   $0xf0107cd8,0xc(%esp)
f01017c4:	f0 
f01017c5:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01017cc:	f0 
f01017cd:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f01017d4:	00 
f01017d5:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01017dc:	e8 5f e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017e8:	e8 ff f8 ff ff       	call   f01010ec <page_alloc>
f01017ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017f0:	85 c0                	test   %eax,%eax
f01017f2:	75 24                	jne    f0101818 <mem_init+0x22c>
f01017f4:	c7 44 24 0c ee 7c 10 	movl   $0xf0107cee,0xc(%esp)
f01017fb:	f0 
f01017fc:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101803:	f0 
f0101804:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f010180b:	00 
f010180c:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101813:	e8 28 e8 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101818:	39 fe                	cmp    %edi,%esi
f010181a:	75 24                	jne    f0101840 <mem_init+0x254>
f010181c:	c7 44 24 0c 04 7d 10 	movl   $0xf0107d04,0xc(%esp)
f0101823:	f0 
f0101824:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f010182b:	f0 
f010182c:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f0101833:	00 
f0101834:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f010183b:	e8 00 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101840:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101843:	74 05                	je     f010184a <mem_init+0x25e>
f0101845:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101848:	75 24                	jne    f010186e <mem_init+0x282>
f010184a:	c7 44 24 0c f4 73 10 	movl   $0xf01073f4,0xc(%esp)
f0101851:	f0 
f0101852:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101859:	f0 
f010185a:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0101861:	00 
f0101862:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101869:	e8 d2 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010186e:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101874:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101879:	c1 e0 0c             	shl    $0xc,%eax
f010187c:	89 f1                	mov    %esi,%ecx
f010187e:	29 d1                	sub    %edx,%ecx
f0101880:	c1 f9 03             	sar    $0x3,%ecx
f0101883:	c1 e1 0c             	shl    $0xc,%ecx
f0101886:	39 c1                	cmp    %eax,%ecx
f0101888:	72 24                	jb     f01018ae <mem_init+0x2c2>
f010188a:	c7 44 24 0c 16 7d 10 	movl   $0xf0107d16,0xc(%esp)
f0101891:	f0 
f0101892:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101899:	f0 
f010189a:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f01018a1:	00 
f01018a2:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01018a9:	e8 92 e7 ff ff       	call   f0100040 <_panic>
f01018ae:	89 f9                	mov    %edi,%ecx
f01018b0:	29 d1                	sub    %edx,%ecx
f01018b2:	c1 f9 03             	sar    $0x3,%ecx
f01018b5:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01018b8:	39 c8                	cmp    %ecx,%eax
f01018ba:	77 24                	ja     f01018e0 <mem_init+0x2f4>
f01018bc:	c7 44 24 0c 33 7d 10 	movl   $0xf0107d33,0xc(%esp)
f01018c3:	f0 
f01018c4:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01018cb:	f0 
f01018cc:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f01018d3:	00 
f01018d4:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01018db:	e8 60 e7 ff ff       	call   f0100040 <_panic>
f01018e0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01018e3:	29 d1                	sub    %edx,%ecx
f01018e5:	89 ca                	mov    %ecx,%edx
f01018e7:	c1 fa 03             	sar    $0x3,%edx
f01018ea:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01018ed:	39 d0                	cmp    %edx,%eax
f01018ef:	77 24                	ja     f0101915 <mem_init+0x329>
f01018f1:	c7 44 24 0c 50 7d 10 	movl   $0xf0107d50,0xc(%esp)
f01018f8:	f0 
f01018f9:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101900:	f0 
f0101901:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f0101908:	00 
f0101909:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101910:	e8 2b e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101915:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f010191a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010191d:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101924:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101927:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010192e:	e8 b9 f7 ff ff       	call   f01010ec <page_alloc>
f0101933:	85 c0                	test   %eax,%eax
f0101935:	74 24                	je     f010195b <mem_init+0x36f>
f0101937:	c7 44 24 0c 6d 7d 10 	movl   $0xf0107d6d,0xc(%esp)
f010193e:	f0 
f010193f:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101946:	f0 
f0101947:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f010194e:	00 
f010194f:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101956:	e8 e5 e6 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010195b:	89 34 24             	mov    %esi,(%esp)
f010195e:	e8 07 f8 ff ff       	call   f010116a <page_free>
	page_free(pp1);
f0101963:	89 3c 24             	mov    %edi,(%esp)
f0101966:	e8 ff f7 ff ff       	call   f010116a <page_free>
	page_free(pp2);
f010196b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010196e:	89 04 24             	mov    %eax,(%esp)
f0101971:	e8 f4 f7 ff ff       	call   f010116a <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101976:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010197d:	e8 6a f7 ff ff       	call   f01010ec <page_alloc>
f0101982:	89 c6                	mov    %eax,%esi
f0101984:	85 c0                	test   %eax,%eax
f0101986:	75 24                	jne    f01019ac <mem_init+0x3c0>
f0101988:	c7 44 24 0c c2 7c 10 	movl   $0xf0107cc2,0xc(%esp)
f010198f:	f0 
f0101990:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101997:	f0 
f0101998:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f010199f:	00 
f01019a0:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01019a7:	e8 94 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01019ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019b3:	e8 34 f7 ff ff       	call   f01010ec <page_alloc>
f01019b8:	89 c7                	mov    %eax,%edi
f01019ba:	85 c0                	test   %eax,%eax
f01019bc:	75 24                	jne    f01019e2 <mem_init+0x3f6>
f01019be:	c7 44 24 0c d8 7c 10 	movl   $0xf0107cd8,0xc(%esp)
f01019c5:	f0 
f01019c6:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01019cd:	f0 
f01019ce:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f01019d5:	00 
f01019d6:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01019dd:	e8 5e e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01019e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019e9:	e8 fe f6 ff ff       	call   f01010ec <page_alloc>
f01019ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019f1:	85 c0                	test   %eax,%eax
f01019f3:	75 24                	jne    f0101a19 <mem_init+0x42d>
f01019f5:	c7 44 24 0c ee 7c 10 	movl   $0xf0107cee,0xc(%esp)
f01019fc:	f0 
f01019fd:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101a04:	f0 
f0101a05:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f0101a0c:	00 
f0101a0d:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101a14:	e8 27 e6 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a19:	39 fe                	cmp    %edi,%esi
f0101a1b:	75 24                	jne    f0101a41 <mem_init+0x455>
f0101a1d:	c7 44 24 0c 04 7d 10 	movl   $0xf0107d04,0xc(%esp)
f0101a24:	f0 
f0101a25:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101a2c:	f0 
f0101a2d:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f0101a34:	00 
f0101a35:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101a3c:	e8 ff e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a41:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101a44:	74 05                	je     f0101a4b <mem_init+0x45f>
f0101a46:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101a49:	75 24                	jne    f0101a6f <mem_init+0x483>
f0101a4b:	c7 44 24 0c f4 73 10 	movl   $0xf01073f4,0xc(%esp)
f0101a52:	f0 
f0101a53:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101a5a:	f0 
f0101a5b:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0101a62:	00 
f0101a63:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101a6a:	e8 d1 e5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101a6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a76:	e8 71 f6 ff ff       	call   f01010ec <page_alloc>
f0101a7b:	85 c0                	test   %eax,%eax
f0101a7d:	74 24                	je     f0101aa3 <mem_init+0x4b7>
f0101a7f:	c7 44 24 0c 6d 7d 10 	movl   $0xf0107d6d,0xc(%esp)
f0101a86:	f0 
f0101a87:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101a8e:	f0 
f0101a8f:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0101a96:	00 
f0101a97:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101a9e:	e8 9d e5 ff ff       	call   f0100040 <_panic>
f0101aa3:	89 f0                	mov    %esi,%eax
f0101aa5:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101aab:	c1 f8 03             	sar    $0x3,%eax
f0101aae:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ab1:	89 c2                	mov    %eax,%edx
f0101ab3:	c1 ea 0c             	shr    $0xc,%edx
f0101ab6:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101abc:	72 20                	jb     f0101ade <mem_init+0x4f2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101abe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ac2:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0101ac9:	f0 
f0101aca:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101ad1:	00 
f0101ad2:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f0101ad9:	e8 62 e5 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101ade:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ae5:	00 
f0101ae6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101aed:	00 
	return (void *)(pa + KERNBASE);
f0101aee:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101af3:	89 04 24             	mov    %eax,(%esp)
f0101af6:	e8 16 44 00 00       	call   f0105f11 <memset>
	page_free(pp0);
f0101afb:	89 34 24             	mov    %esi,(%esp)
f0101afe:	e8 67 f6 ff ff       	call   f010116a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b0a:	e8 dd f5 ff ff       	call   f01010ec <page_alloc>
f0101b0f:	85 c0                	test   %eax,%eax
f0101b11:	75 24                	jne    f0101b37 <mem_init+0x54b>
f0101b13:	c7 44 24 0c 7c 7d 10 	movl   $0xf0107d7c,0xc(%esp)
f0101b1a:	f0 
f0101b1b:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101b22:	f0 
f0101b23:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101b2a:	00 
f0101b2b:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101b32:	e8 09 e5 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101b37:	39 c6                	cmp    %eax,%esi
f0101b39:	74 24                	je     f0101b5f <mem_init+0x573>
f0101b3b:	c7 44 24 0c 9a 7d 10 	movl   $0xf0107d9a,0xc(%esp)
f0101b42:	f0 
f0101b43:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101b4a:	f0 
f0101b4b:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0101b52:	00 
f0101b53:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101b5a:	e8 e1 e4 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b5f:	89 f2                	mov    %esi,%edx
f0101b61:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101b67:	c1 fa 03             	sar    $0x3,%edx
f0101b6a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b6d:	89 d0                	mov    %edx,%eax
f0101b6f:	c1 e8 0c             	shr    $0xc,%eax
f0101b72:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0101b78:	72 20                	jb     f0101b9a <mem_init+0x5ae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101b7e:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0101b85:	f0 
f0101b86:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101b8d:	00 
f0101b8e:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f0101b95:	e8 a6 e4 ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b9a:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101ba1:	75 11                	jne    f0101bb4 <mem_init+0x5c8>
f0101ba3:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101ba9:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101baf:	80 38 00             	cmpb   $0x0,(%eax)
f0101bb2:	74 24                	je     f0101bd8 <mem_init+0x5ec>
f0101bb4:	c7 44 24 0c aa 7d 10 	movl   $0xf0107daa,0xc(%esp)
f0101bbb:	f0 
f0101bbc:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101bc3:	f0 
f0101bc4:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101bcb:	00 
f0101bcc:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101bd3:	e8 68 e4 ff ff       	call   f0100040 <_panic>
f0101bd8:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101bdb:	39 d0                	cmp    %edx,%eax
f0101bdd:	75 d0                	jne    f0101baf <mem_init+0x5c3>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101bdf:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101be2:	89 15 40 b2 22 f0    	mov    %edx,0xf022b240

	// free the pages we took
	page_free(pp0);
f0101be8:	89 34 24             	mov    %esi,(%esp)
f0101beb:	e8 7a f5 ff ff       	call   f010116a <page_free>
	page_free(pp1);
f0101bf0:	89 3c 24             	mov    %edi,(%esp)
f0101bf3:	e8 72 f5 ff ff       	call   f010116a <page_free>
	page_free(pp2);
f0101bf8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bfb:	89 04 24             	mov    %eax,(%esp)
f0101bfe:	e8 67 f5 ff ff       	call   f010116a <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c03:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101c08:	85 c0                	test   %eax,%eax
f0101c0a:	74 09                	je     f0101c15 <mem_init+0x629>
		--nfree;
f0101c0c:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c0f:	8b 00                	mov    (%eax),%eax
f0101c11:	85 c0                	test   %eax,%eax
f0101c13:	75 f7                	jne    f0101c0c <mem_init+0x620>
		--nfree;
	assert(nfree == 0);
f0101c15:	85 db                	test   %ebx,%ebx
f0101c17:	74 24                	je     f0101c3d <mem_init+0x651>
f0101c19:	c7 44 24 0c b4 7d 10 	movl   $0xf0107db4,0xc(%esp)
f0101c20:	f0 
f0101c21:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101c28:	f0 
f0101c29:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101c30:	00 
f0101c31:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101c38:	e8 03 e4 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101c3d:	c7 04 24 14 74 10 f0 	movl   $0xf0107414,(%esp)
f0101c44:	e8 8d 24 00 00       	call   f01040d6 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c50:	e8 97 f4 ff ff       	call   f01010ec <page_alloc>
f0101c55:	89 c6                	mov    %eax,%esi
f0101c57:	85 c0                	test   %eax,%eax
f0101c59:	75 24                	jne    f0101c7f <mem_init+0x693>
f0101c5b:	c7 44 24 0c c2 7c 10 	movl   $0xf0107cc2,0xc(%esp)
f0101c62:	f0 
f0101c63:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101c6a:	f0 
f0101c6b:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0101c72:	00 
f0101c73:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101c7a:	e8 c1 e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c86:	e8 61 f4 ff ff       	call   f01010ec <page_alloc>
f0101c8b:	89 c7                	mov    %eax,%edi
f0101c8d:	85 c0                	test   %eax,%eax
f0101c8f:	75 24                	jne    f0101cb5 <mem_init+0x6c9>
f0101c91:	c7 44 24 0c d8 7c 10 	movl   $0xf0107cd8,0xc(%esp)
f0101c98:	f0 
f0101c99:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101ca0:	f0 
f0101ca1:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0101ca8:	00 
f0101ca9:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101cb0:	e8 8b e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101cb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cbc:	e8 2b f4 ff ff       	call   f01010ec <page_alloc>
f0101cc1:	89 c3                	mov    %eax,%ebx
f0101cc3:	85 c0                	test   %eax,%eax
f0101cc5:	75 24                	jne    f0101ceb <mem_init+0x6ff>
f0101cc7:	c7 44 24 0c ee 7c 10 	movl   $0xf0107cee,0xc(%esp)
f0101cce:	f0 
f0101ccf:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101cd6:	f0 
f0101cd7:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0101cde:	00 
f0101cdf:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101ce6:	e8 55 e3 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ceb:	39 fe                	cmp    %edi,%esi
f0101ced:	75 24                	jne    f0101d13 <mem_init+0x727>
f0101cef:	c7 44 24 0c 04 7d 10 	movl   $0xf0107d04,0xc(%esp)
f0101cf6:	f0 
f0101cf7:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101cfe:	f0 
f0101cff:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0101d06:	00 
f0101d07:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101d0e:	e8 2d e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d13:	39 c7                	cmp    %eax,%edi
f0101d15:	74 04                	je     f0101d1b <mem_init+0x72f>
f0101d17:	39 c6                	cmp    %eax,%esi
f0101d19:	75 24                	jne    f0101d3f <mem_init+0x753>
f0101d1b:	c7 44 24 0c f4 73 10 	movl   $0xf01073f4,0xc(%esp)
f0101d22:	f0 
f0101d23:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101d2a:	f0 
f0101d2b:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0101d32:	00 
f0101d33:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101d3a:	e8 01 e3 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101d3f:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f0101d45:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101d48:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101d4f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101d52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d59:	e8 8e f3 ff ff       	call   f01010ec <page_alloc>
f0101d5e:	85 c0                	test   %eax,%eax
f0101d60:	74 24                	je     f0101d86 <mem_init+0x79a>
f0101d62:	c7 44 24 0c 6d 7d 10 	movl   $0xf0107d6d,0xc(%esp)
f0101d69:	f0 
f0101d6a:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101d71:	f0 
f0101d72:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0101d79:	00 
f0101d7a:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101d81:	e8 ba e2 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d86:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d89:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101d8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101d94:	00 
f0101d95:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101d9a:	89 04 24             	mov    %eax,(%esp)
f0101d9d:	e8 30 f6 ff ff       	call   f01013d2 <page_lookup>
f0101da2:	85 c0                	test   %eax,%eax
f0101da4:	74 24                	je     f0101dca <mem_init+0x7de>
f0101da6:	c7 44 24 0c 34 74 10 	movl   $0xf0107434,0xc(%esp)
f0101dad:	f0 
f0101dae:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101db5:	f0 
f0101db6:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0101dbd:	00 
f0101dbe:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101dc5:	e8 76 e2 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101dca:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101dd1:	00 
f0101dd2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101dd9:	00 
f0101dda:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101dde:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101de3:	89 04 24             	mov    %eax,(%esp)
f0101de6:	e8 e4 f6 ff ff       	call   f01014cf <page_insert>
f0101deb:	85 c0                	test   %eax,%eax
f0101ded:	78 24                	js     f0101e13 <mem_init+0x827>
f0101def:	c7 44 24 0c 6c 74 10 	movl   $0xf010746c,0xc(%esp)
f0101df6:	f0 
f0101df7:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101dfe:	f0 
f0101dff:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101e06:	00 
f0101e07:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101e0e:	e8 2d e2 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101e13:	89 34 24             	mov    %esi,(%esp)
f0101e16:	e8 4f f3 ff ff       	call   f010116a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101e1b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e22:	00 
f0101e23:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e2a:	00 
f0101e2b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101e2f:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101e34:	89 04 24             	mov    %eax,(%esp)
f0101e37:	e8 93 f6 ff ff       	call   f01014cf <page_insert>
f0101e3c:	85 c0                	test   %eax,%eax
f0101e3e:	74 24                	je     f0101e64 <mem_init+0x878>
f0101e40:	c7 44 24 0c 9c 74 10 	movl   $0xf010749c,0xc(%esp)
f0101e47:	f0 
f0101e48:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101e4f:	f0 
f0101e50:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101e57:	00 
f0101e58:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101e5f:	e8 dc e1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e64:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f0101e6a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e6d:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0101e72:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e75:	8b 11                	mov    (%ecx),%edx
f0101e77:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e7d:	89 f0                	mov    %esi,%eax
f0101e7f:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101e82:	c1 f8 03             	sar    $0x3,%eax
f0101e85:	c1 e0 0c             	shl    $0xc,%eax
f0101e88:	39 c2                	cmp    %eax,%edx
f0101e8a:	74 24                	je     f0101eb0 <mem_init+0x8c4>
f0101e8c:	c7 44 24 0c cc 74 10 	movl   $0xf01074cc,0xc(%esp)
f0101e93:	f0 
f0101e94:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101e9b:	f0 
f0101e9c:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0101ea3:	00 
f0101ea4:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101eab:	e8 90 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101eb0:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eb8:	e8 d5 ec ff ff       	call   f0100b92 <check_va2pa>
f0101ebd:	89 fa                	mov    %edi,%edx
f0101ebf:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101ec2:	c1 fa 03             	sar    $0x3,%edx
f0101ec5:	c1 e2 0c             	shl    $0xc,%edx
f0101ec8:	39 d0                	cmp    %edx,%eax
f0101eca:	74 24                	je     f0101ef0 <mem_init+0x904>
f0101ecc:	c7 44 24 0c f4 74 10 	movl   $0xf01074f4,0xc(%esp)
f0101ed3:	f0 
f0101ed4:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101edb:	f0 
f0101edc:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0101ee3:	00 
f0101ee4:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101eeb:	e8 50 e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101ef0:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ef5:	74 24                	je     f0101f1b <mem_init+0x92f>
f0101ef7:	c7 44 24 0c bf 7d 10 	movl   $0xf0107dbf,0xc(%esp)
f0101efe:	f0 
f0101eff:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101f06:	f0 
f0101f07:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101f0e:	00 
f0101f0f:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101f16:	e8 25 e1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101f1b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f20:	74 24                	je     f0101f46 <mem_init+0x95a>
f0101f22:	c7 44 24 0c d0 7d 10 	movl   $0xf0107dd0,0xc(%esp)
f0101f29:	f0 
f0101f2a:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101f31:	f0 
f0101f32:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101f39:	00 
f0101f3a:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101f41:	e8 fa e0 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f46:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f4d:	00 
f0101f4e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f55:	00 
f0101f56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f5a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101f5d:	89 14 24             	mov    %edx,(%esp)
f0101f60:	e8 6a f5 ff ff       	call   f01014cf <page_insert>
f0101f65:	85 c0                	test   %eax,%eax
f0101f67:	74 24                	je     f0101f8d <mem_init+0x9a1>
f0101f69:	c7 44 24 0c 24 75 10 	movl   $0xf0107524,0xc(%esp)
f0101f70:	f0 
f0101f71:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101f78:	f0 
f0101f79:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101f80:	00 
f0101f81:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101f88:	e8 b3 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f8d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f92:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101f97:	e8 f6 eb ff ff       	call   f0100b92 <check_va2pa>
f0101f9c:	89 da                	mov    %ebx,%edx
f0101f9e:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101fa4:	c1 fa 03             	sar    $0x3,%edx
f0101fa7:	c1 e2 0c             	shl    $0xc,%edx
f0101faa:	39 d0                	cmp    %edx,%eax
f0101fac:	74 24                	je     f0101fd2 <mem_init+0x9e6>
f0101fae:	c7 44 24 0c 60 75 10 	movl   $0xf0107560,0xc(%esp)
f0101fb5:	f0 
f0101fb6:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101fbd:	f0 
f0101fbe:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101fc5:	00 
f0101fc6:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101fcd:	e8 6e e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101fd2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fd7:	74 24                	je     f0101ffd <mem_init+0xa11>
f0101fd9:	c7 44 24 0c e1 7d 10 	movl   $0xf0107de1,0xc(%esp)
f0101fe0:	f0 
f0101fe1:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0101fe8:	f0 
f0101fe9:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101ff0:	00 
f0101ff1:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0101ff8:	e8 43 e0 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ffd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102004:	e8 e3 f0 ff ff       	call   f01010ec <page_alloc>
f0102009:	85 c0                	test   %eax,%eax
f010200b:	74 24                	je     f0102031 <mem_init+0xa45>
f010200d:	c7 44 24 0c 6d 7d 10 	movl   $0xf0107d6d,0xc(%esp)
f0102014:	f0 
f0102015:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f010201c:	f0 
f010201d:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102024:	00 
f0102025:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f010202c:	e8 0f e0 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102031:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102038:	00 
f0102039:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102040:	00 
f0102041:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102045:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010204a:	89 04 24             	mov    %eax,(%esp)
f010204d:	e8 7d f4 ff ff       	call   f01014cf <page_insert>
f0102052:	85 c0                	test   %eax,%eax
f0102054:	74 24                	je     f010207a <mem_init+0xa8e>
f0102056:	c7 44 24 0c 24 75 10 	movl   $0xf0107524,0xc(%esp)
f010205d:	f0 
f010205e:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102065:	f0 
f0102066:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f010206d:	00 
f010206e:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102075:	e8 c6 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010207a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010207f:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102084:	e8 09 eb ff ff       	call   f0100b92 <check_va2pa>
f0102089:	89 da                	mov    %ebx,%edx
f010208b:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102091:	c1 fa 03             	sar    $0x3,%edx
f0102094:	c1 e2 0c             	shl    $0xc,%edx
f0102097:	39 d0                	cmp    %edx,%eax
f0102099:	74 24                	je     f01020bf <mem_init+0xad3>
f010209b:	c7 44 24 0c 60 75 10 	movl   $0xf0107560,0xc(%esp)
f01020a2:	f0 
f01020a3:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01020aa:	f0 
f01020ab:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f01020b2:	00 
f01020b3:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01020ba:	e8 81 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01020bf:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020c4:	74 24                	je     f01020ea <mem_init+0xafe>
f01020c6:	c7 44 24 0c e1 7d 10 	movl   $0xf0107de1,0xc(%esp)
f01020cd:	f0 
f01020ce:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01020d5:	f0 
f01020d6:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f01020dd:	00 
f01020de:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01020e5:	e8 56 df ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01020ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020f1:	e8 f6 ef ff ff       	call   f01010ec <page_alloc>
f01020f6:	85 c0                	test   %eax,%eax
f01020f8:	74 24                	je     f010211e <mem_init+0xb32>
f01020fa:	c7 44 24 0c 6d 7d 10 	movl   $0xf0107d6d,0xc(%esp)
f0102101:	f0 
f0102102:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102109:	f0 
f010210a:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0102111:	00 
f0102112:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102119:	e8 22 df ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010211e:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f0102124:	8b 02                	mov    (%edx),%eax
f0102126:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010212b:	89 c1                	mov    %eax,%ecx
f010212d:	c1 e9 0c             	shr    $0xc,%ecx
f0102130:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0102136:	72 20                	jb     f0102158 <mem_init+0xb6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102138:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010213c:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0102143:	f0 
f0102144:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f010214b:	00 
f010214c:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102153:	e8 e8 de ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102158:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010215d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102160:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102167:	00 
f0102168:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010216f:	00 
f0102170:	89 14 24             	mov    %edx,(%esp)
f0102173:	e8 58 f0 ff ff       	call   f01011d0 <pgdir_walk>
f0102178:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010217b:	83 c2 04             	add    $0x4,%edx
f010217e:	39 d0                	cmp    %edx,%eax
f0102180:	74 24                	je     f01021a6 <mem_init+0xbba>
f0102182:	c7 44 24 0c 90 75 10 	movl   $0xf0107590,0xc(%esp)
f0102189:	f0 
f010218a:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102191:	f0 
f0102192:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0102199:	00 
f010219a:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01021a1:	e8 9a de ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01021a6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01021ad:	00 
f01021ae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021b5:	00 
f01021b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01021ba:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01021bf:	89 04 24             	mov    %eax,(%esp)
f01021c2:	e8 08 f3 ff ff       	call   f01014cf <page_insert>
f01021c7:	85 c0                	test   %eax,%eax
f01021c9:	74 24                	je     f01021ef <mem_init+0xc03>
f01021cb:	c7 44 24 0c d0 75 10 	movl   $0xf01075d0,0xc(%esp)
f01021d2:	f0 
f01021d3:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01021da:	f0 
f01021db:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f01021e2:	00 
f01021e3:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01021ea:	e8 51 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021ef:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f01021f5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01021f8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021fd:	89 c8                	mov    %ecx,%eax
f01021ff:	e8 8e e9 ff ff       	call   f0100b92 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102204:	89 da                	mov    %ebx,%edx
f0102206:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f010220c:	c1 fa 03             	sar    $0x3,%edx
f010220f:	c1 e2 0c             	shl    $0xc,%edx
f0102212:	39 d0                	cmp    %edx,%eax
f0102214:	74 24                	je     f010223a <mem_init+0xc4e>
f0102216:	c7 44 24 0c 60 75 10 	movl   $0xf0107560,0xc(%esp)
f010221d:	f0 
f010221e:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102225:	f0 
f0102226:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f010222d:	00 
f010222e:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102235:	e8 06 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010223a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010223f:	74 24                	je     f0102265 <mem_init+0xc79>
f0102241:	c7 44 24 0c e1 7d 10 	movl   $0xf0107de1,0xc(%esp)
f0102248:	f0 
f0102249:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102250:	f0 
f0102251:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102258:	00 
f0102259:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102260:	e8 db dd ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102265:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010226c:	00 
f010226d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102274:	00 
f0102275:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102278:	89 04 24             	mov    %eax,(%esp)
f010227b:	e8 50 ef ff ff       	call   f01011d0 <pgdir_walk>
f0102280:	f6 00 04             	testb  $0x4,(%eax)
f0102283:	75 24                	jne    f01022a9 <mem_init+0xcbd>
f0102285:	c7 44 24 0c 10 76 10 	movl   $0xf0107610,0xc(%esp)
f010228c:	f0 
f010228d:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102294:	f0 
f0102295:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f010229c:	00 
f010229d:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01022a4:	e8 97 dd ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01022a9:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01022ae:	f6 00 04             	testb  $0x4,(%eax)
f01022b1:	75 24                	jne    f01022d7 <mem_init+0xceb>
f01022b3:	c7 44 24 0c f2 7d 10 	movl   $0xf0107df2,0xc(%esp)
f01022ba:	f0 
f01022bb:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01022c2:	f0 
f01022c3:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f01022ca:	00 
f01022cb:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01022d2:	e8 69 dd ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022d7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01022de:	00 
f01022df:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022e6:	00 
f01022e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01022eb:	89 04 24             	mov    %eax,(%esp)
f01022ee:	e8 dc f1 ff ff       	call   f01014cf <page_insert>
f01022f3:	85 c0                	test   %eax,%eax
f01022f5:	74 24                	je     f010231b <mem_init+0xd2f>
f01022f7:	c7 44 24 0c 24 75 10 	movl   $0xf0107524,0xc(%esp)
f01022fe:	f0 
f01022ff:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102306:	f0 
f0102307:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f010230e:	00 
f010230f:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102316:	e8 25 dd ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010231b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102322:	00 
f0102323:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010232a:	00 
f010232b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102330:	89 04 24             	mov    %eax,(%esp)
f0102333:	e8 98 ee ff ff       	call   f01011d0 <pgdir_walk>
f0102338:	f6 00 02             	testb  $0x2,(%eax)
f010233b:	75 24                	jne    f0102361 <mem_init+0xd75>
f010233d:	c7 44 24 0c 44 76 10 	movl   $0xf0107644,0xc(%esp)
f0102344:	f0 
f0102345:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f010234c:	f0 
f010234d:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0102354:	00 
f0102355:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f010235c:	e8 df dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102361:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102368:	00 
f0102369:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102370:	00 
f0102371:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102376:	89 04 24             	mov    %eax,(%esp)
f0102379:	e8 52 ee ff ff       	call   f01011d0 <pgdir_walk>
f010237e:	f6 00 04             	testb  $0x4,(%eax)
f0102381:	74 24                	je     f01023a7 <mem_init+0xdbb>
f0102383:	c7 44 24 0c 78 76 10 	movl   $0xf0107678,0xc(%esp)
f010238a:	f0 
f010238b:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102392:	f0 
f0102393:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f010239a:	00 
f010239b:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01023a2:	e8 99 dc ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01023a7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01023ae:	00 
f01023af:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01023b6:	00 
f01023b7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01023bb:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01023c0:	89 04 24             	mov    %eax,(%esp)
f01023c3:	e8 07 f1 ff ff       	call   f01014cf <page_insert>
f01023c8:	85 c0                	test   %eax,%eax
f01023ca:	78 24                	js     f01023f0 <mem_init+0xe04>
f01023cc:	c7 44 24 0c b0 76 10 	movl   $0xf01076b0,0xc(%esp)
f01023d3:	f0 
f01023d4:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01023db:	f0 
f01023dc:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f01023e3:	00 
f01023e4:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01023eb:	e8 50 dc ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01023f0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01023f7:	00 
f01023f8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023ff:	00 
f0102400:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102404:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102409:	89 04 24             	mov    %eax,(%esp)
f010240c:	e8 be f0 ff ff       	call   f01014cf <page_insert>
f0102411:	85 c0                	test   %eax,%eax
f0102413:	74 24                	je     f0102439 <mem_init+0xe4d>
f0102415:	c7 44 24 0c e8 76 10 	movl   $0xf01076e8,0xc(%esp)
f010241c:	f0 
f010241d:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102424:	f0 
f0102425:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f010242c:	00 
f010242d:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102434:	e8 07 dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102439:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102440:	00 
f0102441:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102448:	00 
f0102449:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010244e:	89 04 24             	mov    %eax,(%esp)
f0102451:	e8 7a ed ff ff       	call   f01011d0 <pgdir_walk>
f0102456:	f6 00 04             	testb  $0x4,(%eax)
f0102459:	74 24                	je     f010247f <mem_init+0xe93>
f010245b:	c7 44 24 0c 78 76 10 	movl   $0xf0107678,0xc(%esp)
f0102462:	f0 
f0102463:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f010246a:	f0 
f010246b:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102472:	00 
f0102473:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f010247a:	e8 c1 db ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010247f:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102484:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102487:	ba 00 00 00 00       	mov    $0x0,%edx
f010248c:	e8 01 e7 ff ff       	call   f0100b92 <check_va2pa>
f0102491:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102494:	89 f8                	mov    %edi,%eax
f0102496:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010249c:	c1 f8 03             	sar    $0x3,%eax
f010249f:	c1 e0 0c             	shl    $0xc,%eax
f01024a2:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01024a5:	74 24                	je     f01024cb <mem_init+0xedf>
f01024a7:	c7 44 24 0c 24 77 10 	movl   $0xf0107724,0xc(%esp)
f01024ae:	f0 
f01024af:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01024b6:	f0 
f01024b7:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f01024be:	00 
f01024bf:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01024c6:	e8 75 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024cb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024d3:	e8 ba e6 ff ff       	call   f0100b92 <check_va2pa>
f01024d8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01024db:	74 24                	je     f0102501 <mem_init+0xf15>
f01024dd:	c7 44 24 0c 50 77 10 	movl   $0xf0107750,0xc(%esp)
f01024e4:	f0 
f01024e5:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01024ec:	f0 
f01024ed:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f01024f4:	00 
f01024f5:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01024fc:	e8 3f db ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102501:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102506:	74 24                	je     f010252c <mem_init+0xf40>
f0102508:	c7 44 24 0c 08 7e 10 	movl   $0xf0107e08,0xc(%esp)
f010250f:	f0 
f0102510:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102517:	f0 
f0102518:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f010251f:	00 
f0102520:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102527:	e8 14 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010252c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102531:	74 24                	je     f0102557 <mem_init+0xf6b>
f0102533:	c7 44 24 0c 19 7e 10 	movl   $0xf0107e19,0xc(%esp)
f010253a:	f0 
f010253b:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102542:	f0 
f0102543:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f010254a:	00 
f010254b:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102552:	e8 e9 da ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102557:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010255e:	e8 89 eb ff ff       	call   f01010ec <page_alloc>
f0102563:	85 c0                	test   %eax,%eax
f0102565:	74 04                	je     f010256b <mem_init+0xf7f>
f0102567:	39 c3                	cmp    %eax,%ebx
f0102569:	74 24                	je     f010258f <mem_init+0xfa3>
f010256b:	c7 44 24 0c 80 77 10 	movl   $0xf0107780,0xc(%esp)
f0102572:	f0 
f0102573:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f010257a:	f0 
f010257b:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f0102582:	00 
f0102583:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f010258a:	e8 b1 da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010258f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102596:	00 
f0102597:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010259c:	89 04 24             	mov    %eax,(%esp)
f010259f:	e8 db ee ff ff       	call   f010147f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025a4:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f01025aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01025ad:	ba 00 00 00 00       	mov    $0x0,%edx
f01025b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025b5:	e8 d8 e5 ff ff       	call   f0100b92 <check_va2pa>
f01025ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025bd:	74 24                	je     f01025e3 <mem_init+0xff7>
f01025bf:	c7 44 24 0c a4 77 10 	movl   $0xf01077a4,0xc(%esp)
f01025c6:	f0 
f01025c7:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01025ce:	f0 
f01025cf:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f01025d6:	00 
f01025d7:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01025de:	e8 5d da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025e3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025eb:	e8 a2 e5 ff ff       	call   f0100b92 <check_va2pa>
f01025f0:	89 fa                	mov    %edi,%edx
f01025f2:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01025f8:	c1 fa 03             	sar    $0x3,%edx
f01025fb:	c1 e2 0c             	shl    $0xc,%edx
f01025fe:	39 d0                	cmp    %edx,%eax
f0102600:	74 24                	je     f0102626 <mem_init+0x103a>
f0102602:	c7 44 24 0c 50 77 10 	movl   $0xf0107750,0xc(%esp)
f0102609:	f0 
f010260a:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102611:	f0 
f0102612:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102619:	00 
f010261a:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102621:	e8 1a da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102626:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010262b:	74 24                	je     f0102651 <mem_init+0x1065>
f010262d:	c7 44 24 0c bf 7d 10 	movl   $0xf0107dbf,0xc(%esp)
f0102634:	f0 
f0102635:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f010263c:	f0 
f010263d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102644:	00 
f0102645:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f010264c:	e8 ef d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102651:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102656:	74 24                	je     f010267c <mem_init+0x1090>
f0102658:	c7 44 24 0c 19 7e 10 	movl   $0xf0107e19,0xc(%esp)
f010265f:	f0 
f0102660:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102667:	f0 
f0102668:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f010266f:	00 
f0102670:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102677:	e8 c4 d9 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010267c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102683:	00 
f0102684:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102687:	89 0c 24             	mov    %ecx,(%esp)
f010268a:	e8 f0 ed ff ff       	call   f010147f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010268f:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102694:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102697:	ba 00 00 00 00       	mov    $0x0,%edx
f010269c:	e8 f1 e4 ff ff       	call   f0100b92 <check_va2pa>
f01026a1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026a4:	74 24                	je     f01026ca <mem_init+0x10de>
f01026a6:	c7 44 24 0c a4 77 10 	movl   $0xf01077a4,0xc(%esp)
f01026ad:	f0 
f01026ae:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01026b5:	f0 
f01026b6:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f01026bd:	00 
f01026be:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01026c5:	e8 76 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01026ca:	ba 00 10 00 00       	mov    $0x1000,%edx
f01026cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026d2:	e8 bb e4 ff ff       	call   f0100b92 <check_va2pa>
f01026d7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026da:	74 24                	je     f0102700 <mem_init+0x1114>
f01026dc:	c7 44 24 0c c8 77 10 	movl   $0xf01077c8,0xc(%esp)
f01026e3:	f0 
f01026e4:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01026eb:	f0 
f01026ec:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01026f3:	00 
f01026f4:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01026fb:	e8 40 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102700:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102705:	74 24                	je     f010272b <mem_init+0x113f>
f0102707:	c7 44 24 0c 2a 7e 10 	movl   $0xf0107e2a,0xc(%esp)
f010270e:	f0 
f010270f:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102716:	f0 
f0102717:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f010271e:	00 
f010271f:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102726:	e8 15 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010272b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102730:	74 24                	je     f0102756 <mem_init+0x116a>
f0102732:	c7 44 24 0c 19 7e 10 	movl   $0xf0107e19,0xc(%esp)
f0102739:	f0 
f010273a:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102741:	f0 
f0102742:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102749:	00 
f010274a:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102751:	e8 ea d8 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102756:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010275d:	e8 8a e9 ff ff       	call   f01010ec <page_alloc>
f0102762:	85 c0                	test   %eax,%eax
f0102764:	74 04                	je     f010276a <mem_init+0x117e>
f0102766:	39 c7                	cmp    %eax,%edi
f0102768:	74 24                	je     f010278e <mem_init+0x11a2>
f010276a:	c7 44 24 0c f0 77 10 	movl   $0xf01077f0,0xc(%esp)
f0102771:	f0 
f0102772:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102779:	f0 
f010277a:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102781:	00 
f0102782:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102789:	e8 b2 d8 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010278e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102795:	e8 52 e9 ff ff       	call   f01010ec <page_alloc>
f010279a:	85 c0                	test   %eax,%eax
f010279c:	74 24                	je     f01027c2 <mem_init+0x11d6>
f010279e:	c7 44 24 0c 6d 7d 10 	movl   $0xf0107d6d,0xc(%esp)
f01027a5:	f0 
f01027a6:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01027ad:	f0 
f01027ae:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f01027b5:	00 
f01027b6:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01027bd:	e8 7e d8 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027c2:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01027c7:	8b 08                	mov    (%eax),%ecx
f01027c9:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01027cf:	89 f2                	mov    %esi,%edx
f01027d1:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01027d7:	c1 fa 03             	sar    $0x3,%edx
f01027da:	c1 e2 0c             	shl    $0xc,%edx
f01027dd:	39 d1                	cmp    %edx,%ecx
f01027df:	74 24                	je     f0102805 <mem_init+0x1219>
f01027e1:	c7 44 24 0c cc 74 10 	movl   $0xf01074cc,0xc(%esp)
f01027e8:	f0 
f01027e9:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01027f0:	f0 
f01027f1:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f01027f8:	00 
f01027f9:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102800:	e8 3b d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102805:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010280b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102810:	74 24                	je     f0102836 <mem_init+0x124a>
f0102812:	c7 44 24 0c d0 7d 10 	movl   $0xf0107dd0,0xc(%esp)
f0102819:	f0 
f010281a:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102821:	f0 
f0102822:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f0102829:	00 
f010282a:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102831:	e8 0a d8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102836:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010283c:	89 34 24             	mov    %esi,(%esp)
f010283f:	e8 26 e9 ff ff       	call   f010116a <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102844:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010284b:	00 
f010284c:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102853:	00 
f0102854:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102859:	89 04 24             	mov    %eax,(%esp)
f010285c:	e8 6f e9 ff ff       	call   f01011d0 <pgdir_walk>
f0102861:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102864:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f010286a:	8b 51 04             	mov    0x4(%ecx),%edx
f010286d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102873:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102876:	8b 15 88 be 22 f0    	mov    0xf022be88,%edx
f010287c:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010287f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102882:	c1 ea 0c             	shr    $0xc,%edx
f0102885:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102888:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010288b:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f010288e:	72 23                	jb     f01028b3 <mem_init+0x12c7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102890:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102893:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102897:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f010289e:	f0 
f010289f:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f01028a6:	00 
f01028a7:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01028ae:	e8 8d d7 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01028b6:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01028bc:	39 d0                	cmp    %edx,%eax
f01028be:	74 24                	je     f01028e4 <mem_init+0x12f8>
f01028c0:	c7 44 24 0c 3b 7e 10 	movl   $0xf0107e3b,0xc(%esp)
f01028c7:	f0 
f01028c8:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01028cf:	f0 
f01028d0:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f01028d7:	00 
f01028d8:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01028df:	e8 5c d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01028e4:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01028eb:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01028f1:	89 f0                	mov    %esi,%eax
f01028f3:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01028f9:	c1 f8 03             	sar    $0x3,%eax
f01028fc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028ff:	89 c1                	mov    %eax,%ecx
f0102901:	c1 e9 0c             	shr    $0xc,%ecx
f0102904:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102907:	77 20                	ja     f0102929 <mem_init+0x133d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102909:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010290d:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0102914:	f0 
f0102915:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010291c:	00 
f010291d:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f0102924:	e8 17 d7 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102929:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102930:	00 
f0102931:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102938:	00 
	return (void *)(pa + KERNBASE);
f0102939:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010293e:	89 04 24             	mov    %eax,(%esp)
f0102941:	e8 cb 35 00 00       	call   f0105f11 <memset>
	page_free(pp0);
f0102946:	89 34 24             	mov    %esi,(%esp)
f0102949:	e8 1c e8 ff ff       	call   f010116a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010294e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102955:	00 
f0102956:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010295d:	00 
f010295e:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102963:	89 04 24             	mov    %eax,(%esp)
f0102966:	e8 65 e8 ff ff       	call   f01011d0 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010296b:	89 f2                	mov    %esi,%edx
f010296d:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102973:	c1 fa 03             	sar    $0x3,%edx
f0102976:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102979:	89 d0                	mov    %edx,%eax
f010297b:	c1 e8 0c             	shr    $0xc,%eax
f010297e:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0102984:	72 20                	jb     f01029a6 <mem_init+0x13ba>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102986:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010298a:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0102991:	f0 
f0102992:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102999:	00 
f010299a:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f01029a1:	e8 9a d6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01029a6:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01029ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01029af:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f01029b6:	75 11                	jne    f01029c9 <mem_init+0x13dd>
f01029b8:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01029be:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01029c4:	f6 00 01             	testb  $0x1,(%eax)
f01029c7:	74 24                	je     f01029ed <mem_init+0x1401>
f01029c9:	c7 44 24 0c 53 7e 10 	movl   $0xf0107e53,0xc(%esp)
f01029d0:	f0 
f01029d1:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01029d8:	f0 
f01029d9:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f01029e0:	00 
f01029e1:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01029e8:	e8 53 d6 ff ff       	call   f0100040 <_panic>
f01029ed:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01029f0:	39 d0                	cmp    %edx,%eax
f01029f2:	75 d0                	jne    f01029c4 <mem_init+0x13d8>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01029f4:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01029f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01029ff:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102a05:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102a08:	89 0d 40 b2 22 f0    	mov    %ecx,0xf022b240

	// free the pages we took
	page_free(pp0);
f0102a0e:	89 34 24             	mov    %esi,(%esp)
f0102a11:	e8 54 e7 ff ff       	call   f010116a <page_free>
	page_free(pp1);
f0102a16:	89 3c 24             	mov    %edi,(%esp)
f0102a19:	e8 4c e7 ff ff       	call   f010116a <page_free>
	page_free(pp2);
f0102a1e:	89 1c 24             	mov    %ebx,(%esp)
f0102a21:	e8 44 e7 ff ff       	call   f010116a <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102a26:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102a2d:	00 
f0102a2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a35:	e8 3f eb ff ff       	call   f0101579 <mmio_map_region>
f0102a3a:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102a3c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102a43:	00 
f0102a44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a4b:	e8 29 eb ff ff       	call   f0101579 <mmio_map_region>
f0102a50:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102a52:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102a58:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102a5e:	76 07                	jbe    f0102a67 <mem_init+0x147b>
f0102a60:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102a65:	76 24                	jbe    f0102a8b <mem_init+0x149f>
f0102a67:	c7 44 24 0c 14 78 10 	movl   $0xf0107814,0xc(%esp)
f0102a6e:	f0 
f0102a6f:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102a76:	f0 
f0102a77:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102a7e:	00 
f0102a7f:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102a86:	e8 b5 d5 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102a8b:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102a91:	76 0e                	jbe    f0102aa1 <mem_init+0x14b5>
f0102a93:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102a99:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102a9f:	76 24                	jbe    f0102ac5 <mem_init+0x14d9>
f0102aa1:	c7 44 24 0c 3c 78 10 	movl   $0xf010783c,0xc(%esp)
f0102aa8:	f0 
f0102aa9:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102ab0:	f0 
f0102ab1:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0102ab8:	00 
f0102ab9:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102ac0:	e8 7b d5 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ac5:	89 da                	mov    %ebx,%edx
f0102ac7:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102ac9:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102acf:	74 24                	je     f0102af5 <mem_init+0x1509>
f0102ad1:	c7 44 24 0c 64 78 10 	movl   $0xf0107864,0xc(%esp)
f0102ad8:	f0 
f0102ad9:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102ae0:	f0 
f0102ae1:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0102ae8:	00 
f0102ae9:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102af0:	e8 4b d5 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102af5:	39 c6                	cmp    %eax,%esi
f0102af7:	73 24                	jae    f0102b1d <mem_init+0x1531>
f0102af9:	c7 44 24 0c 6a 7e 10 	movl   $0xf0107e6a,0xc(%esp)
f0102b00:	f0 
f0102b01:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102b08:	f0 
f0102b09:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0102b10:	00 
f0102b11:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102b18:	e8 23 d5 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102b1d:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102b23:	89 da                	mov    %ebx,%edx
f0102b25:	89 f8                	mov    %edi,%eax
f0102b27:	e8 66 e0 ff ff       	call   f0100b92 <check_va2pa>
f0102b2c:	85 c0                	test   %eax,%eax
f0102b2e:	74 24                	je     f0102b54 <mem_init+0x1568>
f0102b30:	c7 44 24 0c 8c 78 10 	movl   $0xf010788c,0xc(%esp)
f0102b37:	f0 
f0102b38:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102b3f:	f0 
f0102b40:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102b47:	00 
f0102b48:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102b4f:	e8 ec d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102b54:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102b5a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b5d:	89 c2                	mov    %eax,%edx
f0102b5f:	89 f8                	mov    %edi,%eax
f0102b61:	e8 2c e0 ff ff       	call   f0100b92 <check_va2pa>
f0102b66:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102b6b:	74 24                	je     f0102b91 <mem_init+0x15a5>
f0102b6d:	c7 44 24 0c b0 78 10 	movl   $0xf01078b0,0xc(%esp)
f0102b74:	f0 
f0102b75:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102b7c:	f0 
f0102b7d:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102b84:	00 
f0102b85:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102b8c:	e8 af d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102b91:	89 f2                	mov    %esi,%edx
f0102b93:	89 f8                	mov    %edi,%eax
f0102b95:	e8 f8 df ff ff       	call   f0100b92 <check_va2pa>
f0102b9a:	85 c0                	test   %eax,%eax
f0102b9c:	74 24                	je     f0102bc2 <mem_init+0x15d6>
f0102b9e:	c7 44 24 0c e0 78 10 	movl   $0xf01078e0,0xc(%esp)
f0102ba5:	f0 
f0102ba6:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102bad:	f0 
f0102bae:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f0102bb5:	00 
f0102bb6:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102bbd:	e8 7e d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102bc2:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102bc8:	89 f8                	mov    %edi,%eax
f0102bca:	e8 c3 df ff ff       	call   f0100b92 <check_va2pa>
f0102bcf:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102bd2:	74 24                	je     f0102bf8 <mem_init+0x160c>
f0102bd4:	c7 44 24 0c 04 79 10 	movl   $0xf0107904,0xc(%esp)
f0102bdb:	f0 
f0102bdc:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102be3:	f0 
f0102be4:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102beb:	00 
f0102bec:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102bf3:	e8 48 d4 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102bf8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bff:	00 
f0102c00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c04:	89 3c 24             	mov    %edi,(%esp)
f0102c07:	e8 c4 e5 ff ff       	call   f01011d0 <pgdir_walk>
f0102c0c:	f6 00 1a             	testb  $0x1a,(%eax)
f0102c0f:	75 24                	jne    f0102c35 <mem_init+0x1649>
f0102c11:	c7 44 24 0c 30 79 10 	movl   $0xf0107930,0xc(%esp)
f0102c18:	f0 
f0102c19:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102c20:	f0 
f0102c21:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f0102c28:	00 
f0102c29:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102c30:	e8 0b d4 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102c35:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c3c:	00 
f0102c3d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c41:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102c46:	89 04 24             	mov    %eax,(%esp)
f0102c49:	e8 82 e5 ff ff       	call   f01011d0 <pgdir_walk>
f0102c4e:	f6 00 04             	testb  $0x4,(%eax)
f0102c51:	74 24                	je     f0102c77 <mem_init+0x168b>
f0102c53:	c7 44 24 0c 74 79 10 	movl   $0xf0107974,0xc(%esp)
f0102c5a:	f0 
f0102c5b:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102c62:	f0 
f0102c63:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f0102c6a:	00 
f0102c6b:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102c72:	e8 c9 d3 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102c77:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c7e:	00 
f0102c7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c83:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102c88:	89 04 24             	mov    %eax,(%esp)
f0102c8b:	e8 40 e5 ff ff       	call   f01011d0 <pgdir_walk>
f0102c90:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102c96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c9d:	00 
f0102c9e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102ca1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102ca5:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102caa:	89 04 24             	mov    %eax,(%esp)
f0102cad:	e8 1e e5 ff ff       	call   f01011d0 <pgdir_walk>
f0102cb2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102cb8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102cbf:	00 
f0102cc0:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102cc4:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102cc9:	89 04 24             	mov    %eax,(%esp)
f0102ccc:	e8 ff e4 ff ff       	call   f01011d0 <pgdir_walk>
f0102cd1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102cd7:	c7 04 24 7c 7e 10 f0 	movl   $0xf0107e7c,(%esp)
f0102cde:	e8 f3 13 00 00       	call   f01040d6 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(
f0102ce3:	a1 90 be 22 f0       	mov    0xf022be90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ce8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ced:	77 20                	ja     f0102d0f <mem_init+0x1723>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cef:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cf3:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0102cfa:	f0 
f0102cfb:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f0102d02:	00 
f0102d03:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102d0a:	e8 31 d3 ff ff       	call   f0100040 <_panic>
f0102d0f:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0102d15:	c1 e1 03             	shl    $0x3,%ecx
f0102d18:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102d1f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d20:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d25:	89 04 24             	mov    %eax,(%esp)
f0102d28:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d2d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102d32:	e8 41 e6 ff ff       	call   f0101378 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,
f0102d37:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d3c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d41:	77 20                	ja     f0102d63 <mem_init+0x1777>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d47:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0102d4e:	f0 
f0102d4f:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f0102d56:	00 
f0102d57:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102d5e:	e8 dd d2 ff ff       	call   f0100040 <_panic>
f0102d63:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102d6a:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d6b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d70:	89 04 24             	mov    %eax,(%esp)
f0102d73:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102d78:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102d7d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102d82:	e8 f1 e5 ff ff       	call   f0101378 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d87:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102d8c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d91:	77 20                	ja     f0102db3 <mem_init+0x17c7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d93:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d97:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0102d9e:	f0 
f0102d9f:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
f0102da6:	00 
f0102da7:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102dae:	e8 8d d2 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	 boot_map_region(
f0102db3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102dba:	00 
f0102dbb:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f0102dc2:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102dc7:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102dcc:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102dd1:	e8 a2 e5 ff ff       	call   f0101378 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(
f0102dd6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102ddd:	00 
f0102dde:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102de5:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102dea:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102def:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102df4:	e8 7f e5 ff ff       	call   f0101378 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102df9:	b8 00 d0 22 f0       	mov    $0xf022d000,%eax
f0102dfe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e03:	0f 87 d3 07 00 00    	ja     f01035dc <mem_init+0x1ff0>
f0102e09:	eb 0c                	jmp    f0102e17 <mem_init+0x182b>
	// LAB 4: Your code here:
	uintptr_t kstack_start = KSTACKTOP-KSTKSIZE;
	
	int i;
	for (i=0; i!= NCPU; i++){
		boot_map_region(kern_pgdir,kstack_start, KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_W);
f0102e0b:	89 d8                	mov    %ebx,%eax
f0102e0d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102e13:	77 27                	ja     f0102e3c <mem_init+0x1850>
f0102e15:	eb 05                	jmp    f0102e1c <mem_init+0x1830>
f0102e17:	b8 00 d0 22 f0       	mov    $0xf022d000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e20:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0102e27:	f0 
f0102e28:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0102e2f:	00 
f0102e30:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102e37:	e8 04 d2 ff ff       	call   f0100040 <_panic>
f0102e3c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102e43:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e44:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	// LAB 4: Your code here:
	uintptr_t kstack_start = KSTACKTOP-KSTKSIZE;
	
	int i;
	for (i=0; i!= NCPU; i++){
		boot_map_region(kern_pgdir,kstack_start, KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_W);
f0102e4a:	89 04 24             	mov    %eax,(%esp)
f0102e4d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e52:	89 f2                	mov    %esi,%edx
f0102e54:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102e59:	e8 1a e5 ff ff       	call   f0101378 <boot_map_region>
		kstack_start -= (KSTKSIZE+KSTKGAP);
f0102e5e:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102e64:	81 c3 00 80 00 00    	add    $0x8000,%ebx
	//
	// LAB 4: Your code here:
	uintptr_t kstack_start = KSTACKTOP-KSTKSIZE;
	
	int i;
	for (i=0; i!= NCPU; i++){
f0102e6a:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102e70:	75 99                	jne    f0102e0b <mem_init+0x181f>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102e72:	8b 1d 8c be 22 f0    	mov    0xf022be8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102e78:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0102e7e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102e81:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102e88:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102e8e:	0f 84 80 00 00 00    	je     f0102f14 <mem_init+0x1928>
f0102e94:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e99:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e9f:	89 d8                	mov    %ebx,%eax
f0102ea1:	e8 ec dc ff ff       	call   f0100b92 <check_va2pa>
f0102ea6:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102eac:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102eb2:	77 20                	ja     f0102ed4 <mem_init+0x18e8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102eb4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102eb8:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0102ebf:	f0 
f0102ec0:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0102ec7:	00 
f0102ec8:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102ecf:	e8 6c d1 ff ff       	call   f0100040 <_panic>
f0102ed4:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102edb:	39 d0                	cmp    %edx,%eax
f0102edd:	74 24                	je     f0102f03 <mem_init+0x1917>
f0102edf:	c7 44 24 0c a8 79 10 	movl   $0xf01079a8,0xc(%esp)
f0102ee6:	f0 
f0102ee7:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102eee:	f0 
f0102eef:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0102ef6:	00 
f0102ef7:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102efe:	e8 3d d1 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102f03:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f09:	39 f7                	cmp    %esi,%edi
f0102f0b:	77 8c                	ja     f0102e99 <mem_init+0x18ad>
f0102f0d:	be 00 00 00 00       	mov    $0x0,%esi
f0102f12:	eb 05                	jmp    f0102f19 <mem_init+0x192d>
f0102f14:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f19:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102f1f:	89 d8                	mov    %ebx,%eax
f0102f21:	e8 6c dc ff ff       	call   f0100b92 <check_va2pa>
f0102f26:	8b 15 48 b2 22 f0    	mov    0xf022b248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f2c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102f32:	77 20                	ja     f0102f54 <mem_init+0x1968>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f34:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f38:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0102f3f:	f0 
f0102f40:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0102f47:	00 
f0102f48:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102f4f:	e8 ec d0 ff ff       	call   f0100040 <_panic>
f0102f54:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102f5b:	39 d0                	cmp    %edx,%eax
f0102f5d:	74 24                	je     f0102f83 <mem_init+0x1997>
f0102f5f:	c7 44 24 0c dc 79 10 	movl   $0xf01079dc,0xc(%esp)
f0102f66:	f0 
f0102f67:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102f6e:	f0 
f0102f6f:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0102f76:	00 
f0102f77:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102f7e:	e8 bd d0 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102f83:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f89:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102f8f:	75 88                	jne    f0102f19 <mem_init+0x192d>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f91:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102f94:	c1 e7 0c             	shl    $0xc,%edi
f0102f97:	85 ff                	test   %edi,%edi
f0102f99:	74 44                	je     f0102fdf <mem_init+0x19f3>
f0102f9b:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102fa0:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102fa6:	89 d8                	mov    %ebx,%eax
f0102fa8:	e8 e5 db ff ff       	call   f0100b92 <check_va2pa>
f0102fad:	39 c6                	cmp    %eax,%esi
f0102faf:	74 24                	je     f0102fd5 <mem_init+0x19e9>
f0102fb1:	c7 44 24 0c 10 7a 10 	movl   $0xf0107a10,0xc(%esp)
f0102fb8:	f0 
f0102fb9:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0102fc0:	f0 
f0102fc1:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102fc8:	00 
f0102fc9:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0102fd0:	e8 6b d0 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102fd5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102fdb:	39 fe                	cmp    %edi,%esi
f0102fdd:	72 c1                	jb     f0102fa0 <mem_init+0x19b4>
f0102fdf:	c7 45 cc 00 d0 22 f0 	movl   $0xf022d000,-0x34(%ebp)
f0102fe6:	c7 45 d0 00 00 ff ef 	movl   $0xefff0000,-0x30(%ebp)
f0102fed:	89 df                	mov    %ebx,%edi
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102fef:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102ff2:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102ff5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102ff8:	81 c3 00 80 00 00    	add    $0x8000,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ffe:	89 c6                	mov    %eax,%esi
f0103000:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0103006:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103009:	81 c2 00 00 01 00    	add    $0x10000,%edx
f010300f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103012:	89 da                	mov    %ebx,%edx
f0103014:	89 f8                	mov    %edi,%eax
f0103016:	e8 77 db ff ff       	call   f0100b92 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010301b:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103022:	77 23                	ja     f0103047 <mem_init+0x1a5b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103024:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103027:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010302b:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0103032:	f0 
f0103033:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f010303a:	00 
f010303b:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0103042:	e8 f9 cf ff ff       	call   f0100040 <_panic>
f0103047:	39 f0                	cmp    %esi,%eax
f0103049:	74 24                	je     f010306f <mem_init+0x1a83>
f010304b:	c7 44 24 0c 38 7a 10 	movl   $0xf0107a38,0xc(%esp)
f0103052:	f0 
f0103053:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f010305a:	f0 
f010305b:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0103062:	00 
f0103063:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f010306a:	e8 d1 cf ff ff       	call   f0100040 <_panic>
f010306f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103075:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010307b:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f010307e:	0f 85 8a 05 00 00    	jne    f010360e <mem_init+0x2022>
f0103084:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103089:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010308c:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f010308f:	89 f8                	mov    %edi,%eax
f0103091:	e8 fc da ff ff       	call   f0100b92 <check_va2pa>
f0103096:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103099:	74 24                	je     f01030bf <mem_init+0x1ad3>
f010309b:	c7 44 24 0c 80 7a 10 	movl   $0xf0107a80,0xc(%esp)
f01030a2:	f0 
f01030a3:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01030aa:	f0 
f01030ab:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f01030b2:	00 
f01030b3:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01030ba:	e8 81 cf ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01030bf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01030c5:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f01030cb:	75 bf                	jne    f010308c <mem_init+0x1aa0>
f01030cd:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f01030d4:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01030db:	81 7d d0 00 00 f7 ef 	cmpl   $0xeff70000,-0x30(%ebp)
f01030e2:	0f 85 07 ff ff ff    	jne    f0102fef <mem_init+0x1a03>
f01030e8:	89 fb                	mov    %edi,%ebx
f01030ea:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01030ef:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01030f5:	83 fa 04             	cmp    $0x4,%edx
f01030f8:	77 2e                	ja     f0103128 <mem_init+0x1b3c>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01030fa:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01030fe:	0f 85 aa 00 00 00    	jne    f01031ae <mem_init+0x1bc2>
f0103104:	c7 44 24 0c 95 7e 10 	movl   $0xf0107e95,0xc(%esp)
f010310b:	f0 
f010310c:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0103113:	f0 
f0103114:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f010311b:	00 
f010311c:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0103123:	e8 18 cf ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0103128:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010312d:	76 55                	jbe    f0103184 <mem_init+0x1b98>
				assert(pgdir[i] & PTE_P);
f010312f:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0103132:	f6 c2 01             	test   $0x1,%dl
f0103135:	75 24                	jne    f010315b <mem_init+0x1b6f>
f0103137:	c7 44 24 0c 95 7e 10 	movl   $0xf0107e95,0xc(%esp)
f010313e:	f0 
f010313f:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0103146:	f0 
f0103147:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f010314e:	00 
f010314f:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0103156:	e8 e5 ce ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010315b:	f6 c2 02             	test   $0x2,%dl
f010315e:	75 4e                	jne    f01031ae <mem_init+0x1bc2>
f0103160:	c7 44 24 0c a6 7e 10 	movl   $0xf0107ea6,0xc(%esp)
f0103167:	f0 
f0103168:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f010316f:	f0 
f0103170:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0103177:	00 
f0103178:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f010317f:	e8 bc ce ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103184:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103188:	74 24                	je     f01031ae <mem_init+0x1bc2>
f010318a:	c7 44 24 0c b7 7e 10 	movl   $0xf0107eb7,0xc(%esp)
f0103191:	f0 
f0103192:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0103199:	f0 
f010319a:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f01031a1:	00 
f01031a2:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01031a9:	e8 92 ce ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01031ae:	83 c0 01             	add    $0x1,%eax
f01031b1:	3d 00 04 00 00       	cmp    $0x400,%eax
f01031b6:	0f 85 33 ff ff ff    	jne    f01030ef <mem_init+0x1b03>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01031bc:	c7 04 24 a4 7a 10 f0 	movl   $0xf0107aa4,(%esp)
f01031c3:	e8 0e 0f 00 00       	call   f01040d6 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01031c8:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031d2:	77 20                	ja     f01031f4 <mem_init+0x1c08>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031d8:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f01031df:	f0 
f01031e0:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
f01031e7:	00 
f01031e8:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01031ef:	e8 4c ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01031f4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01031f9:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01031fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0103201:	e8 2f da ff ff       	call   f0100c35 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103206:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103209:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010320e:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103211:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103214:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010321b:	e8 cc de ff ff       	call   f01010ec <page_alloc>
f0103220:	89 c6                	mov    %eax,%esi
f0103222:	85 c0                	test   %eax,%eax
f0103224:	75 24                	jne    f010324a <mem_init+0x1c5e>
f0103226:	c7 44 24 0c c2 7c 10 	movl   $0xf0107cc2,0xc(%esp)
f010322d:	f0 
f010322e:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0103235:	f0 
f0103236:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f010323d:	00 
f010323e:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0103245:	e8 f6 cd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010324a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103251:	e8 96 de ff ff       	call   f01010ec <page_alloc>
f0103256:	89 c7                	mov    %eax,%edi
f0103258:	85 c0                	test   %eax,%eax
f010325a:	75 24                	jne    f0103280 <mem_init+0x1c94>
f010325c:	c7 44 24 0c d8 7c 10 	movl   $0xf0107cd8,0xc(%esp)
f0103263:	f0 
f0103264:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f010326b:	f0 
f010326c:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0103273:	00 
f0103274:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f010327b:	e8 c0 cd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103280:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103287:	e8 60 de ff ff       	call   f01010ec <page_alloc>
f010328c:	89 c3                	mov    %eax,%ebx
f010328e:	85 c0                	test   %eax,%eax
f0103290:	75 24                	jne    f01032b6 <mem_init+0x1cca>
f0103292:	c7 44 24 0c ee 7c 10 	movl   $0xf0107cee,0xc(%esp)
f0103299:	f0 
f010329a:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01032a1:	f0 
f01032a2:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f01032a9:	00 
f01032aa:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01032b1:	e8 8a cd ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01032b6:	89 34 24             	mov    %esi,(%esp)
f01032b9:	e8 ac de ff ff       	call   f010116a <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01032be:	89 f8                	mov    %edi,%eax
f01032c0:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01032c6:	c1 f8 03             	sar    $0x3,%eax
f01032c9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032cc:	89 c2                	mov    %eax,%edx
f01032ce:	c1 ea 0c             	shr    $0xc,%edx
f01032d1:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f01032d7:	72 20                	jb     f01032f9 <mem_init+0x1d0d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032dd:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f01032e4:	f0 
f01032e5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01032ec:	00 
f01032ed:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f01032f4:	e8 47 cd ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01032f9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103300:	00 
f0103301:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103308:	00 
	return (void *)(pa + KERNBASE);
f0103309:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010330e:	89 04 24             	mov    %eax,(%esp)
f0103311:	e8 fb 2b 00 00       	call   f0105f11 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103316:	89 d8                	mov    %ebx,%eax
f0103318:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010331e:	c1 f8 03             	sar    $0x3,%eax
f0103321:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103324:	89 c2                	mov    %eax,%edx
f0103326:	c1 ea 0c             	shr    $0xc,%edx
f0103329:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f010332f:	72 20                	jb     f0103351 <mem_init+0x1d65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103331:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103335:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f010333c:	f0 
f010333d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103344:	00 
f0103345:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f010334c:	e8 ef cc ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103351:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103358:	00 
f0103359:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103360:	00 
	return (void *)(pa + KERNBASE);
f0103361:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103366:	89 04 24             	mov    %eax,(%esp)
f0103369:	e8 a3 2b 00 00       	call   f0105f11 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010336e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103375:	00 
f0103376:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010337d:	00 
f010337e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103382:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103387:	89 04 24             	mov    %eax,(%esp)
f010338a:	e8 40 e1 ff ff       	call   f01014cf <page_insert>
	assert(pp1->pp_ref == 1);
f010338f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103394:	74 24                	je     f01033ba <mem_init+0x1dce>
f0103396:	c7 44 24 0c bf 7d 10 	movl   $0xf0107dbf,0xc(%esp)
f010339d:	f0 
f010339e:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01033a5:	f0 
f01033a6:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f01033ad:	00 
f01033ae:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01033b5:	e8 86 cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01033ba:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01033c1:	01 01 01 
f01033c4:	74 24                	je     f01033ea <mem_init+0x1dfe>
f01033c6:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f01033cd:	f0 
f01033ce:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01033d5:	f0 
f01033d6:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f01033dd:	00 
f01033de:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01033e5:	e8 56 cc ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01033ea:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01033f1:	00 
f01033f2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01033f9:	00 
f01033fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033fe:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103403:	89 04 24             	mov    %eax,(%esp)
f0103406:	e8 c4 e0 ff ff       	call   f01014cf <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010340b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103412:	02 02 02 
f0103415:	74 24                	je     f010343b <mem_init+0x1e4f>
f0103417:	c7 44 24 0c e8 7a 10 	movl   $0xf0107ae8,0xc(%esp)
f010341e:	f0 
f010341f:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0103426:	f0 
f0103427:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f010342e:	00 
f010342f:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0103436:	e8 05 cc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010343b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103440:	74 24                	je     f0103466 <mem_init+0x1e7a>
f0103442:	c7 44 24 0c e1 7d 10 	movl   $0xf0107de1,0xc(%esp)
f0103449:	f0 
f010344a:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0103451:	f0 
f0103452:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0103459:	00 
f010345a:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0103461:	e8 da cb ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103466:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010346b:	74 24                	je     f0103491 <mem_init+0x1ea5>
f010346d:	c7 44 24 0c 2a 7e 10 	movl   $0xf0107e2a,0xc(%esp)
f0103474:	f0 
f0103475:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f010347c:	f0 
f010347d:	c7 44 24 04 63 04 00 	movl   $0x463,0x4(%esp)
f0103484:	00 
f0103485:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f010348c:	e8 af cb ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103491:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103498:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010349b:	89 d8                	mov    %ebx,%eax
f010349d:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01034a3:	c1 f8 03             	sar    $0x3,%eax
f01034a6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034a9:	89 c2                	mov    %eax,%edx
f01034ab:	c1 ea 0c             	shr    $0xc,%edx
f01034ae:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f01034b4:	72 20                	jb     f01034d6 <mem_init+0x1eea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034ba:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f01034c1:	f0 
f01034c2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01034c9:	00 
f01034ca:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f01034d1:	e8 6a cb ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01034d6:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01034dd:	03 03 03 
f01034e0:	74 24                	je     f0103506 <mem_init+0x1f1a>
f01034e2:	c7 44 24 0c 0c 7b 10 	movl   $0xf0107b0c,0xc(%esp)
f01034e9:	f0 
f01034ea:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01034f1:	f0 
f01034f2:	c7 44 24 04 65 04 00 	movl   $0x465,0x4(%esp)
f01034f9:	00 
f01034fa:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0103501:	e8 3a cb ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103506:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010350d:	00 
f010350e:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103513:	89 04 24             	mov    %eax,(%esp)
f0103516:	e8 64 df ff ff       	call   f010147f <page_remove>
	assert(pp2->pp_ref == 0);
f010351b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103520:	74 24                	je     f0103546 <mem_init+0x1f5a>
f0103522:	c7 44 24 0c 19 7e 10 	movl   $0xf0107e19,0xc(%esp)
f0103529:	f0 
f010352a:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0103531:	f0 
f0103532:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0103539:	00 
f010353a:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0103541:	e8 fa ca ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103546:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010354b:	8b 08                	mov    (%eax),%ecx
f010354d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103553:	89 f2                	mov    %esi,%edx
f0103555:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f010355b:	c1 fa 03             	sar    $0x3,%edx
f010355e:	c1 e2 0c             	shl    $0xc,%edx
f0103561:	39 d1                	cmp    %edx,%ecx
f0103563:	74 24                	je     f0103589 <mem_init+0x1f9d>
f0103565:	c7 44 24 0c cc 74 10 	movl   $0xf01074cc,0xc(%esp)
f010356c:	f0 
f010356d:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0103574:	f0 
f0103575:	c7 44 24 04 6a 04 00 	movl   $0x46a,0x4(%esp)
f010357c:	00 
f010357d:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f0103584:	e8 b7 ca ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103589:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010358f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103594:	74 24                	je     f01035ba <mem_init+0x1fce>
f0103596:	c7 44 24 0c d0 7d 10 	movl   $0xf0107dd0,0xc(%esp)
f010359d:	f0 
f010359e:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01035a5:	f0 
f01035a6:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f01035ad:	00 
f01035ae:	c7 04 24 99 7b 10 f0 	movl   $0xf0107b99,(%esp)
f01035b5:	e8 86 ca ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01035ba:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01035c0:	89 34 24             	mov    %esi,(%esp)
f01035c3:	e8 a2 db ff ff       	call   f010116a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01035c8:	c7 04 24 38 7b 10 f0 	movl   $0xf0107b38,(%esp)
f01035cf:	e8 02 0b 00 00       	call   f01040d6 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01035d4:	83 c4 3c             	add    $0x3c,%esp
f01035d7:	5b                   	pop    %ebx
f01035d8:	5e                   	pop    %esi
f01035d9:	5f                   	pop    %edi
f01035da:	5d                   	pop    %ebp
f01035db:	c3                   	ret    
	// LAB 4: Your code here:
	uintptr_t kstack_start = KSTACKTOP-KSTKSIZE;
	
	int i;
	for (i=0; i!= NCPU; i++){
		boot_map_region(kern_pgdir,kstack_start, KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_W);
f01035dc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01035e3:	00 
f01035e4:	c7 04 24 00 d0 22 00 	movl   $0x22d000,(%esp)
f01035eb:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01035f0:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01035f5:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01035fa:	e8 79 dd ff ff       	call   f0101378 <boot_map_region>
f01035ff:	bb 00 50 23 f0       	mov    $0xf0235000,%ebx
		kstack_start -= (KSTKSIZE+KSTKGAP);
f0103604:	be 00 80 fe ef       	mov    $0xeffe8000,%esi
f0103609:	e9 fd f7 ff ff       	jmp    f0102e0b <mem_init+0x181f>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010360e:	89 da                	mov    %ebx,%edx
f0103610:	89 f8                	mov    %edi,%eax
f0103612:	e8 7b d5 ff ff       	call   f0100b92 <check_va2pa>
f0103617:	e9 2b fa ff ff       	jmp    f0103047 <mem_init+0x1a5b>

f010361c <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010361c:	55                   	push   %ebp
f010361d:	89 e5                	mov    %esp,%ebp
f010361f:	57                   	push   %edi
f0103620:	56                   	push   %esi
f0103621:	53                   	push   %ebx
f0103622:	83 ec 2c             	sub    $0x2c,%esp
f0103625:	8b 75 08             	mov    0x8(%ebp),%esi
f0103628:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
	void * va_end = (void*)ROUNDUP(va+len,PGSIZE);
f010362b:	89 d8                	mov    %ebx,%eax
f010362d:	03 45 10             	add    0x10(%ebp),%eax
f0103630:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103635:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010363a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if(!pte || ( (*pte & (perm | PTE_P)) != (perm|PTE_P))){
			user_mem_check_addr = (uintptr_t)va;
			return - E_FAULT;
		}
	}
	return 0;
f010363d:	b8 00 00 00 00       	mov    $0x0,%eax
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	void * va_end = (void*)ROUNDUP(va+len,PGSIZE);
	pte_t * pte;
	for(; va < va_end; va = ROUNDUP(va+PGSIZE,PGSIZE)){
f0103642:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103645:	73 4c                	jae    f0103693 <user_mem_check+0x77>
		pte = pgdir_walk(env->env_pgdir,va,0);
		if(!pte || ( (*pte & (perm | PTE_P)) != (perm|PTE_P))){
f0103647:	8b 7d 14             	mov    0x14(%ebp),%edi
f010364a:	83 cf 01             	or     $0x1,%edi
{
	// LAB 3: Your code here.
	void * va_end = (void*)ROUNDUP(va+len,PGSIZE);
	pte_t * pte;
	for(; va < va_end; va = ROUNDUP(va+PGSIZE,PGSIZE)){
		pte = pgdir_walk(env->env_pgdir,va,0);
f010364d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103654:	00 
f0103655:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103659:	8b 46 60             	mov    0x60(%esi),%eax
f010365c:	89 04 24             	mov    %eax,(%esp)
f010365f:	e8 6c db ff ff       	call   f01011d0 <pgdir_walk>
		if(!pte || ( (*pte & (perm | PTE_P)) != (perm|PTE_P))){
f0103664:	85 c0                	test   %eax,%eax
f0103666:	74 08                	je     f0103670 <user_mem_check+0x54>
f0103668:	8b 00                	mov    (%eax),%eax
f010366a:	21 f8                	and    %edi,%eax
f010366c:	39 c7                	cmp    %eax,%edi
f010366e:	74 0d                	je     f010367d <user_mem_check+0x61>
			user_mem_check_addr = (uintptr_t)va;
f0103670:	89 1d 44 b2 22 f0    	mov    %ebx,0xf022b244
			return - E_FAULT;
f0103676:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010367b:	eb 16                	jmp    f0103693 <user_mem_check+0x77>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	void * va_end = (void*)ROUNDUP(va+len,PGSIZE);
	pte_t * pte;
	for(; va < va_end; va = ROUNDUP(va+PGSIZE,PGSIZE)){
f010367d:	81 c3 ff 1f 00 00    	add    $0x1fff,%ebx
f0103683:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103689:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f010368c:	77 bf                	ja     f010364d <user_mem_check+0x31>
		if(!pte || ( (*pte & (perm | PTE_P)) != (perm|PTE_P))){
			user_mem_check_addr = (uintptr_t)va;
			return - E_FAULT;
		}
	}
	return 0;
f010368e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103693:	83 c4 2c             	add    $0x2c,%esp
f0103696:	5b                   	pop    %ebx
f0103697:	5e                   	pop    %esi
f0103698:	5f                   	pop    %edi
f0103699:	5d                   	pop    %ebp
f010369a:	c3                   	ret    

f010369b <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010369b:	55                   	push   %ebp
f010369c:	89 e5                	mov    %esp,%ebp
f010369e:	53                   	push   %ebx
f010369f:	83 ec 14             	sub    $0x14,%esp
f01036a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01036a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01036a8:	83 c8 04             	or     $0x4,%eax
f01036ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036af:	8b 45 10             	mov    0x10(%ebp),%eax
f01036b2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01036b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036bd:	89 1c 24             	mov    %ebx,(%esp)
f01036c0:	e8 57 ff ff ff       	call   f010361c <user_mem_check>
f01036c5:	85 c0                	test   %eax,%eax
f01036c7:	79 24                	jns    f01036ed <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f01036c9:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f01036ce:	89 44 24 08          	mov    %eax,0x8(%esp)
f01036d2:	8b 43 48             	mov    0x48(%ebx),%eax
f01036d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036d9:	c7 04 24 64 7b 10 f0 	movl   $0xf0107b64,(%esp)
f01036e0:	e8 f1 09 00 00       	call   f01040d6 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01036e5:	89 1c 24             	mov    %ebx,(%esp)
f01036e8:	e8 02 07 00 00       	call   f0103def <env_destroy>
	}
}
f01036ed:	83 c4 14             	add    $0x14,%esp
f01036f0:	5b                   	pop    %ebx
f01036f1:	5d                   	pop    %ebp
f01036f2:	c3                   	ret    
	...

f01036f4 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01036f4:	55                   	push   %ebp
f01036f5:	89 e5                	mov    %esp,%ebp
f01036f7:	57                   	push   %edi
f01036f8:	56                   	push   %esi
f01036f9:	53                   	push   %ebx
f01036fa:	83 ec 1c             	sub    $0x1c,%esp
f01036fd:	89 c6                	mov    %eax,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t low = ROUNDDOWN((uintptr_t)va,PGSIZE);
	uintptr_t high = ROUNDUP((uintptr_t)va+len,PGSIZE);
f01036ff:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0103706:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t low = ROUNDDOWN((uintptr_t)va,PGSIZE);
f010370c:	89 d3                	mov    %edx,%ebx
f010370e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t high = ROUNDUP((uintptr_t)va+len,PGSIZE);
	int i;
	struct PageInfo *pp;
	for( i = low; i < high; i+= PGSIZE){
f0103714:	39 df                	cmp    %ebx,%edi
f0103716:	76 51                	jbe    f0103769 <region_alloc+0x75>
		pp = page_alloc(0);
f0103718:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010371f:	e8 c8 d9 ff ff       	call   f01010ec <page_alloc>
		if(!pp)
f0103724:	85 c0                	test   %eax,%eax
f0103726:	75 1c                	jne    f0103744 <region_alloc+0x50>
			panic("region_alloc: page_alloc was out of memory!\n");
f0103728:	c7 44 24 08 c8 7e 10 	movl   $0xf0107ec8,0x8(%esp)
f010372f:	f0 
f0103730:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f0103737:	00 
f0103738:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f010373f:	e8 fc c8 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir,pp,(void *)i,PTE_U|PTE_W);
f0103744:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010374b:	00 
f010374c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103750:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103754:	8b 46 60             	mov    0x60(%esi),%eax
f0103757:	89 04 24             	mov    %eax,(%esp)
f010375a:	e8 70 dd ff ff       	call   f01014cf <page_insert>
	//   (Watch out for corner-cases!)
	uintptr_t low = ROUNDDOWN((uintptr_t)va,PGSIZE);
	uintptr_t high = ROUNDUP((uintptr_t)va+len,PGSIZE);
	int i;
	struct PageInfo *pp;
	for( i = low; i < high; i+= PGSIZE){
f010375f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103765:	39 df                	cmp    %ebx,%edi
f0103767:	77 af                	ja     f0103718 <region_alloc+0x24>
			panic("region_alloc: page_alloc was out of memory!\n");
		page_insert(e->env_pgdir,pp,(void *)i,PTE_U|PTE_W);
	
	}
		
}
f0103769:	83 c4 1c             	add    $0x1c,%esp
f010376c:	5b                   	pop    %ebx
f010376d:	5e                   	pop    %esi
f010376e:	5f                   	pop    %edi
f010376f:	5d                   	pop    %ebp
f0103770:	c3                   	ret    

f0103771 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103771:	55                   	push   %ebp
f0103772:	89 e5                	mov    %esp,%ebp
f0103774:	83 ec 18             	sub    $0x18,%esp
f0103777:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010377a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010377d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103780:	8b 45 08             	mov    0x8(%ebp),%eax
f0103783:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103786:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010378a:	85 c0                	test   %eax,%eax
f010378c:	75 17                	jne    f01037a5 <envid2env+0x34>
		*env_store = curenv;
f010378e:	e8 0d 2e 00 00       	call   f01065a0 <cpunum>
f0103793:	6b c0 74             	imul   $0x74,%eax,%eax
f0103796:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010379c:	89 06                	mov    %eax,(%esi)
		return 0;
f010379e:	b8 00 00 00 00       	mov    $0x0,%eax
f01037a3:	eb 67                	jmp    f010380c <envid2env+0x9b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01037a5:	89 c3                	mov    %eax,%ebx
f01037a7:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01037ad:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01037b0:	03 1d 48 b2 22 f0    	add    0xf022b248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01037b6:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01037ba:	74 05                	je     f01037c1 <envid2env+0x50>
f01037bc:	39 43 48             	cmp    %eax,0x48(%ebx)
f01037bf:	74 0d                	je     f01037ce <envid2env+0x5d>
		*env_store = 0;
f01037c1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01037c7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01037cc:	eb 3e                	jmp    f010380c <envid2env+0x9b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01037ce:	84 d2                	test   %dl,%dl
f01037d0:	74 33                	je     f0103805 <envid2env+0x94>
f01037d2:	e8 c9 2d 00 00       	call   f01065a0 <cpunum>
f01037d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01037da:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f01037e0:	74 23                	je     f0103805 <envid2env+0x94>
f01037e2:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01037e5:	e8 b6 2d 00 00       	call   f01065a0 <cpunum>
f01037ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01037ed:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01037f3:	3b 78 48             	cmp    0x48(%eax),%edi
f01037f6:	74 0d                	je     f0103805 <envid2env+0x94>
		*env_store = 0;
f01037f8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01037fe:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103803:	eb 07                	jmp    f010380c <envid2env+0x9b>
	}

	*env_store = e;
f0103805:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0103807:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010380c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010380f:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103812:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103815:	89 ec                	mov    %ebp,%esp
f0103817:	5d                   	pop    %ebp
f0103818:	c3                   	ret    

f0103819 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103819:	55                   	push   %ebp
f010381a:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010381c:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103821:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103824:	b8 23 00 00 00       	mov    $0x23,%eax
f0103829:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010382b:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010382d:	b0 10                	mov    $0x10,%al
f010382f:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103831:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103833:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103835:	ea 3c 38 10 f0 08 00 	ljmp   $0x8,$0xf010383c
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f010383c:	b0 00                	mov    $0x0,%al
f010383e:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103841:	5d                   	pop    %ebp
f0103842:	c3                   	ret    

f0103843 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103843:	55                   	push   %ebp
f0103844:	89 e5                	mov    %esp,%ebp
f0103846:	83 ec 18             	sub    $0x18,%esp
	// Set up envs array
	// LAB 3: Your code here.
	memset( (void*)envs, 0, sizeof(struct Env)* NENV);
f0103849:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f0103850:	00 
f0103851:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103858:	00 
f0103859:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
f010385e:	89 04 24             	mov    %eax,(%esp)
f0103861:	e8 ab 26 00 00       	call   f0105f11 <memset>
	int i;
	env_free_list = envs;
f0103866:	8b 0d 48 b2 22 f0    	mov    0xf022b248,%ecx
f010386c:	89 0d 4c b2 22 f0    	mov    %ecx,0xf022b24c
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103872:	8d 41 7c             	lea    0x7c(%ecx),%eax
f0103875:	ba ff 03 00 00       	mov    $0x3ff,%edx
	// LAB 3: Your code here.
	memset( (void*)envs, 0, sizeof(struct Env)* NENV);
	int i;
	env_free_list = envs;
	for(i = 0; i < NENV -1; i++){
		envs[i].env_link = &envs[i+1];
f010387a:	89 40 c8             	mov    %eax,-0x38(%eax)
	//	envs[i].env_id = 0;
		envs[i].env_status = ENV_FREE;
f010387d:	c7 40 d8 00 00 00 00 	movl   $0x0,-0x28(%eax)
f0103884:	83 c0 7c             	add    $0x7c,%eax
	// Set up envs array
	// LAB 3: Your code here.
	memset( (void*)envs, 0, sizeof(struct Env)* NENV);
	int i;
	env_free_list = envs;
	for(i = 0; i < NENV -1; i++){
f0103887:	83 ea 01             	sub    $0x1,%edx
f010388a:	75 ee                	jne    f010387a <env_init+0x37>
		envs[i].env_link = &envs[i+1];
	//	envs[i].env_id = 0;
		envs[i].env_status = ENV_FREE;
		//envs[i].env_runs = 0;
	}
	envs[i].env_link = NULL;
f010388c:	c7 81 c8 ef 01 00 00 	movl   $0x0,0x1efc8(%ecx)
f0103893:	00 00 00 
	//envs[i].env_id = 0;
	envs[i].env_status = ENV_FREE;
f0103896:	c7 81 d8 ef 01 00 00 	movl   $0x0,0x1efd8(%ecx)
f010389d:	00 00 00 
	//envs[i].env_runs = 0;
	// Per-CPU part of the initialization
	env_init_percpu();
f01038a0:	e8 74 ff ff ff       	call   f0103819 <env_init_percpu>
}
f01038a5:	c9                   	leave  
f01038a6:	c3                   	ret    

f01038a7 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01038a7:	55                   	push   %ebp
f01038a8:	89 e5                	mov    %esp,%ebp
f01038aa:	53                   	push   %ebx
f01038ab:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01038ae:	8b 1d 4c b2 22 f0    	mov    0xf022b24c,%ebx
f01038b4:	85 db                	test   %ebx,%ebx
f01038b6:	0f 84 8e 01 00 00    	je     f0103a4a <env_alloc+0x1a3>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01038bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01038c3:	e8 24 d8 ff ff       	call   f01010ec <page_alloc>
f01038c8:	85 c0                	test   %eax,%eax
f01038ca:	0f 84 81 01 00 00    	je     f0103a51 <env_alloc+0x1aa>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f01038d0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01038d5:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01038db:	c1 f8 03             	sar    $0x3,%eax
f01038de:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038e1:	89 c2                	mov    %eax,%edx
f01038e3:	c1 ea 0c             	shr    $0xc,%edx
f01038e6:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f01038ec:	72 20                	jb     f010390e <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01038ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038f2:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f01038f9:	f0 
f01038fa:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103901:	00 
f0103902:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f0103909:	e8 32 c7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010390e:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);
f0103913:	89 43 60             	mov    %eax,0x60(%ebx)
	memmove(e->env_pgdir,kern_pgdir,PGSIZE);
f0103916:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010391d:	00 
f010391e:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f0103924:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103928:	89 04 24             	mov    %eax,(%esp)
f010392b:	e8 3c 26 00 00       	call   f0105f6c <memmove>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103930:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103933:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103938:	77 20                	ja     f010395a <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010393a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010393e:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0103945:	f0 
f0103946:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f010394d:	00 
f010394e:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0103955:	e8 e6 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010395a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103960:	83 ca 05             	or     $0x5,%edx
f0103963:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103969:	8b 43 48             	mov    0x48(%ebx),%eax
f010396c:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103971:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103976:	ba 00 10 00 00       	mov    $0x1000,%edx
f010397b:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010397e:	89 da                	mov    %ebx,%edx
f0103980:	2b 15 48 b2 22 f0    	sub    0xf022b248,%edx
f0103986:	c1 fa 02             	sar    $0x2,%edx
f0103989:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010398f:	09 d0                	or     %edx,%eax
f0103991:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103994:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103997:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010399a:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01039a1:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01039a8:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01039af:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01039b6:	00 
f01039b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039be:	00 
f01039bf:	89 1c 24             	mov    %ebx,(%esp)
f01039c2:	e8 4a 25 00 00       	call   f0105f11 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01039c7:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01039cd:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01039d3:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01039d9:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01039e0:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF; // To enable interrupts
f01039e6:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01039ed:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01039f4:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01039f8:	8b 43 44             	mov    0x44(%ebx),%eax
f01039fb:	a3 4c b2 22 f0       	mov    %eax,0xf022b24c
	*newenv_store = e;
f0103a00:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a03:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103a05:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103a08:	e8 93 2b 00 00       	call   f01065a0 <cpunum>
f0103a0d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a10:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a15:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103a1c:	74 11                	je     f0103a2f <env_alloc+0x188>
f0103a1e:	e8 7d 2b 00 00       	call   f01065a0 <cpunum>
f0103a23:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a26:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103a2c:	8b 50 48             	mov    0x48(%eax),%edx
f0103a2f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103a33:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103a37:	c7 04 24 28 7f 10 f0 	movl   $0xf0107f28,(%esp)
f0103a3e:	e8 93 06 00 00       	call   f01040d6 <cprintf>
	return 0;
f0103a43:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a48:	eb 0c                	jmp    f0103a56 <env_alloc+0x1af>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103a4a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103a4f:	eb 05                	jmp    f0103a56 <env_alloc+0x1af>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103a51:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103a56:	83 c4 14             	add    $0x14,%esp
f0103a59:	5b                   	pop    %ebx
f0103a5a:	5d                   	pop    %ebp
f0103a5b:	c3                   	ret    

f0103a5c <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103a5c:	55                   	push   %ebp
f0103a5d:	89 e5                	mov    %esp,%ebp
f0103a5f:	57                   	push   %edi
f0103a60:	56                   	push   %esi
f0103a61:	53                   	push   %ebx
f0103a62:	83 ec 3c             	sub    $0x3c,%esp
f0103a65:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.i
	struct Env * e;
	int pass = env_alloc(&e,0);
f0103a68:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a6f:	00 
f0103a70:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103a73:	89 04 24             	mov    %eax,(%esp)
f0103a76:	e8 2c fe ff ff       	call   f01038a7 <env_alloc>
	if(pass < 0){
f0103a7b:	85 c0                	test   %eax,%eax
f0103a7d:	79 20                	jns    f0103a9f <env_create+0x43>
		panic("env_alloc: %e",pass);
f0103a7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a83:	c7 44 24 08 3d 7f 10 	movl   $0xf0107f3d,0x8(%esp)
f0103a8a:	f0 
f0103a8b:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
f0103a92:	00 
f0103a93:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0103a9a:	e8 a1 c5 ff ff       	call   f0100040 <_panic>
	}
	load_icode(e,binary,size);
f0103a9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103aa2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	
	struct Elf* headr = (struct Elf*)binary;
	if( headr->e_magic != ELF_MAGIC){
f0103aa5:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103aab:	74 1c                	je     f0103ac9 <env_create+0x6d>
		panic("Not in correct ELF format!");
f0103aad:	c7 44 24 08 4b 7f 10 	movl   $0xf0107f4b,0x8(%esp)
f0103ab4:	f0 
f0103ab5:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
f0103abc:	00 
f0103abd:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0103ac4:	e8 77 c5 ff ff       	call   f0100040 <_panic>
	}
	struct Proghdr *ph, *eph;
	ph = (struct Proghdr*)((uint8_t *) headr + headr->e_phoff);
f0103ac9:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph = ph + headr->e_phnum;
f0103acc:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
	lcr3(PADDR(e->env_pgdir));
f0103ad0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103ad3:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ad6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103adb:	77 20                	ja     f0103afd <env_create+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103add:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ae1:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0103ae8:	f0 
f0103ae9:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f0103af0:	00 
f0103af1:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0103af8:	e8 43 c5 ff ff       	call   f0100040 <_panic>
	struct Elf* headr = (struct Elf*)binary;
	if( headr->e_magic != ELF_MAGIC){
		panic("Not in correct ELF format!");
	}
	struct Proghdr *ph, *eph;
	ph = (struct Proghdr*)((uint8_t *) headr + headr->e_phoff);
f0103afd:	01 fb                	add    %edi,%ebx
	eph = ph + headr->e_phnum;
f0103aff:	0f b7 f6             	movzwl %si,%esi
f0103b02:	c1 e6 05             	shl    $0x5,%esi
f0103b05:	01 de                	add    %ebx,%esi
	return (physaddr_t)kva - KERNBASE;
f0103b07:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103b0c:	0f 22 d8             	mov    %eax,%cr3
	lcr3(PADDR(e->env_pgdir));
	for(; ph < eph; ph++){
f0103b0f:	39 f3                	cmp    %esi,%ebx
f0103b11:	73 75                	jae    f0103b88 <env_create+0x12c>
		if(ph->p_type == ELF_PROG_LOAD){
f0103b13:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103b16:	75 69                	jne    f0103b81 <env_create+0x125>
			if(ph->p_filesz > ph->p_memsz){
f0103b18:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103b1b:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103b1e:	76 1c                	jbe    f0103b3c <env_create+0xe0>
				panic("Memory size smaller than file size!\n");
f0103b20:	c7 44 24 08 f8 7e 10 	movl   $0xf0107ef8,0x8(%esp)
f0103b27:	f0 
f0103b28:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f0103b2f:	00 
f0103b30:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0103b37:	e8 04 c5 ff ff       	call   f0100040 <_panic>
			}
			region_alloc(e,(void*)ph->p_va, ph->p_memsz);
f0103b3c:	8b 53 08             	mov    0x8(%ebx),%edx
f0103b3f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103b42:	e8 ad fb ff ff       	call   f01036f4 <region_alloc>
			memmove((void*)ph->p_va,binary+ph->p_offset, ph->p_filesz);
f0103b47:	8b 43 10             	mov    0x10(%ebx),%eax
f0103b4a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103b4e:	89 f8                	mov    %edi,%eax
f0103b50:	03 43 04             	add    0x4(%ebx),%eax
f0103b53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b57:	8b 43 08             	mov    0x8(%ebx),%eax
f0103b5a:	89 04 24             	mov    %eax,(%esp)
f0103b5d:	e8 0a 24 00 00       	call   f0105f6c <memmove>
			memset((void*)(ph->p_va+ph->p_filesz),0,ph->p_memsz - ph->p_filesz);
f0103b62:	8b 43 10             	mov    0x10(%ebx),%eax
f0103b65:	8b 53 14             	mov    0x14(%ebx),%edx
f0103b68:	29 c2                	sub    %eax,%edx
f0103b6a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103b6e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103b75:	00 
f0103b76:	03 43 08             	add    0x8(%ebx),%eax
f0103b79:	89 04 24             	mov    %eax,(%esp)
f0103b7c:	e8 90 23 00 00       	call   f0105f11 <memset>
	}
	struct Proghdr *ph, *eph;
	ph = (struct Proghdr*)((uint8_t *) headr + headr->e_phoff);
	eph = ph + headr->e_phnum;
	lcr3(PADDR(e->env_pgdir));
	for(; ph < eph; ph++){
f0103b81:	83 c3 20             	add    $0x20,%ebx
f0103b84:	39 de                	cmp    %ebx,%esi
f0103b86:	77 8b                	ja     f0103b13 <env_create+0xb7>
			memset((void*)(ph->p_va+ph->p_filesz),0,ph->p_memsz - ph->p_filesz);
		}
	}

	/// entry point
	e->env_tf.tf_eip = headr->e_entry;
f0103b88:	8b 47 18             	mov    0x18(%edi),%eax
f0103b8b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103b8e:	89 42 30             	mov    %eax,0x30(%edx)
	
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	
	// LAB 3: Your code here.
	region_alloc(e,(void*)USTACKTOP-PGSIZE,PGSIZE);
f0103b91:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103b96:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103b9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103b9e:	e8 51 fb ff ff       	call   f01036f4 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f0103ba3:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ba8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bad:	77 20                	ja     f0103bcf <env_create+0x173>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103baf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bb3:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0103bba:	f0 
f0103bbb:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
f0103bc2:	00 
f0103bc3:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0103bca:	e8 71 c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103bcf:	05 00 00 00 10       	add    $0x10000000,%eax
f0103bd4:	0f 22 d8             	mov    %eax,%cr3
	int pass = env_alloc(&e,0);
	if(pass < 0){
		panic("env_alloc: %e",pass);
	}
	load_icode(e,binary,size);
	e->env_type = type;
f0103bd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103bda:	8b 55 10             	mov    0x10(%ebp),%edx
f0103bdd:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103be0:	83 c4 3c             	add    $0x3c,%esp
f0103be3:	5b                   	pop    %ebx
f0103be4:	5e                   	pop    %esi
f0103be5:	5f                   	pop    %edi
f0103be6:	5d                   	pop    %ebp
f0103be7:	c3                   	ret    

f0103be8 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103be8:	55                   	push   %ebp
f0103be9:	89 e5                	mov    %esp,%ebp
f0103beb:	57                   	push   %edi
f0103bec:	56                   	push   %esi
f0103bed:	53                   	push   %ebx
f0103bee:	83 ec 2c             	sub    $0x2c,%esp
f0103bf1:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103bf4:	e8 a7 29 00 00       	call   f01065a0 <cpunum>
f0103bf9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bfc:	39 b8 28 c0 22 f0    	cmp    %edi,-0xfdd3fd8(%eax)
f0103c02:	75 34                	jne    f0103c38 <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103c04:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c09:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c0e:	77 20                	ja     f0103c30 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c10:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c14:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0103c1b:	f0 
f0103c1c:	c7 44 24 04 b0 01 00 	movl   $0x1b0,0x4(%esp)
f0103c23:	00 
f0103c24:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0103c2b:	e8 10 c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103c30:	05 00 00 00 10       	add    $0x10000000,%eax
f0103c35:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103c38:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103c3b:	e8 60 29 00 00       	call   f01065a0 <cpunum>
f0103c40:	6b d0 74             	imul   $0x74,%eax,%edx
f0103c43:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c48:	83 ba 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%edx)
f0103c4f:	74 11                	je     f0103c62 <env_free+0x7a>
f0103c51:	e8 4a 29 00 00       	call   f01065a0 <cpunum>
f0103c56:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c59:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103c5f:	8b 40 48             	mov    0x48(%eax),%eax
f0103c62:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103c66:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c6a:	c7 04 24 66 7f 10 f0 	movl   $0xf0107f66,(%esp)
f0103c71:	e8 60 04 00 00       	call   f01040d6 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103c76:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103c7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c80:	c1 e0 02             	shl    $0x2,%eax
f0103c83:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103c86:	8b 47 60             	mov    0x60(%edi),%eax
f0103c89:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103c8c:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103c8f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103c95:	0f 84 b8 00 00 00    	je     f0103d53 <env_free+0x16b>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103c9b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103ca1:	89 f0                	mov    %esi,%eax
f0103ca3:	c1 e8 0c             	shr    $0xc,%eax
f0103ca6:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103ca9:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103caf:	72 20                	jb     f0103cd1 <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103cb1:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103cb5:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0103cbc:	f0 
f0103cbd:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
f0103cc4:	00 
f0103cc5:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0103ccc:	e8 6f c3 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103cd1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103cd4:	c1 e2 16             	shl    $0x16,%edx
f0103cd7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103cda:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103cdf:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103ce6:	01 
f0103ce7:	74 17                	je     f0103d00 <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103ce9:	89 d8                	mov    %ebx,%eax
f0103ceb:	c1 e0 0c             	shl    $0xc,%eax
f0103cee:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cf5:	8b 47 60             	mov    0x60(%edi),%eax
f0103cf8:	89 04 24             	mov    %eax,(%esp)
f0103cfb:	e8 7f d7 ff ff       	call   f010147f <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103d00:	83 c3 01             	add    $0x1,%ebx
f0103d03:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103d09:	75 d4                	jne    f0103cdf <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103d0b:	8b 47 60             	mov    0x60(%edi),%eax
f0103d0e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103d11:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103d18:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103d1b:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103d21:	72 1c                	jb     f0103d3f <env_free+0x157>
		panic("pa2page called with invalid pa");
f0103d23:	c7 44 24 08 68 73 10 	movl   $0xf0107368,0x8(%esp)
f0103d2a:	f0 
f0103d2b:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103d32:	00 
f0103d33:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f0103d3a:	e8 01 c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103d3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103d42:	c1 e0 03             	shl    $0x3,%eax
f0103d45:	03 05 90 be 22 f0    	add    0xf022be90,%eax
		page_decref(pa2page(pa));
f0103d4b:	89 04 24             	mov    %eax,(%esp)
f0103d4e:	e8 5a d4 ff ff       	call   f01011ad <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103d53:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103d57:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103d5e:	0f 85 19 ff ff ff    	jne    f0103c7d <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103d64:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d67:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d6c:	77 20                	ja     f0103d8e <env_free+0x1a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d72:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0103d79:	f0 
f0103d7a:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
f0103d81:	00 
f0103d82:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0103d89:	e8 b2 c2 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103d8e:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103d95:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103d9a:	c1 e8 0c             	shr    $0xc,%eax
f0103d9d:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103da3:	72 1c                	jb     f0103dc1 <env_free+0x1d9>
		panic("pa2page called with invalid pa");
f0103da5:	c7 44 24 08 68 73 10 	movl   $0xf0107368,0x8(%esp)
f0103dac:	f0 
f0103dad:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103db4:	00 
f0103db5:	c7 04 24 a5 7b 10 f0 	movl   $0xf0107ba5,(%esp)
f0103dbc:	e8 7f c2 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103dc1:	c1 e0 03             	shl    $0x3,%eax
f0103dc4:	03 05 90 be 22 f0    	add    0xf022be90,%eax
	page_decref(pa2page(pa));
f0103dca:	89 04 24             	mov    %eax,(%esp)
f0103dcd:	e8 db d3 ff ff       	call   f01011ad <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103dd2:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103dd9:	a1 4c b2 22 f0       	mov    0xf022b24c,%eax
f0103dde:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103de1:	89 3d 4c b2 22 f0    	mov    %edi,0xf022b24c
}
f0103de7:	83 c4 2c             	add    $0x2c,%esp
f0103dea:	5b                   	pop    %ebx
f0103deb:	5e                   	pop    %esi
f0103dec:	5f                   	pop    %edi
f0103ded:	5d                   	pop    %ebp
f0103dee:	c3                   	ret    

f0103def <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103def:	55                   	push   %ebp
f0103df0:	89 e5                	mov    %esp,%ebp
f0103df2:	53                   	push   %ebx
f0103df3:	83 ec 14             	sub    $0x14,%esp
f0103df6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103df9:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103dfd:	75 19                	jne    f0103e18 <env_destroy+0x29>
f0103dff:	e8 9c 27 00 00       	call   f01065a0 <cpunum>
f0103e04:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e07:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0103e0d:	74 09                	je     f0103e18 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103e0f:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103e16:	eb 2f                	jmp    f0103e47 <env_destroy+0x58>
	}

	env_free(e);
f0103e18:	89 1c 24             	mov    %ebx,(%esp)
f0103e1b:	e8 c8 fd ff ff       	call   f0103be8 <env_free>

	if (curenv == e) {
f0103e20:	e8 7b 27 00 00       	call   f01065a0 <cpunum>
f0103e25:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e28:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0103e2e:	75 17                	jne    f0103e47 <env_destroy+0x58>
		curenv = NULL;
f0103e30:	e8 6b 27 00 00       	call   f01065a0 <cpunum>
f0103e35:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e38:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0103e3f:	00 00 00 
		sched_yield();
f0103e42:	e8 31 0d 00 00       	call   f0104b78 <sched_yield>
	}
}
f0103e47:	83 c4 14             	add    $0x14,%esp
f0103e4a:	5b                   	pop    %ebx
f0103e4b:	5d                   	pop    %ebp
f0103e4c:	c3                   	ret    

f0103e4d <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103e4d:	55                   	push   %ebp
f0103e4e:	89 e5                	mov    %esp,%ebp
f0103e50:	53                   	push   %ebx
f0103e51:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103e54:	e8 47 27 00 00       	call   f01065a0 <cpunum>
f0103e59:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e5c:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0103e62:	e8 39 27 00 00       	call   f01065a0 <cpunum>
f0103e67:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103e6a:	8b 65 08             	mov    0x8(%ebp),%esp
f0103e6d:	61                   	popa   
f0103e6e:	07                   	pop    %es
f0103e6f:	1f                   	pop    %ds
f0103e70:	83 c4 08             	add    $0x8,%esp
f0103e73:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103e74:	c7 44 24 08 7c 7f 10 	movl   $0xf0107f7c,0x8(%esp)
f0103e7b:	f0 
f0103e7c:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
f0103e83:	00 
f0103e84:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0103e8b:	e8 b0 c1 ff ff       	call   f0100040 <_panic>

f0103e90 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103e90:	55                   	push   %ebp
f0103e91:	89 e5                	mov    %esp,%ebp
f0103e93:	83 ec 18             	sub    $0x18,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if( curenv && curenv->env_status == ENV_RUNNING){
f0103e96:	e8 05 27 00 00       	call   f01065a0 <cpunum>
f0103e9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e9e:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103ea5:	74 29                	je     f0103ed0 <env_run+0x40>
f0103ea7:	e8 f4 26 00 00       	call   f01065a0 <cpunum>
f0103eac:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eaf:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103eb5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103eb9:	75 15                	jne    f0103ed0 <env_run+0x40>
		curenv->env_status = ENV_RUNNABLE;
f0103ebb:	e8 e0 26 00 00       	call   f01065a0 <cpunum>
f0103ec0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ec3:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103ec9:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv = e;
f0103ed0:	e8 cb 26 00 00       	call   f01065a0 <cpunum>
f0103ed5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ed8:	8b 55 08             	mov    0x8(%ebp),%edx
f0103edb:	89 90 28 c0 22 f0    	mov    %edx,-0xfdd3fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103ee1:	e8 ba 26 00 00       	call   f01065a0 <cpunum>
f0103ee6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ee9:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103eef:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs ++;
f0103ef6:	e8 a5 26 00 00       	call   f01065a0 <cpunum>
f0103efb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103efe:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103f04:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103f08:	e8 93 26 00 00       	call   f01065a0 <cpunum>
f0103f0d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f10:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103f16:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f19:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f1e:	77 20                	ja     f0103f40 <env_run+0xb0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f20:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f24:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0103f2b:	f0 
f0103f2c:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
f0103f33:	00 
f0103f34:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0103f3b:	e8 00 c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103f40:	05 00 00 00 10       	add    $0x10000000,%eax
f0103f45:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103f48:	c7 04 24 a0 24 12 f0 	movl   $0xf01224a0,(%esp)
f0103f4f:	e8 bf 29 00 00       	call   f0106913 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103f54:	f3 90                	pause  
	
	unlock_kernel();
	
	env_pop_tf(&(curenv->env_tf));	
f0103f56:	e8 45 26 00 00       	call   f01065a0 <cpunum>
f0103f5b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f5e:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103f64:	89 04 24             	mov    %eax,(%esp)
f0103f67:	e8 e1 fe ff ff       	call   f0103e4d <env_pop_tf>

f0103f6c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103f6c:	55                   	push   %ebp
f0103f6d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103f6f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103f74:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f77:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103f78:	b2 71                	mov    $0x71,%dl
f0103f7a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103f7b:	0f b6 c0             	movzbl %al,%eax
}
f0103f7e:	5d                   	pop    %ebp
f0103f7f:	c3                   	ret    

f0103f80 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103f80:	55                   	push   %ebp
f0103f81:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103f83:	ba 70 00 00 00       	mov    $0x70,%edx
f0103f88:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f8b:	ee                   	out    %al,(%dx)
f0103f8c:	b2 71                	mov    $0x71,%dl
f0103f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f91:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103f92:	5d                   	pop    %ebp
f0103f93:	c3                   	ret    

f0103f94 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103f94:	55                   	push   %ebp
f0103f95:	89 e5                	mov    %esp,%ebp
f0103f97:	56                   	push   %esi
f0103f98:	53                   	push   %ebx
f0103f99:	83 ec 10             	sub    $0x10,%esp
f0103f9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f9f:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103fa1:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103fa7:	80 3d 50 b2 22 f0 00 	cmpb   $0x0,0xf022b250
f0103fae:	74 4e                	je     f0103ffe <irq_setmask_8259A+0x6a>
f0103fb0:	ba 21 00 00 00       	mov    $0x21,%edx
f0103fb5:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103fb6:	89 f0                	mov    %esi,%eax
f0103fb8:	66 c1 e8 08          	shr    $0x8,%ax
f0103fbc:	b2 a1                	mov    $0xa1,%dl
f0103fbe:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103fbf:	c7 04 24 88 7f 10 f0 	movl   $0xf0107f88,(%esp)
f0103fc6:	e8 0b 01 00 00       	call   f01040d6 <cprintf>
	for (i = 0; i < 16; i++)
f0103fcb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103fd0:	0f b7 f6             	movzwl %si,%esi
f0103fd3:	f7 d6                	not    %esi
f0103fd5:	0f a3 de             	bt     %ebx,%esi
f0103fd8:	73 10                	jae    f0103fea <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0103fda:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fde:	c7 04 24 8f 84 10 f0 	movl   $0xf010848f,(%esp)
f0103fe5:	e8 ec 00 00 00       	call   f01040d6 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103fea:	83 c3 01             	add    $0x1,%ebx
f0103fed:	83 fb 10             	cmp    $0x10,%ebx
f0103ff0:	75 e3                	jne    f0103fd5 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103ff2:	c7 04 24 93 7e 10 f0 	movl   $0xf0107e93,(%esp)
f0103ff9:	e8 d8 00 00 00       	call   f01040d6 <cprintf>
}
f0103ffe:	83 c4 10             	add    $0x10,%esp
f0104001:	5b                   	pop    %ebx
f0104002:	5e                   	pop    %esi
f0104003:	5d                   	pop    %ebp
f0104004:	c3                   	ret    

f0104005 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104005:	55                   	push   %ebp
f0104006:	89 e5                	mov    %esp,%ebp
f0104008:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f010400b:	c6 05 50 b2 22 f0 01 	movb   $0x1,0xf022b250
f0104012:	ba 21 00 00 00       	mov    $0x21,%edx
f0104017:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010401c:	ee                   	out    %al,(%dx)
f010401d:	b2 a1                	mov    $0xa1,%dl
f010401f:	ee                   	out    %al,(%dx)
f0104020:	b2 20                	mov    $0x20,%dl
f0104022:	b8 11 00 00 00       	mov    $0x11,%eax
f0104027:	ee                   	out    %al,(%dx)
f0104028:	b2 21                	mov    $0x21,%dl
f010402a:	b8 20 00 00 00       	mov    $0x20,%eax
f010402f:	ee                   	out    %al,(%dx)
f0104030:	b8 04 00 00 00       	mov    $0x4,%eax
f0104035:	ee                   	out    %al,(%dx)
f0104036:	b8 03 00 00 00       	mov    $0x3,%eax
f010403b:	ee                   	out    %al,(%dx)
f010403c:	b2 a0                	mov    $0xa0,%dl
f010403e:	b8 11 00 00 00       	mov    $0x11,%eax
f0104043:	ee                   	out    %al,(%dx)
f0104044:	b2 a1                	mov    $0xa1,%dl
f0104046:	b8 28 00 00 00       	mov    $0x28,%eax
f010404b:	ee                   	out    %al,(%dx)
f010404c:	b8 02 00 00 00       	mov    $0x2,%eax
f0104051:	ee                   	out    %al,(%dx)
f0104052:	b8 01 00 00 00       	mov    $0x1,%eax
f0104057:	ee                   	out    %al,(%dx)
f0104058:	b2 20                	mov    $0x20,%dl
f010405a:	b8 68 00 00 00       	mov    $0x68,%eax
f010405f:	ee                   	out    %al,(%dx)
f0104060:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104065:	ee                   	out    %al,(%dx)
f0104066:	b2 a0                	mov    $0xa0,%dl
f0104068:	b8 68 00 00 00       	mov    $0x68,%eax
f010406d:	ee                   	out    %al,(%dx)
f010406e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104073:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104074:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010407b:	66 83 f8 ff          	cmp    $0xffff,%ax
f010407f:	74 0b                	je     f010408c <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f0104081:	0f b7 c0             	movzwl %ax,%eax
f0104084:	89 04 24             	mov    %eax,(%esp)
f0104087:	e8 08 ff ff ff       	call   f0103f94 <irq_setmask_8259A>
}
f010408c:	c9                   	leave  
f010408d:	c3                   	ret    
	...

f0104090 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104090:	55                   	push   %ebp
f0104091:	89 e5                	mov    %esp,%ebp
f0104093:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104096:	8b 45 08             	mov    0x8(%ebp),%eax
f0104099:	89 04 24             	mov    %eax,(%esp)
f010409c:	e8 2f c7 ff ff       	call   f01007d0 <cputchar>
	*cnt++;
}
f01040a1:	c9                   	leave  
f01040a2:	c3                   	ret    

f01040a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01040a3:	55                   	push   %ebp
f01040a4:	89 e5                	mov    %esp,%ebp
f01040a6:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01040a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01040b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01040b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01040ba:	89 44 24 08          	mov    %eax,0x8(%esp)
f01040be:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01040c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040c5:	c7 04 24 90 40 10 f0 	movl   $0xf0104090,(%esp)
f01040cc:	e8 73 17 00 00       	call   f0105844 <vprintfmt>
	return cnt;
}
f01040d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01040d4:	c9                   	leave  
f01040d5:	c3                   	ret    

f01040d6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01040d6:	55                   	push   %ebp
f01040d7:	89 e5                	mov    %esp,%ebp
f01040d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01040dc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01040df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01040e6:	89 04 24             	mov    %eax,(%esp)
f01040e9:	e8 b5 ff ff ff       	call   f01040a3 <vcprintf>
	va_end(ap);

	return cnt;
}
f01040ee:	c9                   	leave  
f01040ef:	c3                   	ret    

f01040f0 <trap_init_percpu>:


// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01040f0:	55                   	push   %ebp
f01040f1:	89 e5                	mov    %esp,%ebp
f01040f3:	53                   	push   %ebx
f01040f4:	83 ec 04             	sub    $0x4,%esp

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	
	
	uint8_t cpu_id = thiscpu->cpu_id;
f01040f7:	e8 a4 24 00 00       	call   f01065a0 <cpunum>
f01040fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ff:	0f b6 98 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%ebx
	struct Taskstate *ts = &thiscpu->cpu_ts;
f0104106:	e8 95 24 00 00       	call   f01065a0 <cpunum>
f010410b:	6b c0 74             	imul   $0x74,%eax,%eax
f010410e:	8d 90 2c c0 22 f0    	lea    -0xfdd3fd4(%eax),%edx
	ts->ts_esp0 = KSTACKTOP - (KSTKSIZE + KSTKGAP)*cpu_id;
f0104114:	0f b6 cb             	movzbl %bl,%ecx
f0104117:	f7 d9                	neg    %ecx
f0104119:	c1 e1 10             	shl    $0x10,%ecx
f010411c:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0104122:	89 88 30 c0 22 f0    	mov    %ecx,-0xfdd3fd0(%eax)
	ts->ts_ss0 = GD_KD;
f0104128:	66 c7 80 34 c0 22 f0 	movw   $0x10,-0xfdd3fcc(%eax)
f010412f:	10 00 
	
		// size of struct SegDesc is 3
	uint16_t gdt_offset = GD_TSS0 + (cpu_id<<3);
f0104131:	0f b6 db             	movzbl %bl,%ebx
f0104134:	8d 1c dd 28 00 00 00 	lea    0x28(,%ebx,8),%ebx
	uint16_t gdt_index = gdt_offset>>3;
f010413b:	89 d8                	mov    %ebx,%eax
f010413d:	66 c1 e8 03          	shr    $0x3,%ax
	
		//selector
	gdt[gdt_index] = SEG16(STS_T32A, (uint32_t)(ts),sizeof(struct Taskstate),0);
f0104141:	0f b7 c0             	movzwl %ax,%eax
f0104144:	66 c7 04 c5 40 23 12 	movw   $0x68,-0xfeddcc0(,%eax,8)
f010414b:	f0 68 00 
f010414e:	66 89 14 c5 42 23 12 	mov    %dx,-0xfeddcbe(,%eax,8)
f0104155:	f0 
f0104156:	89 d1                	mov    %edx,%ecx
f0104158:	c1 e9 10             	shr    $0x10,%ecx
f010415b:	88 0c c5 44 23 12 f0 	mov    %cl,-0xfeddcbc(,%eax,8)
f0104162:	c6 04 c5 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%eax,8)
f0104169:	40 
f010416a:	c1 ea 18             	shr    $0x18,%edx
f010416d:	88 14 c5 47 23 12 f0 	mov    %dl,-0xfeddcb9(,%eax,8)
	gdt[gdt_index].sd_s = 0;
f0104174:	c6 04 c5 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%eax,8)
f010417b:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010417c:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f010417f:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0104184:	0f 01 18             	lidtl  (%eax)
		ltr(GD_TSS0);

		// Load the IDT
		lidt(&idt_pd);
		*/
}
f0104187:	83 c4 04             	add    $0x4,%esp
f010418a:	5b                   	pop    %ebx
f010418b:	5d                   	pop    %ebp
f010418c:	c3                   	ret    

f010418d <trap_init>:

extern int thandlers[];

void
trap_init(void)
{
f010418d:	55                   	push   %ebp
f010418e:	89 e5                	mov    %esp,%ebp
f0104190:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	int i = 0;
f0104193:	b8 00 00 00 00       	mov    $0x0,%eax
	for ( ; i < 52; i++) {
		SETGATE(idt[i], 0, GD_KT, thandlers[i], 0);
f0104198:	8b 14 85 b4 23 12 f0 	mov    -0xfeddc4c(,%eax,4),%edx
f010419f:	66 89 14 c5 60 b2 22 	mov    %dx,-0xfdd4da0(,%eax,8)
f01041a6:	f0 
f01041a7:	66 c7 04 c5 62 b2 22 	movw   $0x8,-0xfdd4d9e(,%eax,8)
f01041ae:	f0 08 00 
f01041b1:	c6 04 c5 64 b2 22 f0 	movb   $0x0,-0xfdd4d9c(,%eax,8)
f01041b8:	00 
f01041b9:	c6 04 c5 65 b2 22 f0 	movb   $0x8e,-0xfdd4d9b(,%eax,8)
f01041c0:	8e 
f01041c1:	c1 ea 10             	shr    $0x10,%edx
f01041c4:	66 89 14 c5 66 b2 22 	mov    %dx,-0xfdd4d9a(,%eax,8)
f01041cb:	f0 
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	int i = 0;
	for ( ; i < 52; i++) {
f01041cc:	83 c0 01             	add    $0x1,%eax
f01041cf:	83 f8 34             	cmp    $0x34,%eax
f01041d2:	75 c4                	jne    f0104198 <trap_init+0xb>
		SETGATE(idt[i], 0, GD_KT, thandlers[i], 0);
	}

	// Change DPL for break point
	SETGATE(idt[T_BRKPT], 0, GD_KT, thandlers[T_BRKPT], 3);
f01041d4:	a1 c0 23 12 f0       	mov    0xf01223c0,%eax
f01041d9:	66 a3 78 b2 22 f0    	mov    %ax,0xf022b278
f01041df:	66 c7 05 7a b2 22 f0 	movw   $0x8,0xf022b27a
f01041e6:	08 00 
f01041e8:	c6 05 7c b2 22 f0 00 	movb   $0x0,0xf022b27c
f01041ef:	c6 05 7d b2 22 f0 ee 	movb   $0xee,0xf022b27d
f01041f6:	c1 e8 10             	shr    $0x10,%eax
f01041f9:	66 a3 7e b2 22 f0    	mov    %ax,0xf022b27e

	// Change DPL for syscall
	SETGATE(idt[T_SYSCALL], 0, GD_KT, thandlers[T_SYSCALL], 3);
f01041ff:	a1 74 24 12 f0       	mov    0xf0122474,%eax
f0104204:	66 a3 e0 b3 22 f0    	mov    %ax,0xf022b3e0
f010420a:	66 c7 05 e2 b3 22 f0 	movw   $0x8,0xf022b3e2
f0104211:	08 00 
f0104213:	c6 05 e4 b3 22 f0 00 	movb   $0x0,0xf022b3e4
f010421a:	c6 05 e5 b3 22 f0 ee 	movb   $0xee,0xf022b3e5
f0104221:	c1 e8 10             	shr    $0x10,%eax
f0104224:	66 a3 e6 b3 22 f0    	mov    %ax,0xf022b3e6

	// Per-CPU setup 
	trap_init_percpu();
f010422a:	e8 c1 fe ff ff       	call   f01040f0 <trap_init_percpu>
}
f010422f:	c9                   	leave  
f0104230:	c3                   	ret    

f0104231 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104231:	55                   	push   %ebp
f0104232:	89 e5                	mov    %esp,%ebp
f0104234:	53                   	push   %ebx
f0104235:	83 ec 14             	sub    $0x14,%esp
f0104238:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010423b:	8b 03                	mov    (%ebx),%eax
f010423d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104241:	c7 04 24 9c 7f 10 f0 	movl   $0xf0107f9c,(%esp)
f0104248:	e8 89 fe ff ff       	call   f01040d6 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010424d:	8b 43 04             	mov    0x4(%ebx),%eax
f0104250:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104254:	c7 04 24 ab 7f 10 f0 	movl   $0xf0107fab,(%esp)
f010425b:	e8 76 fe ff ff       	call   f01040d6 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104260:	8b 43 08             	mov    0x8(%ebx),%eax
f0104263:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104267:	c7 04 24 ba 7f 10 f0 	movl   $0xf0107fba,(%esp)
f010426e:	e8 63 fe ff ff       	call   f01040d6 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104273:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104276:	89 44 24 04          	mov    %eax,0x4(%esp)
f010427a:	c7 04 24 c9 7f 10 f0 	movl   $0xf0107fc9,(%esp)
f0104281:	e8 50 fe ff ff       	call   f01040d6 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104286:	8b 43 10             	mov    0x10(%ebx),%eax
f0104289:	89 44 24 04          	mov    %eax,0x4(%esp)
f010428d:	c7 04 24 d8 7f 10 f0 	movl   $0xf0107fd8,(%esp)
f0104294:	e8 3d fe ff ff       	call   f01040d6 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104299:	8b 43 14             	mov    0x14(%ebx),%eax
f010429c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042a0:	c7 04 24 e7 7f 10 f0 	movl   $0xf0107fe7,(%esp)
f01042a7:	e8 2a fe ff ff       	call   f01040d6 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01042ac:	8b 43 18             	mov    0x18(%ebx),%eax
f01042af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042b3:	c7 04 24 f6 7f 10 f0 	movl   $0xf0107ff6,(%esp)
f01042ba:	e8 17 fe ff ff       	call   f01040d6 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01042bf:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01042c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042c6:	c7 04 24 05 80 10 f0 	movl   $0xf0108005,(%esp)
f01042cd:	e8 04 fe ff ff       	call   f01040d6 <cprintf>
}
f01042d2:	83 c4 14             	add    $0x14,%esp
f01042d5:	5b                   	pop    %ebx
f01042d6:	5d                   	pop    %ebp
f01042d7:	c3                   	ret    

f01042d8 <print_trapframe>:
		*/
}

void
print_trapframe(struct Trapframe *tf)
{
f01042d8:	55                   	push   %ebp
f01042d9:	89 e5                	mov    %esp,%ebp
f01042db:	56                   	push   %esi
f01042dc:	53                   	push   %ebx
f01042dd:	83 ec 10             	sub    $0x10,%esp
f01042e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01042e3:	e8 b8 22 00 00       	call   f01065a0 <cpunum>
f01042e8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01042f0:	c7 04 24 69 80 10 f0 	movl   $0xf0108069,(%esp)
f01042f7:	e8 da fd ff ff       	call   f01040d6 <cprintf>
	print_regs(&tf->tf_regs);
f01042fc:	89 1c 24             	mov    %ebx,(%esp)
f01042ff:	e8 2d ff ff ff       	call   f0104231 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104304:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104308:	89 44 24 04          	mov    %eax,0x4(%esp)
f010430c:	c7 04 24 87 80 10 f0 	movl   $0xf0108087,(%esp)
f0104313:	e8 be fd ff ff       	call   f01040d6 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104318:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010431c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104320:	c7 04 24 9a 80 10 f0 	movl   $0xf010809a,(%esp)
f0104327:	e8 aa fd ff ff       	call   f01040d6 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010432c:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010432f:	83 f8 13             	cmp    $0x13,%eax
f0104332:	77 09                	ja     f010433d <print_trapframe+0x65>
		return excnames[trapno];
f0104334:	8b 14 85 40 83 10 f0 	mov    -0xfef7cc0(,%eax,4),%edx
f010433b:	eb 1d                	jmp    f010435a <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
		return "System call";
f010433d:	ba 14 80 10 f0       	mov    $0xf0108014,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0104342:	83 f8 30             	cmp    $0x30,%eax
f0104345:	74 13                	je     f010435a <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104347:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f010434a:	83 fa 0f             	cmp    $0xf,%edx
f010434d:	ba 20 80 10 f0       	mov    $0xf0108020,%edx
f0104352:	b9 33 80 10 f0       	mov    $0xf0108033,%ecx
f0104357:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010435a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010435e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104362:	c7 04 24 ad 80 10 f0 	movl   $0xf01080ad,(%esp)
f0104369:	e8 68 fd ff ff       	call   f01040d6 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010436e:	3b 1d 60 ba 22 f0    	cmp    0xf022ba60,%ebx
f0104374:	75 19                	jne    f010438f <print_trapframe+0xb7>
f0104376:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010437a:	75 13                	jne    f010438f <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010437c:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010437f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104383:	c7 04 24 bf 80 10 f0 	movl   $0xf01080bf,(%esp)
f010438a:	e8 47 fd ff ff       	call   f01040d6 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010438f:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104392:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104396:	c7 04 24 ce 80 10 f0 	movl   $0xf01080ce,(%esp)
f010439d:	e8 34 fd ff ff       	call   f01040d6 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01043a2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01043a6:	75 51                	jne    f01043f9 <print_trapframe+0x121>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01043a8:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01043ab:	89 c2                	mov    %eax,%edx
f01043ad:	83 e2 01             	and    $0x1,%edx
f01043b0:	ba 42 80 10 f0       	mov    $0xf0108042,%edx
f01043b5:	b9 4d 80 10 f0       	mov    $0xf010804d,%ecx
f01043ba:	0f 45 ca             	cmovne %edx,%ecx
f01043bd:	89 c2                	mov    %eax,%edx
f01043bf:	83 e2 02             	and    $0x2,%edx
f01043c2:	ba 59 80 10 f0       	mov    $0xf0108059,%edx
f01043c7:	be 5f 80 10 f0       	mov    $0xf010805f,%esi
f01043cc:	0f 44 d6             	cmove  %esi,%edx
f01043cf:	83 e0 04             	and    $0x4,%eax
f01043d2:	b8 64 80 10 f0       	mov    $0xf0108064,%eax
f01043d7:	be 99 81 10 f0       	mov    $0xf0108199,%esi
f01043dc:	0f 44 c6             	cmove  %esi,%eax
f01043df:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01043e3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01043e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043eb:	c7 04 24 dc 80 10 f0 	movl   $0xf01080dc,(%esp)
f01043f2:	e8 df fc ff ff       	call   f01040d6 <cprintf>
f01043f7:	eb 0c                	jmp    f0104405 <print_trapframe+0x12d>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01043f9:	c7 04 24 93 7e 10 f0 	movl   $0xf0107e93,(%esp)
f0104400:	e8 d1 fc ff ff       	call   f01040d6 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104405:	8b 43 30             	mov    0x30(%ebx),%eax
f0104408:	89 44 24 04          	mov    %eax,0x4(%esp)
f010440c:	c7 04 24 eb 80 10 f0 	movl   $0xf01080eb,(%esp)
f0104413:	e8 be fc ff ff       	call   f01040d6 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104418:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010441c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104420:	c7 04 24 fa 80 10 f0 	movl   $0xf01080fa,(%esp)
f0104427:	e8 aa fc ff ff       	call   f01040d6 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010442c:	8b 43 38             	mov    0x38(%ebx),%eax
f010442f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104433:	c7 04 24 0d 81 10 f0 	movl   $0xf010810d,(%esp)
f010443a:	e8 97 fc ff ff       	call   f01040d6 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010443f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104443:	74 27                	je     f010446c <print_trapframe+0x194>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104445:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104448:	89 44 24 04          	mov    %eax,0x4(%esp)
f010444c:	c7 04 24 1c 81 10 f0 	movl   $0xf010811c,(%esp)
f0104453:	e8 7e fc ff ff       	call   f01040d6 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104458:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010445c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104460:	c7 04 24 2b 81 10 f0 	movl   $0xf010812b,(%esp)
f0104467:	e8 6a fc ff ff       	call   f01040d6 <cprintf>
	}
}
f010446c:	83 c4 10             	add    $0x10,%esp
f010446f:	5b                   	pop    %ebx
f0104470:	5e                   	pop    %esi
f0104471:	5d                   	pop    %ebp
f0104472:	c3                   	ret    

f0104473 <system_call_handler>:
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}

void
system_call_handler(struct Trapframe *tf)
{
f0104473:	55                   	push   %ebp
f0104474:	89 e5                	mov    %esp,%ebp
f0104476:	53                   	push   %ebx
f0104477:	83 ec 24             	sub    $0x24,%esp
f010447a:	8b 5d 08             	mov    0x8(%ebp),%ebx
    a1 = (tf->tf_regs).reg_edx;
    a2 = (tf->tf_regs).reg_ecx;
    a3 = (tf->tf_regs).reg_ebx;
    a4 = (tf->tf_regs).reg_edi;
    a5 = (tf->tf_regs).reg_esi;
    (tf->tf_regs).reg_eax = (uint32_t)syscall(syscallno,a1,a2,a3,a4,a5);
f010447d:	8b 43 04             	mov    0x4(%ebx),%eax
f0104480:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104484:	8b 03                	mov    (%ebx),%eax
f0104486:	89 44 24 10          	mov    %eax,0x10(%esp)
f010448a:	8b 43 10             	mov    0x10(%ebx),%eax
f010448d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104491:	8b 43 18             	mov    0x18(%ebx),%eax
f0104494:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104498:	8b 43 14             	mov    0x14(%ebx),%eax
f010449b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010449f:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01044a2:	89 04 24             	mov    %eax,(%esp)
f01044a5:	e8 b6 07 00 00       	call   f0104c60 <syscall>
f01044aa:	89 43 1c             	mov    %eax,0x1c(%ebx)
}
f01044ad:	83 c4 24             	add    $0x24,%esp
f01044b0:	5b                   	pop    %ebx
f01044b1:	5d                   	pop    %ebp
f01044b2:	c3                   	ret    

f01044b3 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01044b3:	55                   	push   %ebp
f01044b4:	89 e5                	mov    %esp,%ebp
f01044b6:	83 ec 38             	sub    $0x38,%esp
f01044b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01044bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01044bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01044c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01044c5:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (( tf->tf_cs &3) == 0){
f01044c8:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01044cc:	75 1c                	jne    f01044ea <page_fault_handler+0x37>
		panic("page_fault_handler: page fault in kernel mode!\n");
f01044ce:	c7 44 24 08 e4 82 10 	movl   $0xf01082e4,0x8(%esp)
f01044d5:	f0 
f01044d6:	c7 44 24 04 59 01 00 	movl   $0x159,0x4(%esp)
f01044dd:	00 
f01044de:	c7 04 24 3e 81 10 f0 	movl   $0xf010813e,(%esp)
f01044e5:	e8 56 bb ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall && 
f01044ea:	e8 b1 20 00 00       	call   f01065a0 <cpunum>
f01044ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01044f2:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01044f8:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01044fc:	0f 84 f7 00 00 00    	je     f01045f9 <page_fault_handler+0x146>
		(tf->tf_esp < USTACKTOP || 
f0104502:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104505:	8d 90 00 20 40 11    	lea    0x11402000(%eax),%edx
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall && 
f010450b:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104511:	0f 86 e2 00 00 00    	jbe    f01045f9 <page_fault_handler+0x146>
		(tf->tf_esp < USTACKTOP || 
			tf->tf_esp >= UXSTACKTOP-PGSIZE )){

		// determine the starting address of stack frame
		uint32_t xtop;
		if(tf->tf_esp >= UXSTACKTOP-PGSIZE &&
f0104517:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			tf->tf_esp < UXSTACKTOP)

			xtop = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f010451d:	83 e8 38             	sub    $0x38,%eax
f0104520:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104526:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f010452b:	0f 46 d0             	cmovbe %eax,%edx
f010452e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		else
			xtop = UXSTACKTOP - sizeof(struct UTrapframe);

		user_mem_assert(curenv,(void*)xtop, UXSTACKTOP-xtop, PTE_W|PTE_U);
f0104531:	e8 6a 20 00 00       	call   f01065a0 <cpunum>
f0104536:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010453d:	00 
f010453e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0104543:	2b 55 e4             	sub    -0x1c(%ebp),%edx
f0104546:	89 54 24 08          	mov    %edx,0x8(%esp)
f010454a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010454d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104551:	6b c0 74             	imul   $0x74,%eax,%eax
f0104554:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010455a:	89 04 24             	mov    %eax,(%esp)
f010455d:	e8 39 f1 ff ff       	call   f010369b <user_mem_assert>

		struct UTrapframe *utf = (struct UTrapframe*)xtop;
		utf->utf_eflags = tf->tf_eflags;
f0104562:	8b 43 38             	mov    0x38(%ebx),%eax
f0104565:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104568:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_eip = tf->tf_eip;
f010456b:	8b 43 30             	mov    0x30(%ebx),%eax
f010456e:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_err = tf->tf_err;
f0104571:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104574:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_esp = tf->tf_esp;
f0104577:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010457a:	89 42 30             	mov    %eax,0x30(%edx)
		utf->utf_fault_va = fault_va;
f010457d:	89 32                	mov    %esi,(%edx)
		utf->utf_regs = tf->tf_regs;
f010457f:	89 d7                	mov    %edx,%edi
f0104581:	83 c7 08             	add    $0x8,%edi
f0104584:	89 de                	mov    %ebx,%esi
f0104586:	b8 20 00 00 00       	mov    $0x20,%eax
f010458b:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104591:	74 03                	je     f0104596 <page_fault_handler+0xe3>
f0104593:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104594:	b0 1f                	mov    $0x1f,%al
f0104596:	f7 c7 02 00 00 00    	test   $0x2,%edi
f010459c:	74 05                	je     f01045a3 <page_fault_handler+0xf0>
f010459e:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01045a0:	83 e8 02             	sub    $0x2,%eax
f01045a3:	89 c1                	mov    %eax,%ecx
f01045a5:	c1 e9 02             	shr    $0x2,%ecx
f01045a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01045aa:	ba 00 00 00 00       	mov    $0x0,%edx
f01045af:	a8 02                	test   $0x2,%al
f01045b1:	74 0b                	je     f01045be <page_fault_handler+0x10b>
f01045b3:	0f b7 16             	movzwl (%esi),%edx
f01045b6:	66 89 17             	mov    %dx,(%edi)
f01045b9:	ba 02 00 00 00       	mov    $0x2,%edx
f01045be:	a8 01                	test   $0x1,%al
f01045c0:	74 07                	je     f01045c9 <page_fault_handler+0x116>
f01045c2:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f01045c6:	88 04 17             	mov    %al,(%edi,%edx,1)

		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f01045c9:	e8 d2 1f 00 00       	call   f01065a0 <cpunum>
f01045ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01045d1:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01045d7:	8b 40 64             	mov    0x64(%eax),%eax
f01045da:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = xtop;
f01045dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045e0:	89 43 3c             	mov    %eax,0x3c(%ebx)
		env_run(curenv);
f01045e3:	e8 b8 1f 00 00       	call   f01065a0 <cpunum>
f01045e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01045eb:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01045f1:	89 04 24             	mov    %eax,(%esp)
f01045f4:	e8 97 f8 ff ff       	call   f0103e90 <env_run>

	} 
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01045f9:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01045fc:	e8 9f 1f 00 00       	call   f01065a0 <cpunum>
		tf->tf_esp = xtop;
		env_run(curenv);

	} 
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104601:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104605:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104609:	6b c0 74             	imul   $0x74,%eax,%eax
f010460c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
		tf->tf_esp = xtop;
		env_run(curenv);

	} 
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104612:	8b 40 48             	mov    0x48(%eax),%eax
f0104615:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104619:	c7 04 24 14 83 10 f0 	movl   $0xf0108314,(%esp)
f0104620:	e8 b1 fa ff ff       	call   f01040d6 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104625:	89 1c 24             	mov    %ebx,(%esp)
f0104628:	e8 ab fc ff ff       	call   f01042d8 <print_trapframe>
	env_destroy(curenv);
f010462d:	e8 6e 1f 00 00       	call   f01065a0 <cpunum>
f0104632:	6b c0 74             	imul   $0x74,%eax,%eax
f0104635:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010463b:	89 04 24             	mov    %eax,(%esp)
f010463e:	e8 ac f7 ff ff       	call   f0103def <env_destroy>
}
f0104643:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104646:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104649:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010464c:	89 ec                	mov    %ebp,%esp
f010464e:	5d                   	pop    %ebp
f010464f:	c3                   	ret    

f0104650 <trap>:
    }
}

void
trap(struct Trapframe *tf)
{
f0104650:	55                   	push   %ebp
f0104651:	89 e5                	mov    %esp,%ebp
f0104653:	57                   	push   %edi
f0104654:	56                   	push   %esi
f0104655:	83 ec 20             	sub    $0x20,%esp
f0104658:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010465b:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010465c:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0104663:	74 01                	je     f0104666 <trap+0x16>
		asm volatile("hlt");
f0104665:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104666:	e8 35 1f 00 00       	call   f01065a0 <cpunum>
f010466b:	6b d0 74             	imul   $0x74,%eax,%edx
f010466e:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104674:	b8 01 00 00 00       	mov    $0x1,%eax
f0104679:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010467d:	83 f8 02             	cmp    $0x2,%eax
f0104680:	75 0c                	jne    f010468e <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104682:	c7 04 24 a0 24 12 f0 	movl   $0xf01224a0,(%esp)
f0104689:	e8 c2 21 00 00       	call   f0106850 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010468e:	9c                   	pushf  
f010468f:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104690:	f6 c4 02             	test   $0x2,%ah
f0104693:	74 24                	je     f01046b9 <trap+0x69>
f0104695:	c7 44 24 0c 4a 81 10 	movl   $0xf010814a,0xc(%esp)
f010469c:	f0 
f010469d:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01046a4:	f0 
f01046a5:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
f01046ac:	00 
f01046ad:	c7 04 24 3e 81 10 f0 	movl   $0xf010813e,(%esp)
f01046b4:	e8 87 b9 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01046b9:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01046bd:	83 e0 03             	and    $0x3,%eax
f01046c0:	83 f8 03             	cmp    $0x3,%eax
f01046c3:	0f 85 a7 00 00 00    	jne    f0104770 <trap+0x120>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f01046c9:	e8 d2 1e 00 00       	call   f01065a0 <cpunum>
f01046ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d1:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01046d8:	75 24                	jne    f01046fe <trap+0xae>
f01046da:	c7 44 24 0c 63 81 10 	movl   $0xf0108163,0xc(%esp)
f01046e1:	f0 
f01046e2:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f01046e9:	f0 
f01046ea:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
f01046f1:	00 
f01046f2:	c7 04 24 3e 81 10 f0 	movl   $0xf010813e,(%esp)
f01046f9:	e8 42 b9 ff ff       	call   f0100040 <_panic>
f01046fe:	c7 04 24 a0 24 12 f0 	movl   $0xf01224a0,(%esp)
f0104705:	e8 46 21 00 00       	call   f0106850 <spin_lock>
		/// We are now assured that we entered trap from user mode
		lock_kernel();
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010470a:	e8 91 1e 00 00       	call   f01065a0 <cpunum>
f010470f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104712:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104718:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010471c:	75 2d                	jne    f010474b <trap+0xfb>
			env_free(curenv);
f010471e:	e8 7d 1e 00 00       	call   f01065a0 <cpunum>
f0104723:	6b c0 74             	imul   $0x74,%eax,%eax
f0104726:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010472c:	89 04 24             	mov    %eax,(%esp)
f010472f:	e8 b4 f4 ff ff       	call   f0103be8 <env_free>
			curenv = NULL;
f0104734:	e8 67 1e 00 00       	call   f01065a0 <cpunum>
f0104739:	6b c0 74             	imul   $0x74,%eax,%eax
f010473c:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104743:	00 00 00 
			sched_yield();
f0104746:	e8 2d 04 00 00       	call   f0104b78 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010474b:	e8 50 1e 00 00       	call   f01065a0 <cpunum>
f0104750:	6b c0 74             	imul   $0x74,%eax,%eax
f0104753:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104759:	b9 11 00 00 00       	mov    $0x11,%ecx
f010475e:	89 c7                	mov    %eax,%edi
f0104760:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104762:	e8 39 1e 00 00       	call   f01065a0 <cpunum>
f0104767:	6b c0 74             	imul   $0x74,%eax,%eax
f010476a:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104770:	89 35 60 ba 22 f0    	mov    %esi,0xf022ba60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104776:	8b 46 28             	mov    0x28(%esi),%eax
f0104779:	83 f8 27             	cmp    $0x27,%eax
f010477c:	75 19                	jne    f0104797 <trap+0x147>
		cprintf("Spurious interrupt on irq 7\n");
f010477e:	c7 04 24 6a 81 10 f0 	movl   $0xf010816a,(%esp)
f0104785:	e8 4c f9 ff ff       	call   f01040d6 <cprintf>
		print_trapframe(tf);
f010478a:	89 34 24             	mov    %esi,(%esp)
f010478d:	e8 46 fb ff ff       	call   f01042d8 <print_trapframe>
f0104792:	e9 bf 00 00 00       	jmp    f0104856 <trap+0x206>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.


    switch(tf->tf_trapno) {
f0104797:	83 f8 0e             	cmp    $0xe,%eax
f010479a:	74 1d                	je     f01047b9 <trap+0x169>
f010479c:	83 f8 0e             	cmp    $0xe,%eax
f010479f:	90                   	nop
f01047a0:	77 07                	ja     f01047a9 <trap+0x159>
f01047a2:	83 f8 03             	cmp    $0x3,%eax
f01047a5:	75 6e                	jne    f0104815 <trap+0x1c5>
f01047a7:	eb 21                	jmp    f01047ca <trap+0x17a>
f01047a9:	83 f8 20             	cmp    $0x20,%eax
f01047ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01047b0:	74 57                	je     f0104809 <trap+0x1b9>
f01047b2:	83 f8 30             	cmp    $0x30,%eax
f01047b5:	75 5e                	jne    f0104815 <trap+0x1c5>
f01047b7:	eb 1e                	jmp    f01047d7 <trap+0x187>
        case T_PGFLT:
            page_fault_handler(tf);
f01047b9:	89 34 24             	mov    %esi,(%esp)
f01047bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01047c0:	e8 ee fc ff ff       	call   f01044b3 <page_fault_handler>
f01047c5:	e9 8c 00 00 00       	jmp    f0104856 <trap+0x206>
            break;

        case T_BRKPT:
            monitor(tf);
f01047ca:	89 34 24             	mov    %esi,(%esp)
f01047cd:	e8 35 c2 ff ff       	call   f0100a07 <monitor>
f01047d2:	e9 7f 00 00 00       	jmp    f0104856 <trap+0x206>
            break;

        case T_SYSCALL:
            tf->tf_regs.reg_eax = syscall(
f01047d7:	8b 46 04             	mov    0x4(%esi),%eax
f01047da:	89 44 24 14          	mov    %eax,0x14(%esp)
f01047de:	8b 06                	mov    (%esi),%eax
f01047e0:	89 44 24 10          	mov    %eax,0x10(%esp)
f01047e4:	8b 46 10             	mov    0x10(%esi),%eax
f01047e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01047eb:	8b 46 18             	mov    0x18(%esi),%eax
f01047ee:	89 44 24 08          	mov    %eax,0x8(%esp)
f01047f2:	8b 46 14             	mov    0x14(%esi),%eax
f01047f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047f9:	8b 46 1c             	mov    0x1c(%esi),%eax
f01047fc:	89 04 24             	mov    %eax,(%esp)
f01047ff:	e8 5c 04 00 00       	call   f0104c60 <syscall>
f0104804:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104807:	eb 4d                	jmp    f0104856 <trap+0x206>
                                    tf->tf_regs.reg_edi,
                                    tf->tf_regs.reg_esi);
            break;

        case (IRQ_OFFSET + IRQ_TIMER):
            lapic_eoi();
f0104809:	e8 dd 1e 00 00       	call   f01066eb <lapic_eoi>
            sched_yield();
f010480e:	66 90                	xchg   %ax,%ax
f0104810:	e8 63 03 00 00       	call   f0104b78 <sched_yield>
            break;

        default:
            // Unexpected trap: The user process or the kernel has a bug.
            print_trapframe(tf);
f0104815:	89 34 24             	mov    %esi,(%esp)
f0104818:	e8 bb fa ff ff       	call   f01042d8 <print_trapframe>
            if (tf->tf_cs == GD_KT)
f010481d:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104822:	75 1c                	jne    f0104840 <trap+0x1f0>
                panic("unhandled trap in kernel");
f0104824:	c7 44 24 08 87 81 10 	movl   $0xf0108187,0x8(%esp)
f010482b:	f0 
f010482c:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
f0104833:	00 
f0104834:	c7 04 24 3e 81 10 f0 	movl   $0xf010813e,(%esp)
f010483b:	e8 00 b8 ff ff       	call   f0100040 <_panic>
            else {
                env_destroy(curenv);
f0104840:	e8 5b 1d 00 00       	call   f01065a0 <cpunum>
f0104845:	6b c0 74             	imul   $0x74,%eax,%eax
f0104848:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010484e:	89 04 24             	mov    %eax,(%esp)
f0104851:	e8 99 f5 ff ff       	call   f0103def <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104856:	e8 45 1d 00 00       	call   f01065a0 <cpunum>
f010485b:	6b c0 74             	imul   $0x74,%eax,%eax
f010485e:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104865:	74 2a                	je     f0104891 <trap+0x241>
f0104867:	e8 34 1d 00 00       	call   f01065a0 <cpunum>
f010486c:	6b c0 74             	imul   $0x74,%eax,%eax
f010486f:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104875:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104879:	75 16                	jne    f0104891 <trap+0x241>
		env_run(curenv);
f010487b:	e8 20 1d 00 00       	call   f01065a0 <cpunum>
f0104880:	6b c0 74             	imul   $0x74,%eax,%eax
f0104883:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104889:	89 04 24             	mov    %eax,(%esp)
f010488c:	e8 ff f5 ff ff       	call   f0103e90 <env_run>
	else
		sched_yield();
f0104891:	e8 e2 02 00 00       	call   f0104b78 <sched_yield>
	...

f0104898 <handler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0, 0)
f0104898:	6a 00                	push   $0x0
f010489a:	6a 00                	push   $0x0
f010489c:	e9 e3 db 01 00       	jmp    f0122484 <_alltraps>
f01048a1:	90                   	nop

f01048a2 <handler1>:
TRAPHANDLER_NOEC(handler1, 1)
f01048a2:	6a 00                	push   $0x0
f01048a4:	6a 01                	push   $0x1
f01048a6:	e9 d9 db 01 00       	jmp    f0122484 <_alltraps>
f01048ab:	90                   	nop

f01048ac <handler2>:
TRAPHANDLER_NOEC(handler2, 2)
f01048ac:	6a 00                	push   $0x0
f01048ae:	6a 02                	push   $0x2
f01048b0:	e9 cf db 01 00       	jmp    f0122484 <_alltraps>
f01048b5:	90                   	nop

f01048b6 <handler3>:
TRAPHANDLER_NOEC(handler3, 3)
f01048b6:	6a 00                	push   $0x0
f01048b8:	6a 03                	push   $0x3
f01048ba:	e9 c5 db 01 00       	jmp    f0122484 <_alltraps>
f01048bf:	90                   	nop

f01048c0 <handler4>:
TRAPHANDLER_NOEC(handler4, 4)
f01048c0:	6a 00                	push   $0x0
f01048c2:	6a 04                	push   $0x4
f01048c4:	e9 bb db 01 00       	jmp    f0122484 <_alltraps>
f01048c9:	90                   	nop

f01048ca <handler5>:
TRAPHANDLER_NOEC(handler5, 5)
f01048ca:	6a 00                	push   $0x0
f01048cc:	6a 05                	push   $0x5
f01048ce:	e9 b1 db 01 00       	jmp    f0122484 <_alltraps>
f01048d3:	90                   	nop

f01048d4 <handler6>:
TRAPHANDLER_NOEC(handler6, 6)
f01048d4:	6a 00                	push   $0x0
f01048d6:	6a 06                	push   $0x6
f01048d8:	e9 a7 db 01 00       	jmp    f0122484 <_alltraps>
f01048dd:	90                   	nop

f01048de <handler7>:
TRAPHANDLER_NOEC(handler7, 7)
f01048de:	6a 00                	push   $0x0
f01048e0:	6a 07                	push   $0x7
f01048e2:	e9 9d db 01 00       	jmp    f0122484 <_alltraps>
f01048e7:	90                   	nop

f01048e8 <handler8>:
TRAPHANDLER(handler8, 8)
f01048e8:	6a 08                	push   $0x8
f01048ea:	e9 95 db 01 00       	jmp    f0122484 <_alltraps>
f01048ef:	90                   	nop

f01048f0 <handler9>:
TRAPHANDLER_NOEC(handler9, 9) /* RESERVED */
f01048f0:	6a 00                	push   $0x0
f01048f2:	6a 09                	push   $0x9
f01048f4:	e9 8b db 01 00       	jmp    f0122484 <_alltraps>
f01048f9:	90                   	nop

f01048fa <handler10>:
TRAPHANDLER(handler10, 10)
f01048fa:	6a 0a                	push   $0xa
f01048fc:	e9 83 db 01 00       	jmp    f0122484 <_alltraps>
f0104901:	90                   	nop

f0104902 <handler11>:
TRAPHANDLER(handler11, 11)
f0104902:	6a 0b                	push   $0xb
f0104904:	e9 7b db 01 00       	jmp    f0122484 <_alltraps>
f0104909:	90                   	nop

f010490a <handler12>:
TRAPHANDLER(handler12, 12)
f010490a:	6a 0c                	push   $0xc
f010490c:	e9 73 db 01 00       	jmp    f0122484 <_alltraps>
f0104911:	90                   	nop

f0104912 <handler13>:
TRAPHANDLER(handler13, 13)
f0104912:	6a 0d                	push   $0xd
f0104914:	e9 6b db 01 00       	jmp    f0122484 <_alltraps>
f0104919:	90                   	nop

f010491a <handler14>:
TRAPHANDLER(handler14, 14)
f010491a:	6a 0e                	push   $0xe
f010491c:	e9 63 db 01 00       	jmp    f0122484 <_alltraps>
f0104921:	90                   	nop

f0104922 <handler15>:
TRAPHANDLER_NOEC(handler15, 15) /* RESERVED */
f0104922:	6a 00                	push   $0x0
f0104924:	6a 0f                	push   $0xf
f0104926:	e9 59 db 01 00       	jmp    f0122484 <_alltraps>
f010492b:	90                   	nop

f010492c <handler16>:
TRAPHANDLER_NOEC(handler16, 16)
f010492c:	6a 00                	push   $0x0
f010492e:	6a 10                	push   $0x10
f0104930:	e9 4f db 01 00       	jmp    f0122484 <_alltraps>
f0104935:	90                   	nop

f0104936 <handler17>:
TRAPHANDLER(handler17, 17)
f0104936:	6a 11                	push   $0x11
f0104938:	e9 47 db 01 00       	jmp    f0122484 <_alltraps>
f010493d:	90                   	nop

f010493e <handler18>:
TRAPHANDLER_NOEC(handler18, 18)
f010493e:	6a 00                	push   $0x0
f0104940:	6a 12                	push   $0x12
f0104942:	e9 3d db 01 00       	jmp    f0122484 <_alltraps>
f0104947:	90                   	nop

f0104948 <handler19>:
TRAPHANDLER_NOEC(handler19, 19)
f0104948:	6a 00                	push   $0x0
f010494a:	6a 13                	push   $0x13
f010494c:	e9 33 db 01 00       	jmp    f0122484 <_alltraps>
f0104951:	90                   	nop

f0104952 <handler20>:

/* Have to add in all this since I'm using an array to index into */
TRAPHANDLER_NOEC(handler20, 20)
f0104952:	6a 00                	push   $0x0
f0104954:	6a 14                	push   $0x14
f0104956:	e9 29 db 01 00       	jmp    f0122484 <_alltraps>
f010495b:	90                   	nop

f010495c <handler21>:
TRAPHANDLER_NOEC(handler21, 21)
f010495c:	6a 00                	push   $0x0
f010495e:	6a 15                	push   $0x15
f0104960:	e9 1f db 01 00       	jmp    f0122484 <_alltraps>
f0104965:	90                   	nop

f0104966 <handler22>:
TRAPHANDLER_NOEC(handler22, 22)
f0104966:	6a 00                	push   $0x0
f0104968:	6a 16                	push   $0x16
f010496a:	e9 15 db 01 00       	jmp    f0122484 <_alltraps>
f010496f:	90                   	nop

f0104970 <handler23>:
TRAPHANDLER_NOEC(handler23, 23)
f0104970:	6a 00                	push   $0x0
f0104972:	6a 17                	push   $0x17
f0104974:	e9 0b db 01 00       	jmp    f0122484 <_alltraps>
f0104979:	90                   	nop

f010497a <handler24>:
TRAPHANDLER_NOEC(handler24, 24)
f010497a:	6a 00                	push   $0x0
f010497c:	6a 18                	push   $0x18
f010497e:	e9 01 db 01 00       	jmp    f0122484 <_alltraps>
f0104983:	90                   	nop

f0104984 <handler25>:
TRAPHANDLER_NOEC(handler25, 25)
f0104984:	6a 00                	push   $0x0
f0104986:	6a 19                	push   $0x19
f0104988:	e9 f7 da 01 00       	jmp    f0122484 <_alltraps>
f010498d:	90                   	nop

f010498e <handler26>:
TRAPHANDLER_NOEC(handler26, 26)
f010498e:	6a 00                	push   $0x0
f0104990:	6a 1a                	push   $0x1a
f0104992:	e9 ed da 01 00       	jmp    f0122484 <_alltraps>
f0104997:	90                   	nop

f0104998 <handler27>:
TRAPHANDLER_NOEC(handler27, 27)
f0104998:	6a 00                	push   $0x0
f010499a:	6a 1b                	push   $0x1b
f010499c:	e9 e3 da 01 00       	jmp    f0122484 <_alltraps>
f01049a1:	90                   	nop

f01049a2 <handler28>:
TRAPHANDLER_NOEC(handler28, 28)
f01049a2:	6a 00                	push   $0x0
f01049a4:	6a 1c                	push   $0x1c
f01049a6:	e9 d9 da 01 00       	jmp    f0122484 <_alltraps>
f01049ab:	90                   	nop

f01049ac <handler29>:
TRAPHANDLER_NOEC(handler29, 29)
f01049ac:	6a 00                	push   $0x0
f01049ae:	6a 1d                	push   $0x1d
f01049b0:	e9 cf da 01 00       	jmp    f0122484 <_alltraps>
f01049b5:	90                   	nop

f01049b6 <handler30>:
TRAPHANDLER_NOEC(handler30, 30)
f01049b6:	6a 00                	push   $0x0
f01049b8:	6a 1e                	push   $0x1e
f01049ba:	e9 c5 da 01 00       	jmp    f0122484 <_alltraps>
f01049bf:	90                   	nop

f01049c0 <handler31>:
TRAPHANDLER_NOEC(handler31, 31)
f01049c0:	6a 00                	push   $0x0
f01049c2:	6a 1f                	push   $0x1f
f01049c4:	e9 bb da 01 00       	jmp    f0122484 <_alltraps>
f01049c9:	90                   	nop

f01049ca <handler32>:

/* IRQs */
TRAPHANDLER_NOEC(handler32, 32)
f01049ca:	6a 00                	push   $0x0
f01049cc:	6a 20                	push   $0x20
f01049ce:	e9 b1 da 01 00       	jmp    f0122484 <_alltraps>
f01049d3:	90                   	nop

f01049d4 <handler33>:
TRAPHANDLER_NOEC(handler33, 33)
f01049d4:	6a 00                	push   $0x0
f01049d6:	6a 21                	push   $0x21
f01049d8:	e9 a7 da 01 00       	jmp    f0122484 <_alltraps>
f01049dd:	90                   	nop

f01049de <handler34>:
TRAPHANDLER_NOEC(handler34, 34)
f01049de:	6a 00                	push   $0x0
f01049e0:	6a 22                	push   $0x22
f01049e2:	e9 9d da 01 00       	jmp    f0122484 <_alltraps>
f01049e7:	90                   	nop

f01049e8 <handler35>:
TRAPHANDLER_NOEC(handler35, 35)
f01049e8:	6a 00                	push   $0x0
f01049ea:	6a 23                	push   $0x23
f01049ec:	e9 93 da 01 00       	jmp    f0122484 <_alltraps>
f01049f1:	90                   	nop

f01049f2 <handler36>:
TRAPHANDLER_NOEC(handler36, 36)
f01049f2:	6a 00                	push   $0x0
f01049f4:	6a 24                	push   $0x24
f01049f6:	e9 89 da 01 00       	jmp    f0122484 <_alltraps>
f01049fb:	90                   	nop

f01049fc <handler37>:
TRAPHANDLER_NOEC(handler37, 37)
f01049fc:	6a 00                	push   $0x0
f01049fe:	6a 25                	push   $0x25
f0104a00:	e9 7f da 01 00       	jmp    f0122484 <_alltraps>
f0104a05:	90                   	nop

f0104a06 <handler38>:
TRAPHANDLER_NOEC(handler38, 38)
f0104a06:	6a 00                	push   $0x0
f0104a08:	6a 26                	push   $0x26
f0104a0a:	e9 75 da 01 00       	jmp    f0122484 <_alltraps>
f0104a0f:	90                   	nop

f0104a10 <handler39>:
TRAPHANDLER_NOEC(handler39, 39)
f0104a10:	6a 00                	push   $0x0
f0104a12:	6a 27                	push   $0x27
f0104a14:	e9 6b da 01 00       	jmp    f0122484 <_alltraps>
f0104a19:	90                   	nop

f0104a1a <handler40>:
TRAPHANDLER_NOEC(handler40, 40)
f0104a1a:	6a 00                	push   $0x0
f0104a1c:	6a 28                	push   $0x28
f0104a1e:	e9 61 da 01 00       	jmp    f0122484 <_alltraps>
f0104a23:	90                   	nop

f0104a24 <handler41>:
TRAPHANDLER_NOEC(handler41, 41)
f0104a24:	6a 00                	push   $0x0
f0104a26:	6a 29                	push   $0x29
f0104a28:	e9 57 da 01 00       	jmp    f0122484 <_alltraps>
f0104a2d:	90                   	nop

f0104a2e <handler42>:
TRAPHANDLER_NOEC(handler42, 42)
f0104a2e:	6a 00                	push   $0x0
f0104a30:	6a 2a                	push   $0x2a
f0104a32:	e9 4d da 01 00       	jmp    f0122484 <_alltraps>
f0104a37:	90                   	nop

f0104a38 <handler43>:
TRAPHANDLER_NOEC(handler43, 43)
f0104a38:	6a 00                	push   $0x0
f0104a3a:	6a 2b                	push   $0x2b
f0104a3c:	e9 43 da 01 00       	jmp    f0122484 <_alltraps>
f0104a41:	90                   	nop

f0104a42 <handler44>:
TRAPHANDLER_NOEC(handler44, 44)
f0104a42:	6a 00                	push   $0x0
f0104a44:	6a 2c                	push   $0x2c
f0104a46:	e9 39 da 01 00       	jmp    f0122484 <_alltraps>
f0104a4b:	90                   	nop

f0104a4c <handler45>:
TRAPHANDLER_NOEC(handler45, 45)
f0104a4c:	6a 00                	push   $0x0
f0104a4e:	6a 2d                	push   $0x2d
f0104a50:	e9 2f da 01 00       	jmp    f0122484 <_alltraps>
f0104a55:	90                   	nop

f0104a56 <handler46>:
TRAPHANDLER_NOEC(handler46, 46)
f0104a56:	6a 00                	push   $0x0
f0104a58:	6a 2e                	push   $0x2e
f0104a5a:	e9 25 da 01 00       	jmp    f0122484 <_alltraps>
f0104a5f:	90                   	nop

f0104a60 <handler47>:
TRAPHANDLER_NOEC(handler47, 47)
f0104a60:	6a 00                	push   $0x0
f0104a62:	6a 2f                	push   $0x2f
f0104a64:	e9 1b da 01 00       	jmp    f0122484 <_alltraps>
f0104a69:	90                   	nop

f0104a6a <handler48>:

/* Syscall */
TRAPHANDLER_NOEC(handler48, 48)
f0104a6a:	6a 00                	push   $0x0
f0104a6c:	6a 30                	push   $0x30
f0104a6e:	e9 11 da 01 00       	jmp    f0122484 <_alltraps>
f0104a73:	90                   	nop

f0104a74 <handler49>:

/* IRQs */
TRAPHANDLER_NOEC(handler49, 49)
f0104a74:	6a 00                	push   $0x0
f0104a76:	6a 31                	push   $0x31
f0104a78:	e9 07 da 01 00       	jmp    f0122484 <_alltraps>
f0104a7d:	90                   	nop

f0104a7e <handler50>:
TRAPHANDLER_NOEC(handler50, 50)
f0104a7e:	6a 00                	push   $0x0
f0104a80:	6a 32                	push   $0x32
f0104a82:	e9 fd d9 01 00       	jmp    f0122484 <_alltraps>
f0104a87:	90                   	nop

f0104a88 <handler51>:
TRAPHANDLER_NOEC(handler51, 51)
f0104a88:	6a 00                	push   $0x0
f0104a8a:	6a 33                	push   $0x33
f0104a8c:	e9 f3 d9 01 00       	jmp    f0122484 <_alltraps>
f0104a91:	00 00                	add    %al,(%eax)
	...

f0104a94 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104a94:	55                   	push   %ebp
f0104a95:	89 e5                	mov    %esp,%ebp
f0104a97:	83 ec 18             	sub    $0x18,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104a9a:	8b 15 48 b2 22 f0    	mov    0xf022b248,%edx
f0104aa0:	8b 42 54             	mov    0x54(%edx),%eax
f0104aa3:	83 e8 02             	sub    $0x2,%eax
f0104aa6:	83 f8 01             	cmp    $0x1,%eax
f0104aa9:	76 45                	jbe    f0104af0 <sched_halt+0x5c>

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104aab:	81 c2 d0 00 00 00    	add    $0xd0,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104ab1:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104ab6:	8b 0a                	mov    (%edx),%ecx
f0104ab8:	83 e9 02             	sub    $0x2,%ecx
f0104abb:	83 f9 01             	cmp    $0x1,%ecx
f0104abe:	76 0f                	jbe    f0104acf <sched_halt+0x3b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104ac0:	83 c0 01             	add    $0x1,%eax
f0104ac3:	83 c2 7c             	add    $0x7c,%edx
f0104ac6:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104acb:	75 e9                	jne    f0104ab6 <sched_halt+0x22>
f0104acd:	eb 07                	jmp    f0104ad6 <sched_halt+0x42>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104acf:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104ad4:	75 1a                	jne    f0104af0 <sched_halt+0x5c>
		cprintf("No runnable environments in the system!\n");
f0104ad6:	c7 04 24 90 83 10 f0 	movl   $0xf0108390,(%esp)
f0104add:	e8 f4 f5 ff ff       	call   f01040d6 <cprintf>
		while (1)
			monitor(NULL);
f0104ae2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104ae9:	e8 19 bf ff ff       	call   f0100a07 <monitor>
f0104aee:	eb f2                	jmp    f0104ae2 <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104af0:	e8 ab 1a 00 00       	call   f01065a0 <cpunum>
f0104af5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af8:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104aff:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104b02:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104b07:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104b0c:	77 20                	ja     f0104b2e <sched_halt+0x9a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104b0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b12:	c7 44 24 08 04 6d 10 	movl   $0xf0106d04,0x8(%esp)
f0104b19:	f0 
f0104b1a:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f0104b21:	00 
f0104b22:	c7 04 24 b9 83 10 f0 	movl   $0xf01083b9,(%esp)
f0104b29:	e8 12 b5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104b2e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104b33:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104b36:	e8 65 1a 00 00       	call   f01065a0 <cpunum>
f0104b3b:	6b d0 74             	imul   $0x74,%eax,%edx
f0104b3e:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104b44:	b8 02 00 00 00       	mov    $0x2,%eax
f0104b49:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104b4d:	c7 04 24 a0 24 12 f0 	movl   $0xf01224a0,(%esp)
f0104b54:	e8 ba 1d 00 00       	call   f0106913 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104b59:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104b5b:	e8 40 1a 00 00       	call   f01065a0 <cpunum>
f0104b60:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104b63:	8b 80 30 c0 22 f0    	mov    -0xfdd3fd0(%eax),%eax
f0104b69:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104b6e:	89 c4                	mov    %eax,%esp
f0104b70:	6a 00                	push   $0x0
f0104b72:	6a 00                	push   $0x0
f0104b74:	fb                   	sti    
f0104b75:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104b76:	c9                   	leave  
f0104b77:	c3                   	ret    

f0104b78 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104b78:	55                   	push   %ebp
f0104b79:	89 e5                	mov    %esp,%ebp
f0104b7b:	56                   	push   %esi
f0104b7c:	53                   	push   %ebx
f0104b7d:	83 ec 10             	sub    $0x10,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	int start = -1;
	if(curenv)
f0104b80:	e8 1b 1a 00 00       	call   f01065a0 <cpunum>
f0104b85:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b88:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104b8f:	74 26                	je     f0104bb7 <sched_yield+0x3f>
		start = ENVX(curenv->env_id);
f0104b91:	e8 0a 1a 00 00       	call   f01065a0 <cpunum>
f0104b96:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b99:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104b9f:	8b 48 48             	mov    0x48(%eax),%ecx
f0104ba2:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
	int i;
	for(i = start + 1; i < (NENV+start+1); i++){
f0104ba8:	8d 41 01             	lea    0x1(%ecx),%eax
f0104bab:	81 c1 01 04 00 00    	add    $0x401,%ecx
f0104bb1:	39 c8                	cmp    %ecx,%eax
f0104bb3:	7c 0c                	jl     f0104bc1 <sched_yield+0x49>
f0104bb5:	eb 5d                	jmp    f0104c14 <sched_yield+0x9c>
f0104bb7:	b9 00 04 00 00       	mov    $0x400,%ecx
f0104bbc:	b8 00 00 00 00       	mov    $0x0,%eax
		if(envs[i%NENV].env_status == ENV_RUNNABLE){
f0104bc1:	8b 1d 48 b2 22 f0    	mov    0xf022b248,%ebx
f0104bc7:	89 c2                	mov    %eax,%edx
f0104bc9:	c1 fa 1f             	sar    $0x1f,%edx
f0104bcc:	c1 ea 16             	shr    $0x16,%edx
f0104bcf:	8d 34 10             	lea    (%eax,%edx,1),%esi
f0104bd2:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0104bd8:	29 d6                	sub    %edx,%esi
f0104bda:	6b d6 7c             	imul   $0x7c,%esi,%edx
f0104bdd:	01 da                	add    %ebx,%edx
f0104bdf:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104be3:	75 28                	jne    f0104c0d <sched_yield+0x95>
f0104be5:	eb 1e                	jmp    f0104c05 <sched_yield+0x8d>
f0104be7:	89 c2                	mov    %eax,%edx
f0104be9:	c1 fa 1f             	sar    $0x1f,%edx
f0104bec:	c1 ea 16             	shr    $0x16,%edx
f0104bef:	8d 34 10             	lea    (%eax,%edx,1),%esi
f0104bf2:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0104bf8:	29 d6                	sub    %edx,%esi
f0104bfa:	6b d6 7c             	imul   $0x7c,%esi,%edx
f0104bfd:	01 da                	add    %ebx,%edx
f0104bff:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104c03:	75 08                	jne    f0104c0d <sched_yield+0x95>
			env_run(&envs[i%NENV]);
f0104c05:	89 14 24             	mov    %edx,(%esp)
f0104c08:	e8 83 f2 ff ff       	call   f0103e90 <env_run>
	
	int start = -1;
	if(curenv)
		start = ENVX(curenv->env_id);
	int i;
	for(i = start + 1; i < (NENV+start+1); i++){
f0104c0d:	83 c0 01             	add    $0x1,%eax
f0104c10:	39 c8                	cmp    %ecx,%eax
f0104c12:	7c d3                	jl     f0104be7 <sched_yield+0x6f>
		if(envs[i%NENV].env_status == ENV_RUNNABLE){
			env_run(&envs[i%NENV]);
		}
	}
	
	if( curenv && curenv->env_status == ENV_RUNNING){
f0104c14:	e8 87 19 00 00       	call   f01065a0 <cpunum>
f0104c19:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c1c:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104c23:	74 2a                	je     f0104c4f <sched_yield+0xd7>
f0104c25:	e8 76 19 00 00       	call   f01065a0 <cpunum>
f0104c2a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c2d:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104c33:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104c37:	75 16                	jne    f0104c4f <sched_yield+0xd7>
		env_run(curenv);
f0104c39:	e8 62 19 00 00       	call   f01065a0 <cpunum>
f0104c3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c41:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104c47:	89 04 24             	mov    %eax,(%esp)
f0104c4a:	e8 41 f2 ff ff       	call   f0103e90 <env_run>
	}
	// sched_halt never returns
	sched_halt();
f0104c4f:	e8 40 fe ff ff       	call   f0104a94 <sched_halt>
}
f0104c54:	83 c4 10             	add    $0x10,%esp
f0104c57:	5b                   	pop    %ebx
f0104c58:	5e                   	pop    %esi
f0104c59:	5d                   	pop    %ebp
f0104c5a:	c3                   	ret    
f0104c5b:	00 00                	add    %al,(%eax)
f0104c5d:	00 00                	add    %al,(%eax)
	...

f0104c60 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104c60:	55                   	push   %ebp
f0104c61:	89 e5                	mov    %esp,%ebp
f0104c63:	83 ec 38             	sub    $0x38,%esp
f0104c66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104c69:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104c6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104c6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c72:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104c75:	8b 75 10             	mov    0x10(%ebp),%esi
f0104c78:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

    switch(syscallno) {
f0104c7b:	83 f8 0c             	cmp    $0xc,%eax
f0104c7e:	0f 87 93 05 00 00    	ja     f0105217 <syscall+0x5b7>
f0104c84:	ff 24 85 34 84 10 f0 	jmp    *-0xfef7bcc(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104c8b:	e8 10 19 00 00       	call   f01065a0 <cpunum>
f0104c90:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104c97:	00 
f0104c98:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104c9c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104ca0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ca3:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104ca9:	89 04 24             	mov    %eax,(%esp)
f0104cac:	e8 ea e9 ff ff       	call   f010369b <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104cb1:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104cb5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104cb9:	c7 04 24 c6 83 10 f0 	movl   $0xf01083c6,(%esp)
f0104cc0:	e8 11 f4 ff ff       	call   f01040d6 <cprintf>

        default:
            cprintf("System call number %u invalid!\n", syscallno);
            return -E_INVAL;
    }
    return 0;
f0104cc5:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cca:	e9 5d 05 00 00       	jmp    f010522c <syscall+0x5cc>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104ccf:	e8 ab b9 ff ff       	call   f010067f <cons_getc>
        case SYS_cputs:
            sys_cputs((char*)a1, a2);
            break;

        case SYS_cgetc:
            return sys_cgetc();
f0104cd4:	e9 53 05 00 00       	jmp    f010522c <syscall+0x5cc>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104ce0:	e8 bb 18 00 00       	call   f01065a0 <cpunum>
f0104ce5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ce8:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104cee:	8b 40 48             	mov    0x48(%eax),%eax

        case SYS_cgetc:
            return sys_cgetc();

        case SYS_getenvid:
            return sys_getenvid();
f0104cf1:	e9 36 05 00 00       	jmp    f010522c <syscall+0x5cc>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104cf6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104cfd:	00 
f0104cfe:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104d01:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d05:	89 3c 24             	mov    %edi,(%esp)
f0104d08:	e8 64 ea ff ff       	call   f0103771 <envid2env>
f0104d0d:	85 c0                	test   %eax,%eax
f0104d0f:	0f 88 17 05 00 00    	js     f010522c <syscall+0x5cc>
		return r;
	if (e == curenv)
f0104d15:	e8 86 18 00 00       	call   f01065a0 <cpunum>
f0104d1a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d20:	39 90 28 c0 22 f0    	cmp    %edx,-0xfdd3fd8(%eax)
f0104d26:	75 23                	jne    f0104d4b <syscall+0xeb>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104d28:	e8 73 18 00 00       	call   f01065a0 <cpunum>
f0104d2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d30:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104d36:	8b 40 48             	mov    0x48(%eax),%eax
f0104d39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d3d:	c7 04 24 cb 83 10 f0 	movl   $0xf01083cb,(%esp)
f0104d44:	e8 8d f3 ff ff       	call   f01040d6 <cprintf>
f0104d49:	eb 28                	jmp    f0104d73 <syscall+0x113>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104d4b:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104d4e:	e8 4d 18 00 00       	call   f01065a0 <cpunum>
f0104d53:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104d57:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d5a:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104d60:	8b 40 48             	mov    0x48(%eax),%eax
f0104d63:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d67:	c7 04 24 e6 83 10 f0 	movl   $0xf01083e6,(%esp)
f0104d6e:	e8 63 f3 ff ff       	call   f01040d6 <cprintf>
	env_destroy(e);
f0104d73:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d76:	89 04 24             	mov    %eax,(%esp)
f0104d79:	e8 71 f0 ff ff       	call   f0103def <env_destroy>
	return 0;
f0104d7e:	b8 00 00 00 00       	mov    $0x0,%eax

        case SYS_getenvid:
            return sys_getenvid();

        case SYS_env_destroy:
            return sys_env_destroy(a1);
f0104d83:	e9 a4 04 00 00       	jmp    f010522c <syscall+0x5cc>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104d88:	e8 eb fd ff ff       	call   f0104b78 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
    struct Env *env;
    int error = env_alloc(&env, curenv->env_id);
f0104d8d:	e8 0e 18 00 00       	call   f01065a0 <cpunum>
f0104d92:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d95:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104d9b:	8b 40 48             	mov    0x48(%eax),%eax
f0104d9e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104da2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104da5:	89 04 24             	mov    %eax,(%esp)
f0104da8:	e8 fa ea ff ff       	call   f01038a7 <env_alloc>
    if (error) {
f0104dad:	85 c0                	test   %eax,%eax
f0104daf:	0f 85 77 04 00 00    	jne    f010522c <syscall+0x5cc>
        return error; //env_alloc() returns the appropriate error no.
    }

    env->env_status = ENV_NOT_RUNNABLE;
f0104db5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104db8:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
    env->env_tf = thiscpu->cpu_env->env_tf;
f0104dbf:	e8 dc 17 00 00       	call   f01065a0 <cpunum>
f0104dc4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dc7:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
f0104dcd:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104dd2:	89 df                	mov    %ebx,%edi
f0104dd4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    
    // Make the new environment return zero.
    env->env_tf.tf_regs.reg_eax = 0;
f0104dd6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104dd9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

    return env->env_id;
f0104de0:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_yield:
            sys_yield();
            break;

        case SYS_exofork:
            return sys_exofork();
f0104de3:	e9 44 04 00 00       	jmp    f010522c <syscall+0x5cc>
	// envid's status.

	// LAB 4: Your code here.

    // check status.
    if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f0104de8:	83 fe 02             	cmp    $0x2,%esi
f0104deb:	74 0e                	je     f0104dfb <syscall+0x19b>
        return -E_INVAL;
f0104ded:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	// envid's status.

	// LAB 4: Your code here.

    // check status.
    if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f0104df2:	83 fe 04             	cmp    $0x4,%esi
f0104df5:	0f 85 31 04 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_INVAL;
    }
    
    struct Env *env;
    int error = envid2env(envid, &env, 1);
f0104dfb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e02:	00 
f0104e03:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e06:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e0a:	89 3c 24             	mov    %edi,(%esp)
f0104e0d:	e8 5f e9 ff ff       	call   f0103771 <envid2env>
f0104e12:	89 c2                	mov    %eax,%edx
    if (error) {
        return -E_BAD_ENV;
f0104e14:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
        return -E_INVAL;
    }
    
    struct Env *env;
    int error = envid2env(envid, &env, 1);
    if (error) {
f0104e19:	85 d2                	test   %edx,%edx
f0104e1b:	0f 85 0b 04 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_BAD_ENV;
    }

    // change status.
    env->env_status = status;
f0104e21:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e24:	89 70 54             	mov    %esi,0x54(%eax)

    return 0;
f0104e27:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e2c:	e9 fb 03 00 00       	jmp    f010522c <syscall+0x5cc>

	// LAB 4: Your code here.

    // check address.
    if ((uint32_t)va >= UTOP || ((uint32_t)va % PGSIZE) != 0) {
        return -E_INVAL;
f0104e31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	//   allocated!

	// LAB 4: Your code here.

    // check address.
    if ((uint32_t)va >= UTOP || ((uint32_t)va % PGSIZE) != 0) {
f0104e36:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104e3c:	0f 87 ea 03 00 00    	ja     f010522c <syscall+0x5cc>
f0104e42:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104e48:	0f 85 de 03 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_INVAL;
    }

    // check permission.
    if (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~PTE_SYSCALL)) {
f0104e4e:	89 da                	mov    %ebx,%edx
f0104e50:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f0104e56:	83 fa 05             	cmp    $0x5,%edx
f0104e59:	0f 85 cd 03 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_INVAL;
    }

    // access environment.
    struct Env *env;
    if (envid2env(envid, &env, 1)) {
f0104e5f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e66:	00 
f0104e67:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e6e:	89 3c 24             	mov    %edi,(%esp)
f0104e71:	e8 fb e8 ff ff       	call   f0103771 <envid2env>
f0104e76:	89 c2                	mov    %eax,%edx
        return -E_BAD_ENV;
f0104e78:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
        return -E_INVAL;
    }

    // access environment.
    struct Env *env;
    if (envid2env(envid, &env, 1)) {
f0104e7d:	85 d2                	test   %edx,%edx
f0104e7f:	0f 85 a7 03 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_BAD_ENV;
    }

    // alloc page
    struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0104e85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104e8c:	e8 5b c2 ff ff       	call   f01010ec <page_alloc>
f0104e91:	89 c7                	mov    %eax,%edi
    if (!page) {
f0104e93:	85 c0                	test   %eax,%eax
f0104e95:	74 30                	je     f0104ec7 <syscall+0x267>
        return -E_NO_MEM;
    }

    // side effect handled in page_insert (using page_remove())
    if (page_insert(env->env_pgdir, page, va, perm)) {
f0104e97:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104e9b:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104e9f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ea3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ea6:	8b 40 60             	mov    0x60(%eax),%eax
f0104ea9:	89 04 24             	mov    %eax,(%esp)
f0104eac:	e8 1e c6 ff ff       	call   f01014cf <page_insert>
f0104eb1:	85 c0                	test   %eax,%eax
f0104eb3:	74 1c                	je     f0104ed1 <syscall+0x271>
        page_free(page);
f0104eb5:	89 3c 24             	mov    %edi,(%esp)
f0104eb8:	e8 ad c2 ff ff       	call   f010116a <page_free>
        return -E_NO_MEM;
f0104ebd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104ec2:	e9 65 03 00 00       	jmp    f010522c <syscall+0x5cc>
    }

    // alloc page
    struct PageInfo *page = page_alloc(ALLOC_ZERO);
    if (!page) {
        return -E_NO_MEM;
f0104ec7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104ecc:	e9 5b 03 00 00       	jmp    f010522c <syscall+0x5cc>
    if (page_insert(env->env_pgdir, page, va, perm)) {
        page_free(page);
        return -E_NO_MEM;
    }

    return 0;
f0104ed1:	b8 00 00 00 00       	mov    $0x0,%eax

        case SYS_env_set_status:
            return sys_env_set_status(a1, a2);

        case SYS_page_alloc:
            return sys_page_alloc(a1, (void *)a2, a3);
f0104ed6:	e9 51 03 00 00       	jmp    f010522c <syscall+0x5cc>

	// LAB 4: Your code here.

    // check environments.
    struct Env *srcenv, *destenv;
    if (envid2env(srcenvid, &srcenv, 1) || envid2env(dstenvid, &destenv, 1)) {
f0104edb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ee2:	00 
f0104ee3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eea:	89 3c 24             	mov    %edi,(%esp)
f0104eed:	e8 7f e8 ff ff       	call   f0103771 <envid2env>
f0104ef2:	89 c2                	mov    %eax,%edx
        return -E_BAD_ENV;
f0104ef4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax

	// LAB 4: Your code here.

    // check environments.
    struct Env *srcenv, *destenv;
    if (envid2env(srcenvid, &srcenv, 1) || envid2env(dstenvid, &destenv, 1)) {
f0104ef9:	85 d2                	test   %edx,%edx
f0104efb:	0f 85 2b 03 00 00    	jne    f010522c <syscall+0x5cc>
f0104f01:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f08:	00 
f0104f09:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104f0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f10:	89 1c 24             	mov    %ebx,(%esp)
f0104f13:	e8 59 e8 ff ff       	call   f0103771 <envid2env>
f0104f18:	89 c2                	mov    %eax,%edx
        return -E_BAD_ENV;
f0104f1a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax

	// LAB 4: Your code here.

    // check environments.
    struct Env *srcenv, *destenv;
    if (envid2env(srcenvid, &srcenv, 1) || envid2env(dstenvid, &destenv, 1)) {
f0104f1f:	85 d2                	test   %edx,%edx
f0104f21:	0f 85 05 03 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_BAD_ENV;
    }

    // check addresses
    if ((uint32_t)srcva>=UTOP||(uint32_t)dstva>=UTOP||((uint32_t)srcva%PGSIZE!=0)||((uint32_t)dstva%PGSIZE!=0)) {
f0104f27:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104f2d:	0f 87 97 00 00 00    	ja     f0104fca <syscall+0x36a>
f0104f33:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104f3a:	0f 87 8a 00 00 00    	ja     f0104fca <syscall+0x36a>
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
f0104f40:	8b 55 18             	mov    0x18(%ebp),%edx
f0104f43:	09 f2                	or     %esi,%edx
        return -E_BAD_ENV;
    }

    // check addresses
    if ((uint32_t)srcva>=UTOP||(uint32_t)dstva>=UTOP||((uint32_t)srcva%PGSIZE!=0)||((uint32_t)dstva%PGSIZE!=0)) {
        return -E_INVAL;
f0104f45:	b0 fd                	mov    $0xfd,%al
    if (envid2env(srcenvid, &srcenv, 1) || envid2env(dstenvid, &destenv, 1)) {
        return -E_BAD_ENV;
    }

    // check addresses
    if ((uint32_t)srcva>=UTOP||(uint32_t)dstva>=UTOP||((uint32_t)srcva%PGSIZE!=0)||((uint32_t)dstva%PGSIZE!=0)) {
f0104f47:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0104f4d:	0f 85 d9 02 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_INVAL;
    }

    // check if srcva is mapped in srcenvid's add space
    pte_t *srcpte;
    struct PageInfo *page = page_lookup(srcenv->env_pgdir, srcva, &srcpte);
f0104f53:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f56:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104f5a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104f5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f61:	8b 40 60             	mov    0x60(%eax),%eax
f0104f64:	89 04 24             	mov    %eax,(%esp)
f0104f67:	e8 66 c4 ff ff       	call   f01013d2 <page_lookup>
f0104f6c:	89 c2                	mov    %eax,%edx
    if (!page) {
f0104f6e:	85 c0                	test   %eax,%eax
f0104f70:	74 62                	je     f0104fd4 <syscall+0x374>
        return -E_INVAL;
    }

    // check permissions
    if (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~PTE_SYSCALL)) {
f0104f72:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104f75:	81 e1 fd f1 ff ff    	and    $0xfffff1fd,%ecx
        return -E_INVAL;
f0104f7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
    if (!page) {
        return -E_INVAL;
    }

    // check permissions
    if (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~PTE_SYSCALL)) {
f0104f80:	83 f9 05             	cmp    $0x5,%ecx
f0104f83:	0f 85 a3 02 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_INVAL;
    }

    // Is srcva read-only but dest writable?
    if ((perm & PTE_W) && !(*srcpte & PTE_W)) {
f0104f89:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104f8d:	74 0c                	je     f0104f9b <syscall+0x33b>
f0104f8f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104f92:	f6 01 02             	testb  $0x2,(%ecx)
f0104f95:	0f 84 91 02 00 00    	je     f010522c <syscall+0x5cc>
        return -E_INVAL;
    }

    // Map
    if (page_insert(destenv->env_pgdir, page, dstva, perm)) {
f0104f9b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f0104f9e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104fa2:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0104fa5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104fa9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104fad:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fb0:	8b 40 60             	mov    0x60(%eax),%eax
f0104fb3:	89 04 24             	mov    %eax,(%esp)
f0104fb6:	e8 14 c5 ff ff       	call   f01014cf <page_insert>
        return -E_NO_MEM;
f0104fbb:	83 f8 01             	cmp    $0x1,%eax
f0104fbe:	19 c0                	sbb    %eax,%eax
f0104fc0:	f7 d0                	not    %eax
f0104fc2:	83 e0 fc             	and    $0xfffffffc,%eax
f0104fc5:	e9 62 02 00 00       	jmp    f010522c <syscall+0x5cc>
        return -E_BAD_ENV;
    }

    // check addresses
    if ((uint32_t)srcva>=UTOP||(uint32_t)dstva>=UTOP||((uint32_t)srcva%PGSIZE!=0)||((uint32_t)dstva%PGSIZE!=0)) {
        return -E_INVAL;
f0104fca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104fcf:	e9 58 02 00 00       	jmp    f010522c <syscall+0x5cc>

    // check if srcva is mapped in srcenvid's add space
    pte_t *srcpte;
    struct PageInfo *page = page_lookup(srcenv->env_pgdir, srcva, &srcpte);
    if (!page) {
        return -E_INVAL;
f0104fd4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104fd9:	e9 4e 02 00 00       	jmp    f010522c <syscall+0x5cc>

	// LAB 4: Your code here.

    // check va.
    if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE != 0)) {
        return -E_INVAL;
f0104fde:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.

    // check va.
    if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE != 0)) {
f0104fe3:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104fe9:	0f 87 3d 02 00 00    	ja     f010522c <syscall+0x5cc>
f0104fef:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104ff5:	0f 85 31 02 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_INVAL;
    }

    // Check environment.
    struct Env *env;
    if (envid2env(envid, &env, 1)) {
f0104ffb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105002:	00 
f0105003:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105006:	89 44 24 04          	mov    %eax,0x4(%esp)
f010500a:	89 3c 24             	mov    %edi,(%esp)
f010500d:	e8 5f e7 ff ff       	call   f0103771 <envid2env>
f0105012:	89 c2                	mov    %eax,%edx
        return -E_BAD_ENV;
f0105014:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
        return -E_INVAL;
    }

    // Check environment.
    struct Env *env;
    if (envid2env(envid, &env, 1)) {
f0105019:	85 d2                	test   %edx,%edx
f010501b:	0f 85 0b 02 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_BAD_ENV;
    }

    page_remove(env->env_pgdir, va);
f0105021:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105025:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105028:	8b 40 60             	mov    0x60(%eax),%eax
f010502b:	89 04 24             	mov    %eax,(%esp)
f010502e:	e8 4c c4 ff ff       	call   f010147f <page_remove>
    
    return 0;
f0105033:	b8 00 00 00 00       	mov    $0x0,%eax
f0105038:	e9 ef 01 00 00       	jmp    f010522c <syscall+0x5cc>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.

    assert(func);
f010503d:	85 f6                	test   %esi,%esi
f010503f:	75 24                	jne    f0105065 <syscall+0x405>
f0105041:	c7 44 24 0c fe 83 10 	movl   $0xf01083fe,0xc(%esp)
f0105048:	f0 
f0105049:	c7 44 24 08 bf 7b 10 	movl   $0xf0107bbf,0x8(%esp)
f0105050:	f0 
f0105051:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0105058:	00 
f0105059:	c7 04 24 03 84 10 f0 	movl   $0xf0108403,(%esp)
f0105060:	e8 db af ff ff       	call   f0100040 <_panic>

    // find environment.
    struct Env *env;
    if (envid2env(envid, &env, 1)) {
f0105065:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010506c:	00 
f010506d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105070:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105074:	89 3c 24             	mov    %edi,(%esp)
f0105077:	e8 f5 e6 ff ff       	call   f0103771 <envid2env>
f010507c:	89 c2                	mov    %eax,%edx
        return -E_BAD_ENV;
f010507e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax

    assert(func);

    // find environment.
    struct Env *env;
    if (envid2env(envid, &env, 1)) {
f0105083:	85 d2                	test   %edx,%edx
f0105085:	0f 85 a1 01 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_BAD_ENV;
    }

    env->env_pgfault_upcall = func;
f010508b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010508e:	89 70 64             	mov    %esi,0x64(%eax)

    return 0;
f0105091:	b8 00 00 00 00       	mov    $0x0,%eax
f0105096:	e9 91 01 00 00       	jmp    f010522c <syscall+0x5cc>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.

    if ((uintptr_t)dstva < UTOP) {
f010509b:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f01050a1:	77 11                	ja     f01050b4 <syscall+0x454>
        if ((uintptr_t)dstva % PGSIZE != 0) {
            return -E_INVAL;
f01050a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.

    if ((uintptr_t)dstva < UTOP) {
        if ((uintptr_t)dstva % PGSIZE != 0) {
f01050a8:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f01050ae:	0f 85 78 01 00 00    	jne    f010522c <syscall+0x5cc>
            return -E_INVAL;
        }
    }

    curenv->env_ipc_dstva = dstva;
f01050b4:	e8 e7 14 00 00       	call   f01065a0 <cpunum>
f01050b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01050bc:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01050c2:	89 78 6c             	mov    %edi,0x6c(%eax)
    curenv->env_ipc_recving = 1;
f01050c5:	e8 d6 14 00 00       	call   f01065a0 <cpunum>
f01050ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01050cd:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01050d3:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f01050d7:	e8 c4 14 00 00       	call   f01065a0 <cpunum>
f01050dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01050df:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01050e5:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	return 0;
f01050ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01050f1:	e9 36 01 00 00       	jmp    f010522c <syscall+0x5cc>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.

    struct Env *env;
    if (envid2env(envid, &env, 0)) {
f01050f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01050fd:	00 
f01050fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105101:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105105:	89 3c 24             	mov    %edi,(%esp)
f0105108:	e8 64 e6 ff ff       	call   f0103771 <envid2env>
f010510d:	89 c2                	mov    %eax,%edx
        return -E_BAD_ENV;
f010510f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.

    struct Env *env;
    if (envid2env(envid, &env, 0)) {
f0105114:	85 d2                	test   %edx,%edx
f0105116:	0f 85 10 01 00 00    	jne    f010522c <syscall+0x5cc>
        return -E_BAD_ENV;
    }

    if (!env->env_ipc_recving) {
f010511c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        return -E_IPC_NOT_RECV;
f010511f:	b0 f9                	mov    $0xf9,%al
    struct Env *env;
    if (envid2env(envid, &env, 0)) {
        return -E_BAD_ENV;
    }

    if (!env->env_ipc_recving) {
f0105121:	80 7a 68 00          	cmpb   $0x0,0x68(%edx)
f0105125:	0f 84 01 01 00 00    	je     f010522c <syscall+0x5cc>
        return -E_IPC_NOT_RECV;
    }

    if ((uintptr_t)srcva < UTOP) {
f010512b:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105131:	0f 87 a3 00 00 00    	ja     f01051da <syscall+0x57a>
        if ((uintptr_t)srcva % PGSIZE != 0) {
            return -E_INVAL;
f0105137:	b0 fd                	mov    $0xfd,%al
    if (!env->env_ipc_recving) {
        return -E_IPC_NOT_RECV;
    }

    if ((uintptr_t)srcva < UTOP) {
        if ((uintptr_t)srcva % PGSIZE != 0) {
f0105139:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f010513f:	0f 85 e7 00 00 00    	jne    f010522c <syscall+0x5cc>
            return -E_INVAL;
        }

        if (!(perm & PTE_U) ||
            !(perm & PTE_P) ||
f0105145:	8b 55 18             	mov    0x18(%ebp),%edx
f0105148:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
    if ((uintptr_t)srcva < UTOP) {
        if ((uintptr_t)srcva % PGSIZE != 0) {
            return -E_INVAL;
        }

        if (!(perm & PTE_U) ||
f010514e:	83 fa 05             	cmp    $0x5,%edx
f0105151:	0f 85 d5 00 00 00    	jne    f010522c <syscall+0x5cc>
            (perm & ~PTE_SYSCALL)) {
            return -E_INVAL;
        }

        pte_t *pte;
        struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
f0105157:	e8 44 14 00 00       	call   f01065a0 <cpunum>
f010515c:	8d 55 e0             	lea    -0x20(%ebp),%edx
f010515f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105163:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105167:	6b c0 74             	imul   $0x74,%eax,%eax
f010516a:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105170:	8b 40 60             	mov    0x60(%eax),%eax
f0105173:	89 04 24             	mov    %eax,(%esp)
f0105176:	e8 57 c2 ff ff       	call   f01013d2 <page_lookup>
f010517b:	89 c2                	mov    %eax,%edx
        if (!page) {
f010517d:	85 c0                	test   %eax,%eax
f010517f:	0f 84 8b 00 00 00    	je     f0105210 <syscall+0x5b0>
            return -E_INVAL;
        }

        if ((perm & PTE_W) && !(*pte & PTE_W)) {
f0105185:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105189:	74 11                	je     f010519c <syscall+0x53c>
            return -E_INVAL;
f010518b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
        if (!page) {
            return -E_INVAL;
        }

        if ((perm & PTE_W) && !(*pte & PTE_W)) {
f0105190:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105193:	f6 01 02             	testb  $0x2,(%ecx)
f0105196:	0f 84 90 00 00 00    	je     f010522c <syscall+0x5cc>
            return -E_INVAL;
        }

        if ((uintptr_t)env->env_ipc_dstva < UTOP &&
f010519c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010519f:	8b 48 6c             	mov    0x6c(%eax),%ecx
f01051a2:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f01051a8:	77 25                	ja     f01051cf <syscall+0x56f>
            page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm)) {
f01051aa:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01051ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01051b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01051b5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01051b9:	8b 40 60             	mov    0x60(%eax),%eax
f01051bc:	89 04 24             	mov    %eax,(%esp)
f01051bf:	e8 0b c3 ff ff       	call   f01014cf <page_insert>
f01051c4:	89 c2                	mov    %eax,%edx
            return -E_NO_MEM;
f01051c6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

        if ((perm & PTE_W) && !(*pte & PTE_W)) {
            return -E_INVAL;
        }

        if ((uintptr_t)env->env_ipc_dstva < UTOP &&
f01051cb:	85 d2                	test   %edx,%edx
f01051cd:	75 5d                	jne    f010522c <syscall+0x5cc>
            page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm)) {
            return -E_NO_MEM;
        }

        env->env_ipc_perm = perm;
f01051cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051d2:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01051d5:	89 58 78             	mov    %ebx,0x78(%eax)
f01051d8:	eb 07                	jmp    f01051e1 <syscall+0x581>
    }
    else {
        env->env_ipc_perm = 0;
f01051da:	c7 42 78 00 00 00 00 	movl   $0x0,0x78(%edx)
    }
    
    env->env_ipc_recving = 0;
f01051e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01051e4:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
    env->env_ipc_from = curenv->env_id;
f01051e8:	e8 b3 13 00 00       	call   f01065a0 <cpunum>
f01051ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01051f0:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01051f6:	8b 40 48             	mov    0x48(%eax),%eax
f01051f9:	89 43 74             	mov    %eax,0x74(%ebx)
    env->env_ipc_value = value;
f01051fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051ff:	89 70 70             	mov    %esi,0x70(%eax)
    env->env_status = ENV_RUNNABLE;
f0105202:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

    return 0;
f0105209:	b8 00 00 00 00       	mov    $0x0,%eax
f010520e:	eb 1c                	jmp    f010522c <syscall+0x5cc>
        }

        pte_t *pte;
        struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
        if (!page) {
            return -E_INVAL;
f0105210:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105215:	eb 15                	jmp    f010522c <syscall+0x5cc>

        case SYS_ipc_try_send:
            return sys_ipc_try_send(a1, a2, (void *)a3, a4);

        default:
            cprintf("System call number %u invalid!\n", syscallno);
f0105217:	89 44 24 04          	mov    %eax,0x4(%esp)
f010521b:	c7 04 24 14 84 10 f0 	movl   $0xf0108414,(%esp)
f0105222:	e8 af ee ff ff       	call   f01040d6 <cprintf>
            return -E_INVAL;
f0105227:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
    }
    return 0;
}
f010522c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010522f:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105232:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105235:	89 ec                	mov    %ebp,%esp
f0105237:	5d                   	pop    %ebp
f0105238:	c3                   	ret    
f0105239:	00 00                	add    %al,(%eax)
	...

f010523c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010523c:	55                   	push   %ebp
f010523d:	89 e5                	mov    %esp,%ebp
f010523f:	57                   	push   %edi
f0105240:	56                   	push   %esi
f0105241:	53                   	push   %ebx
f0105242:	83 ec 14             	sub    $0x14,%esp
f0105245:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105248:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010524b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010524e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105251:	8b 1a                	mov    (%edx),%ebx
f0105253:	8b 01                	mov    (%ecx),%eax
f0105255:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0105258:	39 c3                	cmp    %eax,%ebx
f010525a:	0f 8f 9c 00 00 00    	jg     f01052fc <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0105260:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105267:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010526a:	01 d8                	add    %ebx,%eax
f010526c:	89 c7                	mov    %eax,%edi
f010526e:	c1 ef 1f             	shr    $0x1f,%edi
f0105271:	01 c7                	add    %eax,%edi
f0105273:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105275:	39 df                	cmp    %ebx,%edi
f0105277:	7c 33                	jl     f01052ac <stab_binsearch+0x70>
f0105279:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010527c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010527f:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0105284:	39 f0                	cmp    %esi,%eax
f0105286:	0f 84 bc 00 00 00    	je     f0105348 <stab_binsearch+0x10c>
f010528c:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105290:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105294:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0105296:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105299:	39 d8                	cmp    %ebx,%eax
f010529b:	7c 0f                	jl     f01052ac <stab_binsearch+0x70>
f010529d:	0f b6 0a             	movzbl (%edx),%ecx
f01052a0:	83 ea 0c             	sub    $0xc,%edx
f01052a3:	39 f1                	cmp    %esi,%ecx
f01052a5:	75 ef                	jne    f0105296 <stab_binsearch+0x5a>
f01052a7:	e9 9e 00 00 00       	jmp    f010534a <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01052ac:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01052af:	eb 3c                	jmp    f01052ed <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01052b1:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01052b4:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01052b6:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01052b9:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01052c0:	eb 2b                	jmp    f01052ed <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01052c2:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01052c5:	76 14                	jbe    f01052db <stab_binsearch+0x9f>
			*region_right = m - 1;
f01052c7:	83 e8 01             	sub    $0x1,%eax
f01052ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01052cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01052d0:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01052d2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01052d9:	eb 12                	jmp    f01052ed <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01052db:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01052de:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f01052e0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01052e4:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01052e6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01052ed:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01052f0:	0f 8d 71 ff ff ff    	jge    f0105267 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01052f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01052fa:	75 0f                	jne    f010530b <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f01052fc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01052ff:	8b 02                	mov    (%edx),%eax
f0105301:	83 e8 01             	sub    $0x1,%eax
f0105304:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105307:	89 01                	mov    %eax,(%ecx)
f0105309:	eb 57                	jmp    f0105362 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010530b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010530e:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105310:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105313:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105315:	39 c1                	cmp    %eax,%ecx
f0105317:	7d 28                	jge    f0105341 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0105319:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010531c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f010531f:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0105324:	39 f2                	cmp    %esi,%edx
f0105326:	74 19                	je     f0105341 <stab_binsearch+0x105>
f0105328:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010532c:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105330:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105333:	39 c1                	cmp    %eax,%ecx
f0105335:	7d 0a                	jge    f0105341 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0105337:	0f b6 1a             	movzbl (%edx),%ebx
f010533a:	83 ea 0c             	sub    $0xc,%edx
f010533d:	39 f3                	cmp    %esi,%ebx
f010533f:	75 ef                	jne    f0105330 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105341:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105344:	89 02                	mov    %eax,(%edx)
f0105346:	eb 1a                	jmp    f0105362 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105348:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010534a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010534d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105350:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105354:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105357:	0f 82 54 ff ff ff    	jb     f01052b1 <stab_binsearch+0x75>
f010535d:	e9 60 ff ff ff       	jmp    f01052c2 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105362:	83 c4 14             	add    $0x14,%esp
f0105365:	5b                   	pop    %ebx
f0105366:	5e                   	pop    %esi
f0105367:	5f                   	pop    %edi
f0105368:	5d                   	pop    %ebp
f0105369:	c3                   	ret    

f010536a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010536a:	55                   	push   %ebp
f010536b:	89 e5                	mov    %esp,%ebp
f010536d:	57                   	push   %edi
f010536e:	56                   	push   %esi
f010536f:	53                   	push   %ebx
f0105370:	83 ec 5c             	sub    $0x5c,%esp
f0105373:	8b 75 08             	mov    0x8(%ebp),%esi
f0105376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105379:	c7 03 68 84 10 f0    	movl   $0xf0108468,(%ebx)
	info->eip_line = 0;
f010537f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105386:	c7 43 08 68 84 10 f0 	movl   $0xf0108468,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010538d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105394:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105397:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010539e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01053a4:	0f 87 dd 00 00 00    	ja     f0105487 <debuginfo_eip+0x11d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		if(user_mem_check(curenv,usd,sizeof(struct UserStabData),PTE_U)<0){
f01053aa:	e8 f1 11 00 00       	call   f01065a0 <cpunum>
f01053af:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01053b6:	00 
f01053b7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01053be:	00 
f01053bf:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01053c6:	00 
f01053c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01053ca:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01053d0:	89 04 24             	mov    %eax,(%esp)
f01053d3:	e8 44 e2 ff ff       	call   f010361c <user_mem_check>
f01053d8:	89 c2                	mov    %eax,%edx
			return -1;
f01053da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		if(user_mem_check(curenv,usd,sizeof(struct UserStabData),PTE_U)<0){
f01053df:	85 d2                	test   %edx,%edx
f01053e1:	0f 88 b3 02 00 00    	js     f010569a <debuginfo_eip+0x330>
			return -1;
		}

		stabs = usd->stabs;
f01053e7:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f01053ed:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01053f0:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01053f6:	a1 08 00 20 00       	mov    0x200008,%eax
f01053fb:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01053fe:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105404:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv,stabs,stab_end -stabs,PTE_U)<0 ||
f0105407:	e8 94 11 00 00       	call   f01065a0 <cpunum>
f010540c:	89 c2                	mov    %eax,%edx
f010540e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105415:	00 
f0105416:	89 f8                	mov    %edi,%eax
f0105418:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f010541b:	c1 f8 02             	sar    $0x2,%eax
f010541e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105424:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105428:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010542b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010542f:	6b c2 74             	imul   $0x74,%edx,%eax
f0105432:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105438:	89 04 24             	mov    %eax,(%esp)
f010543b:	e8 dc e1 ff ff       	call   f010361c <user_mem_check>
f0105440:	89 c2                	mov    %eax,%edx
				user_mem_check(curenv,stabstr,stabstr_end - stabstr,PTE_U)<0)
			return -1;
f0105442:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv,stabs,stab_end -stabs,PTE_U)<0 ||
f0105447:	85 d2                	test   %edx,%edx
f0105449:	0f 88 4b 02 00 00    	js     f010569a <debuginfo_eip+0x330>
				user_mem_check(curenv,stabstr,stabstr_end - stabstr,PTE_U)<0)
f010544f:	e8 4c 11 00 00       	call   f01065a0 <cpunum>
f0105454:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010545b:	00 
f010545c:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010545f:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105462:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105466:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105469:	89 54 24 04          	mov    %edx,0x4(%esp)
f010546d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105470:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105476:	89 04 24             	mov    %eax,(%esp)
f0105479:	e8 9e e1 ff ff       	call   f010361c <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv,stabs,stab_end -stabs,PTE_U)<0 ||
f010547e:	85 c0                	test   %eax,%eax
f0105480:	79 1f                	jns    f01054a1 <debuginfo_eip+0x137>
f0105482:	e9 07 02 00 00       	jmp    f010568e <debuginfo_eip+0x324>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105487:	c7 45 c0 d6 70 11 f0 	movl   $0xf01170d6,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010548e:	c7 45 bc cd 37 11 f0 	movl   $0xf01137cd,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105495:	bf cc 37 11 f0       	mov    $0xf01137cc,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010549a:	c7 45 c4 54 89 10 f0 	movl   $0xf0108954,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01054a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
				user_mem_check(curenv,stabstr,stabstr_end - stabstr,PTE_U)<0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01054a6:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01054a9:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f01054ac:	0f 83 e8 01 00 00    	jae    f010569a <debuginfo_eip+0x330>
f01054b2:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01054b6:	0f 85 de 01 00 00    	jne    f010569a <debuginfo_eip+0x330>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01054bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01054c3:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01054c6:	c1 ff 02             	sar    $0x2,%edi
f01054c9:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f01054cf:	83 e8 01             	sub    $0x1,%eax
f01054d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01054d5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01054d9:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01054e0:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01054e3:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01054e6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01054e9:	e8 4e fd ff ff       	call   f010523c <stab_binsearch>
	if (lfile == 0)
f01054ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f01054f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01054f6:	85 d2                	test   %edx,%edx
f01054f8:	0f 84 9c 01 00 00    	je     f010569a <debuginfo_eip+0x330>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01054fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0105501:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105504:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105507:	89 74 24 04          	mov    %esi,0x4(%esp)
f010550b:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105512:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105515:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105518:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010551b:	e8 1c fd ff ff       	call   f010523c <stab_binsearch>

	if (lfun <= rfun) {
f0105520:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105523:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105526:	39 d0                	cmp    %edx,%eax
f0105528:	7f 32                	jg     f010555c <debuginfo_eip+0x1f2>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010552a:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010552d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105530:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f0105533:	8b 39                	mov    (%ecx),%edi
f0105535:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0105538:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010553b:	2b 7d bc             	sub    -0x44(%ebp),%edi
f010553e:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0105541:	73 09                	jae    f010554c <debuginfo_eip+0x1e2>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105543:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105546:	03 7d bc             	add    -0x44(%ebp),%edi
f0105549:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010554c:	8b 49 08             	mov    0x8(%ecx),%ecx
f010554f:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105552:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105554:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105557:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010555a:	eb 0f                	jmp    f010556b <debuginfo_eip+0x201>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010555c:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010555f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105562:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105565:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105568:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010556b:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105572:	00 
f0105573:	8b 43 08             	mov    0x8(%ebx),%eax
f0105576:	89 04 24             	mov    %eax,(%esp)
f0105579:	e8 6c 09 00 00       	call   f0105eea <strfind>
f010557e:	2b 43 08             	sub    0x8(%ebx),%eax
f0105581:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105584:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105588:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010558f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105592:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105595:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105598:	e8 9f fc ff ff       	call   f010523c <stab_binsearch>
	if(lline == rline)
f010559d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01055a0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01055a3:	75 10                	jne    f01055b5 <debuginfo_eip+0x24b>
		info->eip_line = stabs[lline].n_desc;
f01055a5:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01055a8:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01055ab:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f01055b0:	89 43 04             	mov    %eax,0x4(%ebx)
f01055b3:	eb 07                	jmp    f01055bc <debuginfo_eip+0x252>
	else
		info->eip_line = -1 ;
f01055b5:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01055bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01055bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01055c2:	89 7d b8             	mov    %edi,-0x48(%ebp)
f01055c5:	39 f8                	cmp    %edi,%eax
f01055c7:	7c 75                	jl     f010563e <debuginfo_eip+0x2d4>
	       && stabs[lline].n_type != N_SOL
f01055c9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01055cc:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01055cf:	8d 34 97             	lea    (%edi,%edx,4),%esi
f01055d2:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f01055d6:	80 f9 84             	cmp    $0x84,%cl
f01055d9:	74 46                	je     f0105621 <debuginfo_eip+0x2b7>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01055db:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f01055df:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01055e2:	89 c7                	mov    %eax,%edi
f01055e4:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f01055e7:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01055ea:	eb 1f                	jmp    f010560b <debuginfo_eip+0x2a1>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01055ec:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01055ef:	39 c3                	cmp    %eax,%ebx
f01055f1:	7f 48                	jg     f010563b <debuginfo_eip+0x2d1>
	       && stabs[lline].n_type != N_SOL
f01055f3:	89 d6                	mov    %edx,%esi
f01055f5:	83 ea 0c             	sub    $0xc,%edx
f01055f8:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f01055fc:	80 f9 84             	cmp    $0x84,%cl
f01055ff:	75 08                	jne    f0105609 <debuginfo_eip+0x29f>
f0105601:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0105604:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105607:	eb 18                	jmp    f0105621 <debuginfo_eip+0x2b7>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105609:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010560b:	80 f9 64             	cmp    $0x64,%cl
f010560e:	75 dc                	jne    f01055ec <debuginfo_eip+0x282>
f0105610:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0105614:	74 d6                	je     f01055ec <debuginfo_eip+0x282>
f0105616:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0105619:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010561c:	3b 45 b8             	cmp    -0x48(%ebp),%eax
f010561f:	7c 1d                	jl     f010563e <debuginfo_eip+0x2d4>
f0105621:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105624:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105627:	8b 04 86             	mov    (%esi,%eax,4),%eax
f010562a:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010562d:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105630:	39 d0                	cmp    %edx,%eax
f0105632:	73 0a                	jae    f010563e <debuginfo_eip+0x2d4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105634:	03 45 bc             	add    -0x44(%ebp),%eax
f0105637:	89 03                	mov    %eax,(%ebx)
f0105639:	eb 03                	jmp    f010563e <debuginfo_eip+0x2d4>
f010563b:	8b 5d b4             	mov    -0x4c(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010563e:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105641:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105644:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105647:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010564c:	3b 7d bc             	cmp    -0x44(%ebp),%edi
f010564f:	7d 49                	jge    f010569a <debuginfo_eip+0x330>
		for (lline = lfun + 1;
f0105651:	8d 57 01             	lea    0x1(%edi),%edx
f0105654:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105657:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f010565a:	7e 3e                	jle    f010569a <debuginfo_eip+0x330>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010565c:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f010565f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105662:	80 7c 8e 04 a0       	cmpb   $0xa0,0x4(%esi,%ecx,4)
f0105667:	75 31                	jne    f010569a <debuginfo_eip+0x330>
f0105669:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010566c:	8d 44 86 1c          	lea    0x1c(%esi,%eax,4),%eax
f0105670:	8b 4d bc             	mov    -0x44(%ebp),%ecx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105673:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105677:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010567a:	39 d1                	cmp    %edx,%ecx
f010567c:	7e 17                	jle    f0105695 <debuginfo_eip+0x32b>
f010567e:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105681:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0105685:	74 ec                	je     f0105673 <debuginfo_eip+0x309>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105687:	b8 00 00 00 00       	mov    $0x0,%eax
f010568c:	eb 0c                	jmp    f010569a <debuginfo_eip+0x330>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv,stabs,stab_end -stabs,PTE_U)<0 ||
				user_mem_check(curenv,stabstr,stabstr_end - stabstr,PTE_U)<0)
			return -1;
f010568e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105693:	eb 05                	jmp    f010569a <debuginfo_eip+0x330>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105695:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010569a:	83 c4 5c             	add    $0x5c,%esp
f010569d:	5b                   	pop    %ebx
f010569e:	5e                   	pop    %esi
f010569f:	5f                   	pop    %edi
f01056a0:	5d                   	pop    %ebp
f01056a1:	c3                   	ret    
	...

f01056b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01056b0:	55                   	push   %ebp
f01056b1:	89 e5                	mov    %esp,%ebp
f01056b3:	57                   	push   %edi
f01056b4:	56                   	push   %esi
f01056b5:	53                   	push   %ebx
f01056b6:	83 ec 3c             	sub    $0x3c,%esp
f01056b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01056bc:	89 d7                	mov    %edx,%edi
f01056be:	8b 45 08             	mov    0x8(%ebp),%eax
f01056c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01056c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01056ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01056cd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01056d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01056d5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01056d8:	72 11                	jb     f01056eb <printnum+0x3b>
f01056da:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01056dd:	39 45 10             	cmp    %eax,0x10(%ebp)
f01056e0:	76 09                	jbe    f01056eb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01056e2:	83 eb 01             	sub    $0x1,%ebx
f01056e5:	85 db                	test   %ebx,%ebx
f01056e7:	7f 51                	jg     f010573a <printnum+0x8a>
f01056e9:	eb 5e                	jmp    f0105749 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01056eb:	89 74 24 10          	mov    %esi,0x10(%esp)
f01056ef:	83 eb 01             	sub    $0x1,%ebx
f01056f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01056f6:	8b 45 10             	mov    0x10(%ebp),%eax
f01056f9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01056fd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105701:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105705:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010570c:	00 
f010570d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105710:	89 04 24             	mov    %eax,(%esp)
f0105713:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105716:	89 44 24 04          	mov    %eax,0x4(%esp)
f010571a:	e8 11 13 00 00       	call   f0106a30 <__udivdi3>
f010571f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105723:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105727:	89 04 24             	mov    %eax,(%esp)
f010572a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010572e:	89 fa                	mov    %edi,%edx
f0105730:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105733:	e8 78 ff ff ff       	call   f01056b0 <printnum>
f0105738:	eb 0f                	jmp    f0105749 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010573a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010573e:	89 34 24             	mov    %esi,(%esp)
f0105741:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105744:	83 eb 01             	sub    $0x1,%ebx
f0105747:	75 f1                	jne    f010573a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105749:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010574d:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105751:	8b 45 10             	mov    0x10(%ebp),%eax
f0105754:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105758:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010575f:	00 
f0105760:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105763:	89 04 24             	mov    %eax,(%esp)
f0105766:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105769:	89 44 24 04          	mov    %eax,0x4(%esp)
f010576d:	e8 ee 13 00 00       	call   f0106b60 <__umoddi3>
f0105772:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105776:	0f be 80 72 84 10 f0 	movsbl -0xfef7b8e(%eax),%eax
f010577d:	89 04 24             	mov    %eax,(%esp)
f0105780:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105783:	83 c4 3c             	add    $0x3c,%esp
f0105786:	5b                   	pop    %ebx
f0105787:	5e                   	pop    %esi
f0105788:	5f                   	pop    %edi
f0105789:	5d                   	pop    %ebp
f010578a:	c3                   	ret    

f010578b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010578b:	55                   	push   %ebp
f010578c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010578e:	83 fa 01             	cmp    $0x1,%edx
f0105791:	7e 0e                	jle    f01057a1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105793:	8b 10                	mov    (%eax),%edx
f0105795:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105798:	89 08                	mov    %ecx,(%eax)
f010579a:	8b 02                	mov    (%edx),%eax
f010579c:	8b 52 04             	mov    0x4(%edx),%edx
f010579f:	eb 22                	jmp    f01057c3 <getuint+0x38>
	else if (lflag)
f01057a1:	85 d2                	test   %edx,%edx
f01057a3:	74 10                	je     f01057b5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01057a5:	8b 10                	mov    (%eax),%edx
f01057a7:	8d 4a 04             	lea    0x4(%edx),%ecx
f01057aa:	89 08                	mov    %ecx,(%eax)
f01057ac:	8b 02                	mov    (%edx),%eax
f01057ae:	ba 00 00 00 00       	mov    $0x0,%edx
f01057b3:	eb 0e                	jmp    f01057c3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01057b5:	8b 10                	mov    (%eax),%edx
f01057b7:	8d 4a 04             	lea    0x4(%edx),%ecx
f01057ba:	89 08                	mov    %ecx,(%eax)
f01057bc:	8b 02                	mov    (%edx),%eax
f01057be:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01057c3:	5d                   	pop    %ebp
f01057c4:	c3                   	ret    

f01057c5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f01057c5:	55                   	push   %ebp
f01057c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01057c8:	83 fa 01             	cmp    $0x1,%edx
f01057cb:	7e 0e                	jle    f01057db <getint+0x16>
		return va_arg(*ap, long long);
f01057cd:	8b 10                	mov    (%eax),%edx
f01057cf:	8d 4a 08             	lea    0x8(%edx),%ecx
f01057d2:	89 08                	mov    %ecx,(%eax)
f01057d4:	8b 02                	mov    (%edx),%eax
f01057d6:	8b 52 04             	mov    0x4(%edx),%edx
f01057d9:	eb 22                	jmp    f01057fd <getint+0x38>
	else if (lflag)
f01057db:	85 d2                	test   %edx,%edx
f01057dd:	74 10                	je     f01057ef <getint+0x2a>
		return va_arg(*ap, long);
f01057df:	8b 10                	mov    (%eax),%edx
f01057e1:	8d 4a 04             	lea    0x4(%edx),%ecx
f01057e4:	89 08                	mov    %ecx,(%eax)
f01057e6:	8b 02                	mov    (%edx),%eax
f01057e8:	89 c2                	mov    %eax,%edx
f01057ea:	c1 fa 1f             	sar    $0x1f,%edx
f01057ed:	eb 0e                	jmp    f01057fd <getint+0x38>
	else
		return va_arg(*ap, int);
f01057ef:	8b 10                	mov    (%eax),%edx
f01057f1:	8d 4a 04             	lea    0x4(%edx),%ecx
f01057f4:	89 08                	mov    %ecx,(%eax)
f01057f6:	8b 02                	mov    (%edx),%eax
f01057f8:	89 c2                	mov    %eax,%edx
f01057fa:	c1 fa 1f             	sar    $0x1f,%edx
}
f01057fd:	5d                   	pop    %ebp
f01057fe:	c3                   	ret    

f01057ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01057ff:	55                   	push   %ebp
f0105800:	89 e5                	mov    %esp,%ebp
f0105802:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105805:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105809:	8b 10                	mov    (%eax),%edx
f010580b:	3b 50 04             	cmp    0x4(%eax),%edx
f010580e:	73 0a                	jae    f010581a <sprintputch+0x1b>
		*b->buf++ = ch;
f0105810:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105813:	88 0a                	mov    %cl,(%edx)
f0105815:	83 c2 01             	add    $0x1,%edx
f0105818:	89 10                	mov    %edx,(%eax)
}
f010581a:	5d                   	pop    %ebp
f010581b:	c3                   	ret    

f010581c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010581c:	55                   	push   %ebp
f010581d:	89 e5                	mov    %esp,%ebp
f010581f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105822:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105825:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105829:	8b 45 10             	mov    0x10(%ebp),%eax
f010582c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105830:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105833:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105837:	8b 45 08             	mov    0x8(%ebp),%eax
f010583a:	89 04 24             	mov    %eax,(%esp)
f010583d:	e8 02 00 00 00       	call   f0105844 <vprintfmt>
	va_end(ap);
}
f0105842:	c9                   	leave  
f0105843:	c3                   	ret    

f0105844 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105844:	55                   	push   %ebp
f0105845:	89 e5                	mov    %esp,%ebp
f0105847:	57                   	push   %edi
f0105848:	56                   	push   %esi
f0105849:	53                   	push   %ebx
f010584a:	83 ec 4c             	sub    $0x4c,%esp
f010584d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105850:	8b 75 10             	mov    0x10(%ebp),%esi
f0105853:	eb 12                	jmp    f0105867 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105855:	85 c0                	test   %eax,%eax
f0105857:	0f 84 77 03 00 00    	je     f0105bd4 <vprintfmt+0x390>
				return;
			putch(ch, putdat);
f010585d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105861:	89 04 24             	mov    %eax,(%esp)
f0105864:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105867:	0f b6 06             	movzbl (%esi),%eax
f010586a:	83 c6 01             	add    $0x1,%esi
f010586d:	83 f8 25             	cmp    $0x25,%eax
f0105870:	75 e3                	jne    f0105855 <vprintfmt+0x11>
f0105872:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105876:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010587d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105882:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105889:	b9 00 00 00 00       	mov    $0x0,%ecx
f010588e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105891:	eb 2b                	jmp    f01058be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105893:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105896:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f010589a:	eb 22                	jmp    f01058be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010589c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010589f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01058a3:	eb 19                	jmp    f01058be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01058a8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01058af:	eb 0d                	jmp    f01058be <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01058b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01058b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058b7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058be:	0f b6 06             	movzbl (%esi),%eax
f01058c1:	0f b6 d0             	movzbl %al,%edx
f01058c4:	8d 7e 01             	lea    0x1(%esi),%edi
f01058c7:	89 7d e0             	mov    %edi,-0x20(%ebp)
f01058ca:	83 e8 23             	sub    $0x23,%eax
f01058cd:	3c 55                	cmp    $0x55,%al
f01058cf:	0f 87 d9 02 00 00    	ja     f0105bae <vprintfmt+0x36a>
f01058d5:	0f b6 c0             	movzbl %al,%eax
f01058d8:	ff 24 85 40 85 10 f0 	jmp    *-0xfef7ac0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01058df:	83 ea 30             	sub    $0x30,%edx
f01058e2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f01058e5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f01058e9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f01058ef:	83 fa 09             	cmp    $0x9,%edx
f01058f2:	77 4a                	ja     f010593e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01058f7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f01058fa:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f01058fd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0105901:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105904:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105907:	83 fa 09             	cmp    $0x9,%edx
f010590a:	76 eb                	jbe    f01058f7 <vprintfmt+0xb3>
f010590c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010590f:	eb 2d                	jmp    f010593e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105911:	8b 45 14             	mov    0x14(%ebp),%eax
f0105914:	8d 50 04             	lea    0x4(%eax),%edx
f0105917:	89 55 14             	mov    %edx,0x14(%ebp)
f010591a:	8b 00                	mov    (%eax),%eax
f010591c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010591f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105922:	eb 1a                	jmp    f010593e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105924:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0105927:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010592b:	79 91                	jns    f01058be <vprintfmt+0x7a>
f010592d:	e9 73 ff ff ff       	jmp    f01058a5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105932:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105935:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f010593c:	eb 80                	jmp    f01058be <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f010593e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105942:	0f 89 76 ff ff ff    	jns    f01058be <vprintfmt+0x7a>
f0105948:	e9 64 ff ff ff       	jmp    f01058b1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010594d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105950:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105953:	e9 66 ff ff ff       	jmp    f01058be <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105958:	8b 45 14             	mov    0x14(%ebp),%eax
f010595b:	8d 50 04             	lea    0x4(%eax),%edx
f010595e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105965:	8b 00                	mov    (%eax),%eax
f0105967:	89 04 24             	mov    %eax,(%esp)
f010596a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010596d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105970:	e9 f2 fe ff ff       	jmp    f0105867 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105975:	8b 45 14             	mov    0x14(%ebp),%eax
f0105978:	8d 50 04             	lea    0x4(%eax),%edx
f010597b:	89 55 14             	mov    %edx,0x14(%ebp)
f010597e:	8b 00                	mov    (%eax),%eax
f0105980:	89 c2                	mov    %eax,%edx
f0105982:	c1 fa 1f             	sar    $0x1f,%edx
f0105985:	31 d0                	xor    %edx,%eax
f0105987:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105989:	83 f8 08             	cmp    $0x8,%eax
f010598c:	7f 0b                	jg     f0105999 <vprintfmt+0x155>
f010598e:	8b 14 85 a0 86 10 f0 	mov    -0xfef7960(,%eax,4),%edx
f0105995:	85 d2                	test   %edx,%edx
f0105997:	75 23                	jne    f01059bc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0105999:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010599d:	c7 44 24 08 8a 84 10 	movl   $0xf010848a,0x8(%esp)
f01059a4:	f0 
f01059a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01059a9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01059ac:	89 3c 24             	mov    %edi,(%esp)
f01059af:	e8 68 fe ff ff       	call   f010581c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01059b7:	e9 ab fe ff ff       	jmp    f0105867 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01059bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01059c0:	c7 44 24 08 d1 7b 10 	movl   $0xf0107bd1,0x8(%esp)
f01059c7:	f0 
f01059c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01059cc:	8b 7d 08             	mov    0x8(%ebp),%edi
f01059cf:	89 3c 24             	mov    %edi,(%esp)
f01059d2:	e8 45 fe ff ff       	call   f010581c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01059da:	e9 88 fe ff ff       	jmp    f0105867 <vprintfmt+0x23>
f01059df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01059e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01059e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01059eb:	8d 50 04             	lea    0x4(%eax),%edx
f01059ee:	89 55 14             	mov    %edx,0x14(%ebp)
f01059f1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01059f3:	85 f6                	test   %esi,%esi
f01059f5:	ba 83 84 10 f0       	mov    $0xf0108483,%edx
f01059fa:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f01059fd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105a01:	7e 06                	jle    f0105a09 <vprintfmt+0x1c5>
f0105a03:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105a07:	75 10                	jne    f0105a19 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105a09:	0f be 06             	movsbl (%esi),%eax
f0105a0c:	83 c6 01             	add    $0x1,%esi
f0105a0f:	85 c0                	test   %eax,%eax
f0105a11:	0f 85 86 00 00 00    	jne    f0105a9d <vprintfmt+0x259>
f0105a17:	eb 76                	jmp    f0105a8f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a19:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a1d:	89 34 24             	mov    %esi,(%esp)
f0105a20:	e8 26 03 00 00       	call   f0105d4b <strnlen>
f0105a25:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105a28:	29 c2                	sub    %eax,%edx
f0105a2a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105a2d:	85 d2                	test   %edx,%edx
f0105a2f:	7e d8                	jle    f0105a09 <vprintfmt+0x1c5>
					putch(padc, putdat);
f0105a31:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105a35:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0105a38:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0105a3b:	89 d6                	mov    %edx,%esi
f0105a3d:	89 c7                	mov    %eax,%edi
f0105a3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a43:	89 3c 24             	mov    %edi,(%esp)
f0105a46:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a49:	83 ee 01             	sub    $0x1,%esi
f0105a4c:	75 f1                	jne    f0105a3f <vprintfmt+0x1fb>
f0105a4e:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0105a51:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0105a54:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0105a57:	eb b0                	jmp    f0105a09 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105a59:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105a5d:	74 18                	je     f0105a77 <vprintfmt+0x233>
f0105a5f:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105a62:	83 fa 5e             	cmp    $0x5e,%edx
f0105a65:	76 10                	jbe    f0105a77 <vprintfmt+0x233>
					putch('?', putdat);
f0105a67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a6b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105a72:	ff 55 08             	call   *0x8(%ebp)
f0105a75:	eb 0a                	jmp    f0105a81 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
f0105a77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a7b:	89 04 24             	mov    %eax,(%esp)
f0105a7e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105a81:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0105a85:	0f be 06             	movsbl (%esi),%eax
f0105a88:	83 c6 01             	add    $0x1,%esi
f0105a8b:	85 c0                	test   %eax,%eax
f0105a8d:	75 0e                	jne    f0105a9d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a8f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105a92:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105a96:	7f 11                	jg     f0105aa9 <vprintfmt+0x265>
f0105a98:	e9 ca fd ff ff       	jmp    f0105867 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105a9d:	85 ff                	test   %edi,%edi
f0105a9f:	90                   	nop
f0105aa0:	78 b7                	js     f0105a59 <vprintfmt+0x215>
f0105aa2:	83 ef 01             	sub    $0x1,%edi
f0105aa5:	79 b2                	jns    f0105a59 <vprintfmt+0x215>
f0105aa7:	eb e6                	jmp    f0105a8f <vprintfmt+0x24b>
f0105aa9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105aac:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105aaf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ab3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105aba:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105abc:	83 ee 01             	sub    $0x1,%esi
f0105abf:	75 ee                	jne    f0105aaf <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ac1:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105ac4:	e9 9e fd ff ff       	jmp    f0105867 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105ac9:	89 ca                	mov    %ecx,%edx
f0105acb:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ace:	e8 f2 fc ff ff       	call   f01057c5 <getint>
f0105ad3:	89 c6                	mov    %eax,%esi
f0105ad5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105ad7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105adc:	85 d2                	test   %edx,%edx
f0105ade:	0f 89 8c 00 00 00    	jns    f0105b70 <vprintfmt+0x32c>
				putch('-', putdat);
f0105ae4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ae8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105aef:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105af2:	f7 de                	neg    %esi
f0105af4:	83 d7 00             	adc    $0x0,%edi
f0105af7:	f7 df                	neg    %edi
			}
			base = 10;
f0105af9:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105afe:	eb 70                	jmp    f0105b70 <vprintfmt+0x32c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105b00:	89 ca                	mov    %ecx,%edx
f0105b02:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b05:	e8 81 fc ff ff       	call   f010578b <getuint>
f0105b0a:	89 c6                	mov    %eax,%esi
f0105b0c:	89 d7                	mov    %edx,%edi
			base = 10;
f0105b0e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105b13:	eb 5b                	jmp    f0105b70 <vprintfmt+0x32c>

		// (unsigned) octal
		case 'o':
			num = getint(&ap,lflag);
f0105b15:	89 ca                	mov    %ecx,%edx
f0105b17:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b1a:	e8 a6 fc ff ff       	call   f01057c5 <getint>
f0105b1f:	89 c6                	mov    %eax,%esi
f0105b21:	89 d7                	mov    %edx,%edi
			base = 8;
f0105b23:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0105b28:	eb 46                	jmp    f0105b70 <vprintfmt+0x32c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0105b2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b2e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105b35:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105b38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b3c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105b43:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105b46:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b49:	8d 50 04             	lea    0x4(%eax),%edx
f0105b4c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105b4f:	8b 30                	mov    (%eax),%esi
f0105b51:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105b56:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105b5b:	eb 13                	jmp    f0105b70 <vprintfmt+0x32c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105b5d:	89 ca                	mov    %ecx,%edx
f0105b5f:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b62:	e8 24 fc ff ff       	call   f010578b <getuint>
f0105b67:	89 c6                	mov    %eax,%esi
f0105b69:	89 d7                	mov    %edx,%edi
			base = 16;
f0105b6b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105b70:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0105b74:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105b78:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105b7b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105b7f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b83:	89 34 24             	mov    %esi,(%esp)
f0105b86:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b8a:	89 da                	mov    %ebx,%edx
f0105b8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b8f:	e8 1c fb ff ff       	call   f01056b0 <printnum>
			break;
f0105b94:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105b97:	e9 cb fc ff ff       	jmp    f0105867 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105b9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ba0:	89 14 24             	mov    %edx,(%esp)
f0105ba3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ba6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105ba9:	e9 b9 fc ff ff       	jmp    f0105867 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105bae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105bb2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105bb9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105bbc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105bc0:	0f 84 a1 fc ff ff    	je     f0105867 <vprintfmt+0x23>
f0105bc6:	83 ee 01             	sub    $0x1,%esi
f0105bc9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105bcd:	75 f7                	jne    f0105bc6 <vprintfmt+0x382>
f0105bcf:	e9 93 fc ff ff       	jmp    f0105867 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105bd4:	83 c4 4c             	add    $0x4c,%esp
f0105bd7:	5b                   	pop    %ebx
f0105bd8:	5e                   	pop    %esi
f0105bd9:	5f                   	pop    %edi
f0105bda:	5d                   	pop    %ebp
f0105bdb:	c3                   	ret    

f0105bdc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105bdc:	55                   	push   %ebp
f0105bdd:	89 e5                	mov    %esp,%ebp
f0105bdf:	83 ec 28             	sub    $0x28,%esp
f0105be2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105be5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105be8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105beb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105bef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105bf2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105bf9:	85 c0                	test   %eax,%eax
f0105bfb:	74 30                	je     f0105c2d <vsnprintf+0x51>
f0105bfd:	85 d2                	test   %edx,%edx
f0105bff:	7e 2c                	jle    f0105c2d <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105c01:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c04:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c08:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c0b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c0f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105c12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c16:	c7 04 24 ff 57 10 f0 	movl   $0xf01057ff,(%esp)
f0105c1d:	e8 22 fc ff ff       	call   f0105844 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105c22:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105c25:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105c2b:	eb 05                	jmp    f0105c32 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105c2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105c32:	c9                   	leave  
f0105c33:	c3                   	ret    

f0105c34 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105c34:	55                   	push   %ebp
f0105c35:	89 e5                	mov    %esp,%ebp
f0105c37:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105c3a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105c3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c41:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c44:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c48:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c52:	89 04 24             	mov    %eax,(%esp)
f0105c55:	e8 82 ff ff ff       	call   f0105bdc <vsnprintf>
	va_end(ap);

	return rc;
}
f0105c5a:	c9                   	leave  
f0105c5b:	c3                   	ret    
f0105c5c:	00 00                	add    %al,(%eax)
	...

f0105c60 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105c60:	55                   	push   %ebp
f0105c61:	89 e5                	mov    %esp,%ebp
f0105c63:	57                   	push   %edi
f0105c64:	56                   	push   %esi
f0105c65:	53                   	push   %ebx
f0105c66:	83 ec 1c             	sub    $0x1c,%esp
f0105c69:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105c6c:	85 c0                	test   %eax,%eax
f0105c6e:	74 10                	je     f0105c80 <readline+0x20>
		cprintf("%s", prompt);
f0105c70:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c74:	c7 04 24 d1 7b 10 f0 	movl   $0xf0107bd1,(%esp)
f0105c7b:	e8 56 e4 ff ff       	call   f01040d6 <cprintf>

	i = 0;
	echoing = iscons(0);
f0105c80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105c87:	e8 65 ab ff ff       	call   f01007f1 <iscons>
f0105c8c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105c8e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105c93:	e8 48 ab ff ff       	call   f01007e0 <getchar>
f0105c98:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105c9a:	85 c0                	test   %eax,%eax
f0105c9c:	79 17                	jns    f0105cb5 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ca2:	c7 04 24 c4 86 10 f0 	movl   $0xf01086c4,(%esp)
f0105ca9:	e8 28 e4 ff ff       	call   f01040d6 <cprintf>
			return NULL;
f0105cae:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cb3:	eb 6d                	jmp    f0105d22 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105cb5:	83 f8 08             	cmp    $0x8,%eax
f0105cb8:	74 05                	je     f0105cbf <readline+0x5f>
f0105cba:	83 f8 7f             	cmp    $0x7f,%eax
f0105cbd:	75 19                	jne    f0105cd8 <readline+0x78>
f0105cbf:	85 f6                	test   %esi,%esi
f0105cc1:	7e 15                	jle    f0105cd8 <readline+0x78>
			if (echoing)
f0105cc3:	85 ff                	test   %edi,%edi
f0105cc5:	74 0c                	je     f0105cd3 <readline+0x73>
				cputchar('\b');
f0105cc7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105cce:	e8 fd aa ff ff       	call   f01007d0 <cputchar>
			i--;
f0105cd3:	83 ee 01             	sub    $0x1,%esi
f0105cd6:	eb bb                	jmp    f0105c93 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105cd8:	83 fb 1f             	cmp    $0x1f,%ebx
f0105cdb:	7e 1f                	jle    f0105cfc <readline+0x9c>
f0105cdd:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105ce3:	7f 17                	jg     f0105cfc <readline+0x9c>
			if (echoing)
f0105ce5:	85 ff                	test   %edi,%edi
f0105ce7:	74 08                	je     f0105cf1 <readline+0x91>
				cputchar(c);
f0105ce9:	89 1c 24             	mov    %ebx,(%esp)
f0105cec:	e8 df aa ff ff       	call   f01007d0 <cputchar>
			buf[i++] = c;
f0105cf1:	88 9e 80 ba 22 f0    	mov    %bl,-0xfdd4580(%esi)
f0105cf7:	83 c6 01             	add    $0x1,%esi
f0105cfa:	eb 97                	jmp    f0105c93 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105cfc:	83 fb 0a             	cmp    $0xa,%ebx
f0105cff:	74 05                	je     f0105d06 <readline+0xa6>
f0105d01:	83 fb 0d             	cmp    $0xd,%ebx
f0105d04:	75 8d                	jne    f0105c93 <readline+0x33>
			if (echoing)
f0105d06:	85 ff                	test   %edi,%edi
f0105d08:	74 0c                	je     f0105d16 <readline+0xb6>
				cputchar('\n');
f0105d0a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105d11:	e8 ba aa ff ff       	call   f01007d0 <cputchar>
			buf[i] = 0;
f0105d16:	c6 86 80 ba 22 f0 00 	movb   $0x0,-0xfdd4580(%esi)
			return buf;
f0105d1d:	b8 80 ba 22 f0       	mov    $0xf022ba80,%eax
		}
	}
}
f0105d22:	83 c4 1c             	add    $0x1c,%esp
f0105d25:	5b                   	pop    %ebx
f0105d26:	5e                   	pop    %esi
f0105d27:	5f                   	pop    %edi
f0105d28:	5d                   	pop    %ebp
f0105d29:	c3                   	ret    
f0105d2a:	00 00                	add    %al,(%eax)
f0105d2c:	00 00                	add    %al,(%eax)
	...

f0105d30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105d30:	55                   	push   %ebp
f0105d31:	89 e5                	mov    %esp,%ebp
f0105d33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105d36:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d3b:	80 3a 00             	cmpb   $0x0,(%edx)
f0105d3e:	74 09                	je     f0105d49 <strlen+0x19>
		n++;
f0105d40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105d43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105d47:	75 f7                	jne    f0105d40 <strlen+0x10>
		n++;
	return n;
}
f0105d49:	5d                   	pop    %ebp
f0105d4a:	c3                   	ret    

f0105d4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105d4b:	55                   	push   %ebp
f0105d4c:	89 e5                	mov    %esp,%ebp
f0105d4e:	53                   	push   %ebx
f0105d4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105d55:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d5a:	85 c9                	test   %ecx,%ecx
f0105d5c:	74 1a                	je     f0105d78 <strnlen+0x2d>
f0105d5e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0105d61:	74 15                	je     f0105d78 <strnlen+0x2d>
f0105d63:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0105d68:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105d6a:	39 ca                	cmp    %ecx,%edx
f0105d6c:	74 0a                	je     f0105d78 <strnlen+0x2d>
f0105d6e:	83 c2 01             	add    $0x1,%edx
f0105d71:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0105d76:	75 f0                	jne    f0105d68 <strnlen+0x1d>
		n++;
	return n;
}
f0105d78:	5b                   	pop    %ebx
f0105d79:	5d                   	pop    %ebp
f0105d7a:	c3                   	ret    

f0105d7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105d7b:	55                   	push   %ebp
f0105d7c:	89 e5                	mov    %esp,%ebp
f0105d7e:	53                   	push   %ebx
f0105d7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105d85:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d8a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105d8e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105d91:	83 c2 01             	add    $0x1,%edx
f0105d94:	84 c9                	test   %cl,%cl
f0105d96:	75 f2                	jne    f0105d8a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105d98:	5b                   	pop    %ebx
f0105d99:	5d                   	pop    %ebp
f0105d9a:	c3                   	ret    

f0105d9b <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105d9b:	55                   	push   %ebp
f0105d9c:	89 e5                	mov    %esp,%ebp
f0105d9e:	53                   	push   %ebx
f0105d9f:	83 ec 08             	sub    $0x8,%esp
f0105da2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105da5:	89 1c 24             	mov    %ebx,(%esp)
f0105da8:	e8 83 ff ff ff       	call   f0105d30 <strlen>
	strcpy(dst + len, src);
f0105dad:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105db0:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105db4:	01 d8                	add    %ebx,%eax
f0105db6:	89 04 24             	mov    %eax,(%esp)
f0105db9:	e8 bd ff ff ff       	call   f0105d7b <strcpy>
	return dst;
}
f0105dbe:	89 d8                	mov    %ebx,%eax
f0105dc0:	83 c4 08             	add    $0x8,%esp
f0105dc3:	5b                   	pop    %ebx
f0105dc4:	5d                   	pop    %ebp
f0105dc5:	c3                   	ret    

f0105dc6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105dc6:	55                   	push   %ebp
f0105dc7:	89 e5                	mov    %esp,%ebp
f0105dc9:	56                   	push   %esi
f0105dca:	53                   	push   %ebx
f0105dcb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dce:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105dd1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105dd4:	85 f6                	test   %esi,%esi
f0105dd6:	74 18                	je     f0105df0 <strncpy+0x2a>
f0105dd8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0105ddd:	0f b6 1a             	movzbl (%edx),%ebx
f0105de0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105de3:	80 3a 01             	cmpb   $0x1,(%edx)
f0105de6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105de9:	83 c1 01             	add    $0x1,%ecx
f0105dec:	39 f1                	cmp    %esi,%ecx
f0105dee:	75 ed                	jne    f0105ddd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105df0:	5b                   	pop    %ebx
f0105df1:	5e                   	pop    %esi
f0105df2:	5d                   	pop    %ebp
f0105df3:	c3                   	ret    

f0105df4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105df4:	55                   	push   %ebp
f0105df5:	89 e5                	mov    %esp,%ebp
f0105df7:	57                   	push   %edi
f0105df8:	56                   	push   %esi
f0105df9:	53                   	push   %ebx
f0105dfa:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105dfd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105e00:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105e03:	89 f8                	mov    %edi,%eax
f0105e05:	85 f6                	test   %esi,%esi
f0105e07:	74 2b                	je     f0105e34 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0105e09:	83 fe 01             	cmp    $0x1,%esi
f0105e0c:	74 23                	je     f0105e31 <strlcpy+0x3d>
f0105e0e:	0f b6 0b             	movzbl (%ebx),%ecx
f0105e11:	84 c9                	test   %cl,%cl
f0105e13:	74 1c                	je     f0105e31 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0105e15:	83 ee 02             	sub    $0x2,%esi
f0105e18:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105e1d:	88 08                	mov    %cl,(%eax)
f0105e1f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105e22:	39 f2                	cmp    %esi,%edx
f0105e24:	74 0b                	je     f0105e31 <strlcpy+0x3d>
f0105e26:	83 c2 01             	add    $0x1,%edx
f0105e29:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105e2d:	84 c9                	test   %cl,%cl
f0105e2f:	75 ec                	jne    f0105e1d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0105e31:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105e34:	29 f8                	sub    %edi,%eax
}
f0105e36:	5b                   	pop    %ebx
f0105e37:	5e                   	pop    %esi
f0105e38:	5f                   	pop    %edi
f0105e39:	5d                   	pop    %ebp
f0105e3a:	c3                   	ret    

f0105e3b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105e3b:	55                   	push   %ebp
f0105e3c:	89 e5                	mov    %esp,%ebp
f0105e3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e41:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105e44:	0f b6 01             	movzbl (%ecx),%eax
f0105e47:	84 c0                	test   %al,%al
f0105e49:	74 16                	je     f0105e61 <strcmp+0x26>
f0105e4b:	3a 02                	cmp    (%edx),%al
f0105e4d:	75 12                	jne    f0105e61 <strcmp+0x26>
		p++, q++;
f0105e4f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105e52:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0105e56:	84 c0                	test   %al,%al
f0105e58:	74 07                	je     f0105e61 <strcmp+0x26>
f0105e5a:	83 c1 01             	add    $0x1,%ecx
f0105e5d:	3a 02                	cmp    (%edx),%al
f0105e5f:	74 ee                	je     f0105e4f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105e61:	0f b6 c0             	movzbl %al,%eax
f0105e64:	0f b6 12             	movzbl (%edx),%edx
f0105e67:	29 d0                	sub    %edx,%eax
}
f0105e69:	5d                   	pop    %ebp
f0105e6a:	c3                   	ret    

f0105e6b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105e6b:	55                   	push   %ebp
f0105e6c:	89 e5                	mov    %esp,%ebp
f0105e6e:	53                   	push   %ebx
f0105e6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105e75:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105e78:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105e7d:	85 d2                	test   %edx,%edx
f0105e7f:	74 28                	je     f0105ea9 <strncmp+0x3e>
f0105e81:	0f b6 01             	movzbl (%ecx),%eax
f0105e84:	84 c0                	test   %al,%al
f0105e86:	74 24                	je     f0105eac <strncmp+0x41>
f0105e88:	3a 03                	cmp    (%ebx),%al
f0105e8a:	75 20                	jne    f0105eac <strncmp+0x41>
f0105e8c:	83 ea 01             	sub    $0x1,%edx
f0105e8f:	74 13                	je     f0105ea4 <strncmp+0x39>
		n--, p++, q++;
f0105e91:	83 c1 01             	add    $0x1,%ecx
f0105e94:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105e97:	0f b6 01             	movzbl (%ecx),%eax
f0105e9a:	84 c0                	test   %al,%al
f0105e9c:	74 0e                	je     f0105eac <strncmp+0x41>
f0105e9e:	3a 03                	cmp    (%ebx),%al
f0105ea0:	74 ea                	je     f0105e8c <strncmp+0x21>
f0105ea2:	eb 08                	jmp    f0105eac <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105ea4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105ea9:	5b                   	pop    %ebx
f0105eaa:	5d                   	pop    %ebp
f0105eab:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105eac:	0f b6 01             	movzbl (%ecx),%eax
f0105eaf:	0f b6 13             	movzbl (%ebx),%edx
f0105eb2:	29 d0                	sub    %edx,%eax
f0105eb4:	eb f3                	jmp    f0105ea9 <strncmp+0x3e>

f0105eb6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105eb6:	55                   	push   %ebp
f0105eb7:	89 e5                	mov    %esp,%ebp
f0105eb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ebc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105ec0:	0f b6 10             	movzbl (%eax),%edx
f0105ec3:	84 d2                	test   %dl,%dl
f0105ec5:	74 1c                	je     f0105ee3 <strchr+0x2d>
		if (*s == c)
f0105ec7:	38 ca                	cmp    %cl,%dl
f0105ec9:	75 09                	jne    f0105ed4 <strchr+0x1e>
f0105ecb:	eb 1b                	jmp    f0105ee8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105ecd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0105ed0:	38 ca                	cmp    %cl,%dl
f0105ed2:	74 14                	je     f0105ee8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105ed4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0105ed8:	84 d2                	test   %dl,%dl
f0105eda:	75 f1                	jne    f0105ecd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0105edc:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ee1:	eb 05                	jmp    f0105ee8 <strchr+0x32>
f0105ee3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ee8:	5d                   	pop    %ebp
f0105ee9:	c3                   	ret    

f0105eea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105eea:	55                   	push   %ebp
f0105eeb:	89 e5                	mov    %esp,%ebp
f0105eed:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ef0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105ef4:	0f b6 10             	movzbl (%eax),%edx
f0105ef7:	84 d2                	test   %dl,%dl
f0105ef9:	74 14                	je     f0105f0f <strfind+0x25>
		if (*s == c)
f0105efb:	38 ca                	cmp    %cl,%dl
f0105efd:	75 06                	jne    f0105f05 <strfind+0x1b>
f0105eff:	eb 0e                	jmp    f0105f0f <strfind+0x25>
f0105f01:	38 ca                	cmp    %cl,%dl
f0105f03:	74 0a                	je     f0105f0f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105f05:	83 c0 01             	add    $0x1,%eax
f0105f08:	0f b6 10             	movzbl (%eax),%edx
f0105f0b:	84 d2                	test   %dl,%dl
f0105f0d:	75 f2                	jne    f0105f01 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0105f0f:	5d                   	pop    %ebp
f0105f10:	c3                   	ret    

f0105f11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105f11:	55                   	push   %ebp
f0105f12:	89 e5                	mov    %esp,%ebp
f0105f14:	83 ec 0c             	sub    $0xc,%esp
f0105f17:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105f1a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105f1d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105f20:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f23:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105f29:	85 c9                	test   %ecx,%ecx
f0105f2b:	74 30                	je     f0105f5d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105f2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105f33:	75 25                	jne    f0105f5a <memset+0x49>
f0105f35:	f6 c1 03             	test   $0x3,%cl
f0105f38:	75 20                	jne    f0105f5a <memset+0x49>
		c &= 0xFF;
f0105f3a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105f3d:	89 d3                	mov    %edx,%ebx
f0105f3f:	c1 e3 08             	shl    $0x8,%ebx
f0105f42:	89 d6                	mov    %edx,%esi
f0105f44:	c1 e6 18             	shl    $0x18,%esi
f0105f47:	89 d0                	mov    %edx,%eax
f0105f49:	c1 e0 10             	shl    $0x10,%eax
f0105f4c:	09 f0                	or     %esi,%eax
f0105f4e:	09 d0                	or     %edx,%eax
f0105f50:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105f52:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105f55:	fc                   	cld    
f0105f56:	f3 ab                	rep stos %eax,%es:(%edi)
f0105f58:	eb 03                	jmp    f0105f5d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105f5a:	fc                   	cld    
f0105f5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105f5d:	89 f8                	mov    %edi,%eax
f0105f5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105f62:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105f65:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105f68:	89 ec                	mov    %ebp,%esp
f0105f6a:	5d                   	pop    %ebp
f0105f6b:	c3                   	ret    

f0105f6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105f6c:	55                   	push   %ebp
f0105f6d:	89 e5                	mov    %esp,%ebp
f0105f6f:	83 ec 08             	sub    $0x8,%esp
f0105f72:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105f75:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105f78:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f7b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105f81:	39 c6                	cmp    %eax,%esi
f0105f83:	73 36                	jae    f0105fbb <memmove+0x4f>
f0105f85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105f88:	39 d0                	cmp    %edx,%eax
f0105f8a:	73 2f                	jae    f0105fbb <memmove+0x4f>
		s += n;
		d += n;
f0105f8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105f8f:	f6 c2 03             	test   $0x3,%dl
f0105f92:	75 1b                	jne    f0105faf <memmove+0x43>
f0105f94:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105f9a:	75 13                	jne    f0105faf <memmove+0x43>
f0105f9c:	f6 c1 03             	test   $0x3,%cl
f0105f9f:	75 0e                	jne    f0105faf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105fa1:	83 ef 04             	sub    $0x4,%edi
f0105fa4:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105fa7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105faa:	fd                   	std    
f0105fab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105fad:	eb 09                	jmp    f0105fb8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105faf:	83 ef 01             	sub    $0x1,%edi
f0105fb2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105fb5:	fd                   	std    
f0105fb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105fb8:	fc                   	cld    
f0105fb9:	eb 20                	jmp    f0105fdb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105fbb:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105fc1:	75 13                	jne    f0105fd6 <memmove+0x6a>
f0105fc3:	a8 03                	test   $0x3,%al
f0105fc5:	75 0f                	jne    f0105fd6 <memmove+0x6a>
f0105fc7:	f6 c1 03             	test   $0x3,%cl
f0105fca:	75 0a                	jne    f0105fd6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105fcc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105fcf:	89 c7                	mov    %eax,%edi
f0105fd1:	fc                   	cld    
f0105fd2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105fd4:	eb 05                	jmp    f0105fdb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105fd6:	89 c7                	mov    %eax,%edi
f0105fd8:	fc                   	cld    
f0105fd9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105fdb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105fde:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105fe1:	89 ec                	mov    %ebp,%esp
f0105fe3:	5d                   	pop    %ebp
f0105fe4:	c3                   	ret    

f0105fe5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105fe5:	55                   	push   %ebp
f0105fe6:	89 e5                	mov    %esp,%ebp
f0105fe8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105feb:	8b 45 10             	mov    0x10(%ebp),%eax
f0105fee:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ff9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ffc:	89 04 24             	mov    %eax,(%esp)
f0105fff:	e8 68 ff ff ff       	call   f0105f6c <memmove>
}
f0106004:	c9                   	leave  
f0106005:	c3                   	ret    

f0106006 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106006:	55                   	push   %ebp
f0106007:	89 e5                	mov    %esp,%ebp
f0106009:	57                   	push   %edi
f010600a:	56                   	push   %esi
f010600b:	53                   	push   %ebx
f010600c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010600f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106012:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106015:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010601a:	85 ff                	test   %edi,%edi
f010601c:	74 37                	je     f0106055 <memcmp+0x4f>
		if (*s1 != *s2)
f010601e:	0f b6 03             	movzbl (%ebx),%eax
f0106021:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106024:	83 ef 01             	sub    $0x1,%edi
f0106027:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f010602c:	38 c8                	cmp    %cl,%al
f010602e:	74 1c                	je     f010604c <memcmp+0x46>
f0106030:	eb 10                	jmp    f0106042 <memcmp+0x3c>
f0106032:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0106037:	83 c2 01             	add    $0x1,%edx
f010603a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010603e:	38 c8                	cmp    %cl,%al
f0106040:	74 0a                	je     f010604c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0106042:	0f b6 c0             	movzbl %al,%eax
f0106045:	0f b6 c9             	movzbl %cl,%ecx
f0106048:	29 c8                	sub    %ecx,%eax
f010604a:	eb 09                	jmp    f0106055 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010604c:	39 fa                	cmp    %edi,%edx
f010604e:	75 e2                	jne    f0106032 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106050:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106055:	5b                   	pop    %ebx
f0106056:	5e                   	pop    %esi
f0106057:	5f                   	pop    %edi
f0106058:	5d                   	pop    %ebp
f0106059:	c3                   	ret    

f010605a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010605a:	55                   	push   %ebp
f010605b:	89 e5                	mov    %esp,%ebp
f010605d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0106060:	89 c2                	mov    %eax,%edx
f0106062:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106065:	39 d0                	cmp    %edx,%eax
f0106067:	73 19                	jae    f0106082 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106069:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f010606d:	38 08                	cmp    %cl,(%eax)
f010606f:	75 06                	jne    f0106077 <memfind+0x1d>
f0106071:	eb 0f                	jmp    f0106082 <memfind+0x28>
f0106073:	38 08                	cmp    %cl,(%eax)
f0106075:	74 0b                	je     f0106082 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106077:	83 c0 01             	add    $0x1,%eax
f010607a:	39 d0                	cmp    %edx,%eax
f010607c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106080:	75 f1                	jne    f0106073 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106082:	5d                   	pop    %ebp
f0106083:	c3                   	ret    

f0106084 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106084:	55                   	push   %ebp
f0106085:	89 e5                	mov    %esp,%ebp
f0106087:	57                   	push   %edi
f0106088:	56                   	push   %esi
f0106089:	53                   	push   %ebx
f010608a:	8b 55 08             	mov    0x8(%ebp),%edx
f010608d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106090:	0f b6 02             	movzbl (%edx),%eax
f0106093:	3c 20                	cmp    $0x20,%al
f0106095:	74 04                	je     f010609b <strtol+0x17>
f0106097:	3c 09                	cmp    $0x9,%al
f0106099:	75 0e                	jne    f01060a9 <strtol+0x25>
		s++;
f010609b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010609e:	0f b6 02             	movzbl (%edx),%eax
f01060a1:	3c 20                	cmp    $0x20,%al
f01060a3:	74 f6                	je     f010609b <strtol+0x17>
f01060a5:	3c 09                	cmp    $0x9,%al
f01060a7:	74 f2                	je     f010609b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f01060a9:	3c 2b                	cmp    $0x2b,%al
f01060ab:	75 0a                	jne    f01060b7 <strtol+0x33>
		s++;
f01060ad:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01060b0:	bf 00 00 00 00       	mov    $0x0,%edi
f01060b5:	eb 10                	jmp    f01060c7 <strtol+0x43>
f01060b7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01060bc:	3c 2d                	cmp    $0x2d,%al
f01060be:	75 07                	jne    f01060c7 <strtol+0x43>
		s++, neg = 1;
f01060c0:	83 c2 01             	add    $0x1,%edx
f01060c3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01060c7:	85 db                	test   %ebx,%ebx
f01060c9:	0f 94 c0             	sete   %al
f01060cc:	74 05                	je     f01060d3 <strtol+0x4f>
f01060ce:	83 fb 10             	cmp    $0x10,%ebx
f01060d1:	75 15                	jne    f01060e8 <strtol+0x64>
f01060d3:	80 3a 30             	cmpb   $0x30,(%edx)
f01060d6:	75 10                	jne    f01060e8 <strtol+0x64>
f01060d8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01060dc:	75 0a                	jne    f01060e8 <strtol+0x64>
		s += 2, base = 16;
f01060de:	83 c2 02             	add    $0x2,%edx
f01060e1:	bb 10 00 00 00       	mov    $0x10,%ebx
f01060e6:	eb 13                	jmp    f01060fb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f01060e8:	84 c0                	test   %al,%al
f01060ea:	74 0f                	je     f01060fb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01060ec:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01060f1:	80 3a 30             	cmpb   $0x30,(%edx)
f01060f4:	75 05                	jne    f01060fb <strtol+0x77>
		s++, base = 8;
f01060f6:	83 c2 01             	add    $0x1,%edx
f01060f9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f01060fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0106100:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106102:	0f b6 0a             	movzbl (%edx),%ecx
f0106105:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0106108:	80 fb 09             	cmp    $0x9,%bl
f010610b:	77 08                	ja     f0106115 <strtol+0x91>
			dig = *s - '0';
f010610d:	0f be c9             	movsbl %cl,%ecx
f0106110:	83 e9 30             	sub    $0x30,%ecx
f0106113:	eb 1e                	jmp    f0106133 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0106115:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0106118:	80 fb 19             	cmp    $0x19,%bl
f010611b:	77 08                	ja     f0106125 <strtol+0xa1>
			dig = *s - 'a' + 10;
f010611d:	0f be c9             	movsbl %cl,%ecx
f0106120:	83 e9 57             	sub    $0x57,%ecx
f0106123:	eb 0e                	jmp    f0106133 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0106125:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0106128:	80 fb 19             	cmp    $0x19,%bl
f010612b:	77 14                	ja     f0106141 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010612d:	0f be c9             	movsbl %cl,%ecx
f0106130:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106133:	39 f1                	cmp    %esi,%ecx
f0106135:	7d 0e                	jge    f0106145 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0106137:	83 c2 01             	add    $0x1,%edx
f010613a:	0f af c6             	imul   %esi,%eax
f010613d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010613f:	eb c1                	jmp    f0106102 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0106141:	89 c1                	mov    %eax,%ecx
f0106143:	eb 02                	jmp    f0106147 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0106145:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0106147:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010614b:	74 05                	je     f0106152 <strtol+0xce>
		*endptr = (char *) s;
f010614d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106150:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0106152:	89 ca                	mov    %ecx,%edx
f0106154:	f7 da                	neg    %edx
f0106156:	85 ff                	test   %edi,%edi
f0106158:	0f 45 c2             	cmovne %edx,%eax
}
f010615b:	5b                   	pop    %ebx
f010615c:	5e                   	pop    %esi
f010615d:	5f                   	pop    %edi
f010615e:	5d                   	pop    %ebp
f010615f:	c3                   	ret    

f0106160 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106160:	fa                   	cli    

	xorw    %ax, %ax
f0106161:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106163:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106165:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106167:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106169:	0f 01 16             	lgdtl  (%esi)
f010616c:	74 70                	je     f01061de <mpentry_end+0x4>
	movl    %cr0, %eax
f010616e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106171:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106175:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106178:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010617e:	08 00                	or     %al,(%eax)

f0106180 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106180:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106184:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106186:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106188:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010618a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010618e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106190:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106192:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0106197:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010619a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010619d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01061a2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01061a5:	8b 25 84 be 22 f0    	mov    0xf022be84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01061ab:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01061b0:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f01061b5:	ff d0                	call   *%eax

f01061b7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01061b7:	eb fe                	jmp    f01061b7 <spin>
f01061b9:	8d 76 00             	lea    0x0(%esi),%esi

f01061bc <gdt>:
	...
f01061c4:	ff                   	(bad)  
f01061c5:	ff 00                	incl   (%eax)
f01061c7:	00 00                	add    %al,(%eax)
f01061c9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01061d0:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01061d4 <gdtdesc>:
f01061d4:	17                   	pop    %ss
f01061d5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01061da <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01061da:	90                   	nop
f01061db:	00 00                	add    %al,(%eax)
f01061dd:	00 00                	add    %al,(%eax)
	...

f01061e0 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f01061e0:	55                   	push   %ebp
f01061e1:	89 e5                	mov    %esp,%ebp
f01061e3:	56                   	push   %esi
f01061e4:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f01061e5:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f01061ea:	85 d2                	test   %edx,%edx
f01061ec:	7e 12                	jle    f0106200 <sum+0x20>
f01061ee:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f01061f3:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f01061f7:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01061f9:	83 c1 01             	add    $0x1,%ecx
f01061fc:	39 d1                	cmp    %edx,%ecx
f01061fe:	75 f3                	jne    f01061f3 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106200:	89 d8                	mov    %ebx,%eax
f0106202:	5b                   	pop    %ebx
f0106203:	5e                   	pop    %esi
f0106204:	5d                   	pop    %ebp
f0106205:	c3                   	ret    

f0106206 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106206:	55                   	push   %ebp
f0106207:	89 e5                	mov    %esp,%ebp
f0106209:	56                   	push   %esi
f010620a:	53                   	push   %ebx
f010620b:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010620e:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0106214:	89 c3                	mov    %eax,%ebx
f0106216:	c1 eb 0c             	shr    $0xc,%ebx
f0106219:	39 cb                	cmp    %ecx,%ebx
f010621b:	72 20                	jb     f010623d <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010621d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106221:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0106228:	f0 
f0106229:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106230:	00 
f0106231:	c7 04 24 61 88 10 f0 	movl   $0xf0108861,(%esp)
f0106238:	e8 03 9e ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010623d:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106240:	89 f2                	mov    %esi,%edx
f0106242:	c1 ea 0c             	shr    $0xc,%edx
f0106245:	39 d1                	cmp    %edx,%ecx
f0106247:	77 20                	ja     f0106269 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106249:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010624d:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0106254:	f0 
f0106255:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010625c:	00 
f010625d:	c7 04 24 61 88 10 f0 	movl   $0xf0108861,(%esp)
f0106264:	e8 d7 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106269:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010626f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106275:	39 f3                	cmp    %esi,%ebx
f0106277:	73 3a                	jae    f01062b3 <mpsearch1+0xad>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106279:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106280:	00 
f0106281:	c7 44 24 04 71 88 10 	movl   $0xf0108871,0x4(%esp)
f0106288:	f0 
f0106289:	89 1c 24             	mov    %ebx,(%esp)
f010628c:	e8 75 fd ff ff       	call   f0106006 <memcmp>
f0106291:	85 c0                	test   %eax,%eax
f0106293:	75 10                	jne    f01062a5 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0106295:	ba 10 00 00 00       	mov    $0x10,%edx
f010629a:	89 d8                	mov    %ebx,%eax
f010629c:	e8 3f ff ff ff       	call   f01061e0 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01062a1:	84 c0                	test   %al,%al
f01062a3:	74 13                	je     f01062b8 <mpsearch1+0xb2>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01062a5:	83 c3 10             	add    $0x10,%ebx
f01062a8:	39 f3                	cmp    %esi,%ebx
f01062aa:	72 cd                	jb     f0106279 <mpsearch1+0x73>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01062ac:	bb 00 00 00 00       	mov    $0x0,%ebx
f01062b1:	eb 05                	jmp    f01062b8 <mpsearch1+0xb2>
f01062b3:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01062b8:	89 d8                	mov    %ebx,%eax
f01062ba:	83 c4 10             	add    $0x10,%esp
f01062bd:	5b                   	pop    %ebx
f01062be:	5e                   	pop    %esi
f01062bf:	5d                   	pop    %ebp
f01062c0:	c3                   	ret    

f01062c1 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01062c1:	55                   	push   %ebp
f01062c2:	89 e5                	mov    %esp,%ebp
f01062c4:	57                   	push   %edi
f01062c5:	56                   	push   %esi
f01062c6:	53                   	push   %ebx
f01062c7:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01062ca:	c7 05 c0 c3 22 f0 20 	movl   $0xf022c020,0xf022c3c0
f01062d1:	c0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062d4:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f01062db:	75 24                	jne    f0106301 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062dd:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01062e4:	00 
f01062e5:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f01062ec:	f0 
f01062ed:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01062f4:	00 
f01062f5:	c7 04 24 61 88 10 f0 	movl   $0xf0108861,(%esp)
f01062fc:	e8 3f 9d ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106301:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106308:	85 c0                	test   %eax,%eax
f010630a:	74 16                	je     f0106322 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f010630c:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010630f:	ba 00 04 00 00       	mov    $0x400,%edx
f0106314:	e8 ed fe ff ff       	call   f0106206 <mpsearch1>
f0106319:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010631c:	85 c0                	test   %eax,%eax
f010631e:	75 3c                	jne    f010635c <mp_init+0x9b>
f0106320:	eb 20                	jmp    f0106342 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106322:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106329:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010632c:	2d 00 04 00 00       	sub    $0x400,%eax
f0106331:	ba 00 04 00 00       	mov    $0x400,%edx
f0106336:	e8 cb fe ff ff       	call   f0106206 <mpsearch1>
f010633b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010633e:	85 c0                	test   %eax,%eax
f0106340:	75 1a                	jne    f010635c <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106342:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106347:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010634c:	e8 b5 fe ff ff       	call   f0106206 <mpsearch1>
f0106351:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106354:	85 c0                	test   %eax,%eax
f0106356:	0f 84 24 02 00 00    	je     f0106580 <mp_init+0x2bf>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010635c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010635f:	8b 78 04             	mov    0x4(%eax),%edi
f0106362:	85 ff                	test   %edi,%edi
f0106364:	74 06                	je     f010636c <mp_init+0xab>
f0106366:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010636a:	74 11                	je     f010637d <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f010636c:	c7 04 24 d4 86 10 f0 	movl   $0xf01086d4,(%esp)
f0106373:	e8 5e dd ff ff       	call   f01040d6 <cprintf>
f0106378:	e9 03 02 00 00       	jmp    f0106580 <mp_init+0x2bf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010637d:	89 f8                	mov    %edi,%eax
f010637f:	c1 e8 0c             	shr    $0xc,%eax
f0106382:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0106388:	72 20                	jb     f01063aa <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010638a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010638e:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0106395:	f0 
f0106396:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f010639d:	00 
f010639e:	c7 04 24 61 88 10 f0 	movl   $0xf0108861,(%esp)
f01063a5:	e8 96 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01063aa:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01063b0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01063b7:	00 
f01063b8:	c7 44 24 04 76 88 10 	movl   $0xf0108876,0x4(%esp)
f01063bf:	f0 
f01063c0:	89 3c 24             	mov    %edi,(%esp)
f01063c3:	e8 3e fc ff ff       	call   f0106006 <memcmp>
f01063c8:	85 c0                	test   %eax,%eax
f01063ca:	74 11                	je     f01063dd <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01063cc:	c7 04 24 04 87 10 f0 	movl   $0xf0108704,(%esp)
f01063d3:	e8 fe dc ff ff       	call   f01040d6 <cprintf>
f01063d8:	e9 a3 01 00 00       	jmp    f0106580 <mp_init+0x2bf>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01063dd:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f01063e1:	0f b7 d3             	movzwl %bx,%edx
f01063e4:	89 f8                	mov    %edi,%eax
f01063e6:	e8 f5 fd ff ff       	call   f01061e0 <sum>
f01063eb:	84 c0                	test   %al,%al
f01063ed:	74 11                	je     f0106400 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f01063ef:	c7 04 24 38 87 10 f0 	movl   $0xf0108738,(%esp)
f01063f6:	e8 db dc ff ff       	call   f01040d6 <cprintf>
f01063fb:	e9 80 01 00 00       	jmp    f0106580 <mp_init+0x2bf>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106400:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0106404:	3c 01                	cmp    $0x1,%al
f0106406:	74 1c                	je     f0106424 <mp_init+0x163>
f0106408:	3c 04                	cmp    $0x4,%al
f010640a:	74 18                	je     f0106424 <mp_init+0x163>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010640c:	0f b6 c0             	movzbl %al,%eax
f010640f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106413:	c7 04 24 5c 87 10 f0 	movl   $0xf010875c,(%esp)
f010641a:	e8 b7 dc ff ff       	call   f01040d6 <cprintf>
f010641f:	e9 5c 01 00 00       	jmp    f0106580 <mp_init+0x2bf>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106424:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0106428:	0f b7 db             	movzwl %bx,%ebx
f010642b:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f010642e:	e8 ad fd ff ff       	call   f01061e0 <sum>
f0106433:	3a 47 2a             	cmp    0x2a(%edi),%al
f0106436:	74 11                	je     f0106449 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106438:	c7 04 24 7c 87 10 f0 	movl   $0xf010877c,(%esp)
f010643f:	e8 92 dc ff ff       	call   f01040d6 <cprintf>
f0106444:	e9 37 01 00 00       	jmp    f0106580 <mp_init+0x2bf>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106449:	85 ff                	test   %edi,%edi
f010644b:	0f 84 2f 01 00 00    	je     f0106580 <mp_init+0x2bf>
		return;
	ismp = 1;
f0106451:	c7 05 00 c0 22 f0 01 	movl   $0x1,0xf022c000
f0106458:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010645b:	8b 47 24             	mov    0x24(%edi),%eax
f010645e:	a3 00 d0 26 f0       	mov    %eax,0xf026d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106463:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0106468:	0f 84 97 00 00 00    	je     f0106505 <mp_init+0x244>
f010646e:	8d 77 2c             	lea    0x2c(%edi),%esi
f0106471:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (*p) {
f0106476:	0f b6 06             	movzbl (%esi),%eax
f0106479:	84 c0                	test   %al,%al
f010647b:	74 06                	je     f0106483 <mp_init+0x1c2>
f010647d:	3c 04                	cmp    $0x4,%al
f010647f:	77 54                	ja     f01064d5 <mp_init+0x214>
f0106481:	eb 4d                	jmp    f01064d0 <mp_init+0x20f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106483:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106487:	74 11                	je     f010649a <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f0106489:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f0106490:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0106495:	a3 c0 c3 22 f0       	mov    %eax,0xf022c3c0
			if (ncpu < NCPU) {
f010649a:	a1 c4 c3 22 f0       	mov    0xf022c3c4,%eax
f010649f:	83 f8 07             	cmp    $0x7,%eax
f01064a2:	7f 13                	jg     f01064b7 <mp_init+0x1f6>
				cpus[ncpu].cpu_id = ncpu;
f01064a4:	6b d0 74             	imul   $0x74,%eax,%edx
f01064a7:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
				ncpu++;
f01064ad:	83 c0 01             	add    $0x1,%eax
f01064b0:	a3 c4 c3 22 f0       	mov    %eax,0xf022c3c4
f01064b5:	eb 14                	jmp    f01064cb <mp_init+0x20a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01064b7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01064bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064bf:	c7 04 24 ac 87 10 f0 	movl   $0xf01087ac,(%esp)
f01064c6:	e8 0b dc ff ff       	call   f01040d6 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01064cb:	83 c6 14             	add    $0x14,%esi
			continue;
f01064ce:	eb 26                	jmp    f01064f6 <mp_init+0x235>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01064d0:	83 c6 08             	add    $0x8,%esi
			continue;
f01064d3:	eb 21                	jmp    f01064f6 <mp_init+0x235>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01064d5:	0f b6 c0             	movzbl %al,%eax
f01064d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064dc:	c7 04 24 d4 87 10 f0 	movl   $0xf01087d4,(%esp)
f01064e3:	e8 ee db ff ff       	call   f01040d6 <cprintf>
			ismp = 0;
f01064e8:	c7 05 00 c0 22 f0 00 	movl   $0x0,0xf022c000
f01064ef:	00 00 00 
			i = conf->entry;
f01064f2:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01064f6:	83 c3 01             	add    $0x1,%ebx
f01064f9:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f01064fd:	39 d8                	cmp    %ebx,%eax
f01064ff:	0f 87 71 ff ff ff    	ja     f0106476 <mp_init+0x1b5>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106505:	a1 c0 c3 22 f0       	mov    0xf022c3c0,%eax
f010650a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106511:	83 3d 00 c0 22 f0 00 	cmpl   $0x0,0xf022c000
f0106518:	75 22                	jne    f010653c <mp_init+0x27b>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010651a:	c7 05 c4 c3 22 f0 01 	movl   $0x1,0xf022c3c4
f0106521:	00 00 00 
		lapicaddr = 0;
f0106524:	c7 05 00 d0 26 f0 00 	movl   $0x0,0xf026d000
f010652b:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010652e:	c7 04 24 f4 87 10 f0 	movl   $0xf01087f4,(%esp)
f0106535:	e8 9c db ff ff       	call   f01040d6 <cprintf>
		return;
f010653a:	eb 44                	jmp    f0106580 <mp_init+0x2bf>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010653c:	8b 15 c4 c3 22 f0    	mov    0xf022c3c4,%edx
f0106542:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106546:	0f b6 00             	movzbl (%eax),%eax
f0106549:	89 44 24 04          	mov    %eax,0x4(%esp)
f010654d:	c7 04 24 7b 88 10 f0 	movl   $0xf010887b,(%esp)
f0106554:	e8 7d db ff ff       	call   f01040d6 <cprintf>

	if (mp->imcrp) {
f0106559:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010655c:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106560:	74 1e                	je     f0106580 <mp_init+0x2bf>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106562:	c7 04 24 20 88 10 f0 	movl   $0xf0108820,(%esp)
f0106569:	e8 68 db ff ff       	call   f01040d6 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010656e:	ba 22 00 00 00       	mov    $0x22,%edx
f0106573:	b8 70 00 00 00       	mov    $0x70,%eax
f0106578:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106579:	b2 23                	mov    $0x23,%dl
f010657b:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010657c:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010657f:	ee                   	out    %al,(%dx)
	}
}
f0106580:	83 c4 2c             	add    $0x2c,%esp
f0106583:	5b                   	pop    %ebx
f0106584:	5e                   	pop    %esi
f0106585:	5f                   	pop    %edi
f0106586:	5d                   	pop    %ebp
f0106587:	c3                   	ret    

f0106588 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106588:	55                   	push   %ebp
f0106589:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010658b:	c1 e0 02             	shl    $0x2,%eax
f010658e:	03 05 04 d0 26 f0    	add    0xf026d004,%eax
f0106594:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106596:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f010659b:	8b 40 20             	mov    0x20(%eax),%eax
}
f010659e:	5d                   	pop    %ebp
f010659f:	c3                   	ret    

f01065a0 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01065a0:	55                   	push   %ebp
f01065a1:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01065a3:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
		return lapic[ID] >> 24;
	return 0;
f01065a9:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
cpunum(void)
{
	if (lapic)
f01065ae:	85 d2                	test   %edx,%edx
f01065b0:	74 06                	je     f01065b8 <cpunum+0x18>
		return lapic[ID] >> 24;
f01065b2:	8b 42 20             	mov    0x20(%edx),%eax
f01065b5:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f01065b8:	5d                   	pop    %ebp
f01065b9:	c3                   	ret    

f01065ba <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01065ba:	55                   	push   %ebp
f01065bb:	89 e5                	mov    %esp,%ebp
f01065bd:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f01065c0:	a1 00 d0 26 f0       	mov    0xf026d000,%eax
f01065c5:	85 c0                	test   %eax,%eax
f01065c7:	0f 84 1c 01 00 00    	je     f01066e9 <lapic_init+0x12f>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01065cd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01065d4:	00 
f01065d5:	89 04 24             	mov    %eax,(%esp)
f01065d8:	e8 9c af ff ff       	call   f0101579 <mmio_map_region>
f01065dd:	a3 04 d0 26 f0       	mov    %eax,0xf026d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01065e2:	ba 27 01 00 00       	mov    $0x127,%edx
f01065e7:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01065ec:	e8 97 ff ff ff       	call   f0106588 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01065f1:	ba 0b 00 00 00       	mov    $0xb,%edx
f01065f6:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01065fb:	e8 88 ff ff ff       	call   f0106588 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106600:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106605:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010660a:	e8 79 ff ff ff       	call   f0106588 <lapicw>
	lapicw(TICR, 10000000); 
f010660f:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106614:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106619:	e8 6a ff ff ff       	call   f0106588 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010661e:	e8 7d ff ff ff       	call   f01065a0 <cpunum>
f0106623:	6b c0 74             	imul   $0x74,%eax,%eax
f0106626:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010662b:	39 05 c0 c3 22 f0    	cmp    %eax,0xf022c3c0
f0106631:	74 0f                	je     f0106642 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106633:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106638:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010663d:	e8 46 ff ff ff       	call   f0106588 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106642:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106647:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010664c:	e8 37 ff ff ff       	call   f0106588 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106651:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0106656:	8b 40 30             	mov    0x30(%eax),%eax
f0106659:	c1 e8 10             	shr    $0x10,%eax
f010665c:	3c 03                	cmp    $0x3,%al
f010665e:	76 0f                	jbe    f010666f <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106660:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106665:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010666a:	e8 19 ff ff ff       	call   f0106588 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010666f:	ba 33 00 00 00       	mov    $0x33,%edx
f0106674:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106679:	e8 0a ff ff ff       	call   f0106588 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010667e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106683:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106688:	e8 fb fe ff ff       	call   f0106588 <lapicw>
	lapicw(ESR, 0);
f010668d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106692:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106697:	e8 ec fe ff ff       	call   f0106588 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010669c:	ba 00 00 00 00       	mov    $0x0,%edx
f01066a1:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01066a6:	e8 dd fe ff ff       	call   f0106588 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01066ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01066b0:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01066b5:	e8 ce fe ff ff       	call   f0106588 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01066ba:	ba 00 85 08 00       	mov    $0x88500,%edx
f01066bf:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066c4:	e8 bf fe ff ff       	call   f0106588 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01066c9:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f01066cf:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01066d5:	f6 c4 10             	test   $0x10,%ah
f01066d8:	75 f5                	jne    f01066cf <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01066da:	ba 00 00 00 00       	mov    $0x0,%edx
f01066df:	b8 20 00 00 00       	mov    $0x20,%eax
f01066e4:	e8 9f fe ff ff       	call   f0106588 <lapicw>
}
f01066e9:	c9                   	leave  
f01066ea:	c3                   	ret    

f01066eb <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01066eb:	55                   	push   %ebp
f01066ec:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01066ee:	83 3d 04 d0 26 f0 00 	cmpl   $0x0,0xf026d004
f01066f5:	74 0f                	je     f0106706 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01066f7:	ba 00 00 00 00       	mov    $0x0,%edx
f01066fc:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106701:	e8 82 fe ff ff       	call   f0106588 <lapicw>
}
f0106706:	5d                   	pop    %ebp
f0106707:	c3                   	ret    

f0106708 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106708:	55                   	push   %ebp
f0106709:	89 e5                	mov    %esp,%ebp
f010670b:	56                   	push   %esi
f010670c:	53                   	push   %ebx
f010670d:	83 ec 10             	sub    $0x10,%esp
f0106710:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106713:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0106717:	ba 70 00 00 00       	mov    $0x70,%edx
f010671c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106721:	ee                   	out    %al,(%dx)
f0106722:	b2 71                	mov    $0x71,%dl
f0106724:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106729:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010672a:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0106731:	75 24                	jne    f0106757 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106733:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f010673a:	00 
f010673b:	c7 44 24 08 28 6d 10 	movl   $0xf0106d28,0x8(%esp)
f0106742:	f0 
f0106743:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f010674a:	00 
f010674b:	c7 04 24 98 88 10 f0 	movl   $0xf0108898,(%esp)
f0106752:	e8 e9 98 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106757:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010675e:	00 00 
	wrv[1] = addr >> 4;
f0106760:	89 f0                	mov    %esi,%eax
f0106762:	c1 e8 04             	shr    $0x4,%eax
f0106765:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010676b:	c1 e3 18             	shl    $0x18,%ebx
f010676e:	89 da                	mov    %ebx,%edx
f0106770:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106775:	e8 0e fe ff ff       	call   f0106588 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010677a:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010677f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106784:	e8 ff fd ff ff       	call   f0106588 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106789:	ba 00 85 00 00       	mov    $0x8500,%edx
f010678e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106793:	e8 f0 fd ff ff       	call   f0106588 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106798:	c1 ee 0c             	shr    $0xc,%esi
f010679b:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01067a1:	89 da                	mov    %ebx,%edx
f01067a3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067a8:	e8 db fd ff ff       	call   f0106588 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01067ad:	89 f2                	mov    %esi,%edx
f01067af:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067b4:	e8 cf fd ff ff       	call   f0106588 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01067b9:	89 da                	mov    %ebx,%edx
f01067bb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067c0:	e8 c3 fd ff ff       	call   f0106588 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01067c5:	89 f2                	mov    %esi,%edx
f01067c7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067cc:	e8 b7 fd ff ff       	call   f0106588 <lapicw>
		microdelay(200);
	}
}
f01067d1:	83 c4 10             	add    $0x10,%esp
f01067d4:	5b                   	pop    %ebx
f01067d5:	5e                   	pop    %esi
f01067d6:	5d                   	pop    %ebp
f01067d7:	c3                   	ret    

f01067d8 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01067d8:	55                   	push   %ebp
f01067d9:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01067db:	8b 55 08             	mov    0x8(%ebp),%edx
f01067de:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01067e4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067e9:	e8 9a fd ff ff       	call   f0106588 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01067ee:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f01067f4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01067fa:	f6 c4 10             	test   $0x10,%ah
f01067fd:	75 f5                	jne    f01067f4 <lapic_ipi+0x1c>
		;
}
f01067ff:	5d                   	pop    %ebp
f0106800:	c3                   	ret    
f0106801:	00 00                	add    %al,(%eax)
	...

f0106804 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106804:	55                   	push   %ebp
f0106805:	89 e5                	mov    %esp,%ebp
f0106807:	53                   	push   %ebx
f0106808:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f010680b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106810:	83 38 00             	cmpl   $0x0,(%eax)
f0106813:	74 18                	je     f010682d <holding+0x29>
f0106815:	8b 58 08             	mov    0x8(%eax),%ebx
f0106818:	e8 83 fd ff ff       	call   f01065a0 <cpunum>
f010681d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106820:	05 20 c0 22 f0       	add    $0xf022c020,%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106825:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106827:	0f 94 c2             	sete   %dl
f010682a:	0f b6 d2             	movzbl %dl,%edx
}
f010682d:	89 d0                	mov    %edx,%eax
f010682f:	83 c4 04             	add    $0x4,%esp
f0106832:	5b                   	pop    %ebx
f0106833:	5d                   	pop    %ebp
f0106834:	c3                   	ret    

f0106835 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106835:	55                   	push   %ebp
f0106836:	89 e5                	mov    %esp,%ebp
f0106838:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010683b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106841:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106844:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106847:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010684e:	5d                   	pop    %ebp
f010684f:	c3                   	ret    

f0106850 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106850:	55                   	push   %ebp
f0106851:	89 e5                	mov    %esp,%ebp
f0106853:	53                   	push   %ebx
f0106854:	83 ec 24             	sub    $0x24,%esp
f0106857:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010685a:	89 d8                	mov    %ebx,%eax
f010685c:	e8 a3 ff ff ff       	call   f0106804 <holding>
f0106861:	85 c0                	test   %eax,%eax
f0106863:	75 12                	jne    f0106877 <spin_lock+0x27>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106865:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106867:	b0 01                	mov    $0x1,%al
f0106869:	f0 87 03             	lock xchg %eax,(%ebx)
f010686c:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106871:	85 c0                	test   %eax,%eax
f0106873:	75 2e                	jne    f01068a3 <spin_lock+0x53>
f0106875:	eb 37                	jmp    f01068ae <spin_lock+0x5e>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106877:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010687a:	e8 21 fd ff ff       	call   f01065a0 <cpunum>
f010687f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106883:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106887:	c7 44 24 08 a8 88 10 	movl   $0xf01088a8,0x8(%esp)
f010688e:	f0 
f010688f:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106896:	00 
f0106897:	c7 04 24 0c 89 10 f0 	movl   $0xf010890c,(%esp)
f010689e:	e8 9d 97 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01068a3:	f3 90                	pause  
f01068a5:	89 c8                	mov    %ecx,%eax
f01068a7:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01068aa:	85 c0                	test   %eax,%eax
f01068ac:	75 f5                	jne    f01068a3 <spin_lock+0x53>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01068ae:	e8 ed fc ff ff       	call   f01065a0 <cpunum>
f01068b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01068b6:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01068bb:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01068be:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01068c1:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01068c3:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01068c8:	77 34                	ja     f01068fe <spin_lock+0xae>
f01068ca:	eb 2b                	jmp    f01068f7 <spin_lock+0xa7>
f01068cc:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01068d2:	76 12                	jbe    f01068e6 <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01068d4:	8b 5a 04             	mov    0x4(%edx),%ebx
f01068d7:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01068da:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01068dc:	83 c0 01             	add    $0x1,%eax
f01068df:	83 f8 0a             	cmp    $0xa,%eax
f01068e2:	75 e8                	jne    f01068cc <spin_lock+0x7c>
f01068e4:	eb 27                	jmp    f010690d <spin_lock+0xbd>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01068e6:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01068ed:	83 c0 01             	add    $0x1,%eax
f01068f0:	83 f8 09             	cmp    $0x9,%eax
f01068f3:	7e f1                	jle    f01068e6 <spin_lock+0x96>
f01068f5:	eb 16                	jmp    f010690d <spin_lock+0xbd>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01068f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01068fc:	eb e8                	jmp    f01068e6 <spin_lock+0x96>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01068fe:	8b 50 04             	mov    0x4(%eax),%edx
f0106901:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106904:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106906:	b8 01 00 00 00       	mov    $0x1,%eax
f010690b:	eb bf                	jmp    f01068cc <spin_lock+0x7c>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010690d:	83 c4 24             	add    $0x24,%esp
f0106910:	5b                   	pop    %ebx
f0106911:	5d                   	pop    %ebp
f0106912:	c3                   	ret    

f0106913 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106913:	55                   	push   %ebp
f0106914:	89 e5                	mov    %esp,%ebp
f0106916:	83 ec 78             	sub    $0x78,%esp
f0106919:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010691c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010691f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106922:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106925:	89 d8                	mov    %ebx,%eax
f0106927:	e8 d8 fe ff ff       	call   f0106804 <holding>
f010692c:	85 c0                	test   %eax,%eax
f010692e:	0f 85 d4 00 00 00    	jne    f0106a08 <spin_unlock+0xf5>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106934:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f010693b:	00 
f010693c:	8d 43 0c             	lea    0xc(%ebx),%eax
f010693f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106943:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0106946:	89 04 24             	mov    %eax,(%esp)
f0106949:	e8 1e f6 ff ff       	call   f0105f6c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010694e:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106951:	0f b6 30             	movzbl (%eax),%esi
f0106954:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106957:	e8 44 fc ff ff       	call   f01065a0 <cpunum>
f010695c:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106960:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106964:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106968:	c7 04 24 d4 88 10 f0 	movl   $0xf01088d4,(%esp)
f010696f:	e8 62 d7 ff ff       	call   f01040d6 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106974:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106977:	85 c0                	test   %eax,%eax
f0106979:	74 71                	je     f01069ec <spin_unlock+0xd9>
f010697b:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f010697e:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106981:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0106984:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106988:	89 04 24             	mov    %eax,(%esp)
f010698b:	e8 da e9 ff ff       	call   f010536a <debuginfo_eip>
f0106990:	85 c0                	test   %eax,%eax
f0106992:	78 39                	js     f01069cd <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106994:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106996:	89 c2                	mov    %eax,%edx
f0106998:	2b 55 e0             	sub    -0x20(%ebp),%edx
f010699b:	89 54 24 18          	mov    %edx,0x18(%esp)
f010699f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01069a2:	89 54 24 14          	mov    %edx,0x14(%esp)
f01069a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01069a9:	89 54 24 10          	mov    %edx,0x10(%esp)
f01069ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01069b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01069b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01069b7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01069bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069bf:	c7 04 24 1c 89 10 f0 	movl   $0xf010891c,(%esp)
f01069c6:	e8 0b d7 ff ff       	call   f01040d6 <cprintf>
f01069cb:	eb 12                	jmp    f01069df <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01069cd:	8b 03                	mov    (%ebx),%eax
f01069cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069d3:	c7 04 24 33 89 10 f0 	movl   $0xf0108933,(%esp)
f01069da:	e8 f7 d6 ff ff       	call   f01040d6 <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01069df:	39 fb                	cmp    %edi,%ebx
f01069e1:	74 09                	je     f01069ec <spin_unlock+0xd9>
f01069e3:	83 c3 04             	add    $0x4,%ebx
f01069e6:	8b 03                	mov    (%ebx),%eax
f01069e8:	85 c0                	test   %eax,%eax
f01069ea:	75 98                	jne    f0106984 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01069ec:	c7 44 24 08 3b 89 10 	movl   $0xf010893b,0x8(%esp)
f01069f3:	f0 
f01069f4:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01069fb:	00 
f01069fc:	c7 04 24 0c 89 10 f0 	movl   $0xf010890c,(%esp)
f0106a03:	e8 38 96 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106a08:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106a0f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106a16:	b8 00 00 00 00       	mov    $0x0,%eax
f0106a1b:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106a1e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106a21:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106a24:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106a27:	89 ec                	mov    %ebp,%esp
f0106a29:	5d                   	pop    %ebp
f0106a2a:	c3                   	ret    
f0106a2b:	00 00                	add    %al,(%eax)
f0106a2d:	00 00                	add    %al,(%eax)
	...

f0106a30 <__udivdi3>:
f0106a30:	83 ec 1c             	sub    $0x1c,%esp
f0106a33:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106a37:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0106a3b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0106a3f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106a43:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106a47:	8b 74 24 24          	mov    0x24(%esp),%esi
f0106a4b:	85 ff                	test   %edi,%edi
f0106a4d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106a51:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106a55:	89 cd                	mov    %ecx,%ebp
f0106a57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a5b:	75 33                	jne    f0106a90 <__udivdi3+0x60>
f0106a5d:	39 f1                	cmp    %esi,%ecx
f0106a5f:	77 57                	ja     f0106ab8 <__udivdi3+0x88>
f0106a61:	85 c9                	test   %ecx,%ecx
f0106a63:	75 0b                	jne    f0106a70 <__udivdi3+0x40>
f0106a65:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a6a:	31 d2                	xor    %edx,%edx
f0106a6c:	f7 f1                	div    %ecx
f0106a6e:	89 c1                	mov    %eax,%ecx
f0106a70:	89 f0                	mov    %esi,%eax
f0106a72:	31 d2                	xor    %edx,%edx
f0106a74:	f7 f1                	div    %ecx
f0106a76:	89 c6                	mov    %eax,%esi
f0106a78:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106a7c:	f7 f1                	div    %ecx
f0106a7e:	89 f2                	mov    %esi,%edx
f0106a80:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106a84:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106a88:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106a8c:	83 c4 1c             	add    $0x1c,%esp
f0106a8f:	c3                   	ret    
f0106a90:	31 d2                	xor    %edx,%edx
f0106a92:	31 c0                	xor    %eax,%eax
f0106a94:	39 f7                	cmp    %esi,%edi
f0106a96:	77 e8                	ja     f0106a80 <__udivdi3+0x50>
f0106a98:	0f bd cf             	bsr    %edi,%ecx
f0106a9b:	83 f1 1f             	xor    $0x1f,%ecx
f0106a9e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106aa2:	75 2c                	jne    f0106ad0 <__udivdi3+0xa0>
f0106aa4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0106aa8:	76 04                	jbe    f0106aae <__udivdi3+0x7e>
f0106aaa:	39 f7                	cmp    %esi,%edi
f0106aac:	73 d2                	jae    f0106a80 <__udivdi3+0x50>
f0106aae:	31 d2                	xor    %edx,%edx
f0106ab0:	b8 01 00 00 00       	mov    $0x1,%eax
f0106ab5:	eb c9                	jmp    f0106a80 <__udivdi3+0x50>
f0106ab7:	90                   	nop
f0106ab8:	89 f2                	mov    %esi,%edx
f0106aba:	f7 f1                	div    %ecx
f0106abc:	31 d2                	xor    %edx,%edx
f0106abe:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106ac2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106ac6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106aca:	83 c4 1c             	add    $0x1c,%esp
f0106acd:	c3                   	ret    
f0106ace:	66 90                	xchg   %ax,%ax
f0106ad0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106ad5:	b8 20 00 00 00       	mov    $0x20,%eax
f0106ada:	89 ea                	mov    %ebp,%edx
f0106adc:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106ae0:	d3 e7                	shl    %cl,%edi
f0106ae2:	89 c1                	mov    %eax,%ecx
f0106ae4:	d3 ea                	shr    %cl,%edx
f0106ae6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106aeb:	09 fa                	or     %edi,%edx
f0106aed:	89 f7                	mov    %esi,%edi
f0106aef:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106af3:	89 f2                	mov    %esi,%edx
f0106af5:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106af9:	d3 e5                	shl    %cl,%ebp
f0106afb:	89 c1                	mov    %eax,%ecx
f0106afd:	d3 ef                	shr    %cl,%edi
f0106aff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106b04:	d3 e2                	shl    %cl,%edx
f0106b06:	89 c1                	mov    %eax,%ecx
f0106b08:	d3 ee                	shr    %cl,%esi
f0106b0a:	09 d6                	or     %edx,%esi
f0106b0c:	89 fa                	mov    %edi,%edx
f0106b0e:	89 f0                	mov    %esi,%eax
f0106b10:	f7 74 24 0c          	divl   0xc(%esp)
f0106b14:	89 d7                	mov    %edx,%edi
f0106b16:	89 c6                	mov    %eax,%esi
f0106b18:	f7 e5                	mul    %ebp
f0106b1a:	39 d7                	cmp    %edx,%edi
f0106b1c:	72 22                	jb     f0106b40 <__udivdi3+0x110>
f0106b1e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0106b22:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106b27:	d3 e5                	shl    %cl,%ebp
f0106b29:	39 c5                	cmp    %eax,%ebp
f0106b2b:	73 04                	jae    f0106b31 <__udivdi3+0x101>
f0106b2d:	39 d7                	cmp    %edx,%edi
f0106b2f:	74 0f                	je     f0106b40 <__udivdi3+0x110>
f0106b31:	89 f0                	mov    %esi,%eax
f0106b33:	31 d2                	xor    %edx,%edx
f0106b35:	e9 46 ff ff ff       	jmp    f0106a80 <__udivdi3+0x50>
f0106b3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106b40:	8d 46 ff             	lea    -0x1(%esi),%eax
f0106b43:	31 d2                	xor    %edx,%edx
f0106b45:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106b49:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106b4d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106b51:	83 c4 1c             	add    $0x1c,%esp
f0106b54:	c3                   	ret    
	...

f0106b60 <__umoddi3>:
f0106b60:	83 ec 1c             	sub    $0x1c,%esp
f0106b63:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106b67:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0106b6b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0106b6f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106b73:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106b77:	8b 74 24 24          	mov    0x24(%esp),%esi
f0106b7b:	85 ed                	test   %ebp,%ebp
f0106b7d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106b81:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106b85:	89 cf                	mov    %ecx,%edi
f0106b87:	89 04 24             	mov    %eax,(%esp)
f0106b8a:	89 f2                	mov    %esi,%edx
f0106b8c:	75 1a                	jne    f0106ba8 <__umoddi3+0x48>
f0106b8e:	39 f1                	cmp    %esi,%ecx
f0106b90:	76 4e                	jbe    f0106be0 <__umoddi3+0x80>
f0106b92:	f7 f1                	div    %ecx
f0106b94:	89 d0                	mov    %edx,%eax
f0106b96:	31 d2                	xor    %edx,%edx
f0106b98:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106b9c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106ba0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106ba4:	83 c4 1c             	add    $0x1c,%esp
f0106ba7:	c3                   	ret    
f0106ba8:	39 f5                	cmp    %esi,%ebp
f0106baa:	77 54                	ja     f0106c00 <__umoddi3+0xa0>
f0106bac:	0f bd c5             	bsr    %ebp,%eax
f0106baf:	83 f0 1f             	xor    $0x1f,%eax
f0106bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106bb6:	75 60                	jne    f0106c18 <__umoddi3+0xb8>
f0106bb8:	3b 0c 24             	cmp    (%esp),%ecx
f0106bbb:	0f 87 07 01 00 00    	ja     f0106cc8 <__umoddi3+0x168>
f0106bc1:	89 f2                	mov    %esi,%edx
f0106bc3:	8b 34 24             	mov    (%esp),%esi
f0106bc6:	29 ce                	sub    %ecx,%esi
f0106bc8:	19 ea                	sbb    %ebp,%edx
f0106bca:	89 34 24             	mov    %esi,(%esp)
f0106bcd:	8b 04 24             	mov    (%esp),%eax
f0106bd0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106bd4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106bd8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106bdc:	83 c4 1c             	add    $0x1c,%esp
f0106bdf:	c3                   	ret    
f0106be0:	85 c9                	test   %ecx,%ecx
f0106be2:	75 0b                	jne    f0106bef <__umoddi3+0x8f>
f0106be4:	b8 01 00 00 00       	mov    $0x1,%eax
f0106be9:	31 d2                	xor    %edx,%edx
f0106beb:	f7 f1                	div    %ecx
f0106bed:	89 c1                	mov    %eax,%ecx
f0106bef:	89 f0                	mov    %esi,%eax
f0106bf1:	31 d2                	xor    %edx,%edx
f0106bf3:	f7 f1                	div    %ecx
f0106bf5:	8b 04 24             	mov    (%esp),%eax
f0106bf8:	f7 f1                	div    %ecx
f0106bfa:	eb 98                	jmp    f0106b94 <__umoddi3+0x34>
f0106bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106c00:	89 f2                	mov    %esi,%edx
f0106c02:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106c06:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106c0a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106c0e:	83 c4 1c             	add    $0x1c,%esp
f0106c11:	c3                   	ret    
f0106c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106c18:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106c1d:	89 e8                	mov    %ebp,%eax
f0106c1f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0106c24:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0106c28:	89 fa                	mov    %edi,%edx
f0106c2a:	d3 e0                	shl    %cl,%eax
f0106c2c:	89 e9                	mov    %ebp,%ecx
f0106c2e:	d3 ea                	shr    %cl,%edx
f0106c30:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106c35:	09 c2                	or     %eax,%edx
f0106c37:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106c3b:	89 14 24             	mov    %edx,(%esp)
f0106c3e:	89 f2                	mov    %esi,%edx
f0106c40:	d3 e7                	shl    %cl,%edi
f0106c42:	89 e9                	mov    %ebp,%ecx
f0106c44:	d3 ea                	shr    %cl,%edx
f0106c46:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106c4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106c4f:	d3 e6                	shl    %cl,%esi
f0106c51:	89 e9                	mov    %ebp,%ecx
f0106c53:	d3 e8                	shr    %cl,%eax
f0106c55:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106c5a:	09 f0                	or     %esi,%eax
f0106c5c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106c60:	f7 34 24             	divl   (%esp)
f0106c63:	d3 e6                	shl    %cl,%esi
f0106c65:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106c69:	89 d6                	mov    %edx,%esi
f0106c6b:	f7 e7                	mul    %edi
f0106c6d:	39 d6                	cmp    %edx,%esi
f0106c6f:	89 c1                	mov    %eax,%ecx
f0106c71:	89 d7                	mov    %edx,%edi
f0106c73:	72 3f                	jb     f0106cb4 <__umoddi3+0x154>
f0106c75:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106c79:	72 35                	jb     f0106cb0 <__umoddi3+0x150>
f0106c7b:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106c7f:	29 c8                	sub    %ecx,%eax
f0106c81:	19 fe                	sbb    %edi,%esi
f0106c83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106c88:	89 f2                	mov    %esi,%edx
f0106c8a:	d3 e8                	shr    %cl,%eax
f0106c8c:	89 e9                	mov    %ebp,%ecx
f0106c8e:	d3 e2                	shl    %cl,%edx
f0106c90:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106c95:	09 d0                	or     %edx,%eax
f0106c97:	89 f2                	mov    %esi,%edx
f0106c99:	d3 ea                	shr    %cl,%edx
f0106c9b:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106c9f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106ca3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106ca7:	83 c4 1c             	add    $0x1c,%esp
f0106caa:	c3                   	ret    
f0106cab:	90                   	nop
f0106cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106cb0:	39 d6                	cmp    %edx,%esi
f0106cb2:	75 c7                	jne    f0106c7b <__umoddi3+0x11b>
f0106cb4:	89 d7                	mov    %edx,%edi
f0106cb6:	89 c1                	mov    %eax,%ecx
f0106cb8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0106cbc:	1b 3c 24             	sbb    (%esp),%edi
f0106cbf:	eb ba                	jmp    f0106c7b <__umoddi3+0x11b>
f0106cc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106cc8:	39 f5                	cmp    %esi,%ebp
f0106cca:	0f 82 f1 fe ff ff    	jb     f0106bc1 <__umoddi3+0x61>
f0106cd0:	e9 f8 fe ff ff       	jmp    f0106bcd <__umoddi3+0x6d>
