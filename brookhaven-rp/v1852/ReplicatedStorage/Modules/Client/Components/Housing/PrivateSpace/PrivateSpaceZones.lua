local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "PrivateSpaceZones"
})
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)

function v:Construct()
	self._Janitor = Janitor.new()
	self.restrictHandle = nil
	self.doneFlashing = true
	self.flashHandle = nil
	local NotificationController2 = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
	NotificationController = NotificationController2
end

function v:UpdateZonePart(instance, flag: boolean, p)
	if flag then
		instance:SetAttribute("OccupiedBy", p.UserId)
		instance.CollisionGroup = "PrivateSpace"
		instance.CanCollide = true
		instance.CanTouch = true
		instance.Transparency = 1

		if self.restrictHandle then
			self.restrictHandle:Disconnect()
			self.restrictHandle = nil
		end

		self.restrictHandle = instance.Touched:Connect(function(otherPart)
			local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

			if playerFromCharacter and playerFromCharacter == game.Players.LocalPlayer and self.doneFlashing then
				self.doneFlashing = false
				instance.Transparency = 1
				self.highlightTween = TweenService:Create(
					instance,
					TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 2, true, 0),
					{
						Transparency = 0.5
					}
				)
				self.highlightTween:Play()
				self.flashHandle = self.highlightTween.Completed:Once(function()
					self.doneFlashing = true
				end)
				NotificationController.Notify("You are not allowed to enter this private space.", 5)
			end
		end)
	else
		if self.restrictHandle then
			self.restrictHandle:Disconnect()
			self.restrictHandle = nil
		end

		if self.highlightTween then
			self.highlightTween:Cancel()
			self.highlightTween = nil
		end

		if self.flashHandle then
			self.flashHandle:Disconnect()
			self.flashHandle = nil
		end

		instance:SetAttribute("OccupiedBy", nil)
		instance.CanCollide = false
		instance.Transparency = 1
	end
end

function v:Start()
	if self.Instance.Parent == nil then
		return
	end

	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "RestrictSpace", function(p, flag: boolean, p2)
		self:UpdateZonePart(p, flag, p2)
	end))

	if self.Instance:GetAttribute("Occupied") then
		self:UpdateZonePart(self.Instance, true)
	end
end

function v:Stop()
	if self.restrictHandle then
		self.restrictHandle:Disconnect()
		self.restrictHandle = nil
	end

	if self.highlightTween then
		self.highlightTween:Cancel()
		self.highlightTween = nil
	end

	if self.flashHandle then
		self.flashHandle:Disconnect()
		self.flashHandle = nil
	end

	self._Janitor:Destroy()
end

return v