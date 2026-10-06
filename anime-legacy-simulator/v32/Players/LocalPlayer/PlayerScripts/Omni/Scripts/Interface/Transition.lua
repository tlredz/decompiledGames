local module = require("@game/ReplicatedStorage/Omni")
local transition = module.Instance.PlayerGui:WaitForChild("Transition")
local frame = Instance.new("Frame")
frame.Name = "Template"
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
local modulesByName = {}
local result = {}
local v = nil
local Transition = {}

local function GetCells()
	local v2 = result[1]

	if v2 and v2.Instance.Parent == transition then
		return result
	end

	for _, v3 in result do
		v3.Instance:Destroy()
	end

	table.clear(result)

	for i = 0, 14 do
		for i2 = 0, 14 do
			local clone = frame:Clone()
			clone.Position = UDim2.fromScale((i2 + 0.5) / 15, (i + 0.5) / 15)
			clone.Visible = false
			clone.Parent = transition
			local v3 = (i2 + 0.5) / 15 - 0.5
			local v4 = (i + 0.5) / 15 - 0.5
			local distance = math.sqrt(v3 * v3 + v4 * v4) / 0.7071067811865476
			table.insert(result, {
				Instance = clone,
				Distance = distance,
				Size = 0.06666666666666667
			})
		end
	end

	return result
end

function Transition.Create(style: string, p2: string, duration: number, p4: number?, callback)
	if v ~= nil then
		Transition.Destroy()
	end

	local v2 = modulesByName[style]

	if not v2 then
		return
	end

	local v3 = v2[p2]

	if not (v3 and workspace.CurrentCamera) then
		return
	end

	local lastTime = tick()
	local endTime = lastTime + duration
	local middleTime = lastTime + duration * 0.5
	local cells = GetCells()

	for _, v7 in cells do
		v7.Instance.BackgroundTransparency = 1
		v7.Instance.Size = UDim2.fromScale(v7.Size, v7.Size)
		v7.Instance.Visible = true
	end

	local renderSteppedConnection = nil
	renderSteppedConnection = module.Services.RunService.RenderStepped:Connect(function()
		if not v then
			renderSteppedConnection:Disconnect()
			return
		end

		local v7 = tick() - lastTime
		local v8 = v7 / duration

		if p4 and v8 > 0.5 then
			local v9 = (v7 - p4) / duration
			v8 = v9 < 0.5 and 0.5 or v9

			if callback then
				module.Libs.ThreadSaver.New(callback)
				callback = nil
			end
		end

		v3(v8, cells)

		if v8 >= 1 then
			Transition.Destroy()
		end
	end)
	v = {
		Style = style,
		StartTime = lastTime,
		MiddleTime = middleTime,
		EndTime = endTime,
		Duration = duration,
		Connection = renderSteppedConnection
	}
	v3(0, cells)
end

function Transition.Destroy()
	if not v then
		return
	end

	if v.Connection then
		v.Connection:Disconnect()
	end

	for _, v2 in result do
		v2.Instance.Visible = false
	end

	v = nil
end

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module2 = require(moduleScript)
	modulesByName[name] = module2
end

return Transition