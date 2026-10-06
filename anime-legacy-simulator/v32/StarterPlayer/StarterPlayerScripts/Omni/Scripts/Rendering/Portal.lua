local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local portalBillboard = module.Assets:WaitForChild("Models"):WaitForChild("PortalBillboard")
local v = {}
local Portal = {}

local function Refresh(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	local ownsMap = module.Utils.PlayerStats.OwnsMap(v2.NextMapName, module.Data)

	if v2.Prompt then
		v2.Prompt.Enabled = ownsMap
	end

	if v2.Main then
		v2.Main.Color = ownsMap and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
	end

	if v2.Billboard then
		v2.Billboard.UI.Main.Desc.Text = v2.NextMapName and ownsMap and v2.NextMapName or "???"
	end
end

function Portal.Refresh()
	for k in v do
		Refresh(k)
	end
end

function Portal.Setup(parent)
	if v[parent] then
		Refresh(parent)
		return
	end

	local primaryPart = parent.PrimaryPart

	if not primaryPart then
		parent:Destroy()
		return
	end

	local name = parent.Parent and parent.Parent.Parent and parent.Parent.Parent.Name

	if not name then
		parent:Destroy()
		return
	end

	if not module.Shared.Maps.List[name] then
		parent:Destroy()
		return
	end

	local nextMapName = module.Shared.Maps.GetNextMapName(name)
	local clone = portalBillboard:Clone()
	clone.Position = primaryPart.Position + createVector(0, 12.5, 0)
	clone.Parent = parent
	clone.UI:AddTag("AnimatedHUD")
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = "Teleport to"
	proximityPrompt.ObjectText = name
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.Parent = primaryPart
	proximityPrompt:SetAttribute("Callback", (`{nextMapName} Teleport`))
	v[parent] = {
		Main = primaryPart,
		MapName = name,
		Prompt = proximityPrompt,
		NextMapName = nextMapName,
		Billboard = clone
	}
	Refresh(parent)
end

module:OnDataChanged({ "Maps" }, Portal.Refresh)
module.Utils.Instance:ObserveTaggedObject("Portal", function(model)
	if not model:IsA("Model") then
		return
	end

	Portal.Setup(model)
end)
return Portal