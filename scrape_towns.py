from requests import get
from bs4 import BeautifulSoup
import pandas as pd
import re
import html5lib


###Collect all towns

url = 'https://www.jri-poland.org/town/index.htm'

response = get(url)

html_soup = BeautifulSoup(response.text, 'html.parser')

all_towns = html_soup.find_all('tr', class_ = 'notranslate')

#start loop
jsonList = []

for idx,town in enumerate(all_towns):
    
    currJson = {}

    #check if town name is empty string
    if town.td.a.text:
 
        currJson['name'] = town.find_all('td')[0].text       
        currJson['href'] = town.td.a['href']
        currJson['alt_name'] = town.find_all('td')[1].text
        currJson['gubernia'] = town.find_all('td')[2].text
        currJson['province'] = town.find_all('td')[3].text
        currJson['lat'] = town.find_all('td')[4].text
        currJson['long'] = town.find_all('td')[5].text
        
        jsonList.append(currJson)
        
        if (idx+1) % 10 == 0:
            print(idx+1)


#convert to dataframe

towns_df = pd.DataFrame(jsonList)

towns_df.head(5)

towns_df.to_csv('~/shtetls/towns_df.csv',index=False)


###Collect USBGN from each page for each town

jsonList = []
for idx, row in towns_df.iterrows():
    currJson = {}
    response = get('https://www.jri-poland.org'+row['href'])
    
    if (idx+1) % 10 == 0:
        print(idx+1)
        
    if response.status_code == 200:
        html_soup = BeautifulSoup(response.text, 'html.parser')
        town_info = html_soup.find_all('td', class_ = 'left')
        currJson['name'] = row['name']
        
        try:
            currJson['google_maps'] = town_info[1].find_all('a')[0]['href']
            currJson['jewish_gen'] = town_info[1].find_all('a')[1]['href']
            usbgn = town_info[1].find_all('b')[4].text.replace(",","")
            currJson['usbgn'] = usbgn
        except:
            currJson['google_maps'] = None
            currJson['jewish_gen'] = None
            currJson['usbgn'] = None
            
        jsonList.append(currJson)

#convert to dataframe
add_info = pd.DataFrame(jsonList)

add_info.head(5)

df = pd.merge(towns_df, add_info, how='left', on='name')

df.tail(5)

df.to_csv('~/shtetls/all_towns.csv',index=False)


###Collect other info from JewishGen site

df = pd.read_csv("~/shtetls/all_towns.csv")
df = pd.read_csv("~/Desktop/all_towns.csv")

df['usbgn'] = df['usbgn'].apply(pd.to_numeric, errors='coerce')
df['usbgn'] = df['usbgn'].fillna(0).astype(int)
df['usbgn'] = df['usbgn'].astype(str)

jsonList = []

for idx, row in df.iterrows():
    currJson = {}
    
    if row['usbgn'] == '0':
        continue
    
    try:
        response = get('https://www.jewishgen.org/Communities/community.php?usbgn='+row['usbgn'])
        pass
    except:
        continue
    
    print(idx)
    
    if (idx) % 10 == 0:
        print(idx)

    if response.status_code == 200:
        
        try:
            html_soup = BeautifulSoup(response.text, 'html5lib')
            
            currJson['name'] = row['name']
    
            ##region,name       
            town_info = html_soup.find_all('table')
            currJson['alt_name'] = town_info[4].find_all('td')[0].find_all('h3')[0].text
            currJson['region'] = town_info[4].find_all('td')[0].find_all('h3')[1].text
            
            ##timeline
            #put timeline code here
            
            ##population, notes
            more_info = html_soup.find_all('tr')
            currJson['population'] = more_info[15].find_all('td')[1].text
            currJson['notes'] = more_info[16].find_all('td')[1].text
            
            jsonList.append(currJson)
        except:
            continue

population = pd.DataFrame(jsonList)

population.head(5)

df = pd.merge(df, population, how='left', on='name')

df.to_csv('~/Desktop/all_towns.csv',index=False)

writer = pd.ExcelWriter('~/shtetls/shtetl_info.xlsx', engine='xlsxwriter')

df.to_excel(writer, sheet_name='Sheet1')

writer.save()



