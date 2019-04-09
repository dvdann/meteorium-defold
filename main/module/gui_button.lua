-- define btn_type
local SPRITE_TYPE = "sprite"
local SCALE_TYPE = "scale"
local SCALE2_TYPE = "scale2"

local M = {}

-- create a button handler
-- @param node The node representing the button
-- @param callback Function to call when button is clicked
-- @param btn_type Scale-based or Sprite-based*
-- @param released_animation*
-- @param pressed_animation*
-- @return Button instance
function M.create(node, callback, btn_type, released_animation, pressed_animation)
	--local SOUND_CLICK = "loader:/go_audio#click" -- default sound effect
	local button = {
		pressed = false
	}

	-- make sure it's in the released when btn_type:sprite
	if btn_type == SPRITE_TYPE then
		gui.play_flipbook(node, released_animation)
	end

	-- define the input handler function
	function button.on_input(action_id, action)
		-- mouse/finger over the button?
		local over = gui.pick_node(node, action.x, action.y)
		-- over button and mouse/finger pressed and enable?
		if over and action.pressed and button.enable() then
			button.pressed = true
			button.anim(button, btn_type)
			-- uncoment following line if you want to add sound
			-- must be located on main collection "sound" game object and "click" sound controller
			--msg.post("loader:/go_audio#click", "play_sound") -- alternative way
			--[[if #SOUND_CLICK > 0 then
				sound.play(SOUND_CLICK)
			end]]
			return true -- to check there is in this-button
		-- mouse/finger released and button pressed?
		elseif action.released and button.pressed then
			button.pressed = false
			button.anim(button, btn_type)
			if over then
				callback(button)
			end
		end
	end

	-- set animation based on btn_type
	function button.anim(button, btn_type)
		local PRESSED_BUTTON_SCALE = vmath.vector3(1.15)
		local NORMAL_BUTTON_SCALE = vmath.vector3(1)
		local ANIMATION_TIME = 0.2
		local type
		if not btn_type then
			type = SCALE_TYPE
			--print "auto assign: scale btn-type"
		elseif btn_type == SCALE2_TYPE then
			type = SCALE2_TYPE
			PRESSED_BUTTON_SCALE = vmath.vector3(0.9)
		else
			type = btn_type
		end
		if button.pressed then
			if type == SPRITE_TYPE then
				gui.play_flipbook(node, pressed_animation)
			else
				gui.animate(node, "scale", PRESSED_BUTTON_SCALE, gui.EASING_OUTBACK, ANIMATION_TIME)
			end
		else
			if type == SPRITE_TYPE then
				gui.play_flipbook(node, released_animation)
			else
				gui.animate(node, "scale", NORMAL_BUTTON_SCALE, gui.EASING_OUTBACK, ANIMATION_TIME)
				if type ~= SCALE_TYPE and type ~= SCALE2_TYPE then -- debug purpose
					print "undefined button type"
				end
			end
		end
	end

	-- get node button position
	function button.pos(position)
		if not position then
			return gui.get_position(node)
		else
			gui.set_position(node, position)
		end
	end

	function button.set_sound(url)
		SOUND_CLICK = url
	end

	-- set enable/disable button
	function button.enable(val)
		if val then
			gui.set_enabled(node, true)
		elseif val == false then
			gui.set_enabled(node, false)
		end
		return gui.is_enabled(node)
	end

	return button
end

return M
