game:GetService("ReplicatedStorage")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
return function(p)
	local createElement = React.createElement
	local root = ReactRoblox.createRoot(p)
	local Maid = require(game.ReplicatedStorage.Util.Maid)
	local maid = Maid.new()
	task.spawn(function()
		local createPortal = ReactRoblox.createPortal
		local Interface = require(script.Parent.Interface)
		local rootComponent = Interface.rootComponent
		local folder = Instance.new("Folder")
		local folder2 = Instance.new("Folder", folder)
		folder2.Name = "Explorers"
		local folder3 = Instance.new("Folder", folder)
		folder3.Name = "Objectives"
		local folder4 = Instance.new("Folder", folder)
		folder4.Name = "Floors"
		local v2 = {
			dungeonFolder = 0
		}

		for i = 1, 10 do
			local folder5 = Instance.new("Folder", folder4)
			folder5.Name = tostring(i)
			folder5:SetAttribute("HasBoss", math.random(0, 5) == 1)
			folder5:SetAttribute("ShowTimer", math.random(0, 5) == 1)
			folder5:SetAttribute("ShowEnemyCounter", math.random(0, 5) ~= 1)
		end

		local folder5 = Instance.new("Folder", folder3)
		local HttpService = game:GetService("HttpService")
		folder5.Name = HttpService:GenerateGUID(false)
		folder5:SetAttribute("Name", "Eliminate All Enemies")
		folder5:SetAttribute("IsComplete", true)
		folder5:SetAttribute("IsOptional", true)
		local folder6 = Instance.new("Folder", folder5)
		local HttpService2 = game:GetService("HttpService")
		folder6.Name = HttpService2:GenerateGUID(false)
		folder6:SetAttribute("Name", "Eliminate All Enemies")
		folder6:SetAttribute("IsComplete", false)
		folder6:SetAttribute("IsOptional", true)
		folder6:SetAttribute("IsHidden", true)

		for i = 1, 4 do
			local folder7 = Instance.new("Folder", folder2)

			if i == 1 then
				local v3 = folder7
				task.delay(1, function()
					v3:SetAttribute("RespawningAt", workspace:GetServerTimeNow() + 6)
				end)
				local v4 = folder7
				task.delay(4, function()
					v4:SetAttribute("RespawningAt", nil)
				end)
			end

			local HttpService3 = game:GetService("HttpService")
			folder7.Name = HttpService3:GenerateGUID(false)
			folder7:SetAttribute("Color", ({
				Color3.fromRGB(38, 227, 0),
				Color3.fromRGB(0, 166, 255),
				Color3.fromRGB(190, 49, 255),
				Color3.fromRGB(255, 115, 7)
			})[i])
			local objectValue = Instance.new("ObjectValue", folder7)
			objectValue.Name = "Player"
			objectValue.Value = Instance.new("Model", workspace)
			objectValue.Value.Name = "TestPlayer" .. i
			maid:GiveTask(objectValue.Value)
			local objectValue2 = Instance.new("ObjectValue", folder7)
			objectValue2.Name = "Character"
			objectValue2.Value = Instance.new("Model", workspace)
			maid:GiveTask(objectValue2.Value)
			local objectValue3 = Instance.new("ObjectValue", folder7)
			objectValue3.Name = "Humanoid"
			local humanoid = Instance.new("Humanoid", workspace)
			humanoid.Health = math.random(0, 100)
			maid:GiveTask(humanoid)
			objectValue3.Value = humanoid
		end

		v2.dungeonFolder = folder
		root:render((createPortal(createElement(rootComponent, v2), p)))
	end)
	return function()
		maid:Destroy()
		root:unmount()
	end
end