local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CUI = require(ReplicatedStorage.CUI)
local CameraTools = require(script.Parent.CameraTools)
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local v = nil
local v2 = nil
local v3 = ""
local v4 = {}
local PlayerPicker = {}

local function syncHighlights()
	local target = v.getTarget()
	local spectateTarget = CameraTools.getSpectateTarget()

	for k, v5 in v4 do
		local v6

		if target == nil then
			v6 = false
		else
			v6 = target.player == k
		end

		local v7

		if v6 then
			v7 = Config.SELECTED_COLOR
		else
			v7 = v5:GetButtonOriginalColor()
		end

		v5:SetButtonColor(v7)
		local v8

		if spectateTarget == k then
			v8 = "▶ " .. k.Name
		else
			v8 = k.Name
		end

		v5:SetButtonText(v8)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pick(object, p)
	v.setTarget(PlayerPicker.toTarget(p))
	object:SetVisible(false)
end

local function render(p)
	local v5 = v2

	for _, v6 in v5.Components:GetAll() do
		v6:Destroy()
	end

	table.clear(v4)
	local otherPlayers = PlayerPicker.getOtherPlayers()

	for _, otherPlayer in otherPlayers do
		if not (v3 == "" or string.find(string.lower(otherPlayer.Name), v3, 1, true)) then
			continue
		end

		local v6 = otherPlayer
		v4[otherPlayer] = v5.Components:AddButton(function(object)
			object:SetYSize(Config.LIST_ROW_HEIGHT):SetButtonCallback(function()
				pick(p, v6) -- equivalent call inferred; original call site unknown
			end)
		end)
	end

	if next(v4) == nil then
		v5.Components:AddText(function(object)
			object:SetText(#otherPlayers == 0 and "Nobody else is in this server" or "No player matches")
		end)
	end

	syncHighlights()
end

local function build(object)
	object:SetTitle(Config.PICKER_WINDOW_ID)
	object.Components:AddField(function(object2)
		object2:SetTextVisible(false):SetPlaceholder("Search players..."):SetValue(""):SetOnChangedRaw(function(value)
			v3 = string.lower(value)

			if v2 then
				render(object)
			end
		end)
	end)
	local v5 = object.Components:AddList(function(object2)
		object2:SetSizeY(Config.PLAYER_LIST_HEIGHT)
	end)
	v2 = v5
	local v6 = {
		Players.PlayerAdded:Connect(function()
			render(object)
		end),
		Players.PlayerRemoving:Connect(function()
			task.defer(render, object)
		end),
		CameraTools.changed:Connect(syncHighlights),
		v.targetChanged:Connect(syncHighlights)
	}
	v5:GetUI().Destroying:Connect(function()
		for _, connection in v6 do
			connection:Disconnect()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function placeBeside(window, object)
	local position = object:GetPosition()
	window:SetPosition(position.X + object:GetSize().X + Config.PICKER_GAP, position.Y)
end

function PlayerPicker.getOtherPlayers()
	local result = {}

	for _, v5 in Players:GetPlayers() do
		if v5 ~= Players.LocalPlayer then
			table.insert(result, v5)
		end
	end

	table.sort(result, function(a, b)
		return string.lower(a.Name) < string.lower(b.Name)
	end)
	return result
end

function PlayerPicker.toTarget(player)
	return {
		userId = player.UserId,
		name = player.Name,
		player = player
	}
end

function PlayerPicker.open(p, object)
	v = p
	local window = CUI.GetWindow(Config.PICKER_WINDOW_ID, Config.PICKER_WINDOW_WIDTH, build)
	placeBeside(window, object) -- equivalent call inferred; original call site unknown
	window:SetVisible(true)
	render(window)
end

return PlayerPicker