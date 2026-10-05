local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local serverConfig = ReplicatedStorage:WaitForChild("ServerConfig")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local enemyTemplate = ReplicatedStorage:WaitForChild("EnemyTemplate")
local monster = workspace:WaitForChild("Monster")
local spawned_Powers = workspace:WaitForChild("SpawningPower"):WaitForChild("Spawned_Powers")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
local Setting = require(moduleScript:WaitForChild("Setting"))
local setting = Setting.Setting
local ItemInfo = require(moduleScript:WaitForChild("ItemInfo"))
local ColorTable = require(moduleScript:WaitForChild("ColorTable"))
local notification = miscEvents:WaitForChild("Notification")
local spawnTime = setting.SpawnTime
local memeBeast = spawnTime["Meme Beast"]
local powers = spawnTime.Powers
local powers_Despawn = spawnTime.Powers_Despawn
local parent = script.Parent
local parent2 = parent.Parent
local parentChangedConnection = nil
local frame = parent:WaitForChild("Spawned_Powers"):WaitForChild("List"):WaitForChild("Template"):WaitForChild("Frame")
local power_Name = frame:WaitForChild("Power_Name")
local location = frame:WaitForChild("Location")
local timeleft = frame:WaitForChild("Timeleft")
local spawning = frame:WaitForChild("Spawning")
local power = ItemInfo.Rarity.Power
local item = ColorTable.Item

-- equivalent calls inferred from this helper; original call sites unknown
local function Check_Distance()
	return (parent2.Position - currentCamera.CFrame.Position).Magnitude <= 750
end

local function Update_Region()
	if localPlayer:GetAttribute("TH") then
		parent.Region.Text = `< ที่ตั้งของเซิร์ฟเวอร์ : {serverConfig:GetAttribute("Timezone")}, {serverConfig:GetAttribute("Country")} >`
		parent.Region.Stroke.Text = `< ที่ตั้งของเซิร์ฟเวอร์ : {serverConfig:GetAttribute("Timezone")}, {serverConfig:GetAttribute("Country")} >`
	else
		parent.Region.Text = `< Server Location: {serverConfig:GetAttribute("Timezone")}, {serverConfig:GetAttribute("Country")} >`
		parent.Region.Stroke.Text = `< Server Location: {serverConfig:GetAttribute("Timezone")}, {serverConfig:GetAttribute("Country")} >`
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Update_ServerTime()
	parent.Time.Text = serverConfig:GetAttribute("ServerTime")
	parent.Time.Stroke.Text = serverConfig:GetAttribute("ServerTime")
end

local function Update_MemeBeast()
	if serverConfig:GetAttribute("Meme_Beast") > 0 then
		parent["Meme Beast"].Text = `Meme Beast : {convertToHMS(memeBeast - serverConfig:GetAttribute("Meme_Beast"))}`
		parent["Meme Beast"].Stroke.Text = `Meme Beast : {convertToHMS(memeBeast - serverConfig:GetAttribute("Meme_Beast"))}`
	else
		parent["Meme Beast"].Text = "Meme Beast : ✅"
		parent["Meme Beast"].Stroke.Text = "Meme Beast : ✅"
	end
end

local function Update_PowerSpawning()
	if spawning.Visible and serverConfig:GetAttribute("Power_Spawn") > 0 then
		spawning.Text = `{convertToHMS(powers - serverConfig:GetAttribute("Power_Spawn"))}`
		spawning.Stroke.Text = `{convertToHMS(powers - serverConfig:GetAttribute("Power_Spawn"))}`
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Update_SpawnedBoss(childName)
	local child = parent:FindFirstChild(childName)
	local child2

	if child then
		child2 = monster:FindFirstChild(childName)
	end

	if child then
		child.Text = `{childName} : {child2 and "✅" or "❌"}`
		child.Stroke.Text = `{childName} : {child2 and "✅" or "❌"}`
	end
end

local function Update_SpawnedPower(tool)
	if tool:IsA("Tool") then
		if parentChangedConnection then
			parentChangedConnection:Disconnect()
			parentChangedConnection = nil
		end

		if spawning.Visible then
			spawning.Visible = false
		end

		if not power_Name.Visible then
			power_Name.Visible = true
		end

		if not location.Visible then
			location.Visible = true
		end

		if not timeleft.Visible then
			timeleft.Visible = true
		end

		power_Name.Text = tool.Name
		power_Name.Outline.Text = tool.Name
		power_Name.Outline.TextColor3 = item[power[tool.Name]] or Color3.fromRGB(92, 140, 211)

		if localPlayer:GetAttribute("TH") then
			location.Text = `[เกาะที่เกิด : {tool:GetAttribute("SpawnLocation")}]` or "[เกาะที่เกิด : ไม่ทราบ]"
			location.Outline.Text = `[เกาะที่เกิด : {tool:GetAttribute("SpawnLocation")}]` or "[เกาะที่เกิด : ไม่ทราบ]]"
		else
			location.Text = `[Location: {tool:GetAttribute("SpawnLocation")}]` or "[Location: Unknown]"
			location.Outline.Text = `[Location: {tool:GetAttribute("SpawnLocation")}]` or "[Location: Unknown]"
		end

		local spawnTime2 = tool:GetAttribute("SpawnTime")

		if spawnTime2 then
			parentChangedConnection = tool:GetPropertyChangedSignal("Parent"):Connect(function()
				if tool.Parent ~= spawned_Powers then
					if power_Name.Visible then
						power_Name.Visible = false
					end

					if location.Visible then
						location.Visible = false
					end

					if timeleft.Visible then
						timeleft.Visible = false
					end

					if not spawning.Visible then
						spawning.Visible = true
					end

					parentChangedConnection:Disconnect()
					parentChangedConnection = nil
				end
			end)

			repeat
				task.wait(0.25)

				if Check_Distance() then
					if localPlayer:GetAttribute("TH") then
						timeleft.Text = `[เวลาที่เหลือ : {convertToHMS(spawnTime2 + powers_Despawn - os.time())}]`
						timeleft.Outline.Text = `[เวลาที่เหลือ : {convertToHMS(spawnTime2 + powers_Despawn - os.time())}]`
					else
						timeleft.Text = `[Time Left: {convertToHMS(spawnTime2 + powers_Despawn - os.time())}]`
						timeleft.Outline.Text = `[Time Left: {convertToHMS(spawnTime2 + powers_Despawn - os.time())}]`
					end
				end
			until not tool or tool.Parent ~= spawned_Powers or spawnTime2 + powers_Despawn - os.time() <= 0
		end
	end
end

Update_Region()
Update_ServerTime() -- equivalent call inferred; original call site unknown
serverConfig:GetAttributeChangedSignal("ServerTime"):Connect(function()
	if Check_Distance() then
		Update_ServerTime() -- equivalent call inferred; original call site unknown
	end
end)
serverConfig:GetAttributeChangedSignal("Timezone"):Connect(function()
	Update_Region()
end)
serverConfig:GetAttributeChangedSignal("Country"):Connect(function()
	Update_Region()
end)
localPlayer:GetAttributeChangedSignal("TH"):Connect(Update_Region)
serverConfig:GetAttributeChangedSignal("Meme_Beast"):Connect(function()
	if Check_Distance() then
		Update_MemeBeast()
	end
end)
serverConfig:GetAttributeChangedSignal("Power_Spawn"):Connect(function()
	if Check_Distance() then
		Update_PowerSpawning()
	end
end)

for _, child in ipairs(enemyTemplate:GetChildren()) do
	Update_SpawnedBoss(child.Name) -- equivalent call inferred; original call site unknown
end

notification.Event:Connect(function(childName)
	Update_SpawnedBoss(childName) -- equivalent call inferred; original call site unknown
end)
spawned_Powers.ChildAdded:Connect(Update_SpawnedPower)

function Format(p)
	return string.format("%02i", p)
end

function convertToHMS(p)
	local v = (p - p % 60) / 60
	local v2 = p - v * 60
	local v3 = v - (v - v % 60) / 60 * 60
	return Format(v3) .. ":" .. Format(v2)
end