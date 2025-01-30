
; Raylib
extrn InitWindow
extrn SetTargetFPS
extrn WindowShouldClose
extrn CloseWindow
extrn InitAudioDevice
extrn LoadWaveFromMemory
extrn LoadImageFromMemory
extrn LoadTextureFromImage
extrn LoadSoundFromWave
extrn PlaySound

extrn GetFrameTime
extrn GetTime
extrn GetMousePosition
extrn GetMouseDelta
extrn CheckCollisionPointCircle
extrn IsMouseButtonDown

extrn BeginDrawing
extrn EndDrawing
extrn ClearBackground
extrn MeasureText
extrn DrawTexturePro
extrn DrawText
extrn DrawCircle
extrn DrawCircleV

MOUSE_BUTTON_LEFT    = 0
MOUSE_BUTTON_RIGHT   = 1

; Useful Raylib structures

struc Vec2 x, y {
    .x dd x
    .y dd y
}

struc Color r, g, b, a {
    .r db r
    .g db g
    .b db b
    .a db a
}

macro init_window width, height, title {
    mov rdi, width
    mov rsi, height
    mov rdx, title
    call InitWindow
}

macro load_wave_from_memory wave_ptr, type, data_ptr, size {
    local .type
    jmp @f
.type: db type, 0
    @@:
    mov rsi, .type
    mov rdi, wave_ptr
    mov rdx, data_ptr
    mov rcx, size
    call LoadWaveFromMemory

}

macro load_image_from_memory img_ptr, type, data_ptr, size {
    local .type
    jmp @f
.type: db type, 0
    @@:
    mov rdi, img_ptr
    mov rsi, .type
    mov rdx, data_ptr
    mov rcx, size
    call LoadImageFromMemory
}

macro load_texture_from_image texture_ptr, img_ptr {
    sub rsp, 32 
    mov rdi, texture_ptr
    mov rax, qword [img_ptr]
    mov [rsp], rax
    mov rax, qword [img_ptr+8]
    mov [rsp+8], rax
    mov rax, qword [img_ptr+16]
    mov [rsp+16], rax
    call LoadTextureFromImage
    add rsp, 32 
}

macro pack_floats x1, x2 {
    movd eax, x1
    movd ecx, x2
    shl rax, 32
    or rax, rcx
    movq x1, rax
}

; Big struct on stack others go to registers
; centered
macro draw_texture texture_ptr, src_rect, dst_rect, origin, rot, color {
    sub rsp, 32 ; allocate 16 alligned event though we only need 20
    mov rax, qword [texture_ptr]
    mov [rsp], rax
    mov rax, qword [texture_ptr+8]
    mov [rsp+8], rax
    mov eax, dword [texture_ptr+16]
    mov [rsp+16], eax
    ; 20 bytes

    ; source rect xmm0 and xmm1
    movq xmm0, qword [src_rect]
    movq xmm1, qword [src_rect+8]
    movq xmm2, qword [dst_rect]
    movq xmm3, qword [dst_rect+8]
    movq xmm4, qword [origin]
    movss xmm5, rot
    mov rdi, color

    call DrawTexturePro
    add rsp, 32
}


macro load_sound_from_wav sound_ptr, wave_ptr {
    sub rsp, 32
    mov rcx, rsp
    mov rdi, sound_ptr 
    mov rax, [wave_ptr]
    mov [rcx], rax
    mov rax, [wave_ptr+8]
    mov [rcx+8], rax
    mov rax, [wave_ptr+16]
    mov [rcx+16], rax
    call LoadSoundFromWave
    add rsp, 32
}

macro play_sound sound_ptr {
    sub rsp, 48 ; allign :(
    mov rax, qword [sound_ptr]
    mov [rsp], rax
    mov rax, qword [sound_ptr+8]
    mov [rsp+8], rax
    mov rax, qword [sound_ptr+16]
    mov [rsp+16], rax
    mov rax, qword [sound_ptr+24]
    mov [rsp+24], rax
    mov rax, qword [sound_ptr+32]
    mov [rsp+32], qword rax
    call PlaySound
    add rsp, 48 
}

macro set_target_fps fps {
    mov rdi, fps
    call SetTargetFPS
}

macro window_should_close {
    call WindowShouldClose
    test rax, rax
}

; Color or constant
macro clear_background color {
    if color eqtype 0x1
        mov rdi, color
    else
        mov rdi, [color]
    end if
    call ClearBackground
}

macro check_collision_point_circle circle, radius, point {
    mov eax, radius
    movsd xmm0, circle
    movsd xmm1, point
    movd xmm2, eax
    call CheckCollisionPointCircle
}

macro draw_text text, x, y, size, color {
    if eqtype text ""
        local .str
        jmp @f
    .str: db text, 0
    @@:
    end if 
    mov rdi, text
    mov rsi, x
    mov rdx, y
    mov rcx, size
    mov r8, color
    call DrawText
}

macro measure_text text, size {
    if eqtype text ""
        local .str
        jmp @f
    .str: db text, 0
        @@:
    end if
    mov rdi, text
    mov rsi, size
    call MeasureText
}

; Vec2 pos, float radius, Color color
macro draw_circle pos, radius, color {
    movq xmm0, [pos]
    mov eax, RADIUS
    movd xmm1, eax
    mov rdi, color
    call DrawCircleV
}
