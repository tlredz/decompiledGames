local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local fromcf = data.fromcf
	local tocf = data.tocf
	local range = data.range
	local plr = data.plr
	local v = range / 600
	local clone = replicatedStorage.Chest.FruitEffect.Ink.ink_slash:Clone()
	clone.Anchored = true
	clone.CFrame = fromcf
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 1)
	TweenService:Create(clone, TweenInfo.new(v, Enum.EasingStyle.Linear), {
		CFrame = tocf
	}):Play()

	if game.Players.LocalPlayer == plr then
		_G.shake("SmallerBump")
	end

	wait(v)

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
			descendant.Enabled = false
		elseif descendant:IsA("Decal") then
			TweenService:Create(
				descendant,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end
	end

	local clone2 = replicatedStorage.Chest.FruitEffect.Ink.bamboo:Clone()
	clone2.Anchored = true
	clone2.CanCollide = false
	clone2.CFrame = CFrame.new(tocf.p + createVector(0, 1.5, 0)) * CFrame.Angles(
		0,
		6.283185307179586 * math.random(),
		0
	)
	clone2.Parent = workspace.Effects
	local Animated = require(clone2.Animated)
	Animated()
	_G.PU:Dust(clone2, 2)

	if (localPlayer.Character.HumanoidRootPart.Position - tocf.p).Magnitude < 50 or game.Players.LocalPlayer == plr then
		_G.shake("SmallBump")
	end
end