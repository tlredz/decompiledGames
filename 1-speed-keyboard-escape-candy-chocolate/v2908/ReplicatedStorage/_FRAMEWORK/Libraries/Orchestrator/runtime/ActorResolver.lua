local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
require(script.Parent.Parent.types.Save)
local ActorResolver = {}
ActorResolver.__index = ActorResolver

function ActorResolver.new(root, actors, onResolved, callback2)
	return (setmetatable({
		_root = root,
		_actors = actors,
		_onResolved = onResolved,
		_onUnresolved = callback2,
		_janitor = Janitor.new(),
		_running = false,
		_resolvedById = {}
	}, ActorResolver))
end

function ActorResolver:_resolvePath(items)
	local _root = self._root

	for _, childName in items do
		if _root ~= nil then
			_root = _root:FindFirstChild(childName)
		end
	end

	return _root
end

function ActorResolver:_setResolved(p, p2)
	local v = self._resolvedById[p.id]

	if v ~= p2 then
		if v ~= nil then
			self._resolvedById[p.id] = nil
			self._onUnresolved(p.id, v)
		end

		if p2 ~= nil then
			self._resolvedById[p.id] = p2
			self._onResolved(p.id, p2)
		end
	end
end

function ActorResolver:_resolveAll()
	if self._running then
		for _, _actor in self._actors do
			self:_setResolved(_actor, self:_resolvePath(_actor.path))
		end
	end
end

function ActorResolver:start()
	if not self._running then
		self._running = true
		self._janitor:Add(self._root.DescendantAdded:Connect(function()
			self:_resolveAll()
		end), "Disconnect")
		self._janitor:Add(self._root.DescendantRemoving:Connect(function(descendant)
			for _, _actor in self._actors do
				local v = self._resolvedById[_actor.id]

				if v ~= nil and (descendant == v or descendant:IsAncestorOf(v)) then
					self:_setResolved(_actor, nil)
				end
			end
		end), "Disconnect")
		self:_resolveAll()
	end
end

function ActorResolver:stop()
	if self._running then
		self._running = false
		self._janitor:Cleanup()

		for _, _actor in self._actors do
			self:_setResolved(_actor, nil)
		end
	end
end

function ActorResolver:get(p2: string)
	return self._resolvedById[p2]
end

return ActorResolver