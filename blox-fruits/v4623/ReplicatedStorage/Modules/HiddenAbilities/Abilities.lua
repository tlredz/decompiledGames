require(game.ReplicatedStorage.BuildUtil)
require(script.Parent.Types)
local values = {}
local fruitsWithAbilities = {}
local values2 = {}
local values3 = {}

for k, v2 in pairs({
	["Control-Control"] = {
		{
			Mastery = 200,
			StorageName = "SpatialCutAuthorization",
			DisplayName = "Spatial Cut Authorization",
			EquippedDescription = "Holding and dragging M1 in Dagger Mode now releases damaging spatial cuts.",
			HiddenDescription = "Validate dimensional incision stability within controlled simulation parameters.",
			Cost = {
				Fragments = 500,
				EtcItems = {
					{
						Name = "Simulation Data",
						Amount = 100
					},
					{
						Name = "Scrap Metal",
						Amount = 30
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "SpatialCutAuthorization",
					Observation = "Controlled spatial incisions remain stable in a simulated environment.",
					Experiment = "Complete one Simulation Dungeon raid on Beginner difficulty."
				}
			}
		},
		{
			Mastery = 300,
			StorageName = "RoomRelocationProtocol",
			DisplayName = "Room Relocation Protocol",
			AbilitiesRequired = { "SpatialCutAuthorization" },
			EquippedDescription = "Reactivating Z outside the control room now relocates the room to your position.",
			HiddenDescription = "Assess spatial anchor integrity during repeated room relocation events.",
			Cost = {
				Fragments = 2000,
				EtcItems = {
					{
						Name = "Simulation Data",
						Amount = 200
					},
					{
						Name = "Scrap Metal",
						Amount = 20
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "RoomRelocationProtocol",
					Observation = "Remote control room redeployment maintains spatial coherence after displacement.",
					Experiment = "Complete three Simulation Dungeon raids on Beginner difficulty."
				}
			}
		},
		{
			Mastery = 500,
			StorageName = "TotalControlOverride",
			DisplayName = "Total Control Override",
			AbilitiesRequired = { "SpatialCutAuthorization", "RoomRelocationProtocol" },
			EquippedDescription = "Ultimate Control protocols are now fully synchronized.",
			HiddenDescription = "Trigger core resonance to evaluate authority-layer amplification effects.",
			Cost = {
				Fragments = 10000,
				EtcItems = {
					{
						Name = "Simulation Data",
						Amount = 2000
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "TotalControlOverride1",
					Observation = "Dimensional strain remains within tolerable limits under sustained spatial tearing.",
					Experiment = "Execute 100 spatial cuts by holding and dragging M1 in Dagger Mode."
				},
				{
					Goal = 1,
					ExperimentName = "TotalControlOverride2",
					Observation = "Core resonance amplifies spatial authority beyond safety thresholds.",
					Experiment = "Consume one additional Control Fruit."
				}
			}
		}
	},
	["Pain-Pain"] = {
		{
			Mastery = 200,
			StorageName = "InfernalEndurance",
			DisplayName = "Infernal Endurance",
			HiddenDescription = "Prolong awakened stability through extreme thermal exposure.",
			EquippedDescription = "Increases the duration of Awakened Form.",
			Cost = {
				Fragments = 1000,
				EtcItems = {
					{
						Name = "Magma Ore",
						Amount = 1
					},
					{
						Name = "Ectoplasm",
						Amount = 2
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "InfernalEndurance",
					Observation = "Users maintained awakened energy under lava exposure.",
					Experiment = "Walk across molten surfaces for five continuous minutes to calibrate awakened endurance."
				}
			}
		},
		{
			Mastery = 300,
			StorageName = "AgonySurge",
			DisplayName = "Agony Surge",
			AbilitiesRequired = { "InfernalEndurance" },
			HiddenDescription = "Assess rapid absorption efficiency during aerial dash maneuvers.",
			EquippedDescription = "F Held unlocks the power of a Drop Kick explosion.",
			Cost = {
				Fragments = 2500,
				EtcItems = {
					{
						Name = "Magma Ore",
						Amount = 2
					},
					{
						Name = "Ectoplasm",
						Amount = 4
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "AgonySurge",
					Observation = "Multiple ghost absorptions increase destructive yield of dash impacts.",
					Experiment = "Absorb five Pain Ghosts in a single F-dash 10 times in a row."
				}
			}
		},
		{
			Mastery = 400,
			StorageName = "TormentConductor",
			DisplayName = "Torment Conductor",
			AbilitiesRequired = { "InfernalEndurance", "AgonySurge" },
			HiddenDescription = "Evaluate combat adaptability against elemental opponents.",
			EquippedDescription = "Z Tap blast Pain Ghosts now heat seek toward enemies.",
			Cost = {
				Fragments = 6000,
				EtcItems = {
					{
						Name = "Nightmare Catcher",
						Amount = 1
					},
					{
						Name = "Ectoplasm",
						Amount = 5
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "TormentConductor",
					Observation = "Ghosts demonstrate targeting improvements after electrical combat trials.",
					Experiment = "Defeat one Lightning Fruit user in PvP to unlock adaptive targeting behavior."
				}
			}
		},
		{
			Mastery = 500,
			StorageName = "SpectralAssimilation",
			DisplayName = "Spectral Assimilation",
			AbilitiesRequired = { "InfernalEndurance", "AgonySurge", "TormentConductor" },
			HiddenDescription = "Test absorption thresholds against sustained spectral intake.",
			EquippedDescription = "C Held will now unleash a chargeable beam.",
			Cost = {
				Fragments = 9500,
				EtcItems = {
					{
						Name = "Nightmare Catcher",
						Amount = 3
					},
					{
						Name = "Ectoplasm",
						Amount = 5
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "SpectralAssimilation",
					Observation = "Energy capacity rises proportionally with ghost absorption volume.",
					Experiment = "Absorb 200 Pain Ghosts to verify enhanced beam-channeling capabilities."
				}
			}
		}
	},
	["Lightning-Lightning"] = {
		{
			Mastery = 200,
			StorageName = "LL1",
			DisplayName = "Arc Discharge Protocol",
			HiddenDescription = "Stabilizes hand surges, producing sharper and stronger electrical strikes.",
			EquippedDescription = "Lightning Orbs recharge faster.",
			Cost = {
				Fragments = 1500,
				EtcItems = {
					{
						Name = "Angel Wings",
						Amount = 3
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "LLE1",
					Observation = "Channel concentrated electrical surges from your hands to neutralize 25 hostile targets.",
					Experiment = "Get 25 NPC Kills with Lightning M1"
				}
			}
		},
		{
			Mastery = 300,
			StorageName = "LL2",
			DisplayName = "Predator Circuit Breaker",
			AbilitiesRequired = { "LL1" },
			HiddenDescription = "Strengthens discharge output, increasing damage against resistant enemies.",
			EquippedDescription = "X Ability clouds can reabsorb your Z energy to combo extend lightning.",
			Cost = {
				Fragments = 3000,
				EtcItems = {
					{
						Name = "Electric Wing",
						Amount = 3
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "LLE2",
					Observation = "Conduct predator-neutralization trials against 30 electrically-charged aquatic specimens.",
					Experiment = "Defeat 30 Electric Piranhas"
				}
			}
		},
		{
			Mastery = 400,
			StorageName = "LL3",
			DisplayName = "Capacitor Overload Test",
			AbilitiesRequired = { "LL1", "LL2" },
			HiddenDescription = "Raises energy capacity, allowing more frequent lightning discharges.",
			EquippedDescription = "A fully charged Z3 Lightning Dragon can now grab players. ",
			Cost = {
				Fragments = 6000,
				EtcItems = {
					{
						Name = "Electric Wing",
						Amount = 5
					},
					{
						Name = "Volt Capsule",
						Amount = 1
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "LLE3",
					Observation = "Log and expend 200 controlled electrical discharges to gauge charge endurance limits.",
					Experiment = "Use a Total of 200 Charges on Your Fruit"
				}
			}
		},
		{
			Mastery = 500,
			StorageName = "LL4",
			DisplayName = "Conductor’s Resonance",
			AbilitiesRequired = { "LL1", "LL2", "LL3" },
			HiddenDescription = "Boosts natural conductivity, letting you handle more Lightning power.",
			EquippedDescription = "Z3 Lightning Dragon used into the Lightning X clouds will release an even stronger dragon.",
			Cost = {
				Fragments = 11000,
				EtcItems = {
					{
						Name = "Electric Wing",
						Amount = 5
					},
					{
						Name = "Volt Capsule",
						Amount = 3
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "LLE4",
					Observation = "Analyze power fluctuations by consuming Lightning Fruit samples for field integration tests.",
					Experiment = "Consume 1 additional physical Lightning Fruit"
				}
			}
		}
	},
	["Eagle-Eagle"] = {
		{
			Mastery = 200,
			StorageName = "EagleSpeed",
			DisplayName = "Aerodynamic Feathers",
			HiddenDescription = "Enhances feather surface structure to improve flight velocity.",
			EquippedDescription = "Increased F flight speed",
			Cost = {
				Fragments = 300,
				EtcItems = {
					{
						Name = "Angel Wings",
						Amount = 5
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "EagleSpeed",
					Observation = "Investigate if flying at high altitudes will affect flying ability.",
					Experiment = "Fly above 2,000 studs in the air."
				}
			}
		},
		{
			Mastery = 300,
			StorageName = "EagleMeter",
			DisplayName = "Flight Capacitor",
			AbilitiesRequired = { "EagleSpeed" },
			HiddenDescription = "Efficiently store wind energy, expanding power reserves.",
			EquippedDescription = "Increased Feathers Meter",
			Cost = {
				Fragments = 800,
				EtcItems = {
					{
						Name = "Fool's Gold",
						Amount = 2
					},
					{
						Name = "Angel Wings",
						Amount = 6
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "EagleMeter",
					Observation = "Investigate maximum power output while flying.",
					Experiment = "Use skills on enemies while flying."
				}
			}
		},
		{
			Mastery = 400,
			StorageName = "EagleCharge",
			DisplayName = "Avian Propulsion",
			AbilitiesRequired = { "EagleSpeed", "EagleMeter" },
			HiddenDescription = "Activates feather thrusters for acceleration bursts.",
			EquippedDescription = "Unlocked F dash ability",
			Cost = {
				Fragments = 1500,
				EtcItems = {
					{
						Name = "Angel Wings",
						Amount = 5
					},
					{
						Name = "Electric Wing",
						Amount = 5
					},
					{
						Name = "Fire Feather",
						Amount = 3
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "EagleCharge",
					Observation = "Use charged explosive feathers to evaluate damage effectiveness.",
					Experiment = "Use the charged M1 ability to defeat 10 enemies."
				}
			}
		}
	},
	["Gravity-Gravity"] = {
		{
			Mastery = 200,
			StorageName = "KineticAmplifier1",
			DisplayName = "Kinetic Amplifier",
			HiddenDescription = "Generates intense gravity waves to repel nearby enemies.",
			EquippedDescription = "Unlocked click/tap ability stage 1",
			Cost = {
				Fragments = 1000,
				EtcItems = {
					{
						Name = "Radioactive Material",
						Amount = 2
					},
					{
						Name = "Mystic Droplet",
						Amount = 1
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "KineticAmplifier1",
					Observation = "Assess enemy movement under brief gravity distortion.",
					Experiment = "Defeat 15 enemies with M1 / Tap abilities using Gravity."
				}
			}
		},
		{
			Mastery = 300,
			StorageName = "KineticAmplifier2",
			DisplayName = "Kinetic Amplifier 2",
			AbilitiesRequired = { "KineticAmplifier1" },
			HiddenDescription = "Generates stronger gravity waves to repel nearby enemies.",
			EquippedDescription = "Unlocked click/tap ability stage 2",
			Cost = {
				Fragments = 2000,
				EtcItems = {
					{
						Name = "Radioactive Material",
						Amount = 4
					},
					{
						Name = "Mystic Droplet",
						Amount = 2
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "KineticAmplifier2",
					Observation = "Assess enemy movement under brief gravity distortion.",
					Experiment = "Defeat 30 enemies with M1 / Tap abilities using Gravity."
				}
			}
		},
		{
			Mastery = 400,
			StorageName = "DarkMatterImplosion",
			DisplayName = "Dark Matter Implosion",
			AbilitiesRequired = { "KineticAmplifier1", "KineticAmplifier2" },
			HiddenDescription = "Activates violent implosion on suspended matter.",
			EquippedDescription = "Unlocked C ability ultimate",
			Cost = {
				Fragments = 6000,
				EtcItems = {
					{
						Name = "Radioactive Material",
						Amount = 6
					},
					{
						Name = "Mystic Droplet",
						Amount = 4
					},
					{
						Name = "Meteorite",
						Amount = 1
					}
				}
			},
			Experiments = {
				{
					Goal = 1,
					ExperimentName = "DarkMatterImplosion",
					Observation = "Investigate whether ships can move faster by eliminating water resistance.",
					Experiment = "Use Gravity Fruit skills on ships 20 times."
				}
			}
		},
		{
			Mastery = 500,
			StorageName = "CelestialCataclysm",
			DisplayName = "Celestial Cataclysm",
			AbilitiesRequired = { "DarkMatterImplosion", "KineticAmplifier1", "KineticAmplifier2" },
			HiddenDescription = "Triggers lunar rupture, unleashing cosmic devastation.",
			EquippedDescription = "Unlocked V ability ultimate",
			Cost = {
				Fragments = 10000,
				EtcItems = {
					{
						Name = "Mystic Droplet",
						Amount = 8
					},
					{
						Name = "Meteorite",
						Amount = 2
					},
					{
						Name = "Moonstone",
						Amount = 2
					}
				}
			},
			Experiments = {
				{
					Goal = 0.2,
					ExperimentName = "MeteorV1",
					Observation = "Do meteors sink or float?",
					Experiment = "Use Gravity Fruit to throw meteors into the sea."
				},
				{
					Goal = 0.8,
					ExperimentName = "MeteorV2",
					Observation = "The earth's rotation has accelerated unnaturally. Identify and neutralize the excessive gravitational anomalies.",
					Experiment = "Defeat the Gravity Fruit Boss \"Orbitus\" or players using Gravity Fruit."
				}
			}
		}
	}
}) do
	assert(values[k] == nil)
	table.insert(fruitsWithAbilities, k)
	local values4 = {}

	for k2, v3 in pairs(v2) do
		local v4 = assert(v3.Experiments)
		local storageName = assert(v3.StorageName)
		assert(values2[v3.StorageName] == nil, (`Duped ability storage name: {v3.StorageName}`))
		local values5 = {}

		for k3, v6 in pairs(v4) do
			assert(values3[v6.ExperimentName] == nil, (`Duped experiment storage name: {v6.ExperimentName}`))
			table.insert(values5, table.freeze({
				ExperimentIndex = k3,
				Observation = assert(v6.Observation),
				Experiment = assert(v6.Experiment),
				ExperimentName = assert(v6.ExperimentName),
				Goal = assert(v6.Goal)
			}))
			values3[v6.ExperimentName] = table.freeze({
				ExperimentIndex = k3,
				AbilityStorageName = v3.StorageName,
				FruitName = k
			})
		end

		local RunService = game:GetService("RunService")

		if RunService:IsStudio() then
			local RunService2 = game:GetService("RunService")

			if RunService2:IsServer() then
				local v6 = v3
				task.delay(3, function()
					for k3, etcItem in pairs(v6.Cost.EtcItems) do
						local Material = require(game.ReplicatedStorage.Modules.Asset.ItemData.Types.Material)

						if not Material[etcItem.Name] then
							task.spawn(error, (`Material isn't in materials: {etcItem.Name}`))
						end
					end
				end)
			end
		end

		local v6 = {
			AbilityIndex = k2,
			Mastery = assert(v3.Mastery),
			StorageName = storageName,
			DisplayName = assert(v3.DisplayName),
			HiddenDescription = assert(v3.HiddenDescription),
			EquippedDescription = assert(v3.EquippedDescription),
			Experiments = values5,
			FruitName = k,
			Cost = assert(v3.Cost),
			AbilitiesRequired = table.freeze(v3.AbilitiesRequired or {})
		}
		values2[v3.StorageName] = table.freeze({
			FruitName = k,
			AbilityIndex = k2
		})
		table.insert(values4, table.freeze(v6))
	end

	values[k] = table.freeze(values4)
end

table.freeze(values)
table.freeze(values3)
table.freeze(values2)
local Abilities = {}
Abilities.ComingSoon = { "Creation-Creation" }
Abilities.FruitsWithAbilities = fruitsWithAbilities

function Abilities.ExperimentFromStorageName(p: string)
	local v2 = assert(values3[p], p)
	local v3 = assert(values2[v2.AbilityStorageName], v2.AbilityStorageName)
	return values[v2.FruitName][v3.AbilityIndex].Experiments[v2.ExperimentIndex]
end

function Abilities.AbilitiesFromFruitName(p: string)
	return values[p]
end

function Abilities.AbilityFromStorageName(p: string)
	local v2 = values2[p]

	if v2 then
		return values[v2.FruitName][v2.AbilityIndex]
	end

	return nil
end

function Abilities.AbilityFromExperimentName(p: string)
	local v2 = assert(values3[p], p)
	local v3 = assert(values2[v2.AbilityStorageName], v2.AbilityStorageName)
	return values[v2.FruitName][v3.AbilityIndex]
end

return Abilities