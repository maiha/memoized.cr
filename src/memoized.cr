require "pretty"

require "./memoized/*"

class Memoized(T)
  record Cached(T), value : T, policy : Policy, at : Time, taken : Time::Span
  class NotCached < Exception; end

  @cached : Cached(T)?
  
  def initialize(@loader : -> T, @policy : Policy)
  end

  def cached? : Cached(T)?
    @cached
  end

  def cached : Cached(T)
    @cached || raise NotCached.new
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

  # handy shortcuts (without '#try')
  def cached_at     : Time       ; cached.at                              ; end
  def cached_at?    : Time?      ; cached?.try(&.at)                      ; end
  def cached_taken  : Time::Span ; cached.taken                           ; end
  def cached_taken? : Time::Span?; cached?.try(&.taken)                   ; end
  def cached_sec    : Float64    ; cached.taken.total_seconds             ; end
  def cached_sec?   : Float64?   ; cached?.try(&.taken.total_seconds)     ; end
  def cached_msec   : Float64    ; cached.taken.total_milliseconds        ; end
  def cached_msec?  : Float64?   ; cached?.try(&.taken.total_milliseconds); end

  protected def fetch : T
    t1 = Pretty.now
    v  = @loader.call
    t2 = Pretty.now
    @cached = Cached(T).new(v, @policy.cached, t2, t2 - t1)
    return v
  end
end
