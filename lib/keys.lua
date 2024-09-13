-- sequencer/keyboard based on earthsea for Paratext

tab = require ("tabutil")
pattern_time = require ("pattern_time")

local grid_held = {}
local playing_notes = {}
local playing_xy = {}
local transpose = 0
local note
local arm = false
local loop = false
local arp = false

function keys_init()
	p = pattern_time.new()
	p.process = p_execute
end

function p_record(x, y, z, note)	
	local rec = {}
	rec.index = p.count + 1
	rec.x = x
	rec.y = y
	rec.state = z
	rec.note = note
	p:watch(rec)
end

function stop_keys()
	for n = 1, #playing_notes do
		play_note(playing_notes[n], 0)
	end
	for n = 1, #playing_xy do
		g:led(playing_xy[n][1], playing_xy[n][2], 0)
	end
	playing_notes = {}
	playing_xy = {}
	grid_dirty = true
end

function keys_panic()
	player = params:lookup_param("voice_keys"):get_player()
	player:stop_all()
end

function add_playing()
	for n = 1, #playing_notes do
		play_note(n, 1)
	end
end

function p_execute(r)
	xy_to_note(r.x, r.y)
	play_note(note, r.state)
	
	if r.state == 1 then
		table.insert(playing_xy, {r.x, r.y})
	else
		for i, v in pairs(playing_xy) do
			if v[1] == r.x and v[2] == r.y then table.remove(playing_xy, i) end
		end
	end


	grid_dirty = true
	
	--[[
	if loop == false then
		if r.index == p.count then
			p:stop()
			stop_keys()
		end
	end
	]]--
end



function xy_to_note(x, y)
    note = 24 + transpose
    note = note + x
	note = note + 5 * (8 - y)
	return note
end

function play_note(note, z)
    player = params:lookup_param("voice_keys"):get_player()
	if z == 1 then 
		player:note_on(note, 1)
		table.insert(playing_notes, note)
	else
		player:note_off(note)	  
		for i, v in pairs(playing_notes) do
			if v == note then table.remove(playing_notes, i) end
		end
	end
end

-- grid interaction

function grid_press_keys(x, y, z)

	--play notes when keys except 1,1 are pressed
	if x == 1 and y == 1 then

	else
        xy_to_note(x, y)
        play_note(note, z)
		p_record(x, y, z, note)
    end

	-- collect pressed keys
	if z == 1 then
		table.insert(grid_held, {x, y})
	else
		for i, v in pairs(grid_held) do
			if v[1] == x and v[2] == y then table.remove(grid_held, i) end
		end
	end
	
	-- record, play, stop and erase pattern
	if x == 1 and y == 1 then

		function hold() -- wait "time" milliseconds to see if key is held				
			clock.sleep(0.5)
			p:rec_stop()
			p:stop()
			stop_keys()
			p:clear()
			p_cleared = true
			grid_dirty = true
		end

		if z == 1 then
			hold_timer = clock.run(hold) -- start hold timer
			if p.count == 0 and p.rec == 0 then  -- empty; start rec
				p:rec_start()
				add_playing()
			elseif p.count == 0 and p.rec == 1 then -- empty, recording; stop rec
				p:rec_stop()
			elseif p.rec == 1 then -- recording; stop rec, play
				p:rec_stop()
				p:start()
			elseif p.play == 1 then -- playing; stop
				p:stop()
				stop_keys()
			elseif p.play == 0 then -- stopped; play
				p:start()
			end
		else
			clock.cancel(hold_timer)
		end

	end

	-- arm recording
	if x == 1 and y == 3 and z == 1 then
		if arm == true then 
			arm = false
		else
			arm = true
		end
	end

	-- loop playback
	if x == 1 and y == 4 and z == 1 then
		if loop == true then 
			loop = false
		else
			loop = true
		end
	end

	grid_dirty = true
end

-- grid interface

function grid_draw_scale()

end

function grid_draw_keys()
    grid_draw_scale()

	-- light up held keys
	for n = 1, #grid_held do
		g:led(grid_held[n][1], grid_held[n][2], 15)
	end

	-- light up held keys
	for n = 1, #playing_xy do
		g:led(playing_xy[n][1], playing_xy[n][2], 10)
	end
	

	-- record button
	if p.rec == 1 then
		g:led(1, 1, 15)
	elseif p.play == 1 then
		g:led(1, 1, 10)
	elseif p_cleared then
		g:led(1, 1, 0)
	else
		g:led(1, 1, 0)
	end
	
	-- arm, button
	--if arm == true then g:led(1, 3, 15) else g:led(1, 3, 0) end

	-- loop button
	--if loop == true then g:led(1, 4, 15) else g:led(1, 4, 0) end

	
end