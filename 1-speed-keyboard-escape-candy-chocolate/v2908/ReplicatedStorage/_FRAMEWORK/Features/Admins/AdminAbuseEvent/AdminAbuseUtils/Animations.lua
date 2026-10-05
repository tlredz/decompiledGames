local ContentProvider = game:GetService("ContentProvider")
local v = nil
local animations = {}
local animations2 = {}

local function findAnimator(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator then
		return animator
	end

	local animationController = instance:FindFirstChildOfClass("AnimationController")

	if not animationController then
		return nil
	end

	local v2 = animationController:FindFirstChildOfClass("Animator")

	if not v2 then
		v2 = Instance.new("Animator")
		v2.Parent = animationController
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOrCreatePreloadModel()
	if v then
		return v
	end

	local model = Instance.new("Model")
	model.Name = "AdminAbuseAnimationPreloader"
	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.Parent = model
	local animator = Instance.new("Animator")
	animator.Name = "Animator"
	animator.Parent = humanoid
	v = model
	return model
end

local function hasLoadableAssetId(value: string)
	local v2 = string.match(value, "(%d+)%s*$")
	return v2 ~= nil and string.find(v2, "[1-9]") ~= nil
end

local function resolveAnimation(instance)
	if typeof(instance) == "Instance" then
		return instance, false, instance.AnimationId
	end

	local animationId = tostring(instance)

	if not string.find(animationId, "://", 1, true) then
		animationId = `rbxassetid://{animationId}`
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	return animation, true, animationId
end

local Animations = {
	loadAnimation = function(instance, p)
		local animator = findAnimator(instance)
		assert(animator, (`AdminAbuseUtils.Animations could not find an Animator inside {instance:GetFullName()}`))
		local animation, v2 = resolveAnimation(p)
		local track = animator:LoadAnimation(animation)

		if v2 then
			animation:Destroy()
		end

		return track
	end
}

function Animations.preload(p)
	local animation, v2, v3 = resolveAnimation(p)
	local v4 = animations2[v3]

	if v4 then
		if v2 then
			animation:Destroy()
		end

		return v4
	else
		local preloadModel = getOrCreatePreloadModel() -- equivalent call inferred; original call site unknown
		local animation2 = Animations.loadAnimation(preloadModel, animation)

		if v2 then
			animation:Destroy()
		end

		table.insert(animations, animation2)
		animations2[v3] = animation2
		return animation2
	end
end

function Animations.preloadAsync(items, options)
	local v2 = options or {}
	local v3 = math.max(1, v2.maxAttempts or 6)
	local v4 = math.max(0, v2.retryBaseSeconds or 3)
	local v5 = math.max(v4, v2.retryMaxSeconds or 30)
	local v6 = {}
	local v7 = {}

	for _, item in items do
		local animation, v8, v9 = resolveAnimation(item)

		if v8 then
			animation:Destroy()
		end

		local v10 = string.match(v9, "(%d+)%s*$")
		local v11

		if v10 == nil then
			v11 = false
		else
			v11 = string.find(v10, "[1-9]") ~= nil
		end

		if not v11 or v6[v9] then
			continue
		end

		v6[v9] = true
		v7[#v7 + 1] = v9
	end

	local count = 0

	while #v7 > 0 and count < v3 do
		count += 1
		local v8 = {}
		local success, result = pcall(function()
			ContentProvider:PreloadAsync(v7, function(p: string, p2)
				if p2 == nil or p2 == Enum.AssetFetchStatus.Success then
					v8[p] = true
				end
			end)
		end)

		if not success then
			warn((`AdminAbuseUtils.Animations.preloadAsync: attempt {count} errored: {result}`))
		end

		local v10 = {}

		for _, v11 in v7 do
			if not v8[v11] then
				v10[#v10 + 1] = v11
			end
		end

		v7 = v10

		if #v7 > 0 and count < v3 then
			task.wait((math.min(v4 * 2 ^ (count - 1), v5)))
		end
	end

	if #v7 > 0 then
		warn(`AdminAbuseUtils.Animations.preloadAsync: gave up on {#v7} animation(s) after ` .. `{count} attempts: {table.concat(v7, ", ")}`)
	end
end

function Animations.cleanup()
	for _, v2 in animations do
		v2:Destroy()
	end

	table.clear(animations)
	table.clear(animations2)

	if v then
		v:Destroy()
		v = nil
	end
end

return Animations