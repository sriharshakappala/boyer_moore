require File.dirname(__FILE__) + '/spec_helper'
require 'boyer_moore'

describe BoyerMoore do
  it "should compute prefixes" do
    expect(BoyerMoore.compute_prefix(%w{A N P A N M A N})).to eq [0, 0, 0, 1, 2, 0, 1, 2]
    expect(BoyerMoore.compute_prefix(%w{f o o b a r})).to eq [0, 0, 0, 0, 0, 0]
  end

  # it "should compute badcharacter heuristics" do
  #   BoyerMoore.prepare_badcharacter_heuristic(%w{A N P A N M A N}).should == {"A"=>6, "M"=>5, "N"=>7, "P"=>2}
  #   BoyerMoore.prepare_badcharacter_heuristic(%w{f o o b a r}).should == {"a"=>4, "b"=>3, "o"=>2, "f"=>0, "r"=>5}
  # end

  it "should prepare goodsuffix heuristics" do
    expect(BoyerMoore.prepare_goodsuffix_heuristic(%w{A N P A N M A N})).to eq [6, 6, 6, 6, 6, 6, 3, 3, 1] 
    expect(BoyerMoore.prepare_goodsuffix_heuristic(%w{f o o b a r})).to eq [6, 6, 6, 6, 6, 6, 1]
  end

  it "should search properly" do
    expect(BoyerMoore.search("ANPANMAN", "ANP")).to eq 0
    expect(BoyerMoore.search("ANPANMAN", "ANPXX")).to eq nil 
    expect(BoyerMoore.search("ANPANMAN", "MAN")).to eq 5
    expect(BoyerMoore.search("foobar", "bar")).to eq 3
    expect(BoyerMoore.search("foobar", "zar")).to eq nil 
  end

  it "should match ruby's #index for basic strings" do
    needle = 'abcab'
    ['12abcabc', 'abcgghhhaabcabccccc', '123456789abc123abc', 'aabbcc'].each do |hay|
      expect(BoyerMoore.search(hay, needle)).to eq hay.index(needle)
    end
  end
  
  it "should match characters" do
    needle = "abc".split(//)
    haystacks = {
      "abc" => 0, 
      "bcd" => nil,
      "efg" => nil, 
      "my dog abc" => 7
    }
    haystacks.each do |hay,pos|
      hay = hay.split(//)
      expect(BoyerMoore.search(hay, needle)).to eq pos
    end
  end

  it "should match in the middle of a string" do
    expect(BoyerMoore.search("xxxfoobarbazxxx".split(//), "foobar".split(//))).to eq 3
  end

  it "should match words" do
    needle = ["foo", "bar"]
    haystacks = {
      ["foo", "bar", "baz"] => 0,
      ["bam", "bar", "bang"] => nil,
      ["put", "foo", "bar", "bar"] => 1,
      ["put", "foo", "bar", "foo", "bar"] => 1
    }
    haystacks.each do |hay,pos|
      expect(BoyerMoore.search(hay, needle)).to eq pos
    end
  end

  it "should match regular expressions" do
    needle = [/^\d+$/]
    haystacks = {
      ["999"] => 0,
      ["foo", "99", "x"] => 1,
      ["foo99", "10", "10"] => 1
    } 
    haystacks.each do |hay,pos|
      expect(BoyerMoore.search(hay, needle)).to eq pos
    end
  end

  describe BoyerMoore::RichHash do
    it "should allow regular hash semantics" do
      h = BoyerMoore::RichHash.new
      h[1] = "foo"
      expect(h[1]).to eq "foo"
    end

    it "should allow regexp semantics" do
      h = BoyerMoore::RichHash.new
      h["a"] = "b"
      h[/\d+/] = "bing"
      expect(h["a"]).to eq "b"
      expect(h["b"]).to eq nil
      expect(h["9"]).to eq "bing"
      expect(h["99"]).to eq "bing"
      expect(h["a99"]).to eq "bing"
    end
  end
end
