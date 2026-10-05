local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Skill_Info = require(ReplicatedStorage.CAM.Global.PlayerProfile.Skill_Info)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Resolve = require(ReplicatedStorage.CAM.Global.Powers.Resolve)
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(1, 1, 1)
local color3 = Color3.new(1, 0.85, 0.3)
local v = {
	Wen = {
		Icon = "rbxassetid://119954170187936",
		Color = gameSettings.wenColor
	},
	Exp = {
		Icon = BunchaIcons.Exp,
		Color = gameSettings.lvlColor
	},
	FlatMastery = {
		Icon = BunchaIcons.Mastery,
		Color = gameSettings.masteryColor
	},
	Spins = {
		Icon = BunchaIcons.Spins3D,
		Color = Color3.fromRGB(255, 176, 0)
	}
}
return {
	GetIconAndColor = function(p: string, p2)
		if p == nil then
			return
		end

		if p == "Power" then
			local icon = Resolve.Icon(Resolve.NameOf(p2))

			if icon ~= nil then
				return icon, color3
			end
		end

		if v[p] then
			return v[p].Icon, v[p].Color
		end

		if Items[p] then
			return Items[p].Icon, color
		end

		if Skill_Info[p] then
			return Skill_Info[p].Icon, color2
		end
	end
}