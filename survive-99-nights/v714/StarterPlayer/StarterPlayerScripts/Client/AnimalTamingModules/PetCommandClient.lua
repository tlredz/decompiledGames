local createVector = vector.create
game:GetService("CollectionService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PetCommandClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
local v2 = nil

function PetCommandClient.OpenCollarGui(p)
	local collarWrite = Client.Interface.CollarWrite
	collarWrite.TextBox.Text = ""
	collarWrite.TextBox.PlaceholderText = "WRITE HERE"
	collarWrite.Visible = true
	v2 = p
end

function CollarTypingEvents()
	local collarWrite = Client.Interface.CollarWrite
	local textBox = collarWrite.TextBox

	-- equivalent calls inferred from this helper; original call sites unknown
	local function filterAndProcessText(text)
		local v3, v4 = Client.Events.FilterSignText:InvokeServer(text, Enum.TextFilterContext.PublicChat)

		if v3 then
			return true, v4
		end

		Client.PopUpUI.AddPopUp("text filtered. try again", "warning")
		collarWrite.TextBox.Text = ""
		collarWrite.TextBox.PlaceholderText = "WRITE HERE"
		return false, nil
	end

	collarWrite.SubmitButton.Activated:Connect(function()
		local text = textBox.Text

		if text == "" then
			Client.PopUpUI.AddPopUp("text box empty", "warning")
			return
		end

		if #text > 20 then
			Client.PopUpUI.AddPopUp("too long", "warning")
			return
		end

		local v3, v4 = filterAndProcessText(text) -- equivalent call inferred; original call site unknown

		if v3 then
			print(v2.Name)
			Client.Events.WriteOnCollar:FireServer(v2, v4)
			Client.Sound.Play("CloseButton")
			Client.Sound.Play("SignWrite")
			collarWrite.Visible = false
			v2 = nil
		end
	end)
	collarWrite.CloseButton.Activated:Connect(function()
		collarWrite.Visible = false
		Client.Sound.Play("CloseButton")
		v2 = nil
	end)
end

function OpenCommandMenu(p, items, callback, options)
	local size = p.Frame.ButtonTemplate.Size
	local clones = {}
	local v3 = options or {}

	for _, item in pairs(items) do
		local clone = p.Frame.ButtonTemplate:Clone()
		table.insert(clones, clone)
		clone.TextTitle.Text = item.Label

		if v3.Resurrected then
			clone.ImageColor3 = Color3.fromRGB(124, 217, 146)
		end

		local v4 = item
		clone.Activated:Connect(function()
			callback(v4.Command, clone)
		end)
		clone.Position = UDim2.new(0.5, 0, 0.5, 0)
		clone.Parent = p.Frame
		clone.Visible = true
	end

	TweenService:Create(p.Frame.InteractButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Size = UDim2.new(0.12, 0, 0.12, 0)
	}):Play()
	local v4 = 360 / #clones
	Client.TweenModule.new(function(p2)
		for k, v5 in pairs(clones) do
			local v6 = (k - 1) * v4
			local v7 = math.sin((math.rad(v6))) * p2 * 0.3
			local v8 = math.cos((math.rad(v6))) * p2 * 0.3
			v5.Position = UDim2.new(0.5 + v7, 0, 0.5 + v8, 0)
			local v9 = 0.1 + 0.9 * p2
			v5.Size = UDim2.new(size.X.Scale * v9, 0, size.Y.Scale * v9, 0)
		end
	end, 0.15, "Quad"):Play()
	return clones
end

function GetCommands(instance)
	local resurrected = instance:GetAttribute("Resurrected")
	local result = {
		{
			Command = "Rename",
			Label = "Rename",
			Active = true
		},
		{
			Command = "Release",
			Label = resurrected and "Banish" or "Release",
			Active = true
		}
	}

	for _, v3 in pairs({
		{
			Command = "Sit",
			Label = resurrected and "Stay" or "Sit",
			Active = true
		},
		{
			Command = "FollowOwner",
			Label = "Follow",
			Active = true
		}
	}) do
		if v3.Command ~= instance:GetAttribute("PetCommand") then
			table.insert(result, v3)
		end
	end

	return result
end

function TamedAnimalAdded(instance)
	v[instance] = {}
	local flag = false
	local clone = game.ReplicatedStorage.Assets.Interface.Pets.InteractMenu:Clone()

	if instance:GetAttribute("Resurrected") then
		clone.Frame.InteractButton.Image = "rbxassetid://105568186033829"
	end

	clone.Parent = localPlayer.PlayerGui
	clone.Adornee = instance.PrimaryPart
	v[instance].Billboard = clone
	local v3 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function show()
		clone.Frame.Visible = true
	end

	local function hide()
		clone.Frame.Visible = false
		clone.Frame.InteractButton.Visible = true
		flag = false
		TweenService:Create(
			clone.Frame.InteractButton,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				Size = UDim2.new(0.22, 0, 0.22, 0)
			}
		):Play()

		if v3 then
			for _, v4 in pairs(v3) do
				v4:Destroy()
			end
		end

		v3 = nil
	end

	local function updateCommand(p, instance2)
		if p == "Rename" then
			PetCommandClient.OpenCollarGui(instance)
		elseif p == "Release" and instance2:GetAttribute("Confirm") == nil then
			instance2.TextTitle.Text = "Confirm"
			local imageColor3 = instance2.ImageColor3
			instance2.ImageColor3 = Color3.fromRGB(158, 158, 158)
			task.delay(2, function()
				instance2:SetAttribute("Confirm", true)
				instance2.ImageColor3 = imageColor3
			end)
			return
		else
			Client.Events.CommandPet:FireServer(instance, p)
		end

		hide()
		show() -- equivalent call inferred; original call site unknown
	end

	clone.Frame.InteractButton.MouseButton1Click:Connect(function()
		local v4 = GetCommands(instance)

		if flag then
			hide()
			return
		end

		flag = true
		local v5 = {
			Resurrected = instance:GetAttribute("Resurrected")
		}
		v3 = OpenCommandMenu(clone, v4, updateCommand, v5)
	end)
	task.spawn(function()
		while v[instance] do
			task.wait(0.1)

			if not instance.Parent then
				break
			end

			if localPlayer.Character and instance.Parent == workspace.Characters and ((instance:GetPivot().Position - localPlayer.Character:GetPivot().Position) * createVector(
				1,
				0,
				1
			)).Magnitude < 10 then
				show() -- equivalent call inferred; original call site unknown
				continue
			end

			hide()
		end
	end)
end

function TamedAnimalRemoved(p)
	if v[p] then
		if v[p].Billboard then
			v[p].Billboard:Destroy()
		end

		v[p] = nil
	end
end

function PetCommandClient.Init()
	Client.Utility.ForAllTagged("TamedAnimal_" .. localPlayer.UserId, TamedAnimalAdded, TamedAnimalRemoved)
	task.spawn(function()
		CollarTypingEvents()
	end)
end

return PetCommandClient