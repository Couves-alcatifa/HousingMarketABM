# grep -r "Transaction: house percentile =" | awk '{print $5}' > ../percentiles.txt
content = []
with open("percentiles.txt", "r") as f:
    content = f.readlines()

values = []
for line in content:
    value = int(line[:-1])
    values.append(value)

print(values / len(values))
