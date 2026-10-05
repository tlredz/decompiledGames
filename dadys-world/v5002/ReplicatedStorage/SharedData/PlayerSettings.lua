local CollectionService = game:GetService("CollectionService")
local v = false
local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function applyMusicMute(soundGroup)
	if not soundGroup:IsA("SoundGroup") then
		return
	end

	soundGroup:SetAttribute("Muted", v)
	soundGroup.Volume = v and 0 or 1
end

return {
	Tabs = {
		General = {
			"StickerSettings",
			"MusicToggle",
			"LoadoutToggle",
			"TailEffectsToggle",
			"SprintToggle",
			"BuffIndicatorToggle",
			"StatusHudToggle",
			"HapticSlider",
			"CameraReset",
			"Unstuck"
		},
		Graphics = {
			"BlinkToggle",
			"ParticleToggle",
			"MovingTextureToggle",
			"NameTagToggle",
			"HudToggle"
		},
		Controls = { "Keybinds" },
		Accessibility = {
			"HighlightToggle",
			"ScreenEffects",
			"SpottedVisualizer",
			"ColorSettings"
		}
	},
	DisabledTabs = {},
	Hierarchy = {
		MinigameSettings = {
			AngledCamera = {
				Type = "boolean",
				HideFromPlayer = true
			},
			AnimatedBackground = {
				Type = "boolean",
				HideFromPlayer = true
			}
		},
		StickerSettings = {
			ChatEnabled = {
				DisplayText = "Stickers In Chat",
				LayoutOrder = 1,
				Type = "boolean",
				DefaultValue = true,
				HideFromPlayer = true,
				PreviewWindow = {
					Description = "Enabling this setting puts the sticker text into chat.",
					PreviewImage = nil
				}
			},
			ShowWindow = {
				Header = "Information",
				DisplayText = "Sticker Game Window",
				LayoutOrder = 2,
				Type = "boolean",
				DefaultValue = true,
				PreviewWindow = {
					Description = "Displays the sticker chat window in the top right in-game.",
					PreviewImage = "rbxassetid://104938610297873"
				}
			}
		},
		BlinkToggle = {
			DisplayText = "Blink Effect",
			LayoutOrder = 1,
			Type = "boolean",
			DefaultValue = true,
			PreviewWindow = {
				Description = "Displays blinking on characters other than yourself.",
				PreviewImage = nil
			}
		},
		HighlightToggle = {
			DisplayText = "Ability Targeting Arrows",
			LayoutOrder = -1,
			Type = "boolean",
			DefaultValue = true,
			PreviewWindow = {
				Description = "Displays the billboard arrow over highlighted entities from abilities.",
				PreviewImage = "rbxassetid://115500081627625"
			},
			OnServerChange = function(player, flag: boolean)
				if not player or not player.Character or typeof(flag) ~= "boolean" then
					return
				end

				player.Character:SetAttribute("HighlightToggle", flag == true)
			end
		},
		ScreenEffects = {
			DisplayText = "Intense Screen Effects",
			LayoutOrder = 0,
			Type = "choice",
			Options = { "On", "Light", "Off" },
			DefaultValue = "On",
			PreviewWindow = {
				Description = "Controls camera shake, camera warps and full-screen particles. Light tones them down, Off removes them. Gameplay is not affected.",
				PreviewImage = nil
			}
		},
		SpottedVisualizer = {
			DisplayText = "Spotted Visualizer",
			LayoutOrder = 1,
			Type = "boolean",
			DefaultValue = false,
			PreviewWindow = {
				Description = "Shows a visual indicator when a Twisted spots you.",
				PreviewImage = nil
			}
		},
		LoadoutToggle = {
			DisplayText = "Toggle Loadouts",
			LayoutOrder = 5,
			Type = "boolean",
			DefaultValue = false,
			PreviewWindow = {
				Description = "Displays trinket loadouts when hovering over players in game.",
				PreviewImage = nil
			}
		},
		MusicToggle = {
			Header = "Gameplay",
			DisplayText = "Mute Music",
			LayoutOrder = 4,
			Type = "boolean",
			DefaultValue = false,
			OnChangeClient = function(flag: boolean)
				v = flag == true

				for _, v3 in pairs(CollectionService:GetTagged("MusicSource")) do
					applyMusicMute(v3) -- equivalent call inferred; original call site unknown
				end

				if not v2 then
					v2 = true
					CollectionService:GetInstanceAddedSignal("MusicSource"):Connect(applyMusicMute)
				end
			end,
			PreviewWindow = {
				Description = "Mutes audio music speakers. \n",
				PreviewImage = nil
			}
		},
		ParticleToggle = {
			DisplayText = "Particles",
			LayoutOrder = 5,
			Type = "boolean",
			DefaultValue = true,
			PreviewWindow = {
				Description = "Displays special effects on all characters.",
				PreviewImage = "rbxassetid://113161785028209",
				HighlightImage = "rbxassetid://131079874806186",
				ImageOverlay = function(instance, flag: boolean?)
					local previewHighlight = instance:WaitForChild("PreviewImage"):WaitForChild("PreviewHighlight")
					previewHighlight.Visible = flag == true
					local previewImage = instance:WaitForChild("PreviewImage")
					previewImage.ImageTransparency = flag == true and 1 or 0
				end
			}
		},
		SprintToggle = {
			DisplayText = "Sprint Toggle",
			LayoutOrder = 6,
			Type = "boolean",
			DefaultValue = false,
			PreviewWindow = {
				Description = "When enabled, sprint behaves as a toggle instead of a hold.",
				PreviewImage = nil
			}
		},
		BuffIndicatorToggle = {
			DisplayText = "Overhead Buff & Debuff Icons",
			LayoutOrder = 7,
			Type = "boolean",
			DefaultValue = false,
			PreviewWindow = {
				Description = "Displays buff and debuff icons above your own character. Other players' icons are unaffected.",
				PreviewImage = nil
			}
		},
		StatusHudToggle = {
			DisplayText = "On-Screen Buff & Debuff Icons",
			LayoutOrder = 8,
			Type = "boolean",
			DefaultValue = true,
			PreviewWindow = {
				Description = "Displays buff and debuff timers on screen, one ring per active effect. Turning this off stops the HUD tracking your character entirely.",
				PreviewImage = nil
			}
		},
		MovingTextureToggle = {
			DisplayText = "Moving Textures",
			LayoutOrder = 7,
			Type = "boolean",
			DefaultValue = true,
			PreviewWindow = {
				Description = "Displays moving texture effects on all characters.",
				PreviewImage = nil
			}
		},
		NameTagToggle = {
			DisplayText = "Toggle Name Tags",
			LayoutOrder = 8,
			Type = "boolean",
			DefaultValue = true,
			PreviewWindow = {
				Description = "Displays the name, title and username above every player.",
				PreviewImage = nil
			}
		},
		HudToggle = {
			DisplayText = "Toggle HUD",
			LayoutOrder = 9,
			Type = "action",
			CloseOnActivate = true,
			OnActivateClient = function()
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local CameraModeController = require(ReplicatedStorage.SharedUtils.CameraModeController)
				CameraModeController.Enter()
			end,
			PreviewWindow = {
				Description = [[
Hides the whole interface for a clean view. Press the return button on screen to bring it back.
<font color="rgb(255,110,110)">Mainly for screenshots.</font>]],
				PreviewImage = nil
			}
		},
		CameraReset = {
			DisplayText = "Reset Camera / UI",
			LayoutOrder = 20,
			Type = "action",
			ValueText = "Reset",
			OnActivateClient = function()
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local UnstuckClient = require(ReplicatedStorage.SharedUtils.UnstuckClient)
				UnstuckClient.resetCamera()
			end,
			PreviewWindow = {
				Description = "Snaps the camera back onto your character and clears a stuck loading screen or hidden HUD after a bad load.",
				PreviewImage = nil
			}
		},
		Unstuck = {
			DisplayText = "Unstuck",
			LayoutOrder = 21,
			Type = "action",
			ValueText = "Nudge",
			CloseOnActivate = true,
			OnActivateClient = function()
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local UnstuckClient = require(ReplicatedStorage.SharedUtils.UnstuckClient)
				UnstuckClient.requestUnstuck()
			end,
			PreviewWindow = {
				Description = [[
Nudges you to the nearest safe spot if you are stuck in the level.
<font color="rgb(255,110,110)">Can be used once a minute.</font>]],
				PreviewImage = nil
			}
		},
		TailEffectsToggle = {
			DisplayText = "Dyle Tail (RP)",
			LayoutOrder = 8,
			Type = "boolean",
			DefaultValue = false,
			HideFromPlayer = true,
			PreviewWindow = {
				Description = "[RP ONLY] When enabled, allow's Twisted Dyle's tail to have animations.",
				PreviewImage = nil
			}
		},
		ColorSettings = {
			ResearchTheme = {
				Header = "Research Capsules",
				DisplayText = "Default Colors",
				LayoutOrder = 1,
				Type = "boolean",
				DefaultValue = true,
				PreviewWindow = {
					Description = "Displays default colors for highlighted research capsules.",
					PreviewImage = nil
				}
			},
			ResearchColor = {
				Dependency = {
					Setting = "ColorSettings.ResearchTheme",
					Value = false
				},
				DisplayText = "Highlight Color",
				LayoutOrder = 2,
				Type = "color",
				DefaultValue = "255,255,255",
				PreviewWindow = {
					Description = "Customizes the color of highlighted research capsules.",
					PreviewImage = "rbxassetid://94917594431539",
					HighlightImage = "rbxassetid://112409490555097"
				}
			},
			HealingTheme = {
				Header = "Healing Items",
				DisplayText = "Default Colors",
				LayoutOrder = 3,
				Type = "boolean",
				DefaultValue = true,
				PreviewWindow = {
					Description = "Displays default colors for highlighted healing items.",
					PreviewImage = nil
				}
			},
			HealingColor = {
				Dependency = {
					Setting = "ColorSettings.HealingTheme",
					Value = false
				},
				DisplayText = "Highlight Color",
				LayoutOrder = 4,
				Type = "color",
				DefaultValue = "255,255,255",
				PreviewWindow = {
					Description = "Customizes the color of highlighted healing items.",
					PreviewImage = "rbxassetid://128720117956356",
					HighlightImage = "rbxassetid://90207978375885"
				}
			},
			ItemTheme = {
				Header = "Items",
				DisplayText = "Default Colors",
				LayoutOrder = 5,
				Type = "boolean",
				DefaultValue = true,
				PreviewWindow = {
					Description = "Displays default colors for highlighted items.",
					PreviewImage = nil
				}
			},
			ItemColor = {
				Dependency = {
					Setting = "ColorSettings.ItemTheme",
					Value = false
				},
				DisplayText = "Highlight Color",
				LayoutOrder = 6,
				Type = "color",
				DefaultValue = "255,255,255",
				PreviewWindow = {
					Description = "Customizes the color of highlighted items.",
					PreviewImage = "rbxassetid://81320499535789",
					HighlightImage = "rbxassetid://98580462154728"
				}
			},
			TapeTheme = {
				Header = "Tapes",
				DisplayText = "Default Colors",
				LayoutOrder = 7,
				Type = "boolean",
				DefaultValue = true,
				PreviewWindow = {
					Description = "Displays default colors for highlighted tapes.",
					PreviewImage = nil
				}
			},
			TapeColor = {
				Dependency = {
					Setting = "ColorSettings.TapeTheme",
					Value = false
				},
				DisplayText = "Highlight Color",
				LayoutOrder = 8,
				Type = "color",
				DefaultValue = "255,255,255",
				PreviewWindow = {
					Description = "Customizes the color of highlighted tapes.",
					PreviewImage = "rbxassetid://129169900623771",
					HighlightImage = "rbxassetid://135189129079704"
				}
			},
			MachineTheme = {
				Header = "Machines",
				DisplayText = "Default Colors",
				LayoutOrder = 9,
				Type = "boolean",
				DefaultValue = true,
				PreviewWindow = {
					Description = "Displays default colors for highlighted machines.",
					PreviewImage = nil
				}
			},
			MachineColor = {
				Dependency = {
					Setting = "ColorSettings.MachineTheme",
					Value = false
				},
				DisplayText = "Highlight Color",
				LayoutOrder = 10,
				Type = "color",
				DefaultValue = "255,255,255",
				PreviewWindow = {
					Description = "Customizes the color of highlighted machines.",
					PreviewImage = "rbxassetid://106588770781922",
					HighlightImage = "rbxassetid://115911383085840"
				}
			},
			TargetTheme = {
				Header = "Targets",
				DisplayText = "Default Colors",
				LayoutOrder = 11,
				Type = "boolean",
				DefaultValue = true,
				PreviewWindow = {
					Description = "Displays default colors for highlighted targets.",
					PreviewImage = nil
				}
			},
			TargetColor = {
				Dependency = {
					Setting = "ColorSettings.TargetTheme",
					Value = false
				},
				DisplayText = "Highlight Color",
				LayoutOrder = 12,
				Type = "color",
				DefaultValue = "255,255,255",
				PreviewWindow = {
					Description = "Customizes the color of highlighted targets.",
					PreviewImage = "rbxassetid://118885127298667",
					HighlightImage = "rbxassetid://92112617777492"
				}
			},
			ThreatTheme = {
				Header = "Twisteds",
				DisplayText = "Default Colors",
				LayoutOrder = 13,
				Type = "boolean",
				DefaultValue = true,
				PreviewWindow = {
					Description = "Displays default colors for highlighted Twisteds.",
					PreviewImage = nil
				}
			},
			ThreatColor = {
				Dependency = {
					Setting = "ColorSettings.ThreatTheme",
					Value = false
				},
				DisplayText = "Highlight Color",
				LayoutOrder = 14,
				Type = "color",
				DefaultValue = "255,255,255",
				PreviewWindow = {
					Description = "Customizes the color of highlighted Twisteds.",
					PreviewImage = "rbxassetid://87054734215209",
					HighlightImage = "rbxassetid://74351224644215"
				}
			},
			AllyTheme = {
				Header = "Toons",
				DisplayText = "Default Colors",
				LayoutOrder = 15,
				Type = "boolean",
				DefaultValue = true,
				PreviewWindow = {
					Description = "Displays default colors for highlighted Toons.",
					PreviewImage = nil
				}
			},
			AllyColor = {
				Dependency = {
					Setting = "ColorSettings.AllyTheme",
					Value = false
				},
				DisplayText = "Highlight Color",
				LayoutOrder = 16,
				Type = "color",
				DefaultValue = "255,255,255",
				PreviewWindow = {
					Description = "Customizes the color of highlighted Toons.",
					PreviewImage = "rbxassetid://125052700386780",
					HighlightImage = "rbxassetid://132135155794230"
				}
			}
		},
		HapticSlider = {
			Header = "Device",
			DisplayText = "Haptic Intensity",
			LayoutOrder = 9,
			Type = "slider",
			DefaultValue = 40,
			SnapTo = 5,
			OnChangeClient = function(_: boolean) end,
			PreviewWindow = {
				Description = "Adjusts the intensity of haptics (0% = no device vibration, 100% = max device vibration).",
				PreviewImage = nil
			}
		},
		Keybinds = {
			DisplayText = "Controls",
			LayoutOrder = 50,
			Type = "control",
			PreviewWindow = {
				Description = "Rebind keyboard and gamepad controls. Changes save instantly.",
				PreviewImage = nil
			}
		}
	}
}