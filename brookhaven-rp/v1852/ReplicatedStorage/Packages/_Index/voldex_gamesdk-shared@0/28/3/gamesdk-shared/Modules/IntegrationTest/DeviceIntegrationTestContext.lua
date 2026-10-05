local GuiService = game:GetService("GuiService")
require(script.Parent.IntegrationTestContext)
local DeviceIntegrationTestContext = {}
DeviceIntegrationTestContext.__index = DeviceIntegrationTestContext

function DeviceIntegrationTestContext.new(remote)
	local self = setmetatable({}, DeviceIntegrationTestContext)
	self.__index = DeviceIntegrationTestContext
	self._remote = remote
	return self
end

function DeviceIntegrationTestContext:ClickAtAsync(p2: number, p3: number)
	local insetArea = GuiService:GetInsetArea(Enum.ScreenInsets.None)
	self._remote:InvokeServer(
		"ClickAtAsync",
		p2,
		p3,
		insetArea.Max.X - insetArea.Min.X,
		insetArea.Max.Y - insetArea.Min.Y
	)
end

function DeviceIntegrationTestContext:ClickOnInstanceAsync(p)
	local X = p.AbsolutePosition.X
	local Y = p.AbsolutePosition.Y
	local X2 = p.AbsoluteSize.X
	local Y2 = p.AbsoluteSize.Y
	local v = X + X2 / 2
	local v2 = Y + Y2 / 2 + GuiService:GetGuiInset().Y
	self:ClickAtAsync(v - GuiService:GetInsetArea(Enum.ScreenInsets.None).Min.X, v2)
end

function DeviceIntegrationTestContext.KeyPressAsync(_, _)
	error("Not implemented")
end

function DeviceIntegrationTestContext.TextInputAsync(_, _, _: string)
	error("Not implemented")
end

function DeviceIntegrationTestContext.WalkToAsync(_, _: number, _: Vector3)
	error("Not implemented")
end

return DeviceIntegrationTestContext