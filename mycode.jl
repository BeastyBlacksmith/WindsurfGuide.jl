using Pkg
Pkg.activate(".")
Pkg.develop(path="../WeatherReport.jl")
Pkg.add("DataFrames")
using WeatherReport
using DataFrames
include("mycode.jl")

function collect_wind_data(city)

    df_wind = DataFrame[]

    parameters = [
        "temperature_2m",
        "apparent_temperature",
        "windspeed_10m",
        "wind_direction_10m",
        "wind_gusts_10m"]

    for parameter in parameters
        df_data, location = WeatherReport.get_hourly_forecast(
                    WeatherReport.CityInput(
                    city, 
                    parameter, 1))

        if !isempty(df_data)
            if isempty(df_wind)
                df_wind = df_data
                rename!(df_data, Dict(:FORECAST => "$(parameter)"))
            else
                df_wind[!, parameter] = df_data[!, :FORECAST]
                rename!(df_data, Dict(:FORECAST => "$(parameter)"))
            end
        end
    end

    return df_wind

end

