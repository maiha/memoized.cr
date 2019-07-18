# memoized.cr [![Build Status](https://travis-ci.org/maiha/memoized.cr.svg?branch=master)](https://travis-ci.org/maiha/memoized.cr)

Time-based memoized library for [Crystal](http://crystal-lang.org/).

- crystal: 0.27.0

```yaml
dependencies:
  memoized:
    github: maiha/memoized.cr
    version: 0.5.0
```

## Usage

```
Memoized(T).new(proc : -> T)                    # memoize forever
Memoized(T).new(proc : -> T, span : Time::Span) # memoize at most the span
Memoized(T).new(proc : -> T, path : String)     # memoize until path is updated
Memoized(T)#get : T
Memoized(T)#cache? : T?
Memoized(T)#clear : Nil
```

```crystal
require "memoized"

# some high cost operation
work = ->() { Dir["/tmp/*"].size }

msg = Memoized(Int32).new(work, 1.minute)
msg.get # => 82
msg.get # => 82 (cached at most 1 minute)
msg.get # => 90 (we would get a new data after 1 minute)
```

### cache policy (2nd arg)

- **Always** : keep forever (this is default)
- **Finite** : refresh after given Time::Span
- **Source** : refresh after given filename is updated (checked by `mtime`)

```crystal
def int_adder
  cnt = Atomic(Int32).new(0)
  -> { cnt.add(1); cnt.get }
end
  
always = Memoized(Int32).new(int_adder)
finite = Memoized(Int32).new(int_adder, 1.minute)
source = Memoized(Int32).new(int_adder, "/tmp/file")
```

#### **always**, **finite**

|time    | always.cache? | always.get | finite.cache? | finite.get | 
|-------:|:-------------:|:----------:|:-------------:|:----------:|
|00:00:01|            nil|           1|            nil|           1|
|00:00:02|              1|           1|              1|           1|
|00:01:00|              1|           1|            nil|           2|
|00:01:01|              1|           1|              2|           2|

#### **source**

```crystal
# (when `/tmp/file` not found)
source.get # => 1
source.get # => 1

# touch /tmp/file
source.get # => 2
source.get # => 2
source.get # => 2

# touch /tmp/file
source.get # => 3
source.get # => 3

# rm /tmp/file
source.get # => 3
```

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

### Block invocation

```crystal
msg1 = Memoized(Array(Int32)).new do
  (0..255).to_a.repeated_combinations(4)
end

msg2 = Memoized(Array(Int32)).new(1.minute) do
  (0..255).to_a.repeated_combinations(4)
end

msg3 = Memoized(Array(Int32)).new("/path/to/cache") do
  (0..255).to_a.repeated_combinations(4)
end
```

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

### 0.3.0

- [x] source policy
- [x] clear cache

### 0.4.0

- [ ] memoize instance method
- [ ] error handling (should be a monad?)


## Contributing

1. Fork it ( https://github.com/maiha/memoized.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
