#include <mach/mach.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/sysctl.h>

struct ram {
  host_t host;
  vm_statistics64_data_t vm_stat;
  
  uint64_t total_memory;
  uint64_t free_memory;
  uint64_t used_memory;
  int usage_percent;
};

static inline void ram_init(struct ram* ram) {
  ram->host = mach_host_self();
  
  // Get total physical memory
  size_t size = sizeof(ram->total_memory);
  sysctlbyname("hw.memsize", &ram->total_memory, &size, NULL, 0);
}

static inline void ram_update(struct ram* ram) {
  mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
  
  kern_return_t error = host_statistics64(ram->host,
                                         HOST_VM_INFO64,
                                         (host_info64_t)&ram->vm_stat,
                                         &count);
  
  if (error != KERN_SUCCESS) {
    printf("Error: Could not read memory host statistics.\n");
    return;
  }
  
  // Calculate memory usage
  // Get actual page size dynamically
  size_t page_size_sz = sizeof(vm_size_t);
  vm_size_t page_size;
  sysctlbyname("hw.pagesize", &page_size, &page_size_sz, NULL, 0);
  
  uint64_t free_pages = ram->vm_stat.free_count;
  uint64_t active_pages = ram->vm_stat.active_count;
  uint64_t inactive_pages = ram->vm_stat.inactive_count;
  uint64_t wire_pages = ram->vm_stat.wire_count;
  uint64_t speculative_pages = ram->vm_stat.speculative_count;
  uint64_t compressed_pages = ram->vm_stat.compressor_page_count;
  
  ram->free_memory = (free_pages + speculative_pages) * page_size;
  ram->used_memory = (active_pages + wire_pages + compressed_pages) * page_size;
  
  if (ram->total_memory > 0) {
    ram->usage_percent = (int)((double)ram->used_memory / (double)ram->total_memory * 100.0);
  } else {
    ram->usage_percent = 0;
  }
}