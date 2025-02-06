import math
# grep -r "Transaction: house percentile =" | awk '{print $5}' > ../percentiles.txt
# for i in {1..36}; do echo Step $i ; cat latest_run/transactions_logs/step_${i}.txt > all.txt ; python percentilesInZone.py ;done
content = []
with open("all.txt", "r") as f:
    content = f.readlines()

text = "Transaction: consumerSurplus = "
# text = "Transaction: bid to ask price ratio = "
# text = "Transaction: house percentile ="
# text = "Transaction: house.area ="
# text = "Transaction: pricePerm2 ="
values = []
correctZone = False
for line in content:
    if "Transaction: sellerId = " in line:
        correctZone = True
    elif correctZone and text in line:
        value = float(line[len(text):-1])
        correctZone = False
        values.append(value)

values = sorted(values)
print(sum(values) / len(values))
print((values[math.ceil(len(values)/2)] + values[math.floor(len(values)/2)]) / 2)
