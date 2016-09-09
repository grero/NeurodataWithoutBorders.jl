import NeurodataWithoutBorders
using FileIO
using Base.Test
using Unitful


dir = tempdir()
fname = joinpath(dir, "test3.nwb")

B = Array(typeof(1.0u"mV"),1000,10)
for i in eachindex(B)
	B[i] = rand()*1.0u"mV"
end

eldata = NeurodataWithoutBorders.ElectricalSeries(B, "test", 1.0, collect(1:10), "test3",NeurodataWithoutBorders.range(0.0u"s", (1/30000.0)u"s", size(B,1)))
NeurodataWithoutBorders.save(File(format"NWB",fname), eldata)
wdata = NeurodataWithoutBorders.load(File(format"NWB", fname))

#rm(fname)
@test eldata.data == wdata.data
@test eldata.help == wdata.help
@test eldata.timestamps == wdata.timestamps


