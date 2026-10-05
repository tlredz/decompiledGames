local TweenService = game:GetService("TweenService")
local NextDayUI = {}
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local Client = require(localPlayer.PlayerScripts.Client)
NextDayUI.ShowStats = false
local dayCounter = nil
local v = {
	Child = "rbxassetid://73493391958749",
	DinoKid = "rbxassetid://121449900145567",
	KrakenKid = "rbxassetid://77472890633753",
	SquidKid = "rbxassetid://134985233785118",
	KoalaKid = "rbxassetid://79333092233804",
	Bed = "rbxassetid://132092466162777"
}
local v2 = {
	["Pelt Trader"] = "rbxassetid://132410718372977",
	Cultists = "rbxassetid://119751387396136",
	HungryDeer = "rbxassetid://131630553114414",
	["Furniture Trader"] = "rbxassetid://129241006049217",
	Aliens = "rbxassetid://108156403175009",
	MegaCultists = "rbxassetid://93564647560872",
	Pollination = "rbxassetid://85322830881696"
}
local v3 = {
	Chillis = "rbxassetid://92995092410409",
	Berries = "rbxassetid://73827292953055",
	Fireflies = "rbxassetid://125472822187494",
	Flowers = "rbxassetid://84459296274799",
	Strawberries = "rbxassetid://78204482365076",
	Roses = "rbxassetid://96948198066204",
	["Brightwood Trees"] = "rbxassetid://116822444920352"
}
local v4 = {
	Cultists = "Something evil is approaching your campfire... it arrives tonight",
	HungryDeer = "The deer is hungry tonight",
	["Furniture Trader"] = "The Furniture Trader is wandering through the Forest today",
	Aliens = "Some Aliens have crash landed in the Forest",
	MegaCultists = "A MEGA Cultist Wave is approaching your campfire... it arrives tonight",
	Pollination = "The Bee Biome has been pollinated"
}

function DayDisplay(p, p2, list, p3)
	dayCounter.Size = UDim2.new(0.156, 0, 0.159, 0)
	dayCounter.Position = UDim2.new(0.5, 0, 0.094, 0)
	dayCounter.Text = "Day " .. p2 + 1
	dayCounter.TextColor3 = Color3.new(0, 0, 0)
	TweenService:Create(dayCounter, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextColor3 = Color3.fromRGB(255, 255, 255)
	}):Play()
	wait(6)
	dayCounter.Multiplier.Visible = true

	for _, child in pairs(dayCounter.Icons:GetChildren()) do
		if child.Name == "Icon" then
			child:Destroy()
		end
	end

	dayCounter.Icons.Visible = true

	if list then
		local v5 = #list

		for i = 1, #list do
			local clone = dayCounter.Icons.Template:Clone()
			clone.Name = "Icon"
			clone.Image = v[list[i]] or "rbxassetid://73493391958749"
			clone.Parent = dayCounter.Icons
			clone.Visible = true
		end

		dayCounter.Multiplier.Count.Text = "x" .. v5 + 1
	end

	wait(2)
	local intValue = Instance.new("IntValue")
	intValue.Value = p2
	TweenService:Create(intValue, TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Value = p
	}):Play()
	intValue:GetPropertyChangedSignal("Value"):Connect(function()
		dayCounter.Text = "Day " .. intValue.Value
	end)
	wait(4)
	dayCounter.Multiplier.Visible = false
	dayCounter.Icons.Visible = false
	dayCounter.Size = UDim2.new(0.051, 0, 0.052, 0)
	dayCounter.Position = UDim2.new(0.5, 0, 0.01, 0)
	local v5 = false

	if #p3.npcs > 0 or #p3.plants > 0 or NextDayUI.ShowStats then
		if NextDayUI.ShowStats then
			dayCounter.InfoFrame.StatBoxes.Visible = true
		else
			dayCounter.InfoFrame.StatBoxes.Visible = false
		end

		local count = 0

		if p3 then
			for _, npc in pairs(p3.npcs) do
				v5 = true
				local clone = dayCounter.InfoFrame.ArrivalTemplate:Clone()
				clone.Parent = dayCounter.InfoFrame

				if v4[npc] then
					clone.TextLabel.Text = v4[npc]
				else
					clone.TextLabel.Text = "The " .. npc .. " has arrived today"
				end

				count += 1
				clone.ImageLabel.Image = v2[npc]
				clone.Name = "DeleteMe"
				clone.Visible = true
			end

			for _, plant in pairs(p3.plants) do
				for k, v6 in pairs(plant) do
					print(k)

					if not (v3[k] or Client.Databases.FairyPlants[k].Ingredient) then
						continue
					end

					local clone = dayCounter.InfoFrame.ArrivalTemplate:Clone()
					clone.Parent = dayCounter.InfoFrame
					clone.TextLabel.Text = `{k} have grown on the map (lvl {v6})`
					count += 1
					clone.ImageLabel.Image = v3[k] or Client.Databases.FairyPlants[k].Ingredient
					clone.Name = "DeleteMe"
					clone.Visible = true
					v5 = true
				end
			end
		end

		if #p3.npcs > 0 or #p3.plants > 0 and v5 or NextDayUI.ShowStats then
			dayCounter.InfoButton.Visible = true
			dayCounter.InfoButton.BackgroundColor3 = Color3.fromRGB(255, 225, 0)

			if table.find(p3.npcs, "Cultists") or table.find(p3.npcs, "HungryDeer") or table.find(
				p3.npcs,
				"MegaCultists"
			) then
				task.spawn(function()
					wait(1.5)
					dayCounter.InfoButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				end)
			end

			dayCounter.InfoButton.ImageLabel.TextLabel.Text = tostring((math.max(1, count)))

			if #p3.npcs > 0 then
				dayCounter.InfoButton.ImageLabel.Visible = true
			else
				dayCounter.InfoButton.ImageLabel.Visible = false
			end

			task.spawn(function()
				wait(25)
				CloseInfoFrame()
			end)
		end
	end
end

function CloseInfoFrame()
	dayCounter.InfoButton.Visible = false
	dayCounter.CloseButton.Visible = false
	dayCounter.InfoFrame.Visible = false

	for _, child in pairs(dayCounter.InfoFrame:GetChildren()) do
		if child.Name == "DeleteMe" then
			child:Destroy()
		end
	end
end

Client.Events.DayDisplay:Connect(function(p, p2, p3, p4)
	DayDisplay(p, p2, p3, p4)
end)

function NextDayUI.Init()
	dayCounter = playerGui:WaitForChild("Interface"):WaitForChild("DayCounter")
	dayCounter.InfoButton.MouseButton1Down:Connect(function()
		Client.Sound.Play("KeyPress", {
			Duplicate = true
		})
		dayCounter.InfoButton.Visible = false
		dayCounter.InfoFrame.Visible = true
		dayCounter.CloseButton.Visible = true
	end)
	dayCounter.CloseButton.MouseButton1Down:Connect(function()
		Client.Sound.Play("CloseButton")
		CloseInfoFrame()
	end)
	dayCounter.Text = "Day " .. (workspace:GetAttribute("StoryDayCounter") or 1)
end

return NextDayUI