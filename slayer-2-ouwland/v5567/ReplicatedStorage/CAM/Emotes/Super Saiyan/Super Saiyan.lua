local SuperSaiyan = {}

local function clip()
	local clip2 = script:FindFirstChild("Clip")

	if clip2 == nil or not clip2:IsA("Animation") then
		return nil
	end

	return clip2
end

function SuperSaiyan.Display()
	local v = nil
	local clip2 = script:FindFirstChild("Clip")

	if clip2 == nil or not clip2:IsA("Animation") then
		return v, nil
	end

	return v, clip2
end

function SuperSaiyan.Do(instance, p)
	local clip2 = script:FindFirstChild("Clip")

	if clip2 == nil or not clip2:IsA("Animation") then
		clip2 = nil
	end

	local animator = instance:FindFirstChildWhichIsA("Animator", true)

	if clip2 == nil or animator == nil then
		return
	end

	local track = animator:LoadAnimation(clip2)
	track.Looped = true
	track:Play()
	p.Track = track
end

function SuperSaiyan.Stop(_, p)
	local track = p.Track

	if track ~= nil then
		track:Stop()
		p.Track = nil
	end
end

function SuperSaiyan.Cancel(p, p2)
	SuperSaiyan.Stop(p, p2)
end

return SuperSaiyan