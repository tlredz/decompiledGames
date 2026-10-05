local createVector = vector.create
local TweenService = game:GetService("TweenService")
local blocks = script:WaitForChild("Blocks")

-- equivalent calls inferred from this helper; original call sites unknown
local function MakePastel(color)
	local HSV, v, v2 = color:ToHSV()
	local v3 = math.clamp(v * 0.5 + 0.2, 0, 1)
	local v4 = math.clamp(v2 + 0.1, 0, 1)
	return Color3.fromHSV(HSV, v3, v4)
end

for _, descendant in blocks:GetDescendants() do
	if descendant.Name == "Outside" then
		descendant.Color = MakePastel(descendant.Color)
	end
end

local collider = script:WaitForChild("Collider")
local Structure = {}
Structure.__index = Structure

function Structure.new(rows: number, cols: number, _, block_template, vector2: Vector3?)
	local self = setmetatable({}, Structure)
	self.model = Instance.new("Model")
	self.rows = rows
	self.cols = cols
	self.block_template = block_template
	self.scaleVector = vector2 or createVector(1, 1, 1)
	self.colliders = {}
	self.blocks = {}
	self:build()
	return self
end

function Structure:build()
	self.model:ClearAllChildren()
	table.clear(self.blocks)
	local instance = Instance.fromExisting(collider)
	instance.Transparency = 1
	instance.Anchored = true
	instance.CanCollide = false
	instance.CanTouch = false
	instance.CanQuery = false
	instance.Size = Vector3.new(self.cols * 1, self.rows * 1, 1) * self.scaleVector
	instance.Name = "Hitbox"
	instance.Parent = self.model
	self.model.PrimaryPart = instance

	for _, v in pairs(self.block_template) do
		local child = blocks:FindFirstChild(v.block_type)

		if not child then
			continue
		end

		local clone = child:Clone()

		for _, child2 in ipairs(clone:GetChildren()) do
			local pivot = clone:GetPivot()
			local position = child2.Position
			child2.Position = pivot.Position + (position - pivot.Position) * Vector3.new(
				self.scaleVector.X,
				self.scaleVector.Y,
				1
			)
			child2.Size *= self.scaleVector
		end

		local extentsSize = clone:GetExtentsSize()
		local v2 = v.position - Vector2.one
		local rotation = v.rotation
		local vector2 = Vector3.new(v2.X * self.scaleVector.Y, 0, v2.Y * self.scaleVector.X)
		local cframe = CFrame.Angles(0, 1.5707963267948966 * rotation, 0)
		local v3 = CFrame.new(vector2) * cframe + (cframe * (extentsSize * createVector(0.5, 0, 0.5))):Abs()
		local transform = CFrame.new(instance.Size / 2 * createVector(1, 1, 0)) * CFrame.Angles(
			0,
			0,
			-1.5707963267948966
		) * CFrame.Angles(1.5707963267948966, 0, 0) * v3
		clone:PivotTo(transform)
		table.insert(self.blocks, {
			instance = clone,
			transform = transform
		})
	end

	table.sort(self.blocks, function(a, b)
		return a.transform.Position.Y < b.transform.Position.Y
	end)
end

function Structure:destroy()
	self.model:Destroy()
	self.model = nil
end

function Structure.hide(p)
	for _, block in pairs(p.blocks) do
		block.Parent = nil
	end

	for _, block in pairs(p.blocks) do
		block.instance.Parent = nil
	end
end

function Structure.show(data)
	local cFrame = data.model.PrimaryPart.CFrame
	local size = data.model.PrimaryPart.Size
	local v = (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < 1500

	if v then
		data.model:SetAttribute("IsAnimatingIn", true)
	end

	local blocks2 = {}

	for _, block in pairs(data.blocks) do
		if v and math.random() < 1 then
			table.insert(blocks2, block)
		else
			block.instance:PivotTo(cFrame * block.transform)
			block.instance.Parent = data.model
		end
	end

	local function burstBlock(instance)
		for _, child in pairs(instance:GetChildren()) do
			if child.Name == "Outside" then
				continue
			end

			local instance2 = Instance.fromExisting(child)
			instance2.BrickColor = BrickColor.Yellow()
			instance2.Transparency = 0.2
			instance2.Parent = instance
			TweenService:Create(instance2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = instance2.Size + createVector(1, 1, 1),
				Transparency = 1
			}):Play()
			task.delay(0.2, function()
				instance2:Destroy()
			end)
		end
	end

	local v2 = false

	for k, v3 in pairs(blocks2) do
		local v4 = not (#blocks2 > 2) and 0 or k / #blocks2
		local v5 = v3
		task.delay(v4, function()
			local transform = v5.transform
			local cframe = CFrame.new(v5.transform.X / 2, v5.transform.Y / 2, (1 - v4) * 30)
			local v7 = CFrame.new(0, size.Y / 2, 0) * CFrame.new(
				math.random(-10, 10),
				math.random(3, 8),
				math.random(5)
			) * CFrame.Angles(0, 0, math.random() * 7)
			local scale = v5.instance:GetScale()
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0
			TweenService:Create(numberValue, TweenInfo.new(0.375, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
				Value = 1
			}):Play()
			local valueChangedConnection = nil
			local valueChangedConnection2 = nil
			valueChangedConnection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
				local value = numberValue.Value
				local lerped = v7:Lerp(cframe, value):Lerp(transform, value)
				v5.instance:PivotTo(cFrame * lerped)

				if value == 1 then
					valueChangedConnection:Disconnect()
					numberValue:Destroy()
				end
			end)
			valueChangedConnection2 = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
				local v8 = math.clamp(numberValue.Value * 7.5, 0, 1)
				v5.instance:ScaleTo(v8 * scale)

				if v8 == 1 then
					valueChangedConnection2:Disconnect()
				end
			end)
			task.delay(0.35, function()
				if not v2 then
					burstBlock(v5.instance)
				end
			end)

			if v5.instance then
				v5.instance:ScaleTo(0.1)
				v5.instance:PivotTo(cFrame * v7)
				v5.instance.Parent = data.model
			end
		end)
	end

	task.delay(1.5, function()
		v2 = true

		for _, collider2 in pairs(data.colliders) do
			local instance = Instance.fromExisting(collider2)
			instance.BrickColor = BrickColor.Yellow()
			instance.Transparency = 0.2
			instance.Parent = data.model
			TweenService:Create(instance, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = instance.Size + createVector(1.5, 1.5, 1.5),
				Transparency = 1
			}):Play()
			task.delay(0.6, function()
				instance:Destroy()
			end)
		end
	end)
	task.delay(2, function()
		data.model:SetAttribute("IsAnimatingIn", nil)
	end)
end

function Structure.getModel(p)
	return p.model
end

return Structure