local ServerFilter = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
require(ReplicatedStorage.Modules.Types)
ServerFilter.Countries = {}
ServerFilter.Tags = {}
ServerFilter.Count = 0
ServerFilter.Updated = FastSignal.new()

local function anyMatches(items, items2)
	if not next(items) then
		return true
	end

	for k in next, items2, nil do
		if items[k] then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCount()
	local count = 0

	for _ in next, ServerFilter.Countries, nil do
		count += 1
	end

	for _ in next, ServerFilter.Tags, nil do
		count += 1
	end

	ServerFilter.Count = count
end

function ServerFilter.Set(_, p)
	if p.Countries then
		ServerFilter.Countries = p.Countries
	end

	if p.Tags then
		ServerFilter.Tags = p.Tags
	end

	updateCount() -- equivalent call inferred; original call site unknown
	ServerFilter.Updated:Fire()
	TeleportService:SetTeleportSetting("ServerFilterCountries", ServerFilter.Countries)
	TeleportService:SetTeleportSetting("ServerFilterTags", ServerFilter.Tags)
end

function ServerFilter.DoesServerPassFilter(_, p)
	local countries = ServerFilter.Countries
	local countries2 = p.Countries or {}
	local v

	if next(countries) then
		local flag = true

		for k in next, countries2, nil do
			if not countries[k] then
				continue
			end

			v = true
			flag = false
			break
		end

		if flag then
			v = false
		end
	else
		v = true
	end

	if not v then
		return v
	end

	local tags = ServerFilter.Tags
	local tags2 = p.Tags or {}

	if not next(tags) then
		return true
	end

	for k in next, tags2, nil do
		if tags[k] then
			return true
		end
	end

	v = false
	return false
end

function ServerFilter.GetNumberOfMatches(_, p)
	local total = 0

	if p.Countries then
		for k in ServerFilter.Countries do
			if p.Countries[k] then
				total += p.Countries[k]
			end
		end
	end

	if p.Tags then
		for k in ServerFilter.Tags do
			if p.Tags[k] then
				total += p.Tags[k]
			end
		end
	end

	return total
end

function ServerFilter.IsFiltering(_)
	return ServerFilter.Count > 0
end

ServerFilter.Countries = TeleportService:GetTeleportSetting("ServerFilterCountries") or {}
ServerFilter.Tags = TeleportService:GetTeleportSetting("ServerFilterTags") or {}
updateCount() -- equivalent call inferred; original call site unknown
return ServerFilter