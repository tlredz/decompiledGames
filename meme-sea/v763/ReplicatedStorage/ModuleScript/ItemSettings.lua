return {
	Katana = {
		M1 = {
			Damage = 1.35,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.5,
			Max_Count = 4
		},
		Z = {
			Name = "Katana Slash",
			Damage = 2.67,
			Cooldown = 4,
			Duration = 2,
			Moving_Speed = 200,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 400,
			Knockback = {
				Velocity = 50,
				Duration = 0.1,
				Clear_BV = false
			}
		}
	},
	Hanger = {
		M1 = {
			Damage = 1.31,
			Attack_Cooldown = 0.25,
			Last_Cooldown = 0.5,
			Max_Count = 4
		},
		Z = {
			Name = "Spinning Hanger",
			Damage = 2.71,
			Cooldown = 5,
			Duration = 2,
			Moving_Speed = 200,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 400,
			Knockback = {
				Velocity = 25,
				Duration = 0.1,
				Clear_BV = false
			}
		}
	},
	Banana = {
		M1 = {
			Damage = 1.45,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.5,
			Max_Count = 4
		},
		Z = {
			Name = "Banana Throw",
			Damage = 2.82,
			Cooldown = 4,
			Duration = 2,
			Moving_Speed = 200,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 400,
			Knockback = {
				Velocity = 50,
				Duration = 0.1,
				Clear_BV = false
			}
		},
		X = {
			Name = "Banana Bite",
			Cooldown = 13,
			Heal = 7.5
		}
	},
	["Flame Katana"] = {
		M1 = {
			Damage = 1.52,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.5,
			Max_Count = 4
		},
		Z = {
			Name = "Flame Slash",
			Damage = 2.81,
			Cooldown = 5,
			Duration = 2,
			Moving_Speed = 250,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 500,
			Knockback = {
				Velocity = 25,
				Duration = 0.1,
				Clear_BV = false
			},
			Burning = {
				Burning_Divide = 50,
				Burning_Times = 10,
				Burning_Cooldown = 0.2,
				Duration = 2
			}
		},
		X = {
			Name = "Burning Quad Slash",
			Damage = 2.83,
			Cooldown = 8,
			Duration = 2,
			Moving_Speed = 250,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 500,
			Knockback = {
				Velocity = 25,
				Duration = 0.1,
				Clear_BV = false
			},
			Burning = {
				Burning_Divide = 50,
				Burning_Times = 10,
				Burning_Cooldown = 0.2,
				Duration = 2
			}
		}
	},
	["Pixel Sword"] = {
		M1 = {
			Damage = 1.5,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.35,
			Max_Count = 4
		},
		Z = {
			Name = "Pixel Block",
			Damage = 2.92,
			Cooldown = 6,
			Duration = 2,
			Moving_Speed = 300,
			Single_Target = true,
			Break_Instinct = true,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 600,
			Knockback = {
				Velocity = 0,
				Duration = 1,
				Clear_BV = true
			},
			BodyPosition = {
				Type = "Body_Position_Reverse",
				P = 100000,
				StunTime = 1,
				Distance = 5,
				Duration = 0.5,
				Clear_BV = true
			}
		},
		X = {
			Name = "Pixel Barrage",
			Damage = 2.99,
			Cooldown = 8,
			Duration = 2,
			Break_Instinct = true,
			Holding_Skill = true,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 75,
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Equipped_Needed = true,
			Knockback = {
				StunTime = 0.5,
				Velocity = 5,
				Duration = 2,
				Clear_BV = true
			}
		}
	},
	["Pink Hammer"] = {
		M1 = {
			Damage = 1.55,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.5,
			Max_Count = 4
		},
		Z = {
			Name = "Pink Doge",
			Damage = 2.87,
			Cooldown = 5,
			Duration = 2,
			Moving_Speed = 275,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 500,
			Knockback = {
				Velocity = 50,
				Duration = 0.1,
				Clear_BV = false
			}
		},
		X = {
			Name = "Pink Smash",
			Damage = 2.91,
			Cooldown = 8,
			Duration = 3,
			Break_Instinct = true,
			MultiHit_Skill = true,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 300,
			Max_Phase = 5,
			Duration_Phase = 0.25,
			Up_Vector = true,
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				Duration = 1.25,
				More_Delay = 0.1,
				Clear_BV = true
			}
		}
	},
	Bonk = {
		M1 = {
			Damage = 1.57,
			Attack_Cooldown = 0.3,
			Last_Cooldown = 0.5,
			Max_Count = 4
		},
		Z = {
			Name = "Cheems Bonk",
			Damage = 2.92,
			Cooldown = 6,
			Duration = 0.5,
			Max_Distance = 100,
			Spin_Divide = 50,
			Spinning_Loop = 5,
			Spinning_Cooldown = 0.2,
			Moving_Speed = 150,
			Break_Instinct = true,
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1,
				Duration = 1,
				Clear_BV = true
			},
			DragPosition = {
				Type = "Body_Position",
				P = 25000,
				StunTime = 1.5,
				Distance = 5,
				Duration = 1.5,
				Clear_BV = true
			}
		},
		X = {
			Name = "Cheems Festival",
			Damage = 2.985,
			Cooldown = 10,
			Duration = 3,
			MultiHit_Skill = true,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 350,
			Max_Phase = 5,
			Duration_Phase = 0.3
		}
	},
	Card = {
		M1 = {
			Damage = 1.53,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.35,
			Max_Count = 4
		},
		Z = {
			Name = "Stop Card",
			Damage = 2.959,
			Cooldown = 7,
			Duration = 2,
			Moving_Speed = 300,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 600,
			Frozen = {
				Type = "Stop_Card",
				Duration = 2
			},
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1.5,
				Duration = 1.5,
				Clear_BV = true
			}
		},
		X = {
			Name = "Reverse Card",
			Cooldown = 14,
			Duration = 4
		}
	},
	Pumpkin = {
		M1 = {
			Damage = 1.6,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.6,
			Max_Count = 4
		},
		Z = {
			Name = "Pumpkin Pull",
			Damage = 3.01,
			Cooldown = 6,
			Duration = 2,
			Single_Target = true,
			Moving_Speed = 300,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 600,
			Knockback = {
				Velocity = 0,
				Duration = 1,
				Clear_BV = true
			},
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1,
				Distance = 5,
				Duration = 0.5,
				Ignore_Hitbox = true,
				Clear_BV = true,
				Invincible = 0.5,
				True_Invincible = true
			}
		},
		X = {
			Name = "Pumpkin Meteor",
			Damage = 3.07,
			Cooldown = 8,
			Duration = 3,
			MultiHit_Skill = true,
			Skill_Type = "Enemy_Effect",
			Max_Phase = 5,
			Duration_Phase = 0.2,
			Max_Distance = 400,
			Break_Instinct = true,
			Up_Vector = true,
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				Duration = 1.25,
				Clear_BV = true
			}
		}
	},
	Portal = {
		M1 = {
			Damage = 1.65,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.5,
			Max_Count = 4
		},
		Z = {
			Name = "Portal Teleport",
			Cooldown = 15,
			Duration = 7.5,
			Portal_Duration = 2,
			Teleport_CD = 1
		}
	},
	["Yellow Blade"] = {
		M1 = {
			Damage = 1.62,
			Attack_Cooldown = 0.25,
			Last_Cooldown = 0.5,
			Max_Count = 4
		},
		Z = {
			Name = "Yellow Tornado",
			Damage = 3.065,
			Cooldown = 7,
			Duration = 2,
			Moving_Speed = 200,
			Skill_Type = "Dragging",
			Dragging_Cooldown = 0.3,
			Max_Phase = 2,
			Max_Dragging = 5,
			Max_Distance = 400,
			MultiHit_Skill = true,
			BodyPosition = {
				Type = "Align_Position",
				StunTime = 0.5,
				Responsiveness = 100,
				Duration = 1,
				Middle = true,
				Clear_BV = true
			}
		},
		X = {
			Name = "Yellow Slashing",
			Damage = 3.125,
			Cooldown = 9,
			Duration = 2,
			Break_Instinct = true,
			Holding_Skill = true,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 125,
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Equipped_Needed = true,
			Knockback = {
				Velocity = 0,
				StunTime = 0.5,
				Duration = 2,
				Clear_BV = true
			}
		}
	},
	["Purple Katana"] = {
		M1 = {
			Damage = 1.64,
			Attack_Cooldown = 0.3,
			Last_Cooldown = 0.5,
			Max_Count = 4
		},
		Z = {
			Name = "Triple Purple Slash",
			Damage = 3.09,
			Cooldown = 5,
			Duration = 2,
			Moving_Speed = 250,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 500,
			Knockback = {
				Velocity = 50,
				Duration = 0.1,
				Clear_BV = false
			}
		},
		X = {
			Name = "Giant Blade",
			Damage = 3.14,
			Cooldown = 8,
			Duration = 3,
			Max_Distance = 250,
			Break_Instinct = true,
			MultiHit_Skill = true,
			Skill_Type = "Enemy_Effect",
			Max_Phase = 5,
			Duration_Phase = 0.25,
			Up_Vector = true,
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				Duration = 1.25,
				Clear_BV = true
			}
		}
	},
	Floppa = {
		M1 = {
			Damage = 1.63,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.35,
			Max_Count = 4
		},
		Z = {
			Name = "Floppa Attack",
			Damage = 3.025,
			Cooldown = 5,
			Duration = 2,
			Moving_Speed = 275,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 500,
			Knockback = {
				Velocity = 50,
				Duration = 0.1,
				Clear_BV = false
			}
		},
		X = {
			Name = "Floppa Rain",
			Damage = 3.125,
			Cooldown = 12,
			Duration = 2,
			Max_Distance = 400,
			MultiHit_Skill = true,
			Skill_Type = "Enemy_Effect",
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Up_Vector = true,
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				Duration = 1,
				Clear_BV = true
			}
		}
	},
	Popcat = {
		M1 = {
			Damage = 1.68,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.5,
			Max_Count = 4
		},
		Z = {
			Name = "Popcat Minigun",
			Damage = 0.35,
			Cooldown = 7,
			Duration = 2,
			Moving_Speed = 250,
			Max_Distance = 500,
			MultiHit_Skill = true,
			Max_Loop = 10,
			Skill_Type = "Enemy_Effect",
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				Duration = 0.5,
				Clear_BV = false
			}
		},
		X = {
			Name = "Popcat Prison",
			Damage = 3.135,
			Cooldown = 10,
			Duration = 2,
			Moving_Speed = 300,
			Max_Distance = 600,
			Break_Instinct = true,
			Hitbox_Duration = 0.1,
			Skill_Type = "Prison",
			Prison = {
				Break_Instinct = true,
				Prison_Divide = 50,
				Prison_Cooldown = 0.5,
				Max_Prison = 4
			},
			BodyPosition = {
				Type = "Align_Position",
				P = 100000,
				StunTime = 2,
				Responsiveness = 100,
				Duration = 2,
				Middle = true,
				Clear_BV = true
			}
		}
	},
	Combat = {
		M1 = {
			Damage = 1.15,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.5,
			Max_Count = 4
		},
		Z = {
			Name = "Punch Barrage",
			Damage = 2.54,
			Cooldown = 7,
			Duration = 2,
			Holding_Skill = true,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 50,
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Equipped_Needed = true,
			Knockback = {
				StunTime = 0.5,
				Velocity = 2.5,
				Duration = 2,
				Clear_BV = true
			}
		}
	},
	Baller = {
		M1 = {
			Damage = 1.57,
			Attack_Cooldown = 0.35,
			Last_Cooldown = 0.35,
			Max_Count = 4
		},
		Z = {
			Name = "Flame Ball",
			Damage = 2.287,
			Cooldown = 6,
			Duration = 2,
			Moving_Speed = 250,
			Max_Distance = 500,
			Burning = {
				Break_Instinct = true,
				Burning_Divide = 50,
				Burning_Times = 10,
				Burning_Cooldown = 0.2,
				Duration = 2
			},
			Knockback = {
				Velocity = 25,
				Duration = 0.1,
				Clear_BV = false
			}
		},
		X = {
			Name = "Rolling Ball",
			Damage = 2.17,
			Cooldown = 8,
			Duration = 1,
			Moving_Speed = 200,
			Break_Instinct = true,
			Max_Distance = 100,
			Spin_Divide = 50,
			Spinning_Loop = 5,
			Spinning_Cooldown = 0.2,
			Skill_Type = "Spinning",
			BodyPosition = {
				Type = "Body_Position",
				P = 12500,
				StunTime = 1.5,
				Distance = 5,
				Duration = 1.25,
				Invincible = 1.25,
				True_Invincible = true,
				Use_MovingSpeed = true,
				Clear_BV = true
			}
		},
		C = {
			Name = "Ball Barrage",
			Damage = 2.21,
			Cooldown = 11,
			Duration = 2,
			Holding_Skill = true,
			Max_Distance = 100,
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Break_Instinct = true,
			Equipped_Needed = true,
			Knockback = {
				StunTime = 0.5,
				Velocity = 5,
				Duration = 2,
				Clear_BV = true
			}
		},
		V = {
			Name = "Baller Summon",
			Damage = 2.05,
			Cooldown = 25,
			Duration = 5,
			Distance = 250,
			Moving_Speed = 200,
			Max_Distance = 500,
			MultiHit_Skill = true,
			Max_Loop = 7,
			Max_Phase = 7,
			Knockback = {
				Velocity = 25,
				Duration = 0.1,
				Clear_BV = false
			}
		}
	},
	["Fly Power"] = {
		Unstoreable = true,
		Droppable = true,
		F = {
			Name = "Flight",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 175
		}
	},
	["Bomb Power"] = {
		Unstoreable = true,
		Droppable = true,
		Z = {
			Name = "Bomb Shot",
			Damage = 2.989,
			Cooldown = 5,
			Duration = 2,
			Moving_Speed = 150,
			Max_Distance = 500,
			Break_Instinct = true,
			Up_Vector = true,
			Max_Phase = 5,
			Duration_Phase = 0.2,
			IsExplosion = true,
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				More_Delay = 0.1,
				Duration = 1.25,
				Clear_BV = true
			}
		},
		X = {
			Name = "Cat Bomb",
			Damage = 2.61,
			Cooldown = 8,
			Duration = 2,
			Max_Distance = 400,
			Break_Instinct = true,
			MultiHit_Skill = true,
			Knockback = {
				Velocity = 10,
				Duration = 0.1,
				Clear_BV = false
			}
		}
	},
	["Invisible Power"] = {
		Unstoreable = true,
		Droppable = true,
		Z = {
			Name = "Invisible",
			Cooldown = 20
		}
	},
	["Barrier Power"] = {
		Unstoreable = true,
		Droppable = true,
		Z = {
			Name = "Barrier Wall",
			Damage = 1.87,
			Cooldown = 5,
			Duration = 0.25,
			Moving_Speed = 400,
			Max_Distance = 500,
			MultiHit_Skill = true,
			Knockback = {
				Velocity = 50,
				Duration = 0.1,
				Clear_BV = false
			}
		},
		X = {
			Name = "Barrier Bubble",
			Damage = 1.83,
			Cooldown = 8,
			Duration = 2,
			Moving_Speed = 250,
			Max_Distance = 500,
			Break_Instinct = true,
			Hitbox_Duration = 0.1,
			Skill_Type = "Prison",
			Prison = {
				Prison_Divide = 50,
				Prison_Cooldown = 0.5,
				Max_Prison = 4
			},
			BodyPosition = {
				Type = "Align_Position",
				P = 100000,
				StunTime = 2,
				Responsiveness = 100,
				Duration = 2,
				Middle = true,
				Clear_BV = true
			}
		},
		C = {
			Name = "Barrier Prison",
			Damage = 1.81,
			Cooldown = 10,
			Duration = 3,
			Break_Instinct = true,
			MultiHit_Skill = true,
			Max_Distance = 400
		},
		F = {
			Name = "Barrier Flight",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 200
		}
	},
	["Spin Power"] = {
		Unstoreable = true,
		Droppable = true,
		Z = {
			Name = "Spin Punch",
			Damage = 2.81,
			Cooldown = 5,
			Duration = 2,
			Moving_Speed = 200,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 400,
			Knockback = {
				Velocity = 50,
				Duration = 0.1,
				Clear_BV = false
			}
		},
		X = {
			Name = "Spin Assault",
			Damage = 2.79,
			Cooldown = 8,
			Duration = 2,
			Break_Instinct = true,
			Holding_Skill = true,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 50,
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Equipped_Needed = true,
			BodyPosition = {
				Type = "Align_Position",
				MaxForce = 500000,
				StunTime = 0.5,
				Responsiveness = 200,
				Duration = 2,
				True_Invincible = true,
				Middle = true,
				Clear_BV = true
			}
		},
		F = {
			Name = "Spin Flight",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 185
		}
	},
	["Diamond Power"] = {
		Unstoreable = true,
		Droppable = true,
		Z = {
			Name = "Diamond Body",
			Damage_Buff = 0.25,
			Defense_Buff = 1,
			Cooldown = 3
		}
	},
	["Flame Power"] = {
		Unstoreable = true,
		Droppable = true,
		Z = {
			Name = "Flame Gun",
			Damage = 1.907,
			Cooldown = 5,
			Duration = 2,
			Moving_Speed = 300,
			Max_Distance = 600,
			Burning = {
				Break_Instinct = true,
				Burning_Divide = 50,
				Burning_Times = 10,
				Burning_Cooldown = 0.2,
				Duration = 2
			}
		},
		X = {
			Name = "Flame Tornado",
			Damage = 1.915,
			Cooldown = 8,
			Duration = 3,
			Max_Distance = 400,
			MultiHit_Skill = true,
			Max_Phase = 5,
			Duration_Phase = 0.3,
			Up_Vector = true,
			Fake_Burning = {
				Duration = 1.5
			},
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				Duration = 1.5,
				Clear_BV = true
			}
		},
		C = {
			Name = "Flame Beam",
			Damage = 1.912,
			Cooldown = 10,
			Duration = 3,
			Max_Distance = 350,
			MultiHit_Skill = true,
			Max_Phase = 5,
			Duration_Phase = 0.3,
			Fake_Burning = {
				Duration = 1.5
			},
			Knockback = {
				Velocity = 2.5,
				StunTime = 0.5,
				Duration = 1.5,
				Clear_BV = true
			}
		},
		V = {
			Name = "Flame Ball",
			Damage = 1.988,
			Cooldown = 15,
			Duration = 4,
			Max_Distance = 500,
			Moving_Speed = 250,
			Break_Instinct = true,
			Up_Vector = true,
			Max_Phase = 5,
			Duration_Phase = 0.2,
			IsExplosion = true,
			Fake_Burning = {
				Duration = 1
			},
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				Duration = 1.25,
				Clear_BV = true
			}
		},
		F = {
			Name = "Flame Flight",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 250
		}
	},
	["Ice Power"] = {
		Unstoreable = true,
		Droppable = true,
		Z = {
			Name = "Ice Sniper",
			Damage = 1.911,
			Cooldown = 5,
			Duration = 3,
			Moving_Speed = 300,
			Max_Distance = 600,
			Frozen = {
				Duration = 1,
				Freeze_Sound = true
			},
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1,
				Duration = 1,
				Clear_BV = true
			}
		},
		X = {
			Name = "Ice Floppa",
			Damage = 1.917,
			Cooldown = 8,
			Duration = 3,
			Moving_Speed = 225,
			Max_Distance = 450,
			Frozen = {
				Duration = 2,
				Freeze_Sound = true
			},
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1.5,
				Duration = 1.5,
				Clear_BV = true
			}
		},
		C = {
			Name = "Ice Floor",
			Damage = 1.925,
			Cooldown = 10,
			Duration = 2,
			Max_Distance = 200,
			MultiHit_Skill = true,
			Break_Instinct = true,
			Frozen = {
				Duration = 1.5
			},
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1.5,
				Duration = 1.5,
				Clear_BV = true
			}
		},
		V = {
			Name = "Ice Ball",
			Damage = 1.981,
			Cooldown = 15,
			Duration = 4,
			Max_Distance = 500,
			Moving_Speed = 250,
			Break_Instinct = true,
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1.5,
				Duration = 1.5,
				Clear_BV = true
			},
			Frozen = {
				Duration = 1.5
			}
		},
		F = {
			Name = "Ice Flight",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 175
		}
	},
	["Paw Power"] = {
		Unstoreable = true,
		Droppable = true,
		Z = {
			Name = "Paw Shot",
			Damage = 1.909,
			Cooldown = 5,
			Duration = 3,
			Moving_Speed = 300,
			Max_Distance = 600,
			Knockback = {
				Velocity = 25,
				Duration = 0.1,
				Clear_BV = false
			}
		},
		X = {
			Name = "Paw Barrage",
			Damage = 1.901,
			Cooldown = 8,
			Duration = 3,
			Moving_Speed = 250,
			Max_Distance = 500,
			MultiHit_Skill = true,
			Max_Phase = 5,
			Max_Loop = 9,
			Knockback = {
				StunTime = 0.5,
				Velocity = 2.5,
				Duration = 0.5,
				Clear_BV = true
			}
		},
		C = {
			Name = "Paw Explosion",
			Damage = 1.931,
			Cooldown = 10,
			Duration = 3,
			Break_Instinct = true,
			MultiHit_Skill = true,
			Max_Distance = 300,
			Max_Phase = 5,
			Duration_Phase = 0.3,
			Up_Vector = true,
			Knockback = {
				Velocity = 2.5,
				StunTime = 0.5,
				Duration = 1.5,
				More_Delay = 0.1,
				Clear_BV = true
			}
		},
		V = {
			Name = "Paw Drain",
			Damage = 1.984,
			Cooldown = 15,
			Duration = 2,
			Moving_Speed = 250,
			Max_Distance = 500,
			Break_Instinct = true,
			Skill_Type = "Heal_Prison",
			Prison = {
				Break_Instinct = true,
				Prison_Divide = 50,
				Prison_Cooldown = 0.5,
				Max_Prison = 4
			},
			Heal = 25,
			BodyPosition = {
				Type = "Align_Position",
				P = 100000,
				StunTime = 2,
				Responsiveness = 100,
				Duration = 2,
				Middle = true,
				Clear_BV = true
			}
		},
		F = {
			Name = "Paw Leap",
			Cooldown = 4,
			Max_Distance = 250
		}
	},
	["Gold Power"] = {
		Unstoreable = true,
		Droppable = true,
		Z = {
			Name = "Golden Sharks",
			Damage = 2.902,
			Cooldown = 7,
			Duration = 2,
			Max_Distance = 400,
			Skill_Type = "Enemy_Effect",
			MultiHit_Skill = true,
			Hitbox_Duration = 0.1,
			Break_Instinct = true,
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1,
				Distance = 5,
				Duration = 0.5,
				Ignore_Hitbox = true,
				Clear_BV = true,
				Invincible = 0.5,
				True_Invincible = true
			}
		},
		X = {
			Name = "Golden Pillar",
			Damage = 2.914,
			Cooldown = 9,
			Duration = 3,
			Max_Distance = 400,
			MultiHit_Skill = true,
			Break_Instinct = true,
			Knockback = {
				Velocity = 0,
				StunTime = 1.5,
				Duration = 1.5,
				Clear_BV = true
			}
		},
		C = {
			Name = "Golden Body",
			Damage_Buff = 0.1,
			Defense_Buff = 0.5,
			Cooldown = 3
		},
		F = {
			Name = "Golden Cloud",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 225
		}
	},
	["Snow Power"] = {
		Unstoreable = true,
		Droppable = true,
		Z = {
			Name = "Snowball Throw",
			Damage = 1.917,
			Cooldown = 6,
			Duration = 2,
			Max_Distance = 500,
			Moving_Speed = 200,
			Frozen = {
				Type = "Snow_Frozen",
				Duration = 1
			},
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1,
				Duration = 1,
				Clear_BV = true
			}
		},
		X = {
			Name = "Snow Tornado",
			Damage = 1.924,
			Cooldown = 9,
			Duration = 3,
			Max_Distance = 400,
			MultiHit_Skill = true,
			Max_Phase = 5,
			Duration_Phase = 0.3,
			Up_Vector = true,
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				Duration = 1.5,
				Clear_BV = true
			}
		},
		C = {
			Name = "Snow Domain",
			Damage = 1.935,
			Cooldown = 13,
			Duration = 3,
			Max_Distance = 300,
			MultiHit_Skill = true,
			Max_Phase = 5,
			Duration_Phase = 0.3
		},
		V = {
			Name = "Snow Turret",
			Damage = 1.985,
			Cooldown = 25,
			Duration = 5,
			Distance = 250,
			Moving_Speed = 300,
			Max_Distance = 500,
			MultiHit_Skill = true,
			Max_Loop = 7,
			Max_Phase = 7,
			Frozen = {
				Type = "Snow_Frozen",
				Duration = 0.5
			},
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 0.5,
				Duration = 0.5,
				Clear_BV = true
			}
		},
		F = {
			Name = "Snow Flight",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 225
		}
	},
	["Sand Power"] = {
		Unstoreable = true,
		Droppable = true,
		Z = {
			Name = "Sand Launcher",
			Damage = 1.955,
			Cooldown = 7,
			Duration = 2,
			Moving_Speed = 250,
			Max_Distance = 500,
			MultiHit_Skill = true,
			Max_Phase = 9,
			Max_Loop = 10,
			Knockback = {
				Velocity = 2.5,
				StunTime = 0.5,
				Duration = 0.5,
				Clear_BV = false
			}
		},
		X = {
			Name = "Sand Trap",
			Damage = 1.921,
			Cooldown = 9,
			Duration = 2,
			Max_Distance = 400,
			MultiHit_Skill = true,
			Max_Phase = 30,
			Dragging_Speed = 25,
			Delayed_Duration = 1,
			Break_Instinct = true,
			Skill_Type = "Coffin",
			BodyPosition = {
				Type = "Body_Position",
				P = 10000,
				StunTime = 1.5,
				Distance = 5,
				Duration = 1.5,
				Ignore_Hitbox = true,
				Clear_BV = true
			}
		},
		C = {
			Name = "Sand Floor",
			Damage = 1.937,
			Cooldown = 10,
			Duration = 3,
			Break_Instinct = true,
			MultiHit_Skill = true,
			Max_Distance = 300,
			Max_Phase = 5,
			Duration_Phase = 0.3,
			BodyPosition = {
				Type = "Body_Position",
				Use_HitboxPosition = true,
				P = 25000,
				StunTime = 0.5,
				Duration = 0.5
			}
		},
		V = {
			Name = "Sand Tornado",
			Damage = 1.988,
			Cooldown = 15,
			Duration = 1.5,
			Moving_Speed = 150,
			Skill_Type = "Dragging",
			Dragging_Cooldown = 0.2,
			Max_Phase = 1.75,
			Max_Dragging = 7,
			Max_Distance = 300,
			Break_Instinct = true,
			MultiHit_Skill = true,
			BodyPosition = {
				Type = "Align_Position",
				StunTime = 0.5,
				Responsiveness = 100,
				Duration = 1,
				Middle = true,
				Clear_BV = true
			}
		},
		F = {
			Name = "Sand Flight",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 245
		}
	},
	["Moai Power"] = {
		Droppable = true,
		Unstoreable = true,
		Z = {
			Name = "Moai Punch",
			Damage = 2.927,
			Cooldown = 6,
			Duration = 2,
			Moving_Speed = 250,
			Skill_Type = "Enemy_Effect",
			Break_Instinct = true,
			Max_Distance = 500,
			Frozen = {
				Type = "Moai_Stun",
				Duration = 1.5
			},
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1.5,
				Duration = 1.5,
				Clear_BV = true
			}
		},
		X = {
			Name = "Moai Statue",
			Damage = 2.911,
			Cooldown = 9,
			Duration = 3,
			MultiHit_Skill = true,
			Max_Phase = 5,
			Duration_Phase = 0.3,
			Max_Distance = 400,
			Break_Instinct = true,
			Up_Vector = true,
			Knockback = {
				Velocity = 1,
				StunTime = 0.5,
				Duration = 1.5,
				Clear_BV = true
			}
		},
		C = {
			Name = "Moai Shield",
			Cooldown = 15,
			Duration = 3
		},
		F = {
			Name = "Moai Teleport",
			Cooldown = 4,
			Max_Distance = 250
		}
	},
	["Water Power"] = {
		Droppable = true,
		Unstoreable = true,
		Z = {
			Name = "Water Ball",
			Damage = 1.884,
			Cooldown = 7,
			Duration = 2,
			Max_Distance = 400,
			Hitbox_Duration = 0.1,
			Moving_Speed = 200,
			Dragging_Speed = 25,
			Skill_Type = "Coffin",
			Prison = {
				Prison_Divide = 50,
				Prison_Cooldown = 0.25,
				Max_Prison = 4
			},
			BodyPosition = {
				Type = "Body_Position",
				P = 10000,
				StunTime = 1,
				Distance = 5,
				Duration = 1,
				Ignore_Hitbox = true,
				Clear_BV = true
			}
		},
		X = {
			Name = "Water Sharks",
			Damage = 1.911,
			Cooldown = 8,
			Duration = 3,
			Moving_Speed = 250,
			Max_Distance = 500,
			MultiHit_Skill = true,
			Max_Phase = 5,
			Max_Loop = 9,
			Knockback = {
				StunTime = 0.5,
				Velocity = 2.5,
				Duration = 0.5,
				Clear_BV = true
			}
		},
		C = {
			Name = "Water Puddle",
			Damage = 1.934,
			Cooldown = 10,
			Duration = 3,
			Break_Instinct = true,
			MultiHit_Skill = true,
			Max_Distance = 300,
			Max_Phase = 5,
			Duration_Phase = 0.3,
			BodyPosition = {
				Type = "Body_Position",
				Use_HitboxPosition = true,
				P = 25000,
				StunTime = 0.5,
				Duration = 0.5
			}
		},
		V = {
			Name = "Water Tsunami",
			Damage = 1.989,
			Cooldown = 15,
			Duration = 2,
			Moving_Speed = 125,
			Skill_Type = "Dragging",
			Dragging_Cooldown = 0.2,
			Max_Phase = 1.75,
			Max_Dragging = 8,
			Max_Distance = 300,
			Break_Instinct = true,
			MultiHit_Skill = true,
			Knockback = {
				Velocity = 125,
				StunTime = 0.5,
				Duration = 1.5,
				Sync_Hitbox = true,
				Clear_BV = true
			}
		},
		F = {
			Name = "Water Flight",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 225
		}
	},
	["Dark Power"] = {
		Droppable = true,
		Unstoreable = true,
		Z = {
			Name = "Dark Hollow",
			Damage = 1.927,
			Cooldown = 8,
			Duration = 2,
			Moving_Speed = 125,
			Skill_Type = "Dragging",
			Dragging_Cooldown = 0.2,
			Max_Phase = 1.75,
			Max_Dragging = 7,
			Max_Distance = 300,
			MultiHit_Skill = true,
			BodyPosition = {
				Type = "Align_Position",
				StunTime = 0.5,
				MaxForce = 1000000,
				Responsiveness = 200,
				Duration = 1.5,
				Middle = true,
				Clear_BV = true
			}
		},
		X = {
			Name = "Dark Floppa",
			Damage = 1.914,
			Cooldown = 9,
			Duration = 2,
			Holding_Skill = true,
			Skill_Type = "Pulling",
			Max_Distance = 100,
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Equipped_Needed = true,
			BodyPosition = {
				Type = "Body_Position",
				StunTime = 0.5,
				P = 4500,
				Duration = 2,
				Distance = 5,
				Clear_BV = true,
				Invincible = 1,
				Ignore_Default = true,
				Respect_Duration = true,
				Respect_Holding = true
			}
		},
		C = {
			Name = "Black Hole",
			Damage = 1.935,
			Cooldown = 11,
			Duration = 2,
			Break_Instinct = true,
			Holding_Skill = true,
			Max_Distance = 200,
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Knockback = {
				Velocity = 0,
				StunTime = 0.5,
				P = 100000,
				Duration = 2,
				Clear_BV = true,
				Respect_Duration = true,
				Respect_Holding = true
			}
		},
		V = {
			Name = "Dark Cube",
			Damage = 2.114,
			Cooldown = 15,
			Duration = 3,
			Max_Distance = 400,
			MultiHit_Skill = true,
			Max_Phase = 5,
			Duration_Phase = 0.3,
			Break_Instinct = true,
			BodyPosition = {
				Type = "Body_Position",
				Use_HitboxPosition = true,
				P = 25000,
				StunTime = 1,
				Duration = 1
			}
		},
		F = {
			Name = "Dark Step",
			Cooldown = 4,
			Max_Distance = 250
		}
	},
	["Dough Power"] = {
		Droppable = true,
		Unstoreable = true,
		Z = {
			Name = "Dough Grab",
			Damage = 1.917,
			Cooldown = 7,
			Duration = 1,
			Moving_Speed = 300,
			Max_Distance = 400,
			MultiHit_Skill = true,
			Skill_Type = "Enemy_Effect",
			Hitbox_Duration = 0.1,
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1,
				Distance = 10,
				Duration = 0.5,
				Ignore_Hitbox = true,
				Clear_BV = true
			}
		},
		X = {
			Name = "Dough Pillar",
			Damage = 1.926,
			Cooldown = 9,
			Duration = 2,
			DelayHitbox_Duration = 0.1,
			Skill_Type = "Pillar",
			Max_Phase = 2,
			Max_Distance = 400,
			MultiHit_Skill = true,
			Delayed_Duration = 1,
			Break_Instinct = true,
			BodyPosition = {
				Type = "StartEnd_Align",
				MaxForce = 500000,
				Responsiveness = 200,
				Distance = 5,
				StunTime = 2,
				Duration = 2,
				Delayed = 1,
				Ignore_Hitbox = true,
				Clear_BV = true
			}
		},
		C = {
			Name = "Dough Floor",
			Damage = 1.932,
			Cooldown = 10,
			Duration = 2,
			Max_Distance = 200,
			MultiHit_Skill = true,
			Break_Instinct = true,
			Frozen = {
				Type = "Dough_Stunning",
				Duration = 1.5
			},
			BodyPosition = {
				Type = "Body_Position",
				P = 100000,
				StunTime = 1.5,
				Duration = 1.5
			}
		},
		V = {
			Name = "Dough Rain",
			Damage = 2.178,
			Cooldown = 15,
			Duration = 2,
			Max_Distance = 400,
			MultiHit_Skill = true,
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Break_Instinct = true,
			BodyPosition = {
				Type = "Body_Position",
				StunTime = 0.5,
				Duration = 0.5,
				Ignore_Hitbox = true
			}
		},
		F = {
			Name = "Dough Roll",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 235
		}
	},
	["Floppa Power"] = {
		Droppable = true,
		Unstoreable = true,
		Z = {
			Name = "Burning Floppa",
			Damage = 1.91,
			Cooldown = 6,
			Duration = 2,
			Moving_Speed = 275,
			Max_Distance = 600,
			MultiHit_Skill = true,
			Burning = {
				Break_Instinct = true,
				Burning_Divide = 50,
				Burning_Times = 10,
				Burning_Cooldown = 0.2,
				Duration = 2
			}
		},
		X = {
			Name = "Thunder Floppa",
			Damage = 1.931,
			Cooldown = 9,
			Duration = 2,
			MultiHit_Skill = true,
			Max_Distance = 200,
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Knockback = {
				StunTime = 0.5,
				Velocity = 5,
				Duration = 2,
				Clear_BV = true
			}
		},
		C = {
			Name = "Floppa Shrine",
			Damage = 1.922,
			Cooldown = 12,
			Duration = 3,
			MultiHit_Skill = true,
			Skill_Type = "Enemy_Effect",
			Max_Distance = 300,
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Break_Instinct = true,
			Knockback = {
				StunTime = 0.5,
				Velocity = 0,
				Duration = 0.5,
				Clear_BV = true
			}
		},
		V = {
			Name = "Floppa Meteor",
			Damage = 2.154,
			Cooldown = 15,
			Duration = 3,
			MultiHit_Skill = true,
			Max_Phase = 5,
			Duration_Phase = 0.2,
			Max_Distance = 400,
			Break_Instinct = true,
			Up_Vector = true,
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				Duration = 1.25,
				More_Delay = 0.1,
				Clear_BV = true
			}
		},
		F = {
			Name = "Floppa Flight",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 275
		}
	},
	["Dog Power"] = {
		Droppable = true,
		Unstoreable = true,
		Z = {
			Name = "Dog Throw",
			Damage = 1.931,
			Cooldown = 6,
			Duration = 2,
			Moving_Speed = 250,
			Max_Distance = 600,
			Up_Vector = true,
			Max_Phase = 5,
			Duration_Phase = 0.2,
			IsExplosion = true,
			Break_Instinct = true,
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				Duration = 1,
				Clear_BV = true
			}
		},
		X = {
			Name = "Dog Roar",
			Damage = 1.939,
			Cooldown = 8,
			Duration = 2,
			Holding_Skill = true,
			Skill_Type = "Pulling",
			Max_Distance = 100,
			Max_Phase = 8,
			Duration_Phase = 0.2,
			Equipped_Needed = true,
			BodyPosition = {
				Type = "Body_Position",
				StunTime = 0.5,
				P = 4500,
				Duration = 2,
				Distance = 5,
				Clear_BV = true,
				Invincible = 1,
				Ignore_Default = true,
				TurnBack = true,
				Respect_Duration = true,
				Respect_Holding = true
			}
		},
		C = {
			Name = "Dog Beam",
			Damage = 1.924,
			Cooldown = 11,
			Duration = 3,
			MultiHit_Skill = true,
			Max_Phase = 5,
			Duration_Phase = 0.3,
			Max_Distance = 400,
			Break_Instinct = true,
			Up_Vector = true,
			Knockback = {
				Velocity = 5,
				StunTime = 0.5,
				Duration = 1.5,
				Clear_BV = true
			}
		},
		V = {
			Name = "Dog Summon",
			Damage = 1.967,
			Cooldown = 25,
			Distance = 200
		},
		F = {
			Name = "Dog Flight",
			Cooldown = 4,
			Duration = 60,
			Flying_Speed = 275
		}
	},
	None = {
		Health = 0
	},
	["Floppa Hat"] = {
		Health = 500,
		FightingStyle_Damage = 1.05
	},
	["Egg Doge"] = {
		Health = 750,
		Weapon_Damage = 1.1,
		Defense = 1.05
	},
	["Sus Face"] = {
		Health = 666,
		Power_Damage = 1.1,
		Power_Cooldown = 1.1
	},
	["Giant Banana"] = {
		Regeneration_Boost = 1.2,
		FightingStyle_Damage = 1.1,
		FightingStyle_Cooldown = 1.1
	},
	Obamid = {
		Health = 500,
		WalkSpeed_Boost = 10,
		Defense = 1.05
	},
	["Moai Face"] = {
		Health = 2500,
		Defense = 1.25,
		Regeneration_Boost = 1.25
	},
	["Rick Buddy"] = {
		FightingStyle_Cooldown = 1.1,
		Weapon_Cooldown = 1.1,
		Power_Cooldown = 1.1
	},
	MrBeast = {
		Health = 777,
		Money_Boost = 1.1,
		Exp_Boost = 1.1
	},
	["Popcat Pet"] = {
		WalkSpeed_Boost = 5,
		Power_Damage = 1.15,
		Weapon_Cooldown = 1.1
	},
	["Pumpkin Head"] = {
		Regeneration_Boost = 1.5,
		WalkSpeed_Boost = 5,
		Health = 500
	},
	["Noob Friend"] = {
		Health = 750,
		WalkSpeed_Boost = 5,
		Defense = 1.075,
		FightingStyle_Damage = 1.075,
		Weapon_Damage = 1.075,
		Power_Damage = 1.075,
		FightingStyle_Cooldown = 1.075,
		Weapon_Cooldown = 1.075,
		Power_Cooldown = 1.075
	},
	["Sus Pals"] = {
		Health = 1000,
		FightingStyle_Damage = 1.1,
		Weapon_Damage = 1.1,
		Instinct_Dodge = 3,
		Power_Cooldown = 1.15
	},
	["Nah, I'd Lose."] = {
		Health = -99,
		FightingStyle_Damage = 0.5,
		Weapon_Damage = 0.5,
		Power_Damage = 0.5,
		FightingStyle_Cooldown = 0.25,
		Weapon_Cooldown = 0.25,
		Power_Cooldown = 0.25,
		WalkSpeed_Boost = -5
	},
	["Nah, I'd Win."] = {
		Health = 236,
		FightingStyle_Damage = 6,
		Weapon_Damage = 6,
		Power_Damage = 6,
		FightingStyle_Cooldown = 8.5,
		Weapon_Cooldown = 8.5,
		Power_Cooldown = 8.5,
		WalkSpeed_Boost = 5
	},
	Valkyrie = {
		Health = 999,
		Money_Boost = 10.99,
		Exp_Boost = 10.99,
		WalkSpeed_Boost = 9
	},
	["Floppa Pet"] = {
		Health = 5000,
		Regeneration_Boost = 6,
		Defense = 6,
		WalkSpeed_Boost = 5
	},
	["Quest Scroll"] = {
		Max_Capacity = 99,
		Unstoreable = true,
		Droppable = true
	},
	["Noob Head"] = {
		Max_Capacity = 99,
		Droppable = false
	},
	["Awakening Orb"] = {
		Max_Capacity = 99,
		Unstoreable = true,
		Droppable = true
	},
	["Meme Cube"] = {
		Max_Capacity = 99,
		Droppable = false
	},
	["Flame Orb"] = {
		Max_Capacity = 99,
		Droppable = false
	},
	["Sussy Orb"] = {
		Max_Capacity = 99,
		Droppable = false
	},
	Ball = {
		Max_Capacity = 99,
		Droppable = false
	},
	["Cat Food"] = {
		Max_Capacity = 99,
		Droppable = false
	},
	["Cheems Cola"] = {
		Max_Capacity = 99,
		Droppable = false
	},
	["Nugget Man"] = {
		Max_Capacity = 99,
		Droppable = false
	},
	["Money Bag"] = {
		Max_Capacity = 99,
		Droppable = false
	}
}