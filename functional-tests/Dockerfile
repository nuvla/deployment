FROM openjdk:8-jre-slim
                
ARG GIT_BRANCH
ARG GIT_COMMIT_ID
ARG GIT_DIRTY
ARG GIT_BUILD_TIME
ARG TRAVIS_BUILD_NUMBER
ARG TRAVIS_BUILD_WEB_URL

LABEL git.branch=${GIT_BRANCH}
LABEL git.commit.id=${GIT_COMMIT_ID}
LABEL git.dirty=${GIT_DIRTY}
LABEL git.build.time=${GIT_BUILD_TIME}
LABEL travis.build.number=${TRAVIS_BUILD_NUMBER}
LABEL travis.build.web.url=${TRAVIS_BUILD_WEB_URL}

ADD . /root

RUN chmod 0755 /root/start-tests.sh

RUN cd /root && apt-get update && apt-get install -y curl && curl -o /usr/local/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && chmod 0755 /usr/local/bin/lein && /usr/local/bin/lein -v && apt-get remove -y curl && apt autoremove -y && rm -rf /var/lib/apt/lists/*

ENV NUVLA_USERNAME=super
ENV NUVLA_PASSWORD=supeRsupeR
ENV NUVLA_INSECURE=FALSE

ENTRYPOINT ["/root/start-tests.sh"]
