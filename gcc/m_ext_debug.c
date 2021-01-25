void print(int a)
{
    volatile int *p = (int *)0xaaaaa008;
    *p = a;
}

int main()
{
    int num = 32;
    int p1 = 1;

    while ((num / p1) > 0)
        p1 *= 10;

    print(p1);
}