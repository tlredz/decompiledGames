local localPlayer = game.Players.LocalPlayer
local ControlModule = require(localPlayer:WaitForChild("PlayerScripts", 9):WaitForChild("PlayerModule", 9):WaitForChild(
	"ControlModule",
	9
))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local serverFunctions = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("ServerFunctions")
local character = nil
local humanoid = nil
local primaryPart = nil
pcall(function()
	task.wait(0.1)
	local StarterGui = game:GetService("StarterGui")
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)
local v = 0
local v2 = 0
local v3 = 0
local linearVelocity = nil
local currentCamera = nil
local vector = Vector3.new()

function setupFlyMode()
	while true do
		local success, result = pcall(function()
			for _ = 1, 80 do
				localPlayer = game.Players.LocalPlayer
				character = localPlayer.Character

				if character then
					humanoid = character:FindFirstChildOfClass("Humanoid")
					primaryPart = character.PrimaryPart

					if localPlayer and character and character.Parent and humanoid and primaryPart then
						break
					end
				end

				task.wait(0.1)
			end

			if humanoid then
				humanoid.PlatformStand = true
				character:PivotTo(CFrame.new(0, 5000, 0))
				primaryPart.Anchored = true
				localPlayer.CameraMode = Enum.CameraMode.Classic
				local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
				local clone = ReplicatedStorage2:WaitForChild("FlyCameraFocus", 9):Clone()
				clone.Parent = workspace
				linearVelocity = clone:WaitForChild("LinearVelocity")
				currentCamera = workspace.CurrentCamera
				currentCamera.CameraType = Enum.CameraType.Track
				currentCamera.CameraSubject = clone
				localPlayer.CameraMaxZoomDistance = 10
				localPlayer.CameraMinZoomDistance = 10
				task.wait()
				currentCamera.CFrame *= CFrame.Angles(0.55, 3.1415, 0)
				_G.CameraCFrameOrig = currentCamera.CFrame
			else
				warn("SL_ char still not loaded after 8 seconds.  Try :LoadCharacter.")
				serverFunctions:InvokeServer("StopClearServerWorkspace")
			end
		end)

		if success then
			break
		end

		warn("SL_ERROR: " .. script.Name .. "  " .. result)
		task.wait(2)
	end
end

setupFlyMode()
local UserInputService = game:GetService("UserInputService")
UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseWheel and not gameProcessed and currentCamera then
		linearVelocity.VectorVelocity = currentCamera.CFrame.lookVector * input.Position.Z * 100
	end
end)
local v4 = 0
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard and not gameProcessed then
		if input.KeyCode == Enum.KeyCode.Q then
			v4 = -1
		elseif input.KeyCode == Enum.KeyCode.E then
			v4 = 1
		end
	end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard and not gameProcessed then
		if input.KeyCode == Enum.KeyCode.Q then
			v4 = 0
		elseif input.KeyCode == Enum.KeyCode.E then
			v4 = 0
		end
	end
end)
local v5 = 0
UserInputService.TouchPinch:Connect(function(_, p, _, p2)
	if p2 == Enum.UserInputState.Change or p2 == Enum.UserInputState.End and currentCamera then
		linearVelocity.VectorVelocity = currentCamera.CFrame.lookVector * (p - v5)
	end

	v5 = p
end)

while task.wait(0.1) do
	if _G.BlockCameraMovement then
		continue
	end

	if not (primaryPart and primaryPart.Position.Y > 4000) then
		setupFlyMode()
	end

	local moveVector = ControlModule:GetMoveVector()

	if moveVector ~= vector then
		v = moveVector.z < -0.2 and 1 or moveVector.z > 0.2 and -1 or 0

		if moveVector.x < -0.2 then
			vector = moveVector
			v2 = -1
		elseif moveVector.x > 0.2 then
			vector = moveVector
			v2 = 1
		else
			vector = moveVector
			v2 = 0
		end
	end

	if v2 == 0 and v == 0 and v4 == 0 then
		linearVelocity.VectorVelocity = Vector3.new()
		v3 = 0
	else
		local v6 = v3 + 5
		v3 = v6 > 90 and 90 or v6
		linearVelocity.VectorVelocity = (currentCamera.CFrame.LookVector * v + currentCamera.CFrame.RightVector * v2 + Vector3.new(
			0,
			v4,
			0
		)) * v3
	end
end