local createVector = vector.create
local HitCallbacks = require(script.HitCallbacks)
local equipAnimations = script.EquipAnimations
local propelVictim = HitCallbacks.PropelVictim(0.2, 10)
local v = {
	ArmsAndLegs = {
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot"
	},
	Arms = {
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand"
	},
	Legs = {
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot"
	}
}
local _ = {
	Idle = {
		AnimationId = "rbxassetid://3255416672"
	}
}
local actions = {
	Idle = {
		AnimationId = "rbxassetid://8994252874"
	}
}
local actions2 = {
	Idle = {
		AnimationId = "rbxassetid://8994244101"
	}
}
local _ = {
	Idle = {
		AnimationId = "rbxassetid://3027921478"
	}
}
local actions3 = {
	Idle = {
		AnimationId = "rbxassetid://10432912847"
	}
}
local actions4 = {
	Idle = {
		AnimationId = "rbxassetid://9897436286"
	}
}
local WeaponData = {
	combat = {
		SwingSound = "MeleeSwing",
		WeaponType = "Melee",
		HitboxLimbs = v.ArmsAndLegs,
		HitboxMagnitude = 2,
		Moveset = {
			Basic = {
				{
					AnimationId = "rbxassetid://9811875121",
					Damage = 9,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9811875901",
					Damage = 9,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9811878081",
					Damage = 9,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9811879387",
					Damage = 9,
					HitCallback = HitCallbacks.PropelVictim(0.25, 55)
				}
			},
			Actions = {
				Idle = {
					AnimationId = "rbxassetid://9811880619"
				}
			}
		}
	},
	advancedcombat = {
		SwingSound = "MeleeSwing",
		WeaponType = "Melee",
		HitboxLimbs = v.ArmsAndLegs,
		HitboxMagnitude = 2,
		Moveset = {
			Basic = {
				{
					AnimationId = "rbxassetid://9811875121",
					Damage = 19,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9811875901",
					Damage = 19,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9811878081",
					Damage = 19,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9811879387",
					Damage = 19,
					HitCallback = HitCallbacks.PropelVictim(0.25, 55)
				}
			},
			Actions = {
				Idle = {
					AnimationId = "rbxassetid://9811880619"
				}
			}
		}
	},
	electro = {
		HitSound = "Hit1Electric",
		SwingSound = "MeleeSwing",
		WeaponType = "Melee",
		HitboxLimbs = v.Arms,
		HitboxMagnitude = 2,
		Moveset = {
			Basic = {
				{
					AnimationId = "rbxassetid://9841321154",
					Damage = 17,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841321918",
					Damage = 17,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841322925",
					Damage = 17,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841323885",
					Damage = 18,
					HitCallback = HitCallbacks.PropelVictim(0.25, 55)
				}
			},
			Actions = {
				Idle = {
					AnimationId = "rbxassetid://9841324959"
				}
			}
		}
	},
	electricclaw = {
		HitSound = "QuickSliceElectric",
		WeaponType = "Melee",
		HitboxLimbs = v.Arms,
		HitboxMagnitude = 2,
		Moveset = {
			Basic = {
				{
					AnimationId = "rbxassetid://9841344725",
					Damage = 22,
					PushDelay = 0.2,
					PushForce = 50,
					HitCallback = HitCallbacks.PropelVictim(0.25, 55)
				},
				{
					AnimationId = "rbxassetid://9841347141",
					Damage = 22,
					PushDelay = 0.2,
					PushForce = 50,
					HitCallback = HitCallbacks.PropelVictim(0.25, 55)
				},
				{
					AnimationId = "rbxassetid://9841347753",
					Damage = 22,
					PushDelay = 0.2,
					PushForce = 50,
					HitCallback = HitCallbacks.PropelVictim(0.25, 55)
				},
				{
					AnimationId = "rbxassetid://9841348546",
					Damage = 22,
					PushDelay = 0.2,
					PushForce = 50,
					HitCallback = HitCallbacks.PropelVictim(0.25, 55)
				}
			},
			Actions = {
				Idle = {
					AnimationId = "rbxassetid://9841350003"
				}
			}
		}
	},
	fishmankarate = {
		HitSound = "WaterHit",
		SwingSound = "MeleeSwing",
		WeaponType = "Melee",
		HitboxLimbs = v.Arms,
		HitboxMagnitude = 2,
		Moveset = {
			Basic = {
				{
					AnimationId = "rbxassetid://9841326790",
					Damage = 18,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841328846",
					Damage = 18,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841331261",
					Damage = 18,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841332216",
					Damage = 18.5,
					HitCallback = HitCallbacks.PropelVictim(0.25, 100)
				}
			},
			Actions = {
				Idle = {
					AnimationId = "rbxassetid://9841333648"
				}
			}
		}
	},
	sharkmankarate = {
		HitSound = "WaterHit",
		CustomSound = true,
		SwingSound = "MeleeSwing",
		WeaponType = "Melee",
		HitboxLimbs = v.Arms,
		HitboxMagnitude = 6.666,
		Moveset = {
			Basic = {
				{
					AnimationId = "rbxassetid://115624290273861",
					Damage = 22,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://105473986330400",
					Damage = 22,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://92961124744913",
					Damage = 22,
					PushDelay = 0.01,
					PushForce = 140,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://113618863770437",
					Damage = 22,
					AOEDelay = 0.38,
					AOESize = 15,
					AOEDistanceFromCharacter = 5,
					CustomAOEEffect = true,
					HitCallback = HitCallbacks.PropelVictim(0.25, 100)
				}
			},
			Actions = {
				Idle = {
					AnimationId = "rbxassetid://9841333648"
				}
			}
		}
	},
	dragonclaw = {
		HitSound = "FireHit",
		SwingSound = "MeleeSwing",
		WeaponType = "Melee",
		HitboxLimbs = v.Arms,
		HitboxMagnitude = 2,
		Moveset = {
			Basic = {
				{
					AnimationId = "rbxassetid://9841334974",
					Damage = 20,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841336120",
					Damage = 20,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841337424",
					Damage = 20,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841338510",
					Damage = 20,
					PushDelay = 0.3,
					PushForce = 120,
					HitCallback = HitCallbacks.PropelVictim(0.25, 100)
				}
			},
			Actions = {
				Idle = {
					AnimationId = "rbxassetid://9841340380"
				}
			}
		}
	},
	dragontalon = {
		HitSound = "FireHit",
		SwingSound = "MeleeSwing",
		WeaponType = "Melee",
		HitboxLimbs = v.Arms,
		HitboxMagnitude = 2,
		Moveset = {
			Basic = {
				{
					AnimationId = "rbxassetid://9841334974",
					Damage = 23,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841336120",
					Damage = 23,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841337424",
					Damage = 23,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://9841338510",
					Damage = 24,
					PushDelay = 0.3,
					PushForce = 120,
					HitCallback = HitCallbacks.PropelVictim(0.25, 100)
				}
			},
			Actions = {
				Idle = {
					AnimationId = "rbxassetid://18884824068"
				}
			}
		}
	}
}

local function blacklegDamage(p, p2, p3)
	return function(instance, _)
		return instance:HasTag("Diablo") and (instance:HasTag("Diablo2") and p3 or p2) or p
	end
end

local blackleg = {
	SwingSound = "MeleeSwing",
	WeaponType = "Melee",
	HitboxLimbs = v.Legs,
	HitboxMagnitude = 2,
	Moveset = 0
}
local v9 = 18.5
local v10 = 16.5
local v11 = 13.5
local v13 = 18.5
local v14 = 16.5
local v15 = 13.5
local v17 = 18.5
local v18 = 16.5
local v19 = 13.5
local v21 = 19.5
local v22 = 17.5
local v23 = 15.5
blackleg.Moveset = {
	Basic = {
		{
			AnimationId = "rbxassetid://9811908324",
			Damage = function(instance, _)
				return instance:HasTag("Diablo") and (instance:HasTag("Diablo2") and v9 or v10) or v11
			end,
			HitCallback = propelVictim
		},
		{
			AnimationId = "rbxassetid://9811909720",
			Damage = function(instance, _)
				return instance:HasTag("Diablo") and (instance:HasTag("Diablo2") and v13 or v14) or v15
			end,
			HitCallback = propelVictim
		},
		{
			AnimationId = "rbxassetid://9811910794",
			Damage = function(instance, _)
				return instance:HasTag("Diablo") and (instance:HasTag("Diablo2") and v17 or v18) or v19
			end,
			HitCallback = propelVictim
		},
		{
			AnimationId = "rbxassetid://9811912343",
			Damage = function(instance, _)
				return instance:HasTag("Diablo") and (instance:HasTag("Diablo2") and v21 or v22) or v23
			end,
			HitCallback = HitCallbacks.PropelVictim(0.25, 55)
		}
	},
	Actions = {
		Idle = {
			AnimationId = "rbxassetid://9811914002"
		}
	}
}
WeaponData.blackleg = blackleg
local deathstep = {
	SwingSound = "MeleeSwing",
	WeaponType = "Melee",
	HitboxLimbs = v.Legs,
	HitboxMagnitude = 2,
	Moveset = 0
}
local v27 = 22
local v28 = 21
local v29 = 20
local v31 = 22
local v32 = 21
local v33 = 20
local v35 = 22
local v36 = 21
local v37 = 20
local v39 = 22
local v40 = 21
local v41 = 20
deathstep.Moveset = {
	Basic = {
		{
			AnimationId = "rbxassetid://9811908324",
			Damage = function(instance, _)
				return instance:HasTag("Diablo") and (instance:HasTag("Diablo2") and v27 or v28) or v29
			end,
			HitCallback = propelVictim
		},
		{
			AnimationId = "rbxassetid://9811909720",
			Damage = function(instance, _)
				return instance:HasTag("Diablo") and (instance:HasTag("Diablo2") and v31 or v32) or v33
			end,
			HitCallback = propelVictim
		},
		{
			AnimationId = "rbxassetid://9811910794",
			Damage = function(instance, _)
				return instance:HasTag("Diablo") and (instance:HasTag("Diablo2") and v35 or v36) or v37
			end,
			HitCallback = propelVictim
		},
		{
			AnimationId = "rbxassetid://9811912343",
			Damage = function(instance, _)
				return instance:HasTag("Diablo") and (instance:HasTag("Diablo2") and v39 or v40) or v41
			end,
			HitCallback = HitCallbacks.PropelVictim(0.25, 55)
		}
	},
	Actions = {
		Idle = {
			AnimationId = "rbxassetid://3406511948"
		}
	}
}
WeaponData.deathstep = deathstep
WeaponData.cyborgcombat = {
	SwingSound = "MeleeSwing",
	WeaponType = "Melee",
	HitboxMagnitude = 4,
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://3456195558",
				Damage = 17,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://3456254569",
				Damage = 17,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://3456293280",
				Damage = 18,
				HitCallback = HitCallbacks.PropelVictim(0.25, 100)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://3456662990"
			}
		}
	}
}
WeaponData.superhuman = {
	SwingSound = "MeleeSwing",
	WeaponType = "Melee",
	HitboxLimbs = v.Arms,
	HitboxMagnitude = 3,
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9841357920",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9841359181",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9841360542",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9841361025",
				Damage = 22,
				HitCallback = HitCallbacks.PropelVictim(0.25, 100)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://9841361789"
			}
		}
	}
}
WeaponData.godhuman = {
	SwingSound = "MeleeSwing",
	WeaponType = "Melee",
	HitboxLimbs = v.Arms,
	HitboxMagnitude = 3,
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9841357920",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9841359181",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9841360542",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9841361025",
				Damage = 23,
				HitCallback = HitCallbacks.PropelVictim(0.25, 100)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://9841361789"
			}
		}
	}
}
WeaponData.dualkatana = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10432908275",
				Damage = 10,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10433030019",
				Damage = 10.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10433031114",
				Damage = 10.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432911582",
				Damage = 12,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions3
	}
}
WeaponData.curseddualkatana = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.CursedDualKatana),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10432908275",
				Damage = 25,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10433030019",
				Damage = 25,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10433031114",
				Damage = 25,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432911582",
				Damage = 26,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions3
	}
}
WeaponData.twinhooks = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.TwinHooks),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10129764661",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129765479",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129766254",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129767328",
				Damage = 24,
				HitCallback = HitCallbacks.PropelVictim(0.25, 80)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://10129768335"
			}
		}
	}
}
WeaponData.triplekatana = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9897433972",
				Damage = 13,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897434364",
				Damage = 13.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897435270",
				Damage = 13.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897435626",
				Damage = 15,
				PushDelay = 0.25,
				PushForce = 90,
				HitCallback = HitCallbacks.PropelVictim(0.25, 75)
			}
		},
		Actions = actions4
	}
}
WeaponData.truetriplekatana = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9897433972",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897434364",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897435270",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897435626",
				Damage = 25,
				PushDelay = 0.25,
				PushForce = 200,
				HitCallback = HitCallbacks.PropelVictim(0.25, 120)
			}
		},
		Actions = actions4
	}
}
WeaponData.tripledarkblade = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.TripleDarkBlade),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9897433972",
				Damage = 34,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897434364",
				Damage = 34,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897435270",
				Damage = 34,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897435626",
				Damage = 35,
				PushDelay = 0.25,
				PushForce = 200,
				HitCallback = HitCallbacks.PropelVictim(0.25, 170)
			}
		},
		Actions = actions4
	}
}
WeaponData.cutlass = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://8994237743",
				Damage = 9,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994238649",
				Damage = 9,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994239701",
				Damage = 9,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994240917",
				Damage = 10,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions2
	}
}
WeaponData.katana = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://8994249326",
				Damage = 9,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994250307",
				Damage = 9,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994250941",
				Damage = 9,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994252279",
				Damage = 10,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions
	}
}
WeaponData.fishingtrophy = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://8994249326",
				Damage = 0.01,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994250307",
				Damage = 0.01,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994250941",
				Damage = 0.01,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994252279",
				Damage = 0.01,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions
	}
}
local actions5 = {
	Idle = {
		AnimationId = "rbxassetid://9400512594"
	}
}
local actions6 = {
	Idle = {
		AnimationId = "rbxassetid://10129760884"
	}
}
local actions7 = {
	Idle = {
		AnimationId = "rbxassetid://10129711980"
	}
}
local actions8 = {
	Idle = {
		AnimationId = "rbxassetid://10375985353"
	}
}
local actions9 = {
	Idle = {
		AnimationId = "rbxassetid://10375964637"
	}
}
local actions10 = {
	Idle = {
		AnimationId = "rbxassetid://10432969960"
	}
}
local actions11 = {
	Idle = {
		AnimationId = "rbxassetid://10375950022"
	}
}
local actions12 = {
	Idle = {
		AnimationId = "rbxassetid://10432944216"
	}
}
local actions13 = {}

for _, v64 in {
	"bronze",
	"silver",
	"gold",
	"platinum",
	"diamond",
	"master"
} do
	WeaponData[`{v64}trophy`] = {
		HitSound = "QuickSlice",
		WeaponType = "Sword",
		Moveset = {
			Basic = {
				{
					AnimationId = "rbxassetid://8994249326",
					Damage = 0.01,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://8994250307",
					Damage = 0.01,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://8994250941",
					Damage = 0.01,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://8994252279",
					Damage = 0.01,
					HitCallback = HitCallbacks.PropelVictim(0.25, 55)
				}
			},
			Actions = actions
		}
	}
end

WeaponData.sharksaw = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9400513669",
				Damage = 14,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9400514424",
				Damage = 14,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9400514970",
				Damage = 14,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9400515801",
				Damage = 16,
				AOEDelay = 0.35,
				HitCallback = HitCallbacks.PropelVictim(0.25, 160)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://9400516463"
			}
		}
	}
}
WeaponData.flail = {
	HitSound = "Hit1",
	WeaponType = "Sword",
	EquippedAttachmentName = "RootPart",
	EquipAnimation = require(equipAnimations.Flail),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://109333170641545",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://103627878051302",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://135129108529829",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://132290526770638",
				Damage = 22,
				PushDelay = 0.25,
				PushForce = 120,
				HitCallback = HitCallbacks.PropelVictim(0.25, 60)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://70849006611173"
			}
		}
	}
}
WeaponData.wardenssword = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9897431693",
				Damage = 16,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897432142",
				Damage = 16.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897432561",
				Damage = 16.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897432959",
				Damage = 17.5,
				HitCallback = HitCallbacks.PropelVictim(0.25, 70)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://9897433386"
			}
		}
	}
}
WeaponData.pipe = {
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9400509992",
				Damage = 15,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9400510558",
				Damage = 15,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9400511197",
				Damage = 16,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9400511670",
				Damage = 16.5,
				HitCallback = HitCallbacks.PropelVictim(0.25, 70)
			}
		},
		Actions = actions5
	}
}
WeaponData.ironmace = {
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9400507531",
				Damage = 12,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9400508063",
				Damage = 12.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9400508615",
				Damage = 13.5,
				AOEDelay = 0.35,
				HitCallback = HitCallbacks.PropelVictim(0.25, 160)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://9400509141"
			}
		}
	}
}
WeaponData.bisento = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.Bisento),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://8982040872",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8982041462",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8982042341",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8982043751",
				Damage = 23,
				AOEDelay = 0.275,
				HitCallback = HitCallbacks.PropelVictim(0.25, 160)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://8982044407"
			}
		}
	}
}
WeaponData.HallowScythe = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10129714021",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129752188",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129753089",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129754265",
				Damage = 21,
				HitCallback = propelVictim
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://10129755282"
			}
		}
	}
}
WeaponData.lightsword = {
	HitSound = "QuickSlice",
	WeaponType = "Demon Fruit",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10375972626",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375973840",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375974683",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375975514",
				Damage = 22,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://10375977428"
			}
		}
	}
}
WeaponData.icesword = {
	HitSound = "QuickSlice",
	WeaponType = "Demon Fruit",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10129756681",
				Damage = 19,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129757619",
				Damage = 20,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129759082",
				Damage = 20,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129759817",
				Damage = 21,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions6
	}
}
WeaponData.soulcane = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10129707298",
				Damage = 18,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129708538",
				Damage = 18,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129709852",
				Damage = 18,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129710763",
				Damage = 20,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions7
	}
}
WeaponData["Dual-Headed Blade"] = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9897747171",
				Damage = 17,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897748059",
				Damage = 17,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897748736",
				Damage = 17,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897749575",
				Damage = 19,
				HitCallback = HitCallbacks.PropelVictim(0.25, 70)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://9897750071"
			}
		}
	}
}
WeaponData["Pole (1st Form)"] = {
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9400509992",
				Damage = 19.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9400510558",
				Damage = 20,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9400511197",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9400511670",
				Damage = 22,
				HitCallback = HitCallbacks.PropelVictim(0.25, 75)
			}
		},
		Actions = actions5
	}
}
WeaponData.trident = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10129756681",
				Damage = 18.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129757619",
				Damage = 18.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129759082",
				Damage = 18.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129759817",
				Damage = 21,
				PushDelay = 0.35,
				PushForce = 100,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions6
	}
}
WeaponData.gravityblade = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.GravityBlade),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10129707298",
				Damage = 20,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129708538",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129709852",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10129710763",
				Damage = 23,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions7
	}
}
WeaponData.koko = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10375966902",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375967965",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375968860",
				Damage = 24,
				PushDelay = 0.25,
				PushForce = 125,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375969814",
				Damage = 24,
				HitCallback = HitCallbacks.PropelVictim(0.25, 80)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://10375971091"
			}
		}
	}
}
WeaponData.midnightblade = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10375979882",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375981285",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375982688",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375984145",
				Damage = 24,
				HitCallback = HitCallbacks.PropelVictim(0.25, 120)
			}
		},
		Actions = actions8
	}
}
WeaponData.rengoku = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.Rengoku),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10432929166",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432929963",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432930988",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432932017",
				Damage = 24,
				PushDelay = 0.35,
				PushForce = 140,
				HitCallback = HitCallbacks.PropelVictim(0.25, 80)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://70700381640299"
			}
		}
	}
}
WeaponData["Pole (2nd Form)"] = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10375957814",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375959340",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375962019",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375963331",
				Damage = 24,
				PushDelay = 0.35,
				PushForce = 190,
				HitCallback = HitCallbacks.PropelVictim(0.25, 120)
			}
		},
		Actions = actions9
	}
}
WeaponData.dragontrident = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10375957814",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375959340",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375962019",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375963331",
				Damage = 24,
				PushDelay = 0.35,
				PushForce = 140,
				HitCallback = HitCallbacks.PropelVictim(0.25, 120)
			}
		},
		Actions = actions9
	}
}
WeaponData.yama = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.Yama),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10432959069",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432961707",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432963001",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432966978",
				Damage = 25,
				PushDelay = 0.35,
				PushForce = 140,
				HitCallback = HitCallbacks.PropelVictim(0.25, 80)
			}
		},
		Actions = actions10
	}
}
WeaponData.tushita = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.Tushita),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10432959069",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432961707",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432963001",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432966978",
				Damage = 25,
				PushDelay = 0.35,
				PushForce = 140,
				HitCallback = HitCallbacks.PropelVictim(0.25, 80)
			}
		},
		Actions = actions10
	}
}

local function durandalEntry()
	return {
		HitSound = "QuickSlice",
		WeaponType = "Sword",
		Moveset = {
			Basic = {
				{
					AnimationId = "rbxassetid://10375944961",
					Damage = 23,
					PushDelay = 0.25,
					PushForce = 150,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://10375946029",
					Damage = 23.5,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://10375947187",
					Damage = 23.5,
					PushDelay = 0.25,
					PushForce = 150,
					HitCallback = propelVictim
				},
				{
					AnimationId = "rbxassetid://10375948760",
					Damage = 24,
					HitCallback = HitCallbacks.PropelVictim(0.25, 80)
				}
			},
			Actions = actions11
		}
	}
end

WeaponData.durandal = durandalEntry()
WeaponData.canvander = durandalEntry()
WeaponData.shizu = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10432940920",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432942138",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432942953",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432943600",
				Damage = 24,
				PushDelay = 0.35,
				PushForce = 140,
				HitCallback = HitCallbacks.PropelVictim(0.25, 80)
			}
		},
		Actions = actions12
	}
}
WeaponData.saishi = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10432934091",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432935142",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432937944",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432939250",
				Damage = 24,
				PushDelay = 0.35,
				PushForce = 140,
				HitCallback = HitCallbacks.PropelVictim(0.25, 80)
			}
		},
		Actions = actions12
	}
}
WeaponData.oroshi = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10432934091",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432935142",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432937944",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432939250",
				Damage = 24,
				PushDelay = 0.35,
				PushForce = 140,
				HitCallback = HitCallbacks.PropelVictim(0.25, 80)
			}
		},
		Actions = actions12
	}
}
WeaponData.longsword = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://9897744863",
				Damage = 20,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897745177",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897745658",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://9897746170",
				Damage = 23,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://9897746533"
			}
		}
	}
}
WeaponData.darkblade = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.DarkBlade),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10445052532",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10445053449",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10445054431",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10445055507",
				Damage = 27,
				PushDelay = 0.15,
				PushForce = 140,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions13
	}
}
WeaponData.darkdagger = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.DarkDagger),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10375933391",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375935776",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375937045",
				Damage = 21,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375938265",
				Damage = 23,
				PushDelay = 0.15,
				PushForce = 140,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://10375939618"
			}
		}
	}
}
WeaponData.buddysword = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10375979882",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375981285",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375982688",
				Damage = 23.5,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10375984145",
				Damage = 24,
				HitCallback = HitCallbacks.PropelVictim(0.25, 80)
			}
		},
		Actions = actions8
	}
}
WeaponData.spikeytrident = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10432946058",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432947280",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432948502",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432949388",
				Damage = 24,
				PushDelay = 0.3,
				PushForce = 190,
				HitCallback = HitCallbacks.PropelVictim(0.25, 120)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://10432951137"
			}
		}
	}
}
WeaponData.saber = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://8994237743",
				Damage = 19,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994238649",
				Damage = 20,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994239701",
				Damage = 20,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://8994240917",
				Damage = 21,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions2
	}
}
WeaponData.foxlamp = {
	HitSound = "BlueFireHit",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.FoxLamp),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://15532922784",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://15532923839",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://15532925465",
				Damage = 22,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://15532926950",
				Damage = 23,
				HitCallback = propelVictim
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://15545818969"
			}
		}
	}
}
WeaponData.dragonheart = {
	HitSound = "FireHit",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.Dragonheart),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10432946058",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432947280",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432948502",
				Damage = 24,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10432949388",
				Damage = 24,
				PushDelay = 0.3,
				PushForce = 190,
				HitCallback = HitCallbacks.PropelVictim(0.25, 120)
			}
		},
		Actions = actions6
	}
}
WeaponData.theswordofthebrat = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.DarkBlade),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10445052532",
				Damage = 15,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10445053449",
				Damage = 15,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10445054431",
				Damage = 15,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10445055507",
				Damage = 19,
				PushDelay = 0.15,
				PushForce = 140,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions13
	}
}
WeaponData.rapiddogblade = {
	HitSound = "QuickSlice",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.DarkBlade),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://10445052532",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10445053449",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10445054431",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://10445055507",
				Damage = 27,
				PushDelay = 0.15,
				PushForce = 140,
				HitCallback = HitCallbacks.PropelVictim(0.25, 55)
			}
		},
		Actions = actions13
	}
}
WeaponData.divineart = {
	HitSound = "DivineHit",
	SwingSound = "AngelSwing",
	WeaponType = "Melee",
	HitboxLimbs = v.Arms,
	HitboxMagnitude = 6.666,
	ValidateFrontHits = true,
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://18699539486",
				Damage = 20,
				HitCallback = HitCallbacks.PropelVictim(0.25, 40)
			},
			{
				AnimationId = "rbxassetid://18699541378",
				Damage = 20,
				HitCallback = HitCallbacks.PropelVictim(0.25, 40)
			},
			{
				AnimationId = "rbxassetid://18699542775",
				Damage = 20,
				HitCallback = HitCallbacks.PropelVictim(0.25, 40)
			},
			{
				AnimationId = "rbxassetid://18699545564",
				Damage = 21,
				HitCallback = HitCallbacks.PropelVictim(0.25, 120),
				AOEDelay = 0.1,
				AOESize = 25,
				AOEDistanceFromCharacter = 15,
				CustomAOEVFX = true
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://14586872029"
			}
		}
	}
}
WeaponData.sanguineart = {
	HitSound = "GhoulHit",
	SwingSound = "GhoulSwing",
	WeaponType = "Melee",
	HitboxLimbs = v.Arms,
	HitboxMagnitude = 6.666,
	ValidateFrontHits = true,
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://14586873525",
				Damage = 20,
				HitCallback = HitCallbacks.PropelVictim(0.25, 40)
			},
			{
				AnimationId = "rbxassetid://14586874599",
				Damage = 20,
				HitCallback = HitCallbacks.PropelVictim(0.25, 40)
			},
			{
				AnimationId = "rbxassetid://14586875624",
				Damage = 20,
				HitCallback = HitCallbacks.PropelVictim(0.25, 40)
			},
			{
				AnimationId = "rbxassetid://14586877813",
				Damage = 21,
				HitCallback = HitCallbacks.PropelVictim(0.25, 120)
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://14586872029 "
			}
		}
	}
}
WeaponData.anchor = {
	HitSound = "WaterHit",
	WeaponType = "Sword",
	EquipAnimation = require(equipAnimations.Anchor),
	Moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://14798724768",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://14798726082",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://14798728487",
				Damage = 23,
				HitCallback = propelVictim
			},
			{
				AnimationId = "rbxassetid://14798729807",
				Damage = 24,
				HitCallback = propelVictim
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://14798231537"
			}
		}
	}
}
WeaponData["Ice-Ice"] = WeaponData.icesword
WeaponData["Light-Light"] = WeaponData.lightsword
WeaponData.RefinedSlingshot = {
	WeaponType = "Gun",
	HitType = "Hitscan",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://111705949600381"
		},
		Reload = {
			AnimationId = "rbxassetid://123002600082464"
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://86929429039992"
		},
		Shoot = {
			AnimationId = "rbxassetid://115261781122110"
		}
	},
	Damage = 11.25,
	Range = 200,
	Cooldown = 0.4,
	ReloadSoundDelay = 0,
	ReloadSound = "BF_WPN_Slingshot_Reload_01",
	FireSound = "BF_WPN_Slingshot_M1_Click_0",
	ShootType = "HitscanSingleShot",
	KnockbackLevel = "Low",
	EquippedAttachmentName = "RootPart",
	EffectModuleName = "Slingshot"
}
WeaponData.DualFlintlock = {
	WeaponType = "Gun",
	HitType = "Hitscan",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://113200623785215"
		},
		Reload = {
			AnimationId = "rbxassetid://126726672412687",
			SpeedMult = 1.1
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://103020845916586"
		},
		Shoot = {
			AnimationId = "rbxassetid://117158004326324",
			SpeedMult = 1.8
		}
	},
	BulletSpreadCount = 7,
	BulletSpreadDegree = 12,
	Damage = function(p)
		if p == 1 then
			return 18.6
		elseif p == 2 then
			return 9.3
		end

		return 23.25
	end,
	Range = 500,
	Cooldown = 1.6,
	FireSound = "BF_WPN_Flintlock_M1_Click_01",
	ReloadSound = "BF_WPN_Flintlock_Reload_01",
	ReloadSoundDelay = 0.5,
	ShootType = "HitscanBurst",
	ShootInterval = 0.08333333333333333,
	NumBurstShots = 2,
	KnockbackLevel = "Medium",
	EffectModuleName = "DualFlintlock",
	EquippedAttachmentName = {
		LeftHand = "RootPartL",
		RightHand = "RootPartR"
	}
}
WeaponData.Musket = {
	WeaponType = "Gun",
	HitType = "Hitscan",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://109100580118153"
		},
		Reload = {
			AnimationId = "rbxassetid://131670709803524",
			SpeedMult = 1.11
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://84093517707506"
		},
		Shoot = {
			AnimationId = "rbxassetid://99466885643713"
		}
	},
	Damage = 22.5,
	Range = 500,
	Cooldown = 2.7,
	FireSound = "MusketGunFire",
	ReloadSound = "BF_WPN_Musket_Reload_01",
	ReloadSoundDelay = 0.4,
	ShootType = "HitscanSingleShot",
	KnockbackLevel = "High",
	EffectModuleName = "Default"
}
WeaponData.Flintlock = {
	WeaponType = "Gun",
	HitType = "Hitscan",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://18522947195"
		},
		Reload = {
			AnimationId = "rbxassetid://18522944702",
			SpeedMult = 1.3333
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://18522966420"
		},
		Shoot = {
			AnimationId = "rbxassetid://18522962717"
		}
	},
	Damage = 19.5,
	Range = 500,
	Cooldown = 1.8,
	FireSound = "BF_WPN_Flintlock_M1_Click_01",
	ReloadSound = "BF_WPN_Flintlock_Reload_01",
	ReloadSoundDelay = 0.5,
	ShootType = "HitscanSingleShot",
	KnockbackLevel = "Medium",
	EquippedAttachmentName = "RootPart"
}
WeaponData.Cannon = {
	WeaponType = "Gun",
	HitType = "Projectile",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://140014467072085"
		},
		Reload = {
			AnimationId = "rbxassetid://108806740031000",
			SpeedMult = 1.3
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://134735747347076"
		},
		Shoot = {
			AnimationId = "rbxassetid://122128600637856"
		}
	},
	Damage = 33,
	SplashDamageRadius = 40,
	Speed = 170,
	Cooldown = 3.5,
	FireSound = "BF_WPN_Cannon_M1_Fire_01",
	ReloadSound = "BF_WPN_Cannon_Reload_01",
	ReloadSoundDelay = 0.85,
	ShootType = "Projectile",
	ProjectileSize = createVector(5, 5, 5)
}
WeaponData.MagmaBlaster = {
	WeaponType = "Gun",
	HitType = "Hitscan",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://80894071549192"
		},
		Reload = {
			AnimationId = "rbxassetid://83506479628489",
			SpeedMult = 1.1
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://97897051637088"
		},
		Shoot = {
			AnimationId = "rbxassetid://98542288405034"
		}
	},
	BulletSpreadCount = 7,
	BulletSpreadDegree = 12,
	Damage = 25.5,
	Range = 500,
	Cooldown = 2.3,
	FireSound = "BF_WPN_MagmaBlaster_M1_Click_Fire_01",
	ReloadSound = "BF_WPN_RefMusket_Reload_01_V2",
	ReloadSoundDelay = 0.4,
	ShootType = "HitscanShotgun",
	KnockbackLevel = "High",
	DamageFalloff = {
		Min = 0.75,
		Max = 1.5
	},
	EquippedAttachmentName = "Magma Shotgun"
}
WeaponData.Bazooka = {
	WeaponType = "Gun",
	HitType = "Projectile",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://109103532551955"
		},
		Reload = {
			AnimationId = "rbxassetid://108684230884166"
		},
		Equip = {
			AnimationId = "rbxassetid://18110691155"
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://127769192082284"
		},
		Shoot = {
			AnimationId = "rbxassetid://117798834762856"
		}
	},
	Damage = 34.5,
	SplashDamageRadius = 40,
	Speed = 225,
	Cooldown = 3.5,
	FireSound = "BazookaGunFire",
	ReloadSound = "BF_WPN_Bazooka_Reload_01",
	ReloadSoundDelay = 0.85,
	ShootType = "Projectile",
	ProjectileSize = createVector(2.93, 2.93, 2.93),
	EquippedAttachmentName = "Main"
}
WeaponData.AcidumRifle = {
	WeaponType = "Gun",
	HitType = "Hitscan",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://18209273000"
		},
		Reload = {
			AnimationId = "rbxassetid://18209268702",
			SpeedMult = 1.2
		},
		Equip = {
			AnimationId = "rbxassetid://18209264429"
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://18209258599"
		},
		Shoot = {
			AnimationId = "rbxassetid://18209253218"
		}
	},
	Damage = 3,
	DamageOverTime = {
		Damage = 6,
		Iterations = 5,
		Interval = 0.5
	},
	Range = 500,
	Cooldown = 2.25,
	FireSound = "BF_WPN_AcidiumRifle_M1Click_0",
	ReloadSound = "BF_WPN_Acidium_Reload_01",
	ShootType = "HitscanSingleShot",
	KnockbackLevel = "Medium",
	EquippedAttachmentName = "RootPart"
}
WeaponData.Kabucha = {
	WeaponType = "Gun",
	HitType = "Hitscan",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://112136598102176"
		},
		Reload = {
			AnimationId = "rbxassetid://124649526140009"
		},
		Equip = {
			AnimationId = "rbxassetid://18336636401"
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://98237869142889"
		},
		Shoot = {
			AnimationId = "rbxassetid://133706385772605"
		}
	},
	Damage = 13.5,
	Range = 200,
	Cooldown = 0.45,
	ReloadSoundDelay = 0.05,
	ReloadSound = "BF_WPN_Slingshot_Reload_01",
	FireSound = "BF_WPN_Kabucha_M1_Click_Fire_0",
	ShootType = "HitscanSingleShot",
	KnockbackLevel = "Low",
	EquippedAttachmentName = "RootPart"
}
WeaponData.BizarreRevolver = {
	WeaponType = "Gun",
	HitType = "Hitscan",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://18742193198"
		},
		SmallReload = {
			AnimationId = "rbxassetid://137417371931078",
			SpeedMult = 1.1
		},
		Reload = {
			AnimationId = "rbxassetid://135251251232067",
			SpeedMult = 0.95
		},
		Equip = {
			AnimationId = "rbxassetid://18742187653"
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://18742176425"
		},
		Shoot = {
			AnimationId = "rbxassetid://18742183602"
		}
	},
	Damage = 18,
	Range = 500,
	Cooldown = 2.6,
	FireSound = "BF_WPN_BizzareRifle_M1ClickFire_0",
	ReloadSound = "BF_WPN_Reload_3Rd_Shot_01",
	SmallReloadSound = "BF_WPN_Bizarre_Rifle_Reload_01",
	ReloadSoundDelay = 0.4,
	ShootType = "HitscanSingleShot",
	KnockbackLevel = "Medium",
	MagSize = 3,
	ShootInterval = 1,
	EquippedAttachmentName = "Blue Gun."
}
WeaponData.VenomBow = {
	WeaponType = "Gun",
	HitType = "Hitscan",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://18249510172"
		},
		Reload = {
			AnimationId = "rbxassetid://140424743816618"
		},
		Equip = {
			AnimationId = "rbxassetid://18250000977"
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://86875603581635"
		},
		Shoot = {
			AnimationId = "rbxassetid://122486479468213"
		}
	},
	Damage = 3,
	DamageOverTime = {
		Damage = 6,
		Iterations = 4,
		Interval = 0.5
	},
	Range = 400,
	Cooldown = 1.5,
	ReloadSound = "BF_WPN_VenomBowReload_01",
	ReloadSoundDelay = 0,
	FireSound = "BF_WPN_VenomBow_M1_Click_0",
	ShootType = "HitscanSingleShot",
	KnockbackLevel = "Medium",
	EquippedAttachmentName = "NurbsPath.003"
}
WeaponData.SkullGuitar = {
	WeaponType = "Gun",
	HitType = "Projectile",
	Moveset = {
		OffensiveIdle = {
			AnimationId = "rbxassetid://130371931911016"
		},
		Shoot = {
			AnimationId = "rbxassetid://80658570637808"
		}
	},
	Damage = 18,
	Range = 400,
	Cooldown = 1.5,
	ShootType = "Custom",
	ShootFunction = game.ReplicatedStorage.Events.ShootSoulGuitar
}
WeaponData.Slingshot = {
	WeaponType = "Gun",
	HitType = "Hitscan",
	Moveset = {
		RelaxedIdle = {
			AnimationId = "rbxassetid://123585889096209"
		},
		Reload = {
			AnimationId = "rbxassetid://70536929765509"
		},
		OffensiveIdle = {
			AnimationId = "rbxassetid://130111030637961"
		},
		Shoot = {
			AnimationId = "rbxassetid://82003889650297"
		}
	},
	Damage = 4.949999999999999,
	Range = 300,
	Cooldown = 0.4,
	ReloadSoundDelay = 0,
	ReloadSound = "BF_WPN_Slingshot_Reload_01",
	FireSound = "BF_WPN_Slingshot_M1_Click_0",
	ShootType = "HitscanSingleShot",
	KnockbackLevel = "Low"
}
WeaponData.Dragonstorm = {
	WeaponType = "Gun",
	HitType = "Hitscan",
	Moveset = {
		OffensiveIdle = {
			AnimationId = "rbxassetid://98313122015656"
		},
		Shoot = {
			AnimationId = "rbxassetid://105151698095841",
			Looped = true
		}
	},
	Damage = 4.949999999999999,
	Range = 400,
	Cooldown = 0.08,
	ReloadSoundDelay = 0,
	ReloadSound = "BF_WPN_Slingshot_Reload_01",
	FireSound = "BF_WPN_Slingshot_M1_Click_0",
	ShootType = "HitscanSingleShot",
	ShootStyle = "Gatling",
	KnockbackLevel = "Low",
	LinearKnockback = true,
	EquippedAttachmentName = "RootPart",
	BulletSpreadDegree = 3,
	OverheatLimit = 3,
	OverheatCooldown = 1,
	BaseCursorRotationSpeed = 10,
	SkipSpreadInterval = 4
}

if game.CreatorType == Enum.CreatorType.User then
	local moveset = {
		Basic = {
			{
				AnimationId = "rbxassetid://13795059104",
				Damage = 5
			},
			{
				AnimationId = "rbxassetid://13795255115",
				Damage = 5
			},
			{
				AnimationId = "rbxassetid://13795309208",
				Damage = 5,
				PushDelay = 0.2,
				PushForce = 50
			},
			{
				AnimationId = "rbxassetid://13795312089",
				Damage = 5,
				AOEDelay = 0.35
			}
		},
		Actions = {
			Idle = {
				AnimationId = "rbxassetid://13795794536"
			}
		}
	}
	WeaponData.LinkedSword = {
		WeaponType = "Sword",
		Moveset = moveset
	}
	WeaponData.BrickSword = {
		WeaponType = "Sword",
		Moveset = moveset,
		EquipAnimation = require(equipAnimations.BrickSword)
	}
	WeaponData.bisento.Moveset = moveset
end

for k, v77 in WeaponData do
	if not v77.Name then
		v77.Name = k
	end

	if not v77.HitSound then
		v77.HitSound = "Hit1"
	end

	if v77.WeaponType == "Gun" then
		if not v77.Reticle then
			v77.Reticle = {
				ImageId = "rbxassetid://102272390628802",
				Size = UDim2.fromOffset(32, 32)
			}
		end

		if not v77.ReloadReticle then
			v77.ReloadReticle = {
				ImageId = "rbxassetid://102272390628802",
				Size = UDim2.fromOffset(32, 32)
			}
		end

		v77.ReloadReticle.IsReload = true
		v77.ReloadReticle.ReloadTime = v77.Cooldown

		if not v77.Hitmarker then
			v77.Hitmarker = {
				ImageId = "rbxassetid://18584746754",
				Size = UDim2.fromOffset(32, 32)
			}
		end

		if not v77.MagSize then
			v77.MagSize = 1
		end
	elseif v77.WeaponType == "Melee" and not v77.HitboxLimbs then
		v77.HitboxLimbs = {
			"RightLowerArm",
			"RightUpperArm",
			"LeftLowerArm",
			"LeftUpperArm",
			"RightHand",
			"LeftHand"
		}
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPureWeaponName(value)
	return string.lower(string.gsub(value, "%s", ""))
end

local RunService = game:GetService("RunService")

if not (RunService:IsServer() and game.ServerStorage.Models:FindFirstChild("WeaponDummies")) then
	return WeaponData
end

local children = game.ServerStorage.WeaponsFolder:GetChildren()
local children2 = game.ServerStorage.Models.WeaponDummies:GetChildren()
local v77 = {
	Sword = { "WeaponType", "Moveset" },
	Melee = { "WeaponType", "Moveset" },
	Gun = { "WeaponType", "Moveset", "Cooldown" },
	["Demon Fruit"] = { "WeaponType", "Moveset" }
}

for k, v78 in WeaponData do
	local pureWeaponName = getPureWeaponName(k) -- equivalent call inferred; original call site unknown

	for _, model in children do
		local name = model.Name

		if pureWeaponName ~= string.lower(string.gsub(name, "%s", "")) then
			continue
		end

		v78.model = model
		break
	end

	for _, weaponDummy in children2 do
		local name = weaponDummy.Name

		if pureWeaponName ~= string.lower(string.gsub(name, "%s", "")) then
			continue
		end

		v78.WeaponDummy = weaponDummy

		for _, child in weaponDummy:GetChildren() do
			local tool = child:FindFirstChild("Tool") or child:FindFirstChildWhichIsA("Model")

			if not tool then
				continue
			end

			for _, folder in tool:GetChildren() do
				if not (folder:IsA("Folder") and not folder:GetAttribute("WeldTo") or folder:GetAttribute("WeldTo") == "") then
					continue
				end

				warn("Missing WeldTo attribute:", folder:GetFullName())
			end
		end

		break
	end

	if not v78.WeaponDummy then
		local _ = v78.WeaponType == "Melee"
	end

	for _, v80 in v77[v78.WeaponType] do
		if not v78[v80] then
			warn(string.format("Weapon \"%s\" is missing field \"%s\"", k, v80))
		end
	end
end

return WeaponData