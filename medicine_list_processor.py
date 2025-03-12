
import csv
import json
filename = "Medicine List for Pill Reminder App.csv"
fields = []
rows = []
with open(filename, 'r') as csvfile:
    csvreader = csv.reader(csvfile)
    fields = next(csvreader)
    for row in csvreader:
        rows.append(row)

    print("Total no. of rows: %d" % (csvreader.line_num))
print('Field names are:' + ', '.join(field for field in fields))

jsonCode = []

for row in rows:
    jsonCode.append(
        {
            "BN": row[1], # brandName = BN
            "GN": row[2], # genericName = GN
            "S": row[3], # strength = S
            "DD": row[4], # dosageDescription = DD
        }
    )

with open('Medicine List for Pill Reminder App.json', 'w') as f:
    json.dump(jsonCode, f)