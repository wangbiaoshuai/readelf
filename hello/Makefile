
MODULE_NAME =hello
BUILD_BIN = $(MODULE_NAME)
CC =	g++
CFLAGS = -fpic -pipe -W -Wall -Wpointer-arith -O2 -fpermissive
CPP =	shell -E
LINK =	$(CC) 

 
		

$(BUILD_BIN):	hello.o 
					

	$(LINK)  -o $(BUILD_BIN)   \
				hello.o 

	


hello.o:	$(CORE_DEPS) \
	hello.cpp
	$(CC) -c $(CFLAGS) $(CORE_INCS)  \
        -o hello.o \
		hello.cpp 
			
				

clean:
	rm -rf *.o  $(BUILD_BIN)


