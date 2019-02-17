# -*- coding: utf-8 -*-
"""
Created on Sat Nov  4 19:57:20 2017

@author: Kashish
"""
import pandas as pd
import csv
from io import BytesIO
from PIL import Image
from urllib import request
import matplotlib.pyplot as plt # this is if you want to plot the map using pyplot
#GDP = open('E:\Fall 2017\Project\image.csv')
Gdp = pd.read_csv('E:\Fall 2017\Project\image.csv')

# = csv.reader(GDP)
#header = next(reader)
data = {}
#for column in header:
    #data[column] = []
#for record in reader:
    #for name, value in zip(header, record):
        #data[name].append(value)
        
#reader = pd.df(Gdp)
print("Gdp is: " ,Gdp)
for x,y in Gdp.iterrows():
    print(type(x))
    print("x[0] is: " ,y['lat'])
    print("y[0] is: " ,y['lon'])
    
    url = "https://maps.googleapis.com/maps/api/streetview?size=400x400&location="+str(y['lat'])+","+str(y['lon'])+"&fov=90&heading=235&pitch=10&key=AIzaSyAF_SHNpUp4sA3SBCTBmWDOk_v1Nh-qeB8"
    buffer = BytesIO(request.urlopen(url).read())
    image = Image.open(buffer)
    image.save("map"+str(y['lat'])+str(y['lon'])+".png")
        

# Or using pyplot
#plt.imshow(image)
#plt.show()

