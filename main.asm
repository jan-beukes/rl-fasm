format ELF64
public _start

include 'print.inc'
include 'raylib.inc'

SCREEN_SIZE = 800
GRAVITY = dword 600.0
RADIUS = dword 80.0
DAMP = dword -0.9
SPEED_MAX_VAL = dword 5000.0

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
    mov eax, DAMP
    movd xmm0, eax
    mulss xmm2, xmm0
    movss [vel], xmm2
    play_sound bounce
.next:
}

section '.data' writeable

delta_time dd ?
title db "ASM Physics", 0
text db "FASM", 0
sound_file file 'res/bounce.wav'
sound_size = $ - sound_file
bounce rb 40

;; BALL
is_held db 0
pos Vec2 0.0, 0.0
color Color 255, 0, 255, 255
vel Vec2 0.0, 0.0

zero dd 0.0, 0.0

section '.text' executable
_start:
    mov rbp, rsp
    sub rsp, 32 ; allocate for le Wave

    ; init
    init_window SCREEN_SIZE, SCREEN_SIZE, title
    set_target_fps 120
    call InitAudioDevice
    lea rax, [rbp-32]
    load_wave_from_memory rax, ".wav", sound_file, sound_size
    lea rbx, [rbp-32]
    load_sound_from_wav bounce, rbx

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

    call GetFrameTime
    movss [delta_time], xmm0
    
    call update

    ; Color
    movss xmm0, [vel.x]
    movss xmm1, [vel.y]
    mulss xmm0, xmm0
    mulss xmm1, xmm1
    addss xmm0, xmm1
    mov eax, SPEED_MAX_VAL
    movd xmm1, eax
    mulss xmm1, xmm1
    divss xmm0, xmm1
    mov eax, 255.0
    movd xmm1, eax
    mulss xmm0, xmm1
    cvtss2si eax, xmm0
    cmp eax, 255
    jl .clamp_done
    mov eax, 255
.clamp_done:
    mov byte [color.r], al
    mov cl, 255
    sub cl, al
    mov byte [color.b], cl

    ; drawing
    call BeginDrawing
    ; text
    clear_background 0xFF18181818
    font_size = 100
    measure_text text, font_size
    mov rcx, SCREEN_SIZE
    sub rcx, rax
    shr rcx, 1
    draw_text text, rcx, (SCREEN_SIZE-font_size)/4, font_size, 0xFFAAAAAA
    draw_circle pos, RADIUS, [color]

    call EndDrawing
   
    jmp .main_loop
.end:
    call CloseWindow

    mov rdi, 0
    mov rsp, rbp
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
    call mouse_update

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

mouse_update:
.mouse_y equ rbp-4
.mouse_x equ rbp-8
    push rbp
    mov rbp, rsp
    sub rsp, 8

    ; get mouse pos
    call GetMousePosition
    movq [.mouse_x], xmm0 ; x vs y is endian specific

    ; Mouse Collision
    check_collision_point_circle [pos], RADIUS, [.mouse_x]
    push rbx ; must restore this mf
    mov bl, al
    mov rdi, MOUSE_BUTTON_LEFT
    call IsMouseButtonDown
    and bl, al
    and al, [is_held]
    or bl, al
    mov [is_held], bl
    test bl, bl
    pop rbx
    jz .skip
    
    ; Move ball
    movss xmm0, [.mouse_x]
    subss xmm0, [pos.x] ; dx
    movss xmm1, [.mouse_y]
    subss xmm1, [pos.y] ; dy
    mov eax, 0.1
    movd xmm2, eax
    divss xmm0, xmm2
    divss xmm1, xmm2
    movss [vel.x], xmm0
    movss [vel.y], xmm1

.skip:
    mov rsp, rbp
    pop rbp
    ret

collision:
; local variables
screen_bound equ rbp-4
radius equ rbp-8
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
