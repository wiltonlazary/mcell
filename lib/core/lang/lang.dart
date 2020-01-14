extension StringExtension on String {
  toInt() => int.parse(this);
}

extension ListExtension<T> on List<T> {
  T call(int index) => this[index];

  List<R> transform<R>(R transformer(T element)) {
    final result = List<R>();

    for (var i = 0; i < this.length; i++) {
      result.add(transformer(this[i]));
    }

    return result;
  }

  List<R> flatTransform<R>(List<R> transformer(T element)) {
    return this.expand(transformer);
  }

  List<R> transformIndexed<R>(R transformer(int index, T element)) {
    final result = List<R>();

    for (var i = 0; i < this.length; i++) {
      result.add(transformer(i, this[i]));
    }

    return result;
  }
}

extension MapExtension<K, V> on Map<K, V> {
  V call(K key) => this[key];

  List<R> transform<R>(R transformer(K key, V value)) {
    final result = List<R>();

    this.forEach((k, v) {
      result.add(transformer(k, v));
    });

    return result;
  }
}

// extension IteratorExtension<T> on Iterator<T> {
//   Stream<R> transform<R>(R transformer(T element)) async* {
//     while (this.moveNext()) {
//       yield transformer(this.current);
//     }
//   }

//   Stream<R> transformIndexed<R>(R transformer(int index, T element)) async* {
//     var index = 0;

//     while (this.moveNext()) {
//       yield transformer(index, this.current);
//       index += 1;
//     }
//   }
// }
