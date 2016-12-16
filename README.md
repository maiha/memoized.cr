# memoized.cr

Time-based memoized library for [Crystal](http://crystal-lang.org/).

- crystal: 0.20.1

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  memoized:
    github: maiha/memoized.cr
    version: 0.1.0
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
  ->(){ cnt.add(1); cnt.get }
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

## Roadmap

### 0.2.0

- [x] add an option to cache forever
- [ ] discard cache, or force get
- [ ] error handling (should be a monad?)

### 0.3.0

- [ ] memoize instance method


## Contributing

1. Fork it ( https://github.com/maiha/memoized.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
