format ELF64
public _start

include 'print.inc'
include 'raylib.inc'

SCREEN_SIZE = 800
GRAVITY = dword 600.0
RADIUS = dword 80.0

; pos and vel must be adresses
macro collide_wall wall, pos, vel, jump {
    local .less
    local .greater
    local .continue
    local .next
    movss xmm0, wall
    movss xmm1, [pos]
    movss xmm2, [vel]
    comiss xmm2, [zero]

    comiss xmm1, xmm0
    jump .next

    movss [pos], xmm0
    mov eax, -1.0
    movd xmm0, eax
    mulss xmm2, xmm0
    movss [vel], xmm2
.next:
}

section '.data' writeable

delta_time dd 0.01667
title db "ASM Physics", 0

;; BALL
is_held db 0
pos Vec2 0.0, 0.0
color Color 255, 0, 255, 255
vel Vec2 0.0, 0.0

zero dd 0.0

section '.text' executable
_start:
    mov rbp, rsp

    ; init
    init_window SCREEN_SIZE, SCREEN_SIZE, title
    set_target_fps 60

    ; center ball
    mov eax, SCREEN_SIZE
    mov edx, 0.5
    cvtsi2ss xmm0, eax
    movd xmm1, edx
    mulss xmm0, xmm1
    movss [pos.x], xmm0
    movss [pos.y], xmm0

.main_loop:
    window_should_close
    jnz .end
    
    call update

    ; drawing
    call BeginDrawing

    clear_background 0xFF18181818
    draw_circle pos, RADIUS, [color]

    call EndDrawing
   
    jmp .main_loop
.end:
    call CloseWindow
    mov rdi, 0
    call _exit


update:
    push rbp
    mov rbp, rsp

    mov al, [is_held]
    test al, al
    jnz .pos

    ; gravity
    mov eax, GRAVITY 
    movd xmm0, eax
    mulss xmm0, [delta_time]
    movss xmm1, [vel.y]
    addss xmm1, xmm0
    movss [vel.y], xmm1

.pos:
    call collision
    ;call mouse_update

    ; update pos
    movss xmm0, [vel.x]
    mulss xmm0, [delta_time]
    movss xmm1, [pos.x]
    addss xmm1, xmm0
    movss [pos.x], xmm1

    movss xmm0, [vel.y]
    mulss xmm0, [delta_time]
    movss xmm1, [pos.y]
    addss xmm1, xmm0
    movss [pos.y], xmm1

    pop rbp
    ret


; local variables
screen_bound equ rsp-4
radius equ rsp-8
collision:
    push rbp
    mov rbp, rsp

    ; setup local vars
    mov eax, SCREEN_SIZE
    mov edx, RADIUS
    cvtsi2ss xmm0, eax
    movd xmm1, edx
    subss xmm0, xmm1
    movd [screen_bound], xmm0
    mov dword [radius], RADIUS
    
    collide_wall [screen_bound], pos.x, vel.x, jb 
    collide_wall [radius], pos.x, vel.x, ja
    collide_wall [screen_bound], pos.y, vel.y, jb
    collide_wall [radius], pos.y, vel.y, ja

    pop rbp
    ret

section '.note.GNU-stack'
