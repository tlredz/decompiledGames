require(script.Parent.Types)
local v = {
	idle = "rbxassetid://507766388",
	walk = "rbxassetid://507777826",
	run = "rbxassetid://507767714",
	jump = "rbxassetid://507765000",
	fall = "rbxassetid://507767968",
	climb = "rbxassetid://507765644"
}
local v2 = {
	idle = Enum.AnimationPriority.Idle,
	walk = Enum.AnimationPriority.Movement,
	run = Enum.AnimationPriority.Movement,
	jump = Enum.AnimationPriority.Action,
	fall = Enum.AnimationPriority.Action,
	climb = Enum.AnimationPriority.Movement
}
local v3 = {
	"idle",
	"walk",
	"run",
	"jump",
	"fall",
	"climb"
}
local Animation = {}
local v4 = {}
local v5 = nil
local v6 = nil
local enabled = false

local function resolveAnimationId(instance, childName: string)
	local child

	if instance ~= nil then
		child = instance:FindFirstChild(childName)
	end

	local animation

	if child ~= nil then
		animation = child:FindFirstChildOfClass("Animation")
	end

	if animation == nil then
		return v[childName]
	end

	return animation.AnimationId
end

local function loadTrack(animator, p: string, animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	track.Priority = v2[p]
	track.Looped = p ~= "jump"
	animation:Destroy()
	return track
end

local function stopAnimateTracks(animator, folder, p)
	local v7 = {}

	for _, animation in folder:GetDescendants() do
		if animation:IsA("Animation") then
			v7[animation.AnimationId] = true
		end
	end

	for _, v8 in animator:GetPlayingAnimationTracks() do
		if v7[v8.Animation.AnimationId] then
			v8:Stop(p.animationFadeTime)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveTrackName(p, p2: number, p3: number)
	if p == "climbing" then
		return "climb"
	elseif p == "freefall" then
		return "fall"
	elseif p == "jumping" then
		return "jump"
	end

	if p3 * 0.75 < p2 then
		return "move"
	end

	return "idle"
end

local function forEachTrack(p: string, callback)
	if p ~= "move" then
		callback(v4[p])
		return
	end

	callback(v4.walk)
	callback(v4.run)
end

local function applyMoveSpeed(p: number, p2: number)
	local v7 = p / 16 * 1.25 / p2
	local v8 = 0.0001
	local v9 = 0.0001
	local v10 = 1

	if v7 <= 0.5 then
		v10 = v7 / 0.5
		v8 = 1
	elseif v7 < 1 then
		v9 = (v7 - 0.5) / 0.5
		v8 = 1 - v9
	else
		v10 = v7 / 1
		v9 = 1
	end

	v4.walk:AdjustWeight(v8)
	v4.run:AdjustWeight(v9)
	v4.walk:AdjustSpeed(v10)
	v4.run:AdjustSpeed(v10)
end

function Animation.bind(instance, animator, p)
	local animate = instance:FindFirstChild("Animate")

	if animate ~= nil and animate:IsA("LocalScript") then
		v6 = animate
		enabled = animate.Enabled
		animate.Enabled = false
		stopAnimateTracks(animator, animate, p)
	end

	for _, childName in v3 do
		local v7 = v4
		local child

		if animate ~= nil then
			child = animate:FindFirstChild(childName)
		end

		local animation

		if child ~= nil then
			animation = child:FindFirstChildOfClass("Animation")
		end

		local animationId

		if animation == nil then
			animationId = v[childName]
		else
			animationId = animation.AnimationId
		end

		local animation2 = Instance.new("Animation")
		animation2.AnimationId = animationId
		local track = animator:LoadAnimation(animation2)
		track.Priority = v2[childName]
		track.Looped = childName ~= "jump"
		animation2:Destroy()
		v7[childName] = track
	end

	Animation.apply("running", 0, 1, p)
end

function Animation.unbind(p)
	for _, v7 in v4 do
		v7:Stop(p.animationFadeTime)
		v7:Destroy()
	end

	table.clear(v4)
	v5 = nil
	local v7 = v6

	if v7 ~= nil and v7.Parent ~= nil then
		v7.Enabled = enabled
	end

	v6 = nil
end

function Animation.stop(p)
	local v7 = v5

	if v7 ~= nil then
		if v7 == "move" then
			v4.walk:Stop(p.animationFadeTime)
			v4.run:Stop(p.animationFadeTime)
		else
			v4[v7]:Stop(p.animationFadeTime)
		end
	end

	v5 = nil
end

function Animation.apply(p, p2: number, p3: number, p4)
	local trackName = resolveTrackName(p, p2, p3) -- equivalent call inferred; original call site unknown

	if trackName ~= v5 then
		Animation.stop(p4)

		if trackName == "move" then
			v4.walk:Play(p4.animationFadeTime)
			v4.run:Play(p4.animationFadeTime)
		else
			v4[trackName]:Play(p4.animationFadeTime)
		end

		v5 = trackName
	end

	if trackName == "move" then
		applyMoveSpeed(p2, p3)
	elseif trackName == "climb" then
		v4.climb:AdjustSpeed(p2 / p3 / 5)
	end
end

return Animation