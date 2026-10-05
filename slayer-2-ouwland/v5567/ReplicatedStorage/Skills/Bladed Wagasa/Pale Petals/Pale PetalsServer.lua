local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local PalePetalsServer = {
	Id = {}
}
local name = script.Parent.Name

function PalePetalsServer.Hold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character

	if character == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	cleanIt:Add(Utility.AddValue(
		getvaluesfolder,
		"WalkSpeed",
		Config.THROW_DURATION,
		"NumberValue",
		Config.THROW_WALK_SPEED
	))
	cleanIt:Add(Utility.AddValue(
		getvaluesfolder,
		"skillsdisabled",
		Config.THROW_DURATION + 0.25,
		"StringValue",
		Config.LOCKED_SKILLS
	))
end

function PalePetalsServer.UnHold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local v2 = PalePetalsServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Pale Petals VFX", character, "Attempt")
	local instances = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.SCAN_OFFSET,
		hitboxSize = Config.SCAN_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, _, _)
			if instance:FindFirstChild("HumanoidRootPart") then
				table.insert(instances, instance)
			end
		end
	})

	if #instances == 0 then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Pale Petals VFX", character, "Cancel")
		cleanIt:Clean()
	else
		local getvaluesfolder = Utility.getvaluesfolder(character)
		cleanIt:Add(Utility.AddValue(
			getvaluesfolder,
			"skillsdisabled",
			Config.HOVER_DURATION + 0.25,
			"StringValue",
			Config.LOCKED_SKILLS
		))
		local position = (humanoidRootPart.CFrame * Config.UMBWEP2_F55).Position
		cleanIt:Add(Utility.AddValue(
			getvaluesfolder,
			"InvisibleItem",
			Config.HOVER_DURATION + 0.5,
			"StringValue",
			"Bladed Wagasa"
		))
		EffectsEvent.ToAllInRange(humanoidRootPart, "Pale Petals VFX", character, "Start")
		task.wait(Config.PETAL_START_DELAY)

		if PalePetalsServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end

		local PETAL_START_DELAY = Config.PETAL_START_DELAY
		local count = 0

		while PalePetalsServer.Id[player.UserId] == v2 and humanoidRootPart.Parent ~= nil and PETAL_START_DELAY < Config.HOVER_DURATION do
			count += 1
			local humanoidRootPart2 = instances[(count - 1) % #instances + 1]:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 and humanoidRootPart2.Parent then
				local flag = false
				local formatted = `{player.Name} PalePetal {count}`
				local v3 = (humanoidRootPart2.Position - position).Magnitude / Config.PETAL_SPEED
				local v4 = humanoidRootPart2.Position + humanoidRootPart2.AssemblyLinearVelocity * createVector(1, 0, 1) * v3 * Config.PETAL_LEAD
				local unit = (v4 - position).Unit
				local v5 = ProjectileModeler.new({
					Name = formatted,
					Size = Config.PETAL_SIZE,
					CFrame = CFrame.new(position),
					Mover = {
						MaxForce = 1000000000,
						VectorVelocity = unit * Config.PETAL_SPEED
					},
					Rotator = {
						Responsiveness = 60,
						CFrame = Utility.SafeLookAt(position, v4, humanoidRootPart.CFrame)
					}
				}, function(_, _, p2)
					if flag or p2 == nil or PalePetalsServer.Id[player.UserId] ~= v2 then
						return false
					end

					local find_character_from_descendant = Utility.find_character_from_descendant(p2)
					local humanoidRootPart3 = find_character_from_descendant and find_character_from_descendant:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart3 == nil then
						return false
					end

					local check_victim = Checker.check_victim(script, character, find_character_from_descendant)

					if check_victim == "Perfect" then
						Combat_Util.Perfect(script, character, find_character_from_descendant)
						flag = true
					elseif check_victim == "Blocking" then
						Combat_Util.Block(script, character, find_character_from_descendant, Config.PETAL_BLOCK_BREAK)
						flag = true
					elseif check_victim == true then
						Combat_Util.Damage(script, character, find_character_from_descendant, {
							Base = Config.PETAL_DAMAGE,
							Skill = name
						})
						Combat_Util.Aggro(script, character, find_character_from_descendant, name)
						flag = true
					end

					if flag then
						EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart3, -1)
					end

					return false
				end, Config.PETAL_LIFETIME, ProjectileModeler.WhitelistType.HumanoidsAndMap, character, RaycastHelper.Crater)

				if v5.Instance then
					v5.Instance:SetNetworkOwner(player)
				end

				cleanIt:Add(v5)
				EffectsEvent.ToAllInRange(
					humanoidRootPart,
					"Pale Petals VFX",
					character,
					"Fire",
					formatted,
					v5.Instance,
					v4
				)
			end

			task.wait(Config.PETAL_INTERVAL)
			PETAL_START_DELAY += Config.PETAL_INTERVAL
		end

		if PalePetalsServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Pale Petals VFX", character, "Cancel")
		cleanIt:Clean()
	end
end

function PalePetalsServer.Cancel(player, _: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Pale Petals VFX", character, "Cancel")
	end

	if p.CleanIt then
		p.CleanIt:Clean()
	end
end

return PalePetalsServer