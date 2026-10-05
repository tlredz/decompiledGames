local CustomModeInfo = {
	Events = {
		["On join"] = {
			Extensions = {
				Variables = {
					Author = {
						ValueType = "Player",
						CanWrite = true
					}
				}
			}
		},
		["On leave"] = {
			Extensions = {
				Variables = {
					Author = {
						ValueType = "Player",
						CanWrite = true
					}
				}
			}
		},
		["On death"] = {
			Extensions = {
				Variables = {
					Killer = {
						ValueType = "Player",
						CanWrite = true,
						IsOptional = true
					},
					Victim = {
						ValueType = "Player",
						CanWrite = true
					}
				}
			}
		},
		Parried = {
			Extensions = {
				Variables = {
					Author = {
						ValueType = "Player",
						CanWrite = true
					},
					Target = {
						ValueType = "Player",
						CanWrite = true
					}
				}
			}
		},
		["Ability used"] = {
			Extensions = {
				Variables = {
					Author = {
						ValueType = "Player",
						CanWrite = true
					},
					Target = {
						ValueType = "Player",
						CanWrite = true,
						IsOptional = true
					}
				}
			}
		},
		["Ability used on player"] = {
			Extensions = {
				Variables = {
					Author = {
						ValueType = "Player",
						CanWrite = true
					},
					Target = {
						ValueType = "Player",
						CanWrite = true
					}
				}
			}
		},
		["On ball spawn"] = {}
	},
	Variables = {
		["Ball Speed"] = {
			ValueType = "Number",
			CanWrite = true
		},
		["Player Count"] = {
			ValueType = "Number",
			CanWrite = false
		},
		Alive = {
			ValueType = "Number",
			CanWrite = false
		}
	},
	ValueTypes = {
		Player = {
			Properties = {
				Health = {
					ValueType = "Number",
					CanWrite = true
				},
				Speed = {
					ValueType = "Number",
					CanWrite = true
				}
			},
			Conditions = {
				Is = {
					"Any",
					"Player",
					"Leader",
					"Bot"
				},
				["Is not"] = { "Player", "Leader", "Bot" }
			},
			Results = {
				Dies = false,
				["Gets kicked"] = false
			}
		},
		Number = {
			Conditions = {
				Equals = true,
				["Higher than"] = true,
				["Lower than"] = true
			},
			Results = {
				Becomes = true,
				Increase = true,
				Decrease = true
			}
		},
		Team = {
			Conditions = {
				Is = true
			},
			Results = {}
		}
	}
}

for k, event in CustomModeInfo.Events do
	event.Name = k
end

for k, variable in CustomModeInfo.Variables do
	variable.Name = k

	if not variable.Properties then
		continue
	end

	for k2, property in variable.Properties do
		property.Name = k2
	end
end

for k, valueType in CustomModeInfo.ValueTypes do
	valueType.Name = k
end

local _ = {
	Name = "Damage non-leader on parry",
	Enabled = true,
	Event = "Parried",
	Conditions = {
		{
			Variable = "Author",
			Type = "Is not",
			Value = "Leader"
		},
		{
			Variable = "Author.Health",
			Type = "Higher than",
			Value = 1
		}
	},
	Results = {
		{
			Variable = "Author.Health",
			Type = "Decrease",
			Value = 1
		}
	}
}
return CustomModeInfo