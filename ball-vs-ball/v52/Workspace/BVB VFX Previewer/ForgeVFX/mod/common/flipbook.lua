local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Flipbook = {
	serialize = function(list)
		local buf = buffer.create(#list * 8)

		for k, value in list do
			buffer.writef64(buf, (k - 1) * 8, value)
		end

		return buf
	end,
	deserialize = function(buffer2)
		if typeof(buffer2) == "string" then
			buffer2 = buffer.fromstring(buffer2) or buffer2
		end

		local result = {}

		for i = 0, buffer.len(buffer2) / 8 - 1 do
			table.insert(result, (buffer.readf64(buffer2, i * 8)))
		end

		return result
	end,
	isLocalFlipbook = function(p)
		if not RunService:IsStudio() then
			return false
		end

		for _, v in CollectionService:GetTags(p) do
			if v:match("^_local_flipbook_") then
				return true
			end
		end

		return false
	end
}

function Flipbook.getTexturePrefix(p)
	if Flipbook.isLocalFlipbook(p) then
		return "rbxtemp://"
	end

	return "rbxassetid://"
end

function Flipbook.getFlipbookData(instance)
	if not instance:GetAttribute("FlipbookEnabled") then
		return nil
	end

	local flipbookTextures = instance:GetAttribute("FlipbookTextures")

	if not flipbookTextures then
		return nil
	end

	local deserialized = Flipbook.deserialize(flipbookTextures)

	if #deserialized == 0 then
		return nil
	end

	return deserialized
end

function Flipbook.getChangeDuration(data)
	local duration = data.duration

	if data.ref:GetAttribute("SyncDuration") then
		duration = data.effectDuration
	end

	return duration
end

function Flipbook.createUpdateCallback(data)
	local texturePrefix = Flipbook.getTexturePrefix(data.ref)
	return function(p, p2)
		local v = math.max(math.round(#data.frames * p), 1)
		data.setTexture((`{texturePrefix}{data.frames[v]}`))
		return p2 * data.getSpeed()
	end
end

return Flipbook