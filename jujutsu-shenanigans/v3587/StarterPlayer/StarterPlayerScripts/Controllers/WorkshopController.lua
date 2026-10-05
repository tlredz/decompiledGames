local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "WorkshopController"
})
controller.UsernameCache = {}
controller.CategoryPages = {
	Map = { 1, 1, 0 },
	Moveset = { 1, 1, 0 },
	Favourite = { 1, 1, 0 }
}

function controller.KnitStart(_)
	local menus = localPlayer.PlayerGui:WaitForChild("Menus")
	local workshop = menus.Group.Workshop
	workshop:SetAttribute("Loaded", true)
	local edit = workshop.Items.Uploads.Edit
	local reportConfirm = workshop.ReportConfirm
	local options = workshop.Options
	local sorting = options.Sorting
	local page = options.Page
	local textBox = workshop.TextBox
	local v5 = "Moveset"
	local v6 = false
	local results = {}
	local v7 = {}
	local v8 = nil
	local fn
	local fn2
	local workshopPreset = menus.Preset.WorkshopPreset

	local function CreateItemFromInfo(data, layoutOrder)
		local list = workshop.Items[`{v5}s`]

		if list.Name == "Uploads" then
			list = list.List
		end

		local clone = workshopPreset:Clone()
		clone.Title.Text = data.title or ""
		clone.Description.Text = data.description or ""
		clone.Background.Image = "rbxassetid://" .. (data.image or "")
		clone.Option2.FavouriteAmt.Text = data.favorites or 0
		clone.Creator.Text = "..."
		clone.LayoutOrder = layoutOrder
		clone.Parent = list
		task.spawn(function()
			local nameFromUserIdAsync = controller.UsernameCache[data.creator]

			if not nameFromUserIdAsync then
				if pcall(function()
					nameFromUserIdAsync = Players:GetNameFromUserIdAsync(data.creator)
				end) then
					controller.UsernameCache[data.creator] = nameFromUserIdAsync
				else
					nameFromUserIdAsync = "..."
				end
			end

			clone.Creator.Text = nameFromUserIdAsync
		end)

		if v7[data._id] then
			clone.Option2.Favourite.ImageColor3 = Color3.fromRGB(255, 255, 0)
		end

		clone.Option2.Favourite.MouseButton1Down:Connect(function()
			v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

			if v7[data._id] then
				if replicatedStorage.Remotes.WorkshopFavorite:InvokeServer(data._id, false) then
					clone.Option2.Favourite.ImageColor3 = Color3.new(1, 1, 1)
					clone.Option2.FavouriteAmt.Text = tonumber(clone.Option2.FavouriteAmt.Text) - 1
					v7[data._id] = nil
				end
			elseif replicatedStorage.Remotes.WorkshopFavorite:InvokeServer(data._id, true) then
				clone.Option2.Favourite.ImageColor3 = Color3.fromRGB(255, 255, 0)
				clone.Option2.FavouriteAmt.Text = tonumber(clone.Option2.FavouriteAmt.Text) + 1
				v7[data._id] = true
			end
		end)

		if localPlayer.UserId == data.creator then
			clone.Option1.Edit.Visible = true
			clone.Option1.Donate.Visible = false
			clone.Option1.Report.Image = "rbxassetid://14714840208"
			clone.Option2.Favourite.Visible = false
			clone.Option1.Edit.MouseButton1Down:Connect(function()
				if v6 == true then
					return
				end

				v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
				fn(workshop.Categories.Uploads)
				workshop.Items.Uploads.List.Visible = false
				workshop.Items.Uploads.Edit.Visible = true
				workshop.Options.Visible = false

				if data.type == "Map" then
					v8 = data
					fn2()
					workshop.Items.Uploads.Edit.Data.TypeChoiceConfirm.Moveset.Text = ""
				else
					workshop.Items[`{v5}s`].Visible = false
					v6 = true
					workshop.Loading.Visible = true
					v2.DataQuery:Fire(data._id)
				end
			end)
			local bindableFunction = Instance.new("BindableFunction", clone)

			function bindableFunction.OnInvoke(p)
				if v6 == true then
					return
				end

				v4:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)

				if p ~= "Yes" then
					return
				end

				list.Visible = false
				v6 = true
				workshop.Loading.Visible = true
				v2.Delete:Fire(data._id)
			end

			clone.Option1.Report.MouseButton1Down:Connect(function()
				v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
				local StarterGui = game:GetService("StarterGui")
				StarterGui:SetCore("SendNotification", {
					Title = "DELETE UPLOAD",
					Text = "Are you sure you want to delete this upload?",
					Button1 = "Yes",
					Button2 = "No",
					Duration = 2,
					Callback = bindableFunction
				})
			end)
		else
			clone.Option1.Report.MouseButton1Down:Connect(function()
				v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

				if reportConfirm.Visible then
					return
				end

				v6 = true
				local reason = reportConfirm.Reason
				local dropdown = reason.Dropdown
				local text = "I don't like it"

				-- equivalent calls inferred from this helper; original call sites unknown
				local function updateReason()
					reason.Text = `{text} ↓`
					dropdown.Visible = false
					reportConfirm.TextBox.Visible = text == "Other"
				end

				reportConfirm.TextBox.Text = ""
				reportConfirm.Visible = true
				local connections = { (reason.MouseButton1Down:Connect(function()
						if dropdown.Visible then
							dropdown.Visible = false
							updateReason() -- equivalent call inferred; original call site unknown
						else
							dropdown.Visible = true
							reason.Text = `{text} ↑`
						end
					end)) }

				for _, v9 in dropdown:QueryDescendants("TextButton") do
					local v10 = v9
					table.insert(connections, v9.MouseButton1Click:Connect(function()
						text = v10.Text
						updateReason() -- equivalent call inferred; original call site unknown
					end))
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function closeUI()
					for _, connection in connections do
						connection:Disconnect()
					end

					reportConfirm.Visible = false
					v6 = false
				end

				reportConfirm.Buttons.Report.MouseButton1Down:Once(function()
					local v9 = text ~= "Other" and text or reportConfirm.TextBox.Text
					v2.Report:Fire(data._id, v9)
					closeUI() -- equivalent call inferred; original call site unknown
				end)
				reportConfirm.Buttons.Cancel.MouseButton1Down:Once(function()
					closeUI() -- equivalent call inferred; original call site unknown
				end)
			end)
			clone.Option1.Donate.MouseButton1Down:Connect(function()
				local text = clone.Creator.Text
				local v9 = v
				local creator = data.creator

				if text == "..." or not text then
					text = nil
				end

				v9:PromptDonateMenu(creator, text)
			end)
		end

		local bindableFunction = Instance.new("BindableFunction", clone)

		function bindableFunction.OnInvoke(p)
			v4:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)

			if p ~= "Yes" then
				return
			end

			_G.WorkshopIcon:deselect()
			v2.DataLoad:Fire(data._id)
		end

		clone.Option1.Load.MouseButton1Down:Connect(function()
			v4:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
			local StarterGui = game:GetService("StarterGui")
			StarterGui:SetCore("SendNotification", {
				Title = data.title,
				Text = "Are you sure you want to load?",
				Button1 = "Yes",
				Button2 = "No",
				Duration = 2,
				Callback = bindableFunction
			})
		end)
	end

	local function LoadFromTable(list, p, p2)
		local list2 = workshop.Items[`{v5}s`]

		if list2.Name == "Uploads" then
			list2 = list2.List
		end

		for _, frame in list2:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			if frame.Name == "Upload" then
				frame.Visible = localPlayer:GetAttribute("PS_Owner") == true
			else
				frame:Destroy()
			end
		end

		for i = p, p + p2 - 1 do
			local v9 = list[i]

			if not v9 then
				break
			end

			CreateItemFromInfo(v9, i)
		end

		list2.CanvasPosition = Vector2.new(0, 0)
		list2.Visible = false
		list2.Visible = true
	end

	local v9 = {
		["★ DAY"] = "daily",
		["★ MONTH"] = "monthly",
		["★ WEEK"] = "weekly",
		NEW = "newest"
	}

	local function UpdateSearch(p)
		if v5 == "Favourite" then
			if p then
				textBox.Text = ""
				local v10 = controller.CategoryPages[v5][1]
				LoadFromTable(results, (v10 - 1) * 20 + 1, 20)
				return
			elseif #textBox.Text ~= 0 then
				local text = textBox.Text
				local v10 = {}

				for _, v11 in results do
					if not string.find(string.lower(v11.title), string.lower(text)) then
						continue
					end

					table.insert(v10, v11)
				end

				LoadFromTable(v10, 1, #v10)
				return
			end
		end

		local text = textBox.Text

		if #text == 0 then
			text = nil
		end

		local title = text and string.sub(text, 0, 50)
		local sort = v9[sorting.Text]
		local page2

		if v5 == "Map" or v5 == "Moveset" then
			page2 = controller.CategoryPages[v5][1]
		end

		local v13 = {
			type = v5,
			title = title,
			sort = sort,
			page = page2
		}
		workshop.Items[`{v5}s`].Visible = false
		v6 = true
		workshop.Loading.Visible = true
		v2.Load:Fire(v13)
	end

	local char = nil
	local v10 = nil

	fn2 = function()
		if not v8 then
			v8 = {
				type = "Map",
				title = nil,
				description = nil,
				image = nil
			}
		end

		if v8.creator then
			edit.Buy.Visible = false
			edit.BuyRobux.Visible = false
			edit.Upload.Text = "SAVE CHANGES"
			edit.Data.TypeChoice.Visible = false
		else
			edit.Buy.Visible = true
			edit.BuyRobux.Visible = true
			edit.Upload.Text = "UPLOAD (" .. (localPlayer:GetAttribute("WorkshopAllowCount") or 2) .. " LEFT)"
			edit.Data.TypeChoice.Visible = true
		end

		if v8.type == "Moveset" then
			edit.Data.TypeChoice.Moveset.BorderColor3 = Color3.fromRGB(85, 255, 255)
			edit.Data.TypeChoice.Map.BorderColor3 = Color3.new(0, 0, 0)
			edit.Data.TypeChoiceConfirm.Map.Visible = false
			edit.Data.TypeChoiceConfirm.Moveset.Visible = true
			edit.List.Visible = true
		else
			edit.Data.TypeChoice.Map.BorderColor3 = Color3.fromRGB(85, 255, 255)
			edit.Data.TypeChoice.Moveset.BorderColor3 = Color3.new(0, 0, 0)
			edit.Data.TypeChoiceConfirm.Map.Visible = true
			edit.Data.TypeChoiceConfirm.Moveset.Visible = false
			edit.List.Visible = false
		end

		edit.Data.TypeChoiceConfirm.Moveset.Map.Visible = false
		edit.Settings.Description.Text = v8.description or ""
		edit.Settings.Title.Text = v8.title or ""
		edit.Settings.ImageId.Text = v8.image or ""

		if edit.Settings:FindFirstChild("Preview") then
			edit.Settings.Preview:Destroy()
		end

		local clone = menus.Preset.WorkshopPreset:Clone()
		clone.Size = UDim2.new(1, 0, 0.4, 0)
		clone.LayoutOrder = 4
		clone.Background.Image = "rbxassetid://" .. (v8.image or "")
		clone.Title.Text = v8.title or ""
		clone.Description.Text = v8.description or ""
		clone.Creator.Text = localPlayer.Name
		clone.Name = "Preview"
		clone.Parent = edit.Settings

		for _, button in edit.List.List:GetChildren() do
			if not button:IsA("TextButton") then
				continue
			end

			if button.Text == char then
				button.BorderColor3 = Color3.fromRGB(85, 255, 255)
			else
				button.BorderColor3 = Color3.fromRGB(0, 0, 0)
			end
		end
	end

	local v11 = {
		Movesets = "Moveset",
		Maps = "Map",
		Favourites = "Favourite",
		Uploads = "Upload"
	}

	fn = function(p)
		for _, button in workshop.Categories:GetChildren() do
			if button:IsA("TextButton") then
				button.Select.Visible = button == p
			end
		end

		local name = p.Name
		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

		for _, child in workshop.Items:GetChildren() do
			child.Visible = name == child.Name
		end

		v10 = nil
		workshop.Warning.Visible = false
		workshop.Items.Uploads.List.Visible = true
		workshop.Items.Uploads.Edit.Visible = false
		workshop.Options.Visible = true

		if v11[name] then
			v5 = v11[name]
		end

		local categoryPage = controller.CategoryPages[v5]

		if categoryPage then
			for _, v12 in workshop.Options:QueryDescendants(".PageInfo") do
				v12.Visible = true
			end

			local v12, v13, text = unpack(categoryPage)
			page.Text = `{v12}/{v13}`
			options.Results.Text = text
		else
			for _, v12 in workshop.Options:QueryDescendants(".PageInfo") do
				v12.Visible = false
			end
		end
	end

	for _, button in workshop.Categories:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local v12 = button
		button.MouseButton1Down:Connect(function()
			if v6 == true then
				return
			end

			fn(v12)
		end)
	end

	local v12 = {
		"★",
		"★ DAY",
		"★ WEEK",
		"★ MONTH",
		"NEW"
	}
	sorting.MouseButton1Click:Connect(function()
		if v6 == true then
			return
		end

		local text = sorting.Text
		sorting.Text = v12[table.find(v12, text) + 1] or "★"
		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		UpdateSearch()
	end)
	options.Next.MouseButton1Click:Connect(function()
		if v6 == true then
			return
		end

		local categoryPage = controller.CategoryPages[v5]

		if not categoryPage then
			return
		end

		local v13, v14 = unpack(categoryPage)
		local v15 = math.min(v13 + 1, v14)

		if v13 == v15 then
			return
		end

		categoryPage[1] = v15
		page.Text = `{v15}/{v14}`
		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		UpdateSearch(true)
	end)
	options.Back.MouseButton1Click:Connect(function()
		if v6 == true then
			return
		end

		local categoryPage = controller.CategoryPages[v5]

		if not categoryPage then
			return
		end

		local v13, v14 = unpack(categoryPage)
		local v15 = math.clamp(v13 - 1, 1, v14)

		if v13 == v15 then
			return
		end

		categoryPage[1] = v15
		page.Text = `{v15}/{v14}`
		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		UpdateSearch(true)
	end)
	options.Page.MouseButton1Down:Connect(function()
		if v6 == true then
			return
		end

		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		local categoryPage = controller.CategoryPages[v5]

		if not categoryPage then
			return
		end

		local text2, v14 = unpack(categoryPage)
		local textBox2 = options.Page.TextBox
		textBox2.Text = text2
		textBox2.Visible = true
		textBox2:CaptureFocus()
		textBox2.FocusLost:Once(function()
			textBox2.Visible = false
			local text = tonumber(textBox2.Text)

			if not text then
				return
			end

			local v15 = math.clamp(text, 1, v14)

			if v15 == text2 then
				return
			end

			categoryPage[1] = v15
			UpdateSearch(true)
		end)
	end)
	options.Load.MouseButton1Click:Connect(function()
		if v6 == true then
			return
		end

		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		UpdateSearch()
	end)
	textBox.FocusLost:Connect(function(p)
		if not (p and v6 ~= true) then
			return
		end

		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		controller.CategoryPages[v5][1] = 1
		UpdateSearch()
	end)
	v2.Load:Connect(function(data, p, p2)
		local list = workshop.Items[`{p}s`]
		fn(workshop.Categories[list.Name])

		if list.Name == "Uploads" then
			list = list.List
		end

		for _, frame in list:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			if frame.Name == "Upload" then
				frame.Visible = localPlayer:GetAttribute("PS_Owner") == true
			else
				frame:Destroy()
			end
		end

		list.CanvasPosition = Vector2.new(0, 0)
		v6 = false
		workshop.Loading.Visible = false

		if not data then
			return
		end

		local categoryPage = controller.CategoryPages[p]
		options.Results.Text = data.total

		if categoryPage then
			categoryPage[3] = data.total
		end

		if p == "Map" or p == "Moveset" then
			local v13 = math.max(data.pages or 1, 1)
			local v14 = math.clamp(data.page or 1, 1, v13)
			categoryPage[1] = v14
			categoryPage[2] = v13
			page.Text = `{v14}/{v13}`
		elseif p == "Favourite" then
			textBox.Text = ""
			results = data.results
			local v13 = math.max(math.ceil(data.total / 12), 1)
			categoryPage[1] = 1
			categoryPage[2] = v13
			page.Text = `{1}/{v13}`
		end

		v7 = p2

		for k, v13 in data.results or {} do
			if k > 20 then
				break
			else
				CreateItemFromInfo(v13, k)
			end
		end
	end)
	v2.Buy:Connect(function(p, json)
		if p then
			v8 = p

			if json then
				local HttpService = game:GetService("HttpService")
				local jSONDecode = HttpService:JSONDecode(json)
				char = jSONDecode.Char

				if #jSONDecode.Data > 199999 then
					edit.Data.TypeChoiceConfirm.Moveset.Text = "Data over 200k characters cannot be previewed, please paste your new code to apply edits"
				else
					edit.Data.TypeChoiceConfirm.Moveset.Text = jSONDecode.Data
				end
			end
		end

		v6 = false
		workshop.Loading.Visible = false
		workshop.Items.Uploads.Visible = true
		fn2()
	end)
	local _ = menus.Preset.WorkshopPreset
	workshop.Items.Uploads.List.Upload.Option1.Edit.MouseButton1Down:Connect(function()
		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		workshop.Items.Uploads.List.Visible = false
		workshop.Items.Uploads.Edit.Visible = true
		workshop.Options.Visible = false
		v8 = nil
		char = nil
		fn2()
		workshop.Items.Uploads.Edit.Data.TypeChoiceConfirm.Moveset.Text = ""
	end)
	edit.Upload.MouseButton1Down:Connect(function()
		if v6 == true then
			return
		end

		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		print(#edit.Data.TypeChoiceConfirm.Moveset.Text)
		workshop.Items[`{v5}s`].Visible = false
		v6 = true
		workshop.Loading.Visible = true
		v2.Upload:Fire(v8, edit.Data.TypeChoiceConfirm.Moveset.Text, char)
	end)
	edit.Data.TypeChoice.Map.MouseButton1Down:Connect(function()
		if not v8 then
			return
		end

		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v8.type = "Map"
		fn2()
	end)
	edit.Data.TypeChoice.Moveset.MouseButton1Down:Connect(function()
		if not v8 then
			return
		end

		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v8.type = "Moveset"
		fn2()
	end)
	edit.Settings.Title.FocusLost:Connect(function()
		if not v8 then
			return
		end

		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v8.title = edit.Settings.Title.Text
		fn2()
	end)
	edit.Settings.Description.FocusLost:Connect(function()
		if not v8 then
			return
		end

		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v8.description = edit.Settings.Description.Text
		fn2()
	end)
	edit.Settings.ImageId.FocusLost:Connect(function()
		if not v8 then
			return
		end

		v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v8.image = edit.Settings.ImageId.Text
		fn2()
	end)
	edit.Data.TypeChoiceConfirm.Moveset.FocusLost:Connect(function()
		if not v8 then
			return
		end

		local Base64 = require(replicatedStorage.Modules.Base64)
		local success, _ = pcall(function()
			local from_base64 = Base64.from_base64(edit.Data.TypeChoiceConfirm.Moveset.Text)
			local HttpService = game:GetService("HttpService")
			HttpService:JSONDecode(from_base64)
		end)

		if success then
			edit.Data.TypeChoiceConfirm.Moveset.Map.Visible = false
			v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		else
			edit.Data.TypeChoiceConfirm.Moveset.Text = ""
			edit.Data.TypeChoiceConfirm.Moveset.Map.Visible = true
			v4:PlaySound(sounds.Misc.UI.Error, workspace, game.SoundService.Effect)
		end
	end)
	local ListData = require(game.ReplicatedStorage.Modules.ListData)
	local count = 0

	for _, v13 in ListData.MoveList do
		local clone = menus.Preset.Button:Clone()
		clone.LayoutOrder = count
		clone.BackgroundColor3 = v13[1][2]
		count += 1
		clone.Parent = edit.List.List
		clone.Text = v13[1][1]
		local v14 = v13
		clone.MouseButton1Down:Connect(function()
			v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

			if char == v14[1][1] then
				char = nil
			else
				char = v14[1][1]
			end

			fn2()
		end)
	end

	local bindableFunction = Instance.new("BindableFunction", edit.Buy)

	function bindableFunction.OnInvoke(_)
		v4:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
		v3.Purchase:Fire("WorkshopSlot", "Cash", nil)
	end

	edit.Buy.MouseButton1Down:Connect(function()
		v4:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
		local StarterGui = game:GetService("StarterGui")
		StarterGui:SetCore("SendNotification", {
			Title = "Buy Upload",
			Text = "Are you sure you want to purchase?",
			Button1 = "Yes",
			Button2 = "No",
			Duration = 2,
			Callback = bindableFunction
		})
	end)
	edit.BuyRobux.MouseButton1Down:Connect(function()
		v4:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
		v3.Purchase:Fire("WorkshopSlot", "Robux", nil)
	end)
	local upload = workshop.Items.Movesets.Upload
	upload.Menu.Option1.Edit.MouseButton1Down:Connect(function()
		upload.Menu.Visible = false
		upload.Edit.Visible = true
	end)
	upload.Edit.Option1.Edit.MouseButton1Down:Connect(function()
		upload.Menu.Visible = true
		upload.Edit.Visible = false
		v2.CustomUpload:Fire(upload.Edit.TextBox.Text)
	end)
	upload.Edit.TextBox.FocusLost:Connect(function()
		local Base64 = require(replicatedStorage.Modules.Base64)
		local success, _ = pcall(function()
			local from_base64 = Base64.from_base64(upload.Edit.TextBox.Text)
			local HttpService = game:GetService("HttpService")
			HttpService:JSONDecode(from_base64)
		end)

		if not (success and localPlayer:GetAttribute("PS_Owner")) then
			upload.Edit.TextBox.Text = ""
			v4:PlaySound(sounds.Misc.UI.Error, workspace, game.SoundService.Effect)
		end
	end)
end

function controller.KnitInit(_)
	v4 = Knit.GetController("FXController")
	v2 = Knit.GetService("WorkshopService")
	v = Knit.GetController("ShopController")
	v3 = Knit.GetService("ShopService")
end

return controller