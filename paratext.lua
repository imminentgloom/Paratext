--            PARATEXT
-- 
--     1st edition, 1st version
--      @imminent gloom 2024
-- 
--   mods: Nb, Fx, Fx_Postscript
--        font: 04B_03, 8p
--      screen: b/w, 128x64p
--
--
--
--
--
--
--
--
--
--
-- ---- ---- ----  ---- ---- ---- 

g = grid.connect()

include("lib/interface")

nb = include("nb/lib/nb")
lattice = require("lattice")

persist = true
k1_held = false
k2_held = false
k3_held = false
feedback_mod = ""
send_mod = ""

function init()
	params:add_separator("paratext: sequencers")
	params:add_option("sequencer", "sequencer",{"keys", "drums"}, 1)
	params:set_action("sequencer", function(x) sequencer = params:string("sequencer") end)
	params:add_option("crow", "crow", {"off", "keys: cv/gate 1+2", "drum: gates 1-4"}, 1)


	params:add_separator("paratext: voices")
	
	nb.voice_count = 5
	nb:init()
	nb:add_param("voice_keys", "keys")
	nb:add_param("voice_drum_1", "drums - track 1")
	nb:add_param("voice_drum_2", "drums - track 2")
	nb:add_param("voice_drum_3", "drums - track 3")
	nb:add_param("voice_drum_4", "drums - track 4")
	nb:add_player_params()


	clock.run(grid_redraw_clock)
	

	my_lattice = lattice:new{
        auto = true,
        ppqn = 480,
		enabled = true
    }
	
	track_keys = my_lattice:new_sprocket{
        action = function(t) end,
        division = 1,
        enabled = true
    }
	
	track_drum_1 = my_lattice:new_sprocket{
        action = function(x) end,
        division = 1,
        enabled = true
    }
	
	track_drum_2 = my_lattice:new_sprocket{
        action = function(x) end,
        division = 1,
        enabled = true
    }
    
    track_drum_3 = my_lattice:new_sprocket{
        action = function(x) end,
        division = 1,
        enabled = true
    }
    
    track_drum_3 = my_lattice:new_sprocket{
        action = function(x) end,
        division = 1,
        enabled = true
    }

	track_drum_4 = my_lattice:new_sprocket{
        action = function(x) end,
        division = 1,
        enabled = true
    }
	
	my_lattice:start()
	track_keys:start()
	track_drum_1:start()
	track_drum_2:start()
	track_drum_3:start()
	track_drum_4:start()

end


-- called by postscript after mod is loaded

function FxPostscript_init() 
    if persist == true then
  	    params:read("/home/we/dust/data/paratext/state.pset")
    else
        setup_fx_defaults()
    end
    
    params:set("fx_postscript_slot", 0) -- seems to need this for insert-mode to take
    params:set("fx_postscript_slot", 4) -- sets postscript as insert

	-- sets up voices choose numbers that works for your particular nb-voice stack
	params:set("voice_keys", 18)
	params:set("voice_drum_1", 2)
	params:set("voice_drum_2", 3)
	params:set("voice_drum_3", 4)
	params:set("voice_drum_4", 5)
	nb:add_player_params()

end

function setup_fx_defaults()

   params:set("fx_postscript_time", 0.55)
   params:set("fx_postscript_feedback", 80)
   params:set("fx_postscript_send", 20)
   params:set("fx_postscript_slot_drywet", 0.4)  
   params:set("fx_postscript_lp", 5000)
   params:set("fx_postscript_width", 0)
end

-- misc
function modulo(num, mod)
	-- % to index 1-based lists
	return ((num - 1) % mod) + 1
end


function redraw()
	screen.clear()
	draw_interface() -- lib/interface
	screen.update()
end

function grid_redraw_clock()
	while true do
		clock.sleep(1/30)
		if grid_dirty then
			grid_redraw()
			grid_dirty = false
		end
	end
end

function grid_redraw()
	g:all(0)
	if sequencer == "keys" then
	    grid_draw_keys()
	else
	    grid_draw_drums()
	end
	g:refresh()
end

function grid_draw_keys()
    
end

function grid_draw_drums()
    
end


-- hw interaction
	
function g.key(x, y, z)

    if sequencer == "keys" then
        grid_press_keys(x, y, z)
    else
        grid_press_drums(x, y, z)    
    end

--[[
local note = 24
    note = note + x
    note = note + 5 * (8 - y)
    local player = params:lookup_param("voice"):get_player()
    if z == 1 then
        player:note_on(note, 1)
    else
        player:note_off(note)
    end
]]--    

end

function grid_press_keys(x, y, z)
    
end

function grid_press_drums(x, y, z)
    
end


function key(n,z)
	if z == 1 then
		if n == 1 then k1_held = true end 
		if n == 2 then k2_held = true end
		if n == 3 then k3_held = true end
	else
		if n == 1 then k1_held = false end
		if n == 2 then k2_held = false end
		if n == 3 then k3_held = false end
	end
	
	if k1_held == false then
		if n == 2 then
			if z == 1 then
				prev_feedback = params:get("fx_postscript_feedback")
				params:set("fx_postscript_feedback", prev_feedback * 0.75)
				feedback_mod = "Active"	
			else
				params:set("fx_postscript_feedback", prev_feedback)
				feedback_mod = ""
			end
		end
		
		if n == 3 then
			if z == 1 then
				prev_send = params:get("fx_postscript_send")
				params:set("fx_postscript_send", 100)
				send_mod = "Active"
			else
				params:set("fx_postscript_send", prev_send)
				send_mod = ""
			end
		end

	elseif k1_held == true then
		if n == 2 then
			if z == 1 then
								
			end
		end
		
		if n == 3 then
			if z == 1 then
				local val = params:get("sequencer")
				val = modulo(val + 1, 2)
				params:set("sequencer", val)
			end				
		end
	end

	redraw()
end


function enc(n,d)
	if k1_held then
		if n == 1 then 
			params:delta("fx_postscript_slot_drywet",d)
		elseif n == 2 then
			params:delta("fx_postscript_lp",d)
		elseif n == 3 then
			params:delta("fx_postscript_width",d)
		end

	else
		if n == 1 then 
			params:delta("fx_postscript_time",d)
		elseif n == 2 then
			params:delta("fx_postscript_feedback",d)
		elseif n == 3 then
			params:delta("fx_postscript_send",d)
		end
	end

	redraw()
end

-- Sequencers: Common

function cleanup()
	if persist == true then
  	    params:write("/home/we/dust/data/paratext/state.pset")
    end
end