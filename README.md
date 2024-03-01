# BalanceAlgorithm

A set of files from [Teiserver](https://github.com/beyond-all-reason/teiserver) for testing balance algorithm changes without needing to have a whole server testing setup.

The purpose is to enable ideas for balance algorithms to be better tested and investigated by those interested in doing so. It provides a better place for implementation ideas to be discussed and tracked compared to discord and will make for an easier way to extend testing of ideas in a uniform way.

## Installation
You will need to install [Elixir](https://elixir-lang.org/).

```
mix deps.get
mix test
```

## Usage

#### Tests
We can use unit tests to ensure implementations of each algorithm produce the output expected, it also allows us to change internal details and ensure the algorithms as a whole are unaffected. We can run the tests with `mix test`. Tests are located in the [test] folder.

#### Mocked database calls
Currently the split one chevs algo requires users' chev ranks. This is currently a mock rather than a real database call. The mock will treat users with id less than 5 as chev rank 0.
