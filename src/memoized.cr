require "./memoized/*"

class Memoized(T)
  record Cached(T), value : T, policy : Policy

  @cached : Cached(T)?
  
  def initialize(@loader : -> T, @policy : Policy)
  end

  def cache? : T?
    @cached.try{|c| c.policy.expired? ? nil : c.value }
  end

  def get : T
    cache? || fetch
  end

  def clear : Nil
    @cached = nil
  end

  protected def fetch : T
    @loader.call.tap{|v| @cached = Cached(T).new(v, @policy.cached) }
  end
end
