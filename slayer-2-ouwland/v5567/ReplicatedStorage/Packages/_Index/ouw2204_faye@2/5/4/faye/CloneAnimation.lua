require(script.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Misc.FayeUtility)
return function(p, data, p2)
	if p == nil then
		return
	end

	local clone = table.clone(p)

	if p2 == nil then
		clone.NoThread = true
	else
		clone.NoThread = nil
		FayeUtility.AddToThread(p2, clone)
	end

	if data == nil then
		return clone
	end

	clone.From = data.From
	clone.AlwaysFrom = data.AlwaysFrom
	clone.FirstGoal = data.FirstGoal
	clone.FirstInfo = data.FirstInfo
	clone.FirstGoal = data.FirstGoal
	return clone
end