# Global Digital Elevation Models
The purpose of the project is to learn how to find and download elevation models for developing countries and how to derive a variety of
terrain products from those models using SAGA. SAG is an open-source desktop GIS developed by German physical geographers and contains an
excellent suite of raster analysis tools. 

The goal is to get the channel network of the Mt. Kilimanjaro in northern Tanzania.

## Data Collection
Either data can be used for the lab:
- ASTER Global Digital Elevation Model, distribute by NASA EOSDIS Land Processes DAAC.
- NASA Shuttle Radar Topography Mission Global 1 arc second. 2013, distributed by NASA EOSDIS Land Processes DAAC.

I have decided to use the SRTM Global Digital Elevation Model.
The data is dowloaded from [earth data](https://earthdata.nasa.gov/).

## Data Mosaicking and Projection to correct UTM zone
The Mt. Kilimanjaro region covers two tiles named by the lower left coordinates: S03E037 and S04E037.Therefore, we have to mosaic the two tiles and project the grid to the correct UTM zone. The tool used to mosaic the two grids is **Mosaicking**(Grid->Tools), and the tool used to project the grid to the correct UTM zone is **UTM Projection(Grid)**(Projection->Proj.4).
![Mosaic](https://user-images.githubusercontent.com/25497706/65726998-7aad6680-e084-11e9-8837-2cf7d928a587.png)
![Mosaic_legend](https://user-images.githubusercontent.com/25497706/65727000-7bde9380-e084-11e9-8e5e-82cd04ffecc7.png)

## Hillshade
Then we create a hillshade grid of the region by using the **Analytical Hillshading Tool**(Terrain Analysis->Lighting, Visibility) in SAGA.

![hillshade](https://user-images.githubusercontent.com/25497706/65726784-e17e5000-e083-11e9-8d36-1e3704e23a2f.png)![hillshade_legend](https://user-images.githubusercontent.com/25497706/65726783-e0e5b980-e083-11e9-8afb-1443710456cf.png)!

## Sink Flow issue
In order to have a correct result, we have to detect sinks and determine flows through them, so that hydrological analysis doesn't get stuck in either real holes or holes created by data errors. The **Sink Drainage Route Detection**(Terrain Analysis->Preprocessing) tool results in a grid with data on which direction water should flow when it encounters sinks. 

![sink_route](https://user-images.githubusercontent.com/25497706/65726839-0bd00d80-e084-11e9-9064-2d666c44dc5e.png)![sink_route_legend](https://user-images.githubusercontent.com/25497706/65726841-0d013a80-e084-11e9-83ab-4dc36b890c0b.png)

To remove and fill sinks from the DEM, I run the **Sink Removal**(Terrain Analysis->Preprocessing) tool to get a new elevation model. 

![mosaic_no_sink](https://user-images.githubusercontent.com/25497706/65726865-1b4f5680-e084-11e9-834b-ff18230dcb71.png)
![mosaic_no_sink_legend](https://user-images.githubusercontent.com/25497706/65726868-1c808380-e084-11e9-976b-3b6cb79abc10.png)

## Flow accumulation
Then, I calculate the flow accumulation based on the new DEM file created using the **Flow Accumulation(Top_Down)**(Terrain Analysis->Hydrology).


![flow_accumulation](https://user-images.githubusercontent.com/25497706/65726913-3b7f1580-e084-11e9-85a7-83157dd360f6.png)![flow_accumulation_legend](https://user-images.githubusercontent.com/25497706/65726915-3cb04280-e084-11e9-94e6-1a229b5d7970.png)

## Channel Network
Finally, using the tool **Channel Network**(Terrain Analysis->Channels), I get a raster and vector version of the streams and rivers of Mt. Kilimanjaro. 

![channel_network](https://user-images.githubusercontent.com/25497706/65726947-52be0300-e084-11e9-9333-d8b671beeb90.png)
![channel_network_legend](https://user-images.githubusercontent.com/25497706/65726948-53569980-e084-11e9-99bb-8a8c83283c8a.png)


## Final result on the hillshade
![final_result](https://user-images.githubusercontent.com/25497706/65726965-623d4c00-e084-11e9-9e29-8a0c403d6cf5.png)
![final_result_legend](https://user-images.githubusercontent.com/25497706/65726966-623d4c00-e084-11e9-9e0e-4cb96aa0be72.png)

