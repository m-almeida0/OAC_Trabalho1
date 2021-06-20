	.data
	.align 0

# Inteiro sem sinal máximo para palavras de 32 bits
MAX_UNSIGNED_INTEGER_WORD: .asciiz "4294967295"

	.text
	.globl atoui
	
# Obtém um inteiro sem sinal de uma string em codificação ASCII e pré-validada.
#
# Parâmetros: 
#	- $a0: endereço do primeiro byte da string
#	- $a1: comprimento efetivo da string
#	- $ra: endereço de retorno para o local de chamada
# Retorno: 
#	- $v0: inteiro de saída. Retornará 0 se não suportar o tamanho do inteiro representado
atoui:
	# Verifica o comprimento (se > 10, então é inválida: número máximo = 4,294,967,295)
	bgt $a1, 10, max_atoui_invalidation
	
	# Posiciona-se ao final da string
	add $a0, $a0, $a1
	addi $a0, $a0, -1
	
	# Calculará o inteiro
	li $s0, 0
	
	# Farão a adaptação decimal
	li $s1, 1
	li $s2, 10
	
	# Caso de verificação do inteiro máximo
	beq $a1, 10, max_atoui
	
	atoui_start_loop:
	
		# Verifica a permanência na string
		beq $a1, $zero, atoui_exit_loop
	
		# Acessa o caractere atual
		lb $t0, 0 ($a0)
		
		# Cálculo
		addi $t0, $t0, -48
		mul $t0, $t0, $s1
		mul $s1, $s1, $s2
		add $s0, $s0, $t0
		
		# Avança na leitura
		addi $a0, $a0, -1
		addi $a1, $a1, -1
		
		# Volta para o início do laço
		j atoui_start_loop
	
	max_atoui:
		# Carrega o endereço do último caractere efetivo da string constante
		la $s3, MAX_UNSIGNED_INTEGER_WORD + 9		
	
	max_atoui_start_loop:
	
		# Verifica a permanência na string
		beq $a1, $zero, atoui_exit_loop

		# Acessa caractere atual de ambas as strings e as compara
		lb $t0, 0 ($a0)
		lb $t1, 0 ($s3)
		bgt $t0, $t1, max_atoui_invalidation
		
		# Cálculo
		addi $t0, $t0, -48
		mul $t0, $t0, $s1
		mul $s1, $s1, $s2
		add $s0, $s0, $t0
		
		# Avança na leitura
		addi $a0, $a0, -1
		addi $a1, $a1, -1
		addi $s3, $s3, -1
		
		# Volta para o início do laço
		j atoui_start_loop
	
	max_atoui_invalidation:
		li $s0, 0
	
	atoui_exit_loop:
	
	# Retorno
	move $v0, $s0
	jr $ra
