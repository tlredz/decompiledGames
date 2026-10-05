local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local Shop = require(game.ReplicatedStorage.Controllers.UI.Shop)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Stats"):tag("UI"):tag("Controller"):traceback():display():build()
local StatsMenu = require(game.ReplicatedStorage.React.Components.StatsMenu)
local useStatRefunds = require(game.ReplicatedStorage.React.Hooks.Player.useStatRefunds)
local useRaceRerolls = require(game.ReplicatedStorage.React.Hooks.Player.useRaceRerolls)
local playerGui

if RunService:IsRunning() then
	local Players = game:GetService("Players")
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local commF_ = game.ReplicatedStorage.Remotes.CommF_
local class = {}
class.__index = class

function class:Open()
	if self._IsOpen then
		v.trace("already open")
		return
	end

	self._IsOpen = true
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
		local state, setState = React.useState(object._IsOpen)
		local v2 = useStatRefunds()
		local v3 = useRaceRerolls()
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
		return React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Active = false
		}, {
			Menu = React.createElement(StatsMenu, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.85, 0.85),
				OnAction = function(data)
					print("info", data)

					if data.Type == "Invest" then
						commF_:InvokeServer("AddPoint", data.StatKey, data.Amount)
					elseif data.Type == "Refund" then
						if v2 and v2 > 0 then
							commF_:InvokeServer("redeemRefundPoints", "Refund Points")
						else
							Shop:BuyAsync("Refund Points")
						end
					elseif data.Type == "Reroll" then
						if v3 and v3 > 0 then
							commF_:InvokeServer("RerollRace")
						else
							Shop:BuyAsync("Change Race")
						end
					elseif data.Type == "Close" then
						object:Close()
					end
				end,
				IsOpen = state,
				OnExit = function()
					object:Close()
				end
			}, {})
		})
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "StatsRoot"
	screenGui.Parent = playerGui
	screenGui.DisplayOrder = 1
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(screenGui)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(React.createElement(component), screenGui)))
	end)
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("Stats", function()
			return object:Open()
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