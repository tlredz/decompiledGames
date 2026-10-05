local FlopConfig = {
	templatePath = { "Assets", "Rigs", "BarnabyRig" },
	attachPartName = "HumanoidRootPart",
	offset = CFrame.new(0, 2, 0),
	cooldown = 0.25,
	overlapPolicy = "queue",
	hideWhilePlaying = { "Barnaby_Geo" },
	hopAnimationIds = {
		"rbxassetid://120439061391425",
		"rbxassetid://135889148341803",
		"rbxassetid://124362592228783",
		"rbxassetid://133003316923286",
		"rbxassetid://81484367303029"
	},
	isEnabled = function()
		local info = workspace:FindFirstChild("Info")
		local barnabyFlopEnabled = info and info:GetAttribute("BarnabyFlopEnabled")

		if barnabyFlopEnabled == nil or barnabyFlopEnabled then
			return true
		end

		return false
	end
}

function FlopConfig.resolveOverlapPolicy()
	local info = workspace:FindFirstChild("Info")

	if (info and info:GetAttribute("BarnabyFlopAlwaysPlay")) == false then
		return "single"
	end

	return FlopConfig.overlapPolicy
end

function FlopConfig.resolveOffset()
	local info = workspace:FindFirstChild("Info")
	local barnabyFlopAnchorY = info and info:GetAttribute("BarnabyFlopAnchorY")

	if type(barnabyFlopAnchorY) == "number" then
		return CFrame.new(0, barnabyFlopAnchorY, 0)
	end

	return FlopConfig.offset
end

function FlopConfig.resolveTextureOverrides(instance)
	if not instance then
		return nil
	end

	local currentSkin = instance:GetAttribute("CurrentSkin")

	if not currentSkin or currentSkin == "" or currentSkin == "Default" then
		return nil
	end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local skin = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("TowerLUT")):GetSkin(
		"Finn",
		currentSkin
	)

	if not skin then
		return nil
	end

	local success, result = pcall(require, skin)

	if success and type(result) == "table" and result.BarnabyTexture then
		return {
			Barnaby_Geo = result.BarnabyTexture
		}
	end

	return nil
end

return FlopConfig