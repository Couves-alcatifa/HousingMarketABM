cd update_values_inflation
pip install .
cd ..
time julia --threads 8 economy.jl
date
