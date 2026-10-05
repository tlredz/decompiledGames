local DanceSpawner = {}
DanceSpawner.__index = DanceSpawner

function DanceSpawner.new(options)
	local v = options or {}
	local self = setmetatable({}, DanceSpawner)
	self._spinSpeed = v.spinSpeed or 10
	self._jumpFreq = v.jumpFreq or 5
	self._jumpHeight = v.jumpHeight or 2
	self._items = {}
	return self
end

function DanceSpawner:setup(maid, instance, instance2)
	self._items = {}

	if not instance then
		return
	end

	for _, model in instance:GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		local model2

		if instance2 then
			model2 = maid:Add(instance2:Clone())
			model2:PivotTo(model:GetPivot())
		else
			model2 = maid:Add(model:Clone())
		end

		model2.Parent = workspace
		table.insert(self._items, {
			model = model2,
			baseCFrame = model:GetPivot(),
			phaseOffset = math.random() * 3.141592653589793 * 2
		})
	end
end

function DanceSpawner:setupAtPositions(maid, items, list)
	self._items = {}

	if not items or not list or #list == 0 then
		return
	end

	for _, cframe in items do
		local model = maid:Add(list[math.random(1, #list)]:Clone())
		model:PivotTo(cframe)
		model.Parent = workspace
		table.insert(self._items, {
			model = model,
			baseCFrame = cframe,
			phaseOffset = math.random() * 3.141592653589793 * 2
		})
	end
end

function DanceSpawner:update(p)
	for _, _item in self._items do
		if not (_item.model and _item.model.Parent) then
			continue
		end

		local v = math.abs((math.sin((p + _item.phaseOffset) * self._jumpFreq))) * self._jumpHeight
		local v2 = p * self._spinSpeed + _item.phaseOffset
		_item.model:PivotTo(_item.baseCFrame * CFrame.new(0, v, 0) * CFrame.Angles(0, v2, 0))
	end
end

return DanceSpawner