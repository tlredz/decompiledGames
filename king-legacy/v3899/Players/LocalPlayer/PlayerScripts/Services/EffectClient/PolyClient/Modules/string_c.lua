local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
game:GetService("TweenService")
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local char = data.char
	local cf = data.cf

	if not char then
		return
	end

	tick()
	PeodizService.HeartbeatWait({
		Time = 8,
		WaitTime = 0.075
	}, function()
		if not char:IsDescendantOf(workspace) then
			return true
		end

		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and char:FindFirstChild("HeatWhip")) then
			return true
		end

		if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 15 or game.Players.LocalPlayer == data.player then
			_G.shake("SmallerBump")
		end

		local v = math.floor(tick() * 10 % 2) + 1
		local cframe = CFrame.Angles(0, 0, 2.0943951023931953 * v)
		local cFrame = humanoidRootPart.CFrame
		local clone = replicatedStorage.Chest.FruitEffect.String.slash2:Clone()
		clone.Parent = workspace.Effects
		clone.Anchored = false
		local clone2 = replicatedStorage.Chest.FruitEffect.String.slashp:Clone()
		_G.PU:Dust(clone2, 3)
		clone2.Anchored = true
		clone2.CFrame = cFrame * cframe
		clone2.Parent = workspace.Effects
		local cframe2 = CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		local weld = Instance.new("Weld")
		weld.Parent = humanoidRootPart
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone
		weld.C0 = CFrame.new(0, 0, -10) * cframe2
		_G.PU:Dust(clone, 2)
		_G.PU:Dust(weld, 2)
		game.TweenService:Create(weld, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			C0 = CFrame.new(0, 0, -30) * cframe2 * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
		game.TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = cFrame * CFrame.new(0, 0, -30)
		}):Play()
		game.TweenService:Create(
			clone.Mesh,
			TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Scale = clone.Mesh.Scale * 1.75
			}
		):Play()
		game.TweenService:Create(
			clone.Bottom,
			TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
			{
				Transparency = 1
			}
		):Play()
		game.TweenService:Create(
			clone.PointLight,
			TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
			{
				Range = 0,
				Brightness = 0
			}
		):Play()
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8748164748",
			Volume = 2,
			PlaybackSpeed = 1.1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone2
		sound:Play()

		if v == 1 then
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9436006531",
				Volume = 2,
				PlaybackSpeed = 1.5
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone2
			sound2:Play()
		end

		clone2.Specs:Emit(5)
		clone2.shard:Emit(8)
		clone2.Flames:Emit(10)
		clone2.Swirl:Emit(1)
		local Animate = require(clone.Animate)
		Animate()
	end)
end