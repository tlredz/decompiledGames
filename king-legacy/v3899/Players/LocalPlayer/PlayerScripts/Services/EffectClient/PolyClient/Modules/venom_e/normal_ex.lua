local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
return function(data)
	local localPlayer = game.Players.LocalPlayer
	local target = data.target

	-- equivalent calls inferred from this helper; original call sites unknown
	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude then
			_G.shake(p)
		end
	end

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	localshake("SmallBump") -- equivalent call inferred; original call site unknown

	for i = 1, #target do
		local v = i
		task.spawn(function()
			local cFrame = target[v]
			local v3 = cFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.Angles(
				1.5707963267948966 * math.random(),
				0,
				0
			) * CFrame.new(0, 0, -60)
			local step = math.max(math.floor((v3.p - cFrame.p).magnitude / 10), 2)
			local v5 = {}
			task.spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.Venom.New.WindRing:Clone()
				clone.CFrame = CFrame.new(v3.p, cFrame.p) * CFrame.Angles(0, -1.5707963267948966, 0)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)
				task.spawn(function()
					local ModuleScript = require(clone.ModuleScript)
					ModuleScript()
				end)
			end)
			local clone = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball:Clone()
			clone.Size = createVector(0, 0, 0)
			clone.CFrame = CFrame.new(v3.p, cFrame.p)
			clone.Parent = workspace.Effects
			clone.Attachment.sm2:Emit(10)
			clone.Attachment.Spark:Emit(2)
			TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(25, 25, 1.5)
			}):Play()
			task.spawn(function()
				wait(0.35)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
			_G.PU:Dust(clone, 1)
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Venom.New.head:Clone()
			_G.PU:Dust(clone2, 5)
			clone2.CFrame = CFrame.new(v3.p, cFrame.p)
			clone2.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11633780899",
				Volume = 1.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
			PeodizService.ForLoop({
				Step = step,
				WaitTime = 0.05
			}, function(p)
				v5[v] = CFrame.new(v3.p, cFrame.p) * CFrame.new(0, 0, v * -10 + 10) * CFrame.new(0, 0, -5)

				if v % 2 == 0 then
					for i2 = 1, math.random(1, 2) do
						local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball:Clone()
						clone3.Size = createVector(6, 6, 6)
						clone3.CFrame = v5[v] * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						clone3.Parent = workspace.Effects
						TweenService:Create(
							clone3,
							TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								CFrame = clone3.CFrame * CFrame.new(0, 0, math.random(7, 12))
							}
						):Play()
						task.spawn(function()
							wait(0.15)
							TweenService:Create(
								clone3,
								TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									Size = Vector3.new()
								}
							):Play()
						end)
						_G.PU:Dust(clone3, 1)
					end
				end

				local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.New.tail:Clone()
				clone3.CFrame = v5[v]
				clone3.Size = createVector(0, 0, 8.5)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(6.5, 7, 10)
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = v5[v] * CFrame.new(0, 0, -10)
				}):Play()
				TweenService:Create(
					clone3,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone3.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
					}
				):Play()
				_G.PU:Dust(clone3, 1)
				task.spawn(function()
					wait(0.35)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 10),
							Transparency = 1
						}
					):Play()
				end)
			end)
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.New.poison_explode:Clone()
			_G.PU:Dust(clone3, 2)
			clone3.CFrame = CFrame.new(cFrame.p)
			clone3.Parent = workspace.Effects
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 750,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://365002938",
				Volume = 1
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone3
			sound2:Play()
			local sound3 = PeoUtils.CreateSound({
				RollOffMaxDistance = 750,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11594475441",
				Volume = 1.25
			})
			_G.PU:Dust(sound3, 3)
			sound3.Parent = clone3
			sound3:Play()

			for i2, emitter in pairs(clone3:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter:GetAttribute("EmitCount") then
					emitter:Emit(emitter:GetAttribute("EmitCount") / 2 or 1)
				else
					emitter:Emit(10)
				end
			end

			for i2 = 1, 3 do
				local clone4 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball:Clone()
				clone4.Size = createVector(9, 9, 9)
				clone4.CFrame = cFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				clone4.Parent = workspace.Effects
				TweenService:Create(
					clone4,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone4.CFrame * CFrame.new(0, 0, math.random(15, 20) * 2.5)
					}
				):Play()
				task.spawn(function()
					wait(0.175)
					TweenService:Create(clone4, TweenInfo.new(0.85, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new()
					}):Play()
				end)
				_G.PU:Dust(clone4, 1)
			end

			local clone4 = ReplicatedStorage.Chest.FruitEffect.Venom.New.Crack:Clone()
			clone4.Parent = workspace.Effects
			clone4.CFrame = CFrame.new(cFrame.p)
			local ModuleScript = require(clone4.ModuleScript)
			ModuleScript()
			_G.PU:Dust(clone4, 2)
			task.spawn(function()
				PeodizService.ForLoop({
					Step = 2,
					WaitTime = 0.05
				}, function(p)
					local clone5 = ReplicatedStorage.Chest.FruitEffect.Venom.New.Shockowave:Clone()
					clone5.CFrame = cFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					clone5.Parent = workspace.Effects
					_G.PU:Dust(clone5, 1)
					TweenService:Create(
						clone5,
						TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(66.986, 7.43, 66.987) * math.random(120, 150) / 100
						}
					):Play()
					spawn(function()
						wait()
						TweenService:Create(
							clone5,
							TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
				end)
			end)
			local clone5 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball:Clone()
			clone5.Size = createVector(0, 0, 0)
			clone5.Material = Enum.Material.Neon
			clone5.CFrame = cFrame
			clone5.Parent = workspace.Effects
			game.TweenService:Create(
				clone5,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = createVector(70, 70, 70),
					Transparency = 1
				}
			):Play()
			_G.PU:Dust(clone5, 1)
			local v6 = 50
			local p = cFrame.p
			local v7 = "SmallBump"
			task.spawn(function()
				v6 = v6 or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v6 then
					_G.shake(v7)
				end
			end)
			task.spawn(function()
				wait(0.35)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(0, 0, 25),
						Transparency = 1
					}
				):Play()
			end)
			_G.PU:Dust(clone2, 1)
		end)
	end
end