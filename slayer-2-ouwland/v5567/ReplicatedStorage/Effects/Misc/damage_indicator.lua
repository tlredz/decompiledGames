local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local folder = Instance.new("Folder")
folder.Name = "Dmg_Indicator_Folder"
folder.Parent = workspace.Debree
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.54, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.432, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo3 = TweenInfo.new(0.405, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0)
local tweenInfo4 = TweenInfo.new(0.315, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo5 = TweenInfo.new(0.5850000000000001, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
return function(instance, p: number?, p2: number?)
	if instance == nil or instance.Parent == nil or p == nil then
		return
	end

	local position = instance.Position

	if p2 ~= nil then
		position += Vector3.new(math.random(-p2, p2), math.random(-p2, p2), math.random(-p2, p2))
	end

	if (position - workspace.CurrentCamera.CFrame.Position).Magnitude <= 150 then
		local clone = script.Part:Clone()
		clone.CFrame = CFrame.new(position)
		clone.Parent = folder
		DebrisModule:AddItem(clone, 0.9)
		local v = tostring(p)

		if #v > 5 then
			v = string.sub(v, 1, 6)
		end

		if #v <= 1 then
			v = "0" .. v
		end

		local text = string.sub(v, 0, (math.floor(#v / 2)))
		local text2 = string.sub(v, math.clamp(math.floor(#v / 2) + 1, 0, #v), #v)
		clone.BillboardGui.Frame.Left.Left.TextLabel.Text = text
		clone.BillboardGui.Frame.Left.Right.TextLabel.Text = text
		clone.BillboardGui.Frame.Right.Left.TextLabel.Text = text2
		clone.BillboardGui.Frame.Right.Right.TextLabel.Text = text2
		local v4 = math.random(1, 2) == 1 and -1 or 1
		clone.BillboardGui.Frame.Left.Position = UDim2.new(0.25, 0, -0.85 * v4, 0)
		clone.BillboardGui.Frame.Right.Position = UDim2.new(0.75, 0, 0.85 * v4, 0)
		TweenService:Create(clone.BillboardGui.Frame.Left, tweenInfo, {
			Position = UDim2.new(0.25, 0, 0.5, 0)
		}):Play()
		TweenService:Create(clone.BillboardGui.Frame.Right, tweenInfo, {
			Position = UDim2.new(0.75, 0, 0.5, 0)
		}):Play()
		local color = Color3.fromRGB(255, 0, 0)
		TweenService:Create(clone.BillboardGui.Frame.Left.Left.TextLabel, tweenInfo3, {
			TextColor3 = color
		}):Play()
		TweenService:Create(clone.BillboardGui.Frame.Left.Right.TextLabel, tweenInfo3, {
			TextColor3 = color
		}):Play()
		TweenService:Create(clone.BillboardGui.Frame.Right.Left.TextLabel, tweenInfo3, {
			TextColor3 = color
		}):Play()
		TweenService:Create(clone.BillboardGui.Frame.Right.Right.TextLabel, tweenInfo3, {
			TextColor3 = color
		}):Play()
		local valueChangedConnection = clone.vvv:GetPropertyChangedSignal("Value"):Connect(function()
			local Y = clone.vvv.Value.Y
			clone.BillboardGui.Frame.Left.Left.TextLabel.UIGradient.Rotation = math.clamp(Y - 180, 0, 180)
			clone.BillboardGui.Frame.Left.Right.TextLabel.UIGradient.Rotation = math.clamp(Y, 0, 180)
			clone.BillboardGui.Frame.Right.Right.TextLabel.UIGradient.Rotation = math.clamp(
				-math.clamp(Y - 180, 0, 180),
				-180,
				0
			)
			clone.BillboardGui.Frame.Right.Left.TextLabel.UIGradient.Rotation = math.clamp(-Y, -180, 0)
		end)
		local uDim = UDim2.new(
			clone.BillboardGui.Size.X.Scale * 5,
			clone.BillboardGui.Size.X.Offset * 5,
			clone.BillboardGui.Size.Y.Scale * 5,
			clone.BillboardGui.Size.Y.Offset * 5
		)
		local uDim2 = UDim2.new(
			clone.BillboardGui.Size.X.Scale * 0.37,
			clone.BillboardGui.Size.X.Offset * 0.37,
			clone.BillboardGui.Size.Y.Scale * 0.37,
			clone.BillboardGui.Size.Y.Offset * 0.37
		)
		TweenService:Create(clone.BillboardGui, tweenInfo4, {
			Size = uDim
		}):Play()
		task.delay(0.35, function()
			TweenService:Create(clone.BillboardGui, tweenInfo5, {
				Size = uDim2
			}):Play()
		end)
		task.wait(0.468)

		if clone and clone:FindFirstChild("vvv") then
			TweenService:Create(clone.vvv, tweenInfo2, {
				Value = createVector(0, 360, 0)
			}):Play()
		end

		task.wait(0.432)

		if valueChangedConnection ~= nil and valueChangedConnection.Disconnect ~= nil then
			valueChangedConnection:Disconnect()
		end
	end
end