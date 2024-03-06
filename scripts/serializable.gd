class_name Serializable extends Resource

func to_dictionary() -> Dictionary:
	var result: Dictionary = Dictionary()
	
	for property in get_property_list():
		var name: StringName = property["name"]
		var value = get(name)
		
		if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:
			result[name] = Serializable._to_dictionary_recursive(value)
	
	return result

static func _to_dictionary_recursive(p_obj: Variant) -> Variant:
	if p_obj is Array:
		return [p_obj.map(Serializable._to_dictionary_recursive), ""]
	elif p_obj is Dictionary:
		var result: Dictionary = Dictionary()
		
		for key in p_obj:
			result[key] = _to_dictionary_recursive(p_obj[key])
		
		return [result, ""]
	elif p_obj is Serializable:
		return [p_obj.to_dictionary(), p_obj.get_script().get_path()]
	elif p_obj is Variant:
		return [p_obj, ""]
	else:
		assert(false, "Unsupported serializable type \"%s\"" % type_string(typeof(p_obj)))
		return null

func from_dictionary(p_dict: Dictionary, p_whitelist: Array = []):
	for property in p_dict:
		if p_whitelist.is_empty() or p_whitelist.has(property):
			var value = Serializable._from_dictionary_recursive(p_dict[property])
			
			if value is Array: # Support for typed arrays
				var orig = get(property) as Array
				orig.clear()
				orig.assign(value)
			else:
				set(property, value)

static func _from_dictionary_recursive(p_obj: Array) -> Variant:
	var value: Variant = p_obj[0]
	
	if value is Array:
		var result: Array = Array()
		
		for element in value:
			if element is Array: # HACK if i make an array of arrays this is going to masterfully blow up
				result.push_back(_from_dictionary_recursive(element))
			else:
				result.push_back(element)
		
		return result
	elif value is Dictionary:
		if p_obj[1].is_empty():
			var result: Dictionary = Dictionary()
			
			for key in value:
				var val = value[key]
				
				if val is Array: # HACK same than up there
					result[key] = _from_dictionary_recursive(val)
				else:
					result[key] = val
			
			return result
		else:
			var result = (load(p_obj[1]) as Script).new()
			result.from_dictionary(value)
			return result
	elif value is Variant:
		return value
	else:
		assert(false, "Unsupported serializable type \"%s\"" % type_string(typeof(value)))
		return null
