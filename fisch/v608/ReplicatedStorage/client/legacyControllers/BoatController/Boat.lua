local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "Boat",
	Ancestors = { workspace }
})

function v:Construct()
	self.trove = Trove.new()
	self._soundVolumeVelocity = 0
	self._soundSpeedVelocity = 0
	self.Animations = {}
	self.HasAnimations = false
end

function v:Start()
	self.IsOwn = self.Instance:GetAttribute("OwnerUserId") == localPlayer.UserId
	self.Name = self.Instance.Name

	if self.Instance:GetAttribute("CopyStatsFrom") then
		local clone = table.clone(vessels.library[self.Instance:GetAttribute("CopyStatsFrom")])
		local v2 = vessels.library[self.Name]
		clone.Bobbing = v2.Bobbing
		clone.BobbingSpeed = v2.BobbingSpeed
		clone.ForwardTilt = v2.ForwardTilt
		clone.SteerTilt = v2.SteerTilt
		clone.Description = v2.Description
		clone.Icon = v2.Icon
		self.BoatData = clone
	else
		self.BoatData = vessels.library[self.Name]
	end

	self.trove:Add(task.spawn(function()
		self.Base = self.Instance:WaitForChild("Base")
		self.Base0 = self.Base:WaitForChild("Base0")
		self.BaseCenter = self.Base:WaitForChild("BaseCenter")
		self.MovingSound = self.Base0:FindFirstChild("movingSound")
		self.VehicleSeat = self.Instance:WaitForChild("owner")
		self.PlanePart = self.Instance:WaitForChild("PlanePart")
		self.Motor = self.Base:WaitForChild("Motor")
		self.MoveResist = self.Base:WaitForChild("MoveResist")
		self.FlightMotor = self.Base:WaitForChild("FlightMotor")
		self.Rot = self.Base:WaitForChild("Rot")
		self.Steer = self.Base:WaitForChild("Steer")
		self.SimpleSteer = self.Base:WaitForChild("SimpleSteer")
		self.PlaneConstraint = self.PlanePart:WaitForChild("PlaneConstraint")

		if self.BoatData.IsSubmarine then
			self.BuoyancySensor = self.Instance:WaitForChild("HitBox"):WaitForChild("BuoyancySensor")
		end

		if self.IsOwn then
			task.spawn(function()
				local module = require("./BoatPhysics")
				module:Init(self)

				if self.Instance:GetAttribute("AutoSeatOwner") then
					local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Humanoid")

					if humanoid and not self.VehicleSeat.Occupant then
						self.VehicleSeat:Sit(humanoid)
					end
				end
			end)
		end

		if not self.Instance:FindFirstChild("Body") then
			self.Instance:FindFirstChildWhichIsA("Model")
		end

		for _, animator in self.Instance:QueryDescendants("Animator.BoatAnimator") do
			self.Animations[animator] = {}

			for _, animation in animator.Parent:QueryDescendants("Animation") do
				self.Animations[animator][animation.Name] = animator:LoadAnimation(animation)
				self.HasAnimations = true
			end
		end

		local sitprompt = self.VehicleSeat:WaitForChild("sitprompt")
		sitprompt.Enabled = self.VehicleSeat.Occupant == nil
		self.trove:Add(self.VehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
			sitprompt.Enabled = self.VehicleSeat.Occupant == nil
		end))
		self.trove:Add(sitprompt.Triggered:Connect(function(player)
			if player == localPlayer and player.Character and self.VehicleSeat.Occupant == nil then
				local character = require(ReplicatedStorage.shared.modules:WaitForChild("character"))

				if character:Can(localPlayer) then
					if self.IsOwn then
						local tool = player.Character:FindFirstChildWhichIsA("Tool")

						if tool and tool:FindFirstChild("bobber") or player.Character:HasTag("emoting") then
							return
						end

						self.VehicleSeat:Sit(player.Character:FindFirstChildWhichIsA("Humanoid"))
					else
						ReplicatedStorage.events.anno_localthought:Fire("This seat isn't for you...")
					end
				end
			end
		end))
		self.MovingParticles = self.Instance:QueryDescendants(".BoatMovingVFX")
	end))
end

function v:PlayAnimation(p2: string?, p3: number?)
	for k, animation in self.Animations do
		local v2, v3

		if p2 == "Unoccupied" and not animation.Unoccupied then
			if animation.Idle then
				v2 = p3
				v3 = "Idle"
			else
				v3 = "Active"
				v2 = 0
			end
		elseif p2 == "Idle" and not (animation.Idle or k:GetAttribute("NoIdle")) then
			v3 = "Active"
			v2 = 0
		elseif p2 == "Active" and not animation.Active then
			v3 = "Idle"
			v2 = 1
		else
			v2 = p3
			v3 = p2
		end

		for _, v4 in animation do
			if v4 == animation[v3] then
				if not v4.IsPlaying then
					v4:Play()
				end

				if v2 then
					v4:AdjustSpeed(v2)
				end
			elseif v4.IsPlaying then
				v4:Stop()
			end
		end
	end
end

function v:HeartbeatUpdate(p: number)
	if not (self.VehicleSeat and self.Base0) then
		return
	end

	debug.profilebegin("Boat::HeartbeatUpdate")

	if self.MovingSound then
		local v2 = not self.MovingSound:FindFirstChild("Volume") and 0.6 or self.MovingSound:FindFirstChild("Volume").Value
		local v3 = not self.MovingSound:GetAttribute("BasePlaybackSpeed") and 1 or self.MovingSound:GetAttribute("BasePlaybackSpeed")

		if self.VehicleSeat.ThrottleFloat < 0 then
			v2 *= 0.9
			v3 *= 0.8
		elseif self.VehicleSeat.ThrottleFloat == 0 then
			v2 = 0
			v3 = 0
		end

		local movingSound = self.MovingSound
		local smoothDamp, soundVolumeVelocity = TweenService:SmoothDamp(
			self.MovingSound.Volume,
			v2,
			self._soundVolumeVelocity,
			3,
			nil,
			p
		)
		movingSound.Volume = smoothDamp
		self._soundVolumeVelocity = soundVolumeVelocity
		local movingSound2 = self.MovingSound
		local smoothDamp2, soundSpeedVelocity = TweenService:SmoothDamp(
			self.MovingSound.PlaybackSpeed,
			v3,
			self._soundSpeedVelocity,
			3,
			nil,
			p
		)
		movingSound2.PlaybackSpeed = smoothDamp2
		self._soundSpeedVelocity = soundSpeedVelocity
	end

	local v2 = self.VehicleSeat.ThrottleFloat > 0

	if self.ParticleState ~= v2 then
		if self.Base0:FindFirstChild("waterSpray") then
			local waterSpray = self.Base0:FindFirstChild("waterSpray")
			waterSpray.Enabled = v2
		end

		if self.MovingParticles then
			for _, movingParticle in self.MovingParticles do
				movingParticle.Enabled = v2
			end
		end

		self.ParticleState = v2
	end

	if self.HasAnimations then
		if self.VehicleSeat.Occupant == nil then
			self:PlayAnimation("Unoccupied")
		elseif self.VehicleSeat.ThrottleFloat == 0 then
			self:PlayAnimation("Idle")
		else
			self:PlayAnimation("Active", self.VehicleSeat.ThrottleFloat)
		end
	end

	debug.profileend()
end

function v:Stop()
	if self.IsOwn then
		local module = require("./BoatPhysics")
		module:Cleanup(self)
	end

	self.trove:Clean()
end

function v.GetComponentFromChild(_, parent)
	while not parent:HasTag("Boat") do
		parent = parent.Parent

		if not parent then
			return nil
		end
	end

	return v:FromInstance(parent)
end

return v