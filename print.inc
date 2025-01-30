; libc
extrn printf
extrn _exit

macro setiarg n, value {
    if n = 1
        mov rdi, value
    else if n = 2 
        mov rsi, value
    else if n = 3
        mov rdx, value
    else if n = 4
        mov rcx, value
    else if n = 5
        mov r8, value
    else if n = 6
        mov r9, value
    end if
}

macro setdarg n, value {
    if n = 1
        movsd xmm0, value
    else if n = 2 
        movsd xmm1, value
    else if n = 3
        movsd xmm2, value
    else if n = 4
        movsd xmm3, value
    else if n = 5
        movsd xmm4, value
    else if n = 6
        movsd xmm5, value
    end if
}

macro print string {
    if string eqtype ""
        local .s
        jmp @f
        .s db string, 10, 0
        @@:
        mov rdi, .s
    else
        mov rdi string
    end if

    call printf
}

macro print_int fmt, [arg] {
    common
        if fmt eqtype ""
            local .s
            ; makes sure data is not executed
            jmp @f
            .s db fmt, 10, 0 
            @@:
            mov rdi, .s
        else 
            mov rdi, fmt
        end if
        ; counter
        local i
        i = 2
    forward
        mov rsi, arg
    common
        call printf
}

macro print_float fmt, [arg] {
    common
        if fmt eqtype ""
            local .s
            jmp @f
            .s db fmt, 10, 0
            @@:
            mov rdi, .s
        else 
            mov rdi, fmt
        end if
        ; counter
        local i
        i = 1
    forward
        movss xmm6, arg
        cvtss2sd xmm6, xmm6
        setdarg i, xmm6
        i = i + 1
    common
        mov eax, i
        call printf
}

