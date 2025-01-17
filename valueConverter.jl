# using Pkg
# Pkg.add("PyCall")
# using Pkg
# ENV["PYTHON"] = "/usr/bin/python"
# Pkg.build("PyCall")
using JSON
using Logging
using PyCall
# import Pkg; Pkg.add("JSON")

const VALUES_FILE = "values_updated_for_inflation.json"

function read_json(file::String)::Dict
    # check if file exists
    if !isfile(file)
        # original_year => original_month => current_year => current_month => value => updated_value
        return Dict(0 => Dict(0 => Dict(0 => Dict(0 => Dict(0.0 => 0.0)))))
    end
    open(file, "r") do f
        return JSON.parse(f)
    end
end

function write_json(file::String, data::Dict)
    open(file, "w") do f
        JSON.print(f, data)
    end
end

# original_year => original_month => current_year => current_month => value => updated_value
UPDATED_VALUES_DICT = read_json(VALUES_FILE)
update_values = pyimport("update_values_inflation")

const ORIGINAL_YEAR = 2021
const ORIGINAL_MONTH = 1
const CURRENT_YEAR = 2012
const CURRENT_MONTH = 1
# const CURRENT_YEAR = 2011
# const CURRENT_MONTH = 1

function adjust_value_to_inflation(value)
    return custom_adjust_value_to_inflation(value, ORIGINAL_YEAR, ORIGINAL_MONTH, CURRENT_YEAR, CURRENT_MONTH)
end

function custom_adjust_value_to_inflation(in_value, in_original_year, in_original_month, in_current_year, in_current_month)
    valueWasFound = true
    value = string(in_value)
    original_year = string(in_original_year)
    original_month = string(in_original_month)
    current_year = string(in_current_year)
    current_month = string(in_current_month)
    if !(original_year in keys(UPDATED_VALUES_DICT))
        valueWasFound = false
        UPDATED_VALUES_DICT[original_year] = Dict()
    end
    if !(original_month in keys(UPDATED_VALUES_DICT[original_year]))
        valueWasFound = false
        UPDATED_VALUES_DICT[original_year][original_month] = Dict()
    end
    if !(current_year in keys(UPDATED_VALUES_DICT[original_year][original_month]))
        valueWasFound = false
        UPDATED_VALUES_DICT[original_year][original_month][current_year] = Dict()
    end
    if !(current_month in keys(UPDATED_VALUES_DICT[original_year][original_month][current_year]))
        valueWasFound = false
        UPDATED_VALUES_DICT[original_year][original_month][current_year][current_month] = Dict()
    end
    if !(value in keys(UPDATED_VALUES_DICT[original_year][original_month][current_year][current_month]))
        valueWasFound = false
    end
    if !valueWasFound
        UPDATED_VALUES_DICT[original_year][original_month][current_year][current_month][value] = update_values.adjust_value(value, original_year, original_month, current_year, current_month) 
    end
    return UPDATED_VALUES_DICT[original_year][original_month][current_year][current_month][value]
end