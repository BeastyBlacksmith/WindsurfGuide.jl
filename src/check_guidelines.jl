"""
check_wind_sail(guidelines, sail_size, i, lb_wind, ub_wind, lb_sail, ub_sail)

    Checks if sail_size is within the guidelines for the given bodyweight defined by row i.
    If the sail size is within the guidelines, it sets the suitable windspeed range by updating ub_wind and lb_wind.
    Also the overall recommended sail size range for the given bodyweight is defined by lb_sail and ub_sail.

    Arguments:
        guidelines: DataFrame containing the guidelines.
        sail_size: selected sail size in m².
        i: row index of the guideline to be checked.
        lb_wind and ub_wind: lower and upper bound of the wind range.
        lb_sail and ub_sail: lower and upper bound of the sail size range.

    Returns:
        The ranges for wind speed and sail size.
"""
function check_wind_sail(guidelines, sail_size, i, lb_wind, ub_wind, lb_sail, ub_sail)

    if !ismissing(guidelines."min_sail"[i]) && !ismissing(guidelines."max_sail"[i])

        if guidelines."min_sail"[i] <= sail_size <= guidelines."max_sail"[i]

            if guidelines."min_knots"[i] < lb_wind
                lb_wind = guidelines."min_knots"[i]
            end

            if guidelines."max_knots"[i] > ub_wind
                ub_wind = guidelines."max_knots"[i]
            end

        end

        if lb_sail > guidelines."min_sail"[i]
            lb_sail = guidelines."min_sail"[i]
        end

        if ub_sail < guidelines."max_sail"[i]
            ub_sail = guidelines."max_sail"[i]
        end

    end

    return lb_wind, ub_wind, lb_sail, ub_sail

end

"""
check_bodyweight(bodyweight, sail_size)

    Determines the recommended wind and sail size ranges for a given bodyweight by using the check_wind_sail function.
    Checks all guideline rows that fit the given bodyweight.

    Arguments:
        bodyweight: bodyweight in kg.
        sail_size: sail size in m².

    Returns:
        The DataFrame containing the guidelines as well as the determined ranges for wind and sail size.
"""
function check_bodyweight(bodyweight, sail_size)

    guidelines = CSV.read(joinpath(data_dir, "guidelines.csv"), DataFrame, missingstring = "missing")
    lb_wind = Inf
    ub_wind = 0
    lb_sail = Inf
    ub_sail = 0

    for i in 1:size(guidelines, 1)

        if ismissing(guidelines."min_weight"[i])

            if bodyweight < guidelines."max_weight"[i]
                lb_wind, ub_wind, lb_sail, ub_sail = check_wind_sail(guidelines, sail_size, i, lb_wind, ub_wind, lb_sail, ub_sail)
            end

        elseif ismissing(guidelines."max_weight"[i])

            if guidelines."min_weight"[i] <= bodyweight
                lb_wind, ub_wind, lb_sail, ub_sail = check_wind_sail(guidelines, sail_size, i, lb_wind, ub_wind, lb_sail, ub_sail)
            end

        elseif guidelines."min_weight"[i] <= bodyweight < guidelines."max_weight"[i]
            lb_wind, ub_wind, lb_sail, ub_sail = check_wind_sail(guidelines, sail_size, i, lb_wind, ub_wind, lb_sail, ub_sail)
        end
    end

    return guidelines, lb_wind, ub_wind, lb_sail, ub_sail

end

"""
print_rec(bodyweight, sail_size)

    Prints a recommendation depending on if the sail size is too small, suitable, or too big for the given bodyweight.
"""
function print_rec(bodyweight, sail_size)

    guidelines, lb_wind, ub_wind, lb_sail, ub_sail = check_bodyweight(bodyweight, sail_size)

    if sail_size < lb_sail
        println("Your sail size is too small for your bodyweight. Please consider a sail size of at least $(lb_sail) m².")
    elseif sail_size > ub_sail
        println("Your sail size is too big for your bodyweight. Please consider a sail size of at most $(ub_sail) m².")
    else
        println("Your sail size is appropriate for your bodyweight. Your recommended wind range is between $(lb_wind) and $(ub_wind) knots.")
    end

end

