local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local ConsoleControlsConstructGate = require(ReplicatedStorage.Modules.Client.Components.UI.Console.ConsoleControlsConstructGate)
local v = Component.new({
	Tag = "PlatformResize",
	Extensions = { ConsoleControlsConstructGate }
})
local v2 = {
	Keyboard = true,
	Mobile = true,
	Controller = true
}

local function getSizeAttributeName(p: string)
	return "PlatformSize" .. p
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._originalSize = nil
end

function v:_applyForPlatform()
	local instance = self.Instance
	local mode = Platform.Mode

	if not v2[mode] then
		instance.Size = self._originalSize
		return
	end

	local attribute = instance:GetAttribute("PlatformSize" .. mode)

	if typeof(attribute) == "UDim2" then
		instance.Size = attribute
	else
		instance.Size = self._originalSize
	end
end

function v:Start()
	if not self.Instance:IsA("GuiObject") then
		warn((`[PlatformResize] Expected GuiObject, got {self.Instance.ClassName} at {self.Instance:GetFullName()}`))
		return
	end

	self._originalSize = self.Instance.Size
	self._Janitor:Add(Platform.PlatformChangedSignal:Connect(function()
		self:_applyForPlatform()
	end))
	self:_applyForPlatform()
end

function v:Stop()
	self._Janitor:Destroy()

	if self.Instance:IsA("GuiObject") then
		self.Instance.Size = self._originalSize
	end
end

return v