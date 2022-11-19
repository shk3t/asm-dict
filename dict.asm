global find_word

%include "lib.inc"


section .text

find_word:
    add rsi, 8
    call string_equals
    test rax, rax
    jnz .occurence
    sub rsi, 8
    mov rsi, [rsi]
    cmp qword[rsi], 0
    jnz find_word
    .not_found:
        xor rax, rax
        ret
    .occurence:
        dec rsi
        .get_value:
            inc rsi
            cmp byte[rsi], 0
            jnz .get_value
        inc rsi
        mov rax, rsi
        ret
