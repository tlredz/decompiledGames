require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Engine.Service.RAPService)
require(script.Parent.Parent.Booth.RAPChart)
local PriceHistory = {}
require(ReplicatedStorage.Engine.Service.GamepadSupport)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = "ball"
local v8 = nil
local flag = false

local function renderSelection()
	if not (v8 and v.Visible) then
		return
	end

	v["标题"].Text = v8.name .. " · Price History"

	if v8.loading then
		v2.SetLoading()
		v3.Text = "Loading..."
		v3.Visible = true
	elseif v8.failed then
		v2.SetLoading()
		v3.Text = "Unable to load prices"
		v3.Visible = true
	else
		v2.Render(v8.buckets)
		v3.Text = "No sales data"
		v3.Visible = v["RAP信息区"]["RAP数值"].Text == "--"
	end
end

function PriceHistory.Close()
	if not flag then
		return
	end

	v.Visible = false
	v4.Visible = true
	v["RAP信息区"]["折线图"]["数据详情框"].Visible = false
end

function PriceHistory.SetCategory(p)
	PriceHistory.Close()
	v7 = p
	v8 = nil

	if flag then
		v6.Text = "--"
		v5.Active = false
	end
end

function PriceHistory.Open() end

function PriceHistory.Select(_, _, _) end

function PriceHistory.Init(_) end

return PriceHistory