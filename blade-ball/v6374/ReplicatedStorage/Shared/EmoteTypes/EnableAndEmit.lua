local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteVFX)
local v2 = require3(ReplicatedStorage2.Packages.Serialization)
local v3 = require3(ReplicatedStorage2.Packages.Squash)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
require3(script.Parent.Utils.Types)
local v5 = require3(script.Parent.Utils.Visual)
local v6

if RunService:IsClient() then
	v6 = require3(ReplicatedStorage2.Packages.Moonlite)
else
	v6 = nil
end

local moonliteEmotesByName = {}
local v7 = {}

local function refreshDanceSoundGroup(items)
	local userId = 1e999
	local v8 = nil

	for k, item in items do
		if not (item.Player.Character == k and k:IsDescendantOf(workspace) and item.Player.UserId < userId) then
			continue
		end

		userId = item.Player.UserId
		v8 = k
	end

	for k, item in items do
		if k ~= v8 then
			item.SetAudible(false)
		end
	end

	if v8 then
		items[v8].SetAudible(true)
	end
end

local v8 = {
	Emote915 = {
		SoundId = "rbxassetid://121746225545509",
		SoundStartFrame = 39
	},
	Emote1017 = {
		SoundId = "rbxassetid://122138306164149",
		SoundStartFrame = 0,
		Serialized = true
	},
	Emote1052 = {
		SoundId = "rbxassetid://86553108866816",
		SoundStartFrame = 0,
		Serialized = true
	},
	Emote1167 = {
		SoundId = "rbxassetid://78966882139691",
		SoundStartFrame = 0,
		Serialized = true
	},
	Emote1185 = {
		SoundId = "rbxassetid://73110745626575",
		SoundStartFrame = 0,
		Serialized = true
	},
	Emote1217 = {
		SoundId = "rbxassetid://107342460864353",
		SoundStartFrame = 200,
		Serialized = true,
		UseCompiledCache = true
	},
	Emote1249 = {
		SoundId = "rbxassetid://116434124565906",
		SoundStartFrame = 0,
		Serialized = true
	},
	Emote1272 = {
		SoundId = "rbxassetid://110933723446185",
		SoundStartFrame = 5,
		Serialized = true,
		Events = require3(script.Parent.Emote1272Events)
	}
}
return function(p, instance, p2, items, flag: boolean?, p3: number?)
	if not p2 then
		return nil
	end

	local emoteVFX_Storage = instance:FindFirstChild("EmoteVFX_Storage")

	if not emoteVFX_Storage then
		return nil
	end

	local maid = v4.new()
	local instance2 = type(p.VFX) == "string" and v:GetInstance(p.VFX)

	if not instance2 then
		if typeof(p.VFX) == "Instance" then
			instance2 = p.VFX or nil
		else
			instance2 = nil
		end
	end

	if instance2 then
		v5.play(instance, maid, emoteVFX_Storage, instance2)
	end

	if p.Emote.Name == "Emote514" and p2 then
		local transparenciesByFolder = {}
		maid:Add(task.delay(0.8833333333333333, function()
			local walk

			walk = function(items2)
				for _, folder in items2 do
					if folder:IsA("BasePart") and folder.Transparency == 0 and not folder:GetAttribute("EMOTE_HIDDEN_DEFAULT") then
						folder:SetAttribute("EMOTE_HIDDEN_DEFAULT", folder.Transparency)
						transparenciesByFolder[folder] = folder.Transparency
						folder.Transparency = 0.75
					elseif folder:IsA("Accoutrement") then
						walk(folder:GetDescendants())
					end
				end
			end

			walk(instance:GetChildren())
		end))

		local function showPlayer()
			for k in transparenciesByFolder do
				if not k:GetAttribute("EMOTE_HIDDEN_DEFAULT") then
					continue
				end

				k.Transparency = k:GetAttribute("EMOTE_HIDDEN_DEFAULT")
				k:SetAttribute("EMOTE_HIDDEN_DEFAULT", nil)
			end

			table.clear(transparenciesByFolder)
		end

		maid:Add(task.delay(3.1, showPlayer))
		maid:Add(showPlayer)
	elseif (p.Emote.Name ~= "Emote594" or not p2) and v8[p.Emote.Name] ~= nil and p2 and v6 then
		local v9 = v8[p.Emote.Name]
		local moonliteEmote = ReplicatedStorage2.Misc.MoonliteEmotes[p.Emote.Name]

		if v9.Serialized then
			moonliteEmote = moonliteEmotesByName[p.Emote.Name] or v2.des(v3.frombuffer(HttpService:JSONDecode(require3(moonliteEmote))))
			moonliteEmotesByName[p.Emote.Name] = moonliteEmote
		end

		debug.profilebegin("CreatePlayer")
		local player = v6.CreatePlayer(moonliteEmote, emoteVFX_Storage)
		player.Looped = true
		debug.profilebegin("Compile")
		player:Compile()
		debug.profileend()
		local timeLength = player:GetTimeLength()
		local timePosition = math.clamp(v9.SoundStartFrame / player.FrameRate, 0, timeLength)
		local v11 = p3 or workspace:GetServerTimeNow()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getElapsedTime()
			return (math.max(0, workspace:GetServerTimeNow() - v11))
		end

		local function getPlaybackPosition()
			if timeLength <= 0 then
				return 0
			end

			local elapsedTime = getElapsedTime() -- equivalent call inferred; original call site unknown

			if elapsedTime < timeLength then
				return elapsedTime
			end

			local v12 = timeLength - timePosition

			if v12 > 0 then
				return timePosition + (elapsedTime - timeLength) % v12
			end

			return (math.max(0, timeLength - 1 / player.FrameRate))
		end

		local timePosition2

		if timeLength <= 0 then
			timePosition2 = 0
		else
			timePosition2 = math.max(0, workspace:GetServerTimeNow() - v11)

			if not (timePosition2 < timeLength) then
				local v13 = timeLength - timePosition

				if v13 > 0 then
					timePosition2 = timePosition + (timePosition2 - timeLength) % v13
				else
					timePosition2 = math.max(0, timeLength - 1 / player.FrameRate)
				end
			end
		end

		player.TimePosition = timePosition2
		player.CurrentFrame = math.floor(timePosition2 * player.FrameRate)
		player:Play()
		local events = v9.Events and v9.Events.new(instance, emoteVFX_Storage)

		if events then
			events:Start(player)
			maid:Add(function()
				events:Destroy()
			end)
		end

		debug.profileend()

		if type(items) == "table" then
			if p.Emote.Name == "Emote1217" then
				timePosition2 = math.max(0, workspace:GetServerTimeNow() - v11)
			end

			for _, item in items do
				if item.Length > 0 then
					item.TimePosition = timePosition2 % item.Length
				end
			end
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
		local v13 = not (instance:HasTag("LobbyNPC") or flag)
		local v14 = false
		maid:Add(function()
			v14 = false
		end)
		local soundInitialTimePosition = v9.SoundInitialTimePosition or 0
		local volume = not v13 and 0 or p.Emote.Name == "Emote1167" and 6 or 1
		local sound = Instance.new("Sound")
		sound.Name = "Sound"
		sound.SoundId = v9.SoundId
		sound.SoundGroup = game.SoundService.SFX
		sound.Looped = true
		sound.RollOffMode = Enum.RollOffMode.InverseTapered
		sound.RollOffMaxDistance = 500
		sound.Volume = volume
		local parent

		if instance:IsDescendantOf(workspace.CurrentCamera) then
			parent = SoundService
		else
			parent = instance:FindFirstChild("HumanoidRootPart")
		end

		sound.Parent = parent
		sound:AddTag("EmoteSFX")
		sound.TimePosition = soundInitialTimePosition

		if workspace:GetAttribute("BrazilMap") then
			sound.Volume = 0
		end

		maid:Add(sound)

		local function getSoundTimePosition(p4: number)
			local v17 = math.max(0, p4 - timePosition)
			local v18 = sound.TimeLength - soundInitialTimePosition

			if v18 > 0 then
				if p.Emote.Name == "Emote1217" then
					v17 = math.max(0, math.max(0, workspace:GetServerTimeNow() - v11) - timePosition) % v18
				else
					v17 %= v18
				end
			end

			return soundInitialTimePosition + v17
		end

		local function syncSound()
			if not v14 then
				return false
			end

			local v17

			if timeLength <= 0 then
				v17 = 0
			else
				v17 = math.max(0, workspace:GetServerTimeNow() - v11)

				if not (v17 < timeLength) then
					local v18 = timeLength - timePosition

					if v18 > 0 then
						v17 = timePosition + (v17 - timeLength) % v18
					else
						v17 = math.max(0, timeLength - 1 / player.FrameRate)
					end
				end
			end

			if v17 < timePosition then
				return false
			end

			local v18 = sound
			local v19 = math.max(0, v17 - timePosition)
			local v20 = sound.TimeLength - soundInitialTimePosition

			if v20 > 0 then
				if p.Emote.Name == "Emote1217" then
					v19 = math.max(0, math.max(0, workspace:GetServerTimeNow() - v11) - timePosition) % v20
				else
					v19 %= v20
				end
			end

			v18.TimePosition = soundInitialTimePosition + v19

			if not sound.IsPlaying then
				sound:Play()
			end

			return true
		end

		local v17

		if timeLength <= 0 then
			v17 = 0
		else
			v17 = math.max(0, workspace:GetServerTimeNow() - v11)

			if not (v17 < timeLength) then
				local v18 = timeLength - timePosition

				if v18 > 0 then
					v17 = timePosition + (v17 - timeLength) % v18
				else
					v17 = math.max(0, timeLength - 1 / player.FrameRate)
				end
			end
		end

		if timePosition <= v17 then
			if v14 then
				local v18

				if timeLength <= 0 then
					v18 = 0
				else
					v18 = math.max(0, workspace:GetServerTimeNow() - v11)

					if not (v18 < timeLength) then
						local v19 = timeLength - timePosition

						if v19 > 0 then
							v18 = timePosition + (v18 - timeLength) % v19
						else
							v18 = math.max(0, timeLength - 1 / player.FrameRate)
						end
					end
				end

				if not (v18 < timePosition) then
					local v19 = math.max(0, v18 - timePosition)
					local v20 = sound.TimeLength - soundInitialTimePosition

					if v20 > 0 then
						if p.Emote.Name == "Emote1217" then
							v19 = math.max(0, math.max(0, workspace:GetServerTimeNow() - v11) - timePosition) % v20
						else
							v19 %= v20
						end
					end

					sound.TimePosition = soundInitialTimePosition + v19

					if not sound.IsPlaying then
						sound:Play()
					end
				end
			end
		else
			maid:Add(task.delay(timePosition - v17, syncSound))
		end

		if not sound.IsLoaded then
			maid:Add(sound.Loaded:Connect(function()
				if not v14 then
					return
				end

				local v18

				if timeLength <= 0 then
					v18 = 0
				else
					v18 = math.max(0, workspace:GetServerTimeNow() - v11)

					if not (v18 < timeLength) then
						local v19 = timeLength - timePosition

						if v19 > 0 then
							v18 = timePosition + (v18 - timeLength) % v19
						else
							v18 = math.max(0, timeLength - 1 / player.FrameRate)
						end
					end
				end

				if v18 < timePosition then
					return
				end

				local v19 = sound
				local v20 = math.max(0, v18 - timePosition)
				local v21 = sound.TimeLength - soundInitialTimePosition

				if v21 > 0 then
					if p.Emote.Name == "Emote1217" then
						v20 = math.max(0, math.max(0, workspace:GetServerTimeNow() - v11) - timePosition) % v21
					else
						v20 %= v21
					end
				end

				v19.TimePosition = soundInitialTimePosition + v20

				if not sound.IsPlaying then
					sound:Play()
				end
			end))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setSoundAudible(flag2: boolean)
			v14 = v13 and flag2

			if v14 then
				if not v14 then
					return
				end

				local v18

				if timeLength <= 0 then
					v18 = 0
				else
					v18 = math.max(0, workspace:GetServerTimeNow() - v11)

					if not (v18 < timeLength) then
						local v19 = timeLength - timePosition

						if v19 > 0 then
							v18 = timePosition + (v18 - timeLength) % v19
						else
							v18 = math.max(0, timeLength - 1 / player.FrameRate)
						end
					end
				end

				if v18 < timePosition then
					return
				end

				local v19 = sound
				local v20 = math.max(0, v18 - timePosition)
				local v21 = sound.TimeLength - soundInitialTimePosition

				if v21 > 0 then
					if p.Emote.Name == "Emote1217" then
						v20 = math.max(0, math.max(0, workspace:GetServerTimeNow() - v11) - timePosition) % v21
					else
						v20 %= v21
					end
				end

				v19.TimePosition = soundInitialTimePosition + v20

				if not sound.IsPlaying then
					sound:Play()
				end
			elseif sound.IsPlaying then
				sound:Pause()
			end
		end

		if playerFromCharacter and v13 then
			local v18 = v7[p.Emote.Name]

			if not v18 then
				v18 = {}
				v7[p.Emote.Name] = v18
			end

			local v19 = v18[v11]

			if not v19 then
				v19 = {}
				v18[v11] = v19
			end

			v19[instance] = {
				Player = playerFromCharacter,
				SetAudible = setSoundAudible
			}
			maid:Add(instance.AncestryChanged:Connect(function()
				refreshDanceSoundGroup(v19)
			end))
			maid:Add(playerFromCharacter:GetPropertyChangedSignal("Character"):Connect(function()
				refreshDanceSoundGroup(v19)
			end))
			maid:Add(function()
				setSoundAudible(false) -- equivalent call inferred; original call site unknown
				v19[instance] = nil
				refreshDanceSoundGroup(v19)

				if next(v19) == nil then
					v18[v11] = nil

					if next(v18) == nil then
						v7[p.Emote.Name] = nil
					end
				end
			end)
			refreshDanceSoundGroup(v19)
		else
			v14 = v13 and v13

			if v14 then
				if v14 then
					local v18

					if timeLength <= 0 then
						v18 = 0
					else
						v18 = math.max(0, workspace:GetServerTimeNow() - v11)

						if not (v18 < timeLength) then
							local v19 = timeLength - timePosition

							if v19 > 0 then
								v18 = timePosition + (v18 - timeLength) % v19
							else
								v18 = math.max(0, timeLength - 1 / player.FrameRate)
							end
						end
					end

					if not (v18 < timePosition) then
						local v19 = math.max(0, v18 - timePosition)
						local v20 = sound.TimeLength - soundInitialTimePosition

						if v20 > 0 then
							if p.Emote.Name == "Emote1217" then
								v19 = math.max(0, math.max(0, workspace:GetServerTimeNow() - v11) - timePosition) % v20
							else
								v19 %= v20
							end
						end

						sound.TimePosition = soundInitialTimePosition + v19

						if not sound.IsPlaying then
							sound:Play()
						end
					end
				end
			elseif sound.IsPlaying then
				sound:Pause()
			end
		end

		maid:Add(player.OnLoop:Connect(function()
			player.TimePosition = timePosition
			player.CurrentFrame = math.floor(timePosition * player.FrameRate)

			if v14 and p.Emote.Name ~= "Emote1217" then
				sound.TimePosition = soundInitialTimePosition
			end

			if type(items) == "table" and p.Emote.Name ~= "Emote1217" then
				for _, item in items do
					item.TimePosition = timePosition
				end
			end
		end))

		if p.Emote.Name ~= "Emote1017" then
			maid:Add(RunService.PostSimulation:Connect(function()
				if timePosition <= player.TimePosition and sound.IsLoaded and not sound.IsPlaying and v14 then
					if not v14 then
						return
					end

					local v18

					if timeLength <= 0 then
						v18 = 0
					else
						v18 = math.max(0, workspace:GetServerTimeNow() - v11)

						if not (v18 < timeLength) then
							local v19 = timeLength - timePosition

							if v19 > 0 then
								v18 = timePosition + (v18 - timeLength) % v19
							else
								v18 = math.max(0, timeLength - 1 / player.FrameRate)
							end
						end
					end

					if v18 < timePosition then
						return
					end

					local v19 = sound
					local v20 = math.max(0, v18 - timePosition)
					local v21 = sound.TimeLength - soundInitialTimePosition

					if v21 > 0 then
						if p.Emote.Name == "Emote1217" then
							v20 = math.max(0, math.max(0, workspace:GetServerTimeNow() - v11) - timePosition) % v21
						else
							v20 %= v21
						end
					end

					v19.TimePosition = soundInitialTimePosition + v20

					if not sound.IsPlaying then
						sound:Play()
					end
				end
			end))
		end

		maid:Add(function()
			player:Stop()
			player:Destroy()
		end)

		if instance:IsDescendantOf(workspace.CurrentCamera) then
			maid:Connect(instance.AncestryChanged, function()
				if not instance:IsDescendantOf(workspace.CurrentCamera) then
					sound:Pause()
					return
				end

				if not v14 then
					return
				end

				local v18

				if timeLength <= 0 then
					v18 = 0
				else
					v18 = math.max(0, workspace:GetServerTimeNow() - v11)

					if not (v18 < timeLength) then
						local v19 = timeLength - timePosition

						if v19 > 0 then
							v18 = timePosition + (v18 - timeLength) % v19
						else
							v18 = math.max(0, timeLength - 1 / player.FrameRate)
						end
					end
				end

				if v18 < timePosition then
					return
				end

				local v19 = sound
				local v20 = math.max(0, v18 - timePosition)
				local v21 = sound.TimeLength - soundInitialTimePosition

				if v21 > 0 then
					if p.Emote.Name == "Emote1217" then
						v20 = math.max(0, math.max(0, workspace:GetServerTimeNow() - v11) - timePosition) % v21
					else
						v20 %= v21
					end
				end

				v19.TimePosition = soundInitialTimePosition + v20

				if not sound.IsPlaying then
					sound:Play()
				end
			end)
		end
	end

	return function()
		maid:Destroy()
	end
end