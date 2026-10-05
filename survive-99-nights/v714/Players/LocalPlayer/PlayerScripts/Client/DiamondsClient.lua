local DiamondsClient = {}
game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local diamondCount = Client.Interface.DiamondCount
local diamonds = nil
local serverTimeNow = workspace:GetServerTimeNow()

function doCountFX(p, p2, p3)
	task.spawn(function()
		Client.Sound.Play("Gem", {
			TimePosition = 0.3
		})
		local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0)
		local color, v

		if p < p2 then
			color = Color3.fromRGB(85, 255, 127)
			v = 1.25
		else
			color = Color3.fromRGB(255, 48, 62)
			v = 0.75
		end

		TweenService:Create(diamondCount.Count, tweenInfo, {
			TextColor3 = color,
			Size = UDim2.new(1.2 * v, 0, 0.7 * v, 0)
		}):Play()
		task.wait(0.1)

		if p3 == serverTimeNow then
			TweenService:Create(diamondCount.Count, tweenInfo2, {
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(1, 0, 0.7, 0)
			}):Play()
		end
	end)
end

function refreshDiamondCount()
	if not localPlayer:GetAttribute("Diamonds") then
		diamondCount.Count.Text = "0"
		return
	end

	diamondCount.Count.Text = tostring(localPlayer:GetAttribute("Diamonds"))

	if diamonds ~= localPlayer:GetAttribute("Diamonds") then
		serverTimeNow = workspace:GetServerTimeNow()

		if diamonds == nil then
			diamonds = localPlayer:GetAttribute("Diamonds")
		else
			diamondCount.Visible = true
			doCountFX(diamonds, localPlayer:GetAttribute("Diamonds"), serverTimeNow)
			local v = serverTimeNow
			task.spawn(function()
				task.wait(30)

				if serverTimeNow == v then
					diamondCount.Visible = false
				end
			end)
		end
	end

	diamonds = localPlayer:GetAttribute("Diamonds")
end

game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local _ = game.Players.LocalPlayer
local uDim = UDim2.new(0.01, 0, 0.98, 0)

function CreateDiamondEffect(clone)
	local v

	if clone then
		v = 0
	else
		v = 3
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		clone = ReplicatedStorage2.Assets.Alec.FakeDiamond:Clone()
		local currentCamera2 = workspace.CurrentCamera
		local viewportSize = currentCamera2.ViewportSize
		local screenPointToRay = currentCamera2:ScreenPointToRay(viewportSize.X / 2, viewportSize.Y * 0.6)
		local v2 = screenPointToRay.Origin + screenPointToRay.Direction * 13

		if clone:IsA("Model") and clone.PrimaryPart then
			clone:SetPrimaryPartCFrame(CFrame.new(v2))
		elseif clone:IsA("BasePart") then
			clone.CFrame = CFrame.new(v2)
		end
	end

	local position

	if clone:IsA("Model") and clone.PrimaryPart then
		position = clone.PrimaryPart.Position
	elseif clone:IsA("BasePart") then
		position = clone.Position
	else
		return
	end

	local worldToScreenPoint = currentCamera:WorldToScreenPoint(position)
	local v2 = 1 / (position - currentCamera.CFrame.Position).Magnitude
	local clone2 = clone:Clone()
	clone2.Name = "DiamondEffect"

	if clone2:IsA("Model") then
		for _, part in pairs(clone2:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Anchored = false
			part.Size *= v2
			part.Massless = true
		end

		if clone2.PrimaryPart then
			clone2.PrimaryPart.Anchored = true
		end
	else
		clone2.CanCollide = false
		clone2.CanTouch = false
		clone2.CanQuery = false
		clone2.Anchored = true
		clone2.Size *= v2
		clone2.Massless = true
	end

	clone2.Parent = workspace
	local viewportSize = currentCamera.ViewportSize
	local v3 = worldToScreenPoint.X / viewportSize.X
	local v4 = worldToScreenPoint.Y / viewportSize.Y
	local v5 = uDim.X.Scale + uDim.X.Offset / viewportSize.X
	local v6 = uDim.Y.Scale + uDim.Y.Offset / viewportSize.Y
	local lastTime = tick()
	local v7 = 0
	Debris:AddItem(clone2, v + 1.1 + 1)
	task.spawn(function()
		while true do
			RunService.RenderStepped:Wait()
			local v8 = tick() - lastTime
			local v9 = math.min(math.max(0, v8 - v) / 1.1, 1)
			local v10 = v8 < v and 0 or v9
			local v11 = math.pow(v10, 4)
			local currentCamera2 = workspace.CurrentCamera
			local viewportSize2 = currentCamera2.ViewportSize
			local v12 = v3 + (v5 - v3) * v11
			local v13 = v4 + (v6 - v4) * v11
			local screenPointToRay = currentCamera2:ScreenPointToRay(v12 * viewportSize2.X, v13 * viewportSize2.Y)
			local v14 = screenPointToRay.Origin + screenPointToRay.Direction * 1
			v7 = v8 * 3 * 3.141592653589793 * 2

			if clone2:IsA("Model") and clone2.PrimaryPart then
				local unit = (currentCamera2.CFrame.Position - v14).Unit
				clone2:SetPrimaryPartCFrame(CFrame.lookAt(v14, v14 + unit) * CFrame.Angles(0, v7, 0))
			elseif clone2:IsA("BasePart") then
				local unit = (currentCamera2.CFrame.Position - v14).Unit
				clone2.CFrame = CFrame.lookAt(v14, v14 + unit) * CFrame.Angles(0, v7, 0)
			end

			if v10 > 0.8 and v <= v8 then
				local transparency = (v10 - 0.8) / 0.2

				if clone2:IsA("Model") then
					for _, part in pairs(clone2:GetDescendants()) do
						if part:IsA("BasePart") and part.Transparency < 1 then
							part.Transparency = transparency
						end
					end
				elseif clone2.Transparency < 1 then
					clone2.Transparency = transparency
				end
			end

			if not (v10 >= 1 and v + 1.1 <= v8) then
				continue
			end

			clone2:Destroy()
			break
		end
	end)
end

local instances = {}

function DiamondsClient.DiamondEffect(instance)
	if instance and instance.PrimaryPart and not table.find(instances, instance) then
		table.insert(instances, instance)
		task.spawn(function()
			CreateDiamondEffect(instance)
		end)
	end
end

Client.Events.DiamondVisuals:Connect(function(p)
	if ReplicatedStorage:GetAttribute("DoubleDiamonds") then
		Client.PopUpUI.AddPopUp("awarded " .. p * 2 .. " diamonds!", "diamond")
		Client.PopUpUI.AddAdminAbuseMessage("2x Diamond Weekend!", "Diamond", Color3.fromRGB(0, 251, 255), 6)
	else
		Client.PopUpUI.AddPopUp("awarded " .. p .. " diamonds!", "diamond")
	end

	for _ = 1, p do
		CreateDiamondEffect()
		wait(0.175)
	end
end)

function DiamondsClient.Init()
	diamondCount.Visible = false
	refreshDiamondCount()
	connections()
end

function connections()
	Client.Events.DiamondsClaimed:Connect(function(_, _)
		diamondCount.Visible = true
	end)
	localPlayer.AttributeChanged:Connect(function(p)
		if p == "Diamonds" then
			task.spawn(function()
				wait(1.2)
				refreshDiamondCount()
			end)
		end
	end)
end

return DiamondsClient