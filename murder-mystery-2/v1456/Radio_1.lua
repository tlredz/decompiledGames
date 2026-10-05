local game2 = script.Parent.Parent:WaitForChild("Game")
local radio = game2:WaitForChild("Settings"):WaitForChild("Radio")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local radio2 = game2.Radio
WindowService:RegisterFrame(radio2, "Radio")
local radio3 = game.Players.LocalPlayer:GetAttribute("Radio")
require(game.ReplicatedStorage.Modules.AudioSearcher)
local v = game.PlaceId == 335132309 or game.PlaceId == 333740520
local v2 = game.PlaceId == 5895823254 or game.PlaceId == 5928494131
local scrollFrame = radio2.Main.MySongs.ScrollFrame
local adder = radio2.Main.MySongs.Adder
local search = radio2.Main.Search
local scrollFrame2 = radio2.Main.Search.ScrollFrame
local searcher = radio2.Main.Search.Searcher

function unescape(value)
	local v3 = string.gsub(value, "&lt;", "<")
	local v4 = string.gsub(v3, "&gt;", ">")
	local v5 = string.gsub(v4, "&quot;", "\"")
	local v6 = string.gsub(v5, "&apos;", "'")
	local v7 = string.gsub(v6, "&#(%d+);", function(p)
		if tonumber(p) and tonumber(p) < 126 then
			return (string.char((tonumber(p))))
		end

		return ""
	end)
	local v8 = string.gsub(v7, "&#x(%d+);", function(p)
		if tonumber(p) and tonumber(p) < 126 then
			return (string.char((tonumber(p))))
		end

		return ""
	end)
	local v9 = string.gsub(v8, ".", function(value2)
		local v10 = string.byte(value2)

		if v10 and v10 < 126 then
			return value2
		end

		return ""
	end)
	return (string.gsub(v9, "&amp;", "&"))
end

if v or v2 then
	if v then
		pcall(function()
			game.Workspace.Lobby.RadioGamepass:Destroy()
		end)
	end
else
	local v3 = unpack({ game.ReplicatedStorage.Remotes.Extras.GetData:InvokeServer("RadioSongs") })

	for _, child in pairs(radio2.Nav:GetChildren()) do
		local v4 = child
		child.MouseButton1Click:connect(function()
			script.Preview:Stop()
			script.Preview.SoundId = ""

			for i, child2 in pairs(radio2.Nav:GetChildren()) do
				child2.Style = child2 == v4 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
			end

			for i, child2 in pairs(radio2.Main:GetChildren()) do
				child2.Visible = child2.Name == v4.Name
			end
		end)
	end

	local v4 = false
	game.ReplicatedStorage.Remotes.Gameplay.RoleSelect.OnClientEvent:connect(function(_, _, _, _)
		v4 = true
	end)
	game.ReplicatedStorage.Remotes.Shop.GetRadio.OnClientEvent:connect(function()
		v4 = true
	end)
	local UpdateSongList

	UpdateSongList = function()
		scrollFrame:ClearAllChildren()

		for k, v5 in pairs(v3) do
			local clone = script.Song:Clone()
			clone.Container.SongName.Text = v5.Name
			local v6 = v5
			clone.Container.Play.MouseButton1Click:connect(function()
				if v4 and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.Humanoid.Health > 0 then
					if radio3 then
						game.ReplicatedStorage.Remotes.Inventory.PlaySong:FireServer(v6.ID)
					else
						game.ReplicatedStorage.Remotes.Shop.GetRadio:FireServer()
					end
				else
					radio2.Main.MySongs.Wait.Visible = true
					wait(2)
					radio2.Main.MySongs.Wait.Visible = false
				end
			end)
			local v7 = k
			clone.Container.Delete.MouseButton1Click:connect(function()
				table.remove(v3, v7)
				game.ReplicatedStorage.Remotes.Inventory.RemoveSong:FireServer(v7)
				UpdateSongList()
			end)
			clone.Position = UDim2.new(0, 0, 0, (k - 1) * clone.Size.Y.Offset)
			clone.Parent = scrollFrame
		end
	end

	local function AddSong(p, unescaped)
		local ID = nil

		if unescaped == nil then
			pcall(function()
				if tonumber(p) then
					local MarketplaceService = game:GetService("MarketplaceService")
					local productInfo = MarketplaceService:GetProductInfo(p)

					if productInfo and productInfo.AssetTypeId == 3 then
						ID = "https://www.roblox.com/asset/?id=" .. p
						unescaped = unescape(productInfo.Name)
					end
				end
			end)
		else
			ID = "https://www.roblox.com/asset/?id=" .. p
		end

		if ID then
			for _, v6 in pairs(v3) do
				if v6.ID == ID then
					return
				end
			end

			table.insert(v3, 1, {
				ID = ID,
				Name = unescaped
			})

			if #v3 >= 30 then
				table.remove(v3, 30)
			end

			game.ReplicatedStorage.Remotes.Inventory.SaveSong:FireServer(ID, unescaped)
			UpdateSongList()
		else
			adder.ID.Text = "Invalid ID!"
		end
	end

	radio.Button.Activated:Connect(function()
		WindowService:ToggleFrame("Radio")
	end)

	local function SearchSongs(p)
		if not (radio3 or p) then
			return
		end

		script.Preview:Stop()
		script.Preview.SoundId = ""

		for _, child in pairs(search:GetChildren()) do
			if child.Name ~= "Searcher" then
				child.Visible = false
			end
		end

		search.Processing.Visible = true
		search.Processing.Text = "Searching."
		spawn(function()
			local v5 = 1

			while search.Processing.Visible do
				search.Processing.Text = "Searching"

				for _ = 1, (v5 - 1) % 4 do
					search.Processing.Text = search.Processing.Text .. "."
				end

				v5 += 1
				wait(0.25)
			end
		end)
		local _ = searcher.ID.Text
		local v5 = game.ReplicatedStorage.Remotes.Extras.SearchSongs:InvokeServer(p and "" or searcher.ID.Text or "")
		search.Processing.Visible = false

		if not v5 or type(v5) ~= "table" then
			search.Error.Visible = true
			return
		end

		if not (#v5 > 0) then
			search.Empty.Visible = true
			return
		end

		scrollFrame2:ClearAllChildren()

		for k, v6 in pairs(v5) do
			local clone = script.SearchedSong:Clone()
			local title = v6.Title or v6.Name
			local id = v6.Id or v6.AssetId
			clone.Container.SongName.Text = tostring(title)

			for _, v7 in pairs(v3) do
				if v7.ID ~= "https://www.roblox.com/asset/?id=" .. id then
					continue
				end

				clone.Container.Add.Text = "Added"
				clone.Container.Add.Style = Enum.ButtonStyle.RobloxRoundButton
			end

			local mouseButton1ClickConnection = nil
			mouseButton1ClickConnection = clone.Container.Add.MouseButton1Click:connect(function()
				mouseButton1ClickConnection:disconnect()
				clone.Container.Add.Text = "Added"
				clone.Container.Add.Style = Enum.ButtonStyle.RobloxRoundButton
				AddSong(id, title)
			end)
			local v10 = id
			local v11 = clone
			clone.Container.Preview.MouseButton1Click:connect(function()
				for i, child in pairs(scrollFrame2:GetChildren()) do
					child.Container.Preview.Text = "Preview"
				end

				script.Preview:Stop()
				local soundId2 = "https://www.roblox.com/asset/?id=" .. v10
				local soundId = script.Preview.SoundId
				script.Preview.SoundId = soundId2

				if script.Preview.SoundId == soundId then
					script.Preview.SoundId = ""
					return
				end

				v11.Container.Preview.Text = "Stop"
				script.Preview:Play()
			end)
			clone.Position = UDim2.new(0, 0, 0, (k - 1) * clone.Size.Y.Offset)
			scrollFrame2.CanvasSize = UDim2.new(0, 0, 0, clone.Size.Y.Offset * k)
			clone.Parent = scrollFrame2
		end

		scrollFrame2.Visible = true
	end

	searcher.Add.MouseButton1Click:connect(SearchSongs)
	searcher.ID.FocusLost:connect(function(p)
		if p then
			SearchSongs()
		end
	end)
	adder.Add.MouseButton1Click:connect(function()
		AddSong(adder.ID.Text)
	end)
	SearchSongs()
	UpdateSongList()
end