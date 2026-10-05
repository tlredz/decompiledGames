local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "Trampoline"
})
local v2 = { "rbxassetid://87647514217870", "rbxassetid://73776686278018" }
local now = 0

function v:GetRandomBounceAnimation()
	local v3 = math.random(1, #v2)
	local animationId = v2[v3]

	if typeof(animationId) ~= "string" then
		return animationId
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	v2[v3] = animation
	return animation
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.Touched:Connect(function(otherPart)
		if os.clock() - now < 0.25 or Players.LocalPlayer.Character:FindFirstChild("Humanoid").Sit or otherPart.Parent ~= Players.LocalPlayer.Character then
			return
		end

		local character = Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChild("Humanoid")
		local animator = humanoid and humanoid:FindFirstChild("Animator")

		if not (humanoidRootPart and animator) then
			return
		end

		now = os.clock()
		animator:LoadAnimation((self:GetRandomBounceAnimation())):Play()
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
			assemblyLinearVelocity.X,
			math.max(assemblyLinearVelocity.Y, 0) + 100 + math.random(-10, 64),
			assemblyLinearVelocity.Z
		)

		if humanoid.MoveDirection.Magnitude > 0 then
			local v3 = humanoid.MoveDirection * createVector(1, 0, 1) * humanoid.MoveDirection.Magnitude
			local vectorForce = Instance.new("VectorForce")
			vectorForce.Force = v3 * humanoidRootPart.AssemblyMass * 314
			vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
			vectorForce.Attachment0 = humanoidRootPart:FindFirstChild("RootAttachment")
			vectorForce.Parent = humanoidRootPart
			TweenService:Create(vectorForce, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
				Force = createVector(0, 0, 0)
			}):Play()
			Debris:AddItem(vectorForce, 1.5)
		end

		local sound = self.Instance:FindFirstChildOfClass("Sound")

		if sound then
			sound.PlaybackSpeed = math.random(90, 110) / 100
			sound:Play()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v