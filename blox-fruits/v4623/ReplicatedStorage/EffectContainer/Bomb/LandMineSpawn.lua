local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.MeshRockModule)
require(game.ReplicatedStorage.Util.ScaleParticle)
require(game.ReplicatedStorage.Util.Debris)
require(game.ReplicatedStorage.Util.Sound)
local Util = require(game.ReplicatedStorage.Util)
local _ = workspace._WorldOrigin
local _ = workspace.Map
return function(player)
	local _ = player.Hit
	local _ = player.Position
	local _ = player.Normal
	local _ = player.Scale
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local ray = Util.Ray
	local position = humanoidRootPart.Position
	local v = { workspace.Characters, workspace.Enemies }
	local _, v2, _ = ray(position, createVector(0, -10, 0), v)
	local part = Instance.new("Part")
	part.CanTouch = false
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Material = "Neon"
	part.Color = Color3.new(1, 0.33, 0)
	part.Shape = "Cylinder"
	part.Size = createVector(0.25, 0, 0)
	part.CFrame = CFrame.new(v2) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = workspace._WorldOrigin
	TweenService:Create(part, TweenInfo.new(2.962962962962963, Enum.EasingStyle.Linear), {
		Transparency = 0.5,
		Size = createVector(0.25, 192.5, 192.5)
	}):Play()

	while humanoid:IsDescendantOf(workspace) and humanoid.Health > 0 and humanoidRootPart:IsDescendantOf(workspace) and player.Status and player.Status:IsDescendantOf(workspace) do
		local ray2 = Util.Ray
		local position2 = humanoidRootPart.Position
		local v3 = { workspace.Characters, workspace.Enemies }
		local _, v4, _ = ray2(position2, createVector(0, -10, 0), v3)
		part.CFrame = CFrame.new(v4) * CFrame.Angles(0, 0, 1.5707963267948966)
		wait()
	end

	TweenService:Create(part, TweenInfo.new(0.1), {
		Transparency = 1
	}):Play()
	wait(0.5)
	part:Destroy()
end