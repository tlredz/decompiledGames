local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local faye = require(ReplicatedStorage.Packages.faye)
local color = Color3.fromRGB(215, 130, 130)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.3),
	NumberSequenceKeypoint.new(0.7, 0.6),
	NumberSequenceKeypoint.new(1, 0.85)
})
local info = faye.Info(0.2, Enum.EasingStyle.Back)
return function(object)
	local flag = false

	local function disband()
		if flag then
			return
		end

		flag = true

		if PopUpCreator.new({
			Type = "Question",
			Content = "Are you sure you want to disband the faction? Every member is removed and this cannot be undone."
		}).Result:Wait() == "Yes" then
			local v = PopUpCreator.new({
				Type = "LoadingFull"
			})
			pcall(SignalFunction.ToServer, "Disband Faction")
			v:Destroy()
		end

		flag = false
	end

	return object:Create("Frame")({
		Name = "DisbandHolder",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.075, 0),
		Size = object:Animation(UDim2.fromScale(0.22, 0.04), info, {
			From = UDim2.fromScale(0, 0.04)
		}),
		BackgroundTransparency = 1,
		GradientButton(object, {
			Text = "Disband",
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.SourceSansBold,
			BgColor = color,
			GradientTransparency = numberSequence,
			CornerRadius = UDim.new(1),
			Properties = {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5)
			},
			Clicked = disband
		})
	})
end