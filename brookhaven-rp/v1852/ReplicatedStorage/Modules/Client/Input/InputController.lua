local InputController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadService = game:GetService("GamepadService")
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local ClickDetectorWithTool = require(ReplicatedStorage.Modules.Client.Components.UI.ClickDetectorWithTool)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local v = false
local v2 = 0

function InputController.FrameworkInit()
	local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
	v = FeatureFlagsConfig
end

function InputController.IsValidMouseClick(p, p2)
	return not p2 and p.UserInputType == Enum.UserInputType.MouseButton1
end

function InputController.IsValidTouchInput(p, p2)
	return not p2 and p.UserInputType == Enum.UserInputType.Touch
end

function InputController.IsValidVirtualCursorClick(p)
	return p.UserInputType == Enum.UserInputType.Gamepad1 and p.KeyCode == Enum.KeyCode.ButtonA and GamepadService.GamepadCursorEnabled
end

function InputController.IsValidGamepadInput(data, p)
	local v3 = not p

	if v3 then
		if data.UserInputType == Enum.UserInputType.Gamepad1 and data.UserInputState == Enum.UserInputState.Begin then
			return data.KeyCode == Enum.KeyCode.ButtonR2
		else
			return false
		end
	end

	return v3
end

function InputController.IsValidInput(p, p2)
	return InputController.IsValidMouseClick(p, p2) or InputController.IsValidTouchInput(p, p2) or InputController.IsValidVirtualCursorClick(p) or InputController.IsValidGamepadInput(
		p,
		p2
	)
end

function InputController.FrameworkStart()
	local UserInputService = game:GetService("UserInputService")
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local currentCamera = workspace.CurrentCamera
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not InputController.IsValidInput(input, gameProcessed) then
			return
		end

		if not v.IsPlayerEligibleForFeatureFlag(localPlayer, "ToolFeedbackImprovement") then
			return false
		end

		local instance = nil

		if input.UserInputType == Enum.UserInputType.Touch then
			local screenPointToRay = currentCamera:ScreenPointToRay(input.Position.X, input.Position.Y)
			local raycastResult = workspace:Raycast(screenPointToRay.Origin, screenPointToRay.Direction * 100)

			if raycastResult then
				instance = raycastResult.Instance
			end
		else
			instance = localPlayer:GetMouse().Target
		end

		local tool = localPlayer.Character:FindFirstChildOfClass("Tool")

		if not (tool and instance) then
			return
		end

		local clickDetector = instance:FindFirstChildOfClass("ClickDetector")

		if not clickDetector then
			local model = instance:FindFirstAncestorOfClass("Model")

			if not model then
				return
			end

			clickDetector = model:FindFirstChildOfClass("ClickDetector")

			if not clickDetector then
				return
			end
		end

		if tool.Name == "PropMaker" and clickDetector:IsDescendantOf(game.Workspace.WorkspaceCom["001_TrafficCones"]) then
			return
		end

		if clickDetector:HasTag("ClickDetectorWithTool") then
			local component = ComponentUtil.GetComponentFromInstance(clickDetector, ClickDetectorWithTool)

			if component then
				component:HoldingToolFire(localPlayer)
			end
		else
			local serverTimeNow = workspace:GetServerTimeNow()

			if serverTimeNow - v2 > 2 then
				v2 = serverTimeNow
				local parent = clickDetector.Parent
				local name = parent.Name

				if name == "BabyBoy" or name == "BabyGirl" then
					return
				end

				if (parent:FindFirstChild("ShoppingCart") or parent:FindFirstChild("Fridge")) and tool.Name == "ShoppingCart" then
					return
				else
					NotificationController.NotifyCenter("Un-equip your tool first!")
				end
			end
		end
	end)
end

return InputController