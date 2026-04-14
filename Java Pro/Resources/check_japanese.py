import json, re

with open('practice_exercises_en.json', 'r') as f:
    data = json.load(f)

jp = re.compile(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]')
issues = []

# Check setup guides
for g in data.get('setupGuide', []):
    for fld in ['title']:
        v = g.get(fld, '')
        if v and jp.search(v):
            issues.append(f'guide.{fld}: {v[:60]}')
    for step in g.get('steps', []):
        for fld in ['title', 'body', 'tip']:
            v = step.get(fld, '')
            if v and jp.search(v):
                issues.append(f'step {step["id"]}.{fld}: {v[:60]}')

# Check chapters
for ch in data.get('chapters', []):
    for fld in ['title', 'subtitle']:
        v = ch.get(fld, '')
        if v and jp.search(v):
            issues.append(f'ch {ch["id"]}.{fld}: {v[:60]}')
    for ex in ch.get('exercises', []):
        for fld in ['title', 'description', 'hint', 'solutionExplanation', 'solutionCode', 'expectedOutput']:
            v = ex.get(fld, '')
            if v and jp.search(v):
                sample = v[:80].replace('\n', ' ')
                issues.append(f'{ex["id"]}.{fld}: {sample}')

print(f'Total remaining Japanese across ALL fields: {len(issues)}')
for i in issues:
    print(i)
