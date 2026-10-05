local HttpService = game:GetService("HttpService")
local Keys = require(game.ReplicatedStorage.UserGenerated.Lang.Keys)
local Asserts = require(game.ReplicatedStorage.UserGenerated.Lang.Asserts)
local JSONEncoder = require(game.ReplicatedStorage.UserGenerated.IO.JSONEncoder)
local v = {
	http = 80,
	https = 443
}
local optional = Asserts.Optional(Asserts.Set(Keys(v)))
local string2 = Asserts.String
local optional2 = Asserts.Optional(Asserts.IntegerRange(0, 65535))

local function fn(value: string)
	if type(value) ~= "string" then
		error("string", 2)
	end

	if not utf8.len(value) then
		error("UTF8", 2)
	end

	if #value > 0 and string.byte(value, 1) ~= 47 then
		error("PathPrefix", 2)
	end

	return value
end

local mapped = Asserts.Map(Asserts.String, Asserts.Any)
local table2 = Asserts.Table({
	Protocol = optional,
	Host = string2,
	Port = optional2,
	Path = fn,
	Params = Asserts.Optional(mapped),
	Fragment = Asserts.Optional(Asserts.String)
})
local v2 = {
	AssertProtocol = optional,
	AssertHost = string2,
	AssertPort = optional2,
	AssertPath = fn,
	AssertEncodeParams = mapped,
	AssertParams = table2,
	EncodePath = function(value: string)
		Asserts.String(value)
		return (value:gsub("([^/]+)", function(p)
			return HttpService:UrlEncode(p)
		end))
	end,
	EncodeParams = function(p)
		mapped(p)
		local keys = Keys(p)
		table.sort(keys)
		local v4 = {}

		for _, v5 in ipairs(keys) do
			local compact = JSONEncoder.Compact(p[v5])
			table.insert(v4, HttpService:UrlEncode(v5) .. "=" .. HttpService:UrlEncode(compact))
		end

		return table.concat(v4, "&")
	end
}

function v2.Build(data)
	table2(data)
	local protocol = data.Protocol or "https"
	local v3 = v[protocol] or 80
	local port = data.Port or v3
	local v4 = {}
	table.insert(v4, protocol)
	table.insert(v4, "://")
	table.insert(v4, data.Host)

	if port ~= v3 then
		table.insert(v4, ":")
		table.insert(v4, (tostring(port)))
	end

	table.insert(v4, v2.EncodePath(data.Path))
	local params = data.Params

	if params and next(params) ~= nil then
		table.insert(v4, "?")
		table.insert(v4, v2.EncodeParams(params))
	end

	if data.Fragment then
		table.insert(v4, "#")
		table.insert(v4, HttpService:UrlEncode(data.Fragment))
	end

	return table.concat(v4)
end

return table.freeze(v2)