local ValueBase = require(script.Parent.Misc.ValueBase)
local simplesignal = require(script.Parent.Parent.simplesignal)
require(script.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Misc.FayeUtility)
local name = script.Name
local count = 0
return function(initial, thread)
	local v = {
		__type = name,
		Id = name .. count,
		Changed = simplesignal.new(),
		Initial = initial,
		ValueType = FayeUtility.tof(initial),
		Thread = thread,
		Value = initial
	}
	v.ValueTypeIsTable = v.ValueType == FayeUtility.tabletxt
	setmetatable(v, ValueBase)

	if thread ~= nil then
		FayeUtility.AddToThread(thread, v)
	end

	count += 1
	return v
end