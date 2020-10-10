SHELL=/bin/bash

.PHONY : ci
ci: check_version_mismatch shard.lock
	./ci

shard.lock: shard.yml
	shards update

.PHONY : check_version_mismatch
check_version_mismatch: shard.yml README.md
	diff -w -c <(grep version: README.md) <(grep '^version:' shard.yml)
