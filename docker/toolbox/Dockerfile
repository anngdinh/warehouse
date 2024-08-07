FROM ubuntu:22.04
      
RUN apt update && apt install build-essential libssl-dev git make unzip jq bc -y

RUN apt update && apt install -y traceroute tmux make telnet git dnsutils curl wget vim && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    wget https://get.helm.sh/helm-v3.9.3-linux-amd64.tar.gz && tar xvf helm-v3.9.3-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin && rm helm-v3.9.3-linux-amd64.tar.gz && \
    rm -rf linux-amd64 && \
    wget https://github.com/vmware-archive/octant/releases/download/v0.25.1/octant_0.25.1_Linux-64bit.deb && \
    dpkg -i octant_0.25.1_Linux-64bit.deb && rm octant_0.25.1_Linux-64bit.deb && \
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p ~/.kube && touch ~/.kube/config && \
    chmod o-r ~/.kube/config && chmod g-r ~/.kube/config

# Install kubecolor
RUN curl -OL https://github.com/kubecolor/kubecolor/releases/download/v0.3.3/kubecolor_0.3.3_linux_amd64.tar.gz && \
    tar -xvf kubecolor_0.3.3_linux_amd64.tar.gz && \
    cp kubecolor /usr/local/bin && \
    echo 'alias k=kubecolor' >> ~/.bashrc && \
    rm -rf kubecolor_0.3.3_linux_amd64.tar.gz

# Install wrk
RUN git clone https://github.com/wg/wrk.git wrk --depth=1 && \
    cd wrk && \
    make && \
    cp wrk /usr/local/bin && \
    cd .. && \
    rm -rf wrk

# Install sockperf
RUN apt-get update && apt-get install -y autoconf automake libtool && \
    git clone https://github.com/Mellanox/sockperf.git --depth=1  && cd sockperf && \
    ./autogen.sh && ./configure --prefix=/usr/local/ && make && make install && \
    cd .. && rm -rf sockperf

# Download and build iperf3 from sources
RUN curl -LO https://downloads.es.net/pub/iperf/iperf-3.1.tar.gz && tar zxf iperf-3.1.tar.gz && \
    cd iperf-3.1 && ./configure --prefix=/usr/local --bindir /usr/local/bin && make && make install && \
    cd .. && rm -rf iperf-3.1.tar.gz iperf-3.1

# Download and build netperf from sources
RUN curl -LO https://github.com/HewlettPackard/netperf/archive/netperf-2.7.0.tar.gz && tar -xzf netperf-2.7.0.tar.gz && mv netperf-netperf-2.7.0/ netperf-2.7.0 && \
    cd netperf-2.7.0 && ./configure --prefix=/usr/local --bindir /usr/local/bin && make CFLAGS=-fcommon && make install && \
    cd .. && rm -rf netperf-2.7.0.tar.gz netperf-2.7.0

# Install golang
RUN curl -OL https://go.dev/dl/go1.22.4.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc && \
    rm -rf go1.22.4.linux-amd64.tar.gz

# Install velero
RUN curl -OL https://github.com/vmware-tanzu/velero/releases/download/v1.13.2/velero-v1.13.2-linux-amd64.tar.gz && \
    tar -xvf velero-v1.13.2-linux-amd64.tar.gz && \
    cp velero-v1.13.2-linux-amd64/velero /usr/local/bin && \
    rm -rf velero-v1.13.2-linux-amd64.tar.gz && \
    rm -rf velero-v1.13.2-linux-amd64

# Install kube node shell
RUN curl -LO https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell && \
    chmod +x ./kubectl-node_shell && \
    mv ./kubectl-node_shell /usr/local/bin/kubectl-node_shell && \
    rm -rf ./kubectl-node_shell

CMD ["/bin/bash"]

# each command run in a separate layer, should merge them into one RUN command