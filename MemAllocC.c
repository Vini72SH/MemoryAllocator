#include <stdio.h>
#include <unistd.h>

long int *topoInicialHeap;
long int *ultimoBloco;

// Função para depurar e imprimir o estado da memória
void debug_memory() {
    long int *current = topoInicialHeap; // Começa do topo inicial da heap
    long int *end = ultimoBloco; // Limite atual da heap

    printf("Estado da memória:\n");
    printf("Endereço inicial       |  Tamanho do bloco         |  Status\n");
    printf("-------------------------------------------------------------------\n");

    while (current < end) {
        // Verifica se o próximo bloco está dentro dos limites
        if (current + 1 >= end) {
            break;
        }

        long int tamanho_bloco = *(current + 1); // Tamanho do bloco
        int status = (*current == 0) ? 1 : 0; // Status do bloco: 1 = livre, 0 = ocupado

        printf("%8p         |  %8ld bytes           |  %s\n",
               (void*)current, tamanho_bloco, status ? "Livre" : "Ocupado");

        // Calcula o próximo bloco usando o tamanho atual e verifica se o avanço é seguro
        long int *next_block = (long int*)((char*)current + 2 * sizeof(long int) + tamanho_bloco);
        if (next_block >= end) {
            break;
        }
        current = next_block;
    }
    printf("\n");
}

/* 
 * Iniciação do Alocador Dinãmico.
 * Armazena o endereço inicial da Heap.
 */
void iniciaAlocador() {
    long int *topo;

    printf("Iniciando o alocador de memória.\n");
    topo = sbrk(0);
    topoInicialHeap = topo;
    ultimoBloco = topo;
};

/*
 * Finalização do Alocador.
 * Restaura a altura inicial da Heap.
 */
void finalizaAlocador() {
    long int *topo, diff;

    printf("Finalizando o alocador de memória.\n");

    topo = sbrk(0);
    diff = ((char *)topo - (char *)topoInicialHeap);
    sbrk(-diff);
};

int liberaMem(void *bloco) {
    char *valido;
    
    if (bloco != NULL) {
        valido = ((char *)bloco - 2 * sizeof(long int));
        *valido = 0;

        return 1;
    }

    return 0;
}

/*
 * Gerenciador de Alocações de Memória.
 * Verifica o tamanho da alocação.
 * Insere metadados referente aos blocos alocados.
 * Política: Best Fit.
 */
void *alocaMem(long int num_bytes) {
    
    int i, melhorTamanho, diff;
    long int *topo, *novoBloco, *melhorBloco, *saltPointer;
    long int *valido, *tamanhoBloco, *basePointer, *verificador;

    i = 4096;
    topo = sbrk(0);
    melhorTamanho = 0;
    melhorBloco = NULL;
    novoBloco = topoInicialHeap;
    while((char *)novoBloco < (char *)ultimoBloco) {
        valido = (long int *)novoBloco;
        tamanhoBloco = (long int *)((char *)novoBloco + sizeof(long int));
        basePointer = (long int *)((char *)novoBloco + 2 * sizeof(long int));

        if ((*valido) == 0) {
            if ((*tamanhoBloco) >= num_bytes) {
                if (melhorBloco == NULL) {
                    melhorBloco = novoBloco;
                    melhorTamanho = *tamanhoBloco;
                } else {
                    if ((*tamanhoBloco) < melhorTamanho) {
                        melhorBloco = novoBloco;
                        melhorTamanho = *tamanhoBloco;
                    }
                }
            }
        }

        novoBloco = (long int *)((char *)basePointer + *tamanhoBloco);
    }

    if (melhorBloco != NULL) {
        valido = (long int *)melhorBloco;
        tamanhoBloco = (long int *)((char *)melhorBloco + sizeof(long int));
        basePointer = (long int *)((char *)melhorBloco + 2 * sizeof(long int));
        (*valido) = 1;
        diff = ((*tamanhoBloco) - num_bytes - 2 * sizeof(long int));
        if (diff > (int)(2 * sizeof(long int))) {
            (*tamanhoBloco) = num_bytes;
            saltPointer = (long int *)((char *)basePointer + num_bytes);
            (*saltPointer) = 0;
            saltPointer = (long int *)((char *)saltPointer + sizeof(long int));
            (*saltPointer) = diff;
        }
    } else {
        valido = (long int *)novoBloco;
        tamanhoBloco = (long int *)((char *)novoBloco + sizeof(long int));
        basePointer = (long int *)((char *)novoBloco + 2 * sizeof(long int));

        if ((char *)basePointer + num_bytes > (char *)topo) {
            while (i < num_bytes) {
                i = i << 1;
            }

            verificador = sbrk(i);
            if (verificador == (long int *)-1) {
                printf("Falha na alocação!\n");
                return NULL;
            }
        }

        (*valido) = 1;
        (*tamanhoBloco) = num_bytes;
        ultimoBloco = (long int *)((char *)basePointer + num_bytes);
    }

    return basePointer; 
};

int main () {
    long int *x, *y, *z, *newTop;

    iniciaAlocador();
    printf("Topo da Heap: %p\n\n", topoInicialHeap);

    x = alocaMem(100);
    if (x != NULL) {
        *x = 5;
        //printf("[%p]: %ld\n", x, *x);
    }
    liberaMem(x);

    debug_memory();

    for (int i = 0; i < 10; i++) {
        x = alocaMem(sizeof(long int));
        if (x != NULL) {
            *x = 100;
            //printf("[%p]: %ld\n", x, *x);
        }

        y = alocaMem(sizeof(long int));
        if (y != NULL) {
            *y = 200;
            //printf("[%p]: %ld\n", y, *y);
        }

        z = alocaMem(sizeof(long int));
        if (z != NULL) {
            *z = 300;
            //printf("[%p]: %ld\n", z, *z);
        }

        liberaMem(x);
        liberaMem(y);
        liberaMem(z);
    }
 
    debug_memory();

    newTop = sbrk(0);
    //printf("Diferença em Bytes: %ld\n", (char *)newTop - (char *)topoInicialHeap);
    finalizaAlocador();

    return 0;
}