local module = require("../mod/utility")
local ObjectCache = {}
ObjectCache.__index = ObjectCache

local function reconcile(p, items)
	for k, item in items do
		if p[k] == nil then
			p[k] = item
		end
	end

	return p
end

local v = table.create(10000)
local v2 = table.create(10000)
local v3 = false
local thread = coroutine.create(function()
	while true do
		workspace:BulkMoveTo(v, v2, Enum.BulkMoveMode.FireCFrameChanged)
		table.clear(v)
		table.clear(v2)
		v3 = false
		coroutine.yield()
	end
end)

function ObjectCache.new(part, parent, options)
	local object = setmetatable({}, ObjectCache)
	object.ref = part
	object.parent = parent
	object.amount = 0
	object.restore_amount = 0
	local params = options or {}

	for k, v5 in {
		size = 100,
		excess_lifetime = 30
	} do
		if params[k] == nil then
			params[k] = v5
		end
	end

	object.params = params
	object.scope = { part, parent }
	object.unused = table.create(object.params.size)
	object.item_map = {}
	object.part_mode = part:IsA("BasePart")

	for _ = 1, object.params.size do
		object:_add()
	end

	table.insert(object.scope, task.spawn(function()
		while task.wait(15) do
			if object.restore_amount > 0 then
				for _ = 1, object.restore_amount do
					object:_add()
					object.restore_amount -= 1
				end
			end

			if object.amount <= object.params.size then
				continue
			end

			local count = 0

			for i = 1, #object.unused do
				if object.amount <= object.params.size then
					break
				end

				local v5 = i - count
				local v6 = object.unused[v5]

				if v6.dependents ~= 0 or os.clock() - v6.added > object.params.excess_lifetime then
					continue
				end

				v6:destroy()
				table.remove(object.unused, v5)
				object.item_map[v6.key] = nil
				object.amount -= 1
				count += 1
			end
		end
	end))
	return object
end

function ObjectCache:_add(p, flag: boolean?)
	local clone = self.ref:Clone()
	clone.Archivable = false
	clone.Parent = self.parent
	local v4 = {
		key = p,
		value = clone,
		added = os.clock(),
		dependents = 1
	}
	local flag2 = false

	function v4:destroy()
		flag2 = true
		clone:Destroy()
	end

	self.amount += 1
	clone.Destroying:Connect(function()
		if flag2 then
			return
		end

		local index = table.find(self.unused, v4)

		if index then
			table.remove(self.unused, index)
		end

		if v4.key then
			self.item_map[v4.key] = nil
		end

		self.amount -= 1
		self.restore_amount += 1
	end)

	if p then
		self.item_map[p] = v4
	end

	if not flag then
		table.insert(self.unused, v4)
	end

	return v4
end

function ObjectCache:has(p2)
	if self.item_map[p2] then
		return true
	end

	return false
end

function ObjectCache:peek(p2)
	return self.item_map[p2]
end

function ObjectCache:get(p)
	if self:has(p) then
		local v4 = self:peek(p)

		if v4 then
			v4.dependents += 1
		end

		return v4.value
	else
		local v4 = table.remove(self.unused)

		if v4 then
			v4.key = p
			v4.added = os.clock()
			self.item_map[p] = v4
		else
			v4 = self:_add(p, true)
		end

		if self.part_mode then
			return (setmetatable({
				_getReal = function()
					return v4.value
				end
			}, {
				__newindex = function(_, p2, p3)
					if p2 == "CFrame" then
						table.insert(v, v4.value)
						table.insert(v2, p3)

						if not v3 then
							v3 = true
							task.defer(thread)
						end
					else
						v4.value[p2] = p3
					end
				end,
				__index = function(_, p2)
					local v5 = v4.value[p2]

					if typeof(v5) == "function" then
						return function(_, ...)
							return v5(v4.value, ...)
						end
					end

					return v5
				end
			}))
		end

		return v4.value
	end
end

function ObjectCache.free(data, p)
	local v4 = data.item_map[p]

	if not v4 then
		return
	end

	v4.dependents = math.max(v4.dependents - 1, 0)

	if v4.dependents == 0 then
		v4.added = os.clock()

		if data.params.on_free then
			data.params.on_free(v4)
		end

		table.insert(data.unused, v4)
	end
end

function ObjectCache:destroy()
	module.cleanupScope(self.scope)

	for _, v4 in self.item_map do
		v4.value:Destroy()
	end

	table.clear(self.unused)
	table.clear(self.item_map)
end

return ObjectCache