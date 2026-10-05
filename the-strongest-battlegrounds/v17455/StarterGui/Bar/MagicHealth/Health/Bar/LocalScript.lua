task.wait()
local parent = script.Parent
local localPlayer = game.Players.LocalPlayer
local parent2 = script.Parent.Parent.Parent
local character = localPlayer.Character
local _ = character.PrimaryPart
local UserInputService = game:GetService("UserInputService")
local v = false
parent2.Visible = true
shared.barMain = parent2
local uIScale = parent2:FindFirstChildOfClass("UIScale")

if uIScale then
	uIScale:Destroy()
end

local uIScale2 = parent2.Parent and parent2.Parent:FindFirstChildOfClass("UIScale")
task.spawn(function()
	if UserInputService.TouchEnabled then
		local character2 = character:GetAttribute("Character")

		if not character2 then
			repeat
				task.wait()
			until character:GetAttribute("Character")

			character2 = character:GetAttribute("Character")
		end

		if character2 == "Batter" or character2 == "Zombie" or character2 == "KJ" or character2 == "Hunter" then
			return
		end

		for _, v2 in pairs({ script.Parent.Parent.Parent.burster, script.Parent.Parent.Parent.cdholder }) do
			v2.Position += UDim2.new(0, 0, -0.65, 0)
		end
	end
end)

if UserInputService.TouchEnabled and not shared.barPos then
	task.spawn(function()
		localPlayer:WaitForChild("LoadedData", 10)

		if shared.barPos then
			return
		end

		local lastTime = tick()

		repeat
			task.wait()
		until localPlayer:GetAttribute("BarLayout") or tick() - lastTime >= 5

		wait(0.5)
		local barLayout = localPlayer:GetAttribute("BarLayout")

		if barLayout and barLayout ~= "{}" and barLayout ~= "" then
			local success, result = pcall(function()
				local HttpService = game:GetService("HttpService")
				return HttpService:JSONDecode(barLayout)
			end)

			if success and typeof(result) == "table" and result.Position then
				shared.barPos = UDim2.new(
					result.Position[1],
					result.Position[2],
					result.Position[3],
					result.Position[4]
				)

				if result.Scale and result.Scale ~= 1 then
					shared.barScale = result.Scale
				end

				if uIScale2 and shared.barScale then
					uIScale2.Scale = shared.barScale
				end

				parent2:TweenPosition(shared.barPos, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.5, true)
			end
		end
	end)
end

if localPlayer:GetAttribute("BarLayout") and UserInputService.TouchEnabled then
	if uIScale2 and shared.barScale then
		uIScale2.Scale = shared.barScale
	end

	if shared.barPos then
		parent2.Position = shared.barPos
	end
end

local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function isBaldOrKJ()
	return character:GetAttribute("Character") == "Bald" or character:GetAttribute("Character") == "KJ"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isCustomAwakenBypass()
	return character:GetAttribute("CustomAwakenBarBypass") == true
end

local function shouldHardHideUltBar()
	local v2 = character:GetAttribute("Ulted") and isBaldOrKJ()

	if v2 then
		local customAwakenBypass = isCustomAwakenBypass() -- equivalent call inferred; original call site unknown
		return not customAwakenBypass
	end

	return v2
end

local flag2 = nil

local function fn()
	if shared.draggingBar then
		return
	end

	parent2:FindFirstChild("TextLabel")
	local v2, barPos

	if character:FindFirstChild("UFW") or workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable or v or character:FindFirstChild("HideUlt") then
		if flag2 then
			return
		end

		v2 = parent2

		if shared.barPos then
			barPos = shared.barPos
		else
			barPos = UDim2.new(0.5, 0, 1, -(UserInputService.TouchEnabled and 150 or 90))
		end

		v2:TweenPosition(
			UDim2.new(barPos.X.Scale, barPos.X.Offset, barPos.Y.Scale, barPos.Y.Offset + 250),
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Quad,
			1,
			true
		)
		flag2 = true
	else
		local v3 = character:GetAttribute("Ulted") and isBaldOrKJ()

		if v3 then
			local customAwakenBypass = isCustomAwakenBypass() -- equivalent call inferred; original call site unknown
			v3 = not customAwakenBypass
		end

		if v3 then
			if flag2 then
				return
			end

			v2 = parent2

			if shared.barPos then
				barPos = shared.barPos
			else
				barPos = UDim2.new(0.5, 0, 1, -(UserInputService.TouchEnabled and 150 or 90))
			end

			v2:TweenPosition(
				UDim2.new(barPos.X.Scale, barPos.X.Offset, barPos.Y.Scale, barPos.Y.Offset + 250),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Quad,
				1,
				true
			)
			flag2 = true
		elseif flag2 then
			local v5

			if shared.barPos then
				v5 = shared.barPos
			else
				v5 = UDim2.new(0.5, 0, 1, -(UserInputService.TouchEnabled and 150 or 90))
			end

			parent2:TweenPosition(v5, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 1, true)
			flag2 = false
		end
	end
end

parent2.ImageButton.MouseButton1Click:Connect(function()
	if shared.draggingButtons or shared.draggingBar or shared.draggingHotbar then
		return
	end

	local communicate = character:FindFirstChild("Communicate") or character:WaitForChild("Communicate", 5)

	if communicate then
		communicate:FireServer({
			Goal = "KeyPress",
			Key = Enum.KeyCode.G,
			MoveDirection = character.Humanoid.MoveDirection
		})
	end
end)
script.Parent.Parent.Parent.Ult:GetPropertyChangedSignal("Visible"):Connect(function()
	script.Parent.Parent.Parent.Ult.ImageLabel.Visible = UserInputService.GamepadEnabled and script.Parent.Parent.Parent.Ult.Visible or false
end)
local v2 = nil

local function fn2()
	parent:TweenSize(UDim2.new((v2 or localPlayer:GetAttribute("Ultimate")) / 100, 0, 0, 25), nil, nil, 0.4, true)
	local ult = script.Parent.Parent.Parent.Ult
	local textLabel = ult.TextLabel

	if UserInputService.GamepadEnabled then
		ult.Text = "[DPAD UP]"
		textLabel.Text = "[DPAD UP]"
	else
		ult.Text = "[G]"
		textLabel.Text = "[G]"
	end

	if localPlayer:GetAttribute("Ultimate") >= 100 then
		script.Parent.Parent.Parent.Ult.Visible = true
	else
		script.Parent.Parent.Parent.Ult.Visible = false
	end
end

local function runUltPopFlow()
	if flag or not character:GetAttribute("Ulted") then
		return
	end

	if (character:GetAttribute("Character") == "Bald" or character:GetAttribute("Character") == "KJ") and character:GetAttribute("CustomAwakenBarBypass") ~= true then
		return
	end

	if not character:GetAttribute("UltimateTime") then
		return
	end

	flag = true
	local lastTime = tick()
	local v3 = false
	v = true
	v2 = 100
	fn2()
	fn()
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
	until v3 or tick() - lastTime > 10 or character:FindFirstChild("BeganUltRn")

	v = nil
	fn()

	if childAddedConnection then
		childAddedConnection:Disconnect()
	end

	if tick() - lastTime > 10 then
		v2 = nil
		flag = false
		return fn2()
	else
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 1
		numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			v2 = numberValue.Value * 100
			fn2()
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

			if numberValue then
				numberValue:Destroy()
				numberValue = nil
			end

			if fillChangedConnection then
				fillChangedConnection:Disconnect()
				fillChangedConnection = nil
			end

			flag = false
			return fn2()
		end)
	end
end

character:GetAttributeChangedSignal("Ulted"):Connect(function()
	if character:GetAttribute("Ulted") then
		runUltPopFlow()
		return
	end

	flag = false
	fn()
end)
character:GetAttributeChangedSignal("CustomAwakenBarBypass"):Connect(function()
	fn()

	if character:GetAttribute("Ulted") and isCustomAwakenBypass() then
		runUltPopFlow()
	end
end)
localPlayer:GetAttributeChangedSignal("Ultimate"):Connect(fn2)

if (localPlayer:GetAttribute("Ultimate") or 0) >= 100 then
	local ult = script.Parent.Parent.Parent.Ult
	local textLabel = ult.TextLabel

	if UserInputService.GamepadEnabled then
		ult.Text = "[DPAD UP]"
		textLabel.Text = "[DPAD UP]"
	else
		ult.Text = "[G]"
		textLabel.Text = "[G]"
	end

	script.Parent.Parent.Parent.Ult.Visible = true
end

workspace.CurrentCamera:GetPropertyChangedSignal("CameraType"):Connect(fn)
character:GetAttributeChangedSignal("Ulted"):Connect(fn)
character:GetAttributeChangedSignal("CustomAwakenBarBypass"):Connect(fn)
character.ChildAdded:Connect(fn)
character.ChildRemoved:Connect(fn)
parent.Size = UDim2.new((localPlayer:GetAttribute("Ultimate") or 0) / 100, 0, 0, 25)
local v3 = {
	[0] = "rbxassetid://82962465996640",
	[1] = "rbxassetid://87983253118081",
	[2] = "rbxassetid://118327710715695",
	[3] = "rbxassetid://83005204809758",
	[4] = "rbxassetid://100217661407423",
	[5] = "rbxassetid://88641627138967",
	[6] = "rbxassetid://110295082123006",
	[7] = "rbxassetid://137025830018693",
	[8] = "rbxassetid://134392286633664",
	[9] = "rbxassetid://106359497596564",
	[10] = "rbxassetid://91638120002030",
	[11] = "rbxassetid://136913580584425",
	[12] = "rbxassetid://130271725722855",
	[13] = "rbxassetid://70865803781085",
	[14] = "rbxassetid://132112097379667",
	[15] = "rbxassetid://89608652687630",
	[16] = "rbxassetid://85670335141883",
	[17] = "rbxassetid://133442223330338",
	[18] = "rbxassetid://124105736954049",
	[19] = "rbxassetid://120156088230665",
	[20] = "rbxassetid://106682796416638",
	[21] = "rbxassetid://104725110845302",
	[22] = "rbxassetid://109993900980939",
	[23] = "rbxassetid://86631021907598",
	[24] = "rbxassetid://74899341433835",
	[25] = "rbxassetid://138091963759115",
	[26] = "rbxassetid://122698048236109",
	[27] = "rbxassetid://110848443262647",
	[28] = "rbxassetid://93673138614952",
	[29] = "rbxassetid://99428018627004",
	[30] = "rbxassetid://75522165745711",
	[31] = "rbxassetid://129314544801969",
	[32] = "rbxassetid://138607537325006",
	[33] = "rbxassetid://80382739395565",
	[34] = "rbxassetid://85222793140131",
	[35] = "rbxassetid://129898051831293",
	[36] = "rbxassetid://82407966748966",
	[37] = "rbxassetid://108590445661978",
	[38] = "rbxassetid://89715914640527",
	[39] = "rbxassetid://82138831175526",
	[40] = "rbxassetid://81424349898795",
	[41] = "rbxassetid://104876280545390",
	[42] = "rbxassetid://76511487774990",
	[43] = "rbxassetid://82504839734172",
	[44] = "rbxassetid://109393450976155",
	[45] = "rbxassetid://90570341749739",
	[46] = "rbxassetid://134673489611532",
	[47] = "rbxassetid://129706753595226",
	[48] = "rbxassetid://109199983100050",
	[49] = "rbxassetid://122243724753359",
	[50] = "rbxassetid://88409441827707",
	[51] = "rbxassetid://135561070195806",
	[52] = "rbxassetid://138697977094069",
	[53] = "rbxassetid://121287121840059",
	[54] = "rbxassetid://73206247593191",
	[55] = "rbxassetid://89602596637131",
	[56] = "rbxassetid://70858693806198",
	[57] = "rbxassetid://116801337020632",
	[58] = "rbxassetid://71566130476762",
	[59] = "rbxassetid://132031878546241",
	[60] = "rbxassetid://107594536991914",
	[61] = "rbxassetid://84843418488639",
	[62] = "rbxassetid://101562648716944",
	[63] = "rbxassetid://124865406512265",
	[64] = "rbxassetid://100568466535672",
	[65] = "rbxassetid://120501098567550",
	[66] = "rbxassetid://109990814409229",
	[67] = "rbxassetid://82391233844083",
	[68] = "rbxassetid://107466338628922",
	[69] = "rbxassetid://73591054122949",
	[70] = "rbxassetid://81863088331490",
	[71] = "rbxassetid://95953467976410",
	[72] = "rbxassetid://99918823833061",
	[73] = "rbxassetid://101619232710719",
	[74] = "rbxassetid://110179893753920",
	[75] = "rbxassetid://76313417345310",
	[76] = "rbxassetid://95882483224967",
	[77] = "rbxassetid://118519514721679",
	[78] = "rbxassetid://76044993019461",
	[79] = "rbxassetid://79755988827638",
	[80] = "rbxassetid://90256670799256",
	[81] = "rbxassetid://84535120874433",
	[82] = "rbxassetid://82677169603780",
	[83] = "rbxassetid://96551438330305",
	[84] = "rbxassetid://130889422436840",
	[85] = "rbxassetid://81977842240827",
	[86] = "rbxassetid://128378588913438",
	[87] = "rbxassetid://125620095924248",
	[88] = "rbxassetid://75112916891781",
	[89] = "rbxassetid://139190736242961",
	[90] = "rbxassetid://126224024814041",
	[91] = "rbxassetid://131700075770399",
	[92] = "rbxassetid://109472972295650",
	[93] = "rbxassetid://114380945877348",
	[94] = "rbxassetid://81096060190246",
	[95] = "rbxassetid://88685561059859",
	[96] = "rbxassetid://96707128495207",
	[97] = "rbxassetid://131155209100892",
	[98] = "rbxassetid://138046436271033",
	[99] = "rbxassetid://72170736460695",
	[100] = "rbxassetid://128852460536951",
	[101] = "rbxassetid://74490544790864",
	[102] = "rbxassetid://104144776025147",
	[103] = "rbxassetid://107525872628611",
	[104] = "rbxassetid://130045447468838",
	[105] = "rbxassetid://131050281657098",
	[106] = "rbxassetid://78226410556910",
	[107] = "rbxassetid://129714710030601",
	[108] = "rbxassetid://99960222384255",
	[109] = "rbxassetid://123405845991413",
	[110] = "rbxassetid://132322766282397",
	[111] = "rbxassetid://121707923012784",
	[112] = "rbxassetid://117534542541325",
	[113] = "rbxassetid://139433756169613",
	[114] = "rbxassetid://87762222466961",
	[115] = "rbxassetid://102335733018590",
	[116] = "rbxassetid://125553732696566",
	[117] = "rbxassetid://139340098080824",
	[118] = "rbxassetid://126680076602012",
	[119] = "rbxassetid://109920412394070",
	[120] = "rbxassetid://118385218380772",
	[121] = "rbxassetid://108367275962679",
	[122] = "rbxassetid://87682738621136",
	[123] = "rbxassetid://98566557991115",
	[124] = "rbxassetid://72019834327939",
	[125] = "rbxassetid://134012835610840",
	[126] = "rbxassetid://82046616632489",
	[127] = "rbxassetid://118501686390863",
	[128] = "rbxassetid://78280412939374",
	[129] = "rbxassetid://125665746556767",
	[130] = "rbxassetid://84994011117393",
	[131] = "rbxassetid://116446951057621",
	[132] = "rbxassetid://106565063040361",
	[133] = "rbxassetid://134661667647340",
	[134] = "rbxassetid://74149522283600",
	[135] = "rbxassetid://129899866302697"
}
local v4 = 0
local bar = script.Parent.Bar
bar.ImageColor3 = Color3.fromRGB(255, 87, 87)
bar.Image = "rbxassetid://7884720727"
local frame = Instance.new("Frame")
frame.Name = "CosmicFrames"
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Size = UDim2.fromScale(1, 1)
frame.ZIndex = bar.ZIndex
frame.Visible = false
frame.Parent = bar
local v5 = {}
local flag3 = nil

local function fn3()
	if flag3 then
		return
	end

	flag3 = true

	for i = 0, 135 do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "F" .. i
		imageLabel.BackgroundTransparency = 1
		imageLabel.BorderSizePixel = 0
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		imageLabel.Image = v3[i]
		imageLabel.ScaleType = bar.ScaleType
		imageLabel.Visible = false
		imageLabel.Parent = frame
		v5[i] = imageLabel
	end

	if not shared.cosmicPreloaded then
		shared.cosmicPreloaded = true
		task.spawn(function()
			pcall(function()
				local ContentProvider = game:GetService("ContentProvider")
				ContentProvider:PreloadAsync(frame:GetChildren())
			end)
		end)
	end
end

local v6 = -1

-- equivalent calls inferred from this helper; original call sites unknown
local function showCosmicFrame(p)
	if v6 == p then
		return
	end

	local v7 = v5[v6]

	if v7 then
		v7.Visible = false
	end

	local v8 = v5[p]

	if v8 then
		v8.Visible = true
	end

	v6 = p
end

local Info = require(game.ReplicatedStorage.Info)

local function fn4()
	fn3()
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 1
	v2 = 100
	fn2()
	local valueChangedConnection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		v2 = numberValue.Value * 100
		fn2()
	end)
	local flag4 = false
	local v7 = false
	local v8 = nil
	local v9 = nil
	local fillChangedConnection = nil
	local childAddedConnection = nil
	local readyChangedConnection = nil
	local ancestryChangedConnection = nil

	local function fn5()
		if flag4 then
			return
		end

		flag4 = true

		if v8 then
			v8:Pause()
			v8:Destroy()
		end

		valueChangedConnection:Disconnect()
		numberValue:Destroy()

		if fillChangedConnection then
			fillChangedConnection:Disconnect()
		end

		if childAddedConnection then
			childAddedConnection:Disconnect()
		end

		if readyChangedConnection then
			readyChangedConnection:Disconnect()
		end

		if ancestryChangedConnection then
			ancestryChangedConnection:Disconnect()
		end

		v2 = nil
		fn2()
	end

	task.delay(5, function()
		if v7 or flag4 then
			return
		end

		local TweenService = game:GetService("TweenService")
		v8 = TweenService:Create(numberValue, TweenInfo.new(4.845, Enum.EasingStyle.Linear), {
			Value = 0
		})
		v8:Play()
	end)
	task.delay(10, function()
		if v7 or flag4 then
			return
		end

		fn5()
	end)
	character:SetAttribute("UltimateName", "COSMIC FORM")
	local count = #v3
	bar.ImageTransparency = 1
	frame.Visible = true

	local function fn6()
		v9 = shared.loop(function()
			if character:GetAttribute("CanCosmic") or character:FindFirstChild("CosmicTriggered") then
				v4 = (v4 + 1) % (count + 1)
				showCosmicFrame(v4) -- equivalent call inferred; original call site unknown
			else
				frame.Visible = false

				if v6 >= 0 and v5[v6] then
					v5[v6].Visible = false
				end

				v6 = -1
				local TweenService = game:GetService("TweenService")
				TweenService:Create(bar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					ImageTransparency = 0
				}):Play()
				character:SetAttribute("UltimateName", Info.Skillsets[character:GetAttribute("Character")].UltimateName)
				fn2()
				return v9()
			end
		end, n)
	end

	fn6()

	local function fn7(instance)
		if v7 or flag4 then
			return
		end

		v7 = true

		if v8 then
			v8:Pause()
			v8:Destroy()
			v8 = nil
		end

		if v9 then
			v9()
			v9 = nil
		end

		numberValue.Value = 1
		v2 = 100
		fn2()

		local function fn8()
			if flag4 then
				return
			end

			if not v9 then
				fn6()
			end

			local primaryPart = character.PrimaryPart

			if not primaryPart then
				return fn5()
			end

			local flag5 = false

			local function fn9()
				if flag4 then
					return
				end

				local fill = primaryPart:GetAttribute("fill")

				if fill == nil then
					if flag5 then
						return fn5()
					end
				else
					if fill <= 0 then
						return fn5()
					end

					flag5 = true
					numberValue.Value = fill
				end
			end

			fillChangedConnection = primaryPart:GetAttributeChangedSignal("fill"):Connect(fn9)
			fn9()
		end

		if instance:GetAttribute("Ready") then
			fn8()
		else
			readyChangedConnection = instance:GetAttributeChangedSignal("Ready"):Connect(function()
				if instance:GetAttribute("Ready") then
					fn8()
				end
			end)
		end

		ancestryChangedConnection = instance.AncestryChanged:Connect(function()
			if not instance.Parent then
				fn5()
			end
		end)
	end

	local cosmicTriggered = character:FindFirstChild("CosmicTriggered")

	if cosmicTriggered and cosmicTriggered:IsA("Accessory") then
		fn7(cosmicTriggered)
	else
		childAddedConnection = character.ChildAdded:Connect(function(accessory)
			if accessory.Name == "CosmicTriggered" and accessory:IsA("Accessory") then
				fn7(accessory)
			end
		end)
	end
end

if character:GetAttribute("CanCosmic") == true then
	fn4()
end

character:GetAttributeChangedSignal("CanCosmic"):Connect(function()
	if character:GetAttribute("CanCosmic") then
		fn4()
	end
end)

if localPlayer:GetAttribute("Loadedcosmic") then
	fn3()
end

local TweenService = game:GetService("TweenService")
local cdholder = parent2:WaitForChild("cdholder")
local template = cdholder:WaitForChild("template")
template.Parent = nil
local size = template.Size
local size2 = template.template.Size
local uDim = UDim2.new(size2.X.Scale, size2.X.Offset, 0, 0)
local tweenInfo = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.10416666666666667, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local linear = Enum.EasingStyle.Linear
local _ = {
	forward = "rbxassetid://108442507536948",
	back = "rbxassetid://93960280784897",
	left = "rbxassetid://74122482952379",
	right = "rbxassetid://119019688468035",
	evasive = "rbxassetid://87178905810098"
}
local v7 = {}
local v8 = true
local layoutOrder = 0
local v10 = {}

local function fn5(k, p)
	local v11 = v7[k]

	if not (v11 and v11.gui) then
		return
	end

	local v12 = v11.on and v7[v11.on]

	if v12 and v12.gui then
		local uDim2 = not v12.dead and UDim2.new(0.5, 0, 0, -4) or UDim2.new(0.5, 0, 1, 0)
		v11.gui.Size = UDim2.new(1, 0, 1, 0)

		if v11.gui.Parent ~= v12.gui then
			v11.gui.Parent = v12.gui
			v11.gui.AnchorPoint = Vector2.new(0.5, 1)

			if not p then
				v11.gui.Position = uDim2
				return
			end

			local absolutePosition = v11.gui.AbsolutePosition
			local absolutePosition2 = v12.gui.AbsolutePosition
			v11.gui.Position = UDim2.new(
				0,
				absolutePosition.X - absolutePosition2.X + v11.gui.AbsoluteSize.X / 2,
				0,
				absolutePosition.Y - absolutePosition2.Y + v11.gui.AbsoluteSize.Y
			)
		end

		v11.gui.AnchorPoint = Vector2.new(0.5, 1)

		if p then
			TweenService:Create(v11.gui, tweenInfo, {
				Position = uDim2
			}):Play()
		else
			v11.gui.Position = uDim2
		end
	elseif v11.gui.Parent ~= cdholder then
		v11.gui.Parent = cdholder
		v11.gui.Size = size
		v11.gui.AnchorPoint = Vector2.new(0, 0)
		v11.gui.Position = UDim2.new(0, 0, 0, 0)
	end
end

local function fn6(name)
	local v11 = v7[name]

	if not v11 then
		return
	end

	character:GetAttribute("Character")

	if v11.on and v7[v11.on] then
		return
	end

	local count = 0

	for k, v12 in pairs(v7) do
		if k == name or v12.on then
			continue
		end

		count += 1
	end

	if count < 2 then
		v11.on = nil
		return
	end

	local on = nil

	for k, v13 in pairs(v7) do
		if k == name or v13.on then
			continue
		end

		local v14 = nil

		for k2, v16 in pairs(v7) do
			if not (k2 ~= name and v16.on == k) then
				continue
			end

			v14 = k2
			break
		end

		if v14 then
			continue
		end

		if on then
			local v16 = v10[k]
			local v17 = not v16 and 0 or v16.length - (tick() - v16.at)
			local v18 = v10[on]

			if not ((not v18 and 0 or v18.length - (tick() - v18.at)) < v17) then
				continue
			end
		end

		on = k
	end

	v11.on = on
end

local function fn7(p, p2)
	local v11 = v7[p]

	if not v11 then
		return
	end

	v11.gen += 1
	local gui = v11.gui

	if not (gui and gui.Parent) then
		v7[p] = nil
	elseif p2 then
		v7[p] = nil
		gui:Destroy()
	else
		v11.dead = true
		TweenService:Create(v11.inner, tweenInfo, {
			Size = uDim
		}):Play()
		TweenService:Create(v11.icon, tweenInfo, {
			ImageTransparency = 1
		}):Play()

		for k in pairs(v7) do
			fn5(k, k ~= nil)
		end
	end
end

local function fn8(name, duration, icon, value)
	if not v8 then
		return
	end

	local v11 = false

	for _, v13 in pairs(v7) do
		if v13.dead then
			continue
		end

		v11 = true
		break
	end

	if not v11 then
		for k, v13 in pairs(v7) do
			if v13.gui then
				v13.gui:Destroy()
			end

			v7[k] = nil
		end

		layoutOrder = 0
	end

	local v13 = v7[name]

	if not v13 then
		local clone = template:Clone()
		clone.Name = name
		local template2 = clone.template
		template2.AnchorPoint = Vector2.new(0.5, 0.5)
		template2.Position = UDim2.new(0.5, 0, 0.5, 0)
		template2.Overlay.ScaleType = Enum.ScaleType.Fit
		template2.Overlay.ImageTransparency = 1
		local frame2 = Instance.new("Frame")
		frame2.Name = "Fill"
		frame2.BackgroundColor3 = Color3.fromRGB(255, 78, 78)
		frame2.BackgroundTransparency = 0.55
		frame2.BorderSizePixel = 0
		frame2.AnchorPoint = Vector2.new(0.5, 1)
		frame2.Position = UDim2.new(0.5, 0, 1, 0)
		frame2.Size = UDim2.new(1, 0, 1, 0)
		frame2.ZIndex = template2.ZIndex + 1
		frame2.Parent = template2
		clone.Size = size
		template2.Size = uDim
		clone.Visible = true
		clone.Parent = cdholder
		layoutOrder -= 1
		clone.LayoutOrder = layoutOrder
		v13 = {
			gui = clone,
			inner = template2,
			fill = frame2,
			icon = template2.Overlay,
			gen = 0
		}
		v7[name] = v13
	end

	v13.dead = nil
	v13.gen += 1
	local gen = v13.gen
	local fill = v13.fill
	v13.icon.Image = icon

	if icon == "rbxassetid://87178905810098" or icon == "rbxassetid://125582764649064" then
		v13.icon.Size = UDim2.new(0.8, 0, 0.8, 0)

		if icon == "rbxassetid://125582764649064" then
			v13.icon.Size = UDim2.new(1, 0, 1, 0)
		end
	end

	TweenService:Create(v13.inner, tweenInfo2, {
		Size = size2
	}):Play()
	TweenService:Create(v13.icon, tweenInfo2, {
		ImageTransparency = 0
	}):Play()
	fill.Size = UDim2.new(1, 0, value or 1, 0)
	TweenService:Create(fill, TweenInfo.new(duration, linear), {
		Size = UDim2.new(1, 0, 0, 0)
	}):Play()
	task.delay(duration, function()
		local v14 = v7[name]

		if v14 == v13 and v14.gen == gen then
			fn7(name)
		end
	end)
	fn6(name)

	if UserInputService.TouchEnabled then
		return
	end

	for k in pairs(v7) do
		fn5(k, k ~= name)
	end
end

for _, v11 in pairs({
	{
		name = "JustLeftDashed",
		slot = "side",
		icon = "rbxassetid://74122482952379",
		cd = "CustomSideDashCooldown",
		def = 2
	},
	{
		name = "JustRightDashed",
		slot = "side",
		icon = "rbxassetid://119019688468035",
		cd = "CustomSideDashCooldown",
		def = 2
	},
	{
		name = "JustForwardDashed",
		slot = "forward",
		icon = "rbxassetid://108442507536948",
		cd = "CustomForwardDashCooldown",
		def = 5
	},
	{
		name = "JustBackDashed",
		slot = "forward",
		icon = "rbxassetid://93960280784897",
		cd = "CustomForwardDashCooldown",
		def = 5
	},
	{
		name = "JustEvasived",
		slot = "evasive",
		icon = "rbxassetid://87178905810098",
		def = 30.05
	},
	{
		name = "justbursted",
		slot = "burst",
		icon = "rbxassetid://125582764649064",
		def = 15
	}
}) do
	local v12 = v11
	character:GetAttributeChangedSignal(v11.name):Connect(function()
		if v12.name:find("Dashed") and character:GetAttribute(v12.name) == 0 then
			v10[v12.slot] = nil
			fn7(v12.slot)
		else
			local def = v12.def

			if v12.cd then
				local attribute = character:GetAttribute(v12.cd)

				if type(attribute) == "number" then
					def = attribute
				end
			end

			if character:GetAttribute("Character") == "Tech" and character:FindFirstChild("Mech") then
				return
			end

			local length = v12.slot == "side" and (character:GetAttribute("AfterimageDash") or 0) > 0 and 0 or def
			v10[v12.slot] = {
				at = tick(),
				length = length,
				icon = v12.icon
			}
			fn8(v12.slot, length, v12.icon)
		end
	end)
end

local function fn9(p)
	v8 = not p

	if p then
		for k, v11 in pairs(v7) do
			v11.gen += 1

			if v11.gui then
				local gui = v11.gui
				TweenService:Create(v11.inner, tweenInfo, {
					Size = uDim
				}):Play()
				TweenService:Create(v11.icon, tweenInfo, {
					ImageTransparency = 1
				}):Play()
				task.delay(0.125, function()
					if gui then
						gui:Destroy()
					end
				end)
			end

			v7[k] = nil
		end

		layoutOrder = 0
	else
		for k, v11 in pairs(v10) do
			local v12 = v11.length - (tick() - v11.at)

			if v12 > 0 then
				fn8(k, v12, v11.icon, v12 / v11.length)
			end
		end
	end
end

localPlayer:GetAttributeChangedSignal("S_CDINDICATOR"):Connect(function()
	fn9(localPlayer:GetAttribute("S_CDINDICATOR") == true)
end)
fn9(localPlayer:GetAttribute("S_CDINDICATOR") == true)
local template2 = parent2:WaitForChild("burster"):WaitForChild("template").template
template2.AnchorPoint = Vector2.new(0.5, 0.5)
template2.Position = UDim2.new(0.5, 0, 0.5, 0)
template2.Overlay.ScaleType = Enum.ScaleType.Fit
template2.Overlay.ImageTransparency = 1
template2.Overlay.ZIndex = template2.ZIndex + 2
local size3 = template2.Size
local uDim2 = UDim2.new(size3.X.Scale, size3.X.Offset, 0, 0)
local color = Color3.fromRGB(189, 64, 64)
Color3.fromRGB(62, 223, 255)
local frame2 = Instance.new("Frame")
frame2.Name = "Fill"
frame2.BackgroundColor3 = color
frame2.BorderSizePixel = 0
frame2.AnchorPoint = Vector2.new(0.5, 1)
frame2.Position = UDim2.new(0.5, 0, 1, 0)
frame2.BackgroundTransparency = 0.15
frame2.Size = UDim2.new(1, 0, 0, 0)
frame2.ZIndex = template2.ZIndex + 1
frame2.Parent = template2
template2.Size = uDim2
template2.Overlay.Image = "rbxassetid://125582764649064"
local flag4 = false
local v11 = false
local tweenInfo3 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function fn10()
	local burst = localPlayer:GetAttribute("Burst") or 0
	local v12 = burst >= 100

	if flag4 or not (burst > 25) then
		if flag4 and burst < 10 then
			flag4 = false
			TweenService:Create(template2, tweenInfo, {
				Size = uDim2
			}):Play()
			TweenService:Create(template2.Overlay, tweenInfo, {
				ImageTransparency = 1
			}):Play()
			TweenService:Create(template2.Glow, tweenInfo, {
				ImageTransparency = 1
			}):Play()
		end
	else
		flag4 = true
		TweenService:Create(template2, tweenInfo, {
			Size = size3
		}):Play()
		TweenService:Create(template2.Overlay, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		TweenService:Create(template2.Glow, tweenInfo, {
			ImageTransparency = v12 and 0.1 or 0.45
		}):Play()
	end

	TweenService:Create(frame2, tweenInfo3, {
		Size = UDim2.new(1, 0, math.clamp(burst / 100, 0, 1), 0)
	}):Play()

	if v12 and not v11 then
		v11 = true
		TweenService:Create(frame2, tweenInfo4, {
			BackgroundTransparency = 0
		}):Play()

		if flag4 then
			TweenService:Create(template2.Glow, tweenInfo4, {
				ImageTransparency = 0.1
			}):Play()
		end
	elseif not v12 and v11 then
		v11 = false
		TweenService:Create(frame2, tweenInfo4, {
			BackgroundColor3 = color,
			BackgroundTransparency = 0.15
		}):Play()

		if flag4 then
			TweenService:Create(template2.Glow, tweenInfo4, {
				ImageTransparency = 0.35
			}):Play()
		end
	end
end

localPlayer:GetAttributeChangedSignal("Burst"):Connect(fn10)
fn10()