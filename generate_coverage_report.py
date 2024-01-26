import json

with open('test-results.json') as f:
    results = json.load(f)
    with open('COVERAGE.md', 'a') as coverage_md:
        coverage_md.write("# Cobertura de testes\n")
        coverage_md.write("## Cobertura geral\n")
        coverage_md.write(f"{results['coverage']['lines']['percent']}%\n")
        coverage_md.write("## Resultados dos testes\n")
        for test in results['tests']:
            coverage_md.write(f"- {test['name']}: {test['status']}\n")
