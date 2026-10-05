local createVector = vector.create
local OwlModuleClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local random = Random.new()
local flag = false
local v = -100
local playerByUserIds = {}
local v2 = {}
local v3 = nil

function GetPlayer(p)
	if playerByUserIds[p] then
		return playerByUserIds[p]
	end

	local playerByUserId = game.Players:GetPlayerByUserId(p)

	if not playerByUserId then
		return
	end

	playerByUserIds[p] = playerByUserId
	return playerByUserId
end

function GetFocusPlayer(instance)
	local chasingPlayer = instance:GetAttribute("ChasingPlayer") or instance:GetAttribute("LocalChasingPlayer")

	if chasingPlayer then
		return GetPlayer(chasingPlayer)
	end
end

function IsPlayerSighted(instance, _)
	if Client.PlayerHandler.HumanoidRootPart == nil or Client.PlayerHandler.Humanoid == nil or not instance:GetAttribute("TrackPlayer") then
		return
	end

	if (instance:GetAttribute("ObserveRange") or 50) < (instance:GetPivot().Position - Client.PlayerHandler.HumanoidRootPart.Position).Magnitude then
		return "OutOfRange"
	end

	if Client.PlayerHandler.Humanoid.MoveDirection.Magnitude > 0.2 then
		return true
	end
end

local v4 = {}

function UrgentEffect(instance, options)
	if v4[instance] then
		return
	end

	v4[instance] = true
	local v5 = options or {}
	local scaleAmount = v5.scaleAmount or 3
	local scaleDuration = v5.scaleDuration or 0.45
	local shakeDuration = v5.shakeDuration or 2.4
	local shakeIntensity = v5.shakeIntensity or 1
	local shakeSpeed = v5.shakeSpeed or 30

	if instance and instance:FindFirstChild("Frame") and instance.Frame:FindFirstChild("RedHolder") then
		instance.Frame.RedHolder.Size = UDim2.new(1, 0, 1, 0)
		instance.Frame.RedHolder.RedFill.Size = UDim2.new(1, 0, 1, 0)
	end

	local size = instance.Size
	local studsOffsetWorldSpace = instance.StudsOffsetWorldSpace
	local uDim = UDim2.new(size.X.Scale * scaleAmount, size.X.Offset, size.Y.Scale * scaleAmount, size.Y.Offset)
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(scaleDuration, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = uDim
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		local heartbeatConnection = nil
		local total = 0
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if shakeDuration <= total then
				heartbeatConnection:Disconnect()
				instance.StudsOffsetWorldSpace = studsOffsetWorldSpace
				TweenService:Create(instance, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Size = size
				}):Play()
			else
				local v6 = 1 - total / shakeDuration
				local v7 = math.sin(total * shakeSpeed) * shakeIntensity * v6
				instance.StudsOffsetWorldSpace = Vector3.new(
					studsOffsetWorldSpace.X + v7,
					studsOffsetWorldSpace.Y,
					studsOffsetWorldSpace.Z
				)

				if instance and instance:FindFirstChild("Frame") and instance.Frame:FindFirstChild("RedHolder") then
					instance.Frame.RedHolder.Size = UDim2.new(1, 0, 1, 0)
					instance.Frame.RedHolder.RedFill.Size = UDim2.new(1, 0, 1, 0)
				end
			end
		end)
	end)
end

function UpdateSpottedPct(instance, p)
	local v5 = v2[instance]

	if not v5 then
		return
	end

	if p == nil then
		v5.Enabled = false
		return
	end

	local v6 = instance:GetPivot() + createVector(0, 2, 0)
	local worldToScreenPoint, v7 = workspace.CurrentCamera:WorldToScreenPoint(v6.Position)
	local magnitude = (v6.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local X = worldToScreenPoint.X

	if not v7 then
		local unit = (workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)).Unit
		local unit2 = ((v6.Position - workspace.CurrentCamera.CFrame.Position) * createVector(1, 0, 1)).Unit
		local _, v8 = Client.Utility.GetAngleBetweenVectors(unit, unit2)
		X = v8 > 0 and -500 or viewportSize.X + 500
	end

	local v8 = math.clamp(X, 100, viewportSize.X - 100)
	local v9 = math.clamp(worldToScreenPoint.Y, 50, viewportSize.Y - 50)

	if not v7 then
		v9 = viewportSize.Y / 2
	end

	local screenPointToRay = workspace.CurrentCamera:ScreenPointToRay(v8, v9)
	local v10 = screenPointToRay.Origin + screenPointToRay.Direction * magnitude
	v5.Adornee.CFrame = CFrame.new(v10)
	v5.Frame.RedHolder.Size = UDim2.new(1, 0, p, 0)
	v5.Frame.RedHolder.RedFill.Size = UDim2.new(1, 0, 1 / p, 0)
	v5.Enabled = true

	if p >= 1 then
		UrgentEffect(v5)
	end
end

function TrackHeadPosition(instance)
	local head = instance:WaitForChild("RootPart"):WaitForChild("GLOBAL"):WaitForChild("Waist"):WaitForChild("Chest"):WaitForChild("Head")
	local value = instance:WaitForChild("InitialPoses"):WaitForChild("Head_Initial").Value
	local v5 = 0
	local v6 = 0
	local v7 = 45
	local v8 = false
	local v9 = -100
	local v10 = 0
	local v11 = nil
	v3 = instance
	task.spawn(function()
		while instance.Parent do
			local v12 = task.wait()
			local v13 = GetFocusPlayer(instance)

			if v13 and v13.Character then
				local position = v13.Character:GetPivot().Position
				local lookVector = instance:GetPivot().LookVector
				local unit = (position - instance:GetPivot().Position).Unit
				local angleBetweenVectors, v14 = Client.Utility.GetAngleBetweenVectors(lookVector, unit)
				v5 = math.deg(angleBetweenVectors * v14)
				v7 = 1500
			else
				v5 = 0
				v7 = 45
			end

			local v14 = IsPlayerSighted(instance)

			if v14 == true then
				v10 += v12
				v9 = time()
			elseif time() - v9 > 1 then
				v10 = math.max(v10 - v12 * 1, 0)
			end

			local movementTimeAllowed = instance:GetAttribute("MovementTimeAllowed") or 1

			if movementTimeAllowed <= v10 and instance:GetAttribute("TrackPlayer") and v8 == false then
				Client.Events.OwlChasePlayer:FireServer(instance)
				v8 = true
				instance:SetAttribute("LocalChasingPlayer", localPlayer.UserId)
				UpdateSpottedPct(instance, 1)
				task.delay(2, function()
					instance:SetAttribute("LocalChasingPlayer", nil)
					DestroyBillboard(instance)
				end)
			end

			if instance:GetAttribute("ChasingPlayer") and not v8 then
				DestroyBillboard(instance)
			elseif instance:GetAttribute("Despawning") then
				DestroyBillboard(instance)
			elseif instance:GetAttribute("LocalChasingPlayer") == localPlayer.UserId then
				UpdateSpottedPct(instance, 1)
			elseif instance:GetAttribute("TrackPlayer") then
				if v14 == "OutOfRange" then
					UpdateSpottedPct(instance, nil)
				elseif v13 == nil and not v8 then
					local v15 = math.clamp(v10 / movementTimeAllowed, 0, 1)
					UpdateSpottedPct(instance, v15)
					v11 = v15
				elseif v13 and not v8 and v11 ~= nil then
					UpdateSpottedPct(instance, nil)
				end
			end

			local v15 = v5 - v6

			if math.abs(v15) < v7 * v12 then
				v6 = v5
			else
				local v16 = v15 < 0 and -1 or 1
				v6 += v7 * v12 * v16
			end

			local v16 = v6
			head.CFrame = value * CFrame.Angles(0, math.rad(v16), 0)
		end
	end)
end

Client.Events.OwlFillEyesVisual:Connect(function()
	if not v3 then
		return
	end

	local v5 = v2[v3]

	if not v5 then
		return
	end

	UrgentEffect(v5)
end)

function FlickerFlashlight()
	if time() - v < 10 then
		return
	end

	local currentlyEquippedClass = Client.InventoryHandler.GetCurrentlyEquippedClass()

	if currentlyEquippedClass and currentlyEquippedClass.Model and currentlyEquippedClass.Model:GetAttribute("ToolName") == "Flashlight" then
		v = time()
		currentlyEquippedClass.Tool:Flicker()
	end
end

function OwlAggroPlayer(instance)
	if flag then
		return
	end

	flag = true

	if not instance.Parent then
		return
	end

	local nPCTarget = instance:FindFirstChild("NPCTarget")

	if not nPCTarget then
		return
	end

	FlickerFlashlight()

	while nPCTarget.Value == localPlayer.Character and instance.Parent ~= nil do
		wait(1)

		if random:NextInteger(1, 10) == 1 then
			FlickerFlashlight()
		end
	end

	flag = false
end

function TrackOwlVisible(folder)
	task.spawn(function()
		folder:WaitForChild("NPC"):WaitForChild("Animator")
		folder:WaitForChild("HumanoidRootPart")
		folder:WaitForChild("OWL_EYES")
		task.wait(0.75)

		for _, part in pairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			local origTransparency = part:GetAttribute("OrigTransparency")

			if origTransparency then
				part.Transparency = origTransparency
			end
		end
	end)
end

function DestroyBillboard(p)
	local v5 = v2[p]

	if v5 then
		v2[p] = nil
		v5.Adornee:Destroy()
		v5.Enabled = false
		v5:Destroy()
	end
end

function OwlRemoved(p)
	DestroyBillboard(p)
end

function OwlAdded(instance)
	if instance.Parent ~= workspace.Characters then
		return
	end

	TrackOwlVisible(instance)

	if not instance.PrimaryPart then
		repeat
			task.wait()
		until instance.PrimaryPart
	end

	local clone = game.ReplicatedStorage.Assets.Interface.OwlBillboard:Clone()
	clone.Adornee = Instance.new("Attachment", workspace.Terrain)
	clone.Parent = localPlayer.PlayerGui
	v2[instance] = clone
	task.spawn(function()
		TrackHeadPosition(instance)
	end)
	instance:WaitForChild("Collider").Touched:Connect(function(otherPart)
		if otherPart.Name == "TorchTouchZone" then
			Client.Events.MonsterHitByTorch:InvokeServer(instance)
		end
	end)
	task.spawn(function()
		local nPCTarget = instance:WaitForChild("NPCTarget")
		nPCTarget.Changed:Connect(function()
			if nPCTarget.Value == localPlayer.Character then
				OwlAggroPlayer(instance)
			end
		end)

		if nPCTarget.Value == localPlayer.Character then
			OwlAggroPlayer(instance)
		end
	end)
end

function OwlModuleClient.Init()
	Client.Utility.ForAllTagged("Owl", OwlAdded, OwlRemoved)
end

return OwlModuleClient