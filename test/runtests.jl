import NeurodataWithoutBorders
using FileIO
using Base.Test
using SIUnits
using SIUnits.ShortUnits


dir = tempdir()
fname = joinpath(dir, "test3.nwb")

B = rand(1000,10)mV
eldata = NeurodataWithoutBorders.ElectricalSeries(B, "test", 1.0, collect(1:10), "test3",NeurodataWithoutBorders.range(0.0s, (1/30000.0)s, size(B,1)))
NeurodataWithoutBorders.save(File(format"NWB",fname), eldata)
wdata = NeurodataWithoutBorders.load(File(format"NWB", fname))

#rm(fname)
@test eldata.data == wdata.data
@test eldata.help == wdata.help
@test eldata.timestamps == wdata.timestamps


