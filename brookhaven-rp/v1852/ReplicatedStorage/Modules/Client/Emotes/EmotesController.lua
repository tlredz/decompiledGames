local EmotesController = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local InteractableItem = require(ReplicatedStorage.Modules.Shared.Item.InteractableItem)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local BackpackVisibilityController = require(ReplicatedStorage.Modules.Client.Player.BackpackVisibilityController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ThrottleEmotes = require(ReplicatedStorage.Modules.Shared.DB.Emotes.ThrottleEmotes)
local ToolEmoteRestrictions = require(ReplicatedStorage.Modules.Shared.DB.Emotes.ToolEmoteRestrictions)
local HideToolsEmotes = require(ReplicatedStorage.Modules.Shared.DB.Emotes.HideToolsEmotes)
local EmotesConfig = require(ReplicatedStorage.Modules.Shared.DB.Emotes.EmotesConfig)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local RichEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.RichEmote)
local SixSevenEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.SixSevenEmote)
local StarDanceEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.StarDanceEmote)
local SkyeDanceEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.SkyeDanceEmote)
local CartwheelEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.CartwheelEmote)
local AngryEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.AngryEmote)
local HeartHandsEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.HeartHandsEmote)
local CryEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.CryEmote)
local LayDownEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.LayDownEmote)
local ThinkingEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.ThinkingEmote)
local TalkingEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.TalkingEmote)
local FlareWaveEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.FlareWaveEmote)
local DinosaurWalkEmote = require(ReplicatedStorage.Modules.Client.Emotes.Scripts.DinosaurWalkEmote)
local AdIntegrationsController = require(ReplicatedStorage.Modules.Client.Ads.AdIntegrationsController)
local v = { "dance" }
local localPlayer = Players.LocalPlayer
local playerGui = nil
local player8Handler = nil
local mainGUIHandler = nil
local menu = nil
local animationStop = nil
local chatAnimationPlaying = nil
local animationPlaying = nil
local v2 = false
local v3 = Signal.new()
local animationString = nil
local track = nil
local v4 = false
local v5 = {}
local v6 = {}
local v7 = nil
local v8 = false
local v9 = true
local v10 = false
local v11 = 0
local v12 = false
local stoppedConnection = nil
local v13 = nil
local tracks = {}
EmotesController.OnAdditiveVfxEnabledChanged = Signal.new()
EmotesController.OnAdditiveVfxToggleVisibleChanged = Signal.new()
local v14 = {
	Rich = RichEmote,
	["67"] = SixSevenEmote,
	["Star Dance"] = StarDanceEmote,
	["Skye's Summer Song"] = SkyeDanceEmote,
	["Cartwheel Move"] = CartwheelEmote,
	Angry = AngryEmote,
	["Heart Hands"] = HeartHandsEmote,
	Cry = CryEmote,
	["Lay Down"] = LayDownEmote,
	Thinking = ThinkingEmote,
	Talking = TalkingEmote,
	["Flare Wave"] = FlareWaveEmote,
	["Dinosaur Walk"] = DinosaurWalkEmote
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isCharacterAdditiveVfxEnabled(instance)
	local emoteAdditiveVfxEnabled = instance:GetAttribute("EmoteAdditiveVfxEnabled")
	return typeof(emoteAdditiveVfxEnabled) ~= "boolean" or emoteAdditiveVfxEnabled
end

local function createAdditiveVfxChangedProxy(object)
	return {
		Connect = function(self, callback)
			return object:GetAttributeChangedSignal("EmoteAdditiveVfxEnabled"):Connect(function()
				callback(isCharacterAdditiveVfxEnabled(object))
			end)
		end
	}
end

local function getAdditiveVfxContext(instance, flag: boolean)
	if flag then
		return {
			isLocalPlayer = true,
			isEnabled = EmotesController.IsAdditiveVfxEnabled,
			onEnabledChanged = EmotesController.OnAdditiveVfxEnabledChanged
		}
	end

	return {
		isLocalPlayer = false,
		isEnabled = function()
			local emoteAdditiveVfxEnabled = instance:GetAttribute("EmoteAdditiveVfxEnabled")
			return typeof(emoteAdditiveVfxEnabled) ~= "boolean" or emoteAdditiveVfxEnabled
		end,
		onEnabledChanged = {
			Connect = function(self, callback)
				return instance:GetAttributeChangedSignal("EmoteAdditiveVfxEnabled"):Connect(function()
					callback(isCharacterAdditiveVfxEnabled(instance))
				end)
			end
		}
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setAdditiveVfxToggleVisible(flag: boolean)
	if v10 == flag then
		return
	end

	v10 = flag
	EmotesController.OnAdditiveVfxToggleVisibleChanged:Fire(v10)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateAdditiveVfxToggleVisible()
	setAdditiveVfxToggleVisible((v8 == true or v12 == true) == true and track ~= nil and track.IsPlaying == true) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCurrentEmoteHasAdditiveVfx(flag: boolean)
	v8 = flag
	updateAdditiveVfxToggleVisible() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateAnimationStopVisible()
	if animationStop == nil then
		return
	end

	animationStop.Visible = v2 or v13 ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCurrentEmoteHasSyncableSound(flag: boolean)
	v12 = flag
	updateAdditiveVfxToggleVisible() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function emoteHasSyncableSound(p)
	return typeof(p.SoundId) == "string" and p.SoundId ~= ""
end

local function getSyncableSound(instance)
	local syncableSound = instance:FindFirstChild("SyncableSound")

	if syncableSound == nil or not syncableSound:IsA("Sound") then
		return nil
	end

	return syncableSound
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroySyncableSound(instance)
	if instance == nil then
		return
	end

	local syncableSound = instance:FindFirstChild("SyncableSound")

	if syncableSound == nil or not syncableSound:IsA("Sound") then
		syncableSound = nil
	end

	if syncableSound ~= nil then
		syncableSound:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applySyncableSoundVolume(character)
	if character == nil then
		return
	end

	local syncableSound = character:FindFirstChild("SyncableSound")

	if syncableSound == nil or not syncableSound:IsA("Sound") then
		syncableSound = nil
	end

	if syncableSound == nil then
		return
	end

	if v9 == true then
		syncableSound.Volume = 0.25
	else
		syncableSound.Volume = 0
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setIsAnimationPlaying(flag: boolean)
	if v2 == flag then
		return
	end

	v2 = flag
	animationPlaying.Value = v2
	v3:Fire(v2)
	updateAnimationStopVisible() -- equivalent call inferred; original call site unknown
end

function EmotesController.IsAdditiveVfxEnabled()
	return v9
end

function EmotesController.IsAdditiveVfxToggleVisible()
	return v10
end

function EmotesController.SetAdditiveVfxEnabled(flag: boolean)
	if v9 == flag then
		return
	end

	v9 = flag
	EmotesController.OnAdditiveVfxEnabledChanged:Fire(v9)
	local character = Players.LocalPlayer.Character

	if character ~= nil then
		character:SetAttribute("EmoteAdditiveVfxEnabled", v9)
	end

	applySyncableSoundVolume(character) -- equivalent call inferred; original call site unknown
	Remotes.fireServer("Emotes:SetAdditiveVfxEnabled", v9)
end

function EmotesController.ToggleAdditiveVfx()
	if v10 == false then
		return
	end

	EmotesController.SetAdditiveVfxEnabled(not v9)
end

function EmotesController.AddAdditiveVfxHotkeyHandler()
	v11 += 1
end

function EmotesController.RemoveAdditiveVfxHotkeyHandler()
	v11 = math.max(v11 - 1, 0)
end

local function updateBackpackVisibility(animator)
	local v15 = true

	for _, v17 in animator:GetPlayingAnimationTracks() do
		if not v17.IsPlaying then
			continue
		end

		local animationId = v17.Animation.AnimationId
		local v18 = string.match(animationId, "%d+")
		local name = EmotesConfig.GetNameFromId(v18)

		if not (name and HideToolsEmotes.ContainsEmote(name)) then
			continue
		end

		v15 = false
		break
	end

	BackpackVisibilityController.SetVisibility(v15, "EmotesController")

	if not v15 then
		warn("Backpack is hidden due to the currently playing emote")
	end
end

local function stopEmote()
	local localPlayer2 = Players.LocalPlayer
	local character = localPlayer2.Character
	local humanoid = character:WaitForChild("Humanoid")
	destroySyncableSound(character) -- equivalent call inferred; original call site unknown

	if humanoid:HasTag("HumanoidSyncableEmote") then
		EmotesController.StopSyncableEmote()
	end

	setCurrentEmoteHasAdditiveVfx(false) -- equivalent call inferred; original call site unknown
	setCurrentEmoteHasSyncableSound(false) -- equivalent call inferred; original call site unknown
	AdIntegrationsController.NotifyEmoteChanged(nil)

	if stoppedConnection ~= nil then
		stoppedConnection:Disconnect()
		stoppedConnection = nil
	end

	if not v4 then
		v4 = true
		local isOpen = PanelController.IsOpen("NoResetGUIHandler", "AvatarEditorMenu")

		if not (localPlayer2.Character:FindFirstChild("NoMotorVehicleModel") or isOpen) then
			character.Humanoid.WalkSpeed = 16
		end

		setIsAnimationPlaying(false) -- equivalent call inferred; original call site unknown
		chatAnimationPlaying.Value = false
		local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in playingAnimationTracks do
			if playingAnimationTrack.Name == "LocalAnimation" then
				playingAnimationTrack:Stop()
			end
		end

		task.wait(0.5)
		v4 = false
	end

	updateBackpackVisibility(humanoid:WaitForChild("Animator"))
	updateAdditiveVfxToggleVisible() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function adjustAnimationPriority(tool, instance)
	local containsTool = ToolEmoteRestrictions.ContainsTool(tool.Name)
	local originalPriority = instance:GetAttribute("OriginalPriority")

	if containsTool then
		instance:SetAttribute("OriginalPriority", instance.Priority)
		instance.Priority = Enum.AnimationPriority.Action3
	elseif originalPriority then
		instance.Priority = originalPriority
	end
end

local function playEmote(data, timePosition: number?, flag: boolean?)
	local localPlayer2 = Players.LocalPlayer
	local character = localPlayer2.Character
	local humanoid = character:WaitForChild("Humanoid")
	destroySyncableSound(character) -- equivalent call inferred; original call site unknown

	if humanoid:HasTag("HumanoidSyncableEmote") then
		EmotesController.StopSyncableEmote()
	end

	if v5[data.Name] then
		Remotes.fireServer("t_animationThrottled", data.Name)
		return
	end

	if ThrottleEmotes.ContainsEmote(data.Name) then
		v5[data.Name] = true
		task.delay(2, function()
			v5[data.Name] = nil
		end)
	end

	if character == nil or humanoid == nil then
		return
	end

	local animationId = "rbxassetid://" .. tostring(data.Id)

	if animationString == animationId then
		if track ~= nil and track.IsPlaying then
			if flag then
				return
			end

			local isOpen = PanelController.IsOpen("NoResetGUIHandler", "AvatarEditorMenu")
			track:Stop()
			setIsAnimationPlaying(false) -- equivalent call inferred; original call site unknown
			setCurrentEmoteHasAdditiveVfx(false) -- equivalent call inferred; original call site unknown
			setCurrentEmoteHasSyncableSound(false) -- equivalent call inferred; original call site unknown
			AdIntegrationsController.NotifyEmoteChanged(nil)

			if not isOpen then
				character.Humanoid.WalkSpeed = 16
			end

			animationString = "Restart"
			updateBackpackVisibility(humanoid:WaitForChild("Animator"))
			return
		end
	else
		animationString = animationId
	end

	if track ~= nil then
		track:Stop()
		character.Humanoid.WalkSpeed = 16
		setIsAnimationPlaying(false) -- equivalent call inferred; original call site unknown
		setCurrentEmoteHasAdditiveVfx(false) -- equivalent call inferred; original call site unknown
		setCurrentEmoteHasSyncableSound(false) -- equivalent call inferred; original call site unknown

		if v7 and ThrottleEmotes.ContainsEmote(v7.Name) and v7.Name ~= data.Name then
			local name = v7.Name
			v5[name] = true
			task.delay(2, function()
				v5[name] = nil
			end)
		end
	end

	local animator = localPlayer2.Character.Humanoid:FindFirstChild("Animator")

	if tracks[animationId] == nil then
		local animation = Instance.new("Animation")
		animation.Name = "LocalAnimation"
		animation.AnimationId = animationId
		track = animator:LoadAnimation(animation)
		tracks[animationId] = track
	else
		track = tracks[animationId]
	end

	if stoppedConnection ~= nil then
		stoppedConnection:Disconnect()
		stoppedConnection = nil
	end

	local v16 = track
	stoppedConnection = track.Stopped:Connect(function()
		if track ~= v16 then
			return
		end

		destroySyncableSound(character) -- equivalent call inferred; original call site unknown
		setCurrentEmoteHasAdditiveVfx(false) -- equivalent call inferred; original call site unknown
		setCurrentEmoteHasSyncableSound(false) -- equivalent call inferred; original call site unknown
	end)
	local tool = character:FindFirstChildOfClass("Tool")

	if tool then
		adjustAnimationPriority(tool, track) -- equivalent call inferred; original call site unknown
	end

	track:Play()
	setCurrentEmoteHasAdditiveVfx(data.VFXToggle == true) -- equivalent call inferred; original call site unknown
	setCurrentEmoteHasSyncableSound(emoteHasSyncableSound(data)) -- equivalent call inferred; original call site unknown
	AdIntegrationsController.NotifyEmoteChanged(data.Name)

	if timePosition then
		track.TimePosition = timePosition
	end

	setIsAnimationPlaying(true) -- equivalent call inferred; original call site unknown
	local v18

	if typeof(data.SoundId) == "string" then
		v18 = data.SoundId ~= ""
	else
		v18 = false
	end

	if v18 then
		local sound = Instance.new("Sound")
		sound.Name = "SyncableSound"
		sound.SoundId = data.SoundId
		sound.Volume = v9 == true and 0.25 or 0
		sound.Parent = character
		sound.Looped = true

		repeat
			task.wait()
		until track.Length > 0

		sound.PlaybackRegionsEnabled = true
		sound.LoopRegion = NumberRange.new(data.SoundLoopStartMark + 1, data.SoundLoopStartMark + track.Length + 1)
		sound.TimePosition = data.SoundLoopStartMark + (timePosition or 0)
		sound:Play()
	end

	if data.Repeat then
		EmotesController.PlaySyncableEmote(data)
	end

	if data.Speed == true then
		character.Humanoid.WalkSpeed = 6
	end

	local v19 = v14[data.Name]

	if v19 then
		local v20 = v19.new()
		local parent = humanoid.Parent
		local v21 = track
		local _ = humanoid.Parent
		v20:start(parent, v21, {
			isLocalPlayer = true,
			isEnabled = EmotesController.IsAdditiveVfxEnabled,
			onEnabledChanged = EmotesController.OnAdditiveVfxEnabledChanged
		})
	end

	v16.Stopped:Once(function()
		if v2 == false then
			return
		end

		v2 = false
		animationPlaying.Value = v2
		v3:Fire(v2)
		updateAnimationStopVisible() -- equivalent call inferred; original call site unknown
	end)
	v7 = data
	Remotes.fireServer("t_animationPlayed", data.Name)
	return track
end

local function checkExternalEmotes(instance)
	local animation = instance.Animation
	local parent = animation.Parent
	local tool = Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")

	if not tool then
		return
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local animate = character:FindFirstChild("Animate")

	if parent and animate and parent:IsDescendantOf(animate) then
		for _, v15 in v do
			if not parent.Name:find(v15) then
				continue
			end

			adjustAnimationPriority(tool, instance) -- equivalent call inferred; original call site unknown
		end
	end

	local v15 = string.match(animation.AnimationId, "%d+")

	for k in v6 do
		if v15 ~= string.match(k, "%d+") then
			continue
		end

		adjustAnimationPriority(tool, instance) -- equivalent call inferred; original call site unknown
	end
end

local function characterAdded(character)
	character:SetAttribute("EmoteAdditiveVfxEnabled", v9)
	Remotes.fireServer("Emotes:SetAdditiveVfxEnabled", v9)
	local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")
	character.ChildAdded:Connect(function(tool)
		if not tool:IsA("Tool") then
			return
		end

		for _, v15 in animator:GetPlayingAnimationTracks() do
			checkExternalEmotes(v15)
		end

		if not track then
			return
		end

		adjustAnimationPriority(tool, track) -- equivalent call inferred; original call site unknown
	end)
	animator.AnimationPlayed:Connect(function(p)
		checkExternalEmotes(p)
		updateBackpackVisibility(animator)
	end)
end

local function characterRemoving(_)
	stopEmote()
	tracks = {}
	setCurrentEmoteHasAdditiveVfx(false) -- equivalent call inferred; original call site unknown
	setCurrentEmoteHasSyncableSound(false) -- equivalent call inferred; original call site unknown
end

function EmotesController.ExternalEmotePlayed(instance)
	local tool = Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")

	if tool then
		adjustAnimationPriority(tool, instance) -- equivalent call inferred; original call site unknown
	end
end

function EmotesController.RegisterExternalEmote(p: string)
	v6[p] = true
end

function EmotesController.IsPlayingEmote()
	local isPlaying = v2

	if not isPlaying then
		if track == nil then
			isPlaying = false
		else
			isPlaying = track.IsPlaying
		end
	end

	return isPlaying
end

function EmotesController.HasExternalCancelHandler()
	return v13 ~= nil
end

function EmotesController.PlaySyncableEmote(p, p2: string?)
	Remotes.fireServer("Emotes:PlaySyncableEmote", p, p2)
end

function EmotesController.StopSyncableEmote()
	Remotes.fireServer("Emotes:StopSyncableEmote")
end

function EmotesController.PlayEmote(data, p, timePosition: number?, flag: boolean?)
	if not (animationString and EmotesController.CanPlayEmote()) then
		return
	end

	if not p then
		return playEmote(data, timePosition, flag)
	end

	local item = data.Item
	local item2 = ItemRegistry.GetItem(item, InteractableItem)

	if item2 ~= nil and not item2:IsUnlockedClient() then
		item2:OnDenied(NotificationController.NotifyCenter, "EmotesMenu", function()
			if EmotesController.CanPlayEmote() then
				playEmote(data, timePosition, flag)
			end
		end)
		return false
	end

	if data.IsVip and p then
		local formatted = `Emote_${data.Name}`

		if not UnlockableController.IsFeatureUnlocked(formatted, Gamepasses.VIP) then
			GamepassController.Show(Gamepasses.VIP, nil, "emote", nil, {
				id = formatted,
				icon = "rbxassetid://5084437490"
			}, nil, "Emotes Inventory", data.Name, function()
				if EmotesController.CanPlayEmote() then
					playEmote(data, timePosition, flag)
				end
			end)
			return false
		end
	end

	return playEmote(data, timePosition, flag)
end

local v15 = {}

local function serverCharacterAdded(character)
	if Players:GetPlayerFromCharacter(character) == Players.LocalPlayer then
		return
	end

	local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")
	local connections = v15[character] or {}
	table.insert(connections, (animator.AnimationPlayed:Connect(function(p)
		local animationId = p.Animation.AnimationId
		local v16 = string.match(animationId, "%d+")
		local v17 = v14[EmotesConfig.GetNameFromId(v16)]

		if v17 then
			local v19 = character
			v17.new():start(character, p, {
				isLocalPlayer = false,
				isEnabled = function()
					local emoteAdditiveVfxEnabled = v19:GetAttribute("EmoteAdditiveVfxEnabled")
					return typeof(emoteAdditiveVfxEnabled) ~= "boolean" or emoteAdditiveVfxEnabled
				end,
				onEnabledChanged = {
					Connect = function(self, callback)
						return v19:GetAttributeChangedSignal("EmoteAdditiveVfxEnabled"):Connect(function()
							callback(isCharacterAdditiveVfxEnabled(v19))
						end)
					end
				}
			})
		end
	end)))
	v15[character] = connections

	for _, v16 in animator:GetPlayingAnimationTracks() do
		local animationId = v16.Animation.AnimationId
		local v17 = string.match(animationId, "%d+")
		local v18 = v14[EmotesConfig.GetNameFromId(v17)]

		if v18 then
			v18.new():start(character, v16, {
				isLocalPlayer = false,
				isEnabled = function()
					local emoteAdditiveVfxEnabled = character:GetAttribute("EmoteAdditiveVfxEnabled")
					return typeof(emoteAdditiveVfxEnabled) ~= "boolean" or emoteAdditiveVfxEnabled
				end,
				onEnabledChanged = {
					Connect = function(self, callback)
						return character:GetAttributeChangedSignal("EmoteAdditiveVfxEnabled"):Connect(function()
							callback(isCharacterAdditiveVfxEnabled(character))
						end)
					end
				}
			})
		end
	end
end

local function serverCharacterRemoving(p)
	local v16 = v15[p]

	if v16 ~= nil then
		for _, connection in v16 do
			connection:Disconnect()
		end

		v15[p] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playerAdded(player)
	player.CharacterAdded:Connect(serverCharacterAdded)
	player.CharacterRemoving:Connect(serverCharacterRemoving)

	if player.Character then
		serverCharacterAdded(player.Character)
	end
end

function EmotesController.StopEmote()
	if EmotesController.IsPlayingEmote() or v13 == nil then
		EmotesController.StopSyncableEmote()
		stopEmote()
	else
		local v16 = v13
		v13 = nil
		updateAnimationStopVisible() -- equivalent call inferred; original call site unknown
		v16()
	end
end

function EmotesController.CanPlayEmote()
	local localPlayer2 = Players.LocalPlayer
	local character = localPlayer2.Character

	if not character then
		return false
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid or humanoid.Sit or humanoid.WalkSpeed <= 1 or localPlayer2.Character:FindFirstChild("NoMotorVehicleModel") then
		return false
	end

	if localPlayer2.Character:FindFirstChild("ClientToClient") or v13 ~= nil or character:FindFirstChild(localPlayer2.Name .. "Horse") then
		return false
	end

	local waitingForReplyPiggy = player8Handler:FindFirstChild("WaitingForReplyPiggy")
	return not (waitingForReplyPiggy and waitingForReplyPiggy.Value)
end

function EmotesController.SetExternalCancelHandler(callback)
	v13 = callback
	updateAnimationStopVisible() -- equivalent call inferred; original call site unknown
end

function EmotesController.ClearExternalCancelHandler(callback)
	if v13 ~= callback then
		return
	end

	v13 = nil
	updateAnimationStopVisible() -- equivalent call inferred; original call site unknown
end

function EmotesController.FrameworkInit() end

function EmotesController.FrameworkStart()
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	player8Handler = playerGui:WaitForChild("Player8Handler")
	mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")
	menu = mainGUIHandler:WaitForChild("Menu")
	animationStop = menu:WaitForChild("AnimationStop")
	chatAnimationPlaying = player8Handler:WaitForChild("ChatAnimationPlaying")
	animationPlaying = player8Handler:WaitForChild("AnimationPlaying")
	animationString = player8Handler:WaitForChild("AnimationString")
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.E and v11 <= 0 then
			EmotesController.ToggleAdditiveVfx()
		elseif input.KeyCode == Enum.KeyCode.Q and (EmotesController.IsPlayingEmote() or v13 ~= nil) then
			EmotesController.StopEmote()
		end
	end)
	localPlayer.CharacterAdded:Connect(characterAdded)
	v3:Connect(updateAnimationStopVisible)
	localPlayer.CharacterRemoving:Connect(function()
		if v2 == false then
			return
		end

		v2 = false
		animationPlaying.Value = v2
		v3:Fire(v2)
		updateAnimationStopVisible() -- equivalent call inferred; original call site unknown
	end)
	updateAdditiveVfxToggleVisible() -- equivalent call inferred; original call site unknown
	localPlayer.CharacterRemoving:Connect(characterRemoving)
	localPlayer.CharacterAdded:Connect(characterAdded)

	if localPlayer.Character then
		characterAdded(localPlayer.Character)
	end

	Players.PlayerAdded:Connect(playerAdded)

	for _, v16 in Players:GetPlayers() do
		playerAdded(v16) -- equivalent call inferred; original call site unknown
	end

	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local CharacterBodyController = require(ReplicatedStorage2.Modules.Client.AvatarEditor.CharacterBodyController)
	local AvatarEditorController = require(ReplicatedStorage2.Modules.Client.AvatarEditor.AvatarEditorController)
	CharacterBodyController.OnBodySizeChanged:Connect(stopEmote)
	AvatarEditorController.OnResetCharacterAppearance:Connect(stopEmote)
	local VehicleController = require(ReplicatedStorage2.Modules.Client.Vehicles.VehicleController)
	VehicleController.OnPlayerStartedDriving:Connect(function()
		EmotesController.StopEmote()
	end)
	VehicleController.OnPlayerStartedDrivingLegacy:Connect(function()
		EmotesController.StopEmote()
	end)
	Remotes.connect("Emotes:PlayEmote", function(p: string)
		local v16 = EmotesConfig.GetFromName(p)

		if v16 then
			playEmote(v16)
		end
	end)
	Remotes.connect("Emotes:StopEmote", function(p: string)
		if EmotesConfig.GetFromName(p) then
			stopEmote()
		end
	end)
end

return EmotesController