# Automated tests

On every push to the `master` branch, the CI will use PyTest to 
execute all the tests in this folder. 


# Run tests manually

## Requirements

Before running the tests, make sure you do:

`pip install -r requirements.txt`

and 

`npm install -g snyk`

## Test

Make sure the following env vars are exported in your environment:
 - `NUVLA_DEV_APIKEY`
 - `NUVLA_DEV_APISECRET`
 - `SNYK_SIXSQCI_API_TOKEN`
 
 
Run:

```bash
pytest --cis -vv -x --html=report.html --self-contained-html 
```

Add `--no-linux` to the command above if you're not running on a Linux machine.

Also, for local tests, `--remote` is optional.

Use `pytest -h` for more help.
