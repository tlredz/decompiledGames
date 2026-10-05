return {
	ManualPanels = {
		MainGUIHandler = {
			HouseControlPanel = {},
			MainAirVehicleMenu = {},
			Jurassic2026ConfirmationPanel = {},
			Jurassic2026ConfirmationPanelWeek2 = {}
		},
		Snowboard = {
			SnowboardMobileUI = {}
		},
		DeckGun = {
			DeckGunUI = {}
		},
		MobileControlUI = {
			MobileControlUI = {}
		},
		IntroGui = {
			Intro = {}
		},
		PrivateServerControlsGUI = {
			PrivateServerControlsPanel = {}
		},
		Jetts = {
			JettsOrderMenu = {}
		},
		MainGUIAlwaysVisible = {
			AdIntegrationsLabel = {}
		}
	},
	Panels = {
		MainGUIHandler = {
			AdStore = {},
			ChangableColorPanel = {},
			CountrySelectorPanel = {},
			ExtendProductUnlock = {},
			HousePartyConfirm = {},
			HousePropCameraOverlay = {},
			HouseProps = {},
			VehiclePropCameraOverlay = {},
			VehicleProps = {},
			ItemCardCountableProduct = {},
			ItemCardPlus = {},
			ItemCardProduct = {},
			ModalBabyAsk = {},
			ModalBabyAskApartment = {},
			ModalBabyAskMansion = {},
			ModalDisasterControls = {},
			ModalFireAsk = {},
			ModalFireAskApartment = {},
			ModalFireAskFirePass = {},
			ModalFireAskFirePassApartment = {},
			ModalFireAskFirePassMansion = {},
			ModalFireAskMansion = {},
			ModalVehicleTextEdit = {},
			NewUserUpsell = {},
			NewUserUpsellControl = {},
			NoMotorVehicleControl = {},
			PartyEndConfirm = {},
			PartyInvited = {},
			YoungRoddoInvite = {},
			PartySelect = {},
			PartyStart = {},
			PrivateServerProps = {},
			PropCameraOverlay = {},
			RobuxGamepassUnlocked = {},
			BalloonPopInfo = {},
			SkyePerformanceNotification = {},
			Summer2026ConfirmationPanel = {},
			VehicleControls = {},
			LandmarkTransferConfirmation = {}
		},
		HelicopterControl = {
			HelicopterControl = {}
		},
		HoistControls = {
			HoistControls = {}
		},
		HotAirBalloonControl = {
			HotAirBalloonControl = {}
		}
	},
	Dependencies = {
		MainGUIHandler = {
			PrivateServerProps = {
				{
					context = "MainGUIHandler",
					name = "PropCameraOverlay"
				}
			},
			VehicleProps = {
				{
					context = "MainGUIHandler",
					name = "VehiclePropCameraOverlay"
				}
			},
			GiftSelectRecipient = {
				{
					context = "MainGUIHandler",
					name = "GiftSent"
				}
			}
		}
	}
}