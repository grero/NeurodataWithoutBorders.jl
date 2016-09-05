import Base.parse, Base.range
abstract NWBData
abstract Acquisition <: NWBData
abstract Analysis <: NWBData
abstract Epochs <: NWBData
abstract General <: NWBData
abstract Processing <: NWBData
abstract Stimulus <: NWBData
abstract TimeSeries <: Acquisition

typealias VoltageType SIUnits.SIQuantity{Float64, 2,1,-3,-1,0,0,0,0,0}
typealias TimeRangeType SIUnits.SIRange{FloatRange{Float64},Float64,0,0,1,0,0,0,0,0,0} 
typealias TimeArrayType Array{SIUnits.SIQuantity{Float64,0,0,1,0,0,0,0,0,0},2}

range{T<:SIUnits.SIQuantity}(a::T, b::T, n::Integer) = a:b:(a+(n-1)*b)

type ElectricalSeries <: TimeSeries
	data::Array{VoltageType,2}
	help::ASCIIString
	resolution::Float64
	electrode_idx::Array{Int64,1}
	name::ASCIIString
	timestamps::Union{TimeRangeType, TimeArrayType}
end

function parse(::Type{SIUnits.SIUnit}, s::String)
	if s == "mV"
		return SIUnits.ShortUnits.mV
	end
end


