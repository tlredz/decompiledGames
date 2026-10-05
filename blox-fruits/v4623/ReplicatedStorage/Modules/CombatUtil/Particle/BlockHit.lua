local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
return {
	playAt = function(position)
		local clone = ReplicatedStorage.Assets.BlockHit:Clone()
		clone.CFrame = CFrame.new(position)
		clone.Parent = workspace._WorldOrigin
		local attachment = clone.Attachment
		attachment.EnergyRing:Emit(1)
		attachment.EnergyRing2:Emit(1)
		attachment.Out:Emit(3)
		Debris:AddItem(clone, 0.6)
	end
}