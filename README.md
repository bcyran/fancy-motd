# Fancy MOTD
Fancy, colorful MOTD written in bash. Server status at a glance.

![MOTD screenshot](readme-img.png)

## Usage

### Running
Clone the repository:
```shell
git clone https://github.com/bcyran/fancy-motd.git
```

Then run `motd.sh`:
```shell
./fancy-motd/motd.sh
```

This runs all the scripts in `modules` directory in order, `run-parts` style, and formats the output.

If any modules are missing in your output, plese see [requirements](#requirements).

You can also pass the config file path as the script argument (see [configuration](#configuration)):
```shell
./fancy-motd/motd.sh ./path/to/config.sh
```

### Running at login
One way to run it at each login is to add a line to `~/.profile` file (assuming you cloned `fancy-motd` into your home directory):
```shell
~/fancy-motd/motd.sh
```

If you don't want to run it in all subshells you could do something like this instead:
```shell
if [ -z "$FANCY_MOTD" ]; then
    ~/fancy-motd/motd.sh
    export FANCY_MOTD=1
fi
```

If you use `tmux` and don't want to see the motd everytime you open a new shell in `tmux`, add this to your `.tmux.conf`:
```
set-option -ga update-environment ' FANCY_MOTD'
```

### Requirements
In order to run all the available modules the following programs are required:

* [`figlet`](http://www.figlet.org/)
* [`curl`](https://curl.se/)
* [`bc`](https://www.gnu.org/software/bc/)
* [`fortune`](https://software.clapper.org/fortune/)
* [`lm-sensors`](https://github.com/lm-sensors/lm-sensors)

This list excludes the obvious ones, like [`tmux`](https://github.com/tmux/tmux) for `tmux` module.

If any program requried by the given module is missing (or any other error occurs), it will fail silently, i.e. the module just won't be shown at all.


### Configuration
You can configure some aspects of the motd using config file.
By default `config.sh` file in the `fancy-motd` directory will be read if it exists.
Alternatively you can pass path to another config as a script argument.

There's an example file provided in the repo:
```shell
cd fancy-motd
cp config.sh.example config.sh
```

## Hacking
To add a new module you can create a new script in `modules` directory.
For the output to be properly formatted it has to use `print_columns` function from `framework.sh`, please refer to the existing modules.

Module files have to start with a two digit number followed by a hyphen. You may disable modules by simply rename the module file.

## Credits
Fancy MOTD is hugely inspired by [this repo](https://github.com/HermannBjorgvin/MOTD) by Hermann Björgvin.
