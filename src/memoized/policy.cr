class Memoized(T)
  module Policy
    abstract def expired? : Bool
    abstract def cached : Policy
  end

  struct Always
    include Policy
    def expired? : Bool   ; false ; end
    def cached   : Policy ; self  ; end
  end

  record Finite, span : Time::Span, max : Time = Pretty.now + span do
    include Policy
    def expired? : Bool   ; max < Pretty.now   ; end
    def cached   : Policy ; Finite.new(span) ; end
  end

  record Source, path : String, ttl : Int64? = nil do
    include Policy

    def expired? : Bool
      return true if ttl.nil?
      ticks = get_ticks
      return false if ticks == 0
      return ttl.not_nil! < ticks
    end

    def cached : Policy
      Source.new(path, get_ticks)
    end

    private def get_ticks : Int64
      File.info(path).modification_time.to_unix_ms
    rescue
      0_i64
    end
  end

  record Change(U), proc : Proc(U), current : U? = nil  do
    include Policy
    def expired? : Bool   ; @current != proc.call          ; end
    def cached   : Policy ; Change(U).new(proc, proc.call) ; end
    def self.new(&proc : -> U); new(proc)         ; end
  end
end
