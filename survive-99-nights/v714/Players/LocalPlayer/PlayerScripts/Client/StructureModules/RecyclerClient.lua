local createVector = vector.create
local RecyclerClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("RunService")
local v = {}
gui = Client.Interface.RecyclerActivateMenu
local v2 = nil

function AnimateRecycler(instance)
	if not instance or v[instance] then
		return
	end

	v[instance] = true
	task.spawn(function()
		local piston = instance:WaitForChild("Functional"):WaitForChild("Piston")

		if piston:GetAttribute("Origin") == nil then
			piston:SetAttribute("Origin", piston:GetPivot())
		end

		local origin = piston:GetAttribute("Origin")
		local v3 = origin - createVector(0, 1.8, 0)
		Client.TweenModule.new(function(p)
			piston:PivotTo((origin:Lerp(v3, p)))
		end, 0.06):Play()
		task.wait(0.06)
		Client.Utility.SpawnParticles("RecyclerSmash", v3 - createVector(0, 0.5, 0))
		v[instance] = nil
		local position = workspace.CurrentCamera.Focus.Position

		if (origin.Position - position).Magnitude < 15 then
			Client.CamShake.ShakeOnce(1.5, 25, 0.07, 0.2)
		end

		task.wait(0.3)
		Client.TweenModule.new(function(p)
			piston:PivotTo((v3:Lerp(origin, p)))
		end, 1, "Quad"):Play()
		task.wait(1)
	end)
end

Client.Events.AnimateRecycler:Connect(AnimateRecycler)

function ToggleRecycleMenu(p)
	if gui.Visible then
		gui.Visible = false
		Client.Sound.Play("CloseButton")
		v2 = nil
	else
		gui.Visible = true
		v2 = p
	end
end

function OpenRecyclerMenu(p)
	print("open menu")
	ToggleRecycleMenu(p)
end

Client.InteractionHandler.RegisterInteraction("Recycler", OpenRecyclerMenu)
local flag = true

function DoErrorMessage(p, p2)
	if flag then
		Client.PopUpUI.AddPopUp(p2, "warning")
		flag = false
		task.spawn(function()
			for _ = 1, 3 do
				p.TextColor3 = Color3.fromRGB(255, 0, 0)
				wait(0.3)
				p.TextColor3 = Color3.fromRGB(255, 255, 255)
				wait(0.3)
			end

			p.TextColor3 = Color3.fromRGB(255, 0, 0)
		end)
		task.spawn(function()
			wait(2.1)
			p.TextColor3 = Color3.fromRGB(255, 255, 255)
			flag = true
		end)
	end
end

function AttemptPurchase(p)
	if not v2 then
		return
	end

	local totalGems = workspace.Map.Campground:GetAttribute("TotalGems")

	if p == "GemOfTheForest" then
		totalGems = workspace.Map.Campground:GetAttribute("TotalGreenGems")
	end

	if totalGems >= 1 then
		local v3 = "TotalGems"

		if p == "GemOfTheForest" then
			workspace.Map.Campground:SetAttribute("GemOfTheForest", totalGems - 1)
			v3 = "TotalGreenGems"
		else
			workspace.Map.Campground:SetAttribute("TotalGems", totalGems - 1)
		end

		AnimateRecycler(v2)
		Client.Events.RequestRecycleMaterial:FireServer(v2, v3)
	elseif p == "GemOfTheForest" then
		DoErrorMessage(gui.GemOfTheForest.GemAmount, "not enough gems")
	else
		DoErrorMessage(gui.CultistGems.GemAmount, "not enough gems")
	end
end

function InitializeButtons()
	gui.CultistGem.Frame.BuyButton.Activated:Connect(function()
		AttemptPurchase("CultistGem")
		Client.Sound.Play("KeyPress", {
			Duplicate = true
		})
	end)
	gui.GemOfTheForest.Frame.BuyButton.Activated:Connect(function()
		AttemptPurchase("GemOfTheForest")
		Client.Sound.Play("KeyPress", {
			Duplicate = true
		})
	end)
	gui.CloseButton.Activated:Connect(function()
		Client.Sound.Play("CloseButton", {
			Duplicate = true
		})
		gui.Visible = false
		v2 = nil
	end)
end

function RecyclerAdded(p)
	if p.Parent == workspace.Structures then
	end
end

function RecyclerClient.Init()
	Client.Utility.ForAllTagged("RecyclerMachine", RecyclerAdded)
	InitializeButtons()
	workspace.Map.Campground:GetAttributeChangedSignal("TotalGems"):Connect(function()
		gui.CultistGem.GemAmount.Text = workspace.Map.Campground:GetAttribute("TotalGems")
	end)
	local totalGems = workspace.Map.Campground:GetAttribute("TotalGems") or 0
	gui.CultistGem.GemAmount.Text = totalGems
	workspace.Map.Campground:GetAttributeChangedSignal("TotalGreenGems"):Connect(function()
		gui.GemOfTheForest.GemAmount.Text = workspace.Map.Campground:GetAttribute("TotalGreenGems")
	end)
	local totalGreenGems = workspace.Map.Campground:GetAttribute("TotalGreenGems") or 0
	gui.GemOfTheForest.GemAmount.Text = totalGreenGems
end

return RecyclerClient