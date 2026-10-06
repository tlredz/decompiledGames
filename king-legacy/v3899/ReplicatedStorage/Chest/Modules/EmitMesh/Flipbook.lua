local Range = require(script.Parent.Range)
local Scheduler = require(game.ReplicatedStorage.Chest.Assets.Modules.Scheduler)
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
		task.spawn(function()
			local v3 = Scheduler.new(p3)
			v3:Wait(v)
			v3:OnStep(function()
				p2.Texture = textures[v2]
				v2 += 1

				if v2 > #textures then
					v2 = 1
				end
			end)
			v3:Execute()
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
			local v3 = Scheduler.Repeat(1, #textures)
			v3:Wait(v)
			v3:OnStep(function()
				if v2 > #textures then
					v3:Destroy()
					return
				end

				p2.Texture = textures[v2]
				v2 += 1
			end)
			v3:Execute()
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