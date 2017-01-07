require "./spec_helper"

describe Memoized do
  it "Usage" do
    work = ->() { Dir["/tmp/*"].size }

    msg = Memoized(Int32).new(work, 1.minute)
    cnt = msg.get
    cnt.should be_a(Int32)
    msg.get.should eq(cnt)
  end
end
