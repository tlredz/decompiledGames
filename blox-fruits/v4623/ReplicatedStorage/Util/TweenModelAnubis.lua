local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local identity = CFrame.identity
local Memoize = require(script.Parent:WaitForChild("Memoize"))
require(script.Parent:WaitForChild("CopyTable"))
local Tween = require(script.Parent:WaitForChild("Tween"))
local v = {}
local cframe = CFrame.new(0, 999999, 0)

local function Return(model, instance)
	v[model][instance] = task.delay(5, function()
		instance.Parent = nil
	end)

	if instance.ClassName == "Model" then
		instance:SetPrimaryPartCFrame(cframe)
	else
		instance.CFrame = cframe
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

local RunService2 = game:GetService("RunService")
local v2

if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
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

local function routine(p, callback, callback2)
	local v3 = math.min(60, p)
	local lastTime = tick()

	while true do
		local v4 = math.min(1, (tick() - lastTime) / v3)
		callback(v4)

		if v4 == 1 then
			break
		end

		RunService.RenderStepped:Wait()
	end

	callback2()
end

local function rawCFrame(cFrame)
	if typeof(cFrame) == "Instance" then
		if cFrame:IsA("Model") then
			if cFrame.PrimaryPart then
				return cFrame.PrimaryPart.CFrame
			end

			return cFrame:GetPivot()
		else
			if cFrame:IsA("BasePart") then
				return cFrame.CFrame
			end

			if cFrame:IsA("Attachment") then
				return cFrame.WorldCFrame
			end
		end
	elseif typeof(cFrame) == "CFrame" then
		return cFrame
	end
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
	local v8 = rawCFrame(v4.CFrame) or identity
	local offset = v4.Offset or identity
	local size = v4.Size or createVector(1, 1, 1)
	local scale = v4.Scale or 1
	local grab = Grab(model)
	grab:SetPrimaryPartCFrame(v8 * offset)

	local function serializeData(instance)
		return
			instance.Size,
			instance.Scale,
			instance ~= v4 and instance.CFrame,
			instance.Transparency,
			instance.Color,
			instance.Tween,
			instance.Custom
	end

	local v10 = v2(grab)

	local function localizeData(items, p)
		for childName, item in pairs(items) do
			if grab:FindFirstChild(childName) and grab[childName] ~= grab.PrimaryPart then
				p[childName] = item
			end
		end
	end

	local v11 = {}
	localizeData(v5, v11)
	local v12 = {}
	localizeData(v7, v12)

	for _, v13 in pairs(v10) do
		local v14 = v11[v13.Name] or v4
		local size2 = v14.Size
		local scale2 = v14.Scale
		local cFrame

		if v14 == v4 then
			cFrame = false
		else
			cFrame = v14.CFrame
		end

		local transparency = v14.Transparency
		local color = v14.Color
		local _ = v14.Tween
		local _ = v14.Custom
		local color2 = color or v4.Color or v13.Color
		local transparency2 = transparency or v4.Transparency or v13.Transparency
		v13.Part.Size = v13.Size * ((size2 or size) * (scale2 or scale))
		v13.Part.CFrame = v8 * offset * v13.Offset * (cFrame or identity)
		v13.Part.Color = color2
		v13.Part.Transparency = transparency2
	end

	grab.Parent = _WorldOrigin
	local count = 0

	for _, v13 in pairs(v10) do
		local v14 = v12[v13.Name] or v6
		local size2 = v14.Size
		local scale2 = v14.Scale
		local cFrame

		if v14 == v4 then
			cFrame = false
		else
			cFrame = v14.CFrame
		end

		local transparency = v14.Transparency
		local color = v14.Color
		local tween = v14.Tween
		local custom = v14.Custom
		local size6 = size2 or v6.Size or size
		local scale5 = scale2 or v6.Scale or scale
		local cFrame4 = cFrame or v6.CFrame
		local color4 = color or v6.Color
		local transparency4 = transparency or v6.Transparency
		local v20 = tween or v6.Tween or tweenInfo

		if typeof(v4.CFrame) == "Instance" or typeof(v20) == "table" or typeof(custom) == "function" then
			local v21 = v11[v13.Name] or v4
			local size3 = v21.Size
			local scale3 = v21.Scale
			local cFrame2

			if v21 == v4 then
				cFrame2 = false
			else
				cFrame2 = v21.CFrame
			end

			local transparency2 = v21.Transparency
			local color2 = v21.Color
			local _ = v21.Tween
			local _ = v21.Custom
			local size7 = size3 or size
			local scale6 = scale3 or scale
			local cFrame5 = cFrame2 or identity
			local color5 = color2 or v4.Color or v13.Color
			local transparency5 = transparency2 or v4.Transparency or v13.Transparency
			local v27 = {
				{},
				{}
			}

			if size7 then
				v27[1].Size = size7
			end

			if scale6 then
				v27[1].Scale = scale6
			end

			if cFrame5 then
				v27[1].CFrame = cFrame5
			end

			if color5 then
				v27[1].Color = color5
			end

			if transparency5 then
				v27[1].Transparency = transparency5
			end

			if size6 then
				v27[2].Size = size6
			end

			if scale5 then
				v27[2].Scale = scale5
			end

			if cFrame4 then
				v27[2].CFrame = cFrame4
			end

			if color4 then
				v27[2].Color = color4
			end

			if transparency4 then
				v27[2].Transparency = transparency4
			end

			local v28 = v8
			local custom2 = custom
			local v31 = v13
			task.spawn(routine, v20.Time or v20[1], function(p)
				local value

				if typeof(v20) == "TweenInfo" then
					value = TweenService:GetValue(p, v20.EasingStyle, v20.EasingDirection)
				else
					value = Tween.ease[v20.Direction or v20[2]][v20.Style or v20[3]](p, 0, 1, 1)
				end

				local size4 = nil
				local scale4 = nil
				local transparency3 = nil
				local color3 = nil
				local v32 = v27[1]
				local v33 = v27[2]
				local cFrame3

				if v32.CFrame and v33.CFrame then
					cFrame3 = v32.CFrame:Lerp(v33.CFrame, value)
				end

				if v32.Size and v33.Size then
					size4 = v32.Size:Lerp(v33.Size, value)
				end

				if v32.Scale and v33.Scale then
					scale4 = Tween.point(v32.Scale, v33.Scale, value)
				end

				if v32.Color and v33.Color then
					color3 = v32.Color:Lerp(v33.Color, value)
				end

				if v32.Transparency and v33.Transparency then
					transparency3 = Tween.point(v32.Transparency, v33.Transparency, value)
				end

				if custom2 then
					local v34 = custom2(value)

					if v34.CFrame then
						cFrame3 = v34.CFrame
					end

					if v34.Size then
						size4 = v34.Size
					end

					if v34.Scale then
						scale4 = v34.Scale
					end

					if v34.Color then
						color3 = v34.Color
					end

					if v34.Transparency then
						transparency3 = v34.Transparency
					end
				end

				local size5 = v31.Size

				if size4 then
					size5 *= size4
				end

				if scale4 then
					size5 *= scale4
				end

				if size4 or scale4 then
					v31.Part.Size = size5
				end

				local v34 = v28

				if typeof(v4.CFrame) == "Instance" and v4.CFrame:IsDescendantOf(workspace) then
					v34 = rawCFrame(v4.CFrame)
					grab:SetPrimaryPartCFrame(v34 * offset)
				end

				if cFrame3 then
					v31.Part.CFrame = v34 * offset * v31.Offset * cFrame3
				end

				if color3 then
					v31.Part.Color = color3
				end

				if transparency3 then
					v31.Part.Transparency = transparency3
				end

				v28 = v34
			end, function()
				count += 1

				if count == #v10 then
					Return(model, grab)
				end
			end)
		else
			local v21 = {}

			if color4 then
				v21.Color = color4
			end

			if transparency4 then
				v21.Transparency = transparency4
			end

			if size6 then
				v21.Size = v13.Size * size6
			end

			if scale5 then
				v21.Size *= scale5
			end

			if cFrame4 then
				v21.CFrame = v8 * offset * v13.Offset * cFrame4
			end

			local count2 = 0

			for _, _ in pairs(v21) do
				count2 += 1
			end

			if count2 > 0 then
				TweenService:Create(v13.Part, v20, v21):Play()
			end

			task.delay(v20.Time, function()
				count += 1

				if count == #v10 then
					Return(model, grab)
				end
			end)
		end
	end

	if #v10 == 0 then
		Return(model, grab)
	end
end

return tweenModel