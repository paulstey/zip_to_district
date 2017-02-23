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
zip2[:district] = map(x -> string("d", x), zip2[:Congressional_District])
zipdata[:district2] = map(x -> !isna(x) && 
                          x == "atlarge" ? "d1" : x, zipdata[:district])

# dictionary to map state num (FIPS) to state
states_dict = Dict([Pair(states[i, :fips_num], states[i, :state]) for i in 1:nrow(states)])

# Start out output dataframe 
df1 = DataFrame()
df1[:zip] = unique(vcat(zip2[:zipcode], zipdata[:zip])) 


function get_districts(dat, zipdata, zip2)
    res = DataFrame()
    res[:zip] = dat[:zip]
    n = size(res, 1)

    res[:district] = repeat("", n)

    for i = 1:n 
        println(i)
        indcs1 = find(zip2[:zipcode] .== res[i, :zip])
        if length(indcs1) > 1
            districts = "[" 
            for idx in indcs1 
                districts *= string("\"", zip2[idx, :district], "\",")
            end
            districts = districts[1:(end-2)] * "\"]"
            res[i, :district] = districts 
        
        elseif length(indcs1) == 1
            res[i, :district] = zip2[indcs1[1], :district]
        
        elseif length(indcs1) == 0
            idx = find(zipdata[:zip] .== res[i, :zip])
            

            if length(idx) ≠ 1 
                error("zipdata found $(length(idx)) matches for $(res[i, :zip])")
            else 
                idx = first(idx)
                res[i, :district] = zipdata[idx, :district2]
            end 
        end 
    end 
    res 
end 


@time df2 = get_districts(df1, zipdata, zip2)

df3 = join(df2, zipdata, on = :zip, kind = :left)

writetable("zip_and_district.csv", df3[:, [:zip, :district, :state]])






