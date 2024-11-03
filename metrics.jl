function sum_wealth(iter)
    start = time()
    next = iterate(iter)
    soma = 0
    while next !== nothing
        (i, state) = next
        if i == false
            next = iterate(iter, state)
            continue
        end
        # println(i)
        soma += i.wealth
        next = iterate(iter, state)
    end
    LOG_INFO("Metrics: sum_wealth took $(time() - start)")
    return soma
end

function money_distribution(iter)
    start = time()
    next = iterate(iter)
    distribution = []
    while next !== nothing
        (i, state) = next
        if i == false
            next = iterate(iter, state)
            continue
        end
        if i.wealth <= 1
            push!(distribution, 1.0)
        else
            push!(distribution, i.wealth)
        end
        next = iterate(iter, state)
    end
    result = sort(distribution)
    LOG_INFO("Metrics: money_distribution took $(time() - start)")
    return result
end

function wealth_distribution(iter)
    start = time()
    next = iterate(iter)
    distribution = []
    # NOTE: if the iteration is taking to long we can try to collect
    # only the wealth,age etc... instead of the whole household
    while next !== nothing
        (i, state) = next
        if i == false
            next = iterate(iter, state)
            continue
        end
        if i.wealth + i.wealthInHouses <= 1
            push!(distribution, 1.0)
        else
            push!(distribution, i.wealth + i.wealthInHouses)
        end
        next = iterate(iter, state)
    end
    result = sort(distribution)
    LOG_INFO("Metrics: wealth_distribution took $(time() - start)")
    return result
end

function size_distribution(iter)
    start = time()
    next = iterate(iter)
    distribution = []
    while next !== nothing
        (i, state) = next
        if i == false
            next = iterate(iter, state)
            continue
        end
        push!(distribution, i.size)
        next = iterate(iter, state)
    end
    result = sort(distribution)
    LOG_INFO("Metrics: size_distribution took $(time() - start)")
    return result
end

function age_distribution(iter)
    start = time()
    next = iterate(iter)
    distribution = []
    while next !== nothing
        (i, state) = next
        if i == false
            next = iterate(iter, state)
            continue
        end
        push!(distribution, i.age)
        next = iterate(iter, state)
    end
    result = sort(distribution)
    LOG_INFO("Metrics: age_distribution took $(time() - start)")
    return result
end

function sum_houses(iter)
    next = iterate(iter)
    soma = 0
    while next !== nothing
        (i, state) = next
        if i == false
            next = iterate(iter, state)
            continue
        end
        # println(i)
        soma += length(i.houses)
        next = iterate(iter, state)
    end
    return soma
end

function calculate_prices_in_supply(model)
    soma = 0.0
    if length(model.houseMarket.supply) == 0
        return 0.0
    end
    for i in 1:length(model.houseMarket.supply)
        soma += model.houseMarket.supply[i].price / model.houseMarket.supply[i].house.area
    end
    return soma / length(model.houseMarket.supply)
end

function calculate_houses_prices_perm2(model)
    soma = 0.0
    if length(model.transactions) == 1
        return 1500.0
    end
    for i in 1:length(model.transactions)
        soma += model.transactions[i].price / model.transactions[i].area
    end
    return soma / length(model.transactions)
end 


function household(a)
    if isHousehold(a)
        return a
    end
    return false
end

function subsidiesPaid(model)
    res = copy(model.subsidiesPaid)
    model.subsidiesPaid = 0.0
    return res
end 
function ivaCollected(model)
    res = copy(model.ivaCollected)
    model.ivaCollected = 0.0
    return res
end 
function irsCollected(model)
    res = copy(model.irsCollected)
    model.irsCollected = 0.0
    return res
end 
function companyServicesPaid(model)
    res = copy(model.companyServicesPaid)
    model.companyServicesPaid = 0.0
    return res
end 
function inheritagesFlow(model)
    res = copy(model.inheritagesFlow)
    model.inheritagesFlow = 0.0
    return res
end 
function constructionLabor(model)
    res = copy(model.constructionLabor)
    model.constructionLabor = 0.0
    return res
end 
function rawSalariesPaid(model)
    res = copy(model.rawSalariesPaid)
    model.rawSalariesPaid = 0.0
    return res
end 
function liquidSalariesReceived(model)
    res = copy(model.liquidSalariesReceived)
    model.liquidSalariesReceived = 0.0
    return res
end 
function expensesReceived(model)
    res = copy(model.expensesReceived)
    model.expensesReceived = 0.0
    return res
end 

number_of_houses_per_region(model) = Dict(location => length(model.houses[location]) for location in instances(HouseLocation))
number_of_houses_built_per_region(model) = Dict(location => Dict(size_interval => length(model.housesBuiltPerRegion[location][size_interval]) for size_interval in instances(SizeInterval)) for location in instances(HouseLocation))
function transactions_per_region(model)
    d = Dict()
    for location in instances(HouseLocation)
        if length(model.transactions_per_region[location]) != 0
            d[location] = last(model.transactions_per_region[location])
        else
            d[location] = Transaction[]
        end
    end
    return d
end

function rents_per_region(model)
    d = Dict()
    for location in instances(HouseLocation)
        if length(model.rents_per_region[location]) != 0
            d[location] = last(model.rents_per_region[location])
        else
            d[location] = Transaction[]
        end
    end
    return d
end
company(a) = kindof(a) == :Company

isHousehold(a) = kindof(a) == :Household
isHouseholdHomeOwner(a) = isHousehold(a) && length(a.houses) > 0
isHouseholdTenant(a) = isHousehold(a) && a.contractAsTenant != Nothing
isHouseholdLandlord(a) = isHousehold(a) && length(a.contractsAsLandlord) > 0
isHouseholdMultipleHomeOwner(a) = isHousehold(a) && length(a.houses) > 1
subsidyRate(model) = model.government.subsidyRate
irs(model) = model.government.irs
vat(model) = model.government.vat
salaryRate(model) = model.salary_multiplier

# bucket_1(model) = mean(model.buckets[smaller_than_50])
# bucket_2(model) = mean(model.buckets[smaller_than_90])
# bucket_3(model) = mean(model.buckets[smaller_than_120])
# bucket_4(model) = mean(model.buckets[bigger_than_120])

count_supply(model) = length(model.houseMarket.supply)
gov_wealth(model) = model.government.wealth
company_wealth(model) = model.company_wealth
bank_wealth(model) = model.bank.wealth
construction_wealth(model) = model.construction_sector.wealth
supply_volume(model) = copy(model.supply_size)
demand_volume(model) = copy(model.demand_size)

function newly_built_houses_for_sale(model)
    houses = House[]
    for supply in model.houseMarket.supply
        if supply.sellerId == -1
            push!(houses, supply.house)
        end
    end
    return houses
end

function houses_for_sale(model)
    houses = House[]
    for supply in model.houseMarket.supply
        push!(houses, supply.house)
    end
    return houses
end

supply_per_bucket(model) = deepcopy(model.supplyPerBucket)
demand_per_bucket(model) = deepcopy(model.demandPerBucket)

mortgages_per_step(model) = copy(model.mortgagesInStep)
function contractRents(model)
    rents = Dict(location => Float64[] for location in instances(HouseLocation))
    for household in allagents(model)
        if household.contractAsTenant == Nothing
            continue
        end
        contract = household.contractAsTenant
        house = contract.house
        push!(rents[house.location], contract.monthlyPayment / house.area)
    end
    res = Dict(location => 0.0 for location in instances(HouseLocation))
    for location in instances(HouseLocation)
        if length(rents[location]) != 0
            res[location] = mean(rents[location])
        end
    end
    return res
end

function births(model)
    res = copy(model.births)
    model.births = 0
    return res
end
function breakups(model)
    res = copy(model.breakups)
    model.breakups = 0
    return res
end
function deaths(model)
    res = copy(model.deaths)
    model.deaths = 0
    return res
end
function children_leaving_home(model)
    res = copy(model.children_leaving_home)
    model.children_leaving_home = 0
    return res
end

n_of_households(model) = nagents(model)