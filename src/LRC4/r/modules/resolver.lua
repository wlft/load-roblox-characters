--!nolint
--!nocheck

local notifs = require(script.Parent.notifs)

local resolver = {}

local us = game:GetService('UserService')

function resolver:init(widget:DockWidgetPluginGui)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	
	local db = false
	
	app.crash_resolver.modal.info.retry.c.hitbox.MouseButton1Click:Connect(function()
		if db then return end
		db = true
		
		app.crash_resolver.modal.info.retry.spinner.Visible = true
		
		local s, err = pcall(function()
			us:GetUserInfosByUserIdsAsync({1})
		end)
		
		app.crash_resolver.modal.info.retry.spinner.Visible = false
		
		if s then
			task.wait()
			app.crash_resolver.Visible = false
			print('r')
			script.Parent.home.__reset:Fire()
			app.home.Visible = true
			app:SetAttribute('nav_locked', nil)
			app.nav.Visible = true
		else
			notifs:banner(widget, 'Failed to connect', 'error', 2)
		end
		
		db = false
	end)
end

function resolver:network_error(widget:DockWidgetPluginGui)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	
	app:SetAttribute('nav_locked', true)
	app.crash_resolver.modal.info.icon.Image = 'rbxassetid://8445470392'
	app.crash_resolver.modal.info.icon.ImageRectOffset = Vector2.new(704,904)
	app.crash_resolver.modal.info.icon.ImageRectSize = Vector2.new(96,96)
	app.crash_resolver.modal.info.subtext.Text = 'Could not connect to Roblox,'
	app.crash_resolver.modal.info.text.Text = 'check your connection and try again.'
	app.crash_resolver.modal.info.retry.Size = UDim2.new(0,1,0,40)
	app.crash_resolver.Visible = true
	app.home.Visible = false
	app.loader.Visible = false
	app.settings.Visible = false
	app.nav.Visible = false
end

return resolver