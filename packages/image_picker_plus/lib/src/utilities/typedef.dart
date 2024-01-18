typedef CustomThreeAsyncValueSetter<A, B, C> = A Function(B value, C value2);
typedef CustomTwoAsyncValueSetter<A, B> = Future<A> Function(B value);
