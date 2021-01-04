#include<cstdio>
#include<cstdlib>
using namespace std;
int main(){
    unsigned int instruction;
    while(fscanf(stdin, "%x", &instruction) > 0){
        putchar(instruction & 0xff);
        putchar((instruction >> 8) & 0xff);
        putchar((instruction >> 16) & 0xff);
        putchar((instruction >> 24) & 0xff);
    }
    return 0;
}
