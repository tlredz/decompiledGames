local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent
local components = parent.Components
local modules = parent.Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)
local Signal = require(Packages.Directory.Signal)
local PacketSizeCounter = require(Packages.Directory.PacketSizeCounter)
local StudioTheme = require(components.StudioTheme)
local PacketCircleArcs = require(components.PacketCircleArcs)
local PacketChartItems = require(components.PacketChartItems)
local ChartResize = require(components.ChartResize)
local TableToSyntaxString = require(modules.TableToSyntaxString)
local visible = not RunService:IsRunning()
local v2 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function GetRemoteColor()
	v2 = (v2 + 0.6180339887498949) % 1
	return (Color3.fromHSV(v2, 0.5, 0.95))
end

local remoteNameprofiler = ReplicatedStorage:FindFirstChild("RemoteName.profiler", true)
local module = nil

if remoteNameprofiler == nil then
	local descendantAddedConnection = nil
	descendantAddedConnection = ReplicatedStorage.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "RemoteName.profiler" then
			assert(typeof(require(descendant)) == "function", "Return of RemoteName.profiler must be a function")
			local module2 = require(descendant)
			module = module2
			descendantAddedConnection:Disconnect()
		end
	end)
else
	assert(typeof(require(remoteNameprofiler)) == "function", "Return of RemoteName.profiler must be a function")
	module = require(remoteNameprofiler)
end

local function GetRemoteData(remote, ...)
	local selected = module and module(remote, ...)

	if selected then
		return selected
	end

	local name = remote.Name
	return (`{remote.Parent}.{name}`)
end

local extended = Roact.Component:extend("PacketChart")

function extended:init()
	self.ArcsUpdated = Signal.new()
	self.OnArcClicked = Signal.new()
	local binding, setChartEnabled = Roact.createBinding(false)
	self.ChartEnabled = binding
	self.SetChartEnabled = setChartEnabled
	local binding2, setScrollBarChanged = Roact.createBinding({
		Size = 0,
		Visible = false
	})
	self.ScrollBarChanged = binding2
	self.SetScrollBarChanged = setScrollBarChanged
	self.OpenRemoteData = Signal.new()
	self:setState({
		Arcs = {}
	})
end

function extended.didMount(object)
	object.props.Signals.ProfilerFrameSelected:Connect(function(p)
		local v3 = {}

		for _, packet in p.Packets do
			local remoteData = GetRemoteData(packet.Remote, unpack(packet.RawData))
			local size = packet.Size

			if typeof(remoteData) == "string" then
				if not v3[remoteData] then
					v3[remoteData] = {
						Size = 0,
						Data = {}
					}
				end

				v3[remoteData].Size += size
				local v6 = #v3[remoteData].Data + 1
				v3[remoteData].Data[v6] = {
					Name = `Remote call {v6}:`,
					Packet = `{packet.Data and TableToSyntaxString(packet.Data) or "[None]"}`
				}
			else
				local v5 = {}
				local total = 0

				for k, v6 in remoteData do
					local v7 = PacketSizeCounter.GetPacketSize({
						RunContext = packet.RunContext,
						RemoteType = "RemoteEvent",
						PacketData = v6.Arguments
					}) - PacketSizeCounter.BaseRemoteOverhead

					if packet.RunContext == "Client" then
						v7 -= PacketSizeCounter.ClientToServerOverhead
					end

					v5[k] = v7
					total += v7
				end

				for k, v6 in remoteData do
					local name = v6.Name

					if not v3[name] then
						v3[name] = {
							Size = 0,
							Data = {}
						}
					end

					v3[name].Size += v5[k] / total * size
					local v8 = #v3[name].Data + 1
					v3[name].Data[v8] = {
						Name = v6.Name,
						Packet = TableToSyntaxString(v6.Arguments, true)
					}
				end
			end
		end

		local totalSize = p.TotalSize
		local arcs = {}

		for k, v5 in v3 do
			local v6 = v5.Size / totalSize
			local color = GetRemoteColor() -- equivalent call inferred; original call site unknown
			table.insert(arcs, {
				Name = k,
				DataSize = v5.Size,
				Percent = v6 * 100,
				Color = color,
				RemoteData = v5.Data
			})
		end

		table.sort(arcs, function(a, b)
			return a.Percent > b.Percent
		end)
		object:setState({
			Arcs = arcs
		})
	end)
	object.props.Signals.ProfilerPaused:Connect(function(p)
		object.SetChartEnabled(p)
	end)
	object.props.OnEnabled:Connect(function(p)
		object.SetChartEnabled(p)
	end)
end

function extended.render(props)
	return Roact.createElement(Packages.IsPlugin and require(components.StudioWidget) or "ScreenGui", ({
		Plugin = {
			WidgetId = "PacketChart",
			WidgetTitle = "Packet Chart",
			InitialDockState = Enum.InitialDockState.Float,
			Enabled = props.props.Enabled,
			OnEnabled = props.props.OnEnabled,
			DefaultSize = Vector2.new(350, 200),
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			MinimumSize = Vector2.new(300, 100)
		},
		Client = {
			IgnoreGuiInset = true,
			ResetOnSpawn = false,
			Enabled = props.ChartEnabled,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		}
	})[Packages.IsPlugin and "Plugin" or "Client"], {
		Holder = StudioTheme(function(object)
			return ChartResize(function(p)
				local createElement = Roact.createElement
				local v4 = {
					BackgroundTransparency = 1,
					AnchorPoint = Packages.IsPlugin and Vector2.new() or Vector2.new(1, 0),
					Position = Packages.IsPlugin and UDim2.new() or UDim2.new(1, 0, 0, 61),
					Size = Packages.IsPlugin and UDim2.fromScale(1, 1) or p.UISize
				}
				local ref = Roact.Ref
				local v5

				if not Packages.IsPlugin then
					v5 = p.SetSizeTarget or nil
				end

				v4[ref] = v5
				return createElement("Frame", v4, {
					Background = Roact.createElement("Frame", {
						BackgroundColor3 = object:GetColor("MainBackground"),
						BorderSizePixel = 0,
						ZIndex = 0,
						Size = UDim2.fromScale(1, 1)
					}, {
						Notches = Roact.createElement("ImageLabel", {
							AnchorPoint = Vector2.new(0, 1),
							BackgroundTransparency = 1,
							Image = "rbxassetid://18701486909",
							ImageColor3 = object:GetColor("BrightText"),
							ImageTransparency = 0.5,
							Position = UDim2.fromScale(0, 1),
							Size = UDim2.fromOffset(16, 16)
						})
					}),
					UIStroke = Roact.createElement("UIStroke", {
						Color = object:GetColor("DropShadow"),
						Thickness = 1
					}),
					BackgroundCircle = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.fromOffset(100, 100),
						Visible = not visible,
						Position = UDim2.fromOffset(8, 8)
					}, {
						BackgroundUI = Roact.createElement("Frame", {
							BackgroundColor3 = object:GetColor("ScrollBarBackground"),
							Size = UDim2.fromScale(1, 1),
							Visible = #props.state.Arcs > 0
						}, {
							UIStroke = Roact.createElement("UIStroke", {
								Color = object:GetColor("DropShadow"),
								LineJoinMode = Enum.LineJoinMode.Round,
								Transparency = 0.5
							}),
							UICorner = Roact.createElement("UICorner", {
								CornerRadius = UDim.new(0, 4)
							})
						}),
						PacketCircle = Roact.createElement(PacketCircleArcs, {
							Arcs = props.state.Arcs,
							PluginMouse = props.props.PluginMouse,
							OnArcClicked = function(p2)
								props.OnArcClicked:Fire(p2)
							end
						})
					}),
					DataList = Roact.createElement("ScrollingFrame", {
						BackgroundColor3 = object:GetColor("MainBackground"),
						Size = UDim2.new(1, -121, 1, -1),
						Position = UDim2.new(1, -1, 0, 0),
						AnchorPoint = Vector2.new(1, 0),
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.new(),
						BorderSizePixel = 0,
						BackgroundTransparency = 1,
						Visible = not visible,
						ZIndex = 2,
						BottomImage = "rbxassetid://5234388158",
						MidImage = "rbxassetid://5234388158",
						TopImage = "rbxassetid://5234388158",
						ScrollBarImageColor3 = object:GetColor("Light"),
						ScrollBarThickness = 10,
						[Roact.Change.AbsoluteCanvasSize] = function(p2)
							props.SetScrollBarChanged({
								Size = p2.AbsoluteSize.Y,
								Visible = p2.AbsoluteSize.Y < p2.AbsoluteCanvasSize.Y
							})
						end,
						[Roact.Change.AbsoluteSize] = function(p2)
							props.SetScrollBarChanged({
								Size = p2.AbsoluteSize.Y,
								Visible = p2.AbsoluteSize.Y < p2.AbsoluteCanvasSize.Y
							})
						end
					}, {
						UIListLayout = Roact.createElement("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							VerticalAlignment = Enum.VerticalAlignment.Top,
							[Roact.Change.AbsoluteContentSize] = function(p2)
								p2.Parent.CanvasSize = UDim2.fromOffset(0, p2.AbsoluteContentSize.Y)
							end
						}),
						Items = Roact.createElement(PacketChartItems, {
							Arcs = props.state.Arcs,
							ScrollBarChanged = props.ScrollBarChanged,
							OnArcClicked = props.OnArcClicked
						}),
						UIPadding = Roact.createElement("UIPadding", {
							PaddingTop = UDim.new(0, 8),
							PaddingBottom = UDim.new(0, 8)
						})
					}),
					EditModeNotifier = Roact.createElement("TextLabel", {
						AutoLocalize = false,
						Size = UDim2.fromScale(1, 1),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Text = "Start session to begin",
						TextColor3 = object:GetColor("WarningText"),
						TextSize = 20,
						Font = Enum.Font.SourceSans,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						Visible = visible
					}),
					ScrollBarOutline = Roact.createElement("Frame", {
						BackgroundColor3 = object:GetColor("ScrollBarBackground"),
						BorderSizePixel = 0,
						Size = props.ScrollBarChanged:map(function(p2)
							return UDim2.fromOffset(12, p2.Size)
						end),
						Position = UDim2.new(1, 0, 0, 0),
						AnchorPoint = Vector2.new(1, 0),
						Visible = props.ScrollBarChanged:map(function(p2)
							return p2.Visible
						end)
					})
				})
			end)
		end)
	})
end

return extended