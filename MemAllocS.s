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

    movq $str1, %rdi    # Carregamento da String.
    call printf         # Chamada do printf.

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
    movq $12, %rax
    movq $0, %rdi
    syscall
    movq %rax, -24(%rbp)    # topo = sbrk(0)
    movq $0, -40(%rbp)      # melhorBloco = NULL
    movq topoInicialHeap, %rax
    movq %rax, -32(%rbp)
    movq -32(%rbp), %rax    # %rax = novoBloco
    movq ultimoBloco, %rbx  # %rbx = ultimoBloco
    movq 16(%rbp), %r12     # %r12 = num_bytes

    addq $72, %rsp
    popq %rbp
    ret


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

    movq $str3, %rdi
    call printf

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

    movq $0, %rax
    pushq %rax
    call liberaMem
    addq $8, %rsp

    call finalizaAlocador

    addq $8, %rsp
    movq $60, %rax
    syscall
