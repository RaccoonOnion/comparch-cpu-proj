.data 

.text 
control:
lw $1, 0xAC60($0)   #which case
addi $2, $0, 0
beq $1, $2, case1
addi $2, $0, 1
beq $1, $2, case2
addi $2, $0, 2
beq $1, $2, case3
addi $2, $0, 3
beq $1, $2, case4
addi $2, $0, 4
beq $1, $2, case5
addi $2, $0, 5
beq $1, $2, case6
addi $2, $0, 6
beq $1, $2, case7
addi $2, $0, 7
beq $1, $2, case8
j control

case1:
	lw $3, 0x8C60($0)  #a
	addi $4, $3, -1
	and $5, $3, $4
	sw $3, 0xBC70($0) # show a
	bne $5, $0, control
	addi $6, $0, 1
	sw $6, 0xDC70($0) #light
	j control
case2:
	lw $3, 0x8C60($0)  #a
	andi $4, $3, 1
	sw $3, 0xBC70($0) # show a
	beq $4, $0, control
	addi $6, $0, 1
	sw $6, 0xC70($0)  #light
	j control
case3:
	or $12, $10, $11
	sw $12, 0xDC70($0) #show
	j control
case4:
	nor $12, $10, $11
	sw $12, 0xDC70($0) #show
	j control
case5:
	xor $12, $10, $11
	sw $12, 0xDC70($0) #show
	j control
case6:
	add $a1, $0, $10
	jal signTurn
	add $10, $0, $v0
	add $a1, $0, $11
	jal signTurn
	add $11, $0, $v0
	slt $12, $10, $11
	sw $12, 0xDC70($0) #show
	j control
case7:	
	sltu $12, $10, $11
	sw $12, 0xDC70($0) #show
	j control
case8:
	lw $10, 0x8C60($0)  #a
	lw $11, 0x9C60($0)  #b
	sll $12, $11, 4
	add $12, $12, $10
	sw $12, 0xEC70($0)  #show a and b
	j control

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