local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return {
	Move = function(player)
		local duration = player.Duration or 0.3
		local character = player.Character
		local fastRotate = player.FastRotate

		if not character then
			return
		end

		local lowerTorso = character:FindFirstChild("LowerTorso")
		local rootPart = player.RootPart

		if not (lowerTorso and rootPart) then
			return
		end

		local mouseHit = player.MouseHit

		if not mouseHit then
			return
		end

		local v = (mouseHit.Position - rootPart.Position).Unit * createVector(1, 0, 1)

		if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or v.Magnitude ~= v.Magnitude then
			v = workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)
		end

		local cframe = CFrame.new(rootPart.Position, rootPart.Position + v)
		local position = (cframe * CFrame.new(0, 0, -75)).Position
		local dashBV = character:FindFirstChild("DashBV", true)
		local dashBG = character:FindFirstChild("DashBG", true)

		if dashBG or dashBV then
			if dashBG then
				dashBG:Destroy()
			end

			local _, v2, _ = cframe:ToOrientation()
			local folder = Instance.new("Folder")
			folder.Name = "NoRotate"
			folder.Parent = character
			local alignOrientation = Instance.new("AlignOrientation")
			alignOrientation.MaxTorque = 1000000
			alignOrientation.Responsiveness = 50
			alignOrientation.Attachment0 = lowerTorso:FindFirstChildOfClass("Attachment")
			alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
			alignOrientation.CFrame = CFrame.new(cframe.Position) * CFrame.fromOrientation(0, v2, 0)
			alignOrientation.Parent = lowerTorso
			PeoUtils:Dust({ alignOrientation, folder }, duration)
		else
			if dashBV then
				dashBV:Destroy()
			end

			if dashBG then
				dashBG:Destroy()
			end

			local clone

			if player.NoMove then
				clone = nil
			else
				clone = ReplicatedStorage.Chest.FruitEffect.Allo.AlignPosition:Clone()
				clone.Responsiveness = 6
				clone.Attachment0 = lowerTorso:FindFirstChildOfClass("Attachment")
				clone.Position = position
				clone.Parent = lowerTorso
			end

			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = createVector(0, 300000, 0)
			bodyGyro.CFrame = cframe
			bodyGyro.P = 30000
			bodyGyro.Parent = lowerTorso
			local folder = Instance.new("Folder")
			folder.Name = "NoRotate"
			folder.Parent = character
			local v2 = duration * 3

			if fastRotate then
				v2 = duration
			end

			PeoUtils:Dust(folder, v2)
			local descendantAddedConnection = nil
			descendantAddedConnection = character.DescendantAdded:Connect(function(instance)
				if instance:IsA("BodyGyro") or instance:IsA("BodyVelocity") then
					if clone and clone.Parent then
						clone:Destroy()
					end

					bodyGyro:Destroy()
					folder:Destroy()
					descendantAddedConnection:Disconnect()
				end
			end)
			task.spawn(function()
				task.wait(duration)

				if clone and clone.Parent then
					clone:Destroy()
				end

				if bodyGyro then
					bodyGyro:Destroy()
				end

				if descendantAddedConnection then
					descendantAddedConnection:Disconnect()
				end
			end)
		end
	end
}