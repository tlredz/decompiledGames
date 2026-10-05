local parent = script.Parent
local result = parent.Result
parent:BindToMessageParallel("GetPartsInPart", function(object, p, p2)
	task.defer(result.Fire, result, object:GetPartsInPart(p2, p))
end)