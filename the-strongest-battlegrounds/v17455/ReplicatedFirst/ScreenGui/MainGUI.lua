local parent = script.Parent
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local _ = character.PrimaryPart
local magicHealth = parent:FindFirstChild("MagicHealth") or parent:WaitForChild("MagicHealth", 1)
local ult = magicHealth:FindFirstChild("Ult") or magicHealth:WaitForChild("Ult", 1)
local bar = magicHealth.Health.Bar
local currentCamera = workspace.CurrentCamera
local v = false
magicHealth.TextButton.MouseButton1Click:Connect(function()
	local communicate = character:FindFirstChild("Communicate") or character:WaitForChild("Communicate", 5)

	if communicate then
		communicate:FireServer({
			Goal = "KeyPress",
			Key = Enum.KeyCode.G,
			MoveDirection = character.Humanoid.MoveDirection
		})
	end
end)
local textLabel = magicHealth:FindFirstChild("TextLabel") or magicHealth:WaitForChild("TextLabel", 1)
textLabel:GetPropertyChangedSignal("Text"):Connect(function()
	local textLabel2 = textLabel:FindFirstChild("TextLabel")

	if textLabel2 then
		textLabel2.Text = textLabel.Text
	end
end)

local function fn()
	local ultimateName = character:GetAttribute("UltimateName")
	textLabel.Text = character:GetAttribute("IceBoss") and "SUB-ZERO SLASH STORM" or ultimateName

	if textLabel.Text == "SORCERER" then
		magicHealth.Visible = false
	end
end

character:GetAttributeChangedSignal("UltimateName"):Connect(fn)
character:GetAttributeChangedSignal("IceBoss"):Connect(fn)

if textLabel then
	if character:GetAttribute("UltimateName") then
		local ultimateName = character:GetAttribute("UltimateName")
		textLabel.Text = character:GetAttribute("IceBoss") and "SUB-ZERO SLASH STORM" or ultimateName

		if textLabel.Text == "SORCERER" then
			magicHealth.Visible = false
		end
	else
		textLabel.Text = "SELECT CHARACTER"
	end
else
	warn("Didnt find ultname.")
end

local flag = nil

local function fn2()
	if workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable or v or character:FindFirstChild("HideUlt") or character:GetAttribute("Ulted") and (character:GetAttribute("Character") == "Bald" or character:GetAttribute("Character") == "KJ") then
		if not flag then
			flag = true
			magicHealth:TweenPosition(
				UDim2.new(0.5, 0, 1, 100),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Quad,
				1,
				true
			)
		end
	elseif flag then
		magicHealth:TweenPosition(UDim2.new(0.5, 0, 1, -90), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 1, true)
		flag = false
	end
end

local v2 = nil

local function fn3()
	bar:TweenSize(UDim2.new((v2 or localPlayer:GetAttribute("Ultimate")) / 100, 0, 0, 17), nil, nil, 0.4, true)

	if localPlayer:GetAttribute("Ultimate") >= 100 then
		ult.Visible = true
	else
		ult.Visible = false
	end
end

character:GetAttributeChangedSignal("Ulted"):Connect(function(_)
	if not character:GetAttribute("Ulted") or (character:GetAttribute("Character") == "Bald" or character:GetAttribute("Character") == "KJ") then
		return
	end

	if not character:GetAttribute("UltimateTime") then
		return
	end

	local lastTime = tick()
	local v3 = false
	v2 = 100
	fn3()
	v = true
	fn2()
	local childAddedConnection = nil
	childAddedConnection = localPlayer.Backpack.ChildAdded:Connect(function(tool)
		if tick() - lastTime > 10 then
			return childAddedConnection:Disconnect()
		end

		if tool:IsA("Tool") then
			local CollectionService = game:GetService("CollectionService")

			if CollectionService:HasTag(tool, "Ultimate" .. localPlayer.Name) then
				v3 = true
				return childAddedConnection:Disconnect()
			end
		end
	end)

	repeat
		task.wait()
	until v3 or tick() - lastTime > 10

	v = nil
	fn2()

	if childAddedConnection then
		childAddedConnection:Disconnect()
	end

	if tick() - lastTime > 10 then
		v2 = nil
		return fn3()
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 1
	numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		v2 = numberValue.Value * 100
		fn3()
	end)
	local primaryPart = character.PrimaryPart
	local fillChangedConnection = nil
	fillChangedConnection = primaryPart:GetAttributeChangedSignal("fill"):Connect(function()
		if character:GetAttribute("CanCosmic") and not character:FindFirstChild("CosmicTriggered") then
			numberValue.Value = 1
			return
		end

		local fill = primaryPart:GetAttribute("fill")

		if fill and not (fill <= 0) then
			numberValue.Value = fill
			return
		end

		v2 = nil
		numberValue:Destroy()
		numberValue = nil
		fillChangedConnection:Disconnect()
		return fn3()
	end)
end)
localPlayer:GetAttributeChangedSignal("Ultimate"):Connect(fn3)

if (localPlayer:GetAttribute("Ultimate") or 0) >= 100 then
	ult.Visible = true
end

currentCamera:GetPropertyChangedSignal("CameraType"):Connect(fn2)
character:GetAttributeChangedSignal("Ulted"):Connect(fn2)
character.ChildAdded:Connect(fn2)
character.ChildRemoved:Connect(fn2)
bar.Size = UDim2.new((localPlayer:GetAttribute("Ultimate") or 0) / 100, 0, 0, 17)