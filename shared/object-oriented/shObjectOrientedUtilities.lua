function is_class_instance(instance, class)
    return type(instance) == "table" and instance.is_a and instance.is_a[class]
end