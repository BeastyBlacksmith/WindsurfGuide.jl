
function collect_wind_data(city)

    df_wind = DataFrame[]

    parameters = [
        "temperature_2m",
        "apparent_temperature",
        "windspeed_10m",
        "wind_gusts_10m",
        "wind_direction_10m"]

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

        if parameter == "windspeed_10m" || parameter == "wind_gusts_10m"
            df_wind[!, parameter] = round.(df_wind[!, parameter] * 0.5399568, digits = 1) # Umrechnung von km/h in Knoten
        end

    end

    return df_wind

end

# df_wind = collect_wind_data("Sankt Peter-Ording")
# this dataframe was saved to CSV on 2026-09-04 for further usage as a test dataset.