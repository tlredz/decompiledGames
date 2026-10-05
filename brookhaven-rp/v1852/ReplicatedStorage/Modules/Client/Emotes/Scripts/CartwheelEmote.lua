local CartwheelEmote = {}
CartwheelEmote.__index = CartwheelEmote

function CartwheelEmote.new()
	return (setmetatable({}, CartwheelEmote))
end

function CartwheelEmote.start(_, instance, p)
	p.Looped = true
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
		return
	end

	local running = humanoidRootPart:FindFirstChild("Running")

	if running == nil or not running:IsA("Sound") then
		return
	end

	local volume = running.Volume
	running.Volume = 0
	p.Stopped:Once(function()
		if running.Parent ~= nil then
			running.Volume = volume
		end
	end)
end

return CartwheelEmote