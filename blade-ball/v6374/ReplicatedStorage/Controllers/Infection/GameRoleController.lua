local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Shared.LTM)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Shared.Statable)
local v6 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
local playerGui = Players.LocalPlayer.PlayerGui
local announcer = playerGui:WaitForChild("announcer")
local chooserUI = playerGui:WaitForChild("ChooserUI")
local duelUI = playerGui:WaitForChild("DuelUI")
local v7 = {
	"Infected",
	"LavaFloor",
	"Shark",
	"CrownClash"
}
local v8 = {
	DragonChoose = {
		RoleName = "Dragon",
		RoleColor = ColorSequence.new(Color3.fromRGB(255, 215, 114), Color3.fromRGB(255, 185, 7))
	},
	JuggernautChoose = {
		RoleName = "Juggernaut",
		RoleColor = ColorSequence.new(Color3.fromHex("#ff8154"), Color3.fromHex("#ff2018"))
	},
	InfectedChoose = {
		RoleName = "Zombie",
		RoleColor = ColorSequence.new(Color3.fromHex("#67ffa4"), Color3.fromHex("#19ff5a"))
	},
	CrownClashChoose = {
		RoleName = "King",
		RoleColor = ColorSequence.new(Color3.fromRGB(255, 203, 83), Color3.fromRGB(255, 185, 7))
	},
	SharkChoose = {
		RoleName = "Shark",
		RoleColor = ColorSequence.new(Color3.fromRGB(62, 162, 255), Color3.fromRGB(28, 115, 255))
	},
	BattlepassEventChoose = {
		DefaultPosition = 3,
		MultipleOptions = true,
		RoleNames = {
			"⚡ Fastball",
			"☁️ Lightball",
			"↪️ Curveball",
			"💥 Clashball",
			"🔮 Forceball"
		},
		RoleColors = {
			ColorSequence.new(Color3.fromRGB(255, 208, 39)),
			ColorSequence.new(Color3.fromRGB(83, 252, 255)),
			ColorSequence.new(Color3.fromRGB(11, 255, 52)),
			ColorSequence.new(Color3.fromRGB(255, 61, 35)),
			ColorSequence.new(Color3.fromRGB(203, 46, 255))
		}
	},
	MysteryBallChoose = {
		DefaultPosition = 3,
		MultipleOptions = true,
		HideChances = true,
		RoleNames = {
			"⚡ Fast Ball",
			"↪️ Curve Ball",
			"💥 Giant Ball",
			"🤏 Tiny Ball",
			"🃏 Fake Ball",
			"🎯 2 Ball",
			"🎩 Trick Ball",
			"💣 Bomb Ball",
			"👻 Phantom Ball",
			"🎲 Geometry Ball"
		},
		RoleColors = {
			ColorSequence.new(Color3.fromRGB(255, 208, 39)),
			ColorSequence.new(Color3.fromRGB(83, 252, 255)),
			ColorSequence.new(Color3.fromRGB(255, 61, 35)),
			ColorSequence.new(Color3.fromRGB(115, 255, 105)),
			ColorSequence.new(Color3.fromRGB(255, 255, 0)),
			ColorSequence.new(Color3.fromRGB(212, 0, 255)),
			ColorSequence.new(Color3.fromRGB(255, 0, 123)),
			ColorSequence.new(Color3.fromRGB(255, 48, 7)),
			ColorSequence.new(Color3.fromRGB(117, 225, 255)),
			ColorSequence.new(Color3.fromRGB(157, 255, 121))
		}
	},
	FatesChoose = {
		DefaultPosition = 1,
		MultipleOptions = true,
		HideChances = true,
		RoleNames = {
			"Spawn Second Ball",
			"Curve Ball",
			"Increased Parry Strength",
			"Decreased Parry Strength",
			"Pulsed Effect",
			"Increased Parry Hitbox",
			"Infinity Effect",
			"Increased Ability Cooldown",
			"Decreased Ability Cooldown",
			"Dash Ability",
			"Singularity Ability",
			"Increased Gravity",
			"Decreased Gravity",
			"Increased Player Speed",
			"Decreased Player Speed",
			"Increased Player Size",
			"Decreased Player Size",
			"Increased Ball Speed",
			"Storm"
		},
		RoleColors = {
			ColorSequence.new(Color3.fromRGB(255, 208, 39)),
			ColorSequence.new(Color3.fromRGB(83, 252, 255)),
			ColorSequence.new(Color3.fromRGB(255, 255, 0)),
			ColorSequence.new(Color3.fromRGB(212, 0, 255)),
			ColorSequence.new(Color3.fromRGB(255, 0, 123)),
			ColorSequence.new(Color3.fromRGB(255, 208, 39)),
			ColorSequence.new(Color3.fromRGB(83, 252, 255)),
			ColorSequence.new(Color3.fromRGB(255, 255, 0)),
			ColorSequence.new(Color3.fromRGB(212, 0, 255)),
			ColorSequence.new(Color3.fromRGB(255, 0, 123)),
			ColorSequence.new(Color3.fromRGB(255, 208, 39)),
			ColorSequence.new(Color3.fromRGB(83, 252, 255)),
			ColorSequence.new(Color3.fromRGB(255, 255, 0)),
			ColorSequence.new(Color3.fromRGB(212, 0, 255)),
			ColorSequence.new(Color3.fromRGB(255, 0, 123)),
			ColorSequence.new(Color3.fromRGB(255, 208, 39)),
			ColorSequence.new(Color3.fromRGB(83, 252, 255)),
			ColorSequence.new(Color3.fromRGB(255, 255, 0)),
			ColorSequence.new(Color3.fromRGB(212, 0, 255))
		}
	},
	LuckyBlocksChoose = {
		DefaultPosition = 1,
		MultipleOptions = true,
		HideChances = true,
		RoleNames = {
			"Spawn Second Ball",
			"Curve Ball",
			"Decreased Gravity",
			"Increased Parry Strength",
			"Increased Player Speed",
			"Decreased Ability Cooldown",
			"Increased Parry Hitbox",
			"Decreased Parry Strength",
			"Decreased Player Speed",
			"Increased Ability Cooldown",
			"Dash Ability",
			"Split Ball"
		},
		RoleColors = {
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(94, 255, 82)),
			ColorSequence.new(Color3.fromRGB(94, 255, 82)),
			ColorSequence.new(Color3.fromRGB(94, 255, 82)),
			ColorSequence.new(Color3.fromRGB(94, 255, 82)),
			ColorSequence.new(Color3.fromRGB(255, 86, 80)),
			ColorSequence.new(Color3.fromRGB(255, 86, 80)),
			ColorSequence.new(Color3.fromRGB(255, 86, 80)),
			ColorSequence.new(Color3.fromRGB(255, 86, 80)),
			ColorSequence.new(Color3.fromRGB(255, 86, 80))
		}
	},
	HovergoalLuckyBlocksChoose = {
		DefaultPosition = 1,
		MultipleOptions = true,
		HideChances = true,
		RoleNames = {
			"Spawn Second Ball",
			"Curve Ball",
			"Increased Parry Strength",
			"Increased Player Speed",
			"Increased Parry Hitbox",
			"Decreased Parry Strength",
			"Decreased Player Speed"
		},
		RoleColors = {
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(94, 255, 82)),
			ColorSequence.new(Color3.fromRGB(94, 255, 82)),
			ColorSequence.new(Color3.fromRGB(94, 255, 82)),
			ColorSequence.new(Color3.fromRGB(255, 86, 80)),
			ColorSequence.new(Color3.fromRGB(255, 86, 80))
		}
	},
	RedLightGreenLightRewards = {
		DefaultPosition = 1,
		MultipleOptions = true,
		HideChances = true,
		CustomLabel = "You received:",
		RoleNames = {
			"Low Tier Sword",
			"Mid Tier Sword",
			"Mid Tier Sword2",
			"High Tier Sword",
			"Mid Tier Explosion",
			"High Tier Explosion",
			"Mid Tier Emote",
			"High Tier Emote",
			"Op Tier Sword"
		},
		RoleColors = {
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(66, 255, 145)),
			ColorSequence.new(Color3.fromRGB(74, 255, 243)),
			ColorSequence.new(Color3.fromRGB(71, 154, 255)),
			ColorSequence.new(Color3.fromRGB(161, 78, 255)),
			ColorSequence.new(Color3.fromRGB(243, 79, 255)),
			ColorSequence.new(Color3.fromRGB(255, 234, 76)),
			ColorSequence.new(Color3.fromRGB(255, 180, 89)),
			ColorSequence.new(Color3.fromRGB(255, 86, 80))
		}
	},
	AbilityBlockChoose = {
		DefaultPosition = 1,
		MultipleOptions = true,
		HideChances = true,
		RoleNames = {
			"Quad Jump",
			"Guardian Angel",
			"Golden Ball",
			"Martyrdom",
			"Luck",
			"Misfortune",
			"Tact",
			"Reaper"
		},
		RoleColors = {
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(239, 255, 66)),
			ColorSequence.new(Color3.fromRGB(239, 255, 66))
		}
	}
}
local v9 = require3(ReplicatedStorage2.Shared.DynArgs).Or()
v9:SetTag("Disabled", true)
local state = v5.State()
v9:LinkState(state)
return {
	Start = function(_)
		local roundTimer = duelUI.RoundTimer
		local timer = roundTimer.Timer
		local title = timer.Title
		v:RemoteEvent("UpdateRoundTimer").OnClientEvent:Connect(function(p: number, flag: boolean)
			if flag then
				title.Text = `{p}s`

				if p <= 1 then
					task.wait(1)
					roundTimer.Visible = false
					duelUI.Enabled = false
				elseif not roundTimer.Visible then
					roundTimer.Visible = true
					duelUI.Enabled = true
				end
			else
				roundTimer.Visible = false
				duelUI.Enabled = false
			end
		end)
		local v10 = nil
		v:RemoteEvent("GameModeRoles").OnClientEvent:Connect(function(p, enabled, p2, p3, p4)
			local thread = coroutine.running()
			v10 = thread
			local v11 = v8[p]

			if v11 then
				local roleName

				if v11.MultipleOptions then
					roleName = v11.RoleNames[v11.DefaultPosition]
				else
					roleName = v11.RoleName
				end

				local roleColor

				if v11.MultipleOptions then
					roleColor = v11.RoleColors[v11.DefaultPosition]
				else
					roleColor = v11.RoleColor
				end

				if p2 then
					if p3 == 0 then
						p2 = p2 == 0 and 1 or p2
						p3 = p2
					end

					if v11.MultipleOptions then
						local v12 = math.floor(p2 / p3 * 100)
						chooserUI.Chooser.Chance.Text = v11.HideChances and "" or ("Chance for event: %d%%"):format(v12)
						chooserUI.Chooser.Label.Text = "Rolling for"
					else
						local v12 = math.floor(p2 / p3 * 100)
						chooserUI.Chooser.Chance.Text = v11.HideChances and "" or ("Your chance to be a %s: %d%%"):format(
							roleName:lower(),
							v12
						)
						chooserUI.Chooser.Label.Text = "You are"
					end

					if v11.CustomLabel then
						chooserUI.Chooser.Label.Text = v11.CustomLabel
					end
				else
					chooserUI.Chooser.Chance.Text = ""
					chooserUI.Chooser.Label.Text = "You are"
				end

				chooserUI.Chooser.Role.UIGradient.Enabled = true
				chooserUI.Chooser.Role.UIGradient.Color = roleColor
				v9:SetTag("Disabled", false)
				announcer.TextBox.Visible = false
				local enabled2 = v11.MultipleOptions and true or false
				local count = 0

				for _, v13 in ipairs({
					10,
					6,
					4,
					2
				}) do
					local v14 = 1 / v13

					for _ = 1, v13 do
						count += 1
						local v15, color

						if v11.MultipleOptions then
							local v17 = math.max(math.fmod(count, #v11.RoleNames) + 1, 1)
							v15 = v11.RoleNames[v17]
							color = v11.RoleColors[v17]
						else
							v15 = roleName
							color = roleColor
						end

						chooserUI.Chooser.Role.Text = enabled2 == true and v15 or "Player"
						chooserUI.Chooser.Role.UIGradient.Color = color
						chooserUI.Chooser.Role.UIGradient.Enabled = enabled2

						if not v11.MultipleOptions then
							enabled2 = not enabled2
						end

						v4.Sounds:Play("smallclick")
						task.wait(v14)

						if thread ~= v10 then
							return
						end
					end
				end

				local v13

				if v11.MultipleOptions then
					roleName = v11.RoleNames[p4]
					roleColor = v11.RoleColors[p4]
					v13 = "No Event"
				else
					v13 = "Player"
				end

				chooserUI.Chooser.Role.Text = enabled == true and roleName or v13
				chooserUI.Chooser.Role.UIGradient.Color = roleColor
				chooserUI.Chooser.Role.UIGradient.Enabled = enabled
				v4.Sounds:Play("reward")
				task.wait(5)

				if thread ~= v10 then
					return
				end

				v9:SetTag("Disabled", true)
				v10 = nil
			end
		end)

		for _, v11 in v3.getProfiles() do
			if not (v2.isLTMServer() and table.find(v7, v11.getGameMode())) then
				continue
			end

			duelUI.Enabled = true
			timer.Visible = true
			title.Visible = true
		end

		v5.setPropertyComputed(chooserUI, "Enabled", function(callback)
			return not (callback(state) or callback(v6.IsUICoveredState))
		end)
	end
}