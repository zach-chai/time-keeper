FROM ruby:2.4.2

# app dependencies
RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /opt/time_tracker
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# ADD . $APP_HOME/

# RUN bundle
