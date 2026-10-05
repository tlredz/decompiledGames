local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("RequestTeleport")

local function TeleportPlayer(player, cframe: CFrame, value: number?)
	assert(player and cframe)
	local character = player.Character

	if not (character and character.PrimaryPart) then
		warn((`Teleport canceled: {player.Name} does not have a valid character`))
		return
	end

	player:SetAttribute("TeleportInProgress", true)
	character:SetAttribute("CharacterLocked", false)
	local success, result = pcall(function()
		player:RequestStreamAroundAsync(cframe.Position, value or 60)
	end)

	if not success then
		warn((`Failed to preload teleport area for {player.Name}: {result}`))
	end

	if character and character.PrimaryPart then
		remoteEvent:FireClient(player, cframe)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoid and humanoid.SeatPart then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			task.wait(0.1)
			local seatWeld = humanoid.SeatPart and humanoid.SeatPart:FindFirstChild("SeatWeld")

			if seatWeld then
				seatWeld:Destroy()
			end
		end

		local tool = character:FindFirstChildWhichIsA("Tool")

		if tool and tool.Name ~= "Tidebreaker" and tool.Name ~= "Frostbreaker" and humanoid then
			humanoid:UnequipTools()
			task.wait(0.1)
		end

		if humanoidRootPart then
			local anchor = humanoidRootPart:FindFirstChild("Anchor")

			if anchor then
				anchor:Destroy()
			end

			local rootPartAlignAttachment = humanoidRootPart:FindFirstChild("RootPartAlignAttachment")

			if rootPartAlignAttachment then
				local ziplineAlignPos = humanoidRootPart:FindFirstChild("ZiplineAlignPos")

				if ziplineAlignPos then
					ziplineAlignPos:Destroy()
				end

				local ziplineAlignOrient = humanoidRootPart:FindFirstChild("ZiplineAlignOrient")

				if ziplineAlignOrient then
					ziplineAlignOrient:Destroy()
				end

				rootPartAlignAttachment:Destroy()
			end
		end

		local seatWeld = humanoid and humanoid.SeatPart and humanoid.SeatPart:FindFirstChild("SeatWeld")

		if seatWeld then
			seatWeld:Destroy()
		end

		character:PivotTo(cframe)
		player:SetAttribute("TeleportInProgress", false)
	else
		warn((`Teleport canceled: {player.Name} does not have a valid character`))
		player:SetAttribute("TeleportInProgress", false)
	end
end

return TeleportPlayer