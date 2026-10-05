local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local v = Component.new({
	Tag = "PhysicalElevator"
})

function v:Construct()
	self._primaryPart = nil
	self._startY = 0
end

function v:_getHeightOffset(attributeName: string)
	local attribute = self.Instance:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return 0
end

function v:_getMoveStartTime()
	local moveStartTime = self.Instance:GetAttribute("MoveStartTime")

	if typeof(moveStartTime) == "number" then
		return moveStartTime
	end

	return 0
end

function v:_applyPose(p2: number, p3: number)
	local _primaryPart = self._primaryPart

	if _primaryPart == nil then
		return
	end

	local cFrame = _primaryPart.CFrame
	_primaryPart.CFrame = cFrame + Vector3.new(0, p2 - cFrame.Position.Y, 0)
	_primaryPart.AssemblyLinearVelocity = Vector3.new(0, p3, 0)
end

function v:SteppedUpdate(_: number)
	if self._primaryPart == nil then
		return
	end

	local _getHeightOffset = self:_getHeightOffset("FromHeightOffset")
	local _getHeightOffset2 = self:_getHeightOffset("ToHeightOffset")
	local v2 = self._startY + _getHeightOffset
	local v3 = self._startY + _getHeightOffset2
	local v4 = math.abs(v3 - v2)

	if v4 <= 0.05 then
		self:_applyPose(v3, 0)
		return
	end

	local v5 = math.clamp((workspace:GetServerTimeNow() - self:_getMoveStartTime()) * 9.6, 0, v4)
	local v6 = math.sign(v3 - v2)
	local v7 = v2 + v6 * v5

	if v4 <= v5 then
		self:_applyPose(v3, 0)
	else
		self:_applyPose(v7, v6 * 9.6)
	end
end

function v:Start()
	local primaryPart = self.Instance.PrimaryPart

	if primaryPart == nil then
		self.Instance:GetPropertyChangedSignal("PrimaryPart"):Wait()
		primaryPart = self.Instance.PrimaryPart
	end

	assert(primaryPart ~= nil, "PhysicalElevator missing PrimaryPart")
	self._primaryPart = primaryPart
	self._startY = primaryPart.Position.Y
end

function v:Stop()
	if self._primaryPart ~= nil then
		self._primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	end
end

return v