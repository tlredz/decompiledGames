local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
require(ReplicatedStorage.Modules.KeyImages)
require(ReplicatedStorage.Controllers.UI.MobileUIController)
local localPlayer = game.Players.LocalPlayer
local v = {
	BoundActionSoru = {
		Keyboard = "R",
		Gamepad = "ButtonR3"
	},
	BoundActionKen = {
		Keyboard = "E",
		Gamepad = "DPadLeft"
	},
	BoundActionBuso = {
		Keyboard = "J",
		Gamepad = "DPadDown"
	},
	BoundActionRaceAbility = {
		Keyboard = "T",
		Gamepad = "DPadUp"
	},
	ActivateRaceV4 = {
		Keyboard = "Y"
	},
	BoundActionDodge = {
		Keyboard = "Q"
	}
}
local v2 = {
	"DPadLeft",
	"DPadDown",
	"DPadUp",
	"ButtonRS",
	"ButtonR3",
	"ButtonTriangle"
}
return {
	OnStart = function(_)
		if LastInput:IsMobile() then
			return
		end

		local playerGui = localPlayer:WaitForChild("PlayerGui")
		local universalContextButtons = playerGui:WaitForChild("Main"):WaitForChild("BottomHUDList"):WaitForChild("UniversalContextButtons")
		local backpack = playerGui:WaitForChild("Backpack")
		local inventory = backpack:WaitForChild("Inventory")

		local function reflectVisibility()
			if inventory.Visible then
				universalContextButtons.Visible = false
			end

			local v3 = false

			for _, guiBase2d in backpack.Hotbar.Container:GetChildren() do
				if not (guiBase2d:IsA("GuiBase2d") and guiBase2d.Visible) then
					continue
				end

				v3 = true
				break
			end

			universalContextButtons.Visible = v3 and not inventory.Visible
		end

		reflectVisibility()
		inventory:GetPropertyChangedSignal("Visible"):Connect(reflectVisibility)
		backpack:WaitForChild("Hotbar").Container.ChildAdded:Connect(reflectVisibility)

		local function reflectInputType(frame, _)
			local lastInputType = UserInputService:GetLastInputType()
			local v3 = v[frame.Name]

			if not v3 then
				return
			end

			local gamepad = nil

			if string.match(lastInputType.Name, "Gamepad") then
				if v3.Gamepad then
					gamepad = v3.Gamepad
				end
			elseif v3.Keyboard then
				gamepad = v3.Keyboard
			end

			local hotkeyIcon = frame.HotkeyIcon
			local hotkeyLabel = frame.HotkeyLabel

			if gamepad then
				local visible = table.find(v2, gamepad) ~= nil
				hotkeyIcon.Visible = visible
				hotkeyIcon.Image = UserInputService:GetImageForKeyCode(Enum.KeyCode[gamepad])
				hotkeyLabel.Visible = not visible
				hotkeyLabel.Text = gamepad
				hotkeyLabel.TextLabel.Text = gamepad
			else
				hotkeyIcon.Visible = false
				hotkeyLabel.Visible = false
			end
		end

		local function inputTypeChanged()
			for _, frame in universalContextButtons:GetChildren() do
				if frame:IsA("Frame") then
					reflectInputType(frame)
				end
			end
		end

		inputTypeChanged()
		UserInputService.LastInputTypeChanged:Connect(inputTypeChanged)
		universalContextButtons.ChildAdded:Connect(function(frame)
			if frame:IsA("Frame") then
				reflectInputType(frame)
			end
		end)
		local backpack2 = playerGui:WaitForChild("Backpack")
		backpack2:GetPropertyChangedSignal("Enabled"):Connect(function()
			universalContextButtons.Visible = backpack2.Enabled
		end)
	end
}