local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local packages = ReplicatedStorage:WaitForChild("packages")
require(packages:WaitForChild("Trove"))
local Promise = require(packages:WaitForChild("Promise"))
local emit = require(ReplicatedStorage.packages.emit)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local localPlayer = Players.LocalPlayer

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

			local v = player == localPlayer

			if v then
				setPlayerState(player, true, true) -- equivalent call inferred; original call site unknown
				CutsceneController:DisableAllScreens(16.78)
				CutsceneController:Fade(3, 0.4, 0.4)
			end

			local cFrame = humanoidRootPart.CFrame
			local clone = script:WaitForChild("Models"):WaitForChild(childName):Clone()
			clone.Name = "CaptureFish"
			clone:PivotTo(cFrame * CFrame.Angles(0, -3.141592653589793, 0))
			clone.Parent = workspace
			local clone2 = script:WaitForChild("Camera"):Clone()
			clone2:PivotTo((cFrame - createVector(0, 2.25, 0)) * CFrame.Angles(0, -3.141592653589793, 0))
			clone2.Parent = workspace
			local clone3 = script:WaitForChild("VFX"):Clone()
			clone3:PivotTo(cFrame - createVector(0, 6.359, 0) + cFrame.LookVector * 55)
			clone3.Parent = workspace
			local clone4 = script:WaitForChild("Sound"):Clone()
			clone4.Parent = workspace
			task.spawn(function()
				clone4.Ended:Wait()
				clone4:Destroy()
			end)
			task.delay(9.356, function()
				for _, child in ipairs(clone3.Tornado.Attachment:GetChildren()) do
					child.Enabled = true
					local v2 = child
					task.delay(3.535, function()
						v2.Enabled = false
					end)
				end
			end)
			task.delay(3.987, function()
				emit.emit(clone3.Splash.Attachment)
			end)

			local function safeLoadAnimation(clone5, childName2)
				local animator2 = clone5:FindFirstChild("AnimationController") and clone5.AnimationController:FindFirstChild("Animator")

				if animator2 then
					return animator2:LoadAnimation((clone5:FindFirstChild(childName2)))
				end

				return {
					Play = function() end
				}
			end

			local v2 = safeLoadAnimation(clone, "Animation")
			local v3 = safeLoadAnimation(clone2, "Animation")
			local track = animator:LoadAnimation(script:WaitForChild("PlayerAnimation"))

			-- equivalent calls inferred from this helper; original call sites unknown
			local function playTracks()
				v2:Play(nil, nil, 1)
				v3:Play(nil, nil, 1)
				track:Play(nil, nil, 1)
			end

			task.wait(1.5)
			playTracks() -- equivalent call inferred; original call site unknown
			task.spawn(function()
				task.wait(0.116)

				if v == true then
					clone4:Play()
					return
				end

				clone4.Parent = humanoidRootPart
				clone4:Play()
			end)
			pcall(function()
				local tool = player.Character:FindFirstChildOfClass("Tool")
				tool.handle.WeldToArm.C0 = CFrame.new(-0.151, -1.013, -0.25) * CFrame.Angles(
					0.6108652381980153,
					-0.4363323129985824,
					-2.9670597283903604
				)
				task.delay(7, function()
					local tool = player.Character:FindFirstChildOfClass("Tool")
					tool.handle.WeldToArm.C0 = CFrame.new(-0.151, -1.013, -0.25) * CFrame.Angles(
						0.2617993877991494,
						-0.4363323129985824,
						-2.6179938779914944
					)
				end)
			end)
			local renderSteppedConnection

			if v then
				CutsceneController:ShowBars(18.458000000000002, 0.1, 0.1)
				local v4 = 1
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				renderSteppedConnection = RunService.RenderStepped:Connect(function()
					workspace.CurrentCamera.CFrame = clone2:WaitForChild("Torso").CFrame
					local child = script:FindFirstChild("FOV") and script.FOV:FindFirstChild(v4)

					if child then
						workspace.CurrentCamera.FieldOfView = child.Value
						v4 += 1
					end
				end)
			end

			task.wait(15.102000000000002)

			if v then
				CutsceneController:Fade(3, 0.4, 0.4)
			end

			task.wait(1.5)

			if v then
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
				end

				workspace.CurrentCamera.FieldOfView = 70
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end

			clone3:Destroy()
			clone2:Destroy()
			clone:Destroy()

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
			callback()
		end)
	end
}