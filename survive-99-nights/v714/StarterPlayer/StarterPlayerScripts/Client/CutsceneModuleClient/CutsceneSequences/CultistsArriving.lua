local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
return {
	{
		Action = "LoadSet",
		SetName = "CultistsArriving"
	},
	{
		Action = "MakeNote",
		Message = "A mysterious group makes its way towards your Campfire"
	},
	{
		Action = "Pause",
		Duration = 2.5
	},
	{
		Action = "Function",
		Callback = function(p)
			local v = {}

			for _, child in pairs(p.Set.CultistsArriving:GetChildren()) do
				if not (string.sub(child.Name, 1, 5) == "Culti" and child:FindFirstChild("HumanoidRootPart")) then
					continue
				end

				table.insert(v, child)
				child.NPC:MoveTo(child.HumanoidRootPart.Position + createVector(120, 0, 0))
				child.NPC:LoadAnimation(child.Animations.Run):Play()
				child.NPC:LoadAnimation(child.Animations.DefaultToolHold):Play()

				if not p.WeaponModel then
					continue
				end

				local clone = p.WeaponModel:Clone()
				clone.Parent = child
				Client.Utility.AttachTool(child, clone)
			end
		end
	},
	{
		Action = "FadeOut",
		Duration = 2
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			34.9645309,
			-118.768539,
			-16.3686543,
			0.187220901,
			0.043812789,
			0.981340289,
			-9.31322575e-10,
			0.9990049,
			-0.0446014367,
			-0.982317865,
			0.00835032016,
			0.187034592
		)
	},
	{
		Action = "FadeIn",
		Duration = 1.5
	},
	{
		Action = "Pause",
		Duration = 1.6
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