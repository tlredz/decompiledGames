local GuiHost = require(script.Parent.GuiHost)
local screenGui = nil
local ScreenHost = {}

function ScreenHost.get()
	if screenGui and screenGui.Parent then
		return screenGui
	end

	local container = GuiHost.resolveContainer()

	if not container then
		return nil
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PartIclesScreenHost"
	screenGui.Archivable = false
	screenGui.DisplayOrder = -10
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = container
	return screenGui
end

function ScreenHost.destroy()
	if screenGui then
		pcall(screenGui.Destroy, screenGui)
		screenGui = nil
	end
end

function ScreenHost.exists()
	return screenGui and screenGui.Parent ~= nil
end

return ScreenHost