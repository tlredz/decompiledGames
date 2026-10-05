local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
return function(cframe)
	if cframe == nil then
		return
	end

	local clone = script.BoulderPlaced:Clone()
	clone.Parent = workspace.Debree
	clone.Part.PS2boulderpushSUCCESS:Play()
	clone:PivotTo(cframe)
	Ouwmit.Emit(clone)
	DebrisModule:AddItem(clone, 3)
end