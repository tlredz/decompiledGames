local Players = game:GetService("Players")

local function watchCharacter(instance)
	local v = false
	local now = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindSHCS(stringValue)
		if not stringValue:IsA("StringValue") then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function upd()
			local v2 = stringValue.Value ~= ""

			if v and not v2 then
				now = os.clock()
			end

			v = v2
		end

		upd() -- equivalent call inferred; original call site unknown
		stringValue.Changed:Connect(upd)
	end

	local SHCS = instance:FindFirstChild("SHCS")

	if SHCS and SHCS:IsA("StringValue") then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function upd()
			local v2 = SHCS.Value ~= ""

			if v and not v2 then
				now = os.clock()
			end

			v = v2
		end

		upd() -- equivalent call inferred; original call site unknown
		SHCS.Changed:Connect(upd)
	end

	instance.ChildAdded:Connect(function(child)
		if child.Name == "SHCS" then
			bindSHCS(child) -- equivalent call inferred; original call site unknown
		end
	end)
	task.spawn(function()
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 15)

		if not humanoidRootPart then
			return
		end

		local landing = humanoidRootPart:WaitForChild("Landing", 15)

		if landing and landing:IsA("Sound") then
			landing:GetPropertyChangedSignal("Playing"):Connect(function()
				if landing.Playing and (v or os.clock() - now < 0.8) then
					landing.Playing = false
				end
			end)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchPlayer(player)
	if player.Character then
		task.spawn(watchCharacter, player.Character)
	end

	player.CharacterAdded:Connect(watchCharacter)
end

for _, v in Players:GetPlayers() do
	watchPlayer(v) -- equivalent call inferred; original call site unknown
end

Players.PlayerAdded:Connect(watchPlayer)