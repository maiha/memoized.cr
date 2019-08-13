require "./spec_helper"

describe Memoized do
  it "works" do
    work = ->() { Dir["/tmp/*"].size }

    msg = Memoized(Int32).new(work, 1.minute)
    cnt = msg.get
    cnt.should be_a(Int32)
    msg.get.should eq(cnt)
  end

  describe "(Basic API)" do
    it "#cached?" do
      m = Memoized(Int32).new{ 1 }
      m.cached?.should eq(nil)

      m.get
      m.cached?.should be_a Memoized::Cached(Int32)
      m.cached?.try(&.at).should be_a Time
      m.cached?.try(&.taken).should be_a Time::Span
    end
  
    it "#cache?" do
      m = Memoized(Int32).new(int_adder)
      m.cache?.should eq(nil)

      m.get
      m.cache?.should be_a Int32
    end
  
    it "#clear" do
      m = Memoized(Int32).new(int_adder)
      m.get.should eq(1)
      m.get.should eq(1)

      m.clear
      m.get.should eq(2)
      m.get.should eq(2)
    end
  end

  describe "(Handy Shortcuts)" do
    it "#cached_at" do
      m = Memoized(Int32).new{ 1 }
      expect_raises(Memoized::NotCached) { m.cached_at }
      m.get
      m.cached_at.should be_a Time
    end

    it "#cached_at?" do
      m = Memoized(Int32).new{ 1 }
      m.cached_at?.should be_a Nil
      m.get
      m.cached_at?.should be_a Time
    end

    it "#cached_taken" do
      m = Memoized(Int32).new{ 1 }
      expect_raises(Memoized::NotCached) { m.cached_taken }
      m.get
      m.cached_taken.should be_a Time::Span
    end

    it "#cached_taken?" do
      m = Memoized(Int32).new{ 1 }
      m.cached_taken?.should be_a Nil
      m.get
      m.cached_taken?.should be_a Time::Span
    end
    
    it "#cached_sec" do
      m = Memoized(Int32).new{ 1 }
      expect_raises(Memoized::NotCached) { m.cached_sec }
      m.get
      m.cached_sec.should be_a Float64
    end

    it "#cached_sec?" do
      m = Memoized(Int32).new{ 1 }
      m.cached_sec?.should be_a Nil
      m.get
      m.cached_sec?.should be_a Float64
    end

    it "#cached_msec" do
      m = Memoized(Int32).new{ 1 }
      expect_raises(Memoized::NotCached) { m.cached_msec }
      m.get
      m.cached_msec.should be_a Float64
    end

    it "#cached_msec?" do
      m = Memoized(Int32).new{ 1 }
      m.cached_msec?.should be_a Nil
      m.get
      m.cached_msec?.should be_a Float64
    end
  end
  
  describe "(Instance Creations)" do
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
  end
end
