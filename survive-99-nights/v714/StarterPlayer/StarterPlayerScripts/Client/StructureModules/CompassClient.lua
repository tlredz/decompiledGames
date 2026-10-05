local createVector = vector.create
local CompassClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {
	Fairy = {
		Landmark = "Fairy House",
		Biome = "Fairy",
		Image = "rbxassetid://100416865309538"
	},
	ToolSmith = {
		Landmark = "ToolSmith",
		Image = "rbxassetid://124332924792942"
	},
	Beekeeper = {
		Landmark = "Beekeepers House",
		Biome = "Bees",
		Image = "rbxassetid://97500529690076"
	},
	FurnitureTrader = {
		Landmark = "FurnitureTrader",
		Image = "rbxassetid://82029259276917"
	}
}
local v2 = {}
local v3 = {}
local v4 = nil
local compass = nil
local humanoidRootPart = nil

function CompassClient.AddIconToCompass(p, image, target, maxRange)
	local compass2 = Client.Interface.TopRight.Frame.Compass

	if v2[p] and v2[p].Label.Parent then
		return v2[p].Label
	end

	local clone = compass2.TemplateLabel:Clone()
	clone.Image = image
	clone.Name = tostring(p)
	v2[p] = {
		Label = clone,
		Target = target,
		MaxRange = maxRange
	}
	clone.Parent = compass2
	return clone
end

function CompassClient.RemoveIconFromCompass(p)
	if v2[p] then
		v2[p].Label:Destroy()
		v2[p] = nil
	end
end

function AddShopIcon(p)
	local v5 = v[p]
	CompassClient.AddIconToCompass(p, v5.Image, function()
		if v5.Biome and Client.BiomesClient.GetCurrentBiome() ~= v5.Biome then
			return nil
		end

		local v6 = v3[v5.Landmark]
		return v6 and v6:GetAttribute("Position")
	end)
end

function CompassClient.ShopFound(p)
	AddShopIcon(p)

	if not localPlayer:GetAttribute("CompassFound" .. p) then
		Client.Events.CompassShopFound:FireServer(p)
	end
end

function GetTargetPosition(value)
	if typeof(value) == "function" then
		return value()
	end

	if typeof(value) == "Instance" then
		return value:GetPivot().Position
	end

	return value
end

function LandmarkAdded(p)
	v3[string.split(p.Name, ".")[1]] = p
end

function BodyAdded(instance)
	if instance:GetAttribute("PlayerBody") == localPlayer.UserId then
		return
	end

	CompassClient.AddIconToCompass(instance, "rbxassetid://118534684831798", function()
		local playerByUserId = game.Players:GetPlayerByUserId(instance:GetAttribute("PlayerBody") or 0)

		if not (playerByUserId and playerByUserId:GetAttribute("DeathTime")) then
			return nil
		end

		local parent = instance.Parent

		if not parent or parent.Name ~= "ItemBag" then
			return instance:GetPivot().Position
		end

		local parent2 = parent.Parent
		local character = parent2 and parent2:IsA("Player") and parent2.Character
		return character and character:GetPivot().Position
	end)
end

local v5 = false
Client.Events.RemoveFromCompass:Connect(CompassClient.RemoveIconFromCompass)

function AddCompass(instance)
	if instance:IsDescendantOf(workspace.Structures) and not v5 then
		v5 = true
		task.spawn(function()
			local currentCamera = workspace.CurrentCamera
			game:GetService("RunService")

			while true do
				local lookVector = currentCamera.CFrame.LookVector
				local X = lookVector.X
				local Z = lookVector.Z

				if X * X + Z * Z < 1e-6 then
					local upVector = currentCamera.CFrame.UpVector

					if lookVector.Y > 0 then
						X = -upVector.X
						Z = -upVector.Z
					else
						X = upVector.X
						Z = upVector.Z
					end
				end

				local v6 = math.atan2(X, -Z)

				for _, v7 in ipairs(v4) do
					local v8 = v7[1]
					local v9 = v7[2]

					if v9.Magnitude > 0 then
						local v10 = math.atan2(v9.X, -v9.Z) - v6
						local v11 = math.sin(v10) * 0.46 + 0.5
						local v12 = 0.5 - math.cos(v10) * 0.46
						v8.Visible = true
						v8.Position = UDim2.new(v11, 0, v12, 0)
					else
						v8.Visible = false
					end
				end

				local position = humanoidRootPart and humanoidRootPart.Position

				for k, v7 in pairs(v2) do
					local label = v7.Label

					if label.Parent == nil then
						v2[k] = nil
					else
						local v8 = position and GetTargetPosition(v7.Target)
						local v9 = v8 and (v8 - position) * createVector(1, 0, 1)
						local v10 = not v9 and 0 or v9.Magnitude or 0

						if v10 > 0 and v10 <= (v7.MaxRange or 1e999) then
							local v11 = math.atan2(v9.X, -v9.Z) - v6
							label.Position = UDim2.new(math.sin(v11) * 0.46 + 0.5, 0, 0.5 - math.cos(v11) * 0.46, 0)
							label.Visible = true
						else
							label.Visible = false
						end
					end
				end

				wait(0.05)
			end
		end)
		local topRight = Client.Interface.TopRight
		topRight.Visible = true

		if compass.Visible ~= true then
			topRight:SetAttribute("EnabledSoFar", topRight:GetAttribute("EnabledSoFar") + 1)
			compass.LayoutOrder = topRight:GetAttribute("EnabledSoFar")
		end

		compass.Visible = true
	end
end

function CompassClient.Init()
	task.spawn(function()
		local topRight = Client.Interface.TopRight
		local hideButton = topRight.HideButton
		local flag = true
		hideButton.MouseButton1Down:Connect(function()
			if flag then
				flag = false
				hideButton.TextLabel.Text = "<<"
				topRight.Frame.Visible = false
				topRight.Position = UDim2.new(1.075, 0, 0.026, 0)
			else
				flag = true
				hideButton.TextLabel.Text = ">>"
				topRight.Frame.Visible = true
				topRight.Position = UDim2.new(0.986, 0, 0.066, 0)
			end
		end)
		compass = Client.Interface.TopRight.Frame.Compass
		v4 = {
			{ compass.NorthLabel, createVector(0, 0, -1) },
			{ compass.EastLabel, createVector(1, 0, 0) },
			{ compass.SouthLabel, createVector(0, 0, 1) },
			{ compass.WestLabel, createVector(-1, 0, 0) }
		}
		local map = game.ReplicatedStorage:WaitForChild("Map")

		for _, child in pairs(map:GetChildren()) do
			LandmarkAdded(child)
		end

		map.ChildAdded:Connect(LandmarkAdded)

		for k in pairs(v) do
			local v6 = "CompassFound" .. k

			if localPlayer:GetAttribute(v6) then
				AddShopIcon(k)
			end

			local v8 = k
			localPlayer:GetAttributeChangedSignal(v6):Connect(function()
				if localPlayer:GetAttribute(v6) then
					AddShopIcon(v8)
				end
			end)
		end

		Client.Utility.ForAllTagged("PlayerBody", BodyAdded, CompassClient.RemoveIconFromCompass)

		if not localPlayer.Character then
			localPlayer.CharacterAdded:Wait()
		end

		humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")
		localPlayer.CharacterAdded:Connect(function(character)
			humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		end)
		Client.Utility.ForAllTagged("Compass", AddCompass)
	end)
end

return CompassClient