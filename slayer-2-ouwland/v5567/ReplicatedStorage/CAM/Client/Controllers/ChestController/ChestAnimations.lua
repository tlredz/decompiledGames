local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Presets = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker.Presets)
local ChestAssets = require(script.Parent.ChestAssets)
local ChestAnimations = {}
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function freezeAtEnd(object)
	object:Stop(0)
	object:Play(0)
	object.TimePosition = math.max(object.Length - 0.016666666666666666, 0)
	object:AdjustSpeed(0)
	object:AdjustWeight(1, 0)
end

local function playOpen(open)
	open:Stop(0)
	open:Play(0)
	open:AdjustSpeed(1)
	local flag = false

	local function hold()
		if flag then
			return
		end

		flag = true
		freezeAtEnd(open) -- equivalent call inferred; original call site unknown
	end

	open.Stopped:Once(hold)
	task.delay(math.max(open.Length, 0.05), hold)
end

local function playFlash(p, state, p2: number, duration: number, p3: number)
	task.delay(duration, function()
		if state.gen ~= p2 or p.Parent == nil then
			return
		end

		local flash = state.flash

		if flash == nil or flash.Parent == nil then
			flash = ChestAssets.flash(p)
			state.flash = flash
		end

		if flash == nil then
			return
		end

		flash.FillTransparency = 0
		flash.OutlineTransparency = 0
		flash.Enabled = true
		local v2 = p3 - duration
		TweenService:Create(flash, TweenInfo.new(v2, Enum.EasingStyle.Linear), {
			FillTransparency = 1,
			OutlineTransparency = 1
		}):Play()
		task.delay(v2, function()
			if state.gen == p2 and flash.Parent ~= nil then
				flash.Enabled = false
			end
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cueImpact(instance, state, gen: number, p: string, p2)
	task.delay(0.18333333333333332, function()
		if state.gen ~= gen or instance.Parent == nil then
			return
		end

		ChestAssets.burst(instance, p)
		Cam_Shaker(instance:GetPivot().Position, p2)
	end)
end

local function syncState(instance, state, flag: boolean?)
	state.gen += 1
	local gen = state.gen

	if instance:GetAttribute("IsOpen") == true then
		if state.spawn then
			state.spawn:Stop(0)
		end

		if flag then
			if state.open then
				playOpen(state.open)
			end

			ChestAssets.play(state.openSound)
			cueImpact(instance, state, gen, "OpenEffect", Presets.tinyshake_preset) -- equivalent call inferred; original call site unknown
			local v3 = 0.7666666666666667
			local v4 = 0.18333333333333332
			task.delay(0.18333333333333332, function()
				if state.gen ~= gen or instance.Parent == nil then
					return
				end

				local flash = state.flash

				if flash == nil or flash.Parent == nil then
					flash = ChestAssets.flash(instance)
					state.flash = flash
				end

				if flash == nil then
					return
				end

				flash.FillTransparency = 0
				flash.OutlineTransparency = 0
				flash.Enabled = true
				local v5 = v3 - v4
				TweenService:Create(flash, TweenInfo.new(v5, Enum.EasingStyle.Linear), {
					FillTransparency = 1,
					OutlineTransparency = 1
				}):Play()
				task.delay(v5, function()
					if state.gen == gen and flash.Parent ~= nil then
						flash.Enabled = false
					end
				end)
			end)
		elseif state.open then
			freezeAtEnd(state.open) -- equivalent call inferred; original call site unknown
		end
	else
		if state.open then
			state.open:Stop(0)
		end

		if instance:GetAttribute("NoSpawnShow") == true then
			if state.spawn then
				freezeAtEnd(state.spawn) -- equivalent call inferred; original call site unknown
			end
		else
			if state.spawn then
				state.spawn:Play(0)
			end

			ChestAssets.play(state.spawnSound)
			cueImpact(instance, state, gen, "SpawnEffect", Presets.activate_shake) -- equivalent call inferred; original call site unknown
			local v3 = 0.5833333333333334
			local v4 = 0.016666666666666666
			task.delay(0.016666666666666666, function()
				if state.gen ~= gen or instance.Parent == nil then
					return
				end

				local flash = state.flash

				if flash == nil or flash.Parent == nil then
					flash = ChestAssets.flash(instance)
					state.flash = flash
				end

				if flash == nil then
					return
				end

				flash.FillTransparency = 0
				flash.OutlineTransparency = 0
				flash.Enabled = true
				local v5 = v3 - v4
				TweenService:Create(flash, TweenInfo.new(v5, Enum.EasingStyle.Linear), {
					FillTransparency = 1,
					OutlineTransparency = 1
				}):Play()
				task.delay(v5, function()
					if state.gen == gen and flash.Parent ~= nil then
						flash.Enabled = false
					end
				end)
			end)
		end
	end
end

function ChestAnimations.track(instance)
	local v2 = v[instance]

	if v2 then
		if instance:GetAttribute("IsOpen") == true and v2.open then
			freezeAtEnd(v2.open) -- equivalent call inferred; original call site unknown
		end
	else
		local v3 = {
			open = nil,
			spawn = nil,
			openSound = nil,
			spawnSound = nil,
			flash = nil,
			gen = 0,
			conns = {}
		}
		v[instance] = v3
		table.insert(v3.conns, instance.Destroying:Connect(function()
			ChestAnimations.untrack(instance)
		end))
		local isOpen = instance:GetAttribute("IsOpen") == true
		local animator = ChestAssets.animator(instance)

		if not animator then
			warn((`Chest '{ChestAssets.key(instance)}' has no Animator — it cannot animate`))
		end

		v3.open = ChestAssets.track(instance, animator, "OpenAnimation")
		v3.spawn = ChestAssets.track(instance, animator, "SpawnAnimation")
		v3.openSound = ChestAssets.sound(instance, "OpenSound")
		v3.spawnSound = ChestAssets.sound(instance, "SpawnSound")

		if v[instance] == v3 then
			syncState(instance, v3, not isOpen and instance:GetAttribute("IsOpen") == true)
			table.insert(v3.conns, instance:GetAttributeChangedSignal("IsOpen"):Connect(function()
				syncState(instance, v3, true)
			end))
		else
			if v3.openSound then
				v3.openSound:Destroy()
			end

			if v3.spawnSound then
				v3.spawnSound:Destroy()
			end
		end
	end
end

function ChestAnimations.untrack(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	for _, conn in v2.conns do
		conn:Disconnect()
	end

	if v2.open then
		v2.open:Stop(0)
	end

	if v2.spawn then
		v2.spawn:Stop(0)
	end

	if v2.openSound then
		v2.openSound:Destroy()
	end

	if v2.spawnSound then
		v2.spawnSound:Destroy()
	end

	if v2.flash then
		v2.flash:Destroy()
	end

	v2.gen += 1
	v[p] = nil
end

function ChestAnimations.teardown()
	for k in v do
		ChestAnimations.untrack(k)
	end
end

return ChestAnimations