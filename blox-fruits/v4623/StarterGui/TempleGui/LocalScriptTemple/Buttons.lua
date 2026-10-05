local innerClock = (game.ReplicatedStorage.MapStash:FindFirstChild("Temple of Time") or workspace.Map:FindFirstChild("Temple of Time")).InnerClock
local parent = script.Parent
local Util = require(game.ReplicatedStorage.Util)
local signal2 = Util.Signal2
local childrenByName = {}
local Buttons = {}

for _, child in pairs(innerClock:GetChildren()) do
	if child.Name:match("Gear") then
		childrenByName[child.Name] = child
	end
end

for _, child in pairs(parent.Parent.GearButtons:GetChildren()) do
	Buttons[child.Name] = setmetatable({
		btn = child,
		gear = childrenByName[child.Name],
		MouseEntered = signal2.new(),
		MouseLeave = signal2.new(),
		Activated = signal2.new(),
		__Hovered = false,
		__Selected = false
	}, {
		__index = function(p, p2)
			local success, result = pcall(function()
				return p.btn[p2]
			end)

			if success then
				return result
			end

			return nil
		end,
		__newindex = function(p, p2, p3)
			local success, _ = pcall(function()
				p.btn[p2] = p3
			end)

			if not success then
				rawset(p, p2, p3)
			end
		end
	})
end

function ResizeGears()
	for _, v in pairs(childrenByName) do
		local v2 = Vector3.new(0, v.Size.X, v.Size.X) / 2
		local v3 = v.Position + v2
		local v4 = v.Position - v2
		local worldToScreenPoint = workspace.CurrentCamera:WorldToScreenPoint(v3)
		local worldToScreenPoint2 = workspace.CurrentCamera:WorldToScreenPoint(v4)
		local v5 = math.abs(worldToScreenPoint2.X - worldToScreenPoint.X)
		local v6 = math.abs(worldToScreenPoint2.Y - worldToScreenPoint.Y)
		local v7 = math.min(worldToScreenPoint.X, worldToScreenPoint2.X)
		local v8 = math.min(worldToScreenPoint.Y, worldToScreenPoint2.Y)
		local v9 = Buttons[v.Name]
		v9.Size = UDim2.fromOffset(v5, v6)
		v9.Position = UDim2.fromOffset(v7, v8)
	end
end

for _, v in pairs(Buttons) do
	local v2 = v
	v.btn.Activated:Connect(function(p)
		if p.UserInputType == Enum.UserInputType.Gamepad1 then
			v2.Activated:Fire()
			return
		end

		for k, v3 in pairs(Buttons) do
			if v3.__Hovered then
				v3.Activated:Fire()
			end
		end
	end)
	local v3 = v
	v.btn.SelectionGained:Connect(function()
		v3.__Selected = true
	end)
	local v4 = v
	v.btn.SelectionLost:Connect(function()
		v4.__Selected = false
	end)
end

parent.Parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if parent.Parent:GetAttribute("Draco") then
		return
	end

	if parent.Parent.Enabled then
		ResizeGears()
		local absoluteSizeChangedConnection = parent.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeGears)
		local v = nil

		while true do
			task.wait()
			local UserInputService = game:GetService("UserInputService")
			local mouseLocation = UserInputService:GetMouseLocation()
			local GuiService = game:GetService("GuiService")
			local v2 = mouseLocation - GuiService:GetGuiInset()
			local v3 = nil

			for _, v5 in pairs(Buttons) do
				local magnitude = (v5.AbsolutePosition + v5.AbsoluteSize / 2 - v2).Magnitude

				if v5.__Selected then
					v3 = v5
					break
				elseif magnitude <= v5.AbsoluteSize.X / 2 and magnitude < 1e999 then
					v3 = v5
				end
			end

			local v5 = nil

			if v3 ~= v then
				for _, v6 in pairs(Buttons) do
					if v6 == v3 then
						if not v6.__Hovered then
							v6.__Hovered = true
							v5 = v6
						end
					elseif v6.__Hovered then
						v6.MouseLeave:Fire()
						v6.__Hovered = false
					end
				end
			end

			if v5 then
				v5.MouseEntered:Fire()
			end

			if parent.Parent.Enabled then
				v = v3
			else
				absoluteSizeChangedConnection:Disconnect()

				for _, v6 in pairs(Buttons) do
					if not v6.__Hovered then
						continue
					end

					v6.__Hovered = false
					v6.MouseLeave:Fire()
				end

				break
			end
		end
	end
end)
return Buttons