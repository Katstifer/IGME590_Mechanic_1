class_name InventorySlot
extends CenterContainer

const GlobalEnums = preload("res://scripts/globalEnums.gd");

@export var mainRect: Control;
@export var innerRect: Control;


var rectSize: int;
var borderWidth: int;

var currentState: GlobalEnums.SlotState;
var mouseHovering = false; 

var containedItem: Node = null; 

signal mouseEnteredSlot(slot: InventorySlot)
signal mouseExitedSlot(slot: InventorySlot)

signal attemptItemPickup(slot: InventorySlot)

func _ready() -> void:	
	if mainRect == null: 
		mainRect = $inventorySlot_Rect;
	setSize(rectSize, borderWidth);
	currentState = GlobalEnums.SlotState.DEFAULT; 
	updateSlotColor(GlobalEnums.SlotState.DEFAULT);

func _process(delta: float) -> void:
	# If the mouse is hovering over the slot, send out the
	# mouse is on the slot signal 
	if (get_global_rect().has_point((get_global_mouse_position()))):
		if mouseHovering == false: 
			mouseHovering = true; 
			emit_signal("mouseEnteredSlot", self)
			
	# Once the mouse leaves, fire the exit signal
	else : 
		if mouseHovering == true: 
			mouseHovering = false; 
			emit_signal("mouseExitedSlot", self)
		
	
func setSize(size, borderWidth):
	custom_minimum_size = Vector2(size, size);
	mainRect.custom_minimum_size = Vector2(size, size);
	
	if (innerRect != null):
		var innerRectSize = size - (2 * borderWidth); 
		innerRect.custom_minimum_size = Vector2(innerRectSize, innerRectSize);
		
		innerRect.offset_left = borderWidth
		innerRect.offset_top = borderWidth
		innerRect.offset_right = -borderWidth
		innerRect.offset_bottom = -borderWidth

func updateSlotColor(state: GlobalEnums.SlotState): 
	match state: 
		GlobalEnums.SlotState.DEFAULT: 
			mainRect.modulate = Color.WHITE;
		GlobalEnums.SlotState.EMPTY: 
			mainRect.modulate = Color(Color.GREEN, 0.2);
		GlobalEnums.SlotState.TAKEN: 
			mainRect.modulate = Color(Color.RED, 0.2);
		GlobalEnums.SlotState.HOVERED: 
			mainRect.modulate = Color(Color.YELLOW, 0.8);
		
func addItem(item: InventoryItem):
	containedItem = item; 
	
func removeItem():
	containedItem = null; 
