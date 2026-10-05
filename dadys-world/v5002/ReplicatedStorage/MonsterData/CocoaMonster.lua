local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local CocoaMonster = {
	Name = "Twisted Cocoa",
	Rarity = "Rare",
	WalkSpeed = 8,
	RunSpeed = 21,
	Damage = 1,
	WaitTime = 1,
	WaitDuration = 0.5,
	GeneratorWaitTime = 15,
	InterestTime = 0.8,
	VisionRadius = 50,
	InstantRadius = 25,
	HearingRadius = 125,
	KillRadius = 3.33,
	HitCooldown = 5,
	LineOfSight = 0.4,
	HolidayTwisted = true,
	EasterTwisted = true,
	Holiday = true,
	Easter = true,
	Icon = "rbxassetid://131621776719456",
	Render = "rbxassetid://101180823373783",
	Trinket = "GlazedFondantBag",
	Description = "Don't underestimate this Twisted. While often patrolling at a slower pace she will quickly speed up by hopping towards her target, often over objects. Thankfully, her attention can drop almost as quickly.",
	AnimationOverrides = true,
	AttackAnimationId = "rbxassetid://83764116448633",
	UseBehaviorTree = true,
	AIConfig = {
		AgentCost = {
			Cocoa = 0.5
		},
		BlockVisionAcrossLinks = true,
		PathfindingLinkReached = function(instance, p)
			local RunService = game:GetService("RunService")
			local Debris = game:GetService("Debris")
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return false
			end

			instance:SetAttribute("_HopInProgress", true)
			local humanoid = instance:FindFirstChildOfClass("Humanoid")
			local v = not humanoid and 0 or humanoid.HipHeight or 0
			local position = humanoidRootPart.Position
			local v2 = p.Position + Vector3.new(0, humanoidRootPart.Size.Y / 2 + v, 0)
			local v3 = Vector3.new(v2.X, position.Y, v2.Z) - position

			if v3.Magnitude > 0.1 then
				humanoidRootPart.CFrame = CFrame.lookAt(position, position + v3)
			end

			local track = nil

			if humanoid then
				local animator = humanoid:FindFirstChild("Animator")

				if animator then
					local animation = Instance.new("Animation")
					animation.AnimationId = "rbxassetid://131112457626247"
					track = animator:LoadAnimation(animation)
					track:Play()
					animation:Destroy()
				end
			end

			local lastTime = os.clock()

			while os.clock() - lastTime < 0.25 do
				if humanoidRootPart and humanoidRootPart.Parent then
					RunService.Heartbeat:Wait()
				else
					if track then
						track:Stop()
					end

					instance:SetAttribute("_HopInProgress", nil)
					return false
				end
			end

			Audio:Play("Sounds.Twisted.Cocoa.Hop", {
				Volume = 0.8,
				RollOffMode = Enum.RollOffMode.Linear,
				RollOffMinDistance = 5,
				RollOffMaxDistance = 100,
				Parent = humanoidRootPart
			})

			if humanoid then
				humanoid.PlatformStand = true
			end

			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			local lastTime2 = os.clock()
			local rotation = humanoidRootPart.CFrame.Rotation
			local position2 = humanoidRootPart.Position
			local vector2 = Vector3.new(v2.X - position2.X, 0, v2.Z - position2.Z)

			if vector2.Magnitude > 0.1 then
				rotation = CFrame.lookAt(createVector(0, 0, 0), vector2).Rotation
			end

			while humanoidRootPart and humanoidRootPart.Parent do
				local v4 = math.clamp((os.clock() - lastTime2) / 0.45, 0, 1)
				local v5 = v4 * v4 * (3 - v4 * 2)
				local lerped = position2:Lerp(v2, v5)
				local v6 = v5 * 32 * (1 - v5)
				humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
				humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
				humanoidRootPart.CFrame = CFrame.new(lerped + Vector3.new(0, v6, 0)) * rotation

				if v4 >= 1 then
					if humanoidRootPart and humanoidRootPart.Parent then
						humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
						humanoidRootPart.CFrame = CFrame.new(v2) * rotation

						if humanoid then
							humanoid.PlatformStand = false
						end

						local v7 = v2 - Vector3.new(0, humanoidRootPart.Size.Y / 2 + v, 0)
						local part = Instance.new("Part")
						part.Size = createVector(1, 1, 1)
						part.Transparency = 1
						part.Anchored = true
						part.CanCollide = false
						part.CanQuery = false
						part.CanTouch = false
						part.CFrame = CFrame.new(v7)
						local particleEmitter = Instance.new("ParticleEmitter")
						particleEmitter.Color = ColorSequence.new(Color3.fromRGB(180, 160, 140))
						particleEmitter.Size = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1.5),
							NumberSequenceKeypoint.new(1, 3)
						})
						particleEmitter.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.3),
							NumberSequenceKeypoint.new(1, 1)
						})
						particleEmitter.Lifetime = NumberRange.new(0.3, 0.6)
						particleEmitter.Speed = NumberRange.new(3, 6)
						particleEmitter.SpreadAngle = Vector2.new(60, 60)
						particleEmitter.Rate = 0
						particleEmitter.Drag = 3
						particleEmitter.Parent = part
						part.Parent = workspace
						particleEmitter:Emit(12)
						Debris:AddItem(part, 1)
					end

					if track then
						track:Stop()
					end

					instance:SetAttribute("_HopInProgress", nil)
					return true
				else
					RunService.Heartbeat:Wait()
				end
			end

			if track then
				track:Stop()
			end

			if humanoid then
				humanoid.PlatformStand = false
			end

			instance:SetAttribute("_HopInProgress", nil)
			return false
		end
	},
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://134449870934837",
			NormalTexture = "rbxassetid://71543964410172",
			AttackTexture = "rbxassetid://138719453702886"
		}
	}
}

function CocoaMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, CocoaMonster.SpecialAnimatorData.Config)
end

return CocoaMonster