local CleanPortion = require(script.Parent.Misc.CleanPortion)

function Recursive(p, p2: number?)
	if p == nil then
		return
	end

	p.__Destroying = true
	p.ParentThread = nil
	p._isCleanAncestor = nil
	p.CleanWhenDone = nil
	p.IsActive = nil
	p.Cleaning = nil
	p._hc = nil

	if p.Priority ~= nil then
		CleanPortion(p.Priority)
		p.Priority = nil
	end

	CleanPortion(p, p2)
	p.AnimationsAmount = nil
	p.__Destroying = nil
end

return function(p)
	Recursive(p)
end