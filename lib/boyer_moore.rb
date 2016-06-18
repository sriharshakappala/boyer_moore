require_relative "./boyer_moore/version"

module BoyerMoore
  class << self
    def search(haystack, needle)
      needle.size > 0 or raise "Must pass needle with size > 0"
      char_indexes = character_indexes(needle)
      goodsuffix   = goodsuffix_heuristic(needle)

      index = 0
      while index <= haystack.size - needle.size
        remaining = needle.size
        while needle[remaining-1] == haystack[index+remaining-1]
          remaining -= 1
          remaining == 0 and return index # SUCCESS!
        end

        char_index = char_indexes[haystack[index+remaining-1]] || -1
        skip =  if char_index < remaining && (m = remaining - char_index - 1) > goodsuffix[remaining]
                  m
                else
                  goodsuffix[remaining]
                end
        index += skip
      end
    end

  private

    def character_indexes(needle)
      (0...needle.length).reduce({}) do |hash, i|
        hash[needle[i]] = i
        hash
      end
    end

    def goodsuffix_heuristic(needle)
      prefix_normal   = prefix(needle)
      prefix_reversed = prefix(needle.reverse)
      result = []
      (0..needle.size).each do |i|
        result[i] = needle.size - prefix_normal[needle.size-1]
      end
      (0...needle.size).each do |i|
        j = needle.size - prefix_reversed[i]
        k = i - prefix_reversed[i] + 1
        result[j] > k and result[j] = k
      end
      result
    end

    def prefix(needle)
      k = 0
      (1...needle.length).reduce([0]) do |prefix, q|
        while k > 0 && needle[k] != needle[q]
          k = prefix[k - 1]
        end
        needle[k] == needle[q] and k += 1
        prefix[q] = k
        prefix
      end
    end
  end
end
