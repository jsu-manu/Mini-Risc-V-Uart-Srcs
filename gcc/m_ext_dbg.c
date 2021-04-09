void print(int a)
{
    volatile int *p = (int *)0xaaaaa008;
    *p = a;
}

int main()
{
    int num = 0;
    int p1 = 3;

    // Expected behavior:
    // 0*3 = 0
    // 0 > 0, no
    // Print 0.

    if ((num * p1) > 0) //  bge x0, rs, offset, meaning branch taken and jump to else.
        print(1);
    else
        print(0);
}