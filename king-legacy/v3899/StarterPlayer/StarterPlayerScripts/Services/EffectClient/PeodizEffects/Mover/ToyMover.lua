local createVector = vector.create
local assets = script.Parent.Parent.Assets
local localPlayer = game.Players.LocalPlayer
localPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
return function()
	local character = localPlayer.Character

	if not character then
		return
	end

	local lowerTorso = character:FindFirstChild("LowerTorso")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (lowerTorso and humanoidRootPart) then
		return
	end

	local v = (_G.MouseHit.Position - humanoidRootPart.Position).Unit * createVector(1, 0, 1)

	if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or v.Magnitude ~= v.Magnitude then
		v = workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)
	end

	local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + v)
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
		_G.PU:Dust({ alignOrientation, folder }, 0.3)
	else
		if dashBV then
			dashBV:Destroy()
		end

		if dashBG then
			dashBG:Destroy()
		end

		local clone = assets.AlignPosition:Clone()
		clone.Responsiveness = 5
		clone.Attachment0 = lowerTorso:FindFirstChildOfClass("Attachment")
		clone.Position = position
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(0, 300000, 0)
		bodyGyro.CFrame = cframe
		bodyGyro.P = 50000
		local folder = Instance.new("Folder")
		folder.Name = "NoRotate"
		folder.Parent = character
		bodyGyro.Parent = lowerTorso
		clone.Parent = lowerTorso
		local descendantAddedConnection = character.DescendantAdded:Connect(function(instance)
			if not (instance:IsA("BodyGyro") or instance:IsA("BodyVelocity")) then
				return
			end

			clone:Destroy()
			bodyGyro:Destroy()
			folder:Destroy()
		end)
		task.spawn(function()
			wait(0.3)
			clone:Destroy()
			bodyGyro:Destroy()
			folder:Destroy()
			descendantAddedConnection:Disconnect()
		end)
	end
end