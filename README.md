# bitcask-rb : A Log-Structured Hash Table for Fast Key/Value Data

[![Ruby Style Guide](https://img.shields.io/badge/code%20style-rubocop-brightgreen)](https://github.com/rubocop/rubocop)
[![Ruby](https://img.shields.io/badge/ruby-3.1.1-brightgreen)](https://www.ruby-lang.org/en/)


Fast, Persistant key/value store based on [bitcask paper](https://riak.com/assets/bitcask-intro.pdf) written in Ruby.
An attempt to understand and build our persitant kv store abd this in anyway is not intended for production.
Few specifications from the paper are intentionally ignore for the same of simiplicity.

## Prerequists

- Ruby
- bundler

## Setup

```shell
bundle install
```

## Example

```ruby
db_store = Bitcask::DiskStore.new('bitcask.db')

# Setting values in store
db_store.put("Anime", "One Piece")
db_store["Luffy"] = "Straw Hat"

# Getting values from store
db_store["Anime"]
db_store.get("Luffy")

# Listing keys
db_store.keys

# Size of the store
db_store.store
```

## Benchmarks

```shell
ruby benchmark.rb
Report for value size: 69 bytes
                                                         user     system      total        real
DiskStore#put : 10k records                          0.131023   0.070932   0.201955 (  0.202188)s
DiskStore#get : 10k records                          0.039780   0.033775   0.073555 (  0.073595)s
DiskStore#put : 100k records                         2.287855   0.824356   3.112211 (  3.116531)s
DiskStore#get : 100k records                         0.831596   0.371778   1.203374 (  1.204517)s
DiskStore#put : 1M records                          46.158727  62.157752 108.316479 (111.450463)s
DiskStore#get : 1M records                          10.434109  48.766160  59.200269 ( 68.947144)s
avg_put:                                             0.000044   0.000057   0.000101 (  0.000103)s
avg_get:                                             0.000010   0.000044   0.000054 (  0.000063)s
```
