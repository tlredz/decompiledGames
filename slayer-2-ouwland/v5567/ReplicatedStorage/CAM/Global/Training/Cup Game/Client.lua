local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local faye = require(ReplicatedStorage.Packages.faye)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Camera_Traffic_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Camera_Traffic_Handler)
local CupGameUI = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.Training.CupGameUI)
local PlatformLeniency = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.PlatformLeniency)
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local currentCamera = workspace.CurrentCamera
local sounds = script.Parent:WaitForChild("Sounds")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 255, 255)
local alwaysOnTop = Enum.HighlightDepthMode.AlwaysOnTop
local cframe = CFrame.Angles(3.141592653589793, 0, 0)
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
local tweenInfo3 = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
local maid = nil
local track = nil
local v = nil
local count = 0
local v2 = nil

local function partOf(instance)
	if instance:IsA("BasePart") then
		return instance
	end

	return instance:IsA("Model") and instance.PrimaryPart or nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTransparency(primaryPart, transparency: number)
	if not primaryPart:IsA("BasePart") then
		primaryPart = primaryPart:IsA("Model") and primaryPart.PrimaryPart or nil
	end

	if primaryPart then
		primaryPart.Transparency = transparency
	end
end

local function playSound(childName: string, primaryPart)
	local child = sounds:FindFirstChild(childName)

	if not child then
		return
	end

	local clone = child:Clone()

	if primaryPart then
		if not primaryPart:IsA("BasePart") then
			primaryPart = primaryPart:IsA("Model") and primaryPart.PrimaryPart or nil
		end

		if not primaryPart then
			primaryPart = sounds
		end
	else
		primaryPart = sounds
	end

	clone.Parent = primaryPart
	clone:Play()
	DebrisModule:AddItem(clone, clone.TimeLength + 1)
end

local cupGameHomes = {}
local v3 = {}
local tweens = {}

local function moveTo(part, tweenInfo5, cframe2: CFrame)
	if not part:IsA("BasePart") then
		part:PivotTo(cframe2)
		return
	end

	local tween = TweenService:Create(part, tweenInfo5, {
		CFrame = cframe2
	})
	table.insert(tweens, tween)
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelTweens()
	for _, v4 in tweens do
		v4:Cancel()
	end

	table.clear(tweens)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapTo(part, cFrame: CFrame)
	if part:IsA("BasePart") then
		part.CFrame = cFrame
	else
		part:PivotTo(cFrame)
	end
end

local function teardown()
	local v4 = maid
	local v5 = track
	local v6 = v2
	local v7 = v
	maid = nil
	track = nil
	v2 = nil
	v = nil
	count += 1
	RunService:UnbindFromRenderStep("cupgame_cam")

	if Camera_Traffic_Handler.CupGame then
		Camera_Traffic_Handler.CupGame = false
	end

	cancelTweens() -- equivalent call inferred; original call site unknown

	if v7 then
		v7()
	end

	if v5 then
		v5:Stop(0.3)
	end

	if v4 then
		v4:Destroy()
	end

	task.defer(function()
		if not v6 then
			return
		end

		for _, cup in v6.cups do
			snapTo(cup, cupGameHomes[cup]) -- equivalent call inferred; original call site unknown
		end

		local v8 = v6.ball and v3[v6.ball]

		if v8 then
			snapTo(v6.ball, v8.cf) -- equivalent call inferred; original call site unknown
			local ball2 = v6.ball
			local transparency = v8.transparency

			if not ball2:IsA("BasePart") then
				ball2 = ball2:IsA("Model") and ball2.PrimaryPart or nil
			end

			if ball2 then
				ball2.Transparency = transparency
			end
		end
	end)
end

local CupGame = {}

function CupGame.Do(p, instance, _, p2)
	teardown()
	count += 1
	local v4 = count
	maid = faye.new()
	maid:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still"))
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay"))
	maid:Add(Utility.AddValue(getvaluesfolder, "NR"))
	track = instance.Humanoid.Animator:LoadAnimation(script["Cup Game"])
	track:Play()

	if not p2 then
		return
	end

	local parent = p2.Parent
	local parent2 = parent and parent.Parent

	if not parent2 then
		return
	end

	local camera = parent2:FindFirstChild("Camera")
	local cups = parent2:FindFirstChild("Cups")

	if not (camera and cups) then
		return
	end

	local ball = cups:FindFirstChild("Ball")
	local parts = {}

	for _, part in cups:GetChildren() do
		if part:IsA("BasePart") and part.Name:match("^Cup%d+$") then
			table.insert(parts, part)
		end
	end

	if #parts < 3 or not ball then
		return
	end

	local rightVector = camera.CFrame.RightVector
	local position = camera.Position
	table.sort(parts, function(a, b)
		return (a.Position - position):Dot(rightVector) < (b.Position - position):Dot(rightVector)
	end)

	for _, v5 in parts do
		if cupGameHomes[v5] ~= nil then
			continue
		end

		local cupGameHome = v5:GetAttribute("CupGameHome")

		if typeof(cupGameHome) ~= "CFrame" then
			cupGameHome = v5.CFrame
			v5:SetAttribute("CupGameHome", cupGameHome)
		end

		cupGameHomes[v5] = cupGameHome
	end

	local slots = { cupGameHomes[parts[1]], cupGameHomes[parts[2]], cupGameHomes[parts[3]] }

	if v3[ball] == nil then
		local cupGameBallHome = ball:GetAttribute("CupGameBallHome")
		local cupGameBallTransparency = ball:GetAttribute("CupGameBallTransparency")

		if typeof(cupGameBallHome) ~= "CFrame" then
			local primaryPart

			if ball:IsA("BasePart") then
				primaryPart = ball
			elseif ball:IsA("Model") then
				primaryPart = ball.PrimaryPart or nil
			end

			cupGameBallHome = ball:GetPivot()
			cupGameBallTransparency = primaryPart and primaryPart.Transparency or 0
			ball:SetAttribute("CupGameBallHome", cupGameBallHome)
			ball:SetAttribute("CupGameBallTransparency", cupGameBallTransparency)
		end

		v3[ball] = {
			cf = cupGameBallHome,
			transparency = cupGameBallTransparency
		}
	end

	local cf = v3[ball].cf
	v2 = {
		model = parent2,
		cameraPart = camera,
		ball = ball,
		cups = parts,
		slots = slots,
		slotCups = { parts[1], parts[2], parts[3] },
		ballHomeCF = cf
	}
	local primaryPart

	if ball:IsA("BasePart") then
		primaryPart = ball
	elseif ball:IsA("Model") then
		primaryPart = ball.PrimaryPart or nil
	end

	if primaryPart then
		primaryPart.Transparency = 0
	end

	snapTo(ball, cf) -- equivalent call inferred; original call site unknown
	Camera_Traffic_Handler.CupGame = true
	RunService:BindToRenderStep("cupgame_cam", Enum.RenderPriority.Camera.Value, function()
		if Camera_Traffic_Handler.Equipped_Hirearchy == "CupGame" then
			currentCamera.CFrame = camera.CFrame
		end
	end)
	local flag = false

	local function stop(flag2: boolean)
		if flag then
			return
		end

		flag = true
		SignalEvent.ToServer("training_signaler", "Stop", flag2 == true)
	end

	local v6, v7, v8, v9, v10 = CupGameUI(p.PlayerGui:WaitForChild("Misc"), stop)
	v = v6
	local v14 = v8
	maid:Spawn(function()
		local function guard()
			return v4 ~= count
		end

		local function arcMove(slotCup, cframe2: CFrame, cFrame: CFrame, p3: number, p4: number)
			local position2 = cframe2.Position
			local position3 = cFrame.Position
			local v15 = (position2 + position3) / 2 + Vector3.new(0, p3, 0)
			local v16 = 0

			while v16 < p4 do
				local v17 = RunService.Heartbeat:Wait()

				if v4 ~= count then
					return
				end

				v16 = math.min(v16 + v17, p4)
				local value = TweenService:GetValue(v16 / p4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				local v18 = 1 - value
				local v19 = v18 * v18 * position2 + 2 * v18 * value * v15 + value * value * position3
				snapTo(slotCup, CFrame.new(v19) * cframe2:Lerp(cFrame, value).Rotation) -- equivalent call inferred; original call site unknown
			end

			snapTo(slotCup, cFrame) -- equivalent call inferred; original call site unknown
		end

		local function ballOnTable(index: number)
			local primaryPart2 = v2.slotCups[index]

			if not primaryPart2:IsA("BasePart") then
				primaryPart2 = primaryPart2:IsA("Model") and primaryPart2.PrimaryPart or nil
			end

			local ball2 = v2.ball

			if not ball2:IsA("BasePart") then
				ball2 = ball2:IsA("Model") and ball2.PrimaryPart or nil
			end

			local v15 = primaryPart2 and primaryPart2.Size.Y / 2 or 0
			local v16 = ball2 and ball2.Size.Y / 2 or 0
			return CFrame.new(slots[index].Position + Vector3.new(0, v16 - v15, 0))
		end

		local function ballInCup(p3: number)
			local primaryPart2 = v2.slotCups[p3]

			if not primaryPart2:IsA("BasePart") then
				primaryPart2 = primaryPart2:IsA("Model") and primaryPart2.PrimaryPart or nil
			end

			return CFrame.new(primaryPart2 and primaryPart2.Position or slots[p3].Position)
		end

		local function toStart()
			for i = 1, 3 do
				v2.slotCups[i] = parts[i]
				moveTo(parts[i], tweenInfo4, slots[i] + createVector(0, 0.3, 0))
			end

			setTransparency(ball, 0) -- equivalent call inferred; original call site unknown
			moveTo(ball, tweenInfo4, cf)
		end

		local function runSequence(p3: number)
			toStart()
			task.wait(0.4)

			if v4 ~= count then
				return false
			end

			moveTo(ball, tweenInfo, ballInCup(2))
			playSound("PS2trainingCUPSplaceball", ball)
			task.wait(0.4)

			if v4 ~= count then
				return false
			end

			setTransparency(ball, 1) -- equivalent call inferred; original call site unknown
			local slotCup = v2.slotCups[2]
			moveTo(v2.slotCups[1], tweenInfo2, slots[1] * cframe)
			moveTo(v2.slotCups[2], tweenInfo2, slots[2] * cframe)
			moveTo(v2.slotCups[3], tweenInfo2, slots[3] * cframe)
			playSound("PS2trainingCUPSflip1", v2.slotCups[2])
			task.wait(0.3)

			if v4 ~= count then
				return false
			end

			local v15 = math.max(0, 1 - (p3 - 1) * 0.07)
			local platformLeniency = PlatformLeniency()
			local v17 = math.max(0.15, v15 * 0.45) * platformLeniency
			local v18 = math.max(0.03, v15 * 0.15) * platformLeniency
			local tweenInfo5 = TweenInfo.new(v17, Enum.EasingStyle.Quad)

			for _ = 1, math.min(12, (math.round(2 ^ (p3 - 1) * 4))) do
				local v19 = math.random(1, 2) == 1 and 1 or 3
				local v20

				if math.random(1, 2) == 1 then
					v20 = v19
					v19 = 2
				else
					v20 = 2
				end

				local slotCup2 = v2.slotCups[v20]
				local slotCup3 = v2.slotCups[v19]
				local slotCups = v2.slotCups
				local slotCups2 = v2.slotCups
				slotCups[v20] = slotCup3
				slotCups2[v19] = slotCup2
				playSound("PS2trainingCUPSslide", slotCup3)
				moveTo(slotCup3, tweenInfo5, slots[v20] * cframe)
				arcMove(slotCup2, slots[v20] * cframe, slots[v19] * cframe, 3.5, v17)

				if v4 ~= count then
					return false
				end

				local index = table.find(v2.slotCups, slotCup)

				if index then
					local primaryPart2 = v2.slotCups[index]

					if not primaryPart2:IsA("BasePart") then
						primaryPart2 = primaryPart2:IsA("Model") and primaryPart2.PrimaryPart or nil
					end

					snapTo(ball, CFrame.new(primaryPart2 and primaryPart2.Position or slots[index].Position)) -- equivalent call inferred; original call site unknown
				end

				task.wait(v18)

				if v4 ~= count then
					return false
				end
			end

			local maid2 = maid:Extend()
			local v19 = maid2:Add(Instance.new("BindableEvent"))
			local v20 = nil

			for i = 1, 3 do
				local slotCup2 = v2.slotCups[i]
				local clickDetector = Instance.new("ClickDetector")
				clickDetector.MaxActivationDistance = 1000
				clickDetector.Parent = slotCup2
				maid2:Add(clickDetector)
				local highlight = Instance.new("Highlight")
				highlight.Adornee = slotCup2
				highlight.FillColor = color
				highlight.OutlineColor = color2
				highlight.FillTransparency = 0.6
				highlight.OutlineTransparency = 0
				highlight.DepthMode = alwaysOnTop
				highlight.Enabled = false
				highlight.Parent = slotCup2
				maid2:Add(highlight)
				maid2:Connect(clickDetector.MouseHoverEnter, function()
					highlight.Enabled = true
				end)
				local v22 = highlight
				maid2:Connect(clickDetector.MouseHoverLeave, function()
					v22.Enabled = false
				end)
				maid2:Connect(clickDetector.MouseClick, function()
					if v20 == nil then
						v20 = slotCup2
						playSound("PS2trainingCUPSlift", slotCup2)
						v19:Fire()
					end
				end)
			end

			v19.Event:Wait()
			maid2:Destroy()

			if v4 ~= count then
				return false
			end

			local index = table.find(v2.slotCups, v20)

			if index then
				moveTo(v20, tweenInfo3, slots[index] * cframe + createVector(0, 2.5, 0))
			end

			if v20 ~= slotCup then
				task.wait(0.35)
				return false
			end

			local index2 = table.find(v2.slotCups, slotCup)
			setTransparency(ball, 0) -- equivalent call inferred; original call site unknown

			if index2 then
				snapTo(ball, ballOnTable(index2)) -- equivalent call inferred; original call site unknown
			end

			task.wait(0.8)
			return true
		end

		local v15 = 1
		local count2 = 0

		while v4 == count do
			local v16 = runSequence(v15)

			if v4 ~= count then
				break
			end

			if v16 then
				count2 += 1
				v9:Set(count2)
				v15 += 1

				if v10 <= count2 then
					if flag then
						break
					end

					flag = true
					SignalEvent.ToServer("training_signaler", "Stop", true)
					break
				end
			else
				if v14 > 0 then
					v7[v14]:Set(false)
					v14 -= 1
				end

				if v14 <= 0 then
					if flag then
						break
					end

					flag = true
					SignalEvent.ToServer("training_signaler", "Stop", false)
					break
				end
			end
		end
	end)
end

function CupGame:Stop(_, _)
	teardown()
end

return CupGame