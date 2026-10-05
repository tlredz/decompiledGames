local None = require(script.Parent.Parent.None)
local get = require(script.Parent.get)
return function(p, list, p2)
	local count = 0

	while count ~= #list do
		count += 1
		p = get(p, list[count], None)

		if p == None then
			return p2
		end
	end

	return p
end