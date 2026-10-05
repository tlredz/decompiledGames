local createVector = vector.create
local Quest = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local character = require(ReplicatedStorage.shared.modules:WaitForChild("character"))
local level = require(ReplicatedStorage.shared.modules:WaitForChild("character"):WaitForChild("level"))
local titles = require(ReplicatedStorage.shared.modules:WaitForChild("character"):WaitForChild("titles"))
local debris = require(ReplicatedStorage.shared.modules:WaitForChild("fx"):WaitForChild("debris"))

function Quest:Find(p, p2, p3)
	local v = character.PS(p)

	if v == nil then
		return
	end

	local children = {}

	if p3 == true then
		for _, child in pairs(v:WaitForChild("Quests"):GetChildren()) do
			if not (child:FindFirstChild("Track") and child:FindFirstChild("Track").Value == p2) then
				continue
			end

			children[#children + 1] = child
		end
	else
		for _, child in pairs(v:WaitForChild("Quests"):GetChildren()) do
			if not (child:FindFirstChild("TypeOfQuest") and child:FindFirstChild("TypeOfQuest").Value == p2) then
				continue
			end

			children[#children + 1] = child
		end
	end

	return children
end

function Quest.FindLine(_, instance, p)
	local v = tostring(p)

	for _, child in pairs(instance:GetChildren()) do
		if string.find(string.lower(child.Name), string.lower(v)) and instance:FindFirstChild(child.Name .. "_Goal") then
			return child
		end
	end
end

function Quest:TrackQuest(p, name)
	local v = character.PS(p)

	if v == nil then
		return
	end

	local stringValue = Instance.new("StringValue")
	stringValue.Name = name
	stringValue.Value = os.time()
	stringValue.Parent = v:WaitForChild("Stats"):WaitForChild("tracker_quests")
	return stringValue
end

function Quest.FindTracker(_, p, p2)
	local v = character.PS(p)

	if v == nil then
		return
	end

	for _, child in pairs(v:WaitForChild("Stats"):WaitForChild("tracker_quests"):GetChildren()) do
		if child.Name == p2 then
			return child
		end
	end

	return nil
end

function Quest:Complete(player, instance)
	local v = character.PS(player)

	if v == nil then
		return
	end

	if instance:FindFirstChild("Track") then
		Quest:TrackQuest(player, instance:FindFirstChild("Track").Value)

		if instance:FindFirstChild("Track").Value == "Tutorial2" then
			task.delay(4, function()
				if #Quest:Find(player, "Tutorial3", false) <= 0 then
					Quest:New(player, {
						Name = "Getting Settled (#3)",
						SubInfo = "Return to Pierre!",
						Icon = "rbxassetid://18409756966",
						Line1 = {
							Name = "Speak to Pierre",
							ValueBase = "BoolValue",
							Goal = true
						},
						AutoComplete = true,
						Rewards = {
							Coins = 0,
							XP = 300,
							Title = "None"
						},
						Tracker = "Tutorial3",
						Position = { createVector(391.994, 137, 196.592), "Pierre" },
						TypeOfQuest = "Tutorial3"
					})
					local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
					ReplicatedStorage2:WaitForChild("events"):WaitForChild("anno_thought"):FireClient(
						player,
						"<font color = '#feffb7'>Good work! Now return back to Pierre!</font>",
						"rbxassetid://11949235061",
						5
					)
				end
			end)
		elseif instance:FindFirstChild("Track").Value == "Tutorial4" then
			task.delay(4, function()
				if #Quest:Find(player, "Tutorial5", false) <= 0 then
					Quest:New(player, {
						Name = "Getting Settled (#5)",
						SubInfo = "Return to Pierre!",
						Icon = "rbxassetid://18409756966",
						Line1 = {
							Name = "Speak to Pierre",
							ValueBase = "BoolValue",
							Goal = true
						},
						AutoComplete = true,
						Rewards = {
							Coins = 250,
							XP = 350,
							Title = "The Clever"
						},
						Tracker = "Tutorial5",
						Position = { createVector(391.4, 137, 196.7), "Pierre" },
						TypeOfQuest = "Tutorial5"
					})
					local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
					ReplicatedStorage2:WaitForChild("events"):WaitForChild("anno_thought"):FireClient(
						player,
						"<font color = '#feffb7'>Good work! Now return back to Pierre!</font>",
						"rbxassetid://11949235061",
						5
					)
				end
			end)
		elseif instance:FindFirstChild("Track").Value == "baitQuest_Completed" then
			task.delay(3, function()
				if #Quest:Find(player, "Phineas2", false) <= 0 then
					Quest:New(player, {
						Name = "Phineas' Bait Quest (#2)",
						SubInfo = "Return to Phineas!",
						Icon = "rbxassetid://18409756966",
						Line1 = {
							Name = "Speak to Phineas",
							ValueBase = "BoolValue",
							Goal = true
						},
						AutoComplete = true,
						Rewards = {
							Coins = 0,
							XP = 400,
							Title = "None"
						},
						Position = { createVector(469.912, 152.193, 277.955), "Phineas" },
						TypeOfQuest = "Phineas2"
					})
					local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
					ReplicatedStorage2:WaitForChild("events"):WaitForChild("anno_thought"):FireClient(
						player,
						"Good work! Now return back to Phineas!",
						nil,
						5
					)
				end
			end)
		end
	end

	if instance:FindFirstChild("XPReward") and instance:FindFirstChild("XPReward").Value > 0 then
		level:GiveXP(player, instance:FindFirstChild("XPReward").Value)
	end

	if instance:FindFirstChild("CoinsReward") then
		local CurrencyService = require(game.ServerScriptService.server.legacyServices.CurrencyService)
		CurrencyService:Increase(player, instance:FindFirstChild("CoinsReward").Value)
	end

	if instance:FindFirstChild("TitleReward") and instance:FindFirstChild("TitleReward").Value ~= nil and instance:FindFirstChild("TitleReward").Value ~= "None" then
		titles:Give(player, instance:FindFirstChild("TitleReward").Value)
	end

	if not instance:FindFirstChild("DontTrack") then
		local tracker_quests = v:WaitForChild("Stats"):WaitForChild("tracker_quests")
		tracker_quests.Value += 1
	end

	ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_quest"):FireClient(
		player,
		(`"<font color='#a2eaa6'>{string.split(instance.Name, "_")[1]}</font>" was completed!`)
	)
	instance.Parent = ReplicatedStorage
	debris:AddItem(instance, 3)
end

function Quest:CheckComplete(instance)
	local count = 0
	local count2 = 0

	for _, child in pairs(instance:GetChildren()) do
		if not instance:FindFirstChild(child.Name .. "_Goal") then
			continue
		end

		count += 1
		local instance2 = instance:FindFirstChild(child.Name .. "_Goal")

		if child.Value == instance2.Value then
			count2 += 1
		elseif (typeof(instance2.Value) == "number" or instance2:IsA("NumberValue") or instance2:IsA("IntValue")) and child.Value >= instance2.Value then
			count2 += 1
		end
	end

	return count <= count2
end

function Quest:AutoComplete(p, instance)
	task.spawn(function()
		local v = false
		local v2 = true

		if character.PS(p) == nil then
			return
		end

		for _, child in pairs(instance:GetChildren()) do
			if not instance:FindFirstChild(child.Name .. "_Goal") then
				continue
			end

			instance:FindFirstChild(child.Name .. "_Goal")
			child.Changed:connect(function()
				local v3 = Quest:CheckComplete(instance)

				if v == true and v3 == true and v2 == true then
					v2 = false
					Quest:Complete(p, instance)
				end
			end)
			local v3 = Quest:CheckComplete(instance)

			if not (v == true and v3 == true and v2 == true) then
				continue
			end

			v2 = false
			Quest:Complete(p, instance)
		end

		v = true
		local v3 = Quest:CheckComplete(instance)

		if v == true and v3 == true and v2 == true then
			v2 = false
			Quest:Complete(p, instance)
		end
	end)
end

function Quest:New(p, state)
	task.spawn(function()
		local v = p and state and character.PS(p)

		if not v then
			return
		end

		if not state.Icon or state.Icon == nil then
			state.Icon = "rbxassetid://18162767851"
		end

		if state.TypeOfQuest and #Quest:Find(p, state.TypeOfQuest, false) > 0 and not state.CanHaveMultiple then
			return
		end

		local stringValue = Instance.new("StringValue")
		stringValue.Name = state.Name .. "_" .. math.random(111111, 999999)
		stringValue.Value = state.SubInfo
		local stringValue2 = Instance.new("StringValue")
		stringValue2.Value = state.Icon
		stringValue2.Name = "Icon"
		stringValue2.Parent = stringValue

		local function Line(p2)
			local instance = Instance.new("" .. state["Line" .. p2].ValueBase .. "")
			instance.Name = state["Line" .. p2].Name

			if instance:IsA("NumberValue") or instance:IsA("IntValue") == "NumerValue" then
				instance.Value = 0
			end

			instance.Parent = stringValue
			local instance2 = Instance.new("" .. state["Line" .. p2].ValueBase .. "")
			instance2.Name = state["Line" .. p2].Name .. "_Goal"
			instance2.Value = state["Line" .. p2].Goal
			instance2.Parent = stringValue
		end

		Line(1)

		if state.Line2 then
			Line(2)

			if state.Line3 then
				Line(3)
			end
		end

		if state.TypeOfQuest and state.TypeOfQuest ~= nil and state.TypeOfQuest ~= "None" then
			local stringValue3 = Instance.new("StringValue")
			stringValue3.Value = state.TypeOfQuest
			stringValue3.Name = "TypeOfQuest"
			stringValue3.Parent = stringValue
		end

		if state.Tracker then
			local stringValue3 = Instance.new("StringValue")
			stringValue3.Name = "Track"
			stringValue3.Value = state.Tracker
			stringValue3.Parent = stringValue
		end

		if state.Position then
			local stringValue3 = Instance.new("StringValue")

			if state.Position[2] and state.Position[2] ~= nil and state.Position[2] ~= "" then
				local stringValue4 = Instance.new("StringValue")
				stringValue4.Name = "PositionName"
				stringValue4.Value = state.Position[2]
				stringValue4.Parent = stringValue
			end

			stringValue3.Name = "Position"
			stringValue3.Value = "" .. state.Position[1].X .. "," .. state.Position[1].Y .. "," .. state.Position[1].Z
			stringValue3.Parent = stringValue
		end

		if state.AutoComplete and state.AutoComplete == true then
			local boolValue = Instance.new("BoolValue")
			boolValue.Value = true
			boolValue.Name = "AutoComplete"
			boolValue.Parent = stringValue
			Quest:AutoComplete(p, stringValue)
		end

		if state.Rewards then
			local intValue = Instance.new("IntValue")
			intValue.Value = state.Rewards.Coins or 0
			intValue.Name = "CoinsReward"
			intValue.Parent = stringValue
			local intValue2 = Instance.new("IntValue")
			intValue2.Value = state.Rewards.XP or 0
			intValue2.Name = "XPReward"
			intValue2.Parent = stringValue
			local stringValue3 = Instance.new("StringValue")
			stringValue3.Value = state.Rewards.Title or "None"
			stringValue3.Name = "TitleReward"
			stringValue3.Parent = stringValue
		end

		local boolValue = Instance.new("BoolValue")
		boolValue.Value = true
		boolValue.Name = "Tracking"
		boolValue.Parent = stringValue
		stringValue.Parent = v:WaitForChild("Quests")
		return stringValue
	end)
end

return Quest