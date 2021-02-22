import pandas as pd 
import matplotlib.pyplot as plt
import numpy as np
import math

df = pd.read_csv('new_test64.csv', index_col=0)
print(df)
diff = ((df['c1'] - df['c0']) / df['c0']) * 100
df2 = pd.read_csv('new_test32.csv', index_col=0)
diff2 = ((df2['c1'] - df2['c0']) / df2['c0'] ) * 100
print(df2)
#diff = np.trim_zeros(diff)
#diff = diff.drop_duplicates()
print(diff)
#log_data = np.log(diff)

plt.title("Quicksort Worst-Case Runtime Overhead")
plt.plot(df['len'], diff, 'r', label="64 Address RAS")
plt.plot(df2['len'], diff2, 'b', label="32 Address RAS")
plt.legend()
plt.xlabel("number of elements in array (n)")
plt.ylabel("Percent increase in execution time")
plt.show()
         
