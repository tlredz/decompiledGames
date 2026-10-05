local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local packages = ReplicatedStorage:WaitForChild("packages")
require(packages:WaitForChild("Trove"))
local Promise = require(packages:WaitForChild("Promise"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local localPlayer = Players.LocalPlayer
local sound = script:WaitForChild("Sound")
return {
	Start = function(_, player, childName: string)
		return Promise.new(function(callback, _, _)
			local WAIT_INTERVAL = 1.5
			local character = player.Character

			if not character then
				callback()
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				callback()
			end

			local humanoid = character:FindFirstChild("Humanoid")

			if not humanoid then
				callback()
			end

			local animator = humanoid:FindFirstChild("Animator")

			if not animator then
				callback()
			end

			local clone = sound:Clone()
			clone.TimePosition = 0.8
			clone.Parent = sound.Parent
			local Debris = game:GetService("Debris")
			Debris:AddItem(clone, 25)
			local v = player == localPlayer

			if v == true then
				humanoidRootPart.Anchored = true
				PlayerController:ToggleControls(false)
				CutsceneController:DisableAllScreens(15.62)
				ProximityPromptService.Enabled = false
			end

			if v == true then
				CutsceneController:Fade(3, 0.4, 0.4)
			end

			local cFrame = humanoidRootPart.CFrame
			local clone2 = script:WaitForChild("Models"):WaitForChild(childName):Clone()
			clone2.Parent = workspace
			clone2.PrimaryPart.CFrame = cFrame * CFrame.new(0, -100, 0)
			local clone3 = script:WaitForChild("Camera"):Clone()
			clone3.Parent = workspace
			clone3.PrimaryPart.CFrame = cFrame
			local track = nil
			local track2 = nil
			local track3 = nil
			local success, _ = pcall(function()
				track = clone2:WaitForChild("AnimationController"):WaitForChild("Animator"):LoadAnimation(clone2:WaitForChild("Animation"))
				track2 = clone3:WaitForChild("AnimationController"):WaitForChild("Animator"):LoadAnimation(clone3:WaitForChild("Animation"))
				track3 = animator:LoadAnimation(script:WaitForChild("PlayerAnimation"))
			end)

			if not success then
				track = {
					Play = function() end
				}
				track2 = {
					Play = function() end
				}
				track3 = {
					Play = function() end
				}
			end

			task.wait(WAIT_INTERVAL)
			local renderSteppedConnection

			if v == true then
				CutsceneController:ShowBars(17.182000000000002, 0.1, 0.1)
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				renderSteppedConnection = RunService.RenderStepped:Connect(function()
					workspace.CurrentCamera.CFrame = clone3:WaitForChild("Cam").CFrame
				end)
			end

			track:Play(nil, nil, 1)
			track3:Play(nil, nil, 1)
			track2:Play(nil, nil, 1)

			if v == true then
				clone.TimePosition = 0.8
				clone:Play()
			else
				clone.TimePosition = 0.8
				clone.Parent = humanoidRootPart
				clone:Play()
				clone.TimePosition = 0.8
			end

			local cFrame2 = CFrame.new((Vector3.new(cFrame.Position.X, 131.061, cFrame.Position.Z))) * (cFrame - cFrame.Position)
			clone2.PrimaryPart.CFrame = cFrame2
			task.wait(14.058)

			if v == true then
				CutsceneController:Fade(3, 0.4, 0.4)
			end

			task.wait(WAIT_INTERVAL)

			if v == true then
				renderSteppedConnection:Disconnect()
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end

			clone2:Destroy()
			clone3:Destroy()

			if v == true then
				PlayerController:ToggleControls(true)
				humanoidRootPart.Anchored = false
				ProximityPromptService.Enabled = true
			end

			task.wait(WAIT_INTERVAL)
			callback()
		end)
	end
}