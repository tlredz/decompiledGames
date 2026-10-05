local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(script.EmoteEffects)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Packages.Observers)
local v5 = require3(ReplicatedStorage2.Shared.DynArgs)
require3(ReplicatedStorage2.ServerInfo)
local v6 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Shared.WeightRandom)
local v7 = require3(ReplicatedStorage2.Shared.FreezeSwordConstraints)
local v8 = require3(ReplicatedStorage2.Shared.EmotesShared)
local v9 = require3(ReplicatedStorage2.Shared.AbilityUtils)
local v10 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v11 = require3(ReplicatedStorage2.Common.Utils)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local localPlayer = Players.LocalPlayer
RunService:IsStudio()
local moonliteEmotes = ReplicatedStorage2.Misc.MoonliteEmotes
local v12 = {
	"Emote1",
	"Emote2",
	"Emote3",
	"Emote4",
	"Emote5",
	"Emote6",
	"Emote7"
}
local v13 = v5.Or()
local customEmote = ReplicatedStorage2.Remotes.CustomEmote

local function RequestCustomEmote(...)
	customEmote:FireServer(...)
end

local EmoteController = {
	_playAnimation = function(self, p)
		if not (self._character and self._character:IsDescendantOf(workspace) and self._humanoid and self._animator) then
			return
		end

		self._humanoid:ChangeState(Enum.HumanoidStateType.Running)
		local animationTrackForAnimator = v8:GetAnimationTrackForAnimator(self._animator, self._characterTrove, p)

		if animationTrackForAnimator then
			animationTrackForAnimator:Play()
		end

		self._currentTrack = animationTrackForAnimator
	end
}
local v14 = {
	"Dual Bloodline Scythe Emote",
	"Dual Runic Blade Emote",
	"Firebloom Scythe Emote",
	"Dual Firebloom Blade",
	"Dual Leviathan Set Emote",
	"Dual Monarch Blade Emote",
	"Dual Lightning Dagger Emote",
	"Dual Void Scythes Emote",
	"Moon Walk Emote",
	"Victory Skipping (Sakura Scythe)",
	"Dual Azurethron Emote",
	"Dual Shadow Monarch Blade Emote"
}

function EmoteController:Play(currentEmote, emoteSlot, p)
	if not currentEmote or not self._character or not self._character:IsDescendantOf(workspace) or self._character:GetAttribute("DoNotPlayEmote") or not self._humanoid then
		return
	end

	if self._humanoid.MoveDirection.Magnitude > 0 then
		return
	end

	if self._currentEmote then
		self:Stop()
	end

	if self._character:GetAttribute("Ability") == "Platform" then
		_G.SendNotification("Cannot use emotes while Platform ability is active!", 3)
		self:Stop()
	else
		if v13.CurrentState then
			_G.SendNotification("Emotes are disabled!", 3)
			return
		end

		local v15 = v10.Emote[currentEmote]

		if self._character.Parent == workspace.Alive and (table.find(v14, currentEmote) or v15 and table.find(
			v14,
			v15.Name
		)) then
			_G.SendNotification("This emote is disabled during matches!", 4)
			return
		end

		local fFlag = v11.FFlag.GetFFlag("DisabledEmotes", {})

		if table.find(fFlag, currentEmote) or v15 and table.find(fFlag, v15.Name) then
			_G.SendNotification("This emote is temporarily disabled!", 3)
			return
		end

		local now = os.clock()

		if now - self._lastEmote < 0.4 and not table.find(v12, currentEmote) then
			return
		end

		v9.setPlaying(currentEmote, true)
		self._lastEmote = now
		self._currentEmote = currentEmote
		self._emoteSlot = emoteSlot
		self._character:SetAttribute("Emoting", currentEmote)

		if table.find(v12, currentEmote) then
			self:_playAnimation(currentEmote)
		else
			RequestCustomEmote(true, currentEmote, p or workspace:GetServerTimeNow(), emoteSlot)
		end
	end
end

function EmoteController:Stop()
	if self._character then
		self._character:SetAttribute("Emoting", nil)
	end

	if self._currentTrack and self._currentTrack.IsPlaying then
		self._currentTrack:Stop()
		self._currentTrack = nil
	end

	if not self._currentEmote then
		return
	end

	v9.setPlaying(self._currentEmote, nil)
	RequestCustomEmote(false, self._currentEmote, workspace:GetServerTimeNow())
	self._currentEmote = nil
	self._emoteSlot = nil
end

function EmoteController:_startMusicEmoteSync()
	local v15 = {}

	local function isOwnedMusicEmote(childName: string)
		return moonliteEmotes:FindFirstChild(childName) ~= nil and #client:FindItems("Emote", childName) > 0
	end

	local function isSyncedWithLocalPlayer(p: string, p2: number)
		local character = localPlayer.Character

		if not (character and character:IsDescendantOf(workspace)) then
			return false
		end

		return character:GetAttribute("CurrentEmote") == p and character:GetAttribute("CurrentEmoteTime") == p2
	end

	local function refreshAllPrompts()
		for _, v16 in v15 do
			v16()
		end
	end

	self._syncTrove:Add(v4.observeCharacters(function(p, instance)
		if p == localPlayer then
			local maid = v3.new()
			maid:Add(instance:GetAttributeChangedSignal("CurrentEmote"):Connect(refreshAllPrompts))
			maid:Add(instance:GetAttributeChangedSignal("CurrentEmoteTime"):Connect(refreshAllPrompts))
			task.defer(refreshAllPrompts)
			return function()
				maid:Destroy()
				task.defer(refreshAllPrompts)
			end
		else
			local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 5)

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				return nil
			end

			local maid = v3.new()
			local maid2 = v3.new()
			maid:Add(maid2)
			local refreshPrompt

			refreshPrompt = function()
				maid2:Clean()
				local currentEmote = instance:GetAttribute("CurrentEmote")
				local currentEmoteTime = instance:GetAttribute("CurrentEmoteTime")

				if type(currentEmote) == "string" and type(currentEmoteTime) == "number" then
					local v16

					if moonliteEmotes:FindFirstChild(currentEmote) == nil then
						v16 = false
					else
						v16 = #client:FindItems("Emote", currentEmote) > 0
					end

					if v16 then
						local character = localPlayer.Character
						local v17

						if character and character:IsDescendantOf(workspace) and character:GetAttribute("CurrentEmote") == currentEmote then
							v17 = character:GetAttribute("CurrentEmoteTime") == currentEmoteTime
						else
							v17 = false
						end

						if v17 then
							return
						end

						local proximityPrompt = Instance.new("ProximityPrompt")
						proximityPrompt.Name = "MusicEmoteSyncPrompt"
						proximityPrompt.ActionText = "Sync"
						proximityPrompt.ObjectText = ""
						proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
						proximityPrompt.HoldDuration = 0
						proximityPrompt.MaxActivationDistance = 10
						proximityPrompt.RequiresLineOfSight = false
						proximityPrompt.Parent = humanoidRootPart
						maid2:Add(proximityPrompt)
						maid2:Add(proximityPrompt.Triggered:Connect(function()
							local currentEmote2 = instance:GetAttribute("CurrentEmote")
							local currentEmoteTime2 = instance:GetAttribute("CurrentEmoteTime")

							if type(currentEmote2) == "string" and currentEmote2 == currentEmote and type(currentEmoteTime2) == "number" then
								local v18

								if moonliteEmotes:FindFirstChild(currentEmote2) == nil then
									v18 = false
								else
									v18 = #client:FindItems("Emote", currentEmote2) > 0
								end

								if v18 then
									local character2 = localPlayer.Character
									local v19

									if character2 and character2:IsDescendantOf(workspace) and character2:GetAttribute("CurrentEmote") == currentEmote2 then
										v19 = character2:GetAttribute("CurrentEmoteTime") == currentEmoteTime2
									else
										v19 = false
									end

									if v19 then
										task.defer(refreshPrompt)
									else
										self:Play(currentEmote, nil, currentEmoteTime2)
									end

									return
								end
							end

							task.defer(refreshPrompt)
						end))
					end
				end
			end

			v15[instance] = refreshPrompt
			maid:Add(function()
				v15[instance] = nil
			end)
			maid:Add(instance:GetAttributeChangedSignal("CurrentEmote"):Connect(refreshPrompt))
			maid:Add(instance:GetAttributeChangedSignal("CurrentEmoteTime"):Connect(refreshPrompt))
			refreshPrompt()
			return function()
				maid:Destroy()
			end
		end
	end))
	local v16 = client:OnChange("Emote", function(p)
		local name = p and p.Name

		if type(name) == "string" and moonliteEmotes:FindFirstChild(name) then
			for _, v17 in v15 do
				v17()
			end
		end
	end)

	if v16 then
		self._syncTrove:Add(v16)
	end
end

function EmoteController:Init()
	self._lastEmote = 0
	self._characterTrove = v3.new()
	self._syncTrove = v3.new()
	self._animationTracks = {}
	v13.StateChanged:Connect(function(flag: boolean)
		if flag then
			self:Stop()
		end
	end)
	ReplicatedStorage2.Remotes.DisableEmote.OnClientEvent:Connect(function()
		if self._currentEmote then
			self:Stop()
		end
	end)
end

function EmoteController:Start()
	local function playEmoteEffects(p: string, ...)
		if not v2[p] then
			warn((`Failed to find EmoteEffect for {p}`))
			return
		end

		local success, result = pcall(function(...)
			return v2[p](...)
		end, ...)

		if not success then
			warn(`EmoteEffect failed for {p}:`, result)
		end
	end

	v:Connect("PlayEmoteEffects", playEmoteEffects)
	v8:SetGetNearestCharacterToDuo(function(instance, _: string, _: string)
		local nearestDuo = instance:FindFirstChild("NearestDuo")

		if nearestDuo and nearestDuo:IsA("ObjectValue") then
			return nearestDuo.Value
		end

		return nil
	end)
	v8:SetPlayEmoteEffects(function(_, ...)
		return playEmoteEffects(...)
	end)
	localPlayer:GetAttributeChangedSignal("UsingTitanBlade"):Connect(function()
		self:Stop()
	end)

	local function characterAdded(character)
		self._characterTrove:Clean()
		table.clear(self._animationTracks)
		self._character = character
		local humanoid = character:WaitForChild("Humanoid")
		self._humanoid = humanoid
		self._animator = humanoid:WaitForChild("Animator")
		local head = character:WaitForChild("Head", 5)
		local torso = character:WaitForChild("Torso", 5)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
		self._characterTrove:Add(RunService.PreSimulation:Connect(function()
			if torso then
				torso.CanCollide = false
			end

			if head then
				head.CanCollide = false
			end

			if humanoidRootPart then
				humanoidRootPart.CanCollide = true
			end
		end))
		self._characterTrove:Add(humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			if humanoid.MoveDirection ~= createVector(0, 0, 0) and self._currentEmote then
				self:Stop()
			end
		end))
		v13:SetTag("InFinisher", character:GetAttribute("InFinisher") ~= nil)
		self._characterTrove:Add(character:GetAttributeChangedSignal("InFinisher"):Connect(function()
			v13:SetTag("InFinisher", character:GetAttribute("InFinisher") ~= nil)
		end))
		v13:SetTag("InOverdriveMech", character:GetAttribute("InOverdriveMech") ~= nil)
		self._characterTrove:Add(character:GetAttributeChangedSignal("InOverdriveMech"):Connect(function()
			v13:SetTag("InOverdriveMech", character:GetAttribute("InOverdriveMech") ~= nil)
		end))
		self._characterTrove:Add(character:GetAttributeChangedSignal("AbilityActive"):Connect(function()
			local abilityActive = character:GetAttribute("AbilityActive")

			if not abilityActive then
				v13:SetTag("AbilityActive", false)
				return
			end

			local ability = abilityActive and character:GetAttribute("Ability")

			if ability == "Platform" or ability == "Bunny Leap" then
				v13:SetTag("AbilityActive", true)

				if self._currentEmote then
					self:Stop()
				end
			else
				v13:SetTag("AbilityActive", false)
			end
		end))
		local v15 = nil
		self._characterTrove:Add(character:GetAttributeChangedSignal("Emoting"):Connect(function()
			if v15 then
				v15()
			end

			if character:GetAttribute("Emoting") ~= nil then
				v15 = v7(localPlayer)
			end
		end))
		self._characterTrove:Add(character.AncestryChanged:Connect(function()
			if not character:IsDescendantOf(workspace) then
				self:Stop()
				self._character = nil
			end
		end))
	end

	localPlayer.CharacterAdded:Connect(characterAdded)

	if localPlayer.Character then
		task.spawn(characterAdded, localPlayer.Character)
	end

	self._syncTrove:Add(task.spawn(function()
		if not localPlayer:GetAttribute("IsInventoryLoaded") then
			localPlayer:GetAttributeChangedSignal("IsInventoryLoaded"):Wait()
		end

		if localPlayer:IsDescendantOf(Players) then
			self:_startMusicEmoteSync()
		end
	end))
	local v15 = v6.Client:WaitReplion("Data")

	if not v15 then
		return
	end

	local function updateCinematicEmoteCamera()
		localPlayer:SetAttribute("UseCinematicEmoteCamera", v15:Get("Settings.Misc.Cinematic Emote Camera.Enabled"))
	end

	v15:OnChange("Settings.Misc.Cinematic Emote Camera.Enabled", updateCinematicEmoteCamera)
	task.defer(updateCinematicEmoteCamera)
end

return EmoteController