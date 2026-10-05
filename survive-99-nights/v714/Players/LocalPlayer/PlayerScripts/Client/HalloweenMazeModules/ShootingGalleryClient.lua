local ShootingGalleryClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local random = Random.new()
local v = {}

function ResetGallery(instance)
	instance:SetAttribute("Resetting", true)
	instance:SetAttribute("TimerRunning", nil)
	local plates = instance:WaitForChild("Functional"):WaitForChild("Plates")

	for _, child in pairs(plates:GetChildren()) do
		local plate = child:FindFirstChild("Plate")

		if plate then
			ResetPlate(plate)
		end
	end

	task.delay(1, function()
		instance:SetAttribute("Resetting", nil)
	end)
end

function ShootingGalleryClient.ResetGallery(instance)
	if instance:GetAttribute("Resetting") then
		return
	end

	Client.Sound.Play("Lever", {
		Position = instance:GetPivot().Position,
		Replicate = true
	})
	Client.Events.CarnivalRequestResetShootingGallery:FireServer(instance)
	ResetGallery(instance)
end

Client.Events.CarnivalResetShootingGallery:Connect(function(p)
	ResetGallery(p)
end)

function TimerStarted(instance)
	if instance:GetAttribute("TimerRunning") then
		return
	end

	instance:SetAttribute("TimerRunning", true)
	local timerStart = instance:GetAttribute("TimerStart")
	local timerDuration = instance:GetAttribute("TimerDuration")
	local v2 = workspace:GetServerTimeNow() - time()
	local ticketSign = instance:FindFirstChild("TicketSign", true)

	if ticketSign and ticketSign:FindFirstChild("Sound") then
		ticketSign.Sound:Play()
	end

	while instance:GetAttribute("TimerRunning") do
		local v3 = math.max(timerDuration - (time() + v2 - timerStart), 0)
		local v4 = math.floor(v3)
		local v5 = math.round((v3 - v4) * 100)
		local text = string.format("%02i:%02i", v4, v5)
		instance.Functional.Timer.SurfaceGui.TextLabel.Text = text

		if ticketSign then
			ticketSign.Sound:Stop()
		end

		if v3 <= 0 then
			break
		else
			task.wait()
		end
	end

	if instance:GetAttribute("GameCompleted") == nil then
		Client.Sound.Play("BuzzerShort", {
			Position = instance.Functional.Timer:GetPivot().Position
		})
	end
end

function GetRemainingTime(instance)
	if not instance:GetAttribute("TimerRunning") then
		return
	end

	local timerStart = instance:GetAttribute("TimerStart")

	if not timerStart then
		return
	end

	local v2 = workspace:GetServerTimeNow() - timerStart
	return instance:GetAttribute("TimerDuration") - v2
end

function OnGameComplete(instance)
	if instance:GetAttribute("LocalGameCompleted") then
		return
	end

	instance:SetAttribute("LocalGameCompleted", true)
	instance:SetAttribute("GameCompleted", true)
	Client.Sound.Play("CarnivalWin", {
		Position = instance:GetPivot().Position
	})
end

function CheckPlatesDown(instance)
	if instance:GetAttribute("GameCompleted") or not instance:HasTag("MazeShootingGallery") then
		return
	end

	local v2 = GetRemainingTime(instance)

	if v2 == nil or v2 <= 0 then
		return
	end

	local children = instance:WaitForChild("Functional"):WaitForChild("Plates"):GetChildren()
	local flag = true

	for _, v4 in pairs(children) do
		if v4.Plate:GetAttribute("KnockedDown") then
			continue
		end

		flag = false
		break
	end

	if flag then
		Client.Events.CarnivalCompleteShootingGallery:FireServer(instance)
		OnGameComplete(instance)
	end
end

function KnockDownPlate(instance)
	if instance:GetAttribute("KnockedDown") then
		return
	end

	instance:SetAttribute("KnockedDown", true)
	Client.TweenModule.new(function(p)
		instance:SetAttribute("Angle", -90 * p)
	end, 0.05):Play()
	Client.Sound.Play("BulletHitTarget", {
		Position = instance:GetPivot().Position
	})
	local parent = instance.Parent.Parent.Parent.Parent
	CheckPlatesDown(parent)
end

function ShootingGalleryClient.KnockDownPlate(p)
	local parent = p.Parent.Parent.Parent.Parent

	if parent:GetAttribute("Resetting") then
		return
	end

	KnockDownPlate(p)
	local serverTimeNow

	if parent:GetAttribute("TimerStart") == nil then
		serverTimeNow = workspace:GetServerTimeNow()
		parent:SetAttribute("TimerStart", serverTimeNow)
	end

	Client.Events.CarnivalShootPlate:FireServer(p, serverTimeNow)
end

Client.Events.CarnivalKnockDownPlate:Connect(function(p)
	KnockDownPlate(p)
end)

function ResetPlate(instance)
	if instance:GetAttribute("KnockedDown") == nil then
		return
	end

	Client.TweenModule.new(function(p)
		instance:SetAttribute("Angle", -90 * (1 - p))
	end, 1):Play()
	task.delay(1, function()
		instance:SetAttribute("KnockedDown", nil)
	end)
end

function AnimatePlate(instance)
	local flag = false
	local total = 0
	local v2 = 0.3 + 0.2 * random:NextNumber()
	local pivot = instance:GetPivot()
	local position2 = instance.Parent:WaitForChild("Position2")
	local pivot2 = position2:GetPivot()
	position2:Destroy()

	local function checkAnimatePlate()
		if instance:GetAttribute("KnockedDown") or flag then
			return
		end

		flag = true

		while true do
			local lerped = pivot:Lerp(pivot2, (math.sin(total * 2 * 3.141592653589793 * v2) + 1) / 2)
			local angle = instance:GetAttribute("Angle") or 0
			instance:PivotTo(lerped * CFrame.Angles(math.rad(angle), 0, 0))
			local v5 = task.wait()

			if instance:GetAttribute("KnockedDown") == nil then
				total += v5
			end
		end
	end

	instance:GetAttributeChangedSignal("KnockedDown"):Connect(checkAnimatePlate)
	checkAnimatePlate()
end

function ShootingGalleryAdded(instance)
	if v[instance] then
		return
	end

	v[instance] = true
	local plates = instance:WaitForChild("Functional"):WaitForChild("Plates")

	for _, child in pairs(plates:GetChildren()) do
		local plate = child:FindFirstChild("Plate")

		if not plate then
			continue
		end

		local v2 = plate
		task.spawn(function()
			AnimatePlate(v2)
		end)
	end

	instance:GetAttributeChangedSignal("TimerStart"):Connect(function()
		if instance:GetAttribute("TimerStart") then
			TimerStarted(instance)
		end
	end)
	instance:GetAttributeChangedSignal("GameCompleted"):Connect(function()
		if instance:GetAttribute("GameCompleted") then
			OnGameComplete(instance)
		end
	end)
end

function ShootingGalleryClient.Init()
	Client.Utility.ForAllTagged("MazeShootingGallery", ShootingGalleryAdded)
end

return ShootingGalleryClient