local RunService = game:GetService("RunService")
local isRunning = RunService:IsRunning()
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local ColorUtil = require(game.ReplicatedStorage.Modules.Util.ColorUtil)
local Mount = require(game.ReplicatedStorage.React.Components.PlayerProfile.ExtendedBackgrounds.Mount)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local instances = script:WaitForChild("Instances")
local fn = nil
local playerGui

if isRunning then
	local Players = game:GetService("Players")
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local previewModelContents = playerGui:FindFirstChild("PreviewModelContents") or Instance.new("ScreenGui")
previewModelContents.Enabled = true
previewModelContents.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
previewModelContents.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
previewModelContents.DisplayOrder = 1
previewModelContents.ResetOnSpawn = false
previewModelContents.Parent = playerGui
previewModelContents.Name = "PreviewModelContents"
local v = {
	MOUSE_MAX_ANGLE = 0.3490658503988659,
	MOUSE_SMOOTHING = 8,
	TWEEN_TIME = 0.8,
	SPINS = 1.5,
	MIN_ZOOM_DISTANCE = 30,
	FLOATS = true,
	FLOAT_AMPLITUDE = 0.15,
	FLOAT_SPEED = 1.5,
	MAX_PITCH = 1.3962634015954636
}

local function particleState(folder, enabled: boolean?)
	local max = 0

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if enabled == nil then
			emitter:Emit((emitter:GetAttribute("EmitCount")))
		else
			emitter.Enabled = enabled
		end

		if not (emitter.Lifetime.Max <= max) then
			max = emitter.Lifetime.Max
		end
	end

	return max
end

local v2 = {
	Common = "Blox_Fruit_Click_01",
	Uncommon = "Blox_Fruit_Click_02",
	Rare = "Blox_Fruit_Click_03",
	Legendary = "Blox_Fruit_Click_04",
	Mythical = "Blox_Fruit_Click_Mythical_01"
}
local v3 = {
	playSound = function(p: string)
		local success, result = pcall(function()
			Sound:Play(p)
		end)

		if not success then
			task.spawn(error, `[PreviewModel] sound error: {p}`, result)
		end
	end,
	tweenHost = function(p, p2, p3)
		local v4 = LastInput:Get() == "Touch" and 1.15 or 1.25
		local TweenService = game:GetService("TweenService")
		return (TweenService:Create(p, p2 or TweenInfo.new(0.2, Enum.EasingStyle.Linear), p3 or {
			Size = UDim2.fromScale(v4, v4)
		}))
	end
}
local PreviewModel = {
	HOLDER_NAME = "__ReplicatedSpinnerInstances",
	PREVIEW_MODEL_CONFIG = v,
	TryFindById = function(instance, p: number)
		local match = ItemConfig.match(p)

		if not match:isErr() then
			return instance:FindFirstChild(match:unwrap().Index.DebugLabel)
		end

		match:inspectErr(warn)
		return nil
	end,
	Destroy = function()
		if fn then
			fn()
		end
	end
}

function PreviewModel.new(data)
	PreviewModel.Destroy()
	local maid = Trove.new()
	maid:Add(data.Instance)
	maid:Add(function()
		fn = nil
	end)
	local disableRayEffect = data.DisableRayEffect == true
	local v4 = false
	local host = data.Host
	local instance = data.Instance
	local unwrapped = RarityUtil.matchRarity(data.Rarity):unwrap()
	local v5

	if data.ItemId then
		local ItemConfig2 = require(game.ReplicatedStorage.ItemConfig)
		v5 = ItemConfig2.match(data.ItemId):unwrap()
	else
		v5 = nil
	end

	local profileFullArtPreview = instance:GetAttribute("ProfileFullArtPreview")
	local v6 = v5 and (v5.Index.IdType == "Accessory" or v5.Index.IdType == "ProfileBackground" or profileFullArtPreview) and true or disableRayEffect

	if v5 and profileFullArtPreview then
		local surfaceGui = instance:FindFirstChild("SurfaceGui", true)

		if surfaceGui and surfaceGui:IsA("SurfaceGui") then
			local success, result = pcall(function(...)
				maid:Add(Mount(`{v5.Index.StorageKey} Profile Full Art`, surfaceGui))
			end)

			if not success then
				warn(result)
			end
		end
	end

	local v7 = nil
	local v8 = nil
	local v9 = 0
	local total = 0
	local currentCamera = workspace.CurrentCamera
	local value = 0
	local v10 = {
		Instance = nil,
		Alpha = 0,
		Elapsed = 0
	}
	local v11 = {
		TargetRotX = 0,
		TargetRotY = 0,
		CurrentRotX = 0,
		CurrentRotY = 0,
		Mouse = function()
			if isRunning then
				local Players = game:GetService("Players")
				local mouse = Players.LocalPlayer:GetMouse()
				return {
					X = mouse.X,
					Y = mouse.Y
				}
			else
				local UserInputService = game:GetService("UserInputService")
				local mouseLocation = UserInputService:GetMouseLocation()
				return {
					X = mouseLocation.X,
					Y = mouseLocation.Y
				}
			end
		end
	}

	local function fn2()
		local uDim = UDim2.fromScale(0.4, 0.1)
		local parent = maid:Add(Instance.new("ImageLabel"))
		parent.Image = "rbxassetid://84814021550813"
		parent.BackgroundTransparency = 1
		parent.ImageColor3 = Color3.new(1, 1, 1)
		parent.ScaleType = Enum.ScaleType.Stretch
		parent.AnchorPoint = Vector2.new(0.5, 0)
		parent.Position = UDim2.fromScale(0.5, 0.01)
		parent.Size = UDim2.fromScale(uDim.X.Scale * 0.5, uDim.Y.Scale * 0.5)
		local textLabel = Instance.new("TextLabel")
		textLabel.Rotation = -2
		textLabel.Size = UDim2.fromScale(1, 0.9)
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.Position = UDim2.fromScale(0.5, 0.5)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Highway
		textLabel.TextScaled = true
		textLabel.Text = data.DisplayName
		textLabel.TextColor3 = unwrapped.Color
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = ColorUtil.tuneBrightness(unwrapped.Color, 0.5)
		uIStroke.Thickness = 1
		uIStroke.Transparency = 0
		uIStroke.LineJoinMode = Enum.LineJoinMode.Round
		uIStroke.Parent = textLabel
		textLabel.Parent = parent
		parent.Parent = previewModelContents
		local maid2 = maid
		local TweenService = game:GetService("TweenService")
		maid2:Add(TweenService:Create(parent, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
			Size = uDim
		})):Play()
	end

	local function update(p)
		debug.profilebegin("PreviewModel")
		local v12 = instance:GetAttribute("__Size") * 0.5
		local absolutePosition = host.AbsolutePosition
		local absoluteSize = host.AbsoluteSize
		local v13 = absolutePosition.X + absoluteSize.X / 2
		local v14 = absolutePosition.Y + absoluteSize.Y / 2
		local v15 = math.max(1, currentCamera.ViewportSize.X)
		local v16 = math.max(1, currentCamera.ViewportSize.Y)
		local screenPointToRay = currentCamera:ScreenPointToRay(v13, v14)
		local fieldOfView = math.rad(currentCamera.FieldOfView)
		local v17 = math.atan(math.tan(fieldOfView / 2) * (v15 / v16)) * 2
		local v18 = absoluteSize.X / v15
		local v19 = absoluteSize.Y / v16
		local v20 = v17 * v18
		local v21 = fieldOfView * v19
		local v22 = v12.X / math.tan(v20 / 2)
		local v23 = v12.Y / math.tan(v21 / 2)
		local v24 = v12.Z * 2
		local v25 = math.min(v22, v23)
		local v26 = math.max(v22, v23, v24)

		if v25 >= 1e999 or v26 > 1e999 then
			v25 = 0
			v26 = 5
		end

		local v27 = math.clamp(v25, v25, v26)
		local v28 = screenPointToRay.Origin + screenPointToRay.Direction * v27

		if v.FLOATS then
			v28 += Vector3.new(0, math.sin(total * v.FLOAT_SPEED) * v.FLOAT_AMPLITUDE, 0)
		end

		local unit = (currentCamera.CFrame.Position - v28).Unit
		local v29 = math.atan2(unit.X, unit.Z)
		local v30 = math.clamp(math.asin(unit.Y), -v.MAX_PITCH, v.MAX_PITCH)
		local vector = Vector3.new(math.sin(v29) * math.cos(v30), math.sin(v30), math.cos(v29) * math.cos(v30))
		local cframe = CFrame.new(v28, v28 + vector)

		if not (value < 1) then
			local X = v11.Mouse().X
			local Y = v11.Mouse().Y
			local v31 = (X - v13) / (absoluteSize.X / 2)
			local v32 = (Y - v14) / (absoluteSize.Y / 2)
			v11.targetRotY = math.clamp(v31 * v.MOUSE_MAX_ANGLE, -v.MOUSE_MAX_ANGLE, v.MOUSE_MAX_ANGLE)
			v11.targetRotX = math.clamp(-v32 * v.MOUSE_MAX_ANGLE, -v.MOUSE_MAX_ANGLE, v.MOUSE_MAX_ANGLE)
			v11.CurrentRotX += (v11.targetRotX - v11.CurrentRotX) * math.clamp(v.MOUSE_SMOOTHING * p, 0, 1)
			v11.CurrentRotY += (v11.targetRotY - v11.CurrentRotY) * math.clamp(v.MOUSE_SMOOTHING * p, 0, 1)
		end

		local v31 = cframe * CFrame.Angles(v11.CurrentRotX, v11.CurrentRotY + v9, 0)

		if v31 ~= v31 then
			return
		end

		instance:PivotTo(v31)

		if value < 1 then
			local v32 = total / v.TWEEN_TIME
			local TweenService = game:GetService("TweenService")
			value = TweenService:GetValue(math.clamp(v32, 0, 1), Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			v9 = math.lerp(0, 4.96238898038469, 1 - value)

			if v10.Instance == nil then
				v10.Instance = maid:Add(Instance.new("Highlight"))
				local assert_2 = assert(v10.Instance)
				assert_2.FillColor = Color3.fromRGB()
				v10.Instance.OutlineTransparency = 1
				v10.Instance.FillTransparency = 0
				v10.Instance.Parent = instance
			end

			assert(v10.Instance)

			if value >= 0.9 then
				local TweenService2 = game:GetService("TweenService")
				local alpha = TweenService2:GetValue(
					math.clamp(v10.Elapsed / 0.5, 0, 1),
					Enum.EasingStyle.Exponential,
					Enum.EasingDirection.Out
				)
				v10.Elapsed += p
				v10.Alpha = alpha
				v10.Instance.FillTransparency = v10.Alpha
			end
		end

		if total >= 0.01 then
			if v6 == false then
				local cFrame = CFrame.new(v28, currentCamera.CFrame.Position) * CFrame.new(0, 0, v12.Z + 1)

				if v8 == nil then
					v8 = maid:Add(instances:FindFirstChild("TrianglePart"):Clone())

					for _, emitter in assert((assert(v8):FindFirstChild("Triangles"))):GetChildren() do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, unwrapped.Color),
							ColorSequenceKeypoint.new(1, unwrapped.Color)
						})
						emitter:Emit(1)
					end

					v8.CFrame = cFrame
					v8.Parent = workspace
				end

				if v8 then
					v8.CFrame = cFrame
				end
			end

			local cframe2 = CFrame.new(v28, currentCamera.CFrame.Position)

			if v7 == nil then
				local mythical = instances:FindFirstChild(unwrapped.Name)

				if mythical == nil then
					mythical = instances:FindFirstChild("Mythical")
					warn((`can't find part for rarity: {unwrapped.Name}`))
				end

				assert(mythical)
				v7 = maid:Add(mythical:Clone())
				local assert_3 = assert(v7)
				assert_3.CFrame = cframe2
				v7.Parent = workspace
			end

			if v7 then
				v7.CFrame = cframe2
			end

			if not v4 and v10.Instance and v10.Instance.FillTransparency >= 0.9 then
				v4 = true

				if data.OnFinish then
					data.OnFinish()
				end

				v3.playSound(v2[unwrapped.Name])

				if v7 then
					particleState(v7)
				end

				maid:Add(task.spawn(fn2))
			end
		end

		total += p
		debug.profileend()
	end

	instance.Parent = workspace
	local RunService2 = game:GetService("RunService")
	maid:Add((RunService2.RenderStepped:Connect(update)))
	local v12 = nil
	local v13 = (LastInput:Get() == "Touch" and 1.25 or 1.5) * 0.9
	local UserInputService = game:GetService("UserInputService")
	maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and v7 and not gameProcessed then
			if v12 or value < 1 then
				return
			end

			local v14 = maid:Add(v3.tweenHost(
				data.Host,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
				{
					Size = UDim2.fromScale(v13, v13)
				}
			))
			v12 = v14
			maid:Add(v14.Completed:Connect(function()
				v12 = nil
			end))
			v14:Play()

			if isRunning then
				v3.playSound(v2[unwrapped.Name])
			end

			particleState(v7)
		end
	end))

	fn = function()
		maid:Destroy()
	end

	return PreviewModel.Destroy
end

return PreviewModel