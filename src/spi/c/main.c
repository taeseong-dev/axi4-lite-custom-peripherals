#include "ap/ap_main.h"
#include "xparameters.h"

// System initialization and main execution loop
int main(void)
{
    ap_init();

    while (1)
    {
        ap_execute();
    }

    return 0;
}
