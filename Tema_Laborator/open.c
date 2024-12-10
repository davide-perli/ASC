#include <stdio.h>
#include <fcntl.h>

int main() {
    int fd = open("/home/davide/Documents/ASC/Tema_Laborator/proiect", O_RDONLY);

    printf("%d\n", fd);
    while (1)
    {
        ;
    }
    
}