	.data
	.align 0

# Strings de entrada
wellcomeMessage:	.asciiz "Wellcome to 32b Base Converter.\nWhen a base is requested, consider \'B\', \'D\' and \'H\' as binary, decimal and hexadecimal bases respectively.\n"
inputBaseRequest:	.asciiz "Enter input base: "
inputNumRequest:	.asciiz "Enter number: "
outputBaseRequest:      .asciiz "Enter output base: "

# Strings de saída
outputNumMessage:	.asciiz "Your final number is: "
invalidBaseMessage:	.asciiz "Informed base is invalid."
invalidNumMessage:	.asciiz "Informed number is invalid for the requested base."
tooBigNumMessage:	.asciiz "Informed number is too big for the requested base."

	.align 2
	
# Tamanho máximo de leitura
chunkSize:		.word 64

	.text
	.globl main

# Procedimento principal
main:
	# Preparação da pilha para as variáveis utilizadas pela main: 
	# 2 strings de tamanho fixo = "chunkSize" + 1 palavra
	lw $t0, chunkSize
	mul $t0, $t0, -2
	addi $t0, $t0, -4
	add $sp, $sp, $t0

	# Impressão da mensagem inicial
	li $v0, 4
	la $a0, wellcomeMessage
	syscall
	
	# Impressão da solicitação de base de entrada
	li $v0, 4
	la $a0, inputBaseRequest
	syscall
	
	# Obtém o deslocamento de inserção da string da base
	lw $t0, chunkSize
	mul $t0, $t0, 2
	addi $t0, $t0, 4
	
	# Lê a base de entrada
	li $v0, 8
	add $a0, $t0, $sp
	lw $a1, chunkSize
	syscall
		
	# Salva o caractere em $s0
	lb $s0, ($a0)
	
	# Valida a base de entrada
	beq $s0, 'B', main_select_bin_input
	beq $s0, 'D', main_select_dec_input
	beq $s0, 'H', main_select_hex_input
	j invalid_base_exception
	
	# Seleção do rótulo a seguir para a base de entrada
	main_select_bin_input:
		la $s0, bin_input_base
		j main_exit_input_selection
	main_select_dec_input:
		la $s0, dec_input_base
		j main_exit_input_selection
	main_select_hex_input:
		la $s0, hex_input_base
	main_exit_input_selection:
	
	# Requisita a inserção do número
	li $v0, 4
	la $a0, inputNumRequest
	syscall
	
	# Obtém o deslocamento de inserção da string numérica
	lw $t0, chunkSize
	addi $t0, $t0, 4
	
	# Obtém a string do número
	li $v0, 8
	add $a0, $t0, $sp
	lw $a1, chunkSize
	syscall
	
	# Chaveia em relação à base selecionada
	jr $s0
	
	# Base de entrada binária
	bin_input_base:
	
		# Pré-processamento da string
		lw $t0, chunkSize
		addi $t0, $t0, 4
		add $a0, $t0, $sp
		jal validate_and_preprocess_binary
		move $t0, $v0
		
		# Validação de formato
		bgt $t0, 0, main_start_bin_len_val
		j invalid_number_exception
		
		# Validação de tamanho
		main_start_bin_len_val:
			blt $t0, 33, main_exit_bin_len_val
			j too_big_number_exception
		main_exit_bin_len_val:
		
		# Gera o decimal intermediário e o empilha
		lw $t1, chunkSize
		addi $t1, $t1, 4
		add $a0, $t1, $sp
		move $a1, $t0
		jal TODO
		sw $v0, 0 ($sp)
		
		j main_output_base_select
	
	# Base de entrada decimal
	dec_input_base:
	
		# Pré-processamento da string
		lw $t0, chunkSize
		addi $t0, $t0, 4
		add $a0, $t0, $sp
		jal validate_and_preprocess_decimal
		move $t0, $v0
	
		# Validação de formato
		bgt $t0, 0, main_start_dec_len_val
		j invalid_number_exception
		
		# Validação de tamanho e geração do número correspondente
		main_start_dec_len_val:
				
			# Seleção da posição da string numérica
			lw $t1, chunkSize
			addi $t1, $t1, 4
			
			# Geração, verificação e empilhamento do número
			add $a0, $t1, $sp
			move $a1, $t0
			jal atoui
			sw $v0, 0 ($sp)
			
			j main_output_base_select
	
	# Base de entrada hexadecimal
	hex_input_base:
		
		# Pré-processamento da string
		lw $t0, chunkSize
		addi $t0, $t0, 4
		add $a0, $t0, $sp
		jal validate_and_preprocess_hexadecimal
		move $t0, $v0
		move $t1, $v1
		
		# Validação de formato
		bgt $t0, 0, main_start_hex_len_val
		j invalid_number_exception
		
		# Validação de tamanho
		main_start_hex_len_val:
			blt $t0, 9, main_exit_hex_len_val
			j too_big_number_exception
		main_exit_hex_len_val:
		
		# Gera o decimal intermediário e o empilha
		lw $t1, chunkSize
		addi $t1, $t1, 4
		add $a0, $t1, $sp
		move $a1, $t0
		jal TODO
		sw $v0, 0 ($sp)
	
	# Seleção da base de saída
	main_output_base_select:
	
		# Impressão da mensagem de solicitação
		li $v0, 4
		la $a0, outputBaseRequest
		syscall
		
		# Obtém o deslocamento de inserção da string da base
		lw $t0, chunkSize
		mul $t0, $t0, 2
		addi $t0, $t0, 4
		
		# Lê a base de saída
		li $v0, 8
		add $a0, $t0, $sp
		lw $a1, chunkSize
		syscall
		
		# Salva o caractere em $s0
		lb $s0, ($a0)
	
		# Impressão da mensagem final
		li $v0, 4
		la $a0, outputNumMessage
		syscall
		
		# Chaveia em relação à base selecionada
		beq $s0, 'B', bin_output_base
		beq $s0, 'D', dec_output_base
		beq $s0, 'H', hex_output_base
		j invalid_base_exception
	
	# Base de saída binária
	bin_output_base:
		lw $a0, 0 ($sp)
		li $a1, 2
		jal imprimir_inteiro_na_base
		j main_exit
	
	# Base de saída decimal
	dec_output_base:
		li $v0, 36
		lw $a0, 0 ($sp)
		syscall
		j main_exit
	
	# Base de saída hexadecimal
	hex_output_base:
		lw $a0, 0 ($sp)
		li $a1, 16
		jal imprimir_inteiro_na_base
		j main_exit
		
	# Exceção de base inválida
	invalid_base_exception:
		li $v0, 4
		la $a0, invalidBaseMessage
		syscall
		j main_exit
		
	# Exceção de número com formatação inválida
	invalid_number_exception:
		li $v0, 4
		la $a0, invalidNumMessage
		syscall
		j main_exit
	
	# Exceção de número com tamanho inválido
	too_big_number_exception:
		li $v0, 4
		la $a0, tooBigNumMessage
		syscall
		j main_exit
	
	# Saída do procedimento principal
	main_exit:
		lw $t0, chunkSize
		mul $t0, $t0, 2
		addi $t0, $t0, 4
		add $sp, $sp, $t0
		li $v0, 10
		syscall


# CONVERSÃO PARA DECIMAL INTERMEDIÁRIO
TODO:
	li $v0, 100
	jr $ra
