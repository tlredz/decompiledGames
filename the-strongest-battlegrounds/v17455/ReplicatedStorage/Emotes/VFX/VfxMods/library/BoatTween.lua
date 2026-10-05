local RunService = game:GetService("RunService")
local TweenFunctions = require(script.TweenFunctions)
local Lerps = require(script.Lerps)
local heartbeat = RunService.Heartbeat
local BoatTween = {}
local v = {
	Heartbeat = true,
	Stepped = true,
	RenderStepped = true
}

if not RunService:IsClient() then
	v.RenderStepped = nil
end

local v2 = {
	FabricAccelerate = {
		In = TweenFunctions.InFabricAccelerate,
		Out = TweenFunctions.OutFabricAccelerate,
		InOut = TweenFunctions.InOutFabricAccelerate,
		OutIn = TweenFunctions.OutInFabricAccelerate
	},
	UWPAccelerate = {
		In = TweenFunctions.InUWPAccelerate,
		Out = TweenFunctions.OutUWPAccelerate,
		InOut = TweenFunctions.InOutUWPAccelerate,
		OutIn = TweenFunctions.OutInUWPAccelerate
	},
	Circ = {
		In = TweenFunctions.InCirc,
		Out = TweenFunctions.OutCirc,
		InOut = TweenFunctions.InOutCirc,
		OutIn = TweenFunctions.OutInCirc
	},
	RevBack = {
		In = TweenFunctions.InRevBack,
		Out = TweenFunctions.OutRevBack,
		InOut = TweenFunctions.InOutRevBack,
		OutIn = TweenFunctions.OutInRevBack
	},
	Spring = {
		In = TweenFunctions.InSpring,
		Out = TweenFunctions.OutSpring,
		InOut = TweenFunctions.InOutSpring,
		OutIn = TweenFunctions.OutInSpring
	},
	Standard = {
		In = TweenFunctions.InStandard,
		Out = TweenFunctions.OutStandard,
		InOut = TweenFunctions.InOutStandard,
		OutIn = TweenFunctions.OutInStandard
	},
	StandardExpressive = {
		In = TweenFunctions.InStandardExpressive,
		Out = TweenFunctions.OutStandardExpressive,
		InOut = TweenFunctions.InOutStandardExpressive,
		OutIn = TweenFunctions.OutInStandardExpressive
	},
	Linear = {
		In = TweenFunctions.InLinear,
		Out = TweenFunctions.OutLinear,
		InOut = TweenFunctions.InOutLinear,
		OutIn = TweenFunctions.OutInLinear
	},
	ExitProductive = {
		In = TweenFunctions.InExitProductive,
		Out = TweenFunctions.OutExitProductive,
		InOut = TweenFunctions.InOutExitProductive,
		OutIn = TweenFunctions.OutInExitProductive
	},
	Deceleration = {
		In = TweenFunctions.InDeceleration,
		Out = TweenFunctions.OutDeceleration,
		InOut = TweenFunctions.InOutDeceleration,
		OutIn = TweenFunctions.OutInDeceleration
	},
	Smoother = {
		In = TweenFunctions.InSmoother,
		Out = TweenFunctions.OutSmoother,
		InOut = TweenFunctions.InOutSmoother,
		OutIn = TweenFunctions.OutInSmoother
	},
	FabricStandard = {
		In = TweenFunctions.InFabricStandard,
		Out = TweenFunctions.OutFabricStandard,
		InOut = TweenFunctions.InOutFabricStandard,
		OutIn = TweenFunctions.OutInFabricStandard
	},
	RidiculousWiggle = {
		In = TweenFunctions.InRidiculousWiggle,
		Out = TweenFunctions.OutRidiculousWiggle,
		InOut = TweenFunctions.InOutRidiculousWiggle,
		OutIn = TweenFunctions.OutInRidiculousWiggle
	},
	MozillaCurve = {
		In = TweenFunctions.InMozillaCurve,
		Out = TweenFunctions.OutMozillaCurve,
		InOut = TweenFunctions.InOutMozillaCurve,
		OutIn = TweenFunctions.OutInMozillaCurve
	},
	Expo = {
		In = TweenFunctions.InExpo,
		Out = TweenFunctions.OutExpo,
		InOut = TweenFunctions.InOutExpo,
		OutIn = TweenFunctions.OutInExpo
	},
	Sine = {
		In = TweenFunctions.InSine,
		Out = TweenFunctions.OutSine,
		InOut = TweenFunctions.InOutSine,
		OutIn = TweenFunctions.OutInSine
	},
	Cubic = {
		In = TweenFunctions.InCubic,
		Out = TweenFunctions.OutCubic,
		InOut = TweenFunctions.InOutCubic,
		OutIn = TweenFunctions.OutInCubic
	},
	EntranceExpressive = {
		In = TweenFunctions.InEntranceExpressive,
		Out = TweenFunctions.OutEntranceExpressive,
		InOut = TweenFunctions.InOutEntranceExpressive,
		OutIn = TweenFunctions.OutInEntranceExpressive
	},
	Elastic = {
		In = TweenFunctions.InElastic,
		Out = TweenFunctions.OutElastic,
		InOut = TweenFunctions.InOutElastic,
		OutIn = TweenFunctions.OutInElastic
	},
	Quint = {
		In = TweenFunctions.InQuint,
		Out = TweenFunctions.OutQuint,
		InOut = TweenFunctions.InOutQuint,
		OutIn = TweenFunctions.OutInQuint
	},
	EntranceProductive = {
		In = TweenFunctions.InEntranceProductive,
		Out = TweenFunctions.OutEntranceProductive,
		InOut = TweenFunctions.InOutEntranceProductive,
		OutIn = TweenFunctions.OutInEntranceProductive
	},
	Bounce = {
		In = TweenFunctions.InBounce,
		Out = TweenFunctions.OutBounce,
		InOut = TweenFunctions.InOutBounce,
		OutIn = TweenFunctions.OutInBounce
	},
	Smooth = {
		In = TweenFunctions.InSmooth,
		Out = TweenFunctions.OutSmooth,
		InOut = TweenFunctions.InOutSmooth,
		OutIn = TweenFunctions.OutInSmooth
	},
	Back = {
		In = TweenFunctions.InBack,
		Out = TweenFunctions.OutBack,
		InOut = TweenFunctions.InOutBack,
		OutIn = TweenFunctions.OutInBack
	},
	Quart = {
		In = TweenFunctions.InQuart,
		Out = TweenFunctions.OutQuart,
		InOut = TweenFunctions.InOutQuart,
		OutIn = TweenFunctions.OutInQuart
	},
	StandardProductive = {
		In = TweenFunctions.InStandardProductive,
		Out = TweenFunctions.OutStandardProductive,
		InOut = TweenFunctions.InOutStandardProductive,
		OutIn = TweenFunctions.OutInStandardProductive
	},
	Quad = {
		In = TweenFunctions.InQuad,
		Out = TweenFunctions.OutQuad,
		InOut = TweenFunctions.InOutQuad,
		OutIn = TweenFunctions.OutInQuad
	},
	FabricDecelerate = {
		In = TweenFunctions.InFabricDecelerate,
		Out = TweenFunctions.OutFabricDecelerate,
		InOut = TweenFunctions.InOutFabricDecelerate,
		OutIn = TweenFunctions.OutInFabricDecelerate
	},
	Acceleration = {
		In = TweenFunctions.InAcceleration,
		Out = TweenFunctions.OutAcceleration,
		InOut = TweenFunctions.InOutAcceleration,
		OutIn = TweenFunctions.OutInAcceleration
	},
	SoftSpring = {
		In = TweenFunctions.InSoftSpring,
		Out = TweenFunctions.OutSoftSpring,
		InOut = TweenFunctions.InOutSoftSpring,
		OutIn = TweenFunctions.OutInSoftSpring
	},
	ExitExpressive = {
		In = TweenFunctions.InExitExpressive,
		Out = TweenFunctions.OutExitExpressive,
		InOut = TweenFunctions.InOutExitExpressive,
		OutIn = TweenFunctions.OutInExitExpressive
	},
	Sharp = {
		In = TweenFunctions.InSharp,
		Out = TweenFunctions.OutSharp,
		InOut = TweenFunctions.InOutSharp,
		OutIn = TweenFunctions.OutInSharp
	}
}

local function Wait(value)
	local v3 = math.max(value or 0.03, 0)
	local v4 = v3

	while v3 > 0 do
		v3 -= heartbeat:Wait()
	end

	return v4 - v3
end

function BoatTween.Create(_, instance, options)
	if not instance or typeof(instance) ~= "Instance" then
		return warn("Invalid object to tween:", instance)
	end

	local v3 = type(options) == "table" and (options or {}) or {}
	local v4 = v[v3.StepType] and RunService[v3.StepType] or RunService.Heartbeat
	local v5 = v2[v3.EasingStyle or "Quad"][v3.EasingDirection or "In"]
	local v6 = math.max(type(v3.Time) ~= "number" and 1 or v3.Time or 1, 0.001)
	local v7 = type(v3.Goal) ~= "table" and {} or v3.Goal or {}
	local delayTime

	if type(v3.DelayTime) == "number" and v3.DelayTime > 0.027 then
		delayTime = v3.DelayTime
	else
		delayTime = false
	end

	local v8 = (type(v3.RepeatCount) ~= "number" and 0 or math.max(v3.RepeatCount, -1) or 0) + 1
	local v9 = {}

	for k, v10 in pairs(v7) do
		v9[k] = Lerps[typeof(v10)](instance[k], v10)
	end

	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	local bindableEvent3 = Instance.new("BindableEvent")
	local connection = nil
	local now = os.clock()
	local v10 = 0
	local v11 = {}
	v11.Instance = instance
	v11.PlaybackState = Enum.PlaybackState.Begin
	v11.Completed = bindableEvent.Event
	v11.Resumed = bindableEvent3.Event
	v11.Stopped = bindableEvent2.Event

	function v11.Destroy()
		if connection then
			connection:Disconnect()
			connection = nil
		end

		bindableEvent:Destroy()
		bindableEvent2:Destroy()
		bindableEvent3:Destroy()
		v11 = nil
	end

	local v12 = false
	local v13 = 0
	local Play

	Play = function(value, p)
		if connection then
			connection:Disconnect()
			connection = nil
		end

		local v14 = value or 1

		if v8 == 0 or not (v8 < v14) then
			v13 = v14

			if p then
				v12 = true
			end

			if delayTime then
				v11.PlaybackState = Enum.PlaybackState.Delayed;
				(delayTime < 2 and Wait or wait)(delayTime)
			end

			now = os.clock() - v10
			connection = v4:Connect(function()
				v10 = os.clock() - now

				if v6 <= v10 then
					if p then
						for k, v15 in pairs(v9) do
							instance[k] = v15(0)
						end
					else
						for k, v15 in pairs(v9) do
							instance[k] = v15(1)
						end
					end

					connection:Disconnect()
					connection = nil

					if p then
						v10 = 0
						Play(v14 + 1, false)
					elseif v3.Reverses then
						v10 = 0
						Play(v14, true)
					else
						v10 = 0
						Play(v14 + 1, false)
					end
				else
					local v15 = p and 1 - v10 / v6 or v10 / v6
					local v16 = math.clamp(v5(v15), 0, 1)

					for k, v17 in pairs(v9) do
						instance[k] = v17(v16)
					end
				end
			end)
			v11.PlaybackState = Enum.PlaybackState.Playing
		else
			v11.PlaybackState = Enum.PlaybackState.Completed
			bindableEvent:Fire()
			v12 = false
			v13 = 1
		end
	end

	function v11.Play()
		v10 = 0
		Play(1, false)
	end

	function v11.Stop()
		if connection then
			connection:Disconnect()
			connection = nil
			v11.PlaybackState = Enum.PlaybackState.Cancelled
			bindableEvent2:Fire()
		end
	end

	function v11.Resume()
		Play(v13, v12)
		bindableEvent3:Fire()
	end

	return v11
end

return BoatTween