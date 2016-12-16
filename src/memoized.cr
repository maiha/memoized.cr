class Memoized(T)
  def self.new(loader : -> T)
    new(loader, Always.new)
  end
  
  def self.new(loader : -> T, keep : Time::Span)
    new(loader, Finite.new(keep))
  end

  record Cached(T), value : T, keep : Keep

  module Keep
    abstract def expired? : Bool
    abstract def cached : Keep
  end

  struct Always
    include Keep
    def expired? ; false ; end
    def cached   ; self  ; end
  end

  record Finite, span : Time::Span, max : Time = Time.now + span do
    include Keep
    def expired? ; max < Time.now   ; end
    def cached   ; Finite.new(span) ; end
  end
  
  @cached : Cached(T)?
  def initialize(@loader : -> T, @keep : Keep)
  end

  def cache? : T?
    if cached = @cached
      unless cached.keep.expired?
        return cached.value
      end
    end
    return nil
  end

  def get : T
    unless cache?
      @cached = nil             # reset before invoke that would cause errors
      @cached = Cached(T).new(@loader.call, @keep.cached)
    end
    @cached.try(&.value) || raise "BUG: @cached is not created in get"
  end
end
