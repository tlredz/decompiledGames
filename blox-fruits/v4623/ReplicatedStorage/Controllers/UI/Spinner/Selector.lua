local RunService = game:GetService("RunService")
require(script.Parent.SpinnerTypes)
require(game.ReplicatedStorage.React.RobloxTypes)
local Create = require(game.ReplicatedStorage.Modules.Create)
local AssetComponent = require(game.ReplicatedStorage.Modules.Create.AssetComponent)
local Spring = require(game.ReplicatedStorage.Packages.Spring)
local SpinnerUtil = require(script.Parent.SpinnerUtil)
local new = Create.new
local random = Random.new()

local function toLocal(p, point: Vector2)
	return point - p.AbsolutePosition
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCenter(template)
	return Vector2.new(
		template.AbsolutePosition.X + template.AbsoluteSize.X / 2,
		template.AbsolutePosition.Y + template.AbsoluteSize.Y / 2
	)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function bezier(p: number, p2: number, p3: number, p4: number)
	return p * (1 - p4) ^ 2 + p2 * 2 * (1 - p4) * p4 + p3 * p4 * p4
end

local count = 0
local v = {}
local renderSteppedConnection = nil
return function(data, data2)
	local screenGui = data.WinnerTile.Frame:FindFirstAncestorOfClass("ScreenGui")
	local selectorFrame = screenGui:FindFirstChild("SelectorFrame")

	if selectorFrame == nil then
		selectorFrame = new("ScrollingFrame", {
			Name = "SelectorFrame",
			Size = UDim2.fromScale(0.8, 0.12),
			ScrollingDirection = Enum.ScrollingDirection.X,
			CanvasSize = UDim2.new(),
			ScrollBarThickness = 0,
			ScrollBarImageTransparency = 0.5,
			ScrollBarImageColor3 = Color3.fromRGB(48, 48, 48),
			Position = UDim2.new(0.5, 0, 1, -5),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Parent = screenGui
		}, { new("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.005, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center
			}) })
		assert(selectorFrame)
		local uIListLayout = selectorFrame:FindFirstChildOfClass("UIListLayout")
		local thread = nil

		local function fn()
			if thread then
				task.cancel(thread)
				thread = nil
			end

			thread = task.delay(0.01, function()
				thread = nil
				selectorFrame.CanvasSize = UDim2.fromOffset(uIListLayout.AbsoluteContentSize.X, 0)
				selectorFrame.CanvasPosition = Vector2.new(uIListLayout.AbsoluteContentSize.X, 0)
			end)
		end

		if thread then
			task.cancel(thread)
			thread = nil
		end

		thread = task.delay(0.01, function()
			thread = nil
			selectorFrame.CanvasSize = UDim2.fromOffset(uIListLayout.AbsoluteContentSize.X, 0)
			selectorFrame.CanvasPosition = Vector2.new(uIListLayout.AbsoluteContentSize.X, 0)
		end)
		uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fn)
		data.WindowMaid:Add(assert(selectorFrame))
		data.WindowMaid:Add(function()
			table.clear(v)
		end)
	end

	assert(selectorFrame)
	local frame = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		ClipsDescendants = true,
		Parent = selectorFrame
	}, { new("UIAspectRatioConstraint", {
			AspectRatio = 1
		}) })
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 2),
		PaddingRight = UDim.new(0, 2),
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 2),
		Parent = frame
	})
	local Create2 = require(game.ReplicatedStorage.Modules.Create)
	local template = Create2.Template("AssetComponentTemplate")
	template.LayoutOrder = data._CurrentSpin
	template.Size = UDim2.fromScale(1, 1)
	template.ZIndex = 10
	template.Parent = frame
	template.Visible = false
	local assetComponent = AssetComponent(template)
	assetComponent:UpdateAsset({
		IdType = data2.ItemType,
		Image = SpinnerUtil.getImage(data2.ImageName, data2.ItemType, data2.ItemId),
		Equipped = false,
		StorageName = data2.StorageName,
		DisplayName = data2.DisplayName,
		Rarity = data2.Rarity.Value,
		ItemId = data2.ItemId
	})
	local clone = template:Clone()
	clone.Position = UDim2.fromOffset(
		data.WinnerTile.Frame.AbsolutePosition.X,
		data.WinnerTile.Frame.AbsolutePosition.Y
	)
	clone.Size = UDim2.fromOffset(data.WinnerTile.Frame.AbsoluteSize.X, data.WinnerTile.Frame.AbsoluteSize.Y)
	clone.Parent = screenGui
	clone.Visible = true
	local filled = clone:FindFirstChild("Filled")
	template:FindFirstChild("Filled")

	local function fn(floatingAssetTile, assetTileInstance, p)
		local filled2 = floatingAssetTile:FindFirstChild("Filled")
		local filled3 = assetTileInstance:FindFirstChild("Filled")

		for _, guiObject in pairs(filled2:GetChildren()) do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			if p == false then
				if guiObject.Name ~= "Icon" then
					guiObject.Visible = false
				end
			else
				local guiObject2 = filled3:FindFirstChild(guiObject.Name)

				if guiObject2 and guiObject2:IsA("GuiObject") and guiObject2.Visible then
					guiObject.Visible = true
				end
			end
		end
	end

	for _, guiObject in pairs(filled:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject.Name ~= "Icon" then
			guiObject.Visible = false
		end
	end

	local center = getCenter(data.WinnerTile.Frame) -- equivalent call inferred; original call site unknown
	local center2 = getCenter(frame) -- equivalent call inferred; original call site unknown
	local startPos = center - screenGui.AbsolutePosition
	local v4 = center2 - screenGui.AbsolutePosition
	local integer = random:NextInteger(600, 800)
	local integer2 = random:NextInteger(300, 400)
	local integer3 = random:NextInteger(200, 400)
	local integer4 = random:NextInteger(600, 800)
	local point = startPos:Lerp(v4, 0.5) + Vector2.new(integer2, -integer)
	local icon = assetComponent._Rbx.Filled:WaitForChild("Icon")
	local springs = {
		Tile = {
			instance = clone,
			targetCenter = function()
				return getCenter(template)
			end,
			targetSize = function()
				return template.AbsoluteSize
			end,
			springX = Spring.new(3, 5, startPos.X),
			springY = Spring.new(3, 5, startPos.Y),
			springW = Spring.new(3, 5, clone.AbsoluteSize.X),
			springH = Spring.new(3, 5, clone.AbsoluteSize.Y)
		}
	}
	springs.Tile.springX.Velocity = integer3
	springs.Tile.springY.Velocity = integer4
	clone.Position = UDim2.fromOffset(startPos.X, startPos.Y)
	count += 1
	local v7 = {
		Toggled = false,
		FloatingAssetTile = clone,
		AssetTileInstance = template,
		AssetTileIcon = icon,
		Slot = frame,
		Springs = springs,
		Elapsed = 0,
		StartPos = startPos,
		UID = count,
		Point = point,
		_Finished = false,
		_Destroyed = false,
		Destroy = function(self)
			if self._Destroyed then
				return
			end

			self._Destroyed = true

			for i = #v, 1, -1 do
				if v[i].UID ~= self.UID then
					continue
				end

				table.remove(v, i)
				break
			end
		end,
		Finish = function(self)
			if self._Finished or self._Destroyed then
				return
			end

			self:Destroy()
			self._Finished = true

			if self.FloatingAssetTile.Parent then
				self.FloatingAssetTile:Destroy()
			end

			if self.AssetTileInstance.Parent then
				self.AssetTileInstance.Visible = true
			end

			if not assetComponent._Destroyed then
				local TweenService = game:GetService("TweenService")
				TweenService:Create(
					self.AssetTileIcon,
					TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
					{
						Size = UDim2.fromScale(0.8, 0.8)
					}
				):Play()
				data.WindowMaid:Add(task.defer(function()
					if data.Replicator and data2.ItemId and data.Replicator.GetAllItems()[data2.ItemId] then
						assetComponent:EnableHoverHighlight(true)
					end

					if data2.Rarity.Value >= 2 then
						assetComponent:Shine(true)
					end
				end))
			end
		end
	}

	local function fullCleanup()
		v7:Destroy()

		for _, v9 in pairs({ frame, template, clone }) do
			local v10 = v9
			pcall(function(...)
				if v10 and v10.Parent then
					v10:Destroy()
				end
			end)
		end
	end

	if template then
		template.Destroying:Connect(fullCleanup)
	end

	data.WindowMaid:Add(fullCleanup)
	table.insert(v, v7)

	if renderSteppedConnection == nil then
		local count2 = 0
		local total = 0
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if total > 0 then
				if #v == 0 then
					if count2 >= 3 then
						if renderSteppedConnection then
							renderSteppedConnection:Disconnect()
							renderSteppedConnection = nil
						end

						return
					else
						count2 += 1
					end
				else
					total = 0
					count2 = 0
				end
			end

			total += dt

			for i = #v, 1, -1 do
				local v8 = v[i]

				if v8._Finished then
					continue
				end

				local elapsed = math.clamp(v8.Elapsed + dt / 0.2, 0, 1)
				v8.Elapsed = elapsed

				for _, spring in pairs(v8.Springs) do
					local v11 = spring.targetCenter() - screenGui.AbsolutePosition
					local v12 = bezier(v8.StartPos.X, v8.Point.X, v11.X, elapsed)
					local vector = Vector2.new(v12, bezier(v8.StartPos.Y, v8.Point.Y, v11.Y, elapsed))

					if spring.springW and spring.springH then
						local targetSize = spring.targetSize()
						spring.springW:Step(dt)
						spring.springH:Step(dt)
						spring.springW:Set(targetSize.X)
						spring.springH:Set(targetSize.Y)
						local v13 = spring.springW:Get()
						local v14 = spring.springH:Get()
						spring.instance.Size = UDim2.fromOffset(v13, v14)
					end

					spring.springX:Step(dt)
					spring.springY:Step(dt)
					spring.springX:Set(vector.X)
					spring.springY:Set(vector.Y)
					local v13 = spring.springX:Get()
					local v14 = spring.springY:Get()
					spring.instance.Position = UDim2.fromOffset(v13, v14)
				end

				if not (elapsed >= 1) then
					continue
				end

				local tile = v8.Springs.Tile
				local velocity = math.abs(tile.springX.Velocity)
				local midpoint = (math.abs(tile.springY.Velocity) + velocity) / 2

				if not v8.Toggled and (v8.FloatingAssetTile.AbsolutePosition - v8.AssetTileInstance.AbsolutePosition).Magnitude <= 4 then
					v8.Toggled = true
					fn(v8.FloatingAssetTile, v8.AssetTileInstance, true)
				end

				if not (midpoint <= 2.5) then
					continue
				end

				v8:Finish()
				break
			end
		end)
	end

	return assetComponent
end