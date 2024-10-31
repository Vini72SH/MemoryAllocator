.section .data
    topoInicialHeap: .quad 0
    ultimoBloco: .quad 0
    str1: .string "Iniciando o alocador de memoria.\n"
    str2: .string "Falha na alocacao!.\n"
    str3: .string "Finalizando o alocador de memoria.\n"

.section .note.GNU-stack,"",@progbits
.section .text
.globl main

iniciaAlocador:
    pushq %rbp          # Salva %rbp.
    movq %rsp, %rbp     # Altera o RA corrente.
    subq $8, %rsp       # Espaço para o ponteiro topo.

    # movq $str1, %rdi    # Carregamento da String.
    # call printf         # Chamada do printf.

    movq $12, %rax
    movq $0, %rdi       # Recebe o endereço do topo da pilha.
    syscall

    movq %rax, -8(%rbp)

    movq %rax, topoInicialHeap  # Armazena o topo nas variáveis globais.
    movq %rax, ultimoBloco

    addq $8, %rsp       # Fecha o espaço para o ponteiro.
    popq %rbp           # Restaura o antigo RA.
    ret                 # Retorna o fluxo do programa.

alocaMem:
    # i -> -8(%rbp)
    # melhorTamanho -> -16(%rbp)
    # topo -> -24(%rbp)
    # novoBloco -> -32(%rbp)
    # melhorBloco -> -40(%rbp)
    # valido -> -48(%rbp)
    # tamanhoBloco -> -56(%rbp)
    # basePointer -> -64(%rbp)
    # verificador -> -72(%rbp)

    pushq %rbp
    movq %rsp, %rbp
    subq $72, %rsp

    movq $0, %rax
    movq $0, %rbx
    movq $0, %rcx
    movq $0, %rdx
    movq $0, %rsi
    movq $0, %rdi
    movq $0, %r8
    movq $0, %r9
    movq $0, %r10
    movq $0, %r11
    movq $0, %r12
    movq $0, %r13
    movq $0, %r14
    movq $0, %r15

    movq $4096, -8(%rbp)    # i = 4096
    movq $0, %rdi
    movq $12, %rax
    syscall
    movq %rax, -24(%rbp)    # topo = sbrk(0)
    movq $0, -40(%rbp)      # melhorBloco = NULL
    movq topoInicialHeap, %rax
    movq %rax, -32(%rbp)
    movq -32(%rbp), %rax    # %rax = novoBloco
    movq ultimoBloco, %rbx  # %rbx = ultimoBloco

    while:
    cmpq %rax, %rbx         # novoBloco < ultimoBloco
    jge fim_while

    movq -32(%rbp), %rax    # %rax = novoBloco
    movq %rax, -48(%rbp)    # valido = novoBloco
    movq %rax, %rbx     
    addq $8, %rbx
    movq %rbx, -56(%rbp)    # tamanhoBloco = novoBloco + 8
    movq %rax, %rbx
    addq $16, %rbx
    movq %rbx, -64(%rbp)    # basePointer = novoBloco + 16    

    movq -48(%rbp), %r8     # %r8 = valido
    movq (%r8), %r9         # %r9 = *valido

    movq -56(%rbp), %r10    # %r10 = tamanhoBloco
    movq (%r10), %r11       # %r11 = *tamanhoBloco

    movq -40(%rbp), %r13    # %r13 = melhorBloco
    movq -16(%rbp), %r14    # %r14 = melhorTamanho

    cmpq $0, %r9    # (*valido) == 0
    jne fim_if1
    cmpq %r12, %r11 # (*tamanhoBloco) >= num_bytes
    jl fim_if2
    cmpq $0, %r13  # melhorBloco == NULL
    jne else_1
    movq %rax, %r13 # melhorBloco = novoBloco
    movq %r11, %r14 # melhorTamanho = *tamanhoBloco
    movq %r13, -40(%rbp)
    movq %r14, -16(%rbp)
    jmp fim_else  
    else_1:
    cmpq %r14, %r11 # (*tamanhoBloco) < melhorTamanho
    jge fim_if3
    movq %rax, %r13 # melhorBloco = novoBloco
    movq %r11, %r14 # melhorTamanho = *tamanhoBloco
    movq %r13, -40(%rbp)
    movq %r14, -16(%rbp)
    fim_if3:
    fim_else:
    fim_if2:
    fim_if1:
    movq -64(%rbp), %rbx    # %rbx = basePointer
    addq %r11, %rbx         # %rbx = basePointer + *tamanhoBloco
    movq %rbx, -32(%rbp)    # novoBloco = basePointer + *tamanhoBloco

    jmp while
    fim_while:

    movq -40(%rbp), %rax # %rax = melhorBloco
    # %rbx = valido
    # %rcx = tamanhoBloco
    # %rdx = basePointer
    cmpq $0, %rax           # melhorBloco != NULL
    je else_2
    movq %rax, %rbx         # valido = melhorBloco
    movq %rax, %rcx         # tamanhoBloco = melhorBloco
    addq $8, %rcx           # tamanhoBloco = melhorBloco + 8
    movq %rax, %rdx         # basePointer = melhorBloco
    addq $16, %rdx          # basePointer = melhorBloco + 16
    movq $1, (%rbx)         # (*valido) = 1
    movq %rbx, -48(%rbp)
    movq %rcx, -56(%rbp)
    movq %rdx, -64(%rbp)
    jmp fim_else2
    else_2:
    movq -32(%rbp), %rax    # %rax = novoBloco
    movq %rax, %rbx         # valido = novoBloco
    movq %rax, %rcx         # tamanhoBloco = novoBloco
    addq $8, %rcx           # tamanhoBloco = novoBloco + 8
    movq %rax, %rdx         # basePointer = novoBloco
    addq $16, %rdx          # basePointer = novoBloco + 16
    movq 16(%rbp), %r12     # %r12 = num_bytes
    movq -24(%rbp), %r15    # %r15 = topo
    movq %rdx, %r10         # %r10 = basePointer
    addq %r12, %r10         # %r10 = basePointer + num_bytes
    movq %rbx, -48(%rbp)
    movq %rcx, -56(%rbp)
    movq %rdx, -64(%rbp)
    cmpq %r15, %r10         # basePointer + num_bytes > topo 
    jle fim_if4
    movq -8(%rbp), %rdi     # %rdi = i
    while_2:
    cmpq %r12, %rdi         # i < num_bytes
    jge fim_while2
    shl $1, %rdi            # i = i << 1
    jmp while_2
    fim_while2:
    movq %rdi, -8(%rbp)     
    movq %rdi, %r8          # %r8 = i

    # %r14 = verificador
    movq -24(%rbp), %rdi    # %rdi = topo
    addq %r8, %rdi          # %rdi = topo + i    
    movq %rax, %r8          # %r8 = %rax
    movq $12, %rax          
    syscall                 # syscall brk

    movq %rax, %r14         # %verificador = %rax
    movq %r14, -72(%rbp)     
    movq %r8, %rax          # %rax = %r8
    cmpq $-1, %r14          # verificador == -1
    jne fim_if5
    movq $str2, %rdi        # Mensagem de erro.
    call printf
    movq $0, %rdi
    addq $72, %rsp          # Desaloca as variáveis locais.
    popq %rbp               # Restaura o antigo RA.
    ret                     # Retorna o fluxo do programa.
    fim_if5:
    fim_if4:
    movq -56(%rbp), %rcx
    movq $1, (%rbx)
    movq %r12, (%rcx)
    movq %r10, ultimoBloco
    fim_else2:
    movq -64(%rbp), %rax    # retorna o basePointer
    addq $72, %rsp          # Desaloca as variáveis locais.
    popq %rbp               # Restaura o antigo RA.
    ret                     # Retorna o fluxo do programa.

liberaMem:
    pushq %rbp          # Salva %rbp
    movq %rsp, %rbp     # Altera o RA corrente.
    subq $8, %rsp       # Espaço para a variável.

    movq 16(%rbp), %rax # (*bloco) mapeado em %rax
    cmpq $0, %rax       # Verificação se é válido.
    je else
    movq %rax, %rbx     
    subq $16, %rbx      # Armazena o endereço do metadado de validez;
    movq $0, (%rbx)     # Define que o bloco está livre.

    movq $1, %rbx       # Retorna 1, em sucesso.
    jmp exit
    
    else:
    movq $0, %rbx       # Retorna 0, em falha. (Bloco NULL)
    
    exit:
    addq $8, %rsp       # Fecha o espaço para o ponteiro.
    movq %rbx, %rax     # Define o valor de retorno da função.
    popq %rbp           # Restaura o antigo RA
    ret                 # Retorna o fluxo do programa.

finalizaAlocador:
    pushq %rbp          # Salva %rbp.
    movq %rsp, %rbp     # Altera o RA corrente.

    movq topoInicialHeap, %rax
    movq %rax, %rdi     # Restaura o valor original da Heap.
    movq $12, %rax      # Contido em topoInicialHeap.
    syscall

    # movq $str3, %rdi
    # call printf

    popq %rbp           # Restaura o antigo RA.
    ret                 # Retorna o fluxo do programa.

main:
    pushq %rbp
    movq %rsp, %rbp
    subq $8, %rsp

    call iniciaAlocador

    pushq $8
    call alocaMem
    addq $8, %rsp
    movq %rax, -8(%rbp)

    pushq %rax
    call liberaMem
    addq $8, %rsp

    call finalizaAlocador

    addq $8, %rsp
    movq $60, %rax
    syscall
