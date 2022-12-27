# bitcask-rb: A Log-Structured Hash Table for Fast Key/Value Data

[![Ruby](https://img.shields.io/badge/ruby-3.1.1-brightgreen)](https://www.ruby-lang.org/en/)
[![BDD](https://img.shields.io/badge/rspec-3.1-green)](https://rspec.info/)
[![Ruby Style Guide](https://img.shields.io/badge/code%20style-rubocop-red)](https://github.com/rubocop/rubocop)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/dineshgowda24/bitcask-rb/tree/main.svg?style=shield)](https://dl.circleci.com/status-badge/redirect/gh/dineshgowda24/bitcask-rb/tree/main)
[![codecov](https://codecov.io/gh/dineshgowda24/bitcask-rb/branch/main/graph/badge.svg?token=HY8IQSEKCA)](https://codecov.io/gh/dineshgowda24/bitcask-rb)
[![DeepSource](https://deepsource.io/gh/dineshgowda24/bitcask-rb.svg/?label=active+issues&token=aISrLFG-Rwka_9MMiZixX_NT)](https://deepsource.io/gh/dineshgowda24/bitcask-rb/?ref=repository-badge)

<img src="image.png"/>

Fast, Persistent key/value store based on [bitcask paper](https://riak.com/assets/bitcask-intro.pdf) written in Ruby.
An attempt to understand and build our persistent key/value store capable of storing data enormous than the RAM. This, in any way, is not intended for production. For simplicity, implementation has ignored a few specifications from the paper.

## Prerequisites

- Ruby
- bundler

## Setup

```shell
bundle install
```

## Usage

```ruby
db_store = Bitcask::DiskStore.new('bitcask.db')

# Setting values in store using put or hash style
db_store.put("Anime", "One Piece")
db_store["Luffy"] = "Straw Hat"
db_store[2020] = "Leap Year"
db_store.put("pie", 3.1415)

# Getting values from store using get or hash style
db_store["Anime"]
db_store.get("Luffy")
db_store["pie"]
db_store.get(2020)

# Listing keys
db_store.keys

# Size of the store
db_store.store
```

## Tests

```shell
bundle exec rspec
```

## Advanatages

- Simple yet powerful
- Easy to use
- Store data enormous than RAM
- Data file is OS agnostic
- Portable
- Faster read/writes
- Minimal dependecies

## Features

| Feature                               | Support            |
|---------------------------------------|--------------------|
| Persisted in disk                     | :white_check_mark: |
| Get API                               | :white_check_mark: |
| Put API                               | :white_check_mark: |
| Int, Float and String for k/v         | :white_check_mark: |
| CRC                                   | :white_check_mark: |
| Directory Support                     | :x:                |
| Delete API                            | :x:                |
| Files Merge and LSM Trees             | :x:                |

## Benchmarks

```ruby
ruby benchmark.rb
Benchmarked with value_size of 69 bytes
                                                         user     system      total        real
DiskStore.put : 10k records                          0.131023   0.070932   0.201955 (  0.202188) s
DiskStore.get : 10k records                          0.039780   0.033775   0.073555 (  0.073595) s
DiskStore.put : 100k records                         2.287855   0.824356   3.112211 (  3.116531) s
DiskStore.get : 100k records                         0.831596   0.371778   1.203374 (  1.204517) s
DiskStore.put : 1M records                          46.158727  62.157752 108.316479 (111.450463) s
DiskStore.get : 1M records                          10.434109  48.766160  59.200269 ( 68.947144) s
avg_put:                                             0.000044   0.000057   0.000101 (  0.000103) s
avg_get:                                             0.000010   0.000044   0.000054 (  0.000063) s
```

## Contributing

If you wish to contribute in any way, please fork the repo and raise a PR.

[![CircleCI](https://dl.circleci.com/insights-snapshot/gh/dineshgowda24/bitcask-rb/main/workflow/badge.svg?window=30d)](https://app.circleci.com/insights/github/dineshgowda24/bitcask-rb/workflows/workflow/overview?branch=main&reporting-window=last-30-days&insights-snapshot=true)