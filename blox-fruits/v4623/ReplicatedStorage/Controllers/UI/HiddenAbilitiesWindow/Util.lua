require(game.ReplicatedStorage.BuildUtil)
local v = {
	BackdropColor = Color3.fromRGB(255, 255, 255),
	FruitIconPosition = UDim2.fromScale(-0.013, 0.5),
	FruitIconSize = UDim2.fromScale(0.228, 1.498),
	FruitNamePosition = UDim2.fromScale(0.55, 0.3),
	Line1Position = UDim2.fromScale(0.555, 0.62),
	Line2Position = UDim2.fromScale(0.555, 0.85)
}
local Util = {
	_open = false,
	_clientInfo = nil,
	RESEARCH_ICONS = {
		Complete = {
			Image = "rbxassetid://119899021737369",
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(128, 128)
		},
		InProgress = {
			Image = "rbxassetid://119899021737369",
			ImageRectOffset = Vector2.new(128, 0),
			ImageRectSize = Vector2.new(128, 128)
		}
	},
	DEFAULT_FRUIT_APPEARANCE_INFO = v,
	FRUIT_APPEARANCE_SETTINGS = {
		["Gravity-Gravity"] = {
			BackdropColor = Color3.fromRGB(255, 152, 254),
			FruitIconPosition = UDim2.fromScale(-0.013, 0.5),
			FruitIconSize = UDim2.fromScale(0.228, 1.498),
			FruitNamePosition = UDim2.fromScale(0.55, 0.3),
			Line1Position = UDim2.fromScale(0.555, 0.62),
			Line2Position = UDim2.fromScale(0.555, 0.85)
		},
		["Creation-Creation"] = {
			BackdropColor = Color3.fromRGB(181, 251, 157),
			FruitIconPosition = UDim2.fromScale(0.004, 0.5),
			FruitIconSize = UDim2.fromScale(0.193, 1.269),
			FruitNamePosition = UDim2.fromScale(0.54, 0.3),
			Line1Position = UDim2.fromScale(0.54, 0.62),
			Line2Position = UDim2.fromScale(0.54, 0.85)
		},
		["Eagle-Eagle"] = {
			BackdropColor = Color3.fromRGB(158, 62, 57),
			FruitIconPosition = UDim2.fromScale(-0.015, 0.5),
			FruitIconSize = UDim2.fromScale(0.225, 1.5)
		},
		["Lightning-Lightning"] = {
			BackdropColor = Color3.fromRGB(255, 162, 0),
			FruitIconPosition = UDim2.fromScale(-0.015, 0.5),
			FruitIconSize = UDim2.fromScale(0.228, 1.2)
		},
		["Pain-Pain"] = {
			BackdropColor = Color3.fromRGB(255, 0, 0),
			FruitIconPosition = UDim2.fromScale(-0.015, 0.5),
			FruitIconSize = UDim2.fromScale(0.228, 1.2)
		},
		["Control-Control"] = {
			BackdropColor = Color3.fromRGB(0, 179, 255),
			FruitIconPosition = UDim2.fromScale(-0.015, 0.5),
			FruitIconSize = UDim2.fromScale(0.228, 1.2)
		}
	}
}
local MathUtil = require(game.ReplicatedStorage.Modules.Util.MathUtil)
local Abilities = require(game.ReplicatedStorage.Modules.HiddenAbilities.Abilities)
local fruitsWithAbilities = Abilities.FruitsWithAbilities
local Abilities2 = require(game.ReplicatedStorage.Modules.HiddenAbilities.Abilities)
local comingSoon = Abilities2.ComingSoon
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteFunction = Net:RemoteFunction("HiddenAbilitiesRF")
local flag = false

function Util.getClientInfo(callback, flag2: boolean?)
	local v2 = true
	task.spawn(function()
		if flag then
			flag2 = nil
		end

		while flag and Util._open do
			task.wait()
		end

		local function run()
			if v2 and Util._clientInfo and Util._open then
				callback(Util._clientInfo)
			end

			v2 = false
		end

		if Util._open then
			flag = true

			if Util._clientInfo == nil or flag2 then
				Util._clientInfo = nil
				local v3 = nil
				task.delay(3, function()
					v3 = nil

					if not Util._clientInfo then
						print("gettingClientInfo failed..")
						flag = false
					end
				end)
				Util._clientInfo = assert(remoteFunction:InvokeServer({
					Context = "GetList"
				}))

				if v3 then
					task.cancel(v3)
					v3 = nil
				end
			end

			flag = false
		end

		task.defer(run)
	end)
	return function()
		v2 = false
	end
end

function Util.getFileName(p: number, p2: number?)
	local v2 = ("ABCDEFGHIJKLMNOPQRSTUVWXYZA"):sub(p, p)

	if p2 then
		v2 = `{v2}-{tostring(p2)}` or v2
	end

	return (`Secret File {v2}`)
end

local v2 = nil

function Util.fruitList()
	if v2 ~= nil then
		return assert(v2, "bad fruitList")
	end

	v2 = {}
	assert(v2, "bad fruitList")

	for _, fruitsWithAbility in pairs(fruitsWithAbilities) do
		table.insert(v2, fruitsWithAbility)
	end

	for i = 1, #comingSoon do
		table.insert(v2, comingSoon[i])
	end

	return assert(v2, "bad fruitList")
end

function Util.getCurrentlyResearching(p, p2: string, p3: string?)
	for _, ability in pairs(p.FruitList[p2].Abilities) do
		if not (not p3 or p3 == ability.StorageName) then
			continue
		end

		for _, experiment in pairs(ability.Experiments) do
			if not ability.Owned and experiment.Researching then
				return experiment
			end
		end
	end

	return nil
end

function Util.connectButtons(items, callback)
	local connections = {}
	local flag2 = false

	local function fn()
		flag2 = true

		for _, connection in connections do
			if connection.Connected then
				connection:Disconnect()
			end
		end

		table.clear(connections)
	end

	task.defer(function()
		for k, item in items do
			if flag2 then
				fn()
				break
			else
				local v3 = k
				table.insert(connections, item.MouseButton1Click:Connect(function()
					callback(v3)
				end))
			end
		end
	end)
	return fn
end

function Util.formatProgress(p: number, p2: number)
	local alpha = math.clamp(p / p2, 0, 1)
	local rounded = MathUtil.round(alpha * 100, 1)
	return {
		Alpha = alpha,
		Percent = rounded,
		String = `{tostring(rounded)}%`
	}
end

function Util:setDoubleText(text: string)
	self.Text = text
	local textLabel = self:FindFirstChild("TextLabel")
	textLabel.Text = text
end

function Util.setButtonText(instance, text: string)
	local textLabel = instance:FindFirstChild("TextLabel")
	local textLabel2 = textLabel:FindFirstChild("TextLabel")
	textLabel.Text = text
	textLabel2.Text = text
end

function Util:setButtonState(p: string)
	local trans = self:FindFirstChild("Trans")

	if p == "Inactive" then
		self.BackgroundColor3 = Color3.fromRGB(158, 158, 158)
		self.BorderColor3 = Color3.fromRGB(48, 48, 48)
		trans.BackgroundColor3 = Color3.fromRGB(191, 191, 191)
		trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
	elseif p == "StartResearch" or p == "CompleteResearch" or p == "ViewResearch" then
		self.BackgroundColor3 = Color3.fromRGB(255, 214, 49)
		self.BorderColor3 = Color3.fromRGB(136, 61, 0)
		trans.BackgroundColor3 = Color3.fromRGB(255, 241, 87)
		trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
	elseif p == "Green" then
		self.BackgroundColor3 = Color3.fromRGB(56, 255, 46)
		self.BorderColor3 = Color3.fromRGB(2, 136, 0)
		trans.BackgroundColor3 = Color3.fromRGB(154, 255, 87)
		trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
	end
end

return Util