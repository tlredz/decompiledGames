local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("sync")
local import4 = _G.import("viewImports")
local basic = import4:get("basic")
local event = import4:get("event")
local modesData = require(script.Parent.modesData)
local rankedCloseButton = require(script.Parent.rankedCloseButton)
local closeButton = rankedCloseButton.CloseButton
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function formatElapsed(value)
	local v = math.max(0, (math.floor(value or 0)))
	return string.format("%d:%02d", math.floor(v / 60), v % 60)
end

local function getModeInfo(playerCount, mode)
	local v = mode and modesData.get(mode)

	if v then
		return v
	end

	for _, mode2 in pairs(modesData.Modes) do
		if mode2.PlayerCount == playerCount then
			return mode2
		end
	end

	return modesData.get()
end

local model = import.model(basic.EmptyElement)

function model.init(p)
	return {
		Size = UDim2.new(0.13, 0, 0.68, 0),
		LayoutOrder = p.LayoutOrder or 1,
		BackgroundTransparency = 1
	}, {
		Icon = import.make(basic.ImageLabel, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			AspectRatio = 1,
			Image = "rbxassetid://119316819438614",
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ScaleType = Enum.ScaleType.Fit
		})
	}
end

local model2 = import.model(basic.Ui, basic.ConstrainedElement, event.Reactive)

function model2.init(options)
	local v = options or {}
	local modeInfo = getModeInfo(v.PlayerCount, v.Mode)
	return {
		ContainerAnchorPoint = Vector2.new(0.5, 0),
		ContainerPosition = UDim2.new(0.5, 0, 0.05, 0),
		ContainerSize = UDim2.new(1, 0, 1, 0),
		AspectRatio = 6,
		Scale = 0.4,
		MaxSize = 400,
		Visible = false,
		RemoteEventNames = { "queueJoined", "queueLeft", "matchFound" },
		OnRemote = function(object, p, p2)
			if not p2 then
				return
			end

			if p == "queueJoined" then
				object:joinQueue(p2)
			elseif p == "queueLeft" then
				object:leaveQueue()
			elseif p == "matchFound" then
				object:matchFound()
			end
		end
	}, {
		QueueBar = import.make(basic.EmptyElement, {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0)
		}, {
			Bar = import.make(import.wrap(basic.Element, basic.Corner), {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.38,
				BorderSizePixel = 0,
				CornerRadius = UDim.new(0.14, 0)
			}, {
				Row = import.make(basic.EmptyList, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0.97, 0, 0.82, 0),
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0.015, 0)
				}, {
					SearchIcon = import.make(model),
					TextStack = import.make(basic.EmptyList, {
						Size = UDim2.new(0.45, 0, 0.8, 0),
						LayoutOrder = 2,
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0.02, 0)
					}, {
						ModeLabel = import.make(basic.TextLabel, {
							Size = UDim2.new(1, 0, 0.55, 0),
							Text = modeInfo.ModeText,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextXAlignment = Enum.TextXAlignment.Left,
							StrokeWidth = 2,
							LayoutOrder = 1
						}),
						SearchingLabel = import.make(basic.TextLabel, {
							Size = UDim2.new(1, 0, 0.4, 0),
							Text = "Searching for players...",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextXAlignment = Enum.TextXAlignment.Left,
							StrokeWidth = 1,
							LayoutOrder = 2
						})
					}),
					RightControls = import.make(basic.EmptyList, {
						Size = UDim2.new(0.35, 0, 0.8, 0),
						LayoutOrder = 3,
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0.055, 0)
					}, {
						TimerLabel = import.make(basic.TextLabel, {
							Size = UDim2.new(0.45, 0, 0.65, 0),
							LayoutOrder = 1,
							Text = "0:00",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							StrokeWidth = 2
						}),
						CloseButton = import.make(closeButton, {
							Scale = 0.3,
							LayoutOrder = 2,
							AspectRatio = 1.45,
							CornerRadius = UDim.new(0.12, 0),
							XSize = UDim2.new(0.7, 0, 0.7, 0),
							Visible = false,
							OnClose = function(p)
								task.wait(0.095)
								import3.request("leaveQueue", function()
									local ui = p.Ui

									if ui and ui.MatchmakingContainer then
										ui.MatchmakingContainer:leaveQueue(true)
									end
								end, function(p2)
									import2.fire("signal", p2)
								end, function(p2, p3)
									if p2 then
										return
									end

									import2.fire("signal", p3)
								end)()
							end
						})
					})
				})
			})
		})
	}
end

function model2:open()
	self.Visible = true
	local container = self.Container

	if container then
		local position = container.Position
		container.Position = UDim2.new(position.X.Scale, position.X.Offset, 0, -container.Instance.AbsoluteSize.Y)
		container:tween(TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = position
		})
	end
end

function model2:close()
	self.Parent:Destroy()
end

function model2:disconnect()
	if self._updateConnection then
		self._updateConnection:Disconnect()
	end

	self.SearchingAnimationActive = false
	self.QueueBar.Bar.Row.TextStack.SearchingLabel.Text = "Searching for players..."
	self.QueueBar.Bar.Row.RightControls.TimerLabel.Text = "0:00"
end

function model2:leaveQueue(p)
	if p then
		import2.fire("signal", "Matchmaking Queue Canceled")
	end

	self:disconnect()
	self:close()
end

function model2:joinQueue(p)
	local lastTime = os.clock()
	local playerCount = p.PlayerCount or self.PlayerCount
	local modeInfo = getModeInfo(playerCount, p.Mode)
	self:disconnect()
	self.QueueBar.Bar.Row.RightControls.CloseButton.Visible = true
	self.QueueBar.Bar.Row.TextStack.ModeLabel.Text = modeInfo.ModeText
	self.SearchingAnimationActive = true
	task.spawn(function()
		local searchingLabel = self.QueueBar.Bar.Row.TextStack.SearchingLabel
		local v = 0

		while self.SearchingAnimationActive and searchingLabel.Parent do
			v = v % 3 + 1
			searchingLabel.Text = "Searching for players" .. string.rep(".", v)
			task.wait(0.45)
		end
	end)
	self._updateConnection = RunService.Heartbeat:Connect(function()
		local timerLabel = self.QueueBar.Bar.Row.RightControls.TimerLabel
		timerLabel.Text = formatElapsed(os.clock() - lastTime)
	end)
end

function model2:matchFound()
	if self._updateConnection then
		self._updateConnection:Disconnect()
	end

	self.SearchingAnimationActive = false
	self.QueueBar.Bar.Row.TextStack.SearchingLabel.Text = "Match Found"
	self.QueueBar.Bar.Row.TextStack.SearchingLabel.TextColor3 = Color3.fromRGB(66, 231, 0)
end

function model2:despawn()
	self:disconnect()
end

local model3 = import.model("ScreenGui", basic.Ui)

function model3.init(options)
	local v = options or {}
	return {
		Name = "MatchmakingQueue",
		DisplayOrder = v.DisplayOrder or 8,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		PlayerCount = v.PlayerCount,
		NoButton = v.NoButton,
		Mode = v.Mode
	}, {
		MatchmakingContainer = import.make(model2, v)
	}
end

function model3.spawn(data)
	local playerCount = data.PlayerCount

	if data.NoButton then
		data.MatchmakingContainer.QueueBar.Bar.Row.RightControls.CloseButton:Destroy()
	end

	local modeInfo = getModeInfo(playerCount, data.Mode)
	data.MatchmakingContainer.QueueBar.Bar.Row.TextStack.ModeLabel.Text = modeInfo.ModeText
end

return {
	MatchmakingQueue = model3
}