FROM fischerscode/flutter-sudo:master

COPY . /Diagora/AppMobile

WORKDIR /Diagora/AppMobile

RUN flutter upgrade && flutter clean

CMD flutter run -d linux
