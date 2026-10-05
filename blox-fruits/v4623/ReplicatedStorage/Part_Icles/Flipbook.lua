local ContentProvider = game:GetService("ContentProvider")
local Range = require(script.Parent.Range)
local Flipbook = {
	GetSortedTextures = function(instance)
		local children = {}

		for _, child in pairs(instance:GetChildren()) do
			if child:IsA("Decal") or child:IsA("Texture") then
				table.insert(children, child)
			end
		end

		if #children == 0 then
			return {}
		end

		table.sort(children, function(a, b)
			return (tonumber(a.Name) or 0) < (tonumber(b.Name) or 0)
		end)
		local textures = {}

		for _, v in ipairs(children) do
			table.insert(textures, v.Texture)
		end

		if #textures > 0 then
			task.spawn(function()
				ContentProvider:PreloadAsync(textures)
			end)
		end

		return textures
	end,
	GetSortedBeamTextures = function(instance)
		local decals = {}

		for _, decal in pairs(instance:GetChildren()) do
			if decal:IsA("Decal") then
				table.insert(decals, decal)
			end
		end

		if #decals == 0 then
			return {}
		end

		table.sort(decals, function(a, b)
			return (tonumber(a.Name) or 0) < (tonumber(b.Name) or 0)
		end)
		local textures = {}

		for _, v in ipairs(decals) do
			table.insert(textures, v.Texture)
		end

		if #textures > 0 then
			task.spawn(function()
				ContentProvider:PreloadAsync(textures)
			end)
		end

		return textures
	end
}
local v = false

local function _writeFrame(instance, p, p2)
	local success, result = pcall(function()
		instance[p] = p2
	end)

	if not success and p == "ColorMap" and not v then
		v = true
		warn(("[Part-Icles] SurfaceAppearance flipbook ColorMap write failed (%s). ColorMap is PluginSecurity  -  SurfaceAppearance flipbooks only animate in plugin context. For runtime games, use Decal / Texture flipbooks instead."):format((tostring(result))))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _texProp(instance)
	if instance and instance:IsA("SurfaceAppearance") then
		return "ColorMap"
	end

	if instance and instance:IsA("MeshPart") then
		return "TextureID"
	end

	return "Texture"
end

local function _loop(p, data, list, instance, p2)
	if #list == 0 then
		return
	end

	local randomValueFromRange = Range.RandomValueFromRange(data.FlipbookFramerate)
	local v2 = 1 / ((not randomValueFromRange or randomValueFromRange < 0.1) and 0.1 or randomValueFromRange)
	local count = #list
	local flipbookReverse = data.FlipbookReverse
	local v3 = not data.FlipbookStartRandom and 0 or math.random(0, count - 1) or 0
	local lastTime = os.clock()
	local v4 = _texProp(instance) -- equivalent call inferred; original call site unknown
	task.spawn(function()
		local v5 = -1

		while os.clock() - lastTime < p2 * 4 do
			if not (instance and instance.Parent) or p and not (p.VisualPart and p.VisualPart.Parent) then
				break
			end

			local v6 = (math.floor((p and p._effectiveElapsed or os.clock() - lastTime) / v2) + v3) % count + 1

			if flipbookReverse then
				v6 = count - v6 + 1
			end

			if v6 ~= v5 then
				_writeFrame(instance, v4, list[v6])
				v5 = v6
			end

			task.wait()
		end
	end)
end

local function _oneShot(p, p2, list, instance, p3)
	if #list == 0 then
		return
	end

	local count = #list
	local flipbookReverse = p2.FlipbookReverse
	local v2 = not p2.FlipbookStartRandom and 0 or math.random(0, count - 1) or 0
	local lastTime = os.clock()
	local v3 = _texProp(instance) -- equivalent call inferred; original call site unknown
	task.spawn(function()
		local v4 = -1

		while os.clock() - lastTime < p3 * 4 do
			if not (instance and instance.Parent) then
				return
			end

			if p and not (p.VisualPart and p.VisualPart.Parent) then
				break
			end

			local v5 = (math.min(
				math.floor((p and p._effectiveElapsed or os.clock() - lastTime) / p3 * count) + 1,
				count
			) - 1 + v2) % count + 1

			if flipbookReverse then
				v5 = count - v5 + 1
			end

			if v5 ~= v4 then
				_writeFrame(instance, v3, list[v5])
				v4 = v5
			end

			task.wait()
		end

		if instance and instance.Parent then
			local v5 = (count - 1 + v2) % count + 1

			if flipbookReverse then
				v5 = count - v5 + 1
			end

			_writeFrame(instance, v3, list[v5])
		end
	end)
end

function Flipbook.Flip(p, p2, p3, p4, p5)
	if not (p2 and p2.FlipbookMode) then
		return
	end

	if p2.FlipbookMode == Enum.ParticleFlipbookMode.Loop then
		_loop(p, p2, p3, p4, p5)
	elseif p2.FlipbookMode == Enum.ParticleFlipbookMode.OneShot then
		_oneShot(p, p2, p3, p4, p5)
	end
end

function Flipbook.FlipBeam(p, p2, p3, p4, p5)
	if not (p2 and p3 and p2.FlipbookMode) then
		return
	end

	local flipbookMode = p2.FlipbookMode

	if flipbookMode == Enum.ParticleFlipbookMode.Loop then
		_loop(p, p2, p3, p4, p5)
	elseif flipbookMode == Enum.ParticleFlipbookMode.OneShot then
		_oneShot(p, p2, p3, p4, p5)
	end
end

return Flipbook