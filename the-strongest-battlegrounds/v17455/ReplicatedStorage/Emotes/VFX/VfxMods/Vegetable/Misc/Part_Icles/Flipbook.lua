local Range = require(script.Parent.Range)
local Flipbook = {}

local function alive(p)
	return p and p.Parent ~= nil
end

local function getSortedTextures(instance)
	if not instance or instance.Parent == nil then
		return nil
	end

	local children = {}

	for _, child in pairs(instance:GetChildren()) do
		if child.Texture then
			table.insert(children, child)
		end
	end

	if #children == 0 then
		return nil
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
	local sortedTextures = getSortedTextures(p2)

	if not sortedTextures or #sortedTextures == 0 or not p3 or p3.Parent == nil then
		return
	end

	local v = 1 / Range.RandomValueFromRange(p.FlipbookFramerate)
	local v2 = not p.FlipbookStartRandom and 1 or math.random(1, #sortedTextures) or 1
	local lastTime = tick()
	task.spawn(function()
		while true do
			if not p3 or p3.Parent == nil or not (tick() - lastTime < p4) then
				break
			end

			p3.Texture = sortedTextures[v2]
			v2 += 1

			if v2 > #sortedTextures then
				v2 = 1
			end

			task.wait(v)
		end
	end)
end

function Flipbook.OneShot(p, p2, p3, p4)
	local sortedTextures = getSortedTextures(p2)

	if not sortedTextures or #sortedTextures == 0 or not p3 or p3.Parent == nil then
		return
	end

	local v = p4 / #sortedTextures
	local v2 = not p.FlipbookStartRandom and 1 or math.random(1, #sortedTextures) or 1
	task.spawn(function()
		for _ = 1, #sortedTextures do
			if not p3 or p3.Parent == nil or v2 > #sortedTextures then
				break
			end

			p3.Texture = sortedTextures[v2]
			v2 += 1
			task.wait(v)
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