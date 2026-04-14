import json, re

with open('practice_exercises_en.json', 'r') as f:
    data = json.load(f)

jp = re.compile(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]+[^\n]*')

for ch in data.get('chapters', []):
    for ex in ch.get('exercises', []):
        eid = ex['id']
        for field in ['solutionCode']:
            val = ex.get(field, '')
            if val and re.search(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]', val):
                print(f"=== {eid}.{field} ===")
                # Find lines with Japanese
                for line in val.split('\n'):
                    if re.search(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]', line):
                        print(f"  {line.strip()}")
                print()
