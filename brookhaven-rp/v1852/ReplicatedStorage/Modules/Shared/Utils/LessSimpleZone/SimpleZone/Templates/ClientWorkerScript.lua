local parent = script.Parent
local result = parent.Result
parent:BindToMessageParallel("GetPartsInPart", function(p, p2)
	task.defer(result.Fire, result, workspace:GetPartsInPart(p2, p))
end)