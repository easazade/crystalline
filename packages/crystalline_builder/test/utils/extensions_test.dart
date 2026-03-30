import 'package:crystalline_builder/src/utils/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('StringX.removeSuffix', () {
    test('removes exact suffix at end', () {
      expect('HelloWorld'.removeSuffix('World'), 'Hello');
    });

    test('removes suffix case-insensitively', () {
      expect('HelloWORLD'.removeSuffix('world'), 'Hello');
      expect('MyController'.removeSuffix('CONTROLLER'), 'My');
      expect('fooBAR'.removeSuffix('bar'), 'foo');
    });

    test('does not remove when suffix is only in the middle or at start', () {
      expect('WorldHello'.removeSuffix('World'), 'WorldHello');
      expect('HelloWorldHello'.removeSuffix('World'), 'HelloWorldHello');
    });

    test('empty suffix leaves string unchanged', () {
      expect('abc'.removeSuffix(''), 'abc');
    });

    test('suffix longer than value leaves string unchanged', () {
      expect('ab'.removeSuffix('abc'), 'ab');
    });

    test('when removal yields empty, returns original (valid codegen name)', () {
      expect('Foo'.removeSuffix('Foo'), 'Foo');
      expect('FOO'.removeSuffix('foo'), 'FOO');
      expect('Page'.removeSuffix('page'), 'Page');
    });

    test('when removal yields non-identifier prefix, returns original', () {
      expect('1Page'.removeSuffix('page'), '1Page');
      expect('123Foo'.removeSuffix('Foo'), '123Foo');
    });

    test('trims whitespace after removal for valid identifiers', () {
      expect('login page'.removeSuffix('page'), 'login');
      expect('  LoginPage'.removeSuffix('page'), 'Login');
      expect('LoginPage  '.removeSuffix('page'), 'Login');
    });

    test('empty string with non-empty suffix stays empty', () {
      expect(''.removeSuffix('x'), '');
    });
  });
}
