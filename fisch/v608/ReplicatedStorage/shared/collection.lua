local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local luauSignal = require(ReplicatedStorage.packages.luauSignal)

local function collection(tag: string)
	local added = luauSignal()
	local removed = luauSignal()
	local tagged = CollectionService:GetTagged(tag)
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(p)
		added:fire(p)
	end)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(p)
		removed:fire(p)
	end)
	return {
		added = added,
		removed = removed,
		members = tagged
	}
end

return {
	WindShake_Sphere = collection("WindShake_Sphere"),
	WindShake_Box = collection("WindShake_Box"),
	WeatherExposedSurface = collection("WeatherExposedSurface")
}