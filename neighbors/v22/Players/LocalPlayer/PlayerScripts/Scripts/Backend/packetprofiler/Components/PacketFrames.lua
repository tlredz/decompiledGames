local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent
local components = parent.Components
local modules = parent.Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)
local PacketSizeCounter = require(Packages.Directory.PacketSizeCounter)
local StudioTheme = require(components.StudioTheme)
local CircularBuffer = require(modules.CircularBuffer)
local PacketFrame = require(components.PacketFrame)
local guiInset = GuiService:GetGuiInset()
local extended = Roact.Component:extend("PacketFrames")
local visible = not RunService:IsRunning()
local v2 = RunService:IsClient() and "OnClientEvent" or "OnServerEvent"
local remoteFunctionEventprofiler = ReplicatedStorage:FindFirstChild("RemoteFunctionEvent.profiler", true)

function extended:init()
	self.Cleanup = {}
	self.ProfilerBackgroundRef = Roact.createRef()
	self.Enabled = not visible
	self.PacketFrames = CircularBuffer.new(256)
	self:setState({
		PacketFrames = extended
	})
	local binding, setPacketsChanged = Roact.createBinding(self.PacketFrames)
	self.PacketsChanged = binding
	self.SetPacketsChanged = setPacketsChanged

	function self.RemoteCallback(instance, p, ...)
		if not self.Enabled then
			return
		end

		local size

		if RunService:IsClient() then
			size = PacketSizeCounter.GetPacketSize({
				RunContext = "Client",
				RemoteType = instance.ClassName,
				PacketData = { p, ... }
			})
		else
			size = PacketSizeCounter.GetPacketSize({
				RunContext = "Server",
				RemoteType = instance.ClassName,
				PacketData = { ... }
			})
		end

		self.CurrentFrame.TotalSize += size
		table.insert(self.CurrentFrame.Packets, {
			Remote = instance,
			Data = RunService:IsClient() and ({ p, ... } or { ... }) or { ... },
			RawData = { p, ... },
			Size = size,
			RunContext = RunService:IsClient() and "Client" or "Server"
		})
	end

	function self.InputBegan(_, p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 then
			local v4 = self.UpdateMouseData(p.Position.X, p.Position.Y + guiInset.Y, true)

			if v4 then
				self.props.Signals.ProfilerFrameSelected:Fire(v4)
			end

			self.props.OnPacketProfilerPaused:Fire(true)
		end
	end

	local binding2, setMousePosition = Roact.createBinding(Vector2.new(0, 0))
	self.MousePosition = binding2
	self.SetMousePosition = setMousePosition
	local binding3, setMouseOver = Roact.createBinding(false)
	self.MouseOver = binding3
	self.SetMouseOver = setMouseOver
	local v6 = {
		Selected = false,
		Index = 0,
		TotalSize = 0,
		Packets = {}
	}
	local binding4, setSelectedFrameData = Roact.createBinding(v6)
	self.SelectedFrameData = binding4
	self.SetSelectedFrameData = setSelectedFrameData
	local binding5, setMouseFrameData = Roact.createBinding(v6)
	self.MouseFrameData = binding5
	self.SetMouseFrameData = setMouseFrameData

	function self.UpdateMouseData(p: number, p2: number, selected: boolean)
		self.SetMousePosition(Vector2.new(p, p2))
		local v9 = 256 - math.floor(p / (self.ProfilerBackgroundRef:getValue().AbsoluteSize.X * 0.00390625))
		local v10

		if p > 0 then
			v10 = self.PacketFrames[v9] or nil
		end

		if not v10 then
			self.SetMouseFrameData(v6)
			return v10
		end

		local v11 = {
			Selected = selected,
			Index = v9,
			TotalSize = v10.TotalSize,
			Packets = v10.Packets
		}

		if selected then
			self.SetSelectedFrameData(v11)
		end

		self.SetMouseFrameData(v11)
		return v10
	end

	function self.MouseEnter(_, p: number, p2: number)
		if visible then
			return
		end

		self.UpdateMouseData(p, p2, false)
		self.SetMouseOver(true)
	end

	function self.MouseMoved(_, p: number, p2: number)
		if visible then
			return
		end

		self.UpdateMouseData(p, p2, false)
	end

	function self.MouseLeave(_)
		if visible then
			return
		end

		self.UpdateMouseData(-1, -1, false)
		self.SetMouseOver(false)
	end

	local binding6, setTooltipSize = Roact.createBinding(Vector2.zero)
	self.TooltipSize = binding6
	self.SetTooltipSize = setTooltipSize
end

function extended:didMount()
	if not visible then
		table.insert(self.Cleanup, self.props.OnPacketProfilerPaused:Connect(function(flag: boolean)
			self.Enabled = not flag
		end))
		self.CurrentFrame = {
			Time = os.clock(),
			TotalSize = 0,
			Packets = {}
		}
		task.spawn(function()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			local ReplicatedFirst = game:GetService("ReplicatedFirst")
			local StarterPlayer = game:GetService("StarterPlayer")
			local Workspace = game:GetService("Workspace")
			local StarterGui = game:GetService("StarterGui")
			local Players = game:GetService("Players")
			local ServerScriptService

			if RunService:IsServer() then
				ServerScriptService = game:GetService("ServerScriptService")
			end

			local v4

			if RunService:IsServer() then
				v4 = game:GetService("ServerStorage")
			end

			for _, folder in {
				ReplicatedStorage2,
				ReplicatedFirst,
				StarterPlayer,
				Workspace,
				StarterGui,
				Players,
				ServerScriptService,
				v4
			} do
				for _, descendant in folder:GetDescendants() do
					if not (descendant:IsA("RemoteEvent") or descendant:IsA("UnreliableRemoteEvent")) then
						continue
					end

					local v5 = descendant
					table.insert(self.Cleanup, descendant[v2]:Connect(function(...)
						self.RemoteCallback(v5, ...)
					end))
				end

				table.insert(self.Cleanup, folder.DescendantAdded:Connect(function(instance)
					if instance:IsA("RemoteEvent") or instance:IsA("UnreliableRemoteEvent") then
						table.insert(self.Cleanup, instance[v2]:Connect(function(...)
							self.RemoteCallback(instance, ...)
						end))
					end
				end))
			end

			if remoteFunctionEventprofiler == nil then
				local descendantAddedConnection = nil
				descendantAddedConnection = ReplicatedStorage.DescendantAdded:Connect(function(bindableEvent)
					if bindableEvent:IsA("BindableEvent") and bindableEvent.Name == "RemoteFunctionEvent.profiler" then
						remoteFunctionEventprofiler = bindableEvent
						table.insert(self.Cleanup, remoteFunctionEventprofiler.Event:Connect(self.RemoteCallback))
						descendantAddedConnection:Disconnect()
					end
				end)
			else
				table.insert(self.Cleanup, remoteFunctionEventprofiler.Event:Connect(self.RemoteCallback))
			end

			table.insert(self.Cleanup, RunService.RenderStepped:Connect(function()
				if not self.Enabled then
					return
				end

				self.PacketFrames:push(self.CurrentFrame)
				self.SetPacketsChanged(self.PacketFrames)
				self.CurrentFrame = {
					Time = os.clock(),
					TotalSize = 0,
					Packets = {}
				}

				if self.MouseOver:getValue() then
					local value = self.MousePosition:getValue()
					self.UpdateMouseData(value.X, value.Y, self.SelectedFrameData:getValue().Selected)
				end
			end))
		end)
	end
end

function extended.willUnmount(p)
	for _, connection in p.Cleanup do
		connection:Disconnect()
	end
end

function extended.render(props)
	local children = {}

	for i = 1, 256 do
		children[i] = Roact.createElement(PacketFrame, {
			Index = i,
			PacketsChanged = props.PacketsChanged,
			MaxFrameSize = props.props.MaxFrameSize,
			MaxFrames = 256
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		[Roact.Event.InputBegan] = props.InputBegan,
		[Roact.Event.MouseEnter] = props.MouseEnter,
		[Roact.Event.MouseMoved] = props.MouseMoved,
		[Roact.Event.MouseLeave] = props.MouseLeave,
		[Roact.Ref] = props.ProfilerBackgroundRef
	}, {
		Frames = Roact.createFragment(children),
		SelectedHighlight = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.00390625, 1),
			BackgroundTransparency = 0.5,
			Position = props.SelectedFrameData:map(function(p)
				return UDim2.fromScale(1 - p.Index / 256, 0)
			end),
			BorderSizePixel = 0,
			Visible = props.SelectedFrameData:map(function(p)
				return p and p.Selected
			end),
			ZIndex = 2,
			BackgroundColor3 = Color3.fromHex("#34ff30")
		}),
		FrameHighlight = Roact.createElement("Frame", {
			Size = props.MouseFrameData:map(function(p)
				local v4 = math.min(p.TotalSize / props.props.MaxFrameSize, 1)
				return UDim2.fromScale(0.00390625, v4)
			end),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 0.25,
			Position = props.MouseFrameData:map(function(p)
				return UDim2.fromScale(1 - p.Index / 256, 1)
			end),
			ZIndex = 2,
			BorderSizePixel = 0,
			Visible = props.MouseFrameData:map(function(p)
				return p.Index ~= 0
			end),
			BackgroundColor3 = Color3.fromHex("#e8e8e8")
		}),
		FrameTooltip = StudioTheme(function(object)
			return Roact.createElement("Frame", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = object:GetColor("Dropdown"),
				BorderColor3 = object:GetColor("Border"),
				Position = props.MousePosition:map(function(p)
					local currentCamera = workspace.CurrentCamera
					local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(0, 0)
					local value = props.TooltipSize:getValue()
					return UDim2.fromOffset(math.min(p.X, viewportSize.X - value.X), p.Y + 12)
				end),
				Visible = props.MouseOver,
				ZIndex = 2,
				[Roact.Change.AbsoluteSize] = function(p)
					props.SetTooltipSize(p.AbsoluteSize)
				end,
				[Roact.Ref] = function(p)
					if p then
						props.SetTooltipSize(p.AbsoluteSize)
					end
				end
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {}),
				FrameLabel = Roact.createElement("TextLabel", {
					AutoLocalize = false,
					Text = props.MouseFrameData:map(function(p)
						return string.format("%d packets, %d bytes", #p.Packets, p.TotalSize)
					end),
					TextColor3 = object:GetColor("BrightText"),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					Font = Enum.Font.SourceSans,
					TextSize = 16,
					Size = UDim2.fromOffset(200, 16),
					BackgroundTransparency = 1
				}),
				KBSent = Roact.createElement("TextLabel", {
					AutoLocalize = false,
					Text = props.MouseFrameData:map(function(p)
						return string.format("%.3f KB sent", p.TotalSize / 1000)
					end),
					TextColor3 = object:GetColor("BrightText"),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					Font = Enum.Font.SourceSans,
					TextSize = 16,
					Size = UDim2.fromOffset(200, 16),
					BackgroundTransparency = 1
				})
			})
		end),
		EditModeNotifier = StudioTheme(function(object)
			return Roact.createElement("TextLabel", {
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
			})
		end)
	})
end

return extended