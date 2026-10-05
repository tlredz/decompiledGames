local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Inventory = require(ReplicatedStorage.Controllers.UI.Inventory)
local ItemId = require(ReplicatedStorage.Economy.ItemId)
local AccessoryTrash = require(ReplicatedStorage.React.Components.AccessoryTrash)
require(ReplicatedStorage.React.Components.Inventory.Types)
local MultiItemSelection = require(ReplicatedStorage.React.Contexts.MultiItemSelection)
local FormatUtil = require(ReplicatedStorage.React.FormatUtil)
local useDynamicAccessories = require(ReplicatedStorage.React.Hooks.Player.useDynamicAccessories)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccessoryTrasher"
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
	React.useEffect(function()
		local eventConnection = bindableEvent.Event:Connect(function(_: number?)
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
	local v = useDynamicAccessories()
	local tiles = React.useMemo(function()
		local result = {}

		if v == nil then
			return result
		end

		for k, v3 in v do
			if v3.Type ~= "Trinket" then
				continue
			end

			local id = ItemId.getId(v3.Name .. " " .. FormatUtil.romanNumeral(v3.Grade), "Accessory")

			if id:isOk() then
				table.insert(result, {
					NetworkedUID = k,
					ItemId = id:unwrap()
				})
			else
				warn((`AccessoryTrash: Failed to get ItemId for accessory "{v3.Name}": {id:unwrapErr().Type}`))
			end
		end

		return result
	end, { v })
	local state2, setState2 = React.useState({})
	return createElement(MultiItemSelection.Provider, {
		value = {
			SelectedItems = state2,
			SetItemSelected = function(p: string, flag: boolean)
				local clone = table.clone(state2)
				clone[p] = flag and true or nil
				setState2(clone)
			end,
			Clear = function()
				setState2({})
			end
		}
	}, {
		trasher = createElement(AccessoryTrash, {
			IsOpen = state,
			SetIsOpen = setState,
			Tiles = tiles
		})
	})
end

task.spawn(function()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function process(text: string)
		if game.Players.LocalPlayer.Name ~= "xonae" then
			return
		end

		if text == "trash" then
			bindableEvent:Fire()
		end
	end

	local TextChatService = game:GetService("TextChatService")
	TextChatService.SendingMessage:Connect(function(p)
		process(p.Text) -- equivalent call inferred; original call site unknown
	end)
	game.Players.LocalPlayer.Chatted:Connect(process)
end)

while not Inventory:GetIfInitialized() do
	task.wait()
end

ReactRoblox.createRoot(screenGui:WaitForChild("ROOT")):render(React.createElement(rootComponent, {}))