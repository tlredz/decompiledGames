local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local global = CAM:WaitForChild("Global")
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local Character_info_provider = require(global:WaitForChild("Character_info_provider"))
local Items = require(global:WaitForChild("Collectibles"):WaitForChild("Items"))
local ClanSkills = require(CAM:WaitForChild("Clans"):WaitForChild("ClanSkills"))
local FightingStyles = require(global:WaitForChild("Collectibles"):WaitForChild("FightingStyles"))
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local PlayerProgression = require(ReplicatedStorage.CAM.Global.PlayerProgression)
local Resolve = require(ReplicatedStorage.CAM.Global.Powers.Resolve)
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()
local SkillsProvider = {
	Keys_Changed = simplesignal.new(),
	ModeBarFull = function()
		local getvaluesfolder = Utility.getvaluesfolder(Players.LocalPlayer)
		local modeBar = getvaluesfolder ~= nil and getvaluesfolder:FindFirstChild("ModeBar") or nil
		return modeBar ~= nil and modeBar.Value >= modeBar.MaxValue
	end
}
local v = {}

function SkillsProvider.AuraActive(childName: string)
	local getvaluesfolder = Utility.getvaluesfolder(Players.LocalPlayer)
	return getvaluesfolder ~= nil and getvaluesfolder:FindFirstChild(childName) ~= nil
end

function SkillsProvider.IsHeld(p: string)
	local character = Players.LocalPlayer.Character
	local SHC

	if character ~= nil then
		SHC = character:FindFirstChild("SHC") or nil
	end

	return SHC ~= nil and SHC.Value == p
end

local default = Menum.skillState.Default
local v2 = false
local v3 = nil
local v4 = nil
local v5 = nil
local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local v6 = false

local function upd_keys()
	local character = localPlayer.Character

	if character then
		local SHC = character:FindFirstChild("SHC")

		if SHC and (SHC:GetAttribute("en") == true or SHC.Value ~= "") then
			local value = SHC.Value

			if value ~= "" and SHC:GetAttribute("en") ~= true then
				local v7 = false

				for _, v9 in SkillsProvider.get_current_keys() do
					if v9.Name ~= value then
						continue
					end

					v7 = true
					break
				end

				if not v7 then
					v6 = true
					local Skill_Controller = require(script.Parent.Skill_Controller)
					Skill_Controller.StopHold(value)
					return
				end
			end

			v6 = true
			return
		end
	end

	v6 = false
	local get_current_keys = SkillsProvider.get_current_keys()
	SkillsProvider.Keys_Changed:Fire(get_current_keys)
end

local items_Config = localPlayer:WaitForChild("Items_Config")
data:WaitForChild("Powers")
items_Config:WaitForChild("Equipped").Changed:Connect(upd_keys)

for _, child in pairs(data.Powers:GetChildren()) do
	child.Changed:connect(upd_keys)
end

for _, child in data.Inventory.Toolbar:GetChildren() do
	local v8

	if child.Name == "One" then
		v8 = 1
	elseif child.Name == "Two" then
		v8 = 2
	elseif child.Name == "Three" then
		v8 = 3
	else
		v8 = false
	end

	child.Changed:Connect(function()
		if v8 == items_Config.Equipped.Value then
			upd_keys()
		end
	end)
end

local function watchValue(instance, childName: string)
	local function bind(valueBase)
		if valueBase.Name ~= childName or not valueBase:IsA("ValueBase") then
			return
		end

		valueBase:GetPropertyChangedSignal("Value"):Connect(upd_keys)
	end

	local valueBase = instance:FindFirstChild(childName)

	if valueBase ~= nil and valueBase.Name == childName and valueBase:IsA("ValueBase") then
		valueBase:GetPropertyChangedSignal("Value"):Connect(upd_keys)
	end

	instance.ChildAdded:Connect(bind)
end

local v7 = "Clan"

local function bind(valueBase)
	if valueBase.Name ~= v7 or not valueBase:IsA("ValueBase") then
		return
	end

	valueBase:GetPropertyChangedSignal("Value"):Connect(upd_keys)
end

local clan = data:FindFirstChild("Clan")

if clan ~= nil and clan.Name == "Clan" and clan:IsA("ValueBase") then
	clan:GetPropertyChangedSignal("Value"):Connect(upd_keys)
end

data.ChildAdded:Connect(bind)
local v8 = "Race"

local function bind2(valueBase)
	if valueBase.Name ~= v8 or not valueBase:IsA("ValueBase") then
		return
	end

	valueBase:GetPropertyChangedSignal("Value"):Connect(upd_keys)
end

local race = data:FindFirstChild("Race")

if race ~= nil and race.Name == "Race" and race:IsA("ValueBase") then
	race:GetPropertyChangedSignal("Value"):Connect(upd_keys)
end

data.ChildAdded:Connect(bind2)
local progression = data:WaitForChild("Progression", 10)

if progression ~= nil then
	for _, childName in PlayerProgression.Sides do
		local child = progression:WaitForChild(childName, 10)

		if child == nil then
			continue
		end

		local v10 = "Max"

		local function bind3(valueBase)
			if valueBase.Name ~= v10 or not valueBase:IsA("ValueBase") then
				return
			end

			valueBase:GetPropertyChangedSignal("Value"):Connect(upd_keys)
		end

		local max = child:FindFirstChild("Max")

		if max ~= nil and max.Name == "Max" and max:IsA("ValueBase") then
			max:GetPropertyChangedSignal("Value"):Connect(upd_keys)
		end

		child.ChildAdded:Connect(bind3)
	end
end

local v9 = false

local function bindModeBar(intConstrainedValue, flag: boolean?)
	if intConstrainedValue.Name ~= "ModeBar" or not intConstrainedValue:IsA("IntConstrainedValue") then
		return
	end

	v9 = intConstrainedValue.Value >= intConstrainedValue.MaxValue
	intConstrainedValue.Changed:Connect(function()
		local v10 = intConstrainedValue.Value >= intConstrainedValue.MaxValue

		if v10 == v9 then
			return
		end

		v9 = v10
		upd_keys()
	end)

	if flag then
		upd_keys()
	end
end

local modeBar = getvaluesfolder:FindFirstChild("ModeBar")

if modeBar ~= nil and modeBar.Name == "ModeBar" and modeBar:IsA("IntConstrainedValue") then
	if modeBar.Value >= modeBar.MaxValue then
		v9 = true
	else
		v9 = false
	end

	modeBar.Changed:Connect(function()
		local v10 = modeBar.Value >= modeBar.MaxValue

		if v10 == v9 then
			return
		end

		v9 = v10
		upd_keys()
	end)
end

getvaluesfolder.ChildAdded:Connect(function(child)
	bindModeBar(child, true)

	if v[child.Name] then
		upd_keys()
	end
end)
getvaluesfolder.ChildRemoved:Connect(function(child)
	if child.Name == "ModeBar" then
		v9 = false
		upd_keys()
	end

	if v[child.Name] then
		upd_keys()
	end
end)
local v10 = cleanit.new()
local v11 = 0

function UpdDMG()
	v10:Clean()
	v11 = 0
	local DMG = getvaluesfolder:FindFirstChild("DMG")
	local UpdDMGState

	UpdDMGState = function()
		local v12 = math.random(1, 999)
		v11 = v12
		local v13 = nil

		if DMG ~= nil and DMG:GetAttribute("EngagedUsing") == "Fist" then
			local v14 = Utility.Tick() - DMG:GetAttribute("LastEngaged")

			if v14 < 2 then
				task.delay(2 - v14, function()
					if v12 == v11 then
						UpdDMGState()
					end
				end)
				v13 = true
			end
		end

		if default ~= v13 then
			default = v13

			if v2 then
				upd_keys()
			end
		end
	end

	UpdDMGState()
	v10:Connect(DMG:GetAttributeChangedSignal("AttackerUsed"), UpdDMGState)
	v10:Connect(DMG:GetAttributeChangedSignal("EngagedUsing"), UpdDMGState)
	v10:Connect(DMG:GetAttributeChangedSignal("LastEngaged"), UpdDMGState)
end

if getvaluesfolder:FindFirstChild("DMG") ~= nil then
	UpdDMG()
end

local function updCustomState()
	local v12, v13

	if getvaluesfolder:FindFirstChild("CustomSkillState") ~= nil then
		v12 = ""
		v13 = {}

		for _, v14 in ipairs(getvaluesfolder:QueryDescendants("#CustomSkillState")) do
			local skill = v14:GetAttribute("Skill")
			local value = v14.Value
			v12 ..= skill .. value
			v13[skill] = value
		end
	end

	if v12 ~= v5 then
		v5 = v12
		v4 = v13
		upd_keys()
	end
end

getvaluesfolder.ChildAdded:Connect(function(child)
	if child.Name == "DMG" then
		UpdDMG()
	elseif child.Name == "CustomSkillState" then
		updCustomState()
	end
end)
getvaluesfolder.ChildRemoved:Connect(function(child)
	if child.Name == "CustomSkillState" then
		updCustomState()
	end
end)

local function updChar(character)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 3)

	if humanoidRootPart == nil then
		return
	end

	v3 = false
	local v12 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updv()
		local v13 = not v12 and humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil

		if v13 ~= v3 then
			v3 = v13
			upd_keys()
		end
	end

	local childAddedConnection = nil

	local function updSHC()
		if childAddedConnection ~= nil then
			childAddedConnection:Disconnect()
		end

		local SHC = character.SHC
		SHC.Changed:Connect(function(p)
			local v13 = p ~= ""

			if v12 ~= v13 then
				v12 = v13
				updv() -- equivalent call inferred; original call site unknown
			end

			if not v13 and v6 then
				upd_keys()
			end
		end)
		SHC:GetAttributeChangedSignal("en"):Connect(function()
			if SHC:GetAttribute("en") ~= true and SHC.Value == "" and v6 then
				upd_keys()
			end
		end)
	end

	if character:FindFirstChild("SHC") == nil then
		childAddedConnection = character.ChildAdded:Connect(function(child)
			if child.Name == "SHC" then
				updSHC()
			end
		end)
	else
		updSHC()
	end

	humanoidRootPart.ChildAdded:Connect(function(child)
		if child.Name == "air_combo_bp" then
			updv() -- equivalent call inferred; original call site unknown
		end
	end)
	humanoidRootPart.ChildRemoved:Connect(function(child)
		if child.Name == "air_combo_bp" then
			updv() -- equivalent call inferred; original call site unknown
		end
	end)
end

if localPlayer.Character ~= nil then
	updChar(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(updChar)
local modules = {
	DemonArt = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Powers"):WaitForChild("DemonArts")),
	Breathing = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Powers"):WaitForChild("Breathings"))
}
local find = table.find
local insert = table.insert

function SkillsProvider.get_current_keys(_)
	local v13 = false
	local value = ""
	local localPlayer2 = Players.LocalPlayer
	local data2 = Utility.GetData(localPlayer2, true)
	local get_equipped_tool = Character_info_provider.Get_equipped_tool(localPlayer2)
	local result = {}
	local v14 = {}

	if get_equipped_tool and Items[get_equipped_tool.Name] then
		local item = Items[get_equipped_tool.Name]

		if item ~= nil then
			local v15 = item.Breathing and "Breathing" or item.DemonArt and "DemonArt" or nil

			if v15 ~= nil then
				local race2 = data2:FindFirstChild("Race")
				local value2 = race2 and race2.Value
				local v16

				if v15 == "Breathing" and (value2 == "Human" or value2 == "Slayer" or value2 == "Hybrid") then
					v16 = true
				elseif v15 == "DemonArt" then
					v16 = value2 == "Demon" or value2 == "Hybrid"
				else
					v16 = false
				end

				if not v16 then
					v15 = nil
				end
			end

			if v15 ~= nil and item[v15] ~= nil then
				local v16 = item[v15]

				if get_equipped_tool.Name == FightingStyles.TOOL_NAME then
					local _, v17 = FightingStyles.For(localPlayer2)

					if v17 ~= nil and v17[v15] ~= nil then
						v16 = v17[v15]
					end
				end

				local v17

				if modules[v15] ~= nil then
					v17 = modules[v15][data2.Powers[v15].Value] or nil
				end

				local v18

				if type(v17) == "table" then
					v18 = v17.CustomPower == true
				else
					v18 = false
				end

				if (v18 or Resolve.LaneCarries(v16, data2.Powers[v15].Value)) and v17 ~= nil and (v17.Category == nil or v17.Category == item.Category) and v17 and data2.Powers:FindFirstChild(v15) then
					for _, v19 in pairs(v17.Skills or {}) do
						if not (v19.ToolCategory == nil or v19.ToolCategory == item.Category) then
							continue
						end

						if v19.State == true then
							insert(
								result,
								v3 and v19[Menum.skillState.Air] or default and v19[Menum.skillState.Combat] or v4 and v4[v19.Name] and v19[v4[v19.Name]] or v19[Menum.skillState.Default]
							)
							v13 = true
						else
							insert(result, v19)
						end
					end

					value = data2.Powers[v15].Value
					v14[v15] = true
				end
			end
		end

		local skills = Items[get_equipped_tool.Name].Skills

		if get_equipped_tool.Name == ClanSkills.TOOL_NAME then
			local clan2 = data2:FindFirstChild("Clan")
			local skillsFor = ClanSkills.SkillsFor
			local v15

			if clan2 ~= nil then
				v15 = clan2.Value or nil
			end

			skills = skillsFor(v15, Players.LocalPlayer)
		end

		if get_equipped_tool.Name == FightingStyles.TOOL_NAME then
			local v15, v16 = FightingStyles.For(Players.LocalPlayer)

			if v16 ~= nil then
				skills = v16.Skills

				if #value == 0 then
					value = v15
				else
					value = `{value},{v15}`
				end
			end
		end

		local v15 = {}

		for _, v16 in pairs(result) do
			insert(v15, v16.Name)
		end

		if skills ~= nil then
			if #value == 0 then
				value = get_equipped_tool.Name
			else
				value ..= `,{get_equipped_tool.Name}`
			end

			local v16 = #result > 0
			local flag = true

			for _, skill in pairs(skills) do
				if not (skill.RequiresModeBar ~= true or SkillsProvider.ModeBarFull() or SkillsProvider.IsHeld(skill.Name)) then
					continue
				end

				if skill.RequiresAura ~= nil then
					v[skill.RequiresAura] = true

					if not (SkillsProvider.AuraActive(skill.RequiresAura) or SkillsProvider.IsHeld(skill.Name)) then
						continue
					end
				end

				if not (find(v15, skill.Name) == nil and (not v16 or skill.Name ~= "Blocking")) then
					continue
				end

				if skill.State == true then
					skill = v3 and skill[Menum.skillState.Air] or default and skill[Menum.skillState.Combat] or v4 and v4[skill.Name] and skill[v4[skill.Name]] or skill[Menum.skillState.Default]
					v13 = true
				end

				if flag then
					local count = #result

					if count > 0 then
						local clone = table.clone(result[count])
						clone.SplitHere = 1
						result[count] = clone
					end

					if v16 then
						local clone = table.clone(skill)
						clone.SplitHere = 2
						insert(result, clone)
					else
						insert(result, skill)
					end

					flag = false
				else
					insert(result, skill)
				end
			end
		end

		table.clear(v15)
	end

	for k, grantedSkill in PlayerProgression.GrantedSkills do
		if not (v14[grantedSkill.Side == "Slayer" and "Breathing" or "DemonArt"] and PlayerProgression.HasGrantedSkill(
			localPlayer2,
			k
		)) then
			continue
		end

		insert(result, grantedSkill.Skill)
	end

	script.CurPower.Value = value
	v2 = v13
	local count = #result

	if isClient and game.ReplicatedStorage.CAM.Client.Components.Layout.Visibility.HUD.Skills.Value < count then
		game.ReplicatedStorage.CAM.Client.Components.Layout.Visibility.HUD.Skills.Value = count
	end

	return result
end

return SkillsProvider