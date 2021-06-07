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
	# Calculará o inteiro
	li $s0, 0
	
	# Verifica o comprimento (se > 10, então é inválida: número máximo = 4,294,967,295)
	bge $a1, 10, atoui_exit_loop
	
	# Posiciona-se ao final da string
	add $a0, $a0, $a1
	addi $a0, $a0, -1
	
	# Farão a adaptação decimal
	li $s1, 1
	li $s2, 10
	
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
	
	atoui_exit_loop:
	
	# Retorno
	move $v0, $s0
	jr $ra