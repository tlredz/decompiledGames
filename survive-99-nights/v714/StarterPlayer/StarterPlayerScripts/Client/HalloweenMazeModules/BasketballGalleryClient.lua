local BasketballGalleryClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local CollectionService = game:GetService("CollectionService")
Random.new()
local v = {}

function TimerStarted(instance)
	if instance:GetAttribute("TimerRunning") then
		return
	end

	instance:SetAttribute("TimerRunning", true)
	instance:SetAttribute("NumberHoops", 0)
	local timerStart = instance:GetAttribute("TimerStart")
	local timerDuration = instance:GetAttribute("TimerDuration")
	local v2 = workspace:GetServerTimeNow() - time()
	local ticketSign = instance:FindFirstChild("TicketSign", true)

	if ticketSign and ticketSign:FindFirstChild("Sound") then
		ticketSign.Sound:Play()
	end

	task.spawn(function()
		while instance:GetAttribute("TimerRunning") do
			local v3 = time() + v2 - timerStart
			local v4 = math.max(timerDuration - v3, 0)
			local v5 = math.floor(v4)
			local v6 = math.round((v4 - v5) * 100)
			local text = string.format("%02i:%02i", v5, v6)
			instance.Functional.Timer.SurfaceGui.TextLabel.Text = text

			if v4 <= 0 then
				break
			else
				task.wait()
			end
		end

		if ticketSign and ticketSign:FindFirstChild("Sound") then
			ticketSign.Sound:Stop()
		end

		Client.Sound.Play("BuzzerShort", {
			Position = instance.Functional.Timer:GetPivot().Position
		})
		instance:SetAttribute("Resetting", true)
		instance:SetAttribute("TimerRunning", nil)
		task.delay(0.5, function()
			instance:SetAttribute("Resetting", nil)
		end)
	end)
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

function BallInHoop(instance)
	if instance:GetAttribute("Resetting") then
		return
	end

	local v2 = GetRemainingTime(instance)
	local serverTimeNow

	if v2 == nil or v2 <= 0 then
		serverTimeNow = workspace:GetServerTimeNow()
		instance:SetAttribute("TimerStart", serverTimeNow)
		TimerStarted(instance)
	end

	print("got ball in hoop")
	Client.Sound.Play("BasketballHoop", {
		Position = instance:GetPivot().Position
	})
	local v3 = (instance:GetAttribute("NumberHoops") or 0) + 1
	instance:SetAttribute("NumberHoops", v3)
	Client.Sound.Play("Ding", {
		Position = instance:GetPivot().Position
	})
	Client.Events.CarnivalBasketballHoop:FireServer(instance, serverTimeNow)

	if (instance:GetAttribute("HoopGoal") or 3) <= v3 and not instance:GetAttribute("GameCompleted") then
		Client.Events.CarnivalCompleteBasketballGallery:FireServer(instance)
		OnGameComplete(instance)
	end
end

function LoadHoop(instance)
	local touchZones = instance:WaitForChild("Functional"):WaitForChild("TouchZones")
	local v2 = {}

	for _, child in pairs(touchZones:GetChildren()) do
		local v4 = tonumber((string.sub(child.Name, 6, 6)))
		local v5 = child
		table.insert(v[instance], child.Touched:Connect(function(otherPart)
			if instance:GetAttribute("Resetting") then
				return
			end

			local parent = otherPart.Parent

			if parent:GetAttribute("Owner") ~= localPlayer.UserId and parent:GetAttribute("LastOwner") ~= localPlayer.UserId then
				return
			end

			if parent:GetAttribute("CarnivalBall") then
				if v2[parent] == nil then
					v2[parent] = {}
				end

				if v4 == 3 then
					local v6 = v2[parent][1] or 0
					local v7 = v2[parent][2] or 0
					local v8 = v2[parent][3] or 0
					local v9 = time()

					if v9 - v6 < 0.3 and v9 - v7 < 0.3 and v9 - v8 > 1 then
						BallInHoop(instance)
						v2[parent][3] = v9
						v5.BrickColor = BrickColor.new("Sea green")
						task.delay(0.3, function()
							v5.BrickColor = BrickColor.new("Really red")
						end)
					end
				else
					v2[parent][v4] = time()
					v5.BrickColor = BrickColor.new("Sea green")
					task.delay(0.3, function()
						v5.BrickColor = BrickColor.new("Really red")
					end)
				end
			end
		end))
	end

	table.insert(v[instance], CollectionService:GetInstanceRemovedSignal("CarnivalBall"):Connect(function(p)
		v2[p] = nil
	end))
	task.spawn(function()
		local counter = instance:WaitForChild("Functional"):WaitForChild("Counter")
		table.insert(v[instance], instance:GetAttributeChangedSignal("NumberHoops"):Connect(function()
			local numberHoops = instance:GetAttribute("NumberHoops") or 0
			local text = string.format("%02i", numberHoops)
			counter.SurfaceGui.TextLabel.Text = text
		end))
	end)
end

function UnloadBasketballGallery(p)
	if v[p] then
		for _, connection in pairs(v[p]) do
			connection:Disconnect()
		end

		v[p] = nil
	end
end

function BasketballGalleryAdded(instance)
	if v[instance] == nil then
		v[instance] = {}
	end

	LoadHoop(instance)
	table.insert(v[instance], instance:GetAttributeChangedSignal("TimerStart"):Connect(function()
		if instance:GetAttribute("TimerStart") then
			TimerStarted(instance)
		end
	end))
	table.insert(v[instance], instance:GetAttributeChangedSignal("GameCompleted"):Connect(function()
		if instance:GetAttribute("GameCompleted") then
			OnGameComplete(instance)
		end
	end))
end

function BasketballGalleryClient.Init()
	Client.Utility.ForAllTagged("MazeBasketballGallery", BasketballGalleryAdded, UnloadBasketballGallery)
	Client.Events.AddBasketballHoopScore:Connect(function(instance)
		instance:SetAttribute("NumberHoops", (instance:GetAttribute("NumberHoops") or 0) + 1)
		Client.Sound.Play("Ding", {
			Position = instance:GetPivot().Position
		})
	end)
end

return BasketballGalleryClient