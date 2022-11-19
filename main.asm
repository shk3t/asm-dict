global _start

%include "words.inc"
%include "lib.inc"
extern find_word


section .data
prompt: db "Input your key: ", 0
output: db "Your value: ", 0
invalid_input_error: db "Invalid input", 0
not_found_error: db "Keyword not found", 0


section .text

print_error:
    mov rsi, rdi
    call string_length
    mov rdi, 2
    mov rdx, rax
    mov rax, 1
    syscall
    ret

_start:
    mov rdi, prompt
    call print_string
    call read_word
    test rax, rax
    jz .invalid_input

    mov rdi, rax
    mov rsi, NEXT
    call find_word
    test rax, rax
    jz .not_found

    .success:
        push rax
        mov rdi, output
        call print_string
        pop rdi
        call print_string
        call exit
    .invalid_input:
        mov rdi, invalid_input_error
        call print_error
        call exit
    .not_found:
        mov rdi, not_found_error
        call print_error
        call exit
