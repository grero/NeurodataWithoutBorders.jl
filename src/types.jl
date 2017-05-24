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
	help::String
	resolution::Float64
	electrode_idx::Array{Int64,1}
	name::String
  timestamps::Union{AbstractArray{S,1}, StepRange{S,S},Range{S}}
  rate::Unitful.Frequency{Float64}
  start_time::Unitful.Time{Float64}
end

function ElectricalSeries(data, help::String, resolution::Float64, electrode_idx::Array{Int64,1}, name::String, rate::Unitful.Frequency{Int64})
  timestamps = (0//1)u"s":(1//rate):(size(data,1)//rate)
  ElectricalSeries(data, help, resolution, electrode_idx, name, timestamps, float(rate),0.0u"s")
end

type SpikeEventSeries{T<:Unitful.Voltage, S<:Unitful.Time} <: AbstractElectricalSeries
	data::Array{T, 3}
	help::String
  name::String
	timestamps::Union{AbstractArray{S,1}, StepRange{S,S}}
end

function SpikeEventSeries{T<:Unitful.Voltage}(D::Array{T,2}, help, name, timestamps)
	wf = zeros(T, size(D,1), 1, size(D,2))
	wf[:,1,:] = D
	SpikeEventSeries(wf, help, name, timestamps)
end

type SpatialSeries{T<:Unitful.Length,S<:Unitful.Time} <: TimeSeries
	data::Array{T, 2}
	help::String
	name::String
	timestamps::Union{AbstractArray{S,1}, StepRange{S,S}}
end
