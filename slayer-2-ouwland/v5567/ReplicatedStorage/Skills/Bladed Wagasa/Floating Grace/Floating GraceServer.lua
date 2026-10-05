local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local DebrisModule = require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local FloatingGraceServer = {
	Id = {}
}
local name = script.Parent.Name

-- equivalent calls inferred from this helper; original call sites unknown
local function showUmbrella(p)
	if p.hideItem then
		p.hideItem:Destroy()
		p.hideItem = nil
	end
end

local function barragePulse(character, humanoidRootPart, cFrame: CFrame, list)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cFrame * Config.DEPLOY_HITBOX_OFFSET,
		hitboxSize = Config.DEPLOY_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoid = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid == nil or humanoidRootPart2 == nil then
				return
			end

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.DEPLOY_BLOCK_BREAK)
			elseif p2 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.DEPLOY_DAMAGE,
					Skill = name
				})
				Combat_Util.Add_Strict_Stun(script, character, p, Config.DEPLOY_STRICT_STUN)
				local v2 = (humanoidRootPart2.Position - cFrame.Position) * createVector(1, 0, 1)
				local v3

				if v2.Magnitude > 0.001 then
					v3 = v2.Unit
				else
					v3 = cFrame.LookVector
				end

				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					v3 * Config.DEPLOY_KNOCKBACK,
					Config.DEPLOY_KNOCKBACK_DURATION,
					"remove_airbp"
				)
				Combat_presets.PlayReactAnim(humanoid)
				table.insert(list, instance)
			end

			EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
		end
	})
end

local function pullVictimTo(character, instance, humanoidRootPart, position: Vector3, RETURN_TIME: number)
	local child = Players:FindFirstChild(character.Name)

	if child and instance.Name ~= child.Name and instance:GetAttribute("IsMob") == nil and Players:FindFirstChild(instance.Name) == nil and humanoidRootPart:CanSetNetworkOwnership() then
		humanoidRootPart:SetNetworkOwner(child)
	end

	local getvaluesfolder = Utility.getvaluesfolder(instance)

	if getvaluesfolder then
		Combat_Util.Add_No_GP(script, character, getvaluesfolder, RETURN_TIME)
	end

	Utility.ClearMovers(humanoidRootPart)

	if child then
		local child2 = Players:FindFirstChild(instance.Name)
		EffectsEvent.ToClient(child2 or child, "Add_Velocity", humanoidRootPart, createVector(0, 0, 0), 0, "delete")
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "air_combo_bp"
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Name = "bpv"
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	alignPosition.MaxAxesForce = createVector(1000000, 1000000, 1000000)
	alignPosition.Attachment0 = attachment
	alignPosition.Responsiveness = 60
	alignPosition.Position = position
	alignPosition.Parent = attachment
	attachment.Parent = humanoidRootPart
	DebrisModule:AddItem(attachment, RETURN_TIME)
end

function FloatingGraceServer.Hold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = FloatingGraceServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	p.deployRootCF = nil
	p.captured = {}
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.MAX_DURATION))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", Config.MAX_DURATION))
	task.wait(Config.DEPLOY_DELAY)

	if FloatingGraceServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	local cFrame = humanoidRootPart.CFrame
	p.deployRootCF = cFrame
	showUmbrella(p) -- equivalent call inferred; original call site unknown
	p.hideItem = Utility.AddValue(
		getvaluesfolder,
		"InvisibleItem",
		Config.MAX_DURATION + Config.RELEASE_DURATION,
		"StringValue",
		"Bladed Wagasa"
	)
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Floating Grace VFX",
		character,
		"Start",
		cFrame * CFrame.new(0, Config.UMBRELLA_HEIGHT, -Config.UMBRELLA_FORWARD)
	)

	while FloatingGraceServer.Id[player.UserId] == v2 and humanoidRootPart.Parent ~= nil do
		local captured = {}
		barragePulse(character, humanoidRootPart, humanoidRootPart.CFrame, captured)
		p.captured = captured
		task.wait(Config.BARRAGE_INTERVAL)
	end
end

function FloatingGraceServer.UnHold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = FloatingGraceServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)

	if state.deployRootCF == nil then
		showUmbrella(state) -- equivalent call inferred; original call site unknown
		EffectsEvent.ToAllInRange(humanoidRootPart, "Floating Grace VFX", character, "Cancel")
	else
		local v3, v4 = ManuelCancel.new(player, Config.RETURN_TIME + 0.5)
		v3:Connect(function()
			FloatingGraceServer.Id[player.UserId] = -1
			FloatingGraceServer.Cancel(player, nil, state)
		end)
		cleanIt:Add(v4)
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RETURN_TIME))
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.RETURN_TIME))
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", Config.RETURN_TIME))
		EffectsEvent.ToAllInRange(humanoidRootPart, "Floating Grace VFX", character, "Pull", humanoidRootPart.CFrame)
		local position = (humanoidRootPart.CFrame * CFrame.new(0, 0, -Config.PULL_FRONT_DIST)).Position

		for _, v5 in state.captured or {} do
			if v5.Parent == nil then
				continue
			end

			local humanoidRootPart2 = v5:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 ~= nil and Checker.check_victim(script, character, v5) == true then
				pullVictimTo(character, v5, humanoidRootPart2, position, Config.RETURN_TIME)
			end
		end

		task.wait(Config.RETURN_TIME)
		showUmbrella(state) -- equivalent call inferred; original call site unknown
		task.wait((math.max(0, Config.RELEASE_DURATION - Config.RETURN_TIME)))

		if FloatingGraceServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Floating Grace VFX", character, "Cancel")
		cleanIt:Clean()
	end
end

function FloatingGraceServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Floating Grace VFX", character, "Cancel")
	end

	showUmbrella(p) -- equivalent call inferred; original call site unknown
	cleanIt:Clean()
end

return FloatingGraceServer