cd update_values_inflation
pip install .
cd ..
time julia --threads 1 economy.jl
date
