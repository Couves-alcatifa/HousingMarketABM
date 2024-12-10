import math
# grep -r "Transaction: house percentile =" | awk '{print $5}' > ../percentiles.txt

content = []
with open("percentiles.txt", "r") as f:
    content = f.readlines()

values = []
for line in content:
    value = int(line[:-1])
    values.append(value)

values = sorted(values)
print(sum(values) / len(values))
print((values[math.ceil(len(values)/2)] + values[math.floor(len(values)/2)]) / 2)
