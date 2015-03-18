def humanize(str)
  str.split('_').map(&:capitalize).join(' ')
end

