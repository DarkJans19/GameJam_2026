extends Effect 
class_name CurationEffect

@export var curation_quantity: int

func effect(objetivo: Node):
	if objetivo.has_method("curate"):
		objetivo.curate(curation_quantity)
		print("Se aplico", effect_name, "Con curacion: ", curation_quantity)
