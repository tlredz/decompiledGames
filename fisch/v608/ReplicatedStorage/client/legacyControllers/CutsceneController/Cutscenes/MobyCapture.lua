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

-- equivalent calls inferred from this helper; original call sites unknown
local function setPlayerState(player, p, anchored)
	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	humanoidRootPart.Anchored = anchored
	PlayerController:ToggleControls(not p)
	ProximityPromptService.Enabled = not p
end

return {
	Start = function(_, player, childName: string)
		return Promise.new(function(callback, _, _)
			local WAIT_INTERVAL = 1.5
			local character = player.Character

			if not character then
				return callback()
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")
			local animator = humanoid and humanoid:FindFirstChild("Animator")

			if not (humanoidRootPart and humanoid and animator) then
				return callback()
			end

			local clone = sound:Clone()
			clone.TimePosition = 0
			clone.Parent = sound.Parent
			local Debris = game:GetService("Debris")
			Debris:AddItem(clone, 25)
			local v = player == localPlayer

			if v then
				setPlayerState(player, true, true) -- equivalent call inferred; original call site unknown
				CutsceneController:DisableAllScreens(9.5)
				CutsceneController:Fade(3, 0.4, 0.4)
			end

			local cFrame = humanoidRootPart.CFrame
			local cFrame2 = cFrame * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.new(-41, 0, 0.5)
			humanoidRootPart.CFrame = cFrame2
			local clone2 = script:WaitForChild("Models"):WaitForChild(childName):Clone()
			clone2.Parent = workspace
			clone2.PrimaryPart.CFrame = cFrame2 * CFrame.Angles(0, 3.141592653589793, 0)
			local clone3 = script:WaitForChild("Camera"):Clone()
			clone3.Parent = workspace
			clone3.PrimaryPart.CFrame = cFrame2
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

			if v then
				CutsceneController:ShowBars(10.450000000000001, 0.1, 0.1)
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				renderSteppedConnection = RunService.RenderStepped:Connect(function()
					workspace.CurrentCamera.CFrame = clone3:WaitForChild("Head").CFrame
				end)
			end

			track:Play(nil, nil, 1)
			track3:Play(nil, nil, 1)
			track2:Play(nil, nil, 1)
			pcall(function()
				local tool = player.Character:FindFirstChildOfClass("Tool")
				tool.handle.WeldToArm.C0 = CFrame.new(-0.151, -1.013, -0.25) * CFrame.Angles(
					0.6108652381980153,
					-0.4363323129985824,
					-2.9670597283903604
				)
				task.delay(6.45, function()
					local tool = player.Character:FindFirstChildOfClass("Tool")
					tool.handle.WeldToArm.C0 = CFrame.new(-0.151, -1.013, -0.25) * CFrame.Angles(
						0.2617993877991494,
						-0.4363323129985824,
						-2.6179938779914944
					)
				end)
			end)

			if v then
				clone.TimePosition = 0
				clone:Play()
			else
				clone.TimePosition = 0
				clone.Parent = humanoidRootPart
				clone:Play()
				clone.TimePosition = 0
			end

			task.wait(8.55)

			if v then
				CutsceneController:Fade(3, 0.4, 0.4)
			end

			task.wait(WAIT_INTERVAL)

			if v then
				renderSteppedConnection:Disconnect()
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end

			clone2:Destroy()
			clone3:Destroy()
			humanoidRootPart.CFrame = cFrame

			if v then
				setPlayerState(player, false, false) -- equivalent call inferred; original call site unknown
			end

			pcall(function()
				local tool = player.Character:FindFirstChildOfClass("Tool")
				tool.handle.WeldToArm.C0 = CFrame.new(-0.151, -1.013, -0.25) * CFrame.Angles(
					-1.5707963267948966,
					-3.141592653589793,
					0
				)
			end)
			task.wait(WAIT_INTERVAL)
			callback()
		end)
	end
}