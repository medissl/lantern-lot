extends RefCounted

static func rounded(numerator: int, denominator: int = 10000) -> int:
	return int((numerator + denominator / 2) / denominator)

static func reference_value(item: Dictionary) -> int:
	return rounded(int(item.base) * int(item.condition))

static func fee(gross: int, fee_bp: int) -> int:
	return rounded(gross * fee_bp)

static func allocate(items: Array, bid: int) -> void:
	var total: int = 0
	for item in items:
		total += reference_value(item)
	var assigned: int = 0
	var remainders: Array = []
	for item in items:
		var numerator: int = bid * reference_value(item)
		item.cost = int(numerator / total)
		assigned += int(item.cost)
		remainders.append({"item": item, "remainder": numerator % total})
	remainders.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.remainder == b.remainder:
			return str(a.item.uid) < str(b.item.uid)
		return a.remainder > b.remainder)
	for index in range(bid - assigned):
		remainders[index].item.cost += 1
