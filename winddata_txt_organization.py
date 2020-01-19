import csv
import windrose
from matplotlib.pyplot import show, title, savefig
from numpy import median

winddir = []
windspeed = []
dir_n = []
dir_nne = []
dir_ne = []
dir_ene = []
dir_e = []
dir_ese = []
dir_se = []
dir_sse = []
dir_s = []
dir_ssw = []
dir_sw = []
dir_wsw = []
dir_w = []
dir_wnw = []
dir_nw = []
dir_nnw = []
sp_n = []
sp_nne = []
sp_ne = []
sp_ene = []
sp_e = []
sp_ese = []
sp_se = []
sp_sse = []
sp_s = []
sp_ssw = []
sp_sw = []
sp_wsw = []
sp_w = []
sp_wnw = []
sp_nw = []
sp_nnw = []
# import wind data from CSV
fileID = 'C:\\Users\\devin\\OneDrive\\Documents\\College\\Research\\Internal\\2020 01\\Wind data\\LLNR 590 buoy data 2017.txt'
with open(fileID) as csvfile:
    reader = csv.reader(csvfile, delimiter=' ')
    next(reader) #skips header line of CSV file
    next(reader)

    for row in reader:
        while '' in row:
            row.remove('')
        currentdir = row[5]
        currentspeed = row[6]
        winddir.append(float(currentdir))
        windspeed.append(float(currentspeed))
for idx, sample in enumerate(winddir):
    if 11.25 <= sample < 33.75:
        dir_nne.append(sample)
        sp_nne.append(windspeed[idx])

    elif 56.25 <= sample < 78.75:
        dir_ne.append(sample)
        sp_ne.append(windspeed[idx])
    elif 33.75 <= sample < 56.25:
        dir_ene.append(sample)
        sp_ene.append(windspeed[idx])
    elif 78.75 <= sample < 101.25:
        dir_e.append(sample)
        sp_e.append(windspeed[idx])
    elif 101.25 <= sample < 123.75:
        dir_ese.append(sample)
        sp_ese.append(windspeed[idx])
    elif 123.75 <= sample < 146.25:
        dir_se.append(sample)
        sp_se.append(windspeed[idx])
    elif 146.25 <= sample < 168.75:
        dir_sse.append(sample)
        sp_sse.append(windspeed[idx])
    elif 168.75 <= sample < 191.25:
        dir_s.append(sample)
        sp_s.append(windspeed[idx])
    elif 191.25 <= sample < 213.75:
        dir_ssw.append(sample)
        sp_ssw.append(windspeed[idx])
    elif 213.75 <= sample < 236.25:
        dir_sw.append(sample)
        sp_sw.append(windspeed[idx])
    elif 236.25 <= sample < 258.75:
        dir_wsw.append(sample)
        sp_wsw.append(windspeed[idx])
    elif 258.75 <= sample < 281.25:
        dir_w.append(sample)
        sp_w.append(windspeed[idx])
    elif 281.25 <= sample < 303.75:
        dir_wnw.append(sample)
        sp_wnw.append(windspeed[idx])
    elif 303.75 <= sample < 326.25:
        dir_nw.append(sample)
        sp_nw.append(windspeed[idx])
    elif 326.25 <= sample < 348.75:
        dir_nnw.append(sample)
        sp_nnw.append(windspeed[idx])
    elif 348.75 <= sample < 360 or 0 <= sample < 11.25:
        dir_n.append(sample)
        sp_n.append(windspeed[idx])

nSamples = len(winddir)
dir_ptgs = [len(dir_n)/nSamples, len(dir_nne)/nSamples, len(dir_ne)/nSamples, len(dir_ene)/nSamples,
            len(dir_e)/nSamples, len(dir_ese)/nSamples, len(dir_se)/nSamples, len(dir_sse)/nSamples,
            len(dir_s)/nSamples, len(dir_ssw)/nSamples, len(dir_sw)/nSamples, len(dir_wsw)/nSamples,
            len(dir_w)/nSamples, len(dir_wnw)/nSamples, len(dir_nw)/nSamples, len(dir_nnw)/nSamples]
sp_medians = [median(sp_n), median(sp_nne), median(sp_ne), median(sp_ene), median(sp_e), median(sp_ese),
              median(sp_se), median(sp_sse), median(sp_s), median(sp_ssw), median(sp_sw), median(sp_wsw),
              median(sp_w), median(sp_wnw), median(sp_nw), median(sp_nnw)]
print(dir_ptgs)
print(sp_medians)

