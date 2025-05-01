--!nolint
--!nocheck

local ts = game:GetService("TweenService")


return function(widget:DockWidgetPluginGui)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	local frames = {app.home,app.loader,app.settings}
	
	local function switch(f:Frame)
		if app:GetAttribute('nav_locked') then return end
		if table.find(frames,f) then
			if f.Visible == true then
				if f == app.home then
					app.home.content.CanvasPosition = Vector2.new(0,0)
				elseif f == app.settings then
					app.settings.content.CanvasPosition = Vector2.new(0,0)
				elseif f == app.loader then
					app.loader.main.content.Visible = true
					app.loader.main.insert_options.Visible = true
					app.loader.main.outfits.Visible = false
					app.loader.main.animations.Visible = false
					app.loader.main.inspect.Visible = false
				end
			end
			
			for _, v in pairs(frames) do
				if v ~= f then
					v.Visible = false
				end
			end
			f.Visible = true
			app.nav[f.Name].icon.ImageTransparency = 0
			for _, v in pairs(app.nav:GetChildren()) do
				if v.Name ~= f.Name and v:IsA("Frame") then
					ts:Create(v.icon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {ImageTransparency = 0.3}):Play()
				end
			end
			--app.inview.Value = f
		end
		
		if app.banner_notif:GetAttribute("auto_clear") == 0 then
			app.banner_notif.m:TweenPosition(UDim2.new(0,0,-1,0),"Out","Quad",0.3,true)
		end
	end
	
	script.__swtich.Event:Connect(function(to)
		switch(to)
	end)
	
	app.nav.home.hitbox.MouseButton1Click:Connect(function()
		switch(app.home)
	end)
	
	app.nav.loader.hitbox.MouseButton1Click:Connect(function()
		switch(app.loader)
	end)
	
	app.nav.settings.hitbox.MouseButton1Click:Connect(function()
		switch(app.settings)
	end)
	
	for _, v in pairs(app.nav:GetChildren()) do
		if v:IsA("Frame") and v:FindFirstChild("hitbox") and v:FindFirstChild("icon") then
			v.icon.ImageTransparency = 0.3
			
			v.hitbox.MouseEnter:Connect(function()
				ts:Create(v.icon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {ImageTransparency = 0.1}):Play()
			end)
			
			v.hitbox.MouseLeave:Connect(function()
				if not app[v.Name].Visible then
					ts:Create(v.icon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {ImageTransparency = 0.3}):Play()
				else
					ts:Create(v.icon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {ImageTransparency = 0}):Play()
				end
			end)
		end
	end
end