local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local gamemodeResults = module.Interface:WaitForChild("Frames"):WaitForChild("GamemodeResults")
local labels = gamemodeResults:WaitForChild("Labels")
local result = labels:WaitForChild("Result")
local nickName = labels:WaitForChild("NickName")
local userName = labels:WaitForChild("UserName")
local main = gamemodeResults:WaitForChild("Main")
local scroll = main:WaitForChild("Players"):WaitForChild("Scroll")
local information = main:WaitForChild("Information")
local buttons = gamemodeResults:WaitForChild("Buttons")
local main2 = buttons:WaitForChild("Main")
local playerViewport = gamemodeResults:WaitForChild("PlayerViewport")
local holder = playerViewport:WaitForChild("Holder")
local gamemodeResults2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("GamemodeResults")
local player = gamemodeResults2:WaitForChild("Player")
local information2 = gamemodeResults2:WaitForChild("Information")
local v = CFrame.new(0, -1.25, -4) * CFrame.Angles(0, 3.141592653589793, 0)
local thread = nil
local v2 = nil
local count = 0
local Controller = {}

local function ClearChildren(instance, p)
	for _, guiObject in instance:GetChildren() do
		if not (guiObject ~= p and (guiObject:IsA("Frame") or guiObject:IsA("ScrollingFrame"))) then
			continue
		end

		guiObject:Destroy()
	end
end

local function CreatePlayerModel(p: number, p2: number)
	if v2 then
		v2:Destroy()
		v2 = nil
	end

	local humanoidModel = module.Utils.Players.GetHumanoidModel(p)

	if not humanoidModel then
		return
	end

	if p2 ~= count then
		humanoidModel:Destroy()
		return
	end

	humanoidModel.Parent = holder
	humanoidModel:PivotTo(v)
	local humanoid = humanoidModel:FindFirstChildOfClass("Humanoid")
	local characterAnimation = module.Utils.Characters.GetCharacterAnimation("Default", "Idle")

	if characterAnimation and humanoid then
		local v3 = humanoid:FindFirstChildOfClass("Animator")

		if not v3 then
			v3 = Instance.new("Animator")
			v3.Parent = humanoid
		end

		local track = v3:LoadAnimation(characterAnimation)
		track.Looped = true
		track:Play()
	end

	v2 = humanoidModel
end

local function BuildDrops(parent, items)
	local drop = parent:FindFirstChild("Drop")

	if not drop then
		return
	end

	drop.Visible = false
	ClearChildren(parent, drop)

	if not items then
		return
	end

	local count2 = 0

	for k, item in items do
		local v3 = module.Utils.Info:Get("Item", k)

		if not v3 then
			continue
		end

		count2 += 1
		local clone = drop:Clone()
		clone.Name = k
		clone.Visible = true
		clone.LayoutOrder = count2
		clone.Main.UIGradient:SetAttribute("Rarity", v3.Rarity or "Common")

		if v3.Icon then
			clone.Main.Icon.Visible = true
			clone.Main.Viewport.Visible = false
			clone.Main.Icon.Image = v3.Icon
		else
			clone.Main.Icon.Visible = false
			clone.Main.Viewport.Visible = true
			module.Utils.Camera.ViewportCharacter({
				Viewport = clone.Main.Viewport,
				Animation = module.Utils.Characters.GetCharacterAnimation(k, "Idle"),
				Character = module.Utils.Characters.Get({
					Name = k,
					RemoveHumanoidStates = true
				})
			})
		end

		clone.Main.Amount.Text = `{module.Utils.Number:Format(item)}x`
		clone.Parent = parent
	end
end

local function BuildPlayerRow(player2, layoutOrder: number)
	local clone = player:Clone()
	clone.Name = tostring(player2.UserId)
	clone.Visible = true
	clone.LayoutOrder = layoutOrder
	local main3 = clone.Main
	main3.NickName.Text = player2.DisplayName
	main3.UserName.Text = `@{player2.Name or player2.DisplayName}`
	local position = main3:FindFirstChild("Position")
	position.Text = `#{layoutOrder}`
	main3.Icon.Icon.Image = `rbxthumb://type=AvatarHeadShot&id={player2.UserId}&w=150&h=150`
	main3.Info.Damage.Text = module.Utils.Number:Format(player2.Damage or 0)
	main3.Info.Kills.Text = module.Utils.Number:Format(player2.Kills or 0)
	BuildDrops(main3.Info.Drops.List, player2.Items)
	clone.Parent = scroll
end

-- equivalent calls inferred from this helper; original call sites unknown
local function BuildInformationRow(p: string, text: string, layoutOrder: number)
	local clone = information2:Clone()
	clone.Name = p
	clone.Visible = true
	clone.LayoutOrder = layoutOrder
	clone.Main.Title.Text = p
	clone.Main.Amount.Text = text
	clone.Parent = information
end

function Controller.Show(data)
	if typeof(data) ~= "table" then
		return
	end

	if thread then
		task.cancel(thread)
		thread = nil
	end

	count += 1
	local enabled = data.Result == "Success"
	result.Text = enabled and "Victory" or "Defeat"
	result.Victory.Enabled = enabled
	result.Defeat.Enabled = not enabled
	nickName.Text = module.Instance.DisplayName
	userName.Text = `@{module.Instance.Name}`
	module.Libs.ThreadSaver.New(CreatePlayerModel, module.Instance.UserId, count)
	ClearChildren(information)
	BuildInformationRow("Stage Reached", `{data.StageReached or "?"}/{data.MaxStage or "?"}`, 1) -- equivalent call inferred; original call site unknown
	BuildInformationRow("Total Kills", module.Utils.Number:Format(data.TotalKills or 0), 2) -- equivalent call inferred; original call site unknown
	BuildInformationRow("Total Damage", module.Utils.Number:Format(data.TotalDamage or 0), 3) -- equivalent call inferred; original call site unknown
	ClearChildren(scroll)
	local players = typeof(data.Players) == "table" and data.Players or {}
	table.sort(players, function(a, b)
		return (a.Damage or 0) > (b.Damage or 0)
	end)

	for k, player2 in players do
		BuildPlayerRow(player2, k)
	end

	buttons.Visible = false
	thread = task.delay(5, function()
		thread = nil
		buttons.Visible = true

		if not (module.Data.Settings["Auto Close Results"] == true and module.Frame:IsFrameOpened("GamemodeResults")) then
			return
		end

		module.Frame:Close("GamemodeResults")
	end)
	module.Frame:Open("GamemodeResults")
end

function Controller.Clear()
	count += 1

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	ClearChildren(information)
	ClearChildren(scroll)
end

function Controller.Init()
	playerViewport.BackgroundTransparency = 1
	playerViewport.Ambient = Color3.new(1, 1, 1)
	playerViewport.LightColor = Color3.new(1, 1, 1)
	playerViewport.ImageColor3 = Color3.new(1, 1, 1)
	playerViewport.LightDirection = createVector(-1, -1, -1)
	playerViewport.BackgroundColor3 = Color3.fromRGB(-2, -2, -2)
	module.Button:Create(main2, "Small"):BindFunction("Click", function()
		module.Frame:Close("GamemodeResults")
	end)
	module.Frame:OnFrameClosed(gamemodeResults, function()
		local v3 = count
		task.delay(0.25, function()
			if v3 ~= count then
				return
			end

			Controller.Clear()
		end)
	end)
end

return Controller