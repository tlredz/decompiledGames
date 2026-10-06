local module = require("@game/ReplicatedStorage/Omni")
local v = {}
local v2 = {}
local object = setmetatable({}, {
	__mode = "k"
})
local AnimationSync = {}

local function GetAnimationID(p)
	local v3 = object[p]

	if not v3 then
		v3 = string.match(p.AnimationId, "%d+")
		object[p] = v3
	end

	return v3
end

local function AddPair(p, p2, animation, looped: boolean)
	if not (p2 and animation) then
		return
	end

	local v3 = object[p2]

	if not v3 then
		v3 = string.match(p2.AnimationId, "%d+")
		object[p2] = v3
	end

	if not v3 or p.Pairs[v3] then
		return
	end

	local track = p.Animator:LoadAnimation(animation)
	track.Looped = looped
	p.Pairs[v3] = {
		Track = track,
		Looped = looped
	}
end

local function StopSources(player)
	if player.Character ~= module.Instance.Character then
		return
	end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	for _, v3 in animator:GetPlayingAnimationTracks() do
		local animation = v3.Animation
		local v4

		if animation then
			v4 = object[animation]

			if not v4 then
				v4 = string.match(animation.AnimationId, "%d+")
				object[animation] = v4
			end
		else
			v4 = animation
		end

		if v4 and player.Pairs[v4] then
			v3:Stop(0)
		end
	end
end

function AnimationSync.Clear(p)
	local v3 = v[p]

	if not v3 then
		return
	end

	v[p] = nil
	v3.Connection:Disconnect()
	StopSources(v3)

	for _, pair in v3.Pairs do
		pair.Track:Stop(0)
		pair.Track:Destroy()
		pair.Source = nil
	end

	table.clear(v3.Pairs)
end

function AnimationSync.Bind(instance, character, p2: string)
	local v3 = module.Shared.Weapons.List[p2]
	local render = v3 and v3.Render

	if not render or not render.ModelAnimations or v[instance] then
		return
	end

	local animationController = instance:FindFirstChildOfClass("AnimationController")
	local animator = animationController and animationController:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	local v4 = {
		Character = character,
		Animator = animator,
		Pairs = {}
	}

	for _, v5 in { render.Idle, render.Walk, render.Run } do
		AddPair(
			v4,
			module.Utils.Weapons.GetWeaponAnimation(p2, v5),
			module.Utils.Weapons.GetWeaponAnimation(p2, v5, true),
			true
		)
	end

	for k in v3.Hits do
		AddPair(
			v4,
			module.Utils.Weapons.GetWeaponHitAnimation(p2, k),
			module.Utils.Weapons.GetWeaponHitAnimation(p2, k, true),
			false
		)
	end

	local ultimate = v3.Ultimate

	if ultimate and ultimate.Animation then
		AddPair(
			v4,
			module.Utils.Weapons.GetWeaponAnimation(p2, ultimate.Animation),
			module.Utils.Weapons.GetWeaponAnimation(p2, ultimate.Animation, true),
			false
		)
	end

	v4.Connection = instance.Destroying:Connect(function()
		AnimationSync.Clear(instance)
	end)
	v[instance] = v4
end

function AnimationSync.Update(p, flag: boolean)
	local v3 = v[p]

	if not v3 then
		return
	end

	local humanoid = v3.Character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local v4 = not flag

	if v4 then
		if humanoid then
			if humanoid.Health > 0 then
				v4 = animator
			else
				v4 = false
			end
		else
			v4 = humanoid
		end
	end

	table.clear(v2)

	if v4 then
		for _, v5 in animator:GetPlayingAnimationTracks() do
			local animation = v5.Animation
			local v6

			if animation then
				v6 = object[animation]

				if not v6 then
					v6 = string.match(animation.AnimationId, "%d+")
					object[animation] = v6
				end
			else
				v6 = animation
			end

			if not (v6 and v3.Pairs[v6] and v5.IsPlaying) then
				continue
			end

			local v7 = v2[v6]

			if not v7 or v5.WeightCurrent > v7.WeightCurrent then
				v2[v6] = v5
			end
		end
	else
		StopSources(v3)
	end

	for k, pair in v3.Pairs do
		local source = v2[k]
		local track = pair.Track

		if source then
			if pair.Priority ~= source.Priority then
				pair.Priority = source.Priority
				track.Priority = source.Priority
			end

			local speed = source.Speed
			local weightCurrent = source.WeightCurrent

			if (pair.Source ~= source or not track.IsPlaying) and (pair.Looped or source.Length == 0 or source.TimePosition < source.Length - 0.016666666666666666) then
				track:Play(0, weightCurrent, speed)
				pair.Speed = speed
				pair.Weight = weightCurrent
			end

			pair.Source = source

			if pair.Speed ~= speed then
				pair.Speed = speed
				track:AdjustSpeed(speed)
			end

			if pair.Weight ~= weightCurrent then
				pair.Weight = weightCurrent
				track:AdjustWeight(weightCurrent, 0)
			end

			if track.IsPlaying and track.Length > 0 then
				local timePosition = math.clamp(source.TimePosition, 0, track.Length)

				if math.abs(track.TimePosition - timePosition) > 0.03333333333333333 then
					track.TimePosition = timePosition
				end
			end
		elseif pair.Source then
			track:Stop(0)
			pair.Source = nil
		end
	end
end

function AnimationSync.Destroy()
	for k in v do
		AnimationSync.Clear(k)
	end
end

script.Destroying:Connect(AnimationSync.Destroy)
return AnimationSync