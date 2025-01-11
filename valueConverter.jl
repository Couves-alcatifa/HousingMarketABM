# using Pkg
# Pkg.add("PyCall")
# using Pkg
# ENV["PYTHON"] = "/usr/bin/python"
# Pkg.build("PyCall")

using PyCall
update_values = pyimport("update_values_inflation")

const ORIGINAL_YEAR = 2021
const ORIGINAL_MONTH = 1
const CURRENT_YEAR = 2021
const CURRENT_MONTH = 1
# const CURRENT_YEAR = 2011
# const CURRENT_MONTH = 1
function adjust_value_to_inflation(value)
    return update_values.adjust_value(value, ORIGINAL_YEAR, ORIGINAL_MONTH, CURRENT_YEAR, CURRENT_MONTH)
end

function custom_adjust_value_to_inflation(value, original_year, original_month, current_year, current_month)
    return update_values.adjust_value(value, original_year, original_month, current_year, current_month)
end