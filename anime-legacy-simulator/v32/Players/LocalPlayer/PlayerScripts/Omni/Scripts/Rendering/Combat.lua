local module = require("@game/ReplicatedStorage/Omni")
local v = {
	Punch = 5,
	Sword = 1
}
local v2 = {}
local v3 = {}
local v4 = {}
local heartbeatConnection = nil
local v5 = module.Services.UserInputService.TouchEnabled and not module.Services.UserInputService.KeyboardEnabled
local Combat = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetGamemodeSession()
	local data = module.Data

	if not data then
		return nil
	end

	local v6

	if typeof(data.Gamemode) == "string" and data.Gamemode ~= "" and typeof(data.GamemodeSession) == "string" then
		v6 = data.GamemodeSession ~= ""
	else
		v6 = false
	end

	if v6 then
		return data.GamemodeSession
	end

	return nil
end

local function IsVisible(p: string?, p2: string?, p3: string?)
	local data = module.Data

	if not data then
		return false
	end

	local gamemodeSession = GetGamemodeSession() -- equivalent call inferred; original call site unknown

	if gamemodeSession then
		return p3 == gamemodeSession and p2 == data.Gamemode
	else
		return p3 == nil and p == data.Maps.Current
	end
end

local function GetSound(childName: string, childName2: string)
	if childName ~= "Punch" and childName ~= "Sword" then
		return nil
	end

	local sounds = module.Assets:FindFirstChild("Sounds")
	local combat = sounds and sounds:FindFirstChild("Combat")
	local child = combat and combat:FindFirstChild(childName)
	local sound = child and child:FindFirstChild(childName2)

	if sound and sound:IsA("Sound") then
		return sound
	end

	return nil
end

local function GetWeaponSound(p: string?, p2: number)
	local v6 = p and module.Data.Weapons.List[p]

	if not v6 then
		return nil
	end

	local sounds = module.Assets:FindFirstChild("Sounds")
	local weapons = sounds and sounds:FindFirstChild("Weapons")
	local child = weapons and weapons:FindFirstChild(v6.Name)
	local sound = child and child:FindFirstChild("Hit" .. p2)

	if not (sound and sound:IsA("Sound")) then
		sound = nil
	end

	return sound, child
end

local function PickDamageVariant(instance)
	if not instance then
		return nil
	end

	local sounds = {}

	for _, sound in instance:GetChildren() do
		if not (sound:IsA("Sound") and string.match(sound.Name, "^Damage%d+$")) then
			continue
		end

		table.insert(sounds, sound)
	end

	if #sounds > 0 then
		return sounds[math.random(1, #sounds)]
	end

	return nil
end

local function GetDamageSound(childName: string, childName2: string?)
	local sounds = module.Assets:FindFirstChild("Sounds")
	local weapons = sounds and sounds:FindFirstChild("Weapons")
	local combat = sounds and sounds:FindFirstChild("Combat")
	local v6 = childName2 and PickDamageVariant(weapons and weapons:FindFirstChild(childName2))

	if v6 then
		return v6
	end

	return PickDamageVariant(combat and combat:FindFirstChild(childName)) or GetSound(childName, "Damage")
end

local function GetDescriptor(clonesByInstance, instance, rollOffMinDistance: number, rollOffMaxDistance: number)
	local v6 = clonesByInstance[instance]

	if v6 then
		return v6
	end

	local clone = instance:Clone()
	clone.RollOffMinDistance = rollOffMinDistance
	clone.RollOffMaxDistance = rollOffMaxDistance
	clone.RollOffMode = Enum.RollOffMode.InverseTapered
	clonesByInstance[instance] = clone
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearDescriptors(list)
	for _, v6 in list do
		v6:Destroy()
	end

	table.clear(list)
end

local function Track(object, p)
	v2[object] = p
	object:finally(function()
		v2[object] = nil

		if p.Holder then
			p.Holder:Destroy()
		end
	end)

	if heartbeatConnection then
		return
	end

	heartbeatConnection = module.Services.RunService.Heartbeat:Connect(function()
		for k, v6 in v2 do
			local mapName = v6.MapName
			local gamemode = v6.Gamemode
			local sessionID = v6.SessionID
			local data = module.Data
			local v7

			if data then
				local gamemodeSession = GetGamemodeSession() -- equivalent call inferred; original call site unknown

				if gamemodeSession then
					if sessionID == gamemodeSession then
						v7 = gamemode == data.Gamemode
					else
						v7 = false
					end
				elseif sessionID == nil then
					v7 = mapName == data.Maps.Current
				else
					v7 = false
				end
			else
				v7 = false
			end

			if v6.Character and v6.Character ~= module.Instance.Character then
				v7 = false
			end

			if v6.Root and not v6.Root:IsDescendantOf(workspace) then
				v7 = false
			end

			if v6.Weapon and v6.Weapon ~= module.Data.Weapons.Equipped then
				v7 = false
			end

			if not v7 then
				k:cancel()
			end
		end

		if not next(v2) then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)
end

function Combat.IsNear(vector: Vector3)
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		return (currentCamera.CFrame.Position - vector).Magnitude <= 80
	end

	return false
end

function Combat.IsMobile()
	return v5
end

function Combat.Hit(player, p: string, p2: number, instance, weapon: string?)
	if not (player == module.Instance and (instance and instance:IsDescendantOf(workspace))) then
		return
	end

	local settingVolume = module.Sound:GetSettingVolume("Hits Volume")

	if settingVolume <= 0 then
		return
	end

	local v6, v7 = GetWeaponSound(weapon, p2)

	if not v6 and v7 and v7:FindFirstChild("Impact" .. p2) then
		return
	end

	local v8 = v6 or GetSound(p, "Hit" .. (p2 - 1) % 3 + 1)

	if not v8 then
		return
	end

	local volumeMultiplier = ((not weapon or v6) and 1 or v[p]) * settingVolume
	local clones = v3
	local clone = clones[v8]

	if not clone then
		clone = v8:Clone()
		clone.RollOffMinDistance = 40
		clone.RollOffMaxDistance = 150
		clone.RollOffMode = Enum.RollOffMode.InverseTapered
		clones[v8] = clone
	end

	local v10 = module.Sound:Play(clone, instance, true, {
		Group = instance,
		Cooldown = 0,
		MaxVoices = 2,
		VolumeMultiplier = volumeMultiplier
	})
	local v12 = {
		Root = instance,
		Character = player.Character,
		Weapon = weapon,
		MapName = module.Data.Maps.Current,
		Gamemode = module.Data.Gamemode,
		SessionID = 0
	}
	local sessionID = GetGamemodeSession() -- equivalent call inferred; original call site unknown
	v12.SessionID = sessionID
	Track(v10, v12)
end

function Combat.Damage(p: string, worldPosition: Vector3, mapName: string?, gamemode: string?, sessionID: string?, p5: string?)
	local data = module.Data
	local v6

	if data then
		local gamemodeSession = GetGamemodeSession() -- equivalent call inferred; original call site unknown

		if gamemodeSession then
			if sessionID == gamemodeSession then
				v6 = gamemode == data.Gamemode
			else
				v6 = false
			end
		elseif sessionID == nil then
			v6 = mapName == data.Maps.Current
		else
			v6 = false
		end
	else
		v6 = false
	end

	if not v6 or typeof(worldPosition) ~= "Vector3" or not Combat.IsNear(worldPosition) or (module.Data.Settings["Effects Volume"] or 50) <= 0 then
		return
	end

	local settingVolume = module.Sound:GetSettingVolume("Hits Volume")

	if settingVolume <= 0 then
		return
	end

	local group = "CombatDamage" .. p

	if not module.Sound:CanPlay(group) then
		return
	end

	local damageSound = GetDamageSound(p, p5)

	if not damageSound then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "CombatSound"
	attachment.WorldPosition = worldPosition
	attachment.Parent = workspace.Terrain
	local clones = v4
	local clone = clones[damageSound]

	if not clone then
		clone = damageSound:Clone()
		clone.RollOffMinDistance = 8
		clone.RollOffMaxDistance = 80
		clone.RollOffMode = Enum.RollOffMode.InverseTapered
		clones[damageSound] = clone
	end

	Track(module.Sound:Play(clone, attachment, true, {
		Group = group,
		Cooldown = 0.06,
		MaxVoices = 4,
		VolumeMultiplier = settingVolume
	}), {
		Holder = attachment,
		MapName = mapName,
		Gamemode = gamemode,
		SessionID = sessionID
	})
end

function Combat.Destroy()
	for k in v2 do
		k:cancel()
	end

	ClearDescriptors(v3) -- equivalent call inferred; original call site unknown
	ClearDescriptors(v4) -- equivalent call inferred; original call site unknown

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

script.Destroying:Connect(Combat.Destroy)
return Combat