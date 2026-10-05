local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local MobileButtonScale = require(ReplicatedStorage.CAM.Client.Modules.MobileButtonScale)
local AutoLoadoutKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.AutoLoadoutKeys)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local localPlayer = Players.LocalPlayer

local function percent(p: number)
	return string.format("%d", (math.round(p * 100)))
end

task.spawn(function()
	for _, v in AutoLoadoutKeys.ByKey do
		if v.Gate.RequiredGroup ~= nil then
			Worlds.CanSee(localPlayer, v.Gate)
		end
	end
end)

local function loadoutChoices()
	local result = {
		{
			Value = AutoLoadoutKeys.Default,
			Label = "None"
		}
	}
	local data = Utility.GetData(localPlayer)
	local itemLoadouts

	if data ~= nil then
		itemLoadouts = data:FindFirstChild("ItemLoadouts")
	end

	if itemLoadouts == nil then
		return result
	end

	local v = {}
	local v2 = {}

	for _, folder in itemLoadouts:GetChildren() do
		if not folder:IsA("Folder") then
			continue
		end

		local name = folder:FindFirstChild("Name")
		local name2 = name == nil and "" or name.Value
		table.insert(v, {
			Folder = folder.Name,
			Name = name2
		})
		v2[name2] = (v2[name2] or 0) + 1
	end

	table.sort(v, function(a, b)
		return (tonumber(a.Folder) or 0) < (tonumber(b.Folder) or 0)
	end)

	for _, v3 in v do
		local name = v3.Name

		if name == "" or v2[name] > 1 then
			name = `{name == "" and "Loadout" or name} {v3.Folder}`
		end

		if #name > 16 then
			name = string.sub(name, 1, 14) .. ".."
		end

		table.insert(result, {
			Value = v3.Folder,
			Label = name
		})
	end

	return result
end

local function autoLoadoutGroup(list, label: string, items, choices)
	local data = Utility.GetData(localPlayer)
	local v = false

	for _, item in items do
		if not Worlds.CanSee(localPlayer, item.Gate, data) then
			continue
		end

		if not v then
			table.insert(list, {
				Kind = "Heading",
				Label = label
			})
			v = true
		end

		table.insert(list, {
			Kind = "Choice",
			Label = item.Label,
			Key = {
				Path = AutoLoadoutKeys.Path(item.Key),
				Default = AutoLoadoutKeys.Default,
				Scope = AutoLoadoutKeys.Scope
			},
			Action = AutoLoadoutKeys.Action,
			Arg = item.Key,
			Choices = choices
		})
	end
end

return {
	Build = function()
		local v = Platform_Handler.Platform.Value == "Mobile"
		local isGamepad = Platform_Handler.IsGamepad()
		local entries = {}

		if not v then
			table.insert(entries, {
				Kind = "Heading",
				Label = "Movement"
			})
			table.insert(entries, {
				Kind = "Toggle",
				Label = "Toggle run",
				Key = SettingsKeys.RunToggle,
				Action = "RunToggle"
			})
		end

		if isGamepad or v then
			table.insert(entries, {
				Kind = "Heading",
				Label = "Aim"
			})
			table.insert(entries, {
				Kind = "Dragbar",
				Label = "Aim assist",
				Key = SettingsKeys.AimAssist,
				Action = "AimAssistStrength",
				Step = 0.05,
				Format = percent
			})
			table.insert(entries, {
				Kind = "Dragbar",
				Label = "Aim assist in combat",
				Key = SettingsKeys.AimAssistCombat,
				Action = "AimAssistCombatStrength",
				Step = 0.05,
				Format = percent
			})
		end

		if isGamepad then
			table.insert(entries, {
				Kind = "Heading",
				Label = "Dash"
			})
			table.insert(entries, {
				Kind = "Toggle",
				Label = "Directional dash",
				Key = SettingsKeys.PadDirectionalDash,
				Action = "PadDirectionalDash"
			})
		end

		table.insert(entries, {
			Kind = "Heading",
			Label = "Shift lock"
		})
		table.insert(entries, {
			Kind = "Toggle",
			Label = "Strict shift lock",
			Key = SettingsKeys.StrictShiftLock,
			Action = "StrictShiftLock"
		})

		if not v then
			table.insert(entries, {
				Kind = "Heading",
				Label = "Keybinds"
			})

			for _, keybind in SettingsKeys.Keybinds do
				if not isGamepad or keybind.NoPad ~= true then
					table.insert(entries, {
						Kind = "Recorder",
						Label = keybind.Label,
						Keybind = keybind.Name,
						CanEdit = not v
					})
				end
			end
		end

		local v3 = {
			{
				Name = "General",
				Entries = {
					{
						Kind = "Heading",
						Label = "Controls"
					},
					{
						Kind = "Choice",
						Label = "Controls",
						Key = SettingsKeys.ForcePlatform,
						Action = "ForcePlatformControls",
						Choices = SettingsKeys.PlatformChoices
					},
					{
						Kind = "Heading",
						Label = "Graphics"
					},
					{
						Kind = "Dragbar",
						Label = "Effects",
						Key = SettingsKeys.Particles,
						Action = "ParticleQuality",
						Step = 0.1,
						Format = percent
					},
					{
						Kind = "Dragbar",
						Label = "My effects",
						Key = SettingsKeys.ParticlesMine,
						Action = "ParticleQualityMine",
						Step = 0.1,
						Format = percent
					},
					{
						Kind = "Dragbar",
						Label = "Ally effects",
						Key = SettingsKeys.ParticlesAllies,
						Action = "ParticleQualityAllies",
						Step = 0.1,
						Format = percent
					},
					{
						Kind = "Dragbar",
						Label = "Other players' effects",
						Key = SettingsKeys.ParticlesOthers,
						Action = "ParticleQualityOthers",
						Step = 0.1,
						Format = percent
					},
					{
						Kind = "Dragbar",
						Label = "Screen shake",
						Key = SettingsKeys.ScreenShake,
						Action = "ScreenShakeStrength",
						Step = 0.05,
						Format = percent
					},
					{
						Kind = "Toggle",
						Label = "Map materials",
						Key = SettingsKeys.Materials,
						Action = "MaterialQuality"
					},
					{
						Kind = "Toggle",
						Label = "Shadows",
						Key = SettingsKeys.Shadows,
						Action = "ShadowQuality"
					},
					{
						Kind = "Heading",
						Label = "Interface"
					},
					{
						Kind = "Toggle",
						Label = "Boss bar",
						Key = SettingsKeys.BossUI,
						Action = "BossUIVisible"
					},
					{
						Kind = "Toggle",
						Label = "Stat chips",
						Key = SettingsKeys.HealthStats,
						Action = "HealthStatsVisible"
					},
					{
						Kind = "Toggle",
						Label = "Control hints",
						Key = SettingsKeys.KeybindHelper,
						Action = "KeybindHelper"
					},
					{
						Kind = "Toggle",
						Label = "Titles",
						Key = SettingsKeys.Titles,
						Action = "TitlesVisible"
					},
					{
						Kind = "Toggle",
						Label = "Title effects",
						Key = SettingsKeys.TitleEffects,
						Action = "TitleEffectsVisible"
					},
					{
						Kind = "Heading",
						Label = "Audio"
					},
					{
						Kind = "Dragbar",
						Label = "Theme",
						Key = SettingsKeys.ThemeVolume,
						Action = "ThemeVolume",
						Step = 0.05,
						Format = percent
					},
					{
						Kind = "Dragbar",
						Label = "Ambience",
						Key = SettingsKeys.AmbienceVolume,
						Action = "AmbienceVolume",
						Step = 0.05,
						Format = percent
					},
					{
						Kind = "Heading",
						Label = "Ouwigahara"
					},
					{
						Kind = "Toggle",
						Label = "Auto skip wave",
						Key = SettingsKeys.AutoWaveSkip,
						Action = "AutoWaveSkip"
					}
				}
			},
			{
				Name = "Controls",
				Entries = entries
			}
		}
		local entries2 = {}
		local choices = loadoutChoices()
		autoLoadoutGroup(entries2, "Worlds", AutoLoadoutKeys.Worlds, choices)
		autoLoadoutGroup(entries2, "Gamemodes", AutoLoadoutKeys.Modes, choices)
		table.insert(v3, {
			Name = "Auto Loadout",
			Entries = entries2
		})

		if v then
			table.insert(v3, {
				Name = "Mobile",
				Entries = {
					{
						Kind = "Heading",
						Label = "On screen controls"
					},
					{
						Kind = "Dragbar",
						Label = "Button size",
						Key = SettingsKeys.MobileScale,
						Action = "MobileButtonScale",
						Step = 0.05,
						Format = function(p: number)
							return percent(MobileButtonScale.Of(p))
						end
					},
					{
						Kind = "Toggle",
						Label = "Toolbar Drag and Drop",
						Key = SettingsKeys.MobileToolbarDrag,
						Action = "MobileToolbarDrag"
					},
					{
						Kind = "Heading",
						Label = "Dash"
					},
					{
						Kind = "Toggle",
						Label = "Directional dash",
						Key = SettingsKeys.MobileDirectionalDash,
						Action = "MobileDirectionalDash"
					},
					{
						Kind = "Heading",
						Label = "Aiming"
					},
					{
						Kind = "Toggle",
						Label = "Skill drag turns camera",
						Key = SettingsKeys.MobileSkillDragTurnsCamera,
						Action = "MobileSkillDragTurnsCamera"
					}
				}
			})
		end

		return v3
	end
}