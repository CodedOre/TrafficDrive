# Copyright 2019, Tapio Pyrhönen

# --- Sky script ---
# Responsible for the mesh displaying the Sky shader.

extends MeshInstance

# -- Properties -

# - Directional light for the sun -
export (NodePath) var sun

# -- Functions --

# - Runs at startup -
func _ready():
	sun = get_node(sun)

# - Runs at every frame -
func _process(delta):
	call_deferred("follow_camera")

# - Updates the mesh to cover the complete viewport -
func follow_camera():
	var cam : Camera = get_viewport().get_camera()
	transform = cam.global_transform
	translate(Vector3(0.0, 0.0, 8.0 - cam.far))
	scale = Vector3(cam.far * 4.0, cam.far * 3.0, 1.0)
	material_override.set_shader_param("camera_y", cam.global_transform.origin.y)
	material_override.set_shader_param("sun_dir", sun.global_transform.basis.z)

# - Sets the color of the clouds -
func set_cloud_colors(cloud_color, lining_color, horizon_color):
	material_override.set_shader_param("cloud_color", cloud_color)
	material_override.set_shader_param("lining_color", lining_color)
	material_override.set_shader_param("horizon_color", horizon_color)

# - Sets how much clouds there are -
func set_cloudiness(cloudiness):
	material_override.set_shader_param("cloudiness", cloudiness)
