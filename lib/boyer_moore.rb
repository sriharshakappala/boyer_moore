require_relative "./boyer_moore/version"

module BoyerMoore
  class << self
    def search(haystack, needle_string)
      needle = Needle.new(needle_string)

      index = 0
      while index <= haystack.size - needle.size
        remaining = needle.size
        while needle[remaining-1] == haystack[index+remaining-1]
          remaining -= 1
          remaining == 0 and return index # SUCCESS!
        end

        char_index = needle.character_index(haystack[index+remaining-1])
        skip =  if char_index < remaining && (m = remaining - char_index - 1) > needle.good_suffix[remaining]
                  m
                else
                  needle.good_suffix[remaining]
                end
        index += skip
      end
    end
  end

  class Needle
    def initialize(needle)
      needle.size > 0 or raise "Must pass needle with size > 0"
      @needle = needle
    end

    def to_s
      @needle
    end

    def size
      @needle.size
    end

    def [](n)
      @needle[n]
    end

    def character_index(char)
      character_indexes[char] || -1
    end

    def character_indexes
      @char_indexes ||=
        (0...@needle.length).reduce({}) do |hash, i|
          hash[@needle[i]] = i
          hash
        end
    end

    def good_suffix
      @good_suffix ||=
        begin
          prefix_normal   = prefix(@needle)
          prefix_reversed = prefix(@needle.reverse)
          result = []
          (0..@needle.size).each do |i|
            result[i] = @needle.size - prefix_normal[@needle.size-1]
          end
          (0...@needle.size).each do |i|
            j = @needle.size - prefix_reversed[i]
            k = i - prefix_reversed[i] + 1
            result[j] > k and result[j] = k
          end
          result
        end
    end

    def prefix(string)
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
