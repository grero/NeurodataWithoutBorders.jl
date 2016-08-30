abstract Acquisition
abstract Analysis
abstract Epochs
abstract General
abstract Processing
abstract Stimulus
abstract TimeSeries <: Acquistion

typealias VoltageType SIUnits.SIQuantity{Float64, 2,1,-3,-1,0,0,0,0,0}

type ElectricalSeries <: TimeSeries
	data::Array{VoltageType,2}
	help::ASCIIString
	resolution::Float64
	electrode_idx::Array{Int64,1}
end


