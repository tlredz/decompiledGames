local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("Debris")
local effects = workspace.Effects
local Utility = require(ReplicatedStorage.Chest.Modules:WaitForChild("Utility"))
local PeodizService = require(ReplicatedStorage.Chest.Modules:WaitForChild("PeodizService"))
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local snow = ReplicatedStorage.Chest.FruitEffect.Snow
local localPlayer = game.Players.LocalPlayer
local v = { "rbxassetid://16378010409", "rbxassetid://16378091356", "rbxassetid://16378056495" }
return function(list)
	local _, _, v2, _ = unpack(list)
	local rootPart = v2.RootPart
	local _ = v2.Character
	local startCF = v2.StartCF
	local cFMouse = v2.CFMouse
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://16470319496",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 5)
	sound.Parent = rootPart
	sound:Play()
	local clones = {}

	for i = 1, 3 do
		local texture = v[math.random(1, 3)]
		local clone = snow.C.card:Clone()
		clone.Parent = effects
		clone.CFrame = startCF * CFrame.new(i * 3 / 2 + -3, 0, -5) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone.Size = createVector(2.5, 0, 0)
		_G.PU:Dust(clone, 2)
		clone.Decal.Texture = texture
		clone.Decal2.Texture = texture
		clones[#clones + 1] = clone
		TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
			Size = createVector(1.117, 0.104, 1.763)
		}):Play()
		Utility.EmitParticles(clone)
		wait()
	end

	wait(0.155)
	task.spawn(function()
		wait(0.1)

		if (localPlayer.Character.HumanoidRootPart.Position - cFMouse.Position).Magnitude < 200 then
			_G.CameraShake:ShakeOnce(5, 12, 0, 0.25)
		end

		local clone = snow.C.foot_fx:Clone()
		clone.CFrame = CFrame.new(startCF.Position) * CFrame.new(0, -3.5, 0)
		clone.Parent = effects
		_G.PU:Dust(clone, 3)
		Utility.EmitParticles(clone)
		local clone2 = snow.C.impact:Clone()
		clone2.CFrame = startCF * CFrame.new(0, 0, -8)
		clone2.Parent = effects
		_G.PU:Dust(clone2, 2)
		Utility.EmitParticles(clone2)
		local clone3 = snow.C.snow_fade:Clone()
		clone3.CFrame = startCF * CFrame.new(0, 10, 0)
		clone3.Parent = effects
		_G.PU:Dust(clone3, 2)
		Utility.EmitParticles(clone3)
	end)

	for i = 1, 3 do
		local v3 = i
		task.spawn(function()
			local parent = clones[v3]
			TweenService:Create(parent, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = parent.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			}):Play()
			wait(0.1)
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://16470321071",
				Volume = 0.5
			})
			_G.PU:Dust(sound2, 4)
			sound2.Parent = parent
			sound2:Play()
			local cFrame = cFMouse

			if v3 == 2 then
				cFrame = cFMouse * CFrame.new(-45, 0, 0)
			elseif v3 == 3 then
				cFrame = cFMouse * CFrame.new(45, 0, 0)
			end

			local magnitude = (startCF.Position - cFMouse.Position).Magnitude
			local v6 = magnitude / 150
			task.spawn(function()
				local clone = snow.C.ray_trail:Clone()
				clone.Parent = effects
				clone.CFrame = startCF
				_G.PU:Dust(clone, 1)
				local v7 = math.rad((math.random(0, 180)))
				local step = math.floor(0.125 * magnitude)
				PeodizService.ForLoop({
					Step = step
				}, function(p)
					local v9 = math.floor(p * step)
					clone.CFrame = startCF * CFrame.new(
						math.sin((3.141592653589793 + v7) * 2 / 15 * v9) * 5,
						math.cos((3.141592653589793 + v7) * 2 / 15 * v9) * 5,
						-v9 * 7
					)
				end)
			end)
			local clone = snow.C.WhiteMesh:Clone()
			clone.CFrame = startCF * CFrame.new(0, 0, 10) * CFrame.Angles(1.5707963267948966, 0, -1.5707963267948966)
			clone.Parent = effects
			clone.Mesh.Scale = clone.Mesh.Scale / 2
			_G.PU:Dust(clone, 1)
			TweenService:Create(
				clone.Mesh,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = createVector(-0.99, 0.25, 0.25)
				}
			):Play()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = startCF * CFrame.new(0, 0, -30) * CFrame.Angles(1.5707963267948966, 0, -1.5707963267948966)
			}):Play()
			task.delay(0.05, function()
				TweenService:Create(
					clone.Mesh,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(-2, 0, 0)
					}
				):Play()
			end)
			local clone2 = snow.C.pjt_trail:Clone()
			clone2.Parent = effects
			clone2.CFrame = startCF
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(v6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = cFrame
			}):Play()
			TweenService:Create(parent, TweenInfo.new(v6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = cFrame
			}):Play()
			wait(v6 * 0.25)
			parent.Transparency = 1

			for i2, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end

				if effect:IsA("Beam") then
					effect.Enabled = false
				end
			end

			local clone3 = snow.C.snow_hurricane:Clone()
			clone3.Parent = effects
			clone3.CFrame = CFrame.new(cFrame.p) * CFrame.new(0, 10, 0)
			_G.PU:Dust(clone3, 3)

			for i2, emitter in pairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				emitter.Enabled = true
				local v7 = emitter
				task.spawn(function()
					wait(2)
					v7.Enabled = false
				end)
			end
		end)
	end

	task.delay(10, function()
		table.clear(clones)
	end)
end