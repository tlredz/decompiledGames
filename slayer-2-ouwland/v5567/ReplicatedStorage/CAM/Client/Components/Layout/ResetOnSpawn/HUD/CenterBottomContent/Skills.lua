local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Skills_Provider = require(ReplicatedStorage.CAM.Client.Controllers.Skills_Provider)
local clear = table.clear
local Skill = require(script.Skill)
local SkillSlot = require(ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.Mobile.SkillSlot)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Skill_Switch_Adder = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local Skill_Controller = require(ReplicatedStorage.CAM.Client.Controllers.Skill_Controller)
local typeof2 = typeof
game:GetService("UserInputService")
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local StatsFetch = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.StatsFetch)
local clock = os.clock
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local HoverInfo = require(ReplicatedStorage.CAM.Client.Modules.HoverInfo)
local Checklists = require(ReplicatedStorage.CAM.Client.Modules.Checklists)
require(ReplicatedStorage.Packages.faye)
local SkillStats = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.StatsFetch.Modules.SkillStats)
local manage_cd = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.manage_cd)
local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
game:GetService("GuiService")
local v = {
	"Skills_1st",
	"Skills_2nd",
	"Skills_3rd",
	"Skills_4th",
	"Skills_5th",
	"Skills_6th",
	"Skills_7th",
	"Skills_8th",
	"Skills_9th",
	"Skills_10th"
}
local v2 = {}

for k, v3 in v do
	for _, v4 in InputHandler.GetMapping(v3) or {} do
		if typeof(v4) == "table" and v4.Modifier == Enum.KeyCode.ButtonL1 then
			v2[k] = true
		end
	end
end

local clone = table.clone(Utility.Cancel_Values)
return function(maid, parent, _, p2)
	local v3 = {}

	local function claimBlock()
		local gui = nil

		for _, v4 in v3 do
			if not (v4.Name == "Blocking" and v4.Gui ~= nil and v4.Enabled:Get() == true) then
				continue
			end

			gui = v4.Gui
		end

		for _, v4 in v3 do
			if v4.Gui ~= nil and v4.Gui ~= gui then
				Checklists.Claim("Block", v4.Gui, false)
			end
		end

		if gui ~= nil then
			Checklists.Claim("Block", gui, true)
		end
	end

	local v4 = {}
	local v5 = {}
	local v6 = {}

	for i = 1, 10 do
		local v7 = i
		v3[i] = {
			OnGui = function(gui, p3)
				local v8 = v3[v7]

				if gui == nil and v8.Gui ~= p3 then
					return
				end

				if v8.Gui ~= nil and v8.Gui ~= gui then
					Checklists.Claim("Block", v8.Gui, false)
				end

				v8.Gui = gui
				claimBlock()
			end,
			Enabled = maid:Value(false),
			Key = v[i],
			Icon = maid:Value(""),
			Name = "",
			CoolDownCurrent = false,
			CoolDown = maid:Value(false),
			SkillStats = {},
			Hover = HoverInfo.new(nil, ""),
			Switch = maid:Value(false),
			Locked = maid:Value(true),
			SplitHere = maid:Value(nil),
			Holding = {
				Is = false,
				HoldingState = maid:Value(false),
				Rotation = maid:Value(0)
			}
		}
	end

	local onPad = maid:Value(Platform_Handler.IsGamepad())
	maid:Connect(Platform_Handler.Platform.Changed.Event, function()
		onPad:Set(Platform_Handler.IsGamepad())
	end)
	local anyHolding = maid:Value(false)

	local function refreshAnyHolding()
		local name = nil

		for i = 1, 10 do
			if not (v3[i] ~= nil and v3[i].Holding.Is == true) then
				continue
			end

			name = v3[i].Name
			break
		end

		anyHolding:Set(name ~= nil)
		local character = localPlayer.Character

		for i = 1, 10 do
			local v7 = v3[i]

			if v7 == nil then
				continue
			end

			local v8

			if name == nil or character == nil or v7.Name == nil or v7.Name == "" or v7.Name == name then
				v8 = false
			else
				local canPlayOver, v9 = StatsFetch.CanPlayOver(character, v7.Name, name)

				if canPlayOver == true then
					v8 = v9 == true
				else
					v8 = false
				end
			end

			v7.PlaysOverHeld:Set(v8)
		end
	end

	for i = 1, 10 do
		v3[i].OnPad = onPad
		v3[i].AnyHolding = anyHolding
		v3[i].PlaysOverHeld = maid:Value(false)
	end

	maid:Connect(localPlayer.ChildAdded, function(p3)
		if v4[p3.Name] ~= nil then
			local name = p3.Name
			local v7 = v4[name]
			local v8 = localPlayer:FindFirstChild(name) ~= nil
			v3[v7].Switch:Set(v8)
		end
	end)
	maid:Connect(localPlayer.ChildRemoved, function(p3)
		if v4[p3.Name] ~= nil then
			local name = p3.Name
			local v7 = v4[name]
			local v8 = localPlayer:FindFirstChild(name) ~= nil
			v3[v7].Switch:Set(v8)
		end
	end)

	local function updateSkills(list)
		clear(v4)
		clear(v5)
		local count = 0

		for i = 1, 10 do
			if list[i] ~= nil then
				count += 1
			end
		end

		local count2 = 0

		for i = 1, 10 do
			local v7 = v3[i]
			local v8 = list[i]
			clear(v7.SkillStats)

			if v8 == nil then
				v7.Name = ""
				v7.Hover:Refresh(nil, "", nil)
				v7.Hover:Hide()
				v7.FilteredSkillName = nil
				v6[i] = nil
				v7.Switch:Reset()
				v7.SplitHere:Reset()
				v7.Enabled:Set(false)
			else
				count2 += 1
				v7.VisualIndex = count2
				v7.EnabledCount = count
				local v9 = SkillStats.Get(v8.Name)

				if v9 then
					for k, icon in SkillStats.Icons do
						local v10 = nil

						if k == "skills_to_play_over" then
							if v9.skills_to_play_over and v9.skills_to_play_over.Blocking == true then
								v10 = icon
							end
						elseif v9[k] then
							v10 = icon
						end

						if v10 ~= nil then
							table.insert(v7.SkillStats, v10)
						end
					end
				end

				v7.Hover:Refresh(nil, v8.Name, v7.SkillStats)
				v4[v8.Name .. Skill_Switch_Adder.extension] = i
				v5[v8.Name] = i

				if v7.Name ~= v8.Name then
					v6[i] = nil
				end

				v7.FilteredSkillName = manage_cd.filter_cd_name(localPlayer, v8.Name)
				v7.Switch:Reset()
				v7.Icon:Set(v8.icon or "")
				v7.Name = v8.Name
				v7.Holding.Rotation:Reset()
				v7.Holding.HoldingState:Reset()
				v7.Max = v8.Max_Hold
				local _, v10 = Stats.GetRequirements(localPlayer, v8.Name)
				v7.Locked:Set(not v10)
				v7.SplitHere:Set(v8.SplitHere or nil)
				v7.Enabled:Set(true)
			end
		end

		for childName in v4 do
			local v7 = v4[childName]
			local v8 = localPlayer:FindFirstChild(childName) ~= nil
			v3[v7].Switch:Set(v8)
		end

		if list[1] == nil then
			game.ReplicatedStorage.CAM.Client.Components.Layout.Visibility.HUD.Skills.Value = 0
		end

		claimBlock()
	end

	updateSkills(Skills_Provider.get_current_keys())
	maid:Connect(Skills_Provider.Keys_Changed, updateSkills)
	local v7 = nil
	maid:Connect(Utility.getvaluesfolder(localPlayer).ChildAdded, function(instance)
		if instance.Name == "Stun" and StatsFetch.HasStunBypass(localPlayer.Character) then
			return
		end

		if instance.Name ~= "Strict_Stun" and instance:GetAttribute("Counter") ~= true and StatsFetch.HasCancelBypass(localPlayer.Character) then
			return
		end

		if clone[instance.Name] and v7 ~= nil and v7.Value ~= "" then
			Skill_Controller.Canceld = true
			local v8 = v5[v7.Value]

			if v8 ~= nil and InputHandler.IsDown(v[v8]) then
				v6[v8] = true
			end
		end
	end)

	local function tryHold(p3: number, name: string?)
		local v8 = v3[p3]

		if v8 == nil or v8.Enabled.Value ~= true then
			return false
		end

		local name2 = v8.Name

		if name2 == nil or typeof2(name2) ~= "string" or name2 == "" then
			return false
		end

		local child = localPlayer:FindFirstChild(name2 .. Skill_Switch_Adder.extension)
		local v9

		if child == nil then
			v9 = false
		else
			v9 = child:FindFirstChild("Disabled") == nil
		end

		if not Skill_Controller.Attempt_Hold(name2, name) then
			return v9
		end

		Skill_Controller.CurrentMax = v8.Max
		Skill_Controller.HeldSkill = v8.Name
		return true
	end

	local count = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function replay(_: string)
		count += 1
		local v8 = count
		task.spawn(function()
			for _ = 1, 16 do
				local v9 = false

				for i = 1, 10 do
					if not (v6[i] and InputHandler.IsDown(v[i])) then
						continue
					end

					local heldInput = InputHandler.HeldInput(v[i])

					if tryHold(i, heldInput and heldInput.Name) then
						v6[i] = nil
						return
					else
						v9 = true
					end
				end

				if not v9 then
					break
				end

				task.wait(0.05)

				if v8 ~= count or not maid.IsActive then
					break
				end
			end
		end)
	end

	for i = 1, 10 do
		local v8 = i
		maid:Add(InputHandler.ListenTo(v[i], function(p3, p4, p5)
			local v9 = v3[v8]

			if v9 == nil then
				return
			end

			local name = v9.Name

			if name == nil or typeof2(name) ~= "string" or name == "" then
				return
			end

			if p3 == "Down" then
				if p4 then
					return
				end

				local name2

				if p5 ~= nil then
					name2 = p5.KeyCode.Name
				end

				if name2 ~= nil and v2[v8] and Platform_Handler.IsGamepad() then
					name2 ..= "+" .. Enum.KeyCode.ButtonL1.Name
				end

				if tryHold(v8, name2) then
					v6[v8] = nil
					return
				end

				v6[v8] = true

				if InputHandler.IsAvailable() then
					replay() -- equivalent call inferred; original call site unknown
				end
			elseif p3 == "Up" then
				v6[v8] = nil

				if p5 == nil then
					local SHC = localPlayer.Character and localPlayer.Character:FindFirstChild("SHC")

					if SHC ~= nil and SHC.Value == name then
						Skill_Controller.UnHoldBoolean = true
					end
				end
			end
		end), true)
	end

	maid:Add(InputHandler.Available:Connect(function(flag: boolean)
		if flag then
			replay() -- equivalent call inferred; original call site unknown
		end
	end), true)
	maid:Add(InputHandler.ListenTo("Screen", function(p3)
		if p3 == "Up" then
			replay() -- equivalent call inferred; original call site unknown
		end
	end), true)
	maid:Add(InputHandler.ListenTo("Combat", function(p3)
		if p3 == "Up" then
			replay() -- equivalent call inferred; original call site unknown
		end
	end), true)
	task.spawn(function()
		while maid.IsActive do
			local character = localPlayer.Character
			local v8

			if character ~= nil then
				v8 = character:FindFirstChild("SHC")
			end

			v7 = v8

			if v7 ~= nil then
				local currentMax = Skill_Controller.CurrentMax
				local v9 = nil

				for i = 1, 10 do
					local v10 = v3[i]

					if not (v10 ~= nil and v10.Enabled.Value) then
						continue
					end

					local is

					if v7.Value == nil or v7.Value == "" then
						is = false
					else
						is = v7.Value == v10.Name
					end

					if is == true then
						local last_performed = v7:GetAttribute("last_performed")

						if last_performed ~= nil and currentMax ~= nil then
							v9 = v9 or clock() - last_performed

							if v10.Holding.Is == true then
								v10.Holding.Rotation:Set(v9 / currentMax * 360)
							end
						end
					end

					local child = v7:FindFirstChild(v10.FilteredSkillName or v10.Name)
					local coolDownCurrent = child ~= nil

					if v10.CoolDownCurrent ~= coolDownCurrent then
						v10.CoolDownCurrent = coolDownCurrent
						v10.CoolDown:Set(coolDownCurrent)
					end

					if coolDownCurrent then
						local started = child:GetAttribute("Started")

						if type(started) == "number" and child.Value > 0 then
							local v13 = (clock() - started) / child.Value
							v10.Holding.Rotation:Set((1 - v13) * 360)
						end
					end

					if v10.Holding.Is == is then
						continue
					end

					v10.Holding.Is = is
					v10.Holding.HoldingState:Set(is)
					refreshAnyHolding()

					if is == true then
						v10.HoldStartedAt = clock()
					elseif InputHandler.IsDown(v[i]) then
						local v13 = clock() - (v10.HoldStartedAt or 0)
						local v14

						if v10.Max == nil or not (v10.Max > 0) then
							v14 = false
						else
							v14 = v10.Max - 0.25 <= v13
						end

						if not v14 then
							v6[i] = true
							replay() -- equivalent call inferred; original call site unknown
						end
					end
				end
			end

			task.wait(0.05)
		end
	end)

	if p2 == nil then
		return maid:Create("Frame")({
			Name = "SkillsHolder",
			Parent = parent,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 0.93, -5),
			Size = UDim2.fromScale(0.25, 0.25),
			maid:Create("UIAspectRatioConstraint")({}),
			maid:Create("UIListLayout")({
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.1, 0),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			BackgroundTransparency = 1,
			maid:Iterate(v3, function(p3, p4, p5)
				return Skill(p5, p3, p4)
			end)
		})
	end

	for k, v8 in v3 do
		local parent2 = p2[Utility.numberToWords(k)]

		if parent2 ~= nil then
			maid:Create("Frame")({
				Parent = parent2,
				Name = "Slot",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				SkillSlot(maid, k, v8)
			})
		end
	end
end