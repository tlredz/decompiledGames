local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function(color)
	task.spawn(function()
		local parent = script.Parent

		if not (parent and parent:FindFirstChild("Mesh")) then
			return
		end

		local decals = {}

		for _, decal in ipairs(parent:GetChildren()) do
			if not (decal:IsA("Decal") and string.match(decal.Name, "^Frame_%d+$")) then
				continue
			end

			table.insert(decals, decal)
			decal.Transparency = 1

			if color and decal.Color3 ~= color then
				decal.Color3 = color
			end
		end

		table.sort(decals, function(a, b)
			return tonumber(string.match(a.Name, "%d+")) < tonumber(string.match(b.Name, "%d+"))
		end)
		local count = #decals
		local v = 0
		PeodizService.ForLoop({
			Step = count
		}, function(p)
			local v2 = math.clamp(math.floor(p * count), 1, count)

			if v2 ~= v then
				if decals[v] then
					decals[v].Transparency = 1
				end

				if decals[v2] then
					decals[v2].Transparency = 0
				end

				v = v2
			end
		end)

		for _, v2 in ipairs(decals) do
			v2.Transparency = 1
		end
	end)
end