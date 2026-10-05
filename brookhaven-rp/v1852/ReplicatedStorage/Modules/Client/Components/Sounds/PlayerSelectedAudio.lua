local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LotRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.LotRoot)
local v = false
local isServer = RunService:IsServer()
local v2 = Component.new({
	Tag = "PlayerSelectedAudio"
})

function v2:Construct()
	self._Janitor = Janitor.new()

	if not isServer then
		local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
		v = ReplicatedDataController
	end

	self.musicMute = false
	self.volumeModifier = 75
end

function v2:Start()
	local instance = self.Instance

	if not instance:IsA("Sound") then
		warn("PlayerSelectedAudio component not on Sound!")
		return
	end

	self.Sound = instance
	self.originalVolume = self.Sound.Volume

	if not instance.Parent:IsA("BasePart") then
		warn("PlayerSelectedAudio component not on child of BasePart!")
	elseif not isServer then
		self.owner = ""

		if instance:IsDescendantOf(Workspace.Vehicles) then
			local parent = instance.Parent

			while parent do
				if CollectionService:HasTag(parent, "VehicleRoot") then
					self.owner = string.sub(parent.Name, 1, -4)
					break
				else
					parent = parent.Parent
				end
			end
		elseif instance:IsDescendantOf(Workspace["001_Lots"]) then
			local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
				self.Instance,
				"LotRoot",
				LotRoot
			)

			if waitForAncestorComponent and waitForAncestorComponent:GetOwner() ~= nil then
				self.owner = waitForAncestorComponent:GetOwner().Name
			end
		else
			local parent = instance.Parent

			while parent do
				if parent:IsA("Player") then
					self.owner = parent.Name
					break
				end

				local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

				if playerFromCharacter then
					self.owner = playerFromCharacter.Name
					break
				else
					parent = parent.Parent
				end
			end
		end

		local v3, v4 = v.GetClientReplicaPromise():await()

		if v3 == false then
			warn("PlayerSelectedAudio: Failed to get client replica")
			return
		end

		self:MuteOtherPlayersMusic(v4.Data.Settings.MusicMute)
		self._Janitor:Add(v4:OnSet({ "Settings", "MusicMute" }, function(p)
			self:MuteOtherPlayersMusic(p)
		end), "Disconnect")
		self:UpdateVolume(v4.Data.musicPlayerVolume)
		self._Janitor:Add(v4:OnSet({ "musicPlayerVolume" }, function(p: number)
			self:UpdateVolume(p)
		end), "Disconnect")
	end
end

function v2:MuteOtherPlayersMusic(musicMute: boolean)
	self.musicMute = musicMute
	self:UpdateVolume(self.volumeModifier)
end

function v2:UpdateVolume(volumeModifier: number)
	self.volumeModifier = volumeModifier
	local v3 = self.originalVolume * self.volumeModifier / 75
	self.Sound.Volume = self.owner ~= localPlayer.Name and self.musicMute and 0 or v3
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2