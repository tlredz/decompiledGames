local UserInputService = game:GetService("UserInputService")
local touch = Enum.UserInputType.Touch
local keyboard = Enum.UserInputType.Keyboard
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

local function DeterminePreferred(p)
	if p == touch then
		SetPreferred("Touch")
	elseif p == keyboard or string.sub(p.Name, 1, 5) == "Mouse" then
		SetPreferred("MouseKeyboard")
	elseif string.sub(p.Name, 1, 7) == "Gamepad" then
		SetPreferred("Gamepad")
	end
end

local lastInputType = UserInputService:GetLastInputType()

if lastInputType == touch then
	SetPreferred("Touch")
elseif lastInputType == keyboard or string.sub(lastInputType.Name, 1, 5) == "Mouse" then
	SetPreferred("MouseKeyboard")
elseif string.sub(lastInputType.Name, 1, 7) == "Gamepad" then
	SetPreferred("Gamepad")
end

UserInputService.LastInputTypeChanged:Connect(DeterminePreferred)
return v