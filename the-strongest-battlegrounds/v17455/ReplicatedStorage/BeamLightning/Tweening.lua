local TweenService = game:GetService("TweenService")
local Tweening = {}

function Tweening.TweenProperty(p, duration: number, p2: string, p3: string, p4, flag: boolean)
	if not p then
		return
	end

	if flag == nil then
		flag = false
	end

	return (TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle[p2], Enum.EasingDirection[p3], 0, flag), p4))
end

function Tweening.TweenGroup(list, duration: number)
	if typeof(list) ~= "table" then
		error("SEQUENCE MUST BE A TABLE!!!")
	end

	for i = 1, #list do
		list[i]:Play()

		if duration > 0 then
			task.wait(duration)
		end
	end
end

function Tweening.TweenSequence(list)
	if typeof(list) ~= "table" then
		error("SEQUENCE MUST BE A TABLE!!!")
	end

	task.spawn(function()
		for i = 1, #list do
			local v = list[i]
			v:Play()
			v.Completed:Wait()
		end
	end)
	return list[#list]
end

return Tweening