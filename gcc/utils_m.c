#include "utils.h"

int abs(int i)
{
    return i < 0 ? -i : i;
}

int multiply(unsigned int a, unsigned int b)
{
    unsigned int r = 0;

    while (a)
    {
        if (a & 1)
            r += b;
        a >>= 1;
        b <<= 1;
    }
    return r;
}

int divide(int x, int y)
{
    // handle divisibility by 0
    if (y == 0)
    {
        return 0;
    }

    // store sign of the result
    int sign = 1;
    if (multiply(x, y) < 0)
    {
        sign = -1;
    }

    // convert both dividend and divisor to positive
    x = abs(x);
    y = abs(y);

    unsigned mask = 1;
    unsigned quotient = 0;

    while (y <= x)
    {
        y <<= 1;
        mask <<= 1;
    }

    while (mask > 1)
    {
        y >>= 1;
        mask >>= 1;
        if (x >= y)
        {
            x -= y;
            quotient |= mask;
        }
    }

    return multiply(sign, quotient);
}

int modulo(int x, int y)
{
    // handle divisibility by 0
    if (y == 0)
    {
        return 0;
    }

    // store sign of the result
    int sign = 1;
    if (x < 0)
    {
        sign = -1;
    }

    // convert both dividend and divisor to positive
    x = abs(x);
    y = abs(y);

    unsigned mask = 1;

    while (y <= x)
    {
        y <<= 1;
        mask <<= 1;
    }

    while (mask > 1)
    {
        y >>= 1;
        mask >>= 1;
        if (x >= y)
        {
            x -= y;
        }
    }

    return multiply(sign, x);
}

int count_digits(long n)
{
    int count = 0;

    while (n != 0)
    {
        n = divide(n, 10);
        ++count;
    }

    return count;
}
