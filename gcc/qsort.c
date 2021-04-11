#define INSERTION_THRESHOLD 10
#define NSTACK 50
#define DATA_SIZE 4
#include "uart.h" 

#define SWAP(a, b)            \
    do                        \
    {                         \
        typeof(a) temp = (a); \
        (a) = (b);            \
        (b) = temp;           \
    } while (0)
#define SWAP_IF_GREATER(a, b) \
    do                        \
    {                         \
        if ((a) > (b))        \
            SWAP(a, b);       \
    } while (0)

//--------------------------------------------------------------------------
// Quicksort function

static void insertion_sort(unsigned int n, int arr[])
{
    int *i, *j;
    int value;
    for (i = arr + 1; i < arr + n; i++)
    {
        value = *i;
        j = i;
        while (value < *(j - 1))
        {
            *j = *(j - 1);
            if (--j == arr)
                break;
        }
        *j = value;
    }
}

static void selection_sort(unsigned int n, int arr[])
{
    for (int *i = arr; i < arr + n - 1; i++)
        for (int *j = i + 1; j < arr + n; j++)
            SWAP_IF_GREATER(*i, *j);
}

void sort(unsigned int n, int arr[])
{
    unsigned int i = 0;

    int *ir = arr + n;
    int *l = arr + 1;
    int *stack[NSTACK];
    int **stackp = stack;

    for (;;)
    {
        // Insertion sort when subarray small enough.
        if (ir - l < INSERTION_THRESHOLD)
        {
            insertion_sort(ir - l + 1, l - 1);

            if (stackp == stack)
                break;

            // Pop stack and begin a new round of partitioning.
            ir = *stackp--;
            l = *stackp--;
        }
        else
        {
            // Choose median of left, center, and right elements as
            // partitioning element a. Also rearrange so that a[l-1] <= a[l] <= a[ir-].
            SWAP(arr[((l - arr) + (ir - arr)) / 2 - 1], l[0]);
            SWAP_IF_GREATER(l[-1], ir[-1]);
            SWAP_IF_GREATER(l[0], ir[-1]);
            SWAP_IF_GREATER(l[-1], l[0]);

            // Initialize pointers for partitioning.
            int *i = l + 1;
            int *j = ir;

            // Partitioning element.
            int a = l[0];

            for (;;)
            { // Beginning of innermost loop.
                while (*i++ < a)
                    ; // Scan up to find element > a.
                while (*(j-- - 2) > a)
                    ; // Scan down to find element < a.
                if (j < i)
                    break;          // Pointers crossed. Partitioning complete.
                SWAP(i[-1], j[-1]); // Exchange elements.
            }                       // End of innermost loop.

            // Insert partitioning element.
            l[0] = j[-1];
            j[-1] = a;
            stackp += 2;

            // Push pointers to larger subarray on stack,
            // process smaller subarray immediately.

            if (ir - i + 1 >= j - l)
            {
                stackp[0] = ir;
                stackp[-1] = i;
                ir = j - 1;
            }
            else
            {
                stackp[0] = j - 1;
                stackp[-1] = l;
                l = i;
            }
        }
    }
}

//--------------------------------------------------------------------------
// Main

int main(void)
{
    unsigned int i = 0;

	uart_init();

    int input_data[DATA_SIZE] = {3, 4, 2, 1};

    sort(DATA_SIZE, input_data);
	
    int res1 = input_data[0] / input_data[1];
    int res2 = input_data[2] / input_data[3];
    
    return 0;
}
