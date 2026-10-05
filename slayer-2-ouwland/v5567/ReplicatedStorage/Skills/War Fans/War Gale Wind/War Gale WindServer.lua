local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local DebrisModule = require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local WarGaleWindServer = {
	Id = {},
	Hold = function(player)
		local character = player.Character

		if character == nil then
			return
		end

		Utility.AddValue(Utility.getvaluesfolder(character), "pause_gameplay", Config.CAST_DURATION)
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart ~= nil then
			EffectsEvent.ToAllInRange(humanoidRootPart, "War Gale Wind VFX", character, "Windup")
		end
	end
}

function WarGaleWindServer.UnHold(player, vector2: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local v = WarGaleWindServer.Id[player.UserId]
	local v2 = ((vector2 or humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * Config.TORNADO_RANGE) - humanoidRootPart.Position) * createVector(
		1,
		0,
		1
	)
	local unit

	if v2.Magnitude > 0.001 then
		unit = v2.Unit
	else
		unit = (humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)).Unit
	end

	local cFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + unit) * Config.TORNADO_SPAWN_OFFSET
	local formatted = `{player.Name} WarGaleWind_captured--`
	local child = character:FindFirstChild(formatted)

	if child then
		child:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = formatted
	folder.Parent = character
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local v7 = {}
	local v8 = {}
	local flag = false
	local position = cFrame.Position
	local projectile = nil

	local function getCenter()
		local v10

		if projectile and projectile.Instance then
			v10 = projectile:Position()
		end

		if v10 == nil then
			return nil
		end

		return v10 + Config.TORNADO_VFX_OFFSET.Position
	end

	local function finishCyclone(flag2: boolean)
		if flag then
			return
		end

		flag = true
		local v10

		if projectile and projectile.Instance then
			v10 = projectile:Position()
		end

		local v11

		if v10 ~= nil then
			v11 = v10 + Config.TORNADO_VFX_OFFSET.Position
		end

		local v12 = v11 or position
		local v13 = {}

		if flag2 and folder.Parent then
			for _, child2 in folder:GetChildren() do
				local value = child2.Value

				if value ~= nil then
					table.insert(v13, value)
				end
			end
		end

		for _, v14 in v5 do
			v14:Destroy()
		end

		for _, v14 in v7 do
			v14:Destroy()
		end

		for _, v14 in v8 do
			v14:Destroy()
		end

		for _, v14 in v6 do
			v14:Destroy()
		end

		for _, v14 in v4 do
			v14:Destroy()
		end

		if folder.Parent then
			folder.Name = "--"
			DebrisModule:AddItem(folder, 0.5)
		end

		if projectile and projectile.IsActive then
			projectile:Destroy()
		end

		for _, v14 in v13 do
			local humanoidRootPart2 = v14:FindFirstChild("HumanoidRootPart")
			local getvaluesfolder = Utility.getvaluesfolder(v14)

			if not (v14.Parent ~= nil and humanoidRootPart2 and getvaluesfolder) then
				continue
			end

			Combat_Util.Damage(script, character, v14, {
				Base = Config.BURST_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.RagDoll(script, character, getvaluesfolder, Config.BURST_STUN)
			Combat_Util.AddStun(script, character, getvaluesfolder, Config.BURST_STUN)
			local v15 = humanoidRootPart2.Position - v12
			local v16

			if v15.Magnitude > 0.001 then
				v16 = v15.Unit
			else
				v16 = unit
			end

			Combat_Util.Knockback(script, character, humanoidRootPart2, v16 * Config.BURST_KNOCKBACK, 0.125)
		end
	end

	function p.cycloneFinish()
		finishCyclone(false)
	end

	local function captureVictim(instance, rootPart, getvaluesfolder)
		if flag then
			return
		end

		for _, child2 in folder:GetChildren() do
			if child2.Value == instance then
				return
			end
		end

		local v10

		if projectile and projectile.Instance then
			v10 = projectile:Position()
		end

		local v11

		if v10 ~= nil then
			v11 = v10 + Config.TORNADO_VFX_OFFSET.Position
		end

		if v11 == nil then
			return
		end

		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = instance.Name
		objectValue.Value = instance
		objectValue.Parent = folder
		local attachment = Instance.new("Attachment")
		attachment.Name = "ALP"
		attachment.Parent = rootPart
		local _, v12 = Utility.SafeLookAt(v11, rootPart.Position, CFrame.new(v11)):ToOrientation()
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "Rot"
		numberValue.Value = v12
		numberValue.Parent = attachment
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.Name = "P"
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.Attachment0 = attachment
		alignPosition.MaxForce = 200000
		alignPosition.Responsiveness = 100
		alignPosition.Position = v11 + CFrame.Angles(0, v12, 0) * Config.SPIN_OFFSET
		alignPosition.Parent = attachment
		local add_Strict_Stun = Combat_Util.Add_Strict_Stun(
			script,
			character,
			getvaluesfolder,
			Config.CAPTURE_STRICT_STUN
		)
		v5[instance] = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.CAPTURE_STRICT_STUN)
		v6[instance] = Utility.AddValue(getvaluesfolder, "iframe", Config.CAPTURE_STRICT_STUN)
		v7[instance] = Utility.AddValue(getvaluesfolder, "noragdoll", Config.CAPTURE_STRICT_STUN)
		v8[instance] = Utility.AddValue(getvaluesfolder, "NOMouvementlines", Config.CAPTURE_STRICT_STUN)
		Combat_Util.Damage(script, character, instance, {
			Base = Config.CAPTURE_INITIAL_DAMAGE,
			Skill = script.Parent.Name
		})
		local humanoid = instance:FindFirstChild("Humanoid")

		if humanoid then
			Combat_presets.PlayReactAnim(humanoid)
		end

		table.insert(v4, attachment)

		if add_Strict_Stun then
			table.insert(v4, add_Strict_Stun)
		end

		if Players:GetPlayerFromCharacter(instance) == nil then
			pcall(function()
				rootPart:SetNetworkOwner(player)
			end)
		end
	end

	local function onTouch(_: Vector3, _: Vector3, p2)
		if flag or v ~= WarGaleWindServer.Id[player.UserId] or p2 == nil then
			return true
		end

		local find_character_from_descendant = Utility.find_character_from_descendant(p2)

		if find_character_from_descendant == nil or find_character_from_descendant == character or folder:FindFirstChild(find_character_from_descendant.Name) then
			return false
		end

		local getvaluesfolder = Utility.getvaluesfolder(find_character_from_descendant)

		if getvaluesfolder == nil then
			return false
		end

		local formatted2 = `WarGaleWind touch from {player.Name}`

		if not Combat_Util.CheckCanTouch(getvaluesfolder, formatted2) then
			return false
		end

		Combat_Util.SetTouchCooldown(getvaluesfolder, formatted2)
		local check_victim = Checker.check_victim(script, character, find_character_from_descendant)

		if check_victim == nil then
			return false
		end

		local humanoid = find_character_from_descendant:FindFirstChild("Humanoid")
		local rootPart = humanoid and humanoid.RootPart

		if rootPart == nil then
			return false
		end

		if check_victim == "Perfect" then
			Combat_Util.Perfect(script, character, find_character_from_descendant)
		elseif check_victim == "Blocking" then
			Combat_Util.Block(script, character, find_character_from_descendant, Config.TORNADO_BLOCK_BREAK)
		else
			captureVictim(find_character_from_descendant, rootPart, getvaluesfolder)
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", rootPart, -1)
		return false
	end

	projectile = ProjectileModeler.new({
		Name = `{player.Name} War Gale Wind`,
		Size = Config.TORNADO_SIZE,
		Massless = true,
		CanCollide = false,
		Transparency = 1,
		CFrame = cFrame,
		Mover = {
			MaxForce = 1000000000,
			VectorVelocity = unit * Config.TORNADO_SPEED
		},
		Rotator = {
			CFrame = cFrame
		}
	}, onTouch, Config.TORNADO_LIFETIME, ProjectileModeler.WhitelistType.HumanoidsAndMap, character, nil, true)
	p.projectile = projectile
	projectile.Instance:SetNetworkOwner(player)
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"War Gale Wind VFX",
		character,
		"Skill1",
		projectile.Instance,
		Config.TORNADO_VFX_OFFSET
	)
	task.spawn(function()
		local v10 = os.clock() + Config.CAPTURE_TICK_INTERVAL

		while v == WarGaleWindServer.Id[player.UserId] and not flag and character.Parent ~= nil do
			local v11

			if projectile and projectile.Instance then
				v11 = projectile:Position()
			end

			local v12

			if v11 ~= nil then
				v12 = v11 + Config.TORNADO_VFX_OFFSET.Position
			end

			if v12 == nil then
				break
			end

			position = v12

			for _, v13 in v4 do
				if not (v13.Name == "ALP" and v13.Parent) then
					continue
				end

				local rot = v13:FindFirstChild("Rot")
				local P = v13:FindFirstChild("P")
				rot.Value += Config.SPIN_INCREMENT
				P.Position = v12 + Vector3.new(0, rot.Value * Config.SPIN_RISE_RATE, 0) + CFrame.Angles(
					0,
					-rot.Value,
					0
				) * Config.SPIN_OFFSET
			end

			if v10 <= os.clock() and folder.Parent then
				v10 = os.clock() + Config.CAPTURE_TICK_INTERVAL

				for _, child2 in folder:GetChildren() do
					local value = child2.Value

					if value and value.Parent and Checker.check_victim(script, character, value, {
						iframe = true
					}) ~= nil then
						Combat_Util.Damage(script, character, value, {
							Base = Config.CAPTURE_TICK_DAMAGE,
							Skill = script.Parent.Name
						})
						local humanoid = value:FindFirstChild("Humanoid")

						if humanoid then
							Combat_presets.PlayReactAnim(humanoid)
						end
					else
						child2:Destroy()
						local humanoidRootPart2 = value and value:FindFirstChild("HumanoidRootPart")
						local ALP = humanoidRootPart2 and humanoidRootPart2:FindFirstChild("ALP")

						if ALP then
							ALP:Destroy()
						end

						if value and v5[value] then
							v5[value]:Destroy()
							v5[value] = nil
						end

						if value and v7[value] then
							v7[value]:Destroy()
							v7[value] = nil
						end

						if value and v8[value] then
							v8[value]:Destroy()
							v8[value] = nil
						end

						if value and v6[value] then
							v6[value]:Destroy()
							v6[value] = nil
						end
					end
				end
			end

			task.wait()
		end

		if not flag then
			finishCyclone(true)
		end
	end)
end

function WarGaleWindServer.Cancel(_, _: Vector3?, p)
	if p and p.cycloneFinish then
		p.cycloneFinish()
	end
end

return WarGaleWindServer