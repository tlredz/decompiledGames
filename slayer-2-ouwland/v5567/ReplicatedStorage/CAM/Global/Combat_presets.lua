game:GetService("StarterPlayer")
local CombatPresets = {
	Last_Punched = 0,
	lastRunHit = 0,
	slow_walk_duration = 0.5,
	slow_walk_speed = 7,
	Last_Punched_Jump = 0,
	No_Jump_Duration = 1.15,
	Last_Combo = 0,
	Last_Climb = 0,
	Is_Air_Combo = false,
	combo_duration = 1.35,
	Default_Swing_Wait = 0.15,
	Presets = {
		Combat = {
			default = 0.26,
			default_before_hit = 0.2,
			default_before_swing = 0.2,
			run_swing_remove_on_first = 0.092,
			final = 1.65,
			AccessoryHitBoxAdditions = {
				Ribbons = 6
			},
			AnimSpeed = {
				Default = 1.125,
				[3] = 1.3,
				[4] = 1.5,
				[5] = 0.85
			},
			delay_before_swing = {
				[5] = 0.2,
				[1] = 0.07,
				[7] = 0.255
			},
			delay_before_hit = {
				[6] = 0.16666666666666666,
				[5] = 0.35,
				[7] = 0.295
			},
			finals = { 5, 7 },
			Effects = {
				Default = "Normal_Punch_Effect",
				[7] = "N/A"
			}
		},
		["Regular Katana"] = {
			default = 0.25,
			default_before_hit = 0.275,
			default_before_swing = 0.21,
			run_swing_remove_on_first = 0.032,
			final = 1.65,
			AnimSpeed = {
				Default = 1.15,
				[-1] = 1.3,
				[4] = 1.25
			},
			delay_before_swing = {
				[5] = 0.2,
				[4] = 0.15,
				[1] = 0.15,
				[7] = 0.2
			},
			delay_before_hit = {
				[5] = 0.275,
				[4] = 0.25,
				[7] = 0.25
			},
			finals = { 5, 7 },
			Effects = {
				Default = "Normal_Sword_Slash_Effect",
				[7] = "N/A"
			}
		},
		["Insect Katana"] = {
			default = 0.25,
			default_before_hit = 0.275,
			default_before_swing = 0.21,
			run_swing_remove_on_first = 0.032,
			final = 1.65,
			AnimSpeed = {
				Default = 1.15,
				[-1] = 1.3,
				[4] = 1.25,
				[6] = 1.35,
				[7] = 1.3
			},
			delay_before_swing = {
				[5] = 0.2,
				[4] = 0.15,
				[1] = 0.15,
				[7] = 0.2
			},
			delay_before_hit = {
				[5] = 0.275,
				[4] = 0.25,
				[7] = 0.25
			},
			finals = { 5, 7 },
			Effects = {
				Default = "Normal_Sword_Slash_Effect",
				[7] = "N/A"
			}
		},
		["Sound Katanas"] = {
			default = 0.25,
			default_before_hit = 0.275,
			default_before_swing = 0.21,
			run_swing_remove_on_first = 0.032,
			final = 1.65,
			AnimSpeed = {
				Default = 1.15,
				[-1] = 1.3,
				[4] = 1.25
			},
			delay_before_swing = {
				[5] = 0.2,
				[4] = 0.15,
				[1] = 0.15,
				[7] = 0.2
			},
			delay_before_hit = {
				[5] = 0.275,
				[4] = 0.25,
				[7] = 0.25
			},
			finals = { 5, 7 },
			Effects = {
				Default = "Normal_Sword_Slash_Effect",
				[7] = "N/A"
			}
		},
		Scythe = {
			default = 0.25,
			default_before_hit = 0.275,
			default_before_swing = 0.21,
			run_swing_remove_on_first = 0.032,
			final = 1.65,
			AnimSpeed = {
				Default = 1.15,
				[-1] = 1.3,
				[4] = 1.25
			},
			delay_before_swing = {
				[5] = 0.2,
				[4] = 0.15,
				[1] = 0.15,
				[7] = 0.2
			},
			delay_before_hit = {
				[5] = 0.275,
				[4] = 0.25,
				[7] = 0.25
			},
			finals = { 5, 7 },
			Effects = {
				Default = "Normal_Sword_Slash_Effect",
				[7] = "N/A"
			}
		},
		["Bladed Wagasa"] = {
			default = 0.25,
			default_before_hit = 0.275,
			default_before_swing = 0.21,
			run_swing_remove_on_first = 0.032,
			final = 1.65,
			AnimSpeed = {
				Default = 1.15,
				[-1] = 1.3,
				[4] = 1.25
			},
			delay_before_swing = {
				[5] = 0.2,
				[4] = 0.15,
				[1] = 0.15,
				[7] = 0.2
			},
			delay_before_hit = {
				[5] = 0.275,
				[4] = 0.25,
				[7] = 0.25
			},
			finals = { 5, 7 },
			Effects = {
				Default = "Normal_Sword_Slash_Effect",
				[7] = "N/A"
			}
		},
		Gauntlet = {
			default = 0.26,
			default_before_hit = 0.2,
			default_before_swing = 0.2,
			run_swing_remove_on_first = 0.085,
			final = 1.65,
			delay_before_swing = {
				[5] = 0.2,
				[1] = 0.07,
				[7] = 0.255
			},
			delay_before_hit = {
				[6] = 0.16666666666666666,
				[7] = 0.295
			},
			finals = { 5, 7 },
			Widths = {
				Default = 2
			},
			Reaches = {
				Default = 1
			},
			Effects = {
				Default = "Normal_Punch_Effect",
				[7] = "N/A"
			}
		},
		Soryu = {
			default = 0.32,
			default_before_hit = 0.2,
			default_before_swing = 0.2,
			run_swing_remove_on_first = 0.092,
			final = 1.65,
			AnimSpeed = {
				Default = 1.5
			},
			finals = { 5, 7 },
			Reaches = {
				Default = 2
			},
			Widths = {
				Default = 1.5
			},
			Effects = {
				Default = "Normal_Punch_Effect",
				[7] = "N/A"
			}
		},
		["Tai Chi"] = {
			default = 0.26,
			default_before_hit = 0.2,
			default_before_swing = 0.25,
			run_swing_remove_on_first = 0.092,
			final = 1.65,
			finals = { 5, 7 },
			Reaches = {
				Default = 2
			},
			Widths = {
				Default = 1.5
			},
			Effects = {
				Default = "Normal_Punch_Effect",
				[7] = "N/A"
			}
		},
		Spear = {
			default = 0.25,
			default_before_hit = 0.275,
			default_before_swing = 0.21,
			run_swing_remove_on_first = 0.032,
			final = 1.65,
			AnimSpeed = {
				Default = 1.15,
				[-1] = 1.3,
				[4] = 1.25
			},
			delay_before_swing = {
				[5] = 0.2,
				[4] = 0.15,
				[1] = 0.15,
				[7] = 0.2
			},
			delay_before_hit = {
				[5] = 0.275,
				[4] = 0.25,
				[7] = 0.25
			},
			Reaches = {
				Default = 2
			},
			finals = { 5, 7 },
			Effects = {
				Default = "Normal_Sword_Slash_Effect",
				[7] = "N/A"
			}
		},
		Tanto = {
			default = 0.25,
			default_before_hit = 0.275,
			default_before_swing = 0.21,
			run_swing_remove_on_first = 0.032,
			final = 1.65,
			AnimSpeed = {
				Default = 1.15,
				[-1] = 1.3,
				[4] = 1.25
			},
			delay_before_swing = {
				[5] = 0.2,
				[4] = 0.15,
				[1] = 0.15,
				[7] = 0.2
			},
			delay_before_hit = {
				[5] = 0.275,
				[4] = 0.25,
				[7] = 0.25
			},
			finals = { 5, 7 },
			Effects = {
				Default = "Normal_Sword_Slash_Effect",
				[5] = "Normal_Punch_Effect",
				[7] = "N/A"
			}
		},
		["War Fans"] = {
			default = 0.25,
			default_before_hit = 0.275,
			default_before_swing = 0.21,
			run_swing_remove_on_first = 0.032,
			final = 1.65,
			AnimSpeed = {
				Default = 1.15,
				[-1] = 1.3,
				[4] = 1.25
			},
			delay_before_swing = {
				[5] = 0.2,
				[4] = 0.15,
				[1] = 0.15,
				[7] = 0.2
			},
			delay_before_hit = {
				[5] = 0.275,
				[4] = 0.25,
				[7] = 0.25
			},
			finals = { 5, 7 },
			Effects = {
				Default = "Normal_Sword_Slash_Effect",
				[7] = "N/A"
			}
		},
		Shotgun = {
			default = 0.25,
			default_before_hit = 0.24,
			default_before_swing = 0.15,
			run_swing_remove_on_first = 0.032,
			final = 1.65,
			finals = { 5, 7 },
			Effects = {
				Default = "Hit_Highlight_Effect",
				[6] = "Normal_Punch_Effect",
				[7] = "Hit_Highlight_Effect"
			}
		},
		Sickles = {
			default = 0.25,
			default_before_hit = 0.2,
			default_before_swing = 0.21,
			run_swing_remove_on_first = 0.092,
			final = 1.65,
			AnimSpeed = {
				Default = 1.15
			},
			delay_before_swing = {
				[5] = 0.2,
				[4] = 0.25,
				[1] = 0.14,
				[7] = 0.3
			},
			delay_before_hit = {
				[5] = 0.25,
				[4] = 0.25,
				[6] = 0.19,
				[7] = 0.35
			},
			finals = { 5, 7 },
			Effects = {
				Default = "Normal_Sickle_Slash_Effect",
				[7] = "N/A"
			}
		},
		Claws = {
			default = 0.3,
			default_before_hit = 0.22,
			default_before_swing = 0.21,
			run_swing_remove_on_first = 0.092,
			final = 1.65,
			AnimSpeed = {
				Default = 1
			},
			finals = { 5, 7 },
			delay_before_swing = {
				[5] = 0.3
			},
			delay_before_hit = {
				[5] = 0.4
			},
			Effects = {
				Default = "Claw_Slash_Effect",
				[7] = "N/A"
			}
		}
	}
}

for k, v in pairs(require(script:WaitForChild("MorePresets"))) do
	CombatPresets.Presets[k] = v
end

CombatPresets.Presets["Blood Manipulation"] = CombatPresets.Presets.Sickles
local FightingStyles, v, v2 = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Powers"):WaitForChild("FightingStyles"))

for k in FightingStyles, v, v2 do
	if CombatPresets.Presets[k] == nil then
		CombatPresets.Presets[k] = CombatPresets.Presets.Combat
	end
end

local v3 = {
	"Landed_Anim",
	"Dash",
	"blockr",
	"blockl",
	"backpack_anim"
}

function CombatPresets.stop_extra_anims(p, list)
	for _, v4 in pairs(p.Animator:GetPlayingAnimationTracks()) do
		if not (string.find(v4.Name, "React_") ~= nil or string.find(v4.Name, "Dash_") ~= nil or list ~= nil and table.find(
			list,
			v4.Name
		) ~= nil or table.find(v3, v4.Name)) then
			continue
		end

		v4:Stop()
		v4:Destroy()
	end
end

local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local PlayerStatResolver = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("PlayerStatResolver"))
local clock = os.clock
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local clamp = math.clamp

function CombatPresets.attackSpeedMult(player)
	if player == nil then
		return 1
	end

	local v4

	if player:IsA("Player") then
		v4 = player
	else
		v4 = game.Players:GetPlayerFromCharacter(player)
	end

	return (math.max(1 + (PlayerStatResolver.GetStat(v4 or player, "Attack Speed Factor") or 0), 0.25))
end

function CombatPresets.runHitPreset(p, flag: boolean)
	if flag and p ~= nil and p.CombatRunHit == true then
		return CombatPresets.Presets.Combat
	end

	return p
end

function get_combat_cd_info(instance, data, p)
	if instance == nil and data == nil and p == nil then
		return
	end

	local last_cmbat = instance:GetAttribute("last_cmbat")
	local last_combo = instance:GetAttribute("last_combo")
	local final = 10000

	if p - 1 == last_combo or p == 6 and p - 2 == last_combo then
		final = data.customDelay and data.customDelay[p] or data.default
	elseif p == 1 then
		if last_combo == 5 or last_combo == 7 then
			final = data.final
		else
			final = CombatPresets.combo_duration
		end
	end

	local v4 = final / CombatPresets.attackSpeedMult(instance)
	local v5 = clock() - last_cmbat
	local v6 = v5 / v4
	return clamp(v4 - v5, 0, 1), v6
end

local random = math.random

function CombatPresets.PlayReactAnim(p, p2: number?, SI: number?, p3)
	if p == nil then
		return
	end

	local parent = p.Parent

	if p2 == nil and p3 == nil then
		p2 = random(1, 5)
	end

	local v4 = p2 == 5 and 6 or p2
	CombatPresets.stop_extra_anims(p)
	local v5 = p3 or Character_info_provider.get_core_anim(parent, "React_" .. v4)

	if v5 == nil and p3 == nil then
		v5 = Character_info_provider.get_core_anim(parent, "React_" .. (v4 - 1) % 3 + 1)
	end

	local track

	if not v5 then
		return track
	end

	track = p.Animator:LoadAnimation(v5)
	track:Play()

	if SI == nil then
		SI = v5:GetAttribute("SI")
	end

	local _ = track.Length

	if SI then
		track:AdjustSpeed(SI)
	end

	return track
end

function CombatPresets.Check_can_do_combat_server(instance, p, last_combo)
	local v4 = false

	if instance == nil or p == nil or last_combo == nil then
		return false
	end

	if instance:GetAttribute("last_cmbat") == nil then
		v4 = true
	else
		local v5, _ = get_combat_cd_info(instance, p, last_combo)
		task.wait(v5)
		local v6, v7 = get_combat_cd_info(instance, p, last_combo)
		v4 = v6 ~= nil and v7 >= 0.95 or v4
	end

	if v4 == true then
		instance:SetAttribute("last_cmbat", clock())
		instance:SetAttribute("last_combo", last_combo)
	end

	return v4
end

function CombatPresets.Get_Players_For_Combat(parent, p, instance, p2, data, p3)
	local Players = game:GetService("Players")
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	local v4 = math.max(1, 1 + (PlayerStatResolver.GetStat(playerFromCharacter or instance, "Dash Speed Factor") or 0))
	local v5 = math.clamp(parent.Velocity.Magnitude / 5, 0, v4 * 13)

	if v5 <= 5 then
		v5 /= 2
	end

	local v6 = parent.Velocity.Unit * v5
	local lookVector = Vector3.new(v6.X, 0, v6.Z) * 1.25

	if lookVector.Magnitude <= 1 or lookVector.Magnitude > 100 or lookVector.Magnitude ~= lookVector.Magnitude then
		lookVector = parent.CFrame.lookVector
	end

	if parent:FindFirstChild("last_magasd") == nil then
		local intValue = Instance.new("IntValue")
		intValue.Name = "last_magasd"
		local v7 = 0
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "last_root"
		objectValue.Parent = intValue
		intValue.Parent = parent
		intValue.Changed:Connect(function()
			local v8 = math.random(1, 9999)
			v7 = v8
			task.wait(0.75)

			if v7 == v8 then
				intValue.Value = 0

				if intValue:FindFirstChild("last_root") ~= nil then
					intValue.last_root.Value = nil
				end
			end
		end)
	end

	if p2 == true then
		if parent.last_magasd.Value < lookVector.Magnitude then
			parent.last_magasd.Value = lookVector.Magnitude
		else
			parent.last_magasd.Value = (parent.last_magasd.Value + lookVector.Magnitude) * 0.5
		end
	end

	local v7 = data == nil and 0 or data.MinHitboxSize or 0
	local get_equipped_tool = Character_info_provider.Get_equipped_tool(instance)

	if get_equipped_tool then
		local preset = CombatPresets.Presets[get_equipped_tool.Name]

		if preset then
			v7 = math.max(v7, preset.MinHitboxSize or 0)

			if preset.AccessoryHitBoxAdditions then
				for childName, accessoryHitBoxAddition in pairs(preset.AccessoryHitBoxAdditions) do
					if not (instance:FindFirstChild("Accessories") ~= nil and instance.Accessories:FindFirstChild(childName) ~= nil) then
						continue
					end

					v7 = math.max(accessoryHitBoxAddition, v7)
				end
			end
		end
	end

	if data.Reaches ~= nil and (data.Reaches[p] or data.Reaches.Default) then
		v7 += data.Reaches[p] or data.Reaches.Default
	end

	local unit = lookVector.Unit

	if parent.last_magasd.last_root.Value ~= nil then
		unit = CFrame.new(parent.Position, parent.last_magasd.last_root.Value.Position).LookVector
	end

	local v8 = math.min(parent.last_magasd.Value, 7)
	local v9

	if v7 < 0 then
		v9 = math.max(v8 + v7, 1)
	else
		v9 = math.clamp(v8, math.max(v7, v8), 99999)
	end

	local v10 = unit * v9
	local v11 = parent.CFrame * CFrame.new(0, -1, 0)

	if data.YOffsets ~= nil and (data.YOffsets[p] or data.YOffsets.Default) then
		v11 *= CFrame.new(0, data.YOffsets[p] or data.YOffsets.Default, 0)
	end

	local v12, v13

	if p == 7 then
		v12 = 4
		v13 = 7
	else
		v12 = 0
		v13 = 0
	end

	local v14 = not p3 and 1 or 1 / gameSettings.NpcCombatHitboxShrink
	local v15 = (data.Widths == nil or not (data.Widths[p] or data.Widths.Default)) and 0 or data.Widths[p] or data.Widths.Default
	local v16 = (data.Depths == nil or not (data.Depths[p] or data.Depths.Default)) and 0 or data.Depths[p] or data.Depths.Default
	local v17 = Vector3.new(v12 + 6 + v15, v15 + 6.25, (math.max(v13 + 9 + v16, 1))) * v14 + Vector3.new(
		0,
		0,
		v10.Magnitude
	)
	local v18 = CFrame.new(v11.Position, v11.Position + v10) * CFrame.new(0, 0, -v10.Magnitude * 0.75)

	if data.ZOffsets ~= nil and (data.ZOffsets[p] or data.ZOffsets.Default) then
		v18 *= CFrame.new(0, 0, -(data.ZOffsets[p] or data.ZOffsets.Default))
	end

	local modelInRegion = Utility.GetModelInRegion(v18, v17, nil, 350)
	local result = {}

	for _, v19 in pairs(modelInRegion) do
		if not (v19:FindFirstChild("Humanoid") and v19 ~= instance and table.find(result, v19) == nil) then
			continue
		end

		table.insert(result, v19)
	end

	return result
end

return CombatPresets