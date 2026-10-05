local PetController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Observers = require(ReplicatedStorage.Packages.Observers)
local PetConstants = require(ReplicatedStorage.Modules.Shared.Pets.PetConstants)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local v = { "AcceptPlayerRequestButtonPiggy", "AcceptPlayerRequestButtonCarry", "AcceptPlayerRequestButtonShoulders" }
local clone = {}
local v2 = false
local client2ClientAccept = nil
local accept = nil
local acceptPlayerRequestButtonPet = nil
local decline = nil
local sent = nil
local mouseButton1ClickConnection = nil
local mouseButton1ClickConnection2 = nil
local count = 0
local flag = false
PetController.OnEquippedPetsChanged = Signal.new()

function PetController.GetEquippedPets()
	return table.clone(clone)
end

function PetController.IsPetEquipped(p: string)
	return table.find(clone, p) ~= nil
end

local function setEquippedPets(p)
	clone = p ~= nil and table.clone(p) or {}
	PetController.OnEquippedPetsChanged:Fire(PetController.GetEquippedPets())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isInVehicle(_)
	return VehicleController.IsPlayerDriving() or VehicleController.IsPlayerDrivingAirVehicle()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateVehicleState(_)
	local inVehicle = isInVehicle() -- equivalent call inferred; original call site unknown

	if inVehicle and not v2 then
		v2 = true
		Remotes.fireServer("Pet_Despawn")
	elseif not inVehicle and v2 then
		v2 = false
		Remotes.fireServer("Pet_Respawn")
	end
end

local maid = Janitor.new()

local function onCharacterAdded(instance)
	maid:Cleanup()
	v2 = false
	local humanoid = instance:WaitForChild("Humanoid", 10)

	if humanoid == nil then
		return
	end

	for _, v3 in {
		VehicleController.OnPlayerStartedDriving,
		VehicleController.OnPlayerStartedDrivingLegacy,
		VehicleController.OnPlayerStoppedDriving,
		VehicleController.OnPlayerStoppedDrivingLegacy
	} do
		maid:Add(v3:Connect(function()
			updateVehicleState() -- equivalent call inferred; original call site unknown
		end))
	end

	maid:Add(humanoid.Seated:Connect(function()
		updateVehicleState() -- equivalent call inferred; original call site unknown
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideInteractionRequest()
	if acceptPlayerRequestButtonPet ~= nil then
		acceptPlayerRequestButtonPet.Visible = false
	end

	if client2ClientAccept ~= nil then
		client2ClientAccept.Visible = false
	end

	if mouseButton1ClickConnection ~= nil then
		mouseButton1ClickConnection:Disconnect()
		mouseButton1ClickConnection = nil
	end

	if mouseButton1ClickConnection2 ~= nil then
		mouseButton1ClickConnection2:Disconnect()
		mouseButton1ClickConnection2 = nil
	end
end

function PetController.ShowIncomingRequest(text: string, p, callback)
	if client2ClientAccept == nil or accept == nil or acceptPlayerRequestButtonPet == nil or client2ClientAccept.Visible then
		return
	end

	for _, childName in v do
		local guiObject = accept:FindFirstChild(childName)

		if guiObject ~= nil and guiObject:IsA("GuiObject") then
			guiObject.Visible = false
		end
	end

	local playersFace = accept:FindFirstChild("PlayersFace")

	if playersFace ~= nil and playersFace:IsA("ImageLabel") then
		playersFace.Image = `https://www.roblox.com/headshot-thumbnail/image?userId={p.UserId}&width=420&height=420&format=png`
	end

	local nameOfAnimation = accept:FindFirstChild("NameOfAnimation")

	if nameOfAnimation ~= nil and nameOfAnimation:IsA("TextLabel") then
		nameOfAnimation.Text = text
	end

	flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function respond(flag2: boolean)
		if flag then
			return
		end

		flag = true
		hideInteractionRequest() -- equivalent call inferred; original call site unknown
		callback(flag2)
	end

	if mouseButton1ClickConnection ~= nil then
		mouseButton1ClickConnection:Disconnect()
	end

	mouseButton1ClickConnection = acceptPlayerRequestButtonPet.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag = true
		hideInteractionRequest() -- equivalent call inferred; original call site unknown
		callback(true)
	end)

	if mouseButton1ClickConnection2 ~= nil then
		mouseButton1ClickConnection2:Disconnect()
		mouseButton1ClickConnection2 = nil
	end

	if decline ~= nil then
		mouseButton1ClickConnection2 = decline.MouseButton1Click:Connect(function()
			if flag then
				return
			end

			flag = true
			hideInteractionRequest() -- equivalent call inferred; original call site unknown
			callback(false)
		end)
	end

	acceptPlayerRequestButtonPet.Visible = true
	client2ClientAccept.Visible = true
	count += 1
	local v3 = count
	task.delay(PetConstants.INTERACTION_REQUEST_TIMEOUT, function()
		if v3 == count and client2ClientAccept ~= nil and client2ClientAccept.Visible then
			respond(false) -- equivalent call inferred; original call site unknown
		end
	end)
end

function PetController.ShowMessageSent()
	if sent == nil then
		return
	end

	sent.Visible = true
	task.delay(5, function()
		if sent ~= nil then
			sent.Visible = false
		end
	end)
end

function PetController.FrameworkInit() end

function PetController.FrameworkStart()
	local mainGUIHandler = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGUIHandler", 10)

	if mainGUIHandler == nil then
		return
	end

	local client2Client = mainGUIHandler:WaitForChild("Client2Client", 10)

	if client2Client == nil then
		return
	end

	client2ClientAccept = client2Client:WaitForChild("Client2ClientAccept", 10)

	if client2ClientAccept == nil then
		return
	end

	accept = client2ClientAccept:WaitForChild("Accept", 10)

	if accept == nil then
		return
	end

	acceptPlayerRequestButtonPet = accept:WaitForChild("AcceptPlayerRequestButtonPet", 10)

	if acceptPlayerRequestButtonPet == nil then
		warn("PetController: missing Client2ClientAccept.Accept.AcceptPlayerRequestButtonPet - add this button in Studio to enable Pet/Feed interaction requests")
	end

	decline = accept:WaitForChild("Decline", 10)
	local menu = mainGUIHandler:WaitForChild("Menu", 10)

	if menu ~= nil then
		sent = menu:WaitForChild("Sent", 10)
	end

	Remotes.connect("Pet_EquippedPetsChanged", function(p)
		setEquippedPets(p)
	end)
	Observers.observeLocalCharacter(function(p)
		onCharacterAdded(p)
	end)
end

return PetController