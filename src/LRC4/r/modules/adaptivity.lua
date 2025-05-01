local scale_adaptivity = {}

function scale_adaptivity:deploy(widget:DockWidgetPluginGui)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	
	local current = 0
	
	local function default()
		current = 0
		app.loader.main.Visible = true
		app.loader.view.Visible = true
		app.loader.main.Position = UDim2.new(0.442,0,0,0)
		app.loader.main.Size = UDim2.new(0.558,0,1,0)
		app.loader.view.Position = UDim2.new(0,0,0,0)
		app.loader.view.Size = UDim2.new(0.442,0,1,0)
	end

	local function narrow()
		current = 1
		app.loader.main.Visible = true
		app.loader.view.Visible = true
		app.loader.main.Position = UDim2.new(0,0,0.442,0)
		app.loader.main.Size = UDim2.new(1,0,0.558,0)
		app.loader.view.Position = UDim2.new(0,0,0,0)
		app.loader.view.Size = UDim2.new(1,0,0.442,0)
	end
	
	local function mini()
		current = 2
		app.loader.main.Visible = true
		app.loader.view.Visible = false
		app.loader.main.Position = UDim2.new(0,0,0,0)
		app.loader.main.Size = UDim2.new(1,0,1,0)
	end
	
	app:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local size = app.AbsoluteSize
		local ratio = size.X / size.Y
		
		if size.X < 400 and current == 0 or (current == 2 or current == 1) and size.X < 280 then
			app.loader.main.content.top_buttons.expand.Visible = true
			app.loader.main.content.top_buttons.inspect.Visible = false
			app.loader.main.content.top_buttons.animations.Visible = false
			app.loader.main.content.top_buttons.outfits.Visible = false
		else
			app.loader.main.content.top_buttons.expand.Visible = false
			app.loader.main.content.top_buttons.inspect.Visible = true
			app.loader.main.content.top_buttons.animations.Visible = true
			app.loader.main.content.top_buttons.outfits.Visible = true
		end
		
		if (size.X < 350 or (size.Y < 400 and size.X < 400)) and size.Y < 500 then
			app.loader.view.contain_view.viewport_padding.viewutil.Visible = false
			app.loader.view.contain_view.viewport_padding.util.Visible = false
			app.loader.view.contain_view.viewport_padding.util2.Visible = false
			app.loader.view.contain_view.viewport_padding.expand.Visible = true
		else
			app.loader.view.contain_view.viewport_padding.viewutil.Visible = true
			app.loader.view.contain_view.viewport_padding.util.Visible = true
			app.loader.view.contain_view.viewport_padding.util2.Visible = true
			app.loader.view.contain_view.viewport_padding.expand.Visible = false
		end
		
		if size.X < 430 and current == 0 or size.X <= 240 and (current == 1 or current == 2) then
			app.loader.main.content.options.option__auto_update.title.txt.__tooltip.Visible = false
			app.loader.main.content.options.option__inspectable.title.txt.__tooltip.Visible = false
			app.loader.main.content.options.option__remove_packages.title.txt.__tooltip.Visible = false
			--app.loader.main.content.options.option__default_scale.title.txt.__tooltip.Visible = false
		else
			app.loader.main.content.options.option__auto_update.title.txt.__tooltip.Visible = true
			app.loader.main.content.options.option__inspectable.title.txt.__tooltip.Visible = true
			if size.X > 532 and current == 0 or size.X < 340 and (current == 1 or current == 2) then
				app.loader.main.content.options.option__remove_packages.title.txt.__tooltip.Visible = true
			else
				app.loader.main.content.options.option__remove_packages.title.txt.__tooltip.Visible = false
			end
		end
		
		if size.X < 200 or size.Y < 200 then
			app.min_size_fallback_error.Visible = true
			app.nav.Visible = false
		else
			app.min_size_fallback_error.Visible = false
			app.nav.Visible = true
		end
		
		if size.X < 300 and size.Y < 300 then
			mini()
		else
			if ratio < 1.3 then
				-- narrow
				if current ~= 1 then narrow() end
				--elseif ratio < 0 then
				--	-- narrow
			else
				-- default
				if current ~= 0 then default() end
			end
		end
	end)
	
	script.__toggle_freeze_input.Event:Connect(function(state)
		if state then
			app.input_frozen.Visible = true
		else
			app.input_frozen.Visible = false
		end
	end)
end

return scale_adaptivity