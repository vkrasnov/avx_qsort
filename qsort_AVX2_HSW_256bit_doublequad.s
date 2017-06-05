
.set pivotALU, %rcx

.set A0, %ymm0
.set A1, %ymm1
.set A2, %ymm2
.set A3, %ymm3

.set G0, %ymm4
.set G1, %ymm5
.set G2, %ymm6
.set G3, %ymm7

.set G0_xmm, %xmm4
.set G1_xmm, %xmm5
.set G2_xmm, %xmm6
.set G3_xmm, %xmm7

.set E0, %ymm8
.set E1, %ymm9
.set E2, %ymm10
.set E3, %ymm11

.set E0_xmm, %xmm8
.set E1_xmm, %xmm9
.set E2_xmm, %xmm10
.set E3_xmm, %xmm11

.set T, %ymm14
.set PIVOT, %ymm15

.set r0, %r8
.set r1, %r9
.set r2, %r10
.set r3, %r11
.set r4, %r15
.set r5, %r12
.set r6, %rax

# This one sorts in ascending order
.align 16
.globl qsort_AVX2
qsort_AVX2:

.set array, %rdi
.set temp_space, %rsi
.set n, %rdx

.set bottom, %r13
.set top, %r14

.Ldo_qsort:
    
	push	n
    push    %r12
    push    %r13
    push    %r14
    push    %r15
    push    %rbp
    
    #mov -8(array, n, 8), pivotALU
    #vpbroadcastq    -8(array, n, 8), PIVOT
	
	mov	n, r0
	shl	$4, r0
	
	VBROADCASTI128	-16(array, r0), PIVOT
	
    
    lea (array), bottom
    lea (temp_space), top
    dec n
    
.Lx4_loop:

    cmp $8, n
    jl  .Lx4_loop_exit

    # Load the next 8 elements
    vmovdqu 32*0(array), A0
    vmovdqu 32*1(array), A1
    vmovdqu 32*2(array), A2
    vmovdqu 32*3(array), A3
    
    # Find elements greater-than PIVOT
    vpcmpgtq  A0, PIVOT, G0		# P > A
    vpcmpgtq  A1, PIVOT, G1
    vpcmpgtq  A2, PIVOT, G2
    vpcmpgtq  A3, PIVOT, G3
	
	vpermq	$0xd, G0, E0	# Top QWORDS of the key are lesser than equal
	vpermq	$0xd, G1, E1
	vpermq	$0xd, G2, E2
	vpermq	$0xd, G3, E3
	
	vpermq	$0x8, G0, G0	# Low QWORDS of the key are lesser than equal
	vpermq	$0x8, G1, G1
	vpermq	$0x8, G2, G2
	vpermq	$0x8, G3, G3
	
	
	# Find elements equal to PIVOT
	vpcmpeqq	A0, PIVOT, T		# A == P
	vpunpckhqdq		T, T, T
	vpand		T, T, G0
	vpcmpeqq  A1, PIVOT, T		# A == P
	vpunpckhqdq	T, T, T
	vpand		T, T, G1
	vpcmpeqq  A2, PIVOT, T		# A == P
	vpunpckhqdq	T, T, T
	vpand		T, T, G2
	vpcmpeqq  A3, PIVOT, T		# A == P
	vpunpckhqdq	T, T, T
	vpand		T, T, G3
	
	vpor	E0, G0, G0
	vpor	E1, G1, G1
	vpor	E2, G2, G2
	vpor	E3, G3, G3
	
	
	# Element is lesser-than-equal to pivot, if the top qword is lesser than pivot and 
	# or the top word is equal, and the bottom is lesser-than-equal
    vmovmskpd   G0_xmm, r0
    vmovmskpd   G1_xmm, r1
    vmovmskpd   G2_xmm, r2
    vmovmskpd   G3_xmm, r3
    
    shl $5, r0
    shl $5, r1
    shl $5, r2
    shl $5, r3
    
    vmovdqa .LPermTableLeft(,r0), T
    VPERMD  A0, T, G0
    vmovdqa .LPermTableLeft(,r1), T
    VPERMD  A1, T, G1
    vmovdqa .LPermTableLeft(,r2), T
    VPERMD  A2, T, G2
    vmovdqa .LPermTableLeft(,r3), T
    VPERMD  A3, T, G3
    
    vmovdqa .LPermTableRight(,r0), T
    VPERMD  A0, T, A0
    vmovdqa .LPermTableRight(,r1), T
    VPERMD  A1, T, A1
    vmovdqa .LPermTableRight(,r2), T
    VPERMD  A2, T, A2
    vmovdqa .LPermTableRight(,r2), T
    VPERMD  A3, T, A3
    
    popcnt  r0, r0
    popcnt  r1, r1
    popcnt  r2, r2
    popcnt  r3, r3
    
    shl $4, r0
    shl $4, r1
    shl $4, r2
    shl $4, r3
    
    vmovdqu G0, (bottom)
    add r0, bottom
    vmovdqu G1, (bottom)
    add r1, bottom
    vmovdqu G2, (bottom)
    add r2, bottom
    vmovdqu G3, (bottom)
    add r3, bottom
    
    sub $32, r0
    sub $32, r1
    sub $32, r2
    sub $32, r3
    
    vmovdqu A0, (top)
    sub r0, top
    vmovdqu A1, (top)
    sub r1, top
    vmovdqu A2, (top)
    sub r2, top
    vmovdqu A3, (top)
    sub r3, top
    
    sub $8, n
    add $8*16, array
    jmp .Lx4_loop    
.Lx4_loop_exit:

.Lx1_loop:

    cmp $2, n
    jl  .Lx1_loop_exit

     # Load the next 2 elements
    vmovdqu 32*0(array), A0
	
    # Find elements greater-than PIVOT
    vpcmpgtq  A0, PIVOT, G0		# P > A
	# Find elements equal to PIVOT
	# vpcmpeqq  A0, PIVOT, E0		# A == P
	
	# vpand	E0, G0, G0
	# Element is lesser-than-equal to pivot, if the top qword is lesser than pivot and 
	# or the top word is equal, and the bottom is lesser-than-equal
    vmovmskpd   G0_xmm, r0
    
    shl $5, r0
    
    vmovdqa .LPermTableLeft(,r0), T
    VPERMD  A0, T, G0
    
    vmovdqa .LPermTableRight(,r0), T
    VPERMD  A0, T, A0
    
    popcnt  r0, r0
    
    shl $4, r0
    
    vmovdqu G0, (bottom)
    add r0, bottom
    
    sub $32, r0
    
    vmovdqu A0, (top)
    sub r0, top
    
    sub $2, n
    add $2*16, array
    jmp .Lx1_loop    
.Lx1_loop_exit:

.Ls_loop:
    
    cmp $0, n
    je  .Ls_loop_exit
    
    mov (array), %r8
    cmp pivotALU,  %r8
    
    jg  .Lgreater
    
        mov %r8, (bottom)
        add $16, bottom
        add $16, array
        dec n
    
    jmp .Ls_loop
    
.Lgreater:
        mov %r8, (top)
        add $16, top
        add $16, array
        dec n
    
    jmp .Ls_loop
    
.Ls_loop_exit:
    mov pivotALU, (bottom)
    add $16, bottom
    
    sub temp_space, top
    shr $4, top
    mov top, %rax
    
.Lx4_copy_loop:
    cmp $8, top
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
    sub $8, top
    jmp .Lx4_copy_loop
.Lx4_copy_end:
    
.Lx1_copy_loop:
    cmp $2, top
    jl  .Lx1_copy_end
    
    vmovdqu 32*0(temp_space), %ymm0
    
    vmovdqu %ymm0, 32*0(bottom)
    
    lea 8*4(temp_space), temp_space
    lea 8*4(bottom), bottom
    sub $2, top
    jmp .Lx1_copy_loop

.Lx1_copy_end:

    cmp $0, top
    je  .Lcopy_end
    
    mov (temp_space), %r8
    mov 8(temp_space), %r9
    mov %r8, (bottom)
    mov %r9, 8(bottom)
    
    lea 16(temp_space), temp_space
    lea 16(bottom), bottom
    sub $1, top
    jmp .Lx1_copy_end

.Lcopy_end:
    pop %rbp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
	pop n
	mov n, %rax
	shr	$1, %rax
    
    ret
    
.align 32
.LPermTableLeft:
.long	0,0,0,0,0,0,0,0	#0
.long	0,1,0,0,0,0,0,0	#1
.long	2,3,0,0,0,0,0,0	#2
.long	0,1,2,3,0,0,0,0	#3

.align 32
.LPermTableRight:
.long	0,1,2,3,4,5,6,7	#0
.long	2,3,4,5,6,7,0,0	#1
.long	0,1,4,5,6,7,0,0	#2
.long	4,5,6,7,0,0,0,0	#3
