local AnimationUtil = {}
local v = {}

function AnimationUtil:StopAllAnimations(p)
	local v2 = v[p]

	if v2 then
		for k, v3 in v2 do
			v3:Stop()
			v3:Destroy()
			v2[k] = nil
		end
	end
end

function AnimationUtil.UnloadAnimation(_, p, p2)
	local v2 = v[p]

	if not v2 then
		return
	end

	local v3 = v2[p2]

	if not v3 then
		return
	end

	v3:Stop()
	v3:Destroy()
	v2[p2] = nil
	return true
end

function AnimationUtil:LoadAnimation(animator, value, p)
	if typeof(value) == "string" then
		local v2 = script:FindFirstChild(value) or Instance.new("Animation")
		v2.Name = value
		v2.AnimationId = value
		v2.Parent = script
		value = v2
	end

	local v2 = p or value.Name

	if not v[animator] then
		v[animator] = {}
		local connections = {}

		local function cleanup()
			for _, connection in connections do
				connection:Disconnect()
			end

			connections = {}
			AnimationUtil:StopAllAnimations(animator)
			v[animator] = nil
		end

		table.insert(connections, animator.AncestryChanged:Connect(function(_, parent)
			if not parent then
				cleanup()
			end
		end))
		table.insert(connections, animator.Died:Connect(cleanup))
	end

	local tracks = v[animator]
	local v3 = tracks[v2]

	if v3 then
		return v3
	end

	local track = animator:LoadAnimation(value)
	tracks[v2] = track
	return track
end

function AnimationUtil.GetLoadedTracks(_, p)
	return v[p] or {}
end

return AnimationUtil