local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local ContinuousListProvider = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.ContinuousList.ContinuousListProvider)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Interface = require(ReplicatedStorage.Modules.Shared.Utils.Interface)
local Component = require(ReplicatedStorage.Packages.Component)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "ContinuousList"
})

function v:Construct()
	self._Janitor = Janitor.new()
	local provider = self.Instance:WaitForChild("Provider")
	assert(provider:IsA("ObjectValue"))
	self.provider = Interface.GetImplementation(provider, ContinuousListProvider)
	self.panelJanitor = Janitor.new()
	local v2 = Signal.new()
	v2:Connect(function(p)
		for _, guiObject in self.Instance:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Visible and guiObject.LayoutOrder == p then
				self:ScrollTo(guiObject)
			end
		end
	end)
	self.provider:InjectScrollListener(v2)
end

function v:Start()
	local instance = self.Instance
	local panel = self.provider:GetPanel()
	panel:RegisterListener(self, panel.Events.Opening, function()
		for i = 1, self.provider:GetCount() do
			local v2 = self.provider:Render(i)
			v2.Parent = instance
			v2.Visible = true
			v2.LayoutOrder = i
			self.panelJanitor:Add(v2)
		end

		self:Scroll()
	end)
	panel:RegisterListener(self, panel.Events.Closing, function()
		instance.CanvasPosition = Vector2.new(0, 0)
		self.panelJanitor:Cleanup()
	end)
	self._Janitor:Add(instance:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:Scroll()
	end))
end

function v:StopTween()
	if self.tween then
		self.tween:Cancel()
		self.tween:Destroy()
		self.tween = nil
	end
end

function v:Scroll()
	if self.tween and self.tween.PlaybackState == Enum.PlaybackState.Playing then
		return
	end

	local instance = self.Instance
	local v2 = instance.AbsoluteWindowSize.Y / 2
	local v3 = -instance.CanvasPosition.Y

	if instance.CanvasPosition.Y == 0 then
		return self.provider:Scrolled(1)
	end

	if instance.CanvasPosition.Y >= instance.AbsoluteCanvasSize.Y - instance.AbsoluteWindowSize.Y then
		return self.provider:Scrolled(self.provider:GetCount())
	end

	for _, guiObject in instance:GetChildren() do
		if not (guiObject:IsA("GuiObject") and guiObject.Visible) then
			continue
		end

		v3 += guiObject.AbsoluteSize.Y

		if not (v2 <= v3) then
			continue
		end

		self.provider:Scrolled(guiObject.LayoutOrder)
		break
	end
end

function v:ScrollTo(p)
	self:StopTween()
	local instance = self.Instance
	local total = 0

	for _, guiObject in self.Instance:GetChildren() do
		if not (guiObject:IsA("GuiObject") and guiObject.Visible) then
			continue
		end

		if guiObject.LayoutOrder < p.LayoutOrder then
			total += guiObject.AbsoluteSize.Y
		else
			break
		end
	end

	self.provider:Scrolled(p.LayoutOrder)
	self.tween = TweenService:Create(instance, TweenInfo.new(1), {
		CanvasPosition = Vector2.new(instance.CanvasPosition.X, (math.min(instance.AbsoluteCanvasSize.Y, total)))
	})
	self.panelJanitor:Add(function()
		self:StopTween()
	end)
	self.tween:Play()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v