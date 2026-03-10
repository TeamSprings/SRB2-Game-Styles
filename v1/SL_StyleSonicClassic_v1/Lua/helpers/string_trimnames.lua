return function(str)
	return string.gsub(string.gsub(str, "[^%a ]", ""), "%s+", " ")
end