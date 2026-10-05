local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EmotesInfo = require(ReplicatedStorage.CAM.Global.EmotesInfo)
local parentModule = require(script.Parent)
return function(instance)
	local v2 = EmotesInfo[instance.Name] or {}
	local startLength = v2.StartLength or 0
	local vfxCue = v2.VfxCue
	local cueOnLoop = v2.CueOnLoop == true

	local function clip(childName: string)
		local animation = instance:FindFirstChild(childName)

		if animation == nil or not animation:IsA("Animation") then
			return nil
		end

		return animation
	end

	local function startClip()
		local startClip2 = instance:FindFirstChild("StartClip")

		if startClip2 == nil or not startClip2:IsA("Animation") then
			startClip2 = nil
		end

		if startClip2 then
			return startClip2
		end

		local clip2 = instance:FindFirstChild("Clip")

		if clip2 ~= nil and clip2:IsA("Animation") then
			return clip2
		end

		startClip2 = nil
		return startClip2
	end

	local function listen(track, p, flag: boolean)
		if vfxCue == nil and not (cueOnLoop and flag) then
			return
		end

		local v3 = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hit()
			local now = os.clock()

			if now - v3 < 0.05 then
				return
			end

			v3 = now
			parentModule.Fire()
		end

		local cues = p.Cues

		if cues == nil then
			cues = {}
			p.Cues = cues
		end

		if vfxCue ~= nil then
			table.insert(cues, track:GetMarkerReachedSignal(vfxCue):Connect(hit))
			table.insert(cues, track.KeyframeReached:Connect(function(p2: string)
				if p2 == vfxCue then
					hit() -- equivalent call inferred; original call site unknown
				end
			end))
		end

		if cueOnLoop and flag then
			table.insert(cues, track.DidLoop:Connect(hit))
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playLoop(animator, p)
		local loopedClip = instance:FindFirstChild("LoopedClip")

		if loopedClip == nil or not loopedClip:IsA("Animation") then
			loopedClip = nil
		end

		if loopedClip == nil then
			return
		end

		local track = animator:LoadAnimation(loopedClip)
		track.Looped = true
		track:Play(0.2)
		p.Loop = track
		listen(track, p, true)
	end

	local function stopAll(p)
		p.Ended = true

		if p.Cues ~= nil then
			for _, cue in p.Cues do
				cue:Disconnect()
			end

			p.Cues = nil
		end

		for _, v3 in { "Start", "Loop" } do
			local v4 = p[v3]

			if v4 == nil then
				continue
			end

			v4:Stop(0.15)
			p[v3] = nil
		end
	end

	return {
		Display = function()
			local v3 = nil
			local loopedClip = instance:FindFirstChild("LoopedClip")

			if loopedClip == nil or not loopedClip:IsA("Animation") then
				loopedClip = nil
			end

			if loopedClip then
				return v3, loopedClip
			end

			loopedClip = instance:FindFirstChild("StartClip")

			if loopedClip == nil or not loopedClip:IsA("Animation") then
				loopedClip = nil
			end

			if loopedClip then
				return v3, loopedClip
			end

			local clip2 = instance:FindFirstChild("Clip")

			if clip2 ~= nil and clip2:IsA("Animation") then
				return v3, clip2
			end

			loopedClip = nil
			return v3, loopedClip
		end,
		Do = function(instance2, p)
			local animator = instance2:FindFirstChildWhichIsA("Animator", true)

			if animator == nil then
				return
			end

			local startClip2 = instance:FindFirstChild("StartClip")

			if startClip2 == nil or not startClip2:IsA("Animation") then
				startClip2 = nil
			end

			if not startClip2 then
				startClip2 = instance:FindFirstChild("Clip")

				if startClip2 == nil or not startClip2:IsA("Animation") then
					startClip2 = nil
				end
			end

			if startClip2 == nil then
				playLoop(animator, p) -- equivalent call inferred; original call site unknown
			else
				local track = animator:LoadAnimation(startClip2)
				track.Looped = false
				track:Play()
				p.Start = track
				listen(track, p, false)
				task.delay(startLength, function()
					if p.Ended then
						return
					end

					playLoop(animator, p) -- equivalent call inferred; original call site unknown
				end)
			end
		end,
		Stop = function(self, p)
			stopAll(p)
		end,
		Cancel = function(_, p)
			stopAll(p)
		end
	}
end