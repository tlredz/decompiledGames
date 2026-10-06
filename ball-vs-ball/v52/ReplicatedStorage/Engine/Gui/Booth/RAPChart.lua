local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local function create(p)
	local v = {}
	local flag = false
	local v2 = nil
	local v3 = nil
	local v4 = nil
	local v5 = nil
	local v6 = nil
	local v7 = nil
	local labels = {}
	local v8 = nil
	local v9 = nil
	local v10 = nil
	local v11 = nil
	local v12 = nil
	local v13 = nil
	local v14 = nil
	local v15 = nil
	local absoluteSizeChangedConnection = nil

	local function findChild(instance, childName: string)
		if instance then
			return instance:WaitForChild(childName, 10)
		end

		return nil
	end

	local function clearGenerated(instance)
		for _, child in instance:GetChildren() do
			if child:GetAttribute("RAPGenerated") then
				child:Destroy()
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stripPreview(instance, _1)
		for _, child in instance:GetChildren() do
			if child ~= _1 then
				child:Destroy()
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function niceStep(p2: number)
		if p2 <= 0 then
			return 1
		end

		local v16 = 10 ^ math.floor((math.log(p2, 10)))
		local v17 = p2 / v16
		return (v17 <= 1 and 1 or v17 <= 2 and 2 or v17 <= 5 and 5 or 10) * v16
	end

	local function bumpStep(p2: number)
		local v16 = 10 ^ math.floor(math.log(p2, 10) + 1e-9)
		local v17 = p2 / v16

		if v17 < 1.5 then
			return v16 * 2
		end

		if v17 < 3.5 then
			return v16 * 5
		end

		return v16 * 10
	end

	local function formatNumber(p2: number)
		local v16 = math.abs(p2)

		if v16 >= 1000000 then
			return (string.format("%.1fm", p2 / 1000000):gsub("%.0m", "m"))
		end

		if v16 >= 10000 then
			return (string.format("%.1fk", p2 / 1000):gsub("%.0k", "k"))
		end

		if p2 % 1 == 0 then
			return string.format("%d", p2)
		end

		return string.format("%.1f", p2)
	end

	local function computeScale(p2: number, p3: number)
		local v16, v17

		if p3 - p2 < 1e-6 then
			local v18 = p2 == 0 and 1 or p2
			v16 = v18 * 0.8
			v17 = v18 * 1.2
		else
			local v18 = p3 - p2
			v16 = p2 - v18 * 0.1
			v17 = p3 + v18 * 0.1
		end

		local v18 = v16 < 0 and 0 or v16
		local v20 = niceStep((v17 - v18) / 3) -- equivalent call inferred; original call site unknown
		local v21 = math.floor(v18 / v20) * v20
		local count = 0

		while v21 + v20 * 3 < p3 and count < 20 do
			local v22 = 10 ^ math.floor(math.log(v20, 10) + 1e-9)
			local v23 = v20 / v22

			if v23 < 1.5 then
				v20 = v22 * 2
			elseif v23 < 3.5 then
				v20 = v22 * 5
			else
				v20 = v22 * 10
			end

			v21 = math.floor(v18 / v20) * v20
			count += 1
		end

		return v21, v20
	end

	local function setTicks(p2: number?, p3: number?)
		for k, v16 in labels do
			if p2 and p3 then
				v16.Text = formatNumber(p2 + (k - 1) * p3)
			else
				v16.Text = ""
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function formatDetailDate(pointDay: number)
		local universalTime = DateTime.fromUnixTimestamp(pointDay * 86400):ToUniversalTime()
		return string.format("%04d/%02d/%02d", universalTime.Year, universalTime.Month, universalTime.Day)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hideDetail()
		if v9 then
			v9.Visible = false
		end
	end

	local function positionDetailBox(scale: number, scale2: number)
		local v16 = v9
		local v17 = v3

		if not (v16 and v17) then
			return
		end

		local position = v17.Position
		local size = v17.Size
		local v18 = position.X.Scale + scale * size.X.Scale
		local v19 = position.Y.Scale + scale2 * size.Y.Scale
		local halfScale = v16.Size.X.Scale / 2
		local v21 = math.clamp(v18, halfScale, 1 - halfScale)
		v16.Position = UDim2.new(v21, 0, v19, -14)
		v16.Visible = true
	end

	local function showDetailFor(instance)
		local pointDay = instance:GetAttribute("PointDay")
		local pointSum = instance:GetAttribute("PointSum")
		local pointCount = instance:GetAttribute("PointCount")

		if typeof(pointDay) ~= "number" or typeof(pointSum) ~= "number" or typeof(pointCount) ~= "number" or pointCount <= 0 then
			return
		end

		if v10 then
			v10.Text = formatDetailDate(pointDay)
		end

		if v11 then
			v11.Text = string.format("%d", (math.floor(pointSum / pointCount + 0.5)))
		end

		if v12 then
			v12.Text = string.format("%d Sales", pointCount)
		end

		positionDetailBox(instance.Position.X.Scale, instance.Position.Y.Scale)
	end

	local function connectDotInteractions(clone)
		clone.SelectionGained:Connect(function()
			showDetailFor(clone)
		end)
		clone.SelectionLost:Connect(function()
			if v13 ~= clone and v9 then
				v9.Visible = false
			end
		end)
		clone.MouseEnter:Connect(function()
			showDetailFor(clone)
		end)
		clone.MouseLeave:Connect(function()
			if v13 ~= clone and v9 then
				v9.Visible = false
			end
		end)
		ButtonActions.Bind(clone, function()
			if v13 == clone then
				v13 = nil
				hideDetail() -- equivalent call inferred; original call site unknown
			else
				v13 = clone
				showDetailFor(clone)
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disconnectSizeWatch()
		if absoluteSizeChangedConnection then
			absoluteSizeChangedConnection:Disconnect()
			absoluteSizeChangedConnection = nil
		end
	end

	local draw

	draw = function()
		local v16 = v14
		local v17 = v15
		local v18 = v3
		local parent = v4
		local parent2 = v5
		local v21 = v6
		local v22 = v7

		if not (v16 and v18 and parent and parent2 and v21 and v22) then
			return
		end

		clearGenerated(parent)
		clearGenerated(parent2)
		v13 = nil
		hideDetail() -- equivalent call inferred; original call site unknown
		local absoluteSize = v18.AbsoluteSize

		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			if not absoluteSizeChangedConnection then
				absoluteSizeChangedConnection = v18:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					local absoluteSize2 = v18.AbsoluteSize

					if absoluteSize2.X > 0 and absoluteSize2.Y > 0 then
						disconnectSizeWatch() -- equivalent call inferred; original call site unknown
						draw()
					end
				end)
			end
		else
			disconnectSizeWatch() -- equivalent call inferred; original call site unknown
			local v23 = absoluteSize.X / absoluteSize.Y

			for k, v24 in v16 do
				local clone = v22:Clone()
				clone.Name = "数据点_" .. k
				clone:SetAttribute("RAPGenerated", true)
				clone.Position = UDim2.new(v24.x, 0, v24.y, 0)
				clone.Visible = true
				local v25 = v17 and v17[k]

				if v25 then
					clone:SetAttribute("PointDay", v25.day)
					clone:SetAttribute("PointSum", v25.sum)
					clone:SetAttribute("PointCount", v25.count)
					connectDotInteractions(clone)
				end

				clone.Parent = parent2
			end

			for i = 1, #v16 - 1 do
				local v24 = v16[i]
				local v25 = v16[i + 1]
				local v26 = v25.x - v24.x
				local v27 = v25.y - v24.y
				local clone = v21:Clone()
				clone.Name = "线段_" .. i
				clone:SetAttribute("RAPGenerated", true)
				clone.Position = UDim2.new((v24.x + v25.x) / 2, 0, (v24.y + v25.y) / 2, 0)
				clone.Size = UDim2.new(math.sqrt(v26 * v26 + (v27 / v23) ^ 2), 0, v21.Size.Y.Scale, v21.Size.Y.Offset)
				clone.Rotation = math.deg((math.atan2(v27, v26 * v23)))
				clone.Visible = true
				clone.Parent = parent
			end
		end
	end

	function v.Init()
		if flag then
			return
		end

		local playerGui = p

		if not playerGui then
			playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

			for _, childName in {
				"通用确认框",
				"背景",
				"摆摊购买确认面板",
				"RAP信息区"
			} do
				if playerGui then
					playerGui = playerGui:WaitForChild(childName, 10)
				else
					playerGui = nil
				end
			end
		end

		local v16

		if playerGui then
			v16 = playerGui:WaitForChild("折线图", 10)
		end

		local v17

		if v16 then
			v17 = v16:WaitForChild("绘图区", 10)
		end

		local v18

		if v17 then
			v18 = v17:WaitForChild("静态预览", 10)
		end

		local v19

		if v18 then
			v19 = v18:WaitForChild("折线层", 10)
		end

		local v20

		if v18 then
			v20 = v18:WaitForChild("数据点层", 10)
		end

		local v21

		if v16 then
			v21 = v16:WaitForChild("价格刻度区", 10)
		end

		local v22

		if v21 then
			v22 = v21:WaitForChild("静态预览", 10)
		end

		local RAP

		if playerGui then
			RAP = playerGui:WaitForChild("RAP数值", 10)
		end

		if not (playerGui and v17 and v19 and v20 and v22 and RAP) then
			warn("[RAPChart] 摆摊购买确认面板缺少 RAP 信息区节点，折线图已停用")
			return
		end

		local _1 = v19:FindFirstChild("线段_1")
		local _12 = v20:FindFirstChild("数据点_1")

		if not (_1 and _12) then
			warn("[RAPChart] 缺少 线段_1 / 数据点_1 模板，折线图已停用")
			return
		end

		stripPreview(v19, _1) -- equivalent call inferred; original call site unknown
		stripPreview(v20, _12) -- equivalent call inferred; original call site unknown
		_1.Visible = false
		_12.Visible = false
		labels = {}

		for i = 1, 4 do
			local label = v22:FindFirstChild("价格刻度" .. i)

			if label and label:IsA("TextLabel") then
				table.insert(labels, label)
			end
		end

		v3 = v17
		v4 = v19
		v5 = v20
		v6 = _1
		v7 = _12
		v2 = RAP
		v8 = v16
		local frame

		if v16 then
			frame = v16:WaitForChild("数据详情框", 10)
		end

		if frame and frame:IsA("Frame") then
			v9 = frame
			local firstChild = frame:FindFirstChild("价格行")
			local label = frame:FindFirstChild("日期")
			local label2 = frame:FindFirstChild("销量")
			local label3 = firstChild and firstChild:FindFirstChild("价格")

			if not (label and label:IsA("TextLabel")) then
				label = nil
			end

			v10 = label

			if not (label2 and label2:IsA("TextLabel")) then
				label2 = nil
			end

			v12 = label2

			if not (label3 and label3:IsA("TextLabel")) then
				label3 = nil
			end

			v11 = label3
			frame.Visible = false

			if not (v10 and v12 and v11) then
				warn("[RAPChart] 数据详情框缺少 日期/价格行.价格/销量 子节点，详情展示已停用")
			end
		else
			warn("[RAPChart] 缺少 数据详情框，数据点悬浮/点击详情已停用")
		end

		flag = true
	end

	function v.SetLoading()
		if not flag then
			return
		end

		disconnectSizeWatch() -- equivalent call inferred; original call site unknown
		v14 = nil
		v15 = nil
		v13 = nil
		hideDetail() -- equivalent call inferred; original call site unknown

		if v4 then
			clearGenerated(v4)
		end

		if v5 then
			clearGenerated(v5)
		end

		for _, v16 in labels do
			v16.Text = ""
		end

		if v2 then
			v2.Text = "--"
		end
	end

	function v.Render(options)
		if not flag then
			return
		end

		v.SetLoading()
		local v16 = math.floor(Workspace:GetServerTimeNow() / 86400) - 6
		local v17 = {}

		for _, v18 in options or {} do
			if typeof(v18) == "table" and v18.count and v18.count > 0 then
				table.insert(v17, v18)
			end
		end

		if #v17 == 0 then
			return
		end

		table.sort(v17, function(a, b)
			return a.day < b.day
		end)
		local total = 0
		local total2 = 0

		for _, v18 in v17 do
			total += v18.sum
			total2 += v18.count
		end

		if v2 and total2 > 0 then
			v2.Text = string.format("%d", (math.floor(total / total2 + 0.5)))
		end

		local v18 = {}
		local v19 = 1e999
		local v20 = -1e999

		for k, v21 in v17 do
			local v22 = v21.sum / v21.count
			v18[k] = v22
			v19 = math.min(v19, v22)
			v20 = math.max(v20, v22)
		end

		local v21, v22 = computeScale(v19, v20)
		setTicks(v21, v22)
		local v23 = v21 + 3 * v22
		local v24 = v23 - v21
		local v25 = {}

		for k, v26 in v17 do
			local v27 = (v26.day - v16) / 6
			local v28 = not (v24 > 0) and 0.5 or (v23 - v18[k]) / v24
			v25[k] = {
				x = math.clamp(v27, 0, 1),
				y = math.clamp(v28, 0, 1)
			}
		end

		v14 = v25
		v15 = v17
		draw()
	end

	return v
end

local v = create(nil)
v.new = create
return v