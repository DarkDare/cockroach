#!/usr/bin/env bash
set -euxo pipefail

build_dir="$(dirname $0)"

# Ensure that no stale binary remains.
rm -f acceptance.test

"${build_dir}"/builder.sh make build
"${build_dir}"/builder.sh make install
"${build_dir}"/builder.sh go test -v -c -tags acceptance ./pkg/acceptance

# The log files that should be created by -l below can only
# be created if the parent directory already exists. Ensure
# that it exists before running the test.
mkdir -p artifacts/acceptance
export TMPDIR=$PWD/artifacts/acceptance

cd pkg/acceptance
../../acceptance.test -nodes 3 -l "$TMPDIR" -test.v -test.timeout 10m 2>&1 | tee "$TMPDIR/acceptance.log" | go-test-teamcity
