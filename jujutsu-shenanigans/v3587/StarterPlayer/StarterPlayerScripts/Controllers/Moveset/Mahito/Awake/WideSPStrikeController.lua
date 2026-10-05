local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "WideSPStrikeController"
})

function controller.KnitStart(_)
	local v4 = {
		Afterimages = function(folder)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.WideSPStrike.HitArea:Clone()
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Overlay, TweenInfo.new(0.4), {
				Transparency = 0.5
			}):Play()
			clone.Prog.Size = createVector(25, 0, 25)
			TweenService:Create(clone.Prog, TweenInfo.new(2.1, Enum.EasingStyle.Linear), {
				Size = createVector(0, 0, 0)
			}):Play()
			clone.groundwaveing.Flare:Emit(10)
			clone.groundwaveing.Wind:Emit(15)
			Debris:AddItem(clone, 4.3)
			v3:PlaySound(sounds.Mahito.WideSPStrike.Start, humanoidRootPart, game.SoundService.Effect)
			local rootJoints = {}

			for i = 1, 4 do
				local clone2 = folder:Clone()
				local humanoidRootPart2 = clone2.HumanoidRootPart

				for _, descendant in clone2:GetDescendants() do
					if descendant:IsA("BillboardGui") or descendant:IsA("Sound") then
						descendant:Destroy()
					elseif descendant:IsA("BasePart") then
						descendant.CollisionGroup = "NoCollision"
						descendant.CanCollide = false
					end
				end

				clone2.Parent = workspace.Effects
				humanoidRootPart2.Anchored = true
				Debris:AddItem(clone2, 2.1)
				local track = clone2.Humanoid:LoadAnimation(animations.Mahito.WideStrike)
				track:Play(0)
				track.TimePosition = 0.5
				local clone_2 = utils.Mahito.WideSPStrike.Afterimage:Clone()
				clone_2.Parent = clone2.Torso
				local rootJoint = humanoidRootPart2:FindFirstChild("RootJoint")

				if not rootJoint then
					continue
				end

				table.insert(rootJoints, rootJoint)
				local cframe = CFrame.Angles(0, 0, (math.rad((i - 1) * 90)))
				local C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) * cframe
				TweenService:Create(rootJoint, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {
					C0 = C0 * CFrame.new(0, math.random(14, 16), 0)
				}):Play()
				local v6 = rootJoint
				task.delay(1.5, function()
					TweenService:Create(v6, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
						C0 = C0
					}):Play()
				end)
			end

			local v5 = {}

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("ParticleEmitter") and descendant.Name == "Aura" then
					descendant.Enabled = false
					v5[descendant] = true
				elseif descendant:IsA("BasePart") or descendant:IsA("Decal") and descendant.Transparency ~= 1 then
					v5[descendant] = descendant.Transparency
					descendant.Transparency = 1
				end
			end

			local lastTime = tick()

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 200 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				if humanoidRootPart.Parent then
					local now = tick()

					if not (lastTime + 2.1 < now) then
						local v6 = (1 - (tick() - lastTime) / 2) * 4000
						local cframe = CFrame.Angles(0, math.rad(v6 * dt), 0)

						for _, v7 in rootJoints do
							v7.Parent.CFrame = (v7.Parent.CFrame - v7.Parent.Position + humanoidRootPart.Position) * cframe
						end

						local raycastResult = workspace:Raycast(
							humanoidRootPart.Position,
							createVector(0, -200, 0),
							_G.MapParams
						)

						if raycastResult then
							clone.Position = raycastResult.Position
						else
							clone.Position = createVector(0, 1000000, 0)
						end

						clone.Prog.Position = clone.Position

						if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 200 then
							CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
						end

						return
					end
				end

				steppedConnection:Disconnect()

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				clone.Overlay:Destroy()
				clone.Prog:Destroy()
				clone.groundwaveing.Spin.Enabled = false
				clone.groundwaveing.Flare:Emit(10)
				clone.groundwaveing.Wind:Emit(15)

				for instance, v6 in v5 do
					if not instance.Parent then
						continue
					end

					if instance:IsA("BasePart") or instance:IsA("Decal") then
						instance.Transparency = v6
					elseif instance:IsA("ParticleEmitter") then
						instance.Enabled = v6
					end
				end

				v5 = nil

				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 200 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				end
			end)
		end,
		Voice = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			task.wait(0.35)

			if p then
			end

			v3:PlaySound(sounds.Mahito.WideSPStrike.Voice, humanoidRootPart, game.SoundService.Voice)
		end,
		Voice2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			Debris:AddItem(v3:PlaySound(sounds.Mahito.WideSPStrike.Flash, humanoidRootPart, game.SoundService.Voice), 1)
		end,
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(p, Color3.new(1, 1, 1))
			v3:PlaySound(
				sounds.Mahito.WideSPStrike["Hit" .. math.random(1, 5)],
				humanoidRootPart,
				game.SoundService.Effect
			)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 50 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			elseif (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 100 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HardHit)
			end

			local clone = utils.Mahito.Worms.DashSlash.Attachment:Clone()
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 2)

			for _, child in clone:GetChildren() do
				child.Enabled = false
				child:Emit(2)
			end

			if localPlayer.Character == instance or localPlayer.Character == p then
				if _G.Settings.Flash ~= true then
					return
				end

				local clone2 = utils.Mahito.WideSPStrike.ScreenSlash:Clone()
				clone2.Base.Rotation = math.random(0, 360)
				clone2.Parent = humanoidRootPart
				TweenService:Create(clone2.Base.Base2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(clone2.Base.Frame, TweenInfo.new(0.1), {
					BackgroundTransparency = 1
				}):Play()
				Debris:AddItem(clone2, 0.3)
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
	v = Knit.GetService("WideSPStrikesService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller