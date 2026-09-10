"""
check_level(guidelines, df_wind, level, i)

    Checks which level was given in the input and saves the specific recommendation unter current.

    Arguments:
        guidelines: the DataFrame containing the guidelines.
        df_wind: the DataFrame containing the wind forecast.
        level: the given skill level (valid levels are "beginner", "intermediate", or "advanced")
        i: the row index determining the time that is currently checked.

    Returns:
        The recommendation based on skill level under current as a string.
"""
function check_level(guidelines, df_wind, level, i)

    current = nothing

    for j in 1:size(guidelines, 1)

        if guidelines."max_knots"[j] >= df_wind.windspeed_10m[i] >= guidelines."min_knots"[j]

            if level == "beginner"
                current = guidelines."beginner"[j]

            elseif level == "intermediate"
                current = guidelines."intermediate"[j]

            elseif level == "advanced"
                current = guidelines."advanced"[j]

            end
        end
    end

    return current

end

"""
check_windspeed(df_wind, guidelines, lb_wind, ub_wind, lb_sail, ub_sail, level)

    Determines if the wind forecast is out of generally surfable conditions, as well as suitable
    for the sail size determined by the recommended wind range.
    If it is suitable, it checks the given level and returns the skill level specific recommendation.

    Arguments:
        df_wind: the DataFrame containing the wind forecast.
        guidelines: the DataFrame containing the guidelines.
        lb_wind and ub_wind: the recommended wind range.
        lb_sail and ub_sail: the recommended sail size range.

    Returns:
        A vector containing the recommendations as strings.
"""
function check_windspeed(df_wind, guidelines, lb_wind, ub_wind, lb_sail, ub_sail, level)

    results_windspeed = String[]

    for i in 1:size(df_wind, 1)

        if df_wind."windspeed_10m"[i] < 4
            push!(results_windspeed, "Wind is too low for windsurfing, consider waiting for better conditions.")

        elseif df_wind."windspeed_10m"[i] >= 28
            push!(results_windspeed, "Wind is too strong for windsurfing, consider waiting for better conditions.")

        elseif 4 <= df_wind."windspeed_10m"[i] < lb_wind
            push!(results_windspeed, "Wind is too low for your sail size, consider using a bigger sail of 
            up to $(ub_sail) m² and check again.")

        elseif ub_wind < df_wind."windspeed_10m"[i] < 28
            push!(results_windspeed, "Wind is too strong for your sail size, consider using a smaller sail of 
            at least $(lb_sail) m² and check again.")

        else
            current = check_level(guidelines, df_wind, level, i)

            if current == "too low for your skill level" || current == "too strong for your skill level"
                push!(results_windspeed, "Wind is $(current), consider waiting for better conditions.")

            else
                push!(results_windspeed, "Wind is $(current) for windsurfing.")

            end
        end
    end

    return results_windspeed

end

"""
check_wind(bodyweight, sail_size, level)

    Pulls the forecast data via collect_wind_data function and the guidelines and ranges via check_bodyweight function.
    Then it first checks if the level input is valid before it continues.
    If it is valid, it checks if the wind forecast is siutable for the given input data.
    Collects the reommendations from check_windspeed function and adds them to the DataFrame.

    To use real forecast data, use the following line to collect the data through the WeatherReport.jl package.
    df_wind = collect_wind_data("Sankt Peter-Ording")

    For testing purposes, we use the test dataset from a CSV file.
    df_wind = CSV.read("data/test_wind_data.csv", DataFrame)

    Arguments:
        bodyweight: bodyweight in kg.
        sail_size: sail size in m².
        level: skill level as a string (valid entries are "beginner", "intermediate", or "advenced")

    Returns:
        The DataFrame containing the recommendations.
"""
function check_wind(bodyweight, sail_size, level)

    # df_wind = collect_wind_data("Sankt Peter-Ording")
    df_wind = CSV.read("data/test_wind_data.csv", DataFrame)

    guidelines, lb_wind, ub_wind, lb_sail, ub_sail = check_bodyweight(bodyweight, sail_size)

    df_results = DataFrame()
    df_results[!, :TIME] = df_wind.TIME
    df_results[!, :Windspeed] = df_wind.windspeed_10m

    if !(level in ["beginner", "intermediate", "advanced"])
        error("Please enter a valid skill level: beginner, intermediate, or advanced")
    end

    results_windspeed = check_windspeed(df_wind, guidelines, lb_wind, ub_wind, lb_sail, ub_sail, level)
    df_results[!, "recommendations"] = results_windspeed

    return df_results

end

# df_results = check_wind(72, 5, "intermediate")
# @df df_results plot(df_results.TIME, df_results.Windspeed,xlabel = "Time",ylabel = "Wind speed [kn]",label = "Wind speed")