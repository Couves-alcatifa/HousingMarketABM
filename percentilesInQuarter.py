import math
import sys
# grep -r "Transaction: house percentile =" | awk '{print $5}' > ../percentiles.txt

quarter = int(sys.argv[1])
first_month = quarter * 3 - 2
last_month = quarter * 3

for month in range(first_month, last_month + 1):
    content = []
    with open("latest_run/transactions_logs/step_%s.txt" % month, "r") as f:
        content += f.readlines()

values = []
correctZone = False
for line in content:
    if "Transaction: house.location = Almada" in line:
        correctZone = True
    elif correctZone and "Transaction: house percentile = " in line:
        value = float(line[len("Transaction: house percentile = "):-1])
        correctZone = False
        values.append(value)

values = sorted(values)
print(sum(values) / len(values))
print((values[math.ceil(len(values)/2)] + values[math.floor(len(values)/2)]) / 2)
