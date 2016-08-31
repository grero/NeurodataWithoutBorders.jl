using FileIO
import Base.write

function FileIO.load(file::File{DataFormat{:NWB}})
	#TODO: Read the hdf5 file, iterating through each group and classifying the datasets in that group according to the identified neurodata_type
	#e.g. neurodata_type == TimeSeries indicate that the datasets in this groups describes a time series object
	file = HDF5.h5open(file.filename)
	if "acquisition" in names(file)
		if "timeseries" in names(file["acquisition"])
			for g in names(file["acquisition"]["timeseries"])
				_data = read(file["acquisition"]["timeseries"][g]["data"])
				_timestamps = read(file["acquisition"]["timeseries"][g]["timestamps"])
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
	write(s, "$(_path)/resoluation", data.resolution)
	write(s, "$(_path)/unit",string(SIUnits.unit(first(data.data))))
	write(s, "$(_path)/electrode_idx", data.electrode_idx)
end

function read(s::HDF5.DataFile) 
end