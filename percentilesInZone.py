import math
# grep -r "Transaction: house percentile =" | awk '{print $5}' > ../percentiles.txt

content = []
with open("all.txt", "r") as f:
    content = f.readlines()

values = []
correctZone = False
for line in content:
    if "Transaction: house.location = Oeiras" in line:
        correctZone = True
    elif correctZone and "Transaction: consumerSurplus = " in line:
        value = float(line[len("Transaction: consumerSurplus = "):-1])
        correctZone = False
        values.append(value)

values = sorted(values)
print(sum(values) / len(values))
print((values[math.ceil(len(values)/2)] + values[math.floor(len(values)/2)]) / 2)
