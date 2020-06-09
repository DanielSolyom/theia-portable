.PHONY: build
build:
	docker build . --tag theia-portable

.PHONY: sh
sh:
	docker run --rm -it theia-portable /bin/bash
