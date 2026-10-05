local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local SraikoVFX = require(replicatedStorage.Modules.SraikoVFX)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "FlowerFieldController"
})
Random.new()
local _ = workspace.CurrentCamera

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function quadraticBezier(p, p2, p3, p4)
	local v4 = p + (p2 - p) * p4
	return v4 + (p2 + (p3 - p2) * p4 - v4) * p4
end

local _ = { Color3.fromRGB(86, 66, 54), Color3.fromRGB(76, 60, 51), Color3.fromRGB(86, 60, 51) }
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }

function controller.KnitStart(_)
	local v4 = {
		Windup = function(_) end,
		FlowerTrail = function(instance, p)
			local clone = utils.Hanami.FlowerFieldTrail:Clone()
			clone.Parent = workspace.Effects
			clone.Anchored = false
			local weld = Instance.new("Weld")
			weld.Part1 = clone
			weld.Part0 = instance
			weld.Parent = instance
			v2:PlaySound(sounds.Hanami.FlowersField.Field, clone, game.SoundService.Effect)
			local clone2

			if p == localPlayer then
				clone2 = utils.Megumi.HitArea:Clone()
				clone2.Size = createVector(30, 0, 30)
				clone2.Parent = workspace.Effects
			end

			while instance.Parent do
				if clone2 then
					local raycastResult = workspace:Raycast(instance.Position, createVector(0, -15, 0), _G.MapParams)

					if raycastResult then
						TweenService:Create(clone2, TweenInfo.new(0.05), {
							Position = raycastResult.Position + createVector(0, 0.1, 0)
						}):Play()

						if not clone2.Parent then
							clone2.Parent = workspace.Effects
						end
					else
						clone2.Parent = nil
					end
				end

				task.wait()
			end

			if clone2 then
				clone2:Destroy()
			end

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			Debris:AddItem(clone, 2)
		end,
		FlowerExplosion = function(p)
			local clone = utils.Hanami.FlowerFieldExplosion:Clone()
			clone.Position = p - createVector(0, 0.5, 0)
			clone.Size = createVector(3, 1, 3)
			clone.Parent = workspace.Effects

			for _, model in pairs(utils.Nanami.BluntCut.Charge:GetChildren()) do
				if not model:IsA("Model") then
					continue
				end

				model:SetAttribute("Duration", model:GetAttribute("Duration"))
				local clone2 = model:Clone()
				clone2:ScaleTo(3)

				if clone2.Name == "NewSlash" then
					clone2:SetAttribute("StartTransparency", 0.5)
				end

				local v5 = SraikoVFX.HandleMesh(
					clone2,
					CFrame.lookAlong(p, createVector(0, 1, 0)) * CFrame.Angles(-1.5707963267948966, 0, 0)
				)
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, v5)
			end

			v2:PlaySound(sounds.Hanami.FlowersField.Hit, clone, game.SoundService.Effect)
			TweenService:Create(clone, TweenInfo.new(0.4), {
				Size = createVector(40, 1, 40)
			}):Play()
			task.wait(0.4)

			for _, emitter in clone:GetChildren() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(20)
				emitter.Enabled = false
			end

			Debris:AddItem(clone, 7)
		end,
		Lasso = function(p, data, p2)
			local v5 = p.Position + createVector(0, 8, 0)
			Random.new()
			local color = Color3.fromRGB(76, 60, 51)
			v2:DustBreak(v5 + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)
			v2:PlaySound(sounds.Hanami.AOESpikes.WoodBallsAppear, p, game.SoundService.Effect)
			v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, p, game.SoundService.Effect)
			local v6 = v5
			local v7 = v6
			local v8 = v7
			v6 = v8
			v7 = v6
			local v10 = {}
			local preRenderConnection = nil
			local preRenderConnection2 = nil
			local preRenderConnection3 = nil
			local preRenderConnection4 = nil

			for i = 1, 8 do
				local v11 = i / 8
				local v12 = v11 * -0.9 + 1.3
				local v13 = v8
				local v14 = v7
				local v15 = v5 + (v13 - v5) * v11
				local v16 = v15 + (v13 + (v14 - v13) * v11 - v15) * v11
				local part = Instance.new("Part")
				part.Name = i
				part.CanCollide = false
				part.Transparency = 0
				part.Anchored = true
				part.Color = color
				part.Material = Enum.Material.Wood
				part.CFrame = CFrame.new(v16, v6) * CFrame.new(0, 0, -(v6 - v16).Magnitude / 2)
				part.Size = vector.create(v12, v12, (v16 - v6).Magnitude * 1.25)
				v10[i] = part
				part.Parent = data.Parts
				v6 = v16
			end

			local total = 0
			local total2 = 0
			local v11 = 0.4
			local cframe = CFrame.lookAt(v5, p2.Position)
			local _ = cframe.LookVector
			local _ = cframe.RightVector
			local position = cframe * CFrame.new(10, 2.5, 10)
			local position2 = cframe * CFrame.new(10, 10, 0)
			local position3 = cframe * CFrame.new(0, 10, -10)
			local position4 = cframe * CFrame.new(0, 2.5, 10)
			local v12 = false
			preRenderConnection2 = RunService.PreRender:Connect(function()
				if data.Parent then
					if v12 == false and data.Grab.Value then
						v12 = true
					end
				else
					if preRenderConnection then
						preRenderConnection:Disconnect()
						preRenderConnection = nil
					end

					if preRenderConnection2 then
						preRenderConnection2:Disconnect()
						preRenderConnection2 = nil
					end

					if preRenderConnection3 then
						preRenderConnection3:Disconnect()
						preRenderConnection3 = nil
					end

					if preRenderConnection4 then
						preRenderConnection4:Disconnect()
						preRenderConnection4 = nil
					end
				end

				local v13 = v5

				for i, v14 in ipairs(v10) do
					local v15 = i / #v10
					local v16 = v5
					local v17 = v8
					local v18 = v7
					local v19 = v16 + (v17 - v16) * v15
					local v20 = v19 + (v17 + (v18 - v17) * v15 - v19) * v15
					local magnitude = (v20 - v13).Magnitude
					v14.CFrame = CFrame.new(v20, v13) * CFrame.new(0, 0, -magnitude / 2)
					v14.Size = vector.create(v14.Size.X, v14.Size.Y, magnitude * 1.25)
					v13 = v20
				end
			end)
			preRenderConnection3 = RunService.PreRender:Connect(function(dt)
				local cframe2 = CFrame.lookAt(v5, p2.Position)
				local _ = cframe2.LookVector
				local _ = cframe2.RightVector
				position = (cframe2 * CFrame.new(10, 2.5, 10)).Position
				position2 = (cframe2 * CFrame.new(10, 10, 0)).Position
				total += dt
				local v13 = math.min(total / 0.2, 1)
				local v14 = v8
				local v15 = position
				local v16 = position2
				local v17 = v14 + (v15 - v14) * v13
				v8 = v17 + (v15 + (v16 - v15) * v13 - v17) * v13

				if v13 >= 1 then
					preRenderConnection3:Disconnect()
					preRenderConnection3 = nil
				end
			end)
			preRenderConnection4 = RunService.PreRender:Connect(function(dt)
				local cframe2 = CFrame.lookAt(v5, p2.Position)
				local _ = cframe2.LookVector
				local _ = cframe2.RightVector
				position3 = (cframe2 * CFrame.new(0, 10, -10)).Position
				position4 = (cframe2 * CFrame.new(0, 2.5, 10)).Position
				total2 += dt
				local v13 = math.min(total2 / v11, 1)
				local v14 = v7
				local v15 = position3
				local v16 = position4
				local v17 = v14 + (v15 - v14) * v13
				v7 = v17 + (v15 + (v16 - v15) * v13 - v17) * v13

				if v13 >= 1 then
					preRenderConnection4:Disconnect()
					preRenderConnection4 = nil
				end
			end)
			task.wait(0.2)
			v2:PlaySound(sounds.Hanami.DefenseResponse.Startup, p, game.SoundService.Effect)

			if preRenderConnection3 then
				preRenderConnection3:Disconnect()
			end

			if preRenderConnection4 then
				preRenderConnection4:Disconnect()
			end

			total = 0
			preRenderConnection3 = RunService.PreRender:Connect(function(dt)
				local cframe2 = CFrame.lookAt(v5, p2.Position)
				local _ = cframe2.LookVector
				local rightVector = cframe2.RightVector
				local position5 = p2.Position
				position = (position2 + position5) / 2 + rightVector * 2.5
				total += dt
				local v13 = math.min(total / 0.2, 1)
				local v14 = v8
				local v15 = position
				local v16 = v14 + (v15 - v14) * v13
				v8 = v16 + (v15 + (position5 - v15) * v13 - v16) * v13
			end)
			total2 = 0
			preRenderConnection4 = RunService.PreRender:Connect(function(dt)
				total2 += dt
				local v13 = math.min(total2 / v11, 1)
				local position5 = p2.Position
				local cframe2 = CFrame.lookAt(v5, p2.Position)
				local _ = cframe2.LookVector
				local rightVector = cframe2.RightVector
				position3 = (position2 + position5) / 2 + createVector(0, 5, 0) + rightVector * 10
				local v14 = v7
				local v15 = position3
				local v16 = v14 + (v15 - v14) * v13
				v7 = v16 + (v15 + (position5 - v15) * v13 - v16) * v13
			end)
			task.wait(0.1)

			if v12 and data.Grab.Value then
				v11 = 0.13333333333333333
				local value = data.Grab.Value
				local v13 = {}

				for i = 1, 2 do
					local part = Instance.new("Part")
					part.Name = "StrangleRoot" .. i
					part.CanCollide = false
					part.Anchored = false
					part.Massless = true
					part.Color = color
					part.Material = Enum.Material.Wood
					part.Size = createVector(1, 0.5, 1.5)
					part.CFrame = value.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)

					if i == 2 then
						part.CFrame *= CFrame.new(0, 0.25, 0) * CFrame.Angles(0, 0, 0.2617993877991494)
					end

					TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Size = createVector(2.3, 0.6, 1.5)
					}):Play()
					part.Parent = data.Parts
					local weldConstraint = Instance.new("WeldConstraint")
					weldConstraint.Part0 = value.HumanoidRootPart
					weldConstraint.Part1 = part
					weldConstraint.Parent = part
					table.insert(v13, part)
				end

				local part = Instance.new("Part")
				part.Name = "WrappingRoot"
				part.CanCollide = false
				part.Anchored = true
				part.Color = color
				part.Material = Enum.Material.Wood
				part.Size = createVector(1, 7, 1)
				part.CFrame = CFrame.lookAt(
					value.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3).Position,
					value.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0).Position
				)
				part.Parent = data.Parts
				TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Size = createVector(0.5, 0, 0.5)
				}):Play()
				local v14 = nil
				local v15 = 0
				local total3 = 0
				preRenderConnection = RunService.PreRender:Connect(function(dt)
					v14 = part.Size.Y / 1.5
					local position5 = (value.HumanoidRootPart.CFrame * CFrame.new(
						0,
						value.HumanoidRootPart.Size.Y / 2,
						0
					)).Position
					v15 -= 40 * dt
					total3 += 20 * dt
					local v16 = position5 + vector.create(
						math.cos(v15) * v14,
						math.cos(total3) * 0.5,
						math.sin(v15) * v14
					)
					local position6 = (value.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)).Position
					part.CFrame = CFrame.lookAt(v16, position6) * CFrame.Angles(0, 0, 0.7853981633974483) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
				end)
			end
		end,
		LassoFail = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hanami.RootDisappear, humanoidRootPart, game.SoundService.Effect)
			local particleDissipationHolder = replicatedStorage.Utils.Hanami.ParticleDissipationHolder

			for _, child in p.Parts:GetChildren() do
				for _, child2 in particleDissipationHolder:GetChildren() do
					local clone = child2:Clone()
					clone.Shape = Enum.ParticleEmitterShape.Box
					clone.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, child.Size.X * 2, 0),
						NumberSequenceKeypoint.new(1, child.Size.X * 2, 0)
					})
					clone.Parent = child
				end

				v2:PlayParticles(child)
				child.Transparency = 1
			end
		end,
		GrappleHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("FlowerFieldService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller