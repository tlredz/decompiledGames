local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Trove = require(ReplicatedStorage.packages.Trove)
local Net = require(ReplicatedStorage.packages.Net)
local titles = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("character"):WaitForChild("titles"))
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local SharedDataHelper = require(ReplicatedStorage.shared.modules.SharedDataHelper)
local legacyPath = SharedDataHelper.readLegacyPath(localPlayer, "Stats.title")
local remoteEvent = Net:RemoteEvent("Titles/Equip", -1)
local remoteFunction = Net:RemoteFunction("EquipmentBag/SetFavorite", -1)
local Titles = {}
local clonesByName = {}
local maid = Trove.new()
local menu2 = HudController:GetSafeZone():WaitForChild("menu2")
local titles2 = menu2.mainframe.selectedpage.titles
local vector = Vector2.new(1e999, 1e999)

local function resolveTitle(p: string)
	if p ~= "Custom" then
		return titles[p]
	end

	local v = playerDataReplicator:TryIndex({ "CustomTitle" })

	if v and v.Text ~= "" then
		return {
			Text = v.Text,
			TextColor = Color3.fromRGB(v.TextColor.r, v.TextColor.g, v.TextColor.b),
			StrokeColor = Color3.fromRGB(v.StrokeColor.r, v.StrokeColor.g, v.StrokeColor.b),
			Bold = true,
			IsCustom = true
		}
	end

	return nil
end

function Titles.updateTitle(p: string)
	local v = clonesByName[p]

	if not v then
		print("how", p)
		return
	end

	local layoutOrder = v.LayoutOrder % 10000000

	if playerDataReplicator:TryIndex({ "FavoritedEquipment", "Titles", p }) then
		v.LayoutOrder = layoutOrder
		v.favorite.Image = "rbxassetid://104522512885034"
		v.favorite.ImageTransparency = 0
		v.favorite.ImageColor3 = Color3.fromRGB(255, 162, 0)
	else
		v.LayoutOrder = layoutOrder + 10000000
		v.favorite.Image = "rbxassetid://85452306516270"
		v.favorite.ImageTransparency = 0.5
		v.favorite.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end

	if legacyPath.Value == p then
		v.LayoutOrder = layoutOrder - 10000000
	end

	v.selected.Visible = legacyPath.Value == p
end

function Titles.addTitle(name: string, layoutOrder: number)
	local clone = script.titleTemplate:Clone()
	clone.Name = name
	local title = resolveTitle(name)

	if not title then
		clone:Destroy()
		return
	end

	local text = (title.Text or name):gsub("{name}", localPlayer.DisplayName)
	clone:SetAttribute("searchText", text)
	local font = Font.new(
		not title.CustomFont and "rbxasset://fonts/families/SourceSansPro.json" or title.CustomFont.Family or "rbxasset://fonts/families/SourceSansPro.json",
		title.CustomFont and title.CustomFont.Weight or Enum.FontWeight.Regular,
		title.CustomFont and title.CustomFont.Style or Enum.FontStyle.Normal
	)

	if title.Bold and not font.Bold then
		font.Bold = true
	end

	if title.Italic then
		font.Style = Enum.FontStyle.Italic
	end

	clone.titleContent.FontFace = font

	if name == "None" then
		clone.titleContent.Text = "None"
	else
		local titleContent = clone.titleContent

		if title.IsCustom then
			text = `<{text}>` or text
		end

		titleContent.Text = text
	end

	clone.titleContent.UISizeConstraint.MaxSize = vector
	clone.LayoutOrder = layoutOrder

	if title.StrokeColor == Color3.new(1, 1, 1) then
		clone.titleContent.TextStrokeTransparency = 1
	else
		clone.titleContent.TextStrokeColor3 = title.StrokeColor
	end

	if typeof(title.TextColor) == "ColorSequence" then
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = title.TextColor
		uIGradient.Rotation = title.GradientRotation or 45

		if title.Animated then
			uIGradient:AddTag("AnimatedGradient")
			uIGradient:SetAttribute("AnimationSpeed", title.AnimationSpeed or 1)
		end

		uIGradient.Parent = clone.titleContent
	else
		clone.titleContent.TextColor3 = title.TextColor
	end

	if title.Shadow then
		local uIShadow = Instance.new("UIShadow")

		for k, v2 in title.Shadow do
			uIShadow[k] = v2
		end

		uIShadow.Parent = clone.titleContent
	end

	maid:Add(clone.Activated:Connect(function()
		remoteEvent:FireServer(name)
	end))
	maid:Add(clone.favorite.Activated:Connect(function()
		remoteFunction:InvokeServer(
			"Titles",
			name,
			not playerDataReplicator:TryIndex({ "FavoritedEquipment", "Titles", name })
		)
	end))
	clonesByName[name] = clone
	Titles.updateTitle(name)
	clone.Parent = titles2.scroll
	maid:Add(clone)
end

function Titles.updateSearch()
	local v = menu2.mainframe.searchBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", "")

	for _, v2 in clonesByName do
		local v3 = { v2.Name, v2.titleContent.LocalizedText, v2:GetAttribute("searchText") or "" }
		local visible = v == ""

		for _, v5 in v3 do
			if visible then
				break
			end

			if v5:lower():gsub("<.->", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", ""):find(v, 1, true) == nil then
				visible = false
			else
				visible = true
			end
		end

		v2.Visible = visible
	end
end

function Titles.loadTitles()
	maid:Clean()
	vector = Vector2.new(titles2.AbsoluteSize.X * 0.8, 1e999)
	maid:Add(titles2:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		vector = Vector2.new(titles2.AbsoluteSize.X * 0.8, 1e999)

		for _, v in clonesByName do
			v.titleContent.UISizeConstraint.MaxSize = vector
		end
	end))
	maid:Add(function()
		table.clear(clonesByName)
	end)
	local allOwned = titles:GetAllOwned(localPlayer)
	local v = playerDataReplicator:TryIndex({ "CustomTitle" })

	if v and v.Text ~= "" then
		table.insert(allOwned, "Custom")
	end

	table.sort(allOwned, function(a, b)
		local title = resolveTitle(a)
		local title2 = resolveTitle(b)
		return (title and title.Text or "") < (title2 and title2.Text or "")
	end)

	for k, v2 in allOwned do
		Titles.addTitle(v2, k)
	end

	local value = legacyPath.Value
	maid:Add(legacyPath.Changed:Connect(function(p)
		Titles.updateTitle(value)
		Titles.updateTitle(p)
		value = p
	end))
	maid:Add(playerDataReplicator:ListenKeys({ "FavoritedEquipment", "Titles" }, function(p)
		Titles.updateTitle(p)
	end))
	maid:Add(legacyPath.ChildAdded:Once(Titles.loadTitles))
	maid:Add(legacyPath.ChildRemoved:Once(Titles.loadTitles))
	Titles.updateSearch()
	maid:Add(menu2.mainframe.searchBox:GetPropertyChangedSignal("Text"):Connect(Titles.updateSearch))
end

function Titles.unload()
	maid:Clean()
end

function Titles.init()
	menu2:GetPropertyChangedSignal("Visible"):Connect(function()
		if not menu2.Visible then
			Titles.unload()
		elseif titles2.Visible then
			Titles.loadTitles()
		end
	end)
	titles2:GetPropertyChangedSignal("Visible"):Connect(function()
		if not titles2.Visible then
			Titles.unload()
		elseif menu2.Visible then
			Titles.loadTitles()
		end
	end)
end

return Titles