class_name InventoryGrid
extends GridContainer

@export var slotSize: int = 32; 
@export var slotBorderWidth: int = 2; 

@export var width: int = 3; 
@export var height: int = 3; 

@export var slotData: Array[Node] = []; 

@export var slotPrefab: PackedScene; 

func _ready() -> void:
	setupInventory(); 
	createEmptySlotData(); 
		
# Setup inventory by filling the grid container with slots
func setupInventory(): 
	print("Setup inventory")

	self.columns = width; 
	for y in height:
		for x in width:
			var inventorySlot = slotPrefab.instantiate();
			print("Created inventory slot at " + str(x) + ", " + str(y));
			inventorySlot.rectSize = slotSize; 
			inventorySlot.borderWidth = slotBorderWidth; 
			
			add_child(inventorySlot);

func createEmptySlotData():
	print("Create slot data")
	var totalElements = width * height;  
	slotData = []; 
	slotData.resize(totalElements);
	slotData.fill(null);
	
func getIndexFromXY(x, y):
	pass; 
