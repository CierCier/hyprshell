# Nix language basics

> Source: https://nix.dev/tutorials/nix-language.html
> Upstream: https://github.com/nixos/nix.dev (`source/tutorials/nix-language.md`)
> Authors: fricklerhandwerk; Editors: infinisil


The Nix language is designed for conveniently creating and composing *derivations* – precise descriptions of how contents of existing files are used to derive new files.
It is a domain-specific, purely functional, lazily evaluated, dynamically typed programming language.

> **Notable uses of the Nix language:**


- Nixpkgs

  The largest, most up-to-date software distribution in the world, and written in the Nix language.

- NixOS

  A Linux distribution that can be configured fully declaratively and is based on Nix and Nixpkgs.

  Its underlying modular configuration system is written in the Nix language, and uses packages from Nixpkgs.
  The operating system environment and services it provides are configured with the Nix language.


You may quickly encounter Nix language expressions that look very complicated.
As with any programming language, the required amount of Nix language code closely matches the complexity of the problem it is supposed to solve, and reflects how well the problem – and its solution – is understood.
Building software is a complex undertaking, and Nix both *exposes* and *allows managing* this complexity with the Nix language.

Yet, the Nix language itself has only a few basic concepts that will be introduced in this tutorial, and which can be combined arbitrarily.
What may look complicated comes not from the language, but from how it is used.

## Overview

This is an introduction to **reading the Nix language**, for the purpose of following other tutorials and examples.

**Using the Nix language** in practice entails multiple things:

- Language: syntax and semantics
- Libraries: `builtins` and `pkgs.lib`
- Developer tools: testing, debugging, linting, formatting, ...
- Generic build mechanisms: `stdenv.mkDerivation`, build helpers, ...
- Composition and configuration mechanisms: `override`, `overrideAttrs`, overlays, `callPackage`, ...
- Ecosystem-specific packaging mechanisms: `buildGoModule`, `buildPythonApplication`, ...
- NixOS module system: `config`, `option`, ...

This tutorial only covers the most important language features, briefly discusses libraries, and at the end will direct you to reference material and resources on the other components.

### What will you learn?

This tutorial should enable you to read typical Nix language code and understand its structure.
Its goal is to highlight where the Nix language may differ from languages you are used to.

It therefore shows the most common and distinguishing patterns in the Nix language:

- [Assigning names and accessing values](https://nix.dev/tutorials/nix-language.html)
- Declaring and calling [functions](https://nix.dev/tutorials/nix-language.html)
- [Built-in and library functions](https://nix.dev/tutorials/nix-language.html)
- [Impurities](https://nix.dev/tutorials/nix-language.html) to obtain build inputs
- [Derivations](https://nix.dev/tutorials/nix-language.html) that describe build tasks

> **Important:**
This tutorial *does not* explain all Nix language features in detail and *does not* go into specifics of syntactical rules.
For instance, this tutorial skips over commonplace constructs such as `if ... then ... else ...`.

See the [Nix manual][manual-language] for a full language reference.

[manual-language]: https://nix.dev/manual/nix/stable/language/index.html

### What do you need?

- Familiarity with software development
- Familiarity with Unix shell, to read command line examples <!-- TODO: link to yet-to-be instructions on "how to read command line examples" -->
- A Nix installation to run the examples

### How long does it take?

- No experience with functional programming: 2 hours
- Familiar with functional programming: 1 hour
- Proficient with functional programming: 30 minutes

Run all examples.
Play with them to validate your assumptions and test what you have learned.
Read detailed explanations if you want to make sure you fully understand the examples.

### How to run the examples?

- A piece of Nix language code is a *Nix expression*.
- Evaluating a Nix expression produces a *Nix value*.
- The content of a *Nix file* (file extension `.nix`) is a Nix expression.

> **Note:**
To *evaluate* means to transform an expression into a value according to the language rules.

This tutorial contains many examples of Nix expressions.
Each one is followed by the expected evaluation result.

The following example is a Nix expression adding two numbers:

```nix
1 + 2
```

```
3
```

#### Interactive evaluation

Use [`nix repl`] to evaluate Nix expressions interactively (by typing them on the command line):

```shell-session
$ nix repl
Welcome to Nix 2.13.3. Type :? for help.

nix-repl> 1 + 2
3
```

> **Note:**
The Nix language uses lazy evaluation, and `nix repl` by default only computes values when needed.

Some examples show a fully evaluated data structure for clarity.
If your output does not match the example, try prepending `:p` to the input expression.

Example:

```shell-session
nix-repl> { a.b.c = 1; }
{ a = { ... }; }

nix-repl> :p { a.b.c = 1; }
{ a = { b = { c = 1; }; }; }
```

Type `:q` to exit [`nix repl`].


[`nix repl`]: https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-repl.html

#### Evaluating Nix files

Use [`nix-instantiate --eval`][nix-instantiate] to evaluate the expression in a Nix file.

```shell-session
$ echo 1 + 2 > file.nix
$ nix-instantiate --eval file.nix
3
```

<details><summary>Detailed explanation</summary>


The first command writes `1 + 2` to a file `file.nix` in the current directory.
The contents of `file.nix` are now `1 + 2`, which you can check with

```shell-session
$ cat file.nix
1 + 2
```

The second command runs `nix-instantiate` with the `--eval` option on `file.nix`, which reads the file and evaluates the contained Nix expression.
The resulting value is printed as output.

`--eval` is required to evaluate the file and do nothing else.
If `--eval` is omitted, `nix-instantiate` expects the expression in the given file to evaluate to a special value called a *derivation*, covered at the end of this tutorial in [derivations](https://nix.dev/tutorials/nix-language.html).

</details>

> **Note:**
`nix-instantiate --eval` will try to read from `default.nix` if no file name is specified.

```shell-session
$ echo 1 + 2 > default.nix
$ nix-instantiate --eval
3
```

> **Note:**
The Nix language uses lazy evaluation, and `nix-instantiate` by default only computes values when needed.

Some examples show a fully evaluated data structure for clarity.
If your output does not match the example, try adding the `--strict` option to `nix-instantiate`.

Example:

```shell-session
$ echo "{ a.b.c = 1; }" > file.nix
$ nix-instantiate --eval file.nix
{ a = <CODE>; }
```

```shell-session
$ echo "{ a.b.c = 1; }" > file.nix
$ nix-instantiate --eval --strict file.nix
{ a = { b = { c = 1; }; }; }
```


[nix-instantiate]: https://nix.dev/manual/nix/stable/command-ref/nix-instantiate.html

### Notes on whitespace

White space is used to delimit [lexical tokens], where required.
It is otherwise insignificant.

[lexical tokens]: https://en.wikipedia.org/wiki/Lexical_analysis#Lexical_token_and_lexical_tokenization

Line breaks, indentation, and additional spaces are for the reader's convenience.

The following are equivalent:

```nix
let
 x = 1;
 y = 2;
in x + y
```

```
3
```

```nix
let x=1;y=2;in x+y
```

```
3
```

## Names and values

Values in the Nix language can be primitive data types, lists, attribute sets, and functions.

Examples of primitive data types and lists appear in the context of [attribute sets](https://nix.dev/tutorials/nix-language.html).
Later in this section, you will encounter special features of character strings: [string interpolation](https://nix.dev/tutorials/nix-language.html), [file system paths](https://nix.dev/tutorials/nix-language.html), and [indented strings](https://nix.dev/tutorials/nix-language.html).
[Functions](https://nix.dev/tutorials/nix-language.html) are covered separately.

[Attribute sets](https://nix.dev/tutorials/nix-language.html) and [`let` expressions](https://nix.dev/tutorials/nix-language.html) are used to assign names to values.
Assignments are denoted by a single equal sign (`=`).

Whenever you encounter an equal sign (`=`) in Nix language code:
- On its left is the assigned name.
- On its right is the value, delimited by a semicolon (`;`).

### Attribute set `{ ... }`

An attribute set is a collection of name-value-pairs, where names must be unique.

The following example shows all primitive data types, lists, and attribute sets.

> **Note:**
If you are familiar with JSON, imagine the Nix language as *JSON with functions*.

Nix language data types *without functions* work just like their counterparts in JSON and look very similar.


**Nix**

```nix
{
  string = "hello";
  integer = 1;
  float = 3.141;
  bool = true;
  null = null;
  list = [ 1 "two" false ];
  attribute-set = {
    a = "hello";
    b = 2;
    c = 2.718;
    d = false;
  }; # comments are supported
}
```


**JSON**

```json
{
  "string": "hello",
  "integer": 1,
  "float": 3.141,
  "bool": true,
  "null": null,
  "list": [1, "two", false],
  "object": {
    "a": "hello",
    "b": 1,
    "c": 2.718,
    "d": false
  }
}
```


> **Note:**
- [Attribute set syntax](https://nix.dev/manual/nix/stable/language/syntax#attrs-literal): attribute names usually do not need quotes
- [List syntax](https://nix.dev/manual/nix/stable/language/syntax#list-literal): list elements are separated by white space


#### Recursive attribute set `rec { ... }`

You will sometimes see attribute sets declared with `rec` prepended.
This allows access to attributes from within the set.

Example:

```nix
rec {
  one = 1;
  two = one + 1;
  three = two + 1;
}
```

```
{ one = 1; three = 3; two = 2; }
```

> **Note:**
Elements in an attribute set can be declared in any order, and are ordered on evaluation.

Counter-example:

```nix
{
  one = 1;
  two = one + 1;
  three = two + 1;
}
```

```
error: undefined variable 'one'

       at «string»:3:9:

            2|   one = 1;
            3|   two = one + 1;
             |         ^
            4|   three = two + 1;
```

### `let ... in ...`

Also known as “`let` expression” or “`let` binding”

`let` expressions allow assigning names to values for repeated use.

Example:

```nix
let
  a = 1;
in
a + a
```

```
2
```

<details><summary>Detailed explanation</summary>


Assignments are placed between the keywords `let` and `in`.
In this example we assign `a = 1`.

After `in` comes the expression in which the assignments are valid, i.e., where assigned names can be used.
In this example the expression is `a + a`, where `a` refers to `a = 1`.

By replacing the names with their assigned values, `a + a` evaluates to `2`.

</details>

Names can be assigned in any order, and expressions on the right of the assignment (`=`) can refer to other assigned names.

Example:

```nix
let
  b = a + 1;
  a = 1;
in
a + b
```

```
3
```

<details><summary>Detailed explanation</summary>


Assignments are placed between the keywords `let` and `in`.
In this example we assign `a = 1` and `b = a + 1`.

The order of assignments does not matter.
Therefore the following example, where the assignments are in reverse order, is equivalent:


```nix
let
  a = 1;
  b = a + 1;
in
a + b
```

```
3
```

Note that the `a` in `b = a + 1` refers to `a = 1`.

After `in` comes the expression in which the assignments are valid.
In this example the expression is `a + b`, where `a` refers to `a = 1`, and `b` refers to `b = a + 1`.

By replacing the names with their assigned values, `a + b` evaluates to `3`.

This is similar to [recursive attribute sets](https://nix.dev/tutorials/nix-language.html):
in both, the order of assignments does not matter, and names on the left can be used in expressions on the right of the assignment (`=`).

Example:


**`let ... in ...`**


```nix
let
  b = a + 1;
  c = a + b;
  a = 1;
in {  c = c; a = a; b = b; }
```

```
{ a = 1; b = 2; c = 3; }
```

</details>


**`rec { ... }`**


```nix
rec {
  b = a + 1;
  c = a + b;
  a = 1;
}
```

```
{ a = 1; b = 2; c = 3; }
```


The difference is that while a recursive attribute set evaluates to an [attribute set](https://nix.dev/tutorials/nix-language.html), any expression can follow after the `in` keyword.

In the following example we use the `let` expression to form a list:

```nix
let
  b = a + 1;
  c = a + b;
  a = 1;
in [ a b c ]
```

```
[ 1 2 3 ]
```


Only expressions within the `let` expression itself can access the newly declared names.
The bindings have local scope.

Counter-example:

```nix
{
  a = let x = 1; in x;
  b = x;
}
```

```
error: undefined variable 'x'

       at «string»:3:7:

            2|   a = let x = 1; in x;
            3|   b = x;
             |       ^
            4| }
```

<!-- TODO: exercise - use let to reuse a value in an attribute set -->

### Attribute access

Attributes in a set are accessed with a dot (`.`) and the attribute name.

Example:

```nix
let
  attrset = { x = 1; };
in
attrset.x
```

```
1
```

Accessing nested attributes works the same way.

Example:

```nix
let
  attrset = { a = { b = { c = 1; }; }; };
in
attrset.a.b.c
```

```
1
```

The dot (`.`) notation can also be used for assigning attributes.

Example:

```nix
{ a.b.c = 1; }
```

```
{ a = { b = { c = 1; }; }; }
```

### `with ...; ...`

The `with` expression allows access to attributes without repeatedly referencing their attribute set.

Example:

```nix
let
  a = {
    x = 1;
    y = 2;
    z = 3;
  };
in
with a; [ x y z ]
```

```
[ 1 2 3 ]
```

The expression

```nix
with a; [ x y z ]
```

is equivalent to

```nix
[ a.x a.y a.z ]
```

Attributes made available through `with` are only in scope of the expression following the semicolon (`;`).

Counter-example:

```nix
let
  a = {
    x = 1;
    y = 2;
    z = 3;
  };
in
{
  b = with a; [ x y z ];
  c = x;
}
```

```
error: undefined variable 'x'

       at «string»:10:7:

            9|   b = with a; [ x y z ];
           10|   c = x;
             |       ^
           11| }
```

### `inherit ...`

`inherit` is shorthand for assigning the value of a name from an existing scope to the same name in a nested scope.
It is for convenience to avoid repeating the same name multiple times.

Example:

```nix
let
  x = 1;
  y = 2;
in
{
  inherit x y;
}
```

```
{ x = 1; y = 2; }
```

The fragment

```nix
inherit x y;
```
is equivalent to

```nix
x = x; y = y;
```

### `inherit (...) ...`

It is also possible to `inherit` names from a specific attribute set by enclosing its name parentheses.

Example:

```nix
let
  a = { x = 1; y = 2; };
in
{
  inherit (a) x y;
}
```

```
{ x = 1; y = 2; }
```

The fragment

```nix
inherit (a) x y;
```

is equivalent to

```nix
x = a.x; y = a.y;
```

`inherit` also works inside `let` expressions.

Example:

```nix
let
  a = { x = 1; y = 2; };
  inherit (a) x y;
in [ x y ]
```

```
[ 1 2 ]
```

<details><summary>Detailed explanation</summary>


While this example is contrived, in more complex code you will regularly see nested [`let` expressions](https://nix.dev/tutorials/nix-language.html) that re-use names from their outer scope.

Here we use the attribute set `a = { x = 1; y = 2; }` to have something non-trivial to inherit from.
The `let` expression inherits `x` and `y` from `a` using `( )`, which is equivalent to writing:

```nix
let
  x = a.x;
  y = a.y;
in
```

The new inner scope now contains `x` and `y`, which are used in the list `[ x y ]`.

</details>

### String interpolation `${ ... }`

Previously known as “antiquotation”.

The value of a Nix expression can be inserted into a character string with the dollar-sign and braces (`${ }`).

Example:

```nix
let
  name = "Nix";
in
"hello ${name}"
```

```
"hello Nix"
```

Only character strings or values that can be represented as a character string are allowed.

Counter-example:

```nix
let
  x = 1;
in
"${x} + ${x} = ${x + x}"
```

```
error: cannot coerce an integer to a string

       at «string»:4:2:

            3| in
            4| "${x} + ${x} = ${x + x}"
             |  ^
            5|
```

Interpolated expressions can be arbitrarily nested.

(This can become hard to read. Avoid it in practice.)

Example:

```nix
let
  a = "no";
in
"${a + " ${a + " ${a}"}"}"
```

```
"no no no"
```

<details><summary>Detailed explanation</summary>

Any Nix expression where the value can be represented as a string can be used within `${ }`.

The `+` sign in the above expression is the [string concatenation operator](https://nix.dev/manual/nix/latest/language/operators#string-concatenation), which takes two strings and produces a new string.

The expression in the example is deliberately confusing to demonstrate that arbitrarily nested string interpolations are possible, but tend to be hard to read.

It denotes a string that contains the interpolation of concatenating the value of `a` with a string that starts with a space and is followed by another interpolated string.
That second interpolated string is again the result of concatenating the value of `a` and yet another string that starts with a space and is followed by an interpolation of `a`.

Example:
```nix
let
  a = "one";
  b = "two";
in
"${a + b}"
```

```
"onetwo"
```

Built-in functions are discussed in a [later section](https://nix.dev/tutorials/nix-language.html).
</details>

> **Warning:**
You may encounter strings that use the dollar sign (`$`) before an assigned name, but no braces (`{ }`):

These are *not* interpolated strings, but usually denote variables in a shell script.

In such cases, the use of names from the surrounding Nix expression is a coincidence.

Example:

```nix
let
  out = "Nix";
in
"echo ${out} > $out"
```

```
"echo Nix > $out"
```

<!-- TODO: link to escaping rules -->

### Indented strings

Also known as “multi-line strings”.

The Nix language offers convenience syntax for character strings which span multiple lines that have common indentation.

Indented strings are denoted by *double single quotes* (`'' ''`).

Example:

```nix
''
multi
line
string
''
```

```
"multi\nline\nstring\n"
```

Equal amounts of prepended white space are trimmed from the result.

Example:

```nix
''
  one
   two
    three
''
```

```
"one\n two\n  three\n"
```

> **Note:**
Indented strings also support [string interpolation](https://nix.dev/tutorials/nix-language.html).
For details check the [documentation on string literals in the Nix language](https://nix.dev/manual/nix/2.24/language/syntax#string-literal).

### File system paths

The Nix language offers convenience syntax for file system paths.

Absolute paths always start with a slash (`/`).

Example:

```nix
/absolute/path
```

```
/absolute/path
```

Paths are relative when they contain at least one slash (`/`) but do not start with one.
They evaluate to the path relative to the file containing the expression.

The following examples assume the containing Nix file is in `/current/directory` (or `nix repl` is run in `/current/directory`).

Example:


```nix
./relative
```

```
/current/directory/relative
```

Example:

```nix
relative/path
```

```
/current/directory/relative/path
```

One dot (`.`) denotes the current directory within the given path.

You will often see the following expression, which specifies a Nix file's directory.

Example:

```nix
./.
```

```
/current/directory
```

<details><summary>Detailed explanation</summary>


Since relative paths must contain a slash (`/`) but must not start with one, and the dot (`.`) denotes no change of directory, the combination `./.` specifies the current directory as a relative path.

</details>

Two dots (`..`) denote the parent directory.

Example:

```nix
../.
```

```
/current
```
> **Note:**
Paths can be used in interpolated expressions – an [impure operation](https://nix.dev/tutorials/nix-language.html) covered in detail in a [later section](https://nix.dev/tutorials/nix-language.html).

#### Lookup paths

Also known as “angle bracket syntax”.

Example:

```nix
<nixpkgs>
```

```
/nix/var/nix/profiles/per-user/root/channels/nixpkgs
```

The value of a [lookup path](https://nix.dev/manual/nix/2.22/language/constructs/lookup-path) is a file system path that depends on the value of [`builtins.nixPath`](https://nix.dev/manual/nix/2.22/language/builtin-constants#builtins-nixPath).

In practice, `<nixpkgs>` points to the file system path of some revision of Nixpkgs.

For example, `<nixpkgs/lib>` points to the subdirectory `lib` of that file system path:

```nix
<nixpkgs/lib>
```

```
/nix/var/nix/profiles/per-user/root/channels/nixpkgs/lib
```

While you will encounter many such examples, [avoid lookup paths](https://nix.dev/tutorials/nix-language.html) in production code, as they are [impurities](https://nix.dev/tutorials/nix-language.html) which are not reproducible.

[NIX_PATH]: https://nix.dev/manual/nix/stable/command-ref/env-common.html?highlight=nix_path#env-NIX_PATH
[nixpkgs]: https://github.com/NixOS/nixpkgs
[manual-primitives]: https://nix.dev/manual/nix/stable/language/values.html#primitives

## Functions

Functions are everywhere in the Nix language and deserve particular attention.

A function always takes exactly one argument.
Argument and function body are separated by a colon (`:`).

Wherever you find a colon (`:`) in Nix language code:
- On its left is the function argument
- On its right is the function body.

Function arguments are the third way, apart from [attribute sets](https://nix.dev/tutorials/nix-language.html) and [`let` expressions](https://nix.dev/tutorials/nix-language.html), to assign names to values.
Notably, values are not known in advance: the names are placeholders that are filled when [calling a function](https://nix.dev/tutorials/nix-language.html).

Function declarations in the Nix language can appear in different forms.
Each of them is explained in the following, and here is an overview:

- Single argument

```nix
  x: x + 1
  ```

  - Multiple arguments via nesting

```nix
    x: y: x + y
    ```

- Attribute set argument

```nix
  { a, b }: a + b
  ```

  - With default attributes

```nix
    { a, b ? 0 }: a + b
    ```

  - With additional attributes allowed

```nix
    { a, b, ...}: a + b
    ```

- Named attribute set argument

```nix
  args@{ a, b, ... }: a + b + args.c
  ```

  or

```nix
  { a, b, ... }@args: a + b + args.c
  ```

Functions in the Nix language have no names.
They are anonymous, and such a function is called a *lambda*.[^lambda]

[^lambda]: The term *lambda* is a shorthand for [lambda abstraction](https://en.wikipedia.org/wiki/Lambda_calculus#lambdaAbstr) in the [lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus).

Example:

```nix
x: x + 1
```

```nix
<LAMBDA>
```

The `<LAMBDA>` indicates the resulting value is an anonymous function.

As with any other value, functions can be assigned to a name.

Example:

```nix
let
  f = x: x + 1;
in f
```

```nix
<LAMBDA>
```

### Calling functions

Also known as "function application".

Calling a function with an argument means writing the argument after the function.

Example:

```nix
let
  f = x: x + 1;
in f 1
```

```
2
```

Example:

```nix
let
  f = x: x.a;
in
f { a = 1; }
```

```
1
```

The above example calls `f` on a literal attribute set.
One can also pass arguments by name.

Example:

```nix
let
  f = x: x.a;
  v = { a = 1; };
in
f v
```

```
1
```

Since function and argument are separated by white space, sometimes parentheses (`( )`) are required to achieve the desired result.

Example:

```nix
(x: x + 1) 1
```

```
2
```

<details><summary>Detailed explanation</summary>


This expression applies an anonymous function `x: x + 1` to the argument `1`.
The function has to be written in parentheses to distinguish it from the argument.

</details>

Example:

List elements are also separated by white space, therefore the following are different:

```nix
let
 f = x: x + 1;
 a = 1;
in [ (f a) ]
```

```nix
[ 2 ]
```

```nix
let
 f = x: x + 1;
 a = 1;
in [ f a ]
```

```
[ <LAMBDA> 1 ]
```

The first example reads: apply `f` to `a`, and put the result in a list.
The resulting list has one element.

The second example reads: put `f` and `a` in a list.
The resulting list has two elements.

#### Multiple arguments

Also known as “[curried] functions”.

Nix functions take exactly one argument.
Multiple arguments can be handled by nesting functions.

Such a nested function can be used like a function that takes multiple arguments, but offers additional flexibility.

[curried]: https://en.wikipedia.org/wiki/Currying

Example:

```nix
x: y: x + y
```

```
<LAMBDA>
```

The above function is equivalent to

```nix
x: (y: x + y)
```

```
<LAMBDA>
```

This function takes one argument and returns another function `y: x + y` with `x` set to the value of that argument.

Example:

```nix
let
  f = x: y: x + y;
in
f 1
```

```
<LAMBDA>
```

Applying the function which results from `f 1` to another argument yields the inner body `x + y` (with `x` set to `1` and `y` set to the other argument), which can now be fully evaluated.

```nix
let
  f = x: y: x + y;
in
f 1 2
```

```
3
```

<!-- TODO: exercise - assign the lambda a name and do something with it -->

### Attribute set argument

Also known as “keyword arguments” or “destructuring”.

Nix functions can be declared to require an attribute set with specific structure as argument.

This is denoted by listing the expected attribute names separated by commas (`,`) and enclosed in braces (`{ }`).

Example:

```nix
{a, b}: a + b
```

```nix
<LAMBDA>
```

The argument defines the exact attributes that have to be in that set.
Leaving out or passing additional attributes is an error.

Example:

```nix
let
  f = {a, b}: a + b;
in
f { a = 1; b = 2; }
```

```nix
3
```

Counter-example:

```nix
let
  f = {a, b}: a + b;
in
f { a = 1; b = 2; c = 3; }
```

```
error: 'f' at (string):2:7 called with unexpected argument 'c'

       at «string»:4:1:

            3| in
            4| f { a = 1; b = 2; c = 3; }
             | ^
            5|
```

<!-- TODO: not the same as x: x.a + x.b (!!!!) -->

#### Default values

Also known as “default arguments”.

Destructured arguments can have default values for attributes.

This is denoted by separating the attribute name and its default value with a question mark (`?`).

Attributes in the argument are not required if they have a default value.

Example:

```nix
let
  f = {a, b ? 0}: a + b;
in
f { a = 1; }
```

```
1
```

Example:

```nix
let
  f = {a ? 0, b ? 0}: a + b;
in
f { } # empty attribute set
```

```
0
```

#### Additional attributes

Additional attributes are allowed with an ellipsis (`...`):

```nix
{a, b, ...}: a + b
```

Unlike in the previous counter-example, passing an argument that contains additional attributes is not an error.

Example:

```nix
let
  f = {a, b, ...}: a + b;
in
f { a = 1; b = 2; c = 3; }
```

```
3
```

### Named attribute set argument

Also known as “@ pattern”, “@ syntax”, or “‘at’ syntax”.

An attribute set argument can be given a name to be accessible as a whole.

This is denoted by prepending or appending the name to the attribute set argument, separated by the at sign (`@`).

Example:

```nix
{a, b, ...}@args: a + b + args.c
```

```
<LAMBDA>
```

or

```nix
args@{a, b, ...}: a + b + args.c
```

```
<LAMBDA>
```

Example:

```nix
let
  f = {a, b, ...}@args: a + b + args.c;
in
f { a = 1; b = 2; c = 3; }
```

```nix
6
```

## Function libraries

In addition to the [built-in operators][operators] (`+`, `==`, `&&`, etc.), there are two widely used libraries that *together* can be considered standard for the Nix language.
You need to know about both to understand and navigate Nix language code.

<!-- TODO: find a place for operators -->

Skim them to familiarise yourself with what is available.

[operators]: https://nix.dev/manual/nix/stable/language/operators.html

### `builtins`

Also known as “primitive operations” or “primops”.

Nix comes with many functions that are built into the language.
They are implemented in C++ as part of the Nix language interpreter.

> **Note:**
The Nix manual lists all [Built-in Functions][nix-builtins], and shows how to use them.

These functions are available under the `builtins` constant.

Example:

```nix
builtins.toString
```

```
<PRIMOP>
```

[nix-builtins]: https://nix.dev/manual/nix/stable/language/builtins.html

#### `import`

Most built-in functions are only accessible through `builtins`.
A notable exception is `import`, which is also available at the top level.

`import` takes a path to a Nix file, reads it to evaluate the contained Nix expression, and returns the resulting value.
If the path points to a directory, the file `default.nix` in that directory is used instead.

Example:

```shell-session
$ echo 1 + 2 > file.nix
```

```nix
import ./file.nix
```

```
3
```

<details><summary>Detailed explanation</summary>


The preceding shell command writes the contents `1 + 2` to the file `file.nix` in the current directory.

The above Nix expression refers to this file as `./file.nix`.
`import` reads the file and evaluates to the contained Nix expression.

It is an error if the file system path does not exist.

After reading `file.nix` the Nix expression is equivalent to the file contents:

```nix
1 + 2
```

```
3
```
</details>

Since a Nix file can contain any Nix expression, `import`ed functions can be applied to arguments immediately.

Whenever you find additional tokens after a call to `import`, the returned value is a function.
Anything that follows are arguments to that function.

Example:

```shell-session
$ echo "x: x + 1" > file.nix
```

```nix
import ./file.nix 1
```

```
2
```

<details><summary>Detailed explanation</summary>


The preceding shell command writes the contents `x: x + 1` to the file `file.nix` in the current directory.

The above Nix expression refers to this file as `./file.nix`.
`import ./file.nix` reads the file and evaluates to the contained Nix expression.

It is an error if the file system path does not exist.

After reading the file, the Nix expression `import ./file.nix` is equivalent to the file contents:

```nix
(x: x + 1) 1
```

```
2
```

This applies the function `x: x + 1` to the argument `1`, and therefore evaluates to `2`.

> **Note:**
Parentheses are required to separate function declaration from function application.
</details>


### `pkgs.lib`

The [`nixpkgs`][nixpkgs] repository contains an attribute set called [`lib`][nixpkgs-lib], which provides a large number of useful functions.
They are implemented in the Nix language, as opposed to [`builtins`](https://nix.dev/tutorials/nix-language.html), which are part of the language itself.

> **Note:**
The Nixpkgs manual lists all [Nixpkgs library functions][nixpkgs-functions].

[nixpkgs-functions]: https://nixos.org/manual/nixpkgs/stable/#sec-functions-library
[nixpkgs-lib]: https://github.com/NixOS/nixpkgs/blob/master/lib/default.nix

These functions are usually accessed through `pkgs.lib`, as the Nixpkgs attribute set is given the name `pkgs` by convention.

Example:

```nix
let
  pkgs = import <nixpkgs> {};
in
pkgs.lib.strings.toUpper "lookup paths considered harmful"
```

```
LOOKUP PATHS CONSIDERED HARMFUL
```

<details><summary>Detailed explanation</summary>


This is a more complex example, but by now you should be familiar with all its components.

The name `pkgs` is declared to be the expression `import`ed from some file.
That file's path is determined by the value of the lookup path `<nixpkgs>`, which in turn is determined by the `$NIX_PATH` environment variable at the time this expression is evaluated.
As this expression happens to be a function, it requires an argument to evaluate, and in this case passing an empty attribute set `{}` is sufficient.

Now that `pkgs` is in scope of `let ... in ...`, its attributes can be accessed.
From the Nixpkgs manual one can determine that there exists a function under [`lib.strings.toUpper`].

[`lib.strings.toUpper`]: https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.toUpper

For brevity, this example uses a lookup path to obtain *some version* of Nixpkgs.
The function `toUpper` is trivial enough that we can expect it not to produce different results for different versions of Nixpkgs.
Yet, more sophisticated software is likely to suffer from such problems.
A fully reproducible example would therefore look like this:

```nix
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/06278c77b5d162e62df170fec307e83f1812d94b.tar.gz";
  pkgs = import nixpkgs {};
in
pkgs.lib.strings.toUpper "always pin your sources"
```

```
ALWAYS PIN YOUR SOURCES
```

See [Towards reproducibility: pinning Nixpkgs](https://nix.dev/tutorials/first-steps/towards-reproducibility-pinning-nixpkgs.html) for details.

What you will also often see is that `pkgs` is passed as an argument to a function.
By convention one can assume that it refers to the Nixpkgs attribute set, which has a `lib` attribute:

```nix
{ pkgs, ... }:
pkgs.lib.strings.removePrefix "no " "no true scotsman"
```

```
<LAMBDA>
```

To make this function produce a result, you can write it to a file (e.g. `file.nix`) and pass it an argument through `nix-instantiate`:

```shell-session
$ nix-instantiate --eval file.nix --arg pkgs 'import <nixpkgs> {}'
"true scotsman"
```

Oftentimes you will see in NixOS configurations, and also within Nixpkgs, that `lib` is passed directly.
In that case one can assume that this `lib` is equivalent to `pkgs.lib` where only `pkgs` is available.

Example:

```nix
{ lib, ... }:
let
  to-be = true;
in
lib.trivial.or to-be (! to-be)
```

```
<LAMBDA>
```

To make this function produce a result, you can write it to a file (e.g. `file.nix`) and pass it an argument through `nix-instantiate`:

```shell-session
$ nix-instantiate --eval file.nix --arg lib '(import <nixpkgs> {}).lib'
true
```

Sometimes both `pkgs` and `lib` are passed as arguments.
In that case, one can assume `pkgs.lib` and `lib` to be equivalent.
This is done to improve readability by avoiding repeated use of `pkgs.lib`.

Example:

```nix
{ pkgs, lib, ... }:
# ... multiple uses of `pkgs`
# ... multiple uses of `lib`
```

</details>

For historical reasons, some of the functions in `pkgs.lib` are equivalent to [`builtins`](https://nix.dev/tutorials/nix-language.html) of the same name.

## Impurities

So far this tutorial has only covered *pure expressions*:
declaring data and transforming it with functions.

In practice, describing derivations – the Nix language's defining feature, which enables functional programming with the file system – requires observing the outside world.
[Derivations](https://nix.dev/tutorials/nix-language.html) are discussed later in the tutorial.

There is only one impurity in the Nix language that is relevant here:
reading files from the file system as *build inputs*.

Derivations refer to build inputs to describe how to derive new files.
When run, a derivation will only have access to explicitly declared build inputs.

The only way to specify build inputs in the Nix language is explicitly with:

- File system paths
- Dedicated functions

Nix and the Nix language refer to files by their content hash. If file contents are not known in advance, it's unavoidable to read files during expression evaluation.

> **Note:**
Nix supports other types of impure expressions, such as [lookup paths](https://nix.dev/tutorials/nix-language.html) or the constant [`builtins.currentSystem`](https://nix.dev/manual/nix/stable/language/builtin-constants.html#builtins-currentSystem).
These are not covered here in more detail, as they do not matter for how the Nix language works in principle, and because they are discouraged for the very reason of breaking reproducibility.

### Paths

Whenever a file system path is used in [string interpolation](https://nix.dev/tutorials/nix-language.html), the contents of that file are copied to a special location in the file system, the *Nix store*, as a side effect.

The evaluated string then contains the Nix store path assigned to that file.

<!-- TODO: link to explanation of the Nix store -->

Example:

```shell-session
$ echo 123 > data
```

```nix
"${./data}"
```

```
"/nix/store/h1qj5h5n05b5dl5q4nldrqq8mdg7dhqk-data"
```

<details><summary>Detailed explanation</summary>


The preceding shell command writes the characters `123` to the file `data` in the current directory.

The above Nix expression refers to this file as `./data` and converts the file system path to an [interpolated string](https://nix.dev/tutorials/nix-language.html) `${ ... }`.

Such interpolated expressions must evaluate to something that can be represented as a character string.
A file system path is such a value, and its character string representation is the corresponding Nix store path:

```
/nix/store/<hash>-<name>
```

The Nix store path is obtained by taking the hash of the file's contents (`<hash>`) and combining it with the file name (`<name>`).
The file is copied into the Nix store directory `/nix/store` as a side effect of evaluation.
It is an error if the file system path does not exist.

</details>

For directories the same thing happens: The entire directory (including nested files and directories) is copied to the Nix store, and the evaluated string becomes the Nix store path of the directory.

### Fetchers

Files to be used as build inputs do not have to come from the file system.

The Nix language provides built-in impure functions to fetch files over the network during evaluation:

- [`builtins.fetchurl`](https://nix.dev/manual/nix/stable/language/builtins.html#builtins-fetchurl)
- [`builtins.fetchTarball`](https://nix.dev/manual/nix/stable/language/builtins.html#builtins-fetchTarball)
- [`builtins.fetchGit`](https://nix.dev/manual/nix/stable/language/builtins.html#builtins-fetchGit)
- [`builtins.fetchClosure`](https://nix.dev/manual/nix/stable/language/builtins.html#builtins-fetchClosure)

These functions evaluate to a file system path in the Nix store.

Example:

```nix
builtins.fetchurl "https://github.com/NixOS/nix/archive/7c3ab5751568a0bc63430b33a5169c5e4784a0ff.tar.gz"
```

```
"/nix/store/7dhgs330clj36384akg86140fqkgh8zf-7c3ab5751568a0bc63430b33a5169c5e4784a0ff.tar.gz"
```

Some of them add extra convenience, such as automatically unpacking archives.

Example:

```nix
builtins.fetchTarball "https://github.com/NixOS/nix/archive/7c3ab5751568a0bc63430b33a5169c5e4784a0ff.tar.gz"
```

```
"/nix/store/d59llm96vgis5fy231x6m7nrijs0ww36-source"
```

> **Note:**
The Nixpkgs manual on [Fetchers][nixpkgs-fetchers] lists numerous additional library functions to fetch files over the network.

It is an error if the network request fails.

[nixpkgs-fetchers]: https://nixos.org/manual/nixpkgs/stable/#chap-pkgs-fetchers

## Derivations


Derivations are at the core of both Nix and the Nix language:
- The Nix language is used to describe derivations.
- Nix runs derivations to produce *build results*.
- Build results can in turn be used as inputs for other derivations.

The Nix language primitive to declare a derivation is the built-in impure function `derivation`.

It is usually wrapped by the Nixpkgs build mechanism `stdenv.mkDerivation`, which hides much of the complexity involved in non-trivial build procedures.

> **Note:**
You will probably never encounter `derivation` in practice.

Whenever you encounter `mkDerivation`, it denotes something that Nix will eventually *build*.

Example: [a package using `mkDerivation`](https://nix.dev/tutorials/nix-language.html)

The evaluation result of `derivation` (and `mkDerivation`) is an [attribute set](https://nix.dev/tutorials/nix-language.html) with a certain structure and a special property:
It can be used in [string interpolation](https://nix.dev/tutorials/nix-language.html), and in that case evaluates to the Nix store path of its build result.

Example:

```nix
let
  pkgs = import <nixpkgs> {};
in "${pkgs.nix}"
```

```
"/nix/store/sv2srrjddrp2isghmrla8s6lazbzmikd-nix-2.11.0"
```

> **Note:**
Your output may differ.
It may produce a different hash or even a different package version.

A derivation's output path is fully determined by its inputs, which in this case come from *some* version of Nixpkgs.

This is why [avoid lookup paths](https://nix.dev/tutorials/nix-language.html) to ensure predictable outcomes, except in examples intended for illustration only.

<details><summary>Detailed explanation</summary>


The example imports the Nix expression from the lookup path `<nixpkgs>`, and applies the resulting function to an empty attribute set `{}`.
Its output is assigned the name `pkgs`.

Converting the attribute `pkgs.nix` to a string with [string interpolation](https://nix.dev/tutorials/nix-language.html) is allowed, as `pkgs.nix` is a derivation.
That is, ultimately `pkgs.nix` boils down to a call to `derivation`.

The resulting string is the file system path where the build result of that derivation will end up.

There is more depth to the inner workings of derivations, but at this point it should be enough to know that such expressions evaluate to Nix store paths.

</details>

String interpolation on derivations is used to refer to their build results as file system paths when declaring new derivations.

This allows constructing arbitrarily complex compositions of derivations with the Nix language.

## Worked examples

So far the examples have been artificial illustrations of the Nix language constructs.

You should now be able to read Nix language code for simple packages and configurations, and come up with similar explanations of the following practical examples.

> **Note:**
The goal of the following exercises is not to understand what the code means or how it works, but how it is structured in terms of functions, attribute sets, and other Nix language data types.

### Shell environment

```nix
{ pkgs ? import <nixpkgs> {} }:
let
  message = "hello world";
in
pkgs.mkShellNoCC {
  packages = with pkgs; [ cowsay ];
  shellHook = ''
    cowsay ${message}
  '';
}
```

This example declares a shell environment (which runs the `shellHook` on initialization).

Explanation:

- This expression is a function that takes an attribute set as its argument.
- If the argument has the attribute `pkgs`, it will be used in the function body.
  Otherwise, by default, import the Nix expression in the file found on the lookup path `<nixpkgs>` (which is a function in this case), call the function with an empty attribute set, and use the resulting value.
- The name `message` is bound to the string value `"hello world"`.
- The attribute `mkShellNoCC` of the `pkgs` set is a function that is passed an attribute set as argument.
  Its return value is also the result of the outer function.
- The attribute set passed to `mkShellNoCC` has the attributes `packages` (set to a list with one element: the `cowsay` attribute from `pkgs`) and `shellHook` (set to an indented string).
- The indented string contains an interpolated expression, which will expand the value of `message` to yield `"hello world"`.


### NixOS configuration

```nix
{ config, pkgs, ... }: {

  imports = [ ./hardware-configuration.nix ];

  environment.systemPackages = with pkgs; [ git ];

  # ...

}
```

This example is (part of) a NixOS configuration.

Explanation:

- This expression is a function that takes an attribute set as an argument.
  It returns an attribute set.
- The argument must at least have the attributes `config` and `pkgs`, and may have more attributes.
- The returned attribute set contains the attributes `imports` and `environment`.
- `imports` is a list with one element: a path to a file next to this Nix file, called `hardware-configuration.nix`.

> **Note:**
  `imports` is not the impure built-in `import`, but a regular attribute name!
- `environment` is itself an attribute set with one attribute `systemPackages`, which will evaluate to a list with one element: the `git` attribute from the `pkgs` set.
- The `config` argument is not (shown to be) used.

### Package

```nix
{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {

  pname = "hello";

  version = "2.12";

  src = fetchurl {
    url = "mirror://gnu/${pname}/${pname}-${version}.tar.gz";
    sha256 = "1ayhp9v4m4rdhjmnl2bq3cibrbqqkgjbl3s7yk2nhlh8vj3ay16g";
  };

  meta = with lib; {
    license = licenses.gpl3Plus;
  };

}
```

This example is a (simplified) package declaration from Nixpkgs.

Explanation:

- This expression is a function that takes an attribute set which must have exactly the attributes `lib`, `stdenv`, and `fetchurl`.
- It returns the result of evaluating the function `mkDerivation`, which is an attribute of `stdenv`, applied to a recursive set.
- The recursive set passed to `mkDerivation` uses its own `pname` and `version` attributes in the argument to the function `fetchurl`.
  `fetchurl` itself comes from the outer function's arguments.
- The `meta` attribute is itself an attribute set, where the `license` attribute has the value that was assigned to the nested attribute `lib.licenses.gpl3Plus`.

## References

- [Nix manual: Nix language][manual-language]
- [Nix manual: String interpolation][manual-string-interpolation]
- [Nix manual: Operators][operators]
- [Nix manual: Built-in Functions][nix-builtins]
- [Nix manual: `nix repl`][`nix repl`]
- [Nixpkgs manual: Functions reference][nixpkgs-functions]
- [Nixpkgs manual: Fetchers][nixpkgs-fetchers]

[manual-string-interpolation]: https://nix.dev/manual/nix/stable/language/string-interpolation.html

## Next steps

### Get things done

- [Declaring a reproducible development environment](https://nix.dev/tutorials/first-steps/declarative-shell.html) – create reproducible shell environments from a Nix file
- `./packaging-existing-software.md` – make more software available through Nix


If you want to take a longer break from learning Nix, you can remove unused build results from the Nix store with:

```console
$ nix-collect-garbage
```

### Learn more

If you worked through the examples, you will have noticed that reading the Nix language reveals the structure of the code, but does not necessarily tell what the code actually means.

Often it is not possible to determine from the code at hand
- the data type of a named value or function argument.
- the data type a called function accepts for its argument.
- which attributes are present in a given attribute set.

Example:

```nix
{ x, y, z }: (x y) z.a
```

How do you know...
- that `x` will be a function that, given an argument, returns a function?
- that, given `x` is a function, `y` will be an appropriate argument to `x`?
- that, given `(x y)` is a function, `z.a` will be an appropriate argument to `(x y)`?
- that `z` will be an attribute set at all?
- that, given `z` is an attribute set, it will have an attribute `a`?
- which data type `y` and `z.a` will be?
- the data type of the end result?

And how does the caller of this function know that it requires an attribute set with attributes `x`, `y`, `z`?

Answering such questions requires knowing the context in which a given expression is supposed to be used.

The Nix ecosystem and code style is driven by conventions.
Most names you will encounter in Nix language code come from Nixpkgs:

- [Nix Pills][nix-pills] - a detailed explanation of derivations and how Nixpkgs is constructed from first principles

Nixpkgs provides generic build mechanisms that are widely used:

- [`stdenv`][stdenv] - most importantly `mkDerivation`
- [Build helpers][build-helpers] - for creating derivations, including shell scripts and single files

Packages from Nixpkgs can be modified through multiple mechanisms:

- [overrides] – specifically `override` and `overrideAttrs` to modify single packages
- [overlays] – to produce a custom variant of Nixpkgs with individually modified packages

Different language ecosystems and frameworks have different requirements to accommodating them into Nixpkgs:

- [Languages and frameworks][language-support] lists tools provided by Nixpkgs to build language- or framework-specific packages with Nix.

The NixOS Linux distribution uses a [modular configuration system](https://nix.dev/tutorials/module-system/) that imposes its own conventions.

[nix-pills]: https://nixos.org/guides/nix-pills/
[stdenv]: https://nixos.org/manual/nixpkgs/stable/#chap-stdenv
[build-helpers]: https://nixos.org/manual/nixpkgs/stable/#part-builders
[overlays]: https://nixos.org/manual/nixpkgs/stable/#chap-overlays
[overrides]: https://nixos.org/manual/nixpkgs/stable/#chap-overrides
[language-support]: https://nixos.org/manual/nixpkgs/stable/#chap-language-support
[nixos-modules]: https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules
