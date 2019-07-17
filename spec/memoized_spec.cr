require "./spec_helper"

describe Memoized do
  it "basic" do
    work = ->() { Dir["/tmp/*"].size }

    msg = Memoized(Int32).new(work, 1.minute)
    cnt = msg.get
    cnt.should be_a(Int32)
    msg.get.should eq(cnt)
  end

  it "can be invoked with a block" do
    msg = Memoized(Int32).new do
      Dir["/tmp/*"].size
    end

    cnt = msg.get
    cnt.should be_a(Int32)
  end

  it "can be invoked with a timespan and a block" do
    msg = Memoized(Int32).new(1.minute) do
      Dir["/tmp/*"].size
    end

    cnt = msg.get
    cnt.should be_a(Int32)
    msg.get.should eq(cnt)
  end

  it "can be invoked with a path and a block" do
    msg = Memoized(Int32).new(__FILE__) do
      Dir["/tmp/*"].size
    end

    cnt = msg.get
    cnt.should be_a(Int32)
    msg.get.should eq(cnt)
  end

  it "#clear" do
    always = Memoized(Int32).new(int_adder)
    always.get.should eq(1)
    always.get.should eq(1)

    always.clear
    always.get.should eq(2)
    always.get.should eq(2)
  end
end
