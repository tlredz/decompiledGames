game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local info = Workspace:WaitForChild("Info")
local noBuy = info:WaitForChild("DandyTracker"):WaitForChild("NoBuy")
local dandyStoreOpen = info:WaitForChild("DandyStoreOpen")
local v = 4
local v2 = 0
local v3 = 1
local normal = ""
local blink = ""
local v4 = nil
local thread = nil
local v5 = {
	Stage1 = {
		Normal = "rbxassetid://104553710025363",
		Blink = "rbxassetid://81122020123978",
		Happy = "rbxassetid://121849818818365"
	},
	Stage2 = {
		Normal = "rbxassetid://114877934529176",
		Blink = "rbxassetid://100411793831395",
		Worried = "rbxassetid://16883352062"
	},
	Stage3 = {
		Normal = "rbxassetid://127475509382530",
		Blink = "rbxassetid://93431163867879"
	},
	Reset = "rbxassetid://90479718244700"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function updateStage()
	local value = noBuy.Value

	if value == 0 then
		v3 = 1
		normal = v5.Stage1.Normal
		blink = v5.Stage1.Blink
	elseif value == 1 then
		v3 = 2
		normal = v5.Stage2.Normal
		blink = v5.Stage2.Blink
	else
		v3 = 3
		normal = v5.Stage3.Normal
		blink = v5.Stage3.Blink
	end
end

local function getHeadTexture()
	if not v4 then
		return nil
	end

	local headPart = v4:FindFirstChild("HeadPart")

	if headPart and headPart:IsA("ObjectValue") and headPart.Value and headPart.Value:IsA("MeshPart") then
		return headPart.Value
	end

	if v4:FindFirstChild("Head") then
		return v4.Head
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTexture(textureID)
	local headTexture = getHeadTexture()

	if headTexture then
		headTexture.TextureID = textureID
	end
end

local function performBlink()
	if not dandyStoreOpen.Value then
		return
	end

	local headTexture = getHeadTexture()

	if not headTexture then
		return
	end

	updateStage() -- equivalent call inferred; original call site unknown
	local textureID = headTexture.TextureID

	if textureID == v5.Stage1.Happy or textureID == v5.Stage2.Worried or textureID == v5.Reset or textureID ~= normal then
		return
	end

	setTexture(blink) -- equivalent call inferred; original call site unknown
	task.wait(0.2)

	if dandyStoreOpen.Value then
		local headTexture2 = getHeadTexture()

		if headTexture2 and headTexture2.TextureID == blink then
			setTexture(normal) -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startBlinkLoop()
	if thread then
		thread:Disconnect()
		thread = nil
	end

	v2 = 0
	thread = task.spawn(function()
		while v4 and v4.Parent do
			if dandyStoreOpen.Value then
				local now = tick()
				local v6 = now - v2

				if v <= v6 then
					v2 = now
					performBlink()
					v = math.random(3, 6)
				end
			end

			task.wait(0.5)
		end
	end)
end

local function onDandyAdded(p)
	if p.Name == "DandyShop" then
		v4 = p
		updateStage() -- equivalent call inferred; original call site unknown
		task.wait(0.1)
		startBlinkLoop() -- equivalent call inferred; original call site unknown
	end
end

local function onDandyRemoved(p)
	if p == v4 then
		if thread then
			task.cancel(thread)
			thread = nil
		end

		v4 = nil
	end
end

updateStage() -- equivalent call inferred; original call site unknown
noBuy.Changed:Connect(updateStage)
CollectionService:GetInstanceAddedSignal("Blinker"):Connect(onDandyAdded)
CollectionService:GetInstanceRemovedSignal("Blinker"):Connect(onDandyRemoved)

for _, v6 in ipairs(CollectionService:GetTagged("Blinker")) do
	if v6.Name ~= "DandyShop" then
		continue
	end

	if v6.Name ~= "DandyShop" then
		break
	end

	v4 = v6
	updateStage() -- equivalent call inferred; original call site unknown
	task.wait(0.1)

	if thread then
		thread:Disconnect()
		thread = nil
	end

	v2 = 0
	thread = task.spawn(function()
		while v4 and v4.Parent do
			if dandyStoreOpen.Value then
				local now = tick()
				local v7 = now - v2

				if v <= v7 then
					v2 = now
					performBlink()
					v = math.random(3, 6)
				end
			end

			task.wait(0.5)
		end
	end)
	break
end