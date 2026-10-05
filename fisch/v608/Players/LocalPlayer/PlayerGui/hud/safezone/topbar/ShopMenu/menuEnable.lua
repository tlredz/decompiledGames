local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GiftController = require(ReplicatedStorage2.client.legacyControllers.GiftController)

function OpenToggle()
	local shop = script:FindFirstAncestor("safezone"):WaitForChild("shop")
	shop.Visible = not script:FindFirstAncestor("safezone"):WaitForChild("shop").Visible

	if script:FindFirstAncestor("safezone"):WaitForChild("shop").Visible ~= true then
		return
	end

	local UserInputService = game:GetService("UserInputService")

	if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
		local GamepadService = game:GetService("GamepadService")
		GamepadService:EnableGamepadCursor(script:FindFirstAncestor("safezone"):WaitForChild("shop"))
	end

	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	fx:PlaySound(
		ReplicatedStorage3:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("popup"),
		script.Parent,
		true
	)
end

script.Parent.Activated:Connect(function()
	if not script:FindFirstAncestor("safezone"):WaitForChild("shop").Visible then
		if GiftController.Prompted then
			return
		end

		if GiftController.isGifting then
			GiftController:EndPrompt()
		end
	end

	OpenToggle()
end)
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage3.client.legacyControllers.InputController):Get("Gamepad").ButtonDown:Connect(function(p, flag: boolean?)
	if flag == true or p ~= Enum.KeyCode.ButtonB or script:FindFirstAncestor("safezone"):WaitForChild("shop").Visible ~= true or GiftController.Prompted then
		return
	end

	if GiftController.isGifting then
		GiftController:EndPrompt()
	end

	OpenToggle()
end)
script.Parent.MouseEnter:Connect(function()
	local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
	fx:PlaySound(
		ReplicatedStorage4:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("select"),
		script.Parent,
		true
	)
end)

local function checkToHide()
	if script:FindFirstAncestor("safezone"):WaitForChild("menu").Visible == true or script:FindFirstAncestor("safezone"):WaitForChild("bestiary").Visible == true or script:FindFirstAncestor("safezone"):WaitForChild("equipment").Visible == true or script:FindFirstAncestor("safezone"):WaitForChild("shipwright").Visible == true or script:FindFirstAncestor("safezone"):WaitForChild("OfficialMerch").Visible == true then
		local shop = script:FindFirstAncestor("safezone"):WaitForChild("shop")
		shop.Visible = false
	end
end

script:FindFirstAncestor("safezone"):WaitForChild("bestiary").Changed:Connect(function()
	checkToHide()
end)
script:FindFirstAncestor("safezone"):WaitForChild("equipment").Changed:Connect(function()
	checkToHide()
end)
script:FindFirstAncestor("safezone"):WaitForChild("shipwright").Changed:Connect(function()
	checkToHide()
end)
script:FindFirstAncestor("safezone"):WaitForChild("menu").Changed:Connect(function()
	checkToHide()
end)
script:FindFirstAncestor("safezone"):WaitForChild("OfficialMerch").Changed:Connect(function()
	checkToHide()
end)
game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
	if child.Name == "reel" then
		local TweenService = game:GetService("TweenService")
		local Lighting = game:GetService("Lighting")
		TweenService:Create(
			Lighting:WaitForChild("uiblur"),
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Size = 0
			}
		):Play()
		local TweenService2 = game:GetService("TweenService")
		local Lighting2 = game:GetService("Lighting")
		TweenService2:Create(
			Lighting2:WaitForChild("uicc"),
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Brightness = 0,
				TintColor = Color3.fromRGB(255, 255, 255),
				Saturation = 0
			}
		):Play()
		local shop = script:FindFirstAncestor("safezone"):WaitForChild("shop")
		shop.Visible = false
	end
end)