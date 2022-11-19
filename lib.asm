global exit
global string_length
global print_string
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global read_word
global parse_uint
global parse_int
global string_copy


section .text

; Принимает код возврата и завершает текущий процесс
exit:
    xor rdi, rdi
    mov rax, 60
    syscall

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    mov rax, -1
    .loop:
        inc rax
        cmp byte[rdi + rax], 0
        jnz .loop
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
    mov rsi, rdi
    call string_length
    mov rdi, 1
    mov rdx, rax
    mov rax, 1
    syscall
    ret

; Принимает код символа и выводит его в stdout
print_char:
    push rdi
    mov rsi, rsp
    mov rdi, 1
    mov rdx, 1
    mov rax, 1
    syscall
    pop rdi
    ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rdi, 10
    jmp print_char

; Выводит беззнаковое 8-байтовое число в десятичном формате
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    mov r8, rsp
    mov rax, rdi
    dec rsp
    mov byte[rsp], 0
    .loop:
        xor rdx, rdx
        mov rcx, 10
        div rcx
        add rdx, "0"
        dec rsp
        mov byte[rsp], dl
        test rax, rax
        jnz .loop
    mov rdi, rsp
    push r8
    call print_string
    pop rsp
    ret

; Выводит знаковое 8-байтовое число в десятичном формате
print_int:
    test rdi, rdi
    jns .positive
    neg rdi
    push rdi
    mov rdi, "-"
    call print_char
    pop rdi
    .positive:
        jmp print_uint

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
    xor rcx, rcx
    .loop:
        mov r8b, byte[rdi + rcx]
        cmp byte[rsi + rcx], r8b
        jne .false
        inc rcx
        test r8b, r8b
        jne .loop
    .true:
        mov rax, 1
        ret
    .false:
        xor rax, rax
        ret

; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока read_char:
read_char:
    push 0
    lea rsi, [rsp]
    xor rax, rax
    xor rdi, rdi
    mov rdx, 1
    syscall
    pop rax
    ret

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор
read_word:
    mov r8, rdi         ; buffer pointer
    mov r9, rsi         ; buffer size
    xor r10, r10        ; char counter
    .skip:
        call read_char
        test rax, rax
        jz .end
        cmp al, 0x20
        je .skip
        cmp al, 0x9
        je .skip
        cmp al, 0xA
        je .skip
    mov byte[r8], al
    inc r10
    .next:
        call read_char
        test rax, rax
        jz .end
        cmp al, 0x20
        je .end
        cmp al, 0x9
        je .end
        cmp al, 0xA
        je .end
        mov byte[r8 + r10], al
        inc r10
        cmp r10, r9
        jle .next
    .fail:
        xor rax, rax
        ret
    .end:
        mov byte[r8 + r10], 0
        mov rdx, r10
        mov rax, r8
        ret

; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
    xor rax, rax
    xor rcx, rcx
    xor r8, r8
    mov r10, 10
    .loop:
        mov r8b, byte[rdi + rcx]
        cmp r8b, "0"
        jl .end
        cmp r8b, "9"
        jg .end
        sub r8b, "0"
        mul r10
        add rax, r8
        inc rcx
        jmp .loop
    .end:
        mov rdx, rcx
        ret

; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был)
; rdx = 0 если число прочитать не удалось
parse_int:
    cmp byte[rdi], "-"
    jne parse_uint
    inc rdi
    call parse_uint
    neg rax
    inc rdx
    ret

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    call string_length
    cmp rax, rdx
    jg .cancel
    xor rcx, rcx
    .loop:
        mov r8b, byte[rdi + rcx]
        mov byte[rsi + rcx], r8b
        inc rcx
        cmp rcx, rax
        jle .loop
        ret
    .cancel:
        xor rax, rax
        ret
