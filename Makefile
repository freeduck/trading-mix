.PHONY: test
test:
	tox

.PHONY: create-sqlite
create-sqlite:
	cd data;find . -name "ohlc-*" -exec jq -r '.["result"]|.["XXMRZEUR"][]|@csv' {} \; > alldata.csv




.PHONY:
test-mark-:
.PHONY: test-mark-%
test-mark-%:
	pipenv run tox -- -m $(*)
