	.data
	.align 0
numero: .asciiz "00000000000000000000000000000000"

	.text
	.globl imprimir_inteiro_na_base

#$a0 deve conter o número a ser convertido, em decimal, e $a1 é a base para a qual ele deve ser convertido,
#quando a função for chamada.
imprimir_inteiro_na_base:
	
	addi $sp, $sp, -8
	sw $a0, 0 ($sp)
	sw $a1, 4 ($sp)

	addu $t0, $a0, $0#t0 é o número a ser convertido
	add $t1, $a1, $0#t1 é a base à qual esse valor deve ser convertido
	li $t2, 10#t2 é 10, pra ser usado num if mais pra frente
	la $t3, numero#t3 é o endereço da string na qual o novo número vai ser impresso
	addi $t3, $t3, 31#e ela é contada a partir do seu último caractere

	loopResto:
		div $t0, $t1
		mflo $t0#t0 = t0/t1
		mfhi $t4#t4 = t0%t1

		blt $t4, $t2, menor10#if resto < 10, pular essa parte. Alternativamente, entrar if resto > 10
		addi $t4, $t4, 87#t4 = 'a'-10+resto
		j fimMaior10
	menor10:
		addi $t4, $t4, 48
	fimMaior10:

		sb $t4, 0($t3)#salva t4 no último byte da string
		addi $t3, $t3, -1#decrementa o endereço da string

		bgtz $t0, loopResto
	fimLoop:
	
	addi $t3, $t3, 1#n loop de saida, e decrementado 1 de t3, o que faz com que o endereço armazenado seja uma unidade anterior a desejada

	addu $s0, $t3, $0#armazena o endereco da string em s0
	#parte de impressao de teste
	add $a0, $0, $t3
	li $v0, 4
	syscall

	lw $a1, 4 ($sp)
	lw $a0, 0 ($sp)
	addi $sp, $sp, 8

	jr $ra
