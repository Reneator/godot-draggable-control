extends Control
class_name Draggable_Control


var drag_position
var last_position


export (float) var zoom_step_size = 0.1 #defines how finely granulated the zoom is. smaller number means finer zoom-levels
export (int) var max_zoom_steps = 10 # how far zoomed in
export (int) var min_zoom_steps = -6 # how far zoomed out
export (bool) var zoom_enabled = false #zoom makes tooltip-detection disfunctional, so deactivated for now!
export (bool) var reset_zoom_on_close = false
export (bool) var restrict_zoom = false
 # in inverse mode, this will restrict the viewport/parent to being smaller than the control
# in normal mode, this will restrict the control to being smaller than the control
# doesnt have an effect with restrict_mode "none"

export (String, "none","parent","viewport") var restrict_mode = "viewport"
export (bool) var only_drag_on_mouse_in_parent = false #restricts the drag functionality when the mouse is inside the parent node.
export(bool) var only_drag_on_is_focused = false #only lets you drag the control when its in focus. the "is_focused" will have to be set externally
export(bool) var inverse_restriction = false #if this is active, the viewport will instead be restricted to draggable (the restrictor will behave like a camera)

export (bool) var restrict_x = true
export (bool) var restrict_y = true


export (bool) var lock_x = false #control cant be moved sideways
export (bool) var lock_y = false #control cant be moved up and down

var zoom_step = 0

var is_dragging = false
var is_focused = false #used for "only_drag_on_is_focused"

func _process(delta):
	var visible_in_tree = is_visible_in_tree()	
	if not visible_in_tree and zoom_step != 0 and reset_zoom_on_close:
		reset_zoom()
	if not visible_in_tree:
		return
	
	match restrict_mode:
		"parent":
			var new_pos
			if inverse_restriction:
				new_pos = restrict_to_inverse(rect_position, get_parent())
			else:
				new_pos = restrict_to(rect_position, get_parent())
			if new_pos != null:
				rect_position = new_pos
		"viewport": 
			var new_pos 
			if inverse_restriction:
				new_pos = restrict_to_inverse(rect_global_position, get_viewport_rect())
			else:
				new_pos = restrict_to(rect_global_position, get_viewport_rect())
			if new_pos != null:
				rect_global_position = new_pos


func reset_zoom():
	rect_scale = Vector2(1,1)
	zoom_step = 0
	rect_position = Vector2.ZERO

func restrict_to(position: Vector2, restrictor): #restricts the control to inside the restrictor
	var restrictor_size
	if restrictor is Control:
		restrictor_size = restrictor.rect_size
	if restrictor is Viewport or restrictor is Rect2:
		restrictor_size = restrictor.size
	#limiting the map to its outer borders
	var current_size = rect_size * rect_scale
	var new_position = position
	if restrictor_size < current_size:
		return
	
	if restrict_x:
		if new_position.x < 0:
			new_position.x = 0
		if new_position.x + current_size.x > restrictor_size.x:
			new_position.x = restrictor_size.x - current_size.x
	
	if restrict_y:
		if new_position.y < 0:
			new_position.y = 0
		if new_position.y + current_size.y > restrictor_size.y:
			new_position.y = restrictor_size.y - current_size.y
	return new_position

func restrict_to_inverse(position: Vector2, restrictor): #restricts the viewport/element to inside the control (like a camera)
	var restrictor_size
	if restrictor is Control:
		restrictor_size = restrictor.rect_size
	if restrictor is Viewport or restrictor is Rect2:
		restrictor_size = restrictor.size
		#limiting the map to its outer borders
	var current_size = rect_size * rect_scale
	var new_position = position
	if restrictor_size > current_size:
		return
	
	if restrict_x:
		if new_position.x > 0:
			new_position.x = 0
		if new_position.x < -current_size.x + restrictor_size.x:
			new_position.x = -current_size.x + restrictor_size.x
	if restrict_y:
		if new_position.y > 0:
			new_position.y = 0
		if new_position.y < -current_size.y + restrictor_size.y:
			new_position.y = -current_size.y + restrictor_size.y
	return new_position
	
func is_mouse_in_parent():
	var parent_rect = get_parent().get_global_rect()
	return parent_rect.has_point(get_global_mouse_position())

func _input(event):
	var visible_in_tree = is_visible_in_tree()
	if not visible_in_tree:
		return

	if event.is_action_released("ui_touch"):
		is_dragging = false
		last_position = null
	elif not is_dragging and only_drag_on_mouse_in_parent and not is_mouse_in_parent():
		is_dragging = false
		last_position = false
		return
	

			
	if event.is_action_pressed("ui_touch"):
		is_dragging = true
	
	if only_drag_on_is_focused and not is_focused:
		return

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom(-1)
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom(+1)

	if event is InputEventMouseMotion and is_dragging:
		drag_position = get_global_mouse_position()
		if last_position:
			var difference = Vector2.ZERO
			if not lock_x:
				difference.x = drag_position.x - last_position.x
			if not lock_y:
				difference.y = drag_position.y - last_position.y
			rect_global_position += difference
		last_position = drag_position

func zoom(zoom_direction):
	if not zoom_enabled:
		return
	var restrictor_size
	match restrict_mode:
		"viewport": restrictor_size = get_viewport_rect().size
		"parent": restrictor_size = get_parent().rect_size
	
	
	var mouse_pos = get_global_mouse_position()
	var mouse_pos_in_control = mouse_pos - rect_global_position
	var scale_factor
	if zoom_direction > 0:
		#zoom out	
		scale_factor = 1 - zoom_step_size
		if zoom_step <= min_zoom_steps:
			return
		# if the control will get bigger than the restrictor with the next zoom in
		if restrict_zoom and inverse_restriction and restrictor_size:
			if (rect_size * rect_scale * scale_factor).x < restrictor_size.x:
				return
			if (rect_size * rect_scale * scale_factor).y < restrictor_size.y:
				return
				
		zoom_step -= 1
		
	else:
		#zoom in
		scale_factor= 1/ (1-zoom_step_size)
		if zoom_step >= max_zoom_steps:
			return
			
		if restrict_zoom and not inverse_restriction and restrictor_size:
			if (rect_size * rect_scale * scale_factor).x > restrictor_size.x:
				return
			if (rect_size * rect_scale * scale_factor).y > restrictor_size.y:
				return
		
		zoom_step += 1
	
	rect_scale *= scale_factor
	
	#zoom towards mouse
	var new_pos = -(mouse_pos_in_control * scale_factor - mouse_pos)
	rect_global_position = new_pos
