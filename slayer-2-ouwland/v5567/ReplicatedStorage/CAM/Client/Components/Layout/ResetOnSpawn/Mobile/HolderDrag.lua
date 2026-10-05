local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Packages.faye)
local Pointer = require(script.Parent.Pointer)
return function(object, object2, object3, p)
	local v = nil
	local zero = Vector2.zero
	local zero2 = Vector2.zero
	local zero3 = Vector2.zero
	local v2 = false
	local parent = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish()
		local v3 = v2
		v = nil
		v2 = false

		if v3 then
			p.Drop(object3:Get())
		else
			p.Tap()
		end

		object3:Set(Vector2.zero)
	end

	object:Connect(UserInputService.InputEnded, function(p2)
		if p2 ~= v then
			return
		end

		finish() -- equivalent call inferred; original call site unknown
	end)
	object:Connect(RunService.RenderStepped, function()
		local v3 = v

		if v3 == nil then
			return
		end

		local v4 = Pointer(v3) - zero

		if not v2 then
			if v4.Magnitude < 8 then
				return
			else
				v2 = true
			end
		end

		object3:Set(Vector2.new(math.clamp(v4.X, zero2.X, zero3.X), (math.clamp(v4.Y, zero2.Y, zero3.Y))))
	end)
	object:Connect(object2.Changed, function()
		if v ~= nil and object2:Get() ~= true then
			finish() -- equivalent call inferred; original call site unknown
		end
	end)
	return object:Create("TextButton")({
		Name = "EditDrag",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 20,
		Visible = object2,
		function(p2)
			parent = p2.Parent
		end,
		InputBegan = function(_, p2)
			if v ~= nil or p2.UserInputState ~= Enum.UserInputState.Begin or p2.UserInputType ~= Enum.UserInputType.Touch and p2.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			local v3 = parent
			local parent2

			if v3 ~= nil then
				parent2 = v3.Parent
			end

			if v3 == nil or parent2 == nil or not parent2:IsA("GuiObject") then
				return
			end

			local v4 = v3.AbsolutePosition - parent2.AbsolutePosition
			local v5 = parent2.AbsoluteSize - v3.AbsoluteSize
			zero2 = -v4
			zero3 = Vector2.new(math.max(v5.X, 0), (math.max(v5.Y, 0))) - v4
			zero3 = Vector2.new(math.max(zero3.X, zero2.X), (math.max(zero3.Y, zero2.Y)))
			zero = Pointer(p2)
			v = p2
		end
	})
end