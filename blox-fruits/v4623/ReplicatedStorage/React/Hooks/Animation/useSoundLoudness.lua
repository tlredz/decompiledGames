local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local Global = require(game.ReplicatedStorage.Global)

-- equivalent calls inferred from this helper; original call sites unknown
local function setDucked(flag: boolean)
	if Global.updateMusic2 then
		Global.updateMusic2(flag)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function play(sound)
	if not RunService:IsRunning() then
		SoundService:PlayLocalSound(sound)
		return
	end

	sound.Parent = SoundService
	sound:Play()
end

local function stop(sound, fadeOut: number)
	if fadeOut <= 0 then
		sound:Destroy()
		return
	end

	local tween = TweenService:Create(sound, TweenInfo.new(fadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Volume = 0
	})
	tween.Completed:Once(function()
		sound:Destroy()
	end)
	tween:Play()
end

return function(data, flag: boolean?)
	local state, setState = React.useState(0)
	React.useEffect(function()
		if not data then
			setState(0)
			return function() end
		end

		local sound = Instance.new("Sound")
		sound.SoundId = data.SoundId
		sound.Looped = data.Looped == true
		sound.Volume = data.Volume or 1
		play(sound) -- equivalent call inferred; original call site unknown
		local scale = data.Scale or 0.001
		local decay = data.Decay or 8
		local fadeOut = data.FadeOut or 3
		local v

		if data.Tempo and data.Tempo > 0 then
			v = 60 / data.Tempo
		else
			v = nil
		end

		local v2 = 0
		local v3 = 0
		local total = 0
		local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			total += dt
			local v4 = math.clamp(sound.PlaybackLoudness * scale, 0, 1)
			v3 = math.max(v3, v4)

			if v and v3 < 0.02 and total > 0.5 then
				v4 = (1 - total % v / v) ^ 3
			end

			if not (v2 < v4) then
				v4 = v2 + (v4 - v2) * math.min(1, dt * decay)
			end

			v2 = v4
			setState(v2)
		end)
		return function()
			renderSteppedConnection:Disconnect()
			stop(sound, fadeOut)
		end
	end, { data })
	React.useEffect(function()
		if not flag then
			return function() end
		end

		setDucked(true) -- equivalent call inferred; original call site unknown
		return function()
			setDucked(false) -- equivalent call inferred; original call site unknown
		end
	end, { flag })
	return state
end