library(ncdf4)
library(PCICt)
library(rcdo)

era5pl <- "/home/user1/Documents/research/ensoceof/analysis/data/raw_data/era5.mon.mean.nc" 
era5sl <- "/home/user1/Documents/research/ensoceof/analysis/data/raw_data/era5.mon.mean.sl.nc"

file.copy("/home/user1/Documents/research/ensoceof/analysis/data/raw_data/nsidc_sea-ice.nc", "data/seaice.nc")
  


sic_projection <- "data/seaice.nc" |> 
  ncdf4::nc_open() |> 
  ncdf4::ncatt_get(varid = 0) |> 
  _$grid_mapping_proj4text
  
writeLines(sic_projection, "data/ice_projetion.txt")

erasst <- cdo_selname(era5sl, names = "sst") |> 
  cdo_remapbil("r144x72") |> 
  cdo_selyear(years = paste0(1980:2023, collapse = ",")) |> 
  cdo_execute(output = "data/era_sst.nc", options = "-L")



era5 <- cdo_merge(
  list(cdo_selname(era5pl, names = "z") |> 
         cdo_remapbil("r360x180"),
       cdo_selname(era5sl, names = "tp") |> 
         cdo_remapbil("r360x180"))
) |> 
  cdo_selyear(years = paste0(1980:2023, collapse = ",")) |> 
  cdo_execute(output = "data/era5_variables.nc", options = "-L -O")
 

cdo_topo(grid = "r360x180") |> 
  cdo_execute(output = "data/topo.nc", options = "-f nc -L")
