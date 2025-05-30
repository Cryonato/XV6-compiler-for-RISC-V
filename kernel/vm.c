#include "param.h"
#include "types.h"
#include "memlayout.h"
#include "elf.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "spinlock.h"

/*
 * the kernel's page table.
 */
pagetable_t kernel_pagetable;

struct spinlock refcount_lock;  // Single global lock for all reference counts



struct {
  struct phys_addr_refcount refcount_entry[MAXPHYSICALFRAMES];
  struct spinlock refcount_lock;
} refcount_table;


extern char etext[];  // kernel.ld sets this to end of kernel code.

extern char trampoline[]; // trampoline.S



// Make a direct-map page table for the kernel.
pagetable_t
kvmmake(void)
{
  pagetable_t kpgtbl;

  kpgtbl = (pagetable_t) kalloc();
  memset(kpgtbl, 0, PGSIZE);

  // uart registers
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);

  // virtio mmio disk interface
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);

  // PLIC
  kvmmap(kpgtbl, PLIC, PLIC, 400000, PTE_R | PTE_W);

  // map kernel text executable and read-only.
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);

  // map kernel data and the physical RAM we'll make use of.
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);

  // map the trampoline for trap entry/exit to
  // the highest virtual address in the kernel.
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

  // allocate and map a kernel stack for each process.
  proc_mapstacks(kpgtbl);
  
  return kpgtbl;
}

// Initialize the one kernel_pagetable
void
kvminit(void)
{
  kernel_pagetable = kvmmake();
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));

  // flush stale entries from the TLB.
  sfence_vma();
}

// Return the address of the PTE in page table pagetable
// that corresponds to virtual address va.  If alloc!=0,
// create any required page-table pages.
//
// The risc-v Sv39 scheme has three levels of page-table
// pages. A page-table page contains 512 64-bit PTEs.
// A 64-bit virtual address is split into five fields:
//   39..63 -- must be zero.
//   30..38 -- 9 bits of level-2 index.
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
  if(va >= MAXVA)
    panic("walk");

  for(int level = 2; level > 0; level--) {
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
}

// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    return 0;

  pte = walk(pagetable, va, 0);
  if(pte == 0)
    return 0;
  if((*pte & PTE_V) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}

// add a mapping to the kernel page table.
// only used when booting.
// does not flush TLB or enable paging.
void
kvmmap(pagetable_t kpgtbl, uint64 va, uint64 pa, uint64 sz, int perm)
{
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    panic("kvmmap");
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
  last = PGROUNDDOWN(va + size - 1);
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
      return -1;
    if(*pte & PTE_V)
      panic("mappages: remap");
    increment_ref_count(pa);
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

void init_refcount_table() {

  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    refcount_table.refcount_entry[i].pa = 0;
    refcount_table.refcount_entry[i].ref_count = 0;
  }
}

// Increment the reference count for a physical address
void increment_ref_count(uint64 pa) {
  // Align the physical address to page boundary
  pa = PGROUNDDOWN(pa);

  // Special case: Allow MMIO regions
  if (pa == UART0 || pa == VIRTIO0 || (pa >= PLIC && pa < PLIC + 0x400000)) {
    return;  // Allow mapping without reference counting
  }
  
  // Check if address is within valid physical memory range
  if ((pa < KERNBASE || pa >= PHYSTOP)) {
    printf("Error: PA %p outside valid range [%p, %p]\n", 
           pa, KERNBASE, PHYSTOP);
    panic("increment_ref_count: invalid physical address");
  }
  acquire(&refcount_lock);
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    
    if (refcount_table.refcount_entry[i].pa == pa) {
      refcount_table.refcount_entry[i].ref_count++;
      release(&refcount_lock);
      return;
    }
  }
  // If the physical address is not found, add it to the table
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    if (refcount_table.refcount_entry[i].ref_count == 0) {
      refcount_table.refcount_entry[i].pa = pa;
      refcount_table.refcount_entry[i].ref_count = 1;
      release(&refcount_lock);
      return;
    }
  }
  release(&refcount_lock);

  // Table is full - print diagnostic information
  printf("refcount_table is full: %d entries\n", MAXPHYSICALFRAMES);
  printf("Failed to add PA: %p\n", pa);
  if (pa == UART0 || pa == VIRTIO0 || (pa >= PLIC && pa < PLIC + 0x400000)) {
    printf("Debug: This is MMIO region at %p\n", (uint)pa);
  }
  
  panic("increment_ref_count: no space in refcount_table");
}

// Decrement the reference count for a physical address and deallocate if it hits zero
void decrement_ref_count(uint64 pa) {
  pa = PGROUNDDOWN(pa);

  acquire(&refcount_lock);
  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    if (refcount_table.refcount_entry[i].pa == pa) {
      refcount_table.refcount_entry[i].ref_count--;
      if (refcount_table.refcount_entry[i].ref_count == 0) {
        kfree((void*)pa);  // Deallocate the physical address
        refcount_table.refcount_entry[i].pa = 0;
      }
      release(&refcount_lock);
      return;
    }
  }
  release(&refcount_lock);

  panic("decrement_ref_count: physical address not found");
}

uint64
uvmfind(pagetable_t pagetable, uint64 pa)
{
  pte_t *pte;
  uint64 va;

  // Iterate over the entire virtual address space.
  // MAXVA is assumed to be the maximum valid virtual address.
  for(va = 0; va < MAXVA; va += PGSIZE){
    pte = walk(pagetable, va, 0);
    if(pte == 0)
      continue;             // No page table entry for this va.
    if((*pte & PTE_V) == 0)
      continue;             // Entry is not valid.
    if(PTE2PA(*pte) == pa)
      return va;            // Found the mapping; return the virtual address.
  }
  return 0;                 // No mapping found.
}

int
find_ref_count(uint64 pa){
  pa = PGROUNDDOWN(pa);

  for (int i = 0; i < MAXPHYSICALFRAMES; i++) {
    if (refcount_table.refcount_entry[i].pa == pa) {
      return refcount_table.refcount_entry[i].ref_count;
    }
      
  }
  panic("cow_fault: physical page not found in refcount table");
}




// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages)
{
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
      panic("uvmunmap: not a leaf");
    uint64 pa = PTE2PA(*pte);

    decrement_ref_count(pa);
    *pte = 0;
  }
}

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
  if(pagetable == 0)
    return 0;
  memset(pagetable, 0, PGSIZE);
  return pagetable;
}

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
  char *mem;

  if(sz >= PGSIZE)
    panic("uvmfirst: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
  memmove(mem, src, sz);
}

// Allocate PTEs and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
uint64
uvmalloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz, int xperm)
{
  char *mem;
  uint64 a;

  if(newsz < oldsz)
    return oldsz;

  oldsz = PGROUNDUP(oldsz);
  for(a = oldsz; a < newsz; a += PGSIZE){
    mem = kalloc();
    if(mem == 0){
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
      kfree(mem);
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
  }
  return newsz;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  if(newsz >= oldsz)
    return oldsz;

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages);
  }

  return newsz;
}

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
}

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
  if(sz > 0)
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE);
  freewalk(pagetable);
}

// Given a parent process's page table, copy
// its memory into a child's page table.
// Copies both the page table and the
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
      kfree(mem);
      goto err;
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE);
  return -1;
}

// Custom function that maps child pagetable to parent pagetable

// TODO use the PTE_S flag to differentiate between cow and write protected pages
int
uvmremap(pagetable_t parent, pagetable_t child, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walk(parent, i, 0)) == 0)
      panic("uvmremap: pte should exist");
    if((*pte & PTE_V) == 0)
      panic("uvmremap: page not present");

    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    
    // If the page was writable, mark it as COW (clear PTE_W, set a custom COW flag)
    if (flags & PTE_W) {
      flags = flags | PTE_COW; // Use a reserved bit for COW entries
      *pte = *pte  | PTE_COW;
    }
    flags = flags & ~PTE_W;
    *pte = *pte & ~PTE_W;        // Updates the parents page table entry
    // Mappinig new page table netry to child
    if(mappages(child, i, PGSIZE, pa, flags) != 0){
      panic("uvmremap: couldnt map pte to child");
    }
  }
  return 0;
}



// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
  if(pte == 0)
    panic("uvmclear");
  *pte &= ~PTE_U;
}

// Copy from kernel to user.
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    va0 = PGROUNDDOWN(dstva);
    // Get the PTE to check for COW
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
      return -1;

    // Handle COW if needed
    if(*pte & PTE_COW) {
      uint64 pa = PTE2PA(*pte);
      char *mem = kalloc();
      if(mem == 0)
        return -1;
      memmove(mem, (char*)pa, PGSIZE);
      uint flags = (PTE_FLAGS(*pte) & ~PTE_COW) | PTE_W;
      // Update PTE with new page and flags
      *pte = PA2PTE(mem) | flags;
      *pte = *pte & ~PTE_COW;
      increment_ref_count((uint64)mem);
      decrement_ref_count(pa);
    }

    pa0 = PTE2PA(*pte);
    n = PGSIZE - (dstva - va0);
    if(n > len) n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);

    len -= n;
    src += n;
    dstva = va0 + PGSIZE;
  }
  return 0;
}

// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);

    len -= n;
    dst += n;
    srcva = va0 + PGSIZE;
  }
  return 0;
}

// Copy a null-terminated string from user to kernel.
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
        got_null = 1;
        break;
      } else {
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    return 0;
  } else {
    return -1;
  }
}
