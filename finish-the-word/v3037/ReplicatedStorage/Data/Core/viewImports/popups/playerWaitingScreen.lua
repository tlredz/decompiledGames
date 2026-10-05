local import = _G.import("romodel")
local import2 = _G.import("iterator")
local import3 = _G.import("signalUtil")
local import4 = _G.import("viewImports")
local basic = import4:get("basic")
local avatar = import4:get("avatar").Avatar
local loadingScreen = require(script.Parent.loadingScreen)
local Players = game:GetService("Players")

-- equivalent calls inferred from this helper; original call sites unknown
local function getDefaultPlayerStates()
	local players = Players:GetPlayers()
	return import2.gen(#players, function(p)
		return p, {
			UserId = players[p].UserId,
			Loaded = false
		}
	end)
end

local function getLoadedPlayerCount(p)
	return import2.values(p):filter(function(p2)
		return p2.Loaded
	end):len()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatSeconds(lobbyTimeRemaining)
	local v = math.max(0, (math.floor(lobbyTimeRemaining or 0)))
	return string.format("%d:%02d", math.floor(v / 60), v % 60)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerCountText(list, p)
	return tostring(getLoadedPlayerCount(list)) .. "/" .. tostring(p or #list)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTitleText(list, p)
	return getPlayerCountText(list, p) .. " Players"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getWaitingText(count)
	return "Waiting For Players" .. string.rep(".", count or 3)
end

local function getCountdownText()
	return formatSeconds(workspace:GetAttribute("LobbyTimeRemaining") or 0)
end

local model = import.model(basic.EmptyElement)

function model.init(options)
	local v = options or {}
	local playerState = v.PlayerStates[v.PlayerIndex]
	return {
		Name = tostring(playerState.UserId or v.PlayerIndex),
		Size = v.Size or UDim2.new(1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		LayoutOrder = v.LayoutOrder,
		BackgroundTransparency = 1,
		PlayerIndex = v.PlayerIndex,
		PlayerStates = v.PlayerStates
	}, {
		Avatar = import.make(avatar, {
			Size = UDim2.new(1, 0, 1, 0),
			UserId = playerState.UserId,
			Image = playerState.Image
		}),
		Overlay = import.make(import.wrap(basic.Element, basic.Corner), {
			Name = "Overlay",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			CornerRadius = UDim.new(1, 0),
			ZIndex = 30
		})
	}
end

function model:render()
	local playerState = self.PlayerStates[self.PlayerIndex]
	self.Overlay.Visible = not playerState.Loaded
end

function model:spawn()
	self:render()
end

local model2 = import.model(basic.EmptyList)

function model2.init(options)
	local v = options or {}
	local playerStates = v.PlayerStates
	return {
		Name = "PlayerList",
		Size = UDim2.new(0.82, 0, 0.42, 0),
		LayoutOrder = v.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.04, 0),
		PlayerStates = playerStates
	}, import2.gen(#playerStates, function(p)
		return tostring(p), import.make(model, {
			LayoutOrder = p,
			PlayerIndex = p,
			PlayerStates = playerStates
		})
	end)
end

function model2:render()
	for _, v in pairs(self._Children) do
		if type(v.render) == "function" then
			v:render()
		end
	end
end

local model3 = import.model(basic.EmptyList)

function model3.init(options)
	local v = options or {}
	return {
		Name = "WaitingPanel",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.055, 0),
		Size = UDim2.new(0.38, 0, 0.16, 0),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0.18, 0),
		BackgroundTransparency = 1,
		PlayerStates = v.PlayerStates,
		ExpectedPlayerCount = v.ExpectedPlayerCount
	}, {
		Title = import.make(basic.TextLabel, {
			Name = "Title",
			Size = UDim2.new(0.9, 0, 0.34, 0),
			LayoutOrder = 1,
			Text = "Waiting For Players" .. string.rep(".", 3),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			StrokeWidth = 2,
			ZIndex = 20
		}),
		Players = import.make(model2, {
			LayoutOrder = 2,
			PlayerStates = v.PlayerStates
		})
	}
end

function model3:spawn()
	self.WaitingTextRunning = true
	task.spawn(function()
		local v = 0

		while self.WaitingTextRunning do
			v = v % 3 + 1
			self.Title:setText(getWaitingText(v))
			task.wait(0.4)
		end
	end)
end

function model3:render()
	self._Children.Players:render()
end

function model3:despawn()
	self.WaitingTextRunning = false
end

local model4 = import.model(loadingScreen.LoadingScreen)

function model4.init(options)
	local v = options or {}
	local playerStates = v.PlayerStates

	if not playerStates then
		playerStates = getDefaultPlayerStates()
	end

	local expectedPlayerCount = v.ExpectedPlayerCount or #playerStates
	return {
		Name = "PlayerWaitingScreen",
		PlayerStates = playerStates,
		ExpectedPlayerCount = expectedPlayerCount,
		Title = getTitleText(playerStates, expectedPlayerCount),
		Subtext = formatSeconds(workspace:GetAttribute("LobbyTimeRemaining")),
		ExtraContent = {
			WaitingPanel = import.make(model3, import.merge(v, {
				PlayerStates = playerStates,
				ExpectedPlayerCount = expectedPlayerCount
			}))
		}
	}
end

function model4:render()
	self.Content.WaitingPanel:render()
	local content = self.Content.Content
	content.BottomRight.Title:setText(getTitleText(self.PlayerStates, self.ExpectedPlayerCount))
	content.BottomRight.Subtext:setText(getCountdownText())
end

function model4:spawn()
	self.Connections = {}
	table.insert(self.Connections, import3.connect(workspace:GetAttributeChangedSignal("LobbyTimeRemaining"), function()
		self:render()
	end))
	table.insert(self.Connections, import3.remoteEvent("setPlayerWaitingLoaded", function()
		print("render", self.PlayerStates)

		for _, playerState in ipairs(self.PlayerStates) do
			print("fetching", playerState.UserId)
			local playerByUserId = Players:GetPlayerByUserId(playerState.UserId)
			playerState.Loaded = playerByUserId and playerByUserId:GetAttribute("DataLoaded") == true
		end

		self:render()
	end))
end

function model4.despawn(p)
	for _, connection in ipairs(p.Connections) do
		connection:Disconnect()
	end
end

return {
	PlayerWaitingScreen = model4
}