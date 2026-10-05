game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("GamepadService")
game:GetService("GuiService")
require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.packages.Signal)
require(ReplicatedStorage.shared.modules.Hook)
require("../Types")
require(ReplicatedStorage.client.legacyControllers.SettingsController)
local Interface = {}

function Interface.new(current)
	local object = setmetatable({}, {
		__index = Interface
	})
	object.current = current
	object.trove = current.trove:Extend()
	object.Disabled = false
	object._progressBarVelocity = 0
	return object
end

function Interface.Start(p)
	p.current.ui_progress.Position += UDim2.fromScale(0, 0.5)
	p.current.ui.passivebars.Position += UDim2.fromScale(0.5, 0)
	p.current.ui_thumbstick.Position += UDim2.fromScale(0, -1)
	TweenService:Create(p.current.ui_progress, TweenInfo.new(1, Enum.EasingStyle.Quint), {
		Position = p.current.ui_progress.Position - UDim2.fromScale(0, 0.5)
	}):Play()
	TweenService:Create(p.current.ui.passivebars, TweenInfo.new(1, Enum.EasingStyle.Quint), {
		Position = p.current.ui.passivebars.Position - UDim2.fromScale(0.5, 0)
	}):Play()
	TweenService:Create(p.current.ui_thumbstick, TweenInfo.new(1, Enum.EasingStyle.Quint), {
		Position = p.current.ui_thumbstick.Position - UDim2.fromScale(0, -1)
	}):Play()
	p.current.trove:Add(p.current.PreMinigameEnd:Once(function()
		TweenService:Create(
			p.current.ui_progress,
			TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				Position = p.current.ui_progress.Position + UDim2.fromScale(0, 0.5)
			}
		):Play()
		TweenService:Create(
			p.current.ui.passivebars,
			TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				Position = p.current.ui.passivebars.Position + UDim2.fromScale(0.5, 0)
			}
		):Play()
		TweenService:Create(
			p.current.ui_thumbstick,
			TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				Position = p.current.ui_thumbstick.Position + UDim2.fromScale(0, -1)
			}
		):Play()
	end))
end

function Interface:Disable()
	self.Disabled = true
end

function Interface.Stop(p)
	p.trove:Clean()
end

function Interface.TickLogic(p, _: number)
	if p.Disabled then
	end
end

function Interface:TickRender(p: number)
	if self.Disabled then
		return
	end

	local smoothDamp, progressBarVelocity = TweenService:SmoothDamp(
		self.current.ui_progress.bar.Size.X.Scale,
		math.clamp(self.current.progress / 100, 0, 1),
		self._progressBarVelocity,
		self.current.ready and 0.1 or 1,
		nil,
		p
	)
	self._progressBarVelocity = progressBarVelocity
	self.current.ui_progress.bar.Size = UDim2.fromScale(smoothDamp, 1)
end

return Interface