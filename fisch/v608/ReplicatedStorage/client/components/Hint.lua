local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Timer = require(packages:WaitForChild("Timer"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
local NotificationController = require(legacyControllers:WaitForChild("NotificationController"))
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "Hint",
	Ancestors = { workspace }
})

function v:Construct()
	self.text = self.Instance:GetAttribute("Text") or ""
	self.range = self.Instance:GetAttribute("Range") or 10
	self.showTime = self.Instance:GetAttribute("TextDuration") or 5
	self.loop = Timer.new(0.25)
	self.trove = Trove.new()
	self.debounce = false
	self.trove:Add(self.loop, "Destroy")
end

function v:Start()
	self.trove:Add(self.loop.Tick:Connect(function()
		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return
		end

		local magnitude = (humanoidRootPart.Position - self.Instance:GetPivot().Position).Magnitude

		if self.debounce == true then
			if self.range * 2 <= magnitude then
				self.debounce = false
			end
		elseif magnitude <= self.range then
			self.debounce = true
			NotificationController:Notify(self.text, self.showTime)
		end
	end))
	self.loop:Start()
end

function v.Stop(p)
	p.trove:Destroy()
end

return v