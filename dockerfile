# ==========================================
# STAGE 1: Download & Build AI Tool Binaries
# ==========================================
FROM node:22-slim AS tool-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g opencode-ai

RUN curl -L https://googleapis.com -o /usr/local/bin/claude \
    && chmod +x /usr/local/bin/claude

# ==========================================
# STAGE 2: CUDA Accelerated Runtime Image
# ==========================================
FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies, core extensions, vim, and keys safely
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3-pip \
    python3.11-dev \
    nodejs \
    npm \
    build-essential \
    llvm \
    git \
    curl \
    vim \
    openssh-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# FIX: Safely provision the official GitHub CLI verified repository mirror via structured keys
RUN mkdir -p -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Symlink python to python3.11
RUN ln -sf /usr/bin/python3.11 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip

COPY --from=tool-builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=tool-builder /usr/local/bin/opencode /usr/local/bin/opencode
COPY --from=tool-builder /usr/local/bin/claude /usr/local/bin/claude

# Ensure both AI tool binaries have execution permissions
RUN chmod +x /usr/local/bin/opencode /usr/local/bin/claude

WORKDIR /workspace

RUN pip install --no-cache-dir \
    numpy \
    pandas \
    numba \
    cuda-python \
    ipython

ENV NUMBA_CUDA_DRIVER=/usr/lib/x86_64-linux-gnu/libcuda.so
ENV EDITOR=vim

CMD ["/bin/bash"]

