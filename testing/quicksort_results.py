import pandas as pd 
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.font_manager as font_manager
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

#plt.title("Quicksort Worst-Case Runtime Overhead")
plt.plot(df['len'], diff, 'rs-', label="64 Address RAS", markevery=4)
plt.plot(df2['len'], diff2, 'bd-', label="32 Address RAS", markevery=4)
font = font_manager.FontProperties(family="Times New Roman", style='normal', size=15)
plt.legend(prop=font)
plt.xlabel("number of elements in array (n)", fontsize=16, fontname="Times New Roman")
plt.ylabel("Percent increase in execution time", fontsize=16, fontname="Times New Roman")
plt.show()
         
