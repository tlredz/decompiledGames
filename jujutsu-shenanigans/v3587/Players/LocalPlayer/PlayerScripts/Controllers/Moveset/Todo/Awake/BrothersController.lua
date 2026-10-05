local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local LightningBeams = require(replicatedStorage.Modules.LightningBeams)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "BrothersController"
})

function controller.KnitStart(_)
	local v4 = {
		Clap = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Todo.Clap, humanoidRootPart, game.SoundService.Effect)

			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 130 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Swap = function(folder, p)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local transparenciesByDescendant = {}

			for _, descendant in folder:GetDescendants() do
				if not ((descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.Transparency ~= 1) then
					continue
				end

				local transparency = descendant.Transparency
				descendant.Transparency = 1
				transparenciesByDescendant[descendant] = transparency
			end

			local clone = game.ReplicatedStorage.Utils.Todo.Clap:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)
			clone.Attachment.Sparks:Emit(20)
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(0, 0, 0),
				Transparency = 1
			}):Play()
			v3:PlaySound(sounds.Itadori.ManjiKick.Startup, clone, game.SoundService.Effect)
			local clone2 = nil
			pcall(function()
				clone2 = utils.Todo.Yuji:Clone()

				for _, part in clone2:GetDescendants() do
					if part:IsA("BasePart") then
						part.CollisionGroup = "Effects"
					end
				end

				clone2.HumanoidRootPart.CFrame = humanoidRootPart.CFrame
				clone2.Parent = workspace.Effects
				local track = clone2.Humanoid:LoadAnimation(animations.Todo.Brothers)
				track:Play(0)
				track.TimePosition = 2.4
			end)
			task.spawn(function()
				while true do
					if clone2 and clone2:FindFirstChild("HumanoidRootPart") then
						clone2.HumanoidRootPart.CFrame = humanoidRootPart.CFrame
					end

					task.wait()

					if not (not folder.Parent or not humanoidRootPart.Parent or not p or not p.Parent or p.Value == true) then
						continue
					end

					if clone2 then
						clone2:Destroy()
					end

					for k, transparency in transparenciesByDescendant do
						if k.Parent then
							k.Transparency = transparency
						end
					end

					local clone3 = game.ReplicatedStorage.Utils.Todo.Clap:Clone()
					clone3.Position = humanoidRootPart.Position
					clone3.Parent = workspace.Effects
					Debris:AddItem(clone3, 1.5)
					clone3.Attachment.Sparks:Emit(20)
					TweenService:Create(clone3, TweenInfo.new(0.3), {
						Size = createVector(0, 0, 0),
						Transparency = 1
					}):Play()
					v3:PlaySound(sounds.Itadori.ManjiKick.Startup, clone3, game.SoundService.Effect)
					break
				end
			end)

			if localPlayer.Character == folder then
				local followTakada = workspace.Effects:FindFirstChild("FollowTakada")

				if followTakada and localPlayer.Character == folder then
					followTakada:ScaleTo(0.01)
					task.delay(1.34, function()
						followTakada:ScaleTo(1)
					end)
				end
			end
		end,
		BlackFlash = function(instance, instance2)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			for _, part in instance2:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local clone = utils.Itadori.DivergentFist.FlashBurn:Clone()
				clone.Parent = part
				Debris:AddItem(clone, 1)
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.Sparks:Emit(20)
			clone.Flare:Emit(20)
			clone.Lightning:Emit(25)
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			Debris:AddItem(clone, 3)
			v3:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart2, game.SoundService.Effect)
			v3:PlaySound(sounds.Itadori.DivergentFist.Voice, humanoidRootPart, game.SoundService.Effect)
			local model = Instance.new("Model", workspace.Effects.Bolt)
			local highlight = Instance.new("Highlight", model)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.OutlineColor = Color3.new(1, 0, 0)
			highlight.FillColor = Color3.new(0, 0, 0)
			highlight.FillTransparency = 0
			Debris:AddItem(model, 1.2)
			local v5 = LightningBeams.new(clone.Core, humanoidRootPart2.RootAttachment, nil, model)
			v5.Color = Color3.new(1, 0, 0)
			v5.PulseSpeed = 1000
			v5.FadeLength = 0.35
			v5.MaxRadius = 20
			v5.MinRadius = 0
			v5.AnimationSpeed = 300
			v5.MinThicknessMultiplier = 0.5
			v5.MaxThicknessMultiplier = 10
			task.delay(0.1, function()
				local WAIT_INTERVAL2 = 0.1
				v5.MaxThicknessMultiplier = 5
				task.wait(WAIT_INTERVAL2)
				v5.MaxThicknessMultiplier = 3
				task.wait(WAIT_INTERVAL2)
				v5.MaxThicknessMultiplier = 2
				task.wait(WAIT_INTERVAL2)
				v5.MaxThicknessMultiplier = 1
				task.wait(0.4)
				v5:Destroy()
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone2.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = 200
				clone2.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone2:Destroy()
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("BrothersService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller