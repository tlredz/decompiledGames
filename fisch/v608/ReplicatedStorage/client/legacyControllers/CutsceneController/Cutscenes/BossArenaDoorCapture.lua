local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Promise = require(packages:WaitForChild("Promise"))
require(packages:WaitForChild("Trove"))
local Observers = require(packages:WaitForChild("Observers"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local HideInstances = require(ReplicatedStorage.shared.modules.HideInstances)
local localPlayer = Players.LocalPlayer
local cframe = CFrame.new(-4354.564, -11186.232, 7172.39)
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
	Start = function(_, player, _: string)
		local v = Observers.observeCharacters(function(p, p2)
			if p == player then
				return nil
			end

			return HideInstances(p2)
		end)
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

			humanoidRootPart.CFrame = cframe
			local clone = sound:Clone()
			clone.TimePosition = 0
			clone.Parent = sound.Parent
			local Debris = game:GetService("Debris")
			Debris:AddItem(clone, 25)
			local v2 = player == localPlayer

			if v2 then
				setPlayerState(player, true, true) -- equivalent call inferred; original call site unknown
				CutsceneController:DisableAllScreens(17.5)
				CutsceneController:Fade(3, 0.4, 0.4)
			end

			local cFrame = humanoidRootPart.CFrame
			local scylla = workspace:WaitForChild("MarianaBossFight"):WaitForChild("Scylla")
			local clone2 = scylla:Clone()
			local parent = scylla.Parent
			scylla.Parent = nil
			clone2.Parent = workspace
			clone2:PivotTo(clone2:GetPivot() - createVector(0, 25, 0))
			local clone3 = script:WaitForChild("Camera"):Clone()
			clone3:PivotTo(cFrame + createVector(0, 5, 0))
			clone3.Parent = workspace
			local welds = workspace:WaitForChild("world"):WaitForChild("ScyllaDoorArena"):WaitForChild("Welds")
			TweenService:Create(welds.Left, TweenInfo.new(7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				C1 = welds.Left:GetAttribute("OpenedCFrame")
			}):Play()
			TweenService:Create(welds.Right, TweenInfo.new(7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				C1 = welds.Right:GetAttribute("OpenedCFrame")
			}):Play()

			local function safeLoadAnimation(clone4, childName)
				local animator2 = clone4:FindFirstChild("AnimationController") and clone4.AnimationController:FindFirstChild("Animator")

				if animator2 then
					return animator2:LoadAnimation((clone4:FindFirstChild(childName)))
				end

				return {
					Play = function() end
				}
			end

			local v3 = safeLoadAnimation(clone2, "Animation")
			local v4 = safeLoadAnimation(clone3, "Animation")
			local track = animator:LoadAnimation(script:WaitForChild("PlayerAnimation"))

			-- equivalent calls inferred from this helper; original call sites unknown
			local function playTracks()
				v3:Play(nil, nil, 1)
				v4:Play(nil, nil, 1)
				track:Play(nil, nil, 1)
			end

			if v2 then
				clone.TimePosition = 0
				clone:Play()
			else
				clone.TimePosition = 0
				clone.Parent = humanoidRootPart
				clone:Play()
				clone.TimePosition = 0
			end

			task.wait(1.5)
			playTracks() -- equivalent call inferred; original call site unknown
			local renderSteppedConnection

			if v2 then
				CutsceneController:ShowBars(19.25, 0.1, 0.1)
				local v5 = 1
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				renderSteppedConnection = RunService.RenderStepped:Connect(function()
					workspace.CurrentCamera.CFrame = clone3:WaitForChild("Bone").CFrame
					local child = script:FindFirstChild("FOV") and script.FOV:FindFirstChild(v5)

					if child then
						workspace.CurrentCamera.FieldOfView = child.Value
						v5 += 1
					end
				end)
			end

			task.wait(15.75)

			if v2 then
				CutsceneController:Fade(3, 0.4, 0.4)
			end

			task.wait(1.5)

			if v2 then
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
				end

				track:Stop(0)
				workspace.CurrentCamera.FieldOfView = 70
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end

			clone3:Destroy()
			clone2:Destroy()
			scylla.Parent = parent
			humanoidRootPart.CFrame = cframe + cframe.LookVector * 25

			if v2 then
				setPlayerState(player, false, false) -- equivalent call inferred; original call site unknown
			end

			callback()
		end):finally(function()
			v()
		end)
	end
}