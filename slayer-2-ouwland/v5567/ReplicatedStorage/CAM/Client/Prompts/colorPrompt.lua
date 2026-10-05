local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local clock = os.clock
local v = nil
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

function annihilate(instance)
	if instance == nil then
		return
	end

	local delay = instance:GetAttribute("Delay")
	instance.Name = "--"

	if delay then
		task.delay(delay, function()
			if instance then
				TweenService:Create(instance, tweenInfo2, {
					Size = UDim2.new()
				}):Play()
				DebrisModule:AddItem(instance, 0.10999999999999999)
			end
		end)
		return
	end

	TweenService:Create(instance, tweenInfo2, {
		Size = UDim2.new()
	}):Play()
	DebrisModule:AddItem(instance, 0.10999999999999999)
end

return function(parent, size, position, p2)
	if v ~= nil then
		annihilate(v)
		v = nil
	end

	if parent == nil or size == nil or position == nil then
		return
	end

	local v2 = p2 == nil and 30 or p2
	local clone = script.colorPickerFrame:Clone()
	clone.Size = UDim2.new(size.X.Scale * 0.5, size.X.Offset * 0.5, size.Y.Scale * 0.5, size.Y.Offset * 0.5)
	clone.Rotation = (math.random(1, 2) == 1 and -1 or 1) * 15
	TweenService:Create(clone, tweenInfo, {
		Size = size,
		Rotation = 0
	}):Play()
	clone.Position = position
	DebrisModule:AddItem(clone, v2 + 0.15)
	clone.Parent = parent
	v = clone
	local v3 = true
	local v4 = nil
	local now = clock()
	local name = v.Name
	local v5 = {}
	local eventConnection = clone.Event.Event:Once(function(p3)
		v4 = p3
	end)
	table.insert(v5, (parent:GetAttributeChangedSignal("Opend"):Once(function()
		v3 = false
	end)))
	table.insert(v5, eventConnection)

	while v3 == true do
		if clone == nil or clone.Parent == nil then
			v3 = false
		end

		if v2 < clock() - now then
			v3 = false
		end

		if v4 ~= nil then
			v3 = false
		end

		if v and v.Name ~= name then
			v3 = false
		end

		task.wait()
	end

	for _, connection in pairs(v5) do
		connection:Disconnect()
	end

	if v4 then
		clone:SetAttribute("Delay", 0.4)
	end

	annihilate(clone)
	return v4
end