local MonsterAudioConfig = {
	CommonSounds = {
		GenericFootstep = 9112872890,
		GenericGrowl = 9113542790
	},
	Monsters = {
		AstroMonster = {
			name = "Astro",
			footsteps = {
				ids = {
					88379888135779,
					81609844912052,
					74707990413706,
					124987936082936
				},
				volume = 0.5,
				pitch = {
					min = 0.95,
					max = 1.05
				}
			},
			attack = {
				id = 89251389972741,
				volume = 0.8
			},
			growl = {
				id = 117296839890044,
				volume = 0.7
			},
			frustrated = {
				id = 114412574299306,
				volume = 0.6
			},
			bark = {
				id = 108620618206247,
				volume = 0.8
			},
			randomGrowl = {
				ids = {
					17651357204,
					17651357803,
					17651357443,
					17651357982
				},
				volume = 0.5,
				interval = {
					min = 18,
					max = 25
				}
			}
		},
		DandyMonster = {
			name = "Dandy",
			footsteps = {
				ids = {
					9113040889,
					9113041192,
					9113041470,
					9113041717
				},
				volume = 0.6,
				pitch = {
					min = 0.95,
					max = 1.05
				}
			},
			attack = {
				id = 9112893406,
				volume = 0.8
			},
			song = {
				id = 9112846997,
				volume = 0.4,
				looped = true
			}
		},
		SproutMonster = {
			name = "Sprout",
			footsteps = {
				ids = {
					114908174308095,
					117668285696405,
					136339547591167,
					95396604116757
				},
				volume = 0.45,
				pitch = {
					min = 0.95,
					max = 1.05
				}
			},
			attack = {
				ids = { 91899929979893, 98728098645549, 93159022426970 },
				volume = 0.7
			},
			growl = {
				id = 73085889015282,
				volume = 0.6
			},
			frustrated = {
				id = 107858949003631,
				volume = 0.5
			},
			bark = {
				id = 115600093082915,
				volume = 0.7
			},
			randomGrowl = {
				ids = {
					1218868653,
					1220649009,
					18698376746,
					18698377096
				},
				volume = 0.45,
				interval = {
					min = 18,
					max = 25
				}
			}
		},
		ShellyMonster = {
			name = "Shelly",
			footsteps = {
				ids = {
					107766046847282,
					84788917044095,
					88099689131571,
					135694387989424
				},
				volume = 0.5,
				pitch = {
					min = 0.95,
					max = 1.05
				}
			},
			attack = {
				id = 76115766556139,
				volume = 0.7
			},
			growl = {
				id = 105179878541376,
				volume = 0.6
			},
			frustrated = {
				id = 103389609088614,
				volume = 0.5
			},
			bark = {
				id = 84050299313124,
				volume = 0.7
			},
			randomGrowl = {
				ids = {
					4510529544,
					902941747,
					9120047517,
					634635257
				},
				volume = 0.45,
				interval = {
					min = 18,
					max = 25
				}
			}
		},
		VeeMonster = {
			name = "Vee",
			footsteps = {
				ids = {
					97666296968696,
					100046355571654,
					114107858851168,
					96098888631406
				},
				volume = 0.5,
				pitch = {
					min = 0.95,
					max = 1.05
				}
			},
			attack = {
				id = 133553055604695,
				volume = 0.7
			},
			growl = {
				id = 95591159159574,
				volume = 0.6
			},
			frustrated = {
				id = 136555547867867,
				volume = 0.5
			},
			bark = {
				id = 135018098411614,
				volume = 0.7
			}
		},
		GourdyMonster = {
			name = "Gourdy",
			footsteps = {
				ids = {
					105855215583914,
					94607725831117,
					95890466844834,
					129503716657379
				},
				volume = 0.5,
				pitch = {
					min = 0.95,
					max = 1.05
				}
			},
			attack = {
				id = 76359685337874,
				volume = 0.7
			},
			spotted = {
				ids = { 92357728809456, 97057202120321, 108964547168210 },
				volume = 0.6
			},
			lostInterest = {
				ids = { 117469193849545, 118621022288747, 116941284531122 },
				volume = 0.5
			},
			groundedHappy = {
				id = 127316477310608,
				volume = 0.5
			},
			groundedAngry = {
				id = 127316477310608,
				volume = 0.5
			},
			emergence = {
				id = 85424880416107,
				volume = 0.8
			},
			feeding = {
				id = 109785620908655,
				volume = 0.5
			},
			rage = {
				id = 106310095668891,
				volume = 0.7
			}
		},
		PebbleMonster = {
			name = "Pebble",
			footsteps = {
				ids = {
					101411823990015,
					134155424451012,
					85308159538908,
					90660689600109
				},
				volume = 0.4,
				pitch = {
					min = 0.95,
					max = 1.05
				}
			},
			attack = {
				id = 138252115478839,
				volume = 0.7
			},
			growl = {
				id = 87890073912215,
				volume = 0.6
			},
			frustrated = {
				id = 127880668106915,
				volume = 0.5
			},
			bark = {
				id = 104499899949766,
				volume = 0.7
			},
			randomGrowl = {
				ids = {
					9120788178,
					9113635074,
					4064886644,
					4536602370
				},
				volume = 0.4,
				interval = {
					min = 18,
					max = 25
				}
			},
			growlLoop = {
				id = 89251389972741,
				volume = 0.3,
				looped = true
			}
		},
		BobetteMonster = {
			name = "Bobette",
			footsteps = {
				ids = {
					130447610693399,
					74116706203424,
					139166107306403,
					103016741765927
				},
				volume = 0.4,
				pitch = {
					min = 0.95,
					max = 1.05
				}
			},
			attack = {
				id = 120085376755878,
				volume = 0.7
			},
			growl = {
				id = 90174820571096,
				volume = 0.6
			},
			frustrated = {
				id = 91177553181371,
				volume = 0.5
			},
			bark = {
				id = 130379399959879,
				volume = 0.7
			},
			randomGrowl = {
				ids = {
					118350511182583,
					118350511182583,
					118350511182583,
					118350511182583
				},
				volume = 0.45,
				interval = {
					min = 18,
					max = 25
				}
			}
		},
		DyleMonster = {
			name = "Dyle",
			footsteps = {
				ids = {
					9114143296,
					9114143594,
					9114143827,
					9114144062
				},
				volume = 0.5,
				pitch = {
					min = 0.95,
					max = 1.05
				}
			},
			attack = {
				id = 88631706022800,
				volume = 0.8
			},
			growl = {
				id = 90658174667858,
				volume = 0.7
			},
			frustrated = {
				id = 93181188024016,
				volume = 0.6
			},
			bark = {
				id = 84912877037867,
				volume = 0.8
			}
		}
	},
	SoundGroups = {
		footsteps = "Footsteps",
		attack = "MonsterCombat",
		growl = "MonsterState",
		frustrated = "MonsterState",
		bark = "MonsterState",
		spotted = "MonsterState",
		lostInterest = "MonsterState",
		rage = "MonsterState",
		emergence = "MonsterState",
		randomGrowl = "MonsterAmbient",
		idle = "MonsterAmbient",
		growlLoop = "MonsterAmbient",
		feeding = "MonsterAmbient",
		groundedHappy = "MonsterAmbient",
		groundedAngry = "MonsterAmbient",
		song = "MonsterMusic"
	},
	VolumeReview = {}
}

function MonsterAudioConfig.GetMonsterConfig(p)
	return MonsterAudioConfig.Monsters[p]
end

function MonsterAudioConfig.GetSoundGroup(p)
	return MonsterAudioConfig.SoundGroups[p] or "Master"
end

function MonsterAudioConfig.GetMonstersWithSoundType(p)
	local result = {}

	for k, monster in pairs(MonsterAudioConfig.Monsters) do
		if monster[p] then
			table.insert(result, k)
		end
	end

	return result
end

function MonsterAudioConfig.GetRandomFootstepId(p)
	local monster = MonsterAudioConfig.Monsters[p]

	if monster and monster.footsteps and monster.footsteps.ids then
		local ids = monster.footsteps.ids
		return ids[math.random(1, #ids)]
	else
		return nil
	end
end

function MonsterAudioConfig.GetRandomGrowlId(p)
	local monster = MonsterAudioConfig.Monsters[p]

	if monster and monster.randomGrowl and monster.randomGrowl.ids then
		local ids = monster.randomGrowl.ids
		return ids[math.random(1, #ids)]
	else
		return nil
	end
end

function MonsterAudioConfig.GetAttackId(p)
	local monster = MonsterAudioConfig.Monsters[p]

	if monster and monster.attack then
		if monster.attack.ids then
			return monster.attack.ids[math.random(1, #monster.attack.ids)]
		end

		if monster.attack.id then
			return monster.attack.id
		end
	end

	return nil
end

function MonsterAudioConfig.GetAllSoundIds()
	local v = {}
	local ids = {}

	for _, monster in pairs(MonsterAudioConfig.Monsters) do
		for _, v2 in pairs(monster) do
			if type(v2) ~= "table" then
				continue
			end

			if v2.id and not v[v2.id] then
				v[v2.id] = true
				table.insert(ids, v2.id)
			end

			if not v2.ids then
				continue
			end

			for _, id in ipairs(v2.ids) do
				if v[id] then
					continue
				end

				v[id] = true
				table.insert(ids, id)
			end
		end
	end

	return ids
end

function MonsterAudioConfig.GetPreloadList()
	local result = {}

	for k in pairs(MonsterAudioConfig.GetAllSoundIds()) do
		table.insert(result, "rbxassetid://" .. tostring(k))
	end

	return result
end

return MonsterAudioConfig