class Memoized(T)
  macro str(method_name, *args)
    Memoized(String).new(-> { {{method_name.id}} }, {{*args}})
  end

  macro int(method_name, *args)
    Memoized(Int32).new(-> { {{method_name.id}} }, {{*args}})
  end

  # TODO: want something like this.
  # macro cache(method_name, *args)
  #   Memoized({{method_name.type}}).new(-> { {{method_name.id}} }, {{*args}})
  # end
  
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
    @cached.try{|c| c.keep.expired? ? nil : c.value }
  end

  def get : T
    cache? || fetch
  end

  protected def fetch : T
    @loader.call.tap{|v| @cached = Cached(T).new(v, @keep.cached) }
  end
end
