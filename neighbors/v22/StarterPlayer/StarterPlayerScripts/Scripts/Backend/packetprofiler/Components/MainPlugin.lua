local UserInputService = game:GetService("UserInputService")
local parent = script.Parent.Parent
local plugin = parent:FindFirstAncestorOfClass("Plugin")
local components = parent.Components
local modules = parent.Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)
local Signal = require(Packages.Directory.Signal)
Roact.setGlobalConfig({
	elementTracing = true
})
local extended = Roact.Component:extend("MainPlugin")

function extended:init()
	self.OnPacketProfilerEnabled = Signal.new()
	local isPacketChartEnabled

	if plugin then
		isPacketChartEnabled = plugin:GetSetting("PacketChartEnabled") == true
	else
		isPacketChartEnabled = false
	end

	self.IsPacketChartEnabled = isPacketChartEnabled
	self.OnPacketChartEnabled = Signal.new()
	local packetProfilerEnabled

	if plugin then
		packetProfilerEnabled = plugin:GetSetting("PacketProfilerEnabled") == true
	else
		packetProfilerEnabled = false
	end

	self:setState({
		PacketProfilerEnabled = packetProfilerEnabled
	})

	if Packages.IsPlugin then
		self.props.PacketProfiler:SetActive(self.state.PacketProfilerEnabled)
		self.props.PacketChart:SetActive(self.IsPacketChartEnabled)
	end

	self.Connections = {}
	self.Signals = {
		ProfilerFrameSelected = Signal.new(),
		ProfilerPaused = Signal.new()
	}

	function self.OnPacketProfilerClicked()
		local packetProfilerEnabled2 = not self.state.PacketProfilerEnabled
		self.OnPacketProfilerEnabled:Fire(packetProfilerEnabled2)
		self:setState({
			PacketProfilerEnabled = packetProfilerEnabled2
		})

		if plugin then
			plugin:SetSetting("PacketProfilerEnabled", packetProfilerEnabled2)
		end
	end

	function self.OnPacketChartClicked(p)
		local isPacketChartEnabled2 = p or not self.IsPacketChartEnabled
		self.IsPacketChartEnabled = isPacketChartEnabled2
		self.OnPacketChartEnabled:Fire(isPacketChartEnabled2)

		if plugin then
			plugin:SetSetting("PacketChartEnabled", isPacketChartEnabled2)
		end
	end
end

function extended:didMount()
	if Packages.IsPlugin then
		table.insert(self.Connections, self.props.PacketProfiler.Click:Connect(self.OnPacketProfilerClicked))
		table.insert(self.Connections, self.props.PacketChart.Click:Connect(self.OnPacketChartClicked))
	else
		table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input)
			if not UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				return
			end

			if input.KeyCode == Enum.KeyCode.F5 then
				self.OnPacketProfilerClicked()
			elseif input.KeyCode == Enum.KeyCode.P then
				self.ProfilerPaused = not self.ProfilerPaused
				self.Signals.ProfilerPaused:Fire(self.ProfilerPaused)
			end
		end))
		table.insert(self.Connections, self.Signals.ProfilerFrameSelected:Connect(function(p)
			if #p.Packets == 0 then
				self.OnPacketChartClicked(false)
			else
				self.OnPacketChartClicked(true)
			end
		end))
	end
end

function extended.render(props)
	local createFragment = Roact.createFragment
	local packetProfiler

	if props.state.PacketProfilerEnabled then
		local createElement = Roact.createElement
		local PacketProfiler = require(components.PacketProfiler)
		packetProfiler = createElement(PacketProfiler, {
			Enabled = true,
			OnEnabled = props.OnPacketProfilerEnabled,
			Signals = props.Signals
		}) or nil
	end

	local createElement = Roact.createElement
	local PacketChart = require(components.PacketChart)
	return createFragment({
		PacketProfiler = packetProfiler,
		PacketChart = createElement(PacketChart, {
			Enabled = props.IsPacketChartEnabled,
			OnEnabled = props.OnPacketChartEnabled,
			Signals = props.Signals,
			PluginMouse = plugin and plugin:GetMouse() or nil
		})
	})
end

function extended.willUnmount(p)
	for _, connection in p.Connections do
		connection:Disconnect()
	end

	table.clear(p.Connections)
end

return extended