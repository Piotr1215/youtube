# User vs AI Battle Exercises

## Exercises Overview

1. **JSON Formatting**: Convert Python dictionary to formatted JSON with proper indentation
2. **Phone Number Formatting**: Standardize various phone number formats to a consistent pattern
3. **Data Transformation**: Convert CSV product data to structured JSON format
4. **Code Organization**: Organize functions by category and sort alphabetically within each category
5. **Text Extraction**: Extract and format structured data from unstructured text

## Efficient Solutions for Humans

### 1. JSON Formatting
Most efficient approach: Use `jq` or Python's `json` module
```bash
# Using jq (first convert Python booleans to JSON format)
cat exercise | sed 's/True/true/g; s/False/false/g' | jq '.'

# Using Python
python3 -c "import json; data=open('exercise').read().replace('True','true').replace('False','false'); print(json.dumps(json.loads(data[data.find('{'):]), indent=2))"
```

### 2. Phone Number Formatting
Regular expressions or simple find/replace work well:
```bash
# Using sed with simple pattern replacement
sed -E 's/\(555\) ([0-9]{3})-([0-9]{4})/555-\1-\2/g' exercise | 
sed -E 's/\(555\)([0-9]{3})-([0-9]{4})/555-\1-\2/g' |
sed -E 's/555\.([0-9]{3})\.([0-9]{4})/555-\1-\2/g' |
sed -E 's/555 ([0-9]{3}) ([0-9]{4})/555-\1-\2/g' |
sed -E 's/555([0-9]{3})([0-9]{4})/555-\1-\2/g'
```

### 3. Data Transformation
Converting CSV to JSON:
```bash
# Using Miller (mlr) - most elegant solution
mlr --icsv --ojson --jvstack cat exercise

# Using csvkit
csvjson --no-inference exercise | python3 -m json.tool

# Using Python one-liner
python3 -c '
import csv, json
result = []
with open("exercise") as f:
    reader = csv.DictReader(f)
    for row in reader:
        # Convert numeric fields to numbers
        result.append({
            "product_id": int(row["product_id"]),
            "product_name": row["product_name"],
            "price_usd": float(row["price_usd"]),
            "stock_count": int(row["stock_count"]),
            "category": row["category"],
            "status": row["status"]
        })
print(json.dumps(result, indent=2))
'
```

### 4. Code Organization
This requires careful analysis and possibly multiple operations:
```bash
# First, identify all categories
grep -E "/\* [A-Z]+ \*/" exercise

# Extract functions by category
grep -A 10 "ADMIN FUNCTIONS" exercise | grep "function" | sort

# Using Vim with global commands
:g/\/\* ADMIN FUNCTIONS \*\//,/\/\* /m0
:g/function \w\+/,/^}$/sort /function \zs\w\+/
```

### 5. Text Extraction
Extract structured data with grep, awk, and sed:
```bash
# Extract headers
grep -E "^#" exercise | sed 's/^# //'

# Extract key fields with multiple patterns
grep -E "^(Date|Location|Sprint Goal):" exercise | sed 's/^[ \t]*//'

# Combine multiple commands for complex extraction
grep -E "^## " exercise | sed 's/^## //' | while read section; do
  echo "[$section]"
  grep -A 5 "^## $section" exercise | grep -v "^##" | grep -v "^--"
  echo
done
```

Remember that tools like `jq`, `sed`, `awk`, and Vim macros can dramatically speed up these tasks compared to manual editing.
