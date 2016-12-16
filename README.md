# memoized.cr [![Build Status](https://travis-ci.org/maiha/memoized.cr.svg?branch=master)](https://travis-ci.org/maiha/memoized.cr)

Time-based memoized library for [Crystal](http://crystal-lang.org/).

- crystal: 0.20.1

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  memoized:
    github: maiha/memoized.cr
    version: 0.1.1
```

## Usage

- `Memoized(T).new(proc : -> T)` # memoize forever
- `Memoized(T).new(proc : -> T, span : Time::Span)` # memoize at most the span

```crystal
require "memoized"

# some high cost operation
builder = ->() { File.read("/var/log/message") }

msg = Memoized(String).new(builder, 1.minute)
msg.get # => String (cached at most 1 minute)

msg.get # we would get a new data after 1 minute
```

### Keep options (2nd arg)

- Always : keep the data forever (this is default)
- Finite : refresh after given Time::Span

```crystal
def int_adder
  cnt = Atomic(Int32).new(0)
  -> { cnt.add(1); cnt.get }
end
  
always = Memoized(Int32).new(int_adder)
finite = Memoized(Int32).new(int_adder, 1.minute)
```

|time    | always.cache? | always.get | finite.cache? | finite.get | 
|-------:|:-------------:|:----------:|:-------------:|:----------:|
|00:00:01|            nil|           1|            nil|           1|
|00:00:02|              1|           1|              1|           1|
|00:01:00|              1|           1|            nil|           2|
|00:01:01|              1|           1|              2|           2|

### macros to memoize method

- `int`, `str` can be used to avoid redundant proc format.

```crystal
def foo
  1
end

# standard way
cached_foo = Memoized(Int32).new(-> { foo })

# with int macro
cached_foo = Memoized.int(foo)
```

- TODO: I'd like to write like `Memozied(Int32).cache(foo)`. Is it possible?

## Examples

Let's speed up Kemal apps with fragment cache.

#### before

```crystal
get "/top" do |env|
  shared_data  = build_shared_data
  dynamic_data = build_dynamic_data
  render "src/views/top.ecr"
end

private def build_shared_data
  ...
```

#### after

```diff
+shared = Memoized.str(build_shared_data, 1.minute)
+
 get "/top" do |env|
-  shared_data  = build_shared_data
+  shared_data  = shared.get
   dynamic_data = build_dynamic_data
   render "src/views/top.ecr"
```

```
2016-12-16 18:02:32 +0900 200 GET /top 97.59ms  # 1st time
2016-12-16 18:02:34 +0900 200 GET /top 578.4µs  # fragment cache!
2016-12-16 18:02:36 +0900 200 GET /top 542.4µs  # fragment cache!
```


## Roadmap

### 0.2.0

- [x] add an option to cache forever
- [x] add class method macros for helpers

### 0.3.0

- [ ] memoize instance method
- [ ] discard cache, or force get
- [ ] error handling (should be a monad?)


## Contributing

1. Fork it ( https://github.com/maiha/memoized.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
