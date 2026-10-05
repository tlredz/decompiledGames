local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local BufferSerialize = require(script.BufferSerialize)
local Sera = require(ReplicatedStorage.Modules.Sera)
local ReplicatedTween = {}
local schema = Sera.Schema({
	Time = Sera.Float32,
	EasingStyle = Sera.Uint8,
	EasingDirection = Sera.Uint8
})

function ReplicatedTween.Tween(_, p, p2, p3, callback)
	RunService:IsClient()
	ReplicatedTween:Replicate(p, p2, p3, Players:GetPlayers(), callback)
end

function ReplicatedTween:Replicate(object, data, items, list, callback)
	assert(object, "ReplicatedTweenService:Replicate() | No 'Object' argument provided.")
	assert(items, "ReplicatedTweenService:Replicate() | No 'Properties' argument provided.")
	assert(data, "ReplicatedTweenService:Replicate() | No 'Information' argument provided.")
	assert(data.Time, "ReplicatedTweenService:Replicate() | No 'Information.Time' argument provided.")
	assert(data.Time > 0, "ReplicatedTweenService:Replicate() | The 'Information.Time' argument cannot be 0 or lower.")
	local v = {
		EasingStyle = data.EasingStyle and data.EasingStyle.Value or Enum.EasingStyle.Linear.Value,
		EasingDirection = data.EasingDirection and data.EasingDirection.Value or Enum.EasingDirection.Out.Value,
		Time = math.clamp(data.Time, 0, 225)
	}

	if RunService:IsServer() and list ~= nil and #list > 0 then
		local serialized = Sera.Serialize(schema, v)
		local Network = require(ServerStorage.Modules.Network)
		Network:fireclients("ReplicatedTween", list, {
			Object = object,
			Information = serialized,
			Properties = BufferSerialize.Serialize(items)
		})
	end

	local PostTweenCallback

	PostTweenCallback = function()
		if callback then
			task.spawn(callback)
		end

		if RunService:IsServer() then
			for k, item in items do
				object[k] = item
			end
		end

		PostTweenCallback = nil
	end

	if RunService:IsClient() then
		local v2 = ReplicatedTween:Animate(object, v, items)

		if PostTweenCallback then
			v2.Completed:Once(PostTweenCallback)
		end
	else
		task.delay(data.Time, PostTweenCallback)
	end
end

function ReplicatedTween:Animate(p, data, p2)
	if not p and RunService:IsStudio() then
		warn("ReplicatedTweenService:Animate() | Could not play animation, tween failed to construct due to lack of instance.")
		return
	end

	if p == nil then
		return
	end

	local tween = TweenService:Create(
		p,
		TweenInfo.new(
			data.Time,
			Enum.EasingStyle:FromValue(data.EasingStyle),
			Enum.EasingDirection:FromValue(data.EasingDirection)
		),
		p2
	)
	tween.Completed:Once(function()
		tween:Destroy()
		tween = nil
	end)
	tween:Play()
	return tween
end

function ReplicatedTween:LoadEffectsNetworkCallbacks()
	if RunService:IsServer() then
		local Network = require(ServerStorage.Modules.Network)
		Network:create("ReplicatedTween", "event")
	elseif RunService:IsClient() then
		local Network = require(ReplicatedStorage.Modules.Network)
		Network:listen("ReplicatedTween", function(data)
			local deserialized = BufferSerialize.Deserialize(data.Properties)
			local deserialized2 = Sera.Deserialize(schema, data.Information)
			ReplicatedTween:Animate(data.Object, deserialized2, deserialized)
		end)
	end
end

ReplicatedTween:LoadEffectsNetworkCallbacks()
return ReplicatedTween