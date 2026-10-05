local Config = require(game.ReplicatedStorage.NPCManager.NPC.Config)
local v = {}

for k, v2 in {
	Explain = "18884847573",
	Observe = "18884849844",
	Negative = "18884851323",
	Positive = "18884853165",
	Welcome = "18893533079",
	Shrug = "18897107533",
	Bye = "18900892919",
	Bye1 = "18900628852",
	Bye2 = "18900630099"
} do
	local animation = Instance.new("Animation")
	animation.Name = "Animation_" .. k
	animation.AnimationId = "rbxassetid://" .. v2
	v[k] = animation
end

local v2 = nil
local now = 0
local Head = {}

function Head.show(instance)
	if not instance then
		return
	end

	v2 = instance

	if instance:GetAttribute(Config.ANIMATIONS_DISABLED_ATTRIBUTE) ~= true and not instance:FindFirstChild("IdleAnimation") then
		local animation = Instance.new("Animation")
		animation.Name = "IdleAnimation"
		animation.AnimationId = "rbxassetid://18884841590"
		animation.Parent = instance
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if humanoid and instance:IsDescendantOf(game) then
			humanoid:LoadAnimation(animation):Play()
		end
	end

	local Global = require(game.ReplicatedStorage.Global)
	Global.dialogueModel = instance
end

function Head.get()
	return v2
end

function Head.clear()
	v2 = nil
end

function Head.playAction(p: string)
	if tick() - now < 0.03333333333333333 then
		return
	end

	now = tick()
	task.spawn(function()
		local dialogueModel = v2

		if not dialogueModel then
			local Global = require(game.ReplicatedStorage.Global)
			dialogueModel = Global.dialogueModel
		end

		if not (dialogueModel and dialogueModel:GetAttribute(Config.ANIMATIONS_DISABLED_ATTRIBUTE) ~= true and dialogueModel:FindFirstChildWhichIsA("Humanoid") and dialogueModel:FindFirstChild("UpperTorso")) then
			return
		end

		local clone = dialogueModel:FindFirstChild("Animation_" .. p)

		if not clone then
			clone = v[p] and v[p]:Clone()

			if not clone then
				return
			end

			clone.Parent = dialogueModel
		end

		if not dialogueModel:IsDescendantOf(game) then
			return
		end

		dialogueModel:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(clone):Play(0.3)
	end)
end

return Head