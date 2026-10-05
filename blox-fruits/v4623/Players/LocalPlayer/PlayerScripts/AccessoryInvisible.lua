local v = {}

local function check(instance)
	if instance:WaitForChild("Humanoid", 3) then
		local playerFromCharacter = nil

		for _ = 1, 10 do
			playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

			if playerFromCharacter then
				break
			else
				wait()
			end
		end

		if not playerFromCharacter then
			return
		end

		local upperTorso = instance:WaitForChild("UpperTorso", 3)

		if not upperTorso then
			return
		end

		assert(upperTorso and upperTorso:IsA("BasePart"), "bad upperTorso")

		if v[instance] then
			for _, connection in pairs(v[instance].con) do
				connection:Disconnect()
			end
		end

		v[instance] = {
			parts = {},
			con = {}
		}
		table.insert(v[instance].con, upperTorso:GetPropertyChangedSignal("Transparency"):Connect(function()
			for _, part in pairs(v[instance].parts) do
				part.Transparency = upperTorso.Transparency
			end
		end))
		table.insert(v[instance].con, upperTorso:GetAttributeChangedSignal("Transparent"):Connect(function()
			for _, part in pairs(v[instance].parts) do
				part.Transparency = upperTorso.Transparency
			end
		end))
	end
end

workspace:WaitForChild("Characters")
workspace.Characters.ChildAdded:Connect(check)
workspace.Characters.ChildRemoved:Connect(function(child)
	if v[child] then
		for _, connection in pairs(v[child].con) do
			connection:Disconnect()
		end
	end

	v[child] = nil
end)

for _, child in pairs(workspace.Characters:GetChildren()) do
	local v2 = child
	task.spawn(function()
		check(v2)
	end)
end

workspace:WaitForChild("_WorldOrigin"):WaitForChild("PlayerAccessoriesProxy").ChildAdded:Connect(function(child)
	local owner = child:GetAttribute("Owner")
	local child2 = game.Players:FindFirstChild(owner)

	if child2 and child2.Character then
		task.wait(0.1)
		local parts = v[child2.Character] and v[child2.Character].parts

		if not parts then
			return
		end

		for _, part in pairs(child:GetChildren()) do
			if not part:IsA("BasePart") or not (part.Transparency < 1) or table.find(parts, part) then
				continue
			end

			table.insert(parts, part)
		end
	end
end)
require(game.ReplicatedStorage.CharacterTransparency)