local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local ConsoleControlsConstructGate = require(ReplicatedStorage.Modules.Client.Components.UI.Console.ConsoleControlsConstructGate)
local v = Component.new({
	Tag = "PlatformVisibility",
	Extensions = { ConsoleControlsConstructGate }
})
local v2 = {
	Keyboard = true,
	Mobile = true,
	Controller = true
}

function v:Construct()
	self._Janitor = Janitor.new()
	self._targetPlatforms = {}
end

function v:_canShowOnCurrentPlatform()
	return self._targetPlatforms[Platform.Mode] == true
end

function v:_applyVisibility()
	self.Instance.Visible = self:_canShowOnCurrentPlatform()
end

function v:_refreshTargetPlatform()
	local platformVisibility = self.Instance:GetAttribute("PlatformVisibility")
	local targetPlatforms = {}

	if typeof(platformVisibility) == "string" then
		for k in string.gmatch(platformVisibility, "[^,]+") do
			local v4 = string.match(k, "^%s*(.-)%s*$")

			if not (v4 ~= nil and v4 ~= "") then
				continue
			end

			if v2[v4] then
				targetPlatforms[v4] = true
			else
				warn((`[PlatformVisibility] Unknown platform "{v4}" on {self.Instance:GetFullName()}`))
			end
		end
	else
		warn((`[PlatformVisibility] Invalid or missing PlatformVisibility attribute on {self.Instance:GetFullName()}`))
	end

	self._targetPlatforms = targetPlatforms
end

function v:Start()
	if not self.Instance:IsA("GuiObject") then
		warn((`[PlatformVisibility] Expected GuiObject, got {self.Instance.ClassName} at {self.Instance:GetFullName()}`))
		return
	end

	self:_refreshTargetPlatform()
	self._Janitor:Add(Platform.PlatformChangedSignal:Connect(function()
		self:_applyVisibility()
	end))
	self:_applyVisibility()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v