local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local surfaceHit = FX:WaitForChild("Creation").SurfaceHit
workspace:WaitForChild("_WorldOrigin")
local _ = {
	"rbxassetid://89597371734260",
	"rbxassetid://71085425555113",
	"rbxassetid://127033087282795",
	"rbxassetid://84521437474990",
	"rbxassetid://94451837589678"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function GetCFramePlane(cframe, p)
	local function ProjectToPlane2D(p2, cframe2)
		local _ = cframe2.UpVector
		local pointToObjectSpace = cframe2:PointToObjectSpace(p2)
		local pointToWorldSpace = cframe2:PointToWorldSpace((Vector3.new(pointToObjectSpace.X, pointToObjectSpace.Y, 0)))
		return CFrame.lookAt(pointToWorldSpace, pointToWorldSpace + cframe2.LookVector)
	end

	local position = p.Position
	local _ = cframe.UpVector
	local pointToObjectSpace = cframe:PointToObjectSpace(position)
	local pointToWorldSpace = cframe:PointToWorldSpace((Vector3.new(pointToObjectSpace.X, pointToObjectSpace.Y, 0)))
	return (CFrame.lookAt(pointToWorldSpace, pointToWorldSpace + cframe.LookVector))
end

local function SurfaceHit(p, folder)
	local v = {
		Color3.fromRGB(255, 58, 127),
		Color3.fromRGB(87, 255, 185),
		Color3.fromRGB(84, 69, 255),
		Color3.fromRGB(142, 49, 255),
		Color3.fromRGB(85, 167, 255)
	}
	local clone = surfaceHit.Phase3.ObjectHitImpact:Clone()
	clone.CFrame = p * CFrame.new(0, 0, 1.5)
	clone.Parent = folder

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
		local v2 = v[math.random(1, #v)]
		emitter.Color = ColorSequence.new(v2, v2)
	end

	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
end

local function snapToSurface(clone, cube, position)
	local pointToObjectSpace = cube.CFrame:PointToObjectSpace(position)
	local vector2 = Vector3.new(
		not (math.abs(pointToObjectSpace.X) > math.abs(pointToObjectSpace.Z)) and 0 or math.sign(pointToObjectSpace.X) or 0,
		0,
		math.abs(pointToObjectSpace.Z) > math.abs(pointToObjectSpace.X) and math.sign(pointToObjectSpace.Z) or 0
	)

	if vector2 == createVector(0, 0, 0) then
		return
	end

	local vectorToWorldSpace = cube.CFrame:VectorToWorldSpace(vector2)
	local v = position + vectorToWorldSpace * (clone.Size / 2).X
	clone.CFrame = CFrame.new(v, v + vectorToWorldSpace)
end

return function(data)
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local root = data.Root
	local hit = data.Hit
	local cube = data.Cube
	local folder = Instance.new("Folder", workspace._WorldOrigin)
	task.spawn(function()
		local clone = surfaceHit.Phase3.Portal:Clone()
		clone.CFrame = data.CFrame and data.CFrame or root.CFrame
		Util.Sound:Play(
			"CreationFruit_V2_M1_CardHitNPC_BassyExplosion_0" .. tostring(math.random(1, 12)),
			clone.Position
		)
		snapToSurface(clone, cube, hit.Position)
		clone.CFrame *= CFrame.new(0, 0, 3)
		clone.Parent = folder
		SurfaceHit(clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0), folder)
		task.wait(0.5)
		clone:Destroy()
	end)
end