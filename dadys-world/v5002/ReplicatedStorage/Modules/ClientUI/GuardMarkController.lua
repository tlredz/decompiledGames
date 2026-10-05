local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local color = Color3.fromRGB(129, 215, 180)
local _ = {
	fade = 1.2,
	hold = 0.4,
	outlineFloor = 0.65
}
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function localName()
	local localPlayer = Players.LocalPlayer
	return localPlayer and localPlayer.Name or ""
end

local function refresh(instance)
	local v2 = "GuardMark:" .. instance.Name

	if instance.Parent and instance:GetAttribute("GuardedBy") == localName() then
		HighlightController:PlayHighlight(instance, "Target", {
			FillColor = color,
			FillTransparency = 1,
			OutlineColor = color,
			OutlineTransparency = 0,
			PulseFade = 1.2,
			PulseHold = 0.4,
			PulseOutlineTransparency = 0.65,
			PulseReverse = true,
			PulseSync = true,
			Priority = HighlightController.Priority.TRINKET
		}, v2)
		return
	end

	HighlightController:ClearHighlight(v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watch(child)
	if v[child] then
		return
	end

	v[child] = child:GetAttributeChangedSignal("GuardedBy"):Connect(function()
		refresh(child)
	end)
	refresh(child)
end

local function unwatch(p)
	local connection = v[p]

	if connection then
		connection:Disconnect()
	end

	v[p] = nil
	HighlightController:ClearHighlight("GuardMark:" .. p.Name)
end

return {
	setupAll = function()
		local inGamePlayers = workspace:WaitForChild("InGamePlayers", 30)

		if not inGamePlayers then
			warn("[GuardMarkController] InGamePlayers never appeared; caster highlight disabled")
			return
		end

		for _, child in ipairs(inGamePlayers:GetChildren()) do
			watch(child) -- equivalent call inferred; original call site unknown
		end

		inGamePlayers.ChildAdded:Connect(watch)
		inGamePlayers.ChildRemoved:Connect(unwatch)
	end
}