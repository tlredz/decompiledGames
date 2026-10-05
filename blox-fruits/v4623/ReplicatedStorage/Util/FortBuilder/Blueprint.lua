local createVector = vector.create
local module = require("./Blueprint/Matrix")
local module2 = require("./Blueprint/Structure")
local Cutter = require(script.Cutter)
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function closestQuotient(p: number, p2: number)
	return (math.floor(p / p2 + 0.5))
end

local function generateSquareMatrixArray(p: number, p2)
	local result = {}

	for _ = 1, p do
		table.insert(result, table.create(p, p2))
	end

	return result
end

local function zeroOutermostEdges(list)
	local count = #list

	if count == 0 then
		return list
	end

	local count2 = #list[1]

	for i = 1, count do
		list[i][1] = 0
		list[i][count2] = 0
	end

	for i = 1, count2 do
		list[1][i] = 0
		list[count][i] = 0
	end

	return list
end

local function zeroOutermostColumns(list)
	local count = #list

	if count == 0 then
		return list
	end

	local v = #list[1]

	for i = 1, count do
		list[i][1] = 0
		list[i][v] = 0
	end

	return list
end

local function generateMatrixArray(p: number, p2: number, p3)
	local result = {}

	for _ = 1, p do
		table.insert(result, table.create(p2, p3))
	end

	return result
end

local Blueprint = {
	createOnPart = function(parent, value: number?, p: string, p2: number, flag: boolean?)
		if flag == true then
			local model_2 = Instance.new("Model")
			model_2.Parent = parent
			return
		end

		local v = value or 2.5
		local size = parent.Size
		local v2 = closestQuotient(size.X, v) -- equivalent call inferred; original call site unknown
		local v3 = closestQuotient(size.Y, v) -- equivalent call inferred; original call site unknown
		local v4 = generateMatrixArray(v3, v2, 1)

		if p2 > 1 then
			v4 = Cutter.getCutMatrix(p, p2, v4)
		end

		if p == "Wall" and p2 == 4 then
			local count = #v4

			if count ~= 0 then
				local v5 = #v4[1]

				for i = 1, count do
					v4[i][1] = 0
					v4[i][v5] = 0
				end
			end
		else
			zeroOutermostEdges(v4)
		end

		local blocks = module.new(v4):computeBlocks(true)
		local v5 = #v4
		local v6 = #v4[1]
		local vector2 = Vector3.new(size.X / v2, size.Y / v3, size.Z)
		local v7 = module2.new(v5, v6, nil, blocks, vector2)
		local model = v7:getModel()
		model.Parent = parent
		model:PivotTo(parent.CFrame)
		v7:show()
	end
}

local function clearAllAttributes(instance)
	for k in pairs(instance:GetAttributes()) do
		instance:SetAttribute(k, nil)
	end
end

local TweenService = game:GetService("TweenService")
local MaterialService = game:GetService("MaterialService")
local flag = false

local function loadMaterial()
	if flag then
		return
	end

	if not MaterialService:FindFirstChild("TetrisGrid") then
		local clone = script.TetrisGrid:Clone()
		clone.Parent = MaterialService
		flag = true
	end
end

function Blueprint.animateInAnimationModel(parent, duration: number, flag2: boolean?)
	if RunService:IsServer() or not ((workspace.CurrentCamera.CFrame.Position - parent.Position).Magnitude < 2500) then
		return
	end

	if not (flag or MaterialService:FindFirstChild("TetrisGrid")) then
		local clone = script.TetrisGrid:Clone()
		clone.Parent = MaterialService
		flag = true
	end

	local color = Color3.fromRGB(55, 55, 55)
	local v = flag2 == true and createVector(1, 1, 1) or createVector(1, 1, 0.8)
	local collisionModel = parent:FindFirstChild("CollisionModel")
	local parent2

	if collisionModel then
		parent2 = collisionModel:Clone()
	else
		parent2 = Instance.new("Model")
		local instance = Instance.fromExisting(parent)
		clearAllAttributes(instance)
		instance.Parent = parent2
	end

	parent2.Name = "AnimationModel"

	for _, child in ipairs(parent2:GetChildren()) do
		child.CanCollide = false
		child.CanTouch = false
		child.CanQuery = false
		child.Transparency = 0
		child.Color = Color3.new(1, 1, 1)
		child.Reflectance = 0
		child.Material = Enum.Material.SmoothPlastic
		child.MaterialVariant = "TetrisGrid"
		child.Size *= v
	end

	parent2:ScaleTo(0.2)
	parent2.Parent = parent
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0.2
	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(duration, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{
			Value = 1
		}
	)
	local valueChangedConnection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		parent2:ScaleTo(numberValue.Value)
	end)
	local numberValue2 = Instance.new("NumberValue")
	numberValue2.Value = 0
	local tween2 = TweenService:Create(
		numberValue2,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{
			Value = 1
		}
	)
	local valueChangedConnection2 = numberValue2:GetPropertyChangedSignal("Value"):Connect(function()
		local value = numberValue2.Value

		for _, child in ipairs(parent2:GetChildren()) do
			child.Color = Color3.new(1, 1, 1):Lerp(color, value)
		end
	end)
	task.delay(duration, function()
		valueChangedConnection:Disconnect()
		valueChangedConnection2:Disconnect()
		local collisionModel2 = parent:FindFirstChild("CollisionModel")

		if collisionModel2 then
			for _, child in ipairs(collisionModel2:GetChildren()) do
				child.Transparency = 0
				child.Color = color
				child.Reflectance = 0
				child.Material = Enum.Material.SmoothPlastic
				child.MaterialVariant = "TetrisGrid"

				if flag2 ~= true then
					child.Size *= v
				end
			end
		else
			local parent3 = parent
			parent3.Transparency = 0
			parent3.Color = color
			parent3.Reflectance = 0
			parent3.Material = Enum.Material.SmoothPlastic
			parent3.MaterialVariant = "TetrisGrid"

			if flag2 ~= true then
				parent3.Size *= v
			end
		end

		parent2:Destroy()
	end)
	tween:Play()
	tween2:Play()
end

function Blueprint:animateOutAnimationModel(duration: number)
	if RunService:IsServer() or not ((workspace.CurrentCamera.CFrame.Position - self.Position).Magnitude < 2500) then
		return
	end

	local TweenService2 = game:GetService("TweenService")

	if self:GetAttribute("AnimationModelAnimatingOut") then
		return
	end

	self:SetAttribute("AnimationModelAnimatingOut", true)
	local collisionModel = self:FindFirstChild("CollisionModel")
	local parent

	if collisionModel then
		parent = collisionModel:Clone()
		self.Transparency = 1

		for _, child in ipairs(collisionModel:GetChildren()) do
			child.Transparency = 1
		end
	else
		parent = Instance.new("Model")
		local instance = Instance.fromExisting(self)
		clearAllAttributes(instance)
		instance.Parent = parent
		self.Transparency = 1
	end

	parent.Name = "AnimationModel"

	for _, child in ipairs(parent:GetChildren()) do
		child.CanCollide = false
		child.CanTouch = false
		child.CanQuery = false
		child.Transparency = 0
	end

	local scale = parent:GetScale()
	parent.Parent = self
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = scale
	local tween = TweenService2:Create(
		numberValue,
		TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
		{
			Value = 0.01
		}
	)
	local valueChangedConnection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		parent:ScaleTo(numberValue.Value)
	end)
	local numberValue2 = Instance.new("NumberValue")
	numberValue2.Value = 0
	local tween2 = TweenService2:Create(
		numberValue2,
		TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
		{
			Value = 1
		}
	)
	local color = parent:GetChildren()[1].Color
	local valueChangedConnection2 = numberValue2:GetPropertyChangedSignal("Value"):Connect(function()
		local value = numberValue2.Value

		for _, child in ipairs(parent:GetChildren()) do
			child.Color = color:Lerp(Color3.new(1, 1, 1), value)
		end
	end)
	task.delay(duration, function()
		valueChangedConnection:Disconnect()
		valueChangedConnection2:Disconnect()
		parent:Destroy()
	end)
	tween:Play()
	tween2:Play()
end

function Blueprint.cutPartInstance(p: string, p2: number, p3, value: number?)
	local v = value or 2.5
	local size = p3.Size
	local v2 = closestQuotient(size.X, v) -- equivalent call inferred; original call site unknown
	local v3 = closestQuotient(size.Y, v) -- equivalent call inferred; original call site unknown
	local v4 = generateMatrixArray(v3, v2, 1)
	return Cutter.cutPartInstance(p, p2, p3, v4)
end

function transferBasePartProperties(instance, p)
	p.Anchored = instance.Anchored
	p.Massless = instance.Massless
	p.CanCollide = instance.CanCollide
	p.CanTouch = instance.CanTouch
	p.CanQuery = instance.CanQuery
	p.CollisionGroup = instance.CollisionGroup
	p.Locked = instance.Locked
	p.BrickColor = instance.BrickColor
	p.Color = instance.Color
	p.Material = instance.Material
	p.MaterialVariant = instance.MaterialVariant
	p.Transparency = instance.Transparency
	p.Reflectance = instance.Reflectance
	p.CastShadow = instance.CastShadow
	p.LocalTransparencyModifier = instance.LocalTransparencyModifier
	p.TopSurface = instance.TopSurface
	p.BottomSurface = instance.BottomSurface
	p.FrontSurface = instance.FrontSurface
	p.BackSurface = instance.BackSurface
	p.LeftSurface = instance.LeftSurface
	p.RightSurface = instance.RightSurface
	p.CFrame = instance.CFrame
	p.Size = instance.Size
	p.CustomPhysicalProperties = instance.CustomPhysicalProperties
	p.Name = instance.Name
	return p
end

function Blueprint:useCustomGeometry(folder)
	local model = Instance.new("Model")
	model.Name = "CollisionModel"
	local isPotentialSurface = self:GetAttribute("IsPotentialSurface")
	local v = {}

	if folder:IsA("BasePart") then
		table.insert(v, folder)
	elseif folder:IsA("Model") then
		for _, part in ipairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				table.insert(v, part)
			end
		end
	end

	for _, v2 in ipairs(v) do
		local v3 = transferBasePartProperties(self, v2:Clone())
		clearAllAttributes(v3)
		v3.CanCollide = not isPotentialSurface
		v3.CanTouch = not isPotentialSurface
		v3.CanQuery = false
		v3.Parent = model
	end

	model.Parent = self
	self.CanCollide = false
	return model
end

function Blueprint.hideModel(instance, duration: number)
	local pivot = instance:GetPivot()

	if not ((workspace.CurrentCamera.CFrame.Position - pivot.Position).Magnitude < 2500) then
		instance:Destroy()
		return
	end

	instance:SetAttribute("IsAnimatingOut", true)
	task.delay(duration, function()
		instance:SetAttribute("IsAnimatingOut", nil)
	end)

	for _, model in ipairs(instance:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		local pivot2 = model:GetPivot()
		local scale = model:GetScale()
		local v = pivot2 * (CFrame.new(math.random(-10, 10), math.random(5, 12), math.random(-10, 10)) * CFrame.Angles(
			0,
			math.rad((math.random(0, 360))),
			0
		))
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		local tween = TweenService:Create(
			numberValue,
			TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
			{
				Value = 1
			}
		)
		local v5 = model
		local connection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			local value = numberValue.Value
			v5:PivotTo((pivot2:Lerp(v, value)))
			local v7 = (1 - value) * scale
			v5:ScaleTo((math.max(v7, 0.01)))
		end)
		task.delay(duration, function()
			connection:Disconnect()
		end)
		tween:Play()
	end
end

local random = Random.new()

local function pointAbovePlane(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	return (vector2 - vector3):Dot(vector4) > 0
end

local _ = time

function Blueprint.jitterModel(instance)
	if not (instance:GetAttribute("IsAnimatingIn") ~= true and instance:GetAttribute("IsAnimatingOut") ~= true and instance:GetAttribute("IsJittering") ~= true) then
		return
	end

	instance:SetAttribute("IsJittering", true)
	local position = workspace.CurrentCamera.CFrame.Position
	local position2 = instance.Parent.CFrame.Position
	local lookVector = instance.Parent.CFrame.LookVector
	local v = (position - position2):Dot(lookVector) > 0 == true and 1 or -1

	for _, model in ipairs(instance:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		if model:GetAttribute("DefaultPivot") == nil then
			model:SetAttribute("DefaultPivot", model:GetPivot())
		end

		local defaultPivot = model:GetAttribute("DefaultPivot")
		local v2 = defaultPivot * CFrame.new(0, -v * random:NextNumber(0.5, 1), 0) * CFrame.Angles(
			0,
			random:NextNumber(-0.1, 0.14),
			0
		)
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		local tween = TweenService:Create(
			numberValue,
			TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
			{
				Value = 1
			}
		)
		local valueChangedConnection = nil
		local v6 = model
		valueChangedConnection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			if instance:GetAttribute("IsJittering") ~= true then
				valueChangedConnection:Disconnect()
				return
			end

			v6:PivotTo((defaultPivot:Lerp(v2, numberValue.Value)))
		end)
		task.delay(0.25, function()
			valueChangedConnection:Disconnect()
		end)
		tween:Play()
	end
end

function Blueprint.stopJitterModel(instance)
	if not (instance:GetAttribute("IsAnimatingIn") ~= true and instance:GetAttribute("IsAnimatingOut") ~= true and instance:GetAttribute("IsJittering") == true) then
		return
	end

	instance:SetAttribute("IsJittering", nil)

	for _, model in ipairs(instance:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		local defaultPivot = model:GetAttribute("DefaultPivot")

		if defaultPivot == nil then
			continue
		end

		local pivot = model:GetPivot()
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		local tween = TweenService:Create(
			numberValue,
			TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
			{
				Value = 1
			}
		)
		local v3 = defaultPivot
		local v4 = model
		local connection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			v4:PivotTo((pivot:Lerp(v3, numberValue.Value)))
		end)
		task.delay(0.2, function()
			connection:Disconnect()
		end)
		tween:Play()
	end
end

return Blueprint