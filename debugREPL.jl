using Agents
function model_step!(model)
    return
end

function agent_step!(agent, model)
    return
end

@multiagent :opt_speed struct MyMultiAgents(NoSpaceAgent)
    @subagent struct Household
        wealth::Float64
        age::Int64
        size::Int64
    end
end

model = StandardABM(MyMultiAgents; agent_step! = agent_step!, model_step! = model_step!)
add_agent!(Household, model, 1, 1, 1.0)
add_agent!(Household, model, 1, 1, 1.0)
add_agent!(Household, model, 1, 1, 1.0)
add_agent!(Household, model, 1, 1, 1.0)
add_agent!(Household, model, 1, 1, 1.0)
