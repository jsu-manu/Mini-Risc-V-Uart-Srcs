import pandas as pd 
import matplotlib.pyplot as plt
import numpy as np
import math

df = pd.read_csv('test64.csv', index_col=0)
print(df)
print(df['c0'].sum())
print(df['c1'].sum())
diff = df['c1'] - df['c0']
cyc_64 = diff / df['c0']
df32 = pd.read_csv('test32.csv', index_col=0)
diff32 = df32['c1'] - df32['c0']
cyc_32 = diff32 / df32['c0']

#diff = np.trim_zeros(diff)
#diff = diff.drop_duplicates()
print(diff)
#log_data = np.log(diff)

#f = np.polyfit(df['n'], diff, 1)
#print(f)
#fit = (f[0] * diff) + f[1]

#plt.plot(df['len'], df['c0'], 'r-')
#plt.plot(df['len'], df['c1'], 'b-')
#plt.plot(df['len'], diff, 'g-')
#plt.plot(df32['len'], df32['c0'], 'ro')
#plt.plot(df32['len'], df32['c1'], 'bo')
#plt.plot(df32['len'], diff32, 'go')
#plt.plot(df['len'], fit, 'y')
plt.plot(df['len'], cyc_64, 'r--')
plt.plot(df32['len'], cyc_32, 'b-.')
plt.show()
         
