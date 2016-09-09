import Base.parse, Base.range
abstract NWBData
abstract Acquisition <: NWBData
abstract Analysis <: NWBData
abstract Epochs <: NWBData
abstract General <: NWBData
abstract Processing <: NWBData
abstract Stimulus <: NWBData
abstract TimeSeries <: Acquisition
abstract AbstractElectricalSeries <: TimeSeries

type ElectricalSeries{T<:Unitful.Voltage,S<:Unitful.Time} <: AbstractElectricalSeries
	data::Array{T,2}
	help::ASCIIString
	resolution::Float64
	electrode_idx::Array{Int64,1}
	name::ASCIIString
	timestamps::Union{AbstractArray{S,1}, StepRange{S,S}}
end

type SpikeEventSeries{T<:Unitful.Voltage} <: AbstractElectricalSeries
	data::Array{T, 3}
end

type SpatialSeries{T<:Unitful.Length,S<:Unitful.Time} <: TimeSeries
	data::Array{T, 2}
	help::ASCIIString
	name::ASCIIString
	timestamps::Union{AbstractArray{S,1}, StepRange{S,S}}
end
