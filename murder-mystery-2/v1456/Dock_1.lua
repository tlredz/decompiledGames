local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("SpectateService"))
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local playerGui = game.Players.LocalPlayer.PlayerGui
local parent = script.Parent.Parent
local inventory = parent:WaitForChild("Inventory")
local dock = parent:WaitForChild("Dock")
dock:WaitForChild("Tip")
local inputContext = playerGui:WaitForChild("InputContext")
local console = inputContext:WaitForChild("Console")
local main = console:WaitForChild("Main")
local dock2 = console:WaitForChild("Dock")
local shop = console:WaitForChild("Shop")
local inventory2 = console:WaitForChild("Inventory")
console:WaitForChild("Spectate")

local function openDock()
	TweenService:Create(dock, TweenInfo.new(0.2), {
		Position = UDim2.new(0.5, 0, 1, -10)
	}):Play()
	dock2.Enabled = true
	dock.Tip.TipText.Text = "CLOSE"
	dock.Tip.Icon1:RemoveTag("ButtonIcon_ButtonX")
	dock.Tip.Icon1:AddTag("ButtonIcon_ButtonB")
	inputContext.GameplayContext.Enabled = false
	ContextActionService:BindActionAtPriority("BlockJump", function() end, false, 10000, Enum.KeyCode.ButtonA)
end

local function closeDock()
	TweenService:Create(dock, TweenInfo.new(0.2), {
		Position = UDim2.new(0.5, 0, 1, 200)
	}):Play()
	dock2.Enabled = false
	dock.Tip.TipText.Text = "MENU"
	dock.Tip.Icon1:RemoveTag("ButtonIcon_ButtonB")
	dock.Tip.Icon1:AddTag("ButtonIcon_ButtonX")
	inputContext.GameplayContext.Enabled = true
	task.wait()
	ContextActionService:UnbindAction("BlockJump")
end

local function openShop()
	closeDock()
	shop.Enabled = true
	WindowService:ViewFrame("Shop")
end

local function onShopClosed()
	openDock()
end

local function openInventory()
	closeDock()
	inventory.Visible = true
	inventory2.Enabled = true
	GuiService:Select(parent.Inventory)
end

local function onInventoryClosed()
	inventory.Visible = false
	openDock()
	inventory2.Enabled = false
	GuiService.SelectedObject = nil
end

local function onInitialize()
	main:WaitForChild("OpenDock").Pressed:Connect(openDock)
	dock2:WaitForChild("CloseDock").Pressed:Connect(closeDock)
	dock2:WaitForChild("Shop").Pressed:Connect(openShop)
	dock2:WaitForChild("Inventory").Pressed:Connect(openInventory)
	shop:WaitForChild("Back").Pressed:Connect(onShopClosed)
	inventory2:WaitForChild("Back").Pressed:Connect(onInventoryClosed)
	script.CloseDock.Event:Connect(closeDock)
end

onInitialize()