local _ = script.Parent.Parent.Game
local songs = script.Parent.Parent.Lobby.Screens.Inventory.Main.Songs
local radio = game.Players.LocalPlayer:GetAttribute("Radio")
local v = game.PlaceId == 335132309 or game.PlaceId == 333740520
local v2 = game.PlaceId == 5895823254 or game.PlaceId == 5928494131
require(game.ReplicatedStorage.Modules.AudioSearcher)
local container = songs.Main.MySongs.ScrollFrame.Container
local search = songs.Main.Search
local container2 = search.Container.ScrollFrame.Container
local searcher = search.Searcher

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

	for _, child in pairs(songs.Nav:GetChildren()) do
		local v4 = child
		child.MouseButton1Click:connect(function()
			script.Preview:Stop()
			script.Preview.SoundId = ""

			for i, child2 in pairs(songs.Nav:GetChildren()) do
				child2.Style = child2 == v4 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
			end

			for i, child2 in pairs(songs.Main:GetChildren()) do
				child2.Visible = child2.Name == v4.Name
			end
		end)
	end

	local flag = false
	game.ReplicatedStorage.Remotes.Gameplay.RoleSelect.OnClientEvent:connect(function(_, _, _, _)
		flag = true
	end)
	game.ReplicatedStorage.Remotes.Shop.GetRadio.OnClientEvent:connect(function()
		flag = true
	end)
	local UpdateSongList

	UpdateSongList = function()
		container:ClearAllChildren()

		for k, v4 in pairs(v3) do
			local clone = script.Song:Clone()
			clone.Container.SongName.Text = v4.Name
			local v5 = v4
			clone.Container.Play.MouseButton1Click:connect(function()
				if flag then
					if radio then
						game.ReplicatedStorage.Remotes.Inventory.PlaySong:FireServer(v5.ID)
					else
						game.ReplicatedStorage.Remotes.Shop.GetRadio:FireServer()
					end
				else
					songs.Main.MySongs.Wait.Visible = true
					wait(2)
					songs.Main.MySongs.Wait.Visible = false
				end
			end)
			local v6 = k
			clone.Container.Delete.MouseButton1Click:connect(function()
				table.remove(v3, v6)
				game.ReplicatedStorage.Remotes.Inventory.RemoveSong:FireServer(v6)
				UpdateSongList()
			end)
			clone.Position = UDim2.new(0, 0, 0, (k - 1) * clone.Size.Y.Offset)
			clone.Parent = container
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
			for _, v5 in pairs(v3) do
				if v5.ID == ID then
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
		end
	end

	local function SearchSongs(p)
		if not (radio or p) then
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
			local v4 = 1

			while search.Processing.Visible do
				search.Processing.Text = "Searching"

				for _ = 1, (v4 - 1) % 4 do
					search.Processing.Text = search.Processing.Text .. "."
				end

				v4 += 1
				wait(0.25)
			end
		end)
		local v4 = game.ReplicatedStorage.Remotes.Extras.SearchSongs:InvokeServer(p and "" or searcher.ID.Text or "")
		local _ = searcher.ID.Text
		search.Processing.Visible = false

		if not v4 then
			search.Error.Visible = true
			return
		end

		if not (#v4 > 0) then
			search.Empty.Visible = true
			return
		end

		container2:ClearAllChildren()

		for k, v5 in pairs(v4) do
			local clone = script.SearchedSong:Clone()
			local title = v5.Title or v5.Name
			local id = v5.Id or v5.AssetId
			clone.Container.SongName.Text = tostring(title)

			for _, v6 in pairs(v3) do
				if v6.ID ~= "https://www.roblox.com/asset/?id=" .. id then
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
			local v9 = id
			local v10 = clone
			clone.Container.Preview.MouseButton1Click:connect(function()
				for i, child in pairs(container2:GetChildren()) do
					child.Container.Preview.Text = "Preview"
				end

				script.Preview:Stop()
				local soundId2 = "https://www.roblox.com/asset/?id=" .. v9
				local soundId = script.Preview.SoundId
				script.Preview.SoundId = soundId2

				if script.Preview.SoundId == soundId then
					script.Preview.SoundId = ""
					return
				end

				v10.Container.Preview.Text = "Stop"
				script.Preview:Play()
			end)
			clone.Position = UDim2.new(0, 0, 0, (k - 1) * clone.Size.Y.Offset)
			container2.Parent.CanvasSize = UDim2.new(0, 0, 0, clone.Size.Y.Offset * k)
			clone.Parent = container2
		end

		container2.Parent.Parent.Visible = true
	end

	searcher.ID.FocusLost:connect(function(p)
		if p then
			SearchSongs()
		end
	end)
	SearchSongs(true)
	UpdateSongList()
end