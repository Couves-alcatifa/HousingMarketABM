function changeInterestRatesAndUnemployment(model)
    if CURRENT_YEAR == 2003
        from2003To2012(model)
    elseif CURRENT_YEAR == 2012
        from2012To2019(model)
    end
end

function from2003To2012(model)
    # considering start is in 2003
    if model.steps == 12
        # end of 2003
        model.unemploymentRate = 0.064
        model.bank.interestRate = 0.0383
    elseif model.steps == 24
        # end of 2004
        model.unemploymentRate = 0.077
        model.bank.interestRate = 0.0349
    elseif model.steps == 36
        # end of 2005
        model.unemploymentRate = 0.078
        model.bank.interestRate = 0.0338
    elseif model.steps == 48
        # end of 2006
        model.unemploymentRate = 0.081
        model.bank.interestRate = 0.0401
    elseif model.steps == 60
        # end of 2007
        model.unemploymentRate = 0.077
        model.bank.interestRate = 0.0480
    elseif model.steps == 72
        # end of 2008
        model.unemploymentRate = 0.096
        model.bank.interestRate = 0.0544
    elseif model.steps == 84
        # end of 2009
        model.unemploymentRate = 0.11
        model.bank.interestRate = 0.0273
    elseif model.steps == 96
        # end of 2010
        model.unemploymentRate = 0.129
        model.bank.interestRate = 0.0247
    elseif model.steps == 108
        # end of 2011
        model.unemploymentRate = 0.158
        model.bank.interestRate = 0.0377
    elseif model.steps == 120
        # end of 2012
        model.unemploymentRate = 0.165
        model.bank.interestRate = 0.0388
    end
end

function from2012To2019(model)
    # considering start is in 2012
    if model.steps == 12
        # end of 2012
        model.unemploymentRate = 0.158
        model.bank.interestRate =  0.0388
    elseif model.steps == 24
        # end of 2013
        model.unemploymentRate = 0.165
        model.bank.interestRate =  0.0324
    elseif model.steps == 36
        # end of 2014
        model.unemploymentRate = 0.141
        model.bank.interestRate =  0.0319
    elseif model.steps == 48
        # end of 2015
        model.unemploymentRate = 0.126
        model.bank.interestRate =  0.0238
    elseif model.steps == 60
        # end of 2016
        model.unemploymentRate = 0.112
        model.bank.interestRate =  0.0195
    elseif model.steps == 72
        # end of 2017
        model.unemploymentRate = 0.09
        model.bank.interestRate =  0.0165
    elseif model.steps == 84
        # end of 2018
        model.unemploymentRate = 0.071
        model.bank.interestRate =  0.0141
    elseif model.steps == 96
        # end of 2019
        model.unemploymentRate = 0.065
        model.bank.interestRate =  0.0122
    end
end
