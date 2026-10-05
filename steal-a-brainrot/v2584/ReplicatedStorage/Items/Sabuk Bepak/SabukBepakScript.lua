local createVector = vector.create
local Players = game:GetService("Players")
game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Debounce = require(packages.Debounce)
local parent = script.Parent
local handle = parent:WaitForChild("Handle")
local beam = handle:WaitForChild("Beam")
handle:WaitForChild("RopeAttachment")
local parent2 = parent.Parent.Parent
parent.Activated:Connect(function()
	if parent2:GetAttribute("Stealing") then
		return
	end

	local PlayerMouse = require(ReplicatedStorage.Packages.PlayerMouse)
	local hit = PlayerMouse.Hit
	local target = PlayerMouse.Target

	if not target then
		return
	end

	local position = hit.Position
	local character = parent2.Character

	if not character then
		return
	end

	local tool = character:FindFirstChildWhichIsA("Tool", true)

	if not (tool and tool.Name == "Sabuk Bepak") then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local _ = (position - humanoidRootPart.Position).Unit
	local magnitude = (position - humanoidRootPart.Position).Magnitude

	if magnitude >= 10 and magnitude <= 50 then
		if Debounce(`ItemUse/SabukBepak/Client/{parent2.Name}`, 15) then
			return
		end

		Net:RemoteEvent("UseItem"):FireServer(magnitude / 120, hit.Position, target)
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
		local targetModel = target and target:FindFirstAncestorOfClass("Model")
		local playerFromCharacter = targetModel and Players:GetPlayerFromCharacter(targetModel)

		if targetModel and playerFromCharacter then
			local humanoidRootPart2 = targetModel:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 then
				attachment.Parent = humanoidRootPart2
			end
		else
			part:Destroy()
		end

		local thread = nil

		local function finish()
			if thread then
				if coroutine.status(thread) == "suspended" then
					pcall(task.cancel, thread)
				end

				thread = nil
			end

			part:Destroy()
			attachment:Destroy()
			beam.Attachment0 = nil
		end

		thread = task.delay(magnitude / 120, function()
			task.defer(finish)
		end)
	end
end)