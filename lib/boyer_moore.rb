require_relative "./boyer_moore/version"

module BoyerMoore

  # Yields the index of each match of needle_string in haystack.
  # If no block given, returns an Enumerator that does the same.
  # Starts at starting_haystack_index (default = 0).
  def self.search(haystack, needle_string, starting_haystack_index = 0, &block)
    enumerator = Enumerator.new(haystack, needle_string, starting_haystack_index)
    if block
      enumerator.each(&block)
    else
      enumerator.to_enum(:each)
    end
  end

  class Enumerator
    def initialize(haystack, needle_string, starting_haystack_index = 0)
      @haystack = haystack
      @needle = Needle.new(needle_string)
      @haystack_index = starting_haystack_index
    end

    def each
      while @haystack_index <= @haystack.size - @needle.size
        if skip_by = @needle.match_or_skip_by(@haystack, @haystack_index)
          @haystack_index += skip_by
        else
          yield @haystack_index # Found a match here!
          @haystack_index += @needle.size
        end
      end
    end
  end

  class Needle
    def initialize(needle)
      needle.size > 0 or raise "Must pass needle with size > 0"
      @needle = needle
    end

    def size
      @needle.size
    end

    def match_or_skip_by(haystack, haystack_index)
      if mismatch_idx = mismatch_index(haystack, haystack_index)
        mismatch_char_index = character_index(haystack[haystack_index + mismatch_idx])
        skip_by(mismatch_char_index, mismatch_idx)
      end
    end

  private

    def mismatch_index(haystack, haystack_index)
      compare_index = size - 1
      while @needle[compare_index] == haystack[haystack_index + compare_index]
        compare_index -= 1
        compare_index < 0 and return nil
      end
      compare_index
    end

    def character_index(char)
      character_indexes[char] || -1
    end

    def good_suffix(compare_index)
      good_suffixes[compare_index]
    end

    def skip_by(mismatch_char_index, compare_index)
      suffix_index = good_suffix(compare_index + 1)
      if mismatch_char_index <= compare_index && (m = compare_index - mismatch_char_index) > suffix_index
        m
      else
        suffix_index
      end
    end

    def character_indexes
      @char_indexes ||=
        (0...@needle.length).reduce({}) do |hash, i|
          hash[@needle[i]] = i
          hash
        end
    end

    def good_suffixes
      @good_suffixes ||=
        begin
          prefix_normal   = self.class.prefix(@needle)
          prefix_reversed = self.class.prefix(@needle.reverse)
          result = []
          (0..@needle.size).each do |i|
            result[i] = @needle.size - prefix_normal[@needle.size - 1]
          end
          (0...@needle.size).each do |i|
            j = @needle.size - prefix_reversed[i]
            k = i - prefix_reversed[i] + 1
            result[j] > k and result[j] = k
          end
          result
        end
    end

    def self.prefix(string)
      k = 0
      (1...string.length).reduce([0]) do |prefix, q|
        while k > 0 && string[k] != string[q]
          k = prefix[k - 1]
        end
        string[k] == string[q] and k += 1
        prefix[q] = k
        prefix
      end
    end
  end
end
