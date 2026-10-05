local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local v = Component.new({
	Tag = "CancellableInteraction"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._cancelHandler = nil
	self._interactionJumpEnabled = nil
end

function v:_SetInteractionJumpLocked(flag: boolean)
	local character = Players.LocalPlayer.Character
	local humanoid

	if character == nil then
		humanoid = false
	else
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if humanoid == nil then
		return
	end

	if flag then
		if self._interactionJumpEnabled == nil then
			self._interactionJumpEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
		end

		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	elseif self._interactionJumpEnabled ~= nil then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, self._interactionJumpEnabled)
		self._interactionJumpEnabled = nil
	end
end

function v:_SetCancelHandler(cancelHandler)
	if self._cancelHandler == cancelHandler then
		return
	end

	local _cancelHandler = self._cancelHandler
	self._cancelHandler = cancelHandler

	if _cancelHandler ~= nil then
		EmotesController.ClearExternalCancelHandler(_cancelHandler)
	end

	if cancelHandler ~= nil then
		EmotesController.SetExternalCancelHandler(cancelHandler)
	end
end

function v:Start()
	self._Janitor:Add(Remotes.connectComponentRemote(
		self.Instance,
		"SetInteractionCancellable",
		function(flag: boolean, flag2: boolean?)
			if flag then
				if EmotesController.IsPlayingEmote() then
					EmotesController.StopEmote()
				end

				if flag2 == true then
					self:_SetInteractionJumpLocked(true)
				end

				self:_SetCancelHandler(function()
					Remotes.fireServerComponent(self.Instance, "CancelInteraction")
				end)
			else
				self:_SetCancelHandler(nil)
				self:_SetInteractionJumpLocked(false)
			end
		end
	))
end

function v:Stop()
	self:_SetCancelHandler(nil)
	self:_SetInteractionJumpLocked(false)
	self._Janitor:Destroy()
end

return v