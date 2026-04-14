import json, re

with open("practice_exercises_en.json", encoding="utf-8") as f:
    data = json.load(f)

jp = re.compile(r'[\u3000-\u9fff\uff00-\uffef]')
ids = [
    'prac_ch03_03','prac_ch07_01','prac_ch38_01',
    'comp_oop_01','comp_oop_02','comp_oop_04',
    'comp_error_01','comp_error_03','comp_error_06',
    'comp_stdlib_01','comp_stdlib_05','comp_stdlib_06',
    'comp_coll_01','comp_coll_07',
    'comp_func_01','comp_func_03','comp_func_05','comp_func_07',
    'comp_dbweb_01','comp_conc_07',
    'comp_mod_01','comp_mod_02','comp_mod_03','comp_mod_06',
]

for ch in data.get('chapters', []):
    for ex in ch.get('exercises', []):
        eid = ex.get('id', '')
        if eid not in ids:
            continue
        for field in ['expectedOutput', 'solutionCode']:
            val = ex.get(field, '')
            if not jp.search(val):
                continue
            lines_with_jp = [l for l in val.split('\n') if jp.search(l)]
            print(f'=== {eid}.{field} ===')
            for l in lines_with_jp:
                print(f'  {repr(l)}')
            print()
