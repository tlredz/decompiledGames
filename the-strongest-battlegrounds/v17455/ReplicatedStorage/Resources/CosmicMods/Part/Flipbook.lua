local Range = require(script.Parent.Range)
local Flipbook = {
	Loop = function(p, instance, p2, p3)
		local children = {}

		for _, child in pairs(instance:GetChildren()) do
			if child.Texture then
				table.insert(children, child)
			end
		end

		if #children == 0 then
			return
		end

		table.sort(children, function(a, b)
			return tonumber(a.Name) < tonumber(b.Name)
		end)
		local textures = {}

		for _, v in ipairs(children) do
			table.insert(textures, v.Texture)
		end

		local v = 1 / Range.RandomValueFromRange(p.FlipbookFramerate)
		local v2 = not p.FlipbookStartRandom and 1 or math.random(1, #textures) or 1
		local lastTime = tick()
		task.spawn(function()
			while tick() - lastTime < p3 do
				p2.Texture = textures[v2]
				v2 += 1

				if v2 > #textures then
					v2 = 1
				end

				task.wait(v)
			end
		end)
	end,
	OneShot = function(p, instance, p2, p3)
		local children = {}

		for _, child in pairs(instance:GetChildren()) do
			if child.Texture then
				table.insert(children, child)
			end
		end

		if #children == 0 then
			return
		end

		table.sort(children, function(a, b)
			return tonumber(a.Name) < tonumber(b.Name)
		end)
		local textures = {}

		for _, v in ipairs(children) do
			table.insert(textures, v.Texture)
		end

		if #textures == 0 then
			return
		end

		local v = p3 / #textures
		local v2 = not p.FlipbookStartRandom and 1 or math.random(1, #textures) or 1
		task.spawn(function()
			for _ = 1, #textures do
				if v2 > #textures then
					break
				end

				p2.Texture = textures[v2]
				v2 += 1
				task.wait(v)
			end
		end)
	end
}

function Flipbook.Flip(p, p2, p3, p4)
	local flipbookMode = p.FlipbookMode

	if flipbookMode == Enum.ParticleFlipbookMode.Loop then
		Flipbook.Loop(p, p2, p3, p4)
		return
	end

	if flipbookMode ~= Enum.ParticleFlipbookMode.OneShot then
		return
	end

	Flipbook.OneShot(p, p2, p3, p4)
end

return Flipbook