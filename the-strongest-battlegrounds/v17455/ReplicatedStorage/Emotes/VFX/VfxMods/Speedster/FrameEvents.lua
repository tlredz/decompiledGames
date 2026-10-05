game:GetService("ReplicatedStorage")
local FrameEvents = {
	frame_events = {},
	fov_keyframes = {},
	fov_eases = {},
	brightness_keyframes = {},
	image_keyframes = {
		imagelabel = {
			ImageTransparency = {}
		}
	}
}

local function add_cleanup_task(p, p2)
	if not (p and p2) then
		return p2
	end

	local cleanup_tasks = p.cleanup_tasks

	if cleanup_tasks then
		table.insert(cleanup_tasks, p2)
	end

	return p2
end

local function remove_cleanup_task(p, p2)
	local cleanup_tasks = p and p.cleanup_tasks

	if not cleanup_tasks then
		return
	end

	local index = table.find(cleanup_tasks, p2)

	if index then
		table.remove(cleanup_tasks, index)
	end
end

local function delay_task(p, duration: number, callback)
	local thread = nil
	thread = task.delay(duration, function()
		local v2 = thread
		local cleanup_tasks = p and p.cleanup_tasks
		local index = cleanup_tasks and table.find(cleanup_tasks, v2)

		if index then
			table.remove(cleanup_tasks, index)
		end

		callback()
	end)
	local v = thread
	local cleanup_tasks = p and v and p.cleanup_tasks

	if cleanup_tasks then
		table.insert(cleanup_tasks, v)
	end

	return thread
end

local function repeat_delayed(p, p2: number, p3: number, fn)
	for i = 0, p2 - 1 do
		local v = i * p3

		local function fn2()
			local run_context = p.run_context

			if not run_context or run_context.running then
				fn()
			end
		end

		local thread = nil
		thread = task.delay(v, function()
			local v4 = thread
			local cleanup_tasks = p and p.cleanup_tasks
			local index = cleanup_tasks and table.find(cleanup_tasks, v4)

			if index then
				table.remove(cleanup_tasks, index)
			end

			fn2()
		end)
		local v3 = thread
		local cleanup_tasks = p and v3 and p.cleanup_tasks

		if cleanup_tasks then
			table.insert(cleanup_tasks, v3)
		end
	end
end

local v = nil

local function get_vfx_util()
	if not v then
		local VFXUtil = require(script.Parent.VFXUtil)
		v = VFXUtil
	end

	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function is_cutscene_active(p)
	local run_context = p.run_context
	return not run_context or run_context.running
end

-- equivalent calls inferred from this helper; original call sites unknown
local function track_cleanup_object(p, instance)
	if typeof(instance) ~= "Instance" then
		return
	end

	local cleanup_objects = p.cleanup_objects

	if cleanup_objects then
		table.insert(cleanup_objects, instance)
	end

	if not instance then
		return
	end

	local function fn()
		if instance.Parent then
			instance:Destroy()
		end
	end

	local thread = nil
	thread = task.delay(15, function()
		local v3 = thread
		local cleanup_tasks = p and p.cleanup_tasks
		local index = cleanup_tasks and table.find(cleanup_tasks, v3)

		if index then
			table.remove(cleanup_tasks, index)
		end

		fn()
	end)
	local v2 = thread
	local cleanup_tasks = p and v2 and p.cleanup_tasks

	if cleanup_tasks then
		table.insert(cleanup_tasks, v2)
	end
end

local function color_correction(p, p2)
	if not is_cutscene_active(p) or p.isme == false then
		return
	end

	p2.cleanup_tasks = p.cleanup_tasks

	if not v then
		local VFXUtil = require(script.Parent.VFXUtil)
		v = VFXUtil
	end

	track_cleanup_object(p, v.ColorCorrection(p2)) -- equivalent call inferred; original call site unknown
end

local function screen_pulse(p, p2)
	if not is_cutscene_active(p) or p.isme == false then
		return
	end

	p2.cleanup_tasks = p.cleanup_tasks

	if not v then
		local VFXUtil = require(script.Parent.VFXUtil)
		v = VFXUtil
	end

	track_cleanup_object(p, v.ScreenPulse(p2)) -- equivalent call inferred; original call site unknown
end

local function get_number_attribute(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return p
end

local function get_effect_duration(instance, p: number)
	local effectDuration = instance:GetAttribute("EffectDuration")

	if typeof(effectDuration) == "NumberRange" then
		return (math.max(effectDuration.Min, effectDuration.Max))
	end

	local duration = instance:GetAttribute("Duration")

	if typeof(duration) == "number" then
		p = duration
	end

	local emitDuration = instance:GetAttribute("EmitDuration")

	if typeof(emitDuration) == "number" then
		return emitDuration
	end

	return p
end

local collect_emit_refs

collect_emit_refs = function(list, value)
	if typeof(value) == "Instance" then
		table.insert(list, value)
	elseif type(value) == "table" then
		for _, item in pairs(value) do
			collect_emit_refs(list, item)
		end
	end
end

local function collect_emit_targets(effects, effect)
	if effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail") then
		table.insert(effects, effect)
	end

	for _, effect2 in ipairs(effect:GetDescendants()) do
		if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Beam") or effect2:IsA("Trail")) then
			continue
		end

		table.insert(effects, effect2)
	end
end

local function direct_emit_target(p, effect)
	local emitDelay = effect:GetAttribute("EmitDelay")
	local v2 = typeof(emitDelay) ~= "number" and 0 or emitDelay

	local function fn()
		if not effect.Parent then
			return
		end

		if effect:IsA("ParticleEmitter") then
			if effect.Enabled then
				effect.Enabled = false
			end

			local name = tonumber(effect.Name) or 1
			local emitCount = effect:GetAttribute("EmitCount")

			if typeof(emitCount) ~= "number" then
				emitCount = name
			end

			local v4 = effect
			local effectDuration = v4:GetAttribute("EffectDuration")
			local emitDuration

			if typeof(effectDuration) == "NumberRange" then
				emitDuration = math.max(effectDuration.Min, effectDuration.Max)
			else
				local duration = v4:GetAttribute("Duration")
				local v5 = typeof(duration) ~= "number" and 0 or duration
				emitDuration = v4:GetAttribute("EmitDuration")

				if typeof(emitDuration) ~= "number" then
					emitDuration = v5
				end
			end

			if emitDuration > 0 then
				effect.Enabled = true
			end

			if emitCount > 0 then
				effect:Emit(emitCount)
			end

			if emitDuration > 0 then
				local v5 = p

				local function fn2()
					if effect.Parent then
						effect.Enabled = false
					end
				end

				local thread = nil
				thread = task.delay(emitDuration, function()
					local v7 = thread
					local cleanup_tasks = v5 and v5.cleanup_tasks
					local index = cleanup_tasks and table.find(cleanup_tasks, v7)

					if index then
						table.remove(cleanup_tasks, index)
					end

					fn2()
				end)
				local v6 = thread
				local cleanup_tasks = v5 and v6 and v5.cleanup_tasks

				if cleanup_tasks then
					table.insert(cleanup_tasks, v6)
				end
			end
		elseif effect:IsA("Beam") or effect:IsA("Trail") then
			local v3 = effect
			local effectDuration = v3:GetAttribute("EffectDuration")
			local emitDuration

			if typeof(effectDuration) == "NumberRange" then
				emitDuration = math.max(effectDuration.Min, effectDuration.Max)
			else
				local duration = v3:GetAttribute("Duration")
				local v4 = typeof(duration) ~= "number" and 1 or duration
				emitDuration = v3:GetAttribute("EmitDuration")

				if typeof(emitDuration) ~= "number" then
					emitDuration = v4
				end
			end

			effect.Enabled = true
			local v4 = p

			local function fn2()
				if effect.Parent then
					effect.Enabled = false
				end
			end

			local thread = nil
			thread = task.delay(emitDuration, function()
				local v6 = thread
				local cleanup_tasks = v4 and v4.cleanup_tasks
				local index = cleanup_tasks and table.find(cleanup_tasks, v6)

				if index then
					table.remove(cleanup_tasks, index)
				end

				fn2()
			end)
			local v5 = thread
			local cleanup_tasks = v4 and v5 and v4.cleanup_tasks

			if cleanup_tasks then
				table.insert(cleanup_tasks, v5)
			end
		end
	end

	local thread = nil
	thread = task.delay(v2, function()
		local v4 = thread
		local cleanup_tasks = p and p.cleanup_tasks
		local index = cleanup_tasks and table.find(cleanup_tasks, v4)

		if index then
			table.remove(cleanup_tasks, index)
		end

		fn()
	end)
	local v3 = thread
	local cleanup_tasks = p and v3 and p.cleanup_tasks

	if cleanup_tasks then
		table.insert(cleanup_tasks, v3)
	end
end

local function emit_vfx(p, ...)
	local v2 = {}

	for i = 1, select("#", ...) do
		collect_emit_refs(v2, select(i, ...))
	end

	if #v2 == 0 then
		return
	end

	local v3 = {}

	for _, v4 in ipairs(v2) do
		collect_emit_targets(v3, v4)
	end

	if #v3 > 0 then
		for _, v4 in ipairs(v3) do
			local emitDelay = v4:GetAttribute("EmitDelay")
			local v5 = typeof(emitDelay) ~= "number" and 0 or emitDelay
			local effect = v4

			local function fn()
				if not effect.Parent then
					return
				end

				if effect:IsA("ParticleEmitter") then
					if effect.Enabled then
						effect.Enabled = false
					end

					local name = tonumber(effect.Name) or 1
					local emitCount = effect:GetAttribute("EmitCount")

					if typeof(emitCount) ~= "number" then
						emitCount = name
					end

					local v7 = effect
					local effectDuration = v7:GetAttribute("EffectDuration")
					local emitDuration

					if typeof(effectDuration) == "NumberRange" then
						emitDuration = math.max(effectDuration.Min, effectDuration.Max)
					else
						local duration = v7:GetAttribute("Duration")
						local v8 = typeof(duration) ~= "number" and 0 or duration
						emitDuration = v7:GetAttribute("EmitDuration")

						if typeof(emitDuration) ~= "number" then
							emitDuration = v8
						end
					end

					if emitDuration > 0 then
						effect.Enabled = true
					end

					if emitCount > 0 then
						effect:Emit(emitCount)
					end

					if emitDuration > 0 then
						local v8 = p

						local function fn2()
							if effect.Parent then
								effect.Enabled = false
							end
						end

						local thread = nil
						thread = task.delay(emitDuration, function()
							local v10 = thread
							local cleanup_tasks = v8 and v8.cleanup_tasks
							local index = cleanup_tasks and table.find(cleanup_tasks, v10)

							if index then
								table.remove(cleanup_tasks, index)
							end

							fn2()
						end)
						local v9 = thread
						local cleanup_tasks = v8 and v9 and v8.cleanup_tasks

						if cleanup_tasks then
							table.insert(cleanup_tasks, v9)
						end
					end
				elseif effect:IsA("Beam") or effect:IsA("Trail") then
					local v6 = effect
					local effectDuration = v6:GetAttribute("EffectDuration")
					local emitDuration

					if typeof(effectDuration) == "NumberRange" then
						emitDuration = math.max(effectDuration.Min, effectDuration.Max)
					else
						local duration = v6:GetAttribute("Duration")
						local v7 = typeof(duration) ~= "number" and 1 or duration
						emitDuration = v6:GetAttribute("EmitDuration")

						if typeof(emitDuration) ~= "number" then
							emitDuration = v7
						end
					end

					effect.Enabled = true
					local v7 = p

					local function fn2()
						if effect.Parent then
							effect.Enabled = false
						end
					end

					local thread = nil
					thread = task.delay(emitDuration, function()
						local v9 = thread
						local cleanup_tasks = v7 and v7.cleanup_tasks
						local index = cleanup_tasks and table.find(cleanup_tasks, v9)

						if index then
							table.remove(cleanup_tasks, index)
						end

						fn2()
					end)
					local v8 = thread
					local cleanup_tasks = v7 and v8 and v7.cleanup_tasks

					if cleanup_tasks then
						table.insert(cleanup_tasks, v8)
					end
				end
			end

			local thread = nil
			thread = task.delay(v5, function()
				local v8 = thread
				local cleanup_tasks = p and p.cleanup_tasks
				local index = cleanup_tasks and table.find(cleanup_tasks, v8)

				if index then
					table.remove(cleanup_tasks, index)
				end

				fn()
			end)
			local v7 = thread
			local cleanup_tasks = p and v7 and p.cleanup_tasks

			if cleanup_tasks then
				table.insert(cleanup_tasks, v7)
			end
		end
	else
		local shared2 = shared

		if shared2.vfx and shared2.vfx.emit then
			shared2.vfx.emit(table.unpack(v2))
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function get_character_vfx(p)
	return p.character_vfx or p.characterVFX
end

local function emit_limb_effects(p, list)
	local v2 = get_character_vfx(p) -- equivalent call inferred; original call site unknown

	if not v2 then
		return
	end

	local v3 = {}

	for _, v4 in ipairs(list) do
		local v5 = v2[v4]

		if not v5 then
			continue
		end

		for _, v6 in ipairs(v5.all) do
			table.insert(v3, v6)
		end
	end

	emit_vfx(p, table.unpack(v3))
end

local function emit_named_limb_effects(p, p2: string, list)
	local v2 = get_character_vfx(p) -- equivalent call inferred; original call site unknown
	local v3 = v2 and v2[p2]

	if not v3 then
		return
	end

	local v4 = {}
	local v5 = {}

	for _, v6 in ipairs(list) do
		local v7 = v3.byName[v6]

		if not v7 then
			continue
		end

		for _, v8 in ipairs(v7) do
			if v4[v8] then
				continue
			end

			v4[v8] = true
			table.insert(v5, v8)
		end
	end

	emit_vfx(p, table.unpack(v5))
end

local function set_model_visible(folder, flag: boolean)
	if not folder then
		return
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
			continue
		end

		if flag then
			local cutsceneOriginalTransparency = descendant:GetAttribute("CutsceneOriginalTransparency")
			descendant.Transparency = typeof(cutsceneOriginalTransparency) ~= "number" and 0 or cutsceneOriginalTransparency
		else
			if descendant:GetAttribute("CutsceneOriginalTransparency") == nil then
				descendant:SetAttribute("CutsceneOriginalTransparency", descendant.Transparency)
			end

			descendant.Transparency = 1
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function play_mask_spawn(p)
	set_model_visible(p.mask, true)
end

FrameEvents.frame_events = {
	[0] = function(data)
		local vfx = data.vfx
		local camera_rig = data.camera_rig
		local camera = camera_rig and camera_rig:FindFirstChild("Camera")
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 5 do
				task.wait(0.1)

				if vfx.Parent then
					vfx:PivotTo(data.character.HumanoidRootPart:GetPivot() * CFrame.Angles(0, 3.141592653589793, 0))
				end
			end
		end)
		emit_vfx(data, vfx.Handler.calm)

		if camera then
			emit_vfx(data, camera:FindFirstChild("blackstart"))
		end

		emit_named_limb_effects(data, "Head", { "eye" })
		local v2 = {
			fadeOut = 7,
			easingStyle = "Smoother",
			easingDirection = "Out",
			brightness = 0,
			contrast = 0.4,
			saturation = -0.8,
			tint = Color3.fromRGB(255, 255, 255)
		}

		if is_cutscene_active(data) then
			if data.isme == false then
				return
			end

			v2.cleanup_tasks = data.cleanup_tasks

			if not v then
				local VFXUtil = require(script.Parent.VFXUtil)
				v = VFXUtil
			end

			track_cleanup_object(data, v.ColorCorrection(v2)) -- equivalent call inferred; original call site unknown
		end
	end,
	[173] = function(p)
		emit_vfx(p, p.vfx.Handler.aura)
	end,
	[215] = function(p)
		repeat_delayed(p, 10, 0.3, function()
			local v2 = p
			local v3 = {
				fadeOut = 1,
				easingStyle = "Smoother",
				easingDirection = "Out",
				brightness = 0.2,
				contrast = 0.3,
				saturation = 0,
				tint = Color3.fromRGB(255, 255, 255)
			}

			if is_cutscene_active(v2) then
				if v2.isme == false then
					return
				end

				v3.cleanup_tasks = v2.cleanup_tasks

				if not v then
					local VFXUtil = require(script.Parent.VFXUtil)
					v = VFXUtil
				end

				track_cleanup_object(v2, v.ColorCorrection(v3)) -- equivalent call inferred; original call site unknown
			end
		end)
	end,
	[313] = function(p)
		local v2 = {
			fadeOut = 3,
			brightness = -1,
			saturation = -0.2,
			contrast = 25,
			tint = Color3.fromRGB(255, 0, 0)
		}

		if is_cutscene_active(p) then
			if p.isme == false then
				return
			end

			v2.cleanup_tasks = p.cleanup_tasks

			if not v then
				local VFXUtil = require(script.Parent.VFXUtil)
				v = VFXUtil
			end

			track_cleanup_object(p, v.ColorCorrection(v2)) -- equivalent call inferred; original call site unknown
		end
	end,
	[316] = function(p)
		emit_vfx(p, p.vfx.Handler.red)
	end,
	[326] = function(p)
		emit_limb_effects(p, {
			"Left Leg",
			"Right Arm",
			"Right Leg",
			"Torso",
			"Left Arm"
		})
		emit_named_limb_effects(p, "Head", {
			"blackspec",
			"blackfire",
			"wave2",
			"wave",
			"static",
			"splat",
			"specs",
			"spec",
			"smoke",
			"redfire",
			"lighting",
			"glow",
			"fire",
			"eyeflare"
		})
	end,
	[357] = function(p)
		repeat_delayed(p, 10, 0.5, function()
			local v2 = p
			local v3 = {
				fadeOut = 1,
				easingStyle = "Smoother",
				easingDirection = "Out",
				brightness = 0.2,
				contrast = 0.7,
				saturation = 0,
				tint = Color3.fromRGB(255, 195, 195)
			}

			if is_cutscene_active(v2) then
				if v2.isme == false then
					return
				end

				v3.cleanup_tasks = v2.cleanup_tasks

				if not v then
					local VFXUtil = require(script.Parent.VFXUtil)
					v = VFXUtil
				end

				track_cleanup_object(v2, v.ColorCorrection(v3)) -- equivalent call inferred; original call site unknown
			end
		end)
	end,
	[576] = function(p)
		play_mask_spawn(p) -- equivalent call inferred; original call site unknown
	end,
	[703] = function(p)
		emit_vfx(p, p.vfx.Handler.b0)
	end,
	[742] = function(p)
		local v2 = {
			fadeIn = 0.1,
			fadeOut = 2,
			pulseTransparency = 0.5,
			pulseColor = Color3.fromRGB(255, 43, 43),
			delayTime = 0.1
		}

		if is_cutscene_active(p) then
			if p.isme == false then
				return
			end

			v2.cleanup_tasks = p.cleanup_tasks

			if not v then
				local VFXUtil = require(script.Parent.VFXUtil)
				v = VFXUtil
			end

			track_cleanup_object(p, v.ScreenPulse(v2)) -- equivalent call inferred; original call site unknown
		end
	end
}
FrameEvents.fov_keyframes = {
	[0] = 30,
	[63] = 70,
	[122] = 70,
	[203] = 50,
	[310] = 50,
	[332] = 70,
	[421] = 70,
	[493] = 40,
	[579] = 70,
	[597] = 70,
	[627] = 40,
	[704] = 40,
	[741] = 70
}
FrameEvents.fov_eases = {
	[0] = {
		Type = "Circ",
		Direction = "Out"
	},
	[122] = {
		Type = "Cubic",
		Direction = "InOut"
	},
	[421] = {
		Type = "Quad",
		Direction = "InOut"
	},
	[493] = {
		Type = "Constant"
	},
	[597] = {
		Type = "Circ",
		Direction = "Out"
	},
	[704] = {
		Type = "Back",
		Direction = "In"
	},
	[741] = {
		Type = "Back",
		Direction = "Out"
	}
}
FrameEvents.image_keyframes.imagelabel.ImageTransparency = {
	[0] = 1,
	[12] = 0.19,
	[90] = 0.19,
	[898] = 0.19,
	[987] = 1
}
FrameEvents.brightness_keyframes = {
	[0] = 0,
	[835] = 0,
	[849] = -1,
	[891] = 0
}
return FrameEvents