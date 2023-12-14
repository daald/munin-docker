#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <stdio.h>

#define FIVE_MIN (5*60)

void runUpdate() {
	printf("Running update\n");

	int returnCode = system("/opt/updater/trigger-muninupdate.sh");
	if (returnCode != 0) {
		printf(" - update returned with exit code %d\n", returnCode);
	} else {
		printf(" - update done\n");
	}
}

int main() {
	time_t now;
	int secondsToNextFiver;

	sleep(3); // avoid overload while starting

	while (1) {
		runUpdate();

		time(&now); // Get the system time
		secondsToNextFiver = FIVE_MIN - (now % FIVE_MIN);
		//printf("sec2next %d\n", secondsToNextFiver);
		sleep(secondsToNextFiver);
	}
	return 0;
}
