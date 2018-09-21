class Memoized(T)
  module Policy
    abstract def expired? : Bool
    abstract def cached : Policy
  end

  struct Always
    include Policy
    def expired? ; false ; end
    def cached   ; self  ; end
  end

  record Finite, span : Time::Span, max : Time = Time.now + span do
    include Policy
    def expired? ; max < Time.now   ; end
    def cached   ; Finite.new(span) ; end
  end

  record Source, path : String, ttl : Int64? = nil do
    include Policy

    def expired?
      return true if ttl.nil?
      ticks = get_ticks
      return false if ticks == 0
      return ttl.not_nil! < ticks
    end

    def cached
      Source.new(path, get_ticks)
    end

    private def get_ticks : Int64
      File.info(path).modification_time.epoch_ms
    rescue
      0_i64
    end
  end
end
