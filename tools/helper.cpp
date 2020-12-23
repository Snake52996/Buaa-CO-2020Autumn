#include<cstdio>
#include<cstdlib>
using namespace std;
inline static void throwFileNotFound(const char* path){
	printf("\e[33;1mError: Failed to open %s: file doesn't exist or permission denied.\e[0m\n", path);
	printf("Maybe you want to check and try again.\n");
	exit(1);
}
int main(int argc, char** argv){
    if(argc < 2) return 1;
    FILE* input_f = fopen(argv[1], "r");
    if(input_f == NULL) throwFileNotFound(argv[1]);
    unsigned int instruction;
    while(fscanf(input_f, "%x", &instruction) > 0){
        putchar(instruction & 0xff);
        putchar((instruction >> 8) & 0xff);
        putchar((instruction >> 16) & 0xff);
        putchar((instruction >> 24) & 0xff);
    }
    fclose(input_f);
    return 0;
}