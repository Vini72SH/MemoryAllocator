#include "meuAlocador.h"
#include <stdio.h>

int main (int argc, char** argv) {
  long int *a, *b;

  iniciaAlocador();               // Impressão esperada
  imprimeMapa();                  // <vazio>

  a = (void *) alocaMem(10);
  imprimeMapa();                  // ################**********
  //b = (void *) alocaMem(4);
  //imprimeMapa();                  // ################**********##############****
  liberaMem(a);
  imprimeMapa();                  // ################----------##############****
  //liberaMem(b);                   // ################----------------------------
                                  // ou
                                  // <vazio>
  finalizaAlocador();

  return 0;
}
