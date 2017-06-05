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

.Ldo_qsort:
    
    push    %r12
    push    %r13
    push    %r14
    push    %r15
    push    %rbp
    
.set el1, %xmm0
.set el2, %xmm1
.set el3, %xmm2
# Median of three
    mov n, r1
    shr $1, r1
    vmovsd      (array), el1
    vmovsd      (array, r1, 8), el3
    vmovsd      -8(array, n, 8), el2
    
    # if el1 > el2
    vucomisd el2, el1    
    jbe     .Lm2
    # swap el1, el2
    vmovapd el1, %xmm3
    vmovapd el2, el1
    vmovapd %xmm3, el2
    
.Lm2:
    vucomisd el3, el2
    jbe     .Lm3
    # swap el2, el3
    vmovapd el3, %xmm3
    vmovapd el2, el3
    vmovapd %xmm3, el2
    
    # if el1 > el2
    vucomisd el2, el1
    jbe     .Lm3
    # swap el1, el2
    vmovapd el1, %xmm3
    vmovapd el2, el1
    vmovapd %xmm3, el2
.Lm3:
        
    vmovsd      el1, (array)
    vmovsd      el3, (array, r1, 8)
    vmovsd      el2, -8(array, n, 8)
   
    vpermpd $0, %ymm1, PIVOT
    #vbroadcastsd    -8(array, n, 8), PIVOT
    
    lea (array), bottom
    lea (temp_space), top
    dec n
    
.Lx7_loop:

    cmp $28, n
    jl  .Lx7_loop_exit

    # Load the next 28 elements
    vmovupd 32*0(array), A0
    vmovupd 32*1(array), A1
    vmovupd 32*2(array), A2
    vmovupd 32*3(array), A3
    vmovupd 32*4(array), A4
    vmovupd 32*5(array), A5
    vmovupd 32*6(array), A6
    
    # Find elements lesser-than-equal to PIVOT
    vcmppd  $2, PIVOT, A0, M0
    vcmppd  $2, PIVOT, A1, M1
    vcmppd  $2, PIVOT, A2, M2
    vcmppd  $2, PIVOT, A3, M3
    vcmppd  $2, PIVOT, A4, M4
    vcmppd  $2, PIVOT, A5, M5
    vcmppd  $2, PIVOT, A6, M6

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
    
    vmovapd .LPermTableLeft(,r0), T
    vpermps  A0, T, M0
    vmovapd .LPermTableLeft(,r1), T
    vpermps  A1, T, M1
    vmovapd .LPermTableLeft(,r2), T
    vpermps  A2, T, M2
    vmovapd .LPermTableLeft(,r3), T
    vpermps  A3, T, M3
    vmovapd .LPermTableLeft(,r4), T
    vpermps  A4, T, M4
    vmovapd .LPermTableLeft(,r5), T
    vpermps  A5, T, M5
    vmovapd .LPermTableLeft(,r6), T
    vpermps  A6, T, M6
    
    vmovapd .LPermTableRight(,r0), T
    vpermps  A0, T, A0
    vmovapd .LPermTableRight(,r1), T
    vpermps  A1, T, A1
    vmovapd .LPermTableRight(,r2), T
    vpermps  A2, T, A2
    vmovapd .LPermTableRight(,r3), T
    vpermps  A3, T, A3
    vmovapd .LPermTableRight(,r4), T
    vpermps  A4, T, A4
    vmovapd .LPermTableRight(,r5), T
    vpermps  A5, T, A5
    vmovapd .LPermTableRight(,r6), T
    vpermps  A6, T, A6
    
    popcnt  r0, r0
    popcnt  r1, r1
    popcnt  r2, r2
    popcnt  r3, r3
    popcnt  r4, r4
    popcnt  r5, r5
    popcnt  r6, r6
    
    vmovupd M0, (bottom)
    lea (bottom, r0, 8), bottom
    vmovupd M1, (bottom)
    lea (bottom, r1, 8), bottom
    vmovupd M2, (bottom)
    lea (bottom, r2, 8), bottom
    vmovupd M3, (bottom)
    lea (bottom, r3, 8), bottom
    vmovupd M4, (bottom)
    lea (bottom, r4, 8), bottom
    vmovupd M5, (bottom)
    lea (bottom, r5, 8), bottom
    vmovupd M6, (bottom)
    lea (bottom, r6, 8), bottom
 	
	neg r0
	neg r1
	neg r2
	neg r3
	neg r4
	neg r5
	neg r6

    vmovupd A0, (top)
	lea	32(top, r0, 8), top
    vmovupd A1, (top)
	lea	32(top, r1, 8), top
    vmovupd A2, (top)
	lea	32(top, r2, 8), top
    vmovupd A3, (top)
	lea	32(top, r3, 8), top
    vmovupd A4, (top)
	lea	32(top, r4, 8), top
    vmovupd A5, (top)
	lea	32(top, r5, 8), top
    vmovupd A6, (top)
	lea	32(top, r6, 8), top

    sub $28, n
    add $28*8, array
    jmp .Lx7_loop
    
.Lx7_loop_exit:
    
.Lx5_loop:

    cmp $20, n
    jl  .Lx5_loop_exit

    # Load the next 28 elements
    vmovupd 32*0(array), A0
    vmovupd 32*1(array), A1
    vmovupd 32*2(array), A2
    vmovupd 32*3(array), A3
    vmovupd 32*4(array), A4
    
    # Find elements lesser-than-equal to PIVOT
    vcmppd  $2, PIVOT, A0, M0
    vcmppd  $2, PIVOT, A1, M1
    vcmppd  $2, PIVOT, A2, M2
    vcmppd  $2, PIVOT, A3, M3
    vcmppd  $2, PIVOT, A4, M4

    vmovmskpd   M0, r0
    vmovmskpd   M1, r1
    vmovmskpd   M2, r2
    vmovmskpd   M3, r3
    vmovmskpd   M4, r4
    
    shl $5, r0
    shl $5, r1
    shl $5, r2
    shl $5, r3
    shl $5, r4
    
    vmovapd .LPermTableLeft(,r0), T
    vpermps  A0, T, M0
    vmovapd .LPermTableLeft(,r1), T
    vpermps  A1, T, M1
    vmovapd .LPermTableLeft(,r2), T
    vpermps  A2, T, M2
    vmovapd .LPermTableLeft(,r3), T
    vpermps  A3, T, M3
    vmovapd .LPermTableLeft(,r4), T
    vpermps  A4, T, M4
    
    vmovapd .LPermTableRight(,r0), T
    vpermps  A0, T, A0
    vmovapd .LPermTableRight(,r1), T
    vpermps  A1, T, A1
    vmovapd .LPermTableRight(,r2), T
    vpermps  A2, T, A2
    vmovapd .LPermTableRight(,r3), T
    vpermps  A3, T, A3
    vmovapd .LPermTableRight(,r4), T
    vpermps  A4, T, A4
    
    popcnt  r0, r0
    popcnt  r1, r1
    popcnt  r2, r2
    popcnt  r3, r3
    popcnt  r4, r4
    
    vmovupd M0, (bottom)
    lea (bottom, r0, 8), bottom
    vmovupd M1, (bottom)
    lea (bottom, r1, 8), bottom
    vmovupd M2, (bottom)
    lea (bottom, r2, 8), bottom
    vmovupd M3, (bottom)
    lea (bottom, r3, 8), bottom
    vmovupd M4, (bottom)
    lea (bottom, r4, 8), bottom
 	
	neg r0
	neg r1
	neg r2
	neg r3
	neg r4

    vmovupd A0, (top)
	lea	32(top, r0, 8), top
    vmovupd A1, (top)
	lea	32(top, r1, 8), top
    vmovupd A2, (top)
	lea	32(top, r2, 8), top
    vmovupd A3, (top)
	lea	32(top, r3, 8), top
    vmovupd A4, (top)
	lea	32(top, r4, 8), top

    sub $20, n
    add $20*8, array
    jmp .Lx5_loop
    
.Lx5_loop_exit:
   
.Lx3_loop:

    cmp $8, n
    jl  .Lx3_loop_exit

    # Load the next 28 elements
    vmovupd 32*0(array), A0
    vmovupd 32*1(array), A1
    
    # Find elements lesser-than-equal to PIVOT
    vcmppd  $2, PIVOT, A0, M0
    vcmppd  $2, PIVOT, A1, M1

    vmovmskpd   M0, r0
    vmovmskpd   M1, r1
    
    shl $5, r0
    shl $5, r1
    
    vmovapd .LPermTableLeft(,r0), T
    vpermps  A0, T, M0
    vmovapd .LPermTableLeft(,r1), T
    vpermps  A1, T, M1
    
    vmovapd .LPermTableRight(,r0), T
    vpermps  A0, T, A0
    vmovapd .LPermTableRight(,r1), T
    vpermps  A1, T, A1
    
	popcnt  r0, r0
    popcnt  r1, r1
    
    vmovupd M0, (bottom)
    lea (bottom, r0, 8), bottom
    vmovupd M1, (bottom)
    lea (bottom, r1, 8), bottom
	
	neg r0
	neg r1

    vmovupd A0, (top)
	lea	32(top, r0, 8), top
    vmovupd A1, (top)
	lea	32(top, r1, 8), top

    sub $8, n
    add $8*8, array
    jmp .Lx3_loop
    
.Lx3_loop_exit:

.Lx1_loop:

    cmp $2, n
    jl  .Lx1_loop_exit

    # Load the next 28 elements
    vmovupd 32*0(array), %xmm0
    
    # Find elements lesser-than-equal to PIVOT
    vcmppd  $2, %xmm15, %xmm0, %xmm1

    vmovmskpd   %xmm1, r0
    
    shl $4, r0
    
            
    vpermilpd .LPermTableLeftS(,r0), %xmm0, %xmm1
    
    vpermilpd .LPermTableRightS(,r0), %xmm0, %xmm0
    
    
    popcnt  r0, r0
    
    shl $3, r0
    
    vmovupd %xmm1, (bottom)
    add r0, bottom
    
    sub $16, r0
    
    vmovupd %xmm0, (top)
    sub r0, top

    sub $2, n
    add $2*8, array
    jmp .Lx1_loop
    
.Lx1_loop_exit:

.Ls_loop:
    
    cmp $0, n
    je  .Ls_loop_exit
    
    vmovsd      (array), %xmm0
    vucomisd    %xmm15, %xmm0
    
    ja  .Lgreater
    
        vmovsd  %xmm0, (bottom)
        add $8, bottom
        add $8, array
        dec n
    
    jmp .Ls_loop
    
.Lgreater:
        vmovsd  %xmm0, (top)
        add $8, top
        add $8, array
        dec n
    
    jmp .Ls_loop
    
.Ls_loop_exit:
    vmovsd  %xmm15, (bottom)
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
    jmp .Lx1_copy_end

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

    
.align 16
.LPermTableLeftS:
.quad	0,0	#0
.quad	0,0	#1
.quad	2,0	#2
.quad	0,2	#3

.align 16
.LPermTableRightS:
.quad	0,2	#0
.quad	2,0	#1
.quad	0,0	#2
.quad	0,0	#3
