#include <stdio.h>

int add(int x, int y)
{
    return x+y;
}

int main()
{
    int x = 1;
    int y = 2;
    int z = add(x, y);
    printf("z=%d\n", z);
    return 0;
}
