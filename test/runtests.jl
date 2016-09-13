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

qdata = NeurodataWithoutBorders.SpatialSeries([rand()*Unitful.cm for i in 1:1000, j in 1:2], "test", "test4", range(0.0*Unitful.s, (1.0/1000)*Unitful.s, 1000))
NeurodataWithoutBorders.save(File(format"NWB",fname), qdata)

wdata = NeurodataWithoutBorders.load(File(format"NWB", fname))

#rm(fname)
@test eldata.data == wdata[1].data
@test eldata.help == wdata[1].help
@test eldata.timestamps == wdata[1].timestamps

@test qdata.data == wdata[2].data
@test qdata.help == wdata[2].help
@test qdata.timestamps == wdata[2].timestamps


