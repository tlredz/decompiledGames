local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SewerSystem = require(game.ReplicatedStorage.Modules.World.SewerSystem)
local v = {
	BRICK_SIZE = 8,
	DEPTH_SCALE_MIN = 0.65,
	FADE_DELAY = 1.8,
	FADE_TIME = 0.8,
	FRAGMENT_LIFETIME = 2.7,
	MAX_ROTATION = 0.05235987755982989,
	REPAIR_DISTANCE_MAX = 34,
	REPAIR_DISTANCE_MIN = 18,
	REPAIR_DROP_MAX = 18,
	REPAIR_DROP_MIN = 5,
	REPAIR_ROTATION = 0.7330382858376184,
	SCRAP_REPAIR_STAGGER_MAX = 0.04,
	REPAIR_SETTLE_TIME = 0.05,
	REPAIR_STAGGER_MAX = 0.08,
	ROW_SIZE_MAX = 1.25,
	ROW_SIZE_MIN = 0.75,
	SCALE = 0.94,
	SEGMENT_WEIGHT_MAX = 1.45,
	SEGMENT_WEIGHT_MIN = 0.55,
	SPEED_MAX = 34,
	SPEED_MIN = 20,
	UPWARD_MAX = 18,
	UPWARD_MIN = 9
}

local function createUnevenSegments(p: number, p2: number, object)
	local v3 = math.max(1, (math.round(p / p2 + object:NextNumber(-0.75, 0.75))))
	local numbers = {}
	local total = 0

	for i = 1, v3 do
		local number = object:NextNumber(0.55, 1.45)
		numbers[i] = number
		total += number
	end

	local v4 = -p * 0.5
	local result = {}

	for i = 1, v3 do
		local v5 = numbers[i]
		local size

		if i == v3 then
			size = p * 0.5 - v4
		else
			size = p * v5 / total
		end

		table.insert(result, {
			center = v4 + size * 0.5,
			size = size
		})
		v4 += size
	end

	return result
end

local function createFragment(instance, size: Vector3, cFrame: CFrame, parent, anchored: boolean, name: string)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = anchored
	part.CanCollide = not anchored
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = instance.CastShadow
	part.CFrame = cFrame
	part.CollisionGroup = instance.CollisionGroup
	part.Color = instance.Color
	part.Material = instance.Material
	part.MaterialVariant = instance.MaterialVariant
	part.CustomPhysicalProperties = PhysicalProperties.new(0.2, 0.6, 0.2, 1, 1)
	part.Reflectance = instance.Reflectance

	if not anchored then
		size *= 0.94
	end

	part.Size = size
	part.Transparency = instance.Transparency
	part.Parent = parent
	return part
end

local function createFragments(instance, parent, random, anchored: boolean, name: string)
	local size = instance.Size
	local unevenSegments = createUnevenSegments(size.Y, 8, random)
	local result = {}

	for _, unevenSegment in unevenSegments do
		local v3 = 8 * random:NextNumber(0.75, 1.25)
		local unevenSegments2 = createUnevenSegments(size.X, v3, random)

		for _, unevenSegment2 in unevenSegments2 do
			local Z

			if anchored then
				Z = size.Z
			else
				Z = size.Z * random:NextNumber(0.65, 1)
			end

			local v4 = anchored and 0 or random:NextNumber(-0.5, 0.5) * (size.Z - Z)
			local v5

			if anchored then
				v5 = CFrame.identity
			else
				v5 = CFrame.Angles(
					random:NextNumber(-0.05235987755982989, 0.05235987755982989),
					random:NextNumber(-0.05235987755982989, 0.05235987755982989),
					random:NextNumber(-0.05235987755982989, 0.05235987755982989)
				)
			end

			local targetCFrame = instance.CFrame * CFrame.new(unevenSegment2.center, unevenSegment.center, v4) * v5
			table.insert(result, {
				part = createFragment(
					instance,
					Vector3.new(unevenSegment2.size, unevenSegment.size, Z),
					targetCFrame,
					parent,
					anchored,
					name
				),
				targetCFrame = targetCFrame
			})
		end
	end

	return result
end

local function getWallScraps(folder)
	local parts = {}

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part:GetAttribute(SewerSystem.WALL_SCRAP_ATTRIBUTE) == true) then
			continue
		end

		table.insert(parts, part)
	end

	return parts
end

local function fadeFragment(p)
	task.delay(1.8, function()
		if p.Parent then
			p.CanCollide = false
			TweenService:Create(p, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
		end
	end)
	Debris:AddItem(p, 2.7)
end

local function throwFragment(instance, vector2: Vector3, unit: Vector3, random)
	local v3 = instance.Position - vector2

	if v3.Magnitude > 0.01 then
		unit = v3.Unit
	end

	instance.Anchored = false
	instance.AssemblyLinearVelocity = unit * random:NextNumber(20, 34) + createVector(0, 1, 0) * random:NextNumber(
		9,
		18
	)
	instance.AssemblyAngularVelocity = Vector3.new(
		random:NextNumber(-8, 8),
		random:NextNumber(-8, 8),
		random:NextNumber(-8, 8)
	)
	pcall(instance.SetNetworkOwner, instance, nil)
	task.delay(v.FADE_DELAY, function()
		if instance.Parent then
			instance.CanCollide = false
			TweenService:Create(instance, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
		end
	end)
	Debris:AddItem(instance, v.FRAGMENT_LIFETIME)
end

local function createScrapClone(instance, name: string, anchored: boolean)
	local clone = instance:Clone()
	clone.Name = name
	clone.Anchored = anchored
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.LocalTransparencyModifier = 0
	clone.Massless = true
	clone:SetAttribute(SewerSystem.WALL_SCRAP_ATTRIBUTE, nil)
	return clone
end

local function animateScrapRepair(clone, cFrame: CFrame, cframe: CFrame, p: number, duration: number, random, transparency: number)
	local pointToWorldSpace = cframe:PointToWorldSpace((Vector3.new(
		random:NextNumber(-3.5, 3.5),
		random:NextNumber(-2.5, 3.5),
		random:NextNumber(-2.5, 2.5)
	)))
	local v3 = p * random:NextNumber(0.86, 1)
	local v4 = v3 * random:NextNumber(0.38, 0.48)
	local v5 = pointToWorldSpace:Lerp(cFrame.Position, 0.48) + createVector(0, 1, 0) * random:NextNumber(5, 11) + cframe.RightVector * random:NextNumber(
		-5,
		5
	)
	local cframe2 = CFrame.Angles(
		random:NextNumber(-3.141592653589793, 3.141592653589793),
		random:NextNumber(-3.141592653589793, 3.141592653589793),
		random:NextNumber(-3.141592653589793, 3.141592653589793)
	)
	clone.CFrame = CFrame.new(pointToWorldSpace) * cFrame.Rotation * cframe2
	clone.Transparency = 1
	task.delay(duration, function()
		if not clone.Parent then
			return
		end

		local tween = TweenService:Create(clone, TweenInfo.new(v4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(v5) * cFrame.Rotation * cframe2:Lerp(CFrame.identity, 0.45),
			Transparency = transparency
		})
		tween:Play()
		tween.Completed:Wait()

		if not clone.Parent then
			return
		end

		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(v3 - v4, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				CFrame = cFrame,
				Transparency = transparency
			}
		)
		tween2:Play()
		tween2.Completed:Wait()

		if clone.Parent then
			clone.CFrame = cFrame
			clone.Transparency = transparency
		end
	end)
end

return table.freeze({
	scatterWall = function(p, vector2: Vector3, parent)
		local random = Random.new()

		for _, v3 in createFragments(p, parent, random, false, "WallFragment") do
			throwFragment(v3.part, vector2, p.CFrame.LookVector, random)
		end

		for _, v3 in getWallScraps(p) do
			local clone = v3:Clone()
			clone.Name = "WallScrapFragment"
			clone.Anchored = false
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.LocalTransparencyModifier = 0
			clone.Massless = true
			clone:SetAttribute(SewerSystem.WALL_SCRAP_ATTRIBUTE, nil)
			clone.Parent = parent
			throwFragment(clone, vector2, p.CFrame.LookVector, random)
		end
	end,
	repairWall = function(self, parent, duration: number, value: number?, cframe: CFrame?)
		local random = Random.new()
		local folder = Instance.new("Folder")
		folder.Name = "LocalWallRepair"
		folder.Parent = parent
		local wallScraps = getWallScraps(self)
		self.LocalTransparencyModifier = 1

		for _, wallScrap in wallScraps do
			wallScrap.LocalTransparencyModifier = 1
		end

		for _, v3 in createFragments(self, folder, random, true, "RepairFragment") do
			local part = v3.part
			local targetCFrame = v3.targetCFrame
			local v4 = targetCFrame.Position - self.Position
			local unit = self.CFrame.LookVector * (random:NextInteger(0, 1) == 0 and -1 or 1)
			local v5 = unit + (not (v4.Magnitude > 0.01) and createVector(0, 0, 0) or v4.Unit * 0.45)

			if v5.Magnitude > 0.01 then
				unit = v5.Unit
			end

			local v6 = targetCFrame.Position + unit * random:NextNumber(18, 34) - createVector(0, 1, 0) * random:NextNumber(
				5,
				18
			)
			local cframe2 = CFrame.Angles(
				random:NextNumber(-0.7330382858376184, 0.7330382858376184),
				random:NextNumber(-0.7330382858376184, 0.7330382858376184),
				random:NextNumber(-0.7330382858376184, 0.7330382858376184)
			)
			part.CFrame = CFrame.new(v6) * targetCFrame.Rotation * cframe2
			part.Transparency = 1
			local number = random:NextNumber(0, 0.08)
			task.delay(number, function()
				if part.Parent then
					local v10 = math.max(duration - number, 0.1)
					TweenService:Create(part, TweenInfo.new(v10, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						CFrame = targetCFrame,
						Transparency = self.Transparency
					}):Play()
				end
			end)
		end

		for _, wallScrap in wallScraps do
			local clone = wallScrap:Clone()
			clone.Name = "RepairScrap"
			clone.Anchored = true
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.LocalTransparencyModifier = 0
			clone.Massless = true
			clone:SetAttribute(SewerSystem.WALL_SCRAP_ATTRIBUTE, nil)
			local number = random:NextNumber(0, 0.04)
			animateScrapRepair(
				clone,
				wallScrap.CFrame,
				cframe or self.CFrame,
				math.max(duration - number, 0.1),
				number,
				random,
				wallScrap.Transparency
			)
			clone.Parent = folder
		end

		task.delay(duration, function()
			if self.Parent then
				self.LocalTransparencyModifier = value or 0
			end

			for _, wallScrap in wallScraps do
				if wallScrap.Parent then
					wallScrap.LocalTransparencyModifier = 0
				end
			end

			task.delay(0.05, function()
				folder:Destroy()
			end)
		end)
		return folder
	end
})