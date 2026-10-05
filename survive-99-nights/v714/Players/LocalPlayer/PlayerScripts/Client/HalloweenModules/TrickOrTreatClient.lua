local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()

function DoorKnockAnimation(p)
	Client.Sound.Play("HalloweenKnock")
	task.spawn(function()
		for _ = 1, 3 do
			p.Blocker.Particle:Emit(1)
			wait(0.15)
		end
	end)
end

function SwingOpenDoor(p)
	local origin = p.Door:GetAttribute("Origin")

	if origin == nil then
		origin = p.Door:GetPivot()
		p.Door:SetAttribute("Origin", origin)
	end

	Client.Sound.Play("DoorToggle", {
		Duplicate = true
	})
	Client.TweenModule.new(function(p2)
		p.Door:PivotTo(origin * CFrame.Angles(math.rad(-110 * p2), 0, 0))
	end, 0.6, "Quint"):Play()
end

function SwingClosedDoor(p)
	local origin = p.Door:GetAttribute("Origin")
	local tweenModule = Client.TweenModule.new(function(p2)
		p.Door:PivotTo(origin * CFrame.Angles(math.rad(-110 * (1 - p2)), 0, 0))
	end, 0.3, "Linear")
	Client.Sound.Play("DoorToggle", {
		Duplicate = true
	})
	tweenModule:Play()
end

function RunAnimationOnCharacter(instance, p)
	if instance and (instance:FindFirstChild("NPC") or instance:FindFirstChild("Humanoid")) then
		local NPC = instance:FindFirstChild("NPC") or instance:FindFirstChild("Humanoid")
		local animation = Instance.new("Animation")
		animation.AnimationId = p == "Treat" and "rbxassetid://129423030" or "rbxassetid://129423131"
		NPC.Animator:LoadAnimation(animation):Play()
	elseif not instance then
		print("CHARACTER IS NOT FOUND")
	end
end

function GetChar(instance)
	for _, child in pairs(instance:GetChildren()) do
		if child:FindFirstChild("NPC") or child:FindFirstChild("Humanoid") then
			return child
		end
	end

	return nil
end

function MakeTrickOrTreatBillboard(instance, p)
	if not (instance and instance:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local clone = ReplicatedStorage.Assets.Billboards.TrickOrTreat:Clone()
	clone.Parent = instance.HumanoidRootPart.RootAttachment
	local frame = clone.Frame
	local imageLabel = frame.ImageLabel
	local textLabel = frame.TextLabel
	imageLabel.Image = p == "Trick" and "rbxassetid://85237310999369" or "rbxassetid://88750413075396"
	textLabel.Text = p == "Trick" and "TRICK" or "TREAT"
	frame.Visible = true
	frame.Size = UDim2.new(0, 0, 0, 0)
	imageLabel.ImageTransparency = 1
	textLabel.TextTransparency = 1
	local lastTime = tick()
	local renderSteppedConnection = nil
	local RunService = game:GetService("RunService")
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v = tick() - lastTime

		if v < 0.3 then
			local v2 = v / 0.3
			local v3 = v2 < 0.5 and v2 * 2.2 or 1 + (1 - v2) * 0.2
			frame.Size = UDim2.new(v3, 0, v3, 0)
			imageLabel.ImageTransparency = 1 - v2
			textLabel.TextTransparency = 1 - v2
		elseif v < 4.5 then
			frame.Size = UDim2.new(1, 0, 1, 0)
			local v2 = math.sin((v - 0.3) * 3) * 0.02
			imageLabel.Position = UDim2.new(0.5, 0, v2 + 0.368, 0)
			textLabel.Position = UDim2.new(0.5, 0, v2 + 0.593, 0)
			imageLabel.ImageTransparency = 0
			textLabel.TextTransparency = 0
		elseif v < 5 then
			local v2 = (v - 4.5) / 0.5
			imageLabel.ImageTransparency = v2
			textLabel.TextTransparency = v2
			local v3 = 1 - v2 * 0.2
			frame.Size = UDim2.new(v3, 0, v3, 0)
		else
			renderSteppedConnection:Disconnect()
			clone:Destroy()
		end
	end)
end

function MakeQuestionBillboard(instance, value)
	local v = value or 10

	if not (instance and instance:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local clone = ReplicatedStorage.Assets.Billboards.TrickOrTreat:Clone()
	clone.Parent = instance.HumanoidRootPart.RootAttachment
	local questionMark = clone.QuestionMark
	local v2 = { 0.25, 0.5, 0.75 }
	local v3 = { 0.8, 1, 1.2 }
	local v4 = {}

	for i = 1, 3 do
		local clone2 = questionMark:Clone()
		clone2.Name = "QuestionMark" .. i
		clone2.Parent = clone
		clone2.Visible = true
		clone2.AnchorPoint = Vector2.new(0.5, 0.5)
		clone2.Position = UDim2.new(v2[i], 0, 0.5, 0)
		clone2.Size = UDim2.new(0.253 * v3[i], 0, 0.45 * v3[i], 0)
		table.insert(v4, {
			gui = clone2,
			baseY = 0.5,
			offset = (i - 1) * 2.0943951023931953
		})
	end

	local lastTime = tick()
	local renderSteppedConnection = nil
	local RunService = game:GetService("RunService")
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v5 = tick() - lastTime

		if v <= v5 then
			renderSteppedConnection:Disconnect()
			clone:Destroy()
		else
			for _, v6 in ipairs(v4) do
				local gui = v6.gui
				local v7 = math.sin(v5 * 2 + v6.offset) * 0.05
				gui.Position = UDim2.new(gui.Position.X.Scale, 0, v6.baseY + v7, 0)
				gui.ImageTransparency = 1 - (math.sin(v5 * 1.5 + v6.offset) * 0.3 + 0.7)
			end
		end
	end)
end

function TempFreezeCharacter(_) end

function RunCutscene(p)
	local flag = true
	local parent = p.Parent
	task.spawn(function()
		while flag do
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			workspace.CurrentCamera.CFrame = parent.CameraPart.CFrame
			workspace.CurrentCamera.FieldOfView = 40
			task.wait()
		end

		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		workspace.CurrentCamera.FieldOfView = 70
	end)
	localPlayer.Character:PivotTo(parent.PlayerPart.CFrame)
	Client.Events.TrickOrTreatCutsceneStarted:FireServer(parent.Parent)
	TempFreezeCharacter(10)
	local trickOrTreat = "Trick"
	local v = GetChar(parent)
	local humanoid = v:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	local track = animator:LoadAnimation(v.Animations.OpenDoor)
	task.spawn(function()
		task.wait(1.5)

		if not flag then
			return
		end

		track:Play()
		task.wait(5.1)

		if not flag then
			return
		end

		local track2 = animator:LoadAnimation(v.Animations[trickOrTreat])
		task.wait(1)

		if not flag then
			return
		end

		track2:Play()
	end)
	task.wait(0.5)
	DoorKnockAnimation(p)
	task.wait(1)
	SwingOpenDoor(p)
	task.wait(2)
	Client.Sound.Play("PizzaPlaceHmm")
	task.spawn(function()
		task.wait(0.5)

		if not flag then
			return
		end

		MakeQuestionBillboard(v, 4.4)
		wait(3.9000000000000004)

		if not (flag and v) then
			return
		end

		if trickOrTreat == "Trick" then
			Client.Sound.Play("HalloweenTrick")
		else
			Client.Sound.Play("HalloweenTreat")
		end

		MakeTrickOrTreatBillboard(v, trickOrTreat)
	end)
	local v2 = localPlayer:GetAttribute("Class") == "Trick or Treater" and 4 or 3
	local v3 = Client.Events.RequestKnockOnDoor:InvokeServer(p)

	if v3 and v3.Success then
		print(v3)
		trickOrTreat = v3.TrickOrTreat

		if v3.AddCandy then
			v2 += 1
		end

		task.wait(4.5)

		if not flag then
			return
		end

		wait(2.25)

		if not flag then
			return
		end

		flag = false
		task.wait(0.55)

		for _ = 1, v2 do
			parent.Character:GetPivot()
			task.wait(0.2)
		end

		task.wait(1.8)
		SwingClosedDoor(p)
	else
		SwingClosedDoor(p)
		flag = false
		track:Stop()
	end
end

function KnockOnDoor(instance)
	local DELAY_DURATION = 2
	local parent = instance.Parent.Parent
	local proximityInteraction = instance.PrimaryPart.ProximityAttachment.ProximityInteraction
	proximityInteraction.Enabled = false

	if parent:GetAttribute("Activated") then
		if parent:GetAttribute("AlwaysActivated") == nil and workspace:GetAttribute("State") ~= "Night" then
			Client.PopUpUI.AddPopUp("you need to come back at night!", "orange")
			task.delay(DELAY_DURATION, function()
				proximityInteraction.Enabled = true
			end)
		elseif parent:GetAttribute("Visited_" .. localPlayer.UserId) then
			if parent:GetAttribute("AlwaysActivated") then
				Client.PopUpUI.AddPopUp("you have already visited this house!", "orange")
			else
				Client.PopUpUI.AddPopUp("you have already visited this house! wait for it to reset", "orange")
			end

			task.delay(DELAY_DURATION, function()
				proximityInteraction.Enabled = true
			end)
		else
			RunCutscene(instance)
			task.delay(DELAY_DURATION, function()
				proximityInteraction.Enabled = true
			end)
		end
	else
		DoorKnockAnimation(instance)
		task.wait(1.6)
		Client.PopUpUI.AddPopUp("you need to light this house with a candle first!", "orange")
		task.delay(DELAY_DURATION, function()
			proximityInteraction.Enabled = true
		end)
	end
end

local TrickOrTreatClient = {
	KnockOnDoor = KnockOnDoor
}

function LoadModules()
	for _, moduleScript in pairs(script.Modules:GetChildren()) do
		local module = require(moduleScript)

		if not module.Init then
			continue
		end

		local v = module
		task.spawn(function()
			v.Init()
		end)
	end
end

function TrickOrTreatClient.Init()
	task.spawn(function()
		LoadModules()
	end)
end

return TrickOrTreatClient