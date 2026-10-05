local remotes = game.ReplicatedStorage.Remotes
local Chance = {}

function Chance.SkewedRandom(_, p: number, p2: number, p3: number, value: number)
	local v = value or 1
	local v2 = p3 / (v < 1 and 1 or v)
	local v3 = math.random() ^ v2
	return p + (p2 - p) * v3
end

function Chance.WeightedRandom(_, items)
	local total = 0
	local v = {}

	for k, item in pairs(items) do
		total += item
		table.insert(v, {
			increment = k,
			weight = item
		})
	end

	table.sort(v, function(a, b)
		return a.increment < b.increment
	end)
	local v2 = math.random() * total
	local total2 = 0

	for _, v3 in ipairs(v) do
		total2 += v3.weight

		if v2 <= total2 then
			return v3.increment
		end
	end

	return v[#v].increment
end

function Chance.GetRandomItemByRarity(_, instance, data)
	if not data then
		warn("No rolling data")
		return
	end

	local chance = data.Chance
	local _ = data.NormalShowup
	local _ = data.NearShowup
	local ownedItems = data.OwnedItems
	local dupeAllowed = data.DupeAllowed or true
	local default = data.Default
	local player = data.Player
	local v = {}

	for _, child in pairs(instance:GetChildren()) do
		if chance[child.Name] == nil then
			continue
		end

		for _, child2 in pairs(child:GetChildren()) do
			if not (child2.Name ~= default and (not string.find(ownedItems.Value, child2.Name) or dupeAllowed == true)) then
				continue
			end

			table.insert(v, { child.Name, chance[child.Name] })
			break
		end
	end

	table.sort(v, function(a, b)
		return a[2] < b[2]
	end)
	local total = 0

	for _, v2 in pairs(v) do
		total += v2[2]
	end

	local v2 = math.random(1, total * 100)
	local total2 = 0
	local v3 = nil

	for _, v5 in pairs(v) do
		total2 += v5[2] * 100

		if not (v2 <= total2) then
			continue
		end

		v3 = v5[1]
		break
	end

	local child = instance:FindFirstChild(v3)
	local children = {}

	for _, child2 in pairs(child:GetChildren()) do
		if not (child2.Name ~= default and (not string.find(ownedItems.Value, child2.Name) or dupeAllowed == true)) then
			continue
		end

		table.insert(children, child2)
	end

	local v5 = children[math.random(1, #children)]

	if not string.find(ownedItems.Value, v5.Name) then
		task.delay(7, function()
			if v3 == "Mythical" then
				remotes.Reusable.ServerMessage:FireAllClients(
					string.format("%s has unlocked %s |  %s", player.DisplayName, v5.Name, v3),
					Color3.fromRGB(255, 85, 255)
				)
			elseif v3 == "Legendary" then
				remotes.Reusable.ServerMessage:FireAllClients(
					string.format("%s has unlocked %s |  %s", player.DisplayName, v5.Name, v3),
					Color3.fromRGB(255, 170, 0)
				)
			end
		end)
	end

	return v5
end

return Chance