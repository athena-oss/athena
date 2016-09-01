# Testing

To ensure that you build robust `plugins`, Athena also provides a built-in testing framework for Bash. With this functionality you can do unit tests to all the functions that you implement.

For the full API on *Testing*, please have a look at the functions under the namespace `athena.test.`.

## Mocking

This is a very important part of testing because it allows you to *fake* third-party functions that you don't care to test while testing your code. The best way to include these types of functions in your code, so that you can mock later, is to not use them directly, but instead, create a wrapper around it. Using this method you will be able to mock the wrapper and your code will be easy to test.

### Example: mocking grep
```bash
# in your code
function my_grep()
{
  grep $@
}

function my_function_that_uses_grep()
{
  if my_grep "val" $1; then
    return 1
  fi
  return 0
}

# in your test
athena.test.mock.returns "my_grep" 0
athena.test.assert_return "my_function_that_uses_grep" 1
```

## Testcases

For Athena to acknowledge a file containing tests as a *TestSuite*, you need to respect the following conventions :

  * File *MUST* follow the pattern `test.<functions_to_test>.sh`
  * Functions inside this file *MUST* follow the pattern `testcase_<name_of_the_function_to_test>()`

### Example : test.example.sh
```bash
function testcase_my_function()
{
  ...
}
```

## Assertions

You can do assertions on :

### Values
```bash
athena.test.assert_value "One" "One"
athena.test.assert_value.expects_fail "One" "Two"
```

### Output
```bash
athena.test.assert_output "_my_function" "OK" "pass"
athena.test.assert_output.expects_fail "_my_function" "OK" "fail"
```

### Return
```bash
athena.test.assert_return "_my_function" "pass"
athena.test.assert_return.expects_fail "_my_function" "fail"
```

### Exit code
```bash
athena.test.assert_exit_code "_my_function_with_exit_0"
athena.test.assert_exit_code.expects_fail "_my_function_with_exit_1"
```

### String
```bash
athena.test.assert_string_contains "my string" "my"
athena.test.assert_string_contains.expects_fail "my string" "xpto"
```

## Other useful features

There are a few other useful features that you can use while implementing tests :

* Create temporary directories

```bash
tmpdir=$(athena.test.create_tempdir)
```


* Create temporary files

```bash
tmpfile=$(athena.test.create_tempfile)
```

## Executing the Testsuites
```bash
$ ./athena cli <testsuite_directory|file> [<source_directory>] [--list]
```
