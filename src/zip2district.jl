using DataFrames
using JSON

house = readtable("../houseDparty.csv")
zipdata = readtable("../zip_data2.csv")
zip2 = readtable("../zipToDistrict.csv")
states = readtable("../stateNumber.csv")

function stringify_zip(x)
    n = length(x)
    res = Array{String, 1}(n)
    for i = 1:n
        res[i] = "z" * lpad(string(x[i]), 5, "0")
    end 
    res 
end 

zip2[:zipcode] = stringify_zip(zip2[:ZCTA])

states_dict = Dict([Pair(states[i, :fips_num], states[i, :state]) for i in 1:nrow(states)])

