local Range = require(script.Parent.Range)
local Flipbook = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function alive(instance)
	return instance and instance.Parent and instance:IsDescendantOf(game)
end

local function get_decals(instance)
	local children = {}

	for _, child in pairs(instance:GetChildren()) do
		if child.Texture then
			table.insert(children, child)
		end
	end

	table.sort(children, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	local textures = {}

	for _, v in ipairs(children) do
		table.insert(textures, v.Texture)
	end

	return textures
end

function Flipbook.Loop(p, p2, p3, p4)
	local v = get_decals(p2)

	if #v == 0 then
		return
	end

	local v2 = 1 / math.max(Range.RandomValueFromRange(p.FlipbookFramerate), 0.001)
	local v3 = not p.FlipbookStartRandom and 1 or math.random(1, #v) or 1
	local lastTime = tick()
	task.spawn(function()
		while true do
			if not (alive(p3) and tick() - lastTime < p4) then
				break
			end

			p3.Texture = v[v3]
			v3 += 1

			if v3 > #v then
				v3 = 1
			end

			task.wait(v2)
		end
	end)
end

function Flipbook.OneShot(p, p2, p3, p4)
	local v = get_decals(p2)

	if #v == 0 then
		return
	end

	local v2 = p4 / #v
	local v3 = not p.FlipbookStartRandom and 1 or math.random(1, #v) or 1
	task.spawn(function()
		for _ = 1, #v do
			if not alive(p3) or v3 > #v then
				break
			end

			p3.Texture = v[v3]
			v3 += 1
			task.wait(v2)
		end
	end)
end

function Flipbook.Flip(p, p2, p3, p4)
	local flipbookMode = p.FlipbookMode

	if flipbookMode == Enum.ParticleFlipbookMode.Loop then
		Flipbook.Loop(p, p2, p3, p4)
	elseif flipbookMode == Enum.ParticleFlipbookMode.OneShot then
		Flipbook.OneShot(p, p2, p3, p4)
	end
end

return Flipbook