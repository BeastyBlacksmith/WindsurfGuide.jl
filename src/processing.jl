using Pkg
Pkg.add("DataFrames")
Pkg.add("CSV")
using DataFrames
using CSV

# To use real forecast data, use the following line to collect the data through the WeatherReport.jl package.
# df_wind = collect_wind_data("Sankt Peter-Ording")

# For testing purposes, we use the test dataset from a CSV file.
df_wind = CSV.read("data/test_wind_data.csv", DataFrame)
