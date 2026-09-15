# WindsurfGuide.jl

`WindsurfGuide.jl` is a package that provides windsurfing recommendations based on wind forecast data, the users bodyweight, sail size, and skill level. For usage is also needed the city name and the direction in which the coast is facing in degrees.

# Features

- it retrieves hourly forecast data and thus provides hourly recommendations.
- evaluated parameters are windspeed, gusts and direction relative to the coast.
- provides sail size recommendations based on the bodyweight and wind conditions.
- generates recommendations based on the users skill level.

# License

This project is licensed under the MIT License.

Parts of this project are based on code from the `WeatherReport.jl` package, which is also licensed under the MIT License.

# Installation

Clone the repository and activate the project environment:

```
julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()

using WindsurfGuide
```

# Usage

A windsurfing recommendation can be generated using:

`get_recs(bodyweight, sail_size, "level", "city", coast)`

For example

`get_recs(72, 5, "intermediate", "Barcelona", 130)`

where:
- `bodyweight`: user's bodyweight in kg.
- `sail_size`: the sail size in m².
- `"level"`: user's skill level (valid are `"beginner"`, `"intermediate"`, and `"advanced"`)
- `"city"`: the location. Note that only locations contained in `WindsurfGuide/data/cities500_lat_long.csv` can be found.
- `coast`: the direction the coast is facing in degrees.

# Data

The package uses weather forecast data contained from `"https://api.open-meteo.com/v1/forecast"`.
The guidelines are based on recommendations found on `"https://www.windcraftsurf.com/en/blog/beginners-guide-to-windsurfing"` and `"https://www.windup.live/blog/wind-speed-for-windsurfing/"`.

# Tests

The package contains tests in the `test/` directory. they can be run by:

```
using Pkg
Pkg.test()
```

or manually.
