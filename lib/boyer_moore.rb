require_relative "./boyer_moore/version"

module BoyerMoore
  class << self
    def search(haystack, needle)
      needle.size > 0 or raise "Must pass needle with size > 0"
      badcharacter = badcharacter_heuristic(needle)
      goodsuffix   = goodsuffix_heuristic(needle)

      index = 0
      while index <= haystack.size - needle.size
        remaining = needle.size
        while needle[remaining-1] == haystack[index+remaining-1]
          remaining -= 1
          remaining == 0 and return index # SUCCESS!
        end

        k = badcharacter[haystack[index+remaining-1]] || -1
        skip =  if k < remaining && (m = remaining-k-1) > goodsuffix[remaining]
                  m
                else
                  goodsuffix[remaining]
                end
        index += skip
      end
    end

    private

    def badcharacter_heuristic(str)
      (0...str.length).reduce({}) do |hash, i|
        hash[str[i]] = i
        hash
      end
    end

    def goodsuffix_heuristic(normal)
      reversed = normal.reverse
      prefix_normal = prefix(normal)
      prefix_reversed = prefix(reversed)
      result = []
      (0..normal.size).each do |i|
        result[i] = normal.size - prefix_normal[normal.size-1]
      end
      (0...normal.size).each do |i|
        j = normal.size - prefix_reversed[i]
        k = i - prefix_reversed[i]+1
        result[j] = k if result[j] > k
      end
      result
    end

    def prefix(str)
      k = 0
      (1...str.length).reduce([0]) do |prefix, q|
        while (k > 0) && (str[k] != str[q])
          k = prefix[k-1]
        end
        str[k] == str[q] and k += 1
        prefix[q] = k
        prefix
      end
    end
  end
end
