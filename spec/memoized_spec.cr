require "./spec_helper"

private def int_adder
  cnt = Atomic(Int32).new(0)
  ->(){ cnt.add(1); cnt.get }
end
  
describe Memoized do
  always = Memoized(Int32).new(int_adder)
  finite = Memoized(Int32).new(int_adder, 1.second)

  it "#cache? should return nil in default" do
    always.cache?.should eq(nil)
    finite.cache?.should eq(nil)
  end

  it "#get should build value from loader" do
    always.get.should eq(1)
    finite.get.should eq(1)
  end

  it "#cache? should return cached value after #get" do
    always.cache?.should eq(1)
    finite.cache?.should eq(1)
  end

  it "#cache? should be cleared when it exceeds specified keep time" do
    sleep 1
    always.cache?.should eq(1)
    finite.cache?.should eq(nil)
  end

  it "#get should refresh data after cache has been expired" do
    always.get.should eq(1)
    finite.get.should eq(2)
  end
end
