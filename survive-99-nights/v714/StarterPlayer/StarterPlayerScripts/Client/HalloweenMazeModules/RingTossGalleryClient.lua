local RingTossGalleryClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local CollectionService = game:GetService("CollectionService")
Random.new()

function IsRingOnPeg(instance, p, _: number)
	local centerPart = instance.CenterPart
	local partsInPart = workspace:GetPartsInPart(centerPart)

	if instance:GetAttribute("OldRing") then
		return false
	end

	for _, v in pairs(partsInPart) do
		v:GetAttribute("LastThrown")

		if v.Name == "CarnivalPeg" and v.Parent == p then
			return true
		end
	end
end

function CheckRings(instance, _: number)
	local pegs = instance.Functional.Pegs
	local tagged = CollectionService:GetTagged("ThrownCarnivalRing")
	local count = 0

	for _, v in pairs(tagged) do
		if not IsRingOnPeg(v, pegs) then
			continue
		end

		count += 1

		if v:GetAttribute("SoundPlayed") then
			continue
		end

		local v2 = v
		task.delay(0.1, function()
			if v2.Parent and not v2:GetAttribute("SoundPlayed") and IsRingOnPeg(v2, pegs) then
				v2:SetAttribute("SoundPlayed", true)
				Client.Sound.Play("Ding", {
					Position = instance:GetPivot().Position
				})
			end
		end)
	end

	print(count)
	local text = string.format("%02i", count)
	instance.Functional.Counter.SurfaceGui.TextLabel.Text = text

	if instance:GetAttribute("RingGoal") <= count and not instance:GetAttribute("GameCompleted") then
		Client.Events.CarnivalCompleteRingToss:FireServer(instance)
		OnGameComplete(instance)
	end
end

function TimerStarted(instance)
	local timerStart = instance:GetAttribute("TimerStart")
	local timerDuration = instance:GetAttribute("TimerDuration")
	local v = workspace:GetServerTimeNow() - time()
	local ticketSign = instance:FindFirstChild("TicketSign", true)

	if ticketSign and ticketSign:FindFirstChild("Sound") then
		ticketSign.Sound:Play()
	end

	while instance:GetAttribute("TimerStart") == timerStart do
		local v2 = math.max(timerDuration - (time() + v - timerStart), 0)
		local v3 = math.floor(v2)
		local v4 = math.round((v2 - v3) * 100)
		local text = string.format("%02i:%02i", v3, v4)
		instance.Functional.Timer.SurfaceGui.TextLabel.Text = text
		CheckRings(instance, timerStart)

		if v2 <= 0 then
			break
		else
			task.wait()
		end
	end

	Client.Sound.Play("BuzzerShort", {
		Position = instance.Functional.Timer:GetPivot().Position
	})

	if ticketSign then
		ticketSign.Sound:Stop()
	end

	if instance:GetAttribute("TimerStart") == timerStart then
		print("resetting")
		instance:SetAttribute("Resetting", true)
		task.delay(1, function()
			instance:SetAttribute("Resetting", nil)
		end)
		local tagged = CollectionService:GetTagged("ThrownCarnivalRing")

		for _, v2 in pairs(tagged) do
			v2:SetAttribute("OldRing", true)
		end
	end
end

function GetRemainingTime(instance)
	local timerStart = instance:GetAttribute("TimerStart")

	if not timerStart then
		return
	end

	local v = workspace:GetServerTimeNow() - timerStart
	return instance:GetAttribute("TimerDuration") - v
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

function LoadRingTossZone(instance)
	instance:WaitForChild("Functional"):WaitForChild("RingTossZone").Touched:Connect(function(otherPart)
		if instance:GetAttribute("Resetting") then
			return
		end

		local parent = otherPart.Parent

		if not (parent:GetAttribute("CarnivalRing") and parent:GetAttribute("LastThrown")) then
			return
		end

		local v = GetRemainingTime(instance)
		print(v)

		if v == nil or v <= 0 then
			local serverTimeNow = workspace:GetServerTimeNow()
			instance:SetAttribute("TimerStart", serverTimeNow)
			Client.Events.CarnivalRingTossStart:FireServer(instance, serverTimeNow)
		end
	end)
end

function RingTossGalleryAdded(instance)
	LoadRingTossZone(instance)
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

function RingTossGalleryClient.Init()
	Client.Utility.ForAllTagged("MazeRingToss", RingTossGalleryAdded)
end

return RingTossGalleryClient