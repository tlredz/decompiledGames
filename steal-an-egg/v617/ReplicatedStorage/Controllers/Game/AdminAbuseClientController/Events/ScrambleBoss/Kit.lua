local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local scrambleBoss = ReplicatedStorage.Assets.Sounds:WaitForChild("ScrambleBoss")
local color = Color3.fromRGB(80, 255, 60)
local v = CameraShaker.new()
v:Start()
local Kit = {
	Green = color,
	Red = Color3.fromRGB(255, 50, 50),
	Debris = function()
		return Workspace:FindFirstChild("Transient") or Workspace
	end
}

function Kit.Anchor(cframe, p: number)
	local part = Instance.new("Part")
	part.Name = "ScrambleFx"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)

	if typeof(cframe) ~= "CFrame" then
		cframe = CFrame.new(cframe)
	end

	part.CFrame = cframe
	part.Parent = Kit.Debris()
	Debris:AddItem(part, p)
	return part
end

function Kit.Shake(p: number, value: number?, value2: number?)
	v:ShakeOnce(p, value or 12, 0.05, value2 or 0.8)
end

function Kit.ShakeFrom(vector2: Vector3, p: number, p2: number)
	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		return
	end

	local v2 = math.clamp(1 - (currentCamera.CFrame.Position - vector2).Magnitude / p2, 0, 1)

	if v2 > 0.05 then
		Kit.Shake(p * v2, 14, 0.9)
	end
end

function Kit.Sound(childName: string, parent, value: number?, value2: number?)
	local child = scrambleBoss:FindFirstChild(childName)

	if child == nil then
		return
	end

	local clone = child:Clone()
	clone.Volume *= value or 1
	clone.PlaybackSpeed *= value2 or 1

	if typeof(parent) == "Vector3" then
		clone.Parent = Kit.Anchor(parent, math.max(clone.TimeLength, 3) + 1)
	else
		if typeof(parent) == "Instance" then
			clone.Parent = parent
		else
			clone.Parent = SoundService
		end

		Debris:AddItem(clone, math.max(clone.TimeLength, 3) + 1)
	end

	clone:Play()
end

function Kit.Loop(childName: string, parent)
	local child = scrambleBoss:FindFirstChild(childName)

	if child == nil then
		return nil, 0
	end

	local clone = child:Clone()
	local volume = clone.Volume
	clone.Looped = true
	clone.Volume = 0
	clone.Parent = parent
	clone:Play()
	return clone, volume
end

function Kit.Part(items)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = Enum.Material.Neon

	for k, item in items do
		part[k] = item
	end

	return part
end

function Kit.Flat(vector2: Vector3)
	return (Vector3.new(vector2.X, 0, vector2.Z))
end

return Kit