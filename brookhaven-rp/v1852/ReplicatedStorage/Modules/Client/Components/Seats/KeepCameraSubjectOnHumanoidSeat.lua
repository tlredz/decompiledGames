local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "KeepCameraSubjectOnHumanoidSeat"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.ChildAdded:Connect(function(weld)
		if weld:IsA("Weld") and weld.Name == "SeatWeld" then
			local part1 = weld.Part1
			local humanoid = part1.Parent:FindFirstChildWhichIsA("Humanoid")

			if part1.Parent ~= Players.LocalPlayer.Character then
				return
			end

			workspace.CurrentCamera.CameraSubject = humanoid
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v