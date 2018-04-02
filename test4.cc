#include <stdio.h>
#include <unistd.h>

class Test
{
public:
  Test ()
  {
  }
  ~Test ()
  {
  }

  int sub (int x, int y)
  {
    int z = x - y;
    sleep (10);
    return z;
  }
  int add (int x, int y)
  {
    return x + y;
  }
  int divi(int x, int y)
  {
      if(y == 0)
      {
          return -1;
      }
      return x/y;
  }
};

int
main ()
{
  int x = 4, y = 2;

  Test test;
  int z = test.add (x, y);
  test.sub (z, y);
  z = test.divi(x, y);
  printf ("z=%d\n", z);
  return 0;
}
