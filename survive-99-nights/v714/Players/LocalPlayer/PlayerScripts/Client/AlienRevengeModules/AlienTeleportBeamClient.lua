local createVector = vector.create
local AlienTeleportBeamClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local v = false
local flag = false
local flag2 = false
local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
linearVelocity.MaxAxesForce = createVector(0, 1e999, 0)
local linearVelocity2 = Instance.new("LinearVelocity")
linearVelocity2.ForceLimitMode = Enum.ForceLimitMode.PerAxis
linearVelocity2.MaxAxesForce = createVector(0, 1e999, 0)

function ArePartsTouching(instance, p)
	local partBoundsInBox = workspace:GetPartBoundsInBox(instance.CFrame, instance.Size)

	for _, v2 in pairs(partBoundsInBox) do
		if v2 == p then
			return true
		end
	end
end

function StartLifting(instance)
	local humanoidRootPart = localPlayer.Character.HumanoidRootPart
	local _ = localPlayer.Character.Humanoid
	local beamPart = instance:WaitForChild("BeamPart")
	local beamFocus = instance:WaitForChild("BeamFocus")
	v = true
	task.spawn(function()
		while true do
			RunService.Heartbeat:Wait()

			if not (localPlayer.Character and ArePartsTouching(beamPart, humanoidRootPart)) then
				break
			end

			local v2 = math.clamp(
				1 - ((humanoidRootPart.Position - beamPart.Position) * createVector(1, 0, 1)).Magnitude / beamPart.Size.X,
				0,
				1
			)
			local assemblyMass = humanoidRootPart.AssemblyMass
			local _ = assemblyMass * workspace.Gravity
			local v3 = ((beamFocus.Position - humanoidRootPart.Position).Unit * createVector(1, 0, 1)).Unit * 20 * (1 - v2)
			local v4 = v2 ^ 2 * 12
			local v5 = assemblyMass * 100

			if flag then
				v5 = assemblyMass * 200
			end

			linearVelocity.MaxAxesForce = Vector3.new(v5, 1e999, v5)
			linearVelocity.VectorVelocity = v3 + Vector3.new(0, v4, 0)
			linearVelocity.Parent = humanoidRootPart
			linearVelocity.Attachment0 = humanoidRootPart.RootAttachment
		end

		EndLifting()
	end)
end

function EndLifting()
	v = false
	print("END LIFTING")
	linearVelocity.Parent = nil
end

local v2 = {
	["Repaired Alien Ship"] = "RepairedAlienShipCF"
}

function WaitForHoverAtTeleportLocation(p)
	local total = 0
	local flag3 = false
	flag2 = true
	print("hover", p)
	local v3 = v2[p] or "AlienCommandShipCF"
	local attribute = workspace:GetAttribute(v3)
	local position = nil
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
	task.spawn(function()
		while true do
			local v4 = task.wait()
			total += v4

			if not humanoidRootPart.Parent then
				break
			end

			local magnitude = ((humanoidRootPart.Position - attribute.Position) * createVector(1, 0, 1)).Magnitude

			if magnitude <= 10 then
				flag3 = true

				if not position then
					position = humanoidRootPart.Position
				end
			end

			if magnitude > 10 and flag3 or not flag3 and total > 5 then
				break
			end

			if not flag3 then
				continue
			end

			local v5 = math.sin(total) * 2.5

			if flag then
				linearVelocity2.MaxAxesForce = createVector(1e999, 1e999, 1e999)
			else
				linearVelocity2.MaxAxesForce = createVector(0, 1e999, 0)
			end

			linearVelocity2.VectorVelocity = Vector3.new(0, v5, 0)
			linearVelocity2.Parent = humanoidRootPart
			linearVelocity2.Attachment0 = humanoidRootPart.RootAttachment
		end

		linearVelocity2.Parent = nil
		flag2 = false
	end)
end

Client.InteractionHandler.RegisterInteraction("CommandShipTeleportBack", function(_)
	DoTeleport("Repaired Alien Ship")
end)

function DoTeleport(p)
	WaitForHoverAtTeleportLocation(p)
	local coverType = p == "Alien Command Ship" and "Alien Command Ship" or "Forest"
	Client.TeleportingClient.Teleport(p, nil, {
		CoverType = coverType
	})
	flag = true
	task.delay(2.5, function()
		flag = false
	end)
end

function TeleportBeamAdded(instance)
	instance:WaitForChild("BeamPart").Touched:Connect(function(otherPart)
		if localPlayer.Character and otherPart == localPlayer.Character.HumanoidRootPart then
			if flag2 then
				return
			end

			if not v then
				StartLifting(instance)
			end
		end
	end)
	local beamTeleport = instance:WaitForChild("BeamTeleport")
	beamTeleport.Touched:Connect(function(otherPart)
		if flag2 then
			return
		end

		if localPlayer.Character and otherPart == localPlayer.Character.HumanoidRootPart then
			local teleportDestination = beamTeleport.Parent:GetAttribute("TeleportDestination") or "Alien Command Ship"
			DoTeleport(teleportDestination)
		end
	end)
end

function AlienTeleportBeamClient.Init()
	Client.Utility.ForAllTagged("AlienTeleportBeam", TeleportBeamAdded)
end

return AlienTeleportBeamClient