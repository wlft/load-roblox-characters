local notifs = {}

type banner_type_def = "default"|"warning"|"error"

local r = script.Parent.Parent
local gateway = r.connect.plugin_gateway

local cconn

function notifs:banner(widget:DockWidgetPluginGui, txt:string?, banner_type:banner_type_def?, auto_clear:number?, click_id:string?)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	if not banner_type or type(banner_type) ~= "string" then banner_type = "default" end
	
	if cconn then cconn:Disconnect()end
	
	app.banner_notif.m.txt.Text = txt or "An error occured and this banner was displayed with no text provided."
	if banner_type == "default" then
		app.banner_notif.m.BackgroundColor3 = Color3.new(1,1,1)
		app.banner_notif.m.txt.TextColor3 = Color3.new(0,0,0)
	elseif banner_type == "warning" then
		app.banner_notif.m.BackgroundColor3 = Color3.new(1, 0.6, 0.08)
		app.banner_notif.m.txt.TextColor3 = Color3.new(1,1,1)
	elseif banner_type == "error" then
		app.banner_notif.m.BackgroundColor3 = Color3.new(1,0,0)
		app.banner_notif.m.txt.TextColor3 = Color3.new(1,1,1)
	end
	app.banner_notif.m:TweenPosition(UDim2.new(0,0,0,0),"Out","Quad",0.3,true)
	app.banner_notif:SetAttribute("auto_clear", auto_clear)
	
	if click_id then
		app.banner_notif.m.c.click.Visible = true
		
		cconn = app.banner_notif.m.c.click.MouseButton1Click:Connect(function()
			local res = gateway:Invoke('post', 'cclick', {id = click_id})
		end) 
	else
		app.banner_notif.m.c.click.Visible = true
	end
	
	if auto_clear ~= 0 then
		task.wait(auto_clear or 3)
		app.banner_notif.m:TweenPosition(UDim2.new(0,0,-1,0),"Out","Quad",0.3,true)
		
		if cconn then cconn:Disconnect()end
	end
end

return notifs