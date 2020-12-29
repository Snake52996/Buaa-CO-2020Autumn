.data
	stack:.space 10000
	space:.asciiz " "
	nl:.asciiz "\n"
.text
	la $s0,stack
	li $v0,5
	syscall
	add $s1,$zero,$v0	# n
	li $v0,5
	syscall
	add $s2,$zero,$v0	# m
	li $t0,1	# i
	li $t1,1	# j
	loop:
	li $v0,5
	syscall
	bnez $v0,save
	updatej:
	addi $t1,$t1,1
	bgt $t1,$s2,updatei
	j loop
	updatei:
	li $t1,1
	addi $t0,$t0,1
	bgt $t0,$s1,endloop
	j loop
	save:
	addi $s0,$s0,12
	sw $t0,-12($s0)
	sw $t1,-8($s0)
	sw $v0,-4($s0)
	j updatej
	endloop:
	la $s1,stack
	print:
	beq $s0,$s1,end
	addi $s0,$s0,-12
	lw $a0,0($s0)
	li $v0,1
	syscall
	li $v0,4
	la $a0,space
	syscall
	lw $a0,4($s0)
	li $v0,1
	syscall
	li $v0,4
	la $a0,space
	syscall
	lw $a0,8($s0)
	li $v0,1
	syscall
	li $v0,4
	la $a0,nl
	syscall
	j print
	end:
	li $v0,10
	syscall