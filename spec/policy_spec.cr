require "./spec_helper"

private def source_file
  "#{__DIR__}/../tmp/source.txt"
end

WATCHED_VALUE = ["foo"]

private def value_watcher
  Memoized::Change(String).new do
    WATCHED_VALUE.first
  end
end

describe Memoized::Policy do
  FileUtils.mkdir_p File.dirname(source_file)
  FileUtils.rm(source_file) if File.exists?(source_file)
  
  always = Memoized(Int32).new(int_adder)
  finite = Memoized(Int32).new(int_adder, 1.second)
  source = Memoized(Int32).new(int_adder, source_file)
  change = Memoized(Int32).new(int_adder, value_watcher)

  it "#cache? should return nil in default" do
    always.cache?.should eq(nil)
    finite.cache?.should eq(nil)
    source.cache?.should eq(nil)
    change.cache?.should eq(nil)
  end

  it "#get should build value from loader" do
    always.get.should eq(1)
    finite.get.should eq(1)
    source.get.should eq(1)
    change.get.should eq(1)
  end

  it "#cache? should return cached value after #get" do
    always.cache?.should eq(1)
    finite.cache?.should eq(1)
    source.cache?.should eq(1)
    change.cache?.should eq(1)
  end

  it "#cache? should be cleared when it exceeds specified keep time" do
    sleep 1
    always.cache?.should eq(1)
    finite.cache?.should eq(nil)
    source.cache?.should eq(1)
    change.cache?.should eq(1)
  end

  it "#get should refresh data after cache has been expired" do
    always.get.should eq(1)
    finite.get.should eq(2)
    source.get.should eq(1)
    change.get.should eq(1)
  end

  describe "(policy: source)" do
    it "initial data is cached if source file is not found" do
      source.get.should eq(1)
      source.get.should eq(1)
    end

    it "cache is expired once file is created" do
      source.cache?.should eq(1)

      File.write(source_file, "")
      source.cache?.should eq(nil)
      source.get.should eq(2)
      source.get.should eq(2)
    end

    it "cache is expired when file is updated" do
      source.cache?.should eq(2)

      sleep 0.1
      File.write(source_file, "")
      source.cache?.should eq(nil)
      source.get.should eq(3)
      source.get.should eq(3)
      source.get.should eq(3)
    end

    it "keep cache even if file is deleted" do
      FileUtils.rm(source_file)
      source.cache?.should eq(3)
      source.get.should eq(3)
    end

    it "succ when file created again" do
      sleep 0.1
      File.write(source_file, "")
      source.cache?.should eq(nil)
      source.get.should eq(4)
    end
  end

  describe "(policy: change)" do
    it "updates value when the watched value has been changed" do
      change.get.should eq(1)
      change.get.should eq(1)
      WATCHED_VALUE[0] = "new value"
      change.get.should eq(2)
    end

    it "should be created by new(change : -> U, &blk)" do
      change2 = Memoized(Int32).new(change: -> { true }) do
        1
      end
    end
  end
end
