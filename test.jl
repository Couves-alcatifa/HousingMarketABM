content = ""

file = open("logger.jl", "r")
content = read(file)

open("test.txt", "w") do file
    write(file, content)
end