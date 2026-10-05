local MasteryManager = {}
game:GetService("TweenService")
MasteryManager.registeredGUIs = {}
MasteryManager.isInitialized = false
MasteryManager.replicatedData = nil

local function updateMasteryUI(p, value, instance)
	local mastery = instance:FindFirstChild("Mastery")

	if not mastery then
		warn("MasteryManager: Mastery folder not found in replicatedData")
		return
	end

	local child = mastery:FindFirstChild(value)

	if not child then
		warn("MasteryManager: Mastery data not found for character:", value)
		return
	end

	local children = child:GetChildren()
	local count = 0

	for _, v in pairs(children) do
		local current = v:FindFirstChild("Current")
		local amount = v:FindFirstChild("Amount")

		if current and amount then
			if math.clamp(current.Value / amount.Value, 0, 1) == 1 then
				count += 1
			end
		else
			warn("MasteryManager: Quest missing 'Current' or 'Amount' for quest:", v.Name)
		end
	end

	local v = children and math.clamp(count / #children, 0, 1) or 0
	p.MasteryFrame.MaxLoad.CurrentLoad.Size = UDim2.new(v, 0, 1, 0)

	if v == 1 then
		p.MasteryFrame.CompletedText.Text = "COMPLETED!"
		return
	end

	p.MasteryFrame.CompletedText.Text = "REACH 100% MASTERY TO UNLOCK A SKIN!"
	p.MasteryFrame.ClaimReward.Visible = false
end

local function QuestText(name, value, value2, p)
	if name == "PassiveAbilityActivate" then
		return "Activate this Toon's Passive Ability " .. value .. " times!"
	elseif name == "ActiveAbilityActivate" then
		return "Use this Toon's Active Ability " .. value .. " times!"
	elseif name == "TravelDistance" then
		return "Travel " .. value .. " Meters!"
	elseif name == "PickUpItem" then
		return "Pick up " .. value .. " Items!"
	elseif name == "SurviveFloor" then
		return "Survive " .. value .. " Floors!"
	elseif name == "UseItem" then
		return "Use " .. value .. " Items!"
	elseif name == "UseItemSpecific" then
		return "Use " .. value .. " " .. p .. "s!"
	elseif name == "CompleteGenerator" then
		return "Finish " .. value .. " Machines!"
	elseif name == "CollectResearch" then
		return "Collect " .. value .. "% of Twisted Research!"
	elseif name == "PickUpCapsule" then
		return "Pick up " .. value .. " Research Capsules!"
	elseif name == "EncounterMonster" then
		return "Encounter " .. value .. " Twisteds!"
	elseif name == "BlackOut" then
		return "Experience " .. value .. " Blackouts!"
	elseif name == "IchorSpill" then
		return "Experience " .. value .. " Ichor Spills!"
	elseif name == "IcedOver" then
		return "Experience " .. value .. " Iced Over floors!"
	end

	if name == "SurviveFloorWithToon" then
		local v = ""

		if type(value2) == "table" then
			local count = #value2

			if count == 0 then
				v = "specific Toons"
			elseif count == 1 then
				v = value2[1]
			elseif count >= 2 then
				local v2 = {}

				for i = 1, count - 1 do
					table.insert(v2, value2[i])
				end

				v = table.concat(v2, ", ") .. " and " .. value2[count]
			end
		elseif type(value2) == "string" then
			if value2 == "Main" then
				v = "any Main"
			else
				v = value2
			end
		else
			v = "an unknown Toon"
		end

		return "Survive " .. value .. " Floors with " .. v .. " in your round!"
	else
		if name == "SurviveFloorWithParty" then
			return "Survive " .. value .. " Floors with " .. value2 - 1 .. " other Players in your round!"
		elseif name == "BuyDandyStoreItem" then
			return "Purchase " .. value .. " items from Dandy's Elevator Shop!"
		elseif name == "ReachFloor" then
			return "Reach Floor " .. value2 .. "!"
		end

		return "Unknown Quest Type!"
	end
end

local function updateQuestUI(p, instance, _)
	local current = instance:FindFirstChild("Current")
	local amount = instance:FindFirstChild("Amount")
	local v = not (current and amount) and 0 or math.clamp(current.Value / amount.Value, 0, 1) or 0
	local holderFrame = p.MasteryFrame.HolderFrame
	local clone = holderFrame:FindFirstChild(instance.Name)

	if not clone then
		clone = holderFrame.Template:Clone()
		clone.Name = instance.Name
		clone.Parent = holderFrame
		clone.Visible = true
	end

	if clone.MaxFill and clone.MaxFill.CurrentFill then
		clone.MaxFill.CurrentFill.Size = UDim2.new(v, 0, 1, 0)
	else
		warn("MasteryManager: Missing 'MaxFill.CurrentFill' in questFrame:", clone.Name)
	end

	if instance:FindFirstChild("DisplayText") then
		local displayText = instance:FindFirstChild("DisplayText")
		clone.CharacterName.Text = string.format(displayText.Value, amount.Value)
	elseif instance:FindFirstChild("Tower") then
		local tower = instance:WaitForChild("Tower")
		clone.CharacterName.Text = QuestText(instance.Name, amount.Value, tower.Value)
	elseif instance:FindFirstChild("Tower_1") then
		local v2 = 1
		local v3 = {}

		while true do
			local stringValue = instance:FindFirstChild("Tower_" .. v2)

			if not (stringValue and stringValue:IsA("StringValue")) then
				break
			end

			table.insert(v3, stringValue.Value)
			v2 += 1
		end

		if #v3 > 0 then
			clone.CharacterName.Text = QuestText(instance.Name, amount.Value, v3)
		else
			clone.CharacterName.Text = QuestText(instance.Name, amount.Value, nil)
		end
	elseif instance:FindFirstChild("Item") then
		local item = instance:WaitForChild("Item")
		clone.CharacterName.Text = QuestText(instance.Name, amount.Value, nil, item.Value)
	elseif instance:FindFirstChild("Number") then
		local number = instance:WaitForChild("Number")
		clone.CharacterName.Text = QuestText(instance.Name, amount.Value, number.Value)
	else
		clone.CharacterName.Text = QuestText(instance.Name, amount.Value)
	end

	clone.CharacterAmount.Text = v == 1 and "COMPLETED!" or current and tostring(current.Value) .. "/" .. tostring(amount.Value) or "0/0"
end

function MasteryManager.initialize(replicatedData)
	if MasteryManager.isInitialized then
		return
	end

	MasteryManager.isInitialized = true

	if not replicatedData then
		error("MasteryManager: initialize called without replicatedData")
	end

	MasteryManager.replicatedData = replicatedData
	local selectedCharacter = replicatedData:WaitForChild("SelectedCharacter")

	if not selectedCharacter then
		error("MasteryManager: 'SelectedCharacter' not found in replicatedData")
	end

	local characterName = selectedCharacter.Value

	local function updateAllGUIs()
		for k, v in pairs(MasteryManager.registeredGUIs) do
			if v.characterName ~= characterName then
				v.characterName = characterName

				for _, button in pairs(k.MasteryFrame.HolderFrame:GetChildren()) do
					if button:IsA("TextButton") and button.Name ~= "Template" then
						button:Destroy()
					end
				end

				local child = replicatedData.Mastery:FindFirstChild(characterName)

				if child then
					local children = child:GetChildren()

					for _, v2 in pairs(children) do
						updateQuestUI(k, v2, replicatedData)
					end
				else
					warn("MasteryManager: Mastery data not found for character:", characterName)
				end
			end

			updateMasteryUI(k, characterName, replicatedData)
		end
	end

	local changedConnection = selectedCharacter.Changed:Connect(function(p)
		print("MasteryManager: SelectedCharacter changed to:", p)
		characterName = p
		updateAllGUIs()
	end)
	MasteryManager.connections = MasteryManager.connections or {}
	table.insert(MasteryManager.connections, changedConnection)
	local mastery = replicatedData:WaitForChild("Mastery")
	local childAddedConnection = mastery.ChildAdded:Connect(updateAllGUIs)
	local childRemovedConnection = mastery.ChildRemoved:Connect(updateAllGUIs)
	table.insert(MasteryManager.connections, childAddedConnection)
	table.insert(MasteryManager.connections, childRemovedConnection)

	for k, v in pairs(MasteryManager.registeredGUIs) do
		for _, button in pairs(k.MasteryFrame.HolderFrame:GetChildren()) do
			if button:IsA("TextButton") and button.Name ~= "Template" then
				button:Destroy()
			end
		end

		local child = replicatedData.Mastery:FindFirstChild(characterName)

		if child then
			local children = child:GetChildren()

			for _, v2 in pairs(children) do
				updateQuestUI(k, v2, replicatedData)
				local current = v2:FindFirstChild("Current")
				local amount = v2:FindFirstChild("Amount")

				if current and amount then
					local v3 = k
					local v4 = v2
					local changedConnection2 = current.Changed:Connect(function()
						updateQuestUI(v3, v4, replicatedData)
						updateMasteryUI(v3, characterName, replicatedData)
					end)
					table.insert(v.connections, changedConnection2)
					local v5 = k
					local v6 = v2
					local changedConnection3 = amount.Changed:Connect(function()
						updateQuestUI(v5, v6, replicatedData)
						updateMasteryUI(v5, characterName, replicatedData)
					end)
					table.insert(v.connections, changedConnection3)
				else
					warn("MasteryManager: Quest missing 'Current' or 'Amount':", v2.Name)
				end
			end
		else
			warn("MasteryManager: Mastery data not found for character:", characterName)
		end

		updateMasteryUI(k, characterName, replicatedData)
		local v2 = v
		local v3 = k

		local function closeMasteryFrame()
			if v2.masterCooldown then
				return
			end

			v2.masterCooldown = true
			task.delay(1, function()
				v2.masterCooldown = false
			end)
			v3.MasteryFrame.Visible = false

			for i, connection in ipairs(v2.connections) do
				connection:Disconnect()
			end

			v2.connections = {}
			MasteryManager.registeredGUIs[v3] = nil
		end

		local activatedConnection = k.MasteryFrame.ExitButton.Activated:Connect(closeMasteryFrame)
		table.insert(v.connections, activatedConnection)
		k.MasteryFrame.Visible = true
	end

	updateAllGUIs()
end

function MasteryManager.register(instance, p)
	if not (instance and instance:FindFirstChild("MasteryFrame")) then
		warn("MasteryManager: Invalid GUI provided to MasteryManager.register")
		return
	end

	if MasteryManager.registeredGUIs[instance] then
		return
	end

	if not p then
		warn("MasteryManager: replicatedData is nil when registering GUI:", instance.Name)
		return
	end

	MasteryManager.registeredGUIs[instance] = {
		connections = {},
		characterName = p.SelectedCharacter.Value,
		masterCooldown = false
	}

	if not MasteryManager.isInitialized then
		MasteryManager.initialize(p)
		return
	end

	local value = p.SelectedCharacter.Value

	for _, button in pairs(instance.MasteryFrame.HolderFrame:GetChildren()) do
		if button:IsA("TextButton") and button.Name ~= "Template" then
			button:Destroy()
		end
	end

	local child = p.Mastery:FindFirstChild(value)

	if child then
		local children = child:GetChildren()

		for _, v in pairs(children) do
			updateQuestUI(instance, v, p)
			local current = v:FindFirstChild("Current")
			local amount = v:FindFirstChild("Amount")

			if current and amount then
				local v2 = v
				local changedConnection = current.Changed:Connect(function()
					updateQuestUI(instance, v2, p)
					updateMasteryUI(instance, value, p)
				end)
				table.insert(MasteryManager.registeredGUIs[instance].connections, changedConnection)
				local v3 = v
				local changedConnection2 = amount.Changed:Connect(function()
					updateQuestUI(instance, v3, p)
					updateMasteryUI(instance, value, p)
				end)
				table.insert(MasteryManager.registeredGUIs[instance].connections, changedConnection2)
			else
				warn("MasteryManager: Quest missing 'Current' or 'Amount' when registering GUI:", v.Name)
			end
		end
	else
		warn("MasteryManager: Mastery data not found for character:", value)
	end

	updateMasteryUI(instance, value, p)

	local function closeMasteryFrame()
		local v = MasteryManager.registeredGUIs[instance]

		if v.masterCooldown then
			return
		end

		v.masterCooldown = true
		task.delay(1, function()
			v.masterCooldown = false
		end)
		instance.MasteryFrame.Visible = false

		for _, connection in ipairs(v.connections) do
			connection:Disconnect()
		end

		v.connections = {}
		MasteryManager.registeredGUIs[instance] = nil
	end

	local activatedConnection = instance.MasteryFrame.ExitButton.Activated:Connect(closeMasteryFrame)
	table.insert(MasteryManager.registeredGUIs[instance].connections, activatedConnection)
	instance.MasteryFrame.Visible = true
end

function MasteryManager.unregister(p)
	if not MasteryManager.registeredGUIs[p] then
		warn("MasteryManager: Attempted to unregister a GUI that is not registered:", p.Name)
		return
	end

	local v = MasteryManager.registeredGUIs[p]

	for _, connection in ipairs(v.connections) do
		connection:Disconnect()
	end

	MasteryManager.registeredGUIs[p] = nil
	print("MasteryManager: Unregistered GUI:", p.Name)
end

return MasteryManager