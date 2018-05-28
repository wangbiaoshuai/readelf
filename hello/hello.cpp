//#include"/usr/local/include/c++/4.8.2/ext/new_allocator.h"
#include <cstdio>
#include<stdlib.h>  
#include <iostream>
#include"debug_new.h"
using namespace std;




class A{
    int num;
public:
    A(){
        cout<<"A's constructor"<<endl;
    }

    ~A(){
        cout<<"~A"<<endl;
    }
    void show(){
        cout<<"num:"<<num<<endl;
    }
};

int main(int argc, char *argv[])  
{  
char buffer[200], s[] = "computer", c = 'l';
int i = 35, j;

  
    char mem[100];
    mem[0]='A';
    mem[1]='\0';
    mem[2]='\0';
    mem[3]='\0';
    cout<<(void*)mem<<endl;
    //A* p=new A;
    A* p1 = new(mem) A;
    cout<<p<<endl;
    p->show();
    p->~A();
    getchar();
		  
	return 0;  
}  


