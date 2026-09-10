"""
collect_wind_data(city)

    Collects the hourly wind forecast data for multiple parameters in one DataFrame.
    The wanted parameters can be set in the parameters vector. Then, for each parameter
    the data is pulled through the get_hourly_forecast function and stored in a DataFrame.
    Converts km/h into knots for further usage of the data.

    Arguments:
        city: Input city name as a string ("Mycity"). Check for correct spelling!

    Returns:
        The DataFrame containing all the forecasts.
"""
function collect_wind_data(city)

    df_wind = DataFrame()

    parameters = [
        "temperature_2m",
        "apparent_temperature",
        "windspeed_10m",
        "wind_gusts_10m",
        "wind_direction_10m"]

    for parameter in parameters

        df_data, location = get_hourly_forecast(CityInput(city, parameter, 1))

        # collect the hourly data in a data frame
        if !isempty(df_data)
            if isempty(df_wind)
                df_wind = df_data
                rename!(df_data, Dict(:FORECAST => "$(parameter)"))
            else
                df_wind[!, parameter] = df_data[!, :FORECAST]
                rename!(df_data, Dict(:FORECAST => "$(parameter)"))
            end
        end

        # convert from km/h to knots
        if parameter == "windspeed_10m" || parameter == "wind_gusts_10m"
            df_wind[!, parameter] = round.(df_wind[!, parameter] * 0.5399568, digits = 1)
        end
    end

    return df_wind

end

# df_wind = collect_wind_data("Sankt Peter-Ording")
# this dataframe was saved to CSV on 2026-09-04 for further usage as a test dataset.