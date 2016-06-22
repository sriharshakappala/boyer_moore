require 'boyer_moore'

describe BoyerMoore do
  describe BoyerMoore::Needle do
    it "should compute prefixes" do
      expect(BoyerMoore::Needle::prefix(%w[A N P A N M A N])).to eq [0, 0, 0, 1, 2, 0, 1, 2]
      expect(BoyerMoore::Needle::prefix(%w[f o o b a r])).to eq [0, 0, 0, 0, 0, 0]
    end

    it "should compute character_indexes" do
      expect(BoyerMoore::Needle.new(%w[A N P A N M A N]).send(:character_indexes)).to eq("A"=>6, "M"=>5, "N"=>7, "P"=>2)
      expect(BoyerMoore::Needle.new(%w[f o o b a r]).send(:character_indexes)).to eq("a"=>4, "b"=>3, "o"=>2, "f"=>0, "r"=>5)
    end

    it "should implement good_suffixes" do
      expect(BoyerMoore::Needle.new(%w[A N P A N M A N]).send(:good_suffixes)).to eq [6, 6, 6, 6, 6, 6, 3, 3, 1]
      expect(BoyerMoore::Needle.new(%w[f o o b a r]).send(:good_suffixes)).to eq [6, 6, 6, 6, 6, 6, 1]
    end
  end

  it "should implement search" do
    yielded = []
    BoyerMoore.search("ANPANMAN", "AN") { |index| yielded << index }
    expect(yielded).to eq [0, 3, 6]
    yielded = []
    BoyerMoore.search("ANANAN", "AN") { |index| yielded << index }
    expect(yielded).to eq [0, 2, 4]
    yielded = []
    BoyerMoore.search("AAAB", "A") { |index| yielded << index }
    expect(yielded).to eq [0, 1, 2]
    yielded = []
    BoyerMoore.search("ANPANMAN", "MAN") { |index| yielded << index }
    expect(yielded).to eq [5]
    yielded = []
    BoyerMoore.search("foobar", "zar") { |index| yielded << index }
    expect(yielded).to eq []
  end

  it "should implement search with a starting index" do
    yielded = []
    BoyerMoore.search("ANPANMAN", "AN", 0) { |index| yielded << index }
    expect(yielded).to eq [0, 3, 6]
    yielded = []
    BoyerMoore.search("ANPANMAN", "AN", 1) { |index| yielded << index }
    expect(yielded).to eq [3, 6]
  end

  it "should implement search to work with first" do
    expect(BoyerMoore.search("ANPANMAN", "ANP").first).to eq 0
    expect(BoyerMoore.search("ANPANMAN", "ANPXX").first).to eq nil
  end

  it "should implement search to work with first with a starting index" do
    expect(BoyerMoore.search("ANPANPAN", "ANP", 0).first).to eq 0
    expect(BoyerMoore.search("ANPANPAN", "ANP", 1).first).to eq 3
  end

  it "should return an enumerator from each with no block" do
    yielded = []
    enumerator = BoyerMoore.search("ANPANMAN", "AN")
    enumerator.each.with_index { |match_index, index| yielded[index] = match_index }
    expect(yielded).to eq [0, 3, 6]
  end

  it "should match ruby's #index for basic strings" do
    needle = 'abcab'
    ['12abcabc', 'abcgghhhaabcabccccc', '123456789abc123abc', 'aabbcc'].each do |haystack|
      expect(BoyerMoore.search(haystack, needle).first).to eq haystack.index(needle)
    end
  end
  
  it "should match characters" do
    {
      %w[a b c] => 0,
      %w[b c d] => nil,
      %w[e f g] => nil,
      %w[m y _ d o g _ a b c] => 7
    }.each do |haystack, position|
      expect(BoyerMoore.search(haystack, ['a', 'b', 'c']).first).to eq position
    end
  end

  it "should match in the middle of a string" do
    expect(BoyerMoore.search("xxxfoobarbazxxx".split(''), "foobar".split('')).first).to eq 3
  end

  it "should match words" do
    {
      ["foo", "bar", "baz"] => 0,
      ["bam", "bar", "bang"] => nil,
      ["put", "foo", "bar", "bar"] => 1,
      ["put", "foo", "bar", "foo", "bar"] => 1
    }.each do |haystack, position|
      expect(BoyerMoore.search(haystack, ["foo", "bar"]).first).to eq position
    end
  end
end
