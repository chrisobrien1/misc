FROM jetbrains/teamcity-agent:2021.2.1-linux-sudo

USER root

# Stops tzdata from asking for input
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update

# Install Mono
RUN apt -y --no-install-recommends install \
    gnupg \
    ca-certificates && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
    apt update && \
    apt -y --no-install-recommends install mono-devel

# Run scripts to install nodejs repo
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

# Install basic tools
RUN apt-get update && \
    apt-get -y --no-install-recommends install \
    nodejs \
    wget \
    apt-transport-https \
    software-properties-common \
    nuget \
    sudo \
    zip

# Install PowerShell
# https://docs.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.2
# Register the Microsoft repository GPG keys
# Update the list of packages after we added packages.microsoft.com
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell

# Install Octopus CLI
RUN curl -sSfL https://apt.octopus.com/public.key | apt-key add - && \
    sh -c "echo deb https://apt.octopus.com/ stable main > /etc/apt/sources.list.d/octopus.com.list" && \
    apt update && \
    apt install -y --no-install-recommends octopuscli

RUN npm install -g @angular/cli

RUN chown buildagent \ 
    /data/teamcity_agent/conf \
    /opt/buildagent/work \
    /opt/buildagent/temp \
    /opt/buildagent/tools \
    /opt/buildagent/plugins \
    /opt/buildagent/system

USER buildagent
