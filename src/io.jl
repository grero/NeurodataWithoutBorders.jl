using FileIO
import FileIO.load


function FileIO.load(file::File{DataFormat{:NBW}})
	#TODO: Read the hdf5 file, iterating through each group and classifying the datasets in that group according to the identified neurodata_type
	#e.g. neurodata_type == TimeSeries indicate that the datasets in this groups describes a time series object
end
