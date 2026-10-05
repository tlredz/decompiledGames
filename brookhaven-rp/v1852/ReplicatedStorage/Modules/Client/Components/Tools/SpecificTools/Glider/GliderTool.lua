local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local EasingLib = require(ReplicatedStorage.Modules.Shared.Utils.EasingLib)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "GliderTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

local function deriveTFromInOutSineVal(p: number, p2: number, p3: number, p4: number)
	return p4 / 3.141592653589793 * math.acos((math.clamp((p - p2) / (-p3 / 2) + 1, -1, 1)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isHumanoidSeated(object)
	return object.Sit or object.SeatPart ~= nil or object:GetState() == Enum.HumanoidStateType.Seated
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self._originalGrip = self.Instance.Grip
end

local function OverrideOtherTweens(p, p2, p3)
	local tween = TweenService:Create(p, TweenInfo.new(1), {
		[p2] = p3
	})
	tween:Play()
	tween:Cancel()
	p[p2] = p3
end

function v:StartGliding()
	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	else
		humanoid = nil
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	else
		humanoidRootPart = nil
	end

	local trailL = self.Instance:WaitForChild("Handle"):FindFirstChild("TrailL")
	local trailR = self.Instance:WaitForChild("Handle"):FindFirstChild("TrailR")

	if not humanoid or not humanoidRootPart or self.isGliding then
		return
	end

	self.isGliding = true
	self.glideAnimation:Play()
	local v2 = not (humanoidRootPart.AssemblyLinearVelocity.Magnitude > 1) and 0 or math.clamp(
		humanoidRootPart.AssemblyLinearVelocity:Dot(humanoidRootPart.CFrame.LookVector),
		0,
		1
	)
	local v3 = math.clamp(humanoidRootPart.AssemblyLinearVelocity.Y, -1e999, 0)
	local v4 = math.abs((math.min(-self.beginGlideFallRate, v3)))
	local lastTime = tick()
	local v5 = CFrame.new(
		humanoidRootPart.CFrame.Position,
		(humanoidRootPart.CFrame * CFrame.new(self.pushVec)).Position
	).LookVector * self.pushVec.Magnitude - Vector3.new(0, v4, 0)
	local v6 = humanoid.WalkSpeed * v2 / (self.pushVec - Vector3.new(0, v4, 0)).Magnitude
	local v7 = math.max(
		self.lerpBeginT,
		self.timeToFullGlide / 3.141592653589793 * math.acos((math.clamp((v6 - 0) / -0.5 + 1, -1, 1)))
	)
	local v8 = self.timeToFullGlide - v7 * self.timeToFullGlide
	local lerped = Vector3.new():Lerp(v5, EasingLib.inOutSine(v7, 0, 1, self.timeToFullGlide))
	local v9 = v4 * self.velConservationScale
	local bodyVelocity = Instance.new("BodyVelocity")
	self.glideForce = bodyVelocity
	bodyVelocity.Velocity = lerped
	bodyVelocity.MaxForce = createVector(99999, 99999, 99999)
	bodyVelocity.Parent = humanoidRootPart
	local bodyGyro = Instance.new("BodyGyro")
	self.glideAligner = bodyGyro
	bodyGyro.MaxTorque = createVector(99999, 99999, 99999)
	bodyGyro.P = 50000
	bodyGyro.D = 100
	bodyGyro.CFrame = humanoidRootPart.CFrame
	bodyGyro.Parent = humanoidRootPart
	humanoid.AutoRotate = false

	if self.Instance:FindFirstChild("FlyingToolGrip") then
		self.Instance.Grip = self.Instance:FindFirstChild("FlyingToolGrip").Value
	end

	task.spawn(function()
		local v10 = {}

		while self.isGliding and bodyVelocity and bodyVelocity.Parent == humanoidRootPart and bodyGyro and bodyGyro.Parent == humanoidRootPart do
			if isHumanoidSeated(humanoid) then
				break
			end

			local v12 = RunService.RenderStepped:Wait()
			local v13 = CFrame.new(
				humanoidRootPart.CFrame.Position,
				(humanoidRootPart.CFrame * CFrame.new(self.pushVec)).Position
			).LookVector * self.pushVec.Magnitude
			local v14 = workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)
			local cframe = CFrame.new(humanoidRootPart.CFrame.Position, humanoidRootPart.CFrame.Position + v14)
			local angle = (humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)).Unit:Angle(
				(cframe.LookVector * createVector(1, 0, 1)).Unit,
				humanoidRootPart.CFrame.UpVector
			)
			local v15 = humanoidRootPart.CFrame:PointToObjectSpace(humanoidRootPart.CFrame.Position + humanoidRootPart.AssemblyLinearVelocity):Dot(createVector(
				0,
				0,
				-1
			)) > 0.85
			bodyGyro.CFrame = bodyGyro.CFrame:Lerp(
				cframe * CFrame.Angles(-math.abs(angle) / 4, 0, angle / 2),
				v12 * self.turnSpeed
			)
			local v16

			if math.abs(v9) > 0.01 then
				v16 = v9 * self.velConservationConvSpd * v12 * math.clamp(
					1.5 - (tick() - lastTime) / (self.timeToFullGlide * 2),
					0.5,
					1
				)

				if v15 then
					v9 -= v16
				end
			else
				v16 = 0
			end

			if tick() - lastTime <= v8 then
				local lerped2 = lerped:Lerp(
					v13 * ((math.abs(angle) + 1) * self.turnSpdMult) - Vector3.new(0, self.fallRate, 0),
					EasingLib.inOutSine(tick() - lastTime, 0, 1, v8)
				)
				bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(lerped2, v12 * self.lerpSpeed)
				bodyVelocity.Velocity += (bodyVelocity.Velocity.Unit * createVector(1, 0.95, 1)).Unit * v16
			else
				bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(
					v13 * ((math.abs(angle) + 1) * self.turnSpdMult) - Vector3.new(0, self.fallRate, 0),
					v12 * self.lerpSpeed
				)
				bodyVelocity.Velocity += (bodyVelocity.Velocity.Unit * createVector(1, 0.95, 1)).Unit * v16
			end

			if not (v15 and trailL and trailR) then
				continue
			end

			local v17 = 0.9 - math.clamp(bodyVelocity.Velocity.Magnitude / v13.Magnitude * 0.9, 0, 0.9)
			local linear = EasingLib.linear(
				math.clamp(
					math.abs(bodyVelocity.Velocity.Magnitude - (self.pushVec - Vector3.new(0, self.fallRate, 0)).Magnitude),
					0,
					150
				) / 95,
				0.225,
				1,
				1
			)
			local numberSequence = NumberSequence.new({
				NumberSequenceKeypoint.new(0, linear),
				NumberSequenceKeypoint.new(0.75, linear),
				NumberSequenceKeypoint.new(1, 0.001)
			})

			for _, v18 in { trailL, trailR } do
				trailL.Enabled = true
				trailR.Enabled = true
				v18.WidthScale = numberSequence

				if not v10[v18] then
					v10[v18] = true
					TweenService:Create(v18, TweenInfo.new(0.25), {
						Lifetime = 0.25
					}):Play()
				end

				v18.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, v17),
					NumberSequenceKeypoint.new(0.25, (math.max(EasingLib.linear(0.5, v17, 1 - v17, 1), 0.85))),
					NumberSequenceKeypoint.new(1, 1)
				})
			end
		end

		humanoid.AutoRotate = true
		self:StopGliding()
	end)
end

function v:StopGliding()
	local _ = Players.LocalPlayer.Character
	local handle = self.Instance and self.Instance:FindFirstChild("Handle")
	self.Instance.Grip = self._originalGrip

	if handle then
		local trailL = handle:FindFirstChild("TrailL")
		local trailR = handle:FindFirstChild("TrailR")

		if trailL then
			OverrideOtherTweens(trailL, "Lifetime", 0)
			trailL.Enabled = false
		end

		if trailR then
			OverrideOtherTweens(trailR, "Lifetime", 0)
			trailR.Enabled = false
		end
	end

	local glideForce = self.glideForce

	if glideForce then
		glideForce.MaxForce = createVector(0, 0, 0)
		glideForce.Velocity = createVector(0, 0, 0)
	end

	local glideAligner = self.glideAligner

	if glideAligner then
		glideAligner.MaxTorque = createVector(0, 0, 0)
	end

	Debris:AddItem(self.glideForce, 0)
	Debris:AddItem(self.glideAligner, 0)
	self.isGliding = false

	if self.glideAnimation then
		self.glideAnimation:Stop()
	end
end

function v:StartListeningToUsage()
	self._equipJanitor:Cleanup()
	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	else
		humanoid = nil
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoid and humanoidRootPart) then
		return
	end

	self._equipJanitor:Add(humanoid.Seated:Connect(function(flag: boolean)
		if flag == true and self.isGliding == true then
			self:StopGliding()
		end
	end))
	self._equipJanitor:Add(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
		if humanoid.SeatPart ~= nil and self.isGliding == true then
			self:StopGliding()
		end
	end))

	while self.equipped do
		local state = humanoid:GetState()

		if state == Enum.HumanoidStateType.Freefall and humanoidRootPart.AssemblyLinearVelocity.Y <= 0 and humanoid.FloorMaterial == Enum.Material.Air and not self.isGliding then
			self:StartGliding()
		elseif self.isGliding and (humanoid.Sit or humanoid.SeatPart ~= nil or humanoid:GetState() == Enum.HumanoidStateType.Seated or state ~= Enum.HumanoidStateType.Freefall or humanoid.FloorMaterial ~= Enum.Material.Air) then
			self:StopGliding()
		end

		task.wait()
	end
end

function v:Start()
	local instance = self.Instance
	self.isGliding = false
	local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()

	if character ~= instance.Parent and Players.LocalPlayer.Backpack ~= instance.Parent then
		return
	end

	local humanoid = character:WaitForChild("Humanoid")

	if not humanoid then
		return
	end

	self.glideAnimation = humanoid:LoadAnimation(instance:WaitForChild("Gliding"))
	self.pushVec = instance:WaitForChild("PushVectorStudsSecond").Value
	self.fallRate = instance:WaitForChild("FallRateStudsSecond").Value
	self.timeToFullGlide = instance:WaitForChild("TimeUntilFullGlide").Value
	self.lerpSpeed = instance:WaitForChild("GliderLerpSpeed").Value
	self.lerpBeginT = instance:WaitForChild("GlideLerpBeginT").Value
	self.beginGlideFallRate = instance:WaitForChild("BeginGlideFallRateStudsSecond").Value
	self.turnSpeed = instance:WaitForChild("TurnSpeed").Value
	self.turnSpdMult = instance:WaitForChild("TurnRotationSpeedIncrease").Value
	self.velConservationScale = instance:WaitForChild("FreefallToForwardMomentumConversionRate").Value
	self.velConservationConvSpd = instance:WaitForChild("MomentumConservationConversionSpeed").Value
	self._Janitor:Add(instance.Equipped:Connect(function()
		self.equipped = true
		self:StartListeningToUsage()
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self.equipped = false
		self._equipJanitor:Cleanup()

		if self.isGliding then
			self:StopGliding()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
	self._equipJanitor:Destroy()
end

return v