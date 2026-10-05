local v = workspace:GetServerTimeNow() % 4 / 4 * 0.9
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function InvisChanged(instance)
	if instance:GetAttribute("InvisibilityPotion") then
		if v2[instance] then
			v2[instance].RemoveNow = nil
		else
			v2[instance] = {}
		end
	elseif v2[instance] then
		v2[instance].RemoveNow = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RegisterCharacter(character)
	if not character then
		return
	end

	character:GetAttributeChangedSignal("InvisibilityPotion"):Connect(function()
		InvisChanged(character) -- equivalent call inferred; original call site unknown
	end)
	InvisChanged(character) -- equivalent call inferred; original call site unknown
end

game.Players.PlayerAdded:Connect(function(player)
	local characterAddedConnection = player.CharacterAdded:Connect(RegisterCharacter)
	local playerRemovingConnection = nil
	playerRemovingConnection = game.Players.PlayerRemoving:Connect(function(player2)
		if player == player2 then
			characterAddedConnection:Disconnect()
			playerRemovingConnection:Disconnect()
		end
	end)
	RegisterCharacter(player.Character) -- equivalent call inferred; original call site unknown
end)
local v3 = 1

for _, v4 in pairs(game.Players:GetPlayers()) do
	local v5 = v4
	task.spawn(function()
		local characterAddedConnection = v5.CharacterAdded:Connect(RegisterCharacter)
		local playerRemovingConnection = nil
		playerRemovingConnection = game.Players.PlayerRemoving:Connect(function(player)
			if v5 == player then
				characterAddedConnection:Disconnect()
				playerRemovingConnection:Disconnect()
			end
		end)
		RegisterCharacter(v5.Character) -- equivalent call inferred; original call site unknown
	end)
end

while true do
	v3 = v > 0.97 and -1 or v < 0.95 and 1 or v3
	v += task.wait(0.1) * v3 / 20

	for folder, v4 in pairs(v2) do
		local transparency = v4.RemoveNow and 0 or v

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("Light") then
				if descendant:GetAttribute("AppliedInvisPotion") then
					if transparency == 0 and v4[descendant] then
						descendant.Brightness = v4[descendant]
					end
				else
					descendant:SetAttribute("AppliedInvisPotion", true)
					v4[descendant] = descendant.Brightness
					descendant.Brightness = 0
				end
			elseif descendant:IsA("ParticleEmitter") then
				if descendant:GetAttribute("AppliedInvisPotion") then
					if transparency == 0 and v4[descendant] then
						descendant.Transparency = v4[descendant]
					end
				else
					descendant:SetAttribute("AppliedInvisPotion", true)
					v4[descendant] = descendant.Transparency
					local numberSequenceKeypoints = {}

					for _, keypoint in pairs(descendant.Transparency.Keypoints) do
						table.insert(
							numberSequenceKeypoints,
							NumberSequenceKeypoint.new(keypoint.Time, 0.8 + keypoint.Value * 0.2, keypoint.Envelope)
						)
					end

					descendant.Transparency = NumberSequence.new(numberSequenceKeypoints)
				end
			elseif (descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.Transparency < 1 then
				if descendant:GetAttribute("AppliedInvisPotion") then
					if transparency == 0 and v4[descendant] then
						descendant.Transparency = v4[descendant]
					elseif descendant:GetAttribute("PartType") ~= 2 then
						descendant.Transparency = transparency
					end
				else
					descendant:SetAttribute("AppliedInvisPotion", true)
					v4[descendant] = descendant.Transparency
				end
			end
		end

		if v4.RemoveNow then
			v2[folder] = nil
		end
	end
end