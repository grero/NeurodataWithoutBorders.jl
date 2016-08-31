abstract NWBData
abstract Acquisition <: NWBData
abstract Analysis <: NWBData
abstract Epochs <: NWBData
abstract General <: NWBData
abstract Processing <: NWBData
abstract Stimulus <: NWBData
abstract TimeSeries <: Acquisition

typealias VoltageType SIUnits.SIQuantity{Float64, 2,1,-3,-1,0,0,0,0,0}

type ElectricalSeries <: TimeSeries
	data::Array{VoltageType,2}
	help::ASCIIString
	resolution::Float64
	electrode_idx::Array{Int64,1}
	name::ASCIIString
end


