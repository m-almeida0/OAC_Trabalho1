	.text
	.globl validate_and_preprocess_hexadecimal
	
# Valida uma string contendo caracteres hexadecimais e remove o terminador de linha 
# se ele existir. Ao final, informa se é ou não válida quanto à base hexadecimal e, 
# em caso positivo, retorna também o comprimento efetivo dela.
#
# Parâmetros: 
#	- $a0: endereço do primeiro byte da string
#	- $ra: endereço de retorno para o local de chamada
# Retorno: 
#	- $v0: comprimento efetivo da string informada
#	- $v1: booleano: 1 se a string for consistente em relação à base, 0 se não
validate_and_preprocess_hexadecimal:
	
	# Registro que calculará o tamanho da string
	move $s0, $zero
	
	# Inicia assumindo a string como válida
	li $v1, 1
	
	validate_and_preprocess_hexadecimal_start_loop:

		# Acessa o caractere atual e o verifica
		lb $t0, 0 ($a0)
		beq $t0, $zero, validate_and_preprocess_hexadecimal_exit_loop
		beq $t0, '\n', validate_and_preprocess_hexadecimal_cut_endline
		blt $t0, '0', validate_and_preprocess_hexadecimal_invalidation
		bgt $t0, '9', validate_and_preprocess_hexadecimal_check_letters
		
		# Avança na leitura
		addi $a0, $a0, 1
		addi $s0, $s0, 1
		
		# Volta para o início do laço
		j validate_and_preprocess_hexadecimal_start_loop
		
		# Verifica a validade do caractere quanto às letras [a, f] U [A, F]
		# Obs: em ASCII, A (65) < a (97)
		validate_and_preprocess_hexadecimal_check_letters:
			blt $t0, 'A', validate_and_preprocess_hexadecimal_invalidation
			bgt $t0, 'f', validate_and_preprocess_hexadecimal_invalidation
			bgt $t0, 'F', validate_and_preprocess_hexadecimal_check_letters_aux
			addi $a0, $a0, 1
			addi $s0, $s0, 1
			j validate_and_preprocess_hexadecimal_start_loop
			
		validate_and_preprocess_hexadecimal_check_letters_aux:
			blt $t0, 'a', validate_and_preprocess_hexadecimal_invalidation
			addi $a0, $a0, 1
			addi $s0, $s0, 1
			j validate_and_preprocess_hexadecimal_start_loop	
		
		# Aplica a invalidação da string se necessário
		validate_and_preprocess_hexadecimal_invalidation:
			li $v1, 0
			li $s0, 0
			j validate_and_preprocess_hexadecimal_exit_loop
		
		# Remoção do caractere terminador de linha
		validate_and_preprocess_hexadecimal_cut_endline:
			li $t0, 0
			sb $t0, 0 ($a0)
	
	validate_and_preprocess_hexadecimal_exit_loop:
	
	# Retorno
	move $v0, $s0
	jr $ra
