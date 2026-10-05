local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ClanTypes)
return {
	STORED_DAMAGE = "Stored Damage x 0.1 becomes Damage Potential, which is added to the user's Weapon and Breathing or Demon Art damage. Pressing the key again ends storage early and cashes it in; letting the window run out cashes it in anyway. The bonus lasts 7 seconds.",
	PainResistance = table.freeze({
		name = "Pain Resistance",
		description = "The user is not slowed at low health."
	}),
	TacticalIntellect = table.freeze({
		name = "Tactical Intellect",
		description = "+25% Quest Exp Factor.",
		effects = table.freeze({ table.freeze({
				stats = table.freeze({
					["Quest Exp Factor"] = 0.25
				})
			}) })
	}),
	MasterSwordsman = table.freeze({
		name = "Master Swordsman",
		description = "+20% Katana and Weapon mastery."
	}),
	EnhancedSpeed = table.freeze({
		name = "Enhanced Speed",
		description = "+5% Movement Speed Factor.",
		effects = {
			{
				stats = {
					["Movement Speed Factor"] = 0.05
				}
			}
		}
	}),
	IndomitableWillImmunity = table.freeze({
		name = "Indomitable Will Immunity",
		description = "Immune to Indomitable Will.",
		immunities = { "Indomitable Will" }
	}),
	FamilyBond = table.freeze({
		name = "Family Bond",
		description = "+5% Health Regen Speed while partied with another member of the family: Aori, Aoshima, Kaneki, Kurotsume, or Yamagiri."
	}),
	WaterFamilyBond = table.freeze({
		name = "Family Bond",
		description = "+15% Water Damage Factor while partied with Makomo's or Sabito's family."
	}),
	PartyBuff = table.freeze({
		name = "Party Buff",
		description = "While partied with Susumaru or Yahaba, gain +10% Evil Art Damage Factor and +10% Additional Damage Factor."
	}),
	IndomitableWill = table.freeze({
		name = "Indomitable Will",
		cooldown = 90,
		maxHold = 0.32,
		description = "Two activation methods. Tap: a burst around the user that shoves nearby enemies away, stuns them briefly and marks them with Fear, slowing their movement and their dash. Hold: a much larger zone placed where the user is standing, stunning everyone inside for as long as they stay and stunning them again on the way out."
	}),
	GhostAttendanceMode = table.freeze({
		name = "Ghost Attendance Mode",
		mode = true,
		cooldown = 90,
		modeCost = 180,
		aura = "White",
		description = "Mode. Grants +100% Dash Speed Factor and +15% Sword Damage Factor."
	})
}