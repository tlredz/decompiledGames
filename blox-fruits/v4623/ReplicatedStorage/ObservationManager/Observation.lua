local ObjectHighlighter = require(game.ReplicatedStorage:WaitForChild("ObjectHighlighter"))
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = -1
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local ImageUtil = require(game.ReplicatedStorage.Modules.Asset.ImageUtil)
local barsBBG = script.Parent:WaitForChild("BarsBBG")
local renderer = ObjectHighlighter.createRenderer(screenGui)
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("ObservationStep", Enum.RenderPriority.First.Value, function(p)
	renderer:step(p)
end)
local Observation = {}
Observation.__index = Observation

function Observation.model(p, p2)
	local highlighter = ObjectHighlighter.createFromTarget(p)
	local color

	if p2 and p2.Color then
		color = p2.Color
	else
		color = Color3.fromRGB(255, 0, 0)
	end

	highlighter.color = color
	local displayName

	if p2 then
		displayName = p2.DisplayName
	end

	highlighter.displayName = displayName
	renderer:addToStack(highlighter)
	return (setmetatable({
		highlighter = highlighter,
		connections = {}
	}, {
		__index = Observation
	}))
end

function Observation.new(instance, color)
	assert(instance, "Observation requires an existing Character!")
	local humanoid = instance:FindFirstChild("Humanoid")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local energy = instance:FindFirstChild("Energy")
	local dodges = instance:FindFirstChild("Dodges")

	if not humanoid then
		humanoidRootPart = instance
		humanoid = {
			Health = 100,
			MaxHealth = 100
		}
	end

	local v

	if instance:GetAttribute("PlayerClone") and instance:FindFirstChild("Summoner") and instance.Summoner.Value then
		local character = instance.Summoner.Value.Character
		humanoidRootPart = instance.HumanoidRootPart
		humanoid = character:FindFirstChild("Humanoid")
		v = instance
		instance = character
	end

	local isMe = instance == game.Players.LocalPlayer.Character

	if isMe then
		color = Color3.fromRGB(184, 184, 184)
	else
		local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

		if playerFromCharacter and playerFromCharacter:GetAttribute("PlayerColor") then
			color = playerFromCharacter:GetAttribute("PlayerColor")
		end
	end

	local connections = {}
	local clone = barsBBG:Clone()

	if energy and not isMe then
		clone.Energy.Fill.Size = UDim2.new(energy.Value / energy.MaxValue, 0, 1, 0)
		table.insert(connections, energy:GetPropertyChangedSignal("Value"):Connect(function()
			clone.Energy.Fill.Size = UDim2.new(energy.Value / energy.MaxValue, 0, 1, 0)
		end))
	else
		clone.Energy:Destroy()
	end

	if isMe or typeof(humanoid) == "table" then
		clone.HP:Destroy()
	else
		local humanoid2

		if v then
			humanoid2 = v.Humanoid
		else
			humanoid2 = humanoid
		end

		clone.HP.Fill.Size = UDim2.new(humanoid2.Health / humanoid2.MaxHealth, 0, 1, 0)
		table.insert(connections, humanoid2:GetPropertyChangedSignal("Health"):Connect(function()
			clone.HP.Fill.Size = UDim2.new(humanoid2.Health / humanoid2.MaxHealth, 0, 1, 0)
		end))
		table.insert(connections, humanoid2:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			clone.HP.Fill.Size = UDim2.new(humanoid2.Health / humanoid2.MaxHealth, 0, 1, 0)
		end))
	end

	local observationScale = humanoidRootPart.Parent:GetAttribute("ObservationScale") or humanoidRootPart.Size.Y
	clone.Size = UDim2.new(observationScale * 6, 0, observationScale * 6, 0)
	clone.StudsOffsetWorldSpace = Vector3.new(0, -observationScale / 2, 0)
	table.insert(connections, humanoidRootPart:GetPropertyChangedSignal("Size"):Connect(function()
		if humanoidRootPart and humanoidRootPart.Parent and humanoidRootPart.Parent:GetAttribute("ObservationScale") then
			return
		end

		clone.Size = UDim2.new(humanoidRootPart.Size.Y * 6, 0, humanoidRootPart.Size.Y * 6, 0)
		clone.StudsOffsetWorldSpace = Vector3.new(0, -humanoidRootPart.Size.Y / 2, 0)
	end))
	table.insert(connections, humanoidRootPart.Parent:GetAttributeChangedSignal("ObservationScale"):Connect(function()
		local observationScale2 = humanoidRootPart.Parent:GetAttribute("ObservationScale")

		if not observationScale2 then
			return
		end

		clone.Size = UDim2.new(observationScale2 * 6, 0, observationScale2 * 6, 0)
		clone.StudsOffsetWorldSpace = Vector3.new(0, -observationScale2 / 2, 0)
	end))
	local playerFromCharacter = not isMe and game.Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter then
		local CollectionService = game:GetService("CollectionService")

		if CollectionService:HasTag(game.Players.LocalPlayer.Character, "KenUpgrade") then
			if playerFromCharacter:FindFirstChild("Data") and playerFromCharacter.Data:FindFirstChild("Level") then
				humanoid.DisplayName = string.gsub(humanoid.DisplayName, " %[Lv. (%d+)%]", "") .. " [Lv. " .. playerFromCharacter.Data.Level.Value .. "]"
				table.insert(connections, function()
					humanoid.DisplayName = string.gsub(humanoid.DisplayName, " %[Lv. (%d+)%]", "")
				end)
			end

			if dodges and not isMe then
				-- equivalent calls inferred from this helper; original call sites unknown
				local function GetValue()
					if playerFromCharacter:GetAttribute("KenDodgesLeft") and playerFromCharacter:GetAttribute("KenMaxDodges") then
						return (math.clamp(
							playerFromCharacter:GetAttribute("KenDodgesLeft") / playerFromCharacter:GetAttribute("KenMaxDodges"),
							0,
							1
						))
					end

					return 1
				end

				clone.Dodge.Fill.Size = UDim2.new(GetValue(), 0, 1, 0)
				table.insert(
					connections,
					playerFromCharacter:GetAttributeChangedSignal("KenDodgesLeft"):Connect(function()
						clone.Dodge.Fill.Size = UDim2.new(GetValue(), 0, 1, 0)
					end)
				)
				table.insert(
					connections,
					playerFromCharacter:GetAttributeChangedSignal("KenMaxDodges"):Connect(function()
						clone.Dodge.Fill.Size = UDim2.new(GetValue(), 0, 1, 0)
					end)
				)
			else
				clone.Dodge:Destroy()
			end

			task.spawn(function()
				local backpack = playerFromCharacter:WaitForChild("Backpack", 5)

				local function check(tool)
					if tool:IsA("Tool") then
						local holding = tool:FindFirstChild("Holding")

						if holding then
							if not holding:GetAttribute("Connected") then
								holding:SetAttribute("Connected", true)
								table.insert(connections, function()
									holding:SetAttribute("Connected", false)
								end)
								table.insert(connections, holding:GetPropertyChangedSignal("Value"):Connect(function()
									if holding.Value then
										clone.Attacking.Visible = true
										clone.Padding.Size = UDim2.new(0, 0, 0.45, -2)
									else
										clone.Attacking.Visible = false
										clone.Padding.Size = UDim2.new(0, 0, 0.7, -2)
									end
								end))
							end

							if holding.Value then
								clone.Attacking.Visible = true
								clone.Padding.Size = UDim2.new(0, 0, 0.45, -2)
							else
								clone.Attacking.Visible = false
								clone.Padding.Size = UDim2.new(0, 0, 0.7, -2)
							end
						end
					elseif tool.Name == "Rage" and tool:GetAttribute("Enabled") then
						clone.Rage.Visible = true
						clone.Rage.Fill.Size = UDim2.new(math.clamp(tool.Value / 100, 0, 1), 0, 1, 0)
						table.insert(connections, tool.AncestryChanged:Connect(function()
							if not (instance:FindFirstChild("Rage") and instance:FindFirstChild("Rage"):GetAttribute("Enabled")) then
								clone.Rage.Visible = false
							end
						end))
						table.insert(connections, tool:GetAttributeChangedSignal("Enabled"):Connect(function()
							if instance:FindFirstChild("Rage") and instance:FindFirstChild("Rage"):GetAttribute("Enabled") then
								clone.Rage.Visible = true
							else
								clone.Rage.Visible = false
							end
						end))
						table.insert(connections, tool:GetPropertyChangedSignal("Value"):Connect(function()
							if tool.Parent == instance then
								clone.Rage.Fill.Size = UDim2.new(math.clamp(tool.Value / 100, 0, 1), 0, 1, 0)
							end
						end))
					end
				end

				table.insert(connections, instance.ChildAdded:Connect(check))
				local tool = instance:FindFirstChildWhichIsA("Tool")

				if tool then
					check(tool)
				end

				if instance:FindFirstChild("Rage") then
					check(instance:FindFirstChild("Rage"))
				end

				if backpack then
					local function update()
						for _, child in pairs(clone.Hotbar:GetChildren()) do
							if child.Name ~= "UIListLayout" and child.Name ~= "Template" then
								child:Destroy()
							end
						end

						local v4 = {
							M = 0,
							B = 1,
							S = 2,
							G = 3
						}

						for _, tool2 in pairs(backpack:GetChildren()) do
							if not tool2:IsA("Tool") then
								continue
							end

							local layoutOrder = v4[tool2.ToolTip:sub(1, 1)]

							if layoutOrder == nil then
								continue
							end

							local clone2 = clone.Hotbar.Template:Clone()
							local imageForToolInstance = ImageUtil.getImageForToolInstance(tool2, nil)

							if imageForToolInstance then
								clone2.TextLabel:Destroy()
								clone2.Image = imageForToolInstance.Icon.Image
								clone2.ImageRectSize = imageForToolInstance.Icon.ImageRectSize or Vector2.zero
								clone2.ImageRectOffset = imageForToolInstance.Icon.ImageRectOffset or Vector2.zero
							else
								clone2.Image = ""
								clone2.TextLabel.Text = tool2.Name
							end

							clone2.Name = tool2.Name
							clone2.LayoutOrder = layoutOrder
							clone2.Parent = clone.Hotbar
							clone2.Visible = true
						end

						local tool2 = instance:FindFirstChildWhichIsA("Tool")

						if tool2 then
							local layoutOrder = v4[tool2.ToolTip:sub(1, 1)]

							if layoutOrder ~= nil then
								local clone2 = clone.Hotbar.Template:Clone()
								local imageForToolInstance = ImageUtil.getImageForToolInstance(tool2, nil)

								if imageForToolInstance then
									clone2.TextLabel.Text = ""
									clone2.Image = imageForToolInstance.Icon.Image
									clone2.ImageRectSize = imageForToolInstance.Icon.ImageRectSize or Vector2.zero
									clone2.ImageRectOffset = imageForToolInstance.Icon.ImageRectOffset or Vector2.zero
								else
									clone2.Image = ""
									clone2.TextLabel.Text = tool2.Name
								end

								clone2.BackgroundTransparency = 0
								clone2.TextLabel.BorderSizePixel = 2
								clone2.Name = tool2.Name
								clone2.LayoutOrder = layoutOrder
								clone2.Parent = clone.Hotbar
								clone2.Visible = true
							end
						end
					end

					table.insert(connections, backpack.ChildAdded:Connect(update))
					table.insert(connections, backpack.ChildRemoved:Connect(update))
					update()
					clone.Hotbar.Visible = true
				end
			end)
		else
			clone.Dodge:Destroy()
		end
	else
		clone.Dodge:Destroy()
	end

	local highlighter = ObjectHighlighter.createFromTarget(v or instance)
	highlighter.color = color or Color3.fromRGB(255, 0, 0)
	renderer:addToStack(highlighter)
	clone.Parent = humanoidRootPart
	local object = setmetatable({
		highlighter = highlighter,
		bars = clone,
		connections = connections,
		isMe = isMe
	}, {
		__index = Observation
	})

	if typeof(humanoid) ~= "table" then
		table.insert(object.connections, humanoid.Died:Connect(function()
			object:destroy()
		end))

		if v then
			table.insert(object.connections, v:FindFirstChildOfClass("Humanoid").Died:Connect(function()
				object:destroy()
			end))
		end
	end

	return object
end

function Observation:destroy()
	if self.destroyed then
		return
	end

	self.destroyed = true

	for _, connection in next, self.connections, nil do
		if typeof(connection) == "function" then
			pcall(connection)
		else
			connection:Disconnect()
		end
	end

	if self.bars then
		self.bars:Destroy()
	end

	renderer:removeFromStack(self.highlighter)
end

return Observation