using DataFrames
using JSON

house = readtable("../houseDparty.csv")
zipdata = readtable("../zip_data2.csv")
senate = readtable("../senate.csv")

function house2json(df)
    df_sorted = sort(df, cols = [:state, :district])
    res = Dict{String, Dict}()
    n = nrow(df_sorted)

    for i = 1:n
        st = df_sorted[i, :state]
        if !haskey(res, st)
            res[st] = Dict{String, Array{String,1}}()
        end
        name = df_sorted[i, :first] * " " * df_sorted[i, :last]

        # append suffix if it's not NA
        if !isna(df_sorted[i, :suffix])
            name *= df_sorted[i, :suffix]
        end
        dis = df_sorted[i, :district]
        res[st][dis] = [name, df_sorted[i, :party], df_sorted[i, :phone]]
    end
    return json(res)
end

# run our function
house_json_string = house2json(house)

# write to file
open("house.json", "w") do f
    write(f, house_json_string)
end



function zip2json(dat)
    n = nrow(dat)
    res = Dict{String, Array{String,1}}()
    for i = 1:n
        k = dat[i, :zip]
        res[k] = repeat([""], inner = 3)
        res[k][1] = dat[i, :state]
        res[k][2] = isna(dat[i, :state_num]) ? "" : string(dat[i, :state_num])
        res[k][2] = isna(dat[i, :district]) ? "" : dat[i, :district]
    end
    return json(res)
end

# run our function
zip_json_string = zip2json(zipdata)

# write to file
open("zipcode.json", "w") do f
    write(f, zip_json_string)
end


function senate2json(dat)
    dat_sorted = sort(dat, cols = [:state, :class])
    res = Dict{String, Dict}()
    n = nrow(dat_sorted)
    for i = 1:n
        st = dat_sorted[i, :state]
        if !haskey(res, st)
            res[st] = Dict{String, Array{String,1}}()
        end
        classnum = dat_sorted[i, :class]
        res[st][classnum] = [dat_sorted[i, :first_name], dat_sorted[i, :last_name], dat_sorted[i, :party], dat_sorted[i, :phone]]
    end
    json(res)
end



# run our function
senate_json_string = senate2json(senate)

# write to file
open("senate.json", "w") do f
    write(f, senate_json_string)
end
