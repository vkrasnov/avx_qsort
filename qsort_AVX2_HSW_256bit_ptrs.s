
.set pivotALU, %rcx

.set A0, %ymm0
.set A1, %ymm1
.set A2, %ymm2
.set A3, %ymm3
.set A4, %ymm4
.set A5, %ymm5
.set A6, %ymm6

.set M0, %ymm7
.set M1, %ymm8
.set M2, %ymm9
.set M3, %ymm10
.set M4, %ymm11
.set M5, %ymm12
.set M6, %ymm13

.set T, %ymm14

.set PIVOT, %ymm15

.set r0, %r8
.set r1, %r9
.set r2, %r10
.set r3, %r11
.set r4, %r15
.set r5, %r12
.set r6, %rax

# This one sorts in descending order, sort in ascending order, requires swapping the cmp operands.
.align 16
.globl qsort_AVX2
qsort_AVX2:

.set array, %rdi
.set temp_space, %rsi
.set n, %rdx

.set bottom, %r13
.set top, %r14

    push    %r12
    push    %r13
    push    %r14
    push    %r15
    push    %rbp
    
    mov -8(array, n, 8), pivotALU
    vpbroadcastq    (pivotALU), PIVOT
    
    lea (array), bottom
    lea (temp_space), top
    dec n
    
.Lx7_loop:

    cmp $28, n
    jl  .Lx7_loop_exit

    # Load the next 28 elements
    vmovdqu 32*0(array), A0
    vmovdqu 32*1(array), A1
    vmovdqu 32*2(array), A2
    vmovdqu 32*3(array), A3
    vmovdqu 32*4(array), A4
    vmovdqu 32*5(array), A5
    vmovdqu 32*6(array), A6
    
    vpcmpeqq    T, T, T
    vpgatherqq T, (,A0), M0
    vpcmpeqq    T, T, T
    vpgatherqq T, (,A1), M1
    vpcmpeqq    T, T, T
    vpgatherqq T, (,A2), M2
    vpcmpeqq    T, T, T
    vpgatherqq T, (,A3), M3
    vpcmpeqq    T, T, T
    vpgatherqq T, (,A4), M4
    vpcmpeqq    T, T, T
    vpgatherqq T, (,A5), M5
    vpcmpeqq    T, T, T
    vpgatherqq T, (,A6), M6
    
    # Find elements lesser-than-equal to PIVOT
    vpcmpgtq  M0, PIVOT, M0
    vpcmpgtq  M1, PIVOT, M1
    vpcmpgtq  M2, PIVOT, M2
    vpcmpgtq  M3, PIVOT, M3
    vpcmpgtq  M4, PIVOT, M4
    vpcmpgtq  M5, PIVOT, M5
    vpcmpgtq  M6, PIVOT, M6

    vmovmskpd   M0, r0
    vmovmskpd   M1, r1
    vmovmskpd   M2, r2
    vmovmskpd   M3, r3
    vmovmskpd   M4, r4
    vmovmskpd   M5, r5
    vmovmskpd   M6, r6
    
    shl $5, r0
    shl $5, r1
    shl $5, r2
    shl $5, r3
    shl $5, r4
    shl $5, r5
    shl $5, r6
    
    vmovdqa .LPermTableLeft(,r0), T
    VPERMD  A0, T, M0
    vmovdqa .LPermTableLeft(,r1), T
    VPERMD  A1, T, M1
    vmovdqa .LPermTableLeft(,r2), T
    VPERMD  A2, T, M2
    vmovdqa .LPermTableLeft(,r3), T
    VPERMD  A3, T, M3
    vmovdqa .LPermTableLeft(,r4), T
    VPERMD  A4, T, M4
    vmovdqa .LPermTableLeft(,r5), T
    VPERMD  A5, T, M5
    vmovdqa .LPermTableLeft(,r6), T
    VPERMD  A6, T, M6
    
    vmovdqa .LPermTableRight(,r0), T
    VPERMD  A0, T, A0
    vmovdqa .LPermTableRight(,r1), T
    VPERMD  A1, T, A1
    vmovdqa .LPermTableRight(,r2), T
    VPERMD  A2, T, A2
    vmovdqa .LPermTableRight(,r3), T
    VPERMD  A3, T, A3
    vmovdqa .LPermTableRight(,r4), T
    VPERMD  A4, T, A4
    vmovdqa .LPermTableRight(,r5), T
    VPERMD  A5, T, A5
    vmovdqa .LPermTableRight(,r6), T
    VPERMD  A6, T, A6
    
    popcnt  r0, r0
    popcnt  r1, r1
    popcnt  r2, r2
    popcnt  r3, r3
    popcnt  r4, r4
    popcnt  r5, r5
    popcnt  r6, r6
    
    shl $3, r0
    shl $3, r1
    shl $3, r2
    shl $3, r3
    shl $3, r4
    shl $3, r5
    shl $3, r6
    
    vmovdqu M0, (bottom)
    add r0, bottom
    vmovdqu M1, (bottom)
    add r1, bottom
    vmovdqu M2, (bottom)
    add r2, bottom
    vmovdqu M3, (bottom)
    add r3, bottom
    vmovdqu M4, (bottom)
    add r4, bottom
    vmovdqu M5, (bottom)
    add r5, bottom
    vmovdqu M6, (bottom)
    add r6, bottom
    
    sub $32, r0
    sub $32, r1
    sub $32, r2
    sub $32, r3
    sub $32, r4
    sub $32, r5
    sub $32, r6
    
    vmovdqu A0, (top)
    sub r0, top
    vmovdqu A1, (top)
    sub r1, top
    vmovdqu A2, (top)
    sub r2, top
    vmovdqu A3, (top)
    sub r3, top
    vmovdqu A4, (top)
    sub r4, top
    vmovdqu A5, (top)
    sub r5, top
    vmovdqu A6, (top)
    sub r6, top

    sub $28, n
    add $28*8, array
    jmp .Lx7_loop
    
.Lx7_loop_exit:

.Lx3_loop:

    cmp $12, n
    jl  .Lx3_loop_exit

    # Load the next 12 elements
    vmovdqu 32*0(array), A0
    vmovdqu 32*1(array), A1
    vmovdqu 32*2(array), A2
    
    vpcmpeqq    T, T, T
    vpgatherqq T, (,A0), M0
    vpcmpeqq    T, T, T
    vpgatherqq T, (,A1), M1
    vpcmpeqq    T, T, T
    vpgatherqq T, (,A2), M2
    
    # Find elements lesser-than-equal to PIVOT
    vpcmpgtq  M0, PIVOT, M0
    vpcmpgtq  M1, PIVOT, M1
    vpcmpgtq  M2, PIVOT, M2

    vmovmskpd   M0, r0
    vmovmskpd   M1, r1
    vmovmskpd   M2, r2
    
    shl $5, r0
    shl $5, r1
    shl $5, r2
    
    vmovdqa .LPermTableLeft(,r0), T
    VPERMD  A0, T, M0
    vmovdqa .LPermTableLeft(,r1), T
    VPERMD  A1, T, M1
    vmovdqa .LPermTableLeft(,r2), T
    VPERMD  A2, T, M2
    
    vmovdqa .LPermTableRight(,r0), T
    VPERMD  A0, T, A0
    vmovdqa .LPermTableRight(,r1), T
    VPERMD  A1, T, A1
    vmovdqa .LPermTableRight(,r2), T
    VPERMD  A2, T, A2
    
    popcnt  r0, r0
    popcnt  r1, r1
    popcnt  r2, r2
    
    shl $3, r0
    shl $3, r1
    shl $3, r2
    
    vmovdqu M0, (bottom)
    add r0, bottom
    vmovdqu M1, (bottom)
    add r1, bottom
    vmovdqu M2, (bottom)
    add r2, bottom
    
    sub $32, r0
    sub $32, r1
    sub $32, r2
    
    vmovdqu A0, (top)
    sub r0, top
    vmovdqu A1, (top)
    sub r1, top
    vmovdqu A2, (top)
    sub r2, top

    sub $12, n
    add $12*8, array
    jmp .Lx3_loop
    
.Lx3_loop_exit:
.Lx1_loop:

    cmp $4, n
    jl  .Lx1_loop_exit

    # Load the next 4 elements
    vmovdqu 32*0(array), A0
    
    vpcmpeqq    T, T, T
    vpgatherqq T, (,A0), M0
    
    # Find elements lesser-than-equal to PIVOT
    vpcmpgtq  M0, PIVOT, M0

    vmovmskpd   M0, r0
    
    shl $5, r0
    
    vmovdqa .LPermTableLeft(,r0), T
    VPERMD  A0, T, M0
    
    vmovdqa .LPermTableRight(,r0), T
    VPERMD  A0, T, A0
    
    popcnt  r0, r0
    
    shl $3, r0
    
    vmovdqu M0, (bottom)
    add r0, bottom
    
    sub $32, r0
    
    vmovdqu A0, (top)
    sub r0, top

    sub $4, n
    add $4*8, array
    jmp .Lx1_loop
    
.Lx1_loop_exit:

    mov pivotALU, %r9
    mov (pivotALU), pivotALU

.Ls_loop:
    
    cmp $0, n
    je  .Ls_loop_exit
    
    mov (array), %r8
    mov (%r8), %r10
    cmp pivotALU,  %r10
    
    jg  .Lgreater
    
        mov %r8, (bottom)
        add $8, bottom
        add $8, array
        dec n
    
    jmp .Ls_loop
    
.Lgreater:
        mov %r8, (top)
        add $8, top
        add $8, array
        dec n
    
    jmp .Ls_loop
    
.Ls_loop_exit:
    mov %r9, (bottom)
    add $8, bottom
    
    sub temp_space, top
    shr $3, top
    mov top, %rax
    
.Lx4_copy_loop:
    cmp $16, top
    jl  .Lx4_copy_end
    
    vmovdqu 32*0(temp_space), %ymm0
    vmovdqu 32*1(temp_space), %ymm1
    vmovdqu 32*2(temp_space), %ymm2
    vmovdqu 32*3(temp_space), %ymm3
    
    vmovdqu %ymm0, 32*0(bottom)
    vmovdqu %ymm1, 32*1(bottom)
    vmovdqu %ymm2, 32*2(bottom)
    vmovdqu %ymm3, 32*3(bottom)
    
    lea 32*4(temp_space), temp_space
    lea 32*4(bottom), bottom
    sub $16, top
    jmp .Lx4_copy_loop
.Lx4_copy_end:
    
.Lx1_copy_loop:
    cmp $4, top
    jl  .Lx1_copy_end
    
    vmovdqu 32*0(temp_space), %ymm0
    
    vmovdqu %ymm0, 32*0(bottom)
    
    lea 8*4(temp_space), temp_space
    lea 8*4(bottom), bottom
    sub $4, top
    jmp .Lx1_copy_loop

.Lx1_copy_end:



    cmp $0, top
    je  .Lcopy_end
    
    mov (temp_space), %r8
    mov %r8, (bottom)
    
    lea 8(temp_space), temp_space
    lea 8(bottom), bottom
    sub $1, top
    jmp .Lx1_copy_loop

.Lcopy_end:
    pop %rbp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    
    ret
    
.align 32
.LPermTableLeft:
.long	0,0,0,0,0,0,0,0	#0
.long	0,1,0,0,0,0,0,0	#1
.long	2,3,0,0,0,0,0,0	#2
.long	0,1,2,3,0,0,0,0	#3
.long	4,5,0,0,0,0,0,0	#4
.long	0,1,4,5,0,0,0,0	#5
.long	2,3,4,5,0,0,0,0	#6
.long	0,1,2,3,4,5,0,0	#7
.long	6,7,0,0,0,0,0,0	#8
.long	0,1,6,7,0,0,0,0	#9
.long	2,3,6,7,0,0,0,0	#10
.long	0,1,2,3,6,7,0,0 #11
.long	4,5,6,7,0,0,0,0	#12
.long	0,1,4,5,6,7,0,0	#13
.long	2,3,4,5,6,7,0,0	#14
.long	0,1,2,3,4,5,6,7	#15

.align 32
.LPermTableRight:
.long	0,1,2,3,4,5,6,7	#0
.long	2,3,4,5,6,7,0,0	#1
.long	0,1,4,5,6,7,0,0	#2
.long	4,5,6,7,0,0,0,0	#3
.long	0,1,2,3,6,7,0,0	#4
.long	2,3,6,7,0,0,0,0	#5
.long	0,1,6,7,0,0,0,0	#6
.long	6,7,0,0,0,0,0,0	#7
.long	0,1,2,3,4,5,0,0	#8
.long	2,3,4,5,0,0,0,0	#9
.long	0,1,4,5,0,0,0,0	#10
.long	4,5,0,0,0,0,0,0	#11
.long	0,1,2,3,0,0,0,0	#12
.long	2,3,0,0,0,0,0,0 #13
.long	0,1,0,0,0,0,0,0 #14
.long	0,0,0,0,0,0,0,0	#15
