local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local parent = script.Parent
local parent2 = parent.Parent
local templates = script:WaitForChild("Templates")
local v = { templates:WaitForChild("SquareConfetti"), templates:WaitForChild("CircularConfetti") }
local touchEnabled = UserInputService.TouchEnabled
local colors = table.create(6)
local v2 = touchEnabled and 22 or 34
local v3 = touchEnabled and 10 or 16

for i = 1, 6 do
	colors[i] = Color3.fromHSV(((i - 1) / 6 + 0.14) % 1, 0.68, 1)
end

local clones = table.create(v2)
local v4 = table.create(v2)
local Ys = table.create(v2)
local v5 = table.create(v2)
local v6 = table.create(v2)
local v7 = table.create(v2)
local v8 = table.create(v2)
local v9 = table.create(v2)
local v10 = 0
local v11 = 0
local v12 = 0
local v13 = 0
local renderSteppedConnection = nil
local random = Random.new()

local function buildPool()
	if v2 <= v10 then
		return
	end

	for i = v10 + 1, v2 do
		local clone = v[i % 2 + 1]:Clone()
		clone.Name = "P"
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.ZIndex = 20
		clone.Visible = false
		clone.Parent = parent
		clones[i] = clone
		local v14 = Ys
		local v15 = v5
		local v16 = v6
		local v17 = v7
		local v18 = v8
		local v19 = v9
		v4[i] = 0
		v14[i] = 0
		v15[i] = 0
		v16[i] = 0
		v17[i] = 0
		v18[i] = 0
		v19[i] = 0
	end

	v10 = v2
end

local sleep
local emit

local function step(p: number)
	local v14 = p > 0.1 and 0.1 or p
	local v15 = parent.AbsoluteSize.Y + 80
	local v16 = 1 - v14 * 0.9
	local v17 = v16 < 0 and 0 or v16
	local count = 0

	for i = 1, v10 do
		local v18 = v9[i]

		if not (v18 > 0) then
			continue
		end

		local v19 = v18 - v14
		local v20 = Ys[i] + v6[i] * v14

		if v19 <= 0 or v15 < v20 then
			v9[i] = 0
			clones[i].Visible = false
		else
			local v21 = v4[i] + v5[i] * v14
			local rotation = v7[i] + v8[i] * v14
			v9[i] = v19
			local v23 = Ys
			v4[i] = v21
			v23[i] = v20
			v5[i] *= v17
			v6[i] += v14 * 1500
			v7[i] = rotation
			local v26 = clones[i]
			v26.Position = UDim2.fromOffset(v21, v20)
			v26.Rotation = rotation

			if v19 < 0.55 then
				v26.ImageTransparency = 1 - v19 / 0.55
			end

			count += 1
		end
	end

	if v13 > 0 and os.clock() - v12 >= 0.1 then
		local v18 = v13
		v13 = 0
		emit(v18)
	elseif count == 0 then
		sleep()
	end
end

local function wake()
	if not renderSteppedConnection then
		parent2.Enabled = true
		renderSteppedConnection = RunService.RenderStepped:Connect(step)
	end
end

sleep = function()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	parent2.Enabled = false
end

emit = function(p: number?)
	local v14 = p or v3
	local now = os.clock()

	if now - v12 < 0.1 then
		if v13 < v14 then
			v13 = v14
		end

		wake()
	else
		buildPool()
		local absoluteSize = parent.AbsoluteSize

		if absoluteSize.X < 1 or absoluteSize.Y < 1 then
			if v13 < v14 then
				v13 = v14
			end

			wake()
		else
			v12 = now

			if v3 < v14 then
				v14 = v3
			end

			local v15 = absoluteSize.X * 0.5
			local Y = absoluteSize.Y

			for _ = 1, v14 do
				v11 += 1

				if v2 < v11 then
					v11 = 1
				end

				local v16 = v11
				local number = random:NextNumber(-0.8, 0.8)
				local number2 = random:NextNumber(950, 1650)
				local integer = random:NextInteger(13, 23)
				v4[v16] = v15 + random:NextNumber(-40, 40)
				Ys[v16] = Y
				v5[v16] = math.sin(number) * number2
				v6[v16] = -math.cos(number) * number2
				v7[v16] = random:NextNumber(0, 360)
				v8[v16] = random:NextNumber(120, 460) * (random:NextInteger(0, 1) == 0 and -1 or 1)
				v9[v16] = 1.6
				local v17 = clones[v16]
				v17.Size = UDim2.fromOffset(integer, integer)
				v17.ImageColor3 = colors[random:NextInteger(1, #colors)]
				v17.ImageTransparency = 0
				v17.Position = UDim2.fromOffset(v4[v16], Ys[v16])
				v17.Visible = true
			end

			wake()
		end
	end
end

local function fadeOut()
	v13 = 0

	for i = 1, v10 do
		if v9[i] > 0.25 then
			v9[i] = 0.25
		end
	end
end

local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Name = "Burst"
bindableEvent.Parent = parent2
bindableEvent.Event:Connect(emit)
local bindableEvent2 = Instance.new("BindableEvent")
bindableEvent2.Name = "Fade"
bindableEvent2.Parent = parent2
bindableEvent2.Event:Connect(fadeOut)
parent2.DisplayOrder = 6
parent2.IgnoreGuiInset = true
parent2.ResetOnSpawn = false
parent2.Enabled = false
script.Destroying:Once(function()
	sleep()
	bindableEvent:Destroy()
	bindableEvent2:Destroy()
end)