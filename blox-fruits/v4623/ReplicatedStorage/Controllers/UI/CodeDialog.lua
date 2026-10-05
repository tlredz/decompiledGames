local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local CodeDialog = require(game.ReplicatedStorage.React.Components.CodeDialog)
local useDelayedState = require(game.ReplicatedStorage.React.Hooks.useDelayedState)
local redeem = game.ReplicatedStorage.Remotes.Redeem
local playerGui

if RunService:IsRunning() then
	local Players = game:GetService("Players")
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local class = {}
class.__index = class

function class:Open()
	if self.IsOpen then
		return
	end

	self.IsOpen = true
	self._OnOpen:Fire()
end

function class:Close()
	if not self.IsOpen then
		return
	end

	self.IsOpen = false
	self._OnClose:Fire()
	self.OnClosed:Fire()
end

return ServiceLocker(function()
	local object = setmetatable({
		_Connections = {},
		IsInitialized = true,
		IsOpen = false,
		OnClosed = Signal.new(),
		_OnOpen = Signal.new(),
		_OnClose = Signal.new(),
		_Callbacks = {},
		_Controllers = {}
	}, class)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function buildSound(soundId: string)
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = 0.5
		table.insert(object._Callbacks, function()
			sound:Destroy()
		end)
		return sound
	end

	local sound = buildSound("rbxassetid://14920473500") -- equivalent call inferred; original call site unknown
	local sound2 = buildSound("rbxassetid://14920473264") -- equivalent call inferred; original call site unknown

	local function component(_)
		local state, setState = React.useState(object.IsOpen)
		local errorMessage, v2 = useDelayedState(nil)
		React.useEffect(function()
			local connection = object._OnClose:Connect(function()
				setState(false)
			end)
			local connection2 = object._OnOpen:Connect(function()
				setState(true)
			end)
			return function()
				connection:Disconnect()
				connection2:Disconnect()
			end
		end, {})
		return React.createElement(CodeDialog, {
			ZIndex = 2,
			OnCloseClick = function()
				object:Close()
			end,
			OnSubmitCode = not errorMessage and function(p: string)
				print("Submitting code:", p)
				local v3 = redeem:InvokeServer(p)
				print("Redeem response:", v3, "for code:", p)

				if v3 == "SUCCESS!" then
					SoundService:PlayLocalSound(sound)
					object:Close()
				else
					SoundService:PlayLocalSound(sound2)
					v2(v3 or "no response received from server", 0)
					v2(nil, 2.5)
				end
			end or nil,
			ErrorMessage = errorMessage,
			IsOpen = state
		}, {})
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "CodeDialogRoot"
	screenGui.Parent = playerGui
	screenGui.DisplayOrder = 5
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(screenGui)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(React.createElement(component, {}), screenGui)))
	end)
	return object
end, function(list)
	for _, _Connection in list._Connections do
		_Connection:Disconnect()
	end

	for _, _Callback in list._Callbacks do
		local v = _Callback
		local success, result = pcall(function(...)
			v()
		end)

		if not success then
			warn("Error while cleaning up CodeDialogController: " .. tostring(result))
		end
	end

	setmetatable(list, nil)
	table.clear(list)
end)