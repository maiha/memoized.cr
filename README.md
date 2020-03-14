# memoized.cr [![Build Status](https://travis-ci.org/maiha/memoized.cr.svg?branch=master)](https://travis-ci.org/maiha/memoized.cr)

Time-based memoized library for [Crystal](http://crystal-lang.org/).

- crystal: 0.27.2 0.31.1 0.32.1 0.33.0

```yaml
dependencies:
  memoized:
    github: maiha/memoized.cr
    version: 0.9.0
```

## Usage

```crystal
# Instance Creations
Memoized(T).new(proc : -> T)                     # memoize forever
Memoized(T).new(&blk : -> T)                     # memoize forever
Memoized(T).new(proc : -> T, span : Time::Span)  # memoize at most the span
Memoized(T).new(span : Time::Span, &blk : -> T)  # memoize at most the span
Memoized(T).new(proc : -> T, path : String)      # memoize until path is updated
Memoized(T).new(path : String, &blk : -> T)      # memoize until path is updated
Memoized(T).new(proc : -> T, change : Change(U)) # memoize until the value changed
Memoized(T).new(change : -> U, &blk : ->T)       # memoize until the value changed

# Instance Methods
Memoized(T)#get : T          # Returns the cached value, otherwise evaluates blk
Memoized(T)#cache? : T?      # Returns the cached value or nil
Memoized(T)#cached? : Cache? # Returns a snapshot of the cache if exists
Memoized(T)#clear : Nil      # Clears cached value
```

```crystal
require "memoized"

msg = Memoized(Int32).new(1.minute) do
  Dir["/tmp/*"].size # some high cost operation
end
msg.get # => 82
msg.get # => 82 (cached at most 1 minute)
msg.get # => 90 (we would get a new data after 1 minute)
```

### Cached info

`Memoized#cached?` and `Memoized#cached` return a snapshot of the cache as `Memoized::Cache` if exists.

```crystal
Memoized::Cache#value  : T          # Returns the cached value
Memoized::Cache#policy : Policy     # Returns a revocation policy for the cache
Memoized::Cache#at     : Time       # Returns the time when the cache was created
Memoized::Cache#taken  : Time::Span # Returns the time taken to execute the block

# shortcuts
Memoized#cached_at     : Time
Memoized#cached_at?    : Time?
Memoized#cached_taken  : Time::Span
Memoized#cached_taken? : Time::Span?
Memoized#cached_sec    : Float64
Memoized#cached_sec?   : Float64?
Memoized#cached_msec   : Float64
Memoized#cached_msec?  : Float64?
```

```crystal
m = Memoized(Int32).new{ 1 }
m.cached?                         # => nil
m.cached                          # raises Memoized::NotCached

m.get                             # => 1
m.cached.at                       # => 2019-08-13 16:11:03.913925000
m.cached.taken.total_milliseconds # => 0.001
m.cached_msec                     # => 0.001 (handy shortcut)
```

### Revocation policy

It can be given at 2nd arg, or 1st arg with &blk.

- **Always** : keep forever (this is default)
- **Finite** : refresh after given Time::Span
- **Source** : refresh after given filename is updated (checked by `mtime`)
- **Change** : refresh after given proc returns different value

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

#### **change**

`Change` policy keeps `expired?` logic as `Proc`, so it can emulate all policies.

```crystal
source = Memoized(Int32).new(int_adder, "/tmp/file")

# can be rewriten by `Change` policy as follows

mtime_watcher = Memoized::Change(Time).new {
  File.info("/tmp/file").modification_time
}
source = Memoized(Int32).new(int_adder, mtime__watcher)
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

### 0.8.0

- [x] take proc as a logic of revocation cache
- [ ] error handling (should be a monad?)


## Contributing

1. Fork it ( https://github.com/maiha/memoized.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
