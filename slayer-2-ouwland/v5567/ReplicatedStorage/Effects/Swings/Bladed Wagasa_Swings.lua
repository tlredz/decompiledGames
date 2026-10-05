local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local WeaponAuras = require(script.Parent:WaitForChild("WeaponAuras"))
local v = {
	anchorParts = {
		["Cone.013"] = true,
		["Cone.003"] = true
	},
	skipParticles = true,
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
	local umbrellaSwing = script:FindFirstChild("UmbrellaSwing")

	if umbrellaSwing == nil then
		return
	end

	local clone = umbrellaSwing:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, 1)
end