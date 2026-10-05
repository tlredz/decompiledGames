local createVector = vector.create
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Promise = require(packages:WaitForChild("Promise"))
require(packages:WaitForChild("Trove"))
local Observers = require(packages:WaitForChild("Observers"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
local HideInstances = require(ReplicatedStorage.shared.modules.HideInstances)
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local localPlayer = Players.LocalPlayer
local cframe = CFrame.new(-4355.886, -11092.608, 7145.695)
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
				CutsceneController:DisableAllScreens(6.18)
				CutsceneController:Fade(1, 0.4, 0.4)
			end

			local cFrame = humanoidRootPart.CFrame
			local scylla = workspace:WaitForChild("MarianaBossFight"):WaitForChild("Scylla")
			local harpoonAnim = workspace:WaitForChild("MarianaBossFight"):WaitForChild("Harpoon Anim")
			local parent = scylla.Parent
			local parent2 = harpoonAnim.Parent
			scylla.Parent = nil
			harpoonAnim.Parent = nil
			local clone2 = scylla:Clone()
			local clone3 = harpoonAnim:Clone()
			clone2.Parent = workspace
			clone3.Parent = workspace
			clone2:PivotTo(clone2:GetPivot() + createVector(0, 18, 0))
			local clone4 = script:WaitForChild("Camera"):Clone()
			clone4:PivotTo(cFrame + createVector(0, 8, 0))
			clone4.Parent = workspace

			local function safeLoadAnimation(clone5, childName)
				local animator2 = clone5:FindFirstChild("AnimationController") and clone5.AnimationController:FindFirstChild("Animator")

				if animator2 then
					return animator2:LoadAnimation((clone5:FindFirstChild(childName)))
				end

				return {
					Play = function() end
				}
			end

			local v3 = safeLoadAnimation(clone2, "Animation2")
			local v4 = safeLoadAnimation(clone3, "Animation")
			local v5 = safeLoadAnimation(clone4, "Animation")
			local track = animator:LoadAnimation(script:WaitForChild("PlayerAnimation"))

			local function playTracks()
				v4:Play(nil, nil, 1)
				v3:Play(nil, nil, 1)
				v5:Play(nil, nil, 1)
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

			task.wait(0.5)
			playTracks()
			local renderSteppedConnection

			if v2 then
				CutsceneController:ShowBars(6.798, 0.1, 0.1)
				local v6 = 1
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				renderSteppedConnection = RunService.RenderStepped:Connect(function()
					workspace.CurrentCamera.CFrame = clone4:WaitForChild("Bone").CFrame
					local child = script:FindFirstChild("FOV") and script.FOV:FindFirstChild(v6)

					if child then
						workspace.CurrentCamera.FieldOfView = child.Value
						v6 += 1
					end
				end)
			end

			task.wait(5.562)

			if v2 then
				CutsceneController:Fade(1, 0.4, 0.4)
			end

			task.wait(0.5)

			if v2 then
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
				end

				workspace.CurrentCamera.FieldOfView = 70
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end

			clone4:Destroy()
			clone2:Destroy()
			clone3:Destroy()
			scylla.Parent = parent
			harpoonAnim.Parent = parent2

			if v2 then
				setPlayerState(player, false, false) -- equivalent call inferred; original call site unknown
			end

			callback()
		end):finally(function()
			v()
		end)
	end
}