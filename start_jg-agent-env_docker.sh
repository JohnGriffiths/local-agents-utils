# =================================================
# Launch Docker Container for OpenCode Setup on WSL
# =================================================
#
#                                     JG 2026-08-07
#
# Usage:
# ======
#
# Step 0 - Install a few things like docker desktop in windows
# ------
#
#
# Step 1 - Build docker container with accompanying dockerfile
# ------
#
# docker build -t jg-agent-env .
#
#
#
# Step 2 - Run this bash script to launch docker container
# ------
#
# bash start_jg-agent-env_docker.sh
#
#
# 
# Step 3 - Launch opencode
# ------
#
# opencode --yolo    (yolo mode is why we're doing this! ) 
#
#
# (if we put it in the launch command then seems that we 
#  can't then drop down to an interactive terminal without 
#  killing the container )
#
#
# Opencode/docker usage tips/notes
# --------------------------------
#
# to drop down to terminal while opencode is running (e.g. to use vim):
# ctrl+z    # (suspends opencode)
# fg        # (returns to opencode)


# necessary ssh key copy step
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# run the container
docker run -it --rm \
  --gpus all \
  -v "$(pwd)":/workspace \
  -v "$HOME/.gitconfig:/root/.gitconfig:ro" \
  -v "$HOME/.config/gh:/root/.config/gh:ro" \
  -v "$SSH_AUTH_SOCK:/run/ssh-agent.sock" \
  -e SSH_AUTH_SOCK=/run/ssh-agent.sock \
  -e ANTHROPIC_API_KEY="your_claude_key" \
  jg-agent-env /bin/bash -c "
    echo 'Checking repository status...';
    
    rm -rf abw_clonetest
    git clone git@github.com:johngriffiths/abw abw_clonetest
    
    exec /bin/bash
    

  "

