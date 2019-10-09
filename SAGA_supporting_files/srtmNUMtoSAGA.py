#! /usr/bin/env python

# ----------------------------------------------------------------------
# Import SRTM V003 or ASTER V002 global elevation model tiles into SAGA, mosaic them, and project them to UTM Zones
# Script by J. Holler, February 2018
# borrowing code & advice from V. Wichmann's script, 'Create hillshades for all ESRI ASCII grids in a folder'
# ----------------------------------------------------------------------

# import required python libraries
import os, sys, subprocess, time

# function definitions for logging errors
def runCommand_logged (cmd, logstd, logerr):
    p = subprocess.call(cmd, stdout=logstd, stderr=logerr)

# environmental for paths to working directory and log files
# set SAGADIR to the directory in which the SAGA program is installed
# set WORKDIR to the directory in which your SRTM V003 NUM grids are stored, which is also where the output folders will be created

SAGADIR	= "C:\Saga6"  #where is SAGA installed?
WORKDIR = "W:\Opensource GIS\Lab2\Week4\data"  #replace the question with the location of your SRTM V003 .NUM files

# the following code sets up the sgrd file paths & opens log files
os.environ["PATH"] += os.pathsep + SAGADIR
if not os.path.isdir(WORKDIR + os.sep + "sgrd"):
    os.mkdir(WORKDIR + os.sep + "sgrd")
STDLOG     = WORKDIR + os.sep + "sgrd" + os.sep + "processing.log"
ERRLOG     = WORKDIR + os.sep + "sgrd" + os.sep + "processing.error.log"
logstd = open(STDLOG, "a")
logerr = open(ERRLOG, "a")

# initialize global variables for managing folders & file names
dirlist = os.listdir(WORKDIR)
t0 = time.time()
gridList = ''
cmd = []
projCMD = []
mirrorCMD = []
  
# loop over SRTM .hgt files and import them to the SAGA Grid format
# meanwhile, add the saga grid file names to gridList for use in the next function: mosaicking
for file in dirlist:
    filename, fileext = os.path.splitext(file)
    cmd = []
    mirrorCMD = []
    projCMD = []
    south = ''
    west = ''
    if fileext == '.num':
        if filename[0] == 'S':
            south = "-"  #negative for southern hemisphere
        if filename[3] == 'W':
            west = '-'  #negative for western hemisphere
        gridList += (WORKDIR + os.sep + 'sgrd' + os.sep + filename + '.sgrd;')
        cmd = ['saga_cmd', '-f=q', 'io_grid', '4',  #import/export -> grids -> import binary raw data
                '-FILE', WORKDIR + os.sep + file,
                '-GRID', WORKDIR + os.sep + 'sgrd' + os.sep + filename + '.sgrd',
                '-NX', '3601', #number of columns
                '-NY', '3601', #number of rows
                '-CELLSIZE', '0.000278',  #cell size
                '-POS_VECTOR', '0', #0 is cell's center; 1 is cell's corner
                '-POS_X', west + filename[4:7], #get x-coordinate, where in a:b, a is inclusive, b exclusive. stupid python
                '-POS_X_SIDE', '0', #0 is left, 1 is right
                '-POS_Y', south + filename[1:3], #get y-coordinate
                '-POS_Y_SIDE', '1', #0 is top, 1 is bottom
                '-DATA_TYPE', '0',
                '-BYTEORDER', '0',
                '-ZFACTOR', '1',
                '-NODATA', '-99999',
                '-DATA_OFFSET', '0',
                '-LINE_OFFSET', '0',
                '-LINE_ENDSET', '0',
                '-ORDER', '0',
                '-TOPDOWN', '0', #bottom-up
                '-LEFTRIGHT', '0' #left to right, doesn't work!!! Seems like it was fixed by SAGA 7.xxx
                ]
                #unused options: -UNIT
        projCMD = ['saga_cmd', '-f=q', 'pj_proj4', '0',
            '-GRIDS', WORKDIR + os.sep + 'sgrd' + os.sep + filename + '.sgrd',
            '-CRS_EPSG', '4326',
            '-CRS_EPSG_AUTH', 'EPSG',
            '-CRS_PROJ4', '+proj=longlat +datum=WGS84 +no_defs'
            ]
        mirrorCMD = ['saga_cmd', '-f=q', 'grid_tools', '35',
            '-GRID', WORKDIR + os.sep + 'sgrd' + os.sep + filename + '.sgrd',
            '-MIRROR', WORKDIR + os.sep + 'sgrd' + os.sep + filename + '.sgrd',
            '-METHOD','0']
    if len(cmd) > 0:
        try:
            print ('executing ' + str(cmd) + '\n')
            runCommand_logged(cmd, logstd, logerr)
        except Exception as e:
            logerr.write("Exception thrown while processing file: " + file + "\n")
            logerr.write("ERROR: %s\n" % e)
    if len(projCMD) > 0: #raw NUM files need projections defined
        try:
            print ('executing ' + str(projCMD) + '\n')
            runCommand_logged(projCMD, logstd, logerr)
        except Exception as e:
            logerr.write("Exception thrown while processing file: " + file + "\n")
            logerr.write("ERROR: %s\n" % e)
    if len(mirrorCMD) > 0: #this will not be needed if you use SAGA with working -LEFTRIGHT switch 
        try:
            print ('executing ' + str(mirrorCMD) + '\n')
            runCommand_logged(mirrorCMD, logstd, logerr)
        except Exception as e:
            logerr.write("Exception thrown while processing file: " + file + "\n")
            logerr.write("ERROR: %s\n" % e)    
# ------------ finished importing files to SAGA grid format ------------


# finalize
logstd.write("\n\nProcessing finished in " + str(int(time.time() - t0)) + " seconds.\n")
logstd.close()
logerr.close()
