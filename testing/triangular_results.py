import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import math

df = pd.read_csv('new_fact.csv', index_col=0)
df2 = pd.read_csv('fact_32.csv', index_col=0) 
print(df)
diff = ((df['c1'] - df['c0']) / (df['c0'])) * 100
diff2 = ((df2['c1'] - df2['c0']) / (df2['c0']) ) * 100

plt.title('Performance Overhead for Recursively Calculating nth Triangular Number')
#plt.plot(df['n'], df['c0'], 'r--')
#plt.plot(df['n'], df['c1'], 'b-.')
line1, = plt.plot(df['n'], diff, 'g', label='64 Address RAS')
line2, = plt.plot(df2['n'], diff2, 'r', label='32 Address RAS')
plt.xlabel('n')
plt.ylabel('Percent incrase in execution time')
plt.legend()
plt.show()
