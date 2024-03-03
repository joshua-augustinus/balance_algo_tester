# Introduction

This repo is a copy of [Teifion's Balance Tester](https://github.com/beyond-all-reason/balance_algorithm) but with some new balance algorithms.

# BalanceAlgorithm

A set of files from [Teiserver](https://github.com/beyond-all-reason/teiserver) for testing balance algorithm changes without needing to have a whole server testing setup.

The purpose is to enable ideas for balance algorithms to be better tested and investigated by those interested in doing so. It provides a better place for implementation ideas to be discussed and tracked compared to discord and will make for an easier way to extend testing of ideas in a uniform way.

## Installation
You will need to install [Elixir](https://elixir-lang.org/).

```
mix deps.get
mix test
```

To test a specific file, reference the file
```
mix test test/split_one_chevs_test.exs
```

### Installation Issues
If you have trouble calling mix deps.get, make sure you have a github ssh already set up. 

If you get this error
```
Host key verification failed.
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
```
Here's the solution: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints

## Usage

#### Tests
We can use unit tests to ensure implementations of each algorithm produce the output expected, it also allows us to change internal details and ensure the algorithms as a whole are unaffected. We can run the tests with `mix test`. Tests are located in the [test] folder.

#### Mocked database calls
Currently the split one chevs algo requires users' chev ranks. This is currently a mock rather than a real database call. The mock will treat users with id less than 5 as chev rank 0.
