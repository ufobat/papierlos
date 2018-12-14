FROM ubuntu:latest AS CompilePerl6

WORKDIR /compile

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install build-essential curl wget git \
    && wget https://rakudo.perl6.org/downloads/star/rakudo-star-2018.10.tar.gz \
    && tar xfz rakudo-star-2018.10.tar.gz \
    && cd rakudo-star-2018.10 \
    && perl Configure.pl --gen-moar --make-install --prefix /opt/rakudo

RUN curl -L https://cpanmin.us | perl - App::cpanminus \
    && cpanm Test::Harness --no-wget \
    && git clone https://github.com/ugexe/zef.git \
    && prove -v -e 'perl6 -I zef/lib' zef/t \
    && perl6 -Izef/lib zef/bin/zef --verbose install ./zef \
    && zef install Inline::Perl5

FROM ubuntu:latest

WORKDIR /srv

COPY --from=CompilePerl6 /opt/perl6 /opt/perl6

ENV PATH=$PATH:/opt/rakudo/bin:/opt/rakudo/share/perl6/site/bin

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install tesseract-ocr sane sane-utils

