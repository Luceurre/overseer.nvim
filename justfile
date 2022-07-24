# This: is a comment

variable := "foo"

default:
  just --list

all: test

test name:
  ./run_tests.sh {{name}}

# TODO args with default value, varargs, param with expression, @annotation, _private
# https://cheatography.com/linux-china/cheat-sheets/justfile/
