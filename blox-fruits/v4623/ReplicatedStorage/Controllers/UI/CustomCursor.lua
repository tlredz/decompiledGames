local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Promise = require(game.ReplicatedStorage.Modules.Util.Promise)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local CustomCursor = {}
local _ = game.Players.LocalPlayer
local flag = false
local v = false
local v2 = false
local v3 = {}

function CustomCursor:ResetCursorImage(p)
	if p == nil then
		v = false
	end

	UserInputService.MouseIconEnabled = true
	v3.cursor.Visible = false
	v3.overlayHolder.Visible = false
	v3.overlayHolder.OverheatBar.Visible = false
	v3.reloadOverlayHolder.Visible = false
	v3.reloadCursor.Visible = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCursor(p, data)
	p.Image = data.ImageId
	p.Size = data.Size
	p.ImageRectSize = data.ImageRectSize or Vector2.new()
	p.ImageRectOffset = data.ImageRectOffset or Vector2.new()
end

function CustomCursor.SetCursorImage(_, data)
	UserInputService.MouseIconEnabled = false
	v = true

	if data.IsReload then
		setCursor(v3.reloadCursor, data) -- equivalent call inferred; original call site unknown
		v3.reloadOverlayHolder.Visible = true
		v3.reloadCursor.Visible = true
		v3.cursor.Visible = false
		v3.overlayHolder.Visible = false
	else
		setCursor(v3.cursor, data) -- equivalent call inferred; original call site unknown
		v3.reloadOverlayHolder.Visible = false
		v3.reloadCursor.Visible = false

		if not LastInput:IsMobile() then
			v3.cursor.Visible = true
			v3.overlayHolder.Visible = true
		end
	end
end

function CustomCursor.PlayReloadAnimation(_, p)
	if flag then
		return
	end

	flag = true
	local v4 = p.ReloadTime - 0.05

	if p.DoNotSpin then
		v3.reloadOverlayHolder.ReloadingLabel.Visible = true
		local v5 = { Promise.fromEvent(v3.reloadCursor.Changed, function(p2)
				return p2 == "Image"
			end), (Promise.delay(v4)) }
		Promise.any(v5):andThen(function()
			v3.reloadCursor.Rotation = 0
			v3.reloadOverlayHolder.ReloadingLabel.Visible = false
			flag = false

			if LastInput:IsMobile() and not v2 then
				CustomCursor:ResetCursorImage(true)
			end
		end)
	else
		local tween = TweenService:Create(
			v3.reloadCursor,
			TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0),
			{
				Rotation = 359
			}
		)
		local v5 = nil
		tween:Play()
		v3.reloadOverlayHolder.ReloadingLabel.Visible = true
		task.delay(v4 * 0.8, function()
			local rotation = v3.reloadCursor.Rotation
			local v6 = ((math.floor(rotation / 120) + 1) * 120 - rotation) % 360

			if v6 > 180 then
				v6 -= 360
			end

			local rotation2 = rotation + v6
			v5 = TweenService:Create(v3.reloadCursor, TweenInfo.new(v4 * 0.2, Enum.EasingStyle.Cubic), {
				Rotation = rotation2
			})
			v5:Play()
		end)
		local v6 = { Promise.fromEvent(v3.reloadCursor.Changed, function(p2)
				return p2 == "Image"
			end), (Promise.delay(v4)) }
		Promise.any(v6):andThen(function()
			tween:Cancel()
			v5:Cancel()
			v3.reloadCursor.Rotation = 0
			v3.reloadOverlayHolder.ReloadingLabel.Visible = false
			flag = false

			if LastInput:IsMobile() and not v2 then
				CustomCursor:ResetCursorImage(true)
			end
		end)
	end
end

function CustomCursor.StepRotate(_, value)
	v3.cursor.Rotation += value or 9
end

function CustomCursor.ResetRotate(_)
	TweenService:Create(v3.cursor, TweenInfo.new(0.05), {
		Rotation = 0
	}):Play()
end

function CustomCursor.UpdateOverheatBar(_, p)
	local overheatBar = v3.overlayHolder and v3.overlayHolder:FindFirstChild("OverheatBar")

	if overheatBar then
		if p > 0 then
			overheatBar.Fill.Size = UDim2.fromScale(p, 1)
			overheatBar.Visible = true
		else
			overheatBar.Visible = false

			if LastInput:IsMobile() then
				CustomCursor:ResetCursorImage(true)
			end
		end
	end
end

function CustomCursor.OnStart(_)
	local PlayerUtil = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PlayerUtil"))
	PlayerUtil.ScreenReady({ "CustomCursor" }, function(p)
		local v4 = assert(p.CustomCursor, "bad CustomCursor")
		local cursor = v4:WaitForChild("Cursor")
		local overlayHolder = v4:WaitForChild("OverlayHolder")
		cursor.Visible = false
		overlayHolder.Visible = false
		v3.reloadOverlayHolder = v4:WaitForChild("ReloadOverlayHolder")
		v3.reloadCursor = v4:WaitForChild("ReloadCursor")
		v3.overlayHolder = overlayHolder
		v3.cursor = cursor
		local v5 = {
			{ v3.cursor, v3.overlayHolder },
			{ v3.reloadCursor, v3.reloadOverlayHolder }
		}

		local function updatePositions(p2)
			local vector = Vector2.new(p2.Position.X, p2.Position.Y)

			if LastInput:Get() == "Gamepad" then
				vector = UserInputService:GetMouseLocation() - Vector2.new(0, game.GuiService.TopbarInset.Height)
			end

			for _, v6 in v5 do
				local uDim = UDim2.fromOffset(vector.X, vector.Y)
				v6[1].Position = uDim
				v6[2].Position = uDim
				v6[2].Size = v6[1].Size
			end

			if v and not v3.reloadCursor.Visible then
				v3.cursor.Visible = true
				v3.overlayHolder.Visible = true
			end
		end

		local v6 = nil

		if not UserInputService.TouchEnabled then
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Connect(function()
				if v6 then
					updatePositions(v6)
				end
			end)
		end

		local instances = {}

		local function inputChanged(instance, p2)
			if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
				if instance:GetAttribute("OriginallyGPE") or p2 and instance.UserInputType == Enum.UserInputType.Touch or #instances == 2 and instance ~= instances[2] then
					return
				end

				v2 = true
				updatePositions(instance)
			elseif (instance.UserInputType == Enum.UserInputType.MouseMovement or instance.KeyCode == Enum.KeyCode.Thumbstick2) and not v6 then
				v6 = instance
			end
		end

		UserInputService.InputChanged:Connect(inputChanged)
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2) and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition then
				v6 = input
				updatePositions(input)
			end
		end)
		UserInputService.InputEnded:Connect(function(input, _)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				v6 = nil
			end
		end)
		UserInputService.TouchTapInWorld:Connect(function(p2, p3)
			if not p3 then
				local v7 = {
					Position = {
						X = p2.X,
						Y = p2.Y
					}
				}
				v7.Position.Y -= game.GuiService.TopbarInset.Height
				updatePositions(v7)
			end
		end)
		UserInputService.TouchStarted:Connect(function(instance, originallyGPE)
			instance:SetAttribute("OriginallyGPE", originallyGPE)
			table.insert(instances, instance)
		end)
		UserInputService.TouchEnded:Connect(function(otherPart, _)
			local index = table.find(instances, otherPart)

			if index then
				table.remove(instances, index)
			end

			v2 = false
			local overheatBar = v3.overlayHolder:FindFirstChild("OverheatBar")

			if not (flag or overheatBar and overheatBar.Visible) then
				CustomCursor:ResetCursorImage(true)
			end
		end)
	end, (`Init {script.Name}`))
end

return CustomCursor