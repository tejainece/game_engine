class Arg<T> {
  final T? value;

  Arg(this.value);
}

extension ObjectArgExt<T> on T {
  Arg<T> get asArg => Arg(this);
}
