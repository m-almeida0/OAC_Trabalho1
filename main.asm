	.data
	.align 0

# Strings de entrada
wellcomeMessage:	.asciiz "Wellcome to Base Converter.\nWhen a base is requested, consider \'B\', \'D\' and \'H\' as binary, decimal and hexadecimal bases respectively."
inputBaseRequest:	.asciiz "\nEnter input base: "
inputBinNumRequest:	.asciiz "\nEnter binary number: "
inputDecNumRequest:	.asciiz "\nEnter decimal number: "
inputHexNumRequest:	.asciiz "\nEnter hexadecimal number: "
outputBaseRequest:      .asciiz "\nEnter output base: "

# Strings de saída
outputNumMessage:	.asciiz "\nYour final number is: "
invalidBaseMessage:	.asciiz "\nInformed base is invalid."

	.text
	.globl main

# Procedimento principal
main:
	# Impressão da mensagem inicial
	li $v0, 4
	la $a0, wellcomeMessage
	syscall
	
	# Impressão da solicitação de base de entrada
	li $v0, 4
	la $a0, inputBaseRequest
	syscall
	
	# Lê a base de entrada e a empilha
	addi $sp, $sp, -2
	li $v0, 8
	la $a0, 0 ($sp)
	li $a1, 2
	syscall
	
	# Recupera o primeiro caractere da string e a desempilha
	lb $t0, 0 ($sp)
	addi $sp, $sp, 2
	
	# Chaveia em relação à base selecionada
	beq $t0, 'B', bin_input_base
	beq $t0, 'D', dec_input_base
	beq $t0, 'H', hex_input_base
	j invalid_base_exception
	
	# Base de entrada binária
	bin_input_base:
	
		# Impressão da mensagem de inserção do número
		li $v0, 4
		la $a0, inputBinNumRequest
		syscall
		
		# Leitura da string binária
		addi $sp, $sp, -33
		li $v0, 8
		la $a0, 33 ($sp)
		li $a1, 33
		syscall
		
		# Cálculo do tamanho efetivo da string binária e remoção do terminador de linha se ele existir
		la $a0, 33 ($sp)
		jal get_strlen_and_cut_endline
		
		# Gera o decimal intermediário
		la $a0, 33 ($sp)
		move $a1, $v0
		jal TODO
		move $t0, $v0
		
		# Desempilha a string e empilha o decimal intermediário
		addi $sp, $sp, 33
		addi $sp, $sp, -4
		sw $t0, 0 ($sp)
		
		j main_output_base_select
	
	# Base de entrada decimal
	dec_input_base:
	
		# Impressão da mensagem de inserção do número
		li $v0, 4
		la $a0, inputDecNumRequest
		syscall
		
		# Obtenção e empilhamento do decimal de entrada
		addi $sp, $sp, -4
		li $v0, 5
		syscall
		sw $v0, 0 ($sp)
	
		j main_output_base_select
	
	# Base de entrada hexadecimal
	hex_input_base:
	
		# Impressão da mensagem de inserção do número
		li $v0, 4
		la $a0, inputHexNumRequest
		syscall
		
		# Leitura da string hexadecimal
		addi $sp, $sp, -9
		li $v0, 8
		la $a0, 9 ($sp)
		li $a1, 9
		syscall
		
		# Cálculo do tamanho efetivo da string binária e remoção do terminador de linha se ele existir
		la $a0, 9 ($sp)
		jal get_strlen_and_cut_endline
		
		# Gera o decimal intermediário
		la $a0, 9 ($sp)
		move $a1, $v0
		jal TODO
		move $t0, $v0
		
		# Desempilha a string e empilha o decimal intermediário
		addi $sp, $sp, 9
		addi $sp, $sp, -4
		sw $t0, 0 ($sp)
		
		j main_output_base_select
	
	# Seleção da base de saída
	main_output_base_select:
	
		# Impressão da mensagem de solicitação
		li $v0, 4
		la $a0, outputBaseRequest
		syscall
		
		# Lê a base de saída e a empilha
		addi $sp, $sp, -2
		li $v0, 8
		la $a0, 0 ($sp)
		li $a1, 2
		syscall
	
		# Recupera o primeiro caractere da string e a desempilha
		lb $t0, 0 ($sp)
		addi $sp, $sp, 2
		
		# Impressão da mensagem final
		li $v0, 4
		la $a0, outputNumMessage
		syscall
		
		# Chaveia em relação à base selecionada
		beq $t0, 'B', bin_output_base
		beq $t0, 'D', dec_output_base
		beq $t0, 'H', hex_output_base
		j invalid_base_exception
	
	# Base de saída binária
	bin_output_base:
		lw $a0, 0 ($sp)
		li $a1, 2
		jal TODO2
		j main_exit
	
	# Base de saída decimal
	dec_output_base:
		li $v0, 1
		lw $a0, 0 ($sp)
		syscall
		j main_exit
	
	# Base de saída hexadecimal
	hex_output_base:
		lw $a0, 0 ($sp)
		li $a1, 16
		jal TODO2
		j main_exit
		
	# Exceção de base inválida
	invalid_base_exception:
		li $v0, 4
		la $a0, invalidBaseMessage
		syscall
		li $v0, 10
		syscall
	
	# Saída do procedimento principal
	main_exit:
		addi $sp, $sp, 4
		li $v0, 10
		syscall


# Calcula o tamanho de uma string e remove o terminador de linha se ele existir
# Parâmetros: 
#	- $a0: endereço do primeiro byte da string
#	- $ra: endereço de retorno para o local de chamada
# Retorno: 
#	- $v0: comprimento efetivo da string informada
get_strlen_and_cut_endline:
	
	# Registro que calculará o tamanho da string
	move $s0, $zero
	
	# Usado para verificar final de linha
	li $s1, '\n'
	
	strlen_start_loop:

		# Acessa o caractere atual e o verifica
		lb $t0, 0 ($a0)
		beq $t0, $zero, strlen_exit_loop
		beq $t0, $s1, strlen_cut_endline
		
		# Avança na leitura
		addi $a0, $a0, 1
		addi $s0, $s0, 1
		
		# Volta para o início do laço
		j strlen_start_loop
		
		# Remoção do caractere terminador de linha
		strlen_cut_endline:
			li $t0, 0
			sb $t0, 0 ($a0)
	
	strlen_exit_loop:
	
	# Retorno
	move $v0, $s0
	jr $ra


# CONVERSÃO PARA DECIMAL INTERMEDIÁRIO
TODO:
	li $v0, 100
	jr $ra
	
# IMPRESSÃO NA BASE SOLICITADA
TODO2:
	li $v0, 1
	li $a0, 99999
	syscall
	jr $ra
