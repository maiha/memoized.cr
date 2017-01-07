class Memoized(T)
  def self.new(loader : -> T)
    new(loader, Always.new)
  end
  
  def self.new(loader : -> T, span : Time::Span)
    new(loader, Finite.new(span))
  end

  def self.new(loader : -> T, path : String)
    new(loader, Source.new(path))
  end
end
