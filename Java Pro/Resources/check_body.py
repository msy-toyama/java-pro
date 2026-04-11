import json

with open('ch02_output_variables.json', 'r') as f:
    data = json.load(f)

for lesson in data.get('lessons', [])[:3]:
    for sec in lesson.get('sections', [])[:2]:
        body = sec.get('body', '')
        if body:
            title = lesson.get('title', '')
            stitle = sec.get('title', '')
            print(f'=== {title} / {stitle} ===')
            print(body[:400])
            print()
