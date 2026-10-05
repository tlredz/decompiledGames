local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "SurgingThornsController"
})
local v3 = { Color3.fromRGB(86, 66, 54), Color3.fromRGB(76, 60, 51), Color3.fromRGB(86, 60, 51) }

function controller.KnitStart(_)
	local v4 = {
		Spikes = function(p)
			local function spike(cFrame)
				local raycastResult = workspace:Raycast(cFrame.Position, -cFrame.UpVector * 12, _G.MapParams)

				if not raycastResult then
					return
				end

				local clone = utils.Hanami.CurvedRoot:Clone()
				clone.CFrame = cFrame
				clone.Position = raycastResult.Position - cFrame.UpVector * 6
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.15), {
					Position = raycastResult.Position + cFrame.UpVector * 3
				}):Play()
				task.wait(0.5)
				clone:Destroy()
			end

			for i = 1, 10 do
				local v5 = p * CFrame.Angles(0, math.rad(i * 36), 0) * CFrame.new(0, 0, -8 + math.random(-1, 1)) * CFrame.Angles(
					math.rad(-30 + math.random(-8, 8)),
					0,
					0
				)
				task.spawn(spike, v5)
			end
		end,
		WoodenBall = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hanami.AOESpikes.WoodBallsAppear, humanoidRootPart, game.SoundService.Effect)

			local function CreateWoodenBall(p, p2)
				local color = v3[math.random(1, #v3)]
				local v6 = humanoidRootPart.CFrame * p
				local raycastResult = workspace:Raycast(v6.Position, createVector(0, -4, 0), _G.MapParams) or {
					Position = v6.Position + createVector(0, -2, 0)
				}
				local _ = v6.Position + createVector(0, 2, 0)
				local clone = utils.Hanami.WoodBall:Clone()
				clone.Position = raycastResult.Position + createVector(0, -2, 0)
				clone.Size *= 1.5
				clone.Transparency = 1
				clone.Color = color
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 5)
				TweenService:Create(clone, TweenInfo.new(0.1), {
					Transparency = 0
				}):Play()
				local numberValue = Instance.new("NumberValue", clone)
				numberValue.Value = -2
				TweenService:Create(numberValue, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Value = 2
				}):Play()
				local flag = false
				local cFrame = nil
				local random = Random.new()
				local renderSteppedConnection = nil
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					if not instance2:IsDescendantOf(workspace.Characters) then
						clone:Destroy()
					end

					if not (instance.Parent and clone.Parent) then
						renderSteppedConnection:Disconnect()
					elseif not cFrame then
						clone.CFrame = clone.CFrame:Lerp(
							humanoidRootPart.CFrame * p + vector.create(0, numberValue.Value, 0),
							dt * 20
						)
					elseif flag then
						clone.CFrame = cFrame * CFrame.new(
							random:NextNumber(-0.2, 0.2),
							random:NextNumber(-0.2, 0.2),
							random:NextNumber(-0.2, 0.2)
						)
					end
				end)

				if not instance2:GetAttribute(("Phase%d"):format(p2)) then
					repeat
						task.wait()
					until not instance2.Parent or instance2:GetAttribute(("Phase%d"):format(p2))

					if not instance2.Parent then
						return
					end
				end

				cFrame = clone.CFrame
				local lookVector = (instance2:GetAttribute(("Phase%d"):format(p2)) or humanoidRootPart.CFrame).LookVector
				local random2 = Random.new()
				local position = clone.Position
				local v7 = clone.Position + lookVector * 20
				v2:PlaySound(sounds.Hanami.AOESpikes[`Spear{p2}`], clone, game.SoundService.Effect)
				local position2 = clone.Position
				local v8 = {}

				for i = 1, 6 do
					local v9 = i / 6
					local v10 = v9 * -0.65 + 0.8
					local v11 = (i <= 1 or i >= 6) and createVector(0, 0, 0) or vector.create(
						random2:NextNumber(-0.3, 0.3),
						random2:NextNumber(-0.3, 0.3),
						random2:NextNumber(-0.2, 0.2)
					)
					local v12 = position + (v7 - position) * v9 + v11

					if i == 6 then
						v12 = v7
					end

					local magnitude = (v12 - position2).Magnitude
					local part = Instance.new("Part")
					part.Transparency = 1
					part.Name = ("Segment"):format(i)
					part.CanCollide = false
					part.Anchored = false
					part.Material = Enum.Material.Wood
					part.Color = color
					part.Size = vector.create(v10, v10, magnitude)
					part.CFrame = CFrame.lookAt((position2 + v12) / 2, position2)
					local weld = Instance.new("Weld")
					weld.C0 = part.CFrame:ToObjectSpace(clone.CFrame)
					weld.Part0 = part
					weld.Part1 = clone
					weld.Parent = part
					part.Parent = workspace.Effects
					table.insert(v8, part)
					position2 = v12
				end

				local flag2 = false

				local function Cleanup()
					if flag2 then
						return
					end

					flag2 = true
					local clone2 = utils.Hanami.ParticleDissipationHolder:Clone()
					clone2.Parent = clone
					v2:PlayParticles(clone)
					v2:PlaySound(sounds.Hanami.RootDisappear, clone, game.SoundService.Effect)

					for _, parent in v8 do
						parent.Anchored = true

						for _, child in clone2:GetChildren() do
							local clone3 = child:Clone()
							clone3.Shape = Enum.ParticleEmitterShape.Box
							clone3.Size = NumberSequence.new({
								NumberSequenceKeypoint.new(0, parent.Size.Magnitude / 2, 0),
								NumberSequenceKeypoint.new(1, parent.Size.Magnitude * 1.25, 0)
							})
							clone3.Parent = parent
						end

						Debris:AddItem(parent, 1)
						v2:PlayParticles(parent)
						TweenService:Create(parent, TweenInfo.new(0.2), {
							Transparency = 1
						}):Play()
					end

					TweenService:Create(clone, TweenInfo.new(0.2), {
						Transparency = 1
					}):Play()
					Debris:AddItem(clone, 1)
					numberValue:Destroy()
				end

				instance2.Destroying:Once(Cleanup)
				instance.Destroying:Once(Cleanup)
				flag = true

				for _, v9 in v8 do
					v9.Transparency = 0
					task.wait(0.024999999999999998)
				end

				flag = false
			end

			task.spawn(CreateWoodenBall, CFrame.new(3, 0, -0.5), 1)
			task.spawn(CreateWoodenBall, CFrame.new(-3, 0, -0.5), 2)
		end,
		SpikesWindup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hanami.AOESpikes.SpikesWindup, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hanami.DefenseResponse[`Hit{p}`], humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("SurgingThornsService")
	v2 = Knit.GetController("FXController")
end

return controller