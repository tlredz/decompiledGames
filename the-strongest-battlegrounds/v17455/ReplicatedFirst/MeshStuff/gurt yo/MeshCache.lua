local ObjectCache = require(script.ObjectCache)

local function noCache()
	return false
end

local v = {}

function v.new(objectCache)
	return (setmetatable({
		Subscribers = 1,
		ObjectCache = objectCache,
		Destroyed = nil
	}, {
		__index = v
	}))
end

function v:Subscribe()
	self.Subscribers += 1
end

function v:Unsubscribe()
	local subscribers = self.Subscribers - 1

	if subscribers <= 0 then
		self:_Destroy()
	end

	self.Subscribers = subscribers
end

function v:_Destroy()
	self.Destroyed()
	self.ObjectCache:Destroy()
end

local v2 = {
	Stored = {},
	NewCacheObject = function(self, p2)
		local v3 = v.new(p2)

		function v3.Destroyed()
			self.Stored[p2._Template] = nil
		end

		self.Stored[p2._Template] = v3
	end,
	SubscribeToCache = function(self, p2)
		local v3 = self.Stored[p2]

		if not v3 then
			return
		end

		v3:Subscribe()
		return v3
	end,
	UnsubscribeToCache = function(self, p2)
		local v3 = self.Stored[p2]

		if not v3 then
			return
		end

		v3:Unsubscribe()
		return v3
	end
}
local MeshCache = {}

function MeshCache.new(model, p: number?, p2)
	if v2.Stored[model] then
		return (setmetatable({
			Cache = v2:SubscribeToCache(model).ObjectCache
		}, {
			__index = MeshCache
		}))
	end

	local cache = ObjectCache.new(model, p, p2)
	local object = setmetatable({
		Cache = cache
	}, {
		__index = MeshCache
	})
	v2:NewCacheObject(cache)
	return object
end

function MeshCache:GetPart(cFrame: CFrame?)
	if not self._NoCache then
		return self.Cache:GetPart(cFrame)
	end

	local clone = self._Template:Clone()
	local primaryPart

	if self._IsTemplateModel then
		primaryPart = clone.PrimaryPart
	else
		primaryPart = clone
	end

	if cFrame then
		primaryPart.CFrame = cFrame
	end

	clone.Parent = self._CachesContainer or workspace
	return primaryPart
end

function MeshCache:ReturnPart(parent)
	if self._NoCache then
		if self._IsTemplateModel and parent.Parent and parent.Parent:IsA("Model") then
			parent = parent.Parent
		end

		parent:Destroy()
	elseif not self.Cache:ReturnPart(parent) then
		local n = parent:GetAttribute("n")
		task.delay(8, function()
			if parent:GetAttribute("n") == n then
				self.Cache:_ReleasePart(parent)
			end
		end)
	end
end

function MeshCache:Destroy()
	if self._NoCache then
		return
	end

	v2:UnsubscribeToCache(self.Cache._Template)
end

return MeshCache