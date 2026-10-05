local ValueBase = require(script.Parent.Misc.ValueBase)
local simplesignal = require(script.Parent.Parent.simplesignal)
require(script.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Misc.FayeUtility)
local name = script.Name
local count = 0
return function(p, p2: string, thread)
	local v = {
		Changed = simplesignal.new(),
		Id = name .. count,
		IsProperty = true,
		Thread = thread,
		__type = name
	}
	setmetatable(v, ValueBase)

	if thread ~= nil then
		FayeUtility.AddToThread(thread, v)
	end

	v:ReCalibrate(p, p2)
	count += 1
	return v
end