
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
    vpbroadcastq    -8(array, n, 8), %zmm15
    
    lea (array), bottom
    lea (temp_space), top
    dec n
    
.Lx7_loop:

    cmp $56, n
    jl  .Lx7_loop_exit

    # Load the next 28 elements
    vmovdqu64 64*0(array), %zmm0
    vmovdqu64 64*1(array), %zmm1
    vmovdqu64 64*2(array), %zmm2
    vmovdqu64 64*3(array), %zmm3
    vmovdqu64 64*4(array), %zmm4
    vmovdqu64 64*5(array), %zmm5
    vmovdqu64 64*6(array), %zmm6
    
    # Find elements lesser-than-equal to PIVOT
    vpcmpgtq  %zmm0, %zmm15, %k1
    vpcmpgtq  %zmm1, %zmm15, %k2
    vpcmpgtq  %zmm2, %zmm15, %k3
    vpcmpgtq  %zmm3, %zmm15, %k4
    vpcmpgtq  %zmm4, %zmm15, %k5
    vpcmpgtq  %zmm5, %zmm15, %k6
    vpcmpgtq  %zmm6, %zmm15, %k7

    kmovq   %k1, r0
    kmovq   %k2, r1
    kmovq   %k3, r2
    kmovq   %k4, r3
    kmovq   %k5, r4
    kmovq   %k6, r5
    kmovq   %k7, r6
    
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
    
    vcompresspd %zmm0, (bottom){%k1}
    add r0, bottom
    vcompresspd %zmm1, (bottom){%k2}
    add r1, bottom
    vcompresspd %zmm2, (bottom){%k3}
    add r2, bottom
    vcompresspd %zmm3, (bottom){%k4}
    add r3, bottom
    vcompresspd %zmm4, (bottom){%k5}
    add r4, bottom
    vcompresspd %zmm5, (bottom){%k6}
    add r5, bottom
    vcompresspd %zmm6, (bottom){%k7}
    add r6, bottom
    
    knotb   %k1, %k1
    knotb   %k2, %k2
    knotb   %k3, %k3
    knotb   %k4, %k4
    knotb   %k5, %k5
    knotb   %k6, %k6
    knotb   %k7, %k7
      
    sub $64, r0
    sub $64, r1
    sub $64, r2
    sub $64, r3
    sub $64, r4
    sub $64, r5
    sub $64, r6
    
    vcompresspd %zmm0, (top){%k1}
    sub r0, top
    vcompresspd %zmm1, (top){%k2}
    sub r1, top
    vcompresspd %zmm2, (top){%k3}
    sub r2, top
    vcompresspd %zmm3, (top){%k4}
    sub r3, top
    vcompresspd %zmm4, (top){%k5}
    sub r4, top
    vcompresspd %zmm5, (top){%k6}
    sub r5, top
    vcompresspd %zmm6, (top){%k7}
    sub r6, top

    sub $56, n
    add $56*8, array
    jmp .Lx7_loop
    
.Lx7_loop_exit:

.Lx3_loop:

    cmp $24, n
    jl  .Lx3_loop_exit

     # Load the next 28 elements
    vmovdqu64 64*0(array), %zmm0
    vmovdqu64 64*1(array), %zmm1
    vmovdqu64 64*2(array), %zmm2
    
    # Find elements lesser-than-equal to PIVOT
    vpcmpgtq  %zmm0, %zmm15, %k1
    vpcmpgtq  %zmm1, %zmm15, %k2
    vpcmpgtq  %zmm2, %zmm15, %k3

    kmovq   %k1, r0
    kmovq   %k2, r1
    kmovq   %k3, r2
    
    popcnt  r0, r0
    popcnt  r1, r1
    popcnt  r2, r2
    
    shl $3, r0
    shl $3, r1
    shl $3, r2
    
    vcompresspd %zmm0, (bottom){%k1}
    add r0, bottom
    vcompresspd %zmm1, (bottom){%k2}
    add r1, bottom
    vcompresspd %zmm2, (bottom){%k3}
    add r2, bottom
    
    knotb   %k1, %k1
    knotb   %k2, %k2
    knotb   %k3, %k3
      
    sub $64, r0
    sub $64, r1
    sub $64, r2
    
    vcompresspd %zmm0, (top){%k1}
    sub r0, top
    vcompresspd %zmm1, (top){%k2}
    sub r1, top
    vcompresspd %zmm2, (top){%k3}
    sub r2, top
    
    sub $24, n
    add $24*8, array
    jmp .Lx3_loop    
.Lx3_loop_exit:

.Lx1_loop:

    cmp $4, n
    jl  .Lx1_loop_exit

    # Load the next 4 elements
    vmovdqu 32*0(array), A0
    
    # Find elements lesser-than-equal to PIVOT
    vpcmpgtq  A0, PIVOT, M0

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

.Ls_loop:
    
    cmp $0, n
    je  .Ls_loop_exit
    
    mov (array), %r8
    cmp pivotALU,  %r8
    
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
    mov pivotALU, (bottom)
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
