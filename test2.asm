.data 
	x: .word 0x8000
	
.text 
control:
	sw $0, 0xDC60($0)
lw $s1, 0xAC60($0)   #which case
addi $s2, $0, 0
beq $s1, $s2, case1
addi $s2, $0, 1
beq $s1, $s2, case2
addi $s2, $0, 2
beq $s1, $s2, case3
addi $s2, $0, 3
beq $s1, $s2, case4
addi $s2, $0, 4
beq $s1, $s2, case5
addi $s2, $0, 5
beq $s1, $s2, case6
addi $s2, $0, 6
beq $s1, $s2, case7
addi $s2, $0, 7
beq $s1, $s2, case8
j control

case1:
	lw $a0, 0x8C60($0)  #a
	addi $t2, $0, 1
	andi $t1, $a0, 8
	bne $t1, $0, else1
	jal sum1
	sw $v0, 0xBC70($0)  #show
	j control
	else1:

	addi $t1, $0, 1000
	loop1:
	beq $t1, $0, end1
	addi $t1, $t1, -1
	sw $t2, 0xDC70($0) #SHOW 1
		addi $t4, $0, 1000
		loop11:
		beq $t4, $0, end11
		addi $t4, $t4, -1
		j loop11
		end11:
	j loop1
	end1:
	
	addi $t1, $0, 1000
	loop2:
	beq $t1, $0, end2
	addi $t1, $t1, -1
	sw $0, 0xDC70($0) #SHOW 0
		addi $t4, $0, 1000
		loop21:
		beq $t4, $0, end21
		addi $t4, $t4, -1
		j loop21
		end21:
	j loop2
	end2:
	
	j control
case2:
	lw $a0, 0x8C60($0)  #a
	addi $v1, $0, 0
	jal sum2
	sw $v1, 0xBC70($0)
	j control
case3:
	lw $a0, 0x8C60($0)  #a
	addi $v1, $0, 0
	jal sum3
	j control
case4:
	lw $a0, 0x8C60($0)  #a
	addi $v1, $0, 0
	jal sum4
	j control
case5:
	lw $t1, 0x8C60($0)  #a
	lw $t2, 0x9C60($0)  #b
	add $a1, $0, $t1
	jal signTurn
	add $t1, $0, $v0
	add $a1, $0, $t2
	jal signTurn
	add $t2, $0, $v0
	
	addi $t4, $0, 1
	add $t0, $t1, $t2
	slti $t3, $t0, 8
	beq $t3, $0, Overflow
	slti $t3, $t0, -8
	bne $t3, $0, Overflow
	No_overflow:
		sw $t0, 0xBC60($0)  #show result
		j control
	Overflow:
		sw $0, 0xBC60($0) 
		sw $t4, 0xDC60($0)  #show overflow(led)
	j control
case6:
	lw $t1, 0x8C60($0)  #a
	lw $t2, 0x9C60($0)  #b
	addi $t4, $0, 1
	add $a1, $0, $t1
	jal signTurn
	add $t1, $0, $v0
	add $a1, $0, $t2
	jal signTurn
	add $t2, $0, $v0
	
	sub $t0, $t1, $t2
	slti $t3, $t0, 8
	beq $t3, $0, Overflow2
	slti $t3, $t0, -8
	bne $t3, $0, Overflow2
	No_overflow2:
		sw $t0, 0xBC60($0)  #show result
		j control
	Overflow2:
		sw $0, 0xBC60($0) 
		sw $t4, 0xDC60($0)  #show overflow(led)
	j control
case7:	
	lw $t1, 0x8C60($0)  #a
	lw $t2, 0x9C60($0)  #b
	andi $t4, $t1, 8
	beq $t4, $0, apos
	addi $s2, $0, 16
	sub $t1, $s2, $t1
	apos:	
	andi $t5, $t2, 8
	beq $t5, $0, bpos
	addi $s2, $0, 16
	sub $t2, $s2, $t2
	bpos:
	xor $t5, $t4, $t5  # 0: pos   1: neg
	
	add $t0,$0,$0
	addi $t3, $0, 4
	loopmul:
	beq $t3,$0,endmul
	andi $s2,$t2, 1
	beq $s2, $0, jumpAdd
	add $t0, $t1, $t0
	jumpAdd:
	sll $t1,$t1,1
	srl $t2,$t2,1
	addi $t3,$t3,-1
	j loopmul
	endmul:
	beq $t5, $0, abpos
	nor $t0, $0, $t0
	addi $t0, $t0, 1
	abpos:
	sw $t0, 0xBC60($0)  #show result
	j control
case8:
	lw $t1, 0x8C60($0)  #a
	lw $t2, 0x9C60($0)  #b
	andi $t6, $t1, 8
	beq $t6, $0, aposDiv
	addi $s2, $0, 16
	sub $t1, $s2, $t1
	aposDiv:	
	andi $t5, $t2, 8
	beq $t5, $0, bposDiv
	addi $s2, $0, 16
	sub $t2, $s2, $t2
	bposDiv:
	xor $t5, $t6, $t5  # 0: pos   1: neg
	
	sll $t2,$t2,4 # t2 : dividor
	addi $t3,$t1,0 # t3 store the remainder
	add $t4,$0,$0 # t4 Quot
	lw $a0,x($0)
	add $t0,$0,$0 # t0: loop cnt
	addi $v0,$0,5 #v0: looptimes
	loopb: #MIPS piece2/3
# $t1: dividend, $t2: divisor, $t3: remainder, $t4: quot
# $a0: 0x8000, $v0: 5
	sub $t3,$t3,$t2 #dividend - dividor
	and $s0,$t3,$a0 # get the higest bit of rem to check if rem<0
	sll $t4,$t4,1 # shift left quot with 1bit
	beq $s0,$0, SdrUq # if rem>=0, shift Div right
	add $t3,$t3,$t2 # if rem<0, rem=rem+div
	srl $t2,$t2,1
	addi $t4,$t4,0
	j loope
	SdrUq:
	srl $t2,$t2,1
	addi $t4,$t4,1
	loope:
	addi $t0,$t0,1
	bne $t0,$v0,loopb

	beq $t5, $0, qpos
	nor $t4, $0, $t4
	addi $t4, $t4, 1
	qpos:
	sw $t4, 0xBC60($0)
	addi $a1, $0, 4000
	jal wait
	beq $t6, $0, rpos
	nor $t3, $0, $t3
	addi $t3, $t3, 1
	rpos:
	sw $t3, 0xBC60($0)
	addi $a1, $0, 4000
	jal wait
	j control
sum1:
addi $sp,$sp,-8 #adjust stack for 2 items
sw $ra, 4($sp) #save the return address
sw $a0, 0($sp) #save the argument n
slti $t0,$a0,1 #test for n<1
beq $t0,$zero,L1 #if n>=1,go to L1
addi $v0,$zero,0#urn 10
addi $sp,$sp,8 #pop 2 items off stack
jr $ra #return to caller
L1: 
addi $a0,$a0,-1 #n>=1; argument gets(n-1)
jal sum1 #call fact with(n-1)
lw $a0,0($sp) #return from jal: restore argument n
lw $ra,4($sp) #restore the return address
addi $sp,$sp,8 #adjust stack pointer to pop 2 items
add $v0,$a0,$v0 #return n*fact(n-1)
jr $ra	


sum2:
addi $sp,$sp,-8 #adjust stack for 2 items
sw $ra, 4($sp) #save the return address
sw $a0, 0($sp) #save the argument n
addi $v1, $v1, 2
slti $t0,$a0,1 #test for n<1
beq $t0,$zero,L2 #if n>=1,go to L1
addi $v0,$zero,0 #return 0
addi $sp,$sp,8 #pop 2 items off stack
jr $ra #return to caller
L2: 
addi $a0,$a0,-1 #n>=1; argument gets(n-1)
jal sum2 #call fact with(n-1)
lw $a0,0($sp) #return from jal: restore argument n
lw $ra,4($sp) #restore the return address
addi $sp,$sp,8 #adjust stack pointer to pop 2 items
add $v0,$a0,$v0 #return n*fact(n-1)
jr $ra

sum3:
addi $sp,$sp,-8 
sw $ra, 4($sp) 
sw $a0, 0($sp) 
	sw $a0, 0xBC70($0) #SHOW argument into stack
	addi $a1, $0, 3000
	jal wait      # ra change
slti $t0,$a0,1 
beq $t0,$zero,L3 
addi $v0,$zero,0
lw $ra,4($sp)
addi $sp,$sp,8 
jr $ra 
L3: 
addi $a0,$a0,-1 
jal sum3 
lw $a0,0($sp) 
lw $ra,4($sp)
addi $sp,$sp,8 
add $v0,$a0,$v0 
jr $ra

sum4:
addi $sp,$sp,-8 
sw $ra, 4($sp) 
sw $a0, 0($sp) 
slti $t0,$a0,1 
beq $t0,$zero,L4 
	sw $a0, 0xBC70($0) #SHOW argument out of stack
	addi $a1, $0, 3000
	jal wait
addi $v0,$zero,0
lw $ra,4($sp)
addi $sp,$sp,8 
jr $ra 
L4: 
addi $a0,$a0,-1 
jal sum4 
lw $a0,0($sp) 
	sw $a0, 0xBC70($0) #SHOW argument out of stack
	addi $a1, $0, 3000
	jal wait 
lw $ra,4($sp)
addi $sp,$sp,8
add $v0,$a0,$v0 
jr $ra

wait:
	add $s1, $0, $a1
	loopwait:
	beq $s1, $0, endwait
	addi $s1, $s1, -1
		add $s4, $0, $a1
		loopwait1:
		beq $s4, $0, endwait1
		addi $s4, $s4, -1
		j loopwait1
		endwait1:
	j loopwait
	endwait:
	jr $ra

signTurn:
	add $s1, $0, $a1
	add $v0, $0, $a1
	andi $s1, $s1, 8
	beq $s1, $0, positive
	addi $s2, $0, 16
	sub $s3, $s2, $a1
	nor $s3, $0, $s3
	addi $s3, $s3, 1
	addi $v0, $s3, 0
	positive:
	jr $ra
