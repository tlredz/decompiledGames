local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local SkinCrates = require(ReplicatedStorage.shared.modules.SkinCrates)
local eggs = require(ReplicatedStorage.shared.modules.library.eggs)
require(ReplicatedStorage.shared.modules.character.titles)
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local bait = require(ReplicatedStorage.shared.modules.library.bait)
local v = Component.new({
	Tag = "EggInfoDisplay",
	Ancestors = { workspace }
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	local showChances = p.Instance:GetAttribute("ShowChances") == true
	local enabled = p.Instance:GetAttribute("PlayerID") == tostring(localPlayer.UserId)
	local v3 = p.trove:Add(script.Egg:Clone())
	v3.Adornee = p.Instance
	v3.Parent = playerGui
	v3.Enabled = enabled
	local egg = eggs[p.Instance:GetAttribute("EggName")]

	for childName, item in ipairs(egg.Items) do
		local child = v3.Container:FindFirstChild(childName)

		if showChances then
			child.Chance.Text = item.Chance .. "%"
		end

		if item.Category == "Coins" then
			child.Icon.Image = "rbxassetid://81392339912198"
		elseif item.Category == "Embercoins" then
			child.Icon.Image = "rbxassetid://111188618947632"
		elseif item.Category == "Title" then
			child.Icon.Image = "rbxassetid://139603177427404"
		elseif item.Category == "Cosmetic Case" then
			child.Icon.Image = SkinCrates.List[item.Item].Icon
		else
			local v4 = item.Category == "Bait" and bait[item.Item] or vessels.library[item.Item]

			if v4 and v4.Icon then
				child.Icon.Image = v4.Icon
			end
		end
	end
end

function v.Stop(p)
	p.trove:Destroy()
end

return v