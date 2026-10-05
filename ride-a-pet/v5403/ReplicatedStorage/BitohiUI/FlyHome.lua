local UserInputService = game:GetService("UserInputService")
local Spring = require(script.Parent:WaitForChild("Spring"))
local Ticker = require(script.Parent:WaitForChild("Ticker"))
local Store = require(script.Parent:WaitForChild("Store"))
local spr = Spring.spr
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function play(p)
	if not p then
		return
	end

	v = v or require(script.Parent:WaitForChild("SFX"))
	v.play(p)
end

local FlyHome = {
	Defaults = {
		Fold = 0.12,
		Flight = 0.46,
		Arc = 0.28,
		Tilt = 14,
		Fit = 1.1,
		Release = 0.78,
		Ghosts = UserInputService.TouchEnabled and 3 or 5,
		GhostEvery = 0.05,
		GhostLife = 0.3,
		GhostFill = 0.72,
		GhostStroke = 0.4
	}
}
local v2 = Store.new()
local rotations = Store.new()

local function defaultArrive(p)
	Spring.scaleFrom(p, 1.3, "Punch", "FlyHomeScale")
	local rotation = rotations[p]

	if rotation == nil then
		rotation = p.Rotation
		rotations[p] = rotation
	end

	local v3 = -(v2[p] or 1)
	v2[p] = v3
	spr.stop(p, "Rotation")
	p.Rotation = rotation + v3 * 12
	Spring.to(p, "Wobble", {
		Rotation = rotation
	})
end

local function resolve(guiObject)
	if type(guiObject) == "function" then
		guiObject = guiObject()
	end

	if typeof(guiObject) ~= "Instance" or not guiObject:IsA("GuiObject") then
		return nil
	end

	if Ticker.isShown(guiObject) then
		return guiObject
	end

	return nil
end

function FlyHome.attach(object, options)
	local object2 = setmetatable(options or {}, {
		__index = FlyHome.Defaults
	})
	local main = object.main
	local scale = object.scale
	local fade = object.fade
	local rotation = main.Rotation
	local settle = object.opts.Settle
	local onArrive = object2.OnArrive or defaultArrive
	local opts = object.opts
	local fold = object2.Fold
	opts.Settle = math.max(settle, fold + object2.Flight + 0.1)
	local ghosts = object2.Ghosts
	local v3 = table.create(ghosts)
	local v4 = table.create(ghosts)
	local v5 = table.create(ghosts)
	local v6 = 0
	local flag = false

	local function buildGhosts()
		if flag then
			return
		end

		flag = true
		local ghostColor = object2.GhostColor

		if not ghostColor then
			local uIStroke = main:FindFirstChildOfClass("UIStroke")
			ghostColor = uIStroke and uIStroke.Color or Color3.fromRGB(20, 20, 26)
		end

		local uICorner = main:FindFirstChildOfClass("UICorner")

		for i = 1, ghosts do
			local frame = Instance.new("Frame")
			frame.Name = "FlyHomeGhost"
			frame.AnchorPoint = main.AnchorPoint
			frame.BackgroundColor3 = main.BackgroundColor3
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.ZIndex = main.ZIndex - 1
			frame.Visible = false

			if uICorner then
				local clone = uICorner:Clone()
				clone.Parent = frame
			end

			local uIStroke = Instance.new("UIStroke")
			uIStroke.Color = ghostColor
			uIStroke.Thickness = 3
			uIStroke.Transparency = 1
			uIStroke.Parent = frame
			frame.Parent = main.Parent
			local v7 = v4
			local v8 = v5
			v3[i] = frame
			v7[i] = uIStroke
			v8[i] = -1
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function dropGhost()
		v6 = v6 % ghosts + 1
		local v7 = v3[v6]
		v7.Position = main.Position
		v7.Rotation = main.Rotation
		v7.Size = UDim2.fromOffset(main.AbsoluteSize.X, main.AbsoluteSize.Y)
		v7.BackgroundTransparency = object2.GhostFill
		v4[v6].Transparency = object2.GhostStroke
		v7.Visible = true
		v5[v6] = 0
	end

	local function fadeGhosts(p)
		local ghostLife = object2.GhostLife
		local count = 0

		for i = 1, ghosts do
			local v7 = v5[i]

			if not (v7 >= 0) then
				continue
			end

			local v8 = v7 + p

			if ghostLife <= v8 then
				v5[i] = -1
				v3[i].Visible = false
			else
				v5[i] = v8
				local v9 = v8 / ghostLife
				local v10 = v9 * (2 - v9)
				v3[i].BackgroundTransparency = object2.GhostFill + (1 - object2.GhostFill) * v10
				v4[i].Transparency = object2.GhostStroke + (1 - object2.GhostStroke) * v10
				count += 1
			end
		end

		return count
	end

	local v7 = nil
	local count = 0
	local v8 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function unhide()
		if not v8 then
			return
		end

		v8 = false

		if object2.Hide then
			for _, v9 in ipairs(object2.Hide) do
				v9.Visible = true
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stop()
		if v7 then
			v7:Stop()
			v7 = nil
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearGhosts()
		for i = 1, ghosts do
			if not v3[i] then
				continue
			end

			v5[i] = -1
			v3[i].Visible = false
		end
	end

	local function fly(target)
		buildGhosts()
		spr.stop(main, "Position")
		spr.stop(main, "Rotation")
		spr.stop(scale)
		local position = main.Position
		local scale2 = scale.Scale
		local absoluteSize = main.AbsoluteSize
		local v9 = main.AbsolutePosition + absoluteSize * 0.5
		local v10 = target.AbsolutePosition + target.AbsoluteSize * 0.5
		local v11 = v10.X - v9.X
		local v12 = v10.Y - v9.Y
		local v13 = math.max(1, (math.sqrt(v11 * v11 + v12 * v12)))
		local v14 = -v12 / v13
		local v15 = v11 / v13

		if v15 > 0 then
			v14 = -v14
			v15 = -v15
		end

		local v16 = v13 * object2.Arc
		local v17 = v11 * 0.5 + v14 * v16
		local v18 = v12 * 0.5 + v15 * v16
		local v19 = absoluteSize.X / math.max(0.01, scale2)
		local v20 = math.clamp(target.AbsoluteSize.X * object2.Fit / v19, 0.03, 0.5)
		local v21 = (v11 >= 0 and 1 or -1) * object2.Tilt
		local flight = object2.Flight
		local release = object2.Release
		local ghostEvery = object2.GhostEvery
		play(object2.Sound) -- equivalent call inferred; original call site unknown

		if object2.Hide then
			v8 = true

			for _, v22 in ipairs(object2.Hide) do
				v22.Visible = false
			end
		end

		local total = 0
		local v22 = ghostEvery
		local v23 = false
		local flag2 = false
		stop() -- equivalent call inferred; original call site unknown
		v7 = Ticker.add(function(p)
			local v24 = fadeGhosts(p)

			if flag2 then
				if v24 == 0 and v7 then
					v7:Stop()
					v7 = nil
				end
			else
				total += p
				local v25 = total < flight and total / flight or 1
				local v26 = v25 * v25 * (3 - 2 * v25)
				local v27 = 2 * (1 - v26) * v26
				local v28 = v26 * v26
				main.Position = position + UDim2.fromOffset(v17 * v27 + v11 * v28, v18 * v27 + v12 * v28)
				local v29 = 1 - v25
				scale.Scale = scale2 + (v20 - scale2) * (1 - v29 * v29)
				main.Rotation = rotation + v21 * math.sin(3.141592653589793 * v26)
				v22 += p

				if ghostEvery <= v22 and v25 < 0.9 then
					v22 = 0
					dropGhost() -- equivalent call inferred; original call site unknown
				end

				if not v23 and release <= v25 then
					v23 = true

					if fade then
						fade:Spring(1, { 1, 16 })
					end
				end

				if v25 >= 1 then
					flag2 = true
					play(object2.ArriveSound) -- equivalent call inferred; original call site unknown
					task.spawn(onArrive, target)
				end
			end
		end)
	end

	local v9 = { object:OnClose(function()
			count += 1
			local v10 = count
			local target = object2.Target

			if type(target) == "function" then
				target = target()
			end

			if typeof(target) == "Instance" and target:IsA("GuiObject") then
				if not Ticker.isShown(target) then
					target = nil
				end
			else
				target = nil
			end

			if not target then
				return
			end

			if fade then
				fade:Spring(0.08, { 1, 14 })
			end

			if object2.Shed then
				for _, scope in ipairs(object2.Shed) do
					scope:Spring(1, { 1, 20 })
				end
			end

			task.delay(object2.Fold, function()
				if v10 ~= count or object.IsOpen or not main.Visible then
					return
				end

				local guiObject = target

				if type(guiObject) == "function" then
					guiObject = guiObject()
				end

				if typeof(guiObject) == "Instance" and guiObject:IsA("GuiObject") then
					if not Ticker.isShown(guiObject) then
						guiObject = nil
					end
				else
					guiObject = nil
				end

				if guiObject then
					fly(target)
				elseif fade then
					fade:Spring(1, object.opts.CloseFade)
				end
			end)
		end), object:OnOpen(function()
			count += 1
			stop() -- equivalent call inferred; original call site unknown
			clearGhosts() -- equivalent call inferred; original call site unknown
			unhide() -- equivalent call inferred; original call site unknown
			Spring.to(main, object.opts.Open, {
				Rotation = rotation
			})
		end), (object:OnHidden(function()
			count += 1
			stop() -- equivalent call inferred; original call site unknown
			clearGhosts() -- equivalent call inferred; original call site unknown
			unhide() -- equivalent call inferred; original call site unknown
			spr.stop(main, "Rotation")
			main.Rotation = rotation
		end)) }
	return {
		Detach = function(_)
			count += 1
			stop() -- equivalent call inferred; original call site unknown
			unhide() -- equivalent call inferred; original call site unknown

			for _, connection in ipairs(v9) do
				connection:Disconnect()
			end

			table.clear(v9)

			for i = 1, ghosts do
				if v3[i] then
					v3[i]:Destroy()
				end
			end

			table.clear(v3)
			table.clear(v4)
			flag = false
			object.opts.Settle = settle
			spr.stop(main, "Rotation")
			main.Rotation = rotation
		end
	}
end

return FlyHome