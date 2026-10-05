local RunService = game:GetService("RunService")
local Encode = require(script.Encode)
local Reflection = require(script.Reflection)
local fastIndex = Encode.fastIndex
local v = {
	"Workspace",
	"Players",
	"Lighting",
	"MaterialService",
	"ReplicatedFirst",
	"ReplicatedStorage",
	"SoundService",
	"StarterGui",
	"StarterPack",
	"StarterPlayer",
	"Teams",
	"TextChatService"
}
local v2 = { "ServerScriptService", "ServerStorage" }

local function encodeId(count: number)
	local v3 = {}

	repeat
		v3[#v3 + 1] = string.char(count % 256)
		count //= 256
	until count == 0

	return table.concat(v3)
end

return {
	capture = function(options, p: number?)
		local v3 = options or {}
		local properties = v3.properties == true
		local yielding = v3.yielding ~= false
		local v4 = (not (p and p > 0) and 0.016666666666666666 or p) * 0.33
		local v5 = os.clock() + 30
		local classes = {}
		local v7 = {}

		local function classIdx(p2: string)
			local v8 = v7[p2]

			if v8 then
				return v8
			end

			local count = #classes
			classes[count + 1] = p2
			v7[p2] = count
			return count
		end

		local props = {}
		local v9 = {}

		local function propIdx(p2: string)
			local v10 = v9[p2]

			if v10 then
				return v10
			end

			local count = #props
			props[count + 1] = p2
			v9[p2] = count
			return count
		end

		local v10 = {}
		local count = 0
		local v11 = {}

		local function assign(p2)
			local v12 = v10[p2]

			if v12 then
				return v12
			end

			count += 1
			local v13 = encodeId(count)
			v10[p2] = v13
			v11[#v11 + 1] = p2
			return v13
		end

		local game2 = game

		if not v10[game2] then
			count += 1
			v10[game2] = encodeId(count)
			v11[#v11 + 1] = game2
		end

		local clone = table.clone(v)

		if RunService:IsServer() then
			for _, v12 in v2 do
				table.insert(clone, v12)
			end
		end

		for _, v12 in clone do
			local v13 = v12
			local success, result = pcall(function()
				return game:GetService(v13)
			end)

			if not (success and result) then
				continue
			end

			if not v10[result] then
				count += 1
				v10[result] = encodeId(count)
				v11[#v11 + 1] = result
			end

			local folder = result
			local success2, result2 = pcall(function()
				return folder:GetDescendants()
			end)

			if not (success2 and result2) then
				continue
			end

			for _, v14 in result2 do
				if v10[v14] then
					continue
				end

				count += 1
				v10[v14] = encodeId(count)
				v11[#v11 + 1] = v14
			end
		end

		local writer = Encode.newWriter(262144)
		writer:u8(68)
		writer:u8(1)
		writer:u8(properties and 1 or 0)
		local now = os.clock()
		local count2 = 0
		local truncated = false

		for _, v14 in v11 do
			local v15

			if v14 == game then
				v15 = ""
			else
				local success, result = pcall(fastIndex, v14, "Parent")

				if not success or result == nil then
					continue
				end

				v15 = v10[result] or ""

				if v15 == "" then
					continue
				end
			end

			local success, result = pcall(fastIndex, v14, "ClassName")

			if not (success and type(result) == "string") then
				continue
			end

			local success2, result2 = pcall(fastIndex, v14, "Name")

			if success2 then
				if type(result2) ~= "string" then
					result2 = result
				end
			else
				result2 = result
			end

			writer:strU8(v10[v14])
			writer:strU8(v15)
			local v16 = v7[result]

			if not v16 then
				v16 = #classes
				classes[v16 + 1] = result
				v7[result] = v16
			end

			writer:u16(v16)
			writer:strU16(result2)

			if properties then
				local readProperties = Reflection.getReadProperties(result)
				local len = writer.len
				writer:u16(0)
				local count3 = 0

				for _, readProperty in readProperties do
					local success3, result3 = pcall(fastIndex, v14, readProperty)

					if not success3 then
						continue
					end

					local v17 = v9[readProperty]

					if not v17 then
						v17 = #props
						props[v17 + 1] = readProperty
						v9[readProperty] = v17
					end

					writer:u16(v17)
					Encode.writeValue(writer, result3)
					count3 += 1
				end

				writer:patchU16(len, count3)
			end

			count2 += 1

			if writer.len >= 50331648 then
				truncated = true
				break
			elseif yielding and count2 >= 20 then
				local now2 = os.clock()

				if v5 <= now2 then
					return {
						TimedOut = true
					}
				end

				if v4 <= now2 - now then
					task.wait()
					now = os.clock()
					count2 = 0
				end
			end
		end

		return {
			Buffer = writer:finish(),
			Classes = classes,
			Props = props,
			Truncated = truncated
		}
	end
}