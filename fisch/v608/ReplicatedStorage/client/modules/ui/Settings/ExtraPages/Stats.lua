local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Trove = require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.packages.Net)
local playerStats = require(ReplicatedStorage.shared.playerStats)
require(ReplicatedStorage.shared.playerStats.Types)
local mutations = require(ReplicatedStorage.shared.modules.fishing.mutations)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local SharedDataHelper = require(ReplicatedStorage.shared.modules.SharedDataHelper)
local SharedPlayerStats = require(ReplicatedStorage.shared.modules.SharedPlayerStats)
local maid = Trove.new()
local menu2 = HudController:GetSafeZone():WaitForChild("menu2")
local stats = menu2.mainframe.selectedpage.stats
local v = {}
local instancesByClone = {}
local clonesById = {}
local Stats = {}
local v2 = {}

for k, playerStat in playerStats do
	if not playerStat.Parent then
		table.insert(v, k)
	end
end

table.sort(v, function(a, b)
	return playerStats[a].Name < playerStats[b].Name
end)

function Stats:addStat(layoutOrder: number, p: number)
	local clone = script.statTemplate:Clone()
	clone.Name = self.Id
	clone.LayoutOrder = layoutOrder
	clone.statName.Text = self.Name
	clone.statName.UIPadding.PaddingLeft = UDim.new(p * 0.15, 0)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		if self._IsSubstat then
			local subStat = SharedPlayerStats.GetSubStat(localPlayer, self.Parent, self.Id)
			clone.statValue.Text = NumberUtils:Comma(subStat)
		else
			local _, text = SharedPlayerStats.GetStatWithDisplay(localPlayer, self.Id)

			if text then
				clone.statValue.Text = text
			end
		end
	end

	local colorGradient

	if rarities.Rarities[self.Id] then
		colorGradient = rarities.Rarities[self.Id].ColorGradient or rarities.Rarities[self.Id].Color
	elseif mutations.Mutations[self.Id] then
		colorGradient = mutations.Mutations[self.Id].Color
	end

	if typeof(colorGradient) == "ColorSequence" then
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = colorGradient
		uIGradient.Parent = clone.statName
	elseif typeof(colorGradient) == "Color3" then
		clone.statName.TextColor3 = colorGradient
	end

	update() -- equivalent call inferred; original call site unknown

	if self.Type == "legacy" then
		local legacyPath = SharedDataHelper.readLegacyPath(localPlayer, self.Path)

		if legacyPath then
			maid:Connect(legacyPath.Changed, update)
		end
	elseif self.Type == "newformat" then
		maid:Add(playerDataReplicator:Listen(self.Path, update))
	elseif self.Type == "newstat" then
		maid:Add(playerDataReplicator:Listen({ "NewStats", self.Path }, update))
	end

	clone.Parent = stats.scroll
	instancesByClone[clone] = self
	maid:Add(clone)
	local v3 = false

	if self.Children and #self.Children > 0 then
		clonesById[self.Id] = clone

		for _, v4 in self.Children do
			layoutOrder = Stats.addStat(playerStats[v4], layoutOrder + 1, p + 1)
			v3 = true
		end
	end

	if self.SubstatKey then
		clonesById[self.Id] = clone
		local allSubStats = SharedPlayerStats.GetAllSubStats(localPlayer, self.Id)
		local v4 = {}

		for k in allSubStats do
			table.insert(v4, k)
		end

		if self.SubstatSort == "rarity" then
			table.sort(v4, function(a, b)
				return rarities.Rarities[a].Order < rarities.Rarities[b].Order
			end)
		else
			table.sort(v4)
		end

		for _, id in v4 do
			local name

			if typeof(self.SubstatNameFormat) == "string" then
				name = self.SubstatNameFormat:format(id)
			elseif typeof(self.SubstatNameFormat) == "function" then
				name = self.SubstatNameFormat(id) or id
			else
				name = id
			end

			local v7 = {
				Id = id,
				Type = "newformat",
				Path = { "NewStats", self.SubstatKey, id },
				Name = name,
				Parent = self.Id,
				_IsSubstat = true
			}
			layoutOrder = Stats.addStat(v7, layoutOrder + 1, p + 1)
			v3 = true
		end
	end

	if not v3 then
		return layoutOrder + 1
	end

	clone.Active = true
	clone.AutoButtonColor = true
	clone.Interactable = true
	clone.Selectable = true
	clone.BackgroundTransparency = 0.75
	clone.dropdownIcon.Visible = true
	clone.statName.UIPadding.PaddingLeft += UDim.new(0.1, 0)
	clone.dropdownIcon.ImageRectOffset = Vector2.new(v2[self.Id] and 0 or 64)
	maid:Add(clone.Activated:Connect(function()
		v2[self.Id] = not v2[self.Id]
		clone.dropdownIcon.ImageRectOffset = Vector2.new(v2[self.Id] and 0 or 64)
		Stats.updateSearch()
	end))
	return layoutOrder + 1
end

function Stats.updateSearch()
	local v3 = menu2.mainframe.searchBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", "")
	local v4 = {}
	local count = 0
	local v5 = nil

	for k, v6 in instancesByClone do
		local clone = table.clone(v6.Aliases or table.create(3))
		table.insert(clone, v6.Id)
		table.insert(clone, v6.Name)
		table.insert(clone, k.statName.LocalizedText)
		local v7 = v6.Parent and v2[v6.Parent]
		local visible

		if v3 == "" then
			visible = not v7
		else
			visible = false
		end

		if not v7 then
			for _, v10 in clone do
				if visible then
					break
				end

				if v10:lower():gsub("<.->", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", ""):find(v3, 1, true) == nil then
					visible = false
				else
					visible = true
				end
			end
		end

		if visible and not v4[k] then
			count += 1
		end

		k.Visible = visible
		v4[k] = true

		if visible and v6.Parent then
			v5 = k

			while v6 and v6.Parent do
				v6 = playerStats[v6.Parent]
				local v9 = v6 and clonesById[v6.Id]

				if not v9 then
					continue
				end

				if not v4[v9] then
					count += 1
				end

				v9.Visible = true
				v4[v9] = true
			end
		else
			v5 = k
		end
	end

	if v5 then
		stats.scroll.CanvasSize = UDim2.fromOffset(0, v5.AbsoluteSize.Y * (count + 5))
	end
end

function Stats.loadStats()
	maid:Clean()
	maid:Add(function()
		table.clear(instancesByClone)
		table.clear(clonesById)
	end)
	local v3 = 1

	for _, v4 in v do
		v3 = Stats.addStat(playerStats[v4], v3, 0)
	end

	Stats.updateSearch()
	maid:Add(menu2.mainframe.searchBox:GetPropertyChangedSignal("Text"):Connect(Stats.updateSearch))
end

function Stats.unload()
	maid:Clean()
end

function Stats.init()
	menu2:GetPropertyChangedSignal("Visible"):Connect(function()
		if not menu2.Visible then
			Stats.unload()
		elseif stats.Visible then
			Stats.loadStats()
		end
	end)
	stats:GetPropertyChangedSignal("Visible"):Connect(function()
		if not stats.Visible then
			Stats.unload()
		elseif menu2.Visible then
			Stats.loadStats()
		end
	end)
end

return Stats