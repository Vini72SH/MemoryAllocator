.section .data
    topoInicialHeap: .quad 0
    ultimoBloco: .quad 0
    str1: .string "Iniciando o alocador de memoria.\n"
    str2: .string "Falha na alocacao!.\n"
    str3: .string "Finalizando o alocador de memoria.\n"
    strHashtag: .string "#"
    strMais: .string "+"
    strMenos: .string "-"
    strDoubleBreak: .string "\n\n"

.section .note.GNU-stack,"",@progbits
.section .text
.globl iniciaAlocador
.globl alocaMem
.globl liberaMem
.globl finalizaAlocador
.globl imprimeMapa

iniciaAlocador:
    pushq %rbp          # Salva %rbp.
    movq %rsp, %rbp     # Altera o RA corrente.
    subq $8, %rsp       # Espaço para o ponteiro topo.

    movq $str1, %rdi    # Carregamento da String.
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
    # diff -> -80(%rbp)
    # num_bytes -> -88(%rbp)

    pushq %rbp
    movq %rsp, %rbp
    subq $88, %rsp

    movq %rdi, -88(%rbp)
    movq %rdi, %rax
    cmpq $0, %rax
    jg tamanho_valido   # Se num_bytes >= 1, o tamanho do bloco é válido
    movq $0, %rax
    addq $88, %rsp
    popq %rbp
    ret

    tamanho_valido:
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

    # %rax = novoBloco
    # %rbx = ultimoBloco
    # %r13 = valido
    # %r14 = tamanhoBloco
    # %r15 = basePointer 
    while:
    cmpq %rbx, %rax         # novoBloco < ultimoBloco
    jge fim_while
    movq %rax, %r13         # valido = novoBloco
    movq %rax, %r14 
    addq $8, %r14           # tamanhoBloco = novoBloco + 8
    movq %rax, %r15
    addq $16, %r15          # basePointer = novoBloco + 16
    
    cmpq $0, (%r13)         # *valido == 0
    jne foraIfValido
    movq -88(%rbp), %r12    
    cmpq %r12, (%r14)       # (*tamanhoBloco) >= num_bytes
    jl foraIfTamNum
    movq -40(%rbp), %r12
    cmpq $0, %r12           # melhorBloco == NULL
    jne elseMelhorBloco
    movq %rax, -40(%rbp)    # Se melhorBloco não existe, salva o bloco atual
    movq (%r14), %r12
    movq %r12, -16(%rbp)    # Salva o tamanho do bloco atual
    jmp foraIfTamNum
    elseMelhorBloco:
    movq (%r14), %r12
    movq -16(%rbp), %rcx
    cmpq %r12, %rcx         # (*tamanhoBloco) < melhorTamanho
    jge foraIfBlocoTam
    movq %rax, -40(%rbp)    # Se o bloco atual é melhor, o salva no lugar   
    movq %r12, -16(%rbp)
    foraIfBlocoTam:
    foraIfTamNum:
    foraIfValido:

    movq (%r14), %r12
    movq %r15, %rax
    addq %r12, %rax
    movq %rax, -32(%rbp)

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
    movq (%rcx), %rax       # %rax = *tamanhoBloco
    movq -88(%rbp), %rbx     # %rbx = num_bytes
    subq %rbx, %rax         # %rax = *tamanhoBloco - num_bytes
    subq $16, %rax          # %rax = *tamanhoBloco - num_bytes - 16
    movq %rax, -80(%rbp)
    cmpq $16, %rax          # diff > 2 * sizeof(long int)
    jle fim_else2

    movq -56(%rbp), %rcx    # %rcx = tamanhoBloco
    movq %rbx, (%rcx)       # (*tamanhoBloco) = num_bytes
    movq -64(%rbp), %rax    # %rax = basePointer
    addq %rbx, %rax         # %rax = basePointer + num_bytes
    movq $0, (%rax)         # (*proxBlocoValido) = 0
    addq $8, %rax
    movq -80(%rbp), %rbx
    movq %rbx, (%rax)       # (*proxBlocoTamanho) = diff

    jmp fim_else2
    else_2:
    movq -32(%rbp), %rax    # %rax = novoBloco
    movq %rax, %rbx         # valido = novoBloco
    movq %rax, %rcx         # tamanhoBloco = novoBloco
    addq $8, %rcx           # tamanhoBloco = novoBloco + 8
    movq %rax, %rdx         # basePointer = novoBloco
    addq $16, %rdx          # basePointer = novoBloco + 16
    movq -88(%rbp), %r12     # %r12 = num_bytes
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
    addq $88, %rsp          # Desaloca as variáveis locais.
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
    addq $88, %rsp          # Desaloca as variáveis locais.
    popq %rbp               # Restaura o antigo RA.
    ret                     # Retorna o fluxo do programa.

liberaMem:
    pushq %rbp          # Salva %rbp
    movq %rsp, %rbp     # Altera o RA corrente.
    subq $8, %rsp       # Espaço para a variável.

    movq %rdi, %rax     # (*bloco) mapeado em %rax
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

    movq $str3, %rdi
    # call printf

    popq %rbp           # Restaura o antigo RA.
    ret                 # Retorna o fluxo do programa.

imprimeMapa:
    # *novoBloco -> %rax
    # *ultimoBloco -> %rbx
    #  tam -> %r12
    # *valido -> %r13
    # *tamanhoBloco -> %r14
    # *basePointer -> %r15

    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp

    movq topoInicialHeap, %rax
    movq ultimoBloco, %rbx

    whileImprime:
    cmpq %rbx, %rax
    jge fora_whileImprime
    movq %rax, %r13         # Valido
    movq %rax, %r14
    addq $8, %r14           # tamanhoBloco = novoBloco + 8
    movq %rax, %r15
    addq $16, %r15          # basePointer = novoBloco + 16
    movq %r15, -8(%rbp)
    movq $0, %r8

    forTags:
    cmpq $16, %r8           # i < 16
    jge fora_forTags
    movq $strHashtag, %rdi  # Imprime "#"
    call printf
    addq $1, %r8
    jmp forTags
    fora_forTags:

    movq (%r14), %r12      # tam = *tamanhoBloco
    movq (%r13), %rdx      # %rdx = *valido
    cmpq $1, %rdx          # %rdx == 1 // Imprime "+" ou "-"
    jne elseImprime
    movq $strMais, %r15
    jmp fora_elseImprime
    elseImprime:
    movq $strMenos, %r15
    fora_elseImprime:

    movq $0, %r8           # %r8 = 0
    forChar:
    cmpq %r12, %r8         # %r8 < *tamanhoBloco
    jge fora_forChar
    movq %r15, %rdi
    call printf            # Imprime as informações
    addq $1, %r8
    jmp forChar
    fora_forChar:

    movq -8(%rbp), %r15    # Restaura o basePointer

    movq %r15, %rax        # Salta para o próximo bloco
    addq %r12, %rax

    jmp whileImprime
    fora_whileImprime:

    movq $strDoubleBreak, %rdi  # Imprime "\n\n"
    call printf

    addq $16, %rsp
    popq %rbp
    ret
