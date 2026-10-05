local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local _ = replicatedStorage.Sounds
local v = nil
local controller = Knit.CreateController({
	Name = "UpdateLogController"
})
controller.Ver = "1.82"
local text = "V" .. controller.Ver .. " \n THE NOTHING UPDATE"
controller.Updates = {
	{
		"SKY ASSASSIN",
		{
			"ADDED 1 NEW SKILL (Blind Rage)",
			"ADDED 1 NEW SKILL (Sky Distortion)",
			"ADDED 1 NEW SKILL (Thin Ice Breaker)",
			"ADDED 1 NEW AWAKENING (Temper)"
		}
	},
	{
		"REGISTER",
		{
			"ADDED 1 NEW AWAKENING (Con-Artistry)",
			"ADDED 1 NEW AWAKENING MOVE (Mayhem)",
			"ADDED 1 NEW AWAKENING MOVE (Big Moves)",
			{
				"GENERAL",
				{ "Sealing a move now has a sound effect" }
			}
		}
	},
	{
		"DISASTER PLANT",
		{
			"DISASTER PLANT IS NOW RELEASED & FREE FOR EVERYONE TO USE!",
			"ADDED NEW EMPOWER VARIANT TO ROOT RAMPAGE (all roots created are doubled and keep following the camera)",
			"ADDED NEW EMPOWER VARIANT TO FLOWER FIELD (creates a different spike that pulls player in when using the move again)",
			{
				"GENERAL",
				{
					"Reverted R special to previous version (Plant Guidance)",
					"Plant Guidance variants can now be used while blocking",
					"Only the character user can see the Plant Guidance spot before an ability is used"
				}
			},
			{
				"ROOT RAMPAGE",
				{
					"Aerial Root Rampage damage decreased by 5 (30 -> 25)",
					"Aerial Root Rampage hitbox increased in width"
				}
			},
			{
				"FLOWER FIELD",
				{
					"Flower Field flower explosion damage increased to 12",
					"Flower Field spike damage increased to 14",
					"Flower Field non empowered spike can now hit 2 different targets before destroying",
					"Flower Field empowered spike can hit 4 different targets before destroying and the same target multiple times if they're pulled into the spike"
				}
			},
			{
				"CURSED BUDS",
				{
					"Cursed Buds (Flower) ragdoll time increased by 0.15s",
					"Cursed Buds (Buds) stun time increased by 0.05s",
					"Cursed Buds (Buds) damage increased by 0.45 (1.25 -> 1.7)",
					"Cursed Buds (Buds) knockback increased x2.5"
				}
			},
			{
				"DEFENSE RESPONSE",
				{ "Added Plant Guidance variant to defense response" }
			}
		}
	},
	{
		"SWITCHER",
		{
			"ADDED 1 NEW VARIANT TO SWIFT KICK (Slide Kick)",
			{
				"PEBBLE THROW",
				{ "Slide variant of Pebble Throw now puts the move on 8s cooldown (7 -> 8)" }
			}
		}
	},
	{
		"HEAD OF THE HEI",
		{ "Reverted Cursory Impact being able to Frame" }
	},
	{
		"CURSED PARTNERS",
		{
			"Added new run animations to certain attacks during Authentic Mutual Love",
			"Improved the visuals of Thin Ice Breaker during Authentic Mutual Love",
			"Added new animations for certain copied techniques during Authentic Mutual Love"
		}
	},
	{
		"BEAMS",
		{
			"Beam clashing duration increased by 5 seconds (5 -> 10)",
			"Beam clashing duration after someone wins increased by 1 second (2 -> 3)",
			"Beams now all have the same start clashing weight"
		}
	},
	{
		"SHOP",
		{
			{
				"NEW CONTENT",
				{
					"Added 13 new emotes (Beat It, MewMew, Shwifty, Distraction, Yo-yo Walk, Sentadao, Livesey Walk, Let's Groove, Upside Down, Pistol Trick, Gravestone, Everyone is dancing!, Shout)",
					"Added some new items to the merch tab!"
				}
			},
			{
				"GENERAL",
				{ "Replaced the gifting icon to something more fitting" }
			},
			"Improved visuals of style emotes (Crane, Snake, Tiger, Boxer)",
			"Added a few more poses to Stand Proud emote",
			"Reanimated Big Shoe and Taka La",
			"Fixed Mayhem emote music"
		}
	},
	{
		"BUILD MODE & SKILL BUILDER",
		{
			{
				"NEW CONTENT",
				{ "Added custom awakening colors" }
			},
			{
				"GENERAL",
				{
					"Renamed a certain item to follow the naming scheme of future exclusive weapons",
					"Made it easier to drag through lists without accidentally clicking buttons on console and mobile"
				}
			},
			{
				"BUILD MODE",
				{
					"Slightly tweaked some of the exclusive weapons in build mode",
					"Improved the amount of data used to store parts with similar properties"
				}
			},
			{
				"SKILL BUILDER",
				{ "Particle Nodes now respect creator clash visual limits" }
			}
		}
	},
	{
		"ROULETTE",
		{
			"Temporarily readded Final Showdown (Current rework taking too long)",
			"Changed the ratio of curses and sorcerers in EOJ from 50/50 to 20/80"
		}
	},
	{
		"BUG FIXES",
		{
			"Fixed text spacing in Update Log",
			"Fixed Detach not reflecting properly",
			"Fixed stun breaking if hit at specific times",
			"Fixed the right side of Workshop being bugged",
			"Fixed Second Wind grab keeping you in the air",
			"Fixed Headcam fun setting not respecting vertical movement",
			"Fixed Speed Crash not aligning properly on the grab version",
			"Fixed Particle Nodes not respecting creator clash visual limits",
			"Fixed stun breaking for certain custom movesets when used by NPCs",
			"Fixed not being able to copy paste character export codes on mobile",
			"Fixed Transfigured Humans being incredibly strong when using Swift Kick",
			"Fixed Fleche Use Twice not working if there was a Detach projectile present",
			"Fixed \"You weren't invited\"'s projectile sometimes clipping through walls if aligned properly"
		}
	}
}

function controller.KnitStart(p)
	local logs = localPlayer.PlayerGui:WaitForChild("Menus").Group.Logs
	local updateTitle = logs.ScrollingFrame.UpdateTitle
	local updateText = logs.ScrollingFrame.UpdateInfo.UpdateText

	if text then
		updateTitle.Text = text
	end

	local v3 = "\n "
	local v4 = ""
	local v5 = 1
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function newSpacing(p2)
		local clone = updateText.Parent:Clone()
		clone.LayoutOrder += 1
		clone.Spacing.Size = UDim2.fromScale(p2 * 0.05, 0)
		clone.Parent = updateText.Parent.Parent
		updateText = clone.UpdateText
		updateText.Text = ""
		v5 = p2
		v6 = true
	end

	local listLog

	listLog = function(items, value: number?)
		local v7 = value or 1

		for k, item in items do
			if v5 ~= v7 then
				newSpacing(v7) -- equivalent call inferred; original call site unknown
			end

			local _, v8 = next(items, k)

			if type(item) == "table" then
				updateText.Text ..= `{v6 and "" or "\n"}- <b>{item[1]} :</b>`
				v4 ..= `\n\n{(" "):rep((v7 - 1) * 3)}- **{item[1]}:**`
				listLog(item[2], v7 + 1)

				if v8 then
					updateText.Text ..= "\n"
				end
			else
				updateText.Text ..= `{v6 and "" or "\n"}• {item}`
				v4 ..= `\n{(" "):rep((v7 - 1) * 3)}- {item}`
				v6 = false

				if v8 and type(v8) == "table" then
					updateText.Text ..= "\n"
				end
			end
		end
	end

	for _, update in p.Updates do
		local clone = updateText.Parent:Clone()
		clone.LayoutOrder += 1
		clone.Spacing.Size = UDim2.fromScale(0, 0)
		clone.Parent = updateText.Parent.Parent
		updateText = clone.UpdateText
		updateText.Text = ""
		v5 = 0
		v6 = true
		updateText.Text ..= v3 .. "<b>[ " .. update[1] .. " ]</b>"
		v4 ..= `\n\n**[ {update[1]} ]**`
		listLog(update[2])
		v3 = [[

 
 ]]
	end

	print(v4)
	logs:SetAttribute("Loaded", true)
end

function controller.KnitInit(_)
	v = Knit.GetController("FXController")
end

return controller