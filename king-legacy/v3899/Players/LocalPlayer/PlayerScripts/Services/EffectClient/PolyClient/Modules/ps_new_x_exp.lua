local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
game:GetService("RunService")
return function(p, _)
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p2)
		if localPlayer == p.plr then
			_G.shake(p2)
		end
	end

	local function rangeshake(p2, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - p.cf.p).Magnitude then
			_G.shake(p2)
		end
	end

	local function local_rangeshake(p2, value, p3)
		task.spawn(function()
			value = value or 100

			if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < value then
				_G.shake(p2)
			end
		end)
	end

	local cf = p.cf
	wait(0.2)
	local clone = replicatedStorage.Chest.SwordEffect.PumpkinSmasher.exp:Clone()
	clone.Transparency = 1
	clone.CFrame = cf
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 3)
	local v = {
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.Inverse,
		SoundId = "rbxassetid://7600233878",
		Volume = 1
	}
	local sound = PeoUtils.CreateSound(v)
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local v2 = {
		RollOffMaxDistance = 500,
		RollOffMinDistance = 0,
		RollOffMode = Enum.RollOffMode.Linear,
		SoundId = "rbxassetid://15157093707",
		Volume = 1
	}
	local sound2 = PeoUtils.CreateSound(v2)
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	if (cf.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
		_G.shake("Explosion")
		local clone2 = replicatedStorage.Chest.Etc.ColorCorrection:Clone()
		clone2.Parent = game.Lighting
		_G.PU:Dust(clone2, 3)
		TweenService:Create(
			clone2,
			TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
			{
				TintColor = Color3.fromRGB(79, 26, 0)
			}
		):Play()
	end

	spawn(function()
		local v3 = CFrame.new(cf.p) * CFrame.new(0, 25, 0)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		local raycastResult = workspace:Raycast(v3.p, createVector(0, -50, 0), raycastParams)
		local position = v3.p + createVector(0, -50, 0)
		local instance, normal

		if raycastResult then
			position = raycastResult.Position
			instance = raycastResult.Instance
			normal = raycastResult.Normal
			local _ = instance.Material
		else
			normal = createVector(0, -1, 0)
		end

		if instance then
			local clone2 = replicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
			clone2.Decal.Transparency = 0
			clone2.Decal.Texture = "rbxassetid://7615931204"
			clone2.Decal.Color3 = Color3.fromRGB(255, 255, 255)
			clone2.rocks.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 15, 5),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone2.rocks.Color = ColorSequence.new(instance.Color)
			clone2.rocks.Lifetime = NumberRange.new(0.5, 1)
			clone2.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				6.283185307179586 * math.random(),
				0
			) * CFrame.new(0, -1, 0)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 3)
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
				Size = createVector(150, 0, 150)
			}):Play()
			spawn(function()
				wait(1)

				if clone2:FindFirstChild("Decal") then
					TweenService:Create(clone2.Decal, TweenInfo.new(0.25), {
						Transparency = 1
					}):Play()
				end
			end)
		end
	end)
end