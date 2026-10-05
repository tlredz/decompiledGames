local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parentModule = require(script.Parent.Parent)
local Places = {
	_mapping = nil,
	_initialized = false
}

local function warno(...)
	warn("[GameSdk - Places]", ...)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function erroro(p)
	error("[GameSdk - Places] " .. p)
end

local function _assertInitialized(flag: boolean, p: string)
	if Places._initialized ~= flag then
		erroro(p) -- equivalent call inferred; original call site unknown
	end
end

function Places.Init()
	if Places._initialized ~= false then
		error("[GameSdk - Places] Already initialized")
	end

	Places._remote = ReplicatedStorage:WaitForChild("GameSdkPlaceRemoteFunction", 20)

	if Places._remote == nil then
		error("[GameSdk - Places] Failed to find remote function")
	end

	local configuration = parentModule:GetConfiguration()

	if configuration ~= nil then
		Places._mapping = configuration:GetExperienceMapping()
	end

	if Places._mapping == nil then
		Places._mapping = Places._remote:InvokeServer()
	end

	if Places._mapping == nil then
		error("[GameSdk - Places] No valid mapping found")
	end

	Places._initialized = true
end

function Places.GetName(p: number?)
	if Places._initialized ~= true then
		error("[GameSdk - Places] Tried to get name before module is initialized, call initialize first")
	end

	local v = p or game.PlaceId

	for _, v2 in Places._mapping do
		for k, place in v2.Places do
			if place == v then
				return k
			end
		end
	end

	return nil
end

function Places.GetExperienceType(p: number?)
	if Places._initialized ~= true then
		error("[GameSdk - Places] Tried to get type before module is initialized, call initialize first")
	end

	local v = p or game.PlaceId

	for _, v2 in Places._mapping do
		for _, place in v2.Places do
			if place == v then
				return v2.Type
			end
		end
	end

	return nil
end

function Places.GetExperienceId(p: number?)
	if Places._initialized ~= true then
		error("[GameSdk - Places] Tried to get experience ID before module is initialized, call initialize first")
	end

	local v = p or game.PlaceId

	for k, v2 in Places._mapping do
		for _, place in v2.Places do
			if place == v then
				return (tonumber(k))
			end
		end
	end

	return nil
end

function Places.GetExperiencePlaces(p: number?)
	if Places._initialized ~= true then
		error("[GameSdk - Places] Tried to get experience places before module is initialized, call initialize first")
	end

	if p == nil then
		for _, v in Places._mapping do
			for _, place in v.Places do
				if place == game.PlaceId then
					return v.Places
				end
			end
		end

		return nil
	else
		local v = Places._mapping[tostring(p)]

		if v == nil then
			return nil
		end

		return v.Places
	end
end

function Places.GetPlaceIdFor(p: string, p2: number?)
	local experiencePlaces = Places.GetExperiencePlaces(p2)

	if experiencePlaces == nil then
		return nil
	end

	return experiencePlaces[p]
end

function Places.IsProduction(p: number?)
	local v = p or game.PlaceId
	return Places.GetExperienceType(v) == "Production"
end

function Places.IsQA(p: number?)
	local v = p or game.PlaceId
	return Places.GetExperienceType(v) == "QA"
end

function Places.IsIntegrationTest(p: number?)
	local v = p or game.PlaceId
	return Places.GetExperienceType(v) == "IntegrationTest"
end

return Places