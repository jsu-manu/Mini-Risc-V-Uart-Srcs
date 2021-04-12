#ifndef KMEM_H
#define KMEM_H

#include<page.h>
#include<qemu.h> 
#include<stddef.h>

// enum AllocListFlags {Taken = 1 << 63};
// uint64_t ATaken = (1 << 63);
uint64_t ATaken;

struct AllocList {
	uint64_t flags_size;
};

typedef struct AllocList AllocList; 

AllocList * KMEM_HEAD;
uint64_t KMEM_ALLOC; 
PageTable * KMEM_PAGE_TABLE; 

AllocList AL_init();
char AL_is_taken(AllocList * self);
char AL_is_free(AllocList * self);
void AL_set_taken(AllocList * self);
void AL_set_free(AllocList * self);
void AL_set_size(AllocList * self, uint64_t size); 
uint64_t AL_get_size(AllocList * self); 

// void * get_head(); 
// PageTable * get_page_table(); 
// uint64_t get_num_allocations(); 

void kmem_init(); 

uint64_t align_val(uint64_t val, uint64_t order); 
void * kzmalloc(size_t sz); 
void * kmalloc(size_t sz); 
void kfree(void * ptr); 

void coalesce(); 

#endif