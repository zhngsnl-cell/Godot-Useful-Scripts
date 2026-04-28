# GenericObjectPool.gd
#来自DeepSeek
class_name GenericObjectPool

extends RefCounted

var _scene: PackedScene
var _pool: Array[Node] = []
var _active_objects: Array[Node] = []
var _parent: Node
var _max_size: int

func _init(scene: PackedScene, parent: Node, initial_size: int = 5,
 max_size: int = 30)->void:
	_scene = scene
	_parent = parent
	_max_size = max_size
	_initialize_pool(initial_size)

func _initialize_pool(count: int)->void:
	for i in range(min(count, _max_size)):
		var obj:Node = _create_instance()
		_return_to_pool(obj)

func _create_instance() -> Node:
	var instance:Node = _scene.instantiate()
	_parent.add_child(instance)
	return instance

func _return_to_pool(obj: Node)->void:
	obj.visible = false
	obj.set_process(false)
	obj.set_physics_process(false)
	_pool.append(obj)

func get_instance() -> Node:
	var instance: Node#这是正确的吗？
	
	if _pool.size() > 0:
		instance = _pool.pop_back()
	else:
		instance = _create_instance()
	
	# 激活实例
	instance.visible = true
	instance.set_process(true)
	instance.set_physics_process(true)
	
	# 调用重置方法
	#if instance.has_method("reset"):
	#	instance.reset()
	
	_active_objects.append(instance)
	return instance

func return_instance(instance: Node)->void:
	if _pool.size() >= _max_size:
		instance.queue_free()
		_active_objects.erase(instance)
		return
	
	instance.visible = false
	instance.set_process(false)
	instance.set_physics_process(false)
	
	_pool.append(instance)
	_active_objects.erase(instance)

func return_all()->void:
	for obj:Node in _active_objects.duplicate():
		return_instance(obj)

func get_active_count() -> int:
	return _active_objects.size()

func get_pool_count() -> int:
	return _pool.size()
