local UserInputService = game:GetService("UserInputService")
local v = nil
local v2 = {}
v = {
	Current = "MouseKeyboard",
	Observe = function(callback)
		if table.find(v2, callback) then
			error("function already subscribed", 2)
		end

		table.insert(v2, callback)
		task.spawn(callback, v.Current)
		return function()
			local index = table.find(v2, callback)

			if index then
				local count = #v2
				local v3 = v2
				v2[index] = v2[count]
				v3[count] = nil
			end
		end
	end
}

local function SetPreferred(current: string)
	if current == v.Current then
		return
	end

	v.Current = current

	for _, callback in v2 do
		task.spawn(callback, current)
	end
end

local function DeterminePreferred()
	local preferredInput = UserInputService.PreferredInput

	if preferredInput == Enum.PreferredInput.Touch then
		SetPreferred("Touch")
	elseif preferredInput == Enum.PreferredInput.KeyboardAndMouse then
		SetPreferred("MouseKeyboard")
	elseif preferredInput == Enum.PreferredInput.Gamepad then
		SetPreferred("Gamepad")
	end
end

DeterminePreferred()
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(DeterminePreferred)
return v