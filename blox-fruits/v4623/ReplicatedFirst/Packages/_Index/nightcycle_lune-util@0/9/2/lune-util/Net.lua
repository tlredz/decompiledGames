local CONFIG = require(script.Parent:WaitForChild("CONFIG"))
local JsonEncode = require(script.Parent:WaitForChild("JsonEncode"))
local v = nil

if CONFIG.IS_LUNE_ENV then
	local module = require("@lune/net")
	local module2 = require("@lune/serde")
	return {
		request = function(url)
			local v2

			if type(url) == "string" then
				v2 = module.request({
					url = url
				})
			else
				v2 = module.request(url)
			end

			return {
				ok = v2.ok,
				statusCode = v2.statusCode,
				statusMessage = v2.statusMessage,
				headers = v2.headers,
				body = v2.body
			}
		end,
		generateGUID = function(flag: boolean?)
			local function generateGUID()
				math.randomseed((math.round(os.clock() % 1 * 100000000000)))

				-- equivalent calls inferred from this helper; original call sites unknown
				local function randomHexDigit()
					local v2 = math.random(0, 15)
					return string.format("%x", v2)
				end

				local function getHexStr(p: number)
					local v2 = ""

					for _ = 1, p do
						v2 ..= randomHexDigit()
					end

					return v2
				end

				local hexStr = getHexStr(8)
				local v5 = ""
				v5 ..= randomHexDigit()
				v5 ..= randomHexDigit()
				v5 ..= randomHexDigit()
				v5 ..= randomHexDigit()
				local v8 = "4" .. (("" .. randomHexDigit()) .. randomHexDigit()) .. randomHexDigit()
				local v9 = string.format("%x", math.random(8, 11))
				local v11 = ("" .. randomHexDigit()) .. randomHexDigit()
				local v12 = math.random(0, 15)
				local v13 = {
					hexStr,
					v5,
					v8,
					v9 .. v11 .. string.format("%x", v12),
					(getHexStr(12))
				}
				return table.concat(v13, "-")
			end

			if flag or flag == nil then
				return "{" .. generateGUID() .. "}"
			end

			return generateGUID()
		end,
		jsonEncode = function(p)
			return JsonEncode(p)
		end,
		jsonDecode = function(p: string)
			return module2.decode("json", p)
		end,
		IS_ENABLED = true
	}
elseif CONFIG.IS_RBX_ENV then
	local HttpService = game:GetService("HttpService")
	return {
		request = function(url)
			local v2 = type(url) == "string" and ({
				Url = url
			} or url) or url
			local v4 = {
				Url = v2.url,
				Method = v2.method,
				Body = v2.body,
				Headers = v2.headers,
				Compress = 0
			}
			local compress

			if v2.options and v2.options.decompress == false then
				compress = Enum.HttpCompression.None
			else
				compress = Enum.HttpCompression.Gzip
			end

			v4.Compress = compress
			local async = HttpService:RequestAsync(v4)
			return {
				ok = async.Success,
				statusCode = async.StatusCode,
				statusMessage = async.StatusMessage,
				headers = async.Headers,
				body = async.Body or ""
			}
		end,
		generateGUID = function(flag: boolean?)
			return (string.sub(HttpService:GenerateGUID(flag), 2, -2))
		end,
		jsonEncode = function(p)
			return JsonEncode(p)
		end,
		jsonDecode = function(json: string)
			return HttpService:JSONDecode(json)
		end,
		IS_ENABLED = HttpService.HttpEnabled
	}
else
	error("Unsupported environment")
	return v
end