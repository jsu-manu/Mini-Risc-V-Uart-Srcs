// #include<kmem.h>
// #include<printf.h>
// #include<qemu.h>  
#include"kmem.h" 

void kmem_init() {
	// ATaken = 0x8000000000000000;
	ATaken = ((uint64_t)(1)) << 63;
	KMEM_ALLOC = 512; 
	void * k_alloc = zalloc(KMEM_ALLOC); 
	KMEM_HEAD = (AllocList *)(k_alloc); 
	AL_set_free(KMEM_HEAD);
	AL_set_size(KMEM_HEAD, KMEM_ALLOC * PAGE_SIZE);
	KMEM_PAGE_TABLE = (PageTable *)(zalloc(1));
} 

uint64_t align_val(uint64_t val, uint64_t order) {
	uint64_t o = (1 << order) - 1; 
	return ((val + o) & ~o);
}
void * kzmalloc(size_t sz) {
	size_t size = align_val(sz, 3);
	void * ret = kmalloc(size); 
	if (ret != NULL) {
		size_t i = 0; 
		for (i = 0; i < size; i++) {
			*(uint8_t *)(ret + i) = 0; 
		}
	}
	return ret; 
}

void * kmalloc(size_t sz) {
	size_t size = align_val(sz, 3);
	// printf("SIZE = %d\n", size);
	AllocList * head = KMEM_HEAD; 
	AllocList * tail = (AllocList *)((uint64_t)(KMEM_HEAD) + (KMEM_ALLOC * PAGE_SIZE)); 

	while ((uint64_t)head < (uint64_t)tail) {
		// printf("HEAD: %08x: %08x %08x\n", head, head->flags_size >> 32, head->flags_size);
		if (AL_is_free(head) && (size <= AL_get_size(head))) {
			// printf("Free at %08x with size %08x %08x\n", head, AL_get_size(head) >> 32, AL_get_size(head));
			uint64_t chunk_size = AL_get_size(head); 
			uint64_t rem = chunk_size - size; 
			AL_set_taken(head); 
			// printf("%08x %08x\n", head->flags_size >> 32, head->flags_size);
			if (rem > sizeof(AllocList)) {
				// AllocList * next = (AllocList *)((uint64_t)head + size); 
				AllocList * next = head + size;
				AL_set_free(next);
				AL_set_size(next, rem); 
				// printf("NEXT: %08x: %08x %08x\n", next, next->flags_size >> 32, next->flags_size);
				AL_set_size(head, size);
				// printf("HEAD: %08x: %08x %08x\n", head, head->flags_size >> 32, head->flags_size);
			} else {
				AL_set_size(head, chunk_size); 
			}
			
			return (void *)((uint64_t)head + sizeof(AllocList));
			// return (void *)(head + sizeof(AllocList));
		} else {
			head = (AllocList *)(head + AL_get_size(head));
		}
	} 
	// printf("sad\n");

	void * undef = NULL;
	return undef;
}

void kfree(void * ptr) {
	if (ptr != NULL) {
		AllocList *p = (AllocList *)(ptr - sizeof(AllocList));
		if (AL_is_taken(p)) {
			AL_set_free(p); 
		}
		coalesce();
	}
}

void coalesce() {
	AllocList * head = KMEM_HEAD; 
	AllocList * tail = KMEM_HEAD + (KMEM_ALLOC * PAGE_SIZE); 
	while ((uint64_t)head < (uint64_t) tail) {
		AllocList * next = head + AL_get_size(head);
		if (AL_get_size(head) == 0) {
			//printf("Double free!\n");
			break; 
		} else if ((uint64_t)next >= (uint64_t)tail) {
			//Done
			break;
		} else if (AL_is_free(head) && AL_is_free(next)) {
			AL_set_size(head, AL_get_size(head) + AL_get_size(next));
		}
		head = head + AL_get_size(head); 
	}
} 

AllocList AL_init() {
	AllocList a = {.flags_size = 0};
	return a;
}

char AL_is_taken(AllocList * self) {
	if ((self->flags_size & ATaken) != (uint64_t)(0))
		return 1;
	else 
		return 0;
	// return (self->flags_size & ATaken);
}
char AL_is_free(AllocList * self) {
	if ((self->flags_size & ATaken) == (uint64_t)(0))
		return 1;
	else 
		return 0;
	// return !AL_is_taken(self);
}
void AL_set_taken(AllocList * self) {
	self->flags_size |= ATaken; 
}
void AL_set_free(AllocList * self) {
	self->flags_size &= ~ATaken;
}
void AL_set_size(AllocList * self, uint64_t size) {
	char k = AL_is_taken(self);
	self->flags_size = size;
	if (k) {
		// printf("Taken!\n");
		AL_set_taken(self);
	}
}
uint64_t AL_get_size(AllocList * self) {
	return self->flags_size & ~ATaken;
}