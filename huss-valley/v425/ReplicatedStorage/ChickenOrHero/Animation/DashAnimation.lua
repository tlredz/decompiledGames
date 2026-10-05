local AnimationConfig = require(script.Parent.AnimationConfig)
local DashAnimationPolicy = require(script.Parent.DashAnimationPolicy)
local AnimationLibrary = require(script.Parent.AnimationLibrary)
local DashAnimation = {}
local v = {}

function DashAnimation.stop(instance)
	local v2 = v[instance]

	if not (v2 and v2.active) then
		return
	end

	v2.serial += 1
	v2.active = nil
	v2.facing = nil
	local serial = v2.serial

	for _, track in v2.tracks do
		if track.track.IsPlaying then
			track.track:Stop(AnimationConfig.Dash.FadeOut)
		end
	end

	instance:SetAttribute("DashAnimationActive", nil)
	task.delay(AnimationConfig.Dash.FadeOut, function()
		if v[instance] == v2 and v2.serial == serial and not v2.active then
			instance:SetAttribute("DashVisualFacing", nil)
		end
	end)
end

function DashAnimation.release(instance)
	local v2 = v[instance]

	if not v2 then
		return
	end

	v[instance] = nil

	for _, connection in v2.connections do
		connection:Disconnect()
	end

	for _, track in v2.tracks do
		track.track:Destroy()
	end

	instance:SetAttribute("DashAnimationActive", nil)
	instance:SetAttribute("DashVisualFacing", nil)
end

function DashAnimation.prepare(instance)
	if not (AnimationConfig.Enabled and AnimationConfig.Dash.Enabled) then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator or humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		return
	end

	local v2 = v[instance]

	if v2 and v2.animator ~= animator then
		DashAnimation.release(instance)
		v2 = nil
	end

	if not v2 then
		v2 = {
			animator = animator,
			tracks = {},
			connections = {},
			serial = 0,
			retryAt = {},
			attempts = {}
		}
		v[instance] = v2
		table.insert(v2.connections, instance.Destroying:Connect(function()
			DashAnimation.release(instance)
		end))
		table.insert(v2.connections, humanoid.Died:Connect(function()
			DashAnimation.stop(instance)
		end))
	end

	local now = os.clock()
	local v3 = AnimationLibrary.prepare()

	for _, v4 in { "DashLeft", "DashRight", "DashBack" } do
		local track = v2.tracks[v4]

		if track and track.track.Length <= 0 and now - track.loadedAt > 8 and (v2.attempts[v4] or 0) < 3 then
			track.track:Destroy()
			v2.tracks[v4] = nil
			track = nil
		end

		if track or not v3[v4] or not ((v2.retryAt[v4] or 0) <= now) or not ((v2.attempts[v4] or 0) < 3) then
			continue
		end

		v2.attempts[v4] = (v2.attempts[v4] or 0) + 1
		v2.retryAt[v4] = now + 2
		local v5 = v4
		local success, result = pcall(function()
			return animator:LoadAnimation(v3[v5].animation)
		end)

		if success then
			result.Name = "CoH_" .. v4
			result.Looped = false
			result.Priority = Enum.AnimationPriority.Action
			v2.tracks[v4] = {
				track = result,
				loadedAt = now
			}
		else
			warn("Chicken or Hero dash animation " .. v4 .. ": " .. tostring(result))
		end
	end

	return v2
end

function DashAnimation.isActive(p)
	local v2 = v[p]
	return v2 ~= nil and v2.active ~= nil and v2.active.IsPlaying and os.clock() < v2.endsAt
end

function DashAnimation.facing(p)
	local v2 = v[p]

	if DashAnimation.isActive(p) then
		return v2.facing
	end
end

function DashAnimation.play(instance, p, p2, p3)
	local v2, facing = DashAnimationPolicy.select(p, p2)

	if not v2 then
		return false
	end

	local v4 = DashAnimation.prepare(instance)
	local v5 = v4 and v4.tracks[v2]

	if not v5 or v5.track.Length <= 0 then
		return false
	end

	local timing, v6 = DashAnimationPolicy.timing(v5.track.Length, p3, AnimationConfig.Dash)

	if not timing then
		return false
	end

	DashAnimation.stop(instance)
	v4.serial += 1
	local track = v5.track
	local serial = v4.serial
	v4.active = track
	v4.facing = facing
	v4.endsAt = os.clock() + timing
	instance:SetAttribute("DashVisualFacing", facing)
	instance:SetAttribute("DashAnimationActive", true)
	instance:SetAttribute("LastDashAnimation", v2)
	track:Play(AnimationConfig.Dash.FadeIn, 1, v6)
	track.TimePosition = 0
	task.delay(timing, function()
		if v[instance] == v4 and v4.serial == serial then
			DashAnimation.stop(instance)
		end
	end)
	return true
end

return DashAnimation