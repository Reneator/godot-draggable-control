# godot-draggable-control
Behaviour script for dragging a control via touch. With many settings.

Done in v3.2.2.beta2.official. Should work with older version as well.

There are 2 example-scenes that work and should enable you to quickly understand the way to setup the Script.

One disadvantage of this script is, that it works via scaling, and this could make some workarounds for certain situations necessary. For me this was, when i wanted to check if a Button on the Draggable_Control is inside the viewport (on my map). Then i had to use the rect_scale or global_scale in the calculations directly, as the rect_size/size returns the "true" size of the Node, without the scaling applied.

## How to/Setup

Add a new Input action to your project settings: "ui_touch" with All devices and left mouse-button

Simply add the Draggable_Control.gd script onto any kind of Control-Node (the script is made for UI) and you can already go and use it.



## Settings explained


- **Zoom Step Size:** this is the factor that the scale will be reduced/increased with each zoom in/out. so 0.1 will result in 0.9 zoom out factor and 1/ 0.9 zoom out. The zoom is constructed, so it will be consistent on zoom in and out and will always get back to default when zooming. For a smoother zooming experience, you will have to make this float smaller, as to have finer steps.

- **Max Zoom In:** The amount of zoom-steps that can be applied when zooming in. (Zoom-Depth). will be limited if this number is big enough and restrict zoom is active.

- **Min Zoom In:** The amount of zoom-steps that can be applied when zooming out. Will be artificially limited if restrict zoom is active

- **Zoom Enabled:** Enables zoom. If deactivated it wont react to the mouse-scrolling input.

- **Restrict Zoom:** Will restrict the zoom in/out depending on the "restrict mode" and "inverse restriction". if "restrict mode": "none" restrict zoom does nothing, "viewport": it restricts the zoom to the viewport, "parent": it restricts the zoom to the parent. If "inverse restriction" is false, it will limit the zoom, so that the control will be smaller than the viewport/parent. If "inverse restriction" is true, it will limit the zoom, so that the viewport/parent will be sameller than the control.

- **Restrict Mode**: This restrict mode setting will be used by "restrict zoom" and it can limit the drag-movement of the control inside the viewport/parent. Also depending on "inverse restriction". If "viewport" the control will be restricted to inside the viewport. If "parent" the control will be limited to inside the parent UI Element (must also be a Control-Node). This restriction will be ignored, if the control gets bigger than the parent/viewport by zooming in. "restrict zoom" will prevent that from happening. If "inverse restriction" is true, the control will be instead restricted in a way, that the viewport/control is restricted to inside the Control (Like a map-screen). This restriction will be ignored, when you zoom out too far, so that the control is smaller than the viewport. Here it makes sense to use "restrict zoom" to ensure consistent behaviour.

- **Inverse Restriction**: Is mainly used by other settings to change the behaviour. Does nothing on its own.

- **Restrict X/Restrict Y**: This setting is mainly used, if you want special behaviour where the restriction wont happen for a specific axis. If Restrict X is false the restriction for the X-Axis will be ignored. If Restrict Y is false, the restriction for the Y-Axis will be ignored. Depending on the other restriction settings.

- **Lock X/Lock Y**: Used to lock a specific axis of drag-movement. If Lock X is true, the control cannot be moved on the X-Axis anymore. If Lock Y the control cannot be moved on the Y-Axis anymore. This setting can be used if you want specific scroll behaviour, like a scrollable Tree, without havivng to use the other restriction-settings, or just want to hav e the player scroll up and down (or side to side like the TOTW: W2 Reseraccht trees) and only restrict on the side, without wobbling around inside (because the control is not big enough to fill it on the locked axis)

- **Active**: If false, the entire drag-functionality will be deactivated. This can be used to for example deactivate the drag functionality by script if you would want to do cutscenes/take away player control.
