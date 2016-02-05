module SliceFilter
  def slice(input, length, start=0)
    if length > input.length
      length = input.length
    end
    input[start, length]
  end

  Liquid::Template.register_filter self
end

module StartsWithFilter
  def startsWith(input, startStr)
    startStr.length < input.length && input[0, startStr.length] == startStr
  end

  Liquid::Template.register_filter self
end

module RemovePrefixFilter
  def removePrefix(input, prefix)
    input[prefix.length, input.length]
  end

  Liquid::Template.register_filter self
end