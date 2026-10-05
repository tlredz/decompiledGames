local FallenPowerUp = {
	FallEase = 2.2,
	FallTimeNearScale = 0.85,
	FallTimeFarScale = 1.3,
	OriginLiftPerSpread = 0.35,
	PickupRadiusStuds = 7,
	PickupLagSeconds = 0.5,
	PickupRetrySeconds = 1.5,
	DropScatterStuds = 42,
	SpotAttempts = 12,
	SpreadStuds = 24,
	BobStuds = 0.65,
	BobSpeed = 2.6,
	SpinSpeed = 1.4,
	HoverStuds = 2.4,
	AbsorbSeconds = 0.32,
	MagnetPullSeconds = 0.42,
	MagnetPullSpinSpeed = 9,
	SkyLiftResponse = 2.4,
	HighlightFillTransparency = 0.5,
	HighlightPulseFill = 0.34,
	HighlightOutlineTransparency = 0,
	HighlightPulse = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	LightBrightness = 2.4,
	LightRangeStuds = 16,
	TailLengthStuds = 40,
	TailWidthStuds = 11,
	TailTexture = "rbxassetid://134046679013293",
	BeaconTexture = "rbxassetid://134046679013293",
	BeaconBaseStuds = 4,
	BeaconHeightStuds = 272,
	BeaconWidthStuds = 5,
	BurstShockTexture = "rbxassetid://14057043166",
	BurstGlowTexture = "rbxassetid://17061556158",
	LandShakeSeconds = 0.55,
	LandShakeIntensity = 1.4,
	GlobalBumpSeconds = 0.38,
	GlobalBumpIntensity = 0.45,
	LandShakeFalloff = 0.7,
	BurstOriginScale = 2.4,
	TailSpeedRef = 90,
	TailMaxLengthStuds = 110,
	TailTipWidthStuds = 1.8,
	TailSparkRate = 90,
	TailSparkStuds = 1.8,
	PlumeWidthScale = 2.6,
	PlumeTransparency = 0.72,
	WorldScale = 4,
	FlightScale = 3.4,
	LandScaleSeconds = 0.3,
	HeadGlowTexture = "rbxassetid://17061556158",
	HeadPixelRef = 5600,
	HeadPixelMin = 38,
	HeadPixelMax = 210,
	HeadCoreScale = 0.42,
	MarkerTexture = "rbxassetid://14057043166",
	MarkerStartStuds = 58,
	MarkerEndStuds = 14,
	MarkerThickStuds = 0.05,
	MarkerLiftStuds = 0.15,
	MarkerPulseSpeed = 7,
	ShockwaveSeconds = 0.55,
	ShockwaveStuds = 72,
	LandFlashBrightness = 9,
	LandFlashRangeStuds = 46,
	RiserSoundId = "rbxassetid://101937236820642",
	RiserVolume = 0.4,
	ImpactSoundId = "rbxassetid://131273749621142",
	ImpactVolume = 0.7,
	ImpactRangeStuds = 260,
	HeadCloneScale = 0.55,
	HeadCloneHoverStuds = 3.4,
	HeadCloneGapStuds = 1.6,
	HeadCloneSpinSpeed = 1.8,
	HeadCloneBobStuds = 0.3,
	NoticeColor = Color3.fromRGB(255, 214, 89),
	NoticeSeconds = 5,
	Announce = "Look up! Power ups are falling!",
	AttributePrefix = "LvdPower_",
	Kinds = {
		Magnet = {
			Id = "Magnet",
			Display = "Ring Magnet",
			Color = Color3.fromRGB(64, 164, 255),
			Order = 1,
			Icon = "rbxassetid://78796564679501"
		},
		x2Rings = {
			Id = "x2Rings",
			Display = "2x Rings",
			Color = Color3.fromRGB(255, 176, 0),
			Order = 2,
			Icon = "rbxassetid://138829174361176"
		},
		Fusion = {
			Id = "Fusion",
			Display = "Fusion",
			Color = Color3.fromRGB(96, 196, 66),
			Order = 3,
			Icon = "rbxassetid://108854972154157"
		}
	},
	KindList = { "Magnet", "x2Rings", "Fusion" }
}

function FallenPowerUp.KindById(p: string)
	return FallenPowerUp.Kinds[p]
end

function FallenPowerUp.IconFor(p: string)
	local kind = FallenPowerUp.Kinds[p]

	if kind == nil then
		return ""
	end

	return kind.Icon
end

function FallenPowerUp.AttributeFor(p: string)
	return FallenPowerUp.AttributePrefix .. p
end

function FallenPowerUp.ActiveUntil(instance, p: string)
	local attribute = instance:GetAttribute(FallenPowerUp.AttributeFor(p))

	if type(attribute) == "number" then
		return attribute
	end

	return 0
end

function FallenPowerUp.IsActive(p, p2: string, p3: number)
	return p3 < FallenPowerUp.ActiveUntil(p, p2)
end

function FallenPowerUp.ModelFor(childName: string)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local powerUps = ReplicatedStorage.Assets.Models:FindFirstChild("PowerUps")
	local model

	if powerUps ~= nil then
		model = powerUps:FindFirstChild(childName)
	end

	if model == nil or not model:IsA("Model") then
		return nil
	end

	return model
end

return FallenPowerUp