local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local selectJetski = HudController:GetSafeZone():WaitForChild("SelectJetski")
local textBox = selectJetski:WaitForChild("Search"):WaitForChild("TextBox")
local main = selectJetski.ships.main
local remoteEvent = Net:RemoteEvent("JetskiRacing/SelectJetski")
local SelectJetski = {}
local clonesByName = {}
local maid = Trove.new()

function SelectJetski.updateSearch()
	local v = textBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", "")

	for k, v2 in clonesByName do
		v2.Visible = v == "" or k:lower():gsub("<.->", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", ""):find(v, 1, true) ~= nil or v2.title.LocalizedText:lower():gsub(
			"<.->",
			""
		):gsub(
			"['\"′‵‘’‚‛″‶“”„‟‴‷⁗]",
			""
		):find(
			v,
			1,
			true
		) ~= nil
	end
end

function SelectJetski.load()
	SelectJetski.unload()
	local children = legacyLocalPlayerData.fetch():WaitForChild("Boats"):GetChildren()
	table.sort(children, function(a, b)
		local favorited = a:FindFirstChild("favorited")
		local favorited2 = b:FindFirstChild("favorited")
		local value = favorited and favorited.Value or false

		if value == (favorited2 and favorited2.Value or false) then
			return a.Name < b.Name
		end

		return value
	end)
	local v = playerDataReplicator:TryIndex({ "BoatRacing", "PreferredBoat" })

	for k, v2 in children do
		local v3 = vessels.library[v2.Name]

		if not v3 then
			continue
		end

		if v3.BlockRacing or v3.StupidPhysics or v3.FlyingBoat or v3.IsSubmarine or v3.Disruptive or v3.FreeMovement then
			continue
		end

		local clone = script.template:Clone()
		clone.LayoutOrder = k
		clone.Name = v2.Name
		clone.title.Text = v2.Name
		clone.icon.Image = v3.Icon or ""

		if v2.Name == v then
			clone.spawn.Text = "[Selected]"
			clone.spawn.TextColor3 = Color3.fromRGB(106, 117, 127)
			clone.spawn.border.Color = Color3.fromRGB(106, 117, 127)
		end

		clonesByName[v2.Name] = clone
		local v4 = v2

		local function selectBoat()
			remoteEvent:FireServer(v4.Name)
			selectJetski.Visible = false
			ReplicatedStorage.events.anno_localthought:Fire((`Selected <b><font color="#ffee90">{v4.Name}</font></b> for Boat Racing!`))
		end

		maid:Add(clone.Activated:Once(selectBoat))
		maid:Add(clone.spawn.Activated:Once(selectBoat))
		maid:Add(clone)
		clone.Parent = main.safezone
	end

	main.CanvasSize = UDim2.fromOffset(0, main.safezone.UIGridLayout.AbsoluteContentSize.Y)
end

function SelectJetski.unload()
	maid:Clean()
	table.clear(clonesByName)
end

function SelectJetski.init()
	selectJetski:GetPropertyChangedSignal("Visible"):Connect(function()
		if selectJetski.Visible then
			SelectJetski.load()
		else
			SelectJetski.unload()
		end
	end)
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		SelectJetski.updateSearch()
	end)
	remoteEvent.OnClientEvent:Connect(function()
		selectJetski.Visible = true
	end)
end

return SelectJetski