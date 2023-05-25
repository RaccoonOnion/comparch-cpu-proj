.data 

.text 
control:
lw $1, 0xC60($0)   #which case
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
	lw $3, 0xC60($0)  #a
	addi $4, $3, -1
	and $5, $3, $4
	bne $5, $0, control
	addi $6, $0, 1
	sw $6, 0xC70($0) #light
	j control
case2:
	lw $3, 0xC60($0)  #a
	andi $4, $3, 1
	beq $4, $0, control
	addi $6, $0, 1
	sw $6, 0xC70($0)  #light
	j control
case3:
	or $12, $10, $11
	sw $12, 0xC70($0) #show
	j control
case4:
	nor $12, $10, $11
	sw $12, 0xC70($0) #show
	j control
case5:
	xor $12, $10, $11
	sw $12, 0xC70($0) #show
	j control
case6:
	slt $12, $10, $11
	sw $12, 0xC70($0) #show
	j control
case7:	
	sltu $12, $10, $11
	sw $12, 0xC70($0) #show
	j control
case8:
	lw $10, 0xC60($0)  #a
	lw $11, 0xC60($0)  #b
	sw $10, 0xC70($0)  #show a
	sw $11, 0xC70($0)  #show b
	j control
