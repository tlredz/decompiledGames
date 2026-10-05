local CollectionService = game:GetService("CollectionService")
local TextService = game:GetService("TextService")
local localPlayer = game.Players.LocalPlayer
local TekrinnDialogue = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function easeOutQuad(p)
	return math.pow(p - 1, 3) * 2.70158 + 1 + math.pow(p - 1, 2) * 1.70158
end

function getColor(p, list)
	local v = list[1]
	local _ = list[#list]
	local value = v.Value

	for i = 1, #list - 1 do
		if not (list[i].Time <= p and p <= list[i + 1].Time) then
			continue
		end

		local v2 = list[i]
		local v3 = list[i + 1]
		local v4 = (p - v2.Time) / (v3.Time - v2.Time)
		return (v2.Value:lerp(v3.Value, v4))
	end

	return value
end

local function retireTexts(template)
	for _, child in template:GetChildren() do
		if child.Name ~= "letter" then
			continue
		end

		child:SetAttribute("Ending", true)
		game.TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = child.Position + UDim2.new(0, 0, 0, 50),
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		game.Debris:AddItem(child, 0.5)
	end
end

local function doText(items, p)
	local v = p or localPlayer
	local v2 = localPlayer.PlayerGui:FindFirstChild(v.Name .. "KJUI") or script.KJDialogue:Clone()
	local v3 = ""
	local total = 0
	local total2 = 0
	local total3 = 0

	if v2:GetAttribute("Created") then
		v2:SetAttribute("Created", os.clock())
	else
		local template = v2:WaitForChild("Holder"):WaitForChild("Template")
		v2.Holder.Position -= UDim2.new(0, 0, 0, #CollectionService:GetTagged("KJUI") * 100)
		local imageLabel = template:WaitForChild("ImageLabel")
		imageLabel.Position -= UDim2.new(0, 0, 0, 100)
		local imageLabel_2 = template:WaitForChild("ImageLabel")
		imageLabel_2.ImageTransparency = 1
		local name = template:WaitForChild("Name")
		name.Position -= UDim2.new(0, 0, 0, 100)
		local name_2 = template:WaitForChild("Name")
		name_2.TextTransparency = 1
		local name_3 = template:WaitForChild("Name")
		name_3.TextStrokeTransparency = 1
		game.TweenService:Create(
			template:WaitForChild("ImageLabel"),
			TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Position = template:WaitForChild("ImageLabel").Position + UDim2.new(0, 0, 0, 100),
				ImageTransparency = 0
			}
		):Play()
		game.TweenService:Create(
			template:WaitForChild("Name"),
			TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Position = template:WaitForChild("Name").Position + UDim2.new(0, 0, 0, 100),
				TextTransparency = 0,
				TextStrokeTransparency = 0
			}
		):Play()
		task.spawn(function()
			v2:SetAttribute("Created", os.clock())

			repeat
				task.wait()
			until os.clock() - v2:GetAttribute("Created") > 5 or not v2.Parent

			v2.Name = "deleting"
			retireTexts(v2.Holder.Template)
			game.TweenService:Create(
				template:WaitForChild("ImageLabel"),
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
				{
					Position = template:WaitForChild("ImageLabel").Position - UDim2.new(0, 0, 0, 100),
					ImageTransparency = 1
				}
			):Play()
			game.TweenService:Create(
				template:WaitForChild("Name"),
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
				{
					Position = template:WaitForChild("Name").Position - UDim2.new(0, 0, 0, 100),
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}
			):Play()
			task.delay(1, function()
				v2:Destroy()
			end)
		end)
	end

	v2.Parent = localPlayer.PlayerGui
	v2.Enabled = true
	v2.Name = v.Name .. "KJUI"
	v2:AddTag("KJUI")
	local name_4 = v2:WaitForChild("Holder"):WaitForChild("Template"):WaitForChild("Name")
	name_4.Text = v.Name

	for _, item in items do
		v3 ..= item.Text
	end

	retireTexts(v2.Holder.Template)

	for _, item in items do
		local v4 = string.split(item.Text, "")
		local sourceSansBold = item.Bold and Enum.Font.SourceSansBold or item.Italic and Enum.Font.SourceSansItalic or Enum.Font.SourceSans

		for _, v5 in v4 do
			total += TextService:GetTextSize(v5, 25, sourceSansBold, Vector2.new(100, 100)).X
		end
	end

	for _, item in items do
		local v4 = string.split(item.Text, "")
		local sourceSansBold = item.Bold and Enum.Font.SourceSansBold or item.Italic and Enum.Font.SourceSansItalic or Enum.Font.SourceSans

		for _, text in v4 do
			local textSize = TextService:GetTextSize(text, 25, sourceSansBold, Vector2.new(100, 100))
			local textLabel = Instance.new("TextLabel")
			UDim2.new(0.5, total2 - total / 2 // 1, 0.5, 0)
			textLabel.AnchorPoint = Vector2.new(0, 0.5)
			textLabel.Position = UDim2.new(0.5, total2 - total / 2 // 1, 0.5, 10)
			textLabel.Size = UDim2.new(0, textSize.X, 0, textSize.Y)
			textLabel.Text = text
			textLabel.Name = "letter"
			textLabel.Font = sourceSansBold
			textLabel.TextSize = 25
			textLabel.Parent = v2.Holder.Template
			textLabel.BackgroundTransparency = 1
			textLabel.TextStrokeColor3 = item.TextStrokeColor
			textLabel.TextStrokeTransparency = 0
			textLabel.TextStrokeTransparency = 1
			textLabel.TextTransparency = 1
			local v6 = item
			local v8 = total2
			task.delay(total3, function()
				local lastTime = os.clock()

				repeat
					local v9 = math.min((os.clock() - lastTime) / 0.35, 1)
					local v10 = math.min((os.clock() - lastTime) / v6.Shake.Lifetime, 1)
					local uDim = not v6.Shake.Enabled and UDim2.new(0, 0, 0, 0) or UDim2.new(
						0,
						math.random(-v6.Shake.Intensity, v6.Shake.Intensity) * (1 - v10),
						0,
						math.random(-v6.Shake.Intensity, v6.Shake.Intensity) * (1 - v10)
					)
					local textTransparency = 1 - easeOutQuad(v9)
					textLabel.TextStrokeTransparency = (1 - v9) ^ 10
					textLabel.TextTransparency = textTransparency
					textLabel.TextSize = 25 + 25 * textTransparency
					textLabel.TextColor3 = getColor(v9, v6.Color.Keypoints)
					textLabel.Position = UDim2.new(0.5, v8 - total / 2 // 1, 0.5, 0) + uDim
					task.wait()
				until os.clock() - lastTime > math.max(0.35, v6.Shake.Lifetime) or not textLabel or not textLabel:IsDescendantOf(v2) or textLabel:GetAttribute("Ending")

				if textLabel then
					textLabel.TextStrokeTransparency = 0
					textLabel.TextTransparency = 0
					textLabel.TextSize = 25
					textLabel.TextColor3 = v6.Color.Keypoints[#v6.Color.Keypoints].Value
					textLabel.Position = UDim2.new(0.5, v8 - total / 2 // 1, 0.5, 0)
				end
			end)
			total3 += item.TypeSpeed
			total2 += textSize.X
		end
	end
end

function TekrinnDialogue.Speak(p, p2)
	doText(p2, p)
end

return TekrinnDialogue