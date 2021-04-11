void print(int a)
{
    volatile int *p = (int *)0xaaaaa008;
    *p = a;
}

int main()
{
    int num = 4;
    int p1 = 3;
    int p2 = 1;

    if ((num / p1) * (p2 / p1) > 0) //  bge x0, rs, offset, meaning branch taken and jump to else.
        print(15);
    else
        print(10);
}