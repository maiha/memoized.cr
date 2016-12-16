require "./spec_helper"

private class Counter
  property value : Int32 = 0
  def succ!
    @value += 1
  end
end

private def int_adder
  cnt  = Counter.new
  ->(){ cnt.succ! }
end
  
describe Memoized do
  counter = Memoized(Int32).new(int_adder, keep: 1.second)

  it "#cache? should return nil in default" do
    counter.cache?.should eq(nil)
  end

  it "#get should build value from loader" do
    counter.get.should eq(1)
  end

  it "#cache? should return cached value after #get" do
    counter.cache?.should eq(1)
  end

  it "#cache? should return nil after keep time has gone" do
    sleep 1
    counter.cache?.should eq(nil)
  end

  it "#get should refresh data after cache has been expired" do
    counter.get.should eq(2)
  end
end
