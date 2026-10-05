local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local deathEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("DeathEvent")
local CollectionService = game:GetService("CollectionService")
local parent = script.Parent
local screenGui = parent.Parent:WaitForChild("ScreenGui")
local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)
local MenuManager = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("MenuManager"))
local CameraModeController = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("CameraModeController"))
parent.DeathScreen.Position = UDim2.new(0, 0, -1, 0)
parent.DeathScreen.Visible = false
local Players = game:GetService("Players")
local nameFromUserIdAsyncs = {}
game:GetService("TweenService")

local function storeName(p)
	nameFromUserIdAsyncs[p] = Players:GetNameFromUserIdAsync(p)
end

local flag = false
local thread = nil

local function setVersionLabelsVisible(visible)
	local gameVersion = workspace:GetAttribute("GameVersion")

	for _, instance in ipairs(CollectionService:GetTagged("VersionNumber")) do
		if not (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) then
			continue
		end

		if gameVersion ~= nil then
			instance.Text = tostring(gameVersion)
		end

		instance.Visible = visible
	end
end

local v = {
	"Thank you for playing!",
	"Earn Ichor by completing Machines in rounds and using your Character's Abilities!",
	"You will earn Ichor based on how far you made it in a round.",
	"The more players that are in your round, the more difficult the game will become.",
	"Poppy gains a temporary speed boost when attacked.",
	"Boxten fills up Machines faster the more alive Players there are in a round.",
	"Dandy's full name is Dandicus Dancifer. Don't tell him I told you!",
	"Each Toon has their own unique Requirements. You can check them by viewing them in Dandy's Store in the Lobby!",
	"You can earn Tapes by performing tasks in game, which you can then spend at Dandy's Shop in the elevator!",
	"Rodger earns twice the amount of Research from Capsules and encountering Twisteds.",
	"Pebble can sniff out the location of Items that are near him!",
	"The deeper you traverse into Dandy's World, the more difficult and terrifying Twisteds await you.",
	"Some Toons will require Research on certain Twisteds in order to unlock them.",
	"Each Toon has their own unique set of Mastery Challenges. Complete them to unlock Lore and Rewards!",
	"Be sure to check back for new Updates, Events, Characters, Trinkets, and more exciting changes!",
	"Goob can grab Toons and pull them towards his position, saving them from trouble!",
	"Brightney passively emits light, and can reveal the position of Twisteds by shining lights on their positions!",
	"The further you venture, the chance of Blackouts occurring increase.",
	"Blackouts can happen randomly on each floor, shrouding the floor in complete darkness.",
	"Main Characters have access to two abilities, at the cost of one of their Hearts.",
	"Beware the dangerous and elusive Main Character Twisteds, as they are much more deadly than the rest of the cast with the abilities they possess.",
	"KEEP YOUR ALLIES CLOSE",
	"FIND THE TAPES",
	"Panic Mode activates when all the Machines on the current floor are completed. Get out of there while you still can!",
	"Odd numbered floors feature Card Votes, while Even numbered floors features Dandy's Shop in the Elevator.",
	"Brightney is great for Blackouts! On Floors with Blackouts, Brightney can shine lights on Twisteds, highlighting them for your allies.",
	"Vee can perform a mic check that causes all Twisteds to be highlighted for a short period.",
	"Razzle & Dazzle have higher movement speed on odd numbered Floors, and higher extraction speed on even numbered floors."
}
local flag2 = false
parent.SkipButton.Activated:Connect(function()
	flag2 = true
	parent.SkipButton.Visible = false
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function resultsAudio(p, p2)
	if flag2 then
		return
	end

	Audio:PlayOne(p, p2)
end

local function RandomHint(_)
	return v[math.random(1, #v)]
end

local currencyFrames = screenGui:FindFirstChild("CurrencyFrames")
local holidayFrame = currencyFrames and currencyFrames:FindFirstChild("HolidayFrame")
local margin = holidayFrame and holidayFrame:FindFirstChild("Margin")
local marginFrame = margin and margin:FindFirstChild("Frame")
local uIGradient = marginFrame and marginFrame:FindFirstChildOfClass("UIGradient")

if uIGradient then
	local resultsHolder = parent.DeathScreen.ResultsScreen.ResultsHolder

	for _, childName in ipairs({ "HolidayAmount", "HolidayTotalAmount" }) do
		local child = resultsHolder:FindFirstChild(childName)

		if not child or child:FindFirstChildOfClass("UIGradient") then
			continue
		end

		child.TextColor3 = Color3.new(1, 1, 1)
		local clone = uIGradient:Clone()
		clone.Parent = child
	end
else
	warn("[DeathScript] Holiday HUD gradient not found; holiday result rows keep their flat colour")
end

local function PlayDeathScreen(p, p2, p3, p4, p5, p6, p7, p8, value, value2)
	local WAIT_INTERVAL = 0.5
	local WAIT_INTERVAL_2 = 1
	local v2 = value or 0
	local v3 = value2 or 0
	MenuManager:CloseAll()
	CameraModeController.Exit()
	screenGui.Enabled = false
	parent.DeathScreen.Visible = true
	local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tween = TweenService:Create(parent.DeathScreen, tweenInfo, {
		Position = UDim2.new(0, 0, 0.1, 0)
	})
	tween:Play()
	tween.Completed:Wait()
	local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
	local tween2 = TweenService:Create(parent.DeathScreen, tweenInfo2, {
		Position = UDim2.new(0, 0, 0, 0)
	})
	Audio:PlayOne("Sounds.UI.Transitions.PlaceSound")
	Audio:PlayOne("Sounds.UI.Transitions.CloseSound")
	tween2:Play()
	parent.SkipButton.Visible = true

	if not flag2 then
		task.wait(WAIT_INTERVAL_2)
	end

	if not flag2 then
		task.wait(WAIT_INTERVAL_2)
	end

	local tweenInfo3 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false)
	local tween3 = TweenService:Create(parent.DeathScreen.YouDied, tweenInfo3, {
		Position = parent.DeathScreen.YouDied2.Position,
		Size = parent.DeathScreen.YouDied2.Size
	})
	tween3:Play()

	if not flag2 then
		tween3.Completed:Wait()
	end

	local tweenInfo4 = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
	local tween4 = TweenService:Create(parent.DeathScreen.ResultsScreen, tweenInfo4, {
		Position = UDim2.new(0.251, 0, 0.156, 0)
	})
	parent.DeathScreen.ResultsScreen.Position = UDim2.new(0.251, 0, 0.18, 0)
	parent.DeathScreen.ResultsScreen.Visible = true
	tween4:Play()
	resultsAudio("Sounds.UI.Results.ElectricTick", nil) -- equivalent call inferred; original call site unknown

	if not flag2 then
		task.wait(WAIT_INTERVAL_2)
	end

	local position = parent.DeathScreen.ResultsScreen.ResultsHolder.FloorAmount.Position
	local tween5 = TweenService:Create(parent.DeathScreen.ResultsScreen.ResultsHolder.FloorAmount, tweenInfo4, {
		Position = position
	})
	parent.DeathScreen.ResultsScreen.ResultsHolder.FloorAmount.Position = UDim2.new(
		position.X.Scale,
		0,
		position.Y.Scale * 1.25,
		0
	)
	parent.DeathScreen.ResultsScreen.ResultsHolder.FloorAmount.TextTransparency = 0
	parent.DeathScreen.ResultsScreen.ResultsHolder.FloorAmount.TextStrokeTransparency = 0
	tween5:Play()
	resultsAudio("Sounds.UI.Results.Tick", nil) -- equivalent call inferred; original call site unknown

	if not flag2 then
		task.wait(WAIT_INTERVAL)
	end

	resultsAudio("Sounds.UI.Results.CountSound", {
		TimePosition = 0.85
	}) -- equivalent call inferred; original call site unknown
	TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)

	if p <= 0 then
		parent.DeathScreen.ResultsScreen.ResultsHolder.FloorAmount.Text = "You Survived... " .. 0 .. " Floors!"
	end

	for i = 1, p do
		local v5 = 1 / p
		parent.DeathScreen.ResultsScreen.ResultsHolder.FloorAmount.Text = "You Survived... " .. i .. " Floors!"

		if not flag2 then
			task.wait(v5)
		end
	end

	parent.DeathScreen.ResultsScreen.ResultsHolder.FloorIchor.Text = "(" .. p2 .. " Ichor Earned)"
	parent.DeathScreen.ResultsScreen.ResultsHolder.FloorIchor.TextTransparency = 0
	parent.DeathScreen.ResultsScreen.ResultsHolder.FloorIchor.TextStrokeTransparency = 0
	parent.DeathScreen.ResultsScreen.ResultsHolder.FloorIchor.Visible = true

	if not flag2 then
		task.wait(WAIT_INTERVAL)
	end

	local position2 = parent.DeathScreen.ResultsScreen.ResultsHolder.MonsterAmount.Position
	local tween6 = TweenService:Create(parent.DeathScreen.ResultsScreen.ResultsHolder.MonsterAmount, tweenInfo4, {
		Position = position2
	})
	parent.DeathScreen.ResultsScreen.ResultsHolder.MonsterAmount.Position = UDim2.new(
		position2.X.Scale,
		0,
		position2.Y.Scale * 1.25,
		0
	)
	parent.DeathScreen.ResultsScreen.ResultsHolder.MonsterAmount.TextTransparency = 0
	parent.DeathScreen.ResultsScreen.ResultsHolder.MonsterAmount.TextStrokeTransparency = 0
	tween6:Play()
	resultsAudio("Sounds.UI.Results.Tick", nil) -- equivalent call inferred; original call site unknown

	if not flag2 then
		task.wait(WAIT_INTERVAL)
	end

	resultsAudio("Sounds.UI.Results.CountSound", {
		TimePosition = 0.85
	}) -- equivalent call inferred; original call site unknown

	if p5 <= 0 then
		parent.DeathScreen.ResultsScreen.ResultsHolder.MonsterAmount.Text = "You Encountered... " .. 0 .. " Twisteds!"
	end

	for i = 1, p5 do
		local v6 = 1 / p5
		parent.DeathScreen.ResultsScreen.ResultsHolder.MonsterAmount.Text = "You Encountered... " .. i .. " Twisteds!"

		if not flag2 then
			task.wait(v6)
		end
	end

	if not flag2 then
		task.wait(WAIT_INTERVAL)
	end

	local position3 = parent.DeathScreen.ResultsScreen.ResultsHolder.ItemAmount.Position
	local tween7 = TweenService:Create(parent.DeathScreen.ResultsScreen.ResultsHolder.ItemAmount, tweenInfo4, {
		Position = position3
	})
	parent.DeathScreen.ResultsScreen.ResultsHolder.ItemAmount.Position = UDim2.new(
		position3.X.Scale,
		0,
		position3.Y.Scale * 1.25,
		0
	)
	parent.DeathScreen.ResultsScreen.ResultsHolder.ItemAmount.TextTransparency = 0
	parent.DeathScreen.ResultsScreen.ResultsHolder.ItemAmount.TextStrokeTransparency = 0
	tween7:Play()
	resultsAudio("Sounds.UI.Results.Tick", nil) -- equivalent call inferred; original call site unknown

	if not flag2 then
		task.wait(WAIT_INTERVAL)
	end

	resultsAudio("Sounds.UI.Results.CountSound", {
		TimePosition = 0.85
	}) -- equivalent call inferred; original call site unknown

	if p4 <= 0 then
		parent.DeathScreen.ResultsScreen.ResultsHolder.ItemAmount.Text = "You Picked Up... " .. 0 .. " Items!"
	end

	for i = 1, p4 do
		local v7 = 1 / p4
		parent.DeathScreen.ResultsScreen.ResultsHolder.ItemAmount.Text = "You Picked Up... " .. i .. " Items!"

		if not flag2 then
			task.wait(v7)
		end
	end

	if not flag2 then
		task.wait(WAIT_INTERVAL)
	end

	local position4 = parent.DeathScreen.ResultsScreen.ResultsHolder.CapsuleAmount.Position
	local tween8 = TweenService:Create(parent.DeathScreen.ResultsScreen.ResultsHolder.CapsuleAmount, tweenInfo4, {
		Position = position4
	})
	parent.DeathScreen.ResultsScreen.ResultsHolder.CapsuleAmount.Position = UDim2.new(
		position4.X.Scale,
		0,
		position4.Y.Scale * 1.25,
		0
	)
	parent.DeathScreen.ResultsScreen.ResultsHolder.CapsuleAmount.TextTransparency = 0
	parent.DeathScreen.ResultsScreen.ResultsHolder.CapsuleAmount.TextStrokeTransparency = 0
	tween8:Play()
	resultsAudio("Sounds.UI.Results.Tick", nil) -- equivalent call inferred; original call site unknown

	if not flag2 then
		task.wait(WAIT_INTERVAL)
	end

	resultsAudio("Sounds.UI.Results.CountSound", {
		TimePosition = 0.85
	}) -- equivalent call inferred; original call site unknown

	if p7 <= 0 then
		parent.DeathScreen.ResultsScreen.ResultsHolder.CapsuleAmount.Text = "You Picked Up... " .. 0 .. " Research Capsules!"
	end

	for i = 1, p7 do
		local v8 = 1 / p7
		parent.DeathScreen.ResultsScreen.ResultsHolder.CapsuleAmount.Text = "You Picked Up... " .. i .. " Research Capsules!"

		if not flag2 then
			task.wait(v8)
		end
	end

	local v8 = p7 * 2

	if p8 then
		v8 = p7 * 3
	end

	local ichor15BoostActive = localPlayer:GetAttribute("Ichor15BoostActive") == true

	if ichor15BoostActive and v8 > 0 then
		v8 = math.ceil(v8 * 1.15)
	end

	parent.DeathScreen.ResultsScreen.ResultsHolder.CapsuleIchor.Text = "(" .. v8 .. " Ichor Earned This Match!)"
	parent.DeathScreen.ResultsScreen.ResultsHolder.CapsuleIchor.TextTransparency = 0
	parent.DeathScreen.ResultsScreen.ResultsHolder.CapsuleIchor.TextStrokeTransparency = 0
	parent.DeathScreen.ResultsScreen.ResultsHolder.CapsuleIchor.Visible = true

	if not flag2 then
		task.wait(WAIT_INTERVAL)
	end

	local position5 = parent.DeathScreen.ResultsScreen.ResultsHolder.GeneratorAmount.Position
	local tween9 = TweenService:Create(parent.DeathScreen.ResultsScreen.ResultsHolder.GeneratorAmount, tweenInfo4, {
		Position = position5
	})
	parent.DeathScreen.ResultsScreen.ResultsHolder.GeneratorAmount.Position = UDim2.new(
		position5.X.Scale,
		0,
		position5.Y.Scale * 1.25,
		0
	)
	parent.DeathScreen.ResultsScreen.ResultsHolder.GeneratorAmount.TextTransparency = 0
	parent.DeathScreen.ResultsScreen.ResultsHolder.GeneratorAmount.TextStrokeTransparency = 0
	tween9:Play()
	resultsAudio("Sounds.UI.Results.Tick", nil) -- equivalent call inferred; original call site unknown

	if not flag2 then
		task.wait(WAIT_INTERVAL)
	end

	resultsAudio("Sounds.UI.Results.CountSound", {
		TimePosition = 0.85
	}) -- equivalent call inferred; original call site unknown

	if p3 <= 0 then
		parent.DeathScreen.ResultsScreen.ResultsHolder.GeneratorAmount.Text = "You Completed... " .. 0 .. " Machines!"
	end

	for i = 1, p3 do
		local v10 = 1 / p3
		parent.DeathScreen.ResultsScreen.ResultsHolder.GeneratorAmount.Text = "You Completed... " .. i .. " Machines!"

		if not flag2 then
			task.wait(v10)
		end
	end

	parent.DeathScreen.ResultsScreen.ResultsHolder.GeneratorIchor.Text = "(" .. p6 .. " Ichor Earned This Match!)"
	parent.DeathScreen.ResultsScreen.ResultsHolder.GeneratorIchor.TextTransparency = 0
	parent.DeathScreen.ResultsScreen.ResultsHolder.GeneratorIchor.TextStrokeTransparency = 0
	parent.DeathScreen.ResultsScreen.ResultsHolder.GeneratorIchor.Visible = true

	if HolidayEventConfig.ENABLED and v2 then
		if not flag2 then
			task.wait(WAIT_INTERVAL)
		end

		if flag2 then
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayAmount.TextTransparency = 0
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayAmount.TextStrokeTransparency = 0
		else
			local position6 = parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayAmount.Position
			local tween10 = TweenService:Create(
				parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayAmount,
				tweenInfo4,
				{
					Position = position6
				}
			)
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayAmount.Position = UDim2.new(
				position6.X.Scale,
				0,
				position6.Y.Scale * 1.25,
				0
			)
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayAmount.TextTransparency = 0
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayAmount.TextStrokeTransparency = 0
			tween10:Play()
		end

		resultsAudio("Sounds.UI.Results.ElectricTick", nil) -- equivalent call inferred; original call site unknown
		resultsAudio("Sounds.UI.Results.Tick", nil) -- equivalent call inferred; original call site unknown
		resultsAudio("Sounds.UI.Money.MoneyPopup", nil) -- equivalent call inferred; original call site unknown

		if not flag2 then
			task.wait(WAIT_INTERVAL)
		end

		resultsAudio("Sounds.UI.Results.CountSound", {
			TimePosition = 0.85
		}) -- equivalent call inferred; original call site unknown

		if v2 <= 0 then
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayAmount.Text = "You Picked Up... " .. 0 .. " Event Items!"
		end

		for i = 1, v2 do
			local v11 = 1 / v2
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayAmount.Text = "You Picked Up... " .. i .. " Event Items!"

			if not flag2 then
				task.wait(v11)
			end
		end
	end

	if HolidayEventConfig.ENABLED and v3 and v3 > 0 then
		if not flag2 then
			task.wait(WAIT_INTERVAL)
		end

		if flag2 then
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayTotalAmount.TextTransparency = 0
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayTotalAmount.TextStrokeTransparency = 0
		else
			local position6 = parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayTotalAmount.Position
			local tween10 = TweenService:Create(
				parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayTotalAmount,
				tweenInfo4,
				{
					Position = position6
				}
			)
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayTotalAmount.Position = UDim2.new(
				position6.X.Scale,
				0,
				position6.Y.Scale * 1.25,
				0
			)
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayTotalAmount.TextTransparency = 0
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayTotalAmount.TextStrokeTransparency = 0
			tween10:Play()
		end

		resultsAudio("Sounds.UI.Results.ElectricTick", nil) -- equivalent call inferred; original call site unknown
		resultsAudio("Sounds.UI.Results.Tick", nil) -- equivalent call inferred; original call site unknown
		resultsAudio("Sounds.UI.Money.MoneyPopup", nil) -- equivalent call inferred; original call site unknown

		if not flag2 then
			task.wait(WAIT_INTERVAL)
		end

		resultsAudio("Sounds.UI.Results.CountSound", {
			TimePosition = 0.85
		}) -- equivalent call inferred; original call site unknown
		local currencyName = "Pumpkins"
		local flag3 = false
		local v11 = v3
		pcall(function()
			local HolidayCurrencyModule = require(game.ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("HolidayCurrencyModule"))
			local uIDisplayInfo = HolidayCurrencyModule.GetUIDisplayInfo()

			if uIDisplayInfo.currencyName then
				currencyName = uIDisplayInfo.currencyName
			end

			if uIDisplayInfo.multiplier and uIDisplayInfo.multiplier > 1 then
				flag3 = true
				v11 = math.floor(v3 / uIDisplayInfo.multiplier)
			end
		end)

		if v3 <= 0 then
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayTotalAmount.Text = "You Earned... " .. 0 .. " " .. currencyName .. " This Match!"

			if flag3 then
				pcall(function()
					local HolidayCurrencyModule = require(game.ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("HolidayCurrencyModule"))
					local uIDisplayInfo = HolidayCurrencyModule.GetUIDisplayInfo()

					if uIDisplayInfo.showBadge then
						local parent2 = parent.DeathScreen.ResultsScreen.ResultsHolder:FindFirstChild("MultiplierBadge")

						if not parent2 then
							parent2 = Instance.new("TextLabel")
							parent2.Name = "MultiplierBadge"
							parent2.Size = UDim2.new(0.94, 0, 0.085, 0)
							parent2.Position = UDim2.new(0.5, 0, 0.05, 0)
							parent2.AnchorPoint = Vector2.new(0.5, 0)
							parent2.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
							parent2.BackgroundTransparency = 0
							parent2.BorderSizePixel = 4
							parent2.BorderColor3 = Color3.fromRGB(255, 255, 255)
							parent2.TextScaled = true
							parent2.Font = Enum.Font.GothamBold
							parent2.TextColor3 = Color3.fromRGB(0, 0, 0)
							parent2.TextStrokeTransparency = 0.8
							parent2.ZIndex = 10
							parent2.Parent = parent.DeathScreen.ResultsScreen.ResultsHolder
							local uICorner = Instance.new("UICorner")
							uICorner.CornerRadius = UDim.new(0.2, 0)
							uICorner.Parent = parent2
							local uIPadding = Instance.new("UIPadding")
							uIPadding.PaddingLeft = UDim.new(0.08, 0)
							uIPadding.PaddingRight = UDim.new(0.08, 0)
							uIPadding.PaddingTop = UDim.new(0.2, 0)
							uIPadding.PaddingBottom = UDim.new(0.2, 0)
							uIPadding.Parent = parent2
						end

						parent2.Text = uIDisplayInfo.badgeText
						parent2.Visible = true
					end
				end)
			end
		else
			parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayTotalAmount.Text = "You Earned... " .. v11 .. " " .. currencyName .. " This Match!"

			if not flag2 then
				task.wait(0.8)
			end

			if flag3 then
				pcall(function()
					local HolidayCurrencyModule = require(game.ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("HolidayCurrencyModule"))
					local uIDisplayInfo = HolidayCurrencyModule.GetUIDisplayInfo()

					if uIDisplayInfo.showBadge then
						local parent2 = parent.DeathScreen.ResultsScreen.ResultsHolder:FindFirstChild("MultiplierBadge")

						if not parent2 then
							parent2 = Instance.new("TextLabel")
							parent2.Name = "MultiplierBadge"
							parent2.Size = UDim2.new(0, 0, 0, 0)
							parent2.Position = UDim2.new(0.5, 0, 0.05, 0)
							parent2.AnchorPoint = Vector2.new(0.5, 0)
							parent2.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
							parent2.BackgroundTransparency = 0
							parent2.BorderSizePixel = 4
							parent2.BorderColor3 = Color3.fromRGB(255, 255, 255)
							parent2.TextScaled = true
							parent2.Font = Enum.Font.GothamBold
							parent2.TextColor3 = Color3.fromRGB(0, 0, 0)
							parent2.TextStrokeTransparency = 0.8
							parent2.ZIndex = 10
							parent2.Parent = parent.DeathScreen.ResultsScreen.ResultsHolder
							local uICorner = Instance.new("UICorner")
							uICorner.CornerRadius = UDim.new(0.2, 0)
							uICorner.Parent = parent2
							local uIPadding = Instance.new("UIPadding")
							uIPadding.PaddingLeft = UDim.new(0.08, 0)
							uIPadding.PaddingRight = UDim.new(0.08, 0)
							uIPadding.PaddingTop = UDim.new(0.2, 0)
							uIPadding.PaddingBottom = UDim.new(0.2, 0)
							uIPadding.Parent = parent2
						end

						parent2.Text = uIDisplayInfo.badgeText
						parent2.Visible = true

						if flag2 then
							parent2.Size = UDim2.new(0.94, 0, 0.085, 0)
						else
							local TweenService2 = game:GetService("TweenService")
							TweenService2:Create(
								parent2,
								TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
								{
									Size = UDim2.new(0.94, 0, 0.085, 0)
								}
							):Play()
							resultsAudio("Sounds.UI.Results.ElectricTick", nil) -- equivalent call inferred; original call site unknown
							resultsAudio("Sounds.UI.Results.Tick", nil) -- equivalent call inferred; original call site unknown
							task.wait(0.8)
						end
					end
				end)
			end

			if not flag2 then
				task.wait(0.2)
			end

			for i = v11 + 1, v3 do
				local v12 = 1 / math.max(1, v3 - v11)
				parent.DeathScreen.ResultsScreen.ResultsHolder.HolidayTotalAmount.Text = "You Earned... " .. i .. " " .. currencyName .. " This Match!"

				if not flag2 then
					task.wait(v12 * 0.8)
				end
			end
		end

		if not flag2 then
			task.wait(WAIT_INTERVAL)
		end
	end

	if flag2 then
		parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.TextTransparency = 0
		parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.TextStrokeTransparency = 0
	else
		local position6 = parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.Position
		local tween10 = TweenService:Create(parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount, tweenInfo4, {
			Position = position6
		})
		parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.Position = UDim2.new(
			position6.X.Scale,
			0,
			position6.Y.Scale * 1.25,
			0
		)
		parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.TextTransparency = 0
		parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.TextStrokeTransparency = 0
		tween10:Play()
	end

	resultsAudio("Sounds.UI.Results.ElectricTick", nil) -- equivalent call inferred; original call site unknown
	resultsAudio("Sounds.UI.Results.Tick", nil) -- equivalent call inferred; original call site unknown
	resultsAudio("Sounds.UI.Money.MoneyPopup", nil) -- equivalent call inferred; original call site unknown

	if not flag2 then
		task.wait(WAIT_INTERVAL)
	end

	resultsAudio("Sounds.UI.Results.CountSound", {
		TimePosition = 0.85
	}) -- equivalent call inferred; original call site unknown

	if p2 <= 0 then
		parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.Text = "You Earned... " .. 0 .. " Ichor This Match!"
	end

	local v11 = p2 + p6 + v8
	local total = 0

	while total < v11 do
		local v12 = 2 / v11

		if v11 >= 100 then
			total += 5
		else
			total += 1
		end

		if v11 <= total then
			parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.Text = "You Earned... " .. v11 .. " Ichor This Match!"
			break
		end

		parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.Text = "You Earned... " .. total .. " Ichor This Match!"

		if v12 <= 0.05 then
			if total % 2 ~= 0 and not flag2 then
				Audio:PlayOne("Sounds.UI.Buttons.Click", nil)
			end
		else
			resultsAudio("Sounds.UI.Buttons.Click", nil) -- equivalent call inferred; original call site unknown
		end

		if v11 >= 100 then
			if not flag2 then
				task.wait(v12 * 2)
			end
		elseif not flag2 then
			task.wait(v12)
		end
	end

	parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.Text = "You Earned... " .. v11 .. " Ichor This Match!"
	Audio:PlayOne("Sounds.UI.Money.MoneyCollected")

	if not flag2 then
		local position6 = parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.Position
		local tween10 = TweenService:Create(parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount, tweenInfo4, {
			Position = position6
		})
		parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.Position = UDim2.new(
			position6.X.Scale,
			0,
			position6.Y.Scale * 1.25,
			0
		)
		parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.TextTransparency = 0
		parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.TextStrokeTransparency = 0
		tween10:Play()
	end

	parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.ParticleEmitter.Enabled = true

	if not flag2 then
		task.wait(0.15)
	end

	parent.DeathScreen.ResultsScreen.ResultsHolder.IchorAmount.ParticleEmitter.Enabled = false

	if ichor15BoostActive and v11 > 0 then
		local parent2 = parent.DeathScreen.ResultsScreen.ResultsHolder:FindFirstChild("IchorBoost")

		if not parent2 then
			parent2 = Instance.new("Frame")
			parent2.Name = "IchorBoost"
			parent2.Size = UDim2.new(0, 0, 0, 0)
			parent2.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
			parent2.BorderSizePixel = 0
			parent2.Visible = false
			parent2.ZIndex = 10
			parent2.Parent = parent.DeathScreen.ResultsScreen.ResultsHolder
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0.2, 0)
			uICorner.Parent = parent2
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.Size = UDim2.fromScale(1, 1)
			textLabel.BackgroundTransparency = 1
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextScaled = true
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.TextStrokeTransparency = 0.5
			textLabel.ZIndex = 11
			textLabel.Parent = parent2
		end

		local textLabel = parent2:FindFirstChild("TextLabel")

		if textLabel then
			parent2.Size = UDim2.new(0, 0, 0, 0)
			textLabel.ZIndex = 10
			textLabel.Text = "+15% ICHOR BOOST APPLIED"
			textLabel.Visible = true
			parent2.Visible = true
		end

		if flag2 then
			parent2.Size = UDim2.new(0.94, 0, 0.085, 0)
		else
			TweenService:Create(parent2, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
				Size = UDim2.new(0.94, 0, 0.085, 0)
			}):Play()
			Audio:PlayOne("Sounds.UI.Results.ElectricTick")
			Audio:PlayOne("Sounds.UI.Results.Tick")
			task.wait(WAIT_INTERVAL)
		end
	end

	if not flag2 then
		task.wait(WAIT_INTERVAL)
	end

	if flag then
		parent.SpectateButton.Visible = true
	end

	parent.SkipButton.Visible = false
end

local v2 = false
parent.SpectateButton.Activated:Connect(function()
	local spectatorGui = parent.Parent:WaitForChild("SpectatorGui")

	if not v2 then
		v2 = true
		spectatorGui.ActivateSpectate:Fire()
		spectatorGui.Enabled = true
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
		TweenService:Create(parent.DeathScreen, tweenInfo, {
			Position = UDim2.new(0, 0, -1, 0)
		}):Play()
		Audio:PlayOne("Sounds.UI.Transitions.Closing")
		parent.SpectateButton.Visible = false
	end
end)
deathEvent.OnClientEvent:Connect(function(p, p2, p3, p4, p5, p6, p7, p8, p9, p10)
	flag = true
	setVersionLabelsVisible(true)

	if thread then
		task.cancel(thread)
		thread = nil
	end

	PlayDeathScreen(p, p2, p3, p4, p5, p6, p7, p8, p9, p10)

	local function disableProximityPrompts()
		local tagged = CollectionService:GetTagged("Prompt")

		for _, proximityPrompt in pairs(tagged) do
			if proximityPrompt:IsA("ProximityPrompt") then
				proximityPrompt.Enabled = false
			end
		end
	end

	disableProximityPrompts()
	thread = task.spawn(function()
		while flag and task.wait(1) do
			disableProximityPrompts()
		end
	end)
end)
task.spawn(function()
	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		for _ = 1, 50 do
			task.wait(0.1)
			events = ReplicatedStorage:FindFirstChild("Events")

			if events then
				break
			end
		end
	end

	if not events then
		return
	end

	local respawnEvent = events:FindFirstChild("RespawnEvent")

	if not respawnEvent then
		for _ = 1, 50 do
			task.wait(0.1)
			respawnEvent = events:FindFirstChild("RespawnEvent")

			if respawnEvent then
				break
			end
		end
	end

	if not respawnEvent then
		return
	end

	respawnEvent.OnClientEvent:Connect(function()
		flag = false
		setVersionLabelsVisible(false)

		if thread then
			task.cancel(thread)
			thread = nil
		end

		local tagged = CollectionService:GetTagged("Prompt")

		for _, proximityPrompt in pairs(tagged) do
			if proximityPrompt:IsA("ProximityPrompt") then
				proximityPrompt.Enabled = true
			end
		end

		parent.DeathScreen.Visible = false
		parent.DeathScreen.Position = UDim2.new(0, 0, -1, 0)
		screenGui.Enabled = true
		v2 = false
		parent.SpectateButton.Visible = false
		parent.SkipButton.Visible = false
		flag2 = false
		local spectatorGui = parent.Parent:FindFirstChild("SpectatorGui")

		if spectatorGui then
			spectatorGui.Enabled = false
		end

		print("[DeathScript] Respawn event received - death screen hidden, prompts re-enabled")
	end)
end)