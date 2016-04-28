# Committed
Committed is a simple vim plugin that will send you a Mac OSX desktop
notification if you haven't committed your code within a certain amount of
time. To keep from being annoying, consecutive reminder messages are shown with
an exponential backoff. See the section on configuration to choose your
threshold settings.

![Committed Example Image](/doc/committed.png)

## Installation

Committed may be installed directly from Github. It's recommended to use a
plugin manager.

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

## Configuration
There are a few configurable parameters to tune operation to your needs.

Here's the default configuration:
```vim
  " Start alerting after 5 minutes without a commit.
  " The threshold doubles each time it occurs
  " So for instance the first notice is at 5 minutes, 
  " then 10, then 20, then 40, etc.
  let g:committed_min_time_threshold = 5
```

## Known Issues
Due to how applescript works within tmux, if running vim within tmux you may
need to install an additional tool. With homebrew you can run:
```sh
  brew install reattach-to-user-namespace
```

Currently the plugin only keeps state for the current repo and will get
confused if switching directories (in vim) between multiple git repos.

## Bug Reports
Please report any bugs encountered as issues on Github.
