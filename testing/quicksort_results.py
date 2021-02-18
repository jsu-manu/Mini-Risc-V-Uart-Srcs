import pandas as pd 
import matplotlib.pyplot as plt
import numpy as np
import math

df = pd.read_csv('fact.csv', index_col=0)
print(df)
print(df['c0'].sum())
print(df['c1'].sum())
diff = df['c1'] - df['c0']

#diff = np.trim_zeros(diff)
diff = diff.drop_duplicates()
print(diff)
#log_data = np.log(diff)

#f = np.polyfit(df['n'], diff, 1)
#print(f)
#fit = (f[0] * diff) + f[1]

#plt.plot(df['n'], df['c0'], 'r')
#plt.plot(df['n'], df['c1'], 'b')
#plt.plot(df['n'], diff, 'g')
#plt.plot(df['len'], fit, 'y')
#plt.show()
         
