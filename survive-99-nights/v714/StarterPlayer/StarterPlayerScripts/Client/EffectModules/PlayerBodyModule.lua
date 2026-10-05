local createVector = vector.create
local PlayerBodyModule = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local v = nil
local v2 = 0
local ancestryChangedConnection = nil

function ForceCameraSubject(cameraSubject)
	local v3 = v2 + 1
	v2 = v3
	wait()

	if workspace.CurrentCamera:HasTag("WaitForDeer") then
		repeat
			wait()
		until not workspace.CurrentCamera:HasTag("WaitForDeer")
	end

	for _ = 1, 10 do
		if v2 ~= v3 then
			break
		end

		workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		workspace.CurrentCamera.CameraSubject = cameraSubject
		wait(0.1)
	end
end

function BodyAdded(instance)
	for _, part in pairs(instance:GetChildren()) do
		if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart") then
			continue
		end

		part.CanCollide = true
		part.Massless = true
	end

	if instance:GetAttribute("PlayerBody") == localPlayer.UserId then
		return
	end

	while instance.Parent ~= nil do
		local position = instance:GetPivot().Position

		if instance.PrimaryPart and instance.Parent == workspace.Characters and (position - workspace.CurrentCamera.CFrame.Position).Magnitude < 60 then
			instance.PrimaryPart.ProximityAttachment.WorldPosition = instance.PrimaryPart.Position + createVector(
				0,
				3,
				0
			)
			RunService.RenderStepped:Wait()
		else
			wait(1)
		end
	end
end

function MyBodyAdded(instance)
	v = instance

	while instance.PrimaryPart == nil do
		RunService.RenderStepped:Wait()
	end

	task.spawn(function()
		instance.PrimaryPart:WaitForChild("ProximityAttachment"):Destroy()
	end)

	if ancestryChangedConnection then
		ancestryChangedConnection:Disconnect()
	end

	ancestryChangedConnection = v.AncestryChanged:Connect(function()
		if v.Parent == workspace.Characters then
			local humanoid = v:FindFirstChild("Humanoid")
			ForceCameraSubject(humanoid)
		elseif v.Parent.Name == "ItemBag" then
			local parent = v.Parent.Parent
			local humanoid = parent.Character and parent.Character:FindFirstChild("Humanoid")

			if humanoid then
				ForceCameraSubject(humanoid)
			end
		end
	end)
	local humanoid = v:FindFirstChild("Humanoid")
	ForceCameraSubject(humanoid)
end

function MyBodyRemoved()
	v = nil

	if ancestryChangedConnection then
		ancestryChangedConnection:Disconnect()
		ancestryChangedConnection = nil
	end

	if localPlayer.Character then
		local humanoid = localPlayer.Character:FindFirstChild("Humanoid")

		if humanoid and workspace.CurrentCamera.CameraSubject ~= humanoid then
			ForceCameraSubject(humanoid)
		end
	end
end

localPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	ForceCameraSubject(humanoid)
end)

function PlayerBodyModule.Init()
	Client.Utility.ForAllTagged("Body" .. localPlayer.UserId, MyBodyAdded, MyBodyRemoved)
	Client.Utility.ForAllTagged("PlayerBody", BodyAdded)
end

return PlayerBodyModule