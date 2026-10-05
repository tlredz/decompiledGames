local CollisionGate = {}
CollisionGate.__index = CollisionGate

function CollisionGate.new()
	return (setmetatable({
		_barriers = {}
	}, CollisionGate))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyPair(char)
	char.charConn:Disconnect()

	for _, constraint in char.constraints do
		constraint:Destroy()
	end
end

local function buildConstraints(instance, instance2)
	local result = {}

	for _, part in instance2:GetChildren() do
		if not (part:IsA("BasePart") and part.CanCollide) then
			continue
		end

		local noCollisionConstraint = Instance.new("NoCollisionConstraint")
		noCollisionConstraint.Part0 = instance
		noCollisionConstraint.Part1 = part
		noCollisionConstraint.Parent = instance
		table.insert(result, noCollisionConstraint)
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearPair(object, p, p2)
	local _barrier = object._barriers[p]

	if not _barrier then
		return
	end

	local char = _barrier.chars[p2]

	if not char then
		return
	end

	destroyPair(char) -- equivalent call inferred; original call site unknown
	_barrier.chars[p2] = nil

	if next(_barrier.chars) == nil then
		object:Release(p)
	end
end

function CollisionGate:Set(instance, instance2, flag: boolean)
	if not instance2 then
		return
	end

	if flag then
		local _barrier = self._barriers[instance]

		if not _barrier then
			_barrier = {
				conn = instance.Destroying:Connect(function()
					self:Release(instance)
				end),
				chars = {}
			}
			self._barriers[instance] = _barrier
		end

		if _barrier.chars[instance2] then
			return
		end

		_barrier.chars[instance2] = {
			constraints = buildConstraints(instance, instance2),
			charConn = instance2.Destroying:Connect(function()
				clearPair(self, instance, instance2) -- equivalent call inferred; original call site unknown
			end)
		}
	else
		clearPair(self, instance, instance2) -- equivalent call inferred; original call site unknown
	end
end

function CollisionGate:Release(p2)
	local _barrier = self._barriers[p2]

	if not _barrier then
		return
	end

	_barrier.conn:Disconnect()

	for _, char in _barrier.chars do
		destroyPair(char) -- equivalent call inferred; original call site unknown
	end

	self._barriers[p2] = nil
end

function CollisionGate:Destroy()
	for k in self._barriers do
		self:Release(k)
	end
end

return CollisionGate