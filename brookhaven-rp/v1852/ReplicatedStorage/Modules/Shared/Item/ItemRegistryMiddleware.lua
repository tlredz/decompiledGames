local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Item.Item)
local AdReleaseMiddleware = require(ReplicatedStorage.Modules.Shared.Item.Middleware.AdReleaseMiddleware)
local CategoryItemMiddleware = require(ReplicatedStorage.Modules.Shared.Item.Middleware.CategoryItemMiddleware)
local FilterableItemMiddleware = require(ReplicatedStorage.Modules.Shared.Item.Middleware.FilterableItemMiddleware)
local VehicleMiddleware = require(ReplicatedStorage.Modules.Shared.Item.Middleware.VehicleMiddleware)
local HouseMiddleware = require(ReplicatedStorage.Modules.Shared.Item.Middleware.HouseMiddleware)
local t = require(ReplicatedStorage.Packages.t)
local ItemRegistryMiddleware = {
	_Middlewares = {}
}

function ItemRegistryMiddleware.FrameworkInit()
	ItemRegistryMiddleware._Middlewares = {
		FilterableItemMiddleware,
		CategoryItemMiddleware,
		VehicleMiddleware,
		AdReleaseMiddleware,
		HouseMiddleware
	}
end

function ItemRegistryMiddleware.FrameworkStart() end

function ItemRegistryMiddleware:ApplyMiddleware(p2)
	local middlewares = self.Middlewares
	assert(t.optional(t.table)(middlewares))

	if middlewares == nil then
		return p2
	end

	self.Middlewares = nil
	local v = {}

	for _, middleware in middlewares do
		v[middleware] = true
	end

	for _, _Middleware in ItemRegistryMiddleware._Middlewares do
		if v[_Middleware.Name] ~= true then
			continue
		end

		v[_Middleware.Name] = nil
		local v2 = {}

		for k, argument in _Middleware.Arguments do
			v2[k] = self[argument]
			self[argument] = nil
		end

		p2 = _Middleware.Apply(p2, table.unpack(v2, 1, #_Middleware.Arguments))
	end

	for k, _ in v do
		error("unknown middleware " .. k)
	end

	return p2
end

return ItemRegistryMiddleware