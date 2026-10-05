local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local colorAssets = ReplicatedStorage:WaitForChild("GuiTemplate"):WaitForChild("ColorAssets")
local GachaChance = require(moduleScript:WaitForChild("GachaChance"))
local Translate = require(moduleScript:WaitForChild("Translate"))
local ColorTable = require(moduleScript:WaitForChild("ColorTable"))
local ItemInfo = require(moduleScript:WaitForChild("ItemInfo"))
local Setting = require(moduleScript:WaitForChild("Setting"))
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
local guiEvent = otherEvent.GuiEvents:WaitForChild("GuiEvent")
local parent = script.Parent
local _ = parent.Parent.Parent.Parent
local container = parent.Container
local max_Luck = Setting.Setting.Max_Luck
local luck = localPlayer:WaitForChild("PlayerData", 60):WaitForChild("Luck", 60)
local gachaChances_Template = colorAssets:WaitForChild("GachaChances_Template")
colorAssets:WaitForChild("Rainbow_UIGradient")
local gacha = GachaChance.Gacha
local _ = ColorTable.Item
local icon = ItemInfo.Icon
local gradient = ColorTable.Gradient
local _ = ColorTable.ToolBoarder
local power = ItemInfo.Rarity.Power
local v = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Legendary = 4
}

local function GenerateIndex()
	for _, frame in ipairs(container:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	local v2 = {}

	for k, v3 in pairs(gacha) do
		local v4 = luck.Value / max_Luck
		v2[k] = v3 + (5 - v3) * v4
	end

	for k, v3 in pairs(v2) do
		local clone = gachaChances_Template:Clone()
		clone.Name = k
		clone.Icon.Image = icon[k]
		clone.Title.Text = k
		clone.Chances.Text = `{Abbreviate.Format(v3, 2)}%`
		clone.LayoutOrder = math.ceil((100 - v3) * 4) * v[power[k]]

		if power[k] == "Common" then
			clone.Description.Text = not localPlayer:GetAttribute("TH") and "Common" or Translate.Common
		elseif power[k] == "Uncommon" then
			clone.Description.Text = not localPlayer:GetAttribute("TH") and "Uncommon" or Translate.Uncommon
		elseif power[k] == "Rare" then
			clone.Description.Text = not localPlayer:GetAttribute("TH") and "Rare" or Translate.Rare
		elseif power[k] == "Legendary" then
			clone.Description.Text = not localPlayer:GetAttribute("TH") and "Legendary" or Translate.Legendary
		end

		clone.Description.UIGradient.Color = gradient[power[k]]
		clone.Description.UIStroke.UIGradient.Color = gradient[power[k]]
		clone.Visible = true
		clone.Parent = container
	end
end

guiEvent.Event:Connect(function(p)
	local menuName = p.MenuName
	local action = p.Action

	if menuName == "ChancesGacha" and action == "Open" then
		GenerateIndex()
	end
end)