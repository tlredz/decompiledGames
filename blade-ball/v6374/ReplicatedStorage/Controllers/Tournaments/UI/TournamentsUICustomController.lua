local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Shared.MapData)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Shared.TournamentData)
local tournaments = ReplicatedStorage2.Controllers.Tournaments
local v4 = require3(tournaments.TournamentsController)
local v5 = require3(tournaments.UI.TournamentsUIController)
local localPlayer = Players.LocalPlayer
local custom = v5.TabsFolder.Custom
local createRoom = custom.CreateRoom
local list = createRoom.List
local joinRoom = custom.JoinRoom

local function handleIntOption(instance, p: number, p2: number, p3: number, p4: number)
	local textLabel = instance.Controls:FindFirstChildWhichIsA("TextLabel") or instance.Controls.PriceList:FindFirstChildWhichIsA("TextLabel")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update(p5: number)
		if p5 == instance:GetAttribute("Value") then
			return
		end

		textLabel.Text = v.ValueConvertor:AddCommas(p5)
		instance:SetAttribute("Value", p5)
	end

	update(p) -- equivalent call inferred; original call site unknown
	local activatedConnection = instance.Controls["<"].Activated:Connect(function()
		update(math.max(p2, instance:GetAttribute("Value") - p4)) -- equivalent call inferred; original call site unknown
	end)
	local activatedConnection2 = instance.Controls[">"].Activated:Connect(function()
		update(math.min(p3, instance:GetAttribute("Value") + p4)) -- equivalent call inferred; original call site unknown
	end)
	return function()
		activatedConnection:Disconnect()
		activatedConnection = nil
		activatedConnection2:Disconnect()
		activatedConnection2 = nil
	end
end

local function handleMapOption(map, list2)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update(p: number)
		local v6 = list2[p]
		local v7 = v2[v6]
		map.Controls.Label.Text = v7.DisplayName
		map.MapImage.MapImage.Image = v7.Image
		map:SetAttribute("Value", v6)
		map:SetAttribute("Index", p)
	end

	update(1) -- equivalent call inferred; original call site unknown
	local activatedConnection = map.Controls["<"].Activated:Connect(function()
		update((map:GetAttribute("Index") - 2) % #list2 + 1) -- equivalent call inferred; original call site unknown
	end)
	local activatedConnection2 = map.Controls[">"].Activated:Connect(function()
		update(map:GetAttribute("Index") % #list2 + 1) -- equivalent call inferred; original call site unknown
	end)
	return function()
		activatedConnection:Disconnect()
		activatedConnection = nil
		activatedConnection2:Disconnect()
		activatedConnection2 = nil
	end
end

local function handleOptionsOption(privacy, list2)
	local function update(p: number)
		local v6 = list2[p]
		privacy.Controls.Label.Text = v6.DisplayName
		privacy.Controls.Label.TextColor3 = v6.TextColor3 or Color3.new(1, 1, 1)
		privacy:SetAttribute("Value", v6.Name)
		privacy:SetAttribute("Index", p)
	end

	update(1)
	local activatedConnection = privacy.Controls["<"].Activated:Connect(function()
		update((privacy:GetAttribute("Index") - 2) % #list2 + 1)
	end)
	local activatedConnection2 = privacy.Controls[">"].Activated:Connect(function()
		update(privacy:GetAttribute("Index") % #list2 + 1)
	end)
	return function()
		activatedConnection:Disconnect()
		activatedConnection = nil
		activatedConnection2:Disconnect()
		activatedConnection2 = nil
	end
end

local RunService = game:GetService("RunService")
local fn = not RunService:IsStudio() and game.GameId == 4777817887 and function(...) end or print
return {
	Start = function(_)
		custom.List.BrowseRooms.Activated:Connect(function()
			v5:SwitchView("Rooms")
		end)
		custom.List.CreateRoom.Activated:Connect(function()
			createRoom.Visible = true
		end)
		custom.List.JoinRoom.Activated:Connect(function()
			joinRoom.Visible = true
			joinRoom.TextBox.Text = ""
		end)
		joinRoom.Close.Activated:Connect(function()
			joinRoom.Visible = false
		end)
		joinRoom.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = string.upper(joinRoom.TextBox.Text)
			local trimmed = v.String.Trim(text)
			local text2 = string.sub(string.gsub(trimmed, "%p", ""), 1, 6)
			joinRoom.TextBox.Text = text2
		end)
		local thread = nil
		joinRoom.Enter.Activated:Connect(function()
			local v6, text = v4.Remotes.JoinTournamentRoom:InvokeServer(joinRoom.TextBox.Text, true)
			fn(v6, text)

			if not v6 then
				if thread then
					task.cancel(thread)
					thread = nil
				end

				joinRoom.Error.Text = text
				thread = task.delay(5, function()
					joinRoom.Error.Text = ""
				end)
			end
		end)
		list.Title.TextBox.Text = `{localPlayer.Name}'s Room`
		createRoom.Close.Activated:Connect(function()
			createRoom.Visible = false
		end)
		handleOptionsOption(list.Privacy, {
			{
				Name = "Public",
				DisplayName = "Public",
				TextColor3 = Color3.fromRGB(99, 238, 94)
			},
			{
				Name = "Private",
				DisplayName = "Private",
				TextColor3 = Color3.fromRGB(238, 30, 30)
			}
		})
		handleIntOption(list.Players, 4, 4, 16, 4)
		local v6 = handleIntOption(list.Rounds, 1, 1, 1, 1)
		list.Players:GetAttributeChangedSignal("Value"):Connect(function()
			if v6 then
				v6()
				v6 = nil
			end

			local value = list.Players:GetAttribute("Value")

			if value == 4 then
				v6 = handleIntOption(list.Rounds, 1, 1, 1, 1)
			elseif value == 8 then
				v6 = handleIntOption(list.Rounds, 1, 2, 2, 1)
			elseif value == 12 then
				v6 = handleIntOption(list.Rounds, 2, 2, 2, 1)
			elseif value == 16 then
				v6 = handleIntOption(list.Rounds, 2, 2, 2, 1)
			end
		end)
		handleIntOption(list.Prize, 1, 1, #v3.CoinTournaments, 1)

		local function updatePrize()
			local entryFee = v3.CoinTournaments[list.Prize:GetAttribute("Value")].EntryFee
			local v7 = list.Players:GetAttribute("Value") * entryFee * 0.75
			list.Prize.Controls.PriceList.Amount.Text = v.ValueConvertor:AddCommas(v7)
			list.Prize:SetAttribute("TrueValue", v7)
			createRoom.CreateButton.PriceList.Amount.Text = v.ValueConvertor:AddCommas(entryFee)
			createRoom.CreateButton:SetAttribute("Value", entryFee)
		end

		updatePrize()
		list.Players:GetAttributeChangedSignal("Value"):Connect(updatePrize)
		list.Prize:GetAttributeChangedSignal("Value"):Connect(updatePrize)
		local v7 = {}

		for k, v8 in v2 do
			if v8.DisabledInTraining or k == "TrainingMode" then
				continue
			end

			table.insert(v7, k)
		end

		handleMapOption(list.Map, v7)
		local thread2 = nil
		createRoom.CreateButton.Activated:Connect(function()
			local v8, text = v4.Remotes.CreateTournamentRoom:InvokeServer({
				Name = list.Title.TextBox.Text,
				Players = list.Players:GetAttribute("Value"),
				Privacy = list.Privacy:GetAttribute("Value"),
				Rounds = list.Rounds:GetAttribute("Value"),
				EntryFee = createRoom.CreateButton:GetAttribute("Value"),
				Map = list.Map:GetAttribute("Value")
			})
			fn(v8, text)

			if not v8 then
				if thread2 then
					task.cancel(thread2)
					thread2 = nil
				end

				createRoom.Error.Text = text
				thread2 = task.delay(5, function()
					createRoom.Error.Text = ""
				end)
			end
		end)
	end
}