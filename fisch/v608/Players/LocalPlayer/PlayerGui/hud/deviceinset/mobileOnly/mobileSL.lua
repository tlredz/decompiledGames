local UserInputService = game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer
localPlayer:WaitForChild("PlayerGui")
local ProximityPromptService = game:GetService("ProximityPromptService")
local parent = script.Parent
local visible = false
parent:WaitForChild("shiftlockController").MouseButton1Click:Connect(function()
	visible = not visible
	local centerIcon = script.Parent:WaitForChild("centerIcon")
	centerIcon.Visible = visible

	if script.Parent:WaitForChild("centerIcon").Visible == true then
		local shiftlockController = script.Parent:WaitForChild("shiftlockController")
		shiftlockController.ImageColor3 = Color3.fromRGB(124, 174, 255)
		local shiftlockController_2 = script.Parent:WaitForChild("shiftlockController")
		shiftlockController_2.ImageTransparency = 0.2
	else
		local shiftlockController_3 = script.Parent:WaitForChild("shiftlockController")
		shiftlockController_3.ImageColor3 = Color3.fromRGB(255, 255, 255)
		local shiftlockController_4 = script.Parent:WaitForChild("shiftlockController")
		shiftlockController_4.ImageTransparency = 0.5
	end
end)

local function MobileShiftLock()
	if visible == true then
		local character = localPlayer.Character

		if character ~= nil then
			local head = character:FindFirstChild("Head")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if not (head and humanoidRootPart and humanoid) then
				return
			end

			local currentCamera = workspace.CurrentCamera

			if currentCamera.CameraType == Enum.CameraType.Scriptable then
				return
			end

			if humanoid and humanoidRootPart and humanoid.Health > 0 and humanoid.AutoRotate == true and humanoid.Sit == false then
				local lookVector = currentCamera.CFrame.LookVector
				humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(
					0,
					math.atan2(-lookVector.X, -lookVector.Z),
					0
				)
			end

			if head ~= nil then
				local magnitude = (currentCamera.Focus.p - currentCamera.CoordinateFrame.p).Magnitude

				if (magnitude < 2 and 1 - (magnitude - 0.5) / 1.5 or 0) < 0.5 then
					currentCamera.CFrame *= CFrame.new(1.75, 0, 0)
				end
			end
		end
	end
end

local RunService = game:GetService("RunService")
RunService:BindToRenderStep("MobileShiftLock", 201, MobileShiftLock)
parent.Visible = UserInputService.PreferredInput == Enum.PreferredInput.Touch
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	parent.Visible = UserInputService.PreferredInput == Enum.PreferredInput.Touch
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.DPadDown and not gameProcessed and ProximityPromptService.Enabled and not localPlayer:GetAttribute("FlyingLocal") then
		visible = not visible
	end
end)