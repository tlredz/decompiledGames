local createVector = vector.create
local halloweenEvent = game.ReplicatedStorage.Remotes:WaitForChild("HalloweenEvent", 1e999)
local halloweenFunction = game.ReplicatedStorage.Remotes:WaitForChild("HalloweenFunction", 1e999)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Notification = require(game.ReplicatedStorage.Notification)
local Events = require(script.Events)
local ViewportWindow = require(script.ViewportWindow)
local localPlayer = game.Players.LocalPlayer
local v = {}
local v2 = {}
local flag = false
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayRandomSound(p: string, p2: number, position, value: number?)
	local v4 = math.random(1, p2)
	Sound:Play(string.format("%s_%02d", p, v4), position, nil, nil, value or 2)
end

local function PlayDoorAnimation(instance, flag2: boolean)
	local leftDoor = instance:FindFirstChild("LeftDoor")
	local rightDoor = instance:FindFirstChild("RightDoor")
	local originalCFrame = nil
	local originalCFrame2

	if leftDoor then
		originalCFrame2 = leftDoor:GetAttribute("OriginalCFrame") or leftDoor:GetPivot()
		leftDoor:SetAttribute("OriginalCFrame", originalCFrame2)
	end

	if rightDoor then
		originalCFrame = rightDoor:GetAttribute("OriginalCFrame") or rightDoor:GetPivot()
		rightDoor:SetAttribute("OriginalCFrame", originalCFrame)
	end

	if flag2 then
		PlayRandomSound("Halloween_Door_Open", 7, instance.Proximity.Position) -- equivalent call inferred; original call site unknown
	else
		Sound:Play("DoorCreakClose", instance.Proximity.Position, nil, nil, 2)
	end

	local v4 = 0

	while v4 < 1 do
		v4 = math.min(v4 + task.wait() * 1.3, 1)
		local v5 = flag2 and v4 or 1 - v4

		if leftDoor then
			leftDoor:PivotTo(originalCFrame2 * CFrame.Angles(0, -1.8849555921538759 * v5, 0))
		end

		if rightDoor then
			rightDoor:PivotTo(originalCFrame * CFrame.Angles(0, 1.8849555921538759 * v5, 0))
		end
	end
end

local function ShowScene(instance, scene: string)
	local child = game.ReplicatedStorage.HalloweenRealms:FindFirstChild(scene)

	if not child then
		return nil
	end

	local clone = child:Clone()
	clone:PivotTo(instance.Part.CFrame)
	local v4 = ViewportWindow.FromPart(
		instance.Part,
		Enum.NormalId.Front,
		instance.Part,
		1,
		0,
		-instance.Part.CFrame.LookVector
	)
	v4.ViewportFrame.LightColor = Color3.fromRGB(127, 127, 127)
	v4.ViewportFrame.Ambient = Color3.fromRGB(255, 255, 255)
	clone.Parent = Instance.new("WorldModel", v4.ViewportFrame)
	local clone2 = script.ImageLabel:Clone()
	clone2.Parent = v4.ViewportFrame.Parent
	local TweenService = game:GetService("TweenService")
	TweenService:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1e999, true), {
		Size = UDim2.fromScale(1.3, 1.3)
	}):Play()
	return v4
end

local function SetLight(instance, flag2: boolean)
	local cube003 = instance:FindFirstChild("Cube.003")

	if cube003 then
		local TweenService = game:GetService("TweenService")
		TweenService:Create(cube003, TweenInfo.new(1), {
			Color = flag2 and Color3.fromRGB(177, 165, 133) or Color3.new(0, 0, 0)
		}):Play()
	end
end

local function DimAllExcept(instance)
	for k in pairs(v2) do
		if k ~= instance then
			SetLight(k, false)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RestoreAllLights()
	for k in pairs(v2) do
		SetLight(k, true)
	end
end

local function SetupHalloweenDoor(descendant)
	if descendant.Name ~= "HalloweenDoor" or not descendant.Parent or v2[descendant] then
		return
	end

	local maid = Maid.new()
	v2[descendant] = maid
	local proximityPrompt = descendant:WaitForChild("Proximity"):WaitForChild("ProximityPrompt")
	Maid.new()

	local function RefreshLightFromAttributes()
		local cooldownUntil = descendant:GetAttribute("CooldownUntil")

		if descendant:GetAttribute("DoorOpen") or typeof(cooldownUntil) == "number" and workspace:GetServerTimeNow() < cooldownUntil then
			SetLight(descendant, false)
		elseif not flag or descendant == v3 then
			SetLight(descendant, true)
		end
	end

	maid:GiveTask(descendant:GetAttributeChangedSignal("CooldownUntil"):Connect(RefreshLightFromAttributes))
	maid:GiveTask(descendant:GetAttributeChangedSignal("DoorOpen"):Connect(RefreshLightFromAttributes))
	local flag2 = false
	maid:GiveTask(proximityPrompt.Triggered:Connect(function()
		PlayRandomSound("Halloween_Knock", 10, descendant.Proximity.Position) -- equivalent call inferred; original call site unknown
		local cooldownUntil = descendant:GetAttribute("CooldownUntil")

		if typeof(cooldownUntil) == "number" and workspace:GetServerTimeNow() < cooldownUntil then
			Notification.new("It seems like nobody is home..."):Display()
			return
		end

		if flag then
			Notification.new("You're still busy with another door!"):Display()
			return
		end

		task.wait(1.2)

		if flag2 then
			return
		end

		flag2 = true
		local v4 = halloweenFunction:InvokeServer(descendant)
		task.delay(0.1, function()
			flag2 = false
		end)

		if v4 then
			return
		end

		RefreshLightFromAttributes()
	end))
	maid:GiveTask(descendant.AncestryChanged:Once(function()
		maid:DoCleaning()
		v2[descendant] = nil

		if v3 == descendant then
			v3 = nil
			flag = false
			RestoreAllLights() -- equivalent call inferred; original call site unknown
		end
	end))
	maid:GiveTask(function()
		v[descendant] = nil
	end)
end

halloweenEvent.OnClientEvent:Connect(function(p, instance, p2, data)
	if p == "DoorOpened" then
		if not (instance and instance.Parent) then
			return
		end

		local v4 = data and data.Event == "Boss Fight"
		local proximityPrompt = instance:FindFirstChild("Proximity") and instance.Proximity:FindFirstChild("ProximityPrompt")

		if proximityPrompt then
			proximityPrompt.Enabled = false
		end

		if p2 == localPlayer and not v4 then
			flag = true
			v3 = instance
			DimAllExcept(instance)
			local Global = require(game.ReplicatedStorage.Global)
			Global.ALREADYINDOOR = true
		end

		task.spawn(function()
			PlayDoorAnimation(instance, true)
			SetLight(instance, false)
		end)
		local v5 = data and data.Scene and (v4 or p2 == localPlayer) and ShowScene(instance, data.Scene)

		if v5 then
			local maid = Maid.new()
			maid:GiveTask(v5)
			maid:GiveTask(v5.ViewportFrame)
			maid:GiveTask(v5.ViewportFrame.Parent)
			v[instance] = maid
			local event = data.Event and Events:GetEvent(data.Event)

			if event then
				local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
				local v6 = Signal2.new()

				if typeof(event) == "table" then
					task.spawn(event.func, instance, v5.ViewportFrame, data.Arguments or {}, v6)
				else
					task.spawn(event, instance, v5.ViewportFrame, data.Arguments or {}, v6)
				end

				v6:Fire()
			end
		end
	elseif p == "BossTeleportSound" then
		PlayRandomSound("Halloween_Portal_Go_Through", 10, game.Players.LocalPlayer.Character.HumanoidRootPart.Position) -- equivalent call inferred; original call site unknown
	elseif p == "EventFinished" then
		if not (instance and instance.Parent) then
			return
		end

		task.spawn(function()
			PlayDoorAnimation(instance, false)
			SetLight(instance, true)
			task.wait(1)
			local v4 = v[instance]

			if v4 then
				v4:DoCleaning()
				v[instance] = nil
			end
		end)
		local proximityPrompt = instance:FindFirstChild("Proximity") and instance.Proximity:FindFirstChild("ProximityPrompt")

		if proximityPrompt then
			proximityPrompt.Enabled = true
		end

		if v3 == instance then
			v3 = nil
			flag = false
			local Global = require(game.ReplicatedStorage.Global)
			Global.ALREADYINDOOR = false
			RestoreAllLights() -- equivalent call inferred; original call site unknown
		else
			SetLight(instance, true)
		end
	end
end)
halloweenEvent.OnClientEvent:Connect(function(p)
	local v4 = {
		PromptEventTeleport = "The halloween spirit is in the air. Would you like to teleport to where the Trick or Treat event is happening? You can teleport back here after it ends!",
		PromptEventReturn = "The night is coming to an end. Would you like to teleport back to your previous location?"
	}

	if p == "PromptEventTeleport" or p == "PromptEventReturn" then
		local DialogueController = require(game.ReplicatedStorage.DialogueController)

		if DialogueController.Active then
			DialogueController:Close()
		end

		while DialogueController.Active do
			task.wait()
		end

		DialogueController:Start({
			Title = "Event",
			Get = function(_)
				task.spawn(function()
					local total = 0

					while total < 30 and DialogueController.Active do
						total += task.wait()
					end

					if total >= 30 then
						DialogueController:Close()
					end
				end)
				return {
					Text = { v4[p] },
					Option1 = {
						Label = "Teleport",
						JumpTo = function()
							task.delay(1, function()
								halloweenEvent:FireServer(p == "PromptEventReturn" and "AcceptTeleportReturn" or "AcceptEventTeleport")
							end)
							task.spawn(function()
								local total = 0

								while total < 6 and DialogueController.Active do
									total += task.wait()
								end

								if total >= 6 then
									DialogueController:Close()
								end
							end)
							return {
								Text = { "Make sure to stand still while you teleport!" }
							}
						end
					}
				}
			end
		})
	end
end)
workspace.Map.DescendantAdded:Connect(SetupHalloweenDoor)

for _, descendant in ipairs(workspace.Map:GetDescendants()) do
	SetupHalloweenDoor(descendant)
end

local function EnemyAdded(child)
	if child:GetAttribute("LocalEnemy") then
		if child:GetAttribute("LocalEnemy") ~= localPlayer.Name then
			local childAddedConnection = nil
			task.spawn(function()
				task.wait()
				child:ClearAllChildren()
				childAddedConnection = child.ChildAdded:Connect(function(child2)
					task.wait()
					child2:Destroy()
				end)
			end)
			child.AncestryChanged:Once(function()
				if childAddedConnection then
					childAddedConnection:Disconnect()
					childAddedConnection = nil
				end
			end)
		end
	else
		local childAddedConnection = nil
		local localEnemyChangedConnection = nil
		localEnemyChangedConnection = child:GetAttributeChangedSignal("LocalEnemy"):Connect(function()
			if child:GetAttribute("LocalEnemy") and child:GetAttribute("LocalEnemy") ~= localPlayer.Name then
				localEnemyChangedConnection:Disconnect()
				task.wait()
				child:ClearAllChildren()
				childAddedConnection = child.ChildAdded:Connect(function(child2)
					task.wait()
					child2:Destroy()
				end)
			end
		end)
		child.AncestryChanged:Once(function()
			if localEnemyChangedConnection then
				localEnemyChangedConnection:Disconnect()
				localEnemyChangedConnection = nil
			end

			if childAddedConnection then
				childAddedConnection:Disconnect()
				childAddedConnection = nil
			end
		end)
	end
end

local Maid2 = require(game.ReplicatedStorage.Util.Maid)
local maid = Maid2.new()
workspace:GetAttributeChangedSignal("HalloweenEventActive"):Connect(function()
	if workspace:GetAttribute("HalloweenEventActive") then
		maid:DoCleaning()
		return
	end

	for _, descendant in pairs(workspace.Map:GetDescendants()) do
		if not (descendant.Name == "HalloweenDoor" and descendant:FindFirstChild("Proximity")) then
			continue
		end

		descendant.Proximity.ProximityPrompt.Enabled = false
		local v4 = descendant
		maid:GiveTask(descendant.Proximity.ProximityPrompt:GetPropertyChangedSignal("Enabled"):Connect(function()
			if v4.Proximity.ProximityPrompt.Enabled then
				v4.Proximity.ProximityPrompt.Enabled = false
			end
		end))
		local v5 = descendant
		maid:GiveTask(function()
			v5.Proximity.ProximityPrompt.Enabled = true
		end)
	end
end)
workspace:WaitForChild("Enemies").ChildAdded:Connect(EnemyAdded)

for _, child in pairs(workspace.Enemies:GetChildren()) do
	EnemyAdded(child)
end

local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
local v4 = nil

local function ChangeSky(flag2: boolean?)
	local v5 = not workspace:GetAttribute("HalloweenEventActive")
	local sky = game.Lighting:FindFirstChildOfClass("Sky")

	if not flag2 then
		local TweenService = game:GetService("TweenService")
		TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
			{
				TintColor = Color3.fromRGB(255, 149, 88)
			}
		):Play()
		Sound:Play("Halloween_RoomTurnOrange_01", workspace.CurrentCamera.CFrame.Position)
		sky.SkyboxOrientation = createVector(0, 0, 0)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(sky, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			SkyboxOrientation = createVector(0, 720, 0),
			MoonAngularSize = v5 and 11 or 21
		}):Play()
		task.wait(0.75)
	end

	local v6 = {
		"SkyboxBk",
		"SkyboxDn",
		"SkyboxFt",
		"SkyboxLf",
		"SkyboxRt",
		"SkyboxUp",
		"MoonTextureId",
		"SunTextureId"
	}

	if not v4 then
		v4 = {}

		for _, v7 in pairs(v6) do
			v4[v7] = sky[v7]
		end
	end

	local sky2

	if v5 == true then
		sky2 = v4
	else
		sky2 = script.Sky
	end

	for _, v7 in pairs(v6) do
		sky[v7] = sky2[v7]
	end
end

workspace:GetAttributeChangedSignal("HalloweenEventActive"):Connect(ChangeSky)

if workspace:GetAttribute("HalloweenEventActive") then
	ChangeSky(true)
end

local v5

repeat
	task.wait(1)
	local CollectionService = game:GetService("CollectionService")
	v5 = CollectionService:GetTagged("HalloweenPortal")[1]
until v5

local HalloweenPortal = require(game.ReplicatedStorage.DirectorComponents.HalloweenPortal)
HalloweenPortal.new(v5):Init()