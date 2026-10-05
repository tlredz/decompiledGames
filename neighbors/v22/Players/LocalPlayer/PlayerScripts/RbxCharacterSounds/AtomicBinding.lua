local function parsePath(item)
	local v = string.split(item, "/")

	for i = #v, 1, -1 do
		if v[i] == "" then
			table.remove(v, i)
		end
	end

	return v
end

local function isManifestResolved(items, p)
	local count = 0

	for _ in pairs(items) do
		count += 1
	end

	assert(count <= p, count)
	return count == p
end

local unbindNodeDescend

unbindNodeDescend = function(state, p)
	if state.instance == nil then
		return
	end

	state.instance = nil
	local connections = state.connections

	if connections then
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)
	end

	if p and state.alias then
		p[state.alias] = nil
	end

	local children = state.children

	if children then
		for _, v in pairs(children) do
			unbindNodeDescend(v, p)
		end
	end
end

local AtomicBinding = {}
AtomicBinding.__index = AtomicBinding

function AtomicBinding.new(items, boundFn)
	local parsedManifest = {}
	local manifestSizeTarget = 1

	for k, item in pairs(items) do
		parsedManifest[k] = parsePath(item)
		manifestSizeTarget += 1
	end

	return (setmetatable({
		_boundFn = boundFn,
		_parsedManifest = parsedManifest,
		_manifestSizeTarget = manifestSizeTarget,
		_dtorMap = {},
		_connections = {},
		_rootInstToRootNode = {},
		_rootInstToManifest = {}
	}, AtomicBinding))
end

function AtomicBinding:_startBoundFn(p2, p3)
	local _boundFn = self._boundFn
	local _dtorMap = self._dtorMap
	local v = _dtorMap[p2]

	if v then
		v()
		_dtorMap[p2] = nil
	end

	local v2 = _boundFn(p3)

	if v2 then
		_dtorMap[p2] = v2
	end
end

function AtomicBinding:_stopBoundFn(p2)
	local _dtorMap = self._dtorMap
	local v = _dtorMap[p2]

	if v then
		v()
		_dtorMap[p2] = nil
	end
end

function AtomicBinding:bindRoot(instance2)
	debug.profilebegin("AtomicBinding:BindRoot")
	local _parsedManifest = self._parsedManifest
	local _rootInstToRootNode = self._rootInstToRootNode
	local _rootInstToManifest = self._rootInstToManifest
	local _manifestSizeTarget = self._manifestSizeTarget
	assert(_rootInstToManifest[instance2] == nil)
	local v = {}
	_rootInstToManifest[instance2] = v
	debug.profilebegin("BuildTree")
	local v2 = {
		alias = "root",
		instance = instance2
	}

	if next(_parsedManifest) then
		v2.children = {}
		v2.connections = {}
	end

	_rootInstToRootNode[instance2] = v2

	for k, list in pairs(_parsedManifest) do
		local v3 = v2

		for i, v4 in ipairs(list) do
			local v5 = i == #list
			local v6 = v3.children[v4] or {}

			if v5 then
				if v6.alias ~= nil then
					error("Multiple aliases assigned to one instance")
				end

				v6.alias = k
			else
				v6.children = v6.children or {}
				v6.connections = v6.connections or {}
			end

			v3.children[v4] = v6
			v3 = v6
		end
	end

	debug.profileend()
	local processNode

	processNode = function(data)
		local v3 = assert(data.instance)
		local children = data.children
		local alias = data.alias
		local v4 = not children

		if alias then
			v[alias] = v3
		end

		if not v4 then
			local function processAddChild(instance)
				local v5 = children[instance.Name]

				if not v5 or v5.instance ~= nil then
					return
				end

				v5.instance = instance
				processNode(v5)
			end

			local function processDeleteChild(p2)
				local name = p2.Name
				local v5 = children[name]

				if not (v5 and v5.instance == p2) then
					return
				end

				self:_stopBoundFn(instance2)
				unbindNodeDescend(v5, v)
				assert(v5.instance == nil)
				local child = v3:FindFirstChild(name)

				if child then
					local v6 = children[child.Name]

					if v6 then
						if v6.instance ~= nil then
							return
						end

						v6.instance = child
						processNode(v6)
					end
				end
			end

			for _, child in ipairs(v3:GetChildren()) do
				local v5 = children[child.Name]

				if not (v5 and v5.instance == nil) then
					continue
				end

				v5.instance = child
				processNode(v5)
			end

			table.insert(data.connections, v3.ChildAdded:Connect(processAddChild))
			table.insert(data.connections, v3.ChildRemoved:Connect(processDeleteChild))
		end

		if v4 then
			local manifestSizeTarget = _manifestSizeTarget
			local count = 0

			for _ in pairs(v) do
				count += 1
			end

			assert(count <= manifestSizeTarget, count)

			if count == manifestSizeTarget then
				self:_startBoundFn(instance2, v)
			end
		end
	end

	debug.profilebegin("ResolveTree")
	processNode(v2)
	debug.profileend()
	debug.profileend()
end

function AtomicBinding:unbindRoot(p)
	local _rootInstToRootNode = self._rootInstToRootNode
	local _rootInstToManifest = self._rootInstToManifest
	self:_stopBoundFn(p)
	local v = _rootInstToRootNode[p]

	if v then
		unbindNodeDescend(v, (assert(_rootInstToManifest[p])))
		_rootInstToRootNode[p] = nil
	end

	_rootInstToManifest[p] = nil
end

function AtomicBinding:destroy()
	debug.profilebegin("AtomicBinding:destroy")

	for _, v in pairs(self._dtorMap) do
		v:destroy()
	end

	table.clear(self._dtorMap)

	for _, _connection in ipairs(self._connections) do
		_connection:Disconnect()
	end

	table.clear(self._connections)
	local _rootInstToManifest = self._rootInstToManifest

	for k, v in pairs(self._rootInstToRootNode) do
		unbindNodeDescend(v, (assert(_rootInstToManifest[k])))
	end

	table.clear(self._rootInstToManifest)
	table.clear(self._rootInstToRootNode)
	debug.profileend()
end

return AtomicBinding