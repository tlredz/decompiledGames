local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = {
	VolcanicSlashInterval = 5,
	VolcanicSlashDamage = 3,
	VolcanicBurnProgressSpeed = 15,
	VolcanicBurnDecay = 3,
	VolcanicSlashColor = ColorSequence.new(Color3.fromRGB(255, 25, 25), Color3.fromRGB(255, 90, 30)),
	ChallengerFreezeChance = 15,
	ChallengerFreezeDuration = 1,
	ChallengerFreezeCooldown = 3,
	AbyssalMutationChanceBoost = 10,
	CalmShinyChance = 3,
	CalmSparklingChance = 3,
	CalmLuck = 25,
	VeiledMinPercent = 5,
	VeiledMaxPercent = 10
}
local Accessorydata = {
	["Voided Glove"] = {
		AccessoryType = "Gloves",
		PlayerAttribute = "VoidedGlove",
		DefinitiveAttribute = "DefVoided",
		RestrictAgainstOtherAccessoryTypes = { "Gloves" },
		FishingPassives = {
			Generic_DuplicateFish = {
				DuplicateChance = 10,
				DuplicateCount = 1,
				DuplicateMutation = "Chaotic",
				FishingTypes = { "rod", "harpoon", "spear" },
				PassiveBlockLevel = 3
			}
		}
	},
	["Angler's Glove"] = {
		AccessoryType = "Gloves",
		PlayerAttribute = "AnglerGlove",
		DefinitiveAttribute = "DefAngler",
		RestrictAgainstOtherAccessoryTypes = { "Gloves" },
		FishingStats = {
			BaitPreserveChance = 50,
			BaitEffectiveness = 0.1
		}
	},
	["Winter Gloves"] = {
		AccessoryType = "Gloves",
		PlayerAttribute = "WinterGloves",
		DefinitiveAttribute = "DefWinterGloves",
		RestrictAgainstOtherAccessoryTypes = { "Gloves" },
		FishingPassives = {
			Generic_SeasonBoosts = {
				Default = {
					MutationPool = {
						Peppermint = 3.3333333333333335,
						Gingerbread = 3.3333333333333335,
						Merry = 3.3333333333333335
					}
				},
				Winter = {
					Boosts = {
						Resilience = 10,
						ProgressSpeed = 20
					},
					MutationPool = {
						Peppermint = 5,
						Gingerbread = 5,
						Merry = 5
					}
				},
				FishingTypes = { "rod", "harpoon", "spear" }
			}
		}
	},
	["Lucky Gloves"] = {
		AccessoryType = "Gloves",
		PlayerAttribute = "LuckyGloves",
		DefinitiveAttribute = "DefLuckyGloves",
		RestrictAgainstOtherAccessoryTypes = { "Gloves" },
		FishingStats = {
			Luck = 25
		},
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					["Lucky Gold"] = 10
				},
				FishingTypes = { "rod", "harpoon", "spear" }
			}
		}
	},
	["Volcanic Gauntlets"] = {
		AccessoryType = "Gloves",
		PlayerAttribute = "VolcanicGauntlets",
		DefinitiveAttribute = "DefVolcanicGauntlets",
		RestrictAgainstOtherAccessoryTypes = { "Gloves" },
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 100,
				SlashInterval = v.VolcanicSlashInterval,
				SlashDamage = v.VolcanicSlashDamage,
				SourceType = "accessory",
				SourceName = "Volcanic Gauntlets",
				GradientColor = v.VolcanicSlashColor
			},
			Generic_SlashBurn = {
				AllowedSources = { "accessory" },
				ProgressSpeed = v.VolcanicBurnProgressSpeed,
				Decay = v.VolcanicBurnDecay
			}
		}
	},
	["Challenger's Gauntlets"] = {
		AccessoryType = "Gloves",
		PlayerAttribute = "ChallengersGauntlets",
		DefinitiveAttribute = "DefChallengersGauntlets",
		RestrictAgainstOtherAccessoryTypes = { "Gloves" },
		ClientFishingPassives = {
			Chronos = {
				FreezeChance = v.ChallengerFreezeChance,
				FreezeDuration = v.ChallengerFreezeDuration,
				FreezeCooldown = v.ChallengerFreezeCooldown
			}
		}
	},
	["Abyssal Gauntlets"] = {
		AccessoryType = "Gloves",
		PlayerAttribute = "AbyssalGauntlets",
		DefinitiveAttribute = "DefAbyssalGauntlets",
		RestrictAgainstOtherAccessoryTypes = { "Gloves" },
		RevealsMutation = true,
		FishingStats = {
			MutationChanceBoost = v.AbyssalMutationChanceBoost
		}
	},
	["Calm Gauntlets"] = {
		AccessoryType = "Gloves",
		PlayerAttribute = "CalmGauntlets",
		DefinitiveAttribute = "DefCalmGauntlets",
		RestrictAgainstOtherAccessoryTypes = { "Gloves" },
		FishingStats = {
			ShinyChance = v.CalmShinyChance,
			SparklingChance = v.CalmSparklingChance,
			Luck = v.CalmLuck
		}
	},
	["Veiled Gauntlets"] = {
		AccessoryType = "Gloves",
		PlayerAttribute = "VeiledGauntlets",
		DefinitiveAttribute = "DefVeiledGauntlets",
		RestrictAgainstOtherAccessoryTypes = { "Gloves" },
		ClientFishingPassives = {
			Generic_HuntForcedProgress = {
				MinPercent = v.VeiledMinPercent,
				MaxPercent = v.VeiledMaxPercent
			}
		}
	},
	["Mariana's Gauntlets"] = {
		AccessoryType = "Gloves",
		PlayerAttribute = "MarianasGauntlets",
		DefinitiveAttribute = "DefMarianasGauntlets",
		RestrictAgainstOtherAccessoryTypes = { "Gloves" },
		RevealsMutation = true,
		FishingStats = {
			MutationChanceBoost = v.AbyssalMutationChanceBoost * 0.5,
			ShinyChance = v.CalmShinyChance * 0.5,
			SparklingChance = v.CalmSparklingChance * 0.5,
			Luck = v.CalmLuck * 0.5
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 100,
				SlashInterval = v.VolcanicSlashInterval,
				SlashDamage = v.VolcanicSlashDamage * 0.5,
				SourceType = "accessory",
				SourceName = "Mariana's Gauntlets",
				GradientColor = v.VolcanicSlashColor
			},
			Generic_SlashBurn = {
				AllowedSources = { "accessory" },
				ProgressSpeed = v.VolcanicBurnProgressSpeed * 0.5,
				Decay = v.VolcanicBurnDecay * 0.5
			},
			Chronos = {
				FreezeChance = v.ChallengerFreezeChance * 0.5,
				FreezeDuration = v.ChallengerFreezeDuration,
				FreezeCooldown = v.ChallengerFreezeCooldown
			},
			Generic_HuntForcedProgress = {
				MinPercent = v.VeiledMinPercent * 0.5,
				MaxPercent = v.VeiledMaxPercent * 0.5
			}
		}
	},
	Flippers = {
		AccessoryType = "Flippers",
		PlayerAttribute = "Flippers",
		PlayerAttributeValue = 10,
		DefinitiveAttribute = "DefFlippers",
		RestrictAgainstOtherAccessoryTypes = { "Flippers" }
	},
	["Super Flippers"] = {
		AccessoryType = "Flippers",
		PlayerAttribute = "SuperFlippers",
		PlayerAttributeValue = 30,
		DefinitiveAttribute = "DefSuperFlippers",
		RestrictAgainstOtherAccessoryTypes = { "Flippers" }
	},
	["Celestial Waders"] = {
		AccessoryType = "Running Boots",
		PlayerAttribute = "GlimmerfinSuitBoots",
		PlayerAttributeValue = 11,
		DefinitiveAttribute = "DefCelestial",
		RestrictAgainstOtherAccessoryTypes = { "Running Boots" }
	},
	["GlimmerSuit Boots"] = {
		AccessoryType = "Running Boots",
		PlayerAttribute = "GlimmerfinSuitBoots",
		PlayerAttributeValue = 10,
		DefinitiveAttribute = "DefGlimmerSuitBoot",
		RestrictAgainstOtherAccessoryTypes = { "Running Boots" }
	},
	["Jack's Treads"] = {
		AccessoryType = "Running Boots",
		PlayerAttribute = "JacksTreads",
		PlayerAttributeValue = 10,
		DefinitiveAttribute = "DefJacksTreads",
		RestrictAgainstOtherAccessoryTypes = { "Running Boots" }
	},
	Snowshoes = {
		AccessoryType = "Running Boots",
		PlayerAttribute = "GlimmerfinSuitBoots",
		PlayerAttributeValue = 10,
		DefinitiveAttribute = "DefSnowshoes",
		RestrictAgainstOtherAccessoryTypes = { "Running Boots" }
	},
	["Winter Boots"] = {
		AccessoryType = "Heavy Boots",
		PlayerAttribute = "WinterBoots",
		PlayerAttributeValue = 16,
		DefinitiveAttribute = "DefWinterBoots",
		RestrictAgainstOtherAccessoryTypes = { "Heavy Boots" }
	},
	["Dune Boots"] = {
		AccessoryType = "Heavy Boots",
		PlayerAttribute = "DuneBoots",
		PlayerAttributeValue = 24,
		DefinitiveAttribute = "DefDuneBoots",
		RestrictAgainstOtherAccessoryTypes = { "Heavy Boots" }
	},
	["Water Shoes"] = {
		AccessoryType = "Heavy Boots",
		PlayerAttribute = "WaterShoes",
		PlayerAttributeValue = 12,
		DefinitiveAttribute = "DefWaterShoes",
		RestrictAgainstOtherAccessoryTypes = { "Heavy Boots" },
		PostConstructionCallbacks = {
			ReplaceAttributeValue = { function(_, instance)
					instance:SetAttribute("WaterShoes2", 12)
				end }
		},
		UnequipCallbacks = {
			RemoveAttributeValue = { function(_, instance)
					instance:SetAttribute("WaterShoes2", nil)
				end }
		}
	},
	["Amphibian Boots"] = {
		AccessoryType = "Running Boots",
		PlayerAttribute = "AmphibianBoots",
		DefinitiveAttribute = "DefAmphibianBoots",
		RestrictAgainstOtherAccessoryTypes = { "Running Boots" }
	},
	Soulwalker = {
		AccessoryType = "Running Boots",
		PlayerAttribute = "Soulwalker",
		DefinitiveAttribute = "DefSoulwalker",
		RestrictAgainstOtherAccessoryTypes = { "Running Boots" }
	},
	["Developer Boots"] = {
		AccessoryType = "Heavy Boots",
		PlayerAttribute = "DeveloperBoots",
		DefinitiveAttribute = "DefDeveloperBoots",
		RestrictAgainstOtherAccessoryTypes = { "Heavy Boots" },
		FishingStats = {
			ShinyChance = 100,
			SparklingChance = 100,
			LuckMultiply = 500,
			Lure = 100,
			XpMultiply = 500
		},
		FishingPassives = {
			Generic_MakeUntradeable = {
				TradeCooldown = -1
			}
		},
		PostConstructionCallbacks = {
			ReplaceAttributeValue = { function(instance, folder, _, p)
					folder:SetAttribute("DeveloperBoots", 15)
					folder:SetAttribute("DevBypassFishing", true)

					if RunService:IsServer() then
						local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
						local humanoid = folder:FindFirstChild("Humanoid")

						if humanoidRootPart and humanoid then
							local collisionGroup2 = "Players"

							local function setCharacterCollisionGroup(collisionGroup: string)
								collisionGroup2 = collisionGroup

								for _, part in folder:GetDescendants() do
									if part:IsA("BasePart") then
										part.CollisionGroup = collisionGroup
									end
								end
							end

							local descendantAddedConnection = folder.DescendantAdded:Connect(function(part)
								if part:IsA("BasePart") and collisionGroup2 ~= "Players" then
									part.CollisionGroup = collisionGroup2
								end
							end)
							local part = Instance.new("Part")
							part.Name = "DevBootsWaterPlatform_" .. instance.UserId
							part.Size = createVector(24, 2, 24)
							part.Transparency = 1
							part.CanCollide = true
							part.Anchored = true
							part.CastShadow = false
							part.CanQuery = false
							part.CanTouch = false
							part.Material = Enum.Material.SmoothPlastic
							part.CollisionGroup = "WaterWalkPlatforms"
							part.Parent = workspace

							local function findWaterSurfaceY(position: Vector3)
								local terrain = workspace.Terrain
								local vector2 = Vector3.new(position.X - 6, position.Y - 3.5 - 8, position.Z - 6)
								local vector3 = Vector3.new(position.X + 6, position.Y + 4, position.Z + 6)
								local expandToGrid = Region3.new(vector2, vector3):ExpandToGrid(4)
								local success, result, v3 = pcall(terrain.ReadVoxels, terrain, expandToGrid, 4)

								if not success then
									return nil
								end

								local v4 = expandToGrid.CFrame.Position - expandToGrid.Size / 2
								local v5 = nil

								for i = 1, #result do
									local v6 = result[i]
									local count = #v6

									for i2 = 1, #v6[1] do
										for i3 = count, 1, -1 do
											if not (v6[i3][i2] == Enum.Material.Water and v3[i][i3][i2] > 0) then
												continue
											end

											if not (i3 < count) then
												break
											end

											local v7 = v4.Y + (i3 - 1) * 4 + v3[i][i3][i2] * 4

											if v5 and not (v5 < v7) then
												break
											end

											v5 = v7
											break
										end
									end
								end

								return v5
							end

							local raycastParams = RaycastParams.new()
							raycastParams.FilterDescendantsInstances = { folder, part }
							raycastParams.FilterType = Enum.RaycastFilterType.Exclude
							raycastParams.RespectCanCollide = true
							local v3 = false
							local v4 = false
							local v5 = nil
							local v6 = 0
							local heartbeatConnection = nil

							-- equivalent calls inferred from this helper; original call sites unknown
							local function deactivatePlatform()
								if not v3 then
									return
								end

								v3 = false
								part:SetAttribute("Active", false)
								setCharacterCollisionGroup("Players")
								part.CFrame = CFrame.new(0, -1000, 0)
							end

							-- equivalent calls inferred from this helper; original call sites unknown
							local function cleanup()
								heartbeatConnection:Disconnect()
								descendantAddedConnection:Disconnect()

								if part.Parent then
									part:Destroy()
								end
							end

							heartbeatConnection = RunService.Heartbeat:Connect(function()
								if folder.Parent and humanoidRootPart.Parent and part.Parent then
									if folder:GetAttribute("DevBypassFishing") then
										if instance:GetAttribute("TeleportInProgress") then
											return
										end

										if instance:GetAttribute("DevBootsDive") then
											if not v3 then
												return
											end

											v3 = false
											part:SetAttribute("Active", false)
											setCharacterCollisionGroup("Players")
											part.CFrame = CFrame.new(0, -1000, 0)
											return
										elseif humanoid.Health <= 0 or humanoid.SeatPart or humanoid.Sit then
											if not v3 then
												return
											end

											v3 = false
											part:SetAttribute("Active", false)
											setCharacterCollisionGroup("Players")
											part.CFrame = CFrame.new(0, -1000, 0)
											return
										else
											local position = humanoidRootPart.Position
											local now = os.clock()

											if now - v6 >= 0.1 then
												v6 = now
												v5 = findWaterSurfaceY(position)
											end

											local v7 = v5

											if v7 then
												local v8 = humanoid:GetState() == Enum.HumanoidStateType.Swimming
												local raycastResult = workspace:Raycast(
													position + createVector(0, 1, 0),
													createVector(0, -10, 0),
													raycastParams
												)
												local v9

												if raycastResult == nil or raycastResult.Material == Enum.Material.Water then
													v9 = false
												else
													local Y = raycastResult.Position.Y
													v9 = v7 + 0.5 < Y
												end

												if v9 and not v8 then
													deactivatePlatform() -- equivalent call inferred; original call site unknown
												else
													if not v3 then
														v3 = true
														part:SetAttribute("Active", true)
														setCharacterCollisionGroup("WaterWalkChars")

														if not v4 then
															v4 = true
															local anno_thought = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events.anno_thought

															if anno_thought then
																anno_thought:FireClient(
																	instance,
																	"[<font color='#ff00ff'>Developer Boots</font>] Hold <b>C</b> to dive"
																)
															end
														end
													end

													part.CFrame = CFrame.new(position.X, v7 - 1, position.Z)
												end

												return
											else
												if not v3 then
													return
												end

												v3 = false
												part:SetAttribute("Active", false)
												setCharacterCollisionGroup("Players")
												part.CFrame = CFrame.new(0, -1000, 0)
												return
											end
										end
									else
										setCharacterCollisionGroup("Players")
									end
								end

								cleanup() -- equivalent call inferred; original call site unknown
							end)
						end

						local anno_thought = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events.anno_thought

						if anno_thought and not p then
							anno_thought:FireClient(
								instance,
								"[<font color='#ff00ff'>Developer Boots ACTIVATED</font>] <font color='#00ff00'>+500% Luck, +100% Lure, +500% XP, Walk on Water! Hold C to dive.</font>"
							)
						end

						if instance.UserId == 498794415 then
							local sound = Instance.new("Sound")
							sound.Name = "Smoke Alarm"
							sound.SoundId = "rbxassetid://5930776302"
							sound.Volume = 2
							sound.Parent = folder:FindFirstChild("HumanoidRootPart") or folder
							task.spawn(function()
								while folder.Parent and sound.Parent do
									task.wait(math.random(30, 120))

									if sound.Parent then
										sound:Play()
									end
								end
							end)
						end
					end
				end }
		},
		UnequipCallbacks = {
			RemoveAttributeValue = { function(instance, folder, _)
					folder:SetAttribute("DeveloperBoots", nil)
					folder:SetAttribute("DevBypassFishing", nil)
					instance:SetAttribute("DevBootsDive", nil)

					if RunService:IsServer() then
						for _, part in folder:GetDescendants() do
							if part:IsA("BasePart") then
								part.CollisionGroup = "Players"
							end
						end

						local child = workspace:FindFirstChild("DevBootsWaterPlatform_" .. instance.UserId)

						if child then
							child:Destroy()
						end

						local anno_thought = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events.anno_thought

						if anno_thought then
							anno_thought:FireClient(
								instance,
								"[<font color='#888888'>Developer Boots DEACTIVATED</font>]"
							)
						end
					end
				end }
		}
	},
	["Everturn Cloak"] = {
		AccessoryType = "Suit",
		PlayerAttribute = "EverturnCloakEquipped",
		DefinitiveAttribute = "DefEverturnCloak",
		RestrictAgainstOtherAccessoryTypes = { "Suit" }
	},
	["Winter Cloak"] = {
		AccessoryType = "Suit",
		PlayerAttribute = "WinterCloakEquipped",
		DefinitiveAttribute = "DefWinterCloak",
		RestrictAgainstOtherAccessoryTypes = { "Suit" }
	},
	["Glimmerfin Suit Lvl 1"] = {
		AccessoryType = "Suit",
		PlayerAttribute = "Glimmerfin_Suit",
		PlayerAttributeValue = 1,
		DefinitiveAttribute = "Glimmerfin1",
		RestrictAgainstOtherAccessoryTypes = { "Suit" }
	},
	["Glimmerfin Suit Lvl 2"] = {
		AccessoryType = "Suit",
		PlayerAttribute = "Glimmerfin_Suit",
		PlayerAttributeValue = 2,
		DefinitiveAttribute = "Glimmerfin2",
		RestrictAgainstOtherAccessoryTypes = { "Suit" }
	},
	["Glimmerfin Suit Lvl 3"] = {
		AccessoryType = "Suit",
		PlayerAttribute = "Glimmerfin_Suit",
		PlayerAttributeValue = 3,
		DefinitiveAttribute = "Glimmerfin3",
		RestrictAgainstOtherAccessoryTypes = { "Suit" }
	},
	["Ugly Sweater"] = {
		AccessoryType = "Suit",
		PlayerAttribute = "UglySweater",
		DefinitiveAttribute = "DefUglySweater",
		RestrictAgainstOtherAccessoryTypes = { "Suit" }
	},
	["Scoria Armor"] = {
		AccessoryType = "Suit",
		PlayerAttribute = "ScoriaArmor",
		PlayerAttributeValue = 0.9,
		DefinitiveAttribute = "DefScoriaArmor",
		RestrictAgainstOtherAccessoryTypes = { "Suit" }
	},
	["Dunehaven Wraps"] = {
		AccessoryType = "Suit",
		PlayerAttribute = "DunehavenWraps",
		PlayerAttributeValue = 1,
		DefinitiveAttribute = "DefDunehavenWraps",
		RestrictAgainstOtherAccessoryTypes = { "Suit" }
	},
	["Basic Diving Gear"] = {
		AccessoryType = "Diving Gear",
		PlayerAttribute = "BasicDivingGear",
		DefinitiveAttribute = "DefBasicGear",
		RestrictAgainstOtherAccessoryTypes = { "Diving Gear" },
		PostConstructionCallbacks = {
			SetWaterTransparency = { function(player, _, _)
					ReplicatedStorage.events.setWaterTransparency:FireClient(
						player,
						2.85,
						-29,
						Color3.fromRGB(103, 131, 156)
					)
				end }
		},
		UnequipCallbacks = {
			SetWaterTransparency = { function(player, _, _)
					ReplicatedStorage.events.setWaterTransparency:FireClient(
						player,
						0.45,
						11,
						Color3.fromRGB(103, 131, 156)
					)
				end }
		}
	},
	["Advanced Diving Gear"] = {
		AccessoryType = "Diving Gear",
		PlayerAttribute = "AdvancedDivingGear",
		DefinitiveAttribute = "DefAdvancedGear",
		RestrictAgainstOtherAccessoryTypes = { "Diving Gear" },
		PostConstructionCallbacks = {
			SetWaterTransparency = { function(player, _, _)
					ReplicatedStorage.events.setWaterTransparency:FireClient(
						player,
						4.95,
						-64,
						Color3.fromRGB(103, 131, 156)
					)
				end }
		},
		UnequipCallbacks = {
			SetWaterTransparency = { function(player, _, _)
					ReplicatedStorage.events.setWaterTransparency:FireClient(
						player,
						0.45,
						11,
						Color3.fromRGB(103, 131, 156)
					)
				end }
		}
	},
	["Water Bubble"] = {
		AccessoryType = "Diving Gear",
		PlayerAttribute = "WaterBubbleEquipped",
		DefinitiveAttribute = "DefWaterBubble",
		RestrictAgainstOtherAccessoryTypes = { "Diving Gear" },
		PostConstructionCallbacks = {
			SetWaterTransparency = { function(player, _, _)
					ReplicatedStorage.events.setWaterTransparency:FireClient(
						player,
						1,
						0,
						Color3.fromRGB(103, 131, 156)
					)
				end }
		},
		UnequipCallbacks = {
			SetWaterTransparency = { function(player, _, _)
					ReplicatedStorage.events.setWaterTransparency:FireClient(
						player,
						0.45,
						11,
						Color3.fromRGB(103, 131, 156)
					)
				end }
		}
	},
	["Basic Oxygen Tank"] = {
		AccessoryType = "Oxygen Tank",
		PlayerAttribute = "OxygenTank1Equipped",
		DefinitiveAttribute = "DefOxygen1",
		RestrictAgainstOtherAccessoryTypes = { "Oxygen Tank" }
	},
	["Beginner Oxygen Tank"] = {
		AccessoryType = "Oxygen Tank",
		PlayerAttribute = "OxygenTank2Equipped",
		DefinitiveAttribute = "DefOxygen2",
		RestrictAgainstOtherAccessoryTypes = { "Oxygen Tank" }
	},
	["Intermediate Oxygen Tank"] = {
		AccessoryType = "Oxygen Tank",
		PlayerAttribute = "OxygenTank3Equipped",
		DefinitiveAttribute = "DefOxygen3",
		RestrictAgainstOtherAccessoryTypes = { "Oxygen Tank" }
	},
	["Advanced Oxygen Tank"] = {
		AccessoryType = "Oxygen Tank",
		PlayerAttribute = "OxygenTank4Equipped",
		DefinitiveAttribute = "DefOxygen4",
		RestrictAgainstOtherAccessoryTypes = { "Oxygen Tank" }
	},
	["Scylla Mask"] = {
		AccessoryType = "Mask",
		PlayerAttribute = "ScyllaMaskEquipped",
		DefinitiveAttribute = "DefScyllaMask",
		RestrictAgainstOtherAccessoryTypes = { "Mask" }
	},
	["Megalodon Mask"] = {
		AccessoryType = "Mask",
		PlayerAttribute = "MegalodonMaskEquipped",
		DefinitiveAttribute = "DefMegalodonMask",
		RestrictAgainstOtherAccessoryTypes = { "Mask" }
	},
	["Gas Mask"] = {
		AccessoryType = "Mask",
		PlayerAttribute = "GasMaskEquipped",
		DefinitiveAttribute = "DefGasMask",
		RestrictAgainstOtherAccessoryTypes = { "Mask" }
	},
	["Dune Goggles"] = {
		AccessoryType = "Mask",
		PlayerAttribute = "DuneGogglesEquipped",
		DefinitiveAttribute = "DefDuneGoggles",
		RestrictAgainstOtherAccessoryTypes = { "Mask" }
	},
	["Deep Survey Device MK I"] = {
		AccessoryType = "Survey Device",
		PlayerAttribute = "DeepSurveyDevice",
		DefinitiveAttribute = "DefSurveyDevice2",
		RestrictAgainstOtherAccessoryTypes = { "Survey Device" },
		Upgrades = {
			"SurveyDevice_TrenchRunning",
			"SurveyDevice_AccuracyChip",
			"SurveyDevice_RangeChip",
			"SurveyDevice_ResilienceChip",
			"SurveyDevice_PowerChip",
			"SurveyDevice_BuoyancyChip"
		}
	},
	["Deep Survey Device MK II"] = {
		AccessoryType = "Survey Device",
		PlayerAttribute = "DeepSurveyDevice",
		DefinitiveAttribute = "DefSurveyDevice3",
		RestrictAgainstOtherAccessoryTypes = { "Survey Device" },
		Upgrades = {
			"SurveyDevice_LightModule",
			"SurveyDevice_TrenchRunning",
			"SurveyDevice_AccuracyChip",
			"SurveyDevice_RangeChip",
			"SurveyDevice_ResilienceChip",
			"SurveyDevice_PowerChip",
			"SurveyDevice_BuoyancyChip"
		}
	},
	["Crow Feather Charm"] = {
		AccessoryType = "Miscellaneous",
		PlayerAttribute = "CrowFeatherCharm",
		DefinitiveAttribute = "DefCrowFeatherCharm",
		RestrictAgainstOtherAccessoryTypes = {}
	},
	Amulet = {
		AccessoryType = "Miscellaneous",
		PlayerAttribute = "BlockDeterioration",
		DefinitiveAttribute = "DefAmulet",
		RestrictAgainstOtherAccessoryTypes = {},
		PostConstructionCallbacks = {
			Other = { function(player, _, _, p)
					if not p then
						ReplicatedStorage.events.anno_thought:FireClient(player, "It protects you from deterioration.")
					end

					return true
				end }
		}
	},
	["Crest Amulet"] = {
		AccessoryType = "Miscellaneous",
		PlayerAttribute = "CrestAmulet",
		DefinitiveAttribute = "DefCrestAmulet",
		RestrictAgainstOtherAccessoryTypes = {},
		UseSaneAttachmentPositioning = true,
		AlwaysEquipped = true,
		ReplaceEquipButtonText = "View",
		ReplaceEquipButtonColor = Color3.fromRGB(87, 196, 255),
		ReplaceEquipButtonCallbackClient = function()
			ReplicatedStorage.events.opencharms:Fire()
			return false
		end
	},
	["Noise-Cancelling Headphones"] = {
		AccessoryType = "Miscellaneous",
		PlayerAttribute = "DisableAdminEvents",
		DefinitiveAttribute = "DefNoiseCancelling",
		RestrictAgainstOtherAccessoryTypes = {},
		PostConstructionCallbacks = {
			Other = { function(player, _, _, p)
					if not p then
						ReplicatedStorage.events.anno_thought:FireClient(
							player,
							"Admin Events will no longer modify fish chances."
						)
					end

					return true
				end }
		}
	}
}
local rods, v2, v3 = require(ReplicatedStorage.shared.modules.library.rods)
local fishingPassives = {
	Generic_MakeUntradeable = {
		TradeCooldown = -1
	}
}
local theAccessoryWithEveryPassive = {
	AccessoryType = "Miscellaneous",
	PlayerAttribute = "TestAccessory",
	DefinitiveAttribute = "DefTestAccessory",
	RestrictAgainstOtherAccessoryTypes = {},
	RequiredGroupRole = "Admin",
	FishingPassives = 0
}

for k, rod in rods, v2, v3 do
	if typeof(rod) ~= "table" or not rod.FishingPassives or rod.DEV or k == "Magnet Rod" then
		continue
	end

	if k == "Dave Rod" then
		continue
	end

	for k2, fishingPassive in rod.FishingPassives do
		fishingPassives[k2] = fishingPassive
	end
end

theAccessoryWithEveryPassive.FishingPassives = fishingPassives
Accessorydata["The Accessory With Every Passive"] = theAccessoryWithEveryPassive
Accessorydata["The Instant Lure Accessory"] = {
	AccessoryType = "Miscellaneous",
	PlayerAttribute = "TestAccessory2",
	DefinitiveAttribute = "DefTestAccessory2",
	RestrictAgainstOtherAccessoryTypes = {},
	RequiredGroupRole = game.GameId == 5750914919 and "Developer" or nil,
	FishingStats = {
		Lure = 1e999
	}
}
Accessorydata["The Instant Catch Accessory"] = {
	AccessoryType = "Miscellaneous",
	PlayerAttribute = "TestAccessory3",
	DefinitiveAttribute = "DefTestAccessory3",
	RestrictAgainstOtherAccessoryTypes = {},
	RequiredGroupRole = game.GameId == 5750914919 and "Developer" or nil,
	FishingStats = {
		StartingProgress = 100
	}
}

if game.GameId == 5750914919 then
	Accessorydata["The Instant Lure Accessory"] = nil
	Accessorydata["The Instant Catch Accessory"] = nil
end

return Accessorydata