local TableKit = require(script.Parent.Parent.Parent.TableKit)
return function(value)
	if typeof(value) == "table" then
		if TableKit.IsArray(value) then
			return TableKit.ToArrayString(value)
		end

		return TableKit.ToString(value)
	else
		local v = ""
		local v2 = ""

		if typeof(value) == "CFrame" then
			v = "CFrame("
			v2 = ")"
		elseif typeof(value) == "Vector3" then
			v = "Vector3("
			v2 = ")"
		end

		return (`{v}{tostring(value)}{v2}`)
	end
end