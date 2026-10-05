local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local RodSkins = require(shared.modules.RodSkins)
local rods = require(shared.modules.library.rods)
local RodSkinUtils = require(shared.utils.RodSkinUtils)
local remoteFunction = Net:RemoteFunction("ChangeRodSkin")
local remoteFunction2 = Net:RemoteFunction("EquipmentBag/SetFavorite", -1)
local localPlayer = game.Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local rods2 = HudController:GetSafeZone().equipment.Container.Rods
local skins = rods2.Skins
local main = rods2.Main
local maid = Trove.new()
local color = Color3.fromRGB(161, 255, 192)
local color2 = Color3.fromRGB(81, 81, 81)
local RodSkinsEquipment = {}

function RodSkinsEquipment:UpdateSkins(p: string)
	local function createSkinSlot(value: string)
		local v = playerDataReplicator:TryIndex({ "Rods", p })

		if not v then
			return
		end

		local v2

		if value == "Default" or value == p then
			v2 = `Default/{p}`
		else
			v2 = value
		end

		local v3 = playerDataReplicator:TryIndex({ "FavoritedEquipment", "RodSkins", v2 }) == true
		local v4 = value == "Random Skin"
		local v5 = RodSkins.Skins[value] or {}
		local v6 = v4 and {
			Icon = "rbxassetid://100294078129711",
			Description = "Use a random favorited skin"
		} or v5
		local name = value == p and "Default" or value or "Default"
		local clone = script.Template:Clone()
		clone.Name = name
		local rodInfo = clone.Rod.RodInfo
		rodInfo.skinImage.Text = v6.DisplayText or name
		rodInfo.desc.Text = v6.Description or ""
		rodInfo.desc.RichText = v6.DescriptionRich
		clone.SkinImage.Image = v6.Icon or name ~= "Default" and "" or rods[p].Icon or ""

		if name == "Default" or not v6.Rarity then
			clone.Rarity.Visible = false
		else
			local rarity = RodSkins.Rarities[v6.Rarity]
			clone.Rarity.Text = v6.Rarity
			clone.Rarity.TextColor3 = rarity.Color
			clone.UIStroke.Color = rarity.Color
			clone.Gradient.BackgroundColor3 = rarity.Color
		end

		clone.Universal.Visible = v6 and v6.TargetRod and v6.TargetRod == "All"
		local equip = clone.Equip

		if v4 and v.randomSkin or v.skin == name and not v.randomSkin then
			equip.UIStroke.Color = color2
			equip.Label.TextColor3 = color2
			equip.Label.Text = "[Equipped]"
		else
			equip.UIStroke.Color = color
			equip.Label.TextColor3 = color
			equip.Label.Text = "[Equip]"
			maid:Connect(equip.Activated, function()
				if localPlayer:GetAttribute("RodEquipInProgress") then
					return
				end

				localPlayer:SetAttribute("RodEquipInProgress", true)
				equip.UIStroke.Color = color2
				equip.Label.TextColor3 = color2
				equip.Label.Text = "..."
				remoteFunction:InvokeServer(p, name)
				localPlayer:SetAttribute("RodEquipInProgress", false)
			end)
		end

		if v4 then
			clone.RodOptions.favorite.Visible = false
		else
			clone.RodOptions.favorite.Image = v3 and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
			clone.RodOptions.favorite.ImageTransparency = v3 and 0.25 or 0.5
			clone.RodOptions.favorite.ImageColor3 = v3 and Color3.fromRGB(255, 162, 0) or Color3.fromRGB(255, 255, 255)
			maid:Add(clone.RodOptions.favorite.Activated:Connect(function()
				v3 = not v3
				remoteFunction2:InvokeServer("RodSkins", v2, v3)
			end))
		end

		maid:Add(clone)
		clone.Parent = skins.ScrollingFrame
		return clone
	end

	maid:Clean()
	local allSkinsForRod = RodSkinUtils.getAllSkinsForRod(p)
	local unlockedSkinsForRod = RodSkinUtils.getUnlockedSkinsForRod(
		playerDataReplicator:TryIndex({ "RodSkins" }) or {},
		p
	)
	skins.RodName.Text = `{p} Skins`
	local skinSlot = createSkinSlot(p)
	skinSlot.LayoutOrder = -1
	local v = {}

	for k in allSkinsForRod do
		if unlockedSkinsForRod[k] then
			table.insert(v, k)
		end
	end

	local index = playerDataReplicator:Index({ "FavoritedEquipment", "RodSkins" })
	table.sort(v, function(a, b)
		local v2 = index[a] or false

		if v2 == (index[b] or false) then
			return RodSkins.Rarities[RodSkins.Skins[a].Rarity].Weight > RodSkins.Rarities[RodSkins.Skins[b].Rarity].Weight
		end

		return v2
	end)

	for i, v2 in ipairs(v) do
		local skinSlot_2 = createSkinSlot(v2)
		skinSlot_2.LayoutOrder = i
	end

	if playerDataReplicator:Index({ "HasRandomSkin" }) then
		local skinSlot_3 = createSkinSlot("Random Skin")
		skinSlot_3.LayoutOrder = 10000
	end

	maid:Add(playerDataReplicator:ListenKeys({ "RodSkins" }, function(p2)
		if table.find({ p, "All" }, RodSkinUtils.getRodForSkin(p2)) then
			RodSkinsEquipment:UpdateSkins(p)
		end
	end))
	maid:Add(playerDataReplicator:ListenKeys({ "FavoritedEquipment", "RodSkins" }, function(p2)
		if table.find({ p, "All" }, RodSkinUtils.getRodForSkin(p2)) then
			RodSkinsEquipment:UpdateSkins(p)
		end
	end))
	maid:Add(playerDataReplicator:Listen({
		{ "Rods", p, "skin" },
		{ "Rods", p, "randomSkin" }
	}, function(_)
		RodSkinsEquipment:UpdateSkins(p)
	end))
	maid:Connect(skins.Back.Activated, function()
		skins.Visible = false
		main.Visible = true
		maid:Clean()
	end)
end

return RodSkinsEquipment