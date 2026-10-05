local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fusion = require(ReplicatedStorage.Shared.Flags.GameplayBalance).Fusion
local GuiService = game:GetService("GuiService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage2.Shared.Types.AssetItem)
local AssetItems = require(ReplicatedStorage2.Shared.Util.AssetItems)
local Assets = require(ReplicatedStorage2.Data.Assets)
local directory = Assets.Directory
local Audio = require(ReplicatedStorage2.Shared.Audio)
local ButtonFX = require(ReplicatedStorage2.Client.UI.VFX.ButtonFX)
require(ReplicatedStorage2.Shared.Globals.Constants)
local Eggs = require(ReplicatedStorage2.Shared.Types.Eggs)
local FuseKernel = require(ReplicatedStorage2.Shared.Util.FuseKernel)
local FuseMachineBackpackSelection = require(script.FuseMachineBackpackSelection)
local FuseMachineProgressPresentation = require(script.FuseMachineProgressPresentation)
local FuseMachineSelectedSlot = require(script.FuseMachineSelectedSlot)
local FuseMachineSignals = require(ReplicatedStorage2.Client.FuseMachineSignals)
local FuseMachine = require(ReplicatedStorage2.Shared.Types.FuseMachine)
local GUI = require(ReplicatedStorage2.Client.GUI)
local Log = require(ReplicatedStorage2.Packages.Log)
local MenuNavigation = require(ReplicatedStorage2.Client.MenuNavigation)
local Toast = require(ReplicatedStorage2.Client.Notifications.Toast)
local Remotes = require(ReplicatedStorage2.Shared.Remotes)
local Save = require(ReplicatedStorage2.Shared.Save)
local Simple = require(ReplicatedStorage2.Packages.FormatNumber.Simple)
local Tabs = require(ReplicatedStorage2.Client.Tabs)
local TryLock = require(ReplicatedStorage2.Shared.Utils.TryLock)
local color = Color3.fromRGB(255, 0, 0)
local v = Log.new()
local tryLock = TryLock()
local tryLock2 = TryLock()
local tryLock3 = TryLock()
return {
	Start = function()
		local petFuse = GUI.PetFuse()
		petFuse.ResetOnSpawn = false
		local fuseMain = petFuse.FuseMain
		assert(fuseMain:IsA("GuiObject"), "PetFuse.FuseMain must be a GuiObject")
		local fuseInputs = fuseMain.FuseInputs
		assert(fuseInputs:IsA("Frame"), "PetFuse.FuseMain.FuseInputs must be a Frame")
		local fuse = fuseMain.Fuse
		assert(fuse:IsA("ImageButton"), "PetFuse.FuseMain.Fuse must be an ImageButton")
		local price = fuse.Price
		assert(price:IsA("TextLabel"), "PetFuse.FuseMain.Fuse.Price must be a TextLabel")
		local backgroundColor3 = fuse.BackgroundColor3
		local lerped = backgroundColor3:Lerp(Color3.new(0, 0, 0), 0.35)
		local fusePetInventory = petFuse.FusePetInventory
		assert(fusePetInventory:IsA("GuiObject"), "PetFuse.FusePetInventory must be a GuiObject")
		local scrollingFrame = fusePetInventory.ScrollingFrame
		assert(scrollingFrame:IsA("ScrollingFrame"), "PetFuse.FusePetInventory.ScrollingFrame must be a ScrollingFrame")
		local close = fusePetInventory:FindFirstChild("Close")
		local includeEquipped = fusePetInventory:WaitForChild("IncludeEquipped")
		local box = includeEquipped:WaitForChild("Box")
		local icon = box:WaitForChild("Icon")
		local uIGradient = box:WaitForChild("UIGradient")
		local emptyState = fusePetInventory:WaitForChild("EmptyState")
		local visible = false
		local output = fuseMain.FuseOutput.Output
		assert(output:IsA("Frame"), "PetFuse.FuseMain.FuseOutput.Output must be a Frame")
		local designBars = fuseMain.DesignBars
		assert(designBars:IsA("Frame"), "PetFuse.FuseMain.DesignBars must be a Frame")
		local briefing = fuseMain:FindFirstChild("Briefing")
		local ok

		if briefing ~= nil then
			ok = briefing:FindFirstChild("Ok")
		end

		local function inputSlot(p: number)
			local frame = fuseInputs:FindFirstChild((`Input{p}`))
			local v6

			if frame == nil then
				v6 = false
			else
				v6 = frame:IsA("Frame")
			end

			assert(v6, (`PetFuse.FuseMain.FuseInputs.Input{p} is missing`))
			return frame
		end

		local machines = Workspace:WaitForChild("World").Machines
		assert(machines:IsA("Folder"), "Workspace.World.Machines must be a Folder")
		local fuseMachine = machines.FuseMachine
		assert(fuseMachine:IsA("Model"), "Workspace FuseMachine must be a Model")
		local overhead = fuseMachine.Overhead
		assert(overhead:IsA("BasePart"), "FuseMachine.Overhead must be a BasePart")
		local billboardGui = overhead.BillboardGui
		assert(billboardGui:IsA("BillboardGui"), "FuseMachine.Overhead.BillboardGui must be a BillboardGui")
		local countdown = billboardGui.Countdown
		assert(countdown:IsA("TextLabel"), "FuseMachine overhead Countdown must be a TextLabel")
		local v6 = FuseMachineBackpackSelection.new(scrollingFrame)
		local v7 = FuseMachineProgressPresentation.new(output, designBars)
		local v8 = {}
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function notifyError(text: string)
			Toast.Show({
				Text = text,
				Color = color,
				Seconds = 3
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getSelectedCategory(p)
			local fusionSlot = p.FusionSlots[1]

			if fusionSlot == nil then
				return nil
			end

			local v9 = p.Inventory[fusionSlot]

			if v9 then
				return v9.Category
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getSelectedTemporary(p)
			local fusionSlot = p.FusionSlots[1]

			if fusionSlot == nil then
				return nil
			end

			local v9 = p.Inventory[fusionSlot]

			if v9 then
				return v9.CreatorTemporary == true
			end

			return nil
		end

		local function updateOverheadInputCount(p)
			local count = 0

			if p ~= nil then
				for i = 1, 2 do
					local fusionSlot = p.FusionSlots[i]

					if fusionSlot ~= nil and p.Inventory[fusionSlot] ~= nil then
						count += 1
					end
				end

				local fusionSlot3 = p.FusionSlots[3]

				if fusionSlot3 ~= nil and p.Inventory[fusionSlot3] ~= nil then
					count += 1
				end
			end

			countdown.Text = `{count}/{fusion.INPUT_COUNT}`
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroySlot(i: number)
			local v9 = v8[i]

			if v9 then
				v9:Destroy()
				v8[i] = nil
			end
		end

		local function requestReturn(p: string)
			tryLock2(function()
				local v9, v10 = Remotes.Fusery.EjectPet:InvokeServer(p)

				if not v9 then
					notifyError(typeof(v10) ~= "string" and "Failed to return pet" or v10) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local function render()
			local v9 = Save.Await()
			local v10 = table.create(3, false)

			if briefing ~= nil then
				briefing.Visible = v9 ~= nil and not v9.FusionInfoAcknowledged
			end

			updateOverheadInputCount(v9)

			if v9 == nil then
				fuse.Visible = true
				fuse.Active = false
				fuse.BackgroundColor3 = lerped
				price.Text = `{fusion.INPUT_COUNT} Pet Left`
				v7:Update(v10, nil)
			else
				local v11 = nil
				local values = {}

				for i = 1, 3 do
					local fusionSlot = v9.FusionSlots[i]
					local v12

					if fusionSlot then
						v12 = v9.Inventory[fusionSlot]
					end

					local frame = fuseInputs:FindFirstChild((`Input{i}`))
					local v13

					if frame == nil then
						v13 = false
					else
						v13 = frame:IsA("Frame")
					end

					assert(v13, (`PetFuse.FuseMain.FuseInputs.Input{i} is missing`))

					if fusionSlot == nil or v12 == nil then
						destroySlot(i) -- equivalent call inferred; original call site unknown
						frame.Full.Visible = false
						frame.Empty.Visible = true
					else
						v10[i] = true
						v11 = v11 or v12.Category
						local v14 = v8[i]

						if v14 == nil or v14:GetUid() ~= fusionSlot then
							destroySlot(i) -- equivalent call inferred; original call site unknown
							v8[i] = FuseMachineSelectedSlot.new(frame, fusionSlot, v12, requestReturn)
						end

						table.insert(values, AssetItems.Decode(v12))
					end
				end

				local active

				if #values == fusion.INPUT_COUNT then
					active = not v9.FusionLocked and v9.FusionEggReward == false
				else
					active = false
				end

				local icon2

				if v11 ~= nil then
					local v13 = directory[v11]
					assert(v13 ~= nil, (`Missing asset config {v11}`))
					icon2 = v13.Egg.Icon
				end

				v7:Update(v10, icon2)

				if active then
					for _, v14 in ipairs(values) do
						if v14.Category == v11 then
							continue
						end

						active = false
						break
					end
				end

				fuse.Visible = true
				fuse.Active = active

				if active then
					fuse.BackgroundColor3 = backgroundColor3
					price.Text = "$ " .. Simple.FormatCompact(FuseKernel.PriceFor(values))
				else
					fuse.BackgroundColor3 = lerped
					price.Text = `{fusion.INPUT_COUNT - #values} Pet Left`
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function scheduleRender()
			if flag then
				return
			end

			flag = true
			task.defer(function()
				flag = false
				render()
			end)
		end

		local function requestAcknowledgeInfo()
			tryLock3(function()
				if briefing == nil or not briefing.Visible then
					return
				end

				if Remotes.Fusery.ConfirmBriefing:InvokeServer() == true then
					briefing.Visible = false
					return
				end

				notifyError("Failed to save Fuse Machine info acknowledgement") -- equivalent call inferred; original call site unknown
				scheduleRender() -- equivalent call inferred; original call site unknown
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeSelection()
			v6:Close()
			fusePetInventory.Visible = false
			fuseMain.Visible = true
			MenuNavigation.SetOverride("FusePetSelection", nil)
		end

		local function requestInsert(p: string)
			tryLock2(function()
				local v9, v10 = Remotes.Fusery.LoadPet:InvokeServer(p, visible)

				if v9 then
					closeSelection() -- equivalent call inferred; original call site unknown
					scheduleRender() -- equivalent call inferred; original call site unknown
				else
					notifyError(typeof(v10) ~= "string" and "Failed to insert pet" or v10) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateEmptyState(p: number)
			emptyState.Visible = p == 0
			emptyState.Text = visible and "No eligible pets for this fuse." or "No matching unequipped pets.\nTry including equipped pets."
		end

		local function paintIncludeEquipped()
			icon.Visible = visible
			local v9 = uIGradient
			local v10

			if visible then
				v10 = Color3.fromRGB(83, 202, 19)
			else
				v10 = Color3.fromRGB(83, 83, 102)
			end

			v9.Color = ColorSequence.new(v10)
			includeEquipped:SetAttribute("Checked", visible)
		end

		local function startSelection()
			if v6:IsOpen() then
				return
			end

			local v9 = Save.Await()

			if v9 == nil then
				return
			end

			local selectedCategory = getSelectedCategory(v9) -- equivalent call inferred; original call site unknown
			local v12 = visible
			local selectedTemporary = getSelectedTemporary(v9) -- equivalent call inferred; original call site unknown
			local v13 = v6:Open(v9, selectedCategory, requestInsert, v12, selectedTemporary)
			updateEmptyState(v13) -- equivalent call inferred; original call site unknown
			fuseMain.Visible = false
			fusePetInventory.Visible = true
			v6:RefreshGridLayout()
			local setOverride = MenuNavigation.SetOverride
			local v16

			if v13 == 0 then
				v16 = includeEquipped
			end

			setOverride("FusePetSelection", fusePetInventory, v16, closeSelection, 1000, true)
		end

		local function refreshSelection()
			if not v6:IsOpen() then
				return
			end

			local v9 = Save.Await()

			if v9 == nil or v9.FusionLocked or v9.FusionEggReward ~= false or #v9.FusionSlots >= fusion.INPUT_COUNT then
				closeSelection() -- equivalent call inferred; original call site unknown
			else
				local canvasPosition = scrollingFrame.CanvasPosition
				local name = nil
				local topOverride = MenuNavigation.TopOverride()

				if not MenuNavigation.IsCursorActive() and topOverride ~= nil and topOverride.Root == fusePetInventory then
					local selectedObject = GuiService.SelectedObject

					if selectedObject == nil or selectedObject.Parent ~= scrollingFrame then
						selectedObject = topOverride.Initial
					end

					if selectedObject ~= nil and selectedObject.Parent == scrollingFrame then
						name = selectedObject.Name
					end
				end

				v6:Close()
				local selectedCategory = getSelectedCategory(v9) -- equivalent call inferred; original call site unknown
				local v12 = visible
				local selectedTemporary = getSelectedTemporary(v9) -- equivalent call inferred; original call site unknown
				updateEmptyState(v6:Open(v9, selectedCategory, requestInsert, v12, selectedTemporary)) -- equivalent call inferred; original call site unknown
				v6:RefreshGridLayout()
				scrollingFrame.CanvasPosition = canvasPosition

				if name ~= nil then
					local guiObject = scrollingFrame:FindFirstChild(name)

					if not (guiObject and guiObject:IsA("GuiObject")) then
						guiObject = includeEquipped
					end

					MenuNavigation.SetOverride(
						"FusePetSelection",
						fusePetInventory,
						guiObject,
						closeSelection,
						1000,
						true
					)
				end
			end
		end

		local function toggleIncludeEquipped()
			tryLock2(function()
				visible = not visible
				paintIncludeEquipped()
				refreshSelection()
			end)
		end

		local function refreshPickerLayout()
			if v6:IsOpen() then
				v6:RefreshGridLayout()
			end
		end

		local function requestFuse()
			tryLock(function()
				local v9 = Save.Await()

				if v9 == nil then
					return
				end

				local count = 0

				for _ in pairs(v9.EggInventory) do
					count += 1
				end

				if Eggs.MAX_INVENTORY <= count then
					notifyError("Your egg inventory is full!") -- equivalent call inferred; original call site unknown
					return
				end

				local v10, v11, v12 = Remotes.Fusery.BeginFuse:InvokeServer()

				if v10 then
					if not FuseMachine.FuseResult(v12) then
						v:AtError():Log("Fuse server returned an invalid reward")
						return
					end

					Audio.Play(83520877125467, script, {
						Volume = 1.5
					})
					FuseMachineSignals.FuseStarted:Fire(v12)
					scheduleRender() -- equivalent call inferred; original call site unknown
				else
					notifyError(typeof(v11) ~= "string" and "Failed to start fuse" or v11) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		paintIncludeEquipped()
		petFuse:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshPickerLayout)
		ButtonFX(includeEquipped, 1.015, toggleIncludeEquipped)
		fuseMain.Visible = true
		output.Visible = true
		fusePetInventory.Visible = false

		if briefing ~= nil then
			briefing.Visible = false
		end

		for i = 1, 3 do
			local frame = fuseInputs:FindFirstChild((`Input{i}`))
			local v9

			if frame == nil then
				v9 = false
			else
				v9 = frame:IsA("Frame")
			end

			assert(v9, (`PetFuse.FuseMain.FuseInputs.Input{i} is missing`))
			frame.Full.Visible = false
			frame.Empty.Visible = true
			local add = frame.Empty.Add
			assert(add:IsA("ImageButton"), (`PetFuse.FuseMain.FuseInputs.Input{i}.Empty.Add must be an ImageButton`))
			add.Activated:Connect(startSelection)
			ButtonFX(add, 1.08)
		end

		fuse.Activated:Connect(requestFuse)
		ButtonFX(fuse, 1.08)

		if close ~= nil then
			GUI.OnActivated(close, closeSelection)
			ButtonFX(close, 1.08)
		end

		if ok ~= nil then
			ok.Activated:Connect(requestAcknowledgeInfo)
			ButtonFX(ok)
		end

		Save.WatchFields({
			"FusionSlots",
			"FusionLocked",
			"FusionEggReward",
			"FusionInfoAcknowledged",
			"Inventory",
			"EggInventory"
		}, function()
			if Tabs.IsActive("PetFuse") then
				scheduleRender() -- equivalent call inferred; original call site unknown
			end
		end)
		Save.WatchFields({
			"FusionSlots",
			"FusionLocked",
			"FusionEggReward",
			"Inventory",
			"EquippedAssets"
		}, function()
			if Tabs.IsActive("PetFuse") then
				refreshSelection()
			end
		end)
		Tabs.Activated:Connect(function(p: string)
			if p == "PetFuse" then
				scheduleRender() -- equivalent call inferred; original call site unknown
			end
		end)
		Tabs.Deactivated:Connect(function(p: string?)
			if p == "PetFuse" then
				visible = false
				paintIncludeEquipped()
				closeSelection() -- equivalent call inferred; original call site unknown
			end
		end)
		render()
		local BalanceConfig = require(ReplicatedStorage2.Shared.Flags.BalanceConfig)
		BalanceConfig.Changed:Connect(scheduleRender)
	end
}