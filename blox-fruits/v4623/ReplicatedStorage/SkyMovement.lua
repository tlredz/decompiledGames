local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(ReplicatedStorage.Effect)
local Util = require(ReplicatedStorage.Util)
local _ = Util.Anims

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local _ = {
	DOWNFORCE_MIN = 4,
	DOWNFORCE_MAX = 8,
	SPEED_MAX = 250
}
local _ = {
	SPEED = 120
}
local v = {
	FlightType = {
		None = 0,
		Glide = 1,
		Free = 2
	}
}
local SkyMovement = {
	Mode = v.FlightType.None,
	CharacterReady = false,
	HasJumped = false,
	Forces = {
		BV = nil,
		BG = nil
	},
	User = {
		Character = nil,
		Humanoid = nil,
		RootPart = nil
	}
}

local function canRun()
	local v2 = true

	for _, v3 in SkyMovement.User do
		if v3 == nil or not v3:IsDescendantOf(workspace) then
			v2 = false
		end
	end

	for _, force in SkyMovement.Forces do
		if force == nil or force.Parent == nil then
			v2 = false
		end
	end

	if SkyMovement.User.Humanoid.Health <= 0 or SkyMovement.User.Humanoid.Sit == true or SkyMovement.Mode == v.FlightType.None or not (SkyMovement.User.Transformed and SkyMovement.User.Transformed.Value) then
		v2 = false
	end

	if SkyMovement.Mode == v.FlightType.Glide and Util.Ray(
		SkyMovement.User.RootPart.Position,
		CFrame.new(SkyMovement.User.RootPart.Position).UpVector.Unit * -SkyMovement.User.Humanoid.HipHeight,
		{ workspace.Characters, workspace.Enemies }
	) then
		return false
	end

	return v2
end

local function cancelFlight()
	SkyMovement.Mode = v.FlightType.None

	if SkyMovement.Forces.BV ~= nil then
		SkyMovement.Forces.BV:Destroy()
	end

	if SkyMovement.Forces.BG ~= nil then
		SkyMovement.Forces.BG:Destroy()
	end

	SkyMovement.User.Humanoid.PlatformStand = false
	SkyMovement.User.Humanoid.AutoRotate = true
	SkyMovement.User.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	Effect.new("RaceAwakenings.Skypiean"):replicate({
		Index = 3,
		Operation = 0,
		Root = SkyMovement.User.RootPart
	})
end

local function getAnimation(instance)
	local upperTorso = instance:FindFirstChild("UpperTorso")

	if upperTorso then
		for _, child in pairs(workspace._WorldOrigin.PlayerAccessoriesProxy:GetChildren()) do
			local rootPart = child:FindFirstChild("RootPart")

			if not rootPart then
				continue
			end

			local motor6D = rootPart:FindFirstChild("Motor6D")

			if not (motor6D and motor6D.Part0 == upperTorso and child:FindFirstChild("AnimationController") and child.AnimationController:FindFirstChild("Animator")) then
				continue
			end

			local animator = child.AnimationController.Animator

			for _, v2 in pairs(animator:GetPlayingAnimationTracks()) do
				return v2
			end
		end
	end
end

function SkyMovement:SetCharacter(character)
	if character == nil then
		warn("[SkyMovement]", "Attempted to reference character, but it does not exist")
		return
	end

	self.User.Character = character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		warn("[SkyMovement]", "Character found, but RootPart or Humanoid was missing")
		return
	end

	self.User.RootPart = humanoidRootPart
	self.User.Humanoid = humanoid
	self.User.Transformed = character:FindFirstChild("RaceTransformed")
	self.CharacterReady = true
	self.Mode = v.FlightType.None
end

function SkyMovement:SetFlight(mode, value)
	local v2 = value or 1

	if self.CharacterReady == true then
		cancelFlight()
		local character = self.User.Character
		local IsTransformed = require(game.ReplicatedStorage.Util.IsTransformed)

		if IsTransformed(character, false, false) then
			return
		end

		if mode ~= self.Mode then
			game.ReplicatedStorage.Remotes.CommE:FireServer("SkypieaFlight", mode)

			if mode ~= v.FlightType.None then
				if mode == v.FlightType.Glide then
					self.Mode = mode
					Effect.new("RaceAwakenings.Skypiean"):replicate({
						Index = 3,
						Operation = 1,
						Root = self.User.RootPart,
						MaxGlideSpeed = 250 * v2
					})
					self.User.Humanoid.AutoRotate = false
					self.User.Humanoid.PlatformStand = true
					self.Forces.BV = Util.BodyMover.new(self.User.Character):Create("BodyVelocity", {
						Priority = -1e999,
						Velocity = createVector(0, 0, 0)
					})
					self.Forces.BG = Util.BodyMover.new(self.User.Character):Create("BodyGyro", {
						Priority = -1e999,
						D = 2000,
						P = 55000,
						CFrame = workspace.CurrentCamera.CFrame
					})
					local v3 = 250 * v2
					local v4 = 150 * v2
					local v5 = createVector(0, 0, 0)
					local velocity = self.User.RootPart.Velocity

					if velocity.Y < 0 then
						v4 = math.min(
							v3,
							(createVector(0, -1, 0)):Dot(workspace.CurrentCamera.CFrame.LookVector) * math.abs(velocity.Y)
						)

						if v4 < 150 * v2 then
							v4 = 150 * v2
						end
					end

					task.spawn(function()
						local animation = Instance.new("Animation")
						animation.AnimationId = "rbxassetid://11459423126"
						local track = self.User.Humanoid:LoadAnimation(animation)
						track:Play()
						animation:Destroy()
						local v6 = 0

						while canRun() and not (self.User.Character.Busy.Value or self.User.Character.Stun.Value > 0) do
							local character2 = self.User.Character
							local IsTransformed2 = require(game.ReplicatedStorage.Util.IsTransformed)

							if IsTransformed2(character2, false, false) then
								break
							end

							local lookVector = workspace.CurrentCamera.CFrame.LookVector
							local dot = (createVector(0, -1, 0)):Dot(workspace.CurrentCamera.CFrame.LookVector)
							v4 = math.clamp(v4 + dot * 2 - v6 * 15, 150 * v2, v3)
							local v7 = v4 >= 0 and 4 + 4 * (v4 / v3) or 4

							if v4 < 0 then
								if dot > 0 then
									v4 = math.min(
										v3,
										(createVector(0, -1, 0)):Dot(workspace.CurrentCamera.CFrame.LookVector) * math.abs(velocity.Y)
									)
								end

								v5 = v5:Lerp(
									(createVector(0, -1, 0)).Unit * math.abs(v4) + Vector3.new(0, -v7, 0),
									0.05
								)
							else
								v5 = v5:Lerp(lookVector.Unit * v4 + Vector3.new(0, -v7, 0), 0.05)
							end

							self.Forces.BV:Set(v5)
							self.Forces.BG:Set(workspace.CurrentCamera.CFrame)
							v6 = RunService.RenderStepped:Wait()
						end

						if track then
							track:Stop()
						end

						cancelFlight()
					end)
				elseif mode == v.FlightType.Free then
					self.Mode = mode
					self.User.Humanoid.AutoRotate = false
					self.User.Humanoid.PlatformStand = true
					self.Forces.BV = Util.BodyMover.new(self.User.Character):Create("BodyVelocity", {
						Priority = -1e999,
						Velocity = createVector(0, 0, 0)
					})
					self.Forces.BG = Util.BodyMover.new(self.User.Character):Create("BodyGyro", {
						Priority = -1e999,
						D = 1000,
						P = 55000,
						CFrame = workspace.CurrentCamera.CFrame
					})
					task.spawn(function()
						local animation = Instance.new("Animation")
						animation.AnimationId = "rbxassetid://11459428581"
						local track = self.User.Humanoid:LoadAnimation(animation)
						track:Play()
						animation:Destroy()

						while canRun() do
							local character2 = self.User.Character
							local IsTransformed2 = require(game.ReplicatedStorage.Util.IsTransformed)

							if IsTransformed2(character2, false, false) then
								break
							end

							local v3 = self.User.Humanoid.MoveDirection.magnitude > 0.03
							local vectorToObjectSpace = workspace.CurrentCamera.CFrame:VectorToObjectSpace(v3 and self.User.Humanoid.MoveDirection or Vector3.new())
							local v4 = vectorToObjectSpace.magnitude > 0.03 and vectorToObjectSpace or Vector3.new()
							local v5 = ((v4.magnitude > 0.03 and workspace.CurrentCamera.CFrame:VectorToWorldSpace(v4) or self.User.RootPart.CFrame.LookVector) + Vector3.new(
								0,
								-v4.Y,
								0
							)).unit * (120 * v2) * (v3 and 1 or 0)
							self.Forces.BV:Set(v5)
							self.Forces.BG:Set(workspace.CurrentCamera.CFrame)
							RunService.RenderStepped:Wait()
						end

						if track then
							track:Stop()
						end

						cancelFlight()
					end)
				end
			end
		end
	else
		warn("[SkyMovement]", "SetFlight was called before character was defined")
	end
end

return SkyMovement