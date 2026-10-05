local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.MeshRockModule)
require(game.ReplicatedStorage.Util.ScaleParticle)
require(game.ReplicatedStorage.Util.Debris)
require(game.ReplicatedStorage.Util.Sound)
local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace._WorldOrigin
local _ = workspace.Map
return function(player)
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local part = Instance.new("Part")
	part.CanTouch = false
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Material = "Neon"
	part.Color = Color3.new(1, 1, 1)
	part.Shape = "Cylinder"
	part.Size = createVector(0.25, 17.5, 17.5)
	part.CFrame = Util.Misc.AlignCFrame(CFrame.new(player.Mouse.Hit.p), player.Mouse.Hit.UpVector) * CFrame.Angles(
		0,
		0,
		1.5707963267948966
	)
	part.Parent = _WorldOrigin
	TweenService:Create(part, TweenInfo.new(1.0111111111111108, Enum.EasingStyle.Linear), {
		Transparency = 0.75,
		Size = createVector(0.25, 118.75, 118.75)
	}):Play()

	while humanoid:IsDescendantOf(workspace) and humanoid.Health > 0 and humanoidRootPart:IsDescendantOf(workspace) and player.Status and player.Status:IsDescendantOf(workspace) do
		local position = humanoidRootPart.Position
		local p = player.Mouse.Hit.p
		local v = p - position

		if v.Magnitude > 200 then
			v = (p - position).Unit * 200
		end

		local ray = Util.Ray
		local v2 = position + v + createVector(0, 0.1, 0)
		local v3 = { workspace.Characters, workspace.Enemies }
		local v4, v5, v6 = ray(v2, createVector(0, -55.1, 0), v3)

		if v4 then
			part.CFrame = Util.Misc.AlignCFrame(CFrame.new(v5), v6) * CFrame.Angles(0, 0, 1.5707963267948966)
		end

		task.wait(0.016666666666666666)
	end

	TweenService:Create(part, TweenInfo.new(0.1), {
		Transparency = 1
	}):Play()
	wait(0.5)
	part:Destroy()
end