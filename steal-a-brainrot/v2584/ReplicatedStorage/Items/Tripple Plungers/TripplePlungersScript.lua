local createVector = vector.create
local Players = game:GetService("Players")
game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Debounce = require(packages.Debounce)
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
local parent = script.Parent
local handle = parent:WaitForChild("Handle")
local beam = handle:WaitForChild("Beam")
handle:WaitForChild("RopeAttachment")
local parent2 = parent.Parent.Parent
local hit = script.Hit
local fire = script.Fire
parent.Activated:Connect(function()
	if parent2:GetAttribute("Stealing") then
		return
	end

	local PlayerMouse = require(ReplicatedStorage.Packages.PlayerMouse)
	local hit2 = PlayerMouse.Hit
	local target = PlayerMouse.Target

	if not target then
		return
	end

	local position = hit2.Position
	local character = parent2.Character

	if not character then
		return
	end

	local tool = character:FindFirstChildWhichIsA("Tool", true)

	if not (tool and tool.Name == "Tripple Plungers") then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local unit = (position - humanoidRootPart.Position).Unit
	local magnitude = (position - humanoidRootPart.Position).Magnitude

	if magnitude >= 10 and magnitude <= 50 then
		if Debounce(`ItemUse/TripplePlungers/Client/{parent2.Name}`, 15) then
			return
		end

		fire:Play()
		Net:RemoteEvent("UseItem"):FireServer(magnitude / 120, hit2.Position, target)
		local part = Instance.new("Part")
		part.Size = createVector(0.1, 0.1, 0.1)
		part.CanCollide = false
		part.Position = position
		part.Transparency = 1
		part.Anchored = true
		part.Parent = workspace
		local attachment = Instance.new("Attachment")
		attachment.Position = createVector(0, 0, 0)
		beam.Attachment0 = attachment
		local bodyVelocity = nil
		local targetModel = target and target:FindFirstAncestorOfClass("Model")
		local playerFromCharacter = targetModel and Players:GetPlayerFromCharacter(targetModel)

		if targetModel and playerFromCharacter then
			local humanoidRootPart2 = targetModel:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 then
				attachment.Parent = humanoidRootPart2
			end
		else
			attachment.Parent = part

			if not ServerAuthority.isEnabled() then
				bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
				bodyVelocity.Velocity = unit * 100
				bodyVelocity.Name = "FlightPower"
				bodyVelocity.P = 2000
				bodyVelocity.Parent = humanoidRootPart
			end
		end

		hit:Play()
		local thread = nil
		local stealingChangedConnection = nil

		local function finish()
			if stealingChangedConnection then
				stealingChangedConnection:Disconnect()
				stealingChangedConnection = nil
			end

			if thread then
				if coroutine.status(thread) == "suspended" then
					pcall(task.cancel, thread)
				end

				thread = nil
			end

			if bodyVelocity then
				bodyVelocity:Destroy()
			end

			part:Destroy()
			attachment:Destroy()
			beam.Attachment0 = nil
		end

		stealingChangedConnection = parent2:GetAttributeChangedSignal("Stealing"):Connect(function()
			if parent2:GetAttribute("Stealing") then
				task.defer(finish)
			end
		end)
		thread = task.delay(magnitude / 120, function()
			task.defer(finish)
		end)

		if parent2:GetAttribute("Stealing") then
			task.defer(finish)
		end
	end
end)