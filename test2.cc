#include <stdio.h>

class Test
{
public:
    Test() {}
    ~Test() {}

    int add(int x, int y) {return x+y;}
};

int add(int x, int y)
{
    int z = x + y;
    return z;
}

int main()
{
    int x = 0, y = 1;

    Test test;
    int z = test.add(x, y);
    printf("z=%d\n", z);
    return 0;
}
