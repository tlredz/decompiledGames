local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local EmotesConfig = require(ReplicatedStorage.Modules.Shared.DB.Emotes.EmotesConfig)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local v = Component.new({
	Tag = "ToolEmoteBlocker",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._characterJanitor = self._Janitor:AddObject(Janitor, "Destroy")
end

function v:Start()
	local instance = self.Instance
	local localPlayer = Players.LocalPlayer

	local function isToolOwnedTrack(p)
		return p.Animation:IsDescendantOf(instance)
	end

	local function catalogEmoteNameForTrack(p)
		if p.Animation:IsDescendantOf(instance) or not p.IsPlaying then
			return nil
		end

		local v2 = string.match(p.Animation.AnimationId, "%d+")

		if v2 == nil then
			return nil
		end

		local v3 = tonumber(v2)

		if v3 == nil then
			return nil
		end

		return EmotesConfig.GetNameFromId(v3)
	end

	local function shouldBlockWhileEquipped()
		if EmotesController.IsPlayingEmote() then
			return true
		end

		local character = localPlayer.Character

		if character == nil then
			return false
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid == nil then
			return false
		end

		local animator = humanoid:FindFirstChildOfClass("Animator")

		if animator == nil then
			return false
		end

		for _, v2 in animator:GetPlayingAnimationTracks() do
			local v3

			if not (v2.Animation:IsDescendantOf(instance) or not v2.IsPlaying) then
				local v4 = string.match(v2.Animation.AnimationId, "%d+")

				if v4 ~= nil then
					local v5 = tonumber(v4)

					if v5 ~= nil then
						v3 = EmotesConfig.GetNameFromId(v5)
					end
				end
			end

			if v3 ~= nil then
				return true
			end
		end

		return false
	end

	local function unequipToBackpack()
		if instance.Parent == localPlayer.Character then
			instance.Parent = localPlayer.Backpack
		end
	end

	local function onEquipped()
		task.defer(function()
			if instance.Parent ~= localPlayer.Character then
				return
			end

			if shouldBlockWhileEquipped() and instance.Parent == localPlayer.Character then
				instance.Parent = localPlayer.Backpack
			end
		end)
	end

	local function onAnimationPlayed(p)
		if instance.Parent ~= localPlayer.Character or p.Animation:IsDescendantOf(instance) then
			return
		end

		task.defer(function()
			if instance.Parent ~= localPlayer.Character then
				return
			end

			if shouldBlockWhileEquipped() and instance.Parent == localPlayer.Character then
				instance.Parent = localPlayer.Backpack
			end
		end)
	end

	local function bindCharacter(character)
		self._characterJanitor:Cleanup()
		local humanoid = character:WaitForChild("Humanoid", 10)

		if humanoid == nil then
			return
		end

		local animator = humanoid:WaitForChild("Animator", 10)

		if animator == nil then
			return
		end

		self._characterJanitor:Add(animator.AnimationPlayed:Connect(onAnimationPlayed))
	end

	self._Janitor:Add(localPlayer.CharacterAdded:Connect(bindCharacter))

	if localPlayer.Character ~= nil then
		bindCharacter(localPlayer.Character)
	end

	self._Janitor:Add(instance.Equipped:Connect(onEquipped))

	if instance.Parent == localPlayer.Character then
		task.defer(function()
			if instance.Parent ~= localPlayer.Character then
				return
			end

			if shouldBlockWhileEquipped() and instance.Parent == localPlayer.Character then
				instance.Parent = localPlayer.Backpack
			end
		end)
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v