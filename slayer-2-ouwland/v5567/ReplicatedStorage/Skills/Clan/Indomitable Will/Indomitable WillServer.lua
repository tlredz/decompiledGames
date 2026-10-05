local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Combat_Util = require(SAM.Services.Combat_Util)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local StatTypes = require(CAM.Global.Types.StatTypes)
local gameSettings = require(CAM.Global.gameSettings)
local Clans = require(CAM.Clans)
local PartBox = require(CAM.Global.PartBox)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local IndomitableWillServer = {
	Id = {}
}

local function immune(p)
	return Clans.IsImmune(Clans.ClanOfCharacter(p), "Indomitable Will")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function awayFrom(instance, humanoidRootPart)
	local v2 = humanoidRootPart.Position - instance.Position
	local vector2 = Vector3.new(v2.X, 0, v2.Z)

	if vector2.Magnitude <= 0 then
		return instance.CFrame.LookVector
	end

	return vector2.Unit
end

local function stampDebuff(p, p2: number?)
	local v2 = Utility.AddValue(p, Config.DEBUFF_VALUE, p2)
	v2:AddTag(StatTypes.ValueStatTag)
	v2:SetAttribute(StatTypes.StatToAttribute("Movement Speed Factor"), gameSettings.lowHealthSpeedFactor)
	v2:SetAttribute(StatTypes.StatToAttribute("Fear"), true)
	return v2
end

function IndomitableWillServer.Hold(player, _, state)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	state.startClock = os.clock()
	state.released = false
	task.wait(Config.TAP_WINDOW)

	if state.cancelled == true or humanoidRootPart.Parent == nil or state.released == true then
		return
	end

	local function stillRunning()
		return state.cancelled ~= true and humanoidRootPart.Parent ~= nil
	end

	local function fromStart(p: number)
		return (math.max(0, p - (os.clock() - state.startClock)))
	end

	local v2, v3 = ManuelCancel.new(player, (math.max(0, Config.FIELD_OPEN_AT - (os.clock() - state.startClock))))
	v2:Connect(function()
		state.cancelled = true
		v3()
		EffectsEvent.ToAllInRange(humanoidRootPart, "IndomitableWillVFX", character, "Cancel")
	end)
	task.delay(math.max(0, Config.FIELD_OPEN_AT - (os.clock() - state.startClock)), v3)

	for _, v4 in Config.HOLD_BEATS do
		local v5 = v4
		task.delay(math.max(0, v4.at - (os.clock() - state.startClock)), function()
			local v6

			if state.cancelled == true then
				v6 = false
			else
				v6 = humanoidRootPart.Parent ~= nil
			end

			if not v6 then
				return
			end

			EffectsEvent.ToAllInRange(
				humanoidRootPart,
				"IndomitableWillVFX",
				character,
				v5.state,
				Config.MAX_FIELD_DURATION
			)
		end)
	end

	task.delay(math.max(0, Config.FIELD_OPEN_AT - (os.clock() - state.startClock)), function()
		local v4

		if state.cancelled == true then
			v4 = false
		else
			v4 = humanoidRootPart.Parent ~= nil
		end

		if not v4 then
			return
		end

		if state.field ~= nil then
			state.field:Destroy()
			state.field = nil
		end

		local v5 = {}

		local function capture(p, p2)
			if v5[p] ~= nil or Clans.IsImmune(Clans.ClanOfCharacter(p), "Indomitable Will") then
				return
			end

			Combat_Util.Aggro(script, character, p)
			v5[p] = {
				stun = Combat_Util.AddStun(script, character, p2, Config.MAX_FIELD_DURATION + Config.LEAVE_STUN + 1),
				mark = stampDebuff(p2)
			}
		end

		local function release(p, p2)
			local v6 = v5[p]

			if v6 == nil then
				return
			end

			v5[p] = nil

			if v6.stun ~= nil and v6.stun.Parent ~= nil then
				v6.stun:Destroy()
			end

			if v6.mark ~= nil and v6.mark.Parent ~= nil then
				v6.mark:Destroy()
			end

			if p.Parent == nil or p2 == nil then
				return
			end

			Combat_Util.AddStun(script, character, p2, Config.LEAVE_STUN)
			stampDebuff(p2, Config.DEBUFF_DURATION)
		end

		local field = PartBox.new({
			Shape = "Ball",
			Center = humanoidRootPart.CFrame,
			Size = createVector(1, 1, 1) * (Config.FIELD_RADIUS * 2),
			MaxDuration = Config.MAX_FIELD_DURATION,
			caster = character,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			specificStateResult = true,
			hitDetected = function(p, p2)
				capture(p, p2)
			end
		})

		if field == nil then
			return
		end

		state.field = field
		field.Left:Connect(release)
	end)
end

function IndomitableWillServer.UnHold(player, _, state)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	state.released = true
	local v2 = os.clock() - (state.startClock or os.clock())

	if Config.TAP_WINDOW <= v2 then
		return
	end

	local function fromStart(p: number)
		return (math.max(0, p - v2))
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", (math.max(0, Config.TAP_END_AT - v2)))
	local v3 = IndomitableWillServer.Id[player.UserId]
	local v4, v5 = ManuelCancel.new(player, (math.max(0, Config.TAP_HIT_AT - v2)))
	local v6 = false
	v4:Connect(function()
		v6 = true
		v5()
		EffectsEvent.ToAllInRange(humanoidRootPart, "IndomitableWillVFX", character, "Cancel")
	end)

	local function stillRunning()
		local v7 = not v6

		if v7 then
			if v3 == IndomitableWillServer.Id[player.UserId] then
				return humanoidRootPart.Parent ~= nil
			else
				return false
			end
		end

		return v7
	end

	for _, v7 in Config.TAP_BEATS do
		local v8 = v7
		task.delay(math.max(0, v7.at - v2), function()
			local v9 = not v6

			if v9 then
				if v3 == IndomitableWillServer.Id[player.UserId] then
					v9 = humanoidRootPart.Parent ~= nil
				else
					v9 = false
				end
			end

			if not v9 then
				return
			end

			EffectsEvent.ToAllInRange(humanoidRootPart, "IndomitableWillVFX", character, v8.state)
		end)
	end

	task.wait((math.max(0, Config.TAP_HIT_AT - v2)))
	v5()
	local v7 = not v6

	if v7 then
		if v3 == IndomitableWillServer.Id[player.UserId] then
			v7 = humanoidRootPart.Parent ~= nil
		else
			v7 = false
		end
	end

	if not v7 then
		return
	end

	if state.tapField ~= nil then
		state.tapField:Destroy()
		state.tapField = nil
	end

	state.tapField = PartBox.new({
		Shape = "Ball",
		Center = humanoidRootPart.CFrame,
		Size = createVector(1, 1, 1) * (Config.TAP_RADIUS * 2),
		MaxDuration = Config.TAP_FIELD_DURATION,
		caster = character,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
			elseif p2 == true then
				if Clans.IsImmune(Clans.ClanOfCharacter(instance), "Indomitable Will") then
					return
				end

				Combat_Util.Aggro(script, character, instance)
				Combat_Util.AddStun(script, character, p, Config.STUN)
				local v9 = awayFrom(humanoidRootPart, humanoidRootPart2) -- equivalent call inferred; original call site unknown
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					v9 * Config.KNOCKBACK,
					Config.KNOCKBACK_DURATION
				)
				stampDebuff(p, Config.DEBUFF_DURATION)
			end
		end
	})
end

function IndomitableWillServer.Cancel(player, _, state)
	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart ~= nil then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end

	if state ~= nil then
		state.cancelled = true

		if state.field ~= nil then
			state.field:Destroy()
			state.field = nil
		end

		if state.tapField ~= nil then
			state.tapField:Destroy()
			state.tapField = nil
		end
	end

	if humanoidRootPart == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "IndomitableWillVFX", character, "Cancel")
end

return IndomitableWillServer