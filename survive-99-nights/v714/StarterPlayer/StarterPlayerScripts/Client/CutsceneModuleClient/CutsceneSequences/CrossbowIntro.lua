return {
	{
		Action = "LoadSet",
		SetName = "CrossbowIntro"
	},
	{
		Action = "FadeOut",
		Duration = 2
	},
	{
		Action = "Function",
		Callback = function(p)
			local crossbowCultist = p.Set.CrossbowIntro.CrossbowCultist
			crossbowCultist.Humanoid:LoadAnimation(crossbowCultist.Animations.Cutscene):Play()
		end
	},
	{
		Action = "MakeNote",
		Message = "A mysterious group makes its way towards your Campfire",
		Timer = 3
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			58.06427,
			-96.1291351,
			12.1944275,
			0.837741971,
			0.0662928522,
			0.542022467,
			3.15182369e-8,
			0.992603481,
			-0.121401861,
			-0.546061397,
			0.101703458,
			0.831545591
		)
	},
	{
		Action = "FadeIn",
		Duration = 1.5
	},
	{
		Action = "Pause",
		Duration = 0.73
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			54.4584122,
			-93.7510757,
			2.02233887,
			-0.974399507,
			0.173385531,
			-0.143101081,
			0,
			0.636536539,
			0.771246552,
			0.224812061,
			0.751502216,
			-0.620240927
		)
	},
	{
		Action = "Pause",
		Duration = 2.73
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			65.9442215,
			-93.5599823,
			4.98838806,
			0.0056392313,
			-0.053271655,
			0.998561502,
			3.04647649e-8,
			0.998580039,
			0.0532726385,
			-0.999981463,
			-0.000300386338,
			0.00563122472
		)
	},
	{
		Action = "Pause",
		Duration = 2.59
	},
	{
		Action = "FadeOut",
		Duration = 1.5
	},
	{
		Action = "ReturnCamera"
	},
	{
		Action = "FadeIn",
		Duration = 2
	}
}