local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
return function(worldPosition: Vector3)
	if worldPosition == nil then
		return
	end

	local clone = script.Attachment:Clone()
	clone.Parent = workspace.Debree
	clone.WorldPosition = worldPosition
	clone.PS2pickup2:Play()
	Ouwmit.Emit(clone)
	DebrisModule:AddItem(clone, 4)
	Cam_Shaker(worldPosition, "tinyshake_less_aggresive_preset")
end