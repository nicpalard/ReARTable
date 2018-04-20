
# Live loop: Beat01 -> simple beat
set :playbeat01, 0
set :beat01_amp, 0
set :beat01_speed, 1

beat01_started = false

live_loop :beat01_update do
  nv = sync "/osc/beat01/update"
  set :beat01_speed, nv[0]
  set :beat01_amp, nv[1]
  puts(get (:beat01_amp))
end

live_loop :beat01_start do
  nv = sync "/osc/beat01/start" unless beat01_started
  beat01_started = true if !beat01_started
  set :playbeat01, 1
  puts "Start beat01"
  sleep 0.5
end

live_loop :beat01_stop do
  nv = sync "/osc/beat01/stop"
  beat01_started = false if beat01_started
  set :playbeat01, 0
  puts "Stop beat01"
  sleep 0.5
end

live_loop :beat01 do
  sample :drum_bass_hard , amp: get(:beat01_amp) if get(:playbeat01) == 1
  sleep 1 / (get (:beat01_speed))
end

# Live loop: Beat02 -> classic drum beat
set :playbeat02, 0
beat02_started = false

live_loop :startbeat02 do
  nv = sync "/osc/beat02/start" unless beat02_started
  beat02_started = true if !beat02_started
  set :playbeat02, 1
  puts "Start beat02"
  sleep 0.5
end

live_loop :stopbeat02 do
  nv = sync "/osc/beat02/stop"
  beat02_started = false if beat02_started
  set :playbeat02, 0
  puts "Stop beat02"
  sleep 0.5
end

live_loop :beat02 do
  sample :loop_amen, beat_stretch: 2 if get(:playbeat02) == 1
  sleep 2
end