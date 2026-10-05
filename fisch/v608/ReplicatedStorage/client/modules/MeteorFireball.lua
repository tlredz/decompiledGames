local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local active = workspace:WaitForChild("active")
RunService.RenderStepped:Connect(function(dt)
	for _, v in CollectionService:GetTagged("GnomeBoss_FireballOuter") do
		if v:IsDescendantOf(workspace) then
			v.CFrame *= CFrame.fromOrientation(0, math.rad(dt) * 360, 0)
		end
	end
end)
return {
	Create = function(self: Vector3, p: number, p2: number, value: string?)
		local clone = script[value or "Fireball"]:Clone()
		clone:PivotTo(CFrame.new(self))
		local v = math.max(p * 1.05, p + 0.5)
		clone.Inner.Size = Vector3.new(p, p, p)
		clone.Outer.Size = Vector3.new(v, v, v)

		if not SettingsController:GetSettingValue("photosensitiveMode") then
			clone.Inner.Flash.FlashImg.ImageTransparency = 0
			clone.Inner.Flash.Enabled = true
			clone.Inner.Flash.Size = UDim2.new(p * 4, 500, p * 4, 500)
			TweenService:Create(clone.Inner.Flash.FlashImg, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				ImageTransparency = 1
			}):Play()
		end

		clone.Parent = active
		task.delay(p2 * 0.2, function()
			TweenService:Create(clone.Inner, TweenInfo.new(p2 * 0.4, Enum.EasingStyle.Quint), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone.Outer, TweenInfo.new(p2 * 0.8, Enum.EasingStyle.Quint), {
				Transparency = 1
			}):Play()
			task.wait(p2 * 0.8)
			clone:Destroy()
		end)
	end
}