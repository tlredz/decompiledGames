local Cache = {}
local RunService = game:GetService("RunService")
local v = {}
local Net = require(script.Parent.Net)
local remoteFunction = Net:RemoteFunction("RequestCache")
local class = {}
class.__index = class

function class.new(p)
	local self = setmetatable({}, class)
	self.cache = {}
	self.key = p
	return self
end

function class.Set(p, p2, p3)
	p.cache[p2] = p3
	return p
end

function class.Get(p, p2)
	return p.cache[p2]
end

function class:GetRaw()
	return self.cache
end

function class.Increase(p, p2, value: number?)
	p.cache[p2] = (p.cache[p2] or 0) + (value or 1)
	return p
end

function class:Destroy()
	setmetatable(self, nil)

	for k, _ in self do
		self[k] = nil
	end
end

local function ReadPath(raw, value: string)
	if not value or typeof(value) ~= "string" then
		return raw
	end

	local v2 = string.split(value, ".")

	for i = 1, #v2 do
		raw = raw[v2[i]]

		if not (raw and typeof(raw) == "table") then
			return raw
		end
	end

	return raw
end

function Cache.Create(_, p)
	local v2 = v[p]

	if v2 then
		return v2
	end

	v[p] = class.new(p)
	return v[p]
end

function Cache.Get(_, p)
	return v[p]
end

function Cache:Destroy(p)
	if v[p] then
		v[p]:Destroy()
		v[p] = nil
	end
end

function Cache.RequestCache(_, p, p2: string?)
	if not RunService:IsServer() then
		return remoteFunction:InvokeServer(p)
	end

	local v2 = v[p]

	if v2 then
		return (ReadPath(v2:GetRaw(), p2))
	end
end

if RunService:IsServer() then
	remoteFunction.OnServerInvoke = function(p, p2: string?)
		local v2 = v[p]

		if v2 then
			return (ReadPath(v2:GetRaw(), p2))
		end

		return nil
	end
end

return Cache