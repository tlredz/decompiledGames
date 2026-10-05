local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("ModelOffset", function(model)
	if not model:IsA("Model") then
		return
	end

	local offset = model:GetAttribute("Offset") or createVector(0, 0, 0)
	model:PivotTo(model:GetPivot() + offset)
end)