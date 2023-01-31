FROM ubuntu:latest

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates sudo wget; \
    echo 'runner ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/runner; \
    useradd -d /runner -m -s /bin/bash runner; \
    mkdir /runner/runner; \
    cd /runner/runner; \
    runner_version=$(wget -qO- https://api.github.com/repos/actions/runner/releases/latest | sed 's/^ *"tag_name": "v\(.*\)",$/\1/p' -n); \
    wget -qO- https://github.com/actions/runner/releases/download/v$runner_version/actions-runner-linux-x64-$runner_version.tar.gz | tar zxf -; \
    chown -R runner: /runner; \
    bin/installdependencies.sh; \
    ( echo '#!/bin/bash -eu'; \
      echo '/runner/runner/config.sh --unattended --url $url --token $token --labels "${labels-}"'; \
      echo 'exec /runner/runner/run.sh'; \
    ) | install -o runner -g runner -m 755 /dev/stdin /runner/cmd.sh; \
    apt-get clean; \
    rm -r /root/.wget-hsts /var/lib/apt/lists/*

USER runner
WORKDIR /runner
CMD ["./cmd.sh"]
