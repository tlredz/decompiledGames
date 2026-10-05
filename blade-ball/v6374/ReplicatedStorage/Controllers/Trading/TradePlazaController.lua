local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ServerScriptService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("GamepadService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Observers)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Shared.Statable)
local v5 = require3(ReplicatedStorage2.Controllers.Trading.TradeRequestController)
local v6 = require3(ReplicatedStorage2.Controllers.ViewInventoryController)
require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v7 = require3(ReplicatedStorage2.Shared.JumpModifiers)
require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Common.Utils)
local v8 = require3(ReplicatedStorage2.Packages.Net)
local localPlayer = Players.LocalPlayer
local viewPlayer = localPlayer.PlayerGui.ViewPlayer
local playerProfile = viewPlayer.PlayerProfile
local maid = v2.new()
local _ = workspace.CurrentCamera
local maid2 = v2.new()
local remoteEvent = v8:RemoteEvent("TradePlaza/AFKRejoin")
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 1
highlight.OutlineTransparency = 0
highlight.OutlineColor = Color3.fromRGB(255, 170, 0)
highlight.Parent = ReplicatedStorage2
local TradePlazaController = {}
local raycast

raycast = function(position: Vector3, vector: Vector3, p: number, options, callback)
	local v9 = callback or function()
		return true
	end
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = options or {}
	local raycastResult = workspace:Raycast(position + vector * 0.01, vector * p, raycastParams)

	if raycastResult and not v9(raycastResult) and (raycastResult.Position - position).Magnitude < p then
		return raycast(raycastResult.Position, vector, p, options, v9)
	end

	return raycastResult
end

function TradePlazaController:_trackIdle()
	maid2:Clean()
	local lastTime = os.clock()
	local maid3 = maid2:Extend()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function wentIdle()
		maid3:Clean()
		maid3:Add(RunService.Heartbeat:Connect(function()
			if os.clock() - lastTime > 960 then
				remoteEvent:FireServer()
				lastTime = os.clock()
			end
		end))
	end

	maid2:Add(v.WindowFocusReleased:Connect(wentIdle))
	maid2:Add(v.InputBegan:Connect(function()
		lastTime = os.clock()
	end))
	maid2:Add(v.InputEnded:Connect(function(_)
		if #v:GetKeysPressed() == 0 then
			wentIdle() -- equivalent call inferred; original call site unknown
		end
	end))
	maid2:Add(localPlayer.Idled:Connect(function(p: number)
		if p > 960 then
			remoteEvent:FireServer()
		end

		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid")

		if humanoid then
			local v9 = v7:SetModifierFor(
				character,
				"Trade Plaza AFK",
				v7.Utils.MinDebuff(character, 0),
				v7.Priority.DEBUFF
			)
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			task.delay(0.1, v9)
		end
	end))
end

function TradePlazaController.ViewPlayer(_, player)
	local playerStates = v5:GetPlayerStates(player)

	if not playerStates then
		return
	end

	maid:Clean()
	local v9 = true
	maid:Add(function()
		v9 = false
	end)
	playerProfile.ProfilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
	playerProfile.Username1.Text = player.DisplayName
	playerProfile.Username2.Text = `@{player.Name}`
	local addFriend = playerProfile.ListOfButtons.ButtonsList.AddFriend
	local inventory = playerProfile.ListOfButtons.ButtonsList.Inventory
	local sendTrade = playerProfile.ListOfButtons.SendTrade

	-- equivalent calls inferred from this helper; original call sites unknown
	local function areFriends()
		local success, result = pcall(function()
			return localPlayer:IsFriendsWith(player.UserId)
		end)
		return success and result
	end

	maid:Add(addFriend.Activated:Connect(function()
		if areFriends() then
			return
		end

		xpcall(function()
			StarterGui:SetCore("PromptSendFriendRequest", player)
		end, warn)
	end))
	maid:Add(inventory.Activated:Connect(function()
		v6:ViewInventory(player)
	end))
	maid:Add(sendTrade.Activated:Connect(function()
		v5:SendTrade(player)
	end))

	local function updateAddFriend()
		local v10 = areFriends() -- equivalent call inferred; original call site unknown

		if not v9 then
			return
		end

		addFriend.Active = not v10
		addFriend.Image = v10 and "rbxassetid://18860669626" or "rbxassetid://18711594643"
		addFriend.HoverImage = v10 and "rbxassetid://18860669386" or "rbxassetid://18711664706"
		local uIStroke = addFriend.Label.UIStroke
		local color

		if v10 then
			color = Color3.fromRGB(41, 41, 41)
		else
			color = Color3.fromRGB(1, 86, 0)
		end

		uIStroke.Color = color
	end

	maid:Add(StarterGui:GetCore("PlayerFriendedEvent").Event:Connect(updateAddFriend))
	maid:Add(StarterGui:GetCore("PlayerUnfriendedEvent").Event:Connect(updateAddFriend))
	task.spawn(updateAddFriend)
	maid:Add(v4.Computed(function(callback)
		local v10 = callback(playerStates.hasPendingRequest)
		local v11 = callback(playerStates.didInvite)
		local v12 = callback(playerStates.isInMatch)
		local v13 = callback(playerStates.options)
		local canViewInventory = v13.CanViewInventory
		local _ = v13.CanInvite
		inventory.Active = canViewInventory
		inventory.Image = canViewInventory and "rbxassetid://18711611169" or "rbxassetid://18860669626"
		inventory.HoverImage = canViewInventory and "rbxassetid://18711662604" or "rbxassetid://18860669386"
		local uIStroke = inventory.Label.UIStroke
		local color

		if canViewInventory then
			color = Color3.fromRGB(93, 18, 112)
		else
			color = Color3.fromRGB(41, 41, 41)
		end

		uIStroke.Color = color
		local v15

		if v11 then
			sendTrade.Label.Text = "Sent"
			v15 = "Active"
		elseif v12 then
			sendTrade.Label.Text = "In Match"
			v15 = "Disabled"
		elseif v13.CanInvite or v10 then
			sendTrade.Label.Text = v10 and "Accept Trade" or "Send Trade"
			v15 = "Active"
		else
			sendTrade.Label.Text = "Not Accepting"
			v15 = "Disabled"
		end

		sendTrade.Image = v15 == "Disabled" and "rbxassetid://18860945893" or "rbxassetid://18711624747"
		sendTrade.HoverImage = v15 == "Disabled" and "rbxassetid://18860945505" or "rbxassetid://18711660772"
		local uIStroke2 = sendTrade.Label.UIStroke
		local color2

		if v15 == "Disabled" then
			color2 = Color3.fromRGB(41, 41, 41)
		else
			color2 = Color3.fromRGB(149, 67, 0)
		end

		uIStroke2.Color = color2
		return nil
	end))
	maid:AttachToInstance(player)
	v3:Open(viewPlayer.Name)
end

function TradePlazaController:Start()
	self:_trackIdle()
end

return TradePlazaController