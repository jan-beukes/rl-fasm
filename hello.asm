format ELF64

; Raylib
include 'raylib.inc'

; symbolic constants
;
SCREEN_SIZE equ 800
FONT_SIZE equ 64

section '.data' writable
pos:
   dd 0.0
   dd 0.0
dir: 
   dd 1.0
   dd 1.0

text_width: dd 0.0

zero: dd 0.0
twenty: dq 20.0
minus_one: dd -1.0

speed: dd 8.0

background: db 0x18, 0x18, 0x18, 0xFF
color: db 0xFF, 0x00, 0x00, 0xFF

msg: db "Hello from Asm", 10, 0 ; newline and null
title: db "Hello Asm", 0
fmt: db "value: %f", 10, 0

; code
section '.text' executable
extrn printf
extrn _exit

draw_msg_text:
    push rbp
    mov rbp, rsp

    mov rdi, msg 
    movss xmm1, [pos]
    cvtss2si esi, xmm1
    movss xmm1, [pos+4]
    cvtss2si edx, xmm1
    mov ecx, FONT_SIZE
    mov r8, [color]
    call DrawText

    pop rbp
    ret

debug_print:
    push rbp

    mov rdi, fmt
    call printf
 
    pop rbp
    ret

; dir offset, pos offset, xmm0 value
bounce:
    push rbp
    mov rbp, rsp
    
    ; set pos
    mov rax, pos

    add rax, rsi
    movss [rax], xmm0

    ; negate dir
    mov rax, dir
    add rax, rdi
    movss xmm0, [rax]
    mulss xmm0, [minus_one]
    movss [rax], xmm0

    pop rbp
    ret

check_collisions:
    push rbp
    mov rbp, rsp

    mov rax, SCREEN_SIZE
    mov rbx, FONT_SIZE

    ; Window width
    cvtsi2ss xmm0, rax
    subss xmm0, [text_width] ; x - width
    movss xmm1, [pos]

    comiss xmm1, xmm0
    jb .width

    mov rdi, 0
    mov rsi, 0
    call bounce
    jmp .collide_y
.width:
    comiss xmm1, [zero]
    ja .collide_y

    movss xmm0, [zero]
    mov rdi, 0
    mov rsi, 0
    call bounce

.collide_y:
    ; Window height
    cvtsi2ss xmm0, rax
    cvtsi2ss xmm2, rbx
    movss xmm1, [pos+4]
    subss xmm0, xmm2 ; y - font size
    comiss xmm1, xmm0
    jb .height
    ; colide
    mov rdi, 4
    mov rsi, 4
    call bounce

.height:
    comiss xmm1, [zero]
    ja .continue
    ; colide
    movss xmm0, [zero]
    mov rdi, 4
    mov rsi, 4
    call bounce

.continue:
    pop rbp
    ret

public _start
_start:
    mov rbp, rsp ; setup stack frame by putting top of stack in rbp

    mov rdi, SCREEN_SIZE
    mov rsi, SCREEN_SIZE
    mov rdx, title
    call InitWindow

    mov rdi, 60
    call SetTargetFPS


    ; initialize position
    mov rdi, msg
    mov rsi, FONT_SIZE
    call MeasureText
    ; x
    mov ebx, SCREEN_SIZE
    sub ebx, eax ; text width
    shr ebx, 1
    cvtsi2ss xmm0, ebx
    movss [pos], xmm0
    ; y
    mov ebx, SCREEN_SIZE
    sub ebx, FONT_SIZE
    shr ebx, 1
    cvtsi2ss xmm0, ebx
    movss [pos+4], xmm0
    ; store text size
    cvtsi2ss xmm0, eax
    movss [text_width], xmm0

.again:
    call WindowShouldClose
    test rax, rax ; if rax && rax
    jnz .end

    call check_collisions

    ; update xpos
    movss xmm0, [dir]
    mulss xmm0, [speed]
    movss xmm1, [pos]
    addss xmm0, xmm1
    movss [pos], xmm0
    ; update ypos
    movss xmm0, [dir+4]
    mulss xmm0, [speed]
    movss xmm1, [pos+4]
    addss xmm1, xmm0
    movss [pos+4], xmm1

    ; Colors
    call GetTime
    mulsd xmm0, [twenty]
    cvtsd2si rax, xmm0
    mov byte [color+2], al
    mov dl, 255
    sub dl, al
    mov byte [color+1], dl

    call BeginDrawing

    mov rdi, [background]
    call ClearBackground

    call draw_msg_text

    call EndDrawing

    jmp .again
.end:
    mov rdi, 0
    call _exit

section '.note.GNU-stack'
