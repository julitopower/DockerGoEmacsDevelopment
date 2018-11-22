FROM ubuntu:latest

# Install basic utilities needed
RUN apt-get update -y && apt-get install wget git gcc-4.8 make libncurses-dev sudo -y
ENV CC /usr/bin/gcc-4.8

# Build and install emacs
RUN wget http://mirrors.ibiblio.org/gnu/ftp/gnu/emacs/emacs-24.5.tar.gz && \
    tar -xzf emacs-24.5.tar.gz && cd emacs-24.5/ && ./configure &&         \
    make install && make distclean && cd ../ && rm emacs-24.5/ -rf &&      \
    rm emacs-24.5.tar.gz

# Create golang user
RUN adduser --disabled-password --gecos '' golang && adduser golang sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER golang

# Install Go
RUN mkdir -p $HOME/staging/ && cd ~/staging/ &&                  \
    wget https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz && \
    sudo tar -C /usr/local -xzf go1.11.2.linux-amd64.tar.gz &&   \
    mkdir -p $HOME/go/src $HOME/go/pkg/ $HOME/go/bin/

ENV GOPATH "/home/golang/go"
RUN echo $GOPATH && ls $GOPATH
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin/

# Copy .emacs and Go test program
COPY emacs_config /home/golang/
COPY go_example ${GOPATH}/src/
RUN sudo chown golang:golang /home/golang -R

# Install go packages to support Emacs development
RUN go get -u golang.org/x/tools/cmd/...       \
&& go get -u github.com/rogpeppe/godef/...     \
&& go get -u github.com/nsf/gocode             \
&& go get -u golang.org/x/tools/cmd/goimports  \
&& go get -u golang.org/x/tools/cmd/guru       \
&& go get -u github.com/dougm/goflymake

WORKDIR ${GOPATH}/src

# Test that Go works
RUN pwd && cd HelloWorld && go build hello_world.go && ./hello_world