local result = {}
local v = {}
local v2 = {}
local v3 = {}
local AnimationPlayer = {}
local mechanims = {
	[85166661837727] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[72881682195727] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action3
	},
	[119200907942880] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action3
	},
	[71400733435974] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[111106456938213] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[86157437083204] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[133068393244196] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action
	},
	[108540171116585] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[97376427568762] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[95593292947426] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[133153701552920] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[120495253991846] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[80479722047642] = {
		Looped = false
	},
	[136432357670037] = {
		Looped = false
	},
	[98093529031758] = {
		Looped = false
	},
	[132749700521148] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[73164438751875] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[121434691577715] = {
		Looped = false
	},
	[102363056607622] = {
		Looped = false
	},
	[123296069589003] = {
		Looped = false
	},
	[134784174843500] = {
		Looped = false
	},
	[109396157070251] = {
		Looped = false
	},
	[127088933881496] = {
		Looped = false
	},
	[73536157885878] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[107470574646661] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[128263166320457] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action4
	},
	[84567735972914] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action2
	},
	[78471512268273] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action2
	},
	[125686360016567] = {
		Looped = false,
		Priority = Enum.AnimationPriority.Action3
	}
}
AnimationPlayer.mechanims = mechanims
local v5 = {
	Looped = true,
	IsPlaying = true,
	Stopped = {},
	Play = function(_) end,
	Stop = function(_) end,
	AdjustSpeed = function(_) end
}

function v5.Stopped:Connect(callback)
	callback()
end

local function getAnimationNumber(value)
	if typeof(value) == "number" then
		return value
	end

	if typeof(value) ~= "string" then
		return
	end

	if string.find(value, "rbxassetid") then
		value = string.gsub(value, "rbxassetid://", ""):gsub("[^%-%d]", "")
	end

	return (tonumber(value))
end

local function getMechSettings(p)
	local animationNumber = getAnimationNumber(p)

	if not animationNumber then
		return
	end

	local v6 = mechanims[animationNumber] or mechanims[tostring(animationNumber)]
	return v6 == true and {} or v6, animationNumber
end

local function makeAnimation(animationId)
	if typeof(animationId) == "string" and string.find(animationId, "rbxassetid") then
		animationId = tonumber((string.gsub(animationId, "rbxassetid://", ""):gsub("[^%-%d]", "")))
	end

	local animation = Instance.new("Animation")

	if typeof(animationId) == "string" then
		animation.AnimationId = animationId
		return animation
	end

	if typeof(animationId) == "number" then
		animation.AnimationId = "rbxassetid://" .. animationId
		return animation
	end

	if typeof(animationId) ~= "Instance" then
		return animation
	end

	local RunService = game:GetService("RunService")

	if RunService:IsStudio() then
		local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
		animation.AnimationId = KeyframeSequenceProvider:RegisterKeyframeSequence(animationId)
	end

	return animation
end

function AnimationPlayer.playRigAnimation(p, p2, _, p3, p4)
	local animationNumber = getAnimationNumber(p2)
	local v6

	if animationNumber then
		local v7 = mechanims[animationNumber] or mechanims[tostring(animationNumber)]
		v6 = v7 == true and {} or v7
	else
		animationNumber = nil
	end

	if not v6 or not (p and p.Parent) or p.Parent:FindFirstChild("Ragdoll") and p2 ~= 14840458512 and not p4 then
		return v5
	end

	if not p2 or p3 then
		return
	end

	local parent = p.Parent

	if not parent:GetAttribute("InMech") then
		return v5
	end

	local mech = parent:FindFirstChild("Mech")
	local animationController = mech and mech:FindFirstChildOfClass("AnimationController")

	if not animationController then
		return v5
	end

	local v7 = "mech:" .. tostring(animationNumber or p2)
	local v8 = rawget(v2, v7)

	if v8 then
		local v9 = v3[v7]

		if v9 and (v9 == animationController or v9.Parent == animationController) then
			return v8
		end

		v2[v7] = nil
		v3[v7] = nil
	end

	local v9 = animationController:FindFirstChildOfClass("Animator")

	if not v9 then
		v9 = Instance.new("Animator")
		v9.Parent = animationController
	end

	local track = v9:LoadAnimation((makeAnimation(p2)))
	v2[v7] = track
	v3[v7] = animationController

	if type(v6) == "table" then
		track.Looped = false

		if v6.Priority then
			track.Priority = v6.Priority
		end
	end

	track:AdjustWeight(0.001)
	return track
end

function AnimationPlayer.playAnimation(instance, value, p, p2, p3)
	local animationNumber = getAnimationNumber(value)
	local v6

	if animationNumber then
		local v7 = mechanims[animationNumber] or mechanims[tostring(animationNumber)]
		v6 = v7 == true and {} or v7
	end

	if v6 then
		return AnimationPlayer.playRigAnimation(instance, value, p, p2, p3)
	end

	if not (instance and instance.Parent) or instance.Parent:FindFirstChild("Ragdoll") and value ~= 14840458512 and not p3 then
		return v5
	end

	if rawget(result, value) then
		return result[value]
	end

	if not value or p2 then
		return
	end

	if not (v[instance] or instance.Parent:GetAttribute("ClonedChar")) then
		v[instance] = true
		instance.AncestryChanged:Connect(function()
			if not instance.Parent then
				for k, v7 in pairs(result) do
					if v7 and v7.Animator and v7.Animator.Parent == instance then
						result[k] = nil
					end
				end
			end
		end)
	end

	local animationId

	if typeof(value) == "string" and string.find(value, "rbxassetid") then
		animationId = tonumber((string.gsub(value, "rbxassetid://", ""):gsub("[^%-%d]", "")))
	else
		animationId = value
	end

	local animation = Instance.new("Animation")

	if typeof(animationId) == "string" then
		animation.AnimationId = animationId
	elseif typeof(animationId) == "number" then
		animation.AnimationId = "rbxassetid://" .. animationId
	elseif typeof(animationId) == "Instance" then
		local RunService = game:GetService("RunService")

		if RunService:IsStudio() then
			local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
			animation.AnimationId = KeyframeSequenceProvider:RegisterKeyframeSequence(animationId)
		end
	end

	local animator = instance:FindFirstChild("Animator") or instance:WaitForChild("Animator", 2)

	if not (animator and animator.Parent) then
		return
	end

	local track = animator:LoadAnimation(animation)
	result[value] = track
	track:AdjustWeight(0.001)
	return track
end

function AnimationPlayer.GetStorage(_)
	return result
end

return AnimationPlayer