import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import math
import matplotlib.font_manager as font_manager

df = pd.read_csv('new_fact.csv', index_col=0)
df2 = pd.read_csv('fact_32.csv', index_col=0) 
print(df)
diff = ((df['c1'] - df['c0']) / (df['c0'])) * 100
diff2 = ((df2['c1'] - df2['c0']) / (df2['c0']) ) * 100

#plt.title('Performance Overhead for Recursively Calculating nth Triangular Number')
#plt.plot(df['n'], df['c0'], 'r--')
#plt.plot(df['n'], df['c1'], 'b-.')
line1, = plt.plot(df['n'], diff, 'rs-', label='64 Address RAS', markevery=20)
line2, = plt.plot(df2['n'], diff2, 'bd-', label='32 Address RAS', markevery=20)
plt.xlabel('N$^{th}$ triangular number', fontsize=16, fontname="Times New Roman")
plt.ylabel('Percent increase in execution time', fontsize=16, fontname="Times New Roman")
font = font_manager.FontProperties(family="Times New Roman", style='normal', size=15)
plt.legend(prop=font)
plt.show()
