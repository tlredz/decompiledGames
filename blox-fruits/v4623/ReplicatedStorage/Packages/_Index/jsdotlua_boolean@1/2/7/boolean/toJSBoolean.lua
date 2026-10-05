local number = require(script.Parent.Parent:WaitForChild("number"))
return function(p)
	local v = p and true or false

	if v then
		if p == 0 or p == "" then
			return false
		else
			return not number.isNaN(p)
		end
	end

	return v
end