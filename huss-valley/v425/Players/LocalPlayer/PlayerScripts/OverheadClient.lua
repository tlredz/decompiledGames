local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local presentation = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation")
local OverheadConfig = require(presentation:WaitForChild("OverheadConfig"))
local overheadUI = presentation:WaitForChild("UITemplates"):WaitForChild("OverheadUI")
local OverheadView = require(presentation:WaitForChild("OverheadView"))
local VerifiedName = require(presentation:WaitForChild("VerifiedName"))
local v = {}

local function clear(state)
	if state.characterConnections then
		for _, characterConnection in state.characterConnections do
			characterConnection:Disconnect()
		end

		table.clear(state.characterConnections)
	end

	if state.gui then
		state.gui:Destroy()
		state.gui = nil
	end
end

local function clean(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v[p] = nil

	for _, connection in v2.connections do
		connection:Disconnect()
	end

	for _, statConnection in v2.statConnections do
		statConnection:Disconnect()
	end

	clear(v2)
end

local function add(player, instance, p)
	local v2 = p or player
	clean(v2)

	if not OverheadConfig.Enabled or not instance and player == localPlayer and not OverheadConfig.ShowOwnName then
		return
	end

	local v3 = {
		connections = {},
		statConnections = {}
	}
	v[v2] = v3

	local function update()
		if not v3.gui then
			return
		end

		local content = v3.gui.Content
		content.DisplayName.RichText = true
		content.DisplayName.Text = VerifiedName.player(player)
		content.Username.Visible = false
		content.AFK.Visible = player:GetAttribute("AFK") == true
		local overheadTitle = player:GetAttribute("OverheadTitle")
		local specialRank = content.SpecialRank
		specialRank.Visible = type(overheadTitle) == "string" and overheadTitle ~= ""
		content.SpecialRank.Text = type(overheadTitle) == "string" and overheadTitle or ""
		local overheadTitleColor = player:GetAttribute("OverheadTitleColor")
		content.SpecialRank.TextColor3 = typeof(overheadTitleColor) == "Color3" and overheadTitleColor or overheadUI.Content.SpecialRank.TextColor3
		local journeyTitle = player:GetAttribute("JourneyTitle")
		local journeyTitleColor = player:GetAttribute("JourneyTitleColor")
		local journeyTitle2 = content.JourneyTitle
		journeyTitle2.Visible = type(journeyTitle) == "string" and journeyTitle ~= ""
		content.JourneyTitle.Text = type(journeyTitle) == "string" and journeyTitle or ""
		content.JourneyTitle.TextColor3 = typeof(journeyTitleColor) == "Color3" and journeyTitleColor or Color3.fromRGB(
			125,
			205,
			228
		)
		local leaderstats = player:FindFirstChild("leaderstats")
		local wins = leaderstats and leaderstats:FindFirstChild("Wins")
		content.Wins.Text = not player:GetAttribute("StatsLoaded") and "— wins" or tostring(wins and wins.Value or 0) .. " wins" or "— wins"
		local level = leaderstats and leaderstats:FindFirstChild("Level")
		local value = level and level.Value or player:GetAttribute("Level")
		content.Lvl.Text = (not player:GetAttribute("StatsLoaded") or type(value) ~= "number") and "Lv. —" or "Lv. " .. tostring(value) or "Lv. —"
		OverheadView.layout(v3.gui)
	end

	local function bindStat(child)
		if (child.Name == "Wins" or child.Name == "Level") and (child:IsA("IntValue") or child:IsA("NumberValue")) then
			table.insert(v3.statConnections, child.Changed:Connect(update))
			update()
		end
	end

	local function statsAdded(leaderstats)
		if leaderstats.Name ~= "leaderstats" then
			return
		end

		for _, statConnection in v3.statConnections do
			statConnection:Disconnect()
		end

		table.clear(v3.statConnections)

		for _, child in leaderstats:GetChildren() do
			bindStat(child)
		end

		table.insert(v3.statConnections, leaderstats.ChildAdded:Connect(bindStat))
		table.insert(v3.statConnections, leaderstats.ChildRemoved:Connect(update))
		update()
	end

	local function character(instance2)
		clear(v3)
		local humanoidRootPart = instance2:WaitForChild("HumanoidRootPart", 30)
		local humanoid = instance2:WaitForChild("Humanoid", 30)

		if not (humanoidRootPart and humanoid) or (instance or player.Character) ~= instance2 or v[v2] ~= v3 then
			return
		end

		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		local head = instance2:FindFirstChild("Head") or humanoidRootPart
		local clone = overheadUI:Clone()
		OverheadView.apply(clone)
		clone.Name = "PlayerOverhead_" .. (instance and instance:GetAttribute("BotUserId") or player.UserId)
		clone.Adornee = head
		clone.Parent = localPlayer:WaitForChild("PlayerGui")
		v3.gui = clone

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateVisibility()
			if v3.gui == clone then
				local v4

				if instance2:GetAttribute("Cloaked") == true then
					v4 = false
				else
					v4 = instance2:GetAttribute("Ghosted") ~= true
				end

				clone:SetAttribute("Concealed", not v4)
				clone.Content.Visible = v4
				clone.Enabled = v4
			end
		end

		v3.updateVisibility = updateVisibility
		v3.characterConnections = { clone:GetPropertyChangedSignal("Enabled"):Connect(function()
				if clone.Enabled and (instance2:GetAttribute("Cloaked") == true or instance2:GetAttribute("Ghosted") == true) and v3.gui == clone then
					local v4

					if instance2:GetAttribute("Cloaked") == true then
						v4 = false
					else
						v4 = instance2:GetAttribute("Ghosted") ~= true
					end

					clone:SetAttribute("Concealed", not v4)
					clone.Content.Visible = v4
					clone.Enabled = v4
				end
			end), instance2:GetAttributeChangedSignal("Cloaked"):Connect(updateVisibility), instance2:GetAttributeChangedSignal("Ghosted"):Connect(updateVisibility) }
		updateVisibility() -- equivalent call inferred; original call site unknown
		update()
		OverheadView.camera(clone, workspace.CurrentCamera)
	end

	for _, v4 in {
		"StatsLoaded",
		"Level",
		"OverheadTitle",
		"OverheadTitleColor",
		"JourneyTitle",
		"JourneyTitleColor",
		"AFK"
	} do
		table.insert(v3.connections, player:GetAttributeChangedSignal(v4):Connect(update))
	end

	table.insert(v3.connections, player:GetPropertyChangedSignal("DisplayName"):Connect(update))

	if typeof(player) == "Instance" and player:IsA("Player") then
		table.insert(v3.connections, player:GetPropertyChangedSignal("HasVerifiedBadge"):Connect(update))
	end

	table.insert(v3.connections, player.ChildAdded:Connect(statsAdded))

	if not instance then
		table.insert(v3.connections, player.CharacterAdded:Connect(character))
		table.insert(v3.connections, player.CharacterRemoving:Connect(function()
			clear(v3)
		end))
	end

	local leaderstats = player:FindFirstChild("leaderstats")

	if leaderstats then
		statsAdded(leaderstats)
	end

	if instance or player.Character then
		task.spawn(character, instance or player.Character)
	end
end

local actors = presentation.Parent:WaitForChild("Bots"):WaitForChild("Actors")

local function cloneAdded(instance)
	local cloneOwnerUserId = instance:GetAttribute("CloneOwnerUserId")

	if not cloneOwnerUserId then
		return
	end

	task.spawn(function()
		local character = instance:WaitForChild("Character", 5)
		local playerByUserId = Players:GetPlayerByUserId(cloneOwnerUserId)

		if character and character.Value and instance.Parent == actors and playerByUserId then
			add(playerByUserId, character.Value, instance)
		end
	end)
end

local childAddedConnection = actors.ChildAdded:Connect(cloneAdded)
local childRemovedConnection = actors.ChildRemoved:Connect(clean)

for _, child in actors:GetChildren() do
	local cloneOwnerUserId = child:GetAttribute("CloneOwnerUserId")

	if not cloneOwnerUserId then
		continue
	end

	local v2 = child
	local v3 = cloneOwnerUserId
	task.spawn(function()
		local character = v2:WaitForChild("Character", 5)
		local playerByUserId = Players:GetPlayerByUserId(v3)

		if character and character.Value and v2.Parent == actors and playerByUserId then
			add(playerByUserId, character.Value, v2)
		end
	end)
end

local playerAddedConnection = Players.PlayerAdded:Connect(add)
local playerRemovingConnection = Players.PlayerRemoving:Connect(clean)

for _, v2 in Players:GetPlayers() do
	add(v2)
end

local renderSteppedConnection = RunService.RenderStepped:Connect(function()
	local currentCamera = workspace.CurrentCamera

	for _, v2 in v do
		if not v2.gui then
			continue
		end

		v2.updateVisibility()
		OverheadView.camera(v2.gui, currentCamera)
	end
end)
script.Destroying:Connect(function()
	renderSteppedConnection:Disconnect()
	playerAddedConnection:Disconnect()
	playerRemovingConnection:Disconnect()
	childAddedConnection:Disconnect()
	childRemovedConnection:Disconnect()

	for k in v do
		clean(k)
	end
end)