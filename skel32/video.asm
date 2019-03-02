;; Basic video routines

%ifndef VIDEO_ASM
%define VIDEO_ASM

%define INPUT_STATUS 0x3DA
%define INPUT_FLAG_ENABLED 0x01
%define INPUT_FLAG_RETRACE 0x08

%define SCREEN_WIDTH 320

%include "skel32\util.asm"

USE32

GLOBAL _vid_setmode
_vid_setmode: FUNCTION
    %arg mode:byte

    mov ah, 0x00 ;; BIOS video function: Set Mode
    mov al, byte [mode] ;; Argument: Mode to set
    int 0x10 ;; Trigger BIOS video interrupt

ENDFUNCTION

GLOBAL _vid_getmode
_vid_getmode: FUNCTION
    mov ah, 0x0F ;; BIOS video function: Get Mode
    mov al, 0x00
    int 0x10

    ;; Return value is in al, so we don't need to do anything further to return the mode
ENDFUNCTION

GLOBAL _vid_wait_retrace
_vid_wait_retrace: FUNCTION
    ;; We need to loop doing 'nothing' until the CRTC flags that the beam is travelling back to
    ;; the beginning again (Retrace), and we wait until the CRTC disables itself (So we don't get artifacting)
    .retrace_check:        
        mov dx, INPUT_STATUS
        in al, dx ;; Read port INPUT_STATUS
        and al, INPUT_FLAG_RETRACE ;; & it with INPUT_FLAG_RETRACE
        jz .retrace_check ;; If zero, we're not retracing yet. Loop.
    .enable_check:
        in al, dx ;; Reading same input status register
        and al, INPUT_FLAG_ENABLED ;; Now we're comparing it to INPUT_FLAG_ENABLED
        jnz .enable_check ;; Loop while still enabled
ENDFUNCTION

GLOBAL _vid_draw_pixel
_vid_draw_pixel: FUNCTION
    ;; Simple pixel-drawing implementation. Be aware that calling this is slower than just setting memory directly from your C code.
    ;; Assembly is better for long string operations (E.G: Blitting bitmaps)
    %arg x:word, y:word, color:byte
    
    xor ebx, ebx ;; Clear EBX
    
    mov bx, word [y]
    imul ebx, SCREEN_WIDTH ;; These three instructions are the equivalent of y*SCREEN_WIDTH+x
    add bx, word [x]
    
    add ebx, 0xA0000 ;; Starting location of VGA RAM
    mov al, byte [color]
    mov byte [ebx], al
ENDFUNCTION

%endif