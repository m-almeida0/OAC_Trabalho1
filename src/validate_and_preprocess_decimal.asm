	.text
	.globl validate_and_preprocess_decimal
	
# Valida uma string contendo caracteres decimais e remove o terminador de linha 
# se ele existir. Todavia, se a string informada for inválida em relação à base 
# decimal, retornará 0 como comprimento.
#
# Parâmetros: 
#	- $a0: endereço do primeiro byte da string
#	- $ra: endereço de retorno para o local de chamada
# Retorno: 
#	- $v0: comprimento efetivo da string ou 0 se ela for inválida
validate_and_preprocess_decimal:
	
	# Registro que calculará o tamanho da string
	move $s0, $zero
	
	validate_and_preprocess_decimal_start_loop:

		# Acessa o caractere atual e o verifica
		lb $t0, 0 ($a0)
		beq $t0, $zero, validate_and_preprocess_decimal_exit_loop
		beq $t0, '\n', validate_and_preprocess_decimal_cut_endline
		blt $t0, '0', validate_and_preprocess_decimal_invalidation
		bgt $t0, '9', validate_and_preprocess_decimal_invalidation
		
		# Avança na leitura
		addi $a0, $a0, 1
		addi $s0, $s0, 1
		
		# Volta para o início do laço
		j validate_and_preprocess_decimal_start_loop
			
		# Aplica a invalidação da string se necessário
		validate_and_preprocess_decimal_invalidation:
			li $s0, 0
			j validate_and_preprocess_decimal_exit_loop
		
		# Remoção do caractere terminador de linha
		validate_and_preprocess_decimal_cut_endline:
			li $t0, 0
			sb $t0, 0 ($a0)
	
	validate_and_preprocess_decimal_exit_loop:
	
	# Retorno
	move $v0, $s0
	jr $ra
