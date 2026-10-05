local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local GameAudioMute = require(ReplicatedStorage.Client.GameAudioMute)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local localPlayer = Players.LocalPlayer
local v2 = nil

local function watchingCFrame(currentCamera, instance)
	local viewportSize = currentCamera.ViewportSize
	local v3 = math.max(viewportSize.X, 1) / math.max(viewportSize.Y, 1)
	local v4 = math.tan(math.rad(currentCamera.FieldOfView) / 2)
	local v5 = math.max(instance.Size.Y / 2 / v4, instance.Size.X / 2 / v4 / v3) * 1.05
	return CFrame.lookAt(instance.Position + instance.CFrame.LookVector * v5, instance.Position)
end

local v = {
	Open = function(instance, instance2, instance3)
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local currentCamera = Workspace.CurrentCamera
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

		if v2 or not humanoid or humanoid.Health <= 0 or not currentCamera or not playerGui or not instance:IsDescendantOf(Workspace) or not instance2:IsDescendantOf(instance) or currentCamera.CameraType == Enum.CameraType.Scriptable or HiddenUIHandler.IsHidden() or Tabs.IsActive() then
			return nil
		end

		local v3 = {
			Closed = Signal.new()
		}
		local connections = {}
		local v4 = nil
		local clone = nil
		local v5 = nil
		local v6 = nil
		local cameraType = currentCamera.CameraType
		local cameraSubject = currentCamera.CameraSubject
		local cFrame = currentCamera.CFrame
		local focus = currentCamera.Focus
		local flag = false
		local v7 = true
		local cFrame2 = watchingCFrame(currentCamera, instance2)
		v2 = v3

		function v3.Close()
			if flag then
				return
			end

			flag = true

			if v2 == v3 then
				v2 = nil
			end

			for _, connection in connections do
				connection:Disconnect()
			end

			if v4 then
				v4:Cancel()
				v4:Destroy()
			end

			if clone then
				clone:Destroy()
			end

			if v7 and currentCamera.Parent and Workspace.CurrentCamera == currentCamera and currentCamera.CameraType == Enum.CameraType.Scriptable and currentCamera.CameraSubject == cameraSubject then
				currentCamera.CFrame = cFrame
				currentCamera.Focus = focus
				currentCamera.CameraType = cameraType
			end

			if v5 then
				v5()
			end

			if v6 then
				v6()
			end

			v3.Closed:Fire()
			v3.Closed:Destroy()
		end

		function v3.IsClosed()
			return flag
		end

		local v9, v10 = xpcall(function()
			clone = instance3:Clone()
			clone.Name = "ForbiddenIslandWatching"
			clone.ResetOnSpawn = false
			clone.DisplayOrder = math.max(instance3.DisplayOrder, 100)
			clone.Enabled = true
			local exit = clone:FindFirstChild("Exit")
			assert(exit and exit:IsA("GuiButton"), "ForbiddenIsland exit button is missing")
			table.insert(connections, exit.Activated:Connect(v3.Close))
			table.insert(connections, clone.Destroying:Connect(v3.Close))
			v5 = GameAudioMute.Acquire()
			v6 = HiddenUIHandler.Acquire()
			clone.Parent = playerGui
			currentCamera.CameraType = Enum.CameraType.Scriptable
			v4 = TweenService:Create(
				currentCamera,
				TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					CFrame = cFrame2
				}
			)
			v4:Play()
			table.insert(connections, currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				v4:Cancel()
				cFrame2 = watchingCFrame(currentCamera, instance2)
				currentCamera.CFrame = cFrame2
			end))
			table.insert(connections, currentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
				v4:Cancel()
				cFrame2 = watchingCFrame(currentCamera, instance2)
				currentCamera.CFrame = cFrame2
			end))
			table.insert(connections, humanoid.Died:Connect(v3.Close))
			table.insert(connections, localPlayer.CharacterRemoving:Connect(v3.Close))
			table.insert(connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(v3.Close))
			table.insert(connections, instance.AncestryChanged:Connect(function()
				if not instance:IsDescendantOf(Workspace) then
					v3.Close()
				end
			end))
			table.insert(connections, instance.Destroying:Connect(v3.Close))
			table.insert(connections, UserInputService.InputBegan:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
					v3.Close()
				end
			end))
			table.insert(connections, Tabs.Activated:Connect(v3.Close))
			table.insert(connections, RunService.Heartbeat:Connect(function()
				local v11 = (currentCamera.CFrame.Position - cFrame2.Position).Magnitude > 0.05 or currentCamera.CFrame.LookVector:Dot(cFrame2.LookVector) < 0.9999 or currentCamera.CFrame.UpVector:Dot(cFrame2.UpVector) < 0.9999

				if v4.PlaybackState == Enum.PlaybackState.Playing or not v11 then
					if not instance:IsDescendantOf(Workspace) or not instance2:IsDescendantOf(instance) or clone.Parent ~= playerGui or not clone.Enabled or localPlayer.Character ~= character or humanoid.Health <= 0 or Workspace.CurrentCamera ~= currentCamera or currentCamera.CameraType ~= Enum.CameraType.Scriptable or currentCamera.CameraSubject ~= cameraSubject then
						v3.Close()
					end
				else
					v7 = false
					v3.Close()
				end
			end))
		end, debug.traceback)

		if v9 then
			return v3
		end

		v3.Close()
		warn("ForbiddenIsland fullscreen failed", v10)
		return nil
	end
}
return table.freeze(v)