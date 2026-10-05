local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local v = Component.new({
	Tag = "PromptAvatarPurchaseButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._debounce = false
end

function v:PromptAvatarPurchase()
	self._debounce = true
	self.Instance.BackgroundColor3 = Color3.new(0.5, 1, 0.5)

	if not WearingController.PromptFullAvatarPurchase() then
		self.Instance.BackgroundColor3 = Color3.new(1, 0.5, 0.5)
		task.wait(1)
	end

	TweenService:Create(self.Instance, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = Color3.new(1, 1, 0)
	}):Play()
	task.delay(0.5, function()
		self._debounce = false
	end)
end

function v:Start()
	local instance = self.Instance
	local flag = false
	self._Janitor:Add(instance.Activated:Connect(function()
		if self._debounce or flag then
			return
		end

		flag = true
		self:PromptAvatarPurchase()
		flag = false
		TelemetryController.SendClientInteraction("avatarEditorUI", {
			button = "BuyAll"
		})
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v