local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Inventory = require(ReplicatedStorage.Controllers.UI.Inventory)
local AccessoryMerge = require(ReplicatedStorage.React.Components.AccessoryMerge)
require(ReplicatedStorage.React.Components.AccessoryMerge.Types)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccessoryMerge"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
local frame = Instance.new("Frame")
frame.Name = "ROOT"
frame.BackgroundTransparency = 1
frame.Size = UDim2.new(1, 0, 1, 0)
frame.Parent = screenGui
screenGui.Parent = playerGui
local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Name = "Open"
bindableEvent.Parent = screenGui
local createElement = React.createElement

function rootComponent(_)
	local state, setState = React.useState(false)
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState(nil)
	local state4, setState4 = React.useState(nil)
	local state5, setState5 = React.useState(nil)
	local setItemInSlot = React.useCallback(function(p: number, p2)
		if p == 1 then
			setState3(p2)
		elseif p == 2 then
			setState4(p2)
		elseif p == 3 then
			setState5(p2)
		end
	end)
	React.useEffect(function()
		local eventConnection = bindableEvent.Event:Connect(function(flag: boolean)
			setState2(flag)
			setState(true)
		end)
		local Global = require(game.ReplicatedStorage.Global)

		function Global.closeMergeWindow()
			setState(false)
		end

		return function()
			eventConnection:Disconnect()
		end
	end, {})
	return createElement(AccessoryMerge, {
		IsOpen = state,
		SetIsOpen = setState,
		IsReforging = state2,
		Item1 = state3,
		Item2 = state4,
		Item3 = state5,
		SetItemInSlot = setItemInSlot
	})
end

task.spawn(function()
	local function process(text: string)
		if game.Players.LocalPlayer.Name ~= "xonae" then
			return
		end

		if text == "merge" then
			bindableEvent:Fire(false)
		elseif text == "forge" then
			bindableEvent:Fire(true)
		elseif text == "buy" then
			print(game.ReplicatedStorage.Remotes.AccessoryInteract:InvokeServer("d"))
		end
	end

	local TextChatService = game:GetService("TextChatService")
	TextChatService.SendingMessage:Connect(function(p)
		process(p.Text)
	end)
	game.Players.LocalPlayer.Chatted:Connect(process)
end)

while not Inventory:GetIfInitialized() do
	task.wait()
end

ReactRoblox.createRoot(screenGui:WaitForChild("ROOT")):render(React.createElement(rootComponent, {}))