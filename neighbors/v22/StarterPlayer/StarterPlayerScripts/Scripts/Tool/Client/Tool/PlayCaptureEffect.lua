local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Network = require(ReplicatedStorage.Modules.Network)
local _ = {
	LifeTime = 4
}
Network:listen("Tool/PlayCaptureEffect", function(worldPosition: Vector3, instance)
	local clone = instance:Clone()
	clone.Parent = workspace.Terrain
	clone.WorldPosition = worldPosition

	for _, child in clone:GetChildren() do
		child:Emit(child:GetAttribute("EmitCount") or 5)
	end

	Debris:AddItem(clone, 4)
end)