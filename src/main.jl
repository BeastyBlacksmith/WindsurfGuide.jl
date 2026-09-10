using DataFrames
using CSV
using Dates
using HTTP
using JSON

include("get_forecast.jl")
include("collect_data.jl")
include("check_guidelines.jl")
include("check_wind.jl")

