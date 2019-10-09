# Global Digital Elevation Models, Model Error Propagation and Uncertainty
This is a continuation of the [Kilimanjaro project](globalDigitalElevation.md). For the Kilimanjaro project, I showed the steps 
needed to model hydrology and channel networks of the Mt.Kilimanjaro in northern Tanzania in SAGA using SRTM data. 

This week, I plan to model the hydrology and channel networks of **Bali and Lombok** islands, Indonesia. In this project,
I plan to delve deeper into:
- using batch processing algorithms for SAGA tools in order to automate processing tasks;
- drilling into sources of error and compare elevation models (SRTM and ASTER) and their resulting hydrological models for error, error 
propogation, and uncertainty;
- using some new SAGA tools for our analysis;
- visualizing data error in the elevation models in QGIS.

## Preparation step

### Data Collection
For this project, I am going to use both DEM models:
- ASTER Global Digital Elevation Model, distribute by NASA EOSDIS Land Processes DAAC.
- NASA Shuttle Radar Topography Mission Global 1 arc second. 2013, distributed by NASA EOSDIS Land Processes DAAC.

Besides the DEM models, I am also going to use the .NUM files for these DEM data, which can help explain errors and differences 
between data sources by telling us the sources of information for each location.

All data are dowloaded from [earth data](https://earthdata.nasa.gov/).

### Software used
The softwares used for the project are SAGA 6.2 for hydrology analysis.

### Creating SAGA grid files for the .NUM files
In order to use the .NUM files in SAGA, we can use this supporting [python file](SAGA_supporting_files/srtmNUMtoSAGA.py) to create 
a set of SAGA grid files. The python file imports a binary file as a SAGA grid, assigns the WGS 1984 geographic coordinate system to
the grid and mirrors the grid. 

### Batch scripts
A bat file is a batch processing file that can run a series of commands in Window's command shell. Since each SAGA tool can be run as a
command, I wrote a [bat script file](SAGA_supporting_files/Steps.bat) that processes all the relevant SAGA tools needed for hydrology and
channel network analysis. 

### Additional step for study region with ocean or large lakes
The region of Bali and Lombok contains large amount of ocean surface, which may make it impossible for SAGA to resolve the flow direction
algorithm. To fix this problem, I reclassified all elevation of zero or below to nodata by using the tool **Reclassify Grid Values** (Grid->
Tools->Reclassify Grid Values).

## Analysis

### Classification of .NUM files
For my analysis of error, I need to visualize the number grids of the .NUM file of ASTER and STRM. The ASTER and STRM have different value
meaning and categories according to the online documentation of [ASTER](https://lpdaac.usgs.gov/documents/434/ASTGTM_User_Guide_V3.pdf) 
and [SRTM](https://lpdaac.usgs.gov/products/srtmgl1v003/).

**Classified ASTER .NUM file**:
![Aster](https://user-images.githubusercontent.com/25497706/66451371-257d3780-ea2a-11e9-9882-8f7df3513e9e.png)
![Aster_legend](https://user-images.githubusercontent.com/25497706/66451372-2615ce00-ea2a-11e9-9d9c-1ef1a4113db0.png)

**Classified STRM .NUM file**:
![SRTM](https://user-images.githubusercontent.com/25497706/66451472-93c1fa00-ea2a-11e9-9445-fbf840821d3e.png)
![SRTM_legend](https://user-images.githubusercontent.com/25497706/66451474-97558100-ea2a-11e9-8611-b2b69f453060.png)

### Grid difference
Using the **Grid Difference** (Grid->Calculus) tool, I can subtract one set of input from the other. I have used the tool twice to calculate
the grid difference between the elevation model of ASTER from that of SRTM, and the Flow accumulation of ASTER data from that of SRTM.

**Elevation Model(ASTER-SRTM)**:
![difference_elevationmodels](https://user-images.githubusercontent.com/25497706/66451820-1303fd80-ea2c-11e9-9ea2-a2085e3cf21f.png)
![difference_elevationmodels_legend](https://user-images.githubusercontent.com/25497706/66451822-14352a80-ea2c-11e9-803a-c199212228e4.png)

**Flow accumulation(ASTER-SRTM)**:
![difference_flowaccumulation](https://user-images.githubusercontent.com/25497706/66452399-59f2f280-ea2e-11e9-8c9a-111392831dbb.png)
![difference_flowaccumulation_legend](https://user-images.githubusercontent.com/25497706/66452400-5b241f80-ea2e-11e9-93b5-dac1a773bf01.png)

### 3D models
**SRTM 3D Model**:
![SRTM_3D](https://user-images.githubusercontent.com/25497706/66452443-768f2a80-ea2e-11e9-8237-50009f46a5e9.png)

**ASTER 3D Model**:

![ASTER_3D](https://user-images.githubusercontent.com/25497706/66452444-77c05780-ea2e-11e9-9005-f504dc5e618d.png)

### Visualizing potential errors
I tried to use QGIS to help visualize the potential errors that I may encounter. 
#### 
According to the elevation model grid difference, Aster and SRTM data seem to be more consistent at higher elevation and steeper lands than at lower elevation and flat land. Moreover, there is a lack of sufficent data at extremely flat coastal areas, for example, in Southern Bali. However, ASTER seem to give a more detailed, consistent, and comprehensive data at flat regions than SRTM.

**Steep/High elevation region**
![High_elevation_comparison](https://user-images.githubusercontent.com/25497706/66488174-83863b00-ea7b-11e9-825c-1430262f3e60.png)

**Flat/Low elevation**
![Low elevation](https://user-images.githubusercontent.com/25497706/66488457-ebd51c80-ea7b-11e9-9ab7-1cf80355f151.png)

#### Water body
Both Aster and SRTM data seem to mass up when there is a water body, for example, at the crater lake. This may be caused by the fact that the program identify lakes as a piece of flat land. The program encountered here may be related to the problem that I had earlier with the ocean. For hydrology analysis, therefore, it may be best to identify these lake regions and convert them to nodata. Additionaly, the strange straight line pattern as seen across the crater lake may also be caused by the resampling code that I chose to use, which in this caseis bilinear interpolation. 
![Crater Lake](https://user-images.githubusercontent.com/25497706/66488626-38b8f300-ea7c-11e9-9d10-98831fd190aa.png)

#### Flow accumulation
From the flow accumulation Grid difference data, both ASTER and SRTM data seem to be more accurate when the flow accumulation is small than when the flow accumulation is large. This makes sense because a small mistake may accumulate to a large one as the flows accumulate.

