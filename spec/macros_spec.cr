require "./spec_helper"

private def str_method
  "x"
end

private def int_method
  1
end

describe Memoized do
  describe ".str" do
    it "should build Memoized with given method name" do
      cache = Memoized.str(str_method)
      cache.should be_a(Memoized(String))
      cache.get.should eq("x")

      cache = Memoized.str(str_method, 1.second)
      cache.should be_a(Memoized(String))
      cache.get.should eq("x")
    end
  end

  describe ".int" do
    it "should build Memoized with given method name" do
      cache = Memoized.int(int_method)
      cache.should be_a(Memoized(Int32))
      cache.get.should eq(1)

      cache = Memoized.int(int_method, 1.second)
      cache.should be_a(Memoized(Int32))
      cache.get.should eq(1)
    end
  end
end
