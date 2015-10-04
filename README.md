# Tabkey

  A library for autocomplete terminal commands using the tab key
  compatible with `bash` and `zsh`.

## Usage

### tabkey on

  ```sh
  tabkey on (command) (callback)
  ```

  - `command` => name of command to autocomplete.
  - `callback` => function to call when key tab is pressed.
  
  Return `0` for success or `1` for failure.

### tabkey pressed

  ```sh
  if tabkey pressed; then
      ...
  fi
  ```

  Set `$TABKEY_WORDS` with the words in current command
  and `$TABKEY_CUR` with the current cursor position.

  Return `0` if tabkey was pressed or `1` otherwise.

### tabkey suggest

  ```sh
  tabkey suggest [dirs] [files] [-- command_1 command_2 ...]
  ```

  Return `0` for success or `1` for failure.

## Installation

### Bash

  ```sh
  $ git clone git://github.com/ibanfq/tabkey.git ~/.tabkey
  $ echo 'source ~/.tabkey/tabkey.sh' >> ~/.bashrc
  ```

### Zsh

  ```sh
  $ git clone git://github.com/ibanfq/tabkey.git ~/.tabkey
  $ echo 'source ~/.tabkey/tabkey.sh' >> ~/.zshrc
  ```

## Example

```sh
#!/usr/bin/env bash

foo() {
    if tabkey pressed; then
        if (( TABKEY_CUR == 2 )); then
            tabkey suggest dirs -- foo bar
        fi

        if (( TABKEY_CUR == 3 )); then
            if [ "${TABKEY_WORDS[$TABKEY_CUR-1]}" = "bar" ]; then
                tabkey suggest -- baz qux
            else
                tabkey suggest files
            fi
        fi
    fi
}

tabkey on foo foo
```

## License

  MIT
