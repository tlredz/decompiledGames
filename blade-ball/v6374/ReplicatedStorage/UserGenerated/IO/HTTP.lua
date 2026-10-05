local HttpService = game:GetService("HttpService")
local Asserts = require(game.ReplicatedStorage.UserGenerated.Lang.Asserts)
local v = Asserts.Set({
	"GET",
	"HEAD",
	"POST",
	"PUT",
	"DELETE",
	"OPTIONS",
	"TRACE",
	"PATCH"
})
local optional = Asserts.Optional(Asserts.Enum(Enum.HttpCompression))
local table2 = Asserts.Table({
	Url = Asserts.String,
	Method = v,
	Headers = Asserts.Optional(Asserts.Map(Asserts.String, Asserts.String)),
	Body = Asserts.Optional(Asserts.RawString),
	Compress = optional,
	NoCache = Asserts.Optional(Asserts.Boolean)
})
return table.freeze({
	AssertCompress = optional,
	AssertMethod = v,
	AssertParams = table2,
	Execute = function(data)
		table2(data)
		local headers = data.Headers or {}

		if data.NoCache then
			headers = table.clone(headers)
			headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
			headers.Pragma = "no-cache"
			headers.Expires = "0"
		end

		local v2 = {
			Url = data.Url,
			Method = data.Method,
			Headers = headers,
			Body = data.Body,
			Compress = data.Compress
		}
		local success, result = pcall(HttpService.RequestAsync, HttpService, v2)

		if success then
			return result
		end

		return {
			Success = false,
			StatusCode = 400,
			StatusMessage = tostring(result),
			Headers = {}
		}
	end
})