using Dates
using Printf
LOG_FILE = "logs/NHH_$(NUMBER_OF_HOUSEHOLDS)_NSTEPS_$(NUMBER_OF_STEPS)_$(Dates.format(now(), "yyyy_mm_dd_THH_MM")).log"

# function LOG_INFO(msg)
#     return Meta.parse("""
#     open(LOG_FILE, "a") do file
#         write(file, Dates.format(now(), "yyyy_mm_dd_THH:MM:SS - ") * string(@__FILE__) * ":" *  string(@__LINE__) * " " * "$(msg)" * "\\n")
#     end
#     """)
# end

function LOG_INFO(msg)
    open(LOG_FILE, "a") do file
        write(file, "$(Dates.format(now(), "yyyy_mm_dd_THH:MM:SS - ")) $(msg)\n")
    end
end

# # Create a simple logger
# logger = SimpleLogger(io)

# # Set the global logger to logger
# global_logger(logger)
# @info("a global log message")
