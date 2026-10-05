local CollectionService = game:GetService("CollectionService")
local Config = require(script.Parent.Config)
local LoggerManager = require(script.Parent.Parent.LoggerManager)
require(script.Parent.Types)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})

local function loadTrack(animator, animationId: string, priority)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	animation:Destroy()
	track.Looped = true
	track.Priority = priority
	return track
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyMoving(p, flag: boolean)
	if flag then
		p.idle:Stop(Config.fadeSeconds)
		p.walk:Play(Config.fadeSeconds)
	else
		p.walk:Stop(Config.fadeSeconds)
		p.idle:Play(Config.fadeSeconds)
	end
end

local function createRigState(instance, data, animator, animationId: string)
	local v = {
		idle = 0,
		walk = 0,
		connections = 0
	}
	local idleAnimationId = Config.idleAnimationIds[data.RigType.Name]
	local idle = Enum.AnimationPriority.Idle
	local animation = Instance.new("Animation")
	animation.AnimationId = idleAnimationId
	local track = animator:LoadAnimation(animation)
	animation:Destroy()
	track.Looped = true
	track.Priority = idle
	v.idle = track
	local movement = Enum.AnimationPriority.Movement
	local animation2 = Instance.new("Animation")
	animation2.AnimationId = animationId
	local track2 = animator:LoadAnimation(animation2)
	animation2:Destroy()
	track2.Looped = true
	track2.Priority = movement
	v.walk = track2
	v.connections = {}
	applyMoving(v, instance:GetAttribute(Config.movingAttribute) == true) -- equivalent call inferred; original call site unknown
	table.insert(v.connections, instance:GetAttributeChangedSignal(Config.movingAttribute):Connect(function()
		if data.Health > 0 then
			applyMoving(v, instance:GetAttribute(Config.movingAttribute) == true) -- equivalent call inferred; original call site unknown
		end
	end))
	table.insert(v.connections, data.Died:Once(function()
		v.idle:Stop(0.2)
		v.walk:Stop(0.2)
	end))
	return v
end

local function releaseRigState(data)
	for _, connection in data.connections do
		connection:Disconnect()
	end

	data.idle:Stop(0)
	data.idle:Destroy()
	data.walk:Stop(0)
	data.walk:Destroy()
end

return {
	start = function(p)
		local v = {}
		local v2 = {}
		local connections = {}
		local v3 = true

		-- equivalent calls inferred from this helper; original call sites unknown
		local function detachRig(p2)
			v2[p2] = nil
			local v4 = v[p2]

			if v4 then
				releaseRigState(v4)
				v[p2] = nil
			end
		end

		local function attachRig(instance)
			if not (v[instance] or v2[instance]) then
				v2[instance] = true
				task.spawn(function()
					local humanoid = instance:WaitForChild("Humanoid", 5)
					local animator

					if humanoid then
						animator = humanoid:WaitForChild("Animator", 5)
					end

					v2[instance] = nil

					if v3 and animator and instance.Parent and not v[instance] then
						local success, result = pcall(createRigState, instance, humanoid, animator, p.walkAnimationId)

						if success then
							v[instance] = result
						else
							logger:warn(string.format("Wanderer animation failed: %s", (tostring(result))))
						end
					end
				end)
			end
		end

		table.insert(connections, CollectionService:GetInstanceAddedSignal(Config.tagName):Connect(function(model)
			if model:IsA("Model") and not (v[model] or v2[model]) then
				v2[model] = true
				task.spawn(function()
					local humanoid = model:WaitForChild("Humanoid", 5)
					local animator

					if humanoid then
						animator = humanoid:WaitForChild("Animator", 5)
					end

					v2[model] = nil

					if v3 and animator and model.Parent and not v[model] then
						local success, result = pcall(createRigState, model, humanoid, animator, p.walkAnimationId)

						if success then
							v[model] = result
						else
							logger:warn(string.format("Wanderer animation failed: %s", (tostring(result))))
						end
					end
				end)
			end
		end))
		table.insert(connections, CollectionService:GetInstanceRemovedSignal(Config.tagName):Connect(function(model)
			if model:IsA("Model") then
				detachRig(model) -- equivalent call inferred; original call site unknown
			end
		end))

		for _, model in CollectionService:GetTagged(Config.tagName) do
			if not model:IsA("Model") or not model:IsDescendantOf(workspace) or (v[model] or v2[model]) then
				continue
			end

			v2[model] = true
			local v4 = model
			task.spawn(function()
				local humanoid = v4:WaitForChild("Humanoid", 5)
				local animator

				if humanoid then
					animator = humanoid:WaitForChild("Animator", 5)
				end

				v2[v4] = nil

				if v3 and animator and v4.Parent and not v[v4] then
					local success, result = pcall(createRigState, v4, humanoid, animator, p.walkAnimationId)

					if success then
						v[v4] = result
					else
						logger:warn(string.format("Wanderer animation failed: %s", (tostring(result))))
					end
				end
			end)
		end

		return function()
			v3 = false

			for _, connection in connections do
				connection:Disconnect()
			end

			table.clear(connections)

			for k in v do
				detachRig(k) -- equivalent call inferred; original call site unknown
			end

			table.clear(v2)
		end
	end
}