FROM node:onbuild
RUN wget http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.21/GraphicsMagick-1.3.21.tar.gz -O /tmp/GraphicsMagick-1.3.21.tar.gz
WORKDIR /tmp
RUN tar -xvf GraphicsMagick-1.3.21.tar.gz
WORKDIR /tmp/GraphicsMagick-1.3.21
RUN ./configure --disable-shared --disable-installed
RUN make install
ENV PATH /usr/local/bin:$PATH
WORKDIR /usr/src/app
EXPOSE 8000
