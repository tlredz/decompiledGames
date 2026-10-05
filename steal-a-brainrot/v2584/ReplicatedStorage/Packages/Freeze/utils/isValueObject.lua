return function(p)
	if p and typeof(p) == "table" and typeof(p.equals) == "function" then
		return true
	end

	return false
end