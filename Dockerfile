FROM node:22-bookworm
 
ARG UID=1000
ARG GID=1000
 
RUN npm install -g pnpm
 
RUN userdel -r node 2>/dev/null || true \
 && (getent group ${GID} >/dev/null || groupadd -g ${GID} dev) \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash dev \
 && mkdir -p /workspace && chown ${UID}:${GID} /workspace
 
USER dev
ENV HOME=/home/dev
ENV PATH="/home/dev/.foundry/bin:${PATH}"
 
RUN curl -L https://foundry.paradigm.xyz | bash \
 && /home/dev/.foundry/bin/foundryup
 
RUN git config --global --add safe.directory '*'
 
RUN mkdir -p /home/dev/.svm /home/dev/.local/share/pnpm
 
WORKDIR /workspace
EXPOSE 8545 4337
CMD ["bash"]
