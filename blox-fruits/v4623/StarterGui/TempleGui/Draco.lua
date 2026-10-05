local v = {
	Gear1 = {
		"Ancient Powers",
		"Upon transforming, receive MAX STATS as well as increased damage and speed, and heal by 10%."
	},
	Alpha = {
		"Thorn Mail",
		"Allows the user to reflect a portion of damage back. Increases defense of nearby allies.",
		"Damage reflected and allies defense greatly increased."
	},
	Omega = {
		"Cometic Field",
		"Allows the user and allies to apply explosive orbs. Increases damage of nearby allies.",
		"Orbs damage greatly increased."
	},
	Gear5 = { "Energy Training", [[
Improves transformation duration and energy gain.
<i><font color="#FFEB9B">Obtained from trainer.</font></i>]] }
}
local Util = require(game.ReplicatedStorage.Util)
local signal2 = Util.Signal2
local Effect = require(game.ReplicatedStorage.Effect)
local WaitForStream = require(game.ReplicatedStorage.Util.WaitForStream)

local function IsDraco()
	local data = game.Players.LocalPlayer:FindFirstChild("Data")

	if not data then
		return
	end

	local race = data:FindFirstChild("Race")

	if not (race and race:FindFirstChild("Evolved")) then
		return
	end

	if race.Value == "Draco" then
		return true
	end
end

local flag = false

if not workspace:WaitForChild("Map"):FindFirstChild("Waterfall") then
	local thread = coroutine.running()
	local childAddedConnection = nil
	childAddedConnection = workspace:WaitForChild("Map").ChildAdded:Connect(function(child)
		if child.Name == "Waterfall" then
			childAddedConnection:Disconnect()
			coroutine.resume(thread)
		end
	end)
	coroutine.yield()
end

local firepit = WaitForStream.workspace.Map.Waterfall.IslandModel.Firepit()
local maid = Util.Maid.new()
local raceDetails = nil

function ShowPopup(p, p2)
	if p == "Gear1" then
		game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TempleClock", "SpendPoint")
		return "Default"
	end

	local v2 = {}
	local v3

	if p == "Gear1" or p == "Gear5" then
		v3 = { "Default" }
	elseif p == "Gear4" then
		if raceDetails.A == 2 and raceDetails.B == 0 then
			v3 = { "Omega" }
		elseif raceDetails.B == 2 and raceDetails.A == 0 then
			v3 = { "Alpha" }
		elseif raceDetails.A == 1 and raceDetails.B == 1 then
			v3 = { "Alpha", "Omega" }
		else
			v3 = v2
		end
	elseif p2.GearType == "Alpha" and raceDetails.B < 2 then
		v3 = { "Omega" }
	elseif p2.GearType == "Omega" and raceDetails.A < 2 then
		v3 = { "Alpha" }
	else
		v3 = {}

		if raceDetails.A < 2 then
			table.insert(v3, "Alpha")
		end

		if raceDetails.B < 2 then
			table.insert(v3, "Omega")
		end

		local _ = #v3 == 0
	end

	for _, button in pairs(script.Parent.Popup.Gears:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		if table.find(v3, button.Name) then
			button.Visible = true
		else
			button.Visible = false
		end
	end

	script.Parent.Popup.Visible = true
	local v4 = signal2.new()
	local activatedConnection = script.Parent.Popup2.Info.Frame.Equip.Activated:Connect(function()
		v4:Fire(script.Parent.Popup2:GetAttribute("SelectedGear"))
	end)
	local activatedConnection2 = script.Parent.Popup.Info.Frame.Exit.Activated:Connect(function()
		v4:Fire(false)
	end)
	local v5 = v4:Wait()
	activatedConnection:Disconnect()
	activatedConnection2:Disconnect()
	script.Parent.Popup.Visible = false
	game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TempleClock", "SpendPoint", p, v5)
	return v5
end

local flag2 = false

for _, button in pairs(script.Parent.Popup.Gears:GetChildren()) do
	if not button:IsA("TextButton") then
		continue
	end

	local v2 = button
	button.Activated:Connect(function()
		local data = game.Players.LocalPlayer:FindFirstChild("Data")
		local v3

		if data then
			local race = data:FindFirstChild("Race")

			if race and race:FindFirstChild("Evolved") then
				v3 = race.Value == "Draco" or nil
			end
		end

		if not v3 then
			return
		end

		local total = 1

		if v2.Name == "Alpha" then
			total += raceDetails.A
		elseif v2.Name == "Omega" then
			total += raceDetails.B
		end

		script.Parent.Popup.Visible = false
		script.Parent.Popup2.Visible = true
		script.Parent.Popup2:SetAttribute("SelectedGear", v2.Name)

		if total == 2 then
			script.Parent.Popup2.Container.List.TextLabel.Text = "Upgrade: "
		else
			script.Parent.Popup2.Container.List.TextLabel.Text = ""
		end

		script.Parent.Popup2.Container.List.TextLabel.Text = script.Parent.Popup2.Container.List.TextLabel.Text .. (v[v2.Name][total + 1] or "Unsocket the current gear. Any effects granted by the current gear will be removed.")
		script.Parent.Popup2.Title.Text = v2.Name == "Blank" and "Unsocket" or v[v2.Name][1] .. " (Tier " .. total .. ")"

		if v2.Name == "Blank" then
			script.Parent.Popup2.Info.Frame.Equip.TextLabel.Text = "Continue"
		else
			script.Parent.Popup2.Info.Frame.Equip.TextLabel.Text = "Equip"
		end

		local activatedConnection = nil
		local activatedConnection2 = nil
		activatedConnection = script.Parent.Popup2.Info.Frame.Equip.Activated:Connect(function()
			script.Parent.Popup2.Visible = false
			activatedConnection:Disconnect()
			activatedConnection2:Disconnect()
		end)
		activatedConnection2 = script.Parent.Popup2.Info.Frame.Exit.Activated:Connect(function()
			script.Parent.Popup.Visible = true
			script.Parent.Popup2.Visible = false
			activatedConnection:Disconnect()
			activatedConnection2:Disconnect()
		end)
	end)
end

local proximityPrompt = firepit:WaitForChild("Fire", 1000000):WaitForChild("ProximityPrompt", 1000000)
proximityPrompt.MaxActivationDistance = 15
local changedConnection = nil
local diedConnection = nil

function EaseIn()
	local data = game.Players.LocalPlayer:FindFirstChild("Data")
	local v2

	if data then
		local race = data:FindFirstChild("Race")

		if race and race:FindFirstChild("Evolved") then
			v2 = race.Value == "Draco" or nil
		end
	end

	if not v2 or flag then
		return
	end

	flag = true
	maid:DoCleaning()
	local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

	if humanoid and humanoid.Health <= 0 then
		flag = false
		return
	end

	local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TempleClock", "Check")

	if v3.Race ~= "Draco" then
		flag = false
		return
	end

	local count = 0
	local count2 = 0

	for _, gear in pairs(v3.RaceDetails.Gears) do
		if gear == "A" then
			count2 += 1
		elseif gear == "B" then
			count += 1
		end
	end

	if count2 < v3.RaceDetails.A then
		for _ = count2 + 1, v3.RaceDetails.A do
			table.insert(v3.RaceDetails.Gears, "A")
		end
	end

	if count < v3.RaceDetails.B then
		for _ = count + 1, v3.RaceDetails.B do
			table.insert(v3.RaceDetails.Gears, "B")
		end
	end

	local busy = game.Players.LocalPlayer.Character:FindFirstChild("Busy")

	if busy then
		busy.Value = true

		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		changedConnection = busy.Changed:Connect(function()
			busy.Value = true
		end)
	end

	local humanoid2 = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

	if humanoid2 then
		if diedConnection then
			diedConnection:Disconnect()
			diedConnection = nil
		end

		diedConnection = humanoid2.Died:Connect(function()
			EaseOut()
		end)
	end

	script.Parent:SetAttribute("Draco", true)
	flag = true
	proximityPrompt:SetAttribute("On", true)
	local _ = v3.Race
	local hadPoint = v3.HadPoint == true
	local canSelect = v3.RaceLevel >= 2
	raceDetails = v3.RaceDetails
	local v5 = {
		Gear1 = {},
		Gear2 = {},
		Gear3 = {},
		Gear4 = {},
		Gear5 = {}
	}
	v5.Gear2.GearType = v3.RaceDetails.Gears[1] == "A" and "Alpha" or v3.RaceDetails.Gears[1] == "B" and "Omega" or "Blank"
	v5.Gear3.GearType = v3.RaceDetails.Gears[2] == "A" and "Alpha" or v3.RaceDetails.Gears[2] == "B" and "Omega" or "Blank"
	v5.Gear4.GearType = v3.RaceDetails.Gears[3] == "A" and "Alpha" or v3.RaceDetails.Gears[3] == "B" and "Omega" or "Blank"
	local gear2 = v5.Gear2
	gear2.Unlocked = v3.RaceDetails.A + v3.RaceDetails.B >= 0 and canSelect
	local gear3 = v5.Gear3
	gear3.Unlocked = v3.RaceDetails.A + v3.RaceDetails.B >= 1 and canSelect
	local gear4 = v5.Gear4
	gear4.Unlocked = v3.RaceDetails.A + v3.RaceDetails.B >= 2 and canSelect
	v5.Gear5.CanSelect = false
	v5.Gear5.Unlocked = false
	v5.Gear5.Color = "Black"

	if v3.RaceDetails.C >= 1 then
		v5.Gear5.Unlocked = true
		v5.Gear5.Color = "Orange"
	end

	v5.Gear1.Unlocked = true

	if canSelect then
		v5.Gear1.CanSelect = false
		v5.Gear1.GearType = "Default"
		v5.Gear1.Color = "Orange"
	else
		v5.Gear1.CanSelect = true
		v5.Gear1.GearType = "Blank"
		v5.Gear1.Color = "Gray"
		hadPoint = true
	end

	if hadPoint then
		local gear22 = v5.Gear2
		gear22.CanSelect = v3.RaceDetails.A + v3.RaceDetails.B == 0 and canSelect
		local gear32 = v5.Gear3
		gear32.CanSelect = v3.RaceDetails.A + v3.RaceDetails.B == 1 and canSelect
		local gear42 = v5.Gear4

		if not (v3.RaceDetails.A + v3.RaceDetails.B >= 2) then
			canSelect = false
		end

		gear42.CanSelect = canSelect

		if v3.RaceDetails.A + v3.RaceDetails.B >= 3 then
			v5.Gear2.CanSelect = true
			v5.Gear3.CanSelect = true
			v5.Gear4.CanSelect = true

			if v5.Gear2.GearType == "Alpha" and v5.Gear3.GearType == "Alpha" and v5.Gear4.GearType == "Omega" then
				v5.Gear4.CanSelect = false
			elseif v5.Gear2.GearType == "Omega" and v5.Gear3.GearType == "Omega" and v5.Gear4.GearType == "Alpha" then
				v5.Gear4.CanSelect = false
			elseif v5.Gear2.GearType == "Alpha" and v5.Gear3.GearType == "Omega" and v5.Gear4.GearType == "Omega" then
				v5.Gear4.CanSelect = false
				v5.Gear2.CanSelect = false
			elseif v5.Gear2.GearType == "Omega" and v5.Gear3.GearType == "Alpha" and v5.Gear4.GearType == "Omega" then
				v5.Gear4.CanSelect = false
				v5.Gear3.CanSelect = false
			elseif v5.Gear2.GearType == "Omega" and v5.Gear3.GearType == "Alpha" and v5.Gear4.GearType == "Alpha" then
				v5.Gear4.CanSelect = false
				v5.Gear2.CanSelect = false
			elseif v5.Gear2.GearType == "Alpha" and v5.Gear3.GearType == "Omega" and v5.Gear4.GearType == "Alpha" then
				v5.Gear4.CanSelect = false
				v5.Gear3.CanSelect = false
			end
		end
	else
		v5.Gear2.CanSelect = false
		v5.Gear3.CanSelect = false
		v5.Gear4.CanSelect = false
	end

	for i = 2, 4 do
		local v9 = v5["Gear" .. i]

		if v9.GearType == "Blank" then
			if v9.CanSelect then
				v9.Color = "Gray"
			else
				v9.Color = "Black"
			end
		elseif v9.GearType == "Alpha" then
			v9.Color = "Red"
		else
			v9.Color = "Blue"
		end
	end

	local colors = {}
	table.insert(colors, v5["Gear" .. 1].Color)
	table.insert(colors, v5["Gear" .. 2].Color)
	table.insert(colors, v5["Gear" .. 3].Color)
	table.insert(colors, v5["Gear" .. 4].Color)
	table.insert(colors, v5["Gear" .. 5].Color)

	if hadPoint then
		script.Parent.Title.TextLabel.Text = "Choose an ember to replace."
		script.Parent.Title.TextLabel.TextLabel.Text = "Choose an ember to replace."
	else
		script.Parent.Title.TextLabel.Text = "Come back when you complete the trial again."
		script.Parent.Title.TextLabel.TextLabel.Text = "Come back when you complete the trial again."
	end

	Effect.new("DracoRace.GearSelect"):replicate({
		Enabled = true,
		Bindable = script.Bindable,
		SpriteColors = colors
	})
	local v9 = {
		false,
		false,
		false,
		false,
		false
	}
	local thread = coroutine.running()
	local eventConnection = nil
	eventConnection = script.Bindable.Event:Connect(function(p, p2, p3)
		if p == "FinishedEffect" then
			v9[p2] = p3

			if v9[1] and v9[2] and v9[3] and v9[4] and v9[5] then
				eventConnection:Disconnect()
				coroutine.resume(thread)
			end
		end
	end)
	coroutine.yield()
	script.Parent.Enabled = true
	local title = script.Parent.Title
	local GuiService = game:GetService("GuiService")
	title.Position = UDim2.fromOffset(0, -GuiService:GetGuiInset().Y)

	for k, v10 in pairs(v9) do
		local worldToScreenPoint = workspace.CurrentCamera:WorldToScreenPoint(v10.Position)
		script.Parent.GearButtons["Gear" .. k].Position = UDim2.fromOffset(worldToScreenPoint.X, worldToScreenPoint.Y)
		script.Parent.GearButtons["Gear" .. k].AnchorPoint = Vector2.new(0.5, 0.5)
	end

	for i, child in pairs(script.Parent.GearButtons:GetChildren()) do
		local v10 = child
		local v11 = i

		local function UpdateDescription()
			if flag2 then
				return
			end

			script.Parent.Description.Title.Text = "<u>Gear " .. v10.Text .. "</u>"
			script.Parent.Description.Title.Title.Text = "<u>Gear " .. v10.Text .. "</u>"
			local v12 = v5["Gear" .. v11]
			local v13 = v11 ~= 1 and v11 ~= 5 and "" or "Gear" .. v11
			local A = 0

			if v12.GearType == "Alpha" then
				A = raceDetails.A
			elseif v12.GearType == "Omega" then
				A = raceDetails.B
			end

			if v[v13] then
				script.Parent.Description.TextLabel.Text = v[v13][2]

				if v13 == "Gear5" and raceDetails.C >= 1 then
					script.Parent.Description.Title.Text = "<u>" .. v.Gear5[1] .. " (Tier " .. raceDetails.C .. ")</u>"
				else
					script.Parent.Description.Title.Text = "<u>" .. v[v13][1] .. "</u>"
				end

				script.Parent.Description.Title.Title.Text = script.Parent.Description.Title.Text
			elseif v12.GearType and v[v12.GearType] then
				script.Parent.Description.TextLabel.Text = v[v12.GearType][2]

				if A == 2 then
					script.Parent.Description.TextLabel.Text = script.Parent.Description.TextLabel.Text .. "\n<font color=\"#e1ad01\">Upgrade:</font> " .. v[v12.GearType][3]
				else
					script.Parent.Description.TextLabel.Text = script.Parent.Description.TextLabel.Text .. "\n<font color=\"#e1ad01\">Upgrade:</font> [LOCKED]"
				end

				script.Parent.Description.Title.Text = "<u>" .. v[v12.GearType][1] .. " (Tier " .. A .. ")</u>"
				script.Parent.Description.Title.Title.Text = script.Parent.Description.Title.Text
			elseif v12.Unlocked then
				if v12.CanSelect then
					script.Parent.Description.TextLabel.Text = [[

<font color="#a7d6ff">Click to convert to a new ember.</font>
]]
				else
					script.Parent.Description.TextLabel.Text = [[

<font color="#ff6164">You can convert this ember after beating the trial again.</font>
]]
				end
			else
				script.Parent.Description.TextLabel.Text = [[

Clear more trials to unlock this slot.
]]
			end

			if not v12.Unlocked then
				script.Parent.Description.Title.Text ..= " [LOCKED]"
				script.Parent.Description.Title.Title.Text ..= "<font color=\"#FF0000\"> [LOCKED]</font>"
			end
		end

		local v12 = child
		local UpdateDescription2 = UpdateDescription
		maid:GiveTask(child.MouseEnter:Connect(function()
			local data2 = game.Players.LocalPlayer:FindFirstChild("Data")
			local v13

			if data2 then
				local race = data2:FindFirstChild("Race")

				if race and race:FindFirstChild("Evolved") then
					v13 = race.Value == "Draco" or nil
				end
			end

			if not v13 then
				return
			end

			script.Bindable:Fire("Hover", (tonumber(v12.Name:sub(5))))
			UpdateDescription2()
			script.Parent.Description.Visible = true
		end))
		local v13 = i
		local v14 = child
		local UpdateDescription3 = UpdateDescription
		maid:GiveTask(child.Activated:Connect(function()
			local data2 = game.Players.LocalPlayer:FindFirstChild("Data")
			local v15

			if data2 then
				local race = data2:FindFirstChild("Race")

				if race and race:FindFirstChild("Evolved") then
					v15 = race.Value == "Draco" or nil
				end
			end

			if not v15 then
				return
			end

			local v16 = v5["Gear" .. v13]

			if v16.CanSelect then
				script.Parent.GearButtons.Visible = false
				flag2 = true
				local v17 = ShowPopup("Gear" .. v13, v16)
				flag2 = false
				script.Parent.GearButtons.Visible = true

				if v17 then
					if v17 == "Omega" then
						script.Bindable:Fire("ChangeColor", tonumber(v14.Name:sub(5)), "Blue", 0.5)

						if v16.GearType == "Alpha" then
							raceDetails.A -= 1
						end

						v16.GearType = "Omega"
						v16.CanSelect = false
						raceDetails.B += 1
					elseif v17 == "Alpha" then
						script.Bindable:Fire("ChangeColor", tonumber(v14.Name:sub(5)), "Red", 0.5)

						if v16.GearType == "Omega" then
							raceDetails.B -= 1
						end

						v16.GearType = "Alpha"
						v16.CanSelect = false
						raceDetails.A += 1
					elseif v17 == "Default" then
						script.Bindable:Fire("ChangeColor", tonumber(v14.Name:sub(5)), "Orange", 0.5)
						v16.CanSelect = false
					end

					v16.Unlocked = true
					UpdateDescription3()
					script.Parent.Title.TextLabel.Text = "Come back when you complete the trial again."
					script.Parent.Title.TextLabel.TextLabel.Text = "Come back when you complete the trial again."
				end
			end
		end))
		local v15 = child
		maid:GiveTask(child.MouseLeave:Connect(function()
			script.Bindable:Fire("StopHover", (tonumber(v15.Name:sub(5))))
			script.Parent.Description.Visible = false
		end))
	end
end

function EaseOut()
	local data = game.Players.LocalPlayer:FindFirstChild("Data")
	local v2

	if data then
		local race = data:FindFirstChild("Race")

		if race and race:FindFirstChild("Evolved") then
			v2 = race.Value == "Draco" or nil
		end
	end

	if not (v2 and flag) then
		return
	end

	maid:DoCleaning()
	Effect.new("DracoRace.GearSelect"):replicate({
		Enabled = false
	})
	script.Parent.Enabled = false

	if changedConnection then
		changedConnection:Disconnect()
		changedConnection = nil
	end

	if diedConnection then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	local busy = game.Players.LocalPlayer.Character:FindFirstChild("Busy")

	if busy then
		busy.Value = false
	end

	script.Parent:SetAttribute("Draco", false)
	flag = false
	proximityPrompt:SetAttribute("On", false)
end

local maid2 = Util.Maid.new()

local function CharacterAdded(character)
	maid2:DoCleaning()

	local function Update()
		if proximityPrompt:GetAttribute("On") then
			proximityPrompt.Enabled = false
		elseif character:FindFirstChild("ValidDracoRoom") or character:FindFirstChild("RaceEnergy") and game.Players.LocalPlayer:FindFirstChild("Data") and game.Players.LocalPlayer.Data:FindFirstChild("Race") and game.Players.LocalPlayer.Data.Race.Value == "Draco" then
			proximityPrompt.Enabled = true
		else
			proximityPrompt.Enabled = false
		end
	end

	maid2:GiveTask(proximityPrompt:GetAttributeChangedSignal("On"):Connect(Update))
	maid2:GiveTask(character.ChildAdded:Connect(Update))
	maid2:GiveTask(character.ChildRemoved:Connect(Update))
	Update()
end

if game.Players.LocalPlayer.Character then
	CharacterAdded(game.Players.LocalPlayer.Character)
end

game.Players.LocalPlayer.CharacterAdded:Connect(CharacterAdded)
script.Parent.Skip.TextButton.Activated:Connect(EaseOut)
proximityPrompt.Triggered:Connect(function()
	local data = game.Players.LocalPlayer:FindFirstChild("Data")
	local v2

	if data then
		local race = data:FindFirstChild("Race")

		if race and race:FindFirstChild("Evolved") then
			v2 = race.Value == "Draco" or nil
		end
	end

	if not v2 then
		return
	end

	EaseIn()
end)