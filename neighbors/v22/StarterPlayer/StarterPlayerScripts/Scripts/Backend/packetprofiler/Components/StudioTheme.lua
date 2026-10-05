local parent = script.Parent.Parent
local components = parent.Components
local modules = parent.Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)
local StudioSettings = require(components.StudioSettings)
local extended = Roact.Component:extend("StudioThemeProvider")

function extended:init()
	self:setState({
		CurrentTheme = StudioSettings.Theme
	})
	self.StudioThemeChanged = StudioSettings.ThemeChanged:Connect(function()
		self:setState({
			CurrentTheme = StudioSettings.Theme
		})
	end)
end

function extended.render(p)
	return Roact.oneChild(p.props[Roact.Children])(p.state.CurrentTheme)
end

function extended.willUnmount(p)
	p.StudioThemeChanged:Disconnect()
end

local function StudioTheme(component)
	return Roact.createElement(extended, {}, {
		Component = component
	})
end

return StudioTheme