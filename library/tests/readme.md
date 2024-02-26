# Tests

## Unit tests

Unit tests test a part of the required functionality of the library functions.

Other than sanity checks, that can be run with every invocation of a new session,
the unittests are only run when invocating `tests::runtests` or when running
the `bats` utility in the `${TOOLSET_LIBRARY_PATH}` directory.

The unit tests use the [bats
framework](https://bats-core.readthedocs.io/en/latest/usage.html) for performing
tests. In every test file the `toolset` initial library entrypoint should be sourced to
ensure the functions are loaded prior to running tests.

Not all functions can safely be tested: Scripts with exit functions or colored
output logging and scripts that call api's like the `aws::` and `k8s::`
functions are uncovered.
