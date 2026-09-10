# These were copied from the WeatherReport.jl Package and slightly adjusted to
# support forecasts for wind direction and gusts. Also, the city name correction
# function was disabled in fetch_lat_long since it does not correctly work for
# city names in other languages than english.

# set thr url for pulling the forecast data
const URL_FORECAST = "https://api.open-meteo.com/v1/forecast"

# set the supported parameters
const HOURLY_FORECAST = ["temperature_2m",
                        "apparent_temperature",
                        "rain",
                        "snowfall",
                        "relativehumidity_2m",
                        "windspeed_10m",
                        "wind_direction_10m", # added
                        "wind_gusts_10m", # added
                        "shortwave_radiation"
                        ]
       
mutable struct CityInput
    city::String
    forecast_type::String
    i_row::Int64
end

struct GeogCoord
    latitude::Float64
    longitude::Float64
    timezone::String
end

# read the csv database into dataframe format
function csv_to_df(path::String)

    df_cities = DataFrame()

    try
        df_cities = CSV.read(path, DataFrame)
    catch
        error("Unable to load cities database, check if $(path) is valid!")
    end

    return df_cities

end

# set the database of cities with their coordinates
const DF_CITIES = csv_to_df(joinpath(@__DIR__,
                           "..",
                           "data",
                           "cities500_lat_long.csv"))

# find the coordinates for the input city
function fetch_lat_long(city::String, i_row::Int64)

    # city = fix_input_name(city) # commented out since it doesnt work for non-english city names

    df_city = filter(row -> ~ismissing(row.CITY) &&
            row.CITY == city, DF_CITIES)

    if nrow(df_city) > 1
        @info "More than one match found, showing report for location in row $(i_row)."
        @info "You can select another location by its row index."
        "$(println(df_city))"
    end

    lat, long = 0, 0
    timezone = ""

    if isempty(df_city)

        # Find closest match to inform the user
        all_valid_cities = filter(x -> ~ismissing(x), DF_CITIES.CITY)
        found_match = closest_match(city, all_valid_cities)

        # Add lines to highlight the message
        println("------------------------------------------------")
        @info("$(city) not found, did you mean $(found_match[1])?")
        println("------------------------------------------------")

        # Better to throw an error and let the user select the closest match if
        # needed
        error("Coordinates for city not found!")
    else
        lat = df_city[!, :LATITUDE][i_row]
        long = df_city[!, :LONGITUDE][i_row]
        timezone = df_city[!, :TIMEZONE][i_row]
    end

    return GeogCoord(lat, long, timezone)

end

# get the url for the given forecast type
function get_url(forecast_type::String, hist::Bool=false)

    url = ""

    if forecast_type in HOURLY_FORECAST
        hist ? url = URL_HIST : url = URL_FORECAST
    else
        error("Forecast type is currently not supported!")
    end

    return url

end

# pull the data from the open meteo database
function get_api_response(params::String, url::String)

    OM_request = nothing

    try
        OM_request = HTTP.request("GET", url * params; verbose = 0, retries = 2)
    catch e
        if isa(e, HTTP.ExceptionRequest.StatusError)
            error("Check if the input is valid")
        else
            error("Could not fetch data, try again later!")
        end
    end

	response_text = String(OM_request.body)
    response_dict = JSON.parse(response_text)

	return response_dict

end

# turn the response dictionary into a dataframe with the hourly forecast data
function dict_to_df(response_dict::Dict, forecast_type::String)

    TIME = map(x -> parse(DateTime, x), response_dict["hourly"]["time"])

    # Filter out absent data marked as nothing
    all_values = response_dict["hourly"][forecast_type]
    valid_values = filter(x -> !isnothing(x), all_values)
    FORECAST = map(x -> convert(Float64, x), valid_values)

    # Make sure both columns are of equal length
    TIME = TIME[1:length(FORECAST)]
    df_hourly = DataFrame(TIME=TIME, FORECAST=FORECAST)

    return df_hourly

end

# get the hourly forecast by putting in a city, returns the corresponding dataframe
function get_hourly_forecast(input::CityInput)

    location = fetch_lat_long(input.city, input.i_row)
    lat      = location.latitude
    long     = location.longitude
    forecast_type = input.forecast_type

    url = get_url(forecast_type)
    params = "?latitude=$(lat)&longitude=$(long)&hourly=$(forecast_type)"

    response_dict = get_api_response(params, url)

    df_hourly = dict_to_df(response_dict, forecast_type)

    return df_hourly, location

end