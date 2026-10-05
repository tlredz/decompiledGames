local Signal2 = require(script.Parent.Signal2)
local v = {}
local class = {}

function d(list)
	list.Changed:Destroy()
	table.freeze(list)
end

function class.__index(p, p2)
	if p2 == "Value" then
		return (rawget(p, "_Value"))
	elseif p2 == "Destroy" then
		return d
	end
end

function class.__newindex(p, p2, p3)
	if p2 == "Value" then
		local v2 = rawget(p, "_Value")
		rawset(p, "_Value", p3)

		if v2 ~= p3 then
			p.Changed:Fire(p3)
		end
	end
end

function v.new(p)
	return (setmetatable({
		Changed = Signal2.new(),
		_Value = p
	}, class))
end

return v.new