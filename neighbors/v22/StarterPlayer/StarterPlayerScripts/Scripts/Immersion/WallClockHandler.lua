local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
game:GetService("Lighting")
local v = {}
RunService:BindToRenderStep("UpdateClocks", Enum.RenderPriority.Last.Value, function()
	for _, v2 in v do
		local v3 = os.date("*t")

		if workspace:GetAttribute("CurrentWeatherPreset") == "Halloween" then
			v3 = os.date("*t", os.clock() * 300)
		end

		local v4 = (v3.hour % 12 + v3.min / 60) * 0.5235987755982988
		local v5 = (v3.min + v3.sec / 60) * 0.10471975511965977
		local v6 = v3.sec * 0.10471975511965977
		v2.HourHand.Transform = CFrame.Angles(0, 0, v4)
		v2.MinuteHand.Transform = CFrame.Angles(0, 0, v5)
		v2.SecondHand.Transform = CFrame.Angles(0, 0, v6)
	end
end)

local function SetupClock(instance)
	table.insert(v, {
		HourHand = instance.PrimaryPart.HourHand,
		MinuteHand = instance.PrimaryPart.MinuteHand,
		SecondHand = instance.PrimaryPart.SecondHand
	})
	local clone = script.Tick:Clone()
	clone.Parent = instance.PrimaryPart
	clone.Playing = true
end

for _, v2 in CollectionService:GetTagged("Clock") do
	SetupClock(v2)
end