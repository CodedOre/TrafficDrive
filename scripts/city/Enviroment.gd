# Copyright 2019, Tapio Pyrhönen

# --- Enviroment script ---
# The main script for the Day/Night cycle

extends WorldEnvironment

# -- Properties --

# - Wind texture -
export (Texture) var wind_tex

# - External nodes -
export (NodePath) var sun
export (NodePath) var sky
export (NodePath) var water

# - Sky colors -
export (Color) var day_color_sun        = Color(1,          1,        1,        1)
export (Color) var day_color_sky        = Color(0.388235,   0.490196, 0.890196, 1)
export (Color) var day_color_horizon    = Color(0.817383,   0.883606, 0.96875,  1)
export (Color) var sunset_color_sun     = Color(1,          0.376471, 0,        1)
export (Color) var sunset_color_sky     = Color(0,          0.007843, 0.215686, 1)
export (Color) var sunset_color_horizon = Color(0.545098,   0.167647, 0.105882, 1)
export (Color) var night_color_sun      = Color(0.117647,   0.12549,  0.219608, 1)
export (Color) var night_color_sky      = Color(0.023529,   0.023529, 0.031373, 1)
export (Color) var night_color_horizon  = Color(0.047059,   0.054902, 0.164706, 1)
export (Color) var dawn_color_sun       = Color(1,          0.678431, 0,        1)
export (Color) var dawn_color_sky       = Color(0,0.082353, 0.215686,           1)
export (Color) var dawn_color_horizon   = Color(0.545098,   0.188235, 0.105882, 1)

# -- Variables --

# - Internal nodes -
var env : Environment

# - Wind settings -
var use_wind       : bool    = true
var wind_nodes     : Array   = Array()
var wind_dir       : Vector2 = Vector2(1.0, 0.0)
var wind_speed     : float   = 0.05
var wind_uv_offset : Vector2 = Vector2(0.0, 0.0)

# - Time settings -
var time_paused    : bool  = true
var time_of_day    : float = 48000.0 # 0 -> 86400
var day_phase      : float = 0.0     # -PI -> PI
var game_timescale : float = 2400.0   # 1.0 = realtime

# - Sky colors -
var sun_c = day_color_sun
var sky_c = day_color_sky
var hor_c = day_color_horizon
var fog_c = hor_c

# -- Functions --

# - Runs at startup -
func _ready():
	# Get nodes
	sun   = get_node(sun)
	sky   = get_node(sky)
	water = get_node(water)
	env   = get_environment()
	var vp : Viewport = get_viewport()
	
	# Setup wind nodes
	wind_nodes = get_tree().get_nodes_in_group("Wind")
	print(wind_nodes.size(), " nodes in Wind group")
	for n in wind_nodes:
		n.use_only_lod = !use_wind
		n.material_override.set_shader_param("texture_wind", wind_tex)
	
	randomize()
	environment.set_dof_blur_far_distance(64.0)
	#environment.set_dof_blur_far_transition(Globals.ground_size * 0.5)

# - Runs at every frame -
func _process(delta):
	wind_speed = lerp(wind_speed, 0.3, delta)
	
	# Run update functions
	upd_time_of_day(delta)
	upd_wind(delta)
	upd_sun()
	upd_fog()
	
	# Update sky
	var a = float(OS.get_ticks_msec()) / 4000.0
	a = (sin(a+day_phase) + (cos(a / 3.0))) / 2.0
	a *= abs(a)
	a /= 7.0
	sky.set_cloudiness(clamp(a + 0.5, 0.0, 1.0))

# - Updates the time -
func upd_time_of_day(delta):
	if (! time_paused):
		time_of_day += delta * game_timescale
	
	# Set the time
	day_phase = time_of_day / (86400.0 / (PI * 2.0))
	
	# Handle time overflow
	if(time_of_day > 86400.0):
		time_of_day -= 86400.0
	if(time_of_day < 0.0):
		time_of_day += 86400.0

# - Update the wind -
func upd_wind(delta):
	if(! use_wind):
		return
	
	# Set wind direction
	wind_dir.x = sin(0.00001 * OS.get_ticks_msec())
	wind_dir.y = cos(0.00001 * OS.get_ticks_msec())
	
	wind_dir = wind_dir.normalized()
	wind_uv_offset += wind_dir * wind_speed * delta
	
	# Update nodes
	for n in wind_nodes:
		n.material_override.set_shader_param("wind_uv_offset", wind_uv_offset)
		n.material_override.set_shader_param("wind_dir", wind_dir)
		n.material_override.set_shader_param("wind_speed", wind_speed)

# - Update the sun and sky -
func upd_sun():
	# Directional Light angle
	var pos = sun.get_global_transform().origin
	var a = day_phase + PI/3.0
	var celesial_pole = Vector3(0, 1, -1).normalized()
	var dir = Vector3(1, 0, 0)
	dir = dir.rotated(celesial_pole, -a)
	sun.look_at(pos + dir, Vector3(0,1,0))
	
	# Sky colors
	var p_day = clamp(-sin(a), 0.0, 1.0)
	var p_night = clamp(sin(a), 0.0, 1.0)
	var p_twilight = pow(1.0 - (p_day + p_night), 2.5)
	
	sun_c = night_color_sun.linear_interpolate(day_color_sun, p_day)
	sky_c = night_color_sky.linear_interpolate(day_color_sky, p_day)
	hor_c = night_color_horizon.linear_interpolate(day_color_horizon, p_day)
	
	if(time_of_day > 10500 && time_of_day < 54000):
		# Am
		sun_c = sun_c.linear_interpolate(dawn_color_sun, p_twilight)
		sky_c = sky_c.linear_interpolate(dawn_color_sky, p_twilight)
		hor_c = hor_c.linear_interpolate(dawn_color_horizon, p_twilight)
	else:
		# Pm
		sun_c = sun_c.linear_interpolate(sunset_color_sun, p_twilight)
		sky_c = sky_c.linear_interpolate(sunset_color_sky, p_twilight)
		hor_c = hor_c.linear_interpolate(sunset_color_horizon, p_twilight)
	
	var amb = (sky_c + hor_c) / 4.0
	amb = amb.linear_interpolate(Color(0.1, 0.1, 0.1), 0.2)
	environment.ambient_light_color = amb
	
	# Directional Light color
	var sin_a = -sin(a)
	var energy = clamp(sin_a * 1.5, 0.0, 1.0)
	if(energy > 0.0):
		sun.set_visible(true)
		sun.set_param(Light.PARAM_ENERGY, energy * 0.1)
		sun.set_color(hor_c)
	else:
		sun.set_visible(false)
	
	sky.material_override.set_shader_param("sun_color", sun_c)
	sky.material_override.set_shader_param("sky_color", sky_c)
	sky.material_override.set_shader_param("horizon_color", hor_c)
	sky.set_cloud_colors(sky_c.linear_interpolate(Color.black, 0.1), hor_c.linear_interpolate(Color.white, 0.1), hor_c)
	#water.set_water_colors(sky_c, (sky_c + hor_c) / 2.0, hor_c)

# - Update fog color -
func upd_fog():
	fog_c = sky_c.linear_interpolate(hor_c, 0.8)
	env.set_fog_color(fog_c)
	env.set_fog_sun_color(hor_c)
