FROM rust

EXPOSE 3000
EXPOSE 3001

ADD [".vimrc", "~/.vimrc"]

RUN apt-get update \ 
   && apt-get install -y vim ripgrep \
   && curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
   && cargo install mdbook

ENV FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
