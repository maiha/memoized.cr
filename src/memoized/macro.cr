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
end
