#ifndef PAGE_H
#define PAGE_H

// #include<stdint.h>
// #include<stddef.h>
// #include<qemu.h>


uint64_t HEAP_START;
uint64_t HEAP_SIZE; 

uint64_t ALLOC_START;

enum PageBits {Empty = 0, Taken = 1, Last = 2};
enum EntryBits {Valid = 1 << 0, Read = 1 << 1, Write = 1 << 2, Execute = 1 << 3, 
	User = 1 << 4, Global = 1 << 5, Access = 1 << 6, Dirty = 1 << 7, 
	ReadWrite = 1 << 1 | 1 << 2, ReadExecute = 1 << 1 | 1 << 3, 
	ReadWriteExecute = 1 << 1 | 1 << 2 | 1 << 3, 
	UserReadWrite = 1 << 1 | 1 << 2 | 1 << 4,
    UserReadExecute = 1 << 1 | 1 << 3 | 1 << 4,
    UserReadWriteExecute = 1 << 1 | 1 << 2 | 1 << 3 | 1 << 4};

struct Page {
	uint8_t flags;
};
typedef struct Page Page; 

struct Entry {
	uint64_t entry;
};
typedef struct Entry Entry; 

struct PageTable {
	Entry entries[512]; 
};
typedef struct PageTable PageTable;



Page new_page();
char page_is_last(Page p);
char page_is_taken(Page p); 
char page_is_free(Page p); 
void page_clear(Page * p); 
void page_set_flag(Page * p, char flag);
void page_clear_flag(Page * p, char flag);

void page_init();

void * alloc(uint64_t pages); 
void * zalloc(uint64_t pages);
void dealloc(uint8_t * ptr);

void kheap(uint64_t a0, uint64_t a1);

void printPageAllocations();

void map(PageTable * root, uint64_t vaddr, uint64_t paddr, uint64_t bits, uint64_t level);
void unmap(PageTable * root); 
uint64_t virt_to_phys(PageTable * root, uint64_t vaddr); 

void Entry_set(Entry * self, uint64_t val); 
char Entry_is_valid(Entry * self);
char Entry_is_invalid(Entry * self); 
char Entry_is_leaf(Entry * self); 
char Entry_is_branch(Entry * self); 

#endif