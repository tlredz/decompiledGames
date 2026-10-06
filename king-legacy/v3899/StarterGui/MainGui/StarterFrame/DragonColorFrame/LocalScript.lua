local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

if not localPlayer:FindFirstChild("DataLoaded") then
	repeat
		wait(0.5)
	until localPlayer:FindFirstChild("DataLoaded")
end

local playerStats = localPlayer:WaitForChild("PlayerStats")
local parent = script.Parent
local TweenService = game:GetService("TweenService")
local colorsScrollingFrame = parent.ColorsScrollingFrame
local previewFrame = parent.PreviewFrame
local minus = previewFrame.Minus
local plus = previewFrame.Plus
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local DragToRotateViewportFrame = require(game.ReplicatedStorage.Chest.Modules:WaitForChild("DragToRotateViewportFrame"))
local TitleColorModule = require(ReplicatedStorage.Chest.Modules.TitleModule.TitleColorModule)
local name = "Head"
local folder = nil
task.spawn(function()
	local uIGradient = previewFrame.UIGradient

	while true do
		if previewFrame.Visible then
			local v = task.wait() * 60
			uIGradient.Rotation = (uIGradient.Rotation + v * 1) % 360
		else
			task.wait()
			previewFrame:GetPropertyChangedSignal("Visible"):Wait()
		end
	end
end)

function UpdateColorScrolling()
	local uIGridLayout = parent.ColorsScrollingFrame.UIGridLayout
	uIGridLayout.CellSize = UDim2.new(
		0,
		(colorsScrollingFrame.AbsoluteSize.X - colorsScrollingFrame.ScrollBarThickness) * 1,
		0,
		(colorsScrollingFrame.AbsoluteSize.Y - colorsScrollingFrame.ScrollBarThickness) * 0.2857142857142857
	)
	colorsScrollingFrame.CanvasSize = UDim2.new(
		0,
		uIGridLayout.AbsoluteContentSize.X,
		0,
		uIGridLayout.AbsoluteContentSize.Y
	)
end

function UpdateColors()
	for k, v in pairs(TitleColorModule) do
		local clone = script.ColorFrame:Clone()
		clone.Name = k
		clone.TitleName.Text = k
		clone.TitleInfo.Text = v.Lore
		clone.TitleName.TextColor3 = v.Color
		clone.LayoutOrder = v.Obtain or 0
		local color = k
		clone.Equip.MouseButton1Click:Connect(function()
			if ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("ChangeDragonColor", {
				Selected = name,
				Color = color
			}) then
				_G.ClickFrameEffect({
					Sound = true,
					Sound2 = true
				})
				clone.Equip.Size = UDim2.new(0.345, 0, 0.45999999999999996, 0)
				TweenService:Create(
					clone.Equip,
					TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
					{
						Size = UDim2.new(0.44999999999999996, 0, 0.6000000000000001, 0)
					}
				):Play()
				UpdateUnlockedAndEquippedColors()
			end
		end)
		local v4 = clone
		clone.Equip.MouseEnter:Connect(function()
			v4.Equip.Size = UDim2.new(0.3, 0, 0.4, 0)
			TweenService:Create(v4.Equip, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = UDim2.new(0.345, 0, 0.45999999999999996, 0)
			}):Play()
		end)
		local v5 = clone
		clone.Equip.MouseLeave:Connect(function()
			TweenService:Create(v5.Equip, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = UDim2.new(0.3, 0, 0.4, 0)
			}):Play()
		end)
		clone.Parent = parent.ColorsScrollingFrame
	end
end

local v = {
	Armor = Color3.fromRGB(248, 248, 248),
	Eyes = Color3.fromRGB(218, 133, 65),
	Flame = Color3.fromRGB(180, 108, 54),
	Horn = Color3.fromRGB(226, 155, 64),
	Body = Color3.fromRGB(255, 0, 0),
	Head = Color3.fromRGB(255, 0, 0),
	Fur = Color3.fromRGB(16, 6, 36)
}

function UpdateUnlockedAndEquippedColors()
	local v2 = HttpService:JSONDecode(playerStats.DragonColors.Value)[name]
	local v3 = game.ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("GetTitleColors")

	if not v3 then
		return
	end

	for _, image in pairs(colorsScrollingFrame:GetChildren()) do
		if not image:IsA("ImageLabel") then
			continue
		end

		local v4 = TitleColorModule[image.Name]

		if not v4 then
			continue
		end

		if (v4.Obtain or 0) <= v3 then
			image.Equip.Visible = true
			image.Equip.Text = "Equip"

			if v2 and v2 == image.Name then
				image.Equip.Text = "Equipped"
			end
		else
			image.Equip.Visible = false
		end
	end

	if folder then
		local HttpService2 = game:GetService("HttpService")
		local jSONDecode = HttpService2:JSONDecode(playerStats.DragonColors.Value)

		for _, part in pairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			local colorType = part:GetAttribute("ColorType")

			if not colorType then
				continue
			end

			local v4 = jSONDecode[colorType]

			if v4 then
				local v5 = TitleColorModule[v4]

				if v5 then
					part.Color = v5.Color
				end
			else
				local color = v[colorType]

				if color then
					part.Color = color
				end
			end
		end
	end
end

local v2 = {
	Head = true,
	Armor = true,
	Eyes = true,
	Flame = true,
	Fur = true,
	Horn = true,
	Body = true
}
local uDim = UDim2.new(1, 0, 0.125, 0)
local uDim2 = UDim2.new(1.15, 0, 0.14375, 0)
local uDim3 = UDim2.new(1.5, 0, 0.1875, 0)

function UpdateButtonSize()
	for _, button in pairs(parent.ButtonFrame:GetChildren()) do
		if not (button:IsA("TextButton") and v2[button.Name]) then
			continue
		end

		if name == button.Name then
			button.Size = uDim2
			TweenService:Create(
				button,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Size = uDim3
				}
			):Play()
		else
			TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = uDim
			}):Play()
		end
	end
end

local v3 = nil

for _, button in pairs(parent.ButtonFrame:GetChildren()) do
	if not (button:IsA("TextButton") and v2[button.Name]) then
		continue
	end

	local v4 = button
	button.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true
		})
		name = v4.Name
		UpdateButtonSize()
		UpdateUnlockedAndEquippedColors()
	end)
	local v5 = button
	button.MouseEnter:Connect(function()
		v5.Size = uDim
		TweenService:Create(v5, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = uDim2
		}):Play()
	end)
	local v6 = button
	button.MouseLeave:Connect(function()
		if name == v6.Name then
			TweenService:Create(v6, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = uDim2
			}):Play()
		else
			TweenService:Create(v6, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = uDim
			}):Play()
		end
	end)
end

UpdateColors()
UpdateColorScrolling()
UpdateButtonSize()
parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateColorScrolling()
end)
parent.CloseButton.MouseButton1Click:Connect(function()
	_G.NPCTalk = false
	parent.Visible = false
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
end)
parent.CloseButton.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = parent.CloseButton,
		ZIndex = 5,
		Size = UDim2.fromScale(0.85, 0.85),
		Circle = true
	})
	parent.CloseButton.Size = UDim2.new(0.11, 0, 0.11, 0)
	TweenService:Create(parent.CloseButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.165, 0, 0.165, 0)
	}):Play()
end)
parent.CloseButton.MouseLeave:Connect(function()
	TweenService:Create(parent.CloseButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.11, 0, 0.11, 0)
	}):Play()
end)
local uDim4 = UDim2.new(0.225, 0, 0.088, 0)
local uDim5 = UDim2.new(0.25875, 0, 0.10119999999999998, 0)
local uDim6 = UDim2.new(0.3375, 0, 0.132, 0)
parent.Preview.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	parent.Preview.Size = uDim5
	TweenService:Create(
		parent.Preview,
		TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Size = uDim6
		}
	):Play()
	previewFrame.Visible = not previewFrame.Visible
end)
parent.Preview.MouseEnter:Connect(function()
	parent.Preview.Size = uDim4
	TweenService:Create(parent.Preview, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = uDim5
	}):Play()
end)
parent.Preview.MouseLeave:Connect(function()
	TweenService:Create(parent.Preview, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = uDim4
	}):Play()
end)
previewFrame.CloseButton.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	previewFrame.Visible = false
end)
previewFrame.CloseButton.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = previewFrame.CloseButton,
		ZIndex = 10,
		Size = UDim2.fromScale(0.85, 0.85),
		Circle = true
	})
	previewFrame.CloseButton.Size = UDim2.new(0.133, 0, 0.167, 0)
	TweenService:Create(previewFrame.CloseButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.1995, 0, 0.2505, 0)
	}):Play()
end)
previewFrame.CloseButton.MouseLeave:Connect(function()
	TweenService:Create(previewFrame.CloseButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.133, 0, 0.167, 0)
	}):Play()
end)
minus.MouseButton1Click:Connect(function()
	if not (folder and v3) then
		return
	end

	minus.Size = UDim2.new(0.192, 0, 0.192, 0)
	TweenService:Create(minus, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0), {
		Size = UDim2.new(0.256, 0, 0.256, 0)
	}):Play()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	folder:SetAttribute("Dist", (math.max((folder:GetAttribute("Dist") or 1) - 0.1, 1)))
	v3:Rotate(0, 0)
end)
minus.MouseEnter:Connect(function()
	minus.Size = UDim2.new(0.128, 0, 0.128, 0)
	TweenService:Create(minus, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.192, 0, 0.192, 0)
	}):Play()
end)
minus.MouseLeave:Connect(function()
	TweenService:Create(minus, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.128, 0, 0.128, 0)
	}):Play()
end)
plus.MouseButton1Click:Connect(function()
	if not (folder and v3) then
		return
	end

	plus.Size = UDim2.new(0.192, 0, 0.192, 0)
	TweenService:Create(plus, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0), {
		Size = UDim2.new(0.256, 0, 0.256, 0)
	}):Play()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	folder:SetAttribute("Dist", (math.min((folder:GetAttribute("Dist") or 1) + 0.1, 4)))
	v3:Rotate(0, 0)
end)
plus.MouseEnter:Connect(function()
	plus.Size = UDim2.new(0.128, 0, 0.128, 0)
	TweenService:Create(plus, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.192, 0, 0.192, 0)
	}):Play()
end)
plus.MouseLeave:Connect(function()
	TweenService:Create(plus, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.128, 0, 0.128, 0)
	}):Play()
end)

function ShowDragon()
	local camera = Instance.new("Camera")
	previewFrame.ViewportFrame.CurrentCamera = camera
	local clone = ReplicatedStorage.Chest.Etc.Dragon:Clone()
	clone.Parent = previewFrame.ViewportFrame.WorldModel
	local v4 = DragToRotateViewportFrame.New(previewFrame.ViewportFrame)
	v4:SetModel(clone)
	v4.MouseMode = "Default"
	clone.Parent = previewFrame.ViewportFrame.WorldModel
	local track = clone.Humanoid.Animator:LoadAnimation(clone.Fly)
	track.Looped = true
	track:Play()
	v3 = v4
	previewFrame.ViewportFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local changedConnection = nil
			v4:BeginDragging()
			changedConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					changedConnection:Disconnect()
					changedConnection = nil
					v4:StopDragging()
				end
			end)
		end
	end)
	folder = clone
end

ShowDragon()
UpdateUnlockedAndEquippedColors()
parent:WaitForChild("ResetColor").MouseButton1Click:Connect(function()
	if ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("ResetDragonColor", {}) then
		UpdateUnlockedAndEquippedColors()
	end
end)