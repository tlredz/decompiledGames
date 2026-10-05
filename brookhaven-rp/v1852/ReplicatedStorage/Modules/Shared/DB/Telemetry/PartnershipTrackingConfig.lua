local PartnershipTrackingConfig = {
	remoteConfigDirectory = "Telemetry/PartnershipTracking",
	isLoaded = false,
	cache = nil
}
local v = {
	tool = "tools",
	zone = "zones",
	vehicle = "vehicles",
	ugc = "ugcAssetIds",
	house = "houses",
	minionFollower = "minionFollowers"
}
local v2 = {
	tool = 0,
	zone = 0,
	vehicle = 0,
	ugc = 0,
	house = 0,
	minionFollower = 0
}
v2.tool = {}
v2.zone = {}
v2.vehicle = {}
v2.ugc = {}
v2.house = {}
v2.minionFollower = {}
PartnershipTrackingConfig.middlewares = {
	buildLookups = function(items)
		local v3 = {
			tool = {},
			zone = {},
			vehicle = {},
			ugc = {},
			house = {},
			minionFollower = {}
		}

		for k, item in items do
			if string.sub(k, 1, 2) == "__" then
				continue
			end

			for k2, v4 in v do
				local v5 = item[v4]

				if v5 == nil then
					continue
				end

				for k3, v6 in v5 do
					if v6 ~= true then
						continue
					end

					if k2 == "ugc" then
						local v7 = tonumber(k3)

						if v7 ~= nil then
							v3.ugc[v7] = k
						end
					else
						v3[k2][k3] = k
					end
				end
			end
		end

		v2 = v3
		return items
	end
}

function PartnershipTrackingConfig.GetConfig()
	while not PartnershipTrackingConfig.isLoaded do
		task.wait()
	end

	return PartnershipTrackingConfig.cache
end

function PartnershipTrackingConfig.GetPartnership(p: string, value)
	while not PartnershipTrackingConfig.isLoaded do
		task.wait()
	end

	if p == "ugc" then
		if typeof(value) ~= "number" then
			value = tonumber(value)
		end

		if value == nil then
			return nil
		end

		return v2.ugc[value]
	elseif typeof(value) == "string" then
		return v2[p][value]
	else
		return nil
	end
end

function PartnershipTrackingConfig.BuildMetricKey(p: string, p2)
	return (`{p}:{p2}`)
end

return PartnershipTrackingConfig