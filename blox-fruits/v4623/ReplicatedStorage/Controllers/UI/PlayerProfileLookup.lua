local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Stats"):tag("UI"):tag("Controller"):traceback():display():build()
local PlayerLookup = require(game.ReplicatedStorage.React.Components.PlayerLookup)
require(game.ReplicatedStorage.React.Components.PlayerLookup.Types)
local playerGui

if RunService:IsRunning() then
	local Players2 = game:GetService("Players")
	playerGui = Players2.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local class = {}
class.__index = class

function class:Open(flag: boolean?)
	if self._IsOpen then
		v.trace("already open")
		return
	end

	self._IsOpen = true
	pcall(function()
		game.ReplicatedStorage.Remotes.MarkPlayerProfileOpened:FireServer()
		local Global = require(game.ReplicatedStorage.Global)
		Global.closeOthers("PlayerProfileLookup")
	end)

	if flag == true then
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
	end

	self._OnOpen:Fire()
end

function class:IsOpen()
	return self._IsOpen
end

function class:Close()
	v.info(":Close()")

	if not self._IsOpen then
		v.trace("already closed")
		return
	end

	self._IsOpen = false
	self._OnClose:Fire()
	self.OnClosed:Fire()
end

return ServiceLocker(function()
	v.info("init()")
	local object = setmetatable({
		IsInitialized = true,
		_Connections = {},
		_IsOpen = false,
		OnClosed = Signal.new(),
		_OnOpen = Signal.new(),
		_OnClose = Signal.new(),
		_Controllers = {}
	}, class)

	local function component(_)
		local state, setState = React.useState(false)
		local state2, setState2 = React.useState(nil)
		local state3, setState3 = React.useState(nil)
		local state4, setState4 = React.useState(nil)
		local ref = React.useRef(true)
		local ref2 = React.useRef(false)
		React.useEffect(function()
			local function updateServer(p)
				local v2 = {}

				for _, v3 in Players:GetPlayers() do
					if v3 ~= p then
						table.insert(v2, {
							UserId = v3.UserId,
							Username = v3.Name,
							Context = "In your server.",
							IsOnline = true,
							IsFriend = false
						})
					end
				end

				setState2(v2)
			end

			local playerAddedConnection = Players.PlayerAdded:Connect(function()
				updateServer()
			end)
			local playerRemovingConnection = Players.PlayerRemoving:Connect(updateServer)
			updateServer()
			return function()
				playerAddedConnection:Disconnect()
				playerRemovingConnection:Disconnect()
			end
		end, {})
		React.useEffect(function()
			if not state or ref2.current then
				return
			end

			ref2.current = true

			-- equivalent calls inferred from this helper; original call sites unknown
			local function fetchCategory(p, callback)
				task.spawn(function()
					local success, result = pcall(function()
						return game.ReplicatedStorage.Remotes.GetPlayerLookupInfo:InvokeServer(p)
					end)

					if ref.current and success and typeof(result) == "table" then
						callback(result)
					end
				end)
			end

			fetchCategory("Recent", setState4) -- equivalent call inferred; original call site unknown
			fetchCategory("Global", setState3) -- equivalent call inferred; original call site unknown
		end, { state })
		React.useEffect(function()
			return function()
				ref.current = false
			end
		end, {})
		React.useEffect(function()
			local connection = object._OnOpen:Connect(function()
				setState(true)
			end)
			local onClosedConnection = object.OnClosed:Connect(function()
				setState(false)
			end)
			return function()
				connection:Disconnect()
				onClosedConnection:Disconnect()
			end
		end, {})
		return PlayerLookup({
			Open = state,
			SetOpen = function(flag: boolean)
				if flag then
					object:Open()
				else
					object:Close()
				end
			end,
			DefaultCategory = "Server",
			Server = state2 or {},
			Global = state3 or {},
			Recent = state4 or {},
			ServerLoading = state2 == nil,
			GlobalLoading = state3 == nil,
			RecentLoading = state4 == nil
		})
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "PlayerProfileLookupRoot"
	screenGui.Parent = playerGui
	screenGui.DisplayOrder = 1
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(screenGui)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(React.createElement(component), screenGui)))
	end)
	local Global = require(game.ReplicatedStorage.Global)

	function Global.closeProfileLookup()
		object:Close()
	end

	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("PlayerProfileLookup", function(...)
			return object:Open(...)
		end, function()
			return object:Close()
		end, function()
			return object:IsOpen()
		end)
	end)
	return object
end, function(list)
	for _, _Connection in list._Connections do
		_Connection:Disconnect()
	end

	setmetatable(list, nil)
	table.clear(list)
end)