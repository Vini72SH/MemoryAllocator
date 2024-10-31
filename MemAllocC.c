#include <stdio.h>
#include <unistd.h>

long int *topoInicialHeap;
long int *ultimoBloco;

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
        if (diff > 2 * sizeof(long int)) {
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
        printf("[%p]: %ld\n", x, *x);
    }
    liberaMem(x);

    y = alocaMem(50);
    if (y != NULL) {
        *y = 10;
        printf("[%p]: %ld\n", y, *y);
    }    

    z = alocaMem(34);
    if (z != NULL) {
        *z = 20;
        printf("[%p]: %ld\n", z, *z);
    }

    liberaMem(y);
    liberaMem(z);

    x = alocaMem(100);
    if (x != NULL) {
        *x = 5;
        printf("[%p]: %ld\n", x, *x);
    }
    liberaMem(x);

    newTop = sbrk(0);
    printf("Diferença em Bytes: %ld\n", (char *)newTop - (char *)topoInicialHeap);
    finalizaAlocador();

    return 0;
}