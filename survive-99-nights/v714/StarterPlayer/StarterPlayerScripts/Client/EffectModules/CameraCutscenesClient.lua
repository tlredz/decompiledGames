local CameraCutscenesClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local jumpscare = nil
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local count = 0
local cameraType = "Custom"
local exposureCompensation = 0
local flag = false

function CameraCutscenesClient.Jumpscare(value)
	local clone = jumpscare:Clone()
	clone.Parent = workspace
	local currentCamera = workspace.CurrentCamera
	local v = value or "Deer"

	if currentCamera then
		currentCamera:AddTag("WaitForDeer")
		local reviveBillboards = {}

		for _, v2 in pairs(CollectionService:GetTagged("Body" .. localPlayer.UserId)) do
			if v2:FindFirstChild("ReviveBillboard") then
				table.insert(reviveBillboards, v2:FindFirstChild("ReviveBillboard"))
			end
		end

		for _, v2 in pairs(reviveBillboards) do
			v2.Enabled = false
		end

		flag = true

		if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
			cameraType = currentCamera.CameraType
			print(cameraType)
		end

		if not (game.Lighting.ExposureCompensation > 1.89 and game.Lighting.ExposureCompensation < 1.91) then
			exposureCompensation = game.Lighting.ExposureCompensation
		end

		game.Lighting.ExposureCompensation = 1.9
		currentCamera.CameraType = Enum.CameraType.Scriptable
		local track = nil
		local track2 = nil

		if v == "Deer" then
			track = clone.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(clone.JumpscareDeer.Folder.Camera)
			track2 = clone.JumpscareDeer.AnimationController.Animator:LoadAnimation(clone.JumpscareDeer.Folder.Jumpscare)
		elseif v == "Owl" then
			track = clone.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(clone.JumpscareDeer.Folder.Camera)
			track2 = clone.JumpscareOwl.AnimationController.Animator:LoadAnimation(clone.JumpscareOwl.Folder.Jumpscare)
		elseif v == "Ram" then
			track = clone.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(clone.JumpscareDeer.Folder.Camera)
			track2 = clone.JumpscareRam.AnimationController.Animator:LoadAnimation(clone.JumpscareRam.Animations.Jumpscare)
		elseif v == "Cat" then
			track = clone.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(clone.JumpscareDeer.Folder.Camera)
			track2 = clone.JumpscareCat.AnimationController.Animator:LoadAnimation(clone.JumpscareCat.Animations.Jumpscare)
		elseif v == "Easter Bunny" then
			track = clone.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(clone.JumpscareDeer.Folder.Camera)
			track2 = clone["JumpscareEaster Bunny"].NPC.Animator:LoadAnimation(clone["JumpscareEaster Bunny"].Animations.Jumpscare)
		end

		for _, child in pairs(clone:GetChildren()) do
			if not (string.sub(child.Name, 1, 4) == "Jump" and string.sub(child.Name, 10) ~= v) then
				continue
			end

			child:Destroy()
		end

		count += 1
		local v2 = count
		local heartbeatConnection = nil
		task.spawn(function()
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if count == v2 then
					currentCamera.CFrame = clone.HumanoidCameraRig.Torso.CFrame
				elseif clone then
					clone:Destroy()
				else
					heartbeatConnection:Disconnect()
				end
			end)
		end)
		track:Play()
		track2:Play()
		ReplicatedStorage.Core.Sounds.JumpscareDeer:Play()
		local flag2 = false

		local function onStopped()
			if flag2 then
				return
			end

			track:Stop()
			flag2 = true

			if count == v2 then
				currentCamera.CameraType = cameraType
			end

			game.Lighting.ExposureCompensation = exposureCompensation

			if count == v2 then
				count += 1
			end

			if clone then
				clone:Destroy()
			end

			for _, v3 in pairs(reviveBillboards) do
				v3.Enabled = true
			end

			currentCamera:RemoveTag("WaitForDeer")
			flag = false
			ReplicatedStorage.Core.Sounds.JumpscareDeer:Stop()
		end

		task.spawn(function()
			wait(6.5)
			onStopped()
		end)
		track.Stopped:Connect(function()
			onStopped()
		end)
	end
end

Client.Events.DeerJumpscareAnimation:Connect(function()
	task.spawn(function()
		CameraCutscenesClient.Jumpscare()
	end)
end)
Client.Events.OwlJumpscareAnimation:Connect(function()
	task.spawn(function()
		CameraCutscenesClient.Jumpscare("Owl")
	end)
end)
Client.Events.RamJumpscareAnimation:Connect(function()
	task.spawn(function()
		CameraCutscenesClient.Jumpscare("Ram")
	end)
end)
Client.Events.CatJumpscareAnimation:Connect(function()
	task.spawn(function()
		CameraCutscenesClient.Jumpscare("Cat")
	end)
end)
Client.Events.EasterBunnyJumpscareAnimation:Connect(function()
	task.spawn(function()
		CameraCutscenesClient.Jumpscare("Easter Bunny")
	end)
end)

function CameraCutscenesClient.OpenSeedBox(p)
	task.spawn(function()
		local fairyPlants = Client.Databases.FairyPlants

		if flag then
			return
		end

		local clone

		if p == "Strawberries" or p == "Chillis" or p == "Fireflies" or p == "Flowers" or p == "Roses" or p == "Brightwood Trees" then
			clone = ReplicatedStorage.Assets.Seeds.SeedBox:Clone()
		else
			clone = ReplicatedStorage.Assets.Seeds.SeedBoxHalloween:Clone()
		end

		if fairyPlants[p] then
			clone.Back.Decal.Texture = fairyPlants[p].image
			clone.Body.Decal.Texture = fairyPlants[p].image

			for i = 1, 5 do
				local findFirstChild = clone:FindFirstChild("Seed" .. i)
				findFirstChild.Color = fairyPlants[p].seedColour

				if not fairyPlants[p].seedMaterial then
					continue
				end

				local findFirstChild_2 = clone:FindFirstChild("Seed" .. i)
				findFirstChild_2.Material = fairyPlants[p].seedMaterial
			end
		end

		local v = true
		local _ = workspace.CurrentCamera
		UtilityAlec.GetAnimationLength(clone.Animation)
		clone.Parent = workspace
		count += 1
		local v2 = count
		local heartbeatConnection = nil
		local changedConnection = nil
		local track = clone.AnimationController.Animator:LoadAnimation(clone.Animation)
		task.spawn(function()
			wait(1.4)
			Client.Sound.Play("SeedBox", {
				Duplicate = true
			})
		end)
		local vector = Vector2.new(0.499715596, 0.480593622)
		local vector2 = Vector2.new(0.345847547, 0.696347058)
		local inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or not v or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			local viewportSize = workspace.CurrentCamera.ViewportSize

			if math.abs(input.Position.X - vector.X * viewportSize.X) > vector2.X * viewportSize.X / 2 then
				return
			end

			if math.abs(input.Position.Y - vector.Y * viewportSize.Y) > vector2.Y * viewportSize.Y / 2 then
				return
			end

			v = false

			if count == v2 then
				count += 1
			end

			if clone then
				clone:Destroy()
			end
		end)
		task.spawn(function()
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if count == v2 then
					clone:PivotTo(workspace.CurrentCamera.CFrame * CFrame.new(
						0.00186538696,
						0.00748920441,
						-0.145399094,
						-1,
						-0,
						-0,
						0,
						1,
						0,
						-0,
						-0,
						-1
					))
				elseif clone then
					clone:Destroy()
				else
					heartbeatConnection:Disconnect()
				end
			end)
			changedConnection = workspace.CurrentCamera.Changed:connect(function()
				if clone then
					clone:PivotTo(workspace.CurrentCamera.CFrame * CFrame.new(
						0.00186538696,
						0.00748920441,
						-0.145399094,
						-1,
						-0,
						-0,
						0,
						1,
						0,
						-0,
						-0,
						-1
					))
				end
			end)
		end)
		track:Play()
		task.spawn(function()
			wait(2.65)

			if clone and clone:FindFirstChild("Top") then
				clone.Top.Transparency = 1
			end

			wait(3)

			if count == v2 then
				count += 1
			end

			if clone then
				clone:Destroy()
			end

			if inputBeganConnection then
				inputBeganConnection:Disconnect()
			end

			changedConnection:Disconnect()
		end)
	end)
end

function CameraCutscenesClient.Claw()
	task.spawn(function()
		local clone = Client.Interface.ScratchFrame:Clone()
		clone.Visible = true
		clone.Parent = localPlayer.PlayerGui.Interface
		clone.ClipsDescendants = false
		local mask = clone:FindFirstChild("Mask") or Instance.new("Frame")
		mask.Name = "Mask"
		mask.BackgroundTransparency = 1
		mask.ClipsDescendants = true
		mask.AnchorPoint = Vector2.new(0, 0)
		mask.Position = UDim2.new(0, 0, 0, 0)
		mask.Size = UDim2.new(0, 0, 1, 0)
		mask.Parent = clone
		clone.Visible = true
		mask.Visible = true
		local imageLabel = mask:WaitForChild("ImageLabel")
		imageLabel.Parent = mask
		imageLabel.AnchorPoint = Vector2.new(0, 0)
		imageLabel.Position = UDim2.new(0, 0, 0, 0)
		imageLabel.Size = UDim2.new(10, 0, 1, 0)
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0.001
		TweenService:Create(numberValue, tweenInfo, {
			Value = 1
		}):Play()
		numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			mask.Size = UDim2.new(numberValue.Value, 0, 1, 0)
			imageLabel.Size = UDim2.new(1 / numberValue.Value, 0, 1, 0)
		end)
		Client.CamShake.ShakeOnce(9, 5.5, 0.02, 0.15)
		wait(0.3)

		if imageLabel and imageLabel.Parent then
			TweenService:Create(imageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				ImageTransparency = 1
			}):Play()
			task.spawn(function()
				wait(2)

				if clone then
					clone:Destroy()
				end
			end)
		end
	end)
end

Client.Events.DeerClawAnimation:Connect(function()
	CameraCutscenesClient.Claw()
end)
Client.Events.SeedBoxAnim:Connect(function(p)
	Client.CameraCutscenesClient.OpenSeedBox(p)
end)

function CameraCutscenesClient.Init()
	task.spawn(function()
		jumpscare = ReplicatedStorage:WaitForChild("Jumpscare")
		UtilityAlec.preload({
			jumpscare.JumpscareDeer.Folder.Camera,
			jumpscare.JumpscareDeer.Folder.Jumpscare,
			ReplicatedStorage.Assets.Seeds.SeedBox.Animation,
			"rbxassetid://137570886127632"
		})
	end)
end

return CameraCutscenesClient