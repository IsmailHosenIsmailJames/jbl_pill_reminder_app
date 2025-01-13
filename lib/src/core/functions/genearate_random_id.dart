import 'dart:math';

String getRandomGeneratedID() {
  return (Random().nextInt(100000000) + 100000000).toString();
}
