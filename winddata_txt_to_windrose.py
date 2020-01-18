import csv
import windrose
from matplotlib.pyplot import show, title, savefig

# import wind data from CSV
#fileID = 'C:\\Users\\devin\\OneDrive\\Documents\\College\\Research\\Internal\\2020 01\\Wind data\\LLNR 590 buoy data 2017.txt'
#with open(fileID) as csvfile:
#    reader = csv.reader(csvfile, delimiter=' ')
#    next(reader) #skips header line of CSV file
#    next(reader)
#    winddir = []
#    windspeed = []
#    for row in reader:
#        while '' in row:
#            row.remove('')
#       currentdir = row[5]
#        currentspeed = row[6]
#        winddir.append(float(currentdir))
#        windspeed.append(float(currentspeed))
winddir = [348.74]
windspeed = [5]
ax = windrose.WindroseAxes.from_ax()
ax.bar(winddir, windspeed, normed=True, opening=0.8, edgecolor='white')
ax.set_legend()

title('LLNR 590 buoy wind data, January 2017 - December 2017')
#savefig('C:\\Users\\devin\\OneDrive\\Documents\\College\\Research\\Internal\\2020 01\\Wind data\\LLNRwindrose.png')
show()