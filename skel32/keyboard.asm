;; Keyboard handler. The blackest of magic written and rewritten after reading the source code
;; to multiple old DOS games.
;; This is a really simple one, no fancy features.

%ifndef KEYBOARD_ASM
%define KEYBOARD_ASM

%include "skel32\util.asm"

;; For the ISR it's essential that we define the segments explitly, since we need to reference
;; the scope of our code and data from the ISR itself.
SEGMENT _DATA PUBLIC ALIGN=4 USE32 class=DATA
    ;; Some local storage, for keeping a pointer to the old ISR, the array of scancodes, etc.

    GLOBAL _kbd_scanbuffer ;; C-visible scanbuffer
    _kbd_scanbuffer resb 128

    ;; Segment and Offset to original keyboard handler
    old_int_seg resw 1
    old_int_off resw 1

SEGMENT _TEXT PUBLIC ALIGN=4 USE32 class=CODE

;; Set up DGROUP. If you add a BSS segment, define it and add it to this after _DATA
GROUP DGROUP _DATA

;; Installs the keyboard handler
GLOBAL _kbd_install
_kbd_install: FUNCTION
    ;; Save our registers from getting clobbered
    push eax
    push ebx
    push ds
    push es

    ;; First we save the old ISR
    mov eax, 0x3509 ;; DOS function 0x35 (Get Vector), argument 0x09 (Interrupt Number. 0x09 is the keyboard interrupt)
    int 0x21 ;; ES:EBX is now pointing to the old 0x09 ISR
    
    ;; Let's save it to our data section
    mov word [old_int_seg], es
    mov dword [old_int_off], ebx

    ;; Install the new ISR
    mov eax, 0x2509 ;; DOS Function 0x25 (Set Vector). AL=Interrupt to change, DS:EDX=Pointer to new handler
    mov edx, kbd_handler
    mov bx, _TEXT ;; Need to give the DOS function our current code segment
    mov ds, bx
    int 0x21

    ;; Restore the registers we clobbered
    pop es
    pop ds
    pop ebx
    pop eax
ENDFUNCTION

;; Uninstall our keyboard handler, restore the original one
GLOBAL _kbd_uninstall
_kbd_uninstall: FUNCTION
    ;; Save registers again
    push eax
    push ebx
    push edx
    push ds

    ;; Reset BIOS key handler state
    cli
    mov ebx, 0x041C
    mov al, byte [ebx] ;; Read from BIOS area to get key state
    mov ebx, 0x041A
    mov byte [ebx], al ;; Write it back
    sti

    ;; Do the same as in _kbd_install, but using pointer we saved
    mov eax, 0x2509
    mov edx, dword [old_int_off]
    mov bx, word [old_int_seg]
    mov ds, bx
    int 0x21

    ;; Restore registers
    pop ds
    pop edx
    pop ebx
    pop eax
ENDFUNCTION

;; The actual keyboard handler. Note that it doesn't use the FUNCTION/ENDFUNCTION macros,
;; as this needs to use iret (Interrupt return). Also, with interrupts, you ABSOLUTELY NEED to
;; preserve the state of ALL registers used.
kbd_handler:
    pushfd ;; Push CPU flags
    push eax
    push ebx
    push ecx
    push edx
    push ds

    mov ax, DGROUP ;; Set DS to DGROUP so we can access the scanbuffer
    mov ds, ax

    xor eax, eax
    xor ebx, ebx

    ;; Read key
    in al, 0x60

    ;; Check if it's a key press or key release (High-bit set == Release)
    cmp al, 128
    jnb .key_release
.key_press:
    ;; Write 1 into scanbuffer at key location
    mov byte [_kbd_scanbuffer+eax], 1
    jmp .key_end
.key_release:
    ;; Write 0 into scanbuffer at key location
    ;; AND the value with 127 to clear the high-bit
    and al, 127
    mov byte [_kbd_scanbuffer+eax], 0
.key_end:

    ;; OK, we can pop the registers now, we'll be handing over to the BIOS handler.
    ;; This is useful for debugging, since we can "Break out" of our game even if we've broken something.
    ;; In production, you'll want to remove this and do your own keyboard ACK.
    pop ds
    pop edx
    pop ecx
    pop ebx
    pop eax

    ;; Now we get ready to jump into the BIOS handler
    sub esp, 8 ;; Make some space on the stack
    push ds
    push eax
    mov ax, DGROUP
    mov ds, ax
    mov eax, dword [old_int_off]
    mov [esp+8], eax
    movzx eax, word [old_int_seg]
    mov [esp+12], eax
    pop eax
    pop ds

    iretd

%endif