local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local Lighting = game:GetService("Lighting")
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local modules = ReplicatedStorage:WaitForChild("client").modules
require(modules.legacyLocalPlayerData)
local Net = require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage:WaitForChild("shared").modules.Worlds)
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local GiftController = require(legacyControllers.Shop.GiftController)
require(legacyControllers.SettingsController)
local InputController = require(legacyControllers.InputController)
local gamepad = InputController:Get("Gamepad")
local globalInterface = ReplicatedStorage:WaitForChild("client"):WaitForChild("inputs"):WaitForChild("GlobalInterface")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("hud")
local safezone = hud:WaitForChild("safezone")
local topbar = safezone:WaitForChild("topbar")
local shop = safezone:WaitForChild("shop")
local main = shop:WaitForChild("Products"):WaitForChild("Views").Main
main:WaitForChild("Credits")
local HudController = {
	buttons = {}
}

function OpenToggle(p)
	local child = safezone:WaitForChild(HudController.buttons[p])
	child.Visible = not child.Visible

	if child.Visible == true then
		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			GamepadService:EnableGamepadCursor(child)
		end

		fx:PlaySound(
			ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("popup"),
			p,
			true
		)
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				FieldOfView = 60
			}
		):Play()
		TweenService:Create(
			Lighting:WaitForChild("uiblur"),
			TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Size = 10
			}
		):Play()
		TweenService:Create(
			Lighting:WaitForChild("uicc"),
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Brightness = -0.07,
				TintColor = Color3.fromRGB(184, 184, 184),
				Saturation = -0.3
			}
		):Play()
	else
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				FieldOfView = 70
			}
		):Play()
		TweenService:Create(
			Lighting:WaitForChild("uiblur"),
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Size = 0
			}
		):Play()
		TweenService:Create(
			Lighting:WaitForChild("uicc"),
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Brightness = 0,
				TintColor = Color3.fromRGB(255, 255, 255),
				Saturation = 0
			}
		):Play()
	end
end

local visibilityByFrame = {}

function HudController.RedirectPurchase(_, point: Vector2?)
	main.CanvasPosition = point or Vector2.new(0, main.Credits.AbsolutePosition.Y - main.Featured.AbsolutePosition.Y)

	if safezone:WaitForChild("shop").Visible then
		return
	end

	if not safezone:WaitForChild("shop").Visible then
		if GiftController.Prompted then
			return
		end

		if GiftController.isGifting then
			GiftController:EndPrompt()
		end
	end

	for _, frame in pairs(safezone:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		visibilityByFrame[frame] = frame.Visible
		frame.Visible = false
	end

	local shop = safezone:WaitForChild("shop")
	shop.Visible = true
	local visibleChangedConnection = nil
	visibleChangedConnection = safezone:WaitForChild("shop"):GetPropertyChangedSignal("Visible"):Connect(function(_)
		if safezone:WaitForChild("shop").Visible == false then
			for k, visible in pairs(visibilityByFrame) do
				k.Visible = visible
			end

			visibleChangedConnection:Disconnect()
			table.clear(visibilityByFrame)
		end
	end)
end

function HudController:SetupTopBar()
	for _, button in pairs(topbar:GetChildren()) do
		if not (button:IsA("TextButton") and button.Name ~= "AutoFishing") then
			continue
		end

		if button.Name == "ShopMenu" then
			HudController.buttons[button] = "shop"
		elseif button.Name == "MainMenu" then
			HudController.buttons[button] = "menu2"
		elseif button.Name == "PersonalAquarium" then
			HudController.buttons[button] = "PersonalAquarium"
		end

		local v = button
		button.Activated:Connect(function()
			local button2 = HudController.buttons[v]

			if button2 then
				if not safezone:WaitForChild(button2).Visible then
					if GiftController.Prompted then
						return
					end

					if GiftController.isGifting then
						GiftController:EndPrompt()
					end
				end

				OpenToggle(v)
			end
		end)
	end
end

function HudController.GetPlayerGui(_)
	return playerGui
end

function HudController.GetHud(_)
	return hud
end

function HudController.GetSafeZone(_)
	return safezone
end

function HudController.GetOverlayGui(_)
	return (playerGui:WaitForChild("over"))
end

function HudController.GetDeviceInsetGui(_)
	return hud:WaitForChild("deviceinset")
end

function HudController.GetBackpackGui(_)
	return playerGui:WaitForChild("backpack")
end

function HudController:Start()
	self:SetupTopBar()
	gamepad.ButtonDown:Connect(function(p, flag: boolean?)
		if flag == true or p ~= Enum.KeyCode.ButtonB or shop.Visible ~= true or GiftController.Prompted then
			return
		end

		if GiftController.isGifting then
			GiftController:EndPrompt()
		end

		OpenToggle(topbar.ShopMenu)
	end)
	globalInterface.OpenMenu.Pressed:Connect(function()
		OpenToggle(topbar.MainMenu)
	end)
	hud:GetPropertyChangedSignal("Enabled"):Connect(function()
		globalInterface.Enabled = hud.Enabled
	end)
	globalInterface.Enabled = hud.Enabled
	task.spawn(function()
		Net:RemoteEvent("HUD/Toggle").OnClientEvent:Connect(function(flag: boolean)
			local backpackGui = HudController:GetBackpackGui()
			backpackGui.Enabled = flag
			local camera = HudController:GetPlayerGui():WaitForChild("TopbarStandard"):WaitForChild("Holders"):WaitForChild("Right"):WaitForChild("Camera")
			camera.Visible = flag
		end)
	end)
end

return HudController