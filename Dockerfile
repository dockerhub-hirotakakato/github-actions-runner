FROM debian:stable-slim

RUN apt-get -qy update && \
    apt-get -qy --no-install-recommends install ca-certificates sudo wget && \
    echo 'runner ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/runner && \
    useradd -d /runner -s /bin/bash runner && \
    mkdir /runner && \
    cd /runner && \
    version=$(wget -qO- https://api.github.com/repos/actions/runner/releases/latest | sed 's/^ *"tag_name": "v\(.*\)",$/\1/p' -n) && \
    wget -qO- https://github.com/actions/runner/releases/download/v$version/actions-runner-linux-x64-$version.tar.gz | tar zxf - && \
    chown -R runner: . && \
    bin/installdependencies.sh && \
    ( echo '#!/bin/bash' && \
      echo '/runner/config.sh --unattended --url $url --token $token --labels $labels' && \
      echo 'exec /runner/run.sh' \
    ) | install /dev/stdin /cmd.sh && \
    rm -r /root/.wget-hsts /var/lib/apt/lists/*

USER runner
WORKDIR /runner

CMD ["/cmd.sh"]
