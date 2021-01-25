void print(int a)
{
    volatile int *p = (int *)0xaaaaa008;
    *p = a;
}

int main()
{
    int num1 = 2;
    int num2 = 0;

    if ((num1 / num2) != 0)
        print(1);
    else
        print(0);
}