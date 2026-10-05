local createVector = vector.create
game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ShockwaveEffect = require(ReplicatedStorage.Shared.ShockwaveEffect)
local superJump = script.SuperJump
local superJumpAnimation = script.SuperJumpAnimation
local SuperJump = {
	AbilityName = "Super Jump",
	AbilityCooldown = 8,
	CanUseAbility = function(_, instance)
		if not instance.PrimaryPart or instance:GetAttribute("PULSED") and not instance:GetAttribute("teamVIP") then
			return false
		end

		return not instance:GetAttribute("AbilityCooldown")
	end
}

function SuperJump:RegisterCooldown(instance, p: number)
	instance:SetAttribute("AbilityCooldown", true)
	local abilityCooldown = SuperJump.AbilityCooldown
	local v = abilityCooldown - abilityCooldown / 8 * p
	task.delay(v, function()
		instance:SetAttribute("AbilityCooldown", nil)
	end)
end

function SuperJump.ServerInit(_, p, p2: number, flag: boolean)
	if not flag then
		SuperJump:RegisterCooldown(p, p2)
	end
end

function SuperJump.ServerStart(_, parent, p: number)
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart.AssemblyLinearVelocity.Magnitude < 10 then
		parent.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end

	local v = p * 25 + 200
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "SuperJump"
	bodyVelocity.MaxForce = createVector(1, 1, 1) * 1e999
	bodyVelocity.Velocity = Vector3.new(0, v, 0)
	bodyVelocity.Parent = humanoidRootPart
	Debris:AddItem(bodyVelocity, 0.001)
	local folder = Instance.new("Folder")
	folder.Parent = parent
	folder.Name = "IsAbilityHigh"
	task.delay(10, function()
		folder:Destroy()
	end)
	local animator = parent:FindFirstChildWhichIsA("Animator", true)

	if animator then
		animator:LoadAnimation(superJumpAnimation):Play()
	end
end

function SuperJump.ClientStart(_, instance, p: number)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	instance:FindFirstChildWhichIsA("Humanoid")
	local clone = superJump:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	clone.Parent = humanoidRootPart
	clone.WeldConstraint.Part1 = humanoidRootPart
	Debris:AddItem(clone, 4)

	if p >= 2 then
		clone.Wind.PlaybackSpeed = 1
		clone.OniCharge:Play()
	end

	clone.Wind:Play()
	clone.Jump:Play()

	for i = 1, 5 do
		if i == 5 and p < 2 then
			break
		end

		local v2 = {
			cframe = humanoidRootPart.CFrame,
			orientation = "Forward",
			color = 0,
			diameter = 0
		}
		local color

		if p >= 2 then
			color = Color3.new(0, 1, 1)
		else
			color = Color3.new(1, 1, 1)
		end

		v2.color = color
		v2.diameter = i == 1 and 30 or 15
		ShockwaveEffect(v2)
		task.wait(0.1)
	end
end

return SuperJump