local GeometryProvider = {}
GeometryProvider.__index = GeometryProvider

function GeometryProvider.new(replicatedStorage)
	local self = setmetatable({}, GeometryProvider)
	self.replicatedStorage = replicatedStorage
	self.poisonSpikeFootprintCache = nil
	self.bigSpikeFootprintCache = nil
	self.frostTrailFootprintCache = nil
	self.alchemistGasTrailFootprintCache = nil
	self.hookChainRestLengthsCache = nil
	self.ballCollisionBoxes = {}
	self.effectCollisionBoxes = {}
	return self
end

function GeometryProvider:_getTemplateCollisionBox(instance, childName: string)
	local model = instance:FindFirstChild(childName)
	assert(model and model:IsA("Model"), string.format("素材模型 '%s' 缺失：%s", childName, instance:GetFullName()))
	local part = model:FindFirstChild("碰撞箱")
	assert(part and part:IsA("BasePart"), string.format("素材模型 '%s' 缺少碰撞箱", model:GetFullName()))
	return part
end

function GeometryProvider:getPoisonSpikeFootprint()
	if self.poisonSpikeFootprintCache then
		return self.poisonSpikeFootprintCache.X, self.poisonSpikeFootprintCache.Y
	end

	local _getTemplateCollisionBox = self:_getTemplateCollisionBox(
		self.replicatedStorage:WaitForChild("美术素材"):WaitForChild("模型效果"),
		"毒刺"
	)
	local v = math.max(0.1, _getTemplateCollisionBox.Size.Z)
	local v2 = math.max(0.1, _getTemplateCollisionBox.Size.X)
	self.poisonSpikeFootprintCache = Vector2.new(v, v2)
	return v, v2
end

function GeometryProvider:getBigSpikeFootprint()
	if self.bigSpikeFootprintCache then
		return self.bigSpikeFootprintCache.X, self.bigSpikeFootprintCache.Y
	end

	local _getTemplateCollisionBox = self:_getTemplateCollisionBox(
		self.replicatedStorage:WaitForChild("美术素材"):WaitForChild("模型效果"),
		"大刺"
	)
	local v = math.max(0.1, _getTemplateCollisionBox.Size.Z)
	local v2 = math.max(0.1, _getTemplateCollisionBox.Size.X)
	self.bigSpikeFootprintCache = Vector2.new(v, v2)
	return v, v2
end

function GeometryProvider:getFrostTrailFootprint()
	if self.frostTrailFootprintCache then
		return self.frostTrailFootprintCache.X, self.frostTrailFootprintCache.Y
	end

	local _getTemplateCollisionBox = self:_getTemplateCollisionBox(
		self.replicatedStorage:WaitForChild("美术素材"):WaitForChild("模型效果"),
		"冰霜尾迹"
	)
	local v = math.max(0.1, _getTemplateCollisionBox.Size.Z)
	local v2 = math.max(0.1, _getTemplateCollisionBox.Size.X)
	self.frostTrailFootprintCache = Vector2.new(v, v2)
	return v, v2
end

function GeometryProvider:getAlchemistGasTrailFootprint()
	if self.alchemistGasTrailFootprintCache then
		return self.alchemistGasTrailFootprintCache.X, self.alchemistGasTrailFootprintCache.Y
	end

	local _getTemplateCollisionBox = self:_getTemplateCollisionBox(
		self.replicatedStorage:WaitForChild("美术素材"):WaitForChild("模型效果"),
		"毒气尾迹"
	)
	local v = math.max(0.1, _getTemplateCollisionBox.Size.Z)
	local v2 = math.max(0.1, _getTemplateCollisionBox.Size.X)
	self.alchemistGasTrailFootprintCache = Vector2.new(v, v2)
	return v, v2
end

local function discoverHookChainSegmentCount(instance)
	local v = {}
	local v2 = 0

	for _, part in ipairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local match = part.Name:match("^连接(%d+)$")

		if not match then
			continue
		end

		local v3 = tonumber(match)
		v[v3] = true
		v2 = math.max(v2, v3)
	end

	assert(v2 > 0, string.format("钩爪素材模型 '%s' 找不到任何 连接N 部件", instance:GetFullName()))

	for i = 1, v2 do
		assert(v[i], string.format("钩爪素材模型 '%s' 缺少连接%d（编号必须从 1 连续到 %d）", instance:GetFullName(), i, v2))
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHookChainMarkerWorldPosition(instance)
	local attachment = instance:FindFirstChild("朝向标记")
	assert(attachment and attachment:IsA("Attachment"), string.format("钩爪链条部件 '%s' 缺少朝向标记", instance:GetFullName()))
	return attachment.WorldPosition
end

function GeometryProvider:getHookChainRestLengths()
	if self.hookChainRestLengthsCache then
		return self.hookChainRestLengthsCache
	end

	local v = self.replicatedStorage:WaitForChild("美术素材"):WaitForChild("模型效果"):WaitForChild("钩爪")
	local v2 = discoverHookChainSegmentCount(v)
	local v3 = table.create(v2 + 1)

	for i = 1, v2 do
		local child = v:FindFirstChild(string.format("连接%d", i))
		assert(child, string.format("钩爪素材模型缺少连接%d", i))
		v3[i] = getHookChainMarkerWorldPosition(child)
	end

	local firstChild = v:FindFirstChild("碰撞箱")
	assert(firstChild, "钩爪素材模型缺少碰撞箱")
	local v4 = v2 + 1
	v3[v4] = getHookChainMarkerWorldPosition(firstChild)
	local magnitudes = table.create(v2)

	for i = 1, v2 do
		magnitudes[i] = (v3[i + 1] - v3[i]).Magnitude
	end

	self.hookChainRestLengthsCache = magnitudes
	return magnitudes
end

function GeometryProvider:getBallCollisionBox(p: string)
	local ballCollisionBox = self.ballCollisionBoxes[p]

	if ballCollisionBox then
		return ballCollisionBox
	end

	local _getTemplateCollisionBox = self:_getTemplateCollisionBox(
		self.replicatedStorage:WaitForChild("美术素材"):WaitForChild("球体模型"),
		p
	)
	self.ballCollisionBoxes[p] = _getTemplateCollisionBox
	return _getTemplateCollisionBox
end

function GeometryProvider:getEffectCollisionBox(p: string)
	local effectCollisionBox = self.effectCollisionBoxes[p]

	if effectCollisionBox then
		return effectCollisionBox
	end

	local _getTemplateCollisionBox = self:_getTemplateCollisionBox(
		self.replicatedStorage:WaitForChild("美术素材"):WaitForChild("模型效果"),
		p
	)
	self.effectCollisionBoxes[p] = _getTemplateCollisionBox
	return _getTemplateCollisionBox
end

local function collectCollisionBoxSizes(instance)
	local sizesByName = {}

	for _, model in ipairs(instance:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		local part = model:FindFirstChild("碰撞箱")

		if part and part:IsA("BasePart") then
			sizesByName[model.Name] = part.Size
		end
	end

	return sizesByName
end

function GeometryProvider.captureSnapshot(instance)
	local v = instance:WaitForChild("美术素材")
	local v2 = v:WaitForChild("球体模型")
	local v3 = v:WaitForChild("模型效果")
	local v4 = GeometryProvider.new(instance)
	local poisonSpikeFootprint, v5 = v4:getPoisonSpikeFootprint()
	local bigSpikeFootprint, v6 = v4:getBigSpikeFootprint()
	local frostTrailFootprint, v7 = v4:getFrostTrailFootprint()
	local alchemistGasTrailFootprint, v8 = v4:getAlchemistGasTrailFootprint()
	return {
		ballCollisionSizes = collectCollisionBoxSizes(v2),
		effectCollisionSizes = collectCollisionBoxSizes(v3),
		poisonSpikeFootprint = Vector2.new(poisonSpikeFootprint, v5),
		bigSpikeFootprint = Vector2.new(bigSpikeFootprint, v6),
		frostTrailFootprint = Vector2.new(frostTrailFootprint, v7),
		alchemistGasTrailFootprint = Vector2.new(alchemistGasTrailFootprint, v8),
		hookChainRestLengths = table.clone(v4:getHookChainRestLengths())
	}
end

local class = {}
class.__index = class

function GeometryProvider.fromSnapshot(snapshot)
	local self = setmetatable({}, class)
	self.snapshot = snapshot
	self.ballStubs = {}
	self.effectStubs = {}
	return self
end

local function stubFor(p, p2, p3: string, p4: string)
	local v = p[p3]

	if v then
		return v
	end

	local size = p2[p3]
	assert(size ~= nil, string.format("几何快照缺少%s素材 '%s' 的碰撞箱", p4, p3))
	local v3 = {
		Size = size
	}
	p[p3] = v3
	return v3
end

function class.getBallCollisionBox(p, p2: string)
	local ballStubs = p.ballStubs
	local ballCollisionSizes = p.snapshot.ballCollisionSizes
	local ballStub = ballStubs[p2]

	if ballStub then
		return ballStub
	end

	local ballCollisionSiz = ballCollisionSizes[p2]
	assert(ballCollisionSiz ~= nil, string.format("几何快照缺少%s素材 '%s' 的碰撞箱", "球体", p2))
	local v = {
		Size = ballCollisionSiz
	}
	ballStubs[p2] = v
	return v
end

function class.getEffectCollisionBox(p, p2: string)
	local effectStubs = p.effectStubs
	local effectCollisionSizes = p.snapshot.effectCollisionSizes
	local effectStub = effectStubs[p2]

	if effectStub then
		return effectStub
	end

	local effectCollisionSiz = effectCollisionSizes[p2]
	assert(effectCollisionSiz ~= nil, string.format("几何快照缺少%s素材 '%s' 的碰撞箱", "特效", p2))
	local v = {
		Size = effectCollisionSiz
	}
	effectStubs[p2] = v
	return v
end

function class:getPoisonSpikeFootprint()
	local poisonSpikeFootprint = self.snapshot.poisonSpikeFootprint
	return poisonSpikeFootprint.X, poisonSpikeFootprint.Y
end

function class:getBigSpikeFootprint()
	local bigSpikeFootprint = self.snapshot.bigSpikeFootprint
	return bigSpikeFootprint.X, bigSpikeFootprint.Y
end

function class:getFrostTrailFootprint()
	local frostTrailFootprint = self.snapshot.frostTrailFootprint
	return frostTrailFootprint.X, frostTrailFootprint.Y
end

function class:getAlchemistGasTrailFootprint()
	local alchemistGasTrailFootprint = self.snapshot.alchemistGasTrailFootprint
	return alchemistGasTrailFootprint.X, alchemistGasTrailFootprint.Y
end

function class:getHookChainRestLengths()
	return self.snapshot.hookChainRestLengths
end

return GeometryProvider