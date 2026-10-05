local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local safezone = localPlayer.PlayerGui:WaitForChild("hud").safezone
local _ = safezone.bodyannouncements
local valentidesDuo = safezone.ValentidesDuo
local scrollingFrame = valentidesDuo.ScrollingFrame
local _ = ReplicatedStorage.resources.sounds.sfx.ui
local shared = ReplicatedStorage.shared
local packages = ReplicatedStorage.packages
local legacyControllers = ReplicatedStorage.client.legacyControllers
local anno_localthought = ReplicatedStorage.events.anno_localthought
require(shared.modules.fx)
require(shared.utils.GeneralUtils)
local Net = require(packages.Net)
require(legacyControllers.DataController)
local remoteFunction = Net:RemoteFunction("Valentides/InviteDuo", -1)
Net:RemoteFunction("Valentides/SendInvite", -1)
Net:RemoteFunction("Valentides/LeaveDuo", -1)
Net:RemoteFunction("Valentides/GetLink", -1)
local v = true
local v2 = nil

local function UpdateDuoInfo()
	local visible = v2 ~= nil
	local nameFromUserIdAsync = v2 and Players:GetNameFromUserIdAsync(v2)
	valentidesDuo.LeaveDuo.Visible = visible

	for _, frame in scrollingFrame:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Request.Visible = not visible
		frame.Duo.Visible = nameFromUserIdAsync and frame.Name == nameFromUserIdAsync
	end
end

local ValentidesDuo = {}

function ValentidesDuo.UpdateList(_, player, p)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function checkIfEmpty()
		valentidesDuo.Empty.Visible = #scrollingFrame:GetChildren() <= 1
	end

	if player == localPlayer then
		checkIfEmpty() -- equivalent call inferred; original call site unknown
		return
	end

	local child = scrollingFrame:FindFirstChild(player.Name)

	if p == "remove" and child then
		child:Destroy()
		checkIfEmpty() -- equivalent call inferred; original call site unknown
	else
		local clone = script.Sample:Clone()
		clone.Name = player.Name
		local _Name = clone._Name
		_Name.DisplayName.Text = player.DisplayName
		_Name.Username.Text = `@{player.Name}`
		clone.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=180&h=180`
		clone.Parent = scrollingFrame
		checkIfEmpty() -- equivalent call inferred; original call site unknown
		local request = clone.Request
		request.Visible = v2 == nil
		local interactable = true

		local function setButtonEnabled(flag: boolean?)
			interactable = flag or not interactable
			request.Label.TextTransparency = interactable and 0 or 0.5
			request.UIStroke.Color = interactable and Color3.fromRGB(165, 221, 255) or Color3.fromRGB(120, 120, 120)
			request.corner.ImageColor3 = request.UIStroke.Color
			request.Interactable = interactable
		end

		setButtonEnabled(true)
		request.MouseButton1Click:Connect(function()
			if not v then
				anno_localthought:Fire("You are on cooldown from inviting people to be duos!")
				return
			end

			v = false
			setButtonEnabled(false)
			remoteFunction:InvokeServer(player)
			v = true
			setButtonEnabled(true)
		end)
	end
end

function ValentidesDuo.init() end

return ValentidesDuo