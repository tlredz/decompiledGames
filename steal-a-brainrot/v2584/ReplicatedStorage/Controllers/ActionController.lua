local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Flags = require(script.Flags)
local Bindable = require(ReplicatedStorage.UserGenerated.Concurrency.Bindable)
local pressed = Bindable.new()
local released = Bindable.new()
local v3 = false
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function IsAction(p)
	return p.UserInputType == Enum.UserInputType.Touch or p.UserInputType == Enum.UserInputType.MouseButton1 or p.KeyCode == Enum.KeyCode.ButtonR2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetInputDown(flag: boolean, p, vector: Vector3)
	v4 = nil

	if v3 == flag then
		return
	end

	v3 = flag

	if flag then
		pressed:Fire(p, vector)
	else
		released:Fire(p)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if IsAction(input) and not v3 then
		if input.UserInputType == Enum.UserInputType.Touch then
			v4 = {
				Object = input,
				Origin = input.Position,
				Age = 0
			}
			return
		end

		SetInputDown(true, input, input.Position) -- equivalent call inferred; original call site unknown
	end
end)
UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if v4 and v4.Object == input and (v4.Origin - input.Position).Magnitude > Flags.DraggingThreshold:Get() then
		v4 = nil
	end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if v4 and v4.Object == input then
		if (v4.Origin - v4.Object.Position).Magnitude > Flags.DraggingThreshold:Get() then
			v4 = nil
		else
			SetInputDown(true, v4.Object, v4.Origin) -- equivalent call inferred; original call site unknown
		end
	end

	if IsAction(input) then
		local _ = input.Position
		v4 = nil

		if v3 == false then
			return
		end

		v3 = false
		released:Fire(input)
	end
end)
RunService:BindToRenderStep("ActionController", Enum.RenderPriority.Input.Value, function(p)
	if v4 then
		v4.Age += p

		if v4.Age >= Flags.TouchDuration:Get() then
			if (v4.Origin - v4.Object.Position).Magnitude > Flags.DraggingThreshold:Get() then
				v4 = nil
				return
			end

			SetInputDown(true, v4.Object, v4.Origin) -- equivalent call inferred; original call site unknown
		end
	end
end)
return table.freeze({
	Pressed = pressed,
	Released = released,
	IsInputDown = function()
		return v3
	end
})