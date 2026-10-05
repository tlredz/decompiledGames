local Players = game:GetService("Players")
local parent = script.Parent.Parent
local components = parent.Components
local modules = parent.Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)
local Signal = require(Packages.Directory.Signal)
local StudioTheme = require(components.StudioTheme)
local PacketFrames = require(components.PacketFrames)
local TopbarButtonsGroup = require(components.TopbarButtonsGroup)
local TopbarButton = require(components.TopbarButton)
local CoreGui = Packages.IsPlugin and game:GetService("CoreGui") or Players.LocalPlayer.PlayerGui
local extended = Roact.Component:extend("PacketProfiler")

function extended:init()
	self:setState({
		MaxFrameSize = 1000
	})
	self.Cleanup = {}
	local binding, setPacketProfilerPaused = Roact.createBinding(false)
	self.PacketProfilerPaused = binding
	self.SetPacketProfilerPaused = setPacketProfilerPaused
	self.OnPacketProfilerPaused = Signal.new()
	table.insert(self.Cleanup, self.OnPacketProfilerPaused:Connect(function(p)
		self.SetPacketProfilerPaused(p)
	end))

	function self.Pause(p)
		self.OnPacketProfilerPaused:Fire(p)
	end
end

function extended.didMount(data)
	table.insert(data.Cleanup, data.props.Signals.ProfilerPaused:Connect(function(p)
		data.Pause(p)
	end))
end

function extended.willUnmount(p)
	for _, connection in p.Cleanup do
		connection:Disconnect()
	end
end

function extended.render(props)
	local v = Packages.IsPlugin and "Left" or "Right"
	local layoutOrder = Packages.IsPlugin and -1 or 1
	return Roact.createElement(Roact.Portal, {
		target = CoreGui
	}, {
		PacketProfiler = Roact.createElement("ScreenGui", {
			DisplayOrder = 10,
			IgnoreGuiInset = true,
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		}, {
			Background = StudioTheme(function(object)
				return Roact.createElement("Frame", {
					BackgroundColor3 = object:GetColor("Light"),
					BorderSizePixel = 1,
					BorderColor3 = object:GetColor("Border"),
					Size = UDim2.new(1, 0, 0, 50),
					Position = UDim2.fromOffset(0, 10)
				}, {
					PacketFrames = Roact.createElement(PacketFrames, {
						Enabled = props.props.Enabled,
						MaxFrameSize = props.state.MaxFrameSize,
						OnPacketProfilerPaused = props.OnPacketProfilerPaused,
						OnPacketProfilerEnabled = props.props.OnEnabled,
						Signals = props.props.Signals
					})
				})
			end),
			Topbar = StudioTheme(function(theme)
				return Roact.createElement("Frame", {
					BackgroundColor3 = theme:GetColor("Item"),
					BorderSizePixel = 0,
					ZIndex = 2,
					Size = UDim2.new(1, 0, 0, 10)
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = v == "Left" and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 5)
					}),
					Title = Roact.createElement(TopbarButton, {
						Text = "PacketProfiler",
						Theme = theme,
						LayoutOrder = layoutOrder
					}),
					MaxKBScale = Roact.createElement(TopbarButtonsGroup, {
						Theme = theme,
						Text = "Max KB scale",
						Options = {
							{
								Name = "10 B",
								Callback = function()
									props:setState({
										MaxFrameSize = 10
									})
								end
							},
							{
								Name = "100 B",
								Callback = function()
									props:setState({
										MaxFrameSize = 100
									})
								end
							},
							{
								Name = "1 KB",
								Callback = function()
									props:setState({
										MaxFrameSize = 1000
									})
								end
							},
							{
								Name = "10 KB",
								Callback = function()
									props:setState({
										MaxFrameSize = 10000
									})
								end
							},
							{
								Name = "50 KB",
								Callback = function()
									props:setState({
										MaxFrameSize = 50000
									})
								end
							},
							{
								Name = "100 KB",
								Callback = function()
									props:setState({
										MaxFrameSize = 100000
									})
								end
							}
						},
						LayoutOrder = layoutOrder * 2
					}),
					PausedLabel = Roact.createElement(TopbarButton, {
						Text = props.PacketProfilerPaused:map(function(p)
							if p then
								return "[Paused]"
							end

							return "[Running]"
						end),
						Theme = theme,
						OnClick = function()
							props.props.Signals.ProfilerPaused:Fire(not props.PacketProfilerPaused:getValue())
						end,
						LayoutIndex = layoutOrder * 3
					})
				})
			end)
		})
	})
end

return extended