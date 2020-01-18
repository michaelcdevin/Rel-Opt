import csv
import windrose
from matplotlib.pyplot import show, title, savefig

# import wind data from CSV
fileID = 'C:\\Users\\devin\\OneDrive\\Documents\\College\\Research\\Internal\\2020 01\\Wind data\\E02_2010-11.csv'
with open(fileID) as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    next(reader) #skips header line of CSV file
    winddir = []
    windspeed = []
    for row in reader:
        currentdir = row[1]
        currentspeed = row[2]
        if currentdir != '' and currentspeed != '':
            winddir.append(float(currentdir))
            windspeed.append(float(currentspeed))

ax = windrose.WindroseAxes.from_ax()
ax.bar(winddir, windspeed, normed=True, opening=0.8, edgecolor='white')
ax.set_legend()

title('E01 buoy wind data, September 2010 - August 2011')
savefig('C:\\Users\\devin\\OneDrive\\Documents\\College\\Research\\Internal\\2020 01\\Wind data\\E02windrose.png')