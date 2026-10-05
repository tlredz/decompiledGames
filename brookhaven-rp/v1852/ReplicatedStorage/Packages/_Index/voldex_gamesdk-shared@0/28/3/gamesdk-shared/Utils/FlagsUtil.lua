local CryptoUtil = require(script.Parent.CryptoUtil)
local FlagsUtil = {
	GLOBAL_ROLLOUT_IDENTIFIER = "__all__"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isPrimitive(p)
	local typeName = typeof(p)
	return typeName == "string" or typeName == "number" or typeName == "boolean"
end

local function warno(...)
	warn("[GameSdk - Flags]", ...)
end

function FlagsUtil.getFlagsPath()
	return "/Flags"
end

function FlagsUtil.getFlagsFromTree(p)
	if type(p) ~= "table" then
		return nil
	end

	if type(p.Flags) == "table" then
		return p.Flags
	end

	for k, v in p do
		if type(k) == "string" and string.upper(k) == string.upper("Flags") and type(v) == "table" then
			return v
		end
	end

	return nil
end

function FlagsUtil.getBucket(p: string, value: string)
	return CryptoUtil.crc32(p .. string.upper(value)) % 100
end

function FlagsUtil.isInRollout(p: number, p2: number)
	return p < p2
end

function FlagsUtil.findFlagDefinition(items, value: string)
	if type(items) ~= "table" then
		return nil
	end

	if items[value] ~= nil then
		return items[value]
	end

	local v = string.upper(value)

	for k, item in items do
		if type(k) == "string" and string.upper(k) == v and type(item) == "table" then
			return item
		end
	end

	return nil
end

function FlagsUtil.parseDefinition(_: string, data)
	if type(data) ~= "table" then
		return nil, "definition must be a table"
	end

	if not isPrimitive(data.value) then
		return nil, "value must be a primitive"
	end

	local v = data.serverRolloutPercentage ~= nil
	local v2 = data.playerRolloutPercentage ~= nil

	if v and v2 then
		return nil, "flag cannot target both servers and players"
	end

	if not (v or v2) then
		return {
			value = data.value
		}, nil
	end

	if data.default == nil then
		return nil, "default must be a primitive when a rollout percentage is set"
	end

	if not isPrimitive(data.default) then
		return nil, "default must be a primitive when a rollout percentage is set"
	end

	local serverRolloutPercentage

	if v then
		serverRolloutPercentage = data.serverRolloutPercentage
	else
		serverRolloutPercentage = data.playerRolloutPercentage
	end

	if type(serverRolloutPercentage) == "number" and not (serverRolloutPercentage < 0 or serverRolloutPercentage > 100) then
		return {
			default = data.default,
			value = data.value,
			rolloutPercentage = serverRolloutPercentage,
			rolloutScope = v and "server" or "player"
		}, nil
	end

	return nil, "rollout percentage must be a number between 0 and 100"
end

function FlagsUtil.isFullRollout(p)
	return p.rolloutPercentage == nil
end

function FlagsUtil.getResolvedFlagCacheKey(value: string, p: string)
	return string.upper(value) .. ":" .. p
end

function FlagsUtil.resolveParsed(p: string, data, p2: string)
	if FlagsUtil.isFullRollout(data) then
		return data.value
	end

	if typeof(data.default) ~= typeof(data.value) then
		warno("Default type for flag", p, "does not match remote value type; using default")
		return data.default
	end

	local bucket = FlagsUtil.getBucket(p2, p)

	if FlagsUtil.isInRollout(bucket, data.rolloutPercentage) then
		return data.value
	end

	return data.default
end

function FlagsUtil.resolve(p: string, p2, p3: string)
	local definition, v = FlagsUtil.parseDefinition(p, p2)

	if definition ~= nil then
		return FlagsUtil.resolveParsed(p, definition, p3)
	end

	warno("Invalid flag definition for", p .. ":", v)
	return nil
end

return FlagsUtil