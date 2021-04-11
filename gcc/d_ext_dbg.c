void print(int a)
{
    volatile int *p = (int *)0xaaaaa008;
    *p = a;
}

int main()
{
    int n1 = 3;
    int n2 = 9;
    int n3 = -3;
    int n4 = -9;
    unsigned int u1 = 3;
    unsigned int u2 = 9;
    unsigned int u3 = -3;
    unsigned int u4 = -9;

    int res1 = n2/n1;
    int res2 = n4/n1;
    int res3 = n4/n3;
    int res4 = u4/u1;
    int res5 = u4/n1;
}