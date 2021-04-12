// #include<page.h>
// #include<printf.h>
#include"page.h" 

void kheap(uint64_t a0, uint64_t a1) {
	HEAP_START = a0;
	HEAP_SIZE = a1; 
}

void page_init() {
	uint64_t num_pages = HEAP_SIZE / PAGE_SIZE; 
	uint64_t i = 0;
	Page * ptr = (Page *)HEAP_START; 
	for (i = 0; i < num_pages; i++) {
		page_clear(ptr);
		ptr++;
	}
	ALLOC_START = (HEAP_START + (num_pages * sizeof(Page)) + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1);
}

void * alloc(uint64_t pages) {
	uint64_t num_pages = HEAP_SIZE / PAGE_SIZE;
	uint64_t i = 0;
	Page * ptr = (Page *)(HEAP_START); 
	for (i = 0; i < num_pages - pages; i++) {
		char found = 0; 
		if (page_is_free(ptr[i])) {
			found = 1;
			uint64_t j = i; 
			for (j = i; j < (i + pages); j++) {
				if (page_is_taken(ptr[j])) {
					found = 0;
					break;
				}
			}
		}

		if (found) {
			uint64_t k = i; 
			for (k = i; k < i + pages - 1; k++) {
				page_set_flag(ptr + k, Taken); 
			}
			page_set_flag(ptr + k, Taken); 
			page_set_flag(ptr + k, Last); 
			return (void *)(ALLOC_START + (PAGE_SIZE * i)); 
		}
	}
	return NULL; 

} 

void * zalloc(uint64_t pages) {
	void * ptr = alloc(pages); 
	uint64_t size = (PAGE_SIZE * pages) / 8; 
	uint64_t * bigptr = (uint64_t *)ptr;
	for (uint64_t i = 0; i < size; i++) {
		bigptr[i] = 0;
	}
	return ptr;
}

void dealloc(uint8_t * ptr) {
	uint64_t base = HEAP_START + (((uint64_t)(ptr) - ALLOC_START) / PAGE_SIZE);
	Page * p = (Page *)(base); 
	uint64_t i = 0; 
	while (page_is_taken(*p) && !(page_is_last(*p))) {
		page_clear(p);
		i++;
		p++; 
	}

	page_clear(p);
}

// void printPageAllocations() {
// 	uint64_t num_pages = HEAP_SIZE / PAGE_SIZE; 
// 	Page * head = (Page *)(HEAP_START); 
// 	Page * tail = (Page *)(HEAP_START + num_pages); 
// 	uint64_t alloc_head = ALLOC_START; 
// 	uint64_t alloc_tail = ALLOC_START + num_pages * PAGE_SIZE; 
// 	printf("PAGE ALLOCATION TABLE: \nMETA: %08x -> %08x\n", (uint64_t)(head), (uint64_t)(tail));
// 	printf("PHYS: %08x -> %08x\n", alloc_head, alloc_tail); 
// 	uint64_t num = 0; 
// 	while((uint64_t)(head) < (uint64_t)(tail)) {
// 		if (page_is_taken(*head)) {
// 			uint64_t start = (uint64_t)head;
// 			uint64_t memaddr = ALLOC_START + (start - HEAP_START) * PAGE_SIZE; 
// 			while (1) {
// 				num++; 
// 				if (page_is_last(*head)) {
// 					uint64_t end = (uint64_t)head; 
// 					uint64_t endmemaddr = ALLOC_START + ((end - HEAP_START) * PAGE_SIZE) + PAGE_SIZE - 1;
// 					printf("%08x => %08x: %02d\n", memaddr, endmemaddr, (end - start + 1)); 
// 					break;
// 				}
// 				head++; 
// 			}
// 		}
// 		head++; 
// 	}
// 	printf("Free Pages: %d\n", num_pages - num);
// }

Page new_page() {
	Page p = {.flags = 0};
	return p;
}

char page_is_last(Page p) {
	return p.flags & Last; 
}

char page_is_taken(Page p) {
	return p.flags & Taken ;
} 

char page_is_free(Page p) {
	return !page_is_taken(p);
} 

void page_clear(Page * p) {
	p->flags = Empty;
}

void page_set_flag(Page * p, char flag) {
	p->flags |= flag; 
}
void page_clear_flag(Page * p, char flag) {
	p->flags &= !flag;
}

void map(PageTable * root, uint64_t vaddr, uint64_t paddr, uint64_t bits, uint64_t level) {
	if ((bits & 0xe) == 0) {
		printf("No bits provided, fool!\n"); 
	}

	uint64_t vpn[3] = {(vaddr >> 12) & 0x1ff, (vaddr >> 21) & 0x1ff, (vaddr >> 30) & 0x1ff}; 
	uint64_t ppn[3] = {(paddr >> 12) & 0x1ff, (paddr >> 21) & 0x1ff, (paddr >> 30) & 0x1ff}; 

	Entry * v = &(root->entries[vpn[2]]);

	int i = 2; 
	for (i = 2; i >= 0; i--) {
		// printf("VPN[%d]: %08x\n", i, vpn[i]);
		if (i == level) break; 
		if (Entry_is_invalid(v)) {
			// printf("new page\n");
			void * p = zalloc(1); 
			Entry_set(v, ((uint64_t)(p) >> 2) | Valid );
			// printf("%08x %08x\n", v->entry >> 32, v->entry);
			// v->entry = (((uint64_t)(p)) >> 2) | Valid;
		}

		PageTable * nextTable = (PageTable *)((v->entry & ~(0x3ff)) << 2); 
		// printf("Next Page Table: %08x\n", nextTable);
		v = &(nextTable->entries[vpn[i-1]]);
	}

	uint64_t e = (ppn[2] << 28) | (ppn[1] << 19) | (ppn[0] << 10) | bits | Valid | Dirty | Access; 
	Entry_set(v, e); 
	// v->entry = e;
	// printf("ENTRY: %08x %08x\n", v->entry >> 32, v->entry);
}

void unmap(PageTable * root) {
	int root_len = 512; 
	int i = 0; 
	for (i = 0; i < root_len; i++) {
		Entry * entry_lvl_2 = &(root->entries[i]); 
		if (Entry_is_invalid(entry_lvl_2) && Entry_is_branch(entry_lvl_2)) {
			uint64_t mem_addr_lvl_1 = (entry_lvl_2->entry & ~(0x3ff)) << 2; 
			PageTable * table_lvl_1 = (PageTable *)(mem_addr_lvl_1); 

			int j; 
			for (j = 0; j < root_len; j++) {
				Entry * entry_lvl_1 = &(table_lvl_1->entries[j]); 
				if (Entry_is_invalid(entry_lvl_1) && Entry_is_branch(entry_lvl_1)) {
					uint64_t memaddr_lvl_0 = (entry_lvl_1->entry & ~(0x3ff)) << 2; 
					dealloc((void *)(memaddr_lvl_0));
				}
			}
			dealloc((void *)(mem_addr_lvl_1));
		}
	}
}

uint64_t virt_to_phys(PageTable * root, uint64_t vaddr) {
	uint64_t vpn[3] = {(vaddr >> 12) & 0x1ff, (vaddr >> 21) & 0x1ff, (vaddr >> 30) & 0x1ff};

	Entry * v = &(root->entries[vpn[2]]); 
	uint64_t i = 2;
	for (i = 2; i >= 0; i--) {
		// printf("VPN[%d]: %08x\n", i, vpn[i]);
		// printf("%08x %08x\n", v->entry >> 32, v->entry);
		if (Entry_is_invalid(v)) {
			printf("Invalid :( %d\n", i);
			break; 
		}
		else if (Entry_is_leaf(v)) {
			uint64_t off_mask = (1 << (12 + (i * 9))) - 1; 
			uint64_t vaddr_pgoff = vaddr & off_mask; 
			uint64_t addr = (v->entry << 2) & ~off_mask; 
			return (addr | vaddr_pgoff);
		}

		PageTable * nextTable = (PageTable *)((v->entry & ~(0x3ff)) << 2); 
		// printf("Page Table: %08x\n", nextTable);
		v = &(nextTable->entries[vpn[i-1]]);
	}

	return 0;
} 

void Entry_set(Entry * self, uint64_t val) {
	self->entry = val; 
}
char Entry_is_valid(Entry * self) {
	return (self->entry & Valid);
}
char Entry_is_invalid(Entry * self) {
	return !Entry_is_valid(self); 
}
char Entry_is_leaf(Entry * self) {
	return (self->entry & 0xe) != 0;
}
char Entry_is_branch(Entry * self) {
	return ~Entry_is_leaf(self);
} 

