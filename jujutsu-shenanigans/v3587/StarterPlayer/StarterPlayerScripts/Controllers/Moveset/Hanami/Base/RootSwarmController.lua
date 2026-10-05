local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
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
	Name = "RootSwarmController"
})
local v3 = { Color3.fromRGB(86, 66, 54), Color3.fromRGB(76, 60, 51), Color3.fromRGB(86, 60, 51) }

function controller.KnitStart(_)
	local v4 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hanami.RootSwarm.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Roots = function(p)
			local function lerp(p2, p3, p4)
				return p2 + (p3 - p2) * p4
			end

			local function quadraticBezier(p2, p3, p4, p5)
				local v5 = p2 + (p3 - p2) * p5
				return v5 + (p3 + (p4 - p3) * p5 - v5) * p5
			end

			local random = Random.new()

			if workspace:Raycast(p.Position + p.lookVector * 1, createVector(0, -5, 0), _G.MapParams) or workspace:Raycast(
				p.Position,
				createVector(0, -15, 0),
				_G.MapParams
			) then
				local v5 = nil
				local v6 = {}
				local v7 = false
				local v8 = {}

				for i = 0, 8 do
					local v10 = p * CFrame.new(0, -2, (i + 1) * -4)
					local v11 = i
					task.spawn(function()
						local v12 = math.random(2, 5)
						local color = Color3.new(1, 1, 1)
						local v13 = 25

						for i2 = 1, 3 do
							local color2 = v3[random:NextInteger(1, #v3)]
							local v15 = random:NextNumber(-40, 40) / 10
							local number = random:NextNumber(-6, -3)
							local number2 = random:NextNumber(-3, 3)
							local vector2 = vector.create(0, random:NextNumber(1, 5), 0)
							local v16 = v10 * CFrame.new(v15, -2, -4 + number).Position
							local position = v10 * CFrame.new(v15 + number2, -2, 4 + number).Position
							local raycastResult = workspace:Raycast(
								v10 * CFrame.new(v15, 1, -4 + number).Position,
								createVector(0, -4, 0),
								_G.MapParams
							)
							local position2

							if raycastResult then
								position2 = v10 * CFrame.new(v15, -1.5, -4 + number).Position
								v5 = v10
							else
								position2 = v10 * CFrame.new(v15, random:NextNumber(-4, 4), -4 + number).Position
								vector2 = vector.create(
									random:NextNumber(-2, 2),
									random:NextNumber(-4, 4),
									random:NextNumber(-2, 2)
								)
							end

							local raycastResult2 = workspace:Raycast(
								v10 * CFrame.new(v15 + number2, 1, 4 + number).Position,
								createVector(0, -3, 0),
								_G.MapParams
							)

							if raycastResult2 then
								position = v10 * CFrame.new(v15 + number2, -1.5, 4 + number).Position
								v5 = v10
								color = raycastResult2.Instance.Color
							elseif v5 then
								position = v5 * CFrame.new(v15, -1.5, 4 + number).Position
							end

							local v19 = (position + position2) / 2 + vector2
							local number3 = random:NextNumber(1.5, 2)
							v13 *= random:NextInteger(0, 1) * 2 - 1
							local clone = replicatedStorage.Utils.Hanami.RootsDust:Clone()
							clone.Position = position
							clone.Size = vector.create(number3, 0.25, number3)
							clone.Bits.Color = ColorSequence.new(color)
							v2:PlayParticles(clone)
							clone.Parent = workspace.Effects
							Debris:AddItem(clone, 2)

							if i2 == 1 and v11 == 0 then
								v2:PlaySound(sounds.Hanami.RootSwarm.Swarm, clone, game.SoundService.Effect)
							end

							local v20 = position

							for i3 = 1, v12 do
								local v21 = i3 / v12
								local v22 = number3 * (random:NextNumber(0.75, 1.25) + math.cos(v21 * 3.141592653589793) * 0.25)
								local part = Instance.new("Part")
								part.Name = i3
								part.CanCollide = false
								part.Anchored = true
								part.Color = color2
								part.Material = Enum.Material.Wood
								part.Size = vector.create(v22, v22, 0.1)

								if raycastResult then
									table.insert(v6, part)
								else
									v7 = true
									part.CanCollide = true
									local v23 = v8[`{v11}_{i2}`]

									if not v23 then
										v23 = {}
										v8[`{v11}_{i2}`] = v23
									end

									table.insert(v23, 1, part)
								end

								local v24 = position + (v19 - position) * v21
								local position3 = v24 + (v19 + (position2 - v19) * v21 - v24) * v21
								part.Position = position3
								part.CFrame = CFrame.new(position3, v20) * CFrame.new(
									0,
									0,
									-(v20 - position3).Magnitude / 2
								) * CFrame.Angles(0, 0, math.random(0, 360))
								part.Size = vector.create(v22, v22, (position3 - v20).Magnitude * 1.25)
								local v26 = raycastResult
								local v27 = number3
								task.delay(0.04 / v12, function()
									if v26 then
										local clone2 = replicatedStorage.Utils.Hanami.RootsDust:Clone()
										clone2.Position = position2
										clone2.Size = vector.create(1 * v27, 0.25, 1 * v27)
										clone2.Bits.Color = ColorSequence.new(v26.Instance.Color)
										v2:PlayParticles(clone2)
										clone2.Parent = workspace.Effects
										Debris:AddItem(clone2, 2)
									end
								end)
								part.Parent = workspace.Effects
								task.wait(0.04 / v12)
								v20 = position3
							end
						end
					end)
					task.wait(0.04)
				end

				task.wait(v7 and 3 or 1)
				local v9 = false

				for _, v10 in v6 do
					if not v9 then
						v2:PlaySound(sounds.Hanami.RootSwarm.Disappear, v10, game.SoundService.Effect)
						v9 = true
					end

					TweenService:Create(v10, TweenInfo.new(0.75), {
						Position = v10.Position - createVector(0, 4, 0),
						Size = v10.Size * createVector(0, 0, 1)
					}):Play()
				end

				for _, v10 in v8 do
					local v12 = v10
					local v13 = 1 / #v10
					local v14 = CFrame.Angles(0, 0, 3.141592653589793)
					task.spawn(function()
						for k, v15 in v12 do
							if not v9 then
								v9 = true
								v2:PlaySound(sounds.Hanami.RootSwarm.Disappear, v15, game.SoundService.Effect)
							end

							local size = v15.Size
							local cFrame = v12[k + 1] and v12[k + 1].CFrame or v15.CFrame * CFrame.new(0, 0, -size.Z)
							TweenService:Create(v15, TweenInfo.new(v13), {
								Size = size * createVector(0, 0, 0),
								CFrame = cFrame * v14
							}):Play()
							task.wait(v13 / 2)
						end
					end)
				end

				task.wait(1.4)

				for _, v10 in v6 do
					v10:Destroy()
				end

				for _, v10 in v8 do
					for _, v11 in v10 do
						v11:Destroy()
					end
				end
			end
		end,
		Hit = function(instance)
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
			v2:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("RootSwarmService")
	v2 = Knit.GetController("FXController")
end

return controller