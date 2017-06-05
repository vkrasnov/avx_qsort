
.set pivotALU, %ecx

.set A0, %ymm0
.set A1, %ymm1
.set A2, %ymm2
.set A3, %ymm3
.set A4, %ymm4

.set M0, %ymm5
.set M1, %ymm6
.set M2, %ymm7
.set M3, %ymm8
.set M4, %ymm9

.set S0, %ymm10
.set S1, %ymm11
.set S2, %ymm12
.set S3, %ymm13
.set S4, %ymm14

.set A5, %ymm10
.set A6, %ymm11

.set M5, %ymm12
.set M6, %ymm13

.set S5, %ymm4
.set TMP, %ymm14

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
    
 
.set el1, %xmm0
.set el2, %xmm1
.set el3, %xmm2
# Median of three
    mov n, r1
    shr $1, r1
    vmovss      (array), el1
    vmovss      (array, r1, 4), el3
    vmovss      -4(array, n, 4), el2
    
    # if el1 > el2
    vucomiss el2, el1    
    jbe     .Lm2
    # swap el1, el2
    vmovaps el1, %xmm3
    vmovaps el2, el1
    vmovaps %xmm3, el2
    
.Lm2:
    vucomiss el3, el2
    jbe     .Lm3
    # swap el2, el3
    vmovaps el3, %xmm3
    vmovaps el2, el3
    vmovaps %xmm3, el2
    
    # if el1 > el2
    vucomiss el2, el1
    jbe     .Lm3
    # swap el1, el2
    vmovaps el1, %xmm3
    vmovaps el2, el1
    vmovaps %xmm3, el2
.Lm3:
        
    vmovss      el1, (array)
    vmovss      el3, (array, r1, 4)
    vmovss      el2, -4(array, n, 4)
   
	vxorps	%ymm2, %ymm2, %ymm2
    vpermps %ymm1, %ymm2, PIVOT
    #vbroadcastss    -4(array, n, 4), PIVOT
    
    lea (array), bottom
    lea (temp_space), top
    dec n
    
jmp .Lx7_loop
.Lx7_loop:

    cmp $56, n
    jl  .Lx7_loop_exit

    # Load the next 56 elements
    vmovups 32*0(array), A0
    vmovups 32*1(array), A1
    vmovups 32*2(array), A2
    vmovups 32*3(array), A3
    vmovups 32*4(array), A4
    vmovups 32*5(array), A5
    vmovups 32*6(array), A6
    
    # Find elements lesser-than-equal to PIVOT
    vcmpps	$2, PIVOT, A0, M0
    vcmpps	$2, PIVOT, A1, M1
    vcmpps	$2, PIVOT, A2, M2
    vcmpps	$2, PIVOT, A3, M3
    vcmpps	$2, PIVOT, A4, M4
    vcmpps	$2, PIVOT, A5, M5
    vcmpps	$2, PIVOT, A6, M6

    vmovmskps   M0, r0
    vmovmskps   M1, r1
    vmovmskps   M2, r2
    vmovmskps   M3, r3
    vmovmskps   M4, r4
    vmovmskps   M5, r5
    vmovmskps   M6, r6
    
    shl $5, r0
    shl $5, r1
    shl $5, r2
    shl $5, r3
    shl $5, r4
    shl $5, r5
    shl $5, r6
        
    vmovdqa .LPermTableLeft(,r0), TMP
    vpermd  A0, TMP, M0
    vmovdqa .LPermTableLeft(,r1), TMP
    vpermd  A1, TMP, M1
    vmovdqa .LPermTableLeft(,r2), TMP
    vpermd  A2, TMP, M2
    vmovdqa .LPermTableLeft(,r3), TMP
    vpermd  A3, TMP, M3
    vmovdqa .LPermTableLeft(,r4), TMP
    vpermd  A4, TMP, M4
    vmovdqa .LPermTableLeft(,r5), TMP
    vpermd  A5, TMP, M5
    vmovdqa .LPermTableLeft(,r6), TMP
    vpermd  A6, TMP, M6
        
    vmovdqa .LPermTableRight(,r0), TMP
    vpermd  A0, TMP, A0
    vmovdqa .LPermTableRight(,r1), TMP
    vpermd  A1, TMP, A1
    vmovdqa .LPermTableRight(,r2), TMP
    vpermd  A2, TMP, A2
    vmovdqa .LPermTableRight(,r3), TMP
    vpermd  A3, TMP, A3
    vmovdqa .LPermTableRight(,r4), TMP
    vpermd  A4, TMP, A4
    vmovdqa .LPermTableRight(,r5), TMP
    vpermd  A5, TMP, A5
    vmovdqa .LPermTableRight(,r6), TMP
    vpermd  A6, TMP, A6
    
    popcnt  r0, r0
    popcnt  r1, r1
    popcnt  r2, r2
    popcnt  r3, r3
    popcnt  r4, r4
    popcnt  r5, r5
    popcnt  r6, r6
    
    
    vmovdqu M0, (bottom)
    lea (bottom, r0, 4), bottom
    vmovdqu M1, (bottom)
    lea (bottom, r1, 4), bottom
    vmovdqu M2, (bottom)
    lea (bottom, r2, 4), bottom
    vmovdqu M3, (bottom)
    lea (bottom, r3, 4), bottom
    vmovdqu M4, (bottom)
    lea (bottom, r4, 4), bottom
    vmovdqu M5, (bottom)
    lea (bottom, r5, 4), bottom
    vmovdqu M6, (bottom)
    lea (bottom, r6, 4), bottom
 	
	neg r0
	neg r1
	neg r2
	neg r3
	neg r4
	neg r5
	neg r6
	
    vmovdqu A0, (top)
	lea	32(top, r0, 4), top
    vmovdqu A1, (top)
	lea	32(top, r1, 4), top
    vmovdqu A2, (top)
	lea	32(top, r2, 4), top
    vmovdqu A3, (top)
	lea	32(top, r3, 4), top
    vmovdqu A4, (top)
	lea	32(top, r4, 4), top
    vmovdqu A5, (top)
	lea	32(top, r5, 4), top
    vmovdqu A6, (top)
	lea	32(top, r6, 4), top

    sub $56, n
    add $56*4, array
    jmp .Lx7_loop
    
.Lx7_loop_exit:

.Lx3_loop:

    cmp $24, n
    jl  .Lx3_loop_exit

    # Load the next 24 elements
    vmovups 32*0(array), A0
    vmovups 32*1(array), A1
    vmovups 32*2(array), A2
    
    # Find elements lesser-than-equal to PIVOT
    vcmpps	$2, PIVOT, A0, M0
    vcmpps	$2, PIVOT, A1, M1
    vcmpps	$2, PIVOT, A2, M2

    vmovmskps   M0, r0
    vmovmskps   M1, r1
    vmovmskps   M2, r2
    
    shl $5, r0
    shl $5, r1
    shl $5, r2
        
    vmovdqa .LPermTableLeft(,r0), S0
    vmovdqa .LPermTableLeft(,r1), S1
    vmovdqa .LPermTableLeft(,r2), S2
    vmovdqa .LPermTableRight(,r0), S3
    vmovdqa .LPermTableRight(,r1), S4
    vmovdqa .LPermTableRight(,r2), S5
    
    
    vpermd  A0, S0, M0
    vpermd  A1, S1, M1
    vpermd  A2, S2, M2
        
    vpermd  A0, S3, A0
    vpermd  A1, S4, A1
    vpermd  A2, S5, A2
    
    popcnt  r0, r0
    popcnt  r1, r1
    popcnt  r2, r2
	
    vmovdqu M0, (bottom)
    lea (bottom, r0, 4), bottom
    vmovdqu M1, (bottom)
    lea (bottom, r1, 4), bottom
    vmovdqu M2, (bottom)
    lea (bottom, r2, 4), bottom
	
	neg r0
	neg r1
	neg r2
    
    vmovdqu A0, (top)
	lea	32(top, r0, 4), top
    vmovdqu A1, (top)
	lea	32(top, r1, 4), top
    vmovdqu A2, (top)
	lea	32(top, r2, 4), top
	
    sub $24, n
    add $24*4, array
    jmp .Lx3_loop
    
.Lx3_loop_exit:


.Lx1_loop:

    # we want to be sure we do not collide when progressing from bottom and top
    cmp $8, n
    jl  .Lx1_loop_exit

    # Load the next 16 elements
    vmovups 32*0(array), A0
    
    # Find elements lesser-than-equal to PIVOT
    vcmpps	$2, PIVOT, A0, M0

    vmovmskps   M0, r0
    
    shl $5, r0
        
    vmovdqa     .LPermTableLeft(,r0), S0
    
    vpermd  A0, S0, M0
    
    vmovdqa     .LPermTableRight(,r0), S0
    
    vpermd  A0, S0, A0
    
    popcnt  r0, r0
    
    vmovdqu M0, (bottom)
    lea (bottom, r0, 4), bottom
    neg r0
    
    vmovdqu A0, (top)
	lea	32(top, r0, 4), top

    sub $8, n
    add $8*4, array
    jmp .Lx1_loop
    
.Lx1_loop_exit:

.Ls_loop:
    
    cmp $0, n
    je  .Ls_loop_exit
    
    vmovss      (array), %xmm0
    vucomiss    %xmm15, %xmm0
    
    ja  .Lgreater
    
        vmovss  %xmm0, (bottom)
        add $4, bottom
        add $4, array
        dec n
    
    jmp .Ls_loop
    
.Lgreater:
        vmovss  %xmm0, (top)
        add $4, top
        add $4, array
        dec n
    
    jmp .Ls_loop
    
.Ls_loop_exit:
    vmovss  %xmm15, (bottom)
    add $4, bottom
    
    sub temp_space, top
    shr $2, top
    mov top, %rax
    
.Lx4_copy_loop:
    cmp $32, top
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
    sub $32, top
    jmp .Lx4_copy_loop
.Lx4_copy_end:
    
.Lx1_copy_loop:
    cmp $8, top
    jl  .Lx1_copy_end
    
    vmovdqu 32*0(temp_space), %ymm0
    
    vmovdqu %ymm0, 32*0(bottom)
    
    lea 8*4(temp_space), temp_space
    lea 8*4(bottom), bottom
    sub $8, top
    jmp .Lx1_copy_loop

.Lx1_copy_end:



    cmp $0, top
    je  .Lcopy_end
    
    mov (temp_space), %r8d
    mov %r8d, (bottom)
    
    lea 4(temp_space), temp_space
    lea 4(bottom), bottom
    sub $1, top
    jmp .Lx4_copy_end

.Lcopy_end:
    pop %rbp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    
    ret
    
.align 64
.LPermTableLeft:

.long	0,0,0,0,0,0,0,0	#0
.long	0,0,0,0,0,0,0,0	#1
.long	1,0,0,0,0,0,0,0	#2
.long	0,1,0,0,0,0,0,0	#3
.long	2,0,0,0,0,0,0,0	#4
.long	0,2,0,0,0,0,0,0	#5
.long	1,2,0,0,0,0,0,0	#6
.long	0,1,2,0,0,0,0,0	#7
.long	3,0,0,0,0,0,0,0	#8
.long	0,3,0,0,0,0,0,0	#9
.long	1,3,0,0,0,0,0,0	#10
.long	0,1,3,0,0,0,0,0	#11
.long	2,3,0,0,0,0,0,0	#12
.long	0,2,3,0,0,0,0,0	#13
.long	1,2,3,0,0,0,0,0	#14
.long	0,1,2,3,0,0,0,0	#15
.long	4,0,0,0,0,0,0,0	#16
.long	0,4,0,0,0,0,0,0	#17
.long	1,4,0,0,0,0,0,0	#18
.long	0,1,4,0,0,0,0,0	#19
.long	2,4,0,0,0,0,0,0	#20
.long	0,2,4,0,0,0,0,0	#21
.long	1,2,4,0,0,0,0,0	#22
.long	0,1,2,4,0,0,0,0	#23
.long	3,4,0,0,0,0,0,0	#24
.long	0,3,4,0,0,0,0,0	#25
.long	1,3,4,0,0,0,0,0	#26
.long	0,1,3,4,0,0,0,0	#27
.long	2,3,4,0,0,0,0,0	#28
.long	0,2,3,4,0,0,0,0	#29
.long	1,2,3,4,0,0,0,0	#30
.long	0,1,2,3,4,0,0,0	#31
.long	5,0,0,0,0,0,0,0	#32
.long	0,5,0,0,0,0,0,0	#33
.long	1,5,0,0,0,0,0,0	#34
.long	0,1,5,0,0,0,0,0	#35
.long	2,5,0,0,0,0,0,0	#36
.long	0,2,5,0,0,0,0,0	#37
.long	1,2,5,0,0,0,0,0	#38
.long	0,1,2,5,0,0,0,0	#39
.long	3,5,0,0,0,0,0,0	#40
.long	0,3,5,0,0,0,0,0	#41
.long	1,3,5,0,0,0,0,0	#42
.long	0,1,3,5,0,0,0,0	#43
.long	2,3,5,0,0,0,0,0	#44
.long	0,2,3,5,0,0,0,0	#45
.long	1,2,3,5,0,0,0,0	#46
.long	0,1,2,3,5,0,0,0	#47
.long	4,5,0,0,0,0,0,0	#48
.long	0,4,5,0,0,0,0,0	#49
.long	1,4,5,0,0,0,0,0	#50
.long	0,1,4,5,0,0,0,0	#51
.long	2,4,5,0,0,0,0,0	#52
.long	0,2,4,5,0,0,0,0	#53
.long	1,2,4,5,0,0,0,0	#54
.long	0,1,2,4,5,0,0,0	#55
.long	3,4,5,0,0,0,0,0	#56
.long	0,3,4,5,0,0,0,0	#57
.long	1,3,4,5,0,0,0,0	#58
.long	0,1,3,4,5,0,0,0	#59
.long	2,3,4,5,0,0,0,0	#60
.long	0,2,3,4,5,0,0,0	#61
.long	1,2,3,4,5,0,0,0	#62
.long	0,1,2,3,4,5,0,0	#63
.long	6,0,0,0,0,0,0,0	#64
.long	0,6,0,0,0,0,0,0	#65
.long	1,6,0,0,0,0,0,0	#66
.long	0,1,6,0,0,0,0,0	#67
.long	2,6,0,0,0,0,0,0	#68
.long	0,2,6,0,0,0,0,0	#69
.long	1,2,6,0,0,0,0,0	#70
.long	0,1,2,6,0,0,0,0	#71
.long	3,6,0,0,0,0,0,0	#72
.long	0,3,6,0,0,0,0,0	#73
.long	1,3,6,0,0,0,0,0	#74
.long	0,1,3,6,0,0,0,0	#75
.long	2,3,6,0,0,0,0,0	#76
.long	0,2,3,6,0,0,0,0	#77
.long	1,2,3,6,0,0,0,0	#78
.long	0,1,2,3,6,0,0,0	#79
.long	4,6,0,0,0,0,0,0	#80
.long	0,4,6,0,0,0,0,0	#81
.long	1,4,6,0,0,0,0,0	#82
.long	0,1,4,6,0,0,0,0	#83
.long	2,4,6,0,0,0,0,0	#84
.long	0,2,4,6,0,0,0,0	#85
.long	1,2,4,6,0,0,0,0	#86
.long	0,1,2,4,6,0,0,0	#87
.long	3,4,6,0,0,0,0,0	#88
.long	0,3,4,6,0,0,0,0	#89
.long	1,3,4,6,0,0,0,0	#90
.long	0,1,3,4,6,0,0,0	#91
.long	2,3,4,6,0,0,0,0	#92
.long	0,2,3,4,6,0,0,0	#93
.long	1,2,3,4,6,0,0,0	#94
.long	0,1,2,3,4,6,0,0	#95
.long	5,6,0,0,0,0,0,0	#96
.long	0,5,6,0,0,0,0,0	#97
.long	1,5,6,0,0,0,0,0	#98
.long	0,1,5,6,0,0,0,0	#99
.long	2,5,6,0,0,0,0,0	#100
.long	0,2,5,6,0,0,0,0	#101
.long	1,2,5,6,0,0,0,0	#102
.long	0,1,2,5,6,0,0,0	#103
.long	3,5,6,0,0,0,0,0	#104
.long	0,3,5,6,0,0,0,0	#105
.long	1,3,5,6,0,0,0,0	#106
.long	0,1,3,5,6,0,0,0	#107
.long	2,3,5,6,0,0,0,0	#108
.long	0,2,3,5,6,0,0,0	#109
.long	1,2,3,5,6,0,0,0	#110
.long	0,1,2,3,5,6,0,0	#111
.long	4,5,6,0,0,0,0,0	#112
.long	0,4,5,6,0,0,0,0	#113
.long	1,4,5,6,0,0,0,0	#114
.long	0,1,4,5,6,0,0,0	#115
.long	2,4,5,6,0,0,0,0	#116
.long	0,2,4,5,6,0,0,0	#117
.long	1,2,4,5,6,0,0,0	#118
.long	0,1,2,4,5,6,0,0	#119
.long	3,4,5,6,0,0,0,0	#120
.long	0,3,4,5,6,0,0,0	#121
.long	1,3,4,5,6,0,0,0	#122
.long	0,1,3,4,5,6,0,0	#123
.long	2,3,4,5,6,0,0,0	#124
.long	0,2,3,4,5,6,0,0	#125
.long	1,2,3,4,5,6,0,0	#126
.long	0,1,2,3,4,5,6,0	#127
.long	7,0,0,0,0,0,0,0	#128
.long	0,7,0,0,0,0,0,0	#129
.long	1,7,0,0,0,0,0,0	#130
.long	0,1,7,0,0,0,0,0	#131
.long	2,7,0,0,0,0,0,0	#132
.long	0,2,7,0,0,0,0,0	#133
.long	1,2,7,0,0,0,0,0	#134
.long	0,1,2,7,0,0,0,0	#135
.long	3,7,0,0,0,0,0,0	#136
.long	0,3,7,0,0,0,0,0	#137
.long	1,3,7,0,0,0,0,0	#138
.long	0,1,3,7,0,0,0,0	#139
.long	2,3,7,0,0,0,0,0	#140
.long	0,2,3,7,0,0,0,0	#141
.long	1,2,3,7,0,0,0,0	#142
.long	0,1,2,3,7,0,0,0	#143
.long	4,7,0,0,0,0,0,0	#144
.long	0,4,7,0,0,0,0,0	#145
.long	1,4,7,0,0,0,0,0	#146
.long	0,1,4,7,0,0,0,0	#147
.long	2,4,7,0,0,0,0,0	#148
.long	0,2,4,7,0,0,0,0	#149
.long	1,2,4,7,0,0,0,0	#150
.long	0,1,2,4,7,0,0,0	#151
.long	3,4,7,0,0,0,0,0	#152
.long	0,3,4,7,0,0,0,0	#153
.long	1,3,4,7,0,0,0,0	#154
.long	0,1,3,4,7,0,0,0	#155
.long	2,3,4,7,0,0,0,0	#156
.long	0,2,3,4,7,0,0,0	#157
.long	1,2,3,4,7,0,0,0	#158
.long	0,1,2,3,4,7,0,0	#159
.long	5,7,0,0,0,0,0,0	#160
.long	0,5,7,0,0,0,0,0	#161
.long	1,5,7,0,0,0,0,0	#162
.long	0,1,5,7,0,0,0,0	#163
.long	2,5,7,0,0,0,0,0	#164
.long	0,2,5,7,0,0,0,0	#165
.long	1,2,5,7,0,0,0,0	#166
.long	0,1,2,5,7,0,0,0	#167
.long	3,5,7,0,0,0,0,0	#168
.long	0,3,5,7,0,0,0,0	#169
.long	1,3,5,7,0,0,0,0	#170
.long	0,1,3,5,7,0,0,0	#171
.long	2,3,5,7,0,0,0,0	#172
.long	0,2,3,5,7,0,0,0	#173
.long	1,2,3,5,7,0,0,0	#174
.long	0,1,2,3,5,7,0,0	#175
.long	4,5,7,0,0,0,0,0	#176
.long	0,4,5,7,0,0,0,0	#177
.long	1,4,5,7,0,0,0,0	#178
.long	0,1,4,5,7,0,0,0	#179
.long	2,4,5,7,0,0,0,0	#180
.long	0,2,4,5,7,0,0,0	#181
.long	1,2,4,5,7,0,0,0	#182
.long	0,1,2,4,5,7,0,0	#183
.long	3,4,5,7,0,0,0,0	#184
.long	0,3,4,5,7,0,0,0	#185
.long	1,3,4,5,7,0,0,0	#186
.long	0,1,3,4,5,7,0,0	#187
.long	2,3,4,5,7,0,0,0	#188
.long	0,2,3,4,5,7,0,0	#189
.long	1,2,3,4,5,7,0,0	#190
.long	0,1,2,3,4,5,7,0	#191
.long	6,7,0,0,0,0,0,0	#192
.long	0,6,7,0,0,0,0,0	#193
.long	1,6,7,0,0,0,0,0	#194
.long	0,1,6,7,0,0,0,0	#195
.long	2,6,7,0,0,0,0,0	#196
.long	0,2,6,7,0,0,0,0	#197
.long	1,2,6,7,0,0,0,0	#198
.long	0,1,2,6,7,0,0,0	#199
.long	3,6,7,0,0,0,0,0	#200
.long	0,3,6,7,0,0,0,0	#201
.long	1,3,6,7,0,0,0,0	#202
.long	0,1,3,6,7,0,0,0	#203
.long	2,3,6,7,0,0,0,0	#204
.long	0,2,3,6,7,0,0,0	#205
.long	1,2,3,6,7,0,0,0	#206
.long	0,1,2,3,6,7,0,0	#207
.long	4,6,7,0,0,0,0,0	#208
.long	0,4,6,7,0,0,0,0	#209
.long	1,4,6,7,0,0,0,0	#210
.long	0,1,4,6,7,0,0,0	#211
.long	2,4,6,7,0,0,0,0	#212
.long	0,2,4,6,7,0,0,0	#213
.long	1,2,4,6,7,0,0,0	#214
.long	0,1,2,4,6,7,0,0	#215
.long	3,4,6,7,0,0,0,0	#216
.long	0,3,4,6,7,0,0,0	#217
.long	1,3,4,6,7,0,0,0	#218
.long	0,1,3,4,6,7,0,0	#219
.long	2,3,4,6,7,0,0,0	#220
.long	0,2,3,4,6,7,0,0	#221
.long	1,2,3,4,6,7,0,0	#222
.long	0,1,2,3,4,6,7,0	#223
.long	5,6,7,0,0,0,0,0	#224
.long	0,5,6,7,0,0,0,0	#225
.long	1,5,6,7,0,0,0,0	#226
.long	0,1,5,6,7,0,0,0	#227
.long	2,5,6,7,0,0,0,0	#228
.long	0,2,5,6,7,0,0,0	#229
.long	1,2,5,6,7,0,0,0	#230
.long	0,1,2,5,6,7,0,0	#231
.long	3,5,6,7,0,0,0,0	#232
.long	0,3,5,6,7,0,0,0	#233
.long	1,3,5,6,7,0,0,0	#234
.long	0,1,3,5,6,7,0,0	#235
.long	2,3,5,6,7,0,0,0	#236
.long	0,2,3,5,6,7,0,0	#237
.long	1,2,3,5,6,7,0,0	#238
.long	0,1,2,3,5,6,7,0	#239
.long	4,5,6,7,0,0,0,0	#240
.long	0,4,5,6,7,0,0,0	#241
.long	1,4,5,6,7,0,0,0	#242
.long	0,1,4,5,6,7,0,0	#243
.long	2,4,5,6,7,0,0,0	#244
.long	0,2,4,5,6,7,0,0	#245
.long	1,2,4,5,6,7,0,0	#246
.long	0,1,2,4,5,6,7,0	#247
.long	3,4,5,6,7,0,0,0	#248
.long	0,3,4,5,6,7,0,0	#249
.long	1,3,4,5,6,7,0,0	#250
.long	0,1,3,4,5,6,7,0	#251
.long	2,3,4,5,6,7,0,0	#252
.long	0,2,3,4,5,6,7,0	#253
.long	1,2,3,4,5,6,7,0	#254
.long	0,1,2,3,4,5,6,7	#255

.LPermTableRight:

.long	0,1,2,3,4,5,6,7	#0
.long	1,2,3,4,5,6,7,0	#1
.long	0,2,3,4,5,6,7,0	#2
.long	2,3,4,5,6,7,0,0	#3
.long	0,1,3,4,5,6,7,0	#4
.long	1,3,4,5,6,7,0,0	#5
.long	0,3,4,5,6,7,0,0	#6
.long	3,4,5,6,7,0,0,0	#7
.long	0,1,2,4,5,6,7,0	#8
.long	1,2,4,5,6,7,0,0	#9
.long	0,2,4,5,6,7,0,0	#10
.long	2,4,5,6,7,0,0,0	#11
.long	0,1,4,5,6,7,0,0	#12
.long	1,4,5,6,7,0,0,0	#13
.long	0,4,5,6,7,0,0,0	#14
.long	4,5,6,7,0,0,0,0	#15
.long	0,1,2,3,5,6,7,0	#16
.long	1,2,3,5,6,7,0,0	#17
.long	0,2,3,5,6,7,0,0	#18
.long	2,3,5,6,7,0,0,0	#19
.long	0,1,3,5,6,7,0,0	#20
.long	1,3,5,6,7,0,0,0	#21
.long	0,3,5,6,7,0,0,0	#22
.long	3,5,6,7,0,0,0,0	#23
.long	0,1,2,5,6,7,0,0	#24
.long	1,2,5,6,7,0,0,0	#25
.long	0,2,5,6,7,0,0,0	#26
.long	2,5,6,7,0,0,0,0	#27
.long	0,1,5,6,7,0,0,0	#28
.long	1,5,6,7,0,0,0,0	#29
.long	0,5,6,7,0,0,0,0	#30
.long	5,6,7,0,0,0,0,0	#31
.long	0,1,2,3,4,6,7,0	#32
.long	1,2,3,4,6,7,0,0	#33
.long	0,2,3,4,6,7,0,0	#34
.long	2,3,4,6,7,0,0,0	#35
.long	0,1,3,4,6,7,0,0	#36
.long	1,3,4,6,7,0,0,0	#37
.long	0,3,4,6,7,0,0,0	#38
.long	3,4,6,7,0,0,0,0	#39
.long	0,1,2,4,6,7,0,0	#40
.long	1,2,4,6,7,0,0,0	#41
.long	0,2,4,6,7,0,0,0	#42
.long	2,4,6,7,0,0,0,0	#43
.long	0,1,4,6,7,0,0,0	#44
.long	1,4,6,7,0,0,0,0	#45
.long	0,4,6,7,0,0,0,0	#46
.long	4,6,7,0,0,0,0,0	#47
.long	0,1,2,3,6,7,0,0	#48
.long	1,2,3,6,7,0,0,0	#49
.long	0,2,3,6,7,0,0,0	#50
.long	2,3,6,7,0,0,0,0	#51
.long	0,1,3,6,7,0,0,0	#52
.long	1,3,6,7,0,0,0,0	#53
.long	0,3,6,7,0,0,0,0	#54
.long	3,6,7,0,0,0,0,0	#55
.long	0,1,2,6,7,0,0,0	#56
.long	1,2,6,7,0,0,0,0	#57
.long	0,2,6,7,0,0,0,0	#58
.long	2,6,7,0,0,0,0,0	#59
.long	0,1,6,7,0,0,0,0	#60
.long	1,6,7,0,0,0,0,0	#61
.long	0,6,7,0,0,0,0,0	#62
.long	6,7,0,0,0,0,0,0	#63
.long	0,1,2,3,4,5,7,0	#64
.long	1,2,3,4,5,7,0,0	#65
.long	0,2,3,4,5,7,0,0	#66
.long	2,3,4,5,7,0,0,0	#67
.long	0,1,3,4,5,7,0,0	#68
.long	1,3,4,5,7,0,0,0	#69
.long	0,3,4,5,7,0,0,0	#70
.long	3,4,5,7,0,0,0,0	#71
.long	0,1,2,4,5,7,0,0	#72
.long	1,2,4,5,7,0,0,0	#73
.long	0,2,4,5,7,0,0,0	#74
.long	2,4,5,7,0,0,0,0	#75
.long	0,1,4,5,7,0,0,0	#76
.long	1,4,5,7,0,0,0,0	#77
.long	0,4,5,7,0,0,0,0	#78
.long	4,5,7,0,0,0,0,0	#79
.long	0,1,2,3,5,7,0,0	#80
.long	1,2,3,5,7,0,0,0	#81
.long	0,2,3,5,7,0,0,0	#82
.long	2,3,5,7,0,0,0,0	#83
.long	0,1,3,5,7,0,0,0	#84
.long	1,3,5,7,0,0,0,0	#85
.long	0,3,5,7,0,0,0,0	#86
.long	3,5,7,0,0,0,0,0	#87
.long	0,1,2,5,7,0,0,0	#88
.long	1,2,5,7,0,0,0,0	#89
.long	0,2,5,7,0,0,0,0	#90
.long	2,5,7,0,0,0,0,0	#91
.long	0,1,5,7,0,0,0,0	#92
.long	1,5,7,0,0,0,0,0	#93
.long	0,5,7,0,0,0,0,0	#94
.long	5,7,0,0,0,0,0,0	#95
.long	0,1,2,3,4,7,0,0	#96
.long	1,2,3,4,7,0,0,0	#97
.long	0,2,3,4,7,0,0,0	#98
.long	2,3,4,7,0,0,0,0	#99
.long	0,1,3,4,7,0,0,0	#100
.long	1,3,4,7,0,0,0,0	#101
.long	0,3,4,7,0,0,0,0	#102
.long	3,4,7,0,0,0,0,0	#103
.long	0,1,2,4,7,0,0,0	#104
.long	1,2,4,7,0,0,0,0	#105
.long	0,2,4,7,0,0,0,0	#106
.long	2,4,7,0,0,0,0,0	#107
.long	0,1,4,7,0,0,0,0	#108
.long	1,4,7,0,0,0,0,0	#109
.long	0,4,7,0,0,0,0,0	#110
.long	4,7,0,0,0,0,0,0	#111
.long	0,1,2,3,7,0,0,0	#112
.long	1,2,3,7,0,0,0,0	#113
.long	0,2,3,7,0,0,0,0	#114
.long	2,3,7,0,0,0,0,0	#115
.long	0,1,3,7,0,0,0,0	#116
.long	1,3,7,0,0,0,0,0	#117
.long	0,3,7,0,0,0,0,0	#118
.long	3,7,0,0,0,0,0,0	#119
.long	0,1,2,7,0,0,0,0	#120
.long	1,2,7,0,0,0,0,0	#121
.long	0,2,7,0,0,0,0,0	#122
.long	2,7,0,0,0,0,0,0	#123
.long	0,1,7,0,0,0,0,0	#124
.long	1,7,0,0,0,0,0,0	#125
.long	0,7,0,0,0,0,0,0	#126
.long	7,0,0,0,0,0,0,0	#127
.long	0,1,2,3,4,5,6,0	#128
.long	1,2,3,4,5,6,0,0	#129
.long	0,2,3,4,5,6,0,0	#130
.long	2,3,4,5,6,0,0,0	#131
.long	0,1,3,4,5,6,0,0	#132
.long	1,3,4,5,6,0,0,0	#133
.long	0,3,4,5,6,0,0,0	#134
.long	3,4,5,6,0,0,0,0	#135
.long	0,1,2,4,5,6,0,0	#136
.long	1,2,4,5,6,0,0,0	#137
.long	0,2,4,5,6,0,0,0	#138
.long	2,4,5,6,0,0,0,0	#139
.long	0,1,4,5,6,0,0,0	#140
.long	1,4,5,6,0,0,0,0	#141
.long	0,4,5,6,0,0,0,0	#142
.long	4,5,6,0,0,0,0,0	#143
.long	0,1,2,3,5,6,0,0	#144
.long	1,2,3,5,6,0,0,0	#145
.long	0,2,3,5,6,0,0,0	#146
.long	2,3,5,6,0,0,0,0	#147
.long	0,1,3,5,6,0,0,0	#148
.long	1,3,5,6,0,0,0,0	#149
.long	0,3,5,6,0,0,0,0	#150
.long	3,5,6,0,0,0,0,0	#151
.long	0,1,2,5,6,0,0,0	#152
.long	1,2,5,6,0,0,0,0	#153
.long	0,2,5,6,0,0,0,0	#154
.long	2,5,6,0,0,0,0,0	#155
.long	0,1,5,6,0,0,0,0	#156
.long	1,5,6,0,0,0,0,0	#157
.long	0,5,6,0,0,0,0,0	#158
.long	5,6,0,0,0,0,0,0	#159
.long	0,1,2,3,4,6,0,0	#160
.long	1,2,3,4,6,0,0,0	#161
.long	0,2,3,4,6,0,0,0	#162
.long	2,3,4,6,0,0,0,0	#163
.long	0,1,3,4,6,0,0,0	#164
.long	1,3,4,6,0,0,0,0	#165
.long	0,3,4,6,0,0,0,0	#166
.long	3,4,6,0,0,0,0,0	#167
.long	0,1,2,4,6,0,0,0	#168
.long	1,2,4,6,0,0,0,0	#169
.long	0,2,4,6,0,0,0,0	#170
.long	2,4,6,0,0,0,0,0	#171
.long	0,1,4,6,0,0,0,0	#172
.long	1,4,6,0,0,0,0,0	#173
.long	0,4,6,0,0,0,0,0	#174
.long	4,6,0,0,0,0,0,0	#175
.long	0,1,2,3,6,0,0,0	#176
.long	1,2,3,6,0,0,0,0	#177
.long	0,2,3,6,0,0,0,0	#178
.long	2,3,6,0,0,0,0,0	#179
.long	0,1,3,6,0,0,0,0	#180
.long	1,3,6,0,0,0,0,0	#181
.long	0,3,6,0,0,0,0,0	#182
.long	3,6,0,0,0,0,0,0	#183
.long	0,1,2,6,0,0,0,0	#184
.long	1,2,6,0,0,0,0,0	#185
.long	0,2,6,0,0,0,0,0	#186
.long	2,6,0,0,0,0,0,0	#187
.long	0,1,6,0,0,0,0,0	#188
.long	1,6,0,0,0,0,0,0	#189
.long	0,6,0,0,0,0,0,0	#190
.long	6,0,0,0,0,0,0,0	#191
.long	0,1,2,3,4,5,0,0	#192
.long	1,2,3,4,5,0,0,0	#193
.long	0,2,3,4,5,0,0,0	#194
.long	2,3,4,5,0,0,0,0	#195
.long	0,1,3,4,5,0,0,0	#196
.long	1,3,4,5,0,0,0,0	#197
.long	0,3,4,5,0,0,0,0	#198
.long	3,4,5,0,0,0,0,0	#199
.long	0,1,2,4,5,0,0,0	#200
.long	1,2,4,5,0,0,0,0	#201
.long	0,2,4,5,0,0,0,0	#202
.long	2,4,5,0,0,0,0,0	#203
.long	0,1,4,5,0,0,0,0	#204
.long	1,4,5,0,0,0,0,0	#205
.long	0,4,5,0,0,0,0,0	#206
.long	4,5,0,0,0,0,0,0	#207
.long	0,1,2,3,5,0,0,0	#208
.long	1,2,3,5,0,0,0,0	#209
.long	0,2,3,5,0,0,0,0	#210
.long	2,3,5,0,0,0,0,0	#211
.long	0,1,3,5,0,0,0,0	#212
.long	1,3,5,0,0,0,0,0	#213
.long	0,3,5,0,0,0,0,0	#214
.long	3,5,0,0,0,0,0,0	#215
.long	0,1,2,5,0,0,0,0	#216
.long	1,2,5,0,0,0,0,0	#217
.long	0,2,5,0,0,0,0,0	#218
.long	2,5,0,0,0,0,0,0	#219
.long	0,1,5,0,0,0,0,0	#220
.long	1,5,0,0,0,0,0,0	#221
.long	0,5,0,0,0,0,0,0	#222
.long	5,0,0,0,0,0,0,0	#223
.long	0,1,2,3,4,0,0,0	#224
.long	1,2,3,4,0,0,0,0	#225
.long	0,2,3,4,0,0,0,0	#226
.long	2,3,4,0,0,0,0,0	#227
.long	0,1,3,4,0,0,0,0	#228
.long	1,3,4,0,0,0,0,0	#229
.long	0,3,4,0,0,0,0,0	#230
.long	3,4,0,0,0,0,0,0	#231
.long	0,1,2,4,0,0,0,0	#232
.long	1,2,4,0,0,0,0,0	#233
.long	0,2,4,0,0,0,0,0	#234
.long	2,4,0,0,0,0,0,0	#235
.long	0,1,4,0,0,0,0,0	#236
.long	1,4,0,0,0,0,0,0	#237
.long	0,4,0,0,0,0,0,0	#238
.long	4,0,0,0,0,0,0,0	#239
.long	0,1,2,3,0,0,0,0	#240
.long	1,2,3,0,0,0,0,0	#241
.long	0,2,3,0,0,0,0,0	#242
.long	2,3,0,0,0,0,0,0	#243
.long	0,1,3,0,0,0,0,0	#244
.long	1,3,0,0,0,0,0,0	#245
.long	0,3,0,0,0,0,0,0	#246
.long	3,0,0,0,0,0,0,0	#247
.long	0,1,2,0,0,0,0,0	#248
.long	1,2,0,0,0,0,0,0	#249
.long	0,2,0,0,0,0,0,0	#250
.long	2,0,0,0,0,0,0,0	#251
.long	0,1,0,0,0,0,0,0	#252
.long	1,0,0,0,0,0,0,0	#253
.long	0,0,0,0,0,0,0,0	#254
.long	0,0,0,0,0,0,0,0	#255
