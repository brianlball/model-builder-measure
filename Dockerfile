ARG OPENSTUDIO_VERSION=3.1.0
FROM nrel/openstudio:$OPENSTUDIO_VERSION as base
MAINTAINER Brian Ball brian.ball@nrel.gov

ENV RUBY_VERSION=2.5.1
ARG OS_BUNDLER_VERSION=2.1.0
ENV BUNDLE_WITHOUT=native_ext

# install locales and set to en_US.UTF-8. This is needed for running the CLI on some machines
# such as singularity.
RUN apt-get update && apt-get install -y \
        curl \
        vim \
        gdebi-core \
        git \
        emacs \
        ruby2.5 \
        libsqlite3-dev \
        ruby-dev \ 
        libffi-dev \
        python3.7-dev \
        python3-pip \
        python3-apt \        
        build-essential \
        zlib1g-dev \
        vim \ 
        git \
	    locales \
        sudo

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1
RUN update-alternatives --set python /usr/bin/python3.7
#RUN update-alternatives --config python
RUN ln -s /usr/bin/pip3 /usr/bin/pip
RUN python -m pip install --upgrade pip
RUN pip install modelica-builder

## Add RUBYLIB link for openstudio.rb
#ENV RUBYLIB=/usr/local/openstudio-${OPENSTUDIO_VERSION}${OPENSTUDIO_VERSION_EXT}/Ruby
#ENV ENERGYPLUS_EXE_PATH=/usr/local/openstudio-${OPENSTUDIO_VERSION}${OPENSTUDIO_VERSION_EXT}/EnergyPlus/energyplus

# The OpenStudio Gemfile contains a fixed bundler version, so you have to install and run specific to that version
RUN gem install bundler -v $OS_BUNDLER_VERSION
#RUN cd /var/oscli && \
#    cp /usr/local/openstudio-${OPENSTUDIO_VERSION}${OPENSTUDIO_VERSION_EXT}/Ruby/Gemfile /var/oscli/ && \
#    cp /usr/local/openstudio-${OPENSTUDIO_VERSION}${OPENSTUDIO_VERSION_EXT}/Ruby/Gemfile.lock /var/oscli/ && \
#    cp /usr/local/openstudio-${OPENSTUDIO_VERSION}${OPENSTUDIO_VERSION_EXT}/Ruby/openstudio-gems.gemspec /var/oscli/
#WORKDIR /var/oscli
 #RUN bundle _${OS_BUNDLER_VERSION}_ install --path=gems --without=native_ext --jobs=4 --retry=3
 #RUN bundle _${OS_BUNDLER_VERSION}_ install --path=gems --jobs=4 --retry=3

# Configure the bootdir & confirm that openstudio is able to load the bundled gem set in /var/gemdata
VOLUME /var/simdata/openstudio
#WORKDIR /var/simdata/openstudio
RUN openstudio --verbose --bundle /var/oscli/Gemfile --bundle_path /var/oscli/gems --bundle_without native_ext  openstudio_version
#RUN openstudio --verbose --bundle /var/oscli/Gemfile --bundle_path /var/oscli/gems openstudio_version

# May need this for syscalls that do not have ext in path
#RUN ln -s /usr/local/openstudio-${OPENSTUDIO_VERSION}${OPENSTUDIO_VERSION_EXT} /usr/local/openstudio-${OPENSTUDIO_VERSION}

RUN mkdir /usr/local/src/measure_test
COPY PythonMeasure /usr/local/src/measure_test/PythonMeasure/.
RUN cd /usr/local/src/measure_test/ && \
    gem install pycall
WORKDIR /usr/local/src/measure_test/
#Run the measure test
RUN cd /usr/local/src/measure_test/ && \
    ruby PythonMeasure/tests/model_measure_test.rb

CMD [ "/bin/bash" ]
