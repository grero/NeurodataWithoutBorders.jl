using FileIO
import Base.write

function FileIO.load(file::File{DataFormat{:NWB}})::NWBData
	#TODO: Read the hdf5 file, iterating through each group and classifying the datasets in that group according to the identified neurodata_type
	#e.g. neurodata_type == TimeSeries indicate that the datasets in this groups describes a time series object
	file = HDF5.h5open(file.filename)
	if "acquisition" in names(file)
		g = file["acquisition"]
		if "timeseries" in names(g)
			gg = g["timeseries"]
			for ggg in gg
				_ancestry = read(ggg,"ancestry")
				#Check the last entry
				_datatype = _ancestry[end]
				_data = read(ggg["data"])
				if "timestamps" in names(ggg)
					_timestamps = read(ggg["timestamps"])
				elseif "start_time" in names(ggg) && "rate" in names(ggg)
					_start_time = read(ggg,"start_time")
					_rate = read(ggg, "rate")
					_timestamps = range(_start_time*u"s",(1/_rate)*u"s",size(_data,1))
				else
					warn("No timestanps found. Using dummy timestamps")
					_timestamps = range(1.0u"s", 1.0u"s", size(_data,1))
				end
				_help = read(ggg["help"])
				_resolution = read(ggg["resolution"])
				_electrode_idx = read(ggg["electrode_idx"])
				_name = read(ggg["name"])
				_unit = read(ggg["unit"])
				unit = eval(parse("1.0Unitful.$(_unit)"))
				if _datatype == "ElectricalSeries"
					return ElectricalSeries(map(x->x*unit,_data),_help, _resolution, _electrode_idx, _name, _timestamps)
				end
			end
		end
	end
end

function save(f::File{format"NWB"},data::NWBData)
	h5open(f.filename, "w") do s
		write(s, data)		
	end
end

function write(s::HDF5.DataFile, data::TimeSeries)
	_path = "/acquisition/timeseries/$(data.name)"
	dd = HDF5.d_create(s, "$(_path)/data", HDF5.datatype(eltype(first(data.data).val)), HDF5.dataspace(size(data.data)))
	for j in 1:size(data.data,2)
		for i in 1:size(data.data,1)
			dd[i,j] = data.data[i,j].val
		end
	end
	write(s, "$(_path)/name", data.name)
	write(s, "$(_path)/help", data.help)
	write(s, "$(_path)/resolution", data.resolution)
	write(s, "$(_path)/unit",string(unit(first(data.data))))
	write(s, "$(_path)/electrode_idx", data.electrode_idx)
	if typeof(data.timestamps) <: Range
		write(s, "$(_path)/start_time", first(data.timestamps).val)
		_rate = 1.0/(data.timestamps[2].val - data.timestamps[1].val)
		write(s, "$(_path)/rate", _rate)
	else
		write(s, "$(_path)/timestamps", data.timestamps)
	end
	write(s, "$(_path)/ancestry", ["TimeSeries", split(string(typeof(data).name),".")[end]])
end
