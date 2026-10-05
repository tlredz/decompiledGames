local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local faye = require(ReplicatedStorage.Packages.faye)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local PlayerProfile = require(ReplicatedStorage.CAM.Global.PlayerProfile)
local AppliedTicks = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.AppliedTicks)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local Ring = require(script.Ring)
local SkillTreeConfig = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder.SkillTreeConfig)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Config = require(ReplicatedStorage.Skills.Clan["Enhanced Hearing"].Config)
local Config2 = require(ReplicatedStorage.Skills.Clan["Soothing Voice"].Config)

-- equivalent calls inferred from this helper; original call sites unknown
local function displayName(instance)
	if instance == nil or typeof(instance) ~= "Instance" then
		return nil
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter == nil then
		return instance.Name
	end

	return playerFromCharacter:GetAttribute("Nickname") or playerFromCharacter.DisplayName
end

local v = {
	["Health Regen Speed"] = {
		text = function()
			return "Regen Adrenal"
		end,
		skill = function(instance)
			return instance:GetAttribute("Skill")
		end,
		when = function(instance)
			return instance:GetAttribute("_RegenAdrenal") == true
		end
	},
	["Max Stamina"] = {
		text = function(p, callback)
			return (`<font color="rgb(255,0,0)">+{callback(p)}</font> Max Stamina`)
		end,
		skill = function(instance)
			return instance:GetAttribute("Skill")
		end,
		when = function(instance)
			return instance:GetAttribute("_Duration") ~= nil
		end
	},
	[Utility.TEMPORARY_BOOST] = {
		text = function(instance, callback)
			return (`<font color="rgb(255,0,0)">x{math.round((tonumber(callback(instance)) or 1) * 100) / 100}</font> {instance:GetAttribute("Stat") or gameSettings.StunChainBoost.Stat}`)
		end,
		when = function(instance)
			return gameSettings.StunChainBoost.DisplayPvPOnly ~= true or instance:GetAttribute("PvP") == true
		end,
		icon = (SkillTreeConfig[gameSettings.StunChainBoost.Stat] or {}).Icon
	},
	[Utility.DODGE_VALUE] = {
		text = function(instance, callback)
			local v2 = instance:GetAttribute("Mode") == "Combat" and "Combat " or ""
			return (`<font color="rgb(255,0,0)">{callback(instance)}</font> {v2}Dodges Left`)
		end,
		skill = function(instance)
			return instance:GetAttribute("Skill")
		end
	},
	[AppliedTicks.ByName["Enhanced Hearing"].Value] = {
		text = function(instance, callback)
			local damage = tonumber(instance:GetAttribute("Damage")) or 0
			local v3 = displayName(callback(instance)) -- equivalent call inferred; original call site unknown
			local v4 = v3 or instance:GetAttribute("Caster") or "them"
			return (`<font color="rgb(255,0,0)">+{math.round(damage * 100)}%</font> Combat Damage Taken from {Utility.NameTag(v4, true)}`)
		end,
		skill = function(instance)
			return instance:GetAttribute("Skill")
		end
	},
	[Config.CASTER_NOTE_VALUE] = {
		text = function(instance, callback)
			local damage = tonumber(instance:GetAttribute("Damage")) or 0
			local v3 = displayName(callback(instance)) -- equivalent call inferred; original call site unknown
			return (`{Utility.NameTag(v3 or "Target", true)} Marked, <font color="rgb(255,0,0)">+{math.round(damage * 100)}%</font> Combat Damage`)
		end,
		skill = function(instance)
			return instance:GetAttribute("Skill")
		end
	},
	[Config2.PIERCE_VALUE] = {
		text = function()
			return "<font color=\"rgb(255,0,0)\">Guard Pierced</font>, Blocking Does Nothing"
		end,
		skill = function(instance)
			return instance:GetAttribute("Skill")
		end
	},
	Counter = {
		when = function(instance)
			return instance:GetAttribute("Record") == true
		end,
		text = function()
			return "Recording for Skills"
		end,
		skill = function(p)
			return p.Value
		end
	},
	SkillToggle = {
		text = function(instance, callback)
			local onlySkill = instance:GetAttribute("OnlySkill")

			if onlySkill ~= nil then
				return (`{Utility.NameTag(onlySkill, true)} Recorded, Next One Dodged`)
			end

			local remaining = instance:FindFirstChild("Remaining")
			local type = instance:FindFirstChild("Type")
			local v2 = (type == nil or type.Value ~= Menum.toggleSkillType.iframe) and "Charges" or "Dodges"
			return (`<font color="rgb(255,0,0)">{remaining == nil and 1 or callback(remaining)}</font> {v2} Left`)
		end,
		skill = function(p)
			return p.Value
		end
	}
}
local v2 = {
	_ClanAura = {
		text = function(p)
			return (`{Utility.NameTag(p.Name, true)} Active`)
		end,
		skill = function(p)
			return p.Name
		end
	},
	_AttackLock = {
		text = function()
			return "<font color=\"rgb(255,0,0)\">Attacks Disabled</font>, You Can Still Block"
		end,
		icon = BunchaIcons.Locked
	}
}
local info = faye.Info(0.3, Enum.EasingStyle.Back)
local info2 = faye.Info(0.3)
local localPlayer = Players.LocalPlayer
return function(object, _)
	local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
	local value = object:Value({})
	local visible = object:Value(false)
	local size = object:Value(UDim2.fromOffset(0, 0))
	local v3 = 0
	local count = 0
	local v4 = {}

	local function rotationOf(instance)
		local _Duration = tonumber(instance:GetAttribute("_Duration")) or 0

		if _Duration <= 0 then
			return 360
		end

		local _Started = tonumber(instance:GetAttribute("_Started")) or workspace:GetServerTimeNow()
		return math.clamp(1 - (workspace:GetServerTimeNow() - _Started) / _Duration, 0, 1) * 360
	end

	object:Connect(RunService.Heartbeat, function()
		for k, v5 in v4 do
			v5:Set((rotationOf(k)))
		end
	end)
	local v5 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addRow(p)
		if v5[p] then
			return
		end

		v5[p] = true
		v3 += 1
		count += 1
		visible:Set(true)
		value += p
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeRow(p)
		if not v5[p] then
			return
		end

		v5[p] = nil
		v4[p] = nil
		v3 -= 1
		value -= p

		if v3 > 0 then
			return
		end

		count += 1
		local v6 = count
		object:Delay(0.3, function()
			if v6 == count and v3 == 0 then
				visible:Set(false)
			end
		end)
	end

	local v6 = {}

	local function watch(child)
		local v7 = v[child.Name]

		if v7 == nil then
			for attributeName, v8 in v2 do
				local v9 = attributeName
				local v10 = v8

				local function evaluate()
					if child:GetAttribute(v9) == nil then
						return
					end

					v6[child] = v10
					addRow(child) -- equivalent call inferred; original call site unknown
				end

				object:Connect(child:GetAttributeChangedSignal(attributeName), evaluate)

				if child:GetAttribute(attributeName) == nil then
					continue
				end

				v6[child] = v8
				addRow(child) -- equivalent call inferred; original call site unknown
			end
		else
			v6[child] = v7

			if v7.when == nil then
				addRow(child) -- equivalent call inferred; original call site unknown
			else
				local function evaluate()
					if v7.when(child) == true then
						addRow(child) -- equivalent call inferred; original call site unknown
					else
						removeRow(child) -- equivalent call inferred; original call site unknown
					end
				end

				object:Connect(child.AttributeChanged, evaluate)

				if v7.when(child) == true then
					addRow(child) -- equivalent call inferred; original call site unknown
				else
					removeRow(child) -- equivalent call inferred; original call site unknown
				end
			end
		end
	end

	for _, child in getvaluesfolder:GetChildren() do
		watch(child)
	end

	object:Connect(getvaluesfolder.ChildAdded, watch)
	object:Connect(getvaluesfolder.ChildRemoved, function(p)
		v6[p] = nil
		removeRow(p) -- equivalent call inferred; original call site unknown
	end)

	local function lineFor(p, instance, callback)
		local hubText = instance:GetAttribute("HubText")

		if typeof(hubText) ~= "string" then
			return p.text(instance, callback)
		end

		if string.find(hubText, "{n}", 1, true) == nil then
			return hubText
		end

		local remaining = instance:FindFirstChild("Remaining") or instance
		return (string.gsub(hubText, "{n}", (`<font color="rgb(255,0,0)">{callback(remaining)}</font>`)))
	end

	local function iconOf(p, p2)
		if p.icon ~= nil then
			return p.icon
		end

		local v7 = p.skill ~= nil and p.skill(p2) or nil
		local v8 = v7 ~= nil and PlayerProfile.skill_info[v7] or nil
		return v8 ~= nil and v8.Icon or nil
	end

	return object:Create("Frame")({
		Name = "AAValueHub",
		Size = size,
		Visible = visible,
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 4),
			AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
				size:Set(UDim2.fromOffset(point.X, point.Y))
			end
		}),
		object:Iterate(value, function(_, p, object2)
			local v7 = v6[p] or v[p.Name]

			if v7 == nil then
				return nil
			end

			local value4 = object2:Value((rotationOf(p)))
			v4[p] = value4
			local icon

			if v7.icon == nil then
				local v8

				if v7.skill ~= nil then
					v8 = v7.skill(p) or nil
				end

				local v9 = v8 ~= nil and PlayerProfile.skill_info[v8] or nil
				icon = v9 ~= nil and v9.Icon or nil
			else
				icon = v7.icon
			end

			local value5 = object2:Value(UDim2.fromOffset(54.8, 34))
			local v8 = object2:Create("Frame")
			local v9 = {
				Size = object2:Animation(value5, info, {
					From = UDim2.fromOffset(28.559999999999995, 23.799999999999997)
				}),
				BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
				BackgroundTransparency = object2:Animation(0.25, info2, {
					From = 1
				}),
				OnClean = {
					BackgroundTransparency = object2:Animation(1, info2)
				}
			}
			local v10 = object2:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
			local ring = Ring(
				object2,
				value4,
				UDim2.fromOffset(20.4, 17),
				UDim2.fromOffset(27.200000000000003, 27.200000000000003)
			)
			local v12 = object2:Create("TextLabel")({
				Name = "Label",
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				Position = UDim2.fromOffset(40.8, 0),
				BackgroundTransparency = 1,
				Text = object2:Do(function(p2)
					return lineFor(v7, p, p2)
				end),
				TextBoundsOnChangedInit = function(_, point: Vector2)
					value5:Set(UDim2.fromOffset(40.8 + point.X + 14, 34))
				end,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 21.08,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = Color3.new(1, 1, 1),
				RichText = true,
				TextTransparency = object2:Animation(0, info2, {
					From = 1
				}),
				OnClean = {
					TextTransparency = object2:Animation(1, info2)
				}
			})
			local v13

			if icon ~= nil then
				v13 = object2:Create("ImageLabel")({
					Name = "SkillIcon",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(20.4, 17),
					Size = UDim2.fromOffset(18.700000000000003, 18.700000000000003),
					BackgroundTransparency = 1,
					Image = icon,
					ImageTransparency = object2:Animation(0, info2, {
						From = 1
					}),
					OnClean = {
						ImageTransparency = object2:Animation(1, info2)
					}
				})
			end

			v9[1], v9[2], v9[3], v9[4] = v10, ring, v12, v13
			return v8(v9)
		end)
	})
end