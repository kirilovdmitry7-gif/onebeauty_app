typedef DevBoolGetter = bool? Function();
typedef DevBoolSetter = Future<void> Function(bool?);

class DevFeature {
  final String key; // уникальный ключ (например, 'advice.useApi')
  final String group; // группа в UI (например, 'Advice', "Today’s tasks")
  final String title; // заголовок тумблера
  final String Function()? subtitle; // опционально: подпись (можно из конфига)
  final DevBoolGetter
      getOverride; // читает текущее override-значение (null/true/false)
  final DevBoolSetter
      setOverride; // сохраняет override (или null = снять override)
  final int order; // порядок внутри группы

  DevFeature({
    required this.key,
    required this.group,
    required this.title,
    required this.getOverride,
    required this.setOverride,
    this.subtitle,
    this.order = 0,
  });
}

class DevFeatureRegistry {
  static final List<DevFeature> _items = [];

  static void register(DevFeature f) {
    // не добавляем дубликаты
    if (_items.indexWhere((x) => x.key == f.key) == -1) {
      _items.add(f);
    }
  }

  static List<DevFeature> all() => List.unmodifiable(_items);

  static Map<String, List<DevFeature>> grouped() {
    final map = <String, List<DevFeature>>{};
    for (final f in _items) {
      map.putIfAbsent(f.group, () => []).add(f);
    }
    for (final v in map.values) {
      v.sort((a, b) => a.order.compareTo(b.order));
    }
    return map;
  }
}
