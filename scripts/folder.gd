class_name Folder

extends Control

@export var documents : Array[DocumentController] = []

func add(doc: DocumentController) -> void:
	documents.append(doc)

func remove(doc: DocumentController) -> void:
	var index = documents.find(doc)
	documents.remove_at(index)
