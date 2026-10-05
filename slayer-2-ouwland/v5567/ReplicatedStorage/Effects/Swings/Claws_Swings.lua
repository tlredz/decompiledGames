local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local WeaponAuras = require(script.Parent:WaitForChild("WeaponAuras"))
local v = {
	anchorParts = {
		Blade = true
	},
	skipTrails = true,
	skipSound = true
}
return function(instance, value, p)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 100 then
		return
	end

	WeaponAuras(instance, value, p, v)
	local pS2clawSLASH1 = script:FindFirstChild("PS2clawSLASH" .. tostring(value or 1))

	if pS2clawSLASH1 == nil then
		pS2clawSLASH1 = script:FindFirstChild("PS2clawSLASH1") or script:FindFirstChildWhichIsA("Sound")
	end

	if pS2clawSLASH1 == nil then
		return
	end

	local clone = pS2clawSLASH1:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, 1)
end