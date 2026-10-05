local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local TitlesMenu = require(ReplicatedStorage.React.Components.TitlesMenu)
require(ReplicatedStorage.React.Components.TitlesMenu.Types)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TitlesMenu"
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
local bindableEvent2 = Instance.new("BindableEvent")
bindableEvent2.Name = "Closed"
bindableEvent2.Parent = screenGui

local function rootComponent()
	local state, setState = React.useState(false)
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState("Titles")
	local state4, setState4 = React.useState("All")
	local state5, setState5 = React.useState("")
	local state6, setState6 = React.useState("")
	local state7, setState7 = React.useState("")
	local state8, setState8 = React.useState({})
	local state9, setState9 = React.useState({})
	local updateFromServer = React.useCallback(function()
		local v2, v3, v4, v5 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("getTitles")
		setState6(v5)
		setState7(v3)
		setState8(v2)
		setState9(v4)
	end)
	local setIsOpen = React.useCallback(function(flag: boolean)
		if flag == false then
			bindableEvent2:Fire()
		end

		setState(flag)
	end)
	React.useEffect(function()
		local eventConnection = bindableEvent.Event:Connect(function(_: number?)
			updateFromServer()
			setState5("")
			setState4("All")
			setState3("Titles")
			setIsOpen(true)
		end)
		return function()
			eventConnection:Disconnect()
		end
	end, {})
	return React.createElement(TitlesMenu, {
		UpdateFromServer = updateFromServer,
		IsOpen = state,
		SetIsOpen = setIsOpen,
		FilterDropdownEnabled = state2,
		SetFilterDropdownEnabled = setState2,
		Category = state3,
		SetCategory = setState3,
		SearchTerm = state5,
		SetSearchTerm = setState5,
		FilterOption = state4,
		SetFilterOption = setState4,
		CurrentTitle = state6,
		CurrentTitleColor = state7,
		TitleList = state8,
		TitleColorList = state9
	})
end

ReactRoblox.createRoot(screenGui:WaitForChild("ROOT")):render(React.createElement(rootComponent, {}))