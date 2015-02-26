# Searchers.vim

Searchers.vim is a library for easily creating search bindings in vim. It was inspired by the
frequency with which I found myself copying an error message from a log file into google.

At first I added a `gl` operator to search google (if you don't know what an operator is, google
"vim operators and motions" - I promise it'll change your life (assuming your as much of a vim nerd
as I am that is)). Soon I added another operator to search my employers jira... then stack
overflow... and so on.

I rapidly realised that searching directly from vim was awesome, so I wrote this plugin to make it
super easy to set up new search operators.

## Usage

Here is a snippet from my `.vimrc`

```{.vim}
    call searchers#make_binding({
          \ 'name': "Google",
          \ 'prefix': "https://www.google.co.uk/search?q=",
          \ 'binding': 'gl'
          \ })
```

With this I can search google using a motion (eg. `gliw`) or using visual mode and then `gl`. It
intentionally does not work with linewise visual mode since multiline google searches would be weird

Here's another example with a prefix and a suffix

```{.vim}
call searchers#make_binding({
      \ 'name': 'Jira',
      \ 'binding': 'Pj',
      \ 'prefix': 'https://jira.corporate.intranet/issues/?jql=text ~ "',
      \ 'suffix': '"'
      \})
```

## Warning!

As far as I'm aware, no one else has ever used this but me, and as a result, I've rather obnoxiously
hardcoded the method for opening urls into the plugin. That means it will use the `firefox` shell
command if it's available and if not it will fall back to the mac `open` shell command. If you want
to use this plugin, but you don't like that behaviour let me know and I'll gladly fix it.

