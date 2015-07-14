FROM node:onbuild
RUN curl -s http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.21/GraphicsMagick-1.3.21.tar.gz | tar xvz -C /tmp
WORKDIR /tmp/GraphicsMagick-1.3.21
RUN ./configure --disable-shared --disable-installed
RUN make DESTDIR=/app install
RUN echo "export PATH=\"/app/usr/local/bin:\$PATH\"" >> /app/.profile.d/nodejs.sh
ENV PATH /app/usr/local/bin:$PATH
EXPOSE 8000
