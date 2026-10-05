local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local EmotesInfo = require(ReplicatedStorage.CAM.Global.EmotesInfo)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local isServer = RunService:IsServer()
local v = {
	Ended = simplesignal.new(),
	Interrupted = simplesignal.new()
}
local v2 = {}

local function half(childName: string)
	local v3 = v2[childName]

	if v3 ~= nil then
		return v3 or nil
	end

	local child = script:FindFirstChild(childName)
	local moduleScript

	if child ~= nil then
		local v4

		if isServer then
			v4 = childName .. "Server"
		else
			v4 = childName
		end

		moduleScript = child:FindFirstChild(v4)
	end

	v2[childName] = moduleScript ~= nil and not not moduleScript:IsA("ModuleScript") and require(moduleScript)
	return v2[childName] or nil
end

local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function callHalf(p: string, p2: string, player, character, storage)
	local v3 = half(p)
	local v4

	if v3 ~= nil then
		v4 = v3[p2]
	end

	if v4 == nil then
		return
	end

	if isServer then
		v4(player, character, storage)
	else
		v4(character, storage)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function asset(childName: string, childName2: string)
	local child = script:FindFirstChild(childName)

	if child == nil then
		return nil
	end

	return (child:FindFirstChild(childName2, true))
end

local function sound(childName: string, childName2: string)
	local sound2 = asset(childName, childName2) -- equivalent call inferred; original call site unknown

	if sound2 == nil or not sound2:IsA("Sound") then
		return nil
	end

	return sound2
end

function v.Wear(parent, childName: string)
	local model = asset(childName, "Model") -- equivalent call inferred; original call site unknown

	if model == nil or not model:IsA("Model") then
		return nil
	end

	local weldTo = model:FindFirstChild("WeldTo")
	local part

	if not (weldTo == nil or not weldTo:IsA("StringValue")) then
		part = parent:FindFirstChild(weldTo.Value)
	end

	if part == nil or not part:IsA("BasePart") then
		return nil
	end

	local clone = model:Clone()
	local motor6D = clone:FindFirstChildOfClass("Motor6D") or clone:FindFirstChildOfClass("Weld")

	if motor6D == nil then
		clone:Destroy()
		return nil
	end

	motor6D.Part0 = part
	clone.Parent = parent
	return clone
end

local names = {}

local function vfx(p: string)
	local name = names[p]

	if name ~= nil then
		return name or nil
	end

	local effects = ReplicatedStorage:FindFirstChild("Effects")
	local child

	if effects ~= nil then
		child = effects:FindFirstChild(p .. "VFX", true)
	end

	if child == nil then
		name = false
	else
		name = child.Name
	end

	names[p] = name
	return name or nil
end

local function fireVfx(p, p2, p3: string?)
	local name = p.Name
	local name2 = names[name]

	if name2 == nil then
		local effects = ReplicatedStorage:FindFirstChild("Effects")
		local child

		if effects ~= nil then
			child = effects:FindFirstChild(name .. "VFX", true)
		end

		if child == nil then
			name2 = false
		else
			name2 = child.Name
		end

		names[name] = name2
	end

	local v3 = name2 or nil

	if v3 == nil or p2.Parent == nil then
		return
	end

	p.VfxFired = true

	if p3 == nil then
		EffectsEvent.ToAllInRange(p2, v3, p2)
	else
		EffectsEvent.ToAllInRange(p2, v3, p2, p3)
	end
end

local function cueSound(p, name: string, humanoidRootPart)
	local sound2 = asset(name, "Sound") -- equivalent call inferred; original call site unknown

	if sound2 == nil or not sound2:IsA("Sound") then
		sound2 = nil
	end

	if sound2 == nil then
		return
	end

	local clone = sound2:Clone()
	clone.Looped = false
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, 0)

	if p.Sounds ~= nil then
		table.insert(p.Sounds, clone)
	end
end

local function loopSound(p, childName: string, parent)
	local sound2 = asset(childName, "SoundLooped") -- equivalent call inferred; original call site unknown

	if sound2 == nil or not sound2:IsA("Sound") then
		sound2 = nil
	end

	if sound2 == nil or p.Sounds == nil then
		return
	end

	local clone = sound2:Clone()
	clone.Looped = true
	clone.Parent = parent
	clone:Play()
	table.insert(p.Sounds, clone)
end

local function startSound(p, childName: string, humanoidRootPart, flag: boolean, flag2: boolean)
	local clones = {}
	p.Sounds = clones
	local sound2

	if not flag2 then
		local child = script:FindFirstChild(childName)

		if child ~= nil then
			sound2 = child:FindFirstChild("Sound", true)
		end

		if sound2 == nil or not sound2:IsA("Sound") then
			sound2 = nil
		end
	end

	if sound2 ~= nil then
		local clone = sound2:Clone()
		clone.Looped = false
		clone.Parent = humanoidRootPart
		clone:Play()
		DebrisModule:AddItem(clone, 0)
		table.insert(clones, clone)
	end

	if not flag then
		return
	end

	if flag2 then
		p.SoundOnCue = true
		return
	end

	local sound3 = asset(childName, "SoundLooped") -- equivalent call inferred; original call site unknown

	if sound3 == nil or not sound3:IsA("Sound") then
		sound3 = nil
	end

	if sound3 ~= nil then
		if p.Sounds == nil then
			return
		end

		local clone = sound3:Clone()
		clone.Looped = true
		clone.Parent = humanoidRootPart
		clone:Play()
		table.insert(p.Sounds, clone)
	end
end

local function endPlay(player, p: string, flag: boolean?, flag2: boolean?)
	local v3 = object[player]

	if v3 == nil then
		return
	end

	local v4 = EmotesInfo[v3.Name]
	local v5

	if p == "Cancel" then
		v5 = not flag2

		if v5 then
			if v4 == nil or v4.Cancelling ~= false or v4.Duration == nil then
				v5 = false
			else
				v5 = v4.Duration >= 0
			end
		end
	else
		v5 = false
	end

	if v3.Locks ~= nil then
		for _, lock in v3.Locks do
			lock:Destroy()
		end

		v3.Locks = nil
	end

	if v3.Breaks ~= nil then
		for _, connection in v3.Breaks do
			connection:Disconnect()
		end

		v3.Breaks = nil
	end

	if v5 then
		return
	end

	object[player] = nil
	v3.Ended = true

	if v3.Unwatch ~= nil then
		v3.Unwatch()
	end

	if v3.Prop ~= nil then
		v3.Prop:Destroy()
		v3.Prop = nil
	end

	if v3.Sounds ~= nil then
		for _, sound2 in v3.Sounds do
			TweenService:Create(sound2, TweenInfo.new(0.3), {
				Volume = 0
			}):Play()
			DebrisModule:AddItem(sound2, 0.3)
		end

		v3.Sounds = nil
	end

	local character = player.Character

	if character ~= nil then
		if isServer and v4 ~= nil and v4.HasState and v3.VfxFired then
			local name = v3.Name
			local name2 = names[name]

			if name2 == nil then
				local effects = ReplicatedStorage:FindFirstChild("Effects")
				local child

				if effects ~= nil then
					child = effects:FindFirstChild(name .. "VFX", true)
				end

				if child == nil then
					name2 = false
				else
					name2 = child.Name
				end

				names[name] = name2
			end

			local v6 = name2 or nil

			if v6 ~= nil and character.Parent ~= nil then
				v3.VfxFired = true
				EffectsEvent.ToAllInRange(character, v6, character, "Cancel")
			end
		end

		callHalf(v3.Name, p, player, character, v3.Storage) -- equivalent call inferred; original call site unknown
	end

	if flag then
		v.Interrupted:Fire(player, v3.Name)
	end

	v.Ended:Fire(player, v3.Name, p)
end

local function begin(player, name3: string)
	local v3 = EmotesInfo[name3]

	if v3 == nil then
		return false
	end

	local character = player.Character
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if character == nil or humanoidRootPart == nil or not v.Free(player) or not v.Owned(player) then
		return false
	end

	endPlay(player, "Cancel", nil, true)
	local v4 = {
		Name = name3,
		Storage = {}
	}
	object[player] = v4

	if v3.Lock ~= nil and isServer then
		local getvaluesfolder = Utility.getvaluesfolder(character)
		v4.Locks = { Utility.AddValue(getvaluesfolder, "WalkSpeed", v3.Lock, "NumberValue", 0) }
	end

	if isServer then
		startSound(v4, name3, humanoidRootPart, v3.Duration ~= nil, v3.SoundOnCue == true)
		v4.Prop = v.Wear(character, name3)
		local v5 = v3.HasState and "Do" or nil

		if v3.VfxCue == nil then
			if v3.VfxDelay == nil or not (v3.VfxDelay > 0) then
				local name = v4.Name
				local name2 = names[name]

				if name2 == nil then
					local effects = ReplicatedStorage:FindFirstChild("Effects")
					local child

					if effects ~= nil then
						child = effects:FindFirstChild(name .. "VFX", true)
					end

					if child == nil then
						name2 = false
					else
						name2 = child.Name
					end

					names[name] = name2
				end

				local v6 = name2 or nil

				if v6 ~= nil and character.Parent ~= nil then
					v4.VfxFired = true

					if v5 == nil then
						EffectsEvent.ToAllInRange(character, v6, character)
					else
						EffectsEvent.ToAllInRange(character, v6, character, v5)
					end
				end
			else
				task.delay(v3.VfxDelay, function()
					if v4.Ended then
						return
					end

					local v6 = v4
					local character2 = character
					local v8 = v5
					local name = v6.Name
					local name2 = names[name]

					if name2 == nil then
						local effects = ReplicatedStorage:FindFirstChild("Effects")
						local child

						if effects ~= nil then
							child = effects:FindFirstChild(name .. "VFX", true)
						end

						if child == nil then
							name2 = false
						else
							name2 = child.Name
						end

						names[name] = name2
					end

					local v9 = name2 or nil

					if v9 ~= nil then
						if character2.Parent == nil then
							return
						end

						v6.VfxFired = true

						if v8 == nil then
							EffectsEvent.ToAllInRange(character2, v9, character2)
						else
							EffectsEvent.ToAllInRange(character2, v9, character2, v8)
						end
					end
				end)
			end
		end
	end

	callHalf(name3, "Do", player, character, v4.Storage) -- equivalent call inferred; original call site unknown

	if v3.Duration == nil then
		object[player] = nil
		local locks = v4.Locks

		if locks ~= nil and v3.Lock ~= nil then
			local v5, v6 = ManuelCancel.new(player, v3.Lock)
			v5:Connect(function()
				for _, lock in locks do
					lock:Destroy()
				end

				v6()
			end)
		end

		return true
	else
		local v5, unwatch = ManuelCancel.new(player, -1)
		v4.Unwatch = unwatch
		v5:Connect(function()
			if object[player] ~= v4 then
				return
			end

			endPlay(player, "Stop", true)
		end)

		if not isServer then
			local connections = {}
			v4.Breaks = connections

			-- equivalent calls inferred from this helper; original call sites unknown
			local function breakOut()
				if object[player] ~= v4 then
					return
				end

				v.Cancel()
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			table.insert(connections, RunService.PostSimulation:Connect(function()
				if humanoid == nil or not (humanoid.MoveDirection.Magnitude > 0) then
					local SHC = character:FindFirstChild("SHC")

					if SHC ~= nil and SHC:IsA("StringValue") and SHC.Value ~= "" then
						breakOut() -- equivalent call inferred; original call site unknown
					end
				else
					breakOut() -- equivalent call inferred; original call site unknown
				end
			end))
		end

		if v3.Duration >= 0 then
			task.delay(v3.Duration + (isServer and 1 or 0), function()
				if object[player] ~= v4 then
					return
				end

				endPlay(player, "Stop")
			end)
		end

		return true
	end
end

function v.Exists(p: string)
	return EmotesInfo[p] ~= nil
end

function v.OnPodium(instance)
	return workspace:GetAttribute("MinigameState") == "Victory" and instance:GetAttribute("PvPVictory") ~= nil
end

function v.Free(p)
	return v.OnPodium(p) or Checker.check(p)
end

function v.Owned(p)
	return Shop.OwnsGamepassListing(p, "Emotes")
end

if isServer then
	function v.Do(p, name: string)
		return (begin(p, name))
	end

	function v.Stop(p)
		endPlay(p, "Stop")
	end

	function v.Cancel(p)
		endPlay(p, "Cancel")
	end

	function v:Fire()
		local v3 = object[self]
		local character = self.Character

		if v3 == nil or character == nil then
			return
		end

		local now = os.clock()

		if v3.LastCue ~= nil and now - v3.LastCue < 0.1 then
			return
		end

		v3.LastCue = now
		local v4 = EmotesInfo[v3.Name]
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local v5

		if v4 == nil then
			v5 = false
		else
			v5 = v4.SoundOnCue == true or v4.CueOnLoop == true
		end

		if v5 and humanoidRootPart ~= nil and humanoidRootPart:IsA("BasePart") then
			cueSound(v3, v3.Name, humanoidRootPart)

			if v3.SoundOnCue then
				v3.SoundOnCue = nil
				local sound2 = asset(v3.Name, "SoundLooped") -- equivalent call inferred; original call site unknown

				if sound2 == nil or not sound2:IsA("Sound") then
					sound2 = nil
				end

				if sound2 ~= nil and v3.Sounds ~= nil then
					local clone = sound2:Clone()
					clone.Looped = true
					clone.Parent = humanoidRootPart
					clone:Play()
					table.insert(v3.Sounds, clone)
				end
			end
		end

		local v6 = v4 ~= nil and v4.HasState and "Do" or nil
		local name = v3.Name
		local name2 = names[name]

		if name2 == nil then
			local effects = ReplicatedStorage:FindFirstChild("Effects")
			local child

			if effects ~= nil then
				child = effects:FindFirstChild(name .. "VFX", true)
			end

			if child == nil then
				name2 = false
			else
				name2 = child.Name
			end

			names[name] = name2
		end

		local v7 = name2 or nil

		if v7 ~= nil then
			if character.Parent == nil then
				return
			end

			v3.VfxFired = true

			if v6 == nil then
				EffectsEvent.ToAllInRange(character, v7, character)
			else
				EffectsEvent.ToAllInRange(character, v7, character, v6)
			end
		end
	end

	function v.Playing(p)
		local v3 = object[p]

		if v3 == nil then
			return nil
		end

		return v3.Name
	end

	return v
else
	local localPlayer = Players.LocalPlayer

	function v.Display(p: string)
		local v3 = half(p)

		if v3 == nil or v3.Display == nil then
			return nil, nil
		end

		return v3.Display()
	end

	function v.Do(name: string)
		if not begin(localPlayer, name) then
			return false
		end

		SignalEvent.ToServer("EmoteAction", name, "Do")
		return true
	end

	function v.Stop()
		if object[localPlayer] == nil then
			return
		end

		endPlay(localPlayer, "Stop")
		SignalEvent.ToServer("EmoteAction", nil, "Stop")
	end

	function v.Cancel()
		if object[localPlayer] == nil then
			return
		end

		endPlay(localPlayer, "Cancel")
		SignalEvent.ToServer("EmoteAction", nil, "Cancel")
	end

	function v.Fire()
		if object[localPlayer] == nil then
			return
		end

		SignalEvent.ToServer("EmoteAction", nil, "Fire")
	end

	function v.Playing()
		local v3 = object[localPlayer]

		if v3 == nil then
			return nil
		end

		return v3.Name
	end

	localPlayer.CharacterRemoving:Connect(function()
		endPlay(localPlayer, "Cancel", nil, true)
	end)
	return v
end