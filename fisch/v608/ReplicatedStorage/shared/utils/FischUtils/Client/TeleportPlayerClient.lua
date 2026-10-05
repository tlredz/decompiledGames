local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function TeleportPlayer(cframe: CFrame)
	assert(cframe)
	local character = localPlayer.Character
	local primaryPart = character and character.PrimaryPart

	if not (character and primaryPart) then
		warn("Teleport canceled: No active character")
		return
	end

	ReplicatedStorage.events.exitzipline:Fire()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoid and humanoid.SeatPart then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		task.wait()
		local seatWeld = humanoid.SeatPart and humanoid.SeatPart:FindFirstChild("SeatWeld")

		if seatWeld then
			seatWeld:Destroy()
			task.wait()
		end
	end

	local tool = character:FindFirstChildWhichIsA("Tool")

	if tool and tool.Name ~= "Tidebreaker" and tool.Name ~= "Frostbreaker" and humanoid then
		humanoid:UnequipTools()
		task.wait()
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

	primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	character:PivotTo(cframe)
end

return TeleportPlayer