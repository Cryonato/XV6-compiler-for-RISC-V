#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

//argv[0]: virtual address
//argv[1]: (Optional) PID
int main (int argc, char* argv[]){
    uint64 pa;
    if (argc < 2){
        printf("Usage\\: vatopa virtual_address \\[pid\\]\n");
        exit(0);
    } else if (argc == 3){
        pa = va2pa(atoi(argv[1]), atoi(argv[2]));
    } else {
        pa = va2pa(atoi(argv[1]), 0x0);
    }
    printf("0x%x\n", pa);
    exit(0);
}