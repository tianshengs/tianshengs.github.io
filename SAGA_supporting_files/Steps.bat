::Tiansheng Sun, October 2019
::Data source:
::ASTER Global Digital Elevation Model, distribute by NASA EOSDIS Land Processes DAAC.]
::NASA Shuttle Radar Topography Mission Global 1 arc second. 2013, distributed by NASA EOSDIS Land Processes DAAC.

::set the path to your SAGA program
SET PATH=%PATH%;c:\saga6

::set the prefix to use for all names and outputs
SET /p pre= "Enter prefix for outputs"

::set the directory in which you want to save ouputs. In the example below, part of the directory name is the prefix you entered above
SET od=W:\OpensourceGIS\Lab2\Week4\data\%pre%

:: the following creates the output directory if it doesn't exist already
if not exist %od% mkdir %od%

:: Run Mosaicking tool, with consideration for the input -GRIDS, the -
saga_cmd grid_tools 3 -GRIDS=ASTGTMV003_S09E114_dem.sgrd;ASTGTMV003_S09E115_dem.sgrd;ASTGTMV003_S09E116_dem.sgrd -NAME=%pre%Mosaic -TYPE=9 -RESAMPLING=1 -OVERLAP=1 -MATCH=0 -TARGET_OUT_GRID=%od%\%pre%mosaic.sgrd

:: Run UTM Projection tool
saga_cmd pj_proj4 24 -SOURCE=%od%\%pre%mosaic.sgrd -RESAMPLING=1 -KEEP_TYPE=1 -GRID=%od%\%pre%mosaicUTM.sgrd -UTM_ZONE=50 -UTM_SOUTH=0

:: Get rid of the ocean
saga_cmd grid_tools 15 -INPUT=%od%\%pre%mosaicUTM.sgrd -RESULT=%od%\%pre%reclassified_mosaicUTM.sgrd -METHOD=0 -OLD=0.000000 -NEW=0.000000 -SOPERATOR=2 -NODATAOPT=0 -OTHEROPT=0 -RESULT_NODATA_CHOICE=1 -RESULT_NODATA_VALUE=0.000000

:: calculate the hillshade
saga_cmd ta_lighting 0 -ELEVATION=%od%\%pre%mosaicUTM.sgrd -SHADE=%od%\%pre%hillshade.sgrd -METHOD=0 -POSITION=0 -AZIMUTH=315.000000 -DECLINATION=45.000000 -EXAGGERATION=1.000000 -UNIT=0

:: calculate the sink drainageRoute
saga_cmd ta_preprocessor 1 -ELEVATION=%od%\%pre%reclassified_mosaicUTM.sgrd -SINKROUTE=%od%\%pre%sinkRoute.sgrd -THRESHOLD=0 -THRSHEIGHT=100.000000

:: Remove sink from the hillshade
saga_cmd ta_preprocessor 2 -DEM=%od%\%pre%reclassified_mosaicUTM.sgrd -SINKROUTE=%od%\%pre%sinkRoute.sgrd -DEM_PREPROC=%od%\%pre%withoutSinkRouteDEM.sgrd -METHOD=1 -THRESHOLD=0 -THRSHEIGHT=100.000000

:: calculate flow accumulation
saga_cmd ta_hydrology 0 -ELEVATION=%od%\%pre%withoutSinkRouteDEM.sgrd -SINKROUTE=%od%\%pre%sinkRoute.sgrd -WEIGHTS=NULL -FLOW=%od%\%pre%FlowAccumulation.sgrd -VAL_INPUT=NULL -ACCU_MATERIAL=NULL -STEP=1 -FLOW_UNIT=0 -FLOW_LENGTH=NULL -LINEAR_VAL=NULL -LINEAR_DIR=NULL -METHOD=4 -LINEAR_DO=1 -LINEAR_MIN=500 -CONVERGENCE=1.100000

:: calculate channel network
saga_cmd ta_channels 0 -ELEVATION=%od%\%pre%withoutSinkRouteDEM.sgrd -SINKROUTE=NULL -CHNLNTWRK=%od%\%pre%channelNetwork.sgrd -CHNLROUTE=%od%\%pre%channelDirection.sgrd -SHAPES=%od%\%pre%shape.shp -INIT_GRID=%od%\%pre%FlowAccumulation.sgrd -INIT_METHOD=2 -INIT_VALUE=1000.000000 -DIV_GRID=NULL -DIV_CELLS=5 -TRACE_WEIGHT=NULL -MINLEN=10

::print a completion message so that uneasy users feel confident that the batch script has finished!
ECHO Processing Complete!
PAUSE
