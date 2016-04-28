# Committed
Committed is a simple vim plugin that will send you a Mac OSX desktop
notification if you haven't committed your code within a certain amount of
time. To keep from being annoying, consecutive reminder messages are shown with
an exponential backoff. See the section on configuration to choose your
threshold settings.

Committed will run a check each time you write a buffer.

![Committed Example Image](/doc/committed.png)

## Installation

Committed may be installed directly from Github. It's recommended to use a
plugin manager. Committed requires OSX.

Using [Vim-Plug](https://github.com/junegunn/vim-plug)

Add the following to your vimrc:
```vim
    Plug 'ChrisPenner/vim-committed'
```

Using [Vundle](https://github.com/VundleVim/Vundle.vim):

Add the following to your vimrc:
```vim
    Plugin 'ChrisPenner/vim-committed'
```

Using [Pathogen](https://github.com/tpope/vim-pathogen):

Run the following command:
```vim
    cd ~/.vim/bundle && \
    git clone git://github.com/ChrisPenner/vim-committed.git
```

## Commands

Use the following commands to enable/disable/toggle the plugin.
```vim
    :CommittedDisable
    :CommittedEnable
    :CommittedToggle
```

## Configuration
There are a few configurable parameters to tune operation to your needs.

Here's the default configuration:
```vim
  " Start alerting after 5 minutes without a commit.
  " The threshold doubles each time it occurs
  " So for instance the first notice is at 5 minutes,
  " then 10, then 20, then 40, etc.
  let g:committed_min_time_threshold = 5

  " A notification won't be triggered unless at least this many lines
  " have been changed.
  let g:committed_lines_threshold = 15
```

## Known Issues
Due to how applescript works within tmux, if running vim within tmux you may
need to install an additional tool. With homebrew you can run:
```sh
  brew install reattach-to-user-namespace
```

## Bug Reports
Please report any bugs encountered as issues on Github.
