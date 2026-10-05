local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(script.Parent.RandomUITypes)
require(ReplicatedStorage.Modules.Color)
local GamepassUtil = require(ReplicatedStorage.Modules.GamepassUtil)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local neighbors = playerGui:WaitForChild("Neighbors")
local prompts = playerGui:WaitForChild("Prompts")
local v = {
	EditHouse = Color3.fromRGB(255, 184, 42),
	Party = Color3.fromRGB(193, 152, 255),
	Language = Color3.fromRGB(193, 152, 255)
}

local function getSaturatedColor(color: Color3, p: number)
	local HSV, v2, v3 = color:ToHSV()
	return Color3.fromHSV(HSV, math.clamp(v2 * (p + 1), 0, 1), v3)
end

local function getDarkerColor(color: Color3, p: number)
	local HSV, v2, v3 = color:ToHSV()
	return Color3.fromHSV(HSV, v2, (math.clamp(v3 * (1 - p), 0, 1)))
end

local function getHoverColor(color: Color3)
	return getSaturatedColor(color, 0.2)
end

local function getTextureIdleColor(color: Color3)
	return getDarkerColor(color, 0.3)
end

local function getTextureHoverColor(_: Color3) end

return {
	Connect = {
		Color = Color3.fromRGB(189, 255, 189)
	},
	Shop = {
		Color = Color3.fromRGB(255, 176, 177),
		MatchingFrame = neighbors.Shop,
		ShowHint = false
	},
	Settings = {
		Color = Color3.fromRGB(255, 255, 161),
		MatchingFrame = neighbors.Settings
	},
	Worlds = {
		Color = Color3.fromRGB(174, 236, 255),
		MatchingFrame = game.Players.LocalPlayer.PlayerGui:WaitForChild("Worlds"):WaitForChild("Frame")
	},
	Party = {
		Color = v.Party,
		MatchingFrame = neighbors.Party
	},
	Language = {
		Color = v.Language,
		MatchingFrame = prompts.LanguageSetting
	},
	EditHouse = {
		Color = v.EditHouse,
		Callback = function(instance)
			local locked = instance:FindFirstChild("Locked")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				locked.Visible = not localPlayer:GetAttribute("HouseEditor")
			end

			localPlayer:GetAttributeChangedSignal("HouseEditor"):Connect(update)
			update() -- equivalent call inferred; original call site unknown
		end,
		OnClick = function()
			local House = require(ReplicatedStorage.Modules.Neighbors.House)

			if localPlayer:GetAttribute("HouseEditor") then
				House:EnterLocalHouse()
			else
				GamepassUtil:DisplayGamepassInfo("HouseEditor")
			end
		end
	}
}