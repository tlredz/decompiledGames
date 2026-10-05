local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local v = false
local v2 = false
local v3 = false

local function getActiveEvent()
	local now = os.time()
	local v4 = nil

	for _, event in ipairs(EventsConfig.Events) do
		if event.Start <= now and now < event.End and (not v4 or event.Start > v4.Start) then
			v4 = event
		end
	end

	return v4
end

local function getNextEvent()
	local now = os.time()
	local v4 = nil

	for _, event in ipairs(EventsConfig.Events) do
		if now < event.Start and (not v4 or event.Start < v4.Start) then
			v4 = event
		end
	end

	return v4
end

local function getState()
	local now = os.time()
	local nextEvent = getNextEvent()
	local v4 = not nextEvent and 1e999 or nextEvent.Start - now or 1e999
	return v4 > 0 and v4 <= 172800, v4, nextEvent
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatCountdown(p)
	local v4 = math.max(0, (math.floor(p)))
	local v5 = math.floor(v4 / 3600)
	local v6 = math.floor(v4 % 3600 / 60)
	local v7 = v4 % 60
	return string.format("%02dh %02dm %02ds", v5, v6, v7)
end

local function initInstance(p, instance)
	if p == "EventWall" then
		local v4 = getActiveEvent() ~= nil
		instance.Transparency = v4 and 1 or 0
		instance.CanCollide = not v4
	else
		local now = os.time()
		local nextEvent = getNextEvent()
		local v4 = nextEvent and nextEvent.Start - now or 1e999
		local visible

		if v4 > 0 then
			visible = v4 <= 172800
		else
			visible = false
		end

		if instance:IsA("BasePart") then
			instance.Transparency = visible and 0 or 1
		elseif instance:IsA("TextLabel") or instance:IsA("TextButton") then
			instance.Visible = visible
		end
	end
end

local function doFadeOut()
	v = true

	for _, v4 in ipairs(CollectionService:GetTagged("NextEventTimer")) do
		v4.Visible = false
	end

	for _, v4 in ipairs(CollectionService:GetTagged("NextEventTimer2")) do
		v4.Visible = false
	end

	local tagged = CollectionService:GetTagged("NextEventPart")

	if #tagged == 0 then
		v = false
		return
	end

	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine)
	local count = #tagged

	for _, v4 in ipairs(tagged) do
		local tween = TweenService:Create(v4, tweenInfo, {
			Transparency = 1
		})
		tween.Completed:Connect(function()
			count -= 1

			if count <= 0 then
				v = false
			end
		end)
		tween:Play()
	end
end

return {
	Init = function(_)
		CollectionService:GetInstanceAddedSignal("NextEventPart"):Connect(function(instance)
			local now = os.time()
			local nextEvent = getNextEvent()
			local v4 = nextEvent and nextEvent.Start - now or 1e999
			local visible

			if v4 > 0 then
				visible = v4 <= 172800
			else
				visible = false
			end

			if instance:IsA("BasePart") then
				instance.Transparency = visible and 0 or 1
			elseif instance:IsA("TextLabel") or instance:IsA("TextButton") then
				instance.Visible = visible
			end
		end)
		CollectionService:GetInstanceAddedSignal("NextEventTimer"):Connect(function(instance)
			local now = os.time()
			local nextEvent = getNextEvent()
			local v4 = nextEvent and nextEvent.Start - now or 1e999
			local visible

			if v4 > 0 then
				visible = v4 <= 172800
			else
				visible = false
			end

			if instance:IsA("BasePart") then
				instance.Transparency = visible and 0 or 1
			elseif instance:IsA("TextLabel") or instance:IsA("TextButton") then
				instance.Visible = visible
			end
		end)
		CollectionService:GetInstanceAddedSignal("NextEventTimer2"):Connect(function(instance)
			local now = os.time()
			local nextEvent = getNextEvent()
			local v4 = nextEvent and nextEvent.Start - now or 1e999
			local visible

			if v4 > 0 then
				visible = v4 <= 172800
			else
				visible = false
			end

			if instance:IsA("BasePart") then
				instance.Transparency = visible and 0 or 1
			elseif instance:IsA("TextLabel") or instance:IsA("TextButton") then
				instance.Visible = visible
			end
		end)
		CollectionService:GetInstanceAddedSignal("EventWall"):Connect(function(p)
			local v4 = getActiveEvent() ~= nil
			p.Transparency = v4 and 1 or 0
			p.CanCollide = not v4
		end)
		task.spawn(function()
			while true do
				local now = os.time()
				local nextEvent = getNextEvent()
				local v4 = nextEvent and nextEvent.Start - now or 1e999
				local v5

				if v4 > 0 then
					v5 = v4 <= 172800
				else
					v5 = false
				end

				if v2 and not (v5 or v) then
					doFadeOut()
				elseif not v then
					for _, v6 in ipairs(CollectionService:GetTagged("NextEventPart")) do
						local transparency = v5 and 0 or 1

						if v6.Transparency ~= transparency then
							v6.Transparency = transparency
						end
					end

					local activeEvent = getActiveEvent()

					for _, v6 in ipairs(CollectionService:GetTagged("NextEventTimer")) do
						if v5 then
							v6.Visible = true
							v6.Text = (not nextEvent and "" or nextEvent.Label or nextEvent.Name or "") .. "\n" .. formatCountdown(v4)
						elseif activeEvent then
							v6.Visible = true
							v6.Text = "Happy " .. (activeEvent.Label or activeEvent.Name)
						elseif v6.Visible then
							v6.Visible = false
						end
					end

					for _, v6 in ipairs(CollectionService:GetTagged("NextEventTimer2")) do
						if v5 then
							v6.Visible = true
							v6.Text = formatCountdown(v4)
						elseif v6.Visible then
							v6.Visible = false
						end
					end
				end

				local v6 = getActiveEvent() ~= nil

				if v6 ~= v3 then
					v3 = v6

					for _, v7 in ipairs(CollectionService:GetTagged("EventWall")) do
						v7.Transparency = v6 and 1 or 0
						v7.CanCollide = not v6
					end
				end

				v2 = v5
				task.wait(1)
			end
		end)
	end
}