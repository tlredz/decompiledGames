local createVector = vector.create
local v = {
	PrintCompletionTime = false,
	PrintObjectVariableErrors = false,
	PrintDataStoreApproximateSize = true,
	ExcludedProperties = { "BrickColor" },
	ShowHTTPWarning = false
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
local MainConvertModule = require(studioLiteFolder:WaitForChild("MainConvertModule"))
local serverFunctions = studioLiteFolder:WaitForChild("ServerFunctions")
local ClearClientWorkspaceModule = require(script.Parent.Parent.Parent.ClearClientWorkspaceModule)
local CloneLocalWorkspaceToReplicatedStorageModule = require(script.Parent.Parent.Parent:WaitForChild("CloneLocalWorkspaceToReplicatedStorageModule"))
local CloneStarterGuiForEditOrPlayModule = require(script.Parent.Parent.Parent:WaitForChild("CloneStarterGuiForEditOrPlayModule"))
local HttpService = game:GetService("HttpService")
local v2 = true
_G.OkToPlayStop = true
script.Parent.MouseButton1Click:Connect(function()
	local success, result = pcall(function()
		if v2 and _G.OkToPlayStop then
			_G.OkToPlayStop = false
			v2 = false
			local localPlayer = game.Players.LocalPlayer
			local studioGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9)
			local warningText = studioGui:WaitForChild("WarningText")
			warningText.Text = "Starting Server..."
			warningText.Visible = true
			task.wait()
			local outputFrame = studioGui:WaitForChild("OutputFrame")
			local errorTextLabel = outputFrame:WaitForChild("ScrollingFrame"):WaitForChild("ErrorTextLabel")
			errorTextLabel.Text = ""
			outputFrame.ScrollingFrame.CanvasPosition = Vector2.new(0, 0)
			outputFrame.Visible = false
			local v3 = studioGui:WaitForChild("ExplorerPanel"):WaitForChild("GetSelection"):Invoke()[1]
			_G.SelectedFullName = ""

			if v3 then
				_G.SelectedFullName = v3:GetFullName()
			end

			if _G.SL_ImageLabelsFolderClone then
				_G.SL_ImageLabelsFolderClone:Destroy()
				CloneStarterGuiForEditOrPlayModule:Edit()
			end

			local character = game.Players.LocalPlayer.Character

			if character:FindFirstChild("SL_MoveLocal") then
				character:FindFirstChild("SL_MoveLocal"):Destroy()
			end

			if character:FindFirstChild("SL_SizeLocal") then
				character:FindFirstChild("SL_SizeLocal"):Destroy()
			end

			if v3 and v3.ClassName == "Attachment" and v3:FindFirstChild("SL_AttachmentAdornee") then
				v3.SL_AttachmentAdornee:Destroy()
			end

			_G.camCFrame = workspace.CurrentCamera.CFrame

			if workspace:FindFirstChild("FlyCameraFocus") then
				_G.flyFocusCFrame = workspace.FlyCameraFocus.CFrame
			end

			for _, child in pairs(studioGui:GetChildren()) do
				if child.ClassName == "Frame" and child.Name ~= "TutorialFrame" then
					child.Visible = false
				end
			end

			studioGui.Stop.Visible = true
			studioGui.main.Enabled = false
			studioGui.HandlesB.Adornee = nil
			studioGui.HandlesG.Adornee = nil
			studioGui.HandlesR.Adornee = nil
			studioGui.ArcHandles.Adornee = nil
			studioGui.SelectionBox.Adornee = nil

			while studioLiteFolder:FindFirstChild("Play321") do
				studioLiteFolder.Play321:Destroy()
				task.wait()
			end

			local converted = MainConvertModule:Convert(
				CloneLocalWorkspaceToReplicatedStorageModule:CloneLocal("Play321"),
				v
			)
			ClearClientWorkspaceModule:ClearWorkspace()
			delay(15, function()
				warningText.Visible = false
			end)
			local v5 = tostring(HttpService:JSONEncode(converted))

			if v5:len() > 3400000 then
				serverFunctions:InvokeServer("Play", "start")

				for i = 1, 10 do
					local v6 = v5:sub((i - 1) * 3400000 + 1, i * 3400000)

					if v6 and v6:len() > 0 then
						serverFunctions:InvokeServer("Play", v6)
						task.wait()
					else
						break
					end
				end

				serverFunctions:InvokeServer("Play", "end")
			else
				local _, _ = serverFunctions:InvokeServer("Play", converted)
			end

			local character2 = localPlayer.Character or localPlayer.CharacterAdded:Wait()
			local humanoid = character2:WaitForChild("Humanoid")
			humanoid.PlatformStand = false
			local humanoidRootPart = character2:WaitForChild("HumanoidRootPart")
			humanoidRootPart.Anchored = false
			local v6 = false

			for _, child in pairs(workspace:GetChildren()) do
				if not (child.ClassName == "SpawnLocation" and child.Neutral) then
					continue
				end

				character2:PivotTo(child.CFrame * CFrame.Angles(0, 3.1415, 0) + createVector(0, 10, 0))
				v6 = true
				break
			end

			if not v6 then
				character2:PivotTo(CFrame.new(0, 10, 0))
			end

			local currentCamera = workspace.CurrentCamera
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = character2.Humanoid
			localPlayer.HealthDisplayDistance = game.StarterPlayer.HealthDisplayDistance
			localPlayer.NameDisplayDistance = game.StarterPlayer.NameDisplayDistance
			localPlayer.CameraMaxZoomDistance = game.StarterPlayer.CameraMaxZoomDistance
			localPlayer.CameraMinZoomDistance = game.StarterPlayer.CameraMinZoomDistance
			localPlayer.CameraMode = game.StarterPlayer.CameraMode
			humanoid.MaxSlopeAngle = game.StarterPlayer.CharacterMaxSlopeAngle
			humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
			localPlayer.CanLoadCharacterAppearance = game.StarterPlayer.LoadCharacterAppearance
			humanoid.JumpHeight = game.StarterPlayer.CharacterJumpHeight
			humanoid.UseJumpPower = game.StarterPlayer.CharacterUseJumpPower
			localPlayer.AutoJumpEnabled = game.StarterPlayer.AutoJumpEnabled
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			localPlayer.PlayerScripts.FlyCameraLocal.Disabled = true
			workspace.FlyCameraFocus:Destroy()
			task.wait()
			localPlayer.CameraMinZoomDistance = 0
			pcall(function()
				local StarterGui = game:GetService("StarterGui")
				StarterGui:SetCore("TopbarEnabled", true)
				local StarterGui2 = game:GetService("StarterGui")
				StarterGui2:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
			end)
			warningText.Text = "Playing"
			warningText.Visible = true
			task.wait(1)
			warningText.Visible = false
			v2 = true
			_G.OkToPlayStop = true
		end
	end)

	if not success then
		warn("SL_ERROR: " .. script.Name .. "  " .. result)
		task.wait(2)
		v2 = true
		_G.OkToPlayStop = true
	end
end)