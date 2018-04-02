#include <stdio.h>

class Test
{
public:
    Test() {}
    ~Test() {}

    int add(int x, int y) {return x+y;}
    int multi(int x, int y) {return x*y;}
    int divi(int x, int y) {return x/y;}
};

int add(int x, int y)
{
    Test test;
    int z = test.add(x, y);
    return z;
}

int main()
{
    int x = 6, y = 3;

    Test test;
    int z = test.add(x, y);
    z = test.multi(x, y);
    z = test.divi(x, y);
    printf("z=%d\n", z);
    return 0;
}
