local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("global")
local import4 = _G.import("configuration")
local import5 = _G.import("viewImports")
local basic = import5:get("basic")
local react = import5:get("react")
local TweenService = game:GetService("TweenService")
local model = import.model(basic.Element, basic.Stroke)

function model.init()
	return {
		Thickness = 2,
		BorderSizePixel = 0,
		StrokeColor = Color3.fromRGB(34, 65, 24),
		BackgroundColor3 = Color3.fromRGB(55, 106, 40),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, 0, 0.25, 0),
		AnchorPoint = Vector2.new(0.5, 1)
	}, {
		FillBar = import.make(import.wrap(basic.Corner, basic.Gradient), {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Position = UDim2.new(0, -5, 0, 0),
			Size = UDim2.new(0.1, 5, 1, 0),
			CornerRadius = UDim.new(0.2, 0),
			GradientRotation = 90,
			GradientColor = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0.184314, 1, 0)),
				ColorSequenceKeypoint.new(0.1, Color3.new(0.0470588, 0.713725, 0.14902)),
				ColorSequenceKeypoint.new(0.9, Color3.new(0.0470588, 0.713725, 0.14902)),
				ColorSequenceKeypoint.new(1, Color3.new(0.184314, 1, 0))
			})
		})
	}
end

function model:update(p2)
	TweenService:Create(self.FillBar.Instance, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Size = UDim2.new(1 - p2, 0, 1, 0)
	}):Play()
end

local model2 = import.model(basic.TextLabel, basic.Gradient)

function model2.init(p)
	local timeRemaining = p.TimeRemaining
	return {
		Position = UDim2.new(0, 0, 0.15, 0),
		Size = UDim2.new(1, 0, 0.45, 0),
		Text = "New Rewards In: " .. timeRemaining .. "s",
		GradientRotation = 90,
		StrokeWidth = 2
	}
end

local model3 = import.model(basic.EmptyElement, react.Reactive)

function model3.init()
	return {
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, 0, 0.1, 0),
		AnchorPoint = Vector2.new(0.5, 1)
	}, {
		ProgressBar = import.make(model),
		TimeUntilRoll = import.make(model2, {
			TimeRemaining = import4.AFK.DurationForReward
		})
	}
end

function model3:spawn()
	local playerSave = import3.get("playerSave", game.Players.LocalPlayer)
	local now = os.time()
	self.ProgressBar:update(0.5)

	if workspace:GetAttribute("TEST") then
		return
	end

	self._updateConnection = import2.schedule(1, function()
		for _, v in playerSave.AfkRewards:pairs() do
			local timestamp = v.Timestamp

			if timestamp then
				local timestamp2 = v.Timestamp
				timestamp = now < timestamp2
			end

			if timestamp then
				now = v.Timestamp
			end
		end

		local timeRemaining = math.max(0, now + import4.AFK.DurationForReward - os.time())
		local v2 = timeRemaining / import4.AFK.DurationForReward
		self.ProgressBar:update(v2)
		self:ClearAllChildren("TextLabel")
		import.apply(self, nil, {
			TimeUntilRoll = import.make(model2, {
				TimeRemaining = timeRemaining
			})
		})
	end)
end

function model3:despawn()
	if self._updateConnection then
		self._updateConnection:Disconnect()
	end
end

return {
	BarPanel = model3
}