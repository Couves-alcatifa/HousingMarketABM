LOG_FILE = "$(output_folder)/NHH_$(NUMBER_OF_HOUSEHOLDS)_NSTEPS_$(NUMBER_OF_STEPS)_$(Dates.format(now(), "yyyy_mm_dd_THH_MM")).log"
TRANSACTION_LOG_FILE(model) = "$output_folder/transactions_logs/step_$(model.steps).txt"

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

function TRANSACTION_LOG(msg, model)
    open(TRANSACTION_LOG_FILE(model), "a") do file
        write(file, content)
    end
end

# # Create a simple logger
# logger = SimpleLogger(io)

# # Set the global logger to logger
# global_logger(logger)
# @info("a global log message")
