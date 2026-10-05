require(script.Parent.FayeTypes)
return function(p, data)
	if p == nil or data == nil then
		return
	end

	p.From = data.From
	p.AlwaysFrom = data.AlwaysFrom
	p.FirstGoal = data.FirstGoal
	p.FirstInfo = data.FirstInfo
	p.FirstDelayTime = data.FirstDelayTime
end