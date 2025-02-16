#include <stdlib.h>

extern int carrega(int, int, int, int, int, int, int, int, int);

int main(int argc, char **argv) {
	int params[9] = {-1, -1, 0, -1, 0, -1, 0, -1, 0};
	for (int i = 1; i < argc; i++) {
		params[i-1] = atoi(argv[i]);
	}
	carrega(params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8]);
	return 0;
}
