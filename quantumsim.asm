format ELF64 executable
entry start

SYS_WRITE   = 1
SYS_EXIT    = 60
SYS_NANOSLEEP = 35
STDOUT      = 1

section .data align 16

one:        dq 1.0
zero:       dq 0.0
half:       dq 0.5
sqrt2_inv:  dq 0.70710678118654752440
pi:         dq 3.14159265358979323846
two_pi:     dq 6.28318530717958647692

banner:     db 0x1B, "[1;35m╔══════════════════════════════════════════════════════════════╗", 0x0A
            db "║        QUANTUM COMPUTING SIMULATION - ASSEMBLY QPU           ║", 0x0A
            db "║              Single Qubit State Evolution Engine             ║", 0x0A
            db "╚══════════════════════════════════════════════════════════════╝", 0x1B, "[0m", 0x0A, 0
banner_len = $ - banner

state_hdr:  db 0x0A, 0x1B, "[1;36mCurrent Quantum State:", 0x1B, "[0m", 0x0A
            db "  |ψ⟩ = ", 0
state_hdr_len = $ - state_hdr

plus_sign:  db " + ", 0
minus_sign: db " - ", 0
i_char:     db "i", 0
ket0:       db "|0⟩", 0
ket1:       db "|1⟩", 0
newline:    db 0x0A, 0
tab:        db "    ", 0

prob_str:   db 0x0A, 0x1B, "[33m  Measurement Probabilities:", 0x1B, "[0m", 0x0A
            db "  P(|0⟩) = ", 0
prob0_len = $ - prob_str
prob1_str:  db "  P(|1⟩) = ", 0

bloch_str:  db 0x0A, 0x1B, "[32m  Bloch Sphere Coordinates:", 0x1B, "[0m", 0x0A
            db "  θ = ", 0
theta_len = $ - bloch_str
phi_str:    db "  φ = ", 0

apply_h:    db 0x0A, 0x1B, "[1;31m» Applying Hadamard Gate (H)...", 0x1B, "[0m", 0x0A, 0
apply_x:    db 0x0A, 0x1B, "[1;31m» Applying Pauli-X Gate (NOT)...", 0x1B, "[0m", 0x0A, 0
apply_m:    db 0x0A, 0x1B, "[1;31m» Performing Measurement...", 0x1B, "[0m", 0x0A, 0

result_0:   db 0x0A, 0x1B, "[1;42;37m  MEASUREMENT RESULT: |0⟩  ", 0x1B, "[0m", 0x0A, 0
result_1:   db 0x0A, 0x1B, "[1;41;37m  MEASUREMENT RESULT: |1⟩  ", 0x1B, "[0m", 0x0A, 0

menu:       db 0x0A, 0x1B, "[1;34mCommands:", 0x1B, "[0m", 0x0A
            db "  [H] Hadamard  [X] Pauli-X  [M] Measure  [R] Reset  [Q] Quit", 0x0A
            db "  Press key to apply gate: ", 0
menu_len = $ - menu

reset_msg:  db 0x0A, 0x1B, "[35m» Resetting to |0⟩ state...", 0x1B, "[0m", 0x0A, 0

percent:    db "%", 0
deg_sym:    db "°", 0x0A, 0

section '.bss' align 16

qubit_state:    rb 32
temp_state:     rb 32
rng_state:      rb 32
float_buf:      rb 64
input_buf:      rb 16

section '.text' align 16

start:
    finit
    call init_qubit_zero
    rdtsc
    mov [rng_state], rax
    mov [rng_state+8], rdx
    not rax
    mov [rng_state+16], rax
    not rdx
    mov [rng_state+24], rdx
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, banner
    mov rdx, banner_len
    syscall

.main_loop:
    call display_state
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, menu
    mov rdx, menu_len
    syscall
    call get_char
    cmp al, 'H'
    je .do_hadamard
    cmp al, 'h'
    je .do_hadamard
    cmp al, 'X'
    je .do_pauli_x
    cmp al, 'x'
    je .do_pauli_x
    cmp al, 'M'
    je .do_measure
    cmp al, 'm'
    je .do_measure
    cmp al, 'R'
    je .do_reset
    cmp al, 'r'
    je .do_reset
    cmp al, 'Q'
    je .quit
    cmp al, 'q'
    je .quit
    jmp .main_loop

.do_hadamard:
    call apply_hadamard
    jmp .main_loop

.do_pauli_x:
    call apply_pauli_x
    jmp .main_loop

.do_measure:
    call measure_qubit
    jmp .main_loop

.do_reset:
    call init_qubit_zero
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, reset_msg
    mov rdx, 35
    syscall
    jmp .main_loop

.quit:
    xor rdi, rdi
    mov rax, SYS_EXIT
    syscall

init_qubit_zero:
    mov rax, [one]
    mov [qubit_state], rax
    mov rax, [zero]
    mov [qubit_state+8], rax
    mov [qubit_state+16], rax
    mov [qubit_state+24], rax
    ret

apply_hadamard:
    push rbp
    mov rbp, rsp
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, apply_h
    mov rdx, 48
    syscall
    movsd xmm0, [qubit_state]
    movsd xmm1, [qubit_state+8]
    movsd xmm2, [qubit_state+16]
    movsd xmm3, [qubit_state+24]
    movsd xmm4, xmm0
    addsd xmm4, xmm2
    movsd xmm5, xmm1
    addsd xmm5, xmm3
    subsd xmm0, xmm2
    subsd xmm1, xmm3
    movsd xmm8, [sqrt2_inv]
    mulsd xmm4, xmm8
    mulsd xmm5, xmm8
    mulsd xmm0, xmm8
    mulsd xmm1, xmm8
    movsd [qubit_state], xmm4
    movsd [qubit_state+8], xmm5
    movsd [qubit_state+16], xmm0
    movsd [qubit_state+24], xmm1
    call delay
    pop rbp
    ret

apply_pauli_x:
    push rbp
    mov rbp, rsp
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, apply_x
    mov rdx, 49
    syscall
    movsd xmm0, [qubit_state]
    movsd xmm1, [qubit_state+8]
    movsd xmm2, [qubit_state+16]
    movsd xmm3, [qubit_state+24]
    movsd [qubit_state], xmm2
    movsd [qubit_state+8], xmm3
    movsd [qubit_state+16], xmm0
    movsd [qubit_state+24], xmm1
    call delay
    pop rbp
    ret

measure_qubit:
    push rbp
    mov rbp, rsp
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, apply_m
    mov rdx, 46
    syscall
    movsd xmm0, [qubit_state]
    mulsd xmm0, xmm0
    movsd xmm1, [qubit_state+8]
    mulsd xmm1, xmm1
    addsd xmm0, xmm1
    call random_double
    ucomisd xmm0, xmm0
    movsd xmm2, xmm0
    movsd xmm0, [qubit_state]
    movsd xmm1, [qubit_state+8]
    mulsd xmm0, xmm0
    mulsd xmm1, xmm1
    addsd xmm0, xmm1
    ucomisd xmm2, xmm0
    jae .collapse_to_one

.collapse_to_zero:
    mov rax, [one]
    mov [qubit_state], rax
    mov rax, [zero]
    mov [qubit_state+8], rax
    mov [qubit_state+16], rax
    mov [qubit_state+24], rax
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, result_0
    mov rdx, 48
    syscall
    jmp .measure_done

.collapse_to_one:
    mov rax, [zero]
    mov [qubit_state], rax
    mov [qubit_state+8], rax
    mov rax, [one]
    mov [qubit_state+16], rax
    mov rax, [zero]
    mov [qubit_state+24], rax
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, result_1
    mov rdx, 48
    syscall

.measure_done:
    call delay
    pop rbp
    ret

display_state:
    push rbp
    mov rbp, rsp
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, state_hdr
    mov rdx, state_hdr_len
    syscall
    movsd xmm0, [qubit_state]
    movsd xmm1, [qubit_state+8]
    call print_complex_number
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, ket0
    mov rdx, 4
    syscall
    movsd xmm0, [qubit_state+16]
    movsd xmm1, [qubit_state+24]
    mulsd xmm0, xmm0
    mulsd xmm1, xmm1
    addsd xmm0, xmm1
    movsd xmm2, [zero]
    ucomisd xmm0, xmm2
    je .skip_beta
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, plus_sign
    mov rdx, 3
    syscall
    movsd xmm0, [qubit_state+16]
    movsd xmm1, [qubit_state+24]
    call print_complex_number
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, ket1
    mov rdx, 4
    syscall

.skip_beta:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newline
    mov rdx, 1
    syscall
    call display_probabilities
    call display_bloch_angles
    pop rbp
    ret

print_complex_number:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    movsd xmm2, xmm1
    mulsd xmm2, xmm2
    movsd xmm3, [zero]
    ucomisd xmm2, xmm3
    je .real_only
    movsd [rsp], xmm0
    call print_double_scientific
    movsd xmm2, [zero]
    ucomisd xmm1, xmm2
    jb .negative_imag
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, plus_sign
    mov rdx, 3
    syscall
    jmp .print_imag_part

.negative_imag:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, minus_sign
    mov rdx, 3
    syscall
    andpd xmm1, xmm1

.print_imag_part:
    movsd [rsp], xmm1
    call print_double_scientific
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, i_char
    mov rdx, 1
    syscall
    jmp .done_complex

.real_only:
    movsd [rsp], xmm0
    call print_double_scientific

.done_complex:
    add rsp, 32
    pop rbp
    ret

display_probabilities:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, prob_str
    mov rdx, prob0_len
    syscall
    movsd xmm0, [qubit_state]
    movsd xmm1, [qubit_state+8]
    mulsd xmm0, xmm0
    mulsd xmm1, xmm1
    addsd xmm0, xmm1
    movsd xmm1, [one]
    mov rax, 100
    cvtsi2sd xmm1, rax
    mulsd xmm0, xmm1
    movsd [rsp], xmm0
    call print_double
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, percent
    mov rdx, 1
    syscall
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newline
    mov rdx, 1
    syscall
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, prob1_str
    mov rdx, 12
    syscall
    movsd xmm0, [qubit_state+16]
    movsd xmm1, [qubit_state+24]
    mulsd xmm0, xmm0
    mulsd xmm1, xmm1
    addsd xmm0, xmm1
    movsd xmm1, [one]
    mov rax, 100
    cvtsi2sd xmm1, rax
    mulsd xmm0, xmm1
    movsd [rsp], xmm0
    call print_double
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, percent
    mov rdx, 1
    syscall
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newline
    mov rdx, 1
    syscall
    add rsp, 16
    pop rbp
    ret

display_bloch_angles:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, bloch_str
    mov rdx, theta_len
    syscall
    movsd xmm0, [qubit_state]
    movsd xmm1, [qubit_state+8]
    mulsd xmm0, xmm0
    mulsd xmm1, xmm1
    addsd xmm0, xmm1
    sqrtsd xmm0, xmm0
    movsd xmm2, [one]
    ucomisd xmm0, xmm2
    jbe .alpha_ok
    movsd xmm0, xmm2
.alpha_ok:
    movsd xmm2, [one]
    subsd xmm2, xmm0
    addsd xmm2, xmm2
    sqrtsd xmm2, xmm2
    movsd xmm3, [qubit_state+16]
    movsd xmm4, [qubit_state+24]
    mulsd xmm3, xmm3
    mulsd xmm4, xmm4
    addsd xmm3, xmm4
    sqrtsd xmm3, xmm3
    divsd xmm3, xmm0
    movsd xmm0, [one]
    ucomisd xmm3, xmm3
    jp .theta_calc_done
    movsd xmm4, xmm3
    mulsd xmm4, xmm4
    movsd xmm5, [one]
    mov rax, 28
    cvtsi2sd xmm6, rax
    mov rax, 100
    cvtsi2sd xmm7, rax
    divsd xmm6, xmm7
    mulsd xmm4, xmm6
    addsd xmm5, xmm4
    divsd xmm3, xmm5
    addsd xmm3, xmm3
    movsd xmm2, xmm3

.theta_calc_done:
    mov rax, 180
    cvtsi2sd xmm0, rax
    mulsd xmm2, xmm0
    divsd xmm2, [pi]
    movsd [rsp], xmm2
    call print_double
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, deg_sym
    mov rdx, 3
    syscall
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, phi_str
    mov rdx, 6
    syscall
    movsd xmm0, [zero]
    movsd [rsp], xmm0
    call print_double
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, deg_sym
    mov rdx, 3
    syscall
    add rsp, 32
    pop rbp
    ret

print_double:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    movsd xmm0, [rsp+24]
    mov rax, [rsp+24]
    shr rax, 63
    test rax, rax
    jz .positive
    push rax
    mov rax, '-'
    mov [float_buf], al
    pop rax
    xorpd xmm0, xmm0
    subsd xmm0, [rsp+24]
    jmp .extract_parts

.positive:
    mov rax, ' '
    mov [float_buf], al

.extract_parts:
    cvttsd2si r12, xmm0
    cvtsi2sd xmm1, r12
    subsd xmm0, xmm1
    mov rax, r12
    mov rbx, 100
    xor rdx, rdx
    div rbx
    add al, '0'
    mov [float_buf+1], al
    mov rax, rdx
    mov rbx, 10
    xor rdx, rdx
    div rbx
    add al, '0'
    mov [float_buf+2], al
    add dl, '0'
    mov [float_buf+3], al
    mov rax, '.'
    mov [float_buf+4], al
    mov rax, 10000
    cvtsi2sd xmm1, rax
    mulsd xmm0, xmm1
    cvttsd2si rax, xmm0
    and rax, 0xFFFF
    mov rbx, 1000
    xor rdx, rdx
    div rbx
    add al, '0'
    mov [float_buf+5], al
    mov rax, rdx
    mov rbx, 100
    xor rdx, rdx
    div rbx
    add al, '0'
    mov [float_buf+6], al
    mov rax, rdx
    mov rbx, 10
    xor rdx, rdx
    div rbx
    add al, '0'
    mov [float_buf+7], al
    add dl, '0'
    mov [float_buf+8], dl
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, float_buf
    mov rdx, 9
    syscall
    pop r12
    pop rbx
    pop rbp
    ret

print_double_scientific:
    push rbp
    mov rbp, rsp
    movsd xmm0, [rsp+16]
    movsd xmm1, [zero]
    ucomisd xmm0, xmm1
    jbe .sci_zero
    movsd xmm1, [half]
    ucomisd xmm0, xmm1
    jb .sci_small
    mov rax, '0'
    mov [float_buf], al
    mov rax, '.'
    mov [float_buf+1], al
    mov rax, 10000
    cvtsi2sd xmm1, rax
    mulsd xmm0, xmm1
    cvttsd2si rax, xmm0
    mov rbx, 1000
    xor rdx, rdx
    div rbx
    add al, '0'
    mov [float_buf+2], al
    mov rax, rdx
    mov rbx, 100
    xor rdx, rdx
    div rbx
    add al, '0'
    mov [float_buf+3], al
    mov rax, rdx
    mov rbx, 10
    xor rdx, rdx
    div rbx
    add al, '0'
    mov [float_buf+4], al
    add dl, '0'
    mov [float_buf+5], dl
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, float_buf
    mov rdx, 6
    syscall
    jmp .sci_done

.sci_zero:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, zero
    mov rdx, 8
    syscall
    jmp .sci_done

.sci_small:
    mov rax, '0'
    mov [float_buf], al
    mov rax, '.'
    mov [float_buf+1], al
    mov rax, 10000
    cvtsi2sd xmm1, rax
    mulsd xmm0, xmm1
    cvttsd2si rax, xmm0
    mov rbx, 1000
    xor rdx, rdx
    div rbx
    add al, '0'
    mov [float_buf+2], al
    mov rax, rdx
    mov rbx, 100
    xor rdx, rdx
    div rbx
    add al, '0'
    mov [float_buf+3], al
    mov rax, rdx
    mov rbx, 10
    xor rdx, rdx
    div rbx
    add al, '0'
    mov [float_buf+4], al
    add dl, '0'
    mov [float_buf+5], dl
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, float_buf
    mov rdx, 6
    syscall

.sci_done:
    pop rbp
    ret

random_double:
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, [rng_state]
    mov rcx, [rng_state+8]
    mov rdx, [rng_state+16]
    mov rsi, [rng_state+24]
    mov rax, rbx
    shl rax, 23
    mov r8, rbx
    shr r8, 23
    xor rax, r8
    mov r8, rcx
    imul r8, 5
    mov r9, 0xDA942042E4DD58B5
    imul r8, r9
    add rax, r8
    mov [rng_state], rcx
    mov [rng_state+8], rdx
    mov [rng_state+16], rsi
    mov r8, rsi
    shl rsi, 17
    shr r8, 47
    or rsi, r8
    xor rsi, rbx
    xor rsi, rdx
    mov [rng_state+24], rsi
    shr rax, 11
    mov rcx, 0x3FF0000000000000
    or rax, rcx
    mov [rsp-8], rax
    movsd xmm0, [rsp-8]
    subsd xmm0, [one]
    pop rbx
    pop rbp
    ret

get_char:
    push rbp
    mov rbp, rsp
    xor rax, rax
    xor rdi, rdi
    mov rsi, input_buf
    mov rdx, 1
    syscall
    cmp rax, 0
    jle .get_done
    mov al, [input_buf]
    cmp al, 0x0A
    je get_char
.get_done:
    pop rbp
    ret

delay:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov qword [rsp], 0
    mov qword [rsp+8], 100000000
    mov rax, SYS_NANOSLEEP
    mov rdi, rsp
    xor rsi, rsi
    syscall
    add rsp, 16
    pop rbp
    ret