local v = {
	EmergeTime = 0.35,
	RiseHeight = 1.5,
	ToHeadTime = 0.45,
	HeadHeight = 4,
	SpinTime = 0.9,
	SpinSpeed = 540,
	FlyInTime = 0.35,
	TokenFolder = "Assets",
	TokenTemplate = "GourdyCollectiblePiece",
	TokenSize = 1.4,
	TokenColor = Color3.fromRGB(255, 137, 2),
	SparkleTexture = "rbxassetid://130947809595971",
	FlowSound = "rbxassetid://139066678383964",
	BurstCount = 24,
	GlowBrightness = 1.5,
	GlowRange = 8,
	SparkleRate = 14,
	SpinGlowBrightness = 4,
	SpinGlowRange = 14,
	SpinSparkleRate = 45,
	CaptionOffset = -1.3,
	CaptionHoldTime = 4,
	SnapWindupTime = 0.08,
	SnapHopTime = 0.16,
	SnapHopHeight = 2.2,
	SnapHopScale = 1.3,
	SnapDiveTime = 0.3,
	SnapArriveScale = 0.2,
	SnapSpinSpeed = 1080
}
local clone = table.clone(v)
clone.TokenTemplate = "HalloweenDecoration"
clone.MeshId = "rbxassetid://79065644969249"
clone.TextureId = "rbxassetid://140199802337207"
clone.Sound = "rbxassetid://82647959566760"
clone.SoundVolume = 0.2
return {
	HolidayKey = "Halloween26",
	ProgressKey = "CollectionProgress",
	CollectablesKey = "CollectableProgress",
	KeepsakesKey = "Keepsakes",
	MaxCollectionProgress = 143,
	ProgressKeepsakes = {
		{
			Id = "EclipseTrinket",
			Object = "Object40",
			Model = "EclipseEmb"
		},
		{
			Id = "RibeccaTrinket",
			Object = "Object80",
			Model = "RibeccaFieldstone"
		},
		{
			Id = "SoulvesterStand",
			Object = "Object120",
			Model = "SoulvesterArmourStand"
		}
	},
	Collectables = {
		{
			Name = "GourdyLockbox",
			Pieces = {
				"Piece1",
				"Piece2",
				"Piece3",
				"Piece4",
				"Piece5",
				"Piece6",
				"Piece7"
			},
			QuestAwarded = true,
			AllowDuringFTUE = true,
			UnlockedBy = {
				StateKey = "GourdyQuest",
				Field = "FinalRevealSeen"
			},
			Stages = {
				"Stage1",
				"Stage2",
				"Stage3",
				"Stage4",
				"Stage5",
				"Stage6",
				"Stage7"
			}
		}
	},
	FloorPieceCounts = {
		{
			fromFloor = 1,
			count = 1
		},
		{
			fromFloor = 6,
			count = 2
		},
		{
			fromFloor = 11,
			count = 3
		},
		{
			fromFloor = 16,
			count = 4
		}
	},
	PieceModelName = "CollectablePiece",
	PieceCollectRadius = 7,
	PieceMeshSize = 2.5,
	PiecePresentation = clone,
	PieceIdle = {
		SpinSpeed = 90,
		BobHeight = 0.35,
		BobPeriod = 2,
		SparkleRate = 8,
		LightRange = 10,
		LightBrightness = 1.2
	},
	PieceHeightOffset = 3,
	PieceTag = "HalloweenCollectablePiece",
	SpotPieceModelName = "SpecialCollectionPiece",
	SpotTag = "Halloween26CollectionSpot",
	PieceIdAttribute = "PieceId",
	SpotPieceTag = "HalloweenSpecialCollectionPiece",
	PromptActionText = "Collect",
	PromptObjectText = "Halloween Decor",
	SpotPromptObjectText = "Gourdy's Lockbox Piece",
	PickupMessage = "Halloween Decor found! It's been added to the Lobby.",
	SpotPickupMessage = "Gourdy's Lockbox piece found! (%d out of %d)",
	PickupCountCaption = "Halloween Decor %d/%d",
	DecorFolder = "HalloweenDecorations",
	CollectablesFolder = "Collectables",
	ProgressFolder = "Progress",
	PercentageAttribute = "Percentage",
	FoundAttribute = "Found",
	CompleteAttribute = "Complete",
	ProgressMaxedAttribute = "HalloweenCollectionMaxed",
	FirstPieceCutscene = {
		PieceId = "Piece1",
		CameraFolder = "Cutscene",
		DandyCamName = "DandyCam",
		LockboxCamName = "LockboxCam",
		Lines = {
			{
				text = "Ever since the humans have been gone our holidays are a lot less festive...",
				duration = 3
			},
			{
				text = "Help me find all these pieces and we can finish decorating!",
				duration = 3
			},
			{
				text = "Some of them are here in the Lobby and others are... down on the lower Floors...",
				duration = 3
			}
		},
		DialogShopName = "DandyShop",
		Token = v,
		ToLockboxTime = 1.25,
		SettleTime = 0.4,
		FlyDistance = 6,
		FlyTime = 1.1,
		RevealTime = 0.9,
		PreviewTransparency = 0.7,
		PreviewTime = 0.9,
		HoldTime = 0.8,
		ToDandyTime = 1.1
	},
	GhostFarTransparency = 1,
	GhostNearTransparency = 1,
	GhostRevealDistance = 25,
	GhostFadeTime = 0.35,
	GhostPollInterval = 0.25,
	GourdyQuest = {
		Collectable = "GourdyLockbox",
		StateKey = "GourdyQuest",
		PropTag = "GourdyQuestProp",
		StepAttribute = "GourdyQuestStep",
		ReadyAttribute = "GourdyQuestReady",
		InteractRange = 10,
		CompletionMessage = "You've collected %d out of %d Gourdy Lockbox Pieces.",
		StepMilestones = {
			{
				Steps = { "LobbyLantern1", "LobbyLantern2", "LobbyLantern3" },
				Message = "You've lit all %d Lobby Jack-o'-Lanterns! %d more are waiting on the Halloween floors."
			}
		},
		Parts = {
			{
				Id = "GourdyPlush",
				Kind = "Plush",
				Pieces = {
					{
						Id = "Piece1",
						Steps = { "RPGourdyPlush" }
					}
				}
			},
			{
				Id = "JackOLanterns",
				Kind = "Lantern",
				Pieces = {
					{
						Id = "Piece2",
						Steps = {
							"LobbyLantern1",
							"LobbyLantern2",
							"LobbyLantern3",
							"Map1Lantern1",
							"Map1Lantern2",
							"Map2Lantern1",
							"Map2Lantern2"
						}
					}
				}
			},
			{
				Id = "QoMPosters",
				Kind = "Poster",
				Pieces = {
					{
						Id = "Piece3",
						Steps = { "LobbyPoster1", "LobbyPoster2" }
					}
				}
			},
			{
				Id = "LoreTV",
				Kind = "LoreTV",
				Pieces = {
					{
						Id = "Piece4",
						Steps = { "Map1LoreTV" }
					}
				}
			},
			{
				Id = "Typewriter",
				Kind = "Typewriter",
				Pieces = {
					{
						Id = "Piece5",
						Steps = { "Map1Typewriter" }
					}
				}
			},
			{
				Id = "SoulvesterPhotograph",
				Kind = "PhotoHalf",
				RequiresAnotherPart = true,
				Pieces = {
					{
						Id = "Piece6",
						Steps = { "Map1PhotoHalf" }
					},
					{
						Id = "Piece7",
						Steps = { "Map2PhotoHalf" }
					}
				}
			}
		},
		Kinds = {
			Plush = {
				ActionText = "Interact",
				ObjectText = "Gourdy Plush",
				MonsterName = "GourdyMonster",
				HappyVariantName = "HappyGourdyPlush",
				SwapTime = 0.4
			},
			Lantern = {
				ActionText = "Light",
				ObjectText = "Jack-o'-Lantern",
				GlowName = "Glow",
				LitColor = Color3.fromRGB(255, 137, 2),
				UnlitColor = Color3.fromRGB(0, 0, 0),
				FadeTime = 0.5
			},
			Poster = {
				ActionText = "Straighten",
				ObjectText = "Poster",
				InteractRange = 16,
				GlowDecalName = "Glow",
				CrookedAngle = 12,
				StraightenTime = 0.6,
				GlowTime = 0.5
			},
			LoreTV = {
				ActionText = "Watch",
				ObjectText = "TV"
			},
			Typewriter = {
				ActionText = "Use",
				ObjectText = "Typewriter",
				CodeLength = 6,
				CodeGroupSize = 2
			},
			PhotoHalf = {
				ActionText = "Collect",
				ObjectText = "Torn Photograph",
				HideTime = 0.4
			}
		},
		Presentation = v,
		LobbyBeatTutorialSettleTime = 3,
		LobbyBeatHoldTutorialSteps = {
			6,
			7,
			8,
			9
		},
		FinalReveal = {
			ServerModelName = "GourdyLockboxFinal",
			LidName = "Lid",
			LidOpenName = "LidOpen",
			ToShrineTime = 1.25,
			SettleTime = 0.4,
			AppearTime = 0.6,
			OpenTime = 1.2,
			HoldTime = 2.5
		}
	}
}