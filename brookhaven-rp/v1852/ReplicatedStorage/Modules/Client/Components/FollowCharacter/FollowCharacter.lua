local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Minions2026Constants = require(ReplicatedStorage.Modules.Shared.LiveOps.Minions2026Constants)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "FollowCharacter"
})
local v2 = { "Freefall1", "Freefall2" }
local v3 = false

function v.SetBananaTornadoCaptured(flag: boolean)
	v3 = flag
end

function v:StartFollowCharacter(instance, parent, instance2, followCharacterController)
	local WAIT_INTERVAL = 0.15
	self.followCharacterController = followCharacterController
	local slotNumber = instance2:GetAttribute("SlotNumber") or 1
	local timePosition = slotNumber == 1 and 0 or math.random(0, 0.5)
	self.targetPositionDelta = Minions2026Constants.TargetPositionsDeltas[slotNumber]
	self._Janitor:Add(instance2.AttributeChanged:Connect(function(p)
		if p == "SlotNumber" then
			slotNumber = instance2:GetAttribute("SlotNumber") or 1
			self.targetPositionDelta = Minions2026Constants.TargetPositionsDeltas[slotNumber]
		end
	end))
	local localPlayer = Players.LocalPlayer
	local bodyPosition = Instance.new("BodyPosition")
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.maxTorque = createVector(400000, 400000, 400000)
	bodyGyro.P = 4000
	bodyGyro.D = 500
	bodyPosition.MaxForce = createVector(12500, 10000, 12500)
	bodyGyro.Parent = parent
	bodyPosition.Parent = parent
	bodyGyro.CFrame = instance.HumanoidRootPart.CFrame
	local animations = instance2:WaitForChild("Animations")
	local runAnim = animations:WaitForChild("RunAnim")
	local humanoid = instance2:FindFirstChild("Humanoid")
	local track = nil
	local track2

	if humanoid then
		track2 = humanoid:LoadAnimation(runAnim)
		track2:Play()
	else
		local animationController = instance2:FindFirstChildOfClass("AnimationController")

		if not animationController then
			warn("No anim controller found for follow character or humanoid not found")
			return
		end

		humanoid = animationController:WaitForChild("Animator")
		track2 = humanoid:LoadAnimation(runAnim)
		track2:Play()
		track = humanoid:LoadAnimation(animations:WaitForChild("IdleAnim"))
	end

	local v5

	if instance2.Parent == nil then
		v5 = false
	else
		v5 = instance2.Parent.Name == Minions2026Constants.MINIONS_PLAYER_FOLDER
	end

	local track3 = nil

	local function startFreefall()
		if track3 == nil then
			local child = animations:FindFirstChild(v2[math.random(1, #v2)])

			if child == nil then
				return
			end

			track3 = humanoid:LoadAnimation(child)
			track3.Looped = true
			track3.Priority = Enum.AnimationPriority.Action
		end

		if track2 and track2.IsPlaying then
			track2:Stop()
		end

		if track and track.IsPlaying then
			track:Stop()
		end

		if not track3.IsPlaying then
			print("Playing freefall animation")
			track3:Play()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopFreefall()
		if track3 == nil then
			return
		end

		if track3.IsPlaying then
			track3:Stop()
		end

		track3:Destroy()
		track3 = nil
	end

	while instance do
		local character = localPlayer.Character

		if character then
			if character:FindFirstChild("HumanoidRootPart") == nil then
				break
			end

			bodyGyro.CFrame = instance.HumanoidRootPart.CFrame
			local cFrame = instance.HumanoidRootPart.CFrame
			local position

			if instance.Humanoid.Sit == false or slotNumber ~= 1 then
				position = CFrame.new(cFrame * self.targetPositionDelta).Position
			else
				position = CFrame.new(cFrame * createVector(1.2, 0.5, -0.4)).Position
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = { instance }

			if slotNumber ~= 1 then
				local positionsForSlot = self.followCharacterController.GetPositionsForSlot(slotNumber)

				if positionsForSlot then
					bodyGyro.CFrame = positionsForSlot
					position = positionsForSlot.Position
				end
			end

			local raycastResult = workspace:Raycast(
				position + createVector(0, 3, 0),
				createVector(-0, -30, -0),
				raycastParams
			)

			if raycastResult then
				position = raycastResult.Position + createVector(0, 1, 0)
			end

			bodyPosition.Position = position

			if v5 and v3 then
				startFreefall()
			else
				stopFreefall() -- equivalent call inferred; original call site unknown

				if instance.HumanoidRootPart.Velocity.magnitude < 1 then
					task.wait(WAIT_INTERVAL)
					track2:AdjustSpeed(0)

					if track2 and track2.IsPlaying then
						track2:Stop()
					end

					if track and not track.IsPlaying then
						track:Play()
					end
				else
					track2:AdjustSpeed(2)

					if track2 and not track2.IsPlaying then
						track2.TimePosition = timePosition
						track2:Play()
					end

					if track and track.IsPlaying then
						track:Stop()
					end
				end
			end

			task.wait(WAIT_INTERVAL)
		else
			task.wait(WAIT_INTERVAL)
		end
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v