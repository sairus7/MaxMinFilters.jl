# to run the script, you should have these packages installed
using RollingFunctions
using Indicators
using MaxMinFilters
using Plots
using StatsPlots

y = randn(1000000)
windows = 10:10:100
t_rol = zeros(size(windows))
t_ind = zeros(size(windows))
t_mmf = zeros(size(windows))

# JIT compilation
mx1 = RollingFunctions.runmax(y, windows[1])
mx2 = Indicators.runmax(y, n=windows[1], cumulative = false)
mx3 = MaxMinFilters.movmax(y, windows[1])

for i in eachindex(windows)
    w = windows[i]

    #println("w=$w")

    #print("RollingFunctions:")
    t = @timed RollingFunctions.runmax(y, w)
    t_rol[i] = t[2]

    #print("Indicators:")
    t = @timed Indicators.runmax(y, n=w, cumulative = false)
    t_ind[i] = t[2]

    #print("MaxMinFilters:")
    t = @timed MaxMinFilters.movmax(y, w)
    t_mmf[i] = t[2]

end

ctg = repeat(["1 - MaxMinFilters . movmax", "2 - RollingFunctions . runmax", "3 - Indicators . runmax"], inner = length(windows))

bars = log10.(1000 * hcat(t_mmf, t_rol, t_ind))
xnames = repeat(collect(windows), outer = 3)

groupedbar(xnames, bars, group = ctg, xlabel = "Window lengths", ylabel = "Time, ms",
        title = "Moving maximum performance, array length = 1000000.", bar_width = 8,
        lw = 0, framestyle = :box)

yticks!(collect(0.0:0.5:2.5), "10^{" .* string.(collect(0.0:0.5:2.5)) .* "}")

# png("plot.png")
