local ImageSprite = require(script.Parent.ImageSprite)
local CompatibilitySprite = {}
local v = {
	__tostring = function()
		return "CompatibilitySprite"
	end
}
v.__index = v

function v:Play()
	return self.__real:Play()
end

function v:Pause()
	return self.__real:Pause()
end

function v:Stop()
	return self.__real:Stop()
end

function v:Advance(value: number?)
	local __real = self.__real

	for _ = 1, value or 1 do
		__real:Advance()
	end
end

function v:Destroy()
	local __real = self.__real

	if __real.isPlaying then
		__real:Pause()
	end

	__real.adornee = nil
end

function v.Clone(data)
	local v2 = CompatibilitySprite.new()
	v2.SpriteSheet = data.SpriteSheet
	v2.InheritSpriteSheet = data.InheritSpriteSheet
	v2.CurrentFrame = data.CurrentFrame
	v2.SpriteSizePixel = data.SpriteSizePixel
	v2.EdgeOffsetPixel = data.EdgeOffsetPixel
	v2.SpriteCount = data.SpriteCount
	v2.SpriteCountX = data.SpriteCountX
	v2.FrameRate = data.FrameRate
	v2.Looped = data.Looped
	return v2
end

function v:GetRealSprite()
	return self.__real
end

local v2 = {
	Adornee = "adornee",
	CurrentFrame = "currentFrame",
	SpriteSizePixel = "spriteSize",
	SpriteOffsetPixel = "spriteOffset",
	EdgeOffsetPixel = "edgeOffset",
	SpriteCount = "spriteCount",
	SpriteCountX = "columnCount",
	FrameRate = "frameRate",
	Looped = "isLooped",
	State = "isPlaying"
}

local function fn(state, p: string, value)
	local v3 = v2[p]
	local __real = state.__real

	if v3 then
		if v3 == "currentFrame" then
			__real:SetFrame(value)
			return
		end

		if v3 ~= "adornee" then
			__real[v3] = value
			return
		end

		if state.InheritSpriteSheet then
			state.SpriteSheet = value.Image
		end

		__real[v3] = value
	elseif p == "SpriteSheet" then
		__real.spriteSheetId = value or ""
	elseif p == "FrameTime" then
		__real.frameRate = math.round(1 / value)
	else
		state.__raw[p] = value
	end
end

function CompatibilitySprite.new()
	local raw = {
		InheritSpriteSheet = true,
		__real = ImageSprite.new({
			adornee = nil,
			spriteSheetId = nil,
			currentFrame = 1,
			spriteSize = Vector2.new(100, 100),
			spriteOffset = Vector2.zero,
			edgeOffset = Vector2.zero,
			spriteCount = 25,
			columnCount = 5,
			frameRate = 15,
			isLooped = true
		})
	}
	raw.__raw = raw
	setmetatable(raw, v)
	local v4 = newproxy(true)
	local metatable = getmetatable(v4)

	function metatable.__tostring()
		return "CompatibilitySprite"
	end

	metatable.__newindex = fn

	function metatable.__index(_, p: string)
		local __real = raw.__real
		local v5 = v2[p]

		if v5 then
			return __real[v5]
		end

		if p == "SpriteSheet" then
			local spriteSheetId = __real.spriteSheetId

			if spriteSheetId == "" then
				return nil
			end

			return spriteSheetId
		elseif p == "FrameTime" then
			return 1 / __real.frameRate
		else
			return raw[p]
		end
	end

	return v4
end

return CompatibilitySprite