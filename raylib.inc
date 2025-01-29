
; Raylib
extrn InitWindow
extrn SetTargetFPS
extrn WindowShouldClose
extrn CloseWindow

extrn GetTime
extrn GetMousePosition

extrn BeginDrawing
extrn EndDrawing
extrn ClearBackground
extrn MeasureText
extrn DrawText
extrn DrawCircle
extrn DrawCircleV

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

macro set_target_fps fps {
    mov rdi, fps
    call SetTargetFPS
}

; return value in passed addresses
macro get_mouse_position x, y {

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

; Vec2 pos, float radius, Color color
macro draw_circle pos, radius, color {
    movsd xmm0, [pos]
    mov eax, RADIUS
    movd xmm1, eax
    mov rdi, color
    call DrawCircleV
}
