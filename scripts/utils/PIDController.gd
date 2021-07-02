# Copyright 2019, Yog-Shoggoth
# Copyright 2021, Frederick Schenk

# --- PIDController Script ---
# A script to provide an output for reaching a goal

extends Node
class_name PIDController

# -- Variables --

# - PID parameters -
var gain_P        : float = 0.0
var gain_I        : float = 0.0
var gain_D        : float = 0.0
var error_sum_max : float = 20.0

# - Error variables -
var error_old     : float = 0.0
var error_old_2   : float = 0.0
var error_sum     : float = 0.0 

# -- Methods --

# - Calls the PID controller -
func get_pid_output(gains : Vector3, error : float) -> float:
	# Gains are supplied as a Vector3 and error as a float representing the difference between the desired and 
	# current values of whatever is being measured e.g. rotational angle or speed etc.
	gain_P = gains.x
	gain_I = gains.y
	gain_D = gains.z
	
	var output : float = _calculate(error)

	return output

# - The functionality of the PID -
func _calculate(error: float) -> float:

	#The output from the PID
	var output: float = 0.0

	#P
	output += gain_P * error

	#I
	error_sum += get_physics_process_delta_time() * error

	#Clamp the error_sum
	error_sum = clamp(error_sum, -error_sum_max, error_sum_max)

	output += gain_I * error_sum;

	#D
	var d_dt_error : float = 0
	if get_physics_process_delta_time() != 0:
		d_dt_error = (error - error_old) / get_physics_process_delta_time()

	#Save the last two errors
	error_old_2 = error_old

	error_old = error

	output += gain_D * d_dt_error

	return output
