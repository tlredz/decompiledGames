local Players = game:GetService("Players")
local v = {
	Climbing = true,
	Died = true,
	GettingUp = true,
	Swimming = true,
	Jumping = true,
	Landing = true,
	Splash = true,
	FreeFalling = true,
	Running = true
}
return {
	start = function(instance)
		local connections = {}
		local enabledsByScript = {}
		local playerScripts = instance:WaitForChild("PlayerScripts")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function disable(script)
			if script.Name == "RbxCharacterSounds" and script:IsA("LocalScript") then
				if enabledsByScript[script] == nil then
					enabledsByScript[script] = script.Enabled
				end

				script.Enabled = false
			end
		end

		table.insert(connections, playerScripts.ChildAdded:Connect(disable))
		local v2 = {}
		local v3 = {}

		for _, child in playerScripts:GetChildren() do
			disable(child) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cleanCharacter(p)
			local connection = v2[p]

			if connection then
				connection:Disconnect()
				v2[p] = nil
			end
		end

		local function character(p, folder)
			cleanCharacter(p) -- equivalent call inferred; original call site unknown

			local function removeDefault(descendant)
				local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

				if v[descendant.Name] and (descendant:IsA("Sound") or descendant:IsA("AudioPlayer")) and descendant.Parent == humanoidRootPart then
					descendant:Destroy()
				elseif descendant.Name == "RbxCharacterSoundsEmitter" and descendant:IsA("AudioEmitter") then
					descendant:Destroy()
				end
			end

			v2[p] = folder.DescendantAdded:Connect(removeDefault)

			for _, descendant in folder:GetDescendants() do
				removeDefault(descendant)
			end
		end

		local function add(player)
			v3[player] = player.CharacterAdded:Connect(function(character2)
				character(player, character2)
			end)

			if player.Character then
				character(player, player.Character)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function remove(k)
			cleanCharacter(k) -- equivalent call inferred; original call site unknown

			if v3[k] then
				v3[k]:Disconnect()
				v3[k] = nil
			end
		end

		table.insert(connections, Players.PlayerAdded:Connect(add))
		table.insert(connections, Players.PlayerRemoving:Connect(remove))

		for _, v4 in Players:GetPlayers() do
			local v5 = v4
			v3[v4] = v4.CharacterAdded:Connect(function(character2)
				character(v5, character2)
			end)

			if v4.Character then
				character(v4, v4.Character)
			end
		end

		return function()
			for _, connection in connections do
				connection:Disconnect()
			end

			for k in v3 do
				remove(k) -- equivalent call inferred; original call site unknown
			end

			for k, enabled in enabledsByScript do
				if k.Parent then
					k.Enabled = enabled
				end
			end
		end
	end
}