local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("Debris")
local TsunamiEventController = require(ReplicatedStorage.Controllers.TsunamiEventController)
local AnimalController = require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local VFX = require(ReplicatedStorage.Shared.VFX)

local function fn() end

local function getAnimalCFrame(primaryPart, p)
	local animalModel, v

	if ServerData.IsTsunamiServer() then
		local brainrotCFrame
		brainrotCFrame, animalModel = TsunamiEventController:GetBrainrotCFrame(primaryPart)

		if brainrotCFrame and animalModel then
			v = brainrotCFrame * CFrame.new(0, animalModel:GetExtentsSize().Y * 0.5, 0)
		else
			return CFrame.identity
		end
	else
		local v2 = AnimalController:GetAnimals()[primaryPart]

		if not v2 then
			return CFrame.identity
		end

		animalModel = v2.AnimalModel
		assert(animalModel)
		v = animalModel:GetPivot() * CFrame.new(0, animalModel:GetExtentsSize().Y * 0.5, 0)
	end

	if not (v and animalModel) then
		return CFrame.identity
	end

	if p and p.top then
		return v * CFrame.new(0, animalModel:GetExtentsSize().Y * 0.5, 0)
	end

	if p and p.bottom then
		return v * CFrame.new(0, -animalModel:GetExtentsSize().Y * 0.5, 0)
	end

	return v
end

local ClientEventUtils = {}

function ClientEventUtils.getAnimalModel(p: string)
	if ServerData.IsTsunamiServer() then
		local _, v = TsunamiEventController:GetBrainrotCFrame(p)
		return v or nil
	else
		local v = AnimalController:GetAnimals()[p]

		if v then
			return v.AnimalModel
		end

		return nil
	end
end

ClientEventUtils.getAnimalCFrame = getAnimalCFrame

function ClientEventUtils.getAnimalPosition(p, p2)
	local animalModel, position

	if ServerData.IsTsunamiServer() then
		local brainrotCFrame
		brainrotCFrame, animalModel = TsunamiEventController:GetBrainrotCFrame(p)

		if brainrotCFrame and animalModel then
			position = brainrotCFrame.Position + Vector3.new(0, animalModel:GetExtentsSize().Y * 0.5, 0)
		else
			return createVector(0, 0, 0)
		end
	else
		local v = AnimalController:GetAnimals()[p]

		if not v then
			return createVector(0, 0, 0)
		end

		position = v.AnimalModel:GetPivot().Position
		animalModel = v.AnimalModel
	end

	if not (position and animalModel) then
		return createVector(0, 0, 0)
	end

	if p2 and p2.top then
		return position + Vector3.new(0, animalModel:GetExtentsSize().Y * 0.5, 0)
	end

	if p2 and p2.bottom then
		position -= Vector3.new(0, animalModel:GetExtentsSize().Y * 0.5, 0)
	end

	return position
end

function ClientEventUtils.getAnimalRootPart(p: string)
	local animalModel

	if ServerData.IsTsunamiServer() then
		local _, v = TsunamiEventController:GetBrainrotCFrame(p)
		animalModel = v or nil
	else
		local v = AnimalController:GetAnimals()[p]

		if v then
			animalModel = v.AnimalModel
		end
	end

	if animalModel then
		return animalModel.PrimaryPart
	end

	return nil
end

function ClientEventUtils.playBurst(instance, primaryPart, items, p)
	local animalModel, cframe

	if typeof(primaryPart) == "string" then
		if ServerData.IsTsunamiServer() then
			local _, v = TsunamiEventController:GetBrainrotCFrame(primaryPart)
			animalModel = v or nil
		else
			local v = AnimalController:GetAnimals()[primaryPart]

			if v then
				animalModel = v.AnimalModel
			end
		end

		cframe = getAnimalCFrame(primaryPart, p)

		if animalModel and cframe then
			primaryPart = animalModel.PrimaryPart

			if not primaryPart then
				return fn
			end
		else
			return fn
		end
	elseif typeof(primaryPart) == "CFrame" then
		animalModel = workspace
		cframe = primaryPart
		primaryPart = nil
	elseif typeof(primaryPart) == "Vector3" then
		cframe = CFrame.new(primaryPart)
		animalModel = workspace
		primaryPart = nil
	else
		cframe = primaryPart:GetPivot()
		animalModel = primaryPart
	end

	local clone = instance:Clone()

	if p and p.modify then
		clone = p.modify(clone)
	end

	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone:PivotTo(cframe)

	if primaryPart == nil then
		clone.Anchored = true
	else
		clone.Anchored = false
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = clone
		weldConstraint.Part1 = primaryPart
		weldConstraint.Parent = clone
	end

	clone.Parent = animalModel
	VFX.emit(clone)
	task.delay(5, function()
		clone:Destroy()
	end)

	if items ~= nil then
		for _, item in items do
			SoundController:PlaySound(item, cframe.Position, false)
		end
	end

	return function()
		clone:Destroy()
	end
end

function ClientEventUtils.resizeEffects(p, p2: number)
	local parent = p.Parent
	local model = Instance.new("Model")
	p.Parent = model
	model:ScaleTo(p2)
	p.Parent = parent
	model:Destroy()
end

function ClientEventUtils.fitEffectsToEggMap(part)
	local borders = workspace.Map:FindFirstChild("Borders")

	if not (borders and borders:IsA("Model")) then
		return
	end

	local boundingBox, v = borders:GetBoundingBox()
	local parts = {}

	if part:IsA("BasePart") then
		table.insert(parts, part)
	end

	for _, part2 in part:GetDescendants() do
		if part2:IsA("BasePart") then
			table.insert(parts, part2)
		end
	end

	if #parts == 0 then
		return
	end

	local v2 = 1e999
	local v3 = -1e999
	local v4 = 1e999
	local v5 = -1e999

	for _, v6 in parts do
		local position = v6.Position
		local size = v6.Size
		v2 = math.min(v2, position.X - size.X / 2)
		v3 = math.max(v3, position.X + size.X / 2)
		v4 = math.min(v4, position.Z - size.Z / 2)
		v5 = math.max(v5, position.Z + size.Z / 2)
	end

	local midpoint = (v2 + v3) / 2
	local midpoint2 = (v4 + v5) / 2
	local v8 = v.X / math.max(v3 - v2, 1)
	local v9 = v.Z / math.max(v5 - v4, 1)
	local position = boundingBox.Position

	for _, v10 in parts do
		local position2 = v10.Position
		local size = v10.Size

		if math.max(size.X, size.Z) >= 100 then
			v10.Size = Vector3.new(size.X * v8, size.Y, size.Z * v9)
		end

		v10.Position = Vector3.new(
			position.X + (position2.X - midpoint) * v8,
			position2.Y,
			position.Z + (position2.Z - midpoint2) * v9
		)
	end
end

return ClientEventUtils