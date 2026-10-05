local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local WeaponAuras = require(script.Parent:WaitForChild("WeaponAuras"))
local v = {
	anchorParts = {
		LeftRootPart = true,
		RightRootPart = true
	},
	skipTrails = true,
	skipSound = true
}
return function(instance, p, p2)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 100 then
		return
	end

	WeaponAuras(instance, p, p2, v)
	local fanSwing = script:FindFirstChild("FanSwing")

	if fanSwing == nil then
		return
	end

	local clone = fanSwing:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, 1)
end