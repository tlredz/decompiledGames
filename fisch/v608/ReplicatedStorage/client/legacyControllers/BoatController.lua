local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local observeCharacter = require(ReplicatedStorage.packages.Observers.observeCharacter)
local BoatController = {}
local humanoidRootPart = nil
local humanoid = nil
local animator = nil
local track = nil
local track2 = nil
local module = require("@self/Boat")
local module2 = require("@self/BoatPhysics")
BoatController.Boat = module
BoatController.Physics = module2

function BoatController:UpdateSeatAnimation()
	if track then
		track:Stop()
		track:Destroy()
		track = nil
	end

	if track2 then
		track2:Stop()
		track2:Destroy()
		track2 = nil
	end

	local seatPart = humanoid.SeatPart

	for _, v in CollectionService:GetTagged("BoatSeatPrompt") do
		v.Enabled = seatPart == nil and not v:GetAttribute("SeatOccupied")
	end

	if not seatPart then
		localPlayer.CameraMaxZoomDistance = 36
		return
	end

	local parent = seatPart.Parent

	if parent:HasTag("Boat") and parent:IsA("Model") then
		local _, v = parent:GetBoundingBox()
		localPlayer.CameraMaxZoomDistance = (v.X + v.Y + v.Z) / 3 / 4.5 + 36
	end

	local sitAnims = seatPart:FindFirstChild("sitAnims")

	if not sitAnims then
		return
	end

	local descendants = sitAnims:QueryDescendants("Animation")

	if #descendants == 0 then
		return
	end

	local v = nil

	if #descendants >= 2 then
		for k, descendant in descendants do
			if descendant.Name ~= "run" then
				continue
			end

			table.remove(descendants, k)
			v = descendant
			break
		end
	end

	local descendant = descendants[math.random(1, #descendants)]
	track = animator:LoadAnimation(descendant)
	track:Play()

	if v then
		track2 = animator:LoadAnimation(v)
	end
end

function BoatController:Start()
	BoatController.Physics:Start()
	observeCharacter(Players.LocalPlayer, function(_, instance)
		if track then
			track:Stop()
			track:Destroy()
			track = nil
		end

		humanoid = instance:WaitForChild("Humanoid")
		animator = humanoid:WaitForChild("Animator")
		humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		BoatController:UpdateSeatAnimation()
		humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
			BoatController:UpdateSeatAnimation()
		end)
	end)
	CollectionService:GetInstanceAddedSignal("BoatSeatPrompt"):Connect(function(instance)
		instance.Enabled = humanoid ~= nil and humanoid.SeatPart == nil and not instance:GetAttribute("SeatOccupied")
	end)
	RunService.Heartbeat:Connect(function()
		if animator and track and track2 and humanoidRootPart and humanoid.SeatPart then
			if humanoid.SeatPart:GetAttribute("AnimsUseThrottle") then
				if humanoid.SeatPart:IsA("VehicleSeat") then
					local v = math.abs(humanoid.SeatPart.ThrottleFloat) > 0

					if v and not track2.IsPlaying then
						track2:Play()
						track:Stop()
					elseif not v and track2.IsPlaying then
						track2:Stop()
						track:Play()
					end

					if v and track2.IsPlaying then
						if humanoid.SeatPart.ThrottleFloat > 0 then
							track2:AdjustSpeed(1)
						else
							track2:AdjustSpeed(-1)
						end
					end
				end
			else
				local v = math.clamp(math.map(humanoidRootPart.AssemblyLinearVelocity.Magnitude, 0, 80, 0, 1), 0, 1)

				if v > 0 and not track2.IsPlaying then
					track2:Play(0.1, v)
				elseif v <= 0 and track2.IsPlaying then
					track2:Stop()
				end

				track:AdjustWeight(1 - v)
				track2:AdjustWeight(v)
			end
		end
	end)
end

return BoatController