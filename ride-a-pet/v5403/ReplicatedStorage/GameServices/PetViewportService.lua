local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local pets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Pets")
local PetRigService = require(script.Parent:WaitForChild("PetRigService"))
local PetViewportService = {}
local v = {
	FieldOfView = 40,
	Padding = 1.03,
	SideBias = 0.55,
	HeightBias = 0.3,
	VerticalBias = 0,
	HorizontalBias = 0
}

local function Opt(p, p2)
	local selected = p and p[p2]

	if selected == nil then
		return v[p2]
	end

	return selected
end

local function VisibleBounds(folder)
	local vector2 = nil
	local vector3 = nil

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		local cFrame = part.CFrame
		local size = part.Size
		local vector4 = Vector3.new(
			0.5 * (math.abs(cFrame.XVector.X) * size.X + math.abs(cFrame.YVector.X) * size.Y + math.abs(cFrame.ZVector.X) * size.Z),
			0.5 * (math.abs(cFrame.XVector.Y) * size.X + math.abs(cFrame.YVector.Y) * size.Y + math.abs(cFrame.ZVector.Y) * size.Z),
			0.5 * (math.abs(cFrame.XVector.Z) * size.X + math.abs(cFrame.YVector.Z) * size.Y + math.abs(cFrame.ZVector.Z) * size.Z)
		)
		local v2 = cFrame.Position - vector4
		local v3 = cFrame.Position + vector4

		if vector2 then
			vector2 = Vector3.new(math.min(vector2.X, v2.X), math.min(vector2.Y, v2.Y), (math.min(vector2.Z, v2.Z))) or v2
		else
			vector2 = v2
		end

		if vector3 then
			vector3 = Vector3.new(math.max(vector3.X, v3.X), math.max(vector3.Y, v3.Y), (math.max(vector3.Z, v3.Z))) or v3
		else
			vector3 = v3
		end
	end

	if vector2 then
		return vector2, vector3
	end

	local boundingBox, v2 = folder:GetBoundingBox()
	return boundingBox.Position - v2 / 2, boundingBox.Position + v2 / 2
end

local function FitDistance(p, data, data2, unit, p2, data3)
	local vector2 = -unit
	local cross = vector2:Cross(createVector(0, 1, 0))
	local unit2 = cross.Magnitude > 0.0001 and cross.Unit or createVector(1, 0, 0)
	local unit3 = unit2:Cross(vector2).Unit
	local fieldOfView = data3 and data3.FieldOfView

	if fieldOfView == nil then
		fieldOfView = v.FieldOfView
	end

	local v2 = math.tan((math.rad(fieldOfView / 2)))
	local v3 = v2 * math.max(p2, 0.001)
	local v4 = 0

	for i = 0, 1 do
		for i2 = 0, 1 do
			for i3 = 0, 1 do
				local vector3 = Vector3.new(
					i == 0 and data.X or data2.X,
					i2 == 0 and data.Y or data2.Y,
					i3 == 0 and data.Z or data2.Z
				) - p
				local dot = vector3:Dot(unit)
				v4 = math.max(v4, dot + math.abs((vector3:Dot(unit3))) / v2, dot + math.abs((vector3:Dot(unit2))) / v3)
			end
		end
	end

	local padding = data3 and data3.Padding

	if padding == nil then
		padding = v.Padding
	end

	return (math.max(v4 * padding, 0.1))
end

local function AimCamera(parent, clone, camera, data)
	local v2, v3 = VisibleBounds(clone)
	local midpoint = (v2 + v3) / 2
	local pivot = clone:GetPivot()
	local lookVector = pivot.LookVector
	local rightVector = pivot.RightVector
	local sideBias = data and data.SideBias

	if sideBias == nil then
		sideBias = v.SideBias
	end

	local v5 = lookVector + rightVector * sideBias
	local heightBias = data and data.HeightBias

	if heightBias == nil then
		heightBias = v.HeightBias
	end

	local unit = (v5 + createVector(0, 1, 0) * heightBias).Unit
	local absoluteSize = parent.AbsoluteSize
	local v7 = absoluteSize.Y > 0 and absoluteSize.X / absoluteSize.Y or 1
	local fitDistance = FitDistance(midpoint, v2, v3, unit, v7, data)
	local v9 = createVector(0, 0, 0)
	local verticalBias = data and data.VerticalBias

	if verticalBias == nil then
		verticalBias = v.VerticalBias
	end

	if verticalBias ~= 0 then
		local vector2 = -unit
		local cross = vector2:Cross(createVector(0, 1, 0))
		v9 = (cross.Magnitude > 0.0001 and cross.Unit or createVector(1, 0, 0)):Cross(vector2).Unit * ((v3.Y - v2.Y) * verticalBias)
	end

	local horizontalBias = data and data.HorizontalBias

	if horizontalBias == nil then
		horizontalBias = v.HorizontalBias
	end

	if horizontalBias ~= 0 then
		local cross = (-unit):Cross(createVector(0, 1, 0))
		local unit2 = cross.Magnitude > 0.0001 and cross.Unit or createVector(1, 0, 0)
		local v10 = 2 * fitDistance
		local fieldOfView = data and data.FieldOfView

		if fieldOfView == nil then
			fieldOfView = v.FieldOfView
		end

		v9 += unit2 * (v10 * math.tan((math.rad(fieldOfView / 2))) * v7) * horizontalBias
	end

	camera.CFrame = CFrame.lookAt(midpoint + unit * fitDistance + v9, midpoint + v9)
end

local v2 = {}
local object = setmetatable({}, {
	__mode = "k"
})

local function PlayIdle(parent)
	local animations = parent:FindFirstChild("Animations")
	local idle = animations and animations:FindFirstChild("Idle")

	if not (idle and idle:IsA("Animation")) then
		return
	end

	local primaryPart = parent.PrimaryPart or parent:FindFirstChild("RootPart") or parent:FindFirstChildWhichIsA(
		"BasePart",
		true
	)

	if not primaryPart then
		return
	end

	primaryPart.Name = "HumanoidRootPart"
	parent.PrimaryPart = primaryPart
	local animationController = parent:FindFirstChildOfClass("AnimationController")

	if animationController then
		animationController:Destroy()
	end

	local humanoid = Instance.new("Humanoid")
	humanoid.EvaluateStateMachine = false
	humanoid.Parent = parent
	local animator = Instance.new("Animator")
	animator.Parent = humanoid
	local success, result = pcall(function()
		return animator:LoadAnimation(idle)
	end)

	if not (success and result) then
		warn(string.format("PetViewportService: couldn't load an idle for %s", parent.Name))
		return
	end

	result.Looped = true
	result:Play()
	table.insert(v2, {
		Track = result,
		Model = parent
	})

	for _, v3 in pairs(object) do
		if v3.Model == parent then
			v3.Track = result
		end
	end

	task.spawn(function()
		local v3 = os.clock() + 10

		while result.Length == 0 and os.clock() < v3 and parent.Parent do
			task.wait(0.1)
		end

		if not parent.Parent then
			return
		end

		if result.Length == 0 then
			warn(string.format("PetViewportService: %s idle animation never loaded", parent.Name))
		else
			result.TimePosition = math.random() * result.Length
		end
	end)
end

task.spawn(function()
	while true do
		task.wait(2)

		for i = #v2, 1, -1 do
			local v3 = v2[i]

			if v3.Model.Parent and not v3.Retired then
				if not v3.Track.IsPlaying then
					v3.Track:Play()
				end
			else
				table.remove(v2, i)
			end
		end
	end
end)

function PetViewportService:Build(childName, p, p2)
	local child = pets:FindFirstChild(childName)

	if not child then
		return false
	end

	self:ClearAllChildren()
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = self
	local clone = child:Clone()

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("Sound") or descendant:IsA("LuaSourceContainer") or descendant:IsA("BillboardGui") or descendant:IsA("ProximityPrompt") or descendant:IsA("ParticleEmitter") or descendant:IsA("Highlight") then
			descendant:Destroy()
		end
	end

	if not clone:FindFirstChildWhichIsA("BasePart", true) then
		worldModel:Destroy()
		return false
	end

	PetRigService.HideRideSeat(clone)
	clone.Parent = worldModel
	local camera = Instance.new("Camera")
	local fieldOfView = p and p.FieldOfView

	if fieldOfView == nil then
		fieldOfView = v.FieldOfView
	end

	camera.FieldOfView = fieldOfView
	camera.Parent = self
	self.CurrentCamera = camera
	AimCamera(self, clone, camera, p)
	object[self] = {
		Model = clone
	}

	if p2 ~= false then
		PlayIdle(clone)
	end

	self:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if clone.Parent then
			AimCamera(self, clone, camera, p)
		end
	end)
	return true
end

function PetViewportService.SetAnimated(p, p2)
	local v3 = object[p]

	if not (v3 and v3.Model.Parent) then
		return
	end

	if p2 then
		if v3.Track then
			return
		end

		local humanoid = v3.Model:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

		if not animator then
			PlayIdle(v3.Model)
			return
		end

		local animations = v3.Model:FindFirstChild("Animations")
		local idle = animations and animations:FindFirstChild("Idle")

		if not idle then
			return
		end

		local success, result = pcall(function()
			return animator:LoadAnimation(idle)
		end)

		if success and result then
			result.Looped = true
			result:Play()
			v3.Track = result
			table.insert(v2, {
				Track = result,
				Model = v3.Model
			})
		end
	else
		local track = v3.Track

		if not track then
			return
		end

		v3.Track = nil

		for _, v4 in v2 do
			if v4.Track == track then
				v4.Retired = true
			end
		end

		track:Stop(0)
		track:Destroy()
	end
end

return PetViewportService