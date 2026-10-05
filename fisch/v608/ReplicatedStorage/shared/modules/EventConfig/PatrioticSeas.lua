local ReplicatedStorage = game:GetService("ReplicatedStorage")
local locations = require(ReplicatedStorage.shared.modules.library.locations)
local patrioticSeas = locations["Patriotic Seas"]
return {
	StartsAt = assert(patrioticSeas and patrioticSeas.StartTime, "Patriotic Seas locations entry needs a StartTime"),
	ExpiresAt = assert(patrioticSeas and patrioticSeas.EndTime, "Patriotic Seas locations entry needs an EndTime"),
	IsActive = function(p)
		return workspace:GetServerTimeNow() < p.ExpiresAt.UnixTimestamp
	end
}