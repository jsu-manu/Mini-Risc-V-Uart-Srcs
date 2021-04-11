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
    int res = 0;

    if ((num / p1) * (p2 / p1) > 0) //  bge x0, rs, offset, meaning branch taken and jump to else.
        res = 15;
    else
        res = ((num / p2) - (p1 * p1)) / ((num - p1) + (p1 * p2));

    print(res);
}