local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
require(ReplicatedStorage.Modules.Shared.Item.Item)
local MiddlewareUtil = require(ReplicatedStorage.Modules.Shared.Item.Middleware.MiddlewareUtil)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	GetAdFeature = function(self)
		if DateTime.now().UnixTimestamp >= self.timestampSeconds then
			return self.super:GetAdFeature()
		end

		return nil
	end
}
return {
	Name = "AdRelease",
	Arguments = { "AdReleaseTimestamp" },
	Apply = function(p, timestampSeconds)
		if not Object.InstanceOf(p, DisplayItem) then
			error("Ad release middleware can only be used on DisplayItems")
		end

		assert(t.integer(timestampSeconds))
		assert(timestampSeconds < 10000000000, "Timestamp is too large, is it in milliseconds?")
		return (MiddlewareUtil.Apply({
			timestampSeconds = timestampSeconds
		}, nil, p, v, "AdReleaseImpl"))
	end
}