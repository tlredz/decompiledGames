local TweenService = game:GetService("TweenService")
local v = {}

for _, guiObject in script.Parent:GetChildren() do
	if not guiObject:IsA("GuiObject") then
		continue
	end

	local name = tonumber(guiObject.Name)

	if not name then
		continue
	end

	local v2 = name + 1
	local v3 = v[v2]

	if not v3 then
		v3 = {}
		v[v2] = v3
	end

	table.insert(
		v3,
		TweenService:Create(
			guiObject,
			TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false),
			{
				ImageTransparency = 1
			}
		)
	)
end

task.spawn(function()
	while true do
		for _, v2 in v do
			for _, v3 in v2 do
				v3.Instance.ImageTransparency = 0.8
				v3:Play()
			end

			task.wait(0.1)
		end

		task.wait(2)
	end
end)