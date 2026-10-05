local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "UIPulsatingBackground"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance then
		warn("UIPulsatingBackground is not on a GuiObject")
		return
	end

	local backgroundColor3 = self.Instance.BackgroundColor3
	local v2 = {
		BackgroundColor3 = Color3.fromHex(self.Instance:GetAttribute("UIPulsatingBackground_Color"))
	}
	local uIPulsatingBackground_Time = self.Instance:GetAttribute("UIPulsatingBackground_Time")
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(uIPulsatingBackground_Time, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
		v2
	)
	tween:Play()
	self._Janitor:Add(function()
		tween:Cancel()
		self.Instance.BackgroundColor3 = backgroundColor3
	end, true)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v