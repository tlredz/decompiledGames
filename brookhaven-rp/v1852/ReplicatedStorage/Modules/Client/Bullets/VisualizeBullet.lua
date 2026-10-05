local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local guns = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Guns")

local function getHitSurfaceCFrame(vector2: Vector3, instance)
	if not (vector2 and instance) then
		return nil
	end

	local tagged = CollectionService:GetTagged("PreventBulletHoles")

	for _, ancestor in tagged do
		if instance:IsDescendantOf(ancestor) then
			return
		end
	end

	local v = 1e999
	local v2 = nil

	for _, v3 in {
		{ "Back", instance.CFrame * CFrame.new(0, 0, instance.Size.Z) },
		{ "Bottom", instance.CFrame * CFrame.new(0, -instance.Size.Y, 0) },
		{ "Front", instance.CFrame * CFrame.new(0, 0, -instance.Size.Z) },
		{ "Left", instance.CFrame * CFrame.new(-instance.Size.X, 0, 0) },
		{ "Right", instance.CFrame * CFrame.new(instance.Size.X, 0, 0) },
		{ "Top", instance.CFrame * CFrame.new(0, instance.Size.Y, 0) }
	} do
		local magnitude = (vector2 - v3[2].p).magnitude

		if not (magnitude < v) then
			continue
		end

		v2 = v3
		v = magnitude
	end

	return v2[2]
end

local function createBulletHole(vector2: Vector3, instance, handle)
	local parent = handle.Parent

	if not (parent and vector2 and instance and instance.Parent) then
		return
	end

	if instance.Parent:FindFirstChild("Humanoid") or (instance.Name == "water" or instance.Transparency >= 1) or not instance.Anchored then
		return
	end

	local hitSurfaceCFrame = getHitSurfaceCFrame(vector2, instance)

	if not hitSurfaceCFrame then
		warn("VisualizeBullet:createBulletHole() - SurfaceCF not found")
		return
	end

	local cframe = CFrame.new(instance.Position, hitSurfaceCFrame.Position)
	local v = cframe.LookVector * (instance.Position - hitSurfaceCFrame.Position).magnitude / 2
	local v2 = vector2 - hitSurfaceCFrame.Position + v
	local cFrame = cframe + v + v2
	local v4 = parent:GetAttribute("Shotgun") and 5470828808 or 4520072594
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(1, 1, 0.05)
	local decal = Instance.new("Decal")
	decal.Face = Enum.NormalId.Front
	decal.Texture = `rbxassetid://{v4}`
	decal.Parent = part
	part.Parent = workspace.CurrentCamera
	part.CFrame = cFrame
	task.delay(10, function()
		part:Destroy()
	end)
end

return function(vector2: Vector3, p, instance)
	local handle = instance:FindFirstChild("Handle")

	if not handle then
		return
	end

	local silencer = instance:FindFirstChild("Silencer")
	local v = silencer and silencer.Transparency == 0
	local shot = handle:FindFirstChild("Shot")
	local muzzleEffect = guns:FindFirstChild("MuzzleEffect")
	local barrel = handle:FindFirstChild("Barrel")

	if v then
		shot = handle:FindFirstChild("SilencedShot")
		muzzleEffect = guns:FindFirstChild("SilencedMuzzleEffect")
		barrel = handle:FindFirstChild("SilencedBarrel")
	end

	if not shot then
		warn("VisualizeBullet:playGunSound() - Sound not found")
		return
	end

	if not muzzleEffect then
		warn("VisualizeBullet:playGunSound() - MuzzleEffect not found")
		return
	end

	if not barrel then
		warn("VisualizeBullet:playGunSound() - Barrel not found")
		return
	end

	shot.Volume = 1
	shot.EmitterSize = 1
	shot.MaxDistance = 100
	local clone = shot:Clone()
	clone.PlayOnRemove = true
	clone.Parent = handle
	clone:Destroy()
	local clone2 = muzzleEffect:Clone()
	clone2.Parent = barrel
	clone2:Emit(5)
	createBulletHole(vector2, p, handle)
end