local localPlayer = game.Players.LocalPlayer
local Info = require(game.ReplicatedStorage.Info)
local accessoriesSF = script.Parent.AccessoriesSF
local parent = script.Parent
local aurasSF = script.Parent.AurasSF
local frame = accessoriesSF.Frame
local frame2 = parent.TitlesSF.Frame
frame2.Parent = script
frame.Parent = script
localPlayer:WaitForChild("LoadedData")
wait()
localPlayer:WaitForChild("GamepassesLoaded", 5)

if not localPlayer:GetAttribute("AllowedTitles") then
	local lastTime = tick()

	repeat
		task.wait()
	until tick() - lastTime > 5 or localPlayer:GetAttribute("AllowedTitles")
end

local cosmeticProducts = Info.CosmeticProducts

function shared.cosgui()
	local parent2 = parent.Parent

	if not parent2.Enabled then
		Info.hideGUI(script.Parent, true)
		shared.virtualcursor(script.Parent.Parent)
	end

	parent2.Enabled = not parent2.Enabled
end

local clone = table.clone(Info.Cosmetics)

for k, v in pairs(clone) do
	if v[1] ~= "Special Stuff" or Info.Special[localPlayer.UserId] then
		continue
	end

	table.remove(clone, k)
	break
end

local v = {}

local function fn(p, list)
	local v2 = "<font color=\"rgb(%s, %s, %s)\">%s</font>"
	local v3 = 255
	local v4 = 101
	local v5 = 101
	local v6 = false
	local v7

	if list[2] == 10000000000 then
		v7 = "<font color=\"rgb(255, 216, 19)\">ONLY YOURS</font>"
	elseif list[2] == 100000000000 then
		v7 = "<font color=\"rgb(156, 182, 255)\">THE HUNT</font>"
	elseif list[2] > 1000000 then
		v7 = "<font color=\"rgb(255, 216, 19)\">VIP ONLY</font>"
	elseif list[2] == 1000000 then
		v7 = "<font color=\"rgb(169, 255, 176)\">GROUP ONLY</font>"
	else
		local v8 = localPlayer:GetAttribute("CosmeticGamepass") and list[5]
		local cosmetics = localPlayer:GetAttribute("Cosmetics") or "[]"
		local HttpService = game:GetService("HttpService")
		local v9 = rawget(HttpService:JSONDecode(cosmetics), list[1])

		if (localPlayer:GetAttribute("TotalKillsFrb") or 0) >= list[2] or v8 or v9 then
			local TweenService = game:GetService("TweenService")
			TweenService:Create(p.ImageLabel, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageColor3 = Color3.new(1, 1, 1)
			}):Play()
			v3 = 143
			v4 = 204
			v5 = 140
		elseif not v8 then
			p.ImageLabel.ImageColor3 = Color3.new(0, 0, 0)
			v6 = true
		end

		v7 = string.format(v2, v3, v4, v5, "%s")
	end

	if not v6 then
		if localPlayer.Character:GetAttribute("WC_" .. string.gsub(list[1], " ", "")) then
			local TweenService = game:GetService("TweenService")
			TweenService:Create(p.ImageLabel, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				ImageColor3 = Color3.new(1, 1, 1)
			}):Play()
		else
			local TweenService = game:GetService("TweenService")
			TweenService:Create(p.ImageLabel, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				ImageColor3 = Color3.new(0.35, 0.35, 0.35)
			}):Play()
		end
	end

	if list[3] then
		p.ImageLabel.Image = list[3]
	else
		p.ImageLabel.Image = "rbxassetid://16523852699"
	end

	if list[2] <= 0 then
		p.Info.Info.Text = string.format(v7, "FREE")
	else
		p.Info.Info.Text = string.format(v7, list[2] .. " KILLS")
	end
end

for _, v2 in pairs(clone) do
	local clone2 = frame:Clone()
	table.insert(v, { clone2, v2 })
	fn(clone2, v2)
	clone2.Info.Text = string.format("<font size=\"30\">%s</font>", v2[1])
	local v3 = v2
	clone2.ImageButton.MouseButton1Click:Connect(function()
		local character = localPlayer.Character
		local communicate = character and character:FindFirstChild("Communicate")

		if communicate then
			shared.sfx({
				SoundId = "rbxassetid://6895079853",
				Parent = workspace,
				Volume = 0.5
			}):Play()
			communicate:FireServer({
				Goal = "Wear Cosmetic",
				cosmetic = v3[1]
			})
		end
	end)
	clone2.Parent = v2[4] == "cosmetic" and accessoriesSF or aurasSF
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fn2()
	for _, v2 in pairs(v) do
		fn(v2[1], v2[2])
	end
end

localPlayer:GetAttributeChangedSignal("TotalKillsFrb"):Connect(fn2)
localPlayer:GetAttributeChangedSignal("Update"):Connect(fn2)
localPlayer:GetAttributeChangedSignal("HandlerLoaded"):Connect(fn2)
localPlayer:GetAttributeChangedSignal("CosmeticGamepass"):Connect(fn2)

for _, v2 in pairs(v) do
	fn(v2[1], v2[2])
end

for _, guiObject in pairs(parent:GetChildren()) do
	if guiObject:IsA("ScrollingFrame") then
		local uIGridLayout = guiObject:FindFirstChildOfClass("UIGridLayout") or guiObject:FindFirstChildOfClass("UIListLayout")
		guiObject.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
		local v2 = guiObject
		uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			v2.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
		end)
	elseif guiObject:IsA("TextButton") then
		local v2 = guiObject
		guiObject.MouseButton1Click:Connect(function()
			local lower = string.sub(v2.Text, 2, #v2.Text):lower()
			local child = parent:FindFirstChild(string.sub(v2.Text, 1, 1):upper() .. lower .. "SF")

			for i, scrollingFrame in pairs(parent:GetChildren()) do
				if scrollingFrame:IsA("ScrollingFrame") and scrollingFrame ~= child then
					scrollingFrame.Visible = false
				end
			end

			if not child.Visible then
				child.Visible = true
				shared.sfx({
					SoundId = "rbxassetid://15675032796",
					Parent = workspace,
					Volume = 0.5
				}):Play()
			end
		end)
	end
end

local function fn3()
	local cosmetics = localPlayer:GetAttribute("Cosmetics")
	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(cosmetics)
	local count = 0
	local cosmetics2 = {}

	for _, cosmetic in pairs(Info.Cosmetics) do
		if localPlayer:GetAttribute("CosmeticGamepass") and cosmetic[5] or not ((localPlayer:GetAttribute("TotalKillsFrb") or 0) < cosmetic[2]) or jSONDecode[cosmetic[1]] or not (cosmetic[2] < 100000) then
			continue
		end

		count += 1
		table.insert(cosmetics2, cosmetic)
	end

	return count, cosmetics2
end

local function fn4()
	local titlesSF = parent.TitlesSF

	for _, child in pairs(titlesSF:GetChildren()) do
		if not (child:IsA("UIGridLayout") or child:IsA("UIListLayout")) then
			child:Destroy()
		end
	end

	local v2 = fn3()

	for _, cosmeticProduct in pairs(cosmeticProducts) do
		if not cosmeticProduct.button then
			continue
		end

		if cosmeticProduct.count <= v2 then
			cosmeticProduct.button.Visible = true
		else
			cosmeticProduct.button.Visible = false
		end
	end

	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(localPlayer:GetAttribute("AllowedTitles") or "[]")
	local HttpService2 = game:GetService("HttpService")
	local jSONDecode2 = HttpService2:JSONDecode(localPlayer:GetAttribute("StoredTitles"))

	for _, text in pairs(jSONDecode2 or "[]") do
		local clone2 = frame2:Clone()
		clone2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
			ColorSequenceKeypoint.new(
				1,
				jSONDecode[text] and Color3.fromRGB(125, 255, 129) or Color3.fromRGB(255, 157, 157)
			)
		})
		clone2.Title.Text = text
		clone2.Description.Text = Info.TitleDescriptions[text] or "A title specifically tailored for you and you only! One-of-one."

		if text == "Rank Title" then
			clone2.Title.Text = string.format("Rank Title  —  %s", localPlayer:GetAttribute("OGRankTitle") or "N/A")
		elseif text == "Duel Title" then
			clone2.Title.Text = string.format("Duel Title  —  %s", localPlayer:GetAttribute("OGDuelTitle") or "N/A")
		end

		clone2.Parent = titlesSF
		local v4 = text
		clone2.Button.MouseButton1Click:Connect(function()
			shared.sfx({
				SoundId = "rbxassetid://552900451",
				Parent = workspace,
				Volume = 0.5
			}):Play()
			local allowedTitles = localPlayer:GetAttribute("AllowedTitles")
			local HttpService3 = game:GetService("HttpService")
			local jSONDecode3 = HttpService3:JSONDecode(allowedTitles)
			jSONDecode3[v4] = not jSONDecode3[v4]
			local v6 = {}

			for k, v7 in pairs(jSONDecode3) do
				if typeof(v7) == "string" then
					jSONDecode3[k] = nil
				else
					v6[k] = v7
				end
			end

			local HttpService4 = game:GetService("HttpService")
			local jSONEncode = HttpService4:JSONEncode(v6)
			clone2.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
				ColorSequenceKeypoint.new(1, v6[v4] and Color3.fromRGB(125, 255, 129) or Color3.fromRGB(255, 157, 157))
			})
			clone2.Button.BackgroundTransparency = 0.4
			local TweenService = game:GetService("TweenService")
			TweenService:Create(clone2.Button, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
			localPlayer.Character.Communicate:FireServer({
				Goal = "Update Titles",
				Title = jSONEncode
			})
		end)
	end
end

localPlayer:GetAttributeChangedSignal("StoredTitles"):Connect(fn4)
localPlayer:GetAttributeChangedSignal("OGRankTitle"):Connect(fn4)
localPlayer:GetAttributeChangedSignal("OGDuelTitle"):Connect(fn4)
fn4()
local bulk = accessoriesSF.Parent.Bulk
local imageButton = bulk.ImageButton
imageButton.Name = "GP"
imageButton.Parent = script

for _, cosmeticProduct in pairs(cosmeticProducts) do
	local id = cosmeticProduct.id
	local MarketplaceService = game:GetService("MarketplaceService")
	local productInfo = MarketplaceService:GetProductInfo(id, Enum.InfoType.Product)
	local clone2 = imageButton:Clone()
	clone2.Visible = false
	clone2.Parent = bulk
	clone2.Spin.Text = string.format([[
<font size="45">%s</font>
<font size="35" color="rgb(158, 255, 174)">%s ROBUX</font>]], cosmeticProduct.count .. " " .. (cosmeticProduct.count > 1 and "SPINS" or "SPIN"), productInfo.PriceInRobux)
	clone2.Image = "rbxassetid://" .. 17859138719
	clone2.MouseButton1Click:Connect(function()
		if not localPlayer:GetAttribute("CanBuyRandom") then
			return
		end

		localPlayer.Character.Communicate:FireServer({
			Goal = "Prompt Cosmetic",
			Id = id
		})
	end)
	cosmeticProduct.button = clone2
end

fn4()

for _, v2 in pairs(v) do
	fn(v2[1], v2[2])
end

localPlayer:GetAttributeChangedSignal("Cosmetics"):Connect(function()
	fn2() -- equivalent call inferred; original call site unknown
	fn4()
end)
local main = script.Parent.Parent.Main
local parent2 = script.Parent
local v2 = {}
local v3 = {
	53,
	25,
	73,
	29,
	15,
	329
}
localPlayer:GetAttributeChangedSignal("NewCosmetic"):Connect(function()
	parent2.Visible = false

	if not parent.Parent.Enabled and shared.cosgui then
		shared.cosgui()
	end

	local newCosmetic = localPlayer:GetAttribute("NewCosmetic")
	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(newCosmetic)
	local v4 = {}

	for _ = 1, #jSONDecode do
		local _, v5 = fn3()
		table.insert(v4, v5)
	end

	for k, v5 in pairs(jSONDecode) do
		local v6 = v4[k]
		main.ImageLabel.Rotation = 0

		for _, v7 in pairs(v2) do
			v7.brake = true
		end

		table.clear(v2)

		for _, child in pairs(main.ImageLabel:GetChildren()) do
			local imageLabel = child:FindFirstChildOfClass("ImageLabel")

			if imageLabel then
				imageLabel.Image = v6[math.random(#v6)][3]
			end
		end

		main.Visible = true
		local v7 = -(-1440 + 52 * math.random(#v3))
		local v8 = nil

		for _, v9 in pairs(v6) do
			if v9[1] == v5 then
				v8 = v9
			end
		end

		main.ImageLabel[v7].ImageLabel.Image = v8[3]
		local imageLabel = main.ImageLabel
		imageLabel.Rotation = 0
		local v9 = #jSONDecode > 5 and 125 or #jSONDecode > 1 and 50 or 15
		local rotation = 0
		local v10 = {
			brake = false
		}
		table.insert(v2, v10)
		local v11 = false
		local lastTime = tick()
		local v12 = nil
		local v16 = k
		v12 = shared.loop(function()
			local v17 = 1 - imageLabel.Rotation / v7
			local v18 = v9 * v17
			local v19 = v17 <= 0.001 and 0 or v17
			imageLabel.Rotation = math.clamp(imageLabel.Rotation + v18, 0, v7)

			if imageLabel.Rotation - rotation > 15 then
				rotation = imageLabel.Rotation
				shared.sfx({
					SoundId = "rbxassetid://17849584689",
					Parent = workspace,
					PlaybackSpeed = 1 + imageLabel.Rotation / v7,
					Volume = 1
				}):Play()
			end

			if not (v7 <= imageLabel.Rotation) and not v10.brake and v19 ~= 0 then
				return
			end

			if v19 == 0 then
				shared.sfx({
					SoundId = "rbxassetid://17849807535",
					Parent = workspace,
					Volume = 2
				}):Play()
				local v20 = {}

				for i = 1, #jSONDecode == 5 and v16 ~= #jSONDecode and 5 or 25 do
					local v21 = (math.random(1, 2) == 1 and -1 or 1) * Random.new():NextNumber(1, 3) * math.random()
					local number = Random.new():NextNumber(1, 3)
					local v22 = (math.random(1, 2) == 1 and -1 or 1) * Random.new():NextNumber(1, 3) * math.random()
					local number2 = Random.new():NextNumber(0.4, 0.6)
					local frame3 = Instance.new("Frame")
					frame3.BorderSizePixel = 0
					frame3.Rotation = math.random(-360, 360)
					frame3.BackgroundColor3 = BrickColor.Random().Color
					frame3.Size = UDim2.new(number2, 0, number2, 0)
					frame3.Parent = main.Arrow
					local v23 = {
						frame3,
						v21,
						number,
						v22
					}
					task.delay(Random.new():NextNumber(0.6, 1.2), function()
						local number3 = Random.new():NextNumber(1, 2)
						frame3:TweenSize(UDim2.new(0, 0, 0, 0), nil, nil, number3)
						task.delay(number3, function()
							frame3:Destroy()
							table.remove(v20, table.find(v20, v23))
						end)
					end)
					table.insert(v20, v23)
				end

				task.delay(#jSONDecode == 5 and 0.5 or 1.5, function()
					v11 = true
				end)
				local lastTime2 = tick()
				local v21 = nil
				v21 = shared.loop(function()
					if tick() - lastTime2 > 3 or #v20 == 0 then
						return v21()
					end

					for k2, v22 in pairs(v20) do
						local v23 = v22[2]
						local v24 = v22[3]
						local v25 = v22[4]
						v22[2] *= 0.99
						v22[3] -= 0.08
						local v26 = v22[1]
						local v27 = v23 * 5
						local v28 = v24 * 5
						v26.Rotation += 0.1
						v26.Position = UDim2.new(
							v26.Position.X.Scale,
							v26.Position.X.Offset + v27,
							v26.Position.Y.Scale,
							v26.Position.Y.Offset + v28
						)
					end
				end, 60)
			end

			if v16 == #jSONDecode then
				task.delay(#jSONDecode > 1 and 1.75 or 3, function()
					main.Visible = false
					parent2.Visible = true
				end)
			end

			return v12()
		end, 60)

		repeat
			task.wait()
		until v11 or tick() - lastTime > 25
	end
end)