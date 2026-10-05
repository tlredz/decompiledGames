local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
game:GetService("SoundService")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage:WaitForChild("packages")
require(packages:WaitForChild("Trove"))
local Promise = require(packages:WaitForChild("Promise"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local localPlayer = Players.LocalPlayer
return {
	Start = function(_, player)
		return Promise.new(function(callback, _, _)
			local WAIT_INTERVAL = 1.5
			local character = player.Character

			if not character then
				callback()
			end

			if not character:FindFirstChild("HumanoidRootPart") then
				callback()
			end

			local humanoid = character:FindFirstChild("Humanoid")

			if not humanoid then
				callback()
			end

			if not humanoid:FindFirstChild("Animator") then
				callback()
			end

			local v = CollectionService:GetTagged("MarianaCutsceneUtils")[1]
			PlayerController:ToggleControls(false)
			CutsceneController:DisableAllScreens(12)
			ProximityPromptService.Enabled = false
			local part = Instance.new("Part", workspace)
			part.Anchored = true
			part.Transparency = 1
			part.CanCollide = false
			CutsceneController:Fade(3, 0.4, 0.4)
			task.wait(WAIT_INTERVAL)
			CutsceneController:ShowBars(9)
			part.CFrame = CFrame.new(
				-1256.78833,
				353.778595,
				683.557861,
				0.630013406,
				-0.429362923,
				0.647094011,
				1.4901163e-8,
				0.833256721,
				0.552886367,
				-0.776584387,
				-0.348325819,
				0.524962842
			)
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			workspace.CurrentCamera.CFrame = part.CFrame
			task.wait(WAIT_INTERVAL)
			local beam = v:WaitForChild("Beam")

			if beam then
				beam.Enabled = true
			end

			local vfx = v:WaitForChild("Vfx")

			if vfx then
				vfx.Emit:Play()
				vfx.Loop:Play()

				for _, child in vfx.Attachment:GetChildren() do
					if child:IsA("ParticleEmitter") or child:IsA("Smoke") then
						child.Enabled = true
					end
				end
			end

			task.wait(6)
			vfx.Loop:Stop()
			beam.Enabled = false

			for _, child in vfx.Attachment:GetChildren() do
				if child:IsA("ParticleEmitter") or child:IsA("Smoke") then
					child.Enabled = false
				end
			end

			CutsceneController:Fade(3, 0.4, 0.4)
			task.wait(WAIT_INTERVAL)
			PlayerController:ToggleControls(true)
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			local character2 = localPlayer.Character
			local humanoid2 = character2 and character2:FindFirstChild("Humanoid")

			if humanoid2 then
				workspace.CurrentCamera.CameraSubject = humanoid2
			end

			callback()
		end)
	end
}