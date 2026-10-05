local ServerStorage = game:GetService("ServerStorage")
local Analytics = require(ServerStorage.SAM.Services.Reporting.Analytics)
return function(p, instance, p2: string, value: number?, p3)
	if p == nil or instance == nil then
		return false, "No player"
	end

	local spins

	if p3 ~= nil then
		spins = tonumber(p3.Spins) or nil
	end

	if spins == nil or spins <= 0 then
		return false, "Listing has no Spins"
	end

	local spinning = instance:FindFirstChild("Spinning")
	local spins2

	if spinning ~= nil then
		spins2 = spinning:FindFirstChild("Spins") or nil
	end

	if spins2 == nil then
		return false, "No Spins counter"
	end

	local v = spins * math.max(math.floor(value or 1), 1)
	spins2.Value += v
	Analytics.Economy(p, "Spins", "Source", v, "RobuxPurchase", p2)
	return true
end