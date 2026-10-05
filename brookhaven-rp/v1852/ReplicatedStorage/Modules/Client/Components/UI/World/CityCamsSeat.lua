local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local CityCams = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.CityCams)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "CityCamsSeat"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.ChildAdded:Connect(function(weld)
		if not (weld:IsA("Weld") and weld.Part1.Name == "HumanoidRootPart") then
			return
		end

		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and weld.Part1 == humanoidRootPart) then
			return
		end

		CityCams.SeatStatusChanged:Fire(self.Instance)
	end))
	self._Janitor:Add(self.Instance.ChildRemoved:Connect(function(weld)
		if not (weld:IsA("Weld") and weld.Part1.Name == "HumanoidRootPart") then
			return
		end

		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and weld.Part1 == humanoidRootPart) then
			return
		end

		CityCams.SeatStatusChanged:Fire(nil)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v