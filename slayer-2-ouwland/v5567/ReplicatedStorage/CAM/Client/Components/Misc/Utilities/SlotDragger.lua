local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
require(ReplicatedStorage.Packages.faye)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local v = {
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.Touch] = true
}
local v2 = {
	[Enum.KeyCode.Thumbstick1] = true,
	[Enum.KeyCode.Thumbstick2] = true
}
return function(maid, data)
	local clickWindow = data.ClickWindow or 0.1
	local threshold = data.Threshold or 15
	local v3 = nil
	local position = maid:Value()
	local v4 = {}
	local v5 = {
		Down = false,
		Started = nil,
		PressedAt = 0,
		Hover = maid:Value(),
		Offset = nil,
		Size = maid:InstancePropertySync(),
		Icon = nil,
		HoldingDown = nil,
		Dragging = maid:Value(nil),
		ByHand = false
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function grabIcon(holdingDown: string)
		local v6 = v4[holdingDown]

		if v6 == nil then
			return nil
		end

		return v6.Grab()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function pointer()
		local mouseLocation = UserInputService:GetMouseLocation()
		return (vector.create(mouseLocation.X, mouseLocation.Y, 0))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function moveGhost(vector2: Vector3)
		position:Set(UDim2.fromOffset(vector2.X - v5.Offset.X, vector2.Y - v5.Offset.y))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearGhost()
		if v3 ~= nil then
			v3:Destroy()
			v3 = nil
		end
	end

	local function buildGhost()
		clearGhost() -- equivalent call inferred; original call site unknown
		v3 = maid:Extend()
		local v6 = {
			Parent = data.Target,
			ZIndex = 200,
			Size = v3:Do(function(callback)
				local v7 = callback(v5.Size)
				return UDim2.fromOffset(v7.X, v7.Y)
			end),
			BackgroundTransparency = 1,
			Position = position,
			v3:Create("ImageLabel")({
				Size = UDim2.fromScale(1.25, 1.25),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 3,
				BackgroundTransparency = 1,
				Image = v5.Icon,
				ImageTransparency = 0,
				ScaleType = data.IconScaleType
			})
		}

		if data.Backdrop ~= nil then
			table.insert(v6, data.Backdrop(v3))
		end

		v3:Create("Frame")(v6)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function commit()
		local v6 = v5.Dragging:Get()
		local v7 = v5.Hover:Get()

		if v6 ~= nil and v7 ~= nil and v6 ~= v7 then
			data.OnDrop(v6, v7)
		end
	end

	function v5.Attach(_, p: string, entity, grab)
		v4[p] = {
			Entity = entity,
			Grab = grab
		}
	end

	function v5:Begin(p2, holdingDown: string)
		local icon = grabIcon(holdingDown) -- equivalent call inferred; original call site unknown

		if icon == nil then
			return
		end

		local absolutePosition = p2.AbsolutePosition
		local started = pointer() -- equivalent call inferred; original call site unknown
		self.Size:ReCalibrate(p2, "AbsoluteSize")
		self.Offset = vector.create(started.X - absolutePosition.X, started.Y - absolutePosition.Y)
		self.Icon = icon
		self.HoldingDown = holdingDown
		self.Started = started
		self.PressedAt = os.clock()
		self.Down = true
	end

	function v5.SetHover(p, p2: string)
		if p.ByHand then
			return
		end

		p.Hover:Set(p2)
	end

	function v5.ClearHover(p, p2: string)
		if p.ByHand then
			return
		end

		if p.Hover:Compare(p2) then
			p.Hover:Reset()
		end
	end

	local function hitTest(vector2: Vector3)
		local guiInset = GuiService:GetGuiInset()
		local v6 = vector2.X - guiInset.X
		local v7 = vector2.Y - guiInset.Y

		for k, v8 in v4 do
			local entity = v8.Entity

			if entity.Parent == nil then
				continue
			end

			local absolutePosition = entity.AbsolutePosition
			local absoluteSize = entity.AbsoluteSize

			if absolutePosition.X <= v6 and v6 <= absolutePosition.X + absoluteSize.X and absolutePosition.Y <= v7 and v7 <= absolutePosition.Y + absoluteSize.Y then
				return k
			end
		end

		return nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function follow(vector2: Vector3, flag: boolean)
		moveGhost(vector2) -- equivalent call inferred; original call site unknown

		if not flag then
			return
		end

		local v6 = hitTest(vector2)

		if v6 == nil then
			v5.Hover:Reset()
		else
			v5.Hover:Set(v6)
		end
	end

	maid:Connect(UserInputService.InputChanged, function(data2)
		if v5.Down ~= true or v[data2.UserInputType] == nil and v2[data2.KeyCode] == nil then
			return
		end

		local byHand = data2.UserInputType == Enum.UserInputType.Touch
		local vector2

		if byHand then
			if data2 ~= InputHandler.HeldObject("Slot_Drag") then
				return
			end

			local guiInset = GuiService:GetGuiInset()
			vector2 = vector.create(data2.Position.X + guiInset.X, data2.Position.Y + guiInset.Y, 0)
		else
			vector2 = pointer()
		end

		if v5.Dragging:Compare(nil) then
			if os.clock() - v5.PressedAt < clickWindow or vector.magnitude(vector2 - v5.Started) <= threshold then
				return
			end

			v5.ByHand = byHand
			follow(vector2, byHand) -- equivalent call inferred; original call site unknown
			v5.Dragging:Set(v5.HoldingDown)
			buildGhost()
			InputHandler.SetDragging(true)
		else
			follow(vector2, byHand) -- equivalent call inferred; original call site unknown
		end
	end)
	maid:Add(InputHandler.ListenTo("Slot_Drag", function(p: string)
		if p ~= "Up" then
			return
		end

		if v5.Down == true then
			v5.Down = false
			commit() -- equivalent call inferred; original call site unknown
			v5.ByHand = false
			v5.Dragging:Set(nil)
			clearGhost() -- equivalent call inferred; original call site unknown
			InputHandler.SetDragging(false)
		end

		v5.Hover:Reset()
		v5.Dragging:Reset()
	end))
	maid:Add(function()
		InputHandler.SetDragging(false)
	end)
	return v5
end