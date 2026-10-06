local module = require("@game/ReplicatedStorage/Omni")
local parentModule = require(script.Parent)
local Ultimates = require(script.Parent.Ultimates)
local v = {}
local UltimateRunner = {}

local function ClearResources(p)
	for _, resource in p.Resources do
		if typeof(resource) == "Instance" then
			resource:Destroy()
		elseif typeof(resource) == "RBXScriptConnection" then
			resource:Disconnect()
		elseif typeof(resource) == "function" then
			local success, result = pcall(resource)

			if not success then
				warn((`[Weapons] Renderer cleanup failed: {result}`))
			end
		end
	end

	table.clear(p.Resources)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetSoundsFolder(skillWeapon: string)
	local sounds = module.Assets:FindFirstChild("Sounds")
	local weapons = sounds and sounds:FindFirstChild("Weapons")
	return weapons and weapons:FindFirstChild(skillWeapon)
end

local function UpdateSounds(state, p: number)
	local soundTimeline = state.SoundTimeline

	while state.SoundCursor <= #soundTimeline and soundTimeline[state.SoundCursor].Time <= p do
		local v2 = soundTimeline[state.SoundCursor]
		state.SoundCursor += 1
		local child = state.SoundsFolder and state.SoundsFolder:FindFirstChild(v2.Name)

		if child and p - v2.Time <= 0.2 then
			table.insert(state.Sounds, module.Sound:Play(child, state.HRP, false, {
				Group = state.HRP,
				Cooldown = 0,
				MaxVoices = 4
			}))
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopSounds(p, completed: boolean)
	if not completed then
		for _, sound in p.Sounds do
			sound:cancel()
		end
	end

	table.clear(p.Sounds)
end

local function CallRenderer(p, p2: string)
	local v2 = p.Renderer and p.Renderer[p2]

	if not v2 then
		return
	end

	local success, result = pcall(v2, p)

	if not success then
		warn((`[Weapons] Renderer {p2} failed: {result}`))
		p.Renderer = nil
		ClearResources(p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsVisible(player)
	local v2 = player == module.Instance and "Show My Skills" or "Show Other Skills"
	return module.Data.Settings[v2] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HideVisuals(state)
	local clear = state.Initialized and state.Renderer and state.Renderer.Clear

	if clear then
		local success, result = pcall(clear, state)

		if not success then
			warn((`[Weapons] Renderer Clear failed: {result}`))
			state.Renderer = nil
			ClearResources(state)
		end
	end

	ClearResources(state)
	StopSounds(state, false) -- equivalent call inferred; original call site unknown
	parentModule.RemoveEffect(state.Effect)
	state.Effect = nil
	state.Index = nil
	state.Initialized = nil
end

function UltimateRunner.Clear(p, flag: boolean?)
	local v2 = v[p]

	if not v2 then
		return
	end

	v2.Completed = flag == true
	local clear = v2.Initialized and v2.Renderer and v2.Renderer.Clear

	if clear then
		local success, result = pcall(clear, v2)

		if not success then
			warn((`[Weapons] Renderer Clear failed: {result}`))
			v2.Renderer = nil
			ClearResources(v2)
		end
	end

	ClearResources(v2)
	StopSounds(v2, v2.Completed) -- equivalent call inferred; original call site unknown

	if v2.Track then
		local track = v2.Track

		if flag and track.IsPlaying then
			track.Stopped:Once(function()
				track:Destroy()
			end)
			module.Services.Debris:AddItem(track, math.max(0, track.Length - track.TimePosition) + 0.2)
		else
			track:Stop()
			track:Destroy()
		end
	end

	parentModule.RemoveEffect(v2.Effect)
	v[p] = nil
end

function UltimateRunner.Update(player)
	local skillRunID = player:GetAttribute("SkillRunID")
	local v2 = v[player]

	if not (skillRunID or v2) then
		return
	end

	local skillPhaseIndex = player:GetAttribute("SkillPhaseIndex")
	local skillWeapon = player:GetAttribute("SkillWeapon")
	local v3 = skillWeapon and module.Shared.Weapons.List[skillWeapon]
	local ultimate = v3 and v3.Ultimate
	local phase = ultimate and skillPhaseIndex and ultimate.Phases[skillPhaseIndex]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if skillRunID and phase and humanoidRootPart and player:GetAttribute("SkillActive") then
		if v2 and (v2.ID ~= skillRunID or v2.Character ~= character) then
			UltimateRunner.Clear(player)
			v2 = nil
		end

		local skillOrigin = player:GetAttribute("SkillOrigin")
		local skillDirection = player:GetAttribute("SkillDirection")
		local skillPhaseStartedAt = player:GetAttribute("SkillPhaseStartedAt")

		if typeof(skillOrigin) ~= "Vector3" or typeof(skillDirection) ~= "Vector3" or typeof(skillPhaseStartedAt) ~= "number" then
			return
		end

		if not v2 then
			v2 = {
				ID = skillRunID,
				Player = player,
				Character = character,
				HRP = humanoidRootPart,
				Skill = ultimate,
				Renderer = Ultimates.Get(ultimate.Renderer),
				Resources = {},
				SoundsFolder = 0,
				SoundTimeline = 0,
				SoundCursor = 1,
				Sounds = 0
			}
			v2.SoundsFolder = GetSoundsFolder(skillWeapon)
			v2.SoundTimeline = module.Shared.Weapons.Ultimate.GetSoundTimeline(ultimate)
			v2.Sounds = {}
			v[player] = v2
			local animator = character:FindFirstChildWhichIsA("Animator", true)
			local v5 = ultimate.Animation and module.Utils.Weapons.GetWeaponAnimation(skillWeapon, ultimate.Animation)

			if player == module.Instance and animator and v5 and skillPhaseIndex == 1 then
				local track = animator:LoadAnimation(v5)
				track.Priority = Enum.AnimationPriority.Action4
				track.Looped = false
				track:Play()
				v2.Track = track
				v2.AnimationStartedAt = skillPhaseStartedAt
			end
		end

		local serverTimeNow = workspace:GetServerTimeNow()

		if v2.Track and not v2.AnimationSynced and v2.Track.Length > 0 then
			v2.Track.TimePosition = math.clamp(serverTimeNow - v2.AnimationStartedAt, 0, v2.Track.Length)
			v2.AnimationSynced = true
		end

		local elapsed = math.clamp(serverTimeNow - skillPhaseStartedAt, 0, phase.Duration or 0)
		local v6 = skillOrigin + skillDirection * (phase.Speed or 0) * elapsed
		local cframe = CFrame.lookAt(v6, v6 + skillDirection)
		v2.Phase = phase
		v2.Origin = skillOrigin
		v2.Direction = skillDirection
		v2.StartedAt = skillPhaseStartedAt
		v2.Elapsed = elapsed
		v2.Progress = not (phase.Duration and phase.Duration > 0) and 0 or elapsed / phase.Duration
		v2.Transform = cframe

		if IsVisible(player) then
			if not v2.Initialized then
				v2.Initialized = true
				local setup = v2.Renderer and v2.Renderer.Setup

				if setup then
					local success, result = pcall(setup, v2)

					if not success then
						warn((`[Weapons] Renderer Setup failed: {result}`))
						v2.Renderer = nil
						ClearResources(v2)
					end
				end
			end

			if v2.Index ~= skillPhaseIndex then
				parentModule.RemoveEffect(v2.Effect)
				v2.Effect = nil
				v2.Index = skillPhaseIndex

				if phase.Vfx then
					local clone = table.clone(phase.Vfx)

					if clone.Enable and not clone.Duration then
						clone.Duration = phase.Duration
					end

					v2.Effect = parentModule.CreateEffect(character, skillWeapon, "Skill", clone, cframe)
				end

				local onPhase = v2.Renderer and v2.Renderer.OnPhase

				if onPhase then
					local success, result = pcall(onPhase, v2)

					if not success then
						warn((`[Weapons] Renderer OnPhase failed: {result}`))
						v2.Renderer = nil
						ClearResources(v2)
					end
				end
			end

			if v2.Effect and v2.Effect.Parent and not phase.Vfx.Weld then
				v2.Effect:PivotTo(cframe * (phase.Vfx.Offset or CFrame.identity))
			end

			for i = 1, skillPhaseIndex - 1 do
				elapsed += ultimate.Phases[i].Duration
			end

			UpdateSounds(v2, elapsed)
			local update = v2.Renderer and v2.Renderer.Update

			if not update then
				return
			end

			local success, result = pcall(update, v2)

			if not success then
				warn((`[Weapons] Renderer Update failed: {result}`))
				v2.Renderer = nil
				ClearResources(v2)
			end
		elseif v2.Initialized or v2.Effect then
			HideVisuals(v2) -- equivalent call inferred; original call site unknown
		end
	else
		local v5 = v2 and not player:GetAttribute("SkillActive") and player:GetAttribute("SkillCompletedRunID") == v2.ID
		UltimateRunner.Clear(player, v5)
	end
end

return UltimateRunner