local FlopConfig = {
	templatePath = { "Assets", "Rigs", "BarnabyRig" },
	attachPartName = "Head",
	offset = CFrame.new(0, -4, 0),
	cooldown = 0.25,
	overlapPolicy = "queue",
	hideWhilePlaying = { "Barnaby_Geo" },
	hopAnimationIds = {
		"rbxassetid://124897295191808",
		"rbxassetid://136298347911100",
		"rbxassetid://123587475025956",
		"rbxassetid://76507475414133"
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

return FlopConfig