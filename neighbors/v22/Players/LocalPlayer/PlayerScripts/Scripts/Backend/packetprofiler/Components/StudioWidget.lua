local plugin = script:FindFirstAncestorOfClass("Plugin")
local modules = plugin:FindFirstChildOfClass("Script").Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)
local extended = Roact.Component:extend("StudioWidget")

function extended:init()
	local dockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo.new(
		self.props.InitialDockState,
		self.props.Enabled,
		false,
		self.props.DefaultSize.X,
		self.props.DefaultSize.Y,
		self.props.MinimumSize.X,
		self.props.MinimumSize.Y
	)
	local dockWidgetPluginGui = plugin:CreateDockWidgetPluginGui(self.props.WidgetId, dockWidgetPluginGuiInfo)
	dockWidgetPluginGui.Title = self.props.WidgetTitle
	dockWidgetPluginGui.Name = self.props.WidgetId
	dockWidgetPluginGui.ZIndexBehavior = self.props.ZIndexBehavior or Enum.ZIndexBehavior.Global
	self.Widget = dockWidgetPluginGui
end

function extended:didMount()
	self.OnEnabled = self.props.OnEnabled:Connect(function(enabled)
		self.Widget.Enabled = enabled
	end)
	self.Widget:BindToClose(function()
		self.Widget.Enabled = false
	end)
end

function extended.render(p)
	return Roact.createElement(Roact.Portal, {
		target = p.Widget
	}, p.props[Roact.Children])
end

function extended.didUpdate(p, p2)
	if p.props.Enabled ~= p2.Enabled then
		p.Widget.Enabled = p.props.Enabled
	end
end

function extended.willUnmount(p)
	p.OnEnabled:Disconnect()
end

return extended