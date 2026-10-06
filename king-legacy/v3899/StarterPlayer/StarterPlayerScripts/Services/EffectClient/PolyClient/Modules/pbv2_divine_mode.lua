local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local _ = data.Charge
	local _ = data.Char
	local root = data.Root
	local duration = data.Duration
	local localPlayer = game.Players.LocalPlayer

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
	tick()
	local clone = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.divine_ring:Clone()
	clone:SetPrimaryPartCFrame(root.CFrame)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, duration + 1)
	clone.PrimaryPart.PointLight.Range = 0
	TweenService:Create(
		clone.PrimaryPart.PointLight,
		TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Range = 30
		}
	):Play()
	local clone2 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.pb_symbol:Clone()
	clone2.CFrame = root.CFrame
	clone2.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12325531264",
		Volume = 2,
		Looped = true
	})
	sound.Parent = clone2
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12388328102",
		Volume = 3,
		PlaybackSpeed = 1.25
	})
	sound2.Parent = clone2
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12486113643",
		Volume = 3
	})
	sound3.Parent = clone2
	sound3:Play()
	_G.PU:Dust(clone2, duration + 1)
	local weld = Instance.new("Weld")
	weld.Part0 = root
	weld.Part1 = clone2
	weld.C0 = CFrame.new(0, 8, 0)
	weld.Parent = root
	_G.PU:Dust(weld, duration + 1)

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	PeodizService.new({
		Time = 60
	}, function()
		local success, _ = pcall(function()
			clone.PrimaryPart.CFrame = CFrame.new(root.CFrame.p) * CFrame.new(0, -2.5, 0) * CFrame.Angles(
				0,
				-(tick() * 5) % 360,
				0
			)
		end)

		if success == false then
			return true
		end
	end)
	wait(5)

	if weld then
		weld:Destroy()
	end

	if clone2 then
		clone2:Destroy()
	end

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	if clone:FindFirstChild("center") and clone.center:FindFirstChild("PointLight") then
		TweenService:Create(
			clone.center.PointLight,
			TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Range = 0
			}
		):Play()
	end
end