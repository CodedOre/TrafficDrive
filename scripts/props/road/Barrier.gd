# Copyright 2021, Frederick Schenk

# --- Barrier Script ---
# A script to allow the barrier to fall apart.

extends Spatial

# -- Variables --

# - Internal joints -
onready var left_joint  : Generic6DOFJoint = $LeftToBeamJoint
onready var right_joint : Generic6DOFJoint = $RightToBeamJoint

# -- Functions --

# - Break the barrier apart -
func break_barrier(_body : PhysicsBody):
	if _body != null:
		# Detach left leg
		left_joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_LINEAR_LIMIT,  false)
		left_joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
		left_joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_LINEAR_LIMIT,  false)
		left_joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
		left_joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_LINEAR_LIMIT,  false)
		left_joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
		# Detach right leg
		right_joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_LINEAR_LIMIT,  false)
		right_joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
		right_joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_LINEAR_LIMIT,  false)
		right_joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
		right_joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_LINEAR_LIMIT,  false)
		right_joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
