local ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
local serverFunctions = studioLiteFolder:WaitForChild("ServerFunctions")
local ClonePathGameToLocalWorkspaceModule = require(script.Parent.Parent.ClonePathGameToLocalWorkspaceModule)
local CloneStarterGuiForEditOrPlayModule = require(script.Parent.Parent.CloneStarterGuiForEditOrPlayModule)
local ClearClientWorkspaceModule = require(script.Parent.Parent.ClearClientWorkspaceModule)
_G.OkToPlayStop = true
script.Parent.MouseButton1Click:Connect(function()
	if _G.OkToPlayStop then
		_G.OkToPlayStop = false

		while true do
			local success, result = pcall(function()
				local localPlayer = game.Players.LocalPlayer
				local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
				local humanoid = character:WaitForChild("Humanoid")
				local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
				humanoid:UnequipTools()
				local studioGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9)
				local warningText = studioGui:WaitForChild("WarningText")
				warningText.Text = "Returning to edit mode..."
				warningText.Visible = true
				script.Parent.Visible = false
				ClearClientWorkspaceModule:ClearWorkspace()
				local _, _ = serverFunctions:InvokeServer("StopClearServerWorkspace")
				ClonePathGameToLocalWorkspaceModule:Load(studioLiteFolder:FindFirstChild("Play321"))
				CloneStarterGuiForEditOrPlayModule:Stop()
				CloneStarterGuiForEditOrPlayModule:Edit()
				script.Parent.Parent.TopBar.Visible = true
				script.Parent.Parent.MainBar.Visible = true
				script.Parent.Parent.ExplorerPanel.Visible = true
				script.Parent.Parent.PropertiesPanel.Visible = true
				script.Parent.Parent.SLWorkspaceFrame.Visible = true
				script.Parent.Parent.main.Enabled = true
				pcall(function()
					local StarterGui = game:GetService("StarterGui")
					StarterGui:SetCore("TopbarEnabled", false)
				end)
				localPlayer.Backpack:ClearAllChildren()
				localPlayer.PlayerScripts.FlyCameraLocal.Disabled = false
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
				humanoid.PlatformStand = true
				character:PivotTo(CFrame.new(0, 5000, 0))
				humanoidRootPart.Anchored = true

				if _G.SelectedFullName ~= "" then
					local game2 = game

					for _, childName in pairs(_G.SelectedFullName:split(".")) do
						if game2:FindFirstChild(childName) then
							game2 = game2:FindFirstChild(childName)
						end
					end

					local explorerPanel = studioGui:WaitForChild("ExplorerPanel")
					task.wait(0.4)
					explorerPanel:WaitForChild("SetSelection"):Invoke({ game2 })
				end

				task.wait(0.1)
				local flyCameraFocus = workspace:WaitForChild("FlyCameraFocus", 3)
				flyCameraFocus.CFrame = _G.flyFocusCFrame
				task.wait(0.1)
				workspace.CurrentCamera.CFrame = _G.camCFrame
				warningText.Text = "Editing"
				task.wait(1)
				warningText.Visible = false
			end)

			if success then
				break
			end

			warn("SL_ERROR: " .. script.Name .. "  " .. result)
			task.wait(2)
		end

		_G.OkToPlayStop = true
	end
end)