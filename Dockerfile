FROM ubuntu:18.04 AS build

ARG node_version=10.21.0

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y curl xz-utils python3 build-essential 

WORKDIR /theia-portable

#Install node
RUN curl -L https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz | tar -xJv
ENV PATH=${PATH}:/theia-portable/node-v${node_version}-linux-x64/bin

ADD package.json .
RUN npm install yarn
ENV PATH=${PATH}:/theia-portable/node_modules/.bin

RUN yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn theia download:plugins && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

FROM ubuntu:18.04 as runner
COPY --from=build /theia-portable /theia-portable
WORKDIR /theia-portable
ENTRYPOINT [ "/theia-portable/node-v10.21.0-linux-x64/bin/node", "/home/theia/src-gen/backend/main.js", "/", "--hostname=0.0.0.0" ]

