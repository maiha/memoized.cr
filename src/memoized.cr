class Memoized(T)
  record Cached(T), value : T, at : Time = Time.now

  @cached : Cached(T)?
  def initialize(@loader : -> T, @keep : Time::Span)
  end

  def cache? : T?
    if cached = @cached
      if cached.at + @keep >= Time.now
        return cached.value
      end
    end
    return nil
  end

  def get : T
    unless cache?
      @cached = nil             # reset before invoke that would cause errors
      @cached = Cached(T).new(@loader.call)
    end
    @cached.try(&.value) || raise "BUG: @cached is not created in get"
  end
end
