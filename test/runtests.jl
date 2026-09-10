using Test

@testset "directions" begin
    result = directions(270)

    @test result."dir"[2] == "crossshore"
    @test result."start"[4] == 247.5
    @test result."stop"[6] == 202.5
    @test_throws ErrorException directions(360)
    @test_throws ErrorException directions(-1)
end

@testset "check_direction" begin
    df_test1 = DataFrame(
        wind_direction_10m = [0, 90, 180, 270])
    df_test2 = DataFrame(
        wind_direction_10m = [337.5, 337.4, 337.6])

    result1 = check_direction(df_test1, 270, "beginner")
    result2 = check_direction(df_test2, 270, "beginner")

    @test result1[1] == "Crossshore wind, very good for all levels."
    @test result1[2] == "Offshore wind, consider waiting for better conditions."
    @test result1[3] == "Crossshore wind, very good for all levels."
    @test result1[4] == "Onshore wind, very good for your skill level."
    @test result2[1] == "Crossshore wind, very good for all levels."
    @test result2[2] == "Cross-onshore wind, very good for all levels."
    @test result2[3] == "Crossshore wind, very good for all levels."
end

@testset "check_gusts" begin
    df_test = DataFrame(
        windspeed_10m = [10, 10, 10],
        wind_gusts_10m = [17, 18, 19])

    result = check_gusts(df_test, "beginner")

    @test occursin("stable", result[1])
    @test occursin("too strong", result[2])
    @test occursin("too strong", result[3])
end