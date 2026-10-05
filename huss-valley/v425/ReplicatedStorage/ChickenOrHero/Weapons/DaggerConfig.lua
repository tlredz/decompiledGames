local ContactCatchConfig = require(script.Parent.Parent.Game.ContactCatchConfig)
return table.freeze({
	Enabled = true,
	DefaultSkin = "BaseDagger",
	GripInwardStuds = 0.25,
	DrawDuration = 0.9166666666666666,
	DrawTransfer = 0.17,
	StabDelay = ContactCatchConfig.Windup,
	StabDuration = 0.8333333333333334,
	StabContactStart = 0.05,
	StabContactEnd = 0.5,
	FadeIn = 0.07,
	FadeOut = 0.14,
	WindupRate = 0.8,
	WindupHoldTail = 0.04,
	DiveDuration = 0.62,
	DiveFadeOut = 0.2,
	AimLimit = 30,
	AimRate = 18
})