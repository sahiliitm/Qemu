/* See COPYRIGHT for copyright information. */

#ifndef JOS_KERN_ENV_HPP
#define JOS_KERN_ENV_HPP

#include <inc/env.h>
#include <kern/cpu.h>


// extern struct Env *envs;		// All environments
#define curenv (thiscpu->cpu_env)		// Current environment
extern struct Segdesc gdt[];


class AllEnvts{
	private:

		struct Env * envs;
		static bool instanceFlag;
		static AllEnvts *single;
    	AllEnvts()
    	{
        	//private constructor
    	}
	static struct Env *env_free_list;
	public:
		static AllEnvts* getInstance();
		~AllEnvts(){
        	instanceFlag = false;
    	}
		int	envid2env(envid_t envid, struct Env **env_store, bool checkperm);
		void	env_init(void);
		int	env_alloc(struct Env **e, envid_t parent_id);
		void	env_free(struct Env *e);
		void	env_create(uint8_t *binary, size_t size, enum EnvType type);
		void	env_destroy(struct Env *e);	// Does not return if e == curenv
		static void region_alloc(struct Env *e, void *va, size_t len);
		static void load_icode(struct Env *e, uint8_t *binary, size_t size);
		void	env_init_percpu(void);

};



// The following two functions do not return
void	env_run(struct Env *e) __attribute__((noreturn));
void	env_pop_tf(struct Trapframe *tf) __attribute__((noreturn));

// Without this extra macro, we couldn't pass macros like TEST to
// ENV_CREATE because of the C pre-processor's argument prescan rule.
#define ENV_PASTE3(x, y, z) x ## y ## z

#define ENV_CREATE(x, type)						\
	do {								\
		extern uint8_t ENV_PASTE3(_binary_obj_, x, _start)[],	\
			ENV_PASTE3(_binary_obj_, x, _size)[];		\
		env_create(ENV_PASTE3(_binary_obj_, x, _start),		\
			   (int)ENV_PASTE3(_binary_obj_, x, _size),	\
			   type);					\
	} while (0)

#endif // !JOS_KERN_ENV_HPP
