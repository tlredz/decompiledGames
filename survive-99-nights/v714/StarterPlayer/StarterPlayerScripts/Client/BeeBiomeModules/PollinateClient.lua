local PollinateClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local ContextActionService = game:GetService("ContextActionService")
local v = false
local v2 = false
local pollination = nil
local pollinateFrame = Client.Interface.PollinateFrame
local honeyGif = pollinateFrame.HoneyGif
local v3 = {
	"rbxassetid://110268386949862",
	"rbxassetid://127960525074411",
	"rbxassetid://98805796776464",
	"rbxassetid://103810099853021",
	"rbxassetid://92094526545168"
}
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(232, 174, 0)
local color3 = Color3.fromRGB(255, 0, 0)
local v4 = 0
local v5 = false
local random = Random.new()
local v6 = {
	beehive = {
		Color = "yellow"
	},
	flowers = {
		Color = Color3.fromRGB(255, 85, 255),
		GroupSize = 40
	},
	["Strawberry Plant"] = {
		Color = Color3.fromRGB(255, 85, 85),
		GroupSize = 3
	},
	["Brightwood Tree"] = {
		Color = Color3.fromRGB(255, 213, 128),
		GroupSize = 3
	},
	["Chilli Plant"] = {
		Color = Color3.fromRGB(255, 60, 60),
		GroupSize = 3
	}
}
local color4 = Color3.fromRGB(255, 255, 255)

function PlayHoneyGif()
	if v5 or not (pollinateFrame.Visible and honeyGif.Visible) then
		return
	end

	v5 = true
	task.spawn(function()
		local v7 = 1

		while pollinateFrame.Visible and honeyGif.Visible do
			honeyGif.Image = v3[v7]
			v7 = v7 % #v3 + 1
			task.wait(v4 * -0.1 + 0.2)
		end

		v5 = false
	end)
end

function UpdatePollinationFrame()
	local honeyRequired1 = pollination:GetAttribute("HoneyRequired1")
	local honeyRequired2 = pollination:GetAttribute("HoneyRequired2")
	local honeyRequired3 = pollination:GetAttribute("HoneyRequired3")
	local totalHoney = workspace:GetAttribute("TotalHoney") or 0

	if not (honeyRequired1 and honeyRequired3) then
		return
	end

	pollinateFrame.PollinationStrength.HoneyCounter1.TextLabel.Text = honeyRequired1
	pollinateFrame.PollinationStrength.HoneyCounter2.TextLabel.Text = honeyRequired2
	pollinateFrame.PollinationStrength.HoneyCounter3.TextLabel.Text = honeyRequired3
	local v7 = math.clamp((totalHoney - honeyRequired1) / (honeyRequired3 - honeyRequired1), 0, 1)
	v4 = v7
	local v8 = color

	if v7 >= 0.6666666666666666 then
		v8 = color3
	elseif v7 >= 0.3333333333333333 then
		v8 = color2
	end

	honeyGif.ImageColor3 = v8
	honeyGif.Visible = v7 >= 0.6666666666666666
	PlayHoneyGif()

	if totalHoney < honeyRequired1 then
		local v9 = totalHoney / honeyRequired1 * 0.3333333333333333
		pollinateFrame.PollinationStrength.Bar.Size = UDim2.new(v9, 0, 1, 0)
	else
		local v9 = v7 * 0.6666666666666666 + 0.3333333333333333
		local v10 = honeyRequired3 <= totalHoney and 1 or v9
		pollinateFrame.PollinationStrength.Bar.Size = UDim2.new(v10, 0, 1, 0)
	end

	local v9 = math.round(v7 * 1000) / 10
	pollinateFrame.StrengthIndicator.Text = "Strength: " .. v9 .. "%"
	pollinateFrame.StrengthIndicator.TextColor3 = v8
	local pollinationComplete = pollination:GetAttribute("PollinationComplete")

	if pollinationComplete then
		pollinateFrame.PollinateButton.CurrencyCounter.TextLabel.Text = "Complete"
	else
		pollinateFrame.PollinateButton.CurrencyCounter.TextLabel.Text = "Pollinate"
	end

	if honeyRequired1 <= totalHoney and not pollinationComplete then
		pollinateFrame.PollinateButton.BackgroundColor3 = Color3.fromRGB(102, 200, 46)
		pollinateFrame.PollinateButton.UIStroke.Color = Color3.fromRGB(76, 172, 22)
	else
		pollinateFrame.PollinateButton.BackgroundColor3 = Color3.fromRGB(177, 177, 177)
		pollinateFrame.PollinateButton.UIStroke.Color = Color3.fromRGB(139, 141, 139)
	end
end

pollinateFrame.CloseButton.MouseButton1Click:Connect(function()
	pollinateFrame.Visible = false
end)
pollinateFrame:GetPropertyChangedSignal("Visible"):Connect(PlayHoneyGif)
ContextActionService:BindAction("CloseGiantBeehive", function()
	if pollinateFrame.Visible then
		pollinateFrame.Visible = false
	end
end, false, Enum.KeyCode.ButtonB)
pollinateFrame.PollinateButton.MouseButton1Click:Connect(function()
	if Client.PingClient.PingActive then
		return
	end

	UpdatePollinationFrame()

	if pollination:GetAttribute("PollinationComplete") then
		Client.PopUpUI.AddPopUp("the giant beehive has fully bloomed", "warning")
		return
	end

	if pollination:GetAttribute("HoneyRequired1") > workspace:GetAttribute("TotalHoney") then
		Client.PopUpUI.AddPopUp("There isn't enough honey for this", "warning")
		return
	end

	if not v2 then
		if Client.WarningClient.ShowWarning({
			Description = "Are you sure? Pollinating resets all the bee hives and all your honey",
			ConfirmText = "Yes",
			CancelText = "No"
		}) ~= "Confirm" then
			return
		end

		v2 = true
	end

	pollinateFrame.Visible = false
	Client.Events.RequestPollinateServer:FireServer()
end)
Client.InteractionHandler.RegisterInteraction("GiantBeeHive", function()
	pollinateFrame.Visible = true
end)

function SplitIntoGroups(p, p2)
	local v7 = math.max(1, (math.round(p / p2)))
	local result = {}

	for i = 1, v7 do
		if i == v7 then
			table.insert(result, p)
		else
			local v8 = math.min(
				math.max(1, (math.round(p / (v7 - i + 1) * (0.7 + random:NextNumber() * 0.6)))),
				p - (v7 - i)
			)
			table.insert(result, v8)
			p -= v8
		end
	end

	return result
end

function ShowPollinationMessages(items)
	local v7 = {}

	for _, item in pairs(items) do
		local v8 = v6[item.Name]
		local color5 = v8 and v8.Color or color4
		local quantity = item.Quantity or 0
		local name = string.lower(item.Name)

		if not (quantity >= 1) then
			continue
		end

		if v8 and v8.GroupSize then
			for _, v9 in pairs(SplitIntoGroups(quantity, v8.GroupSize)) do
				table.insert(v7, {
					Text = "x" .. v9 .. " " .. name .. " grown",
					Color = color5
				})
			end
		else
			for _ = 1, quantity do
				table.insert(v7, {
					Text = "x1 " .. name .. " grown",
					Color = color5
				})
			end
		end
	end

	local v8 = 2 + random:NextNumber()

	for _, v9 in pairs(v7) do
		v9.Time = v8 + random:NextNumber() * (9.5 - v8)
	end

	table.sort(v7, function(a, b)
		return a.Time < b.Time
	end)
	task.spawn(function()
		local time = 0

		for k, v9 in pairs(v7) do
			task.wait(v9.Time - time)
			time = v9.Time

			if Client.BiomesClient.GetCurrentBiome() ~= "Bees" then
				continue
			end

			local text = v9.Text

			if k % 2 == 0 then
				text ..= "​"
			end

			Client.PopUpUI.AddPopUp(text, v9.Color)
			Client.Sound.Play("PollinationPlantPlanted", {
				Duplicate = true
			})
		end
	end)
end

function UpdatePollinationSound()
	local v7

	if workspace:GetAttribute("Pollinating") == true then
		v7 = Client.BiomesClient.GetCurrentBiome() == "Bees"
	else
		v7 = false
	end

	if v7 == v then
		return
	end

	v = v7

	if v7 then
		Client.Sound.Play("Pollination")
	else
		Client.Events.StopSound:Fire("Pollination", {
			FadeTime = 3
		})
	end
end

function PollinateClient.Init()
	workspace:GetAttributeChangedSignal("Pollinating"):Connect(UpdatePollinationSound)
	Client.Events.BiomeEntered:Connect(UpdatePollinationSound)
	Client.Events.PollinationSpawnMessages:Connect(ShowPollinationMessages)
	UpdatePollinationSound()
	task.spawn(function()
		pollination = game.ReplicatedStorage.Shops:WaitForChild("Pollination")
		pollination.AttributeChanged:Connect(UpdatePollinationFrame)
		workspace:GetAttributeChangedSignal("TotalHoney"):Connect(UpdatePollinationFrame)
		UpdatePollinationFrame()
	end)
end

return PollinateClient