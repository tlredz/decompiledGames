local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local cframe = CFrame.new()
local Memoize = require(game.ReplicatedStorage.Util.Memoize)
require(game.ReplicatedStorage.Util.CopyTable)
local v = {}
local cframe2 = CFrame.new(0, 999999, 0)

local function Return(model, instance)
	v[model][instance] = task.delay(5, function()
		instance.Parent = nil
	end)

	if instance.ClassName == "Model" then
		instance:SetPrimaryPartCFrame(cframe2)
	else
		instance.CFrame = cframe2
	end
end

local function Grab(model)
	v[model] = v[model] or {}
	local v2 = v[model]
	local v3, v4 = next(v2)

	if not v3 then
		return model:Clone()
	end

	task.cancel(v4)
	v2[v3] = nil
	return v3
end

local RunService = game:GetService("RunService")
local v2

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	v2 = Memoize(function(folder)
		local result = {}

		for _, part in pairs(folder:GetDescendants()) do
			if part ~= folder.PrimaryPart and part:IsA("BasePart") then
				table.insert(result, {
					Name = part.Name,
					Part = part,
					Size = part.Size,
					Transparency = part.Transparency,
					Color = part.Color,
					Offset = part.CFrame:ToObjectSpace(folder.PrimaryPart.CFrame)
				})
			end
		end

		return result
	end, function(instance)
		for _, v3 in pairs(v) do
			if not v3[instance] then
				continue
			end

			v3[instance] = nil
			instance:Destroy()
			break
		end
	end)
else
	v2 = nil
end

local function tweenModel(model, options, options2)
	local v3

	if typeof(model) == "Instance" then
		v3 = model:IsA("Model") and model.PrimaryPart
	else
		v3 = false
	end

	assert(v3, "Please make sure that the function is being called upon a model with a PrimaryPart")
	local v4 = options or {}
	local v5 = v4[1] or {}
	local v6 = options2 or {}
	local v7 = v6[1] or {}
	local cFrame = v4.CFrame or cframe
	local size = v4.Size or createVector(1, 1, 1)
	local scale = v4.Scale or 1
	local grab = Grab(model)
	grab:SetPrimaryPartCFrame(cFrame)

	local function serializeData(instance)
		return
			instance.Size,
			instance.Scale,
			instance ~= v4 and instance.CFrame,
			instance.Transparency,
			instance.Color,
			instance.Tween
	end

	local v9 = v2(grab)

	local function localizeData(items, p)
		for childName, item in pairs(items) do
			if grab:FindFirstChild(childName) and grab[childName] ~= grab.PrimaryPart then
				p[childName] = item
			end
		end
	end

	local v10 = {}
	localizeData(v5, v10)
	local v11 = {}
	localizeData(v7, v11)

	for _, v12 in pairs(v9) do
		local _ = v10[v12.Name]
		local v13 = v10[v12.Name] or v4
		local size2 = v13.Size
		local scale2 = v13.Scale
		local cFrame2

		if v13 == v4 then
			cFrame2 = false
		else
			cFrame2 = v13.CFrame
		end

		local transparency = v13.Transparency
		local color = v13.Color
		local _ = v13.Tween
		local color2 = color or v4.Color or v12.Color
		local transparency2 = transparency or v4.Transparency or v12.Transparency
		v12.Part.Size = v12.Size * ((size2 or size) * (scale2 or scale))
		v12.Part.CFrame = cFrame * v12.Offset * (cFrame2 or cframe)
		v12.Part.Color = color2
		v12.Part.Transparency = transparency2
	end

	grab.Parent = _WorldOrigin
	local count = 0

	for _, v12 in pairs(v9) do
		local _ = v11[v12.Name]
		local v13 = v11[v12.Name] or v6
		local size2 = v13.Size
		local scale2 = v13.Scale
		local cFrame2

		if v13 == v4 then
			cFrame2 = false
		else
			cFrame2 = v13.CFrame
		end

		local transparency = v13.Transparency
		local color = v13.Color
		local tween = v13.Tween
		local v14 = size2 or v6.Size or size
		local v15 = scale2 or v6.Scale or scale
		local v16 = cFrame2 or v6.CFrame or cframe
		local color2 = color or v6.Color
		local transparency2 = transparency or v6.Transparency
		local v19 = tween or v6.Tween or tweenInfo
		local v20 = {
			Size = v12.Size * (v14 * v15),
			CFrame = cFrame * v12.Offset * v16
		}

		if color2 then
			v20.Color = color2
		end

		if transparency2 then
			v20.Transparency = transparency2
		end

		local tween2 = TweenService:Create(v12.Part, v19, v20)
		task.delay(v19.Time, function()
			count += 1

			if count == #v9 then
				Return(model, grab)
			end
		end)
		tween2:Play()
	end

	if #v9 == 0 then
		Return(model, grab)
	end
end

return tweenModel