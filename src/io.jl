using FileIO
import Base.write, Base.show

function read_data(gg::HDF5.HDF5Group)::NWBData
	_ancestry = read(gg,"ancestry")
	#Check the last entry
	_datatype = _ancestry[end]
	_data = read(gg["data"])
	if "timestamps" in names(gg)
		_timestamps = read(gg["timestamps"])
	elseif "start_time" in names(gg) && "rate" in names(gg)
		_start_time = read(gg,"start_time")
		_rate = read(gg, "rate")
		_timestamps = range(_start_time*u"s",(1/_rate)*u"s",size(_data,1))
	else
		warn("No timestanps found. Using dummy timestamps")
		_timestamps = range(1.0u"s", 1.0u"s", size(_data,1))
	end
	_help = read(gg["help"])
	_resolution = read(gg["resolution"])
	_name = read(gg["name"])
	_unit = read(gg["unit"])
	unit = eval(parse("1.0Unitful.$(_unit)"))
	if _datatype == "ElectricalSeries"
		_electrode_idx = read(gg["electrode_idx"])
		return ElectricalSeries(map(x->x*unit,_data),_help, _resolution, _electrode_idx, _name, _timestamps)
	elseif _datatype == "SpatialSeries"
		return SpatialSeries(map(x->x*unit,_data),_help, _name, _timestamps)
  elseif _datatype == "SpikeEventSeries"
    return SpikeEventSeries(map(x->x*unit, _data), _help, _name, _timestamps)
	end
end

function FileIO.load(file::File{DataFormat{:NWB}})::Array{NWBData,1}
	#TODO: Read the hdf5 file, iterating through each group and classifying the datasets in that group according to the identified neurodata_type
	#e.g. neurodata_type == TimeSeries indicate that the datasets in this groups describes a time series object
	file = HDF5.h5open(file.filename)
	rdata = Array(NWBData,0)
	if "acquisition" in names(file)
		g = file["acquisition"]
		if "timeseries" in names(g)
			gg = g["timeseries"]
			for ggg in gg
				_data = read_data(ggg)
				push!(rdata, _data)
			end
		end
	end
	return rdata
end

function save(f::File{format"NWB"},data::NWBData)
	if isfile(f.filename)
		_mode = "r+"
	else
		_mode ="w"
	end
	h5open(f.filename, _mode) do s
		write(s, data)
	end
end

function write(s::HDF5.DataFile, data::TimeSeries)
	_path = "/acquisition/timeseries/$(data.name)"
	write(s, "$(_path)/name", data.name)
	write(s, "$(_path)/help", data.help)
	if "resolution" in fieldnames(data)
		_resolution = data.resolution
	else
		_resolution = NaN
	end
	write(s, "$(_path)/resolution", _resolution)
	write(s, "$(_path)/unit",string(unit(first(data.data))))
	if typeof(data) <: ElectricalSeries
		write(s, "$(_path)/electrode_idx", data.electrode_idx)
	end
	if typeof(data.timestamps) <: Range
		write(s, "$(_path)/start_time", first(data.timestamps).val)
		_rate = 1.0/(data.timestamps[2].val - data.timestamps[1].val)
		write(s, "$(_path)/rate", _rate)
	else
		write(s, "$(_path)/timestamps", data.timestamps)
	end
	write(s, "$(_path)/ancestry", ["TimeSeries", split(string(typeof(data).name),".")[end]])
end

function write(s::HDF5.DataFile, data::SpikeEventSeries)
  invoke(write,(HDF5.DataFile, TimeSeries),s, data) #call write for the general TimeSries type first
	_path = "/acquisition/timeseries/$(data.name)"
	dd = HDF5.d_create(s, "$(_path)/data", HDF5.datatype(eltype(first(data.data).val)), HDF5.dataspace(size(data.data)))
	for j in 1:size(data.data,2)
		for i in 1:size(data.data,1)
      for k in 1:size(data.data,3)
        dd[i,j,k] = data.data[i,j,k].val
      end
		end
	end
end

function write(s::HDF5.DataFile, data::Union{ElectricalSeries,SpatialSeries})
  invoke(write,(HDF5.DataFile, TimeSeries), s,data) #call write for the general TimeSries type first
	_path = "/acquisition/timeseries/$(data.name)"
  #write the data
	dd = HDF5.d_create(s, "$(_path)/data", HDF5.datatype(eltype(first(data.data).val)), HDF5.dataspace(size(data.data)))
	for j in 1:size(data.data,2)
		for i in 1:size(data.data,1)
			dd[i,j] = data.data[i,j].val
		end
	end
end

function Base.show(io::IO, X::TimeSeries)
  print(io, "$(typeof(X).name) with data ")
  println(io, "$(join(map(string, size(X.data)), "x")) Array{$(unit(first(X.data))),$(ndims(X.data))}")
  nothing
end
