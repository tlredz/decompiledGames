local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local WeaponAuras = require(script.Parent:WaitForChild("WeaponAuras"))
local v = {
	anchorParts = {
		SickleR = true,
		SickleL = true,
		SickleRight = true,
		SickleLeft = true
	},
	skipSound = true,
	skipTrails = true
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
	local tool_Accessories = instance:FindFirstChild("Tool_Accessories")
	local sickleRight

	if tool_Accessories ~= nil then
		sickleRight = tool_Accessories:FindFirstChild("SickleRight") or nil
	end

	local bloodSwingSharp = sickleRight ~= nil and sickleRight:FindFirstChild("Part") ~= nil and script:FindFirstChild("BloodSwingSharp") or script:FindFirstChild("SwingSharp")

	if bloodSwingSharp == nil then
		return
	end

	local clone = bloodSwingSharp:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, 1)
end