using Pkg
Pkg.add("DataFrames")
Pkg.add("CSV")
using DataFrames
using CSV

# To use real forecast data, use the following line to collect the data through the WeatherReport.jl package.
# df_wind = collect_wind_data("Sankt Peter-Ording")

# For testing purposes, we use the test dataset from a CSV file.
df_wind = CSV.read("data/test_wind_data.csv", DataFrame)


function check_wind_sail(sails, sail_size, i, lb_wind, ub_wind, lb_sail, ub_sail)
    if !ismissing(sails."min_sail"[i]) && !ismissing(sails."max_sail"[i])
        if sails."min_sail"[i] <= sail_size <= sails."max_sail"[i]
            if sails."min_knots"[i] < lb_wind
                lb_wind = sails."min_knots"[i]
            end
            if sails."max_knots"[i] > ub_wind
                ub_wind = sails."max_knots"[i]
            end
        end
        if lb_sail > sails."min_sail"[i]
            lb_sail = sails."min_sail"[i]
        end
        if ub_sail < sails."max_sail"[i]
            ub_sail = sails."max_sail"[i]
        end
    end
    return lb_wind, ub_wind, lb_sail, ub_sail
end
