require "spec"
require "../src/memoized"

require "file_utils"

def int_adder
  cnt = Atomic(Int32).new(0)
  -> { cnt.add(1); cnt.get }
end
