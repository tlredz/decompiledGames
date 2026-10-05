local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Template = require(script.Parent.Template)

function getAnchorPosition(instance)
	local teleporterVFX = instance:FindFirstChild("TeleporterVFX")
	local base

	if teleporterVFX then
		base = teleporterVFX:FindFirstChild("Base")
	end

	if base and base:IsA("BasePart") then
		return base.CFrame.Position
	end

	return instance:GetPivot().Position
end

function getTargetPosition(p: number, cframe: CFrame)
	local vector2 = Vector3.new(cframe.LookVector.X, 0, cframe.LookVector.Z)
	local v = not (vector2.Magnitude > 0.01) and createVector(0, 0, -1) or vector2 / vector2.Magnitude
	return cframe.Position + v * p - createVector(0, 25, 0)
end

function clearLeftovers()
	for _, child in workspace:GetChildren() do
		if child.Name == "WorldTeleporterDebug" then
			child:Destroy()
		end
	end
end

local StoryTeleporter = {
	DEFAULT_DISTANCE = 110,
	MIN_DISTANCE = 40,
	MAX_DISTANCE = 300,
	findSource = function()
		local model = CollectionService:GetTagged("WORLD_TELEPORTER")[1]

		if not model then
			warn("no instance tagged \"WORLD_TELEPORTER\" found")
			return nil
		end

		if model:IsA("Model") then
			return model
		end

		warn((`{model:GetFullName()} is tagged "WORLD_TELEPORTER" but is not a Model`))
		return nil
	end,
	placeInFrontOfCamera = function(instance, p: number, cFrame: CFrame?)
		local currentCamera = workspace.CurrentCamera

		if not cFrame and currentCamera then
			cFrame = currentCamera.CFrame
		end

		if not cFrame then
			return
		end

		local v = getTargetPosition(p, cFrame) - getAnchorPosition(instance)
		instance:PivotTo(instance:GetPivot() + v)
	end
}

function StoryTeleporter.create(p, p2: number, cframe: CFrame?)
	clearLeftovers()
	local copy = Template.copy(p)
	copy.Name = "WorldTeleporterDebug"
	StoryTeleporter.placeInFrontOfCamera(copy, p2, cframe)
	copy.Parent = workspace
	return copy, function()
		copy:Destroy()
	end
end

return StoryTeleporter