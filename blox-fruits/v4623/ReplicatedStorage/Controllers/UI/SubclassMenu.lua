local modules = game.ReplicatedStorage:WaitForChild("Modules")
require(modules.Net)
local Trove = require(modules.Util.Trove)
local TextUtil = require(modules.Util.TextUtil)
local v = nil
local SubclassController = require(game.ReplicatedStorage.Controllers.SubclassController)
local SubclassMenu = {
	screen = nil
}
local bindableEvent = Instance.new("BindableEvent")
local localPlayer = game.Players.LocalPlayer
local rawData = nil
local screen = nil
local v3 = nil
local v4 = nil
local maid = nil
local v5 = { "I", "II", "III" }
local v6 = {
	Yellow = {
		Buy = {
			BackgroundColor3 = Color3.fromRGB(255, 214, 49),
			BorderColor3 = Color3.fromRGB(255, 240, 69)
		},
		Trans = {
			BackgroundColor3 = Color3.fromRGB(255, 241, 87)
		}
	},
	Grey = {
		Buy = {
			BackgroundColor3 = Color3.fromRGB(125, 125, 125),
			BorderColor3 = Color3.fromRGB(100, 100, 100)
		},
		Trans = {
			BackgroundColor3 = Color3.fromRGB(150, 150, 150)
		}
	}
}

local function changeButtonColor(folder, p)
	local v7 = v6[p]

	-- equivalent calls inferred from this helper; original call sites unknown
	local function process(p2)
		local v8 = v7[p2.Name]

		if not v8 then
			return
		end

		for k, v9 in v8 do
			p2[k] = v9
		end
	end

	process(folder) -- equivalent call inferred; original call site unknown

	for _, descendant in folder:GetDescendants() do
		process(descendant) -- equivalent call inferred; original call site unknown
	end
end

local function selectPassive(p, p2)
	v3 = p
	v4 = p2
	local subclassData = SubclassController:GetSubclassData()
	local passive = p.Passives[p2]
	local priceList = screen:FindFirstChild("PriceList", true)

	for _, frame in priceList:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	local v7 = subclassData.Purchased[p.Name]
	local passive2 = v7.Passives[passive.Name]
	local v8 = not passive2 and 1 or passive2.Level or 1
	local level = passive.Levels[v8]
	local v9 = passive2 ~= nil
	local v10 = v8 == #passive.Levels
	local buy = screen:FindFirstChild("Buy", true)
	local passiveInfo = screen:FindFirstChild("PassiveInfo", true)
	passiveInfo.Right.Visible = true
	passiveInfo.Right.Upgrade.Visible = false
	passiveInfo.Right.Description.TextLabel.Text = level.Description.Current
	passiveInfo.Right.Title.TextLabel.Text = passive.DisplayName .. " " .. (not v9 and "" or v5[v8] or "")

	if v10 and v9 then
		buy.TextLabel.Text = "Max Level"
		changeButtonColor(buy, "Grey")
	elseif v9 and not v10 then
		if level.Description.Upgrade then
			passiveInfo.Right.Upgrade.TextLabel.Text = level.Description.Upgrade
			passiveInfo.Right.Upgrade.Visible = true
		end

		buy.TextLabel.Text = "Upgrade"
		changeButtonColor(buy, "Yellow")
	elseif v9 then
		warn("IDK")
	elseif v7.Level >= passive.LevelRequirement then
		buy.TextLabel.Text = "Purchase"
		changeButtonColor(buy, "Yellow")
	else
		buy.TextLabel.Text = string.format("Lv. %s Required", passive.LevelRequirement)
		changeButtonColor(buy, "Grey")
	end

	if not v10 or v10 and passive.UnlockOrder > 1 and not v9 then
		for k, v11 in (v9 and passive.Levels[v8 + 1] or passive.Levels[1]).Cost do
			local clone = script.PriceTile:Clone()

			if k == "Fragments" then
				clone.Icon:Destroy()
				clone.FragmentLabel.Visible = true
				clone.AmountLabel.TextColor3 = Color3.fromRGB(177, 121, 255)
				clone.LayoutOrder = 2
			elseif k == "Valor" then
				clone.Icon.ImageColor3 = Color3.fromRGB(85, 255, 255)
				clone.AmountLabel.TextColor3 = Color3.fromRGB(85, 255, 255)
				clone.LayoutOrder = 1
			end

			clone.AmountLabel.Text = TextUtil.commaValue(v11)
			clone.Parent = priceList
		end
	end

	bindableEvent:Fire()
end

function SubclassMenu:Open(p)
	if maid then
		maid:Destroy()
		maid = nil
	end

	maid = Trove.new()
	local subclassData = SubclassController:GetSubclassData()
	local v7 = rawData[p]
	local v8 = subclassData.Purchased[p]
	local passives = {}

	for k, passive in v7.Passives do
		passive.Name = k
		table.insert(passives, passive)
	end

	table.sort(passives, function(a, b)
		return a.UnlockOrder < b.UnlockOrder
	end)
	local window = screen.Window
	window.Title.Header.Text = v7.DisplayName

	for k, v9 in passives do
		local clone = script.PassiveTile:Clone()
		clone.LayoutOrder = k
		clone.Name = k
		local v10 = nil
		local v11 = v9
		local v12 = k
		local levelLabel = clone.LevelLabel

		local function reflectText()
			local passive = v8.Passives[v11.Name]
			local visible = passive ~= nil
			local v16

			if v12 > 1 then
				v16 = passives[v12 - 1]
			else
				v16 = false
			end

			local v17 = v16 and v8.Passives[v16.Name] ~= nil
			v10 = not (visible or v17)
			local button = clone.Button
			button.Text = v10 and "???" or v11.DisplayName

			if v10 then
				button.TextColor3 = Color3.fromRGB(150, 150, 150)
			elseif v4 == v11.Name then
				button.TextColor3 = Color3.fromRGB(255, 255, 50)
			else
				button.TextColor3 = Color3.fromRGB(255, 255, 255)
			end

			local level = passive and passive.Level
			levelLabel.Text = v5[level] or ""
			levelLabel.Visible = visible
		end

		reflectText()
		maid:Add(SubclassController:Connect("Upgrade", reflectText))
		maid:Add(bindableEvent.Event:Connect(reflectText))
		local v15 = v9
		clone.Button.Activated:Connect(function()
			if v10 then
				return
			end

			selectPassive(v7, v15.Name)
		end)

		if k == 5 then
			clone.Divider:Destroy()
		end

		clone.Parent = window.Content.PassiveList
	end

	selectPassive(v7, "Base")
	local footer = screen:FindFirstChild("Footer", true)
	local experience = v8.Experience
	local level = v8.Level
	local v9 = v(level)
	footer.CurrentLevel.Text = "Lv. " .. level
	footer.NextLevel.Text = "Lv. " .. level + 1
	local v10 = experience / v9
	footer.ExpBar.Fill.Size = UDim2.fromScale(v10, 1)
	footer.ExpBar.SubclassExp.Text = string.format("%s/%s", experience, v9)
	screen.Enabled = true
end

function SubclassMenu.OnStart(_)
	local EXPFunction = require(game.ReplicatedStorage:WaitForChild("EXPFunction"))
	v = EXPFunction
	local PlayerUtil = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PlayerUtil"))
	PlayerUtil.ScreenReady({ "SubclassMenu" }, function(p)
		screen = assert(p.SubclassMenu, "bad package.SubclassMenu")
		SubclassMenu.screen = screen
		local subclassNetwork = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SubclassNetwork")
		local window = screen.Window
		local footer = window.Footer
		rawData = SubclassController:GetRawData()

		local function resetUIState()
			for _, frame in window.Content.PassiveList:GetChildren() do
				if frame:IsA("Frame") then
					frame:Destroy()
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function close()
			screen.Enabled = false
			v3 = nil
			v4 = nil

			if maid then
				maid:Destroy()
				maid = nil
			end

			resetUIState()
		end

		close() -- equivalent call inferred; original call site unknown
		window.Title.Exit.Activated:Connect(close)
		local valor = localPlayer:WaitForChild("Data"):WaitForChild("Valor")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function reflectValor()
			local value = valor.Value
			footer.ValorFrame.AmountLabel.Text = TextUtil.commaValue(value) .. " Valor"
		end

		reflectValor() -- equivalent call inferred; original call site unknown
		valor.Changed:Connect(reflectValor)

		local function onUpgrade()
			selectPassive(v3, v4)
		end

		SubclassController:Connect("Upgrade", onUpgrade)
		local flag = false
		screen:FindFirstChild("Buy", true).Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			local v7 = v4

			if subclassNetwork.PurchasePassive:InvokeServer(v3.Name, v7) then
				resetUIState()
				SubclassMenu:Open(v3.Name)
				selectPassive(v3, v7)
			end

			flag = false
		end)
		local RunService = game:GetService("RunService")

		if RunService:IsStudio() then
			localPlayer.Chatted:Connect(function(p2)
				if p2 == "opensubclass" then
					SubclassMenu:Open("Shipwright")
				end
			end)
		end
	end, (`Init {script.Name}`))
end

return SubclassMenu