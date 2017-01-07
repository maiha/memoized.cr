require "./spec_helper"

describe Memoized do
  it "basic" do
    work = ->() { Dir["/tmp/*"].size }

    msg = Memoized(Int32).new(work, 1.minute)
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
