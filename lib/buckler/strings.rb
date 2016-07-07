class String

  # Returns a copy of this string with terminal escapes to bold it
  def bold
    "\033[1m#{self}\e[0m"
  end

  # Returns a copy of this string with terminal escapes to make it red
  def dangerize
    "\e[38;5;196m#{self}\e[0m"
  end

  # Returns a copy of this string with terminal escapes to make it a color
  # Options: `:orange` or `:pink`
  def bucketize(color = :orange)
    case color
    when :pink
      "\e[38;5;206m#{self}\e[0m"
    else
      "\e[38;5;208m#{self}\e[0m"
    end
  end

end
